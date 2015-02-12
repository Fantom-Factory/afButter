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
			req.headers.host = normaliseHost(req.url)

		// set the Content-Length, if it's not been already
		if (req.headers.contentLength == null)
			if (req.method == "GET" && req.body.size == 0)
				null?.toStr // don't bother setting Content-Length for GET reqs with an empty body, Firefox v32 doesn't
			else
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
		
		try {
			reqOutStream := WebUtil.makeContentOutStream(req.headers.map, out)
	
			// send request
			out.print("${req.method} ${reqPath} HTTP/${req.version}\r\n")
			req.headers.each |v, k| { out.print("${k}: ${v}\r\n") }
			out.print("\r\n")
			out.flush
	
			// use seek(0) rather than flip, 'cos we may be redirected subsequent times and flip() has a habit of clearing the buffer! 
			req.body.seek(0).in.pipe(out)
			out.flush
		
			return ButterResponse(socket.in)
		} finally {
			out.close
			socket.close
		}
	}
	
	// Returns a normalised host string from a URL.
	static Str normaliseHost(Uri url) {
		uri  := (url.host == null) ? `//$url` : url
		host := uri.host 
		if (host == null || host.isEmpty)
			throw ArgErr(ErrMsgs.hostNotDefined(url))
		isHttps := url.scheme == "https"
		defPort := isHttps ? 443 : 80
		if (uri.port != null && uri.port != defPort)
			host += ":${uri.port}"
		return host
	}
}

