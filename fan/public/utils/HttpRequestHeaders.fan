using web::Cookie
using web::WebUtil

** A wrapper for HTTP request headers with accessors for commonly used headings.
** Set a value to 'null' to remove it from the map.
** Backed by a case insensitive map.
** 
** @see `http://en.wikipedia.org/wiki/List_of_HTTP_header_fields`
class HttpRequestHeaders {
	private const static Log 	log := Utils.getLog(HttpRequestHeaders#)
	private Str:Str headers	:= Str:Str[:] { it.caseInsensitive = true }

	** Creates 'HttpRequestHeaders' copying over values in the given map. 
	new make([Str:Str]? headers := null) {
		if (headers != null)
			this.headers.addAll(headers)
	}

	** Content-Types that are acceptable for the response. 
	** 
	** Example: 'Accept: audio/*; q=0.2, audio/basic'
	** 
	** Returns 'null' if the header doesn't exist.
	QualityValues? accept {
		get { makeIfNotNull("Accept") { QualityValues(it, true) }}
		set { addOrRemove("Accept", it?.toStr) }
	}

	** List of acceptable encodings.
	** 
	** Example: 'Accept-Encoding: compress;q=0.5, gzip;q=1.0'
	** 
	** Returns 'null' if the header doesn't exist.
	QualityValues? acceptEncoding {
		get { makeIfNotNull("Accept-Encoding") { QualityValues(it, true) }}
		set { addOrRemove("Accept-Encoding", it?.toStr) }
	}

	** List of acceptable human languages for response.
	** 
	** Example: 'Accept-Language: da, en-gb;q=0.8, en;q=0.7'
	** 
	** Returns 'null' if the header doesn't exist.
	QualityValues? acceptLanguage {
		get { makeIfNotNull("Accept-Language") { QualityValues(it, true) }}
		set { addOrRemove("Accept-Language", it?.toStr) }
	}

	** Authorization header. For *BASIC* authorisation, encode the credentials like this:
	** 
	**   syntax: fantom
	**   headers.authorization = "BASIC " + "${username}:${password}".toBuf.toBase64 
	** 
	** Example: 'Authorization: Basic QWxhZGRpbjpPcGVuU2VzYW1l'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? authorization {
		get { headers["Authorization"] }
		set { addOrRemove("Authorization", it) }
	}

	** The length of the request body in octets (8-bit bytes).
	** 
	** Example: 'Content-Length: 348'
	** 
	** Returns 'null' if the header doesn't exist.
	Int? contentLength {
		get { makeIfNotNull("Content-Length") { Int.fromStr(it, 10, true) }}
		set { addOrRemove("Content-Length", it?.toStr) }
	}

	** The MIME type of the body of the request (mainly used with POST and PUT requests).
	** 
	** Example: 'Content-Type: application/x-www-form-urlencoded'
	** 
	** Returns 'null' if the header doesn't exist.
	MimeType? contentType {
		get { makeIfNotNull("Content-Type") { MimeType(it, true) }}
		set { addOrRemove("Content-Type", it?.toStr) }
	}

	** HTTP cookies previously sent by the server with 'Set-Cookie'. 
	** 
	** Example: 'Cookie: Version=1; Skin=new;'
	** 
	** Returns 'null' if the header doesn't exist.
	Cookie[]? cookie {
		get { makeIfNotNull("Cookie") { it.split(';'). map { Cookie.fromStr(it) }}}
		set { addOrRemove("Cookie", it?.join("; ") { it.name + "=" + WebUtil.toQuotedStr(it.val) }) }
	}

	** The domain name of the server (for virtual hosting), and the TCP port number on which the 
	** server is listening. The port number may be omitted if the port is the standard port for 
	** the service requested.
	** 
	** Example: 'Host: www.alienfactory.co.uk:8069'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? host {
		get { headers["Host"] }
		set { addOrRemove("Host", it) }
	}

	** Allows a 304 Not Modified to be returned if content is unchanged.
	** 
	** Example: 'If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT'
	** 
	** Returns 'null' if the header doesn't exist.
	DateTime? ifModifiedSince {
		get { makeIfNotNull("If-Modified-Since") { DateTime.fromHttpStr(it, true) }}
		set { addOrRemove("If-Modified-Since", it?.toHttpStr) }
	}

	** Allows a 304 Not Modified to be returned if content is unchanged.
	** 
	** Example: 'If-None-Match: "737060cd8c284d8af7ad3082f209582d"'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? ifNoneMatch {
		get { headers["If-None-Match"] }
		set { addOrRemove("If-None-Match", it) }
	}

	** Initiates a request for cross-origin resource sharing.
	** 
	** Example: 'Origin: http://www.example-social-network.com'
	** 
	** Returns 'null' if the header doesn't exist.
	Uri? origin {
		get { makeIfNotNull("Origin") { Uri.decode(it, true) } }
		set { addOrRemove("Origin", it?.encode) }
	}

	** This is the address of the previous web page from which a link to the currently requested 
	** page was followed. 
	** 
	** Example: 'Referer: http://en.wikipedia.org/wiki/Main_Page'
	** 
	** Returns 'null' if the header doesn't exist.
	Uri? referrer {
		// yeah, I know I've mispelt referrer!
		// see `https://en.wikipedia.org/wiki/HTTP_referrer`
		get { makeIfNotNull("Referer") { Uri.decode(it, true) } }
		set { addOrRemove("Referer", it?.encode) }
	}

	** The user agent string of the user agent.
	** 
	** Example: 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? userAgent {
		get { headers["User-Agent"] }
		set { addOrRemove("User-Agent", it) }
	}

	** Mainly used to identify Ajax requests. 
	** 
	** Example: 'X-Requested-With: XMLHttpRequest'
	** 
	** Returns 'null' if the header doesn't exist.
	Str? xRequestedWith {
		get { headers["X-Requested-With"] }
		set { addOrRemove("X-Requested-With", it) }
	}

	** Identifies the originating IP address of a client connecting through an HTTP proxy. 
	** 
	** Example: 'X-Forwarded-For: client, proxy1, proxy2'
	** 
	** Returns 'null' if the header doesn't exist.
	Str[]? xForwardedFor {
		get { headers["X-Forwarded-For"]?.split(',') }
		set { addOrRemove("X-Forwarded-For", it?.join(", ")) }
	}

	** Simple getter for setting raw Str values.
	@Operator
	Str? get(Str name) {
		headers[name]
	}

	** Simple setter for getting raw Str values.
	** Setting a 'null' value removes the value from the map.
	@Operator
	Void set(Str name, Str? value) {
		addOrRemove(name, value)
	}
	
	** Iterates over the headers.
	Void each(|Str val, Str key| c) {
		headers.each(c)
	}
	
	** Returns 'true' if the given header has been set
	Bool containsKey(Str key) {
		headers.containsKey(key)
	}
	
	@NoDoc @Deprecated { msg="Use 'val' instead." }
	Str:Str map() { val }
	
	** Returns the case insensitive map that backs the headers.
	Str:Str val() {
		headers
	}
	
	override Str toStr() {
		headers.toStr
	}
	
	private Obj? makeIfNotNull(Str name, |Str->Obj| func) {
		val := headers[name]
		if (val == null)
			return val
		try		return func(val)
		catch	log.warn("Could not parse dodgy ${name} HTTP Header: ${val}")
		return	null
	}

	private Void addOrRemove(Str name, Str? value) {
		if (value == null)
			headers.remove(name)
		else
			headers[name] = value
	}
}
