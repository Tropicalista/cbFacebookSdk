component implements="IPersistentData" accessors="true" {

    property name="sessionPrefix" default="FBRLH_";

    public function init( enableSessionCheck = true ){

        if ( structKeyExists(application, "sessionManagement") ) {
            if ( arguments.enableSessionCheck && structKeyExists(application, "sessionManagement") ) {
                throw( 'Sessions are not active. Please make sure session_start() is at the top of your script.' );
            }
        }

    }

    public function get( key ){
        if (structKeyExists( session, variables.sessionPrefix & arguments.key ) ) {
            return session[variables.sessionPrefix & arguments.key];
        }
        return "";
    }

    public function set( key, value ){
        session[variables.sessionPrefix & arguments.key] = arguments.value;
    }

}