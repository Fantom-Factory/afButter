using web::Cookie

// TODO: respect domain, path, and secure attributes.
** (Middleware) - Stores cookies found in response objects, and automatically sets them in subsequent requests. 
** This effectively gives you a *session* when querying web applications.
** 
** 'StickyCookiesMiddleware' inspects the 'Max-Age' attribute of the cookies and automatically expires them when required.
** 
** 'StickyCookiesMiddleware' does not respect the Domain, Path and Secure attributes.
class StickyCookiesMiddleware : ButterMiddleware {

	internal Str:CookieData cookieData	:= Str:CookieData[:] { caseInsensitive = true }

	@NoDoc @Deprecated { msg = "Use 'allCookies()' instead" }
	Cookie[] cookies() { allCookies }
	
	@NoDoc @Deprecated { msg = "Use 'addCookie()' instead" }
	Void setCookie(Cookie cookie) { addCookie(cookie) }

	** Sets the the cookie to be included in the next request 
	Void addCookie(Cookie cookie) {
		cookieData.remove(cookie.name)
		cookieData[cookie.name] = CookieData() { it.name = cookie.name; it.cookie = cookie; it.timeSet = DateTime.now }
	}

	** Returns a cookie by name.
	** Returns 'null' if not found.
	@Operator
	Cookie? getCookie(Str cookieName) {
		cookieData[cookieName]?.cookie
	}

	** Deletes a cookie by name, returning the deleted cookie. 
	** Returns 'null' if the cookie was not found.
	Cookie? removeCookie(Str cookieName) {
		cookieData.remove(cookieName)?.cookie
	}
	
	** A read only list of all cookies held.
	Cookie[] allCookies() {
		cookieData.vals.map { it.cookie }.ro
	}

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {

		// remove any old cookies
		cookieData = cookieData.exclude { it.cookie.maxAge != null && (it.timeSet + it.cookie.maxAge) < DateTime.now }
		
		// set request cookies - being careful not to override any user set cookies
		cookies := Str:Cookie[:].addList(req.headers.cookie) { it.name }
		cookieData.each { 
			if (!cookies.containsKey(it.name))
				cookies[it.name] = it.cookie
		}
		req.headers.cookie = cookies.isEmpty ? null : cookies.vals
		
		// the usual 
		res := butter.sendRequest(req)
		
		// keep any response returned cookies
		res.headers.setCookies?.each { addCookie(it) }
		
		return res
	}
}

internal class CookieData {
	Str 		name
	DateTime	timeSet
	Cookie		cookie
	new make(|This|in) { in(this) }
}
