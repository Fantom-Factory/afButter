
internal class TestErrOn5xxMiddleware : ButterTest {
	
	Void testPassThroughOn200() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(200, "", HttpResponseHeaders(), "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testPassThroughOn500() {
		mw	:= ErrOn5xxMiddleware()
		mw.enabled = false
		res := ButterResponse(500, "Argh!", HttpResponseHeaders(), "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testThrowsServerErr() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(500, "Argh!", HttpResponseHeaders(), "")
		verifyErrMsg(BadStatusErr#, "500 - Argh! at GET `/`") {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))			
		}
	}

	Void testThrowsBedSheetErr() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(500, "Argh!", HttpResponseHeaders(["X-afBedSheet-errMsg":"Msg", "X-afBedSheet-errType":"Type", "X-afBedSheet-errStackTrace":"StackTrace"]), "")
		verifyErrMsg(BadStatusErr#, "500 - Msg at GET `/`") {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
		}
	}
}

