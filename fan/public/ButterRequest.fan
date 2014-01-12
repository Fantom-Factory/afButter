using inet 

** Holds values to be used in making a HTTP request.
class ButterRequest {

	** A const value representing HTTP 1.0
	static const Version http10 := Version("1.0")

	** A const value representing HTTP 1.1
	static const Version http11 := Version("1.1")

	** Uri to use for request. 
	Uri				uri

	** HTTP version to use for request.
	** Defaults to HTTP 1.1
	Version 		version	:= http11

	** HTTP method to use for request.
	** Defaults to "GET".
	Str 			method	:= "GET" { set { &method = it.upper } }

	// TODO: set Host header
	** The HTTP headers to use for the next request.  
	** This map uses case insensitive keys.  
	** The "Host" header is implicitly defined by 'reqUri' and must not be defined in this map.
	HttpRequestHeaders	headers	:= HttpRequestHeaders(Str:Str[:] { caseInsensitive = true })
	
	OutStream out
	
	internal Buf buf	:= Buf()
	
	InStream asInStream() {
		buf.flip.in
	}
	
	new make(Uri uri, |This|? f := null) {
		this.uri = uri
		this.out = buf.out
		f?.call(this)
	}
}
