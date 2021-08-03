component extends="tests.resources.ModuleIntegrationSpec" {

	property name="cache" inject="cachebox:default";

	function beforeAll() {
		super.beforeAll();
	}

	function run() {
		describe( "Constraints", function() {
			it( "can skip strategies based on constraints", function() {
				var unleash = prepareMock( getInstance( "UnleashSDK@unleashsdk" ) );
				unleash.$(
					"getContext",
					{
						"appName"       : "unleashsdk-tests",
						"environment"   : "testing",
						"userId"        : "1",
						"sessionId"     : "1",
						"remoteAddress" : CGI.REMOTE_ADDR
					}
				);
				unleash.$(
					"getFeature",
					{
						"stale"      : false,
						"variants"   : "",
						"enabled"    : true,
						"type"       : "release",
						"name"       : "feature-1",
						"strategies" : [
							{
								"name"        : "default",
								"parameters"  : {},
								"constraints" : [
									{
										"contextName" : "environment",
										"operator"    : "IN",
										"values"      : [ "dev", "testing" ]
									},
									{
										"contextName" : "appName",
										"operator"    : "NOT_IN",
										"values"      : [ "unleashsdk-tests" ]
									}
								]
							},
							{
								"name"       : "userWithId",
								"parameters" : { "userIds" : "2,3,4" }
							}
						]
					}
				);
				expect( unleash.isEnabled( "feature-1" ) ).toBeFalse();
				// unleash.$( "getContext", {
				//     "appName": "unleashsdk-not-tests",
				//     "environment": "testing",
				//     "userId": "1",
				//     "sessionId": "1",
				//     "remoteAddress": CGI.REMOTE_ADDR
				// } );
				// expect( unleash.isEnabled( "feature-1" ) ).toBeTrue();
			} );

			it( "all strategies that pass constraints must be enabled for the feature to be enabled", function() {
				var unleash = prepareMock( getInstance( "UnleashSDK@unleashsdk" ) );
				unleash.$(
					"getContext",
					{
						"appName"       : "unleashsdk-not-tests",
						"environment"   : "testing",
						"userId"        : "1",
						"sessionId"     : "1",
						"remoteAddress" : CGI.REMOTE_ADDR
					}
				);
				unleash.$(
					"getFeature",
					{
						"stale"      : false,
						"variants"   : "",
						"enabled"    : true,
						"type"       : "release",
						"name"       : "feature-1",
						"strategies" : [
							{
								"name"        : "default",
								"parameters"  : {},
								"constraints" : [
									{
										"contextName" : "environment",
										"operator"    : "IN",
										"values"      : [ "dev", "testing" ]
									},
									{
										"contextName" : "appName",
										"operator"    : "NOT_IN",
										"values"      : [ "unleashsdk-tests" ]
									}
								]
							},
							{
								"name"       : "userWithId",
								"parameters" : { "userIds" : "1,2,3,4" }
							}
						]
					}
				);
				expect( unleash.isEnabled( "feature-1" ) ).toBeTrue();
			} );
		} );
	}

}
