

class FollowRedriectsMiddleware : ButterMiddleware {
	Bool followRedirects
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		return butter.sendRequest(req)
	}
}
 

mixin FollowRedriectsDish : ButterDish {

	Bool followRedirects() {
		followRedriectsMw.followRedirects
	}	

	private FollowRedriectsMiddleware followRedriectsMw() {
		findMiddleware(FollowRedriectsMiddleware#)
	}	
}