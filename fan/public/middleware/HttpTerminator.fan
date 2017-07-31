using inet
using web::WebUtil

// TODO: Continue 100 - http://www.w3.org/Protocols/rfc2616/rfc2616-sec8.html#sec8.2.3
// TODO: pipelining - use middleware, have it set the 'socket' via req.stash

** (Terminator) - A 'Butter' Terminator for making real HTTP requests. 
** When used in a chain, no other middleware should come after this one. (For they will not be called.)
** 
** To use a proxy, set the full proxy URL (as a 'Uri') in the request stash under the key 'afButter.proxy':
** 
**   syntax: fantom
**   req.stash[afButter.proxy] = `http://proxy.example.org:8069`
** 
class HttpTerminator : ButterMiddleware {

	SocketOptions? options
	
	** Makes a real HTTP request.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!req.url.isAbs || req.url.host == null)
			throw ButterErr(ErrMsgs.reqUriHasNoScheme(req.url))

		req._primeForSend

		proxyUrl := proxyUrl(req)
		socket	 := req.stash["afButter.socket"] as TcpSocket ?: connect(req, proxyUrl)
		out 	 := socket.out

		try {
			reqOutStream := WebUtil.makeContentOutStream(req.headers.val, out)

			// request uri is absolute if proxy, relative otherwise
			reqPath := (proxyUrl != null ? req.url : req.url.relToAuth).encode
	
			// send request
			out.print("${req.method} ${reqPath} HTTP/${req.version}\r\n")
			req.headers.each |v, k| { out.print("${k}: ${v}\r\n") }
			out.print("\r\n")
			out.flush

			if (req.body.buf != null) {
				req.body.buf.seek(0).in.pipe(out)
				out.flush
			}

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
		socket 	:= isHttps ? TcpSocket.makeTls: TcpSocket.make
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
	
	@NoDoc	// used by Bounce
	static Str normaliseHost(Uri url) {
		ButterRequest.normaliseHost(url)
	}
}

