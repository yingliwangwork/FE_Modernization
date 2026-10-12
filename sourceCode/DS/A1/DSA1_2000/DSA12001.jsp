<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%-- 
程式：DSA12001.jsp
作者：簡辰宇
功能：文初檢核表分頁畫面
完成：2023/10/20
更新：
[20240322] 問題單:20240322115438 移除權狀註記事項欄位
[20241106]文初檢核表-查詢優化:查詢法金案件時有BUG(數字開頭在js是不合法)
--%>
<html>
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--匯入外部Javascript 與 css-->
<title></title>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />

<style>

input:read-only, 
textarea:read-only {
    border: groove !important;
}

</style>

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/tabs.js"></script>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/date.js"></script>
<%--[20240723]難字css  --%>
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

Event.observe(window, 'load', new DSA12001().initApp);

function DSA12001(){

	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA1_2001/');
	var externalListResult = [];
	var APPLY_ID = "${APPLY_ID}";
	var loanTypeTra = "${loanTypeTra}";
	var valid1;
	var isCalculate = false;
	var tempIdList = [""] <%-- 查詢時記錄借款人/保證人有多少人--%>
	var link_jud = "${link_jud}";//監輔宣告
	var link_bus1 = "${link_bus1}";//營登查詢1
	var link_bus2 = "${link_bus2}";//營登查詢2
	var link_cle = "${link_cle}";//票交所查詢
	
	<%-- 按鈕權限 --%>
	var buttonAuth = function(){
		var authButtons = {
			B0003 : 'btn_insert',		<%--新增--%>	
			B0004 : 'btn_update'		<%--修改--%>		
		};
		<dz:grantButtons FUNC_ID='DSA12001'/>
	};
	<%-- 檢核1 --%>
    var mapping1 = {
            "LEVEL_CH":"高風險等級",
            "INSU_RELATION":"保險法利害關係人",
            "FHC_RELATION":"金控法利害關係人",
            "SPC_CTR_BOR":"特殊件控管紀錄",
            "NEW_CON_3M":"近 3 個月有新契約投保",
            "HEALTHY_ERR":"健康情形異常或無資料",
            "ILLITERATE":"不識字"
        }
	<%-- 檢核1: 聯徵相關檢核 --%>
    var mapping1_2 = {
            "JCIC_REPORT":"聯徵通報及補充註記異常",
            "JCIC_CHECK":"聯徵授信異常紀錄",
            "JCIC_REJECT":"聯徵拒往、退票紀錄",
            "CH_JUDICIAL":"監護輔助宣告",
            "CASH_CARD_PASS":"現金卡逾期遲繳",
            "CREDIT_CARD_CLS":"信用卡強停",
            "CREDIT_CARD_ERR":"信用卡使用異常"
        }
	
	<%-- 檢核2_5 --%>
    var mapping2 = {
    		"LOAN_ERR_BOR": "契約效力異常",
    		"PAY_6P_BOR": "近六期繳息異常",
    		"PAY_5Y_BOR": "近五年曾繳息異常",
    		"CLAIM_COSTS_BOR": "有裁定費用",
    		"LOAN_CTR_BOR": "特殊件控管紀錄",
    		"LOAN_ERR_GUA": "契約效力異常",
    		"PAY_6P_GUA": "近六期繳息異常",
    		"PAY_5Y_GUA": "近五年曾繳息異常",
    		"CLAIM_COSTS_GUA": "有裁定費用",
    		"LOAN_CTR_GUA": "特殊件控管紀錄",
        }
    
	<%-- 檢核2_5 for update --%>
    var LOAN_BOR_TITLE = "借款債務-";
    var mapping3 = {
    		"LOAN_ERR_BOR": LOAN_BOR_TITLE + "契約效力異常",
    		"PAY_6P_BOR": LOAN_BOR_TITLE + "近六期繳息異常",
    		"PAY_5Y_BOR": LOAN_BOR_TITLE + "近五年曾繳息異常",
    		"CLAIM_COSTS_BOR": LOAN_BOR_TITLE + "有裁定費用",
    		"LOAN_CTR_BOR": LOAN_BOR_TITLE + "特殊件控管紀錄"
        }
    
	<%-- 檢核2_5 for update --%>
    var LOAN_GUA_TITLE = "保證債務-";
    var mapping4 = {
    		"LOAN_ERR_GUA": LOAN_GUA_TITLE + "契約效力異常",
    		"PAY_6P_GUA": LOAN_GUA_TITLE + "近六期繳息異常",
    		"PAY_5Y_GUA": LOAN_GUA_TITLE + "近五年曾繳息異常",
    		"CLAIM_COSTS_GUA": LOAN_GUA_TITLE + "有裁定費用",
    		"LOAN_CTR_GUA": LOAN_GUA_TITLE + "特殊件控管紀錄"
        }
    	
	<%-- 檢核2~4 --%>
	var checkboxList = [
		'PENDING_CASE','CREDIT_REJ','GAGE_DIF_3M','FIRST_BUY','PAYOFF_3M',
		'BUY_INSURANCE','ILL_APP',
		<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
		<%--'DEBT_CODE',--%>
		'LIMIT_CODE','NORMAL_CODE','ASS_SET_MORT','ROC_CLAIMANT',
		'MAX_LIM_MORT','RUR_EXP','READJUST','LAND_OTHER','MUTI_BUD_NM',
		'HOLD_PART','SPACE_L5','IS_FARMHOUSE','IS_BRICK','OWN_NO_CON',
		'REG_DATE_L1Y','SPC_LOAN',
		
		'BALC_CHK','GAGE_REJ','SPACE_REJ',
		
		'ADD_NO_CL','ADD_NOT_CL','TWO_LOAN','NO_LIMIT_CL','NO_RANGE_CL',
		'CNT_REJ_CL','BLD_REJ','BLD_REJ_OTHER',
		
		<%--'APPLY_INPUT','BORROW_INPUT','GUAR_INPUT','DATA_INPUT',--%>
		'RELATION',	'BOR_BUS_OPR',
		
		'LOAN_STATUS_ERR','PAY_STA_6P','PAY_STA_5Y','CLAIM_COSTS','SPC_CTR_LOAN'
	];

	var withoutRedCheckboxList= [
		'BORROW_POS01','COUPLE_POS01','CHILD_POS01','RELATIVE_POS01',
	];
	
	var checkboxList2_3 = [
		'SPC_LOAN','PENDING_CASE','CREDIT_REJ','GAGE_DIF_3M','FIRST_BUY','PAYOFF_3M',
		'BUY_INSURANCE','ILL_APP'
	];

	var checkboxList2_4 = [
		'LOAN_STATUS_ERR','PAY_STA_6P','PAY_STA_5Y','CLAIM_COSTS','SPC_CTR_LOAN'
	];
	
	var checkboxList3 = [
		<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
		<%--'DEBT_CODE',--%>
		'LIMIT_CODE','NORMAL_CODE','ASS_SET_MORT','ROC_CLAIMANT',
		'MAX_LIM_MORT','RUR_EXP','READJUST','LAND_OTHER','MUTI_BUD_NM',
		'HOLD_PART','SPACE_L5','IS_FARMHOUSE','IS_BRICK','OWN_NO_CON',
		'REG_DATE_L1Y',
		
		'BALC_CHK','GAGE_REJ','SPACE_REJ',
		
		'ADD_NO_CL','ADD_NOT_CL','TWO_LOAN','NO_LIMIT_CL','NO_RANGE_CL',
		'CNT_REJ_CL','BLD_REJ','BLD_REJ_OTHER'
	];
	
	var checkboxList4 = [
		<%--'APPLY_INPUT','BORROW_INPUT','GUAR_INPUT','DATA_INPUT',--%>
		'RELATION',	'BOR_BUS_OPR'
	];

	<%-- 各 checkbox 對應的異常分類項目 --%>
	//[文初檢核表上線後優化_V3]「異常項目」文字改為「注意項目」，且調整分類，連同PDF也要做調整
    var exception_mapping = {
			// 試算1 
            "LEVEL_CH":"1",
            "INSU_RELATION":"1",
            "FHC_RELATION":"1",
            "SPC_CTR_BOR":"4",
            "NEW_CON_3M":"4",//近 3 個月有新契約投保:內外規範>提醒訊息
            "HEALTHY_ERR":"4",
            "ILLITERATE":"4",

			// 試算1_2 聯徵
            "JCIC_REPORT":"2",
            "JCIC_CHECK":"2",
            "JCIC_REJECT":"2",
            "CH_JUDICIAL":"2",
            "CASH_CARD_PASS":"2",
            "CREDIT_CARD_CLS":"2",
            "CREDIT_CARD_ERR":"2",

			// 試算2 借款債務
			"LOAN_ERR_BOR":"2",
			"PAY_6P_BOR":"2",
			"PAY_5Y_BOR":"2",
			"CLAIM_COSTS_BOR":"2",
			"LOAN_CTR_BOR":"4",

			// 試算2_2 保證債務
			"LOAN_ERR_GUA":"2",
			"PAY_6P_GUA":"2",
			"PAY_5Y_GUA":"2",
			"CLAIM_COSTS_GUA":"2",
			"LOAN_CTR_GUA":"4",

			// 試算2_3 案件受理情形
			"PENDING_CASE":"4",
			"CREDIT_REJ":"4",
			"GAGE_DIF_3M":"4",
			"FIRST_BUY":"4",
			"PAYOFF_3M":"4",
			"BUY_INSURANCE":"4",
			"ILL_APP":"4",
			"SPC_LOAN":"4",

			// 試算2_4 本擔借款情形
			"LOAN_STATUS_ERR":"2",
			"PAY_STA_6P":"2",
			"PAY_STA_5Y":"2",
			"CLAIM_COSTS":"2",
			"SPC_CTR_LOAN":"4",
			<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
			// 試算3
			<%--"DEBT_CODE": "3",--%>  
			"LIMIT_CODE": "3",   
			"NORMAL_CODE": "3",  
			"ASS_SET_MORT": "3", 
			"ROC_CLAIMANT": "3", 
			"MAX_LIM_MORT": "3", 
			"RUR_EXP": "3",      
			"READJUST": "4",//有重劃 (測) 紀錄:擔保品暨謄本>提醒訊息
			"LAND_OTHER": "4",//設定-有其他登記事項:擔保品暨謄本>提醒訊息
			"MUTI_BUD_NM": "4",//兩個 (含) 以上主建號:擔保品暨謄本>提醒訊息
			"HOLD_PART": "3",    
			"SPACE_L5": "3",     
			"IS_FARMHOUSE": "3", 
			"IS_BRICK": "3",     
			"OWN_NO_CON": "3",   
			"REG_DATE_L1Y": "4",//登記日期未超過 1 年:擔保品暨謄本>提醒訊息
			"BALC_CHK": "3",     
			"GAGE_REJ": "3",     
			"SPACE_REJ": "3",    
			"ADD_NO_CL": "3",    
			"ADD_NOT_CL": "3",   
			"TWO_LOAN": "3",     
			"NO_LIMIT_CL": "3",  
			"NO_RANGE_CL": "3",  
			"CNT_REJ_CL": "3",   
			"BLD_REJ": "3",      
			"BLD_REJ_OTHER": "3",

			// 試算4
			//"APPLY_INPUT": "4", 
			//"BORROW_INPUT": "4",
			//"GUAR_INPUT": "4",  
			//"DATA_INPUT": "4",  
			"RELATION": "4",    
			"BOR_BUS_OPR": "4"
        }    
	
    <%--檢核--%>
	function initValidation(){		
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validate'});
		valid2 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validate'});
		valid1.define('validate_COMM_PRICE' , [{ id : "COMM_PRICE" ,errMsg:'房屋金額格式錯誤!!'}] );
		valid1.define('validate_BUY_YM' , [{ id : "BUY_YM" ,errMsg:'購買年月格式錯誤!!'}] );
		valid1.define('validate_SALE_ID' , [{ id : "SALE_ID" ,errMsg:'售屋者 ID格式錯誤!!'}] );
		valid2.define('validate_SALE_ID' , [{ id : "SALE_ID" ,errMsg:'售屋者 ID格式錯誤!!'}] );
	    Validation.addAllThese([
			['validate_COMM_PRICE', '', function(value) {
				var regex = /^[1-9]\d*$/;
				if( isNaN(value) || !regex.test(value)||value=="" ){
					return false
				}
				return true;
			}],
			['validate_BUY_YM', '', function(value) {
			    if (!/^\d{5}$/.test(value)) {
			        return false;
			    }
			    var year = parseInt(value.substr(0, 3), 10) + 1911;
			    var month = parseInt(value.substr(3, 2), 10);
			    var dateObj = new Date(year, month - 1);
			    if (dateObj.getFullYear() == year && dateObj.getMonth() == month - 1) {
			        return true;
			    } else {
			        return false;
			    }	
				return true;
			}],
			['validate_SALE_ID', '', function(value) {
				if( value == ""){//非必輸值
					return true;
				}
				if( value.length == 10 ){//自然人
					return validation.checkID( value );	
				}else if(value.length == 8){//法人
				    return iscmpid( value );
				}else{
					return false
				}
				return true;
			}],
		]);
	};
	
	<%-- 定義事件 --%>
	var buttons = {
			
		doQuery: function() {			
			ajaxRequest.post( 'query', {'APPLY_ID': APPLY_ID}, function(resp) {
				var a010Map = resp.a010Map;
				var a600Map = resp.a600Map;
				var is600 = a600Map ? true : false;				
				var data = is600 ? a600Map : a010Map;
				
				<%-- 同步作業 --%>
				actions.calculateSupply();
				actions.calculateLastSub();
				actions.calculateLoanLog();
				actions.getEmp(data.CH_STATUS);

				
				<%-- 受理影像檢核顯示 --%>
				loanTypeTra = resp.loanTypeTra;
				if(loanTypeTra) {
					<%-- 買賣件 --%>
					if(loanTypeTra.TRAN_ITEM == "1") {
						$("TRAN_ITEM").checked = true;
						$("IMG_PO").removeAttribute("hidden");
					}			
					<%-- 轉貸件 --%>
					if (loanTypeTra.REFI_ITEM == "1") {
						$("REFI_ITEM").checked = true;
						$("IMG_LF").removeAttribute("hidden");
					}		
					<%-- 法拍件 --%>
					if (loanTypeTra.AUCT_ITEM == "1") {
						$("AUCT_ITEM").checked = true;
						$("IMG_AP").removeAttribute("hidden");
					}
				}
				
				<%-- 大部資料 --%>
				APPLY_ID = data.APPLY_ID;
				$('APPLY_ID').innerHTML = APPLY_ID;
				$('BORROW_NAME').innerHTML = a010Map.BORROW_NAME;
				$('LOAN_TYPE').value = a010Map.LOAN_TYPE;
				$('LOAN_TYPE_DOC').innerHTML = a010Map.LOAN_TYPE_DOC;
				$('CH_STATUS').value = data.CH_STATUS;
				$('CH_STATUS_NM').innerHTML = data.CH_STATUS_NM || '';
				$('APPLY_PROCESS').value = a010Map.APPLY_PROCESS;
				$('APPLY_PROCESS_DOC').innerHTML = a010Map.APPLY_PROCESS_DOC;
				$('SEND_DATE').innerHTML = localeDisplay.formatDate(a010Map.SEND_DATE) || "";
				<%-- 買賣件 --%>
				$('CT_SOURCE').value = data.CT_SOURCE ||'';
				$('OVERSEAS_AUTH').value = data.OVERSEAS_AUTH ||"";	
				if (data.OVERSEAS_AUTH === '1') {
					$('OVERSEAS_AUTH').setAttribute("style","color:red");
				}
				if(a600Map){
					$('INPUT_NAME').innerHTML = a600Map.INPUT_NAME || "";
					$('INPUT_TIME').innerHTML = localeDisplay.formatTimestamp(a600Map.INPUT_TIME) || "";
				}
				
				<%-- 借款人姓名 
				var borrowNames = document.getElementsByClassName("borrowNames");
				for(var i=0; i<borrowNames.length; i++) {
					borrowNames[i].innerHTML = data.BORROW_NAME;
				}
				--%>		
				
				var radioBtnList = ['PARAMS_6P','EST_TRA_DOC'];
				actions.setRadioBtnList(radioBtnList, data, false);
				var TextList = ['MEMO','CT_NOTE','COMM_PRICE','BUY_YM','PARK_NO','PARK_NO','SALE_ID','SALE_NAME','SPC_MEMO'];
				actions.setTextList(TextList, data, false);
				
				<%-- 檢核3 --%>
				<%-- 土地分區 --%>
				var a040Users = resp.a040Users;
				if(a040Users && a040Users.length > 0){
					$('A040USERS').innerHTML = ''
					var temp = ''
					for (var i = 0; i < a040Users.length; i++) {
						temp = temp + a040Users[i] + ';'
					}
					temp = temp.lastIndexOf(';') > -1 ? temp.substring(0, temp.lastIndexOf(';')) : temp;
					$('A040USERS').innerHTML = temp;
				}
				
				<%-- 其他登記事項 --%>
				var num = 0;
				<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
				var arr = [
					<%--'DEBT_CODE',--%>'LIMIT_CODE','NORMAL_CODE','ASS_SET_MORT','ROC_CLAIMANT',
					'MAX_LIM_MORT','RUR_EXP','READJUST','LAND_OTHER'
				];
				
				for(var i=0; i<arr.length; i++) {
					num += actions.getCheckBox(arr[i]) == 1 ? 1 : 0;
				}
				
				if(is600){
					actions.setCheckBoxList(checkboxList, data, withoutRedCheckboxList); //原本的set
				}else{
					var memo = resp.memo;
					var isMemo = memo ? true : false;
					if(isMemo){
						$('MEMO').value = memo;
					}
				}
				
				<%-- 檢核1,  檢核2 本擔借款情形 --%>
				var a020List = resp.a020List;
				var a610List = resp.a610List;
 				var is610 = resp.a610List ? true : false;
				var data = is610 ? a610List : a020List;
				
				if(a600Map && a600Map.CH_STATUS === '1'){
					<%-- 已輸入狀態情境, 不需要進行試算 --%>
					if (is610) {
						actions.setCal(a610List, "CAL1_1", mapping1, "cal1List", "checkList1", true);
						actions.setCal(a610List, "CAL1_1", mapping1_2, "cal1List", "checkList1_2", true);
							
						for(var i=0; i<a610List.length; i++) {
							tempIdList.push(a610List[i].ID); <%-- 查詢時記錄借款人/保證人的ID，判斷異常項目時需要使用到 for exceptionItems()--%>
							var div = document.createElement("div");
							<%-- 借款債務 --%>
					        var obj = a610List[i].LOAN_BOR_MAP; 
					        obj['ID'] = a610List[i].ID;
					        obj['TYPE'] = a610List[i].TYPE;
					        obj['NAME'] = a610List[i].NAME;
					        obj['GUAR_KIND'] = a610List[i].GUAR_KIND;
					        obj['USER_TYPE_NAME'] = a610List[i].USER_TYPE_NAME;
					        actions.setCal([obj], "CAL2_5", mapping3, "cal2_51List", "checkList2"); 
					        <%-- 保證債務 --%>
					        var obj2 = a610List[i].LOAN_GUA_MAP;
					        obj2['ID'] = a610List[i].ID;
					        obj2['TYPE'] = a610List[i].TYPE;
					        obj2['NAME'] = a610List[i].NAME;
					        obj2['GUAR_KIND'] = a610List[i].GUAR_KIND;
							obj2['USER_TYPE_NAME'] = a610List[i].USER_TYPE_NAME;
					        actions.setCal([obj2], "CAL2_5", mapping4, "cal2_52List", "checkList2");   
						}
			        }
					actions.createExceptionItemDiv();
					actions.exceptionItems(document.getElementsByName("checkList3"));
					actions.exceptionItems(document.getElementsByName("checkList4"));
					actions.exceptionItems(document.getElementsByName("checkList1"));
					actions.exceptionItems(document.getElementsByName("checkList1_2"));
					actions.exceptionItems(document.getElementsByName("checkList2"));
					actions.exceptionItems(document.getElementsByName("checkList2_3"));
					actions.exceptionItems(document.getElementsByName("checkList2_4"));
					
					<%-- 外部資料查詢 開始--%>
	 				actions.calculateBuss(data);
				} else{
					<%-- 非已輸入狀態情境, 需要進行試算 --%>
					actions.calculate1();
					actions.calculate2();
					actions.calculate2_3();
					actions.calculate2_4();
					actions.calculate3();
					actions.calculate4();
					actions.calculate1_2();
					actions.calculate2_2();
					actions.calculateEDQ();
				}
				
				tempIdList = [""];<%-- 清空後再重新紀錄--%>
				for(var i=0; i<a020List.length; i++) {
					tempIdList.push(a020List[i].ID); <%-- 查詢時記錄借款人/保證人的ID，判斷異常項目時需要使用到 for exceptionItems()--%>
				}
				
				<%-- 試算三 登記次序 table ui--%>
				grid.load(resp.bldList || []);
								
				<%-- 待是否送出即試算檢查 --%>
				actions.doCheckUpdate();
				
				<%-- read only 基本資料檢核  --%>
				actions.doReadOnly();
				
			});

		},
		doCalculate: function() {
			isCalculate = true;
			<%-- 同步作業 --%>
			actions.calculateSupply();
			actions.calculateLastSub();
			actions.calculateLoanLog();
			actions.getEmp($('CH_STATUS').value);
			actions.calculate1();
			actions.calculate2();
			actions.calculate2_2();
			actions.calculate2_3();
			actions.calculate2_4();
			actions.calculate3();
			actions.calculate4();
			actions.calculate1_2();
			actions.calculateEDQ();
			actions.doCheckUpdate();
		},
		doInsert: function() {
			var CH_STATUS = $('CH_STATUS').value;
			
			if(CH_STATUS === '1'){
				alert("無法再次新增，修改資料請點選修改鈕");	
				return
			}
			
			var isCheckItem = actions.isCheckItem();
			
			if(!valid1.validate()){
				return
			}
			
			var reqMap600 = actions.get600Map();
			reqMap600.CH_STATUS = '1'; // 送出狀態=已輸入
			
			if(isCheckItem) {
				// 送出狀態為空字串時, 表示DB無資料,執行新增
				if (CH_STATUS === '') {
					ajaxRequest.post('insert', {
						'applyID': $('APPLY_ID').textContent,
						'reqMap600': Object.toJSON(reqMap600),
						'reqMap610': Object.toJSON(actions.get610Map())
					},
					function(resp) {
						alert("新增完成")		
						var LP_JSON = {
							action:'${dispatcher}/DSA1_2001/prompt',
							APPLY_ID: APPLY_ID,
							isLinkTo: true
						};
						CSRUtil.linkTo(LP_JSON, 'form1');
						
					})				
				
				} else if(CH_STATUS === '0'){
					// 送出狀態為未輸入, 執行更新(因DB已經存有資料)
					ajaxRequest.post('update', {
						'applyID': $('APPLY_ID').textContent,
						'reqMap600': Object.toJSON(reqMap600),
						'reqMap610': Object.toJSON(actions.get610Map())
					},
					function(resp) {
						alert("修改完成")
						
						var LP_JSON = {
							action:'${dispatcher}/DSA1_2001/prompt',
							APPLY_ID: APPLY_ID,
							isLinkTo: true
						};
						CSRUtil.linkTo(LP_JSON, 'form1');
						
					})		
				}
			}

			
		},
		doUpdate: function() {
			var CH_STATUS = $('CH_STATUS').value;
		
			// 是否送出為已輸入時, 要先試算才能修改
			if(CH_STATUS === '1' && !isCalculate){
				alert("請先試算，再進行修改!");
				return
			}
			
			// 是否送出狀態為已輸入, 才需要檢核必填欄位
			if(CH_STATUS === '1' && !valid1.validate()){
				return;
			}
			
			if(!valid2.validate()){
				return
			}
			var reqMap600 = actions.get600Map();
			
			// 送出狀態為空字串時, 表示DB無資料,執行暫存(新增資料)  
			if (CH_STATUS === '') {
				reqMap600.CH_STATUS = '0';
				ajaxRequest.post('insert', {
					'applyID': $('APPLY_ID').textContent,
					'reqMap600': Object.toJSON(reqMap600),
					'reqMap610': Object.toJSON(actions.get610Map())
				},
				function(resp) {
					alert("新增完成")		
					var LP_JSON = {
						action:'${dispatcher}/DSA1_2001/prompt',
						APPLY_ID: APPLY_ID,
						isLinkTo: true
					};
					CSRUtil.linkTo(LP_JSON, 'form1');
					
				})				
			} else if(CH_STATUS === '0' || (CH_STATUS === '1' && actions.isCheckItem())) {
				// 送出狀態為未輸入 或是 已輸入且必輸皆輸入時, 執行更新(因DB已經存有資料)
				reqMap600.CH_STATUS = CH_STATUS ;
				ajaxRequest.post('update', {
					'applyID': $('APPLY_ID').textContent,
					'reqMap600': Object.toJSON(reqMap600),
					'reqMap610': Object.toJSON(actions.get610Map())
				},
				function(resp) {
					alert("修改完成")
					
					var LP_JSON = {
						action:'${dispatcher}/DSA1_2001/prompt',
						APPLY_ID: APPLY_ID,
						isLinkTo: true
					};
					CSRUtil.linkTo(LP_JSON, 'form1');
					
				})				
			}
		},
		doGetJCIC : function() {

			popupWin.popup({
				parameters : {'APPLY_ID': APPLY_ID},
				src : '<%=dispatcher%>/DSA2_0410/prompt'
			});
		},
		doVideoLink: function() {

			popupWin.popup({
				parameters : {'APPLY_ID': APPLY_ID, 'fieldName' : 'ITEM6'},
				src : '<%=dispatcher%>/DSA0_0200/prompt'
			});
		},
		doLinkJud: function() {
			window.open(link_jud);
		},
		doLinkBus1: function() {
			window.open(link_bus1);
		},
		doLinkBus2: function() {
			window.open(link_bus2);
		},
		doLinkCle: function() {
			window.open(link_cle);
		},
		doPrint: function() {
			ajaxRequest.post( 'print', { 'APPLY_ID': APPLY_ID }
				,function(resp) {
						RPTUtil.executePrintByResponse(resp, true);
				}
			)
		},
		doChangeOverseaColor: function() {
			var OVERSEAS_AUTH = $('OVERSEAS_AUTH');
			<%-- 海外授權選擇是: 文字顯示紅色; 否則恢復成黑色 --%>
			if (OVERSEAS_AUTH.value === '1') {
				OVERSEAS_AUTH.setAttribute('style','color:red');
			} else {
				OVERSEAS_AUTH.removeAttribute('style','color:red');
			}
		},
		doChangePARAMS_6PColor: function(e) {
			var PARAMS_6Ps = document.getElementsByName('PARAMS_6P')
			for (var i in PARAMS_6Ps) {
				if (PARAMS_6Ps[i].checked && (PARAMS_6Ps[i].id === 'PARAMS_6P_NG' || PARAMS_6Ps[i].id === 'PARAMS_6P_NO')) {
					PARAMS_6Ps[i].parentNode.setAttribute("style", "color: red");
				} else {
					PARAMS_6Ps[i].parentNode.removeAttribute('style','color:red');
				}
			}
		},
		doChangeESTColor: function() {
			var EST_TRA_DOCs = document.getElementsByName('EST_TRA_DOC')
			for (var i in EST_TRA_DOCs) {
				if (EST_TRA_DOCs[i].checked && EST_TRA_DOCs[i].id === 'EST_TRA_DOC_NG') {
					EST_TRA_DOCs[i].parentNode.setAttribute("style", "color: red");
				} else {
					EST_TRA_DOCs[i].parentNode.removeAttribute('style','color:red');
				}
			}
		},
		doChangeEDQColor: function(e) {
			if (e.target.checked && e.target.id.substr(-2) === 'NG' ) {
				e.target.parentNode.setAttribute("style", "color: red");
			} else {
				var arr = document.getElementsByName(e.target.name);
				for (var i in arr) { 
					if (arr[i] && arr[i].parentNode) {
						arr[i].parentNode.removeAttribute('style','color:red');
					}
				}
			}
		}
	};

	var actions = {
	
		doCheckUpdate: function() {	
			var CH_STATUS = $('CH_STATUS').value
			var arr = ["IMG_PO", "table_EDQ", "IMG_LF", "IMG_AP"];<%-- 依序為 買賣件, 外部資料查詢, 轉貸件, 法拍件 --%>
			if(CH_STATUS == '1' && isCalculate == false){
				$('OVERSEAS_AUTH').setAttribute("disabled", true);
				$('MEMO').setAttribute("readonly", true);
				for(var i=0; i<arr.length; i++) {
					var inputs = $(arr[i]).querySelectorAll('input[type="text"]');
					for(var j=0; j<inputs.length; j++) {
						inputs[j].setAttribute("readonly", true);
					}
					
					var selector = $(arr[i]).querySelectorAll("select");
					for(var j=0; j<selector.length; j++) {
						selector[j].setAttribute("disabled", true);
					}
					
					var checkbox = $(arr[i]).querySelectorAll('input[type="checkbox"]');
					for(var j=0; j<checkbox.length; j++) {
						<%-- 1.轉貸件 2.法拍件 3.外部資料查詢 radio、checkbox 不以灰色顯示--%>
						if (arr[i] === "IMG_PO") {
							checkbox[j].setAttribute("disabled", true);
						} else {
							checkbox[j].setAttribute("onclick", "return false");
						}
					}
					
					var radio = $(arr[i]).querySelectorAll('input[type="radio"]');
					for(var j=0; j<radio.length; j++) {
						<%-- 1.轉貸件 2.法拍件 3.外部資料查詢 radio、checkbox 不以灰色顯示--%>
						if (arr[i] === "IMG_PO") {
							radio[j].setAttribute("disabled", true);
						} else {
							radio[j].setAttribute("onclick", "return false");
						}
					}	
				}
			} else {
				$('OVERSEAS_AUTH').removeAttribute("disabled");
				$('MEMO').removeAttribute("readonly");
				for(var i=0; i<arr.length; i++) {
					var inputs = $(arr[i]).querySelectorAll('input[type="text"]');
					for(var j=0; j<inputs.length; j++) {
						inputs[j].removeAttribute('readonly');
					}
					
					var selector = $(arr[i]).querySelectorAll("select");
					for(var j=0; j<selector.length; j++) {
						selector[j].removeAttribute('disabled');
					}
					
					var checkbox = $(arr[i]).querySelectorAll('input[type="checkbox"]');
					for(var j=0; j<checkbox.length; j++) {
						if (arr[i] === "IMG_PO") {
							checkbox[j].removeAttribute('disabled');
						} else {
							checkbox[j].removeAttribute("onclick");
						}
					}
					
					var radio = $(arr[i]).querySelectorAll('input[type="radio"]');
					for(var j=0; j<radio.length; j++) {
						if (arr[i] === "IMG_PO") {
							radio[j].removeAttribute('disabled');
						} else {
							radio[j].removeAttribute("onclick");
						}
					}	
				}
			}
		},
		
		doReadOnly: function() {
			var arr = ["CalTb", "calTb2"];
			for(var i=0; i<arr.length; i++) {
				var checkbox = $(arr[i]).querySelectorAll('input[type="checkbox"]');
				for(var j=0; j<checkbox.length; j++) {
					checkbox[j].setAttribute("disabled", true);
				}
				
				var radio = $(arr[i]).querySelectorAll('input[type="radio"]');
				for(var j=0; j<radio.length; j++) {
					radio[j].setAttribute("disabled", true);
				}
				
			}
			
		},
			
		setCal: function(calList, calName, mapping, title, name, isQuery) {
			for (var i = 0; i < calList.length; i++) {
	            var group = calList[i];
	            var userType = group.USER_TYPE_NAME + '-'; 
	            var userName = group.NAME
	            var userGK = group.GUAR_KIND
	            
				if(calName == "CAL1_1") {
					var div = document.getElementById(group.ID + "_cal1");
					if (!div) {
						<%-- 標題 --%>
						div = document.createElement("div");
						div.setAttribute("type", "cal1");		
						div.setAttribute("style","display: flex;");
						div.setAttribute("id", group.ID + "_cal1");
						
						<%-- 借款人/保證人 - 姓名--%>
			            var TYPE = document.createElement("div");            
			            TYPE.textContent = userType + userName;
			            TYPE.setAttribute("style","width:125px");
			            div.appendChild(TYPE);
					}
					
		            <%-- div id container --%>
		            var idDiv = document.getElementById(group.ID + "_cal1_0");
		            var idDiv1 = document.getElementById(group.ID + "_cal1_1"); <%-- id container 1--%>
		            var idDiv2 = document.getElementById(group.ID + "_cal1_2"); <%-- id container 2--%>
		            if (!idDiv) {
		            	idDiv = document.createElement("div"); 
		            	idDiv.setAttribute("id", group.ID + "_cal1_0");
		            	
		            	idDiv1 = document.createElement("div");
		            	idDiv1.setAttribute("id", group.ID + "_cal1_1");
		            	
		            	idDiv2 = document.createElement("div");
		            	idDiv2.setAttribute("id", group.ID + "_cal1_2");
		            }
					<%-- checkbox --%>
	                for (var key in group) {
	                    if (key !== "NAME" && mapping[key]) {
	                        <%-- checkbox --%>
	                        var input = document.createElement("input");
	                        input.type = "checkbox";
	                        input.id = group.ID + "_" + key;
	                        input.value = key;
	                        input.setAttribute("userid", group.ID);
	                        input.setAttribute("userName", userName);
	                        input.setAttribute("userType", userType);
	                        input.setAttribute("userTypeCode", group.TYPE);
	                        input.setAttribute("userGK", userGK);
	                        input.setAttribute("name", name); 
	                        input.setAttribute("text", mapping[key]);
							
	                        <%-- label --%>
	                        var label = document.createElement("label");
	                        label.htmlFor = group.ID + "_" + key;
	                        label.textContent = mapping[key];
	                        
	                    	<%-- 僅借款人會顯示 高風險等級及近 3 個月有新契約投保 --%>
	                    	if(group.TYPE != '0' && (key == 'LEVEL_CH' || key == 'NEW_CON_3M')){
                                input.hidden = true;
                                label.hidden = true;
	                    	}
	                        
	                        if (group[key] == 1) {
	                            input.setAttribute("checked", "checked");
	                            label.setAttribute("style", "color: red");
	                        }
	                        
	                        <%-- 「聯徵通報及補充註記異常」之後(含)的選項，換行顯示 --%>
	                        if (title == 'cal1List') {
		                        if(isQuery && key === "JCIC_REPORT") {
		                        	idDiv1.appendChild(document.createElement("br"));
		                        }
		                        idDiv1.appendChild(input);
		                        idDiv1.appendChild(label);
	                        } else if (title == 'cal1_2List') {
		                        if(isQuery && key === "JCIC_REPORT") {
		                        	idDiv2.appendChild(document.createElement("br"));
		                        }
		                        idDiv2.appendChild(input);
		                        idDiv2.appendChild(label);
	                        }

	                    }
	                }
	                idDiv.appendChild(idDiv1);
	                idDiv.appendChild(idDiv2);
	                div.appendChild(idDiv);
	                $(calName).appendChild(div);
				} else if (calName == 'CAL2_5') {
					var div = document.getElementById(group.ID + "_cal2_5");
					if (!div) {
						div = document.createElement("div");
						div.setAttribute("id", group.ID + "_cal2_5");	
						<%-- 借款/保證人 --%>
			            var TYPE = document.createElement("span");      
			            TYPE.textContent = group.USER_TYPE_NAME + '-'; 
			            div.appendChild(TYPE);
			            <%-- 姓名 --%>
		                var NAME = document.createElement("span");
			            NAME.textContent = group.NAME;
			            div.appendChild(NAME);
					}
					
					var idDiv = document.getElementById(group.ID + "_cal2_5_0");
					var idDiv1 = document.getElementById(group.ID + "_cal2_5_1");
					var idDiv2 = document.getElementById(group.ID + "_cal2_5_2");
					if (!idDiv) {
						idDiv = document.createElement("div");
						idDiv.setAttribute("id", group.ID + "_cal2_5_0");	
						
						idDiv1 = document.createElement("div");
						idDiv1.setAttribute("id", group.ID + "_cal2_5_1");	
						
						idDiv2 = document.createElement("div");
						idDiv2.setAttribute("id", group.ID + "_cal2_5_2");	
					}
					
					
					var checkboxDiv = document.createElement("div");
					checkboxDiv.setAttribute("type", "cal2_5");			
					
    	            var TYPE2 = document.createElement("span");
    	            TYPE2.textContent = title == "cal2_51List" ? "借款債務-" : "保證債務-";
    	            checkboxDiv.appendChild(TYPE2);
    	            
					<%-- checkbox --%>
	                for (var key in group) {
	                    if (key !== "NAME" && mapping[key]) {
	                        <%-- checkbox --%>
	                        var input = document.createElement("input");
	                        input.type = "checkbox";
	                        input.id = group.ID + "_" + key;
	                        input.value = key;
	                        input.setAttribute("name", name);
	                        input.setAttribute("userid", group.ID);
	                        input.setAttribute("userName", userName);
	                        input.setAttribute("userType", userType);
	                        input.setAttribute("userTypeCode", group.TYPE);
	                        input.setAttribute("text", mapping[key]);

	                        <%-- label --%>
	                        var label = document.createElement("label");
	                        label.htmlFor = group.ID + "_" + key;
	                        var labelText = mapping[key];
	                        if (labelText.indexOf(LOAN_BOR_TITLE) !== -1 || labelText.indexOf(LOAN_GUA_TITLE) !== -1) {
	                        	<%--checkbox 文字不需顯示借款債務 或 保證債務--%>
	                        	labelText = mapping[key].substr(LOAN_BOR_TITLE.length, labelText.length);
	                        } 
	                        label.textContent = labelText;
	                        
	                        if (group[key] == 1) {
	                            input.setAttribute("checked", "checked");
	                            label.setAttribute("style", "color: red");
	                        }
	                        
	                        checkboxDiv.appendChild(input);
	                        checkboxDiv.appendChild(label);
                            
	                        if (title == "cal2_51List") {
		                        idDiv1.appendChild(checkboxDiv);
		                        idDiv1.appendChild(checkboxDiv);
	                        } else if (title == 'cal2_52List') {
		                        idDiv2.appendChild(checkboxDiv);
		                        idDiv2.appendChild(checkboxDiv);
	                        }
	                    }
	                }
	                idDiv.appendChild(idDiv1);
	                idDiv.appendChild(idDiv2);
	                div.appendChild(idDiv);
	                $(calName).appendChild(div);
				}
	        }
			<%-- read only 基本資料檢核  --%>
			actions.doReadOnly(); 
		},
		
		getCal1_1: function() {
			var cal1Divs = document.querySelectorAll('#CAL1_1 [type="cal1"]');
			var results = [];
			var index = 1;

			cal1Divs.forEach(function(div) {
			    var result = {};
			    var id = div.querySelector('input[type="checkbox"]').getAttribute('userid');
			    result.ID = id;
			    result.CH_JUDICIAL = actions.getCheckBox(id + '_CH_JUDICIAL');
			    result.FHC_RELATION = actions.getCheckBox(id + '_FHC_RELATION');
			    result.CREDIT_CARD_CLS = actions.getCheckBox(id + '_CREDIT_CARD_CLS');
			    result.CASH_CARD_PASS = actions.getCheckBox(id + '_CASH_CARD_PASS');
			    result.INSU_RELATION = actions.getCheckBox(id + '_INSU_RELATION');
			    result.HEALTHY_ERR = actions.getCheckBox(id + '_HEALTHY_ERR');
			    result.SPC_CTR_BOR = actions.getCheckBox(id + '_SPC_CTR_BOR');
			    result.JCIC_REPORT = actions.getCheckBox(id + '_JCIC_REPORT');
			    result.JCIC_CHECK = actions.getCheckBox(id + '_JCIC_CHECK');
			    result.CREDIT_CARD_ERR = actions.getCheckBox(id + '_CREDIT_CARD_ERR');
			    result.JCIC_REJECT = actions.getCheckBox(id + '_JCIC_REJECT');
			    result.ILLITERATE = actions.getCheckBox(id + '_ILLITERATE');
				result.NEW_CON_3M = actions.getCheckBox(id + '_NEW_CON_3M'); //僅借款人
				result.LEVEL_CH = actions.getCheckBox(id + '_LEVEL_CH'); //僅借款人
			    results.push(result);
			    i++;
			});

			return results;
		},
		
		getCal2_1: function() {
			<%-- 外部資料查詢 - 取得內容 --%>
	    	var arr = [];
	    	var externalList = ['JUDICIAL', 'BUS_REG', 'CLE_HOU', 'CLE_CORP', 'PRO_QUA'];
	    	var count = document.getElementsByName('JUDICIAL_DESC');
	    	
	    	for (var k=0; k<externalList.length; k++) {
	    		var num = 0;
				for (var i=0; i<count.length; i++) {
					
					<%-- radio btn --%>		
					var name = externalList[k] + "_" + i;
					var buttons = document.getElementsByName(name);
					
					<%-- input text --%>
					var desc = externalList[k] + "_DESC";
					var colDesc = document.getElementsByName(desc)[i].value;
					
					for (var j=0; j<buttons.length; j++) {
						
					  if (buttons[j].checked) {								
							var colObj = {
								'colName': buttons[j].getAttribute('colname'),
								'colValue': buttons[j].getAttribute('status'),
								'colDesc': colDesc
							};
							
							if(arr.length < count.length){
								arr.push({
									'TYPE': buttons[j].getAttribute('usertype'),
									'ID': buttons[j].getAttribute('userid'),
									'NAME': buttons[j].getAttribute('username'),
									'GUAR_KIND': buttons[j].getAttribute('userGK'),
									'RESULT': [colObj]
								});
								
							} else {
								arr[num].RESULT.push(colObj);
							}
							
							num = num + 1;
						}
					}
				}
	    	}
	    	
	    	<%-- 包裝 CAL2_1 --%>		    
	    	var results = [];
	    	for (var i=0; i<arr.length; i++) {
	    		results.push({
		    		'APPLY_ID': APPLY_ID,
		    		'TYPE': arr[i].TYPE,
		    		'ID': arr[i].ID,
		    		'NAME': arr[i].NAME,
		    		'GUAR_KIND': arr[i].GUAR_KIND,
		    		
		    		'JUDICIAL': arr[i].RESULT[0].colValue,
		    		'JUDICIAL_DESC': arr[i].RESULT[0].colDesc,
		    		'BUS_REG': arr[i].RESULT[1].colValue,
		    		'BUS_REG_DESC': arr[i].RESULT[1].colDesc,
		    		'CLE_HOU': arr[i].RESULT[2].colValue,
		    		'CLE_HOU_DESC': arr[i].RESULT[2].colDesc,
		    		'CLE_CORP': arr[i].RESULT[3].colValue,
		    		'CLE_CORP_DESC': arr[i].RESULT[3].colDesc,
		    		'PRO_QUA': arr[i].RESULT[4].colValue,
		    		'PRO_QUA_DESC': arr[i].RESULT[4].colDesc
	    		});
	    	}
	    	
	    	return results;
		},
		
		getCal2_5: function() {
			var cal1Divs = document.querySelectorAll('#CAL2_5 [type="cal2_5"]');
			var results = [];
			var IDs = [];

			cal1Divs.forEach(function(div) {
				var id = div.querySelector('input[type="checkbox"]').getAttribute('userid');
				if(IDs.indexOf(id) == -1){
				    var result = {};
				    result.ID = id;				    				    
				    result.LOAN_ERR_BOR = actions.getCheckBox(id + '_LOAN_ERR_BOR');
				    result.PAY_6P_BOR = actions.getCheckBox(id + '_PAY_6P_BOR');
				    result.PAY_5Y_BOR = actions.getCheckBox(id + '_PAY_5Y_BOR');
				    result.CLAIM_COSTS_BOR = actions.getCheckBox(id + '_CLAIM_COSTS_BOR');
				    result.LOAN_CTR_BOR = actions.getCheckBox(id + '_LOAN_CTR_BOR');
				    result.LOAN_ERR_GUA = actions.getCheckBox(id + '_LOAN_ERR_GUA');
				    result.PAY_6P_GUA = actions.getCheckBox(id + '_PAY_6P_GUA');
				    result.PAY_5Y_GUA = actions.getCheckBox(id + '_PAY_5Y_GUA');
				    result.CLAIM_COSTS_GUA = actions.getCheckBox(id + '_CLAIM_COSTS_GUA');
				    result.LOAN_CTR_GUA = actions.getCheckBox(id + '_LOAN_CTR_GUA');
				    results.push(result);
				    IDs.push(id);
				}
			});
			
			return results;
		},
				
		doToggleBtn: function() {
			$('TRAN_ITEM').addEventListener("click", function() {
				if(this.checked) {
					$('IMG_PO').removeAttribute("hidden");
				}else{
					$('IMG_PO').setAttribute("hidden", "hidden");
				}
			});
			
			$('REFI_ITEM').addEventListener("click", function() {
				if(this.checked) {
					$('IMG_LF').removeAttribute("hidden");
				}else{
					$('IMG_LF').setAttribute("hidden", "hidden");
				}
			});
			
			$('AUCT_ITEM').addEventListener("click", function() {
				if(this.checked) {
					$('IMG_AP').removeAttribute("hidden");
				}else{
					$('IMG_AP').setAttribute("hidden", "hidden");
				}
			});

			<%--買賣件 --%>
			if(loanTypeTra.TRAN_ITEM == "1") {  
				$("IMG_PO").removeAttribute("hidden");
			}
			
			<%--轉貸件 --%>
			if (loanTypeTra.REFI_ITEM == "1") {  
				$("IMG_LF").removeAttribute("hidden");
			}
			
			<%--法拍件 --%>
			if (loanTypeTra.AUCT_ITEM == "1") {
				$("IMG_AP").removeAttribute("hidden");
			}
			
		},
		
		isCheckItem: function() {

			var errMsg = [];
			
			<%-- 海外授權件檢查--%>
			if($('OVERSEAS_AUTH').value == ''){
				errMsg.push("海外授權件，不可為請選擇");
			}
			
			<%-- 買賣件檢查--%>
			if ($('TRAN_ITEM').checked) {
				<%--購買年月 (民國)--%>
				if($F('BUY_YM') == '') {
					errMsg.push("買賣件：購買年月，不可皆為空 ");
				}
				
				<%--房屋 萬元--%>
				if($F('COMM_PRICE') == '') {
					errMsg.push("買賣件：房屋價格，不可皆為空");
				}
				
				<%--買契來源--%>
				if($F('CT_SOURCE') == '') {
					errMsg.push("買賣件：買契來源，不可為請選擇");
				}
			}	
			<%-- 轉貸件檢查--%>
			if ($('REFI_ITEM').checked) {
				<%--近六期繳息紀錄--%>
				if(actions.getRadioBtn('PARAMS_6P') == null) {
					errMsg.push("轉貸件：近六期繳息紀錄，不可皆為空");
				}
				<%--前行庫借款人--%>
				var num = 0;
				var arr = ['BORROW_POS01','COUPLE_POS01','CHILD_POS01','RELATIVE_POS01'];
				for(var i=0; i<arr.length; i++) {
					num += actions.getCheckBox(arr[i]) == 1 ? 1 : 0;
				}
				
				if(num == 0 ) {
					errMsg.push("轉貸件：前行庫借款人，不可皆為空");	
				}
			}
			<%-- 法拍件檢查--%>
			if ($('AUCT_ITEM').checked && actions.getRadioBtn('EST_TRA_DOC') == null ) {
				errMsg.push("法拍件：不動產移轉證明，不可皆為空");
			}
			
			<%-- 外部資料查詢--%>
			var arr = actions.get610Map();
			for(var i=0; i<arr.length; i++) {
				if(arr[i].JUDICIAL === '') {
					errMsg.push("客戶: " + arr[i].NAME + " 監輔宣告，為必查項目");
				} else if(arr[i].JUDICIAL === '1' && arr[i].JUDICIAL_DESC == '') {
					errMsg.push("客戶: " + arr[i].NAME + " 監輔宣告的異常說明，不可為空");
				}
				
				if(arr[i].BUS_REG == 1 && arr[i].BUS_REG_DESC == '') {
					errMsg.push("客戶: " + arr[i].NAME + " 營登查詢的異常說明，不可為空");
				}
				
				if(arr[i].CLE_HOU == 1 && arr[i].CLE_HOU_DESC == '') {
					errMsg.push("客戶: " + arr[i].NAME + " 個人票交所查詢的異常說明，不可為空");
				}
				
				if(arr[i].CLE_CORP == 1 && arr[i].CLE_CORP_DESC == '') {
					errMsg.push("客戶: " + arr[i].NAME + " 公司票交所查詢的異常說明，不可為空");
				}
				
				if(arr[i].PRO_QUA == 1 && arr[i].PRO_QUA_DESC == '') {
					errMsg.push("客戶: " + arr[i].NAME + " 專門職業資格的異常說明，不可為空");
				}
				
			}
			
			var isPass = errMsg.length == 0 ? true : false;
			if(!isPass) {
				var str = "請完成必輸欄位再點選新增，或點選修改做資料暫存\n";
				for(var i=0; i<errMsg.length; i++) {
					str += errMsg[i] + "\n";
				}
				alert(str)
			}
			return isPass
		},		
		setCheckBoxList: function(checkboxList, map, withoutRedCheckboxList) {
			<%-- 將勾選項目打勾並顯示紅色 --%>
			for(var i=0; i<checkboxList.length; i++) {
				var checkboxItem = checkboxList[i];
				if(map[checkboxItem] == '1'){
					$(checkboxItem).checked = true;
					var label = $(checkboxItem).parentNode;
					label.setAttribute("style", "color: red");
				} else {
					$(checkboxItem).checked = false;
					var label = $(checkboxItem).parentNode;
					label.removeAttribute("style");
				}
			}

			<%-- 將勾選項目打勾 不顯示紅色--%>
			if (withoutRedCheckboxList && withoutRedCheckboxList.length > 0){
	 			for(var i=0; i<withoutRedCheckboxList.length; i++) {
					var checkboxItem = withoutRedCheckboxList[i];
					if(map[checkboxItem] == '1'){
						$(checkboxItem).checked = true;
					} else {
						$(checkboxItem).checked = false;
					}
				}
			}

		},
		setRadioBtnList: function(radioBtnList, map, isMultiple) {
			for(var i=0; i<radioBtnList.length; i++) {
				var radioBtnItem = radioBtnList[i];
				if(isMultiple) {
					var arr = ['JUDICIAL','BUS_REG','CLE_HOU','CLE_CORP','PRO_QUA'];
					for(var j=0; j<arr.length; j++) {
						if(map[arr[j]]) {
							if(map[arr[j]] == 0){
								$(radioBtnList[j] + "_OK").checked = 1
							}
							if(map[arr[j]] == 1){
								$(radioBtnList[j] + "_NG").checked = 1
								$(radioBtnList[j] + "_NG").parentNode.setAttribute("style", "color: red");
							}
							if(map[arr[j]] == 2){
								$(radioBtnList[j] + "_NO").checked = 1
							}
						}
					}
				} else {
					if(map[radioBtnItem]) {
						if(map[radioBtnItem] == 0){
							$(radioBtnItem + "_OK").checked = 1
						}
						if(map[radioBtnItem] == 1){
							$(radioBtnItem + "_NG").checked = 1
							$(radioBtnItem + "_NG").parentNode.setAttribute("style", "color: red");
						}
						if(map[radioBtnItem] == 2){
							$(radioBtnItem + "_NO").checked = 1
							$(radioBtnItem + "_NO").parentNode.setAttribute("style", "color: red");
						}
					}
				}
			}
		},
		setTextList: function(textList, map, isMultiple) {
			for(var i=0; i<textList.length; i++) {
				var radioBtnItem = textList[0];
				if(isMultiple) {
					var arr = ['JUDICIAL_DESC','BUS_REG_DESC','CLE_HOU_DESC','CLE_CORP_DESC','PRO_QUA_DESC'];
					for(var j=0; j<arr.length; j++) {
						$(textList[j]).value = map[arr[j]] || "";
					}
				} else {
					for(var j=0; j<textList.length; j++) {
						if(textList[j] == 'BUY_YM' ){
							var tempYm = map['BUY_YM']
							if(tempYm){
								tempYm = Date.toInputROC( tempYm , "-" );
								var buyYm = tempYm.split("-");
								$(textList[j]).value = buyYm[0] + buyYm[1];
							} else {
								$(textList[j]).value = "";
							}
						} else{
							$(textList[j]).value = map[textList[j]] || "";	
						}
					}
				}
			}
		},
		getRadioBtn: function(radioName) {
			var radios = document.getElementsByName(radioName);
			for (var i=0; i<radios.length; i++) {
			  if (radios[i].checked) {
			    return radios[i].value;
			  }
			}
			return null;
		},
		getCheckBox: function(checkbox) {
			return $(checkbox).checked ? '1' : '0';
		},
	    get600Map: function() {
	    	return {
	    		'APPLY_ID': APPLY_ID || '',
				'LOAN_TYPE': $F('LOAN_TYPE') || '',
				'CH_STATUS': $('CH_STATUS').textContent == '未輸入' ? 0 : 1,
				'APPLY_PROCESS': $F('APPLY_PROCESS') || '',
				'INTERNAL_RULES': $('INTERNAL_RULES').getAttribute("value") || '',
				'CREDIT_TERMS': $('CREDIT_TERMS').getAttribute("value") || '',
				'GAGE_LAND': $('GAGE_LAND').getAttribute("value") || '',
				'MESSAGE': $('MESSAGE').getAttribute("value") || '',
				'OVERSEAS_AUTH': $F('OVERSEAS_AUTH') || '',
				'MEMO': $F('MEMO') || '',
				'CT_SOURCE': $F('CT_SOURCE') || '',
				'CT_NOTE': $F('CT_NOTE') || '',
				'BUY_YM':  $F('BUY_YM') == '' ? '': $F('BUY_YM')+'01',
				'COMM_PRICE': $F('COMM_PRICE') || '',
				'PARK_NO': $F('PARK_NO') || '',
				'SALE_ID': $F('SALE_ID') || '',
				'SALE_NAME': $F('SALE_NAME') || '',
				
				'SPC_MEMO': $F('SPC_MEMO') || '',
				
				'PARAMS_6P': actions.getRadioBtn('PARAMS_6P'),
				'EST_TRA_DOC': actions.getRadioBtn('EST_TRA_DOC'),
				
				'BALC_CHK': actions.getCheckBox('BALC_CHK'),
				
				'GAGE_REJ': actions.getCheckBox('GAGE_REJ'),
				'SPACE_REJ': actions.getCheckBox('SPACE_REJ'),
				'BORROW_POS01': actions.getCheckBox('BORROW_POS01'),
				'COUPLE_POS01': actions.getCheckBox('COUPLE_POS01'),
				'CHILD_POS01': actions.getCheckBox('CHILD_POS01'),
				'RELATIVE_POS01': actions.getCheckBox('RELATIVE_POS01'),
				
				'LOAN_STATUS_ERR': actions.getCheckBox('LOAN_STATUS_ERR'),
				'PAY_STA_6P': actions.getCheckBox('PAY_STA_6P'),
				'PAY_STA_5Y': actions.getCheckBox('PAY_STA_5Y'),
				'CLAIM_COSTS': actions.getCheckBox('CLAIM_COSTS'),
				'SPC_CTR_LOAN': actions.getCheckBox('SPC_CTR_LOAN'),
				
				'PENDING_CASE': actions.getCheckBox('PENDING_CASE'),
				'CREDIT_REJ': actions.getCheckBox('CREDIT_REJ'),
				'GAGE_DIF_3M': actions.getCheckBox('GAGE_DIF_3M'),
				'FIRST_BUY': actions.getCheckBox('FIRST_BUY'),
				'PAYOFF_3M': actions.getCheckBox('PAYOFF_3M'),
				'BUY_INSURANCE': actions.getCheckBox('BUY_INSURANCE'),
				'ILL_APP': actions.getCheckBox('ILL_APP'),
				'SPC_LOAN': actions.getCheckBox('SPC_LOAN'),
				<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
				<%--'DEBT_CODE': actions.getCheckBox('DEBT_CODE'),--%>
				'LIMIT_CODE': actions.getCheckBox('LIMIT_CODE'),
				'NORMAL_CODE': actions.getCheckBox('NORMAL_CODE'),
				'ASS_SET_MORT': actions.getCheckBox('ASS_SET_MORT'),
				'ROC_CLAIMANT': actions.getCheckBox('ROC_CLAIMANT'),
				'MAX_LIM_MORT': actions.getCheckBox('MAX_LIM_MORT'),
				'RUR_EXP': actions.getCheckBox('RUR_EXP'),
				'READJUST': actions.getCheckBox('READJUST'),
				'LAND_OTHER': actions.getCheckBox('LAND_OTHER'),
				'MUTI_BUD_NM': actions.getCheckBox('MUTI_BUD_NM'),
				'HOLD_PART': actions.getCheckBox('HOLD_PART'),
				'SPACE_L5': actions.getCheckBox('SPACE_L5'),
				'IS_FARMHOUSE': actions.getCheckBox('IS_FARMHOUSE'),
				'IS_BRICK': actions.getCheckBox('IS_BRICK'),
				'OWN_NO_CON': actions.getCheckBox('OWN_NO_CON'),
				'REG_DATE_L1Y': actions.getCheckBox('REG_DATE_L1Y'),
				
				'ADD_NO_CL': actions.getCheckBox('ADD_NO_CL'),
				'ADD_NOT_CL': actions.getCheckBox('ADD_NOT_CL'),
				'TWO_LOAN': actions.getCheckBox('TWO_LOAN'),
				'NO_LIMIT_CL': actions.getCheckBox('NO_LIMIT_CL'),
				'NO_RANGE_CL': actions.getCheckBox('NO_RANGE_CL'),
				'CNT_REJ_CL': actions.getCheckBox('CNT_REJ_CL'),
				'BLD_REJ': actions.getCheckBox('BLD_REJ'),
				'BLD_REJ_OTHER': actions.getCheckBox('BLD_REJ_OTHER'),
				
				//'APPLY_INPUT': actions.getCheckBox('APPLY_INPUT'),
				//'BORROW_INPUT': actions.getCheckBox('BORROW_INPUT'),
				//'GUAR_INPUT': actions.getCheckBox('GUAR_INPUT'),
				//'DATA_INPUT': actions.getCheckBox('DATA_INPUT'),
				'RELATION': actions.getCheckBox('RELATION'),
				'BOR_BUS_OPR': actions.getCheckBox('BOR_BUS_OPR'),
				'TRAN_ITEM': actions.getCheckBox('TRAN_ITEM'), 
	            'REFI_ITEM': actions.getCheckBox('REFI_ITEM'),
	            'AUCT_ITEM': actions.getCheckBox('AUCT_ITEM')
			}
	   	},
	   	
	    get610Map: function() {

	    	<%-- 包裝 CAL1_1 --%>		    	
	    	var CAL1_1Arr = actions.getCal1_1();
	    	<%-- 包裝 CAL2_1 --%>		    	
	    	var CAL2_1Arr = actions.getCal2_1();
	    	<%-- 包裝 CAL2_5 --%>
	    	var CAL2_5Arr = actions.getCal2_5();   	
	    	<%-- calObj merge --%>
	    	var tempArr = {};

	    	for (var i = 0; i < CAL1_1Arr.length; i++) {
	    	    var id = CAL1_1Arr[i]['ID'];
	    	    if (!tempArr[id]) {
	    	    	tempArr[id] = {};
	    	    }
	    	    for (var key in CAL1_1Arr[i]) {
	    	    	tempArr[id][key] = CAL1_1Arr[i][key];
	    	    }
	    	}

	    	for (var i = 0; i < CAL2_1Arr.length; i++) {
	    	    var id = CAL2_1Arr[i]['ID'];
	    	    if (!tempArr[id]) {
	    	    	tempArr[id] = {};
	    	    }
	    	    for (var key in CAL2_1Arr[i]) {
	    	    	tempArr[id][key] = CAL2_1Arr[i][key];
	    	    }
	    	}

	    	for (var i = 0; i < CAL2_5Arr.length; i++) {
	    	    var id = CAL2_5Arr[i]['ID'];
	    	    if (!tempArr[id]) {
	    	    	tempArr[id] = {};
	    	    }
	    	    for (var key in CAL2_5Arr[i]) {
	    	    	tempArr[id][key] = CAL2_5Arr[i][key];
	    	    }
	    	}
	    	
	    	var result = [];
			for (var key in tempArr) {
			    if (tempArr.hasOwnProperty(key)) {
			    	result.push(tempArr[key]);
			    }
			}

	    	return result;
		},
		exceptionItems: function(checkList) {
			index = 1;
			var checkUserId ='';
			var checkExceptionType = -1;
			var itemArr = [];
			
			for (var i=0; i<checkList.length; i++) {
				var checkItem = checkList[i];
				var userType = checkItem.getAttribute("userType")||'';  <%-- 借款人/保證人 種類中文顯示名稱 --%>	
				var userid = checkItem.getAttribute("userid") || '';  <%-- 借款人/保證人 ID --%>	
				var userName = checkItem.getAttribute("userName")||''; <%-- 借款人/保證人 姓名 --%>
				var text = checkItem.getAttribute("text")||''; <%--  異常項目 --%>
				var userTypeCode = checkItem.getAttribute("userTypeCode") || ''; <%-- 借款人/保證人 種類  --%>
				
				 <%-- 借款人才有 高風險等級及近三個月有新契約投保  --%>
				if (userTypeCode && (userTypeCode !== "0" && (checkItem.value === "LEVEL_CH" || checkItem.value === "NEW_CON_3M")) ) {
					continue;
				}
				
				if (checkItem.checked) {
					for (var key in exception_mapping) {
						if (key === checkItem.value || key === checkItem.id) {
							var exception_item_type = "_exception_item_" + exception_mapping[key]; <%-- 異常項目類別 --%>	
							var itemDivId = (userid || "") + exception_item_type; <%-- 異常項目父容器的ID --%>	
							var itemDiv = document.getElementById(itemDivId); <%-- 異常項目父容器 --%>	
							
							<%-- 組裝借款人/保證人 種類及姓名 --%>
							if (itemDiv && !itemDiv.hasChildNodes() && (checkUserId != userid || checkExceptionType != exception_mapping[key])){
								<%-- 當借款人/保證人id不同 或者 異常項目分類不同時, 編號需要從1開始顯示 --%>
								if (userType && userName) {
									<%-- 判斷有username usertype，避免產生換行 --%>
									itemDiv.innerHTML +="<b>"+ userType + "  "  + userName + "</b> <br>"
									itemDiv.style.fontFamily = "EUDC";
								}
								index = 1;
							} 
							
							<%-- 組裝異常項目子項 --%>
							index = $$("#" + itemDivId + " span").length + 1; <%-- 取得異常項目接續的index [20241106]修正document.querySelectorAll不支援數字開頭id--%>
							itemDiv.innerHTML += "<span>" + index + ". "  + " " + text + "</span><br>";		
							
							
							index++;
							checkUserId = userid;
							checkExceptionType = exception_mapping[key];
							
							break;
						}
					}
					
				}
			}

			<%-- 從 dom 取得每個異常分類, 判斷是否有異常項目, 若有異常項目顯示:異常; 否則顯示:正常 --%>	
			var errMsg1 = document.querySelectorAll("#errMsg1 span");
			var errMsg2 = document.querySelectorAll("#errMsg2 span");
			var errMsg3 = document.querySelectorAll("#errMsg3 span");
			var errMsg4 = document.querySelectorAll("#errMsg4 span");
            <%--[文初檢核表上線後優化_V3]四大類檢核結果，目前會顯示「正常」、「異常」，調整為「正常」不顯示，異常改以「◎」並以紅字顯示，連同PDF也要做調整--%>
			<%-- 內外規範 --%>	
			var INTERNAL_RULES = $('INTERNAL_RULES')
			while (INTERNAL_RULES.firstChild) {
				INTERNAL_RULES.removeChild(INTERNAL_RULES.firstChild);
    		}
			if (errMsg1 && errMsg1.length === 0) {
				INTERNAL_RULES.setAttribute("value", "0");
				//INTERNAL_RULES.innerHTML = '<span>正常</span>';
			} else {
				INTERNAL_RULES.setAttribute("value", "1");
				INTERNAL_RULES.innerHTML = '<span class="textRed">◎</span>';
			}

			<%-- 內外規範 --%>	
			var CREDIT_TERMS = $('CREDIT_TERMS')
			while (CREDIT_TERMS.firstChild) {
				CREDIT_TERMS.removeChild(CREDIT_TERMS.firstChild);
    		}
			if (errMsg2 && errMsg2.length === 0) {
				CREDIT_TERMS.setAttribute("value", "0");
				//CREDIT_TERMS.innerHTML = '<span>正常</span>';
			} else {
				CREDIT_TERMS.setAttribute("value", "1");
				CREDIT_TERMS.innerHTML = '<span class="textRed">◎</span>';
			} 

			<%-- 擔保品暨謄本 --%>	
			var GAGE_LAND = $('GAGE_LAND')
			while (GAGE_LAND.firstChild) {
				GAGE_LAND.removeChild(GAGE_LAND.firstChild);
    		}
			if(errMsg3 && errMsg3.length === 0){
				GAGE_LAND.setAttribute("value", "0");
				//GAGE_LAND.innerHTML = '<span>正常</span>';
			} else {
				GAGE_LAND.setAttribute("value", "1");
				GAGE_LAND.innerHTML = '<span class="textRed">◎</span>';
			}

			<%-- 提醒訊息 --%>	
			var MESSAGE = $('MESSAGE')
			while (MESSAGE.firstChild) {
				MESSAGE.removeChild(MESSAGE.firstChild);
    		}
			if(errMsg4 && errMsg4.length === 0){
				MESSAGE.setAttribute("value", "0");
				//MESSAGE.innerHTML = '<span>正常</span>';
			} else {
				MESSAGE.setAttribute("value", "1");
				MESSAGE.innerHTML = '<span class="textRed">◎</span>';
			}
		},
		calculate1: function() {
			$("CAL1_1").innerHTML = "";
			$("errMsg1").innerHTML = "";
			ajaxRequest.post('calculate1', {'APPLY_ID': APPLY_ID},function(resp){	
                var cal1List = resp.cal1List;
				<%-- 動態設定 checkbox --%>
                actions.setCal(cal1List, "CAL1_1", mapping1, "cal1List", "checkList1");
				<%-- 動態設定異常項目 --%>
				actions.createExceptionItemDiv();
                actions.exceptionItems(document.getElementsByName("checkList1"));

				var calTime = resp.calTime; <%-- 試算時間 --%>
				$('calTime').innerHTML = calTime;			
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate1_2: function() {
			$("CAL1_1").innerHTML = "";
			$("errMsg1").innerHTML = "";
			ajaxRequest.post('calculate1_2', {'APPLY_ID': APPLY_ID},function(resp){	
                var cal1_2List = resp.cal1List;
                actions.setCal(cal1_2List, "CAL1_1", mapping1_2, "cal1_2List", "checkList1_2");
                <%-- 動態設定異常項目 --%>
				actions.createExceptionItemDiv();
                actions.exceptionItems(document.getElementsByName("checkList1_2"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate2: function() {
			$("CAL2_5").innerHTML = "";
			$("errMsg2").innerHTML = "";
			ajaxRequest.post('calculate2', {'APPLY_ID': APPLY_ID},function(resp){
				var cal2List = resp.cal2List;
				for(var i=0; i<cal2List.length; i++) {
			        var obj = cal2List[i].LOAN_BOR_MAP;
			        obj['ID'] = cal2List[i].ID;
			        obj['TYPE'] = cal2List[i].TYPE;
			        obj['NAME'] = cal2List[i].NAME;
			        obj['GUAR_KIND'] = cal2List[i].GUAR_KIND;
			        obj['USER_TYPE_NAME'] = cal2List[i].USER_TYPE_NAME;
			        <%-- 借款債務 --%>
			        actions.setCal([obj], "CAL2_5", mapping3, "cal2_51List", "checkList2");	
		        }
					actions.createExceptionItemDiv();
					actions.exceptionItems(document.getElementsByName("checkList2"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate2_2: function() {
			$("CAL2_5").innerHTML = "";
			$("errMsg2").innerHTML = "";
			ajaxRequest.post('calculate2_2', {'APPLY_ID': APPLY_ID},function(resp){
				var cal2List = resp.cal2List;
				for(var i=0; i<cal2List.length; i++) {
			        var obj2 = cal2List[i].LOAN_GUA_MAP;
			        obj2['ID'] = cal2List[i].ID;
			        obj2['TYPE'] = cal2List[i].TYPE;
			        obj2['NAME'] = cal2List[i].NAME;
			        obj2['GUAR_KIND'] = cal2List[i].GUAR_KIND;
			        obj2['USER_TYPE_NAME'] = cal2List[i].USER_TYPE_NAME;
			        <%-- 保證債務 --%>
			        actions.setCal([obj2], "CAL2_5", mapping4, "cal2_52List", "checkList2_2");        
		        }
					actions.createExceptionItemDiv();
					actions.exceptionItems(document.getElementsByName("checkList2_2"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate2_3: function() {
			ajaxRequest.post('calculate2_3', {'APPLY_ID': APPLY_ID},function(resp){	
				 <%-- 案件受理情形 --%>
				var cal2_3Map = resp.cal2_3Map;		
				actions.setCheckBoxList(checkboxList2_3, cal2_3Map);
				actions.createExceptionItemDiv();
				actions.exceptionItems(document.getElementsByName("checkList2_3"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate2_4: function() {
			ajaxRequest.post('calculate2_4', {'APPLY_ID': APPLY_ID},function(resp){	
				 <%-- 本擔借款情形 --%>
				var cal2_4Map = resp.cal2_4Map;		
                for (var key in cal2_4Map.loanMap) {
                	cal2_4Map[key] = cal2_4Map.loanMap[key];
                }
                delete cal2_4Map.loanMap;
				actions.setCheckBoxList(checkboxList2_4, cal2_4Map);
				actions.exceptionItems(document.getElementsByName("checkList2_4"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate3: function() {
			$("errMsg3").innerHTML = "";
			$("A040USERS").innerHTML = "";
			ajaxRequest.post('calculate3', {'APPLY_ID': APPLY_ID},function(resp){
				var cal3Map = resp.cal3Map;
				var a040Users = cal3Map['a040Users'];
				if(a040Users && a040Users.length > 0){
					$('A040USERS').innerHTML = ''
					var temp = ''
					for (var i = 0; i < a040Users.length; i++) {
						temp = temp + a040Users[i] + ';'
					}
					temp = temp.lastIndexOf(';') > -1 ? temp.substring(0, temp.lastIndexOf(';')) : temp;
					$('A040USERS').innerHTML = temp;
				}

				actions.setCheckBoxList(checkboxList3, cal3Map);
 				grid.load(cal3Map.bldList || []);
 				actions.createExceptionItemDiv();
 				actions.exceptionItems(document.getElementsByName("checkList3"));
				},function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculate4: function() {
			$("errMsg4").innerHTML = "";
			ajaxRequest.post('calculate4', {'APPLY_ID': APPLY_ID},
				function(resp){	
					var cal4Map = resp.cal4Map;
					actions.setCheckBoxList(checkboxList4, cal4Map);
					actions.createExceptionItemDiv();
					actions.exceptionItems(document.getElementsByName("checkList4"));
				},
				function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculateSupply: function() {
			ajaxRequest.post('calculateSupply', {'APPLY_ID': APPLY_ID},
				function(resp){	
					<%-- 核貸前補全紀錄顯示 --%>
					var List_A106 = resp.List_A106;
					if (List_A106 && List_A106.length > 0) {
						$("PRE_LOAN").removeAttribute("hidden");
						<%-- 補全狀態 --%>
						var SUPPLY_CODE = resp.SUPPLY_CODE;
						if(SUPPLY_CODE) {
							$('SUPPLY_CODE').innerHTML = SUPPLY_CODE;	
						}
						<%-- 補全項目 --%>
						$('SUPPLY_ITEM').innerHTML = "";
						$('SUPPLY_ITEM').innerHTML += '<div class="textBold">' + Date.toROC(List_A106[0].INPUT_DATE) + '　' + List_A106[0].INPUT_NAME + '</div>';
						for(var i=0; i< List_A106.length; i++){
							
							if (List_A106[i].FINISH_DATE) {
								$('SUPPLY_ITEM').innerHTML += '<span style="padding-left: 8px">' + List_A106[i].SUPPLY_ID +'. '+  List_A106[i].OTHER_ITEM +'(' + Date.toROC(List_A106[i].FINISH_DATE) +')</span><br>';
							} else {
								$('SUPPLY_ITEM').innerHTML += '<span style="padding-left: 8px">' + List_A106[i].SUPPLY_ID +'. '+  List_A106[i].OTHER_ITEM +'</span><br>';
							}
							
							if(List_A106.length > 1 && i < List_A106.length -1 && List_A106[i].INPUT_DATE != List_A106[i+1].INPUT_DATE) {
								$('SUPPLY_ITEM').innerHTML +=  '<div class="textBold">' + Date.toROC(List_A106[i+1].INPUT_DATE) + '　' + List_A106[i+1].INPUT_NAME + '</div>';									
							}
						}
						
					}
				},
				function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculateBuss: function(data) {
			ajaxRequest.post('calculateBuss', {'APPLY_ID': APPLY_ID},
				function(resp){	
				
	                var table = document.getElementById("table_EDQ");
	                var rowEDQ = table.querySelectorAll(".rowEDQ");
	                if(rowEDQ.length > 0 ){
	                        for (var i = 0; i < rowEDQ.length; i++) {
	                            rowEDQ[i].parentNode.removeChild(rowEDQ[i]);
	                        }
	                }
	                
					for(var i=0; i<data.length; i++) {
						<%-- 客戶種類/姓名/xxx_ID --%>
						var GUAR_KIND_NM = data[i].GUAR_KIND_NM
						var type = data[i].USER_TYPE_NAME + '-'; 
						
						var applyId = data[i].APPLY_ID;
						var userType = data[i].TYPE;
						var userId = data[i].ID;
						var userName = data[i].NAME;
						var userGK = data[i].GUAR_KIND;
						
						<%-- 外部資料查詢 開始--%>
						var table = document.getElementById("table_EDQ");
						var row = table.insertRow(-1);
						row.className = "rowEDQ";
						var cell1 = row.insertCell(0);
						var cell2 = row.insertCell(1);
						var cell3 = row.insertCell(2);
						var cell4 = row.insertCell(3);
						var cell5 = row.insertCell(4);
						var cell6 = row.insertCell(5);
						cell1.classList.add("tbYellow");
						cell1.style.width = "100px";
						cell1.style.tableLayout = "fixed"
						cell1.innerHTML =  
							'<td>' +
								'<span>'+ type +' </span>' +
								'<span style="font-family:\'EUDC\'">'+ data[i].NAME +'</span><br>' +<%--[20240723]難字調整 --%>
								'<span>'+ userId +'</span>' +
							'</td>';
						
						cell2.classList.add("tbYellow");
						cell2.style.width = "150px";
						cell2.style.tableLayout = "fixed"
						cell2.colSpan = "2";
						
						var bussData = resp.bussData;
						var td = document.createElement("td");

						if(bussData && bussData[userId]){
							<%-- 經營事業 --%>
							var BUSS_NAME = bussData[userId].BUSS_NAME;		
							if (BUSS_NAME) {
								var newBuss = BUSS_NAME.replace(/\./g, "\n");
								var bussNameText = document.createElement("span");
								bussNameText.setAttribute("name", "BUSS_NAME");
								bussNameText.setAttribute("userId", userId);	
								bussNameText.setAttribute("style","white-space: pre-line");
								bussNameText.textContent = newBuss
								td.appendChild(bussNameText);
							}
	
							<%-- 目前服務單位 --%>
							var SERVICE =  bussData[userId].SERVICE;
							if (SERVICE) {
								var newSer = SERVICE.replace(/\./g, "\n");
								var serviceText = document.createElement("span");
								serviceText.setAttribute("name", "SERVICE");
								serviceText.setAttribute("userId", userId);
								serviceText.setAttribute("style","white-space: pre-line")
								serviceText.textContent = newSer					
								td.appendChild(serviceText);
							}
						}
						cell2.appendChild(td);
						
						cell3.classList.add("tbYellow2");
						cell3.innerHTML = 
							'<td>' +
								'<input type="radio" id="JUDICIAL_'+ i +'_NO" status="" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="JUDICIAL_'+ i +'" colname="JUDICIAL" checked hidden>' +
								'<label><input type="radio" id="JUDICIAL_'+ i +'_OK" status="0" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="JUDICIAL_'+ i +'" colname="JUDICIAL">正常</label>' +
								'<label><input type="radio" id="JUDICIAL_'+ i +'_NG" status="1" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="JUDICIAL_'+ i +'" colname="JUDICIAL">異常</label>，說明' +
								'<input type="text" class="textBox2" id="JUDICIAL_DESC_'+ i +'" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="JUDICIAL_DESC" colname="JUDICIAL" value="" maxlength="40">' +
							'</td>';
							
						<%-- 註冊 監輔宣告 JUDICIAL--%>
						$('JUDICIAL_'+ i +'_NO').observe('change', buttons.doChangeEDQColor );
						$('JUDICIAL_'+ i +'_OK').observe('change', buttons.doChangeEDQColor );
						$('JUDICIAL_'+ i +'_NG').observe('change', buttons.doChangeEDQColor );		
							
						cell4.classList.add("tbYellow2");
						cell4.innerHTML = 
							'<td>' +
								'<label><input type="radio" id="BUS_REG_'+ i +'_NO" status="2" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="BUS_REG_'+ i +'" colname="BUS_REG" checked >未查詢</label>' +
								'<label><input type="radio" id="BUS_REG_'+ i +'_OK" status="0" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="BUS_REG_'+ i +'" colname="BUS_REG">正常</label>' +
								'<label><input type="radio" id="BUS_REG_'+ i +'_NG" status="1" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="BUS_REG_'+ i +'" colname="BUS_REG">異常</label>，說明' +
								'<input type="text" class="textBox2" id="BUS_REG_DESC_'+ i +'" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="BUS_REG_DESC" colname="BUS_REG" value="" maxlength="40">' +
							'</td>';
							
						<%-- 註冊 營登查詢 BUS_REG--%>
						$('BUS_REG_'+ i +'_NO').observe('change', buttons.doChangeEDQColor );
						$('BUS_REG_'+ i +'_OK').observe('change', buttons.doChangeEDQColor );
						$('BUS_REG_'+ i +'_NG').observe('change', buttons.doChangeEDQColor );	
							
						cell5.classList.add("tbYellow2");
						cell5.innerHTML = 
							'<td>' +
								'<span>個人</span>' +
								'<label><input type="radio" id="CLE_HOU_'+ i +'_NO" status="2" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_HOU_'+ i +'" colname="CLE_HOU" checked >未查詢</label>' +
								'<label><input type="radio" id="CLE_HOU_'+ i +'_OK" status="0" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_HOU_'+ i +'" colname="CLE_HOU">正常</label>' +
								'<label><input type="radio" id="CLE_HOU_'+ i +'_NG" status="1" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_HOU_'+ i +'" colname="CLE_HOU">異常</label>，說明' +
								'<input type="text" class="textBox2" id="CLE_HOU_DESC_'+ i +'" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_HOU_DESC" colname="CLE_HOU" value="" maxlength="40"> <br>' +
								
								'<span>公司 </span>' +
								'<label><input type="radio" id="CLE_CORP_'+ i +'_NO" status="2" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_CORP_'+ i +'" colname="CLE_CORP" checked >未查詢</label>' +
								'<label><input type="radio" id="CLE_CORP_'+ i +'_OK" status="0" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_CORP_'+ i +'" colname="CLE_CORP">正常</label>' +
								'<label><input type="radio" id="CLE_CORP_'+ i +'_NG" status="1" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_CORP_'+ i +'" colname="CLE_CORP">異常</label>，說明' +
								'<input type="text" class="textBox2" id="CLE_CORP_DESC_'+ i +'" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="CLE_CORP_DESC" colname="CLE_CORP" value="" maxlength="40">' +
							'</td>';
						
						<%-- 註冊 個人票交所查詢 CLE_HOU--%>
						$('CLE_HOU_'+ i +'_NO').observe('change', buttons.doChangeEDQColor );
						$('CLE_HOU_'+ i +'_OK').observe('change', buttons.doChangeEDQColor );
						$('CLE_HOU_'+ i +'_NG').observe('change', buttons.doChangeEDQColor );	
						
						<%-- 註冊 公司票交所查詢 CLE_CORP--%>
						$('CLE_CORP_'+ i +'_NO').observe('change', buttons.doChangeEDQColor );
						$('CLE_CORP_'+ i +'_OK').observe('change', buttons.doChangeEDQColor );
						$('CLE_CORP_'+ i +'_NG').observe('change', buttons.doChangeEDQColor );	
						
						cell6.classList.add("tbYellow2");
						cell6.innerHTML = 
							'<td>' +
							'<label><input type="radio" id="PRO_QUA_'+ i +'_NO" status="2" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="PRO_QUA_'+ i +'" colname="PRO_QUA" checked>未查詢</label>' +
							'<label><input type="radio" id="PRO_QUA_'+ i +'_OK" status="0" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="PRO_QUA_'+ i +'" colname="PRO_QUA">正常</label>' +
							'<label><input type="radio" id="PRO_QUA_'+ i +'_NG" status="1" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="PRO_QUA_'+ i +'" colname="PRO_QUA">異常</label>，說明' +
							'<input type="text" class="textBox2" id="PRO_QUA_DESC_'+ i +'" username="'+ userName +'" userid="'+ userId +'" userGK="'+ userGK +'" applyid="'+ applyId +'" usertype="'+ userType +'" name="PRO_QUA_DESC" colname="PRO_QUA" value="" maxlength="40">' +
							'</td>';
							
						<%-- 註冊 專門職業資格 PRO_QUA--%>
						$('PRO_QUA_'+ i +'_NO').observe('change', buttons.doChangeEDQColor );
						$('PRO_QUA_'+ i +'_OK').observe('change', buttons.doChangeEDQColor );
						$('PRO_QUA_'+ i +'_NG').observe('change', buttons.doChangeEDQColor );
							
						var radioBtnList = [];
						radioBtnList.push('JUDICIAL_'+ i);
						radioBtnList.push('BUS_REG_'+ i);
						radioBtnList.push('CLE_HOU_'+ i);
						radioBtnList.push('CLE_CORP_'+ i);
						radioBtnList.push('PRO_QUA_'+ i);
						
						var TextList = [];
						TextList.push('JUDICIAL_DESC_'+ i);
						TextList.push('BUS_REG_DESC_'+ i);
						TextList.push('CLE_HOU_DESC_'+ i);
						TextList.push('CLE_CORP_DESC_'+ i);
						TextList.push('PRO_QUA_DESC_'+ i);
						
						actions.setRadioBtnList(radioBtnList, data[i], true);
						actions.setTextList(TextList, data[i], true);
						actions.doCheckUpdate();	

					}
				},
				function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculateLastSub: function() {
			ajaxRequest.post('calculateLastSub', {'APPLY_ID': APPLY_ID},
				function(resp){	
					var LAST_SUBMIT = resp.LAST_SUBMIT
					if (LAST_SUBMIT) {
						var subHTML = "";
						for (var i = 0; i < LAST_SUBMIT.length; i++) {
							subHTML += '<div>' + LAST_SUBMIT[i]['LAST_SUBMIT'] + '</div>';
						}
						$("LAST_SUBMIT").innerHTML = subHTML;
					}
				},
				function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		calculateLoanLog: function() {
			ajaxRequest.post('calculateLoanLog', {'APPLY_ID': APPLY_ID},
				function(resp){	
					var LOAN_LOG = resp.LOAN_LOG
					if (LOAN_LOG) {
						var logHTML = "";
						for (var i = 0; i < LOAN_LOG.length; i++) {
							logHTML += '<div>' + LOAN_LOG[i]['LOAN_LOG'] + '</div>';
						}
						$("LOAN_LOG").innerHTML = logHTML;
					}
				},
				function(resp){ <%-- 試算失敗 --%>
					isCalculate = false 
				}
			)
		},
		getEmp: function(CH_STATUS) {
			ajaxRequest.post('getEmp', {'APPLY_ID': APPLY_ID, 'CH_STATUS': CH_STATUS},
				function(resp){	
					var EMP = resp.EMP
					$("EMP").innerHTML = "";
					if (EMP) {
						for (var i = 0; i < EMP.length; i++) {
							$("EMP").innerHTML += '<div>' + EMP[i]['EMP'] + '</div>';
						} 
					}	
				}
			)
		},
		calculateEDQ: function() {
            ajaxRequest.post('calculateEDQ', {'APPLY_ID': APPLY_ID},
                    function(resp){        
                            var EDQLIST = resp.EDQLIST
                            actions.calculateBuss(EDQLIST);
           			 }
            	)
			},
		createExceptionItemDiv: function() {
			// 異常項目: 於每個異常項目中建立對應的借款人/保證人區塊
			for (var j = 1; j <= 4; j++) {
				var errMsg = document.getElementById("errMsg" + j);
				// 借款人/保證人
				for (var i = 0; i < tempIdList.length; i++) {
					var id = tempIdList[i] + "_exception_item_" + j;
					
					var idDiv = document.getElementById(id);
					
					if (!idDiv) {
						idDiv = document.createElement("div");
						idDiv.setAttribute("id", id);
						errMsg.appendChild(idDiv);
					}
					
				}
			}

			
		}
	};
	
	return{
		initApp: function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
			
			<%-- 頁面渲染 --%>
			PageUI.createPageWithAllBodySubElement("DSA12001", "基本資料檢核", "基本資料檢核");
			
			<%-- 監聽事件 --%>
			actions.doToggleBtn();
			
			<%-- 基本資料 --%>
			buttons.doQuery();
			
			<%-- 註冊事件 --%>
			$('btn_calculate').observe('click',buttons.doCalculate);<%--試算--%>
			$('btn_insert').observe('click',buttons.doInsert);<%--新增--%>
			$('btn_update').observe('click',buttons.doUpdate);<%--修改--%>
			$('btn_print').observe('click',buttons.doPrint);<%--列印--%>
			$('btn_getJCIC').observe('click',buttons.doGetJCIC);<%--聯徵紀錄--%>
			$('btn_videoLink').observe('click',buttons.doVideoLink);<%--受理影像連結--%>

			$('link_jud').observe('click',buttons.doLinkJud);<%--監輔宣告--%>
			$('link_bus1').observe('click',buttons.doLinkBus1);<%--營登查詢 財政部--%>
			$('link_bus2').observe('click',buttons.doLinkBus2);<%--營登查詢 經濟部--%>
			$('link_cle').observe('click',buttons.doLinkCle);<%--票交所查詢--%>
			
			$('OVERSEAS_AUTH').observe('change',buttons.doChangeOverseaColor);<%--海外授權件--%>
			$('EST_TRA_DOC_NG').observe('change',buttons.doChangeESTColor); <%--不動產移轉證明 radio button --%>
			$('EST_TRA_DOC_OK').observe('change',buttons.doChangeESTColor);
			$('PARAMS_6P_NG').observe('change',buttons.doChangePARAMS_6PColor); <%--近六期繳息紀錄 radio button --%>
			$('PARAMS_6P_NO').observe('change',buttons.doChangePARAMS_6PColor);
			$('PARAMS_6P_OK').observe('change',buttons.doChangePARAMS_6PColor);

			
			
			<%-- TABLEUI--%>
			grid = new TableUI({
				table: $("grid"), pageSize : 10, allSortable: false, overDiv:false,
				column:[
					{header:'登記次序', key:"RANK"},
					{header:"權利人統一編號", key:"C09"},
					{header:"起始日", key:"T19_2",
						render:function(obj, val){
							return val ? val : obj.C05;
		            }},
					{header:"終止日", key:"T19_3",
						render:function(obj, val){
							return val ? val : obj.G30_2;
					}},
					{header:"權利類別", key:"C27_C"},
					{header:"權利價值", key:"T17_2",sortRule:"number"},	
					{header:"權利範圍", key:"C18_1_C"}
					]
			});
			
 			buttonAuth();
			displayMessage();
			initValidation();
		}
	}

}

</script>
</head>
<body>

<form id="form1" name="form1" method="post" action="${dispatcher}/DSA1_2001/prompt">

	<div id="tabs_1">
		<div id="tabs_1_1">
			<table id="table_2" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
				<tbody>
					<tr>
						<td id="table_2_R0C0" rowspan="1" colspan="1" style="text-align:center;">
							<button type="button" id="btn_calculate" class="button">試算</button>
							<button type="button" id="btn_insert" class="button">新增</button>
							<button type="button" id="btn_update" class="button">修改</button>
							<button type="button" id="btn_print" class="button">列印</button>
							<button type="button" id="btn_getJCIC" class="button">聯徵紀錄</button>
							<button type="button" id="btn_videoLink" class="button">受理影像連結</button>
						</td>
					</tr>
				</tbody>
			</table>
			<table id="table_5" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
				<tbody>
					<tr>
						<td class="tbYellow3" id="table_5_R0C0" rowspan="1" colspan="1" style="text-align:left;">
							<span id="input-label_18" class="textRed"
								style="font-weight:bold; ">【提醒】試算完成，需點選新增或修改，資料才會寫入資料庫</span>
							<span>　最近一次點選「試算鈕」的時間：</span>
							<span id="calTime"></span>
						</td>
 					</tr>
				</tbody>
			</table>
			
			<table id="table_4" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
				<tbody>
					<tr>
						<td class="tbYellow" width="12%"><span>受理編號</span></td>
						<td class="tbYellow2" width="12%"><span id="APPLY_ID"></span></td>

						<td class="tbYellow" width="12%"><span>借款人姓名</span></td>
						<td class="tbYellow2" width="12%"><span id="BORROW_NAME" class="borrowNames" style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%></td>

						<td class="tbYellow" width="12%"><span>貸款類型</span></td>
						<td class="tbYellow2" width="12%"><span id="LOAN_TYPE_DOC"></span><input type="hidden" id="LOAN_TYPE" value=""></td>

						<td class="tbYellow" width="12%"><span>是否送出</span></td>
						<td class="tbYellow2" width="12%"><span id="CH_STATUS_NM"></span>
						<input type="hidden" id="CH_STATUS" value="">
						</td>
					</tr>

					<tr>
						<td class="tbYellow"><span>受理進度</span></td>
						<td class="tbYellow2"><span id="APPLY_PROCESS_DOC"></span><input type="hidden" id="APPLY_PROCESS" value=""></td>

						<td class="tbYellow"><span>送件日期</span></td>
						<td class="tbYellow2"><span id="SEND_DATE"></span></td>

						<td class="tbYellow"><span>輸入人員</span></td>
						<td class="tbYellow2"><span id="INPUT_NAME" style="font-family:'EUDC'"></span></td>

						<td class="tbYellow"><span>輸入時間</span></td>
						<td class="tbYellow2"><span id="INPUT_TIME"></span></td>
					</tr>

				</tbody>
			</table>
			
			<table id="table_6" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
				<tbody>
					<tr>
						<td class="tbBlue" rowspan="2" colspan="1" style="text-align:center;"><span>檢核結果</span></td>
						<td class="tbBlue"  rowspan="1" colspan="1" style="text-align:center;"><span>內外規範</span></td>
						<td class="tbBlue"  rowspan="1" colspan="1" style="text-align:center;"><span>債信條件</span></td>
						<td class="tbBlue"  rowspan="1" colspan="1" style="text-align:center;"><span>擔保品暨謄本</span></td>
						<td class="tbBlue"  rowspan="1" colspan="1" style="text-align:center;"><span>提醒訊息</span></td>
						<td class="tbBlue"  rowspan="2" colspan="1" style="text-align:center;"><span>海外授權件</span></td>
						<td class="tbBlue2"  rowspan="2" colspan="1" style="text-align:left;">
							<select class="textBox2" id="OVERSEAS_AUTH" name="OVERSEAS_AUTH">
								<option value="">請選擇</option>
								<c:forEach items= "${OVERSEAS_AUTH}" var="row">
									<option value="${row.key}">
										${row.value}
									</option>	
								</c:forEach>	
							</select>	
						</td>
					</tr>
					
					<tr>
						<td  id="INTERNAL_RULES" class="tbBlue2" rowspan="1" colspan="1" style="text-align:center;"></td>
						<td  id="CREDIT_TERMS" class="tbBlue2" rowspan="1" colspan="1" style="text-align:center;"></td>
						<td  id="GAGE_LAND" class="tbBlue2" rowspan="1" colspan="1" style="text-align:center;"></td>
						<td  id="MESSAGE" class="tbBlue2" rowspan="1" colspan="1" style="text-align:center;"></td>
					</tr>
					
					<tr>
						<td class="tbBlue" rowspan="1" colspan="1" style="text-align:center;"><span>注意項目</span></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:top;" id="errMsg1"></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:top;" id="errMsg2"></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:top;" id="errMsg3"></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:top;" id="errMsg4"></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:left;"></td>
						<td class="tbBlue2" rowspan="1" colspan="1" style="text-align:left;"></td>
					</tr>
					
					<tr>
						<td class="tbBlue" rowspan="1" colspan="1" style="text-align:center;"><span id="">其他說明</span></td>
						<td class="tbBlue2" rowspan="1" colspan="9" style="text-align:left;">
						<textarea id="MEMO" class="textBox2" rows="3" style="width:600px;" maxlength="1000"></textarea></td>
						<%--文初檢核表之其他說明欄同A130.CRED_NOTE，欄位長度設定為2000--%>
					</tr>
					
				</tbody>
			</table>
			
			<table id="table_7" class="tbBox2" width="100%" cellspacing="1" cellpadding="2">
				<tbody>
					<tr>
						<td class="tbYellow0" id="table_7_R0C0" rowspan="1" colspan="8" style="text-align:center;">
							<span style="font-weight:bold; ">受理影像檢核</span>
							<span>※為文件初審結果，非案件最終結果</span>
						</td>
					</tr>
					<tr>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" width="250px">
							<span>檢核項目</span>
						</td>
						<td class="tbBlue2" colspan="3">
							<label><input type="checkbox" id="TRAN_ITEM" >買賣件</label>
							<label><input type="checkbox" id="REFI_ITEM" >轉貸件</label>
							<label><input type="checkbox" id="AUCT_ITEM" >法拍件</label>
						</td>
					</tr>
				</tbody>
			</table>
			
			<table id="PRE_LOAN" class="tbBox2" width="100%" cellspacing="1" cellpadding="2" hidden>
				<tbody>
					<tr>
						<td class="tbBlue" rowspan="1" colspan="8" style="text-align:left;"><span>核貸前補全紀錄</span></td>
					</tr>
					<tr >
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" width="250px"><span>補全狀態</span></td>
						<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:center;" width="150px"><span id="SUPPLY_CODE"></span></td>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:left;"><span>補全項目 (補全完成日期)</span></td>
						<td class="tbYellow2" rowspan="1" colspan="5" style="text-align:left;"><span id="SUPPLY_ITEM" style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%></td>
					</tr>
				</tbody>
			</table>
			
			<table  id="IMG_PO" class="tbBox2" width="100%" cellspacing="1" cellpadding="2" hidden>
				<tbody>
					<tr>
						<td class="tbBlue" rowspan="1" colspan="8" style="text-align:left;">
							<span>受理影像檢核 - 買賣件</span>
						</td>
					</tr>
					
					<tr>
						<td class="tbYellow" rowspan="3" colspan="1" style="text-align:center;" width="250px">買賣契約書資訊</td>
						<td class="tbYellow2"  style="text-align: left;">
							<span>買契來源/備註</span>
							<select class="textBox2" id="CT_SOURCE" name="CT_SOURCE">
								<option value="">請選擇</option>
								<c:forEach items= "${CT_SOURCE}" var="row">
									<option value="${row.key}">
										${row.value}
									</option>	
								</c:forEach>	
							</select>	
							<input type="text" class="textBox2" id="CT_NOTE" maxlength="30" size="" value="買契備註">
							<span>購買年月(民國如11108)</span>
							<input type="text" class="textBox2" id="BUY_YM" maxlength="5" value="">
							<span>金額</span>
							<input type="text" class="textBox2" id="COMM_PRICE" maxlength="7" size="8" value="">
							<span>萬元</span>
							<span>車位編號</span>
							<input type="text" class="textBox2" id="PARK_NO" maxlength="60" size="30" value="">
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" style="text-align: left;">
							<span>售屋者 ID</span>
							<input type="text" class="textBox2" id="SALE_ID" maxlength="10" size="12" value="" onkeyup="value=value.replace(/[^a-zA-Z0-9]/g,'')" >
							<span>售屋者姓名</span>
							<input type="text" class="textBox2" id="SALE_NAME" maxlength="10"" size="12" value="">
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" style="text-align: left;">
							<span>特殊記載</span>
							<input type="text" class="textBox2" id="SPC_MEMO" maxlength="200" size="200" value="特殊記載">
						</td>
					</tr>
					
				</tbody>
			</table>
				
			<table id="IMG_LF" class="tbBox2" width="100%" cellspacing="1" cellpadding="2" hidden>
				<tbody>
					<tr>
						<td class="tbBlue" rowspan="1" colspan="8" style="text-align:left;">
							<span id="input-label_53">受理影像檢核 - 轉貸件</span>
						</td>
					</tr>

					<tr>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" width="250px">
							<span>近六期繳息紀錄</span>
						</td>
					
						<td class="tbYellow2"  style="text-align: left;">
							<label><input type="radio" id="PARAMS_6P_OK" status="0" name="PARAMS_6P" value="0">繳息正常</label>
							<label><input type="radio" id="PARAMS_6P_NG" status="1" name="PARAMS_6P" value="1">繳息異常</label>
							<label><input type="radio" id="PARAMS_6P_NO" status="2" name="PARAMS_6P" value="2">未檢附或未完整拍攝</label>
						</td>
					</tr>

					<tr>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;">
							<span>前行庫借款人</span>
						</td>

						<td class="tbYellow2" rowspan="1" colspan="7" style="text-align:left;" width="250px"> 
							<span>
								<label><input type="checkbox" id="BORROW_POS01" name="input-input_checkbox_1" text="本次借款人">本次借款人</label>
								<label><input type="checkbox" id="COUPLE_POS01" name="input-input_checkbox_1" text="借款人配偶">借款人配偶</label>
								<label><input type="checkbox" id="CHILD_POS01" name="input-input_checkbox_1" text="借款人子女">借款人子女</label>
								<label><input type="checkbox" id="RELATIVE_POS01" name="input-input_checkbox_1" text="借款人其他親屬">借款人其他親屬</label>
							</span>
						</td>
					</tr>
				</tbody>
			</table>
				
			<table id="IMG_AP" class="tbBox2" width="100%" cellspacing="1" cellpadding="2" hidden>
				<tbody>
					<tr>
						<td class="tbBlue" rowspan="1" colspan="8" style="text-align:left;">
							<span>受理影像檢核 - 法拍件</span>
						</td>
					</tr>

					<tr >
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" width="250px">
							<span>不動產移轉證明</span>
						</td>
						<td class="tbYellow2" colspan="7">
							<label><input type="radio" id="EST_TRA_DOC_OK" name="EST_TRA_DOC" value="0">已檢附，且拍攝完整</label>
							<label><input type="radio" id="EST_TRA_DOC_NG" name="EST_TRA_DOC" value="1">未檢附或未完整拍攝</label>
						</td>
					</tr>
				</tbody>
			</table>
			
			<table id="table_EDQ" class="tbBox2" width="100%" cellspacing="1" cellpadding="1">
				<tbody>
					<tr>
						<td class="tbYellow0" rowspan="1" colspan="7" style="text-align:center;">
							<span style="font-weight:bold;">外部資料查詢</span>
						</td>
					</tr>
					
					<tr>
						<td class="tbBlue" rowspan="2" colspan="1" style="text-align:center;">
							<span>客戶種類/姓名/ID</span>
						</td>
					
						<td class="tbBlue" rowspan="2" colspan="2" style="text-align:center;">
							<span>經營事業/目前服務單位</span>
						</td>
					</tr>

					<tr>
						<td class="tbBlue" style="text-align:center;">
							<span>監輔宣告</span>
							<span class="textBlue" style="text-decoration:underline; ">
								<a id="link_jud" href="javascript:void();">查詢連結</a>	
							</span>
						</td>

						<td class="tbBlue" style="text-align:center;">
							<span>營登查詢</span>
							<BR>
							<span class="textBlue" style="text-decoration:underline; ">(財政部)
								<a id="link_bus1" href="javascript:void();">查詢連結</a>
							</span>
							<BR>
							<span class="textBlue" style="text-decoration:underline; ">(經濟部)
								<a id="link_bus2" href="javascript:void();">查詢連結</a>
							</span>
						</td>

						<td class="tbBlue" style="text-align:center;">
							<span>票交所查詢</span>
							<span class="textBlue" style="text-decoration:underline; ">
								<a id="link_cle" href="javascript:void();">查詢連結</a>
							</span>
						</td>

						<td class="tbBlue" style="text-align:center;">
							<span>專門職業資格</span>
						</td>
					</tr>
					
					<%-- 寫入外部資料 --%>

				</tbody>
			</table>

			<table id="CalTb" class="tbBox2" width="100%" cellspacing="1" cellpadding="2" readonly>
				<tbody>
					<tr>
						<td class="tbYellow0" rowspan="1" colspan="10" style="text-align:center;">
							<span style="font-weight:bold; ">基本資料檢核</span>
							<span>※尚未簽件時方更新資訊</span>
						</td>

					</tr>
					<tr>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" width="150px">
							<span>基本資料檢核（一）<br> 借保人資料</span>
						</td>

						<td class="tbYellow2" rowspan="1" colspan="9" style="text-align:left;">
							<div id="CAL1_1"></div>
							<br>
							<span>金融集團員工檢核：【任用別/本職公司及職稱/集團年資】(僅包含金控、銀行、人壽、產險、證券、投信、投顧)</span>
							<div id="EMP" style="padding-left: 10px"></div>
						</td>

					</tr>
					<tr>
						<td class="tbBlue" rowspan="1" colspan="10" style="text-align:left;"></td>
					</tr>
					<tr>
						<td class="tbYellow" rowspan="1" colspan="1" style="text-align:center;" >
							<span>基本資料檢核（二）<br> 貸款∕送件紀錄</span>
						</td>

						<td class="tbYellow2" rowspan="1" colspan="9"
							style="text-align:left;">
							<span>1.近一次送件情形 (排除本次申貸件)</span><br>
							<div id ="LAST_SUBMIT" style="padding-left: 10px"></div>
							
							<div style="display:flex;">
								<div style="width: 115px">2.案件受理情形</div>
								<div>
									<label><input type="checkbox" id="PENDING_CASE" name="checkList2_3" text="借保人尚有審理中案件">借保人尚有審理中案件</label>
									<label><input type="checkbox" id="CREDIT_REJ" name="checkList2_3" text="借保人曾因債信退件">借保人曾因債信退件</label>
									<label><input type="checkbox" id="GAGE_DIF_3M" name="checkList2_3" text="本擔近三個月有他人送件">本擔近三個月有不同經手人或銀行端送件</label>
									<label><input type="checkbox" id="FIRST_BUY" name="checkList2_3" text="首購未附財產清單">首購未附財產清單</label>
									<label><input type="checkbox" id="PAYOFF_3M" name="checkList2_3" text="清償逾3個月可適用新件">清償未領超過3個月可適用新件</label>
									<label><input type="checkbox" id="BUY_INSURANCE" name="checkList2_3" text="本次用途為購買保險">本次借款用途告知購買保險</label>
									<label><input type="checkbox" id="ILL_APP" name="checkList2_3" text="本案曾不識字對保">本案曾不識字對保</label>
									<label><input type="checkbox" id="SPC_LOAN" name="checkList2_3" text="案源為代書/建商/代辦">貸款來源為代書/建商/仲介介紹、代辦</label>
								</div>
							</div>
							
							<span>3.貸款紀錄</span><br>
							<div id ="LOAN_LOG" style="padding-left: 10px"></div>
							<span>4.本擔借款情形：</span>
							<span>
								<label><input type="checkbox" id="LOAN_STATUS_ERR" name="checkList2_4" text="本擔借款-契約效力異常">契約效力異常</label>
								<label><input type="checkbox" id="PAY_STA_6P" name="checkList2_4" text="本擔借款-近六期繳息異常">近六期繳息異常</label>
								<label><input type="checkbox" id="PAY_STA_5Y" name="checkList2_4" text="本擔借款-近五年曾繳息異常">近五年曾繳息異常</label>
								<label><input type="checkbox" id="CLAIM_COSTS" name="checkList2_4" text="本擔借款-有裁定費用">有裁定費用</label>
								<label><input type="checkbox" id="SPC_CTR_LOAN" name="checkList2_4" text="本擔借款-特殊件控管紀錄">特殊件控管紀錄</label>
							</span>
							<br>
							
							<span>5.其他借款/保證債務情形：</span>
							<br>
							<div id="CAL2_5" style="padding-left: 10px;"></div>
						</td>
					</tr>

					<tr>
						<td class="tbBlue" rowspan="1" colspan="10" style="text-align:left;">
							<span> **為核准日期前最後一次謄本查詢記錄**</span>
						</td>
					</tr>
                    
					<tr>
						<td class="tbYellow" rowspan="2" colspan="1" style="text-align:center;">
							<span>基本資料檢核（三）<br> 謄本/抵押權設定資訊 </span>
						</td>

						<td class="tbYellow2" rowspan="1" colspan="9" style="text-align:left;">
							<span>1.土地分區：</span><span id='A040USERS'></span>
							<div>2.其他登記事項</span>
							<br>
							<div style="padding-left: 8px">
								<%--[20240322] 問題單:20240322115438 移除權狀註記事項欄位--%>
								<%--<label><input type="checkbox" id="DEBT_CODE" name="checkList3" text="謄本-權狀註記事項">權狀註記事項</label>--%>
								<label><input type="checkbox" id="LIMIT_CODE" name="checkList3" text="謄本-限制登記事項">限制登記事項</label>
								<label><input type="checkbox" id="NORMAL_CODE" name="checkList3" text="謄本-一般登記事項">一般登記事項</label>
								<label><input type="checkbox" id="ASS_SET_MORT" name="checkList3" text="謄本-讓與或設定抵押權限制">讓與或設定抵押權限制</label>
								<label><input type="checkbox" id="ROC_CLAIMANT" name="checkList3" text="謄本-預告登記請求權人">預告登記請求權人</label>
								<label><input type="checkbox" id="MAX_LIM_MORT" name="checkList3" text="謄本-本最高限額抵押權已確定">本最高限額抵押權已確定</label>
								<label><input type="checkbox" id="RUR_EXP" name="checkList3" text="謄本-列冊管理期滿">列冊管理期滿</label>
								<label><input type="checkbox" id="READJUST" name="checkList3" text="謄本-有重劃 (測) 紀錄">有重劃 (測) 紀錄</label>
								<label><input type="checkbox" id="LAND_OTHER" name="checkList3" text="謄本-有其他登記事項">設定-有其他登記事項</label>
							</div>
							<span>3.是否有特殊情形</span>
							<br>
							<div style="padding-left: 8px"> 
								<div style="display: flex" >
									<div style=" width: 65px;">(1) 主建物</div>
									<div>
										<label><input type="checkbox" id="MUTI_BUD_NM" name="checkList3" text="兩個以上主建號">兩個 (含) 以上主建號</label>
										<label><input type="checkbox" id="HOLD_PART" name="checkList3" text="主建物持份非 1/1">持份非 1/1</label>
										<label><input type="checkbox" id="SPACE_L5" name="checkList3" text="主建物小於 5 坪">小於 5 坪</label>
										<label><input type="checkbox" id="IS_FARMHOUSE" name="checkList3" text="主建物登記用途為農舍">登記用途為農舍</label>
										<label><input type="checkbox" id="IS_BRICK" name="checkList3" text="主建物建材為磚造或空白">建材為磚造</label>
										<label><input type="checkbox" id="OWN_NO_CON" name="checkList3" text="未全部所有權人進件">未全部所有權人進件</label>
										<label><input type="checkbox" id="REG_DATE_L1Y" name="checkList3" text="主建物登記日期未超過 1 年">登記日期未超過 1 年</label>
									</div>
								</div>
								<div>
									<span>(2) 與前次資料比對</span>
									<span>
										<label><input type="checkbox" id="BALC_CHK" name="checkList3" text="需人工檢核前次貸款地建號及坪數">需人工檢核前次貸款地建號及坪數</label>
									</span>
									<span>
										<label><input type="checkbox" id="GAGE_REJ" name="checkList3" text="與前次貸款地建號不符">與前次貸款地建號不符</label>
										<label><input type="checkbox" id="SPACE_REJ" name="checkList3" text="與前次貸款坪數不符">與前次貸款坪數不符</label>
									</span>
								</div>
								<div>(3) 設定資料檢核</div>
								<div style="padding-left: 8px">
									<label><input type="checkbox" id="ADD_NO_CL" name="checkList3" text="增貸件無國壽設定">增貸件無國壽設定</label>
									<label><input type="checkbox" id="ADD_NOT_CL" name="checkList3" text="增貸件有非國壽設定">增貸件有非國壽設定</label>
									<label><input type="checkbox" id="TWO_LOAN" name="checkList3" text="二胎貸款">二胎貸款</label>
									<label><input type="checkbox" id="NO_LIMIT_CL" name="checkList3" text="國壽設定非最高限額">國壽設定非最高限額</label>
									<label><input type="checkbox" id="NO_RANGE_CL" name="checkList3" text="國壽設定非全部權利範圍">國壽設定非全部權利範圍</label>
									<label><input type="checkbox" id="CNT_REJ_CL" name="checkList3" text="國壽設定筆數與金庫資料不符">國壽設定筆數與金庫資料不符</label>
									<label><input type="checkbox" id="BLD_REJ" name="checkList3" text="各地建號設定內容不一致">各地建號設定內容不一致</label>
									<label><input type="checkbox" id="BLD_REJ_OTHER" name="checkList3" text="他項設定地建號與系統不一致">他項設定地建號與系統不一致</label>
								</div>
							</div>
							
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" style="text-align:left;">
							<div class="grid" id="grid"></div>
						</td>
					</tr>
				</tbody>
			</table>
			
			
			<table id="calTb2" class="tbBox2" width="100%" cellspacing="1" cellpadding="1" readonly>
				<tbody>
					<tr>
						<td class="tbYellow" rowspan="2" colspan="1" style="text-align:center;" width="150px">
							<span>基本資料檢核（四）<br> 輸入欄位檢核</span>
						</td>

						<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
							<span>作業系統資料尚未新增或修改</span>
							<span>
							    <%-- 
								<label><input type="checkbox" id="APPLY_INPUT" name="checkList4" text="借款申請輸入未完成">借款申請輸入</label> 
								<label><input type="checkbox" id="BORROW_INPUT" name="checkList4" text="借款資料輸入未完成">借款資料輸入</label>
								<label><input type="checkbox" id="GUAR_INPUT" name="checkList4" text="保人資料輸入未完成">保人資料輸入</label>
								<label><input type="checkbox" id="DATA_INPUT" name="checkList4" text="簽件作業未完成">簽件作業</label> --%>
								<label><input type="checkbox" id="RELATION" name="checkList4" text="同一關係人未完成">同一關係人</label>
							</span>
						</td>

					</tr>
					<tr>
						<td class="tbYellow2" rowspan="1" colspan="1" style="text-align:left;">
							<span>與近一次貸款紀錄比對：</span>
							<span>
								<label><input type="checkbox" id="BOR_BUS_OPR" name="checkList4" text="〈借款人〉行業別或職業類別有異動">〈借款人〉行業別或職業類別有異動</label> 
								
							</span>
						</td>

					</tr>
				</tbody>
			</table>
		</div>

	</div>
	</form>
</body>
</html>