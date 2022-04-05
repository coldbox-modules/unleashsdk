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
            "environment": wirebox.getInstance( "box:setting:environment", getSystemSetting( "ENVIRONMENT", "production" ) ),
            "contextProvider": "DefaultContextProvider@unleashsdk",
            "apiURL": getSystemSetting( "UNLEASH_API_URL" ),
            "apiToken": getSystemSetting( "UNLEASH_API_TOKEN" ),
            "refreshInterval": 10,
            "metricsInterval": 60
        };

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

        binder.map( "UnleashSDK@unleashsdk" )
            .to( "#moduleMapping#.models.UnleashSDK" );

        binder.map( "@unleashsdk" )
            .toDSL( "UnleashSDK@unleashsdk" );
	}

	function onLoad() {
        wirebox.getInstance( "UnleashSDK@unleashsdk" ).register();
	}

    private string function getApplicationName() {
		try {
			return getApplicationSettings().name;
		} catch ( any e ) {
			return "";
		}
	}

    private string function resolveHostname() {
		var hostname = createObject( "java", "java.lang.System" ).getProperty( "hostname" );
		if ( isNull( hostname ) ) {
			try {
				hostname = createObject( "java", "java.net.InetAddress" ).getLocalHost().getHostName();
			} catch ( UnknownHostException e ) {
				hostname = "undefined";
			}
		}
		return hostname;
	}

}
