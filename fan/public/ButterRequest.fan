using util::JsonOutStream
using web::WebUtil

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
		formFunc(form)
		form._writeBoundryEnd
		return this
	}

	** Dumps a debug string that in some way resembles the full HTTP request.
	Str dump(Bool dumpBody := true) {
		buf := StrBuf()
		out := buf.out

		out.print("${method} ${url.relToAuth.encode} HTTP/${version}\n")
		headers.each |v, k| { out.print("${k}: ${v}\n") }
		out.print("\n")

		if (dumpBody)
			if (body.buf != null && body.buf.size > 0) {
				try	  out.print(body.str)
				catch out.print("** ERROR: Body does not contain string content **")
			}

		return buf.toStr
	}
	
	@NoDoc	// this is the sort of thing I'll prob need to call one day!
	Void _primeForSend() {
		// set the Host, if it's not been already
		// Host is mandatory for HTTP/1.1, and does no harm in HTTP/1.0
		if (headers.host == null)
			headers.host = normaliseHost(url)

		// set the Content-Length, if it's not been already
		bufSize := body.size
		if (headers.contentLength == null)
			// don't bother setting Content-Length for GET reqs with an empty body, Firefox v32 doesn't
			if (method == "GET" && bufSize == 0) {
				// then again, set Content-Length if there's a Content-Type - see http://fantom.org/forum/topic/2520
				if (headers.contentType != null)
					headers.contentLength = 0
			} else
				headers.contentLength = bufSize
	}

	** Returns a normalised host string from a URL.
	static Str normaliseHost(Uri url) {
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
		req.body.buf	= Buf()

		this.req		= req
		this.out		= req.body.buf.out
		this.boundary	= "Boundary-" + Buf.random(16).toHex
		req.headers.contentType = MimeType("multipart/form-data; boundary=$boundary")
	}

	** Writes a JSON part. Converts the given obj to a JSON str first. (using 'JsonOutStream'.)
	This writeJsonObj(Str name, Obj? jsonObj) {
		writeJson(name, JsonOutStream.writeJsonToStr(jsonObj))
	}

	** Writes a JSON part.
	This writeJson(Str name, Str json) {
		write(name, json.toBuf, MimeType("application/json; charset=utf-8"))
	}

	** Writes a standard text part. Use for setting form fields.
	This writeText(Str name, Str text) {
		write(name, text.toBuf, MimeType("text/plain; charset=utf-8"))
	}

	** Writes a part.
	This write(Str name, Buf content, MimeType? contentType := null) {
		_writeBoundry
		out.print("Content-Disposition: form-data; name=${_quote(name)}\r\n")
		if (contentType != null)
			out.print("Content-Type: ${contentType}\r\n")
		out.print("\r\n")
		out.writeBuf(content.seek(0))
		out.print("\r\n")
		return this
	}

	** Writes a File part. If 'mimeType' is not passed in, it is taken from the file's extension.
	This writeFile(Str name, File file, MimeType? mimeType := null) {
		_writeBoundry
		if (!file.exists)
			throw IOErr("File not found: ${file.normalize.osPath}")
		
		if (mimeType == null)
			// files *should* always have a MimeType
			mimeType = file.mimeType ?: MimeType("application/octet-stream")

		out.print("Content-Disposition: form-data; name=${_quote(name)}; filename=${_quote(file.name)}\r\n")
		out.print("Content-Type: ${mimeType}\r\n")
		out.print("\r\n")
		out.writeBuf(file.readAllBuf)
		out.print("\r\n")		
		return this
	}
	
	internal Void _writeBoundry() {
		out.print("--").print(boundary).print("\r\n")
	}
	
	internal Void _writeBoundryEnd() {
		out.print("--").print(boundary).print("--\r\n")
	}
	
	private static Str _quote(Str name) {
		WebUtil.toQuotedStr(name)
	}
}