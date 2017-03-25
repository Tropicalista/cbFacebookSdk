component accessors="true" {

    property name="httpStatusCode";
    property name="headers";
    property name="body";
    property name="decodedBody";
    property name="request";
    property name="thrownException";

    property name="GraphNodeFactory" inject="GraphNodeFactory@cbFacebookSdk";

    public function init(FacebookRequest request, body = "", httpStatusCode = "", struct headers ){
        variables.request = arguments.request;
        variables.body = arguments.body;
        variables.httpStatusCode = arguments.httpStatusCode;
        variables.headers = structKeyExists( arguments, "headers" ) ? arguments.headers : {};

        decodeBody();
        return this;
    }

    public function getApp(){
        return variables.request.getApp();
    }

    public function getAccessToken(){
        return variables.request.getAccessToken();
    }

    public function getAppSecretProof(){
        return variables.request.getAppSecretProof();
    }

    public function getETag(){
        return structKeyExists( variables.headers, "ETag" ) ? variables.headers['ETag'] : "";
    }

    public function getGraphVersion(){
        return structKeyExists( variables.headers, "Facebook-API-Version" ) ? variables.headers['Facebook-API-Version'] : "";
    }

    public function isError(){
        return structKeyExists( variables.headers, "error" );
    }


    public function makeException(){
        variables.thrownException = FacebookResponseException.create(this);
    }

    public function decodeBody(){
        variables.decodedBody = deserializeJSON(variables.body);

        if( isBoolean(variables.decodedBody ) ){
            // Backwards compatibility for Graph < 2.1.
            // Mimics 2.1 responses.
            // @TODO Remove this after Graph 2.0 is no longer supported
            variables.decodedBody['success'] = variables.decodedBody;
        } elseif(isNumeric( variables.decodedBody ) ){
            variables.decodedBody['id'] = variables.decodedBody;
        }

        if ( !isStruct(variables.decodedBody ) ){
            variables.decodedBody = {};
        }

        if( variables.isError() ){
            makeException();
        }
    }

    public function getGraphObject( required subclassName ){
        return getGraphNode( arguments.subclassName );
    }

    public function getGraphNode( required subclassName ){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphNode($subclassName);
    }

    public function getGraphAlbum(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphAlbum();
    }

    public function getGraphPage(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphPage();
    }

    public function getGraphSessionInfo(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphSessionInfo();
    }

    public function getGraphUser(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphUser();
    }

    public function getGraphEvent(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphEvent();
    }

    public function getGraphGroup(){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphGroup();
    }

    public function getGraphList( subclassName = "", auto_prefix = true ){
        return getGraphEdge( arguments.subclassName, arguments.auto_prefix );
    }

    public function getGraphEdge( subclassName = "", auto_prefix = true ){
        var factory = GraphNodeFactory.init(this);

        return factory.makeGraphEdge( arguments.subclassName, arguments.auto_prefix );
    }

}
