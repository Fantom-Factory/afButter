
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

	** Returns an read only list of middleware instances used by this 'Butter' 
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
	**  - `HttpTerminator`
	static ButterMiddleware[] defaultStack() {
		ButterMiddleware[
			StickyHeadersMiddleware(),
			GzipMiddleware(),
			FollowRedirectsMiddleware(),
			StickyCookiesMiddleware(),		// as cookies can come with a re-direct command, Cookie middleware needs to come *before* Redirect middleware
			ErrOn4xxMiddleware(),
			ErrOn5xxMiddleware(),
			HttpTerminator()
		]
	}

	** Makes a simple HTTP get request to the given URI and returns the response.
	virtual ButterResponse get(Uri uri) {
		sendRequest(ButterRequest(uri))
	}

	** Make a post request to the URI with the given form data.
	** The 'Content-Type' is set to 'application/x-www-form-urlencoded'.
	virtual ButterResponse postForm(Uri uri, Str:Str form) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = MimeType("application/x-www-form-urlencoded")
		
		//sys::UnsupportedErr: java.lang.UnsupportedOperationException
		//  fan.sys.Map$CIHashMap.keySet (Map.java:650)
		//  fan.sys.Map.keysIterator (Map.java:629)
		//  fan.sys.Uri.encodeQuery (Uri.java:87)
		// see http://fantom.org/sidewalk/topic/2236
		caseSensitive := Str:Str[:].addAll(form)
		
		enc := Uri.encodeQuery(caseSensitive)
		req.body.print(enc)
		return sendRequest(req)
	}
	
	** Make a post request to the URI with the given String.
	** The 'Content-Type' is set to 'text/plain'.
	virtual ButterResponse postStr(Uri uri, Str content, Charset charset := Charset.utf8) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = MimeType("text/plain")
		Buf() { it.charset = charset }.print(content).flip.in.pipe(req.body.out)
		return sendRequest(req)
	}

	** Make a post request to the URI with the given file.
	** The 'Content-Type' is set from the file extension's MIME type, or 'application/octet-stream' if unknown.
	virtual ButterResponse postFile(Uri uri, File file) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = file.mimeType ?: MimeType("application/octet-stream")
		file.in.pipe(req.body.out, file.size, true)
		return sendRequest(req)
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

