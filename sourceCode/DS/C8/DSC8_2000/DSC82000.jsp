<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式:DSC82000.jsp
作者:陳思涵
功能:平轉-年資優惠
完成:2013-08-08

[20230321] 修改程式  楊青峰
難字調整
  -->
  
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ page language='java' contentType='text/html; charset=BIG5'%>
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
Event.observe(window, 'load', new DSC82000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC82000(){

	var valid1;
	var updateRecord;

	//畫面檢核
	function  initValidation(){
	
	     valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		 //valid1.define("required", { id: "LOAN_ID" , errMsg:"請輸入貸款帳號，謝謝!!" } );
		
	}
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_2000/" + actionName,
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
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0004:"btn_update"
		};
		<dz:grantButtons FUNC_ID="DSC82000" ignored="false"/>
	}	
	
	
	function checkQuery(){
		if(!updateRecord){
			alert("請先查詢！");
			return false;
		}
		
		var LOAN_ID_OLD = updateRecord.LOAN_ID;
		if(LOAN_ID_OLD != $F('LOAN_ID')){
			alert("欲變更的帳號("+$F('LOAN_ID')+")與原先查詢的帳號("+LOAN_ID_OLD+")不一致!");
			return false;
		}
		return true;
	};
	
	// 金額格式化
	var gridFmtRender = function(value) { 
		return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
	};
	
	var buttons = {
		
		//查詢
		doQuery : function(event){
			
			if(!valid1.validate()){
				return;
			}
			
			var LOAN_ID_length = $F('LOAN_ID').length;
			if(LOAN_ID_length!=10){
				alert("貸款帳號有誤, 請檢查後重新輸入!");
				return;
			}
			
			$$('#table3 span').each(
				function(ele){
				var id = ele.id;
				ele.update('');
			});
			
			ajaxPost('query' , {'LOAN_ID' : $F('LOAN_ID')},
				function(resp){
					//查詢成功
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$('BORROW_ID').update(rtnMap.BORROW_NAME +' '+ rtnMap.BORROW_ID || '');
					$('LOAN_KIND1').update(rtnMap.LOAN_KIND_NM1 +' '+ rtnMap.PREFER_TYPE_NM1 || '');
					$('REMAIN_AMT').update(gridFmtRender(rtnMap.REMAIN_AMT) || 0);
					$w('LOAN_STATUS_NM VIP_GRADE_NM PAID_TIMES NEXT_PAYDT1 ').each(
						function(id){
							$(id).update(rtnMap[id] || '');
						});
					$w('VIP_GRADE LOAN_STATUS').each(
						function(id){
							$(id).value = rtnMap[id] || '';
						});
					updateRecord = {LOAN_ID:$F('LOAN_ID')	
									,BORROW_ID:rtnMap.BORROW_ID		
									,NEXT_PAYDT1:rtnMap.NEXT_PAYDT1
									,PAID_TIMES:rtnMap.PAID_TIMES
									}; 					 
				}
			);
		},
		
		//試算
		doQuery2 : function(event){
			if(!checkQuery()){
				return;
			}
			
			ajaxPost('query2' , {'LOAN_ID' : updateRecord.LOAN_ID,'BORROW_ID' : updateRecord.BORROW_ID},
				function(resp){
					
					var rtnMap = resp.rtnMap ? resp.rtnMap : {};
					
					$('PREFER_BEGDT').update(updateRecord.NEXT_PAYDT1 || '');
					$('PREFER_BEGNO').update(updateRecord.PAID_TIMES || '');
					$('VIP_GRADE2').update(rtnMap.VIP_GRADE_NM2 || '');
					$('SALARY_GROUP2').update(rtnMap.SALARY_GROUP_NM2  || '');
					$('LOAN_KIND2').update(rtnMap.LOAN_KIND_NM2 + ' ' + rtnMap.PREFER_TYPE_NM2 || '');
				}
			);
		},
		
		//變更
		doUpdate : function(event){

			if(!checkQuery()){
				return;
			}

			if(confirm("確定要平轉此貸款帳號為年資優惠?")){
				ajaxPost('update' , {'LOAN_ID' : $F('LOAN_ID')},
					function(resp){
				
						var rtnMap = resp.rtnMap || {};
				
						$('PREFER_BEGDT').update(rtnMap.PREFER_BEGDT2|| '');
						$('PREFER_BEGNO').update(rtnMap.PREFER_BEGNO2 || '');
						$('VIP_GRADE2').update(rtnMap.VIP_GRADE_NM2 || '');
						$('SALARY_GROUP2').update(rtnMap.SALARY_GROUP_NM2  || '');
						$('LOAN_KIND2').update(rtnMap.LOAN_KIND_NM2 + ' ' + rtnMap.PREFER_TYPE_NM2 || '');
					}
				);
			}else{
				return;
			}
		},
		
		//復原
		doResume : function(event){
		
			if(!checkQuery()){
				return;
			}
			
			if(confirm("確定要復原此貸款帳號的平轉資料?")){
				ajaxPost('resume' , {'LOAN_ID' : $F('LOAN_ID')},
					function(resp){
						var rtnMap = resp.rtnMap || {};
						$('PREFER_BEGDT').update(rtnMap.PREFER_BEGDT2|| '');
						$('PREFER_BEGNO').update(rtnMap.PREFER_BEGNO2|| '');
						$('VIP_GRADE2').update(rtnMap.VIP_GRADE_NM2|| '');
						$('SALARY_GROUP2').update(rtnMap.SALARY_GROUP_NM2|| '');
						$('LOAN_KIND2').update(rtnMap.LOAN_KIND_NM2 || '');
											
					}
				);
			}else{
				return;
			}
		}
	};


	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC82000', '收息資料更新', '平轉-年資優惠');
			
			initValidation();
			//buttonAuth();
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_query2').observe('click', buttons.doQuery2);
			$('btn_update').observe('click', buttons.doUpdate);
			$('btn_resume').observe('click', buttons.doResume);
			
			$('LOAN_ID').observe('blur', function(){
				this.value = this.value.toUpperCase();
			})

			PageUI.resize();			
			displayMessage();			
		}
	};
}


