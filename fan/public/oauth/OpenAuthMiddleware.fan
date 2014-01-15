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
		oauthParams	:= OpenAuthParams()

		seconds	:= timestampGen.generate
		nonce	:= nonceGen.generate(seconds)
		
		oauthParams["oauth_version"]			= "1.0"
		oauthParams["oauth_timestamp"]			= seconds.toStr
		oauthParams["oauth_nonce"]				= nonce
		oauthParams["oauth_consumer_key"]		= consumerKey
		oauthParams["oauth_signature_method"]	= "HMAC-SHA1"	// TODO: OAuth have PLAINTEXT option
		
		req.uri.query.each |val, key| { 
			oauthParams[key] = val
		}

		normalizedUri		:= normalizeUri(req.uri)
		normalizedParams	:= oauthParams.queryStr
		signatureBaseStr	:= OpenAuthParams.percentEscape(req.method) + "&" + 
							   OpenAuthParams.percentEscape(normalizedUri) + "&" + 
							   OpenAuthParams.percentEscape(normalizedParams)
		secretKey			:= consumerSecret + "&"	// + tokenSecret
		signature			:= signatureBaseStr.toBuf.hmac("SHA-1", secretKey.toBuf).toBase64

		oauthParams["oauth_signature"] 	= signature
		req.headers["Authorization"] 	= oauthParams.headerStr
		
		return butter.sendRequest(req)
	}
	
	private Str normalizeUri(Uri uri) {
		scheme 		:= uri.scheme
		authority	:= uri.auth.lower
		path 		:= uri.pathStr
        return scheme + "://" + authority + path
    }
}


