
internal const class ErrMsgs {

	static Str reqUriHasNoScheme(Uri uri) {
		"Request URI must have a scheme and a host, such as `http://example.com/` : `$uri`"
	}

	static Str middlewareNotSupplied() {
		"Middleware is empty"
	}

	static Str terminatorNotFound(Type? type) {
		"Middleware ${type?.qname} is not a terminator / did not process the request"
	}

	static Str chainMiddlewareNotFound(Str mwType) {
		"Could not find Middleware for type '${mwType}'"
	}

	static Str tooManyRedirects(Int tooMany) {
		"Too many redirects detected, ${tooMany} in total! See '${FollowRedirectsMiddleware#tooManyRedirects.qname}' to change the limit."
	}

	static Str hostNotDefined(Uri host) {
		"Host URI does not contain a host part: ${host}"
	}
}
