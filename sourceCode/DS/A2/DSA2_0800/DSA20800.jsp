<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
    Date        Version Description Author
    2011-09-13  1.0     Created     陳正毅

    程式功能概要說明：
    程式功能　償債能力分析表
    程式名稱　DSA2_0800.java
    作業方式　ONLINE
    概要說明　(1) 查詢 ─ 使用者輸入查詢受理編號後，查詢評估對象的償債能力相關資料。
　　　　　　　(2) 新增 ─ 使用者按下新增按鈕後，將評估對象的償債能力相關資料新增至資料庫中(償債能力分析-收入部分DTDSA152、償債能力分析-本息支出(貸款)DTDSA153、償債能力分析-本息支出(信用卡)DTDSA158)。
　　　　　　　(3) 修改 ─ 使用者按下修改按鈕後，將評估對象的償債能力相關資料修改至資料庫中(償債能力分析-收入部分DTDSA152、償債能力分析-本息支出(貸款)DTDSA153、償債能力分析-本息支出(信用卡)DTDSA158)。
　　　　　　　(4) 刪除 ─ 使用者按下刪除按鈕後，將評估對象的償債能力相關資料刪除至資料庫中(償債能力分析-收入部分DTDSA152、償債能力分析-本息支出(貸款)DTDSA153、償債能力分析-本息支出(信用卡)DTDSA158)。
　　　　　　　(5) 組長同意 ─ 同意償債能力分析表資料。
　　　　　　　(6) 組長退回 ─ 退回償債能力分析表資料。
　　　　　　　(7) 科長同意 ─ 同意償債能力分析表資料。
　　　　　　　(8) 科長退回 ─ 退回償債能力分析表資料。
　　　　　　　(9) 列印 ─ 使用者按下列印按鈕後，將直接將畫面資料送出列印。
    按鈕授權　FUNC_ID = DSA20800

	@author 楊宗翰
	@since 2011-10-18
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

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
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

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var MaxIndex = {C:0, D:0, E:0, F:0, G:0, I:0};	// 最大的index值
var UpdateIndex = {C:null, D:null, E:null, F:null, G:null, I:null};	// 正在異動的index

// 檢核
var validate4define;

// 檢核字數-修正原因說明
var twoBytesRegExp = /[^\x00-\xff]/g;

// 檢核textArea的長度
var textarea_MaxLength;

// 檢核數字格式-整數長度、小數長度
var public_intLength;
var public_decLength;
var public_isPositive;
var intType = "1";	// 1:大於0的整數, 2:大於等於0的整數, 3:小於等於0的整數, 4:小於0的整數, 5:整數

var Is_dataA;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)
var pattern_money = "#,###";	// 金額格式(無小數)
var pattern_money1 = "#,###.#";	// 金額格式(小數1位)
var pattern_money2 = "#,###.##";	// 金額格式(小數2位)
var pattern_money3 = "###.###";	// 金額格式(小數3位)
var pattern_money4= "###.####";	// 金額格式(小數4位)

// 下拉選單－CARD_TYPE
var CARD_TYPE_List = [{key:"A", value:"現金卡"}, {key:"B", value:"信用卡"}];



//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0003:'A_btn_add',<%--新增--%>
		B0004:'A_btn_update',<%--修改--%>
		B0005:'A_btn_delete',<%--刪除--%>
		B0017:'A_btn_agree1',<%--組長同意--%>
		B0018:'A_btn_reject1'<%--組長退回--%>
	};
	<dz:grantButtons FUNC_ID="DSA20800" ignored="false"/>
}

function initApp(){

	PageUI.createPage('DSA20800' , '核貸作業', '償債能力分析表', '${titleNotDisplay}'=='Y');
	PageUI.loadin(['tableA','tableB','tableC'] ,1);

	// 日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();
	// 按鈕權限
	buttonAuth();

	// 檢核物件
	validate4define = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		]
	]);

	new UI().init();

	PageUI.resize(true);
}

