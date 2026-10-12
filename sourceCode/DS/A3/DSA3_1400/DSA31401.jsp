
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA31401.jsp
作者：張智翔
功能：鑑價件數明細查詢。
完成：2012/04/10
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSA31401 = new DSA31401();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA31401.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31401(){	
	
	var grid;			
	
	var reqMap = <c:out value = "${reqMap}" default = "{}" escapeXml = "false" />;
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSA3_1401/" + actionName,
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
		doQuery : function(){		
			//發送ajax
			ajaxPost( 'query' , {reqMap : Object.toJSON(reqMap)	},
				function(resp){	
					grid.load(resp.rtnList);					
					
				},
				function(resp){					
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		
		}
	}		
	

	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement( "DSA31401" , "鑑價作業", "鑑價件數明細查詢");
	
				grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true ,
					column:	[		
						{header: "受理編號 ",key: "APPLY_ID"},
						{header: "案件類別 ",key: "APPR_TYPE_NM"},
						{header: "借款人姓名 ",key: "CASE_NAME"},
						{header: "受理進度 ",key: "APPR_PROCESS_NM"},
						{header: "派件日期 ",key: "APPLY_DATE",
							render : function(rec , val){
								return Date.toInputROC(val || "","/");
							}			
						},
						{header: "覆核(退件)日期 ",key: "REPORT_DATE",
							render : function(rec , val){
								return Date.toInputROC(val || "","/");
							}
						},
						{header: "郵遞區號 ",key: "GAGE_ZIP"},
						{header: "轉換件數 ",key: "APPR_COUNT"},
						{header: "鑑價組 ",key: "APPR_GROUP_NM"},
						{header: "鑑價員",key: "APPR_NM",
							render : function(rec , val){
								if (rec.IS_AUTOAPPR=='2'){
									return "智能件"};
								return val;
								}
							}
								
					]
				});	
				
				buttons.doQuery();
				
				fix();

				displayMessage();				
			
			}
	};	
};

</script>
</head>
<body>		
	<table id='grid' width="100%"></table>	
</body>
</html>