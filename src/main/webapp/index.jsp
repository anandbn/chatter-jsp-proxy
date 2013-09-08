<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="https://always-a-developer-edition.na9.force.com/resource/1371244154000/chatter_io_js_1_1/chatterio.css">
  <link rel="stylesheet" type="text/css" href="https://always-a-developer-edition.na9.force.com/resource/1371244154000/chatter_io_js_1_1/jquery-ui.css">
  <style type="text/css">
  	#loginBtn {
		-webkit-appearance: none;
		-webkit-border-horizontal-spacing: 0px;
		-webkit-border-image: none;
		-webkit-border-vertical-spacing: 0px;
		-webkit-box-align: center;
		-webkit-box-shadow: rgba(255, 255, 255, 0.2) 0px 1px 0px 0px inset, rgba(0, 0, 0, 0.0470588) 0px 1px 2px 0px;
		background-color: #49AFCD;
		background-image: -webkit-linear-gradient(top, #5BC0DE, #2F96B4);
		background-repeat: repeat-x;
		border-bottom-color: rgba(0, 0, 0, 0.247059);
		border-bottom-left-radius: 4px;
		border-bottom-right-radius: 4px;
		border-bottom-style: solid;
		border-bottom-width: 1px;
		border-collapse: separate;
		border-left-color: rgba(0, 0, 0, 0.0980392);
		border-left-style: solid;
		border-left-width: 1px;
		border-right-color: rgba(0, 0, 0, 0.0980392);
		border-right-style: solid;
		border-right-width: 1px;
		border-top-color: rgba(0, 0, 0, 0.0980392);
		border-top-left-radius: 4px;
		border-top-right-radius: 4px;
		border-top-style: solid;
		border-top-width: 1px;
		box-shadow: rgba(255, 255, 255, 0.2) 0px 1px 0px 0px inset, rgba(0, 0, 0, 0.0470588) 0px 1px 2px 0px;
		box-sizing: border-box;
		color: white;
		cursor: pointer;
		display: inline-block;
		font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
		font-size: 14px;
		font-weight: normal;
		height: 30px;
		letter-spacing: normal;
		line-height: 20px;
		margin-bottom: 0px;
		margin-left: 0px;
		margin-right: 0px;
		margin-top: 0px;
		max-width: none;
		padding-bottom: 4px;
		padding-left: 12px;
		padding-right: 12px;
		padding-top: 4px;
		text-align: center;
		text-indent: 0px;
		text-shadow: rgba(0, 0, 0, 0.247059) 0px -1px 0px;
		text-transform: none;
		vertical-align: middle;
		word-spacing: 0px;
		word-wrap:;
	}
	</style>
