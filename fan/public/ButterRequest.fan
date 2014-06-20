using inet 

** The HTTP request.
class ButterRequest {

	** Url to use for request. 
	Uri		url

	** HTTP version to use for request.
	** Defaults to HTTP 1.1
	Version version	:= Butter.http11

	** HTTP method to use for request.
	** Defaults to "GET".
	Str 	method	:= "GET" { set { &method = it.upper } }

	** The HTTP headers to use for the next request.  
	** This map uses case insensitive keys.  
	HttpRequestHeaders	headers	:= HttpRequestHeaders()

	** A temporary store for request data, use to pass data between middleware.
	Str:Obj stash	:= Str:Obj[:] { caseInsensitive = true }
	
	** The request body.
	Buf 	body	:= Buf()
	
	new make(Uri url, |This|? f := null) {
		this.url = url
		f?.call(this)
	}
	
	override Str toStr() {
		"${method} ${url} HTTP/${version}"
	}
}
