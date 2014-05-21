

** Middleware that throws a `BadStatusErr` when a HTTP response returns a 4xx status code, indicating a bad request.
class ErrOn4xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `BadStatusErr` on a 4xx status code. 
	** Defaults to 'true'.
	Bool enabled	:= true

	** Do dat ting.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (enabled && (400..<500).contains(res.statusCode))
			throw BadStatusErr(res.statusCode, res.statusMsg, ErrMsgs.badRequest(res.statusCode, res.statusMsg, req.uri))
		return res
	}
}

** Middleware that throws a `BadStatusErr` when a HTTP response returns a 5xx status code, indicating a server error.
class ErrOn5xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `BadStatusErr` on a 5xx status code. 
	** Defaults to 'true'.
	Bool enabled	:= true

	** Do dat ting.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (enabled && (500..<600).contains(res.statusCode)) {
			errMsg 	 := res.headers["X-BedSheet-errMsg"]
			errType	 := res.headers["X-BedSheet-errType"]
			errStack := res.headers["X-BedSheet-errStackTrace"]
			if (errMsg != null && errType != null && errStack != null)
				throw BadStatusErr(res.statusCode, errMsg, "${errType} - ${errMsg}\n${errStack}")
			throw BadStatusErr(res.statusCode, res.statusMsg, ErrMsgs.serverError(res.statusCode, res.statusMsg))
		}
		return res
	}
}

** Throw by 'ErrOnXxxMiddleware' when a HTTP response returns a bad status code.
const class BadStatusErr : Err {
	** The failing HTTP response status code
	const Int statusCode
	
	** The failing HTTP response status message
	const Str statusMsg
	
	new make(Int statusCode, Str statusMsg, Str msg := "", Err? cause := null) : super(msg, cause) {
		this.statusCode = statusCode
		this.statusMsg  = statusMsg
	}
}