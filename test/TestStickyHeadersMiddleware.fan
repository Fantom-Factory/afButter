
internal class TestStickyHeadersMiddleware : ButterTest {
	
	Void testStickyHeaders() {
		mw	:= StickyHeadersMiddleware()
		res := ButterResponse(200, "", HttpResponseHeaders(), "")
		end := MockTerminator([res, res])
		
		mw.stickyHeaders.userAgent = "Whoop!"
		
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.headers.userAgent, "Whoop!")

		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.headers.userAgent, "Whoop!")
	}

	Void testStickyHeadersOverride() {
		mw	:= StickyHeadersMiddleware()
		res := ButterResponse(200, "", HttpResponseHeaders(), "")
		end := MockTerminator([res, res])
		
		mw.stickyHeaders.userAgent = "Whoop!"
		req := ButterRequest(`/`)
		req.headers.userAgent = "Dredd"
		
		mw.sendRequest(end, req)
		verifyEq(end.req.headers.userAgent, "Dredd")
	}

}

