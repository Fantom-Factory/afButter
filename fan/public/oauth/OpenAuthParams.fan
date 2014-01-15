using web::WebUtil


** TODO: OAuth: Allow multiple values per key
** TODO: OAuth: Allow null / empty key values
** @see http://hueniverse.com/oauth/guide/authentication/
internal class OpenAuthParams {
	private Str:Str	params	:= Str:Str[:] 

	@Operator
	Void set(Str key, Str val) {
		if (params.containsKey(key.trim))
			throw ArgErr(OpenAuthMsgs.duplicateParamsNotSuppored(key, params[key], val))
		if (val.trim.isEmpty)
			throw ArgErr(OpenAuthMsgs.emptyParamsNotSuppored(key, val))
		params[key.trim] = percentEscape(val.trim)
	}

	@Operator
	Str get(Str key) {
		params[key]
	}

	Str queryStr() {
		q := StrBuf()
		params.keys.sort.each |key| {
			val := params[key]
			if (!q.isEmpty)
				q.add("&")
			q.add("$key=$val")
		}
		return q.toStr
	}

	Str headerStr() {
		q := StrBuf()
		params.keys.sort.each |key| {
			if (!key.startsWith("oauth"))
				return
			val := params[key]
			if (!q.isEmpty)
				q.add(", ")
			q.add("$key=" + WebUtil.toQuotedStr(val))
		}
		return "OAuth $q"
	}

	** Percent encode the given string as per [Parameter Encoding]`http://oauth.net/core/1.0/#rfc.section.5.1` of the 
	** OAuth spec. Essentially, encode ALL characters except for 'A-Za-z0-9-_.~'
	static Str percentEscape(Str query) {
		// lets the uri encoding handle all the crazy unicode octlet stuff
		query = query.toUri.encode.toStr
		
		// now I just have to deal with the 'safe' characters that weren't encoded as part of the URI
		"!\$&@#+()'*,;:=/\\?".each |char| {
			query = query.replace(char.toChar, "%" + char.toHex(2).upper)
		}
		
		// TODO: ask the Fantom boys to add a static method to Uri to do all this 
		return query				
	}
	
	static Void main(Str[] args) {
		// test string - 
		echo(percentEscape("!~*'()@:\$,;/?:` âÕ÷ÚÊ+"))

		// test string - non should be encoded
		echo(percentEscape("-_.~ABCDEF...Zabcdef...z0123456789"))
	}
}
