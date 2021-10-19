component {

    this.name = "ColdBoxTestingSuite" & hash(getCurrentTemplatePath());
    this.sessionManagement  = true;
    this.setClientCookies   = true;
    this.sessionTimeout     = createTimeSpan( 0, 0, 15, 0 );
    this.applicationTimeout = createTimeSpan( 0, 0, 15, 0 );
    this.bufferoutput = true;

    testsPath = getDirectoryFromPath( getCurrentTemplatePath() );
    this.mappings[ "/tests" ] = testsPath;
    rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
    this.mappings[ "/root" ] = rootPath;
    this.mappings[ "/unleashsdk" ] = rootPath;
    this.mappings[ "/testingModuleRoot" ] = "/app";
    this.mappings[ "/app" ] = testsPath & "resources/sample_app";
    this.mappings[ "/coldbox" ] = testsPath & "resources/sample_app/coldbox";
    this.mappings[ "/testbox" ] = rootPath & "/testbox";

    this.javaSettings = {
		loadPaths = [
            expandPath( "../lib" )
        ],
		loadColdFusionClassPath = true,
		reloadOnChange = false
	};

    function onRequestStart() {
        systemOutput( "Starting request" );
        setting requestTimeout="180";
        structDelete( application, "cbController" );
        structDelete( application, "wirebox" );
        fetchAndSetAPIToken();
    }

    function fetchAndSetAPIToken() {
        logInToUnleash();
        var token = fetchAPIToken();
        getJavaSystem().setProperty( "UNLEASH_API_TOKEN", token );
    }

    function logInToUnleash() {
        var apiURL = createObject( "java", "java.net.URL" ).init( getSystemSetting( "UNLEASH_API_URL" ) );
        var unleashURL = "#apiURL.getProtocol()#://#apiURL.getHost()#:#apiURL.getPort()#";
        structDelete( cookie, "unleash-session" );
        cfhttp( result="local.res", method="POST", url="#unleashURL#/auth/simple/login", throwonerror="true" ) {
            cfhttpparam( type="header", name="Content-Type", value="application/json" );
            cfhttpparam( type="body", value="#serializeJSON({
                "username": "admin",
                "password": "unleash4all"
            })#" );
        }
        var authCookie = local.res.Responseheader[ "Set-Cookie" ];
        if ( isArray( authCookie ) ) {
            authCookie = authCookie[ 1 ];
        }
        authCookie = listFirst( authCookie, ";" );
        cookie[ "unleash-session" ] = listRest( urlDecode( authCookie ), "=" );
    }

    function fetchAPIToken() {
        var tokens = fetchAllAPITokens();
        if ( !tokens.isEmpty() ) {
            return tokens[ 1 ];
        }
        return createNewAPIToken();
    }

    function fetchAllAPITokens() {
        cfhttp( result="local.res", method="GET", url="#getSystemSetting( "UNLEASH_API_URL" )#/admin/api-tokens", throwonerror="true" ) {
            cfhttpparam( type="header", name="Content-Type", value="application/json" );
            cfhttpparam( type="cookie", name="unleash-session", value = cookie[ "unleash-session" ] );
        }
        return deserializeJSON( local.res.filecontent ).tokens
            .filter( function( token ) {
                return token.type == "admin";
            } )
            .map( function( token ) {
                return token.secret;
            } );
    }

    function createNewAPIToken() {
        cfhttp( result="local.res", method="POST", url="#getSystemSetting( "UNLEASH_API_URL" )#/admin/api-tokens", throwonerror="true" ) {
            cfhttpparam( type="header", name="Content-Type", value="application/json" );
            cfhttpparam( type="cookie", name="unleash-session", value = cookie[ "unleash-session" ] );
            cfhttpparam( type="body", value="#serializeJSON({
                "username": "unleashsdk-#createUUID()#",
                "type": "ADMIN"
            })#" );
        }
        return deserializeJSON( local.res.filecontent ).secret;
    }

    function getSystemSetting( required string name, any defaultValue ) {
        var envValue = getJavaSystem().getEnv( arguments.name );
        if ( !isNull( envValue ) ) {
            return envValue;
        }
        var propertyValue = getJavaSystem().getProperty( arguments.name );
        if ( !isNull( propertyValue ) ) {
            return propertyValue;
        }
        if ( !isNull( arguments.defaultValue ) ) {
            return arguments.defaultValue;
        }
        throw( "No env var or system property name [#arguments.name#]" );
    }

    function getJavaSystem() {
        if ( !structKeyExists( variables, "system" ) ) {
            variables.system = createObject( "java", "java.lang.System" );
        }
        return variables.system;
    }

}
