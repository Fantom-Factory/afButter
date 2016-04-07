using web::WebUtil
using util::JsonInStream

** The HTTP response.
class ButterResponse {

	** The HTTP status code.
	Int statusCode

	** The HTTP status message.
	Str statusMsg

	** The HTTP repsonse headers.
	HttpResponseHeaders headers { private set }

	** HTTP version of the response.
	Version version	:= Butter.http11

	** The request body. 
	Body	body { private set }
	
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
			instream := WebUtil.makeContentInStream(headers.map, in)
			
			body = Body(headers, instream)
		}
		catch (IOErr e) throw e 
		catch (Err err) throw IOErr("Invalid HTTP response: $res", err)
	}

	** Create a response from a 'Str' body.
	new makeFromStr(Int statusCode, Str statusMsg, HttpResponseHeaders headers, Str? body, |This|? f := null) {
		this.statusCode = statusCode
		this.statusMsg 	= statusMsg
		this.headers	= headers
		this.body 		= Body(this.headers, body)
		f?.call(this)		
	}
	** Create a response from a 'Buf' body.
	new makeFromBuf(Int statusCode, Str statusMsg, HttpResponseHeaders headers, Buf? body, |This|? f := null) {
		this.statusCode = statusCode
		this.statusMsg 	= statusMsg
		this.headers	= headers
		this.body 		= Body(this.headers, body)
 		f?.call(this)		
	}

	@NoDoc @Deprecated { msg="Use 'body.makeFromStr' instead" } 
	new makeFromStrOld(Int statusCode, Str statusMsg, Str:Str headers, Str? body, |This|? f := null) {
		this.statusCode = statusCode
		this.statusMsg 	= statusMsg
		this.headers	= HttpResponseHeaders(headers)
		this.body 		= Body(this.headers, body)
		f?.call(this)		
	}

	** Dumps a debug string that in some way resembles the full HTTP response.
	Str dump() {
		buf := StrBuf()
		out := buf.out

		out.print("HTTP/${version} ${statusCode} ${statusMsg}\n")
		headers.each |v, k| { out.print("${k}: ${v}\n") }
		out.print("\n")

		if (body.buf != null && body.buf.size > 0) {
			try	  out.print(body.str)
			catch out.print("** ERROR: Body does not contain string content **")
		}

		return buf.toStr
	}
	
	@NoDoc @Deprecated { msg="Use 'body.str' instead" } 
	Str? asStr() {
		body.str
	}

	@NoDoc @Deprecated { msg="Use 'body.buf' instead" } 
	Buf? asBuf() {
		body.buf
	}

	@NoDoc @Deprecated { msg="Use 'body.buf.seek(0).in' instead" } 
	InStream? asInStream() {
		body.buf?.seek(0)?.in
	}

	@NoDoc @Deprecated { msg="Use 'body.jsonObj' instead" } 
	Obj? asJson() {
		body.jsonObj
	}
	
	@NoDoc @Deprecated { msg="Use 'body.jsonMap' instead" } 
	[Str:Obj?]? asJsonMap() {
		body.jsonMap
	}
	
	@NoDoc
	override Str toStr() {
		"$statusCode - $statusMsg"
	}
}
