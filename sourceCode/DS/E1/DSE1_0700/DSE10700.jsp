<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE10700.jsp
功能：管理費用作業
作者：徐麗雲
完成：2013/06/25

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<%-- [20240207] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/javascript">


Event.observe(window, 'load', new DSE10700().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE10700(){
	
	var grid;
	var LOAN_ID = '${LOAN_ID}';	

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0700/" + actionName,
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
			}
		);
	}
			
	// 檢核查詢條件輸入
	function checkAtleastOneInput() {
		if(!validateNull($F('LOAN_ID')) && !validateNull($F('REFER_ID')) && !validateNull($F('BORROW_ID')) && !validateNull($F('BORROW_NAME'))) {		
			return false;
		} else {
			return true;
		}
	}

	//去空白，檢查是否為空
	function validateNull( params ) {
		var temp = params.trim();
		if(!temp) {
			return false;
		}else{
			return true;
		}
	}
	
	//按鈕功能	
	var buttons = {
		
		//查詢
		doQuery : function(){
		

			if( !checkAtleastOneInput() ) {
				alert('請至少輸入一項查詢條件');
				return;
			}
			
			//將畫面上的欄位存成reqMap
			var reqMap = {};
			$w('LOAN_ID REFER_ID BORROW_ID BORROW_NAME').each(
				function(id){
					reqMap[id] = $(id).value;
				}
			);
						
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){	
					grid.load(resp.rtnList || []);
				},
				function(resp){
					grid.load([]);
				}
			);

		}
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE10700','法務件','管理費用作業',1);
			
			//產生 Grid1 物件	
			grid = new TableUI ( 
				{ table: $('grid'), pageSize: 20, allSortable:true, overDiv:false,
	            <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column : [
					{header: '貸款帳號' , key : 'LOAN_ID'},
					{header: '原貸帳號' , key : 'REFER_ID'
						,render:function(record,value,number){
							var link = new Element('a', { href : '#' });
							link.setAttribute('id','linkEle_'+number);
							link.update(value);
							var LP_JSON = {	
								action :'${dispatcher}/DSE1_0701/prompt',
								REFER_ID : value,
								BORROW_NAME : record.BORROW_NAME,
								BORROW_ID : record.BORROW_ID,
								LINK_FROM : 'DSE10700'
							};
							link.onclick = function() {
								CSRUtil.linkTo(LP_JSON, 'form1');
							};
							return link;
						}					
					},
				
					{header: '契約效力' , key : 'LOAN_STATUS_NM'},
					<%-- [20240207] 難字調整：借款人、保證人、擔保品門牌、承辦法務 --%>
					{header: '借款人' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header: '保證人' , key : 'GUARANTOR_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header: '擔保品門牌' , key : 'GAGE_ADDR',attrs:{align:'left',style:"font-family:'EUDC'"},
					    render : function(rec,val){
							return val ? CSRUtil.maskHandler.getMaskAddress2(val) : '';						
						}
					},
					{header: '承辦法務' , key : 'INPUT_NM', attrs:{ style:"font-family:'EUDC'" }}
				]
			});						
						
							
			//按鈕事件監聽
			$('btn_query').observe('click', buttons.doQuery);//查詢
							
			//身分證字母自動轉大寫、如果該欄位有值則清空其他兩個欄位			
			

			$('LOAN_ID').observe('focus',function(){		
				
				$w('REFER_ID BORROW_ID BORROW_NAME').each(
				function(id){
						$(id).value ='';
					}
				);
				
			});	
			
			$('REFER_ID').observe('focus',function(){
				$('REFER_ID').value = $F('REFER_ID').toUpperCase();
				
				$w('LOAN_ID BORROW_ID BORROW_NAME').each(
					function(id){
						$(id).value ='';
					}
				);
				
			});
			
			$('BORROW_ID').observe('focus',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();

				$w('LOAN_ID REFER_ID BORROW_NAME').each(
					function(id){
						$(id).value ='';
					}
				);
			});

			$('BORROW_NAME').observe('focus',function(){				

				$w('LOAN_ID REFER_ID BORROW_ID').each(
					function(id){
						$(id).value ='';
					}
				);
			});		


			//其他頁面按上一頁回來，依原條件回來重查
			if(CSRUtil.isBackLink('form1')){
				buttons.doQuery();
				
			//if 接值.LOAN_ID有值，自動查詢	
			}else if(LOAN_ID != ''){
				buttons.doQuery();
			
			}
			
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					貸款帳號
				</td>
				<td class="tbYellow2" width="10%">
					<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" size="12" maxlength="10" onKeyUp="this.value=this.value.toUpperCase();" fieldName = "貸款帳號"/ value=${LOAN_ID}>
				</td>
				<td class="tbYellow" width="10%" align="left" >
					原貸帳號
				</td>
				<td class="tbYellow2" width="10%">
					<input id="REFER_ID" name="REFER_ID" type="text" class="textBox2" size="12" maxlength="10"  onKeyUp="this.value=this.value.toUpperCase();" fieldName = "原貸帳號"/>
				</td>
				<td class="tbYellow" width="10%" align="left" >
					借款人ID
				</td>
				<td class="tbYellow2" width="10%">
					<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" size="12" maxlength="10" onKeyUp="this.value=this.value.toUpperCase();" fieldName = "借款人ID"/>
				</td>
				<td class="tbYellow" width="10%" align="left" >
					借款人姓名
				</td>
				<td class="tbYellow2" width="10%">
					<%-- [20240207] 難字調整：借款人姓名 --%>
					<input id="BORROW_NAME" name="BORROW_NAME" type="text" class="textBox2" size="12" maxlength="10" fieldName = "借款人姓名" alt="ch" />
				</td>				
				<td class="tbYellow2" width="20%">	
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>			
				</td>
			</tr>
		</table>
		<table id = "grid" ></table>
</form>	
</body>
</html>