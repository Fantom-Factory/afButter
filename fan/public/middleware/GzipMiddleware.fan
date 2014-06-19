
** (Middleware) - Automatically un-gzips HTTP response content.
** 
** Adds 'gzip' as an accepted encoding in the HTTP request header. 
** Should the response then be gzip encoded, the 'body' of the response is replaced with a decoded version. 
class GzipMiddleware : ButterMiddleware {
	
	** Set to 'false' to disable this middleware instance. 
	Bool enabled	:= true

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!enabled)
			return butter.sendRequest(req)
		
		encs := req.headers.acceptEncoding ?: QualityValues()
		if (!encs.accepts("gzip"))
			req.headers.acceptEncoding = encs.set("gzip", 1.0f)
		
		res := butter.sendRequest(req)

		if (res.headers.contentEncoding?.equalsIgnoreCase("gzip") ?: false)
			res.body = Zip.gzipInStream(res.asInStream).readAllBuf
		
		return res
	}
}
