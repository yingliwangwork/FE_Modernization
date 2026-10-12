<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA20900.jsp
作者：i9100606
功能：放款綜合評分
完成：2011/10/03
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<style type="text/css"> 
<!--
.style1 {font-size: 24px; color: #0000FF;}
-->
</style>
<%--[20240729]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">
<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function initApp(){

	cleanMsgBoard();

	PageUI.createPageWithAllBodySubElement( "DSA20900" , "核貸作業" ,"放款綜合評分" , 2 );

	buttonAuth();

	//TableUI的產生        
	new UI().init();                
   
   PageUI.resize();
}

<%--
	button控制
--%>
function buttonAuth(){
	var authButtons = {
		B0001:"btn_query"//查詢
	};
	<dz:grantButtons FUNC_ID="DSA20900" ignored="true"/> 	
}

//--------------------------------------------------------------------------  
<%--全域 函數 UI 與 畫面 公用 End----------------------------------------------------%>

<%--Define UI Class Start-------------------------------------------------------%>
function UI(){                
	//--------------------------------------------------------------------------          
	//UI() private variable        
	//--------------------------------------------------------------------------         
	var grid = {};
	var gridIndex=0;
	var checked = false;
	var checkedInd=0;
	//--------------------------------------------------------------------------          
	//UI() private method        
	//--------------------------------------------------------------------------          
	//***        
	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_0900/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}      
	
	//AJAX SuccessAction For Query
	function successActionForQuery(XHT, resp) {
		if(CSRUtil.isSuccess(resp)){
			gridIndex=0;
			grid.load(resp.rtnList || []);
			if(checked){
				$('singleRG'+checkedInd).click();
			}
			grid.resetDivHeight();
		} else{
			grid.load([]);
		}
	}		
		
	//查詢Function       
	var doQuery = function(){
		var msg = "";
		$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

		if($('APPLY_ID').value==''){
			msg = '\n 請輸入受理編號!';	
		}else if($('APPLY_ID').value.length!=11) {
			msg = '\n 輸入受理編號有誤！';
		}
		
		
		if(msg!=""){
			alert(msg);
			return;
		}
		
		$$('#table1 span').each(
			function(span){ 
				span.innerHTML = ''; 
			}
		);
		$$('#table1 input[type="text"]').each( 
			function(text){
				text.value='';
			}
		);
		$$('#table1 td[id]').each( 
			function(text){
				text.innerHTML = ''; 
			}
		);
		$('COMMENT').value='';
		checked = false;
		ajaxPost('query', 
				$("form1").serialize( true ),
				successActionForQuery
		);

	};

	//--------------------------------------------------------------------------        
	//以下為UI() public method,放在 return 中        
	//--------------------------------------------------------------------------          
	return{                              
		//init Function for 初始整個UI Class                
		init:function(){                                        
				
			//產生 Grid 物件                
			grid = new TableUI( {
				table: $("grid"), allSortable: false,
				overDiv:false,
				<%-- [20240729] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{ header: '選取', key: "RADIO_BOX", sortable: false,
					  	render: function( record, value ) {
					  		var index = gridIndex;							
							var radio = new Element('input',{name:'singleRG',id:'singleRG'+index,type:'radio'});
							radio.style.cursor = "hand";
							radio.onclick = function() {
								if(record.QRY_MESSAGE){
									$$('#table1 span').each(
										function(span){ 
											span.innerHTML = ''; 
										}
									);
									$$('#table1 input[type="text"]').each( 
										function(text){
											text.value='';
										}
									);
									$$('#table1 td[id]').each( 
										function(text){
											text.innerHTML = ''; 
										}
									);
									$('COMMENT').value='';
								}else{
									JSONUtil.sampleJSON2Form2( 'table1', record );
									JSONUtil.sampleJSON2Form3( 'table1', record );
									if("N"==record.IS_NEW){
										$('IS_NEW_SCORE12').hide();
										$('IS_NEW_SCORE13').hide();
										$('IS_NEW_SCORE14').hide();
										$('IS_NEW_SCORE15').hide();
										$('IS_NEW_SCORE16').hide();
										$('IS_NEW_SCORE17').hide();
									}else{
										$('IS_NEW_SCORE12').show();
										$('IS_NEW_SCORE13').show();
										$('IS_NEW_SCORE14').show();
										$('IS_NEW_SCORE15').show();
										$('IS_NEW_SCORE16').show();
										$('IS_NEW_SCORE17').show();
									}
									if("Y"==record.IS_NEW){
										$('IS_NEW_SCORE7').hide();
										$('IS_NEW_SCORE10').hide();
									}else{
										$('IS_NEW_SCORE7').show();
										$('IS_NEW_SCORE10').show();
									}
								}
								
							};
							if(!record.QRY_MESSAGE && !checked){
								radio.checked = true;
								checked = true;
								checkedInd = index;
							}
							gridIndex++;
							return radio;
						}
					},
					{ header: '評估對象', key: "ID_TYPE_NM", sortable: false,
					  	render: function( record, value ) {
							return value;
						}
					},
					{ header: '對象關係', key: "NAME", sortable: false, attrs:{style:"font-family:'EUDC'"},<%--[20240729] 難字調整 --%>
					  	render: function( record, value ) {
							return value;
						}
					},
					{ header: '評估人員', key: "CRED_NAME", sortable: false, attrs:{style:"font-family:'EUDC'"},<%--[20240729] 難字調整 --%>
					  	render: function( record, value ) {
							return value;
						}
					},
					{ header: '評估日期', key: "CRED_DATE", sortable: false,
					  	render: function( record, value ) {
							return Date.toROC(value);
						}
					},
					{ header: '查詢訊息', key: "QRY_MESSAGE", sortable: false,
					  	render: function( record, value ) {
							return value;
						}
					}
				]
			} );
			
			//查詢 button click event                        
			$('btn_query').observe('click',function(event){                                        
					doQuery();					
				}                        
			); 

			if ('${APPLY_ID}' != "") {
				$('APPLY_ID').value = '${APPLY_ID}';
			} else { 
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}			
			if($('APPLY_ID').value){
				doQuery();
			}

//			<c:if test="${not empty APPLY_ID}">
//				$("APPLY_ID").value = "<c:out value='${APPLY_ID}'/>";
//				doQuery();
//			</c:if>

		}//end init()--                        
	}//end return--        /
	//-------------------------------------------------------------------------- 
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<form id="form1" name="form1" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">
				受理編號
			</td>
			<td class="tbYellow2" width="25%">
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
				<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			</td>
			<td class="tbYellow2">
			  <font color="blue">※若借款資料、保人資料有異動，請重新查詢評分</font>
			</td>
		</tr>
	</table>
	</form>

	<table id="grid" class="grid"></table>							
                    	
    <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
       <tr class="tbBlue" align="center">
         <td colspan="4" class="tbYellow0" >
         	<font color="red">本畫面現僅提供查詢舊件功能，如需新增、異動、刪除資料，請至新進件評分作業！</font>
         </td>
       </tr>
       <tr class="tbBlue" align="center">
         <td colspan="2" class="tbYellow" ><div align="center"><strong> 項目 </strong></div></td>
         <td width="50%" class="tbYellow" ><strong>符合條件</strong></td>
         <td width="20%" class="tbYellow" ><strong>得分</strong></td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td width="5%" rowspan="8" class="tbYellow">
         	<div align="center"><strong>基<br>本<br>資<br>料<br></strong></div>
         </td>
         <td width="25%" height="30" class="tbYellow" >
         	<div align="left"><strong>職業</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE1_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE1"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td class="tbYellow" >
         	<div align="left"><strong>年資(含同行業前職)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE2_NM"></td>
         <td height="70" class="tbYellow2">
         	<p><strong><U>實際年資<input type="text" size="3" value="" name="SERV_YEAR" id="SERV_YEAR" readOnly>年</U></strong></p>
           <p><strong><span class="style1" id="SCORE2"></span></p></</td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td height="70" class="tbYellow" >
         	<div align="left"><strong>年收入(含配偶)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE3_NM"></td>
         <td class="tbYellow2" >
         	<p><strong><U>實際收入<input type="text" maxLength="9" size="7" value="" name="INCOME_TOTAL" id="INCOME_TOTAL" readOnly>萬</U></strong></p>
           <p><strong><span class="style1" id="SCORE3"></span></strong></p>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td height="70" class="tbYellow" >
         	<div align="left"><strong>年齡</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE4_NM"></td>
         <td class="tbYellow2" >
         	<p><strong><U>實際年齡<input type="text" size="3" value="" name="AGE" id="AGE" readOnly>歲</U></strong></p>
         	<p><strong><span class="style1" id="SCORE4"></span></strong></p>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>婚姻狀況</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE5_NM"></td>
         <td class="tbYellow2">
         	<strong><span class="style1" id="SCORE5"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>學歷</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE6_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE6"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE12">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>繳款方式</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE12_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE12"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td class="tbYellow" >
         	<div align="left"><strong>綜合評價</strong></div>
         </td>
         <td class="tbYellow2" >
         	<textarea rows=3 cols=50 name="COMMENT" id="COMMENT" readonly></textarea>
         </td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE9"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td rowspan="6" class="tbYellow">
         	<div align="center"><strong>債<br>信<br>表<br>現<br></strong></div>
         </td>
         <td class="tbYellow" >
         	<div align="left"><strong>年本息支出(含他銀行)佔年收入比(含配偶)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE8_NM"></td>
         <td class="tbYellow2" >
         	<p><strong><U>實際比率<input type="text" maxLength="9" size="7" value="" name="EXPENSE_RATE" id="EXPENSE_RATE" readOnly>%</U></strong></p>
           <p><strong><span class="style1" id="SCORE8"></span></strong></p>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE7">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>金融往來(含配偶)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE7_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE7"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE13">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>查詢家數</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE13_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE13"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE14">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>信用卡繳款情形</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE14_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE14"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE15">
         <td class="tbYellow" >
         	<div align="left"><strong>無擔保貸款佔總授信比率</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE15_NM"></td>
         <td class="tbYellow2" >
         	<p><input type="text" maxLength="9" size="7" value="" name="NON_GAGE_RATE" id="NON_GAGE_RATE" readOnly>%</p>
           <p><strong><span class="style1" id="SCORE15"></span></strong></p>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE16">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>現金卡使用狀況</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE16_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE16"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td class="tbYellow" colspan="3"></td>
       </tr>
       <tr class="tbBlue3" align="center">
         <td rowspan="3" class="tbYellow">
         	<div align="center"><strong>外<br>加<br>分<br>數<br></strong></div>
         </td>
         <td class="tbYellow" >
         	<div align="left"><strong>年繳保費(含直系血親)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE11_NM"></td>
         <td class="tbYellow2" >
         	<p><strong><U>實際保費<input type="text" maxLength="9" size="7" name="PREMIUM" id="PREMIUM" readOnly>萬</U></strong></p>
           <p><strong><span class="style1" id="SCORE11"></span></strong></p>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE17">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>其它財力證明(需佐證資料)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE17_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE17"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center" id="IS_NEW_SCORE10">
         <td height="30" class="tbYellow" >
         	<div align="left"><strong>其他不動產(含保人，需佐證資料)</strong></div>
         </td>
         <td class="tbYellow2" id="SCORE10_NM"></td>
         <td class="tbYellow2" >
         	<strong><span class="style1" id="SCORE10"></span></strong>
         </td>
       </tr>
       <tr class="tbBlue3" align="center"> 
         <td class="tbYellow" colspan="3"></td>
       </tr>
       <tr class="tbYellow2" align="center">
         <td height="30" colspan="3" class="tbBlue3" ><div align="right"><strong>合計</strong></div></td>
         <td class="tbBlue3" ><strong><span class="style1" id="TOTAL_SCORE"></span></strong></td>
       </tr>
    </table>								

</body>
<!-- InstanceEnd -->
</html>
