<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC33201.jsp
作者：卓達瑋
功能：卡號交易明細歷史紀錄
完成：2013/05/07
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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSC33201().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC33201(){
	var grid;

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_3201/" + actionName,
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
	};

	// 功能按鈕
	var action = {	
		// 查詢
		doQuery: function() {	
			ajaxPost( 'query', {'ACCOUNT' : '${ACCOUNT}'}
				,function(resp){
				     grid.load(resp.rtnList);
				}
				,function(resp){
                     grid.load([]);
				}
			);
		}
		
	};
    	
	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement( "DSC33201" , "繳款方式", "卡號交易明細歷史紀錄" );
            grid = new TableUI(
				{table: $("grid"), allSortable: false, pageSize: 20,			
				column:[
                    {header:"轉帳帳號",key:"MEMO2_ACCOUNT_OUT"},				
					
					{header:"貸款帳號",key:"LOAN_ID"}
				
				]
			});
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
            action.doQuery();
			//按鈕權限		
			PageUI.resize();	
			displayMessage();
		}
	}

}


</script>



</script>
</head>
<body>

<table id='grid' width="100%"></table>

	



</body>
</html>	