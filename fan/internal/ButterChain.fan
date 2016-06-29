
internal class ButterChain : Butter {
	override ButterMiddleware[]	middleware
	private Int?				depth
	private const Log			log	:= this.typeof.pod.log
	
	new make(ButterMiddleware[] middleware) {
		if (middleware.isEmpty)
			throw ArgErr(ErrMsgs.middlewareNotSupplied)

		// there's no reason why this list should be read only
		this.middleware = middleware.rw
	}

	override ButterResponse sendRequest(ButterRequest req)	{
		depth = (depth == null) ? 0 : depth + 1
		try {
			if (depth >= middleware.size) 
				// throw 'cos what can we return?
				throw ButterErr(ErrMsgs.terminatorNotFound(middleware.last?.typeof))
			
			dump := log.isDebug && depth == middleware.size - 1
			if (dump && middleware[depth] is HttpTerminator)
				req._primeForSend	// ensure we dump *exactly* what's being sent
			if (dump)
				log.debug("\n\nButter Request:\n${req.dump}\n")
			
			// make the call!
			res := middleware[depth].sendRequest(this, req)
			
			if (dump)
				log.debug("\n\nButter Response:\n${res.dump}\n")
			return res
			
		} finally {
			depth = (depth == 0) ? null : depth - 1
		}
	}
	
	override ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true) {
		middleware.findType(middlewareType).first ?: (checked ? throw ButterErr(ErrMsgs.chainMiddlewareNotFound(middlewareType.qname), middleware.map { it.typeof.qname }) : null) 
	}
}