component {

	// Module Properties
	this.title 				= "FacebookSdk";
	this.author 			= "";
	this.webURL 			= "";
	this.description 		= "";
	this.version			= "1.0.0";
	// Model Namespace
	this.modelNamespace		= "FacebookSdk";
	// CF Mapping
	this.cfmapping			= "FacebookSdk";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	function configure(){

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		binder.map("Facebook@FacebookSdk")
			.to('#moduleMapping#.models.Facebook')
			.noInit();		
		binder.map("FacebookApp@FacebookSdk")
			.to('#moduleMapping#.models.FacebookApp')
			.noInit();		
		binder.map("oAuth2Client@FacebookSdk")
			.to('#moduleMapping#.models.Authentication.oAuth2Client')
			.noInit();
		binder.map("FacebookRedirectLoginHelper@FacebookSdk")
			.to('#moduleMapping#.models.Helpers.FacebookRedirectLoginHelper')
			.noInit();
		binder.map("FacebookClient@FacebookSdk")
			.to('#moduleMapping#.models.FacebookClient')
			.noInit();
		binder.map("AccessToken@FacebookSdk")
			.to('#moduleMapping#.models.Authentication.AccessToken')
			.noInit();
		binder.map("FacebookRequest@FacebookSdk")
			.to('#moduleMapping#.models.FacebookRequest')
			.noInit();
		binder.map("GraphNodeFactory@FacebookSdk")
			.to('#moduleMapping#.models.GraphNodes.GraphNodeFactory')
			.noInit();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}