

mixin ButterHelper : Butter {
	
	abstract Butter butter
	
	override ButterResponse get(Uri uri) {
		butter.get(uri)
	}

	override ButterResponse sendRequest(ButterRequest req) {
		butter.sendRequest(req)
	}

	override ButterMiddleware findMiddleware(Type middlewareType) {
		return butter.findMiddleware(middlewareType)
	}
}
