component extends="tests.resources.ModuleIntegrationSpec" {

    property name="cache" inject="cachebox:default"

    function beforeAll() {
        super.beforeAll();
        variables.unleash = getInstance( "UnleashSDK@unleashsdk" );
    }

    function run() {
        describe( "UnleashSpec", function() {
            it( "returns the default value for an unknown feature", function() {
                expect( unleash.isEnabled( "bar" ) ).toBeFalse();
            } );

            it( "can check if a feature is enabled", function() {
                unleash.ensureFeatureExists(
                    name = "feature-1",
                    description = "A test feature flag that is enabled",
                    type = "release",
                    enabled = true,
                    strategies = [
                        {
                            "name": "default",
                            "parameters": {}
                        }
                    ]
                );

                unleash.ensureFeatureExists(
                    name = "feature-2",
                    description = "A test feature flag that is disabled",
                    type = "release",
                    enabled = false,
                    strategies = [
                        {
                            "name": "default",
                            "parameters": {}
                        }
                    ]
                );

                expect( unleash.isEnabled( "feature-1" ) ).toBeTrue();
                expect( unleash.isEnabled( "feature-2" ) ).toBeFalse();
            } );

            it( "can return all features", function() {
                unleash.ensureFeatureExists(
                    name = "feature-1",
                    description = "A test feature flag that is enabled",
                    type = "release",
                    enabled = true,
                    strategies = [
                        {
                            "name": "default",
                            "parameters": {}
                        }
                    ]
                );
                expect( unleash.getFeatures() ).toBeArray();
                expect( unleash.getFeatures() ).notToBeEmpty();
            } );

            it( "caches the features", function() {
                cache.clear( "unleashsdk-features" );
                var hyper = prepareMock( getInstance( "UnleashHyperClient@unleashsdk" ) );
                var newRequest = hyper.new();
                hyper.$( "new", newRequest );
                unleash.getFeatures();
                unleash.getFeatures();
                expect( hyper.$count( "new" ) ).toBe( 1, "The UnleashHyperClient should only be used once." );
            } );
        } );
    }

}