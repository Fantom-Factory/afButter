using inet
using web::WebUtil

// TODO: Continue 100 - http://www.w3.org/Protocols/rfc2616/rfc2616-sec8.html#sec8.2.3
// TODO: pipelining - use middleware, have it set the 'socket' via req.stash

** (Terminator) - A 'Butter' Terminator for making real HTTP requests. 
** When used in a chain, no other middleware should come after this one. (For they will not be called.)
** 
** To use a proxy, set the full proxy URL (as a 'Uri') in the request stash under the key 'afButter.proxy':
** 
**   req.stash[afButter.proxy] = `http://proxy.example.org:8069`
** 
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
		bufSize := req.body.buf.size
		if (req.headers.contentLength == null)
			if (req.method == "GET" && bufSize == 0)
				null?.toStr // don't bother setting Content-Length for GET reqs with an empty body, Firefox v32 doesn't
			else
				req.headers.contentLength = bufSize

		proxyUrl := proxyUrl(req)
		socket	 := req.stash["afButter.socket"] as TcpSocket ?: connect(req, proxyUrl)
		out 	 := socket.out

		try {
			reqOutStream := WebUtil.makeContentOutStream(req.headers.map, out)

			// request uri is absolute if proxy, relative otherwise
			reqPath := (proxyUrl != null ? req.url : req.url.relToAuth).encode
	
			// send request
			out.print("${req.method} ${reqPath} HTTP/${req.version}\r\n")
			req.headers.each |v, k| { out.print("${k}: ${v}\r\n") }
			out.print("\r\n")
			out.flush

			req.body.buf.seek(0).in.pipe(out)
			out.flush
		
			return ButterResponse(socket.in)

		} finally {
			out.close
			socket.close
		}
	}
	
	internal TcpSocket connect(ButterRequest req, Uri? proxyUrl) {
		connUrl := proxyUrl ?: req.url
		isHttps := connUrl.scheme == "https"
		defPort := isHttps ? 443 : 80
		socket 	:= isHttps ? TcpSocket.makeSsl: TcpSocket.make
		if (options != null) socket.options.copyFrom(this.options)

		socket.connect(IpAddr(connUrl.host), connUrl.port ?: defPort)
		return socket
	}

	** Grabs the proxy URL from the request stash.
	internal Uri? proxyUrl(ButterRequest req) {
		proxyObj := req.stash["afButter.proxy"]
		if (proxyObj != null && proxyObj isnot Uri)
			Utils.getLog(this.typeof).warn(LogMsgs.httpTerminator_proxyNotUri(proxyObj))
		proxyUrl := proxyObj as Uri
		return proxyUrl
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

