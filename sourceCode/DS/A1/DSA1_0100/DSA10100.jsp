<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：GCJ00101
功能：借款申請輸入
作者： 
完成： 
 
[20191213] : 修改件
             申請書190829001411-法金專案(受理)：新增法金件區域
[20200923] 問題單20200330-0083：增加售屋者ID檢核（僅能輸入10碼半形英數）  
[20220309] 修改件：申請書220221003565-調整聯徵授信餘額月報資料檔案格式(代號:B201):增加綠色授信、永續績效連結欄位

[20220714]修改件
 配合行動房貸APP調整及自動徵審專案，增加系統欄位及資料寫入規則。
郭曉慧

[20221121]
[申請書:221102005585]行動房貸送件年齡與資料保存時間調整
高強禾
[20240326] 修改件 陳勁谷 [申請書240201007793]新增本金彈性還還款方式_貸後變更
[20241107][申請書:]新增社會責任授信註記欄位
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<%-- [20190626] 增加羅馬拼音欄位+調整部分欄位順序 --%>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var defaultMap = {};
var SPEC_AREA_List = {};
function initApp(){
	$('tableA').show();
	$('tableB').show();
	
	PageUI.createPageWithAllBodySubElement("DSA10100" , "受理作業" , "借款申請輸入", 1, '${param.titleNotDisplay}' == 'Y');
	
	initParameter();
	
	cleanMsgBoard();
	
	displayMessage();
	
	buttonAuth();
	
	new UI().init();
		
	PageUI.resize(true);

}

function initParameter(){
	<c:forEach var="map" items="${defaultMap}">
	defaultMap["${map.key}"] = "${map.value}";
	</c:forEach>
	defaultMap["APPLY_DATE"] = Date.toInputROC(defaultMap["APPLY_DATE"] , "/" );
	$('APPLY_DATE').innerHTML = defaultMap["APPLY_DATE"];

	<c:forEach var="map" items="${SPEC_AREA_List}">
	SPEC_AREA_List["${map.key}"] = "${map.value}";
	</c:forEach>
}

function buttonAuth(){
	var authButtons = {
		B0003:"Btn_add", <%--新增 --%>
		B0004:"Btn_update", <%--修改 --%>	
		B0005:"Btn_delete", <%--刪除 --%>	
		B0042:"Btn_imageChange", <%--影像置換-變更 --%>
		B0043:"Btn_addLoan", <%--快速增貸-變更 --%>
		B0044:"Btn_linkImage", <%--影像連結 --%>
		B0234:"Btn_reMakeReport",  <%--申請書置換 --%>
		B0254:"Btn_linkImageScan"	<%--影像掃描--%>
	};
	
	<dz:grantButtons FUNC_ID="DSA10100" ignored="false"/>	
}



