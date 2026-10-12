<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	PageUI.createPageWithAllBodySubElement("DSA10600" , "受理作業" , "案件送件確認", 1);
	PageUI.resize(true);
	
	var LP_JSON = CSRUtil.isBackLink('form1');
	if(LP_JSON){
		$('APPLY_DIV').value = LP_JSON.BQ_ARG.APPLY_DIV;
		query();
	}
	
	var APPLY_DIV = '${APPLY_DIV}';
	if(APPLY_DIV != '') {
		$('APPLY_DIV').value = LP_JSON.BQ_ARG.APPLY_DIV;
		query();
	}
	
	new UI().init();
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){

				grid = new TableUI( 
					{
						table: $("grid"),  
						overDiv:false,
						pageSize: 20,	
						<%-- [20240722] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
								<%--
									受理編號	APPLY_ID	rtnMap.APPLY_ID	可超連結
									借款人	BORROW_NAME	rtnMap.BORROW_NAME	
									承辦科別	CRED_DEPT_NM	rtnMap.CRED_DEPT _NM	
									受理日期	APPLY_DATE	rtnMap.APPLY_DATE	
									送件人員	INPUT_NM	rtnMap.INPUT_NM	
									送件日期	INPUT_DATE	rtnMap.INPUT_DATE	
									注意事項	CHK_MSG	rtnMap.CHK_MSG	
									送件確認			若注意事項(CHK_MSG)為空值，則顯示送件按鈕；否則空白
								--%>						
								{header: '受理編號',sortable: true, key:'APPLY_ID',
									render:function(rec,val){
								   		var link = document.createElement( "a" );
				                      	link.href = "#";
				                      	link.innerHTML = val;
				                     	link.onclick = function( event ) { doPopupLink( val ) };
				                      	return link;
									}
			                	},
								{header: '借款人',sortable: true, key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>,
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '承辦科別',sortable: true, key:'CRED_DEPT_NM',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '受理日期',sortable: true, key:'APPLY_DATE',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '送件人員',sortable: true, key:'INPUT_NM', attrs:{style:"font-family:'EUDC'"}<%-- [20240722]難字調整--%>,
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '送件日期',sortable: true, key:'INPUT_DATE',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								<%-- 送件確認:若注意事項(CHK_MSG)為空值，則顯示送件按鈕；否則空白--%>						
								{header: '注意事項',sortable: true, key:'CHK_MSG',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								//20200114 法金系統: bug處理
								{header: '送件確認',sortable: true, 
									input:{
										type:'button', 	
				                		text:'送件確認',
										action : function( node , dataObj , textDiv, record, isOnChange){
											<%-- 送件確認 --%>
									    	send(dataObj[0]);
										},
			                            genRule:function(record , value){
			                                return record['CHK_MSG_BLANK'] == 'true';
			                            } 
				                	}
								}
						]
					}
				);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

<%--
4.	受理編號超連結
4.1	超連結(window open) 至DSA1_1700 (受理資料修正畫面)
4.2	傳入參數：APPLY_ID= rtnMap.APPLY_ID
--%>
function doPopupLink(APPLY_ID){

	var LP_JSON = LP_JSON ? LP_JSON : {};	// 紀錄連結資訊Object
	LP_JSON.FROM_TRX = 'DSA1_1700';			// 從這頁出發
	LP_JSON.IS_BACK = "N";					// 是否從別頁回來
	LP_JSON.BACK_TRX = 'DSA1_1700';			// 回這頁
	LP_JSON.BACK_ACTION = 'prompt';			// 回來要先做的事
	LP_JSON.TABLE_INFO = grid.getTableInfo();
	LP_JSON.APPLY_ID = APPLY_ID;			// 回來要先做的事
	LP_JSON.action = '<%=dispatcher%>/DSA1_1700/prompt';
	LP_JSON.BQ_ARG = {      
		APPLY_DIV:$F('APPLY_DIV')
	};
	CSRUtil.linkTo(LP_JSON, 'form1');
	
}


<%--
	查詢作業
--%>
function query() {

	if($F('APPLY_DIV') == '') {
		alert("請輸入查詢單位");
		return;
	}
	
	$('APPLY_DIV').value = $('APPLY_DIV').value.toUpperCase();
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0600/doQuery", 
	{
			parameters:{"APPLY_DIV":$F('APPLY_DIV')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					grid.load(resp.returnList);
					$('APPLY_DIV_NM').innerText = resp.APPLY_DIV_NM;
				}else{
					if(resp.DATA_NOT_FOUND){
						grid.load(resp.returnList);
						$('APPLY_DIV_NM').innerText = "";
					}						
				}
				PageUI.resize(true);
			}
	});

}

<%--
	新增作業
--%>
function send(targetRow) {
	var APPLY_ID = targetRow.APPLY_ID;
	var INPUT_ID = targetRow.INPUT_ID;
  	new Ajax.Request("<%=dispatcher%>/DSA1_0600/doSend", 
	{
  		//[20211201] fix bug，多傳查詢參數，讓重查可正常作業
			parameters:{"APPLY_ID":APPLY_ID,"INPUT_ID":INPUT_ID,"APPLY_DIV":$F('APPLY_DIV')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					grid.load(resp.returnList);
					$('APPLY_DIV_NM').innerText = resp.APPLY_DIV_NM;
				}else{
					if(resp.DATA_NOT_FOUND){
						grid.load(resp.returnList);
						$('APPLY_DIV_NM').innerText = "";
					}						
				}
			}
	});
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
					
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<form name="form1" id="form1" method="post">			
			<input type="hidden" name="APPLY_ID" id="APPLY_ID" value="">
			<input type="hidden" name="INPUT_ID" id="INPUT_ID" value="">
            <input type="hidden" name="IS_BACK" id="IS_BACK" value="N"/>
			<input type="hidden" name="LP_JSON" id="LP_JSON" />
		
			<!-- Block_4_Start 輸入區塊-->
			<tr>
				<td width="15%" class="tbYellow">查詢單位</td>
				<td width="20%" class="tbYellow2" >
                          <input type="text" class="textBox" id="APPLY_DIV" name="APPLY_DIV" size="7" maxlength="5" >
                          <SPAN ID = "APPLY_DIV_NM"></SPAN>
                </td>
                <td width="65%" class="tbYellow2" >
					<input id="btnQuery" name="btnQuery" onClick="query()" type="button" class="button" value="查詢"> 
				</td>	
			</tr>
			</form>
		</table>

		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td colspan='3'>
					<table id='grid' class="grid"></table>
				</td>
			</tr>			
		</table>

	</body>
</html>
