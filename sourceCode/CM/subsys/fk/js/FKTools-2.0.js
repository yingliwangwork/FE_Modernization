/**
 * Ajax global default config
 * [20240301][LISYSFK-4172] 修改件 陳慶州
 * 1.JQuery 升級3.6程式調整  
 */
(function( $, undefined ) {
	/**
	 * 在 ajax 請求發送前，先檢查 dataType 的設定，
	 * 若不是 json ，則加上 X-Requested-OutputType 的標頭，
	 * 讓核心端的 AjaxFilter 忽略此 ajax 請求的回應處理，
	 * 不強制轉為 json 回傳，讓使用 ajax 載入 jsp 網頁可以運作
	 */
	$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {

		var dataType = options['dataType'],
			prefix = '?';
		
		/**
		 * 預設 ajax 請求使用 post, $.load 則維持預設定
		 */ 
		if(originalOptions) {
			var originalRequestType = originalOptions['type'] || originalOptions['method'];
			if(dataType != 'html' && !originalRequestType) {
				options['type'] = 'POST';
				options['method'] = 'POST';
			}
		}

		if( dataType && dataType != 'json' ) {
			options['headers'] = {'X-Requested-OutputType':dataType};
			options['fk_load'] = true;			
		}
		
		/**
		 * 以query string方式傳遞eBAF_UserObject_Flag
		 */
		if(options.url.indexOf('?') > -1) {
			prefix = '&';
		}
		
		options.url += prefix + 'eBAF_UserObject_Flag=' + checkNull(sessionStorage.getItem('FK_eBAF_UserObject_Flag'));
	});
	
	/**
	 *  全域的 ajax 及 submit handler
	 *  用來防止重複按按鈕
	 */
	var globalCoverOption = {
			className : 'tmp_fk_global_cover',
			backgroundColor : 'rgb(0, 0, 0)',
			opacity         : 0.7,
			loader          : 'ball-pulse-rise'
		},
		covered = false;
	
	
	$( document ).ajaxSend(function(event, xhr, options) { 
		// only cover when first ajax request send
		if(covered) {
			return;
		}

		// $.load is doing content loading, ignore
		if(options && options['fk_load']) {
			return;
		}

		covered = true;
		$('body').cover(globalCoverOption);	
		
	}).ajaxStop(function() {
		// all ajax requests complete
		$('body').uncover(globalCoverOption);
		covered = false;
	}).on( 'submit', 'form', function() { 
		// all submit request
		$(this).append($('<input type="hidden" name="eBAF_UserObject_Flag" value="' + checkNull(sessionStorage.getItem('FK_eBAF_UserObject_Flag')) +'"></input>'));
		$('body').cover(globalCoverOption);	
	}).on( 'click', 'a[href]', function(e) {
		var href = $(this).attr('href');
		if(href && href.indexOf('#') != 0 && href.indexOf('javascript') == -1) {
			//build a temp form to submit
			if(href.indexOf('?') != -1) {
				
				e.preventDefault();
				
				var queryPair = href.split('?'),
					action    = queryPair[0],
					queryString = queryPair[1],
				    $form = $("<form>");
				
				$form.attr('action', action);
				$form.attr('method', 'post');
				
				queryString = queryString.split('&');
				
				queryString.push('eBAF_UserObject_Flag=' + checkNull(sessionStorage.getItem('FK_eBAF_UserObject_Flag')));
				
				for(var i = 0; i < queryString.length; i++) {
					var aPair = queryString[i].split('=');
					$form.append('<input type="hidden" name="' + aPair[0] + '" value="' + aPair[1] + '" />');
				}
				
				$('body').append($form);
				$form.trigger('submit');
				return;
				
			}
			
			$('body').cover(globalCoverOption);	
		}
	});
	
	//傳入參數null or undefined判斷
	var checkNull = function ( data ) {
		if ((data == null && data == undefined) || data === "null") {
			return "";
		}
		return data;
	};
	
	/**
	 * 判斷是否是 AjaxFilter 寫回的 json 資料，是的話該要有 ErrMsg 的患性
	 */
	var isAjaxResponse = function ( data ) {
		return data && data['ErrMsg'];
	};

	var showAjaxError = function ( msg ) {
		if( msg ) {
			$.notify(msg, 'error');	
		}
	};
	
	var showMsg = function ( msg ) {
		if( msg ) {
			$.notify(msg, 'success');	
		}
	};

	/**
	 * 取得核心 ajax response 或 rpc response 的錯誤訊息
	 */
	var getServerErrorMsg = function (data) {

		var errorMsgText = undefined;

		if( $.isPlainObject(data) ) {

	   		if( isAjaxResponse(data) ) {

	   			// CSR AjaxFilter response
	   			var errMsg = data['ErrMsg'],
	   			    msgid  = errMsg['msgid'];

	   			if( errMsg.returnCode != 0 ) {
	   				errorMsgText = errMsg.msgDesc 
	   								|| errMsg.displayMsgDescs 
	   								|| $.validator.messages.serverException;
	   			}
	   			
	   			if(msgid) {
					errorMsgText = msgid + '\n\n' + errorMsgText ;
	   			}

	   		} else {

	   			// RPC response
	   			if( data['error'] ) {
	   				errorMsgText = data['error']['msg'] || '';
	   			}

	   		}

	   	}	

	   	return errorMsgText;

	};
	
	/**
	 *  取得 ajax response 的成功訊息
	 */
	var getSuccessMsg = function (data) {
		
		var msgText = undefined;

		if( $.isPlainObject(data) ) {
			
			if( isAjaxResponse(data) ) {
				
	   			var errMsg = data['ErrMsg'];

	   			if( errMsg.returnCode == 0 ) {
	   				msgText = errMsg.msgDesc;		    				
	   			}
				
			}
		}
		
		return msgText; 
		
	};
	
	//--------------------------------------------------------------
	// extend method 
	//--------------------------------------------------------------
	$.getSuccessMsg = getSuccessMsg;
	$.getServerErrorMsg = getServerErrorMsg;

	//--------------------------------------------------------------
	// override jQuery load 
	//--------------------------------------------------------------
	var $_load = $.fn.load;
	$.fn.load = function ( url, data, complete) {
			
		if(typeof url === "string") {
			this.cover();
		}
		
		if(data == undefined) {
			data = {};
		}
		
		return $_load.apply(this, arguments);
	};
	
	//--------------------------------------------------------------
	// override jQuery ajax 
	//--------------------------------------------------------------
	var $_ajax = $.ajax;

	$.ajax = function( url, options ) {

		if( $.isPlainObject(url) ) {
			options = url;
		}

		if(options == undefined) {
			options = {};
		}
		
		var errorHandler = options.error,
		    successHandler = options.success,
		    handlerContext = options.context || $,
		    errorMsgText = undefined;

		var customSuccessHandler = function( data, textStatus, jqXHR ) {

			errorMsgText = getServerErrorMsg( data );

	   		if( errorMsgText != undefined ) {

	   			if( typeof errorHandler === "function" ) {
	   				errorHandler.apply( handlerContext, [jqXHR, errorMsgText] );
	   			}

	    		return;
		    	
			}

			if( typeof successHandler === "function" ) {
				//call orignalSuccessHandler if pass check
				successHandler.apply( handlerContext, arguments );
			}

		};

		// override the success handler
		if( typeof successHandler === "function" ) {
			options.success = customSuccessHandler;
		}

		//deal with defered
		var $promise = $_ajax.apply( $, arguments ).then(

			function( data ) {

				errorMsgText = getServerErrorMsg( data );
				if( errorMsgText == undefined ) {

					if( isAjaxResponse(data) ) {
						showMsg( getSuccessMsg(data) );
						return data;
					} else {
						//return data['result'] || data;
						return FKHeir.dataWithProperty(data,'result');
					}

				} else {
					showAjaxError( errorMsgText );
					return $.Deferred().reject( errorMsgText );
				}

			}

		);

		return $promise;

	};

})( jQuery );

