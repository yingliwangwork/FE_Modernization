var CitizenPersonalCertificate = new function(){

	var _currentVersion = '1.0.2';
	var cbFunction;
	var options;
	
	var useProdDomain = ['www.cathaylife.com.tw', 'w3.cathaylife.com.tw', 'was2.cathaylife.com.tw', 'was3.cathaylife.com.tw', 'im.cathaylife.com.tw','online.cathaylife.com.tw','bgdonline.cathaylife.com.tw'];

	var useProdServer = false;
	
	var wls = window.location.toString();

	for(var i=0;i<useProdDomain.length;i++){
		var patternString = '\/'+useProdDomain[i]+'*';
		var regex = new RegExp(patternString);
		useProdServer = regex.test(wls);
		if(useProdServer){
			break;
		}
	}
	
	var downloadURL = useProdServer ? 'https://www.cathaylife.com.tw/ocauth/OCWeb/html/OC/resource/citizenPersonal/CathayLifeCPC.zip' : 'https://twww.cathaylife.com.tw/ocauth/OCWeb/html/OC/resource/citizenPersonal/CathayLifeCPC.zip';
	
	var cssStyle_flowstep_first = {
		'width':'80px',
		'height':'60px',
		'background-image':'url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAAA/CAMAAAFoewDPAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAqUExURQAAAACwUACwTgCvTwCwUACqVQCuUACwTwCvTwCwUACwTwCwUACvTwCvUK5RMKEAAAAOdFJOUwCbNJf/DDzDx4/zn/fLnCd/OAAAAAlwSFlzAAAXEQAAFxEByibzPwAAAdNJREFUWEfll9lywyAMRemSpkv6/79bsI8xYBZLnoiHnpcILVc3OJlJ3Ov7zsN5iOGQ8BmCyDBxKxK3QsOfs0SwkXccEipjI43jlpRQ7TbQQtxg2OBbeG1RXmdBeZsFodxpWMvthq2uV4gdnGoMTHqWDuI6oYOwge8gajG4as+oYbRiZHL0NkO917DUOw1rvd1AvW+yCk95g6yITIKckESCjJgowVkBEpxULBLESrwEkZqrAuMvVJdwCYQa1sfAQQ5PUSuwjSsF9nGVQDru3AfZszzycec+KZzli7kI+fPcGdwgLaBQICshVyApIlMgJyNVICUkUSAjZVcgISYqcJazKXBUgAInDasCBxWLArGOoECoxCsQaXm7KvAz+S1cvcSrj3GZvyCwzusFmFcLbPNagTivFNjndQLJvEogndcIZPMKgXxeLlDMu1/yZ3lhLiL9fSDnXv4kyaHrqXQt0PNkOhboeDpNC9QNaFigakLVAjUjKhaomHGwQN6QwgJZUzIL5IxJLJAxJ1rgPAEscJrCYoF4Et4C0Sy+//cNTP4MTP4WsH6Wgbh+joFk/QwD2Xp7A8V6awOH9bYGKustDVTX2xlorLcy0FxvY6Czfva/Y+f+AAltcYbHGavYAAAAAElFTkSuQmCC")',
		'background-repeat':'no-repeat',
		'display':'inline-block',
		'overflow':'hidden',
		'margin-top':'40px',
		'-moz-background-size':'100%',
		'-webkit-background-size':'100%',
		'-o-background-size':'100%',
		'background-size':'100%'
	};

	var cssStyle_flowstep_on = {
		'width':'80px',
		'height':'60px',
		'background-image':'url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAAA/CAMAAAFhkKC1AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAeUExURQAAAACwUACvUACqVQC0VQCwTgCwTwCwTwCwUACwUFQT+7gAAAAKdFJOUwD/+wwYVMPTj59KxF9mAAAACXBIWXMAABcRAAAXEQHKJvM/AAAAt0lEQVRYR+3WwRKCMAxF0SiK8v8/rCFBUpmKBWSYes+uJX08YINcT4H0Fm/5wmyw0erGBjtL1unzRZbf22/G11M7XZ8f+M+R7Je7zQ0Mn7aOgQ8jWePZF0L8ZFBTyOoEAqoIEDn7he81fnJERoqMFBmpijLKIy5+crC+BAmGBEOCOULC8x+lPKRYO73tO2pE1IioEVEjokZEjYga0d1Hf6nze2Uc4E1QQVFBUUFRQVFBUUFRQUTkAZJ5HBMkuyihAAAAAElFTkSuQmCC")',
		'background-repeat':'no-repeat',
		'display':'inline-block',
		'overflow':'hidden',
		'margin-top':'40px',
		'margin-left':'-15px',
		'-moz-background-size':'100%',
		'-webkit-background-size':'100%',
		'-o-background-size':'100%',
		'background-size':'100%'
	};

	var cssStyle_flowstep_off = {
		'width':'80px',
		'height':'60px',
		'background-image':'url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAAA/CAMAAAFhkKC1AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAA5UExURQAAAKvlxQCwUACvUACqVQC0VQCwTgCwTwCwTzzDeef47wCwUP///wCwUAiyVdv05vP794/csgSxUxvHz9QAAAAOdFJOUwD///sMGFTD0///j/+fs3aLlwAAAAlwSFlzAAAXEQAAFxEByibzPwAAAP1JREFUWEft1usSgiAQBWCy0u6R7/+wsbjkopIQ2lBzvn/gejxhM6XqSlBWfeklbVW8JHbrkw2hoQ1vJH7nwStD03rDCyNqbQ6GlwPcyvreTCX6CZpPPv96CF+fH5h/hvF3I8E3d5gbcK/2RwYC3MCbkaD+3hcTMn3k0zRCRooOyU5AQCEBiQYBSm35Qrwd39lbJqPljxnliAwPMnzI8K2VkR6x5zud/BJI6CChg4RO/s/yEj/sdXpIsmb82KGSarQp//pSaPMtQA0HNSTUkFBDQg0JNaToGmeaa+9829JON4q/8rMCCjgJVCCoQFCBoAJBBYIKxFZYWekVlHoCst339CzuXf0AAAAASUVORK5CYII=")',
		'background-repeat':'no-repeat',
		'display':'inline-block',
		'overflow':'hidden',
		'margin-top':'40px',
		'margin-left':'-15px',
		'-moz-background-size':'100%',
		'-webkit-background-size':'100%',
		'-o-background-size':'100%',
		'background-size':'100%'
	};

	/*
	產生step
	*/
	function creatStep(oDiv_body, stepNum){
		
		oDiv_body.append($('<div/>'));
		
		for(var i=0;i<8;i++){
			var stepDiv = $('<div/>');
			if(i==0){
				stepDiv.css(cssStyle_flowstep_first);
			}else if((i+1)<=stepNum){
				stepDiv.css(cssStyle_flowstep_on);
			}else {
				stepDiv.css(cssStyle_flowstep_off);
			}
			oDiv_body.append(stepDiv);
		}
	}

	/*
	產生body
	*/
	function createBody(oDiv_body, stepNum, slots){
		
		switch(stepNum){
		
			case 1 :
			
				/*
				本文
				*/
				var div = $('<div/>');
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('請確認您備妥讀卡機並插入本人自然人憑證');			
				div.append(span);
				oDiv_body.append(div);
				
				/*
				按鈕
				*/
				div = $('<div/>').css({'margin-top':'20px','margin-bottom':'40px'});//TODO
				var button = $('<button/>').addClass('greenbn').attr('type','button');
				button.html('<b>開始驗證</b>');
				div.append(button);
				oDiv_body.append(div);

				/*
				按扭動作
				*/
				button.click(function(){	
					HiPKI.getPKCS11Info(function(data){
						var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
						if(!data.version){
							creatStep(body, 2);
							createBody(body, 2);
						}else if(data.version !=_currentVersion){
							creatStep(body, 3);
							createBody(body, 3);
						}else {
							creatStep(body, 4);
							createBody(body, 4, data.slots);
						}
						displayLightbox(createForm(options.title, body));	
					});		
				});		
				
				break;
				
			case 2 :
				/*
				本文
				*/
				var div = $('<div/>').css('margin-bottom','40px');
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('尚未安裝驗證元件，請');
				div.append(span);

				/*				
				超連結
				*/
				var a = $('<a/>').css({'color':'#008852','font-size':'24px','font-family':'Microsoft JhengHei','font-weight':'bold'});
					a.attr({'href':downloadURL,'target':'_blank'}).click(WIUtil.closeCoverPage);
					a.html('點此下載與安裝');
				div.append(a);
				oDiv_body.append(div);	
			
				break;
				
			case 3 :
				
				/*
				本文
				*/
				var div = $('<div/>').css('margin-bottom','40px');
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('驗證元件非最新版本 '+ _currentVersion +'，請');
				div.append(span);

				/*
				超連結
				*/
				var a = $('<a/>').css({'color':'#008852','font-size':'24px','font-family':'Microsoft JhengHei','font-weight':'bold'});
					a.attr({'href':downloadURL,'target':'_blank'}).click(WIUtil.closeCoverPage);
					a.html('點此更新');
				div.append(a);
				oDiv_body.append(div);
		
				break;
				
			case 4 :
				
				/*
				本文
				*/
				var div = $('<div/>').css({'margin-bottom':'10px'});;
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('請選擇讀卡機與卡片');			
				div.append(span);
				oDiv_body.append(div);
				
				/*
				下拉選單
				*/
				div = $('<div/>');
				var isClose = true;
				var errMsg;
				var select = $('<select/>').attr('id','slotDescription').css('width','60%');	
				if(!slots||slots.length==0){
					select.append($('<option></option>').attr('value', '').text('無法偵測到讀卡機'));
					errMsg = '請確認您備妥讀卡機後重新驗證。';
					isReload = true;
				}else{
					for(var index=0; index < slots.length; index++){ 
						var slotDescription = slots[index].slotDescription;
						var text;
						if(slots[index].token instanceof Object){	
							text = slotDescription + ' 卡號:[' + slots[index].token.serialNumber + ']';
							isClose = false;
						}else{
							if(slots[index].token == 'unknown token'){
								text = slotDescription + ' (無法辨識的卡片)';
								errMsg = '讀卡機無法辨識卡片，將重新驗證。';
							}else{
								text = slotDescription + ' (未插卡)';
								errMsg = '讀卡機未插卡，將重新驗證。';
							}	
						}

						select.append($('<option></option>').attr('value', slotDescription).text(text));
					}
				}
				div.append(select);
				oDiv_body.append(div);
				
				select.on('change', function(){
					options.slotDescription = select.val();
				})
				
				options.slotDescription = select.val();
				
				/*
				按鈕
				*/
				div = $('<div/>').css({'margin-top':'20px','margin-bottom':'40px'}); //TODO
				var button = $('<button/>').addClass('greenbn').attr('type','button');
				
				//TODO
				/*
				if(isClose){
					button.addClass('close'); 
				}*/
				
				if(isClose){
					button.html('<b>重整</b>');
				}else{
					button.html('<b>確定</b>');
				}
				
				div.append(button);
				oDiv_body.append(div);	
				
				/*
				按扭動作
				*/
				button.click(function(){
				
					if(isClose){
						HiPKI.getPKCS11Info(function(data){
							var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
							if(!data.version){
								creatStep(body, 2);
								createBody(body, 2);
							}else if(data.version !=_currentVersion){
								creatStep(body, 3);
								createBody(body, 3);
							}else {
								creatStep(body, 4);
								createBody(body, 4, data.slots);
							}
							
							displayLightbox(createForm(options.title, body));
						});
						return;
					}
					
					var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
					creatStep(body, 5);
					createBody(body, 5);
					
					displayLightbox(createForm(options.title, body));
				});	
			
				break;
				
			case 5 :
			
				var errMsg = options.errMsg;

				if(errMsg){
					/*
					錯誤訊息
					*/
					var div = $('<div/>').css({'margin-bottom':'10px'});
					var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
					span.html(errMsg);			
					div.append(span);
					oDiv_body.append(div);
					options.errMsg = '';
				}
			
				var containsPID = options.PID ? true :false;
				
				var input_PID;
				
				if(!containsPID){
					/*
					輸入欄位
					*/
					var div = $('<div/>');
					input_PID = $('<input/>').attr({'type':'text','id':'PID','size':'11','maxlength':'10','font-size':'24px'});
					WIUtil.inputTextValueTipsRegister(input_PID, '請輸入身分證字號');
					div.append(input_PID);
					oDiv_body.append(div);
					input_PID.on('change', function(){
						input_PID.slotDescription = input_PID.val(input_PID.val().toUpperCase());
					});
				}
				/*
				輸入欄位
				*/
				var div = $('<div/>');
				var input_pin = $('<input/>').attr({'type':'password','id':'pin','size':'9','maxlength':'8','font-size':'24px'});	
				WIUtil.inputTextValueTipsRegister(input_pin, '請輸入自然人憑證PIN碼');				
				div.append(input_pin);
				oDiv_body.append(div);

				/*
				按鈕
				*/
				div = $('<div/>').css({'margin-top':'20px','margin-bottom':'40px'});//TODO
				var button = $('<button/>').addClass('greenbn').attr('type','button');
				button.html('<b>送出</b>');
				div.append(button);
				
				/*
				按扭動作
				*/
				button.click(function(){
				
					if(input_PID){
						options.PID = input_PID.val();
					}
					
					options.pin = input_pin.val();
				
					var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
					creatStep(body, 5);
					createBody(body, 9);
					displayLightbox(createForm(options.title, body));
					
					setTimeout(function(){
				
					HiPKI.sign(options, function(data){
					
						if(data.ret_code != 0 ){
							var msg = MajorErrorReason(data.ret_code);	
							if(data.last_error){
								msg = msg +' : '+MinorErrorReason(data.last_error);
							}
							if(!containsPID){
								options.PID = '';
							}	
							options.errMsg = msg;
							var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
							creatStep(body, 5);
							createBody(body, 5);
							displayLightbox(createForm(options.title, body));
							return;
						}
						
						options.signedDataB64 = data.signature;	
							
						HiPKI.doVerifyP7(options);
						
						var resp = options.resp;
						
						if(resp.resultErrorCode == 0){
							options.UUID = resp.UUID;	
							var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
							creatStep(body, 8);
							createBody(body, 8);
							displayLightbox(createForm(options.title, body));
						}else{									
							var msg = VAErrorReason(parseInt(resp.resultErrorCode));	
							options.errMsg = msg;
							if(!containsPID){
								options.PID = '';
							}
							var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
							creatStep(body, 7);
							createBody(body, 7);
							displayLightbox(createForm(options.title, body));
						}
					});
					}, 500 );
				});	
				oDiv_body.append(div);	
		
				break;	

			case 7 :

				/*
				本文
				*/
				var div = $('<div/>').css({'text-align':'left','margin-left':'80px'});
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
					span.html('憑證驗證失敗！');			
				div.append(span);
				oDiv_body.append(div);
				
				div = $('<div/>').css({'text-align':'left','margin-left':'80px'});
				span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html(options.errMsg);			
				div.append(span);
				oDiv_body.append(div);
				
				options.errMsg = '';
				
				/*
				按鈕
				*/
				div = $('<div/>').css({'margin-top':'20px','margin-bottom':'40px'});//TODO
				var button = $('<button/>').addClass('greenbn').attr('type','button');
					button.html('<b>重新驗證</b>');
				div.append(button);
				oDiv_body.append(div);

				/*
				按扭動作
				*/
				button.click(function(){	
					var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
					creatStep(body, 5);
					createBody(body, 5);
					
					displayLightbox(createForm(options.title, body));
				});		
				
				break;
				
			case 8 :
				/*
				本文
				*/
				var div = $('<div/>');
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('驗證成功');			
				div.append(span);
				oDiv_body.append(div);

				/*
				按鈕
				*/
				div = $('<div/>').css({'margin-top':'20px','margin-bottom':'40px'});//TODO
				var button = $('<button/>').addClass('greenbn').attr('type','button');
				button.html('<b>' + options.SuccessBtnTitle + '</b>'); //TODO
				div.append(button);
				oDiv_body.append(div);

				/*				
				按扭動作
				*/
				button.click(function(){	
					cbFunction(options.UUID);
					WIUtil.closeCoverPage();
				});		
				
				break;	
			case 9 :
				/*
				本文
				*/
				var div = $('<div/>');
				var span = $('<span/>').css({'color':'#000000','font-size':'24px','font-family':'Microsoft JhengHei'});
				span.html('卡片驗證中...<br><br>');			
				div.append(span);
				oDiv_body.append(div);

				break;
		}
	}
	
	function createForm(title, oDiv_body){

		var oDiv_header = $('<div/>').addClass('header')
			.append($('<div/>').addClass('title').html(title))
			.append($('<div/>').addClass('close').append('<a href="javascript:;"></a>').click(WIUtil.closeCoverPage));

		var oForm = $('<form/>').append(oDiv_header).append(oDiv_body);
		
		return oForm;
	}

	function displayLightbox(displayForm){
		var opts = {};
			opts.type = 'html';
			opts.disaplyServiceLine = true;
			opts.html = displayForm;
			opts.canClose = true;//TODO
		WIUtil.lightbox(opts);
	}

	return {
	
		startCheck:function(config){

			options = {};
			
			options.title = config.title ? config.title : '自然人憑證驗證';
			options.SuccessBtnTitle = config.SuccessBtnTitle ?  config.SuccessBtnTitle : '完成'; //TODO
			
			/*
			local Server驗證用
			*/
			options.PID = config.PID;
			options.pin = config.pin;
			options.tbs = config.tbs ? config.tbs : 'TBS';
			options.tbsEncoding = config.tbsEncoding ? config.tbsEncoding : 'NONE';
			options.hashAlgorithm = config.hashAlgorithm ? config.tbsEncoding : 'SHA256';
			options.nonce = config.nonce;
			options.withCardSN = config.withCardSN ? config.tbsEncoding : 'false';
			options.signatureType = config.signatureType ? config.tbsEncoding : 'PKCS7';

			/*
			Cathay Server驗證用
			*/
			options.ip = config.ip;
			options.tname = config.tname;
			options.user = config.user;
			options.attr01 = config.attr01;
			options.clientIP = config.clientIP;
			options.src = config.src;
			options.case_no = config.case_no;
			options.memo = config.memo;
			options.password = config.pin;
			options.isAjax = 'Y';
			
			cbFunction = config.cb;
		
			var body = $('<div/>').addClass('body').css({'text-align':'center','vertical-align':'middle','width':'100%'});
			creatStep(body, 1);
			createBody(body, 1);

			displayLightbox(createForm(options.title, body));
		}
	};
};