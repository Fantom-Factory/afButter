
class CookieMiddleware : ButterMiddleware {

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		return butter.sendRequest(req)
	}
}

mixin CookieDish : ButterDish {

//	Bool followRedirects() {
//		followRedriectsMw.followRedirects
//	}	

	private CookieMiddleware cookieMw() {
		findMiddleware(CookieMiddleware#)
	}	
}