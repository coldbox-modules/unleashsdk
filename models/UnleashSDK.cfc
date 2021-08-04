component singleton accessors="true" {

	property name="settings" inject="coldbox:moduleSettings:unleashsdk";
	property name="client"   inject="UnleashHyperClient@unleashsdk";
	property name="log"      inject="logbox:logger:{this}";
	property name="cache"    inject="cachebox:default";
	property name="wirebox"  inject="wirebox";

	variables.strategies = {
		"default"             : "DefaultStrategy@unleashsdk",
		"userWithId"          : "UserWithIdStrategy@unleashsdk",
		"flexibleRollout"     : "FlexibleRolloutStrategy@unleashsdk",
		"remoteAddress"       : "RemoteAddressStrategy@unleashsdk",
		"applicationHostname" : "ApplicationHostnameStrategy@unleashsdk"
	};

	public boolean function isEnabled(
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

	private array function fetchFeatures() {
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

}
