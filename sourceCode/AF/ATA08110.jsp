<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ page import="com.cathay.common.util.trx.*"%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
	<title>ATA08110</title>
	<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

	<script src="<%=htmlBase%>/CM/js/Validator.js"></script><!-- 檢核輸入參數 -->
	<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!-- alert 訊息 -->
	<script src="<%=htmlBase%>/CM/js/utility.js"></script><!-- 判斷 button -->
	<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- Ajax1 -->
	<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- Ajax2 -->	
	
	<!-- Function -->
	<script>
	
	function initApp(){			
	
	    // 顯示執行結果
		displayMessage();				
	}
			
	function stat(){
		var a = pageYOffset+window.innerHeight-document.bar1.document.height-15
		document.bar1.top = a
		setTimeout('stat()',2)
	}			
			
	function fix(){
		nome=navigator.appName
		if(nome=='Netscape'){
			stat()
		}else{
			var a=document.body.scrollTop-document.all.bar1.offsetHeight+30
			bar1.style.top = a
		}
	}
	
	// 檢核：只能輸入數字
	function doChkNumber(self_obj, content){
		if(isNaN(self_obj.value)){
			alert(content + "限定只能輸入數字，請重新輸入。");
			self_obj.value = "";
		}
	}
			
	// 按鈕：【新增】		
	function doInsert(){	
		var validator = new Validator();
		validator.errHandler = new AlertHandler();
		
		var SRC = document.getElementById("SRC_NEW");
		var TIMEOUT = document.getElementById("TIMEOUT_NEW");
		var URL = document.getElementById("URL_NEW");
		var MAXAMT = document.getElementById("MAXAMT_NEW");
		var CONNECT_TIMEOUT = document.getElementById("CONNECT_TIMEOUT_NEW");
		var RETRY = document.getElementById("RETRY_NEW");
		
		// 參數檢核：新增
		if(SRC.value.trim() == ""){
			validator.define("SRC_NEW", '契約來源', '契約來源必須輸入', 'string','1');
		}
		if(TIMEOUT.value.trim() == ""){
			validator.define("TIMEOUT_NEW", '等待時間', '等待時間必須輸入', 'string','1');
		}
		if(URL.value.trim() == ""){
			validator.define("URL_NEW", '通算網址', '通算網址必須輸入', 'string','1');
		}
		if(MAXAMT.value.trim() == ""){
			validator.define("MAXAMT_NEW", '累計最大保障', '累計最大保障必須輸入', 'string','1');
		}
		if(CONNECT_TIMEOUT.value.trim() == ""){
			validator.define("CONNECT_TIMEOUT_NEW", '連線等候時間', '連線等候時間必須輸入', 'string','1');
		}
		if(RETRY.value.trim() == ""){
			validator.define("RETRY_NEW", '重試次數', '重試次數必須輸入', 'string','1');
		}
		if(!validator.validate()){	
			alert("紅底文字框為必須輸入。")	
			return false;
		}
		
		new Ajax.Request(
			"<%=dispatcher%>/ATA0_8110/insert", 
			{
				asynchronous:false,
				parameters:Form.serialize("form1"),
			 	onSuccess: function(XHT, resp){
				 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
			 		
			 		if(CSRUtil.isSuccess(resp)){
						alert("公會通報設定新增成功");
						var frm = document.getElementById("form1");
						frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
						frm.submit();
					
					}else{
						var frm = document.getElementById("form1");
						frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
						frm.submit();
					}
			 	}
			}	
		);						
	}
	
	// 按鈕：【刪除】
	function doDelete(index){
		
		// 刪除資料列數	
		document.getElementById("index").value = index;				
		
		var agree = confirm("請確認是否要刪除?");
				
		if(!agree){
			return false;
		}else{
			new Ajax.Request(
				"<%=dispatcher%>/ATA0_8110/doDelete", 
				{
					asynchronous:false,
					parameters:Form.serialize("form1"),
				 	onSuccess: function(XHT, resp){
					 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
				 		
				 		if(CSRUtil.isSuccess(resp)){
							alert("公會通報設定刪除成功");
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
							frm.submit();
						
						}else{
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
							frm.submit();
						}
				 	}
				}	
			);
		}
	}
	
	// 按鈕：【修改】		
	function doUpdate(index){
	
		// 修改資料列數
		document.getElementById("index").value = index;
	
		var validator = new Validator();
		validator.errHandler = new AlertHandler();
		
		var TIMEOUT = document.getElementsByName("TIMEOUT");
		var URL = document.getElementsByName("URL");
		var MAXAMT = document.getElementsByName("MAXAMT");
		var CONNECT_TIMEOUT = document.getElementsByName("CONNECT_TIMEOUT");
		var RETRY = document.getElementsByName("RETRY");		
		
		// 參數檢核：修改
		if(TIMEOUT[index].value.trim() == ""){
			validator.define(TIMEOUT[index].id, '等待時間', '等待時間必須輸入', 'string','1');
		}
		if(URL[index].value.trim() == ""){
			validator.define(URL[index].id, '通算網址', '通算網址必須輸入', 'string','1');
		}
		if(MAXAMT[index].value.trim() == ""){
			validator.define(MAXAMT[index].id, '累計最大保障', '累計最大保障必須輸入', 'string','1');
		}
		if(CONNECT_TIMEOUT[index].value.trim() == ""){
			validator.define(CONNECT_TIMEOUT[index].id, '連線等候時間', '連線等候時間必須輸入', 'string','1');
		}
		if(RETRY[index].value.trim() == ""){
			validator.define(RETRY[index].id, '重試次數', '重試次數必須輸入', 'string','1');
		}
		if(!validator.validate()){	
			alert("紅底文字框為必須輸入。")	
			return false;
		}
		
		var agree=confirm("請確認是否要修改?");
		
		if(!agree){
			return false;		
		}else{
			new Ajax.Request(
				"<%=dispatcher%>/ATA0_8110/update", 
				{
					asynchronous:false,
					parameters:Form.serialize("form1"),
				 	onSuccess: function(XHT, resp){
					 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
				 		
				 		if(CSRUtil.isSuccess(resp)){
							alert("公會通報設定修改成功");
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
							frm.submit();
						
						}else{
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8110/prompt";
							frm.submit();
						}
				 	}
				}	
			);
		}
	}					
	</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp()">
