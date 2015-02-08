using web::WebUtil
using util::JsonInStream

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

	** Creates a response reading real HTTP values from an 'InStream'.
	** The whole response body is read in. 
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

			// ChunkInStream throws NullErr if the response has no body, e.g. HEAD requests
			// see http://fantom.org/sidewalk/topic/2365
			// I could check the Content-Length header, but why should I trust it!?
			instream	:= WebUtil.makeContentInStream(headers.map, in)
			try 	body = instream.readAllBuf
			catch	body = Buf()
			instream.close
		}
		catch (IOErr e) throw e 
		catch (Err err) throw IOErr("Invalid HTTP response: $res", err)
	}

	** Create a response from a 'Str' body.
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
	** This method closes the response stream. 
	Buf asBuf() {
		body.seek(0)
	}

	** Returns the body as an 'InStream'.
	InStream asInStream() {
		body.seek(0).in
	}

	** Returns the response stream as a JSON object. 
	** The response stream is read as a string and converted to Fantom using `util::JsonInStream`.
	Obj asJson() {
		JsonInStream(asInStream).readJson
	}
	
	** Returns the response stream as a JSON map. Exactly the same as 'asJson()' but casts the result to a map.  
	** 
	** Convenience for '(Str:Obj) butterResponse.asJson()' 
	Str:Obj asJsonMap() {
		asJson
	}
	
	@NoDoc
	override Str toStr() {
		"$statusCode - $statusMsg"
	}
}
