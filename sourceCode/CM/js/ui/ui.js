String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,"");
};

var uiJs = new function(){

	var UICorePrivate = {
		webBase:'',
		imageBase:'',
		/**
		 *  @private
		 *  @class §PÂ_¥Ø«e©Ò¦b¤§¤l¨t²Î¬O§_¬°«ü©w¤§¤l¨t²Î
		 *  @param str (String) : ¦r¦ê
		 *  @param inSign (String) : ¾B½ª²Å¸¹¡]¹w³]¬°¡¯¡^
		 *  @author ¼B¥»³Ç
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
			if(Object.isArray(sysId)){
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
			var js = /prototype\.js(\?.*)?$/;
		    $$('head script[src]').findAll(function(s){
		      return s.src.match(js);
		    }).each(function(s) {
		      var eles = s.src.split('/');
			      eles.each(function(ele){
			      	 if(ele.include('Web')){
			      		UICorePrivate.webBase = '/' + ele;
			      	 }
			      });
		    });

		    //set up the images base by css path
		    var css = $$('head link[href$=css]');
		    if(css.length > 0){
		    	var cssHref = css[0].href;
				var i = cssHref.indexOf('html');
				UICorePrivate.imageBase = cssHref.substring(0, i) + 'images';
		    }
		}
	};
	UICorePrivate.setup();

	var createCoverPage = function(inputId){

		var docBody = document.body;
		var cover = $(inputId);

		if(!cover){

			var coverStyle = {
				'width': '100%',
				'height': '100%',
				'position': 'absolute',
				'left': 0,
				'top': 0,
				'cursor': 'progress',
				'posLeft': 0,
				'posTop': 0,
				'margin': '0 auto',
				'zIndex': 150
			};

			var uiCoverPageBgPng = UICorePrivate.imageBase+'/CM/ui/CSRUtil.coverPage.bg.png';

			if(window.XMLHttpRequest){
				coverStyle['background']='url('+uiCoverPageBgPng+')';
			}else { // png supported by IE6
			    coverStyle['filter']='progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale,src='+uiCoverPageBgPng+')';
			}

			cover = new Element('div', {id:inputId}).setStyle(coverStyle).insert(
				new Element('div').setStyle({
					'width': '100%',
					'height': '100%',
					'position': 'absolute',
					'left': 0,
					'top': 0,
					'background': 'no-repeat center center url('+UICorePrivate.imageBase+'/CM/ui/CSRUtil.loading.gif)'
				})
			);

			cover.resizeCoverPage = function(){
				if(docBody.scrollWidth>docBody.clientWidth || docBody.scrollHeight>docBody.clientHeight){
					cover.setStyle({
						width: (docBody.scrollWidth/docBody.clientWidth * 100)+'%',
						height: (docBody.scrollHeight/docBody.clientHeight * 100)+'%'
					});
				}
			};

			docBody.appendChild(cover);

		}

		cover.resizeCoverPage();

		var ae = document.activeElement;

		if( !Object.isUndefined(ae) && ae.type =='button') {
			window.focus();
		}

		cover.hide();

		return cover;

	};

	var isOnProgress = function(xmlhttp){
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

	var getReturnMessage = function (resp){
		return resp['ErrMsg'];
	};

	return {
		defaultAjaxHandler:{

				onCreate: function (request){

					// ¦b¨C¦¸ Ajax request ½Ð¨D«Ø¥ß®É¡A¶i¦æµù¥U¤@¦¸°Ê§@
					msgWin.registerActive();

					var cover = Object.isFunction(createCoverPage) && createCoverPage('_frontCover');
					if(cover){
						cover.show();
					}

					if(!Object.isUndefined(request.options) && !Object.isUndefined(request.options.timeout)){
						//«Ø¥ß timeout ªº³B²z±±¨î
						var waitTime = request.options.timeout * 1000;
						request.timeoutId = window.setTimeout(
							function(){
								if(isOnProgress(request.transport)){

									//cancel the readystatechange listener, to avoid call onSuccess function
									request.transport.onreadystatechange = Prototype.emptyFunction;
									request.transport.abort();

									if(Object.isFunction(request.options.onTimeout)){
										Ajax.Responders.dispatch('onTimeout', request);
										request.options.onTimeout();
									}else{
										alert('¦bµ¥«Ý ' + request.options.timeout + ' ¬í«á¦øªA¾¹¤´¥¼¦^À³¡A½Ðµy«á¦A½T»{¥æ©ö°õ¦æªºµ²ªG¡C');
									}
									Ajax.Responders.dispatch('onComplete', request);
								}
							}, waitTime
						);
					}

				},
				onComplete: function (request, transport){

					// ¦b¨C¦¸ Ajax request ½Ð¨D§¹¦¨®É¡A¶i¦æµù¾P¤@¦¸°Ê§@
					msgWin.unregisterActive();

					$('_frontCover').resizeCoverPage();

					//­Y¦³«ü©w timeout¡A²M°£ timeout ªº±±¨î
					if(!Object.isUndefined(request.timeoutId)){
						window.clearTimeout(request.timeoutId);
					}

					var resp = transport.responseJSON;

					var errMsg = getReturnMessage(resp);

					if(!errMsg){
						if(Ajax.activeRequestCount == 0){
							// ·í«áÄò¥¼¦³¥ô¦ó Ajax request ½Ð¨D®É¡A«h±N cover page ÁôÂÃ
							if(!msgWin.isActive()){
								$('_frontCover').hide();
							}
						}
						return;
					}

					var msgArray = $A(errMsg.displayMsgDescs.split('\\n'));
					var str = '';
					msgArray.each(function(s){
						str += s + '\n';
					});

					var msgBoard = getMsgBoard();
					if(msgBoard){
						var color= (errMsg.returnCode==0)?"blue":"red";
						var htmlMessage = "<font color='blue'>°T®§¡G</font><font color='" + color + "'>" + str.replace(/\\n/g,"<br>") + "</font>";
						try{
							var showNotifyMsgFunc;
							if(msgBoard.contentWindow){
								showNotifyMsgFunc = msgBoard.contentWindow.showNotifyMsg;
							}else{
								showNotifyMsgFunc = msgBoard.showNotifyMsg;
							}
							if(typeof showNotifyMsgFunc==='function'){
								showNotifyMsgFunc({
									'returnCode': errMsg.returnCode,
									'returnMessage': htmlMessage
								});
							}else{
								msgBoard.innerHTML=htmlMessage;
							}
						}catch(err){
						}
					}

					var msgid = errMsg.msgid;
					var isError = errMsg.returnCode != 0;

					if(UICorePrivate.isOnTheSys(['L.', 'R.', 'J.', 'DS', 'DZ', 'QB', 'AN'])){

						var alertMessage = "";
						if(isError && msgid!='' && msgid.length>17){
							alertMessage += '¿ù»~½s¸¹¡G\n'+msgid;
							alertMessage +='\n';
							alertMessage +='°T®§»¡©ú¡G\n';
						}
						alertMessage +=str;

						//§ëºÞ­×¥¿¡A¿ù»~©Î¥¢±ÑmÅã¥Ü¤Î alert °T®§
						if(str.trim() != ''){
							msgWin.show(alertMessage);
						}else if(isError){
							//µL°T®§¡A¶È¦³¿ù»~¦^¶Ç½Xªº¸Ü¡Aalert ¥XÄµ§i
							msgWin.show(alertMessage);
						}else{
							// ·í«áÄò¥¼¦³¥ô¦ó Ajax request ½Ð¨D®É¡A«h±N cover page ÁôÂÃ
							if(!msgWin.isActive()){
								$('_frontCover').hide();
							}
						}

					}else{

						// ·í«áÄò¥¼¦³¥ô¦ó Ajax request ½Ð¨D®É¡A«h±N cover page ÁôÂÃ
						if(!msgWin.isActive()){
							$('_frontCover').hide();
						}

						var alertMessage = "";
						if(isError){

							if(msgid!='' && msgid.length>17){
								alertMessage += '¿ù»~½s¸¹¡G\n'+msgid;
								alertMessage +='\n';
							}

							alertMessage +='°T®§»¡©ú¡G\n'+str;
							alert(alertMessage);

						// ­YreturnCode == 0 ¥B°T®§¤£¬°ªÅ¥Õ¦r¦ê¡A¦Ó¤U¤èµL°T®§¦C®É¡A«hÅã¥Ü°T®§
						} else if(str.trim() != '' && !msgBoard){
							alertMessage +='°T®§»¡©ú¡G\n'+str;
							alert(alertMessage);
						}

					}

				},
				//script °õ¦æ¦³»~®Éªº¿ù»~³B²z
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
	};

};

//­Y­¶­±¨S¦³µù¥U¹LMsgWinÃþ§O¡A¦b¦¹²£¥Í¡C  ¤@¯ë¨Ó»¡¸Ó¤èªk·|¦bCSRUtils.js¤¤²£¥Í
if(Object.isUndefined(window.MsgWin)){
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
			actives.clear();
			win = new Element('div', {'align':'center', 'id':'msg-win'});
			win.setStyle({
				'fontFamily': 'Verdana, Arial, sans-serif, ·L³n¥¿¶ÂÅé',
				'fontSize':'10pt',
				'border':'solid 1px #000',
				'position': 'absolute',
				'padding':'0 5px 5px 5px',
				'backgroundColor': '#0066CC',
				'width': minWidth+'px',
				'zIndex':999,
				'filter': 'alpa(opacity=95)',	// old IE
				'filter': 'progid:DXImageTransform.Microsoft.Alpha(Opacity=95,FinishOpacity=15, Style=3, StartX=0, FinishX=100, StartY=0,FinishY=16)', // supported by current IE
				'-moz-opacity': '0.95',			// Moz + FF
				'opacity': '0.95'				// ¤ä«ù·sª©ÂsÄý¾¹
			});

			btn = new Element('input', {'type':'button', 'value':'½T©w'}).addClassName('button').setStyle({
				'padding': '0 15px 0 15px'
			}).observe('click', function(event){
				document.body.style.overflow="";
				win.remove();
				msgWin.unregisterActive();
				// ·í«áÄò¥¼¦³¥ô¦ó Ajax request ½Ð¨D®É¡A«h±N cover page ÁôÂÃ
				if(!msgWin.isActive()){
					var cover = $('_frontCover');
					cover && cover.hide();
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
			titleDiv.innerHTML = 'ºô­¶°T®§';

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

			dragDiv.setStyle({
				'width':win.getWidth(),
				'height':win.getHeight(),
				'left':pos.left,
				'top':pos.top
			});

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
				top:pos.top,
				left:pos.left
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

				document.body.style.overflow = "hidden";

				var splitSign = '<br/>';
				msg = msg.replace(/\\n|\n/g, splitSign);
				addDisplayMsg(msg);

				var cover = $('_frontCover');
				cover && cover.show();

				var x = msg.length * 15;
				if(contentDiv.innerText==''){
					document.body.appendChild(win);
					actives.push(true);
					contentDiv.update(msg);

					document.observe('keypress', function(e){
						// ­Y«ö¤U Enter¡BEsc¡BªÅ¥ÕÁä®É¡A«hÄ²µo°T®§¤º½T©wªº click event
						if(e.keyCode == Event.KEY_RETURN || e.keyCode == Event.KEY_ESC || e.keyCode == 32) {
							btn.click();
							Event.stop(e);
							document.stopObserving('keypress');
						}
					});

					if(x > maxWidth){
						win.setStyle({'width':maxWidth + 'px'});
						contentDiv.setStyle({'width':maxWidth-contentDivSubtractWidth + 'px'});
					}else if(x > minWidth){
						win.setStyle({'width': x + 'px'});
						contentDiv.setStyle({'width':x-contentDivSubtractWidth + 'px'});
					}else{
						win.setStyle({'width': minWidth+'px'});
						contentDiv.setStyle({'width':minWidth-contentDivSubtractWidth + 'px'});
					}

				}else{

					var contentDivWidth = contentDiv.getWidth();
					if(contentDivWidth < maxWidth-contentDivSubtractWidth && contentDivWidth < x){
						if(x > maxWidth){
							win.setStyle({'width':maxWidth + 'px'});
							contentDiv.setStyle({'width':maxWidth-contentDivSubtractWidth + 'px'});
						}else if(x > minWidth){
							win.setStyle({'width': x + 'px'});
							contentDiv.setStyle({'width':x-contentDivSubtractWidth + 'px'});
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
					'top': (document.body.clientHeight/4)+scrollOffsets['top'],
					'left': (document.body.clientWidth-win.getWidth())/2+scrollOffsets['left']
				});

				btn.focus();
				win.remove();
				document.body.appendChild(win);

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
}

//­Y­¶­±¨S¦³µù¥U¹LmsgWinÅÜ¼Æ¡A¦b¦¹²£¥Í¡C
if(Object.isUndefined(window.msgWin)){
	var msgWin = new MsgWin();
}

//register default request/response handler for submit once ui control
(function(){
	// ­Y¥¼¤Þ¥Î CSRUtil.js «h¥Ñ ui.js ¦Û¦æ¶i¦æ Ajax.Responders.register
	if(Object.isUndefined(window.CSRUtil)){
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
		Ajax.Responders.register(uiJs.defaultAjaxHandler);
	}

})();

function CONST() {

}

CONST.LINK_TYPE_COMM = 'COMM'; // ¤@¯ëªº
CONST.LINK_TYPE_LIST = 'Q'; // ²M³æ
CONST.LINK_TYPE_OPEN = 'OPEN'; // ¶}µ¡
CONST.LINK_TYPE_EXAMINE = 'EXAMINE'; // ¼f§å


function Util() {};

Util.getBodyObj = function() {
	return  (document.documentElement) ? document.documentElement : document.body;
};

Util.isBlank = function(val) {
	 return  (!val) ? true : false;
};

Util.isNotBlank = function(val) {
	 return  (val) ? true : false;
};

Util.removeChildrenElements = function(target) {
	var children = target.childElements()
	children.each(
		function(child){
			child.remove();
		}
	);
};

Util.unigue = function() {
 	var g = "{";
    for(var i = 0; i < 32; i++) {
    	g += Math.floor(Math.random() * 0xF).toString(0xF) + (i == 8 || i == 12 || i == 16 || i == 20 ? "-" : "")
    }
    return g + "}";
};

Util.createElement = function(tag,attributes) {

	var tag = document.createElement(tag);

	if (attributes != null) {

		for (var i=0;i<attributes.length;i++) {
			var attribute = attributes[i].split('=');
			tag.setAttribute(attribute[0], attribute[1]);
		}

	}

	return tag;
};


Util.getRadioValue = function(name) {
	var array = document.getElementsByName(name);
	for (var i=0;i<array.length;i++) {
		 if (array[i].checked == true) {
			return array[i].value;
		 }
	}
	return null;
};

Util.getArrayMaxValue = function(array) {
	var max = 0;
	for (var i=0;i<array.length;i++) {
		 if (array[i] * 1 >= max) {
			max =  array[i];
		 }
	}
	return max;
};


Util.getCheckCount = function(name) {

	var count = 0;
	var array = document.getElementsByName(name);
	for (var i=0;i<array.length;i++) {
		 if (array[i].checked == true) {
			 count++;
		 }
	}

	return count;
};

Util.hasCheck = function(name,value) {

	var array = document.getElementsByName(name);
	for (var i=0;i<array.length;i++) {
		 if (array[i].checked == true && value == array[i].value ) {
			 return true;
		 }
	}

	return false;
};


Util.setRadioValue = function(name,value,callback) {

	var array = document.getElementsByName(name);
	for (var i=0;i<array.length;i++) {

		 if (array[i].value == value) {
			 array[i].checked = true;

			 if (callback) {
			 	 callback($(array[i].id));
			 }

		 }
	}

	return null;
};

Util.setDisabledByName = function(name,disabled) {

	var array = document.getElementsByName(name);
	for (var i=0;i<array.length;i++) {
		 array[i].disabled = disabled;
	}

};

Util.setReadonly = function(id,status,callback) {

	var obj = $(id);

	if (obj == null) {
		alert('can not find object by id :' + id);
		return;
	}

	if (obj.type == 'text' ) {
		obj.writeAttribute('readonly',status);
	} else {
		obj.disabled = status;
	}

};

Util.trim = function(s) {
	if (s == null) {
		return null;
	}
	var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
	return (m == null) ? '' : m[1];
};


Util.buildGrid = function(config) {

	// grid,columns,caption,buttom

	var grid = $(config.id);
	var caption = $(config.caption);
	var buttom = $(config.buttom);
	var records = config.records;
	var column = config.column;

	clean();

	for (var i=0;i<records.length;i++) {

		var tr = document.createElement("tr");
		var record = records[i];

		for (var j=0;j<column.length;j++) {

			var col = column[j];

			var td = document.createElement("td");

			td.innerHTML = record[ col.dataIndex ];

			tr.insertBefore(td,null);
		}

		grid.insertBefore(tr,buttom);
	}

	function clean() {

		var children = grid.childElements()

		children.each(
			function(child){
				child.remove();
			}
		);


	}

};

Util.downloadFile = function(url,fileName) {

	function getNewSubmitForm(){
	 	var submitForm = document.createElement("FORM");
	 	document.body.appendChild(submitForm);
	 	submitForm.method = "POST";
	 	return submitForm;
	}

	function createNewFormElement(inputForm, elementName, elementValue){
	 	var newElement = document.createElement("input");
	 	newElement.name = elementName;
	 	newElement.type = "hidden";
	 	inputForm.appendChild(newElement);
	 	newElement.value = elementValue;
	 	return newElement;
	}

	 var submitForm = getNewSubmitForm();
	 createNewFormElement(submitForm, 'fileName', fileName);
	 submitForm.action= url;
	 submitForm.submit();

};



function Sys() {};
	Sys.SystemError = function(config) {
};

Sys.isIE = function() {
	return !!(window.attachEvent && !window.opera);
};

Sys.openWindow = function(E, B, C) {
	var D = B, H = C, F = (screen.width - B) / 2, A = (screen.height - C) / 2, G = "width=" + D + ",height=" + H + ",left=" + F + ",top=" + A + ",menubar=no,scrollbars=yes,resizable=yes";
    return window.open(E, "", G);
};

Sys.check = function(json,callback) {
	var status = false;
	if (json.ErrMsg.msgDesc != '' || json.ErrMsg.msgDescs != null) {
		status = messageDisplay(json.ErrMsg);
	}
	if (callback != null) {
		callback(status);
	}
};

Sys.setMsgBoard = function(json, isAlertErrorMsg){

	try{

		var errMsg = json.ErrMsg;
		var errorShowMsg = errMsg.msgDesc;

		if (errMsg.msgDescs.length > 1) {
			errorShowMsg = errMsg.displayMsgDescs;
		}

		var msgBoard = getMsgBoard();
		if (msgBoard) {
			var color= (errMsg.returnCode==0)?"blue":"red";
			var htmlMessage = "<font color='blue'>°T®§¡G</font><font color='" + color + "'>" + errorShowMsg.replace(/\\n/g,"<br>") + "</font>";
			msgBoard.innerHTML = htmlMessage;
		}

		if(errorShowMsg && errorShowMsg!='' && isAlertErrorMsg===true){
			var str = '';
			var msgid = errMsg.msgid;
			var isError = errMsg.returnCode != 0;
			if(isError && msgid!='' && msgid.length>17){
				str += '¿ù»~½s¸¹¡G\n'+msgid;
				str +='\n';
				str +='°T®§»¡©ú¡G\n';
			}
			str += errorShowMsg.replace(/\\n/g,"\n");
			alert(str);
		}

	}catch(e){
		window.console && window.console.log("update bottomFrame at ui.js 'Sys.setMsgBoard()' throws exception : " + e);
	}

};

function messageDisplay(obj) {
	
		if(!obj || typeof(obj) != 'object'){ 
			window.console && window.console.log('[ui.js][messageDisplay] the type of input not object.')
			return; 
		}

		var isSucceed;
		var msgid = typeof(obj.msgid) != 'string' ? '' : obj.msgid;
		if(msgid.startsWith("ME") )	{
			isSucceed=false;
		}else if(obj.returnCode >= 0 || msgid.startsWith("MI") ){
			isSucceed=true;
		}
		return isSucceed;
}

function cleanMsgBoard() {
	try{
		var msgBoard = getMsgBoard();
		if(!msgBoard){
			return;
		}
		if (msgBoard.tagName == 'IFRAME') {
			if(msgBoard.contentWindow){
				msgBoard.contentWindow.cathay_common_msgBoard='';
			}else{
				msgBoard.cathay_common_msgBoard='';
			}
		}else{
			msgBoard.innerHTML = '';
		}
	}catch(e){
		window.console && window.console.log("update bottomFrame at ui.js 'cleanMsgBoard()' throws exception : " + e);
	}
}

function getMsgBoard() {

	try{
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

		var bottomFrame = getBottomFrame();
		if(bottomFrame){
			if(bottomFrame.contentWindow){
				return bottomFrame.contentWindow.cathay_common_msgBoard;
			}
			return bottomFrame.cathay_common_msgBoard;
		}
	}catch(e){
		window.console && window.console.log("cannot found bottomFrame at ui.js 'getMsgBoard()'");
	}
}

Util.cleanMessBoard = cleanMsgBoard;

Util.submit = function(url,params) {

	function getNewSubmitForm(){
	 	var submitForm = document.createElement("FORM");
	 	document.body.appendChild(submitForm);
	 	submitForm.method = "POST";
	 	return submitForm;
	}

	function createNewFormElement(inputForm, elementName, elementValue){
	 	var newElement = document.createElement("input");
	 	newElement.name = elementName;
	 	newElement.type = "hidden";
	 	inputForm.appendChild(newElement);
	 	newElement.value = elementValue;
	 	return newElement;
	}

	 var submitForm = getNewSubmitForm();

	 if (params != null) {
	 	for (var i=0;i<params.length;i++) {
	 		createNewFormElement(submitForm, params[i].name, params[i].value);
	 	}
	 }

	 submitForm.action= url;
	 submitForm.submit();

};



function SelectUI(config) {

	var select = $(config.id);
	var text = config.text;
	var value = config.value;
	var url = config.url;
	var callback = config.callback;
	var records = [];
	var selectValue;
	var parameters = config.parameters;
	var afterRender;


	var store = new Store(
							{
								root:config.root,
								recordID:config.recordID,
								url:url,
								parameters:config.parameters
								/**
								,
								listeners:[

								]*/
							}
						  );

	if (config.listeners == null) {
		config.listeners = [];
	}


	// add listener
	if (config.listeners) {

		config.listeners.push(
							{
								type:Store.EVENT_AFTER_LOAD,
								handler:renderUI       // ¦b store ¸ü¤J¤§«á,Åã¥Ü¤U©Ô¿ï³æªº¤º®e
							}
						  );

		config.listeners.push(
							{
								type:Store.EVENT_AFTER_LOAD,
								handler:toSelectValue  // ¦b store ¸ü¤J¤§«á,¤Ä¿ï¼Æ­È
							}
						  );

		for (var i=0;i<config.listeners.length;i++) {

			var event = config.listeners[i];

			event.target = select;
			event.store = store;

			if (config.listeners[i].type == 'ON_CHANGE') {

				select.observe('change',event.handler);

			} else {

				store.addListener( event );
			}
		}
	}

	function toSelectValue() {

		if (selectValue != null) {
			select.value = selectValue;
			selectValue = null; // ¤Ä¿ï§¹¥H«á§â¥¦²M°£
		}
	}


	function renderUI(event) {

		Util.removeChildrenElements(event.target);

		var records = event.store.getRecords();

		for (var i=0;i<records.length;i++) {
			var record = records[i];

			if ( Sys.isIE() ) {

			   var option = new Option(record.getFieldByName(text).value,record.getFieldByName(value).value);
			   event.target.options.add( option );

			} else {

				var option = Util.createElement("option");
				option.update( record.getFieldByName(text).value );
				option.setAttribute('value', record.getFieldByName(value).value );
				event.target.insert(option);
			}

		}

	}

	this.parameters = parameters;

	return {
				init:function() {

				},
				load:function(parameters,newValue) {
					selectValue = newValue;
					store.load(parameters);
				},
				reload:function(parameters) {
					store.load(parameters);
				},
				getStore:function() {
					return store;
				},
				getUrl:function() {
					return url;
				}
			};
}

