using web::Cookie

internal class TestGzipMiddleware : ButterTest {
	
	Void testAcceptGzipHeaderIsAdded() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, null, "")
		end := MockTerminator([res])
		mw	:= GzipMiddleware()
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		
		mw.sendRequest(end, req)
		
		verify(req.headers.acceptEncoding.accepts("gzip"))
	}

	Void testIgnoresNonGzip() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, ["Content-Encoding":"zip"], "Piddles")
		end := MockTerminator([res])
		mw	:= GzipMiddleware()
		
		res = mw.sendRequest(end, req)		
		
		verifyEq(res.body.str, "Piddles")
	}

	// from web v1.0.67 this (sometimes) happens automatically
	Void testDecodesTheResponse() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, ["Content-Encoding":"gzip"], "") {
			Zip.gzipOutStream(it.body.buf.out).print("Moar Coffee!!!").flush.close
			it.body.buf.flip
		}
		end := MockTerminator([res])
		mw	:= GzipMiddleware()

		res = mw.sendRequest(end, req)		
		
		verifyEq(res.body.str, "Moar Coffee!!!")
	}
	
	Void testDoesNothingWhenDisabled() {
		res := ButterResponse(200, ["Content-Encoding":"gzip"], "not encoded")
		end := MockTerminator([res])
		mw	:= GzipMiddleware() { it.enabled = false }
		req := ButterRequest(`/`)
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		
		mw.sendRequest(end, req)		
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		verifyEq(res.body.str, "not encoded")
	}
}

