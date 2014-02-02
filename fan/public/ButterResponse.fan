using web::WebUtil

** The HTTP response.
class ButterResponse {

	** The HTTP status code.
	Int statusCode

	** The HTTP status message.
	Str statusMsg

	** The HTTP repsonse headers.
	HttpResponseHeaders headers

	** HTTP version of the response.
	Version version	:= Butter.http11

	** The request body. 
	Buf body
	
	** A temporary store for request data, use to pass data between middleware.
	Str:Obj data	:= [:]
	
	** it-block ctor.
	new make(|This| in) {
		in(this)
	}

	** Create a response from an 'InStream'.
	new makeFromInStream(InStream in) {
		res := Str.defVal
		try {
			resVer	:= (Version?) null
			res 	= in.readLine
			if 		(res.startsWith("HTTP/1.0")) resVer = Butter.http10
			else if (res.startsWith("HTTP/1.1")) resVer = Butter.http11
			else throw IOErr("Unknown HTTP version: ${res}")

			statusCode 	= res[9..11].toInt
			statusMsg 	= res[13..-1]
			headers		= HttpResponseHeaders(WebUtil.parseHeaders(in))
			body 		= WebUtil.makeContentInStream(headers.map, in).readAllBuf
		}
		catch (IOErr e) throw e 
		catch (Err err) throw IOErr("Invalid HTTP response: $res", err)
	}

	new makeFromStr(Int statusCode, Str statusMsg, Str:Str headers, Str body, |This|? f := null) {
		this.statusCode = statusCode
		this.statusMsg 	= statusMsg
		this.headers	= HttpResponseHeaders(headers)
		this.body 		= Buf() { charset = this.headers.contentType?.charset ?: Charset.utf8 }.writeChars(body).flip
		f?.call(this)		
	}

	** Reads the response stream and converts it to a 'Str' using the charset defined in the 'Content-Type' header.
	** 
	** This method closes the response stream. 
	Str asStr() {
		body.seek(0).charset = headers.contentType?.charset ?: Charset.utf8
		return body.readAllStr
	}

	** Return the response stream as a 'Buf'.
	** 
	** Convenience for `in.readAllBuf`.  
	** This method closes the response stream. 
	Buf asBuf() {
		body.seek(0)
	}

	** Returns the response stream.
	InStream asInStream() {
		body.seek(0).in
	}
	
	override Str toStr() {
		"$statusCode - $statusMsg"
	}
}
