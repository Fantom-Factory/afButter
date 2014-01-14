
** Middleware that automatically resubmits requests on redirect responses.
class FollowRedirectsMiddleware : ButterMiddleware {
	private static const Log 	log				:= Utils.getLog(FollowRedirectsMiddleware#)
	private static const Int[]	redirectCodes	:= [301, 302, 303, 307]
	
	** Set to 'true' to follow redirects.
	** 
	** Defaults to 'true'.
	Bool enabled	:= true
	
	** How many redirects are too many? This number answers the question. 
	** An Err is raised should the number of redirects reach this number for a single request. 
	** 
	** Defaults to '20', as does [Firefox and Chrome]`http://stackoverflow.com/questions/9384474/in-chrome-how-many-redirects-are-too-many#answer-9384762`.
	Int tooManyRedirects	:= 20
	
	** Do dat ting.
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
			
			locations.add(req.uri)
			res = butter.sendRequest(req)
			redirect = false

			if (redirectCodes.contains(res.statusCode)) {
				if (res.headers.location == null)
					log.warn(LogMsgs.redirectGivenWithNoLocation(res.statusCode))
				else {
					if (res.statusCode == 301)
						req.uri = res.headers.location
					if (res.statusCode == 302 && res.version == Butter.http10) {
						req.uri = res.headers.location
						req.method = "get"
					}
					if (res.statusCode == 302 && res.version == Butter.http11) {
						req.uri = res.headers.location
					}
					if (res.statusCode == 303) {
						req.uri = res.headers.location
						req.method = "get"
					}
					if (res.statusCode == 307)
						req.uri = res.headers.location
					
					redirect = true
				}
			}
		}
		
		return res
	}
}
