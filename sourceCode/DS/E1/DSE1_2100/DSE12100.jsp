<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSE12100.jsp
功能：協議清償作業
作者：黃子玹
完成：2013/09/04

[20240215]難字調整

[20240315]問題單號:20240311144850
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		  <%-- 月曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			  <%-- 日期用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script> 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>      <%-- 表格用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>		  <%-- 檔案下載 --%>

<%--[20240215]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type="text/JavaScript">

Event.observe(window, 'load', new DSE12100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE12100(){
	
	var valid1;
	var valid2;
	var legal2;
    var grid_B,grid_C,grid_D,grid_E,grid_F;
	var fileList;
	var C140List;
	var REFER_ID='${REFER_ID}';
	var LOAN_ID='${LOAN_ID}';	
	var C_LOAN_ID;
	var C_SPR_STEP;
	var C_SEQ_NO;
	var C_BARGAIN_APPR_DATE;
	var REM_CREDIT;
	var END_DATE_C;
     
	//畫面檢核
	function initValidation(){	 

		Validation.addAllThese([
			[ 'chkRATE',  '請輸入1-200、小數點2位數之數值!',
				function(v,elem){			
					if(v.indexOf('.')!=-1){	
						var point = v.split('.')[1];
						if (point.length > 2){
						    return false;
						}
						return !(v > 200 || v < 1);
					}else{						
						return !(v > 200 || v < 1);
					}
				}
			]
		]);
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
	}	
	
   //按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0076 : 'btn_upload',
			//B0077 : 'btn_deleteE208',			
			B0003 : 'btn_insert',
			B0004 : 'btn_update',
			B0005 : 'btn_delete',
			B0070 : 'btn_agree',
			B0071 : 'btn_cancel',
			B0230 : 'btn_repudiate',
			B0236 : 'btn_confirm',
			B0238 : 'btn_confirm2',
			B0239 : 'btn_delay',
			B0174 : 'btn_print'		
		};		
		legal2=legal;
		<dz:grantButtons FUNC_ID ="DSE12100"/>
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_2100/" + actionName,
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
			}
		);
	}
	
	//--------------------------------------------------------------------------
	// 建立/關閉coverPage(不讓使用者在上載時做任何事)
	//--------------------------------------------------------------------------
	var auxiliary = {
		createCoverPage:function(){
			CSRUtil.createCoverPage('_frontCover');
			$('_frontCover').show();
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};
	
	var actions = {
		<%--[20240315]問題單號:20240311144850--%>
		removeInputTypeFile : function(){
			var input = $('import_file');
			$('import_file').remove();
			parseEUDC("ap");
			$('import').insert(input);
		},
	
		getReqMap: function(){			
		
			var reqMap={
				'REFER_ID': $F('REFER_ID'),
				'ID': $F('ID'),
				'NAME': $F('NAME')
			};
			return reqMap;
		}
		// 查詢
        ,doQuery : function(){			

			//原貸帳號、ID、姓名至少需輸入一項，否則顯示錯誤訊息:“請至少輸入一項查詢條件”  
			if( !$F('REFER_ID') && !$F('ID') &&  !$F('NAME')){				
			
				$('REFER_ID').style.backgroundColor = '#FFB0AF';	
				$('ID').style.backgroundColor = '#FFB0AF';
				$('NAME').style.backgroundColor = '#FFB0AF';				
				alert('請至少輸入一項查詢條件!');
				return;
			}
			
			ajaxPost('query', {reqMap : Object.toJSON(actions.getReqMap())}, 
				function(resp){
					$('REFER_ID').style.backgroundColor = 'white';	
					$('ID').style.backgroundColor = 'white';
					$('NAME').style.backgroundColor = 'white';	
					var rtnList = resp.rtnList || [];
					grid_B.load(rtnList);
					
					grid_C.load([]);
					grid_D.load([]);	
					grid_E.load([]);
					grid_F.load([]);	
					actions.clear();	
					$('import_file').value = '';
					$('B_LOAN_ID').update('');
					$('FILE_ID').update('');
				},function(resp){
					grid_B.load([]);
					grid_C.load([]);
					grid_D.load([]);	
					grid_E.load([]);
					grid_F.load([]);	
					actions.clear();	
					$('import_file').value = '';
					$('B_LOAN_ID').update('');
					$('FILE_ID').update('');					
					$('REFER_ID').style.backgroundColor = 'white';	
					$('ID').style.backgroundColor = 'white';
					$('NAME').style.backgroundColor = 'white';	
				}	
			);
        }
		//由B區貸款帳號取得並顯示C區、D區資訊
		,getDetailList1 : function(B_LOAN_ID){

			ajaxPost('query1', {B_LOAN_ID : B_LOAN_ID}, 
			function(resp){					
				grid_C.load(resp.BargainList || []);
				grid_D.load(resp.DList || []);
				REM_CREDIT = resp.REM_CREDIT || 0;
				END_DATE_C = resp.END_DATE_C || '';
				if(B_LOAN_ID){
					var link = new Element('a' , { href : '#' } ).update('債權試算');
						link.observe( 'click', function (event){ 																			
						actions.linkToDSE11800(B_LOAN_ID);
					});
					$('B_LOAN_ID').update(B_LOAN_ID);							
					$('FILE_ID').update(link);
					//IDList設值	
					$('APPLICANT_ID').options.length = 1;
					
					var IDList = resp.IDList || [];					
					IDList.each(
						function(data) {
							$('APPLICANT_ID').add(new Option(data.NAME, data.ID));
						}  
					);	
				}	
				
				grid_E.load([]);
				grid_F.load([]);	
				actions.clear();	
				$('import_file').value = '';		
			
			},function(resp){					
				//失敗把前次內容清掉								
				grid_C.load([]);
				grid_D.load([]);	
				grid_E.load([]);
				grid_F.load([]);		
				actions.clear();	
				$('import_file').value = '';	
				$('B_LOAN_ID').update('');
				$('FILE_ID').update('');		
			});			
		}		
		//連結至 DSE11800				
		,linkToDSE11800 : function(B_LOAN_ID) {
       	
			var source = '<%=dispatcher%>/DSE1_1800/prompt'; 
			popupWin.fullPopup({
				parameters : { 'LOAN_ID': B_LOAN_ID,'LINK_FROM' : 'DSE1_2100' },
				src : source
				//,cb : function(){actions.getDetailList1(B_LOAN_ID)}
			});
			
			popupWin.callbackHandler = function(){actions.getDetailList1(B_LOAN_ID)};
        
		}	
 		//由C區選取資料之貸款帳號、協議日期取得並顯示E區
		,getDetailList2 : function(data,rec) {
			
			C_LOAN_ID = rec.LOAN_ID || '';
			C_SPR_STEP = rec.SPR_STEP || '';
			C_BARGAIN_APPR_DATE = rec.BARGAIN_APPR_DATE || '';
			C_SEQ_NO = rec.SEQ_NO || '';
			C_END_DATE = rec.END_DATE || '';
			ajaxPost('query2', {C_LOAN_ID : C_LOAN_ID, C_BARGAIN_APPR_DATE  : C_BARGAIN_APPR_DATE, C_SEQ_NO : C_SEQ_NO, C_END_DATE : C_END_DATE}, 
			function(resp){				
				grid_D.load(resp.DList || []);
				REM_CREDIT = resp.REM_CREDIT || 0;
				END_DATE_C = resp.END_DATE_C || '';
				grid_E.load(resp.fileList || []);	
				grid_F.load(resp.C140List || []);				
				
				$('btn_upload').enable();
				var E200Map = data[0];			
				$('table_E').select('input[type="text"]', 'input[type="hidden"]','select').each(function(elem){
									
					var oID = elem.id;					
					var v = E200Map[oID];							
					if(oID == 'BARGAIN_APPR_DATE' || oID == 'BEGIN_DATE' || oID == 'CAL_DATE' ){
					
						elem.setValue(Date.toInputROC(v) || '');
					
					}else if(oID == 'TOTAL_AMT' || oID == 'BARGAIN_AMT' || oID == 'LATER_AMT' 
						 || oID == 'ALL_AMT' || oID == 'OLD_REMAIN_AMT' ){						
						elem.setValue(CSRUtil.$fmt(v,'#,###') || 0);
					}else{	
						elem.setValue(v || '');	
					}					
				});
				$w('BAD_AMT PAY_AMT REMAIN_AMT ALL_AMT DUTY_PAY_AMT').each(
					function(id){
						$(id).update(CSRUtil.$fmt(E200Map[id],'#,###') || 0);
					}			
				);				
				
				$('OLD_BARGAIN_APPR_DATE').setValue(E200Map['BARGAIN_APPR_DATE'] || '');//隱藏欄位設值				
				//$('INPUT_DEPT_NM').update(E200Map['BARGAIN_DEPT_NM'] || '');//協議單位
				$('INPUT_NAME').update(E200Map['INPUT_NAME'] || '');//協議人員
				$('CONFIRM_NAME').update(E200Map['CONFIRM_NAME'] || '');//覆核人員
				$('CONFIRM_DATE').update(Date.toROC(E200Map['CONFIRM_DATE'] || ''));//覆核日期
				$('INPUT_DATE').update(Date.toROC(E200Map['INPUT_DATE'] || ''));//輸入日期
				$('SEQ_NO_E').innerHTML = C_SEQ_NO;
				$('BARGAIN_NAME').update(E200Map['BARGAIN_NAME'] || '');//覆核人員
				$('DELAY').update(E200Map['DELAY'] || '');//延期繳款期數
				actions.colControl();
				actions.colControl_A();
				actions.colControl_B();
				actions.doChangeList(E200Map['BARGAIN_DEPT'] || '',rec.BARGAIN_ID);
				
			},function(resp){					
				//失敗把前次內容清掉
				grid_D.load([]);
				grid_E.load([]);
				grid_F.load([]);	
				actions.clear();	
			});		
		}
		
		//駐點下拉選單連動承辦法務選單
		,doChangeList :  function(CRED_DEPT_CODE,rec_BARGAIN_ID){	

			$('BARGAIN_ID').options.length = 1;
			
			ajaxPost( 'changelist',	{CRED_DEPT_CODE: CRED_DEPT_CODE},
				function(resp){			
					var BARGAIN_ID_LIST = resp.BARGAIN_ID_LIST;
					BARGAIN_ID_LIST.each(
						function(data) {
							$('BARGAIN_ID').add(new Option(data.NAME, data.ID));
						}  
					);
					if (rec_BARGAIN_ID){
						$('BARGAIN_ID').value=rec_BARGAIN_ID;
					} 
				}					
			);
		}
		

		
		//取得E區的資料		
		,storedataMap: function(){
		
			var dataMap = {};

			$('table_E').select('input[type="text"]', 'input[type="hidden"]','select').each(function(elem){
								
				var oID = elem.id;
	
				if(oID == 'TOTAL_AMT' || oID == 'BARGAIN_AMT' || oID == 'LATER_AMT' || oID == 'ALL_AMT' || oID == 'PAY_AMOUNT'
				   || oID == 'OLD_REMAIN_AMT'){	
				
					dataMap[elem.id] =  elem.value.replace(/,/g,'') || '';
					
				}else{	
					dataMap[elem.id]  = elem.value;	
				}				
			});	
			
			dataMap['APPLICANT_NAME'] = $('APPLICANT_ID').options[$('APPLICANT_ID').selectedIndex].innerText.trim() || '';		
			
			dataMap['LOAN_ID'] = $('B_LOAN_ID').innerHTML || '';
			
			$w('BAD_AMT PAY_AMT REMAIN_AMT ALL_AMT DUTY_PAY_AMT').each(
				function(id){
					dataMap[id] = $(id).innerHTML.replace(/,/g,'') || '' 
				}			
			);		
			return dataMap;	
		}
		//新增
		,doInsert : function(){	
			
			valid1.reset();
			valid1.clear();
			//if 還款方式!= 一次償還，則分期償還金額、分期期數、分期始日為必輸欄位
			if($F('SPR_TYPE') != '5' && $F('SPR_TYPE') != ''){
				valid1.define( 'required' , [{ id : 'PAY_TERM'}] );//分期期數
				valid1.define( 'required' , [{ id : 'LATER_AMT'}] );//分期償還金額	
				valid1.define( 'required' , [{ id : 'PAY_AMOUNT'}] );//分期金額
				valid1.define( 'required' , [{ id : 'BEGIN_DATE'}] );//分期始日
				valid1.define( 'validate-ROCDate' , [{ id : 'BEGIN_DATE'}] );//分期始日		
			}	
			//if 新舊件= 舊件，則舊件債權總額，債權計算至日期為必輸欄位
			if($F('CASE_TYPE') == '0'){	
				valid1.define( 'required' , [{ id : 'OLD_REMAIN_AMT'}] );//舊件債權總額
				valid1.define( 'required' , [{ id : 'CAL_DATE'}] );//債權計算至日期	
				valid1.define( 'validate-ROCDate' , [{ id : 'CAL_DATE'}] );//債權計算至日期		
			}	
			
			if($('BARGAIN_REASON_CODE').value=='99'){
				valid1.define( 'required' , [{ id : 'BARGAIN_REASON'}] );//協議原因
			}
			valid1.define( 'required' , [{ id : 'BARGAIN_DEPT'}] );//駐點
			valid1.define( 'required' , [{ id : 'BARGAIN_ID'}] );//協議法務
			valid1.define( 'required' , [{ id : 'RATE'}] );//放款加權平均利率債權受償率
			valid1.define( 'chkRATE' , [{ id : 'RATE'}] );//放款加權平均利率債權受償率			
			
			if(!valid1.validate()){
				return;
			}
			if($F('DELAY_ADD').length != 0 || $F('DELAY_SUB').length != 0){
				alert('若需延期繳款，請所有分期階段均輸入完畢後再執行延期繳款。請先清空延期繳款欄位。');
				return;			
			}
			var inputMap = 	actions.storedataMap();
						
			//發送ajax
			ajaxPost( 'insert' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML, END_DATE : END_DATE_C},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);						
			
		}		

		//修改
		,doUpdate : function(action){			

			valid1.reset();
			valid1.clear();
			
			var chkData = grid_C.getCheckedRecord();			
			if( chkData.length == 0 ){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			//if 還款方式!= 一次償還，則分期償還金額、分期期數、分期始日為必輸欄位
			if($F('SPR_TYPE') != '5' && $F('SPR_TYPE') != ''){
				valid1.define( 'required' , [{ id : 'PAY_TERM'}] );//分期期數
				valid1.define( 'required' , [{ id : 'LATER_AMT'}] );//分期償還金額	
				valid1.define( 'required' , [{ id : 'PAY_AMOUNT'}] );//分期金額
				valid1.define( 'required' , [{ id : 'BEGIN_DATE'}] );//分期始日
				valid1.define( 'validate-ROCDate' , [{ id : 'BEGIN_DATE'}] );//分期始日		
			}	

			//if 新舊件= 舊件，則舊件債權總額，債權計算至日期為必輸欄位
			if($F('CASE_TYPE') == '0'){	
				valid1.define( 'required' , [{ id : 'OLD_REMAIN_AMT'}] );//舊件債權總額
				valid1.define( 'required' , [{ id : 'CAL_DATE'}] );//債權計算至日期	
				valid1.define( 'validate-ROCDate' , [{ id : 'CAL_DATE'}] );//債權計算至日期		
			}	
			
			if($('BARGAIN_REASON_CODE').value=='99'){
				valid1.define( 'required' , [{ id : 'BARGAIN_REASON'}] );//協議原因
			}
			valid1.define( 'required' , [{ id : 'BARGAIN_DEPT'}] );//駐點
			valid1.define( 'required' , [{ id : 'BARGAIN_ID'}] );//協議法務
			valid1.define( 'required' , [{ id : 'RATE'}] );//放款加權平均利率債權受償率
			valid1.define( 'chkRATE' , [{ id : 'RATE'}] );//放款加權平均利率債權受償率

			if(!valid1.validate()){
				return;
			}
			if($F('DELAY_ADD').length != 0 || $F('DELAY_SUB').length != 0){
				alert('若需延期繳款，請所有分期階段均輸入完畢後再執行延期繳款。請先清空延期繳款欄位。');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			if(C_SPR_STEP != $F('SPR_STEP') ){
				alert('分期階段不可異動');
				return;
			}

			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'update' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML, END_DATE : END_DATE_C},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
		}
		
		//刪除
		,doDelete : function(action){
		
			var chkData = grid_C.getCheckedRecord();			
			if( chkData.length == 0 ){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			
		    if(!confirm('該筆紀錄將會全部刪除，請確認是否繼續？')){
			    return;
			}
			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'delete' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
		}
		//覆核
		,doAgree : function(action){
			
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
		
			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'agree' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
			
		}
		
		//取消覆核
		,doCancel : function(action){
			
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			
			if(!confirm('請確認是否取消覆核')){
			    return;
			}
		
			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'cancel' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
			
		}

		//毀諾
		,doRepudiate : function(action){
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			
			if(!confirm('毀諾後不可取消毀諾，請確認是否繼續?')){
			    return;
			}
		
			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'repudiate' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
						
				}
			);				
		}
		
		//延期繳款
		,doDelay : function(action){
		
		    valid1.reset();
			valid1.clear();
			
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			
			if($F('DELAY_ADD').length == 0 && $F('DELAY_SUB').length == 0){
				alert('增加期數或減少期數需擇一輸入');
				return;			
			}
			if($F('DELAY_ADD').length != 0 && $F('DELAY_SUB').length != 0){
				alert('增加期數或減少期數需擇一輸入');
				return;			
			}
			if(!confirm('延期繳款將連動修改後面分期階段之分期始日，請確認是否繼續?')){
			    return;
			}
			
		
			var inputMap = 	actions.storedataMap();
			
			ajaxPost( 'delay' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
						
				}
			);				
		}
		
		//一次協議確認
		,doConfirm : function(action){
		
			valid1.reset();
			valid1.clear();
			
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			valid1.define( 'required' , [{ id : 'RECEIPT_SERNO'}] );//單據序號
			
			if(!valid1.validate()){
				return;
			}
			
			if($F('RECEIPT_SERNO').length != 10){
				alert('單據序號需為10碼!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
		
			var inputMap = 	actions.storedataMap();
			
			var checkedRecord = grid_F.getCheckedRecord();
			
			//檢核是否至少勾選一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆人工暫收資料");
				return;
			}
			
			ajaxPost( 'confirm' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML,checkedList : Object.toJSON(checkedRecord)},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
			
		}
		
		//分期協議確認
		,doConfirm2 : function(action){
		
			valid1.reset();
			valid1.clear();
			
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			valid1.define( 'required' , [{ id : 'RECEIPT_SERNO'}] );//單據序號
			
			if(!valid1.validate()){
				return;
			}
			
			if($F('RECEIPT_SERNO').length != 10){
				alert('單據序號需為10碼!');
				return;			
			}
			
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) 
			//|| C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)，顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
		
			var inputMap = 	actions.storedataMap();
			
			var checkedRecord = grid_F.getCheckedRecord();
			
			//檢核是否至少勾選一筆資料
			if(checkedRecord.length==0){
				alert("請至少選取一筆人工暫收資料");
				return;
			}
			
			ajaxPost( 'confirm2' , {inputMap : Object.toJSON(inputMap), B_LOAN_ID : $('B_LOAN_ID').innerHTML,checkedList : Object.toJSON(checkedRecord)},				
				function(resp){
				
					grid_C.load(resp.BargainList || []);
					actions.clear();
					
				},function(resp){					
					//失敗把前次內容清掉								
					//grid_C.load([]);					
					//actions.clear();								
				}
			);		
			
		}
		
		,doPrint: function(){
		
		    valid1.reset();
			valid1.clear();
		
			var chkData = grid_C.getCheckedRecord();			
			if(chkData.length == 0){
				alert('請選取一筆協議清償資料!');
				return;			
			}
			
			valid1.define( 'required' , [{ id : 'RECEIPT_SERNO'}] );//單據序號
			
			if(!valid1.validate()){
				return;
			}
			
			if($F('RECEIPT_SERNO').length != 10){
				alert('單據序號需為10碼!');
				return;			
			}

			var inputMap = 	actions.storedataMap();
			//RPTUtil.executePrintByLink('print' , {	'BillList': Object.toJSON(grid.getAllRecords())}, true );
			/*ajaxPost( 'print' , { inputMap : Object.toJSON(inputMap)},
						function(resp){			
							RPTUtil.executePrintByResponse(resp, true);
						}
					);*/
			//因應報表浮水印控管，需設白名單之報表要有引用到浮水印模組
			RPTUtil.downloadFile('${dispatcher}/DSE1_2100/print' , { inputMap : Object.toJSON(inputMap)}, true );						
		}
		
		,getReqMap1: function(){			
			
			var reqMap={
				'LOAN_ID': $F('LOAN_ID'),
				'BARGAIN_APPR_DATE': $F('OLD_BARGAIN_APPR_DATE')				
			};
			return reqMap;
		}
		
		,clear :function(){			
			//清空E區 INPUT
			$('table_E').select('input[type="text"]','select').each(function(elem){
				elem.setValue('');
			});	
			
			//清空E區 SPAN
			$('table_E').select('span').each(function(elem){		
				elem.update('');															
			});	
		}

		//新增檔案  
		,doUpload:function(event){		
			
			//檢核「檔案」是否有選取	
			if(!$F('import_file')){
				alert('請選取要上載的檔案!');
				return;
			}

			//需選取C區資料
			var chkData = grid_C.getCheckedRecord();	
			if(chkData.length == 0){
				alert('請先選取協議清償紀錄!');
				return;
			}	
			//顯示錯誤訊息: “查詢資料與異動資料不符，請重新查詢”
			//if C區選取之貸款帳號(C_LOAN_ID) != E區之貸款帳號(隱藏欄位)(LOAN_ID) || C區選取之協議日期(C_BARGAIN_APPR_DATE) != E區之協議日期(隱藏欄位)(OLD_BARGAIN_APPR_DATE)					
			if(C_LOAN_ID != $F('LOAN_ID') || C_BARGAIN_APPR_DATE != $F('OLD_BARGAIN_APPR_DATE')){
				alert('查詢資料與異動資料不符，請重新查詢!');
				return;
			}
			
			$('SEQ_NO').VALUE = $('SEQ_NO_E').innerHTML;
			auxiliary.createCoverPage();
			$('form1').submit();
		} 
		//數字格式化
		,formatAMT : function(val){
			if(Object.isUndefined(val) || val == null || isNaN(val)){
			 	return '';
			}else{
				return CSRUtil.$fmt(val,'#,###');
			}
		}
		
		//匯入結束 
		,importEnd : function(event){
		
			var obj = window.importFrame.document.getElementById('filedata').innerHTML.evalJSON();		
			
			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				alert(Msg);
			}	
			if(CSRUtil.isSuccess(obj)){			
				var rtnList = obj.File_mapList||[];				
				grid_E.load(rtnList);									
			}else{
				var rtnList = obj.File_mapList||[];			
				grid_E.load(rtnList);	
			}							
			auxiliary.closeCoverPage();
		}
		//下載檔案
		,getDownLoadFile : function(FILE_ID)  {
			RPTUtil.downloadFile( '<%=dispatcher%>/DSE1_2100/download', {'FILE_ID':FILE_ID});						
		}
		,changeBAD_AMT : function(){
			if($F('BARGAIN_COND') == '2'){	//若選擇【免除保證責任】時，「免除金額」欄位則自動帶出「0」，且不能更改。
				$('BAD_AMT').update(0);	
			} else {
				//免除金額 = 對外債權合計-協議總金額		
				ajaxPost( 'changeBAD_AMT' , {REM_CREDIT : REM_CREDIT, TOTAL_AMT : $F('TOTAL_AMT').replace(/,/g,''), 
							OLD_REMAIN_AMT : $F('OLD_REMAIN_AMT').replace(/,/g,''),CASE_TYPE : $F('CASE_TYPE')},
					function(resp){	
						$('BAD_AMT').update(CSRUtil.$fmt(resp.BAD_AMT,'#,###') || 0);				  
					}				
				);	
			}			
		}
		,changeREMAIN_AMT : function(){
				
			//剩餘還款金額 = 協議總金額-累計還款金額
			ajaxPost( 'changeREMAIN_AMT' , {PAY_AMT : $('PAY_AMT').innerHTML.replace(/,/g,''), TOTAL_AMT : $F('TOTAL_AMT').replace(/,/g,'')},
				function(resp){	
					$('REMAIN_AMT').update(CSRUtil.$fmt(resp.REMAIN_AMT,'#,###') || 0);				  
				}				
			);			
		}
		,changeTOTAL_AMT : function(){ //「分期償還金額(原後續金額)」欄位，自動帶入為協議總金額扣除頭期款之金額。
			//分期償還金額(原後續金額) = 協議總金額-頭期款
			ajaxPost( 'changeTOTAL_AMT' , {TOTAL_AMT : $F('TOTAL_AMT').replace(/,/g,''), BARGAIN_AMT : $F('BARGAIN_AMT').replace(/,/g,'')},
				function(resp){	
					$('LATER_AMT').value = CSRUtil.$fmt(resp.LATER_AMT,'#,###') || 0;				  
				}				
			);			
		}		
		,colControl :function(){

			if($F('SPR_TYPE') == '5'){
				$('LATER_AMT').value = '';	
				$('PAY_AMOUNT').value = '';	
				$('PAY_TERM').value = '';	
				$('BEGIN_DATE').value = '';	
				$('LATER_AMT').disable();
				$('PAY_AMOUNT').disable();
				$('PAY_TERM').disable();
				$('BEGIN_DATE').disable();
			}else{
				$('LATER_AMT').disable();
				$('PAY_AMOUNT').enable();
				$('PAY_TERM').enable();
				$('BEGIN_DATE').enable();
			}				
		}	
		,colControl_A :function(){
			//新舊件=請選擇、新件
			if($F('CASE_TYPE') == '' || $F('CASE_TYPE') == '1'){
				$('OLD_REMAIN_AMT').value = '';	
				$('CAL_DATE').value = '';	
				$('OLD_REMAIN_AMT').disable();
				$('CAL_DATE').disable();
			}else{
				$('OLD_REMAIN_AMT').enable();
				$('CAL_DATE').enable();
			}				
		}
		,colControl_B :function(){
			//分期階段=第2、3、4
			if($F('SPR_STEP') == '2' || $F('SPR_STEP') == '3' || $F('SPR_STEP') == '4'){
				$('CASE_TYPE').disable();
				$('OLD_REMAIN_AMT').disable();
				$('CAL_DATE').disable();
				$('BARGAIN_APPR_DATE').disable();
				$('APPLICANT_ID').disable();
				$('BARGAIN_AMT').disable();
				$('LATER_AMT').disable();
				$('TOTAL_AMT').disable();
				$('BARGAIN_COND').disable();		
			}else{
				$('CASE_TYPE').enable();
				$('OLD_REMAIN_AMT').enable();
				$('CAL_DATE').enable();
				$('BARGAIN_APPR_DATE').enable();
				$('APPLICANT_ID').enable();
				$('BARGAIN_AMT').enable();
				$('TOTAL_AMT').enable();
				$('BARGAIN_COND').enable();
				$('LATER_AMT').disable();
			}				
		}				
	};


	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE12100','法務作業','協議清償作業',1);

					grid_B = new TableUI({			
							table: $('grid_B'), pageSize: 20, allSortable: true,	
							<%-- [20240215] 難字調整 --%>
							afterLoad: function() {
								if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240311144850--%>
							},
							pageChange: function() {
								if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240311144850--%>
							},
							column: [
							    {header:"契約狀態", key:'LOAN_STATUS_NM'},	
								{header:'貸款帳號', key:'LOAN_ID',
									render : function(record , value){							
										var link = new Element('a', { 'href' : '#'}).update(value);
										link.observe('click', //監聽click事件
											function( event ) {
												//貸款帳號超連結(B區)
												actions.getDetailList1(value);  
											}
										);							
										return link;
									}			
								}, 													
								{header:"借款人", key:'BORROW_NAME_MASK', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>					
								{header:"保證人", key:'GUARANTOR_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>	
								{header:"拍賣不足本金", key:'SHORT_AMT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},					
								{header:"擔保品地址", key:'GAGE_ADDR_MASK', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header:"備抵呆帳", key:'BAD_ACCOUNT_NM'}									
							]
					});
					grid_C = new TableUI({			
							table: $('grid_C'), pageSize: 20, allSortable: true,
										    	autoCheckBox:{text:'選取',
												type:'radio',
												action: function(elem, status, data){
												            if(status){
															var record = data[0];
															//由C區選取資料之貸款帳號、協議日期取得E區、F區資訊
															actions.getDetailList2(data,record);
															}
														}				   
												},
							<%-- [20240215] 難字調整 --%>
							afterLoad: function() {
								if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240311144850--%>
							},
							pageChange: function() {
								if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240311144850--%>
							},
							column: [
								{header:"序號", key:'SEQ_NO'},													
								{header:"狀態", key:'STATUS_NM'},					
								{header:"協議狀態", key:'BARGAIN_STATUS_NM'},	
								{header:"協議日期", key:'BARGAIN_APPR_DATE',
									render: function(record, value) {
										return value ? Date.toROC(value) : ''; 
									} 
								},	
								{header:"聲請人", key:'APPLICANT_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header:"協議條件", key:'BARGAIN_COND_NM'},								
								{header:"協議總金額", key:'TOTAL_AMT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},					
								{header:"還款方式", key:'SPR_TYPE_NM'},
								{header:"分期階段", key:'SPR_STEP_NM'}								
							]
					});	
					
	
					grid_D = new TableUI({			
							table: $('grid_D'), allSortable: false,
							column: [	
								{header:"項目", key:'ITEM'},
								{header:"結算日", key:'END_DATE',
									render: function(rec, value) {
										if(rec.isRed == 'Y'){
											return "<span class = 'textRed'>"+Date.toROC(value)+"</span>";	
										}else{									
											return value ? Date.toROC(value) : ''; 
										}
									}	
								},														
								{header:"本金", key:'REM_AMT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},
								{header:"利息", key:'REM_INT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},								
								{header:"違約金", key:'REM_RENEGE',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},		
								{header:"費用", key:'REM_FEE',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},
								{header:"累計暫收款", key:'BALC_AMT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								},
								{header:"合計", key:'REM_CREDIT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								}
							]
					});	
					grid_E = new TableUI({			
							table: $('grid_E'), allSortable: false, overDiv:false,	
							column: [	
								{header:"檔名", key:"FILE_NM",
									render:function(rec, val){
										
										if(val){
											var link = new Element('a', {href :'#'});
											link.setAttribute('FILE_ID',rec.FILE_ID);
											link.update(val).observe('click',function(){actions.getDownLoadFile(rec.FILE_ID)});
												return link;
										}else{
											return val;
										}	
									}								
								},														
								{header:"上傳人員", key:"LST_PROC_NAME", attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header:"上傳時間", key:"LST_PROC_DATE"},
								{header:"刪除附件", key:"del_FILE",
									render:function(rec, val){								
										
										var button = new Element( "input", { id:"btn_delete", name:"button", type:"button", value:"刪除"});	
										var span = new Element('span',{ id:"delete_button_span"});										
										button.onclick = function(){
											//需選取C區資料
											var chkData = grid_C.getCheckedRecord();	
											if(chkData.length == 0){
												alert('請先選取協議清償紀錄!');
												return;
											}
										
											if (!confirm("確定要刪除此筆附件資料?")){
												return;
											}
											var reqMap={
												'LOAN_ID': $F('LOAN_ID'),
												'BARGAIN_APPR_DATE': $F('BARGAIN_APPR_DATE'),
												'FILE_ID': rec.FILE_ID,
												'SEQ_NO': rec.SEQ_NO
											}										 
											ajaxPost( 'deleteFile' , {'reqMap':Object.toJSON(reqMap)},
						 
												function(resp){
													grid_E.load(resp.fileList || []);								
												}
											);
										
										};										
										if(legal2 && legal2.length!=0){ 
											for(var j=0 ; j<legal2.length ; j++){
												if(legal2[j]!='B0077'){
												   button.disable();
												}else{
												   button.enable();
												   break;
												}
											}
										}
										/*else{
											button.disable();
										}*/	
										span.insert(button);
										return span;								
								   }
								}
							]
					});
					grid_F = new TableUI({			
							table: $('grid_F'), pageSize: 20, allSortable: true,
								autoCheckBox:{
								text:'選取', 
								type:'checkbox'
							},										  
							column: [	
								{header:'貸款帳號', key:'LOAN_ID'},
								{header:'暫收編號', key:'BALC_NO'},		
								{header:"暫收餘額", key:'REMAIN_AMT',
									render:function(rec ,val){
										return actions.formatAMT(val);										
									}								
								}									
							]
					});
		
			//按鈕事件監聽
		    $('btn_query').observe('click', actions.doQuery);//查詢	
			$('btn_insert').observe('click', actions.doInsert);//新增
			$('btn_update').observe('click', actions.doUpdate);//修改
			$('btn_delete').observe('click', actions.doDelete);//刪除
			$('btn_agree').observe('click', actions.doAgree);//覆核
			$('btn_cancel').observe('click', actions.doCancel);//取消覆核				
			$('btn_repudiate').observe('click', actions.doRepudiate);//毀諾
			$('btn_delay').observe('click', actions.doDelay); //延期繳款	
			$('btn_upload').observe('click', actions.doUpload);//新增檔案	
			$('importFrame').observe('load', actions.importEnd); //匯入結束
			$('btn_confirm').observe('click', actions.doConfirm); //一次協議確認
			$('btn_confirm2').observe('click', actions.doConfirm2); //分期協議確認
			$('btn_print').observe('click', actions.doPrint); //單據列印

			//Input欄位自動轉大寫，如果該欄位有值則清空其他兩個欄位		
			$('REFER_ID').observe('focus',function(){
	
				
				$w('ID NAME').each(
					function(id){
						$(id).value ='';
					}
				);
				
			});
			
			$('ID').observe('focus',function(){
			
				$w('REFER_ID NAME').each(
					function(id){
						$(id).value ='';
					}
				);
			});

			$('NAME').observe('focus',function(){				

				$w('REFER_ID ID').each(
					function(id){
						$(id).value ='';
					}
				);
			});	

			$('ID').observe('change',function(){
				$('ID').value = $F('ID').toUpperCase();
			});
			$('REFER_ID').observe('change',function(){
				$('REFER_ID').value = $F('REFER_ID').toUpperCase();
			});	
			

			$('TOTAL_AMT').observe('blur',function(){				
				actions.changeBAD_AMT();//免除金額 = 對外債權合計-協議總金額
				actions.changeREMAIN_AMT();	//剩餘還款金額 = 協議總金額-累計還款金額
				actions.changeTOTAL_AMT();//分期償還金額(原後續金額) = 協議總金額-頭期款					
			});	
			
			$('BARGAIN_AMT').observe('blur',function(){				
				actions.changeTOTAL_AMT();//分期償還金額(原後續金額) = 協議總金額-頭期款					
			});	
			
			$('OLD_REMAIN_AMT').observe('blur',function(){				
				actions.changeBAD_AMT();//免除金額 = 對外債權合計-協議總金額
				actions.changeREMAIN_AMT();	//剩餘還款金額 = 協議總金額-累計還款金額				
			});	
			
			/*$('PAY_AMT').observe('blur',function(){			
				actions.changeREMAIN_AMT();	//剩餘還款金額 = 協議總金額-累計還款金額				
			});	*/
			
			//if 還款方式 = 一次償還:分期償還金額、分期期數、分期始日disable
			$('SPR_TYPE').observe('change',function(){
				
				actions.colControl();
				
			});	
						
			//if 新舊件 =0舊件:舊件債權總額，債權計算至日期enable
			$('CASE_TYPE').observe('change',function(){
				 
				actions.colControl_A();
				actions.changeBAD_AMT();//免除金額 = 對外債權合計-協議總金額
				actions.changeREMAIN_AMT();	//剩餘還款金額 = 協議總金額-累計還款金額	
								
			});	
			
			//if 分期階段=第2、3、4>>部分欄位需同第1階段
			$('SPR_STEP').observe('change',function(){
				 
				actions.colControl_B();	
				
			});	
			
			//駐點下拉選單連動
			$('BARGAIN_DEPT').observe('change', function(event){
				actions.doChangeList(this.value,''); 
			});
			
			//2017-08-07因為免除保證責任之案件，其協議款均要以追償款入帳，契約效力亦不會變更，免除金額並無意義，故請設計若選擇【免除保證責任】時，「免除金額」欄位則自動帶出「0」，且不能更改。
			$('BARGAIN_COND').observe('change',function(){				 
				actions.changeBAD_AMT();						
			});	

			initValidation();		
			buttonAuth();
			autoFormatToNumber();
			$('btn_upload').disable();//新增檔案初始關閉
			
			PageUI.resize();			
			displayMessage();						
		}//end init()--
	};//end return--	
};//end DSE12100
</script>
</head>
<body>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="10%" align="left" >原貸帳號</td>				
				<td class="tbYellow2" width = "15%">
					<input id="REFER_ID" type="text" class="textBox2" size = "12" maxlength = "10" fieldName = "原貸帳號" value='${REFER_ID}'/>
				</td>
				<td class="tbYellow" width="10%" align="left" >ID</td>			
				<td class="tbYellow2" width = "15%">
					<input id="ID" type="text" class="textBox2" size = "12" maxlength = "10" fieldName = "ID"/>
				</td>
				<td class="tbYellow" width="10%" align="left" >姓名</td>			
				<td class="tbYellow2" width = "15%">
					<input id="NAME" type="text" class="textBox2" size = "12" maxlength = "10" fieldName = "姓名" alt="ch"/> <%-- [20240215]難字調整 --%>
				</td>	
				<td class="tbYellow2" width="25%" "center">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"   />	
				</td>
			</tr>	
			<tr>
				<td colspan = "7" align = "center">			
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />
					<input id = "btn_update" type = "button" class = "button" value = "修改"   />
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"  />					
					<input id = "btn_agree" type = "button" class = "button" value = "覆核"  />						
					<input id = "btn_cancel" type = "button" class = "button" value = "取消覆核"   />	
					<input id = "btn_repudiate" type = "button" class = "button" value = "毀諾"   />	
					<input id = "btn_delay" type = "button" class = "button" value = "延期繳款"   />	
					<input id = "btn_confirm" type = "button" class = "button" value = "一次協議確認"   />	
					<input id = "btn_confirm2" type = "button" class = "button" value = "分期協議確認"   />	
					<input id = "btn_print" type = "button" class = "button" value = "單據列印"   />						
				</td>
			</tr>
		</table>	     
	<form id="form1" method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSE1_2100/upload" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "grid_B" ></table>
		<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>				
				<td class="tbYellow0"  align="center" colSpan="4">					
					<span style="font-weight: bold;">協議清償進度</span>				
				</td>
			</tr>
		</table>	
		<table id = "grid_C" ></table>
		<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"  align="center" colSpan="4">					
					<span style="font-weight: bold;">債權試算結果</span>				
				</td>
			</tr>
			<tr>	
				<td class="tbYellow" width="10%" align="left" >貸款帳號</td>			
				<td class="tbYellow2" width = "15%">
					<span id="B_LOAN_ID"></span>
				</td>							
				<td class="tbYellow2" width="75%">	
					<span id="FILE_ID"></span>
				</td>
			</tr>
		</table>
		<table id = "grid_D" ></table>
		<table id="table_E" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>				
				<td class="tbYellow0"  align="center" colSpan="8">					
					<span style="font-weight: bold;">協議清償條件</span>				
				</td>
			</tr>
			<tr>
			<td class="tbYellow" width="10%">新舊件</td>
			<td class="tbYellow2" width="15%">
                    <select id="CASE_TYPE" class="textBox2 validate-selection" fieldName="新舊件">
						<option value="">請選擇</option>
                        <c:forEach items="${CASE_TYPE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
			<td class="tbYellow" width="10%">舊件債權總額</td>
			<td class="tbYellow2" >
					<input id="OLD_REMAIN_AMT" type="text" class="textBox2" size = "12" maxlength = "10" dataType ="number" fieldName = "舊件債權總額"/>
				</td>
			<td class="tbYellow" width="10%">舊件債權計算至</td>		
				<td class="tbYellow2" width="15%">
					<input id="CAL_DATE" name ="CAL_DATE" datatype ="ROCDate" type='text' fieldName="舊件債權計算至" class= "textBox2" size='9' maxlength='7'  /> 
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('CAL_DATE'))"><br><font color=red>舊件請上傳舊系統試算畫面</font>
				</td> 
			<td class="tbYellow" width="10%">放款加權平均利率<br>債權受償率(%)</td>
			<td class="tbYellow2" >
					<input id="RATE" type="text" class="textBox2 validate-number" size = "8" maxlength = "6" dataType ="number" fieldName = "放款加權平均利率債權受償率"/>
			</td>				
			</tr>
			<tr>
				<input id="END_DATE"   type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "結算日期"/>
				<input id="LOAN_ID" name ="LOAN_ID" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "貸款帳號"/>
				<input id="OLD_BARGAIN_APPR_DATE" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "協議日期"/>
				<input id="SEQ_NO" name ="SEQ_NO" type='hidden' class= 'textBox2'  size='12' maxlength='10' fieldName = "序號"/>
				
				<td class="tbYellow" width="10%">協議日期</td>		
				<td class="tbYellow2" width="15%" >
					<input id="BARGAIN_APPR_DATE" name ="BARGAIN_APPR_DATE" datatype ="ROCDate" type='text' fieldName="協議日期" class= "textBox2 required validate-ROCDate" size='9' maxlength='7'  /> 
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('BARGAIN_APPR_DATE'))">
				</td>
				<td class="tbYellow" width="10%">聲請人</td>
                <td class="tbYellow2" width="15%">
                    <select id="APPLICANT_ID" class="textBox2 validate-selection" fieldName="聲請人" alt="ch"> <%-- [20240215]難字調整 --%>                       
						<option value="">請選擇</option>                          
                    </select>
                </td>
				<td class="tbYellow" width="10%">協議條件</td>
                <td class="tbYellow2" width="15%">
                    <select id="BARGAIN_COND" class="textBox2 validate-selection" fieldName="協議條件">
						<option value="">請選擇</option>
                        <c:forEach items="${BARGAIN_COND_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
				<td class="tbYellow" width="10%">還款方式</td>
                <td class="tbYellow2" width="15%">
                    <select id="SPR_TYPE" class="textBox2 validate-selection" fieldName="還款方式">
						<option value="">請選擇</option>
                        <c:forEach items="${SPR_TYPE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >協議總金額</td>				
				<td class="tbYellow2">
					<input id="TOTAL_AMT" type="text" class="textBox2 required" size = "12" maxlength = "10" dataType ="number" fieldName = "協議總金額"/>
				</td>
				<td class="tbYellow" align="left" >免除金額<br>(原呆帳金額)</td>				
				<td class="tbYellow2" >
					<span id="BAD_AMT"></span>
				</td>		
				<td class="tbYellow"  align="left" >頭期款<br>(原協議金額)</td>				
				<td class="tbYellow2" >
					<input id="BARGAIN_AMT" type="text" class="textBox2 required"  size = "12" maxlength = "10"  dataType ="number" fieldName = "頭期款(原協議金額)"/>
				</td>				
				<td class="tbYellow"  align="left" >分期償還金額<br>(原後續金額)</td>				
				<td class="tbYellow2" >
					<input id="LATER_AMT" type="text" class="textBox2" size = "12" maxlength = "10" dataType ="number" fieldName = "分期償還金額(原後續金額)"/>
				</td>
			</tr>
			<tr>
			<td class="tbYellow" width="10%">分期階段</td>
                <td class="tbYellow2" width="15%">
                    <select id="SPR_STEP" class="textBox2 validate-selection" fieldName="分期階段">
                        <c:forEach items="${SPR_STEP_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
				<td class="tbYellow" align="left" >分期期數</td>				
				<td class="tbYellow2">
					<input id="PAY_TERM" type="text" class="textBox2" size = "12" maxlength = "10" dataType="number" fieldName = "分期期數"/>
				</td>
				<td class="tbYellow">分期始日</td>		
				<td class="tbYellow2" >
					<input id="BEGIN_DATE" datatype ="ROCDate" type='text' fieldName="分期始日" class= "textBox2" size='9' maxlength='7'  /> 
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('BEGIN_DATE'))">
				</td>
				<td class="tbYellow"  align="left" >分期金額</td>				
				<td class="tbYellow2" >
					<input id="PAY_AMOUNT" type="text" class="textBox2" size = "12" maxlength = "10" dataType ="number" fieldName = "分期金額"/>
				</td>					
				
			</tr>
			<tr>	
				<td class="tbYellow" align="left" >分期應繳金額</td>	
				<td class="tbYellow2">
					<span id="DUTY_PAY_AMT"> </span>
				</td>
				<td class="tbYellow" align="left" >剩餘還款金額<br>(原後續餘額)</td>	
				<td class="tbYellow2">
					<span id="REMAIN_AMT"> </span>
				</td>
				<td class="tbYellow" align="left" >累計還款金額</td>				
				<td class="tbYellow2">
					<span id="PAY_AMT" /> </span>
				</td>	
				<td class="tbYellow" align="left" >協議總金額(歸戶)</td>				
				<td class="tbYellow2" colSpan ="3">
					<!-- <input id="ALL_AMT" type="text" class="textBox2"  size = "12" maxlength = "10" dataType ="number" fieldName = "協議總金額(歸戶)"/> -->
					<span id="ALL_AMT" /> </span>
				</td>
			</tr>	
			<tr>
			<td class="tbYellow">駐點</td>
				<td class="tbYellow2">								
					<select name="BARGAIN_DEPT" id="BARGAIN_DEPT" class="textBox2" fieldName = "駐點">
					<option value="">請選擇</option>
						<c:forEach items="${CRED_DEPT_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow">協議法務</td>
				<td class="tbYellow2" >					
					<select name="BARGAIN_ID" id="BARGAIN_ID" class="textBox2" fieldName = "承辦法務"  alt="ch"> <%-- [20240215]難字調整 --%>
					<option value="">請選擇</option>
						<c:forEach items="${BARGAIN_ID_LIST}" var="map">
							<option value="${map.ID}">${map.NAME}</option>
						</c:forEach>
					</select>	<span id="BARGAIN_NAME"></span>				
				</td>	
				<td class="tbYellow" width="10%" align="left" >協議原因</td>			
				<td class="tbYellow2" colSpan ="3">
                    <select id="BARGAIN_REASON_CODE" class="textBox2 validate-selection required" fieldName="協議原因">
						<option value="">請選擇</option>
                        <c:forEach items="${BARGAIN_REASON_CODE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>				
					<input id="BARGAIN_REASON" type="text" class="textBox2" size = "70" maxlength = "70" fieldName = "協議原因"/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align="left" >輸入人員</td>				
				<td class="tbYellow2">
					<span id="INPUT_NAME" style="font-family:'EUDC'"></span><%--[20240215]難字調整 --%>
				</td>
				<td class="tbYellow" align="left" >輸入日期</td>				
				<td class="tbYellow2" >
					<span id="INPUT_DATE"></span>
				</td>		
				<td class="tbYellow"  align="left" >覆核人員</td>				
				<td class="tbYellow2" >
					<span id="CONFIRM_NAME" style="font-family:'EUDC'"></span><%--[20240215]難字調整 --%>
				</td>				
				<td class="tbYellow"  align="left" >覆核日期</td>				
				<td class="tbYellow2" >
					<span id="CONFIRM_DATE"></span>
				</td>
			</tr>
			<tr>
			<td class="tbYellow" align="left" >序號</td>				
				<td class="tbYellow2">
					<span id="SEQ_NO_E" /> </span>
				</td>
				<td class="tbYellow" width="10%" align="left" >單據序號</td>			
				<td class="tbYellow2" >
					<input id="RECEIPT_SERNO" type="text" class="textBox2" size = "11" maxlength = "10" fieldName = "單據序號"/>
				</td>
				<td class="tbYellow" align="left" >延期繳款</td>				
				<td class="tbYellow2" colspan="3" >
					增加<input id="DELAY_ADD" type="text" class="textBox2" size = "4" maxlength = "3" dataType="number" fieldName = "增加延期繳款期數"/>期/
					減少<input id="DELAY_SUB" type="text" class="textBox2" size = "4" maxlength = "3" dataType="number" fieldName = "減少延期繳款期數"/>期
					累計延期繳款<font color=red><span id="DELAY"></span></font>期
				</td>
			</tr>	
		</table>
		<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">上傳附件</td>					
				<td class="tbYellow2" width="90%">
						<span id="import">
							<input id="import_file" name="import_file" type="file" size="49" class="button" value="瀏覽" />
						</span>
						<input id = "btn_upload" type = "button" class = "button" value = "新增檔案"  />
						<table id = "grid_E" ></table>
				</td>					
			</tr>	
		</table>
		<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>				
				<td class="tbYellow0"  align="center" colSpan="4">					
					<span style="font-weight: bold;">人工暫收</span>				
				</td>
			</tr>
		</table>	
		<table id = "grid_F" ></table>
	</form>	
	<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>