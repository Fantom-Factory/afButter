
internal class TestBasicAuthMiddleware : ButterTest {
	
	Void testBasicAuth() {
		verifyReqUrl(`http://user:password@example.com:8080/path?query#frag`)
		verifyReqUrl(`http://user:password@example.com:8080/path?query`)
		verifyReqUrl(`http://user:password@example.com:8080/path`)
		verifyReqUrl(`http://user:password@example.com:8080/`)
		verifyReqUrl(`http://user:password@example.com:8080`)
		verifyReqUrl(`http://user:password@example.com`)
		verifyReqUrl(`//user:password@example.com`)
		verifyReqUrl(`//user:password@`)
		
		verifyReqUrl(`http://example.com:8080/path?query#frag`)		
		verifyReqUrl(`/path?query#frag`)
	}
	
	Void verifyReqUrl(Uri url) {
		mw		:= BasicAuthMiddleware()
		req		:= ButterRequest(url)
		butter	:= MockTerminator([ButterResponse(200)])
		
		mw.sendRequest(butter, req)
		if (req.url.userInfo != null)
			verifyEq(req.headers.authorization, "BASIC dXNlcjpwYXNzd29yZA==")
		verifyEq(req.url.toStr, req.url.toStr.replace("", "user:password@"))
	}
}
