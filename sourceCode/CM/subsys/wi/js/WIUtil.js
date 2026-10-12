var WIUtil = new function(){

	var diffCountByWindowOpen=0;

	var isEmptyForString = function(s){
		return typeof s == 'undefined' || s=='';
	};

	var addMsg = function(msg, str){
		if(msg==''){
			msg+='請輸入您欲變更的';
		}else{
			msg+='、';
		}
		msg+=str;	
		return msg;
	};

/*
	網路投保 - 職業類別
*/
	var WI_JOB_CLASS = {'1':'第一類', '2':'第二類'};
/*
	網路投保 - 職業類別行業別
*/
	var WI_GROUP  = {
		'01':'機關團體、公司行號'
		, '02':'學生'
		, '03':'家管'
		, '04':'文教、醫療、金融法律、資訊、商、服務業'
		, '05':'退休'
		, '06':'待業中'	
		, '07':'製造、建築、交通運輸'
		, '08':'保全(警察)、軍人、教練或體育人員'
		, '09':'農、林、魚、牧、礦產、觀光、餐飲業'
		, '10':'其他'
	};

/*
	網路投保 - 職業類別說明
*/
	var WI_DESCRIPTION = {
		'1-01':'內勤人員、管理階層人員、諮詢人員…等從事文書處理工作且非以外務為主。'
		, '1-02':'學生（非軍校、體育學院之學生）。'
		, '1-03':'家庭管理。'
		, '1-04':'教職員(非教官、體育老師)、文教機構（圖書、美術館..等）內勤人員、新聞、雜誌、廣告內勤人員、藝術及演藝人員（編曲編劇）。<br>醫師及護士（含中醫）醫務行政人員。<br>資訊業人員、程式撰寫、軟體設計…等非出外務為主工程師。<br>銀行、金融、保險業內勤人；商、服務業之專業人員（會計師、律師、攝影師、髮型設計師等）；商店經營者。'
		, '1-05':'退休。'
		, '1-06':'待業中。'
		, '1-07':'建築師、繪圖、設計師。<br>車行老闆、售票或站務員、服務台人員，屬諮詢、服務人員，非直接從事製造、駕駛者。'
		, '1-08':'警察局/調查局內勤(行政文書)人員、軍人（行政文書）。<br>教練、經紀人。'
		, '1-09':'實驗室研究人員、觀光農牧場經營者、旅館飯店經營者或服務人員、魚塭經營者，多屬經營、管理、諮詢，非直接從事生產工作者。'
		, '2-01':'外勤(業務)人員、推銷員。'
		, '2-02':'軍校、體育學院之學生。'
		, '2-03':'家庭代工、幫傭。'
		, '2-04':'教官、體育教師；外景攝影、記者（非戰地）、廣告拍攝、剪輯員、印刷員、燈光及音效工作、演員、導演、舞者（非武術、特技表演）。<br>獸醫、寵物店看護人員、監獄、看守所醫師、護理人員、安養中心工作人員、齒模製造。<br>食品（米、魚、肉、菜、水果）、雜貨、花卉商、陶磁器、五金、建材商、瓦斯器具商負責人或店員、加油站工作人員、汽車美容（洗車打蠟）人員、泊車、停車場工作人員、清潔人員、收銀員、廚師、小吃(攤販)。'
		, '2-07':'承包商、監工、地毯裝設人員。<br>娃娃車司機、車內服務人員、站內清潔人員、車站月台工作人員、倉儲管理/船務人員(港口作業)。<br>危險程度較低之製造業之工程師、技師、領班、主任、加工人員（家電、電子、塑膠、橡膠、水泥、化學原料、機車、自行車、紡織、成衣、手工藝品、食品、飲品、化妝、藥品…等）汽車玻璃裝配、汽車百貨商。'
		, '2-08':'大樓保全、樓管、守望相助人員。'
		, '2-09':'農夫（花農）、農業技師、水族館經營者、釣魚釣蝦場經營者、木材工廠職員森林、遊樂區導覽員、礦產經營者（現場監督者）、導遊。'
		, '2-10':'自由業、宗教人士、股票投資者、印章刻印、鎖匠、當鋪/銀樓負責人、葬儀社從業人員…等文書、管理者或從事推銷、拜訪從業者。'
	};
/*
	網路投保 - 職業類別要保書套印
*/
	var WI_OVERPRINT  = {
		'1-01':'一般內勤'
		, '1-02':'學生'
		, '1-03':'家管'
		, '1-04':'退休'
		, '1-05':'待業中'
		, '1-06':'其他內勤從業'
		, '2-01':'一般外勤'
		, '2-02':'學生'
		, '2-03':'代工、幫傭'
		, '2-04':'其他外勤從業'
	};
	
	var WI_JOB_CODE = {
		  '1-01':''
		, '1-02':'12010020'
		, '1-03':'17000010'
		, '1-04':''
		, '1-05':'17000040'
		, '1-06':'17000050'
		, '1-07':''
		, '1-08':''
		, '1-09':''
		, '2-01':''
		, '2-02':''
		, '2-03':''
		, '2-04':''
		, '2-07':''
		, '2-08':''
		, '2-09':''
		, '2-10':''	
	};
	
	var initInputOptions = [
		{jobClass:'1', group:'01', overprint:'01', chooseNoOption:{jobClass:'2', group:'01', overprint:'01'}}
		, {jobClass:'1', group:'02', overprint:'02', chooseNoOption:{jobClass:'2', group:'02', overprint:'02'}}
		, {jobClass:'1', group:'03', overprint:'03', chooseNoOption:{jobClass:'2', group:'03', overprint:'03'}}
		, {jobClass:'1', group:'04', overprint:'01', chooseNoOption:{jobClass:'2', group:'04', overprint:'01'}}
		, {jobClass:'1', group:'05', overprint:'04', chooseNoOption:{backInit:true}}
		, {jobClass:'1', group:'06', overprint:'05', chooseNoOption:{backInit:true}}
		, {jobClass:'1', group:'07', overprint:'06', chooseNoOption:{jobClass:'2', group:'06', overprint:'04'}}
		, {jobClass:'1', group:'08', overprint:'06', chooseNoOption:{jobClass:'2', group:'07', overprint:'04'}}
		, {jobClass:'1', group:'09', overprint:'06', chooseNoOption:{jobClass:'2', group:'08', overprint:'04'}}
		, {jobClass:'2', group:'10', overprint:'04', chooseNoOption:{backInit:true}}
	];

	var options_02 = [
		{jobClass:'2', group:'01', overprint:'01'}
		, {jobClass:'2', group:'02', overprint:'02'}
		, {jobClass:'2', group:'03', overprint:'03'}
		, {jobClass:'2', group:'04', overprint:'01'}
		, {jobClass:'2', group:'05', overprint:'04'}
		, {jobClass:'2', group:'06', overprint:'04'}
		, {jobClass:'2', group:'07', overprint:'04'}
	];

	var creditCardIssuers = [
		{bankName:"國泰世華"}, {bankName:"中國信託"}, {bankName:"玉山銀行"}, {bankName:"台新銀行"}, {bankName:"台北富邦"}
		, {bankName:"永豐銀行"}, {bankName:"聯邦銀行"}, {bankName:"遠東商銀"}, {bankName:"新光銀行"}, {bankName:"第一銀行"}
		, {bankName:"華南銀行"}, {bankName:"大眾銀行"}, {bankName:"兆豐銀行"}, {bankName:"凱基銀行"}, {bankName:"合作金庫"}
		, {bankName:"上海銀行"}, {bankName:"彰化銀行"}, {bankName:"台灣企銀"}, {bankName:"元大銀行"}, {bankName:"台灣銀行"}
		, {bankName:"安泰銀行"}, {bankName:"日盛銀行"}, {bankName:"台中銀行"}, {bankName:"永旺信用卡"}, {bankName:"土地銀行"}
		, {bankName:"陽信銀行"}, {bankName:"三信銀行"}, {bankName:"星展銀行"}, {bankName:"華泰銀行"}, {bankName:"高雄銀行"}
		, {bankName:"匯豐銀行"}, {bankName:"渣打銀行"}, {bankName:"樂天信用卡"}, {bankName:""}, {bankName:""}
	];
	
	var creditCardIssuersTips = "註：目前暫不接受花旗銀行、澳盛銀行、美國運通等發卡機構之信用卡。";

	var inputTextValueTipsRegister = function(demoObj, dv){

			var supperedAttr_placeholder = false;
			var userAgent = window.navigator.userAgent.toLowerCase();
			if(userAgent.indexOf('msie ')>0){				
				var version = $.browser.version;
				if(version>=10){
					supperedAttr_placeholder=true;
				}
			}else{
				supperedAttr_placeholder=true;
			}
			
			if(supperedAttr_placeholder){
				demoObj.attr('placeholder',dv);
			}else{
				if(demoObj.val()===''){
					demoObj.val(dv).addClass('initDefaultValue');
				}
				demoObj.click(function(){
					var obj = $(this);
					if(obj.hasClass('initDefaultValue')){
						obj.val('').removeClass('initDefaultValue');
					}
				});
				demoObj.focusout(function(){
					var obj = $(this);
					if(obj.val()===''){
						obj.val(dv).addClass('initDefaultValue');
					}
				});
			}

	};

	/**
	 *	@private
	 *	@class 取得瀏覽器資訊
	 **/
	var getBrowser = function(){
        var browser = {   // browser object
            browser: '',
            desp: null,
            verIE:null,
            docModeIE: null, //IE browser document mode
            verIEtrue: null, //True IE browser version (independent of userAgent, document mode, or browser mode):
            verIE_ua: null //IE browser version (derived from navigator.userAgent)
        };

        var userAgentStrings = navigator.userAgent;
        var tmp = document.documentMode;
        try{document.documentMode = "";}
        catch(e){};

        browser.isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");

        try{document.documentMode = tmp;}
        catch(e){};

        if (browser.isIE) {
            // IE version from user agent
            //
            // For IE < 11, we look for "MSIE 10.0", etc...
            // For IE 11+, we look for "rv:11.0", etc...
            browser.verIE_ua = (/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(userAgentStrings || "") ? parseFloat(RegExp.$1, 10) : null;

            // Get true IE version using clientCaps.
            var e, verTrueFloat, x, obj = document.createElement("div");
            // Array of classids that can give us the IE version
            var CLASSID = [
                 "{45EA75A0-A269-11D1-B5BF-0000F8051515}", // Internet Explorer Help
                 "{3AF36230-A269-11D1-B5BF-0000F8051515}", // Offline Browsing Pack
                 "{89820200-ECBD-11CF-8B85-00AA005B4383}"
            ];
            try { obj.style.behavior = "url(#default#clientcaps)" } catch (e) { };

            for (x = 0; x < CLASSID.length; x++) {
                try { browser.verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
                if (browser.verIEtrue) break;
            };
            verTrueFloat = parseFloat(browser.verIEtrue || "0", 10);
            browser.docModeIE = document.documentMode || ((/back/i).test(document.compatMode || "") ? 5 : verTrueFloat) || browser.verIE_ua;
            browser.verIE = verTrueFloat || browser.docModeIE;
        } else {
            if (userAgentStrings.search('Firefox') >= 0) {
                browser.browser = 'Firefox';
                browser.desp = 'mozilla Firefox';
            } else if (userAgentStrings.search('Opera') >= 0 || userAgentStrings.search('OPR') >= 0) {
                browser.browser = 'Opera';
                browser.desp = 'Opera';
            } else if (userAgentStrings.search('Chrome') >= 0) {
                browser.browser = 'Chrome';
                browser.desp = 'Google Chrome';
            } else if (userAgentStrings.search('Safari') >= 0) {
                browser.browser = 'Safari';
                browser.desp = 'Apple Safari';
            } else if (userAgentStrings.search('Mozilla') >= 0) {
                browser.browser = 'Mozilla';
                browser.desp = 'Mozilla';
            }
        }
        return browser;
    };

	return {
		lightbox: function(opts){//TODO

			var display = function(win){
				if(win && win.displayLightbox){
					win.displayLightbox(opts);
					return true;
				}
			};

			if(self!=top){
				if(display(parent.window)){
					return true;
				}
				if(display(parent.parent.window)){
					return true;
				}
    		}else{    		
    			if(display(window)){
    				return true;
    			}
    		}

    		var msg = opts['msg'];
    		if(msg){
    			alert(msg);
    		}
		}
		, lightboxForModifyMoblNo: function(inputOpts){

			var cbFunc = inputOpts['cbFunc'];

			var opts = {
				type:'json'
				, title:'變更行動電話號碼'
				, columns:[
					{label:'行動電話',type:'text', value:inputOpts['MOBLI_NO']}
					, {label:'新行動電話',type:'inputText', name:'CHG_MOBL_NO'}
					, {type:'span', value:'為保障您的權益，請輸入您的<b>網路交易密碼</b>以變更資料'}
					, {label:'網路交易密碼',type:'password', name:'NET_PW'}
				]
				, buttons:[
					{
						label:'確認送出'
						, clickAction:function(info){
							var CHG_MOBL_NO = info['CHG_MOBL_NO'];
							var NET_PW = info['NET_PW'];
							var msg = '';
							if(isEmptyForString(CHG_MOBL_NO)){
								msg = addMsg(msg,'行動電話號碼');
							}
							if(isEmptyForString(NET_PW)){
								msg = addMsg(msg,'網路交易密碼');
							}
							if(msg!=''){
								alert(msg);
								return false;
							}
							if(!cbFunc){
								return true;
							}
							return cbFunc(CHG_MOBL_NO, NET_PW);
						}
					}
				]
			};
			this.lightbox(opts);
		}
		, lightboxForModifyEmail: function(inputOpts){

			var cbFunc = inputOpts['cbFunc'];

			var opts = {
				type:'json'
				, title:'變更 Email'
				, columns:[
					{label:'Email',type:'text', value:inputOpts['EMAIL']}
					, {label:'新 Email',type:'inputText', name:'CHG_EMAIL'}
					, {type:'span', value:'為保障您的權益，請輸入您的<b>網路交易密碼</b>以變更資料'}
					, {label:'網路交易密碼',type:'password', name:'NET_PW'}
				]
				, buttons:[
					{
						label:'確認送出'
						, clickAction:function(info){
							var CHG_EMAIL = info['CHG_EMAIL'];
							var NET_PW = info['NET_PW'];
							var msg = '';
							if(isEmptyForString(CHG_EMAIL)){
								msg = addMsg(msg,' Email');
							}
							if(isEmptyForString(NET_PW)){
								msg = addMsg(msg,'網路交易密碼');
							}
							if(msg!=''){
								alert(msg);
								return false;
							}
							if(!cbFunc){
								return true;
							}
							return cbFunc(CHG_EMAIL, NET_PW);
						}
					}
				]
			};
			this.lightbox(opts);
		}
		/**
		 *	@public
		 *	@class 建立出基生日期下拉選項。
		 *	@param inputOpts (Map)
		 *	@param inputOpts.showSpece (Object) : 顯示下拉選項的區塊。
		 *	@param inputOpts.minAge (Number) : 最小年齡，預設為 20。
		 *	@param inputOpts.maxAge (Number) : 最大年齡，預設不限制。
		 *	@param inputOpts.value (String) : 初始參數。
		 *	@param inputOpts.change (Function) : 變更下拉選單時，欲進行之動作。
		 **/
		, lightboxForCreateBirthday: function(inputOpts){
			if(self!=top){
				if(parent.window && parent.window.lightboxForCreateBirthday){
					parent.window.lightboxForCreateBirthday(inputOpts);
				}
    		}
		}
		, lightboxForJobClass: function(cbFunc){

			var stepNum = 0;

			var closeLightbox_jobClass = function(jobClassValue,groupValue,overprintValue){
				if(cbFunc){
					if(jobClassValue!==false){
						if(!jobClassValue || !groupValue || !overprintValue){
							alert('請選擇行業別');
							return;
						}
						cbFunc({
							'jobClassValue':jobClassValue
							, 'jobClassName':WIUtil.jobInfoHandler.getJobClassName(jobClassValue)
							, 'groupValue':groupValue
							, 'groupName':WIUtil.jobInfoHandler.getGroupName(jobClassValue,groupValue)
							, 'overprintValue':overprintValue
							, 'overprintName':WIUtil.jobInfoHandler.getOverprintName(jobClassValue,overprintValue)
							, 'description':WIUtil.jobInfoHandler.getDescription(jobClassValue,groupValue)
							, 'jobcode':WIUtil.jobInfoHandler.getJobcode(jobClassValue,groupValue)
						});
					}else{
						cbFunc();
					}
				}
				WIUtil.closeCoverPage();
			};

			var displayLightbox_question = function(questionText,yesFunc,noFunc,unknownFunc){
				stepNum++;
				var inputOpts = {};
				var cbFunc = inputOpts['cbFunc'];
				var opts = {
					type:'json'
					, title:'職業類別查詢'
					, disaplyServiceLine:true
					, columns:[
						{type:'question', isPosLeft:true
							, topicTitle:{
								value:'請回答以下問題以協助我們判斷您的職業：'
							}
							, topicContent:[
								{
									step:stepNum
									, value:questionText
									, options:[
										{text:'是', clickFunction:yesFunc}
										, {text:'否', clickFunction:noFunc}
										, {text:'不清楚', clickFunction:unknownFunc}
									]
								}
							]
						}
					]
				};
				WIUtil.lightbox(opts);
			};

			var displayLightbox_option = function(inputOptions,yesFunc,noFunc,mouseOverTips_no){

				stepNum++;

				var oSelect = $('<select/>');
					oSelect.append($('<option/>').attr('jobClass','').attr('group','').attr('overprint','').attr('description','').html('請選擇'));

				for(var i=0;i<inputOptions.length;i++){
					var inputOption = inputOptions[i];
					var jobClass = inputOption.jobClass;
					var group = inputOption.group;
					var overprint = inputOption.overprint;
					var chooseNoOption = inputOption.chooseNoOption;
					var backInit = chooseNoOption.backInit||false;

					var oSelectOption = $('<option/>')
						.attr('jobClass',jobClass)
						.attr('group',group)
						.attr('overprint',overprint)
						.attr('backInit',backInit)
						.attr('description',WIUtil.jobInfoHandler.getDescription(jobClass,group))
						.html(WIUtil.jobInfoHandler.getGroupName(jobClass,group));

					if(!backInit){
						var cnoJobClass = chooseNoOption.jobClass;
						var cnoGroup = chooseNoOption.group;
						oSelectOption
							.attr('chooseNoOption_jobClass',cnoJobClass)
							.attr('chooseNoOption_group',cnoGroup)
							.attr('chooseNoOption_overprint',chooseNoOption.overprint)
							.attr('chooseNoOption_description',WIUtil.jobInfoHandler.getDescription(cnoJobClass,cnoGroup));
					}

					oSelect.append(oSelectOption);
				}

				var opts = {
					type:'json'
					, title:'職業類別查詢'
					, disaplyServiceLine:true
					, columns:[
						{type:'question', isPosLeft:true
							, topicTitle:{
								value:'請回答以下問題以協助我們判斷您的職業：'
							}
							, topicContent:[
								{
									step:stepNum
									, isSelectOption:true
									, value:'請選擇您的行業別：'
									, optionTitle:'行業別'
									, selectOption:oSelect
									, options:[
										{text:'是', clickFunction:function(){
											var oSelPts = oSelect.children();
											var jobClass;
											var group;
											var overprint;
											for(var i=0;i<oSelPts.length;i++){
												var oSelPt = oSelPts[i];
												if(oSelPt.selected){
													oSelPt = $(oSelPt);
													jobClass = oSelPt.attr('jobClass');
													group = oSelPt.attr('group');
													overprint = oSelPt.attr('overprint');
													break;
												}
											}
			        						return yesFunc(jobClass,group,overprint);
										}}
										, {text:'否', mouseOverTips:mouseOverTips_no, clickFunction:function(){
										}}
									]
								}
							]
						}
					]
				};
				WIUtil.lightbox(opts);
			};

			var unknownAction = function(){
				displayLightbox_option(
					initInputOptions
					, function(jobClassValue,groupValue,overprintValue){// click yes
						closeLightbox_jobClass(jobClassValue,groupValue,overprintValue);
					}
					, function(){// click no
					},'很抱歉！本險僅限職業類別為 1~2 類投保，請點選與您目前職業最為相近者；若均不符合，請洽客服專線 0800-036-599 協助或聯絡您的服務人員進行紙本投保，謝謝！'
				);
			};

			var rtnOptStep1Init = {jobClass:'1', group:'01', overprint:'01'};
			var jobClassStep1 = rtnOptStep1Init['jobClass'];
			var groupStep1 = rtnOptStep1Init['group'];
			var overprintStep1 = rtnOptStep1Init['overprint'];			

			displayLightbox_question(
				'請問您是否屬於：'+WIUtil.jobInfoHandler.getDescription(jobClassStep1,groupStep1)
				, function(){// step1 click yes
					closeLightbox_jobClass(jobClassStep1,groupStep1,overprintStep1);
				}
				, function(){// step1 click no
					var rtnOptStep2Init = {jobClass:'2', group:'01', overprint:'01'};
					var jobClassStep2 = rtnOptStep2Init['jobClass'];
					var groupStep2 = rtnOptStep2Init['group'];
					var overprintStep2 = rtnOptStep2Init['overprint'];
					displayLightbox_question(
						'請問您是否屬於：'+WIUtil.jobInfoHandler.getDescription(jobClassStep2,groupStep2)
						, function(){// step2 click yes
							closeLightbox_jobClass(jobClassStep2,groupStep2,overprintStep2);
						}
						, unknownAction
						, unknownAction
					);
				}
				, unknownAction
			);

		}
		, lightboxForDisplayAdditionalFee: function(){
			

			var html = "";
			html += "<div style='text-align:center;margin-bottom:10px;'>附加費用=總繳保費 x 附加費用率(依不同繳費方式給予不同附加費用率)</div>";
			html += "<table style='border:3px solid #d7d7d7;width:500px;margin:0 auto;'>";
				html += "<thead style='background-color:#82ba32;color:#fff;'>";
					html += "<tr align='center'>";
						html += "<td>";
						html += "年金給付開始日前之各保單年度"
						html += "</td>";
						html += "<td>";
						html += "附加費用率"
						html += "</td>";
					html += "</tr>";
				html += "</thead>";

				html += "<tbody>";
					html += "<tr align='center'>";
						html += "<td>";
						html += "信用卡繳費<br/>(限國泰世華卡)"
						html += "</td>";
						html += "<td>";
						html += "1.5%"
						html += "</td>";
					html += "</tr>";

					html += "<tr align='center'>";
						html += "<td>";
						html += "信用卡以外之繳費管道"
						html += "</td>";
						html += "<td>";
						html += "1.2%"
						html += "</td>";
					html += "</tr>";
				html += "</tbody>";
			html += "</table>";
			var opts = {
				type:'json'
				, title:'什麼是附加費用？'
				, disaplyServiceLine:true
				, columns:[
					{type:'span', isPosLeft:true, value:html}
				]
			};
			WIUtil.lightbox(opts);
		}
		, lightboxForDisplayCreditCardIssuers: function(){
			var countByOneRow = 5;
			var oTbody = $('<tbody/>');
			var oTr;
			for(var i=0;i<creditCardIssuers.length;i++){
				if(i==0||i%countByOneRow==0){
					oTr = $('<tr/>').attr('align','center');
					oTbody.append(oTr);
				}
				var ele = creditCardIssuers[i];
				oTr.append($('<td/>').html(ele.bankName));
			}
			var opts = {
				type:'json'
				, title:'目前配合之發卡機構'
				, disaplyServiceLine:true
				, columns:[
					{type:'span', isPosLeft:true, value:$('<table style="border:3px solid #d7d7d7"/>').append(oTbody)}
					, {type:'span', value:'<font size="2px;">'+creditCardIssuersTips+'</font>'}
				]
			};
			WIUtil.lightbox(opts);
		} 
		, autoFixIframeHeight: function(opts){
			if(!opts){
				return;
			}
			var id = opts['id'];
			if(!id){
				return;
			}

			var limitCountByWaiting = opts['limitCountByWaiting']||0;
			var intervalTime = opts['intervalTime']||500;

			var keepHeight = 0;
			var idOfSetinterval;
			var executeCounts = 0;

			idOfSetinterval = setInterval(function(){

				try{
					var oIframe = document.getElementById(id);
					var changeHeight = oIframe.contentWindow.document.body.scrollHeight;
			    	if(keepHeight==changeHeight){
			    		executeCounts++;
						if(limitCountByWaiting>0 && limitCountByWaiting==executeCounts){
				    		clearInterval(idOfSetinterval);
				    	}
			    		return;
			    	}
	
					oIframe.style.height=changeHeight+'px';
					var newHeight = oIframe.contentWindow.document.body.scrollHeight;
					keepHeight=oIframe.contentWindow.document.body.scrollHeight;
	
				}catch(error){
				}

			}, intervalTime);

		}
		, createFlowStep: function(opts){
			
			if(!opts){
				return;
			}

			var id = opts['id'];
			if(!id){
				return;
			}

			var flowSteps = opts['flowSteps'] || [];
			var flowIndex = opts['flowIndex']||1;
			var flowAry = [];

			for(var i=0;i<flowSteps.length;i++){
				flowAry.push({'label':flowSteps[i]});
			}

			var showFlowStepDiv = $('#'+id);
			for(var i=0;i<flowSteps.length;i++){
				var oDiv_flowStep = $('<div/>');
				if(i==flowIndex){
					oDiv_flowStep.addClass('on');
				}
				oDiv_flowStep.html((i+1)+'. '+flowAry[i].label);
				showFlowStepDiv.append(oDiv_flowStep);
			}

		}
		, showCoverPage: function(){
			this.lightbox({type:'html',html:'<span/>',canClose:false});
		}
		, showDataLoading: function(){

			var cssRectangle = {'position': 'relative', 'display': 'inline-block', 'margin-left': '6px', 'width': '6px', 'height': '20px', 'background': '#4394bd'};
			var cssRectangleWhite = {'background': '#fff', 'opacity': '0', 'margin-left': '0px'};

			for(var k in cssRectangle){
				if(!cssRectangleWhite[k]){
					cssRectangleWhite[k]=cssRectangle[k];
				}
			}

			var cssTextDot = {'display': 'inline-block','margin-right': '2px'};

			var dataLoaderDiv = $('<div/>').css({'position': 'relative', 'width': '100%', 'margin': '20px 0px'}).append(
					$('<div/>').css({'position':'relative', 'margin':'0px auto', 'width':'650px', 'height':'283px'})
						.append(
							$('<div class="cloud-small-1"/>').css({'position': 'absolute','top': '30px','right': '68px','width': '101px','height': '68px','background-image': 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGUAAABECAMAAACvUgtuAAAANlBMVEV2veH///92veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veHVbuWaAAAAEXRSTlMAABAgMEBQYHCAj5+vv8/f7/4ucL8AAAHFSURBVFjDvdlZkoUgDAXQMIvIcPe/2f7o9lX7nKIMdwOnkBTEQGJE6C7ShQgAQImzpcfhKG7BJiXo5orN2CfqpoqKOM7cULEFZ0m6leJwkaLbKB5ow1wpDmjEXCgGt8myVpH5XsFSq8zgxNQpioUg1ymBp8DVKMylAIm0j79bmJZJPVM8V8G2SJJ7oiS8TTZsRaEii2QqtkbZH6Qniq9SdkfPibKgkpEcJVYqSEMU+CEK1BAlXirK+iUWNF3MlyJdQqvMZ8pU0C75WFEJTaOPFF3aIpgOFIvW8Xul+Ur+1/KqsDqWp6eMMWarzOiUNMmPotAvxa9KQM8kKYQQJNE3RQsh7vvu6nNAClF9NTKqWgjK3RU4Qf0R5CEK7BAlDFHyEAVUhihxiDINUdQQZcQni6wJQosuoP9iFBGp3sUcBGu0U7sUQf2Zae0tXdfv9emTbemJfHp+2edmLtPX/4vp0DIFtf8Xk3aO7dqAGJxkzJPvS6Kk7zvxxWz8jil6s5vF0RuF3GXlZU1EZj2fSlBvXxP0xTbFv0mIct57b2reLOR8WqINX0aI9OGRHZjTZK5CpMLX9mTPNvgKERm/jjTyMr14f/kB4kMuQ8xGl0gAAAAASUVORK5CYII=)'})
						)
						.append(
							$('<div class="cloud-small-2"/>').css({'position': 'absolute','top': '140px','left': '128px','width': '61px','height': '38px','background-image': 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAD0AAAAmCAMAAABArWODAAAAM1BMVEV2veH///92veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veHALddEAAAAEHRSTlMAABAgMEBQYICPn6+/z9/vNiZ63QAAAPFJREFUSMfF1kmShSAQRVHApJEu3/5XW4NvGDZIO6g7NU6gIoIQ5ZQNDADZm/sFee3DOsZZNmOaEm4FNaCJ8Sipbv3GV97SCYX2Tu3wGXvd0IpRK1JVW9RjW9MBrfSn1jo3NauiNu1xAQCuoLeIzvitidFdtA+tBjCATDcdMZi9aA3M8EP7cQ06NU/oeGg7MzSgpRCCMubycmyiH9MmRyf6lqz9DDp0XtL4L52X9L703LTyzoNcmG/e5Py3xvRboZRm8W+NGR8L1e7Jq8ru/z4CHCUASPtWPTucm4N1ZlPnP49N18njubcFAEhOvXZgudIfQT1hCAU5PzMAAAAASUVORK5CYII=)'})
						)
						.append(
							$('<div/>').css({'position': 'absolute','top': '30px','left': '190px','width': '250px','height': '152px','background-image': 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPoAAACYCAMAAAD6DgReAAAANlBMVEV2veH///92veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veF2veHVbuWaAAAAEXRSTlMAABAgMEBQYHCAj5+vv8/f7/4ucL8AAASkSURBVHja5d3ZlqsgEAVQZJ6h/v9n70Pn2hkc0IAt1HnPSnYQFYWCkCvChHEhwpwQrBaU/EWmORewlU+wmOgkHZfObITNBE1HpFO14/6Jl6PRmc1QmHRh07enMwdHkg0dhE5NhoNJagi6THAigXdPpx5OxnROlxlOJ/Ke6Ra+SVbd0mmEL+M6pfMEXyfQHuk8Q4VE2h+9jryxvQm9lrytvQW9nrypvQGdVZQDxI7o31/VLrrG1ad7qBzdC11D9fA+6Ly+HBLtgU5TAzr4HugWmkTcn87byNsc8nXpoRG9yaOLqnTVSg6Z3YgulLEhBG+MmH9WakZvcWNzis7065GdnGzb6ADA7kBXSz06W9ay0Vs0+2G6WgUGaBr63M9CCMEaKS6ks8a+rZM8lQtvLKOV19B1/jM5rH+1V83p1MFNky1rSq89EK98GmTt6PeWA4Cljei3lx9+YVNMd9BBDr20KKVr6CJZVKezDJ1E16YH6CauLl0CjGcvoycY0F5EVwAD2ovooTM62Fp0Bt1FVaLr/uiZ16GH/uglL6dL6NBjbA0675K+/5KygK76pIcKdNMnffcsPzA9fU/3MGazF9BDr/SIl77zWn6XLvqV7wxjdujUQcfJX9Blhq4jz9Kph87jTtJ56l2+fWlfp6sM/YedoWsYIeoE3Q0h3xy6rtAHkW8O35bpdhD55nluka5gmBykC8BKZxkGSwxG8RJ6hCHzmNe4RTcwbLLjW3QOQyeIdXqAwRPYCl3B+HlUw3inJwR0SHyBbgBH1Cc9IaGDe6crQBNHX+kRDx0ifaZzwBT3THeA004IybjooGe6AGzh/+kWHT3RBz2io4N90AFh+DRNE8KuDgBhmqZpkJcORyOmacJ2VX9q9vEfUqw2O55R28c9HcEph0zR0kHhpXu89IyXDhwvXeOlW7z0gJeeMA7XH8F6Dw8ACJ9PzXSNly7w0gliesBL13jpHKk8YJpY8DZgRzSd5C2mz/IENSJRTJpbDB1tTnRxIrIZVE+xE0E2hWoOn4aeEb55vE/jrYAoi55nRntk8kxnOkU2jco8rYKQ6Bp9Gm55X3GjTz3VDq2W9LbOjePp7uJ9dSOaK5z9XNOK5KYuLq1kRmHPbHH9OgJ75itVC+Tw5zq5Wqti8PN8VhsVSmgY+mjfLskz7mPKyPeqEfFBb+w8LSi/pQfs8VmXVR47sYH63ZucFdeb6wqf9n7r7wL2oprRVMVuOjE1W0+VvTi+IQLT8fQffV0n/qlGIVceskXNzu77Iu3HlT46zW9z8+N+iyV//NTkNftyeysmlHlEC35BfYusC0s8hvdKklz8/6VS0Ga7+DUr0JYMJYTIcBx+2QaGJ4/5uHlOgjDXTBNu6wtei65cvXfjqZKEnhLC7conw2vnpMrnFfe5jb3qbVt5YrDzfxtOptzrh3Mwcql3CuNf/6fo9fldiyvu2HlwsPO2MQ8VPydQIXZ6LRdCG2O0EF9u51hzs9JDgx3fbk/5v9inlRTf8iZByFj0wmrDSREyHJ0Qttvy94A3oBNCVdi6BAtChqUTQtjyRfij2t2AdEII4cqG31N+8EYycqv80v8BAQvj3IeH/OcAAAAASUVORK5CYII=)'})
								.append(
									$('<div class="loader-bar">').css({'position': 'absolute', 'bottom': '40px', 'left': '26px'})
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
										.append($('<span class="rectangle"/>').css(cssRectangle).append($('<span class="white"/>').css(cssRectangleWhite)))
								)
						)
						.append(
							$('<div class="text text_18 bold"/>').css({'position': 'absolute','bottom': '50px','width': '100%','text-align': 'center','font-size': '20px','color': '#fff','display': 'inline-block'})
								.append($('<div class="main"/>').css(cssTextDot).html('資料連線處理中'))
								.append($('<div class="dot"/>').css(cssTextDot).html('.'))
								.append($('<div class="dot"/>').css(cssTextDot).html('.'))
								.append($('<div class="dot"/>').css(cssTextDot).html('.'))
						)
					);

			this.lightbox({type:'html',html:dataLoaderDiv,canClose:false});

			dataLoaderDiv.parent('.lightbox-wrap').removeClass('lightbox-wrap');

			var animateCloud = function() {
				var t = dataLoaderDiv.find(".rectangle .white");
				for (var n = 0; n < t.length; n++) {
					var r = $(t[n]);
						TweenMax.to(r, .4, {
						alpha: 1,
						ease: Quad.easeInOut,
						repeat: -1,
						yoyo: true,
						repeatDelay: .3,
						delay: n * .1
					})
				}
				var i = dataLoaderDiv.find(".cloud-small-1");
				TweenMax.to(i, 5, {
					y: 20,
					ease: Quad.easeInOut,
					repeat: -1,
					yoyo: true
				});

				var s = dataLoaderDiv.find(".cloud-small-2");
				TweenMax.to(s, 6, {
					y: 20,
					ease: Quad.easeInOut,
					repeat: -1,
					yoyo: true
				});
			};

			var animateText = function() {
				var t = dataLoaderDiv.find(".text .dot");
				for (var n = 0; n < t.length; n++) {
					var r = $(t[n]);
					TweenMax.to(r, .05, {
						alpha: 0,
						ease: Quad.easeInOut,
						repeat: -1,
						yoyo: true,
						repeatDelay: .3,
						delay: n * .1
					});
				}
			};

			animateCloud();
			animateText();

		}
		, showDataLoadingForWI: function() {

			var body = $('body');

			var outter = $('<div class="wbis-main" />').css({'position': 'relative', 'z-index':'3000'})
							.append($('<div class="bg" />').css({'position': 'fixed', 'width': '100%'
										,'height': '100%', 'top': '0', 'left': '0', 'cursor': 'pointer'
										,'background-image': 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA/IAAAVUAQMAAABJObGyAAAAA1BMVEUAAACnej3aAAAAAXRSTlOZyTXzhgAAAMBJREFUGBntwQENAAAAwiD7p34ON2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAApwKqHgABycLWAQAAAABJRU5ErkJggg==)'}))
							.append($('<div class="lightbox-wrap" />'))

			var dataLoaderDiv = $('<div/>').css({'position': 'relative', 'width': '100%', 'margin': '20px 0px'}).append(
						$('<div/>').css({'position':'relative', 'width':'650px', 'height':'283px'}).append(
							$('<div />').css({'position': 'absolute','left': '110px', 'bottom': '80px', 'width': '400px','height': '365px','background-image': 'url(data:image/png;base64,R0lGODlhmQFqAff/ANb/yKB/U8rzvOP/2uC7lKf2/7znrXVYMMqlfuX/3drNu/X/8aSEWrqaec31wPHr5Pr/+a2Qa/Pl2NHBrLL3/9T9xt7SwuD/1sy7o+j/4dGth/n+/82phItsQ7WVdKn2/+zl3MKtkfj/9uL/2IJkO/Xx7P7//vn28vz/+633/73orubIqaqMZdSwisz1vv3//KGBVtHuxp19Ufb+9NTEsLade+ng1uDUxeL13Obd0fT+/8Cqjd//1Nz/0Pz///H+/+H8/9f/ydj/y9v/ztD5wuz/5s3twsnsvb/psenRt+7/6ci1nOTazd65ktX7/836/8X5/+766eT/26uOaNH6/8r0vMH5/8jyur34//P/7+X8/9n7/9D1xLn4/+39/6eJYebMsvH/7LOZdZR0St7/09n/zO/p4cezmf7+/ej9/9f+ysTutev/5Mbruc73wNL8xKaIXrCVcL7or8n6/7mhgN3/0rznrtnx0XtdNdi0jer45d78//H67f7///ny68imgtr/zezcytfyzrb4/9H6w9z7/////9zz1dbwzeHWyPz7+fPu6MWjgeb54O//6tS1lJl5Te3axcbwuOH42X9hOPf08KWFY/79+8LttNT1yXhbMtn6zrylhsWvlM6rh+j3472miP7+/v///vT78cHrssLptMKgftu2kNbItfP98Nb/yZBxRrKTcez55+b24OK+meP/29TvyuPBnvL67+C8lfH/7XxeNr+efHdaMuH/19C/qbeXdvr39d3BpIJmQP38/MTqtpt+WMumf76oisGmisv0vbukhN/JseX53ohpP8Xvts++qOj64srzvd741vv5+HZZMZR2UfD87Mr0u9r30OnWw8zyv8q3n4ZnPsvzvtf2zNz60d/z2Pz699X4yYZoQv/+/ta7n5+AXfDeytq8npd5VfL87tr7z+/567iffrqig9z30nhbNHlcM/Hh0Nv/z6+Sbt331NS3l7OUcvfu5Nz80vfw6I5wS9P1x+P528nvvNf5zN781L+ihdr8zv///yH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQyIDc5LjE2MDkyNCwgMjAxNy8wNy8xMy0wMTowNjozOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo5Zjk3OGQxNC0xMjc4LTcyNDEtOGRiMi01ODU1ZTkzZTJjNzUiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NjIwRTkwOTYwQTFCMTFFOEE0QUJEOUUyRkJGRTQ5QjciIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NjIwRTkwOTUwQTFCMTFFOEE0QUJEOUUyRkJGRTQ5QjciIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjgzQkUxMDk4MDBDQTExRThBNzAxRDUyQkMyODZEMjY1IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjgzQkUxMDk5MDBDQTExRThBNzAxRDUyQkMyODZEMjY1Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+Af/+/fz7+vn49/b19PPy8fDv7u3s6+rp6Ofm5eTj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66trKuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6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)'})
							.append(
								$('<span/>').css({'position': 'absolute','bottom': '-30px','width': '100%'
										,'text-align': 'center','font-size': '20px','color': '#fff'
										,'display': 'inline-block'}).text("")
									.append($('<img class="rotateCircle" />').css({'position': 'relative'}).attr({'src': "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAMAAAAM7l6QAAACc1BMVEUAAAA0oBPC6ARuvA5BpxKd1gkJixg2oRN6wwwhlxXp/AFwvg0QjhdEqBLM7QOq2wcAfxqd1Qiy3wZFqRLS8ANrvQ6FyQtgtw+QzwoUkBc6pBMAgRp+xQwxnxS/5gVTsBCd1gjZ9AILjBhitw+OzgoelRbS8APb9AIUkRee1ggVkRZRrxCf1ggUkBdTrxHc9QIJixhmuQ+KzArn+gEznxQvnxTB5gW95gWX0AksnRU2oRNzwA265AbE6AX//wAilxZAphKw3wfO7gMIihhlug+Lywro+wEEiBlvvg6Bxwzr/QAqmxU4oxO44gbG6gQUkBdTsBGd1Qnc9QJXshAXkhcRjxdPrhHf9gLZ8wI6pBPI6wSp2gjj+AEmmRU8pBO04QbK7ARLrBGl2QhctRCU0ArV8gPj+AIqmhW44gbG6wT//wAmmBWz4QfK7QSX0AmGygvk+QHm+gGq3Afk+QGr2wcjlxaw3wcIixhnug+JywtVsBFQrhHd9QLa9ALg9gLW8gMRjxeX0Qnp+wELjBgFiRjk+QEIihgdlRYZkxY6pBNUsRC24gbS8APh9wIVkRcOjhdgtw+t3QcAfhsglhYomhUmmRUjmBUzoBQvnhQ2oRNEqBI+phJNrRFZsxBctQ96wwyHyguOzgqk2Qig1wiy4Ae65AbB5wW95gXI6wTF6QTO7gPV8gL//wDr/QAAgxornBVHqhJQrhFKqxFvvg5qvA5nug5ywA2EyQuByAuU0QqR0Aqa1Amn2gip2wfK7ATM7QPf9gLd9QLa9ALY8wJkuQ9svQ52wg3m+gF3wQ1+xgx9xQyKywuv3wcAghosnRWLzAqX0wlu6HajAAAAgHRSTlMACAgE/v67DfO/vJCNSg0L88jAv768vLq6oJKRkY+PjIyMT09PTU1FNzcfHx/7+/v39/f39PT09PPy8vLy8vLu7u7u6+vr69/f39/e3t7e2tra2snIyMjIyL6+vLi2tra2oaGgoKCgk5OTk5GRkI+OjlFOTkxGRkVFRTc3NzcgHxHibGUAAAIsSURBVCjPZdP3XxJxHMfxD2BsyL3LrZW2995777333nsdKCICAiFUYCJIZZBFimnKEA1bNv6kPt8DkqPXr8973+Med/eFWNKKK8J1i+YkJ6/mim/zgNno68Lp8vb2t7InP2tqaqdwi1nx+uiUQvElwu+Qa6urcyaM6IPdWi2yPMqoOmrnuJg+3Nbfr1Uo5HI5YTLW6Shqc9Qf7xkIhcg8xmRMNTTsoO/PPjk4OBAi81XCc5fy8rjLcYxaV5fDQi7XuN20H7jKBoxTzKUoClWpLAOQpms0GvTJRRyIxhFPpFUp4EFF0OVCdxdBXGJEo9FovgkXg+guTTo7nlkCNLPZdB72tQUCgeCycmBUtthsMpkaBbCpDQscwTFjftDUiK2HhW9IZyGh0++xX3Nh1ivS2EQe84w0E2a/Jv3PT0kzYMFL0plEzn1Omgcb1aTDiY92SEXaAKlqtdPpXHqDyZIlVqtVpdoLF5zO4WGDYT/ztaRZLElJVmsu3DIYDH6/z1EYzwVNHR5ygQSkqQa/z+doHVU48kkKJn1A91jSeADXcIraJ8su5dBYkvWivh69wyMhv8MxRyvRT/aVmfn5IlHGCn0z7U1HWYBVpdDaa2/p7rENdYa7Pkd8VyXQjd/a9wf1R0v3N9vQx7C3S9+MvuU+QNRTZDT3EO700vPt9+BfVSd67b/x3t9tXyOsP17JOESl2dNiHPZOzSphJZ6yu5cz1/L5/PlrMkR3eBDtL0C0FN72kurUAAAAAElFTkSuQmCC"}))
									.append($('<label>').css({'bottom':'10px', 'position': 'relative', 'padding': '0px 0px 0px 10px'}).text('努力加載中，請稍候...'))
							)
						));
			
			var i = dataLoaderDiv.find(".rotateCircle");
			TweenMax.to(i, 0.5, {
				rotation:360,
				ease:Linear.easeNone,
				repeat: -1,
			});
		
			$(outter.find('.lightbox-wrap')).append(dataLoaderDiv);
			body.append(outter);

			// select outtest frame to locate view 
		    var contentH = $(".lightbox-wrap").height();
	    	_topHeight = $(top).height();
	    	_topWidth= $(top).width();
	    	$(".lightbox-wrap").css('position','fixed').css('top',(_topHeight-contentH)/2).css('left',(_topWidth-700)/2);

		}
		, closeCoverPage: function(){
			if(self!=top){
				if(parent && parent.window && parent.window.closeLightbox){
					parent.window.closeLightbox();
				}else{
					if(window && window.closeLightbox){//TODO
						window.closeLightbox();
					}
				}
			}
		}
		, displayMessage: function(opts){
			var msg = opts['msg'];
			if(!msg){
				return;
			}
			var canClose = opts['canClose']!==false;
			var title = opts['title']||'訊息內容';
			var oDiv_closeIcon = $('<div/>');
		    var oDiv_header = $('<div/>').addClass('header').append($('<div/>').addClass('title').html(title));
			var oDiv_body = $('<div/>').css({width:'100%'}).addClass('body')
								.append($('<div/>').html(msg).css({'font-size':'20px','margin':'20px'}))
								.append(oDiv_closeIcon);
			if(canClose){
				oDiv_closeIcon.addClass('close').append('<a href="javascript:;" onclick="closeLightbox(true);"></a>');
			}

			this.lightbox({
				type:'msg'
				, canClose:canClose
				, html:$('<div/>').append(oDiv_header).append(oDiv_body)
				, msg:msg
			});

		}
		, scrollTop: function(v){

			if(self!=top){
				if(parent.window){
					$(parent.window).scrollTop(v);
					parent.window.resetLightboxOriScrollTop(v);
				}
			}else{
				$(window).scrollTop(v);
				window.resetLightboxOriScrollTop(v);
			}
		}
		/**
		 *	@public
		 *	@class 建立被保人區塊。
		 *	@param initOpt (Map)
		 *	@param initOpt.showBlockId (String) : 顯示的區塊 ID。
		 *	@param initOpt.relationData (Map) : 與被保人關係的下拉選單。
		 *	@param initOpt.maxBenePerson (int) : 被保人最大人數限制。
		 *  @param initOpt.legalrelation (String) : 被保人種類為法定繼承人。
		 *	@param initOpt.apcInfo (Map) : 要保人資訊
		 **/
		, InsdficiaryHandler: function(initOpt){
			var benecficiaryHandler = [];
			var _radioIndex_addInsdficiary=0;
			var _icheckboxClass = 'icheckbox';
			var _insdPerson = 0;
			
			var showBlockId = initOpt['showBlockId'];
			var relationData = initOpt['relationData'];
			var insdRelationData = initOpt['insdRelationData'];			
			var beneIdTypeData = initOpt['beneIdTypeData'];
			var insdIdTypeData = initOpt['insdIdTypeData'];
			var insdIdTypeNotCheckIDs = initOpt['insdIdTypeNotCheckIDs'];
			var insdIdTypeAllowEmpty = initOpt['insdIdTypeAllowEmpty'];
			var legalrelation = initOpt['legalrelation'];
			var insdInfo = initOpt['apcInfo']||{'defaultIsSame':false};
			var maxInsdPerson = initOpt['maxInsdPerson']||0;

			var getZipName = initOpt['getZipName'];
			
			var netinsrLv = initOpt['netinsrLv'];
			var apcId = '';
			var apcName = '';
			var apcBrdy = '';
			var lastYearDiff = parseInt(initOpt['lastYearDiff']);
			
			if(!showBlockId){
				return;
			}

			var showValue = function(v, dv, isIncludeWhitespace){
				var dvIsNotUndefined  = typeof dv != 'undefined';
				var rv = v;
				if(typeof v == 'undefined' || v===null){
					if(dvIsNotUndefined){
						rv = dv;
					}else{
						rv = '';
					}
				}
				if(dvIsNotUndefined && rv==='' && isIncludeWhitespace===true){
					rv = dv;
				}
				return rv;
			};

			var addOneRowData = function(opt){

				opt = opt||{};
				var isFirstRowData = opt['isFirstRowData'];
				var inputData = opt['inputData'];
				var hasData = typeof inputData != 'undefined';

				if(!isFirstRowData && maxInsdPerson!==0 && maxInsdPerson<_insdPerson+1){
					return;
				}
	
				var insdInfoDiv = $('<div/>').css('margin-top', '15px');
				var data = inputData||{'INSD_RLTN':'','INSD_ID':'','INSD_NAME':'','INSD_BRDY':''};
	
				insdInfoDiv.addClass('flowform');
	
				/*
				身分證字號
			 	*/
				var oInput_INSD_ID = $('<input type="text" name="INSD_ID" title="INSD_ID" maxlength="20" required style="margin-left:0px;width:110px;ime-mode:disabled">').change(function(){
					var obj = $(this);
					obj.val(obj.val().toUpperCase());
				});
				oInput_INSD_ID.val(showValue(data['INSD_ID']));
				/*
				姓名
			 	*/
				var oInput_INSD_NAME = $('<input type="text" name="INSD_NAME" title="INSD_NAME" maxlength="16" required style="width:170px"/>');
				oInput_INSD_NAME.val(showValue(data['INSD_NAME']));
				/*
				生日
				 */
				var theBrdy = showValue(data['INSD_BRDY']);
				var theBrdySplit = theBrdy.split("-");
				var currentYear = new Date().getFullYear();
				var oInput_INSD_BRDY_Y = $('<select name="INSD_BRDY_Y" required style="width:80px"></select>').change(function(){
					var $yearSelect = $(this);
					var $monthSelect = $yearSelect.parent().next().children("select");
					var theDate = new Date($yearSelect.val(), $monthSelect.val(), 1);
					if (!isNaN(theDate)) {
						theDate.setDate(theDate.getDate()-1);
						var $dateSelect = $monthSelect.parent().next().children("select");					
						var oriDay = $dateSelect.val();
						$dateSelect.children().remove();
						for (var i = 1; i <= theDate.getDate(); i++) {
							$dateSelect.append('<option value="'+i+'">'+i+'日</option>');
						}
						$dateSelect.val(oriDay);
					}
				});
				
				var oInput_INSD_BRDY_M = $('<select name="INSD_BRDY_M" required style="width:80px"></select>').change(function(){
					var $monthSelect = $(this);
					var theYear = $monthSelect.parent().prev().children("select").val();
					var theDate = new Date(theYear, $monthSelect.val(), 1);
					if (!isNaN(theDate)) {
						theDate.setDate(theDate.getDate()-1);
						var $dateSelect = $monthSelect.parent().next().children("select");
						var oriDay = $dateSelect.val();
						$dateSelect.children().remove();
						for (var i = 1; i <= theDate.getDate(); i++) {
							$dateSelect.append('<option value="'+i+'">'+i+'日</option>');
						}
						$dateSelect.val(oriDay);
					}
				});
				
				var oInput_INSD_BRDY_D = $('<select name="INSD_BRDY_D" required style="width:80px"></select>');
				
				for (var i = currentYear -lastYearDiff ; i >= 1911 ; i--) {
					oInput_INSD_BRDY_Y.append('<option value="'+i+'">'+i+'年</option>');
				}
				for (var i = 1 ; i <= 12 ; i++) {
					oInput_INSD_BRDY_M.append('<option value="'+i+'">'+i+'月</option>');
				}
				for (var i = 1 ; i <= 31 ; i++) {
					oInput_INSD_BRDY_D.append('<option value="'+i+'">'+i+'日</option>');
				}
				
				oInput_INSD_BRDY_Y.val(parseInt(theBrdySplit[0]));
				oInput_INSD_BRDY_M.val(parseInt(theBrdySplit[1]));
				oInput_INSD_BRDY_D.val(parseInt(theBrdySplit[2]));
				/*
				與要保人關係
				 */
				_radioIndex_addInsdficiary++;
				var radioGroupName = 'insdRadioGroup'+_radioIndex_addInsdficiary;
				var radio_rltn1 = $('<input name='+radioGroupName+' type="radio" style="position: absolute; opacity: 0;filter: alpha(opacity=0); ZOOM: 1;" value="1">');
				var radio_rltn2 = $('<input name='+radioGroupName+' type="radio" style="position: absolute; opacity: 0;filter: alpha(opacity=0); ZOOM: 1;" value="2">');
				var div_rltn1 = $('<div class="iradio"></div>')
				.append(radio_rltn1)
				.append('<ins class="iCheck-helper" style="border-bottom: 0px; position: absolute; padding-bottom: 0px; margin: 0px; padding-left: 0px; width: 100%; padding-right: 0px; display: block; background: #fff; border-top: 0px; top: 0%; border-right: 0px; padding-top: 0px; left: 0%; opacity: 0;filter: alpha(opacity=0); BORDER-LEFT: 0px; zoom: 1; height: 100%;"></ins>');
				var div_rltn2 = $('<div class="iradio"></div>')
				.append(radio_rltn2)
				.append('<ins class="iCheck-helper" style="border-bottom: 0px; position: absolute; padding-bottom: 0px; margin: 0px; padding-left: 0px; width: 100%; padding-right: 0px; display: block; background: #fff; border-top: 0px; top: 0%; border-right: 0px; padding-top: 0px; left: 0%; opacity: 0;filter: alpha(opacity=0); BORDER-LEFT: 0px; zoom: 1; height: 100%;"></ins>');
				
				var oSelect_RELATION = $('<select name="INSD_RLTN" required style="width:170px"></select>');
					
				var defaultValueApcIdTypeData = undefined;
				if (inputData != undefined && 'defaultValueApcIdTypeData' in inputData) {
					defaultValueApcIdTypeData = inputData['defaultValueApcIdTypeData'];
				}
				
				if (defaultValueApcIdTypeData != undefined) {
					apcId = defaultValueApcIdTypeData['APC_ID'];
					apcName = defaultValueApcIdTypeData['APC_NAME'];
					apcBrdy = defaultValueApcIdTypeData['APC_BRDY'];
				}
				
				div_rltn1.click(function(){					
					div_rltn1.addClass('checked');
					
					oInput_INSD_ID.attr('readOnly', true).attr('legalbene', true).val(apcId);
					oInput_INSD_NAME.attr('readOnly', true).attr('legalbene', true).val(apcName);
					var theBrdySplit = apcBrdy.split("-");
					oInput_INSD_BRDY_Y.attr('readOnly', true).attr('disabled', true).val(parseInt(theBrdySplit[0]));
					oInput_INSD_BRDY_M.attr('readOnly', true).attr('disabled', true).val(parseInt(theBrdySplit[1]));
					oInput_INSD_BRDY_D.attr('readOnly', true).attr('disabled', true).val(parseInt(theBrdySplit[2]));
					
					div_rltn2.removeClass('checked');
					oSelect_RELATION.attr("disabled", true).attr('readOnly', true).val("1");
				});
	
				div_rltn2.click(function(){
					div_rltn1.removeClass('checked');
					
					oInput_INSD_ID.attr('readOnly', false).removeAttr('legalbene').val('');
					oInput_INSD_NAME.attr('readOnly', false).removeAttr('legalbene').val('');
					var currentDate = new Date();
					oInput_INSD_BRDY_Y.attr('readOnly', false).attr('disabled', false).val(currentDate.getFullYear()-lastYearDiff);
					oInput_INSD_BRDY_M.attr('readOnly', false).attr('disabled', false).val(currentDate.getMonth()+1);
					oInput_INSD_BRDY_D.attr('readOnly', false).attr('disabled', false).val();
					oInput_INSD_BRDY_Y.change();
					div_rltn2.addClass('checked');
					oSelect_RELATION.attr('readOnly', false).attr("disabled", false);
				});
				
				oSelect_RELATION.append('<option value="" selected>請選擇</option>');
				
				if(insdRelationData){
					for(var key in insdRelationData){
						oSelect_RELATION.append('<option value="'+key+'">'+insdRelationData[key]+'</option>');
					}
					if(data['INSD_RLTN'] == 1){
						div_rltn1.click();
					}else {
						
						div_rltn1.removeClass('checked');
						
						oInput_INSD_ID.attr('readOnly', false).removeAttr('legalbene');
						oInput_INSD_NAME.attr('readOnly', false).removeAttr('legalbene');
						var currentDate = new Date();
						oInput_INSD_BRDY_Y.attr('readOnly', false).attr('disabled', false);
						oInput_INSD_BRDY_M.attr('readOnly', false).attr('disabled', false);
						oInput_INSD_BRDY_D.attr('readOnly', false).attr('disabled', false);
						oInput_INSD_BRDY_Y.change();
						
						div_rltn2.addClass('checked');						
						
						oSelect_RELATION.attr('readOnly', false).attr("disabled", false).val(data['INSD_RLTN']);
					}
				}
				
				if (netinsrLv != '4') {
					div_rltn2.off("click");
				}
				
				var beneTitle1 = $("<span>").addClass("tt").append('<font>身故保險金</font>')
						.append('<a href=javascript:;" data-tooltip="享有賠償請求權之人，受益人限配偶、子女、父母、祖孫" data-my="left center" data-at="right center">受益人</a>')
						.append('<i class="icon-info2"></i>資料');
				var beneTitle2 = $("<span>").addClass("descr")
						.append('<div class="icheckbox">\
								<input type="checkbox" name="chk_getPreBeneData" style="position: absolute; opacity: 0;">\
								</div>帶出前次投保之受益人資訊');
				var beneTitle3 = $("<span>").addClass("rq").append('<font>*必填</font>');
				 
				var oTbody = $('<tbody/>');
				var oTr_deleteInsd = $('<tr/>');
				if(isFirstRowData!==true){
					oTr_deleteInsd.append(
						$('<td colspan="4" class="pd-10">').append(
							$('<div class="field-tt"/>')
								.append($('<i/>').addClass('icon-del'))
								.append($('<a href="javascript:;" style="padding-left:5px;">刪除此被保人</a>', {'data-my':'left center', 'data-at':'right center'}).click(
										function(){
											insdInfoDiv.remove(); 
											if(_insdPerson>0){
												_insdPerson--;
												}
											$("#aLink_addInsdficiary").parents("div[class=addrow]").show();
										}))
						)
					);
				} 
				

				var oTd_insdRelation = $('<td/>');
				if (_insdPerson == 0) {
					oTd_insdRelation.addClass('chooseClaimsType')
					.append($('<div/>').addClass('field-cont')
						.append('<label/>')
							.append(div_rltn1).append('<font>本人</font>')
					).append($('<div/>').addClass('field-cont')
						.append('<label/>')
							.append(div_rltn2).append('<font>其他</font>')
					).append($('<div/>').addClass('field-cont')
							.append($('<span class="iselect" style="width: 168px; margin-left: 0px;"/>').append(oSelect_RELATION).append($('<i style="z-index:1"/>')))
					);
				} else {
					oTd_insdRelation.addClass('chooseClaimsType')
					.append($('<div/>').addClass('field-cont')
							.append($('<span class="iselect" style="width: 168px; margin-left: 0px;"/>').append(oSelect_RELATION).append($('<i style="z-index:1"/>')))
					);
				}
				/*
				if (netinsrLv != '4') {
					div_rltn1.click();
					div_rltn2.attr("readonly", true).off("click");					
				}
				*/
				oTbody.append(oTr_deleteInsd);
				
				oTbody.append(
					$('<tr/>')
						.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i>與要保人關係</div>'))
						.append(oTd_insdRelation)
						.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>身分證字號或居留證號</div>'))
						.append($('<td/>').append(
								$('<div/>').addClass('field-cont').append(oInput_INSD_ID)
							)
						)
				)
				.append(
					$('<tr/>')
						.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i>姓名</div>'))
						.append($('<td/>').append(
								$('<div/>').addClass('field-cont').append(oInput_INSD_NAME)
							)
						)
						.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>生日</div>'))
						.append($('<td/>').append(
								$('<div/>').addClass('field-cont')
									.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_INSD_BRDY_Y).append($('<i style="z-index:1"/>')))
									.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_INSD_BRDY_M).append($('<i style="z-index:1"/>')))
									.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_INSD_BRDY_D).append($('<i style="z-index:1"/>')))
							)
						)
				)
				.append($('<tr/>')
						.append($('<td/>').attr('colspan', '4').addClass("fieldset-legend")
								.append(beneTitle1).append(beneTitle2).append(beneTitle3)
								.append($('<span/>').addClass("field-cont").attr('id','block_bene'+_insdPerson))
						)
				)
				.append($('<tr/>')
						.append($('<td/>').attr('colspan', '4')
								.append($('<div/>')
									.append($('<i/>').addClass('icon-plus'))
									.append($('<a/>').attr('href', 'javascript:;')
	      									.attr('id', 'aLink_addBeneficiary'+_insdPerson)
	      									.attr('data-tooltip', '可填寫一位受益人資料')
	      									.attr('data-my', 'left center')
	      									.attr('data-at', 'right center')
	      									.text('新增一位受益人')
	      							)
	      						)
	      				)
			    );
				
				insdInfoDiv.append(
					$('<table/>')
						.append('<colgroup><col style="width:142px"><col style="width:210px"><col style="width:140px"><col></colgroup>')
						.append(oTbody)
				);
				$("#block_insd").append(insdInfoDiv);
				oInput_INSD_BRDY_Y.change();
				$("#aLink_addBeneficiary"+_insdPerson).click(function(){
	                var currIdx = this.id.slice("aLink_addBeneficiary".length, this.id.length);
	                benecficiaryHandler[currIdx].add();
	            });
				
				benecficiaryHandler[_insdPerson] = new WIUtil.BeneficiaryHandler({'showBlockId':'block_bene'+_insdPerson, 'relationData':relationData, 'maxBenePerson':4, 'beneIdTypeData':beneIdTypeData,'beneIdTypeNotCheckIDs':["3"],'legalrelation':legalrelation
					, apcInfo:{
						'defaultIsSame':false
						, onChangeByBENE_ZIP_CODE: function(zipCode){
							return getZipName(zipCode);
						}
					}
				});
					
				var inputData;
				if (hasData) {
					inputData = [data];	
				}
				benecficiaryHandler[_insdPerson].loadData(inputData);
				
				_insdPerson++;
				if (_insdPerson == maxInsdPerson) {
					$("#aLink_addInsdficiary").parents("div[class=addrow]").hide();
				} else {
					$("#aLink_addInsdficiary").parents("div[class=addrow]").show();
				}
	        };
		return {
				 /**
				 *	@public
				 *	@class 載入被保人資料。
				 *	@param inputDatas (Array)
				 **/
				loadData: function(inputDatas){
					_insdPerson=0;
					$("#block_insd").empty();
					if(!inputDatas || inputDatas.length==0){
						addOneRowData({isFirstRowData:true});
						return;
					}
					for(var i=0;i<inputDatas.length;i++){
						addOneRowData({
							isFirstRowData:i==0
							, inputData:inputDatas[i]
						});
					}
				}
				/**
				 *	@public
				 *	@class 增加被保人輸入資料。
				 *	@param inputDatas (Map)
				 *	@param inputDatas.isFirstRowData (Boolean)
				 *	@param inputDatas.inputData (Map)
				 *	@param inputDatas.defaultValueRelation (String) : 若無指定「與要保人關係」預設值時，以 inputData 內的 RELATION 值為預設值。
				 **/
				, add: function(inputOpt){
					addOneRowData(inputOpt);					
				}
				, check: function(){
					var keyInIds = [];
					var hasSameId = false;
					var cntLegal = 0;

					var checkResult = '';
					var addMsg = function(msg){
						if(checkResult!=''){ checkResult += '<br>'; }
						checkResult += msg;
					};
					
					$("#block_insd > div[class=flowform]").each(function(idx, elem){
						var $elem = $(elem);
						var insdRltnRadio = $elem.find("input[name^=insdRadioGroup]:checked").val();
						var insdRltnValue = $elem.find("select").val();
						var insdId = $elem.find("input[name=INSD_ID]").val();
						var insdName = $elem.find("input[name=INSD_NAME]").val();
						var insdBrdy = $elem.find("input[name=INSD_BRDY]").val();
						if (insdRltnRadio == 2 && insdRltnValue == "") {
							addMsg("被保人"+(idx+1)+"未選取與要保人關係");
						}
						if(insdId == "") {
							addMsg("被保人"+(idx+1)+"未輸入被保人身分證字號");
						}
						if(insdName == "") {
							addMsg("被保人"+(idx+1)+"未輸入被保人姓名");
						}
						if(insdBrdy == "") {
							addMsg("被保人"+(idx+1)+"未輸入被保人生日");
						}
					});
					
					if(checkResult!=''){
						WIUtil.displayMessage({'msg':checkResult});
						return false;
					}
					var beneChecked = true;
					for(var idx in benecficiaryHandler) {
						beneChecked = beneChecked & benecficiaryHandler[idx].check();
						if (!beneChecked) {
							break;
						}
					}
					if (!beneChecked){ return false;}

					return true;
				}
				, loadBeneData: function(beneNo, inputData) {
					var intBeneNo = parseInt(beneNo);
					if (intBeneNo < benecficiaryHandler.length) {
						benecficiaryHandler[intBeneNo].loadData(inputData);
					}
				}
			};
		}
		/**
		 *	@public
		 *	@class 建立受益人區塊。
		 *	@param initOpt (Map)
		 *	@param initOpt.showBlockId (String) : 顯示的區塊 ID。
		 *	@param initOpt.relationData (Map) : 與被保人關係的下拉選單。
		 *	@param initOpt.maxBenePerson (int) : 受益人最大人數限制。
		 *	@param initOpt.beneIdTypeData (Map) : 受益人證件種類。
		 *	@param initOpt.beneIdTypeNotCheckIDs (Array) : 不檢核身份證號碼之受益人證件種類。
		 *  @param initOpt.legalrelation (String) : 受益人種類為法定繼承人。
		 *	@param initOpt.apcInfo (Map) : 要保人資訊
		 **/
		, BeneficiaryHandler: function(initOpt) {

			var _radioIndex_addBeneficiary=0;
			var _icheckboxClass = 'icheckbox';
			var _benePerson = 0;
			
			var showBlockId = initOpt['showBlockId'];
			var relationData = initOpt['relationData'];
			var beneIdTypeData = initOpt['beneIdTypeData'];
			var beneIdTypeNotCheckIDs = initOpt['beneIdTypeNotCheckIDs'];
			var beneIdTypeAllowEmpty = initOpt['beneIdTypeAllowEmpty'];
			var legalrelation = initOpt['legalrelation'];
			var apcInfo = initOpt['apcInfo']||{'defaultIsSame':false};
			var maxBenePerson = initOpt['maxBenePerson']||0;
			var beneIdType = initOpt['beneIdType'];
			var isNeedBeneInfo = initOpt['isNeedBeneInfo']||false;

			if(!showBlockId){
				return;
			}

			var showValue = function(v, dv, isIncludeWhitespace){
				var dvIsNotUndefined  = typeof dv != 'undefined';
				var rv = v;
				if(typeof v == 'undefined' || v===null){
					if(dvIsNotUndefined){
						rv = dv;
					}else{
						rv = '';
					}
				}
				if(dvIsNotUndefined && rv==='' && isIncludeWhitespace===true){
					rv = dv;
				}
				return rv;
			};

			var block_bene = $('#'+showBlockId);

			var addOneRowData = function(opt){

				opt = opt||{};
				var isFirstRowData = opt['isFirstRowData'];
				var inputData = opt['inputData'];
				var hasData = typeof inputData != 'undefined';

				if(!isFirstRowData && maxBenePerson!==0 && maxBenePerson<_benePerson+1){
					return;
				}

				var defaultValueRelation = opt['defaultValueRelation'];
				var defaultValueBeneIdTypeData = opt['defaultValueBeneIdTypeData'];
				var beneInfoDiv = $('<div/>').css('margin-top', '15px');
				var data = inputData||{'BENE_NAME':'','BENE_ID_TYPE':'','BENE_ID':'','RELATION':'','BENE_PRIO':'','BENE_RATO_BASE':'','BENE_RATO_UP':'','BENE_BRDY':'','BENE_NATION':''};

				beneInfoDiv.addClass('flowform');

				_radioIndex_addBeneficiary++;
				var radioGroupName = 'radioGroup'+_radioIndex_addBeneficiary;

				var benePrio = data['BENE_PRIO'];
				var benePatoBase = data['BENE_RATO_BASE'];
				var beneRatoUp = data['BENE_RATO_UP'];
				var beneNation = data['BENE_NATION'];
/*
				獲得理賠方式 － 比例
*/
				var input_rate = $('<input type="text" name="rate" title="rate" style="width:50px;ime-mode:disabled" disabled>');
				var radio_rate = $('<input name='+radioGroupName+' type="radio" style="position: absolute; opacity: 0;filter: alpha(opacity=0); ZOOM: 1;">');
				var div_rate = $('<div class="iradio"></div>')
						.append(radio_rate)
						.append('<ins class="iCheck-helper" style="border-bottom: 0px; position: absolute; padding-bottom: 0px; margin: 0px; padding-left: 0px; width: 100%; padding-right: 0px; display: block; background: #fff; border-top: 0px; top: 0%; border-right: 0px; padding-top: 0px; left: 0%; opacity: 0;filter: alpha(opacity=0); BORDER-LEFT: 0px; zoom: 1; height: 100%;"></ins>');

/*
				獲得理賠方式 － 順位
*/
				var input_order = $('<input type="text" name="oder" title="oder" style="width:50px;ime-mode:disabled" disabled>');
				var radio_order = $('<input name='+radioGroupName+' type="radio" style="position: absolute; opacity: 0;filter: alpha(opacity=0); ZOOM: 1;">');
				var div_order = $('<div class="iradio"></div>')
						.append(radio_order)
						.append('<ins class="iCheck-helper" style="border-bottom: 0px; position: absolute; padding-bottom: 0px; margin: 0px; padding-left: 0px; width: 100%; padding-right: 0px; display: block; background: #fff; border-top: 0px; top: 0%; border-right: 0px; padding-top: 0px; left: 0%; opacity: 0;filter: alpha(opacity=0); BORDER-LEFT: 0px; zoom: 1; height: 100%;"></ins>');

					div_rate.click(function(){
						div_rate.addClass('checked');
						input_rate.attr('checked', true);
						input_rate.attr('disabled', false).focus();
	
						div_order.removeClass('checked');
						input_order.attr('disabled', true).val('');
					});
	
					div_order.click(function(){
						div_rate.removeClass('checked');
						input_rate.attr('disabled', true).val('');

						div_order.addClass('checked');
						radio_order.attr('checked', true);
						input_order.attr('disabled', false).focus();
					});

/*
					預設「獲得理賠方式 － 比例」
*/
					div_rate.addClass('checked');
					div_order.removeClass('checked');
					input_rate.attr('checked', true);
					input_rate.attr('disabled', false).val('');
					input_order.attr('disabled', true);
					
					if(_benePerson === 0){
						input_rate.val('100');
					}
					
				/*
				生日
				 */
				var oInput_BENE_BRDY_H = $('<input type="hidden" name="BENE_BRDY" value="" style="width:350px;ime-mode:active;"/>');
				var theBrdy = showValue(data['BENE_BRDY']);
				var theBrdySplit = theBrdy.split("-");
				var currentYear = new Date().getFullYear();
				var oInput_BENE_BRDY_Y = $('<select name="BENE_BRDY_Y" required style="width:80px"></select>').change(function(){
					var $yearSelect = $(this);
					var $monthSelect = $yearSelect.parent().next().children("select");
					var $dateSelect = $monthSelect.parent().next().children("select");	
					if($yearSelect.val() !== ''){
						$monthSelect.children().remove('option[value=""]');
						
						var theDate = new Date($yearSelect.val(), $monthSelect.val(), 1);
						if (!isNaN(theDate)) {
							theDate.setDate(theDate.getDate()-1);
							var oriDay = $dateSelect.val();
							$dateSelect.children().remove();
							for (var i = 1; i <= theDate.getDate(); i++) {
								$dateSelect.append('<option value="'+i+'">'+i+'日</option>');
							}
							$dateSelect.val(oriDay);
						}
						
					} else if ($yearSelect.val() === '') {
						$monthSelect.append('<option value="" selected>請選擇</option>');
						$dateSelect.append('<option value="" selected>請選擇</option>');
						
						$monthSelect.val('');
						$dateSelect.val('');
						oInput_BENE_BRDY_H.val('');
					}
				});
				
				var oInput_BENE_BRDY_M = $('<select name="BENE_BRDY_M" required style="width:80px"></select>').change(function(){
					var $monthSelect = $(this);
					var theYear = $monthSelect.parent().prev().children("select").val();
					var theDate = new Date(theYear, $monthSelect.val(), 1);
					if (!isNaN(theDate)) {
						theDate.setDate(theDate.getDate()-1);
						var $dateSelect = $monthSelect.parent().next().children("select");
						var oriDay = $dateSelect.val();
						$dateSelect.children().remove();
						for (var i = 1; i <= theDate.getDate(); i++) {
							$dateSelect.append('<option value="'+i+'">'+i+'日</option>');
						}
						$dateSelect.val(oriDay);
					}
				});
				
				var oInput_BENE_BRDY_D = $('<select name="BENE_BRDY_D" required style="width:80px"></select>');
				
				for (var i = currentYear ; i >= 1911 ; i--) {
					oInput_BENE_BRDY_Y.append('<option value="'+i+'">'+i+'年</option>');
				}
				for (var i = 1 ; i <= 12 ; i++) {
					oInput_BENE_BRDY_M.append('<option value="'+i+'">'+i+'月</option>');
				}
				for (var i = 1 ; i <= 31 ; i++) {
					oInput_BENE_BRDY_D.append('<option value="'+i+'">'+i+'日</option>');
				}
				
				oInput_BENE_BRDY_Y.append('<option value="" selected>請選擇</option>');
				oInput_BENE_BRDY_M.append('<option value="" selected>請選擇</option>');
				oInput_BENE_BRDY_D.append('<option value="" selected>請選擇</option>');
				
				if(isNaN(theBrdySplit[0])||'' === theBrdySplit[0]){
					oInput_BENE_BRDY_Y.val('');
				}else {
					oInput_BENE_BRDY_Y.val(parseInt(theBrdySplit[0]));
				}
				if(isNaN(theBrdySplit[1])){
					oInput_BENE_BRDY_M.val('');
				}else {
					oInput_BENE_BRDY_M.val(parseInt(theBrdySplit[1]));
				}
				if(isNaN(theBrdySplit[2])){
					oInput_BENE_BRDY_D.val('');
				}else {
					oInput_BENE_BRDY_D.val(parseInt(theBrdySplit[2]));
				}

				var oInput_BENE_NATION_H = $('<input type="hidden" name="BENE_NATION" value="'+showValue(data['BENE_NATION'])+'" style="width:350px;ime-mode:active;"/>');
				
				var oSelect_BENE_NATION = $('<select name="BENE_NATION_SELECT" required style="width:170px"></select>').change(function(){
					var obj = $(this);

					oInput_BENE_NATION_H.val(obj.val());
					
				});
				
				if(nationData){
					for(var key in nationData){
						oSelect_BENE_NATION.append('<option value="'+key+'">'+nationData[key]+'</option>');
					}
				}
				oSelect_BENE_NATION.append('<option value="" selected>請選擇</option>');
					
				var oInput_BENE_ID = $('<input type="text" name="BENE_ID" title="BENE_ID" value="'+showValue(data['BENE_ID'])+'" maxlength="20" required style="margin-left:0px;width:110px;ime-mode:disabled">').change(function(){
					var obj = $(this);
					obj.val(obj.val().toUpperCase());
				});
				var oInput_BENE_NAME = $('<input type="text" name="BENE_NAME" title="BENE_NAME" maxlength="16" value="'+showValue(data['BENE_NAME'])+'" required style="width:170px"/>');

				var oSelect_BENE_ID_TYPE;	
				
				var oSelect_RELATION = $('<select name="RELATION" required style="width:170px"></select>').change(function(){
					var obj = $(this);
					if(legalrelation === obj.val()){
						/*
						2017-01-03 網路投保UI優化受益人選擇受益人則掛免填
						*/
						oInput_BENE_ID.attr('readOnly', true).attr('legalbene', true).val('免填');
						oInput_BENE_NAME.attr('readOnly', true).attr('legalbene', true).val('免填');
						oSelect_BENE_ID_TYPE.val('1');
						
						/*
						 若選擇法定繼承人，國籍鎖定TW，生日不用選擇
						 */
						if(isNeedBeneInfo){
							oSelect_BENE_NATION.attr('readOnly', true).attr('disabled', true).val('TW');
							oSelect_BENE_NATION.trigger('change');
							
							oInput_BENE_BRDY_Y.attr('readOnly', true).attr('disabled', true).val('');
							oInput_BENE_BRDY_M.attr('readOnly', true).attr('disabled', true).val('');
							oInput_BENE_BRDY_D.attr('readOnly', true).attr('disabled', true).val('');

							oInput_BENE_BRDY_H.val('');
						}
					} else {
						oInput_BENE_ID.attr('readOnly', false).removeAttr('legalbene').val('');
						oInput_BENE_NAME.attr('readOnly', false).removeAttr('legalbene').val('');
						
						if(isNeedBeneInfo){
							oSelect_BENE_NATION.attr('readOnly', false).attr('disabled', false);
							
							oInput_BENE_BRDY_Y.attr('readOnly', false).attr('disabled', false).val('');
							oInput_BENE_BRDY_M.attr('readOnly', false).attr('disabled', false).val('');
							oInput_BENE_BRDY_D.attr('readOnly', false).attr('disabled', false).val('');

						}
					}					
				});

				/*
				2016-08-05 增加不檢核的ID_TYPE將ID變成灰色，若法定繼承人則保持灰色
				*/
				if(beneIdTypeData){
					oSelect_BENE_ID_TYPE = $('<select name="BENE_ID_TYPE" required style="width:130px"></select>').change(function(){
						var obj = $(this);
						if((!beneIdTypeAllowEmpty || $.inArray(obj.val(), beneIdTypeAllowEmpty)<0) && legalrelation !== oSelect_RELATION.val()){
							oInput_BENE_ID.removeAttr('legalbene');
						} else {
							oInput_BENE_ID.attr('legalbene', true);
						}	
						
						/*

						 */
						if(isNeedBeneInfo){
							/*
						 	若證件種類為ID，將固定國籍中華民國
							 */
							if(beneIdType === obj.val()){
								oSelect_BENE_NATION.attr('readOnly', true).attr('disabled', true).val('TW');
								oSelect_BENE_NATION.trigger('change');
							} else {
								oSelect_BENE_NATION.attr('readOnly', false).attr('disabled', false);
							}
						}

					});
					for(var key in beneIdTypeData){
						oSelect_BENE_ID_TYPE.append('<option value="'+key+'">'+beneIdTypeData[key]+'</option>');
					}
					if(defaultValueBeneIdTypeData){
						oSelect_BENE_ID_TYPE.val(defaultValueBeneIdTypeData);
					}else{
						oSelect_BENE_ID_TYPE.val(data['BENE_ID_TYPE']);
						oSelect_BENE_ID_TYPE.trigger('change');
					}
				}
				

					oSelect_RELATION.append('<option value="" selected>請選擇</option>');

				if(relationData){
					for(var key in relationData){
						oSelect_RELATION.append('<option value="'+key+'">'+relationData[key]+'</option>');
					}
					if(defaultValueRelation){
						oSelect_RELATION.val(defaultValueRelation);
					}else{
						oSelect_RELATION.val(data['RELATION']);
						if(oSelect_RELATION.val()=== legalrelation){
							oSelect_RELATION.trigger('change');
						}
					}
				}

				if(hasData){
					if(beneRatoUp){
						div_rate.click();
						input_rate.val((beneRatoUp));
					}else{
						div_order.click();
						input_order.val(benePrio);
					}
					
					if(isNeedBeneInfo){
						oSelect_BENE_NATION.val(beneNation);
						oSelect_BENE_NATION.trigger('change');
					}
					
				}

				var aLink_obj = $('<a href="javascript:;" style="margin-left:5px">比例和順位是什麼?</a>').click(function(){
					WIUtil.lightbox({type:'popClaimOption'});
				});
				
				/*
				2017-01-03 網路投保UI優化受益人增加說明
				*/
				var legalLink_obj = $('<a href="javascript:;" style="margin-left:5px">法定繼承人</a>').click(function(){
					
					
					var opts = {
							type:'json'
							, title:'法定繼承人:填寫說明'
							, disaplyServiceLine:true
							, columns:[
								{type:'span', value:'選擇法定繼承人無需填寫姓名、身分證或護照號碼'}
							]
						};
					
					
					WIUtil.lightbox(opts);
				});

				var oTD_showBeneID = $('<td/>');

				if(oSelect_BENE_ID_TYPE){
					oTD_showBeneID.append(
						$('<span class="iselect" style="width: 110px; margin-left: 0px;top: -1px;"/>').append(oSelect_BENE_ID_TYPE).append($('<i style="z-index:1"/>'))
					);
				}

				oTD_showBeneID.append(
						oInput_BENE_ID
				);

				
				

				var oInput_BENE_MOBL_NO = $('<input type="text" name="BENE_MOBL_NO" title="BENE_MOBL_NO" maxlength="10" size="11" value="'+showValue(data['BENE_MOBL_NO'])+'" style="width:160px;ime-mode:disabled;"/>');
				var oInput_BENE_ZIP_CODE = $('<input type="text" name="BENE_ZIP_CODE" title="BENE_ZIP_CODE" maxlength="5" size="6" value="'+showValue(data['BENE_ZIP_CODE'])+'" style="width:70px;ime-mode:disabled;"/>');
				var oSpan_zipCodeName = $('<span id="zipCodeName"></span>');
				var oInput_BENE_ADDR = $('<input type="text" name="BENE_ADDR" title="BENE_ADDR" maxlength="150" size="45" value="'+showValue(data['BENE_ADDR'])+'" style="width:350px;ime-mode:active;"/>');
				var oInput_IS_SAME_APC = $('<input type="hidden" name="IS_SAME_APC" value="'+showValue(data['IS_SAME_APC'], '0', true)+'" style="width:350px;ime-mode:active;"/>');
				var ADDR_SAMPLE = $('<BR><span>例:106&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;例:仁愛路四段296號1樓</span>');
				inputTextValueTipsRegister(oInput_BENE_MOBL_NO, '電話');
				inputTextValueTipsRegister(oInput_BENE_ZIP_CODE, '郵遞區號');
				inputTextValueTipsRegister(oInput_BENE_ADDR, '地址');

				var oDiv_beneAddrTelInfo = $('<div/>').addClass('field-cont').append(
													$('<div/>').addClass('field-cont').append(oInput_BENE_MOBL_NO)
												).append(
													$('<div/>').addClass('field-cont').append(oInput_BENE_ZIP_CODE)
													.append(oSpan_zipCodeName)
													.append(oInput_BENE_ADDR)
													.append(ADDR_SAMPLE)
												);

				var oCheckBox_forSAME_APC = $('<input type="checkbox"/>').click(function(){
					if($(this).attr('checked')){
						oInput_IS_SAME_APC.val('2');
						oDiv_beneAddrTelInfo.hide();
					}else{
						oInput_IS_SAME_APC.val('0');
						oDiv_beneAddrTelInfo.show();
					}
				});

				if(oInput_IS_SAME_APC.val()==='2'){
					oCheckBox_forSAME_APC.attr('checked','checked');
					oDiv_beneAddrTelInfo.hide();
				}

				var cbEvent_zipCode = apcInfo['onChangeByBENE_ZIP_CODE'];
				if(cbEvent_zipCode){
					oInput_BENE_ZIP_CODE.change(function(){
						oSpan_zipCodeName.html(cbEvent_zipCode(this.value));
					});
					if(oInput_BENE_ZIP_CODE.val()!=''){
						oInput_BENE_ZIP_CODE.trigger('change');
					}
				}

				if(apcInfo['defaultIsSame']===true){
					oCheckBox_forSAME_APC.attr('checked','checked');
				}

				var oTbody = $('<tbody/>');
				var oTr_deleteBene = $('<tr/>');
				if(isFirstRowData!==true){
					oTr_deleteBene.append(
						$('<td colspan="4" class="pd-10">').append(
							$('<div class="field-tt"/>')
								.append($('<i/>').addClass('icon-del'))
								.append($('<a href="javascript:;" style="padding-left:5px;">刪除此受益人</a>', {'data-my':'left center', 'data-at':'right center'}).click(function()
										{beneInfoDiv.remove(); 
										if(_benePerson>0){
											_benePerson--;
										}
										if(_benePerson==1){
											var one_rate = $('input[name=rate]');
											var one_order = $('input[name=oder]');

											one_rate.siblings('div.iradio').trigger('click');
											
											one_order.attr('disabled', true).val('');
											one_rate.attr('checked', true);
											one_rate.attr('disabled', false).val('100');
										}
								}))
						)
					);
				}
				oTbody.append(oTr_deleteBene.append(oInput_IS_SAME_APC));
				
				var beneTable = $('<table/>');
				
				beneTable
				.append('<colgroup><col style="width:142px"><col style="width:210px"><col style="width:140px"><col></colgroup>')
				.append(
						oTbody
							.append(
								$('<tr/>')
									.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i>與被保人關係</div>'))
									.append(
										$('<td/>').append(
											$('<div/>').addClass('field-cont').append($('<span class="iselect" style="width: 168px; margin-left: 0px;"/>').append(oSelect_RELATION).append($('<i style="z-index:1"/>')))
											.append($('<div/>').addClass('field-cont').addClass('fl-left')
													.append($('<span class="descr"></span>')
															.append($('<i class="icon-info"></i>'))
															.append(legalLink_obj))
											)
										)
									)
									.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>身分證或護照號碼</div>'))
									.append(oTD_showBeneID)
							)
							.append(
								$('<tr/>')
									.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i> 受益人姓名</div>'))
									.append(
										$('<td/>').append(
											$('<div/>').addClass('field-cont').append(oInput_BENE_NAME)
										)
									)
									.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>獲得理賠方式</div>'))
									.append(
										$('<td/>').addClass('chooseClaimsType')
											.append($('<div/>').addClass('field-cont').addClass('fl-left')
												.append('<label/>')
													.append(div_rate).append('<font>比例</font>')
													.append(input_rate).append('<font style="padding-left:5px">%</font>')
											).append($('<div/>').addClass('field-cont').addClass('fl-left').addClass('mt-0').addClass('ml-10')
												.append('<label/>')
													.append(div_order).append('<font>順位</font>')
													.append(input_order)
											).append($('<div/>').addClass('field-cont').addClass('fl-left')
												.append($('<span class="descr"></span>')
												.append($('<i class="icon-info"></i>'))
												.append(aLink_obj))
											)
									)
							)
					);
				
				if(isNeedBeneInfo){
					beneTable
					.append(
							$('<tr/>')
								.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i>國籍</div>'))
								.append($('<td/>').append(
										$('<div/>').addClass('field-cont').append($('<span class="iselect" style="width: 168px; margin-left: 0px;"/>').append(oSelect_BENE_NATION).append($('<i style="z-index:1"/>')))
										.append(oInput_BENE_NATION_H)
									)
								)
								.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>生日</div>'))
								.append($('<td/>').append(
										$('<div/>').addClass('field-cont')
											.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_BENE_BRDY_Y).append($('<i style="z-index:1"/>')))
											.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_BENE_BRDY_M).append($('<i style="z-index:1"/>')))
											.append($('<span class="iselect" style="width: 80px; margin-left: 0px;"/>').append(oInput_BENE_BRDY_D).append($('<i style="z-index:1"/>')))
											.append(oInput_BENE_BRDY_H)
									)
								)
						);
				}
				beneTable
				.append(
						$('<tr/>')
							.append($('<td/>').addClass('first').append('<div class="field-tt"><i class="rq">*</i>電話及地址</div>'))
							.append(
								$('<td/>').attr('colspan',3).append(
									$('<div/>').append(
										$('<div/>').addClass('field-cont').append($('<div/>').append(oCheckBox_forSAME_APC).append('電話及地址同要保人'))
									).append(
										oDiv_beneAddrTelInfo
									)
								)
							)
					);
				beneInfoDiv.append(beneTable).append($('<div class="flowhelper"></div>').append($('<div class="descr"><i class="icon-circledisc"></i> 身故保險金受益人之地址及電話未填寫，則以要保人最後所留之地址及電話做為日後身故保險金受益人之通知依據。</div>')));
				block_bene.append(beneInfoDiv);
				oCheckBox_forSAME_APC.iCheck({checkboxClass: _icheckboxClass}).parent('.'+_icheckboxClass).children('.iCheck-helper').click(function(){oCheckBox_forSAME_APC.click();});
				if(apcInfo['defaultIsSame']===true){
					oCheckBox_forSAME_APC.trigger('click');
				}
				_benePerson++;
			}

			return {
				/**
				 *	@public
				 *	@class 載入受益人資料。
				 *	@param inputDatas (Array)
				 **/
				loadData: function(inputDatas){
					_benePerson=0;
					block_bene.empty();
					if(!inputDatas || inputDatas.length==0){
						addOneRowData({isFirstRowData:true});
						return;
					}
					for(var i=0;i<inputDatas.length;i++){
						addOneRowData({
							isFirstRowData:i==0
							, inputData:inputDatas[i]
						});
					}
				}
				/**
				 *	@public
				 *	@class 增加受益人輸入資料。
				 *	@param inputDatas (Map)
				 *	@param inputDatas.isFirstRowData (Boolean)
				 *	@param inputDatas.inputData (Map)
				 *	@param inputDatas.defaultValueRelation (String) : 若無指定「與被保人關係」預設值時，以 inputData 內的 RELATION 值為預設值。
				 **/
				, add: function(inputOpt){
					addOneRowData(inputOpt);
				}
				/**
				 *	@public
				 *	@class 檢核受益人輸入資料。
				 **/
				, check: function(){
					var checkResult = '';
					var addMsg = function(msg){
						if(checkResult!=''){ checkResult += '<br>'; }
						checkResult += msg;
					};

					$('span[id^=block_bene]').each(function(idx, elem){
						var keyInIds = [];
						var hasSameId = false;
						var cntLegal = 0;
						
						var $elem = $(elem);
						var oSelect_RELATIONs = $elem.find('select[name=RELATION]');
						var oInput_NAMEs = $elem.find('input[name=BENE_NAME]');
						var oSelect_TYPEs = $elem.find('select[name=BENE_ID_TYPE]');
						
						var oInput_BRDYs = $elem.find('input[name=BENE_BRDY]');
						var oSelect_BENE_BRDY_Y = $elem.find('select[name=BENE_BRDY_Y]');
						var oSelect_BENE_BRDY_M = $elem.find('select[name=BENE_BRDY_M]');
						var oSelect_BENE_BRDY_D = $elem.find('select[name=BENE_BRDY_D]');
						
						var oSelect_NATIONs = $elem.find('input[name=BENE_NATION]');
						
						$elem.find('input[name=BENE_ID]').each(function(index){
							var oInput_id = $(this);
							var v = oInput_id.val();
							var oSelect_TYPE = oSelect_TYPEs[index];
							//法定繼承人不檢核姓名必須輸入
							if($(oInput_NAMEs[index]).val()==='' && $(oSelect_RELATIONs[index]).val() !== legalrelation){
								addMsg('「第 '+(index+1)+' 位受益人」姓名必須輸入');
							}
	
							if(v==='' && $(oSelect_RELATIONs[index]).val() !== legalrelation && (!beneIdTypeAllowEmpty || $.inArray(oSelect_TYPE.value, beneIdTypeAllowEmpty)<0) ){
								/*
								2016-04-22 受益人檢核ID可以輸入空值
								*/
								addMsg('「第 '+(index+1)+' 位受益人」身分證或護照號碼必須輸入');
							}else{
								if($(oSelect_RELATIONs[index]).val() !== legalrelation && (!beneIdTypeAllowEmpty || $.inArray(oSelect_TYPE.value, beneIdTypeAllowEmpty)<0)){
									if((!beneIdTypeNotCheckIDs || $.inArray(oSelect_TYPE.value, beneIdTypeNotCheckIDs)<0) && !idCheck(v)){
										addMsg('「第 '+(index+1)+' 位受益人」身分證或護照號碼格式不符');
									}else if(!hasSameId){
										if($.inArray(v, keyInIds)>=0){
											hasSameId = true;
										}else{
											keyInIds.push(v);
										}
									}
								}else{
									//法定繼承人不檢核護照號碼。
								}
							}
							var oSelect_RELATION = $(oSelect_RELATIONs[index]);
							if(oSelect_RELATION.val()===''){
								addMsg('「第 '+(index+1)+' 位受益人」尚未選擇與被保人關係');
							} else if(oSelect_RELATION.val()=== legalrelation) {
								cntLegal = cntLegal + 1;
							}
							
							
							if(isNeedBeneInfo){
								var BENE_BRDY_Y = $(oSelect_BENE_BRDY_Y[index]).val()+"";
								var BENE_BRDY_M = $(oSelect_BENE_BRDY_M[index]).val()+"";
								var BENE_BRDY_D = $(oSelect_BENE_BRDY_D[index]).val()+"";
			
								if(''===BENE_BRDY_Y || ''===BENE_BRDY_M || ''===BENE_BRDY_D){
									addMsg('「第 '+(index+1)+' 位受益人」尚未輸入生日完成');
								} else {
									var BENE_BRDY = BENE_BRDY_Y + "-" + (BENE_BRDY_M.length < 2 ? "0"+BENE_BRDY_M:BENE_BRDY_M) + "-" +(BENE_BRDY_D.length < 2 ? "0"+BENE_BRDY_D:BENE_BRDY_D);
									$(oInput_BRDYs[index]).val(BENE_BRDY);
								}

								if($(oSelect_NATIONs[index]).val()===''){
									addMsg('「第 '+(index+1)+' 位受益人」尚未選擇國籍');
								}
							}

						});
	
						if(hasSameId){
							addMsg('「身故保險金受益人」不可重覆輸入受益人');
						}
						
						if(cntLegal > 1){
							addMsg('不可重覆輸入法定繼承人');
						}

					
						var chooseRate = false;
						var chooseOder = false;
						var rate = 0;
						var oder = [];
						$(elem).find('.chooseClaimsType .iradio').each(function(){
							var oDiv = $(this);
							if(oDiv.hasClass('checked')){
								var oDiv_fieldCont = oDiv.parent();
								var oInputText = oDiv_fieldCont.find('input[type=text]');
								if (oInputText == null || oInputText.size() == 0) {
									return;
								}
								var oText = oInputText[0];
								var v = oText.value;
								var isChooseRate = oText.name=='rate';
								if(isChooseRate){ chooseRate = true; }else{ chooseOder = true; }
								if(v==''){
									return;
								}
								if(isChooseRate){
									rate += parseInt(v,10);
								}else{
									oder.push(v);
								}
							}
						});
	
						if(!chooseRate && !chooseOder){
							addMsg('「獲得理賠方式」請輸入比例或順位');
		
						}else if(chooseRate && chooseOder){
							addMsg('「獲得理賠方式」理賠方式需一致，不可同時為比例及順位');
		
						}else if(chooseRate){
							if(rate!=100){
								addMsg('「獲得理賠方式」受益人比例總合需為 100');
							}
						}else{
							var maxOder = oder.length;
							for(var i=1;i<=maxOder;i++){
								if($.inArray(i.toString(), oder)<0){
									addMsg('「獲得理賠方式」受益人順位須從 1 開始且不可跳號');
									break;
								}
							}
						}

					});
					
					if(checkResult!=''){
						WIUtil.displayMessage({'msg':checkResult});
						return false;
					}
					return true;
				}
			}
		}
		, jobInfoHandler:{
			/**
			 *	@public
			 *	@class 取得職業類別名稱
			 *	@param jobClass (String) : 職業類別
			 **/
			getJobClassName: function(jobClass){
				return WI_JOB_CLASS[jobClass];
			}
			/**
			 *	@public
			 *	@class 取得職業類別大分類名稱
			 *	@param jobClass (String) : 職業類別
			 *	@param group (String) : 職業類別大分類
			 **/
			, getGroupName:function(jobClass,group){
				return WI_GROUP[group];
			}
			/**
			 *	@public
			 *	@class 取得職業類別要保書套印名稱
			 *	@param jobClass (String) : 職業類別
			 *	@param overprint (String) : 要保書套印代碼
			 **/
			, getOverprintName:function(jobClass,overprint){
				return WI_OVERPRINT[jobClass+'-'+overprint];
			}
			/**
			 *	@public
			 *	@class 取得職業類別說明
			 *	@param jobClass (String) : 職業類別
			 *	@param group (String) : 職業類別大分類
			 **/
			, getDescription:function(jobClass,group){
				return WI_DESCRIPTION[jobClass+'-'+group];
			}
			/**
			 *	@public
			 *	@class 取得職業代碼
			 *	@param jobClass (String) : 職業類別
			 *	@param group (String) : 職業類別大分類
			 **/
			, getJobcode:function(jobClass,group){
				return WI_JOB_CODE[jobClass+'-'+group];
			}
		}
		, iCheckStyleHandler:{
			applyCheckbox:function(){
				$(':checkbox').each(function(){
					var cssClass = 'icheckbox';
					var oCheckbox = $(this);
					oCheckbox.iCheck({checkboxClass: cssClass}).parent('.'+cssClass).children('.iCheck-helper').click(function(){oCheckbox.click();});
				});
			}
			, applyRadio:function(){
				$(':radio').each(function(){
					var cssClass = 'iradio';
					var oRadio = $(this);
					oRadio.iCheck({checkboxClass: cssClass}).parent('.'+cssClass).children('.iCheck-helper').click(function(){oRadio.click();});
				});
			}
			, applySelect:function(){
				$('select').each(function() {
					var o = $(this), w = parseInt(o.css('width')) || 100, ml = parseInt(o.css('margin-left')) || 0, iselect, toggle;
						o.wrap('<span class="iselect" />');
						iselect = o.parent();
						iselect.css('width', w );
						iselect.css('margin-left', ml );
						o.css('width', w + 20);
						o.css('margin-left',0);
						toggle = $('<i />').appendTo(iselect);
						// avoid text overlaps <i>
						iselect.on('mouseenter', function(){
							toggle.css('z-index', 1);
						}).on('mouseleave', function(){
							toggle.css('z-index', '');
						});
				});
            }
		}
		/**
		 *	@public
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
		, windowOpen:function(url, opts){

			var createHideParameter = function(n,v){
				var oInput = document.createElement('input');
					oInput.type = 'hidden';
					oInput.name = n;
					oInput.value = v;
				return oInput;
			};

			opts = opts || {};
	
			var params = opts.parameters || {};
			var fullScreen = opts.fullScreen === true;
			var attrs = {'status':'no','toolbar':'no','menubar':'no','resizable':fullScreen?'no':'yes', 'scrollbars': 'yes','location':'no','directories':'no'};
	
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
	
			var formId = '_popupWin_windowOpen_form';

			var theForm = document.getElementById(formId);

			if(!theForm){
				theForm = document.createElement('form');
				theForm.id=formId;
				theForm.method='post';
				document.body.appendChild(theForm);
			}

			theForm.action=url;

			theForm.innerHTML='';

			for(var k in params){
			    theForm.appendChild(createHideParameter(k,params[k]));
			}

			try{
				var eBAF_loginSystemInfo = top['eBAF_loginSystemInfo'];
				var eBAF_UserObject_Flag = top['eBAF_UserObject_Flag'];
				if(eBAF_loginSystemInfo){
				    theForm.appendChild(theForm.appendChild(createHideParameter('eBAF_loginSystemInfo',eBAF_loginSystemInfo)));
				}
				if(eBAF_UserObject_Flag){
					theForm.appendChild(theForm.appendChild(createHideParameter('eBAF_UserObject_Flag',eBAF_UserObject_Flag)));
				}
			}catch(e){
			}
			window.open('',windowName,windowOpenAttrs,true);

			theForm.setAttribute('target', windowName);

			theForm.submit();

		}
		, inputTextValueTipsRegister: inputTextValueTipsRegister
		, getJoblightbox: function(){
			if(self!=top){
				var getJoblightbox = function(win){
					if(win && win.joblightbox){
						return win.joblightbox;
					}
				};
				return getJoblightbox(parent.window) || getJoblightbox(parent.parent.window);
    		}
		}
		, foreachCreditCardIssuers: function(cbFunc){
			if(!cbFunc){
				return;
			}
			for(var i=0;i<creditCardIssuers.length;i++){
				var bankInfo = creditCardIssuers[i];
				cbFunc(bankInfo['bankName']);
			}
		}
		, getCreditCardIssuersTips: function(){
			return creditCardIssuersTips;
		}
		, showBrowserUpgradeTips: function(obj){

			var browser_info = getBrowser();

			if(!browser_info.isIE){
				return;
			}

			var version = parseFloat(browser_info.verIE||'0', 10);

			if(version>8){
				return;
			}
			
			var aLinkChrome = $('<a/>').css({'margin':'0px 10px','cursor':'pointer'}).html('Google Chrome').click(function(){
				window.open('https://www.google.com.tw/chrome/browser/desktop');
			});
			var aLinkIE = $('<a/>').css({'margin':'0px 10px','cursor':'pointer'}).html('IE9').click(function(){
				window.open('http://windows.microsoft.com/zh-tw/internet-explorer/download-ie');
			});

			var oSpan = $('<span/>').append(
				$('<span/>').html('提醒您：IE8以下瀏覽器可能造成網頁資訊不完整或部分功能無法操作，請您使用')
			).append(
				aLinkChrome
			).append(
				$('<span/>').html('或')
			).append(
				aLinkIE
			).append(
				$('<span/>').html('以上瀏覽器，以獲得最佳操作體驗。')
			);

			$(obj).append(oSpan);

		}
	};
};