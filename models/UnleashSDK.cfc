component singleton accessors="true" {

    property name="client" inject="UnleashHyperClient@unleashsdk";
    property name="cache" inject="cachebox:default";
    property name="log" inject="logbox:logger:{this}";

    variables.strategies = {
        "default": "DefaultStrategy",
        "userWithId": "UserWithIdStrategy",
        "flexibleRollout": "FlexibleRolloutStrategy",
        "remoteAddress": "RemoteAddressStrategy",
        "applicationHostname": "ApplicationHostnameStrategy"
    };

    public boolean function isEnabled( required string name, boolean defaultValue = false ) {
        var feature = findFeature( arguments.name );
        if ( isNull( feature ) ) {
            return arguments.defaultValue;
        }

        if ( !feature.enabled ) {
            return false;
        }

        for ( var strategyData in feature.strategies ) {
            var strategy = getStrategy( strategyData.name );
            if ( isNull( strategy ) ) {
                return false;
            }

            param strategyData.constraints = [];
            if ( !strategy.satisfiesConstraints( strategyData.constraints ) ) {
                continue;    
            }
            
            param strategyData.parameters = {};
            if ( !strategy.isEnabled( strategyData.parameters ) ) {
                return false;
            }
        }

        return true;
    }

    private any function getStrategy( required string name ) {
        if ( !variables.strategies.keyExists( arguments.name ) ) {
            log.warn( "No Unleash strategy found for [#arguments.name#]" );
            return javacast( "null", "" );
        }

        if ( isSimpleValue( variables.strategies[ arguments.name ] ) ) {
            variables.strategies[ arguments.name ] = new "unleashsdk.models.strategies.#variables.strategies[ arguments.name ]#"();
        }

        return variables.strategies[ arguments.name ];
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

    public array function getFeatures() {
        return cache.getOrSet( "unleashsdk-features", function() {
            return fetchFeatures();
        }, createTimespan( 0, 0, 10, 0 ) );
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