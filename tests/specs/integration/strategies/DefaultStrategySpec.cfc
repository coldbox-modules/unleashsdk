component extends="tests.resources.ModuleIntegrationSpec" {

    function beforeAll() {
        super.beforeAll();
        variables.strategy = getInstance( "DefaultStrategy@unleashsdk" );
    }

    function run() {
        describe( "DefaultStrategy", function() {
            it( "returns true for any params and context", function() {
                var result = variables.strategy.isEnabled( {}, getTestContext() );
                expect( result ).toBeTrue();
            } );
        } );
    }

    function getTestContext( struct overrides = {} ) {
        structAppend( arguments.overrides, {
            "appName": "unleashsdk-tests",
            "environment": "testing",
            "userId": "1",
            "sessionId": "1",
            "remoteAddress": CGI.REMOTE_ADDR
        }, false );
        return arguments.overrides;
    }

}