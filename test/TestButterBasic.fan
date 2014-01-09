
class TestButterBasic : Test {
	
	Void testButter() {
		
		butter := Butter.churnOut([
			FollowRedriectsMiddleware(), 
			HttpTerminator()
		])
		
		wrapper := MyButterWrapper(butter)
		
		echo(wrapper.followRedirects)
		
		wrapper.doReq(ButterReq(`http://www.alienfactory.co.uk`))
		
	}
	
}

class MyButterWrapper : ButterHelper, FollowRedriectsMiddlewareHelper {
	override Butter butter
	
	new make(Butter butter) { this.butter = butter }
}
