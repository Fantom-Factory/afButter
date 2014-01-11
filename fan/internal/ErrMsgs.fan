
internal const class ErrMsgs {

	// TODO: use me!
	static Str reqUriHasNoScheme(Uri uri) {
		"Request URI must have a scheme, such as `http://` : `$uri`"
	}
	
	static Str middlewareNotSupplied() {
		"Middleware is empty"
	}

	static Str terminatorNotFound(Type type) {
		"Middleware $type.qname is not a terminator / did not process the request"
	}
	
	static Str responseAlreadyEmpitedBy(Str by) {
		"Response has already been emptied by '${by}'"
	}
	
}
