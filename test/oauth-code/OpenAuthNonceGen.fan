using util::Random

** @see [Nonce and Timestamp]`http://oauth.net/core/1.0/#rfc.section.8`
@NoDoc
class OpenAuthNonceGen {
	private Int? oldSecondsSinceUnixEpoch
	private Str? oldNonce
	
	** Note that the Unix epoch is not the same as the Fantom epoch, hence it's easier to work with seconds in an Int, 
	** than it is a Fantom duration
	virtual Str generate(Int secsSinceUnixEpoch) {

		// use the same nonce for each unique timestamp
		if (secsSinceUnixEpoch == oldSecondsSinceUnixEpoch)
			return oldNonce
		
		random 	:= Random.makeSeeded(secsSinceUnixEpoch)
		nonce	:= random.nextBuf(9).toBase64

		oldSecondsSinceUnixEpoch	= secsSinceUnixEpoch
		oldNonce					= nonce
		
		return nonce
	}
}

** @see [Nonce and Timestamp]`http://oauth.net/core/1.0/#rfc.section.8`
@NoDoc
class OpenAuthTimestampGen {
	private static const DateTime	unixEpoch	:= DateTime(1970, Month.jan, 1, 0, 0)
	Int oldTimestamp
	
	virtual Int generate() {
		timestamp := (DateTime.now - unixEpoch).toSec

//		if ((timestamp - oldTimestamp) <= 5)
//			return oldTimestamp
		
		oldTimestamp = timestamp
		return timestamp
	}
}