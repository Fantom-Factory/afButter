
//TODO: expect / continue middleware

** 
mixin Butter {
	
	** Makes a simple HTTP get request to the given URI and returns the response.
	abstract ButterResponse get(Uri uri)

	** Makes a request and returns the response.
	abstract ButterResponse sendRequest(ButterRequest req)	
	
	** Returns an instance of the given middleware type as used by the 
	abstract ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true)

	** Builds a slab of butter from the given middleware.
	static Butter churnOut(ButterMiddleware[] middleware := defaultStack) {
		return ButterChain(middleware)
	}

	** The default middleware stack. It currently returns new instances of (in order):
	**  - `CookieMiddleware`
	**  - `FollowRedriectsMiddleware`
	**  - `ErrOn5xxMiddleware`
	**  - `HttpTerminator`
	static ButterMiddleware[] defaultStack() {
		ButterMiddleware[
			CookieMiddleware(),
			FollowRedriectsMiddleware(),
			ErrOn5xxMiddleware(),
			HttpTerminator()
		]
	}

	** Make a post request to the URI with the given form data.
	** The 'Content-Type' is set to 'application/x-www-form-urlencoded'.
	virtual ButterResponse postForm(Uri uri, Str:Str form) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = MimeType("application/x-www-form-urlencoded")
		req.out.print(Uri.encodeQuery(form))
		return sendRequest(req)
	}
	
	** Make a post request to the URI with the given String.
	** The 'Content-Type' is set to 'text/plain'.
	virtual ButterResponse postStr(Uri uri, Str content, Charset charset := Charset.utf8) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = MimeType("text/plain")
		Buf() { it.charset = charset }.print(content).flip.in.pipe(req.out)
		return sendRequest(req)
	}

	** Make a post request to the URI with the given file.
	** The 'Content-Type' is set from the file extension's MIME type, or 'application/octet-stream' if unknown.
	virtual ButterResponse postFile(Uri uri, File file) {
		req := ButterRequest(uri) {
			it.method	= "POST"
		}
		req.headers.contentType = file.mimeType ?: MimeType("application/octet-stream")
		file.in.pipe(req.out, file.size, true)
		return sendRequest(req)
	}	
}