/**
 * FKCaller 用來以類似 RPC 的方式直接呼叫後端的模組
 */
(function( $, window, undefined ){
	
	// Define FKCaller object
	window.FKCaller = (function() {
		
		/**
		 *後端接收請求的 TxBean
		 */
		var actionTarget = '/FKWeb/servlet/HttpDispatcher/FKZ5_3000/invoke',
		    _token       = undefined;
			
		var cacheToken = function (token) {
			
			if(token) {
				_token = token;
			} else {
				return _token;
			}
			
		};	
		
		/**
		 * 用 get 請求讀取資料，此方法讀回的資料會被 browser cache，以加速網頁的 loading
		 * 常用且不常改變的資料，如各層選單的資料，建議採用此方式讀資料
		 *
		 * @param moduleAndMethodName - 模組名及要呼叫的方式，範例: FK_Z0Z001.getMenu
		 * @param args - 要傳送給後端模組的參數 [optional]
		 * @param successCallback - 呼叫成功的 callback [optional]
		 * @param errorCallback - 呼叫失敗的 callback [optional]
		 *
		 * @return jqXHR - 是一個 Defered object
		 */
		var get = function ( moduleAndMethodName, args, successCallback, errorCallback ) {
			
			return sendRequest( 'get', moduleAndMethodName, args, successCallback, errorCallback );
			
		};

		/**
		 * 用 post 請求讀取資料，此方法讀回的資料不會被 browser cache
		 * 交易的資料，建議採用此方式讀資料
		 *
		 * @param moduleAndMethodName - 模組名及要呼叫的方式，範例: FK_Z0Z001.getMenu
		 * @param args - 要傳送給後端模組的參數 [optional]
		 * @param successCallback - 呼叫成功的 callback [optional]
		 * @param errorCallback - 呼叫失敗的 callback [optional]
		 *
		 * @return jqXHR - 是一個 Defered object
		 */		
		var post = function ( moduleAndMethodName, args, successCallback, errorCallback ) {
			return sendRequest( 'post', moduleAndMethodName, args, successCallback, errorCallback );	
		};
		

		/**
		 * 從 window.location.pathname 的 URL 取出 8 碼功能代號
		 */
		 var getFUNC_ID = function () {

			var currentURL = window.location.pathname, 
				term       = 'HttpDispatcher/',
				idx        = currentURL.indexOf(term),
				FUNC_ID    = currentURL.substr(idx + term.length, 9);
			return FUNC_ID.replace('_', '');
		 };

		/**
		 * private Method, 用來執行 ajax 的呼叫
		 *
		 * @param httpMethod - get/post
		 * @param moduleAndMethodName - 模組名及要呼叫的方式，範例: FK_Z0Z001.getMenu
		 * @param args - 要傳送給後端模組的參數 [optional]
		 * @param successCallback - 呼叫成功的 callback [optional]
		 * @param errorCallback - 呼叫失敗的 callback [optional]
		 *
		 * @return jqXHR - 是一個 Defered object
		 */		
		var sendRequest = function ( httpMethod, moduleAndMethodName, args, successCallback, errorCallback ) {
			
			/**
			 * 若 args 是一個 function，表示應該是調用一個不用傳參數的模組方式，
			 * 並有指定 successCallback，故 shift 參數
			 */
			if( typeof args === "function" ) {
				errorCallback = successCallback;
				successCallback = args;
				args = undefined;
			}
			
			var data = {
				'method'			   : moduleAndMethodName,
				'args'   			   : args ? JSON.stringify(args) : '[]'
			};
			
			/**
			 * 最後一個參數若是數字的話，把它當成資料 cache time 的指定時間
			 */
			if( arguments.length > 2 ) {
				
				var len = arguments.length - 1,
					cacheTime = undefined; 
				
				/**
				 * 取得最後一個不是 undefined 的參數
				 */
				while( len > 2 && cacheTime == undefined ) {
					cacheTime = arguments[len];
					len--;
				} 
				
				if( typeof cacheTime === 'number' ) {
					
					data['_d_age'] = cacheTime;
					
					if(_token == undefined) {
						_token = parseInt(new Date().getTime()/(cacheTime * 1000));
					}					
					
				}
				
			}
			
			data['_'] = _token || '';
			
			var jqXHR = $.ajax ({

					url : actionTarget,
					
					/** 
					 * 給後端的 AjaxFilter 看，讓 AjaxFilter 不要處理回傳的資料
					 */
					headers : {'X-Requested-OutputType':'rpc-json'},
					
					/** 
					 * get 請求會 cache，目前由後台控制，cache 一分鐘
					 */
					cache : (httpMethod == 'get'),
					
					/**
					 * jquery 1.9 後要改用 method 來指定請求的方法
					 */
					method : httpMethod,
					type : httpMethod,  
					
					/** 
					 * 參數(TODO:考慮編碼或加密)
					 */
					data : data					
				});
			
			/**
			 * 設定 callback
			 */
			if( typeof successCallback === "function" ) {
				jqXHR.done( successCallback );	
			}

			if( typeof errorCallback === "function" ) {
				jqXHR.fail( errorCallback );	
			}
			
			return jqXHR;				
			
		};
		
		/**
		 * export FKCaller 的公開方法
		 */
		return {
			get  : get,
			post : post,
			getFUNC_ID : getFUNC_ID,
			cacheToken : cacheToken
		};			
		
	}()); // end of FKCaller init

//--------------------------------------------------------------------------
	// Build sub menu box and bread crumb if needed
	$(function() {

		var $subMenu = $('ul.hmenu');

		if($subMenu.length == 0) {
			return;
		}	

		$subMenu.empty();
		var $menuContainer = $subMenu.closest('div.bx-wrapper'),
			FUNC_ID = FKCaller.getFUNC_ID(),
		    webContext = '/' + window.location.pathname.split('/')[1],
			$breadcrumb = $('#breadcrumb').empty();
		

		//[20241212] 取暫存在sessionStorage的資料
		var enableMenuCache = sessionStorage.getItem('enableMenuCache');//代碼開關
		var sysId = sessionStorage.getItem('sysId');
		var newRoute = false;
		if('Y' == enableMenuCache && sysId == FUNC_ID.substring(0, 2)){
			try{
				var menuList = sessionStorage.getItem('menuList');//getMainMenu暫存的資料
				if(menuList){
					menuList = JSON.parse(menuList);
					var breadTitle = sessionStorage.getItem('breadTitle');//getBreadCrumb暫存的Title
					if(menuList && breadTitle){
						newRoute = setSubMenu(menuList, FUNC_ID, $subMenu, $breadcrumb, breadTitle, webContext);
					}
				}
			} catch(error){
				//發生錯誤需走回原方法
				$subMenu.empty();
				$breadcrumb.empty();
			}
		}
		if(!newRoute){
			$menuContainer.cover({
				backgroundColor : '#000',
				opacity         : 0.5
			});
			/**
			 * 產生子選單
			 */
			FKCaller.get( 'MenuProvider.getSubMenu', ['$COMP_ID', '$EMP_NO', FUNC_ID], 3600, function(errorMsgText) {
				$menuContainer.uncover();
			}).then(function(result){
					
					var currentTx = (FUNC_ID.length == 8) ? FUNC_ID.substring(0, 4) + '_' + FUNC_ID.substring(4) : FUNC_ID,
						currentIdx = 0;
				
					if( Array.isArray(result) ) {
						$.each(result, function(idx, aFunc){
							
							var invokeURL = aFunc['INVK_URL'] || '',
								funcName  = aFunc['FUNC_NAME'] || '',
								current   = (invokeURL.indexOf(currentTx) != -1),
								$li       = $('<li>');
							if( current ) {
								currentIdx = idx;
								$li.addClass( 'current' );
							}
							$li.append( '<a href="' + webContext + invokeURL + '">' + funcName +'</a>' );
							$subMenu.append($li); 
							
						});					
					}

					$menuContainer.uncover();
					
					var bxSlider = $subMenu.data('bxSlider');
					if(bxSlider) {
						bxSlider.reloadSlider();
					}
					
					if( currentIdx > 4 ) {
						bxSlider.goToSlide( currentIdx - 2 );
					}

				});

			/**
			 * 產生麵包屑
			 */
			FKCaller.get( 'MenuProvider.getBreadCrumb', [FUNC_ID], 3600 )
				.then(function(result){
					if( Array.isArray(result) ) {
						$.each(result, function(idx, aFunc){
							if(idx == 0) {//紀錄breadTitle供下次使用
								sessionStorage.setItem('breadTitle', aFunc['FUNC_NAME']);
								sessionStorage.setItem('sysId', aFunc['FUNC_ID'].substring(0,2));
							}else{
								$breadcrumb.append('<li>&gt;</li>');
							}
							$breadcrumb.append('<li>' + aFunc['FUNC_NAME'] + '</li>');
						});
					}
				});
		}

		/**
		 * 載入網頁維護人
		 */	
		var $webManager = $('#webManager'),
		    $webManagerDiv = $('<div>').addClass('hoverWrap');
		$webManager.append($webManagerDiv);

		$webManagerDiv.load('/FKWeb/servlet/HttpDispatcher/FKZ5_3000/webManager', {'FUNC_ID':FUNC_ID});

	});	

 }( jQuery, window ));	


