<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ page import="com.cathay.common.util.trx.*"%>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
	<title>ATA08120</title>
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

			
	// 按鈕：【新增】		
	function doInsert(){	
		var validator = new Validator();
		validator.errHandler = new AlertHandler();
		
		var SRC = document.getElementById("SRC_NEW");
		var TIMEOUT = document.getElementById("TIMEOUT_NEW");
		var DATA_TIMEOUT = document.getElementById("DATA_TIMEOUT_NEW");
		var TYPE = document.getElementById("TYPE_NEW");
		var FTP_HOST = document.getElementById("FTP_HOST_NEW");
		var CONNECTION = document.getElementById("CONNECTION_NEW");
		var RETRY = document.getElementById("RETRY_NEW");
		CONNECTION.value = CONNECTION.value.toUpperCase();
		// 參數檢核
		if(SRC.value.trim() == ""){
			validator.define("SRC_NEW", '契約來源', '契約來源必須輸入', 'string','1');
		}
		if(TIMEOUT.value.trim() == ""){
			validator.define("TIMEOUT_NEW", '連線等候時間', '連線等候時間必須輸入', 'string','1');
		}else{
			validator.define("TIMEOUT_NEW", '連線等候時間', '連線等候時間必須輸入數字', 'chkNum');
		}
		if(DATA_TIMEOUT.value.trim() == ""){
			validator.define("DATA_TIMEOUT", '資料等候時間', '資料等候時間必須輸入', 'string','1');
		}else{
			validator.define("DATA_TIMEOUT", '資料等候時間', '資料等候時間必須輸入數字', 'chkNum');
		}
		if(CONNECTION.value.trim() == ""){
			validator.define("CONNECTION_NEW", '公會連線方式', '公會連線方式必須輸入', 'string','1');
		}
		if(FTP_HOST.value.trim() == ""){
			validator.define("FTP_HOST_NEW", 'FTP登入帳號', 'FTP登入帳號必須輸入', 'string','1');
		}
		if(RETRY.value.trim() == ""){
			validator.define("RETRY_NEW", '重試次數', '重試次數必須輸入', 'string','1');
		}else{
			validator.define("RETRY_NEW", '重試次數', '重試次數必須輸入數字', 'chkNum');
		}
		if(!validator.validate()){	
			return false;
		}
			new Ajax.Request(
				"<%=dispatcher%>/ATA0_8120/insert", 
				{
					asynchronous:false,
					parameters:Form.serialize("form1"),
				 	onSuccess: function(XHT, resp){
					 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
				 		
				 		if(CSRUtil.isSuccess(resp)){
							alert("公會通報設定新增成功");
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
							frm.submit();
						
						}else{
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
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
				"<%=dispatcher%>/ATA0_8120/doDelete", 
				{
					asynchronous:false,
					parameters:Form.serialize("form1"),
				 	onSuccess: function(XHT, resp){
					 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
				 		
				 		if(CSRUtil.isSuccess(resp)){
							alert("公會通報設定刪除成功");
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
							frm.submit();
						
						}else{
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
							frm.submit();
						}
				 	}
				}	
			);
		}
	}
	function chkNum(obj){
		if(isNaN(obj)){
			return false;
		}
		return true;
	}

	// 按鈕：【修改】		
	function doUpdate(index){
	
		// 修改資料列數
		document.getElementById("index").value = index;
	
		var validator = new Validator();
		validator.errHandler = new AlertHandler();
		
		var TIMEOUT = document.getElementsByName("TIMEOUT");
		var DATA_TIMEOUT = document.getElementsByName("DATA_TIMEOUT");
		var ACTION = document.getElementsByName("ACTION");
		var CONNECTION = document.getElementsByName("CONNECTION");
		var FTP_HOST = document.getElementsByName("FTP_HOST");
		var TYPE = document.getElementsByName("TYPE");
		var RETRY = document.getElementsByName("RETRY");		
		CONNECTION[index].value = CONNECTION[index].value.toUpperCase();
		// 參數檢核：修改
		if(TIMEOUT[index].value.trim() == ""){
			validator.define(TIMEOUT[index].id, '連線等待時間', '連線等待時間必須輸入', 'string','1');
		}else{
			validator.define(TIMEOUT[index].id,"連線等待時間 ","連線等待時間必須輸入數字","chkNum");
		}
		if(DATA_TIMEOUT[index].value.trim() == ""){
			validator.define(DATA_TIMEOUT[index].id, '資料等待時間', '資料等待時間必須輸入', 'string','1');
		}else{
			validator.define(DATA_TIMEOUT[index].id,"資料等待時間 ","資料等待時間必須輸入數字","chkNum");
		}
		if(CONNECTION[index].value.trim() == ""){
			validator.define(CONNECTION[index].id, '公會通報方式', '公會通報方式必須輸入', 'string','1');
		}
		if(FTP_HOST[index].value.trim() == ""){
			validator.define(FTP_HOST[index].id, 'FTP登入帳號', 'FTP登入帳號必須輸入', 'string','1');
		}
		if(RETRY[index].value.trim() == ""){
			validator.define(RETRY[index].id, '重試次數', '重試次數必須輸入', 'string','1');
		}else{
			validator.define(RETRY[index].id,"重試次數 ","重試次數必須輸入數字","chkNum");
		}
		if(!validator.validate()){	
			return false;
		}
		
		var agree=confirm("請確認是否要修改?");
		
		if(!agree){
			return false;		
		}else{
			new Ajax.Request(
				"<%=dispatcher%>/ATA0_8120/update", 
				{
					asynchronous:false,
					parameters:Form.serialize("form1"),
				 	onSuccess: function(XHT, resp){
					 	Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
				 		
				 		if(CSRUtil.isSuccess(resp)){
							alert("公會通報設定修改成功");
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
							frm.submit();
						
						}else{
							var frm = document.getElementById("form1");
							frm.action = "<%=dispatcher%>/ATA0_8120/prompt";
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
				<td><div align="right">畫面編號：ATA08120</div></td>
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
									<th width="8%">契約來源</th>
									<th width="10%">連線等候時間(毫秒)</th>
									<th width="10%">資料等候時間(毫秒)</th>
									<th width="10%">作業開關</th>
									<th width="10%">公會連線方式</th>
									<th width="10%">WebService呼叫方法</th>
									<th width="10%">重試次數</th>
									<th width="10%">FTP登入帳號</th>
									<th width="10%">通報種類</th>
									<th width="10%">操作</th>																
								</tr>								
								<tr class="tbYellow2" align="center">
									<td></td>
									<td><input type="text" id="SRC_NEW" name="SRC_NEW" value="" size="10" maxlength="6"/></td>
									<td><input type="text" id="TIMEOUT_NEW" name="TIMEOUT_NEW" value="" size="10" /></td>
									<td><input type="text" id="DATA_TIMEOUT_NEW" name="DATA_TIMEOUT_NEW" value="" size="10" /></td>
									<td>
										<select id="IS_EFFECTIVE_NEW" name="IS_EFFECTIVE_NEW" >
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<td><input type="text" id="CONNECTION_NEW" name="CONNECTION_NEW" value="" size="10" maxlength="1"/></td>
									<td><cathay:converSelect sys="AT" field="ATA08120_ACTION"   name="ACTION_NEW" value=""/></td>
									<td><input type="text" id="RETRY_NEW" name="RETRY_NEW" value="" size="10"  /></td>									
									<td><input type="text" id="FTP_HOST_NEW" name="FTP_HOST_NEW" value="" size="10"  maxlength="1"/></td>
									<td><input type="text" id="TYPE_NEW" name="TYPE_NEW" value="" size="10" maxlength="1"/></td>
									<td><input type="button" id="insertBtn" name="insertBtn" value="新增" class="button" onclick="doInsert()"/></td>
								</tr>							
							</table>
							
							<br><br>							
							
							<!-- FORM1 表格 1-2：操作列------------------------------------------------------------------------------------ -->
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
								<tr class="tbBlue">
									<th width="12%">契約來源中文</th>
									<th width="8%">契約來源</th>
									<th width="10%">連線等候時間(毫秒)</th>
									<th width="10%">資料等候時間(毫秒)</th>
									<th width="10%">作業開關</th>
									<th width="10%">公會連線方式</th>
									<th width="10%">WebService呼叫方法</th>
									<th width="10%">重試次數</th>
									<th width="10%">FTP登入帳號</th>
									<th width="10%">通報種類</th>
									<th width="10%">操作</th>																
								</tr>
								
								<!-- 操作資料 -->
								<c:forEach var="detail" items="${DTAFY001_List}" varStatus="status"> 									
									<tr class="tbYellow2" align="center">
										<td><cathay:conver sys="AT" field="SRC" value="${detail.SRC}"/><input type="hidden" id="index" name="index" value=""/></td>
										<td><c:out value="${detail.SRC}"/><input type="hidden" id="SRC_<c:out value="${status.index}"/>" maxlength="6" name="SRC" value="<c:out value="${detail.SRC}"/>"/></td>
										<td><input type="text" id="TIMEOUT_<c:out value="${status.index}"/>" name="TIMEOUT" value="<c:out value="${detail.TIMEOUT}"/>" size="10" /></td>
										<td><input type="text" id="DATA_TIMEOUT_<c:out value="${status.index}"/>" name="DATA_TIMEOUT" value="<c:out value="${detail.DATA_TIMEOUT}"/>" size="10" /></td>
										<td>
											<select id="IS_EFFECTIVE_<c:out value="${status.index}"/>" name="IS_EFFECTIVE">
												<option value="Y" <c:if test="${detail.IS_EFFECTIVE eq 'Y'}">selected</c:if>>Y</option>
												<option value="N" <c:if test="${detail.IS_EFFECTIVE eq 'N'}">selected</c:if>>N</option>
											</select>
										</td>
										<td><input type="text" id="CONNECTION_<c:out value="${status.index}"/>" name="CONNECTION" value="<c:out value="${detail.CONNECTION}"/>" size="10" maxlength="1"/></td>	
										<td>
											<SELECT id="ACTION_<c:out value="${status.index}"/>" name="ACTION">
												<c:forEach items='${ACTION_Map}' var='map' varStatus="status2">
													<option value="<c:out value='${map.key}' />" <c:if test="${map.key eq detail.ACTION}"> selected </c:if> >${map.value}</option>
												</c:forEach>
											</SELECT>										
										</td>																									
										<td><input type="text" id="RETRY_<c:out value="${status.index}"/>" name="RETRY" value="<c:out value="${detail.RETRY}" />" size="10" /></td>										
										<td><input type="text" id="FTP_HOST_<c:out value="${status.index}"/>" name="FTP_HOST" value="<c:out value="${detail.FTP_HOST}"/>" size="10" maxlength="1"/></td>
										<td><input type="text" id="TYPE_<c:out value="${status.index}"/>" name="TYPE" value="<c:out value="${detail.TYPE}" />" size="10" maxlength="1" /></td>	
										<td>
											<input type="button" id="deleteBtn" name="deleteBtn" value="刪除" class="button" onclick="doDelete(${status.index})"/>
											<input type="button" id="updateBtn" name="updateBtn" value="修改" class="button" onclick="doUpdate(${status.index})"/>
										</td>
									</tr>
								</c:forEach>
								
							</table>	
							
							</form>
							※使用說明:<br>
							1. 通報種類: R=收件，L=承保 (如果是取回作業，這個欄位不會使用)<br>
							2. 公會連線方式: W=Webservice，V=VPN<br>
							3. FTP登入帳號: 1=網路投保，2=批次<br>
							4. 作業開關(正式環境請小心使用): Y->開，N->關(代表直接pass該項公會作業)<br>

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