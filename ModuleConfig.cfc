component {

	// Module Properties
	this.title 				= "cbFacebookSdk";
	this.author 			= "Francesco Pepe";
	this.webURL 			= "";
	this.description 		= "A module to interact with Facebook Api";
	this.version			= "1.0.0";
	// Model Namespace
	this.modelNamespace		= "cbFacebookSdk";
	// CF Mapping
	this.cfmapping			= "cbFacebookSdk";
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
		binder.map("Facebook@cbFacebookSdk")
			.to('#moduleMapping#.models.Facebook')
			.noInit();		
		binder.map("FacebookApp@cbFacebookSdk")
			.to('#moduleMapping#.models.FacebookApp')
			.noInit();		
		binder.map("oAuth2Client@cbFacebookSdk")
			.to('#moduleMapping#.models.Authentication.oAuth2Client')
			.noInit();
		binder.map("FacebookRedirectLoginHelper@cbFacebookSdk")
			.to('#moduleMapping#.models.Helpers.FacebookRedirectLoginHelper')
			.noInit();
		binder.map("FacebookClient@cbFacebookSdk")
			.to('#moduleMapping#.models.FacebookClient')
			.noInit();
		binder.map("AccessToken@cbFacebookSdk")
			.to('#moduleMapping#.models.Authentication.AccessToken')
			.noInit();
		binder.map("FacebookRequest@cbFacebookSdk")
			.to('#moduleMapping#.models.FacebookRequest')
			.noInit();
		binder.map("GraphNodeFactory@cbFacebookSdk")
			.to('#moduleMapping#.models.GraphNodes.GraphNodeFactory')
			.noInit();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}