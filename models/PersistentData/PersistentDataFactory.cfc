component {

    property name="FbSession" inject="FacebookSessionPersistentDataHandler@cbFacebookSdk";
    property name="FbMemory" inject="FacebookMemoryPersistentDataHandler@cbFacebookSdk";

    public function init(){
        return this;
    }

    public function createPersistentDataHandler( handler="memory" ){

        if ( arguments.handler EQ "memory" || !len(arguments.handler) ) {
            return FbMemory;
        }
        if (!structKeyExists( arguments, "handler" ) OR isNull( arguments.handler ) ) {
            return FbSession;
        }
        if ( isInstanceOf( arguments.handler, "IPersistentData" ) ) {
            return arguments.handler;
        }
        if ( arguments.handler EQ "session" ) {
            return FbSession;
        }
        throw('The persistent data handler must be set to "session", "memory", or be an instance of Facebook\PersistentData\PersistentDataInterface');
    }

}