<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA32400.jsp
作者：i9300610 劉金宜 
功能：聯合鑑價中心案件查詢主程式
完成：2012/11/21
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
<script type='text/javascript'>
<!--

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA32400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA32400(){

<c:if test="${empty unauthorized}">
	
	//==========================================================================
	// 按鈕授權
	//==========================================================================
	var buttonAuth = function() {
		var authButtons = { 	
		
		};
		<dz:grantButtons FUNC_ID="DSA32400" ignored="false"/>
	};

	//==========================================================================
	// 功能按鈕
	//==========================================================================
	var actions = {
		//--------------------------------------------------------------------------
		// 共用的Ajax
		//--------------------------------------------------------------------------
		ajaxPost : function( actionName, params, successAction, errorAction ){	
			new Ajax.Request(
				'<%=dispatcher%>/DSA3_2400/' + actionName,
				{	method: "post", parameters: params,
					onSuccess:function(resp){
						var json = resp.responseJSON;
						if(CSRUtil.isSuccess(json)) {
							successAction( json ); 
						}else{
							if( errorAction ){
								errorAction(json);
							}
						}
					}	
				}
			);	
		},
		//--------------------------------------------------------------------------
		//傳回的資料
		//--------------------------------------------------------------------------
		getData : function(ActionType){
			var infoData = {
				ActionType : ActionType, //交易種類 01:一般件價報告,02:土建融鑑價報告,03:土建融鑑價報告,04:銀行案件查詢
				BankDept : '${BankDept}', //查詢分行代號
				CheckId : '${CheckId}', //是否總行人員查詢 1:是,0:否
				CathayNo : '${CathayNo}', //案件編號
				QueryId : '${QueryId}', //查詢人員ID
				method : '${method}', //
				requestStr : '${requestStr}' //
			}
			return {'infoData': Object.toJSON(infoData)};
		},
		//--------------------------------------------------------------------------
		// 查詢 : 將成交單序號查詢憑證資料檔(DTLDL011)資料帶出 
		//--------------------------------------------------------------------------
		doQuery : function(ActionType){

			actions.ajaxPost( 'query' , actions.getData(ActionType) ,
				
				// 指正確執行後, jsp要做何動作
				function(resp){	
					
					var LP_JSON= {
						QueryId : '${QueryId}', //查詢人員ID
						APPLY_ID : '${CathayNo}', //案件編號
						BankDept : '${BankDept}', //查詢分行代號
						CheckId  : '${CheckId}' //是否總行人員查詢 1:是,0:否
					};
			
					if('01' === ActionType){ //一般鑑價報告
					
						LP_JSON.action = '<%=dispatcher%>/DSA3_2400/promptToDSA3_0500';
					}else if('02' === ActionType){ //土建融鑑價報告
						
						LP_JSON.action = '<%=dispatcher%>/DSA3_2400/promptToDSA3_0600';
					}else if('03' === ActionType){ //整批件鑑價報告
					
						LP_JSON.action = '<%=dispatcher%>/DSA3_2400/promptToDSA3_0700';	
					}else if('04' === ActionType){ //銀行案件查詢
					
						LP_JSON.action = '<%=dispatcher%>/DSA3_2400/promptToDSA3_1100';						
					}else{
						alert('查詢之交易種類有誤');
						return;
					}
					
					CSRUtil.linkTo(LP_JSON, 'form1');
				}
			);	
		}
    };
</c:if>
	return{
		initApp : function() {
			PageUI.createPageWithAllBodySubElement('DSA32400','鑑價作業', '聯合鑑價中心');
			<c:if test="${empty unauthorized}">
			//交易種類 01:一般件價報告,02:土建融鑑價報告,03:土建融鑑價報告,04:銀行案件查詢
			actions.doQuery('${ActionType}');

			buttonAuth();
			</c:if>
			
            fix();
			
            displayMessage();			
        }
	};//end return
};
// -->
</script>
</head>
<body>
<form id="form1" name="form1" target="showTableUI" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" enctype="multipart/form-data"  action="">
</form>
</body>
</html>
