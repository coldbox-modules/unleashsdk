component {

    property name="refreshInterval" inject="coldbox:setting:refreshInterval@unleashsdk";
    property name="metricsInterval" inject="coldbox:setting:metricsInterval@unleashsdk";
    property name="log" inject="logbox:logger:{this}";

    function configure() {
        task( "unleashsdk-refresh-features" )
            .call( getInstance( "UnleashSDK@unleashsdk" ), "refreshFeatures" )
            .every( variables.refreshInterval, "seconds" )
            .before( function() {
                if ( log.canDebug() ) {
                    log.debug( "Starting to fetch new features from Unleash" );
                } 
            } )
            .onSuccess( function( task, results ) {
                if ( log.canInfo() ) {
                    log.info( "Successfully refreshed features", results );
                }
            } )
            .onFailure( function( task, exception ) {
                if ( log.canError() ) {
                    log.error( "Exception when running task [unleashsdk-refresh-features]:", exception );
                }
            } );

        task( "unleashsdk-send-metrics" )
            .call( getInstance( "UnleashSDK@unleashsdk" ), "sendMetrics" )
            .every( variables.metricsInterval, "seconds" )
            .delay( variables.metricsInterval, "seconds" )
            .before( function() {
                if ( log.canDebug() ) {
                    log.debug( "Starting to send metrics to Unleash" );
                } 
            } )
            .onSuccess( function( task, results ) {
                if ( log.canInfo() ) {
                    log.info( "Successfully sent metrics to Unleash features", results );
                }
            } )
            .onFailure( function( task, exception ) {
                if ( log.canError() ) {
                    log.error( "Exception when running task [unleashsdk-send-metrics]:", exception );
                }
            } );
    }

}