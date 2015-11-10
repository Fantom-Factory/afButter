
** @see http://oauth.googlecode.com/svn/code/javascript/example/signature.html
internal class TestOpenAuthParams : ButterTest {
	
	Void testDuplicateParams() {
		params := OpenAuthParams()
		params["judge"] = "dredd"
		
		verifyErrMsg(ArgErr#, OpenAuthMsgs.duplicateParamsNotSuppored("judge", "dredd", "anderson")) {
			params["judge"] = "anderson"			
		}
	}
	
	Void testQueryStrParamsAreAlphaSorted() {
		params := OpenAuthParams()
		params["z"] 	= "x"
		params["name"] 	= "value2"
		params["abc"] 	= "abc"
		
		verifyEq(params.queryStr, "abc=abc&name=value2&z=x")
	}

	Void testHeaderStrOnlyContainsOAuthParams() {
		params := OpenAuthParams()
		params["z"] 			= "x"
		params["oauth_stuff"] 	= "very important"
		params["abc"] 			= "abc"
		
		verifyEq(params.headerStr, "OAuth oauth_stuff=\"very%20important\"")
	}
	
	Void testPercentEncodingEncodes() {
		// all chars should be encoded
		verifyEq(OpenAuthParams.percentEscape("!*'()@:\$,;/?:` âÕ÷ÚÊ+"), "%21%2A%27%28%29%40%3A%24%2C%3B%2F%3F%3A%60%20%C3%A2%C3%95%C3%B7%C3%9A%C3%8A%2B")
	}

	Void testPercentEncodingUnicode() {
		// examples from https://en.wikipedia.org/wiki/UTF-8
		verifyEq(OpenAuthParams.percentEscape("\u0024" ), "%24")
		verifyEq(OpenAuthParams.percentEscape("\u00a2" ), "%C2%A2")
		verifyEq(OpenAuthParams.percentEscape("\u20ac" ), "%E2%82%AC")
		buf := StrBuf()
		OpenAuthParams.percentEncodeUtf8Char(buf, 0x10348)
		verifyEq(buf.toStr, "%F0%90%8D%88")
		
		// examples from https://tools.ietf.org/html/rfc3629#section-7
		verifyEq(OpenAuthParams.percentEscape("\u2262\u0391"      ), "%E2%89%A2%CE%91")
		verifyEq(OpenAuthParams.percentEscape("\uD55C\uAD6D\uC5B4"), "%ED%95%9C%EA%B5%AD%EC%96%B4")
		verifyEq(OpenAuthParams.percentEscape("\u65E5\u672C\u8A9E"), "%E6%97%A5%E6%9C%AC%E8%AA%9E")
		buf = StrBuf()
		OpenAuthParams.percentEncodeUtf8Char(buf, 0x233B4)
		verifyEq(buf.toStr, "%F0%A3%8E%B4")
		
	}

	Void testPercentEncodingDoeNotEncode() {
		// no chars should be encoded
		verifyEq(OpenAuthParams.percentEscape("-_.~ABCDEF...Zabcdef...z0123456789"), "-_.~ABCDEF...Zabcdef...z0123456789")
	}
}

		