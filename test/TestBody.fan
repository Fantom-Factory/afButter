
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
		verifyEq(body.str,		null)
		verifyEq(body.form,		null)
		verifyEq(body.jsonObj,	null)
		verifyEq(body.jsonMap,	null)

		body.str = null
		verifyEq(body.str,		null)
		
		body.form = null
		verifyEq(body.form, 	null)
		
		body.jsonObj = null
		verifyEq(body.jsonObj, 	null)
		
		body.jsonMap = null
		verifyEq(body.jsonMap,	null)		

		
		body.buf = null
		body.str = "Dude!"
		verifyEq(body.str,		"Dude!")
		body.str = "Dude!"
		verifyEq(body.str,		"Dude!")
		
		body.buf = null
		body.form = ["wot":"ever"]
		verifyEq(body.form,		["wot":"ever"])
		body.form = ["wot":"ever"]
		verifyEq(body.form,		["wot":"ever"])
		
		body.buf = null
		body.jsonObj = 69
		verifyEq(body.jsonObj,	69)
		body.jsonObj = 69
		verifyEq(body.jsonObj,	69)
		
		body.buf = null
		body.jsonMap = ["wot":"ever"]
		verifyEq(body.jsonMap, Str:Obj?["wot":"ever"])
		body.jsonMap = ["wot":"ever"]
		verifyEq(body.jsonMap, Str:Obj?["wot":"ever"])
	}
	
	Void testReset() {
		body := Body.makeForReq(HttpRequestHeaders([:]))
		body.str = "Hello Mum!"
		body.str = "Hello!"
		verifyEq(body.str, "Hello!")	// was "Hello!Mum!"
	}
}
