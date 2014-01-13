
internal const class ErrMsgs {

	static Str reqUriHasNoScheme(Uri uri) {
		"Request URI must have a scheme and a host, such as `http://example.com/` : `$uri`"
	}

	static Str middlewareNotSupplied() {
		"Middleware is empty"
	}

	static Str terminatorNotFound(Type type) {
		"Middleware $type.qname is not a terminator / did not process the request"
	}

	static Str chainMiddlewareNotFound(Type mwType) {
		"Could not find Middleware for type '${mwType.qname}'"
	}

	static Str serverError(Int statusCode, Str statusMsg) {
		"HTTP response indicated a server error: ${statusCode} - ${statusMsg}"
	}

	static Str tooManyRedirects(Int tooMany) {
		"Too many redirects detected, ${tooMany} in total! See '${FollowRedirectsMiddleware#tooManyRedirects.qname}' to change the limit."
	}
}
