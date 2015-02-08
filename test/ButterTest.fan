
internal class ButterTest : Test {
	
	Void verifyButterErrMsg(Str errMsg, |Obj| func) {
		verifyErrMsg(ButterErr#, errMsg, func)
	}

}
