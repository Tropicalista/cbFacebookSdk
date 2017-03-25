component accessors="true" {

    property name="value" default="";
    property name="expiresAt";

    public function init( accessToken, expiresAt = 0 ){
        variables.value = arguments.accessToken;
        if ( arguments.expiresAt ) {
            variables.setExpiresAtFromTimeStamp(arguments.expiresAt);
        }
        return this;
    }

    public function getAppSecretProof( appSecret ){
        return LCase(HMac( variables.value, arguments.appSecret, 'HmacSHA256' ));
    }

    public function isAppAccessToken(){
        return strpos(variables.value, '|') !== false;
    }

    public function isLongLived(){
        if (variables.expiresAt) {
            return variables.expiresAt.getTimestamp() > time() + (60 * 60 * 2);
        }
        if ( isAppAccessToken() ) {
            return true;
        }
        return false;
    }

    public function isExpired(){
        if ( isInstanceOf( getExpiresAt(), DateTime) ){
            return getExpiresAt().getTimestamp() < time();
        }
        if ( isAppAccessToken() ){
            return false;
        }
        return null;
    }

    public function toString(){
        return getValue();
    }

    private function setExpiresAtFromTimeStamp( timeStamp ){
        variables.expiresAt = DateAdd( "s", arguments.timeStamp, DateConvert( "local2Utc", "January 1 1970 00:00" ) );
    }
}