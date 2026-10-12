<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!-- 
[20240730] 修改件 難字調整
-->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240730]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;
var grid;

function initApp(){  
	
	PageUI.createPageWithAllBodySubElement("DSA11200" , "受理作業" , "特殊件受理查詢", 1);
	
	new UI().init();
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});
	
	$("CRED_DEPT").observe('change',function(event){
		buttons.doGetCRED_NAME_LIST($("CRED_DEPT").value);
	});
	
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	Validation.addAllThese([
		[ 'validateDateBetween',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件!', function(){ if(diffDay($F('BEGIN_DATE'),$F('END_DATE'), true) < 0){ return false; } return true; }] ,
		[ 'validateQUERY_COND_1',  '請輸入正確貸款帳號!', function(v){ if ($F('QUERY_KIND') == '1' && v.length != 10 ){return false; } return true; }],
		[ 'validateQUERY_COND_2',  '請輸入正確受理編號!', function(v){ if( $F('QUERY_KIND') == '2' && v.length != 11 ){return false; } return true; }],
		[ 'validateQUERY_COND_3',  '請輸入正確借款人ID!', function(v){ if( $F('QUERY_KIND') == '3' && v.length != 10 ){return false; } return true; }],
		[ 'validateCRED_NAMEorPROCESS',  '請至少選擇 徵信人員 或 特殊件受理進度 條件查詢', function(v){ if( $F('QUERY_KIND') != '0' || $F('CRED_NAME')!="" || $F('SPEC_PROCESS')!=0 ){ return true; } return false; }],
		[ 'validateCRED_DEPTorQUERY_KIND',  '請至少選擇 承辦科別 或 查詢方式', function(v){ if( $F('CRED_DEPT') != '' || $F('QUERY_KIND') != "0"){ return true; } return false; }]
	]);	
	
	$("BEGIN_DATE").value = toROC("${BEGIN_DATE}");
	$("END_DATE").value = toROC("${END_DATE}");
		
	PageUI.resize(true);
		
}


//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: true,
					<%--[20240730] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header:"派件序號", key:"SEQ_NO" },
						{ header:"貸款帳號╱<br>受理編號", key:"LOAN_ID" },
						{ header:"借款人", key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"} },
						{ header:"案件類別", key:"SPEC_KIND_NM" },
						{ header:"進度", key:"SPEC_PROCESS_NM" },
						{ header:"派件日期", key:"ASSIGN_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header:"覆核日期╱<br>退件日期", key:"CHECK_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header:"徵信人員", key:"CRED_NAME", attrs:{style:"font-family:'EUDC'"} },
						{ header:"聯絡電話", key:"TEL_OFFICE" },
						{ header:"　", key:"", sortable:false}
					]
				}
			);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){

		valid1.reset();
		
		columnToUpperCase('QUERY_COND');
		
		if( !valid1.validate() ) {return;}
		
		
		var reqMap = Form.serialize("form1",true);
		reqMap.BEGIN_DATE = toY2K(reqMap.BEGIN_DATE);
		reqMap.END_DATE = toY2K(reqMap.END_DATE);
		
		new Ajax.Request("<%=dispatcher%>/DSA1_1200/query", 
		{
			parameters: reqMap,
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){					
					grid.load(resp.rtnList);
				}else{
					if(resp.DataNotFoundException){
						grid.load();
					}
				}
			}
		});
	},
	doGetCRED_NAME_LIST:function(CRED_DEPT){
		var CRED_NAME_DOM = $('CRED_NAME');
		while(CRED_NAME_DOM.hasChildNodes() && CRED_NAME_DOM.childNodes.length > 2 ){
			CRED_NAME_DOM.removeChild(CRED_NAME_DOM.lastChild);
		}
		if(!CRED_DEPT){ return ;}
		new Ajax.Request("<%=dispatcher%>/DSA1_1200/getCRED_NAME_LIST", 
		{
			parameters:{CRED_DEPT:CRED_DEPT},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){	
					if(resp.CRED_NAME_LIST){
						for( var i = 0 ; i < resp.CRED_NAME_LIST.length ; i = i + 1 ){
							var opt = document.createElement("OPTION");
							opt.setAttribute("value" ,resp.CRED_NAME_LIST[i].ID );
							opt.appendChild(document.createTextNode(resp.CRED_NAME_LIST[i].NAME) );
							CRED_NAME_DOM.appendChild(opt);
						}
					}
				}
			}
		});
	
	}
	
};

	<%--
		轉大寫
	--%>
	function columnToUpperCase(columnName) {
		$(columnName).value = $(columnName).value.toUpperCase();
	}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0" onLoad="initApp();" onResize="fix();"
	onScroll="fix();">
	

