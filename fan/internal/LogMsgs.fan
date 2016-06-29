
internal const class LogMsgs {
	
	static Str redirectGivenWithNoLocation(Int statusCode) {
		"Response indicates a redirect (status code ${statusCode}) but no 'Location' header was given"
	}

	static Str httpTerminator_proxyNotUri(Obj proxy) {
		"Proxy object is not a Uri - ${proxy.typeof.qname}:${proxy}"
	}

}
