component singleton accessors="true" {

	property name="settings" inject="box:moduleSettings:unleashsdk";
	property name="config"   inject="box:moduleConfig:unleashsdk";
	property name="client"   inject="UnleashHyperClient@unleashsdk";
	property name="log"      inject="logbox:logger:{this}";
	property name="cache"    inject="cachebox:default";
	property name="wirebox"  inject="wirebox";

	property name="isRegistered" default="false";
	property name="_isOffline"    default="false";

	variables.strategies = {
		"default"             : "DefaultStrategy@unleashsdk",
		"userWithId"          : "UserWithIdStrategy@unleashsdk",
		"flexibleRollout"     : "FlexibleRolloutStrategy@unleashsdk",
		"remoteAddress"       : "RemoteAddressStrategy@unleashsdk",
		"applicationHostname" : "ApplicationHostnameStrategy@unleashsdk"
	};

	function onDIComplete() {
		variables.metricsBucket = newMetricsBucket();
	}

	public UnleashSDK function register() {
		if ( variables.settings.apiToken == "" ) {
			variables._isOffline = true;
			if ( variables.log.canWarn() ) {
				variables.log.warn( "UnleashSDK was asked to register, but no API token was provided." );
			}
			return this;
		}

		if ( variables.isRegistered ) {
			if ( variables.log.canInfo() ) {
				variables.log.info( "UnleashSDK was asked to register, but it is already registered." );
			}
			refreshFeatures();
			return this;
		}

		var registrationInfo = {
			"appName"    : variables.settings.appName,
			"instanceId" : variables.settings.instanceId,
			"sdkVersion" : "coldbox-modules/unleashsdk:#variables.config.version#",
			"strategies" : variables.strategies.keyArray(),
			"started"    : getIsoTimeString( now() ),
			"interval"   : variables.settings.metricsInterval * 1000
		};
		if ( log.canInfo() ) {
			log.info( "Registering instance with Unleash", registrationInfo );
		}
		variables.client.post( "/client/register", registrationInfo );
		variables.isRegistered = true;
		refreshFeatures();
		return this;
	}

	public boolean function isEnabled(
		required string name,
		struct additionalContext = {},
		boolean defaultValue     = false
	) {
		var enabled = checkEnabled( argumentCollection = arguments );
		countForMetrics( arguments.name, enabled );
		return enabled;
	}

	public boolean function checkEnabled(
		required string name,
		struct additionalContext = {},
		boolean defaultValue     = false
	) {
		var feature = getFeature( arguments.name );
		if ( isNull( feature ) ) {
			return arguments.defaultValue;
		}

		if ( !feature.enabled ) {
			return false;
		}

		var context = getContext( arguments.additionalContext );

		if ( feature.strategies.isEmpty() ) {
			return true;
		}

		for ( var strategyData in feature.strategies ) {
			var strategy = getStrategy( strategyData.name );
			if ( isNull( strategy ) ) {
				return false;
			}

			param strategyData.constraints = [];
			if ( !satisfiesConstraints( strategyData.constraints, context ) ) {
				continue;
			}

			param strategyData.parameters = {};
			if ( strategy.isEnabled( strategyData.parameters, context ) ) {
				return true;
			}
		}

		return false;
	}

	public boolean function isDisabled(
		required string name,
		struct additionalContext = {},
		boolean defaultValue     = false
	) {
		return !isEnabled( argumentCollection = arguments );
	}

	public boolean function isOffline() {
		return variables._isOffline;
	}

	private any function getStrategy( required string name ) {
		if ( !variables.strategies.keyExists( arguments.name ) ) {
			log.warn( "No Unleash strategy found for [#arguments.name#]" );
			return javacast( "null", "" );
		}

		if ( isSimpleValue( variables.strategies[ arguments.name ] ) ) {
			variables.strategies[ arguments.name ] = wirebox.getInstance( variables.strategies[ arguments.name ] );
		}

		return variables.strategies[ arguments.name ];
	}

	public struct function createFeature(
		required string name,
		required string description,
		string type      = "release",
		boolean enabled  = true,
		array strategies = []
	) {
		if ( variables._isOffline ) {
			throw(
				type = "UnleashSDK.Offline",
				message = "UnleashSDK was not provided with an API token. Features cannot be created."
			);
		}

		return variables.client
			.throwErrors()
			.post(
				"/admin/features",
				{
					"name"        : arguments.name,
					"description" : arguments.description,
					"type"        : arguments.type,
					"enabled"     : arguments.enabled,
					"strategies"  : arguments.strategies
				}
			)
			.json();
	}

	public struct function ensureFeatureExists(
		required string name,
		required string description,
		string type      = "release",
		boolean enabled  = true,
		array strategies = []
	) {
		var feature = getFeature( arguments.name );
		if ( !isNull( feature ) ) {
			return feature;
		}
		return createFeature( argumentCollection = arguments );
	}

	public any function getFeature( required string name ) {
		return arrayFindFirst( getFeatures(), function( feature ) {
			return feature.name == name;
		} );
	}

	public array function getFeatures() {
		var features = cache.get( "unleashsdk-failover" );
		if ( isNull( features ) ) {
			return [];
		}
		return features;
	}

	public array function refreshFeatures() {
		var features = fetchFeatures();
		cache.set( "unleashsdk-failover", features, 0 );
		return features;
	}

	public struct function sendMetrics() {
		if ( variables._isOffline ) {
			if ( variables.log.canWarn() ) {
				variables.log.warn( "UnleashSDK was not provided with an API token. No metrics will be sent." );
			}
			return {
				"appName"    : variables.settings.appName,
				"instanceId" : variables.settings.instanceId,
				"bucket"     : structCopy( variables.metricsBucket )
			};
		}

		var bucketToSend        = variables.metricsBucket;
		variables.metricsBucket = newMetricsBucket();
		bucketToSend.stop       = getIsoTimeString( now() );
		var metrics             = {
			"appName"    : variables.settings.appName,
			"instanceId" : variables.settings.instanceId,
			"bucket"     : bucketToSend
		};
		variables.client.post( "/client/metrics", metrics );
		return metrics;
	}

	private void function countForMetrics( required string name, required boolean enabled ) {
		if ( !variables.metricsBucket.toggles.keyExists( arguments.name ) ) {
			variables.metricsBucket.toggles[ arguments.name ] = { "yes" : 0, "no" : 0 };
		}
		variables.metricsBucket.toggles[ arguments.name ][ yesNoFormat( arguments.enabled ) ]++;
	}

	public struct function newMetricsBucket() {
		return {
			"start"   : getIsoTimeString( now() ),
			"stop"    : "",
			"toggles" : {}
		};
	}

	private array function fetchFeatures() {
		if ( variables._isOffline ) {
			if ( variables.log.canWarn() ) {
				variables.log.warn( "UnleashSDK was not provided with an API token. No features will be fetched." );
			}
			return [];
		}

		return variables.client.get( "/client/features" ).json().features;
	}

	private boolean function satisfiesConstraints( required array constraints, required struct context ) {
		for ( var constraint in arguments.constraints ) {
			if ( !satisfiesConstraint( constraint, arguments.context ) ) {
				return false;
			}
		}
		return true;
	}

	private boolean function satisfiesConstraint( required struct constraint, required struct context ) {
		var contextValue = context[ arguments.constraint.contextName ];
		var valuePresent = arrayContainsNoCase( arguments.constraint.values, contextValue );
		return arguments.constraint.operator == "IN" ? valuePresent : !valuePresent;
	}

	private struct function getContext( struct additionalContext = {} ) {
		param request.unleashContext = generateContext();
		structAppend(
			arguments.additionalContext,
			request.unleashContext,
			false
		);
		return arguments.additionalContext;
	}

	private struct function generateContext() {
		var contextProvider = wirebox.getInstance( variables.settings.contextProvider );
		return contextProvider.getContext();
	}

	private any function arrayFindFirst( required array items, required function predicate ) {
		for ( var item in arguments.items ) {
			if ( arguments.predicate( item ) ) {
				return item;
			}
		}
		return javacast( "null", "" );
	}

	private string function getIsoTimeString( required date datetime, boolean convertToUTC = true ) {
		if ( arguments.convertToUTC ) {
			arguments.datetime = dateConvert( "local2utc", arguments.datetime );
		}

		return dateFormat( arguments.datetime, "yyyy-mm-dd" ) &
		"T" &
		timeFormat( arguments.datetime, "HH:mm:ss" ) &
		"Z";
	}

}
