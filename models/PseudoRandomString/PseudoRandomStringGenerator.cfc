component implements="IPseudoRandomStringGenerator" {

    function init(){
        return this;
    }

    public function getPseudoRandomString(length){
		var tokenBase = Now();
		tokenBase &= cgi.remote_addr;
		tokenBase &= RandRange(0, 65535, "SHA1PRNG");
		tokenBase &= getTickCount();
		return UCase( left( hash( tokenBase, "SHA-256" ), 40) );
    }

}