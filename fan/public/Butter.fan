

internal class ButterChain : Butter {
	private ButterMiddleware[]	middleware
	private Int?				depth
	
	new make(ButterMiddleware[] middleware) {
		this.middleware = middleware
	}
	
	override ButterRes doReq(ButterReq req)	{
		depth = (depth == null) ? 0 : depth + 1
		try {

			// TODO: test!
			if (depth >= middleware.size) {
				// log.warn Terminator not supplied / middleare type is not a terminator
				throw Err()
				// throw 'cos what can we return?
			}
			
			return middleware[depth].doReq(req, this)
			
		} finally {
			depth = (depth == 0) ? null : depth - 1
		}
	}
	
	override ButterMiddleware findMiddleware(Type middlewareType) {
		middleware.findType(middlewareType).first
	}
}



mixin Butter {
	abstract ButterRes doReq(ButterReq req)	
	
	abstract ButterMiddleware findMiddleware(Type middlewareType)
	
	static Butter churnOut(ButterMiddleware[] middleware) {
		return ButterChain(middleware)
	}
}

mixin ButterMiddleware {
	abstract ButterRes doReq(ButterReq req, Butter butter)
}

mixin ButterHelper : Butter {
	
	abstract Butter butter
	
	override ButterRes doReq(ButterReq req) {
		butter.doReq(req)
	}

	override ButterMiddleware findMiddleware(Type middlewareType) {
		return butter.findMiddleware(middlewareType)
	}
}
