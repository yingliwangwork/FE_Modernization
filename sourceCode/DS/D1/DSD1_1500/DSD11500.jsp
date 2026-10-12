<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSD11500.jsp
功能：當日未收件入帳統計表
作者：徐麗雲
完成：2013/05/28
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
<script type="text/javascript">


Event.observe(window, 'load', new DSD11500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11500(){
	
	var grid1;	

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1500/" + actionName,
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
	
	
	//各種action
	var actions = {
		//取得超連結
		getLink : function(funcid,val){			
			var link = new Element('a', { href : '#' });
			if(!val){
				val = 0;
			}
			link.update(CSRUtil.$fmt(val,'#,###'));
			var LP_JSON;
			if(funcid=='1501'){
				LP_JSON = {	action :'${dispatcher}/DSD1_1501/prompt',
							BEGIN_DATE : '${BEGIN_DATE}',
							AREA_CODE :  'TOTAL',
							CHECK_TYPE : '81',
							QUERY_TYPE : 'D011'　
							};
			}else{
			    LP_JSON = { action :'${dispatcher}/DSD1_1502/prompt',
							AREA_CODE : 'TOTAL'
							};
			}
			
			link.onclick = function() {
				CSRUtil.linkTo(LP_JSON, 'form1');
			};
		
			return link;
		},
		
		doBack : function(){
			var LP_JSON = {
				action :'${dispatcher}/DSD1_1500/prompt'
			};			
			CSRUtil.linkTo(LP_JSON, 'form1');
		
		
		}
		
	};	
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11500','催收作業','當日未收件入帳統計表',1);			
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 20, allSortable:false, overDiv:false,
				split:['D011_CNT'],
				//由於舊版的TableUI在合計部分，若render 回傳的是Element，目前顯示會有問題，所以在afterLoad部分做處理
                afterLoad:function(element){
						$$("#grid1 tfoot td").each( function( elem ){ 
							    							
							if(elem.name=='COUNTS'){
							
							    var val = elem.innerText;
							    elem.innerText = '';
							    
							    var tmpAREA_CODE='';
							    if('${sCheckType}'=='81'){
							       tmpAREA_CODE = 'TOTAL';
							    }else if('${sCheckType}'=='82'){
							       tmpAREA_CODE = '${OLD_AREA_CODE}'.substring(0,2);
							    }
					
							    var link = new Element('a', { href : '#', style : 'font-weight:bold' });							
							    link.update(CSRUtil.$fmt(val,'#,###'));							
							    link.onclick = function() {
								    var LP_JSON = {
									    action :'${dispatcher}/DSD1_1502/prompt',
									    AREA_CODE : tmpAREA_CODE,
									    CHECK_TYPE : '${sCheckType}',
									    OLD_AREA_CODE : '${OLD_AREA_CODE}'　,
									    IS_INIT : '${IS_INIT}'
								    };								
								    CSRUtil.linkTo(LP_JSON, 'form1');
							    };
																						   
							   	elem.insert(link);								   							   						    							
							}
						} );											
			    },					
				column : [
					{header: '單位' , key : 'AREA_NAME', attrs:{rowSpan:2}
						,render:function(rec,val){								
							if('${IS_INIT}' == 'Y'){
								var link = new Element('a', { href : '#' });
								link.update(val);
								link.onclick = function() {
									var LP_JSON = {
										action :'${dispatcher}/DSD1_1500/prompt',
										BEGIN_DATE : rec.BEGIN_DATE,
										AREA_CODE : rec.AREA_CODE,
										CHECK_TYPE : '82',
										QUERY_TYPE : 'D011'　
									};								
									CSRUtil.linkTo(LP_JSON, 'form1');
								};
								return link;
							}else{
								return val;
							}
						}
					
					},
					{header: '有效件數' , key : 'VALID_CNT', attrs:{rowSpan:2,align:'center'}, renderInCount:true
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					},
					{header: '有效件餘額(萬)' , key : 'VALID_AMT_T', attrs:{rowSpan:2,align:'center'},renderInCount:true
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					},
					{header: 'A：未收件(逾1~5期)', key:'t2',attrs:{colSpan:5, style:'color:red'}, empty:'rowSpan_down'},
					{header: '件數' , key : 'D011_CNT', attrs:{align:'center'}
						,render:function(rec,val){							
							var inAREA_CODE;
							var inBEGIN_DATE;
							if(rec.isSum == '9999'){
								inAREA_CODE = 'TOTAL';
								inBEGIN_DATE = '${BEGIN_DATE}';
							}else{
								inAREA_CODE = rec.AREA_CODE;
								inBEGIN_DATE = rec.BEGIN_DATE;
							}
							var link = new Element('a', { href : '#'});
							link.update(CSRUtil.$fmt(val,'#,###'));	
							link.onclick = function() {
								var LP_JSON = {
									action :'${dispatcher}/DSD1_1501/prompt',
									BEGIN_DATE : inBEGIN_DATE,
									AREA_CODE : inAREA_CODE,
									CHECK_TYPE : '${sCheckType}',
									QUERY_TYPE : 'D011',
									OLD_AREA_CODE : '${OLD_AREA_CODE}'　,
									IS_INIT : '${IS_INIT}'
								};								
								CSRUtil.linkTo(LP_JSON, 'form1');
							};
							
							return link;
							
						}

					},
					{header: '已繳件數' , key : 'COUNTS', attrs:{align:'center'}
						,render:function(rec,val){
							var tmpAREA_CODE;
							if(rec.isSum == '9999'){
							    if('${sCheckType}'=='81'){
							       tmpAREA_CODE = 'TOTAL';
							    }else if('${sCheckType}'=='82'){
							       tmpAREA_CODE = '${OLD_AREA_CODE}'.substring(0,2);
							    }							
							}else{
								tmpAREA_CODE = rec.AREA_CODE;
							}
							
							var link = new Element('a', { href : '#' });
							link.update(CSRUtil.$fmt(val,'#,###'));
							link.onclick = function() {
								var LP_JSON = {
									action :'${dispatcher}/DSD1_1502/prompt',
									AREA_CODE : tmpAREA_CODE,
									CHECK_TYPE : '${sCheckType}',
									OLD_AREA_CODE : '${OLD_AREA_CODE}'　,
									IS_INIT : '${IS_INIT}'
								};								
								CSRUtil.linkTo(LP_JSON, 'form1');
							};
							
							return link;
						}
					},
					{header: '件數比率(%)' , key : 'CNT_PER',
						render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###.0'):'0';
						}
					},
					{header: '金額(萬)' , key : 'D011_AMT_T', attrs:{align:'center'}, renderInCount:true
						,render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###'):'0';
						}
					
					},
					{header: '金額比率(%)' , key : 'AMT_PER',
						render:function(rec,val){
							return val ? CSRUtil.$fmt(val,'#,###.0'):'0';
						}
					}
					
				]
			});			
			<c:if test="${not empty CHECK_TYPE}">
				$('back_table').show();	
				$('btn_back').observe('click' , actions.doBack);
			</c:if>
							
			var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false"/>;
			var sumList = <c:out value="${sumList}" default="[]" escapeXml="false"/>;
				
			if(rtnList.length > 0){				
				sumList[0].value.D011_CNT =  CSRUtil.$fmt(sumList[0].value.D011_CNT,'#,###') || '0';
				sumList[0].value.COUNTS =  CSRUtil.$fmt(sumList[0].value.COUNTS,'#,###') || '0';				
				grid1.load(rtnList, sumList);
			}else{
				grid1.load([]);
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
		<table id = "grid1" ></table>
		<table id="back_table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style = "display:none">
			<tr>
				<td class="tbYellow2" align="center">
					<input type="button" id="btn_back" class="button" value="上一頁" /> 
				</td>
			</tr>
		</table>
</form>	
</body>
</html>