
** (Middleware) - Automatically un-gzips HTTP response content.
** 
** Adds 'gzip' as an accepted encoding in the HTTP request header. 
** Should the response then be gzip encoded, the 'body' of the response is replaced with a decoded version. 
class GzipMiddleware : ButterMiddleware {
	
	** Set to 'false' to disable this middleware instance. 
	Bool enabled	:= true

	private static const Version webVer := Pod.find("web").version

	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!enabled)
			return butter.sendRequest(req)
		
		encs := req.headers.acceptEncoding ?: QualityValues()
		if (!encs.accepts("gzip"))
			req.headers.acceptEncoding = encs.set("gzip", 1.0f)
		
		res := butter.sendRequest(req)

		res.body.buf = deGzipResponse(res)

		return res
	}
	
	internal static Buf? deGzipResponse(ButterResponse res) {
		// because v1.0.67 auto de-gzips the response, we don't have to
		if (res.headers.contentEncoding?.equalsIgnoreCase("gzip") ?: false)
			// we may still have have to un-gzip the response if web::WebUtil wasn't used to decode the stream
			// e.g. if a afBounce::BedTerminator was used.  
			// reduce the number of false positives by checking for a magic number first: http://en.wikipedia.org/wiki/Gzip
			if (res.body.buf != null && res.body.buf.size >= 10 && res.body.buf.get(0) == 0x1f && res.body.buf.get(1) == 0x8b)
				try return Zip.gzipInStream(res.body.buf.seek(0).in).readAllBuf
				catch (Err err) { /* pfft - so it wasn't a gzip, so what!? */ }
		
		// no change
		return res.body.buf
	}
}
