
internal const class ErrMsgs {

	static Str middlewareNotSupplied() {
		"Middleware is empty"
	}

	static Str terminatorNotFound(Type type) {
		"Middleware $type.qname is not a terminator / did not process the request"
	}
	
}
