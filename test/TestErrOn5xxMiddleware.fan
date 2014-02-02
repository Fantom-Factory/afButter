
internal class TestErrOn5xxMiddleware : ButterTest {
	
	Void testPassThroughOn200() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(200, "", [:], "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testPassThroughOn500() {
		mw	:= ErrOn5xxMiddleware()
		mw.enabled = false
		res := ButterResponse(500, "Argh!", [:], "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testThrowsServerErr() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(500, "Argh!", [:], "")
		verifyErrTypeAndMsg(BadStatusErr#, ErrMsgs.serverError(500, "Argh!")) {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))			
		}
	}
}