</head>
<body>
<div id='chatter' style="width:500px;"></div>
<script type="text/javascript" src="https://always-a-developer-edition.na9.force.com/resource/1371244154000/chatter_io_js_1_1/chatterio.js"></script>
<script type="text/javascript">
  var config = {
    scope: 'full',
    unauthorized: function(){
      console.log("unauthorized()");
      var signInButton = $('<button id="loginBtn" href="#"></button>').html('Login');
      signInButton.click(function(){force.oauth.authorize();});
      $('#chatter').append(signInButton);
    },
    authorized: function(token){
		console.log("authorized()");
		console.log(token);

		$('#chatter').children().remove();
		Sfdc.Chatter.Feed.create({
		  el: '#chatter',
		  connection: {
			sid: token.access_token,
			host:token.instance_url,
			proxy: {
			  url: '/chatter.jsp?path=${host}${path}',
			  headers: [
				{name: 'Authorization', value: 'OAuth ${sid}' }
			  ]
			}
		  },
		  success: function(){
			console.log('success!Chatter feed should be displayed');
		  },
		  error:  function(err){ 
		  	console.log('ruh-roh: ' + err);
		  }
		});
	

    }
  }

  
  //Force OAuth Javacsript
  var force = window.force || {}
  
  force.oauth = {
    
    defaults: {
      scope:                      'id',
      loginUrl:                   'https://login.salesforce.com',
      callbackPath:               undefined,
      popup:                      true,
      cacheTokenInSessionStorage: false,
      unauthorized:               undefined,
      error:                      undefined
    },

    configure: function(config){
      for(var prop in this.defaults) this[prop] = this.defaults[prop];
      for(var prop in config       ) this[prop] = config[prop];
    },
    
    ready: function(config){
      if(!config) 
        throw 'No config!';
      if(!config.clientId) 
        throw 'No clientId property in config!';
      if(!config.authorized) 
        throw 'No authorized property in config!';
      if(!(typeof config.authorized === 'function')) 
        throw 'authorized config property must be a function!';
      if(config.unauthorized && !(typeof config.unauthorized === 'function')) 
        throw 'unauthorized config property must be a function!';
      if(!config.popup && !config.cacheTokenInSessionStorage)
        throw 'popup must be enabled if cacheTokenInSessionStorage is enabled';
      
      this.configure(config);

           if(this.hasAuthorizationResponse()) this.callback();
      else if(this.hasSessionToken()         ) this.authorized(this.getSessionToken());
      else if(this.unauthorized              ) this.unauthorized();
      else                                     this.authorize();
    },
    
    authorize: function(){
      var theUrl = this.getAuthorizeUrl('popup');
      if(this.popup) this.openPopup(this.getAuthorizeUrl('popup'));            
      else           this.setWindowLocationHref( this.getAuthorizeUrl('page' ));
    },

    callback: function(config){
      if(config) this.configure(config);
      if(opener) opener.force.oauth._callback(window);
      else       this._callback();
    },
    
    _callback: function(popup){
      authorizationResponse = this.parseAuthorizationResponse((popup ? popup.location.hash : this.getWindowLocationHash()));
      if(authorizationResponse.error){
        if(this.error) this.error(authorizationResponse);
        else           throw authorizationResponse;
      } 
      this.setSessionToken(authorizationResponse);
      if(popup){
        popup.close();
        this.authorized(authorizationResponse);
      } else {
        this.replaceWindowLocation(authorizationResponse.state);
      }
    },
    
    clearSessionToken: function(token){
      sessionStorage.setItem('token',undefined);
    },
    
    setSessionToken: function(token){
      if(this.cacheTokenInSessionStorage)
        sessionStorage.setItem('token',JSON.stringify(token));
    },
    
    getSessionToken: function(){
      var token = undefined;
      try{ token = JSON.parse(sessionStorage.getItem('token')); }catch(err){}
      return token;
    },
    
    hasSessionToken: function(){
      return this.getSessionToken() && this.getSessionToken() != null;
    },
    
    parseAuthorizationResponse: function(hashFragment){
      var authorizationResponse = {};
      if(hashFragment) {
		    if(hashFragment[0] === '#') hashFragment = hashFragment.substr(1);
				var nvps = hashFragment.split('&');
				for (var nvp in nvps) {
			    var parts = nvps[nvp].split('=');
					authorizationResponse[parts[0]] = unescape(parts[1]);
				}
      }
      if(!authorizationResponse.access_token && !authorizationResponse.error) 
        authorizationResponse = undefined;
      return authorizationResponse;
    },
    
    hasAuthorizationResponse: function(hashFragment){
      if(!hashFragment) hashFragment = this.getWindowLocationHash();
      if(hashFragment) {
		    if(hashFragment[0] === '#') hashFragment = hashFragment.substr(1);
				var nvps = hashFragment.split('&');
				for (var nvp in nvps) {
			    var part = nvps[nvp].split('=');
			    if(part) part = part[0];
			    if(part && (part === 'access_token' || part === 'error')) return true;
				}
      }
      return false;
    },
    
    getAuthorizeUrl: function(display){
      var returnValue = this.loginUrl + 
        '/services/oauth2/authorize?response_type=token' + 
        '&display=' + escape(display) + 
        '&scope=' + escape(this.scope) +
        '&client_id=' + escape(this.clientId) + 
        '&redirect_uri=' + escape(this.getRedirectUrl()) + 
        '&state=' + escape(this.getWindowLocationHref());
      return returnValue;
    },

    openPopup: function(url){
      window.open(url, 'Connect', 'height=524,width=675,toolbar=0,scrollbars=0' 
        + ',status=0,resizable=0,location=0,menuBar=0,left=' 
        + window.screenX + (((window.outerWidth/2) - (675/2)))
        + ',top=' 
        + window.screenY + (((window.outerHeight/2) - (524/2)))
      ).focus();
    },
    
    getRedirectUrl: function(){
      return window.location.protocol + '//' + window.location.host + 
        (this.callbackPath ? this.callbackPath : window.location.pathname);
    },
    
    getCurrentUrl: function(){
      return window.location.protocol + '//' + window.location.host + window.location.pathname;
    },
    setWindowLocationHref: function(url){ window.location.href = url  ;},
    getWindowLocationHref: function(   ){ return window.location.href ;},
    replaceWindowLocation: function(url){ window.location.replace(url);},
    getWindowLocationHash: function(   ){ return window.location.hash ;}
    
  }
</script>
<script type='text/javascript'>
 
  $(function(){
    config.popup = true;
    config.cacheTokenInSessionStorage = true;
    config.clientId = '<%= System.getenv("client_id")!=null?
    								System.getenv("client_id"):
    								"3MVG9y6x0357HlefnLzrysj7TpflcJ5dXrCqVhymraRe7bKROKaPfSc8GF0di.Tk8lQq11cx_ntV3jUkdzJzV" 
    					%>';
    config.callbackPath = undefined;

    force.oauth.ready(config); 
  });
</script>


</body>


</html>