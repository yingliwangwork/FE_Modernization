var RPTUtil = new function(){

	var isArray = function(obj){
		return Object.prototype.toString.call( obj ) === '[object Array]';
	};

	var hasInclude_jQuery = function (){
		return typeof window['jQuery'] !== 'undefined';
	};

	var hasInclude_Prototype = function (){
		return typeof window['Prototype'] !== 'undefined';
	};

	var judgeHasCSRUtilOrSys = function(resp){
        var hasCSRUtilOrSys = false;
        var isSuccess = false;
		if(window.CSRUtil){// 若有引用 CSRutil.js 時，使用其檢核 returnMessage 判斷
			isSuccess = CSRUtil.isSuccess(resp);
			hasCSRUtilOrSys = true;
        }else if(window.Sys){// 若有引用 ui.js 時，使用其檢核 returnMessage 判斷
        	Sys.check(resp, function(status){isSuccess=status;});
        	hasCSRUtilOrSys = true;
        }else if(resp.ErrMsg.returnCode==0){
        	isSuccess = true;
        }else{
        	isSuccess = false;
        }

        return [isSuccess, hasCSRUtilOrSys];
	};

	var userAgent = navigator.userAgent.toLowerCase();
	var isChrome = userAgent.indexOf("chrome")>=0;
	var isSafari = userAgent.indexOf("safari")>=0;
	var isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");

	//know whick webcontext the page is existed
	var wls = window.location.toString();

	var useBig5EncodeServerSysNos = ['EG'];

	var useBig5EncodeServer = false;
	
	for(var i=0;i<useBig5EncodeServerSysNos.length;i++){
		var patternString = '\/'+useBig5EncodeServerSysNos[i]+'Web*';
		var regex = new RegExp(patternString);
		useBig5EncodeServer = regex.test(wls);
		if(useBig5EncodeServer){
			break;
		}
	}

	var webName = useBig5EncodeServer?'ZRBWeb':'ZRWeb';

	var diffCountByWindowOpen=0;

	/**
	 *  @private
	 *  @class 發送 AJAX 請求
	 *  @param requestURL : 請求路徑。
	 *  @param params : 請求參數。
	 *  @param successAction : 請求結果成功時所要執行之動作。
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	function ajaxRequest(requestURL, params, successAction){
		var requestParams = params || {};
/*
		// 與 CSRUtil.js 使用相同名稱之 cover page id
		var docBody = document.body;
		var cover = $('_frontCover');
		if(!cover){
			cover = document.createElement('div');
			cover.id = '_frontCover';
			cover.style.background = 'white';
			cover.style.filter = 'alpha(opacity=35)';
			cover.style.position = 'absolute';
			cover.style.cursor = 'progress';
			cover.style.posLeft = 0;
			cover.style.posTop = 0;
			cover.style.zIndex = 150;
			docBody.appendChild(cover);
		}
		cover.style.width = (docBody.clientWidth>docBody.scrollWidth)?docBody.clientWidth:docBody.scrollWidth;
		cover.style.height = (docBody.clientHeight>docBody.scrollHeight)?docBody.clientHeight:docBody.scrollHeight;
		Element.show('_frontCover');

		// 在以非同步進行處理時，為讓 cover page 效果產生，故等待 0.001 秒再發送請求
		setTimeout(function(){
*/
		var _ajaxPost_jQuery = !hasInclude_Prototype() && hasInclude_jQuery();
		var ajaxResp;
		var returnMessage;
		var hasCSRUtilOrSys;

		if(_ajaxPost_jQuery){

			jQuery.ajax({
				url: requestURL,
				type: 'post',
				async: false,
				traditional: true,
				cache: false,
				data: params,
				success:function(resp){

					var result = judgeHasCSRUtilOrSys(resp);
	                var isSuccess = result[0];

					hasCSRUtilOrSys = result[1];

	                if(isSuccess){
	                	if(!isSafari || isChrome){
                            successAction(resp);
                        }else{// 當 browser 為 safari 時，需在執行 Ajax 請求後才可執行 form submit
                            ajaxResp = resp;
                        }
                        return;
	                }

					function getErrorMsg(resp){
                        var errMsg = resp.ErrMsg;
                        if(!errMsg || !errMsg.displayMsgDescs){
                            return '';
                        }
                        var msgArray = errMsg.displayMsgDescs.split('\\n');
						var str = '';
						for(var mai=0;mai<msgArray.length;mai++){
							str += msgArray[mai] + '\n';
						}
                        return str.trim();
                    }

                    returnMessage = getErrorMsg(resp);

				}
			});

		}else{
			new Ajax.Request(
				requestURL, {
				parameters:requestParams,
				asynchronous:false,
				onSuccess: function( transport ) {
	                var resp = transport.responseText.evalJSON();

					var result = judgeHasCSRUtilOrSys(resp);
	                var isSuccess = result[0];

					hasCSRUtilOrSys = result[1];

					if(isSuccess){
						if(!isSafari || isChrome){
							successAction(resp);
						}else{// 當 browser 為 safari 時，需在執行 Ajax 請求後才可執行 form submit
							ajaxResp = resp;
						}
						return;
					}

					var getErrorMsg = function(resp){
						var errMsg = resp.ErrMsg;
						if(!errMsg || !errMsg.displayMsgDescs){
							return '';
						}
						var msgArray = $A(errMsg.displayMsgDescs.split('\\n'));
						var str = '';
						msgArray.each(function(s){
							str += s + '\n';
						});
						return str;
					}

		        	returnMessage = getErrorMsg(resp);

				}
			});
		}

		if(!hasCSRUtilOrSys && returnMessage){
			alert(returnMessage);
		}

		if(ajaxResp){
			successAction(ajaxResp);
		}
		return returnMessage;
//		}, 1);
	}

	/**
	 *  @private
	 *  @class 提供 RPTUtil 取得 form
	 *  @param options (Map) :
	 *	       options.actionId :
	 *	       options.servletName :
	 *	       options.spanName :
	 *	       options.isOpenNewBrowse : 開啟新視窗（預設為true）。
	 *	       options.isIndependent (default false)。
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	function getForm(options){
		var actionId = options['actionId'];
		var judgeSetFormTarget = function(eleForm){
			if(options['isOpenNewBrowse'] !== false){
				var currentDate = new Date();
				var windowName = '_RPTUtil_window_'+currentDate.getFullYear()+(currentDate.getMonth()+1)+currentDate.getDate()+currentDate.getHours()+currentDate.getMinutes()+currentDate.getSeconds()+currentDate.getMilliseconds();
				var windowOpenAttrs = 'status=no,toolbar=no,menubar=no,resizable=no,scrollbars=yes';
				window.open('',windowName,windowOpenAttrs,true);
				eleForm.setAttribute('target', windowName);
			}
		};

		var oForm = document.getElementById(actionId);
		
		if(oForm && isIE){
			var windowName = oForm.getAttribute('target');
			var windowOpenAttrs = 'status=no,toolbar=no,menubar=no,resizable=no';
			var win = window.open('',windowName,windowOpenAttrs,true);
			win.close();
		}

		if(!oForm){
			oForm = document.createElement("form");
			oForm.id=actionId;
			oForm.name=actionId;
			oForm.action='/'+webName+'/'+options['servletName'];
			oForm.method="post";
			oForm.style.display="none";

			judgeSetFormTarget(oForm);

			var printParametersSpanObj = document.createElement("span");
				printParametersSpanObj.id=options['spanName'];

			oForm.appendChild(printParametersSpanObj);

			document.body.appendChild(oForm);

		} else if(options['isIndependent'] === true){
			judgeSetFormTarget(oForm);
		}
		return oForm;
	}

	/**
	 *	@private
	 *	@class 利用 window open 開啟視窗 <br>
	 *         預設無狀態列、toolbar、menubar
	 *
	 *	@param url (String) :
	 *	@param opts(Map) :
	 *	       opts.parameters (Map) : 傳遞參數
	 *	       opts.attributes (Map) : window open 屬性（如：status, toolbar, menubar, resizable, width, height, top, left ...等）
	 *	       opts.useSameWindow (Boolean) : 是否使用同一開啟視窗，預設為 true。
	 *	       opts.fullScreen (Boolean) : 是否全螢幕，預設為 false。
	 **/
	function windowOpen(url, opts){

		opts = opts || {};

		var params = opts.parameters || {};
		var fullScreen = opts.fullScreen === true;
		var attrs = {'status':'no','toolbar':'no','menubar':'no','resizable':fullScreen?'no':'yes'};

		var inputAttrs = opts.attributes;
		if(inputAttrs){
			for(var k in inputAttrs){
				attrs[k]=inputAttrs[k];
			}
		}

		if(fullScreen){
			attrs['width']=screen.availWidth;
			attrs['height']=screen.availHeight;
			attrs['top']=0;
			attrs['left']=0;
		}

		var windowName = 'RPTUtilWindowOpen';
		if(opts.useSameWindow===false){
			diffCountByWindowOpen++;
			var currentDate = new Date();
			windowName += '_'+currentDate.getFullYear()+(currentDate.getMonth()+1)+currentDate.getDate()+currentDate.getHours()+currentDate.getMinutes()+currentDate.getSeconds()+currentDate.getMilliseconds();
			windowName += '_'+diffCountByWindowOpen;
		}

		var windowOpenAttrs = '';
		for(var attrKey in attrs){
			if(windowOpenAttrs.length>0){ windowOpenAttrs +=','; }
			windowOpenAttrs += attrKey+'='+attrs[attrKey];
		}

		var formId = '_RPTUtil_windowOpen_form';
		var theForm = $(formId);

		if(!theForm){
			theForm = new Element('form', {'id':formId, 'method':'post', 'action':url}).setStyle({'display':'none'});
			document.body.appendChild(theForm);
		}

		theForm.update();

		for(var k in params){
			theForm.insert(new Element('input', {'type':'hidden', 'name':k, 'value': params[k]}));
		}

		theForm.setAttribute( 'target', windowName );
		window.open('',windowName,windowOpenAttrs,true);
		theForm.submit();

	}

	/**
	 *  @private
	 *  @class 執行列印，當具有子報表時，PARAM及DETAIL請以Array傳入。
	 *  @param options (Map) :
	 *  	   options.servletName : 取得報表的 servlet
	 *	       options.pageIds : 頁面ID。
	 *	       options.rptParams : 報表使用之PARAM。
	 *	       options.rptDetails : 報表使用之DETAIL。
	 *	       options.encryptTempFileFullPath : 報表產生之暫存檔完整路徑。
	 *	       options.isOpenNewBrowse : 開啟新視窗（預設為true）。
	 *	       options.isIndependent : 每次開啟的新視窗皆獨立不重覆使用（預設為 false）。
	 *	       options.downloadFileName : 下載的檔案名稱（不需含副檔名）。
	 *		   options.beforeActions : 執行下載前需先執行的相關 action，格式為 [ { url(必輸, String), parameters(非必輸, {}) } ]
	 *         options.submitParam : 需要跟著送出的參數值
	 *  @author 劉本傑
	 *  @version 1.00
	 **/
	function actionHandler(options){

		var encryptTempFileFullPath = options['encryptTempFileFullPath'];
		var downloadFileName = options['downloadFileName'];
		var beforeActions = isArray(options['beforeActions'])? options['beforeActions'] : false;

		var downloadFileNameKey = 'downloadFileName';
		var spanName='printParametersSpan';

		var oForm = getForm({
			'actionId': 'pdfAction',
			'servletName': options['servletName'],
			'spanName': spanName,
			'isOpenNewBrowse': options['isOpenNewBrowse'],
			'isIndependent': options['isIndependent']
		});
		var submitParam = options['submitParam'];
		if( Object.prototype.toString.call(submitParam) == '[object Object]'){
			for(var k in submitParam){
				oForm.appendChild(RPTUtil.createHiddenElementByPrintParameter(k, submitParam[k]));
			}
		}
			
		var printParametersSpanObj = document.getElementById(spanName);
			printParametersSpanObj.innerHTML='';

		if(encryptTempFileFullPath && typeof(encryptTempFileFullPath)=='string'){

			var paramName='encryptTempFileFullPath';

			printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(paramName, encryptTempFileFullPath));

			// 加上浮水印的檔案完整路徑 - for download
			var encryptMarkedFileFullPath = options['encryptMarkedFileFullPath'];

			if(encryptMarkedFileFullPath) {
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('encryptMarkedFileFullPath', encryptMarkedFileFullPath));
			}

			// 加上浮水印的檔名 - for download
			var encryptMarkedFileName = options['encryptMarkedFileName'];

			if(encryptMarkedFileName) {
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('encryptMarkedFileName', encryptMarkedFileName));
			}

		}else{

			var pageIds = options['pageIds'];
			var rptParams = options['rptParams'];
			var rptDetails = options['rptDetails'];

			var urlName='RPT_URL';
			var paramName='RPT_PARAM';
			var detailName='RPT_DETAIL';

			if(isArray(rptParams)){

				var pageIdsIsArray = false;
				var lengthIsSame = false;

				if(isArray(pageIds)){

					pageIdsIsArray = true;

					if(pageIds.length==rptParams.length){
						lengthIsSame = true;
						for(var i=0;i<pageIds.length;i++){
							var pageId = pageIds[i];
							printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlName, pageId));
						}
					}

				}

				for(var i=0;i<rptParams.length;i++){
					var rptParam = rptParams[i];
					if(!pageIdsIsArray){
						printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlName, pageIds));
					}else if(!lengthIsSame){
						printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlName, pageIds[0]));
					}

					printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(paramName, rptParam));
				}

			}else{
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlName, pageIds));
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(paramName, rptParams));
			}

			if(isArray(rptDetails)){

				for(var i=0;i<rptDetails.length;i++){
					var rptDetail = rptDetails[i];
					printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(detailName, rptDetail));
				}

			}else{
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(detailName, rptDetails));
			}
		}

		if(options['IS_TIFF']){
			printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('IS_TIFF', options['IS_TIFF']));
		}

		if(beforeActions) {

			var urlName = 'url';
			var urlParamName = 'parameters';

			for(var i=0;i<beforeActions.length;i++){
				var beforeAction = beforeActions[i];
				var url = beforeAction[urlName];
				var urlParam = beforeAction[urlParamName] || '{}';
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlName, url));
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(urlParamName, urlParam));
			}

		}

		if(downloadFileName && typeof(downloadFileName)=='string'){
			printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter(downloadFileNameKey, downloadFileName));
		}

		oForm.submit();
	}

	return {
		/**
		 *  @public
		 *  @class 建立Hidden輸入欄位。
		 *  @param n : 名稱。
		 *  @param v : 值。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		createHiddenElementByPrintParameter: function(n, v){
			var inputText = document.createElement("input");
			    inputText.type = "hidden";
			    inputText.name = n;
			    inputText.value = v;
			return inputText;
		},
		/**
		 *  @public
		 *  @class 執行列印，當具有子報表時，PARAM及DETAIL請以Array傳入。
		 *  @param options (Map) :
		 *	       options.pageIds : 頁面ID。
		 *	       options.rptParams : 報表使用之PARAM。
		 *	       options.rptDetails : 報表使用之DETAIL。
		 *	       options.encryptTempFileFullPath : 報表產生之暫存檔完整路徑。
		 *	       options.isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *	       options.downloadFileName : 下載的檔案名稱（不需含副檔名）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executePrintHandler: function(options){
			options['servletName'] = 'RptServlet';
			actionHandler(options);
		},
		/**
		 *  @public
		 *  @class 執行列印，當具有子報表時，PARAM及DETAIL請以Array傳入。
		 *  @param pageIds : 頁面ID。
		 *  @param rptParams : 報表使用之PARAM。
		 *  @param rptDetails : 報表使用之DETAIL。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executePrint: function(pageIds, rptParams, rptDetails, isOpenNewBrowse, isTiff){
			var options = {
				'pageIds': pageIds,
				'rptParams': rptParams,
				'rptDetails': rptDetails,
				'isOpenNewBrowse': isOpenNewBrowse
			};
			if(isTiff){
				options['IS_TIFF'] = 'Y';
			}
			this.executePrintHandler(options);
		},
		/**
		 *  @public
		 *  @class 依所使用之連結進行查詢，查詢完成後直接進行列印。
		 *  @param requestURL : 連結路徑。
		 *  @param params : 該連結所需使用之相關參數。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executePrintByLink: function(requestURL, params, isOpenNewBrowse){
			return ajaxRequest(requestURL, params, function(resp){
				RPTUtil.executePrintByResponse(resp, isOpenNewBrowse);
			});
		},
		/**
		 *  @public
		 *  @class 執行列印，當具有子報表時，PARAM 及 DETAIL 請以 Array 傳入，後端程式需配合使用 com.cathay.util.jasper.JasperReportUtils 將報表「頁面ID、報表使用之PARAM、報表使用之DETAIL」設定至 response。
		 *  @param resp : response（JSON format）。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executePrintByResponse: function(resp, isOpenNewBrowse){
			this.executePrintHandler({
				'IS_TIFF': resp['IS_TIFF'],
				'encryptTempFileFullPath': resp['encryptTempFileFullPath'],
				'isOpenNewBrowse': isOpenNewBrowse
			});
		},
		/**
		 *  @public
		 *  @class
		 *  @param resp : response（JSON format）。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *  @param beforeActions ( Map Array ) : 在執行下載前可先執行其他 action，beforeAction 可有多筆
		 *	       beforeActions.url : action url (必輸)
		 *	       beforeActions.parameters : action 會用到的參數 (非必輸)
		 *  @param isIndependent : 每次開啟的新視窗皆獨立不重覆使用（預設為 false）。
		 *  @author 傅威銘
		 *  @version 1.00
		 **/
		executeSecurityPrintHandler: function(resp, isOpenNewBrowse, beforeActions, isIndependent){
			var options = {
				'servletName':'AppletServlet',
				'encryptTempFileFullPath': resp['encryptTempFileFullPath'],
				'encryptMarkedFileFullPath': resp['encryptMarkedFileFullPath'],
				'encryptMarkedFileName': resp['encryptMarkedFileName'],
				'downloadFileName' : resp['downloadFileName'],
				'isOpenNewBrowse': isOpenNewBrowse,
				'isIndependent':isIndependent,
				'submitParam':resp['submitParam']
			};
			if(beforeActions){
				options['beforeActions']=beforeActions;
			}
			actionHandler(options);
		},
		/**
		 *  @public
		 *  @class 透過 Applet 開啟報表，當具有子報表時，PARAM 及 DETAIL 請以 Array 傳入，後端程式需配合使用 com.cathay.util.jasper.JasperReportUtils 將報表「頁面ID、報表使用之PARAM、報表使用之DETAIL」設定至 response。
		 *  @param resp : response（JSON format）。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *	@param isIndependent : 每次開啟的新視窗皆獨立不重覆使用（預設為 false）。
		 *  @author 傅威銘
		 *  @version 1.00
		 **/
		executeSecurityPrintByResponse: function(resp, isOpenNewBrowse, isIndependent){
			this.executeSecurityPrintHandler(resp, isOpenNewBrowse, false, isIndependent);
		},
		/**
		 *  @public
		 *  @class 下載列印資料，當具有子報表時，PARAM及DETAIL請以Array傳入。
		 *  @param pageIds : 頁面ID。
		 *  @param rptParams : 報表使用之PARAM。
		 *  @param rptDetails : 報表使用之DETAIL。
		 *  @param downloadFileName : 下載的檔案名稱（不需含副檔名）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		downloadPrintData: function(pageIds, rptParams, rptDetails, downloadFileName, isTiff){
			var options = {
				'pageIds': pageIds,
				'rptParams': rptParams,
				'rptDetails': rptDetails,
				'downloadFileName': downloadFileName
			};
			if(isTiff){
				options['IS_TIFF'] = 'Y';
			}
			this.executePrintHandler(options);
		},
		/**
		 *  @public
		 *  @class 依 response 內所設定之檔案名稱及完整之檔案路徑取得後，轉送請求至指定 Web 的 XlsServlet，進行下載動作。
		 *  @param requestURL : 請求路徑。
		 *  @param params : 請求參數。
		 *  @param isOpenNewBrowse : 是否開新視窗（預設為true）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executeCreateXlsFile: function(requestURL, params, isOpenNewBrowse){
			return ajaxRequest(requestURL, params, function(obj){
				var spanName='createXlsParametersSpan';
				isOpenNewBrowse = isOpenNewBrowse!==false?true:false;
				var oForm = getForm({
					'actionId': 'xlsAction',
					'servletName': 'xls',
					'spanName': spanName,
					'isOpenNewBrowse': isOpenNewBrowse
				});

				var printParametersSpanObj = document.getElementById(spanName);
					printParametersSpanObj.innerHTML='';
					printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('xlsFileFullPath', obj['xlsFileFullPath']));
					printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('outputFileName', obj['outputFileName']));

				oForm.submit();
			});
		},
		/**
		 *  @public
		 *  @class 依 response 內所設定之檔案名稱及完整之檔案路徑取得後，轉送請求至指定 Web 的 XlsServlet，進行下載動作。
		 *  @param requestURL : 請求路徑。
		 *  @param params : 請求參數。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		executeCreateCsvFile: function(requestURL, params){
			this.executeCreateXlsFile(requestURL, params);
		},
		/**
		 *  @public
		 *  @class 先發送 Ajax 請求至指定 URL 後，透過 RptUtils 設定下載相關參數，轉送請求至指定 Web 的 FileDownloadServlet，進行下載動作。
		 *  @param requestURL : 請求路徑。
		 *  @param params : 請求參數。
		 *  @param isOpenNewBrowse : 是否開新視窗。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		downloadFile: function(requestURL, params, isOpenNewBrowse){
			return ajaxRequest(requestURL, params, function(obj){
				RPTUtil.download({
					'downloadFileName': obj['downloadFileName'],
					'downloadFileFullPath': obj['downloadFileFullPath'],
					'isOpenNewBrowse': isOpenNewBrowse
				});
			});
		},
		/**
		 *  @public
		 *  @class 檔案下載
		 *  @param options (Map) :
		 *	       options.downloadFileName : 加密後之下載檔案名稱。
		 *	       options.downloadFileFullPath : 加密後之下載檔案完整路徑。
		 *	       options.isOpenNewBrowse : 是否開新視窗，預設為 true。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		download: function(options){
			var isOpenNewBrowse = options.isOpenNewBrowse!==false?true:false;
			var spanName='downloadFileParametersSpan';
			var oForm = getForm({
				'actionId': 'downloadAction',
				'servletName': 'FileDownload',
				'spanName': spanName,
				'isOpenNewBrowse': isOpenNewBrowse
			});
			var printParametersSpanObj = document.getElementById(spanName);
				printParametersSpanObj.innerHTML='';
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('downloadFileName', options['downloadFileName']));
				printParametersSpanObj.appendChild(RPTUtil.createHiddenElementByPrintParameter('downloadFileFullPath', options['downloadFileFullPath']));
				oForm.submit();
		},
		/**
		 *  @public
		 *  @class 依所使用之連結進行查詢，查詢完成後直接進行列印。
		 *  @param requestURL : 連結路徑。
		 *  @param params : 該連結所需使用之相關參數。
		 *  @param isOpenNewBrowse : 開啟新視窗（預設為true）。
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		fileWatchDog: function(requestURL, params){
			return ajaxRequest(requestURL, params, function(resp){
				var actionUril = '/'+webName+'/FileWatchDog';
				var effps = resp['encryptTempFileFullPaths'];
				var enableWaterMark;
				if(!params){
					enableWaterMark = 'false';
				}else{
					enableWaterMark = params['enableWaterMark'];
				}
				if(effps){
					for(var i=0;i<effps.length;i++){
						windowOpen(actionUril, {
							'parameters':{'encryptTempFileFullPath': effps[i], 'enableWaterMark': enableWaterMark},
							'useSameWindow': false
						});
					}
				}else{
					var effp = resp['encryptTempFileFullPath'];
					if(!effp){
						return;
					}
					windowOpen(actionUril, {
						'parameters':{'encryptTempFileFullPath': effp, 'enableWaterMark': enableWaterMark, 'webName': webName},
						'useSameWindow': false
					});
				}
			});
		},
		fileWatchDog4WaterMark: function(requestURL, params){
			if(!params){
				params = {};
			}
			params['enableWaterMark'] = 'true';
			this.fileWatchDog(requestURL, params);
		},
		/**
		 *  @public
		 *  @class 產生 barcode
		 *  @param options (Map) :
		 *	       options.value(String) : 輸入文字（必輸欄位）
		 *	       options.width(Number) : 寬度（預設為 1）
		 *	       options.height(Number) : 高度 （預設為 22）
		 *	       options.rotate(Boolean) : 是否翻轉 90度（預設為 false）
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		genBarcode: function(options, node){
			var params = {
				'width': options['width']||1,
				'height': options['height']||22,
				'rotate': options['rotate']===true||false
			};
			var linkSrc = '/'+webName+'/BarcodeGenerator?inputStr='+options['value'];
			for(var key in params){
				var v = options[key];
				if(v){linkSrc+='&'+key+'='+v;}
			}

			var img = document.createElement('img');
				img.src = linkSrc;

			return img;
		}
	};
};