function UI(){
	return {
		init:function() {
			displayMessage();

			//--------- 註冊按鈕 ----------
			// 查詢
			$("A_btn_query").observe('click',function(event){
				buttons.doQuery();
			});

			// 查詢
			$("A_btn_print").observe('click',function(event){
				buttons.doPrint();
			});

			// 新增
			$w('A_btn_add C_btn_add D_btn_add E_btn_add F_btn_add G_btn_add I_btn_add').each(
				function(key){
					$(key).observe('click', function(event){
						var preKey = key.substring(0, 1);
						buttons.doAdd(preKey);
					});
				}
			);

			// 修改
			$w('A_btn_update').each(
				function(key){
					$(key).observe('click', function(event){
						buttons.doUpdate();
					});
				}
			);

			// 刪除
			$w('A_btn_delete C_btn_delete D_btn_delete E_btn_delete F_btn_delete G_btn_delete I_btn_delete').each(
				function(key){
					$(key).observe('click', function(event){
						var preKey = key.substring(0, 1);
						buttons.doDelete(preKey);
					});
				}
			);

			// 同意
			$w('A_btn_agree1').each(
				function(key){
					$(key).observe('click', function(event){
						var preKey = key.split("A_btn_agree")[1];
						buttons.doAgree(preKey);
					});
				}
			);

			// 退回
			$w('A_btn_reject1').each(
				function(key){
					$(key).observe('click', function(event){
						var preKey = key.split("A_btn_reject")[1];
						buttons.doReject(preKey);
					});
				}
			);

			//--------- 註冊事件 ----------
			// A
			register.textNoSpace('A_APPLY_ID', "upper");	// 受理編號

			// H
			register.textNoSpace('H_FINAL_MSG');	// 綜合分析

			// I
			register.isPatternNumber('I_CREDIT_MONTH');	// 近...個月

			if ('${APPLY_ID}' != "") {
				$('A_APPLY_ID').value = '${APPLY_ID}';
			} else {
				//保留參數管理-取得受理編號
				$('A_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}
			if($('A_APPLY_ID').value){
				buttons.doQuery();
			}

			if($('H_FINAL_MSG').addEventListener){
				$('H_FINAL_MSG').observe('input',function(){
					if(this.scrollHeight > 180){
						this.style.posHeight=this.scrollHeight
					}
				});
			}else{
				$('H_FINAL_MSG').observe('propertychange',function(){
					if(this.scrollHeight > 180){
						this.style.posHeight=this.scrollHeight
					}
				});
			}
		}
	};
}

//--------------------------------------------------------------------------
// 註冊事件
//--------------------------------------------------------------------------
var register = {
	// 欄位去空白
	textNoSpace:function (keys, type, toFullwidth){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.text(key, true, "", toFullwidth);

					// 轉大寫或小寫
					if($(key).value){
						if(type == "upper"){
							$(key).value = $(key).value.toUpperCase();
						}else if(type == "lower"){
							$(key).value = $(key).value.toLowerCase();
						}
					}
				});
			}
		);
	},
	// 數字欄位轉換
	isNumber:function (keys){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.number(key);
				});
			}
		);
	},
	// 數字(有位數或格式限制)欄位轉換
	isPatternNumber:function (keys){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.patternNumber(key, true, $(key).pattern);
				});
			}
		);
	}
};

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		if(!validates.checkInput("query")){
			return;
		}

		var queryData = {
			APPLY_ID: $('A_APPLY_ID').value
		};

		var actionName = "query";
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(resp){
			layout.loadData(resp);
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 新增
	doAdd:function(type){
		var actionName = "add";

		if(!validates.checkInput(actionName, type)){
			return;
		}

		if(type == "A"){
			var data = auxiliary.getAllData(actionName);

			var params = {"queryData":Object.toJSON(data)};
			var successAction = function(resp){
				layout.loadData(resp);
			};
			var errorAction = function(resp){
				// 畫面保留按鈕前資訊
			};
			ajaxPost(actionName, params, successAction, errorAction);
		}else if(type == "C"){
			layout.create_Block_C();
		}else if(type == "D"){
			layout.create_Block_D();
		}else if(type == "E"){
			layout.create_Block_E();
		}else if(type == "F"){
			layout.create_Block_F();
		}else if(type == "G"){
			layout.create_Block_G();
		}else if(type == "I"){
			layout.create_Block_I();
		}
		parseEUDC();<%--[20240729] 難字調整，動態產需呼叫 --%>
	},
	// 修改
	doUpdate:function(){
		var actionName = "update";
		if(!validates.checkInput(actionName, "A")){
			return;
		}

		var data = auxiliary.getAllData();

		var params = {"queryData":Object.toJSON(data)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(resp){
			// 畫面保留按鈕前資訊
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 刪除
	doDelete:function(type){
		var actionName = "delete";
		if(!validates.checkInput(actionName, type)){
			return;
		}

		if(type == "A"){
			var queryData = {
				APPLY_ID: $('B_APPLY_ID').innerHTML,
				QRY_ID: $('B_BORROW_ID').innerHTML
			};
			var params = {"queryData":Object.toJSON(queryData)};
			var successAction = function(resp){
				layout.loadData(resp);
			};
			var errorAction = function(resp){
				// 畫面保留按鈕前資訊
			};
			ajaxPost(actionName, params, successAction, errorAction);
		}else {
			layout.delete_Selected_Detail(type);
		}
	},
	// 同意
	doAgree:function(type){
		var action = "leader_agree";

		if(!validates.checkInput(action)){
			return;
		}

		var queryData = {
			APPLY_ID: $('B_APPLY_ID').innerHTML
		};
		var actionName = "agree";
		var params = {"queryData":Object.toJSON(queryData), "TYPE":type};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(resp){};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 退回
	doReject:function(type){
		var action = "leader_reject";

		if(!validates.checkInput(action)){
			return;
		}

		var queryData = {
			APPLY_ID: $('B_APPLY_ID').innerHTML
		};
		var actionName = "reject";
		var params = {"queryData":Object.toJSON(queryData), "TYPE":type};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(resp){};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	doPrint:function(){
		if(!validates.checkInput("query")){
			return;
		}

		var queryData = {
			APPLY_ID: $('A_APPLY_ID').value,
			SUM_TOTAL_PRICE:formatInput.getSplitValue($('C_SUM_TOTAL_PRICE').innerHTML, ","),
			SUM_INCOME:formatInput.getSplitValue($('D_SUM_INCOME').innerHTML, ","),
			SUM_LOAN_AMT:formatInput.getSplitValue($('F_SUM_LOAN_AMT').innerHTML, ","),
			SUM_YEAR_AMT:formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ","),
			INCOME_EXP_RATE:formatInput.getSplitValue($('H_INCOME_EXP_RATE').innerHTML, ","),
			CREDIT_MONTH: $('I_CREDIT_MONTH').value
		};

		var url = "<%=dispatcher%>/DSA2_0801/prompt?queryData="+Object.toJSON(queryData);
		window.open(url,"DSA2_0801", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var comment_Limit = {
	GAGE_MSG:100,
	BUILD_ADDR:80,
	CREDIT_MSG:400
};

var keyMap = {
	BUILD_NAME:"所有權人",
	COMP_BANK:"設定銀行",
	BUILD_ADDR:"地點",
	USE_STATUS:"使用狀況",
	RENTAL:"月租金",
	SET_AMT:"貸款餘額",
	GAGE_MSG:"不動產說明",
	TOTAL_PRICE:"總價",
	GAGE_PRICE:"單價",
	GAGE_SPACE:"建坪",
	INCOME_NAME:"當事人",
	INCOME_ITEM:"收入項目",
	INCOME:"年所得(萬)",
	LOAN_AMT:"金額",
	RATE:"利率",
	LOAN_PERIOD:"年期(期數)",
	YEAR_AMT:"本金與利息(仟/年)",
	CARD_COUNT:"張數",
	YEAR_RATE:"利率",
	FINAL_MSG:"綜合分析",
	CREDIT_MONTH:"授信餘額月份",
	CREDIT_NAME:"授信餘額姓名",
	AMT_A:"變動前授信餘額",
	AMT_B:"變動後授信餘額",
	CREDIT_MSG:"授信額度說明"
};

var validates = {
	// 畫面欄位
	checkInput:function(action, type){
		validate4define.clear();	// 清define
		validate4define.reset();	// 清背景色

		// 查詢
		if(action == "query"){
			validates.checkInputA();
		}
		// 新增
		else if(action == "add"){
			if(type == "A"){
				// B區的受理編號須有值，否則跳出警示訊息： “請先查詢，再做新增、刪除、修改"。
				if(!validates.checkInputB("新增")){
					return false;
				}

				// A區的受理編號須有值，否則跳出警示訊息： “請輸入受理編號"
				if(validates.checkInputA()){
					// 若A區的受理編號有值，B區的受理編號與A區的受理編號必須一致
					var A_APPLY_ID = $('A_APPLY_ID').value;
					if(A_APPLY_ID != $(B_APPLY_ID).innerHTML){
						if(!confirm("受理編號不一致，請確認是否將資料新增到受理編號:" + A_APPLY_ID + "中?")){
							return false;
						}
					}
					// 若 Is_dataA <> “N”，且A區的受理編號=B區的受理編號
					else if(Is_dataA != "N"){
						alert("資料已存在，無法新增！");
						return false;
					}
					// 若本金與利息支出合計<=0，跳出警示訊息：“本金與利息支出合計不得為0”
					else if(Number(formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",")) <= 0){
						alert("本金與利息支出合計不得為0");
						return false;
					}
					//D區必須至少有一筆收入資料
					else if($('tbody_D').rows.length < 1){
						alert('請輸入收入資料!');
						return false;
					}

					//C區必須至少有一筆不動產明細料
					else if($('tbody_C').rows.length < 1){
						alert('請輸入不動產明細資料!');
						return false;
					}

					// C, D, E, F, G, H, I檢核
					validates.checkInputC();
					validates.checkInputD();
					validates.checkInputE();
					validates.checkInputF();
					validates.checkInputG();
					validates.checkInputH();
					validates.checkInputI();
				}
			}else {
				var msg = "";
				var checkAPPLY_ID = false;
				var checkBORROW_ID = true;

				if(type == "C"){
					msg = "新增【借款人及保證人不動產明細】";
					checkBORROW_ID = false;
				}else if(type == "D"){
					msg = "新增【收入部分】";
				}else if(type == "E"){
					msg = "新增【本金與利息支出估計－本公司貸款】";
				}else if(type == "F"){
					msg = "新增【本金與利息支出估計－其他行庫貸款】";
				}else if(type == "G"){
					msg = "新增【本金與利息支出估計－現金/信用卡貸款】";
				}else if(type == "I"){
					msg = "新增【本金與利息支出估計－授信餘額】";
				}

				return validates.checkInputB(msg, checkAPPLY_ID, checkBORROW_ID);
			}
		}
		// 刪除
		else if(action == "delete"){
			if(type == "A"){
				if(!validates.checkInputB("刪除", true)){
					return false;
				}

				// 若Is_dataA <> “Y”，跳出警示訊息： “請先新增資料後，再作修改、刪除！”
				if(Is_dataA != "Y"){
					alert("請先新增資料後，再作刪除！");
					return false;
				}

				if(!confirm("確定刪除償債能力分析?")){
					return false;
				}
			}else {
				var msg = "";

				if(type == "C"){
					msg = "刪除【借款人及保證人不動產明細】";
					checkBORROW_ID = false;
				}else if(type == "D"){
					msg = "刪除【收入部分】";
				}else if(type == "E"){
					msg = "刪除【本金與利息支出估計－本公司貸款】";
				}else if(type == "F"){
					msg = "刪除【本金與利息支出估計－其他行庫貸款】";
				}else if(type == "G"){
					msg = "刪除【本金與利息支出估計－現金/信用卡貸款】";
				}else if(type == "I"){
					msg = "刪除【本金與利息支出估計－授信餘額】";
				}

				if(!validates.isRadioChecked(type, msg)){
					return false;
				};
			}
		}
		// 修改
		else if(action == "update"){
			var i = 0;
			if(!validates.checkInputB("修改", true)){
				return false;
			}

			// 若Is_dataA <> “Y”，跳出警示訊息： “請先新增資料後，再作修改、刪除！”
			if(Is_dataA != "Y"){
				alert("請先新增資料後，再作修改！");
				return false;
			}
			// 若本金與利息支出合計<=0，跳出警示訊息：“本金與利息支出合計不得為0”
			else if(Number(formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",")) <= 0){
				alert("本金與利息支出合計不得為0");
				return false;
			}
			//D區必須至少有一筆收入資料
			else if($('tbody_D').rows.length < 1){
				alert('請輸入收入資料!');
				return false;
			}

			//C區必須至少有一筆收入資料
			else if($('tbody_C').rows.length < 1){
				alert('請輸入不動產明細資料!');
				return false;
			}

			// C, D, E, F, G, H, I檢核
			validates.checkInputC();
			validates.checkInputD();
			validates.checkInputE();
			validates.checkInputF();
			validates.checkInputG();
			validates.checkInputH();
			validates.checkInputI();
		}
		// 試算
		else if(action == "calculate"){
			if(!validates.isRadioChecked(type, "試算")){
				return false;
			}
		}
		// 組長/科長 同意、退回
		else {

			var msg = "";
			if(action == "leader_agree"){
				msg = "組長同意";
			}else if(action == "chief_agree"){
				msg = "科長同意";
			}else if(action == "leader_reject"){
				msg = "組長退回";
			}else if(action == "chief_reject"){
				msg = "科長退回";
			}

			if(msg && !validates.checkInputB(msg, true)){
				return false;
			}
		}
		return validate4define.validate();
	},
	// 檢查A
	checkInputA:function(){
		var key = "A_APPLY_ID";
		if(validates.isBlank(key, true)){
			validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : "請輸入受理編號"}] , { useTitle: false });
			return false;
		}
		return true;
	},
	// 檢查B
	checkInputB:function(action, checkAPPLY_ID, checkBORROW_ID){
		if(checkAPPLY_ID){
			var B_APPLY_ID = $('B_APPLY_ID').innerHTML;
			if(B_APPLY_ID == ""){
				alert("案件資料無受理編號，無法" + action);
				return false;
			}
		}

		if(checkBORROW_ID){
			var B_BORROW_ID = $('B_BORROW_ID').innerHTML;
			if(B_BORROW_ID == ""){
				alert("案件資料無借款人ID，無法" + action);
				return false;
			}
		}

		return true;
	},
	// 檢查C
	checkInputC:function(){
		var preKey = "C_";
		var tbody = $('tbody_C');

		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;

			// 所有權人
			validates.checkInput_C('BUILD_NAME', preKey, postKey, keyMap, true, false);

			// 設定銀行
			var key = 'COMP_BANK';
			var newKey = preKey + key + postKey;
			var maxLength = 20;
			if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
				var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + maxLength + ")";
				validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
			}

			// 使用狀況
			var key = 'USE_STATUS';
			if(validates.checkInput_C(key, preKey, postKey, keyMap, true, false)){
				var newKey = preKey + key + postKey;
				var maxLength = 10;
				if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
					var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + maxLength + ")";
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
				}
			}

			// 地點
			var key = 'BUILD_ADDR';
			if(validates.checkInput_C(key, preKey, postKey, keyMap, true, false)){
				var newKey = preKey + key + postKey;
				var maxLength = comment_Limit[key];
				if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
					var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + maxLength + ")";
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
				}
			}

			// 月租金
			var key = 'RENTAL';
			if(validates.checkInput_M(key, preKey, postKey, keyMap, false)){
				var newKey = preKey + key + postKey;

				if(Number($(newKey).getValue()) > 100000){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : keyMap[key] + "數字過大(不可大於100,000),請注意:本欄位是以萬元為單位!"}] , { useTitle: false });
				}
			}

			// 貸款餘額
 			validates.checkInput_M('SET_AMT', preKey, postKey, keyMap, false);

			// 不動產說明
			var key = 'GAGE_MSG';
			if(validates.checkInput_C(key, preKey, postKey, keyMap, false, false)){
				var newKey = preKey + key + postKey;
				var maxLength = comment_Limit[key];
				if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
					var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + maxLength + ")";
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
				}
			}

			//  總價、單價、建坪
			validates.checkInput_M('TOTAL_PRICE GAGE_PRICE GAGE_SPACE', preKey, postKey, keyMap, true);

		}
	},
	// 檢查D
	checkInputD:function(){
		var preKey = "D_";
		var tbody = $('tbody_D');

		var length = tbody.rows.length;

		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;

			// 當事人、收入項目
			validates.checkInput_C('INCOME_NAME INCOME_ITEM', preKey, postKey, true, false);

			// 年所得(萬)
			validates.checkInput_M('INCOME', preKey, postKey, true);

		}

		$$('#table_D textArea[id]').each(
			function(obj){
				if(!validates.isTextAreaLengthLegal(obj.id, 1000)){
					validate4define.define( "customize_returnFalse" , [{ id :obj.id , errMsg : "收入部分－說明長度為(1000)(中文佔2個字)!!"}] , { useTitle: false });
				}
			}
		);

	},
	// 檢查E
	checkInputE:function(){
		var preKey = "E_";
		var tbody = $('tbody_E');

		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;
			// 本公司貸款
			var tmpMap = {BANK_NAME:"本公司貸款"};
			validates.checkInput_C('BANK_NAME', preKey, postKey, tmpMap, true, false);
			//  金額、利率、年期(期數)、本金與利息(仟/年)
			validates.checkInput_M('LOAN_AMT RATE LOAN_PERIOD', preKey, postKey, keyMap, true);
		}
	},
	// 檢查F
	checkInputF:function(){
		var preKey = "F_";
		var tbody = $('tbody_F');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;
			// 其他行庫貸款
			var tmpMap = {BANK_NAME:"其他行庫貸款"};
			validates.checkInput_C('BANK_NAME', preKey, postKey, tmpMap, true, false);
			// 金額、利率、年期(期數)
			validates.checkInput_M('LOAN_AMT RATE LOAN_PERIOD', preKey, postKey, keyMap, true);
		}
	},
	// 檢查G
	checkInputG:function(){
		var preKey = "G_";
		var tbody = $('tbody_G');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;
			// 張數
			validates.checkInput_M('CARD_COUNT', preKey, postKey, keyMap, false);
			// 金額、利率
			validates.checkInput_M('LOAN_AMT YEAR_RATE', preKey, postKey, keyMap, true);
		}

	},
	// 檢查H
	checkInputH:function(){
		// 綜合分析
		if(!validates.isTextAreaLengthLegal('H_FINAL_MSG', 5000)){
			validate4define.define( "customize_returnFalse" , [{ id :'H_FINAL_MSG' , errMsg : "綜合分析－長度為(5000)(中文佔2個字)!!"}] , { useTitle: false });
		}
	},
	// 檢查I
	checkInputI:function(){
		var preKey = "I_";
		var postKey = "";
		var tbody = $('tbody_I');
		var length = tbody.rows.length;
		if(length > 0){
			// 授信餘額月份
			validates.checkInput_M('CREDIT_MONTH', preKey, postKey, keyMap, false);
		}
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			postKey = '_' + no;

			// 授信餘額姓名
			validates.checkInput_C('CREDIT_NAME', preKey, postKey, keyMap, true, false);
			// 授信餘額
			validates.checkInput_M('AMT_A AMT_B', preKey, postKey, keyMap, true);
			// 授信額度說明
			var key = 'CREDIT_MSG';
			if(validates.checkInput_C(key, preKey, postKey, keyMap, false, false)){
				var newKey = preKey + key + postKey;
				var maxLength = comment_Limit[key];
				if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
					var msg = keyMap[key] + "的字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限(" + maxLength + ")";
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
				}
			}
		}
	},
	// 檢查radio是否有勾選
	isRadioChecked:function(type, action){
		var selectIndex = UpdateIndex[type];
		if(!selectIndex){
			alert("沒有勾選任何一筆資料，無法" + action);
			return false;
		}
		return true;
	},
	// 檢查是否為空值
	isBlank:function(key_Value, isKey){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		// 取得value
		var value;
		if(isKey){
			if($(key_Value)){
				value = $(key_Value).value;
			}else{
				return false;
			}
		}else{
			value = key_Value;
		}

		if(value || !isNaN(parseInt(value, 10))){
			return false;
		}else{
			return true;
		}
	},
	// 檢查是否不為空值
	isNotBlank:function(key_Value, isKey){
		return !validates.isBlank(key_Value, isKey);
	},
	// 輸入欄位的檢核(中文)
	checkInput_C:function(keys, preKey, postKey, keyMap, checkEmpty, checkfull, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;
				var title = (keyMap && keyMap[key]) ? keyMap[key] : "";

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(checkfull === true && validation.hasHalfType($(newKey).value)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "必須為全形字"}] , { useTitle: useTitle });
					result = false;
				}
			}
		);

		return result;
	},
	// 輸入欄位的檢核(數字)
	checkInput_N:function(keys, preKey, postKey, keyMap, checkEmpty, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;
				var title = (keyMap && keyMap[key]) ? keyMap[key] : "";

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(!validates.isNumber(newKey)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "只能輸入數字"}] , { useTitle: useTitle });
					result = false;
				}
			}
		);

		return true;
	},
	// 輸入欄位的檢核(金額)
	checkInput_M:function(keys, preKey, postKey, keyMap, checkEmpty, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;
				var title = (keyMap && keyMap[key]) ? keyMap[key] : "";

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(!validates.isNumber(newKey)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : title + "只能輸入數字"}] , { useTitle: useTitle });
					result = false;
				}else {
					//var intLength = $(newKey).intLength ? $(newKey).intLength : 0;
					//var	decLength = $(newKey).decLength ? $(newKey).decLength : 0;
					//var	numberType = $(newKey).numberType ? $(newKey).numberType : "5";
					var intLength = $(newKey).getAttribute("intLength") ? $(newKey).getAttribute("intLength") : 0;
					var	decLength = $(newKey).getAttribute("decLength") ? $(newKey).getAttribute("decLength") : 0;
					var	numberType = $(newKey).getAttribute("numberType") ? $(newKey).getAttribute("numberType") : "5";

					var msg;
					if(intLength > 0 && decLength > 0){
						msg = "格式有誤(應為整數" + intLength + "位、小數" + decLength + "位)";
					}else if(intLength > 0){
						msg = "格式有誤(應為整數" + intLength + "位)";
					}else if(decLength > 0){
						msg = "格式有誤(應為小數" + decLength + "位)";
					}

					if(numberType == "1"){
						msg = msg ? msg + "，且大於0" : "應為大於零的整數";
					}else if(numberType == "2"){
						msg = msg ? msg + "，且大於等於0" : "應為大於等於零的整數";
					}else if(numberType == "3"){
						msg = msg ? msg + "，且小於等於0" : "應為小於等於零的整數";
					}else if(numberType == "4"){
						msg = msg ? msg + "，且小於0" : "應為小於零的整數";
					}else if(numberType == "5"){
						msg = msg ? msg : "應為整數";
					}

					if(!validates.isNumPattern(newKey, numberType)){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : keyMap[key] + msg}] , { useTitle: useTitle });
						result = false;
					}
				}
			}
		);

		return result;
	},
	// 檢查textArea是否超過字數限制
	isTextAreaLengthLegal:function(key, maxLength){
		var value = $(key).getValue();

		if(!isNaN(parseInt(maxLength, 10))){
			return validateStringBytes(value, 0, maxLength);
		}else{
			return true;
		}
	},
	// 檢查輸入日期是否合法
	isDate:function(date, checkEmpty, mod, yearLimit){
		var inputDate;
		if($(date)){
			inputDate = $(date).value;
		}else{
			inputDate = date;
		}

		if(checkEmpty !== true && inputDate == ""){
			return true;
		}else{
			yearLimit = (yearLimit === false) ? false : true;
			if(mod == "ROC"){
				return isROCdate(inputDate, yearLimit);
			}else{
				return isADdate(inputDate, yearLimit);
			}
		}
	},
	// 檢核傳進來的值是否為正確的數字格式？是，則將該欄位依照pattern(自訂或預設)格式化；否，則將該欄位清空
	isNumber:function(key){
		var value = $(key).getValue().trim();

		if(isNaN(parseInt(value, 10))){
			return false;
		}else{
			return true;
		}
	},
	// 檢核數字欄位是否符合規定的長度
	isNumPattern:function(key, numberType){
		if(validates.isNumber(key)){
			//var intLength = $(key).intLength;
			//var decLength = $(key).decLength ? $(key).decLength : 0;
			//var pattern = $(key).pattern;
			//var numberType = $(key).numberType;	// 1:大於0 2:大於等於0 3:小於等於0 4:小於0

			var intLength = $(key).getAttribute("intLength");
			var	decLength = $(key).getAttribute("decLength") ? $(key).getAttribute("decLength") : 0;
			var	pattern = $(key).getAttribute("pattern");
			var	numberType = $(key).getAttribute("numberType");// 1:大於0 2:大於等於0 3:小於等於0 4:小於0

			var value = $(key).getValue() + "";
			var tmp1 = value.split(".");
			var INT = tmp1[0];
			var DEC = (tmp1.length > 1) ? tmp1[1] : "";

			if(numberType == "1"){	// 1:大於0
				if(Number(value) <= 0){
					return false;
				}else if(intLength && INT.length > intLength){
					return false;
				}
			}else if(numberType == "2"){	// 2:大於等於0
				if(Number(value) < 0){
					return false;
				}else if(intLength && INT.length > intLength){
					return false;
				}
			}else if(numberType == "3"){	// 3:小於等於0
				if(Number(value) > 0){
					return false;
				}else if(INT.length > intLength+1){
					return false;
				}
			}else if(numberType == "4"){	// 4:小於0
				if(Number(value) >= 0){
					return false;
				}else if(INT.length > intLength+1){
					return false;
				}
			}else{
				if(Number(value) < 0 && intLength && INT.length > intLength+1){
					return false;
				}else if(Number(value) >= 0 && intLength && INT.length > intLength+1){
					return false;
				}
			}

			if(DEC.length > decLength){
				return false;
			}else {
				return true;
			}
		}

		return false;
	},
	// 回傳false
	returnFalse:function(){
		return false;
	}
};

