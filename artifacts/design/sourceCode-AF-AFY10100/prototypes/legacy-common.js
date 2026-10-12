var CSRUtil = {}; CSRUtil.hasInclude_Prototype = function(){return typeof window.Prototype!=='undefined';};
CSRUtil.hasInclude_jQuery=function(){return typeof window.jQuery!=='undefined';};
CSRUtil.getReturnMessage=function(resp){if(resp)return resp.ErrMsg;};
CSRUtil.isSuccess=function(resp){var m=CSRUtil.getReturnMessage(resp);return !!m && m.returnCode==0;};
CSRUtil.isOnProgress=function(xhr){return xhr.readyState!=4;};
CSRUtil.UICore={imageBase:'',isOnTheSys:function(patterns){var locationText='/'+(new URLSearchParams(location.search).get('subsystem')||'AF')+'Web/';if(!Array.isArray(patterns))patterns=[patterns];return patterns.some(function(x){return new RegExp('\\/'+x+'Web*').test(locationText);});}};
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
			cover.setAttribute('id', inputId); cover.className='common-cover';
			
			
			cover.style.position=canUsePositionStyle_fixed?'fixed':'absolute';
			
			
			
			
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
				/* TODO-02: loading image unavailable, keep geometry. */

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
			/* TODO-02: background PNG unavailable. */
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
		win.addClassName('common-style-1').setStyle({'width': minWidth+'px',});

		btn = new Element('input', {'type':'button', 'value':'確定'}).addClassName('button common-confirm').observe('click', function(event){
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
		titleDiv.addClassName('common-style-2');
		titleDiv.innerHTML = '網頁訊息';

		contentDiv = new Element('div', {'align':'left', 'id':'msg-win_content'});
		contentDiv.addClassName('common-style-3');

		bottomDiv = new Element('div');
		bottomDiv.addClassName('common-style-4');
		bottomDiv.insert(btn);

		win.insert(titleDiv);
		win.insert(contentDiv);
		win.insert(bottomDiv);

		dragDiv = new Element('div');
		dragDiv.addClassName('common-style-5');

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