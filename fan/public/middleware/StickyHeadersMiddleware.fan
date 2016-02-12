
** (Middleware) - Automatically sets headers in each request, so you don't have to!
** 
** Only non-existing header values are set, leaving any existing values untouched. This means you can use sticky 
** headers to set default values and manually override them for individual requests.
class StickyHeadersMiddleware : ButterMiddleware {

	** The header values set in every request 
	HttpRequestHeaders headers	:= HttpRequestHeaders()
	
	@NoDoc @Deprecated { msg="Use 'headers' instead" }
	HttpRequestHeaders stickyHeaders()	{ headers }
	
	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {		
		headers.map.each |val, key| {
			if (!req.headers.containsKey(key))
				req.headers[key] = val
		}
		
		return butter.sendRequest(req)
	}
	
	** Getter for sticky header values.
	@Operator
	Str? get(Str key) {
		headers[key]
	}

	** Setter for sticky header values.
	** Setting a 'null' value removes the value from the map.
	@Operator
	Void set(Str key, Str? val) {
		headers[key] = val
	}
}
