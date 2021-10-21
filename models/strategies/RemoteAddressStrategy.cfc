component implements="IStrategy" singleton {

	public boolean function isEnabled( required struct parameters, required struct context ) {
		if ( !arguments.parameters.keyExists( "remoteAddress" ) ) {
			return true;
		}

		var parameterAddresses = arraySlice( arguments.parameters.remoteAddress.split( ",\s*" ), 1 );
		var contextAddresses = arraySlice( arguments.context.remoteAddress.split( ",\s*" ), 1 );
		contextAddresses.retainAll( parameterAddresses );
		return !contextAddresses.isEmpty();
	}

}
