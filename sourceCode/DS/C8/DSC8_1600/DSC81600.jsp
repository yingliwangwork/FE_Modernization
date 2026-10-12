<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>


<!--
程式：DSC81600.jsp
功能：保人資料變更
作者：余凱鈞
完成：2013/07/

[20230321]
難字調整
高強禾
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>

<%-- [20230321] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type='text/javascript'>
Event.observe(window, 'load', new DSC81600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC81600(){
var grid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_1600/" + actionName, {  
			parameters : params, 
			onSuccess : function(response){
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
	
	//POP UP 開啟新視窗
  	function doPopup( page , parms ) {
		popupWin.fullPopup({
			src : '<%=dispatcher%>/DSC8_1601/prompt' ,
			parameters : parms ,
			scrolling : 'yes',
			cb : function(obj){			
				buttons.doQuery();
			}
		});
  	}
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'BTN_INSERT',
			B0004 : 'BTN_UPDATE',		
			B0005 : 'BTN_DELETE'
		 }; 
		 <dz:grantButtons FUNC_ID='DSC81600'/>
	}
var buttons={
	doQuery : function(){
		if(!$F('LOAN_ID_Q')){
			alert("請輸入貸款帳號");
			return;
		}
		ajaxPost( 'query', {LOAN_ID : $F('LOAN_ID_Q')}
					,function(resp){
						var rtnList=resp.rtnList;
						grid.load(rtnList);

						$('BTN_INSERT').enable();
						$('BTN_UPDATE').enable();
						$('BTN_DELETE').enable();
					},function(resp){
						grid.load([]);

						$('BTN_INSERT').enable();
						$('BTN_UPDATE').disable();
						$('BTN_DELETE').disable();
					}
		);
	}
	,doInsert : function (){
		if(!$F('LOAN_ID_Q')){
			alert("請輸入貸款帳號");
			return;
		}
		ajaxPost( 'insert', {LOAN_ID : $F('LOAN_ID_Q')}
					,function(resp){
						rtnMap=resp.rtnMap;
						var parms = { 
							'LOAN_ID' : $F('LOAN_ID_Q'),
							'ID' : rtnMap.ID,								
							'APPLY_ID' : rtnMap.APPLY_ID,				
							'BORROW_NAME' : encodeURIComponent(rtnMap.BORROW_NAME),	//popupWin中文編碼問題
							'BORROW_ID' : rtnMap.BORROW_ID,	
							'COPR_CODE' : rtnMap.COPR_CODE,
							'SOURCE' : 'I',
							'IS_EXTRACT' :rtnMap.IS_EXTRACT
						}; 		
						doPopup( "DSC8_1601" , parms );							
					}					
				);
	}
	,doUpdate : function(){
		//檢查選取筆數是否為一筆
		var checkedRecord = grid.getCheckedRecord();
		if(checkedRecord.length!=1){
			alert("請選取一筆資料");
			return;
		}

		//開啟新視窗(POP UP)DSC81601，保人資料變更
		var parms = { 
			'LOAN_ID' : $F('LOAN_ID_Q'),			
			'APPLY_ID' : checkedRecord[0]["APPLY_ID"],				
			'ID' : checkedRecord[0]["ID"],
			'SOURCE' : 'U'
		}; 								
		doPopup( "DSC8_1601" , parms );
	}
	,doDelete : function(){
		//檢查是否至少選取一筆資料
		var LOAN_ID = $F('LOAN_ID_Q');	
		var checkedRecord = grid.getCheckedRecord(['LOAN_ID','APPLY_ID','ID']);
		if(checkedRecord.length==0){
			alert("請至少選取一筆資料");
			return;
		}
		
		//確認是否執行刪除
		if(!confirm('確定要刪除勾選保人資料?')){
			return;
		}
		ajaxPost( 'delete', {DATA_LIST : Object.toJSON(checkedRecord), LOAN_ID : $F('LOAN_ID_Q') }
					,function(resp){
						grid.load(resp.rtnList);}
					,function(resp){
						grid.load([]);
					});
	}	
}
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC81600', '收息資料更新', '保人資料變更清單');
								grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true,	 title: "保人資料",
					autoCheckBox:{
							text:'選取', 
							type:'checkbox'
					},
					<%-- [20230321] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
				column:[			
					{header:"受理編號", key:"APPLY_ID"},
					<%-- [20230321] 難字調整 --%>
					{header:"借款人姓名",key:"BORROW_NAME",attrs:{style:"font-family:'EUDC'"}},
					{header:"借款人ID",key:"BORROW_ID"},
					<%-- [20230321] 難字調整 --%>
					{header:"保證人姓名",key:"NAME",attrs:{style:"font-family:'EUDC'"}},
					{header:"保證人ID",key:"ID",
						render:function(rec,val){							
							if(val){
								//以ID超連結開啟新視窗(POP UP)DSC81601，保人資料變更
								var link = new Element( 'a' , { 'href' : "#" } ).update(val);
								var parms = { 
									'LOAN_ID' : $F('LOAN_ID_Q'),		
									'APPLY_ID' : rec.APPLY_ID,	
									'BORROW_NAME' : rec.BORROW_NAME,
									'ID' : val,					
									'SOURCE' : 'U'
								}; 		
								link.observe('click', function(){doPopup( "DSC8_1601" , parms )});
								return link;
							}	
							return '';
						}
					},
					{header:"身分",key:"GUAR_KIND_NM"},
					{header:"關係",key:"RELATION"}
				]
				});
				
				buttonAuth();
				//$('BTN_UPDATE').disable();
				//$('BTN_DELETE').disable();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_UPDATE').observe('click',buttons.doUpdate);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="12%" >貸款帳號</td>
			<td class="tbYellow2" width="28%">
				<input id="LOAN_ID_Q" type="text" class="textBox1" maxLength="11" size="13" onblur="this.value = this.value.toUpperCase()"/>
			</td>
			<td class="tbYellow2" width="60%" align="center">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >
				<input id="BTN_INSERT" type="button" value="新增" class="button" >	
				<input id="BTN_UPDATE" type="button" value="變更" class="button" >	
				<input id="BTN_DELETE" type="button" value="刪除" class="button" >	
			</td>
		</tr>
	  </table>
	<table id = "grid" ></table>
</form>
</body>
</html>