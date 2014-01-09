

mixin Butter {
	abstract ButterRes doReq(Uri uri, Str method := "GET")

	abstract ButterRes doRequest(ButterReq req)	
	
	abstract ButterMiddleware findMiddleware(Type middlewareType)
	
	static Butter churnOut(ButterMiddleware[] middleware) {
		return ButterChain(middleware)
	}
}


