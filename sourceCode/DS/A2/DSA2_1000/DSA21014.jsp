<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21014.jsp
作者：i9100621
功能：主管裁決批示
完成：2011/11/3
20200701申請書-主管批示裁決畫面新增欄位 BY余凱鈞
[20221226]修改件
[申請書:220725005491]新增本金彈性還還款方式 
郭曉慧
-->
<html>
<head>
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>
<script language="JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA21014" , "核貸作業" , "主管裁決批示", 0,'${titleNotDisplay}' == 'Y');
	displayMessage();
	buttonAuth();
	
	//TableUI的產生        
	new UI().init();
	autoFormatToNumber(); 
	
}

function buttonAuth(){
	var authButtons = {
			B0075:"btn_agree"<%--核准--%> ,
			B0052:"btn_confirm"<%--繼續呈核--%> ,
			B0008:"btn_reject"<%--退回--%>,
			B0079:"btn_getFile"<%--鑑價影像檔--%>,
			B0130:"btn_elandImage"<%--電子謄本影像--%>
	};
	<dz:grantButtons FUNC_ID="DSA21014" ignored="false"/>
}

var INST_TYPE = '${INST_TYPE}';
var INST_LEVEL = '${INST_LEVEL}';
var REJ_LEVEL = '${REJ_LEVEL}';

var grid;
INST_LEVEL = (INST_LEVEL==''||INST_LEVEL==null)? INST_LEVEL: parseInt(INST_LEVEL,10);
REJ_LEVEL = (REJ_LEVEL==''||REJ_LEVEL==null)? REJ_LEVEL: parseInt(REJ_LEVEL,10);

var actions = {

	//共用ajax
	ajaxPost : function( actionName, params, successAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA2_1014/" + actionName,{  
				parameters: params, 
				onSuccess: function(response){ successAction(response.responseJSON );
			}
		});
	}
};

var changeEvent  = {
	//(C區)定期/分期年月欄位 disable 控制
	
	FIX_SPR_CONTROL :function (xRETURN_TYPE){

		$('FIX_YY').disabled = false;
		$('FIX_MM').disabled = false;
		$('SPR_YY').disabled = false;
		$('SPR_MM').disabled = false;
		
		if(xRETURN_TYPE == '1'){ //分期:(C區)定期年月欄位無法輸入
			$('FIX_YY').disabled = true;
			$('FIX_MM').disabled = true;
			
		}else if(xRETURN_TYPE == '3'){ //定期	:(C區)分期年月欄位無法輸入
			$('SPR_YY').disabled = true;
			$('SPR_MM').disabled = true;
		}			
	},
	
	buttonShow:	function(v){
		if(((INST_TYPE == 'G' || INST_TYPE == 'A' || INST_TYPE == 'B') && v <= INST_LEVEL) || (INST_TYPE == 'R' && REJ_LEVEL == INST_LEVEL)){
			$('btn_agree_div').style.display = '';

		}else{
			$('btn_agree_div').style.display = 'none';
		}
		if(INST_TYPE == 'B'){ 
			$('btn_elandImage_div').style.display = '';
			$('btn_DSA21002_div').style.display = '';
		}else{
			$('btn_elandImage_div').style.display = 'none';
			$('btn_DSA21002_div').style.display = 'none';
		}
			
		if (INST_LEVEL == 90) {
			$('btn_confirm_div').style.display = 'none';
		} else if (INST_TYPE == 'R') {
			if (REJ_LEVEL > INST_LEVEL) {
				$('btn_confirm_div').style.display = '';
			} else {
				$('btn_confirm_div').style.display = 'none';
			}
		} else {
			$('btn_confirm_div').style.display = '';
		}
	},
	
	doShowHistory:function(){
		if($('div_I').style.display != 'none'){
			$('div_I').style.display = 'none';
		}else{
			$('div_I').style.display = 'block';
		}
	},

	doShowFileList:function(){
		if($('div_J').style.display != 'none'){
			$('div_J').style.display = 'none';
		}else{
			$('div_J').style.display = 'block';
		}
	}
}

