component implements="IStrategy" singleton {

	public boolean function isEnabled( required struct parameters, required struct context ) {
		if ( !arguments.parameters.keyExists( "userIds" ) ) {
			return true;
		}
		return listContains(
			arguments.parameters.userIds,
			arguments.context.userId,
			", "
		);
	}

}
