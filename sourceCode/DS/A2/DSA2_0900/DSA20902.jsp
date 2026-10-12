<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSA20902.jsp
作者：林秉宏
功能：債信評等
完成：2018/01/17
更新：

[20230509]問題單號20230508134214
1.新增隱藏INPUT，判斷D區模型回饋是否有異動
2.D區模型回饋異動時，將隱藏欄位賦值'Y'
3.按下新增一列及移除按鈕，也視為D區模型回饋異動，將隱藏欄位賦值'Y'
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<title></title>

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>

<style type="text/css"> 
<!--
.style1 {font-size: 24px; color: #0000FF;}
.blueColor{
		color: blue;
		background-color: #F0F8FF;
		text-align:center;
	}
-->
</style>
<%--[20240729]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

// 產生畫面物件
var DSA20902 = new DSA20902();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', DSA20902.initApp);

function DSA20902(){
	
	<%--建立 ajax request 物件--%>
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0902/');
    
    var valid;
    var OPINION_BAD = <c:out value ="${OPINION_BAD}" default="{}" escapeXml="false" />;
    var OPINION_GOOD = <c:out value ="${OPINION_GOOD}" default="{}" escapeXml="false" />;
    
    <%--檢核--%>
	var initValidation = function(){	
		valid = new Validation('form1', { focusOnError:true, immediate:false , mode : 'validator'});
		valid.define( "required" , [{ id : "APPLY_ID", errMsg:'請輸入受理編號'}]);
	};
    
    var actions = {
    	<%--查詢--%>
		doQuery : function(){	
		
			if(!valid.validate()){ 
				return; 
			}
			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });
			
			ajaxRequest.post( 'query' , { APPLY_ID : $F('APPLY_ID') },
				function(resp){		
					buttons.setTable(resp.rtnMap);
					buttons.setDEFTable(resp); 
					$('INFO').show();
					$('GFICO').show();
					$('AREA_D').show();//[20220921]新增意見回饋區塊
					
					//[20220921]根據MM_CODE顯示對應 GFICO Score表格
					var attrDesc = resp.rtnMap.attrDesc; 
					var MM_CODE = attrDesc['MM_CODE_SRC'];
					$('table_E_0').hide();
					$('table_E_1').hide();	
					$('table_E_2').hide();	
					if(MM_CODE == '0'){
						$('table_E_0').show(); //中長型
					} else if(MM_CODE == '1'){
						$('table_E_1').show(); //單理財型	
					} else if(MM_CODE == '2'){
						$('table_E_2').show(); //混合型	
					}
				},
				function(resp){
					buttons.setTable(); 
					$('INFO').hide();
					$('GFICO').hide();
					$('AREA_D').hide();//[20220921]新增意見回饋區塊
				}
			);
		},
		<%--[20220923]新模組是否優於或相當於舊模組連動意見回饋下拉選單--%>
		isBetterChange : function(){
			var IS_BETTER = $$('input[name="IS_BETTER"]:checked')[0].getValue();
			actions.setOpinionSelect(IS_BETTER);
			actions.clearInput();<%--[20230426]連動清空畫面上舊的回饋文字輸入--%>
		},
		<%--[20220923]設定意見回饋下拉選單--%>
		setOpinionSelect : function(IS_BETTER){	
			$$('select[name="OPINION"]').each(
					function(elem){
						elem.length = 0;
						elem.insert(new Option('請選擇', ''));
						if(IS_BETTER == '1'){
							for(var key in OPINION_GOOD){
								
								elem.insert(new Option(OPINION_GOOD[key], key));
							}
						} else {
							for(var key in OPINION_BAD){
								elem.insert(new Option(OPINION_BAD[key], key));
							}
						}
					}
			);
		},
		<%--[20230426]清空模型使用回饋文字輸入--%>
		clearInput: function(){
			$$('input[name="DETAIL"]').each(function(elem){
				elem.setValue('');
			});			
		},
		<%--[20220926]查詢D區塊--%>
		queryDarea : function(resp){
			var table_D = $('table_D');
			var A514List = resp.A514List || [];
			var A514Map = {};
			if(A514List.length > 0){
				A514Map = A514List[0]; //A514第一筆資料
    		}
			
    		//先刪除原有ROW
    		$$("tr[name=OPINION_ROW]").each(function(elem){
				elem.remove();
			})
			
			<%--[20230509][20230508134214]將隱藏欄位預設值為'N'--%>
    		$('updateStatus_DSA20902').setValue('N');
    		
    		//依照A514筆數生成ROW
    		for(var i = 0 ; i < A514List.length; i++){
    			var thisA514 = A514List[i];
    			var thisTR = new Element('tr', {id: 'OPINION_ROW_' + i, name: 'OPINION_ROW'});
    			var thisTD1 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;', colspan: '2'});
    			var thisSELECT = new Element('select', {class: 'form-control',id: 'OPINION_' + i, name: 'OPINION'});
    			var thisTD2 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;', colspan: '4'});
    			var thisINPUT = new Element('input', {type: 'text',id: 'DETAIL_' + i, name: 'DETAIL', size:'70'}).setValue(thisA514['DETAIL']);
    			
    			<%--[20230509][20230508134214]新增綁定事件:D區模型回饋異動時，將隱藏欄位賦值'Y'--%>
    			thisINPUT.observe('change', function(event){
    				$('updateStatus_DSA20902').setValue('Y');
    			});
    			thisSELECT.observe('change', function(event){
    				$('updateStatus_DSA20902').setValue('Y');
    			});
    			var thisBUTTON = new Element('button', {class: 'button', type: 'button',id: 'BTN_delete_' + i}).update('移除');
    			thisBUTTON.observe('click', function(event){
    				event.target.up('tr').remove();
    				$('updateStatus_DSA20902').setValue('Y');
    			});
    			var thisTD3 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;'});
    			var thisSPAN = new Element('span', {id:'INPUT_NM_' + i, style:"font-family:'EUDC'"}).update(thisA514['INPUT_NM']);<%--[20240729]難字調整 --%>
    			thisTR.insert(thisTD1.insert(thisSELECT)).insert(thisTD2.insert(thisINPUT).insert(thisBUTTON)).insert(thisTD3.insert(thisSPAN));
    			table_D.insert(thisTR);
    		}
    		//若無回饋預設是
    		var IS_BETTER = A514Map['IS_BETTER' || ''];
    		if(IS_BETTER == '0'){
    			$('IS_BETTER_0').checked = true;
    			actions.setOpinionSelect('0');
    		} else {
    			$('IS_BETTER_1').checked = true;
    			actions.setOpinionSelect('1');
    		}
    		
    		//下拉選單setValue
    		for(var i = 0 ; i < A514List.length; i++){
    			$('OPINION_' + i).setValue(A514List[i]['OPINION']);
    		}
    		<%-- [20240729]難字調整，動態產需呼叫 --%>
    		parseEUDC();
		}
		
    };
    
    var buttons = {
    
    	setTable : function(rtnMap){
    		//如果作業完有rtnMap.
			if(rtnMap){
	    		//債信評等資料
	    		var creditInfo = rtnMap.creditInfo;
	    		$('IS_SEPARATE').update(creditInfo['IS_SEPARATE'] || '');
	    		$('INPUT_TIME').update(localeDisplay.formatTimestamp(creditInfo['INPUT_TIME'],false) || '');
	    		$('BORROW_NAME').update(creditInfo['BORROW_NAME'] || '');
	    		$('RENEGE_CHANCE').update(localeDisplay.formatNumber(creditInfo['RENEGE_CHANCE']*100, 6) || '');	    		
	    		$('GF_SCORE').update(creditInfo['GF_SCORE'] || '');
	    		$('OY_SCORE').update(creditInfo['OY_SCORE'] || '');
	    		$('CREDIT_RANK').update(creditInfo['CREDIT_RANK'] || '');

				//特徵欄位值說明
				var attrDesc = rtnMap.attrDesc;
				$$('#table_B span').each(
					function(elem){
						elem.update(attrDesc[elem.id] || '');
					}
				);
			}else{
				$('IS_SEPARATE').update('');
	    		$('INPUT_TIME').update('');
	    		$('BORROW_NAME').update('');
	    		$('RENEGE_CHANCE').update('');    		
	    		$('GF_SCORE').update('');
	    		$('OY_SCORE').update('');
	    		$('CREDIT_RANK').update('');
			}
    	},
    	<%--[20220921]設定D、E、F區塊顯示資料--%>
    	setDEFTable : function(resp){
    		var A512List = resp.A512List || [];
    		var A512Map = {};
    		if(A512List.length > 0){
    			A512Map = A512List[0]; //A512第一筆資料
    		}
    		var A513Map = resp.A513Map || {};
    		
    		//D區塊
    		$('LDM_PROB').update(A513Map['LDM_PROB'] || "");
    		$('NEW_CREDIT_RANK').update(A513Map['CREDIT_RANK'] || "");
    		actions.queryDarea(resp);
    		
    		//E區塊
    		$('BASE_VALUE_0').update(A513Map['SHAP_BASE_VALUE'] || "");
    		$('BASE_VALUE_1').update(A513Map['SHAP_BASE_VALUE'] || "");
    		$('BASE_VALUE_2').update(A513Map['SHAP_BASE_VALUE'] || "");
    		
    		//F區塊
    		<%--基本資訊--%>
    		$('AGE_NEW').update(A512Map['AGE'] || "");
    		$('AGE_SHAP').update(A513Map['AGE_SHAP'] || "0");
    		$('DEGREE_NEW').update(A512Map['DEGREE_SEG'] || "");
    		$('DEGREE_SHAP').update(A513Map['DEGREE_SHAP'] || "0");
    		$('MARRY_NEW').update(A512Map['MARRY'] || "");
    		$('MARRY_SHAP').update(A513Map['MARRY_SHAP'] || "0");
    		$('OCCU_CODE_NEW').update(A512Map['OCCU_CODE_SEG'] || "");
    		$('OCCU_CODE_SHAP').update(A513Map['OCCU_CODE_SHAP'] || "0");
    		$('SERV_YEAR_NEW').update(A512Map['SERV_YEAR'] || "");
    		$('SERV_YEAR_SHAP').update(A513Map['SERV_YEAR_SHAP'] || "0");
    		$('INFO_SHAP').update(A513Map['INFO_SHAP'] || "0");
    		<%--申貸資訊--%>
    		$('LOAN_POS_NEW').update(A512Map['LOAN_POS_SEG'] || "");
    		$('LOAN_POS_SHAP').update(A513Map['LOAN_POS_SHAP'] || "0");
    		$('RETURN_TYPE_NEW').update(A512Map['RETURN_TYPE_SEG'] || "");
    		$('RETURN_TYPE_SHAP').update(A513Map['RETURN_TYPE_SHAP'] || "0");
    		$('LOAN_AMT_NEW').update(A512Map['LOAN_AMT'] || "");
    		$('LOAN_AMT_SHAP').update(A513Map['LOAN_AMT_SHAP'] || "0");
    		$('LOAN_SHAP').update(A513Map['LOAN_SHAP'] || "0");
    		<%--償還能力--%>
    		$('GUAR_RELATION_NEW').update(A512Map['GUAR_RELATION_SEG'] || "");
    		$('GUAR_RELATION_SHAP').update(A513Map['GUAR_RELATION_SHAP'] || "0");
    		$('EXPENSE_RATE_NEW').update(A512Map['EXPENSE_RATE'] || "");
    		$('EXPENSE_RATE_SHAP').update(A513Map['EXPENSE_RATE_SHAP'] || "0");
    		$('LOANAMTINCOME_NEW').update(A512Map['LOANAMTINCOME'] || "");
    		$('LOANAMTINCOME_SHAP').update(A513Map['LOANAMTINCOME_SHAP'] || "0");
    		$('ABILITY_SHAP').update(A513Map['ABILITY_SHAP'] || "0");
    		<%--授信紀錄--%>
    		$('GAGE_AMT_NEW').update(A512Map['GAGE_AMT'] || "0");
    		$('GAGE_AMT_SHAP').update(A513Map['GAGE_AMT_SHAP'] || "0");
    		$('CASHUSING_RATIO_NEW').update(A512Map['CASHUSING_RATIO'] || "0");
    		$('CASHUSING_RATIO_SHAP').update(A513Map['CASHUSING_RATIO_SHAP'] || "0");
    		$('FIDUCIARY_AMT_NEW').update(A512Map['FIDUCIARY_AMT'] || "0");
    		$('FIDUCIARY_AMT_SHAP').update(A513Map['FIDUCIARY_AMT_SHAP'] || "0");
    		$('GUARANTOR_AMT_NEW').update(A512Map['GUARANTOR_AMT'] || "0");
    		$('GUARANTOR_AMT_SHAP').update(A513Map['GUARANTOR_AMT_SHAP'] || "0");
    		$('REL_CODE_SEG_NEW').update(A512Map['REL_CODE_SEG'] || "0");
    		$('REL_CODE_SEG_SHAP').update(A513Map['REL_CODE_SEG_SHAP'] || "0");
    		$('CREDIT_SHAP').update(A513Map['CREDIT_SHAP'] || "0");
    		<%--信用卡類--%>
    		$('LATE_PAYMENT_CNT_NEW').update(A512Map['LATE_PAYMENT_CNT'] || "0");
    		$('LATE_PAYMENT_CNT_SHAP').update(A513Map['LATE_PAYMENT_CNT_SHAP'] || "0");
    		$('PERM_LIMIT_NEW').update(A512Map['PERM_LIMIT'] || "0");
    		$('PERM_LIMIT_SHAP').update(A513Map['PERM_LIMIT_SHAP'] || "0");
    		$('PAYABLE_SUM_NEW').update(A512Map['PAYABLE_SUM'] || "0");
    		$('PAYABLE_SUM_SHAP').update(A513Map['PAYABLE_SUM_SHAP'] || "0");
    		$('CYC_NEW').update(A512Map['CYC'] || "0");
    		$('CYC_SHAP').update(A513Map['CYC_SHAP'] || "0");
    		$('CYC_M_NEW').update(A512Map['CYC_M'] || "0");
    		$('CYC_M_SHAP').update(A513Map['CYC_M_SHAP'] || "0");
    		$('CARD_SHAP').update(A513Map['CARD_SHAP'] || "0");
    		<%--投保類型--%>
    		$('LOB1_POL_CNT_NEW').update(A512Map['LOB1_POL_CNT'] || "0");
    		$('LOB1_POL_CNT_SHAP').update(A513Map['LOB1_POL_CNT_SHAP'] || "0");
    		$('LOB2_POL_CNT_NEW').update(A512Map['LOB2_POL_CNT'] || "0");
    		$('LOB2_POL_CNT_SHAP').update(A513Map['LOB2_POL_CNT_SHAP'] || "0");
    		$('LOB5_POL_CNT_NEW').update(A512Map['LOB5_POL_CNT'] || "0");
    		$('LOB5_POL_CNT_SHAP').update(A513Map['LOB5_POL_CNT_SHAP'] || "0");
    		$('LOB6_POL_CNT_NEW').update(A512Map['LOB6_POL_CNT'] || "0");
    		$('LOB6_POL_CNT_SHAP').update(A513Map['LOB6_POL_CNT_SHAP'] || "0");
    		$('LOB_SHAP').update(A513Map['LOB_SHAP'] || "0");
    		<%--保單交易--%>
    		$('TOTAL_PREMIUM_NEW').update(A512Map['TOTAL_PREMIUM'] || "0");
    		$('TOTAL_PREMIUM_SHAP').update(A513Map['TOTAL_PREMIUM_SHAP'] || "0");
    		$('INSU_LOAN_CNT_NEW').update(A512Map['INSU_LOAN_CNT'] || "0");
    		$('INSU_LOAN_CNT_SHAP').update(A513Map['INSU_LOAN_CNT_SHAP'] || "0");
    		$('LOAN_POL_CNT_NEW').update(A512Map['LOAN_POL_CNT'] || "0");
    		$('LOAN_POL_CNT_SHAP').update(A513Map['LOAN_POL_CNT_SHAP'] || "0");
    		$('LOAN_BAL_SUM_NEW').update(A512Map['LOAN_BAL_SUM'] || "0");
    		$('LOAN_BAL_SUM_SHAP').update(A513Map['LOAN_BAL_SUM_SHAP'] || "0");
    		$('AP_CNT_NEW').update(A512Map['AP_CNT'] || "0");
    		$('AP_CNT_SHAP').update(A513Map['AP_CNT_SHAP'] || "0");
    		$('AP_POL_CNT_NEW').update(A512Map['AP_POL_CNT'] || "0");
    		$('AP_POL_CNT_SHAP').update(A513Map['AP_POL_CNT_SHAP'] || "0");
    		$('AP_BAL_SUM_NEW').update(A512Map['AP_BAL_SUM'] || "0");
    		$('AP_BAL_SUM_SHAP').update(A513Map['AP_BAL_SUM_SHAP'] || "0");
    		$('URGEPAY_CNT_NEW').update(A512Map['URGEPAY_CNT'] || "0");
    		$('URGEPAY_CNT_SHAP').update(A513Map['URGEPAY_CNT_SHAP'] || "0");
    		$('LAPSE_CNT_NEW').update(A512Map['LAPSE_CNT'] || "0");
    		$('LAPSE_CNT_SHAP').update(A513Map['LAPSE_CNT_SHAP'] || "0");
    		$('LAPSE_POL_CNT_NEW').update(A512Map['LAPSE_POL_CNT'] || "0");
    		$('LAPSE_POL_CNT_SHAP').update(A513Map['LAPSE_POL_CNT_SHAP'] || "0");
    		$('INSURANCE_SHAP').update(A513Map['INSURANCE_SHAP'] || "0");
    		<%--變數標註(前六高且大於0)--%>
    		$('AGE_SHAP_TOP6').update(A513Map['AGE_SHAP_TOP6'] || "");
    		$('DEGREE_SHAP_TOP6').update(A513Map['DEGREE_SHAP_TOP6'] || "");
    		$('MARRY_SHAP_TOP6').update(A513Map['MARRY_SHAP_TOP6'] || "");
    		$('OCCU_CODE_SHAP_TOP6').update(A513Map['OCCU_CODE_SHAP_TOP6'] || "");
    		$('SERV_YEAR_SHAP_TOP6').update(A513Map['SERV_YEAR_SHAP_TOP6'] || "");
    		$('LOAN_POS_SHAP_TOP6').update(A513Map['LOAN_POS_SHAP_TOP6'] || "");
    		$('RETURN_TYPE_SHAP_TOP6').update(A513Map['RETURN_TYPE_SHAP_TOP6'] || "");
    		$('LOAN_AMT_SHAP_TOP6').update(A513Map['LOAN_AMT_SHAP_TOP6'] || "");
    		$('GUAR_RELATION_SHAP_TOP6').update(A513Map['GUAR_RELATION_SHAP_TOP6'] || "");
    		$('EXPENSE_RATE_SHAP_TOP6').update(A513Map['EXPENSE_RATE_SHAP_TOP6'] || "");
    		$('LOANAMTINCOME_SHAP_TOP6').update(A513Map['LOANAMTINCOME_SHAP_TOP6'] || "");
    		$('GAGE_AMT_SHAP_TOP6').update(A513Map['GAGE_AMT_SHAP_TOP6'] || "");
    		$('CASHUSING_RATIO_SHAP_TOP6').update(A513Map['CASHUSING_RATIO_SHAP_TOP6'] || "");
    		$('FIDUCIARY_AMT_SHAP_TOP6').update(A513Map['FIDUCIARY_AMT_SHAP_TOP6'] || "");
    		$('GUARANTOR_AMT_SHAP_TOP6').update(A513Map['GUARANTOR_AMT_SHAP_TOP6'] || "");
    		$('REL_CODE_SEG_SHAP_TOP6').update(A513Map['REL_CODE_SEG_SHAP_TOP6'] || "");
    		$('LATE_PAYMENT_CNT_SHAP_TOP6').update(A513Map['LATE_PAYMENT_CNT_SHAP_TOP6'] || "");
    		$('PERM_LIMIT_SHAP_TOP6').update(A513Map['PERM_LIMIT_SHAP_TOP6'] || "");
    		$('PAYABLE_SUM_SHAP_TOP6').update(A513Map['PAYABLE_SUM_SHAP_TOP6'] || "");
    		$('CYC_SHAP_TOP6').update(A513Map['CYC_SHAP_TOP6'] || "");
    		$('CYC_M_SHAP_TOP6').update(A513Map['CYC_M_SHAP_TOP6'] || "");
    		$('LOB1_POL_CNT_SHAP_TOP6').update(A513Map['LOB1_POL_CNT_SHAP_TOP6'] || "");
    		$('LOB2_POL_CNT_SHAP_TOP6').update(A513Map['LOB2_POL_CNT_SHAP_TOP6'] || "");
    		$('LOB5_POL_CNT_SHAP_TOP6').update(A513Map['LOB5_POL_CNT_SHAP_TOP6'] || "");
    		$('LOB6_POL_CNT_SHAP_TOP6').update(A513Map['LOB6_POL_CNT_SHAP_TOP6'] || "");
    		$('TOTAL_PREMIUM_SHAP_TOP6').update(A513Map['TOTAL_PREMIUM_SHAP_TOP6'] || "");
    		$('INSU_LOAN_CNT_SHAP_TOP6').update(A513Map['INSU_LOAN_CNT_SHAP_TOP6'] || "");
    		$('LOAN_POL_CNT_SHAP_TOP6').update(A513Map['LOAN_POL_CNT_SHAP_TOP6'] || "");
    		$('LOAN_BAL_SUM_SHAP_TOP6').update(A513Map['LOAN_BAL_SUM_SHAP_TOP6'] || "");
    		$('AP_CNT_SHAP_TOP6').update(A513Map['AP_CNT_SHAP_TOP6'] || "");
    		$('AP_POL_CNT_SHAP_TOP6').update(A513Map['AP_POL_CNT_SHAP_TOP6'] || "");
    		$('AP_BAL_SUM_SHAP_TOP6').update(A513Map['AP_BAL_SUM_SHAP_TOP6'] || "");
    		$('URGEPAY_CNT_SHAP_TOP6').update(A513Map['URGEPAY_CNT_SHAP_TOP6'] || "");
    		$('LAPSE_CNT_SHAP_TOP6').update(A513Map['LAPSE_CNT_SHAP_TOP6'] || "");
    		$('LAPSE_POL_CNT_SHAP_TOP6').update(A513Map['LAPSE_POL_CNT_SHAP_TOP6'] || "");
    		
    	},
    	<%--[20220926]增加一列--%>
    	addRow : function(){
    		var table_D = $('table_D');
    		var thisTR = new Element('tr', {id: 'OPINION_ROW_add', name: 'OPINION_ROW'});
			var thisTD1 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;', colspan: '2'});
			var thisSELECT = new Element('select', {class: 'form-control',id: 'OPINION_add', name: 'OPINION'});
			var thisTD2 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;', colspan: '4'});
			var thisINPUT = new Element('input', {type: 'text',id: 'DETAIL_add', name: 'DETAIL', size:'70'});
			var thisBUTTON = new Element('button', {class: 'button', type: 'button',id: 'BTN_delete_add'}).update('移除');
			thisBUTTON.observe('click', function(event){
				event.target.up('tr').remove();
			});
			var thisTD3 = new Element('td', {class: 'tbYellow2', style: 'text-align:center;'});
			var thisSPAN = new Element('span', {id:'INPUT_NM_add', style:"font-family:'EUDC'"});<%--[20240729]難字調整 --%>
			thisTR.insert(thisTD1.insert(thisSELECT)).insert(thisTD2.insert(thisINPUT).insert(thisBUTTON)).insert(thisTD3.insert(thisSPAN));
			table_D.insert(thisTR);
			
			var IS_BETTER = document.querySelector('input[name="IS_BETTER"]:checked').value;
			thisSELECT.insert(new Option('請選擇', ''));
			if(IS_BETTER == '1'){
				for(var key in OPINION_GOOD){
					thisSELECT.insert(new Option(OPINION_GOOD[key], key));
				}
			} else {
				for(var key in OPINION_BAD){
					thisSELECT.insert(new Option(OPINION_BAD[key], key));
				}
			}
			
    		<%--[20230509][20230508134214]新增一列視為D區模型回饋異動，將隱藏欄位賦值'Y'--%>
			$('updateStatus_DSA20902').setValue('Y');
			<%-- [20240729]難字調整，動態產需呼叫 --%>
			parseEUDC();
    	},
    	<%--[20220926]修改--%>
		doUpdate : function(){
			var APPLY_ID = $F('APPLY_ID');
			var IS_BETTER = $$('input[name="IS_BETTER"]:checked')[0].getValue();
			var updateList = [];
			var array1 = [];
			var array2 = [];
			$$("select[name=OPINION]").each(function(elem){
				var opinion = elem.value;
				array1.push(opinion);
			})
			$$("input[name=DETAIL]").each(function(elem){
				var detail = elem.value;
				array2.push(detail);
			})
			if(array1.length == 0){
				alert('請先完成回饋內容再修正。');
				return;
			}
			if(array1.length > 10){
				alert('新模型意見回饋不得超過10個。');
				return;
			}
			for(var i=0; i < array1.length; i++){
				var opinion = array1[i];
				var detail = array2[i];
				//新模型意見回饋如已選取，則模型使用回饋不得空白。
				if(opinion == "" || detail == ""){
					alert('模型使用回饋不得空白。');
					return;
				}
				//新模型意見回饋若未選取，即使模型使用回饋有值也不儲存
				if(opinion != ""){
					var updateMap = {
							'APPLY_ID' : APPLY_ID,
							'IS_BETTER' : IS_BETTER,
							'OPINION' : opinion,
							'DETAIL' : detail
						};
					updateList.push(updateMap);
				}
			}
			ajaxRequest.post('update', {ListA : Object.toJSON(updateList), APPLY_ID : APPLY_ID },
				function(resp){
					actions.queryDarea(resp);
				}
			);
		},
		<%--顯示Shap值欄位--%>
		displayShap : function(){
			$$('[name=hiddenShap]').each(function(elem){
    			elem.toggle();
    		})
		}
    	
    };
    
    return {
		
		initApp : function() {
		
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>

			PageUI.createPageWithAllBodySubElement("DSA20902", "核貸作業", "債信評等", 1);
			
			initValidation();						
							
			<%--查詢--%>
			$('BTN_query').observe('click', actions.doQuery );
			
			//監聽: 查詢方式(值) 轉大寫
			$("APPLY_ID").observe('change', function() {$("APPLY_ID").setValue($F("APPLY_ID").toUpperCase());});
			
			<%--[20220923]radio連動新模型意見回饋下拉選單--%>
			$$("[name=IS_BETTER]").each(function(elem){
				elem.observe('change', actions.isBetterChange);
			})
			<%--[20220926]新增按鈕--%>
			$('BTN_addrow').observe('click', buttons.addRow);
			$('BTN_update').observe('click', buttons.doUpdate);
			$('BTN_display').observe('click', buttons.displayShap);
			
			$('INFO').hide();
			$('GFICO').hide();
			$('AREA_D').hide();//[20220921]新增意見回饋區塊
			
			if ('${APPLY_ID}' != "") {
				$('APPLY_ID').value = '${APPLY_ID}';
			}else if(CSRUtil.keepParamsManager.get('APPLY_ID')){
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}
			if($F('APPLY_ID')){
				actions.doQuery();
			}
					
			PageUI.resize();
			displayMessage();
		}		
	};
}

