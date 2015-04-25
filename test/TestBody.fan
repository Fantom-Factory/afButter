
internal class TestBody : ButterTest {
	
	Void testBodyBuffer() {
		buf  := Buf().writeChars("Yo Homeboy, wot up!?")
		verify(buf.pos > 0)
		
		body := Body.makeForResStr(HttpResponseHeaders([:]), "Paddington")
		verifyEq(body.buf.pos, 0)

		body = Body.makeForResBuf(HttpResponseHeaders([:]), Buf().writeChars("Paddington"))
		verifyEq(body.buf.pos, 0)

		body = Body.makeForResIn(HttpResponseHeaders([:]), Buf().writeChars("Paddington").flip.in)
		verifyEq(body.buf.pos, 0)
	}
	
	
	Void testNullChecks() {
		body := Body.makeForReq(HttpRequestHeaders([:]))
		body.buf.clear
		verifyEq("",   			body.str)
		verifyEq(Str:Str[:],	body.form)
		verifyEq(null, 			body.jsonObj)
		verifyEq(Str:Obj?[:],	body.jsonMap)

		body.str 	 = null
		verifyEq("",   			body.str)
		
		body.form 	 = null
		verifyEq(Str:Str[:],	body.form)
		
		body.jsonObj = null
		verifyEq(null, 			body.jsonObj)
		
		body.jsonMap = null
		verifyEq(Str:Obj?[:],	body.jsonMap)		
	}
}
