<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD10500.jsp
作者：黃子玹 
功能：催收明細查詢
完成：2013/07/04

[20210107] 修改件                                  
         新增「收費代號」欄位。                            
         將原本欄位「聯絡電話(日)」，改成「收費代號」                
         列印部分一併調整。
[20230418] 修改件: 查詢無行動電話者，整筆文字標示為紅色

[20230726]問題單20230725160154
將列印PDF改成excel格式
郭曉慧

[20240322]修改件 難字

 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<%-- [20240322]難字 --%>
<style type="text/css">
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

// 產生畫面物件
var DSD10500 = new DSD10500();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSD10500.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


	
//以下為UI() public method,放在 return 中
function DSD10500(){


		
	var grid;
	var rtnList;
	
	function buttonAuth(){
		var authButtons = {	
			B0174:"btn_print"		
		};
		<dz:grantButtons FUNC_ID="DSD10500" />
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_0500/" + actionName,
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
	
	
	//共用AJAX
	function ajaxPost1 ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_0500/" + actionName,
		{
			asynchronous: false,
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
	}//END   共用AJAX
	
	
	var actions = {
	
		//區域選單連動服務中心一下拉選單
		doChangeSRV_DEPT_List :  function(ADM_CENTER){	

			$('SRV_DEPT').options.length = 1;
			
			ajaxPost1( 'changesrv_dept_list',	{ADM_CENTER: ADM_CENTER},
				function(resp){			
					var SRV_DEPT_List = resp.SRV_DEPT_List || '';					
					SRV_DEPT_List.each(
						function(data) {							
							$('SRV_DEPT').add(new Option(data.SRV_DEPT_NAME, data.SER_DEPT_NO));
						}  
					); 	
				}					
			);

		},
		//服務中心一選單連動服務中心二三下拉選單
		doChangeSRV_DEPT2_List :  function(SRV_DEPT){	

			$('SRV_DEPT2').options.length = 1;
			
			ajaxPost1( 'changesrv_dept2_list',	{SRV_DEPT: SRV_DEPT},
				function(resp){			
					var SRV_DEPT2_List = resp.SRV_DEPT2_List || '';	
					
					var SRV_DEPT_NAME = $('SRV_DEPT').options[$('SRV_DEPT').selectedIndex].innerText.trim()
					$('SRV_DEPT2').add(new Option(SRV_DEPT_NAME, SRV_DEPT));	
					
					SRV_DEPT2_List.each(
						function(data) {							
							$('SRV_DEPT2').add(new Option(data.SRV_DEPT_NAME, data.SER_DEPT_NO));							
						}  
					); 					
							
				}					
			);

		},		
		//查詢
		doQuery : function(event) {
					
			var DEPT_ID =  $F('DEPT_ID');
			var ADM_CENTER =  $F('ADM_CENTER');
			if(!$('DEPT_ID_check').checked && !$('ADM_CENTER_check').checked){
				alert('請至少選擇一項收息單位或區域');
				return;	
			}
			//將畫面上的欄位存成reqMap			
			var reqMap = {	
				'DEPT_ID': '',
				'ADM_CENTER': '',
				'SRV_DEPT' : '', 
				'SRV_DEPT2' : '',
				'INPUT_DATE' : $F('INPUT_DATE')
			};
	
			if($('DEPT_ID_check').checked){
				
				if(!(DEPT_ID.length == 3 || DEPT_ID.length == 5|| DEPT_ID.length == 7)){
					alert('請輸入3或5或7碼的收息單位代號!');
					return;
				}
				
				reqMap['DEPT_ID'] = $F('DEPT_ID');
				
			}else if($('ADM_CENTER_check').checked){
				
				if(!ADM_CENTER){
					alert('請至少選擇一個區域!');
					return;				
				}
				var SRV_DEPT2 = $F('SRV_DEPT2');
				var SRV_DEPT = $F('SRV_DEPT');
				var ADM_CENTER = $F('ADM_CENTER');
				
				if(SRV_DEPT2){
					reqMap['SRV_DEPT2'] = SRV_DEPT2;						
				}else if(SRV_DEPT){
					reqMap['SRV_DEPT'] = SRV_DEPT;				
				}else{
					reqMap['ADM_CENTER'] = ADM_CENTER;				
				}					
			}			
		
			ajaxPost( 'query',	{reqMap:Object.toJSON(reqMap)},
				function(resp){
					rtnList = resp.rtnList || []; 
					grid.load(rtnList || []);
					var reqMap = resp.reqMap || {};					
					actions.doLink(reqMap);	
					$('btn_print').enable();	
					
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);	
					$('btn_print').disable();	
				}					
			);		
		},
		//超連結至 “DSD1_0501” 本月已催收件數統計畫面，供使用者看該單位的催收件數統計。
		doLink: function(reqMap){
				
				var link = new Element('a', { 'href' : '#'}).update("本月已催收件數統計");
				link.observe('click', //監聽click事件
					function( event ) {
						popupWin.popup({        
							'src': "<%=dispatcher%>/DSD1_0501/prompt",        
							'parameters': { 'DEPT_ID': reqMap.DEPT_ID, 'DIV_NO': reqMap.DIV_NO, 'DIV_KIND' : reqMap.DIV_KIND }    
						});                
					}
				);							
				$('showLink').update(link);
		},
		//列印
		doPrint : function(event) {
			
			if(!rtnList || rtnList.length == 0){
				alert('需做過查詢才能列印!');
				return;
			}
			var gridJSON = grid.getXlsSettingJSON("催收明細表"); 
			<%--[20230726]調整為xls--%>
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSD1_0500/print',
				{rtnList: Object.toJSON(rtnList), gridJSON: gridJSON}, false); 
		},
		<%-- 查詢無行動電話者，整筆文字標示為紅色 --%><%-- [20230418]新增程式碼 --%>
		gneRedText : function(rec, val) {
			if(!val && val!==0){
				return '';
			}
			var rec_MOBILE = rec.MOBILE;
			if(rec_MOBILE || rec_MOBILE===0){
				return val;
			} else {
				return new Element('span', {'class':'textRed'}).update(val);	
			}
		}
	};
	
	
	return{
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD10500" , "催收作業" , "催收明細查詢");
			
				grid = new TableUI({
				table: $('grid'), pageSize: 15, allSortable: true,
				<%-- [20240322]難字 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
                },
				column: [
					//{header:"當<br>輪<br>催<br>收<br>次<br>數<br>", key:'NCNT'}, //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位
					{header:"催<br>繳<br>次<br>數<br>", key:'CNT',
						render : function (rec , val){
							val = val || 0;
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}					
					},				
					{header:"相<br>關<br>案<br>件<br>", key:'REL_CASE',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"移<br>送<br>法<br>務<br>", key:'LOAN_STATUS',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}					
					},
					//{header:"信<br>保<br>貸<br>款<br>", key:'CRED_GUAR'}, //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位
					//{header:"921<br>案件<br>", key:'VICTIM_KIND_NM'}, //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位
					{header:"前<br>置<br>協<br>商<br>", key:'NEGO_STATUS',
						render : function (rec , val){
							val = (val || '')+(rec.NEGO_STATUS_NM || '');
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}					
					},				
					{header:"繳款<br>狀況<br>", key:'PAY_STATUS',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"約定<br>繳款日<br>", key:'DUE_DATE',
						render : function (rec , val){
							val = Date.toROC(val || '');
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"帳號<br>", key:'LOAN_ID',
						render : function(rec , val){							
							var link = new Element('a', { 'href' : '#'}).update(val);
							link.observe('click', //監聽click事件
								function( event ) {
								    var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+val+"&INPUT_TYPE=2";									
									window.open(url, "DSD1_0500", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");
							
								});
								return link;
						}
					},
					{header:"姓名<br>", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" },<%-- [20240322]難字 --%>
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"繳款<br>方式<br>", key:'PAY_TYPE_NM',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"簡訊<br>寄送狀態<br>", key:'SEND_STATUS',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"上次<br>實繳日<br>", key:'REAL_PAYDT',
						render : function (rec , val){
							val = Date.toROC(val || '');
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}				
					},					
					{header:"下次<br>應繳日<br>", key:'NEXT_PAYDATE',
						render : function (rec , val){
							val = Date.toROC(val || '');
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}					
					},
					/*{header:"滿期日<br>", key:'END_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");									
						}					
					}*/
					{header:"已繳<br>期數<br>", key:'PAY_TERM',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"本金餘額<br>", key:'REMAIN_AMT',attrs:{align:'right'},
						render : function(rec,val){						
							val = val ? CSRUtil.$fmt(val,'#,###.####') : 0;
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}					
					},			
					{header:"近半年<br>遲繳<br>次數<br>", key:'DELAY_TIMES',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"餘額<br>放款率<br>（％）<br>", key:'REMAIN_AMT_RATE', sortRule:'number',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					<%--[20210107] 刪除[ 聯絡電話(日) ]，取代為[ 收費代號 ]--%>
					{header:"收費代號", key:'RECEIVE_ID',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					/*{header:"聯絡電話<br>(日)", key:'DAY_TEL'
						render : function (rec , val){
									
							var DAY_TEL_AREA = rec.DAY_TEL_AREA || '';
							var DAY_TEL_NUM = rec.DAY_TEL_NUM || '';
							var DAY_TEL_EXT = rec.DAY_TEL_EXT || '';								
							
							if(DAY_TEL_AREA != ''&& DAY_TEL_NUM != '' && DAY_TEL_EXT!= ''){										
								return DAY_TEL_AREA+'-'+DAY_TEL_NUM+'#'+DAY_TEL_EXT									
							}else if(DAY_TEL_AREA != ''&& DAY_TEL_NUM != '' ){
								return DAY_TEL_AREA+'-'+DAY_TEL_NUM
							}else{
								return ''
							}		
						}				
					},*/
					{header:"聯絡電話<br>(夜)", key:'NIGHT_TEL',	
						/*
						render : function (rec , val){
											
							var NIGHT_TEL_AREA = rec.NIGHT_TEL_AREA || '';
							var NIGHT_TEL_NUM = rec.NIGHT_TEL_NUM || '';
							var NIGHT_TEL_EXT = rec.NIGHT_TEL_EXT || '';								
							
							if(NIGHT_TEL_AREA != ''&& NIGHT_TEL_NUM != '' && NIGHT_TEL_EXT!= ''){										
								return NIGHT_TEL_AREA+'-'+NIGHT_TEL_NUM+'#'+NIGHT_TEL_EXT									
							}else if(NIGHT_TEL_AREA != ''&& NIGHT_TEL_NUM != '' ){
								return NIGHT_TEL_AREA+'-'+NIGHT_TEL_NUM
							}else{
								return ''
							}		
						}*/					
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					{header:"行動電話<br>", key:'MOBILE',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},	
					//{header:"收費代號<br>", key:'RECEIVE_ID'}, //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位				
					{header:"經手人<br>", key:'AGENT_NAME', attrs:{ style:"font-family:'EUDC'" },<%-- [20240322]難字 --%>
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					},
					//{header:"經手人<br>單位<br>", key:'AGENT_DIV_NM'}, //2018-01-02申請書-催收明細查詢及逾四日未繳件明細查詢作業增加上次實繳日欄位 拿掉此欄位	 
					{header:"經手人<br>行動電話<br>", key:'AGENT_MOBILE',
						render : function (rec , val){
							return actions.gneRedText(rec, val); <%-- [20230418]修改程式碼: 查詢無行動電話者，整筆文字標示為紅色 --%>
						}
					}
					/*,
					{header:"擔保品地址<br>", key:'GAGE_ADDR',
						render :function(rec,val){
							return val ? CSRUtil.maskHandler.getMaskAddress(val) :''; 						
						}					
					}*/	
				]	
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
			
			// 查詢
			$('btn_query').observe('click', function(event){
				actions.doQuery();
			});
			//列印
			$('btn_print').observe('click', function(event){
				actions.doPrint();
			});
								
			//區域選單連動服務中心一下拉選單
			$('ADM_CENTER').observe('change', function(event){
				
				actions.doChangeSRV_DEPT_List(this.value); 
			});
			//服務中心一選單連動服務中心二三下拉選單
			$('SRV_DEPT').observe('change', function(event){
				
				actions.doChangeSRV_DEPT2_List(this.value); 
			});
			
			if('${SRV_DEPT}'){//如果初始服務中心一有值則重帶選單
				$('SRV_DEPT').simulate('change');				
				if('${SRV_DEPT2}'){
					$('SRV_DEPT2').value = '${SRV_DEPT2}';
				}	
			}
			
			
			$('btn_print').disable();
			buttonAuth();
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSD10500
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>		
				<td class="tbYellow" width= "7%" align="left" rowSpan ="2" >查詢方式</td>
				<td class="tbYellow" width= "3%" align="center">
					<input id ='DEPT_ID_check' name='QUERY_TYPE' type ='radio'  value='QUERY_ByDEPT_ID' checked/>
				</td>
				<td class="tbYellow"  width= "7%" align="left" >收息單位</td>		
				<td class="tbYellow2" width ="40%" colSpan ="5">
					<input id="DEPT_ID" type="text" class="textBox2"  size="12" maxlength="7" value = "${DIV_NO}" onblur="this.value=this.value.toUpperCase();"/>
					<input name="INPUT_DATE" id="INPUT_DATE" type="hidden" value="${INPUT_DATE}" >
				</td>				
				<td class="tbYellow2" width = "15%" align="left" rowSpan ="2" >
					<input id="btn_query" type="button" class="button" value="查詢">
					<input id="btn_print" type="button" class="button" value="列印">
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width= "3%" align="center">
					<input id ='ADM_CENTER_check' name='QUERY_TYPE' type ='radio'  value='QUERY_ByCRED_DEPT' />
				</td>
				<td class="tbYellow" width= "7%" >區域</td>										
				<td class="tbYellow2" width= "10%">
					<select id="ADM_CENTER" class="textBox2">
						<option value="">請選擇</option> 
						<c:forEach items="${ADM_CENTER_List}" var="map">							
							<option value="${map.key}"<c:if test="${map.key eq ADCD}">selected</c:if>>${map.value}</option>								
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width= "8%" >服務中心一</td>										
				<td class="tbYellow2"  width= "10%" >
					<select id="SRV_DEPT" name="SRV_DEPT" class="textBox2">	
						<option value="">全部</option>
						<c:forEach items="${SRV_DEPT_List}" var="map">							
							<option value="${map.SER_DEPT_NO}"<c:if test="${map.SER_DEPT_NO eq SRV_DEPT}">selected</c:if>>${map.SRV_DEPT_NAME}</option>
						</c:forEach>	
					</select>
				</td>
				<td class="tbYellow" width= "9%" >服務中心二三</td>										
				<td class="tbYellow2"  width= "10%" >
					<select id="SRV_DEPT2" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${SRV_DEPT2_List}" var="map">							
							<option value="${map.SER_DEPT_NO}"<c:if test="${map.SER_DEPT_NO eq SRV_DEPT2}">selected</c:if>>${map.SRV_DEPT_NAME}</option>
						</c:forEach>
					</select>
				</td>
			</tr>	
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td align="left" colSpan="7"><div id = 'showLink'> </div> </td>	
			</tr>
		</table>	
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
				<tr>
					<td class="tbYellow2">
					<font color="blue">***理財型催收件*** </font>
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.<font color="green">理財型房貸</font>催收件為前一次轉帳扣繳利息不成且該借款人已無可動用額度時，累積欠繳利息 
　　				<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;達1個月以上者，請通知客戶前來服務櫃檯補繳利息。  
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.<font color="green">理財型房貸</font>到期催收件為客戶理財型房貸到期，公司不同意展期，請通知客戶前來清償。 
					<br><br>
					<font color="blue">一、作業規定  </font>
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.各種貸款規定請參照放款作業手冊及發文規定。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.此作業可供催收人員查上個月的未繳件(六個月內)。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.<font color="green">篩選條件</font>：「下次應繳日」在本月之前的非催收款項件，【即查詢下次應繳日 小於<font color="blue">本月1日</font> 的件，	
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;但如繳款方式為 <font color="red">銀行轉帳、郵局轉帳</font>時，則判斷<font color="blue">(扣款日+2個工作天)</font>是否小於今日，的扣薪不足未繳件。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;《是：則符合催收件；否：則還不算催收件》】。 
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.本作業尚提供<font color="blue">新增、異動催收記錄、催收地址電話及列印催繳函、存證信函等</font>相關作業。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.催收超過<font color="blue">六個月以上</font>請至<font color="red">催收款項查詢</font>。
					<br><br>
					<font color="blue">二、操作方式</font>
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. 查詢方式有二：
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;●點選<font color="red">收息單位</font>查詢(輸入欲查詢之單位代號，如AA400……)。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;●點選<font color="red">區域</font>(選擇所欲查詢之區域，如北區服務部……)，再進入選取服務中心一或服務中心二、三查詢。
					<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.如欲列印催收報表，於查詢完成後，再按<font color="blue">列印</font>即可。
					</td>
				</tr>		
		</table>
	</form>		
</body>
</html>