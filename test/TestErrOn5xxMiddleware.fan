
internal class TestErrOn5xxMiddleware : ButterTest {
	
	Void testPassThroughOn200() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(200, "", [:], "".in)
		mw.sendRequest(MockTerminator(res), ButterRequest(`/`))
	}

	Void testPassThroughOn500() {
		mw	:= ErrOn5xxMiddleware()
		mw.errOn5xx = false
		res := ButterResponse(500, "Argh!", [:], "".in)
		mw.sendRequest(MockTerminator(res), ButterRequest(`/`))
	}

	Void testThrowsServerErr() {
		mw	:= ErrOn5xxMiddleware()
		res := ButterResponse(500, "Argh!", [:], "".in)
		verifyErrTypeAndMsg(ServerErr#, ErrMsgs.serverError(500, "Argh!")) {
			mw.sendRequest(MockTerminator(res), ButterRequest(`/`))			
		}
	}
}

internal class MockTerminator : Butter {
	ButterResponse res
	new make(ButterResponse res) { this.res = res }
	override ButterResponse get(Uri uri) { res }
	override ButterResponse sendRequest(ButterRequest req) { res }
	override ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true) { null }
}
