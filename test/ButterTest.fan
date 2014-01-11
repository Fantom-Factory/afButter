
internal class ButterTest : Test {
	
	Void verifyButterErrMsg(Str errMsg, |Obj| func) {
		verifyTypeErrMsg(ButterErr#, errMsg, func)
	}

	protected Void verifyTypeErrMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(69)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				throw Err("Expected $errType got $e.typeof", e)
			msg := e.msg
			if (msg != errMsg)
				verifyEq(errMsg, msg)	// this gives the Str comparator in eclipse
			return
		}
		throw Err("$errType not thrown")
	}
}
