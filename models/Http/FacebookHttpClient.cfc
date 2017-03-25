component accessors="true" {

	property name="body";
	property name="headers";
	property name="httpResponseCode";

	public function init(){
		return this;
	}

    public function send(url, method, body, struct headers, timeOut = 10){
    	
		var httpService = new http(); 

		httpService.setMethod(arguments.method); 
		httpService.setUrl(arguments.url); 
		httpService.setTimeout(arguments.timeOut); 

		for( h in arguments.headers ){
			httpService.addParam( type="header", name="#h#", value="#arguments.headers[h]#" ); 
		}
		if( method NEQ "GET" ){
			httpService.addParam( type="body", value="#serializeJSON(arguments.body)#" ); 
		}

        try {
            var result = httpService.send().getPrefix();
        }catch(any e) {
        	dump(e);
        }

        setBody( result.filecontent );
        setHttpResponseCode( result.status_code );
        setHeaders( result.responseheader );

        return this;

    }

}