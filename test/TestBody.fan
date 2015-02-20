
internal class TestBody : ButterTest {
	
	Void testReq() {
		body := Body.makeForReq(HttpRequestHeaders())
		
		verifyNull(body.str)
		verifyNull(body.jsonObj)
		verifyNull(body.buf)
//		verifyNull(body.in)
//		verifyNull(body.out)
		
		body.jsonObj = 69
		
		verifyEq(body.str, "69")
		verifyEq(body.jsonObj, 69)
		verifyEq(body.buf.readAllStr, "69")
//		verifyEq(body.in.readAllStr, "69")
//		verifyErr(Err#) { body.out.toStr }
	}

	Void testRes() {
		body := Body(HttpResponseHeaders(), "")

		verifyNull(body.str)
		verifyNull(body.jsonObj)
		verifyNull(body.buf)
//		verifyNull(body.in)
//		verifyNull(body.out)
	}
}
