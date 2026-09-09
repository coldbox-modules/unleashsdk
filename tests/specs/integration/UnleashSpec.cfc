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
					name        = "feature-1",
					description = "A test feature flag that is enabled",
					type        = "release",
					enabled     = true,
					strategies  = [
						{
							"name"       : "default",
							"parameters" : {}
						}
					]
				);

				unleash.ensureFeatureExists(
					name        = "feature-2",
					description = "A test feature flag that is disabled",
					type        = "release",
					enabled     = false,
					strategies  = [
						{
							"name"       : "default",
							"parameters" : {}
						}
					]
				);

				unleash.refreshFeatures();
				expect( unleash.isEnabled( "feature-1" ) ).toBeTrue();
				expect( unleash.isEnabled( "feature-2" ) ).toBeFalse();
			} );

			it( "can check if a feature is disabled", function() {
				unleash.ensureFeatureExists(
					name        = "feature-1",
					description = "A test feature flag that is enabled",
					type        = "release",
					enabled     = true,
					strategies  = [
						{
							"name"       : "default",
							"parameters" : {}
						}
					]
				);

				unleash.ensureFeatureExists(
					name        = "feature-2",
					description = "A test feature flag that is disabled",
					type        = "release",
					enabled     = false,
					strategies  = [
						{
							"name"       : "default",
							"parameters" : {}
						}
					]
				);

				unleash.refreshFeatures();
				expect( unleash.isDisabled( "feature-1" ) ).toBeFalse();
				expect( unleash.isDisabled( "feature-2" ) ).toBeTrue();
			} );

			it( "can return all features", function() {
				unleash.ensureFeatureExists(
					name        = "feature-1",
					description = "A test feature flag that is enabled",
					type        = "release",
					enabled     = true,
					strategies  = [
						{
							"name"       : "default",
							"parameters" : {}
						}
					]
				);
				unleash.refreshFeatures();
				expect( unleash.getFeatures() ).toBeArray();
				expect( unleash.getFeatures() ).notToBeEmpty();
			} );

			it( "reads cached features without making HTTP requests", function() {
				var features = unleash.refreshFeatures();
				var originalClient = unleash.getClient();
				var unavailableClient = createStub().$( method = "get", callback = function() {
					throw( "Cached feature reads must not make HTTP requests." );
				} );
				unleash.setClient( unavailableClient );
				try {
					expect( unleash.getFeatures() ).toBe( features );
					expect( unleash.getFeatures() ).toBe( features );
				} finally {
					unleash.setClient( originalClient );
				}
			} );

			it( "stores refreshed features in the failover cache", function() {
				cache.clear( "unleashsdk-failover" );
				expect( unleash.getFeatures() ).toBeEmpty();
				var features = unleash.refreshFeatures();
				expect( features ).notToBeEmpty();
				expect( cache.get( "unleashsdk-failover" ) ).toBe( features );
			} );

			it( "keeps cached features when a refresh throws", function() {
				var features = unleash.refreshFeatures();
				var originalClient = unleash.getClient();
				var unavailableClient = createStub().$( method = "get", callback = function() {
					throw( type = "UnleashTest.Unavailable", message = "Test connection failure" );
				} );
				unleash.setClient( unavailableClient );
				try {
					expect( function() {
						unleash.refreshFeatures();
					} ).toThrow( "UnleashTest.Unavailable" );
					expect( unleash.getFeatures() ).toBe( features );
				} finally {
					unleash.setClient( originalClient );
				}
			} );
		} );
	}

}
