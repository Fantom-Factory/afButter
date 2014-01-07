using inet
using concurrent

class HttpyBuilder {
	static Httpy buildHttpy(HttpyMiddleware[] middleware) {
		Actor.locals["mw"] = middleware.first
		return HttpyTerminator()
	}
}

mixin Httpy {
	abstract HttpyRes doReq(HttpyReq req)	
}

class HttpyReq {
	Version 		version	:= Version("1.1")
	Str 			method	:= "GET"
	Str:Str 		headers	:= Str:Str[:] { caseInsensitive = true }
	SocketOptions?	options
}

class HttpyRes {}

mixin HttpyMiddleware {
	abstract HttpyRes doReq(HttpyReq req, Httpy httpy)
}


class HttpyTerminator : Httpy {
	override HttpyRes doReq(HttpyReq req) {
		HttpyRes()
	}
}

class FollowRedriectsMiddleware : HttpyMiddleware {
	Bool followRedirects
	override HttpyRes doReq(HttpyReq req, Httpy httpy) {
		return httpy.doReq(req)
	}
}
 

mixin FollowRedriectsMiddlewareHelper {
	
	abstract HttpyMiddleware findMiddleware(Type middlewareType)
	
	Bool followRedirects() {
		(findMiddleware(FollowRedriectsMiddleware#) as FollowRedriectsMiddleware).followRedirects
	}	
}


mixin HttpyHelper : Httpy {
	virtual HttpyMiddleware findMiddleware(Type middlewareType) {
		wrapper := Actor.locals["mw"]
//		return [,][0]
		return wrapper
	}

	virtual Httpy httpy() {
		[,][0]
	}
	
	virtual Void setHttpy(Httpy httpy) {}
	
	override HttpyRes doReq(HttpyReq req) {
		httpy.doReq(req)
	}
}

class MyHttpyWrapper : HttpyHelper, FollowRedriectsMiddlewareHelper {
	new make(Httpy httpy) { setHttpy(httpy) }
}


class Example {
	Void main() {
		httpy := HttpyBuilder.buildHttpy([FollowRedriectsMiddleware()])
		
		wrapper := MyHttpyWrapper(httpy)
		
		echo(wrapper.followRedirects)
	}
}