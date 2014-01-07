using inet
using concurrent

class ButterBuilder {
	static Butter buildButter(ButterMiddleware[] middleware) {
		Actor.locals["mw"] = middleware.first
		return ButterTerminator()
	}
}

mixin Butter {
	abstract ButterRes doReq(ButterReq req)	
}

class ButterReq {
	Version 		version	:= Version("1.1")
	Str 			method	:= "GET"
	Str:Str 		headers	:= Str:Str[:] { caseInsensitive = true }
	SocketOptions?	options
}

class ButterRes {}

mixin ButterMiddleware {
	abstract ButterRes doReq(ButterReq req, Butter butter)
}


class ButterTerminator : Butter {
	override ButterRes doReq(ButterReq req) {
		ButterRes()
	}
}

class FollowRedriectsMiddleware : ButterMiddleware {
	Bool followRedirects
	override ButterRes doReq(ButterReq req, Butter butter) {
		return butter.doReq(req)
	}
}
 

mixin FollowRedriectsMiddlewareHelper {
	
	abstract ButterMiddleware findMiddleware(Type middlewareType)
	
	Bool followRedirects() {
		(findMiddleware(FollowRedriectsMiddleware#) as FollowRedriectsMiddleware).followRedirects
	}	
}


mixin ButterHelper : Butter {
	virtual ButterMiddleware findMiddleware(Type middlewareType) {
		wrapper := Actor.locals["mw"]
//		return [,][0]
		return wrapper
	}

	virtual Butter butter() {
		[,][0]
	}
	
	virtual Void setButter(Butter butter) {}
	
	override ButterRes doReq(ButterReq req) {
		butter.doReq(req)
	}
}

class MyButterWrapper : ButterHelper, FollowRedriectsMiddlewareHelper {
	new make(Butter butter) { setButter(butter) }
}


class Example {
	Void main() {
		butter := ButterBuilder.buildButter([FollowRedriectsMiddleware()])
		
		wrapper := MyButterWrapper(butter)
		
		echo(wrapper.followRedirects)
	}
}