//--------------------------------------------------------------------------
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	// 新增一筆可輸入的【借款人及保證人不動產明細】
	create_Block_C:function(datas){
		var TYPE = "C";
		var preKey = TYPE + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、所有權人、地點、使用狀況/月租金、設定銀行/貸款餘額、市值估算) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 所有權人
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUILD_NAME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'所有權人',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'60',
			value:value,
			alt: "ch", <%-- [20240729]難字調整 --%>
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);

		td.appendChild(input);

		// 地點
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUILD_ADDR';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id: id,
			fieldName:'地點',
			cols: "20",
			rows: "3",
			value: value,
			alt: "ch", <%-- [20240729]難字調整 --%>
			onblur:function(){
				formatInput.text(this.id);
			},
			onpropertychange:function(){
				if(this.scrollHeight > 50){this.style.posHeight=this.scrollHeight;}
			}
		};
		var textarea = tableElement.createElement("textarea", config);















		td.appendChild(textarea);
		if(textarea.scrollHeight > 50){
			textarea.style.posHeight=textarea.scrollHeight;
		}

		// 使用狀況
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'USE_STATUS';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'使用狀況',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'10',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);

		td.appendChild(input);

		var textNode = document.createTextNode(" / ");
		td.appendChild(textNode);

		// 月租金
		var dataId = 'RENTAL';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var decLength = 1;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0.0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'月租金',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		// 設定銀行
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'COMP_BANK';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'設定銀行',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'20',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode(" / ");
		td.appendChild(textNode);

		// 貸款餘額
		var dataId = 'SET_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'貸款餘額',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		var br = tableElement.createElement("br");
		td.appendChild(br);

		// 不動產說明
		var dataId = 'GAGE_MSG';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id: id,
			fieldName:'說明',
			cols: "25",
			rows: "2",
			value: value,
			onblur:function(){
				formatInput.text(this.id);
			},
			onpropertychange:function(){
				if(this.scrollHeight > 50){this.style.posHeight=this.scrollHeight;}
			}
		};
		var textarea = tableElement.createElement("textarea", config);

















		td.appendChild(textarea);
		if(textarea.scrollHeight > 50){
			textarea.style.posHeight=textarea.scrollHeight;
		}

		// 市值估算
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		// 總價
		var dataId = 'TOTAL_PRICE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 8;
		var decLength = 1;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0.0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'總價',
			type:'text',
			'class':'textBox2',
			size:'11',
			maxLength:'11',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"1",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				// 連動不動產總值(jsp)
				layout.calculate("1");
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		var br = tableElement.createElement("br");
		td.appendChild(br);

		var textNode = document.createTextNode("(單價");
		td.appendChild(textNode);

		// 單價
		var dataId = 'GAGE_PRICE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 4;
		var decLength = 1;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0.0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'單價',
			type:'text',
			'class':'textBox2',
			size:'7',
			maxLength:'7',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"1",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4C(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬×");
		td.appendChild(textNode);

		// 建坪
		var dataId = 'GAGE_SPACE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 5;
		var decLength = 3;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'建坪',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'12',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"1",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4C(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("坪)");
		td.appendChild(textNode);

		autoFormatToNumber();
	},
	// 新增一筆可輸入的【收入部分】
	create_Block_D:function(datas){
		var TYPE = "D";
		var preKey = TYPE + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、當事人、收入項目、年所得(萬)、說明) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 當事人
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'INCOME_NAME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : $('BORROW_NAME').getValue();
		var config = {
			id:id,
			name:dataId,
			fieldName:'當事人',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'60',
			value:value,
			alt: "ch", <%-- [20240729]難字調整 --%>
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 收入項目
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'INCOME_ITEM';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'收入項目',
			type:'text',
			'class':'textBox2',
			size:'20',
			maxLength:'20',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 年所得
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'INCOME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'年所得',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				// 連動總收入合計(jsp)
				layout.calculate("2");

				// 連動本金與利息支出/總收入(java)
				var parameter = {
					SUM_INCOME:formatInput.getSplitValue($('D_SUM_INCOME').innerHTML, ","),
					SUM_YEAR_AMT:formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",")
				};

				var target = 'H_INCOME_EXP_RATE';

				layout.calculate("5", target, parameter);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 說明
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'INCOME_MSG';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id: id,
			fieldName:'說明',
			cols: "50",
			rows: "3",
			value: value,
			onblur:function(){
				formatInput.text(this.id);
			},
			onpropertychange:function(){
				if(this.scrollHeight > 50){this.style.posHeight=this.scrollHeight;}
			}
		};
		var textarea = tableElement.createElement("textarea", config);

















		td.appendChild(textarea);
		if(textarea.scrollHeight > 50){
			textarea.style.posHeight=textarea.scrollHeight;
		}
		autoFormatToNumber();
	},
	// 新增一筆可輸入的【本金與利息支出估計-1】
	create_Block_E:function(datas){
		var TYPE = "E";
		var preKey = TYPE + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、本公司貸款、金額(仟)、利率(%)、年期(期數)、本金與利息(仟/年)) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 本公司貸款
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BANK_NAME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'本公司貸款',
			type:'text',
			'class':'textBox2',
			size:'50',
			maxLength:'80',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 金額(仟)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LOAN_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'金額(仟)',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				// 連動合計貸款金額(jsp)
				layout.calculate("3");

				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 利率%
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'RATE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 2;
		var decLength = 4;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'利率%',
			type:'text',
			'class':'textBox2',
			size:'7',
			maxLength:'7',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);
				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 年期(期數)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LOAN_PERIOD';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'年期(期數)',
			type:'text',
			'class':'textBox2',
			size:'6',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);
				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 本金與利息(仟/年)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";

		var config = {
			id:id,
			pattern:pattern,
			numberType:"1",
			innerHTML:value
		};
		var span = tableElement.createElement("span", config);
		td.appendChild(span);

		autoFormatToNumber();

	},
	// 新增一筆可輸入的【本金與利息支出估計-2】
	create_Block_F:function(datas){
		var TYPE = "F";
		var preKey = TYPE + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、其他行庫貸款部分、金額(仟)、利率(%)、年期(期數)、本金與利息(仟/年)) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 其他行庫貸款部分
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BANK_NAME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'其他行庫貸款',
			type:'text',
			'class':'textBox2',
			size:'50',
			maxLength:'80',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 金額(仟)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LOAN_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'金額(仟)',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				// 連動合計貸款金額(jsp)
				layout.calculate("3");

				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 利率%
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'RATE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 2;
		var decLength = 4;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'利率%',
			type:'text',
			'class':'textBox2',
			size:'7',
			maxLength:'7',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 年期(期數)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LOAN_PERIOD';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'年期(期數)',
			type:'text',
			'class':'textBox2',
			size:'6',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4F(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 本金與利息(仟/年)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";

		var config = {
			id:id,
			pattern:pattern,
			numberType:"1",
			innerHTML:value
		};
		var span = tableElement.createElement("span", config);
		td.appendChild(span);

		autoFormatToNumber();
	},
	// 新增一筆可輸入的【本金與利息支出估計-3】
	create_Block_G:function(datas){
		var TYPE = "G";
		var preKey = TYPE + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、現金/信用卡使用情形、金額(元)、利率(最低應繳)、應繳金額(元)) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 現金/信用卡使用情形
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'CARD_TYPE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var config = {
			id:id,
			name:dataId,
			fieldName:'現金/信用卡使用情形',
			onchange:function(){
				var key = this.id.split("_");
				var no = key[key.length-1];
				var MONTH_RATE = $(preKey + 'MONTH_RATE' + '_' + no);
				if(this.value == "A"){
					MONTH_RATE.value = "2.0";
				}else if(this.value == "B"){
					MONTH_RATE.value = "5.0";
				}

				layout.calculate4G(preKey, this.id);
			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, CARD_TYPE_List, "", "key", "value");
		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		// 張數
		var textNode = document.createTextNode("(");
		td.appendChild(textNode);

		var dataId = 'CARD_COUNT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'張數',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("張)");
		td.appendChild(textNode);

		// 金額(元)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LOAN_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'金額(元)',
			type:'text',
			'class':'textBox2',
			size:'10',
			datatype:'number',
			pattern:pattern,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4G(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 利率%
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_RATE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var intLength = 2;
		var decLength = 4;
		var zeroDec = 1;
		var pattern = formatInput.getPattern(intLength, decLength, zeroDec);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "20";//預設20
		var config = {
			id:id,
			name:dataId,
			fieldName:'利率%',
			type:'text',
			'class':'textBox2',
			size:'7',
			maxLength:'7',
			datatype:'number',
			pattern:pattern,
			intLength:intLength,
			decLength:decLength,
			zeroDec:zeroDec,
			numberType:"2",
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.calculate4G(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 最低應繳
		var textNode = document.createTextNode("% (");
		td.appendChild(textNode);

		var dataId = 'MONTH_RATE';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = "";
		var CARD_TYPE = $(preKey + 'CARD_TYPE' + '_' + UpdateIndex[TYPE]).value;
		if(CARD_TYPE == "A"){
			value = "2.0";
		} else {
			value = "5.0";
		}
		var config = {
			id:id,
			value:value,
			size : 5,
			datatype:'number',
			type:'text',
			'class':'textBox2'

		};
		var input = tableElement.createElement("input", config);
		input.readOnly = true;
		td.appendChild(input);

		var textNode = document.createTextNode("%)");
		td.appendChild(textNode);

		// 應繳金額(元)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_AMT';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			pattern:pattern,
			numberType:"1",
			innerHTML:value
		};
		var span = tableElement.createElement("span", config);
		td.appendChild(span);

		autoFormatToNumber();
	},
	// 新增一筆可輸入的【授信餘額變動】
	create_Block_I:function(datas){
		var TYPE = "I";
		var preKey = TYPE + "_";
		//---------- 取得tbody ----------
		var tBody = $('tbody_' + TYPE);
		UpdateIndex[TYPE] = (!isNaN(parseInt(MaxIndex[TYPE]))) ? parseInt(MaxIndex[TYPE], 10) + 1 : 1;	// 編號(從1開始)
		MaxIndex[TYPE] = UpdateIndex[TYPE];

		//---------- 產生row(選取、近()個月授信餘額、增減、附註) ----------

		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[TYPE];

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			'class': 'tbBlue3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var config = {
			id:preKey + 'index_' + UpdateIndex[TYPE],
			name:preKey + 'index',
			type:'radio',
			onclick:function(){
				var key = this.id.split("_");
				UpdateIndex[TYPE] = key[key.length-1];
			}
		};
		var radio = tableElement.createElement("input", config);
		td.appendChild(radio);
		radio.checked = true;

		// 借款人或保證人姓名
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'CREDIT_NAME';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];

		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:dataId,
			fieldName:'借款人或保證人姓名',
			type:'text',
			'class':'textBox2',
			size:'10',
			maxLength:'60',
			value:value,
			alt: "ch", <%-- [20240729]難字調整 --%>
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var textNode = document.createTextNode("由");
		td.appendChild(textNode);

		// 變動前授信餘額
		var dataId = 'AMT_A';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'變動前授信餘額',
			type:'text',
			'class':'textBox2',
			size:'8',
			datatype:'number',
			pattern:pattern,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.link4I(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("仟至");
		td.appendChild(textNode);

		// 變動後授信餘額
		var dataId = 'AMT_B';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var pattern = pattern_money;
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "0";
		var config = {
			id:id,
			name:dataId,
			fieldName:'變動後授信餘額',
			type:'text',
			'class':'textBox2',
			size:'8',
			datatype:'number',
			pattern:pattern,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, $(this.id).pattern);

				layout.link4I(preKey, this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("仟");
		td.appendChild(textNode);

		// 增減
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'AMT_MSG';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var config = {
			id:id
		};
		var span = tableElement.createElement("span", config);
		td.appendChild(span);
		layout.link4I(preKey, id);

		// 附註
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'CREDIT_MSG';
		var id = preKey + dataId + '_' + UpdateIndex[TYPE];
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id: id,
			fieldName:'附註',
			cols: "50",
			rows: "3",
			value: value,
			onblur:function(){
				formatInput.text(this.id);
			},
			onpropertychange:function(){
				if(this.scrollHeight > 50){this.style.posHeight=this.scrollHeight;}
			}
		};
		var textarea = tableElement.createElement("textarea", config);

















		td.appendChild(textarea);
		if(textarea.scrollHeight > 50){
			textarea.style.posHeight=textarea.scrollHeight;
		}
		autoFormatToNumber();
	},
	// 刪除指定的資料
	delete_Selected_Detail:function(type){
		var preKey = type + "_";
		var key = 'tbody_' + type;
		var no = UpdateIndex[type];

		$$('#' + key +' tr[id="' + no + '"]').each(
			function(obj){
				for(var lastCell = obj.cells.length-1; lastCell >= 0; lastCell--){
					// 清除td裡面的內容
					obj.cells[lastCell].innerHTML = "";
					obj.removeChild(obj.cells[lastCell]);
				}
				obj.parentElement.removeChild(obj);
			}
		);

		var tbody = $(key);
		var length = tbody.rows.length;
		var no = (length > 0) ? tbody.rows[0].id : 0;

		if(no === 0){
			MaxIndex[type] = 0;
			UpdateIndex[type] = null;
		}else{
			MaxIndex[type] = no;
			UpdateIndex[type] = no;

			var postKey = "_" + no;
			$(preKey + 'index' + postKey).checked = true;
		}

		layout.afterDeleteAction(type);
	},
	// 刪除所有資料(將MaxIndex歸0)
	delete_All_Detail:function(type){
		var target = $('tbody_' + type);
		MaxIndex[type] = 0;
		UpdateIndex[type] = null;
		// 清除tr
		for(var lastRow = target.rows.length-1; lastRow >= 0; lastRow--){
			// 清除td
			for(var lastCell = target.rows[lastRow].cells.length-1; lastCell >= 0; lastCell--){
				// 清除td裡面的內容
				target.rows[lastRow].cells[lastCell].innerHTML = "";
				target.rows[lastRow].removeChild(target.rows[lastRow].cells[lastCell]);
			}
			target.removeChild(target.rows[lastRow]);
		}
	},
	// 刪除之後，要重算
	afterDeleteAction:function(type){
		if(type == "C"){
			layout.calculate("1");
		}else if(type == "D"){
			// 連動總收入合計(jsp)
			layout.calculate("2");

			// 連動本金與利息支出/總收入(java)
			var parameter = {
				SUM_INCOME:formatInput.getSplitValue($('D_SUM_INCOME').innerHTML, ","),
				SUM_YEAR_AMT:formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",")
			};

			var target = 'H_INCOME_EXP_RATE';

			layout.calculate("5", target, parameter);
		}else if(type == "E"){
			layout.calculate("3");
			layout.calculate4Common_1();
		}else if(type == "F"){
			layout.calculate("3");
			layout.calculate4Common_1();
		}else if(type == "G"){
			layout.calculate4Common_1();
		}else{
			layout.calculate("1");

			// 連動總收入合計(jsp)
			layout.calculate("2");

			layout.calculate("3");
			layout.calculate4Common_1();
		}
	},
	// 初始畫面
	initial:function(){
		Is_dataA = null;

		// 明細區塊全部刪除
		$w('C D E F G I').each(
			function(type){
				layout.delete_All_Detail(type);
			}
		);
		// span欄位要請空
		$w('B_APPLY_ID B_BORROW_NAME B_BORROW_ID C_SUM_TOTAL_PRICE D_SUM_INCOME F_SUM_LOAN_AMT G_SUM_YEAR_AMT H_INCOME_EXP_RATE J_INPUT_NAME J_LEADER_NAME J_CHIEF_NAME J_INPUT_DATE J_LEADER_DATE J_CHIEF_DATE').each(
			function(key){
				$(key).innerHTML = "";
			}
		);

		// input欄位要請空 [20240729]+hidden欄位BORROW_NAME
		$w('I_CREDIT_MONTH BORROW_NAME').each(
			function(key){
				$(key).value = "";
			}
		);
	},
	// 載入資料
	loadData:function(resp){
		layout.initial();

		var DSA010 = resp.DSA010;
		var A151_List = resp.A151_List;
		var A152_List = resp.A152_List;
		var A153_ListA = resp.A153_ListA;
		var A153_ListB = resp.A153_ListB;
		var A158_List = resp.A158_List;
		var A154_List = resp.A154_List;
		Is_dataA = resp.Is_dataA;

		//---------- B ----------
		if(DSA010){
			var preKey = "B_";

			// 受理編號、借款人姓名、借款人ID
			$w('APPLY_ID BORROW_NAME BORROW_ID').each(
				function(key){
					var newKey = preKey + key;
					$(newKey).innerHTML = formatInput.text(DSA010[key], false);
				}
			);
			$('BORROW_NAME').setValue(DSA010['BORROW_NAME']);//[20240729]+hidden欄位
		}

		//---------- C、H、J ----------
		if(A151_List && A151_List.length > 0){
			// 所有權人、地點、使用狀況(月租金)、設定銀行╱貸款餘額、市值估算
			var length = A151_List.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_C(A151_List[i]);
			}
			$('C_index_1').checked = true;
			UpdateIndex["C"] = 1;

			// 綜合分析
			preKey = "H_";
			$w('FINAL_MSG').each(
				function(key){
					var newKey = preKey + key;
					$(newKey).value = formatInput.text(A151_List[0][key], false);
				}
			);

			preKey = "J_";
			// 輸入人員、覆核組長、覆核科長
			$w('INPUT_NAME LEADER_NAME CHIEF_NAME').each(
				function(key){
					var newKey = preKey + key;
					$(newKey).innerHTML = formatInput.text(A151_List[0][key], false);
				}
			);

			// 輸入日期、覆核日期、覆核日期
			$w('INPUT_DATE LEADER_DATE CHIEF_DATE').each(
				function(key){
					var newKey = preKey + key;
					$(newKey).innerHTML = formatInput.Y2KDate2ROCDate(A151_List[0][key], false, "/");
				}
			);
		}

		//---------- D ----------
		if(A152_List && A152_List.length > 0){
			// 當事人、收入項目、年所得(萬)、說明
			var length = A152_List.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_D(A152_List[i]);
			}
			$('D_index_1').checked = true;
			UpdateIndex["D"] = 1;
		}

		//---------- E ----------
		if(A153_ListA && A153_ListA.length > 0){
			// 本公司貸款、金額(仟)、利率%、年期(期數)、本金與利息(仟/年)
			var length = A153_ListA.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_E(A153_ListA[i]);
			}
			$('E_index_1').checked = true;
			UpdateIndex["E"] = 1;
		}

		//---------- F ----------
		if(A153_ListB && A153_ListB.length > 0){
			// 其他行庫貸款、金額(仟)、利率%、年期(期數)、本金與利息(仟/年)
			var length = A153_ListB.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_F(A153_ListB[i]);
			}
			$('F_index_1').checked = true;
			UpdateIndex["F"] = 1;
		}

		//---------- G ----------
		if(A158_List && A158_List.length > 0){
			// 現金/信用卡使用情形、金額(元)、利率%(最低應繳)、應繳金額(元)
			var length = A158_List.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_G(A158_List[i]);
			}
			$('G_index_1').checked = true;
			UpdateIndex["G"] = 1;
		}

		//---------- I ----------
		if(A154_List && A154_List.length > 0){
			// 近(CREDIT_MONTH)個月授信餘額
			var preKey = "I_";
			$w('CREDIT_MONTH').each(
				function(key){
					var newKey = preKey + key;
					$(newKey).value = A154_List[0][key];
				}
			);

			// 增減、附註
			var length = A154_List.length;
			for(var i = 0; i < length; i++){
				layout.create_Block_I(A154_List[i]);
			}
			$('I_index_1').checked = true;
			UpdateIndex["I"] = 1;
		}

		if($F('I_CREDIT_MONTH') != ''){ //近(xx)個月授信餘額欄位不為空
			$('div_I').style.display = 'block';
		}else{
			$('div_I').style.display = 'none';
		}

		layout.afterDeleteAction();
		parseEUDC();<%--[20240729] 難字調整，動態產需呼叫 --%>
	},
	// 連動C
	calculate4C:function(preKey, id){
		// 連動總價(java)
		var keys = id.split("_");
		var no = keys[keys.length-1];
		var target = preKey + 'TOTAL_PRICE' + '_' + no;

		var doAfter = function(){
			// 連動不動產總值(jsp)
			layout.calculate("1");
		};

		if(validates.isNumPattern(preKey + 'GAGE_PRICE' + '_' + no) && validates.isNumPattern(preKey + 'GAGE_SPACE' + '_' + no)){
			var GAGE_PRICE = $(preKey + 'GAGE_PRICE' + '_' + no).getValue();
			var GAGE_SPACE = $(preKey + 'GAGE_SPACE' + '_' + no).getValue();

			var parameter = {
				GAGE_PRICE:GAGE_PRICE,
				GAGE_SPACE:GAGE_SPACE
			};

			layout.calculate("6", target, parameter, doAfter);
		}else{
			$(target).value = "";
			doAfter();
		}
	},
	// 連動E
	calculate4E:function(preKey, no){
		// 連動本金與利息(java)
		var LOAN_AMT = $(preKey + 'LOAN_AMT' + '_' + no).getValue();
		var RATE = $(preKey + 'RATE' + '_' + no).getValue();
		var LOAN_PERIOD = $(preKey + 'LOAN_PERIOD' + '_' + no).getValue();

		var target = preKey + 'YEAR_AMT' + '_' + no;
		var doAfter = function(){
			// 連動本金與利息支出合計(jsp)
			layout.calculate("4");

			// 連動本金與利息支出/總收入(java)
			var SUM_INCOME = formatInput.getSplitValue($('D_SUM_INCOME').innerHTML, ",");
			var SUM_YEAR_AMT = formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",");
			SUM_INCOME = (isNaN(parseInt(SUM_INCOME, 10))) ? 0 : SUM_INCOME;
			SUM_YEAR_AMT = (isNaN(parseInt(SUM_YEAR_AMT, 10))) ? 0 : SUM_YEAR_AMT;

			var parameter = {
				SUM_INCOME:SUM_INCOME,
				SUM_YEAR_AMT:SUM_YEAR_AMT
			};

			var target = 'H_INCOME_EXP_RATE';

			layout.calculate("5", target, parameter);
		};

		if(validates.isNumPattern(preKey + 'LOAN_AMT' + '_' + no) && validates.isNumPattern(preKey + 'RATE' + '_' + no) && validates.isNumPattern(preKey + 'LOAN_PERIOD' + '_' + no)){
			LOAN_AMT = (isNaN(parseInt(LOAN_AMT, 10))) ? 0 : LOAN_AMT;
			RATE = (isNaN(parseInt(RATE, 10))) ? 0 : RATE;
			LOAN_PERIOD = (isNaN(parseInt(LOAN_PERIOD, 10))) ? 0 : LOAN_PERIOD;


			if(LOAN_AMT > 0 && RATE > 0 && LOAN_PERIOD > 0){
				var parameter = {
					LOAN_AMT:LOAN_AMT,
					RATE:RATE,
					LOAN_PERIOD:LOAN_PERIOD
				};

				layout.calculate("7", target, parameter, doAfter);
			}
		}else{
			//$(target).value = "";
			//doAfter();
		}
	},
	// 連動F
	calculate4F:function(preKey, id){
		// 連動本金與利息(java)
		var keys = id.split("_");
		var no = keys[keys.length-1];

		var target = preKey + 'YEAR_AMT' + '_' + no;

		var doAfter = function(){
			layout.calculate4Common_1();
		};

		if(validates.isNumPattern(preKey + 'LOAN_AMT' + '_' + no) && validates.isNumPattern(preKey + 'RATE' + '_' + no) && validates.isNumPattern(preKey + 'LOAN_PERIOD' + '_' + no)){
			var LOAN_AMT = $(preKey + 'LOAN_AMT' + '_' + no).getValue();
			var RATE = $(preKey + 'RATE' + '_' + no).getValue();
			var LOAN_PERIOD = $(preKey + 'LOAN_PERIOD' + '_' + no).getValue();
			LOAN_AMT = (isNaN(parseInt(LOAN_AMT, 10))) ? 0 : LOAN_AMT;
			RATE = (isNaN(parseInt(RATE, 10))) ? 0 : RATE;
			LOAN_PERIOD = (isNaN(parseInt(LOAN_PERIOD, 10))) ? 0 : LOAN_PERIOD;

			if(LOAN_AMT > 0 && RATE > 0 && LOAN_PERIOD > 0){
				var parameter = {
					LOAN_AMT:LOAN_AMT,
					RATE:RATE,
					LOAN_PERIOD:LOAN_PERIOD
				};

				layout.calculate("8", target, parameter, doAfter);
			}
		}else{
			//$(target).innerHTML = "";
			//doAfter();
		}
	},
	// 連動G
	calculate4G:function(preKey, id){
		// 連動應繳金額(java)
		var keys = id.split("_");
		var no = keys[keys.length-1];

		var target = preKey + 'YEAR_AMT' + '_' + no;

		var doAfter = function(){
			layout.calculate4Common_1();
		};

		if(validates.isNumPattern(preKey + 'LOAN_AMT' + '_' + no) && validates.isNumPattern(preKey + 'YEAR_RATE' + '_' + no)){
			var CARD_TYPE = $(preKey + 'CARD_TYPE' + '_' + no).getValue();
			var LOAN_AMT = $(preKey + 'LOAN_AMT' + '_' + no).getValue();
			var YEAR_RATE = $(preKey + 'YEAR_RATE' + '_' + no).getValue();
			LOAN_AMT = (isNaN(parseInt(LOAN_AMT, 10))) ? 0 : LOAN_AMT;
			YEAR_RATE = (isNaN(parseInt(YEAR_RATE, 10))) ? 0 : YEAR_RATE;

			if(LOAN_AMT > 0 && YEAR_RATE > 0){
				var parameter = {
					CARD_TYPE:CARD_TYPE,
					LOAN_AMT:LOAN_AMT,
					YEAR_RATE:YEAR_RATE
				};

				layout.calculate("9", target, parameter, doAfter);
			}
		}else{
			//$(target).innerHTML = "";
			//doAfter();
		}
	},
	// 連動(共用1)
	calculate4Common_1:function(){
		// 連動本金與利息支出合計(jsp)
		layout.calculate("4");

		// 連動本金與利息支出/總收入(java)
		var SUM_INCOME = formatInput.getSplitValue($('D_SUM_INCOME').innerHTML, ",");
		var SUM_YEAR_AMT = formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",");
		SUM_INCOME = (isNaN(parseInt(SUM_INCOME, 10))) ? 0 : SUM_INCOME;
		SUM_YEAR_AMT = (isNaN(parseInt(SUM_YEAR_AMT, 10))) ? 0 : SUM_YEAR_AMT;

		var target = 'H_INCOME_EXP_RATE';
		var parameter = {
			SUM_INCOME:SUM_INCOME,
			SUM_YEAR_AMT:SUM_YEAR_AMT
		};

		layout.calculate("5", target, parameter);
	},
	// 合計
	calcuate_SUM:function(TYPE, addId, isInput){
		var preKey = TYPE + "_";
		var tbody = $('tbody_' + TYPE);

		isInput = (isInput === false) ? isInput : true;	// 預設:true

		var total = 0;
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var newKey = preKey + addId + "_" + no;

			var value;
			if(isInput){
				value = $(newKey).getValue();
			}else{
				value = formatInput.getSplitValue($(newKey).innerHTML, ",");
			}

			if(!isNaN(parseInt(value, 10))){
				total = total + Number(value);
			}
		}

		return total;
	},
	// 計算(kind－1:不動產總值, 2:總收入合計, 3:合計貸款金額, 4:本金與利息支出合計, 5:本金與利息支出/總收入, 6:市值估算－總價, 7:本金與利息(E), 8:本金與利息(F), 9:應繳金額(G))
	calculate:function(kind, target, parameter, doAfter){
		if(kind == "1"){
			var result = layout.calcuate_SUM("C", "TOTAL_PRICE");

			var targetId = "C_SUM_TOTAL_PRICE";
			$(targetId).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(targetId).intLength, $(targetId).decLength, $(targetId).zeroDec), null, 0);
		}else if(kind == "2"){
			var result = layout.calcuate_SUM("D", "INCOME");

			var targetId = "D_SUM_INCOME";
			$(targetId).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(targetId).intLength, $(targetId).decLength, $(targetId).zeroDec), null, 0);
		}else if(kind == "3"){
			var result1 = layout.calcuate_SUM("E", "LOAN_AMT");
			var result2 = layout.calcuate_SUM("F", "LOAN_AMT");
			var result = Number(result1) + Number(result2);

			var targetId = "F_SUM_LOAN_AMT";
			$(targetId).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(targetId).intLength, $(targetId).decLength, $(targetId).zeroDec), null, 0);
		}else if(kind == "4"){
			var result1 = layout.calcuate_SUM("E", "YEAR_AMT", false);
			var result2 = layout.calcuate_SUM("F", "YEAR_AMT", false);
			var result3 = layout.calcuate_SUM("G", "YEAR_AMT", false);
			var result = Number(result1) + Number(result2) + Number(result3)/1000;

			var targetId = "G_SUM_YEAR_AMT";
			$(targetId).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(targetId).intLength, $(targetId).decLength, $(targetId).zeroDec), null, 0);
		}else if(kind == "5"){
			var actionName = "calculate";
			var params = {"parameter":Object.toJSON(parameter)};
			var successAction = function(resp){
				var result = resp.INCOME_EXP_RATE;

				if(isNaN(parseInt(result, 10))){
					$(target).innerHTML = result;
				}else{
					$(target).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(target).intLength, $(target).decLength, $(target).zeroDec), null, 0);;
				}

				if(doAfter){
					doAfter();
				}
			};
			ajaxPost(actionName, params, successAction, null, false);
		}else if(kind == "6"){
			var actionName = "calculate4TOTAL_PRICE";
			var params = {"parameter":Object.toJSON(parameter)};
			var successAction = function(resp){
				var result = resp.TOTAL_PRICE;

				$(target).value = formatInput.patternNumber(result, false, formatInput.getPattern($(target).intLength, $(target).decLength, $(target).zeroDec));

				if(doAfter){
					doAfter();
				}
			};
			ajaxPost(actionName, params, successAction, null, false);
		}else if(kind == "7" || kind == "8"){
			var actionName = "calculate4E";
			var params = {"parameter":Object.toJSON(parameter)};
			var successAction = function(resp){
				var result = resp.AMT_Y;

				if(kind == "7"){
					$(target).value = formatInput.patternNumber(result, false, formatInput.getPattern($(target).intLength, $(target).decLength, $(target).zeroDec));
				}else {
					$(target).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(target).intLength, $(target).decLength, $(target).zeroDec), null, 0);
				}

				if(doAfter){
					doAfter();
				}
			};
			ajaxPost(actionName, params, successAction, null, false);
		}else if(kind == "9"){
			var actionName = "calculate4G";
			var params = {"parameter":Object.toJSON(parameter)};
			var successAction = function(resp){
				var result = resp.CAR_YEAR_AMT;
				$(target).innerHTML = formatInput.patternNumber(result, false, formatInput.getPattern($(target).intLength, $(target).decLength, $(target).zeroDec), null, 0);

				if(doAfter){
					doAfter();
				}
			};
			ajaxPost(actionName, params, successAction, null, false);
		}
	},
	// 連動I
	link4I:function(preKey, id){
		var keys = id.split("_");
		var no = keys[keys.length-1];
		var AMT_A = $(preKey + 'AMT_A' + '_' + no).getValue();
		var AMT_B = $(preKey + 'AMT_B' + '_' + no).getValue();

		var value = "";
		if(!isNaN(parseInt(AMT_A, 10)) && !isNaN(parseInt(AMT_B, 10))){
			AMT_A = Number(AMT_A);
			AMT_B = Number(AMT_B);

			if(AMT_A > AMT_B){
				value = "遞減" + formatInput.patternNumber(AMT_A - AMT_B, false, formatInput.getPattern($(preKey + 'AMT_MSG' + '_' + no).intLength, $(preKey + 'AMT_MSG' + '_' + no).decLength, $(preKey + 'AMT_MSG' + '_' + no).zeroDec)) + "仟";
			}else{
				value = "遞增" + formatInput.patternNumber(AMT_B - AMT_A, false, formatInput.getPattern($(preKey + 'AMT_MSG' + '_' + no).intLength, $(preKey + 'AMT_MSG' + '_' + no).decLength, $(preKey + 'AMT_MSG' + '_' + no).zeroDec)) + "仟";
			}
		}

		$(preKey + 'AMT_MSG' + '_' + no).innerHTML = value;
	},

	//授信餘額變動超連結(顯示/隱藏div_I)
	doShowdiv_I:function(){

		if($('div_I').style.display != 'none'){
			$('div_I').style.display = 'none';
		}else{
			$('div_I').style.display = 'block';
		}
	}
};

