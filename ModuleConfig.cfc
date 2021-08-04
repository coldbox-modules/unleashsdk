component {

	this.name = "unleashsdk";
	this.author = "Eric Peterson";
	this.webUrl = "https://github.com/coldbox-modules/unleashsdk";
	this.dependencies = [ "hyper" ];

	function configure() {
		settings = {
            "environment": variables.controller.getSetting( "environment" ),
            "contextProvider": "DefaultContextProvider@unleashsdk",
            "apiURL": getSystemSetting( "UNLEASH_API_URL" ),
            "apiToken": getSystemSetting( "UNLEASH_API_TOKEN" ),
            "cacheTimeout": createTimeSpan( 0, 0, 0, 10 ),
            "refreshInterval": 10
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
        
	}

}
