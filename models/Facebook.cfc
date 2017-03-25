component accessors="true" singleton {

    THIS.VERSION = '1.0.0';

    THIS.DEFAULT_GRAPH_VERSION = 'v2.8';

    THIS.APP_ID_ENV_NAME = 'FACEBOOK_APP_ID';

    THIS.APP_SECRET_ENV_NAME = 'FACEBOOK_APP_SECRET';


    property name="app";
    property name="client";
    property name="oAuth2Client";
    property name="urlDetectionHandler";
    property name="pseudoRandomStringGenerator";
    property name="defaultAccessToken";
    property name="defaultGraphVersion";
    property name="persistentDataHandler";
    property name="lastResponse";

    property name="FacebookApp" inject="FacebookApp@cbFacebookSdk";
    property name="PRSG" inject="PseudoRandomStringGenerator@cbFacebookSdk";
    property name="FacebookUrlDetectionHandler" inject="FacebookUrlDetectionHandler@cbFacebookSdk";
    property name="PersistentDataFactory" inject="PersistentDataFactory@cbFacebookSdk";
    property name="OAuth2Client" inject="OAuth2Client@cbFacebookSdk";
    property name="FacebookRedirectLoginHelper" inject="FacebookRedirectLoginHelper@cbFacebookSdk";
    property name="FacebookClient" inject="FacebookClient@cbFacebookSdk";
    property name="AccessToken" inject="AccessToken@cbFacebookSdk";
    property name="FacebookHttpClient" inject="FacebookHttpClient@cbFacebookSdk";
    property name="FacebookRequest" inject="FacebookRequest@cbFacebookSdk";

    public function init( myConfig ){

        variables.config = {
            'app_id' : arguments.myConfig.app_id,
            'app_secret' : arguments.myConfig.app_secret,
            'default_graph_version' : THIS.DEFAULT_GRAPH_VERSION,
            'enable_beta_mode' : false,
            'http_client_handler' : FacebookHttpClient,
            'persistent_data_handler' : "",
            'pseudo_random_string_generator' : "",
            'url_detection_handler' : "",
        };
        structAppend( config, arguments.myConfig, true );

        if ( !structKeyExists(config, "app_id") ) {
            throw('Required "app_id" key not supplied in config and could not find fallback environment variable "' & THIS.APP_ID_ENV_NAME & '"');
        }

        if ( !structKeyExists(config, "app_secret") ) {
            throw('Required "app_secret" key not supplied in config and could not find fallback environment variable "' & THIS.APP_SECRET_ENV_NAME & '"');
        }
        variables.app = FacebookApp.init( id=variables.config['app_id'], secret=variables.config['app_secret'] );
        variables.client = FacebookClient.init(
            variables.config['http_client_handler'],
            variables.config['enable_beta_mode']
        );

        variables.pseudoRandomStringGenerator = PRSG.getPseudoRandomString(
            config['pseudo_random_string_generator']
        );
        setUrlDetectionHandler( len( variables.config['url_detection_handler'] ) ? variables.config['url_detection_handler'] : FacebookUrlDetectionHandler );
        variables.persistentDataHandler = PersistentDataFactory.createPersistentDataHandler(
            config['persistent_data_handler']
        );
        if (structKeyExists( variables.config, 'default_access_token')) {
            setDefaultAccessToken( variables.config['default_access_token'] );
        }
        variables.defaultGraphVersion = variables.config['default_graph_version'];

        return this;
    }

    public function getOAuth2Client(){
        //if (!structKeyExists(variables, "oAuth2Client") OR !IsInstanceOf( variables.oAuth2Client, "OAuth2Client" ) ){
        variables.oAuth2Client = OAuth2Client.init( getApp(), getClient(), getDefaultGraphVersion() );
        //}
        return variables.oAuth2Client;
    }

    private function setUrlDetectionHandler( urlDetectionHandler ){
        variables.urlDetectionHandler = arguments.urlDetectionHandler;
    }

    public function setDefaultAccessToken( accessToken ){
        if ( isSimpleValue( arguments.accessToken) ){
            variables.defaultAccessToken = new AccessToken( arguments.accessToken );
            return;
        }
        if ( IsInstanceOf( arguments.accessToken, "AccessToken" ) ){
            variables.defaultAccessToken = arguments.accessToken;
            return;
        }
        throw('The default access token must be of type "string" or Facebook\AccessToken');
    }

    public function getRedirectLoginHelper(){
        return FacebookRedirectLoginHelper.init(
            getOAuth2Client(),
            variables.persistentDataHandler,
            variables.urlDetectionHandler,
            variables.pseudoRandomStringGenerator
        );
    }

    public function getJavaScriptHelper(){
        return new FacebookJavaScriptHelper(variables.app, variables.client, variables.defaultGraphVersion);
    }

    public function getCanvasHelper(){
        return new FacebookCanvasHelper(variables.app, variables.client, variables.defaultGraphVersion);
    }

    public function getPageTabHelper(){
        return new FacebookPageTabHelper(variables.app, variables.client, variables.defaultGraphVersion);
    }

    public function get(endpoint, accessToken = "", eTag = "", graphVersion = ""){
        return sendRequest(
            'GET',
            arguments.endpoint,
            {},
            arguments.accessToken,
            arguments.eTag,
            arguments.graphVersion
        );
    }

    public function post(endpoint, array params = [], accessToken = "", eTag = "", graphVersion = ""){
        return sendRequest(
            'POST',
            arguments.endpoint,
            arguments.params,
            arguments.accessToken,
            arguments.eTag,
            arguments.graphVersion
        );
    }

    public function delete(endpoint, array params = [], accessToken = "", eTag = "", graphVersion = ""){
        return sendRequest(
            'DELETE',
            arguments.endpoint,
            arguments.params,
            arguments.accessToken,
            arguments.eTag,
            arguments.graphVersion
        );
    }

    public function next(GraphEdge graphEdge){
        return getPaginationResults( arguments.graphEdge, 'next' );
    }

    public function previous( GraphEdge graphEdge ){
        return getPaginationResults( arguments.graphEdge, 'previous' );
    }

    public function getPaginationResults( GraphEdge graphEdge, direction ){
        var paginationRequest = arguments.graphEdge.getPaginationRequest( arguments.direction );
        if (!structKeyExists( arguments, "paginationRequest" ) ){
            return "";
        }
        variables.lastResponse = variables.client.sendRequest($paginationRequest);
        // Keep the same GraphNode subclass
        var subClassName = arguments.graphEdge.getSubClassName();
        arguments.graphEdge = variables.lastResponse.getGraphEdge( subClassName, false );
        return count( arguments.graphEdge ) > 0 ? graphEdge : "";
    }

    public function sendRequest( method, endpoint, struct params, accessToken = "", eTag = "", graphVersion = "" ){
        arguments.accessToken = arguments.accessToken ?: variables.defaultAccessToken;
        arguments.graphVersion = arguments.graphVersion ?: variables.defaultGraphVersion;
        var fbRequest = request(arguments.method, arguments.endpoint, arguments.params, arguments.accessToken, arguments.eTag, arguments.graphVersion);
        return variables.lastResponse = variables.client.sendRequest(fbRequest);
    }

    public function sendBatchRequest(array requests, accessToken = "", graphVersion = ""){
        arguments.accessToken = arguments.accessToken ?: variables.defaultAccessToken;
        arguments.graphVersion = arguments.graphVersion ?: variables.defaultGraphVersion;
        var batchRequest = new FacebookBatchRequest(
            variables.app,
            arguments.requests,
            arguments.accessToken,
            arguments.graphVersion
        );
        return variables.lastResponse = variables.client.sendBatchRequest($batchRequest);
    }

    public function request(method, endpoint, struct params, accessToken = "", eTag = "", graphVersion = ""){
        arguments.accessToken = accessToken ?: variables.defaultAccessToken;
        arguments.graphVersion = graphVersion ?: variables.defaultGraphVersion;
        return FacebookRequest.init(
            variables.app,
            arguments.accessToken,
            arguments.method,
            arguments.endpoint,
            arguments.params,
            arguments.eTag,
            arguments.graphVersion
        );
    }

    public function fileToUpload(pathToFile){
        return new FacebookFile(arguments.pathToFile);
    }

    public function videoToUpload(pathToFile){
        return new FacebookVideo(arguments.pathToFile);
    }

    public function uploadVideo(target, pathToFile, metadata = [], accessToken = "", maxTransferTries = 5, graphVersion = ""){
        arguments.accessToken = arguments.accessToken ?: variables.defaultAccessToken;
        arguments.graphVersion = arguments.graphVersion ?: variables.defaultGraphVersion;
        var uploader = new FacebookResumableUploader(variables.app, variables.client, arguments.accessToken, arguments.graphVersion);
        var endpoint = '/' & arguments.target & '/videos';
        var file = variables.videoToUpload($pathToFile);
        var chunk = uploader.start($endpoint, $file);
        do {
            chunk = variables.maxTriesTransfer(uploader, endpoint, chunk, maxTransferTries);
        } while (!$chunk.isLastChunk());
        return {
          'video_id' : arguments.chunk.getVideoId(),
          'success' : uploader.finish(arguments.endpoint, arguments.chunk.getUploadSessionId(), arguments.metadata),
        };
    }

    private function maxTriesTransfer(FacebookResumableUploader uploader, endpoint, FacebookTransferChunk chunk, retryCountdown){
        var newChunk = arguments.uploader.transfer($endpoint, $chunk, $retryCountdown < 1);
        if (newChunk !== arguments.chunk) {
            return newChunk;
        }
        arguments.retryCountdown--;
        // If transfer() returned the same chunk entity, the transfer failed but is resumable.
        return variables.maxTriesTransfer(arguments.uploader, arguments.endpoint, arguments.chunk, arguments.retryCountdown);
    }
}