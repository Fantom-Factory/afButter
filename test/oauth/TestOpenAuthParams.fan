
** @see http://oauth.googlecode.com/svn/code/javascript/example/signature.html
internal class TestOpenAuthParams : ButterTest {
	
	Void testDuplicateParams() {
		params := OpenAuthParams()
		params["judge"] = "dredd"
		
		verifyErrTypeAndMsg(ArgErr#, OpenAuthMsgs.duplicateParamsNotSuppored("judge", "dredd", "anderson")) {
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
		verifyEq(OpenAuthParams.percentEscape("!*'()@:\$,;/?:` âÕ÷ÚÊ+"), "%21%2A%27%28%29%40%3A%24%2C%3B%2F%3F%3A%60%2B%C3%A2%C3%95%C3%B7%C3%9A%C3%8A%2B")
	}

	Void testPercentEncodingDoeNotEncode() {
		// no chars should be encoded
		verifyEq(OpenAuthParams.percentEscape("-_.~ABCDEF...Zabcdef...z0123456789"), "-_.~ABCDEF...Zabcdef...z0123456789")
	}
}
