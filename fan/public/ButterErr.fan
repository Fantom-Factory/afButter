
** As thrown by HTTPY.
const class HttpyErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
