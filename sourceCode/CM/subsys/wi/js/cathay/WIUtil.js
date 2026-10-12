(function($) {
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
	var WI_JOB_CLASS = {'0':'第零類', '1':'第一類', '2':'第二類', '3':'第三類', '4':'第四類', '5':'第五類', '6':'第六類', '7':'第七類', '8':'第八類'};
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
		  '1-01':'00010010'
		, '1-02':'12010020'
		, '1-03':'17000010'
		, '1-04':''
		, '1-05':'17000040'
		, '1-06':'17000050'
		, '1-07':''
		, '1-08':''
		, '1-09':''
		, '2-01':'00010020'
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
		, {bankName:"匯豐銀行"}, {bankName:"渣打銀行"}, {bankName:"樂天信用卡"}, {bankName:"花旗銀行"}, {bankName:""}
	];
	
	var creditCardIssuersTips = "註：目前暫不接受美國運通等發卡機構之信用卡。";

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
		, lightboxForJobClassNew: function(opt){
			var stepNum = 0;
			var cbFunc = opt['cbFunc'];
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

			var displayLightbox_option = function(){
				
				WIUtil.closeCoverPage();
				var joblightbox = WIUtil.getJoblightbox();
				if(!joblightbox){
					return;
				}
				joblightbox.openForAT({
					cbFunc : cbFunc
					, optionsLv1 : opt['optionsLv1']
					, cbFunc_optionsLv1 : opt['cbFunc_optionsLv1']
					, cbFunc_optionsLv2 : opt['cbFunc_optionsLv2']
				});
			};

			//TODO step3 for AT new product
			var unknownAction = function(){
				displayLightbox_option();
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
		, showDataLoadingForWI: function(opt, indexOfPage) {

			var body = null;
			var switcher = false;

			//check if what kind of class
			body = $('body', window.top.document);
			if(window.top != window.self) {
				$(body.find('#CSRPage_Iframe')).load(function() {
					WIUtil.showDataLoadingForWI(false);
				});
			}

			if(typeof(indexOfPage) == "number" && (opt == null || ((typeof(opt) == "boolean") && opt == true))) {
				switcher = true;
			} else {
				if($(body.find('.main_diagram')).length == 0) {
					return;
				}
			}

			switch(indexOfPage) {
				case 1:
					//澆花
					_diagram = 'data:image/png;base64,R0lGODlhLAFeAff/AKB/U9b/yMrzvOP/2uC7lKf2//7//0BAQIvN1SqZFLznrXats7/AwGq5DodrRRcSDFlpU6nXB+v7AQIDApOrA0k6KDAwMMLrtAtxFI+QkH+AgCsiGLmZeJR1TBomJwoWAt3/0Zt7ULPYpqbHmtn/zK+wsEpYRSU3ORJVDAaHGDI8L4KbelRCLBAREDRPBDlENmpUN6OCVnFVLTpVWJrj6zBvC9X/xsbqBCw1KXaSBFFuBcmkfjYrHNz0AlpIMQwKBgoNC4XJC39lQkWoEsqohFmEiZW0ipnTCYylhEVlabjiBtf/ybnkqkeIDMjyuiQdFDiiE+G8lUdWAnFaO6eJaR2TFml6Y3KKanjBDGN3XHyWc9u3kOT/3D9KPGxZRmaWmyAgIH5gOJu6kRQdHlBQUBGOFw0TFNayjAUKAZTa4sDls2BgYHVYMOT+2+/w8Lrlq4NlPKvAo4ejfZGriJ+goN/g4HlcNM/Q0G5SKmuCY873wMz1vh4kHBcgAR8ZEWJOMxQYEy1DRQgnBiIpIMr0vFayENGtiDBHSnyLdxg4Bq7SosPXAqO3nND5whEOCXBwcAY8C2Z7A9//1Z/q88zlxNHuA1F4fJLKCQcJCE1yduP/25msk77Vtig4A2yfpSIqAeH/2NL6w5Z8Yl+2D9bwzVV9gtP8xYLAx4BrVMTbvLHHquO+lsbvuGJJJtHsyVygDE+tEb7psDQrIURRQHdfPniRbzM/Ao1wSIpyWTVOUaTy+0lscNH2xQYGBXdiTGCOk7jhqRkdF9j/yn24v+W/mNb+yFBgS+S/l5/Ak6b0/ab1/uD/16Lv+BsWDwsPDyo+QHJYNT4yIbbdqA8XGMTuttb/ydX3yuL/2df/yN/61h8uMLjPscv0vcvyvkFgYz1bXqXz/Mnzu830v+b/3tX/x9f+ySkxJ832v6GAVMvzvMrzvaCBXl9xWeG8lK+RcSYuJMrxvdn20Nb9yXF/bMvvv+j/3+P+2l9PPt+7lbzgr+C8l966k7SUc8juu8nyuwAAACH/C05FVFNDQVBFMi4wAwEAAAAh/wtYTVAgRGF0YVhNUDw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQyIDc5LjE2MDkyNCwgMjAxNy8wNy8xMy0wMTowNjozOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo5MTNmMDY3OS0yNjNhLTc5NGQtODRiYy05MWY0ODZhOWY2OGQiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QkMwNUVFOTEyQkU1MTFFODhDMkU4RkNFQjkxQjFCQUQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QkMwNUVFOTAyQkU1MTFFODhDMkU4RkNFQjkxQjFCQUQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjk4MGZjMDg0LWFjYzYtYzE0NS1hYjEyLTIxZGM1MjdlYjI4OCIgc3RSZWY6ZG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjkwYTQ4MWI5LTg5M2MtMzc0My1hMjhmLWVhZTgzYzY3NzFhMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0s7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQ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';
				break;
			}

			if($(body.find('.main_diagram')).hasClass("main_diagram")) {
				if(!switcher) {
					if ($.browser.mozilla) {
						$(body.find('.main_diagram')).remove();
					}else {
						$(body.find('.main_diagram')).removeClass("show_p");
						$(body.find('.main_diagram')).css({'visibility': 'hidden'});
					}
				} else {

					if(!$(body.find('.main_diagram')).hasClass("show_p")) {
						$(body.find('.main_diagram')).css({'visibility': 'visible'});
					}

				}
			} else {
				var outter = $('<div class="main_diagram show_p" />').css({'position': 'relative', 'z-index':'9100'})
								.append($('<div class="bg" />').css({'position': 'fixed', 'width': '100%'
											,'height': '100%', 'top': '0', 'left': '0', 'cursor': 'pointer'
											,'background-color': 'rgba(0,0,0,0.70)'}))
								.append($('<div class="diagram-wrap" />'))
		

				var dataLoaderDiv = $('<div class="show_diagram" />').css({'position': 'relative', 'width': '100%', 'margin': '20px 0px'}).append(
							$('<div/>').css({'position':'relative', 'width':'650px', 'height':'283px'}).append(
								$('<div class="data2Loaded"/>').css({'position': 'absolute','left': '160px', 'bottom': '80px', 'width': '300px','height': '365px', 'background-image': "url(" + _diagram + ")"})
							));

				$(outter.find('.diagram-wrap')).append(dataLoaderDiv);
				body.append(outter);
				
				// select outtest frame to locate view 
			    var contentH = $(".diagram-wrap", body).height();
		    	_topHeight = $(top).height();
		    	_topWidth= $(top).width();
		    	$(".diagram-wrap", body).css('position','fixed').css('top',(_topHeight-contentH)/2).css('left',(_topWidth-700)/2);
		    	
			}

		}
		, closeCoverPage: function(){
			//if(self!=top){
				if(parent && parent.window && parent.window.closeLightbox){
					parent.window.closeLightbox();
				}else{
					if(window && window.closeLightbox){//TODO
						window.closeLightbox();
					}
				}
			//}
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
					$('#myselfForRadio').attr('hidden', false);
					$('#otherForRadio').attr('hidden', true);

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
					$('#myselfForRadio').attr('hidden', true);
					$('#otherForRadio').attr('hidden', false);

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

					// 本人
					oTd_insdRelation.addClass('chooseClaimsType').attr('colspan',3);
					$('<div/>').attr('class', 'field-cont').appendTo(oTd_insdRelation);
					$('<label/>').appendTo(oTd_insdRelation);
					$(div_rltn1).appendTo(oTd_insdRelation);
					$('<font/>').css('padding-right', '20px').text("本人").appendTo(oTd_insdRelation);
					var blockM = $('<span/>').attr('id', 'myselfForRadio');
					$('<label/>').css("font-weight", 'bold').text("**開通自然人憑證驗證，可同時幫親屬投保，讓您替家人帶來保障！").appendTo(blockM);
					$('<a/>').attr('id', 'btn_validate').attr('href', '#').attr('target', '_blank').css("font-weight", 'bold').text("了解如何開通").appendTo(blockM);
					$(blockM).appendTo(oTd_insdRelation);

					// 其它
					$('<div/>').attr('class', 'field-cont').appendTo(oTd_insdRelation);
					$('<label/>').appendTo(oTd_insdRelation);
					$(div_rltn2).appendTo(oTd_insdRelation);
					$('<font/>').css('padding-right', '20px').text("其他").appendTo(oTd_insdRelation);
					var blockO = $('<span/>').attr('id', 'otherForRadio');
					$('<label/>').css({"font-weight":'bold' , 'color':'red'}).text("**幫親屬投保，請先準備親屬自然人憑證IC卡、讀卡機以供待會驗證喔").appendTo(blockO);
					$(blockO).appendTo(oTd_insdRelation);

					//select box
					oTd_insdRelation.append($('<div/>').addClass('field-cont')
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
				).append(
					$('<tr/>')
						.append($('<td/>').addClass('field').append('<div class="field-tt"><i class="rq">*</i>身分證字號或居留證號</div>'))
						.append($('<td/>').attr('colspan',3).append(
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
						'defaultIsSame':true
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
			var nationData = initOpt['nationData'];
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

                        if('true' === div_order.attr('oneBene')){
                                return;
                        }
                        
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
					}else if(benePrio){
                        div_order.click();
                        input_order.val(benePrio);
                    }
					
                    if(oInput_BENE_ID.val().length === 0) {
                    	oSelect_RELATION.val('2');
                    	oSelect_RELATION.trigger('change');
                    }

					if(isNeedBeneInfo){
						oSelect_BENE_NATION.val(beneNation);
						oSelect_BENE_NATION.trigger('change');
						oSelect_BENE_ID_TYPE.trigger('change');
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
                                            one_order.siblings('div.iradio').attr('oneBene', true);
                                                                                                                                    
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

				var one_order = $('input[name=oder]');
                if(_benePerson > 1){
	                one_order.siblings('div.iradio').attr('oneBene', false);
                }else {
	                one_order.siblings('div.iradio').attr('oneBene', true);
                }
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
							, defaultValueRelation:'2'
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
									if(oSelect_RELATION.val()=== legalrelation) {
									/*
									法定繼承人不檢核生日
									*/		
									}else {
										addMsg('「第 '+(index+1)+' 位受益人」尚未輸入生日完成');
									}
									$(oInput_BRDYs[index]).val('');
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

window.WIUtil = WIUtil;

}) (jQuery);