function changeDate(obj) {

	if (obj.value.length == 8) {
		obj.value = obj.value.substring(0,4) + "-" + obj.value.substring(4,6) + "-" + obj.value.substring(6,8);
	}

}


/**
	trip:{
			id:,
			title:
		 }


*/
function ToolTipUI(list) {


	var identifyCss = 'ui.class.tip';

	var toolTip = ( new function() {

						var identifyTip = 'ui.obj.tip';

						this.init = function() {

							if ( $(identifyTip) == null ) {

								 var divTips = document.createElement('div'); //create div element
					¡@¡@			 divTips.id = identifyTip;
					¡@¡@			 divTips.style.display='none';

								 document.body.appendChild(divTips);
							}

							return this;
						};


						function getMousePosition(e) {

					        var x = 0, y = 0;
					        var e = e || window.event;
					        if (e.pageX || e.pageY) {
					            x = e.pageX;
					            y = e.pageY;
					        } else if (e.clientX || e.clientY) {
					            x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
					            y = e.clientY + document.body.scrollTop  + document.documentElement.scrollTop;
					        }
					        return { 'x': x, 'y': y };
					    }



						this.locate = function(e) {

					¡@¡@		e = e || window.event;

					¡@¡@		var divTips = $(identifyTip);

					¡@¡@		var mousePos = getMousePosition(e); // get the coordinate of the mouse

							if (Sys.isIE()) {
								divTips.style.top = mousePos.x-12 ;
								divTips.style.left = mousePos.y-8 ;
							} else {
								divTips.style.top = mousePos.x-12 + "px";
								divTips.style.left = mousePos.y-8 + "px";
							}

						¡@¡@

					¡@¡@ };



						this.show = function(trip) {

							var obj = $(identifyTip);

							obj.update(trip.title);
							obj.show();
						};

						this.hide = function(trip) {

							var obj = $(identifyTip);

							obj.update('');
							obj.hide();
						};

					}).init();

	this.unregister = function() {
		var tips = $$('.'+identifyCss);
		for (var i=0;i<tips.length;i++) {
	    	 tips[i].removeClassName(identifyCss);
	    	 tips[i].stopObserving();
	    }
	};

	this.add = function(trip) {

		var obj = $(trip.id);

		var parent = $(Element.identify( obj.parentNode )); // parent node

		if (parent.hasClassName(identifyCss) == false) {

			parent.addClassName(identifyCss); // to identify

			trip.parent =  parent.identify();

			parent.observe('click', function(event){
				  					//toolTip.show(trip);
				  					alert(trip.title);
				 				}
			 				);

		}

	};


}

