var HTML_locate_base = "";

function getLocateBase(){
	if(!HTML_locate_base){
		if(!window.HTML_locate_base || window.HTML_locate_base !== false){
			HTML_locate_base = location.href.split("servlet");

			if(HTML_locate_base.length <= 1 ){
				HTML_locate_base = location.href.split("html");
			}
			if(HTML_locate_base.length > 1 ){
				HTML_locate_base = HTML_locate_base[0];
			}else{
				HTML_locate_base = false;
			}
		}
	}
}

if(!window.popupWin){
	getLocateBase();
	var head = document.getElementsByTagName('HEAD')[0];
    var sc = document.createElement('script');
    sc.src = HTML_locate_base +"html/CM/js/ui/popupWin.js";
    head.appendChild(sc);
}

var crossForward = new CrossForwardUI();

/**
 * 程式：crossForward.js 導頁相關 js
 * 作者：楊宗翰
 * 功能：提供跨網域導頁機制
 * 完成：2014/02/18
 * 更新：
 *           Date         Author                                                    Description
 *      ==============  ==========  ==============================================================================================================
 *			2014/02/18		楊宗翰
 *
 * 說明：
 *           public function                                                        Description
 *      =========================   =============================================================================================================
 *        	forward						跨網域導頁
 **/
function CrossForwardUI(){
	var targets = {
		"popupWin":["POPUPWIN", "FULLPOPUP", "WINDOWOPEN"]
		,"form_target":["_blank", "_self", "_parent", "_top"]
	};

	var actions = {
		forward: function(config){
			getLocateBase();
			var src = HTML_locate_base + "servlet/HttpDispatcher/SysLogin/forward";

			if(config && (config instanceof Object)){
				var keys = Object.keys(config);
				if(keys.length > 0){
					var target = config.target;
					var paramKeys = ["url", "function_id", "PLATFORM", "params"];

					if(utils.isPopupWin(target)){
						var parameters = {};
						// 參數加入
						for(var i=0; i<paramKeys.length; i++){
							var key = paramKeys[i];

							if(config[key]){
								var value = config[key];
								parameters[key]= utils.getJSONStr(value);
							}
						}

						target = target.toUpperCase();
						if(target == targets["popupWin"][0]){
							popupWin.popup({
								src: src
								,parameters: parameters
							});
						}else if(target == targets["popupWin"][1]){
							popupWin.fullPopup({
								src: src
								,parameters: parameters
							});
						}else{
							var tmp = {};
							var attributeKeys = ["attributes", "windowName", "fullScreen"];
							for(var i=0; i<attributeKeys.length; i++){
								var key = attributeKeys[i];

								if(config[key]){
									var value = config[key];
									tmp[key]= utils.getJSONStr(value);
								}
							}
							tmp["parameters"]=parameters;
							popupWin.windowOpen(src, tmp);
						}

						if(config["callbackHandler"]){
							popupWin.callbackHandler = config["callbackHandler"]
						}
					}else{
						var form = document.createElement('form');
						form.id = '_crossForward_form';
						form.method = 'post';
						form.action = src;
						form.target = config["target"] ? config["target"] : "_self";
						
						document.body.appendChild(form);

						for(var i=0; i<paramKeys.length; i++){
							var key = paramKeys[i];

							if(config[key]){
								var value = config[key];

								var input = document.createElement('input');
								input.id = key;
								input.name = key;
								input.type = 'hidden';
								input.value = utils.getJSONStr(value);

								form.appendChild(input);
							}
						}

						form.submit();
					}
				}
			}
		}
	}

	var utils = {
		isPopupWin: function(target){
			if(target){
				target = target.toUpperCase();
				for(var i=0; i<targets["popupWin"].length; i++){
					if(targets["popupWin"][i] == target){
						return true;
					}
				}
			}

			return false;
		}
		, getJSONStr: function(value){
			if(typeof(value) == "object"){
				if(window.Prototype){
					return Object.toJSON(value);
				}else if(window.JSON && JSON.stringify){
					return JSON.stringify(utils.filterObject(value));
				}else{
					throw '無引用Prototype且IE版本過低，無法使用原生轉JSON方法';
				}
			}
			return value;
		}
		,filterObject: function(obj){
			var type = Object.prototype.toString.apply(obj);
			if(type =='[object Object]' && !obj.tagName){
				var rtn = {};
				for(var key in obj){
					rtn[key] = utils.filterObject(obj[key]);
				}
				return rtn;
			}else if(type =='[object Array]'){
				var rtn = [];
				for(var i = 0; i < obj.length; i++){
					rtn[i] = utils.filterObject(obj[i]);
				}
				return rtn;
			}else{
				return "" + obj;
			}
		}
	}

	/**
	 *  @public
	 *	@class 導頁(主要是做跨網域)
	 *	@param config (Map)
	 *	@param config.url (String) : 目標頁面的 url
	 *	@param config.function_id (String) : 目標頁面(jsp)的ID
	 *	@param config.PLATFORM (String) : 目標頁面所在的平台
	 *	@param config.params (Map) : 要傳遞給目標頁面的資料
	 *	@param config.target (String) : 目標頁面的開啟方式(popupWin, fullPopup, windowOpen By popupWin.js 或是 form 的 target 屬性)，預設為 form 的 target="_self"
	 *	@param config.callbackHandler (Function) : popupWin 使用
	 *  以下屬性為 popupWin 的 windowOpen 使用
	 *	@param config.attributes (Map) : window open 屬性（如：status, toolbar, menubar, resizable, width, height, top, left ...等）
	 *	@param config.windowName (String) : 開啟視窗的名稱
	 *	@param config.fullScreen (Boolean) : 是否全螢幕，預設為 false
	 **/
	this.forward = actions.forward;
}