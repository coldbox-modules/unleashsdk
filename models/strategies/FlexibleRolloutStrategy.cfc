component implements="IStrategy" singleton {

    property name="murmur3" inject="java:com.sangupta.murmur.Murmur3";

    public boolean function isEnabled(
        required struct parameters,
        required struct context
    ) {
        param arguments.parameters.stickiness = "default";
        var stickinessId = resolveStickiness( arguments.parameters.stickiness, arguments.context );
        if ( !len( stickinessId ) ) {
            return false;
        }
        param arguments.parameters.rollout = 100;
        var percentage = getPercentage( arguments.parameters.rollout );
        param arguments.parameters.groupId = "";
        var norm = getNormalizedNumber( stickinessId, arguments.parameters.groupId )
        return norm <= percentage;
    }

    private string function resolveStickiness( required string stickinessKey, required struct context ) {
        switch ( arguments.stickinessKey ) {
            case "userId":
                return arguments.context.userId;
            case "sessionId":
                return arguments.context.sessionId
            case "random":
                return randRange( 1, 100 );
            case "default":
            default:
                if ( arguments.context.keyExists( "userId" ) && len( arguments.context.userId ) ) {
                    return arguments.context.userId;
                }
                if ( arguments.context.keyExists( "sessionId" ) && len( arguments.context.sessionId ) ) {
                    return arguments.context.sessionId;
                }
                return randRange( 1, 100 );
        }
    }

    /**
     * Takes a numeric string value and converts it to a integer between 0 and 100.
     *
     * returns 0 if the string is not numeric.
     *
     * @param percentage - A numeric string value
     * @return a integer between 0 and 100
     */
    private numeric function getPercentage( required any percentage ) {
        return clamp( 0, isNumeric( arguments.percentage ) ? arguments.percentage : 0, 100 );
    }

    private numeric function clamp( required numeric low, required numeric actual, required numeric high ) {
        if ( arguments.actual < arguments.low ) {
            return arguments.low;
        }
        if ( arguments.actual > arguments.high ) {
            return arguments.high;
        }
        return arguments.actual;
    }

    private numeric function getNormalizedNumber( required string identifier, required string groupId, numeric normalizer = 100 ) {
        var value = getStringBytes( "#arguments.groupId#:#arguments.identifier#" );
        var hash = calculateHash( value );
        return normalizeHash( hash, normalizer );
    }

    private array function getStringBytes( required string identifier ) {
        return createObject( "java", "java.lang.String" ).init( arguments.identifier ).getBytes();
    }

    private any function calculateHash( required array bytes ) {
        var hash = variables.murmur3.hash_x86_32( arguments.bytes, len( arguments.bytes ), 0 );
        return createObject( "java", "java.math.BigInteger" ).valueOf( hash );
    }

    private numeric function normalizeHash( required any hash, required numeric normalizer ) {
        var normalizerBigInt = createObject( "java", "java.math.BigInteger" ).init( normalizer )
        return arguments.hash.remainder( normalizerBigInt ) + 1;
    }

}