
internal class TestOpenAuthMiddleware : ButterTest {
	
	Void testSignRequest() {
		mw	:= OpenAuthMiddleware("key", "secret")
		mw.timestampGen = OpenAuthTimestampGenStub()
		mw.nonceGen		= OpenAuthNonceGenStub()
		
		res := ButterResponse(200, "", [:], Buf())
		end := MockTerminator([res])		
		req	:= ButterRequest(`http://yboss.yahooapis.com/ysearch/web?q=yahoo&format=xml`)
		
		mw.sendRequest(end, req)
		
		verifyEq(req.headers.map.size, 1)
		verifyEq(req.headers["Authorization"], Str<|OAuth oauth_consumer_key="key", oauth_nonce="dMEVdXmIzpdK", oauth_signature="3mwCzCORDFl3AYgKnetTYir1fbM%3D", oauth_signature_method="HMAC-SHA1", oauth_timestamp="1368988686", oauth_version="1.0"|>)
	}
	
	Void testAgainstRealServer() {
		consumerKey		:= "key"
		consumerSecret	:= "secret"
		
		query	:= Uri.encodeQuery(["Cats and dogs":null])
		qMap	:= ["format":"json", "q":query]

		client	:= ButterDish(Butter.churnOut([
			OpenAuthMiddleware(consumerKey, consumerSecret),
			ErrOn5xxMiddleware(),
			HttpTerminator()
		]))

		req	:= `http://term.ie/oauth/example/request_token.php`.plusQuery(qMap)
		res := client.get(req)
		
		boss := res.asStr
		verifyEq("oauth_token=requestkey&oauth_token_secret=requestsecret", res.asStr) 
	}
}

internal class OpenAuthNonceGenStub : OpenAuthNonceGen {
	override Str generate(Int secondsSinceUnixEpoch) { "dMEVdXmIzpdK" }
}

internal class OpenAuthTimestampGenStub : OpenAuthTimestampGen {
	override Int generate() { 1368988686 }
}