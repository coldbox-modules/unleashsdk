component implements="IStrategy" singleton {

    public boolean function isEnabled(
        required struct parameters,
        required struct context
    ) {
        return true;
    }

}