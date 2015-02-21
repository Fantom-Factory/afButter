
** (Middleware) - Automatically un-gzips HTTP response content.
** 
** Adds 'gzip' as an accepted encoding in the HTTP request header. 
** Should the response then be gzip encoded, the 'body' of the response is replaced with a decoded version. 
class GzipMiddleware : ButterMiddleware {
	
	** Set to 'false' to disable this middleware instance. 
	Bool enabled	:= true

	private const Version webVer := Pod.find("web").version

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!enabled)
			return butter.sendRequest(req)
		
		encs := req.headers.acceptEncoding ?: QualityValues()
		if (!encs.accepts("gzip"))
			req.headers.acceptEncoding = encs.set("gzip", 1.0f)
		
		res := butter.sendRequest(req)

		// because v1.0.67 auto de-gzips the response, we don't have to
		if (webVer < Version("1.0.67"))
			if (res.headers.contentEncoding?.equalsIgnoreCase("gzip") ?: false)
				res.body.buf = Zip.gzipInStream(res.body.buf.in).readAllBuf

		return res
	}
}
