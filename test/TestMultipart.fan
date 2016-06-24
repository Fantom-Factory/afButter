
internal class TestMultipart : ButterTest {
	
	Void testMultipart() {
		// a bit of a lame test, but it did throw an NPE
		req	:= ButterRequest(`/`)
		req.writeMultipartForm |form| {
			form.writeText("name", "value")
		}
	}
}
