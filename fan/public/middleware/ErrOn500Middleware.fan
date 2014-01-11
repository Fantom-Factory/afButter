
// TODO: do for 404
class ErrOn500Middleware : ButterMiddleware {
	
	Bool errOn5xx	:= true

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		res := butter.sendRequest(req)
		if (errOn5xx && (500..<600).contains(res.statusCode))
			throw ButterErr("Response returned status code ${res.statusCode}")
		return res
	}
}

mixin ErrOn500Dish : ButterDish {

	Bool errOn5xx() {
		errOn500Mw.errOn5xx
	}	

	Void setErrOn5xx(Bool errOn5xx) {
		errOn500Mw.errOn5xx = errOn5xx
	}	

	private ErrOn500Middleware errOn500Mw() {
		findMiddleware(ErrOn500Middleware#)
	}	
}
