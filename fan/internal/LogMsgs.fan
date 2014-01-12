
internal const class LogMsgs {
	
	static Str redirectGivenWithNoLocation(Int statusCode) {
		"Response indicates a redirect (status code ${statusCode}) but no 'Location' header was given"
	}

}
