component {

	this.name = "unleashsdk";
	this.author = "Eric Peterson";
	this.webUrl = "https://github.com/coldbox-modules/unleashsdk";
	this.dependencies = [ "hyper" ];
    this.version = "0.1.0";

	function configure() {
		settings = {
            "appName": getApplicationName(),
            "instanceId": resolveHostname(),
            "environment": resolveEnvironment(),
            "contextProvider": "DefaultContextProvider@unleashsdk",
            "apiURL": resolveSystemSetting( "UNLEASH_API_URL", "" ),
            "apiToken": resolveSystemSetting( "UNLEASH_API_TOKEN", "" ),
            "refreshInterval": 10,
            "metricsInterval": 60,
            "autoRegister": true
        };

        binder.map( "UnleashSDK@unleashsdk" )
            .to( "#moduleMapping#.models.UnleashSDK" );

        binder.map( "@unleashsdk" )
            .toDSL( "UnleashSDK@unleashsdk" );
	}

	function onLoad() {
        binder.map( "UnleashHyperClient@unleashsdk" )
            .to( "hyper.models.HyperBuilder" )
            .asSingleton()
            .initWith(
                baseUrl = settings.apiURL,
                bodyFormat = "json",
                headers = {
                    "Authorization": settings.apiToken,
                    "Content-Type": "application/json"
                }
            );

        if ( settings.autoRegister ) {
            wirebox.getInstance( "UnleashSDK@unleashsdk" ).register();
        }
	}

    private string function resolveSystemSetting( required string name, any defaultValue ) {
        var envValue = javaSystem().getEnv( arguments.name );

        if ( !isNull( envValue ) && envValue != "" ) {
            return envValue;
        }

        var propsValue = javaSystem().getProperty( arguments.name );

        if ( !isNull( propsValue ) && propsValue != "" ) {
            return propsValue;
        }

        if ( !isNull( arguments.defaultValue ) ) {
            return arguments.defaultValue;
        }

        throw( "No env or system prop set for [#arguments.name#]" );
    }

    private string function getApplicationName() {
		try {
			return getApplicationSettings().name;
		} catch ( any e ) {
			return "";
		}
	}

    private string function resolveHostname() {
		var hostname = javaSystem().getProperty( "hostname" );
		if ( isNull( hostname ) ) {
			try {
				hostname = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName();
			} catch ( UnknownHostException e ) {
				hostname = "undefined";
			}
		}
		return hostname;
	}

    private string function resolveEnvironment() {
        var configSettings = wirebox.getInstance( "box:configSettings" );

        if (
            structKeyExists( configSettings, "ENVIRONMENT" ) &&
            !isNull( configSettings.environment ) &&
            isSimpleValue( configSettings.environment ) &&
            configSettings.environment != ""
        ) {
            return configSettings.environment;
        }

        var envEnvironment = javaSystem().getEnv( "ENVIRONMENT" );

        if ( !isNull( envEnvironment ) && envEnvironment != "" ) {
            return envEnvironment;
        }

        var propsEnvironment = javaSystem().getProperty( "ENVIRONMENT" );

        if ( !isNull( propsEnvironment ) && propsEnvironment != "" ) {
            return propsEnvironment;
        }

        return "production";
    }

    private any function javaSystem() {
        param variables._javaSystem = createObject( "java", "java.lang.System" );
        return variables._javaSystem;
    }

}
