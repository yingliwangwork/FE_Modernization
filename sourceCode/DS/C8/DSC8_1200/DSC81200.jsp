<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!--
程式：DSC81200.jsp
作者：溫子?
功能：借款資料變更
完成：2013/8/

[20230321]
難字調整
高強禾
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!--alert訊息-->

<script type="text/javascript">
//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC81200().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC81200(){
var rtnMap={};

// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0004 : 'BTN_UPDATE'
			};
			<dz:grantButtons FUNC_ID='DSC81200'/>
		};
function initValidation(){
			//查詢用檢核
				
			Validation.addAllThese([
				[ 'validateLOAN_ID_10',  '貸款帳號長度不正確 需為10碼',
					function(v){				
						return (v.length != 10) ? false : true ;
					}
				],
				[ 'validateDUTY_DAY',  '每月應繳日須為01~30的數字!!',
					function(v){				
						if(isNaN(v)||parseInt(v)>31){
							return false;
						}else{
							return true;
						}
						
					}
				],
			    [ 'chkBORROW_ID', '借款人ID輸入錯誤!!', 
					function(v,elm) {
						if(v.length >= 8){			
							if(validation.checkUniSN(v) || validation.checkROCID(v) || !validation.checkROCPassport(v) || validation.checkROCARC(v)) { 
								return true ;
							}
						}
						return false;
					}
				]/*,
				[ 'chkAGENT_ID', '經手人ID不可空白!!', 
					function(v) {
						if($F('CRED_DEPT') == "2"){	
							return true ;
						} 						
						if(v != "") { 
							return true ;
						}						
						return false;
					}
				],
				[ 'checkROCID_AGENT_ID', '經手人ID輸入錯誤!!', 
					function(v) {
						if($F('CRED_DEPT') == "2"){	
							if(v != "") { 
								if(validation.checkROCID(v)){
									return true ;						
								}
								
								return false;
							}	
							return true ;
						} 

						if(v != "") { 
							if(validation.checkROCID(v)){
								return true ;						
							}
						}							
											
						return false;
					}
				]*/					
			]);
			
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid1.define( "required" , { id: "LOAN_ID" , errMsg:"貸款帳號不可空白!!" } );
			valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID"});
			
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid2.define( "required" , { id: "BORROW_ID" , errMsg:"借款人ID不可空白!!" } );
			valid2.define( "chkBORROW_ID" , { id: "BORROW_ID", errMsg:"借款人ID輸入錯誤!!" });
			/*valid2.define( "chkAGENT_ID" , { id: "AGENT_ID" , errMsg:"經手人ID不可空白!!" } );
			valid2.define( "checkROCID_AGENT_ID" , { id: "AGENT_ID", errMsg:"經手人ID輸入錯誤!!" });*/
			valid2.define( "validate-ROCDate" , { id: "BIRTHDAY", errMsg:"出生日期輸入錯誤!!" });
			valid2.define( "validate-ROCDate" , { id: "END_DATE", errMsg:"滿期日輸入錯誤!!" });
			valid2.define( "required" , { id: "BIRTHDAY", errMsg:"請輸入出生日期!!" });
			valid2.define( "required" , { id: "END_DATE", errMsg:"請輸入滿期日期!!" });
			valid2.define( "validate-selection" , { id: "CRED_DEPT", errMsg:"請輸入承辦科別!!" });
			valid2.define( "validate-selection" , { id: "LOAN_TYPE", errMsg:"請輸入貸款類別!!" });
			
			valid2.define( "required" , { id: "DUTY_DAY" , errMsg:"請輸入每月應繳日!!" } );
			valid2.define( "validateDUTY_DAY" , { id: "DUTY_DAY" } );
			
	}
// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_1200/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};
var buttons = {
	doQuery : function(){
		valid2.reset();
		if(!valid1.validate()){ 
			return; 
		}
		ajaxPost( 'query' , { 'LOAN_ID' : $F('LOAN_ID') },
					function(resp){
						rtnMap = resp.rtnMap;
						
						$$('#form input[type!="button"]' ,'#form select').each(function(ele){
							var id =ele.id;
							$(id).value=rtnMap[id]||'';
						
						})
						$w('SALARY_STATUS LIMIT_CODE TAX_CODE EXTRA_CODE PAID_TIMES PREPAY_TIMES GROUP_CODE CRED_GUAR VALID_TIMES RETAIN_INT').each(function(ele){
							if(!rtnMap[ele]){
								$(ele).value=0;
							}
						})
						if(rtnMap['ZERO_TERM']=='Y'){
							$('DUTY_DAY').disabled=false;
						}
						if(!rtnMap['AREA_CODE']){
							$('AREA_CODE').value=1;
						}
						if(rtnMap['disable']){
							$('FLOAT_TYPE').disabled=true;
						}
						$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
						$('COPR_CODE').value = rtnMap['COPR_CODE'] || '';
						
						if("2" == rtnMap.CRED_DEPT) {
							$('CRED_DEPT_2').show();
							$('isNotPay').checked = true;
						} else {
							$('CRED_DEPT_2').hide();
							$('isNotPay').checked = false;
						}
					},function(resp){
						$('FLOAT_TYPE').disabled=false;
						$('LOAN_ID_OLD').value = '';
						$('CRED_DEPT_2').hide();
						$('isNotPay').checked = false;
					}
				);
	}
	,doUpdate : function(){
		valid2.reset();
		if(!$F('LOAN_ID_OLD')){
			alert("請先查詢後再變更!");
			return;
		}
		if($F('LOAN_ID') != $F('LOAN_ID_OLD')){
			alert("欲變更的"+$F('LOAN_ID')+"與原先查詢的"+$F('LOAN_ID_OLD')+"不同，無法作業!");
			return;
		}
		if(!valid2.validate()){ 
			return; 
		}
		if($('isNotPay').checked){
			$('IS_E020').value = "0";	
		} else {
			$('IS_E020').value = "1";	
		}
		if($F('FLOAT_TYPE')!=rtnMap['FLOAT_TYPE']){
			if(!$F('FLOAT_TYPE')){
				alert("請選擇利率調整方式!!");
				return;
			}
			if($F('IS_E020')==1){
				alert("變更利率調整方式將酌收1,500元手續費");
			}
			if(!confirm("是否變更利率調整方式？")){
				return ;
			}
			$('ACT').value='UPDATE2';
		}
		if($F('BORROW_ID')!=rtnMap['BORROW_ID']){
			if(!confirm("是否更換借款人（非ID改號）")){
				alert("欲變更借款人的ID，請使用ID改號作業！");
				return;
			}
		}
		if($F('BORROW_NAME')!=rtnMap['BORROW_NAME']){
			alert("欲變更借款人的姓名，請使用ID改號作業！");
			return;
		}
		ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap()), 'LOAN_ID' : $F('LOAN_ID') },
				function(resp){
						
					rtnMap = resp.rtnMap;
						$$('#form input[type!="button"]' ,'#form select').each(function(ele){
							var id =ele.id;
							$(id).value=rtnMap[id]||'';
						
						})
						$w('SALARY_STATUS LIMIT_CODE TAX_CODE EXTRA_CODE PAID_TIMES PREPAY_TIMES GROUP_CODE CRED_GUAR VALID_TIMES RETAIN_INT ').each(function(ele){
							if(!rtnMap[ele]){
								$(ele).value=0;
							}
						})
						if(rtnMap['ZERO_TERM']=='Y'){
							$('DUTY_DAY').disabled=false;
						}
						if(!rtnMap['AREA_CODE']){
							$('AREA_CODE').value=1;
						}
						if(rtnMap['disable']){
							$('FLOAT_TYPE').disabled=true;
						}	
						
					$('LOAN_ID_OLD').value = rtnMap['LOAN_ID'] || '';
				}
			);	
	}
}

// 產生查詢回傳資料
	var reqMap = function(){
		
		var reqMap = {};

		$$('#form input[type!="button"]', '#form select').each(
			function(text){
				reqMap[text.id] = text.value;
			}
		);
		
		return reqMap;		
	};	
