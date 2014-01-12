using web::Cookie

internal class TestCookieMiddleware : ButterTest {
	
	Void testCookie() {
		mw	:= CookieMiddleware()
//		    &cookies.each |Cookie c| { sout.print("Set-Cookie: ").print(c).print("\r\n") }

		res1 := ButterResponse(200, "", [:], "".in)
		res2 := ButterResponse(200, "", [:], "".in)
		res1.headers.map["Set-Cookie"] = Cookie("judge", "Dredd") { it.secure=true; it.domain="alienfactory.co.uk" ; it.path="/awesome"; it.maxAge=1sec }.toStr
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

}