</script>
</head>
<body>
<form id="form1" name="form1">
	<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" height="68">
		<tr>
			<td class="tbYellow" width="10%">受理編號</td>
			<td class="tbYellow2" width="12%">
				<input id="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
			</td>
			<td class="tbYellow2" width="32%" colspan="3">
				<input id="BTN_query" type="button" class="button" value="查詢">
			</td>
			<td class="tbYellow" width="10%">拆件編號</td>
			<td class="tbYellow2" width="12%">
				<span id="IS_SEPARATE"></span>
			</td>
			<td class="tbYellow" width="10%">評等日期</td>
			<td class="tbYellow2" width="12%">
				<span id="INPUT_TIME"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="10%"><strong>借款人姓名</strong></td>
			<td class="tbYellow2" width="12%">
				<span class="style1" id="BORROW_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%>
			</td>
			<td class="tbYellow" width="12%"><strong>預測違約機率</strong></td>
			<td class="tbYellow2" width="10%">
				<span class="style1" id="RENEGE_CHANCE"></span>&nbsp;&nbsp;<strong>%</strong>
			</td>
			<td class="tbYellow" width="10%"><strong>G-FICO</strong></td>
			<td class="tbYellow2" width="22%" colspan="2" style="white-space: nowrap">
				<span class="style1" id="GF_SCORE"></span>&nbsp;&nbsp;<strong>分</strong>
        		<strong>(近一年百分位點:</strong>&nbsp;&nbsp;<span class="style1" id="OY_SCORE"></span>&nbsp;&nbsp;<strong>%)</strong>
			</td>
			<td class="tbYellow" width="10%"><strong>債信評等</strong></td>
			<td class="tbYellow2" width="12%">
				<span class="style1" id="CREDIT_RANK"></span>&nbsp;&nbsp;<strong>級</strong>
			</td>
		</tr>
	</table>								
