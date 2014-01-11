using inet 

class ButterRequest {

	** HTTP 1.0
	static const Version http10 := Version("1.0")
	
	** HTTP 1.1
	static const Version http11 := Version("1.1")
	
	** Uri to use for request. 
	Uri				uri
	
	** HTTP version to use for request.
	** Defaults to Version("1.1")
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
	
	private Buf buf	:= Buf()
	
	InStream asInStream() {
		buf.flip.in
	}
	
	new make(|This|? f := null) {
		out = buf.out
		f?.call(this)
	}
}
