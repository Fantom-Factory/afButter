
** Middleware that throws a `ServerErr` when a HTTP response returns a 5xx status code, indicating a server error.
class ErrOn5xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `ServerErr` on a 5xx status code. 
	** Defaults to 'true'.
	Bool enabled	:= true

	** Do dat ting.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (enabled && (500..<600).contains(res.statusCode))
			throw ServerErr(res.statusCode, res.statusMsg, ErrMsgs.serverError(res.statusCode, res.statusMsg))
		return res
	}
}

** Throw by `ErrOn5xxMiddleware` when a HTTP response returns a 5xx status code.
const class ServerErr : Err {
	** The failing HTTP response status code
	const Int statusCode
	
	** The failing HTTP response status message
	const Str statusMsg
	
	new make(Int statusCode, Str statusMsg, Str msg := "", Err? cause := null) : super(msg, cause) {
		this.statusCode = statusCode
		this.statusMsg  = statusMsg
	}
}