</form>
<form id="form2" name="form2">
	<div id="AREA_D" style="display:none;">
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" style="text-align:center; width:10%">新模型違約機率</td>
				<td class="tbYellow2" style="text-align:center; width:12%"><span id="LDM_PROB"></span></td>
				<td class="tbYellow" style="text-align:center; width:10%">新債信等級</td>
				<td class="tbYellow2" style="text-align:center; width:12%"><span id="NEW_CREDIT_RANK"></span>級</td>
				<td class="tbYellow" style="text-align:center; width:10%">新模型是否優於或相當於舊模型</td>
				<td class="tbYellow2" style="text-align:center; width:12%">
					<input type="radio" name="IS_BETTER" id="IS_BETTER_1" value="1">是
					<input type="radio" name="IS_BETTER" id="IS_BETTER_0" value="0">否
				</td>
				<td class="tbYellow2" style="text-align:center; width:34%">
					<button class="button" type="button" id="BTN_addrow">新增一列</button>
					<button class="button" type="button" id="BTN_update">修改</button>
					<input type="hidden" name="updateStatus_DSA20902" id="updateStatus_DSA20902" value='N'><%--[20230509][20230508134214]新增隱藏欄位，儲存D區模型回饋有否有異動--%>
				</td>
			</tr>
			<tr>
				<td class="tbBlue" style="text-align:center;" colspan="2">新模型意見回饋</td>
				<td class="tbBlue" style="text-align:center;" colspan="4">模型使用回饋</td>
				<td class="tbBlue" style="text-align:center;" colspan="1">修改人員</td>
			</tr>
		</table>
	</div>								
