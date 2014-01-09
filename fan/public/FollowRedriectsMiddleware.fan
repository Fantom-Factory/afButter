

class FollowRedriectsMiddleware : ButterMiddleware {
	Bool followRedirects
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		return butter.sendRequest(req)
	}
}
 

mixin FollowRedriectsMiddlewareHelper : ButterHelper {
	
	Bool followRedirects() {
		(findMiddleware(FollowRedriectsMiddleware#) as FollowRedriectsMiddleware).followRedirects
	}	
}