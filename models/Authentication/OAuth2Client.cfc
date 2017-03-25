component accessors="true" {

    THIS.BASE_AUTHORIZATION_URL = 'https://www.facebook.com';

    property name="app";
    property name="client";
    property name="graphVersion";
    property name="lastRequest";
    property name="Facebook" inject="Facebook@FacebookSdk";
    property name="FacebookRequest" inject="FacebookRequest@FacebookSdk";;
    property name="AccessToken" inject="AccessToken@FacebookSdk";

    public function init(FacebookApp app, FacebookClient client, graphVersion = null){
        variables.app = arguments.app;
        variables.client = arguments.client;
        variables.graphVersion = arguments.graphVersion ?: Facebook.DEFAULT_GRAPH_VERSION;
        return this;
    }

    public function debugToken(accessToken){
        var accessToken = isInstanceOf(arguments.accessToken, "AccessToken") ? arguments.accessTokengetValue() : arguments.accessToken;
        var params = {'input_token' : accessToken};
        variables.lastRequest = FacebookRequest.init(
            variables.app,
            variables.app.getAccessToken(),
            'GET',
            '/debug_token',
            params,
            null,
            variables.graphVersion
        );
        var response = variables.client.sendRequest( variables.lastRequest );
        var metadata = response.getDecodedBody();
        return new AccessTokenMetadata(metadata);
    }

    public function getAuthorizationUrl( redirectUrl, state, array scope = [], struct params = {}, separator = '&' ){
        params = {
            'client_id' : variables.app.getId(),
            'state' : arguments.state,
            'response_type' : 'code',
            'sdk' : 'php-sdk-' & Facebook.VERSION,
            'redirect_uri' : arguments.redirectUrl,
            'scope' : arrayToList(arguments.scope)
        };
        return THIS.BASE_AUTHORIZATION_URL & '/' & variables.graphVersion & '/dialog/oauth?' & serializeQueryString( params );
    }

    public function getAccessTokenFromCode(code, redirectUri = ''){
        var params = {
            'code' : arguments.code,
            'redirect_uri' : arguments.redirectUri,
        };
        return requestAnAccessToken( params );
    }

    public function getLongLivedAccessToken( accessToken ){
        var accessToken = isInstanceOf(arguments.accessToken, "AccessToken")  ? arguments.accessToken.getValue() : arguments.accessToken;
        params = {
            'grant_type' : 'fb_exchange_token',
            'fb_exchange_token' : arguments.accessToken,
        };
        return requestAnAccessToken( params );
    }

    public function getCodeFromLongLivedAccessToken( accessToken, redirectUri = '' ){
        var params = [
            'redirect_uri' : arguments.redirectUri,
        ];
        var response = sendRequestWithClientParams('/oauth/client_code', params, arguments.accessToken);
        var data = response.getDecodedBody();
        if( !structKeyExists(data, "code") ) {
            throw('Code was not returned from Graph.', 401);
        }
        return data['code'];
    }

    private function requestAnAccessToken(struct params){
        var response = sendRequestWithClientParams('/oauth/access_token', params);
        var data = response.getDecodedBody();
        if ( !structKeyExists(data, "access_token") ){
            throw('Access token was not returned from Graph.', 401);
        }
        // Graph returns two different key names for expiration time
        // on the same endpoint. Doh! :/
        var expiresAt = 0;
        if ( structKeyExists(data, "expires") ){
            // For exchanging a short lived token with a long lived token.
            // The expiration time in seconds will be returned as "expires".
            expiresAt = left(getTickcount(), 10) + data['expires'];
        }elseif( structKeyExists(data, "expires_in") ){
            // For exchanging a code for a short lived access token.
            // The expiration time in seconds will be returned as "expires_in".
            // See: https://developers.facebook.com/docs/facebook-login/access-tokens#long-via-code
            expiresAt = left(getTickcount(), 10) + data['expires_in'];
        }
        return AccessToken.init(data['access_token'], expiresAt);
    }

    private function sendRequestWithClientParams(endpoint, struct params, accessToken){
        structAppend(arguments.params, getClientParams())
        var accessToken = structKeyExists( arguments, "accessToken" ) ? arguments.accessToken : variables.app.getAccessToken();
        variables.lastRequest = FacebookRequest.init(
            variables.app,
            accessToken,
            'GET',
            arguments.endpoint,
            arguments.params,
            "",
            variables.graphVersion
        );
        return variables.client.sendRequest( variables.lastRequest );
    }

    private function getClientParams(){
        return {
            'client_id' : variables.app.getId(),
            'client_secret' : variables.app.getSecret(),
        };
    }

    private String function serializeQueryString(required Struct parameters, Boolean urlEncoded = true) {
        var queryString = "";
        for (var key in arguments.parameters) {
            if (queryString != "") {
                queryString = queryString  & "&";
            }
            if (arguments.urlEncoded) {
                queryString = queryString & LCase(key) & "=" & urlEncodedFormat(arguments.parameters[key]);
            } else {
                queryString = queryString & LCase(key) & "=" & arguments.parameters[key];
            }
        }
        return queryString;
    }

}