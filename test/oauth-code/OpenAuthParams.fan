using web::WebUtil


** TODO: OAuth: Allow multiple values per key
** TODO: OAuth: Allow null / empty key values
** @see http://nouncer.com/oauth/authentication.html
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
static Str percentEscape(Str str) {
	buf := StrBuf(str.size * 2)
	str.each { 
		if (it.isAlphaNum || it == '-' || it == '_' || it == '.' || it == '~')
			buf.addChar(it)
		else
			percentEncodeUtf8Char(buf, it)
			//buf.add(Buf().writeChar(it).toHex)
	}
	return buf.toStr			
}

static Void percentEncodeUtf8Char(StrBuf buf, Int c) {
	if (c <= 0x007F) {
		percentEncodeByte(buf, c);
	} else if (c <= 0x07FF) {
		percentEncodeByte(buf, 0xC0.or(c.shiftr( 6).and(0x1F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr( 0).and(0x3F)));
	} else if (c <= 0xFFFF) {
		percentEncodeByte(buf, 0xE0.or(c.shiftr(12).and(0x0F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr( 6).and(0x3F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr( 0).and(0x3F)));
	} else if (c <= 0x10FFFF) {
		percentEncodeByte(buf, 0xF0.or(c.shiftr(18).and(0x0F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr(12).and(0x3F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr( 6).and(0x3F)));
		percentEncodeByte(buf, 0x80.or(c.shiftr( 0).and(0x3F)));
	} else
		throw ArgErr("0x${c.toHex} is not a valid UTF-8 code point")
}

private static Void percentEncodeByte(StrBuf buf, Int c) {
	buf.addChar('%');
	hi := c.shiftr(4).and(0xf);
	lo := c.and(0xf);
	buf.addChar(hi < 10 ? '0'+hi : 'A'+(hi-10));
	buf.addChar(lo < 10 ? '0'+lo : 'A'+(lo-10));
}
}
