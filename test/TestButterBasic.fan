
internal class TestButterBasic : ButterTest {

	Void main() {
        butter   := Butter.churnOut()
        response := butter.get(`http://www.fantomfactory.org/`)
        echo("[${response}]")
		echo("[${response.body.str}]")
    }

	Void testButterBasic() {
		butter := ButterDish(Butter.churnOut())
		res := butter.get(`http://www.alienfactory.co.uk`)
//		res := butter.get(`http://localhost:8069/`)
		web := res.body.str
//		verify(web.contains("Factory"), "No Gundam on AF site: [$web]")
		verify(web.contains("Gundam"), "No Gundam on AF site: [$web]")
	}

	Void testNoMiddleware() {
		verifyErrMsg(ArgErr#, ErrMsgs.middlewareNotSupplied) {
			but	:= Butter.churnOut([,])
		}
	}
	
	Void testNoTerminator() {
		but	:= Butter.churnOut([T_PassThroughMiddleware(StrBuf(), "")])
		verifyButterErrMsg(ErrMsgs.terminatorNotFound(T_PassThroughMiddleware#)) {
			but.get(`/`)
		}
	}
	
	Void testMiddlewareStack() {
		stack := StrBuf()
		but	:= Butter.churnOut([
			T_PassThroughMiddleware(stack, "1"),
			T_PassThroughMiddleware(stack, "2"),
			T_NullTerminator(stack, "3")
		])

		but.get(`/`)
		verifyEq(stack.toStr, "12321")

		but.get(`/`)
		verifyEq(stack.toStr, "1232112321")
	}
	
	Void testMiddlewareDynamicAccess() {
		but	:= Butter.churnOut
		verifyEq(but->httpTerminator->typeof, HttpTerminator#)
		but->followRedirects->enabled = true

		but	= ButterDish(Butter.churnOut)
		verifyEq(but->httpTerminator->typeof, HttpTerminator#)
	}
}

internal class T_PassThroughMiddleware : ButterMiddleware {
	StrBuf stack
	Str id
	new make(StrBuf stack, Str id) {
		this.stack = stack
		this.id = id
	}
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		stack.add(id)
		res := butter.sendRequest(req)
		stack.add(id)
		return res
	}
}

internal class T_NullTerminator : ButterMiddleware {
	StrBuf stack
	Str id
	new make(StrBuf stack, Str id) {
		this.stack = stack
		this.id = id
	}
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		stack.add(id)
		return ButterResponse(200, "OK", HttpResponseHeaders(), "")
	}
}

