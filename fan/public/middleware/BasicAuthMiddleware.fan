
** (Middleware) - Converts user info in the request URL to a 'BASIC' Authentication HTTP header.
** 
** Example, a HTTP request of:
** 
** pre>
** GET http://tony:fish@www.alienfactory.co.uk/secret.zip HTTP/1.1
** Host: www.alienfactory.co.uk
** <pre
** 
** is converted to:
** 
** pre>
** GET http://www.alienfactory.co.uk/secret.zip HTTP/1.1
** Host: www.alienfactory.co.uk
** Authorization: BASIC dG9ueTpmaXNo
** <pre
class BasicAuthMiddleware : ButterMiddleware {
	
	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		userInfo := req.url.userInfo
		if (userInfo != null) {
			url := ""
			if (req.url.scheme != null)
				url += req.url.scheme
			if (req.url.auth != null)
				url += req.url.auth
			if (req.url.pathStr.trimToNull != null)
				url += req.url.pathStr
			if (req.url.queryStr != null)
				url += "?" + req.url.queryStr
			if (req.url.frag != null)
				url += "#" + req.url.frag
			
			req.url = url.toUri
			req.headers.authorization = "BASIC " + userInfo.toBuf.toBase64 
		}
		
		return butter.sendRequest(req)
	}
}
