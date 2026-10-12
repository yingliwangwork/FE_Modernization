<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!-- Import resource，新增請放下面 -->
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!--
程式：DSC80114.jsp
作者：許家龍
功能：個別優惠變更記錄
完成：2013/03/27

[20230316]修改件
難字調整
郭曉慧
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<!--[20230316]難字css  -->
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
    Event.observe(window, 'load', new DSC80114().initApp);
    Event.observe(window, 'resize', fix);
    Event.observe(window, 'scroll', fix);
    
    function DSC80114() {
		var rtnMap = <c:out value="${rtnMap}" default="{}" escapeXml="false" />;
		var buttons = {
			//關閉視窗
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
		}
	
		return{
			initApp:function(){
				PageUI.createPageWithAllBodySubElement("DSC80114", '變更作業', '個別優惠變更記錄');
			
				$("btn_close").observe('click',  buttons.doClose);	
				$w('LOAN_ID OPER_KIND BEGIN_DATE END_DATE ADJUST_REASON SPEC_ADJUST RENEGE_ADJUST FIX_RATE FRATE_TERM FRATE_ENDDATE INSU_PREFER AREA_CODE REGISTER_NO OLD_ID OLD_NM OLD_DATE OLD_DEPT OLD_DEPT_NM INPUT_ID INPUT_NM INPUT_DATE INPUT_DEPT INPUT_DEPT_NM').each(
					function(id){
				       if(id == 'SPEC_ADJUST' || id == 'FIX_RATE' || id == 'FRATE_TERM'){
				        	$(id).update(rtnMap[id]);
				       }else{
					       	$(id).update(rtnMap[id]||"");
					   }	
					}
				);	
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
				<td class="tbYellow2" width=20%" colSpan='5'><span id="LOAN_ID"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">作業方式</td>
				<td class="tbYellow2" width=20%"><span id="OPER_KIND"></span></td>
				<td class="tbYellow" width="15%">生效日期</td>
				<td class="tbYellow2" width=20%"><span id="BEGIN_DATE"></span></td>
				<td class="tbYellow" width="15%">終止日期</td>
				<td class="tbYellow2" width=20%"><span id="END_DATE"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">加減碼原因</td>
				<td class="tbYellow2" width=20%"><span id="ADJUST_REASON"></span></td>
				<td class="tbYellow" width="15%">優惠減碼</td>
				<td class="tbYellow2" width=20%"><span id="SPEC_ADJUST"></span></td>
				<td class="tbYellow" width="15%">違約金比例</td>
				<td class="tbYellow2" width=20%"><span id="RENEGE_ADJUST"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">固定優惠利率</td>
				<td class="tbYellow2" width=20%"><span id="FIX_RATE"></span></td>
				<td class="tbYellow" width="15%">固定優惠利率期數</td>
				<td class="tbYellow2" width=20%"><span id="FRATE_TERM"></span></td>
				<td class="tbYellow" width="15%">固定優惠利率終止日</td>
				<td class="tbYellow2" width=20%"><span id="FRATE_ENDDATE"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">是否保優</td>
				<td class="tbYellow2" width=20%"><span id="INSU_PREFER"></span></td>
				<td class="tbYellow" width="15%">區別代碼</td>
				<td class="tbYellow2" width=20%"><span id="AREA_CODE"></span></td>
				<td class="tbYellow" width="15%">登錄編號</td>
				<td class="tbYellow2" width=20%"><span id="REGISTER_NO"></span></td>
			</tr>
			<!--[20230316]人員姓名加難字style  -->
			<tr>
				<td class="tbYellow" width="15%">原輸入人員</td>
				<td class="tbYellow2" width=20%"><span id="OLD_ID"></span><br/><span id="OLD_NM" style="font-family:'EUDC'"></span></td>
				<td class="tbYellow" width="15%">原輸入日期</td>
				<td class="tbYellow2" width=20%"><span id="OLD_DATE"></span></td>
				<td class="tbYellow" width="15%">原輸入單位</td>
				<td class="tbYellow2" width=20%"><span id="OLD_DEPT"></span><br/><span id="OLD_DEPT_NM"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">變更人員</td>
				<td class="tbYellow2" width=20%"><span id="INPUT_ID"></span><br/><span id="INPUT_NM" style="font-family:'EUDC'"></span></td>
				<td class="tbYellow" width="15%">變更日期</td>
				<td class="tbYellow2" width=20%"><span id="INPUT_DATE"></span></td>
				<td class="tbYellow" width="15%">變更單位</td>
				<td class="tbYellow2" width=20%"><span id="INPUT_DEPT"></span><br/><span id="INPUT_DEPT_NM"></span></td>
			</tr>
			<tr>
				<td align='center' class='tbYellow2' colspan='6'>
				<input id='btn_close' type='button' class='button' value='關閉視窗' />
				</td>
			</tr>	
		</table>
	</form>		
</body>
</html>
