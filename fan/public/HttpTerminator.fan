
class HttpTerminator : ButterMiddleware {
	
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		ButterResponse()
		
//		if (!it.isAbs) throw ArgErr(ErrMsgs.reqUriHasNoScheme(it))

	}
	
  ** Write the request line and request headers.  Once this method
  ** completes the request body may be written via `reqOut`, or the
  ** response may be immediately read via `readRes`.  Throw IOErr
  ** if there is a network or protocol error.  Return this.
  **
//  This writeReq()
//  {
//    // sanity checks
//    if (!reqUri.isAbs || reqUri.scheme == null || reqUri.host == null) throw Err("reqUri is not absolute: `$reqUri`")
//    if (!reqHeaders.caseInsensitive) throw Err("reqHeaders must be case insensitive")
//    if (reqHeaders.containsKey("Host")) throw Err("reqHeaders must not define 'Host'")
//
//    // connect to the host:port if we aren't already connected
//    isHttps := reqUri.scheme == "https"
//    defPort := isHttps ? 443 : 80
//    usingProxy := isProxy(reqUri)
//    if (!isConnected)
//    {
//      // make https or http socket
//      socket = isHttps ? TcpSocket.makeSsl: TcpSocket.make
//      if (options != null) socket.options.copyFrom(this.options)
//
//      // connect to proxy or directly to request host
//      connUri := usingProxy ? proxy : reqUri
//      socket.connect(IpAddr(connUri.host), connUri.port ?: defPort)
//    }
//
//    // request uri is absolute if proxy, relative otherwise
//    reqPath := (usingProxy ? reqUri : reqUri.relToAuth).encode
//
//    // host authority header
//    host := reqUri.host
//    if (reqUri.port != null && reqUri.port != defPort) host += ":$reqUri.port"
//
//    // figure out if/how we are streaming out content body
//    out := socket.out
//    reqOutStream = WebUtil.makeContentOutStream(reqHeaders, out)
//
//    // send request
//    out.print(reqMethod).print(" ").print(reqPath)
//       .print(" HTTP/").print(reqVersion).print("\r\n")
//    out.print("Host: ").print(host).print("\r\n")
//    reqHeaders.each |Str v, Str k| { out.print(k).print(": ").print(v).print("\r\n") }
//    out.print("\r\n")
//    out.flush
//
//    return this
//  }
	
//  This readRes()
//  {
//    // read response
//    if (!isConnected) throw IOErr("Not connected")
//    in := socket.in
//    res := ""
//    try
//    {
//      // parse status-line
//      res = in.readLine
//      if (res.startsWith("HTTP/1.1")) resVersion = ver11
//      else if (res.startsWith("HTTP/1.0")) resVersion = ver10
//      else throw Err("Not HTTP")
//      resCode = res[9..11].toInt
//      resPhrase = res[13..-1]
//
//      // parse response headers
//      resHeaders = WebUtil.parseHeaders(in)
//    }
//    catch (Err e) throw IOErr("Invalid HTTP response: $res", e)
//
//    // check for redirect
//    checkFollowRedirect
//
//    // if there is response content, then create wrap the raw socket
//    // input stream with the appropiate chunked input stream
//    resInStream = WebUtil.makeContentInStream(resHeaders, socket.in)
//
//    return this
//  }
}

