
internal class TestButterRequest : ButterTest {
	
	Void testHost() {
		
		host := ButterRequest._normaliseHost(`www.alienfactory.co.uk:8069`)
		verifyEq(host, "www.alienfactory.co.uk:8069")
		
		host = ButterRequest._normaliseHost(`www.alienfactory.co.uk:80`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk:443")
		
		host = ButterRequest._normaliseHost(`https://www.alienfactory.co.uk:443`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`http://www.alienfactory.co.uk`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`http://www.alienfactory.co.uk/`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		host = ButterRequest._normaliseHost(`http://www.alienfactory.co.uk/wotever`)
		verifyEq(host, "www.alienfactory.co.uk")
		
		verifyErrMsg(ArgErr#, ErrMsgs.hostNotDefined(`:8080`)) {
			ButterRequest._normaliseHost(`:8080`)
		}
	}
}