//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var default_A151 = {
	RENTAL:0,
	SET_AMT:0,
	TOTAL_PRICE:0,
	GAGE_PRICE:0,
	GAGE_SPACE:0
};
var default_A152 = {
	INCOME:0
};
var default_A153 = {
	LOAN_AMT:0,
	RATE:0,
	LOAN_PERIOD:0,
	YEAR_AMT:0
};
var default_A158 = {
	CARD_COUNT:0,
	LOAN_AMT:0,
	YEAR_RATE:0,
	MONTH_RATE:0,
	YEAR_AMT:0
};
var default_A154 = {
	AMT_A:0,
	AMT_B:0
};

var auxiliary = {
	// 取得畫面上的資料(C~I)
	getAllData:function(action){

		auxiliary.trimTextAreaValue();

		var B_APPLY_ID = $('B_APPLY_ID').innerHTML;
		var B_BORROW_ID = $('B_BORROW_ID').innerHTML;

		//----- C(DSA151) -----
		var A151_List = [];
		var preKey = "C_";
		var tbody = $('tbody_C');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A151 = {};

			// 輸入欄位(所有權人, 地點, 使用狀況, 月租金, 設定銀行, 貸款餘額, 說明, 總價, 單價, 建坪)
			auxiliary.getData(preKey, 'BUILD_NAME BUILD_ADDR USE_STATUS RENTAL COMP_BANK SET_AMT GAGE_MSG TOTAL_PRICE GAGE_PRICE GAGE_SPACE', no, A151, default_A151);

			// 特殊處理
			A151['APPLY_ID'] = B_APPLY_ID;	// 受理編號

			A151_List.push(A151);
		}

		//----- D(DSA152) -----
		var A152_List = [];
		var preKey = "D_";
		var tbody = $('tbody_D');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A152 = {};

			// 輸入欄位(當事人, 收入項目, 年所得(萬), 說明)
			auxiliary.getData(preKey, 'INCOME_NAME INCOME_ITEM INCOME INCOME_MSG', no, A152, default_A152);

			// 特殊處理
			A152['APPLY_ID'] = B_APPLY_ID;	// 受理編號
			A152['ID'] = B_BORROW_ID;	// 評估對象ID

			A152_List.push(A152);
		}

		//----- E(DSA153) -----
		var A153_ListA = [];
		var preKey = "E_";
		var tbody = $('tbody_E');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A153 = {};

			// 輸入欄位(本公司貸款, 金額(仟), 利率%, 年期(期數), 本金與利息(仟/年))
			auxiliary.getData(preKey, 'BANK_NAME LOAN_AMT RATE LOAN_PERIOD YEAR_AMT', no, A153, default_A153);

			// 特殊處理
			A153['APPLY_ID'] = B_APPLY_ID;	// 受理編號
			A153['ID'] = B_BORROW_ID;	// 評估對象ID
			A153['BANK_TYPE'] = "A";	// 行庫類別

			A153_ListA.push(A153);
		}

		//----- F(DSA153) -----
		var A153_ListB = [];
		var preKey = "F_";
		var tbody = $('tbody_F');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A153 = {};

			// 輸入欄位(本公司貸款, 金額(仟), 利率%, 年期(期數), 本金與利息(仟/年))
			auxiliary.getData(preKey, 'BANK_NAME LOAN_AMT RATE LOAN_PERIOD YEAR_AMT', no, A153, default_A153);

			// 特殊處理
			A153['APPLY_ID'] = B_APPLY_ID;	// 受理編號
			A153['ID'] = B_BORROW_ID;	// 評估對象ID
			A153['BANK_TYPE'] = "B";	// 行庫類別

			A153_ListB.push(A153);
		}

		//----- G(DSA158) -----
		var A158_List = [];
		var preKey = "G_";
		var tbody = $('tbody_G');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A158 = {};

			// 輸入欄位(現金/信用卡使用情形, 張數, 金額(元), 利率%, 應繳金額(元))
			auxiliary.getData(preKey, 'CARD_TYPE CARD_COUNT LOAN_AMT YEAR_RATE YEAR_AMT', no, A158, default_A158);

			// 特殊處理
			A158['APPLY_ID'] = B_APPLY_ID;	// 受理編號
			A158['ID'] = B_BORROW_ID;	// 評估對象ID
			var MONTH_RATE = $(preKey + "MONTH_RATE_" + no).value;
			A158['MONTH_RATE'] = (MONTH_RATE) ? MONTH_RATE : default_A158['MONTH_RATE'];	// 最低應繳

			A158_List.push(A158);
		}

		//----- I(DSA154) -----
		var CREDIT_MONTH = $('I_CREDIT_MONTH').value;
		var A154_List = [];
		var preKey = "I_";
		var tbody = $('tbody_I');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i++){
			var no = tbody.rows[i].id;
			var A154 = {};

			// 輸入欄位(借款人或保證人姓名(可任意修改), 變動前授信餘額, 變動後授信餘額, 附註)
			auxiliary.getData(preKey, 'CREDIT_NAME AMT_A AMT_B CREDIT_MSG', no, A154, default_A154);

			// 特殊處理
			A154['APPLY_ID'] = B_APPLY_ID;	// 受理編號
			A154['CREDIT_MONTH'] = CREDIT_MONTH;	// 近X個月授信餘額

			A154_List.push(A154);
		}

		//----- 其他 -----
		var rtnMap = {};

		if(action == "add"){
			rtnMap['APPLY_ID'] = $('A_APPLY_ID').value;	// 受理編號
		}else{
			rtnMap['APPLY_ID'] = B_APPLY_ID;	// 受理編號
		}

		rtnMap['QRY_ID'] = B_BORROW_ID;	// 借款人ID
		rtnMap['FINAL_MSG'] = $('H_FINAL_MSG').value;	// 綜合分析
		rtnMap['SUM_YEAR_AMT'] = formatInput.getSplitValue($('G_SUM_YEAR_AMT').innerHTML, ",");	// 本金與利息支出合計

		rtnMap['A151_List'] = A151_List;	// 不動產明細資料
		rtnMap['A152_List'] = A152_List;	// 收入資料
		rtnMap['A153_ListA'] = A153_ListA;	// 本公司貸款資料
		rtnMap['A153_ListB'] = A153_ListB;	// 其他行庫貸款資料
		rtnMap['A158_List'] = A158_List;	// 現金信用卡資料
		rtnMap['A154_List'] = A154_List;	// 授信餘額資料

		return rtnMap;
	},
	// 取得輸入欄位
	getData:function(preKey, keys, no, list, defaultMap){
		$w(keys).each(
			function(key){
				var newKey = preKey + key + "_" + no;

				if($(newKey)){
					var value;
					if($(newKey).tagName.toLocaleLowerCase() == "span"){
						value = formatInput.getSplitValue($(newKey).innerHTML, ",");
					}else{
						value = $(newKey).getValue();
					}

					if(value || !isNaN(parseInt(value, 10))){
						list[key] = value;
					}else if(!Object.isUndefined(defaultMap[key])){
						list[key] = defaultMap[key];
					}else{
						list[key] =  "";
					}
				}
			}
		);
	},
	//將TextArea欄位輸入的資料包含單引號或字尾有空白或換行需trim掉
	trimTextAreaValue:function(){
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
		var textAreas = document.getElementsByTagName('textarea');

		for(var i=0 ;i<textAreas.length;i++){
			//alert(textAreas[i].id);
			if(textAreas[i].value.length>0){
				textAreas[i].value = textAreas[i].value.replace(/'/gi, "").replace(/"/gi, "");
				while(true){
					ln0 = textAreas[i].value.length;
					while(true){
						ln1 = textAreas[i].value.length;
						if(textAreas[i].value.indexOf('\r\n')>=0){
							textAreas[i].value = textAreas[i].value.replace(/\r\n$/g, "");
							if(ln1 == textAreas[i].value.length){
								break;
							}
						}else{
							break;
						}
					}
					while(true){
						ln2 = textAreas[i].value.length;
						if(textAreas[i].value.indexOf(' ')>=0){
							textAreas[i].value = textAreas[i].value.replace(/ $/g, "");
							if(ln2 == textAreas[i].value.length){
								break;
							}
						}else{
							break;
						}
					}
					if(ln0 == textAreas[i].value.length){
						break;
					}
				}
			}

		}
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
	}
};

