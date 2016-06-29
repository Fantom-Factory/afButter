
internal class TestButterRequest : ButterTest {
	
	Void testHost() {
		
		host := ButterRequest.normaliseHost(`www.alienfactory.co.uk:8069`)
		verifyEq(host, "www.alienfactory.co.uk:8069")
		
		host = ButterRequest.normaliseHost(`www.alienfactory.co.uk:80`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk:443")
		
		host = ButterRequest.normaliseHost(`https://www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`http://www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`http://www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest.normaliseHost(`http://www.alienfactory.co.uk/wotever`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		verifyErrMsg(ArgErr#, ErrMsgs.hostNotDefined(`:8080`)) {
			ButterRequest.normaliseHost(`:8080`)
		}
	}
}
