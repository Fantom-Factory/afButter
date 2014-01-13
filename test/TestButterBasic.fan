
internal class TestButterBasic : ButterTest {

	Void main() {
		echo("sdkjhfkjd")
        butter   := Butter.churnOut()
        response := butter.get(`http://www.fantomfactory.org/`)
        echo("[${response}]")
		echo("[${response.asStr}]")
    }

	Void testButterBasic() {
		butter := MyButterDish(Butter.churnOut())
		res := butter.get(`http://www.alienfactory.co.uk`)
//		res := butter.get(`http://localhost:8069/`)
		web := res.asStr
		Env.cur.err.printLine(web)
//		verify(web.contains("Factory"), "No Gundam on AF site: [$web]")
		verify(web.contains("Gundam"), "No Gundam on AF site: [$web]")
	}

	Void testNoMiddleware() {
		verifyErrTypeAndMsg(ArgErr#, ErrMsgs.middlewareNotSupplied) {
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

		but	= MyButterDish(Butter.churnOut)
		verifyEq(but->httpTerminator->typeof, HttpTerminator#)
	}
}

internal class MyButterDish : FollowRedirectsDish {
	override Butter butter
	new make(Butter butter) { this.butter = butter }
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
		return ButterResponse(200, "OK", [:], "")
	}
}

