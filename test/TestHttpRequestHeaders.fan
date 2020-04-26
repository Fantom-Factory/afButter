using web::Cookie

internal class TestHttpRequestHeaders : ButterTest {
	
	Void testCookies() {
		headers := HttpRequestHeaders()

		cookies := [Cookie("foo", "bar")]
		headers.cookie = cookies
		echo(cookies.first.val)
		verifyEq(cookies.first.val, "bar")		// "bar"  <-- it was this...

		cookies = headers.cookie
		headers.cookie = cookies
		echo(cookies.first.val)
		verifyEq(cookies.first.val, "bar")		// "\"bar\""  <-- then this...

		cookies = headers.cookie
		headers.cookie = cookies
		echo(cookies.first.val)
		verifyEq(cookies.first.val, "bar")		// "\"\\"bar\\"\""  <-- and then this!
	}
}