//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  
function UI(){
	var result;
	var txBean = '/DSA1_0100/';
	var validForAdd;
	var validForUpdate;
	var validForQueryForNewLoan;
	var validForAPPLY_ID;
	var valid1;
	var isNewQuery;
	var address1;
	var address2;
	var isCORP_DEPT = '${isCORP_DEPT}';/* [20191213] */
	var AGENT_DEPT;
	
	var validfunction = {
		idCheck1 : function( value ){
			if( value != "" ){
				return validation.checkID(value);
				//return idCheck1( value );	//一般人
			}
			return true;
		},
		hasHalfType : function(v){
			return ! validation.hasHalfType( v );
		},
		validInteger : function(v){
			if( v ){
				return /^\d+$/.test(v);
			}
			return true;
		},
		validAPPLY_ID_Q: function(v, minlength){
			return v.length >= minlength && (/^[a-zA-Z0-9@]+$/.test(v));
		}
	};
	
	//--欄位檢核
	function initValidation() {
		Validation.addAllThese([
			['validate-MM_ACCOUNT', '理財連結帳號必需為12或16碼.', function(value) {
				if( value != "" && value.length != 12 && value.length != 16  ){
					return false;
				}
				return true;
			}],
			['validate-BORROW_ID1', '借款人身份證號有誤，請檢查後重新輸入!', function(value) {
				if( value.length==10 ){
					return idCheck1( value );	//一般人
				}else if(value.length!=8){
				    return false
				}
				return true;
			}],
			['validate-BORROW_ID2', '借款人統一編號有誤，請檢查後重新輸入!', function(value) {
				if(value.length==8 ){
					return iscmpid( value );	//法人
				}
				return true;
			}],
			['validate-AGENT1_ID', '第二經手人身分證字號有誤，請重新輸入!', function(value) {
				var ALWC_RATE = $('ALWC_RATE').value;
				if( ALWC_RATE != 100 ){
					return idCheck1(value);
				}
				return true;
			}],
			['validate-COUPLE_ID1', '請輸入配偶或負責人ID!', function(value) {
				if( $F('COUPLE_NAME') != "" ){
					return value != "";
				}
				return true;
			}],
			['validate-COUPLE_ID2', '配偶或負責人身份證號有誤，請檢查後重新輸入!', validfunction.idCheck1 ],
			['validate-COUPLE_NAME', '請輸入配偶或負責人姓名!', function(value) {
				if( $F('COUPLE_ID') != "" ){
					return value != "";
				}
				return true;
			}],
			['validate-MOBILE', '行動電話號碼錯誤!', function(value) {
				if( value != "" ){
					return /[0-9]{10}/.test(value);
				}
				return true;
			}],
			//20231016 問題單20230419-0175：配合產險卡控，判斷連絡電話有值要檢核連絡電話區碼 & 預防市話被填入手機，卡控市話最長輸入8碼
			['validate-TEL_AREA', '', function(area, num) {
				return !(num && Validation.get('IsEmpty').test(area));
			}],
			['validate-TEL_NUM', '電話格式有誤，請確認是否為市話號碼(不含區碼最長8碼)', function(num) {
				if(num && num.length>8){
					return false;
				}
				return true;
			}],
			//['validate-COUPLE_BIRTH', '配偶生日錯誤!', function(value) {
			//	if( $F('COUPLE_ID') != '' || $F('COUPLE_NAME') != '' ){ 
			//		return isROCdate(value,false);
			//	}
			//	return true;
			//}],
			['validate-YearAndMonth', '購買年月錯誤!', function(value) {
				if( value != "" ){
					return isROCdate(value + "01",false);
				}
				return true;
			}],
			['validate-GAGE_ADDR', '擔保種類為房地產、土地、國外不動產需輸入擔保品資料', function(value) {
				if(( $F('GAGE_TYPE') == '1' || $F('GAGE_TYPE') == '6' || $F('GAGE_TYPE') == '3') && value == '' ){
					return false;
				}
				return true;
			}],
			['validate-FIX_YY', '還款方式選擇定期,定期期數需大於0', function(value) {
				if( $F('RETURN_TYPE') == '3' ){
					return checkTotalValue( ["FIX_YY","FIX_MM"] );
				}
				return true;
			}],
			['validate-SPR_YY', '還款方式選擇分期,分期期數需大於0', function(value) {
				if( $F('RETURN_TYPE') == '1' ){
					return checkTotalValue( ["SPR_YY","SPR_MM"] );
				}
				return true;
			}],
			['validate-RETURN_TYPE1', '還款方式總期數須大於0', function(value) {
				return checkTotalValue( ["FIX_YY","FIX_MM","SPR_YY","SPR_MM"] );
			}],
			['validate-RETURN_TYPE2', '還款方式選擇定期+分期,定期及分期期數需皆大於0', function(value) {
				if( $F('RETURN_TYPE') == '2' ){
					return checkTotalValue( ["FIX_YY","FIX_MM"] ) && checkTotalValue( ["SPR_YY","SPR_MM"] );
				}
				return true;
			}],
			['validate-RETURN_TYPE3', '還款方式總期數須大於0', function(value) {
				if( $F('RETURN_TYPE') == '4' ){
					return checkTotalValue( ["SPR_YY","SPR_MM"] );
				}
				return true;
			}],
			//1031029借款用途勾選「代償」者，貸款類別為「其他借新還舊」則不檢核代償行庫中「銀行」及「分行」為必輸欄位:
			['validate-COMP_BANK', '', function(value) {
				if( $F('LOAN_POS') == '01' &&  $F('LOAN_TYPE') != '4'){
					if( value == "" ){
						return false;
					}
				}
				return true;
			}],
			['validate-PRE_SET_AMT', '前順位設定金額請輸入大於0的數字', function(value) {
				if( $('SECOND').checked ){
					if( !isNaN(value) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(value) ){
						return new Number(value) > 0;
					}
				}
				return true;
			}],
			['validate-GAGE_ZIP', '該郵遞區號非澄特區請再次確認', function(value) {
				if ( $F('SPEC_AREA') =='1' && ( value !='814' && value!='833')) {
					return false;
				}
				return true;
			}],
			['validate-OWN_CODE_CONTENT', '通訊地址所有人其他說明為必要輸入欄位', function(value) {
				if($F('OWN_CODE')=='3'){//若通訊地址所有權人選擇"其他"，則通訊地址所有人其他說明為必輸欄位
					return value !== "";
				}
				return true;
			}],
			['validate-IS_SEPARATE', '請輸入正確的拆件另件受理編號長度!', function(value) {
				if( value !== '' && value != 'N' && value.length < 11 ){
					return false;
				}
				return true;
			}],
			['validate-VIP_GRADE', '搭配優利貸客戶，拆件受理商品須為優利貸專案，請重新選擇!', function(value) {
				if ( value == "J" && $F("SEPARATE_TYPE") != "34") {
					return false;
				}
				return true;
			}],
			['validate-Has_Full_Type', '不可輸入全型文字!', function(value) {
				if ( value.length > 0 ) {
					var old_val = value.trim();
					var length = value.length;
					//全形比對
					for ( var i = 0 ; i < length ; i ++ ) {
						var val = old_val.charAt(i) ;  
						var j = DSZ01000.fForm.indexOf(val) ;  
						if(j > -1){
							return false;
						}          
					}
				}
				return true;
			}],
			['validate-REFER_ID_Q', '請輸入正確的前貸款帳號', function(value) {
				<%--檢核長度不得小於10、並只能輸入英數--%>
				return value.length >= 10 && (/^[a-zA-Z0-9]+$/.test(value));
			}],
			['validate-APPLY_ID_Q_11', '請輸入正確的受理編號', function(value) {
				<%--檢核長度不得小於11、並只能輸入英數@--%>
				return validfunction.validAPPLY_ID_Q(value,11);
			}],
			['validate-APPLY_ID_Q_5', '請輸入正確的受理編號', function(value) {
				<%--檢核長度不得小於11、並只能輸入英數@--%>
				return validfunction.validAPPLY_ID_Q(value,5);
			}],
			<%-- [20191213] 增加 拆件受編 檢核--%>
			['validate-SEP_APPLYID_11', '請輸入正確的拆件受編', function(value) {
				<%--檢核長度不得小於11、並只能輸入英數@--%>
				return validfunction.validAPPLY_ID_Q(value,11);
			}],
			<%-- [20191213] 增加 總聯貸金額 檢核--%>
			['validate-UNION_LOAN_AMT', '總聯貸金額請輸入大於0的數字', function(value) {
				if(isCORP_DEPT == 'Y' &&　$F('CASE_STRUCT') == '2'){
					if( !isNaN(value) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(value) ){
						return new Number(value) > 0;
					}
				}
				return true;
			}],
			<%-- [20191213] 若為主受編，須至少輸入一個拆件受編核--%>
			['validate-SEP_APPLYID', '請輸入至少一個拆件受編', function(value) {
				if($('IS_MAIN_APPLYID_Y').checked == true){//是主要受編
					if( $F('SEP_APPLYID_1') == '' && $F('SEP_APPLYID_2') == '' && $F('SEP_APPLYID_3') == '' && $F('SEP_APPLYID_4') == '' &&
					 $F('SEP_APPLYID_5') == '' && $F('SEP_APPLYID_6') == '' && $F('SEP_APPLYID_7') == '' && $F('SEP_APPLYID_8') == '' ){
						return false;
					}
				}
				return true;
			}],
			<%--[20220309] 綠色授信檢核--%>
			['validate-GREEN_TYPE-selection1', '', function(value) {
				if($F('GREEN_TYPE_YES_NO')=='1'){
					if (!$F('GREEN_TYPE')){
						return false;
					}
				}
				return true;
			}],
			<%--[20220309] 綠色授信檢核--%>
			['validate-GREEN_TYPE-selection2', '', function(value) {
				if($F('GREEN_TYPE_YES_NO')=='1'){
					if (!$F('ESG_TYPE_YES_NO')){
						return false;
					}
				}
				return true;
			}],
			<%--[20220309] 永續績效連結欄位檢核--%>
			['validate-ESG_TYPE-selection', '', function(value) {
				if($F('ESG_TYPE_YES_NO')=='1'){
					if (!$F('ESG_TYPE')){
						return false;
					}
				}
				return true;
			}],
			<%--[申請書220606065713]自動徵審:若為理財型房貸，則[理財型_借款主用途]必選--%>
			['validate-LOAN_POS_M-selection', '', function(value) {
				if (!$F('LOAN_POS_M')){
					return false;
				}
				return true;
			}],
			<%--[申請書220606065713]自動徵審:若理財型_借款主用途為「代償」，則理財型_前行庫用途必選
			['validate-LOAN_POS01_M-selection', '', function(value) {
				if($F('LOAN_POS_M')=='01'){
					if (!$F('LOAN_POS01_M')){
						return false;
					}
				}
				return true;
			}],--%>
			<%--[申請書220606065713]自動徵審:若理財型_借款主用途為「業務周轉」、「投資」、「個人周轉」，則[說明框]必輸值--%>
			['validate-LOAN_POS_OTHER_M-selection', '', function(value) {
				if($F('LOAN_POS_M')=='06' || $F('LOAN_POS_M')=='07' || $F('LOAN_POS_M')=='09'){
					if (!$F('LOAN_POS_OTHER_M')){
						return false;
					}
				}
				return true;
			}],
			<%--[申請書220606065713]自動徵審:若理財型_借款次用途為「業務周轉」、「投資」、「個人周轉」，則[說明框]必輸值--%>
			['validate-LOAN_POS2_OTHER_M-selection', '', function(value) {
				if($F('LOAN_POS2_M')=='06' || $F('LOAN_POS2_M')=='07' || $F('LOAN_POS2_M')=='09'){
					if (!$F('LOAN_POS2_OTHER_M')){
						return false;
					}
				}
				return true;
			}],
			<%--[20221223] 若[本金彈性還]選'是'，則[本金彈性還期間_起迄]必輸--%>
            ['validate-FLEX_PERIOD-required', '', function(value) {
                if ($('IS_FLEX_NM_Y').checked) {
                    return value > 0;
                }
                return true;
            }],
			<%-- [20221121] 檢核借款人年齡 --%>
			<%--['validate-age', '請再次確認借款人已成年!', function(value) {
				if (value && $F('BORROW_ID').length != 8) {
					// 自然人才需檢查年齡
					return parseInt($F('AGE')) >= parseInt('${AGE_MIN}');
				}
				return true;
			}],--%>
			<%-- [20221121] 檢核配偶/負責人年齡 --%>
			<%--['validate-couple_age', '請再次確認配偶/負責人已成年!', function(value) {
				if (value && $F('COUPLE_ID').length != 8) {
					// 自然人才需檢查年齡
					return parseInt($F('COUPLE_AGE')) >= parseInt('${AGE_MIN}');
				}
				return true;
			}]--%>
			<%--[20241107] 社會責任授信--%>
			['validate-CSR_TYPE-selection', '', function(v) {
				if($F('CSR_TYPE_YES_NO')=='1'){
					return !Validation.get('IsEmpty').test(v);
				}
				return true;
			}],
			['validate-CSR_RESP', '選擇[個人戶承作]，借款人必須為自然人!', function(v) {
				if($F('CSR_RESP')=='B'){
					return validation.checkROCID(v);
				}
				return true;
			}]
		]);
	
		validForAdd = new Validation( 'form1' );
		setCommonValidation(validForAdd);
		validForQueryForNewLoan = new Validation( 'formQ' );
		validForQueryForNewLoan.define('validate-REFER_ID_Q', 'REFER_ID_Q');
		validForAPPLY_ID = new Validation( 'formQ' );
		
		validForUpdate = new Validation( 'form2' );
		validForUpdate.define( "validate-IS_SEPARATE" , "IS_SEPARATE" );
		validForUpdate.define( "validate-VIP_GRADE" , "VIP_GRADE" );
		setCommonValidation(validForUpdate);
		
		<%-- [20191213] 增加 法金件 檢核--%>
		validForCORP_DEPT = new Validation( 'form1' );
	}
	
	//檢查欄位值總合是否大於0
	function checkTotalValue( checkList ){
		var total = 0;
		for( var i=0 ; i < checkList.length ; i++ ){
			var elm = $(checkList[i]);
			if( elm.disabled == true ){
				continue;
			}
			value = elm.value;
			if( value != "" &&  /^(-)?\d*$/.test(value)){
				total = total + value;
			}					
		}
		if( total > 0 ){
			return true;
		}
		return false;	
	}
	<%--[20220309]辨別是不是null或undefined--%>
	function isEmpty(value){
		if(value == null || value == undefined) {
			return true;
		}else {
			return false;
		}
	}
	function setCommonValidation( valid ){
		valid.define( "validate-MM_ACCOUNT" , "MM_ACCOUNT" );		
		valid.define( "validate-AGENT1_ID" , "AGENT1_ID" );
		valid.define( "validate-COUPLE_ID2" , { id:"AGENT_ID" , errMsg : "經手人身份證號有誤，請檢查後重新輸入!" } );
		valid.define( "validate-COUPLE_NAME" , "COUPLE_NAME" );
		valid.define( "validate-email" , "EMAIL" );
		valid.define( "validate-MOBILE" , "MOBILE" );
		valid.define( "validate-TEL_AREA" , [{ id: 'DAY_TEL_AREA',  errMsg:"電話(日)區碼未選擇" }, {id: 'DAY_TEL_NUM', ignore: true } ] );
		valid.define( "validate-TEL_AREA" , [{ id: 'NIGHT_TEL_AREA',  errMsg:"電話(夜)區碼未選擇" }, {id: 'NIGHT_TEL_NUM', ignore: true } ] );
		valid.define( "validate-TEL_NUM" , "DAY_TEL_NUM" );
		valid.define( "validate-TEL_NUM" , "NIGHT_TEL_NUM");		
		//valid.define( "validate-MOBILE" , "COM_MOBIL" );//[申請書220606065713]自動徵審:聯絡人電話：調整為非必輸值。
		<%--[20250310]問題單20240926-0026：增加卡控借款人生日/成立日期為必輸 --%>
		valid.define( "required" , { id :"BIRTHDAY" , errMsg: "請輸入借款人生日/成立日期" } );
		valid.define( "validate-ROCDate" , { id :"BIRTHDAY" , errMsg: "借款人生日/成立日期錯誤" } );
		//valid.define( "validate-COUPLE_BIRTH" , "COUPLE_BIRTH" );
		valid.define( "validate-YearAndMonth" , "TRADE_DATE" );
		valid.define( "validate-YearAndMonth" , { id : "SET_YM" , errMsg : "設定年月錯誤"} );
		//valid.define( "validate-ROCDate" , { id : "COPR5" , errMsg : "訂約日期錯誤"} );
		valid.define( "validate-GAGE_ADDR" , "GAGE_ADDR" );
		valid.define( "validate-FIX_YY" , "FIX_YY" );
		valid.define( "validate-RETURN_TYPE1" , "RETURN_TYPE" );
		valid.define( "validate-RETURN_TYPE2" , "RETURN_TYPE" );
		valid.define( "validate-RETURN_TYPE3" , "RETURN_TYPE" );		
		valid.define( "validate-COMP_BANK" , { id : "COMP_BANK" , errMsg : "請輸入代償銀行"} );
		valid.define( "validate-COMP_BANK" , { id : "COMP_BRANCH" , errMsg : "請輸入代償分行"} );
		valid.define( "validate-COMP_BANK" , { id : "COMP_AMT" , errMsg : "請輸入代償金額"} );
		valid.define( "validate-PRE_SET_AMT" , "PRE_SET_AMT" );
		valid.define( "validate-GAGE_ZIP" , "GAGE_ZIP" );
		valid.define( "validate-OWN_CODE_CONTENT" , "OWN_CODE_CONTENT" );
		valid.define( "hasHalfType" , "SELL_ID" );
		valid.define( "checkInputLength" , "SELL_ID" );
		
		<%--[20220309] 綠色授信、永續績效連結欄位檢核--%>
		valid.define( 'validate-selection' , [{ id : 'GREEN_TYPE_YES_NO', errMsg:'綠色授信尚未選擇'}] );
		valid.define( 'validate-GREEN_TYPE-selection1' , [{ id : 'GREEN_TYPE', errMsg:'請選擇請選擇綠色支出類別'}] );
		valid.define( 'validate-GREEN_TYPE-selection2' , [{ id : 'ESG_TYPE_YES_NO', errMsg:'必須選擇永續績效連結'}] );		
		valid.define( 'validate-ESG_TYPE-selection' , [{ id : 'ESG_TYPE', errMsg:'請選擇永續績效連結類別'}] );
		<%--[申請書220606065713]自動徵審:理財型欄位檢核--%>
		valid.define( 'validate-LOAN_POS_M-selection' , [{ id : 'LOAN_POS_M', errMsg:'請選擇[理財型_借款主用途]類別'}] );
		//valid.define( 'validate-LOAN_POS01_M-selection' , [{ id : 'LOAN_POS01_M', errMsg:'請選擇[理財型_前行庫用途]類別'}] );
		valid.define( 'validate-LOAN_POS_OTHER_M-selection' , [{ id : 'LOAN_POS_OTHER_M', errMsg:'請輸入[說明框]'}] );
		valid.define( 'validate-LOAN_POS2_OTHER_M-selection' , [{ id : 'LOAN_POS2_OTHER_M', errMsg:'請輸入[說明框]'}] );
		
		<%-- [20221121] 檢核借款人/配偶/負責人 --%>
		//valid.define( 'validate-age' , [{ id : 'BIRTHDAY', errMsg:'請再次確認借款人已成年!'}] );
		//valid.define( 'validate-couple_age' , [{ id : 'COUPLE_BIRTH', errMsg:'請再次確認配偶/負責人已成年!'}] );
		
		<%--[20221223] 若[本金彈性還]選'是'，則[本金彈性還期間_起迄]必輸--%>
        valid.define( 'validate-FLEX_PERIOD-required' , [{ id : 'FLEX_PERIOD_B', errMsg:'請輸入[本金彈性還期間_起]'}] );
        valid.define( 'validate-FLEX_PERIOD-required' , [{ id : 'FLEX_PERIOD_E', errMsg:'請輸入[本金彈性還期間_迄]'}] );
        <%--[20241107] 社會責任授信欄位檢核--%>
		valid.define( 'validate-selection' , [{ id : 'CSR_TYPE_YES_NO', errMsg:'社會責任授信尚未選擇'}] );
		valid.define( 'validate-CSR_TYPE-selection' , [{ id : 'CSR_TYPE', errMsg:'本案為[社會責任授信]，必須選擇[社會責任專案類別]!'}] );
		valid.define( 'validate-CSR_TYPE-selection' , [{ id : 'CSR_TA', errMsg:'本案為[社會責任授信]，必須選擇[社會責任專案目標族群]!'}] );		
		valid.define( 'validate-CSR_TYPE-selection' , [{ id : 'CSR_RESP', errMsg:'本案為[社會責任授信]，必須選擇[承作社會責任專案者]!'}] );
		valid.define( 'validate-CSR_RESP' , [{ id : 'BORROW_ID', errMsg:'選擇[個人戶承作]，借款人必須為自然人!'}] );
	}
	
	
	//新增前的檢核
	function validateBeforeAdd(){
		//理財型房貸被勾選
		if($('LOAN_M').checked ){
			var LOAN_AMT_M = $F('LOAN_AMT_M');
			if(  LOAN_AMT_M == "" || LOAN_AMT_M ==0 ){
                if(! confirm("請確認週轉型額度為0萬")){
					return false;
				}
			}
		}
		
		if ( $F('GAGE_TYPE') != '1'){
			if( !confirm("請確認擔保品種類是否非房地產")){
				return false;
			}
		}
		return validForAdd.validate();
	}
	//修改前的檢核
	function validateBeforeUpdate(){
		//理財型房貸被勾選
		if($('LOAN_M').checked ){
			var LOAN_AMT_M = $F('LOAN_AMT_M');
			if(  LOAN_AMT_M == "" || LOAN_AMT_M ==0 ){
                if(! confirm("請確認週轉型額度為0萬")){
					return false;
				}
			}
		}
	
		if ( $F('GAGE_TYPE') != '1'){
			if( !confirm("請確認擔保品種類是否非房地產")){
				return false;
			}
		}
		return ( validForAdd.validate() &&  validForUpdate.validate() );
	}
	
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
	
	//將查詢回來的data set到畫面上
	function dataTofillForm( rtnMap ){
		validForAdd.reset(true);
	
		$('form1').reset();					//回復原始input再塞值
		//填form
		rtnMap["APPLY_ID1"] = rtnMap["APPLY_ID"].substring(0,5);
		JSONUtil.sampleJSON2Form3( "form1", rtnMap, [] );
		//填div	
		$('form1').select('div').each(function(elm){
			var id = elm.id;
			elm.innerHTML = rtnMap[id] || ''; 			
		});
		//填checkbox
		$('form1').select('input[type="checkbox"]').each(function(elm){
			var id = elm.id;
			if( rtnMap[id] == '1' ){
				elm.checked = true;
			}
		});
		
		//特別處理民國日期的部份
		$('form1').select('[datatype="ROCDate"]').each(function(elm){
			var id = elm.id;
			if( elm.tagName == 'DIV' ){
				if( rtnMap[id] ){
					elm.innerHTML = Date.toInputROC( rtnMap[id] , "/" );
				}
			}else{
				if( rtnMap[id] ){
					if( elm.getAttribute("data-YMonly")){		//只秀年月
						var roc_date = Date.toInputROC( rtnMap[id] , "" );
						elm.value = roc_date.substring( 0 , roc_date.length - 2 );
					}else{
						elm.value = Date.toInputROC( rtnMap[id] , "" );
					}
				}
			}
		});
		
		var option = $('SELECT_BANK').down('option[value="'+ (rtnMap.COMP_BANK || "") + '"]');
		if( option ){
			option.selected = true;
		}else{
			$('SELECT_BANK').value = "其他";
		}
		
		//電腦作業申請書150213000124
		//新增理財型房貸新商品-「新理財型房貸10404」97H	
		$('PREFER_TYPE_M').value = '97' + rtnMap['INSU_PRANK'].substring(0,1);
		
		//前貸款帳號
		$('REFER_ID_Q').value = rtnMap.REFER_ID || "";
		
		$('A010_INPUT_ID').value = rtnMap["INPUT_ID"];
		
		address1.setINPUT_ZIPCODE( rtnMap.GAGE_ZIP );
		address2.setINPUT_ZIPCODE( rtnMap.CON_ZIP );
		
		//設定VIP資訊
		setVIPforAjax( 1 , rtnMap.VIPBO );
		
		AGENT_DEPT = rtnMap.AGENT_DEPT;						
		if(AGENT_DEPT == '720'){
			$('ALWC_RATE').value = "100";
			$('ALWC_RATE').disabled = true;							
		}else{
			$('ALWC_RATE').disabled = false;
		}						
		ALWC_RATE_Changed( $F('ALWC_RATE'));
		
		<%-- [20220309] 綠色授信、永續績效連結恢復欄位初始化--%>
		$('GREEN_TYPE').enable();
		$('ESG_TYPE').enable();
		$('ESG_TYPE_YES_NO').enable();
		
		<%--[20220309] 綠色授信、永續績效連結欄位塞值--%>		
		if (!isEmpty(rtnMap)){
			//綠色授信
			if (rtnMap['GREEN_TYPE']){
				if (rtnMap['GREEN_TYPE']=='0'){
					$('GREEN_TYPE_YES_NO').setValue('0');
					$('GREEN_TYPE').setValue('');
					$('GREEN_TYPE').disable();
				}else{
					$('GREEN_TYPE_YES_NO').setValue('1');
					$('GREEN_TYPE').setValue(rtnMap['GREEN_TYPE']);
					$('GREEN_TYPE').simulate('change');
				}
			}else{
				if(rtnMap['COPR_CODE'] == '0'){//非法人
					if(rtnMap['LOAN_DATE'] == '' || rtnMap['LOAN_DATE'] >= '2022-03-01' || rtnMap['APPLY_DATE'] == '' || rtnMap['APPLY_DATE'] >= '2022-03-01'){
					//[laon_date >= 3/1] or [apply_date >= 3/1或空值]綠色授信與永續績效連結預帶”否”，不符合條件則預帶”請選擇”
						$('GREEN_TYPE_YES_NO').setValue('0');
						$('GREEN_TYPE').setValue('');
						$('GREEN_TYPE').disable();
						$('ESG_TYPE_YES_NO').setValue('0');
						$('ESG_TYPE').setValue('');
						$('ESG_TYPE').disable();
					}else{
						$('GREEN_TYPE_YES_NO').setValue('');
						$('GREEN_TYPE').setValue('');
						$('ESG_TYPE_YES_NO').setValue('');
						$('ESG_TYPE').setValue('');
					}
				}else{//法人
					if(rtnMap['APPLY_DATE'] != ''){//[apply_date有值]，綠色授信與永續績效連結預帶”否”  [apply_date = 空值]則預帶”請選擇”
						$('GREEN_TYPE_YES_NO').setValue('0');
						$('GREEN_TYPE').setValue('');
						$('GREEN_TYPE').disable();
						$('ESG_TYPE_YES_NO').setValue('0');
						$('ESG_TYPE').setValue('');
						$('ESG_TYPE').disable();
					}else{
						$('GREEN_TYPE_YES_NO').setValue('');
						$('GREEN_TYPE').setValue('');
						$('ESG_TYPE_YES_NO').setValue('');
						$('ESG_TYPE').setValue('');
					}
				}
				<%--
				if (rtnMap['FORM_TYPE']=='R'){//APP件
					$('GREEN_TYPE_YES_NO').setValue('0');
					$('GREEN_TYPE').setValue('');
					$('GREEN_TYPE').disable();
				}else{
					$('GREEN_TYPE_YES_NO').setValue('');
					$('GREEN_TYPE').setValue('');
				}--%>
				<%--
				if(rtnMap['COPR_CODE'] == '0'){//非法人
					if(rtnMap['LOAN_DATE'] == '' || rtnMap['LOAN_DATE'] >= '2022-03-01'){//3/1後貸放，綠色授信與永續績效連結預帶「否」
						$('GREEN_TYPE_YES_NO').setValue('0');
						$('GREEN_TYPE').setValue('');
						$('GREEN_TYPE').disable();
						$('ESG_TYPE_YES_NO').setValue('0');
						$('ESG_TYPE').setValue('');
						$('ESG_TYPE').disable();
					}else{
						$('GREEN_TYPE_YES_NO').setValue('');
						$('ESG_TYPE_YES_NO').setValue('');
					}
				}else{//法人
					$('GREEN_TYPE_YES_NO').setValue('0');
					$('GREEN_TYPE').setValue('');
					$('GREEN_TYPE').disable();
					$('ESG_TYPE_YES_NO').setValue('0');
					$('ESG_TYPE').setValue('');
					$('ESG_TYPE').disable();
				}--%>
			}
			//永續績效連結
            if (rtnMap['ESG_TYPE']){
            	if (rtnMap['ESG_TYPE']=='0'){
					$('ESG_TYPE_YES_NO').setValue('0');
					$('ESG_TYPE').setValue('');
					$('ESG_TYPE').disable();
				}else{
					$('ESG_TYPE_YES_NO').setValue('1');
					$('ESG_TYPE').setValue(rtnMap['ESG_TYPE']);
				}
			}else{
				<%--//上述綠色授信為「是」且法人件欄位打勾者即可點選拉把，系統預帶「請選擇」，反之即帶入「否」且不可點選拉把。
				if ( $('COPR_CODE').checked && $F('GREEN_TYPE_YES_NO') == '1' ){
					$('ESG_TYPE_YES_NO').setValue('');
				}else{
					$('ESG_TYPE_YES_NO').setValue('0');
				}
				$('ESG_TYPE').setValue('');
				$('ESG_TYPE').disable();--%>
				if(rtnMap['COPR_CODE'] == '0'){//非法人
					if(rtnMap['LOAN_DATE'] == '' || rtnMap['LOAN_DATE'] >= '2022-03-01' || rtnMap['APPLY_DATE'] == '' || rtnMap['APPLY_DATE'] >= '2022-03-01'){
					//[laon_date >= 3/1] or [apply_date >= 3/1或空值]綠色授信與永續績效連結預帶”否”，不符合條件則預帶”請選擇”
						$('ESG_TYPE_YES_NO').setValue('0');
						$('ESG_TYPE').setValue('');
						$('ESG_TYPE').disable();
					}else{
						$('ESG_TYPE_YES_NO').setValue('');
						$('ESG_TYPE').setValue('');
					}
				}else{//法人
					if(rtnMap['APPLY_DATE'] != ''){//[apply_date有值]，綠色授信與永續績效連結預帶”否”  [apply_date = 空值]則預帶”請選擇”
						$('ESG_TYPE_YES_NO').setValue('0');
						$('ESG_TYPE').setValue('');
						$('ESG_TYPE').disable();
					}else{
						$('ESG_TYPE_YES_NO').setValue('');
						$('ESG_TYPE').setValue('');
					}
				}
			}
		}	
		<%--[20241107]社會責任授信--%>
		var CSR_TYPE = rtnMap['CSR_TYPE'] == undefined ? '' : rtnMap['CSR_TYPE'];
		if(CSR_TYPE != ''){
	        if (CSR_TYPE == '0'){
	        	$('CSR_TYPE_YES_NO').setValue('0');        	
	        }else{
	        	$('CSR_TYPE_YES_NO').setValue('1');
	        	$w('CSR_TYPE CSR_TA CSR_RESP').each(function(id){
	        		var val = rtnMap[id] == undefined ? '' : rtnMap[id];
	        		$(id).setValue(val);
	    		});        	
	        }
	    	$('CSR_TYPE_YES_NO').simulate('change');
		}
		controlInputs();
	}
	
	//將畫面的資料set到VO
	function getDataFromForm( isInsert ){
		var DATA_MAP = isInsert ? {} : result;		//如果是新增的話，new一個新物件，否則用上次查詢回來舊的資料
		
		$('form1').select('select').each(function(elm){
			if( elm.disabled == false ){
				DATA_MAP[elm.id] = elm.value;
			}else{
				DATA_MAP[elm.id] = '';		
			}			
		});
		
		$('form1').select('input').each(function(elm){
			var id = elm.id;
			if( elm.type == 'radio' ){
				var elmName = elm.name;
				id = elmName;
				
				var elmValue = '';
				$('form1').select('input[name='+elmName+']').each(function(radioEle){
					if(radioEle.checked){
						elmValue = radioEle.value;
						return;
					}
				});
				
				DATA_MAP[id] = elmValue;	
				return;
			}else if( elm.type == 'checkbox' && elm.checked == false){
				DATA_MAP[id] = '0';				//checkbox未勾選預設為0
				return;
			}
			
			//enable的欄位才設定值 ,排除"本次借款用途為購買保險"
			//排除radio
			if( elm.disabled == false || 'BUY_INSURANCE' == id ){		
				DATA_MAP[id] = elm.value;
			}else{
				DATA_MAP[id] = '';
			}
		});
		DATA_MAP["REFER_ID"] = $F('REFER_ID_Q');
		DATA_MAP["GAGE_ZIP"] = $F("GAGE_ZIP");		//郵遞區號為特別 (畫面為disabled但必需設定值)
		DATA_MAP["CON_ZIP"] = $F("CON_ZIP");
		DATA_MAP["ALWC_RATE"] = $F("ALWC_RATE"); //業績比例為特別 (畫面為disabled但必需設定值)
		<%--[20220309] 讀取綠色授信、綠色支出類別、永續績效連結和永續績效連結類別下拉選單設定--%>
		if ($F('GREEN_TYPE_YES_NO')=='0'){
			DATA_MAP['GREEN_TYPE']='0';
		}
		else{
			DATA_MAP['GREEN_TYPE']=$F('GREEN_TYPE');
		}		
		if ($F('ESG_TYPE_YES_NO')=='0'){
			DATA_MAP['ESG_TYPE']='0';
		}
		else{
			DATA_MAP['ESG_TYPE']=$F('ESG_TYPE');
		}
		<%--[申請書:220908003741]新增本金彈性還還款方式--%>
	    if ($('LOAN_C').checked && $('IS_FLEX_NM_Y').checked) {
	        DATA_MAP['FLEX_PERIOD_B'] = $F('FLEX_PERIOD_B');
	        DATA_MAP['FLEX_PERIOD_E'] = $F('FLEX_PERIOD_E');
	    }else{
	    	 DATA_MAP['FLEX_PERIOD_B'] = '';
		     DATA_MAP['FLEX_PERIOD_E'] = '';
		     DATA_MAP['IS_FLEX_NM'] = 'N';
	    }
	    <%--[20241107]社會責任授信--%>
        if ($F('CSR_TYPE_YES_NO')=='0'){
			DATA_MAP['CSR_TYPE']='0';
		}
		return DATA_MAP;
	}
	
	//根據業務邏輯 control 畫面欄位 enable or disable
	//rtnMap為查詢出的資料,isNewQuery為是否為增貸查詢
	function controlInputs( rtnMap ){
		//房貸類型
		var LOAN_C_checked = $('LOAN_C').checked;
		LOAN_Changed( 'LOAN_C' , $('LOAN_C').checked );
		LOAN_Changed( 'LOAN_M' , $('LOAN_M').checked );
	
		//還款方式 (一般型打勾時才做change的動作，避免disabled被打開)
		if( LOAN_C_checked ){
			RETURN_TYPE_Changed( $('RETURN_TYPE').value );
		}
	
		//通訊地址選擇事件
		CON_CODE_Changed( getRadioValue("CON_CODE") );
		
		//擔保種類
		var GAGE_TYPE = $('GAGE_TYPE').value;
		GAGE_TYPE_Changed( GAGE_TYPE );

		//擔保品資料_地址
		$('GAGE_ADDR').disabled = isNewQuery ? true : false;
		
		//貸款種類		*先拿掉~ 暫時不做*
		//LOAN_KIND_Changed( $('LOAN_KIND').value );
		
		//法人件改變
		COPR_CODE_Changed( $('COPR_CODE').checked , $F('APPLY_ID1') );
				
		//業績比例
		ALWC_RATE_Changed( $F('ALWC_RATE') );
		
		//二順位
		SECOND_Changed( $('SECOND').checked );
		
		//貸款用途
		LOAN_POS_Changed((rtnMap)?rtnMap['BUY_INSURANCE']:null);

		<%-- [20191213] 增加 案件架構(CASE_STRUCT)】、【幣別(CURR)】連動：--%>
		if(isCORP_DEPT == 'Y'){
			CASE_STRUCT_Changed( $F('CASE_STRUCT') , $F('CURR') );				 
		}
		//[申請書220606065713]自動徵審:若借款主用途為「投資」，則「說明框」預帶"投資"；若借款主用途為「業務週轉(公司)」或「個人週轉」，則「說明框」預帶"週轉"
	    var LOAN_POSvalue = $F('LOAN_POS');
		if( !$F('LOAN_POS_OTHER') ){
	    	if( '06' == LOAN_POSvalue ){
	    		$('LOAN_POS_OTHER').value = "投資";
	    	}else if( '07' == LOAN_POSvalue || '09' == LOAN_POSvalue){
	    		$('LOAN_POS_OTHER').value = "週轉";
	    	}
	    }
	    LOAN_POS_M_Changed();
	    
	    <%-- [20221121] --%>
	    $('BORROW_ID').simulate('change');
		$('BIRTHDAY').simulate('change');
		$('COUPLE_BIRTH').simulate('change');
		
		<%--[20221223] 本金彈性還--%>
        var FLEX_PERIOD_B = rtnMap ? rtnMap.FLEX_PERIOD_B : '';
        var FLEX_PERIOD_E = rtnMap ? rtnMap.FLEX_PERIOD_E : '';
        if (FLEX_PERIOD_B > 0 && FLEX_PERIOD_E > 0) {
            $('IS_FLEX_NM_Y').checked = true;
            $('IS_FLEX_NM_Y').simulate('change');
            $('FLEX_PERIOD_B').setValue(FLEX_PERIOD_B);
            $('FLEX_PERIOD_E').setValue(FLEX_PERIOD_E);
        } else {
            $('IS_FLEX_NM_N').checked = true;
            $('IS_FLEX_NM_N').simulate('change');
        }
	}
	
	function getRadioValue( radioName){
		var radios = document.getElementsByName(radioName);
		for( var i=0 ; i<radios.length ; i++ ){
			if( radios[i].checked == true ){
				return radios[i].value;
			}
		}
		return '';
	}
	
	function setRadioValue( radioName , value ){
		var radios = document.getElementsByName(radioName);
		for( var i=0 ; i<radios.length ; i++ ){
			if( radios[i].value == value ){
				radios[i].checked = true;
				break;
			}else{
				radios[i].checked = false;
			}
		}
	}
	
	function setRadioDisable( radioName , disable ){
		var radios = document.getElementsByName(radioName);
		for( var i=0 ; i<radios.length ; i++ ){
			radios[i].disabled = disable;
		}
	}
	
	//法人檢核
	function chkCoprCode(){
		<%--20180131陳妍伶,風險評分模型導入
		1.借款人ID長度為8碼，若法人件check box未勾選，跳出確認視窗，訊息"借款人ID非統一編號，法人件項目已勾選，請確認是否繼續作業!"
		2.借款人ID長度為10碼，若法人件check box有勾選，跳出確認視窗，訊息"借款人為自然人，請確認受理案件是否為法人件"
		3.若法人件check box有勾選，畫面須檢查有勾選負責人、姓名、ID 
		--%>
		var BID_LENGTH=$F('BORROW_ID').length;			
		if($F('COPR_CODE')=="1" && BID_LENGTH != 8){
			if(!confirm('法人件項目已勾選，借款人ID非統一編號，請確認是否繼續作業!')) {
				return false;
			}	
		}else if($F('COPR_CODE')!="1" && BID_LENGTH == 8){
			if(!confirm('法人件項目未勾選，借款人ID為統一編號，請確認是否繼續作業!')) {
				return false;
			}
		}
		//取得配偶/負責人radio box的值
		var coupleType=getRadioValue("COUPLE_TYPE");
		//20180430 改在檢核模組判斷
		<%--if($F('COPR_CODE')=="1"){				
			if(coupleType !="2"){
				alert("公司件，請勾選負責人!");
				return false;
			}
			if($F('COUPLE_NAME') ==""){
				alert("公司件，請填寫負責人姓名!");
				return false;
			}
			if($F('COUPLE_ID') ==""){
				alert("公司件，請填寫負責人ID!");
				return false;
			}
		}--%>
		
		return true;
	}
	
	<%-- [20191213] 法金件 增加 --%>
	function check_CORP_DEPT(){
		if(isCORP_DEPT != 'Y'){//是否為法金科輸入
			return true;
		}
	
		validForCORP_DEPT.clear();		 
		validForCORP_DEPT.reset();
		
		//案件架構
		validForCORP_DEPT.define('required', 'CASE_STRUCT');
		
		//總聯貸金額		 
		validForCORP_DEPT.define('validate-UNION_LOAN_AMT', 'UNION_LOAN_AMT');
		
		//檢核是否為主受編
		if($F('SEP_REASON')){
			if(!$('IS_MAIN_APPLYID_Y').checked && !$('IS_MAIN_APPLYID_N').checked){
				validForCORP_DEPT.define('required', 'IS_MAIN_APPLYID_Y');
			}
		}
		
		//若為主受編，須至少輸入一個拆件受編
		validForCORP_DEPT.define('validate-SEP_APPLYID', 'SEP_APPLYID_1');
		
		//拆件受編:檢核受編長度
		if($F('SEP_APPLYID_1')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_1');
 		}
		if($F('SEP_APPLYID_2')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_2');
 		}
		if($F('SEP_APPLYID_3')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_3');
 		}
		if($F('SEP_APPLYID_4')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_4');
 		}
		if($F('SEP_APPLYID_5')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_5');
 		}
		if($F('SEP_APPLYID_6')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_6');
 		}
		if($F('SEP_APPLYID_7')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_7');
		}
		if($F('SEP_APPLYID_8')){
			validForCORP_DEPT.define('validate-SEP_APPLYID_11', 'SEP_APPLYID_8');
		}	
		if(!validForCORP_DEPT.validate()){
			return false;
		}		
		return true;
	}
	
	var btnActions ={
		//查詢
		Btn_query: function( event){
			var APPLY_ID = $F('APPLY_ID_Q');
			validForAPPLY_ID.clear();
			validForAPPLY_ID.reset();
			validForAPPLY_ID.define('validate-APPLY_ID_Q_11', 'APPLY_ID_Q');
			if(!validForAPPLY_ID.validate()){
				return;
			}
			/*if( APPLY_ID.length < 11 ){
				alert("請輸入正確的受理編號");
				return;
			}*/
			
			APPLY_ID = APPLY_ID.toUpperCase();
			$('APPLY_ID_Q').value = APPLY_ID;
			
			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': APPLY_ID });
			
			ajaxPost( 'query' , { APPLY_ID : APPLY_ID } , function(resp){
				dataTofillForm( resp.rtnMap );
				result = resp.rtnMap;
				isNewQuery = false;
				<%-- [20191213] 增加 --%>
				isCORP_DEPT = result['isCORP_DEPT'];
				if(isCORP_DEPT == 'Y'){
					sectionLOAN_UNION.show();
				} else {
					sectionLOAN_UNION.hide();
				}
				controlInputs(result);	
														
			});
		},
		//增貸查詢
		Btn_queryNewLoan: function( event){
			var REFER_ID_Q = $F('REFER_ID_Q');
			
			if(!validForQueryForNewLoan.validate()){
				return;
			}
			
			
			REFER_ID_Q = REFER_ID_Q.toUpperCase();
			$('REFER_ID_Q').value = REFER_ID_Q;
			
			ajaxPost( 'queryNewLoan' , { REFER_ID_Q : REFER_ID_Q } , function(resp){
				dataTofillForm( resp.rtnMap );
				result = resp.rtnMap;
				isNewQuery = true;
				controlInputs( result );
			});
		},
		//影像置換-變更
		Btn_imageChange: function( event){
			if( confirm("確定要修改影像置換？")){
				
				var DATA_MAP = getDataFromForm();
				
				ajaxPost( 'imageChange' , { DATA_MAP : Object.toJSON(DATA_MAP) } , function(resp){
					if( resp.rtnMap ){
						dataTofillForm( resp.rtnMap );
						result = resp.rtnMap;
						controlInputs(result);		
					}
				});
			}
		},
		//快速增貸-變更
		Btn_addLoan: function( event){
			if( confirm("確定要變更快速審核？")){
				
				var DATA_MAP = getDataFromForm();
				
				ajaxPost( 'addLoan' , { DATA_MAP : Object.toJSON(DATA_MAP) } , function(resp){
					if( resp.rtnMap ){
						dataTofillForm( resp.rtnMap ); 
						result = resp.rtnMap;
						controlInputs(result);
					}
				});
			}
		},
		//影像連結
		Btn_linkImage: function( event){
			validForAPPLY_ID.clear();
			validForAPPLY_ID.reset();
			validForAPPLY_ID.define('validate-APPLY_ID_Q_11', 'APPLY_ID_Q');
			if(!validForAPPLY_ID.validate()){
				return;
			}
		
			var APPLY_ID = $F('APPLY_ID_Q');
			/*if( APPLY_ID.length < 11 ){
				alert("請輸入正確的受理編號");
				return;
			}*/
			
			APPLY_ID = APPLY_ID.toUpperCase();
			$('APPLY_ID_Q').value = APPLY_ID;

			popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
				'parameters': {'APPLY_ID': APPLY_ID, 'draftyn':'${draftyn}'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA10100' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
			});
		},
		//新增
		Btn_add: function(event){
			if( $('LOAN_C').checked == false && $('LOAN_M').checked == false ){
				alert( "必須勾選房貸類型" );
				return;
			}
			<%-- [20221121] 檢核借款人年齡--%>
			if ('' != $F('BORROW_ID') && $F('BORROW_ID').length != 8) {//自然人才需檢查年齡
				if( '' != $F('AGE') && parseInt($F('AGE')) <= parseInt('${AGE_MIN}') ){
					alert('請再次確認借款人已成年!');
				}
			}
			<%-- [20221121] 檢核配偶/負責人年齡 --%>
			if ('' != $F('COUPLE_ID') && $F('COUPLE_ID').length != 8) {//自然人才需檢查年齡
				if( '' != $F('COUPLE_AGE') && parseInt($F('COUPLE_AGE')) <= parseInt('${AGE_MIN}') ){
					alert('請再次確認配偶/負責人已成年!');
				}
			}
			<%--[20240326] 修改件 陳勁谷申請書240201007793]新增本金彈性還還款方式_貸後變更
			若[本金彈性還]選'是'，則檢核FLEX_PERIOD_E是否為12的倍數，若非12的倍數時則confirm"本金彈性還期間非12之倍數，是否繼續執行!"，點"是"後新增修改成功，點"否"後不執行新增修改。--%> 
			if ($('IS_FLEX_NM_Y').checked && $F('FLEX_PERIOD_E') % 12 != 0) {
				if (!confirm('本金彈性還期間非12之倍數，是否繼續執行!')) {
					return;
				}
			}
			validForAPPLY_ID.clear();
			validForAPPLY_ID.reset();
			validForAPPLY_ID.define('validate-APPLY_ID_Q_5', 'APPLY_ID_Q');
			if(!validForAPPLY_ID.validate()){
				return;
			}
			
			<%-- [20191213] 法金件檢核 --%>
			if(!check_CORP_DEPT()){
				return;
			}
			
			var APPLY_ID = $F('APPLY_ID_Q');
			/*if( APPLY_ID.length < 5 ){
				alert( "請輸入至少5碼受理編號");
				return;
			}*/
			if( !validateBeforeAdd() ){
				return;
			}
			
			//法金、聯貸案件，須簡查訂約日期格式為民國年
			 var is_copr2=$('COPR2').checked ;
			 if(is_copr2 ){
			 	if(!isROCdate($F('COPR5'))){
			 		alert("聯貸案件，訂約日期須為民國年格式!");
			 		return;
			 	}
			 }
			
			//檢查法人件欄位
			if(!chkCoprCode()){
				return;
			}
			
			
			<%--因聯徵查詢在動產的部份有針對不同的動產別做不同的類別報送，所以要請法金科提供動產是哪種動產
			政府保證(02)、其他機構保證(04)、航空器(34)、船舶(32)、有價證券(1X)
			設定受理編號對應的類別在代碼管理(DS/D201_GAGECLASS)--%>
			if($F('GAGE_TYPE') == '7'){
				alert('國外動產請提供受編及擔保品類別給放款資訊科人員');
			}
			replacetaiwan();//臺改台
			var DATA_MAP = getDataFromForm(true);
			DATA_MAP["APPLY_ID"] = APPLY_ID;
			DATA_MAP["APPLY_ID1"] = APPLY_ID.substring(0,5);
			DATA_MAP["CRED_ID"] = "";	//新增時,CRED_ID不能使用畫面資料寫入,請給空白
			ajaxPost( 'add' , { DATA_MAP : Object.toJSON(DATA_MAP) } , function(resp){
				if( resp.rtnMap ){
					var APPLY_ID = resp.rtnMap.APPLY_ID;
					$('APPLY_ID_Q').value = APPLY_ID;
					$('APPLY_ID1').value = APPLY_ID.substring( 0 , 5);
					dataTofillForm( resp.rtnMap );
					result = resp.rtnMap;
					isNewQuery = false;
					controlInputs(result);
				}
			});
		},
		//修改
		Btn_update: function(event){
			var APPLY_ID = $('APPLY_ID').innerHTML;
			if( !APPLY_ID ){
				alert("請先查詢後再繼續作業");
				return;
			}
		
			if( $('LOAN_C').checked == false && $('LOAN_M').checked == false ){
				alert( "必須勾選房貸類型" );
				return;
			}			
			
			if( APPLY_ID != $F('APPLY_ID_Q') ){
				alert( "輸入的受理編號必須等於查詢的受理編號" );
				return;
			}
			
			<%-- [20221121] 檢核借款人年齡--%>
			if ( '' != $F('BORROW_ID') && $F('BORROW_ID').length != 8) {//自然人才需檢查年齡
				if( '' != $F('AGE') && parseInt($F('AGE')) <= parseInt('${AGE_MIN}') ){
					alert('請再次確認借款人已成年!');
				}
			}
			<%-- [20221121] 檢核配偶/負責人年齡 --%>
			if ('' != $F('COUPLE_ID') && $F('COUPLE_ID').length != 8) {//自然人才需檢查年齡
				if( '' != $F('COUPLE_AGE') && parseInt($F('COUPLE_AGE')) <= parseInt('${AGE_MIN}') ){
					alert('請再次確認配偶/負責人已成年!');
				}
			}
			<%--[20240326] 修改件 陳勁谷申請書240201007793]新增本金彈性還還款方式_貸後變更
			若[本金彈性還]選'是'，則檢核FLEX_PERIOD_E是否為12的倍數，若非12的倍數時則confirm"本金彈性還期間非12之倍數，是否繼續執行!"，點"是"後新增修改成功，點"否"後不執行新增修改。--%> 
			if ($('IS_FLEX_NM_Y').checked && $F('FLEX_PERIOD_E') % 12 != 0) {
				if (!confirm('本金彈性還期間非12之倍數，是否繼續執行!')) {
					return;
				}
			}
			if( !validateBeforeUpdate() ){
				return;
			}
			
			//檢查法人件欄位
			if(!chkCoprCode()){
				return;
			}
			
			<%-- [20191213] 法金件檢核 --%>
			if(!check_CORP_DEPT()){
			   return;
			}

			<%--因聯徵查詢在動產的部份有針對不同的動產別做不同的類別報送，所以要請法金科提供動產是哪種動產
			政府保證(02)、其他機構保證(04)、航空器(34)、船舶(32)、有價證券(1X)
			設定受理編號對應的類別在代碼管理(DS/D201_GAGECLASS)--%>
		  	if($F('GAGE_TYPE') == '7'){
				alert('國外動產請提供受編及擔保品類別給放款資訊科人員');
			}
    		replacetaiwan();//臺改台
			var DATA_MAP = getDataFromForm();	
			ajaxPost( 'update' , { DATA_MAP : Object.toJSON(DATA_MAP) } , function(resp){
				if( resp.rtnMap ){
					dataTofillForm( resp.rtnMap );
					result = resp.rtnMap;
					controlInputs(result);
				}					
			});
		},
		//刪除
		Btn_delete: function(event){
			var APPLY_ID = $('APPLY_ID').innerHTML;
			if( !APPLY_ID ){
				alert("請先查詢後再繼續作業");
				return;
			}
			
			var DATA_MAP = getDataFromForm();
			
			if( confirm("確定要刪除 " + APPLY_ID + " 此受理編號之所有資料(申請,個人,土地,建物...)？")){	
				
				ajaxPost( 'delete' , { DATA_MAP : Object.toJSON(DATA_MAP) } , function(resp){				
					result = '';
					isNewQuery = false;
					btnActions.Btn_clear();
				});
			}
		},
		//清空
		Btn_clear: function(event){
			if( result ){
				dataTofillForm( result );
			}else{
				validForAdd.reset(true);
				
				$('form1').reset();
				address1.setINPUT_ZIPCODE("");
				address2.setINPUT_ZIPCODE("");
				$('form1').select('div').each(function(elm){
					elm.innerHTML = defaultMap[elm.id] || "";
				});
				
				//銀行名稱預設其他
				$('SELECT_BANK').value = "其他";
				
				//業績比例預設100%
				$('ALWC_RATE').value = "100";
				
				setRadioValue( "FAST_AGREE" , "X");
				setRadioValue( "IMAGE_EDIT_AUTH" , "X");
				
				/* [20191213] 增加 */
				setRadioValue("CRED_RATE_BBB" , "");
				setRadioValue("IS_MAIN_APPLYID" , "");
				$('CURR').value = 'NTD';//幣別
				$('INTEREST_RT_TP').value = '5';//利率指標
				
				//清除VIP資訊
				setVIPforAjax( 1 , false );
				
				controlInputs();

			}		
		},
		
		<%-- 重新產生報表 --%>
		Btn_reMakeReport : function(event){
			validForAPPLY_ID.clear();
			validForAPPLY_ID.reset();
			validForAPPLY_ID.define('validate-APPLY_ID_Q_11', 'APPLY_ID_Q');
			if(!validForAPPLY_ID.validate()){
				return;
			}
			ajaxPost( 'Reprint' , {APPLY_ID : $('APPLY_ID_Q').value } , function(resp){				
				
				});
		
			
		
		},
		<%--連結到影像新件掃描畫面--%>
		Btn_linkImageScan: function(event){
			validForAPPLY_ID.clear();
			validForAPPLY_ID.reset();
			validForAPPLY_ID.define('validate-APPLY_ID_Q_11', 'APPLY_ID_Q');
			if(!validForAPPLY_ID.validate()){
				return;
			}
		
			var APPLY_ID = $F('APPLY_ID_Q');
			/*if( APPLY_ID.length < 11 ){
				alert("請輸入正確的受理編號");
				return;
			}*/
			
			APPLY_ID = APPLY_ID.toUpperCase();
			$('APPLY_ID_Q').value = APPLY_ID;

			popupWin.windowOpen('/AVWeb/servlet/HttpDispatcher/AVB1_0200/prompt',{
				'parameters': {'APPLY_ID': APPLY_ID, 'LINK_FROM' : 'DSA10100'},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'},
				'windowName': 'DSA10100'
			});
		}
	};
	
	//房貸類型改變，畫面控制
	function LOAN_Changed( id , check){
		var section = $('section'+ id);
		if( check ){
			section.show();
		}else{
			section.hide();
		}
		var disable = !check;	
		section.select('input','select').each(function(elm){
			elm.disabled = disable;		
		});
		
		//一般型重新被勾選時，要重新觸發RETURN_TYPE改變
		if( id == 'LOAN_C' && check ){
			RETURN_TYPE_Changed($F('RETURN_TYPE'));
			
			//191219:法金件導入:承辦科別為法金科時，當房貸類型勾選一般型，一般型房貸中之貸款種類及優惠種類自動預設為法人金融貸款。
			if('Y' == isCORP_DEPT){
				$('LOAN_KIND').setValue('712');
				$('PROD_ID').setValue('712');
			}
			
		}			
	}
	
	//擔保種類改變，畫面控制
	function GAGE_TYPE_Changed( GAGE_TYPE ){
	
		var elms = address1.getAllSelectObject();
		var check = GAGE_TYPE != '1' && GAGE_TYPE != '3';	//非房地產及土地		 
		var CON_CODE_List = document.getElementsByName("CON_CODE");
		if(check){
			//通訊地址只能選擇 "其他如下"
			for( var i=0 ; i < CON_CODE_List.length ; i++ ){
				if( CON_CODE_List[i].value == "2" ){
					CON_CODE_List[i].checked = true;
					CON_CODE_List[i].disabled = false;
				}else{
					CON_CODE_List[i].disabled = true;
				}
			}
			CON_CODE_Changed( "2" );
		} else {
			for( var i=0 ; i < CON_CODE_List.length ; i++ ){
				CON_CODE_List[i].disabled = false;
			}			
		}
       
		<%-- [20191213] 若擔保品種類為「國內動產(5)」或「國外動產(7)」 --%>
		var check_SUB  = GAGE_TYPE == '5' || GAGE_TYPE == '7';	
		if(check_SUB){
		    $('GAGE_TYPE_SUB').show();
		} else {
			$('GAGE_TYPE_SUB').hide();			 
		}
		
		check = check || isNewQuery;
	
		for( var key in elms ){
			elms[key].disabled = check;
		}
		$('SPEC_AREA').disabled = check;
		
		if( check ){
			//只有擔保品地址不封鎖
			$('GAGE_ADDR').disabled = false;
		}
		
		//重設全形檢核
		resetHasFullTypeCheck();
	}
	
	//通訊地址改變，畫面控制
	function CON_CODE_Changed( CON_CODE , isChanged){
		if( CON_CODE == '1' ){
			$('DSZ01000_1').select('select').each(function(elm){
				elm.disabled = true;
			});
			$('CON_ZIP').readOnly = true;
			$('CON_ADDR').readOnly = true;	
			if( isChanged == true ){
				ajaxPost( 'getCON_ADDR' , { GAGE_ZIP : $F('GAGE_ZIP') , GAGE_ADDR : $F('GAGE_ADDR')  } , function(resp){
					//重新設定地址
					address2.setINPUT_ZIPCODE(resp.CON_ZIP);
					address2.setINPUT_ADDR(resp.CON_ADDR);
				});
			}
		}else{
			$('DSZ01000_1').select('select').each(function(elm){
				elm.disabled = false;
			});
			$('CON_ZIP').readOnly = false;
			$('CON_ADDR').readOnly = false;
		}
   }
   <%--[20220309] 綠色授信欄位連動--%>
   function GREEN_TYPE_Changed1(){
		  $('GREEN_TYPE').enable();
		  if ($F('GREEN_TYPE_YES_NO')=='0'){
			  $('GREEN_TYPE').setValue('');
			  $('GREEN_TYPE').disable();
			  $('ESG_TYPE_YES_NO').setValue('0');
			  $('ESG_TYPE_YES_NO').simulate('change');
		  }
		  //綠色授信為「是」且法人件欄位打勾者即可點選拉把，系統預帶「請選擇」，反之即帶入「否」且不可點選拉把。
		  if (($('COPR_CODE').checked)&&($F('GREEN_TYPE_YES_NO')=='1')){
			  $('ESG_TYPE_YES_NO').setValue('');
			  $('ESG_TYPE_YES_NO').simulate('change');
			  $('ESG_TYPE_YES_NO').enable();
		  }else{
			  $('ESG_TYPE_YES_NO').setValue('0');
			  $('ESG_TYPE_YES_NO').simulate('change');
			  $('ESG_TYPE_YES_NO').disable();
		  }
   }
   <%--[20220309] 綠色授信欄位連動--%>
   function GREEN_TYPE_Changed2(){
		  if (($F('LOAN_POS')=='03')&&($F('GREEN_TYPE_YES_NO')=='1')){
			  $('GREEN_TYPE').setValue('F');
		  }
    }
	<%--[20220309] 永續績效連結欄位連動--%>
	function ESG_TYPE_Changed1(){
		  $('ESG_TYPE').enable();
		  if ($F('ESG_TYPE_YES_NO')=='0' || $F('ESG_TYPE_YES_NO')==''){
			  $('ESG_TYPE').setValue('');
			  $('ESG_TYPE').disable();
		  }
	}
	<%--[20220309] 永續績效連結欄位連動--%>
	function ESG_TYPE_Changed2(){
		  $('ESG_TYPE_YES_NO').disable();
		  $('ESG_TYPE_YES_NO').setValue('0');
		  //綠色授信為「是」且法人件欄位打勾者即可點選拉把，系統預帶「請選擇」，反之即帶入「否」且不可點選拉把。
		  if (($('COPR_CODE').checked)&&($F('GREEN_TYPE_YES_NO')=='1')){
			  $('ESG_TYPE_YES_NO').setValue('');
			  $('ESG_TYPE_YES_NO').simulate('change');
			  $('ESG_TYPE_YES_NO').enable();
		  }
	}

	//檢查ADDR_NO是否有繁體的臺
  function replacetaiwan() {
   $('GAGE_ADDR').value=$('GAGE_ADDR').value.replace("臺北", "台北");
   $('GAGE_ADDR').value=$('GAGE_ADDR').value.replace("臺中", "台中");
   $('GAGE_ADDR').value=$('GAGE_ADDR').value.replace("臺南", "台南");
   $('GAGE_ADDR').value=$('GAGE_ADDR').value.replace("臺東", "台東");
  }
  
	//Reset Has Full Type Check 重設檢查是否有全形
	//檢核國外擔保品不輸經手人
	//若為國外擔保品，貸款種類選擇法人金融貸款	
  function resetHasFullTypeCheck() {
  	if($F('GAGE_TYPE') == '6' || $F('GAGE_TYPE') == '7'){
  		//190830:原住民導入-原借款人姓名欄不可為空
		$('BORROW_NAME').className = 'textBox2 required checkInputLength validate-Has_Full_Type';
		$('COUPLE_NAME').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('COMP_BANK').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('COMP_BRANCH').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('PREVIOUS_BORROW').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('SELL_NAME').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('COM_NAME').className = 'textBox2 checkInputLength validate-Has_Full_Type';
		$('GAGE_ADDR').className = 'checkInputLength validate-Has_Full_Type';
		$('CON_ADDR').className = 'checkInputLength validate-Has_Full_Type';
		$('BORROW_ID').className = 'textBox2 required';
		$('COUPLE_ID').className = 'textBox2 validate-COUPLE_ID1';
		$('GAGE_ADDR').blnToHalfType = true;
		$('CON_ADDR').blnToHalfType = true;
		//國外不動產指定郵遞區號
		//尚不支援擔保品為國外、聯絡人在國內的狀況，若有需求請單位再提申請書修改
		//避免後端檢核出錯，寫死郵遞區號
		if($F('GAGE_TYPE') == '6'){ 
			$('GAGE_ADDR').blnZIPCODE = '106';
		}
		$('CON_ADDR').blnZIPCODE = '10633';
		$('AGENT_ID').disabled = true;
		$('AGENT_ID').value = '';
		$('AGENT_NAME').innerHTML = '';
		$('AGENT1_ID').value = '';
		$('AGENT1_ID').disabled = true;
		$('AGENT1_NAME').innerHTML = '';
		$('ALWC_RATE1').innerHTML = '0%';
		$('ALWC_RATE').disabled = true;
		$('ALWC_RATE').setValue('100');
		
		$('LOAN_KIND').setValue('712');
		//$('ALWC_RATE').change();
	}else{
		//190830:原住民導入-原借款人姓名欄不可為空
		$('BORROW_NAME').className = 'textBox2 required checkInputLength hasFullType';
		$('COUPLE_NAME').className = 'textBox2 checkInputLength hasFullType';
		$('COMP_BANK').className = 'textBox2 checkInputLength hasFullType';
		$('COMP_BRANCH').className = 'textBox2 checkInputLength hasFullType';
		$('PREVIOUS_BORROW').className = 'textBox2 checkInputLength hasFullType';
		$('SELL_NAME').className = 'textBox2 checkInputLength hasFullType';
		$('COM_NAME').className = 'textBox2 checkInputLength hasFullType';
		$('GAGE_ADDR').className = 'checkInputLength hasFullType';
		$('CON_ADDR').className = 'checkInputLength hasFullType';
		$('BORROW_ID').className = 'textBox2 validate-BORROW_ID1 validate-BORROW_ID2';
		$('COUPLE_ID').className = 'textBox2 validate-COUPLE_ID1 validate-COUPLE_ID2';
		$('GAGE_ADDR').blnToHalfType = false;
		$('CON_ADDR').blnToHalfType = false;
		$('AGENT_ID').disabled = false;
	
		if(AGENT_DEPT == '720'){
			$('ALWC_RATE').disabled = true;							
		}else{
			$('ALWC_RATE').disabled = false;
		}									
	}
  }
	//貸款種類改變，畫面控制
	/*
	function LOAN_KIND_Changed( LOAN_KIND ){
		if( LOAN_KIND == '970' ){
			$('PREFER_TYPE').value = '14';
		}else if( LOAN_KIND == '971' ){
			$('PREFER_TYPE').value = '17';
		}else if( LOAN_KIND == '972' ){
			$('PREFER_TYPE').value = '43';
		}else if( LOAN_KIND == '973' ){
			$('PREFER_TYPE').value = '27';
		}else if( LOAN_KIND == '974' ){
			$('PREFER_TYPE').value = '23';
		}else if( LOAN_KIND == '976' ){
			$('PREFER_TYPE').value = '25';
		}
	}*/
	
	//還款方式改變，畫面控制
	function RETURN_TYPE_Changed( RETURN_TYPE ){
		if( RETURN_TYPE == '1'){
			$('FIX_YY').disabled = true;
			$('FIX_MM').disabled = true;
			$('SPR_YY').disabled = false;
			$('SPR_MM').disabled = false;
		}else if( RETURN_TYPE == '3'){
			$('FIX_YY').disabled = false;
			$('FIX_MM').disabled = false;
			$('SPR_YY').disabled = true;
			$('SPR_MM').disabled = true;
		}else if( RETURN_TYPE == '4'){
			$('FIX_YY').value = 0;
			$('FIX_MM').value = 0;
			$('FIX_YY').disabled = true;
			$('FIX_MM').disabled = true;
			$('SPR_YY').disabled = false;
			$('SPR_MM').disabled = false;
		}else{
			$('FIX_YY').disabled = false;
			$('FIX_MM').disabled = false;
			$('SPR_YY').disabled = false;
			$('SPR_MM').disabled = false;
		}
	}
	
	//法人件改變，畫面控制
	function COPR_CODE_Changed( COPR_CODE , APPLY_ID1 ){
		var check = !(COPR_CODE == true && (APPLY_ID1 == '06014' || APPLY_ID1 == '64002' || APPLY_ID1 == '72001' || APPLY_ID1 == '72006'));
		$('COPR2').disabled = check;
		$('COPR3').disabled = check;
		$('COPR4').disabled = check;
		$('COPR5').disabled = check;	
		$('SPC_DESC').disabled = !check;
	}
	
	//業績比例改變，畫面控制
	function ALWC_RATE_Changed( ALWC_RATE ){
		if( ALWC_RATE == '100' ){
			$('AGENT1_ID').value = '';
			$('AGENT1_ID').disabled = true;			
		}else{
			$('AGENT1_ID').disabled = false;
		}
		$('ALWC_RATE1').innerHTML = (100 - new Number(ALWC_RATE)) + "%";		
	}
	
	//二順位改變，畫面控制
	function SECOND_Changed( SECOND ){
		if( SECOND ){
			$('PRE_SET_AMT').readOnly = false;
		}else{
			$('PRE_SET_AMT').value = "0";
			$('PRE_SET_AMT').readOnly = true;			
		}
	}
	
	//優惠種類改變，連動貸款種類
	function PREFER_TYPE_Changed( id , LOAN_KIND ){
		if( id == "PREFER_TYPE_M" ){
			$("LOAN_KIND_M").value = LOAN_KIND;
		}else{
			$("LOAN_KIND").value = LOAN_KIND;
		}
	}
	
	//[借款主用途-代償],連動[前行庫用途]
	//[借款主用途-購買保險],連動[本次借款用途為『購買保險』]
	function LOAN_POS_Changed(BUY_INSURANCE){
		var LOAN_POSvalue = $F('LOAN_POS');
	    if( LOAN_POSvalue == '01'){ 
	        $('LOAN_POS01').disabled = false;      
	        
			if(BUY_INSURANCE=='1'){
				$('BUY_INSURANCE').checked = true; 
			}else{
				$('BUY_INSURANCE').checked = false; 
			}                             
	        $('BUY_INSURANCE').enable();     
			//doGetLOAN_POS01Map();	
		}else if( LOAN_POSvalue == '11'){//借款用途為"購買保險"，預設勾選"本次借款用途為『購買保險』"
			$('LOAN_POS01').disabled = true;  
			$('LOAN_POS01').value="";      
			  
	        $('BUY_INSURANCE').checked = true;   
	        $('BUY_INSURANCE').disable();                            
		}else{		    
			$('LOAN_POS01').disabled = true;     
			$('LOAN_POS01').value="";
			
			if(BUY_INSURANCE=='1'){
				$('BUY_INSURANCE').checked = true; 
			}else{
				$('BUY_INSURANCE').checked = false; 
			}
	        $('BUY_INSURANCE').enable(); 
		}
	    
	    //[20220309] 修改件：申請書220221003565-調整聯徵授信餘額月報資料檔案格式(代號:B201):
	    //「綠色授信」為是時， LOAN_POS=買車，綠色支出類別預帶「F.潔淨交通運輸」，但如果LOAN_POS改成其他的，再預帶回"請選擇"
	    if( LOAN_POSvalue == '03' && $F('GREEN_TYPE_YES_NO')=='1'){
	    	$('GREEN_TYPE').setValue('F');
	    }else{
	    	//$('GREEN_TYPE').setValue('');
	    }
	    //若借款主用途為「投資」，則「說明框」預帶"投資"；若借款主用途為「業務週轉(公司)」或「個人週轉」，則「說明框」預帶"週轉"
	    if( !$F('LOAN_POS_OTHER') ){
	    	if( '06' == LOAN_POSvalue ){
	    		$('LOAN_POS_OTHER').value = "投資";
	    	}else if( '07' == LOAN_POSvalue || '09' == LOAN_POSvalue){
	    		$('LOAN_POS_OTHER').value = "週轉";
	    	}
	    }
	}
	
	//[申請書220606065713]自動徵審:「理財型借款主用途」為「代償」時為必輸值，初始值預設「請選擇」，其餘借款主用途反灰不得選擇
	function LOAN_POS_M_Changed(){
		var LOAN_POS_Mvalue = $F('LOAN_POS_M');
		<%--if( LOAN_POS_Mvalue == '01'){ 
	        $('LOAN_POS01_M').disabled = false;      
		}else{		    
			$('LOAN_POS01_M').disabled = true;     
			$('LOAN_POS01_M').value="";
		}--%>
	    //若借款主用途為「投資」，則「說明框」預帶"投資"；若借款主用途為「業務週轉(公司)」或「個人週轉」，則「說明框」預帶"週轉"
	    if( !$F('LOAN_POS_OTHER_M') ){
	    	if( '06' == LOAN_POS_Mvalue ){
	    		$('LOAN_POS_OTHER_M').value = "投資";
	    	}else if( '07' == LOAN_POS_Mvalue || '09' == LOAN_POS_Mvalue){
	    		$('LOAN_POS_OTHER_M').value = "週轉";
	    	}
	    }
	}
	
	//[借款主用途-代償],連動[前行庫用途]
	/*function doGetLOAN_POS01Map(){
		$('LOAN_POS01').options.length = 1;
		var LOAN_POS = $F('LOAN_POS');
		if(!LOAN_POS){
			return;
		}
				
		//發送ajax
	     	ajaxPost( 'getLOAN_POS01List' , { LOAN_POS : $F('LOAN_POS') } , 
				function(resp){	
					var LOAN_POS01_List = resp.LOAN_POS01_List ? resp.LOAN_POS01_List : [];
					createLOAN_POS01_Select(resp.LOAN_POS01_List);
				},
				function(resp){					
					//失敗把前次內容清掉 
				}
		);		
	}
	
	//建立[前行庫用途]選單
	function createLOAN_POS01_Select(optList){		
		if(optList){
			for(var i=0; i<optList.length; i++){ 				
	    		$('LOAN_POS01').options.add(new Option(list[i]['value'], list[i]['key'])); 
			}
		}	
	}*/
	
	//輸入完後自動轉大寫的事件
	function toUpperCaseField( event ){
		event.target.value = event.target.value.toUpperCase();
	}
	
	<%-- [20191213] 增加 案件架構(CASE_STRUCT)】、【幣別(CURR)】連動：--%>
	function CASE_STRUCT_Changed( CASE_STRUCT , CURR ){
   	
		//清空
		
		if( CASE_STRUCT == '1'){ //案件架構=自貸(1)
		   // Disable：主辦銀行家數與說明、信用評等皆BBB+以上、總聯貸金額、管理銀行
           // Enable：幣別、利率指標、是否為主要受編、拆件受編、拆件原因
           $w('UNION_BANK_NUM UNION_BANK_MEMO UNION_LOAN_AMT MANAGER_BANK ').each(function(eleid){
           		$(eleid).setValue('');
           		$(eleid).disable();
           });
			setRadioValue("CRED_RATE_BBB" , "");//信用評等皆BBB+以上
			setRadioDisable('CRED_RATE_BBB',true);
			
			<%-- 幣別(CURR) = 「台幣(NTD)」，「利率指標」預設為「(5)」--%>
			if(CURR == 'NTD'){
			   $('INTEREST_RT_TP').value = '5';//利率指標
			}
		}else if( CASE_STRUCT == '2'){ //案件架構=聯貸(2)
			if(CURR == 'NTD'){
			    // Disable：信用評等皆BBB+以上               
				setRadioValue("CRED_RATE_BBB" , "");//信用評等皆BBB+以上
				setRadioDisable('CRED_RATE_BBB',true);//信用評等皆BBB+以上
			} else {
				setRadioDisable('CRED_RATE_BBB',false);//信用評等皆BBB+以上
			}
            // Enable：主辦銀行家數與說明、總聯貸金額、管理銀行、幣別、利率指標、是否為主要受編、拆件受編、拆件原因			
			$w('UNION_BANK_NUM UNION_BANK_MEMO UNION_LOAN_AMT MANAGER_BANK ').each(function(eleid){
           		$(eleid).enable();
           });		
		} 
		 
	}
	
	<%-- [20221121] 變更借款人 生日or成立日期 --%>
	function changeBirthdayHeader() {
		
		var BORROW_ID = $F('BORROW_ID');
		if (BORROW_ID && BORROW_ID.length == 8) {
			$('BIRTHDAY_HEADER').update('成立日期');
		} else {
			$('BIRTHDAY_HEADER').update('生日');
		}
	}

	<%-- [20221121] 計算借款人年齡 --%>
	function getAge() {
		getLawAge('AGE', 'BIRTHDAY');
	}
	
	<%-- [20221121] 計算配偶/負責人年齡 --%>
	function getCoupleAge() {
		getLawAge('COUPLE_AGE', 'COUPLE_BIRTH');
	}
	
	<%-- [20221121] 計算年齡 --%>
	function getLawAge(ageId, birthdayId) {

		var ageObj = $(ageId);
		ageObj.setValue('');

		var BIRTHDAY = $F(birthdayId);
		if (!BIRTHDAY || !isROCdate(BIRTHDAY, false)) {
			return;
		}

		ajaxPost('getLawAge', {BIRTHDAY : BIRTHDAY, APPLY_DATE : toY2K($('APPLY_DATE').innerHTML)}
			, function(resp) {				
				ageObj.setValue(resp.age);
			});
	}
	<%-- [20241107]社會責任授信--%>
	function CSR_TYPE_Changed(){
		var isY = $F('CSR_TYPE_YES_NO') != '0';
		$w('CSR_TYPE CSR_TA CSR_RESP').each(function(id){
			if(!isY){
				$(id).setValue('');
				$(id).disable();
			}else{
				$(id).enable();
			}
		});
	}
	<%-- [20241107]借款人ID連動--%>
	function BORROW_ID_Changed(){
		changeBirthdayHeader();		
		var BORROW_ID = $F('BORROW_ID');
		var isEmpty = $F('CSR_TYPE_YES_NO') == '';
		if($F('CSR_TYPE') == '' && (BORROW_ID.length == 0 || BORROW_ID.length == 10)){
			$('CSR_TYPE_YES_NO').setValue('0');
			$('CSR_TYPE_YES_NO').simulate('change');
		}
	}
	

	return{
	
		init:function(){
			//Button事件註冊
			$('Btn_add','Btn_addLoan','Btn_clear','Btn_delete','Btn_imageChange','Btn_linkImage','Btn_query','Btn_queryNewLoan','Btn_update','Btn_reMakeReport','Btn_linkImageScan').each(function(elm){
				elm.observe('click', btnActions[elm.id] );
			});
			
			//以下欄位英文字要自動轉大寫
			$('BORROW_ID','AGENT1_ID','AGENT_ID','SELL_ID','COUPLE_ID','REFER_ID_Q','IS_SEPARATE').each(function(elm){
				elm.observe('change', toUpperCaseField ); 
			});
			
			//房貸類型勾選事件
			$('LOAN_C','LOAN_M').each(function(elm){
				elm.observe('click', function( event){
					var id = event.target.id;
					var check = event.target.checked;
					LOAN_Changed( id , check );
				});
			});		
			
			
			$('LOAN_POS').observe('change',LOAN_POS_Changed);
			$('LOAN_POS_M').observe('change',LOAN_POS_M_Changed);
			
			//擔保種類選擇事件
			$('GAGE_TYPE').observe('change', function(event){
				GAGE_TYPE_Changed( event.target.value );
			});
			
			//通訊地址所有權人選擇事件
			$('OWN_CODE').observe('change', function(event){
				if( event.target.value =='3'){//其他
					$('OWN_CODE_CONTENT').style.display="block";
				}else{
					$('OWN_CODE_CONTENT').style.display="none";
					$('OWN_CODE_CONTENT').value="";
				}
			});
			
			//通訊地址選擇事件
			$$('input[type="radio"][name="CON_CODE"]').each(function(elm){
				elm.observe('click', function(event){
					CON_CODE_Changed( event.target.value , true );
				});	
			});			
			/*
			//貸款種類：	先拿掉~暫時不做
			$('LOAN_KIND').observe('change', function(event){
				LOAN_KIND_Changed( event.target.value );
			});
			*/
			//還款方式
			$('RETURN_TYPE').observe('change' , function(event){
				RETURN_TYPE_Changed( event.target.value );
			});			
			
			//法人件
			$('COPR_CODE').observe('click', function(event){
				COPR_CODE_Changed( event.target.checked , $F('APPLY_ID1') ); 
			});
			
			//銀行名稱
			$('SELECT_BANK').observe('change', function(event){
				if( event.target.value != '其他' ){
					$('COMP_BANK').value = event.target.value;
				}
			});
			
			//業績比例
			$('ALWC_RATE').observe('change', function(event){
				ALWC_RATE_Changed( event.target.value );
			});
			
			//二順位
			$('SECOND').observe('click', function(event){
				SECOND_Changed(event.target.checked);
			});
			
			//優惠種類
			$('PROD_ID','PREFER_TYPE_M').each(function(elm){
				elm.observe('change', function(event){
					PREFER_TYPE_Changed( event.target.id , event.target.options[event.target.selectedIndex].getAttribute("data-LOAN_KIND") );
				});
			});
			
			//第一經手人  220104002089 放款部人員為經手人，不得掛第二經手人以受理單位為放款部卡控經手人資格
			$('AGENT_ID').observe('change', function(event){
				if($F('AGENT_ID')){
					ajaxPost( 'checkAgentId' , { AGENT_ID : $F('AGENT_ID') } , function(resp){
						AGENT_DEPT = resp.AGENT_DEPT;								
						if(AGENT_DEPT == '720'){
							$('ALWC_RATE').value = "100";
							$('ALWC_RATE').disabled = true;							
						}else{
							$('ALWC_RATE').disabled = false;
						}						
						ALWC_RATE_Changed( $F('ALWC_RATE'));										
					});
				}				
			});
			
			<%-- [20191213] 增加 案件架構(CASE_STRUCT)】、【幣別(CURR)】連動：--%>
			$('CASE_STRUCT','CURR').each(function(elm){
				elm.observe('change', function(event){
					CASE_STRUCT_Changed( $F('CASE_STRUCT') , $F('CURR') );				 
				});
			});
			
			<%--[20220309] 綠色授信、永續績效連結欄位事件註冊--%>
			$('GREEN_TYPE_YES_NO').observe('change',GREEN_TYPE_Changed1);
			$('GREEN_TYPE_YES_NO').observe('change',GREEN_TYPE_Changed2);
			$('LOAN_POS').observe('change',GREEN_TYPE_Changed2);
			$('ESG_TYPE_YES_NO').observe('change',ESG_TYPE_Changed1); 
			$('COPR_CODE').observe('change',ESG_TYPE_Changed2);
			$('GREEN_TYPE_YES_NO').observe('change',ESG_TYPE_Changed2);										  
			
			<%-- [20221121] 變更生日or成立日期 [20241107]+連動社會責任授信--%>
			$('BORROW_ID').observe('change', BORROW_ID_Changed );
			$('BORROW_ID').simulate('change');

			<%-- [20221121] 計算年齡 --%>
			$('BIRTHDAY').observe('change', getAge);
			$('COUPLE_BIRTH').observe('change', getCoupleAge);
			
			<%--[20241107]社會責任授信--%>
			$('CSR_TYPE_YES_NO').observe('change', CSR_TYPE_Changed);

			//理財型優惠種類預設適用區間之理財型商品
			$('PREFER_TYPE_M').value = "${PROD_ID_M}";
			
			address1 = new DSZ01000( "DSZ01000" , "1");    //產生地址選擇器 (擔保品資料)
			address2 = new DSZ01000( "DSZ01000_1" , "2");  //產生地址選擇器 (通訊地址)
			var select = document.createElement('select');	  //產生非澄特區選單
			select.id = "SPEC_AREA";
			JSONUtil.addOptions2( select , SPEC_AREA_List );
			var selects = $('DSZ01000').select('select');
			Element.insert( selects[selects.length-1] , { after : select } );			
			Element.insert( select , { after : '<span style="color:red">—房地產，土地請輸入正確縣市鄉鎮資料</span>' } );

			var inputs = $('DSZ01000').select('input');	
			inputs[0].id = 'GAGE_ZIP';
			inputs[1].id = 'GAGE_ADDR';
			inputs[1].className = "checkInputLength";
			inputs[1].maxLength = "200"
			inputs[1].setAttribute( "fieldName" , "擔保品資料_地址" );
			inputs[1].setAttribute( "alt", "ch" );<%--[20240722]難字調整 --%>
			
			inputs = $('DSZ01000_1').select('input');	
			inputs[0].id = 'CON_ZIP';
			inputs[1].id = 'CON_ADDR';
			inputs[1].className = "checkInputLength";
			inputs[1].maxLength = "80"
			inputs[1].setAttribute( "fieldName" , "通訊地址_地址" );
			inputs[1].setAttribute( "alt", "ch" );<%--[20240722]難字調整 --%>			
			
			//銀行名稱預設其他
			$('SELECT_BANK').value = "其他";
			//業績比例預設100%
			$('ALWC_RATE').value = "100";					
			setRadioValue( "FAST_AGREE" , "X");
			setRadioValue( "IMAGE_EDIT_AUTH" , "X");
			
				
			//初始檢核
			initValidation();
			
			//初始化欄位狀態
			controlInputs();
			
			//抓取前端傳過來的值
			var APPLY_ID = '${APPLY_ID}';			
			if ( APPLY_ID == "") {
				//保留參數管理-取得受理編號
				APPLY_ID = CSRUtil.keepParamsManager.get('APPLY_ID');
			}	
			
			if( CSRUtil.isBackLink('formQ') ){
				btnActions["Btn_query"]();
				return;
			}
			
			<%-- [20191213] 增加 --%>
			isCORP_DEPT = '${isCORP_DEPT}';  
			if( APPLY_ID ){
				$('APPLY_ID_Q').value = APPLY_ID;
				$('APPLY_ID1').value = APPLY_ID.substring(0 , 5 );
				btnActions["Btn_query"]();			
			}else{
				$('APPLY_ID_Q').value = "${defaultMap.DIV_NO}".substring(0,5);
				$('APPLY_ID1').value = "${defaultMap.DIV_NO}".substring(0,5);
				<%-- [20191213] 增加 --%>
				if(isCORP_DEPT == 'Y'){
					sectionLOAN_UNION.show();
					$('CURR').value = 'NTD'; //幣別
					$('CASE_STRUCT').simulate('change');
				} else {
					sectionLOAN_UNION.hide();
				}
			}
			
			<%--[20221223] 本金彈性還期間強制輸入數字 --%>
            autoFormatToNumber();
            <%--[20221223] 本金彈性還連動--%>
            $$('input[name="IS_FLEX_NM"]').forEach(function(ele) {
                ele.observe('change', function(e) {
                    var isShow = this.value == 'Y';
                    $('TD_FLEX_PERIOD').select('span, input').forEach(function(it) {
                        if (isShow) {
                            it.show();
                        } else {
                            it.hide();
                        }
                    });
                });
                if (ele.checked) {
                    ele.simulate('change');
                }
            });
			
			//重設全形檢核
			resetHasFullTypeCheck();
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}
//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA" style="display:none;">
	<form name="formQ" id="formQ" >
		<tr>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2" width="15%">
				<input type="text" name="APPLY_ID_Q" id="APPLY_ID_Q" class="textBox2" maxLength="11" size="15" value="" />
				<input type="hidden" name="APPLY_ID1" id="APPLY_ID1" class="textBox2" maxLength="5" size="10" value="" />
			</td>
			<td class="tbYellow" width="10%">前貸款帳號</td>	
			<td class="tbYellow2" width="25%">
				<input type="text" name="REFER_ID_Q" id="REFER_ID_Q" class="textBox2" maxLength="10" size="12" value="" />—增貸需輸入
			</td>												
			<td class="tbYellow2" align="center" width="40%">
				<input id="Btn_query" name="Btn_query" type="button" class="button" value="查詢" />
				<input id="Btn_queryNewLoan" name="Btn_queryNewLoan" type="button" class="button" value="增貸查詢" /> 	
				<input id="Btn_linkImage" name="Btn_linkImage" type="button" class="button" value="影像連結" />
				<input id="Btn_reMakeReport" name="Btn_reMakeReport" type="button" class="button" value="申請書置換" />
				<input id="Btn_linkImageScan" name="Btn_linkImageScan" type="button" class="button" value="影像掃描" />
			</td>	
		</tr>
		<tr >
			<td colSpan="5" align="center">
				<input id="Btn_clear" name="Btn_clear" type="button" class="button" value="清除" />
				<input id="Btn_add" name="Btn_add"   type="button" class="button" value="新增" /> 	
				<input id="Btn_update" name="Btn_update" type="button" class="button" value="修改" />
				<input id="Btn_delete" name="Btn_delete"   type="button" class="button" value="刪除" /> 													
			</td>
		</tr>
	</form> 
</table>
	
	<form name="form2" id="form2" ></form>
	<form name="form1" id="form1">
	<input type="hidden" id="APPLY_PROCESS" name="APPLY_PROCESS" value="" />
	<input type="hidden" id="CRED_ID" name="CRED_ID" value="" />
	<input type="hidden" id="GFS_SCORE" name="GFS_SCORE" value="" />
	<input type="hidden" id="A010_INPUT_ID" name="A010_INPUT_ID" value="" />
	<input type="hidden" id="SEPARATE_TYPE" name="SEPARATE_TYPE" value="" />
	<input type="hidden" id="INPUT_ID" name="INPUT_ID" value="" />
	<input type="hidden" id="INPUT_NAME" name="INPUT_NAME" value="" />
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB" style="display:none;">
	<tr>
		<td class="tbYellow" width="13%">受理編號</td>
		<td class="tbYellow2" width="25%">
			<div id="APPLY_ID" ></div>
		</td>
		<td class="tbYellow" width="10%">受理進度</td>												
		<td class="tbYellow2" >
			<div id="APPLY_PROCESS_NM" ></div>													
		</td>	
		<td class="tbYellow">法人件</td>												
		<td class="tbYellow2" >
			<input type="checkbox" name="COPR_CODE" id="COPR_CODE" value="1" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow">影像置換</td>
		<td class="tbYellow2">
			是<input type="radio" name="IMAGE_EDIT_AUTH" value="A"/>
			否<input type="radio" name="IMAGE_EDIT_AUTH" value="X"/>
			<input type="button" class="button" value="變更" id="Btn_imageChange" />
		</td>
		<td class="tbYellow">快速增貸</td>												
		<td class="tbYellow2" >
			是<input type="radio" name="FAST_AGREE" value="A" />
			否<input type="radio" name="FAST_AGREE" value="X" />
			<input type="button" class="button" value="變更" id="Btn_addLoan" />
		</td>
		<td class="tbYellow" width="16%">二順位</td>												
		<td class="tbYellow2" width="12%">
			<input type="checkbox" id="SECOND" name="SECOND" value="1" />
		</td>			
	</tr>
	<tr>
		<td class="tbYellow">房貸類型</td>
		<td class="tbYellow2">
			<input type="checkbox" name="LOAN_C" id="LOAN_C" value="1" />一般型
			<input type="checkbox" name="LOAN_M" id="LOAN_M" value="1" />理財型
		</td>
		<td class="tbYellow">貸款類別</td>												
		<td class="tbYellow2" width="24%">
			<select name="LOAN_TYPE" id="LOAN_TYPE">
			<c:forEach var="map" items="${LOAN_TYPE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow">前順位設定金額</td>												
		<td class="tbYellow2">
			<input type="text" name="PRE_SET_AMT" fieldName="前順位設定金額" id="PRE_SET_AMT" class="textBox2 validate-number" size="8" value="" />萬
		</td>									
	</tr>
	<tr>
		<td class="tbYellow">客戶類型</td>
		<td class="tbYellow2">
			<select name="VIP_CUSTOMER" id="VIP_CUSTOMER">
			<c:forEach var="map" items="${VIP_CUSTOMER_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow">地段類別</td>												
		<td class="tbYellow2">
			<select name="VIP_AREA" id="VIP_AREA">
			<c:forEach var="map" items="${VIP_AREA_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow">首月免息</td>												
		<td class="tbYellow2">
			是<input type="radio" name="REMISSION_INT" value="1" />
			否<input type="radio" name="REMISSION_INT" value="0" />
		</td>											
	</tr>
	<tr>
		<td class="tbYellow">優質等級</td>
		<td class="tbYellow2">
			<select name="VIP_GRADE" id="VIP_GRADE">
			<c:forEach var="map" items="${VIP_GRADE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow">擔保種類</td>												
		<td class="tbYellow2">
			<select name="GAGE_TYPE" id="GAGE_TYPE">
			<c:forEach var="map" items="${GAGE_TYPE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			<%-- [20190626] 增加 擔保種類(補充) --%>
			<select name="GAGE_TYPE_SUB" id="GAGE_TYPE_SUB">
				<c:forEach var="map" items="${GAGE_TYPE_SUB_List}">
				<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">搭配貨</td>												
		<td class="tbYellow2">
			<input type="checkbox" name="BANK_SECOND" id="BANK_SECOND" disabled/>
		</td>												
	</tr>
	<%--[20220714]調整版面--%>
	<tr>
		<%--[20220309] 新增綠色授信、綠色支出類別、永續績效連結和永續績效連結類別下拉選單--%>
		<td class="tbYellow">綠色授信</td>
		<td class="tbYellow2" >
			<select name="GREEN_TYPE_YES_NO" id="GREEN_TYPE_YES_NO">
			  <option value="" >請選擇</option>
			  <c:forEach var="map" items="${GREEN_TYPE_YES_NO_List}">
			    <option value="${map.key}">${map.value}</option>
			  </c:forEach>
			</select>
		</td>
		<td class="tbYellow">綠色支出類別</td>												
		<td class="tbYellow2">
		  <select name="GREEN_TYPE" id="GREEN_TYPE" style="width:300px">
		    <option value="" >請選擇</option>
			<c:forEach var="map" items="${GREEN_TYPE_List}">
			  <option value="${map.key}" style="width:300px; overflow: hidden; white-sapce: no-wrap;">${map.value}</option>
			</c:forEach>
		  </select>
		</td>	
		<td class="tbYellow">本次借款用途為「購買保險」</td>												
		<td class="tbYellow2">
			<input type="checkbox" name="BUY_INSURANCE" id="BUY_INSURANCE" value="1"/>
		</td>																								
	</tr>
	<tr>
		<td class="tbYellow">永續績效連結</td>
		<td class="tbYellow2" >
			<select name="ESG_TYPE_YES_NO" id="ESG_TYPE_YES_NO">
			  <option value="" >請選擇</option>
			  <c:forEach var="map" items="${ESG_TYPE_YES_NO_List}">
			    <option value="${map.key}">${map.value}</option>
			  </c:forEach>
			</select>
		</td>
		<td class="tbYellow">永續績效連結類別</td>												
		<td class="tbYellow2">
		  <select name="ESG_TYPE" id="ESG_TYPE">
		    <option value="" >請選擇</option>
			  <c:forEach var="map" items="${ESG_TYPE_LIST}">
			    <option value="${map.key}">${map.value}</option>
			  </c:forEach>
		  </select>
		</td>			
		<td class="tbYellow">有巢氏</td>												
		<td class="tbYellow2">
			<select name="INSURANCE_KIND" id="INSURANCE_KIND" disabled>
			</select>
		</td>																								
	</tr>
	<%--[20241107] 新增社會責任授信註記欄位--%>	
	<tr>	
		<td class="tbYellow">社會責任授信</td>
		<td class="tbYellow2" >
			<select name="CSR_TYPE_YES_NO" id="CSR_TYPE_YES_NO">
			  <option value="" >請選擇</option>
			  <c:forEach var="map" items="${ESG_TYPE_YES_NO_List}">
			    <option value="${map.key}">${map.value}</option>
			  </c:forEach>
			</select>
		</td>
		<td class="tbYellow">社會責任專案類別</td>												
		<td class="tbYellow2" colspan='3'>
		  <select name="CSR_TYPE" id="CSR_TYPE" style="width:300px">
		    <option value="" >請選擇</option>
			  <c:forEach var="map" items="${CSR_TYPE_LIST}">
			    <option value="${map.key}" style="width:300px; overflow: hidden; white-sapce: no-wrap;">${map.value}</option>
			  </c:forEach>
		  </select>
		</td>																						
	</tr>
	<tr>	
		<td class="tbYellow">社會責任專案目標族群</td>
		<td class="tbYellow2" >
			<select name="CSR_TA" id="CSR_TA" style="width:300px">
			  <option value="" >請選擇</option>
			  <c:forEach var="map" items="${CSR_TA_LIST}">
			    <option value="${map.key}" style="width:300px; overflow: hidden; white-sapce: no-wrap;">${map.value}</option>
			  </c:forEach>
			</select>
		</td>
		<td class="tbYellow">承作社會專案責任者</td>												
		<td class="tbYellow2" colspan='3'>
		  <select name="CSR_RESP" id="CSR_RESP" style="width:300px">
		    <option value="" >請選擇</option>
			  <c:forEach var="map" items="${CSR_RESP_LIST}">
			    <option value="${map.key}" style="width:300px; overflow: hidden; white-sapce: no-wrap;">${map.value}</option>
			  </c:forEach>
		  </select>
		</td>																						
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="sectionLOAN_C" style="display:none;">
	<tr>
		<td class="tbBlue textBold" width="100%" colSpan="6" >一般型房貸</td>
	</tr>
	<tr>
		<td class="tbYellow" width="13%">貸款種類</td>
		<td class="tbYellow2" width="30%">
			<select name="LOAN_KIND" id="LOAN_KIND">
			<c:forEach var="map" items="${LOAN_KIND_List}">
			<option value="${map.key}" >${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">優惠種類</td>												
		<td class="tbYellow2" width="24%" colSpan="3">
			<select name="PROD_ID" id="PROD_ID">
			<c:forEach var="PREFER_TYPE" items="${PREFER_TYPE_List}">
			<option value="${PREFER_TYPE.PROD_ID}" data-LOAN_KIND="${PREFER_TYPE.LOAN_KIND}">${PREFER_TYPE.PROD_NAME}</option>
			</c:forEach>
			</select>
		</td>	
	</tr>
	<tr>
		<td class="tbYellow">借款金額</td>
		<td class="tbYellow2">
			<input type="text" name="LOAN_AMT" id="LOAN_AMT" fieldName="借款金額(一般型房貸)" class="textBox2 required" size="10" value="" />萬元
		</td>
		<td class="tbYellow">還款方式</td>												
		<td class="tbYellow2" colSpan="3">
			<select name="RETURN_TYPE" id="RETURN_TYPE">
			<c:forEach var="map" items="${RETURN_TYPE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			<br>定期
			<input type="text" name="FIX_YY" size="5" id="FIX_YY" value="" class="textBox2" />
			年
			<input type="text" name="FIX_MM" size="5" id="FIX_MM" value="" class="textBox2" />
			月+分期
			<input type="text" name="SPR_YY" size="5" id="SPR_YY" value="" class="textBox2" />
			年
			<input type="text" name="SPR_MM" size="5" 	id="SPR_MM" value="" class="textBox2" />
			月
		</td>											
	</tr>
	<tr>
		<td class="tbYellow">政府優惠</td>
		<td class="tbYellow2">
			<select name="GOVER_TRANS" id="GOVER_TRANS">
			<c:forEach var="map" items="${GOVER_TRANS_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<%--[20221223] 增-本金彈性還--%>
        <td class="tbYellow">本金彈性還</td>
        <td class="tbYellow2">
			是<input type="radio" id="IS_FLEX_NM_Y" name="IS_FLEX_NM" value="Y" class="">
           	 否<input type="radio" id="IS_FLEX_NM_N" name="IS_FLEX_NM" value="N" class="" checked>
        </td>
	</tr>
	<%--[20220714]調整版面--%>
	<tr>
		<td class="tbYellow">借款主用途</td>
		<td class="tbYellow2">
			<select name="LOAN_POS" id="LOAN_POS" class="required" fieldName="借款主用途" >
			<option value="">請選擇</option>
			<c:forEach var="map" items="${LOAN_POS_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			前行庫用途
			<select name="LOAN_POS01" id="LOAN_POS01" fieldName="前行庫用途" disabled >
			<option value="">請選擇</option>
			<c:forEach var="map" items="${LOAN_POS01_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			說明：
			<input type="text" name="LOAN_POS_OTHER" id="LOAN_POS_OTHER" fieldName="借款主用途_說明" class="textBox2 hasFullType" value="" maxLength="20" />
		</td>
		<%--[20221223] 增-本金彈性還期間--%>
        <td class="tbYellow">本金彈性還期間</td>
        <td class="tbYellow2" id="TD_FLEX_PERIOD">
            <span>第</span><input type="text" id="FLEX_PERIOD_B" name="FLEX_PERIOD_B" datatype="number" pattern="#,###" class="textBox2" maxlength="3" size="5" />
            <span>-</span><input type="text" id="FLEX_PERIOD_E" name="FLEX_PERIOD_E" datatype="number" pattern="#,###" class="textBox2" maxlength="3" size="5" />
            <span>期</span>
        </td>																							
	</tr>
	<tr>
		<td class="tbYellow">借款次用途</td>
		<td class="tbYellow2" colSpan="5">
			<select name="LOAN_POS2" id="LOAN_POS2">
			<option value="" >請選擇</option>
			<c:forEach var="map" items="${LOAN_POS_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			說明：
			<input type="text" name="LOAN_POS2_OTHER" id="LOAN_POS2_OTHER" value="" fieldName="借款次用途_說明" class="textBox2 hasFullType" maxLength="20" />
		</td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="sectionLOAN_M" style="display:none;">
	<tr>
		<td class="tbBlue textBold" width="100%" colSpan="6">理財型房貸</td>
	</tr>
	<tr>
		<td class="tbYellow" width="13%">貸款種類</td>
		<td class="tbYellow2" width="22%">
			<select name="LOAN_KIND_M" id="LOAN_KIND_M">
			<c:forEach var="map" items="${LOAN_KIND_M_List}">
			<option value="${map.key}" >${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="12%">優惠種類</td>												
		<td class="tbYellow2"  width="21%">
			<select name="PREFER_TYPE_M" id="PREFER_TYPE_M">
			<c:forEach var="PREFER_TYPE_M" items="${PREFER_TYPE_M_List}">
			<option value="${PREFER_TYPE_M.PROD_ID}" data-LOAN_KIND="${PREFER_TYPE_M.LOAN_KIND}">${PREFER_TYPE_M.PROD_NAME}</option>
			</c:forEach>
			</select>
		</td>	
		<td class="tbYellow" width="16%">申請電子化交易</td>												
		<td class="tbYellow2" width="20%">
			<input type="checkbox" id="ATM_CODE" name="ATM_CODE" value="1" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow">借款金額</td>
		<td class="tbYellow2">
			<input type="text" id="LOAN_AMT_M" name="LOAN_AMT_M" fieldName="借款金額(理財型房貸)" class="textBox2 required" size="10" value=""/>萬元
		</td>
		<td class="tbYellow">理財連結帳號</td>												
		<td class="tbYellow2">
			國泰世華銀行帳號<br><input type="text" id="MM_ACCOUNT" name="MM_ACCOUNT" class="textBox2" />
		</td>
		<td class="tbYellow">優質等級</td>												
		<td class="tbYellow2">
			<select name="VIP_GRADE_M" id="VIP_GRADE_M">
			<c:forEach var="map" items="${VIP_GRADE_M_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>												
	</tr>
	<%--[20220714]增-借款主用途/借款次用途--%>
	<tr>
		<td class="tbYellow">借款主用途</td>
		<td class="tbYellow2" colSpan="5">
			<select name="LOAN_POS_M" id="LOAN_POS_M" class="required" fieldName="借款主用途" >
			<option value="">請選擇</option>
			<c:forEach var="map" items="${LOAN_POS_M_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			前行庫用途
			<select name="LOAN_POS01_M" id="LOAN_POS01_M" fieldName="前行庫用途" disabled >
			<option value="">請選擇</option>
			<c:forEach var="map" items="${LOAN_POS01_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			說明：
			<input type="text" name="LOAN_POS_OTHER_M" id="LOAN_POS_OTHER_M" fieldName="借款主用途_說明" class="textBox2 hasFullType" value="" maxLength="20" />
		</td>																							
	</tr>
	<tr>
		<td class="tbYellow">借款次用途</td>
		<td class="tbYellow2" colSpan="5">
			<select name="LOAN_POS2_M" id="LOAN_POS2_M">
			<option value="" >請選擇</option>
			<c:forEach var="map" items="${LOAN_POS2_M_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
			說明：
			<input type="text" name="LOAN_POS2_OTHER_M" id="LOAN_POS2_OTHER_M" value="" fieldName="借款次用途_說明" class="textBox2 hasFullType" maxLength="20" />
		</td>
	</tr>
</table>
<%-- [20190626] 增加羅馬拼音欄位+調整部分欄位順序 --%>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
	<tr>
		<td class="tbYellow" width="9%" rowSpan="4">借款人</td>
		<td class="tbYellow" width="10%">姓名</td>
		<td class="tbYellow2" width="25%">
			<input type="text" id="BORROW_NAME" name="BORROW_NAME" maxlength="100" fieldName="借款人_姓名" class="textBox2 hasFullType" alt="ch"/><%--[20240722]難字調整 --%>
		</td>
		<td class="tbYellow" width="14%">ID</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="BORROW_ID" name="BORROW_ID" class="textBox2" maxlength="10" fieldName="借款人ID"/>
			<jsp:include page="/html/CM/VIP.jsp" />
		</td>
	</tr>	
	<tr>	
		<%-- [20190626] 增加羅馬拼音欄位 --%>	
		<td class="tbYellow">姓名(羅馬拼音)</td>
		<td class="tbYellow2">
			<input type="text" id="BORROW_NAME_RM" name="BORROW_NAME_RM" fieldName="借款人_姓名(羅馬拼音)" maxlength="100" class="textBox2 checkInputLength hasFullType"/>
		</td>
		<%-- [20221121] 增加ID,用於更換生日or成立日期 --%>
		<td class="tbYellow" id="BIRTHDAY_HEADER">生日</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="BIRTHDAY" datatype="ROCDate" name="BIRTHDAY" class="textBox2" size="10" />(EX：630110)
			<%-- [20221121] 增加hidden年齡欄位 --%>
			<input type="hidden" id="AGE">
		</td>	
												
	</tr>	
	<tr>
		<td class="tbYellow">電話(日)</td>
		<td class="tbYellow2">
			<select name="DAY_TEL_AREA" id="DAY_TEL_AREA">
			<option value="" >區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>—
			<input type="text" id="DAY_TEL_NUM" name="DAY_TEL_NUM" size="15" class="textBox2 validate-digits" fieldName="借款人_電話(日)_號碼" maxlength="10" />#
			<input type="text" id="DAY_TEL_EXT" name="DAY_TEL_EXT" size="5" class="textBox2 validate-digits" fieldName="借款人_電話(日)_分機" maxlength="6" />
		</td>	
		<td class="tbYellow">行動電話</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="MOBILE" name="MOBILE" class="textBox2" fieldName="行動電話" maxlength="15" />
		</td>												
	</tr>
	<tr>
		<td class="tbYellow">電話(夜)</td>
		<td class="tbYellow2">
			<select name="NIGHT_TEL_AREA" id="NIGHT_TEL_AREA">
			<option value="" >區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>—
			<input type="text" id="NIGHT_TEL_NUM" name="NIGHT_TEL_NUM" size="15" class="textBox2 validate-digits" fieldName="借款人_電話(夜)_號碼" maxlength="10"/>#
			<input type="text" id="NIGHT_TEL_EXT" name="NIGHT_TEL_EXT" size="5" class="textBox2 validate-digits" fieldName="借款人_電話(夜)_分機" maxlength="6" />
		</td>	
		<td class="tbYellow">電子信箱</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="EMAIL" name="EMAIL" class="textBox2" fieldName="電子信箱" maxlength="40" size='50'/>
		</td>												
	</tr>
	<tr>
		<td class="tbYellow" rowSpan="2" >
			<input type="radio"  name="COUPLE_TYPE" value="1" />配偶<br>
			<input type="radio"  name="COUPLE_TYPE" value="2" />負責人
		</td>
		<td class="tbYellow">姓名</td>
		<td class="tbYellow2">
			<input type="text" id="COUPLE_NAME" name="COUPLE_NAME" fieldName="配偶or負責人_姓名" maxlength="100" class="textBox2 checkInputLength" alt="ch"/><%--[20240722]難字調整 --%>
		</td>
		<td class="tbYellow">ID</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="COUPLE_ID" name="COUPLE_ID" class="textBox2" />
		</td>														
	</tr>
	<tr>	
		<%-- [20190626] 增加羅馬拼音欄位 --%>	
		<td class="tbYellow">姓名(羅馬拼音)</td>
		<td class="tbYellow2">
			<input type="text" id="COUPLE_NAME_RM" name="COUPLE_NAME_RM" fieldName="配偶or負責人_姓名(羅馬拼音)" maxlength="100" class="textBox2 checkInputLength hasFullType"/>
		</td>
		<td class="tbYellow">生日</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" datatype="ROCDate" id="COUPLE_BIRTH" name="COUPLE_BIRTH" class="textBox2" size="10" />(EX：630110)
			<%-- [20221121] 增加hidden年齡欄位 --%>
			<input type="hidden" id="COUPLE_AGE">
		</td>													
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2" >擔保品資料</td>
		<td class="tbYellow2" colSpan="4" id="DSZ01000">													
		</td>
	</tr>	
	<tr>
		<td class="tbYellow" rowSpan="2" colSpan="2">通訊地址</td>
		<td class="tbYellow2">
			<input type="radio" name="CON_CODE" value="1" />同擔保品地址
			<input type="radio" name="CON_CODE" value="2" />其他如下
		</td>
		<td class="tbYellow">通訊地址所有人</td>
		<td class="tbYellow2" colspan="2">
			<select name="OWN_CODE" id="OWN_CODE">
			<option value=" "> </option>
			<c:forEach var="map" items="${OWN_CODE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>	
			</select>
			<input type="text" style="display:none" id="OWN_CODE_CONTENT" name="OWN_CODE_CONTENT" fieldName="通訊地址所有人.其他說明" size="30" maxlength="60" class="textBox2 checkInputLength" />
		</td>												
	</tr>
	<tr>
		<td class="tbYellow2" colSpan="4" id="DSZ01000_1" >
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2" rowSpan="2" >前次買賣價</td>
		<td class="tbYellow2" colSpan="4">
			<input type="radio" name="TRADE_CODE" value="1" />自地自建
			<input type="radio" name="TRADE_CODE" value="2" />法拍屋
			<input type="radio" name="TRADE_CODE" value="3" />其他
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colSpan="4">
			購買年月 
			<input type="text" id="TRADE_DATE" size="6" name="TRADE_DATE" datatype="ROCDate" data-YMonly="1" class="textBox2"/>
			，金額 
			<input type="text" id="TRADE_PRICE" size="10" name="TRADE_PRICE" class="textBox2 validate-number" fieldName="前次買賣價_金額" />
			萬元，車位
			<input type="text" id="PARK_PRICE" size="10"name="PARK_PRICE" class="textBox2 validate-number" fieldName="前次買賣價_車位" />
			萬元，車位編號
			<input type="text" id="PARK_NO" size="15" name="PARK_NO" fieldName="前次買賣價_車位編號" maxlength="60" class="textBox2 checkInputLength" />
			號
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2" rowSpan="2" >代償行庫</td>
		<td class="tbYellow2" colSpan="4">
			銀行名稱
			<select id="SELECT_BANK" name="SELECT_BANK">
			<c:forEach var="map" items="${SELECT_BANK_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>		
			</select>
			<input type="text" id="COMP_BANK" size="15" name="COMP_BANK" fieldName="代償行庫_銀行" class="textBox2 checkInputLength" maxlength="20" />
			銀行
			<input type="text" id="COMP_BRANCH" size="15" name="COMP_BRANCH" fieldName="代償行庫_分行" class="textBox2 checkInputLength" maxlength="12" />
			分行
			<input type="text" id="COMP_AMT" size="10" name="COMP_AMT" class="textBox2 validate-number" fieldName="代償行庫_代償金額" />
			萬要求代償
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colSpan="4">
			（設定年月
			<input type="text" id="SET_YM" size="6" name="SET_YM" datatype="ROCDate" data-YMonly="1" class="textBox2" />
			ex:8808，設定
			<input type="text" id="SET_AMT" size="10" name="SET_AMT" class="textBox2 validate-number" fieldName="代償行庫_設定金額" />
			萬，餘額
			<input type="text" id="SET_REMAIN" size="10" name="SET_REMAIN" class="textBox2 validate-number" fieldName="代償行庫_設定餘額" />
			萬，前順位借款人
			<input type="text" id="PREVIOUS_BORROW" size="15" name="PREVIOUS_BORROW" class="textBox2 checkInputLength" fieldName="代償行庫_前順位借款人" maxlength="60" alt="ch"/><%--[20240722]難字調整 --%>
			）
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2"  >連帶保證人</td>
		<td class="tbYellow2" colSpan="4">
			<input type="radio" name="GUAR_CODE" value="1" />無
			<input type="radio" name="GUAR_CODE" value="2" />同擔保品提供人
			<input type="radio" name="GUAR_CODE" value="3" />同配偶/負責人
			<input type="radio" name="GUAR_CODE" value="4" />其他
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2">售屋者ID</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="SELL_ID" name="SELL_ID" class="textBox2" maxLength = "10" fieldName = "售屋者ID" />
			—3200億專案須輸入
		</td>
		<td class="tbYellow" width="15%">售屋者姓名</td>
		<td class="tbYellow2" width="33%">
			<input type="text" id="SELL_NAME" name="SELL_NAME" fieldName="售屋者姓名" class="textBox2 checkInputLength" size="15" maxlength="20" alt="ch"/><%--[20240722]難字調整 --%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2" rowSpan="2" >注意事項</td>
		<td class="tbYellow2" colSpan="4" >
			<select name="SPC_CODE" id="SPC_CODE">
			<c:forEach var="map" items="${SPC_CODE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>	
			</select>
			<input type="text" id="SPC_DESC" name="SPC_DESC" class="textBox2" size="60"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" colSpan="4">
			聯貸案
			<input type="checkbox" id="COPR2" name="COPR2" value="1"/>
			聯貸比例
			<input type="text" id="COPR3" name="COPR3" fieldName="注意事項_聯貸比例起" class="textBox2 validate-number" size="4"/>
			.
			<input type="text" id="COPR4" name="COPR4" fieldName="注意事項_聯貸比例迄" class="textBox2 validate-number" size="4"/>
			%，訂約日期
			<input type="text" id="COPR5" name="COPR5" class="textBox2 required" fieldName="訂約日期" size="12"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colSpan="2">職學團代號</td>
		<td class="tbYellow2" colspan="2">
			<input type="text" id="SCHOOL_CODE" name="SCHOOL_CODE" class="textBox2" size="10"/>
			<span style="color:red;" >※職學團件請輸入八碼統一編號</span>
		</td>
		<td class="tbYellow">拆件另件受理編號</td>
		<td class="tbYellow2">
			<input type="text" id="IS_SEPARATE" name="IS_SEPARATE" class="textBox2" size="15"/>
		</td>
	</tr>									
</table>
<%-- [20191213] 增加 法金案件資訊 區域 --%>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="sectionLOAN_UNION" >
	<tr>
		<td class="tbBlue textBold" width="100%" colSpan="6">法金案件資訊</td>
	</tr>
	<tr>
		<td class="tbYellow">案件架構</td>
		<td class="tbYellow2">
			<select name="CASE_STRUCT" id="CASE_STRUCT" fieldName="法金_案件架構">	
				<option value="">請選擇</option>			 
				<c:forEach var="map" items="${A010_CASE_TYPE_List}">
					<option value="${map.key}" >${map.value}</option>
				</c:forEach>
			</select>
		</td>	
		<td class="tbYellow">主辦銀行家數與說明</td>
		<td class="tbYellow2" colSpan='3'>
		    <select name="UNION_BANK_NUM" id="UNION_BANK_NUM">
				<option value="">請選擇</option>			 
				<c:forEach var="map" items="${BANK_NUM_List}">
					<option value="${map.key}" >${map.value}</option>
				</c:forEach>
			</select>
			<input type="text" class="textBox2" id="UNION_BANK_MEMO" name="UNION_BANK_MEMO" size="100" />
		</td>
    </tr>		
    <tr>	
		<td class="tbYellow">管理銀行</td>
		<td class="tbYellow2" colSpan='3'>		     
			<input type="text" class="textBox2" id="MANAGER_BANK" name="MANAGER_BANK" size="100" />
		</td>
		<td class="tbYellow">信用評等皆BBB+以上</td>												
		<td class="tbYellow2">
			是<input type="radio" id="CRED_RATE_BBB_Y" name="CRED_RATE_BBB" value="Y" />
			否<input type="radio" id="CRED_RATE_BBB_N" name="CRED_RATE_BBB" value="N" />			
		</td>
	</tr>
	<tr>
		<td class="tbYellow"  width="10%">總聯貸金額</td>
		<td class="tbYellow2"  width="23%">
			<input type="text" id="UNION_LOAN_AMT" name="UNION_LOAN_AMT" class="textBox2" size="14" value="" fieldName="總聯貸金額"/>元
		</td>		 
		<td class="tbYellow"  width="10%">幣別</td>												
		<td class="tbYellow2"  width="23%">
			<select name="CURR" id="CURR">
				<option value="">請選擇</option>			 
				<c:forEach var="map" items="${CURR_List}">
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow"  width="10%">利率指標</td>
		<td class="tbYellow2"  width="23%">
			<select name="INTEREST_RT_TP" id="INTEREST_RT_TP">
				<option value="">請選擇</option>			 
				<c:forEach var="map" items="${BASE_RATE_List}">
					<option value="${map.key}" >${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >拆件原因</td>
		<td class="tbYellow2">
		    <select name="SEP_REASON" id="SEP_REASON">
				<option value="">請選擇</option>			 
				<c:forEach var="map" items="${A010_DETACH_REASON_List}">
					<option value="${map.key}" >${map.value}</option>
				</c:forEach>
			</select>
		</td>		
	    <td class="tbYellow">是否為主要受編</td>												
		<td class="tbYellow2" colSpan='3'>
			是<input type="radio" class="textBox2" id="IS_MAIN_APPLYID_Y" name="IS_MAIN_APPLYID" value="Y" fieldName="是否為主要受編"/>
			否<input type="radio" class="textBox2" id="IS_MAIN_APPLYID_N" name="IS_MAIN_APPLYID" value="N" />			
		</td>
	</tr>		
	<tr>	
		<td class="tbYellow" >拆件受編</td>
		<td class="tbYellow2"  colSpan='5'>
			<input type="text" class="textBox2" id="SEP_APPLYID_1" name="SEP_APPLYID_1" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_2" name="SEP_APPLYID_2" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_3" name="SEP_APPLYID_3" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_4" name="SEP_APPLYID_4" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_5" name="SEP_APPLYID_5" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_6" name="SEP_APPLYID_6" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_7" name="SEP_APPLYID_7" maxlength="11" size="15" />
			<input type="text" class="textBox2" id="SEP_APPLYID_8" name="SEP_APPLYID_8" maxlength="11" size="15" />
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
	<tr>
		<td class="tbYellow" width="13%">業績歸屬</td>
		<td class="tbYellow2" colSpan="3" >
			<input type="text" id="BELONG_DEPT1" name="BELONG_DEPT1" size="5" class="textBox2" value="${defaultMap.BELONG_DEPT1}" />
			<input type="text" id="BELONG_DEPT2" name="BELONG_DEPT2" size="5" class="textBox2" value="${defaultMap.BELONG_DEPT2}" />
		</td>
		<td class="tbYellow" width="3%" rowSpan="4" align="center">聯<br>絡<br>人</td>
		<td class="tbYellow" width="8%" >姓名</td>
		<td class="tbYellow2" width="37%" >
			<input type="text" id="COM_NAME" name="COM_NAME" fieldName="聯絡人_姓名" class="textBox2 checkInputLength" maxlength="12" alt="ch"/><%--[20240722]難字調整 --%>
		</td>												
	</tr>
	<tr>
		<td class="tbYellow">輸入人員</td>
		<td class="tbYellow2" width="20%" >
			<div id="INPUT_NAME" style="font-family:'EUDC'">${defaultMap.INPUT_NAME}</div><%--[20240722]難字調整 --%>
		</td>
		<td class="tbYellow" width="9%">受理日期</td>
		<td class="tbYellow2" width="10%" >
			<div id="APPLY_DATE" datatype="ROCDate" >${defaultMap.APPLY_DATE}</div>
		</td>
		<td class="tbYellow">電話</td>
		<td class="tbYellow2">
			<select name="COM_TEL_AREA" id="COM_TEL_AREA">
			<option value="" >區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>—
			<input type="text" id="COM_TEL_NUM" name="COM_TEL_NUM" size="15" fieldName="聯絡人電話號碼" class="textBox2 validate-digits" maxlength="10" />#
			<input type="text" id="COM_TEL_EXT" name="COM_TEL_EXT" size="5" fieldName="聯絡人電話分機" class="textBox2 validate-digits" maxlength="6" />
		</td>												
	</tr>		
	<tr>
		<td class="tbYellow">經手人ID</td>
		<td class="tbYellow2">
			<input type="text" id="AGENT_ID" name="AGENT_ID" class="textBox2" size="12" />
			<div id="AGENT_NAME" style="font-family:'EUDC'"></div> <%--[20240722]難字調整 --%>
		</td>
		<td class="tbYellow">業績比例  </td>
		<td class="tbYellow2">
			<select name="ALWC_RATE" id="ALWC_RATE">
			<c:forEach var="map" items="${ALWC_RATE_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>
		</td>
		<td class="tbYellow">傳真</td>
		<td class="tbYellow2">
			<select name="COM_FAX_AREA" id="COM_FAX_AREA">
			<option value="" >區碼</option>
			<c:forEach var="map" items="${TEL_AREA_List}">
			<option value="${map.key}">${map.value}</option>
			</c:forEach>
			</select>—
			<input type="text" id="COM_FAX_NUM" name="COM_FAX_NUM" size="15" class="textBox2 validate-digits" fieldName="聯絡人傳真號碼" maxlength="10" />
		</td>												
	</tr>	
	<tr>
		<td class="tbYellow">第二經手人<br>(AO或放款精英)</td>
		<td class="tbYellow2">
			<input type="text" id="AGENT1_ID" name="AGENT1_ID" class="textBox2" size="12" />
			<div id="AGENT1_NAME" style="font-family:'EUDC'"></div> <%--[20240722]難字調整 --%>
		</td>
		<td class="tbYellow">業績比例</td>
		<td class="tbYellow2">
			<div id="ALWC_RATE1" ></div>
		</td>
		<td class="tbYellow">行動</td>
		<td class="tbYellow2">
			<input type="text" id="COM_MOBIL" name="COM_MOBIL" class="textBox2" fieldName="聯絡人行動電話" maxlength="15"/>
		</td>												
	</tr>	
</table>

</form>			

	</body>
</html>