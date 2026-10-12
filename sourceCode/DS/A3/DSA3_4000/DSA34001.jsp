<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA34001.jsp
作者：李曼華
功能：命中率統計明細
完成：2021/07/01

[20210715][20210714094025] :
          1.新增統計明細表格欄位
[20240930]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>  
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>      
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>       
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">
Event.observe(window, 'load', new DSA34001().initApp);

function DSA34001(){
	var grid1;
	var rtnList = <c:out value='${rtnList}' default='[]' escapeXml='false' />;

	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement(
					'DSA34001',
					'鑑價作業',
					'模型統計明細'
				);

			grid1=new TableUI({
				table:$('grid1'), allSortable: true, split:['PRICE_S'],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{ header: "序號" , key:'SN', 
		                    	render : function(rec, val , sn){
		                    		return sn;
		                    	},attrs:{rowSpan:2} 
		                    },
	                { header:"受理編號",key:'APPLY_ID',attrs:{rowSpan:2 }},
	                { header:"建築型態",key:'USE_FOR',attrs:{rowSpan:2 }},
	                { header:"自動估價建議價格",key:'PRICE_A', 
	                	render: function(record,value){
                        return  MoneyFormat(value) ;
                    }},
	                { header:"是否落入區間",key:'REGION_A'},
	                { header:"價格落差",key:'GAP_VALUE_A', 
	                	render: function(record,value){
	                        return  MoneyFormat(value) ;
	                    }},
		            { header:"價格落差原因一",key:'GAP_NOTE1_A'},
		            { header:"價格落差原因二",key:'GAP_NOTE2_A'},
		            { header:"單價(萬/坪)",key:'PER_PRICE',attrs:{rowSpan:2 }},
		            { header:"總價(萬)",key:'TOTAL_PRICE',attrs:{rowSpan:2 }},
		            { header:"面積(坪)",key:'AREA',attrs:{rowSpan:2 }},
		            { header:"案件類別",key:'APPLD_TYPE',attrs:{rowSpan:2 }},
		            { header:"縣市",key:'CITY_NAME',attrs:{rowSpan:2 }},
	                { header:"行政區",key:'DISTRICT',attrs:{rowSpan:2 }},
	                <%--[20210715][20210714094025]--%>
	                { header:"受理進度",key:'APPR_PROCESS',attrs:{rowSpan:2 }},
	                { header:"派件日期",key:'APPLY_DATE',attrs:{rowSpan:2 },sortRule:"date"},
	                { header:"覆核(退件)日期",key:'REPORT_DATE',attrs:{rowSpan:2 },sortRule:"date"},
	                { header:"鑑價組",key:'APPR_GROUP',attrs:{rowSpan:2 }},
	                { header:"鑑價員",key:'APPR_NM',attrs:{rowSpan:2},
	                	render: function(rec, val){
	                		<%--[20240930]難字調整 --%> 
	                		return new Element('span', { style:"font-family:'EUDC'" }).update(val);
	                	}
	                },
	                { header:"覆核組長",key:'CAPT_NM',attrs:{rowSpan:2},
		                render: function(rec, val){
		                	<%--[20240930]難字調整 --%> 
	                		return new Element('span', { style:"font-family:'EUDC'" }).update(val);
	                	}
	                },
	                { header:"建議案例建議價格",key:'PRICE_S', 
	                	render: function(record,value){
	                        return  MoneyFormat(value) ;
	                    }},
	                { header:"是否落入區間",key:'REGION_S'},
	                { header:"價格落差",key:'GAP_VALUE_S', 
	                	render: function(record,value){
	                        return  MoneyFormat(value) ;
	                    }},
	                { header:"價格落差原因一",key:'GAP_NOTE1_S'},
	                { header:"價格落差原因二",key:'GAP_NOTE2_S'}
	                   
				]});
			grid1.load(rtnList||[]);
			displayMessage();
			
		}

	};
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post">
		<table id='grid1' width="100%"></table>
		
	</form>
	
</body>
</html>