/* Notify.js - http://notifyjs.com/ Copyright (c) 2015 MIT */
// [20240301] JQuery 升級3.6 調整 M(p,"top",m.top-j.top) 及   M(p,"left",m.left-j.left) 改為  M(p,"top", 0) 及 M(p,"left", 0)
!function(t){"function"==typeof define&&define.amd?define(["jquery"],t):"object"==typeof module&&module.exports?module.exports=function(i,e){return void 0===e&&(e="undefined"!=typeof window?require("jquery"):require("jquery")(i)),t(e),e}:t(jQuery)}(function(t){function i(i,e,n){"string"==typeof n&&(n={className:n}),this.options=C(v,t.isPlainObject(n)?n:{}),this.loadHTML(),this.wrapper=t(p.html),this.options.clickToHide&&this.wrapper.addClass(o+"-hidable"),this.wrapper.data(o,this),this.arrow=this.wrapper.find("."+o+"-arrow"),this.container=this.wrapper.find("."+o+"-container"),this.container.append(this.userContainer),i&&i.length&&(this.elementType=i.attr("type"),this.originalElement=i,this.elem=F(i),this.elem.data(o,this),this.elem.before(this.wrapper)),this.container.hide(),this.run(e)}var e=[].indexOf||function(t){ for(var i=0,e=this.length;e>i;i++) if(i in this&&this[i]===t)return i;return-1},n="notify",o=n+"js",r=n+"!blank",s={t:"top",m:"middle",b:"bottom",l:"left",c:"center",r:"right"},a=["l","c","r"],l=["t","m","b"],h=["t","b","l","r"],A={t:"b",m:null,b:"t",l:"r",c:null,r:"l"},c=function(i){var e;return e=[],t.each(i.split(/\W+/),function(t,i){var n;return n=i.toLowerCase().charAt(0),s[n]?e.push(n):void 0}),e},d={},p={name:"core",html:'<div class="'+o+'-wrapper">\n	<div class="'+o+'-arrow"></div>\n	<div class="'+o+'-container"></div>\n</div>',css:"."+o+"-corner {\n	position: fixed;\n	margin: 5px;\n	z-index: 1050;\n}\n\n."+o+"-corner ."+o+"-wrapper,\n."+o+"-corner ."+o+"-container {\n	position: relative;\n	display: block;\n	height: inherit;\n	width: inherit;\n	margin: 3px;\n}\n\n."+o+"-wrapper {\n	z-index: 1;\n	position: absolute;\n	display: inline-block;\n	height: 0;\n	width: 0;\n}\n\n."+o+"-container {\n	display: none;\n	z-index: 1;\n	position: absolute;\n}\n\n."+o+"-hidable {\n	cursor: pointer;\n}\n\n[data-notify-text],[data-notify-html] {\n	position: relative;\n}\n\n."+o+"-arrow {\n	position: absolute;\n	z-index: 2;\n	width: 0;\n	height: 0;\n}"},u={"border-radius":["-webkit-","-moz-"]},f=function(t){return d[t]},g=function(t){if(!t)throw"Missing Style name";d[t]&&delete d[t]},m=function(i,e){if(!i)throw"Missing Style name";if(!e)throw"Missing Style definition";if(!e.html)throw"Missing Style HTML";var r=d[i];r&&r.cssElem&&(window.console&&console.warn(n+": overwriting style '"+i+"'"),d[i].cssElem.remove()),e.name=i,d[i]=e;var s="";e.classes&&t.each(e.classes,function(i,n){return s+="."+o+"-"+e.name+"-"+i+" {\n",t.each(n,function(i,e){return u[i]&&t.each(u[i],function(t,n){return s+="	"+n+i+": "+e+";\n"}),s+="	"+i+": "+e+";\n"}),s+="}\n"}),e.css&&(s+="/* styles for "+e.name+" */\n"+e.css),s&&(e.cssElem=w(s),e.cssElem.attr("id","notify-"+e.name));var a={},l=t(e.html);y("html",l,a),y("text",l,a),e.fields=a},w=function(i){var e;e=x("style"),e.attr("type","text/css"),t("head").append(e);try{e.html(i)}catch(n){e[0].styleSheet.cssText=i}return e},y=function(i,e,n){var o;return"html"!==i&&(i="text"),o="data-notify-"+i,b(e,"["+o+"]").each(function(){var e;e=t(this).attr(o),e||(e=r),n[e]=i})},b=function(t,i){return t.is(i)?t:t.find(i)},v={clickToHide:!0,autoHide:!0,autoHideDelay:5e3,arrowShow:!0,arrowSize:5,breakNewLines:!0,elementPosition:"bottom",globalPosition:"top right",style:"bootstrap",className:"error",showAnimation:"slideDown",showDuration:400,hideAnimation:"slideUp",hideDuration:200,gap:5},C=function(i,e){var n;return n=function(){},n.prototype=i,t.extend(!0,new n,e)},E=function(i){return t.extend(v,i)},x=function(i){return t("<"+i+"></"+i+">")},S={},F=function(i){var e;return i.is("[type=radio]")&&(e=i.parents("form:first").find("[type=radio]").filter(function(e,n){return t(n).attr("name")===i.attr("name")}),i=e.first()),i},M=function(t,i,e){var n,o;if("string"==typeof e)e=parseInt(e,10);else if("number"!=typeof e)return;if(!isNaN(e))return n=s[A[i.charAt(0)]],o=i,void 0!==t[n]&&(i=s[n.charAt(0)],e=-e),void 0===t[i]?t[i]=e:t[i]+=e,null},D=function(t,i,e){if("l"===t||"t"===t)return 0;if("c"===t||"m"===t)return e/2-i/2;if("r"===t||"b"===t)return e-i;throw"Invalid alignment"},k=function(t){return k.e=k.e||x("div"),k.e.text(t).html()};i.prototype.loadHTML=function(){var i;i=this.getStyle(),this.userContainer=t(i.html),this.userFields=i.fields},i.prototype.show=function(t,i){var e,n,o,r,s;if(n=function(e){return function(){return t||e.elem||e.destroy(),i?i():void 0}}(this),s=this.container.parent().parents(":hidden").length>0,o=this.container.add(this.arrow),e=[],s&&t)r="show";else if(s&&!t)r="hide";else if(!s&&t)r=this.options.showAnimation,e.push(this.options.showDuration);else{if(s||t)return n();r=this.options.hideAnimation,e.push(this.options.hideDuration)}return e.push(n),o[r].apply(o,e)},i.prototype.setGlobalPosition=function(){var i=this.getPosition(),e=i[0],n=i[1],r=s[e],a=s[n],l=e+"|"+n,h=S[l];if(!h||!document.body.contains(h[0])){  h=S[l]=x("div");var A={};A[r]=0,"middle"===a?A.top="45%":"center"===a?A.left="45%":A[a]=0,h.css(A).addClass(o+"-corner"),t("body").append(h)}return h.prepend(this.wrapper)},i.prototype.setElementPosition=function(){var i,n,o,r,c,d,p,u,f,g,m,w,y,b,v,C,E,x,S,F,k,B,H,Q,R,U,X,z,j;  for(X=this.getPosition(),Q=X[0],B=X[1],H=X[2],m=this.elem.position(),u=this.elem.outerHeight(),w=this.elem.outerWidth(),f=this.elem.innerHeight(),g=this.elem.innerWidth(),j=this.wrapper.position(),c=this.container.height(),d=this.container.width(),x=s[Q],F=A[Q],k=s[F],p={},p[k]="b"===Q?u:"r"===Q?w:0,M(p,"top", 0),M(p,"left", 0),z=["top","left"],b=0,C=z.length;C>b;b++)R=z[b],S=parseInt(this.elem.css("margin-"+R),10),S&&M(p,R,S);if(y=Math.max(0,this.options.gap-(this.options.arrowShow?o:0)),M(p,k,y),this.options.arrowShow){for(o=this.options.arrowSize,n=t.extend({},p),i=this.userContainer.css("border-color")||this.userContainer.css("border-top-color")||this.userContainer.css("background-color")||"white",v=0,E=h.length;E>v;v++)R=h[v],U=s[R],R!==F&&(r=U===x?i:"transparent",n["border-"+U]=o+"px solid "+r);M(p,s[F],o),e.call(h,B)>=0&&M(n,s[B],2*o)}else this.arrow.hide();return e.call(l,Q)>=0?(M(p,"left",D(B,d,w)),n&&M(n,"left",D(B,o,g))):e.call(a,Q)>=0&&(M(p,"top",D(B,c,u)),n&&M(n,"top",D(B,o,f))),this.container.is(":visible")&&(p.display="block"),this.container.removeAttr("style").css(p),n?this.arrow.removeAttr("style").css(n):void 0},i.prototype.getPosition=function(){var t,i,n,o,r,s,A,d;if(d=this.options.position||(this.elem?this.options.elementPosition:this.options.globalPosition),t=c(d),0===t.length&&(t[0]="b"),i=t[0],e.call(h,i)<0)throw"Must be one of ["+h+"]";return(1===t.length||(n=t[0],e.call(l,n)>=0&&(o=t[1],e.call(a,o)<0))||(r=t[0],e.call(a,r)>=0&&(s=t[1],e.call(l,s)<0)))&&(t[1]=(A=t[0],e.call(a,A)>=0?"m":"l")),2===t.length&&(t[2]=t[1]),t},i.prototype.getStyle=function(t){var i;if(t||(t=this.options.style),t||(t="default"),i=d[t],!i)throw"Missing style: "+t;return i},i.prototype.updateClasses=function(){var i,e;return i=["base"],Array.isArray(this.options.className)?i=i.concat(this.options.className):this.options.className&&i.push(this.options.className),e=this.getStyle(),i=t.map(i,function(t){return o+"-"+e.name+"-"+t}).join(" "),this.userContainer.attr("class",i)},i.prototype.run=function(i,e){var n,o,s,a,l;if(t.isPlainObject(e)?t.extend(this.options,e):"string"===typeof(e)&&(this.options.className=e),this.container&&!i)return void this.show(!1);if(this.container||i){o={},t.isPlainObject(i)?o=i:o[r]=i;for(s in o)n=o[s],a=this.userFields[s],a&&("text"===a&&(n=k(n),this.options.breakNewLines&&(n=n.replace(/\n/g,"<br/>"))),l=s===r?"":"="+s,b(this.userContainer,"[data-notify-"+a+l+"]").html(n));this.updateClasses(),this.elem?this.setElementPosition():this.setGlobalPosition(),this.show(!0),this.options.autoHide&&(clearTimeout(this.autohideTimer),this.autohideTimer=setTimeout(this.show.bind(this,!1),this.options.autoHideDelay))}},i.prototype.destroy=function(){this.wrapper.data(o,null),this.wrapper.remove()},t[n]=function(e,o,r){return e&&e.nodeName||e.jquery?t(e)[n](o,r):(r=o,o=e,new i(null,o,r)),e},t.fn[n]=function(e,n){return t(this).each(function(){var r=F(t(this)).data(o);r&&r.destroy();new i(t(this),e,n)}),this},t.extend(t[n],{defaults:E,addStyle:m,removeStyle:g,pluginOptions:v,getStyle:f,insertCSS:w}),m("bootstrap",{html:"<div>\n<span data-notify-text></span>\n</div>",classes:{base:{"font-weight":"bold",padding:"8px 15px 8px 14px","text-shadow":"0 1px 0 rgba(255, 255, 255, 0.5)","background-color":"#fcf8e3",border:"1px solid #fbeed5","border-radius":"4px","white-space":"nowrap","padding-left":"25px","background-repeat":"no-repeat","background-position":"3px 7px"},error:{color:"#B94A48","background-color":"#F2DEDE","border-color":"#EED3D7","background-image":"url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAtRJREFUeNqkVc1u00AQHq+dOD+0poIQfkIjalW0SEGqRMuRnHos3DjwAH0ArlyQeANOOSMeAA5VjyBxKBQhgSpVUKKQNGloFdw4cWw2jtfMOna6JOUArDTazXi/b3dm55socPqQhFka++aHBsI8GsopRJERNFlY88FCEk9Yiwf8RhgRyaHFQpPHCDmZG5oX2ui2yilkcTT1AcDsbYC1NMAyOi7zTX2Agx7A9luAl88BauiiQ/cJaZQfIpAlngDcvZZMrl8vFPK5+XktrWlx3/ehZ5r9+t6e+WVnp1pxnNIjgBe4/6dAysQc8dsmHwPcW9C0h3fW1hans1ltwJhy0GxK7XZbUlMp5Ww2eyan6+ft/f2FAqXGK4CvQk5HueFz7D6GOZtIrK+srupdx1GRBBqNBtzc2AiMr7nPplRdKhb1q6q6zjFhrklEFOUutoQ50xcX86ZlqaZpQrfbBdu2R6/G19zX6XSgh6RX5ubyHCM8nqSID6ICrGiZjGYYxojEsiw4PDwMSL5VKsC8Yf4VRYFzMzMaxwjlJSlCyAQ9l0CW44PBADzXhe7xMdi9HtTrdYjFYkDQL0cn4Xdq2/EAE+InCnvADTf2eah4Sx9vExQjkqXT6aAERICMewd/UAp/IeYANM2joxt+q5VI+ieq2i0Wg3l6DNzHwTERPgo1ko7XBXj3vdlsT2F+UuhIhYkp7u7CarkcrFOCtR3H5JiwbAIeImjT/YQKKBtGjRFCU5IUgFRe7fF4cCNVIPMYo3VKqxwjyNAXNepuopyqnld602qVsfRpEkkz+GFL1wPj6ySXBpJtWVa5xlhpcyhBNwpZHmtX8AGgfIExo0ZpzkWVTBGiXCSEaHh62/PoR0p/vHaczxXGnj4bSo+G78lELU80h1uogBwWLf5YlsPmgDEd4M236xjm+8nm4IuE/9u+/PH2JXZfbwz4zw1WbO+SQPpXfwG/BBgAhCNZiSb/pOQAAAAASUVORK5CYII=)"},success:{color:"#468847","background-color":"#DFF0D8","border-color":"#D6E9C6","background-image":"url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAutJREFUeNq0lctPE0Ecx38zu/RFS1EryqtgJFA08YCiMZIAQQ4eRG8eDGdPJiYeTIwHTfwPiAcvXIwXLwoXPaDxkWgQ6islKlJLSQWLUraPLTv7Gme32zoF9KSTfLO7v53vZ3d/M7/fIth+IO6INt2jjoA7bjHCJoAlzCRw59YwHYjBnfMPqAKWQYKjGkfCJqAF0xwZjipQtA3MxeSG87VhOOYegVrUCy7UZM9S6TLIdAamySTclZdYhFhRHloGYg7mgZv1Zzztvgud7V1tbQ2twYA34LJmF4p5dXF1KTufnE+SxeJtuCZNsLDCQU0+RyKTF27Unw101l8e6hns3u0PBalORVVVkcaEKBJDgV3+cGM4tKKmI+ohlIGnygKX00rSBfszz/n2uXv81wd6+rt1orsZCHRdr1Imk2F2Kob3hutSxW8thsd8AXNaln9D7CTfA6O+0UgkMuwVvEFFUbbAcrkcTA8+AtOk8E6KiQiDmMFSDqZItAzEVQviRkdDdaFgPp8HSZKAEAL5Qh7Sq2lIJBJwv2scUqkUnKoZgNhcDKhKg5aH+1IkcouCAdFGAQsuWZYhOjwFHQ96oagWgRoUov1T9kRBEODAwxM2QtEUl+Wp+Ln9VRo6BcMw4ErHRYjH4/B26AlQoQQTRdHWwcd9AH57+UAXddvDD37DmrBBV34WfqiXPl61g+vr6xA9zsGeM9gOdsNXkgpEtTwVvwOklXLKm6+/p5ezwk4B+j6droBs2CsGa/gNs6RIxazl4Tc25mpTgw/apPR1LYlNRFAzgsOxkyXYLIM1V8NMwyAkJSctD1eGVKiq5wWjSPdjmeTkiKvVW4f2YPHWl3GAVq6ymcyCTgovM3FzyRiDe2TaKcEKsLpJvNHjZgPNqEtyi6mZIm4SRFyLMUsONSSdkPeFtY1n0mczoY3BHTLhwPRy9/lzcziCw9ACI+yql0VLzcGAZbYSM5CCSZg1/9oc/nn7+i8N9p/8An4JMADxhH+xHfuiKwAAAABJRU5ErkJggg==)"},info:{color:"#3A87AD","background-color":"#D9EDF7","border-color":"#BCE8F1","background-image":"url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3QYFAhkSsdes/QAAA8dJREFUOMvVlGtMW2UYx//POaWHXg6lLaW0ypAtw1UCgbniNOLcVOLmAjHZolOYlxmTGXVZdAnRfXQm+7SoU4mXaOaiZsEpC9FkiQs6Z6bdCnNYruM6KNBw6YWewzl9z+sHImEWv+vz7XmT95f/+3/+7wP814v+efDOV3/SoX3lHAA+6ODeUFfMfjOWMADgdk+eEKz0pF7aQdMAcOKLLjrcVMVX3xdWN29/GhYP7SvnP0cWfS8caSkfHZsPE9Fgnt02JNutQ0QYHB2dDz9/pKX8QjjuO9xUxd/66HdxTeCHZ3rojQObGQBcuNjfplkD3b19Y/6MrimSaKgSMmpGU5WevmE/swa6Oy73tQHA0Rdr2Mmv/6A1n9w9suQ7097Z9lM4FlTgTDrzZTu4StXVfpiI48rVcUDM5cmEksrFnHxfpTtU/3BFQzCQF/2bYVoNbH7zmItbSoMj40JSzmMyX5qDvriA7QdrIIpA+3cdsMpu0nXI8cV0MtKXCPZev+gCEM1S2NHPvWfP/hL+7FSr3+0p5RBEyhEN5JCKYr8XnASMT0xBNyzQGQeI8fjsGD39RMPk7se2bd5ZtTyoFYXftF6y37gx7NeUtJJOTFlAHDZLDuILU3j3+H5oOrD3yWbIztugaAzgnBKJuBLpGfQrS8wO4FZgV+c1IxaLgWVU0tMLEETCos4xMzEIv9cJXQcyagIwigDGwJgOAtHAwAhisQUjy0ORGERiELgG4iakkzo4MYAxcM5hAMi1WWG1yYCJIcMUaBkVRLdGeSU2995TLWzcUAzONJ7J6FBVBYIggMzmFbvdBV44Corg8vjhzC+EJEl8U1kJtgYrhCzgc/vvTwXKSib1paRFVRVORDAJAsw5FuTaJEhWM2SHB3mOAlhkNxwuLzeJsGwqWzf5TFNdKgtY5qHp6ZFf67Y/sAVadCaVY5YACDDb3Oi4NIjLnWMw2QthCBIsVhsUTU9tvXsjeq9+X1d75/KEs4LNOfcdf/+HthMnvwxOD0wmHaXr7ZItn2wuH2SnBzbZAbPJwpPx+VQuzcm7dgRCB57a1uBzUDRL4bfnI0RE0eaXd9W89mpjqHZnUI5Hh2l2dkZZUhOqpi2qSmpOmZ64Tuu9qlz/SEXo6MEHa3wOip46F1n7633eekV8ds8Wxjn37Wl63VVa+ej5oeEZ/82ZBETJjpJ1Rbij2D3Z/1trXUvLsblCK0XfOx0SX2kMsn9dX+d+7Kf6h8o4AIykuffjT8L20LU+w4AZd5VvEPY+XpWqLV327HR7DzXuDnD8r+ovkBehJ8i+y8YAAAAASUVORK5CYII=)"},warn:{color:"#C09853","background-color":"#FCF8E3","border-color":"#FBEED5","background-image":"url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAABJlBMVEXr6eb/2oD/wi7/xjr/0mP/ykf/tQD/vBj/3o7/uQ//vyL/twebhgD/4pzX1K3z8e349vK6tHCilCWbiQymn0jGworr6dXQza3HxcKkn1vWvV/5uRfk4dXZ1bD18+/52YebiAmyr5S9mhCzrWq5t6ufjRH54aLs0oS+qD751XqPhAybhwXsujG3sm+Zk0PTwG6Shg+PhhObhwOPgQL4zV2nlyrf27uLfgCPhRHu7OmLgAafkyiWkD3l49ibiAfTs0C+lgCniwD4sgDJxqOilzDWowWFfAH08uebig6qpFHBvH/aw26FfQTQzsvy8OyEfz20r3jAvaKbhgG9q0nc2LbZxXanoUu/u5WSggCtp1anpJKdmFz/zlX/1nGJiYmuq5Dx7+sAAADoPUZSAAAAAXRSTlMAQObYZgAAAAFiS0dEAIgFHUgAAAAJcEhZcwAACxMAAAsTAQCanBgAAAAHdElNRQfdBgUBGhh4aah5AAAAlklEQVQY02NgoBIIE8EUcwn1FkIXM1Tj5dDUQhPU502Mi7XXQxGz5uVIjGOJUUUW81HnYEyMi2HVcUOICQZzMMYmxrEyMylJwgUt5BljWRLjmJm4pI1hYp5SQLGYxDgmLnZOVxuooClIDKgXKMbN5ggV1ACLJcaBxNgcoiGCBiZwdWxOETBDrTyEFey0jYJ4eHjMGWgEAIpRFRCUt08qAAAAAElFTkSuQmCC)"}}}),t(function(){w(p.css).attr("id","core-notify"),t(document).on("click","."+o+"-hidable",function(i){t(this).trigger("notify-hide")}),t(document).on("notify-hide","."+o+"-wrapper",function(i){var e=t(this).data(o);e&&e.show(!1)})})});

