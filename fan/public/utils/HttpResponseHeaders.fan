using web::Cookie
using web::WebUtil

** A wrapper for HTTP response headers with accessors for commonly used headings. 
** Backed by a case insensitive map.
** 
** @see `https://en.wikipedia.org/wiki/List_of_HTTP_header_fields`
class HttpResponseHeaders {
	
	private Str:Str headers	:= Str:Str[:] { it.caseInsensitive = true }

	** Creates 'HttpResponseHeaders' copying over values in the given map. 
	new make([Str:Str]? headers := null) {
		if (headers != null)
			this.headers.addAll(headers)
	}
	
	** Tells all caching mechanisms from server to client whether they may cache this object. It is 
	** measured in seconds.
	** 
	** Example: 'Cache-Control: max-age=3600'
	Str? cacheControl {
		get { headers["Cache-Control"] }
		private set { }
	}

	** The type of encoding used on the data.
	** 
	** Example: 'Content-Encoding: gzip'
	Str? contentEncoding {
		get { headers["Content-Encoding"] }
		private set { }
	}

	** Usually used to direct the client to display a 'save as' dialog.
	** 
	** Example: 'Content-Disposition: Attachment; filename=example.html'
	** 
	** @see `http://tools.ietf.org/html/rfc6266`
	Str? contentDisposition {
		get { headers["Content-Disposition"] }
		private set { }
	}

	** The length of the response body in octets (8-bit bytes).
	** 
	** Example: 'Content-Length: 348'
	Int? contentLength {
		get { makeIfNotNull("Content-Length") { Int.fromStr(it) }}
		private set { }
	}

	** The MIME type of this content.
	** 
	** Example: 'Content-Type: text/html; charset=utf-8'
	MimeType? contentType {
		get { makeIfNotNull("Content-Type") { MimeType(it, true) }}
		private set { }
	}

	** An identifier for a specific version of a resource, often a message digest.
	** 
	** Example: 'ETag: "737060cd8c284d8af7ad3082f209582d"'
	Str? eTag {
		get { makeIfNotNull("ETag") { WebUtil.fromQuotedStr(it) }}
		private set { }
	}
	
	** Gives the date/time after which the response is considered stale.
	** 
	** Example: 'Expires: Thu, 01 Dec 1994 16:00:00 GMT'
	DateTime? expires {
		get { makeIfNotNull("Expires") { DateTime.fromHttpStr(it, true)} }
		private set { }
	}

	** The last modified date for the requested object, in RFC 2822 format.
	** 
	** Example: 'Last-Modified: Tue, 15 Nov 1994 12:45:26 +0000'
	DateTime? lastModified {
		get { makeIfNotNull("Last-Modified") { DateTime.fromHttpStr(it, true)} }
		private set { }
	}

	** Used in redirection, or when a new resource has been created.
	** 
	** Example: 'Location: http://www.w3.org/pub/WWW/People.html'
	Uri? location {
		get { makeIfNotNull("Location") { Uri.decode(it, true) } }
		private set { }
	}

	** Implementation-specific headers.
	** 
	** Example: 'Pragma: no-cache'
	Str? pragma {
		get { headers["Pragma"] }
		private set { }
	}

	** HTTP cookies previously sent by the server with 'Set-Cookie'. 
	** 
	** Example: 'Set-Cookie: UserID=JohnDoe; Max-Age=3600'
	Cookie[]? setCookie {
		// FIXME: WebUtil.parseHeaders is borked for "Set-Cookie"
		get { makeIfNotNull("Set-Cookie") |cookieValue->Cookie[]| {
			cName	:= (Str?) null 
			cValue 	:= (Str?) null
			nameValue := ""
			values := [Str:Str?][:] { caseInsensitive = true }
			cookieValue.split(';').each |value, i| {
				pair := value.split('=')
				if (i == 0) {
					cName = pair[0]
					cValue = pair.getSafe(1) ?: ""
					if (cValue.startsWith("\""))
						cValue = WebUtil.fromQuotedStr(cValue)
				} else 
					values[pair[0]] = pair.getSafe(1)
			}
			return [Cookie(cName, cValue) {
				it.maxAge 	= values.containsKey("Max-Age") ? Duration.fromStr(values["Max-Age"] + "sec", true) : null  
				it.domain 	= values["Domain"]  
				it.path 	= values["Path"]  
				it.secure 	= values.containsKey("Secure")
			}]
		}}
		private set { }
	}

	** Clickjacking protection, set to:
	**  - 'deny' - no rendering within a frame, 
	**  - 'sameorigin' - no rendering if origin mismatch
	** 
	** Example: 'X-Frame-Options: deny'
	Str? xFrameOptions {
		get { headers["X-Frame-Options"] }
		private set { }
	}

	** Cross-site scripting (XSS) filter.
	** 
	** Example: 'X-XSS-Protection: 1; mode=block'
	Str? xXssProtection {
		get { headers["X-XSS-Protection"] }
		private set { }
	}

	@Operator
	Str? get(Str name) {
		headers[name]
	}

	Str? remove(Str name) {
		headers.remove(name)
	}

	** Returns the case insensitive map that backs the headers.
	Str:Str map() {
		headers
	}
	
	override Str toStr() {
		headers.toStr
	}
	
	private Obj? makeIfNotNull(Str name, |Str->Obj| func) {
		val := headers[name]
		return (val == null) ? null : func(val)
	}
	
//	FIXME: WebUtil.parseHeaders is borked for "Set-Cookie" - the testcase 
//	static Void main(Str[] args) {
//		c:=Cookie("judge", "Dredd") { it.secure=true; it.domain="alienfactory.co.uk" ; it.path="/awesome"; it.maxAge=1sec }.toStr
//		s:="$c\r\n$c\r\n\r\n"
//		map:=WebUtil.parseHeaders(Buf().print(s).flip.in)
//		Env.cur.err.printLine(map)
//	}
}
