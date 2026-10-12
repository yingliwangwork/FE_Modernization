<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC81800.jsp
作者：張憶如 
功能：保戶優惠變更
完成：2013/9/18

[20230321]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>		    <%-- 日期用 --%>

<%-- [20230321] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC81800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC81800(){
	
	var grid;
	var valid1;
	
	//畫面檢核
	function initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	
	}
	
	function validDefine1(){
		valid1.reset();
		valid1.clear();
		valid1.define('required' , [{ id : "LOAN_ID_Q" , errMsg:'請輸入貸款帳號'}]);	
	}
	function validDefine2(){
		valid1.reset();
		valid1.clear();
		valid1.define('required' , [{ id : "NEW_INSU_PRANK" , errMsg:'請輸入新保優等級'}]);
		valid1.define('validate-number' , [{ id : "NEW_INSU_PRANK" , errMsg:'新保優等級須為數字'}]);
		valid1.define('required' , [{ id : "NEW_BEGIN_YM" , errMsg:'請輸入新優惠年月'}]);
		valid1.define('validate-ROCDateYM' , [{ id : "NEW_BEGIN_YM" , errMsg:'請輸入年月正確格式'}]);
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1800/" + actionName,
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
	
	var actions = {		
		//初始查詢		
		doQuery : function(){
			//檢核欄位
			validDefine1();
			if(!valid1.validate()){					
				return;			
			}
			//發送ajax
			ajaxPost( 'query', {LOAN_ID_Q: $F('LOAN_ID_Q')},
				function(resp){	
					var rtnMap = resp.rtnMap || {};
					$$('#table_A input').each(function(ele){
						if(rtnMap[ele.id] === 0){
							ele.value = 0;
						}else{
							ele.value=rtnMap[ele.id]||'';
						}
					})
					
					$$('#table_A span').each(function(ele){
						ele.update(rtnMap[ele.id]||'');
					})
					//$('LOAN_STATUS_NM').update(rtnMap['LOAN_STATUS_NM']||'');
					$('btn_update').enable();
				},
				function(resp){
					$$('#table_A input').each(function(ele){
						ele.value = '';
					})
					$$('#table_A span').each(function(ele){
						ele.update();
					})
					//$('LOAN_STATUS_NM').update();
					$('btn_update').disable();
				}
			);				
		},
		doUpdate : function(){
			//檢核欄位
			validDefine2();
			if(!valid1.validate()){					
				return;			
			}
			//確認是否執行變更
			if(!confirm('確定要變更'+$F('LOAN_ID_Q')+'此貸款帳號之保戶優惠？')){
				return;
			}
			
			<%--
			[20230321] DATA_MAP 移除 BORROW_NAME
			BORROW_NAME後端未使用 且 傳入含有難字時會發生「AntiXSSRequestData$InputXSSError輸入值格式有安全性的錯誤」
			--%>
			var DATA_MAP = {
				OLD_INSU_PRANK : $F('OLD_INSU_PRANK'),
				OLD_BEGIN_DATE : $F('OLD_BEGIN_DATE'),
				LOAN_STATUS : $('LOAN_STATUS').innerHTML,
				OLD_END_DATE : $F('OLD_END_DATE'),
				NEW_INSU_PRANK : $F('NEW_INSU_PRANK'),
				NEW_BEGIN_YM : $F('NEW_BEGIN_YM'),
				LOAN_ID : $F('LOAN_ID'),
				LOAN_ID_Q : $F('LOAN_ID_Q'),
				INPUT_DEPT : $F('INPUT_DEPT'),
				INPUT_ID : $F('INPUT_ID')
			};
			//發送ajax
			ajaxPost( 'update', {DATA_MAP : Object.toJSON(DATA_MAP)});				
		}
	};
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC81800" , "變更作業", "保戶優惠變更" );
			initValidation(); //檢核欄位
			//按鈕動作
			// 查詢
			$('btn_query').observe('click', actions.doQuery);
			//變更
			$('btn_update').observe('click', actions.doUpdate);
			//轉大寫
			var LOAN_ID_Q = $('LOAN_ID_Q');
			LOAN_ID_Q.observe('blur', function(event){
				LOAN_ID_Q.value = LOAN_ID_Q.value.toUpperCase();
			});
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC81800
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="20%">貸款帳號</td>
				<td class="tbYellow2" width="50%">
					<input id="LOAN_ID_Q" class="textBox2" size="12" maxlength="11">
				</td>
				<td class="tbYellow2" width="30%">
					<input id="btn_query" class="button" type="button" value="查詢">
					<input id="btn_update" class="button" type="button" value="變更" disabled>
				</td>
			</tr>
		</table>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>	
				<td class="tbYellow" width="20%">借款人</td>			
				<td class="tbYellow2" width="30%">
					<%-- [20230321] 難字調整 --%>
					<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow" width="20%">契約狀態</td>			
				<td class="tbYellow2" width="30%">
					<span id="LOAN_STATUS_NM"></span>
				</td>
			</tr>
			<tr>	
				<td class="tbYellow">保優等級</td>			
				<td class="tbYellow2">
					<input id="OLD_INSU_PRANK" type="text" class="textBox2" size="12" disabled/>
				</td>
				<td class="tbYellow">優惠起日</td>			
				<td class="tbYellow2">
					<input id="OLD_BEGIN_DATE" type="text" class="textBox2" size="12" disabled/>~
					<input id="OLD_END_DATE" type="text" class="textBox2" size="12" disabled/>
				</td>
			</tr>
			<tr>	
				<td class="tbBox3" colspan="4" align="center">保戶優惠變更</td>	
			</tr>
			<tr>	
				<td class="tbYellow" width="20%">新保優等級</td>			
				<td class="tbYellow2" width="20%">
					<input id="NEW_INSU_PRANK" type="text" class="textBox2" size="12" />
				</td>
				<td class="tbYellow" width="20%">新優惠年月</td>			
				<td class="tbYellow2" width="20%">
					<input id="NEW_BEGIN_YM" type="text" class="textBox2" size="12" maxlength='5'>
				</td>				
			</tr>
			<input id="LOAN_STATUS" type="hidden"/>
			<input id="LOAN_ID" type="hidden"/>
			<input id="INPUT_DEPT" type="hidden"/>
			<input id="INPUT_ID" type="hidden"/>
		</table>
	</form>
</body>
</html>