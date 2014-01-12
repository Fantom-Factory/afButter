using web::Cookie

// TODO: respect domain, path, and secure attributes.
** Middleware that stores cookies found in response objects, and automatically sets them in subsequent requests. 
** This effectively gives you a *session* when querying web applications.
** 
** 'CookieMiddleware' inspects the 'Max-Age' attribute of the cookies and automatically expires them when required.
** 
** 'CookieMiddleware' does not respect the Domain, Path and Secure attributes.
class CookieMiddleware : ButterMiddleware {

	** A read only list of cookies.
	Cookie[] cookies() {
		cookieData.vals.map { it.cookie }
	}
	
	** Sets the the cookie to be included in the next request 
	Void setCookie(Cookie cookie) {
		cookieData.remove(cookie.name)
		cookieData[cookie.name] = CookieData() { it.name = cookie.name; it.cookie = cookie; it.timeSet = DateTime.now }
	}

	internal Str:CookieData cookieData	:= Str:CookieData[:] { caseInsensitive = true }
	
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {

		// remove any old cookies
		cookieData = cookieData.exclude { (it.timeSet + it.cookie.maxAge) < DateTime.now }
		
		// set request cookies - being cafeful not to override any user set cookies
		reqCookies := Str:Cookie[:].addList(cookies) { it.name }
		cookieData.each { 
			if (!reqCookies.containsKey(it.name))
				reqCookies[it.name] = it.cookie
		}
		req.headers.cookie = reqCookies.isEmpty ? null : reqCookies.vals
		
		// the usual 
		res := butter.sendRequest(req)
		
		// keep any response returned cookies
		res.headers.setCookie?.each { setCookie(it) }
		
		return res
	}
}

internal class CookieData {
	Str 		name
	DateTime	timeSet
	Cookie		cookie
	new make(|This|in) { in(this) }
}

** A `ButterDish` for `CookieMiddleware`.
mixin CookieDish : ButterDish {

	** A read only list of cookies.
	** 
	** @see `CookieMiddleware#cookies`
	Cookie[] cookies() {
		getCookieMw.cookies
	}	

	** Sets the the cookie to be included in the next request 
	** 
	** @see `CookieMiddleware#setCookie`
	Void setCookie(Cookie cookie) {
		getCookieMw.setCookie(cookie)
	}

	private CookieMiddleware getCookieMw() {
		findMiddleware(CookieMiddleware#)
	}	
}