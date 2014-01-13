
internal class MockTerminator : Butter {
	ButterRequest? req
	ButterResponse[] res
	Int index
	
	new make(ButterResponse[] res) { this.res = res }
	
	override ButterResponse sendRequest(ButterRequest req) { this.req=req; return res[index++] }
	override ButterMiddleware? findMiddleware(Type middlewareType, Bool checked := true) { null }
	override ButterMiddleware[] middleware() { ButterMiddleware#.emptyList }
}