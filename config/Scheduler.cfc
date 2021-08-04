component {

    property name="refreshInterval" inject="coldbox:setting:refreshInterval@unleashsdk";
    property name="log" inject="logbox:logger:{this}";

    function configure() {
        task( "unleashsdk-refresh-features" )
            .call( getInstance( "UnleashSDK@unleashsdk" ), "refreshFeatures" )
            .every( variables.refreshInterval, "seconds" )
            .before( function() {
                if ( log.canDebug() ) {
                    log.debug( "Starting to fetch new features from unleash" );
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
    }

}