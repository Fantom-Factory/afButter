
internal class TestHttps : ButterTest {
	
	Void testHttps() {
		// just make sure we can create a TLS Socket - given Fantom broke backwards compatibility in Fantom 1.0.77
		res := Butter.churnOut.get(`https://www.google.com/`)
		verifyEq(res.statusCode, 200)
	}
}
