<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>

<!-- Import resource，新增請放下面 -->
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!--
程式：DSC80115.jsp
作者：黃子玹
功能：借款資料變更記錄
完成：2013-04-01

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
    Event.observe(window, 'load', new DSC80115().initApp);
    Event.observe(window, 'resize', fix);
    Event.observe(window, 'scroll', fix);
    
    function DSC80115() {
	
		var LOAN_ID = '${LOAN_ID}';
		var APPLY_DATE = '${APPLY_DATE}';
		var CHG_KIND = '${CHG_KIND}';	
		var SEQ_NO = '${SEQ_NO}';		
		
		//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC8_0115/" + actionName,
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
		
		function numberFormat(value) {
			return value ? CSRUtil.$fmt(value, '#,###', 0) : 0;
		}
		
		var actions = {			
			
			//查詢
			doQuery : function(event) {			
							
				ajaxPost( 'query',	{LOAN_ID : LOAN_ID, APPLY_DATE : APPLY_DATE, CHG_KIND : CHG_KIND, SEQ_NO : SEQ_NO},
					function(resp){
						var rtnMap = resp.rtnMap;
					
						$w('LOAN_ID APPLY_DATE SEQ_NO BORROW_ID1 BORROW_NAME1 BIRTHDAY1 END_DATE1 AGENT_ID1 CRED_DEPT1 LOAN_TYPE1 LIMIT_CODE1 EXTRA_CODE1 AREA_CODE1 TAX_CODE1 SALARY_GROUP1 SALARY_STATUS1 DUTY_DAY1 SPEC_CODE1 GROUP_NOTE1A GROUP_NOTE1D BORROW_ID2 BORROW_NAME2 BIRTHDAY2 END_DATE2 AGENT_ID2 CRED_DEPT2 LOAN_TYPE2 LIMIT_CODE2 EXTRA_CODE2 AREA_CODE2 TAX_CODE2 SALARY_GROUP2 SALARY_STATUS2 DUTY_DAY2 SPEC_CODE2 GROUP_NOTE2A GROUP_NOTE2D INPUT_ID INPUT_NM INPUT_DATE INPUT_DEPT INPUT_DEPT_NM').each(
							function(id){
								$(id).update(rtnMap[id]||"");
							}
						);
						
						$w('GROUP_CODE1 CRED_GUAR1 PAID_TIMES1 VALID_TIMES1 PREPAY_TIMES1 GROUP_CODE2 CRED_GUAR2 PAID_TIMES2 VALID_TIMES2 PREPAY_TIMES2').each(function(id){
							if(rtnMap[id] === 0){
								$(id).update("0");
							}else{
								$(id).update(rtnMap[id]||"");
							}
						})
						
						$('RETAIN_INT1').update(numberFormat(rtnMap['RETAIN_INT1']));
						$('RETAIN_INT2').update(numberFormat(rtnMap['RETAIN_INT2']));
					}			
				);				
			},
			
			//上一頁
			doBack : function(event) {
			   if(window.isPopupWin && window.popupWinBack){
				   // 呼叫callback Function(若有) 並關閉
				   window.popupWinBack(); 
				}else if(window.parent && window.parent.popupWin){
					//呼叫callback Function(若有) 並關閉
				   window.parent.popupWin.back();
				}else{
					CSRUtil.linkBack();
				}	
			}
		}
	
		return{
			initApp:function(){
				PageUI.createPageWithAllBodySubElement("DSC80115", '變更作業', '借款資料變更記錄');
			
				$("BTN_back").observe('click', actions.doBack);	
				
				actions.doQuery();			
				
				PageUI.resize();		
				displayMessage();	
				
			}//end init()--
		};//end return--
	}// end DSC80115
