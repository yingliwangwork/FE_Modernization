<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSD10410.jsp
作者：吳學建
功能：催收簡訊發送
完成：
[20200914]修改件
放款簡訊發送平台增加簡訊項目:
    1. 新增檢核，行動電話部分，行動電話與原貸款帳號行動電話不同時，提出提示。
    2. 將簡訊改成長簡訊模式發送，不需再判別70字。
    3. 書入內容由136字放寬為330字
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>         <%-- 判斷BUTTON用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/InputUtility.js"></script>   <%-- 檢核用 --%>

<script type="text/JavaScript">

// 產生畫面物件
var DSD10410 = new DSD10410();

Event.observe(window, 'load', DSD10410.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD10410(){
	
	var valid1;
	var grid1;
	var ori_MOBILE = '${MOBILE}'; //[20200914]原貸款帳號行動電話
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPost( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSD1_0410/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
	
	var button = {
		//發送
		doSend: function(){
		
			
			// 清空檢核
			valid1.reset();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!valid1.validate()){ 
				return; 
			}
			
			var MSG_CONTENT = $F('MSG_CONTENT');
			
			if(MSG_CONTENT.length == 0){
				alert("請輸入簡訊內容");
				return;								
			}
			//[20200914]最多可容納330個字
			if(MSG_CONTENT.length > 330){
				alert("簡訊字數不能大於330個字");
				return;
			}						
			
			if($F('MOBILE').length != 10 ){
				alert("行動電話長度為10碼!");
				return;
			}
			
			//行動電話每一碼都必須是數字格式
			var mobile = $F('MOBILE');
			for(var i=0; i<mobile.length; i++){				
				if(!JsUtils.isNumeric(mobile.substring(i,i+1))){
					alert("行動電話號碼的格式應為數字!");
					return;
				}	
			}
			if(MSG_CONTENT.indexOf('▲')!=-1){
				alert('訊息內容尚有資料未輸入，請將資料內容填入▲進行取代。');
				return;
			}
			//[20200914]行動電話與原貸款帳號行動電話不同時，提出提示
			if(ori_MOBILE!=mobile){
				alert("行動電話與原貸款帳號行動電話不同，請確認。謝謝!");
			}
			//[20200914]改為長簡訊，無需再作超過70個字判斷
			if(!confirm('確定要發送簡訊嗎？')){
				return;
			}
			
			ajaxPost( 'send' ,  {LOAN_ID: $F('LOAN_ID'),MOBILE: $F('MOBILE'),MSG_TYPE: $F('MSG_TYPE'),MSG_CONTENT: MSG_CONTENT,FUNC_ID : '${FUNC_ID}',INPUT_TYPE : '${INPUT_TYPE}'}, 
				function(resp){	
					//傳送簡訊後，簡訊種類set=請選擇，強迫重新選擇簡訊種類帶入簡訊內容，以免user接著要傳給別的貸款帳號時把上一個貸款帳號的訊息傳給下一個貸款帳號
					$('MSG_TYPE').setValue('');
				},	
				function(resp){	
					//傳送發生錯誤，簡訊種類set=請選擇，強迫重新選擇簡訊種類帶入簡訊內容
					//以免user接著要傳給別的貸款帳號時把上一個貸款帳號的訊息傳給下一個貸款帳號
					$('MSG_TYPE').setValue('');
				}			
			);
		} ,
		
		doGetMobile: function(){
			// 清空檢核
			valid1.reset();
			// 檢核觸動：所有檢核設定要在觸動前完成
			//if(!valid1.validate()){ 
			//	return; 
			//}
			$('MOBILE').setValue('');
			ajaxPost( 'getMobile' ,  { LOAN_ID: $F('LOAN_ID'), MSG_TYPE: $F('MSG_TYPE'), FUNC_ID : '${FUNC_ID}' }, 
				function(resp){					
					$('MOBILE').setValue(resp.MOBILE);
					ori_MOBILE = resp.MOBILE; //[20200914] 貸款帳號預帶的行動電話
					//20210126 為避免重新輸入貸款帳號卻沒更新簡訊內容，所以如果更改貸款帳號時有選釋簡訊種類的話也一併連動簡訊內容
					if($F('MSG_TYPE')){
						button.getMsgContent(event);
					}
				},	
				function(resp){	
					//傳送發生錯誤，簡訊種類set=請選擇，強迫重新選擇簡訊種類帶入簡訊內容
					//以免user接著要傳給別的貸款帳號時把上一個貸款帳號的訊息傳給下一個貸款帳號
					$('MSG_TYPE').setValue('');
				}				
			);
		},
		
		getMsgContent: function(){
		
			$('MSG_CONTENT').setValue('');
		
			// 清空檢核			
			valid1.reset();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!valid1.validate()){ 
				return; 
			}
			

			
			var vMSG_TYPE = $('MSG_TYPE').value;
			if(vMSG_TYPE == 'D002' && '${FUNC_ID}' != 'DSD10201'){
				$('MSG_CONTENT').readOnly = false; 
				return; 
			}
			ajaxPost( 'getMsgContent' ,  {LOAN_ID: $F('LOAN_ID'), MSG_TYPE : vMSG_TYPE}, 
                 function(resp){      
                 	//190909 自動化導入bug處理:原寫法chrome執行會有問題,改用setValue               
                    $('MSG_CONTENT').setValue(resp.MSG_CONTENT || '');  
					$('MSG_CONTENT').simulate('blur');
					//202210126 申請書210119000837 房貸「催繳函及簡訊通知文字優化」：開放「關懷型」、「加強提醒型」可以自行調整簡訊內容
					if(vMSG_TYPE == 'D003'){
						$('MSG_CONTENT').readOnly = true;
					} else {
						$('MSG_CONTENT').readOnly = false;
					}
                 },  
                 function(resp){ 
                    //傳送發生錯誤，簡訊種類set=請選擇，強迫重新選擇簡訊種類帶入簡訊內容
                    //以免user接著要傳給別的貸款帳號時把上一個貸款帳號的訊息傳給下一個貸款帳號
                    $('MSG_TYPE').setValue('');
                    $('MSG_CONTENT').readOnly = true;
                 }               
             );
			
		}
		
		//回上一頁
		/*
		doBack: function(event){
		   if(window['callbackHandler']){
				callbackHandler();
				close();
			}else if(parent && parent.popupWin ){ 
				if(parent.popupWin.callbackHandler){
					parent.popupWin.callbackHandler();
				}
				close();
			}else{
				CSRUtil.linkBack(CSRUtil.getLP_JSON().RQ_SENDER +'?STAT_DATE='+toY2K('${STAT_DATE}')
				+'&DIV_NO='+'${DIV_NO}'
				+'&DIV_NM='+'${DIV_NM}'
				+'&CHECK_TYPE='+'${CHECK_TYPE}'
				);	
			}	
		}
		*/	
		
	};
	
	//畫面檢核
	
	function initValidation(){
			valid1 = new Validation('form1',{ mode:'validator' });
			valid1.define( 'required' , [{ id : 'LOAN_ID' , errMsg : '請輸入貸款帳號'} ] );	
			valid1.define( 'required' , [{ id : 'MOBILE' , errMsg : '請輸入行動電話'} ] );	
			valid1.define( 'required' , [{ id : 'MSG_TYPE' , errMsg : '請選擇簡訊種類'} ] );			
		}

	return {
		initApp : function() {
			var noPageFrame = '${FUNC_ID}' == 'DSD11800' ?  true : false;			
			PageUI.createPageWithAllBodySubElement( "DSD10410" , "簡訊發送", "簡訊發送作業", 0, noPageFrame);
			
			// 檢核初始化
			initValidation();	
			
			if('${FUNC_ID}' == 'DSD10201' && !$('MOBILE').value) {
				button.doGetMobile();
			}		
			
			// 發送
			$("btn_send").observe('click', button.doSend );	
			
			//回上一頁
			//$("btn_back").observe('click', button.doBack);	
			// 查詢電話
			$("LOAN_ID").observe('change', button.doGetMobile);
			
			// 查詢簡訊內容
			$("MSG_TYPE").observe('change', button.getMsgContent);
			//[20200914]最多可容納330個字
			InputUtility.lengthLimit.add('MSG_CONTENT', 330, false);

			PageUI.resize();
			displayMessage();
			//$('MOBILE').disabled = true;
		} // end initApp()--
		
	}// end return--
}// end DDA02600

