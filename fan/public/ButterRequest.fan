using util::JsonOutStream

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
	HttpRequestHeaders	headers	:= HttpRequestHeaders() { private set }	// 'cos it's required by body

	** A temporary store for request data, use to pass data between middleware.
	Str:Obj? stash	:= Str:Obj?[:] { caseInsensitive = true }
	
	** The request body.
	Body	body	:= Body(headers)
	
	new make(Uri url, |This|? f := null) {
		this.url = url
		f?.call(this)
	}
	
	** Builder method for setting the HTTP method.
	This setMethod(Str method) {
		this.method = method 
		return this
	}

	** Builder method for setting a header value.
	This setHeader(Str name, Str? value) {
		headers.set(name, value)
		return this
	}
	
	** Writes a Multipart Form to the body. Use to simulate file uploads.
	** 
	** pre>
	** syntax:fantom
	** request.writeMultipartForm |MultipartForm form| {
	**     form.writeJsonObj("meta", ["desc":"Awesome!"])
	**     form.writeFile("upload", `newGame.pod`.toFile)
	** }
	** <pre
	This writeMultipartForm(|MultipartForm| formFunc) {
		form := MultipartForm(this)
		form.start
		formFunc(form)
		form.finish
		return this
	}

	** Dumps a debug string that in some way resembles the full HTTP request.
	Str dump() {
		buf := StrBuf()
		out := buf.out

		out.print("${method} ${url.encode} HTTP/${version}\n")
		headers.each |v, k| { out.print("${k}: ${v}\n") }
		out.print("\n")

		if (body.buf != null) {
			try	  out.print(body.str)
			catch out.print("** ERROR: Body does not contain string content **")
		}

		return buf.toStr
	}
	
	internal Void _primeForSend() {
		// set the Host, if it's not been already
		// Host is mandatory for HTTP/1.1, and does no harm in HTTP/1.0
		if (headers.host == null)
			headers.host = _normaliseHost(url)

		// set the Content-Length, if it's not been already
		bufSize := body.size
		if (headers.contentLength == null)
			if (method == "GET" && bufSize == 0)
				null?.toStr // don't bother setting Content-Length for GET reqs with an empty body, Firefox v32 doesn't
			else
				headers.contentLength = bufSize
	}

	** Returns a normalised host string from a URL.
	internal static Str _normaliseHost(Uri url) {
		uri  := (url.host == null) ? `//$url` : url
		host := uri.host 
		if (host == null || host.isEmpty)
			throw ArgErr(ErrMsgs.hostNotDefined(url))
		isHttps := url.scheme == "https"
		defPort := isHttps ? 443 : 80
		if (uri.port != null && uri.port != defPort)
			host += ":${uri.port}"
		return host
	}
	
	@NoDoc @Deprecated { msg="Use 'body.set' instead" }  
	This setBodyFromStr(Str str) {
		body.str = str
		return this
	}
	
	@NoDoc @Deprecated { msg="Use 'body.set' instead" }  
	This setBodyFromJson(Obj jsonObj) {
		body.jsonObj = jsonObj
		return this
	}
	
	@NoDoc
	override Str toStr() {
		"${method} ${url} HTTP/${version}"
	}
}

** Represents Multipart Form Data as defined by [RFC 2388]`https://www.ietf.org/rfc/rfc2388.txt`.
** Used to write data to a request.
class MultipartForm {
	private ButterRequest	req
	private OutStream		out
	private Str				boundary

	internal new make(ButterRequest req) {
		this.req		= req
		this.out		= req.body.buf.out
		this.boundary	= "Boundary-" + Buf.random(16).toHex
		req.headers.contentType = MimeType("multipart/form-data; boundary=$boundary")
	}

	internal Void start() {
		out.print("--").print(boundary).print("\r\n")
	}

	** Writes a part.
	This write(Str name, Buf content, MimeType? contentType) {
		out.print("Content-Disposition: form-data; name=\"${quote(name)}\"\r\n")
		if (contentType != null)
			out.print("Content-Type: ${contentType}\r\n")
		out.print("\r\n")
		out.print(content)
		out.print("\r\n")		
		return this
	}

	** Writes a JSON part.
	This writeJson(Str name, Str json) {
		write(name, json.toBuf, MimeType("application/json; charset=utf-8"))
		return this
	}

	** Writes a JSON part.
	This writeJsonObj(Str name, Obj? jsonObj) {
		writeJson(name, JsonOutStream.writeJsonToStr(jsonObj))
	}

	** Writes a File part.
	This writeFile(Str name, File file) {
		mimeType := file.mimeType ?: MimeType("application/octet-stream")

		out.print("--").print(boundary).print("\r\n")
		out.print("Content-Disposition: form-data; name=\"${quote(name)}\"; filename=\"${quote(file.name)}\"\r\n")
		out.print("Content-Type: ${mimeType}\r\n")
		out.print("\r\n")
		out.writeBuf(file.readAllBuf)
		out.print("\r\n")		
		return this
	}
	
	internal Void finish() {
		out.print("--").print(boundary).print("--\r\n")
	}
	
	private Str quote(Str name) {
		// TODO quote as per RFC 2047
		name.toCode(null)
	}
}