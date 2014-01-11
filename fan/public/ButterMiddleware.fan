
** Implement to define middleware for 'Butter'.
mixin ButterMiddleware {
	
	** The chained method. Call 'butter.sendRequest(req)' to propagate the method call down the chain to the terminator.  
	abstract ButterResponse sendRequest(Butter butter, ButterRequest req)

}
