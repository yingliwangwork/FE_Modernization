<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var selecList = {};

function initApp(){

	PageUI.createPage("DSA12500" , "受理作業" , "拆件複製功能");
	PageUI.loadin(["tableA"] ,1);

	cleanMsgBoard();
	
	displayMessage();
	
	buttonAuth();
	
	new UI().init();
		
	PageUI.resize(true);
}

function buttonAuth(){
	var authButtons = {
		B0045:"Btn_Copy" <%--案件複製 --%>
	};
	
	<dz:grantButtons FUNC_ID="DSA12500" ignored="false"/>	
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){
	
	var txBean = '/DSA1_2500/';
	var OLD_APPLY_ID = '';
	
	function ajaxPost( actionName, params, successAction , failAction)
    {
        new Ajax.Request( "<%=dispatcher%>" + txBean + actionName,
        {
			method: "post", parameters: params,
			onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if( successAction ) {
						successAction(resp);
					}
				}else{
					if( failAction ){
						failAction(resp);
					}						
				}
			}
        });
    }

	function query( event ){
		var TYPE = ''; 
		if($('TYPE_1').checked){
			TYPE = $F('TYPE_1');
		} 
	
		if($('TYPE_1').checked){
			var APPLY_ID = $F('APPLY_ID').toUpperCase();
			$('APPLY_ID').value = APPLY_ID;
			
			if( APPLY_ID === '' ){
				alert( "您必須填入受理編號的資料!!" );
				return;
			}
			
			var iframe = $('DSA1_1700_Temp');
			if( iframe ){
				Element.remove( iframe );
			}
			iframe = document.createElement('iframe');
			iframe.id = "DSA1_1700_Temp";
			iframe.src = "<%=dispatcher%>/DSA1_1700/prompt?APPLY_ID=" + APPLY_ID + '&titleNotDisplay=Y';
			iframe.width = "100%";
			iframe.scrolling="no";
			iframe.onload = function(){						
				iframe.height = 200+iframe.contentDocument.body.offsetHeight;
			}
			$('result').appendChild( iframe );						
			
			OLD_APPLY_ID = APPLY_ID;
		}
		//[20211223] 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。
		//刪除type2查詢
	}
	
	function copy( event ){
		var APPLY_ID = $F('APPLY_ID').toUpperCase();
		$('APPLY_ID').value = APPLY_ID;

		//[20211223] 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。
		
		var TYPE = ''; 
		if($('TYPE_1').checked){
			TYPE = $F('TYPE_1');
			if( APPLY_ID === '' ){
				alert( "您必須填入受理編號的資料!!" );
				return;
			}
			
			if( OLD_APPLY_ID === '' ){
				alert( "請先查詢再執行案件複製功能" );
				return;
			}
			
			if( APPLY_ID != OLD_APPLY_ID ){
				alert( "欲複製的受理編號與原先查詢的資料不同，無法作業!" );
				return;
			}
			if(!confirm("請確認是否要做拆件複製!!")){
				return;
			}
		} 
		//[20211223] 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。
		//刪除type2檢核
				
		ajaxPost( 'copy' , { APPLY_ID : APPLY_ID , OLD_APPLY_ID : OLD_APPLY_ID , TYPE : TYPE} , function(resp){
			$('APPLY_ID').value = resp.NEW_APPLY_ID;
			msgWin.setCallback(function(){
				query();
				msgWin.setCallback("");
			});
		});
	}

	//[20211223] 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。
	//刪除type2 click連動
	function clickType1( event ){
		$('APPLY_ID').disabled = false;
	}
	
	return{
	
		init:function(){
			//[20211223] 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。
			$('TYPE_1').observe('click' , clickType1 );
			//$('TYPE_2').observe('click' , clickType2 );
			$('Btn_Query').observe('click' , query );
			$('Btn_Copy').observe('click' , copy );
			$('TYPE_1').checked = true;
			clickType1();
		
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}
//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

		<form name="form1" id="form1" method="post" action="<%=dispatcher%>/DSA1_2500/prompt">
			<input name="LP_JSON" id="LP_JSON" type="hidden" value="">
			<input type="hidden" name="gridJSON" id="gridJSON" value="">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<!-- Block_4_Start 輸入區塊-->
				<tr>
					<td class="tbYellow" width="15%"><input type="radio" name="TYPE" id="TYPE_1" value="1">拆件複製</td>
					<td class="tbYellow" width="15%">受理編號</td>
					<td class="tbYellow2" width="45%" colspan="3">
						<input type="text" name="APPLY_ID" id="APPLY_ID" class="textBox2" maxlength="11" value="${param.APPLY_ID}" />
					</td>
					<td class="tbYellow2" align="center" width="25%" >
						<input id="Btn_Query" name="Btn_Query" type="button" class="button" value="查詢">
						<input id="Btn_Copy" name="Btn_Copy"   type="button" class="button" value="複製"> 														
					</td>	
				</tr>
				<tr >
					<td colSpan="8" id="result" class="tbYellow2">
					</td>
				</tr>
				<!-- 申請書211118003371-(變更書-關閉其他借新還舊)：因涉及作業權限與作業辦法修正，故自105年暫緩啟用至今。-->
				<!-- 刪除type2區域 -->
			</table>
		</form>
									
	</body>
</html>