function UI(){                

	var valid1;
	
	var A010Map;
	var A130Map;
	var rejectMap;
	var exeAction;
	var radioHasCheck = false;//避免radio重複檢查

	
    // confirm訊息
	function confirmMsg2(msg){
		if(msg){
			return confirm(msg);
		}

		return true;
	}
	//頁面<input>enable控制
	function colEditControl(){
		//C區可編輯
		if((INST_TYPE == 'G' || INST_TYPE == 'A' || INST_TYPE == 'B')&& INST_LEVEL <= 50){
			var inputs = $('blockC').getElementsByTagName('INPUT');
			Element.extend(inputs);
			$A(inputs).each(function(it){
				//[申請書211123002869]配合稽核室查核意見，進行呈核層級系統檢核卡控
				if(it.name == 'TRANS_CODE'){
					it.disabled = true;
				}else{
					it.disabled = false;
				}
			});
			
			var selects = $('blockC').getElementsByTagName('SELECT');
			Element.extend(selects);
			$A(selects).each(function(it){
				it.disabled = false;
			});
			
			var textareas = $('blockC').getElementsByTagName('TEXTAREA');
			Element.extend(textareas);
			$A(textareas).each(function(it){
				it.disabled = false;
			});
			
			changeEvent.FIX_SPR_CONTROL(A010Map.RETURN_TYPE);
			if($('IS_ONLINE0')){
				$('IS_ONLINE0').disabled = true;
			}
			if($('IS_ONLINE1')){
				$('IS_ONLINE1').disabled = true;
			}
			if($('IS_ONLINE_SHOW')){
				$('IS_ONLINE_SHOW').hide();
			}
		}
		
		changeEvent.buttonShow(A130Map.AGREE_LEVEL);

		if((A010Map.GAGE_TYPE != '1')){
			$('btn_DSA21006').disabled = true;
		}else{
			$('btn_DSA21006').disabled = false;
		}
		//非影像件,不開啟影像連結
		if ((A010Map.TOTAL_PAGE != null && A010Map.TOTAL_PAGE != '' && parseInt(A010Map.TOTAL_PAGE) > 0) || A010Map.FORM_TYPE == 'S') {
			$('btn_DSA00200').disabled = false;
		} else {
			$('btn_DSA00200').disabled = true;
		}
	}
	
	//載入資料
	function loadAllData(AGREE_HISTORY){

		if(INST_TYPE == 'R'){
			loadData.blockB();
		}
		
		else if(INST_TYPE == 'G' || INST_TYPE == 'A' || INST_TYPE == 'B' ){
			loadData.blockC();
			changeEvent.FIX_SPR_CONTROL(A010Map.RETURN_TYPE);
		}		

		loadData.blockD(AGREE_HISTORY);		
	}
	
	//退件-錯誤歸類
	function doLink(){
		exeAction = 'reject';
		valid1.reset();
		radioHasCheck = false;
		if(!valid1.validate()){
			return;
		}

		<c:if test="${(INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B')}">
			if(!confirmMsg()){return;}
		</c:if>
		var dataMap = getDataMap();
		
		var params = { inputMap:Object.toJSON(dataMap)};
		
		//成功
		var successAction = function(resp){
			if (INST_LEVEL == '30' && '${isWorkCell}' == 'true') {
				popupWin.popup({
					src: '/DSWeb/servlet/HttpDispatcher/DSA2_1901/prompt',
					parameters: {'APPLY_ID':'${APPLY_ID}', 'LINK_FROM':'DSA2_1014'},
					width: 800, 
					height: 450,
					scrolling : 'no'
				});	
				popupWin.callbackHandler = function(){doActionBy('reject');};
			} else {
				doActionBy('reject');
			}
		};

		ajaxPost({
			'actionName':'link',
			'params':params,
			'successAction':successAction
		});
	}	

	//核准,繼續呈核,退回
	function doActionBy(action){
		if (action != 'reject') {
			exeAction = action;
			valid1.reset();
			radioHasCheck = false;
			if(!valid1.validate()){
				return;
			}
				
			<c:if test="${(INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B')}">
				if(!confirmMsg()){return;}
			</c:if>
		}
		
		var dataMap = getDataMap();
			
	    var params = { inputMap:Object.toJSON(dataMap)};
	
		//成功
		var successAction = function(resp){
			A010Map = resp.A010Map?resp.A010Map:{};
			A130Map = resp.A130Map?resp.A130Map:{};
			rejectMap = resp.rejectMap?resp.rejectMap:{};
			loadAllData(resp.AGREE_HISTORY);
			changeEvent.buttonShow(A130Map.AGREE_LEVEL);
		};	
		
		var confirmAction = function(resp){
			var checkConfirmMsg = resp.checkConfirmMsg;
			if(checkConfirmMsg){
				checkConfirmMsg = checkConfirmMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
				if(confirmMsg2(checkConfirmMsg)){
				    step = "2";
					params["STEP"] = step;
					ajaxPost({
						'actionName':exeAction,
						'params':params,
			            'successAction':successAction
		            });
				}
			}else{
				successAction(resp);
			}
		};	
		
		ajaxPost({
			'actionName':exeAction,
			'params':params,
			'successAction':confirmAction
		});
	}
	
	//鑑價影像檔             
	function doGetFile(){
	
		var dataMap = getDataMap();
		
		if (A130Map.APPR_APPLY_ID && A130Map.APPR_APPLY_ID !=''){
			dataMap.APPLY_ID = A130Map.APPR_APPLY_ID;
		}
				
		var params = { inputMap:Object.toJSON(dataMap)};
		//成功
		//var successActionOpen = function(resp){
		//	if(resp.apprPath && resp.apprPath!=''){
		//		var theAction = resp.apprPath;
		//		window.open(theAction);
		//	}else{
		//		alert('取得鑑價影像檔失敗');
		//	}
		//};
		
		var successActionOpen = function(resp){
			if(resp.isExternal && resp.isApprExternalAuth) { //高級主管由外網登入開啟影像
				RPTUtil.download({'downloadFileName': resp.apprFileNM,	'downloadFileFullPath': resp.apprPath});
			} else {
				window.open(resp.apprPath);
			}
		};

		ajaxPost({
			'actionName':'getFile',
			'params':params,
			'successAction':successActionOpen
		});	
	}

	//電子謄本影像按鈕            
	function doElandImage(){
	
	    var dataMap = getDataMap();
	
		actions.ajaxPost( 'elandImage' , { APPLY_ID : dataMap.APPLY_ID} ,
			function(resp){
				if (CSRUtil.isSuccess(resp)){
					$('blockF').innerHTML = '<table>' + (resp.rtnStr || '') + '</table>';
				}
			}
		);
	}
	
	
	//簽件畫面
	function doOpenDSA21002(){
		var url = "<%=dispatcher%>/DSA2_1002/prompt?APPLY_ID="+'${APPLY_ID}'+"&CASE_TYPE=3"+"&BTN=1";
	
		window.open(url,"DSA2_1002", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//批覆書
	function doOpenDSA21007(){
		var url = "<%=dispatcher%>/DSA2_1007/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1007", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//不動產明細
	function doOpenDSA21006(){
		var url = "<%=dispatcher%>/DSA2_1006/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1006", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//鑑估表
	function doOpenDSA21008(){
		var url = "<%=dispatcher%>/DSA2_1008/prompt?APPLY_ID="+'${APPLY_ID}';
	
		window.open(url,"DSA2_1008", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	
	//影像連結
	function doOpenDSA00200(){
		//var url = "${pageContext.request.contextPath}/servlet/HttpDispatcher/DSA0_0200/prompt?APPLY_ID="+'${APPLY_ID}';
		//window.open(url, "DSA0_0200");
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': $F('APPLY_ID')},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	}
		
	var loadData = {
		
		blockB:function(){//退件批覆書(R)
			$('REJ_ITEM_NM').innerHTML = rejectMap.REJ_ITEM_NM || '';//退件原因大項	
			$('REJ_REASON_NM').innerHTML = rejectMap.REJ_REASON_NM|| '';//退件原因
			$('SEND_CHECK_NM').innerHTML = rejectMap.SEND_CHECK_NM|| '';//是否送件控管
			$('REJ_NAME').innerHTML = rejectMap.REJ_NAME|| '';//退件人員	
			$('REJ_NOTE').innerText = rejectMap.REJ_NOTE|| '';//退件備註
			$('REJ_LEVEL_NM').innerHTML = rejectMap.REJ_LEVEL_NM|| '';//退件核定層級		
		},
		
		blockC:function(){//一般,快審件(G,A)
			$('RETURN_TYPE').value = A010Map.RETURN_TYPE;//還款方式
			$('FIX_YY').value = A010Map.FIX_YY;//定期.年 (整數)
			$('FIX_MM').value = A010Map.FIX_MM;//定期.月(整數)
			$('SPR_YY').value = A010Map.SPR_YY;//分期.年	(整數)
			$('SPR_MM').value = A010Map.SPR_MM;//分期.月(整數)
			$('A_VALUE').value = A130Map.A_VALUE;//A值	DECIMAL(5,2)
			
			<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
				$('INTEREST').value = A130Map.INTEREST;//一般型調整後利率 DECIMAL(6,4)
			</c:if>	
			<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
				$('INTEREST_M').value = A130Map.INTEREST_M;//理財型表定利率	 DECIMAL(6,4)
			</c:if>	
			<c:if test="${(INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B') && INST_LEVEL <= 40 }">
				$('AGREE_LEVEL').value =  A130Map.AGREE_LEVEL;//呈核層級
				radio.setValue('TRANS_CODE',A130Map.TRANS_CODE);//呈核原因
				$('TOTAL_GAGE_AMT').value = CSRUtil.$fmt(A130Map.TOTAL_GAGE_AMT,'#,###.####');
				tmp_TRANS_REASON = A130Map.TRANS_REASON;
				$('TRANS_REASON').value = tmp_TRANS_REASON.replace('<br>','');//轉呈原因 :字數限制250中文字大小
				if($('IS_ONLINE0') && $('IS_ONLINE0').value==A130Map.IS_ONLINE){
					$('IS_ONLINE0').checked = true;
				}else if($('IS_ONLINE1') && $('IS_ONLINE1').value==A130Map.IS_ONLINE){
					$('IS_ONLINE1').checked = true;
				}
			</c:if>	
		},
		
		blockD:function(AGREE_HISTORY){//主管批示區塊
			$('COMMENT').value = '';
			<c:if test="${INST_LEVEL >= 50 }">
				$('AGREE_LEVEL_NM').innerHTML = A130Map.AGREE_LEVEL_NM;
			</c:if>
			$('AGREE_HISTORY').innerHTML = AGREE_HISTORY;
		}			
		
	};

	function initValidation(){
		valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
		<c:if test="${(INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B') && INST_LEVEL <= 40 }"> //當有顯示c3區塊時才需檢核
		Validation.addAllThese([
		
			[ 'chkTRANS_REASON1',  '轉呈種類為特殊情形呈核，請輸入轉呈件原因!', function(){
						var TRANS_CODE = radio.getValue('TRANS_CODE');	 
						if(TRANS_CODE == '1'){ 
							if($('TRANS_REASON').value.trim().length < 1){
								return false;
							}
						 } 
					return true;
				 } ] ,
			[ 'chkTOTAL_GAGE_AMT1',  '必須輸入且需為>0之整數', function(v){ 
					if(exeAction!='reject' && (INST_LEVEL == 30 || INST_LEVEL == 40)){ 
						return  /^\d+$/.test(v) && parseInt(v,10)>0;
					 } 
					return true;
				 }] ,
				 
			[ 'chkTRANS_CODE',  '請點選轉呈種類!', function(v){ 
					if(!radioHasCheck && exeAction!='reject' && (INST_LEVEL == 30 || INST_LEVEL == 40)){ 
						var result = false;
						$$('#form1 input[name="TRANS_CODE"]').each( function(radio){
							if(radio.checked){
							 	result =  true;
							 }
						 } );
						 radioHasCheck = true;
						 return result;
					 } 
					radioHasCheck = true;
					return true;
				 } ] ,
			[ 'chkTOTAL_GAGE_AMT2',  '格式必須為整數', function(v){ 
					if($F('TOTAL_GAGE_AMT') != ''){ 
						return !isNaN(v) && /^(-)?\d+$/.test(v);
					 } 
					return true;
				 } ],
				 
			[ 'chkAGREE_LEVEL',  '案件須繼續呈核時,請點選最高核定層級', function(v){ 
					if(exeAction=='confirm' && INST_LEVEL == 30 && $F('AGREE_LEVEL')==''){ 
						return false;
					 } 
					return true;
				 } ],
				 
			[ 'chkTRANS_REASON2',  '字數限制250中文字大小', function(){
					if($F('TRANS_REASON') != ''){ 
						return validation.checkInputLength($F('TRANS_REASON'), 500, 250, null);
					 }  

					return true;
				 } ],
				 
			[ 'chkIS_ONLINE',  '請點選是否召開線上放審會', function(){
					if($('IS_ONLINE0') && !$('IS_ONLINE0').checked && !$('IS_ONLINE1').checked){ 
						return false;
					 }  

					return true;
				 } ],
				 
			[ 'chkIS_ONLINE1',  '該件無法召開線上放審會', function(){
					
					if(exeAction=='agree' && $('IS_ONLINE1') && $('IS_ONLINE1').checked && (INST_TYPE == 'G' || INST_TYPE == 'A') && INST_LEVEL <= 40){ 
						return false;
					 }  

					return true;
				 } ],
			 [ 'chkIS_ONLINE2',  '其他借新還舊(簡易)簽件無法召開線上放審會', function(){
				
				if((exeAction=='agree' || exeAction=='confirm') && $('IS_ONLINE1') && $('IS_ONLINE1').checked && (INST_TYPE == 'B')){ 
					return false;
				 }  

				return true;
			 } ]
			
		]);
		
		</c:if>

	}
	
	//確認訊息
	function confirmMsg(){

		var isContinue = true;
		
		var result = false;
		
		<c:if test="${A010Map.MM_CODE eq '0'}">
			result = A130Map.INTEREST != A130Map.INTEREST;
		</c:if>
		
		<c:if test="${A010Map.MM_CODE eq '1'}">
			result = A130Map.INTEREST_M != A130Map.INTEREST_M;
		</c:if>
		
		<c:if test="${A010Map.MM_CODE eq '2'}">
			result = A130Map.INTEREST != A130Map.INTEREST || A130Map.INTEREST_M != A130Map.INTEREST_M;
		</c:if>		
		
		//當『一般型擬准利率』、『理財型擬准利率』資料異動時
		if( result){
			 isContinue = false;
			 if (confirm('請確認A值是否須修改')){
			 	isContinue = true;
			 }
		}
		
		//畫面上的一般型調整後利率 <> A130Map.INTEREST_C
		
		<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
			if(isContinue && A130Map.INTEREST_C != A130Map.INTEREST_C){
				 isContinue = false;
				 if (confirm('本件簽件利率('+A130Map.INTEREST_C+')與表定利率('+A130Map.INTEREST_C+')不一致\n是否繼續執行?')){
				 	isContinue = true;
				 }		
			}
		</c:if>	
		
		return isContinue;	
	}	
	
	function getDataMap(){
		var dataMap = {};
			
		<c:if test="${INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B' }">
		
			dataMap.REFER_ID = $F('REFER_ID');
			dataMap.APPLY_ID = $F('APPLY_ID');
			dataMap.APPR_APPLY_ID = A130Map.APPR_APPLY_ID;						
			dataMap.INST_LEVEL = INST_LEVEL;
			dataMap.INST_TYPE = INST_TYPE;
			dataMap.MM_CODE = A010Map.MM_CODE;
			dataMap.A_VALUE = '${A130Map.A_VALUE}';//$F('A_VALUE');
			dataMap.RETURN_TYPE = '${A010Map.RETURN_TYPE}';//$F('RETURN_TYPE');
			dataMap.COMMENT = $F('COMMENT');
			
			
			if($F('RETURN_TYPE') == '1'){ //分期
				dataMap.FIX_YY = '';
				dataMap.FIX_MM = '';
				dataMap.SPR_YY = '${A010Map.SPR_YY}';//$F('SPR_YY');
				dataMap.SPR_MM = '${A010Map.SPR_MM}';//$F('SPR_MM');
				
			}else if($F('RETURN_TYPE') == '3'){ //定期
				dataMap.FIX_YY = '${A010Map.FIX_YY}';//$F('FIX_YY');
				dataMap.FIX_MM = '${A010Map.FIX_MM}';//$F('FIX_MM');
				dataMap.SPR_YY = '';
				dataMap.SPR_MM = '';
			}else{
				dataMap.FIX_YY = '${A010Map.FIX_YY}';//$F('FIX_YY');
				dataMap.FIX_MM = '${A010Map.FIX_MM}';//$F('FIX_MM');
				dataMap.SPR_YY = '${A010Map.SPR_YY}';//$F('SPR_YY');
				dataMap.SPR_MM = '${A010Map.SPR_MM}';//$F('SPR_MM');								
			}		
			
			<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
				dataMap.INTEREST = A130Map.INTEREST;//一般型
				dataMap.INTEREST_M = A130Map.INTEREST_M;//理財型
			</c:if>	 
			<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
				dataMap.INTEREST_M = A130Map.INTEREST_M;//理財型
				dataMap.INTEREST = A130Map.INTEREST;//一般型
			</c:if>	
			
			<c:if test="${INST_LEVEL <= 40 }">
				dataMap.AGREE_LEVEL =  $F('AGREE_LEVEL');
				dataMap.TOTAL_GAGE_AMT = $F('TOTAL_GAGE_AMT');
				dataMap.TRANS_CODE =radio.getValue('TRANS_CODE');
				dataMap.TRANS_REASON =  $('TRANS_REASON').value;			
			
			</c:if>
			
			<c:if test="${INST_LEVEL > 40 }">
				dataMap.AGREE_LEVEL =  A130Map.AGREE_LEVEL;
				dataMap.TOTAL_GAGE_AMT = A130Map.TOTAL_GAGE_AMT;				
				dataMap.TRANS_CODE = A130Map.TRANS_CODE;
				dataMap.TRANS_REASON =  A130Map.TRANS_REASON;			
			</c:if>
			
			dataMap.APPLY_GROUP = A010Map.APPR_GROUP;
			
			if($('IS_ONLINE0') && $('IS_ONLINE0').checked){
				dataMap.IS_ONLINE = '0';
			}else if($('IS_ONLINE1') && $('IS_ONLINE1').checked){
				dataMap.IS_ONLINE = '1';
			}
	
		</c:if>
				
		<c:if test="${INST_TYPE eq 'R' }">
		
			dataMap.REFER_ID = $F('REFER_ID');
			dataMap.APPLY_ID = $F('APPLY_ID');
			dataMap.APPR_APPLY_ID = A130Map.APPR_APPLY_ID;			
			dataMap.INST_LEVEL = INST_LEVEL;
			dataMap.INST_TYPE = INST_TYPE;
			dataMap.MM_CODE = A010Map.MM_CODE;
			dataMap.INTEREST = A130Map.INTEREST;
			dataMap.INTEREST_M = A130Map.INTEREST_C;
			dataMap.A_VALUE = A130Map.A_VALUE;
			dataMap.RETURN_TYPE = A010Map.RETURN_TYPE;
			dataMap.FIX_YY = A010Map.FIX_YY;
			dataMap.FIX_MM = A010Map.FIX_MM;
			dataMap.SPR_YY = A010Map.SPR_YY;
			dataMap.SPR_MM = A010Map.SPR_MM;
			dataMap.AGREE_LEVEL =  A130Map.AGREE_LEVEL;
			dataMap.TOTAL_GAGE_AMT = A130Map.TOTAL_GAGE_AMT;
			dataMap.TRANS_CODE = A130Map.TRANS_CODE;
			dataMap.TRANS_REASON =  A130Map.TRANS_REASON;
			dataMap.COMMENT = $F('COMMENT');
			dataMap.APPLY_GROUP = A010Map.APPR_GROUP;
			dataMap.REJ_LEVEL = rejectMap.REJ_LEVEL;
		</c:if>
		
		return dataMap;
		}
	
	var radio = {
		
		getValue:function(name){
			var v = '';
			$$('#form1 input[name="'+name+'"]').each( function(radio){ 
				if(radio.checked){
				 	v = radio.value;
				 }
			} );
			return v;		
		},
		
		setValue:function(name,v){
			$$('#form1 input[name="'+name+'"]').each( function(radio){ 
				if(radio.value == v){
				 	radio.checked = true;
				 }
			} );		
		}	
	};
	
	//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
	function doTrimTextArea (val){
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
		if($(val).value.length>0){
			$(val).value = $(val).value.replace(/'/gi, "").replace(/"/gi, "");
			while(true){
				ln0 = $(val).value.length;
				while(true){
					ln1 = $(val).value.length;
					if($(val).value.indexOf('\r\n')>=0){
						//trim掉最後一個\r\n
						$(val).value = $(val).value.replace(/\r\n$/g, "");
						if(ln1 == $(val).value.length){
							break;	
						}
					}else{
						break;
					}
				}
				while(true){
					ln2 = $(val).value.length;
					if($(val).value.indexOf(' ')>=0){
						$(val).value = $(val).value.replace(/ $/g, "");
						if(ln2 == $(val).value.length){
							break;	
						}
					}else{
						break;
					}
				}
	
				if(ln0 == $(val).value.length){
					break;	
				}
			}
		}
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
	}
	
	/* 共用ajaxpost function */
	function ajaxPost(opts){	

		var actionName = opts['actionName'];
		var params = opts['params'];
		var successAction = opts['successAction'];
		var errorAction = opts['errorAction'];
		var func_id = opts['func_id'];

		if(!func_id){
			func_id = "DSA2_1014";
		}

		new Ajax.Request( "<%=dispatcher%>/"+func_id+"/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}  

	return{                              
              
		init:function(){
			
			<c:if test="${not empty A010MapJSON}">
				A010Map = ${A010MapJSON};
			</c:if>
			if(!A010Map){
				A010Map = {};
			}
			<c:if test="${not empty A130MapJSON}">
				A130Map = ${A130MapJSON};
			</c:if>
			if(!A130Map){
				A130Map = {};
			}
			<c:if test="${not empty rejectMapJSON}">
				rejectMap = ${rejectMapJSON};
			</c:if>
			if(!rejectMap){
				rejectMap = {};
			}
		    
			//載入資料
			loadAllData('${AGREE_HISTORY}');
			
			//頁面<input>enable控制            
			colEditControl('${A010Map.RETURN_TYPE}');
			
			initValidation();
			
			//核准                    
			$('btn_agree').observe('click',function(event){                                        
					doTrimTextArea ('COMMENT');
					if((INST_TYPE == 'G' || INST_TYPE == 'A' || INST_TYPE == 'B') && INST_LEVEL < 50){
						doTrimTextArea ('TRANS_REASON');
					}
					doActionBy('agree');					
				}                        
			);
			
			//繼續呈核                    
			$('btn_confirm').observe('click',function(event){                                        
					doTrimTextArea ('COMMENT');
					if((INST_TYPE == 'G' || INST_TYPE == 'A' || INST_TYPE == 'B') && INST_LEVEL < 50){
						doTrimTextArea ('TRANS_REASON');
					}
					doActionBy('confirm');					
				}                        
			);
			
			//退回                   
			$('btn_reject').observe('click',function(event){                                        
					//doActionBy('reject');	
					doLink();				
				}                        
			);
			
			//鑑價影像檔               
			$('btn_getFile').observe('click',function(event){                                        
					doGetFile();					
				}                        
			);
			
			//電子謄本影像按鈕
			$('btn_elandImage').observe('click',function(event){                                        
					doElandImage();					
				}                        
			);
			
			//簽件畫面               
			$('btn_DSA21002').observe('click',function(event){                                        
					doOpenDSA21002();					
				}                        
			);	
			
			//批覆書               
			$('btn_DSA21007').observe('click',function(event){                                        
					doOpenDSA21007();					
				}                        
			);													
			
			//不動產明細
			$('btn_DSA21006').observe('click',function(event){                                        
					doOpenDSA21006();					
				}                        
			);

			//鑑估表
			$('btn_DSA21008').observe('click',function(event){                                        
					doOpenDSA21008();					
				}                        
			);			
			
			//影像連結
			$('btn_DSA00200').observe('click',function(event){                                        
					doOpenDSA00200();					
				}                        
			);

			grid = new TableUI({
					table: $('grid'), pageSize: 10, allSortable: true,overDiv:false,
					column:[
						{header:'檔名', key:'FILE_NM',render: function(record , value){
								var link = document.createElement('a');
									link.href = '#' ;
									link.onclick = function(){
										ajaxPost({
											'actionName':'download',
											'params':{'FILE_ID':record.FILE_ID},
											'successAction':function (resp) {
												if(CSRUtil.isSuccess(resp)){
													RPTUtil.download({
														'downloadFileName': resp.FILE_NM,
														'downloadFileFullPath': resp.FILE_PATH
													})
												}
											},
											'func_id':'DSA2_2400'
										});
									};
									link.innerHTML = value;	
								return link;
							}
						},
						{header:'產製人員', key:'LST_PROC_NAME'},
						{header:'產製日期', key:'LST_PROC_DT'}
					]
			});

			grid.load(${fileList});
			
			
			var MM_CODE = '${A010Map.MM_CODE}';
			$('AGREE_AMT_P').innerHTML = ('${rtnMap.AGREE_AMT_P}' ? MoneyFormat('${rtnMap.AGREE_AMT_P}') : 0 ) + '&nbsp萬';
			if(MM_CODE == '1' || MM_CODE == '2'){//當為理財型
				$('AGREE_AMT_M').innerHTML = ('${rtnMap.AGREE_AMT_M}' ? MoneyFormat('${rtnMap.AGREE_AMT_M}') : 0 ) + '&nbsp萬';
			}
			
			$('APPR_REALVALUE').innerHTML = ('${rtnMap.APPR_REALVALUE}' ? MoneyFormat('${rtnMap.APPR_REALVALUE}') : 0 ) + '&nbsp元';	
             <c:if test="${INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B'}">
			   $('iniarea').hide();
			 </c:if>
			/*
			if (INST_TYPE == 'R') {
				if (rejectMap.IS_HAVE_A143 == 'Y' || REJ_LEVEL < INST_LEVEL) {
					$('btn_confirm_div').style.display = 'none';
				} else {
					$('btn_confirm_div').style.display = '';
				}
			}
			*/
		}                 
	}

}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<span>
		<form id="form1" name="form1" method="post">
			
			<input type="hidden" id="APPLY_ID" name="APPLY_ID" value="<c:out value='${APPLY_ID}' />">
			<input type="hidden" id="REFER_ID" name="REFER_ID" value="<c:out value='${REFER_ID}' />">
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow"  colspan = "4">
						<span><c:out value='${rtnMap.PREFER_TYPE_NM}' /></span>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="20%">受理編號</td>
					<td class="tbYellow2" colspan = "3"><c:out value='${A010Map.APPLY_ID}' />&nbsp<c:out value='${rtnMap.LOAN_TYPE_NM}' /></td>					
				</tr>
				<tr>					
					<td class="tbYellow">借款人</td>
					<td class="tbYellow2"><c:out value='${A010Map.BORROW_NAME}' />&nbsp&nbsp<c:out value='${A010Map.BORROW_ID}' /><br><font color="red"><c:out value='${alertMsg}' /></font></td>
					<td class="tbYellow" width = "14%">借款人資料</td>
					<td class="tbYellow2" ><c:out value='${rtnMap.BORR_DATA}' /></td>
				</tr>
				<tr>					
					<td class="tbYellow">借款用途</td>
					<td class="tbYellow2"><c:out value='${rtnMap.LOAN_POS_NM}' /></td>	
					<td class="tbYellow">債信評等</td>
					<td class="tbYellow2"><font color="blue"><b><c:out value='${rtnMap.CREDIT_RANK}' /></b></font> &nbsp 級   <font color="red">**I~VI級，I級最佳**</font></td>						
				</tr>
				<tr>					
					<td class="tbYellow">違約機率</td>
					<td class="tbYellow2"><font color="blue"><c:out value='${rtnMap.RENEGE_CHANCE}' /></font> &nbsp % &nbsp <font color="red">**數值越低越好**</font></td>	
					<td class="tbYellow">G-FICO</td>
					<td class="tbYellow2"><font color="blue"><c:out value='${rtnMap.GF_SCORE}' /></font> &nbsp 分 &nbsp (近一年近件百分位點：<font color="blue"><c:out value='${rtnMap.OY_SCORE}' /></font>%) &nbsp <font color="red">**分數高通常表示信用佳，百分點位亦同**</font></td>						
				</tr>				
				<tr>
					<c:choose>
						<c:when test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
							<td class="tbYellow">擬准一般型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_P" ></td>					
							
							<td class="tbYellow">擬准理財型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_M" ></td>
						</c:when>
						<c:otherwise> 
							<td class="tbYellow" >擬准一般型貸款</td>
							<td class="tbYellow2" id = "AGREE_AMT_P" colspan ="3"></td>	
						</c:otherwise>
					</c:choose>
				</tr>
				<tr>					
					<td class="tbYellow">貸放成數</td>
					<td class="tbYellow2"><c:out value='${rtnMap.GA_RATE}' /> &nbsp%</td>
					<td class="tbYellow">區域放款率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.LOAN_LIMIT_C}' /> &nbsp %</td>
				</tr>
					<tr>					
					<td class="tbYellow">擬准一般型利率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.INTEREST}' /> &nbsp%</td>
					<td class="tbYellow">一般型表定利率</td>
					<td class="tbYellow2"><c:out value='${rtnMap.INTEREST_CONT1}' /> &nbsp %</td>
				</tr>
				<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
					<tr>					
						<td class="tbYellow">擬准理財型利率</td>
						<td class="tbYellow2" colspan = "3"><c:out value='${rtnMap.INTEREST_CONT2}' />&nbsp %</td>					
					</tr>
				</c:if>
				</tr>
				<tr>					
					<td class="tbYellow">擔保品</td>
					<td class="tbYellow2"><c:out value='${rtnMap.FLOOR_NM}' /> &nbsp <c:out value='${rtnMap.BUILD_TYPE_NM}' /> &nbsp <c:out value='${rtnMap.USE_STATUS_NM}' /> &nbsp <c:out value='${rtnMap.REAL_USE_NM}' /></td> 
					<td class="tbYellow">屋齡</td>
					<td class="tbYellow2"><c:out value='${rtnMap.BUILD_AGE}' /> &nbsp 年</td>
				</tr>
				<tr>					
					<td class="tbYellow">還款方式</td>
					<td class="tbYellow2"><c:out value='${RETURN_TYPE_NM}' /></td>
					<td class="tbYellow">年期</td>
					<td class="tbYellow2">
					<c:if test="${A010Map.FIX_YY != '0' || A010Map.FIX_MM != '0'}">
						定期
					</c:if>
					<c:if test="${A010Map.FIX_YY != '0'}">
						<c:out value='${A010Map.FIX_YY}' />年&nbsp
					</c:if>
					<c:if test="${A010Map.FIX_MM != '0'}">
						<c:out value='${A010Map.FIX_MM}' />月&nbsp
					</c:if>
					<c:if test="${A010Map.SPR_YY != '0' || A010Map.SPR_MM != '0'}">
						分期 
					</c:if> 
					<c:if test="${A010Map.SPR_YY != '0'}">
						<c:out value='${A010Map.SPR_YY}' />年&nbsp
					</c:if> 
					<c:if test="${A010Map.SPR_MM != '0'}">
						<c:out value='${A010Map.SPR_MM}' />月&nbsp
					</c:if> 
					</td> 					
				</tr>
				<%--[20221226]增-本金彈性還/本金彈性還期間 --%>				
				<tr>					
					<td class="tbYellow">擔保品座落</td>
					<td class="tbYellow2">( <c:out value='${rtnMap.AREA_CODE_930318}' /> )<c:out value='${rtnMap.GAGE_ADDR}' /> </td>
					<td class="tbYellow">本金彈性還</td>
					<td class="tbYellow2"><c:out value='${A010Map.IS_FLEX_NM}' /></td>					
				</tr>
				<tr>					
					<td class="tbYellow">判定時價</td>
					<td class="tbYellow2" id = "APPR_REALVALUE"></td>	
					<td class="tbYellow">本金彈性還期間</td>
					<td class="tbYellow2"><c:out value='${A010Map.FLEX_PERIOD_NM}' /></td>					
				</tr>
			</table>									
<!------------------------ B區--------------------->											
			<c:if test="${INST_TYPE eq 'R'}" >							
			<div id="blockB" >	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" rowSpan="6" width="2%">退<br>件<br>批<br>覆<br>書</td>
					<td class="tbYellow" width="23%">退件原因大項</td>
					<td class="tbYellow2" width="75%"><span id="REJ_ITEM_NM"></span></td>								
				</tr>
				<tr>
					<td class="tbYellow" >退件原因</td>
					<td class="tbYellow2" ><span id="REJ_REASON_NM"></span></td>							
				</tr>
				<tr>
					<td class="tbYellow" >是否送件控管</td>
					<td class="tbYellow2" ><span id="SEND_CHECK_NM"></span></td>								
				</tr>																					
				<tr>
					<td class="tbYellow" >退件人員</td>
					<td class="tbYellow2" ><span id="REJ_NAME"></span></td>									
				</tr>
				<tr>
					<td class="tbYellow" >退件備註</td>
					<td class="tbYellow2" ><span id="REJ_NOTE"></span></td>								
				</tr>																				
				<tr>
					<td class="tbYellow" >退件核定層級</td>
					<td class="tbYellow2" ><span id="REJ_LEVEL_NM"></span></td>									
				</tr>
			</table>
			</div>
			</c:if>
<!------------------------ C區--------------------->											
			<c:if test="${INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B'}">
			<div id="blockC" >	
			<table id="blockC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				
				<tbody id = "iniarea">
				<tr>
					<td class="tbYellow" width="2%">年期</td>
					<td class="tbYellow2" width="98%" colspan="2">
						還款方式						
						<select class="textBox2" name="RETURN_TYPE" id="RETURN_TYPE"  onchange="changeEvent.FIX_SPR_CONTROL(this.value)" disabled>
                             <c:forEach var="map" items="${RETURN_TYPE_LIST}">
                               <option value="${map.key}">${map.value}</option>
                             </c:forEach>
                           </select>
                           	定期	<input type="text" datatype="number" id="FIX_YY" name="FIX_YY" fieldName="定期(年)" class="textBox2 validate-digits" size="6" disabled>年
                           	<input type="text" datatype="number" id="FIX_MM" name="FIX_MM" fieldName="定期(月)" class="textBox2 validate-digits" size="6"  disabled>月+
                           	分期	<input type="text" datatype="number" id="SPR_YY" name="SPR_YY" fieldName="分期(年)" class="textBox2 validate-digits" size="6"  disabled>年	
                           	<input type="text" datatype="number" id="SPR_MM" name="SPR_MM" fieldName="分期(月)" class="textBox2 validate-digits" size="6" disabled>月			                            							
					</td>								
				</tr>
				<tr>
					<td class="tbYellow" >A值</td>
					<td class="tbYellow2" colspan="2">
						<select class="textBox2" name="A_VALUE" id="A_VALUE" >
                             <c:forEach var="map" items="${A_VALUE_LIST}">
                               <option value="${map.key}">${map.value}</option>
                             </c:forEach>
                           </select>
					</td>
				</tr> 
				<tr>
					<td class="tbYellow" >利率</td>
					<td class="tbYellow2" colspan="2">
					<c:if test="${A010Map.MM_CODE eq '0' || A010Map.MM_CODE eq '2'}">
					一般型調整後利率<input type="text" datatype="number" id="INTEREST" name="INTEREST" fieldName="一般型調整後利率" class="textBox2 validate-number" size="15" disabled>
					<BR><BR>
					</c:if>
					<c:if test="${A010Map.MM_CODE eq '1' || A010Map.MM_CODE eq '2'}">
					理財型表定利率<input type="text" datatype="number" id="INTEREST_M" name="INTEREST_M" fieldName="理財型表定利率" class="textBox2 validate-number" size="15" disabled>
					<BR><BR>
					</c:if>
					</td>						
				</tr>
				</tbody> 
				
				<c:if test="${(INST_TYPE eq 'G' || INST_TYPE eq 'A' || INST_TYPE eq 'B') && INST_LEVEL <= 40 }">
				<tr>
					<td class="tbYellow2" colspan="2">
						須呈核至<select class="textBox2" name="AGREE_LEVEL" id="AGREE_LEVEL" onchange="changeEvent.buttonShow(this.value)" disabled>								
                             <c:forEach var="map" items="${AGREE_LEVEL_LIST}">
                               <option value="${map.key}" >${map.value}</option>
                             </c:forEach>
                           </select>(最高核定層級)<br>
                             <c:forEach var="map" items="${TRANS_CODE_LIST}">
                                <input type="radio" name="TRANS_CODE" class="textBox2 chkTRANS_CODE chkAGREE_LEVEL" value="${map.key}" disabled>${map.value}
                             </c:forEach>
                             <br>含本次累貸金額：<input type="text" datatype="number" id="TOTAL_GAGE_AMT" name="TOTAL_GAGE_AMT" fieldName="含本次累貸金額" class="textBox2 chkTOTAL_GAGE_AMT1 chkTOTAL_GAGE_AMT2" size="15"  disabled>萬
                             <font id="IS_ONLINE_SHOW"><br>是否召開線上放審會<input type="radio" id="IS_ONLINE1" name="IS_ONLINE" class="textBox2 chkIS_ONLINE chkIS_ONLINE1 chkIS_ONLINE2" value="1" disabled>是<input type="radio" id="IS_ONLINE0" name="IS_ONLINE" class="textBox2" value="0" disabled>否</font>
					</td>
					<td width="55%" class="tbYellow2">
					轉呈原因：<br>
					<textarea  name="TRANS_REASON" id="TRANS_REASON" class="textBox2 chkTRANS_REASON1 chkTRANS_REASON2" rows="3" cols="55" disabled></textarea>
					</td>
				</tr>
				</c:if>				
			</table>
			</div>
<!------------------------ D區--------------------->											
			</c:if>	
			<div id="blockD">	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="2%" align="center">主<BR>管<BR>批<BR>示</td>
					<td width="60%" class="tbYellow2"><textarea  name="COMMENT" id="COMMENT" rows="5" cols="72" ></textarea></td>
					<c:if test="${INST_LEVEL >= 50 }">
						<td class="tbYellow" width="8%" align="center" >核<BR>定<BR>層<BR>級</td>
						<td class="tbYellow2" width="15%"><span id="AGREE_LEVEL_NM"></span></td>
					</c:if>	
					<td class="tbYellow2" width="15%">
					<div id="btn_DSA21002_div" style="{display:none}">
					<input id="btn_DSA21002" name="btn_DSA21002" type="button" class="button" value="簽件畫面"><BR>
					</div>
					<input id="btn_DSA21007" name="btn_DSA21007" type="button" class="button" value="批覆書"><BR>
					<input id="btn_DSA21008" name="btn_DSA21008" type="button" class="button" value="鑑估表"><BR>
					<input id="btn_DSA00200" name="btn_DSA00200" type="button" class="button" value="影像連結"><BR>
					<input id="btn_getFile" name="btn_getFile" type="button" class="button" value="鑑價影像檔"><BR>
					<input id="btn_DSA21006" name="btn_DSA21006" type="button" class="button" value="不動產明細"><BR>
					<div id="btn_elandImage_div" style="{display:none}">
					<input id="btn_elandImage" name="btn_elandImage" type="button" class="button" value="電子謄本影像"><BR>
					</div>
					<div id="btn_agree_div" style="{display:none}">
					<input id="btn_agree" name="btn_agree" type="button" class="button" value="核准"><BR>
					</div>
					<div id="btn_confirm_div" style="{display:none}">
					<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="繼續呈核"><BR>
					</div>
					
					<input id="btn_reject" name="btn_reject" type="button" class="button" value="退回">
					</td>	
				</tr>
				<tr>
					<td class="tbYellow2" colspan="5">
						<a href="#A_div_I" onClick="changeEvent.doShowHistory()">＊批示歷程</a>
						<div id="div_I" style="overflow:auto; ">
							<span id="AGREE_HISTORY"></span>
						</div>
					</td>
				</tr>								
				<tr>
					<td class="tbYellow2" colspan="6">
						<a href="#A_div_J" onClick="changeEvent.doShowFileList()" name="A_div_J">＊取消核貸批覆書</a>
						<div id="div_J" style="overflow:auto; display:none;">
							<span id="FILE_LIST">
								<table id="grid" class="grid" width="100%"></table>
							</span>
						</div>
					</td>
				</tr>
			</table>
			</div>
		</form>
	</span>
	<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td align="center" colspan="6">
					<span id="blockF"></span>
				</td>
			</tr>
	</table>
</body>
<!-- InstanceEnd -->
</html>