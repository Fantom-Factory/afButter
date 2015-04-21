
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
	
}
