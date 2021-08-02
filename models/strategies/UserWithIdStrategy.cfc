component implements="IStrategy" singleton {

    public boolean function satisfiesConstraint(
        required string contextName,
        required string operator,
        required array values,
        required struct context
    ) {
        return true; // spike
    }

    public boolean function isEnabled(
        required struct parameters,
        required struct context
    ) {
        if ( !arguments.parameters.keyExists( "userIds" ) ) {
            return true;
        }
        return listContains( arguments.parameters.userIds, arguments.context.userId, ", " );
    }

}