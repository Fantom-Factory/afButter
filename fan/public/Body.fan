using util

// Can't use streams for request - 'cos we write to body before we open the real socket connection. 
// We would need a callback for when socket out becomes available. 
** Convenience methods for reading and writing content.
class Body {	
	private Buf						buffer
	private HttpRequestHeaders?		reqHeaders
	private HttpResponseHeaders?	resHeaders
	
	** The charset used to en / decode the string and json objects. If left as 'null' then it defaults to the 'Content-Type' HTTP Header, or UTF-8 if not set.
	Charset? charset
	
	** Gets and sets the body content as a 'Buf'.
	Buf buf {
		// don't seek so we can add more and more to it
		get { buffer.charset = _strCharset; return buffer }
		set { buffer = it }
	}

	** Gets and sets the body content as a string. The string is en / decodes using a charset found in the following precedence:
	**  - any charset set via the 'charset' field
	**  - the charset defined in a 'Content-Type' HTTP header
	**  - UTF-8
	** 
	** When set, the 'Content-Type' is set to 'text/plain' (if it's not been set already).  
	Str? str {
		get { buf.seek(0).readAllStr }
		set {
			if (reqHeaders.contentType != null)
				reqHeaders.contentType = MimeType("text/plain; charset=${_strCharset}")
			buffer = buf.seek(0).writeChars(it).flip
		}
	}

	** Gets and sets the body content as a JSON object. 'JsonInStream' / 'JsonOutStream' are used to convert objects to and from JSON strings.
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).  
	Obj? jsonObj {
		get { JsonInStream(buf.seek(0).in).readJson }
		set {
			if (reqHeaders.contentType != null)
				reqHeaders.contentType = MimeType("application/json; charset=${_strCharset}")
			str = JsonOutStream.writeJsonToStr(it)
		}
	}

	** Gets and set the body content as a JSON map. Convenience for '([Str:Obj?]?) body.jsonObj'.
	** 
	** When set, the 'Content-Type' is set to 'application/json' (if it's not been set already).  
	[Str:Obj?]? jsonMap {
		get { jsonObj }
		set { jsonObj = it }
	}

	internal new makeForReq(HttpRequestHeaders reqHeaders) {
		this.reqHeaders = reqHeaders
		// we start off with a buffer, as that is what most requests will use to set Str content etc
		buffer = Buf()
	}	
	
	internal new makeForResIn(HttpResponseHeaders resHeaders, InStream in) {
		this.resHeaders = resHeaders
		// read in the whole instream only because we need to make sure we close it at some point
		try buffer = in.readAllBuf
		catch buffer = Buf()
	}
	
	internal new makeForResStr(HttpResponseHeaders resHeaders, Str str) {
		this.resHeaders = resHeaders
		this.buffer = str.toBuf
	}
	
	private Charset _strCharset() {
		((&charset ?: reqHeaders?.contentType?.charset) ?: resHeaders?.contentType?.charset) ?: Charset.utf8
	}
}
