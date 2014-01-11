
** Holds the HTTP response.
class ButterResponse {

	** The HTTP status code 
	Int statusCode

	// TODO:
//	const Str statusMsg

	** The HTTP repsonse headers 
	HttpResponseHeaders headers

	private InStream 	in
	private Str? 		emptiedBy
	
	new make(InStream in, |This|? f := null) {
		this.in = in
		f?.call(this)
	}
	
	** Reads the response stream and converts it to a 'Str' using the charset defined in the 'Content-Type' header.
	** 
	** This method closes the response stream. 
	Str asStr() {
		if (emptiedBy != null)
			throw ButterErr(ErrMsgs.responseAlreadyEmpitedBy(emptiedBy))
		emptiedBy = "asStr()"

		in.charset = headers.contentType?.charset ?: Charset.utf8
		return in.readAllStr
	}

	** Return the response stream as a 'Buf'.
	** 
	** Convenience for `in.readAllBuf`.  
	** This method closes the response stream. 
	Buf asBuf() {
		if (emptiedBy != null)
			throw ButterErr(ErrMsgs.responseAlreadyEmpitedBy(emptiedBy))
		emptiedBy = "asBuf()"

		return in.readAllBuf
	}

	** Returns the response stream.
	InStream asInStream() {
		if (emptiedBy != null)
			throw ButterErr(ErrMsgs.responseAlreadyEmpitedBy(emptiedBy))
		emptiedBy = "asInStream()"
		
		return in
	}
}
