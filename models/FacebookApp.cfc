component accessors="true" {

    property name="id";
    property name="secret";

    property name="AccessToken" inject="AccessToken@cbFacebookSdk";;

    public function init(id, secret){
        // We cast as a string in case a valid int was set on a 64-bit system and this is unserialised on a 32-bit system
        variables.id = javacast("string", arguments.id);
        variables.secret = arguments.secret;
        return this;
    }

    public function getAccessToken(){
        return AccessToken.init(variables.id & '|' & variables.secret);
    }

    public function serialize(){
        return ArrayToList( [variables.id, variables.secret], '|' );
    }

    public function unserialize(serialized){
        var args = listToArray(arguments.serialized, "|");
        init(args[1], args[2]);
    }
}