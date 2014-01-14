
internal class ButterChain : Butter {
	override ButterMiddleware[]	middleware
	private Int?				depth
	
	new make(ButterMiddleware[] middleware) {
		if (middleware.isEmpty)
			throw ArgErr(ErrMsgs.middlewareNotSupplied)

		this.middleware = middleware.ro
	}

	override ButterResponse sendRequest(ButterRequest req)	{
		depth = (depth == null) ? 0 : depth + 1
		try {
			if (depth >= middleware.size) 
				// throw 'cos what can we return?
				throw ButterErr(ErrMsgs.terminatorNotFound(middleware.last.typeof))
			
			return middleware[depth].sendRequest(this, req)
			
		} finally {
			depth = (depth == 0) ? null : depth - 1
		}
	}
	
	override ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true) {
		middleware.findType(middlewareType).first ?: (checked ? throw ButterErr(ErrMsgs.chainMiddlewareNotFound(middlewareType.qname), middleware.map { it.typeof.qname }) : null) 
	}

}