function CompareList(define, templateHtml) {

	var target = define.target;

	this.load = function(records) {

		if ( records == null || records.length == 0) {
			 this.reset();return;
		}


		if(!templateHtml){
				templateHtml=
							"<tr>"+
								"<td class='tbBlue3' align='center'>#{PROPERTY_NAME}</td>"+
								"<td class='tbBlue3' align='center' valign='top'>#{TARGET_VALUE}</td>"+
								"<td height='21' class='tbBlue3' align='center' valign='top'>#{SOURCE_VALUE}</td>"+
							"</tr>";
		}

		var all = "";
		for (var i=0;i<records.length;i++) {
			var obj = records[i];
			var s = new Template(templateHtml).evaluate(obj);
			all = all + s;
		}

		var body = "<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>" +
				   "<tbody>" +
				   "<tr>" +
					  "<td height='20' colspan='3' class='tbYellow0' align='center'><font class='textBold'>®t²§¤ñ¹ï</font></td>" +
				   "</tr>" +
				   "<tr>" +
                      "<td class='tbYellow0' align='center' width='20%'><font color='red' class='textBold'>Äæ¦ì</font></td>" +
                      "<td class='tbYellow0' align='center' width='40%'><font color='red' class='textBold'>­×§ï«e</font>" +
                      "<td height='21' class='tbYellow0' align='center' width='40%'><font color='red' class='textBold'>­×§ï«á</font></td>" +
                   "</tr>" +
                   all +
                   "</tbody>" +
                   "</table>";

		$(target).innerHTML = body;
	}

	this.reset = function() {
		$(target).update('');
	}

}

