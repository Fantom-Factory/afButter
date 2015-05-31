
** Holds an instance of 'Butter'; use to create helper classes that access your middleware.
** 
** Butter middleware classes should provide helper mixins that you can extend. These mixins should provide methods to
** access the middleware, making your code easier to read.
** 
** For example, without using a 'ButterDish':
** 
** pre>
**   syntax: fantom
**   butter := Butter.churnOut()
**   ((FollowRedriectsMiddleware) butter.findMiddleware(FollowRedriectsMiddleware#)).enabled = true
**   ((ErrOn5xxMiddleware) butter.findMiddleware(ErrOn5xxMiddleware#)).enabled = true
** <pre
** 
** Compare *with* using a 'ButterDish':
** 
** pre>
**   syntax: fantom
**   butter := ButterDish(Butter.churnOut())
**   butter.followRedirects.enabled = true
**   butter.errOn5xx.enabled = true
** <pre
class ButterDish : Butter {
	
	protected Butter butter
	
	new make(Butter butter) {
		this.butter = butter
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
	
	// ---- Default Stack Middleware -----------------------------------------------------------------------------------
	
	ErrOn4xxMiddleware errOn4xx() {
		findMiddleware(ErrOn4xxMiddleware#)
	}

	ErrOn5xxMiddleware errOn5xx() {
		findMiddleware(ErrOn5xxMiddleware#)
	}

	FollowRedirectsMiddleware followRedirects() {
		findMiddleware(FollowRedirectsMiddleware#)
	}

	StickyCookiesMiddleware stickyCookies() {
		findMiddleware(StickyCookiesMiddleware#)
	}

	StickyHeadersMiddleware stickyHeaders() {
		findMiddleware(StickyHeadersMiddleware#)
	}

	GzipMiddleware gzip() {
		findMiddleware(GzipMiddleware#)
	}
}
