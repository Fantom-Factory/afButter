
internal class ButterChain : Butter {
	private ButterMiddleware[]	middleware
	private Int?				depth
	
	new make(ButterMiddleware[] middleware) {
		if (middleware.isEmpty)
			throw ArgErr(ErrMsgs.middlewareNotSupplied)

		this.middleware = middleware
	}

	override ButterRes doReq(Uri uri, Str method := "GET") {
		doRequest(ButterReq(uri, method))
	}

	override ButterRes doRequest(ButterReq req)	{
		depth = (depth == null) ? 0 : depth + 1
		try {
			if (depth >= middleware.size) 
				// throw 'cos what can we return?
				throw ButterErr(ErrMsgs.terminatorNotFound(middleware.last.typeof))
			
			return middleware[depth].doRequest(this, req)
			
		} finally {
			depth = (depth == 0) ? null : depth - 1
		}
	}
	
	override ButterMiddleware findMiddleware(Type middlewareType) {
		middleware.findType(middlewareType).first
	}
}