//--------------------------------------------------------------------------
// 表格元素產生器
//--------------------------------------------------------------------------
var tableElement = {
	// 產生tr
	createTR:function(target, position, config){
		var tr = target.insertRow(position);

		tr = tableElement.addAttributes(tr, config);
		return tr;
	},
	// 產生td
	createTD:function(tr, position, config){
		var td = tr.insertCell(position);

		var config = config;
		if(!config){
			config = {
				'class': "tbBlue",
				align: "center"
			};
		}else if(!config.align){
			config.align = "center";
		}

		td = tableElement.addAttributes(td, config);

		return td;
	},
	// 產生元素
	createElement:function(elementNM, config){
		var element = document.createElement(elementNM);
		if(elementNM == "textarea"){
			config.wrap = config.wrap ? config.wrap : "soft";
			config.cols = config.cols ? config.cols : "40";
			config.rows = config.rows ? config.rows : "4";
			config.disabled = config.disabled ? config.disabled : false;
			<%-- [20180328] 問題單20180327115719 textarea 文字沒有出現  --%>
			config.innerHTML = config.value ? config.value : "";
		}
		element = tableElement.addAttributes(element, config);

		return element;
	},
	// 將屬性設定給指定的元素
	addAttributes:function(element, config){
		if(config){
			var key = Object.keys(config);
			key.each(
				function(key){
					var attribute = config[key];
					if(attribute){
						if(key == 'onblur'){
							$(element).observe('blur',attribute);
						}else if(key == 'onclick'){
							$(element).observe('click',attribute);
						}else if(key == 'onchange'){
							$(element).observe('change',attribute);
						}else if(key == 'onpropertychange'){
							if(element.addEventListener){
								$(element).observe('input',attribute);
							}else{
								$(element).observe('propertychange',attribute);
							}
						}else if(key == 'class'){
							$(element).addClassName(attribute);
						}else if(key == 'innerHTML'){
							$(element).update(attribute);
						}else if(key == 'EUDC'){ <%--[20240729]難字調整--%>
							element.setStyle({"font-family": 'EUDC'});
						}else{
							element.setAttribute(key, attribute);
						}
					}
				}
			);
		}

		return element;
	}
};

