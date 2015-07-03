
** 'Butter' instances route HTTP requests through a stack of middleware.    
mixin Butter {
	
	** A const value representing HTTP 1.0
	static const Version http10 := Version("1.0")

	** A const value representing HTTP 1.1
	static const Version http11 := Version("1.1")


	** Makes a request and returns the response.
	abstract ButterResponse sendRequest(ButterRequest req)	
	
	** Returns an instance of the given middleware type as used by the 
	abstract ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true)

	** Returns a (modifiable) list of middleware instances used by this 'Butter' 
	abstract ButterMiddleware[] middleware()

	** Builds a pack of butter from the given middleware stack.
	** The ordering of the stack *is* important.
	static Butter churnOut(ButterMiddleware[] middleware := defaultStack) {
		return ButterChain(middleware)
	}

	** The default middleware stack. It currently returns new instances of (in order):
	**  - `StickyHeadersMiddleware`
	**  - `GzipMiddleware`
	**  - `FollowRedirectsMiddleware`
	**  - `StickyCookiesMiddleware`
	**  - `ErrOn4xxMiddleware`
	**  - `ErrOn5xxMiddleware`
	**  - `ProxyMiddleware`
	**  - `HttpTerminator`
	static ButterMiddleware[] defaultStack() {
		ButterMiddleware[
			StickyHeadersMiddleware(),
			GzipMiddleware(),
			FollowRedirectsMiddleware(),
			StickyCookiesMiddleware(),		// as cookies can come with a re-direct command, Cookie middleware needs to come *before* Redirect middleware
			ErrOn4xxMiddleware(),
			ErrOn5xxMiddleware(),
			ProxyMiddleware(),
			HttpTerminator()
		]
	}

	** Makes a simple HTTP get request to the given URL and returns the response.
	virtual ButterResponse get(Uri url) {
		sendRequest(ButterRequest(url))
	}

	** Makes a HTTP POST request to the URL with the given form data.
	** The 'Content-Type' is set to 'application/x-www-form-urlencoded'.
	virtual ButterResponse postForm(Uri url, Str:Str form) {
		sendRequest(ButterRequest(url) {
			it.method = "POST"
			it.body.form = form
		})
	}
	
	** Makes a HTTP POST request to the URL with the given String.
	** The 'Content-Type' is set to 'text/plain'.
	virtual ButterResponse postStr(Uri url, Str content, Charset charset := Charset.utf8) {
		sendRequest(ButterRequest(url) {
			it.method	= "POST"
			it.body.str = content
		})
	}

	** Makes a HTTP POST request to the URL with the given JSON Obj.
	** The 'Content-Type' is set to 'application/json'.
	virtual ButterResponse postJsonObj(Uri url, Obj? jsonObj) {
		sendRequest(ButterRequest(url) {
			it.method = "POST"
			it.body.jsonObj = jsonObj
		})
	}

	** Makes a HTTP POST request to the URL with the given file.
	** The 'Content-Type' is set from the file extension's MIME type, or 'application/octet-stream' if unknown.
	virtual ButterResponse postFile(Uri url, File file) {
		sendRequest(ButterRequest(url) {
			it.method = "POST"
			it.headers.contentType = file.mimeType ?: MimeType("application/octet-stream")
			it.body.buf = file.readAllBuf  
		})
	}	

	** Makes a HTTP PUT request to the URL with the given String.
	** The 'Content-Type' is set to 'text/plain'.
	virtual ButterResponse putStr(Uri url, Str content, Charset charset := Charset.utf8) {
		sendRequest(ButterRequest(url) {
			it.method	= "PUT"
			it.body.str = content
		})
	}

	** Makes a HTTP PUT request to the URL with the given JSON Obj.
	** The 'Content-Type' is set to 'application/json'.
	virtual ButterResponse putJsonObj(Uri url, Obj? jsonObj) {
		sendRequest(ButterRequest(url) {
			it.method = "PUT"
			it.body.jsonObj = jsonObj
		})
	}

	** Makes a simple HTTP DELETE request to the given URL and returns the response.
	virtual ButterResponse delete(Uri url) {
		sendRequest(ButterRequest(url) {
			it.method = "DELETE"
		})
	}

	@NoDoc
	override Obj? trap(Str name, Obj?[]? args := null) {
		middleware.find |mw->Bool| {
			if (mw.typeof.name.equalsIgnoreCase(name))
				return true
			if (mw.typeof.name.lower.endsWith("middleware"))
				if (mw.typeof.name[0..<-"middleware".size].equalsIgnoreCase(name))
					return true
			return false
		} ?: throw ButterErr(ErrMsgs.chainMiddlewareNotFound(name), middleware.map { it.typeof.name })
	}	
}