</form>
<form  id="form3" name="form3">
	<div id="GFICO" style="background:tbYellow2; padding:10px; display:none;">
		<table style="width:100%">
			<tr>
				<td style="vertical-align:top; width:50%;">
					<table id="table_C" border="0" cellpadding="0" cellspacing="1" class="tbBlue">
						<tr>
							<td colspan="3" rowspan="3">&nbsp;</td>
							<td align="center" colspan="7">GFICO Score(107/4/23 改版)</td>
						</tr>
						<tr>
							<td class="blueColor" width="10%">1</td>
							<td class="blueColor" width="10%">2</td>
							<td class="blueColor" width="10%">3</td>
							<td class="blueColor" width="10%">4</td>
							<td class="blueColor" width="10%">5</td>
							<td class="blueColor" width="10%">6</td>
							<td class="blueColor" width="10%">7</td>
						</tr>
						<tr align="center">
							<td class="tbBlue3">745~</td>
							<td class="tbBlue3">720~744</td>
							<td class="tbBlue3">660~719</td>
							<td class="tbBlue3">615~659</td>
							<td class="tbBlue3">530~614</td>
							<td class="tbBlue3">~529</td>
								<td class="tbBlue3">0</td>
						</tr>
						<tr align="center">
							<td class="tbBlue" rowspan="7" align="center">違<br>約<br>機<br>率</td>
							<td class="blueColor">1</td>
							<td class="tbBlue3">&lt= 0.3%</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbYellow">II</td>
						</tr>
						<tr align="center">
							<td class="blueColor">2</td>
							<td class="tbBlue3">0.3%~1.3%(含)</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbYellow">II</td>
						</tr>
						<tr align="center">
							<td class="blueColor">3</td>
							<td class="tbBlue3">1.3%~2.9%(含)</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbYellow0">III</td>
						</tr>
						<tr align="center">
							<td class="blueColor">4</td>
							<td class="tbBlue3">2.9%~4.53%(含)</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue2">IV</td>
						</tr>
						<tr align="center">
							<td class="blueColor">5</td>
							<td class="tbBlue3">4.53%~8.9%(含)</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue">V</td>
						</tr>
						<tr align="center">
							<td class="blueColor">6</td>
							<td class="tbBlue3">8.9%~40.6%(含)</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
						</tr>
						<tr align="center">
							<td class="blueColor">7</td>
							<td class="tbBlue3">&gt 40.6%</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
						</tr>
					</table>
				</td>
				<td style="vertical-align:top; width:50%;">
				<table id="table_E_0" border="0" cellpadding="0" cellspacing="1" class="tbBlue" style="display:none;">
						<tr>
							<td colspan="2" rowspan="3">&nbsp;</td>
							<td align="center" rowspan="3">中長期<br>(Base Value=<span id="BASE_VALUE_0"></span>)</td>
							<td align="center" colspan="7">GFICO Score(110/5/1 改版)</td>
						</tr>
						<tr>
							<td class="blueColor" width="10%">1</td>
							<td class="blueColor" width="10%">2</td>
							<td class="blueColor" width="10%">3</td>
							<td class="blueColor" width="10%">4</td>
							<td class="blueColor" width="10%">5</td>
							<td class="blueColor" width="10%">6</td>
						</tr>
						<tr align="center">
							<td class="tbBlue3">&gt= 780</td>
							<td class="tbBlue3">750~779</td>
							<td class="tbBlue3">720~749</td>
							<td class="tbBlue3">660~719</td>
							<td class="tbBlue3">&lt= 659</td>
							<td class="tbBlue3">0</td>
						</tr>
						<tr align="center">
							<td class="tbBlue" rowspan="5" align="center">違<br>約<br>機<br>率<br>(新)</td>
							<td class="blueColor">1</td>
							<td class="tbBlue3">&lt= 17.989%</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow">II</td>
						</tr>
						<tr align="center">
							<td class="blueColor">2</td>
							<td class="tbBlue3">17.989%~29.632%</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbBlue2">IV</td>
							<td class="tbYellow0">III</td>
						</tr>
						<tr align="center">
							<td class="blueColor">3</td>
							<td class="tbBlue3">29.632%~45.935%</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
						</tr>
						<tr align="center">
							<td class="blueColor">4</td>
							<td class="tbBlue3">45.935%~64.254%</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
						</tr>
						<tr align="center">
							<td class="blueColor">5</td>
							<td class="tbBlue3">&gt 64.254%</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
						</tr>
					</table>
					<table id="table_E_1" border="0" cellpadding="0" cellspacing="1" class="tbBlue" style="display:none;">
						<tr>
							<td colspan="2" rowspan="3">&nbsp;</td>
							<td align="center" rowspan="3">理財型<br>(Base Value=<span id="BASE_VALUE_1"></span>)</td>
							<td align="center" colspan="7">GFICO Score(110/5/1 改版)</td>
						</tr>
						<tr>
							<td class="blueColor" width="10%">1</td>
							<td class="blueColor" width="10%">2</td>
							<td class="blueColor" width="10%">3</td>
							<td class="blueColor" width="10%">4</td>
							<td class="blueColor" width="10%">5</td>
							<td class="blueColor" width="10%">6</td>
						</tr>
						<tr align="center">
							<td class="tbBlue3">&gt= 780</td>
							<td class="tbBlue3">750~779</td>
							<td class="tbBlue3">720~749</td>
							<td class="tbBlue3">660~719</td>
							<td class="tbBlue3">&lt= 659</td>
							<td class="tbBlue3">0</td>
						</tr>
						<tr align="center">
							<td class="tbBlue" rowspan="3" align="center">違<br>約<br>機<br>率<br>(新)</td>
							<td class="blueColor">1</td>
							<td class="tbBlue3">&lt= 38.214%</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue2">IV</td>
						</tr>
						<tr align="center">
							<td class="blueColor">2</td>
							<td class="tbBlue3">38.214%~50.174%</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
						</tr>
						<tr align="center">
							<td class="blueColor">3</td>
							<td class="tbBlue3">&gt 50.174%</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
						</tr>
					</table>
					<table id="table_E_2" border="0" cellpadding="0" cellspacing="1" class="tbBlue" style="display:none;">
						<tr>
							<td colspan="2" rowspan="3">&nbsp;</td>
							<td align="center" rowspan="3">混和型<br>(Base Value=<span id="BASE_VALUE_2"></span>)</td>
							<td align="center" colspan="7">GFICO Score(110/5/1 改版)</td>
						</tr>
						<tr>
							<td class="blueColor" width="10%">1</td>
							<td class="blueColor" width="10%">2</td>
							<td class="blueColor" width="10%">3</td>
							<td class="blueColor" width="10%">4</td>
							<td class="blueColor" width="10%">5</td>
							<td class="blueColor" width="10%">6</td>
						</tr>
						<tr align="center">
							<td class="tbBlue3">&gt= 780</td>
							<td class="tbBlue3">750~779</td>
							<td class="tbBlue3">720~749</td>
							<td class="tbBlue3">660~719</td>
							<td class="tbBlue3">&lt= 659</td>
							<td class="tbBlue3">0</td>
						</tr>
						<tr align="center">
							<td class="tbBlue" rowspan="3" align="center">違<br>約<br>機<br>率<br>(新)</td>
							<td class="blueColor">1</td>
							<td class="tbBlue3">&lt= 37.779%</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow">II</td>
							<td class="tbYellow">II</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
						</tr>
						<tr align="center">
							<td class="blueColor">2</td>
							<td class="tbBlue3">37.779%~52.132%</td>
							<td class="tbYellow2">I</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbYellow0">III</td>
							<td class="tbBlue">V</td>
							<td class="tbBlue">V</td>
						</tr>
						<tr align="center">
							<td class="blueColor">3</td>
							<td class="tbBlue3">&gt 52.132%</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue2">IV</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
							<td class="tbBlue3">VI</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
