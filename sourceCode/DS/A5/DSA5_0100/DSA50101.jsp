<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA50101.jsp
作者：謝雅筑
功能：受理進度追蹤畫面列印。
完成：
-->

<fmt:setBundle basename='TextResource' />

<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<STYLE TYPE="text/css">


table.grid {
    font-size: 10pt;
    border:1px solid #000;
    border-collapse: collapse;
    background-color: #FFFFFF;
}

table.grid td {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

table.grid th {
    margin: 0px;
    padding: 2px;
    padding-top: 5px;
    border:1px solid #000;
}

</STYLE>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA50100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA50100(){
	
	var grid;

	function getColumnType(isPrompt){
		var xHeader = '';
		var xKey = '';
		var type1 = $F('TYPE1');
		if(isPrompt ||type1 == '3' || type1 == '4'){
			xHeader = '派件日期';
			xKey = 'ASSIGN_DATE';
		}else{
			xHeader = '送件日期';
			xKey = 'SEND_DATE';				
		}
		
		var cloumnHeader;
		if(isPrompt || type1 != '0'){	//if 查詢項目1下拉選單有輸入
			
			if(type1=='7'){//變更年期異常
			  cloumnHeader  =  	[
			    	{header: "序號" ,key: "SEQ_NO" },
	       			{header: "貸款帳號" ,key: "LOAN_ID" },
	       			{header: "借款人" ,key: "BORROW_NAME" },
	       			{header: "受理進度" ,key: "SPEC_PROCESS_NM" },
					{header: "派件日期" ,key: "ASSIGN_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: "徵信人員" ,key: "CRED_NAME" }
					];			
			}else{
			  cloumnHeader  =  	[
			    	{header: "序號" ,key: "SEQ_NO" },
					{header: "受理編號",key: "APPLY_ID" ,
	              		render:function(record,value){
	              			if(value){
	              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doLink(record.APPLY_ID)});
	              			}	          
	              			return value;
	              		}
	          			},
	       			{header: "借款人" ,key: "BORROW_NAME" },
	       			{header: "受理進度" ,key: "SPEC_PROCESS_NM" },
	       			{header: "貸款種類" ,key: "LOAN_KIND_NM" },
	       			{header: "貸款類別" ,key: "LOAN_TYPE_NM" },
	       			{header: "貸款金額(萬元)" ,key: "LOAN_AMT"  , 
	               		render:function(record,value){
	               		 	return CSRUtil.$fmt(value , '#,###.####')  ;
	               		}
	            	},
					{header: "受理日期" ,key: "APPLY_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: xHeader ,key: xKey , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
					{header: "包裹日期",key: "PACK_DATE" , 
	               		render:function(record,value){
	               			return Date.toROC(value);
	               		}
	            	},
	            	{header: "鑑價輸入日" ,key: "APPR_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: "鑑價覆核日" ,key: "REPORT_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
					{header: "核准日期",key: "AGREE_DATE" , 
	               		render:function(record,value){
	               			if($F('TYPE1') == '5'){
	               				return '-';
	               			}else{
	               		 		return Date.toROC(value);
	               		 	}
	               		}
	            	},
					{header: "徵信人員" ,key: "CRED_NM" },
					{header: "匯款人員" ,key: "REMIT_NM" },
					{header: "鑑價人員" ,key: "APPR_NM" }
					];
			}
				
		}else{//if查詢項目2下拉選單有輸入	
			cloumnHeader  =  	[
				{header: "序號" ,key: "SEQ_NO" },
				{header: "受理編號",key: "APPLY_ID" ,
              		render:function(record,value){
              			if(value){
              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doLink(record.APPLY_ID)});
              			}	          
              			return value;
              		}
          			},
       			{header: "借款人" ,key: "BORROW_NAME" },
       			{header: "貸款種類" ,key: "LOAN_KIND_NM" },
       			{header: "貸款類別" ,key: "LOAN_TYPE_NM" },
       			{header: "貸款金額(萬元)" ,key: "LOAN_AMT"  , 
               		render:function(record,value){
               		 	return CSRUtil.$fmt(value , '#,###.####')  ;
               		}
            	},
				{header: "受理日期" ,key: "APPLY_DATE" , 
               		render:function(record,value){
               		 	return Date.toROC(value);
               		}
            	},
				{header: "包裹日期",key: "PACK_DATE" , 
               		render:function(record,value){
						return Date.toROC(value);
               		}
            	},
				{header: "徵信人員" ,key: "CRED_NM" },
				{header: "匯款人員" ,key: "REMIT_NM" }
			];
		}
		return cloumnHeader;
	}
	
	function doPrint(){
		$$('input').each(function(record){
			record.readOnly = true;
		});

		$$('select').each(function(record){
			record.disabled = true;
		});
				
		window.print();
	}
					
	var actions = {
		
		//查詢
		doQuery:function(){
	    	
	    	var reqMap = commonTools.getInputData();
	    	
			ajaxPost('query',{reqMap:Object.toJSON(reqMap)},
				function(resp){
					actions.loadData(resp.rtnList);
							
					doPrint();
				},
				function(){
					actions.loadData([]);
					doPrint();
				}
			);
			
		},
		
		//受理編號超連結
		doLink:function(apply_id){
		},
		
		//載入查詢資料
		loadData:function(rtnList){
			rtnList = rtnList ? rtnList:[];
			var index = 0;
			rtnList.each(function(map){
				index++;
				map.SEQ_NO = index;
			
			});
			grid = new TableUI ( {
				table: $("grid"),  allSortable:false, overDiv:false, printMode: true,
					column:getColumnType()
				
			});				
			grid.load(rtnList);
			
			$$('.grid page').each(function(page){
				var pageParent = page.parentNode ;
					if(pageParent){
						while( page.firstChild ){
							pageParent.appendChild( page.firstChild );
						}	
						pageParent.removeChild(page);
						pageParent.pageElement = page;
					}					
			});		
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA5_0100/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	

	var commonTools = {			
		
		//取得A區塊資料
		getInputData:function(){
			var dataMap = {};
			$$('#tableA input[type=text]','#tableA select').each(function(o){
				if(o.datatype == 'number'){
					dataMap[o.id] = o.getValue();
				}else{
					dataMap[o.id] = o.value;
				}
			});

			return dataMap;
		}
	};
	
	return{                              
		initApp:function(){

			grid = new TableUI ( {
				table: $("grid"),  allSortable:false, overDiv:false,printMode: true,
					column:getColumnType(true)
				
			});	
		
			autoFormatToNumber();
			displayMessage();
			
			actions.doQuery();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body >
		
<!------------------------ A區--------------------->	
			<div style="text-align: right;">製表日期:${PRINT_TIME}</div>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="grid" id="tableA">
				<form id="form1" name="form1" method="post">
				<tr>
					<td class="tbYellow" width="15%">承辦科別</td>
                    <td class="tbYellow2" width="15%" >
						<select name="CRED_DEPT" id="CRED_DEPT" fieldName="承辦科別">
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}"  <c:if test="${map.key eq CRED_DEPT}">selected</c:if> >${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow" width="15%">徵信人員</td>
                    <td class="tbYellow2" width="15%" >
						<select name="CRED_ID" id="CRED_ID" fieldName="徵信人員">
							<option value="">全部</option>
							<c:forEach var="map" items="${CRED_ID_LIST}">
								<option value="${map.ID}" <c:if test="${map.ID eq CRED_ID}">selected</c:if> >${map.NAME}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
	 			<tr>
	 				<td class="tbYellow" rowSpan="2">查詢項目</td>
                    <td class="tbYellow2" colspan="3">
						<select name="TYPE1" id="TYPE1" class="textBox2 chooseOne" fieldName="查詢項目1">
							<c:forEach var="map" items="${TYPE1_LIST}">
								<option value="${map.key}" <c:if test="${map.key eq TYPE1}">selected</c:if> ><c:choose><c:when test="${map.key eq '0'}">請選擇</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
						<span>&gt;</span>
						<input id="TYPE1_VAL" name="TYPE1_VAL" type="text" datatype="number" pattern="#,###.###"  class="textBox2 type1check" size="5" value="${TYPE1_VAL}" readonly/>
					</td>
                </tr>
	 			<tr>
                    <td class="tbYellow2" colspan="3">
						<select name="TYPE2" id="TYPE2" class="textBox2 chooseOne" fieldName="查詢項目2">
							<c:forEach var="map" items="${TYPE2_LIST}">
								<option value="${map.key}"  <c:if test="${map.key eq TYPE2}">selected</c:if>><c:choose><c:when test="${map.key eq '0'}">請選擇</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
						<span>&ndash;逾期天數</span>
						<input id="TYPE2_VAL" name="TYPE2_VAL" type="text" datatype="number" pattern="#,###.###" class="textBox2 type2check" size="5" value="${TYPE2_VAL}" readonly/>
					</td>
                </tr>
               </form>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
			

</body>
<!-- InstanceEnd -->
</html>