$.notify.defaults({position  : 'bottom right', autoHideDelay:10000});

// add custome style for validation usage
$.notify.addStyle('validate-error', {
	  html: "<div><span data-notify-text/></div>",
	  classes: {
	    base: {
	      "white-space": "nowrap",
	      "background-color": "LightCoral",
	      "border" : "1px solid IndianRed",
	      "color" : "white",
	      "padding": "5px"
	    }
	  }
});

// change default validate error showing
jQuery.validator.setDefaults({
    showErrors: function(errorMap, errorList) {
		
		for(var i = 0; i < this.successList.length; i++) {
		
			var $successObject = $(this.successList[i]);
          
          	if($successObject.parent('label').length) {//for radio, checkbox
              	$successObject = $successObject.parent('label');
          	}
          
          	$successObject.prev('.notifyjs-wrapper:first').trigger('notify-hide');
        }
        
        for(var i = 0; i < errorList.length; i++) {
			
            var aError = errorList[i],
                $notifyObj = $(aError.element);
            
            if($notifyObj.parent('label').length) { //becuase label does not contain div(for checkbox and radio)
                $notifyObj = $notifyObj.parent('label');
            }
            
            $notifyObj.notify(aError.message, {position:'right', autoHide:false, style:'validate-error'});
        }
        
    }
});

