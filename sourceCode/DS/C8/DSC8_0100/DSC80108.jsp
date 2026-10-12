<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC80108.jsp
作者：卓達瑋
功能：貸款年期變更記錄
完成：2013/2/25

[20230316] 修改程式  楊青峰
難字調整
-->
	
<html>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<fmt:setBundle basename="TextResource" />
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<link href="<%=htmlBase%>/CM/js/ext/resources/css/ext-all.css" rel="stylesheet" type="text/css" />

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

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>




<script type="text/JavaScript">
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC80108().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80108(){
	
    //取值
	var LOAN_ID ='${LOAN_ID}';
	var APPLY_DATE ='${APPLY_DATE}';
	var CHG_KIND ='${CHG_KIND}';
	var SEQ_NO ='${SEQ_NO}';

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0108/" + actionName,
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
    var actions = {
	     // 數值顯示方式處理
		numberFormat : function (value) {
			return value ? CSRUtil.$fmt(value, '#,###.########', 0) : '';
		},
		doQuery: function(event){
		    ajaxPost( 'query', {'LOAN_ID' :LOAN_ID, 'APPLY_DATE':APPLY_DATE, 'CHG_KIND': CHG_KIND, 'SEQ_NO': SEQ_NO }
				,function(resp){
					//查詢成功,載入資料	
					rtnMap = resp.rtnMap;
					//初始頁面顯示欄位
					$$('#table1 div').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					});
					$('RATE_CODE').update(rtnMap['RATE_CODE']);
					$('REMAIN_AMT').update(actions.numberFormat(rtnMap['REMAIN_AMT']));
				}			
			);	
		}
				
	   
	};
	//按鈕功能
	var buttons = {
	    doClose : function(event){	
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
	};

	return {
			initApp : function() {
                
				PageUI.createPageWithAllBodySubElement("DSC80108", "收息資料更新", "貸款種類變更紀錄");	
			//-----------------------------------------------------
			      //以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------			
				$('btn_close').observe('click',  buttons.doClose);
				
				//初始時執行查詢功能
				actions.doQuery();

				fix();
				displayMessage();			
			}
	}		
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<form  id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
   
		<tr>
			<td class="tbYellow"  >貸款帳號</td>
			<td class="tbYellow2" >
				<div id="LOAN_ID"></div>
			</td>
			<td class="tbYellow" >變更日期</td>
			<td class="tbYellow2"  >
				<div id="APPLY_DATE"></div>
			</td>
			<td class="tbYellow"  >序號</td>
			<td class="tbYellow2">
				<div id="SEQ_NO"></div>
			</td>		
		</tr>
		<tr>
			<td class="tbYellow" >貸款餘額</td>
			<td class="tbYellow2"  >
				<div id="REMAIN_AMT"></div>
			</td>
			<td class="tbYellow"  >利率代號</td>
			<td class="tbYellow2" colspan=3 >
				<div id="RATE_CODE"></div>
			</td>
			
			
		</tr>
		<tr>
		    <td class="tbYellow"  >原貸款種類</td>
			<td class="tbYellow2"  >
				<div id="LOAN_KIND1"></div>
			</td>
			<td class="tbYellow" >原扣薪組別</td>
			<td class="tbYellow2" >
				<div id="SALARY_GROUP1"></div>
			</td>
			<td class="tbYellow" >原扣薪狀態</td>
			<td class="tbYellow2" >
				<div id="SALARY_STATUS1" ></div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  >原資料限制</td>
			<td class="tbYellow2" colspan=5 >
				<div id="LIMIT_CODE1" ></div>
			</td>
		</tr>
        <tr>
		    <td class="tbYellow"  >新貸款種類</td>
			<td class="tbYellow2"  >
				<div id="LOAN_KIND2"></div>
			</td>
			<td class="tbYellow" >新扣薪組別</td>
			<td class="tbYellow2" >
				<div id="SALARY_GROUP2"></div>
			</td>
			<td class="tbYellow" >新扣薪狀態</td>
			<td class="tbYellow2" >
				<div id="SALARY_STATUS2" ></div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  >新資料限制</td>
			<td class="tbYellow2" colspan=5 >
				<div id="LIMIT_CODE2" ></div>
			</td>
		</tr>		
		<tr>
		    <td class='tbYellow' rowspan='2'>輸入人員</td>
		    <td class='tbYellow2'  rowspan='2'>
		        <div id='INPUT_ID' ></div>
	         	<div id='INPUT_NM' style="font-family: 'EUDC'"></div> <%-- [20230316] --%>
		    </td>
		    <td class='tbYellow'  rowspan='2'>輸入日期</td>
		    <td class='tbYellow2'  rowspan='2'>
		        <div id='INPUT_DATE' ></div>
		    </td>
		    <td class='tbYellow' rowspan='2'>輸入單位</td>
		    <td class='tbYellow2'  rowspan='2'>
		        <div id='INPUT_DEPT' ></div>
		        <div id='INPUT_DEPT_NM' ></div>
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