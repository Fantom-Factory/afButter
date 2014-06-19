using inet
using web::WebUtil

// TODO: Continue 100 - http://www.w3.org/Protocols/rfc2616/rfc2616-sec8.html#sec8.2.3
// TODO: use proxy
// TODO: pipelining - use middleware, have it set the 'socket' via req.data

** (Terminator) - A 'Butter' Terminator for making real HTTP requests. 
** When used in a chain, no other middleware should come after this one. (For they will not be called.)
class HttpTerminator : ButterMiddleware {

	SocketOptions? options
	
	** Makes a real HTTP request.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!req.url.isAbs || req.url.host == null)
			throw ButterErr(ErrMsgs.reqUriHasNoScheme(req.url))

		// set the Host, if it's not been already
		// Host is mandatory for HTTP/1.1, and does no harm in HTTP/1.0
		if (req.headers.host == null)
			req.headers.host = req.url	// let the headers normalise the host part out of the entire req url

		// set the Content-Length, if it's not been already
		if (req.headers.contentLength == null && req.method != "GET")
			req.headers.contentLength = req.body.size

		isHttps := req.url.scheme == "https"
		defPort := isHttps ? 443 : 80

		socket 	:= isHttps ? TcpSocket.makeSsl: TcpSocket.make
		if (options != null) socket.options.copyFrom(this.options)
		// request uri is absolute if proxy, relative otherwise
//		reqPath := (usingProxy ? reqUri : reqUri.relToAuth).encode
		reqPath := (req.url.relToAuth).encode
		socket.connect(IpAddr(req.url.host), req.url.port ?: defPort)
		out 	:= socket.out
		reqOutStream := WebUtil.makeContentOutStream(req.headers.map, out)

		// send request
		out.print("${req.method} ${reqPath} HTTP/${req.version}\r\n")
		req.headers.each |v, k| { out.print("${k}: ${v}\r\n") }
		out.print("\r\n")
		out.flush

		// use seek(0) rather than flip, 'cos we may be redirected subsequent times and flip() has a habit of clearing the buffer! 
		req.body.seek(0).in.pipe(out)
		out.flush		
		
		try {
			return ButterResponse(socket.in)
		} finally {
			socket.close
		}
	}	
}