</script>
</head>
<body >	
	<form id="form1" style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table width="100%" border="0" cellspacing="1" cellpadding="0"class="tbBox2" id="table1">
			<tr>
				<td class="tbYellow" width="15%">貸款帳號</td>
				<td class="tbYellow2" width="20%"><span id="LOAN_ID"></span></td>
				<td class="tbYellow" width="15%">變更日期</td>
				<td class="tbYellow2" width="20%"><span id="APPLY_DATE"></span></td>
				<td class="tbYellow" width="15%">序號</td>
				<td class="tbYellow2" width="20%"><span id="SEQ_NO"></span></td>				
			</tr>
			<tr>			
				<td class="tbYellow2" width="100%" colspan ='6'>&nbsp;</td>								
			</tr>
			<!--[20230317]人員姓名加難字style  -->
			<tr>
				<td class="tbYellow" width="15%">原借款人ＩＤ</td>
				<td class="tbYellow2" width="20%"><span id="BORROW_ID1"></span></td>
				<td class="tbYellow" width="15%">原借款人姓名</td>
				<td class="tbYellow2" width="20%" colspan ='4'><span id="BORROW_NAME1" style="font-family:'EUDC'"></span></td>				
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原出生日期</td>
				<td class="tbYellow2" width="20%"><span id="BIRTHDAY1"></span></td>
				<td class="tbYellow" width="15%">原滿期日期</td>
				<td class="tbYellow2" width="20%"><span id="END_DATE1"></span></td>
				<td class="tbYellow" width="15%">原經手人</td>
				<td class="tbYellow2" width="20%"><span id="AGENT_ID1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原承辦科別</td>
				<td class="tbYellow2" width="20%"><span id="CRED_DEPT1"></span></td>
				<td class="tbYellow" width="15%">原貸款類別</td>
				<td class="tbYellow2" width="20%"><span id="LOAN_TYPE1"></span></td>
				<td class="tbYellow" width="15%">原資料限制</td>
				<td class="tbYellow2" width="20%"><span id="LIMIT_CODE1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原集團代碼</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_CODE1"></span></td>
				<td class="tbYellow" width="15%">原專案額度外</td>
				<td class="tbYellow2" width="20%">
				<span id="EXTRA_CODE1"></span>
				<input type="checkbox" name="option1" value="">
				</td>
				<td class="tbYellow" width="15%">原信保貸款</td>
				<td class="tbYellow2" width="20%"><span id="CRED_GUAR1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原已繳期數</td>
				<td class="tbYellow2" width="20%"><span id="PAID_TIMES1"></span></td>
				<td class="tbYellow" width="15%">原有效期數</td>
				<td class="tbYellow2" width="20%"><span id="VALID_TIMES1"></span></td>
				<td class="tbYellow" width="15%">原預繳期數</td>
				<td class="tbYellow2" width="20%"><span id="PREPAY_TIMES1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原年底應利</td>
				<td class="tbYellow2" width="20%"><span id="RETAIN_INT1"></span></td>
				<td class="tbYellow" width="15%">原地區代號</td>
				<td class="tbYellow2" width="20%"><span id="AREA_CODE1"></span></td>
				<td class="tbYellow" width="15%">原代扣稅款</td>
				<td class="tbYellow2" width="20%"><span id="TAX_CODE1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">原扣薪組別</td>
				<td class="tbYellow2" width="20%"><span id="SALARY_GROUP1"></span></td>
				<td class="tbYellow" width="15%">原扣薪狀態</td>
				<td class="tbYellow2" width="20%"><span id="SALARY_STATUS1"></span></td>
				<td class="tbYellow" width="15%">原每月應繳日</td>
				<td class="tbYellow2" width="20%"><span id="DUTY_DAY1"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">延滯息違約金</td>
				<td class="tbYellow2" width="20%"><span id="SPEC_CODE1"></span></td>
				<td class="tbYellow" width="15%">原金雞獨利優惠</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_NOTE1A"></span></td>
				<td class="tbYellow" width="15%">原利率調整方式</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_NOTE1D"></span></td>
			</tr>
			<tr>			
				<td class="tbYellow2" width="100%" colspan ='6'>&nbsp;</td>								
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新借款人ＩＤ</td>
				<td class="tbYellow2" width="20%"><span id="BORROW_ID2"></span></td>
				<td class="tbYellow" width="15%">新借款人姓名</td>
				<td class="tbYellow2" width="20%" colspan ='4'><span id="BORROW_NAME2" style="font-family:'EUDC'"></span></td>				
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新出生日期</td>
				<td class="tbYellow2" width="20%"><span id="BIRTHDAY2"></span></td>
				<td class="tbYellow" width="15%">新滿期日期</td>
				<td class="tbYellow2" width="20%"><span id="END_DATE2"></span></td>
				<td class="tbYellow" width="15%">新經手人</td>
				<td class="tbYellow2" width="20%"><span id="AGENT_ID2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新承辦科別</td>
				<td class="tbYellow2" width="20%"><span id="CRED_DEPT2"></span></td>
				<td class="tbYellow" width="15%">新貸款類別</td>
				<td class="tbYellow2" width="20%"><span id="LOAN_TYPE2"></span></td>
				<td class="tbYellow" width="15%">新資料限制</td>
				<td class="tbYellow2" width="20%"><span id="LIMIT_CODE2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新集團代碼</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_CODE2"></span></td>
				<td class="tbYellow" width="15%">新專案額度外</td>
				<td class="tbYellow2" width="20%">
				<span id="EXTRA_CODE2"></span>
				<input type="checkbox" name="option1" value="">
				</td>
				<td class="tbYellow" width="15%">新信保貸款</td>
				<td class="tbYellow2" width="20%"><span id="CRED_GUAR2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新已繳期數</td>
				<td class="tbYellow2" width="20%"><span id="PAID_TIMES2"></span></td>
				<td class="tbYellow" width="15%">新有效期數</td>
				<td class="tbYellow2" width="20%"><span id="VALID_TIMES2"></span></td>
				<td class="tbYellow" width="15%">新預繳期數</td>
				<td class="tbYellow2" width="20%"><span id="PREPAY_TIMES2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新年底應利</td>
				<td class="tbYellow2" width="20%"><span id="RETAIN_INT2"></span></td>
				<td class="tbYellow" width="15%">新地區代號</td>
				<td class="tbYellow2" width="20%"><span id="AREA_CODE2"></span></td>
				<td class="tbYellow" width="15%">新代扣稅款</td>
				<td class="tbYellow2" width="20%"><span id="TAX_CODE2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">新扣薪組別</td>
				<td class="tbYellow2" width="20%"><span id="SALARY_GROUP2"></span></td>
				<td class="tbYellow" width="15%">新扣薪狀態</td>
				<td class="tbYellow2" width="20%"><span id="SALARY_STATUS2"></span></td>
				<td class="tbYellow" width="15%">新每月應繳日</td>
				<td class="tbYellow2" width="20%"><span id="DUTY_DAY2"></span></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">延滯息違約金</td>
				<td class="tbYellow2" width="20%"><span id="SPEC_CODE2"></span></td>
				<td class="tbYellow" width="15%">新金雞獨利優惠</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_NOTE2A"></span></td>
				<td class="tbYellow" width="15%">新利率調整方式</td>
				<td class="tbYellow2" width="20%"><span id="GROUP_NOTE2D"></span></td>
			</tr>
			<tr>			
				<td class="tbYellow2" width="100%" colspan ='6'>&nbsp;</td>								
			</tr>
			<tr>
				<td class="tbYellow" width="15%">輸入人員</td>
				<td class="tbYellow2" width="20%"><span id="INPUT_ID"></span><br><span id="INPUT_NM" style="font-family:'EUDC'"></span></td>
				<td class="tbYellow" width="15%">輸入日期</td>
				<td class="tbYellow2" width="20%"><span id="INPUT_DATE"></span></td>
				<td class="tbYellow" width="15%">輸入單位</td>
				<td class="tbYellow2" width="20%"><span id="INPUT_DEPT"></span><br><span id="INPUT_DEPT_NM"></span></td>
			</tr>
			
			<tr>
				<td align='center' class='tbYellow2' colspan='6'>
				<input id='BTN_back' type='button' class='button' value='關閉視窗' />
				</td>
			</tr>	
		</table>
	</form>	
</body>
</html>