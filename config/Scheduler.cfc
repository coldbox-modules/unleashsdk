component {

    property name="refreshInterval" inject="box:setting:refreshInterval@unleashsdk";
    property name="metricsInterval" inject="box:setting:metricsInterval@unleashsdk";
    property name="unleash" inject="provider:UnleashSDK@unleashsdk";
    property name="log" inject="logbox:logger:{this}";

    function configure() {
        task( "unleashsdk-refresh-features" )
			.when( () => !variables.unleash.isOffline() )
            .call( () => variables.unleash.refreshFeatures() )
            .delay( variables.refreshInterval, "seconds" )
            .every( variables.refreshInterval, "seconds" )
            .before( function() {
                if ( log.canDebug() ) {
                    log.debug( "Starting to fetch new features from Unleash" );
                }
            } )
            .onSuccess( function( task, results ) {
                if ( log.canDebug() ) {
                    log.debug( "Successfully refreshed features", results );
                }
            } )
            .onFailure( function( task, exception ) {
                if ( log.canError() ) {
                    log.error( "Exception when running task [unleashsdk-refresh-features]:", exception );
                }
            } );

        task( "unleashsdk-send-metrics" )
			.when( () => !variables.unleash.isOffline() )
            .call( () => variables.unleash.sendMetrics() )
            .every( variables.metricsInterval, "seconds" )
            .delay( variables.metricsInterval, "seconds" )
            .before( function() {
                if ( log.canDebug() ) {
                    log.debug( "Starting to send metrics to Unleash" );
                }
            } )
            .onSuccess( function( task, results ) {
                if ( log.canDebug() ) {
                    log.debug( "Successfully sent metrics to Unleash features", results );
                }
            } )
            .onFailure( function( task, exception ) {
                if ( log.canError() ) {
                    log.error( "Exception when running task [unleashsdk-send-metrics]:", exception );
                }
            } );
    }

}