//--------------------------------------------------------------------------
// 下拉選單
//--------------------------------------------------------------------------
var selection = {
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, key, value, choiceValue, isCode_CodeNM){
		if(!key){
			key = "CODE";
		}
		if(!value){
			value = "CODE_NM";
		}

		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionList){
				for(var i = 0; i < optionList.length; i++){
					if(isCode_CodeNM){
						selection.create(tagID, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
					}else{
						selection.create(tagID, optionList[i][key], optionList[i][value], choiceValue);
					}
				}
			}
		}
	},
	// 依照傳入資料與id，產生下拉選單(資料為Map)
	createAll4Map:function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionMap){
				var dataKey = Object.keys(optionMap);
				dataKey.each(
					function(key){
						if(isCode_CodeNM){
							selection.create(tagID, key, key + " " + optionMap[key], choiceValue);
						}else{
							selection.create(tagID, key, optionMap[key], choiceValue);
						}
					}
				);
			}
		}
	},
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 0;
	},
	// 設定下拉選單(如果不在選項裡面，則預設為第一筆)
	setOptions:function(key, value){
		if(value || value == "0"){
			$(key).value = formatInput.text(value, false);

			if($(key).selectedIndex < 0){
				$(key).selectedIndex = 0;
			}
		}
	}
};

