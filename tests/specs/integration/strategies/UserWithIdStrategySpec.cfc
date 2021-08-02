component extends="tests.resources.ModuleIntegrationSpec" {

    property name="cache" inject="cachebox:default";

    function beforeAll() {
        super.beforeAll();
        variables.unleash = getInstance( "UnleashSDK@unleashsdk" );
        variables.strategy = getInstance( "UserWithIdStrategy@unleashsdk" );
    }

    function run() {
        describe( "UserWithIdStrategy", function() {
            it( "returns true for valid user ids", function() {
                var params = { "userIds": "123, 456" };
                var context = getTestContext( { "userId": "456" } );
                var result = variables.strategy.isEnabled( params, context );
                expect( result ).toBeTrue();
            } );

            it( "returns false for invalid user ids", function() {
                var params = { "userIds": "123,456" };
                var context = getTestContext( { "userId": "789" } );
                var result = variables.strategy.isEnabled( params, context );
                expect( result ).toBeFalse();
            } );

            it( "returns false for no user id in context", function() {
                var params = { "userIds": "123,456" };
                var context = getTestContext( { "userId": "" } );
                var result = variables.strategy.isEnabled( params, context );
                expect( result ).toBeFalse();
            } );

            it( "returns true for no user id in params", function() {
                var params = {};
                var context = getTestContext( { "userId": "456" } );
                var result = variables.strategy.isEnabled( params, context );
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