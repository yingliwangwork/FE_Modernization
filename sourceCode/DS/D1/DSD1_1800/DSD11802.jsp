<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD11802.jsp
作者：黃子玹 
功能：新增修改催收地址電話擔保品作業
完成：2013/8/

[20240327]難字
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	      <%-- 地址用 --%>

<%-- [20240327]難字 --%>
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

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD11802().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSD11802(){

	var LOAN_ID = '${LOAN_ID}';
	var URGE_ADDR;	
	//var valid1,valid2;	
				
	function buttonAuth(){
		var authButtons = {	
			B0003:"btn_insert",
			B0004:"btn_update"
		};
		<dz:grantButtons FUNC_ID="DSD11802" />
	}
	
	
	
	//畫面檢核
	function initValidation(){
		Validation.addAllThese([	
			
			['validate-select', '', 
				function(v,elm){		
					return  elm.selectedIndex > 0;							
				}
			]
			/*
			,[ 'checkID',  '身份證字號格式錯誤',
				function(v){  
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v );
				}
			]*/
		]);	
		//valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
		//valid1.define('required' , [{ id : "URGE_ADDR_INPUT_ADDR" ,errMsg : '催收地址不可空白!' }] );
		//valid1.define('required' , [{ id : "URGE_TEL" ,errMsg : '催收電話不可空白!' }] );
		//valid1.define('required' , [{ id : "GUARANTEE" ,errMsg : '擔保品現況不可空白!' }] );
		//valid1.define('validate-select' , [{ id : "CHECK_LEV" ,errMsg : '請選擇查看人職稱!' }] );
		
		//valid1.define('required' , [{ id : "CHECK_NAME" ,errMsg : '查看人姓名不可空白!' }] );
		//valid1.define('required' , [{ id : "CHECK_ID" ,errMsg : '查看人ID不可空白!' }] );
		//valid1.define('required' , [{ id : "CHECK_ID" ,errMsg : '查看人ID輸入有誤!' }] );
		
		//valid2 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
		//valid2.define('required' , [{ id : "URGE_ADDR_INPUT_ADDR" ,errMsg : '催收地址不可空白!' }] );
		//valid2.define('required' , [{ id : "URGE_TEL" ,errMsg : '催收電話不可空白!' }] );
		//valid2.define('required' , [{ id : "GUARANTEE" ,errMsg : '擔保品現況不可空白!' }] );
		//valid2.define('validate-select' , [{ id : "CHECK_LEV" ,errMsg : '請選擇查看人職稱!' }] );		
		//valid2.define('required' , [{ id : "CHECK_NAME" ,errMsg : '查看人姓名不可空白!' }] );
		//valid2.define('required' , [{ id : "CHECK_ID" ,errMsg : '查看人ID不可空白!' }] );
	
	}


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1802/" + actionName,
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

	var actions = {			
		
		//查詢
		doQuery : function(event) {

			
			
			ajaxPost( 'query',{LOAN_ID:LOAN_ID},
				function(resp){
					$('btn_insert').disable();
					var rtnMap = resp.rtnList[0] || '';
					
					$('LOAN_ID').update(LOAN_ID);
					
					$('table').select('input[type="text"]','select').each(function(it){
						var v = rtnMap[it.id];
						var ID = it.id;						
						if(Object.isUndefined(v)) return;			
						if( v == null || (Object.isString(v) && v.blank()) ){
							it.value = '';		
						}else{
							it.setValue(v);	
						}				
					});
					
					URGE_ADDR.setINPUT_ADDR(rtnMap['URGE_ADDR']);	
				},function(resp){
				
					//查無資料，修改disable、新增enable
					$('btn_update').disable();						

				}					
			);		
		}
		//新增					
		,doInsert : function(event){	

			
			//valid2.reset();
			//if(!valid1.validate()){			
			//	return;
			//}

			var reqMap = actions.storeReqMap();			
			
			ajaxPost( 'insert',	{reqMap: Object.toJSON(reqMap)},
				function(resp){	
					
							
				}
			);					
					
		}
		//將畫面存成reqMap
		,storeReqMap: function(){
			var reqMap = {};		
			
			$$('#table input[type =text]','#table select').each(
				function (elem){
					var tagName = elem.tagName;
					reqMap[elem.id] =  elem.value || '';					
											
				}
			)
			reqMap['LOAN_ID'] = LOAN_ID;
			reqMap['URGE_ADDR'] = URGE_ADDR.getINPUT_ADDR();
			
			return reqMap;
			
		}	
		//修改
		,doUpdate : function(event){

				//valid1.reset();
				//if(!valid2.validate()){			
				//	return;
				//}
				
				var reqMap = actions.storeReqMap();			
	
				ajaxPost( 'update',	{reqMap: Object.toJSON(reqMap)},
				function(resp){
						
								
				}				
			);		
		}
		
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD11802" , "催收作業" , "新增修改催收地址、電話、擔保品作業",0,true);
			
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
				
			$('btn_insert').observe('click',actions.doInsert);
			$('btn_update').observe('click',actions.doUpdate);	
			
			//產生地址下拉選單群
			URGE_ADDR = new DSZ01000($('URGE_ADDR'), '1');	 //1:for3碼郵遞區號地址輸入
			
			if(LOAN_ID != ''){
				actions.doQuery();
			}
			initValidation();
			buttonAuth();
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSD11801
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td align="center" colSpan="4">					
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>
					<input id = "btn_update" type = "button" class = "button" value = "修改"/>	
				</td>
			</tr>			
			<tr>					
				<td class="tbYellow" width= "15%" align="left">貸款帳號</td>
				<td class="tbYellow2" width ="85%" colSpan="3">
					<span id="LOAN_ID">${LOAN_ID}							
				</td>					
			</tr>
			<tr>					
				<td class="tbYellow" width= "15%" align="left">催收地址</td>
				<td class="tbYellow2" id ="URGE_ADDR" width ="40%" alt="ch">		<%-- [20240327]難字 --%>									
				</td>
				<td class="tbYellow" width= "15%" align="left">催收電話</td>
				<td class="tbYellow2" width ="30%">
					<input id="URGE_TEL" type="text" class="textBox2" size="30" maxlength="30">							
				</td>	
			</tr>
			<tr>					
				<td class="tbYellow" align="left">擔保品現況</td>
				<td class="tbYellow2">
					<input id="GUARANTEE" type="text" class="textBox2" size="50" maxlength="50">							
				</td>
				<td class="tbYellow" align="left">查看人職稱</td>
				<td class="tbYellow2" >	
					<select id ="CHECK_LEV" class ="textBox2">
						<c:forEach items="${CHECK_LEV_List}" var="map">
							<option value ='${map.key}'>${map.value}</option>
						</c:forEach>	
					</select>				
				</td>	
			</tr>
			<tr>					
				<td class="tbYellow" align="left">查看人姓名</td>
				<td class="tbYellow2">
					<input id="CHECK_NAME" type="text" class="textBox2" size="14" maxlength="12" value=${UserName} alt="ch">	<%-- [20240327]難字 --%>						
				</td>
				<td class="tbYellow" align="left">查看人ID</td>
				<td class="tbYellow2">
					<input id="CHECK_ID" type="text" class="textBox2" size="12" maxlength="10" value=${UserID}>							
				</td>
			</tr>
			<tr>					
				<td class="tbYellow" align="left">備註</td>
				<td class="tbYellow2" colspan="3">
					<input id="NOTE" type="text" class="textBox2" size="100" maxlength="100">							
				</td>
				
			</tr>	
				
		</table>
	</form>
</body>
</html>		