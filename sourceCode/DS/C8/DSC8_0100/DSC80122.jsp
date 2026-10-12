<%@ page language="java" contentType="text/html; charset=BIG5"
    pageEncoding="BIG5"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" >
<!--
程式：DSC8_0122.java
作者：陳思涵 
功能：所有權人資料變更
完成：2013-09-05	

[20230316]修改件: 難字修改
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

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

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC80122().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC80122(){

	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0122/" + actionName,
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
	}//END   共用AJAX
	
	var buttons = {
		doQuery : function(){
		
			ajaxPost( 'query', {'LOAN_ID' :'${LOAN_ID}','SEQ_NO': '${SEQ_NO}' , 'APPLY_DATE': '${APPLY_DATE}', 'CHG_KIND': '${CHG_KIND}'}
				,function(resp){
					
					var rtnMap = resp.rtnMap || {};
					$$('#table span').each(
						function(ele){
							var id = ele.id;
							
							if(id == 'APPLY_DATE'){
								ele.update(Date.toROC(rtnMap[id]));
							}else { 
								ele.update(rtnMap[id] || '');
							}
					});
				}			
			);
		},
		doClose : function (){
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

	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC80122', '變更作業', '所有權人資料變更');
			
			$('btn_return').observe('click',buttons.doClose);
			
			//初始時執行查詢功能
			buttons.doQuery();
			
			PageUI.resize();			
			displayMessage();			
		}
	};

}

</script>
</head>
<body>

<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow"  width="15%">貸款帳號</td>
			<td class="tbYellow2">
				<span id="LOAN_ID"></span>
 			</td>
			<td class="tbYellow"  width="15%">受理編號</td>
			<td class="tbYellow2">
				<span id="APPLY_ID"></span>
			</td>
			
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">所有權人ID</td>
			<td class="tbYellow2">
				<span id="ID"></span>
			</td>
			<td class="tbYellow"  width="15%">所有權類別</td>
			<td class="tbYellow2">
				<span id="OWN_KIND"></span>
			</td>
		</tr>
		
		<tr>
			<td  colspan="4" align="left" class="tbYellow0">原始資料</td>
		</tr>
		
		<tr>
			<td class="tbYellow"  width="15%">地(建)號</td>
			<td class="tbYellow2">
				<span id="BUILD_NO1"></span>
			</td>
			<td class="tbYellow"  width="15%">所有權人姓名</td>
			<td class="tbYellow2">
				<span id="NAME1" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">所有權人生日</td>
			<td class="tbYellow2">
				<span id="BIRTHDAY1"></span>
			</td>
			<td class="tbYellow"  width="15%">建築完成日期</td>
			<td class="tbYellow2">
				<span id="FINISH_DATE1"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">持份</td>
			<td class="tbYellow2" colspan="3">
				<span id="HOLD1"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">面積</td> 
			<td class="tbYellow2">
				<span id="MEASURE1"></span> 平方公尺
			</td>
			<td class="tbYellow"  width="15%">單獨登記車位面積</td>
			<td class="tbYellow2">
				<span id="PARK_SPACE1"></span> 平方公尺
			</td>
		</tr>
		
		<tr>
			<td  colspan="4" align="left" class="tbYellow0">變更資料</td>
		</tr>
		
		<tr>
			<td class="tbYellow"  width="15%">地(建)號</td>
			<td class="tbYellow2">
				<span id="BUILD_NO2"></span>
			</td>
			<td class="tbYellow"  width="15%">所有權人姓名</td>
			<td class="tbYellow2">
				<span id="NAME2" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">所有權人生日</td>
			<td class="tbYellow2">
				<span id="BIRTHDAY2"></span>
			</td>
			<td class="tbYellow"  width="15%">建築完成日期</td>
			<td class="tbYellow2">
				<span id="FINISH_DATE2"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">持份</td>
			<td class="tbYellow2" colspan="3">
				<span id="HOLD2"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow"  width="15%">面積</td>
			<td class="tbYellow2">
				<span id="MEASURE2"></span> 平方公尺
			</td>
			<td class="tbYellow"  width="15%">單獨登記車位面積</td>
			<td class="tbYellow2">
				<span id="PARK_SPACE2"></span> 平方公尺
			</td>
		</tr>
		
		<tr>
			<td  colspan="4" class="tbYellow2"> 　　</td>
		</tr>
		
		<tr>
			<td class="tbYellow"  width="15%">作業人員</td>
			<td class="tbYellow2">
				<span id="INPUT_ID_NM" style="font-family:'EUDC'"></span> <%-- [20230316]難字style --%>
			</td>
			<td class="tbYellow"  width="15%">作業日期</td>
			<td class="tbYellow2">
				<span id="APPLY_DATE"></span>
			</td>
		</tr>
		
		<tr>
			<td  colspan="4" align="center" >
				<input id="btn_return" type="button" class="button" value="關閉視窗"/>
			</td>
		</tr>
</table>


</body>
</html>