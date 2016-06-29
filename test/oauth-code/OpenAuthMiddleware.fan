using web::WebUtil

** (Bonus!) Middleware for signing HTTP requests as per the [OAuth Protocol 1.0a]`http://tools.ietf.org/html/rfc5849`.
** 
** 'OpenAuthMiddleware' automatically signs all HTTP requests with the given credentials as per the OAuth 1.0 
** Specification.
** 
** Here is an awesome guide on [How To Sign HTTP Requests With OAuth 1.0]`http://nouncer.com/oauth/authentication.html`.
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
	
	@NoDoc 	OpenAuthTimestampGen	timestampGen	:= OpenAuthTimestampGen()
	@NoDoc	OpenAuthNonceGen 		nonceGen		:= OpenAuthNonceGen()
	
	** The identifier portion of the client credentials (equivalent to a username)
				Str consumerKey
				Str consumerSecret

	** Optional
				Str? tokenKey
	** Optional
				Str? tokenSecret
	
	new make(Str consumerKey, Str consumerSecret, |This|? in := null) {
		this.consumerKey 	= consumerKey
		this.consumerSecret	= consumerSecret
		in?.call(this) 
	}
	
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		seconds	:= timestampGen.generate
		nonce	:= nonceGen.generate(seconds)

		req.headers["Authorization"] = generateAuthorizationHeader(req.url, req.method, consumerKey, consumerSecret, tokenKey, tokenSecret, nonce, seconds, "HMAC-SHA1")
		
		return butter.sendRequest(req)
	}
	
	static Str generateAuthorizationHeader(Uri reqUrl, Str reqMethod, Str consumerKey, Str consumerSecret, Str? tokenKey, Str? tokenSecret, Str nonce, Int timestamp, Str signatureMethod) {
		// TODO: support OAuth PLAINTEXT option
		if (signatureMethod != "HMAC-SHA1")
			throw UnsupportedErr("Only the following signature methods are supported: ${signatureMethod}")

		oauthParams	:= OpenAuthParams()
		oauthParams["oauth_consumer_key"]		= consumerKey
		oauthParams["oauth_nonce"]				= nonce
		oauthParams["oauth_timestamp"]			= timestamp.toStr
		oauthParams["oauth_signature_method"]	= "HMAC-SHA1"
		oauthParams["oauth_version"]			= "1.0"
		if (tokenKey != null)
			oauthParams["oauth_token"]			= tokenKey	
		
		reqUrl.query.each |val, key| { 
			oauthParams[key] = val
		}

		normalizedUri		:= normalizeUri(reqUrl)
		normalizedParams	:= oauthParams.queryStr
		signatureBaseStr	:= OpenAuthParams.percentEscape(reqMethod) + "&" + 
							   OpenAuthParams.percentEscape(normalizedUri) + "&" + 
							   OpenAuthParams.percentEscape(normalizedParams)
		secretKey			:= OpenAuthParams.percentEscape(consumerSecret) + "&" + (tokenSecret == null ? "" : OpenAuthParams.percentEscape(tokenSecret))
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


