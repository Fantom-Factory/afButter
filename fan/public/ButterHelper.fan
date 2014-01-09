

mixin ButterHelper : Butter {
	
	abstract Butter butter
	
	override ButterRes doReq(Uri uri, Str method := "GET") {
		butter.doReq(uri, method)
	}

	override ButterRes doRequest(ButterReq req) {
		butter.doRequest(req)
	}

	override ButterMiddleware findMiddleware(Type middlewareType) {
		return butter.findMiddleware(middlewareType)
	}
}
