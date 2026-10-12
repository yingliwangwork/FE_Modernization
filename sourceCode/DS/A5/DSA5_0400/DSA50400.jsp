<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA50400.jsp
作者：謝雅筑
功能：滿期案件查詢
完成：2012/06/08
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
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
				},
				function(){
					grid.load([]);
				}
			);
			
		},
		
		//列印
		doPrint:function(event){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			window.open('<%=dispatcher%>/DSA5_0400/print?CRED_DEPT='+$F('CRED_DEPT'),'_blank', "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=1024, height=768");

		}
	};
	
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
			PageUI.createPage("DSA50400" , "管理作業" , "滿期案件查詢", false);
			PageUI.loadin(["tableA","grid","tableB"] ,1);

			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
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
						{header: "區域" ,key: "CRED_DEPT_NM" }
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
			
			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);

			//列印
			$('btn_print').observe('click',function(event){
					actions.doPrint();
				}
			);

			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body >	
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<form id="form1" name="form1" method="post">	
				<tr>
					<td class="tbYellow" width="15%">區域</td>
                    <td class="tbYellow2" width="35%" >
						<select name="CRED_DEPT" id="CRED_DEPT" fieldName="區域" class="validateCRED_DEPT">
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">請選擇</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow2" align="center" width="40%">
						<input id="btn_query" type="button" class="button" value="查詢" />
						<input id="btn_print" type="button" class="button" value="列印" />
					</td>
				</tr>
				</form>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
				<tr>				
					<td class="tbYellow" >		
						<b><font class = 'textBlue'>一、作業規定</font></b><BR>
						１、供各區域管理、查詢滿期件使用。<BR><BR>
						<b><font class = 'textBlue'>二、操作方式</font></b><BR>
						１、依各主辦科(各區域及總公司)選項，查詢距查詢日三個月內滿期(含查詢日前已滿期、未轉期或清償案件)之案件。<BR>			
					</td>								
				</tr>
			</table>	

</body>
<!-- InstanceEnd -->
</html>