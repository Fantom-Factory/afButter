using inet 

class ButterReq {
	Uri				uri
	Version 		version	:= Version("1.1")
	Str 			method	:= "GET"
	Str:Str 		headers	:= Str:Str[:] { caseInsensitive = true }
	SocketOptions?	options
	
	new make(Uri uri) {
		this.uri = uri
	}
}
