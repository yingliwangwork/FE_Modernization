var HiPKI = new function(){

	var postTarget;
	var timeoutId;
	var isReturn = false;
	var tbsData;
	var rtnData;
	var action;
	var callbackFunction;
	
	var useProdDomain = ['www.cathaylife.com.tw', 'w3.cathaylife.com.tw', 'was2.cathaylife.com.tw', 'was3.cathaylife.com.tw', 'im.cathaylife.com.tw', 'online.cathaylife.com.tw'];

	var useProdServer = false;

	var wls = window.location.toString();
	
	var keys = ['slotDescription', 'tbs', 'tbsEncoding', 'hashAlgorithm', 'withCardSN', 'pin', 'nonce', 'func', 'signatureType'];

	for(var i=0;i<useProdDomain.length;i++){
		var patternString = '\/'+useProdDomain[i]+'*';
		var regex = new RegExp(patternString);
		useProdServer = regex.test(wls);
		if(useProdServer){
			break;
		}
	}
	
	var certURL = useProdServer ? 'https://cert.cathaylife.com.tw' : 'https://tcert.cathaylife.com.tw';

	//透過ActiveX執行動作
	//method不可變
	function httpActiveX(actionMethod, url, data){
		http.actionMethod = actionMethod;
		http.url = url;	
		var code = http.sendRequest(data);
		if(code != 0){ 
			return null;
		}	
		return http.responseText;
	}
	
	/**
	 *依瀏覽器判斷是否如何取得資訊
	 *若是ie則採用ActiveX
	 *其他則透過popupForm
	 **/
	function openPopupAgent(options){

		var ua = window.navigator.userAgent;
		var isAlertMsg = options.isAlertMsg;

		//is IE, use ActiveX
		if(ua.indexOf('MSIE')!=-1 || ua.indexOf('Trident')!=-1) {
			
			//產生ActiveX要用之httpObject
			var span = document.getElementById('httpObject');
			if(!span){
				var span = document.createElement('span');
				span.id = 'httpObject';
				span.style.display = 'none';
				document.body.appendChild(span);
			}
			span.innerHTML='<OBJECT id="http" width=1 height=1 style="LEFT: 1px; TOP: 1px" type="application/x-httpclient" VIEWASTEXT></OBJECT>';
			
			//返回為json字串
			var data = httpActiveX(options.actionMethod, options.url, options.param);

			postTarget = null;
			
			if(!data) {
				if(isAlertMsg){
					alert('尚未安裝元件，或元件未啟動');
				}
				data = {};
			}else{
				data = JSON.parse(data);
			}
			
			callbackFunction(data);
			
		}else{
			postTarget = window.open('http://localhost:56001/popupForm', 'Signing','height=200, width=200, left=100, top=20');
			timeoutId = setTimeout(function(){
				checkFinish(isAlertMsg)
			}, 3500);
		}
	}
	
	//若請求無回應，關閉式窗
	function checkFinish(isAlertMsg){
		if(postTarget){
			postTarget.close();
			if(isAlertMsg){
				alert('尚未安裝元件，或元件未啟動');
			}
			callbackFunction({});
		}
	}
	
	//HTML5 跨文檔通信 API（Cross-document messaging）
	function receiveMessage(event){
	
		if(console) {
			console.log(event);
		}
		
		//安全起見，這邊應填入網站位址檢查
		if(event.origin!='http://localhost:56001'){
			return;
		}	
			
		try{
			var ret = JSON.parse(event.data);
			if(ret.func){
				if(console) {
					console.log(ret.func);
				}
				if(ret.func=='getTbs'){
					clearTimeout(timeoutId);
					var json = JSON.stringify(tbsData);
					postTarget.postMessage(json, '*');
				}else if(ret.func=='sign'){
					callbackFunction(ret);
				}else if(ret.func=='cspuser'){
					callbackFunction(ret);
				}else if(ret.func=='pkcs11info'){		
					callbackFunction(ret);	
				}else if(ret.func=='hipkiinfo'){
					callbackFunction(ret);
				}
			}else{
				if(console) {
					console.log('no func');
				}
			}
		}catch(e){
			if(console){
				console.log(e);
			}
		}
	}
	
	if (window.addEventListener) {
		window.addEventListener('message', receiveMessage, false);
	}else {
		//for IE8
		window.attachEvent('onmessage', receiveMessage);
	}
	
	return {

		getPKCS11Info:function(cb, isAlertMsg){
			action = 'pkcs11info?withcert=true';
			tbsData = {};
			tbsData.func = action;
			callbackFunction = cb;
			
			var options = {};
			options.url = 'http://localhost:56001/pkcs11info?withcert=true';
			options.actionMethod = 'GET';
			options.param = '';
			options.isAlertMsg = isAlertMsg;
			openPopupAgent(options);	
		},
		
		sign:function(param, cb, isAlertMsg){	
			action = 'sign';
			param.func = 'MakeSignature';		
			var fmtData = {};
			
			keys.map(function(key, index){
				var v = param[key];
				if(v){
					fmtData[key] = v;
				}
			})
			tbsData = param;	
			callbackFunction = cb;	
			var options = {};	
			options.url = 'http://localhost:56001/sign';
			options.actionMethod = 'POST';
			options.param = 'tbsPackage=' + JSON.stringify(fmtData);
			options.isAlertMsg = isAlertMsg;
			openPopupAgent(options);
		},
		
		cspuser:function(param, cb, isAlertMsg){	
			action = 'cspuser';
			param.func = 'CSPUser';		
			tbsData = param;	
			callbackFunction = cb;	
			var options = {};	
			options.url = 'http://localhost:56001/cspuser';
			options.actionMethod = 'POST';
			options.param = 'tbsPackage=' + JSON.stringify(param);	
			options.isAlertMsg = isAlertMsg;
			openPopupAgent(options);
		},
		
		doVerifyP7:function(options){
		
			var param = '';	   
			for(var key in options){
				var v = options[key];
				if(v){
					if(param){
						param = param + '&';
					}
					param = param + key + '=' + options[key];
				}
			}
			
			var xhttp = new XMLHttpRequest();
					
			xhttp.onreadystatechange = function() {
				if (xhttp.readyState == 4 && xhttp.status == 200) {
					var resp = JSON.parse(xhttp.responseText);
					options.resp = resp;
				}
			};
			xhttp.open('POST', certURL+'/VerifyServletClient/VerifyP7', false);
			xhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
			xhttp.send(param);	
		},
		
		isSuccess:function(data){
			if(data.ret_code != 0 ){
				var msg = MajorErrorReason(data.ret_code);	
				if(data.last_error){
					msg = msg +' : '+MinorErrorReason(data.last_error);
				}
				alert(msg);
				return false;
			}
			return true;
		}
	};
};