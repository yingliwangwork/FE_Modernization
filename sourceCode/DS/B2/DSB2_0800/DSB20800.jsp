
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20800.jsp
作者：張智翔
功能：設定控管統計作業。
完成：2012/05/25
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type='text/javascript'>

// 產生畫面物件
var DSB20800 = new DSB20800();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20800.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20800(){	
	
	//load用的tableUI
	var loadColunm = [ 
		[		
											
			{header: "行政中心別",key: "DEPT_NM",				
				render : function(rec ,val ){
					if(val){
						var link = new Element("a" , { href : "#" } ).update(val);
							link.observe( 'click', function (event){ 
								$('CRED_DEPT').value = rec.CRED_DEPT;							
								buttons.doQueryArea();							
							});		
						return link;
					}else{
						return "";
					}								
				}
			},						
			{header: "申請件數",key: "A",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'A',
								TYPE : $('queryTP').value	
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}			
			},
			{header: "待核印件數",key: "B",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'B',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "已核印件數",key: "C",
				render : function(rec ,val ){
					
					if(JsUtils.isNumeric(val)){					
						var link = new Element("a" , { href : "#" } ).update(val);
							link.observe( 'click', function (event){ 	
								var LP_JSON = {
									action :'<%=dispatcher%>/DSB2_0801/prompt',
									YEAR  : rec.YEAR,
									MONTH  :  rec.MONTH,
									CRED_DEPT : rec.CRED_DEPT,
									QUERY_TYPE : 'C',
									TYPE : $('queryTP').value
								}									
								CSRUtil.linkTo(LP_JSON , 'form1');									
							});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "庫存件數",key: "D",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'D',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "領用件數",key: "E",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'E',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "匯款件數",key: "F",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'F',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "退件件數",key: "G",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'G',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "作廢件數",key: "H",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								CRED_DEPT : rec.CRED_DEPT,
								QUERY_TYPE : 'H',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "核銷比例",key: "RATE",
				render : function(rec ,val ){
					return val + '%';				
				}							
			}
		
		],


		[
			{header: "服務中心別",key: "DEPT_NM"},						
			{header: "申請件數",key: "A",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
						var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'A',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}			
			},
			{header: "待核印件數",key: "B",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'B',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "已核印件數",key: "C",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'C',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "庫存件數",key: "D",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'D',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "領用件數",key: "E",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'E',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "匯款件數",key: "F",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'F',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "退件件數",key: "G",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'G',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "作廢件數",key: "H",
				render : function(rec ,val ){
					if(JsUtils.isNumeric(val)){
					var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB2_0801/prompt',
								YEAR  : rec.YEAR,
								MONTH  :  rec.MONTH,
								SRV_DEPT : rec.SRV_DEPT,
								QUERY_TYPE : 'H',
								TYPE : $('queryTP').value
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}								
				}							
			},
			{header: "核銷比例",key: "RATE",
				render : function(rec ,val ){
					return val + '%';				
				}							
			}
		]
	
	]
	
	var grid;	

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB2_0800/" + actionName,
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
				});
		}	
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){			
		    
			$('queryType').value = 'normal';		
			
			//將查詢條件放入隱藏的input中			
			$('queryYY').value = $('YEAR').value;
			$('queryMM').value = $('MONTH').value;		
			$('queryTP').value = $('TYPE').value;		
			
			makeGrid();
			//發送ajax
			ajaxPost( 'query' , {
					reqMap :Object.toJSON( {
						YEAR : $('YEAR').value ,
						TYPE : $('TYPE').value ,
						MONTH : $('MONTH').value	
					})	
				},
				function(resp){		
					var TOTobj = 
						[{ 	text: '總計' ,	
							textAlign : "center",
							value : resp.countMap
						}];
					grid.load(resp.rtnList , TOTobj);
				},
				function(resp){	
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		},
		
		//查詢行政中心底下單位
		doQueryArea :function(event){
			$('queryType').value = 'area';		
		
			makeGrid();
			//發送ajax
			ajaxPost( 'queryArea' , {
					reqMap :Object.toJSON( {
						YEAR : $('queryYY').value ,
						MONTH : $('queryMM').value,	
						TYPE : $('queryTP').value,
						CRED_DEPT : $('CRED_DEPT').value
					})	
				},
				function(resp){	
					var TOTobj = 
						[{ 	text: '總計' ,	
							textAlign : "center",
							value : resp.countMap
						}];
					grid.load(resp.rtnList , TOTobj);					
				},
				function(resp){	
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		}
	};
	
	//判斷查詢種類new出新的tableUI
	function makeGrid(){
		var queryType = $('queryType').value
		var newColunm ; 
		var title;
		if(queryType === 'normal'){
			newColunm = loadColunm[0];
			title = '行政中心別統計';
		}else{
			newColunm = loadColunm[1];
			title = '服務中心別統計';
		}
		grid = new TableUI ( {			
			table: $("grid"), pageSize: 10, allSortable:true , title : title,					
			column: newColunm
		});				
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20800", "匯款文件", "設定控管統計作業" );			
				grid = new TableUI ( {
						
						table: $("grid"), pageSize: 10, allSortable:true , title:'行政中心統計別',
								
						column: loadColunm[0]
					});		
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery);					
				
				fix();

				displayMessage();		
				
						
				if(CSRUtil.isBackLink('form1')){ 
					if($('queryType').value === 'normal'){
						buttons.doQuery();  
					}else if($('queryType').value === 'area'){
						buttons.doQueryArea();		
					}
				 
				}
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<input id = "queryType" name ="queryType" type = "hidden"/>	
			<input id = "CRED_DEPT" name ="CRED_DEPT" type = "hidden"/>	
			<input id = "queryYY" name ="queryYY" type = "hidden"/>		
			<input id = "queryTP" name ="queryTP" type = "hidden"/>	
			<input id = "queryMM" name ="queryMM" type = "hidden"/>		
			<tr>
				<td class="tbYellow" width="10%" align="left">
					年度
				</td>
				<td class="tbYellow2">
					<select  id="YEAR" name = "YEAR" fieldName = "年度" >		
						<c:forEach items="${YEAR_LIST}" var="row">
							<option value="${row.VALUE}" />${row.YEAR}</option>						
						</c:forEach>							
					</select>		
				</td>
				<td class="tbYellow" width="10%">
					文件類別
				</td>
				<td class="tbYellow2">
					<select name="TYPE" id="TYPE">
						<option value='0'>舊式</option>
						<option value='1'>新式</option>
					</select>
				</td>
				<td class="tbYellow" width="10%" align="left" >
					月份
				</td>	
				<td class="tbYellow2">
					<select  id="MONTH" name = "MONTH" fieldName = "月份" >	
					<option value="" selected>---</option>	
						<c:forEach items="${MONTH_LIST}" var="row">
							<option value="${row.key}" />${row.value}</option>						
						</c:forEach>							
					</select>			
				</td>
				<td class="tbYellow2"  align = "center">				
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>				
				</td>
			</tr>		
		</table>
	</form>	
	<table id='grid' width="100%"></table>
</body>
</html>