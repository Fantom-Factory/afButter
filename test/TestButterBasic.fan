
internal class TestButterBasic : ButterTest {
	
	Void testButter() {
		
		butter := Butter.churnOut([
			FollowRedriectsMiddleware(), 
			HttpTerminator()
		])
		
		wrapper := MyButterWrapper(butter)
		
		echo(wrapper.followRedirects)
		
		wrapper.doReq(`http://www.alienfactory.co.uk`)
		
	}

	Void testNoMiddleware() {
		verifyTypeErrMsg(ArgErr#, ErrMsgs.middlewareNotSupplied) {
			but	:= Butter.churnOut([,])
		}
	}
	
	Void testNoTerminator() {
		but	:= Butter.churnOut([T_PassThroughMiddleware(StrBuf(), "")])
		verifyButterErrMsg(ErrMsgs.terminatorNotFound(T_PassThroughMiddleware#)) {
			but.doReq(`/`)
		}
	}
	
	Void testMiddlewareStack() {
		stack := StrBuf()
		but	:= Butter.churnOut([
			T_PassThroughMiddleware(stack, "1"),
			T_PassThroughMiddleware(stack, "2"),
			T_NullTerminator(stack, "3")
		])

		but.doReq(`/`)
		verifyEq(stack.toStr, "12321")

		but.doReq(`/`)
		verifyEq(stack.toStr, "1232112321")
	}
	
}

internal class MyButterWrapper : ButterHelper, FollowRedriectsMiddlewareHelper {
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
	override ButterRes doRequest(Butter butter, ButterReq req) {
		stack.add(id)
		res := butter.doRequest(req)
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
	override ButterRes doRequest(Butter butter, ButterReq req) {
		stack.add(id)
		return ButterRes()
	}
}
