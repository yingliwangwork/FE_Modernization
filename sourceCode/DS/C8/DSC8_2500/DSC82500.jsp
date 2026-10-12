<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式:DSC82500.jsp
作者:陳思涵
功能:火險經手人變更
完成:2013-08-05

[20230321] 修改程式  楊青峰
難字調整
  -->
  
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<%-- [20230321] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<title></title>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>       <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>   <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>   <!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript">

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC82500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function DSC82500(){

var valid1;
var valid2;
var updateRecord;

	//畫面檢核
	function  initValidation(){
		Validation.addAllThese([
			['validLOAN_ID', '貸款帳號格式有誤', function(v , node) { 
				if(v){
					<%--貸款帳號10碼英數字--%>
					return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
				}
				return true;
			}]
		]);
	     valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		 valid1.define("required", { id: "LOAN_ID" , errMsg:"請輸入貸款帳號，謝謝!!" } );
		 valid1.define("validLOAN_ID", { id: "LOAN_ID"  } );
		
		 valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});		 		 
		 valid2.define("checkROCID",{ id: "FIRE_AGENT_ID" , errMsg:"新經手人身份證ID有誤，請檢查後重新輸入！" });
		 
		

	}

	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_2500/" + actionName,
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
	}//END   共用AJAX
	

	//button對應的event function
	var buttons = {
		doQuery : function(event){
		
			valid2.reset();

			if(!valid1.validate()){
			return;			
		    }
			
			
			var LOAN_ID_length = $F('LOAN_ID').length;
			if(LOAN_ID_length!=10){
				alert("請輸入正確貸款帳號!");
				return;
			}
			
			ajaxPost('query' , {'LOAN_ID' : $F('LOAN_ID')},
				function(resp){
					//查詢成功
					
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					
					$('REFER_ID').update(rtnMap.REFER_ID || '');
					$('APPLY_ID').update(rtnMap.APPLY_ID || '');
					$('BORROW_ID').update(rtnMap.BORROW_ID || '');
					$('BORROW_NAME').update(rtnMap.BORROW_NAME || '');
					$('OLD_FIRE_AGENT_ID').update(rtnMap.OLD_FIRE_AGENT_ID || '');
					$('OLD_FIRE_AGENT_NM').update(rtnMap.OLD_FIRE_AGENT_NM || '');
					$('OLD_FIRE_AGENT_DEPTNM').update(rtnMap.OLD_FIRE_AGENT_DEPTNM || '');
					
					
					
					$$('#table2 input[type=text]').each(
						function(ele){
							
							ele.value = rtnMap[ele.id] || '';
						}
					);
					
					$w('OLD_FIRE_AGENT_DEPT SEQ_NO VALID').each(
						function(id){
							$(id).value = rtnMap[id] || '';
						}
					);
					 
					
					if(rtnMap.CHG_REASON==='0'){
						$('CHG_REASON_1').checked = true;
					}else if(rtnMap.CHG_REASON==='1'){
						$('CHG_REASON_2').checked = true;
					}else{
						$('CHG_REASON_1').checked = false;
						$('CHG_REASON_2').checked = false;
					}
					
 					updateRecord = {LOAN_ID:$F('LOAN_ID'),REFER_ID:rtnMap.REFER_ID,BORROW_ID:rtnMap.BORROW_ID,BORROW_NAME:rtnMap.BORROW_NAME,
 					OLD_FIRE_AGENT_ID:rtnMap.OLD_FIRE_AGENT_ID,OLD_FIRE_AGENT_NM:rtnMap.OLD_FIRE_AGENT_NM,OLD_FIRE_AGENT_DEPTNM:rtnMap.OLD_FIRE_AGENT_DEPTNM,
 					OLD_FIRE_AGENT_DEPT:rtnMap.OLD_FIRE_AGENT_DEPT}; 
				},
				function(){
					$('REFER_ID').update('');
					$('APPLY_ID').update('');
					$('BORROW_ID').update('');
					$('BORROW_NAME').update('');
					$('OLD_FIRE_AGENT_ID').update('');
					$('OLD_FIRE_AGENT_NM').update('');
					$('OLD_FIRE_AGENT_DEPTNM').update('');
					
					$$('#table2 input[type=text]').each(
						function(ele){							
							ele.value = '';
						}
					);
					
					$w('OLD_FIRE_AGENT_DEPT SEQ_NO VALID').each(
						function(id){
							$(id).value = '';
						}
					);
					
					$('CHG_REASON_1').checked = false;
					$('CHG_REASON_2').checked = false;
					
 					updateRecord = {}; 
				
				}
			);
			
		},
		doUpdate : function(event){
		
			valid1.reset();
			
			
			if(!updateRecord ){
				alert("請先查詢再做變更！");
				return ;
			}
			
			var LOAN_ID_OLD = updateRecord.LOAN_ID || '';
			
			if(LOAN_ID_OLD != $F('LOAN_ID')){
				alert("欲變更的帳號("+$F('LOAN_ID')+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!");
				return ;
			}
		    
		    if(!valid2.validate()){
					return;			
			}
		    var CHG_REASON;
		  	if($('CHG_REASON_1').checked){
		    	CHG_REASON = "0";
		    }else if($('CHG_REASON_2').checked){
		    	CHG_REASON = "1";
		    }else{
		    	alert("請輸入新經手人變更原因!!");
		    	return;
		    }
		    
		    var reqMap = {
		    	 LOAN_ID:$F('LOAN_ID'),
				 REFER_ID:updateRecord.REFER_ID,
				 BORROW_ID:updateRecord.BORROW_ID,
				 OLD_FIRE_AGENT_ID:updateRecord.OLD_FIRE_AGENT_ID,
				 FIRE_AGENT_ID:$F('FIRE_AGENT_ID'),
				 CHG_REASON:CHG_REASON,
				 OLD_FIRE_AGENT_DEPT:updateRecord.OLD_FIRE_AGENT_DEPT,
				 SEQ_NO:$F('SEQ_NO'),
				 VALID:$F('VALID')
		    };
		    
		    ajaxPost( 'update' , {'reqMap':Object.toJSON(reqMap)},
		    	function(resp){
		    		var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					
					$('REFER_ID').update(rtnMap.REFER_ID || '');
					$('APPLY_ID').update(rtnMap.APPLY_ID || '');
					$('BORROW_ID').update(rtnMap.BORROW_ID || '');
					$('BORROW_NAME').update(rtnMap.BORROW_NAME || '');
					$('OLD_FIRE_AGENT_ID').update(rtnMap.OLD_FIRE_AGENT_ID || '');
					$('OLD_FIRE_AGENT_NM').update(rtnMap.OLD_FIRE_AGENT_NM || '');
					$('OLD_FIRE_AGENT_DEPTNM').update(rtnMap.OLD_FIRE_AGENT_DEPTNM || '');


					$$('#table2 input[type=text]').each(
						function(ele){
							
							ele.value = rtnMap[ele.id] || '';
						}
					);
					"OLD_FIRE_AGENT_NM"
					$w('OLD_FIRE_AGENT_DEPT SEQ_NO VALID').each(
						function(id){
							$(id).value = rtnMap[id] || '';
						}
					);
					 
					
					if(rtnMap.CHG_REASON==='0'){
						$('CHG_REASON_1').checked = true;
					}else if(rtnMap.CHG_REASON==='1'){
						$('CHG_REASON_2').checked = true;
					}else{
						$('CHG_REASON_1').checked = false;
						$('CHG_REASON_2').checked = false;
					}
		    	}
		    	
		    );
		    
		    
		    
		}
	};

	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC82500', '變更作業', '火險經手人變更');
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_update').observe('click', buttons.doUpdate);

			PageUI.resize();
			initValidation();
			displayMessage();
			
		}
	};


}
</script>
</head>
<body>