//--------------------------------------------------------------------------
// 格式化
//--------------------------------------------------------------------------
/** 英數字半形轉全形 */
var asciiTable = "!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
var big5Table = "%uFF01%u201D%uFF03%uFF04%uFF05%uFF06%u2019%uFF08%uFF09%uFF0A%uFF0B%uFF0C%uFF0D%uFF0E%uFF0F%uFF10%uFF11%uFF12%uFF13%uFF14%uFF15%uFF16%uFF17%uFF18%uFF19%uFF1A%uFF1B%uFF1C%uFF1D%uFF1E%uFF1F%uFF20%uFF21%uFF22%uFF23%uFF24%uFF25%uFF26%uFF27%uFF28%uFF29%uFF2A%uFF2B%uFF2C%uFF2D%uFF2E%uFF2F%uFF30%uFF31%uFF32%uFF33%uFF34%uFF35%uFF36%uFF37%uFF38%uFF39%uFF3A%uFF3B%uFF3C%uFF3D%uFF3E%uFF3F%u2018%uFF41%uFF42%uFF43%uFF44%uFF45%uFF46%uFF47%uFF48%uFF49%uFF4A%uFF4B%uFF4C%uFF4D%uFF4E%uFF4F%uFF50%uFF51%uFF52%uFF53%uFF54%uFF55%uFF56%uFF57%uFF58%uFF59%uFF5A%uFF5B%uFF5C%uFF5D%uFF5E";

