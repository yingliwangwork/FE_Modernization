<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!-- Import resource，新增請放下面 -->
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!--
程式：DSC80113.jsp
作者：李佳興
功能：優質客戶變更記錄
完成：2013/03/19

[20230317]修改件
難字調整
郭曉慧
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript'>

    // 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
    Event.observe(window, 'load', new DSC80113().initApp);
    Event.observe(window, 'resize', fix);
    Event.observe(window, 'scroll', fix);
    
    function DSC80113() {
		var rtnMap = <c:out value="${rtnMap}" default="{}" escapeXml="false" />;
		var buttons = {
			doBack: function(event) {
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
		}
	
		return{
			initApp:function(){
				PageUI.createPageWithAllBodySubElement("DSC80113", '變更作業', '優質客戶變更紀錄');
			
				$("BTN_back").observe('click', buttons.doBack);	

				$('LOAN_ID').update(rtnMap.LOAN_ID);
				$('APPLY_DATE').update(rtnMap.APPLY_DATE);
				$('SEQ_NO').update(rtnMap.SEQ_NO);
				$('VIP_BEGDT1').update(rtnMap.VIP_BEGDT1);
				$('VIP_GRADE1').update(rtnMap.VIP_GRADE1);
				$('VIP_BEGDT2').update(rtnMap.VIP_BEGDT2);	
				$('VIP_GRADE2').update(rtnMap.VIP_GRADE2);
				$('INPUT_ID').update(rtnMap.INPUT_ID );
				$('INPUT_NM').update( rtnMap.INPUT_NM );
				$('INPUT_DATE').update(rtnMap.INPUT_DATE);
				$('INPUT_DEPT').update(rtnMap.INPUT_DEPT );
				$('INPUT_DEPT_NM').update( rtnMap.INPUT_DEPT_NM);
				
				PageUI.resize();		
				displayMessage();	
				
			}//end init()--
		};//end return--
	}
</script>
</head>
<body >	
	<form id="form1" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table width="100%" border="0" cellspacing="1" cellpadding="0"class="tbBox2" id="table1">
			<tr>
				<td class="tbYellow" width="15%">貸款帳號</td>
				<td class="tbYellow2" width=20%" id="LOAN_ID">
					<span id="LOAN_ID"></span>
				</td>
				<td class="tbYellow" width="15%">變更日期</td>
				<td class="tbYellow2" id="APPLY_DATE" width=20%">
					<span id="APPLY_DATE"></span>
				</td>	
				<td class="tbYellow" width="15%">序號</td>
				<td class="tbYellow2" id="SEQ_NO" width="15%">
					<span id="SEQ_NO"></span>
				</td>	
			</tr>
			
			<tr>
				<td class="tbYellow">原優惠起日</td>
				<td class="tbYellow2" id="VIP_BEGDT1">
					<span id="VIP_BEGDT1"></span>
				</td>
				<td class="tbYellow">原優惠種類</td>
				<td class="tbYellow2" id="VIP_GRADE1" colspan="3">
					<span id="VIP_GRADE1"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">新優惠起日</td>
				<td class="tbYellow2" id="VIP_BEGDT2">
					<span id="VIP_BEGDT2"></span>
				</td>
				<td class="tbYellow">新優惠種類</td>
				<td class="tbYellow2" id="VIP_GRADE2" colspan="3">
					<span id="VIP_GRADE2"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">輸入人員</td>
				<td class="tbYellow2" >
					<!--[20230317]人員姓名加難字style  -->
					<span id="INPUT_ID"></span><BR><span id="INPUT_NM" style="font-family:'EUDC'"></span>
				</td>
				<td class="tbYellow">輸入日期</td>
				<td class="tbYellow2" id="INPUT_DATE">
					<span id="INPUT_DATE"></span>
				</td>
				<td class="tbYellow">輸入單位</td>
				<td class="tbYellow2" >
					<span id="INPUT_DEPT"></span><BR><span id="INPUT_DEPT_NM"></span>
				</td>
			</tr>
			<tr>
				<td align='center' class='tbYellow2' colspan='8'>
				<input id='BTN_back' type='button' class='button' value='關閉視窗' />
				</td>
			</tr>	
		</table>
	</form>	
</body>
</html>