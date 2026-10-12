<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>


<!--
程式：DSC50100.jsp
作者：熊偉翔
功能：基準利率作業
完成：2012/12/07

[20241104] 修改件 難字調整 吳志鴻
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->

<%-- [20241104] 難字調整 --%>
<style type="text/css">
	@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
	}
</style>

<script type="text/javascript">


var DSC50100 = new DSC50100();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC50100.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC50100(){
		
	var grid;
	
	var queryType;
	
	//待覆核查詢需增加顯示的欄位
	var col_confirm = [
		{header: '異動類別',key: 'CHG_KIND_NM' }
	];
	
	//查詢顯示的欄位
	var col = [
				{header: '基準代碼',key: 'BASE_CODE' },
				{header: '基準利率名稱',key: 'BASE_NAME' ,                       
					render : function(rec , val){	
						//alert("rec.CONFIRM_ID:"+ rec.CONFIRM_ID);
						if(diffDay(toY2K(rec.END_DATE),'2099-12-31')== 0 && !rec.CONFIRM_ID){
							var link = new Element('a', { 'href' : '#'}).update(val);
							link.observe('click', //監聽click事件
								function( event ) { 		                      
									var LP_JSON = {
										'BASE_CODE':rec.BASE_CODE,		//基準代碼
										'BEGIN_DATE':rec.BEGIN_DATE,	//生效日期
										'CHG_KIND':rec.CHG_KIND,		//異動種類代碼
										'SER_NO':rec.SER_NO,			//序號
										'ACTION_TYPE':'Q', 				//查詢件
										'queryType': queryType,          //查詢種類
										'IS_FIRST' : rec.IS_FIRST
								};
									
									//加上輸入欄位(下拉選單)的保留值       
									LP_JSON.BQ_ARG = { 
										BASE_CODE: $F('BASE_CODE')
									};
									
									LP_JSON.action = "<%=dispatcher%>/DSC5_0101/prompt";
									CSRUtil.linkTo(LP_JSON , "form1");		                     			
								}
							);

							return link;
						}else{
							return val;
						}
					}
				},
				{header: '基準利率％',key: 'BASE_RATE' , attrs:{align:'right'}, render: getFmtPercent},
				{header: '生效日期',key: 'BEGIN_DATE' , 
					render : function(rec , val){
						return val ? toROC(val) : '';
					}
				},
				{header: '終止日期',key: 'END_DATE' , 
					render : function(rec , val){
						return val? toROC(val) : '';
					}
				},
				{header: '輸入人員',key: 'INPUT_NM',attrs:{style:"font-family:'EUDC'"}},   <%-- [20241104] 難字調整: 輸入人員 --%>
				{header: '輸入日期',key: 'INPUT_DATE' , 
					render : function(rec , val){
						return val? toROC(val) : '';
					}
				},	
				{header: '覆核人員',key: 'CONFIRM_NM',attrs:{style:"font-family:'EUDC'"}},  <%-- [20241104] 難字調整: 覆核人員 --%>
				{header: '覆核日期',key: 'CONFIRM_DATE' , 
					render : function(rec , val){
						return val? toROC(val) : '';
					}
				}			
			];
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0100/" + actionName,
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
	
	 //百分比格式化
	 function getFmtPercent(rec , val){
		//取到小數點第四位,不足補0
		return val ? (CSRUtil.$fmt(val , '###.0000')) : 0;
	 };
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	
	var buttons = {
		
		//新增資料
		doInsert: function(event){		
			var LP_JSON = {				  		    
       			'ACTION_TYPE':'I'
       		};
       		//基準利率明細
            LP_JSON.action = "<%=dispatcher%>/DSC5_0101/prompt";
            CSRUtil.linkTo(LP_JSON , "form1");	
        },	  
		
		//共用 查詢Ajax (查詢,待覆核查詢)
		Action_shared_Ajax_Query : function( actionName ){
		
			ajaxPost( actionName, { 'BASE_CODE' :$F('BASE_CODE')}
					
					,function(resp){
						
						if(actionName ==='confirm_Query'){
						
							 grid = new TableUI ( { table: $("grid"), pageSize: 10, allSortable:true, column : col_confirm.concat(col) });
							 
							 queryType = 'confirm_Query';
							 
						}else {
						
							 grid = new TableUI ( { table: $("grid"), pageSize: 10, allSortable:true, column : col });
							 
							 queryType = 'query';
						}
						
						grid.load(resp.rtnList || []);  //載入資料
					}
					,function(resp){	
					//如果失敗,把前一次的內容清掉
					grid.load([]);
					}
					
				);
	
		}
		
	};


	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement("DSC50100", "利率計算", "基準利率作業");
				
				//產生 Grid 物件	
				grid = new TableUI ( { table: $("grid"), pageSize: 10, allSortable:true, column : col });
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
					
				//註冊DOM物件 : 監聽	
				$('BTN_0001').observe('click',  function() {buttons.Action_shared_Ajax_Query('query');}); 		 //查詢
				$('confirm_Query').observe('click', function() { buttons.Action_shared_Ajax_Query('confirm_Query'); } );	 //待覆核查詢
				$('BTN_0002').observe('click', buttons.doInsert);//新增
				
				//初始頁面alert訊息用	
				displayMessage();
					
				PageUI.resize();
				
				var LP_JSON = CSRUtil.isBackLink('form1');
			
				//需要指定填回顯示的輸入欄位	
				if(LP_JSON){  
					
					var BQ_ARG = LP_JSON.BQ_ARG || {};
					 
					 //填回顯示的輸入欄位(下拉選單)     
					 if(BQ_ARG.BASE_CODE){
						$('BASE_CODE').value = BQ_ARG.BASE_CODE;      
					 } 
					 
					 var action = LP_JSON.queryType;
					
				     //依查詢種類顯示不同的清單			 
					 if(action) {
						buttons.Action_shared_Ajax_Query(action);
					}
				}
	
			}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
<input type='hidden' name='queryType' id='queryType' value=""><%-- 查詢判斷 --%>
		<tr>
		<td class='tbYellow' width='10%'>基準代碼</td>
		<td class='tbYellow2' width='35%'>
			<select id='BASE_CODE' class='textBox2'> 
				<option value = " ">全部</option>
				<c:forEach var='item' items='${BASE_CODE_LIST}'>
					<option value='${item.key}'><c:out value= '${item.key}_${item.value}' /></option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow2' colspan='5' align='center'>
			<input id='BTN_0001' type='button' class='button' value='查詢' />
			<input id='confirm_Query' type='button' class='button' value='待覆核查詢' />
		</td>
	</tr>
	<tr>
		<td  width="100%" colspan="9" align="center">
			<input id="BTN_0002" type="button" class="button" value='新增' />
		</td>
	</tr>	
</table>
</form>
<table id='grid' width='100%'></table>
</body>
</html>