
class StickyHeadersMiddleware : ButterMiddleware {

	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		return butter.sendRequest(req)
	}
}

mixin StickyHeadersDish : ButterDish {

//	Bool followRedirects() {
//		followRedriectsMw.followRedirects
//	}	

	private StickyHeadersMiddleware cookieMw() {
		findMiddleware(StickyHeadersMiddleware#)
	}	
}