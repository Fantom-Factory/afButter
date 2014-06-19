
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
		verifyErrMsg(BadStatusErr#, ErrMsgs.serverError(500, "Argh!")) {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))			
		}
	}

	Void testThrowsBedSheetErr() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(500, "Argh!", ["X-BedSheet-errMsg":"Msg", "X-BedSheet-errType":"Type", "X-BedSheet-errStackTrace":"StackTrace"], "")
		verifyErrMsg(BadStatusErr#, "Type - Msg\nStackTrace") {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))			
		}
	}
}

