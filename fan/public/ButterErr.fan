
** As thrown by 'Butter'.
const class ButterErr : Err {
	const Str[]? availableValues

	new make(Str msg := "", Err? cause := null) : super(msg, cause) {}

	new makeFromValues(Str msg, Obj?[] availableValues, Err? cause := null) : super.make(msg, cause) {
		this.availableValues = availableValues.exclude { it == null }.map { it.toStr }
	}

	override Str toStr() {
		if (availableValues?.isEmpty ?: true)
			return super.toStr
		buf := StrBuf()
		buf.add("${typeof.qname}: ${msg}\n")
		buf.add("\nAvailable values:\n")
		availableValues.each { buf.add("  $it\n")}
		buf.add("\nStack Trace:")
		return buf.toStr
	}
}
