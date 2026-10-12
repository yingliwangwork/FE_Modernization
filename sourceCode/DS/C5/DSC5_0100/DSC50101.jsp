<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC50101.jsp
作者：張恆勖
功能：基準利率明細
完成：2012/11/30
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->


<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		  <%-- 月曆專用 --%>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC50101().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC50101(){
		
	//欄位必輸入檢核
	var valid1;		
	
	//紀錄查詢後的參數
	var CK_KIND;	
	
	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	function buttonAuth(){
		var authButtons = {
			B0003 : 'BTN_B0003'<%-- 新增 --%>,
			B0004 : 'BTN_B0004'<%-- 刪除 --%>,
			B0005 : 'BTN_B0005'<%-- 修改 --%>,
			B0070 : 'BTN_B0070'<%-- 覆核 --%>
		};
				
		<dz:grantButtons FUNC_ID="DSC50101" ignored="false"/>
	}
	
	//檢核日期欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});		
		valid1.define('required' , [{ id : "BASE_CODE"  , errMsg:"請輸入基準代碼"}] );				
		valid1.define('required' , [{ id : "BEGIN_DATE" , errMsg:"請輸入生效日期"}] );				
		valid1.define('required' , [{ id : "BASE_RATE"  , errMsg:"請輸入基準利率"}] );	
		valid1.define('validate-number' , [{ id : "BASE_RATE"  }] );		
	}		
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0101/" + actionName,
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
	
	// 功能按鈕
	var button = {
		
		rtnMap : null, 
				
		name : null,
		//把中文取出來
		BASE_NAME : name.split('_')[1], 
				
		//修正、刪除取得參數
		getreqMap : function() {
			
			return {			
				BASE_CODE : $F('BASE_CODE'),								
				BASE_RATE : $F('BASE_RATE'),	
				BEGIN_DATE : $F('BEGIN_DATE'),
				SER_NO : button.rtnMap.SER_NO,								
				INPUT_ID : button.rtnMap.INPUT_ID,
				BASE_NAME : button.BASE_NAME,
				CHG_KIND : CK_KIND
				
			};
		},

		getreqInsertMap : function() {
			
			return {			
				BASE_CODE : $F('BASE_CODE'),								
				BASE_RATE : $F('BASE_RATE'),	
				BEGIN_DATE : $F('BEGIN_DATE'),		
				BASE_NAME : button.BASE_NAME
				
			};
		},
			
		//查詢
		doQuery : function(){			
			//發送AJAX
			ajaxPost('query', {'BASE_CODE' : '${BASE_CODE}', 'BEGIN_DATE' : '${BEGIN_DATE}', 'SER_NO' : '${SER_NO}', 'IS_FIRST' : '${IS_FIRST}'}
				,function(resp){					
							
					button.rtnMap = resp.rtnMap;					
					
					$w('SER_NO CHG_KIND_NM INPUT_NM  CONFIRM_NM ').each(
						function(id) {
							$(id + '_SPAN').innerHTML = button.rtnMap[id] || '';
						}
					);
					
					$('SER_NO_SPAN').update(button.rtnMap.SER_NO);
					$('INPUT_DATE_SPAN').update(toROC(button.rtnMap['INPUT_DATE']|| ''));
					$('CONFIRM_DATE_SPAN').update(toROC(button.rtnMap['CONFIRM_DATE'] || ''));
					
					
					$('BASE_CODE').value = button.rtnMap.BASE_CODE  || '';
					$('BEGIN_DATE').value = button.rtnMap.BEGIN_DATE  || '';
					$('BASE_RATE').value = button.rtnMap.BASE_RATE  || '';
							
				}
			);	
		},
		
		//新增
		doInsert: function() {		
			//檢核
			if(!valid1.validate()){
				return; 
			}
			
			//取出表面值
			name = $('BASE_CODE').options[$('BASE_CODE').selectedIndex].text;
			
			//發送AJAX	
			ajaxPost( 'insert', { 'reqMap' : Object.toJSON(button.getreqInsertMap())}
				,function(resp){	
					alert('新增成功');
					button.doBack();				
				}				
			);
						
		},
		
		//修正
		doUpdate: function() {
								
			//檢核
			if(!valid1.validate()){
				return; 
			}			
			
			if($('BASE_CODE').value != button.rtnMap.BASE_CODE || $('BEGIN_DATE').value != button.rtnMap.BEGIN_DATE){
				alert('欲UPDATE的基本利率與原先查詢的不同,無法作業!');
				return;
			}
			
			if('${IS_FIRST}'!='Y' && '${CHG_KIND }'!= '1'){ 	
				alert('已覆核過的記錄無法再做變動');
				return;
			}
			
			<c:choose>
				<c:when test='${ IS_FIRST != "Y"}'>
					if(!confirm('確定要修改正式輸入的利率資料？')){					
						return;
					}
				</c:when>
				<c:otherwise>
					if(!confirm('確定要修改試輸的資料？')){					
						return;
					}
				</c:otherwise>
			</c:choose>						
						
			//發送AJAX	
			ajaxPost( 'update', {reqMap:Object.toJSON(button.getreqMap()),'IS_FIRST' : '${IS_FIRST}'}
				,function(resp){										
					//成功之後
					if('${IS_FIRST}'=='Y'){
						alert('修正完成');
					}else{
						alert('修正資料輸入完成，請主管覆核');	
					}					
					button.doBack();					
				}				
			);
		},
		
		//刪除
		doDelete: function() {
		
			//檢核
			if(!valid1.validate()){
				return; 
			}						
			
			if($('BASE_CODE').value != button.rtnMap.BASE_CODE || $('BEGIN_DATE').value != button.rtnMap.BEGIN_DATE){
				alert('欲DELETE的基本利率與原先查詢的不同,無法作業!');
				return;
			}
			
			if('${IS_FIRST}'!='Y' && '${CHG_KIND }'!= '1'){ 	
				alert('已覆核過的記錄無法再做變動');
				return;
			}
						
			<c:choose>
				<c:when test='${IS_FIRST != "Y"}'>
					if(!confirm('確定要刪除正式輸入的利率資料？')){					
						return;
					}
				</c:when>
				<c:otherwise>
					if(!confirm('確定要刪除試輸的資料？')){					
						return;
					}
				</c:otherwise>
			</c:choose>						
			
			//發送AJAX	
			ajaxPost( 'delete', {'reqMap':Object.toJSON(button.getreqMap()),'IS_FIRST' : '${IS_FIRST}'}
				,function(resp){					
					//成功之後							
				<c:choose>
					<c:when test='${IS_FIRST eq "Y"}'>
						alert('刪除試輸資料完成');
					</c:when>
					<c:otherwise>
						alert('刪除資料輸入完成，請主管覆核');
					</c:otherwise>
				</c:choose>			
					CSRUtil.linkBack();   	
				}				
			);				
		},
		
		//覆核
		doConfirm: function() {
			
			//取出表面值
			name = $('BASE_CODE').options[$('BASE_CODE').selectedIndex].text;			
							
			//檢核
			if(!valid1.validate()){
				return; 
			}
			
			if($('BASE_CODE').value != button.rtnMap.BASE_CODE || $('BEGIN_DATE').value != button.rtnMap.BEGIN_DATE || $('BASE_RATE').value != button.rtnMap.BASE_RATE){
				alert('欲覆核的資料與原先查詢的不同,無法作業!');
				return;
			}
						
			<c:choose>
				<c:when test='${CHG_KIND eq "0"}'>
					alert('非待覆核件，無法作業');
					return;
				</c:when>
				<c:when test='${CHG_KIND eq "1"}'>
					if(!confirm('確定要覆核新增的基準利率？')){					
						return;
					}
				</c:when>
				<c:when test='${CHG_KIND eq "2"}'>
					if(!confirm('確定要覆核修改的基準利率？')){					
					return;
				}
				</c:when>
				<c:otherwise>
					if(!confirm('確定要覆核刪除的基準利率？')){					
						return;
					}
				</c:otherwise>
			</c:choose>											
						
			//發送AJAX	
			ajaxPost( 'confirm', {'reqMap':Object.toJSON(button.getreqMap()),'INPUT_ID' : button.rtnMap.INPUT_ID,'IS_FIRST' : '${IS_FIRST}'}
				,function(resp){					
					//成功之後
					<c:choose>						
						<c:when test='${CHG_KIND eq "1"}'>
							alert('覆核成功' + '\n' + '請檢查新增的基本商品利率與優惠商品利率是否正確');								
						</c:when>
						<c:when test='${CHG_KIND eq "2"}'>
							alert('覆核成功' + '\n' + '請檢查修改的基本商品利率與優惠商品利率是否正確');	
						
						</c:when>
						<c:otherwise>
							alert('覆核成功' + '\n' + '請檢查刪除的基本商品利率與優惠商品利率是否正確');	
						</c:otherwise>
					</c:choose>
					button.doBack();					
				}				
			);
		},

		//上一頁
	    doBack : function(event) {										
			
			//連回至連結至本頁之頁面			
			CSRUtil.linkBack();    		   
		}		
	};	
	
	return {
		initApp : function() {			
			PageUI.createPageWithAllBodySubElement( "DSC50101" , "利率調整", "基準利率明細" );					
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------			
			
			<c:choose>
				<c:when test='${ACTION_TYPE eq "I"}'>
					//新增
					$('BTN_B0003').enable();
					$('BTN_B0004').disable();
					$('BTN_B0005').disable();
					$('BTN_B0070').disable();
				</c:when>
				<c:otherwise>
					//查詢
					$('BTN_B0003').disable();
					$('BTN_B0004').enable();
					$('BTN_B0005').enable();
					$('BTN_B0070').enable();			
					//接值的CHG_KIND
					CK_KIND = ${CHG_KIND};					
					button.doQuery();
				</c:otherwise>
			</c:choose>
			
			//畫面日期檢核
			initValidation();
			
			//新增						
			$("BTN_B0003").observe('click', button.doInsert);
			//修正						
			$("BTN_B0004").observe('click', button.doUpdate);
			//刪除					
			$("BTN_B0005").observe('click', button.doDelete);
			//覆核						
			$("BTN_B0070").observe('click', button.doConfirm);
			//回上一頁						
			$("BTN_back").observe('click', button.doBack);
							
			PageUI.resize();
			//初始頁面alert訊息用		
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSC50101
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">		
			<form id="form1">
			<tr>
				<td colspan="4" align="center">					
					<input id="BTN_B0003" type="button" class="button" value="新增" >
					<input id="BTN_B0004" type="button" class="button" value="修正" >
					<input id="BTN_B0005" type="button" class="button" value="刪除" >
					<input id="BTN_B0070" type="button" class="button" value="覆核" >
				</td>
			</tr>
			<tr>
				<td class="tbYellow"  width="20%">基準代碼</td>
				<td class="tbYellow2" width="30%">
					<select id="BASE_CODE">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${BASE_CODE_LIST}">
							<option value="${map.key}">${map.key}_${map.value}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" width="20%">生效日期</td>
				<td class="tbYellow2"  width="30%">				
					<input id="BEGIN_DATE" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" value="<c:out value="${BEGIN_DATE}"/>" datatype="ROCDate">
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BEGIN_DATE'))">

				</td>				
			</tr>
			<tr>
				<td class="tbYellow">基準利率</td>
				<td class="tbYellow2" colspan="3">
					<input id= "BASE_RATE" type="text" class="textBox2" size="6"/>
				</td>						
			</tr>
			<c:if test='${ACTION_TYPE eq "Q"}'>
				<tr>
					<td class="tbYellow">序號</td>
					<td class="tbYellow2">
						<span id = "SER_NO_SPAN"></span>
					</td>
					<td class="tbYellow">異動類別</td>
					<td class="tbYellow2">
						<span id='CHG_KIND_NM_SPAN'></span>
					</td>				
				</tr>
			</c:if>
			<tr>
				<td class="tbYellow">作業人員</td>
				<td class="tbYellow2">
					<span id='INPUT_NM_SPAN'></span>
				</td>
				<td class="tbYellow">作業日期</td>
				<td class="tbYellow2">
					<span id='INPUT_DATE_SPAN'></span>				
				</td>				
			</tr>
			<tr>
				<td class="tbYellow">覆核人員</td>
				<td class="tbYellow2">
					<span id='CONFIRM_NM_SPAN'></span>					
				</td>
				<td class="tbYellow">覆核日期</td>
				<td class="tbYellow2">		
					<span id='CONFIRM_DATE_SPAN'></span>								
				</td>				
			</tr>
			<tr>
				<td colspan="4" align="center">					
					<input id="BTN_back" type="button" class="button" value="上一頁" > 
				</td>
			</tr>
			</form>	
	</table>	
</body>
</html>	