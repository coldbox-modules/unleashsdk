component implements="IStrategy" singleton {

    public boolean function isEnabled(
        required struct parameters,
        required struct context
    ) {
        if ( !arguments.parameters.keyExists( "hostNames" ) ) {
            return true;
        }
        return listContains( arguments.parameters.hostNames, arguments.context.hostname, ", " );
    }

}