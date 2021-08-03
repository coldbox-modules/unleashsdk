component extends="tests.resources.ModuleIntegrationSpec" {

    property name="cache" inject="cachebox:default";

    function beforeAll() {
        super.beforeAll();
        variables.strategy = getInstance( "FlexibleRolloutStrategy@unleashsdk" );
    }

    function run() {
        describe( "FlexibleRolloutStrategy", function() {
            it( "always is enabled for 100 percent rollouts", function() {
                var result = variables.strategy.isEnabled(
                    parameters = {
                        "rollout": "100",
                        "stickiness": "default",
                        "groupId": "Feature.flexibleRollout.100"
                    },
                    context = {}
                );
                expect( result ).toBeTrue();
            } );

            it( "never is enabled for 0 percent rollouts", function() {
                var result = variables.strategy.isEnabled(
                    parameters = {
                        "rollout": "0",
                        "stickiness": "default",
                        "groupId": "Feature.flexibleRollout.0"
                    },
                    context = {
                        "sessionId": "147",
                        "userId": "12"
                    }
                );
                expect( result ).toBeFalse();
            } );

            it( "should be enabled for userId=174 in rollout of 10", function() {
                var result = variables.strategy.isEnabled(
                    parameters = {
                        "rollout": "10",
                        "stickiness": "default",
                        "groupId": "Feature.flexibleRollout.10"
                    },
                    context = getTestContext( {
                        "userId": "174"
                    } )
                );
                expect( result ).toBeTrue();
            } );

            it( "should be disabled for userId=499 in rollout of 10", function() {
                var result = variables.strategy.isEnabled(
                    parameters = {
                        "rollout": "10",
                        "stickiness": "default",
                        "groupId": "Feature.flexibleRollout.10"
                    },
                    context = getTestContext( {
                        "userId": "499"
                    } )
                );
                expect( result ).toBeFalse();
            } );

            it( "should be disabled for sessionId=25 for a userId specific version", function() {
                var result = variables.strategy.isEnabled(
                    parameters = {
                        "rollout": "55",
                        "stickiness": "userId",
                        "groupId": "Feature.flexibleRollout.userId.55"
                    },
                    context = getTestContext( {
                        "sessionId": "25"
                    } )
                );
                expect( result ).toBeFalse();
            } );
        } );
    }

    function getTestContext( struct overrides = {} ) {
        structAppend( arguments.overrides, {
            "appName": "unleashsdk-tests",
            "environment": "testing",
            "userId": "",
            "sessionId": "",
            "remoteAddress": CGI.REMOTE_ADDR
        }, false );
        return arguments.overrides;
    }

}