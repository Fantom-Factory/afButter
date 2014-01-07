
** As thrown by HTTPY.
const class HTTPYErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