return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC81200', '變更作業', '借款資料變更');

				// 查詢
				$('BTN_QUERY').observe('click', buttons.doQuery);
				
				// 變更
				$('BTN_UPDATE').observe('click', buttons.doUpdate);
				
				$('CRED_DEPT_2').hide();
				
				//$('SALARY_GROUP').value=0;
				$('SALARY_STATUS').value=0;
				$('LIMIT_CODE').value=0;
				$('TAX_CODE').value=0;
				$('AREA_CODE').value=1;
				$('EXTRA_CODE').value=0;
				buttonAuth();
				initValidation();
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
				
			}
	}

}
</script>
</head>
<body>
<form id="form" name="form"  style="PADDING: 0px; MARGIN: 0px;">
<table id='table1' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">貸款帳號</td>
			<td class="tbYellow2" width="15%">
			<input id="LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
			<input id="LOAN_ID_OLD" type="hidden">
			
			<input id="ITEM_CHINESE" type="hidden">
			<input id="IS_E020" type="hidden">
			<input id="LOAN_KIND" type="hidden">
			<input id="EXPENSE_ITEM" type="hidden">
			<input id="ACT" type="hidden">
			<input id="COPR_CODE" type="hidden">
			
		</td>
		<td class="tbYellow2" width="30%" colspan="6">
			<input id="BTN_QUERY" type="button" value="查詢" class="button"> 
			<input id="BTN_UPDATE" type="button" value="變更" class="button"> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >借款人ID</td>
		<td class="tbYellow2" >
			<input id="BORROW_ID" type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()" maxlength='10' />
		</td>
		<td class="tbYellow" >借款人姓名</td>
		<td class="tbYellow2" >
			<%-- [20230321] 難字調整 --%>
			<input id="BORROW_NAME" type="text" class="textBox2" alt="ch" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >出生日期</td>
		<td class="tbYellow2" >
			<input id="BIRTHDAY"  type="text" class="textBox2 " name="BIRTHDAY"   datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('BIRTHDAY'))"></td>
		<td class="tbYellow" >滿期日期</td>
		<td class="tbYellow2" >
			<input id="END_DATE"  type="text" class="textBox2 " name="END_DATE"   datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('END_DATE'))"></td>
	</tr>
	<tr>
		<td class="tbYellow" >經手人ID</td>
		<td class="tbYellow2" >
			<input id="AGENT_ID" type="text" class="textBox2"  onblur="this.value = this.value.toUpperCase()" maxlength='10' readOnly/>
		</td>
		<td class="tbYellow" >承辦科別</td>
		<td class="tbYellow2" >
			<select id="CRED_DEPT">
					<c:forEach var="map" items="${CRED_DEPT_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >貸款類別</td>
		<td class="tbYellow2" >
			<select id="LOAN_TYPE">
				<option value="">請選擇</option>
					<c:forEach var="map" items="${LOAN_TYPE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >擔保品種類</td>
		<td class="tbYellow2" >
			<select id="GAGE_TYPE">
					<c:forEach var="map" items="${GAGE_TYPE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >扣薪組別</td>
		<td class="tbYellow2" >
			<select id="SALARY_GROUP">
					<option value="">非扣薪件</option>
					<c:forEach var="map" items="${SALARY_GROUP_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >扣薪狀態</td>
		<td class="tbYellow2" >
			<select id="SALARY_STATUS">

					<c:forEach var="map" items="${SALARY_STATUS_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >資料限制</td>
		<td class="tbYellow2" >
			<select id="LIMIT_CODE">
					<c:forEach var="map" items="${LIMIT_CODE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >代扣稅款</td>
		<td class="tbYellow2" >
			<select id="TAX_CODE">
					<c:forEach var="map" items="${TAX_CODE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >地區代號</td>
		<td class="tbYellow2" >
			<select id="AREA_CODE">
					<c:forEach var="map" items="${AREA_CODE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >集團代碼</td>
		<td class="tbYellow2" >
			<input id="GROUP_CODE" type="text" class="textBox2 validate-number" maxlength='4'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >3200億專案額外</td>
		<td class="tbYellow2" >
			<select id="EXTRA_CODE">
					<c:forEach var="map" items="${EXTRA_CODE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >信保貸款</td>
		<td class="tbYellow2" >
			<input id="CRED_GUAR" type="text" class="textBox2 validate-number" maxlength='11'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >已繳期數</td>
		<td class="tbYellow2" >
			<input id="PAID_TIMES" type="text" class="textBox2 validate-number" maxlength='6'/>
		</td>
		<td class="tbYellow" >有效期數</td>
		<td class="tbYellow2" >
			<input id="VALID_TIMES" type="text" class="textBox2 validate-number" maxlength='6'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >預繳期數</td>
		<td class="tbYellow2" >
			<input id="PREPAY_TIMES" type="text" class="textBox2 validate-number" maxlength='6'/>
		</td>
		<td class="tbYellow" >年底應利</td>
		<td class="tbYellow2" >
			<input id="RETAIN_INT" type="text" class="textBox2 validate-number" maxlength='9'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >每月應繳日</td>
		<td class="tbYellow2" >
			<input id="DUTY_DAY" type="text" class="textBox2" size="9" disabled />
		</td>
		<td class="tbYellow" >延滯息違約金</td>
		<td class="tbYellow2" >
			<select id="SPEC_CODE">
					<c:forEach var="map" items="${SPEC_CODE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>		
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >利率調整方式</td>
		<td class="tbYellow2" >
			<select id="FLOAT_TYPE">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${FLOAT_TYPE_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
			</select>
		</td>
		<td class="tbYellow" >授信行業別</td>
		<td class="tbYellow2" >
			<input id="CRED_BUSINESS" type="text" class="textBox2" maxlength='6'/>
		</td>
	</tr>
	<tr id="CRED_DEPT_2">
		<td class="tbYellow">不收取帳管費</td>
		<td class="tbYellow2" colspan=3 >
			<input id="isNotPay" type="checkbox">
		</td>
	</tr>	
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow" >
		<br>&nbsp; ※1. 請先查詢再變更。
		<br>&nbsp; ※2. 災戶件不可做每月應繳日變更。
		<br>&nbsp; <font color="red">※3. 當利率調整有異動，其它欄位的異動不會一併處理。</font>
		<br>&nbsp; ※4. 利率調整方式改為月調後，不可再改回原方式。
		</td>
	</tr>
</table>
</table>
</form>
</body>
</html>
