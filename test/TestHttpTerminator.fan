
internal class TestHttpTerminator : ButterTest {
	
	Void testHost() {
		
		host := HttpTerminator.normaliseHost(`www.alienfactory.co.uk:8069`)
		verifyEq(host, "www.alienfactory.co.uk:8069")
		
		host = HttpTerminator.normaliseHost(`www.alienfactory.co.uk:80`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk:443")
		
		host = HttpTerminator.normaliseHost(`https://www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`http://www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`http://www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = HttpTerminator.normaliseHost(`http://www.alienfactory.co.uk/wotever`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		verifyErrMsg(ArgErr#, ErrMsgs.hostNotDefined(`:8080`)) {
			HttpTerminator.normaliseHost(`:8080`)
		}
	}
}
