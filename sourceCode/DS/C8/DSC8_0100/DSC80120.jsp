<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSC80120.jsp
功能：違約金控管變更記錄
作者：林秉宏
完成：2013/09/05

[20230316]修改件: 難字修改
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230316]新增style --%>
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
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC80120().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
	
	//--------------------------------------------------------------------------
	function DSC80120() {
	
		var rtnMap; 
		
		//共用AJAX
		var ajaxPost = function( actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC8_0120/' + actionName,
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
						//金額欄位
						$('RENEGE_AMT').update(gridFmtRender(rtnMap['RENEGE_AMT']));		
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
		
		// 金額格式化
		var gridFmtRender = function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
		};				
	
		return{
		
			initApp  : function(){		
				
				PageUI.createPageWithAllBodySubElement( 
					'DSC80120' , 
					'變更作業' ,		
					'違約金控管變更記錄'				
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
<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">

	<tr>
		<td class='tbYellow' width='15%' >
			貸款帳號
		</td>
		<td class='tbYellow2' width='85%' colspan="5">
			<div id='LOAN_ID' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow' width='15%'>
			作業方式
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='OPER_KIND' ></div>
		</td>
		<td class='tbYellow' width='10%'>
			生效期數
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='BEGIN_TIMES' >
		</div>
		</td>
		<td class='tbYellow' width='10%'>
			終止期數
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='END_TIMES' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow' width='15%'>
			加減碼原因
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='ADJUST_REASON' ></div>
		</td>
		<td class='tbYellow' width='10%'>
			違約金比例
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='RENEGE_RATE' >
		</div>
		</td>
		<td class='tbYellow' width='10%'>
			提前清償控管金額
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='RENEGE_AMT' ></div>
		</td>
	</tr>

	<tr>
		<td class='tbYellow' width='15%'>
			共同控管帳號
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='CONTROL_REFER_ID' ></div>
		</td>
		<td class='tbYellow' width='10%'>
			區別代碼
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='AREA_KIND' ></div>
		</td>
		<td class='tbYellow' width='10%'>
			登錄編號
		</td>
		<td class='tbYellow2' width='15%'>
			<div id='REGISTER_NO' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			原輸入人員
		</td>
		<td class='tbYellow2'>
			<div id='OLD_ID' ></div>
			<div id='OLD_NM' style="font-family:'EUDC'"></div><%-- [20230316]難字style --%>
		</td>
		<td class='tbYellow'>
			原輸入日期
		</td>
		<td class='tbYellow2'>
			<div id='OLD_DATE' ></div>
		</td>
		<td class='tbYellow'>
			原輸入單位
		</td>
		<td class='tbYellow2'>
			<div id='OLD_DEPT' ></div>
			<div id='OLD_DEPT_NM' ></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow'>
			變更人員
		</td>
		<td class='tbYellow2'>
			<div id='INPUT_ID' ></div>
			<div id='INPUT_NM' style="font-family:'EUDC'"></div><%-- [20230316]難字style --%>
		</td>
		<td class='tbYellow'>
			變更日期
		</td>
		<td class='tbYellow2'>
			<div id='INPUT_DATE' ></div>
		</td>
		<td class='tbYellow'>
			變更單位
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