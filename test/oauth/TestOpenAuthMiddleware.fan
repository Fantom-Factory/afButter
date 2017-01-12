
internal class TestOpenAuthMiddleware : ButterTest {
	
	Void testSignRequest() {
		mw	:= OpenAuthMiddleware("key", "secret")
		mw.timestampGen = OpenAuthTimestampGenStub()
		mw.nonceGen		= OpenAuthNonceGenStub()
		
		res := ButterResponse(200)
		end := MockTerminator([res])		
		req	:= ButterRequest(`http://yboss.yahooapis.com/ysearch/web?q=yahoo&format=xml`)
		mw.sendRequest(end, req)
	
		verifyEq(req.headers.map.size, 1)
		verifyEq(req.headers["Authorization"], Str<|OAuth oauth_consumer_key="key", oauth_nonce="dMEVdXmIzpdK", oauth_signature="3mwCzCORDFl3AYgKnetTYir1fbM%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1368988686", oauth_version="1.0"|>)
	}

	** @see http://term.ie/oauth/example/index.php
	Void testAgainstRealServer() {
		consumerKey		:= "key"
		consumerSecret	:= "secret"
		
		oauth	:= OpenAuthMiddleware(consumerKey, consumerSecret)
		qMap	:= ["format":"json", "q":"Cats and dogs"]

		client	:= ButterDish(Butter.churnOut([
			oauth,
			ErrOn5xxMiddleware(),
			HttpTerminator()
		]))
		
		

		// ---- Getting a Request Token ----
		req	:= `http://term.ie/oauth/example/request_token.php`
		res := client.get(req)
		verifyEq("oauth_token=requestkey&oauth_token_secret=requestsecret", res.body.str)

		
		
		// ---- Getting an Access Token ----
		oauth.tokenKey 	  = "requestkey"
		oauth.tokenSecret = "requestsecret"
		req	= `http://term.ie/oauth/example/access_token.php`.plusQuery(qMap)
		res = client.get(req)
		verifyEq("oauth_token=accesskey&oauth_token_secret=accesssecret", res.body.str)

		
		
		// ---- Making Authenticated Calls ----
		oauth.tokenKey 	  = "accesskey"
		oauth.tokenSecret = "accesssecret"
		req	= `http://term.ie/oauth/example/echo_api.php`.plusQuery(qMap)
		res = client.get(req)
		verifyEq("q=Cats+and+dogs&format=json", res.body.str)
	}
}

internal class OpenAuthNonceGenStub : OpenAuthNonceGen {
	override Str generate(Int secondsSinceUnixEpoch) { "dMEVdXmIzpdK" }
}

internal class OpenAuthTimestampGenStub : OpenAuthTimestampGen {
	override Int generate() { 1368988686 }
}