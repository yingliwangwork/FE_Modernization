<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21018.jsp
作者：陳思涵
功能：新契約受理查詢
完成：2019/11/13

[20200603] 修改件	申請書200407001741 不當招攬比對與放款支給扣回：調整欄位排序和增加欄位		張憶如	2000601002365
By 蔡政均 20200619
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA21018().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA21018(){

	var grid;

	function doQuery(){
		
		var params = {
			'APPLY_ID' : $F('APPLY_ID'),
			'BORROW_ID' : $F('BORROW_ID'),
			'APPLY_DATE' : $F('APPLY_DATE')
		};
		ajaxPost('query',{qryMap:Object.toJSON(params)},
		function(resp){
			grid.load(resp.rtnList||[]);
		});
	}
	
	          
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1018/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
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
		
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />	
			PageUI.createPageWithAllBodySubElement("DSA21018" , "核貸作業" , "新契約受理查詢", 0);
			//[20200603] 修改件
			grid = new TableUI(
				{
					table:$('grid'),
					overDiv: false,
					allSortable:true,
					column:[
						//{header:'契約編號', key:'CONTRACT_NO'},
						//{header:'ID', key:'ID'},
						{header:'要保人', key:'IS_ROLE_A',render:function(rec,v,ser){
							return ('Y'==v) ? '是' : '';
						}},	
						{header:'被保人', key:'IS_ROLE_I',render:function(rec,v,ser){
							return ('Y'==v) ? '是' : '';
						}},	
						{header:'實際繳費人', key:'IS_PAY_ID_ACT',render:function(rec,v,ser){
							return ('Y'==v) ? '是' : '';
						}},	
						{header:'追費繳費人', key:'IS_PAY_ID_ADD',render:function(rec,v,ser){
							return ('Y'==v) ? '是' : '';
						}},	
						{header:'商品名稱', key:'PROD_NAME',render:function(rec,v,ser){
							return (rec.PROD_ID||'') + ' ' + (v||'');
						}},
						{header:'契約狀態', key:'CONTRACT_STATUS'},
						{header:'是否有保價金', key:'IS_KEEPVALUE',render:function(rec,v,ser){
							return ('Y'==v) ? '是' : '';
						}},	
						{header:'一次保費總計', key:'TOTAL_PREM',sortRule:'number',render:function(rec,v,ser){
							v = window.localeDisplay.formatNumber(v);
							return (v || v=='0') ? (v + ' 元') : '';
						}},
						{header:'年收入(萬)', key:'INCOME',sortRule:'number'},
						{header:'年收入來源', key:'INCOME_FROM'},
						//{header:'單位', key:'FACE_AMT_UNIT'},
						//{header:'單位', key:'FACE_AMT_UNIT_NM'},
						{header:'新契約受理編號', key:'APPLY_NO'},
						{header:'保單號碼', key:'POLICY_NO'},
						{header:'受理完成日', key:'FORM_CLOSEDT',sortRule:'date'},
						{header:'核定日', key:'APPROVE_DATE',sortRule:'date'},
						{header:'成立日', key:'EFFECT_DATE',sortRule:'date'},
						{header:'新契約經手人-1', key:'AGENT_NAME_1'},
						{header:'新契約經手人-2', key:'AGENT_NAME_2'},
						{header:'新契約經手人-3', key:'AGENT_NAME_3'},
						{header:'新契約經手人-4', key:'AGENT_NAME_4'},
						{header:'新契約經手人-5', key:'AGENT_NAME_5'},
						{header:'新契約經手人-6', key:'AGENT_NAME_6'},
						{header:'保費繳款方式', key:'METHOD_PREMPAY_NM_ACT'},
						{header:'保費繳費時間', key:'PAY_DATE_ACT',sortRule:'date'},
						{header:'追費繳款方式', key:'METHOD_PREMPAY_NM_ADD'},
						{header:'追費繳費時間', key:'PAY_DATE_ADD',sortRule:'date'},
						{header:'要保人職業', key:'JOB_NAME'},
						{header:'要保人職位', key:'POSITION'},
						{header:'繳費來源為貸款(來源：生調表)', key:'PREMIUM_SOURCE_LOAN',render:function(rec,v,ser){
							return ('1'==v) ? '是' : '';
						}},	
						{header:'前3個月是否辦理貸款(來源：生調表)', key:'ASSURED_IS_LOAN',render:function(rec,v,ser){
							return ('1'==v) ? '是' : '';
						}}
					]
				}
			)

			doQuery();		
			
			fix();
			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
		<form id="form1" name="form1" method="post">
			
			<input type="hidden" id="APPLY_ID" name="APPLY_ID" value="<c:out value='${APPLY_ID}' />">
			<input type="hidden" id="BORROW_ID" name="BORROW_ID" value="<c:out value='${BORROW_ID}' />">
			<input type="hidden" id="APPLY_DATE" name="APPLY_DATE" value="<c:out value='${APPLY_DATE}' />">
			
			<table id="grid" class="grid"></table>
		</form>
</body>
<!-- InstanceEnd -->
</html>