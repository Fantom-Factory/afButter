using inet 

class ButterReq {
	Uri				uri
	Version 		version	:= Version("1.1")
	Str 			method	:= "GET"
	Str:Str 		headers	:= Str:Str[:] { caseInsensitive = true }
	SocketOptions?	options
	
	new make(|This|? f := null) {
		f?.call(this)
	}

	new makeFromUri(Uri uri, Str method := "GET") {
		this.uri = uri
		this.method = method
	}
}
