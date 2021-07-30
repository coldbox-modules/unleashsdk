component singleton accessors="true" {

    property name="client" inject="UnleashHyperClient@unleashsdk";

    public boolean function isEnabled( required string name, boolean defaultValue = false ) {
        var feature = findFeature( arguments.name );
        if ( isNull( feature ) ) {
            return arguments.defaultValue;
        }

        if ( !feature.enabled ) {
            return false;
        }

        return true;
    }

    public struct function createFeature(
        required string name,
        required string description,
        string type = "release",
        boolean enabled = true,
        array strategies = []
    ) {
        return variables.client
            .throwErrors()
            .post( "/admin/features", {
                "name": arguments.name,
                "description": arguments.description,
                "type": arguments.type,
                "enabled": arguments.enabled,
                "strategies": arguments.strategies
            } )
            .json();
    }

    public struct function ensureFeatureExists(
        required string name,
        required string description,
        string type = "release",
        boolean enabled = true,
        array strategies = []
    ) {
        var feature = findFeature( arguments.name );
        if ( !isNull( feature ) ) {
            return feature;
        }
        return createFeature( argumentCollection = arguments );
    }

    private any function findFeature( required string name ) {
        return arrayFindFirst( fetchFeatures(), function( feature ) {
            return feature.name == name;
        } );
    }

    private array function fetchFeatures() {
        return variables.client.get( "/client/features" ).json().features;
    }

    private any function arrayFindFirst( required array items, required function predicate ) {
        for ( var item in arguments.items ) {
            if ( arguments.predicate( item ) ) {
                return item;
            }
        }
        return javacast( "null", "" );
    }
    
}