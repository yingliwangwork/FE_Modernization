<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA50401.jsp
作者：謝雅筑
功能：滿期案件查詢。
完成：
-->

<fmt:setBundle basename='TextResource' />

<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
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

<link href="<%=cssBase%>/ui/TableUI_print.css" rel="stylesheet" type="text/css">

<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA50400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA50400(){
	
	var valid;
	var grid;
					
	var actions = {
		
		//查詢
		doQuery:function(){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
	    	
			ajaxPost('query',{CRED_DEPT:$F('CRED_DEPT')},
				function(resp){
					var index=0;
					rtnList = resp.rtnList?resp.rtnList:[];
					rtnList.each(function(map){
						index++;
						map.SEQ_NO = index;
					
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
					doPrint();
				},
				function(){
					grid.load([]);
					doPrint();
				}
			);
			
		}
	};
	
	function doPrint(){
		$$('select').each(function(record){
			record.disabled = true;
		});
				
		window.print();
	}
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA5_0400/" + actionName,
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
	
	return{                              
		initApp:function(){

			grid = new TableUI ( {
				table: $("grid"), allSortable:false, overDiv:false, pageSize:0, printMode: true,
					column:[
						{header: "序號" ,key: "SEQ_NO" },
						{header: "貸款帳號" ,key: "LOAN_ID" },
						{header: "借款人" ,key: "BORROW_NAME" },
						{header: "滿期日期" ,key: "END_DATE" , 
		               		render:function(record,value){
		               		 	return Date.toROC(value);
		               		}
		            	},
						{header: "契約狀況" ,key: "LOAN_STATUS_NM" },
						{header: "還款方式" ,key: "RETURN_TYPE_NM" },
						{header: "行政中心" ,key: "CRED_DEPT_NM" }
					]
				
			});	
						
			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'validateCRED_DEPT', '必須輸入',
					function(v){				
						return (v!='0' && v!='') ;
					}
				]
			]);

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
                    <td class="tbYellow2" width="85%" >
						<select name="CRED_DEPT" id="CRED_DEPT" fieldName="承辦科別" class="validateCRED_DEPT">
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}" <c:if test="${map.key eq CRED_DEPT}">selected</c:if>>${map.value}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				</form>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="grid" id="tableB">
			<tr>				
				<td class="tbYellow" >		
					<b>一、作業規定</b><BR>
					１、供行政中心管理、查詢滿期件使用。<BR><BR>
					<b>二、操作方式</b><BR>
					１、依各主辦科(各行政中心及總公司)選項，查詢距查詢日三個月內滿期(含查詢日前已滿期、未轉期或清償案件)之案件。<BR>			
				</td>								
			</tr>
			</table>	

</body>
<!-- InstanceEnd -->
</html>