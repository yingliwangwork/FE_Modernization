<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA2_1002
功能：快審件簽件作業
作者：李俊德
完成：

[20211217] 修改程式  楊青峰
申請書:配合稽核室查核意見，進行呈核層級系統檢核卡控。
畫面調整:新增【呈核層級事項】不予承作事項、提高授權事項、洗錢防制高風險客戶、一年內重簽件
[20221227] 新增本金彈性還還款方式
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/jsonUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="${htmlBase}/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/utility.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<style>
.overDiv {
	overflow:visible;
}
</style>
<script type="text/JavaScript">

Event.observe(window, 'load', initApp);
Event.observe(window, 'scroll', fix);

var valid;
var ReneList={};
var ReneList_size=0;
var MAdjList={};
var AdjList={};
var MAdjList_size=0;
var AdjList_size=0;
var count;
var count1;
var countA;
var countB;
var query_AdjList={};
var dataMap=null;
var PREFER_TYPE;
var MM_CODE;

function initApp(){
	
	if(${CASE_TYPE eq '3'}){
		PageUI.createPageWithAllBodySubElement("DSA21002" , "核貸作業" , "其他借新還舊簽件作業",1,'${titleNotDisplay}' == 'Y');
		$('btn_eland').show();
		$('btn_elandImage').show();
		$('div_B').style.display = 'block';
	}else{
	    PageUI.createPageWithAllBodySubElement("DSA21002" , "核貸作業" , "快審件簽件作業",1,'${titleNotDisplay}' == 'Y');
	    $('div_A').style.display = 'block';
	}

	<cathay:LocaleDisplay numberFields="AVG_PRICE EXPENSE_AMT AGREE_AMT AGREE_AMT_M CRED_TRADE_AMT SET_AMT FIREINSU_AMT FIREINSU_AMT_VALID INTEREST INTEREST_M LOAN_ABLE TOTAL_PREMIUM LOAN_REMAIN" sysCode= 'DS' var='localeDisplay' /> 
	
	if(${BTN eq '1'}){
		$('table_btn_tr').hide();
	}
	
	displayMessage();
	
	buttonAuth();
	
	autoFormatToNumber();	
	
	new UI().init();
	
	PageUI.resize();
		
	valid = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'validateGAGE_USE', '擔保品使用狀況不可空白!', function(v){
				return $('GAGE_USE_0').checked || $('GAGE_USE_1').checked ? true : false;
			}
		],
		[ 'validateSPEC_CHECK_990625', '本件為央行特定地區購屋貸款件!', function(v){
				return $('SPEC_CHECK_990625_0').checked || $('SPEC_CHECK_990625_1').checked ;
			}
		],
		[ 'validateIS_MANSION', '本件為高價住宅購屋貸款件!', function(v){
				return $('IS_MANSION_0').checked || $('IS_MANSION_1').checked ;
			}
		],	
		[ 'validateIS_FIX_VIPGRADE', '貸款全期不更新客戶優質等級!', function(v){
				return $('IS_FIX_VIPGRADE_0').checked || $('IS_FIX_VIPGRADE_1').checked ;
			}
		],	
		[ 'validateIS_INSU', '是否為保戶!', function(v){
				return $('IS_INSU_0').checked || $('IS_INSU_1').checked ;
			}
		],
		[ 'validateAPPR_APPLY_ID', '參照鑑價報告必須為11碼!', function(v) {
				return $F('APPR_APPLY_ID').length == 0 || $F('APPR_APPLY_ID').length == 11 ? true : false;
			}
		],
		
		[ 'validateMM_ID', '清償理財型帳號必須為10碼且最後一碼須=“X”!', function(v) {
				if(v == ''){return true;}
				$('MM_ID').value = v.toUpperCase();
				return v.length == 10 && v.charAt(9)== 'X';
			}
		],
		
		['validate-number0', '須介於0~9999999之間(最大7位整數)', function(v) {
			if(!$('IS_EXPENSE').checked){
				return true;
			}
			var EXPENSE_AMT = parseInt(v,10);
			return (EXPENSE_AMT >0 && EXPENSE_AMT <= 9999999);
		}],
		['validate-IS_COPRATION_CNT', '請選擇法人購住戶數', function(v) {
			<%-- 20201217 申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：若為法人購住，則必須輸入戶數--%>
			if($('IS_COPRATION_1').checked){
				return $F('IS_COPRATION_CNT') != '';
			}
			return true;
		}]	,
		['validate-IS_CHANGE_HOUSE', '請選擇是否換屋', function(v) {
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：若為購買特定地區，則必須輸入是否換屋--%>
			if($('SPEC_CHECK_990625_1').checked){
				return $F('IS_CHANGE_HOUSE') != '';
			}
			return true;
		}]	,
		['validate-IS_MANSION_CNT', '請選擇高價住宅戶數', function(v) {
			<%-- 20210406 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為高價住宅，則必須輸入戶數--%>
			if($('IS_MANSION_1').checked){
				return $F('IS_MANSION_CNT') != '';
			}
			return true;
		}]	,
		['validate-IS_THIRD_CODE_CNT', '請選擇購置第3戶戶數', function(v) {
			<%-- 20210406 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為購置第3戶，則必須輸入戶數--%>
			if($('IS_THIRD_CODE_1').checked){
				return $F('IS_THIRD_CODE_CNT') != '';
			}
			return true;
		}],
		['validate-AGREE_FLEX_TYPE', '請選擇[本金彈性還擬准類型]!', function(v) {
			<%-- [20221227] --%>
			if($F('IS_FLEX') == 'Y' && !$('AGREE_FLEX_TYPE_0').checked && !$('AGREE_FLEX_TYPE_1').checked && !$('AGREE_FLEX_TYPE_2').checked){
				return false;
			}
			return true;
		}],
		['validate-AGREE_FLEX_AMT', '[自行約定金額]需於上下限金額內!', function(v) {
			<%-- [20221227] --%>
			if(!$('AGREE_FLEX_TYPE_2').checked){
				return true;
			}
			var AGREE_FLEX_AMT = parseInt($F('AGREE_FLEX_AMT'));
			return AGREE_FLEX_AMT <= parseInt($F('FLEX_MAX')) && AGREE_FLEX_AMT >= parseInt($F('FLEX_MIN'));
		}],
		['validate-AGREE_FLEX_AMT_1000', '[自行約定金額]需以仟元為單位!', function(v) {
			<%-- [20221227] --%>
			var AGREE_FLEX_AMT = $F('AGREE_FLEX_AMT');
			if($('AGREE_FLEX_TYPE_2').checked && AGREE_FLEX_AMT % 1000 != 0){
				return false;
			}
			return true;
		}]
	]);	
	
	$('BTN_INSERT1').observe('click',buttons.doInsert1);
	$('BTN_DELETE1').observe('click',buttons.doDelete1);
	$('BTN_INSERT2').observe('click',buttons.doInsert2);
	$('BTN_DELETE2').observe('click',buttons.doDelete2);
	
	$('IS_ADJUST').observe('click', function(event){
		if($('IS_ADJUST').checked){
			$('IS_ADJUST').value='1';
			$$('#grid_body tr').each(
				function(obj){
					obj.show();
				}
			);
			$('table_A_tr1').show();
			$('table_A_tr2').show();
			$('INTEREST').value=($('text6_0'))?$('text6_0').innerHTML:'';
			//$('INTEREST').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
		}else{
			$('IS_ADJUST').value='0';
			$$('#grid_body tr').each(
				function(obj){
					obj.hide();
				}
			);
			$('table_A_tr1').hide();
			$('table_A_tr2').hide();
			//$('INTEREST').readOnly=false; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
		}
	});
	$('IS_ADJUST_M').observe('click', function(event){//checkbox 點選 show hide   2016-12-12新增
		if($('IS_ADJUST_M').checked){
			$('IS_ADJUST_M').value='1';
			$$('#grid_body_Fin tr').each(
					function(obj){
						obj.show();
					}
				);
			$('INTEREST_M').value=($('text6_Fin_0'))?$('text6_Fin_0').innerHTML:'';
			//$('INTEREST_M').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
		}else{
			$('IS_ADJUST_M').value='0';
			$$('#grid_body_Fin tr').each(
					function(obj){
						obj.hide();
					}
				);
			//$('INTEREST_M').readOnly=false; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
		}

	});		
	$('IS_RENEGE').observe('click', function(event){								
		if($('IS_RENEGE').checked){
			$('IS_RENEGE').value='1';
			$$('#grid_body1 tr').each(
				function(obj){
					obj.show();
				}
			);
			$('table_B_tr1').show();
			$('table_B_tr2').show();
		}else{
			$('IS_RENEGE').value='0';
			$$('#grid_body1 tr').each(
				function(obj){
					obj.hide();
				}
			);
			$('table_B_tr1').hide();
			$('table_B_tr2').hide();
		}
	});
	
	//20150515 簽件作業中，央行限制─法人購住、央行限制─高價住宅、央行限制─購置特定地區、央行限制─購置第3戶等四個欄位，設控只允許勾選其中一項。
	//若「本件為高價住宅購屋貸款件」和「本件為央行特定地區購屋貸款件」選擇 是，則適用保戶123則不勾選且DISABLED。
	//20201125 妍伶：需重新判斷承作成數
	<%-- 20210406 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為高價住宅需選擇戶數並預帶「3戶以上」--%>
	$('IS_MANSION_1').observe('click',function(event){
		if($('IS_MANSION_1').checked){
			$('INSU_NOTE').checked = false;
			$('INSU_NOTE').disabled = true;
			$('IS_COPRATION_0').click();
			$('IS_THIRD_CODE_0').click();
			$('SPEC_CHECK_990625_0').click();
			$('IS_MANSION_CNT').disabled = false;
			$('IS_MANSION_CNT').setValue('1'); <%--預帶「3戶以上」--%>
			doCalLoanLimit();
		}
	});		
	<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項，預帶非換屋--%>
	$('SPEC_CHECK_990625_1').observe('click',function(event){
		if($('SPEC_CHECK_990625_1').checked){
			$('INSU_NOTE').checked = false;
			$('INSU_NOTE').disabled = true;
			$('IS_COPRATION_0').click();
			$('IS_THIRD_CODE_0').click();
			$('IS_MANSION_0').click();
			$('IS_CHANGE_HOUSE').disabled = false;
			$('IS_CHANGE_HOUSE').setValue('0'); <%--預帶「非換屋」--%>
		}
	});
	
	//若「央行限制─法人購住」點選=”是”，則 「央行限制─高價住宅」、「央行限制─購置第3戶」、「央行限制─購置特定地區」 自動改為 點選=”否”
	<%--申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：增加法人購住戶數，當「央行限制─法人購住」選擇「是」時顯示戶數下拉選單，並預帶「第二戶以上」--%>
	$('IS_COPRATION_1').observe('click',function(event){
		if($('IS_COPRATION_1').checked){
			$('IS_THIRD_CODE_0').click();
			$('SPEC_CHECK_990625_0').click();
			$('IS_MANSION_0').click();
			$('INSU_NOTE').checked = false;
			$('INSU_NOTE').disabled = true;
			$('IS_COPRATION_CNT').disabled = false;
			$('IS_COPRATION_CNT').setValue('1'); <%--預帶「第二戶以上」--%>
		}
	});
	
	//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位	有任一個點選=”是” ，則「適用保戶123」INSU_NOTE改為取消勾選0:不選取
	<%-- 20210406 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為購置第3戶需輸入戶數並預帶「4戶以上」--%>
	$('IS_THIRD_CODE_1').observe('click',function(event){
		if($('IS_THIRD_CODE_1').checked){
			$('IS_COPRATION_0').click();
			$('SPEC_CHECK_990625_0').click();
			$('IS_MANSION_0').click();
			$('INSU_NOTE').checked = false;
			$('INSU_NOTE').disabled = true;
			$('IS_THIRD_CODE_CNT').disabled = false;
			$('IS_THIRD_CODE_CNT').setValue('1'); <%--預帶「4戶以上」--%>
		}
	});
	
	//若「央行限制─高價住宅」和「央行限制─購置特定地區」都選擇 否，且PREFER_TYPE不等於56、MM_CODE不等於1，則適用保戶123恢復成可勾選狀態。
	$('IS_MANSION_0').observe('click',function(event){
		//20201125 妍伶：需重新判斷承作成數
		if($('IS_MANSION_0').checked){
			$('IS_MANSION_CNT').disabled = true;
			$('IS_MANSION_CNT').setValue(''); //清空
			doCalLoanLimit();
		}
		if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
			$('INSU_NOTE').disabled = false;
		}
		if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
			$('INSU_NOTE').disabled = true;
		}
		//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位均為否，
		//且適用保戶優惠預設勾選，則「適用保戶優惠」INSU_NOTE改為勾選1:選取
		if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && dataMap.INSU_NOTE == "1" && dataMap.MM_CODE != "1"){
			$('INSU_NOTE').checked = true;
			$('INSU_NOTE').disabled = false;
		}
	});		
	$('SPEC_CHECK_990625_0').observe('click',function(event){
		if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
			$('INSU_NOTE').disabled = false;
		}
		if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
			$('INSU_NOTE').disabled = true;
		}
		//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位均為否，
		//且適用保戶優惠預設勾選，則「適用保戶優惠」INSU_NOTE改為勾選1:選取
		if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && dataMap.INSU_NOTE == "1" && dataMap.MM_CODE != "1"){
			$('INSU_NOTE').checked = true;
			$('INSU_NOTE').disabled = false;
		}
		<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
		if($('SPEC_CHECK_990625_0').checked){
			$('IS_CHANGE_HOUSE').disabled = true;
			$('IS_CHANGE_HOUSE').setValue(''); <%--清空--%>
		}
	});
	$('IS_THIRD_CODE_0').observe('click',function(event){
		if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
			$('INSU_NOTE').disabled = false;
		}
		if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
			$('INSU_NOTE').disabled = true;
		}
		if($('IS_THIRD_CODE_0').checked){
			$('IS_THIRD_CODE_CNT').disabled = true;
			$('IS_THIRD_CODE_CNT').setValue(''); //清空
		}
		//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位均為否，
		//且適用保戶優惠預設勾選，則「適用保戶優惠」INSU_NOTE改為勾選1:選取
		if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && dataMap.INSU_NOTE == "1" && dataMap.MM_CODE != "1"){
			$('INSU_NOTE').checked = true;
			$('INSU_NOTE').disabled = false;
		}
	});
	$('IS_COPRATION_0').observe('click',function(event){
		if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
			$('INSU_NOTE').disabled = false;
		}
		if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
			$('INSU_NOTE').disabled = true;
		}
		if($('IS_COPRATION_0').checked){
			$('IS_COPRATION_CNT').disabled = true;
			$('IS_COPRATION_CNT').setValue(''); //清空
		}
		//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位均為否，
		//且適用保戶優惠預設勾選，則「適用保戶優惠」INSU_NOTE改為勾選1:選取
		if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && dataMap.INSU_NOTE == "1" && dataMap.MM_CODE != "1"){
			$('INSU_NOTE').checked = true;
			$('INSU_NOTE').disabled = false;
		}
	});
	
	
	//擔保品使用狀況: 無值時預設住:0
	if (!($('GAGE_USE_0').checked || $('GAGE_USE_1').checked)) {
		$('GAGE_USE_0').checked = true;
	}
	
	var IS_MANSION_checked = false;
	if($('IS_MANSION_0').checked || (!$('IS_MANSION_0').checked && !$('IS_MANSION_1').checked) ){
		IS_MANSION_checked = true;			
	}

	var SPEC_CHECK_990625_checked = false;
	if($('SPEC_CHECK_990625_0').checked || (!$('SPEC_CHECK_990625_0').checked && !$('SPEC_CHECK_990625_1').checked) ){
		SPEC_CHECK_990625_checked = true;			
	}
	
	var IS_THIRD_CODE_checked = false;
	if($('IS_THIRD_CODE_0').checked || (!$('IS_THIRD_CODE_0').checked && !$('IS_THIRD_CODE_1').checked) ){
		IS_THIRD_CODE_checked = true;			
	}
	
	var IS_COPRATION_checked = false;
	if($('IS_COPRATION_0').checked || (!$('IS_COPRATION_0').checked && !$('IS_COPRATION_1').checked) ){
		IS_COPRATION_checked = true;			
		if($('IS_COPRATION_0').checked){
			$('IS_COPRATION_CNT').disabled = true;
			$('IS_COPRATION_CNT').setValue(''); //清空
		}
	}
	
			
	<c:if test="${not empty DataMapJSON}">
		
		<c:if test="${not empty AdjList}">			
					AdjList=${AdjList};
					AdjList_size=${AdjList_size};
		</c:if>		
		<c:if test="${not empty MAdjList}">			
					MAdjList=${MAdjList};
					MAdjList_size=${MAdjList_size};
		</c:if>			
		<c:if test="${not empty ReneList}">			
			ReneList=${ReneList};
			ReneList_size=${ReneList_size};
		</c:if>	
		dataMap=${DataMapJSON};
		loadData(${DataMapJSON});

		<c:if test="${not empty fileList}">					
			grid.load(${fileList});
			$('div_J').style.display = 'block';
		</c:if>
				
		alert("查詢完成");
	</c:if>

}

