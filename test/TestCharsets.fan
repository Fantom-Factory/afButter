
class TestCharsets : Test {

	** https://fantom.org/forum/topic/2740
	Void X_testUTF7() {
		// http://hampshiredragonflies.co.uk/wordpress/category/blog/page/3/
		// Invalid Charset: 'UTF-7': java.nio.charset.UnsupportedCharsetException: UTF-7
		Butter.churnOut.get(`http://hampshiredragonflies.co.uk/wordpress/category/blog/page/3/`)
	}
}
