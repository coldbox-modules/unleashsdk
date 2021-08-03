component implements="IStrategy" singleton {

    public boolean function isEnabled(
        required struct parameters,
        required struct context
    ) {
        if ( !arguments.parameters.keyExists( "remoteAddress" ) ) {
            return true;
        }
        return listContains( arguments.parameters.remoteAddress, arguments.context.remoteAddress, ", " );
    }

}