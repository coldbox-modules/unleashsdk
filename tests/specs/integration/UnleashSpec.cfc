component extends="tests.resources.ModuleIntegrationSpec" {

    property name="cache" inject="cachebox:default";

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

            it( "can check if a feature is disabled", function() {
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

                expect( unleash.isDisabled( "feature-1" ) ).toBeFalse();
                expect( unleash.isDisabled( "feature-2" ) ).toBeTrue();
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

            it( "stores a failover cache", function() {
                cache.clear( "unleashsdk-features" );
                cache.clear( "unleashsdk-failover" );
                expect( cache.get( "unleashsdk-failover" ) ).toBeNull();
                var features = unleash.getFeatures();
                expect( cache.get( "unleashsdk-failover" ) ).notToBeNull().toBe( features );
            } );

            it( "uses the failover cache if there are any issues retrieving the features", function() {
                cache.clear( "unleashsdk-features" );
                cache.clear( "unleashsdk-failover" );
                unleash.getFeatures();
                var fallbackFeatures = cache.get( "unleashsdk-failover" );
                expect( fallbackFeatures ).notToBeNull();

                cache.clear( "unleashsdk-features" );
                var hyper = prepareMock( getInstance( "UnleashHyperClient@unleashsdk" ) );
                hyper.$( method = "new", callback = function() {
                    throw( "Something went wrong with the HTTP request to Unleash for the test!" );
                } );

                var features = unleash.getFeatures();
                expect( features ).toBe( fallbackFeatures );
            } );

            // this test currently doesn't work with CacheBox's default settings
            // because it only reaps the cache every 5 minutes
            // and it doesn't clear timed out items on a `get`.
            xit( "caches the features within a timeout", function() {
                cache.clear( "unleashsdk-features" );
                var hyper = prepareMock( getInstance( "UnleashHyperClient@unleashsdk" ) );
                var newRequest = hyper.new();
                hyper.$( "new", newRequest );
                unleash.getFeatures();
                unleash.getFeatures();
                sleep( 5 * 1000 ); // default timeout is 11 seconds
                unleash.getFeatures();
                expect( hyper.$count( "new" ) ).toBe( 2, "The UnleashHyperClient should be used twice." );
            } );
        } );
    }

}