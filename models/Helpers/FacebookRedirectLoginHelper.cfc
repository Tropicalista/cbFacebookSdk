component accessors="true" {

    THIS.CSRF_LENGTH = 32;

    property name="oAuth2Client";
    property name="urlDetectionHandler";
    property name="persistentDataHandler";
    property name="pseudoRandomStringGenerator";
    property name="prsgFactory" inject="pseudoRandomStringGenerator@cbFacebookSdk";;
    property name="FacebookUrlManipulator" inject="FacebookUrlManipulator@cbFacebookSdk";;
    property name="FacebookUrlDetectionHandler" inject="FacebookUrlDetectionHandler@cbFacebookSdk";;
    property name="FacebookSessionPersistentDataHandler" inject="FacebookSessionPersistentDataHandler@cbFacebookSdk";;

    public function init(OAuth2Client oAuth2Client, IPersistentData persistentDataHandler, IUrlDetection urlHandler, prsg){
        variables.oAuth2Client = arguments.oAuth2Client;
        variables.persistentDataHandler = structKeyExists( arguments,"persistentDataHandler" ) ? arguments.persistentDataHandler : FacebookSessionPersistentDataHandler.init();
        variables.urlDetectionHandler = structKeyExists( arguments,"urlHandler" ) ? arguments.urlHandler : FacebookUrlDetectionHandler.init();
        variables.pseudoRandomStringGenerator = prsgFactory.getPseudoRandomString(arguments.prsg);

        return this;

    }

    private function makeUrl(redirectUrl, array scope, struct params = {}, separator = '&'){
        var state = len(persistentDataHandler.get('state')) ? persistentDataHandler.get('state') : prsgFactory.getPseudoRandomString(THIS.CSRF_LENGTH);
        persistentDataHandler.set('state', state);
        return getOAuth2Client().getAuthorizationUrl(arguments.redirectUrl, state, arguments.scope, arguments.params, arguments.separator);
    }

    public function getLoginUrl(redirectUrl, array scope = [], separator = '&'){

        return makeUrl(arguments.redirectUrl, arguments.scope, {}, arguments.separator);

    }

    public function getLogoutUrl( accessToken, next, separator = '&' ){

        if ( !isInstanceOf(arguments.accessToken, "AccessToken") ) {
            accessToken = new AccessToken( arguments.accessToken );
        }

        if (arguments.accessToken.isAppAccessToken()) {
            throw('Cannot generate a logout URL with an app access token.', 722);
        }

        $params = [
            'next' : arguments.next,
            'access_token' : arguments.accessToken.getValue(),
        ];

        return 'https://www.facebook.com/logout.php?' . http_build_query($params, null, $separator);

    }

    public function getReRequestUrl($redirectUrl, array scope = [], separator = '&'){

        var params = ['auth_type' : 'rerequest'];

        return makeUrl( arguments.redirectUrl, arguments.scope, params, arguments.separator);

    }

    public function getReAuthenticationUrl( redirectUrl, array scope = [], separator = '&' ){

        var params = ['auth_type' : 'reauthenticate'];

        return makeUrl( arguments.redirectUrl, arguments.scope, params, arguments.separator);

    }

    public function getAccessToken(redirectUrl){
        /*if (getCode() != "code") {
            return null;
        }*/
        validateCsrf();
        resetCsrf();
        var redirectUrl = structKeyExists( arguments, 'redirectUrl' ) ? arguments.redirectUrl : variables.urlDetectionHandler.getCurrentUrl();
        // At minimum we need to remove the state param
        redirectUrl = FacebookUrlManipulator.removeParamsFromUrl(redirectUrl, ['state']);
        return oAuth2Client.getAccessTokenFromCode(code, redirectUrl);
    }

    private function validateCsrf()    {
        var state = getState();

        if (!len(state)) {
            throw('Cross-site request forgery validation failed. Required GET param "state" missing.');
        }
        var savedState = persistentDataHandler.get('state');

        if (!len(savedState)) {
            throw('Cross-site request forgery validation failed. Required param "state" missing from persistent data.');
        }
        if (!compare(savedState, state)) {
            return;
        }
        throw('Cross-site request forgery validation failed. The "state" param from the URL and session do not match.');
    }

    private function resetCsrf(){
        persistentDataHandler.set('state', "");
    }

    private function getCode(){
        return getInput('code');
    }

    private function getState(){
        return getInput('state');
    }

    public function getErrorCode(){
        return getInput('error_code');
    }

    public function getError(){
        return getInput('error');
    }

    public function getErrorReason()    {
        return getInput('error_reason');
    }

    public function getErrorDescription()    {
        return getInput('error_description');
    }

    private function getInput(key){
        return structKeyExists(url, arguments.key) ? url[#arguments.key#] : "";
    }
    
}