/**
 * Adding custom cover plugin
 */
(function( $ ) {
	 
	// loaders plugin not import
	// just build empty cover/uncover plugin
	if($().loaders == undefined ) {
		
		$.fn.cover = function() {
			return this;
		};
		
		$.fn.uncover = function () {
			return this;
		};
		
		return;
	}
	
    $.fn.cover = function( options ) {
		
    	var defaultOptions = {
    			backgroundColor : 'rgb(26,164,29)',
    			opacity         : 0.7,
    			loader          : 'line-scale',
    			className       : 'fk-tmp-cover'
    		};    	
    	
		var settings = $.extend(defaultOptions, options);
		
		return this.each(function(){
			
			var $elem  = $(this),
			    $cover = $('<div>', {
			    			css : {
								position : 'absolute',
								top      : 0,
								left     : 0,
								width    : $elem.outerWidth(),
								height   : $elem.outerHeight(),
								opacity  : settings.opacity,
								zIndex   : 9999,
								textAlign: 'center',
								backgroundColor : settings.backgroundColor
			    			}
			    		 }).addClass(settings.className),
				$loader = $('<div>').addClass('loader-inner ' + settings.loader).loaders();
			
			if($elem.is('body')) {
				$cover.css({
					'width' : '100%',
					'height': '100%',
					'position' : 'fixed',
					'top' : 0,
					'left' : 0,
					'z-index': 99999
				});
			}
			
			$cover.append($loader).appendTo($elem);
			
			$loader.css({ 
				'position' : 'relative',
				'top'      : Math.max(0, ($cover.height() - $loader.height())/2)
			});
			
		});		
 
    };
    
    $.fn.uncover = function (options) {
    	
    	var settings = $.extend({className:'fk-tmp-cover'}, options);
    	
    	return this.each(function() {
    		
			var $elem = $(this);
			$elem.find('div.' + settings.className).remove();
			if($elem.is('body')) {
				$elem.find('div.tmp_fk_global_cover').remove();	
			}
    		
    	});
    	
    };
    
    
    //防滑鼠右鍵
//    document.oncontextmenu=function(){
//    	return false;
//    }
// 
}( jQuery ));

	//[20241212] 用menuList設置subMenu,breadCrumb 不重新查詢取得
	function setSubMenu(menuList, FUNC_ID, $subMenu, $breadcrumb, breadTitle, webContext){
		//console.log("setSubMenu is new Route");
		var findFuncId = false;
		var subMenu;
		var breadAry = [];
		$.each(menuList, function(idx, aFunc1){
			$.each(aFunc1.subFuncs, function(idx, aFunc2){
				$.each(aFunc2.subFuncs, function(idx, aFunc3){
					$.each(aFunc3.subFuncs, function(idx, aFunc4){
						if(FUNC_ID == aFunc4.funcID){
							findFuncId = true;
							breadAry.push(aFunc4.funcName);
							return false;
						}
					});
					if(findFuncId){
						subMenu = aFunc3.subFuncs;
						breadAry.push(aFunc3.funcName);
						return false;
					}
				});
				if(findFuncId){
					breadAry.push(aFunc2.funcName);
					return false;
				}
			});
			if(findFuncId){
				breadAry.push(aFunc1.funcName);
				return false;
			}
		});
		if(findFuncId){
			var currentTx = (FUNC_ID.length == 8) ? FUNC_ID.substring(0, 4) + '_' + FUNC_ID.substring(4) : FUNC_ID;
			currentIdx = 0;
			if( Array.isArray(subMenu) ) {
				$.each(subMenu, function(idx, aFunc){
					var invokeURL = aFunc['URL'] || '',
						funcName  = aFunc['funcName'] || '',
						current   = (invokeURL.indexOf(currentTx) != -1),
						$li       = $('<li>');
					if( current ) {
						currentIdx = idx;
						$li.addClass( 'current' );
					}
					$li.append( '<a href="' + webContext + invokeURL + '">' + funcName +'</a>' );
					$subMenu.append($li); 
							
				});					
			}
			var bxSlider = $subMenu.data('bxSlider');
			if(bxSlider) {
				bxSlider.reloadSlider();
			}
			if( currentIdx > 4 ) {
				bxSlider.goToSlide( currentIdx - 2 );
			}
			
			if(breadAry) {
				$breadcrumb.append('<li>' + breadTitle + '</li>');
				for(var i = breadAry.length - 1; i >= 0; i--){
					$breadcrumb.append('<li>&gt;</li>');
					$breadcrumb.append('<li>' + breadAry[i] + '</li>');
				}
			}
		}
		return findFuncId;
	}
