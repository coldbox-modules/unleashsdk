component implements="IStrategy" singleton {

    public boolean function satisfiesConstraints( array constraints, struct context ) {
        return true; // spike
    }

    public boolean function isEnabled( struct parameters, struct context ) {
        return true;
    }

}