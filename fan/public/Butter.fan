

mixin Butter {
	abstract ButterResponse get(Uri uri)

	abstract ButterResponse sendRequest(ButterRequest req)	
	
	abstract ButterMiddleware findMiddleware(Type middlewareType)
	
	static Butter churnOut(ButterMiddleware[] middleware) {
		return ButterChain(middleware)
	}
}


//TODO: expect / continue middleware

//TODO: PostFormHelper / FormHelper / PostHelper / PostMan
//  This postForm(Str:Str form)
//  {
//    if (reqHeaders["Expect"] != null) throw UnsupportedErr("'Expect' header")
//    body := Uri.encodeQuery(form)
//    reqMethod = "POST"
//    reqHeaders["Content-Type"] = "application/x-www-form-urlencoded"
//    reqHeaders["Content-Length"] = body.size.toStr // encoded form is ASCII
//    writeReq
//    reqOut.print(body).close
//    readRes
//    return this
//  }

//  This postStr(Str content)
//  {
//    if (reqHeaders["Expect"] != null) throw UnsupportedErr("'Expect' header")
//    body := Buf().print(content).flip
//    reqMethod = "POST"
//    ct := reqHeaders["Content-Type"]
//    if (ct == null)
//      reqHeaders["Content-Type"] = "text/plain; charset=utf-8"
//    reqHeaders["Content-Length"] = body.size.toStr
//    writeReq
//    reqOut.writeBuf(body).close
//    readRes
//    return this
//  }

  **
  ** Post a file to the URI.  If Content-Type header is not already
  ** set, then it is set from the file extension's MIME type.  Upon
  ** completion the response is ready to be read.  This method does
  ** not support the ["Expect" header]`pod-doc#expectContinue` (it
  ** posts full file before reading response).
  **
//  This postFile(File file)
//  {
//    if (reqHeaders["Expect"] != null) throw UnsupportedErr("'Expect' header")
//    reqMethod = "POST"
//    ct := reqHeaders["Content-Type"]
//    if (ct == null)
//      reqHeaders["Content-Type"] = file.mimeType?.toStr ?: "application/octet-stream"
//    if (file.size != null)
//      reqHeaders["Content-Length"] = file.size.toStr
//    writeReq
//    file.in.pipe(reqOut, file.size)
//    reqOut.close
//    readRes
//    return this
//  }