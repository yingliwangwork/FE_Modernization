<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC32300.jsp
功能：法扣入人工帳
作者：溫子?
完成：2013/05/23
      2018-01-29因應繳款服務單調整，新增負責人ID、具控制權自然人1~3的ID欄位
      2018-07-11備註欄改字元數檢核
	  2019-07-01 新增【繳款人姓名/法人名稱(羅馬拼音)(PAY_NAME_RM)】欄位
	  [20241104] 修改件 難字調整 吳志鴻
 -->

<html>
<head>
<%-- <meta http-equiv='Content-Type' content='text/html; charset=big5'>--%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src='${htmlBase}/CM/js/RPTUtil.js'></script>         <%-- 報表列印 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/calendar.js'></script>

<%-- [20241104] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type='text/javascript'>

Event.observe(window, 'load', new DSC32300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC32300(){
	var rtnMap=[];
	var query_BALC_NO;
	var isQry;
	var RemitList=[];	
	var valid;
	var validQuery;
	var grid;
	var noWrite = "N";  //Y.不寫繳款服務單也不列印 R.不寫繳款服務單。但要印單據 N.要寫繳款服務單要印單據
	var PAY_INFO=[];
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_2300/" + actionName,
			{  
			parameters: params, 
			onSuccess:function(response){
				var resp = response.responseJSON;
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
	//共用字元數計算
	function calWordLength( v ){
		var fullWordArray = v.match(/[^\x00-\xff]/g);
		var halfWordArray = v.match(/[\x00-\xff]/g);

		var fullWordLength = fullWordArray==null?0:fullWordArray.length;
		var halfWordLength = halfWordArray==null?0:halfWordArray.length;
		return fullWordLength*(window.charCountsByte || 2)+halfWordLength;
	}
	
	//檢核
	function initValidation(){
		
		Validation.addAllThese([
			['validBALC_NO', '暫應收編號格式有誤', function(v , node) { 
				if(v){
					<%--暫應收編號12碼英數字--%>
					return v.length == 12 && (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}],
			[ 'checkInputLength_mod', '備註欄文字超過長度限制(40個字元)',
				function(v){
					if( calWordLength(v) > 40){
						return false;
					}
					return true;	
				}
			],
			// ====================== 繳款服務單檢核 START ====================== 
			['validPAY_RELATION', '請選擇繳款人關係', 
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
			[ 'checkPAY_RELATION', '若繳款人關係為[其他]需填入代繳原因、其他關係',
				function(v){
					if($('PAY_RELATION') != null){
						if ('O' == $F('PAY_RELATION') && 'CB' == $F('BALC_KIND')){
	                        return !Validation.get('IsEmpty').test(v);		  
						}
					}
					return true;		
				}
			],
			[ 'checkCHIEF', '繳款人為[法人]需填入負責人姓名',
				function(v){
					if ($('COPR_CODE').value == '1' && $('BALC_KIND').value == 'CB'){
                        return !Validation.get('IsEmpty').test(v);		  
					}
					return true;					
				}
			],
			[ 'checkPAY_ID', '請輸入正確身分證字號、統一編號或居留證號',
				function(v){
					if (v && $('BALC_KIND').value == 'CB'){
					  if ($('COPR_CODE').value == '1'){
						   if ($('NATION_CODE').value != 'TW'){
								return v.length == 10;
							} else {
					  
							   var checkUniSN = validation.checkUniSN( v );		
								//需符合統編規則，否則顯示提示訊息："繳款種類為法人，必須符合統編規則，是否繼續作業"，若選擇是，則往下繼續執行作業
								if(checkUniSN != true) {
									if(!confirm('繳款種類為法人，輸入值不符合統編規則，是否繼續作業')) {
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
					}					
					return true;
				}
			],
			[ 'checkTEL_NO', '若繳款人關係非為[借款人]且繳款方式為[現金]需填正確[電話]',
				function(v){
					if($('PAY_RELATION') != null){
						if ('B' != $F('PAY_RELATION') && '0' == $F('ISTIC')){
							var checkTable = "#-0123456789"; //2018-01-09規則同繳款服務單畫面，僅能填入0~9,-,#
							if($F('TEL_NO')){
								for ( var i = 0 ; i < v.length ; i ++ ) {
									var val = v.charAt(i) ;   
									if (checkTable.indexOf(val) == -1){
										return false;
									}						
								}
								return !Validation.get('IsEmpty').test(v);
							} else {				
								return !Validation.get('IsEmpty').test(v);	
							}							
						}
					}
					return true;		
				}
			],
			//2018-01-12跟壽二毓華確認繳款服務單檢核生日與電話規則皆為 繳現非借款人需填
			[ 'checkBIRTH_DATE', '若繳款人關係非為[借款人]且繳款方式為[現金]需填[生日/法人註冊日期]',
				function(v){
					if($('PAY_RELATION') != null){
						if ('B' != $F('PAY_RELATION') && '0' == $F('ISTIC')){
							return !Validation.get('IsEmpty').test(v);						
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
			[ 'checkLength60', '姓名長度超過50中文字或100個英文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
						return false;
					}		
					return true;					
				}
			],
							
			[ 'checkLength60_C', '負責人姓名長度超過50個全形文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
						return false;
					}		
					return true;					
				}
			],
			[ 'checkLength60_1', '具控制權之自然人姓名1長度超過50個全形文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
						return false;
					}		
					return true;					
				}
			],
			[ 'checkLength60_2', '具控制權之自然人姓名2長度超過50個全形文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
						return false;
					}		
					return true;					
				}
			],
			[ 'checkLength60_3', '具控制權之自然人姓名3長度超過50個全形文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
						return false;
					}		
					return true;					
				}
			],
			[ 'checkLength100', '姓名(羅馬拼音)長度超過50個全型文字，請確認',
				function(v){
					if( calWordLength(v) > 100){
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
		]);
		
		valid = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator', checkDisabled:true});	
		//valid.define( "checkInputLength" , { id: "BALC_MEMO" , errMsg:"備註欄文字超過長度限制" } );	
		validQuery = new Validation("table_A", { focusOnError:true, immediate:false , mode : 'validator'});	
		validQuery.define( "required" , { id: "BALC_NO" , errMsg:"請輸入暫應收編號" } );	
		validQuery.define( "validBALC_NO" , { id: "BALC_NO" , errMsg:"暫應收編號格式有誤" } );
	}
	
	var actions = {
		observeEvent : function(){
			$('BTN_INSERT').observe('click',buttons.doInsert);
			$("BTN_QUERY").observe('click', buttons.doQuery);
			$("BTN_DELETE").observe('click', buttons.doDelete);
			$("BTN_CLEAR").observe('click', buttons.doClear);
			$("BTN_PRINT").observe('click', buttons.doPrint);
			$("BTN_PRINT").hide();
			
			$("BALC_KIND").observe('change', actions.chgBALCList);
			$('LOAN_ID').observe('change', actions.getRelationList);			
			$('BALC_AMT').observe('blur', actions.writePayinfo);
			$('RECEIPT_SERNO').observe('blur', actions.writePayinfo); //2018-01-04連動改變繳款人資訊
			
			//繳款人關係連動帶出繳款人ID及姓名
			if($('PAY_RELATION')!=null){
				$('PAY_RELATION').observe('change', function(event){
						if ($('ISTIC').value == '0') {
							$('PAY_ID').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('RELATION_ID') || '';
							$('PAY_NAME').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('RELATION_NAME') || '';
							
							//2019-07-01 新增【繳款人姓名/法人名稱(羅馬拼音)(PAY_NAME_RM)】欄位
							$('PAY_NAME_RM').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('RELATION_NAME_RM') || '';
							
							$('BIRTH_DATE').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('BIRTH_DATE') || '';
							$('TEL_NO').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('DAY_TEL_NUM') || '';
							$('COPR_CODE').value = $('PAY_RELATION').options[$('PAY_RELATION').selectedIndex].getAttribute('COPR_CODE') || '0';
							$('PAY_REASON').value = '';
							$('OTHER_RELATION').value = '';
							if ($('COPR_CODE').value == "1") {
								$('CHIEF').enable();
								$('NATURAL_PERSON1').enable();
								$('NATURAL_PERSON2').enable();
								$('NATURAL_PERSON3').enable();
								$('CHIEF_ID').enable();
								$('NATURAL_PERSON1_ID').enable();
								$('NATURAL_PERSON2_ID').enable();
								$('NATURAL_PERSON3_ID').enable();
							}
							
							//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
							//select連動:關係為BG(借款人,保證人)->ID,NAME disable
							if($('PAY_RELATION').value == 'B'||$('PAY_RELATION').value == 'G'){
								$('PAY_ID').disable();
								$('PAY_NAME').disable();
								//2019-07-01 新增繳款人姓名(羅馬拼音)
								$('PAY_NAME_RM').disable();
							}else{
								$('PAY_ID').enable();
								$('PAY_NAME').enable();
								//2019-07-01 新增繳款人姓名(羅馬拼音)
								$('PAY_NAME_RM').enable();
							}
						}
				});
			}
			
			//繳款人種類連動負責人姓名、自然人姓名
			$('COPR_CODE').observe('change', function(event){
				if ($('COPR_CODE').value == "1") {
					$('CHIEF').enable();
					$('NATURAL_PERSON1').enable();
					$('NATURAL_PERSON2').enable();
					$('NATURAL_PERSON3').enable();		
					$('CHIEF_ID').enable();
					$('NATURAL_PERSON1_ID').enable();
					$('NATURAL_PERSON2_ID').enable();
					$('NATURAL_PERSON3_ID').enable();						
				} else {
					$('CHIEF').disable();
					$('NATURAL_PERSON1').disable();				
					$('NATURAL_PERSON2').disable();
					$('NATURAL_PERSON3').disable();
					$('CHIEF').value = '';
					$('NATURAL_PERSON1').value = '';			
					$('NATURAL_PERSON2').value = '';
					$('NATURAL_PERSON3').value = '';
					$('CHIEF_ID').disable();
					$('NATURAL_PERSON1_ID').disable();				
					$('NATURAL_PERSON2_ID').disable();
					$('NATURAL_PERSON3_ID').disable();
					$('CHIEF_ID').value = '';
					$('NATURAL_PERSON1_ID').value = '';			
					$('NATURAL_PERSON2_ID').value = '';
					$('NATURAL_PERSON3_ID').value = '';
				}					
			});
			
			//繳款方式選擇匯款單時，顯示匯款單索引
			$("ISTIC").observe('change', actions.showButton);
			$("BTN_INDEX").observe('click', buttons.doIndex);
			$('BTN_INDEX').hide();
			
			$('CHIEF').disable();
			$('NATURAL_PERSON1').disable();				
			$('NATURAL_PERSON2').disable();
			$('NATURAL_PERSON3').disable();
			$('CHIEF_ID').disable();
			$('NATURAL_PERSON1_ID').disable();
			$('NATURAL_PERSON2_ID').disable();
			$('NATURAL_PERSON3_ID').disable();
			
			//轉全形
			$('CHIEF').observe('blur', function(event){
				$('CHIEF').value = methods.unAsc($('CHIEF').value);
			});		
			$('NATURAL_PERSON1').observe('blur', function(event){
				$('NATURAL_PERSON1').value = methods.unAsc($('NATURAL_PERSON1').value);
			});	
			$('NATURAL_PERSON2').observe('blur', function(event){
				$('NATURAL_PERSON2').value = methods.unAsc($('NATURAL_PERSON2').value);
			});	
			$('NATURAL_PERSON3').observe('blur', function(event){
				$('NATURAL_PERSON3').value = methods.unAsc($('NATURAL_PERSON3').value);
			});	
			$('PAY_NAME').observe('blur', function(event){
				$('PAY_NAME').value = methods.unAsc($('PAY_NAME').value);
			});
			
			//2019-07-01 新增繳款人姓名(羅馬拼音)
			$('PAY_NAME_RM').observe('blur', function(event){
				$('PAY_NAME_RM').value = methods.unAsc($('PAY_NAME_RM').value);
			});
		},
		
		setGrid : function(){
			grid = new TableUI({
				table: $('grid'),
				pageSize:0,
				afterLoad:function(Element){
					actions.observeEvent();
				},
				column:[
					{header:'借款人', key:'BORROW_NAME', attrs:{Width:"25%", style:"text-align: left"}},
					{header:'繳款人關係', key:'PayRelationList', attrs:{style:"text-align: left"}, 
						render: function(record, value){
							var hasC = false, hasP = false, hasS = false, hasW = false;
							
							var renderString = '<select id="PAY_RELATION" name="PAY_RELATION" class="validPAY_RELATION validPAY_RELATION2" alt="ch"><option>請選擇</option>'
							for(var i = 0; i < value.size(); i++){
								var birthday = value[i].BIRTH_DATE;
								var tel = value[i].DAY_TEL_NUM;
								var coprcode = value[i].COPR_CODE;
								if(birthday){
									birthday = toROC(birthday);
								}else{
									birthday = '';
								}
								if(!tel){
									tel = '';
								}
								if(!coprcode){
									coprcode='';
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
								
								////2019-07-01 新增繳款人姓名(羅馬拼音)
								renderString += '<option value="' + (value[i].PAY_RELATION||'') + 
									'" relation_id="' + (value[i].RELATION_ID||'') + 
									'" relation_name="' + (value[i].RELATION_NAME||'') + 
									'" relation_name_rm="' + (value[i].RELATION_NAME_RM||'') + 
									'" birth_date="' + birthday +
									'" day_tel_num="' + tel +
									'" copr_code="' + coprcode + '">' +
								value[i].PAY_RELATION_NAME + '：' + value[i].RELATION_ID + '(' + value[i].RELATION_NAME + ')</option>';
							}
							if(!hasC){
								renderString += '<option value="C">配偶</option>';
							}
							if(!hasP){
								renderString += '<option value="P">父母</option>';
							}
							if(!hasS){
								renderString += '<option value="S">子女</option>';
							}
							if(!hasW){
								renderString += '<option value="W">負責人</option>';
							}
							renderString += '<option value="O">其他</option></select>';
							renderString += '其他關係<input id="OTHER_RELATION" type="text" class="textBox2 checkPAY_RELATION checkLength20" size="30" maxlength="60" value=""/>';
							renderString += '待繳原因<input id="PAY_REASON" type="text" class="textBox2 checkPAY_RELATION" size="30" maxlength="60" value=""/>';
							return renderString;
                        }}
				]
			});
		},
		
		doPopup : function(parms){
			//POP UP 開啟新視窗
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
		
		chgBALCList : function(){
			//發送ajax
			ajaxPost( 'chgBALC' , { BALC_KIND : $F('BALC_KIND')},
				function(resp){
					var balcList=resp.BALC_REASONList;
					var balcReason=$('BALC_REASON');
					balcReason.update('');
					
					for(var i=0;i<balcList.length;i++){
						var balcMap=balcList[i];
						balcReason.add(new Option(balcMap.value,balcMap.key));
					}	
				}
			);	
			if ($('BALC_KIND').value == 'DB'){
				$('table_B').hide();
				$('table_B').select('input[type!=button], select').each(function(ele){						
					ele.value = '';
				});		
				$('COPR_CODE').value = '0';
				noWrite = "Y";
				$('rpt_tr').hide();
				$('RECEIPT_SERNO').value ="";
			} else {
				actions.writePayinfo();
				$('rpt_tr').show();
			}			
			
		},
		
		getRelationList : function(){
		    if($F('LOAN_ID').length == 10){
				//發送ajax
				ajaxPost( 'getRelation' , { LOAN_ID : $F('LOAN_ID').toUpperCase()},  //2018-01-15因碰到輸入小寫貸款帳號去查無借款人資料就會隱藏單據序號區塊，但畫面上欄位已是大寫貸款帳號，故一律改成大寫貸款帳號去查
					function(resp){
						var RelationList = resp.PayRelationList;
						if (RelationList.size()>0){
							grid.load(RelationList[0]);
							$('BORROW_ID').value = RelationList[0]['BORROW_ID'] || '';
							var LastPayList = resp.LastPayList;
							if(LastPayList != null){
								$('PAY_ID').value = LastPayList['PAY_ID'] || '';
								$('PAY_NAME').value = LastPayList['PAY_NAME'] || '';
								
								//2019-07-01 新增繳款人姓名(羅馬拼音)
								$('PAY_NAME_RM').value = LastPayList['PAY_NAME_RM'] || '';
								
								var birthday = LastPayList['BIRTH_DATE'];
									if(birthday){
										birthday = toROC(birthday);
									}else{
									birthday = '';
								}    
								$('BIRTH_DATE').value = birthday;
								$('TEL_NO').value = LastPayList['TEL_NO'] || '';
								$('COPR_CODE').value = LastPayList['COPR_CODE'] || '';
								
								if (LastPayList['COPR_CODE'] == "1") {
									$('CHIEF').enable();
									$('NATURAL_PERSON1').enable();
									$('NATURAL_PERSON2').enable();
									$('NATURAL_PERSON3').enable();		
									$('CHIEF_ID').enable();
									$('NATURAL_PERSON1_ID').enable();
									$('NATURAL_PERSON2_ID').enable();
									$('NATURAL_PERSON3_ID').enable();						
								} else {
									$('CHIEF').disable();
									$('NATURAL_PERSON1').disable();				
									$('NATURAL_PERSON2').disable();
									$('NATURAL_PERSON3').disable();
									$('CHIEF').value = '';
									$('NATURAL_PERSON1').value = '';			
									$('NATURAL_PERSON2').value = '';
									$('NATURAL_PERSON3').value = '';
									$('CHIEF_ID').disable();
									$('NATURAL_PERSON1_ID').disable();				
									$('NATURAL_PERSON2_ID').disable();
									$('NATURAL_PERSON3_ID').disable();
									$('CHIEF_ID').value = '';
									$('NATURAL_PERSON1_ID').value = '';			
									$('NATURAL_PERSON2_ID').value = '';
									$('NATURAL_PERSON3_ID').value = '';
								}
								
								var PAY_RELATION = $('PAY_RELATION');
								if(PAY_RELATION != null){
									var borrow_id = "";
									var pay_relation = "";
									for(var j = 1; j < PAY_RELATION.length; j++){ //j=0為"請選擇"
										//取得借款人ID
										if(PAY_RELATION[j].value == "B"){
											borrow_id = PAY_RELATION[j].getAttribute("relation_id");
											pay_relation = LastPayList['PAY_RELATION'];
											//該借款人無繳款人資料
											if(!pay_relation){
													break;
											}
										}
										//選擇對應到的關係
										if(PAY_RELATION[j].value == pay_relation){
											PAY_RELATION[j].selected = true;
											break;
										}
									}
								}
						   }
							//2018-01-04若有查出關係資料要將相關欄位秀出
							$('table_B').show();
							$('rpt_tr').show();	
							noWrite = "N";	
						} else {
							$('table_B').hide();
							$('table_B').select('input[type!=button], select').each(function(ele){						
								ele.value = '';
							});		
							$('COPR_CODE').value = '0';
							noWrite = "Y";
							$('rpt_tr').hide();
							$('RECEIPT_SERNO').value =""; //若非貸款帳號
						}						
					}
				);	
								
			} else {
			
				$('table_B').hide();
				$('table_B').select('input[type!=button], select').each(function(ele){						
					ele.value = '';
				});		
				$('COPR_CODE').value = '0';
				noWrite = "Y";
				$('rpt_tr').hide();
				$('RECEIPT_SERNO').value =""; //若非貸款帳號
			}
			
			//重新執行畫面連動
			actions.writePayinfo();
		},
		
		writePayinfo: function(){
			if ($('RECEIPT_SERNO').value =="" || 'DB'==$F('BALC_KIND')){
				noWrite = "Y";
				$('table_B').hide();
				$('table_B').select('input[type!=button], select').each(function(ele){						
					ele.value = '';
				});		
				$('COPR_CODE').value = '0';
			} else if('CB'==$F('BALC_KIND') && '0' == $F('ISTIC')) {
				if (parseInt($('BALC_AMT').getValue(), 10) <= 50000) {
					$('table_B').hide();
					$('table_B').select('input[type!=button], select').each(function(ele){						
						ele.value = '';
					});		
					$('COPR_CODE').value = '0';
					if ($F('LOAN_ID').length == 10) {
						noWrite = "R";
					} else {
						noWrite = "Y";
						$('RECEIPT_SERNO').value ="";
					}					
				} else {
					$('table_B').show();
					$('NATION_CODE').value = "TW";
					$('OCR_NATION_CODE').value = "TW";
					$('FUND_SORC_COUNTRY').value = "TW";
					noWrite = "N"
				}	
			} else {
					$('table_B').show();
					$('NATION_CODE').value = "TW";
					$('OCR_NATION_CODE').value = "TW";
					$('FUND_SORC_COUNTRY').value = "TW";					
					noWrite = "N";
			}				
		},
		//2018-01-30因財會科匯款單不再輸入負責人、具控制權自然人、匯款來源國等欄位，會在繳款服務單就填寫，故改由本畫面自行填入再寫到繳款服務單
		showButton : function(){
			if($('ISTIC').value == '3') { 
				$('BTN_INDEX').show();
				$('PAY_ID').disable();
				$('COPR_CODE').disable();	
				$('PAY_NAME').disable();
				//2019-07-01 新增繳款人姓名(羅馬拼音)
				$('PAY_NAME_RM').disable();
				$('FUND_SORC_COUNTRY').enable();				
			} else {
				$('BTN_INDEX').hide();
				$('PAY_ID').enable();
				$('COPR_CODE').enable();	
				$('PAY_NAME').enable();
				//2019-07-01 新增繳款人姓名(羅馬拼音)
				$('PAY_NAME_RM').enable();
				$('FUND_SORC_COUNTRY').disable();					
			}
			
			//220621問題單編號 20220620-0148 BY余凱鈞
			//程式需調整，選擇不同繳款方式時也要連動繳款服務單資訊區塊
			actions.writePayinfo();

		},
		
		callback_doIndex : function(records){	
			
 			RemitList = records.RMT_INFO_LIST;	
 			for (var idx = 0; idx < RemitList.length; idx++) {

				RemitList[idx]['REMIT_GROUP'] = RemitList[idx]['RMT_SET_NO'];
				RemitList[idx]['REMIT_DATE'] = RemitList[idx]['RMT_DATE'];
				RemitList[idx]['FACE_AMT'] = RemitList[idx]['TRN_AMT'];
				RemitList[idx]['REMIT_SERNO'] = RemitList[idx]['CO_ACNT_NO'];
				if(idx==0){
					//2018-01-30因財會科匯款單不再輸入負責人、具控制權自然人、匯款來源國等欄位，會在繳款服務單就填寫，故改由本畫面自行填入再寫到繳款服務單
					var ID_KIND = RemitList[idx]['ID_KIND'] || '';
					var REMIT_DATE = RemitList[idx]['REMIT_DATE'] || '';
					if (ID_KIND == "2"){ //法人的統編因匯款單系統記錄10碼(前2碼補0)，取後8碼呈現
						$('PAY_ID').value=RemitList[idx]['RMT_ID'].substr(2,8) || '';
						$('CHIEF').enable();
						$('NATURAL_PERSON1').enable();
						$('NATURAL_PERSON2').enable();
						$('NATURAL_PERSON3').enable();
						$('CHIEF_ID').enable();
						$('NATURAL_PERSON1_ID').enable();
						$('NATURAL_PERSON2_ID').enable();
						$('NATURAL_PERSON3_ID').enable();						
					} else {					
						$('PAY_ID').value=RemitList[idx]['RMT_ID'] || '';
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
					$('PAY_NAME').value=RemitList[idx]['RMT_NAME'] || '';
					$('COPR_CODE').value=(ID_KIND == "1" ? "0" : "1");
					$('REMIT_DATE').value = REMIT_DATE;
				}
			}
 			
			ajaxPost( 'count', { 'RemitList' : Object.toJSON(RemitList) },
				function(resp){
					$('BALC_AMT').value = methods.gridFmtRender(resp.TRN_AMT_TOT);
					$('REMIT_GROUP').value = records.RMT_SET_NO;
				}
			);		
		},
		
		clearContents : function(){
			$('PAY_ID').value = '';
			$('PAY_NAME').value = '';
			
			//2019-07-01 新增繳款人姓名(羅馬拼音)
			$('PAY_NAME_RM').value = '';
			
			$('BIRTH_DATE').value = '';
			$('TEL_NO').value = '';
			$('CHIEF').value = '';
			$('NATURAL_PERSON1').value = '';
			$('NATURAL_PERSON2').value = '';
			$('NATURAL_PERSON3').value = '';
			$('CHIEF_ID').value = '';
			$('NATURAL_PERSON1_ID').value = '';
			$('NATURAL_PERSON2_ID').value = '';
			$('NATURAL_PERSON3_ID').value = '';			
			grid.clear();
		}
	};
	
	var methods = {
		unAsc : function(text){
			//轉全形
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
		
		gridFmtRender : function(value) { 
			//金額格式化
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		}
	};
	
	var buttons={		
		doQuery : function (){
			if(!validQuery.validate()){
				return;
			}
			query_BALC_NO=$('BALC_NO').value;
			actions.clearContents();
			ajaxPost( 'query', {BALC_NO : $F('BALC_NO')}
					,function(resp){
						rtnMap=resp.rtnMap;
						//初始頁面顯示欄位
						$$('.textBox2').each(function(ele){
							var id = ele.id;
							ele.value=rtnMap[id] || '';
						});
						$$('.class1').each(function(ele){
							var id = ele.id;
							ele.value=Date.toROC(rtnMap[id]) || '';
						});
						$$('.money1').each(function(ele){
							var id = ele.id;
							ele.value= CSRUtil.$fmt(rtnMap[id],"#,###") || '';
						});
						$('BALC_KIND').value = rtnMap['BALC_KIND'];
						$('BALC_REASON').value = rtnMap['BALC_REASON'];
						$('ISTIC').value = rtnMap['ISTIC'];
						isQry = true;
						$('WAUTHID2_NM').update(rtnMap.WAUTHID2_NM);
						$('DAUTHID1_NM').update(rtnMap.DAUTHID1_NM);
						$('DELTID_NM').update(rtnMap.DELTID_NM);
						$('WAUTHID1_NM').update(rtnMap.WAUTHID1_NM);
						$('INPUT_NAME').update(rtnMap.INPUT_NAME);
						$('DEPT_SRTNM').update(rtnMap.DEPT_SRTNM);
						$('TRN_SER_NO').update(rtnMap.TRN_SER_NO);
						$('RECEIPT_SERNO').value = rtnMap['RECEIPT_SERNO'];
						if($F('RECEIPT_SERNO') != ""){
							$('BTN_PRINT').show();
						}
						$('NATION_CODE').value = "TW";
						$('OCR_NATION_CODE').value = "TW";
						$('COPR_CODE').value = "0";
						$('FUND_SORC_COUNTRY').value = "TW";
					},function(resp){
						isQry = false;
					
					}
				);

		},
		
		doInsert : function(){
				
			if(!$F('LOAN_ID')){
				alert("貸款帳號不可為空!!");
				return;
			}
			if(!$F('BALC_KIND')){
				alert("請選擇暫收種類!!");
				return;
			}
			if(!$F('ISTIC') && 'CB'==$F('BALC_KIND')){
				alert("請選擇繳款方式!!");
				return;
			}
			if(!$F('BALC_AMT')){
				alert("請輸入暫應收金額!!");
				return;
			}
			if($F('BALC_NO')){
				alert("新增時,暫收編號不可輸入!!");
				return;
			}

			//2018-01-04檢核單據序號輸入長度
			if($F('RECEIPT_SERNO') && $F('RECEIPT_SERNO').length !=10){
				alert("單據序號輸入有誤!!");
				return;
			}
			valid.reset();
			valid.clear();
			if (noWrite =="N"){
				//改用VALID檢核
				if('CB'==$F('BALC_KIND') && !$F('PAY_NAME') && $F('LOAN_ID').length ==10){
					valid.define('required' , [{ id : "PAY_NAME" , errMsg:'請輸入繳款人名稱/法人名稱!!'}]);	  	
				}								
				$('CHIEF').value = methods.unAsc($('CHIEF').value);
				$('NATURAL_PERSON1').value = methods.unAsc($('NATURAL_PERSON1').value);
				$('NATURAL_PERSON2').value = methods.unAsc($('NATURAL_PERSON2').value);
				$('NATURAL_PERSON3').value = methods.unAsc($('NATURAL_PERSON3').value);
				$('PAY_NAME').value = methods.unAsc($('PAY_NAME').value);	
				
				//2019-07-01 新增繳款人姓名(羅馬拼音)
				$('PAY_NAME_RM').value = methods.unAsc($('PAY_NAME_RM').value);	
			}			
			
			if(!valid.validate()){
				return;
			}

			rtnMap={};
			rtnMap['LOAN_ID']=$('LOAN_ID').value;
			rtnMap['BALC_KIND']=$('BALC_KIND').value;
			rtnMap['BALC_REASON']=$('BALC_REASON').value;
			rtnMap['BALC_AMT']=$('BALC_AMT').getValue();
			rtnMap['BALC_MEMO']=$('BALC_MEMO').value;
			rtnMap['BALC_NO']=$('BALC_NO').value;
			rtnMap['INPUT_DEPT']=$('INPUT_DEPT').value;
			rtnMap['INPUT_ID']=$('INPUT_ID').value;
			rtnMap['INPUT_NAME']=$('INPUT_NAME').innerHTML;
			rtnMap['ISTIC']=$('ISTIC').value;
			rtnMap['REMIT_GROUP']=$('REMIT_GROUP').value;

			PAY_INFO ={};
			PAY_INFO['noWrite'] = noWrite;	
			if(noWrite =="N"){
				rtnMap['RECEIPT_SERNO']=$('RECEIPT_SERNO').value;
				PAY_INFO = {
					RELATION : [{
						BORROW_ID : grid.getAllRecords()[0].BORROW_ID,
						BORROW_NAME : grid.getAllRecords()[0].BORROW_NAME,
						PAY_RELATION : $F('PAY_RELATION'),
						OTHER_RELATION: $F('OTHER_RELATION'),
						PAY_REASON : $F('PAY_REASON')
					}],
					PAY_ID : $('PAY_ID').value,
					COPR_CODE : $F('COPR_CODE'),
					PAY_NAME : $F('PAY_NAME'),
					//2019-07-01 新增繳款人姓名(羅馬拼音)
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
					FUND_SORC_COUNTRY : ($('ISTIC').value=='0') ? "" : $F('FUND_SORC_COUNTRY'),
			        REMIT_DATE : $F('REMIT_DATE'),
			        noWrite : noWrite					
				};
			} else if (noWrite =="R") {
				rtnMap['RECEIPT_SERNO']=$('RECEIPT_SERNO').value;
				//不需寫繳款服務單,還是要檢核借款人及保證人的洗錢防制(需寫C117)
				PAY_INFO = {
					RELATION : [{
						BORROW_ID : $F('BORROW_ID')
					}],
			     	noWrite : noWrite	
				};
			} else {
				rtnMap['RECEIPT_SERNO']= '';
				$('RECEIPT_SERNO').value ="";
				//不需寫繳款服務單,還是要檢核借款人及保證人的洗錢防制(需寫C117)
				PAY_INFO = {
					RELATION : [{
						BORROW_ID : $F('BORROW_ID')
					}],
			     	noWrite : noWrite
				};
			}
			
			ajaxPost( 'insert', {tempData : Object.toJSON(rtnMap), RemitList : Object.toJSON(RemitList),
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
					    	ajaxPost( 'insert', {tempData : Object.toJSON(rtnMap), RemitList : Object.toJSON(RemitList),
									PAY_INFO : Object.toJSON(PAY_INFO),
									isSecondTime : 'Y',
									TIPS_MSG : resp.TIPS_MSG }
							,function(resp){	
								successFuncForInsert(resp);	
			    			});
					    } else {
							successFuncForInsert(resp);	
						}
				});
		},
		
		doDelete : function(){
			if($('BALC_NO').value!=query_BALC_NO){
				alert("暫應收編號與先前查詢的不同，請先確認!");
				return;
			}
			rtnMap['LOAN_ID']=$('LOAN_ID').value;
			rtnMap['BALC_KIND']=$('BALC_KIND').value;
			rtnMap['BALC_REASON']=$('BALC_REASON').value;
			rtnMap['BALC_AMT']=$('BALC_AMT').getValue();
			rtnMap['BALC_MEMO']=$('BALC_MEMO').value;
			rtnMap['BALC_NO']=$('BALC_NO').value;
			rtnMap['EMP_ID']='${EMP_ID}';
			rtnMap['OP_UNIT']='${OP_UNIT}';
			ajaxPost( 'delete', {tempData : Object.toJSON(rtnMap)}
					,function(resp){
					
				});
		},
		
		doClear : function (){
					$$('.textBox2').each(function(ele){
						ele.value= '';
					});
					$$('.class1').each(function(ele){
						ele.value= '';
					});
					$$('.money1').each(function(ele){
						ele.value='';
					});
					$('BALC_REASON').value=99;
		
		},
		
		doPrint : function(){			
		
			if(!isQry){
				alert('請先查詢成功再進行列印!');
				return;
			}
			if($F('BALC_NO') != query_BALC_NO){
				alert('暫應收編號與先前查詢的不同，請先確認!');
				return;					
			}
			
			if(query_BALC_NO.substring(0,2) != 'CB'){
				alert('只提供人工暫收明細列印');
				return;				
			}
		
			//發送ajax
			/*ajaxPost( 'print' , { BALC_NO : query_BALC_NO, NEW_RECEIPT_SERNO : $F('RECEIPT_SERNO')},
				function(resp){
					RPTUtil.executePrintByResponse(resp, true);	
				}
			);	*/

			//2018-01-12改用浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSC3_2300/print' , { BALC_NO : query_BALC_NO, NEW_RECEIPT_SERNO : $F('RECEIPT_SERNO')}, true );			
		},
		
		doIndex: function(){
			popupWin.popup({
				src: '/DJWeb/servlet/HttpDispatcher/DCG2_0100/prompt',
				cb: actions.callback_doIndex
			});	
		}		
	};
	
	function successFuncForInsert(resp){
		if(resp.TIPS_MSG){
			alert(resp.TIPS_MSG); //2018-01-29提示：負責人或具控制權自然人若無ID，且為制裁名單，需提示(因無ID資訊無法填寫洗錢防制檢核紀錄，請確實申報，並與收費管理科聯繫)
		}
		rtnMap=resp.rtnMap;
		$('BALC_NO').value=rtnMap["BALC_NO"];	
		
		$('INPUT_DEPT').value=rtnMap["INPUT_DEPT"];	
		$('INPUT_ID').value=rtnMap["INPUT_ID"];	
		
		$('INPUT_NAME').update(rtnMap["INPUT_NAME"]);
		$('DEPT_SRTNM').update(rtnMap["DEPT_SRTNM"]);
		$$('.class1').each(function(ele){
				var id = ele.id;
				ele.value=Date.toROC(rtnMap[id]) || '';
			});
		if (noWrite == "N" || noWrite =="R"){
			//執行列印暫收明細報表
			/*ajaxPost( 'print' , { BALC_NO : rtnMap["BALC_NO"]},
				function(resp){
					RPTUtil.executePrintByResponse(resp, true);	
				}
			);*/
			//2018-01-12改用浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSC3_2300/print' , { BALC_NO : rtnMap["BALC_NO"]}, true );
		}
		$('RECEIPT_SERNO').value = rtnMap["RECEIPT_SERNO"] || '';
		$('TRN_SER_NO').update(rtnMap["TRN_SER_NO"] || '');		
	};
	
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode="DS" 	var="localeDisplay" dateFields="BIRTH_DATE"/>
			//specStr=${spec};
			specStr=$('SPEC').value;
			if(specStr=='1'){
				PageUI.createPageWithAllBodySubElement('DSC32300', '收息作業', '法扣入人工帳');
			}else {
				PageUI.createPageWithAllBodySubElement('DSC32300', '收息作業', '暫收款輸入');
			}
			
			initValidation();
			autoFormatToNumber();
			$('BALC_REASON').value = 99;
			$('INPUT_DEPT').value = '${INPUT_DEPT}';			
			$('DEPT_SRTNM').update('${DEPT_SRTNM}');
			$('INPUT_ID').value = '${EMP_ID}';
			$('INPUT_NAME').update('${INPUT_NAME}');
			$('INPUT_DATE').value='${INPUT_DATE}';
			$('RECEIPT_SERNO').value='${RECEIPT_SERNO}';
			$('FUND_SORC_COUNTRY').disable();
			actions.setGrid();
			
			<%--註冊click事件--%>	
			actions.observeEvent();
			
			//先把畫面區塊都調整到位再顯示訊息
			fix();	
			PageUI.resize();
			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr id='tr1'>
			<td class="tbYellow" width="25%">暫應收編號</td>
				<input type='hidden' id = 'SPEC' value="${spec}"/>
				<input type='hidden' id = 'REMIT_DATE' />
			<td class="tbYellow2" width="25%" >
			<input id="BALC_NO"  type="text" class="textBox2" maxlength="12"/></td>
			<td class="tbYellow2"  colspan="2" width="50%"> 
			<input id="BTN_QUERY" type="button" value="查詢" class="button" > 
		</td>
		</tr>
		<tr>
			<td class="tbYellow0" width="100%"  colspan="4"><B>暫應收資料</td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">貸款帳號</td>
			<td class="tbYellow2" width="25%" >
			<input id="LOAN_ID"  type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()" />
			<input id="BORROW_ID"  type="hidden" class="textBox2"  /></td>
			<td class="tbYellow" width="25%">暫收種類</td>
			<td class="tbYellow2" width="25%" >
				<select id="BALC_KIND">
						<c:forEach var="map" items="${BALC_KINDList}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select> 
		
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">暫收原因</td>
			<td class="tbYellow2" width="25%" >
				<c:set var="SPEC_FLAG" scope="session" value="${spec}"/>
				<c:if test="${SPEC_FLAG=='0'}">
				   <select id="BALC_REASON">
						<c:forEach var="map" items="${BALC_REASONList}">
								<option value="${map.key}">${map.value}</option>
						</c:forEach>
				   </select>
				</c:if>				
				<c:if test="${SPEC_FLAG=='1'}">
				   <input  type = 'hidden'  id = 'BALC_REASON' value="12"/>強迫扣薪
				</c:if>	
		
			</td>
			<td class="tbYellow" width="25%">暫應收金額</td>
			<td class="tbYellow2"  >
			<input id="BALC_AMT"  type="text" class="money1" datatype="number"/></td>
			
		</tr>
		<tr>
			<td class="tbYellow" width="25%" >備註</td>
			<td class="tbYellow2" >
			<input id="BALC_MEMO"  type="text" class="textBox2 checkInputLength_mod"  size='50' maxlength='40'/></td>
			<td class="tbYellow" width="25%">繳款方式</td>
			<td class="tbYellow2" width="25%" >
				<select id="ISTIC">
					<c:forEach var="map" items="${ISTICList}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select> 
				<input id="BTN_INDEX" type="button" value="匯款單索引" class="button" > 
				<input type='hidden' id='REMIT_GROUP' value=""/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">剩餘金額</td>
			<td class="tbYellow2"  >
			<input id="REMAIN_AMT"  type="text" class="money1" size='15' style="background-color:#FCFFCB" readonly datatype="number"/></td>
			<td class="tbYellow" width="25%">沖帳授權</td>
			<td class="tbYellow2"  >
			<input id="WASH_AUTH"  type="text" class="textBox2" size='15' style="background-color:#FCFFCB" readonly /></td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">剔帳授權</td>
			<td class="tbYellow2"  >
			<input id="DELT_AUTH"  type="text" class="textBox2" size='15' style="background-color:#FCFFCB" readonly /></td>
			<td class="tbYellow" width="25%">入帳日期</td>
			<td class="tbYellow2"  >
			<input id="ACNT_DATE"  type="text" class="class1" size='10' style="background-color:#FCFFCB" readonly /></td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">總公司授權人員</td>
			<td class="tbYellow2"  >
			<input id="WAUTH_ID2"  type="text" class="textBox2" size='15' alt="ch" style="background-color:#FCFFCB" readonly /> <%-- [20241104] 難字調整: 總公司授權人員 --%>
			<span id="WAUTHID2_NM" style="font-family:'EUDC'"></span></td>  
			<td class="tbYellow" width="25%">單位剔帳授權人員</td>
			<td class="tbYellow2"  >
			<input id="DAUTH_ID1"  type="text" class="textBox2" size='15' alt="ch" style="background-color:#FCFFCB" readonly /> <%-- [20241104] 難字調整: 單位剔帳授權人員 --%>
			<span id="DAUTHID1_NM"></span></td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">單位剔帳人員</td>
			<td class="tbYellow2"  >
			<input id="DELT_ID"  type="text" class="textBox2" size='15' alt="ch" style="background-color:#FCFFCB" readonly /> <%-- [20241104] 難字調整: 單位剔帳人員 --%>
			<span id="DELTID_NM"></span></td>
			<td class="tbYellow" width="25%">單位沖帳授權人員</td>
			<td class="tbYellow2"  >
			<input id="WAUTH_ID1"  type="text" class="textBox2" size='15' alt="ch" style="background-color:#FCFFCB" readonly /> <%-- [20241104] 難字調整: 單位沖帳授權人員 --%>
			<span id="WAUTHID1_NM"></span></td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">輸入單位</td>
			<td class="tbYellow2"  >
			<input id="INPUT_DEPT"  type="text" class="textBox2" size='12' style="background-color:#FCFFCB" readonly />			
			<span id="DEPT_SRTNM"></span></td>			
			<td class="tbYellow" width="25%">作業人員</td>
			<td class="tbYellow2"  >
			<input id="INPUT_ID"  type="text" class="textBox2" size='15' alt="ch" style="background-color:#FCFFCB" readonly /> <%-- [20241104] 難字調整: 作業人員 --%>
			<span id="INPUT_NAME"></span></td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%" >作業日期</td>
			<td class="tbYellow2">
			<input id="INPUT_DATE" type="text" class="class1" style="background-color:#FCFFCB" size='10' readonly /></td>
			<td class="tbYellow" width="25%" >繳款服務單編號</td>
			<td class="tbYellow2">
			<span id="TRN_SER_NO"></span></td>
		</tr>
		<tr id="rpt_tr">
			<td class="tbYellow" width="25%" >單據序號</td>
			<td class="tbYellow2" width="75%" colspan="3">
			<B>請在印表機放入您的空白單據，其單據序號為 </B><input id="RECEIPT_SERNO" class="textBox2" type="text" size='12' maxlength='10'/>
			<input id="BTN_PRINT" type="button" value="補發暫收明細" class="button"/></td>
		</tr>
	</table>
	<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0" colspan= "4"><B>繳款人資訊</B>
			</td>
		</tr>
		
		<tr><td colspan= "4"><div id="grid" class="grid"></div></td></tr>
		
		<tr>
			<td class="tbYellow" width="25%" rowspan="2">繳款人ID</td>
			<td class="tbYellow2" width="25%" rowspan="2">
				<input id="PAY_ID" type="text"  class="textBox2 checkPAY_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				<select id="COPR_CODE" name="COPR_CODE" >
					<option value="0">個人</option>
					<option value="1">法人</option>					
				</select>					
			</td>
			<td class="tbYellow" width="25%">繳款人姓名/法人名稱</td>
			<td class="tbYellow2" >
				<input id="PAY_NAME" type="text" class="textBox2 checkLength60" size='30' maxlength="60" value="" alt="ch"/> <%-- [20241104] 難字調整: 繳款人姓名/法人名稱 --%>
			</td>
		</tr>
		<tr>

			<td class="tbYellow" width="25%">繳款人姓名/法人名稱(羅馬拼音)</td>
			<td class="tbYellow2" >
				<!--[20190630] 新增欄位-->
				<input id="PAY_NAME_RM" type="text" class="textBox2 checkLength100" size='30' maxlength="50" value=""/>
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow" width="25%">繳款人生日/法人註冊日期</td>
			<td class="tbYellow2" >
				<input id="BIRTH_DATE" type="text" class="textBox2 checkBIRTH_DATE" size='30' maxlength="60" value=""/>
			</td>
			<td class="tbYellow" width="25%">繳款人電話</td>
			<td class="tbYellow2" >
				<input id="TEL_NO" type="text" class="textBox2 checkTEL_NO" size='30' maxlength="30" value=""/>(請填：0~9,-,#)
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">繳款人國籍</td>
			<td class="tbYellow2" width="25%">
				<select id="NATION_CODE" name="NATION_CODE" >
					<c:forEach var="map" items="${NATION_CODEList}">
							<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
					</c:forEach>
				</select>
			</td>
			<td class="tbYellow" width="25%">繳款人居住國</td>
			<td class="tbYellow2" width="25%">
				<select id="OCR_NATION_CODE" name="OCR_NATION_CODE" >
					<c:forEach var="map" items="${NATION_CODEList}">
							<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
					</c:forEach>
				</select>					
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="25%">負責人ID</td>
			<td class="tbYellow2" >
				<input id="CHIEF_ID" type="text" class="textBox2 checkCHIEF_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/><br>
			</td>
			<td class="tbYellow" width="25%">負責人姓名</td>
			<td class="tbYellow2" >
				<input alt="ch" id="CHIEF" type="text" class="textBox2 checkCHIEF checkLength60_C" size='30' maxlength="60" value="" /> <%-- [20241104] 難字調整: 負責人姓名 --%>
			</td>
		</tr>			
		<tr>	
			<td class="tbYellow" width="25%">具控制權之自然人1 ID</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON1_ID" type="text" class="textBox2 checkNATURAL_PERSON1_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/><br>
			</td>				
			<td class="tbYellow" width="25%">具控制權之自然人1 姓名</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON1" type="text" class="textBox2 checkLength60_1" size='30' maxlength="60" value="" alt="ch"/> <%-- [20241104] 難字調整: 具控制權之自然人1 姓名 --%>
			</td>				
		</tr>
		<tr>
			<td class="tbYellow" width="25%">具控制權之自然人2 ID</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON2_ID" type="text" class="textBox2 checkNATURAL_PERSON2_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/><br>
			</td>			
			<td class="tbYellow" width="25%">具控制權之自然人2 姓名</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON2" type="text" class="textBox2 checkLength60_2" size='30' maxlength="60" value="" alt="ch"/> <%-- [20241104] 難字調整: 具控制權之自然人2 姓名 --%>
			</td>				
		</tr>
		<tr>					
			<td class="tbYellow" width="25%">具控制權之自然人3 ID</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON3_ID" type="text" class="textBox2 checkNATURAL_PERSON3_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/><br>
			</td>
			<td class="tbYellow" width="25%">具控制權之自然人3 姓名</td>
			<td class="tbYellow2" >
				<input id="NATURAL_PERSON3" type="text" class="textBox2 checkLength60_3" size='30' maxlength="60" value="" alt="ch"/> <%-- [20241104] 難字調整: 具控制權之自然人3 姓名 --%>
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" width="25%">匯款來源國</td>
			<td class="tbYellow2" width="25%" colspan="3">
				<select id="FUND_SORC_COUNTRY" name="FUND_SORC_COUNTRY" >
					<c:forEach var="map" items="${NATION_CODEList}">
							<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
					</c:forEach>
				</select>
			</td>
		</tr>		
	</table>	
	<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow2" width="100%" colspan="4" align="center">
			<input id="BTN_INSERT" type="button" value="新增" class="button"/> 
			<input id="BTN_DELETE" type="button" value="刪除" class="button"/>
			<input id="BTN_CLEAR" type="button" value="清除" class="button"/>
			</td>
		</tr>
	</table>	
</form>
</body>
</html>