<form name="form1" id="form1">	
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
    <tr>
        <td class="tbYellow" width="8%" align="left">承辦科別</td>
        <td class="tbYellow2" width="20%">
            <select id="CRED_DEPT" name="CRED_DEPT" class="textBox2 validateCRED_DEPTorQUERY_KIND">
                <option value="" selected>請選擇</option>
                <c:forEach var="item" items="${CRED_DEPT_LIST}"><option value="${item.key}" >${item.value}</option>
                </c:forEach>
            </select>
        </td>
        <td class="tbYellow" width="10%" align="left">徵信人員</td>
         <td class="tbYellow2" width="20%">
         	<%--[20240730] 難字調整 --%>
            <select id="CRED_NAME" name="CRED_NAME" class="textBox2 validateCRED_NAMEorPROCESS" alt="ch">
                <option value="" selected>請選擇</option>
                <c:forEach var="item" items="${CRED_NAME_LIST}"><option value="${item.ID}" >${item.NAME}</option>
                </c:forEach>
            </select>
        </td>
        <td class="tbYellow" width="14%" align="left">特殊件受理進度</td>
         <td class="tbYellow2" width="18%">
            <select id="SPEC_PROCESS" name="SPEC_PROCESS" class="textBox2 validateCRED_NAMEorPROCESS">
                <option value="0" selected>全部</option>
                <c:forEach var="item" items="${SPEC_PROCESS_LIST}"><option value="${item.key}" >${item.value}</option>
                </c:forEach>
            </select>
        </td>
        <td class="tbYellow2" rowspan="2" align="left"><input type="button" name="btn_query" id="btn_query" class="button" value="查詢" /></td>
    </tr>
    <tr>
        <td class="tbYellow" width="8%" align="left">派件日期</td>
        <td class="tbYellow2" width="20%">
         <input id="BEGIN_DATE" name="BEGIN_DATE" type="text" maxlength="7" size="8"class="textBox2 required validateDateBetween" datatype="ROCDATE"/>
         <img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onClick="getCalendarFor($('BEGIN_DATE'))">
          ~
         <input id="END_DATE" name="END_DATE" type="text" maxlength="7" size="8"class="textBox2 required validateDateBetween" datatype="ROCDATE"/>	
         <img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onClick="getCalendarFor($('END_DATE'))">
        </td>
        <td class="tbYellow" width="10%" align="left">查詢方式</td>
        <td class="tbYellow2" width="20%">
            <select id="QUERY_KIND" name="QUERY_KIND" class="textBox2">
                <option value="0" selected>其它查詢</option>
                <c:forEach var="item" items="${OTHER_QUERY_LIST}"><option value="${item.key}" >${item.value}</option>
                </c:forEach>
            </select>
            <input id="QUERY_COND" name="QUERY_COND" type="text" maxlength="11" size="12" class="textBox2 validateQUERY_COND_1 validateQUERY_COND_2 validateQUERY_COND_3"/>
        </td>
        <td class="tbYellow" width="14%" align="left">特殊件類別</td>
         <td class="tbYellow2" width="18%">
             <select id="SPEC_KIND" name="SPEC_KIND"  class="textBox2">
                <option value="00" selected>全部</option>
                <c:forEach var="item" items="${SPEC_KIND_LIST}"><option value="${item.key}" >${item.value}</option>
                </c:forEach>
            </select>
        </td>
    </tr>
</table>
</form>

<table id='grid'></table>

<div id='dtlDiv'
	style="position: absolute; top: 0px; left: -2px; visibility: hidden"
	align='center'><iframe src='' name='dtlFrame' width='99%'
	height='500' id='dtlFrame'></iframe></div>

</body>
</html>