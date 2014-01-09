
class TestNullField : Test {
	
	// Lazy creation
	Uri?	uri {
		get {
			&uri == null ? `dude` : &uri
		}
	}
	
	Uri? getUri() { &uri }
	
	Void testNull() {
		
		Env.cur.err.printLine(&uri)
		Env.cur.err.printLine(uri)
		
	}
}
