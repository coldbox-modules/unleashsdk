component {

	property name="javaInetAddress" inject="java:java.net.InetAddress";
	property name="environment"     inject="box:setting:environment@unleashsdk";
	property name="javaSystem"      inject="java:java.lang.System";

	public struct function getContext() {
		return {
			"appName"       : getApplicationName(),
			"environment"   : variables.environment,
			"userId"        : "",
			"sessionId"     : getSessionId(),
			"remoteAddress" : CGI.REMOTE_ADDR,
			"hostname"      : resolveHostname()
		};
	}

	private string function getApplicationName() {
		try {
			return getApplicationSettings().name;
		} catch ( any e ) {
			return "";
		}
	}

	private string function getSessionId() {
		try {
			return session.sessionid;
		} catch ( any e ) {
			return "";
		}
	}

	private string function resolveHostname() {
		var hostname = javaSystem.getProperty( "hostname" );
		if ( isNull( hostname ) ) {
			try {
				hostname = javaInetAddress.getLocalHost().getHostName();
			} catch ( UnknownHostException e ) {
				hostname = "undefined";
			}
		}
		return hostname;
	}

}
