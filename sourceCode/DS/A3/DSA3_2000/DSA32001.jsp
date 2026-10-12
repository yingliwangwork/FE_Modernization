<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA32001.jsp
作者：李俊德
功能：鑑價初估明細
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>

<script type="text/JavaScript">
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSA32001().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//--------------------------------------------------------------------------
//	以下為DSA32001() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSA32001(){
	
	var grid1;

	var actions = {
	
		// 初估編號超連結(DSA32100)
		doLinkByPreapprNo : function(PREAPPR_NO){
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSA3_2100/prompt";	
			LP_JSON.PREAPPR_NO = PREAPPR_NO; //初估編號
			CSRUtil.linkTo(LP_JSON, 'form1');
		},
		// 上一頁
		doBack : function(){
			CSRUtil.linkBack();
		},
		//調整金額欄位名稱 Q_TYPE
		doChange : function(Q_TYPE){
			var AMT_HEADER = $$('#grid1 th[name=AMT]')[0];
			switch(Q_TYPE) {
				case 1:
					AMT_HEADER.update('初估金額');
					break;
				case 2:
					AMT_HEADER.update('申貸金額');
					break;
				case 3:
					AMT_HEADER.update('核准金額');
					break;
				case 4:
					AMT_HEADER.update('貸放金額');
					break;
			}
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSA32001" , "鑑價作業", "鑑價初估明細" );

			grid1 = new TableUI(
				{	
					table:$('grid1'), allSortable: false, pageSize: 10, overDiv: true, split:["PREAPPR_ADDR"], 
					column:[
						{ header: "送件區部", key: "AREA_NM"},
						{ header: "區域", key: "CRED_DEPT_NM"},
						{ header: "初估編號", key: "PREAPPR_NO",
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByPreapprNo( record.PREAPPR_NO ); };
				                 	return link;
							}
						},
						{ header: "借款人姓名", key: "BORROW_NAME",
						  	render: function(record, value){
								return CSRUtil.maskHandler.getMaskName(value);
						  	}
						},
						{ header: "經手人姓名", key: "AGENT_NM"},
						{ header: "受理進度", key: "APPLY_PROCESS_NM"},
						{ header: "初估金額", key: "AMT", attrs:{ align:'right' },
							render : function(record , value){
								return value ? CSRUtil.$fmt(value, "#,##0") : "0";
							}
						},
						{ header: "擔保品地址", key: "PREAPPR_ADDR", attrs:{ colSpan:7 },
							render : function(record , value){
								return value || '　';
							}
						}
					]
				}
			);
			
			$('btn_back').observe('click', actions.doBack ); // 上一頁按鈕		

			displayMessage();
			
			<c:if test="${not empty rtnList}">			
				grid1.load(${rtnList});
				actions.doChange(${Q_TYPE});
			</c:if>		
			
		}// end initApp()--
	}// end return--
}// end DSA32001

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post"></form>
	<table id='grid1' width="100%"></table>
	<center>
		<input type="button" id="btn_back" value="上一頁" class="button">
	</center>
</body>
</html>
