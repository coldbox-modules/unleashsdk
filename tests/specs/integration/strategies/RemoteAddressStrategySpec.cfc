component extends="tests.resources.ModuleIntegrationSpec" {

	function beforeAll() {
		super.beforeAll();
		variables.strategy = getInstance( "RemoteAddressStrategy@unleashsdk" );
	}

	function run() {
		describe( "RemoteAddressStrategy", function() {
			it( "returns true when matching a remote address", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "remoteAddress" : "1.1.1.1,2.2.2.2" },
					context    = getTestContext( { "remoteAddress" : "1.1.1.1" } )
				);
				expect( result ).toBeTrue();
			} );

			it( "returns false when not matching a remote address", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "remoteAddress" : "1.1.1.1,2.2.2.2" },
					context    = getTestContext( { "remoteAddress" : "3.3.3.3" } )
				);
				expect( result ).toBeFalse();
			} );

			it( "returns false when no remote address is in the context", function() {
				var result = variables.strategy.isEnabled(
					parameters = { "remoteAddress" : "1.1.1.1,2.2.2.2" },
					context    = getTestContext( { "remoteAddress" : "3.3.3.3" } )
				);
				expect( result ).toBeFalse();
			} );

			it( "returns true when no remote address is in the parameters", function() {
				var result = variables.strategy.isEnabled(
					parameters = {},
					context    = getTestContext( { "remoteAddress" : "3.3.3.3" } )
				);
				expect( result ).toBeTrue();
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
