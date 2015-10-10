
** (Middleware) - Automatically resubmits requests on redirect responses.
class FollowRedirectsMiddleware : ButterMiddleware {
	private static const Log 	log				:= Utils.getLog(FollowRedirectsMiddleware#)
	private static const Int[]	redirectCodes	:= [301, 302, 303, 307, 308]
	
	** Set to 'true' to follow redirects.
	** 
	** Defaults to 'true'.
	Bool enabled	:= true
	
	** How many redirects are too many? This number answers the question. 
	** An Err is raised should the number of redirects reach this number for a single request. 
	** 
	** Defaults to '20', as does [Firefox and Chrome]`http://stackoverflow.com/questions/9384474/in-chrome-how-many-redirects-are-too-many#answer-9384762`.
	Int tooManyRedirects	:= 20
	
	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		ButterResponse? res := null

		if (!enabled)
			return butter.sendRequest(req)
		
		// +1 for the original req uri
		locations := Uri[,] { it.capacity = tooManyRedirects + 1 }
		redirect := true
		redirectCount := 0
		while (redirect) {
			if (redirectCount++ > tooManyRedirects)
				throw ButterErr(ErrMsgs.tooManyRedirects(tooManyRedirects), locations)
			
			locations.add(req.url)
			res = butter.sendRequest(req)
			redirect = false

			if (redirectCodes.contains(res.statusCode)) {
				if (res.headers.location == null)
					log.warn(LogMsgs.redirectGivenWithNoLocation(res.statusCode))
				else {
					newUrl := res.headers.location

					if (newUrl.scheme == null && newUrl.auth == null && newUrl.pathStr.isEmpty.not && newUrl.isPathAbs.not)
						newUrl = req.url + newUrl
					
					if (newUrl.auth == null && req.url.auth != null)
						newUrl = req.url.auth.toUri.plusSlash + newUrl.relTo(`/`)

					if (newUrl.scheme == null && req.url.scheme != null)
						newUrl = `${req.url.scheme}://${newUrl}`

					req.url = newUrl
					req.headers.host = res.headers.location.host
					redirect = true
					
					if (303 == res.statusCode)
						req.method = "get"
					
					if ([301, 302].contains(res.statusCode) && res.version == Butter.http10)
						req.method = "get"
					
					// Should we store permanent redirects and auto-change the req url?
					// Naa, that's web browser behaviour to speed up page rendering.
					// We're just mooching around the net!
				}
			}
		}
		
		return res
	}
}
