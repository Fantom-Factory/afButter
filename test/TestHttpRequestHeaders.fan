
internal class TestHttpRequestHeaders : ButterTest {
	
	Void testHost() {
		headers := HttpRequestHeaders()
		
		headers.host = `www.alienfactory.co.uk:8069`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk:8069")
		
		headers.host = `www.alienfactory.co.uk:80`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		headers.host = `www.alienfactory.co.uk`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		headers.host = `www.alienfactory.co.uk/`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		headers.host = `http://www.alienfactory.co.uk`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		headers.host = `http://www.alienfactory.co.uk/`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		headers.host = `http://www.alienfactory.co.uk/wotever`
		verifyEq(headers.map["Host"], "www.alienfactory.co.uk")
		
		verifyErrMsg(ArgErr#, ErrMsgs.hostNotDefined(`:8080`)) {
			headers.host = `:8080`
		}
	}
}
