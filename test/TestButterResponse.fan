
internal class TestButterResponse : ButterTest {
	
	Void testHttpRes() {
		// in the wilds, I've seen some crazy non-standard HTTP responses!
		res := ButterResponse.makeFromInStream("HTTP/1.1 307\r\nhttps://epdf.tips/download/researching-amp-writing-a-dissertation-an-essential-guide-for-business-students-.html\r\n\r\n".toBuf.in)
		verifyEq(res.statusCode, 307)
		verifyEq(res.statusMsg, "")		
	}
}
