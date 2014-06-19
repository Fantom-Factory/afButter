using web::Cookie

internal class TestGzipMiddleware : ButterTest {
	
	Void testAcceptGzipHeaderIsAdded() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, "", [:], "")
		end := MockTerminator([res])
		mw	:= GzipMiddleware()
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		
		mw.sendRequest(end, req)		
		
		verify(req.headers.acceptEncoding.accepts("gzip"))
	}

	Void testIgnoresNonGzip() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, "", ["Content-Encoding":"zip"], "Piddles")
		end := MockTerminator([res])
		mw	:= GzipMiddleware()
		
		res = mw.sendRequest(end, req)		
		
		verifyEq(res.asStr, "Piddles")
	}

	Void testDecodesTheResponse() {
		req := ButterRequest(`/`)
		res := ButterResponse(200, "OK", ["Content-Encoding":"gzip"], "") {
			it.body = Buf()
			Zip.gzipOutStream(it.body.out).print("Moar Coffee!!!").flush.close
			it.body.flip
		}
		end := MockTerminator([res])
		mw	:= GzipMiddleware()

		res = mw.sendRequest(end, req)		
		
		verifyEq(res.asStr, "Moar Coffee!!!")
	}
	
	Void testDoesNothingWhenDisabled() {
		res := ButterResponse(200, "", ["Content-Encoding":"gzip"], "not encoded")
		end := MockTerminator([res])
		mw	:= GzipMiddleware() { it.enabled = false }
		req := ButterRequest(`/`)
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		
		mw.sendRequest(end, req)		
		
		verifyFalse(req.headers.acceptEncoding?.accepts("gzip") ?: false)
		verifyEq(res.asStr, "not encoded")
	}


}

