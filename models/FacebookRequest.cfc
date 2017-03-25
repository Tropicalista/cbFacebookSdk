component accessors="true" {

    property name="app";
    property name="accessToken";
    property name="method";
    property name="endpoint";
    property name="headers";
    property name="params";
    property name="files";
    property name="eTag";
    property name="graphVersion" default="";

    property name="Facebook" inject="Facebook@cbFacebookSdk";
    property name="AccessToken" inject="AccessToken@cbFacebookSdk" scope="instance";
    property name="FacebookUrlManipulator" inject="FacebookUrlManipulator@cbFacebookSdk";
    property name="RequestBodyUrlEncoded" inject="RequestBodyUrlEncoded@cbFacebookSdk";

    public function init(FacebookApp app = "", accessToken = "", method = "", endpoint = "", struct params, eTag = "", graphVersion ){
        if( !structKeyExists( arguments, "params" ) ){
            variables.params = {};
        }
        setApp( arguments.app );
        setAccessToken( arguments.accessToken );
        setMethod( arguments.method );
        setEndpoint( arguments.endpoint );
        setParams( arguments.params );
        setETag( arguments.eTag );
        variables.graphVersion = len(arguments.graphVersion) ? arguments.graphVersion : Facebook.DEFAULT_GRAPH_VERSION;

        return this;
    }

    public function setAccessToken( accessToken ){
        variables.accessToken = arguments.accessToken;
        if ( isInstanceOf( arguments.accessToken, "AccessToken") ) {
            variables.accessToken = arguments.accessToken.getValue();
        }
        return this;
    }

    public function setAccessTokenFromParams( accessToken ){
        var existingAccessToken = getAccessToken();
        if (!len(existingAccessToken)) {
            setAccessToken( arguments.accessToken );
        }elseif( arguments.accessToken != existingAccessToken ){
            throw('Access token mismatch. The access token provided in the FacebookRequest and the one provided in the URL or POST params do not match.');
        }
        return this;
    }

    public function getAccessToken(){
        return variables.accessToken;
    }

    public function getAccessTokenEntity(){
        return len(variables.accessToken) ? instance.AccessToken.init( variables.accessToken ) : "";
    }

    public function setApp(FacebookApp app ){
        variables.app = arguments.app;
    }

    public function getAppSecretProof(){
    	var accessTokenEntity = getAccessTokenEntity();
        if ( !len( accessTokenEntity ) ) {
            return "";
        }
        return accessTokenEntity.getAppSecretProof( variables.app.getSecret() );
    }

    public function validateAccessToken(){
        var accessToken = getAccessToken();
        if (!len(accessToken)) {
            throw('You must provide an access token.');
        }
    }

    public function setMethod(method){
        variables.method = uCase(arguments.method);
    }

    public function validateMethod(){
        if (!len(variables.method)) {
            throw('HTTP method not specified.');
        }
        if ( !arrayFind( ['GET', 'POST', 'DELETE'], variables.method ) ) {
            throw('Invalid HTTP method specified.');
        }
    }

    public function setEndpoint(endpoint){
        // Harvest the access token from the endpoint to keep things in sync
        var params = FacebookUrlManipulator.getParamsAsStruct( arguments.endpoint );
        if ( isStruct(params) AND structKeyExists(params, "access_token") ){
            setAccessTokenFromParams( params['access_token'] );
        }
        // Clean the token & app secret proof from the endpoint.
        var filterParams = ['access_token', 'appsecret_proof'];
        variables.endpoint = FacebookUrlManipulator.removeParamsFromUrl( arguments.endpoint, filterParams );
        return this;
    }

    public function getHeaders(){
        var headers = getDefaultHeaders();
        if ( len(variables.eTag) ) {
            headers['If-None-Match'] = variables.eTag;
        }
        if( isNull(variables.headers) ){
            variables.headers = {};
        }
        structAppend( variables.headers, headers );
        return variables.headers;
    }

    public function setHeaders( struct headers ){
        if( isNull( variables.headers ) ){
            variables.headers = {};
        };       
        if( !isNull(arguments.headers) ){
            structAppend( variables.headers, headers );
        }
    }

    public function setParams( struct params ){
        if ( structKeyExists( arguments.params, 'access_token' ) ) {
            setAccessTokenFromParams( params['access_token'] );
        }
        // Don't let these buggers slip in.
        structDelete( arguments.params, 'access_token' )
        structDelete( arguments.params, 'appsecret_proof' )
        // @TODO Refactor code above with this
        //$params = $this->sanitizeAuthenticationParams($params);
        var params = sanitizeFileParams( arguments.params );
        dangerouslySetParams(params);
        return this;
    }

    public function dangerouslySetParams(struct params){
        if(isNull(variables.params)){
            variables.params = {};
        }
    	if( !isNull(arguments.params) ){
	        structAppend(variables.params, arguments.params);
    	}
        return this;
    }

    public function sanitizeFileParams(struct params){
    	StructEach( arguments.params, function( key, value ){
            if ( isInstanceOf( value, "FacebookFile" ) ) {
                addFile(key, value);
                arguments.params[key];
            }
    	});

        return params;
    }

    public function addFile(key, FacebookFile file){
        variables.files[arguments.key] = arguments.file;
    }

    public function resetFiles(){
        variables.files = [];
    }

    public function containsFileUploads(){
        return !empty(variables.files);
    }

    public function containsVideoUploads(){
        if( !isNull( variables.files ) ){
            ArrayEach(variables.files,function(file) {
                if ( isInstanceOf(file, FacebookVideo) ){
                    return true;
                }
            });     
        };
        return false;
    }

    public function getMultipartBody(){
        var params = getPostParams();
        return new RequestBodyMultipart(params, variables.files);
    }

    public function getUrlEncodedBody(){
        var params = getPostParams();
        return RequestBodyUrlEncoded.init(params);
    }

    public function getParams(){
        var params = variables.params ?: {};
        var accessToken = getAccessToken();
        if (len(accessToken)) {
            params['access_token'] = accessToken;
            params['appsecret_proof'] = getAppSecretProof();
        }
        return params;
    }

    public function getPostParams(){
        if (getMethod() EQ 'POST') {
            return getParams();
        }
        return {};
    }

    public function getUrl(){
        validateMethod();
        var graphVersion = FacebookUrlManipulator.forceSlashPrefix( variables.graphVersion );
        var endpoint = FacebookUrlManipulator.forceSlashPrefix( getEndpoint() );
        var getUrl = graphVersion & endpoint;

        if (getMethod() != 'POST') {
            var params = getParams();
            getUrl = FacebookUrlManipulator.appendParamsToUrl(getUrl, params);
        }
        return getUrl;
    }

    public function getDefaultHeaders(){
        return {
            'User-Agent' : 'fb-php-' & Facebook.VERSION,
            'Accept-Encoding' : '*'
        };
    }

}