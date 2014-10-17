
** Worked examples from http://nouncer.com/oauth/authentication.html
internal class TestOpenAuthService : ButterTest {
	
	Void testOAuthSpec() {
		
		auth := OpenAuthMiddleware.generateAuthorizationHeader(`http://photos.example.net/photos?size=original&file=vacation.jpg`, "GET", "dpf43f3p2l4k3l03", "kd94hf93k423kf44", "kllo9940pd9333jh", 1191242096, "HMAC-SHA1")
		
		echo(auth)
	}
	
}