function loadData(dataMap,resp){

	JSONUtil.sampleJSON2Form2( "form1", dataMap );
	JSONUtil.sampleJSON2Form3( "form1", dataMap );
	var update=dataMap.update;
	
	if(update=='N'){
		$('IS_ADJUST').checked=false;
		$$('#grid_body tr').each(
			function(obj){
				obj.hide();
			}
		);
		$('IS_ADJUST_M').checked=false;  //2016-12-12新增
		$$('#grid_body_Fin tr').each(
			function(obj){
				obj.hide();
			}
		);					
		$('table_A_tr1').hide();
		$('table_A_tr2').hide();
	}
	
	count=AdjList_size;
	countA=AdjList_size;

	//利率個調資料
	$('IS_ADJUST').value=dataMap.IS_ADJUST;
	$('IS_ADJUST_M').value=dataMap.IS_ADJUST_M;  //2016-12-12新增
	
	
	if($('IS_ADJUST').value=='1'&&update=='N'){//LOAD 資料 147有資料
		$('table_A_tr1').show();
		$('table_A_tr2').show();
		for(var i=0;i<AdjList_size;i++){
		
			var oTr = new Element('tr', { id:'tr_'+i,'id2':'tr_'+i});
			oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
			var oInput_BEG_TERM = new Element('input', {type:'text', id:'text1_'+i, size:'2',maxlength:"3",name:'BEG_TERM',value:(AdjList[i]['BEG_TERM']||AdjList[i]['BEG_TERM']===0)?AdjList[i]['BEG_TERM']:''});
			var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(oInput_BEG_TERM);
			oInput_BEG_TERM.observe('change',function(event){
				if(isNaN(this.value)){
					this.value='';
				}
				var num1=this.value;
				var num2=this.up().up().previousSibling?this.up().up().previousSibling.down().nextSibling.down().nextSibling.nextSibling.value||parseInt(num1)-1:parseInt(num1)-1;
				var num3=this.nextSibling.nextSibling.value||999;
				if(num1||num1===0){
					if(parseInt(num1)!=parseInt(num2)+1||parseInt(num1)>=parseInt(num3)){
						alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
						this.value='';
					}else{
						buttons.doChangText1(event);
					}
				}
			});
		
			var oInput_END_TERM;
			if(i==AdjList_size-1){
				oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(dataMap.LOAN_PERIOD||dataMap.LOAN_PERIOD===0)?dataMap.LOAN_PERIOD:''});
			}else{
				oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(AdjList[i]['END_TERM']||AdjList[i]['END_TERM']===0)?AdjList[i]['END_TERM']:''});
			}
			
			otd.insert("-").insert(oInput_END_TERM);
			oInput_END_TERM.observe('change',function(event){
				if(isNaN(this.value)){
					this.value='';
				}
				var num1=this.value;
				var num2=this.previousSibling.previousSibling.value||0;
				var num3=this.up().up().nextSibling?this.up().up().nextSibling.down().nextSibling.down().value||parseInt(num1)+1:parseInt(num1)+1;
				if(num1||num1===0){
					if(parseInt(num1)<=parseInt(num2)||parseInt(num1)!=parseInt(num3)-1){
						alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
						this.value='';
					}
				}
			});
	
			otd.insert("期，加減碼").insert(new Element('input', {type:'text', id:'text3_'+i, size:'3', name:'RT_ADJ',value:(AdjList[i]['RT_ADJ']||AdjList[i]['RT_ADJ']===0)?AdjList[i]['RT_ADJ']:''}));
			otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+i, size:'3', name:'BAS_RT'}).update((AdjList[i]['BAS_RT']||AdjList[i]['BAS_RT']===0)?AdjList[i]['BAS_RT']:''));
			otd.insert("+").insert(new Element('span', {type:'text', id:'text5_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ'])||CSRUtil.round(AdjList[i]['IR_RT'])));//加減碼利率
			otd.insert("=").insert(new Element('span', {type:'text', id:'text6_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ']),6)||CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']),6)));//貸款利率
			otd.insert('<br>').insert(new Element('input', {type:'radio', id:'text7_'+i,name:'IS_FIX_'+i, value:'0'}));
			otd.insert("浮動 ").insert(new Element('input', {type:'radio', id:'text8_'+i,name:'IS_FIX_'+i, value:'1'}));
			otd.insert("固定");
			oTr.insert(otd);
			$('grid_body').insert(oTr);
			
			if($('text4_'+i).innerHTML===0||$('text4_'+i).innerHTML=='0'){
				$('text7_'+i).disabled=true;
			}
			if(AdjList[i]['IS_FIX']==0){
				$('text7_'+i).checked=true;  //AUD00020031
			}else if(AdjList[i]['IS_FIX']==1){
				$('text8_'+i).checked=true;
			}
			$("text3_"+i).observe('change',function(event){buttons.doChangText(event);})
		}
		$('IS_ADJUST').click();
		
	}else if (update=='N'){
		$('IS_ADJUST').value='0';
		for(var i=0;i<AdjList_size;i++){
			var oTr = new Element('tr', { id:'tr_'+i,'id2':'tr_'+i});
			oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
			var oInput_BEG_TERM = new Element('input', {type:'text', id:'text1_'+i, size:'2',maxlength:"3",name:'BEG_TERM',value:(AdjList[i]['BEG_TERM']||AdjList[i]['BEG_TERM']===0)?AdjList[i]['BEG_TERM']:''});
			var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(oInput_BEG_TERM);
			oInput_BEG_TERM.observe('change',function(event){
				if(isNaN(this.value)){
					this.value='';
				}
				var num1=this.value;
				var num2=this.up().up().previousSibling?this.up().up().previousSibling.down().nextSibling.down().nextSibling.nextSibling.value||parseInt(num1)-1:parseInt(num1)-1;
				var num3=this.nextSibling.nextSibling.value||999;
				if(num1||num1===0){
					if(parseInt(num1)!=parseInt(num2)+1||parseInt(num1)>=parseInt(num3)){
						alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
						this.value='';
					}else{
						buttons.doChangText1(event);
					}
				}
			});
			
			var oInput_END_TERM;
			if(i==AdjList_size-1){
				oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(dataMap.LOAN_PERIOD||dataMap.LOAN_PERIOD===0)?dataMap.LOAN_PERIOD:''});
			}else{
				oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(AdjList[i]['END_TERM']||AdjList[i]['END_TERM']===0)?AdjList[i]['END_TERM']:''});
			}
			otd.insert("-").insert(oInput_END_TERM);
			oInput_END_TERM.observe('change',function(event){
				if(isNaN(this.value)){
					this.value='';
				}
				var num1=this.value;
				var num2=this.previousSibling.previousSibling.value||0;
				var num3=this.up().up().nextSibling?this.up().up().nextSibling.down().nextSibling.down().value||parseInt(num1)+1:parseInt(num1)+1;
				if(num1||num1===0){
					if(parseInt(num1)<=parseInt(num2)||parseInt(num1)!=parseInt(num3)-1){
						alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
						this.value='';
					}
				}
			});
			
			otd.insert("期，加減碼").insert(new Element('input', {type:'text', id:'text3_'+i, size:'2', name:'RT_ADJ',value:(AdjList[i]['RT_ADJ']||AdjList[i]['RT_ADJ']===0)?AdjList[i]['RT_ADJ']:''}));
			otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+i, size:'3', name:'BAS_RT'}).update((AdjList[i]['BAS_RT']||AdjList[i]['BAS_RT']===0)?AdjList[i]['BAS_RT']:''));
			otd.insert("+").insert(new Element('span', {type:'text', id:'text5_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ'])||CSRUtil.round(AdjList[i]['IR_RT'])));//加減碼利率
			otd.insert("=").insert(new Element('span', {type:'text', id:'text6_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ']),6)||CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']),6)));//貸款利率
			otd.insert('<br>').insert(new Element('input', {type:'radio', id:'text7_'+i,name:'IS_FIX_'+i, value:'0'}));
			otd.insert("浮動 ").insert(new Element('input', {type:'radio', id:'text8_'+i,name:'IS_FIX_'+i, value:'1'}));
			otd.insert("固定");
			oTr.insert(otd);
			$('grid_body').insert(oTr);
			
			if($('text4_'+i).innerHTML===0||$('text4_'+i).innerHTML=='0'){
				$('text7_'+i).disabled=true;
			}
			if(AdjList[i]['IS_FIX']==0){
				$('text7_'+i).checked=true;  //AUD00020031
			}else if(AdjList[i]['IS_FIX']==1){
				$('text8_'+i).checked=true;
			}
			$("text3_"+i).observe('change',function(event){buttons.doChangText(event);})
		}
		$$('#grid_body tr').each(
			function(obj){
				obj.hide();
			}
		);

		$('IS_ADJUST').checked=true;
		$('IS_ADJUST').click();  //小心
	}

	if($('IS_ADJUST_M').value=='1'&&update=='N'){//LOAD 資料 147M有資料

		for(var i=0;i<MAdjList_size;i++){

			 //2016-12-12新增加		
			var otd_Fin = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("加減碼").insert(new Element('input', {type:'text', id:'text3_Fin_'+i, size:'3',name:'RT_ADJ',value:(MAdjList[i]['RT_ADJ']||MAdjList[i]['RT_ADJ']===0)?MAdjList[i]['RT_ADJ']:''}))
			otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text4_Fin_'+i, size:'3', name:'BAS_RT'}).update((MAdjList[i]['BAS_RT']||MAdjList[i]['BAS_RT']===0)?MAdjList[i]['BAS_RT']:''))
			otd_Fin.insert("+").insert(new Element('span', {type:'text', id:'text5_Fin_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ'])||CSRUtil.round(MAdjList[i]['IR_RT'])));//加減碼利率
			otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text6_Fin_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ']),6)||CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']),6)));//貸款利率
			var oTr_Fin = new Element('tr', { id:'tr_Fin_'+i,'id2':'tr_Fin_'+i});
			oTr_Fin.insert(otd_Fin);
			$('grid_body_Fin').insert(oTr_Fin);    //2016-12-12新增加		
			$("text3_Fin_"+i).observe('change',function(event){buttons.doChangTextFin(event);})  //2016-12-12新增加
		
		}
		
		$('IS_ADJUST_M').click();		
		
	}else if (update=='N'){
		$('IS_ADJUST_M').value='0';	
		for(var i=0;i<MAdjList_size;i++){
		
			//2016-12-12新增加
			var otd_Fin = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("加減碼").insert(new Element('input', {type:'text', id:'text3_Fin_'+i, size:'2', name:'RT_ADJ',value:(MAdjList[i]['RT_ADJ']||MAdjList[i]['RT_ADJ']===0)?MAdjList[i]['RT_ADJ']:''}))
			otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text4_Fin_'+i, size:'3', name:'BAS_RT'}).update((MAdjList[i]['BAS_RT']||MAdjList[i]['BAS_RT']===0)?MAdjList[i]['BAS_RT']:''))
			otd_Fin.insert("+").insert(new Element('span', {type:'text', id:'text5_Fin_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ'])||CSRUtil.round(MAdjList[i]['IR_RT'])));//加減碼利率
			otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text6_Fin_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ']),6)||CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']),6)));//貸款利率
			var oTr_Fin = new Element('tr', { id:'tr_Fin_'+i,'id2':'tr_Fin_'+i});
			oTr_Fin.insert(otd_Fin);
			$('grid_body_Fin').insert(oTr_Fin);    //2016-12-12新增加			
			$("text3_Fin_"+i).observe('change',function(event){buttons.doChangTextFin(event);}) //2016-12-12新增加
			
		}
		$$('#grid_body_Fin tr').each(  //2016-12-12新增加
				function(obj){
					obj.hide();
				}
		);			
		$('IS_ADJUST_M').checked=true;
		$('IS_ADJUST_M').click();  //小心		
		
		
	}		
	
	//提前清償違約金資料
	if(update=='N'){
		$('IS_RENEGE').checked=false;
		$$('#grid_body1 tr').each(
			function(obj){
				obj.hide();
			}
		);
		$('table_B_tr1').hide();
		$('table_B_tr2').hide();
	}
	count1=ReneList_size;
	countB=ReneList_size;
	$('IS_RENEGE').value=dataMap.IS_RENEGE;
	
	if($('IS_RENEGE').value=='1'&&update=='N'){//LOAD 資料 
		$('table_B_tr1').show();
		$('table_B_tr2').show();
		for(var i=0;i<ReneList_size;i++){
		
			var oTr = new Element('tr',{id:'trB_'+i,'idB':'trB_'+i});
			oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
			var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(new Element('input', {type:'text', id:'text1_1_'+countB, size:'2',maxlength:"3",name:'BEG_TERM',value:(ReneList[i]['BEG_TERM']||ReneList[i]['BEG_TERM']===0)?ReneList[i]['BEG_TERM']:''}));
			
			otd.insert('-').insert(new Element('input', {type:'text', id:'text2',  size:'3',maxlength:"3",name:'END_TERM',value:(ReneList[i]['END_TERM']||ReneList[i]['END_TERM']===0)?ReneList[i]['END_TERM']:''}))
			otd.insert('期，比率').insert(new Element('input', {type:'text', id:'text3', size:'4', name:'RENEGE_RATE',value:(ReneList[i]['RENEGE_RATE']||ReneList[i]['RENEGE_RATE']===0)?ReneList[i]['RENEGE_RATE']:''}))
			otd.insert('%')
			
			oTr.insert(otd);
			$('grid_body1').insert(oTr);
		}
		$('IS_RENEGE').click();
	}else if(update=='N'){
		$('IS_RENEGE').value='';
		for(var i=0;i<ReneList_size;i++){
			var oTr = new Element('tr',{id:'trB_'+i,'idB':'trB_'+i});
			oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
			var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(new Element('input', {type:'text', id:'text1_1_'+countB, size:'2',maxlength:"3",name:'BEG_TERM',value:(ReneList[i]['BEG_TERM']||ReneList[i]['BEG_TERM']===0)?ReneList[i]['BEG_TERM']:''}));
		
			otd.insert('-').insert(new Element('input', {type:'text', id:'text2',  size:'3',maxlength:"3",name:'END_TERM',value:(ReneList[i]['END_TERM']||ReneList[i]['END_TERM']===0)?ReneList[i]['END_TERM']:''}))
			otd.insert('期，比率').insert(new Element('input', {type:'text', id:'text3', size:'4', name:'RENEGE_RATE',value:(ReneList[i]['RENEGE_RATE']||ReneList[i]['RENEGE_RATE']===0)?ReneList[i]['RENEGE_RATE']:''}))
			otd.insert('%')
			oTr.insert(otd);
			$('grid_body1').insert(oTr);
			$$('#grid_body1 tr').each(
				function(obj){
					obj.hide();
				}
			);
		}
		$('IS_RENEGE').checked=true;
		$('IS_RENEGE').click();
	}
	
	$('APPLY_ID_SHOW').innerHTML = dataMap.APPLY_ID || '';
	$('IS_FAST_AGREE_SHOW').innerHTML = dataMap.IS_FAST_AGREE || '';
	$('BORROW_NAME_SHOW').innerHTML = dataMap.BORROW_NAME || '';
	$('APPLY_PROCESS_NM_SHOW').innerHTML = dataMap.APPLY_PROCESS_NM || '';
	$('AGREE_PROCESS_NM_SHOW').innerHTML = dataMap.AGREE_PROCESS_NM || '';
	$('AGREE_LEVEL_NM_SHOW').innerHTML = dataMap.AGREE_LEVEL_NM || '';
	$('APPR_APPLY_ID').value = dataMap.APPR_APPLY_ID || '';
	$('MAIN_USE_NM_SHOW').innerHTML = dataMap.MAIN_USE_NM || '';
	$('FIREINSU_YY_SHOW').innerHTML = dataMap.FIREINSU_YY || '';
	$('FIREINSU_MM_SHOW').innerHTML = dataMap.FIREINSU_MM || '0';
	$('ACCOUNT_STATUS_SHOW').innerHTML = dataMap.ACCOUNT_STATUS_NM || '';
	$('VIP_GRADE_NM_SHOW').innerHTML = dataMap.VIP_GRADE_NM || '';
	$('AREA_CODE_930318_SHOW').innerHTML = dataMap.AREA_CODE_930318 + ' 區' || ' 區';
	//$('CRED_NOTE').value = dataMap.CRED_NOTE;
	$('MM_ID').value = dataMap.MM_ID || '';

	$('CRED_SHOW').innerHTML = ((dataMap.INPUT_NAME || '') + ' '+ (dataMap.CRED_TEL || ''));
	
	$('REAL_USE').value = dataMap.REAL_USE == undefined  ? '1' : dataMap.REAL_USE;
	$('A_VALUE').value = dataMap.A_VALUE == undefined  ? '1.00' : dataMap.A_VALUE;
	
	//核選方塊
	if (dataMap.GAGE_USE == '1'){
		$('GAGE_USE_1').checked = true;
	} else {
		$('GAGE_USE_0').checked = true;
	}
	
	//央行限制─購置特定地區
	<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
	if (dataMap.SPEC_CHECK_990625 == '1'){
		$('SPEC_CHECK_990625_1').checked = true;
		$('IS_CHANGE_HOUSE').enable();
		$('IS_CHANGE_HOUSE').setValue(dataMap.IS_CHANGE_HOUSE||'');
	} else if (dataMap.SPEC_CHECK_990625 == '0'){
		$('SPEC_CHECK_990625_0').checked = true;
		$('IS_CHANGE_HOUSE').disable();
		$('IS_CHANGE_HOUSE').setValue('');
	}
	
	//央行限制─高價住宅
	if (dataMap.IS_MANSION == '1'){
		$('IS_MANSION_1').checked = true;
		$('IS_MANSION_CNT').enable();
		$('IS_MANSION_CNT').setValue(dataMap.IS_MANSION_CNT||'');
	} else if (dataMap.IS_MANSION == '0'){
		$('IS_MANSION_0').checked = true;
		$('IS_MANSION_CNT').disable();
		$('IS_MANSION_CNT').setValue('');
	}
	
	//央行限制─法人購住
	if (dataMap.IS_COPRATION == '1'){
		$('IS_COPRATION_1').checked = true;
		$('IS_COPRATION_CNT').enable();
		$('IS_COPRATION_CNT').setValue(dataMap.IS_COPRATION_CNT||'');
	} else if (dataMap.IS_COPRATION == '0'){
		$('IS_COPRATION_0').checked = true;
		$('IS_COPRATION_CNT').disable();
		$('IS_COPRATION_CNT').setValue('');
	}
	
	//央行限制─購置第3戶
	if (dataMap.IS_THIRD_CODE == '1'){
		$('IS_THIRD_CODE_1').checked = true;
		$('IS_THIRD_CODE_CNT').enable();
		$('IS_THIRD_CODE_CNT').setValue(dataMap.IS_THIRD_CODE_CNT||'');
	} else if (dataMap.IS_THIRD_CODE == '0'){
		$('IS_THIRD_CODE_0').checked = true;
		$('IS_THIRD_CODE_CNT').disable();
		$('IS_THIRD_CODE_CNT').setValue('');
	}
	
	//貸款全期不更新客戶優質等級
	if (dataMap.IS_FIX_VIPGRADE == '1'){
		$('IS_FIX_VIPGRADE_1').checked = true;
	} else if (dataMap.IS_FIX_VIPGRADE == '0'){
		$('IS_FIX_VIPGRADE_0').checked = true;
	}else{
		$('IS_FIX_VIPGRADE_0').checked = false;
		$('IS_FIX_VIPGRADE_1').checked = false;
	}		
	
	//是否為保戶
	if (dataMap.IS_INSU == '1'){
		$('IS_INSU_1').checked = true;
	} else if (dataMap.IS_INSU == '0'){
		$('IS_INSU_0').checked = true;
	}else{
		$('IS_INSU_0').checked = false;
		$('IS_INSU_1').checked = false;
	}
	
	//是否為保戶3年
	if (dataMap.IS_INSU_3YEAR == '1'){
		$('IS_INSU_3YEAR_1').checked = true;
	} else if (dataMap.IS_INSU_3YEAR == '0'){
		$('IS_INSU_3YEAR_0').checked = true;
	}else{
		$('IS_INSU_3YEAR_0').checked = false;
		$('IS_INSU_3YEAR_1').checked = false;
	}
	
	//是否首月免息
	if (dataMap.REMISSION_NOTE == 'Y' || dataMap.REMISSION_INT == '1'){
		$('REMISSION_INT').checked = true;
	} else {
		$('REMISSION_INT').checked = false;
	}	
	
	$('INSUFREE_CODE').checked = (dataMap.INSUFREE_CODE == '1') ? true : false;
	$('IS_FIREINSU').checked = (dataMap.IS_FIREINSU == '1') ? true : false;
	$('INSU_NOTE').checked = (dataMap.INSU_NOTE == '1') ? true : false;
	$('CRED_STATUS1').checked = (dataMap.CRED_STATUS1 == '1') ? true : false;
	$('CRED_STATUS2').checked = (dataMap.CRED_STATUS2 == '1') ? true : false;
	$('CRED_STATUS3').checked = (dataMap.CRED_STATUS3 == '1') ? true : false;
	$('CRED_STATUS9').checked = (dataMap.CRED_STATUS9 == '1') ? true : false;
	$('CRED_STATUSA').checked = (dataMap.CRED_STATUSA == '1') ? true : false;
	$('CRED_STATUSB').checked = (dataMap.CRED_STATUSB == '1') ? true : false;
	
	<%-- [20211217] --%>
	$('AGREE_ITEM_01').checked = (dataMap.AGREE_ITEM_01 == '1') ? true : false;
	$('AGREE_ITEM_02').checked = (dataMap.AGREE_ITEM_02 == '1' || dataMap.AGREE_ITEM_02 == '2' || dataMap.AGREE_ITEM_02 == '3') ? true : false;
	$('AGREE_ITEM_03').checked = (dataMap.AGREE_ITEM_03 == '1') ? true : false;
	$('TRANS_CODE_2').checked = (dataMap.TRANS_CODE_2 == '2') ? true : false;
	$('AGREE_ITEM_02_MAP').setValue(dataMap.AGREE_ITEM_02);
	
	$('INTEREST_C_SHOW').update(localeDisplay.formatNumber(dataMap.INTEREST_C)) + ' %';
	$('INTEREST_C_M_SHOW').update(localeDisplay.formatNumber(dataMap.INTEREST_C_M)) + ' %';
						

	$('AVG_PRICE').setValue(dataMap.AVG_PRICE);
	$('AGREE_AMT').setValue(dataMap.AGREE_AMT);
	$('AGREE_AMT_M').setValue(dataMap.AGREE_AMT_M);
	$('SET_AMT').setValue(dataMap.SET_AMT);
	$('TOTAL_PREMIUM').setValue(dataMap.TOTAL_PREMIUM);
	$('LOAN_ABLE').setValue(dataMap.LOAN_ABLE);
	$('LOAN_REMAIN').setValue(dataMap.LOAN_REMAIN);
	$('FIREINSU_AMT').setValue(dataMap.FIREINSU_AMT);
	$('CRED_TRADE_AMT').setValue(dataMap.CRED_TRADE_AMT);
	$('APPR_TRADE_AMT').setValue(dataMap.APPR_TRADE_AMT);
	
	if(dataMap['PROD_ID']=='56'||dataMap['MM_CODE']=='1'){
		$('IS_ADJUST').checked=true;
		$('IS_ADJUST').enable();
		$('IS_ADJUST').click();
		$('IS_ADJUST').disable();
	}

 	//2016-12-12新增
	if(dataMap['PROD_ID']=='56'||dataMap['MM_CODE']=='0'){
		$('IS_ADJUST_M').checked=true;
		$('IS_ADJUST_M').enable();
		$('IS_ADJUST_M').click();
		$('IS_ADJUST_M').disable();
	}	
	
	if(dataMap['PROD_ID']=='56'||dataMap['MM_CODE']=='1'){
		$('IS_RENEGE').checked=true;
		$('IS_RENEGE').enable();
		$('IS_RENEGE').click();
		$('IS_RENEGE').disable();
	}
	
	if($('IS_ADJUST').checked){
		$('INTEREST').value=$('text6_0').innerHTML;
		//$('INTEREST').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
	}else{
		$('INTEREST').setValue(dataMap.INTEREST);
	}
	if($('IS_ADJUST_M').checked){
		$('INTEREST_M').value=$('text6_Fin_0').innerHTML;
		//$('INTEREST_M').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
	}else{
		$('INTEREST_M').setValue(dataMap.INTEREST_M);
	}
	
	
	//作業日期
	$('INPUT_DATE_SHOW').innerHTML = getDateField(dataMap.INPUT_DATE);
	
	//建築完成日
	$('FINISH_DATE_SHOW').innerHTML = getDateField(dataMap.FINISH_DATE);
	$('LAND_SPACE_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.LAND_SPACE) + ' 坪';
	$('BUILD_SPACE_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.BUILD_SPACE) + ' 坪';
	$('APPR_AMT_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.APPR_AMT) + ' 元';
	$('LIMIT_AMT_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.LIMIT_AMT);
	$('GA_RATE_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.GA_RATE) + ' %';
	$('GAGE_AMT_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.GAGE_AMT) + ' 萬';
	$('GAGE_AMT_M_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.GAGE_AMT_M) + ' 萬';
	$('LOAN_LIMIT_C_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.LOAN_LIMIT_C);
	$('LOAN_LIMIT_SHOW').innerHTML = localeDisplay.formatNumber(dataMap.LOAN_LIMIT);

	//若PREFER_TYPE等於56 或是 MM_CODE等於1，則適用保戶123不可勾選且DISABLED
	PREFER_TYPE = dataMap.PREFER_TYPE;
	MM_CODE = dataMap.MM_CODE;
	if(PREFER_TYPE == '56' || MM_CODE == '1' || dataMap.IS_MANSION == '1' || dataMap.SPEC_CHECK_990625 == '1'){
		$('INSU_NOTE').checked = false;	
		$('INSU_NOTE').disabled = true;	
	
	} else if (dataMap.INSU_NOTE == "" || dataMap.INSU_NOTE == undefined){ 
		//若A130中無INSU_NOTE值，則 適用保戶123 預設打勾
		$('INSU_NOTE').checked = true;		
	}
	
	//帳管費
	if(dataMap.IS_EXPENSE == '1'){
		$('IS_EXPENSE').checked = true;
		$('EXPENSE_AMT').disabled = false;
	}else{
		$('IS_EXPENSE').checked= false;
		$('EXPENSE_AMT').disabled = true;	
	}


	$('AGREE_HISTORY').innerHTML = dataMap.AGREE_HISTORY || '';
	if($('AGREE_HISTORY').innerHTML != ''){
		$('div_I').style.display = 'block';
	} else {
		$('div_I').style.display = 'none';
	}
	
	//近3個月是否有投保新契約
	<%-- 20200901 效能問題，畫面改成一律顯示超連結，由另一個畫面去查新契約資料 --%>
	/*if('Y'==dataMap.hasATApply){
		$$('.hasATApply').each(function(ele){
			ele.show();
		});
	}else{
		$$('.hasATApply').each(function(ele){
			ele.hide();
		});
	}*/
	
	//[20210315]申請書210311001575-快審件規則調整
	//承作成數區域比照一般簽件畫面
	$('CRED_ADD_RATE').update(dataMap.CRED_ADD_RATE||'0');
	$('VIP_ADD').setValue(dataMap.VIP_ADD||'0');
	$('VIP_ADD_RATE').update(dataMap.VIP_ADD_RATE||'0');
	//「區域加成」下拉選單
	var AreaAdd_mapList =  resp ? resp.AreaAdd_mapList.evalJSON() : '${AreaAdd_mapList}'.evalJSON();
	AreaAdd_mapList = AreaAdd_mapList? AreaAdd_mapList:[];
	var target = $('AREA_ADD');
	if(target){
		if(AreaAdd_mapList){
			target.options.length = 0;
			for(var i = 0; i < AreaAdd_mapList.length; i++){
				target.options.add(new Option(AreaAdd_mapList[i]['CODE_NM'], AreaAdd_mapList[i]['CODE']));
			}
		}
	}
	//「區域加成」下拉選單 [失效項選取調整]
	var AREA_ADD_OPTS = $('AREA_ADD').options;
	if(AREA_ADD_OPTS.length > 0){
		var hasValue = false;
		for(var i =0 ; i<AREA_ADD_OPTS.length;i++){
			if(AREA_ADD_OPTS[i].value == dataMap.AREA_ADD){
				hasValue = true;
				break;
			}
		}
		if(!hasValue){
			if( dataMap.AREA_ADD == "" || dataMap.AREA_ADD == undefined ){
				$('AREA_ADD').setValue("1");//無值時預設1:無
			}else{
				$('AREA_ADD').setValue("");//失效項選取
			}
		}else{
			$('AREA_ADD').setValue(dataMap.AREA_ADD);
		}
		
		// 載入資料後，要做的控制
		if($F('AREA_ADD') != "" && $F('AREA_ADD') != "1"){
			$('AREA_ADD_RATE').innerHTML = "+5";
		}else{
			$('AREA_ADD_RATE').innerHTML = "0";
		}
	}
	// 載入資料後，要做的控制
	$('INVEST_ADD').checked = (dataMap.INVEST_ADD=='1');
	$('INVEST_ADD_RATE').update((dataMap.INVEST_ADD=='1')?"-5":"");
	
	<%--[申請書:220908003741]新增本金彈性還還款方式--%>
	if(dataMap['IS_FLEX'] == 'N'){
		$('AGREE_FLEX_TYPE_0').disable();
		$('AGREE_FLEX_TYPE_1').disable();
		$('AGREE_FLEX_TYPE_2').disable();
		$('AGREE_FLEX_AMT').disable();
	}
	var AGREE_FLEX_TYPE = dataMap.AGREE_FLEX_TYPE
	if('0' == AGREE_FLEX_TYPE){
		$('AGREE_FLEX_TYPE_0').checked = true;
		$('AGREE_FLEX_AMT').setValue('');
	}else if('1' == AGREE_FLEX_TYPE){
		$('AGREE_FLEX_TYPE_1').checked = true;
		$('AGREE_FLEX_AMT').setValue('');
	}else if('2' == AGREE_FLEX_TYPE){
		$('AGREE_FLEX_TYPE_2').checked = true;
		$('AGREE_FLEX_AMT').setValue(DataMap.AGREE_FLEX_AMT);
	}
	$('FLEX_MIN_SP').update(CSRUtil.$fmt(dataMap.FLEX_MIN, "#,###"));
	$('FLEX_MAX_SP').update(CSRUtil.$fmt(dataMap.FLEX_MAX, "#,###"));
}

function getDateField(str){
	return str ? Date.toROC(str) : "";
}

function buttonAuth(){
	var authButtons = {
			B0009:"btn_cancel"<%--取消--%>,
			B0072:"btn_update"<%--試算--%>,
			B0055:"btn_confirm"<%--簽件--%>,
			B0129:"btn_eland"<%--電子謄本查詢--%>,
			B0130:"btn_elandImage"<%--電子謄本影像--%>
	};
	<dz:grantButtons FUNC_ID="DSA21002" ignored="false"/>
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------

var grid;  
function UI(){

	return {
		init:function() {
								
			grid = new TableUI({
					table: $('grid'), pageSize: 10, allSortable: true,overDiv:false,
					column:[
						{header:'檔名', key:'FILE_NM',render: function(record , value){
								var link = document.createElement('a') ;
								link.href = '#' ;
								link.onclick = function(){
									var obj={};
									obj.FILE_ID = record.FILE_ID;
		
									actions.ajaxPostDSA2_2400( "download", obj, function (resp) {
											if(CSRUtil.isSuccess(resp)){
												RPTUtil.download({
													'downloadFileName': resp.FILE_NM,
													'downloadFileFullPath': resp.FILE_PATH
												})
											}
										}, function(){}, "DSA2_2400"
									);
								} ;
								link.innerHTML = value ;	
								return link ;
							}
						},
						{header:'產製人員', key:'LST_PROC_NAME'},
						{header:'產製日期', key:'LST_PROC_DT'}
					]
			});
			
			// 試算按鈕
			$("btn_update").observe('click',function(event){
				doTrimTextArea();
				buttons.doUpdateCheck();										
			});
			
			// 簽件按鈕
			$("btn_confirm").observe('click',function(event){
				doTrimTextArea();
				buttons.doConfirmCheck();										
			});
			
			// 取消按鈕
			$("btn_cancel").observe('click',function(event){
				buttons.doCancel();										
			});
			
			//不動產明細
			$("btn_DSA21006").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1006');
			});
			
			//批覆書
			$("btn_DSA21007").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1007');
			});			
			
                        //鑑估表
			$("btn_DSA21008").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1008');
			});	
			
			$('btn_eland').observe('click', buttons.doEland ); //電子謄本查詢按鈕
			
			$('btn_elandImage').observe('click', buttons.doElandImage ); //電子謄本影像按鈕

			// 一般型擬准金額
			$("AGREE_AMT").observe('blur',function(event){
				// 計算擔累貸金額∕鑑估總值		
				doCalGA_Rate();										
			});
			
			// 理財型擬准金額
			$("AGREE_AMT_M").observe('blur',function(event){
				//計算擔累貸金額∕鑑估總值	
				doCalGA_Rate();										
			});
			
			// 買契價格
			$("CRED_TRADE_AMT").observe('blur',function(event){
				//計算擔累貸金額∕鑑估總值	
				doCalGA_Rate();
				doCalLoanLimitC();									
			});
			
			// 擔保品使用狀況						
			$("GAGE_USE_0").observe('click',function(event){
				//計算區域放款率
				doCalLoanLimitC();					
			});
			$("GAGE_USE_1").observe('click',function(event){
				//計算區域放款率
				doCalLoanLimitC();					
			});
			
			$w('APPR_APPLY_ID').each( 
				function(key){
					$(key).observe('blur', function(event){
						event.target.value = event.target.value ? event.target.value.toUpperCase() : "";
					});
				}
			);
			
			// 帳管費
			$('IS_EXPENSE').observe('click',function(event){
				var obj = $('EXPENSE_AMT');
				if($('IS_EXPENSE').checked){
					obj.disabled = false;
				}else{
					obj.value = '';
					obj.disabled = true;
				}
			});
			
			// 是否為保戶(否)
			$("IS_INSU_0").observe('click',function(event){
				$('TOTAL_PREMIUM').value='0';
				$('LOAN_ABLE').value='0';
				$('LOAN_REMAIN').value='0';		
				$('IS_INSU_3YEAR_1').checked=false;
				$('IS_INSU_3YEAR_0').checked=true;								
			});
			/*
			$w('IR_ADJ_REASON1 IR_ADJ_REASON2 IR_ADJ_REASON3 IR_ADJ_REASON4 IR_ADJ_REASON5').each(function(id){
				$(id).observe('click',function(event){
					if($(id).checked){
						if(id=='IR_ADJ_REASON1'){
							alert('-0.05% ~ -0.1%');
						}else if(id=='IR_ADJ_REASON2'){
							alert('●年繳化保費350萬以上：\n   -0.12% ~ -0.20%\n●年繳化保費150-350萬：\n   -0.09% ~ -0.17%\n●年繳化保費50-150萬：\n   -0.06% ~ -0.14%\n●年繳化保費20-50萬：\n   -0.04% ~ -0.12%');
						}else if(id=='IR_ADJ_REASON3'){
							alert('-0.3% ~ +0.3%');
						}else if(id=='IR_ADJ_REASON4'){
							alert('-0.3% ~ +0.3%');
						}else if(id=='IR_ADJ_REASON5'){
							alert('0% ~ -0.3%');
						}
					}
					
				});
			});
			*/
			
			$('INVEST_ADD').observe('click',function(event){ 
				$('INVEST_ADD_RATE').innerHTML = ($('INVEST_ADD').checked)?"-5":"0";
				doCalLoanLimit();
			});
			
			// 區域加成條件
			$('AREA_ADD').observe('change',function(event){
				var value = $('AREA_ADD').value;
				if(value != "" && value != "1"){
					$('AREA_ADD_RATE').innerHTML = "+5";
					if($('AREA_ADD').value == '5'){
						$('INVEST_ADD').checked = false;
						$('INVEST_ADD_RATE').innerHTML = "0";
						$('IS_MANSION_0').checked = true;
					}else if($('AREA_ADD').value == '2' ){
					    alert('區域加成條件不可選擇捷運沿線!!');
					    $('AREA_ADD').value = '1';
					    $('AREA_ADD_RATE').innerHTML = "0";
					}else if( $('AREA_ADD').value == '4'){
					    alert('區域加成條件不可選擇符合太平市地區!!');
					    $('AREA_ADD').value = '1';
					    $('AREA_ADD_RATE').innerHTML = "0";
					}
				}else{
					$('AREA_ADD_RATE').innerHTML = "0";
				}
				doCalLoanLimit();
			});
		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {

	doChangText:function(event){
		var ele_ID = Event.element(event).id;
		var count = ele_ID.split('_')[1];
		
		if(!$F('text3_'+count)){
			$('text3_'+count).value=0;
		}
		$('text5_'+count).update(CSRUtil.round(parseFloat($('text3_'+count).value)+parseFloat(AdjList[count]['IR_RT']),6));
		$('text6_'+count).update(CSRUtil.round(parseFloat($('text3_'+count).value)+parseFloat(AdjList[count]['IR_RT'])+parseFloat(AdjList[count]['BAS_RT']),6));
		$('INTEREST').value=$('text6_0').innerHTML;
		//$('INTEREST').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
	},
	doChangTextFin:function(event){   //2016-12-12新增
		var ele_ID = Event.element(event).id;
		var count = ele_ID.split('_')[2];
		
		if(!$F('text3_Fin_'+count)){
			$('text3_Fin_'+count).value=0;
		}
		$('text5_Fin_'+count).update(CSRUtil.round(parseFloat($('text3_Fin_'+count).value)+parseFloat(MAdjList[count]['IR_RT']),6));
		$('text6_Fin_'+count).update(CSRUtil.round(parseFloat($('text3_Fin_'+count).value)+parseFloat(MAdjList[count]['IR_RT'])+parseFloat(MAdjList[count]['BAS_RT']),6));
		$('INTEREST_M').value=$('text6_Fin_0').innerHTML;
		//$('INTEREST_M').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
	},
	//連動取得BAS_RT  IR_RT
	doChangText1:function(event){//發送AJAX查詢
		var ele_ID = Event.element(event).id;
		var count = ele_ID.split('_')[1];
		
		var reqMap=[];
		reqMap['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
		reqMap['BEG_TERM']=$F('text1_'+count);
		
		actions.ajaxPostDSA2_1002( 'changtext' , reqMap ,
			function(resp){
				query_AdjList=resp.AdjList;
				$('text4_'+count).update(query_AdjList[0]['BAS_RT']);
				if($('text4_'+count).innerHTML===0||$('text4_'+count).innerHTML=='0'){
					$('text7_'+count).disabled=true;
				}
				$('text5_'+count).update("+"+(CSRUtil.round(parseFloat(query_AdjList[0]['IR_RT']),6)));
				$('text6_'+count).update("="+(CSRUtil.round(parseFloat(query_AdjList[0]['IR_RT'])+parseFloat(query_AdjList[0]['BAS_RT']),6)));
			});
	},
	doChangText2:function (event){
		var ele_ID = Event.element(event).id;
		var count = ele_ID.split('_')[1];
		if(Object.toJSON(query_AdjList)=='{}'){
			alert("請先輸入期數");
			return;
		}
		
		$('text5_'+count).update("+"+(CSRUtil.round((parseFloat($('text3_'+count).value)+parseFloat(query_AdjList[0]['IR_RT'])),6)));
		$('text6_'+count).update("="+(CSRUtil.round(parseFloat($('text3_'+count).value)+parseFloat(query_AdjList[0]['IR_RT'])+parseFloat(query_AdjList[0]['BAS_RT']),6)));
	},
	//利率個調
	doInsert1: function(){
		var oTr = new Element('tr', {id:'tr_'+count,'id2':'tr_'+countA});
		oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+countA,name:'radioGroup' ,value:'1' })));
		
		var oInput_BEG_TERM = new Element('input', {type:'text', id:'text1_'+countA, size:'2',value:'','datatype':"number" ,maxlength:"3",name:'BEG_TERM'});
		oInput_BEG_TERM.observe('change',function(event){
			if(isNaN(oInput_BEG_TERM.value)){
				oInput_BEG_TERM.value='';
			}
			var num1=oInput_BEG_TERM.value;
			var num2=oInput_BEG_TERM.up().up().previousSibling?oInput_BEG_TERM.up().up().previousSibling.down().nextSibling.down().nextSibling.nextSibling.value||parseInt(num1)-1:parseInt(num1)-1;
			var num3=oInput_BEG_TERM.nextSibling.nextSibling.value||999;
			if(num1||num1===0){
				if(parseInt(num1)!=parseInt(num2)+1||parseInt(num1)>=parseInt(num3)){
					alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
					oInput_BEG_TERM.value='';
				}else{
					buttons.doChangText1(event);
				}
			}
		});
		
		var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(oInput_BEG_TERM);
		var oInput_END_TERM=new Element('input', {type:'text', id:'text2',  size:'3',value:'',maxlength:"3",name:'END_TERM'});
		oInput_END_TERM.observe('change',function(event){
			if(isNaN(oInput_END_TERM.value)){
				oInput_END_TERM.value='';
			}
			var num1=oInput_END_TERM.value;
			var num2=oInput_END_TERM.previousSibling.previousSibling.value||0;
			var num3=oInput_END_TERM.up().up().nextSibling?oInput_END_TERM.up().up().nextSibling.down().nextSibling.down().value||parseInt(num1)+1:parseInt(num1)+1;
			if(num1||num1===0){
				if(parseInt(num1)<=parseInt(num2)||parseInt(num1)!=parseInt(num3)-1){
					alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
					oInput_END_TERM.value='';
				}
			}
		});
		
		otd.insert("-").insert(oInput_END_TERM);
		otd.insert("期，加減碼").insert(new Element('input', {type:'text', id:'text3_'+countA, size:'3', value:'',name:'RT_ADJ'}));
		
		otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+countA, size:'3', value:'',name:'BAS_RT'}));//指標利率
		otd.insert(new Element('span', {type:'text', id:'text5_'+countA, size:'3', value:'',name:'TOT_ADJ'}));//加減碼利率
		otd.insert(new Element('span', {type:'text', id:'text6_'+countA, size:'3', value:'',name:'TOT_RT'}));//貸款利率
		otd.insert('<br>').insert(new Element('input', {type:'radio', id:'text7_',name:'IS_FIX_'+count, value:'0'}));
		otd.insert("浮動 ").insert(new Element('input', {type:'radio', id:'text8_',name:'IS_FIX_'+count, value:'1'}));
		otd.insert("固定");
		//otd7.insert(new Element('td',{id:'text9'}).update('固定'));
		oTr.insert(otd);
		$('grid_body').insert(oTr);
		if($('text4_'+countA).innerHTML===0||$('text4_'+countA).innerHTML=='0'){
			$('text7_'+count).disabled=true;
		}
		count=count+1;
		countA=countA+1;
	}
	//利率個調
	,doDelete1 :function(){
		count=count-1;
		var no;
		var check=$$('#grid_body input:checked[name=radioGroup]');
		if(check.length == 0){
			alert('至少選取一筆資料刪除');
			return;				
		}
		
		$$('#grid_body input:checked[name=radioGroup]').each(function(ele){

			no='tr_'+ele.id.substring(ele.id.length-1,ele.id.length);
		});
		
		$$('#grid_body tr[id2="' + no + '"]').each(
			function(obj){
				for(var lastCell = obj.cells.length-1; lastCell >= 0; lastCell--){
					// 清除td裡面的內容
					obj.cells[lastCell].innerHTML = "";
					obj.removeChild(obj.cells[lastCell]);
				}
				obj.parentElement.removeChild(obj);
			}
		);
	},
	//提前清償違約金:
	doInsert2: function(){

		var oTr = new Element('tr', {id:'trB_'+count1,'idB':'trB_'+countB});
		oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+countB,name:'radioGroup1' ,value:'1'})));
		var oInput_BEG_TERM=new Element('input', {type:'text', id:'text1_1_'+countB, size:'2',maxlength:"3",value:'',name:'BEG_TERM'})
		oInput_BEG_TERM.observe('change',function(event){
			if(isNaN(oInput_BEG_TERM.value)){
				oInput_BEG_TERM.value='';
			}
			var num1=oInput_BEG_TERM.value;
			var num2=oInput_BEG_TERM.up().up().previousSibling?oInput_BEG_TERM.up().up().previousSibling.down().nextSibling.down().nextSibling.nextSibling.value||parseInt(num1)-1:parseInt(num1)-1;
			var num3=oInput_BEG_TERM.nextSibling.nextSibling.value||999;
			if(num1||num1===0){
				if(parseInt(num1)!=parseInt(num2)+1||parseInt(num1)>=parseInt(num3)){
					alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
					oInput_BEG_TERM.value='';
				}
			}
		});
		var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(oInput_BEG_TERM);
		
		var oInput_END_TERM=new Element('input', {type:'text', id:'text2',  size:'3',value:'',maxlength:"3",name:'END_TERM'})
		oInput_END_TERM.observe('change',function(event){
			if(isNaN(oInput_END_TERM.value)){
				oInput_END_TERM.value='';
			}
			var num1=oInput_END_TERM.value;
			var num2=oInput_END_TERM.previousSibling.previousSibling.value||0;
			var num3=oInput_END_TERM.up().up().nextSibling?oInput_END_TERM.up().up().nextSibling.down().nextSibling.down().value||parseInt(num1)+1:parseInt(num1)+1;
			if(num1||num===0){
				if(parseInt(num1)<=parseInt(num2)||parseInt(num1)!=parseInt(num3)-1){
					alert("期數起迄有誤，可能有重覆的期數，或前後不連續");
					oInput_END_TERM.value='';
				}
			}
		});
		otd.insert('-').insert(oInput_END_TERM);
		otd.insert('期，比率').insert(new Element('input', {type:'text', id:'text3', size:'4', value:'',name:'RENEGE_RATE'}));
		otd.insert('%')
		oTr.insert(otd);
		$('grid_body1').insert(oTr);
		count1=count1+1;
		countB=countB+1;
	},
	//提前清償違約金
	doDelete2 :function(){
		count1=count1-1;
		var no;
		var check=$$('#grid_body1 input:checked[type=radio]');
		
		if(check.length == 0){
			alert('至少選取一筆資料刪除');
			return;				
		}
		
		$$('#grid_body1 input:checked[type=radio]').each(function(ele){
			no='trB_'+ele.id.substring(ele.id.length-1,ele.id.length);
		});
		
		$$('#grid_body1 tr[idB="' + no + '"]').each(
			function(obj){
				for(var lastCell = obj.cells.length-1; lastCell >= 0; lastCell--){
					// 清除td裡面的內容
					obj.cells[lastCell].innerHTML = "";
					obj.removeChild(obj.cells[lastCell]);
				}
				obj.parentElement.removeChild(obj);
			}
		);
	},
	//試算前確認
	doUpdateCheck:function(){
		var actionName = "update";
		var msg = '請先查詢，再進行試算!';
		
		if(!checkInput(actionName, msg, true)){
			return;
		}
		var reqMap = Form.serialize("form1",true);	
		
		getReqMapData(reqMap);
		
		var A147_tempList=[];
		var A148_tempList=[];
		var A147M_tempList = [];  //2016-12-12 新增此判斷參數
		reqMap['IS_ADJUST']=$F('IS_ADJUST');
		reqMap['IS_RENEGE']=$F('IS_RENEGE');
		reqMap['IS_ADJUST_M']=$F('IS_ADJUST_M');
		
		//一般型利率個調
		if($('IS_ADJUST').checked){
			var  check=false;
			$$('#grid_body input[type=text]').each(
				function(obj){
					if(!obj.value){
						
						check=true;
						return;
					}
				}
			);
			if($$('#grid_body input[type=text]').length===0){
				check=true;
			}
			if(check){
				alert("請輸入「利率個調資料」!(利率個調資料所有欄位為必輸)")
				return;
			}
			
			var check1=true;
			for(var i=0;i<$$('#grid_body input[type=radio]').length/3;i++){
				$$('#tr_'+ i + ' input[name=IS_FIX_'+i+']').each(function(ele){
					if(ele.checked==true){
						check1=false;
						return;
					}
				});	
				if(check1===true){
				alert('請選擇浮動或固定!');
					return;
				}
			}
		
			var  check2=false;
			if($$('#grid_body input[type=text]')[0]){
				if($$('#grid_body input[type=text]')[0].value!=1){
					alert("利率個調資料期數必須由第1期開始!")
					return;
				}
				
				if($$('#grid_body input[type=text][name=END_TERM]')[$$('#grid_body input[type=text][name=END_TERM]').length-1].value!=dataMap.LOAN_PERIOD){
					alert("期數必須由最後一期結束!");
					check2=true;
					return;
				}
			}
			if(check2){
				return;
			}
			
			var datas=$$('#grid_body input[type=radio]');
			for(var i=0;i<datas.length/3;i++){ 
				var map={}; 			
				datas[i*3].up('tr').select('input[type=text]').each(function(ele){
					map[ele.name]=ele.value;
				});
				datas[i*3].up('tr').select('input:checked[name=IS_FIX_'+i+']').each(function(ele){	
					map['IS_FIX']=ele.value;
				});
				datas[i*3].up('tr').select('span[name=BAS_RT]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				datas[i*3].up('tr').select('span[name=TOT_ADJ]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				datas[i*3].up('tr').select('span[name=TOT_RT]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				map['IS_ADJUST']=1;
				map['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
				map['AREA_CODE']=$F('AREA_CODE_930318');
				A147_tempList.push(map);
			}
			reqMap['IS_ADJUST']=1;
		}
		
		//理財型利率個調
		if($('IS_ADJUST_M').checked){   //2016-12-12新增加
			var check=false;
			$$('#grid_body_Fin input[type=text]').each(
				function(obj){
					if(!obj.value){
						check=true;
						return;
					}
				}
			);
			if($$('#grid_body_Fin input[type=text]').length===0){
				check=true;
			}
			if(check){
				alert("請輸入「理財型利率個調資料」!")
				return;
			}		
			var check2=false;
			$$('#grid_body_Fin input[type=text]').each(
				function(obj){
					if(!Number(obj.value) || Number(obj.value) == 0){
						check2=true;
						return;
					}
				}
			);	
			if(check2){
				alert("理財型利率個調加減碼需為非0數字")
				return;
			}		

			//抓資料送回後端
			var DTDSA147MRows = $('grid_body_Fin').rows;
			var oTr = $(DTDSA147MRows[0]);
			var map={};

			oTr.select('input[type=text]').each(function(ele){
				map[ele.name]=ele.value;
			});

			map['IS_FIX']= 0;

			oTr.select('span[name=BAS_RT]','span[name=TOT_ADJ]','span[name=TOT_RT]').each(function(ele){
				map[ele.name]=ele.innerHTML;
			});
			map['IS_ADJUST_M']=1;
			map['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
			map['AREA_CODE']=$F('AREA_CODE_930318');
			A147M_tempList.push(map);
			reqMap['IS_ADJUST_M']=1;   //2016-12-12 新增
		}
		
		//提前清償違約金
		if($('IS_RENEGE').checked){
			var check3=false;
			$$('#grid_body1 input[type=text]').each(
				function(obj){
					if(!obj.value){
						
						check3=true;
						return;
					}
				}
			);
			if($$('#grid_body1 input[type=text]').length===0){
				check3=true;
			}
			if(check3){
				alert("請輸入「提前清償解約金資料」!(提前清償解約金資料所有欄位為必輸)")
				return;
			}
			if($$('#grid_body1 input[type=text]')[0]){
				if(countB!='0'&&$$('#grid_body1 input[type=text]')[0].value!=0){
					alert("提前清償解約金資料期數必須由第0期開始!")
					return;
				}
			}
		
			var datas=$$('#grid_body1 input[type=radio]');
			for(var i=0;i<datas.length;i++){
				var map2={};
				datas[i].up('tr').select('input[type=text]').each(function(obj){
					map2[obj.name]=obj.value;
				});
				map2['IS_RENEGE']=1;
				map2['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
				map2['AREA_CODE']=$F('AREA_CODE_930318');
				A148_tempList.push(map2);
			}
			reqMap['IS_RENEGE']=1;
		}
		
		//2016-12-12 多加 A147M_LIST這個參數  為了 理財型利率
		var params = {
			reqMap:Object.toJSON(reqMap),
			A147_LIST:Object.toJSON(A147_tempList),
			A147M_LIST:Object.toJSON(A147M_tempList),
			A148_LIST:Object.toJSON(A148_tempList) 
		};
		
		actions.ajaxPostDSA2_1002( 'updateCheck' , params ,
			function(resp){
				//[20240326]申請書240205006925：因updateCheck會先查一次承作區，檢核完後直接將結果帶入update，不需要再重查
				params['reqMap']=Object.toJSON(resp.dataMap);
				if (resp.UpdateCheckMSG1 == 'OK'){
					buttons.doUpdate(params);
				} else {
		        	msgWin.setCallback(function(){   
						buttons.doUpdate(params);
					});
				}
			});
	},
	//試算
	doUpdate:function(reqMap){
		msgWin.clearCallback();
		
		actions.ajaxPostDSA2_1002( 'update' , reqMap ,
			function(resp){
				$('UpdateSuccess').value = resp.UpdateSuccess;
				loadData(resp.DataMap,resp);
				$('CRED_NOTE').value = resp.CRED_NOTE;
				if (resp.AlertMsg){
					alert(resp.AlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n"));
				}
			},function(resp){
				$('UpdateSuccess').value = 'false';
			});
	},
	//簽件前確認
	doConfirmCheck:function(){
		var actionName = "confirm";
		var msg = '請先查詢，再進行簽件!';
		
		if(parent.form1.CONTROL_CODE.value == "ERR"){
	       	alert("本件為特殊控管件,無法進行簽件!!");
	    	return;
	    }
		
		if(!checkInput(actionName, msg, true)){
			return;
		}	
		var reqMap = Form.serialize("form1",true);	
		
		getReqMapData(reqMap);
		
		var A147_tempList=[];
		var A148_tempList=[];
		var A147M_tempList=[];    //2016-12-12 新增此參數
		reqMap['IS_ADJUST']=$F('IS_ADJUST');
		reqMap['IS_RENEGE']=$F('IS_RENEGE');
		reqMap['IS_ADJUST_M']=$F('IS_ADJUST_M');
		var params;
		if($('IS_ADJUST').checked){
			var check=false;
			$$('#grid_body input[type=text]').each(
				function(obj){
					if(!obj.value){
						check=true;
						return;
					}
				}
			);
			if($$('#grid_body input[type=text]').length===0){
				check=true;
			}
			if(check){
				alert("請輸入「利率個調資料」!(利率個調資料所有欄位為必輸)");
				return;
			}
			var check1=true;
			for(var i=0;i<$$('#grid_body input[type=radio]').length/3;i++){
				$$('#tr_'+ i + ' input[name=IS_FIX_'+i+']').each(function(ele){
					if(ele.checked==true){
						check1=false;
						return;
					}
				});
				if(check1){
					return;
				}
			}
		
			var check2=false;
		
			if($$('#grid_body input[type=text]')[0]){
				if($$('#grid_body input[type=text]')[0].value!=1){
					alert("利率個調資料期數必須由第1期開始!")
					return;
				}
				if($$('#grid_body input[type=text][name=END_TERM]')[$$('#grid_body input[type=text][name=END_TERM]').length-1].value!=dataMap.LOAN_PERIOD){
					alert("期數必須由最後一期結束!");
					check2=true;
					return;
				}
			}
			
			if(check2){
				return;
			}
			
			var datas=$$('#grid_body input[type=radio]');
			for(var i=0;i<datas.length/3;i++){
				var map={}; 			
				datas[i*3].up('tr').select('input[type=text]').each(function(ele){
					map[ele.name]=ele.value;
				});
				datas[i*3].up('tr').select('input:checked[name=IS_FIX_'+i+']').each(function(ele){
					map['IS_FIX']=ele.value;
				});
				datas[i*3].up('tr').select('span[name=BAS_RT]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				datas[i*3].up('tr').select('span[name=TOT_ADJ]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				datas[i*3].up('tr').select('span[name=TOT_RT]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				map['IS_ADJUST']=1;
				map['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
				map['AREA_CODE']=$F('AREA_CODE_930318');
				A147_tempList.push(map);
			}
			reqMap['IS_ADJUST']=1;
		}
		
		if($('IS_ADJUST_M').checked){  //2016-12-12新增加
			var check=false;
			$$('#grid_body_Fin input[type=text]').each(
				function(obj){
					if(!obj.value){
						check=true;
						return;
					}
				}
			);
			if($$('#grid_body_Fin input[type=text]').length===0){
				check=true;
			}
			if(check){
				alert("請輸入「理財型利率個調資料」!")
				return;
			}	
			var check2=false;
			$$('#grid_body_Fin input[type=text]').each(
				function(obj){
					if(!Number(obj.value) || Number(obj.value) == 0){
						check2=true;
						return;
					}
				}
			);	
			if(check2){
				alert("理財型利率個調加減碼需為非0數字")
				return;
			}				

			//抓資料送回後端
			var DTDSA147MRows = $('grid_body_Fin').rows;
			var oTr = $(DTDSA147MRows[0]);
			var map={};

			oTr.select('input[type=text]').each(function(ele){
				map[ele.name]=ele.value;
			});

			map['IS_FIX']= 0;

			oTr.select('span[name=BAS_RT]','span[name=TOT_ADJ]','span[name=TOT_RT]').each(function(ele){
				map[ele.name]=ele.innerHTML;
			});
			map['IS_ADJUST_M']=1;
			map['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
			map['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
			A147M_tempList.push(map);
			reqMap['IS_ADJUST_M']=1;   //2016-12-12 新增
		}
		
		if($('IS_RENEGE').checked){
			var check3=false;
			$$('#grid_body1 input[type=text]').each(
				function(obj){
					if(!obj.value){
						
						check3=true;
						return;
					}
				}
			);
			if($$('#grid_body1 input[type=text]').length===0){
				check3=true;
			}
			if(check3){
				alert("請輸入「提前清償解約金資料」!(提前清償解約金資料所有欄位為必輸)")
				return;
			}
			if($$('#grid_body1 input[type=text]')[0]){
				if(countB!='0'&&$$('#grid_body1 input[type=text]')[0].value!=0){
					alert("提前清償解約金資料期數必須由第0期開始!")
					return;
				}
			}
		
			var datas=$$('#grid_body1 input[type=radio]');
			for(var i=0;i<datas.length;i++){
				var map2={};
				datas[i].up('tr').select('input[type=text]').each(function(obj){
					map2[obj.name]=obj.value;
				});
				map2['IS_RENEGE']=1;
				map2['APPLY_ID']=$('APPLY_ID_SHOW').innerHTML;
				map2['AREA_CODE']=$F('AREA_CODE_930318');
				A148_tempList.push(map2);
			}
			reqMap['IS_RENEGE']=1;
		}
		
		params = {reqMap:Object.toJSON(reqMap),A147_LIST:Object.toJSON(A147_tempList),A147M_LIST:Object.toJSON(A147M_tempList),A148_LIST:Object.toJSON(A148_tempList) };
		
		actions.ajaxPostDSA2_1002( 'confirmCheck' , params ,
			function(resp){
				var checkMoneyLaunderMsg = resp.checkMoneyLaunderMsg;
				var CHK_ID = resp.CHK_ID; //洗錢防制檢核紀錄畫面傳入ID
				if (checkMoneyLaunderMsg) {
					alert(checkMoneyLaunderMsg);
					if (CHK_ID) {
						//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
						var parms = { 
							'QUERY_ID' : CHK_ID,
							'QUERY_START_DATE' : resp.CURRENT_DATE,
							'QUERY_END_DATE' : resp.CURRENT_DATE
						}; 	
						buttons.doPopupWin(parms);
					}	
				} else {
					if (resp.ConfirmCheckMSG1 == 'OK'){
						buttons.doConfirmCheck2(params);
					} else {
						var ConfirmCheckMSG1 = resp.ConfirmCheckMSG1;
						
						if(ConfirmCheckMSG1){
							ConfirmCheckMSG1 = ConfirmCheckMSG1.replace(/\\r|\\n|\\r\\n/g, "\n");
						}
						if(!confirm(ConfirmCheckMSG1)){
							return false;
						}
						buttons.doConfirmCheck2(params);
					}
				}
			});
	},
	//簽件前確認2
	doConfirmCheck2:function(reqMap){
		msgWin.clearCallback();
		
		actions.ajaxPostDSA2_1002( 'confirmCheck2' , reqMap ,
			function(resp){
				if (resp.ConfirmCheckMSG2 == 'OK'){
					buttons.doConfirm(reqMap);
				} else {
		        	msgWin.setCallback(function(){   
						buttons.doConfirm(reqMap);
					});
				}
			});
	},	
	//簽件
	doConfirm:function(reqMap){
		msgWin.clearCallback();
		
		actions.ajaxPostDSA2_1002( 'confirm' , reqMap ,
			function(resp){
				loadData(resp.DataMap,resp);
				$('CRED_NOTE').value = resp.CRED_NOTE;
				if (resp.AlertMsg){
					alert(resp.AlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n"));
				}
			});
	},
	//取消
	doCancel:function(){
	
		var actionName = "cancel";
		var msg = '請先查詢，再進行取消!';
		
		if(!checkInput(actionName, msg, true)){
			return;
		}	
		
		var reqMap = Form.serialize("form1",true);	
		
		getReqMapData(reqMap);
		
		actions.ajaxPostDSA2_1002( 'cancel' , reqMap ,
			function(resp){
				loadData(resp.DataMap,resp);
				$('CRED_NOTE').value = resp.CRED_NOTE;
			});
	},
	// 電子謄本查詢
	doEland : function(){	
		var actionName = "eland";
		var msg = '請先查詢，再進行電子謄本查詢!';
		if(!checkInput(actionName, msg, false)){
			return;
		}
		actions.ajaxPostDSA2_1002( 'eland' , 
			{ APPLY_ID : $('APPLY_ID_SHOW').innerHTML,CASE_TYPE : $F('CASE_TYPE')} ,
			function(resp){}
		);
		
	},
	// 電子謄本影像
	doElandImage : function(){
	    var actionName = "elandImage";
		var msg = '請先查詢，再進行電子謄本影像查詢!';
		if(!checkInput(actionName, msg, false)){
			return;
		}
		actions.ajaxPostDSA2_1002( 'elandImage' , 
			{ APPLY_ID : $('APPLY_ID_SHOW').innerHTML,CASE_TYPE : $F('CASE_TYPE')} ,
			function(resp){
				$('blockF').innerHTML = '<table>' + (resp.rtnStr || '') + '</table>';
			}
		);
	},
	//導頁至DSA21006,DSA21007
	doLinkToPDF:function(target){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID="+$F('APPLY_ID');	
		window.open(url,target, "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	},
	//開啟新視窗(洗錢防制檢核紀錄)
  	doPopupWin:function(parms){			
		popupWin.popup({
			'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
			'parameters' :  {
				'dataObj' : Object.toJSON(parms)  //2018-05-11配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
			}
		});
  	},
  	
  	//新契約受理查詢作業
  	linkToDSA21018 : function(){
  		
  		popupWin.popup({
			'src': "<%=dispatcher%>/DSA2_1018/prompt?",
			'parameters' :  {
				'APPLY_ID' : dataMap.APPLY_ID,
				'BORROW_ID' : dataMap.BORROW_ID,
				'APPLY_DATE' : dataMap.SEND_DATE <%--20200424 申請書200407001711 徵信報告書加強審查作業：調整為送件日前三個月--%>
			}
		});
  	
  	}
};

var actions = {

	//共用ajax
	ajaxPostDSA2_1002 : function( actionName, params, successAction, errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA2_1002/" + actionName, {  
			parameters: params, 
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
					errorAction(resp);
				}
	        }
		});
	},
	ajaxPostDSA2_2400 : function( actionName, params, successAction, errorAction){
		new Ajax.Request("<%=dispatcher%>/DSA2_2400/" + actionName,{ 
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
};

//計算擔累貸金額∕鑑估總值
function doCalGA_Rate(){
	var reqMap = {};
	reqMap.APPR_AMT = $F('APPR_AMT');
	reqMap.AGREE_AMT = $F('AGREE_AMT');
	reqMap.AGREE_AMT_M = $F('AGREE_AMT_M');
	reqMap.GAGE_AMT = $F('GAGE_AMT');
	reqMap.GAGE_AMT_M = $F('GAGE_AMT_M');
	reqMap.RENT = $F('RENT');
	reqMap.PRE_SET_AMT = $F('PRE_SET_AMT');
	reqMap.SEPARATE_AMT = $F('SEPARATE_AMT');
	reqMap.TYPE = '2';	//案件種類:2=快審件
	reqMap.MM_ID = '';	//清償理財型帳號
	reqMap.CRED_TRADE_AMT = $F('CRED_TRADE_AMT');
	
	actions.ajaxPostDSA2_1002( 'calGA_Rate' , 
		reqMap ,
		function(resp){
			$('GA_RATE').setValue(resp.ga_rate||'0');
			$('GA_RATE_SHOW').innerHTML = CSRUtil.$fmt(resp.ga_rate, '#,##0.00') + ' %';
			var DataMap = resp.DataMap;
			$('FLEX_MIN_SP').update(CSRUtil.$fmt(DataMap.FLEX_MIN, "#,###"));
			$('FLEX_MAX_SP').update(CSRUtil.$fmt(DataMap.FLEX_MAX, "#,###"));
			$('FLEX_MIN').setValue(DataMap.FLEX_MIN);
			$('FLEX_MAX').setValue(DataMap.FLEX_MAX);
		}
	);
}

function doCalLoanLimitC(){

	var reqMap = {};
	reqMap.APPLY_ID = $F('APPLY_ID');
	reqMap.APPR_APPLY_ID = $F('APPR_APPLY_ID');
	reqMap.AREA_CODE_930318 = $F('AREA_CODE_930318');
	reqMap.CRED_ADD = $F('CRED_ADD')||'0';// 債信等級
	reqMap.GFS_SCORE = $F('GFS_SCORE');// GFS分數
	reqMap.GAGE_USE = ($('GAGE_USE_1').checked) ? '1' : '0';// 擔保品使用狀況
	reqMap.IS_MANSION = ($('IS_MANSION_1').checked) ? '1' : '0';//高價住宅購屋貸款
	reqMap.LOAN_LIMIT_C = $F('LOAN_LIMIT_C');
	reqMap.CRED_ADD_RATE = $('CRED_ADD_RATE').innerHTML;//債信等級調整值
	reqMap.VIP_ADD_RATE = $('VIP_ADD_RATE').innerHTML;//優質客戶
	reqMap.AREA_ADD = $F('AREA_ADD');//區域加成條件
	reqMap.AREA_ADD_RATE = $('AREA_ADD_RATE').innerHTML;//區域加成條件
	reqMap.INVEST_ADD = ($('INVEST_ADD').checked) ? '1' : '0';//投資戶
	reqMap.RENT = $F('RENT');	// 租押金
	reqMap.APPR_AMT = $F('APPR_AMT');	// 鑑估總值
	reqMap.CRED_TRADE_AMT = $F('CRED_TRADE_AMT');

	actions.ajaxPostDSA2_1002( 'calLoanLimitC' , 
		reqMap ,
		function(resp){
			var limit_Map = resp.limit_Map;
			if(limit_Map){
				var LOAN_LIMIT = limit_Map.LOAN_LIMIT||'0';
				$('LOAN_LIMIT_SHOW').update(localeDisplay.formatNumber(LOAN_LIMIT));
				$('LOAN_LIMIT').setValue(LOAN_LIMIT);
				$('ABLE_AMT').setValue(limit_Map.ABLE_AMT||'0');
	
				var LOAN_LIMIT_C = limit_Map.LOAN_LIMIT_C||'0';
				$('LOAN_LIMIT_C_SHOW').update(localeDisplay.formatNumber(LOAN_LIMIT_C));
				$('LOAN_LIMIT_C').setValue(LOAN_LIMIT_C);
				$('LIMIT_AMT').setValue(limit_Map.LIMIT_AMT||'0');
				$('LIMIT_AMT_SHOW').update(localeDisplay.formatNumber((limit_Map.LIMIT_AMT||'0')));
			}
		}
	);
}

function doCalLoanLimit(){

	var reqMap = {};
	reqMap.AREA_CODE_930318 = $F('AREA_CODE_930318');
	reqMap.CRED_ADD = $F('CRED_ADD')||'0';// 債信等級
	reqMap.GFS_SCORE = $F('GFS_SCORE');// GFS分數
	reqMap.GAGE_USE = ($('GAGE_USE_1').checked) ? '1' : '0';// 擔保品使用狀況
	reqMap.IS_MANSION = ($('IS_MANSION_1').checked) ? '1' : '0';//高價住宅購屋貸款
	reqMap.LOAN_LIMIT_C = $F('LOAN_LIMIT_C');
	reqMap.CRED_ADD_RATE = $('CRED_ADD_RATE').innerHTML;//債信等級調整值
	reqMap.VIP_ADD_RATE = $('VIP_ADD_RATE').innerHTML;//優質客戶
	reqMap.AREA_ADD = $F('AREA_ADD');//區域加成條件
	reqMap.AREA_ADD_RATE = $('AREA_ADD_RATE').innerHTML;//區域加成條件
	reqMap.INVEST_ADD = ($('INVEST_ADD').checked) ? '1' : '0';//投資戶
	reqMap.RENT = $F('RENT');	// 租押金
	reqMap.APPR_AMT = $F('APPR_AMT');	// 鑑估總值
	reqMap.TYPE = '2';//計算承作成數
	reqMap.CRED_TRADE_AMT = $F('CRED_TRADE_AMT');
	
	
	actions.ajaxPostDSA2_1002( 'calLoanLimitC' , 
		reqMap ,
		function(resp){
			var limit_Map = resp.limit_Map;
			if(limit_Map){
				var LOAN_LIMIT = limit_Map.LOAN_LIMIT||'0';
				$('LOAN_LIMIT_SHOW').update(localeDisplay.formatNumber(LOAN_LIMIT));
				$('LOAN_LIMIT').setValue(LOAN_LIMIT);
				$('ABLE_AMT').setValue(limit_Map.ABLE_AMT||"0");
			}
		}
	);
}

// 連結到司法院
function doLink(){
	var url = 'http://jirs.judicial.gov.tw/GNNWS/NNWSS001.asp?classFlag=z&Search=y';
	window.open(url, "DSA2_1002", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
}

// 連結到家事事件公告
function doLink1(){
	var url = 'http://domestic.judicial.gov.tw/abbs/wkw/WHD9H01.jsp?classFlag=z&Search=y';
	window.open(url, "DSA2_1002", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
}

//交易憑證
function OpenNewWindow(eviurl) {
	window.open(eviurl,"eDoc","menubar=0,resizable=yes,scrollbars=yes,directories=0,toolbar=0,height=500,width=650");
}

function checkInput(act, msg, isConfirm){
	
	if(parent.form1){
		var APPLY_ID = parent.form1.APPLY_ID.value;
	
		if(APPLY_ID == ''){
			alert(msg);
			return false;
		}
		
		var APPLY_ID_SHOW = $('APPLY_ID_SHOW').innerHTML;
		if(APPLY_ID != APPLY_ID_SHOW){
		 	alert('欲異動的受理編號: ' + APPLY_ID + ' 與原先查詢的 ' + APPLY_ID_SHOW + ' 不同，請重新查詢!');
		 	return false;
		}
	}

	if(isConfirm){
		valid.reset();
		$('IS_CHANGE_HOUSE').className = '';
		$('IS_COPRATION_CNT').className = '';
		$('IS_MANSION_CNT').className = '';
		$('IS_THIRD_CODE_CNT').className = '';
		$('AGREE_FLEX_TYPE_0').className = '';
		$('AGREE_FLEX_AMT').className = '';
		if(act == 'update'){//試算
			$('CRED_NOTE').className = '';
			$('SPEC_CHECK_990625_0').className = '';
			$('IS_CHANGE_HOUSE').className = 'validate-IS_CHANGE_HOUSE';
			$('IS_COPRATION_CNT').className = 'validate-IS_COPRATION_CNT';
			$('IS_MANSION_CNT').className = 'validate-IS_MANSION_CNT';
			$('IS_THIRD_CODE_CNT').className = 'validate-IS_THIRD_CODE_CNT';
			$('AGREE_FLEX_TYPE_0').addClassName('validate-AGREE_FLEX_TYPE'); <%-- [20221227] --%>
			$('AGREE_FLEX_AMT').addClassName('validate-AGREE_FLEX_AMT'); <%-- [20221227] --%>
			$('AGREE_FLEX_AMT').addClassName('validate-AGREE_FLEX_AMT_1000'); <%-- [20221227] --%>
		
		}else if(act == 'confirm'){//簽件
			$('CRED_NOTE').className = 'required';
			$('SPEC_CHECK_990625_0').className = 'validateSPEC_CHECK_990625';	
			
			//3.1.17	「保單平均經過期間是否3年以上」IS_INSU_3YEAR檢核:
			if($('IS_INSU_3YEAR_1').checked && $('IS_INSU_0').checked){
				alert('勾選非保戶不該有保單往來年期,資料輸入錯誤!');
				return;
			}
			//3.1.18	「利率減項原因」利率減項原因IR_ADJ_REASON及利率減項原因說明IR_ADJ_DESC檢核:
			//if($('IS_ADJUST').checked && !($F('IR_ADJ_REASON1')||$F('IR_ADJ_REASON2')||$F('IR_ADJ_REASON3')||$F('IR_ADJ_REASON4')||$F('IR_ADJ_REASON5'))){
		 	//	alert('案件有利率個調,請輸入利率減項原因說明!');
			//	return;
			//}
			if($F('IR_ADJ_REASON5')=='1' && !$F('IR_ADJ_DESC')){
				alert('利率減項原因選擇其他，請輸入說明!');
				return;
			}
			$('IS_CHANGE_HOUSE').className = 'validate-IS_CHANGE_HOUSE';
			$('IS_COPRATION_CNT').className = 'validate-IS_COPRATION_CNT';
			$('IS_MANSION_CNT').className = 'validate-IS_MANSION_CNT';
			$('IS_THIRD_CODE_CNT').className = 'validate-IS_THIRD_CODE_CNT';
			$('AGREE_FLEX_TYPE_0').addClassName('validate-AGREE_FLEX_TYPE'); <%-- [20221227] --%>
			$('AGREE_FLEX_AMT').addClassName('validate-AGREE_FLEX_AMT'); <%-- [20221227] --%>
			$('AGREE_FLEX_AMT').addClassName('validate-AGREE_FLEX_AMT_1000'); <%-- [20221227] --%>
		}
			
		if( !valid.validate() ) {
			return false;
		}
	}
	return true;
}

function getReqMapData(reqMap){
	reqMap.FAST_AGREE = dataMap['FAST_AGREE'];
	reqMap.INSUFREE_CODE = $('INSUFREE_CODE').checked ? '1' : '0';
	reqMap.IS_FIREINSU = $('IS_FIREINSU').checked ? '1' : '0';
	reqMap.INSU_NOTE = $('INSU_NOTE').checked ? '1' : '0';
	reqMap.REMISSION_INT = $('REMISSION_INT').checked ? '1' : '0';
	reqMap.CRED_STATUS1 = $('CRED_STATUS1').checked ? '1' : '0';
	reqMap.CRED_STATUS2 = $('CRED_STATUS2').checked ? '1' : '0';
	reqMap.CRED_STATUS3 = $('CRED_STATUS3').checked ? '1' : '0';
	reqMap.CRED_STATUS9 = $('CRED_STATUS9').checked ? '1' : '0';
	reqMap.CRED_STATUSA = $('CRED_STATUSA').checked ? '1' : '0';
	reqMap.CRED_STATUSB = $('CRED_STATUSB').checked ? '1' : '0';
	reqMap.IR_ADJ_REASON1 = $('IR_ADJ_REASON1').checked ? '1' : '0';
	reqMap.IR_ADJ_REASON2 = $('IR_ADJ_REASON2').checked ? '1' : '0';
	reqMap.IR_ADJ_REASON3 = $('IR_ADJ_REASON3').checked ? '1' : '0';
	reqMap.IR_ADJ_REASON4 = $('IR_ADJ_REASON4').checked ? '1' : '0';
	reqMap.IR_ADJ_REASON5 = $('IR_ADJ_REASON5').checked ? '1' : '0';
	reqMap.INVEST_ADD = $('INVEST_ADD').checked ? '1' : '0';
	
	<%-- [20211217] 新增參數: 不予承作事項, 提高授權事項, 洗錢防制高風險客戶, 一年內重簽件 --%>
	reqMap.AGREE_ITEM_01 = $('AGREE_ITEM_01').checked ? '1' : '0';
	reqMap.AGREE_ITEM_02 = $('AGREE_ITEM_02').checked ? $F('AGREE_ITEM_02_MAP') : '0';
	reqMap.AGREE_ITEM_03 = $('AGREE_ITEM_03').checked ? '1' : '0';
	reqMap.TRANS_CODE_2 = $('TRANS_CODE_2').checked ? '2' : '0';

	reqMap.APPLY_ID=$('APPLY_ID_SHOW').innerHTML;
	if($('GAGE_USE_0').checked){
		reqMap.GAGE_USE = $F('GAGE_USE_0');
	} else if ($('GAGE_USE_1').checked) {
		reqMap.GAGE_USE = $F('GAGE_USE_1');
	}
	
	if($('SPEC_CHECK_990625_0').checked){
		reqMap.SPEC_CHECK_990625 = '0';
		reqMap.IS_CHANGE_HOUSE = '';
	} else if ($('SPEC_CHECK_990625_1').checked) {
		reqMap.SPEC_CHECK_990625 = '1';
		reqMap.IS_CHANGE_HOUSE = $F('IS_CHANGE_HOUSE');
	}

	if($('IS_MANSION_0').checked){
		reqMap.IS_MANSION = '0';
		reqMap.IS_MANSION_CNT = '';
	} else if ($('IS_MANSION_1').checked) {
		reqMap.IS_MANSION = '1';
		reqMap.IS_MANSION_CNT = $F('IS_MANSION_CNT');
	}
	
	if($('IS_COPRATION_0').checked){
		reqMap.IS_COPRATION = '0';
		reqMap.IS_COPRATION_CNT = '';
	} else if ($('IS_COPRATION_1').checked) {
		reqMap.IS_COPRATION = '1';
		reqMap.IS_COPRATION_CNT = $F('IS_COPRATION_CNT');
	}
	
	if($('IS_THIRD_CODE_0').checked){
		reqMap.IS_THIRD_CODE = '0';
		reqMap.IS_THIRD_CODE_CNT = '';
	} else if ($('IS_THIRD_CODE_1').checked) {
		reqMap.IS_THIRD_CODE = '1';
		reqMap.IS_THIRD_CODE_CNT = $F('IS_THIRD_CODE_CNT');
	}
	
	if($('IS_FIX_VIPGRADE_0').checked){
		reqMap.IS_FIX_VIPGRADE = '0';
	} else if ($('IS_FIX_VIPGRADE_1').checked) {
		reqMap.IS_FIX_VIPGRADE = '1';
	}
	
	if($('IS_INSU_0').checked){
		reqMap.IS_INSU = '0';
	} else if ($('IS_INSU_1').checked) {
		reqMap.IS_INSU = '1';
	}
	
	if($('IS_INSU_3YEAR_0').checked){
		reqMap.IS_INSU_3YEAR = '0';
	} else if ($('IS_INSU_3YEAR_1').checked) {
		reqMap.IS_INSU_3YEAR = '1';
	}
	
	reqMap.CASE_TYPE=$F('CASE_TYPE');
	
	// [20221227]
	if($('AGREE_FLEX_TYPE_0').checked){
		reqMap.AGREE_FLEX_TYPE = '0';
		reqMap.AGREE_FLEX_AMT = $F('FLEX_MIN');
	} else if($('AGREE_FLEX_TYPE_1').checked){
		reqMap.AGREE_FLEX_TYPE = '1';
		reqMap.AGREE_FLEX_AMT = $F('FLEX_MAX');
	} else if($('AGREE_FLEX_TYPE_2').checked){
		reqMap.AGREE_FLEX_TYPE = '2';
		reqMap.AGREE_FLEX_AMT = $F('AGREE_FLEX_AMT');
	}
}

//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
function doTrimTextArea (){
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
	if($('CRED_NOTE').value.length>0){
		$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/'/gi, "").replace(/"/gi, "");
		while(true){
			ln0 = $('CRED_NOTE').value.length;
			while(true){
				ln1 = $('CRED_NOTE').value.length;
				if($('CRED_NOTE').value.indexOf('\r\n')>=0){
					//trim掉最後一個\r\n
					$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/\r\n$/g, "");
					if(ln1 == $('CRED_NOTE').value.length){
						break;	
					}
				}else{
					break;
				}
			}
			while(true){
				ln2 = $('CRED_NOTE').value.length;
				if($('CRED_NOTE').value.indexOf(' ')>=0){
					$('CRED_NOTE').value = $('CRED_NOTE').value.replace(/ $/g, "");
					if(ln2 == $('CRED_NOTE').value.length){
						break;	
					}
				}else{
					break;
				}
			}

			if(ln0 == $('CRED_NOTE').value.length){
				break;	
			}
		}
	}
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
}

//批示歷程超連結(顯示/隱藏div)
function doShowHistory(){
	if($('div_I').style.display != 'none'){
		$('div_I').style.display = 'none';
	}else{
		$('div_I').style.display = 'block';
	}
}

function doShowFileList(){
	if($('div_J').style.display != 'none'){
		$('div_J').style.display = 'none';
	}else{
		$('div_J').style.display = 'block';
	}
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	    <tr id="table_btn_tr">
			<td class="tbYellow2" colspan="6" align="center" width="12%">
				<input id="btn_update" name="btn_update" type="button" class="button" value="試算">						
				<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="簽件">
				<input id="btn_cancel" name="btn_cancel" type="button" class="button" value="取消">
				<input id="btn_DSA21007" type="button" class="button" value="批覆書">
				<input id="btn_DSA21006" type="button" class="button" value="不動產明細">
                <input id="btn_DSA21008" type="button" class="button" value="鑑估表">
                <input type="button" id="btn_eland" value="電子謄本查詢" class="button" style="display:none">
			    <input type="button" id="btn_elandImage" value="電子謄本影像" class="button" style="display:none">
			</td>
		</tr>															
	</table>
	<form name="form1" id="form1" method="post" action="">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<input type='hidden' id='APPLY_ID' name='APPLY_ID'>
			<input type='hidden' id='IS_FAST_AGREE' name='IS_FAST_AGREE'>
			<input type='hidden' id='BORROW_NAME' name='BORROW_NAME'>
			<input type='hidden' id='APPLY_PROCESS_NM' name='APPLY_PROCESS_NM'>
			<input type='hidden' id='APPLY_PROCESS' name='APPLY_PROCESS'>
			<input type='hidden' id='AGREE_PROCESS_NM' name='AGREE_PROCESS_NM'>							
			<input type='hidden' id='AGREE_LEVEL_NM' name='AGREE_LEVEL_NM'>							
			<input type='hidden' id='LAND_SPACE' name='LAND_SPACE'>
			<input type='hidden' id='BUILD_SPACE' name='BUILD_SPACE'>
			<input type='hidden' id='FINISH_DATE' name='FINISH_DATE'>
			<input type='hidden' id='APPR_AMT' name='APPR_AMT'>
			<input type='hidden' id='MAIN_USE' name='MAIN_USE'>
			<input type='hidden' id='MAIN_USE_NM' name='MAIN_USE_NM'>
			<input type='hidden' id='LOAN_AMT' name='LOAN_AMT'>
			<input type='hidden' id='LOAN_AMT_M' name='LOAN_AMT_M'>				
			<input type='hidden' id='LIMIT_AMT' name='LIMIT_AMT'>
			<input type='hidden' id='GA_RATE' name='GA_RATE'>
			<input type='hidden' id='GAGE_AMT' name='GAGE_AMT'>
			<input type='hidden' id='GAGE_AMT_M' name='GAGE_AMT_M'>
			<input type='hidden' id='VIP_GRADE' name='VIP_GRADE'>
			<input type='hidden' id='VIP_GRADE_NM' name='VIP_GRADE_NM'>
			<input type='hidden' id='LOAN_LIMIT_C' name='LOAN_LIMIT_C'>
			<input type='hidden' id='AREA_CODE_930318' name='AREA_CODE_930318'>
			<input type='hidden' id='FIREINSU_YY' name='FIREINSU_YY'>
			<input type='hidden' id='FIREINSU_MM' name='FIREINSU_MM'>
			<input type='hidden' id='INTEREST_C' name='INTEREST_C'>									
			<input type='hidden' id='INTEREST_C_M' name='INTEREST_C_M'>
			<input type='hidden' id='ACCOUNT_STATUS' name='ACCOUNT_STATUS'>
			<input type='hidden' id='INPUT_NAME' name='INPUT_NAME'>
			<input type='hidden' id='INPUT_DATE' name='INPUT_DATE'>
			<input type='hidden' id='CRED_TEL' name='CRED_TEL'>
			<input type='hidden' id='ANNOU_VALUE' name='ANNOU_VALUE'>
			<input type='hidden' id='TRANS_VALUE' name='TRANS_VALUE'>
			<input type='hidden' id='TRAN_VALUE' name='TRAN_VALUE'>			
			<input type='hidden' id='FLOOR' name='FLOOR'>
			<input type='hidden' id='BUILD_AGE' name='BUILD_AGE'>
			<input type='hidden' id='MATERIAL' name='MATERIAL'>
			<input type='hidden' id='MATERIAL_NM' name='MATERIAL_NM'>
			<input type='hidden' id='USE_STATUS' name='USE_STATUS'>
			<input type='hidden' id='USE_STATUS_NM' name='USE_STATUS_NM'>
			<input type='hidden' id='BUILD_TYPE' name='BUILD_TYPE'>
			<input type='hidden' id='BUILD_TYPE_NM' name='BUILD_TYPE_NM'>
			<input type='hidden' id='RENT' name='RENT'>
			<input type='hidden' id='FIREINSU_PRICE' name='FIREINSU_PRICE'>
			<input type='hidden' id='LAND_TAX' name='LAND_TAX'>
			<input type='hidden' id='DEPRECIATION' name='DEPRECIATION' >
			<input type='hidden' id='REALVALUE_RATE' name='REALVALUE_RATE'>
			<input type='hidden' id='APPR_REALVALUE' name='APPR_REALVALUE'>
			<input type='hidden' id='LOAN_LIMIT' name='LOAN_LIMIT'>
			<input type='hidden' id='PRE_SET_AMT' name='PRE_SET_AMT'>
			<input type='hidden' id='SEPARATE_AMT' name='SEPARATE_AMT'>
			<input type='hidden' id='FIREINSU_CAMT' name='FIREINSU_CAMT'>
			<input type='hidden' id='LIMIT_CAMT' name='LIMIT_CAMT' >
			<input type='hidden' id='PREFER_TYPE' name='PREFER_TYPE'>
			<input type='hidden' id='LOAN_KIND' name='LOAN_KIND'>
			<input type='hidden' id='AGREE_PROCESS' name='AGREE_PROCESS'>
			<input type='hidden' id='IS_AGREE' name='IS_AGREE'>
			<input type='hidden' id='CRED_ADD' name='CRED_ADD'> 
			<input type='hidden' id='GFS_SCORE' name='GFS_SCORE'>
			<input type='hidden' id='ABLE_AMT' name='ABLE_AMT'>
			<input type='hidden' id='REJECT_DATA' name='REJECT_DATA'>
			<input type='hidden' id='SCRIBE_TYPE' name='SCRIBE_TYPE' value='5'>
			<input type='hidden' id='LOGIN_ID' name='LOGIN_ID'>
			<input type='hidden' id='INPUT_ID' name='INPUT_ID'>
			<input type='hidden' id='APPLY_DATE' name='APPLY_DATE'>
			<input type='hidden' id='SEND_DATE' name='SEND_DATE'>
			<input type='hidden' id='BORROW_ID' name='BORROW_ID'>
			<input type='hidden' id='IS_SEPARATE' name='IS_SEPARATE'>
			<input type='hidden' id='TEL_APPLY_ID' name='TEL_APPLY_ID'>
			<input type='hidden' id='DEBT_APPLY_ID' name='DEBT_APPLY_ID'>
			<input type='hidden' id='IS_A130' name='IS_A130'>
			<input type='hidden' id='BASE_RATE' name='BASE_RATE'>
			<input type='hidden' id='TYPE' name='TYPE'>
			<input type='hidden' id='UpdateSuccess' name='UpdateSuccess' value='${UpdateSuccess}'>
			<input type='hidden' id='POLICY_YEAR' name='POLICY_YEAR' >
			<input type='hidden' id='APPR_TRADE_AMT' name='APPR_TRADE_AMT'>
			<input type='hidden' id='CASE_TYPE' name='CASE_TYPE'>
			<input type='hidden' id='AGENT_DEPT_IS_720' name='AGENT_DEPT_IS_720'>
			
			<tr>
				<td class="tbYellow" >
					受理編號
				</td>
				<td class="tbYellow2" colspan="3">
					<span id="APPLY_ID_SHOW" ></span>&nbsp;&nbsp;
					<font color="red"><span id="IS_FAST_AGREE_SHOW" ></span></font>
				</td>
				<td class="tbYellow" >
					借款人姓名
				</td>
				<td class="tbYellow2">
					<span id="BORROW_NAME_SHOW" ></span>&nbsp;&nbsp;<span id="LEVEL_CH_NM"></span>
					
					<img id="img_getfile" class="hasATApply" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="buttons.linkToDSA21018()">
					<span id="hasATApply_s" class="hasATApply">三個月內新契約資訊</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="16%">
					受理進度
				</td>
				<td class="tbYellow2" width="17%" id="APPLY_PROCESS_NM_SHOW">
				</td>
				<td class="tbYellow" width="16%">
					批示進度
				</td>
				<td class="tbYellow2" width="17%" id="AGREE_PROCESS_NM_SHOW">
				</td>
				<td class="tbYellow" width="16%">
					核定層級
				</td>
				<td class="tbYellow2" width="17%" id="AGREE_LEVEL_NM_SHOW">
				</td>
			</tr>
			<tr>
				<td class="tbYellow0" colspan="6">&nbsp;</td>
			</tr>			
			<tr>
				<td class="tbYellow">
					地坪
				</td>
				<td class="tbYellow2">
					<span id="LAND_SPACE_SHOW" ></span>
				</td>								
				<td class="tbYellow">
					建坪
				</td>
				<td class="tbYellow2">
					<span id="BUILD_SPACE_SHOW" ></span>
				</td>	
				<td class="tbYellow">
					整批分戶件
				</td>
				<td class="tbYellow2">
					<input id="INSU_PRANK7_0" name="INSU_PRANK7" fieldName="整批分戶件" type="radio" value="0" checked><span>否</span>
					<input id="INSU_PRANK7_1" name="INSU_PRANK7" fieldName="整批分戶件" type="radio" value="1"><span>是</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					平均單價
				</td>
				<td class="tbYellow2"  >
					<input type="text" class="textBox2 required" size="6" id="AVG_PRICE" name="AVG_PRICE" > 萬
				</td>	
				<td class="tbYellow" >
					建築完成日
				</td>
				<td class="tbYellow2" >
					<span id="FINISH_DATE_SHOW" ></span> 
				</td>	
				<td class="tbYellow">
					帳管費
				</td>
				<td class="tbYellow2">
					<input id="IS_EXPENSE" name="IS_EXPENSE" type="checkbox" value="1">
					<input type="text" class="textBox2 validate-positive validate-number0" size="15" maxlength="9" value="" id="EXPENSE_AMT" name="EXPENSE_AMT" disabled > 元
				</td>								
			</tr>	
			<tr>
				<td class="tbYellow" >
					主要用途
				</td>
				<td class="tbYellow2"  >
					<span id="MAIN_USE_NM_SHOW" ></span>
				</td>	
				<td class="tbYellow" >
					實際用途
				</td>
				<td class="tbYellow2" >
					<select id="REAL_USE" name="REAL_USE" >
						<c:forEach var="map" items="${RealUseMap}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>	
				<td class="tbYellow">
					參照鑑價報告
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2 validateAPPR_APPLY_ID" size="15" maxlength="11" id="APPR_APPLY_ID" name="APPR_APPLY_ID" >
				</td>								
			</tr>			
			<tr>
				<td class="tbYellow" >
					一般型擬准金額
				</td>
				<td class="tbYellow2" >
					<input type="text" class="textBox2 required" size="15" id="AGREE_AMT" name="AGREE_AMT" > 萬
				</td>	
				<td class="tbYellow" >
					理財型擬准金額
				</td>
				<td class="tbYellow2" >
					<input type="text" class="textBox2 required" size="15" id="AGREE_AMT_M" name="AGREE_AMT_M" > 萬
				</td>
				<td class="tbYellow" >
					鑑估總值
				</td>
				<td class="tbYellow2"  >
					<span id="APPR_AMT_SHOW" ></span>
				</td>	
			</tr>		
			<tr>
				<td class="tbYellow" rowSpan="3">
					買契價格
				</td>
				<td class="tbYellow2" rowSpan="3">
					<input type="text" class="textBox2" size="12" id="CRED_TRADE_AMT" name="CRED_TRADE_AMT" maxlength="11"> 萬
				</td>	
				<td class="tbYellow" rowSpan="2">
					放款值
				</td>
				<td class="tbYellow2" rowSpan="2">
					<span id="LIMIT_AMT_SHOW" ></span>元
				</td>
				<td class="tbYellow" >
					業績Ａ值
				</td>
				<td class="tbYellow2"  >
					<select name="A_VALUE" id="A_VALUE">
						<c:forEach var="map" items="${AValueMAP}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"> <%-- [20221227] --%>
					每月約定還本擬准金額
				</td>
				<td class="tbYellow2">
					<input id="IS_FLEX" name="IS_FLEX" fieldName="是否本金彈性還" type="hidden" value="">
					<input id="FLEX_MIN" name="FLEX_MIN" fieldName="下限金額" type="hidden" value="${FLEX_MIN}">
					<input id="AGREE_FLEX_TYPE_0" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="0">
					<span>下限金額</span><span id="FLEX_MIN_SP" datatype="number" intLength="11"></span><span>元</span>
					<br>
					<input id="AGREE_FLEX_TYPE_2" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="2">-自行約定金額
					<input id="AGREE_FLEX_AMT" name="AGREE_FLEX_AMT" fieldName="自行約定金額" type="text" class="textBox2" datatype="number" intLength="11" pattern="#,###" size="10" maxlength="15" value=""><span>元</span>
					<br>
					<input id="FLEX_MAX" name="FLEX_MAX" fieldName="上限金額" type="hidden" value="${FLEX_MAX}">
					<input id="AGREE_FLEX_TYPE_1" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="1">
					<span>上限金額</span><span id="FLEX_MAX_SP" datatype="number" intLength="11"></span><span>元</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					貸放成數
				</td>
				<td class="tbYellow2" >
					<span id="GA_RATE_SHOW" ></span>
				</td>
				<td class="tbYellow" >
					火險年期
				</td>
				<td class="tbYellow2"  >
					<span id="FIREINSU_YY_SHOW" ></span>&nbsp;年<span id="FIREINSU_MM_SHOW" ></span>&nbsp;月
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					設定金額
				</td>
				<td class="tbYellow2"  >
					<input type="text" class="textBox2 required" size="15" id="SET_AMT" name="SET_AMT" > 元
				</td>	
				<td class="tbYellow" >
					火險保額
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2 required" size="12" id="FIREINSU_AMT" name="FIREINSU_AMT" > 萬
				</td>
				<td class="tbYellow">
					已保火險金額(有效)
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" id="FIREINSU_AMT_VALID" name="FIREINSU_AMT_VALID" fieldName="已保火險金額(有效)" intLength="7" decLength="2" size="10" maxlength="13" value=""><span>萬</span>
				</td>
				
			</tr>
			<tr>
				<td class="tbYellow" >
					贈送火險及地震險
				</td>
				<td class="tbYellow2">
					<input type="checkbox" id="INSUFREE_CODE" name="INSUFREE_CODE" > (勾選)
				</td>
				<td class="tbYellow" >
					是否投保火險
				</td>
				<td class="tbYellow2">
					<input type="checkbox" id="IS_FIREINSU" name="IS_FIREINSU" > (勾選)
				</td>
				<td class="tbYellow">
					承作成數
				</td>
				<td class="tbYellow2">
					<span id="LOAN_LIMIT_SHOW" datatype="number" intLength="3" decLength="2"></span>&nbsp;<span>%</span><br/><%-- 承作成數 --%>
					<span>1.債信指標調整：</span><span id="CRED_ADD_RATE" name="CRED_ADD_RATE"></span><br/>
					<span>2.優質客戶加成</span><input id="VIP_ADD" name="VIP_ADD" fieldName="優質客戶加成" type="hidden" value="0"><span>：</span><span id="VIP_ADD_RATE"></span><br/>
					<span>3.區域加成條件</span><span>：</span><span id="AREA_ADD_RATE" name="AREA_ADD_RATE"></span><br/>
					<select id="AREA_ADD" name="AREA_ADD" style="width:120px" fieldName="區域加成條件"></select><br/>
					<span>4.投資戶</span><input id="INVEST_ADD" name="INVEST_ADD" fieldName="投資戶" type="checkbox" value="1"><span>：</span><span id="INVEST_ADD_RATE"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					適用保戶優惠
				</td>
				<td class="tbYellow2">
					<input type="checkbox" id="INSU_NOTE" name="INSU_NOTE" > (勾選)
				</td>
				<td class="tbYellow" >
					擔已貸金額
				</td>
				<td class="tbYellow2"  >
					<span id="GAGE_AMT_SHOW" ></span>
				</td>
				
				<td class="tbYellow2" rowspan="4" colspan="2">
					&nbsp;利率：<br/>
					&nbsp;一般型表定利率&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id="INTEREST_C_SHOW" ></span><br/>
					&nbsp;理財型表定利率&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id="INTEREST_C_M_SHOW" ></span><br/>
					&nbsp;(一般型調整後利率) <input type="text" class="textBox2 required" datatype="number" size="15" id="INTEREST" name="INTEREST" readonly> %<br/>
					&nbsp;(理財型調整後利率) <input type="text" class="textBox2 required" datatype="number" size="15" id="INTEREST_M" name="INTEREST_M" readonly> %<br/>
					&nbsp;理財型帳號設定&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span id="ACCOUNT_STATUS_SHOW" ></span>
					
				<table id="table_A" width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbYellow0" colspan="15">一般型利率個調
							<input id="IS_ADJUST"  type="checkbox" value="">
						</td>
					</tr>
					<tr id="table_A_tr1">
						<td class="tbYellow" width="2%" align='center'>
							選取
						</td>
						<td class="tbYellow" colspan="15" width="15%" align='center'>
							內容
						</td>
					</tr>
					
					
					<tbody id="grid_body">
					</tbody>
					<tr id="table_A_tr2">
					    <td class="tbYellow2" width="5%" colspan="16" align="center" >
							<input id="BTN_INSERT1" type="button" value="新增" class="button"> 
						    <input id="BTN_DELETE1" type="button" value="刪除" class="button">
						</td>
					</tr>
				</table>
				<table id="table_A_Fin" width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbBlue" colspan="15">
							理財型利率個調
							<input id="IS_ADJUST_M"  type="checkbox" value="">
						</td>
					</tr>
					<tbody id="grid_body_Fin">
					</tbody>
				</table>					
				<table id="table_B" width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbYellow0" colspan="15">
							提前清償違約金
							<input id="IS_RENEGE"  type="checkbox" value="">
						</td>
					</tr>
					<tr id="table_B_tr1">
						<td class="tbYellow" width="2%" align='center'>
							選取
						</td>
						<td class="tbYellow" colspan="15" width="15%" align='center'>
							內容
						</td>
					</tr>
					
					
					<tbody id="grid_body1">
					</tbody>
					
					<tr id="table_B_tr2">
					    <td class="tbYellow2" width="5%" colspan="16" align="center" >
							<input id="BTN_INSERT2" type="button" value="新增" class="button"> 
						    <input id="BTN_DELETE2" type="button" value="刪除" class="button">
						</td>
						
					</tr>
				</table>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					已生效理財型額度
				</td>
				<td class="tbYellow2" >
					<span id="GAGE_AMT_M_SHOW" ></span>
				</td>
				<td class="tbYellow" >
					優質等級
				</td>
				<td class="tbYellow2" >
					<span id="VIP_GRADE_NM_SHOW" ></span>
				</td>
			</tr>	
			<tr>
				<td class="tbYellow" >
					是否首月免息
				</td>
				<td class="tbYellow2">
					<input type="checkbox" id="REMISSION_INT" name="REMISSION_INT" > (勾選)
				</td>
				<td class="tbYellow" >
					區域放款率<br/>
				        (生活圈)
				</td>
				<td class="tbYellow2"  >
					<span id="LOAN_LIMIT_C_SHOW" ></span>%
					<font color="red"><span id="AREA_CODE_930318_SHOW" ></span></font> <br/>
					<c:forEach var="map" items="${GageUseMAP}" varStatus="status">
						<input type='radio' id='GAGE_USE_${status.index}' name='GAGE_USE' class='validateGAGE_USE' value='${map.key}'>${map.value}
					</c:forEach>
					<br/><span id="SUBMKT_NAME"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">
				央行限制─法人購住
			    </td>
			    <td class="tbYellow2">
			        <input type='radio' id='IS_COPRATION_0' name='IS_COPRATION' >否
					<input type='radio' id='IS_COPRATION_1' name='IS_COPRATION' >是
					&nbsp;
					<select name="IS_COPRATION_CNT" id="IS_COPRATION_CNT">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${IsCoprationCntMAP}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
			    </td>
				<td class="tbYellow" >清償理財型帳號</td>
				<td class="tbYellow2" >	
				<input type="text" class="textBox2 validateMM_ID" size="15" maxlength="10" id="MM_ID" name="MM_ID" >
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					央行限制─高價住宅
				</td>
				<td class="tbYellow2" >
					<input type='radio' id='IS_MANSION_0' name='IS_MANSION' class='validateIS_MANSION' checked>否
					<input type='radio' id='IS_MANSION_1' name='IS_MANSION' >是
					&nbsp;
					<select name="IS_MANSION_CNT" id="IS_MANSION_CNT">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${IsMansionCntMAP}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>			
				<td class="tbYellow" >
					是否為保戶
				</td>
				<td class="tbYellow2" >
					<input type='radio' id='IS_INSU_0' name='IS_INSU' class='validateIS_INSU' >否
					<input type='radio' id='IS_INSU_1' name='IS_INSU' >是
				</td>
				<td class="tbYellow" >
				          保單平均3年以上
				</td>
				<td class="tbYellow2">
				<input id="IS_INSU_3YEAR_0" name="IS_INSU_3YEAR" fieldName="保單平均3年以上" type="radio" value="0"><span>否</span>
				<input id="IS_INSU_3YEAR_1" name="IS_INSU_3YEAR" fieldName="保單平均3年以上" type="radio" value="1"><span>是</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					央行限制─購置特定或全國地區
				</td>
				<td class="tbYellow2" >
					<input type='radio' id='SPEC_CHECK_990625_0' name='SPEC_CHECK_990625' class='validateSPEC_CHECK_990625' checked>否
					<input type='radio' id='SPEC_CHECK_990625_1' name='SPEC_CHECK_990625' >是
					&nbsp;
					<select name="IS_CHANGE_HOUSE" id="IS_CHANGE_HOUSE">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${IsChangeHouseMAP}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" >
					保單可貸金額
				</td>
				<td class="tbYellow2" >
					<input type="text" class="textBox2 required" size="12" id="LOAN_ABLE" name="LOAN_ABLE" > 萬
				</td>
				<td class="tbYellow" >
					作業日期
				</td>
				<td class="tbYellow2">
					<span id="INPUT_DATE_SHOW" ></span> 
				</td>
			</tr>
			<tr>
				<td class="tbYellow">
				         央行限制─購置第3戶
			    </td>
			    <td class="tbYellow2">
			        <input type='radio' id='IS_THIRD_CODE_0' name='IS_THIRD_CODE' checked>否
					<input type='radio' id='IS_THIRD_CODE_1' name='IS_THIRD_CODE' >是
					&nbsp;
					<select name="IS_THIRD_CODE_CNT" id="IS_THIRD_CODE_CNT">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${IsThirdCodeCntMAP}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
			    </td>
			    <td class="tbYellow" >
					保單已貸金額
				</td>
				<td class="tbYellow2">	
					<input type="text" class="textBox2 required" size="12" id="LOAN_REMAIN" name="LOAN_REMAIN" > 萬
				</td>				
				<td class="tbYellow" >
					徵信人員
				</td>
				<td class="tbYellow2"  >
					<span id="CRED_SHOW" ></span>
				</td>	
			</tr>
			<tr>
				<td class="tbYellow">
				        貸款期間<br/>全期不調整客戶等級
			    </td>
			    <td class="tbYellow2">
			        <input type='radio' id='IS_FIX_VIPGRADE_0' name='IS_FIX_VIPGRADE' class='validateIS_FIX_VIPGRADE' checked>否
					<input type='radio' id='IS_FIX_VIPGRADE_1' name='IS_FIX_VIPGRADE' >是
			    </td>				
				<td class="tbYellow" >
					要保人年繳化保費
				</td>
				<td class="tbYellow2">	
					<input type="text" class="textBox2 required" size="12" id="TOTAL_PREMIUM" name="TOTAL_PREMIUM" > 萬
				</td>
			    <td class="tbYellow"> 
					利率減項原因
				</td>
				<td class="tbYellow2" >
					<input id="IR_ADJ_REASON1" name="IR_ADJ_REASON1" type="checkbox" value="1"> 經營策略${IR_ADJ_REASON1RATE}<br/>
					<input id="IR_ADJ_REASON2" name="IR_ADJ_REASON2" type="checkbox" value="1"> 客戶貢獻度${IR_ADJ_REASON2RATE}<br/>
					<input id="IR_ADJ_REASON3" name="IR_ADJ_REASON3" type="checkbox" value="1"> 償債能力${IR_ADJ_REASON3RATE}<br/>
					<input id="IR_ADJ_REASON4" name="IR_ADJ_REASON4" type="checkbox" value="1"> 職業收入${IR_ADJ_REASON4RATE}<br/>
					<input id="IR_ADJ_REASON5" name="IR_ADJ_REASON5" type="checkbox" value="1"> 其他${IR_ADJ_REASON5RATE}
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="2">
					&nbsp;徵信狀況：<br/>									
					<input type='checkBox' id='CRED_STATUS1' name='CRED_STATUS1' > 繳息正常<br/>
					<input type='checkBox' id='CRED_STATUS2' name='CRED_STATUS2' > 支存正常<br/>
					<input type='checkBox' id='CRED_STATUS3' name='CRED_STATUS3' > 聯徵正常<br/>
					<input type='checkBox' id='CRED_STATUS9' name='CRED_STATUS9' > 符合利害關係人授信作業規定<br/>
					<input type='checkBox' id='CRED_STATUSA' name='CRED_STATUSA' > 符合保險業同一關係人,同一關係企業授信規定<br/>
					<input type='checkBox' id='CRED_STATUSB' name='CRED_STATUSB' disabled> 監護及輔助宣告查詢正常
					&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onClick="doLink()">連結到司法院</a>
					&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onClick="doLink1()">連結到家事事件公告</a>
				</td>
				<td class="tbYellow2" colspan="2"> &nbsp;徵信說明：<br/>
					<textarea class="required" onblur="this.value = this.value.slice(0, 1000)" id="CRED_NOTE" name="CRED_NOTE" fieldName="徵信說明" wrap="hard" cols="30" rows="9">${CRED_NOTE}</textarea>
				</td>
				<td class="tbYellow2" colspan="2"> 減項原因說明<br/>
					<div style="float: left">
						<textarea id="IR_ADJ_DESC" name="IR_ADJ_DESC" fieldName="減項原因說明" rows="9" cols="25"></textarea>
					</div>
					<span>呈核層級事項:</span><br/><%-- [20211217] 新增呈核層級事項區塊 --%>
					<input id="AGREE_ITEM_01" name="AGREE_ITEM_01" title="不予承作事項" type="checkbox"><span>不予承作事項</span><br/>
					<input id="AGREE_ITEM_02" name="AGREE_ITEM_02" title="提高授權事項" type="checkbox"><span>提高授權事項</span>
					<select id="AGREE_ITEM_02_MAP" name="AGREE_ITEM_02_MAP" title="提高授權事項選單">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${AgreeItem02Map}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select><br/>
					<input id="AGREE_ITEM_03" name="AGREE_ITEM_03" title="洗錢防制高風險客戶" type="checkbox"><span>洗錢防制高風險客戶</span><br/>
					<input id="TRANS_CODE_2" name="TRANS_CODE_2" title="一年內重簽件" type="checkbox"><span>一年內重簽件</span><br/>
					
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">
					<a href="#A_div_I" onClick="doShowHistory()" name="A_div_I">＊批示歷程</a>
					<div id="div_I" style="overflow:auto; display:none;">
						<span id="AGREE_HISTORY"></span>
					</div>
				</td>
			</tr>	
			<tr>
				<td class="tbYellow2" colspan="6">
					<a href="#A_div_J" onClick="doShowFileList()" name="A_div_J">＊取消核貸批覆書</a>
					<div id="div_J" style="display:none;">						
						<table id="grid" class="grid" width="100%"></table>						
					</div>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2" colspan="6">
				<div id="div_A" style="display:none;">	
				【作業說明】：<br>
				　符合快速審核案件條件（得免重新鑑價）：<br>
				　　1.鑑價報告覆核日需為109/12/29(含)以後，送件日前5年內曾有貸放紀錄之增貸件。<br>
				　　2.繳息正常(借款人於公司貸款近一年繳息1次以上超過30天或3次超過15天）。<br>
				　　3.借款人GFS分數達750分(含)以上。<br>
				　　4.借款人於本公司累貸金額≦新台幣5000萬。<br>
				　　5.擔保品位A、B、C、D、E區5年內增貸件，貸款成數符合以下條件之一：<br>
				　  　  (1)座落A、B、C、D、E區都市計畫區住宅區/商業區，貸放成數 ≦ 區域放款率。<br>
				　  　  (2)座落A、B、C、D、E區都市計畫區非住宅區/商業區，貸放成數 ≦ 55%。<br>
				　  　  (3)座落A、B、C區非都市計畫區，貸放成數 ≦ 55%。<br>
				</div>
				<div id="div_B" style="display:none;">	
				【作業說明】：<br>
				　1.其他借新還舊件得免重新鑑價。<br>
				   &nbsp;&nbsp;&nbsp;&nbsp;2.一般型擬准金額需檢核原額度+10萬元。<br>
				</div>
				</td>
			</tr>		
	</table>
	</form>
	<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td align="center" colspan="6">
					<span id="blockF"></span>
				</td>
			</tr>
	</table>
</body>
</html>