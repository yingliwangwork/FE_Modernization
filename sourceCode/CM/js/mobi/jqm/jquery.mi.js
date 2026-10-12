(function($, undefined){
	
	//namespace for csr mi project
	$.mi = {}; 
	
	var $alert = $( "<div class='ui-loader ui-body-a ui-corner-all'><span class='ui-icon ui-icon-loading spin'></span><h1></h1></div>" );		
	
	//object for save uuid
	var $myScript = $('#jqueryMiJs');
	var uuid =  $myScript.jqmData('uuid');	
	var responseTimeEndParameters;
	
	if(!window.console){		
		window.console = {
			log:function(){}
		}				
	}
	if(!window.dateJs){
		window.dateJs = new createDateJs();
	}
	keepResponseTimeEndParameters(uuid);	
//-----------------------------------------------
//utility methods
//-----------------------------------------------
	//定住畫面不隨 touchmove 而移動
	$.mi.lockView = function(){
		$(document).bind('touchmove', stopTouchMove);
	};
//--------------------------------------------------------------------------------		
	//解除畫面鎖定
	$.mi.unlockView = function(){
		$(document).unbind('touchmove', stopTouchMove);
	};
//--------------------------------------------------------------------------------		
	$.mi.stopEvent = function(event){
		event.preventDefault();
		event.stopImmediatePropagation();		
	}
//--------------------------------------------------------------------------------		
	//透過 jqm 來顯示 loading 訊息，但可先自定一次訊息內容
	$.mi.showLoadingMsg = function(msg){
		$.mobile.loadingMessage = msg || '載入中'
		$.mobile.showPageLoadingMsg();
	};
//--------------------------------------------------------------------------------		
	//取得 Response 中的 ReturnMessage 物件
	$.mi.getRtMsg = function(resp) {
		return resp['ErrMsg'];
	};
//--------------------------------------------------------------------------------		
	//顯示錯誤訊息
	$.mi.error = function(msg){
		alert(msg);
	};
//--------------------------------------------------------------------------------		
	//判斷 Response 中的 ReturnMessage 的 ReturnCode 決定是否成功
	$.mi.isSuccess = function(resp) {
		var msg = $.mi.getRtMsg(resp);
		if(msg){
			return (msg.returnCode == 0);
		}
		return false;
	};
//--------------------------------------------------------------------------------	
	/**
	 *  @public
	 *	@class 將西元年日期轉為民國年日期。 <br>
	 *	@param String : 西元年月日
	 **/
	$.mi.toROC = function(Y2Kdate){
		if (Y2Kdate && Y2Kdate.length==10){
			ROCdate = ((parseInt(Y2Kdate.substring(0,4),10))-1911)+Y2Kdate.substring(5,7)+Y2Kdate.substring(8,10);
		}else{	
			ROCdate = Y2Kdate;
		}
		return ROCdate;
	}
//--------------------------------------------------------------------------------	
	/**
	 *  @public
	 *	@class 將民國年日期轉為西元年日期。 <br>
	 *	@param String : 民國年月日。
	 **/
	$.mi.toY2K = function(ROCdate){
		var Y2Kdate = "";
		if(ROCdate){
			if (ROCdate.length==6){
				Y2Kdate = ((parseInt(ROCdate.substring(0,2),10))+1911)+"-"+ROCdate.substring(2,4)+"-"+ROCdate.substring(4,6);
			}else if (ROCdate.length==7){
				Y2Kdate = ((parseInt(ROCdate.substring(0,3),10))+1911)+"-"+ROCdate.substring(3,5)+"-"+ROCdate.substring(5,7);
			}else if (ROCdate.length==8){
				Y2Kdate = ((parseInt(ROCdate.substring(0,4),10))+1911)+"-"+ROCdate.substring(4,6)+"-"+ROCdate.substring(6,8);
			}else{
				Y2Kdate = ROCdate;
			}
		}
		return Y2Kdate;
	}
	
	//將物件的值填入 input 及有定義 data-mi-text 的 elem 中	
	//default options
	var dataToView_options = {
		exclude : []
	};
			
	$.mi.dataToView = function( data, selecter, options ){

		var $selecter = $(selecter);
		
		options = $.extend({}, dataToView_options, options);
		
		console.log('data to view options');
		console.log(options);
		
		
		$selecter.find(':input').each(function(index, elem){
			
			dataToInput(data, elem, options);
				
		}).end().find('[data-mi-text]').each(function(index, elem){
			
			dataToText(data, elem, options);
			
		});
		
		if($selecter.is(':input')){
			dataToInput(data, $selecter, options);
		}else if($selecter.jqmData('mi-text')){	
			dataToText(data, $selecter, options);
		}	
	}
//--------------------------------------------------------------------------------	
	$.mi.viewToData = function( selecter ){
		
		var obj = {};
		
		$(selecter).find(':input').each(function(index, elem){
			
			var $this = $(elem);
			
			if($this.is(':checkbox')){
				//bug find in jq attr checked
				if($this.attr('checked') || this.getAttribute('checked')){
					obj[elem.name] = $this.val();	
				}
			}else if($this.is(':radio')){
				if($this.attr('checked')){
					obj[elem.name] = $this.val();	
				}
			}else{
				obj[elem.name] = $this.val();	
			}
			
		});
		
		return obj;	
			
	};
//--------------------------------------------------------------------------------	
	$.mi.submit = function ( url, options ){
		var $form = $('<form>').attr('method', 'post').attr('action', url).attr('data-ajax', 'false');
		if(options != undefined){
			var data = options.data || {};
			
			for(var n in data){
				
				if( typeof data[n] == 'string' || typeof data[n] == 'number' ){
					
					$('<input>').attr('name', n).val(data[n]).appendTo($form);
					
				}
				
			}
			//set uuid and time
			if(responseTimeEndParameters && responseTimeEndParameters.length>0){
				for(var i=0;i<responseTimeEndParameters.length;i++){
					var responseTimeEndParameter = responseTimeEndParameters[i];
					$('<input>').attr('name', 'requestTimeEndUUID').val(responseTimeEndParameter['UUID']).appendTo($form);
					$('<input>').attr('name', 'requestTimeEndField').val(responseTimeEndParameter['requestTimeField']).appendTo($form);
				}
				responseTimeEndParameters = [];
			}
		}
		
		$form.appendTo($('body'));
		$form.submit();
		
	}
//--------------------------------------------------------------------------------	
	//a stupid wrap for jq ajax invoke
	$.mi.ajax = function(url, options) {
		
		if (typeof url === "object") {
			options = url;
			url = undefined;
		}
		
		options = options || {};
		
		var success = options.success;
		
		if(success && $.isFunction(success)){
			
			options.success = function(data, textStatus, jqXHR){
				
				//only validate json object response
				
				if( typeof data == "object" && options.dataType != 'jsonp'){

					if( $.mi.isSuccess(data) ){
						success(data, textStatus, jqXHR);
					}else{
						if(options.error){
							options.error(jqXHR, textStatus);					
						}else{
							var errMsgStr = $.mi.getRtMsg(data).displayMsgDescs.split('\\n').join('\n');
							$.mi.error(errMsgStr);
						}
					}					
					
				}else{
					success(data, textStatus, jqXHR);
				}	
				
			}
			
		}
		
		return $.ajax(options);
		
	}
//--------------------------------------------------------------------------------
	var allTmplStores = {};
	$.mi.createTemplate = function($page) {
		
		var $pageTmplStore = {};
		
		$page.find('[data-mi-tmpl]').each(function(index, elem){
			
			elem = $(elem);
			var $tmpl = elem.clone();
			var $container = elem.parent() || undefined;
			var $next = elem.next() || undefined;
			var tmplName = elem.jqmData('mi-tmpl');
			
			elem.remove();
			$pageTmplStore[tmplName] = {
				tmpl: $tmpl,
				container: $container,
				next: $next
			};
			
		});
		
		var tmpStoreId = 'page_tmp_store_' + $.now();
		$page.jqmData('page_tmp_store', tmpStoreId);
		
		allTmplStores[tmpStoreId] = $pageTmplStore;
		
		return $.extend({}, $pageTmplStore);
		
	}	
//--------------------------------------------------------------------------------	
	$.mi.getTmpl = function(tmplName){
		
		var $page = $.mobile.activePage;
		var tmpStoreId = $page.jqmData('page_tmp_store');
		
		var tmpStore = allTmplStores[tmpStoreId];
		var tmplDef = tmplStore[tmplName];
		if(tmplDef != undefined){
			return tmplDef.tmpl.clone();
		}	
			
		return $('<div>');
	}
//--------------------------------------------------------------------------------
//	$.mi.evalTmpl(tmplName [,options]) 
//  Any html element has data-mi-tmpl attribute will become template before page 
//	created. And the value in data-mi-tmpl will become the template name for using.
//  
//	@param tmplName - name of the templ
//  @param options is object, now you can set [data] and [content] properties.
//  ex: $.mi.evalTmpl('myTmpl', {data:{}, content:'some html'});
//--------------------------------------------------------------------------------	
	$.mi.evalTmpl = function(tmplName, options){
		
		var $page = $.mobile.activePage;
		var tmpStoreId = $page.jqmData('page_tmp_store');
		var tmplDef = allTmplStores[tmpStoreId][tmplName];
		console.log('Got tmplDef');
		console.log(tmplDef);		
		console.log(options);
		
		if(tmplDef != undefined){
			
			var tmpl = tmplDef.tmpl.clone();
						
			var $container = tmplDef.container;
			var $next = tmplDef.next;
			
			if(options && options.content){
				tmpl.append(options.content);
			}	
			
			if($next.size() > 0){
				$next.before(tmpl);
			}else{	
				$container.append(tmpl);
			}	
			
			//init the jqm ui self
			initUI(tmpl, $container);
			
			if(options && options.data){
				$.mi.dataToView(options.data, tmpl);
			}
			
			if(!tmpl.attr('id')){		
				//create a uid for template target
				tmpl.attr('id', tmpl.get(0).tagName + '_' + $.now());				
			}

			//return the template object
			return tmpl;
			
		}	
	}	
//--------------------------------------------------------------------------------
	function initUI ($node, $container) {

		var dataRole = $node.jqmData('role');
		
		console.log('will init ui for ' + dataRole);
		
		if( dataRole == 'collapsible' ){
			initUI($node.find('[data-role]'), $('<div>'));
		}

		$.each([$container, $node], function(index, instance){
				
			var dataRole = instance.jqmData('role');	
				
			if(dataRole != undefined){
				if( (dataRole != 'fieldcontain' ) && $.isFunction(instance[dataRole]) ){
					instance[dataRole].apply(instance);
				}else{
					instance.trigger('create');
						
				}					
			}
				
		});			
		
	}
//--------------------------------------------------------------------------------	
//Custom some global setting for mi
//--------------------------------------------------------------------------------		
	//Default ajax options setting
	$.ajaxSetup({
		dataType : 'json',
		type     : 'post',
		timeout  : 10000  //預設 10 秒
	});
	
	//global ajax event for loading message
	$(document).bind({
		ajaxSend:function(event, jqXHT, ajaxOptions){
			//set the ajax header to avoid AjaxFilter handle response			
			if(ajaxOptions && ajaxOptions.dataType == 'html'){
				jqXHT.setRequestHeader('X-Requested-With', 'ajax-loading-page');
			}
			//adding this header to force encoding correct in Chrome
			jqXHT.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
			$.mi.showLoadingMsg(ajaxOptions && ajaxOptions.loadingMsg); //setting custom msg if any			
			//set uuid and time
			var optParams = ajaxOptions.data;
			if(!optParams){
				optParams = '';
			}
			if(typeof optParams == 'string'){					
				if(hasDateJs()){										
					optParams += (optParams?'&':'') + 'requestTimeField=' + dateJs.getCurrentTimeStamp();
					if(responseTimeEndParameters && responseTimeEndParameters.length>0){
						var inputRequestTimeEndUUIDs = [];
						var inputRequestTimeEndFields = [];
						for(var i=0;i<responseTimeEndParameters.length;i++){
							var responseTimeEndParameter = responseTimeEndParameters[i];
							inputRequestTimeEndUUIDs.push(responseTimeEndParameter['UUID']);
							inputRequestTimeEndFields.push(responseTimeEndParameter['requestTimeField']);
							optParams += '&requestTimeEndUUID=' + responseTimeEndParameter['UUID'];
							optParams += '&requestTimeEndField=' + responseTimeEndParameter['requestTimeField'];
						}
						responseTimeEndParameters = [];													
					}						
					ajaxOptions.data = optParams;					
				}
			}else{//default json				
				if(hasDateJs()){
					if(optParams){
						optParams.requestTimeField=dateJs.getCurrentTimeStamp();
						if(responseTimeEndParameters && responseTimeEndParameters.length>0){
							var inputRequestTimeEndUUIDs = [];
							var inputRequestTimeEndFields = [];
	
							for(var i=0;i<responseTimeEndParameters.length;i++){
								var responseTimeEndParameter = responseTimeEndParameters[i];
								inputRequestTimeEndUUIDs.push(responseTimeEndParameter['UUID']);
								inputRequestTimeEndFields.push(responseTimeEndParameter['requestTimeField']);
							}
							responseTimeEndParameters = [];				
							optParams.requestTimeEndUUID=inputRequestTimeEndUUIDs;
							optParams.requestTimeEndField=inputRequestTimeEndFields;
						}
						ajaxOptions.data = optParams;
					}					
				}
			}
			console.log("ajaxOptions.data");
			console.log(optParams);
		},
		ajaxStop:function(e){
			$.mobile.hidePageLoadingMsg();		
		},
		ajaxSuccess:function(event, jqXHR, setting, response){
			var requestTimeHandleUUID = response.requestTimeHandleUUID;
			keepResponseTimeEndParameters(requestTimeHandleUUID);			
		}
	});	
//-----------------------------------------------
//  jQuery extends
//-----------------------------------------------
	$.fn.outerHTML = function(s) {
		return $($('<div>').html(this.clone())).html();
	};
//-----------------------------------------------
//  private methods
//-----------------------------------------------
	function stopTouchMove(e){
		e.preventDefault();
	}
	
	function dataToInput(data, elem, options){
		
		var $this = $(elem);
		var name = $this.attr('name');
		var exclude = options.exclude;
		
		if( $.inArray(name, exclude) > -1 ){
			return;
		}
		
		var val = data[name];
	
		if($this.is(':radio') || $this.is(':checkbox')){
			
			if($this.val() == val){
				$this.attr('checked', true).checkboxradio('refresh');
			}else{
				$this.attr('checked', false).checkboxradio('refresh');
			}
		}else{
			
			if(val != undefined){
				$this.val(val);	
			}else{
				$this.val('');
			}
			
			if($this.is('select')){
				$this.selectmenu('refresh');
			}
			
		}	
	}	
	
	function dataToText(data, elem, options){
		
		var $this = $(elem);
		var name = $(elem).jqmData('mi-text');
		var exclude = options.exclude;
		
		if( $.inArray(name, exclude) > -1 ){
			return;
		}
		
		var val = data[name];		
		
		if(val != undefined){
			$(elem).text(val);
		}else{
			$(elem).text('');
		}
		
	}

	
//-----------------------------------------------
//  Custom init page for every page, dialog
//-----------------------------------------------	
  	$(':jqmData(role="page"), :jqmData(role="dialog")').live('pagebeforecreate', function(e, ui){
	  		
  		$page = $(this);
	  	
		console.log('before page create');
  		//search and create template in page before page create and js loaded
  		$.mi.createTemplate($page);
		$page.find('.mustIn').each(function(index, elem){
			$(elem).text('*');			
		});
  		var $js = $page.jqmData('mi-js');
  		
  		if($js){
			
			$.each($js.split(','), function(index, $jsToLoad){
				$.ajax({
					url: $.trim($jsToLoad), 
					async: false,
					global: false,
					dataType: 'script'
				});				
			});

  		}  		
	  		
  	});
  	
  	//--------------------------------------------------------------------------------
	/**
	 *  @public
	 *	@class //計算保險年齡
	 *	@param String : 西元年月日
	 **/
	$.mi.calInsuredAge = function(birthday){
		var curyy,curmm,curdd,ageyy,agemm,agedd,insuredAge,day1,day2;
		var today = new Date();
				
		curyy = parseInt(today.getFullYear(),10)-1911;
		curmm = today.getMonth()+1;
		curdd = today.getDate();
		
		day1=curyy*10000+curmm*100+curdd*1;
		if(birthday.length > 6){
			ageyy = birthday.substr(0,3);
			agemm = birthday.substr(3,2);
			agedd = birthday.substr(5,2);
		}else{
			ageyy = birthday.substr(0,2);
			agemm = birthday.substr(2,2);
			agedd = birthday.substr(4,2);
		}
		day2=ageyy*10000+agemm*100+agedd*1;
		if(day2 >= day1){
			$.mi.error("不得大於今天");
			return;
		}
		var insuredAge=curyy-ageyy;
		var m=curmm-agemm;
		var d=curdd-agedd;
		if(m >0){
			if(m >6 || m==6 && d>0){
				insuredAge ++;
			}
		}else if(m<0){
			if(m<-6 || m==-6 && d==0 || m==-6 && d<0){
				insuredAge--;
			}
		}
		return insuredAge;
	};
	//產生報表
	$.mi.createReportData = function(options){
		var RPT_HOME = '/ALWeb/task';
		var rptData = options.RPT_DATA;
		var asynch = rptData.async==undefined?true:rptData.async;
		rptData.RPT_PARAM['REPORT_ID'] = rptData.REPORT_ID;
		$.mi.ajax({
			async:asynch,
			url: RPT_HOME + '/PostData',
			timeout: 60000,
			data : {
				'APPLY_NO': rptData.APPLY_NO,
				'REPORT_ID': rptData.REPORT_ID,
				'RPT_URL' : 'TEST',
				'RPT_PARAM' : JSON.stringify(rptData.RPT_PARAM),
				'RPT_DETAIL' : JSON.stringify(rptData.RPT_DETAIL),
			},
			dataType: 'text',
			loadingMsg : '資料上傳處理中，約須 1 分鐘請耐心等候！',
			success: function( imgList ){
						
				//取得回傳的圖檔清單，為一個 js 陣列
				imgList = imgList.split(',');
				
			},
			error: function(jqXHR, textStatus, error){
				if(error == 'timeout'){
					$.mi.error('資料上傳失敗,系統忙碌請稍後再試');	
				}else{
					$.mi.error('資料上傳失敗');	
				}
			}
				
		});
		
	}
  	//--------------------------------------------------------------------------------
	function createDateJs(){

		function formatValue(v){
			return v<10?'0'+v:v;
		}

		function formatValueMilliseconds(v){
			if(v<10){
				return '00'+v;
			}
			if(v<100){
				return '0'+v;
			}
			return v;
		};

		function getCurrentTimeStamp(){
			var currentDate = new Date();
				var str = "";
				str += currentDate.getFullYear();
				str += '-'+formatValue(currentDate.getMonth()+1);
				str += '-'+formatValue(currentDate.getDate());
				str += ' '+formatValue(currentDate.getHours());
				str += ':'+formatValue(currentDate.getMinutes());
				str += ':'+formatValue(currentDate.getSeconds());
				str += '.'+formatValueMilliseconds(currentDate.getMilliseconds());
				return str;
		}

		this.getCurrentTimeStamp = getCurrentTimeStamp;
	}
	
	function hasDateJs(){
		return window.dateJs && dateJs.getCurrentTimeStamp;
	}		
	//--------------------------------------------------------------------------------
	/**
	 * @public
	 * @class 交易效能檢測機制導入相關異動，在起動檢測時，將回應時間送至 ZRWeb Servlet <br>
	 * @param uuid (String)
	 **/
	function keepResponseTimeEndParameters(uuid){
		if(!uuid || !hasDateJs()){
			return;
		}					
		if(!responseTimeEndParameters){
			responseTimeEndParameters = [];			
		}else{
			if(responseTimeEndParameters.length==0){
				responseTimeEndParameters=[];
			}
		}		
		responseTimeEndParameters.push({'UUID': uuid, 'requestTimeField':dateJs.getCurrentTimeStamp()});		
	}
	//get responseTimeEndParameters object
	$.mi.getResponseTimeEndParameters = function(){	
		return responseTimeEndParameters;		
	}
})(jQuery);