</script>
</head>
<body>
<form name="form" id="from" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	
	<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2"  width="50%">
				<input id="LOAN_ID" type="text" class="textBox2 required" size='12' maxlength='10'/>
			</td>
			<td class="tbYellow2" width="40%">
				<input id="btn_query" type="button" class="button" value="查詢"/>
				<input id="btn_query2" type="button" class="button" value="試算"/>
				<input id="btn_update" type="button" class="button" value="變更"/>
				<input id="btn_resume" type="button" class="button" value="復原"/>	
			</td>
		</tr>
	</table>
		
	<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">借款人</td>
			<td class="tbYellow2" width="20%" >
				<span id="BORROW_ID" style="font-family: 'EUDC'"></span> <%-- [20230321] --%>
			</td>
			<td class="tbYellow" width="15%">契約狀態</td>
			<td	class="tbYellow2" width="20%" >
				<span id="LOAN_STATUS_NM" class="textBlue"></span>
				<input id="LOAN_STATUS" type="hidden">
			</td>
			<td class="tbYellow" width="15%">本金餘額</td>
			<td class="tbYellow2" width="20%">
				<span id="REMAIN_AMT"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">商品種類</td>
			<td class="tbYellow2">
				<span id="LOAN_KIND1"></span>
			</td>
			<td class="tbYellow">客戶等級</td>
			<td class="tbYellow2">
				<span id="VIP_GRADE_NM" class="textRed"></span>
			</td>
			<td class="tbYellow">已繳期數</td>
			<td class="tbYellow2">
				<span id="PAID_TIMES"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">下次應繳日</td>
			<td class="tbYellow2">
				<span id="NEXT_PAYDT1"></span>
			</td>
			<td class="tbYellow"></td>
			<td class="tbYellow2" colspan="3">
				<input id="VIP_GRADE" type="hidden">
			</td>
		</tr>
	</table>
	
	<table id="table3" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td align="center" colspan="6" class="tbBox3">變更後</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">轉換應繳日</td>
			<td class="tbYellow2" width="20%" >
				<span id="PREFER_BEGDT"></span>
			</td>
			<td class="tbYellow" width="15%">轉換期數</td>
			<td	class="tbYellow2" width="20%" >
				<span id="PREFER_BEGNO"></span>
			</td>
			<td class="tbYellow" width="15%">新客戶等級</td>
			<td class="tbYellow2" width="20%" >
				<span id="VIP_GRADE2" class="textRed" ></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">扣薪組別</td>
			<td class="tbYellow2" width="20%" >
				<span id="SALARY_GROUP2" class="textRed" ></span>
			</td>
			<td class="tbYellow" width="15%">新商品種類</td>
			<td	class="tbYellow2" width="20%" >
				<span id="LOAN_KIND2"></span>
			</td>
			<td class="tbYellow" width="15%"></td>
			<td class="tbYellow2" width="20%"></td>
		</tr>
	</table>

</form>	
</body>
</html>