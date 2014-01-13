
** Holds an instance of 'Butter'; use to create helper classes that access your middleware.
** 
** Butter middleware classes should provide helper mixins that you can extend. These mixins should provide methods to
** access the middleware, making your code easier to read.
** 
** For example, without using a 'ButterDish':
** 
** pre>
**   butter := Butter.churnOut()
**   ((FollowRedriectsMiddleware) butter.findMiddleware(FollowRedriectsMiddleware#)).setFollowRedirects(true)
**   ((ErrOn500Middleware) butter.findMiddleware(ErrOn500Middleware#)).setErrOn500(true)
** <pre
** 
** Compare *with* using a 'ButterDish':
** 
** pre>
**   butter := MyButterDish(Butter.churnOut())
**   butter..setFollowRedirects(true)
**   butter..setErrOn500(true)
** 
**   ...
** 
**   class MyButterDish : ButterDish, FollowRedirectsDish, ErrOn500Dish {
**       override Butter butter
**       new make(Butter butter) { this.butter = butter }
**   }
** <pre
mixin ButterDish : Butter {
	
	abstract Butter butter
	
	override ButterResponse get(Uri uri) {
		butter.get(uri)
	}

	override ButterResponse sendRequest(ButterRequest req) {
		butter.sendRequest(req)
	}

	override ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true) {
		butter.findMiddleware(middlewareType)
	}

	override ButterMiddleware[] middleware() {
		butter.middleware
	}
	
	override Obj? trap(Str name, Obj?[]? args := null) {
		butter.trap(name, args)
	}
}
