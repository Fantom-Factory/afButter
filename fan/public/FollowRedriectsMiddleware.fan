

class FollowRedriectsMiddleware : ButterMiddleware {
	Bool followRedirects
	override ButterRes doReq(ButterReq req, Butter butter) {
		return butter.doReq(req)
	}
}
 

mixin FollowRedriectsMiddlewareHelper : ButterHelper {
	
	Bool followRedirects() {
		(findMiddleware(FollowRedriectsMiddleware#) as FollowRedriectsMiddleware).followRedirects
	}	
}