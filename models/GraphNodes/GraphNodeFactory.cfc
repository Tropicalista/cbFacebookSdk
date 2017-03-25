component accessors="true" {

    property name="response";
    property name="decodedBody";

    property name="wirebox" inject="wirebox";

    public function init(FacebookResponse response){
        variables.response = arguments.response;
        variables.decodedBody = arguments.response.getDecodedBody();
        return this;
    }

    public function makeGraphNode(subclassName = ""){
        validateResponseAsStruct();
        validateResponseCastableAsGraphNode();

        return castAsGraphNodeOrGraphEdge( variables.decodedBody, arguments.subclassName );
    }

    public function makeGraphAchievement(){
        return makeGraphNode('GraphAchievement');
    }

    public function makeGraphAlbum(){
        return makeGraphNode('GraphAlbum');
    }

    public function makeGraphPage(){
        return makeGraphNode('GraphPage');
    }

    public function makeGraphSessionInfo(){
        return makeGraphNode('GraphSessionInfo');
    }

    public function makeGraphUser(){
        return makeGraphNode('GraphUser');
    }

    public function makeGraphEvent(){
        return makeGraphNode('GraphEvent');
    }

    public function makeGraphGroup(){
        return makeGraphNode('GraphGroup');
    }

    public function makeGraphEdge( subclassName = "" ){
        validateResponseAsStruct();
        validateResponseCastableAsGraphEdge();

        if ( len( subclassName ) ) {
            var subclassName = arguments.subclassName;
        }

        return castAsGraphNodeOrGraphEdge( variables.decodedBody, subclassName );
    }

    public function validateResponseAsStruct(){
        if (!isStruct(variables.decodedBody)) {
            throw('Unable to get response from Graph as array.', 620);
        }
    }

    public function validateResponseCastableAsGraphNode(){
        if ( structKeyExists(variables.decodedBody, "data") && isCastableAsGraphEdge(variables.decodedBody['data'])){
            throw(
                'Unable to convert response from Graph to a GraphNode because the response looks like a GraphEdge. Try using GraphNodeFactory::makeGraphEdge() instead.',
                620
            );
        }
    }

    public function validateResponseCastableAsGraphEdge(){
        if (!structKeyExists(variables.decodedBody, "data") && isCastableAsGraphEdge(variables.decodedBody['data'])){
            throw(
                'Unable to convert response from Graph to a GraphEdge because the response does not look like a GraphEdge. Try using GraphNodeFactory::makeGraphNode() instead.',
                620
            );
        }
    }

    public function safelyMakeGraphNode(struct data, subclassName = ""){

        validateSubclass(arguments.subclassName);

        // Remember the parent node ID
        var parentNodeId = structKeyExists(arguments.data, "id") ? arguments.data['id'] : "";

        items = {};
        dump(arguments);abort;
        /*foreach ($data as $k => $v) {
            // Array means could be recurable
            if (is_array($v)) {
                // Detect any smart-casting from the $graphObjectMap array.
                // This is always empty on the GraphNode collection, but subclasses can define
                // their own array of smart-casting types.
                $graphObjectMap = $subclassName::getObjectMap();
                $objectSubClass = isset($graphObjectMap[$k])
                    ? $graphObjectMap[$k]
                    : null;

                // Could be a GraphEdge or GraphNode
                $items[$k] = $this->castAsGraphNodeOrGraphEdge($v, $objectSubClass, $k, $parentNodeId);
            } else {
                $items[$k] = $v;
            }
        }

        return new $subclassName($items);*/
    }

    public function castAsGraphNodeOrGraphEdge(struct data, subclassName = "", parentKey = "", parentNodeId = ""){
        if ( structKeyExists(arguments.data, "data") ){
            // Create GraphEdge
            if( isCastableAsGraphEdge( arguments.data['data'] ) ) {
                return safelyMakeGraphEdge($data, $subclassName, $parentKey, $parentNodeId);
            }
            // Sometimes Graph is a weirdo and returns a GraphNode under the "data" key
            var data = arguments.data['data'];
        }

        // Create GraphNode
        return safelyMakeGraphNode(data, arguments.subclassName);
    }

    public function safelyMakeGraphEdge(array $data, $subclassName = null, $parentKey = null, $parentNodeId = null){
        if ( !structKeyExists(arguments.data, "data") ){
            throw new FacebookSDKException('Cannot cast data to GraphEdge. Expected a "data" key.', 620);
        }

        var dataList = {};
        /*foreach ($data['data'] as $graphNode) {
            $dataList[] = $this->safelyMakeGraphNode($graphNode, $subclassName);
        }

        var metaData = getMetaData( arguments.data );

        // We'll need to make an edge endpoint for this in case it's a GraphEdge (for cursor pagination)
        $parentGraphEdgeEndpoint = $parentNodeId && $parentKey ? '/' . $parentNodeId . '/' . $parentKey : null;
        $className = static::BASE_GRAPH_EDGE_CLASS;

        return new $className($this->response->getRequest(), $dataList, $metaData, $parentGraphEdgeEndpoint, $subclassName);*/
    }

    public function getMetaData(struct data){
        structDelete(arguments.data, "data")
        return arguments.data;
    }

    public function isCastableAsGraphEdge( struct data ){
        if ( isStruct(arguments.data ) ) {
            return true;
        }

        // Checks for a sequential numeric array which would be a GraphEdge
        //return array_keys($data) === range(0, count($data) - 1);
    }

    public function validateSubclass(subclassName){
        if ( len(subclassName) ){
            return;
        }

        throw('The given subclass "' & arguments.subclassName & '" is not valid. Cannot cast to an object that is not a GraphNode subclass.', 620);
    }
}
