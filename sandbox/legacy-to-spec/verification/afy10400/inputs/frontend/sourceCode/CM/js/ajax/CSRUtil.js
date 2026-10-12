// CSRUtil.js
var CSRUtil = {};

CSRUtil.hasInclude_jQuery = function (resp){
	return typeof window['jQuery'] !== 'undefined';
};

CSRUtil.hasInclude_Prototype = function (resp){
	return typeof window['Prototype'] !== 'undefined';
};

/*
	help to get the ReturnMessage object from response
*/
CSRUtil.getReturnMessage = function (resp){
	if(resp){
		return resp['ErrMsg'];
	}
};
/*
	help to know the return code in return message is zero or not
*/
CSRUtil.isSuccess = function(resp){
	var msg = CSRUtil.getReturnMessage(resp);
	if(msg){
		return (msg.returnCode == 0);
	}
	return false;
};
/*
	協助判斷 XMLHttpRequest 是否作用中(for timeout check)
*/
CSRUtil.isOnProgress = function(xmlhttp){
	switch (xmlhttp.readyState) {
		case 1: case 2: case 3:
			return true;
		break;
		// Case 4 and 0
		default:
			return false;
		break;
	}
};
/*
	把JavaScript object 設定到畫面 上的 input
*/
CSRUtil.voToInputs = function(panel_id, vo ){

		var panel = $(panel_id);

		var inputs = panel.select('input[type="text"]', 'input[type="hidden"]', 'textarea');
		inputs.each(function(it){
			var v = vo[it.name];
			if(Object.isUndefined(v)) return;

			if( v == null || (Object.isString(v) && v.blank()) ){
				it.value = '';
			}else{
				it.setValue(v);
			}
		});

		inputs = panel.select('input[type="checkbox"]', 'input[type="radio"]');
		inputs.each(function(it){
			var v = vo[it.name];
			if(Object.isUndefined(v)) return;
			it.checked = (v === it.value);
		});

		inputs = panel.select('select');
		inputs.each(function(it){
			var v = vo[it.name];
			if(Object.isUndefined(v)) return;

			it.setValue(v);

			if(it.ref){
				if(it.options[it.selectedIndex].value == ''){
					$(it.ref).value = '';
				}else{
					$(it.ref).value = it.options[it.selectedIndex].text;
				}
			}else{
				var ref = $(it.name + '_NAME');
				if(ref){
					if(it.options[it.selectedIndex].value == ''){
						ref.value = '';
					}else{
						ref.value = it.options[it.selectedIndex].text;
					}
				}
			}
		});
/*
		抓取 id 後4碼為 '_txt' (不分大小寫) 的 span
*/
		var spans = panel.select('span');
		spans.each(function(it){
			var span_id = it.id.toUpperCase();
			if (span_id.length > 4 && span_id.endsWith('_TXT')){
				var v = vo[it.id.substr(0,span_id.length-4)];
				if(Object.isUndefined(v)) return;

				it.innerHTML = String.emptyIf(v, '');
			}
		});
};
/**
 *	@public
 *	@class 把畫面上 input 值轉存JavaScript Object Vo
 *	@param panel_id - 指定元件的 id, 轉值時會取此元件之內的 input
 *	@param includeDisabled - 有給值的話，disabled 的 input 值也會被取出
 **/
CSRUtil.inputsToVo = function(panel_id, includeDisabled){
		var vo = {};
		var inputs = $(panel_id).select('input[type="text"]', 'select', 'input[type="hidden"]', 'textarea');
		inputs.each(function(it){
			if(!includeDisabled){
				if(!it.disabled){
					vo[it.name] = it.getValue();
				}
			}else{
				vo[it.name] = it.getValue();
			}
		});
		inputs = $(panel_id).select('input[type="checkbox"]');
		inputs.each(function(it){
			if(it.checked){
				vo[it.name] = it.getValue();
			}
		});

		inputs = $(panel_id).select('input[type="radio"]');
		inputs.each(function(it){
			if(it.checked){
				vo[it.name] = it.getValue();
			}
		});

		return vo;
};

/**
 *  @public
 *	@class create cover page
 *	@param inputOpts (Map)
 *	@param inputOpts.id (String) : cover page id。
 *	@param inputOpts.transparent (Boolean) : 是否設定為透明，預設為 false。
 *	@param inputOpts.cursor (String) : 游標樣式，預設為 progress。
 *	@param inputOpts.show (Boolean) : 是否建立時就立即顯示，預設為 false。
 *	@param inputOpts.tipsMsg (String) : cover page 上顯示提示訊息內容。
 *	@param inputOpts.zIndex (Number)。
 **/
