using util

// Can't use streams for request - 'cos we write to body before we open the real socket connection. 
// We would need a callback for when socket out becomes available. 
** Convenience methods for reading and writing content.
class Body {	
	private Buf?						buffer
	private HttpRequestHeaders?		reqHeaders
	private HttpResponseHeaders?	resHeaders
	
	** The charset used to en / decode the string and json objects. If left as 'null' then it defaults to the 'Content-Type' HTTP Header, or UTF-8 if not set.
	** 
	** 'charset' should be set *before* the body content.
	Charset? charset
	
	** Gets and sets the body content as a 'Buf'.
	Buf? buf {
		// don't seek so we can add more and more to it
		get { if (buffer != null) buffer.charset = _strCharset; return buffer }
		set { buffer = it }
	}

	** Gets and sets the body content as a string. The string is en / decoded using a charset found in the following precedence:
	**  - any charset set via the 'charset' field
	**  - the charset defined in a 'Content-Type' HTTP header
	**  - UTF-8
	** 
	** When set, the 'Content-Type' is set to 'text/plain' (if it's not been set already).
	** 
	** Returns 'null' if the body has not been set, and an empty Str if it's empty.
	Str? str {
		get { (buf == null) ? null : buf.seek(0).readAllStr }
		set {
			if (it != null && reqHeaders.contentType == null)
				reqHeaders.contentType = MimeType("text/plain; charset=${_strCharset}")
			buffer = (it == null) ? null : (buf ?: Buf() { it.charset = _strCharset }).seek(0).writeChars(it)
		}
	}

	** Gets and sets the body content as a JSON string. 
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).
	**   
	** Returns 'null' if the body has not been set or if it is empty.
	Str? json {
		get { str.trimToNull }
		set {
			if (it != null && reqHeaders.contentType == null)
				reqHeaders.contentType = MimeType("application/json; charset=${_strCharset}")
			str = it
		}
	}

	** Gets and sets the body content as a JSON object. 
	** 'JsonInStream' / 'JsonOutStream' are used to convert objects to and from JSON strings.
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).
	**   
	** Returns 'null' if the body has not been set or if it's empty.
	** 
	** Note that [JsonOutStream]`util::JsonOutStream` is used for the conversion. See the
	** [Json library]`pod:afJson` should you need pretty printing or more control over conversion.
	Obj? jsonObj {
		get { 
			(buf == null || buf.isEmpty) ? null : JsonInStream(buf.seek(0).in).readJson 
		}
		set {
			if (it != null && reqHeaders.contentType == null)
				reqHeaders.contentType = MimeType("application/json; charset=${_strCharset}")
			str = (it == null) ? null : JsonOutStream.writeJsonToStr(it)
		}
	}

	** Gets and set the body content as a JSON list. Convenience for '(Obj?[]?) body.jsonObj'.
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).  
	**   
	** Returns 'null' if the body has not been set or if it's empty.
	** 
	** Note that [JsonOutStream]`util::JsonOutStream` is used for the conversion. See the
	** [Json library]`pod:afJson` should you need pretty printing or more control over conversion.
	Obj?[]? jsonList {
		get { jsonObj }
		set { jsonObj = it }
	}

	** Gets and set the body content as a JSON map. Convenience for '([Str:Obj?]?) body.jsonObj'.
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).  
	**   
	** Returns 'null' if the body has not been set or if it's empty.
	** 
	** Note that [JsonOutStream]`util::JsonOutStream` is used for the conversion. See the
	** [Json library]`pod:afJson` should you need pretty printing or more control over conversion.
	[Str:Obj?]? jsonMap {
		get { jsonObj }
		set { jsonObj = it }
	}

	** Gets and sets the body content as a URL encoded form (think forms on web pages). 
	** 'Uri.encodeQuery()' / 'Uri.decodeQuery()' methods are used to convert objects to and from form values.
	** 
	** When set, the 'Content-Type' is set to 'application/x-www-form-urlencoded' (if it's not been set already).  
	**   
	** Returns 'null' if the body has not been set or if it's empty.
	[Str:Str]? form {
		get { (buf == null) ? null : Uri.decodeQuery(str) }
		set {
			if (it != null && reqHeaders.contentType == null)
				reqHeaders.contentType = MimeType("application/x-www-form-urlencoded; charset=${_strCharset}")
			str = (it == null) ? null : Uri.encodeQuery(it)
		}
	}
	
	** Returns the size of the body in bytes. 
	** Shortcut for 'buf?.size ?: 0'.
	Int size() {
		buf?.size ?: 0
	}
	
	** Returns the contents of the body as in 'InStream'.
	** Shortcut for 'buf?.seek(0)?.in'.
	InStream? in() {
		buf?.seek(0)?.in
	}
	
	internal new makeForReq(HttpRequestHeaders reqHeaders) {
		this.reqHeaders = reqHeaders
		// we start off with a buffer, as that is what most requests will use to set Str content etc
		buffer = Buf()
	}	
	
	internal new makeForResIn(HttpResponseHeaders resHeaders, InStream in) {
		this.resHeaders = resHeaders
		// read in the whole instream only because we need to make sure we close it at some point
		// use 'try' in case the 'in' is empty 
		try buffer = in.readAllBuf.seek(0)
		catch buffer = null
	}
	
	internal new makeForResStr(HttpResponseHeaders resHeaders, Str? str) {
		this.resHeaders = resHeaders
		this.buffer = str?.toBuf?.seek(0)
	}

	internal new makeForResBuf(HttpResponseHeaders resHeaders, Buf? buf) {
		this.resHeaders = resHeaders
		this.buffer = buf?.seek(0)
	}
	
	private Charset _strCharset() {
		if (&charset != null)
			return &charset
		if (resHeaders?.contentType?.charset != null)
			return resHeaders.contentType.charset
		if (reqHeaders?.contentType?.charset != null)
			return reqHeaders.contentType.charset
		return Charset.utf8
	}
}