<form name="form" id="from" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" action="">
	
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2"  width="70%">
				<input id="LOAN_ID" type="text" class="textBox2" size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()" />
			</td>
			<td class="tbYellow2" width="20%">
				<input id="btn_query" type="button" class="button" value="查詢"/>
				<input id="btn_update" type="button" class="button" value="變更"/>	
			</td>
		</tr>
	</table>
		
	<table id='table2' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">歸戶帳號</td>
			<td class="tbYellow2" width="20%" >
				<span id="REFER_ID"></span>
			</td>
			<td class="tbYellow" width="15%">受理編號</td>
			<td	class="tbYellow2" width="20%" >
				<span id="APPLY_ID"></span>
			</td>
			<td class="tbYellow" width="15%">
				<input id="OLD_FIRE_AGENT_DEPT" type="hidden" />
			</td>
			<td class="tbYellow2" width="20%">
				<input id="SEQ_NO" type="hidden" >
			</td>
		</tr>
		<tr>
			<td class="tbYellow">借款人ID</td>
			<td class="tbYellow2">
			<span id="BORROW_ID"></span>
			</td>
			<td class="tbYellow">借款人姓名</td>
			<td class="tbYellow2">
			<span id="BORROW_NAME" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
			</td>
			<td class="tbYellow">
				<input id="VALID" type="hidden" >
			</td>
			<td class="tbYellow2">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">舊經手人ID</td>
			<td class="tbYellow2">
			<span id="OLD_FIRE_AGENT_ID"></span>
			</td>
			<td class="tbYellow">舊經手人姓名</td>
			<td class="tbYellow2">
			<span id="OLD_FIRE_AGENT_NM" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
			</td>
			<td class="tbYellow">舊經手人單位</td>
			<td class="tbYellow2">
			<span id="OLD_FIRE_AGENT_DEPTNM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">新經手人ID</td>
			<td class="tbYellow2">
				<input id="FIRE_AGENT_ID" type="text" class = "textBox2"  size='12' maxlength='10' onblur="this.value = this.value.toUpperCase()"/>
			</td>
			<td class="tbYellow">變更原因</td>
			<td class="tbYellow2"  colspan="3">
				<input name="CHG_REASON" id="CHG_REASON_1" type="radio" value="0"/>1.原經手人已離職，原單位主管同意轉出
				<input name="CHG_REASON" id="CHG_REASON_2" type="radio" value="1"/>2.原經手人切結同意轉出
			</td>
		</tr>
	</table>
</form>

</body>
</html>