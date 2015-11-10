
** Worked examples from http://nouncer.com/oauth/authentication.html
internal class TestOpenAuthService : ButterTest {
	
	Void testOAuthSpec() {
		
		// Example used in the OAuth Specification
		clientKey	:= "dpf43f3p2l4k3l03"
		clientSecret:= "kd94hf93k423kf44"
		tokenKey    := "nnch734d00sl2jdk"
		tokenSecret := "pfkkdhi9sl3r4s00"
		nonce		:= "kllo9940pd9333jh"
		timestamp	:= 1191242096
		url			:= `http://photos.example.net/photos?size=original&file=vacation.jpg`
		method		:= "GET"
		authHeader	:= OpenAuthMiddleware.generateAuthorizationHeader(url, method, clientKey, clientSecret, tokenKey, tokenSecret, nonce, timestamp, "HMAC-SHA1")
		verifyEq(authHeader, """OAuth oauth_consumer_key="dpf43f3p2l4k3l03", oauth_nonce="kllo9940pd9333jh", oauth_signature="tR3%2BTy81lMeYAr%2FFid0kMTYa%2FWM%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1191242096", oauth_token="nnch734d00sl2jdk", oauth_version="1.0" """.trimEnd)
		
		// Non URL-Safe Parameter
		clientKey	= "dpf43f3++p+#2l4k3l03"
		clientSecret= "kd9@4h%%4f93k423kf44"
		tokenKey    = "nnch734d(0)0sl2jdk"
		tokenSecret = "pfkkd#hi9_sl-3r=4s00"
		nonce		= "kllo~9940~pd9333jh"
		timestamp	= 1191242096
		url			= `http://PHOTOS.example.net:8001/Photos?photo size=300%&title=Back of \$100 Dollars Bill`
		method		= "GET"
		authHeader	= OpenAuthMiddleware.generateAuthorizationHeader(url, method, clientKey, clientSecret, tokenKey, tokenSecret, nonce, timestamp, "HMAC-SHA1")
		verifyEq(authHeader, """OAuth oauth_consumer_key="dpf43f3%2B%2Bp%2B%232l4k3l03", oauth_nonce="kllo~9940~pd9333jh", oauth_signature="tTFyqivhutHiglPvmyilZlHm5Uk%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1191242096", oauth_token="nnch734d%280%290sl2jdk", oauth_version="1.0" """.trimEnd)
		
//		// Non-English Parameter
//		clientKey	= "dpf43f3++p+#2l4k3l03"
//		clientSecret= "kd9@4h%%4f93k423kf44"
//		tokenKey    = "nnch734d(0)0sl2jdk"
//		tokenSecret = "pfkkd#hi9_sl-3r=4s00"
//		nonce		= "kllo~9940~pd9333jh"
//		timestamp	= 1191242096
//		url			= `http://PHOTOS.example.net:8001/Photos?type=××•×˜×•×‘×•×¡%&scenario=×ª××•× ×”`	// not sure these are cut'n'pasted properly
//		method		= "GET"
//		authHeader	= OpenAuthMiddleware.generateAuthorizationHeader(url, method, clientKey, clientSecret, tokenKey, tokenSecret, nonce, timestamp, "HMAC-SHA1")
//		verifyEq(authHeader, """OAuth oauth_consumer_key="dpf43f3%2B%2Bp%2B%232l4k3l03", oauth_nonce="kllo~9940~pd9333jh", oauth_signature="MH9NDodF4I%2FV6GjYYVChGaKCtnk%3D" oauth_signature_method="HMAC-SHA1", oauth_timestamp="1191242096", oauth_token="nnch734d%280%290sl2jdk", oauth_version="1.0" """.trimEnd)
	}
}
