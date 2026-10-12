<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB50300.jsp
作者：王文進
功能：個件人工入檔。
完成：2012/05/29
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB50300 = new DSB50300();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB50300.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB50300(){
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0121:"btn_insert"<%--輸入--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB50300" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	//查詢變數
	var sendRecord
	//建檔變數
	var insertRecord
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkInpute',  '請輸入正確受理編號!!',
				function(v){
					return 	v.length!=11 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkInpute" , { id: "APPLY_ID" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB5_0300/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$("OLD_APPLY_ID").innerHTML = rtnMap.OLD_APPLY_ID ? rtnMap.OLD_APPLY_ID : '';
					$("LOAN_ID").innerHTML = rtnMap.LOAN_ID ? rtnMap.LOAN_ID : '';
					$("REMIT1_DATE").innerHTML = rtnMap.REMIT1_DATE ? Date.toInputROC(rtnMap.REMIT1_DATE || "","/") : '';
					$("IS_C100_CD").innerHTML = rtnMap.IS_C100_CD ? rtnMap.IS_C100_CD : '';
					insertRecord = rtnMap;
				},
				function(resp){
					//失敗把前次內容清掉 
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$("OLD_APPLY_ID").innerHTML = '';
					$("LOAN_ID").innerHTML = '';
					$("REMIT1_DATE").innerHTML = '';
					$("IS_C100_CD").innerHTML = '';
					insertRecord = rtnMap;
				}
			);		
		},
		
		//建檔資料
		doInsert : function(event){	
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			if(!insertRecord || !insertRecord.OLD_APPLY_ID || insertRecord.OLD_APPLY_ID != $('APPLY_ID').value){
				return alert("請先查詢再作建檔!");
			}
			
			if(insertRecord.IS_C100 == '1'){
				return alert("資料已入收息主檔，不必再建檔!");
			}

			//發送ajax
			ajaxPost( 'insert' , {'sendRecord' : Object.toJSON(sendRecord),'insertRecord' : Object.toJSON(insertRecord)	},
				function(resp){
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					$("OLD_APPLY_ID").innerHTML = rtnMap.OLD_APPLY_ID ? rtnMap.OLD_APPLY_ID : '';
					$("LOAN_ID").innerHTML = rtnMap.LOAN_ID ? rtnMap.LOAN_ID : '';
					$("REMIT1_DATE").innerHTML = rtnMap.REMIT1_DATE ? Date.toInputROC(rtnMap.REMIT1_DATE || "","/") : '';
					$("IS_C100_CD").innerHTML = rtnMap.IS_C100_CD ? rtnMap.IS_C100_CD : '';
					insertRecord = rtnMap;
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {};
		sendRecord.APPLY_ID	= $('APPLY_ID').value; // 受理編號
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB50300", "匯款作業", "個件人工入檔", 1);			

				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_insert").observe("click", buttons.doInsert );
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				buttonAuth();
				
			}
	};	
};

</script>
</head>
<body>	
<form id="form1" name="form1">		
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="12%">
			受理編號
		</td>
		<td class="tbYellow2">
			<input id="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
		</td>
		<td class="tbYellow2" align="center">
			<input type="button" class="button" id="btn_query" value="查詢">
		</td>
	</tr>
	<tr>
		<td align="center" colspan="3">
			<input type="button" class="button" id="btn_insert" value="建檔">
		</td>
		
	</tr>
	</table>
</form>	
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td>
			<table id="table_A" name="table_A" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<tr>
					<td class="tbBlue" align="center" width="13%">受理編號</td>
					<td class="tbBlue2" align="center" width="12%" id="OLD_APPLY_ID"></td>
					<td class="tbBlue" align="center" width="13%">貸款帳號</td>
					<td class="tbBlue2" align="center" width="12%" id="LOAN_ID"></td>
					<td class="tbBlue" align="center" width="13%">一匯日期</td>
					<td class="tbBlue2" align="center" width="12%" id="REMIT1_DATE"></td>
					<td class="tbBlue" align="center" width="13%">是否已入收息主檔</td>
					<td class="tbBlue2" align="center" width="12%"><font color="red"  id="IS_C100_CD"></font></td>
				</tr>
				<tr>
	                <td class="tbYellow" align="left" colspan="8">
					＊針對<font color=red>當日匯款結帳件，若客戶當日來做清償</font>，請先到本作業進行人工入主檔作業。<br>
					＊客戶若<font color=red>非</font>匯款當日要做清償，<font color=red>晚上會進行批次入主檔作業</font>，不需要人工入主檔。
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>