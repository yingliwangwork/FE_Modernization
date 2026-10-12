<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSC80110.jsp
功能：擔保地址變更記錄
作者：林秉宏
完成：2013/02/26

[20230316] 修改程式  楊青峰
難字調整
 -->

<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230316] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>

<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript'>

	// 產生畫面物件
	var dsc80110 = new DSC80110();
	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', dsc80110.initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
	
	//--------------------------------------------------------------------------
	function DSC80110() {
	
		var rtnMap; 
		
		//共用AJAX
		var ajaxPost = function( actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_0110/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};	
		
		var actions = {		
		
			//查詢
			doQuery : function(){		
				
				ajaxPost( 'query' , { 'LOAN_ID' : '${LOAN_ID}', 'APPLY_DATE' : '${APPLY_DATE}', 'CHG_KIND' : '${CHG_KIND}', 'SEQ_NO' : '${SEQ_NO}'  },
					function(resp){		
					
						//載入資料					
						rtnMap = resp.rtnMap;
						
						$$('#table1 div').each(function(ele){
							var id = ele.id;
							ele.update(rtnMap[id] || '');
						});				
					}
				);
			},
			
			//上一頁：關閉視窗
			doClose : function(){

				if(window.isPopupWin && window.popupWinBack){
				   // 呼叫callback Function(若有) 並關閉
				   window.popupWinBack(rtnMap); 
				}else if(window.parent && window.parent.popupWin){
					//呼叫callback Function(若有) 並關閉
				   window.parent.popupWin.back(rtnMap);
				}else{
					CSRUtil.linkBack();
				}	
			}														
		};
		
		//金額格式化
		var gridFmtRender = function(value) {
			return value ? CSRUtil.$fmt(value, '#,##0.####', 0) : '';
		};				
	
		return{
		
			initApp  : function(){		
				
				PageUI.createPageWithAllBodySubElement( 
					'DSC80110' , 
					'變更作業' ,		
					'擔保地址變更記錄'				
				);											
								
				//上一頁
				$('BTN_close').observe('click', actions.doClose );
				
				//初始時執行查詢功能
				actions.doQuery(); 
		 
				PageUI.resize();	
				displayMessage();	
							
			} //end init()--
		}; //end return--
	
	}

</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
	
	<tr>
		<td class='tbYellow' width='15%'>
			貸款帳號
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='LOAN_ID' ></div>
		</td>
		<td class='tbYellow' width='10%'>
			變更日期
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='APPLY_DATE' >
		</div>
		</td>
		<td class='tbYellow' width='10%'>
			序號
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='SEQ_NO' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			原擔保品資料
		</td>
		<td class='tbYellow2' width='15%' colspan='5'>
			<div id='ADDRESS1' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			原澄清特區
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='SPEC_AREA1' ></div>
		</td>
		<td class='tbYellow'>
			原地區代號
		</td>
		<td class='tbYellow2' width='15%' colspan='3'>
			<div id='AREA_CODE1' ></div>
		</td>
	</tr>

		<tr>
		<td class='tbYellow'>
			新擔保品資料
		</td>
		<td class='tbYellow2' width='15%' colspan='5'>
			<div id='ADDRESS2' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			新澄清特區
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='SPEC_AREA2' ></div>
		</td>
		<td class='tbYellow'>
			新地區代號
		</td>
		<td class='tbYellow2' width='15%' colspan='3'>
			<div id='AREA_CODE2' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			輸入人員
		</td>
		<td class='tbYellow2'>
			<div id='INPUT_ID' ></div>
			<div id='INPUT_NM' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		</td>
		<td class='tbYellow'>
			輸入日期
		</td>
		<td class='tbYellow2'>
			<div id='INPUT_DATE' ></div>
		</td>
		<td class='tbYellow'>
			輸入單位
		</td>
		<td class='tbYellow2'>
			<div id='INPUT_DEPT' ></div>
			<div id='INPUT_DEPT_NM' ></div>
		</td>
	</tr>
	<tr>
		<td align='center' class='tbYellow2' colspan='6'>
			<input id='BTN_close' type='button' class='button' value='關閉視窗' />
		</td>
	</tr>
</table>

</form>
</body>
</html>