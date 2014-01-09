
** As thrown by Butter.
const class ButterErr : Err {
	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}
}
