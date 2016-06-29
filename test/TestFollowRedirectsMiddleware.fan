
internal class TestFollowRedirectsMiddleware : ButterTest {
	
	FollowRedirectsMiddleware? mw
	
	override Void setup() {
		mw = FollowRedirectsMiddleware()
	}
	
	Void testPassThroughOn200() {
		res := ButterResponse(200, "", HttpResponseHeaders(), "")
		end	:= MockTerminator([res])
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/`)
		verifyEq(res.statusCode, 200)
	}

	Void testPassThroughWhenNoLocation() {
		res := ButterResponse(301, "", HttpResponseHeaders(), "")
		end	:= MockTerminator([res])
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/`)
		verifyEq(res.statusCode, 301)
	}
	
	Void testPassThroughWhenTurnedOff() {
		mw.enabled = false
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/`)
		verifyEq(res.statusCode, 301)
		verifyEq(res.headers.location, `/301`)
	}

	Void testMultipleRedirects() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-1"]), ""), 
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-2"]), ""), 
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-3"]), ""), 
			ButterResponse(200, "Groovy", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.url, `/301-3`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.statusMsg, "Groovy")
	}

	Void testErrOnTooManyRedirects() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-1"]), ""), 
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-2"]), ""), 
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-3"]), ""), 
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301-4"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		verifyErrMsg(ButterErr#, ErrMsgs.tooManyRedirects(3)) {
			res := mw.sendRequest(end, ButterRequest(`/`))
		}
	}

	Void test301GetHttp10() {
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301"]), "") { it.version = Butter.http10 },  
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/301`)
		verifyEq(res.statusCode, 200)
	}

	Void test301PostHttp10() {
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301"]), "") { it.version = Butter.http10 }, 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/301`)
		verifyEq(res.statusCode, 200)
	}
	
	Void test301GetHttp11() {
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/301`)
		verifyEq(res.statusCode, 200)
	}

	Void test301PostHttp11() {
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/301"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.url, `/301`)
		verifyEq(res.statusCode, 200)
	}
	
	Void test302GetHttp10() {
		end	:= MockTerminator([
			ButterResponse(302, "", HttpResponseHeaders(["Location":"/302"]), "") { it.version = Butter.http10 }, 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302PostHttp10() {
		end	:= MockTerminator([
			ButterResponse(302, "", HttpResponseHeaders(["Location":"/302"]), "") { it.version = Butter.http10 }, 
			ButterResponse(200, "", HttpResponseHeaders(), "") 
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302GetHttp11() {
		end	:= MockTerminator([
			ButterResponse(302, "", HttpResponseHeaders(["Location":"/302"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302PostHttp11() {
		end	:= MockTerminator([
			ButterResponse(302, "", HttpResponseHeaders(["Location":"/302"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.url, `/302`)
		verifyEq(res.statusCode, 200)
	}
	
	Void test303Get() {
		end	:= MockTerminator([
			ButterResponse(303, "", HttpResponseHeaders(["Location":"/303"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/303`)
		verifyEq(res.statusCode, 200)
	}

	Void test303Post() {
		end	:= MockTerminator([
			ButterResponse(303, "", HttpResponseHeaders(["Location":"/303"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/303`)
		verifyEq(res.statusCode, 200)
	}

	Void test307Get() {
		end	:= MockTerminator([
			ButterResponse(307, "", HttpResponseHeaders(["Location":"/307"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/307`)
		verifyEq(res.statusCode, 200)
	}

	Void test307Post() {
		end	:= MockTerminator([
			ButterResponse(307, "", HttpResponseHeaders(["Location":"/307"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.url, `/307`)
		verifyEq(res.statusCode, 200)
	}

	Void test308Get() {
		end	:= MockTerminator([
			ButterResponse(308, "", HttpResponseHeaders(["Location":"/308"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.url, `/308`)
		verifyEq(res.statusCode, 200)
	}

	Void test308Post() {
		end	:= MockTerminator([
			ButterResponse(308, "", HttpResponseHeaders(["Location":"/308"]), ""), 
			ButterResponse(200, "", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.url, `/308`)
		verifyEq(res.statusCode, 200)
	}
	
	Void testFullUrlRedirect() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"http://www.example.com/zacharySmith"]), ""), 
			ButterResponse(200, "Danger, Will Robinson!", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`http://www.example.com/lostInSpace/willRobinson`))
		verifyEq(end.req.url, `http://www.example.com/zacharySmith`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.statusMsg, "Danger, Will Robinson!")
	}

	Void testAbsUrlRedirect() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"/zacharySmith"]), ""), 
			ButterResponse(200, "Danger, Will Robinson!", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`http://www.example.com/lostInSpace/willRobinson`))
		verifyEq(end.req.url, `http://www.example.com/zacharySmith`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.statusMsg, "Danger, Will Robinson!")
	}

	Void testRelUrlRedirect() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", HttpResponseHeaders(["Location":"zacharySmith"]), ""), 
			ButterResponse(200, "Danger, Will Robinson!", HttpResponseHeaders(), "")
		])
		res := mw.sendRequest(end, ButterRequest(`http://www.example.com/lostInSpace/willRobinson`))
		verifyEq(end.req.url, `http://www.example.com/lostInSpace/zacharySmith`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.statusMsg, "Danger, Will Robinson!")
	}
}
