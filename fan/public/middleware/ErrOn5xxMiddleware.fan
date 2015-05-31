

** (Middleware) - Throws `BadStatusErr` when a HTTP response returns a 4xx status code. 
** This indicates a bad request.
class ErrOn4xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `BadStatusErr` on a 4xx status code. 
	** Defaults to 'true'.
	Bool enabled	:= true

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (enabled && (400..<500).contains(res.statusCode)) {
			body := (Str?) null
			try body = res.body.str; catch { /* wotever */ }
			throw BadStatusErr(req.method, req.url, res.statusCode, res.statusMsg, body)
		}
		return res
	}
}

** (Middleware) - Throws `BadStatusErr` when a HTTP response returns a 5xx status code.
** This indicates a server error.
class ErrOn5xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `BadStatusErr` on a 5xx status code. 
	** Defaults to 'true'.
	Bool enabled	:= true

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (enabled && (500..<600).contains(res.statusCode)) {
			errMsg 	 := res.headers["X-afBedSheet-errMsg"]
			errType	 := res.headers["X-afBedSheet-errType"]
			errStack := res.headers["X-afBedSheet-errStackTrace"]
			
			body := (Str?) null
			try body = res.body.str; catch { /* wotever */ }
			
			if (errMsg != null && errType != null && errStack != null)
				throw BadStatusErr(req.method, req.url, res.statusCode, errMsg, "${errType} - ${errMsg}\n${errStack}")
			throw BadStatusErr(req.method, req.url, res.statusCode, res.statusMsg, body)
		}
		return res
	}
}

** Throw by 'ErrOnXxxMiddleware' when a HTTP response returns a bad status code.
** 
** To prevent 'BadStatusErrs' from being thrown, just disable the relevant middleware.
** For example, to prevent a 'BadStatusErr' from being thrown when a 404 is returned:
** 
**   syntax: fantom
**   butterDish.errOn4xxx.enabled = false
** 
** To prevent a 'BadStatusErr' from being thrown when a 500 is returned:
** 
**   syntax: fantom
**   butterDish.errOn5xxx.enabled = false 
const class BadStatusErr : Err {
		
	** The failing HTTP request URL
	const Uri reqUrl
	
	** The failing HTTP request Method
	const Str reqMethod
	
	** The failing HTTP response status code
	const Int statusCode
	
	** The failing HTTP response status message
	const Str statusMsg

	** The body of the failing HTTP response (if a string)
	const Str? body

	** Create a 'BadStatusErr'.
	new make(Str reqMethod, Uri reqUrl, Int statusCode, Str statusMsg, Str? body := null, Err? cause := null) : super(mess(reqMethod, reqUrl, statusCode, statusMsg), cause) {
		this.reqMethod 	= reqMethod
		this.reqUrl 	= reqUrl
		this.statusCode = statusCode
		this.statusMsg  = statusMsg
		this.body 		= body
	}
	
	** Pre-pends the list of available values to the stack trace.
	override Str toStr() {
		buf := StrBuf()
		buf.add("${typeof.qname}: ${mess(reqMethod, reqUrl, statusCode, statusMsg)}\n")
		if (body != null) {
			buf.add("\nBody:\n")
			body.splitLines.each { buf.add("  $it\n")}
		}
		buf.add("\nStack Trace:")
		return buf.toStr
	}

	private static Str mess(Str reqMethod, Uri reqUrl, Int statusCode, Str statusMsg) {
		"${statusCode} - ${statusMsg} at ${reqMethod} `${reqUrl}`"
	}
}