var formatInput = {
	// 一般輸入
	text:function(key_Value, isKey, defaultVaule, toFullwidth){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(!defaultVaule && defaultVaule != "0"){
			defaultVaule = "";
		}

		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}

		// 處理value
		if(value || !isNaN(parseInt(value))){
			value = value + "";
		}else {
			value = defaultVaule + "";
		}

		// 如果有設定要轉成全形
		if(toFullwidth === true){
			var length = value.length;

			var result = "";
			for ( var i = 0 ; i < length ; i ++ ) {
				var val = value.charAt(i) ;
				var j = asciiTable.indexOf(val) * 6 ;
				result += ( j > -1 ? unescape(big5Table.substring( j , j + 6 ) ) : val );
			}

			value = result;
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 數字輸入
	number:function(key_Value, isKey,  defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(isNaN(parseInt(defaultVaule))){
			defaultVaule = "";
		}

		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}

		// 處理value
		if(isNaN(parseInt(value))){
			value = defaultVaule + "";
		}else {
			value = value + "";
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 動態產生金額pattern
	getPattern:function(intLength, decLength, zeroDec){
		intLength = parseInt(intLength, 10);
		if(isNaN(intLength)){
			intLength = 4;
		}

		decLength = parseInt(decLength, 10);
		if(isNaN(decLength)){
			decLength = 0;
		}

		var hasZeroDec = false;
		if(!isNaN(parseInt(zeroDec, 10))){
			hasZeroDec = true;
		}

		var pattern = "";
		if(intLength > 3){
			pattern = "#,###";
		}else{
			pattern = "###";
		}

		for(var i = 0; i < decLength; i++){
			if(i == 0){
				pattern = pattern + ".";
			}

			if(hasZeroDec && i<Number(zeroDec)){
				pattern = pattern + "0";
			}else{
				pattern = pattern + "#";
			}
		}

		return pattern;
	},
	// 數字(有位數或格式限制)輸入
	patternNumber:function(key_Value, isKey, pattern, mode, defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(isNaN(parseInt(defaultVaule, 10))){
			defaultVaule = "";
		}

		// mode={0:四捨五入, 1:只做格式化(無條件捨去), 2:無條件進位}
		if(pattern){
		}else{
			pattern = pattern_money2;
		}

		if(mode){
		}else{
			mode = "0";
		}

		var value;
		if(isKey){
			value = $(key_Value).getValue().trim();
			pattern = ($(key_Value).pattern) ? $(key_Value).pattern : formatInput.getPattern($(key_Value).intLength, $(key_Value).decLength, $(key_Value).zeroDec);
		}else{
			value = key_Value;
		}

		var scale = pattern.split(".");
		var length = scale.length;
		if(length > 1){
			scale = scale[length-1].length;
		}else{
			scale = 0;
		}

		// 處理value
		if(isNaN(parseInt(value, 10))){
			value = defaultVaule.trim();
		}else {
			var bigNum = new BigNumber(value, scale).toString();
			if(mode == "0"){
				value = CSRUtil.$fmt(bigNum, pattern);
			}else if(mode == "1"){
				if(scale == "0"){
					value = CSRUtil.$fmt(bigNum, pattern, "true");
				}else{
					value = CSRUtil.$fmt(bigNum, pattern);
				}
			}else if(mode=="2"){

			}
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 取得過濾掉splitSymbol的值
	getSplitValue:function(value, splitSymbol){
		var newValue = "";
		if(value){
			value = value + "";
			var values = value.split(splitSymbol);
			var length = values.length;

			for(var i = 0; i < length; i++){
				newValue = newValue + values[i];
			}
		}
		return newValue;
	},
	// 取得金額位數(台幣：整數、非台幣：兩位小數)
	getMoneyPattern:function(CURR){
		if(CURR == "NTD"){
			return pattern_money;
		}else{
			return pattern_money2;
		}
	},
	// 民國年轉西元年
	ROCDate2Y2KDate:function(date, yearLimit, symbol){
		var rocDate;
		var isKey;

		if(date && $(date)){
			rocDate = $(date).value;
			isKey = true;
		}else{
			rocDate = date;
			isKey = false;
		}
		yearLimit = (yearLimit === false) ? false : true;

		if(symbol){
			var result = rocDate.split(symbol);
			var newDate = "";
			for(var i = 0; i < result.length; i++){
				newDate = newDate + result[i];
			}

			rocDate = newDate;
		}

		if(rocDate){
			var dateLength = rocDate.length;

			if(dateLength == 5 && isROCdate("0" + rocDate, yearLimit)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);

				if(isKey){
					$(date).value = value;
				}

				return value;
			}else if(dateLength > 5 && isROCdate(rocDate, yearLimit)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);

				if(isKey){
					$(date).value = value;
				}

				return value;
			}
		}

		if(isKey === true){
			alert("輸入的日期：" + rocDate + "，不符合民國年格式(例：1000101)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年轉民國年
	Y2KDate2ROCDate:function(date, yearLimit, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}

		if(!symbol){
			symbol = "";
		}

		yearLimit = (yearLimit === false) ? false : true;

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";

			if(isADdate(y2kDate, yearLimit)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;

				rocYear = rocYear + "";
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1] + symbol + dates[2];

				if(splitTool.length > 1){
					y2kDate = y2kDate + " " + splitTool[1];
				}

				if(isKey){
					$(date).value = y2kDate;
				}

				return y2kDate;
			}
		}

		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年月轉民國年月
	Y2KMonth2ROCMonth:function(date, yearLimit, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}

		if(!symbol){
			symbol = "";
		}

		yearLimit = (yearLimit === false) ? false : true;

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";

			if(y2kDate.length < 10){
				y2kDate = y2kDate + "-01";
			}
			if(isADdate(y2kDate, yearLimit)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;

				rocYear = rocYear + "";
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1];

				if($(date)){
					$(date).value = y2kDate;
				}

				return y2kDate;
			}
		}

		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	}
};

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction, asynchronous){
	asynchronous = (asynchronous === false) ? asynchronous : true;
   	new Ajax.Request(
		"<%=dispatcher%>/DSA2_0800/" + actionName,
		{ parameters: params,
		  asynchronous: asynchronous,
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

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">


							<form name="form1" id="form1" method="post" action="">
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">

								<tr>
									<td class="tbYellow" width="12%">
										受理編號
									</td>
									<td class="tbYellow2">
										<input id="A_APPLY_ID" name="A_APPLY_ID" fieldName="受理編號" type="text" class="textBox2" size="15" maxlength="11" value="">
										<input id="A_btn_query" name="A_btn_query" type="button" class="button" value="查詢">
									</td>
								</tr>
								<tr>
									<td align="center" colspan="2">
										<input id="A_btn_add" name="A_btn_add" type="button" class="button" value="新增">
										<input id="A_btn_update" name="A_btn_update" type="button" class="button" value="修改">
										<input id="A_btn_delete" name="A_btn_delete" type="button" class="button" value="刪除">
										<input id="A_btn_agree1" name="A_btn_agree1" type="button" class="button" value="組長同意">
										<input id="A_btn_reject1" name="A_btn_reject1" type="button" class="button" value="組長退回">
										<input id="A_btn_print" name="A_btn_print" type="button" class="button" value="列印">
									</td>
								</tr>
							</table>
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2"  id="tableB">
								<%-- 案件資料(B) --%>
								<tr>
									<td class="tbYellow0" align="center" colspan="4">
										<span style="font-weight: bold;">案件資料</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" width="12%">
										受理編號
									</td>
									<td class="tbYellow2" width="38%">
										<span id="B_APPLY_ID"></span>
									</td>
									<td class="tbYellow" width="12%">
										借款人姓名
									</td>
									<td class="tbYellow2" width="38%">
										<span id="B_BORROW_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%>
										<span id="B_BORROW_ID" style="display:none"></span>
										<input type='hidden' id='BORROW_NAME' /> 
									</td>
								</tr>

								<%-- 借款人及保證人不動產明細(C) --%>
								<tr>
									<td class="tbYellow0" align="center" colspan="4">
										<span style="font-weight: bold;">借款人及保證人不動產明細</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_C" style="overflow:auto; display:block;">
										<table id="table_C" name="table_C" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
											<thead>
												<tr>
													<td class="tbBlue" align="center" rowspan="2" width="5%" style="font-weight: bold;">
														選取
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														所有權人
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														地點
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														使用狀況/月租金
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														設定銀行/貸款餘額
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														市值估算
													</td>
												</tr>
											</thead>
											<tbody id="tbody_C"></tbody>
										</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="4">
										<input id="C_btn_add" name="C_btn_add" type="button" class="button" value="新增">
										<input id="C_btn_delete" name="C_btn_delete" type="button" class="button" value="刪除">
									</td>
								</tr>
								<tr>
									<td class="tbBlue2" colspan="4">
										<span style="font-weight: bold; ">不動產總值</span>
										<span id="C_SUM_TOTAL_PRICE" intLength="6" decLength="1" style="font-weight: bold;background-color: Sandybrown;"></span>
										<span style="font-weight: bold;">萬</span>
										<br/>
										<span style="color:red;">＊非擔保品之不動產市值估算，僅為略估值供參考用，非實際鑑估值。</span>
										<br/>
										<span style="color:red;">＊財稅資料係為課稅目的蒐集，僅供金融徵信案件之參考，若有資料內容疑問時，應向資料主管機關洽詢。</span>
									</td>
								</tr>

								<%-- 收入部分(D) --%>
								<tr>
									<td class="tbYellow0" align="center" colspan="4">
										<span style="font-weight: bold;">收入部分</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_D" style="overflow:auto; display:block;">
										<table id="table_D" name="table_D" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
											<thead>
												<tr>
													<td class="tbBlue" align="center" rowspan="2" width="6%" style="font-weight: bold;">
														選取
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														當事人
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														收入項目
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														年所得(萬)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														說明
													</td>
												</tr>
											</thead>
											<tbody id="tbody_D"></tbody>
										</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="4">
										<input id="D_btn_add" name="D_btn_add" type="button" class="button" value="新增">
										<input id="D_btn_delete" name="D_btn_delete" type="button" class="button" value="刪除">
									</td>
								</tr>
								<tr>
									<td class="tbBlue2" colspan="4">
										<span style="font-weight: bold;">總收入合計</span>
										<span id="D_SUM_INCOME" style="font-weight: bold;background-color: Sandybrown;"></span>
										<span style="font-weight: bold;">萬/年</span>
									</td>
								</tr>

								<%-- 本金與利息支出估計(E) --%>
								<tr>
									<td class="tbYellow0" align="center" colspan="4">
										<span style="font-weight: bold;">本金與利息支出估計</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_E" style="overflow:auto; display:block;">
										<table id="table_E" name="table_E" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
											<thead>
												<tr>
													<td class="tbBlue" align="center" rowspan="2" width="6%" style="font-weight: bold;">
														選取
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														本公司貸款
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														金額(仟)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														利率(%)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														年期(期數)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														本金與利息(仟/年)
													</td>
												</tr>
											</thead>
											<tbody id="tbody_E"></tbody>
										</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="4">
										<input id="E_btn_add" name="E_btn_add" type="button" class="button" value="新增">
										<input id="E_btn_delete" name="E_btn_delete" type="button" class="button" value="刪除">
									</td>
								</tr>
								<%-- 本金與利息支出估計(F) --%>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_F" style="overflow:auto; display:block;">
										<table id="table_F" name="table_F" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
											<thead>
												<tr>
													<td class="tbBlue" align="center" rowspan="2" width="6%" style="font-weight: bold;">
														選取
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														其他行庫貸款部分
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														金額(仟)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														利率(%)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														年期(期數)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														本金與利息(仟/年)
													</td>
												</tr>
											</thead>
											<tbody id="tbody_F"></tbody>
										</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="4">
										<input id="F_btn_add" name="F_btn_add" type="button" class="button" value="新增">
										<input id="F_btn_delete" name="F_btn_delete" type="button" class="button" value="刪除">
									</td>
								</tr>
								<tr>
									<td class="tbBlue2" colspan="4">
										<span style="font-weight: bold;">合計貸款金額</span>
										<span id="F_SUM_LOAN_AMT" style="font-weight: bold;background-color: Sandybrown;"></span>
										<span style="font-weight: bold;">仟/年</span>
									</td>
								</tr>
								<%-- 本金與利息支出估計(G) --%>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_G" style="overflow:auto; display:block;">
										<table id="table_G" name="table_G" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
											<thead>
												<tr>
													<td class="tbBlue" align="center" rowspan="2" width="6%" style="font-weight: bold;">
														選取
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														現金/信用卡使用情形
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														金額(元)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														利率(最低應繳)
													</td>
													<td class="tbBlue" align="center" style="font-weight: bold;">
														應繳金額(元)
													</td>
												</tr>
											</thead>
											<tbody id="tbody_G"></tbody>
										</table>
										</div>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="4">
										<input id="G_btn_add" name="G_btn_add" type="button" class="button" value="新增">
										<input id="G_btn_delete" name="G_btn_delete" type="button" class="button" value="刪除">
									</td>
								</tr>
								<tr>
									<td class="tbBlue2" colspan="4">
										<span style="font-weight: bold;">本金與利息支出合計</span>
										<span id="G_SUM_YEAR_AMT" decLength="1" style="font-weight: bold;background-color: Sandybrown;"></span>
										<span style="font-weight: bold;">仟/年</span>
									</td>
								</tr>
								<%-- 本金與利息支出估計(H) --%>
								<tr>
									<td class="tbYellow2" colspan="4">
										<span style="font-weight: bold;">＊本金與利息支出 / 總收入 = </span>
										<span id="H_INCOME_EXP_RATE" style="font-weight: bold;background-color: Sandybrown;"></span>
										<span style="font-weight: bold;">%(依申貸計算)</span>
									</td>
								</tr>
								<tr>
									<td class="tbYellow2" colspan="4">
										<span style="font-weight: bold;">＊綜合分析：</span>
										<br/>
										<textarea id="H_FINAL_MSG" name="H_FINAL_MSG" fieldName="綜合分析" rows="10" cols="100" value=""></textarea>
									</td>
								</tr>

								<%-- 授信餘額變動(I) --%>
								<tr>
									<td class="tbBlue2" colspan="4">
										<a href="#A_divI" onClick="layout.doShowdiv_I()" name="A_divI">＊授信餘額變動</a>
									</td>
								</tr>
								<tr>
									<td class="tbYellow" colspan="4">
										<div id="div_I" style="overflow:auto; display:none;">
										<table name="table_div_I" class="tbBox2" cellspacing="0" style="width:100%; border:0;">
											<tr>
											<td>
												<table id="table_I" name="table_I" class="tbBox2" title="" cellspacing="1" style="width:100%; border:0;">
													<thead>
														<tr>
															<td class="tbBlue" align="center" rowspan="2" width="6%" style="font-weight: bold;">
																選取
															</td>
															<td class="tbBlue" align="center" colspan="2" style="font-weight: bold;">
																近(
																<input id="I_CREDIT_MONTH" name="I_CREDIT_MONTH" fieldName="近X個月授信餘額" type="text" class="textBox2" datatype="number" intLength="2" decLength="0" pattern ="##" size="2" maxlength="2" value="">
																)個月授信餘額
															</td>
															<td class="tbBlue" align="center" style="font-weight: bold;">
																增減
															</td>
															<td class="tbBlue" align="center" style="font-weight: bold;">
																附註
															</td>
														</tr>
													</thead>
													<tbody id="tbody_I"></tbody>
												</table>
											</td>
											</tr>
											<tr>
												<td class="tbYellow2" align="center" colspan="4">
													<input id="I_btn_add" name="I_btn_add" type="button" class="button" value="新增">
													<input id="I_btn_delete" name="I_btn_delete" type="button" class="button" value="刪除">
												</td>
											</tr>
										</table>
										</div>
									</td>
								</tr>
							</table>

							<%-- (J) --%>
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
								<tr>
									<td class="tbYellow" width="11%">
										覆核主管
									</td>
									<td class="tbYellow2" width="23%">
										<span id="J_CHIEF_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%>
									</td>
									<td class="tbYellow" width="10%">
										覆核組長
									</td>
									<td class="tbYellow2" width="23%">
										<span id="J_LEADER_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%>
									</td>
									<td class="tbYellow" width="10%">
										輸入人員
									</td>
									<td class="tbYellow2" width="23%">
										<span id="J_INPUT_NAME" style="font-family:'EUDC'"></span><%--[20240729]難字調整 --%>
									</td>
								</tr>
								<tr>
									<td class="tbYellow">
										覆核日期
									</td>
									<td class="tbYellow2">
										<span id="J_CHIEF_DATE"></span>
									</td>
									<td class="tbYellow">
										覆核日期
									</td>
									<td class="tbYellow2">
										<span id="J_LEADER_DATE"></span>
									</td>
									<td class="tbYellow">
										輸入日期
									</td>
									<td class="tbYellow2">
										<span id="J_INPUT_DATE"></span>
									</td>
								</tr>

							</table>
							</form>
</body>
</html>