<!-- Bolck_1_Start 表單的開頭  功能名稱  畫面編號 ------------------------------------------------------------------------------------------------------ -->
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24"><div align="center"><font size="-5">●</font></div></td>
				<td><b>公會通報設定</b></td>
				<td><div align="right">畫面編號：ATA08110</div></td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> 
<!-- Bolck_1_ End ---------------------------------------------------------------------------------------------------------------------------------- -->

<!-- Bolck_2_Start 空白區塊 版面跳行------------------------------------------------------------------------------------------------------------------ -->
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr><td>&nbsp;</td></tr>
</table>
<!-- Bolck_2_End------------------------------------------------------------------------------------------------------------------------------------ --> 

<!-- Bolck_3_Start 表單主功能區塊 -------------------------------------------------------------------------------------------------------------------- -->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
					<tbody>
						<tr>
							<td class="tbBox2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">公會通報設定</td>
						</tr>
						<tr bgcolor=#FFFFFF>
							<td>
							
							<!-- Bolck_4_Start 輸入區塊 --------------------------------------------------------------------------------- -->
							<form id="form1" name="form1" method="post">
							
							<!-- FORM1 表格 1-1：新增列------------------------------------------------------------------------------------ -->
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr class="tbBlue">
									<th width="12%">契約來源中文</th>
									<th width="7%">契約來源</th>
									<th width="10%">等待時間(毫秒)</th>
									<th width="10%">是否通算</th>
									<th width="21%">通算網址</th>
									<th width="10%">累計最大保障(萬)</th>
									<th width="10%">連線等候時間(毫秒)</th>
									<th width="10%">重試次數</th>
									<th width="10%">操作</th>																
								</tr>								
								<tr class="tbYellow2" align="center">
									<td></td>
									<td><input type="text" id="SRC_NEW" name="SRC_NEW" value="" size="10"/></td>
									<td><input type="text" id="TIMEOUT_NEW" name="TIMEOUT_NEW" value="" size="10" onchange="doChkNumber(this,'等待時間')"/></td>
									<td>
										<select id="CALL_ASSO_NEW" name="CALL_ASSO_NEW" >
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<td><input type="text" id="URL_NEW" name="URL_NEW" size="50" value=""/></td>
									<td><input type="text" id="MAXAMT_NEW" name="MAXAMT_NEW" value="" size="10" onchange="doChkNumber(this,'累計最大保障')"/></td>
									<td><input type="text" id="CONNECT_TIMEOUT_NEW" name="CONNECT_TIMEOUT_NEW" value="" size="10" onchange="doChkNumber(this,'連線等候時間')"/></td>
									<td><input type="text" id="RETRY_NEW" name="RETRY_NEW" value="" size="10" onchange="doChkNumber(this,'重試次數')" /></td>
									<td><input type="button" id="insertBtn" name="insertBtn" value="新增" class="button" onclick="doInsert()"/></td>
								</tr>							
							</table>
							
							<br><br>							
							
							<!-- FORM1 表格 1-2：操作列------------------------------------------------------------------------------------ -->
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr class="tbBlue">
									<th width="12%">契約來源中文</th>
									<th width="7%">契約來源</th>
									<th width="10%">等待時間(毫秒)</th>
									<th width="10%">是否通算</th>
									<th width="21%">通算網址</th>
									<th width="10%">累計最大保障(萬)</th>
									<th width="10%">連線等候時間(毫秒)</th>
									<th width="10%">重試次數</th>
									<th width="10%">操作</th>																
								</tr>
								
								<!-- 操作資料 -->
								<c:forEach var="detail" items="${DTCBZ004_List}" varStatus="status"> 									
									<tr class="tbYellow2" align="center">
										<td><cathay:conver sys="AT" field="SRC" value="${detail.SRC}"/><input type="hidden" id="index" name="index" value=""/></td>
										<td><c:out value="${detail.SRC}"/><input type="hidden" id="SRC_<c:out value="${status.index}"/>" name="SRC" value="<c:out value="${detail.SRC}"/>"/></td>
										<td><input type="text" id="TIMEOUT_<c:out value="${status.index}"/>" name="TIMEOUT" value="<c:out value="${detail.TIMEOUT}"/>" size="10" onchange="doChkNumber(this,'等待時間')"/></td>
										<td>
											<select id="CALL_ASSO_<c:out value="${status.index}"/>" name="CALL_ASSO">
												<option value="Y" <c:if test="${detail.CALL_ASSO eq 'Y'}">selected</c:if>>Y</option>
												<option value="N" <c:if test="${detail.CALL_ASSO eq 'N'}">selected</c:if>>N</option>
											</select>
										</td>
										<td><input type="text" id="URL_<c:out value="${status.index}"/>" name="URL" size="50" value="<c:out value="${detail.URL}"/>"/></td>
										<td><input type="text" id="MAXAMT_<c:out value="${status.index}"/>" name="MAXAMT" value="<c:out value="${detail.MAXAMT}"/>" size="10" onchange="doChkNumber(this,'累計最大保障')"/></td>
										<td><input type="text" id="CONNECT_TIMEOUT_<c:out value="${status.index}"/>" name="CONNECT_TIMEOUT" value="<c:out value="${detail.CONNECT_TIMEOUT}" />" size="10" onchange="doChkNumber(this,'連線等候時間')"/></td>
										<td><input type="text" id="RETRY_<c:out value="${status.index}"/>" name="RETRY" value="<c:out value="${detail.RETRY}" />" size="10" onchange="doChkNumber(this,'重試次數')"/></td>
										<td>
											<input type="button" id="deleteBtn" name="deleteBtn" value="刪除" class="button" onclick="doDelete(${status.index})"/>
											<input type="button" id="updateBtn" name="updateBtn" value="修改" class="button" onclick="doUpdate(${status.index})"/>
										</td>
									</tr>
								</c:forEach>
							</table>	
							
							</form>
							<!-- Bolck_4_End ------------------------------------------------------------------------------------------- -->
							</td>
						</tr>
					</tbody>
				</table>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End--></center>
</body>
</html>