</form>	
<form id="form4" name="form4">
	<div id="INFO" style="display:none;">
	<table style="width:100%">
		<tr>
			<td style="text-align:center; vertical-align:top; width:50%">
				<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				   <tr>
			         <td width="25%" class="tbYellow" colspan="2"><strong>變數</strong></td>
			         <td width="25%" class="tbYellow" ><strong>變數值</strong></td>
			       </tr>
			       <!-- 基本資料 -->
			       <tr>
			         <td width="5%" rowspan="7" class="tbYellow">
			         	<div align="center"><strong>基<br>本<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>年齡</strong></div></td>
			         <td class="tbYellow2" ><span id="AGE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>學歷</strong></div></td>
			         <td class="tbYellow2" ><span id="DEGREE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>婚姻</strong></div></td>
			         <td class="tbYellow2" ><span id="MARRY_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>職業</strong></div></td>
			         <td class="tbYellow2" ><span id="OCCU_CODE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>工作年資</strong></div></td>
			         <td class="tbYellow2" ><span id="SERV_YEAR_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>擔保品位置</strong></div></td>
			         <td class="tbYellow2" ><span id="CITY_CODE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>擔保品使用情形</strong></div></td>
			         <td class="tbYellow2" ><span id="USE_STATUS_DESC"></span></td>
			       </tr>
			       <!-- 聯徵資訊 -->
			       <tr>
			         <td width="5%" rowspan="7" class="tbYellow">
			         	<div align="center"><strong>聯<br>徵<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>是否擔任保人</strong></div></td>
			         <td class="tbYellow2" ><span id="GUARANTOR_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>信用卡是否延遲繳款</strong></div></td>
			         <td class="tbYellow2" ><span id="LATE_PAYMENTS_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>信用卡卡循比</strong></div></td>
			         <td class="tbYellow2" ><span id="PERM_LIMIT_3_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否動用現金卡</strong></div></td>
			         <td class="tbYellow2" ><span id="UTILIZATION_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否有信貸</strong></div></td>
			         <td class="tbYellow2" ><span id="FIDUCIARY_LOAN_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>收支比</strong></div></td>
			         <td class="tbYellow2" ><span id="EXPENSE_RATES_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>負債收入比</strong></div></td>
			         <td class="tbYellow2" ><span id="LOANAMTINCOME_DESC"></span></td>
			       </tr>
			       <!-- 保險資訊 -->
			       <tr>
			         <td width="5%" rowspan="7" class="tbYellow">
			         	<div align="center"><strong>保<br>險<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>是否有保單貸款</strong></div></td>
			         <td class="tbYellow2" ><span id="INSU_LOAN_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>保費是否墊繳</strong></div></td>
			         <td class="tbYellow2" ><span id="INSU_AUTOLOAN_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>保費是否催繳</strong></div></td>
			         <td class="tbYellow2" ><span id="INSU_URGEPAY_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否投保壽險</strong></div></td>
			         <td class="tbYellow2" ><span id="LOB_RKZ1_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否投保健康險</strong></div></td>
			         <td class="tbYellow2" ><span id="LOB_RKZ2_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否投保投資型壽險</strong></div></td>
			         <td class="tbYellow2" ><span id="LOB_RKZ5_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否投保投資型年金險</strong></div></td>
			         <td class="tbYellow2" ><span id="LOB_RKZ6_DESC"></span></td>
			       </tr>
			       <!-- 申貸資料 -->
			       <tr>
			         <td width="5%" rowspan="7" class="tbYellow">
			         	<div align="center"><strong>申<br>貸<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>借款用途</strong></div></td>
			         <td class="tbYellow2" ><span id="LOAN_POS_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>借款金額</strong></div></td>
			         <td class="tbYellow2" ><span id="GAGELOANM_AMT_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>貸款種類</strong></div></td>
			         <td class="tbYellow2" ><span id="MM_CODE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>還款方式</strong></div></td>
			         <td class="tbYellow2" ><span id="RETURN_TYPE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否為員工貸款</strong></div></td>
			         <td class="tbYellow2" ><span id="EMPLOYEE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>保人關係</strong></div></td>
			         <td class="tbYellow2" ><span id="GUAR_CODE_DESC"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>是否享有保戶優惠</strong></div></td>
			         <td class="tbYellow2" ><span id="INSU_NOTE_DESC"></span></td>
			       </tr>
				</table>
			</td>
			<td style="text-align:center; vertical-align:top; width:50%">
				<table id="table_F" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				   <tr>
			         <td width="12%" class="tbYellow" ><strong>構面</strong></td>
			         <td width="23%" class="tbYellow" ><strong>變數</strong></td>
			         <td width="15%" class="tbYellow" ><strong>變數值</strong></td>
			         <td width="20%" class="tbYellow" >
			         	<strong>變數標註</strong>
			         	<button class="button" type="button" id="BTN_display">顯示Shap值</button>
			         </td>
			         <td width="15%" class="tbYellow" name="hiddenShap" style="display: none"><strong>變數Shap</strong></td>
			         <td width="15%" class="tbYellow" ><strong>構面Shap</strong></td>
			       </tr>
			       <!-- 基本資料 -->
			       <tr>
			         <td width="5%" rowspan="5" class="tbYellow">
			         	<div align="center"><strong>基<br>本<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>年齡(歲)</strong></div></td>
			         <td class="tbYellow2"  align="right"><span id="AGE_NEW"></span></td>
			         <td class="tbYellow2" style="text-align:center" align="right"><span id="AGE_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" name="hiddenShap" style="display: none" align="right"><span id="AGE_SHAP"></span></td>
			         <td class="tbBlue2" rowspan="5" align="right"><span id="INFO_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>學歷</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="DEGREE_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="DEGREE_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="DEGREE_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>婚姻</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="MARRY_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="MARRY_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="MARRY_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>職業</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="OCCU_CODE_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="OCCU_CODE_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="OCCU_CODE_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>工作年資(含前職)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="SERV_YEAR_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="SERV_YEAR_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="SERV_YEAR_SHAP"></span></td>
			       </tr>
			       <!-- 申貸資訊 -->
			       <tr>
			         <td width="5%" rowspan="3" class="tbYellow">
			         	<div align="center"><strong>申<br>貸<br>資<br>訊<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>借款用途</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOAN_POS_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOAN_POS_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOAN_POS_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="3"><span id="LOAN_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>還款方式</strong></div></td>
			         <td class="tbYellow2" align="right" ><span id="RETURN_TYPE_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="RETURN_TYPE_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="RETURN_TYPE_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>借款申請書申貸金額(萬元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOAN_AMT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOAN_AMT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOAN_AMT_SHAP"></span></td>
			       </tr>
			       <!-- 償還能力 -->
			       <tr>
			         <td width="5%" rowspan="3" class="tbYellow">
			         	<div align="center"><strong>償<br>還<br>能<br>力<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>保人關係</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="GUAR_RELATION_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="GUAR_RELATION_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="GUAR_RELATION_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="3"><span id="ABILITY_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>收支比</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="EXPENSE_RATE_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="EXPENSE_RATE_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="EXPENSE_RATE_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>負債收入比</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOANAMTINCOME_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOANAMTINCOME_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOANAMTINCOME_SHAP"></span></td>
			       </tr>
			       <!-- 授信紀錄 -->
			       <tr>
			         <td width="5%" rowspan="5" class="tbYellow">
			         	<div align="center"><strong>授<br>信<br>紀<br>錄<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>已貸金額(萬元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="GAGE_AMT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="GAGE_AMT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="GAGE_AMT_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="5"><span id="CREDIT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>現金卡使用比例</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="CASHUSING_RATIO_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="CASHUSING_RATIO_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="CASHUSING_RATIO_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>信貸、非擔保放款金額(千元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="FIDUCIARY_AMT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="FIDUCIARY_AMT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="FIDUCIARY_AMT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>從債務金額(千元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="GUARANTOR_AMT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="GUARANTOR_AMT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="GUARANTOR_AMT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>擔保人關係</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="REL_CODE_SEG_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="REL_CODE_SEG_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="REL_CODE_SEG_SHAP"></span></td>
			       </tr>
			       <!-- 信用卡類 -->
			       <tr>
			         <td width="5%" rowspan="5" class="tbYellow">
			         	<div align="center"><strong>信<br>用<br>卡<br>類<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>延遲繳款紀錄</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LATE_PAYMENT_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LATE_PAYMENT_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LATE_PAYMENT_CNT_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="5"><span id="CARD_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>歷史最高額度(千元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="PERM_LIMIT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="PERM_LIMIT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="PERM_LIMIT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近一年帳單金額合計(元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="PAYABLE_SUM_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="PAYABLE_SUM_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="PAYABLE_SUM_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近1~6個月各月卡循比(註:顯示1st)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="CYC_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="CYC_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="CYC_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>六個月間卡循比斜率</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="CYC_M_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="CYC_M_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="CYC_M_SHAP"></span></td>
			       </tr>
			       <!-- 投保類型 -->
			       <tr>
			         <td width="5%" rowspan="4" class="tbYellow">
			         	<div align="center"><strong>投<br>保<br>類<br>型<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>曾投保壽險保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOB1_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOB1_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOB1_POL_CNT_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="4"><span id="LOB_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>曾投保健康險保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOB2_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOB2_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOB2_POL_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>曾投保投資型壽險保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOB5_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOB5_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOB5_POL_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>曾投保投資型年金險保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOB6_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOB6_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOB6_POL_CNT_SHAP"></span></td>
			       </tr>
			       <!-- 保單交易 -->
			       <tr>
			         <td width="5%" rowspan="10" class="tbYellow">
			         	<div align="center"><strong>保<br>單<br>交<br>易<br></strong></div>
			         </td>
			         <td class="tbYellow" ><div align="left"><strong>年繳保費(萬元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="TOTAL_PREMIUM_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="TOTAL_PREMIUM_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="TOTAL_PREMIUM_SHAP"></span></td>
			         <td class="tbBlue2" align="right" rowspan="10"><span id="INSURANCE_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單貸款次數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="INSU_LOAN_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="INSU_LOAN_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="INSU_LOAN_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年申請保單貸款的保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOAN_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOAN_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOAN_POL_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>最後一次保單貸款的餘額(元)</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LOAN_BAL_SUM_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LOAN_BAL_SUM_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LOAN_BAL_SUM_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單墊繳次數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id=AP_CNT_NEW></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="AP_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="AP_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單墊繳的保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="AP_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="AP_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="AP_POL_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單墊繳餘額</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="AP_BAL_SUM_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="AP_BAL_SUM_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="AP_BAL_SUM_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單慛繳次數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="URGEPAY_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="URGEPAY_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="URGEPAY_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年保單停效次數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LAPSE_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LAPSE_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LAPSE_CNT_SHAP"></span></td>
			       </tr>
			       <tr>
			         <td class="tbYellow" ><div align="left"><strong>近2年停效保單數</strong></div></td>
			         <td class="tbYellow2" align="right"><span id="LAPSE_POL_CNT_NEW"></span></td>
			         <td class="tbYellow2" align="right" style="text-align:center"><span id="LAPSE_POL_CNT_SHAP_TOP6"></span></td>
			         <td class="tbYellow2" align="right" name="hiddenShap" style="display: none"><span id="LAPSE_POL_CNT_SHAP"></span></td>
			       </tr>
				</table>
			</td>
		</tr>
	</table>
	   	
	</div>
</form>	
</body>
</html>
