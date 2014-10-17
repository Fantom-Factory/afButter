
internal const class OpenAuthMsgs {

	static Str duplicateParamsNotSuppored(Str key, Str val1, Str val2) {
		"Duplicate parameter keys are not currently supported. key='$key', vals='$val1', '$val2'"
	}

	static Str emptyParamsNotSuppored(Str key, Str val) {
		"Empty parameter keys are not currently supported. key='$key', val='$val'"
	}
}
