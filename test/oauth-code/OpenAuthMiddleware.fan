using web::WebUtil

** (Bonus!) Middleware for signing HTTP requests as per the [OAuth Protocol 1.0a]`http://tools.ietf.org/html/rfc5849`.
** 
** 'OpenAuthMiddleware' automatically signs all HTTP requests with the given credentials as per the OAuth 1.0 
** Specification.
** 
** Here is an awesome guide on [How To Sign HTTP Requests With OAuth 1.0]`http://hueniverse.com/oauth/guide/authentication/`.
** 
** Note that 'OpenAuthMiddleware' is *NOT* part of the default 'Butter' stack. To use, you must create your own:
** 
** pre>
** middlewareStack := [
**     ...
**     ...
**     OpenAuthMiddleware("key", "secret"),
**     HttpTerminator()
** ]
** butter := Butter.churnOut(middlewareStack)
** <pre
** 
** Because 'OpenAuthMiddleware' signs the HTTP parameters, it must come just before the 'Terminator' or after all the
** headers have been set.
class OpenAuthMiddleware : ButterMiddleware {
	
	internal 	OpenAuthTimestampGen	timestampGen	:= OpenAuthTimestampGen()
	@NoDoc		OpenAuthNonceGen 		nonceGen		:= OpenAuthNonceGen()
	
	Str consumerKey
	Str consumerSecret
	
	new make(Str consumerKey, Str consumerSecret, |This|? in := null) {
		this.consumerKey 	= consumerKey
		this.consumerSecret	= consumerSecret
		in?.call(this) 
	}
	
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {

		seconds	:= timestampGen.generate
		nonce	:= nonceGen.generate(seconds)

		req.headers["Authorization"] = generateAuthorizationHeader(req.url, req.method, consumerKey, consumerSecret, nonce, seconds, "HMAC-SHA1")
		
		return butter.sendRequest(req)
	}
	
	// TODO: if works, move to a service!
	static Str generateAuthorizationHeader(Uri reqUrl, Str reqMethod, Str consumerKey, Str consumerSecret, Str nonce, Int timestamp, Str signatureMethod) {
		oauthParams	:= OpenAuthParams()
		oauthParams["oauth_version"]			= "1.0"
		oauthParams["oauth_timestamp"]			= timestamp.toStr
		oauthParams["oauth_nonce"]				= nonce
		oauthParams["oauth_consumer_key"]		= consumerKey
		oauthParams["oauth_signature_method"]	= "HMAC-SHA1"	// TODO: OAuth have PLAINTEXT option
		
		tokenKey    := "nnch734d00sl2jdk"
		tokenSecret := "pfkkdhi9sl3r4s00"
		oauthParams["oauth_token"]= tokenKey	
		
		reqUrl.query.each |val, key| { 
			oauthParams[key] = val
		}

		normalizedUri		:= normalizeUri(reqUrl)
		normalizedParams	:= oauthParams.queryStr
		signatureBaseStr	:= OpenAuthParams.percentEscape(reqMethod) + "&" + 
							   OpenAuthParams.percentEscape(normalizedUri) + "&" + 
							   OpenAuthParams.percentEscape(normalizedParams)
		secretKey			:= consumerSecret + "&"	+ tokenSecret
		signature			:= signatureBaseStr.toBuf.hmac("SHA-1", secretKey.toBuf).toBase64

		oauthParams["oauth_signature"] 	= signature		
		return oauthParams.headerStr
	}
	
	private static Str normalizeUri(Uri uri) {
		scheme 		:= uri.scheme
		authority	:= uri.auth.lower
		path 		:= uri.pathStr
        return scheme + "://" + authority + path
    }
}


