using web::Cookie

internal class TestCookieMiddleware : ButterTest {
	
	Void testCookie() {
		cookie := Cookie("judge", "Dredd") { it.secure=true; it.domain="alienfactory.co.uk" ; it.path="/awesome"; it.maxAge=1sec }.toStr
		mw	:= StickyCookiesMiddleware()
		res1 := ButterResponse(200, "", ["Set-Cookie":cookie], "")
		res2 := ButterResponse(200, "", [:], "")
		end := MockTerminator([res1, res2, res2])

		// test it picked up the Set-Cookie header
		mw.sendRequest(end, ButterRequest(`/`))
		
		verifyEq(mw.cookies[0].name, "judge")
		verifyEq(mw.cookies[0].val, "Dredd")
		verifyEq(mw.cookies[0].secure, true)
		verifyEq(mw.cookies[0].domain, "alienfactory.co.uk")
		verifyEq(mw.cookies[0].path, "/awesome")
		verifyEq(mw.cookies[0].maxAge, 1sec)

		// test cookies are sent
		mw.sendRequest(end, ButterRequest(`/`))

		verifyEq(end.req.headers.cookie[0].name, "judge")
		verifyEq(end.req.headers.cookie[0].val, "Dredd")
		
		// test cookies time out
		mw.cookieData["judge"].timeSet = mw.cookieData["judge"].timeSet - 1min
		mw.sendRequest(end, ButterRequest(`/`))

		verifyEq(end.req.headers.cookie, null)
	}

	** If you can't be arsed to set credentials on your test cookies, assume wild cards
	Void testCookieNullMaxAge() {
		mw	:= StickyCookiesMiddleware()
		res1 := ButterResponse(200, "", ["set-cookie":Cookie("judge", "Dredd").toStr], "")
		res2 := ButterResponse(200, "", [:], "")
		end := MockTerminator([res1, res2, res2])

		// test it picked up the Set-Cookie header
		mw.sendRequest(end, ButterRequest(`/`))
		
		verifyEq(mw.cookies[0].name, "judge")
		verifyEq(mw.cookies[0].val, "Dredd")

		// test cookies are sent
		mw.sendRequest(end, ButterRequest(`/`))

		verifyEq(end.req.headers.cookie[0].name, "judge")
		verifyEq(end.req.headers.cookie[0].val, "Dredd")
		
		// test cookie did not time out
		mw.cookieData["judge"].timeSet = mw.cookieData["judge"].timeSet - 1min
		mw.sendRequest(end, ButterRequest(`/`))

		verifyEq(end.req.headers.cookie[0].name, "judge")
	}

}

