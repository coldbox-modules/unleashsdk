component {

    property name="environment" inject="coldbox:setting:environment";
    property name="event" inject="coldbox:requestContext";

    public struct function getContext() {
        return {
            "appName": getApplicationName(),
            "environment": variables.environment,
            "userId": "",
            "sessionId": getSessionId(),
            "remoteAddress": CGI.REMOTE_ADDR
        };
    }

    private string function getApplicationName() {
        try {
            return getApplicationSettings().name;
        } catch ( any e ) {
            return "";
        }
    }

    private function getSessionId() {
        try {
            return session.sessionid;
        } catch ( any e ) {
            return "";
        }
    }

}
