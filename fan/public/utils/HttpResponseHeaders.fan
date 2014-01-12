using web::WebUtil

** A wrapper for HTTP response headers with accessors for commonly used headings. 
** Backed by a case insensitive map.
** 
** @see `https://en.wikipedia.org/wiki/List_of_HTTP_header_fields`
class HttpResponseHeaders {
	
	private Str:Str headers	:= Str:Str[:] { it.caseInsensitive = true }

	new make(Str:Str headers) { this.headers.addAll(headers) }
	
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
	
	private Obj? makeIfNotNull(Str name, |Obj->Obj| func) {
		val := headers[name]
		return (val == null) ? null : func(val)
	}
}
