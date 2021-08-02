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
        return true;
    }

}