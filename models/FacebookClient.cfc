component accessors="true" {

    THIS.BASE_GRAPH_URL = 'https://graph.facebook.com';
    THIS.BASE_GRAPH_VIDEO_URL = 'https://graph-video.facebook.com';
    THIS.BASE_GRAPH_URL_BETA = 'https://graph.beta.facebook.com';
    THIS.BASE_GRAPH_VIDEO_URL_BETA = 'https://graph-video.beta.facebook.com';
    THIS.DEFAULT_REQUEST_TIMEOUT = 60;
    THIS.DEFAULT_FILE_UPLOAD_REQUEST_TIMEOUT = 3600;
    THIS.DEFAULT_VIDEO_UPLOAD_REQUEST_TIMEOUT = 7200;
    THIS.requestCount = 0;
    
    property name="enableBetaMode" default="false";
    property name="httpClientHandler";

    property name="FacebookResponse" inject="FacebookResponse@cbFacebookSdk";

    public function init( httpClientHandler, enableBeta = false ){
        variables.httpClientHandler = arguments.httpClientHandler;
        variables.enableBetaMode = arguments.enableBeta;
        return this;
    }

    public function enableBetaMode($betaMode = true){
        variables.enableBetaMode = arguments.betaMode;
    }

    public function getBaseGraphUrl(postToVideoUrl = false){
        if (arguments.postToVideoUrl) {
            return variables.enableBetaMode ? THIS.BASE_GRAPH_VIDEO_URL_BETA : THIS.BASE_GRAPH_VIDEO_URL;
        }
        return variables.enableBetaMode ? THIS.BASE_GRAPH_URL_BETA : THIS.BASE_GRAPH_URL;
    }

    public function prepareRequestMessage(FacebookRequest request){
        var postToVideoUrl = arguments.request.containsVideoUploads();
        var fbUrl = getBaseGraphUrl(postToVideoUrl) & arguments.request.getUrl();
        // If we're sending files they should be sent as multipart/form-data
        if (arguments.request.containsFileUploads()) {
            var requestBody = arguments.request.getMultipartBody();
            arguments.request.setHeaders({
                'Content-Type' : 'multipart/form-data; boundary=' & requestBody.getBoundary(),
            });
        }
        else{
            var requestBody = arguments.request.getUrlEncodedBody();
            arguments.request.setHeaders({
                'Content-Type' : 'application/x-www-form-urlencoded'
            });
        }
        return {
            url : fbUrl,
            method : arguments.request.getMethod(),
            headers : arguments.request.getHeaders(),
            body : requestBody.getBody(),
        };
    }

    public function sendRequest(FacebookRequest request){
        if ( isInstanceOf( arguments.request, 'FacebookRequest' ) ){
            arguments.request.validateAccessToken();
        }
        fbRequest = prepareRequestMessage(arguments.request);

        // Since file uploads can take a while, we need to give more time for uploads
        var timeOut = THIS.DEFAULT_REQUEST_TIMEOUT;
        if ( arguments.request.containsFileUploads() ){
            var timeOut = THIS.DEFAULT_FILE_UPLOAD_REQUEST_TIMEOUT;
        }elseif( arguments.request.containsVideoUploads() ){
            var timeOut = THIS.DEFAULT_VIDEO_UPLOAD_REQUEST_TIMEOUT;
        }
        // Should throw `FacebookSDKException` exception on HTTP client error.
        // Don't catch to allow it to bubble up.
        var rawResponse = variables.httpClientHandler.send(fbRequest.url, fbRequest.method, fbRequest.body, fbRequest.headers, timeOut);
        THIS.requestCount++;
        var returnResponse = FacebookResponse.init(
            arguments.request,
            rawResponse.getBody(),
            rawResponse.getHttpResponseCode(),
            rawResponse.getHeaders()
        );
        if (returnResponse.isError()) {
            throw returnResponse.getThrownException();
        }
        return returnResponse;
    }

    public function sendBatchRequest(FacebookBatchRequest request){
        arguments.request.prepareRequestsForBatch();
        var facebookResponse = sendRequest(arguments.request);
        return new FacebookBatchResponse(arguments.request, facebookResponse);
    }
}