using inet 

class ButterRequest {

	static const Version http10 := Version("1.0")
	static const Version http11 := Version("1.1")
	
	** Uri to use for request. 
	** Must be absolute and contain a scheme such as `http://` 
	Uri				uri
	
	** HTTP version to use for request.
	** Defaults to Version("1.1")
	Version 		version	:= http11

	** HTTP method to use for request.
	** Defaults to "GET".
	Str 			method	:= "GET" { set { &method = it.upper } }

	// TODO: Lazy create??
	// TODO: Host
	** The HTTP headers to use for the next request.  This map uses
	** case insensitive keys.  The "Host" header is implicitly defined
	** by 'reqUri' and must not be defined in this map.
	Str:Str 		headers	:= Str:Str[:] { caseInsensitive = true }
	
	// TODO: move to Terminator?
	** Socket options for the TCP socket used for requests.
	SocketOptions?	options
	
	new make(|This|? f := null) {
		f?.call(this)
	}
}
