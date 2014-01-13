using inet
using web::WebUtil

// TODO: Continue 100 - http://www.w3.org/Protocols/rfc2616/rfc2616-sec8.html#sec8.2.3
// TODO: use proxy
// TODO: pipelining - use middleware, have it set the 'socket' via req.data

** A middleware terminator for making real HTTP requests. 
** When used in a chain, no other middleware should come after this one. (For they will not be called.)
class HttpTerminator : ButterMiddleware {
	
	SocketOptions? options
	
	** Makes a real HTTP request.
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		if (!req.uri.isAbs || req.uri.host == null)
			throw ButterErr(ErrMsgs.reqUriHasNoScheme(req.uri))
		
		isHttps := req.uri.scheme == "https"
		defPort := isHttps ? 443 : 80

		// set the Host, if it's not been already
		if (req.headers.host == null) {
			host := req.uri.host
			if (req.uri.port != null && req.uri.port != defPort)
				host += ":${req.uri.port}"
			req.headers.host = host.toUri
		}

		// set the Content-Length, if it's not been already
		if (req.headers.contentLength == null && req.method != "GET") {
			req.headers.contentLength = req.body.size
		}

		socket 	:= isHttps ? TcpSocket.makeSsl: TcpSocket.make
		if (options != null) socket.options.copyFrom(this.options)
		// request uri is absolute if proxy, relative otherwise
//		reqPath := (usingProxy ? reqUri : reqUri.relToAuth).encode
		reqPath := (req.uri.relToAuth).encode
		socket.connect(IpAddr(req.uri.host), req.uri.port ?: defPort)
		out 	:= socket.out
		reqOutStream := WebUtil.makeContentOutStream(req.headers.map, out)

		// send request
		out.print("${req.method} ${reqPath} HTTP/${req.version}\r\n")
		req.headers.each |v, k| { out.print("${k}: ${v}\r\n") }
		out.print("\r\n")
		out.flush

		req.body.flip.in.pipe(out)
		out.flush		
		
		res := Str.defVal
		try {
			resVer	:= (Version?) null
			res 	= socket.in.readLine
			if 		(res.startsWith("HTTP/1.0")) resVer = Butter.http10
			else if (res.startsWith("HTTP/1.1")) resVer = Butter.http11
			else throw IOErr("Unknown HTTP version: ${res}")
			resCode 	:= res[9..11].toInt
			resPhrase 	:= res[13..-1]
			resHeaders	:= WebUtil.parseHeaders(socket.in)
			resInStream := WebUtil.makeContentInStream(resHeaders, socket.in)

			content		:= resInStream.readAllBuf
			socket.close
			
			return ButterResponse(resCode, resPhrase, resHeaders, content) { it.version = resVer }
		}
		catch (IOErr e) throw e 
		catch (Err err) throw IOErr("Invalid HTTP response: $res", err)
	}
}

