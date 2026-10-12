 <%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<%

ServletContext context = this.getServletConfig().getServletContext();
String strPath = context.getRealPath("/");
//request.setAttribute("strPath",strPath);
pageContext.setAttribute("strPath",strPath);
%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	PageUI.createPageWithAllBodySubElement("DSA10603" , "受理作業" , "組長強迫送件確認", 1);
	PageUI.resize(true);

	new UI().init();
	
	<%--[20240723]難字調整，改用ajax查詢 --%>
	<c:if test="${isRLDS203 eq 'Y'}">
		doQuery();
	</c:if>
	
}

function doLinkAPPLY_ID(APPLY_ID) { 
		var LP_JSON = {};
					
		LP_JSON.FROM_TRX = 'DSA1_1700';			// 從這頁出發
		LP_JSON.IS_BACK = "N";					// 是否從別頁回來
		LP_JSON.BACK_TRX = 'DSA1_0603';			// 回這頁
		LP_JSON.BACK_ACTION = 'prompt';			// 回來要先做的事		
		LP_JSON.APPLY_ID = APPLY_ID;			// 回來要先做的事
		LP_JSON.action = '<%=dispatcher%>/DSA1_1700/prompt';
		LP_JSON.BQ_ARG = {      
			APPLY_ID:APPLY_ID,
			wobNum:$F('wobNum'),
			queueName:$F('queueName')
		};
	
		CSRUtil.linkTo(LP_JSON, 'form1');
}


//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
				var i=1;
				
				grid = new TableUI( 
					{
						table: $("grid"),  
						overDiv:false,
						pageSize: 10,	
						<%-- [20240723] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						split: ['CHECK_MSG'],
						column:[
								{header: '序號',sortable: true, key:'SER_NO',  attrs:{rowSpan:2} ,
									render:function(rec,val){
										return i++;
									}
								},
								{header: '受理編號',sortable: true, key:'APPLY_ID',								
									render:function(rec,val){
										var link = document.createElement( "a" );
					                 	link.href = "#";
					                 	link.innerHTML = val;
					                	link.onclick = function( event ) { 
					                		doLinkAPPLY_ID(val);			                	
					                	};
					                 	return link;		 
									}
			                	},
			                	{header: '借款人',sortable: true, key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"}<%--[20240723]難字調整 --%>},
								{header: '承辦科別',sortable: true, key:'CRED_DEPT_NM',
									render:function(rec,val){
									 	return val ? val : "";
									}
								},
								{header: '受理日期',sortable: true, key:'APPLY_DATE'	},
								{header: '送件人員',sortable: true, key:'INPUT_NM', attrs:{style:"font-family:'EUDC'"}<%--[20240723]難字調整 --%>,
									render:function(rec,val){
										return val ? val : "";
									}
								},
			                	{header: '送件日期',sortable: true, key:'INPUT_DATE',
									render:function(rec,val){
										return val ? Date.toROC(val) : "";
									}
								},								
								{header: '注意事項',sortable: true, key:'STATUS',  attrs:{rowSpan:2},
									render:function(rec,val){
										var unique_id = rec.APPLY_ID;
			                    		var div = document.createElement('div');
			                    		var input = document.createElement('input');
			                    		input.id = unique_id+'1';
			                    		input.name = unique_id;
			                    		input.value = '送件';
			                    		input.type = 'button';
			                    		input.className = 'button';
			                    		input.onclick = function(){
			                    			doConfirm(rec.APPLY_ID,rec.INPUT_ID);
			                    		};
			                    		div.appendChild(input);
			                    		
			                    		var input2 = document.createElement('input');
			                    		input2.id = unique_id+'2';
			                    		input2.name = unique_id;
			                    		input2.value = '退件';
			                    		input2.type = 'button';
			                    		input2.className = 'button';
			                    		input2.onclick = function(){
			                    			doReject(rec.APPLY_ID);
			                    		};
			                    		div.appendChild(input2);
			                    		
			                    		return div;
									}
								},
																
								{header: '送件檢核失敗訊息',sortable: true, key:'CHECK_MSG', attrs:{colSpan:6}}
						]
					}
				);
			
			
				$("btn_back").observe('click',function(event){
					CSRUtil.linkBack();										
				});
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}



function doConfirm(APPLY_ID, INPUT_ID) {
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0603/confirm", 
	{
			parameters:{APPLY_ID:APPLY_ID, INPUT_ID:INPUT_ID, strPath:$F('strPath')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){	
					$(APPLY_ID+'1').disabled = true;			
					$(APPLY_ID+'2').disabled = true;										
				}
			}
	});

}


function doReject(APPLY_ID) {
	
	
	var msg ='確定要將此件'+APPLY_ID+'退件?';
	if(!confirm(msg)){
		return;
	}
	
  	new Ajax.Request("<%=dispatcher%>/DSA1_0603/reject", 
	{
			parameters:{APPLY_ID:APPLY_ID},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){					
					//grid.load(resp.rtnList);
					$(APPLY_ID+'1').disabled = true;			
					$(APPLY_ID+'2').disabled = true;			
				}
			}
	});

}

function doQuery() {
	
  	new Ajax.Request("${dispatcher}/DSA1_0603/query", {
			parameters:{APPLY_ID:'${APPLY_ID}'},
		 	onSuccess:function(XHT, resp){
		 		if(CSRUtil.isSuccess(resp)){
					grid.load(resp.rtnList);
				}else{
					grid.load([]);
				}
			}
	});

}


//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor=#FFFFFF>
		<td>
			<!-- Block_3_Start 表單主功能區塊-->
			<form name="form1" id="form1" method="post"><input name="LP_JSON" id="LP_JSON" type="hidden" value="">
				<input type="hidden" name="strPath" id="strPath" value="${strPath}">
				<input type="hidden" name="wobNum" id="wobNum" value="${wobNum}">
				<input type="hidden" name="queueName" id="queueName" value="${queueName}">				
			</form>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td colspan='3'>
				<table id='grid' class="grid"></table>
			</td>
		</tr>
		<div align="center">
			<input class="button" type="button" name="btn_back" id="btn_back" value="上一頁" >
		</div>
</table>
	</body>
</html>
