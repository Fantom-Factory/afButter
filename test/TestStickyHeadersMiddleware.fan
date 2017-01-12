
internal class TestStickyHeadersMiddleware : ButterTest {
	
	Void testStickyHeaders() {
		mw	:= StickyHeadersMiddleware()
		res := ButterResponse(200)
		end := MockTerminator([res, res])
		
		mw.headers.userAgent = "Whoop!"
		
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.headers.userAgent, "Whoop!")

		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.headers.userAgent, "Whoop!")
	}

	Void testStickyHeadersOverride() {
		mw	:= StickyHeadersMiddleware()
		res := ButterResponse(200)
		end := MockTerminator([res, res])
		
		mw.headers.userAgent = "Whoop!"
		req := ButterRequest(`/`)
		req.headers.userAgent = "Dredd"
		
		mw.sendRequest(end, req)
		verifyEq(end.req.headers.userAgent, "Dredd")
	}

}

