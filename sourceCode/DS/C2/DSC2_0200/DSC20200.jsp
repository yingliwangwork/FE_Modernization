<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSC20200.jsp
作者：i9300606
功能：核心放款
完成：2011/06/10
-->

<html>	
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>

<script type="text/javascript">

Event.observe(window, 'load', initApp);
Event.observe(window, 'scroll', fix);
Event.observe(window, 'resize', fix);
	
function initApp(){ 
	new UI().init();                
	displayMessage();
}//--------------------------------------------------------------------------
var count = 0;
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	var grid;
	
	//--------------------------------------------------------------------------  
	//UI() private method
	//--------------------------------------------------------------------------  
	
	//--------------------------------------------------------------------------
	/* 查詢 */
	function doQuery(){
		//查詢條件檢核
		if(!doCheck()){return;}
		count = 0;
		ajaxPost('query', $("form").serialize( true ), successAction );
			
	}
	
	// 清空AlterHandler 
	var validator;
	/* 設定此畫面中所有要檢查的欄位 */
	function initValidator(){
		validator = new Validator();  
		validator.errHandler = new AlertHandler();
		validator.define('ACNT_DATE', '帳務日期', '不可空值', 'isNotBlank');
		validator.define('ACNT_DATE', '帳務日期', '應為民國日期', 'isROCdate');
	}
	
	function doCheck(){
		if(validator) validator.errHandler.clear();	
		initValidator();
		return validator.validate();
	}
		
	//--------------------------------------------------------------------------
	//AJAX SuccessAction
	function successAction(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			//alert('11='+Object.toJSON(resp.boList));
			var rtnList = resp.boList;
			var totalList = resp.totalList;
			grid.load( (rtnList) ? rtnList:[],(totalList) ? totalList:[]);
		} else {
			grid.load( [] );
		}
	}
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){

			grid = new TableUI({	
				table: $('grid'), 
				column:[
					{ key: "FND_NM", header: "序號",
                      	render: function( record, value ) {

							count++
							var param = "ACNT_TYPE="+$("ACNT_TYPE").value+"&ACNT_DATE="+record.ACNT_DATE+"&ACNT_DIV_NO="+record.ACNT_DIV_NO+"&SLIP_SET_NO="+record.SLIP_SET_NO+"&SLIP_LOT_NO="+record.SLIP_LOT_NO;
							var url = "${pageContext.request.contextPath}/servlet/HttpDispatcher/DSC2_0200/query1?"+param;
	        				var link = document.createElement( "a" );
	    	                  	link.href = "#";
	                      		link.innerHTML = count;
	                      		link.onclick = function() { popupWin.fullPopup( url ); };
	                      		return link;
						
                      	}
					},
					{ key: "FM_ACNT_DATE", header: "帳務日期" },
					{ key: "ACNT_DIV_NO", header: "製票單位" },
					{ key: "SLIP_SEQ_NO", header: "傳票序號" },
					{ key: "SLIP_SET_NO", header: "傳票組號" },
					{ key: "SLIP_LOT_NO", header: "批號" },
					{ key: "DR_AMT", header: "借方金額" ,
                      	render: function( record, value ) {
	                    	return CSRUtil.$fmt(value,"#,###.####");
                      	}
                    },
					{ key: "CR_AMT", header: "貸方金額" ,
                      	render: function( record, value ) {
	                    	return CSRUtil.$fmt(value,"#,###.####");
                      	}
                    }
					
				]
			});

			$("btnQuery").observe( "click", function( event ) { doQuery(); } );

		}//end init()--
		
	}//end return--

	//-------------------------------------------------------------------------- 
}

<!--全域 函數 UI 與 畫面 公用 Start-------------------------------------------------->
//--------------------------------------------------------------------------
//共用ajaxpost function
function ajaxPost( actionName, params, successAction ) {
	new Ajax.Request( "<%=dispatcher%>/DSC2_0200/" + actionName, { 	
    	parameters: params,
    	onSuccess: successAction
    });
}	
//-------------------------------------------------------------------------- 
function isNotBlank() {
	if (document.form.ACNT_DATE.value == "")
		return false;	
	return true; 

}
//--------------------------------------------------------------------------
</script>

</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<!--此網頁自建使用的JavaScript 放下面 -->
<center>

<!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號--> 
<span id="bar1"	style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img	src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr><td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td></tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24"><div align="center"><font size="-5">●</font></div></td>
				<td><b>收息帳務作業</b></td>
				<td><div align="right">畫面編號：DSC20200</div></td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span>
<!-- Bolck_1_ End-->

<!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<!-- Bolck_3_Start 表單主功能區塊-->
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
							<td class="tbBox2" colspan="2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">
								EIR調整帳務查詢作業
							</td>
						</tr>
						<tr bgcolor=#FFFFFF>
							<td colspan="2">
							<!-- Bolck_4_Start 輸入區塊-->
							<tr bgcolor=#FFFFFF>
								<td>
									<form name="form" id="form" method="post" action="">
										<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table0">
             								<tr>
             									<td class="tbYellow"  width="20%" align="center">帳務日期</td>
                                                <td class="tbYellow2"  width="20%" align="left">&nbsp;&nbsp;
                                                	<input type='text' value='${iniDateROC}' maxlength='7' size="7" id="ACNT_DATE" name = 'ACNT_DATE'/>
                                                </td>
												<td class="tbYellow"  width="20%" align="center">帳務類別</td>
                                                <td class="tbYellow2"  width="20%" align="left">&nbsp;&nbsp;
                                                	<select name="ACNT_TYPE" id="ACNT_TYPE">
                                                	<option value="">請選擇</option>
                                                	<c:forEach var="option" items="${fieldOptionList}">
                                                		<option value="${option.key}" <c:if test="${iniACNT_TYPE eq option.key}"><c:out value=" selected"/></c:if>>${option.key}&nbsp;${option.value}</option>
                                                	</c:forEach>
													</select>
												</td>
												<td class="tbYellow2"  align ="center"><input name="btnQuery" id="btnQuery" type="button" class="button" value="查詢"></td>
											</tr>
										</table>							
										<!-- Query Result (Grid Table) -->
										<table class="grid" id="grid"></table>
										<!--Bolck_4_End-->							
									</form>
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
<!-- Bolck_3_End-->

</center>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</BODY>
</HTML>