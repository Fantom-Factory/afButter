
** Middleware that throws a `ServerErr` when a HTTP response returns a 5xx status code, indicating a server error.
class ErrOn5xxMiddleware : ButterMiddleware {
	
	** If set to 'true', this middleware throws a `ServerErr` on a 5xx status code. 
	** Defaults to 'true'.
	Bool errOn5xx	:= true

	** Do dat ting.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (errOn5xx && (500..<600).contains(res.statusCode))
			throw ServerErr(res.statusCode, res.statusMsg, ErrMsgs.serverError(res.statusCode, res.statusMsg))
		return res
	}
}

** A `ButterDish` for `ErrOn5xxMiddleware`.
mixin ErrOn500Dish : ButterDish {

	** Returns 'true' if a `ServerErr` is thrown on a 5xx status code.
	** 
	** @see `ErrOn5xxMiddleware#errOn5xx`
	Bool errOn5xx() {
		getErrOn5xxMw.errOn5xx
	}	

	** Set to 'true' for a `ServerErr` is thrown on a 5xx status code.
	** 
	** @see `ErrOn5xxMiddleware#errOn5xx`
	Void setErrOn5xx(Bool errOn5xx) {
		getErrOn5xxMw.errOn5xx = errOn5xx
	}	

	private ErrOn5xxMiddleware getErrOn5xxMw() {
		findMiddleware(ErrOn5xxMiddleware#)
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