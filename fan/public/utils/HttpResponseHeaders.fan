using web::Cookie
using web::WebUtil

** A wrapper for HTTP response headers with accessors for commonly used headings. 
** 
** @see `https://en.wikipedia.org/wiki/List_of_HTTP_header_fields`
class HttpResponseHeaders {
	private static const Int CR  := '\r'
	private static const Int LF  := '\n'
	private static const Int maxTokenSize := 4096

	@NoDoc
	const KeyVal[]	keyVals	

	** it-block ctor.
	new make(|This| in) {
		in(this)
	}
	
	** Creates 'HttpResponseHeaders' copying over values in the given map. 
	new makeFromMap([Str:Str]? headers := null) {
		this.keyVals = convertMap(headers)
	}

	** Parses headers from the given InStream. 
	new makeFromInStream(InStream in) {
		this.keyVals = parseHeaders(in)
	}

	** Tells all caching mechanisms from server to client whether they may cache this object. It is 
	** measured in seconds.
	** 
	** Example: 'Cache-Control: max-age=3600'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? cacheControl {
		get { getFirst("Cache-Control") }
		private set { }
	}

	** The type of encoding used on the data.
	** 
	** Example: 'Content-Encoding: gzip'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? contentEncoding {
		get { getFirst("Content-Encoding") }
		private set { }
	}

	** Usually used to direct the client to display a 'save as' dialog.
	** 
	** Example: 'Content-Disposition: Attachment; filename=example.html'
	** 
	** Returns 'null' if the header doesn't exist.
	** 
	** @see `http://tools.ietf.org/html/rfc6266`
	Str? contentDisposition {
		get { getFirst("Content-Disposition") }
		private set { }
	}

	** The length of the response body in octets (8-bit bytes).
	** 
	** Example: 'Content-Length: 348'
	** 
	** Returns 'null' if the header doesn't exist.
	Int? contentLength {
		get { makeIfNotNull("Content-Length") { Int.fromStr(it) }}
		private set { }
	}

	** The MIME type of this content.
	** 
	** Example: 'Content-Type: text/html; charset=utf-8'
	** 
	** Returns 'null' if the header doesn't exist.
	MimeType? contentType {
		get { makeIfNotNull("Content-Type") { MimeType(it, true) }}
		private set { }
	}

	** An identifier for a specific version of a resource, often a message digest.
	** 
	** Example: 'ETag: "737060cd8c284d8af7ad3082f209582d"'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? eTag {
		get { makeIfNotNull("ETag") { WebUtil.fromQuotedStr(it) }}
		private set { }
	}
	
	** Gives the date/time after which the response is considered stale.
	** 
	** Example: 'Expires: Thu, 01 Dec 1994 16:00:00 GMT'
	** 
	** Returns 'null' if the header doesn't exist.
	DateTime? expires {
		get { makeIfNotNull("Expires") { DateTime.fromHttpStr(it, true)} }
		private set { }
	}

	** The last modified date for the requested object, in RFC 2822 format.
	** 
	** Example: 'Last-Modified: Tue, 15 Nov 1994 12:45:26 +0000'
	** 
	** Returns 'null' if the header doesn't exist.
	DateTime? lastModified {
		get { makeIfNotNull("Last-Modified") { DateTime.fromHttpStr(it, true)} }
		private set { }
	}

	** Used in redirection, or when a new resource has been created.
	** 
	** Example: 'Location: http://www.w3.org/pub/WWW/People.html'
	** 
	** Returns 'null' if the header doesn't exist.
	** 
	** Returns 'null' if the header doesn't exist.
	Uri? location {
		get { makeIfNotNull("Location") { Uri.decode(it, true) } }
		private set { }
	}

	** Implementation-specific headers.
	** 
	** Example: 'Pragma: no-cache'
	Str? pragma {
		get { getFirst("Pragma") }
		private set { }
	}

