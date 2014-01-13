using inet 

// TODO: convert to mixin
** The HTTP request.
class ButterRequest {

	** A temporary store for request data, use to pass data between middleware.
	Str:Obj data	:= [:]
	
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
	
	OutStream out
	
	internal Buf buf	:= Buf()
	
	new make(Uri uri, |This|? f := null) {
		this.uri = uri
		this.out = buf.out
		f?.call(this)
	}

	InStream asInStream() {
		buf.flip.in
	}
	
	Void reset() {
		// FIXME:
	}
}