function SourceControl(config) {

	 this.build = function() {

	 	if (config.source == null || config.source == '' || config.source == CONST.LINK_TYPE_EXAMINE) {

	 		Event.stopObserving('btn_back', 'click'); // ¨ú®ø­ì¥»ªº³B²z

	 		$("btn_back").observe('click', function(event){
					  					history.back();
					 				}
				 				);

		} else if (config.source == CONST.LINK_TYPE_LIST) {

	 		// «O¯d­ì¥»ªº¤è¦¡

	 	} else if (config.source == CONST.LINK_TYPE_OPEN) {

	 		var buttons = $('button_div').childElements()
	 		for (var i=0;i<buttons.length;i++) {
	 			buttons[i].hide();
	 		}

			var btnClose = Util.createElement('button',['id=btnClose']);
			btnClose.setAttribute('className',"button");

			$('button_div').insert(btnClose);

			btnClose.innerHTML = 'Ãö³¬';

 			$(btnClose.id).observe('click', function(event){ parent.popupWin.close(); });

	 	}

	 	return this;

	 };

}

function getNewOrg(ORG_ID,id) {
	new Ajax.Request("<%= request.getContextPath() %>/servlet/HttpDispatcher/RZC0_0101/getOrg",
		{
			parameters: { ORG_ID:ORG_ID} ,
			onSuccess: function(transport) {

				var json = transport.responseText.evalJSON();
				var obj = json.returnObj;

				Sys.check(json,function(status) {
					if (status) {
						var title = Util.trim(obj.ORG_ID0)+' - '+Util.trim(obj.ORG_SRT_NM) ;
						var value = Util.trim(obj.ORG_UID)+' - '+Util.trim(obj.ORG_ID) ;
						if (obj.ACT == '1') {
							title = title + ' (°±¥Î)';
						}
						var option = new Option(title,value);
						option.selected = true;
						$(id).options.add( option );
						$(id).value = value;
					}
				});
			}
		}
	);
}