	** HTTP cookies previously sent by the server with 'Set-Cookie'. 
	** 
	** Example: 'Set-Cookie: UserID=JohnDoe; Max-Age=3600'
	** 
	** Returns 'null' if the header doesn't exist.
	Cookie[]? setCookies {
		get { 
			cookies := getAll("Set-Cookie").map |cookieValue->Cookie| {
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
				return Cookie(cName, cValue) {
					it.maxAge 	= values.containsKey("Max-Age") ? Duration.fromStr(values["Max-Age"] + "sec", true) : null  
					it.domain 	= values["Domain"]  
					it.path 	= values["Path"]  
					it.secure 	= values.containsKey("Secure")
				}
			}
			return cookies.isEmpty ? null : cookies
		}
		private set { }
	}

	** WWW-Authenticate header to indicate supported authentication mechanisms.
	** 
	** Example: 'WWW-Authenticate: SCRAM hash=SHA-256'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? wwwAuthenticate {
		get { getFirst("WWW-Authenticate") }
		private set { }
	}
	
	** Clickjacking protection, set to:
	**  - 'deny' - no rendering within a frame, 
	**  - 'sameorigin' - no rendering if origin mismatch
	** 
	** Example: 'X-Frame-Options: deny'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? xFrameOptions {
		get { getFirst("X-Frame-Options") }
		private set { }
	}

	** Cross-site scripting (XSS) filter.
	** 
	** Example: 'X-XSS-Protection: 1; mode=block'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? xXssProtection {
		get { getFirst("X-XSS-Protection") }
		private set { }
	}

	** Returns the first header with the given name. (case-insensitive)
	@Operator
	Str? getFirst(Str name) {
		keyVals.find { it.key.equalsIgnoreCase(name) }?.val
	}

	** Returns all header with the given name. (case-insensitive)
	Str[] getAll(Str name) {
		keyVals.findAll { it.key.equalsIgnoreCase(name) }.map |kv->Str| { kv.val }
	}

	@NoDoc @Deprecated { msg="Use 'val' instead." }
	Str:Str map() { val }

	** Returns a read-only case insensitive map of the headers.
	Str:Str val() {
		(keyVals.reduce(Str:Str[:] { it.caseInsensitive = true}) |Str:Str map, kv -> Str:Str| {
			map[kv.key] = map.containsKey(kv.key) ?  map[kv.key] + "," + kv.val : kv.val
		} as Str:Str).ro
	}

	** Iterates over the headers.
	Void each(|Str val, Str key| c) {
		keyVals.each { c(it.val, it.key) }
	}

	@NoDoc
	KeyVal[] convertMap([Str:Str]? headers) {
		keyVals := KeyVal[,]
		headers?.each |val, key| { keyVals.add(KeyVal(key, val)) }
		return keyVals
	}

	@NoDoc
	override Str toStr() {
		val.toStr
	}
	
	private Obj? makeIfNotNull(Str name, |Str->Obj| func) {
		val := getFirst(name)
		return (val == null) ? null : func(val)
	}

	private static KeyVal[] parseHeaders(InStream in) {
		keyVals := KeyVal[,]
		while (true) {
			peek := in.peek
		
			// CRLF is end of headers
			if (peek == CR) break
			
			// if line starts with space it's a continuation of the last header field
			if (peek.isSpace && !keyVals.isEmpty) {
				last := keyVals.removeAt(-1)
				keyVals.add(KeyVal(last.key, last.val + " " + in.readLine.trim))
				continue
			}
		
			// key/value pair
			key := token(in, ':').trim
			val := token(in, CR).trim
			if (in.read != LF)
				throw ParseErr("Invalid CRLF line ending")
		
			keyVals.add(KeyVal(key, val))
		}
		
		// consume final CRLF
		if (in.read != CR || in.read != LF)
			throw ParseErr("Invalid CRLF headers ending")
		
		return keyVals
	}

	** Read the next token from the stream up to the specified separator. 
	** We place a limit of 4096 bytes on a single token.
	** Consume the separate char too.
	private static Str token(InStream in, Int sep) {
		// read up to separator
		tok := in.readStrToken(maxTokenSize) |Int ch->Bool| { return ch == sep }
		
		// sanity checking
		if (tok == null) throw IOErr("Unexpected end of stream")
		if (tok.size >= maxTokenSize) throw ParseErr("Token too big")
		
		// read separator
		in.read
		
		return tok
	}	
}

@NoDoc
const class KeyVal {
	const Str key
	const Str val
	new make(Str key, Str val) {
		this.key = key
		this.val = val
	}
}
