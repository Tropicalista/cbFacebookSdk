component implements="IUrlDetection" {

    public function init(){
        return this;
    }

    public function getCurrentUrl(){
        return cgi.REQUEST_URL;
    }

    private function getHttpScheme(){
        return isBehindSsl() ? 'https' : 'http';
    }

    private function isBehindSsl(){
        if( isBoolean( cgi.server_port_secure ) AND cgi.server_port_secure){ return true; }
        // Add typical proxy headers for SSL
        if( getHTTPHeader( "x-forwarded-proto", "http" ) eq "https" ){ return true; }
        if( getHTTPHeader( "x-scheme", "http" ) eq "https" ){ return true; }
        return false;
    }

    private function getHTTPHeader( required header, defaultValue="" ){
        var headers = getHttpRequestData().headers;

        if( structKeyExists( headers, arguments.header ) ){
            return headers[ arguments.header ];
        }
        if( structKeyExists( arguments, "defaultValue" ) ){
            return arguments.defaultValue;
        }

        throw( message="Header #arguments.header# not found in HTTP headers",
               detail="Headers found: #structKeyList( headers )#",
               type="RequestContext.InvalidHTTPHeader");
    }

}