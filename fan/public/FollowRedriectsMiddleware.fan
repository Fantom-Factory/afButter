

class FollowRedriectsMiddleware : ButterMiddleware {
	Bool followRedirects
	override ButterRes doRequest(Butter butter, ButterReq req) {
		return butter.doRequest(req)
	}
}
 

mixin FollowRedriectsMiddlewareHelper : ButterHelper {
	
	Bool followRedirects() {
		(findMiddleware(FollowRedriectsMiddleware#) as FollowRedriectsMiddleware).followRedirects
	}	
}