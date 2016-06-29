
** (Middleware) - Sets a proxy for HTTP sockets to connect via.
**
** Reuses the mechanism used by `web::WebClient`; 
** that is, the proxy address should be configured in 'etc/web/config.props' with the key 'proxy'.  
** Proxy exceptions are configured via the 'proxy.exceptions' key as a comma separated list of 
** Regex globs.
**
** Sample 'config.props':
** 
**   // Default proxy URL formatted as "http://{host}[:port]/"
**   proxy=http://foo:8080/
** 
**   // Proxy exceptions as comma separated list of Regex globs
**   proxy.exceptions=192.168.*.*,*.google.com
** 
** For more automated and advanced proxy setting, including Proxy Auto-Config (PAC) files, see the 
** article [Butter Proxies]`http://www.fantomfactory.org/articles/butter-proxies`.
** 
class ProxyMiddleware : ButterMiddleware {
	
	@NoDoc
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		
		requiresProxy := proxyUrl != null && !proxyExceptions.any { it.matches(req.url.host.toStr) }
		
		if (requiresProxy)
			req.stash["afButter.proxy"] = proxyUrl.isAbs ? proxyUrl : `${req.url.scheme}://${proxyUrl}`
		
		return butter.sendRequest(req)
	}

	private once Uri? proxyUrl() {
		webConfig("proxy")?.toUri
	}

	private once Regex[] proxyExceptions() {
		webConfig("proxy.exceptions")?.split(',')?.map { Regex.glob(it) } ?: Regex#.emptyList
	}

	private Str? webConfig(Str key) {
		Pod.find("web", false)?.config(key)
	}
}
