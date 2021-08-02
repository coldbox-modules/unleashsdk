component implements="IStrategy" singleton {

    public boolean function satisfiesConstraints( array constraints, struct context ) {
        return true; // spike
    }

    public boolean function isEnabled( struct parameters, struct context ) {
        if ( !arguments.parameters.keyExists( "userIds" ) ) {
            return true;
        }
        return listContains( arguments.parameters.userIds, arguments.context.userId, ", " );
    }

}