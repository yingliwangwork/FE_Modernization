<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC80111.jsp
作者：楊鈞傑
功能：平轉變更記錄
完成：2013/02/27

[20230317]修改件
難字處理
郭曉慧
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<!--[20230317]難字css  -->
<style type="text/css">
@font-face{
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		 url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight:normal;
	font-style:normal
}
</style>
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<!--alert訊息-->
<script type="text/javascript">

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSC80111().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC80111(){
	
	var rtnMap; 
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0111/" + actionName,
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
	
	// 數值顯示方式處理
	function numberFormat(value){
		return (value || value == 0) ? CSRUtil.$fmt(value, '#,###.########', 0) : '';
	}
	
	//==========================================================================
	// 功能按鈕
	//==========================================================================
	var actions = {
		
		doQuery: function(event){
					
			ajaxPost('query', {	LOAN_ID : '${LOAN_ID}', APPLY_DATE : '${APPLY_DATE}',CHG_KIND : '${CHG_KIND}',SEQ_NO : '${SEQ_NO}'}
				,function(resp){
								
					var rtnMap = resp.rtnMap;	
					
					//初始頁面顯示欄位
					$$('.class1').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					});

					//違約金、貸款餘額 : 千分位逗號顯示
					$('REMAIN_AMT').update(numberFormat(rtnMap['REMAIN_AMT']));
					$('RENEGE').update(numberFormat(rtnMap['RENEGE']));
					
					//優惠起期日欄位顯示
					for(var i = 1; i < 3; i++){
						$('PREFER_DATA'+i).update(rtnMap['PREFER_BEGNO'+i] + '期' + rtnMap['PREFER_BEGDT'+i] + '共' + rtnMap['PREFER_TERM'+i] + '期'); 
					}
				}			
			);
		},
		//--------------------------------------------------------------------------
		// 上一頁:執行關閉功能
		//--------------------------------------------------------------------------
		doClose : function(event){	
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
	
	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80111', '變更作業', '平轉變更記錄');
				
				//註冊DOM物件 : 監聽
				$('btn_close').observe('click',  actions.doClose);
				
				//初始時執行查詢功能
				actions.doQuery();
				
				//先把畫面區塊都調整到位再顯示訊息
				PageUI.resize();	
			
				//初始頁面alert訊息用	
				displayMessage();
				
			}// end initApp()
	};// end return--
} // end DSC80111

</script>
</head>
<body>
<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
		<tr>
			<td class='tbYellow' width='10%'>貸款帳號</td>
			<td class='tbYellow2' width='15%'>
				<div id='LOAN_ID' class='class1'></div>
			</td>
			<td class='tbYellow' width='10%'>變更日期</td>
			<td class='tbYellow2' width='15%'>
				<div id='APPLY_DATE' class='class1'></div>
			</td>
			<td class='tbYellow' width='10%'>序號</td>
			<td class='tbYellow2' width='15%' colspan="3">
				<div id='SEQ_NO' class='class1'></div>
			</td>
		</tr>

		<tr>
			<td class="tbYellow" >貸款餘額</td>
			<td class="tbYellow2"  >
				<div id="REMAIN_AMT" class='class1'></div>
			</td>
			<td class="tbYellow"  >平轉編號</td>
			<td class="tbYellow2" colspan="5">
				<div id="REGISTER_NO" class='class1'></div>
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow" >違約金方式</td>
			<td class="tbYellow2"  >
				<div id="RENEGE_KIND" class='class1'></div>
			</td>
			<td class="tbYellow"  >違約金</td>
			<td class="tbYellow2" colspan="5">
				<div id="RENEGE" class='class1'></div>
			</td>
		</tr>
		
	<tr>
		<td class='tbYellow' width='12%'>原利率代號</td>
		<td class='tbYellow2' width='15%'>
			<div id='PREFER_CODE1' class='class1'></div>
		</td>
		<td class='tbYellow' width='12%'>原優惠種類</td>
		<td class='tbYellow2' width='15%'>
			<div id='PREFER_TYPE1_NM' class='class1'></div>
		</td>
		<td class='tbYellow' width='16%'>原優惠起期日</td>
		<td class='tbYellow2' width='14%'>
			<div id='PREFER_DATA1'></div>
		</td>
		<td class='tbYellow' width='12%'>原同意優惠</td>
		<td class='tbYellow2' width='12%'>
			<div id='INSU_NOTE1' class='class1'></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow' width='10%'>新利率代號</td>
		<td class='tbYellow2' width='15%'>
			<div id='PREFER_CODE2' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%'>新優惠種類</td>
		<td class='tbYellow2' width='15%'>
			<div id='PREFER_TYPE2_NM' class='class1'></div>
		</td>
		<td class='tbYellow' width='16%'>新優惠起期日</td>
		<td class='tbYellow2' width='14%'>
			<div id='PREFER_DATA2'></div>
		</td>
		<td class='tbYellow' width='10%'>新同意優惠</td>
		<td class='tbYellow2' width='12%'>
			<div id='INSU_NOTE2' class='class1'></div>
		</td>
	</tr>
	
	<tr>
		<td class='tbYellow' width='10%' rowspan='2'>輸入人員</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
			<!--[20230317]人員姓名加難字style  -->
			<div id='INPUT_ID' class='class1'></div>
			<div id='INPUT_NM' class='class1' style="font-family:'EUDC'"></div>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>輸入日期</td>
		<td class='tbYellow2' width='15%' rowspan='2'>
			<div id='INPUT_DATE' class='class1'></div>
		</td>
		<td class='tbYellow' width='10%' rowspan='2'>輸入單位</td>
		<td class='tbYellow2' width='15%' rowspan='2' colspan="3">
			<div id='INPUT_DEPT' class='class1'></div>
			<div id='INPUT_DEPT_NM' class='class1'></div>
		</td>
	</tr>
	<tr>
	</tr>
	<tr>
		    <td align='center' class='tbYellow2' colspan='8'>
			<input id='btn_close' type='button' class='button' value='關閉視窗' />
			</td>
	</tr>
</table>
</form>
</body>
</html>