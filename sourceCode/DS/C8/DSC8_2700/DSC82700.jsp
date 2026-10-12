<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC82700.jsp
作者：張憶如 
功能：平轉-新增好貸
完成：2013/9/9

[20230321] 修改程式  楊青峰
難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

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

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC82700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC82700(){
	
	var grid;
	var valid1;
	
	//畫面檢核
	function initValidation(){
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	
	}
	
	//定義檢核
	function defineValid(type){
		if(type=='query'){
			valid1.define('required' , [{ id : "LOAN_ID" , errMsg:'貸款帳號有誤, 請檢查後重新輸入!'}]);		
		}else if(type=='other'){
			valid1.define('required' , [{ id : "LOAN_ID" , errMsg:'貸款帳號有誤, 請檢查後重新輸入!'}]);		
			valid1.define('required' , [{ id : "APPLY_DATE" , errMsg:'請輸入申請日期!'}]);		
		}		
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_2700/" + actionName,
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
		
			valid1.reset();
			valid1.clear();				
			//檢核欄位
			defineValid('query');
			if(!valid1.validate()){					
				return;			
			}
			//發送ajax
			ajaxPost( 'query', {LOAN_ID: $F('LOAN_ID')},
				function(resp){	
					$$('#table_B span').each(function(ele){
						ele.update();
					})
					$$('#table_B input').each(function(ele){
						ele.value = '';
					})
					var rtnMap = resp.rtnMap || [];
					$$('#table_A input').each(function(ele){
						ele.value = rtnMap[ele.id]||'';
					})
					$$('#table_A span').each(function(ele){
						ele.update(rtnMap[ele.id]||'');
					})
					$('REMAIN_AMT').update(CSRUtil.$fmt(rtnMap['REMAIN_AMT'],"#,###")||0);
					$('LOAN_ID_O').value = $F('LOAN_ID');
					$('btn_compute').enable();
					$('btn_update').enable();
					$('btn_delete').enable();
					
					$('VIP_GRADE').value = '';
					$('VIP_GRADE').disable();
				},
				function(resp){
					$$('#table_A span').each(function(ele){
						ele.update();
					})
					$$('#table_A input').each(function(ele){
						ele.value = '';
					})
					$$('#table_B span').each(function(ele){
						ele.update();
					})
					$$('#table_B input').each(function(ele){
						ele.value = '';
					})
					$('btn_update').disable();
					$('btn_compute').disable();
					$('btn_delete').disable();
					
					$('VIP_GRADE').value = '';
					$('VIP_GRADE').disable();
				}
			);				
		},
		doCompute : function(){
			
			valid1.reset();
			valid1.clear();	
			//檢核欄位
			defineValid('other');
			if(!valid1.validate()){					
				return;			
			}
			
			<%-- 
				[20240226]  借款人 若含有難字, 則會導致 AntiXSSRequestData$InputXSSError輸入值格式有安全性的錯誤
				移除 借款人   
			--%>
			var reqMap = {
				APPLY_DATE : $F('APPLY_DATE'),
				LOAN_ID : $F('LOAN_ID'),
				LOAN_ID_O : $F('LOAN_ID_O'),
				BORROW_ID : $('BORROW_ID').innerHTML,
				//BORROW_NAME : $('BORROW_NAME').innerHTML,
				LOAN_STATUS : $F('LOAN_STATUS'),
				LOAN_STATUS_NM : $('LOAN_STATUS_NM').innerHTML,
				REMAIN_AMT : $('REMAIN_AMT').innerHTML,
				LOAN_KIND_NM1 : $('LOAN_KIND_NM1').innerHTML,
				PREFER_TYPE_NM1 : $('PREFER_TYPE_NM1').innerHTML,
				LOAN_KIND1 : $F('LOAN_KIND1'),
				PREFER_TYPE1 : $F('PREFER_TYPE1'),
				VIP_GRADE1 : $F('VIP_GRADE1'),
				VIP_GRADE_NM1 : $('VIP_GRADE_NM1').innerHTML,
				PAID_TIMES : $('PAID_TIMES').innerHTML,
				NEXT_PAYDT1 : $('NEXT_PAYDT1').innerHTML,
				RENEGE_KIND : $('RENEGE_KIND').value,
				LOAN_PERIOD : $F('LOAN_PERIOD'),
				DUTY_DAY : $F('DUTY_DAY'),
				NEXT_PAYDT : $F('NEXT_PAYDT'),
				LOAN_DATE : $F('LOAN_DATE')
			};			
			//發送ajax
			ajaxPost( 'compute', {reqMap : Object.toJSON(reqMap)}, 
				function(resp){
					
					var rtnMap = resp.rtnMap || {};
					actions.display(rtnMap);
					$('VIP_GRADE').enable();
					var AREA_CODE_TIPS = rtnMap['AREA_CODE_TIPS']||'';
					if(AREA_CODE_TIPS == 'Y'){
						alert("平轉新增好貸後之地區別有異動，請確認!")
					}
				},function(resp){
					$('VIP_GRADE').disable();				
				}
			);				
		},
		doUpdate : function(){
		
			valid1.reset();
			valid1.clear();				
			defineValid('other');
			//檢核欄位
			if(!valid1.validate()){					
				return;			
			}
			//確認是否執行復原
			if(!confirm('確定要平轉此貸款帳號為新增好貸？')){
				return;
			}
			
			<%-- 
				[20240226]  借款人 若含有難字, 則會導致 AntiXSSRequestData$InputXSSError輸入值格式有安全性的錯誤
				移除 借款人   
			--%>
			var reqMap = {
				APPLY_DATE : $F('APPLY_DATE'),
				LOAN_ID : $F('LOAN_ID'),
				LOAN_ID_O : $F('LOAN_ID_O'),
				BORROW_ID : $('BORROW_ID').innerHTML,
				//BORROW_NAME : $('BORROW_NAME').innerHTML,
				LOAN_STATUS : $F('LOAN_STATUS'),
				LOAN_STATUS_NM : $('LOAN_STATUS_NM').innerHTML,
				REMAIN_AMT : $('REMAIN_AMT').innerHTML,
				LOAN_KIND_NM1 : $('LOAN_KIND_NM1').innerHTML,
				PREFER_TYPE_NM1 : $('PREFER_TYPE_NM1').innerHTML,
				LOAN_KIND1 : $F('LOAN_KIND1'),
				PREFER_TYPE1 : $F('PREFER_TYPE1'),
				VIP_GRADE1 : $F('VIP_GRADE1'),
				VIP_GRADE_NM1 : $('VIP_GRADE_NM1').innerHTML,
				PAID_TIMES : $('PAID_TIMES').innerHTML,
				NEXT_PAYDT1 : $('NEXT_PAYDT1').innerHTML,
				RENEGE_KIND : $('RENEGE_KIND').value,
				LOAN_PERIOD : $F('LOAN_PERIOD'),
				DUTY_DAY : $F('DUTY_DAY'),
				NEXT_PAYDT : $F('NEXT_PAYDT'),
				VIP_GRADE : $F('VIP_GRADE'),
				LOAN_DATE : $F('LOAN_DATE')				
			};
			//發送ajax
			ajaxPost( 'update', {reqMap : Object.toJSON(reqMap)},
				function(resp){
					var rtnMap = resp.rtnMap || {};
					actions.display(rtnMap);
					$('VIP_GRADE').disable();
					var AREA_CODE_TIPS = rtnMap['AREA_CODE_TIPS']||'';
					if(AREA_CODE_TIPS == 'Y'){
						alert("平轉新增好貸後之地區別有異動，請確認!")
					}					
				}
			);				
		},
		doDelete : function(){
			valid1.reset();
			valid1.clear();			
		
			//確認是否執行復原
			if(!confirm('確定要復原此貸款帳號的平轉資料？')){
				return;
			}
			
			//發送ajax
			ajaxPost( 'delete', {LOAN_ID: $F('LOAN_ID'), LOAN_ID_O: $F('LOAN_ID_O')},
				function(resp){	
					var rtnMap = resp.rtnMap || {};
					actions.display(rtnMap);
					$('VIP_GRADE').disable();
				},function(resp){
					$('VIP_GRADE').disable();				
				}
			);				
		},
		display: function(rtnMap){
			$$('#table_B span').each(function(ele){
				ele.update(rtnMap[ele.id]||'');
			})			
			$('RENEGE').update(CSRUtil.$fmt(rtnMap['RENEGE'], '#.###')||0);
			$('VIP_GRADE').value = rtnMap['VIP_GRADE2']||'';		
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC82700" , "變更作業", "平轉-新增好貸" );
			initValidation(); //檢核欄位
			
			//按鈕動作
			// 查詢
			$('btn_query').observe('click', actions.doQuery);
			//新增
			$('btn_compute').observe('click', actions.doCompute);
			//修正
			$('btn_update').observe('click', actions.doUpdate);
			//刪除
			$('btn_delete').observe('click', actions.doDelete);
			//轉大寫
			var LOAN_ID = $('LOAN_ID');
			LOAN_ID.observe('blur', function(event){
				LOAN_ID.value = LOAN_ID.value.toUpperCase();
			});
			
			autoCreateDate();			
			autoFormatToDate();
			
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC82700
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="15%">貸款帳號</td>
				<td class="tbYellow2" width="15%">
					<input id="LOAN_ID" class="textBox2" size='12' maxlength='10'>
				</td>
				<td class="tbYellow" width="15%" >申請日期</td>
				<td class="tbYellow2" width="35%">
					<input id="APPLY_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate">
				</td>
				<td class="tbYellow2" width="20%">
					<input id="btn_query" class="button" type="button" value="查詢">
					<input id="btn_compute" class="button" type="button" value="試算" disabled>
					<input id="btn_update" class="button" type="button" value="變更" disabled>
					<input id="btn_delete" class="button" type="button" value="復原" disabled>
				</td>
			</tr>
		</table>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan="6">&nbsp</td>
			</tr>
			<tr>	
				<td class="tbYellow" width="16%">借款人</td>			
				<td class="tbYellow2" width="16%">
					<span id="BORROW_NAME" style="font-family: 'EUDC'"></span>&nbsp <%-- [20230321] --%>
					<span id="BORROW_ID"></span>
				</td>
				<td class="tbYellow" width="16%">契約狀態</td>			
				<td class="tbYellow2" width="16%">
					<span id="LOAN_STATUS_NM" style="color:blue"></span>
				</td>
				<td class="tbYellow" width="16%">本金餘額</td>			
				<td class="tbYellow2" width="16%">
					<span id="REMAIN_AMT"></span>
				</td>
			</tr>
			<tr>	
				<td class="tbYellow" >商品種類</td>			
				<td class="tbYellow2" >
					<span id="LOAN_KIND_NM1"></span>&nbsp
					<span id="PREFER_TYPE_NM1"></span>
				</td>
				<td class="tbYellow" >客戶等級</td>			
				<td class="tbYellow2" >
					<span id="VIP_GRADE_NM1"></span>
				</td>
				<td class="tbYellow" >已繳期數</td>			
				<td class="tbYellow2" >
					<span id="PAID_TIMES"></span>
				</td>
			</tr>
			<tr>	
				<td class="tbYellow" >下次應繳日</td>			
				<td class="tbYellow2" >
					<span id="NEXT_PAYDT1"></span>
					<input id="NEXT_PAYDT" type='hidden'/>
				</td>
				<td class="tbYellow" >違約金方式</td>			
				<td class="tbYellow2" >
					<select id = "RENEGE_KIND" name="RENEGE_KIND">
						<c:forEach var="map" items="${RENEGE_KIND_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow" ></td>			
				<td class="tbYellow2" ></td>
			</tr>
			<input id="LOAN_STATUS" type="hidden"/>
			<input id="LOAN_KIND1" type="hidden"/>
			<input id="PREFER_TYPE1" type="hidden"/>
			<input id="VIP_GRADE1" type="hidden"/>
			<input id="LOAN_PERIOD" type="hidden"/>
			<input id="DUTY_DAY" type="hidden"/>
			<input id="LOAN_ID_O" type="hidden"/>
			<input id="LOAN_DATE" type="hidden"/>			
		</table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow0" colspan="6" align="center">變更後資料</td>
			</tr>
			<tr>	
				<td class="tbYellow" width="16%">轉換應繳日</td>			
				<td class="tbYellow2" width="16%">
					<span id="PREFER_BEGDT"></span>
				</td>
				<td class="tbYellow" width="16%">轉換期數</td>			
				<td class="tbYellow2" width="16%">
					<span id="PREFER_BEGNO"></span>
				</td>
				<td class="tbYellow" width="16%">新客戶等級</td>			
				<td class="tbYellow2" width="16%">
					<select id = "VIP_GRADE" name="VIP_GRADE" disabled>
						<option value=""></option>					
						<c:forEach var="map" items="${VIP_GRADE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select> 
				</td>
			</tr>
			<tr>	
				<td class="tbYellow" >新商品種類</td>			
				<td class="tbYellow2" >
					<span id="LOAN_KIND_NM2"></span>&nbsp
					<span id="PREFER_TYPE_NM2"></span>
				</td>
				<td class="tbYellow" >違約金</td>			
				<td class="tbYellow2" >
					<span id="RENEGE"></span>
				</td>
				<td class="tbYellow" >擔保品地區別</td>			
				<td class="tbYellow2" >
					<span id="AREA_CODE_NM2"></span>
				</td>
			</tr>
		</table>
		
	</form>
</body>
</html>