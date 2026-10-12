<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSA21500.jsp
功能：簡易徵信報告書
作者： 
完成：2011/??/??

[20190312] 修改件
		1. 電腦作業申請書181214000655，從匯款掃描作業新增的特殊派件，不可以修改「特殊案件類別」
[20240729] 修改件 陳勁谷 難字修改
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var valid1;
var valid2;
var grid;

var buttonAction;
var checkedApplyId;

function buttonAuth(){
	var authButtons = {
			B0067:"insert"<%--派件--%> ,
			B0004:"modify"<%--修改--%> ,
			B0070:"approve"<%--覆核--%> ,
			B0005:"delete"<%--刪除--%> ,
			B0068:"reject"<%--退件--%> ,
			B0071:"cancelapprove"<%--取消覆核--%> ,
			B0069:"cancelreject"<%--取消退件--%>
	};
	
	<dz:grantButtons FUNC_ID="DSA21500" ignored="false"/>
}

function initApp(){  
  	
	PageUI.createPage("DSA21500" , "核貸作業" , "特殊案件派件及覆核");
	PageUI.loadin(["form1","grid","form2"] ,1);
  	
	buttonAuth();
	
	new UI().init();	
	$('BORROW_NAME').hide();	
	$('ASSIGN_DATE').innerHTML = Date.toInputROC(getY2KToday(),"/");
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	Validation.addAllThese([
		[ 'validateLOAN_ID',  '輸入欄位長度有誤', function(){  if( $F('INPUT_ID1') && ( $F('INPUT_ID1').length == 11 || $F('INPUT_ID1').length == 10)){ return true; } return false; } ] ,
		[ 'validateMomo_Check',  '說明欄位必須有值', function(){ if( $F('SPEC_KIND') === "99" && (!$F('OTHER_MEMO') ||$F('OTHER_MEMO') ==="說明")){ return false; } return true; } ],
		[ 'validateInsert_Check',  '欄位必須有值', function(v){ if(buttonAction == 'insert' && !v ){ return false; } return true;  } ],
		[ 'validateUpdate_Check',  '欄位必須有值', function(v){ if(buttonAction == 'up' && !v ){ return false; } return true;  } ]
	]);
	
	valid2 = new Validation("form2", {useTitles:true,focusOnError:false,immediate:false});
	
	PageUI.resize(true);
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){
	
	function ajaxpost( action , param , successFunction , errorFunction ){
		new Ajax.Request("<%=dispatcher%>/DSA2_1500/"+action, 
			{
				parameters: param,
				onSuccess:function(XHT, resp){
					if(CSRUtil.isSuccess(resp)){	
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
					PageUI.resize(true);
				}
			});
	}
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------
	var buttons = {
		// 查詢
		doQuery:function(){	
			valid2.reset();
			if(!valid1.validate()){ 
				return; 
			}
			$('INPUT_ID1').value = $('INPUT_ID1').value.toUpperCase();
			var QUERY_TYPE = getRadioValue("form1","QUERY_TYPE");
			$('CONTROL_CODE').value = '';
			ajaxpost( "query" , { QUERY_TYPE: QUERY_TYPE , LOAN_ID:$F('INPUT_ID1') } , 
				function(resp){					
					buttons.doClearAll();
					grid.load(resp.rtnList || []); 
					dataChange.QUERY_TYPE(QUERY_TYPE);						
					
					var records = grid.getAllRecords();
					var SEQ_NO = records[0].SEQ_NO;
					$$('#grid input[type="radio"]').each( 
						function(ele){
							if(ele.value==SEQ_NO){
								ele.click();
							}
						}
					);
					
					var CONTROL_CODE =  resp.CONTROL_CODE;
					var isInternal =  resp.isInternal;
					if (CONTROL_CODE){
					   $('CONTROL_CODE').value = CONTROL_CODE;
						var MSG;
						if(CONTROL_CODE == "ERR"){
						    MSG ="本件有「特殊管控」注意事項。"
						    if(isInternal == 'N'){
						    	MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
						    }
						    MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
						}else if(CONTROL_CODE){
							MSG ="本件有「特殊提醒」注意事項。"
							if(isInternal == 'N'){
								MSG = MSG +"\r\n詳細內容請洽"+resp.CONTROL_DEPT_GROUP_NM+"。";
							}	
							MSG += "\r\n若要查詢特殊件控管變更紀錄請按『確定』鍵?";
						}
						if( confirm(MSG)){
							   buttons.linkTo_DSC8_3100(resp.BORROW_ID,"3-9");
				        }
					}
					
					
				} 
				, function(resp){									
					checkedApplyId = "";
				}				
			);	
		},
		docheckInsert :function(){
			if($F('CONTROL_CODE') == "ERR"){
	    		alert("本件為特殊控管件,無法進行派件!!");
		    	return;
		    }
					
			buttonAction = 'insert';
			if(!$('LOAN_ID').innerHTML){ 
				alert("請先查詢後，再進行作業!"); 
				return;
			}
			if(!valid2.validate()){ 				
				return; 
			}					
			if(  $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
				if(!confirm("查詢之貸款帳號與畫面上貸款帳號不同，請確認是否要繼續處理")){return;}				
			}
			var sendRecord = getDataFromForm();			
			if(!sendRecord) {
				alert("無資料!");
				return;		
			}	
			ajaxpost( "checkInsert" , sendRecord, function(resp){
					<%--[20240318]修改件: SN_221221005419[申請書240201007793]新增本金彈性還還款方式_貸後變更--%>				
					if(resp.checkAlertMsg){
						alert(resp.checkAlertMsg);
					}
					grid.load(resp.rtnList);
					buttonAction = '';					
				},	function(resp){ 					
					buttonAction = '';	
				}
			);	
		},
		doUpdate :function(){	
			buttonAction = 'up';
			if(!$('LOAN_ID').innerHTML){ 
				alert("請先查詢後，再進行作業!"); 
				return ;
			}
			if(!valid2.validate()){ 				
				return; 
			}			
			//if($F('QUERY_TYPE')	== 1 && $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
			if(form1.QUERY_TYPE.value	== 1 && $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
				if(!confirm("查詢之貸款帳號與畫面上貸款帳號不同，請確認是否要繼續處理")){
					return;
				}
			}
			var sendRecord = getDataFromForm();			
			if(!sendRecord) {
				alert("無資料!");
				return;
			}	
			ajaxpost( "update" , sendRecord, 
				  function(resp){
					grid.load(resp.rtnList); 
					buttonAction = '';
				  }, 
				  function(resp){	
					buttonAction = '';
				  }
			);
		},
		
		doApprove :function(){		
			valid2.reset();	
			if(buttons.doCheck()){return;}
			var sendRecord = getDataFromForm();
			ajaxpost( "approve" , sendRecord, function(resp){grid.load(resp.rtnList);});	 
		},
		
		doReject :function(){
			valid2.reset();	
			if(buttons.doCheck()){return;}	
			var sendRecord = getDataFromForm();
			ajaxpost( "reject" , sendRecord ,function(resp){grid.load(resp.rtnList);});	
		},
		
		doCancelApprove :function(){
			valid2.reset();	
			if(buttons.doCheck()){return;}	
			var sendRecord = getDataFromForm();
			ajaxpost( "cancelapprove" , sendRecord ,function(resp){grid.load(resp.rtnList);});	
		},
		
		doCancelReject :function(){
			valid2.reset();
			if(buttons.doCheck()){
				return;
			}
			var sendRecord = getDataFromForm();	
			ajaxpost( "cancelreject" , sendRecord ,function(resp){grid.load(resp.rtnList);});	
		},
		
		doCheck :function(){
			if(!$('LOAN_ID').innerHTML){ 
				alert("請先查詢後，再進行作業!"); 
				return true;
			}
			if(form1.QUERY_TYPE.value	== '1' && $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
			//if($F('QUERY_TYPE')	== '1' && $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
				if(!confirm("查詢之貸款帳號與畫面上貸款帳號不同，請確認是否要繼續處理")){
					return true;
				}
			}	
		},
		
		doDelete:function(){
			if(!$('LOAN_ID').innerHTML){ 
				alert("請先查詢後，再進行作業!"); 
				return;
			}
							
			if( getRadioValue( "form1" , "QUERY_TYPE" )	== 1 && $F('INPUT_ID1')!== $('LOAN_ID').innerHTML){
				if(!confirm("查詢之貸款帳號與畫面上貸款帳號不同，請確認是否要繼續處理")){return;}
			}
			var sendRecord = grid.getCheckedRecord()[0];		
			if(!sendRecord) {
				alert("無資料!");
				return;		
			}							
			ajaxpost( "delete" , sendRecord, function(resp){									
					grid.load(resp.rtnList||[]);
					if(!resp.rtnList){
						buttons.doClearAll();
						dataChange.QUERY_TYPE(getRadioValue( "form1" , "QUERY_TYPE" ));
					}
				},	function(resp){ 
				}
			);	
		
		},
		
		doClear :function(){
			$('SPEC_KIND').enable();/* [20190312] */
			$('OTHER_MEMO').enable();/* [20190312] */

			$('CRED_ID').value = "";		
			$('OTHER_MEMO').value = "";	
			$('BORROW_NAME').value = "";	
			$('SPEC_KIND').value = "";	
			$('CRED_DEPT').value = "";
		},
		
		doClearAll :function(){
			buttons.doClear();
			$('LOAN_ID').innerHTML = "";	
			$('GAGE_ADDR').innerHTML = "";	
			$('SPEC_PROCESS_NM').innerHTML = "";	
			$('PAY_DELAY_NM').innerHTML = "";	
			$('ASSIGN_DATE').innerHTML = "";
			$('CONFIRM_DATE').innerHTML = "";
			$('REJECT_DATE').innerHTML = "";
			$('CONVERT_CNT').innerHTML = "";
		},
		
		doGetRec :function( record ){
			$('SPEC_KIND').enable();/* [20190312] */
			$('OTHER_MEMO').enable();/* [20190312] */

			var val = null;
			var A196_KEY = null;/* [20190312] */

			for( var key in record ){
				val = record[key];

				/* [20190312] */
				if ( 'A196_KEY' == key ) {
					 A196_KEY = val;
					 continue;
				}

				var element = $('form2').down('[id="'+key+'"]');
				if( element ){
					var tagName = element.tagName.toUpperCase();
					if( element.tagName == 'TD' ){
						element.innerHTML = val || '';
					}else{
						element.value = val;
					}
				}
			}
			
			$('OTHER_MEMO').value = record.OTHER_MEMO || "";
			dataChange.QUERY_TYPE(getRadioValue( "form1" , "QUERY_TYPE" ));	
			$('ASSIGN_DATE').innerHTML =  Date.toInputROC(record.ASSIGN_DATE || "","/");
			$('CONFIRM_DATE').innerHTML = Date.toInputROC(record.CONFIRM_DATE || "","/");
			$('REJECT_DATE').innerHTML = Date.toInputROC(record.REJECT_DATE || "","/");			
			getCONVERT_CNT_AFT = record.CONVERT_CNT_AFT;			
			
			dataChange.DEPT( record.CRED_ID );

			/* [20190312] */
			if ( A196_KEY ) {
				$('SPEC_KIND').disable();
				$('OTHER_MEMO').disable();
			}
		},
		linkTo_DSC8_3100:function(BORROW_ID,CONTROL_SOURCE){	
			
		popupWin.popup({
			src: '<%=dispatcher%>/DSC8_3100/prompt',scrolling : 'yes',
			parameters: { 
				LOAN_ID : BORROW_ID,
				CONTROL_TYPE : 'U',
				CONTROL_SOURCE : CONTROL_SOURCE,
				BORROW_NAME : $('BORROW_NAME').value
			}, 
			width: 600, 
			height: 350,
			cb : function(obj){}
		});
		
	}	
	};
	var getCONVERT_CNT_AFT;
	function getDataFromForm(){
		var record = grid.getCheckedRecord()[0];		
		var index = $('CRED_DEPT').selectedIndex;
		if( index >= 0 ){
			record.CRED_DEPT = $('CRED_DEPT').value;
			record.CRED_DEPT_NM = $('CRED_DEPT').options[index].innerHTML;		
		}
		var index = $('CRED_ID').selectedIndex;	
		if( index >= 0 ){
			record.CRED_ID = $('CRED_ID').value;
			record.CRED_NAME = $('CRED_ID').options[index].innerHTML;
		}	
		var index = $('SPEC_KIND').selectedIndex;
		if( index >= 0 ){
			record.SPEC_KIND = $('SPEC_KIND').value;
			record.SPEC_KIND_NM = $('SPEC_KIND').options[index].innerHTML;
		}			
		record.QUERY_TYPE = getRadioValue("form1","QUERY_TYPE");
		record.OTHER_MEMO = $('OTHER_MEMO').value;
		record.LOAN_ID = $('INPUT_ID1').value;
		record.CONVERT_CNT_AFT = getCONVERT_CNT_AFT;
		record.BORROW_ID = $('BORROW_ID').value;	
		if(getRadioValue( "form1" , "QUERY_TYPE" )=="3"){
			record.GAGE_ADDR = $('MASK_GAGE_ADDR').value;	
			record.BORROW_NAME = $('BORROW_NAME').value;
		}		
		return record;
	}

	var dataChange={
		DEPT:function( cred_id_default ){
			ajaxpost( "getCredID" , {CRED_DEPT:$F('CRED_DEPT'),SPEC_KIND:$F('SPEC_KIND')},function(resp){
					// del opts
					while($('CRED_ID').lastChild){
						$('CRED_ID').removeChild($('CRED_ID').lastChild);
					}
					var empty = document.createElement("OPTION");
					empty.value = "";
					empty.appendChild(document.createTextNode("請選擇"));
					$('CRED_ID').appendChild(empty);
					// rtn value
					var list = resp.CRED_ID_LIST;
					// add opts
					for( var i = 0 ; i < list.length ; i = i + 1 ){
						var opt = document.createElement("OPTION");
						opt.value = list[i].ID;
						opt.appendChild(document.createTextNode(list[i].NAME));
						$('CRED_ID').appendChild(opt);
					}
					
					// set value
					if( cred_id_default ){
						$('CRED_ID').value = cred_id_default; //show
					}
				}
			);		
		},	
		SPEC_KIND:function(){	
			ajaxpost( "getConertCNT" , {SPEC_KIND:$F('SPEC_KIND')},function(resp){				
				getCONVERT_CNT_AFT = resp.CONVERT_CNT_AFT;
				CONVERT_CNT.innerHTML = getCONVERT_CNT_AFT;
				
				// del opts
				while($('CRED_DEPT').lastChild){
					$('CRED_DEPT').removeChild($('CRED_DEPT').lastChild);
				}
				var empty = document.createElement("OPTION");
				empty.value = "";
				empty.appendChild(document.createTextNode("請選擇"));
				$('CRED_DEPT').appendChild(empty);
				// rtn value
				var list = resp.DEPT_LIST;
				// add opts
				for( var i = 0 ; i < list.length ; i = i + 1 ){
					var opt = document.createElement("OPTION");
					opt.value = list[i].CODE;
					opt.appendChild(document.createTextNode(list[i].CODE_NM));
					$('CRED_DEPT').appendChild(opt);
				}
			})	
		},
		QUERY_TYPE:function(value){		
			var record = grid.getCheckedRecord()[0];			
			if(value=="3"){				
				$('BORROW_NAME').show();
				$('BORROW_NAME1').innerHTML = "";
				$('GAGE_ADDR').innerHTML = "";
				var check ;
				if(record && record.MASK_GAGE_ADDR){
					check = record.MASK_GAGE_ADDR;
				}else{
					check = "";			
				}				
				while(!$('GAGE_ADDR').lastChild){
					var address = document.createElement( "input" );	
					address.className = "validateInsert_Check validateUpdate_Check" ;
					address.id = "MASK_GAGE_ADDR" ;
					address.Name = "MASK_GAGE_ADDR" ;
					address.type = "text" ;
					address.size = "45";
					$('GAGE_ADDR').appendChild(address);		
				}
				$('MASK_GAGE_ADDR').value = check;				
			}
			if(value=="1"||value=="2"){
				$('BORROW_NAME').hide();
				if(record&&record.BORROW_NAME){
					$('BORROW_NAME1').innerHTML = record.BORROW_NAME;
					$('BORROW_NAME').value = record.BORROW_NAME;
				}
				if(record&&record.GAGE_ADDR){					
					$('GAGE_ADDR').innerHTML =  record.MASK_GAGE_ADDR;
				}else{
					$('GAGE_ADDR').innerHTML = "";				
				}				
			}
		
		}
	}

	function getRadioValue( form , inputName){
		var radioes = $(form)[inputName];		
		if(radioes){
			for( var i = 0 ; i < radioes.length ; i = i + 1){
				if(radioes[i].checked){
					return radioes[i].value;
				}
			}		
		}
		return "";
	}

	return{
		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 6, allSortable: true ,
					autoCheckBox:{
						valueKey:"SEQ_NO",
						type :"radio" ,
						action: function(checkbox , boxStatus , records) {
							valid2.reset();
							checkedApplyId = checkbox.value;							
							buttons.doGetRec(records[0]);
						}
					},			
					column:[
						{header:"承辦科別", key:"CRED_DEPT",
						 render: function(record,value){
								return record.CRED_DEPT_NM;
							}
						},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header:"徵信人員", key:"CRED_NAME", attrs: {style:"font-family:'EUDC'"}},
						{header:"特殊案件類別", key:"SPEC_KIND_NM"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header:"借款人姓名", key:"BORROW_NAME", attrs: {style:"font-family:'EUDC'"}},
						{header:"種類換算件數", key:"CONVERT_CNT"},
						{header:"目前進度", key:"SPEC_PROCESS_NM"},
						<%--[20240729] 修改件 陳勁谷 難字修改 --%>
						{header:"覆核人員/退件人員", key:"CONFIRM_NAME", attrs: {style:"font-family:'EUDC'"}},
						{header:"覆核/退件日期", key:"CONFIRM_DATE", 
							render:function(rec,val){
								if(rec.SPEC_PROCESS == "2"){ return Date.toInputROC( val || "" ,"/");}
								if(rec.SPEC_PROCESS == "3"){ return Date.toInputROC( rec.REJECT_DATE || "","/" );} 
								return "";
							}
						}
					],
					afterLoad:function(){
						var checks = $('grid').select("input[type=radio]");
						var check;
						for( var i = 0 ; i < checks.length ; i = i + 1 ){						
							if( checks[i].value == checkedApplyId){
								check = checks[i];
								break;
							}
						}
						if(check){
							check.checked = true;
							if(check.onclick){ check.onclick(); }							
						} else if ( checks[0] ){
							checks[0].checked = true;
							if(checks[0].onclick){ checks[0].onclick(); }
							checkedApplyId = checks[0].value;
						}						
					}
				}
			);
			
			$("btn_query").observe('click', function(event){ buttons.doQuery(); });
			$("insert").observe('click', function(event){ buttons.docheckInsert(); });
			$("modify").observe('click', function(event){ buttons.doUpdate(); });
			$("delete").observe('click', function(event){ buttons.doDelete(); });
			$("approve").observe('click', function(event){ buttons.doApprove(); });
			$("reject").observe('click', function(event){ buttons.doReject(); });
			$("cancelapprove").observe('click', function(event){ buttons.doCancelApprove(); });
			$("cancelreject").observe('click', function(event){ buttons.doCancelReject(); });
			$("clear").observe('click', function(event){ buttons.doClear(); });
			$("CRED_DEPT").observe('change',function(event){ dataChange.DEPT(); });
			$("SPEC_KIND").observe('change',function(event){ dataChange.SPEC_KIND(); });
			var checks = document.getElementsByName('QUERY_TYPE');
			for( var i = 0 ; i < checks.length ; i = i + 1 ){							
				$(checks[i]).observe('click',function(event){ dataChange.QUERY_TYPE(getRadioValue("form1","QUERY_TYPE"))});
			}
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

						<!------------------------------------- -->
						<form name="form1" id="form1">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">                        
                        <input id="CONTROL_CODE" name="CONTROL_CODE" type="hidden" value="">
                            <tr>
                        	    <td class="tbYellow" width="35%" align="center">
									<input type="radio" value="1" name="QUERY_TYPE" checked /> 貸款帳號
									<input type="radio" value="2" name="QUERY_TYPE"  /> 受理編號
									<input type="radio" value="3" name="QUERY_TYPE"  /> 身份證字號
								</td>
                                <td class="tbYellow2" colspan=2>
                                	<input id="INPUT_ID1" name="INPUT_ID1" type="text" maxlength="11" size="12" class="text2 validateLOAN_ID" onblur="this.value = this.value.toUpperCase()" />
									<input type="button" name="btn_query" id="btn_query" class="button" value="查詢" />
								</td>
							</tr>
							<tr>
								<td class="tbYellow1" align="center" colspan="3">
									<input type="button" name="insert" id="insert" class="button" value="派件"/>
									<input type="button" name="modify" id="modify" class="button" value="修改"/>
									<input type="button" name="delete" id="delete" class="button" value="刪除"/>
									<input type="button" name="approve" id="approve" class="button" value="覆核"/>
									<input type="button" name="reject" id="reject" class="button" value="退件"/>
									<input type="button" name="cancelapprove" id="cancelapprove" class="button" value="取消覆核"/>
									<input type="button" name="cancelreject" id="cancelreject" class="button" value="取消退件"/>
									<input type="button" name="clear" id="clear" class="button" value="清除"/>
								</td>
							</tr>                        
                        </table>
                        </form>
						<!------------------------------------- -->

						<!------------------------------------- -->
						<table id='grid'></table>		
						<!------------------------------------- -->							

						<form id="form2" name="form2" >
						<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">						
						<!--第三個talbe -->
							<tr>
								<td class="tbYellow1" align="center" colspan="4">
								<b><font size="3">基本資料</font></b>
								</td>
							
							</tr>
							<tr>
								<td class="tbYellow" width="12%" align="left">
								貸款帳號
								</td>
								<td id = "LOAN_ID" class="tbYellow2 " width="38%" colspan="3">
								
								</td>
							</tr>
							<tr>
								<td class="tbYellow" align="left">
								借款人姓名
								</td>
								<td class="tbYellow2">
								<%--[20240729] 修改件 陳勁谷 難字修改 --%>
								<span id = "BORROW_NAME1" name = "BORROW_NAME1" style="font-family:'EUDC'"></span>
								<input id="BORROW_NAME" name="BORROW_NAME" type="text" maxlength="11" size="12" class="text2 validateInsert_Check validateUpdate_Check" alt="ch" />
								</td>
								<td class="tbYellow" align="left" width="12%">
								指派日期
								</td>
								<td id = "ASSIGN_DATE" class="tbYellow2" width="38%">
								
								</td>							
							</tr>
							<tr>
								<td class="tbYellow" align="left" >
								特殊案件類別
								</td>
								<td class="tbYellow2" colspan="3">									
										<select id="SPEC_KIND" class = "validateInsert_Check validateUpdate_Check">
										<c:forEach var="map" items="${SPEC_KIND_LIST}" >
										<option value = "${map.CODE}" > ${map.CODE_NM} </option>
										</c:forEach>
										</select>
										<input id="OTHER_MEMO" name="OTHER_MEMO" type="text" size="18" class="text2 validateMomo_Check" value = "說明"/>
								</td>
							</tr>
							<tr>
								<td class="tbYellow" align="left">
								承辦科別
								</td>
								<td id = "c1" class="tbYellow2">
									<select id="CRED_DEPT" class ="validateInsert_Check validateUpdate_Check">
										<c:forEach var="map" items="${DEPT_LIST}" ><option value = "${map.CODE}" > ${map.CODE_NM} </option>
										</c:forEach>
									</select>
								</td>
								<td class="tbYellow" align="left">
								徵信/作業人員
								</td>
								<td class="tbYellow2">
								<%--[20240729] 修改件 陳勁谷 難字修改 --%>
								<select id="CRED_ID" class = "validateInsert_Check validateUpdate_Check" alt="ch">
										
									</select>
								</td>							
							</tr>
							<tr>
								<td class="tbYellow" align="left">
								擔保品地址
								</td>
								<%--[20240729] 修改件 陳勁谷 難字修改 --%>
								<td id = "GAGE_ADDR" class="tbYellow2" style="font-family:'EUDC'">
									
								</td>
							
								<td class="tbYellow">
								種類換算件數
								</td>
								<td id = "CONVERT_CNT" class="tbYellow2">
								
								</td>							
							</tr>
							<tr>
								<td class="tbYellow" align="left">
								目前進度
								</td>
								<td id = "SPEC_PROCESS_NM" class="tbYellow2">
								
								</td>
								<td class="tbYellow" align="left">
								覆核日期
								</td>
								<td id = "CONFIRM_DATE" class="tbYellow2" >
								
								</td>							
							</tr>
							<tr>
								<td class="tbYellow" align="left">
								繳息狀況
								</td>
								<td id = "PAY_DELAY_NM" class="tbYellow2">
								
								</td>
								<td class="tbYellow" align="left">
								退件日期
								</td>
								<td id = "REJECT_DATE" class="tbYellow2">
								
								</td>							
							</tr>
							<input id="BORROW_ID" name="BORROW_ID" type="hidden"/>								
						</table>
						</form>
						
						<div id='dtlDiv' style="position: absolute; top: 0px; left: -2px; visibility: hidden" align='center'><iframe src='' name='dtlFrame' width='99%' height='500' id='dtlFrame'></iframe></div>
</body>
</html>