</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="12%">貸款帳號</td>		
			<td class="tbYellow2" width="20%" >
			    <input type="text" class="textBox" id="LOAN_ID" name="LOAN_ID" size="12" maxlength="11" class="required" value = "${LOAN_ID}">
			</td>			
			<td class="tbYellow" width="12%" >行動電話</td>
			<td class="tbYellow2" width="20%">
			    
			    <input  name="MOBILE" id="MOBILE" value="${MOBILE}">
				  
			</td>			
			<td class="tbYellow" width="12%">簡訊種類</td>		
			<td class="tbYellow2" width="24%">
				<select id="MSG_TYPE"  fieldName="格式代號">
				     <option value=''>請選擇</option>
			       	<c:forEach var="map" items="${MSG_TYPE_LIST}">
						<option value='${map.key}'>${map.value}</option>
			       	</c:forEach>
				</select>   
				<input type="button" class="button" value="發送" id="btn_send" />     
				<!-- <input type="button" class="button" value="回上一頁" id="btn_back" />     --> 
			</td>	
		</tr>		
		
		
		
	</table>
	<table  width="100%">
		<tr>
			<td class="tbYellow2"  height="100">
					<textarea name="MSG_CONTENT" id="MSG_CONTENT"  cols="80" rows="10" maxLength="280"  class="textBox2 "></textarea>
			</td>		
		</tr>	
	
	</table>
	
	</form>
</body>
</html>