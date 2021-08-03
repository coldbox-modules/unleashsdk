component extends="tests.resources.ModuleIntegrationSpec" {

	function beforeAll() {
		super.beforeAll();
		variables.strategy = getInstance( "ApplicationHostnameStrategy@unleashsdk" );
	}

	function run() {
		describe( "ApplicationHostnameStrategy", function() {
			it( "returns true when matching a hostname", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "hostNames" : "example.com,hostname.com" },
					context    = getTestContext( { "hostname" : "example.com" } )
				);
				expect( result ).toBeTrue();
			} );

			it( "returns false when not matching a hostname", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "hostNames" : "example.com,hostname.com" },
					context    = getTestContext( { "hostname" : "google.com" } )
				);
				expect( result ).toBeFalse();
			} );

			it( "returns false when no hostname is in the context", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "hostNames" : "example.com,hostname.com" },
					context    = getTestContext( { "hostname" : "google.com" } )
				);
				expect( result ).toBeFalse();
			} );
		} );
	}

	function getTestContext( struct overrides = {} ) {
		structAppend(
			arguments.overrides,
			{
				"appName"       : "unleashsdk-tests",
				"environment"   : "testing",
				"userId"        : "1",
				"sessionId"     : "1",
				"remoteAddress" : CGI.REMOTE_ADDR
			},
			false
		);
		return arguments.overrides;
	}

}
