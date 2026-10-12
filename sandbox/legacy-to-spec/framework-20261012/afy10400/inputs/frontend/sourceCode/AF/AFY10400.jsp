<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ include file="/html/CM/header.jsp"%>
<%@ page import="org.apache.commons.collections.map.ListOrderedMap"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/HotKey.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%>
<script language="JavaScript" type="text/JavaScript">

<!--取得唯一不重複的id-->
function get_unique_num(){
	unique_num++;
	return unique_num;
}

function initApp(){
	unique_num = 0;
	tb1 = document.getElementById("table1");
	displayMessage();
}

function doAdd(){
	var tempcount = get_unique_num();
	console.log(tempcount);
	var newRow = tb1.insertRow();
	newRow.id = "table1_row_" + tempcount;
	var newCell;
	var elemStr;
	newCell = newRow.insertCell();
	elemStr = '<input type="button" class="button" value="刪除此列" id="deleleBtn_' + tempcount +'" onclick="doDelete(\'' + tempcount + '\')" >';
	newCell.innerHTML = elemStr;
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '<input type="text" size="12" maxlength="10" name= "I_ID" id="I_ID_' + tempcount + '" class="textBox2" >';
	newCell.innerHTML = elemStr;	
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '<textarea rows="3" cols="30" name= "POLICY_NO" id="POLICY_NO_' + tempcount + '" class="textBox2" >';
	newCell.innerHTML = elemStr;	
	newCell.align="center";
	
	newCell = newRow.insertCell();
	elemStr = '';
	newCell.innerHTML = elemStr;	
	RowColor();
}

function doDelete(key){
	var temp = document.getElementById(("table1_row_" +key));	
	temp.remove();
	RowColor();
}

function doExport(){
	var param = {
		'insrType': $F('insrType'),
    	'prodType': $F('prodType'),
    	'table1_I_ID':[],
    	'table1_POLICY_NOs':[]
	}
	
	var table1_I_ID = document.getElementsByName("I_ID");
	var table1_POLICY_NOs = document.getElementsByName("POLICY_NO");
	for(var i =0; i< table1_I_ID.length ; i++){
		var I_ID = table1_I_ID[i].value;
		var POLICY_NOs = table1_POLICY_NOs[i].value;
		param.table1_I_ID[i]=I_ID;
		param.table1_POLICY_NOs[i]=POLICY_NOs;
		if(I_ID == "" || POLICY_NOs ==""){
			i=i+1;
			alert("第" + i + "列的被保人ID或保單號碼不得為空值，若不需要請刪除該列");
			return;
		}
		for(var j =i+1; j< table1_I_ID.length ; j++){
			var I_ID_2 = table1_I_ID[j].value;
			if(I_ID == I_ID_2){
				alert("被保人ID：" + I_ID + "有重覆出現，請合併在同一列處理");
				return;
			}
		}
	}
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/AFY1_0400/');
	
	ajaxRequest.post('export',Form.serialize('frm'),
	function(resp){
		var fileName = resp.fileName;
		const rtnMap = new Map(Object.entries(resp.rtnMap));
		for(var i =0; i< table1_I_ID.length ; i++){
			var I_ID = table1_I_ID[i].value;
			document.all.table1.rows[i+3].cells[3].innerHTML = rtnMap.get(I_ID);
		}
		console.log('doRPTUtil');
		RPTUtil.downloadFile('${dispatcher}/AFY1_0400/download', { fileName : fileName } , false);
	},function(resp){
		const rtnMap = new Map(Object.entries(resp.rtnMap));
		for(var i =0; i< table1_I_ID.length ; i++){
			var I_ID = table1_I_ID[i].value;
			document.all.table1.rows[i+3].cells[3].innerHTML = rtnMap.get(I_ID);
		}
	});
}

function RowColor(){
    for (i=3; i < document.all.table1.rows.length; i++) {
		if(i%2 == 0){
			document.all.table1.rows[i].bgColor = "#FAFBE1"; //tbYellow2
		}else{
			document.all.table1.rows[i].bgColor = "#EEF1A7"; //tbYellow
		}
    }
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad='initApp()'> 
<span id="bar1" style="position:absolute; left:0; top:0; width:100%; z-index:9; visibility:visible;">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
				<tr>
					<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
				<tr>
					<td width="20" height="24">
						<div align="center"><font size="-5">●</font></div>
					</td>
					<td>公會通報下傳作業</td>
					<td><div align="right">畫面編號：AFY10400</div></td>
				</tr>
			</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif">
			<img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12">
		</td>
		<td width="5" class="tbBox">
			<img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1">
		</td>
	</tr>
</table>
</span>
<table width="100%" height="30" border="0" cellpadding="0"
	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
			<img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top">
						<table width=97% border=0 align=center cellpadding="0" cellspacing="1" bgcolor="#003366">
							<tbody>
								<tr>
									<td class="tbBox2">
										<p><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">公會補通報作業</p>
									</td>
								</tr>
								<tr bgcolor=#FFFFFF>
									<td>
										<table width="100%" border="0" cellspacing="0" cellpadding="5">
											<tr>
												<td>
													<form id="frm" name="frm" method="post">													
													<table  id="table1" width="100%" class="tbBox2">
														<tr>
															<td class="tbYellow2" colspan="4">
																1、此畫面請用<font color='red'>Google Chrome</font>使用<br/>
																2、收承方式、商品屬性，每次只能針對其中一種組合進行下載，若有多種組合下載，需分多次匯出處理<br/>
																3、同一ID查詢多筆保單時，請在保單號碼欄位，輸入多筆且用<font color='red'>Enter</font>來分格
															</td>
														</tr>
														<tr>
															<td class="tbYellow" width="20%" align="center">收承方式</td>
															<td class="tbYellow2" width="20%" style="text-align:left;">
																<select id="insrType" name="insrType">
																	<option value="L" selected>承保</option>
																	<option value="R">收件</option>																	
																</select>																
																
															</td>
															<td class="tbYellow" width="20%" align="center">商品屬性</td>
															<td class="tbYellow2" width="40%" style="text-align:left;">
																<select id="prodType" name="prodType">
																	<option value="AT" selected>個險</option>
																	<option value="BG" >團險</option>
																	<option value="CB" >意外險</option>																	
																</select>																
															</td>
														</tr>
														<tr class="tbBlue">
															<td align="center">刪除</td>
															<td align="center">被保人ID
																<input type="button" id="addBtn" value="新增一列" class="button" onclick="doAdd()">
															</td>
															<td align="center">保單號碼</td>
															<td align="center">匯出結果</td>
														</tr>
														
													</table>
													<table id="table2" width="100%" class="tbBox2">
														<tr>
															<td class="tbYellow2" align="center">
																<input type="button" id="exportBtn" value="匯出檔案" class="button" onclick="doExport()">
															</td>
														</tr>
													</table>
													
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
			</table> 
		</td>
	</tr>
</table>
</body>
</html>
