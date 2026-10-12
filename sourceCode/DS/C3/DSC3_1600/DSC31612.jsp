<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC31612.jsp
作者：陳宥銓
功能：匯款單入帳金額分配
完成：2013/09/26
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src='${htmlBase}/CM/js/ui/TableUI.js'></script>     <%-- 表格用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/PageUI.js'></script>      <%-- 標準外框表格 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/JavaScript" src='${htmlBase}/CM/js/calendar.js'></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/validation.js'></script>	<%-- 檢核用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC31612().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31612(){
	var gridA;
	var gridB;
	var gridC;
	var gridD;
	var valid;
	var BillList;
	var PAY_TYPE="";
	var GETINT_CODE="";
	var SPEC="0";
	var dataListA=[];
	var dataListB=[];
	var dataListC =[];
	var borrowCount = "0";
	var isCash = false;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1612/" + actionName,
			{  
				parameters: params, 
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}			
			});
	}
	
	//檢核
	function initValidation(){
		Validation.addAllThese([
			[ 'validateRECEIPT_SERNO', '單據序號輸入有誤!',
				function(v){
					return v.length == 10 ;
				}
			],
			[ 'AMT_Required', '請輸入繳暫收款金額',
				function(value,elem){  				
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || value;
				}
			],
			// ====================== 繳款服務單檢核 START ====================== 
			['validPAY_RELATION', '請選擇匯款人關係', 
			function(v) { 
				return '請選擇' != v;
			}],
			//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
			//繳款人為法人(1)->關係不可為CPSW(配偶父母子女負責人)
			['validPAY_RELATION2', '繳款人為[法人]，關係別不可選[配偶、父母、子女、負責人]', 
				function(v) { 
					if($F('COPR_CODE') == '1'){
						if(v=='C'||v=='P'||v=='S'||v=='W'){
							return false;
						}
					}
					return true;
				}],
			[ 'checkPAY_RELATION', '若匯款人關係為[其他]需填入其他關係、代繳原因',
				function(v, node){
					var selectValue = '';
					var pre = node.previousSiblings();
					for(var i = 0; i < pre.length; i++){
						var item = pre[i];
						if(item.nodeName == 'SELECT'){
							selectValue = item.getValue();
						}
					}
					if(selectValue == 'O'){
						return !Validation.get('IsEmpty').test(v);
					}
					return true;
				}
			],
			[ 'checkCHIEF', '繳款人為[法人]需填入負責人姓名',
				function(v){
					if ($('COPR_CODE').value == '1'){
                        return !Validation.get('IsEmpty').test(v);		  
					}
					return true;
				}
			],
			//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
			//繳款人為法人(1)且國別為TW->ID需符合統編;繳款人為自然人(0)->ID需服和ID檢核
			[ 'checkPAY_ID', '請輸入正確身分證字號、統一編號或居留證號',
				function(v){
					  if ($('COPR_CODE').value == '1'){
						   if ($('NATION_CODE').value != 'TW'){
								return v.length == 10;
							} else {
					  
							   var checkUniSN = validation.checkUniSN( v );		
								//需符合統編規則，否則顯示提示訊息："繳款種類為法人，必須符合統編規則，是否繼續作業"，若選擇是，則往下繼續執行作業
								if(checkUniSN != true) {
									if(!confirm('繳款種類為[法人]，輸入值不符合統編規則，是否繼續作業')) {
										return;
									}
								}
								return true;
							}
					  } else if ($('NATION_CODE').value != 'TW'){
							return v != '';
					  } else {
							return validation.checkROCID( v );
					  }					
					return true;
				}
			],
			[ 'checkTEL_NO', '若匯款人關係非為[借款人]且有[現金]金額需填正確[電話]',
				function(v){
					for(var i = 1; i <= borrowCount; i++){
						var PAY_RELATION = 'PAY_RELATION' + i;
						if($(PAY_RELATION) != null){
							if ('B' != $F(PAY_RELATION) && isCash){
		                        return !Validation.get('IsEmpty').test(v);		  
							}
						}
					}
					
					var checkTable = "#-0123456789"; //2018-01-10規則同繳款服務單畫面，僅能填入0~9,-,#
					if(v){
						for ( var i = 0 ; i < v.length ; i ++ ) {
							var val = v.charAt(i) ;   
							if (checkTable.indexOf(val) == -1){
								return false;
							}						
						}
					}
					return true;		
				}
			],	
			//2018-01-12跟壽二毓華確認繳款服務單檢核生日與電話規則皆為 繳現非借款人需填
			[ 'checkBIRTH_DATE', '若匯款人關係非為[借款人]且有[現金]金額需填[生日/法人註冊日期]',
				function(v){
					for(var i = 1; i <= borrowCount; i++){
						var PAY_RELATION = 'PAY_RELATION' + i;
						if($(PAY_RELATION) != null){
							if ('B' != $F(PAY_RELATION) && isCash){
		                        return !Validation.get('IsEmpty').test(v);		  
							}
						}
					}
					return true;					
				}
			],
			//姓名是否輸入檢核
			[ 'checkCHIEF_ID', '若有輸入負責人ID，請也輸入負責人姓名',
				function(v){
					if (v){
                        return !Validation.get('IsEmpty').test($('CHIEF').value);		  
					}
					return true;	
				}
			],
			[ 'checkNATURAL_PERSON1_ID', '若有輸入具控制權之自然人1 ID，請也輸入具控制權之自然人1姓名',
				function(v){
					if (v){
                        return !Validation.get('IsEmpty').test($('NATURAL_PERSON1').value);		  
					}
					return true;	
				}
			],
			[ 'checkNATURAL_PERSON2_ID', '若有輸入具控制權之自然人2 ID，請也輸入具控制權之自然人2姓名',
				function(v){
					if (v){
                        return !Validation.get('IsEmpty').test($('NATURAL_PERSON2').value);		  
					}
					return true;	
				}
			],
			[ 'checkNATURAL_PERSON3_ID', '若有輸入具控制權之自然人3 ID，請也輸入具控制權之自然人3姓名',
				function(v){
					if (v){
                        return !Validation.get('IsEmpty').test($('NATURAL_PERSON3').value);		  
					}
					return true;	
				}
			],
			//姓名長度檢核
			[ 'checkLength60', '姓名長度超過30中文字或60個英文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}		
					return true;					
				}
			],
			<%-- [20190802] (a) 修改：可輸入長度調整為VARCHAR 100 (若有檢核順便調整) --%>
			[ 'checkLength100', '姓名長度超過50中文字或100個英文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 100){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_C', '負責人姓名長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_1', '具控制權之自然人姓名1長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_2', '具控制權之自然人姓名2長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_3', '具控制權之自然人姓名3長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			//問題單編號 20211022-0134 其他關係輸入超過10個中文字，導致寫入不了繳款服務單DTACE017 BY余凱鈞 
			[ 'checkLength20', '其他關係長度超過10個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 20){
						return false;
					}
					return true;
				}
			]
			// ====================== 繳款服務單檢核 END ====================== 
		])
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator', checkDisabled:true});	
	}
	
	function defineValid(type){
		 if(type=='billin'){
			valid.define( "validateRECEIPT_SERNO" , { id: "RECEIPT_SERNO" , errMsg:"單據序號輸入有誤!" } );	
			//valid.define('required' , [{ id : "PAY_RELATION" , errMsg:'匯款人關係不可空白!'}]);	
		}
	}
	
	
						
	var buttons = {
		//索引
		doIndex: function(){
			var url='/DJWeb/servlet/HttpDispatcher/DCG2_0100/prompt?SYS_NO=DP';
			if($F('RMT_SET_NO')){
				url='/DJWeb/servlet/HttpDispatcher/DCG2_0100/prompt?SYS_NO=DP&RMT_SET_NO='+ $F('RMT_SET_NO');
			}
			popupWin.popup({
				src: url
			});	
			popupWin.callbackHandler = buttons.callback_doIndex;
		},
		callback_doIndex : function(records){	
			
 			dataListA = records.RMT_INFO_LIST;	
			for (var idx = 0; idx < dataListA.length; idx++) {
				dataListA[idx]['REMIT_GROUP'] = dataListA[idx]['RMT_SET_NO'];
				dataListA[idx]['REMIT_DATE'] = dataListA[idx]['RMT_DATE'];
				dataListA[idx]['FACE_AMT'] = dataListA[idx]['TRN_AMT'];
				dataListA[idx]['REMIT_SERNO'] = dataListA[idx]['CO_ACNT_NO'];
				if(idx==0){
					//2018-01-30因財會科匯款單不再輸入負責人、具控制權自然人、匯款來源國等欄位，會在繳款服務單就填寫，故改由本畫面自行填入再寫到繳款服務單				
					$('RMT_SET_NO').value=dataListA[idx]['RMT_SET_NO'];
					var ID_KIND = dataListA[idx]['ID_KIND'] || '';
					if (ID_KIND == "2"){ //法人的統編因匯款單系統記錄10碼(前2碼補0)，取後8碼呈現
						$('PAY_ID').value=dataListA[idx]['RMT_ID'].substr(2,8) || '';
						$('CHIEF').enable();
						$('NATURAL_PERSON1').enable();
						$('NATURAL_PERSON2').enable();
						$('NATURAL_PERSON3').enable();
						$('CHIEF_ID').enable();
						$('NATURAL_PERSON1_ID').enable();
						$('NATURAL_PERSON2_ID').enable();
						$('NATURAL_PERSON3_ID').enable();						
					} else {					
						$('PAY_ID').value=dataListA[idx]['RMT_ID'] || '';
						$('CHIEF').disable();
						$('NATURAL_PERSON1').disable();
						$('NATURAL_PERSON2').disable();
						$('NATURAL_PERSON3').disable();
						$('CHIEF_ID').disable();
						$('NATURAL_PERSON1_ID').disable();
						$('NATURAL_PERSON2_ID').disable();
						$('NATURAL_PERSON3_ID').disable();	
						$('CHIEF').value = "";
						$('NATURAL_PERSON1').value = "";
						$('NATURAL_PERSON2').value = "";
						$('NATURAL_PERSON3').value = "";
						$('CHIEF_ID').value = "";
						$('NATURAL_PERSON1_ID').value = "";
						$('NATURAL_PERSON2_ID').value = "";
						$('NATURAL_PERSON3_ID').value = "";								
					}
					$('PAY_NAME').value=dataListA[idx]['RMT_NAME'] || '';
					<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
					$('PAY_NAME_RM').value = dataListA[idx]['RMT_NAME_RM'] || '';
					
					$('COPR_CODE').value=(ID_KIND == "1" ? "0" : "1");				
				}
			}
			
			var borrow = gridD.getAllRecords();  //2018-01-09調整匯款單帶回繳款人ID時要對應下拉選單
			//loop每個下拉選單
			for(var i = 1; i <= borrow.length; i++){
				var PAY_RELATION = $('PAY_RELATION'+i);
				if(PAY_RELATION != null){
					var borrow_id = "";
					for(var j = 1; j < PAY_RELATION.length; j++){ //j=0為"請選擇"
						//取得借款人ID
						borrow_id = PAY_RELATION[j].getAttribute("relation_id") || ''; //取關係人ID
						//選擇對應到的關係 //判斷borrow_id有值再處理
						if(borrow_id && borrow_id == $('PAY_ID').value){
							PAY_RELATION[j].selected = true;
							break;
						}
					}															
				}
			}
			
			gridA.load(dataListA);	
 			buttons.doCal();
 			buttons.doConfirm();
 			//$('TOTAL_AMT').value=parseInt($F('TOTAL_AMT'))+$F('CASH_PAYMT');	
		},
		doCal: function(){
		
			if(dataListA.size()==0){
				alert("請先執行匯款單索引!");
				return;
			}

			ajaxPost( 'calculate', {dataListA : Object.toJSON(dataListA)}
				,function(resp){
					//$('TOTAL_AMT').value=methods.gridFmtRender(resp.TOTAL_AMT+parseInt(methods.fmtRemove($F('TOTAL_AMT'))));
					$('TOTAL_AMT').value=methods.gridFmtRender(resp.TOTAL_AMT+parseInt(methods.fmtRemove($F('CASH_PAYMT'))));
				}
			);	
		},
		
		//清除
		doClear : function(){	
			valid.reset();			
			valid.clear();
			
			//A區清空
			gridA.load();
			$('CASH_PAYMT').value='0';
			$('TOTAL_AMT').value='0';
			$('PRE_CASH_PAYMT').value='0';
			
			//B區清空
			gridB.load();
			$('table_B').hide();
			$('gridB').hide();
		
			//各暫存LIST清空
			dataListA=[];
			dataListB=[];
			dataListC=[];	


			//C區清空
			gridC.load();
			$('table_C').hide();
			$('gridC').hide();
			$('table_D').hide();
			$('table_E').hide();
				
			
		},
		//確認
		doConfirm : function(){
			valid.reset();			
			valid.clear();

			//檢核A區是否有資料
			if(dataListA.size()==0){
				alert("請先執行匯款單索引!")
				return;
			}
			
			//檢核B區是否有資料
			if(dataListB.size()>0){
				alert("已產生匯款單金額分配設定資料!")
				return;
			}
			
			//若隱藏時則讓B顯示
			$('table_B').show();
			$('gridB').show();
		
			dataListB= BillList; 
		    gridB.load(dataListB);
			
			//按完確認A區(重讀)開放點選
			gridA.load(dataListA);	
		},
		//分配
		doAssign : function(record){
			valid.reset();			
			valid.clear();
			
			//每次分配時，要將C區的實繳金額清空			
			for(var i=0; i< dataListB.length ; i++){
				dataListB[i].TRADE_AMT=0;
				dataListB[i].preCheck="N";				
			}
			
			//檢核B區是否有資料
			if(dataListB.size()==0){
				alert("匯款單金額分配無資料!")
				return;
			}
			
			ajaxPost( 'assign', {CheckMap : Object.toJSON(record), BillList : Object.toJSON(dataListB)}
				,function(resp){
					dataListB = resp.rtnList;
					gridB.load(dataListB, null, null, ["Y"]);
				}
			);

		},
		//選取確認
		doChkAssign : function(){
			valid.reset();			
			valid.clear();
			
			var CheckedRecordA = gridA.getCheckedRecord();
			if(CheckedRecordA.length==0){
				alert("請先選取一筆匯款單資料!");
				 return;
			}			
			
			var CheckedRecord = gridB.getCheckedRecord();
			if(CheckedRecord.length==0){
				alert("請至少選取一筆資料!");
				 return;
			}
						
			if(!valid.validate()){
				return;
			}
			
			/*
			for(var i=0 ; i<CheckedRecord.length ; i++){
				if(CheckedRecord[i].REAL_PAYMT <=0){
					alert("請檢查繳款金額是否大於0!");
					return;				
				}
			}
			*/
			
			ajaxPost( 'chkassign', {
				CheckMap : Object.toJSON(CheckedRecordA[0]), 
				BillList : Object.toJSON(CheckedRecord), 
				SPEC : '${SPEC}',
				dataListB : Object.toJSON(gridB.getAllRecords())}
				,function(resp){
					var rtnList = resp.rtnList;
					isCash = resp.isCash;//紀錄是否有現金金額
					//將每次選取確認之項目逐筆加入到D區清單中
					for(var i=0; i< rtnList.length ; i++){
						dataListC.push(rtnList[i]);
					}
					$('table_C').show();
					$('gridC').show();
					$('table_D').show();
					$('table_E').show();					
					gridC.load(dataListC);
					
					//重新顯示尚未分配之清單
					gridB.load(resp.rtnListB);
					dataListB= resp.rtnListB;
					$('RECEIPT_SERNO').value=resp.RECEIPT_SERNO;					
				}
			);
		},
		//取消選取確認
		doCancel : function(){
			valid.reset();			
			valid.clear();
		
			//選取確認LIST清空
			dataListC = [];	
			
			//C區清空
			
			$('table_C').hide();
			$('gridC').hide();
			$('table_D').hide();
			$('table_E').hide();			
			
			//B區重新讀取初始接值之LIST
			dataListB= BillList;	
			gridB.load(BillList);

		},
		//入帳確認
		doBillIn : function(){
			valid.reset();			
			valid.clear();
			
			//判斷D區是否有值
			if(!dataListC.size()>0){
				alert("請產生票據入帳試算結果後，再做入帳確認!")
				return;
			}
			
			//入帳確認檢核
			defineValid('billin');
			if(!valid.validate()){
				return;
			}
			
			//關係人選單檢核
			if(!actions.checkSelectedPAY_RELATIONS()){
				alert("繳款人關係選取有誤，需為同一繳款人，請確認後再重新入帳!");
				return;
			};
			
			$('CHIEF').value = methods.unAsc($('CHIEF').value);
			$('NATURAL_PERSON1').value = methods.unAsc($('NATURAL_PERSON1').value);
			$('NATURAL_PERSON2').value = methods.unAsc($('NATURAL_PERSON2').value);
			$('NATURAL_PERSON3').value = methods.unAsc($('NATURAL_PERSON3').value);
			//$('NATURAL_PERSON4').value = methods.unAsc($('NATURAL_PERSON4').value);
			$('PAY_NAME').value = methods.unAsc($('PAY_NAME').value);
			
					
			var PAY_INFO = {
				RELATION : actions.getPayRelations(),
				PAY_ID : $F('PAY_ID'),
                COPR_CODE : $F('COPR_CODE'),
                PAY_NAME : $F('PAY_NAME'),
                <%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
                PAY_NAME_RM : $F('PAY_NAME_RM'),
				BIRTH_DATE : $F('BIRTH_DATE'),
				TEL_NO : $F('TEL_NO'),
				NATION_CODE : $F('NATION_CODE'),
				OCR_NATION_CODE : $F('OCR_NATION_CODE'),
                CHIEF : $F('CHIEF'),
				NATURAL_PERSON1 : $F('NATURAL_PERSON1'),
                NATURAL_PERSON2 : $F('NATURAL_PERSON2'),		
				NATURAL_PERSON3 : $F('NATURAL_PERSON3'),
				CHIEF_ID : $F('CHIEF_ID'),
				NATURAL_PERSON1_ID : $F('NATURAL_PERSON1_ID'),
				NATURAL_PERSON2_ID : $F('NATURAL_PERSON2_ID'),		
				NATURAL_PERSON3_ID : $F('NATURAL_PERSON3_ID'),
				FUND_SORC_COUNTRY : $F('FUND_SORC_COUNTRY'), //匯款來源國 //2019-01-28：申請書 181128001539 - 繳款服務單新增檢核
				noWrite : 'N' //需寫入繳款服務單
            };
		
			ajaxPost( 'billin', {
				BillList : Object.toJSON(dataListC), 
				PAY_TYPE : '${PAY_TYPE}',
				ISTIC : '${ISTIC}',
				SPEC : '${SPEC}',
				GETINT_CODE : '${GETINT_CODE}',
				RECEIPT_SERNO:$F('RECEIPT_SERNO'),
				CASH_PAYMT:$F('CASH_PAYMT'),
				TOTAL_AMT:$F('TOTAL_AMT'),
				PAY_INFO : Object.toJSON(PAY_INFO)}
				,function(resp){
					if(resp.ERR_MSG){
					    alert(resp.ERR_MSG);
						var parms = { //180917:申請書(180828001571):新增可疑交易檢核
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						}; 		
						actions.doPopup( parms );	
					}
					//2019-01-28：申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
					//威國：該繳款人為業務同仁，比照保費部作業，依「受理保戶以匯款方式繳交保險費應注意事項」不得收取大於五萬元之現金保費後，再以匯款單、支票等其他方式入帳，
					else if(resp.BEFORE_TIPS_MSG){//執行前提示訊息
				    	if(!confirm(resp.BEFORE_TIPS_MSG)){//點選確認後繼續作業
				    		return;
				    	}
				    	ajaxPost( 'billin', {	BillList : Object.toJSON(dataListC), 
							PAY_TYPE : '${PAY_TYPE}',
							ISTIC : '${ISTIC}',
							SPEC : '${SPEC}',
							GETINT_CODE : '${GETINT_CODE}',
							RECEIPT_SERNO:$F('RECEIPT_SERNO'),
							CASH_PAYMT:$F('CASH_PAYMT'),
							TOTAL_AMT:$F('TOTAL_AMT'),
							PAY_INFO : Object.toJSON(PAY_INFO),
							isSecondTime : 'Y',
							TIPS_MSG : resp.TIPS_MSG }
						,function(resp){	
							successFuncForBillin(resp);	
		    			}); 
		    		}else {
						successFuncForBillin(resp);
					}
				}			
			);
		}
	};
	
	function successFuncForBillin(resp){
		if(resp.TIPS_MSG){
			alert(resp.TIPS_MSG); //2018-01-29提示：負責人或具控制權自然人若無ID，且為制裁名單，需提示(因無ID資訊無法填寫洗錢防制檢核紀錄，請確實申報，並與收費管理科聯繫)
		}				
		var LP_JSON = {	
			action : '<%=dispatcher%>/DSC3_1620/prompt',
			//BillinList : resp.BillinList,
			BillListStr : resp.BillListStr,
			PAY_TYPE : '${PAY_TYPE}',
			ISTIC : '${ISTIC}',
			SPEC : '${SPEC}',
			INPUT_ID : resp.INPUT_ID,
			GETINT_CODE : '${GETINT_CODE}',	
			INPUT_DEPT : resp.INPUT_DEPT,
			RECEIPT_SERNO: $F('RECEIPT_SERNO')
		};
		CSRUtil.linkTo(LP_JSON , 'form');
	}
	
	var methods = {
		//轉全形
		unAsc : function (text) {
		  var asciiTable = "!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
		  var big5Table = "%uFF01%u201D%uFF03%uFF04%uFF05%uFF06%u2019%uFF08%uFF09%uFF0A%uFF0B%uFF0C%uFF0D%uFF0E%uFF0F%uFF10%uFF11%uFF12%uFF13%uFF14%uFF15%uFF16%uFF17%uFF18%uFF19%uFF1A%uFF1B%uFF1C%uFF1D%uFF1E%uFF1F%uFF20%uFF21%uFF22%uFF23%uFF24%uFF25%uFF26%uFF27%uFF28%uFF29%uFF2A%uFF2B%uFF2C%uFF2D%uFF2E%uFF2F%uFF30%uFF31%uFF32%uFF33%uFF34%uFF35%uFF36%uFF37%uFF38%uFF39%uFF3A%uFF3B%uFF3C%uFF3D%uFF3E%uFF3F%u2018%uFF41%uFF42%uFF43%uFF44%uFF45%uFF46%uFF47%uFF48%uFF49%uFF4A%uFF4B%uFF4C%uFF4D%uFF4E%uFF4F%uFF50%uFF51%uFF52%uFF53%uFF54%uFF55%uFF56%uFF57%uFF58%uFF59%uFF5A%uFF5B%uFF5C%uFF5D%uFF5E";
			
		  var result = "";
		  for ( var i = 0 ; i < text.length ; i ++ ) {
			var val = text.charAt(i) ;   
			if (val == " "){
				result += "　";
			} else {
				var j = asciiTable.indexOf(val) * 6 ;        
				result += ( j > -1 ? unescape(big5Table.substring( j , j + 6 ) ) : val ); 
			}		
		  }
		  return result;
		},
		//金額格式化
		gridFmtRender : function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		},		
		//移除逗號
		fmtRemove : function(value){
			return value.replace(/,/g, "");
		}
	};
	
	var actions = {
		//POP UP 開啟新視窗
	  	doPopup : function ( parms ) {			
			var LINK_TO = parms.LINK_TO;
	  		if('AIL0_1300'==LINK_TO){	
	  			//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
	  			parms.QUERY_START_DATE = parms.CURRENT_DATE;
	  			parms.QUERY_END_DATE = parms.CURRENT_DATE;
	  					
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
					'parameters' :  {
						'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
					}
				});
			}else if('AIL1_1000'==LINK_TO){//180917:申請書(180828001571):新增可疑交易檢核
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL1_1000/query',
					'parameters' :  {
						'QUR_ID': parms.QUERY_ID,//客戶ID/繳款人ID 
						'QUR_DATE_STR':parms.CURRENT_DATE,
						'QUR_DATE_END':parms.CURRENT_DATE,
						'COUNT':'0',
						'PAGE':'0',
						'TotalPage':'0'
					}
				});
			}
	  	},
		observeEvent : function(){
			$('btn_INDEX').observe('click',buttons.doIndex);
			//$('btn_CAL').observe('click',buttons.doCal);
			//$('btn_CONFIRM').observe('click',buttons.doConfirm);
			$('btn_CLEAR').observe('click',buttons.doClear);
		
			$('btn_CHKASSIGN').observe('click',buttons.doChkAssign);
			$('btn_CANCEL').observe('click',buttons.doCancel);
			$('btn_BILLIN').observe('click',buttons.doBillIn);
			$('btn_BILLIN_2').observe('click',buttons.doBillIn);
			
			$('CASH_PAYMT').observe('blur',function(event){	//補現、繳票金額合計						
				var cashAmt=parseInt($F('CASH_PAYMT'));
				if(cashAmt<0){
					alert("補現金額不得為負!");
					$('CASH_PAYMT').value = 0;
					return;
				}
				//$('TOTAL_AMT').value=methods.gridFmtRender(parseInt(methods.fmtRemove($F('TOTAL_AMT')))+cashAmt);	
				
				$('TOTAL_AMT').value=parseInt($F('TOTAL_AMT'))+cashAmt-parseInt($F('PRE_CASH_PAYMT'));	
				$('PRE_CASH_PAYMT').value=cashAmt;				
		  	});	
		  	
		  	$('btn_return').observe('click', function(){
				CSRUtil.linkBack();
			});
			
			//僅第一筆匯款人關係連動帶出匯款人ID及姓名
            var PAY_RELATION = $('PAY_RELATION1');
            if(PAY_RELATION != null){
				PAY_RELATION.observe('change', function(event){
					var selectItem = $('PAY_RELATION1').options[$('PAY_RELATION1').selectedIndex];
					$('BIRTH_DATE').value = selectItem.getAttribute('BIRTH_DATE') || '';
					$('TEL_NO').value = selectItem.getAttribute('DAY_TEL_NUM') || '';
					$('OTHER_RELATION1').value = '';
					$('PAY_REASON1').value = '';
					
					//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
					//select連動:關係為BG(借款人,保證人)->ID,NAME disable 
					//匯款的繳款人ID,姓名是從匯款單帶入，顧不須特別控制(本來就是disable)
				});
			}
			
			
			<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
			$('PAY_NAME_RM').observe('blur', function(event){
				$('PAY_NAME_RM').value = methods.unAsc($('PAY_NAME_RM').value);
			});
		},
		uiControl : function(){
			$('table_B').hide();
			$('gridB').hide();
						
			$('table_C').hide();
			$('gridC').hide();
			$('table_D').hide();
			$('table_E').hide();
			
			if(SPEC=="0" && (PAY_TYPE=="1" ||PAY_TYPE=="7" ||PAY_TYPE=="4")){
				$('billWithNoPaper').hide();
			}else{
				$('billWithPaper').hide();
			}
		},
		setGrid_A : function(){
			gridA = new TableUI({
				table: $('gridA'), pageSize: 20, allSortable: false, 
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return;//檢核box狀態，避免連續點選，造成載入資料有問題
						buttons.doAssign(records[0]);
					}
			
				},				
				column: [
					{header:"匯款單組號", key:'REMIT_GROUP'},
					{header:"行庫代號", key:'BANK_NO'},
					{header:"銀行帳號", key:'ACNT_NO'},
					{header:"匯款日期", key:'REMIT_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"匯款金額", key:'FACE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val, "#,###") : 0 ; 
					}}
				]	
			});
		},
		setGrid_B : function(){
			gridB = new TableUI({
				table: $('gridB'), pageSize: 20, allSortable: false, overDiv : false,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					valueKey: 'preCheck'
				},				
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM',
					    render: function (rec,value){
							if("4"==rec.PAY_KIND){
								return "暫收款";
							}else if("3"==rec.PAY_KIND){
								return "清償";
							}else if("2"==rec.PAY_KIND){
								return "部入";
							}else if("1"==rec.PAY_KIND){
								return "變更應繳日";
							}else{
								return value;
							}
						}
					},
					{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"繳款金額", key:'TRADE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						},  
						input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}        
					},
					{header:"現金", key:'CASH_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val || val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						},
							input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}        
					}
				]		
			});
		},
		setGrid_C : function(){
			gridC = new TableUI({
				table: $('gridC'), pageSize: 20, allSortable: false, overDiv : false,		
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM',
					    render: function (rec,value){
							if("4"==rec.PAY_KIND){
								return "暫收款";
							}else if("3"==rec.PAY_KIND){
								return "清償";
							}else if("2"==rec.PAY_KIND){
								return "部入";
							}else if("1"==rec.PAY_KIND){
								return "變更應繳日";
							}else{
								return value;
							}
						}
					},
					{header:"應繳金額", key:'DUTY_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"實繳金額", key:'REAL_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
						{header:"現金", key:'CASH_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},					
					{header:"繳款金額", key:'TRADE_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"匯款單組號", key:'REMIT_GROUP'},
					{header:"匯款金額", key:'FACE_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}}				
				]	
			});
		},
		setGrid_D : function(){
			gridD = new TableUI({
				table: $('gridD'),
				pageSize:0,
				column:[
					{header:'借款人', key:'BORROW_NAME', attrs:{Width:"50%", style:"text-align: left"}},
					{header:'匯款人關係', key:'PayRelationList', attrs:{style:"text-align: left"}, 
						render: function(record, value, sn){
							var div = new Element('div');
							var select = new Element('select', {'class':'validPAY_RELATION validPAY_RELATION2', 'id':'PAY_RELATION'+sn}).insert(new Element('option').update('請選擇'));
							var inputOTHER_RELATION = new Element('input',{'class':'textBox2 checkPAY_RELATION checkLength20', 'id':'OTHER_RELATION'+sn, 'type':'text', 'size':'30', 'maxlength':'60'});
							var inputPAY_REASON = new Element('input',{'class':'textBox2 checkPAY_RELATION', 'id':'PAY_REASON'+sn, 'type':'text', 'size':'30', 'maxlength':'60'});
							var hasC = false, hasP = false, hasS = false, hasW = false;
							
							for(var i = 0; i < value.size(); i++){
								var birthday = value[i].BIRTH_DATE;
								var tel = value[i].DAY_TEL_NUM;
								if(birthday){
									birthday = toROC(birthday);
								}else{
									birthday = '';
								}
								if(!tel){
									tel = '';
								}
								switch (value[i].PAY_RELATION) {
									case "C":
										hasC = true;
										break;
									case "P":
										hasP = true;
										break;
									case "S":
										hasS = true;
										break;
									case "W":
										hasW = true;
										break;
								}
								var option = new Element('option',{'value':value[i].PAY_RELATION, 'relation_id':value[i].RELATION_ID, 'relation_name':value[i].RELATION_NAME, 'relation_name_rm':(value[i].RELATION_NAME_RM||''), 'birth_date':birthday, 'day_tel_num':tel});
								option.update(value[i].PAY_RELATION_NAME + ':' + value[i].RELATION_ID + '(' + value[i].RELATION_NAME + ')');
								select.insert(option);
							}
							if(!hasC){
								var option = new Element('option',{'value':'C'}).update('配偶');
								select.insert(option);
							}
							if(!hasP){
								var option = new Element('option',{'value':'P'}).update('父母');
								select.insert(option);
							}
							if(!hasS){
								var option = new Element('option',{'value':'S'}).update('子女');
								select.insert(option);
							}
							if(!hasW){
								var option = new Element('option',{'value':'W'}).update('負責人');
								select.insert(option);
							}
							select.insert(new Element('option',{'value':'O'}).update('其他'));
							
							div.insert(select).insert('其他關係').insert(inputOTHER_RELATION).insert('代繳原因').insert(inputPAY_REASON);
							return div;
                        }}
				]
			});
		},
		getPayRelations : function(){
			var relations = [];
			for(i = 0; i < gridD.getAllRecords().length; i++){
				var pay_relation = 'PAY_RELATION' + (i+1);
				var other_relation = 'OTHER_RELATION' + (i+1);
				var pay_reason = 'PAY_REASON' + (i+1);
				var relation = {
					BORROW_ID : gridD.getAllRecords()[i].BORROW_ID,
					BORROW_NAME : gridD.getAllRecords()[i].BORROW_NAME,
	                PAY_RELATION : $F(pay_relation),
	                OTHER_RELATION: $F(other_relation),
	                PAY_REASON : $F(pay_reason)
				};
				relations.push(relation);
			}
			return relations;
		},
		initLoadDatas : function(){
			//初始接BillList
			<c:choose>
				<c:when test='${not empty BillList}'>
				   BillList = ${BillList};
				   PAY_TYPE = ${PAY_TYPE};
				   SPEC = ${SPEC};
				   if(PAY_TYPE=="2"){
				   	GETINT_CODE = '${GETINT_CODE}';
				   }
				</c:when>
				<c:otherwise>
				   BillList = [];
				</c:otherwise>
			</c:choose>
			
			gridD.load(${PayRelationList} || []);
			borrowCount = gridD.getAllRecords().length || 0; //2018-01-03申請書-繳款服務單調整取關係人清單筆數
		},
		checkSelectedPAY_RELATIONS : function(){		
			var onlyOnePayID = []			
			//loop每個下拉選單
			for(var i = 1; i <= borrowCount; i++){
				var PAY_RELATION = $('PAY_RELATION'+i);
				if(PAY_RELATION != null){
					var borrow_id = PAY_RELATION[PAY_RELATION.selectedIndex].getAttribute("relation_id");
					if(borrow_id){ //null不理他
						if(onlyOnePayID.length == 0){ //沒有紀錄則放入
							var obj = {};
							obj['PayID'] = borrow_id;
							onlyOnePayID.push(obj);
						}else{ //有紀錄則檢查一不一樣
							if(onlyOnePayID[0]['PayID'] != borrow_id){
								return false;
							}
						}
					}
				}
			}
			if(onlyOnePayID.length != 0 && onlyOnePayID[0]['PayID'] != $F('PAY_ID')){
				return false;
			}
			return true;
		}
	};
	
	return{	
		initApp:function(){	
			<cathay:LocaleDisplay sysCode="DS" 	var="localeDisplay" dateFields="BIRTH_DATE"/>
			PageUI.createPageWithAllBodySubElement('DSC31612','核心放款','繳款方式匯款單',1);
			
			actions.setGrid_A();
			actions.setGrid_B();
			actions.setGrid_C();
			actions.setGrid_D();
			
			actions.initLoadDatas();			
					
			actions.observeEvent();
			
			initValidation();
			
			actions.uiControl();
			
			autoFormatToNumber();
						
			PageUI.resize();			
			displayMessage();		
		}
	};	
}
--></script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>				
				<td class="tbYellow0" colspan='4'><B>匯款單清單</B>
					<input type="button" class="button" id="btn_INDEX" value="匯款單輸入∕索引"/>	
					<input type="button" class="button" id="btn_CLEAR" value="清除"/>
					<input id="btn_return" type="button" class="button" value="回上一頁" />
					<input type="hidden" name="RMT_SET_NO" id="RMT_SET_NO" value=""/>		
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">補現金額</td>		
				<td class="tbYellow2" width="10%">
						<input id="CASH_PAYMT" type='text' datatype="number" class= 'textBox2'  size='12' maxlength='12' value='0'/>
						<input  type = 'hidden'  id = 'PRE_CASH_PAYMT' value='0'/>
				</td>	
				<td class="tbYellow" width="10%">合計</td>		
				<td class="tbYellow2" width="70%">
						<input id="TOTAL_AMT" type='text' datatype="number" class= 'textBox2'  size='12' maxlength='12' value='0' readOnly/>
				</td>	
			</tr>
		</table>
		<table id="gridA" width="100%" class="grid" ></table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>匯款單金額分配設定</B>
					<input type="button" class="button" id="btn_CHKASSIGN" value="選取確認"/>	
				</td>
			</tr>
		</table>
		<table id="gridB" width="100%" class="grid" ></table>
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>票據入帳試算結果</B>
					<input type="button" class="button" id="btn_CANCEL" value="取消選取確認"/>	
				</td>
			</tr>
		</table>			
		<table id="gridC" width="100%" class="grid" ></table>
		<table id="table_E" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" colspan= "8"><B>匯款人資訊</B>
				</td>
			</tr>
			<tr><td colspan= "8"><div id="gridD" class="grid"></div></td></tr>
			<tr>		
				<td class="tbYellow" rowspan="2"  width="10%">匯款人ID</td>
				<td class="tbYellow2" rowspan="2"  width="15%">
					<input id="PAY_ID" type="text" class="textBox2 checkPAY_ID" size='15' maxlength="10" value="" disabled/>
					<select id="COPR_CODE" name="COPR_CODE" disabled>
						<option value="0">個人</option>
						<option value="1">法人</option>					
					</select>					
				</td>
				<td class="tbYellow" width="10%">匯款人姓名/法人名稱</td>
				<td class="tbYellow2" width="15%">
					<input id="PAY_NAME" type="text" class="textBox2 checkLength100" size='30' maxlength="100" value="" disabled/>
				</td>
				<td class="tbYellow" rowspan="2"  width="10%">匯款人生日/法人註冊日期</td>
				<td class="tbYellow2" rowspan="2"  width="15%">
					<input id="BIRTH_DATE" type="text" class="textBox2 checkBIRTH_DATE" size='30' maxlength="60" value=""/>
				</td>
				<td class="tbYellow" rowspan="2"  width="10%">匯款人電話</td>
				<td class="tbYellow2" rowspan="2"  width="15%">
					<input id="TEL_NO" type="text" class="textBox2 checkTEL_NO" size='30' maxlength="30" value=""/>(請填：0~9,-,#)
				</td>
			</tr>
				<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
			<tr>
				<td class="tbYellow">匯款人姓名/法人名稱(羅馬拼音)</td>
				<td class="tbYellow2">
					<input id="PAY_NAME_RM" type="text" class="textBox2 checkLength100" size='30' maxlength="100" value="" disabled/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">匯款人國籍</td>
				<td class="tbYellow2" width="15%">
					<select id="NATION_CODE" name="NATION_CODE">
						<c:forEach var="map" items="${NATION_CODEList}">
								<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">匯款人居住國</td>
				<td class="tbYellow2" width="15%">
					<select id="OCR_NATION_CODE" name="OCR_NATION_CODE" >
						<c:forEach var="map" items="${NATION_CODEList}">
								<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" width="10%">負責人ID</td>
				<td class="tbYellow2" width="15%">
					<input id="CHIEF_ID" type="text" class="textBox2 checkCHIEF_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">負責人姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="CHIEF" type="text" class="textBox2 checkCHIEF checkLength60_C" size='30' maxlength="60" value=""/>
				</td>				
			</tr>
			<tr>			
				<td class="tbYellow" width="10%">具控制權之自然人1 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON1_ID" type="text" class="textBox2 checkNATURAL_PERSON1_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">具控制權之自然人1 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON1" type="text" class="textBox2 checkLength60_1" size='30' maxlength="60" value=""/>
				</td>	
				<td class="tbYellow" width="10%">具控制權之自然人2 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON2_ID" type="text" class="textBox2 checkNATURAL_PERSON2_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>	
				<td class="tbYellow" width="10%">具控制權之自然人2 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON2" type="text" class="textBox2 checkLength60_2" size='30' maxlength="60" value=""/>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" width="10%">具控制權之自然人3 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON3_ID" type="text" class="textBox2 checkNATURAL_PERSON3_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>	
				<td class="tbYellow" width="10%">具控制權之自然人3 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON3" type="text" class="textBox2 checkLength60_3" size='30' maxlength="60" value=""/>
				</td>
				<td class="tbYellow" width="10%">匯款來源國</td>
				<td class="tbYellow2" width="15%" colspan="3">
					<select id="FUND_SORC_COUNTRY" name="FUND_SORC_COUNTRY">
						<c:forEach var="map" items="${NATION_CODEList}">
								<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
						</c:forEach>
					</select>
				</td>				
			</tr>
		</table>			
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0">
					<div id="billWithPaper">
					<B>請在印表機放入您的空白單據，其單據序號為</B>
							<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10" value="${RECEIPT_SERNO}"/>
							<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>
							<br><B>註：若此交易為"繳多期款項"，請您務必放入"連續之有效空白單據"，因系統會自動給定上述空白單據之下一連續單據序號(序號不可中斷)</B>
					</div>
					<div id="billWithNoPaper">
					<input type="button" class="button" id="btn_BILLIN_2" value="入帳確認"/>
					</div>
				</td>
				<!-- 
				<td class="tbYellow0"><B>請在印表機放入您的空白單據，其單據序號為</B>
					<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10 value="${RECEIPT_SERNO}" />
					<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>
					<br><B>註：若此交易為"繳多期款項"，請您務必放入"連續之有效空白單據"，因系統會自動給定上述空白單據之下一連續單據序號(序號不可中斷)</B>
				</td>
				 -->
			</tr>
		</table>
	</form>
</body>
</html>		