CSRUtil.createCoverPage = function(inputOpts){

	var opts;
	if(typeof inputOpts === 'string') {
		opts = {'id':inputOpts};
	}else{
		opts = inputOpts || {};
	}

	var setDefault = function(key, defaultValue){
		if(typeof opts[key] === 'undefined'){opts[key]=defaultValue;}
	};

	setDefault('transparent', false);
	setDefault('cursor', 'progress');
	setDefault('show', false);
	setDefault('tipsMsg', '');

	inputId = opts['id'];

	var docBody = document.body;

	var cover = document.getElementById(inputId);
	if(!cover){

		var canUsePositionStyle_fixed = false;
		try{
			var isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");
			var docModeIE;
			if(isIE){
				var userAgentStrings = navigator.userAgent;
				var verIE_ua = (/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(userAgentStrings || "") ? parseFloat(RegExp.$1, 10) : null;
				var verIEtrue;
				try { verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
				// Get true IE version using clientCaps.
				var obj = document.createElement("div");
				// Array of classids that can give us the IE version
				var CLASSID = [
					"{45EA75A0-A269-11D1-B5BF-0000F8051515}", // Internet Explorer Help
					"{3AF36230-A269-11D1-B5BF-0000F8051515}", // Offline Browsing Pack
					"{89820200-ECBD-11CF-8B85-00AA005B4383}"
				];
				try{obj.style.behavior = "url(#default#clientcaps)"}catch(e){};

				for(var x = 0; x < CLASSID.length; x++){
					try { verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
					if (verIEtrue) break;
				};
				docModeIE = document.documentMode || ((/back/i).test(document.compatMode || "") ? 5 : parseFloat(verIEtrue || "0", 10)) || verIE_ua;
			}
			if(!isIE ||  docModeIE>=7){
				canUsePositionStyle_fixed = true;
			}
		}catch(e){
		}

		var zIndex = opts.zIndex || 150;

		var cover = document.createElement('div');
			cover.setAttribute('id', inputId);
			cover.style.width='100%';
			cover.style.height='100%';
			cover.style.position=canUsePositionStyle_fixed?'fixed':'absolute';
			cover.style.left='0px';
			cover.style.top='0px';
			cover.style.padding='0px';
			cover.style.margin='0px auto';
			cover.style.zIndex=zIndex;
			cover.style.cursor=opts['cursor'];

		var bgPng;
		if(opts['transparent']===true){
			bgPng='CSRUtil.coverPage.bg2.png';
		}else{
			bgPng='CSRUtil.coverPage.bg.png';

			var loadingImage = document.createElement('div');
				loadingImage.style.width='100%';
				loadingImage.style.height='100%';
				loadingImage.style.position='absolute';
				loadingImage.style.left=0;
				loadingImage.style.top=0;
				loadingImage.style.background='no-repeat center center url('+CSRUtil.UICore.imageBase+'/CM/ui/CSRUtil.loading.gif)';

			cover.appendChild(loadingImage);
		}

		var tipsMsg = opts['tipsMsg'];
		if(tipsMsg){
			var fullWordArray = tipsMsg.match(/[^\x00-\xff]/g);
			var halfWordArray = tipsMsg.match(/[\x00-\xff]/g);
			var fullWordLength = fullWordArray==null?0:fullWordArray.length;
			var halfWordLength = halfWordArray==null?0:halfWordArray.length;
			var marginLeftValue = -20-((fullWordLength*7)+(halfWordLength*2))+'px';
			var tipsMsgColor = '#FFF';

			var tipsMsgDiv = document.createElement('div');
				tipsMsgDiv.style.position='absolute';
				tipsMsgDiv.style.left='50%';
				tipsMsgDiv.style.top='50%';
				tipsMsgDiv.style.padding='5px 15px';
				tipsMsgDiv.style.marginTop='40px';
				tipsMsgDiv.style.marginLeft=marginLeftValue;
				tipsMsgDiv.style.color=tipsMsgColor;
				tipsMsgDiv.style.border=tipsMsgColor+' 1px solid';
				tipsMsgDiv.style.zIndex=-1;
				tipsMsgDiv.innerHTML=tipsMsg;

			cover.appendChild(tipsMsgDiv);
		}

		var CSRUtilCoverPageBgPng = CSRUtil.UICore.imageBase+'/CM/ui/'+bgPng;
		if(window.XMLHttpRequest){
			cover.style.background='url('+CSRUtilCoverPageBgPng+')';
		}else { // png supported by IE6
			try{
				cover.filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src=CSRUtilCoverPageBgPng;
			}catch(e){
			}
		}

		cover['resizeCoverPage'] = function(){
			if(canUsePositionStyle_fixed){
				return;
			}

			var tolerance = 20;

			var currentHeight = cover.offsetHeight;
			

			var changeHeight = Math.max( currentHeight , docBody.scrollHeight, docBody.clientHeight, docBody.offsetHeight);

			if(changeHeight>currentHeight){
				cover.style.height=changeHeight+'px';
			}

			/*
			2016-09-07 寬度已定義100%，不需再手動處理

			var currentWidth = cover.width;
			var changeWidth = currentWidth;
			if(changeWidth<docBody.scrollWidth){ changeWidth = docBody.scrollWidth; }
			if(changeWidth<docBody.clientWidth){ changeWidth = docBody.clientWidth; }
			if(changeWidth<docBody.offsetWidth){ changeWidth = docBody.offsetWidth; }
			
			if(changeWidth>(currentWidth+tolerance)){
				cover.style.width=(changeWidth/currentWidth * 100)+'%';
			}

			 */
		};

		cover['show'] = function(){
			cover.style.display='';
			return this;
		};

		cover['hide'] = function(){
			cover.style.display='none';
			return this;
		};

		docBody.appendChild(cover);

	}

	cover['resizeCoverPage']();
	try{
		var ae = document.activeElement;
		if(ae && ae.getAttribute('type') && ae.getAttribute('type').match(/button/i)) { window.focus(); }
	}catch(e){
		window.console && console.log('[CSRUtil][createCoverPage] cant read activeElement!' + e );
	}

	if(opts['show']===true){
		cover['show']();
	}else{
		cover['hide']();
	}

	return cover;

};

/**
 Default Ajax Response handler for CSR project. 功能如下：
 1、在 XMLHttpRequest 送出後，產生 cover 的 div 覆蓋目前的頁面，並於 XMLHttpRequest
    回應後移除覆蓋的 div，以達成 submit once 的目的。
 2、onComplete 的時候，會去檢查伺服端的回應 ErrMsg 物件，若帶有任何的訊息，
    則以自定的 alert 視窗秀出訊息。
 3、加入 timeout 的控制能力(僅於 asynchronous 的模式下有用)使用 timeout 的方式如下：

    3.a 於 options 中指定 tiemout 的屬性，單位為秒
        new Ajax.Request( url,
        	{
        	  parameters: {'key':'value'},
        	  timeout: 2,  \\指定 2 秒 timeout，若仍未回應會中斷 XHLHttpRequest，並 alert 提示
        	  onSuccess: function(XHT, resp){
        	  }
        	}
        );

    3.b 指定 options 中的 timeout , 並自定 onTimeout 的控制
         new Ajax.Request( url,
        	{
        	  parameters: {'key':'value'},
        	  timeout: 2,  \\指定 2 秒 timeout，若仍未回應會中斷 XHLHttpRequest，並 alert 提示
        	  onTimeout: function(){
        	      alert('交易逾時，伺服器可能忙碌中無法回應，請稍後再執行');
        	  },
        	  onSuccess: function(XHT, resp){
        	  }
        	}
        );
 */

CSRUtil.AjaxHandler = new function(){

	var _ajaxPost_jQuery = !CSRUtil.hasInclude_Prototype() && CSRUtil.hasInclude_jQuery();
	var _isShowCoverPage;
	var _isShowSuccessMessage;

	function initParams(){
		_isShowCoverPage = true;
		_isShowSuccessMessage = true;
	}

	initParams();

	return {

		request: function(requestTxBean){
			var _asynchronous = true;
			return {
				post: function(action, params, successAction, failureAction){
					if(_ajaxPost_jQuery){
						var hasIncludeJS_WIUtil = typeof window.WIUtil != 'undefined';
						var cover;
						if(_isShowCoverPage){
							if(hasIncludeJS_WIUtil){
								var isSuccess = WIUtil.showCoverPage();
								if(!isSuccess){
									cover = CSRUtil.createCoverPage({'id':'_frontCover'});
									cover.show().resizeCoverPage();
								}
							}else{
								cover = CSRUtil.createCoverPage({'id':'_frontCover'});
								cover.show().resizeCoverPage();
							}
						}

						jQuery.ajax({
							url: requestTxBean + action,
							type: 'post',
							async: _asynchronous,
							traditional: true,
							cache: false,
							data: params,
							success:function(resp){
								var errMsg;
								if(resp){
									var requestTimeHandleUUID = resp.requestTimeHandleUUID;
									if(requestTimeHandleUUID && window.utility && utility.keepResponseTimeEndParameters){
										utility.keepResponseTimeEndParameters(requestTimeHandleUUID);
									}
									errMsg = CSRUtil.getReturnMessage(resp);
								}

								if(!errMsg){
									return;
								}

								var msgArray = errMsg.displayMsgDescs.split('\\n');
								var str = '';
								for(var mai=0;mai<msgArray.length;mai++){
									str += msgArray[mai] + '\n';
								}

								str = str.trim();
								var msgBoard = CSRUtil.getMsgBoard(str,errMsg.returnCode);
								/*
								
								if(msgBoard && str!==''){
									var color= isError?'red':'blue';
									var htmlMessage = '<font color="blue">訊息：</font><font color="' + color + '">' + str.replace(/\\n/g,'<br>') + '</font>';
									msgBoard.innerHTML=htmlMessage;
								}
								*/
								var isError = errMsg.returnCode != 0;
								var msgid = errMsg.msgid;
								if(isError){
									var alertMessage = '';
									if(msgid!='' && msgid.length>17){
										alertMessage += '錯誤編號：\n'+msgid;
										alertMessage +='\n';
									}

									alertMessage +=str;

									if(hasIncludeJS_WIUtil){
										WIUtil.displayMessage({msg:alertMessage});
									}else{
										alert(alertMessage);
									}
								}else{
									if(hasIncludeJS_WIUtil){
										WIUtil.closeCoverPage();
									}
								}

								if(CSRUtil.isSuccess(resp)){
									if(successAction) {successAction(resp);}
								}else{
									if(failureAction){failureAction(resp);}
								}
							},
							complete:function(){
								if(_isShowCoverPage && !hasIncludeJS_WIUtil || cover){
									cover.hide();
								}
								initParams();
							}
						});

					}else{
						new Ajax.Request( requestTxBean + action, {
							method: 'post', asynchronous: _asynchronous, parameters: params,
							onSuccess: function( transport ) {
								
								if(Object.isUndefined(transport)){
									return;
								}

								var resp = transport.responseJSON;
								if(Object.isUndefined(resp)){
									return;
								}

								if(CSRUtil.isSuccess(resp)){
									if(successAction) {successAction(resp);}
								}else{
									if(failureAction){failureAction(resp);}
								}
							}
						});
					}
				},
				setSynchronous: function(isSync){
					_asynchronous=!isSync;
				},
				setShowCoverPage: function(isShow){
					_isShowCoverPage = isShow;
				},
				closeSuccMsg: function(){
					_isShowSuccessMessage = false;
				},
				enforceUse_jQuery:function(isUse){
					_ajaxPost_jQuery=isUse;
				}
			};
		},
		getDefaultResponderCallbacks: function(){
			return {
				onCreate: function (request){
/*
					在每次 Ajax request 請求建立時，進行註冊一次動作
*/
					msgWin.registerActive();
					var cover = CSRUtil.createCoverPage({'id':'_frontCover'});

					if(_isShowCoverPage){
						cover.show().resizeCoverPage();
					}
					if(!Object.isUndefined(request.options) && !Object.isUndefined(request.options.timeout)){
/*
						建立 timeout 的處理控制
*/
						var waitTime = request.options.timeout * 1000;
						request.timeoutId = window.setTimeout(
							function(){
								if(CSRUtil.isOnProgress(request.transport)){

									// cancel the readystatechange listener, to avoid call onSuccess function
									request.transport.onreadystatechange = Prototype.emptyFunction;
									request.transport.abort();

									if(Object.isFunction(request.options.onTimeout)){
										Ajax.Responders.dispatch('onTimeout', request);
										request.options.onTimeout();
									}else{
										alert('在等待 ' + request.options.timeout + ' 秒後伺服器仍未回應，請稍後再確認交易執行的結果。');
									}
									Ajax.Responders.dispatch('onComplete', request);
								}
							}, waitTime
						);
					}
				},
				onComplete: function (request, transport){
					var resp = transport.responseJSON;
					var errMsg;
					if(resp){
						var requestTimeHandleUUID = resp.requestTimeHandleUUID;
						if(requestTimeHandleUUID && window.utility && utility.keepResponseTimeEndParameters){
							utility.keepResponseTimeEndParameters(requestTimeHandleUUID);
						}
						errMsg = CSRUtil.getReturnMessage(resp);
					}else{
						var respText = transport.responseText;
						if(respText){

							var bodyTagBeginStr = '<body>';
							var bodyTagBeginIndex = respText.indexOf(bodyTagBeginStr);

							var WAFMsg;
							if(bodyTagBeginIndex>=0){
								WAFMsg = respText.substr(bodyTagBeginIndex+bodyTagBeginStr.length);
								WAFMsg = WAFMsg.substr(0, WAFMsg.indexOf('</body>'));
								WAFMsg = WAFMsg.replace(/<br>/g,'\n');
							}else{
								WAFMsg = respText;
							}
							errMsg = { 'displayMsgDescs': WAFMsg, 'returnCode': -1, 'msgid': '' };
						}
					}
/*
					在每次 Ajax request 請求完成時，進行註銷一次動作
*/
					msgWin.unregisterActive();

					var frontCover = $('_frontCover');

					frontCover.resizeCoverPage();
/*
					若有指定 timeout，清除 timeout 的控制
*/
					if(!Object.isUndefined(request.timeoutId)){
						window.clearTimeout(request.timeoutId);
					}

					if(!errMsg){
						if(Ajax.activeRequestCount == 0){
/*
							當後續未有任何 Ajax request 請求時，則將 cover page 隱藏
*/
							if(!msgWin.isActive()){
								frontCover.hide();
							}
						}
						return;
					}

					var msgArray = $A(errMsg.displayMsgDescs.split('\\n'));
					var str = '';
					msgArray.each(function(s){
						str += s + '\n';
					});

					str = str.trim();
					var msgBoard = CSRUtil.getMsgBoard(str,errMsg.returnCode);
					/*
					
					if(msgBoard && str!==''){
						var color= isError?'red':'blue';
						var htmlMessage = '<font color="blue">訊息：</font><font color="' + color + '">' + str.replace(/\\n/g,'<br>') + '</font>';
						msgBoard.innerHTML=htmlMessage;
					}
					*/

					var isError = errMsg.returnCode != 0;
					var msgid = errMsg.msgid;
					if(CSRUtil.UICore.isOnTheSys(['L.', 'R.', 'J.', 'DS', 'DZ', 'QB', 'AN', 'EP','ZU'])){

						var alertMessage = '';
						if(isError && msgid!='' && msgid.length>17){
							alertMessage += '錯誤編號：\n'+msgid;
							alertMessage +='\n';
							alertMessage +='訊息說明：\n';
						}
						alertMessage +=str;

						if(isError){
							msgWin.show(alertMessage, _isShowCoverPage);
						}else if(_isShowSuccessMessage && str !== ''){
							if(CSRUtil.UICore.isOnTheSys('EP')){
								if(!msgWin.isActive()){
									frontCover.hide();
								}
							}else{
								msgWin.show(alertMessage, _isShowCoverPage);
							}
						}else{
/*
							當後續未有任何 Ajax request 請求時，則將 cover page 隱藏
*/
							if(!msgWin.isActive()){
								frontCover.hide();
							}
						}

					}else{
/*
						當後續未有任何 Ajax request 請求時，則將 cover page 隱藏
*/
						if(!msgWin.isActive()){
							frontCover.hide();
						}

						var alertMessage = '';
						if(isError){

							if(msgid!='' && msgid.length>17){
								alertMessage += '錯誤編號：\n'+msgid;
								alertMessage +='\n';
							}

							alertMessage +='訊息說明：\n'+str;
							alert(alertMessage);

						} else if(str !== '' && !msgBoard){
							alertMessage +='訊息說明：\n'+str;
							if(_isShowSuccessMessage){
								alert(alertMessage);
							}
						}

					}
					initParams();
				},
				onException:function(XHR, ex){
					var errMsg = 'Error :\n';
					errMsg += 'url : ' + XHR['url'];
					errMsg += '\nparams: ' + XHR['options']['parameters'];
					errMsg += '\nException: \n';
					for(var p in ex){
						errMsg += p + '=' + ex[p] + '\n';
					}
					alert(errMsg);
				}
			}
		}
	};
};

CSRUtil.defaultAjaxHandler = CSRUtil.AjaxHandler.getDefaultResponderCallbacks();

// find message board
CSRUtil.getMsgBoard = function( msg , returnCode ){

	var getBottomFrame = function(){
		if(top.frames['leftFrame'] && top.frames['leftFrame'].frames['bottomFrame']){
			return top.frames['leftFrame'].frames['bottomFrame'];
		}else if(parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame']){
			return parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame'];
		}else if(top.frames['bottomFrame']){
			return top.frames['bottomFrame'];
		}else if(parent.frames['bottomFrame']){
			return parent.frames['bottomFrame'];
		}
	};
	
	
	try{
		var msgBoard = null;
		var bottomFrame = getBottomFrame();
		if(bottomFrame){
			if(bottomFrame.contentWindow){
				msgBoard = bottomFrame.contentWindow.document.getElementById('cathay_common_msgBoard'); //包覆在 IFRAME 中
			}else{
				msgBoard = bottomFrame.cathay_common_msgBoard; //舊版，採FRAME分框
			}
		}
		if(msg){
			msg = (msg+'').replace(/\\n/g,'<br>');
			if((returnCode+'').match(/^[-]?[0-9]+$/)){
				msg = '<font color="blue">訊息：</font><font color="' + (parseInt(returnCode)===0?'blue':'red') + '">' + msg + '</font>';
			}else if( msg.indexOf('訊息：') < 0 ){
				msg = '<font color="blue">訊息：' + msg + '</font>';
			}
			msgBoard.innerHTML = msg;
		}
		return msgBoard;
		
	}catch(e){
		if(window.console){
			console.log("取得bottomFrame發生錯誤:");
			console.log(e);
		}
		return;
	}

};

// format with usually used pattern #,###.00  #,### ...

CSRUtil.defaultPattern = '#,###.####';
CSRUtil.replacePattern = /,/g;

CSRUtil.$fmt = function(v, pattern, isInput){

	if(Object.isUndefined(v) || v == null) return '';

	var str = ('' + v).toLowerCase().replace(CSRUtil.replacePattern, '');

	if(str.blank()) return '';

	if(isNaN(str)) return v;

/*
	pattern 有指定小數
*/
	var dot = pattern.indexOf('.');
/*
	精準度判斷，若 pattern 有指定小數，則依指定的小數位數為精準度
	原 $fmt 在執行畫面格式化時，若未指定小數位，則小數位數的部份會直接保留
	為了相容原功能，故保留預設位數至 40 位。但當作輸入時，若未指定小數位數，則精準度設為 0
*/
	var precision = BigNumber.defaultPrecision;
	if(dot != -1){
		precision = pattern.substr(dot+1).length;
	}else if(isInput){
		precision = 0;
	}else{
/*
		非輸入時，未指定小數的話，用預設精準度來格式化(40位)
*/
		dot = pattern.length;
		pattern += '.' +  '#'.times(precision);
	}
/*
	是否有科學記號表示
*/
	var eePrest = str.indexOf('e');
	if( eePrest != -1){
		var powerN = str.substring(eePrest + 1);
		powerN = new Number(powerN);
/*
		精準度預設小數點後 40 位數
*/
		powerN = new BigNumber(10).pow(powerN);
		str = new BigNumber(str.substring(0, eePrest), precision).multiply(powerN).toString();
	}else if(!isInput){
/*
		不是 input 時才做精準度及進位處理
*/
		str = new BigNumber(str, precision).toString();
	}
/*
	是否為負數
*/
	var minus = false;
	if(str.startsWith('-')){
		minus = true;
		str = str.substr(1);
	}
/*
	拆成數字跟小數部份
*/
	var ary = str.split('.', 2);
	var intPart = ary[0];
	var floatPart = ary[1];

	var resultStr = formatInteger(intPart, pattern, dot);
/*
	pattern 有指定小數
*/
	if(precision > 0){

		if(isInput){
/*
			輸入時，小數部份僅做位數的截斷
*/
			if(str.indexOf('.') != -1){
				resultStr += '.' + floatPart.substr(0, precision);
			}
		}else{
			var floatPart = formatFloat(floatPart, pattern, dot, precision);
			if(floatPart){
				resultStr += '.' + 	floatPart;
			}
		}

	}

	if(minus){
		return '-' + resultStr;
	}

	return resultStr;

/*
	數字部份的處理(private method)
*/
	function formatInteger(intPart, pattern, dotPos){
/*
		逗點分隔位置
*/
		var sep = pattern.indexOf(',');

		if(sep == -1){
			return intPart;
		}
/*
		計算每幾位數給分隔號
*/
		var sepLen = (dotPos!=-1?dotPos-sep-1:pattern.length-sep-1);
		var m = intPart.length;
/*
		長度超過才分隔
*/
		if(m > sepLen){

			var firstP = m % sepLen;
			var sectionN = parseInt(m / sepLen);
			var sAry = [];

			if(firstP > 0){
				sAry.push(intPart.substr(0, firstP));
			}

			while(sectionN > 0){
				sAry.push(intPart.substr(firstP, sepLen));
				firstP += sepLen;
				sectionN--;
			}
			intPart = sAry.join(',');
		}
		return intPart;
	}
/*
	end of 數字部份的處理
*/

/*
	小數部份的處理(private method)
*/
	function formatFloat(floatPart, pattern, dotPos, precision){

		var floatPattern = pattern.substr(dotPos+1);

		if(!isNaN(floatPart)){
/*
			數值有小數，根據 pattern 的位數先用 0 補滿
*/
			var fm = floatPart.length;
/*
			小數部份長度超過指定的長度
*/
			if(fm > precision){
				floatPart = floatPart.substr(0, precision);
			}else if(fm < precision) {
				var padL = precision - floatPart.length;
/*
				先將小數部位用 0 補滿指定的精準位數
*/
				if(padL > 0){
					floatPart += '0'.times(padL);
				}
			}
		}else{
/*
			數值沒有小數，用 0 補滿
*/
			floatPart = '0'.times(precision);
		}
/*
		跟 pattern 比較，若 pattern 為 # 且數字為 0 則不保留
*/
		var x = floatPart.length - 1;

		while(x >= 0){
			if(floatPattern.charAt(x) == '#' && floatPart.charAt(x) != '0'){
				break;
			}else if(floatPattern.charAt(x) == '0'){
				break;
			}else{
				floatPart = floatPart.substr(0, x);
			}
			x--;
		}
		return floatPart;
	}
/*
	end of 小數部份的處理
*/

};

/*
Y2k Date formate for YYYY-MM-DD, YYYYMMDD, YYYY/MM/DD
*/
CSRUtil.Y2KDatePattern = [/^(\d{4})-(\d{2})-(\d{2})/, /^(\d{4})(\d{2})(\d{2})/, /^(\d{4})\/(\d{2})\/(\d{2})/];

/*
Date object extension for transfering ROC date format
*/
Date.toROC = function(d){
	return Date.toInputROC(d, '/');
};

Date.toInputROC = function(d, delimiter){
	if(!d) return '';

	var timePart = d.split(' ');
	var time;

	if(timePart.length && timePart.length > 1){
		time = timePart[1];
	}

	for(var i=0; i<CSRUtil.Y2KDatePattern.length; i++){
		var p = d.match(CSRUtil.Y2KDatePattern[i]);
		if(p){
			var r;
			if(delimiter){
				r = (p[1]-1911) + delimiter + p[2] + delimiter + p[3];
			}else{
				r = (p[1]-1911) + p[2] + p[3];
			}
			if(time){
				r = r + ' ' + time;
			}
			return r;
		}
	}
	return '';
};
/*
table maintain
*/
CSRUtil.clearTable = function (tableID){
	var tb = $(tableID);
	var stopPoint = tb.tHead?0:1;
	var i = tb.rows.length;
	while(i>stopPoint){
		tb.deleteRow(i-1);
		i--;
	}
};

/*
四捨五入至指定的位數，預設取四位
*/
CSRUtil.round = function(val, scale){
	if(scale == undefined) scale = 4;
 	val = Math.round(val * Math.pow(10, scale))/Math.pow(10 ,scale);
 	return  val;
};

String.emptyIf = function(str, replaceStr){
	if(str || str === 0){return str;}
	return replaceStr;
};

String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,'');
};
/*
Map object to select options as name
*/
CSRUtil.mapToSelectOptions = function(e, m, d){
	var selectObject = $(e);
	m = $H(m);
	m.each(function(item){
			var oneOpt = document.createElement('option');
				oneOpt.text = item['key'];
				oneOpt.value = item['value'];
			selectObject.add(oneOpt);
	});
	if(d)selectObject.value=d;
};
/*
List<Map> object to select options as name
*/
CSRUtil.listToSelectOptions = function(e, l, d){
	var selectObject = $(e);
	for(var i=0; i<l.length; i++){
			var m = $H(l[i]);
			m.each(function(item){
				var oneOpt = document.createElement('option');
					oneOpt.text = item['key'];
					oneOpt.value = item['value'];
				selectObject.add(oneOpt);
			});
	}
	if(d)selectObject.value=d;
};
/*
標識為錯誤
*/
CSRUtil.mark = function(elem){
	elem.style.backgroundColor = '#FF8888';
};
/*
清除錯誤標識
*/
CSRUtil.unmark = function(elem){
	elem.style.backgroundColor = '';
};
/**
 *	@public
 *	@class 將 grid 匯出成 execl 表
 *	CSRUtil.exportXls('股票價量2009_07_20.xls', [grid1, grid2], ['股票', '指數']);
 *	@param fileName - 下載的檔名
 *	@param grids    - 欲產生 xls 表的 grid 物件陣列
 *	@param sheetNames - 各試算表的標簽名，字串陣列 (非必要)
 **/
CSRUtil.exportXls = function(fileName, grids, sheetNames){
/*
	取得 grid 中非勾選控制的資料欄定義，僅取出 dataIndex 及 header 來用
*/
	function getColumns(cols, grid) {
		var columns = [];
		var rawData = grid.getRecords()[0];
		cols.each(function(col){
			if(col.dataIndex != '_grid_selected_row' && col.dataIndex != '_grid_onRowClick'){
				columns.push({'dataIndex':col.dataIndex, 'header':col.header, 'type':getType(rawData, col.dataIndex)});
			}
		});
		return columns;
	}
/*
	依資料類型決定 excel 的資料類型(文、數字)
*/
	function getType(rawData, dataIndex){
		if(!rawData) return 'string';
		var data = rawData[dataIndex];
		if(typeof(data) == 'number'){
			return 'number';
		}
		return 'string';
	}
/*
	上傳的 JSON
*/
	var xlsData = {
		'fileName': fileName
	};

	var sheets = [];

	var theSheetNames = sheetNames;
	if(Object.isUndefined(sheetNames) || sheetNames == null){
		theSheetNames = [];
	}
	for(var i=0; i<grids.length; i++){
		var grid = grids[i];
		var cols = grid.getColumns();
		var emptyColumns = grid.getEmptyColumns();
		sheets[i] = {
			'sheetName':theSheetNames[i] || '',
			'columns': getColumns(cols, grid),
			'records': grid.getRecords()
		};
		if(emptyColumns){
			var eCols = [];
			for(var x=0; x<emptyColumns.length; x++){
				var eCol = emptyColumns[x];
				var colSpan = 1;
				if(eCol.attrs && eCol.attrs.colSpan){
					colSpan = eCol.attrs.colSpan;
				}
				eCols[x] = {header:eCol.header || '',
				colSpan: colSpan};
			}
			sheets[i].emptyColumns = eCols;
		}
	}

	xlsData.sheets = sheets;

	var form = new Element('form', {'action':'/ZRWeb/xls', 'target':'_blank', 'method':'post'});
	form.setStyle({
		'display':'none'
	});

	form.insert(new Element('input', {
		'type':'hidden',
		'name':'xlsData',
		'value':Object.toJSON(xlsData)
	}));

	document.body.appendChild(form);
	form.submit();
	form.remove();
};
/*
	將 YYYY-MM-DD 格式字串轉為日期物件
*/
CSRUtil.parseDate = function(str){
	if(!str) return null;
	return Date.parse(str.replace(/-/g, '/'));
};
/*
	比對兩個日期的差異天數(d2 - d1), 日期格式為 YYYY-MM-DD
*/
CSRUtil.dateRange = function (d1, d2){
	d1 = CSRUtil.parseDate(d1);
	d2 = CSRUtil.parseDate(d2);
	return (d2 - d1)/86400000;
};
/**
 *	@public
 *	@class 輔助輸入日期,將輸入轉為 yyyy-mm-dd, 且只能輸入數字
 *	抓取Html 中input含有 自訂屬性為datatype="date"，設定0.1秒偵測1次
 *	modify 2009-06-11 by fran
 *	改為監聽 keypress event 時變更格式，keyup 時檢查日期的合理性
 *	抓取Html 中input含有 自訂屬性為datatype="date"，設定0.1秒偵測1次
 *	若不為合理的日期，則會還原前值
 *	
 *	keypress 調整至 keyup ，因 chrome 中文輸入法 KeyCode 229 數字鍵盤輸入輔助輸入-無法觸發問題 
 *	不可使用在 keydown 當使用 IE 時補上 - 會有游標停留在原本位置問題
 *	中文輸入法 無法透過 Event.stop(event) 禁止輸入 -，
 *	使用 compositionend 中文輸入後進行資料判斷處理，與底層日期處理自動加上-，判斷中文輸入事件 若輸入欄位值結尾 --，將--取代掉保留一個 -
 *	modify 2022-01-21 by 晟芳
 *	
 *	優化調整增加可使用keycode：tab、ctrl、C、V 、X、Z
 *	modify 2022-04-22 by 晟芳
 **/
function autoFormatToDate(){
/*
	//var detectTime = 0.1;	//偵測時間 100 milliseconds
*/
	var inputs = $$('input:not(.hasAutoFormatToDateEvent)[datatype="date"]');
	inputs.each(function (it) {

		if (!it.hasAttribute('size')) {
			it.writeAttribute('size', 11);
		}

		it.writeAttribute('maxLength', 10);

		it.observe('compositionend', function (event) {
			var el = event.element();
			var val = el.value;
			var index = val.indexOf('--');
			var valLength = val.length;
			if (index != -1 && index == (valLength - 2)) {
				el.value = val.substring(0, valLength - 1);
			}
		});
		var ignoreKeyCode = [229, 9, 17, 67, 86, 88, 90];//229:中文輸入法、9:Tab、17:Ctrl、67:C、86:V、88:X、90:Z

		it.observe('keydown', function (event) {
			var keyCode = event.keyCode;

			if (keyCode == 8 || keyCode == 46 || keyCode == 37 || keyCode == 39) { //BackSpace:8,-:173,189,109 
				return;
			}
			if (event.char === '-' || event.key === '-' || event.code === 'NumpadSubtract' || keyCode == 109 || keyCode == 189 || keyCode == 173) {
				Event.stop(event);
				return;
			}

			if (!(keyCode > 47 && keyCode < 58) && !(keyCode > 95 && keyCode < 106) && ignoreKeyCode.indexOf(keyCode) == -1) { 
				Event.stop(event);
				return;
			}
		});

		it.observe('keyup', function (event, observer) {
			var keyCode = event.keyCode;
			var el = event.element();

			if (event.char === '-' || event.key === '-' || event.code === 'NumpadSubtract') {
				return;
			}
			if (!(keyCode > 47 && keyCode < 58) && !(keyCode > 95 && keyCode < 106) && ignoreKeyCode.indexOf(keyCode) == -1) {
				return;
			}

			switch (el.value.length) {
				case 4:
				case 7:
					el.value = el.value + '-';
			}

			var theD = el.value;
			var theDLength = theD.length;
			var d;

			if (theDLength != 10) {
				return;
			}

			if (theD.match(/^(\d{4})-(\d{2})-(\d{2})$/)) {
				d = new Date(RegExp.$1 + '/' + RegExp.$2 + '/' + RegExp.$3);
			}

			if (!d || d.getMonth() != (RegExp.$2 - 1) || d.getDate() != RegExp.$3) {
				el.value = el.readAttribute('__lastValue') || '';
			}
		});
		it.addClassName('hasAutoFormatToDateEvent');
	});
};

/*
判斷是否為數字的輸入(0-9, -, .)
*/
CSRUtil.pressNumber = function(code){
	if((code > 47 && code < 58) || code == 46 || code == 45 || code == 8){
		return true;
	}
	return false;
};

/*
判斷是否為數字的 keyup(0-9, -, .)
經測試的結果，numpad 的數字 keypress 與 keyup 所得的 key code 不一樣
故加上一些 keycode 的判斷。目前些方法僅用在與 autoFormatToNumber 一並使用
*/
CSRUtil.upNumber = function (code){
	if( (code > 95 && code < 106) || code == 110 ||code == 109){
		return true;
	}
	return CSRUtil.pressNumber(code);
};

/*
轉為數字，空白或 undefined 或 null 或 NaN 傳回 0
*/
CSRUtil.getNumber = function(val){
	if(Object.isNumber(val)) return val;
	if(Object.isUndefined(val) || val == null) return 0;
	val = new String(val);
	val = val.replace(CSRUtil.replacePattern ,'');
	if(isNaN(val) || val.blank()) return 0;
	return new Number(val)-0;
};

/*
輔助輸入數字且只能輸入數字，小數點及負號，文字靠右
抓取Html 中input含有 自訂屬性為datatype="number" 的elemnt
若有定義 pattern 的屬性，則會依 pattern 來限制可輸入的文字
@return 回傳被修正過的數字 input elements
*/
function autoFormatToNumber(elemID){

	var inputs;

	if(elemID){
		inputs = $(elemID).select('input[datatype="number"]');
	}else{
		inputs = $$('input[datatype="number"]');
	}

	if(inputs.length > 0 && !Form.Element.Serializers.functionModified){
/*
		修改 prototype 的 serializers，加上對 datatype="number" 的處理
*/
		Form.Element.Serializers['input']
			= Form.Element.Serializers['input'].wrap(
				function(proceed, element, value){
/*
					value 是給 setValue() 用的，取值的時候不用此參數
*/
					if(element.readAttribute('datatype') == 'number'){

						if(Object.isUndefined(value)){
/*
							get value(去掉逗點)
*/
							return element.value.replace(CSRUtil.replacePattern ,'');

						}else{
/*
							 set value
							若有定義 pattern 則用欄位定義的 pattern，否則用 defaultPattern, #,###.#### (小數四位)
*/
							var pattern = element.readAttribute('pattern') || CSRUtil.defaultPattern;

							value = new String(value);
							element.value = CSRUtil.$fmt(value, pattern, element.readAttribute('_isInput'));
							element.writeAttribute('_isInput');

						}

					}else{
						return proceed(element, value);
					}

				}
			);

		Form.Element.Serializers.functionModified = true;

	}

	inputs.each(function(it){

		it.setStyle({
			'textAlign': 'right',
			'paddingRight':'3px'
		});

		it.observe('keypress', function(event){

				var code = event.keyCode;

				if(!CSRUtil.pressNumber(code)){
					Event.stop(event);
				}

			}
		);

		it.observe('keyup', function(event){

			var code = event.keyCode;

            if (CSRUtil.upNumber(code)) {

                var elem = event.element();
                var pVar = elem.value;

                var pos = 0 , oldCommaCnt = 0 , newCommaCnt = 0 ;
                /*  取出原 cursor 位置  */
                if(document.selection){
                    var oldRange = document.selection.createRange();
                    oldRange.moveStart('character', -pVar.length);
                    pos = oldRange.text.length;
                }else{
                    pos = elem.selectionStart;
                }
                /* 取得原,數量 */
                oldCommaCnt = pVar.match(/,/g);
                oldCommaCnt = oldCommaCnt ? oldCommaCnt.length : 0;
                /* 格式化資料 */
                elem.writeAttribute('_isInput', true);
                elem.setValue(pVar);
                /* 取得格式化後,數量 */
                newCommaCnt = elem.value.match(/,/g);
                newCommaCnt = newCommaCnt ? newCommaCnt.length : 0;

                /*  還原 cursor 位置  */
				//[20220121] 調整 chrome 不支援 createTextRange 問題
				var cursorPos = pos + (newCommaCnt - oldCommaCnt);
				if (elem.createTextRange) { //IE
					var textRange = elem.createTextRange();
					textRange.move('character', cursorPos);
					textRange.select();
				}else{
					elem.setSelectionRange( cursorPos, cursorPos);
				}
            }

		});

	});

	return inputs;
}

function MsgWin() {

	var win;
	var contentDiv;
	var titleDiv;
	var btn;
	var dragDiv;
	var x, y, w, h;
	var maxWidth = 600;
	var maxHeight = 500;
	var minWidth = 180;
	var contentDivSubtractWidth = 12;
	var actives = [];
	var displayMsgs = [];
	var callback;

	function build(){

		if(!CSRUtil.hasInclude_Prototype()){
			return;
		}

		actives.length = 0;
		win = new Element('div', {'align':'center' , 'id':'msg-win'});
		win.setStyle({
			'fontFamily': 'Verdana, Arial, sans-serif, 微軟正黑體',
			'fontSize':'10pt',
			'border':'solid 1px #000',
			'position': 'absolute',
			'padding':'0 5px 5px 5px',
			'backgroundColor': '#0066CC',
			'width': minWidth+'px',
			'zIndex':999,
			//'filter': 'alpa(opacity=95)',	// old IE
			//'filter': 'progid:DXImageTransform.Microsoft.Alpha(Opacity=95,FinishOpacity=15, Style=3, StartX=0, FinishX=100, StartY=0,FinishY=16)', // supported by current IE
			//'-moz-opacity': '0.95',			// Moz + FF
			'opacity': '0.95',				// support new version browser
			'boxShadow':'0px 0px 10px 2px #000'
		});

		btn = new Element('input', {'type':'button', 'value':'確定'}).addClassName('button').setStyle({
			'padding': '0 15px 0 15px'
		}).observe('click', function(event){
			/*
				解除msgWin對於所有按扭動作都會將msgBar清空之動作，否則msgBar會被清空
			*/
			event.stopPropagation && event.stopPropagation();
			
			//document.body.style.overflow='';
			if(!win || !win.parentNode){ return; }
			win.remove();
			msgWin.unregisterActive();
/*
			當後續未有任何 Ajax request 請求時，則將 cover page 隱藏
*/
			if(!msgWin.isActive()){
				var cover = CSRUtil.createCoverPage({'id':'_frontCover'});
				cover.hide();
			}
			displayMsgs=[];
			contentDiv.update('');
			if(callback && Object.isFunction(callback)){
				callback();
			}

		});

		titleDiv = new Element('div', {'align':'left'});
		titleDiv.setStyle({
			'backgroundColor':'#0066CC',
			'fontWeight ':'bold',
			'color':'#fff',
			'padding':'8px 0 8px 2px',
			'cursor':'move'
		});
		titleDiv.innerHTML = '網頁訊息';

		contentDiv = new Element('div', {'align':'left', 'id':'msg-win_content'});
		contentDiv.setStyle({
			'backgroundColor': '#FFFFFF',
			'overflow':'auto',
			'height':'105px',
			'borderLeft': '1px solid #000',
			'borderRight': '1px solid #000',
			'borderTop': '1px solid #000',
			'paddingLeft':'15px',
			'paddingTop':'10px',
			'position': 'relative',
			'scrollbar-face-color':'#D4D0C8',
			'scrollbar-highlight-color':'#FFFFFF',
			'scrollbar-3dlight-color':'#D4D0C8',
			'scrollbar-darkshadow-color':'#404040',
			'scrollbar-shadow-color':'#808080',
			'scrollbar-arrow-color':'#000000',
			'scrollbar-track-color':'#CCCCCC'
		});

		bottomDiv = new Element('div');
		bottomDiv.setStyle({
			'backgroundColor':'#EEEEEE',
			'borderLeft': '1px solid #000',
			'borderRight': '1px solid #000',
			'borderBottom': '1px solid #000',
			'padding': '10px 0 10px 0'
		});
		bottomDiv.insert(btn);

		win.insert(titleDiv);
		win.insert(contentDiv);
		win.insert(bottomDiv);

		dragDiv = new Element('div');
		dragDiv.setStyle({
			'position':'absolute',
			'border':'1px solid #000000'
		});

		titleDiv.observe('mousedown', startDrag);
	}

	function startDrag(){
		titleDiv.stopObserving('mousedown', startDrag);
		x = Event.pointerX(event);
		y = Event.pointerY(event);

		var pos = win.positionedOffset();
		w = x - pos.left;
		h = y - pos.top;

		dragDiv.setStyle({'width':win.getWidth(), 'height':win.getHeight(), 'left':pos.left, 'top':pos.top});
		document.body.appendChild(dragDiv);
		dragDiv.show();
		Event.observe(document, 'mousemove', drag);
		Event.observe(document, 'mouseup', stopDrag);
	}

	function drag(event){
		x = Event.pointerX(event);
		y = Event.pointerY(event);
		Event.stop(event);
		dragDiv.setStyle({
			top:(y - h) + 'px',
			left:(x - w) + 'px'
		});
		document.body.appendChild(win);
		win.remove();
	}

	function stopDrag(event){
		Event.stopObserving(document, 'mousemove', drag);
		Event.stopObserving(document, 'mouseup', stopDrag);
		Event.stop(event);
		var pos = dragDiv.positionedOffset();
		win.setStyle({
			top: parseInt(pos.top,10) +'px', 
			left: parseInt(pos.left,10) +'px'
		});
		dragDiv.remove();
		document.body.appendChild(win);
		titleDiv.observe('mousedown', startDrag);
	}

	function addDisplayMsg(msg){
		var isDuplicate = false;
		for(var i=0;i<displayMsgs.length;i++){
			isDuplicate = displayMsgs[i]==msg;
			if(isDuplicate){
				break;
			}
		}
		if(!isDuplicate){
			displayMsgs.push(msg);
		}
	}

	build();

	return {

		show:function(msg){

			//document.body.style.overflow = 'hidden';

			var splitSign = '<br/>';
			if(msg === null || msg === undefined || msg === ''){
				msg = '<font color="gray">(無訊息內容)</span>';
			}else{
				msg = (msg+"").replace(/\\n|\n/g, splitSign);
			}
			addDisplayMsg(msg);

			var cover = CSRUtil.createCoverPage({'id':'_frontCover'});
			cover.show().resizeCoverPage();

			var x = msg.length * 15;
			if(contentDiv.innerText==''){
				document.body.appendChild(win);
				actives.push(true);
				contentDiv.update(msg);

				var keyPressHandler = function(e){
					try{
						
						/* 此事件僅執行一次 */
						document.stopObserving('keypress' , keyPressHandler);
					}catch(e){
						window.console && console.log("msgWin keypress Error:" + e);
					}
					try{
						/*
						若按下 Enter、Esc、空白鍵時，則觸發訊息內確定的 click event
						*/
						if(e.keyCode == Event.KEY_RETURN || e.keyCode == Event.KEY_ESC || e.keyCode == 32) {
							if(!win || !win.parentNode){ return; }
							btn.click();
							/* 停止事件 */
							Event.stop(e);
						}
					}catch(e){
						window.console && console.log("msgWin keypress Error:" + e);
					}
				}

				document.observe('keypress', keyPressHandler);

				if(x > maxWidth){
					win.setStyle({'width':maxWidth + 'px'});
				}else if(x > minWidth){
					win.setStyle({'width': x + 'px'});
				}else{
					win.setStyle({'width': minWidth+'px'});
				}

			}else{

				var contentDivWidth = contentDiv.getWidth();
				if(contentDivWidth < maxWidth-contentDivSubtractWidth && contentDivWidth < x){
					if(x > maxWidth){
						win.setStyle({'width':maxWidth + 'px'});
					}else if(x > minWidth){
						win.setStyle({'width': x + 'px'});
					}
				}

				var updateMsg='';
				for(var i=0;i<displayMsgs.length;i++){
					if(i>0){
						updateMsg+=splitSign;
					}
					updateMsg+=displayMsgs[i];
				}
				contentDiv.update(updateMsg);
			}

			var scrollOffsets = document.viewport.getScrollOffsets();

			win.setStyle({
				'top': parseInt((document.body.clientHeight/4)+scrollOffsets['top'] , 10) + 'px',
				'left': parseInt((document.body.clientWidth-win.getWidth())/2+scrollOffsets['left'] , 10) + 'px'
			});

			win.remove();
			document.body.appendChild(win);

			btn.focus();
		},

		setCallback:function(theCB){
			callback = theCB;
		},
		clearCallback:function(){
			callback = null;
		},
		isActive:function(){
			return actives.length>0;
		},
		registerActive:function(){
			actives.push(true);
		},
		unregisterActive:function(){
			if(actives.length>0){
				actives.pop();
			}
		}
	}
}

var msgWin = new MsgWin();

/*
BigNumber class(測試時 javascript number 在整數位數大於 17 位時會不正確，應用此 class 計算)
+ Jonas Raoni Soares Silva
@ http://jsfromhell.com/classes/bignumber [rev. #4]
self fix round() bug @2010-08-09
*/
var BigNumber = function(n, p, r){
	var o = this, i;
	if(n instanceof BigNumber){
		for(i in {precision: 0, roundType: 0, _s: 0, _f: 0}) o[i] = n[i];
		o._d = n._d.slice();
		return;
	}
	o.precision = isNaN(p = Math.abs(p)) ? BigNumber.defaultPrecision : p;
	o.roundType = isNaN(r = Math.abs(r)) ? BigNumber.defaultRoundType : r;
	o._s = (n += '').charAt(0) == '-';
	o._f = ((n = n.replace(/[^\d.]/g, '').split('.', 2))[0] = n[0].replace(/^0+/, '') || '0').length;
	for(i = (n = o._d = (n.join('') || '0').split('')).length; i; n[--i] = +n[i]);
	o.round();
};
with({$: BigNumber, o: BigNumber.prototype}){
	$.ROUND_HALF_EVEN = ($.ROUND_HALF_DOWN = ($.ROUND_HALF_UP = ($.ROUND_FLOOR = ($.ROUND_CEIL = ($.ROUND_DOWN = ($.ROUND_UP = 0) + 1) + 1) + 1) + 1) + 1) + 1;
	$.defaultPrecision = 40;
	$.defaultRoundType = $.ROUND_HALF_UP;
	o.add = function(n){

		if(this._s != (n = new BigNumber(n))._s)
			return n._s ^= 1, this.subtract(n);
		var o = this._rounding ? this : new BigNumber(this);
		var a = o._d, b = n._d, la = o._f, lb = n._f, n = Math.max(la, lb), i, r;
		la != lb && ((lb = la - lb) > 0 ? o._zeroes(b, lb, 1) : o._zeroes(a, -lb, 1));
		i = (la = a.length) == (lb = b.length) ? a.length : ((lb = la - lb) > 0 ? o._zeroes(b, lb) : o._zeroes(a, -lb)).length;
		for(r = 0; i; r = (a[--i] = a[i] + b[i] + r) / 10 >>> 0, a[i] %= 10);
		return r && ++n && a.unshift(r), o._f = n, o.round();
	};
	o.subtract = function(n){
		if(this._s != (n = new BigNumber(n))._s)
			return n._s ^= 1, this.add(n);
		var o = new BigNumber(this), c = o.abs().compare(n.abs()) + 1, a = c ? o : n, b = c ? n : o, la = a._f, lb = b._f, d = la, i, j;
		a = a._d, b = b._d, la != lb && ((lb = la - lb) > 0 ? o._zeroes(b, lb, 1) : o._zeroes(a, -lb, 1));
		for(i = (la = a.length) == (lb = b.length) ? a.length : ((lb = la - lb) > 0 ? o._zeroes(b, lb) : o._zeroes(a, -lb)).length; i;){
			if(a[--i] < b[i]){
				for(j = i; j && !a[--j]; a[j] = 9);
				--a[j], a[i] += 10;
			}
			b[i] = a[i] - b[i];
		}
		return c || (o._s ^= 1), o._f = d, o._d = b, o.round();
	};
	o.multiply = function(n){
		var o = new BigNumber(this), r = o._d.length >= (n = new BigNumber(n))._d.length, a = (r ? o : n)._d,
		b = (r ? n : o)._d, la = a.length, lb = b.length, x = new BigNumber, i, j, s;
		for(i = lb; i; r && s.unshift(r), x.set(x.add(new BigNumber(s.join('')))))
			for(s = (new Array(lb - --i)).join('0').split(''), r = 0, j = la; j; r += a[--j] * b[i], s.unshift(r % 10), r = (r / 10) >>> 0);
		return o._s = o._s != n._s, o._f = ((r = la + lb - o._f - n._f) >= (j = (o._d = x._d).length) ? this._zeroes(o._d, r - j + 1, 1).length : j) - r, o.round();
	};
	o.divide = function(n){
		if((n = new BigNumber(n)) == '0')
			throw new Error('Division by 0');
		else if(this == '0')
			return new BigNumber;
		var o = new BigNumber(this), a = o._d, b = n._d, la = a.length - o._f,
		lb = b.length - n._f, r = new BigNumber, i = 0, j, s, l, f = 1, c = 0, e = 0;
		r._s = o._s != n._s, r.precision = Math.max(o.precision, n.precision),
		r._f = +r._d.pop(), la != lb && o._zeroes(la > lb ? b : a, Math.abs(la - lb));
		n._f = b.length, b = n, b._s = false, b = b.round();
		for(n = new BigNumber; a[0] == '0'; a.shift());
		out:
		do{
			for(l = c = 0, n == '0' && (n._d = [], n._f = 0); i < a.length && n.compare(b) == -1; ++i){
				(l = i + 1 == a.length, (!f && ++c > 1 || (e = l && n == '0' && a[i] == '0')))
				&& (r._f == r._d.length && ++r._f, r._d.push(0));
				(a[i] == '0' && n == '0') || (n._d.push(a[i]), ++n._f);
				if(e)
					break out;
				if((l && n.compare(b) == -1 && (r._f == r._d.length && ++r._f, 1)) || (l = 0))
					while(r._d.push(0), n._d.push(0), ++n._f, n.compare(b) == -1);
			}
			if(f = 0, n.compare(b) == -1 && !(l = 0))
				while(l ? r._d.push(0) : l = 1, n._d.push(0), ++n._f, n.compare(b) == -1);
			for(s = new BigNumber, j = 0; n.compare(y = s.add(b)) + 1 && ++j; s.set(y));
			n.set(n.subtract(s)), !l && r._f == r._d.length && ++r._f, r._d.push(j);
		}
		while((i < a.length || n != '0') && (r._d.length - r._f) <= r.precision);
		return r.round();
	};
	o.mod = function(n){
		return this.subtract(this.divide(n).intPart().multiply(n));
	};
	o.pow = function(n){
		var o = new BigNumber(this), i;
		if((n = (new BigNumber(n)).intPart()) == 0) return o.set(1);
		for(i = Math.abs(n); --i; o.set(o.multiply(this)));
		return n < 0 ? o.set((new BigNumber(1)).divide(o)) : o;
	};
	o.set = function(n){
		return this.constructor(n), this;
	};
	o.compare = function(n){
		var a = this, la = this._f, b = new BigNumber(n), lb = b._f, r = [-1, 1], i, l;
		if(a._s != b._s)
			return a._s ? -1 : 1;
		if(la != lb)
			return r[(la > lb) ^ a._s];
		for(la = (a = a._d).length, lb = (b = b._d).length, i = -1, l = Math.min(la, lb); ++i < l;)
			if(a[i] != b[i])
				return r[(a[i] > b[i]) ^ a._s];
		return la != lb ? r[(la > lb) ^ a._s] : 0;
	};
	o.negate = function(){
		var n = new BigNumber(this); return n._s ^= 1, n;
	};
	o.abs = function(){
		var n = new BigNumber(this); return n._s = 0, n;
	};
	o.intPart = function(){
		return new BigNumber((this._s ? '-' : '') + (this._d.slice(0, this._f).join('') || '0'));
	};
	o.valueOf = o.toString = function(){
		var o = this;
		return (o._s ? '-' : '') + (o._d.slice(0, o._f).join('') || '0') + (o._f != o._d.length ? '.' + o._d.slice(o._f).join('') : '');
	};
	o._zeroes = function(n, l, t){
		var s = ['push', 'unshift'][t || 0];
		for(++l; --l;  n[s](0));
		return n;
	};
	o.round = function(){
		if('_rounding' in this) return this;
		var $ = BigNumber, r = this.roundType, b = this._d, d, p, n, x;
		for(this._rounding = true; this._f > 1 && !b[0]; --this._f, b.shift());
		for(d = this._f, p = this.precision + d, n = b[p]; b.length > d && !b[b.length -1]; b.pop());
		x = (this._s ? '-' : '') + (p - d ? '0.' + this._zeroes([], p - d - 1).join('') : '') + 1;
		if(b.length > p){
			n && (r == $.ROUND_DOWN ? false : r == $.ROUND_UP ? true : r == $.ROUND_CEIL ? !this._s
			: r == $.ROUND_FLOOR ? this._s : r == $.ROUND_HALF_UP ? n >= 5 : r == $.ROUND_HALF_DOWN ? n > 5
			: r == $.ROUND_HALF_EVEN ? n >= 5 && b[p - 1] & 1 : false) && this.add(x);
			b.splice(p, b.length - p);
		}
		return delete this._rounding, this;
	};
}

/**
 * 瀏覽器是否支援html5 sessionStorage 技術
 */
CSRUtil._is_html_storage_enable = !!(window.sessionStorage && window.sessionStorage.getItem);

/** 檢查是否能用window.top.LP_JSON進行儲存資料(原始方法)
 * 採用非原始方法時機：
 * 1. 未包含在框架中
 * 2. sessionStorage已有儲存資料
 * 3. 子頁面與母頁面非同源  */
CSRUtil._is_LPJSON_at_top_worked = true;
 /* 非傳統方式需支援瀏覽器 sessionStorage 功能  */
if(CSRUtil._is_html_storage_enable){
	CSRUtil._is_LPJSON_at_top_worked = ( window != window.top );
	if(CSRUtil._is_LPJSON_at_top_worked){
		CSRUtil._is_LPJSON_at_top_worked = !sessionStorage.getItem('LP_JSON');
	}
	if(CSRUtil._is_LPJSON_at_top_worked){
		try{
			window.top.document.body.setAttribute('data-test','Orgin-test');
		}catch(e){
			window.console && console.log('[CSRUtil] using sessionStorage to save data. cause there has Orgin problem.');
			CSRUtil._is_LPJSON_at_top_worked = false;
		}
	}
}

CSRUtil.enableSessionStorage = function( enable ){
	enable = (enable === true);
	if(enable){
		enable = CSRUtil._is_html_storage_enable && !!window.JSON.parse;
		if(!enable){
			window.console && console.log('[CSRUtil][enableSessionStorage] can not enable session storage. browser not support.');
		}
	}
	CSRUtil._is_LPJSON_at_top_worked = !enableSessionStorage;
}

/**
 *	@public
 *	@class 發送連結至指定交易, 用 linkParams.action 來指定 URL. 若有自定的回上一頁查詢參，可用 JSON 的格式，放在 linkParams.BA_ARG 中
 *	@param linkParams 給指定交易的參數(LP_JSON)
 *  @param linkParams.action 來指定跳轉的 URL [required]
 *  @param linkParams.BA_ARG 除在保留form中自動抓取的參數外，要加入記憶的資料
 *  @param linkParams.{any} 要傳給下一個頁面的參數
 *	@param formID 指定保留的查詢參數，採用serialize方法來進行資料讀取
 *  @version 2.0.0
 *  @editor i9300618 
 **/
CSRUtil.linkTo = function(linkParams, formID){

	if(!linkParams || !linkParams.action){
		alert('請指定 action 參數');
		return;
	}

	var myFormArgs;
	if(!formID || (formID.tagName != 'FORM' && Object.prototype.toString.call(formID) != '[object String]')){
		myFormArgs = {};
	}else{
		var inputForm = $(formID);
		if(!inputForm){
			myFormArgs = {};
		}else{
			myFormArgs = inputForm.serialize(true);
		}
	}
	//keep all custom BQ_ARG if any
	if(linkParams.BQ_ARG){
		var new_BQ_ARG = {};
		for( var k in linkParams.BQ_ARG){
			new_BQ_ARG[k] = linkParams.BQ_ARG[k];
		}
		for( var k in myFormArgs){
			new_BQ_ARG[k] = myFormArgs[k];
		}
		linkParams.BQ_ARG = new_BQ_ARG;
	}else{
		linkParams.BQ_ARG = myFormArgs;
	}

	//store the url path as the sender
	//you can get RQ_SENDER in LP_JSON to know who create the LP_JSON
	linkParams.RQ_SENDER = window.location.pathname;
	//alert(linkParams.RQ_SENDER);
	
	var LP_JSON = window.JSON && JSON.stringify ? JSON.stringify(linkParams) : ( Object.toJSON ? Object.toJSON(linkParams) : null );
	
	if(!LP_JSON){
		window.console && console.log('[CSRUtil][linkto] Can not convert to JSON.');
		return;
	}
	
	var linkForm = document.createElement('form'); 
	linkForm.setAttribute('method','post');
	linkForm.setAttribute('action',linkParams.action);
	linkForm.style.display = 'none';
	
	var LP_JSON_input = document.createElement('input');
	LP_JSON_input.setAttribute('type','hidden');
	LP_JSON_input.setAttribute('name','LP_JSON');
	LP_JSON_input.value = LP_JSON;
	
	linkForm.appendChild(LP_JSON_input);
	document.body.appendChild(linkForm);
	
	//keep the LP_JSON in top window
	var orgLP_JSON = CSRUtil._is_LPJSON_at_top_worked ? top.LP_JSON : window.sessionStorage.getItem('LP_JSON');
	
	var newLP_JSON; 
	if(!orgLP_JSON){
		newLP_JSON = LP_JSON;
	}else{
		orgLP_JSON = window.JSON && JSON.parse ? JSON.parse(orgLP_JSON) : orgLP_JSON.evalJSON();
		var type = Object.prototype.toString.call(orgLP_JSON);
		if(type == '[object Array]'){
			orgLP_JSON.push(linkParams);
		}else{
			orgLP_JSON = [orgLP_JSON, linkParams];
		}
		newLP_JSON = window.JSON && JSON.stringify ? JSON.stringify(orgLP_JSON) : Object.toJSON(orgLP_JSON);
	}
	if(CSRUtil._is_LPJSON_at_top_worked){
		top.LP_JSON = newLP_JSON;
	}else if(newLP_JSON){
		window.sessionStorage.setItem('LP_JSON' , newLP_JSON );
	}else{
		window.sessionStorage.removeItem('LP_JSON');
	}

	submitOnce(LP_JSON_input);

};

/**
 *	@public
 *	@class 依 action 指定回上頁, 若未指定 action, 則以記錄的 LP_JSON 中的 RQ_SENDER 回送。 <br>
 *	       當指定 backAction 為 9 碼之作業名稱時，則會將所記錄之 LP_JSON 依序由最後一個往前搜尋符合之 action，並清除過程中不符合之記錄。 <br>
 *	       Ex :
 *	            // 連結至指定作業，當無該作業時，自行連結至該畫面
 *	            CSRUtil.linkBack('XXA0_0100',{
 *	                'mappingOnError':function(){
 *	                    var LP_JSON = {
 *	                        action :'<%=dispatcher%>/XXA0_0100/prompt'
 *	                    };
 *	                    CSRUtil.linkTo(LP_JSON , 'form1');
 *	                }
 *	            });
 *
 *	@param backAction [optional]
 *	@param cbFuncOptions(Map) :
 *	       cbFuncOptions.mappingOnError (Function) : 當指定作業名稱時，無該記錄之 call back function
 *	       cbFuncOptions.backOnError (Function) : 當執行時，無該記錄之 call back function
 *	       cbFuncOptions.isSubmitParameters (Boolean) : 若欲將之前保留之條件作為參數傳遞時，指定 true，預設為 false
 *
 **/
CSRUtil.linkBack = function(backAction, cbFuncOptions){

	var cbFuncOptions = Object.prototype.toString.call(cbFuncOptions) == '[object Object]' ? cbFuncOptions : {};
	var backOnError = Object.prototype.toString.call(cbFuncOptions['backOnError']) == '[object Function]' ? cbFuncOptions['backOnError'] : null;
	var mappingOnError = Object.prototype.toString.call(cbFuncOptions['mappingOnError']) == '[object Function]' ? cbFuncOptions['mappingOnError'] : null;
	var isSubmitParameters = cbFuncOptions['isSubmitParameters']===true;
	
	var RQ_SENDER;
	var BQ_ARG;
	
	if( backAction && ( Object.prototype.toString.call(backAction) != '[object String]' || backAction.length!=9)){
		window.console && console.log('[CSRUtil][linkBack] backAction data is incorrect: ' + backAction)
		RQ_SENDER = backAction;
	}else{
		if(!backAction){
			var LP_JSON = CSRUtil.getLP_JSON();
			RQ_SENDER = LP_JSON.RQ_SENDER;
			BQ_ARG = LP_JSON.BQ_ARG;
			
		}else{
			var LP_JSON = CSRUtil._is_LPJSON_at_top_worked ? top.LP_JSON : sessionStorage.getItem('LP_JSON');
			
			if(LP_JSON){
				if(Object.prototype.toString.call(LP_JSON) == '[object String]'){
					LP_JSON = window.JSON && JSON.parse ? JSON.parse(LP_JSON) : LP_JSON.evalJSON();
				}
				if(Object.prototype.toString.call(LP_JSON) == '[object Array]'){
					while(LP_JSON){
						var testObj = LP_JSON[LP_JSON.length -1 ];
						if(testObj && testObj.RQ_SENDER.indexOf(backAction)>0){
							RQ_SENDER = testObj.RQ_SENDER;
							BQ_ARG = testObj.BQ_ARG;
							break;
						}
						LP_JSON.pop();
						if(!LP_JSON.length){
							LP_JSON = undefined;
						}
					}
				}else{
					if(LP_JSON && LP_JSON.RQ_SENDER.indexOf(backAction)>0){
						RQ_SENDER = LP_JSON.RQ_SENDER;
						BQ_ARG = LP_JSON.BQ_ARG;
					}else{
						LP_JSON = undefined;
					}
				}
			}
			if(!RQ_SENDER){
				if(mappingOnError){
					mappingOnError();
					return;
				}
				alert('無指定之功能，故無法執行');
				return;
			}

			var newLP_JSON = LP_JSON ? ( window.JSON && JSON.stringify ? JSON.stringify(LP_JSON) : Object.toJSON(LP_JSON) ) : undefined;
			if(CSRUtil._is_LPJSON_at_top_worked){
				top.LP_JSON = newLP_JSON;
			}else if(newLP_JSON){
				window.sessionStorage.setItem('LP_JSON' , newLP_JSON );
			}else{
				window.sessionStorage.removeItem('LP_JSON');
			}
		}
	}

	if(!RQ_SENDER){
		if(backOnError){
			backOnError();
			return;
		}
		alert('無已記錄的 URL，故無法執行');
		return;
	}
	
	var linkForm = document.createElement('form'); 
	linkForm.setAttribute('method','post');
	linkForm.setAttribute('action',RQ_SENDER);
	linkForm.style.display = 'none';
	
	if( isSubmitParameters  && Object.prototype.toString.call(BQ_ARG) == '[object Object]'){
		for(var k in BQ_ARG){
			var param_input = document.createElement('input');
			param_input.setAttribute('type','hidden');
			param_input.setAttribute('name',k);
			param_input.value = BQ_ARG[k];
			linkForm.appendChild(param_input);
		}
	}
	document.body.appendChild(linkForm);
	submitOnce(linkForm);
};
/**
 *	@public
 *	@class 取得最後一個 LP_JSON，若 remove 參數給 true, 且取得的 LP_JSON 的 RQ_SENDER 和目前頁面的 URL 一致，則刪除該 LP_JSON。
 *	@param remove(true/false) [optional]
 *
 **/
CSRUtil.getLP_JSON = function(remove){
	try{
		var LP_JSON = CSRUtil._is_LPJSON_at_top_worked ? top.LP_JSON : window.sessionStorage.LP_JSON;
		if(!LP_JSON){
			return {};
		}
		if(Object.prototype.toString.call(LP_JSON) == '[object String]'){
			if(window.JSON && JSON.stringify){
				LP_JSON =  JSON.parse(LP_JSON);
			}else if(Object.prototype.toString.call(LP_JSON.evalJSON) == '[object Function]'){
				LP_JSON =  LP_JSON.evalJSON();
			}else{
				window.console && console.log('[CSRUtil][getLP_JSON] can not parse JSON string');
				return {};
			}
		}
		var jsonBack;
		var newLP_JSON = undefined;
		if(Object.prototype.toString.call(LP_JSON) == '[object Array]'){
			if(LP_JSON.length <= 0){
				return {};
			}
			jsonBack = LP_JSON[LP_JSON.length - 1];
			if(remove && jsonBack.RQ_SENDER == window.location.pathname){
				LP_JSON.pop();
				newLP_JSON = LP_JSON.length > 0 ? LP_JSON : undefined;
			}
			
		}else{
			jsonBack = LP_JSON;
			if(remove && jsonBack.RQ_SENDER == window.location.pathname ){
				newLP_JSON = undefined;
			}
		}
		
		if(remove){
			newLP_JSON = newLP_JSON ? ( window.JSON && JSON.stringify ? JSON.stringify(newLP_JSON) : Object.toJSON(newLP_JSON)) : undefined;
			if(CSRUtil._is_LPJSON_at_top_worked){
				top.LP_JSON = newLP_JSON;
			}else if(newLP_JSON){
				window.sessionStorage.setItem('LP_JSON' , newLP_JSON );
			}else{
				window.sessionStorage.removeItem('LP_JSON');
			}
		}
		return jsonBack;
	}catch(e){
		window.console && console.log('[CSRUtil][getLP_JSON] Exception : '+ e);
		return {};
	}
};
/**
 *	@public
 *	@class 是否為回上頁的來的，若是的話，會嚐試將 BQ_ARG 值轉到指定的 form 中，若有指定 backFunc, 則在設定完 form 的值後，還去執行該 function
 *	@param formID 指定由 BQ_ARG 還原參數所該填入的 form [option]
 *	@param backFunc 若是回上頁來的，有指定 backFunc 的話，在還原參數後會執行此 function
 *
 **/
CSRUtil.isBackLink = function(formID, backFunc){

	var	LP_JSON = CSRUtil.getLP_JSON();

	if(!LP_JSON){
		return false;
	}

	if(LP_JSON.RQ_SENDER == window.location.pathname){
		
		// 刪除已記憶的
		LP_JSON = CSRUtil.getLP_JSON(true);

		var BQ_ARG = LP_JSON.BQ_ARG || {};

		if(formID){
			CSRUtil.voToInputs(formID, BQ_ARG);
		}

		if(backFunc && Object.isFunction(backFunc)){
			backFunc(BQ_ARG);
		}

		return LP_JSON;

	}

	return false;

};

/**
 *  @public
 *  @class 清除所有的 LP_JSON 記錄
 *  @version 1.00
 **/
CSRUtil.clearLP_JSON = function(){
	try{
		top.LP_JSON = undefined;
	}catch(e){
		window.console && console.log('[CSRUtil][getLP_JSON] cant not clear LP_JSON from top : '+e);
	}
	if(window.sessionStorage){
		try{
			window.sessionStorage.removeItem('LP_JSON')
		}catch(e){
			window.console && console.log('[CSRUtil][getLP_JSON] cant not clear LP_JSON from sessionStorage : '+e);
		}	
	}
};

/**
 *  @public
 *  @class 保留參數管理
 *  @author 劉本傑
 *  @version 1.00
 **/
CSRUtil.keepParamsManager = {
	/**
	 *  @private
	 *  @class 於 TOP 保留參數使用之鍵值
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	keepKey:'CSRUtil.keepParamsManager.params',
	/**
	 *  @public
	 *  @class 清除所有參數
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	clear:function(){
		if(CSRUtil._is_LPJSON_at_top_worked){
			top[CSRUtil.keepParamsManager.keepKey]=undefined;
		}else{
			window.sessionStorage.removeItem(CSRUtil.keepParamsManager.keepKey);
		}
	},
	/**
	 *  @public
	 *  @class 初始
	 *  @param inParams (Map) : 參數及對應值
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	initial:function(inParams){
		if(CSRUtil._is_LPJSON_at_top_worked){
			top[CSRUtil.keepParamsManager.keepKey]=inParams;
		}else{
			window.sessionStorage.setItem(CSRUtil.keepParamsManager.keepKey , JSON.stringify(inParams) );
		}
	},
	/**
	 *  @public
	 *  @class 置入參數
	 *  @param inParams (Map) : 參數及對應值
	 *  @param overWrite (boolean) : 是否覆寫同參數所對應之值（預設為 true）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	put:function(inParams, overWrite){
		var keepKey = CSRUtil.keepParamsManager.keepKey;
		var params = CSRUtil.keepParamsManager.getAll();
		if(Object.isUndefined(params)||params==null){
			params = {};
		}

		overWrite = overWrite!==false;
		for(var inKey in inParams){
			var valueFromParams = params[inKey];
			if(overWrite || Object.isUndefined(valueFromParams)|| valueFromParams==null){
				params[inKey]=inParams[inKey];
			}
		}
		
		CSRUtil.keepParamsManager.initial(params);
	},
	/**
	 *  @public
	 *  @class 取得所有參數
	 *  @return inParams (Map) : 參數及對應值
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getAll:function(){
		if(CSRUtil._is_LPJSON_at_top_worked){
			return top[CSRUtil.keepParamsManager.keepKey];
		}else{
			var params = window.sessionStorage.getItem(CSRUtil.keepParamsManager.keepKey);
			if(params){ 
				return JSON.parse(params);
			}
		}
	},
	/**
	 *  @public
	 *  @class 取得參數所對應的值，若無任何參數時，回傳空白
	 *  @param key (String) : 參數名稱
	 *  @return String
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	get:function(key){
		var params = CSRUtil.keepParamsManager.getAll();
		if(Object.isUndefined(params)||params==null){
			return '';
		}
		var valueFormParams = params[key];
		if(Object.isUndefined(valueFormParams)||valueFormParams==null){
			return '';
		}
		return valueFormParams;
	},
	/**
	 *  @public
	 *  @class 將所保留參數設定至畫面（不存在時則建立 input[type=hidden]）
	 *  @param formId (String) : Form ID
	 *  @param setKeys (String/Array) : 設定鍵值，未傳入該參數時，表示全部設定
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	setPageValue:function(formId, setKeys){
		var frm = $(formId);
		var params = CSRUtil.keepParamsManager.getAll();
		var executeSetValue = function(key){
			var obj = $(key);
			if(obj){
				obj.value=params[key];
			}else{
				frm.insert(new Element('input', {
					'type':'hidden',
					'id':key,
					'name':key,
					'value':params[key]
				}));
			}
		};
		if(Object.isUndefined(setKeys)){
			for(var key in params){
				executeSetValue(key);
			}
		}if(Object.isArray(setKeys)){
			for(var i=0;i<setKeys.length;i++){
				executeSetValue(setKeys[i]);
			}
		}else{
			executeSetValue(setKeys);
		}
	}
};

/**
 *  @public
 *  @class mask tool
 *  @author 劉本傑
 *  @version 1.00
 **/
CSRUtil.maskHandler = {
	/**
	 *  @private
	 *  @class 於 TOP 保留參數使用之鍵值
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	maskSign: '*',
	/**
	 *  @public
	 *  @class 遮蔽字串
	 *         Ex : CSRUtil.maskHandler.getMaskStr('1234567890', 2, false, '*')             return 12********
	 *              CSRUtil.maskHandler.getMaskStr('1234567890', 3, 2, '#')                 return 123##67890
	 *              CSRUtil.maskHandler.getMaskStr('123', 3, false, '*')                     return 123
	 *  @param str (String) : 字串
	 *  @param beginIndex (int) : 遮蔽啟始位置（由 0 開始計算）
	 *  @param maskLength (int) : 遮蔽長度（由遮蔽啟始位置開始計算）
	 *  @param inSign (String) : 遮蔽符號（預設為 *）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getMaskStr:function(str, beginIndex, maskLength, inSign){

		if(!str){
			return str;
		}

		var strLength = str.length;
		if(typeof strLength === "undefined"){
			str = str.toString(10)
		}
		if(beginIndex>strLength || maskLength===0){
			return str;
		}

		var endIndex = (!maskLength)?0:beginIndex+maskLength;
		var sign = inSign || CSRUtil.maskHandler.maskSign;

		if(!endIndex || (endIndex>0 && endIndex>strLength)){
			var tempStr = str.substr(0, beginIndex);
			while(tempStr.length<strLength){
				tempStr += sign;
			}
			return tempStr;
		}

		var tempStr = str.substr(0, beginIndex);
		for(var i=0;i<maskLength;i++){
			tempStr += sign;
		}
		tempStr += str.substr(endIndex);;
		return tempStr;

	},
	/**
	 *  @public
	 *  @class 遮蔽身分證字號
	 *         Ex : CSRUtil.maskHandler.getMaskID('X123456789')                             return X123***789
	 *              CSRUtil.maskHandler.getMaskID('X123456789', 5)                          return X12*****89
	 *              CSRUtil.maskHandler.getMaskID('X1234')                                  return X***4
	 *              CSRUtil.maskHandler.getMaskID('X123')                                   return X***
	 *              CSRUtil.maskHandler.getMaskID('X1')                                     return ***
	 *              CSRUtil.maskHandler.getMaskID('')                                       return ***
	 *              CSRUtil.maskHandler.getMaskID(undefined)                                return ***
	 *  @param str (String) : 字串
	 *  @param maskLength (int) : 遮蔽中間 n 碼（預設為 3 碼）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getMaskID:function(str, maskLength){

		maskLength = isNaN(maskLength)?3:maskLength
		var strLen = !str?0:str.length;

		if(strLen<=maskLength){
			var rtnStr = '';
			for(var i=0;i<maskLength;i++){
				rtnStr+=CSRUtil.maskHandler.maskSign;
			}
			return rtnStr;
		}

		var diffLen = strLen - maskLength;
		var hasAdd1 = diffLen%2!==0;
		if(hasAdd1){
			diffLen--;
		}

		var last = diffLen==0?0:diffLen/2;
		var firstIndex = hasAdd1 ? last+1 : last;

		return CSRUtil.maskHandler.getMaskStr(str, firstIndex, maskLength);
	},
	/**
	 *  @public
	 *  @class 遮蔽姓名（遮蔽由右向左第 2 個字）
	 *         Ex : CSRUtil.maskHandler.getMaskName('程設科')                               return 程＊科
	 *              CSRUtil.maskHandler.getMaskName('程設科', '◎')                         return 程◎科
	 *              CSRUtil.maskHandler.getMaskName('投資程設科')                           return 投＊程設科
	 *  @param str (String) : 字串
	 *  @param inSign (String) : 遮蔽符號（預設為＊）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getMaskName:function(str, inSign){
		var sign = inSign || '＊';
		return CSRUtil.maskHandler.getMaskStr(str,1,1,sign);
	},
	/**
	 *  @public
	 *  @class 遮蔽地址（遮蔽第 3 碼之後的字）
	 *         Ex : CSRUtil.maskHandler.getMaskAddress('台北市內湖區陽光街２８８號')        return 台北市＊＊＊＊＊＊＊＊＊＊
	 *              CSRUtil.maskHandler.getMaskAddress('台北市內湖區陽光街２８８號', '◎')  return 台北市◎◎◎◎◎◎◎◎◎◎
	 *              CSRUtil.maskHandler.getMaskAddress('台北市')                            return 台北市
	 *  @param str (String) : 字串
	 *  @param inSign (String) : 遮蔽符號（預設為＊）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getMaskAddress:function(str, inSign){
		var sign = inSign || '＊';
		return CSRUtil.maskHandler.getMaskStr(str,3, false, sign);
	},
	/**
	 *  @public
	 *  @class 遮蔽地址
	 *         若所傳入之地址長度超過 20 碼時，則保留前 20 碼之文字。
	 *         若所傳入之地址長度超過 10 碼時，則保留前 10 碼之文字。
	 *         若所傳入之地址長度低於或等於 10 碼時，則不進行遮蔽。
	 *         Ex : CSRUtil.maskHandler.getMaskAddress2('台北市內湖區陽光街２８８號８樓')   return 台北市內湖區陽光街２＊＊＊＊＊
	 *              CSRUtil.maskHandler.getMaskAddress2('台北市內湖區陽光街２８８號', '◎') return 台北市內湖區陽光街２◎◎◎
	 *              CSRUtil.maskHandler.getMaskAddress2('台北市內湖區陽光街')               return 台北市內湖區陽光街
	 *  @param str (String) : 字串
	 *  @param inSign (String) : 遮蔽符號（預設為＊）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	getMaskAddress2:function(str, inSign){
		if(!str){
			return str;
		}
		var sign = inSign || '＊';
		var strLength = str.length;
		if (strLength > 20) {
			return CSRUtil.maskHandler.getMaskStr(str,20, false, sign);
		}
		if (strLength > 10) {
			return CSRUtil.maskHandler.getMaskStr(str,10, false, sign);
		}
		return str;
	}
};

/**
 *  @public
 *  @class set some default var for UI lib usage
 **/
CSRUtil.UICore={
	webBase:'',
	imageBase:'',
	/**
	 *  @public
	 *  @class 判斷目前所在之子系統是否為指定之子系統
	 *         Ex :
	 *             若此時在子系統「LA」
	 *                 CSRUtil.UICore.isOnTheSys(['L.', 'R.'])                              return true
	 *             若此時在子系統「RZ」
	 *                 CSRUtil.UICore.isOnTheSys('R.*')                                     return true
	 *             若此時在子系統「AB」
	 *                 CSRUtil.UICore.isOnTheSys(['AA', 'B.'])                              return false
	 *  @param str (String) : 字串
	 *  @param inSign (String) : 遮蔽符號（預設為＊）
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	isOnTheSys: function(sysId){

		//know whick webcontext the page is existed
		var wls = window.location.toString();

		var judgeOnSys = function(inSysId){
			var patternString = '\/'+inSysId+'Web*';
			var regex = new RegExp(patternString);
			return regex.test(wls);
		};
		var checkOnSys = false;
		if(Object.prototype.toString.call(sysId) === '[object Array]'){
			for(var i=0;i<sysId.length;i++){
				checkOnSys = judgeOnSys(sysId[i]);
				if(checkOnSys){
					break;
				}
			}
		}else{
			checkOnSys = judgeOnSys(sysId);
		}
		return checkOnSys;

	},
	setup: function(){
		var prototypeJS = /prototype\.js(\?.*)?$/;
		var utilityJS = /utility\.js(\?.*)?$/;

		var includeScripts = document.getElementsByTagName('script');

		//set up the images base by web path
		if(includeScripts.length>0){
			for(var i=0;i<includeScripts.length;i++){
				var scriptSrc = includeScripts[i].src;
				if(!scriptSrc.match(prototypeJS) && !scriptSrc.match(utilityJS)){
					continue;
				}
				var splitWords = scriptSrc.split('/');
				for(var i=0;i<splitWords.length;i++){
					var sw=splitWords[i];
					if(sw.indexOf('Web')>0){
						CSRUtil.UICore.webBase = '/' + sw;
						break;
					}
				}
				break;
			}
		}

		//set up the images base by css path
		var includeCSSs = document.getElementsByTagName('link');
		if(includeCSSs.length > 0){
			for(var i=0;i<includeCSSs.length;i++){
				var includeCSS = includeCSSs[i];
				if(includeCSS.type!='text/css'){
					continue;
				}
				var cssHref = includeCSS.href;
				var cssHrefIndex = cssHref.indexOf('html');
				CSRUtil.UICore.imageBase = cssHref.substring(0, cssHrefIndex) + 'images';
				break;
			}
		}

	}
};

CSRUtil.UICore.setup();

if(CSRUtil.hasInclude_Prototype()){
	/*
	Add simulate method to $() let Element can fire native event
	*/
	Element.addMethods({
		simulate: function(element, event) {
			
			// dispatch for firefox , others , IE 9+
			if(document.createEvent){
				var e = document.createEvent('HTMLEvents');
				e.initEvent(event, true, true ); // event type, bubbling, cancelable
				return !element.dispatchEvent(e);
			}

			// dispatch for IE 8-
			var e = document.createEventObject();
			return element.fireEvent('on' + event, e);
		}
	});
}

/*
register default request/response handler for submit once ui control
*/
(function(){
	if(CSRUtil.hasInclude_Prototype()){
		Ajax.Responders.register({
			onCreate: function(request){
				if(!Object.isUndefined(request.options)
				   && !Object.isUndefined(request.options.onSuccess)
				   && Object.isFunction(request.options.onSuccess)){
					var myFunc = request.options.onSuccess;
					request.options.onSuccess = myFunc.wrap(
						function(proceed, response){
							proceed(response, response.responseJSON);
						}
					);
				}
			}
		});
		Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
	}
})();