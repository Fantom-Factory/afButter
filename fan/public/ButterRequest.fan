using inet 

** The HTTP request.
class ButterRequest {

	** Uri to use for request. 
	Uri		uri

	** HTTP version to use for request.
	** Defaults to HTTP 1.1
	Version version	:= Butter.http11

	** HTTP method to use for request.
	** Defaults to "GET".
	Str 	method	:= "GET" { set { &method = it.upper } }

	** The HTTP headers to use for the next request.  
	** This map uses case insensitive keys.  
	HttpRequestHeaders	headers	:= HttpRequestHeaders()

	// TODO: rename to stash
	** A temporary store for request data, use to pass data between middleware.
	Str:Obj data	:= Str:Obj[:] { caseInsensitive = true }
	
	** The request body.
	Buf 	body	:= Buf()
	
	new make(Uri uri, |This|? f := null) {
		this.uri = uri
		f?.call(this)
	}
	
	override Str toStr() {
		"${method} ${uri} HTTP/${version}"
	}
}
