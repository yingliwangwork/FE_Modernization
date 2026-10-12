<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011-10-21  1.0     Created     陳正毅

    程式功能概要說明：
    程式功能　一般件簽件作業
    程式名稱　DSA2_1001.java
    作業方式　ONLINE
    概要說明　(1) 試算 ─ 使用者按下試算按鈕後，試算簽件資料並寫至核貸記錄資料檔。
　　　　　　　(2) 簽件 ─ 須先查詢並試算後才能進行簽件，使用者按下簽件按鈕後，將簽件資料呈送主管覆核。
　　　　　　　(3) 取消 ─ 使用者按下取消按鈕後，將簽件資料核示進度修改為NULL。
    按鈕授權　FUNC_ID = DSA21001

	@author 楊宗翰
	@since 2011-11-04
	
[20211216] 修改程式  楊青峰
申請書:配合稽核室查核意見，進行呈核層級系統檢核卡控。
畫面調整:新增【呈核層級事項】不予承作事項、提高授權事項、洗錢防制高風險客戶、一年內重簽件

[20221227] 申請書:新增本金彈性還還款方式

[20240729] 修改件 陳勁谷 難字修改
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<style>
.overDiv {
	overflow:visible;
}
</style>
<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

// 檢核
var validate4define;

// 檢核字數-修正原因說明
var twoBytesRegExp = /[^\x00-\xff]/g;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)
var pattern_number = "#,###";	// 金額格式(無小數)
var pattern_number1 = "#,###.#";	// 金額格式(小數1位)
var pattern_number2 = "#,###.##";	// 金額格式(小數2位)

// 查詢結果
var DataMap = null;
var oldValue = {};
var doUpdate1 = false;
var ReneList={};
var ReneList_size =0;
var MAdjList={};
var AdjList={};
var MAdjList_size=0;
var AdjList_size=0;
var countA;
var countB;
var count;
var count1;
var PREFER_TYPE;
var MM_CODE;

var query_AdjList={};
//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0072:'btn_update1',<%--試算--%>
		B0055:'btn_update2',<%--簽件--%>
		B0009:'btn_delete'<%--取消--%>
	};
	<dz:grantButtons FUNC_ID="DSA21001" ignored="false"/>
}

function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA21001" , "核貸作業" , "一般件簽件作業", 1,'${titleNotDisplay}' == 'Y');

	$('IS_ADJUST').observe('click', function(event){//checkbox 點選 show hide
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
			$('IR_ADJ_REASON1').checked = false;
			$('IR_ADJ_REASON2').checked = false;
			$('IR_ADJ_REASON3').checked = false;
			$('IR_ADJ_REASON4').checked = false;
			$('IR_ADJ_REASON5').checked = false;
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

	displayMessage();

	// 日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();

	// 按鈕權限
	buttonAuth();

	// 檢核物件
	validate4define = new Validation("body", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		],

		['validate-number0', '須介於0~9999999之間(最大7位整數)', function(v) {
			if(!$('IS_EXPENSE').checked){
				return true;
			}
			var EXPENSE_AMT = parseInt(v,10);
			return (EXPENSE_AMT >0 && EXPENSE_AMT <= 9999999);
		}]
	]);

	new UI().init();

}

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

									ajaxPost( "download", obj, function (resp) {
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
						{header:'產製人員', key:'LST_PROC_NAME', attrs: {style:"font-family:'EUDC'"}},
						{header:'產製日期', key:'LST_PROC_DT'}
					]
			});

			//--------- 註冊按鈕 ----------
			// 試算
			$("btn_update1").observe('click',function(event){
				buttons.doUpdate1();
			});

			// 簽件
			$("btn_update2").observe('click',function(event){
				buttons.doUpdate2();
			});

			// 取消
			$("btn_delete").observe('click',function(event){
				buttons.doDelete();
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

			// 超連結
			$w('btn_link2').each(
				function(key){
					$(key).observe('click',function(event){
						var length = key.length;
						var type = key.substring(length-1);
						buttons.doLink(type);
					});
				}
			);

			// 優質客戶加成
			/*
			$w('VIP_ADD').each(
				function(key){
					$(key).observe('click',function(event){
						layout.VIP_ADD_control(key);
						buttons.doCalculate("2");
					});
				}
			);
			*/
			// 投資戶加成
			$w('INVEST_ADD').each(
				function(key){
					$(key).observe('click',function(event){
						layout.INVEST_ADD_control(key);
						buttons.doCalculate("2");
					});
				}
			);

			// 區域加成條件
			$w('AREA_ADD').each(
				function(key){
					$(key).observe('change',function(event){
						layout.AREA_ADD_control(key);
						buttons.doCalculate("2");
					});
				}
			);

			// 是否為保戶－選取不是保戶時，要保人年繳化保費、保單可貸金額、保單已貸金額皆設定為0
			$("IS_INSU_0").observe('click',function(event){
				$('TOTAL_PREMIUM').value = 0;
				$('LOAN_ABLE').value = 0;
				$('LOAN_REMAIN').value = 0;
				$('IS_INSU_3YEAR_0').checked = true;
			});

			// 計算擔累貸金額╱鑑估總值
			$w('AGREE_AMT AGREE_AMT_M').each(
				function(key){
					$(key).observe('blur',function(event){
						buttons.doCalculate("1");
					});
				}
			);
			//計算本金彈性還上下限
			$w('AGREE_AMT').each(
				function(key){
					$(key).observe('blur',function(event){
						buttons.doCalculate("4");
					});
				}
			);

			// 異動異動買賣金額時,需算出貸放成數、放款值、可貸金額
			$w('CRED_TRADE_AMT').each(
				function(key){
					$(key).observe('blur',function(event){
						buttons.doCalculate("1");
						buttons.doCalculate("3");
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

			//20150515 簽件作業中，央行限制─法人購住、央行限制─高價住宅、央行限制─購置特定地區、央行限制─購置第3戶等四個欄位，設控只允許勾選其中一項。
			//若「央行限制─高價住宅」和「央行限制─購置特定地區」選擇 是，則適用保戶123則不勾選且DISABLED。
			<%--20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：增加高價住宅戶數 --%>
			$('IS_MANSION_1').observe('click',function(event){
				if($('IS_MANSION_1').checked){
					$('INSU_NOTE').checked = false;
					$('INSU_NOTE').disabled = true;
					//若「央行限制─高價住宅」 點選=”是”，則「央行限制─購置第3戶」、「央行限制─購置特定地區」自動改為 點選=”否”
					$('IS_THIRD_CODE_0').click();
					$('SPEC_CHECK_990625_0').click();
					$('IS_COPRATION_0').click();
					$('AREA_ADD').value = 1;
					layout.AREA_ADD_control("AREA_ADD");
					$('IS_MANSION_CNT').disabled = false;
					$('IS_MANSION_CNT').setValue('1'); <%--預帶「4戶以上」--%>
				}
				buttons.doCalculate("2");
			});
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項，預帶「非換屋」--%>
			$('SPEC_CHECK_990625_1').observe('click',function(event){
				if($('SPEC_CHECK_990625_1').checked){
					$('INSU_NOTE').checked = false;
					$('INSU_NOTE').disabled = true;
					$('IS_MANSION_0').click();
					$('IS_THIRD_CODE_0').click();
					$('IS_COPRATION_0').click();
					$('IS_CHANGE_HOUSE').disabled = false;
					$('IS_CHANGE_HOUSE').setValue('0'); <%--預帶「非換屋」--%>
				}
			});

			//若「央行限制─法人購住」點選=”是”，則 「央行限制─高價住宅」、「央行限制─購置第3戶」、「央行限制─購置特定地區」 自動改為 點選=”否”
			<%--申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：增加法人購住戶數，當「央行限制─法人購住」選擇「是」時顯示戶數下拉選單，並預帶「第二戶以上」--%>
			$('IS_COPRATION_1').observe('click',function(event){
				if($('IS_COPRATION_1').checked){
					$('IS_MANSION_0').click();
					$('IS_THIRD_CODE_0').click();
					$('SPEC_CHECK_990625_0').click();
					$('INSU_NOTE').checked = false;
					$('INSU_NOTE').disabled = true;
					$('IS_COPRATION_CNT').disabled = false;
					$('IS_COPRATION_CNT').setValue('1'); <%--預帶「第二戶以上」--%>
				}
			});

			//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位	有任一個點選=”是” ，則「適用保戶123」INSU_NOTE改為取消勾選0:不選取
			<%--20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：增加購置第3戶戶數 --%>
			$('IS_THIRD_CODE_1').observe('click',function(event){
				if($('IS_THIRD_CODE_1').checked){
					$('INSU_NOTE').checked = false;
					$('INSU_NOTE').disabled = true;
					$('IS_MANSION_0').click();
					$('IS_COPRATION_0').click();
					$('SPEC_CHECK_990625_0').click();
					$('IS_THIRD_CODE_CNT').disabled = false;
					$('IS_THIRD_CODE_CNT').setValue('1'); <%--預帶「第4戶以上」--%>
				}
			});
			//若「央行限制─法人購住」IS_COPRATION、「央行限制─高價住宅」IS_MANSION、「央行限制─購置第3戶」IS_THIRD_CODE、「央行限制─購置特定地區」SPEC_CHECK_990625 四個欄位均為否，
			//且適用保戶優惠預設勾選，則「適用保戶優惠」INSU_NOTE改為勾選1:選取
			$('IS_MANSION_0').observe('click',function(event){
				if($('IS_MANSION_0').checked){
					if($('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && DataMap.INSU_NOTE == "1" && DataMap.MM_CODE != "1"){
						$('INSU_NOTE').checked = true;
						$('INSU_NOTE').disabled = false;
					}
					$('IS_MANSION_CNT').disabled = true;
					$('IS_MANSION_CNT').setValue(''); //清空
				}
			});
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
			$('SPEC_CHECK_990625_0').observe('click',function(event){
				if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_THIRD_CODE_0').checked && DataMap.INSU_NOTE == "1" && DataMap.MM_CODE != "1"){
					$('INSU_NOTE').checked = true;
					$('INSU_NOTE').disabled = false;
				}
				$('IS_CHANGE_HOUSE').disabled = true;
				$('IS_CHANGE_HOUSE').setValue(''); //清空 
			});
			$('IS_COPRATION_0').observe('click',function(event){
				if($('IS_COPRATION_0').checked){
					if($('IS_MANSION_0').checked && $('SPEC_CHECK_990625_0').checked && $('IS_THIRD_CODE_0').checked && DataMap.INSU_NOTE == "1" && DataMap.MM_CODE != "1"){
						$('INSU_NOTE').checked = true;
						$('INSU_NOTE').disabled = false;
					}
					$('IS_COPRATION_CNT').disabled = true;
					$('IS_COPRATION_CNT').setValue(''); //清空
				}
			});
			$('IS_THIRD_CODE_0').observe('click',function(event){
				if($('IS_THIRD_CODE_0').checked){
					if($('SPEC_CHECK_990625_0').checked && $('IS_COPRATION_0').checked && $('IS_MANSION_0').checked && DataMap.INSU_NOTE == "1" && DataMap.MM_CODE != "1"){
						$('INSU_NOTE').checked = true;
						$('INSU_NOTE').disabled = false;
					}
					$('IS_THIRD_CODE_CNT').disabled = true;
					$('IS_THIRD_CODE_CNT').setValue(''); //清空
				}
			});




			//--------- 註冊事件 ----------
			// 輸入(去空白、轉大寫)
			register.textNoSpace('APPR_APPLY_ID CRED_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID ASSESS_APPLY_ID MM_ID BRANCH_ID', "upper");

			// 輸入(去空白)
			register.textNoSpace('CRED_NOTE');

			// 格式化數字
			register.isPatternNumber('AVG_PRICE FIREINSU_AMT_VALID FIREINSU_YY FIREINSU_MM TOTAL_PREMIUM LOAN_ABLE LOAN_REMAIN AGREE_AMT AGREE_AMT_M SET_AMT FIREINSU_AMT INTEREST INTEREST_M'); //個資

			// 「實際用途」下拉選單
			<c:if test="${not empty RealUse_mapList}">
				var RealUse_mapList = ${RealUse_mapList};

				$w('REAL_USE').each(
					function(key){
						selection.createAll(key, RealUse_mapList, "", "", "");
					}
				);
			</c:if>

			// 「業務A值」下拉選單
			<c:if test="${not empty AValue_mapList}">
				var AValue_mapList = ${AValue_mapList};

				$w('A_VALUE').each(
					function(key){
						selection.createAll(key, AValue_mapList, "", "", "","1.00");
					}
				);
			</c:if>

			// 擔保品使用狀況radio選單
			<c:if test="${not empty GageUse_mapList}">
				var GageUse_mapList = ${GageUse_mapList};

				$w('GAGE_USE_radio').each(
					function(key){
						radio_check.createAll("radio", key, "GAGE_USE", GageUse_mapList, "", "", "0", "");
					}
				);

				// 擔保品使用狀況－選取時計算區域放款率
				$w('GAGE_USE_0 GAGE_USE_1').each(
					function(key){
						if($(key)){
							$(key).observe('click',function(event){
								buttons.doCalculate("3");
							});
						}
					}
				);
			</c:if>

			//申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：增加法人購住戶數
			//「法人購住戶數」下拉選單 IS_COPRATION_CNT_LIST
			<c:if test="${not empty IS_COPRATION_CNT_LIST}">
				var IS_COPRATION_CNT_LIST = ${IS_COPRATION_CNT_LIST};
				$w('IS_COPRATION_CNT').each(
					function(key){
						selection.createAll(key, IS_COPRATION_CNT_LIST, "請選擇", "", "");
					}
				);
			</c:if>
			<%--20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：增加高價住宅戶數、購置第3戶戶數--%>
			<c:if test="${not empty IS_MANSION_CNT_LIST}">
				var IS_MANSION_CNT_LIST = ${IS_MANSION_CNT_LIST};
				$w('IS_MANSION_CNT').each(
					function(key){
						selection.createAll(key, IS_MANSION_CNT_LIST, "請選擇", "", "");
					}
				);
			</c:if>
			<c:if test="${not empty IS_THIRD_CODE_CNT_LIST}">
				var IS_THIRD_CODE_CNT_LIST = ${IS_THIRD_CODE_CNT_LIST};
				$w('IS_THIRD_CODE_CNT').each(
					function(key){
						selection.createAll(key, IS_THIRD_CODE_CNT_LIST, "請選擇", "", "");
					}
				);
			</c:if>
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
			<c:if test="${not empty IS_CHANGE_HOUSE_LIST}">
				var IS_CHANGE_HOUSE_LIST = ${IS_CHANGE_HOUSE_LIST};
				$w('IS_CHANGE_HOUSE').each(
					function(key){
						selection.createAll(key, IS_CHANGE_HOUSE_LIST, "請選擇", "", "");
					}
				);
			</c:if>
			
			<%-- [20211216] 新增提高授權事項(下拉式選單) --%>
			<c:if test="${not empty AGREE_ITEM_02_MAP}">
				var AGREE_ITEM_02_MAP = ${AGREE_ITEM_02_MAP};
				$w('AGREE_ITEM_02_MAP').each(
					function(key){
						selection.createAll(key, AGREE_ITEM_02_MAP, "請選擇", "", "");
					}
				);
			</c:if>
			
			$('BTN_INSERT1').observe('click',buttons.doInsert1);
			$('BTN_DELETE1').observe('click',buttons.doDelete1);
			$('BTN_INSERT2').observe('click',buttons.doInsert2);
			$('BTN_DELETE2').observe('click',buttons.doDelete2);
			// 一般件簽件資料
			<c:if test="${not empty DataMap}">

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
				DataMap = ${DataMap};

				layout.loadData();

				<c:if test="${not empty fileList}">
					grid.load(${fileList});
					$('div_J').style.display = 'block';
				</c:if>


				alert('查詢完成');
			</c:if>

			var newVersion=DataMap.NEW_VERSION;
			if(newVersion=="C"){
				$('ASSESS_APPLY_ID').disabled=true;
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
			}

			//若「央行限制─高價住宅」和「央行限制─購置特定地區」都選擇 否，且PREFER_TYPE不等於56、MM_CODE不等於1，則適用保戶123恢復成可勾選狀態。
			$('IS_MANSION_0').observe('click',function(event){
				if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
					$('INSU_NOTE').disabled = false;
				}
				if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
					$('INSU_NOTE').disabled = true;
				}
				buttons.doCalculate("2");

			});
			$('SPEC_CHECK_990625_0').observe('click',function(event){
				if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
					$('INSU_NOTE').disabled = false;
				}
				if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
					$('INSU_NOTE').disabled = true;
				}
			});
			$('IS_THIRD_CODE_0').observe('click',function(event){
				if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
					$('INSU_NOTE').disabled = false;
				}
				if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
					$('INSU_NOTE').disabled = true;
				}
			});
			$('IS_COPRATION_0').observe('click',function(event){
				if(IS_MANSION_checked && SPEC_CHECK_990625_checked && IS_THIRD_CODE_checked && IS_COPRATION_checked && PREFER_TYPE != '56' && MM_CODE != '1'){
					$('INSU_NOTE').disabled = false;
				}
				if($('IS_MANSION_1').checked || $('SPEC_CHECK_990625_1').checked || $('IS_THIRD_CODE_1').checked || $('IS_COPRATION_1').checked){
					$('INSU_NOTE').disabled = true;
				}
			});

			<%--[20240729] 修改件 陳勁谷 難字修改--%>
			parseEUDC();
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
	},
	doTrimTextArea : function (){
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
};

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
		$('text6_'+count).update(CSRUtil.round(parseFloat($('text3_'+count).value)+parseFloat(AdjList[count]['IR_RT'])+parseFloat(AdjList[count]['BAS_RT']),2));
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
		$('text6_Fin_'+count).update(CSRUtil.round(parseFloat($('text3_Fin_'+count).value)+parseFloat(MAdjList[count]['IR_RT'])+parseFloat(MAdjList[count]['BAS_RT']),2));
		$('INTEREST_M').value=$('text6_Fin_0').innerHTML;
		//$('INTEREST_M').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
	},	
	doChangText1:function(event){//發送AJAX查詢

		var ele_ID = Event.element(event).id;
		var count = ele_ID.split('_')[1];

		ajaxPost( 'changtext', {APPLY_ID : $('APPLY_ID').innerHTML,BEG_TERM:$F('text1_'+count)}
					,function(resp){
						query_AdjList=resp.AdjList;
						$('text4_'+count).update(query_AdjList[0]['BAS_RT']);
						if($('text4_'+count).innerHTML===0||$('text4_'+count).innerHTML=='0'){
							$('text7_'+count).disabled=true;
						}
						$('text5_'+count).update("+"+(CSRUtil.round(parseFloat(query_AdjList[0]['IR_RT']))));
						$('text6_'+count).update("="+(CSRUtil.round(parseFloat(query_AdjList[0]['IR_RT'])+parseFloat(query_AdjList[0]['BAS_RT']))));
					}
				);
	},
	//利率個調
	doInsert1: function(data){

		/*var BEG_TERM_dataValue;
		if(data){
			BEG_TERM_dataValue = data['BEG_TERM'];
		}else{
			BEG_TERM_dataValue='';
		}*/

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
		var oInput_RT_ADJ = new Element('input', {type:'text', id:'text3_'+countA, size:'3', value:'',name:'RT_ADJ'});
		var oSpan_TOT_ADJ = new Element('span', {type:'text', id:'text5_'+countA, size:'3', value:'',name:'TOT_ADJ'});
		var oSpan_TOT_RT = new Element('span', {type:'text', id:'text6_'+countA, size:'3', value:'','datatype':"number",name:'TOT_RT'})

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
		otd.insert("期，加減碼").insert(
			oInput_RT_ADJ.observe('change',function(){
				if(oInput_BEG_TERM.value==''){
					alert("請先輸入期數");
					return;
				}
				var IS_RT = query_AdjList[0]['IR_RT'];
				var totAdjValue = parseFloat(oInput_RT_ADJ.value)+parseFloat(IS_RT);
				oSpan_TOT_ADJ.update("+"+(CSRUtil.round(totAdjValue,6)));
				oSpan_TOT_RT.update("="+(CSRUtil.round(totAdjValue+parseFloat(query_AdjList[0]['BAS_RT']),2)));
			})
		);
		otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+countA, size:'3', value:'',name:'BAS_RT'}));//指標利率
		otd.insert(oSpan_TOT_ADJ);//加減碼利率
		otd.insert(oSpan_TOT_RT);//貸款利率
		otd.insert('<br>');
		otd.insert(new Element('input', {type:'radio', id:'text7_'+countA, name:'IS_FIX_'+count, value:'0'}).addClassName('radioBoxIsFix')).insert("浮動 ")
		otd.insert(new Element('input', {type:'radio', name:'IS_FIX_'+count, value:'1'}).addClassName('radioBoxIsFix')).insert("固定");

		//otd7.insert(new Element('td',{id:'text9'}).update('固定'));
		oTr.insert(otd);
		$('grid_body').insert(oTr);
		if($('text4_'+countA).innerHTML===0||$('text4_'+countA).innerHTML=='0'){
			$('text7_'+countA).disabled=true;
		}
		count=count+1;
		countA=countA+1;

	}
	//利率個調
	,doDelete1 :function(){
		count=count-1;
		var no;
		var check=CSS_Selectors.getElementByAttr($$('#grid_body input:checked'), {'name':'radioGroup'});

		if(check.length == 0){
			alert('至少選取一筆資料刪除');
			return;
		}
		check.each(function(ele){

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
			//var otd1=new Element('td').update("-").insert(new Element('input', {type:'text', id:'text2',  size:'1',value:'',name:'END_TERM'}));
			//var otd2=new Element('td').update("期，比率").insert(new Element('input', {type:'text', id:'text3', size:'1', value:'',name:'RENEGE_RATE'}));

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

			//otd2.insert(new Element('td',{id:'text9'}).update('%'));
			oTr.insert(otd);
			//
			$('grid_body1').insert(oTr);
			count1=count1+1;
			countB=countB+1
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
	// 試算
	doUpdate1:function(){
		register.doTrimTextArea();
		var actionName = "update1";
		if(!validates.checkInput(actionName)){
			return;
		}

		var A148_tempList=[];
		var A147_tempList = [];
		var A147M_tempList = [];  //2016-12-12 新增此判斷參數
		var isRenege = $('IS_RENEGE').checked?1:0;<%--提前清償違約金--%>
		var isAdjust = $('IS_ADJUST').checked?1:0;<%--一般型利率個調--%>
		var isAdjust_Fin = $('IS_ADJUST_M').checked?1:0;<%--理財型利率個調--%>   //2016-12-12 新增此判斷參數

		var queryData = layout.getAllData();
			queryData['IS_ADJUST']=isAdjust;
			queryData['IS_ADJUST_M']=isAdjust_Fin;   //2016-12-12 新增此判斷參數
			queryData['IS_RENEGE']=isRenege;
			
		<%-- [20211216] --%>
		var agreeItem01 = $('AGREE_ITEM_01').checked ? 1 : 0;
		var agreeItem02 = $('AGREE_ITEM_02').checked ? $F('AGREE_ITEM_02_MAP') : 0;
		var agreeItem03 = $('AGREE_ITEM_03').checked ? 1 : 0;
		var transCode = $('TRANS_CODE_2').checked ? 2 : 0;
		queryData['AGREE_ITEM_01'] = agreeItem01;
		queryData['AGREE_ITEM_02'] = agreeItem02;
		queryData['AGREE_ITEM_03'] = agreeItem03;
		queryData['TRANS_CODE_2'] = transCode;

		<%-- 210708011693 買賣件帳管費及業佣設控：案件不為央行受限戶（法人購住、高價住宅、購置特定地區、購置第3戶）做以下卡控：若鑑價報告的「買賣金額」有值但勾選不為買賣件，跳出確認視窗：「請確認並勾選是否為買賣件」--%>
		if(!$('IS_COPRATION_1').checked && !$('IS_MANSION_1').checked && !$('SPEC_CHECK_990625_1').checked && !$('IS_THIRD_CODE_1').checked && $F('APPR_TRADE_AMT') && $F('APPR_TRADE_AMT')!=0 && !$('IS_TRADE_1').checked){
			if(!layout.confirmMsg('請確認並勾選是否為買賣件')){
				return;
			}
		}


		// 是否一般型利率個調
		var hasAdjust = isAdjust=='1'
		// 是否理財型利率個調   2016-12-12新增
		var hasAdjust_Fin = isAdjust_Fin=='1'		
		// 是否提前清償違約金
		var hasRenege = isRenege=='1'

		if(hasAdjust){
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
				alert("請輸入「利率個調資料」!(利率個調資料所有欄位為必輸)")
				return;
			}
			//var check=$$('#grid_body tr[name=IS_FIX]')

			var DTDSA147Rows = $('grid_body').rows;
			var DTDSA147RowCount = $('grid_body').rows.length;
			var showErrMsg = '';
			for(var i=0;i<DTDSA147RowCount;i++){
				var DTDSA147Row = DTDSA147Rows[i];
				var readioBox_isFixs = DTDSA147Row.select('.radioBoxIsFix');
				var checkRadioIsClick=false;
				for(var j=0;j<readioBox_isFixs.length;j++){
					if(readioBox_isFixs[j].checked){
						checkRadioIsClick=true;
						break;
					}
				}
				if(!checkRadioIsClick){
					if(showErrMsg!=''){
						showErrMsg+='\n';
					}
					showErrMsg += '第 '+(i+1)+' 筆利率個調[請選擇浮動或固定]';
				}
			}

			if(showErrMsg!=''){
				alert(showErrMsg);
				return;
			}

			var check2=false;

			if($$('#grid_body input[type=text]')[0]){
			if($$('#grid_body input[type=text]')[0].value!=1){
				alert("利率個調資料期數必須由第1期開始!")
						return;
			}
			if($$('#grid_body input[type=text][name=END_TERM]')[$$('#grid_body input[type=text][name=END_TERM]').length-1].value!=DataMap.LOAN_PERIOD){
				alert("期數必須由最後一期結束!");
				check2=true;
				return;
			}
			}

			if(check2){
				return;
			}


			for(var i=0;i<DTDSA147Rows.length;i++){
				var oTr = $(DTDSA147Rows[i]);
				var map={};

				oTr.select('input[type=text]').each(function(ele){
					map[ele.name]=ele.value;
				});

				var readioBox_isFixs = oTr.select('.radioBoxIsFix');
				for(var j=0;j<readioBox_isFixs.length;j++){
					var readioBox_isFix = readioBox_isFixs[j];
					if(readioBox_isFix.checked){
						map['IS_FIX']=readioBox_isFix.value;
						break;
					}
				}
				oTr.select('span[name=BAS_RT]','span[name=TOT_ADJ]','span[name=TOT_RT]').each(function(ele){
					map[ele.name]=ele.innerHTML;
				});
				map['IS_ADJUST']=1;
				map['APPLY_ID']=$('APPLY_ID').innerHTML;
				map['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
				A147_tempList.push(map);
			}
			//queryData['A147_LIST']=A147_tempList;
		}

		if(hasAdjust_Fin){   //2016-12-12新增加
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
					if(!Number(obj.value) || Number(obj.value) == 0 ){
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
			//for(var i=0;i<DTDSA147Rows.length;i++){
			var DTDSA147MRows = $('grid_body_Fin').rows;
			//var DTDSA147MRowCount = $('grid_body_Fin').rows.length;			
			var oTr = $(DTDSA147MRows[0]);
			var map={};

			oTr.select('input[type=text]').each(function(ele){
				map[ele.name]=ele.value;
			});

				//var readioBox_isFixs = oTr.select('.radioBoxIsFix');
				//for(var j=0;j<readioBox_isFixs.length;j++){
				//	var readioBox_isFix = readioBox_isFixs[j];
				//	if(readioBox_isFix.checked){
			map['IS_FIX']= 0;
				//		break;
				//	}
				//}
			oTr.select('span[name=BAS_RT]','span[name=TOT_ADJ]','span[name=TOT_RT]').each(function(ele){
				map[ele.name]=ele.innerHTML;
			});
			map['IS_ADJUST_M']=1;
			map['APPLY_ID']=$('APPLY_ID').innerHTML;
			map['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
			A147M_tempList.push(map);
			
		}
		
		if(hasRenege){
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
				if($$('#grid_body1 input[type=text]')[0].value!=0){
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
				map2['APPLY_ID']=$('APPLY_ID').innerHTML;
				map2['IS_RENEGE']=1;
				map2['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
				A148_tempList.push(map2);
			}
			//queryData['A148_LIST']=A148_tempList;
		}
		
		<%-- 修正非必要內容，避免XSS --%>
		queryData.AGREE_HISTORY = '';
		
		//2016-12-12 多加 A147M_LIST這個參數  為了 理財型利率
		var params = {queryData:Object.toJSON(queryData),A147_LIST:Object.toJSON(A147_tempList),A147M_LIST:Object.toJSON(A147M_tempList),A148_LIST:Object.toJSON(A148_tempList) };

		var successAction = function(resp){
			/*var checkMoneyLaunderMsg = resp.checkMoneyLaunderMsg; //2017-12-18 申請書-調整簽件作業試算功能
			var CHK_ID = resp.CHK_ID; //洗錢防制檢核紀錄畫面傳入ID
			if (checkMoneyLaunderMsg) {
				alert(checkMoneyLaunderMsg);
				if (CHK_ID) {
					var parms = { 
						'QUERY_ID' : CHK_ID
					}; 		
					buttons.doPopupWin(parms);
				}	
			} else {*/
				var checkAlertMsg = resp.checkAlertMsg;
				var update1AlertMsg = resp.update1AlertMsg;
				var queryAlertMsg = resp.queryAlertMsg;
				var msg = "";
				if(checkAlertMsg){
					checkAlertMsg = checkAlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
					msg += checkAlertMsg + "\n";
				}
	
				if(update1AlertMsg){
					update1AlertMsg = update1AlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
					msg += update1AlertMsg + "\n";
				}
	
				if(queryAlertMsg){
					queryAlertMsg = queryAlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
					msg += queryAlertMsg + "\n";
				}
				//debugger;
				layout.alertMsg(msg);
				layout.loadData(resp);
				doUpdate1 = true;
	
				//parent.buttons.doQuery();
				/*msgWin.setCallback(function(){ 因為這邊在IE11會重查 故註解掉
					parent.createTabs(resp.Tab_List, $('APPLY_ID').innerHTML, resp.linkToDPURL, resp.UserID);
			    });*/  
			//}
		};
		var errorAction = function(resp){
			doUpdate1 = false;
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 簽件
	doUpdate2:function(type, step){

	    if(parent.form1.CONTROL_CODE.value == "ERR"){

	       	alert("本件為特殊控管件,無法進行簽件!!");
	    	return;
	    }

		register.doTrimTextArea();
		var actionName = "update2";
		if(!validates.checkInput(actionName)){
			return;
		}
		
		<%-- 210708011693 買賣件帳管費及業佣設控：案件不為央行受限戶（法人購住、高價住宅、購置特定地區、購置第3戶）做以下卡控：若鑑價報告的「買賣金額」有值但勾選不為買賣件，跳出確認視窗：「請確認並勾選是否為買賣件」--%>
		if(!$('IS_COPRATION_1').checked && !$('IS_MANSION_1').checked && !$('SPEC_CHECK_990625_1').checked && !$('IS_THIRD_CODE_1').checked && $F('APPR_TRADE_AMT') && $F('APPR_TRADE_AMT')!=0 && !$('IS_TRADE_1').checked){
			if(!layout.confirmMsg('請確認並勾選是否為買賣件')){
				return;
			}
		}


		var A147_tempList=[];
		var A148_tempList=[];
		var A147M_tempList=[];    //2016-12-12 新增此參數
		var isRenege = $('IS_RENEGE').checked?1:0;<%--提前清償違約金--%>
		var isAdjust = $('IS_ADJUST').checked?1:0;<%--一般型利率個調--%>
		var isAdjust_Fin = $('IS_ADJUST_M').checked?1:0;<%--理財型利率個調--%>   //2016-12-12 新增此判斷參數

		var step = "1";

		var queryData = layout.getAllData();
		queryData['IS_ADJUST']=isAdjust;
		queryData['IS_ADJUST_M']=isAdjust_Fin;   //2016-12-12 新增此判斷參數
		queryData['IS_RENEGE']=isRenege;
		
		<%-- [20211216] --%>
		var agreeItem01 = $('AGREE_ITEM_01').checked ? 1 : 0;
		var agreeItem02 = $('AGREE_ITEM_02').checked ? $F('AGREE_ITEM_02_MAP') : 0;
		var agreeItem03 = $('AGREE_ITEM_03').checked ? 1 : 0;
		var transCode = $('TRANS_CODE_2').checked ? 2 : 0;
		queryData['AGREE_ITEM_01'] = agreeItem01;
		queryData['AGREE_ITEM_02'] = agreeItem02;
		queryData['AGREE_ITEM_03'] = agreeItem03;
		queryData['TRANS_CODE_2'] = transCode;
		
		// 是否一般型利率個調
		var hasAdjust = isAdjust=='1'
		// 是否理財型利率個調     2016-12-12新增
		var hasAdjust_Fin = isAdjust_Fin=='1'			
		// 是否提前清償違約金
		var hasRenege = isRenege=='1'

	if(hasAdjust){
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
			alert("請輸入「利率個調資料」!(利率個調資料所有欄位為必輸)");
			return;
		}
		var DTDSA147Rows = $('grid_body').rows;
			var DTDSA147RowCount = $('grid_body').rows.length;
			var showErrMsg = '';
			for(var i=0;i<DTDSA147RowCount;i++){
				var DTDSA147Row = DTDSA147Rows[i];
				var readioBox_isFixs = DTDSA147Row.select('.radioBoxIsFix');
				var checkRadioIsClick=false;
				for(var j=0;j<readioBox_isFixs.length;j++){
					if(readioBox_isFixs[j].checked){
						checkRadioIsClick=true;
						break;
					}
				}
				if(!checkRadioIsClick){
					if(showErrMsg!=''){
						showErrMsg+='\n';
					}
					showErrMsg += '第 '+(i+1)+' 筆利率個調[請選擇浮動或固定]';
				}
			}

			if(showErrMsg!=''){
				alert(showErrMsg);
				return;
			}
			var check2=false;

			if($$('#grid_body input[type=text]')[0]){
			if($$('#grid_body input[type=text]')[0].value!=1){
				alert("利率個調資料期數必須由第1期開始!")
				return;
			}
			if($$('#grid_body input[type=text][name=END_TERM]')[$$('#grid_body input[type=text][name=END_TERM]').length-1].value!=DataMap.LOAN_PERIOD){
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

				CSS_Selectors.doActionWhenGetElement(datas[i*3].up('tr').select('input:checked'), {'name':'IS_FIX_'+i},
					function(ele){
						map['IS_FIX']=ele.value;
					}
				);
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
				map['APPLY_ID']=$('APPLY_ID').innerHTML;
				map['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
				A147_tempList.push(map);
			}
			//queryData['A147_LIST']=A147_tempList;
			queryData['IS_ADJUST']=1;
			//queryData['A147_LIST']=A147_tempList;
		}

		if(hasAdjust_Fin){   //2016-12-12新增加
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
			map['APPLY_ID']=$('APPLY_ID').innerHTML;
			map['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
			A147M_tempList.push(map);

		}

		if(hasRenege){
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
				map2['APPLY_ID']=$('APPLY_ID').innerHTML;
				map2['IS_RENEGE']=1;
				map2['AREA_CODE']=$('AREA_CODE_930318').innerHTML;
				A148_tempList.push(map2);
			}
			queryData['IS_RENEGE']=1;
		}

		<%-- 修正非必要內容，避免XSS --%>
		queryData.AGREE_HISTORY = '';

		var params = {queryData:Object.toJSON(queryData),A147_LIST:Object.toJSON(A147_tempList),A147M_LIST:Object.toJSON(A147M_tempList),A148_LIST:Object.toJSON(A148_tempList) };

		var successAction = function(resp){
			var checkAlertMsg = resp.checkAlertMsg;
			var update2AlertMsg = resp.update2AlertMsg;
			var queryAlertMsg = resp.queryAlertMsg;
			var msg = "";
			if(checkAlertMsg){
				checkAlertMsg = checkAlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
				msg = msg + checkAlertMsg + "\n";
			}

			if(update2AlertMsg){
				update2AlertMsg = update2AlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
				msg = msg + update2AlertMsg + "\n";
			}

			if(queryAlertMsg){
				queryAlertMsg = queryAlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
				msg = msg + queryAlertMsg + "\n";
			}
			layout.alertMsg(msg);
			layout.loadData(resp);
		};
		var errorAction = function(resp){};

		var confirmAction = function(resp){
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
				var checkConfirmMsg = resp.checkConfirmMsg;
				if(checkConfirmMsg){
					checkConfirmMsg = checkConfirmMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
					if(layout.confirmMsg(checkConfirmMsg)){
						step = "2";
						params["STEP"] = step;
						ajaxPost(actionName, params, successAction, errorAction);
					}
				}else{
					successAction(resp);
				}
			}
		};
		ajaxPost(actionName, params, confirmAction, errorAction);
	},
	// 取消
	doDelete:function(type){
		var actionName = "delete";
		if(!validates.checkInput(actionName)){
			return;
		}

		var queryData = layout.getAllData();

		<%-- 修正非必要內容，避免XSS --%>
		queryData.AGREE_HISTORY = '';
		
		<%-- [20211216] --%>
		var agreeItem01 = $('AGREE_ITEM_01').checked ? 1 : 0;
		var agreeItem02 = $('AGREE_ITEM_02').checked ? $F('AGREE_ITEM_02_MAP') : 0;
		var agreeItem03 = $('AGREE_ITEM_03').checked ? 1 : 0;
		var transCode = $('TRANS_CODE_2').checked ? 2 : 0;
		queryData['AGREE_ITEM_01'] = agreeItem01;
		queryData['AGREE_ITEM_02'] = agreeItem02;
		queryData['AGREE_ITEM_03'] = agreeItem03;
		queryData['TRANS_CODE_2'] = transCode;
		
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			var queryAlertMsg = resp.queryAlertMsg;
			if(queryAlertMsg){
				queryAlertMsg = queryAlertMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
			}
			layout.alertMsg(queryAlertMsg);
			layout.loadData(resp);
		};
		var errorAction = function(resp){};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 計算
	doCalculate:function(type){
		var successAction;
		var calData = {
				'APPLY_ID':$('APPLY_ID').innerHTML,// 受理編號
				'APPR_APPLY_ID':$F('APPR_APPLY_ID'),// 鑑價報告編號
				'SCRIBE_TYPE':'1',//一般件
				'TYPE':'1'// 案件種類:1=一般件
		};

		// 計算擔累貸金額╱鑑估總值
		if(type == "1"){
			calData["APPR_AMT"] = formatInput.getSplitValue($('APPR_AMT').innerHTML, ",");	// 鑑估總值
			calData["AGREE_AMT"] = $('AGREE_AMT').getValue();	// 一般型擬准金額
			calData["AGREE_AMT_M"] = $('AGREE_AMT_M').getValue();	// 理財型擬准金額
			calData["GAGE_AMT"] = formatInput.getSplitValue($('GAGE_AMT').innerHTML, ",");	// 擔已貸金額
			calData["RENT"] = formatInput.getSplitValue($('RENT').innerHTML, ",");	// 押金
			calData["PRE_SET_AMT"] = DataMap['PRE_SET_AMT'];//前順位設定金額
			calData["SEPARATE_AMT"] = DataMap['SEPARATE_AMT'];//拆件案件擬准金額
			calData["NEW_VERSION"] = DataMap['NEW_VERSION'];//案件版本
			calData["MM_ID"] = "";	// 清償理財型帳號
			calData["CRED_TRADE_AMT"] = $('CRED_TRADE_AMT').getValue();	  //買契價格

			var mm_id=DataMap['MM_ID'];
			if(mm_id==""){
			    calData["GAGE_AMT_M"] = formatInput.getSplitValue($('GAGE_AMT_M').innerHTML, ",");	// 已生效理財型額度
			}else{
			    calData["GAGE_AMT_M"] = "0";	// 已生效理財型額度
			}

			successAction = function(resp){
				// 擔累貸金額╱鑑估總值
				$('GA_RATE').innerHTML = formatInput.patternNumber(resp.ga_rate, false, formatInput.getPattern($('GA_RATE').intLength, $('GA_RATE').decLength, $('GA_RATE').zeroDec));
			}
		}
		else if(type == "2"||type == "3"){
			calData["AREA_CODE_930318"] = $('AREA_CODE_930318').innerHTML;	// 擔保品地區
			calData["CRED_ADD"] = DataMap['CRED_ADD'];	// 債信等級
			calData["GFS_SCORE"] = DataMap['GFS_SCORE'];	// GFS分數
			calData["GAGE_USE"] = ($('GAGE_USE_1').checked) ? '1' : '0';	// 擔保品使用狀況
			calData["IS_MANSION"] = ($('IS_MANSION_1').checked) ? '1' : '0';	//高價住宅購屋貸款
			calData["LOAN_LIMIT_C"] = formatInput.getSplitValue($('LOAN_LIMIT_C').innerHTML, ",");	// 區域放款率(表定放款率)
			calData["CRED_ADD_RATE"] = formatInput.getSplitValue($('CRED_ADD_RATE').innerHTML, ",");	//債信等級調整值
			calData["VIP_ADD"] = $F('VIP_ADD');//優質客戶
			calData["AREA_ADD"] = $F('AREA_ADD');//區域加成條件
			calData["INVEST_ADD"] = ($('INVEST_ADD').checked) ? '1' : '0';	//投資戶
			calData["NEW_VERSION"] = DataMap['NEW_VERSION'];//案件版本
			calData["RENT"] = formatInput.getSplitValue($('RENT').innerHTML, ",");	// 租押金
			calData["APPR_AMT"] = formatInput.getSplitValue($('APPR_AMT').innerHTML, ",");	// 鑑估總值
			calData["CRED_TRADE_AMT"] = $F('CRED_TRADE_AMT');
			
			// 計算放款率(承作成數)
			if(type == "2"){
				successAction = function(resp){
					var limit_Map = resp.limit_Map;
					if(limit_Map){
						// 放款率(承作成數)
						$('LOAN_LIMIT').innerHTML = formatInput.patternNumber(limit_Map.LOAN_LIMIT, false, formatInput.getPattern($('LOAN_LIMIT').intLength, $('LOAN_LIMIT').decLength, $('LOAN_LIMIT').zeroDec));
						// 可貸金額
						$('ABLE_AMT').innerHTML = formatInput.patternNumber(limit_Map.ABLE_AMT, false, formatInput.getPattern($('ABLE_AMT').intLength, $('ABLE_AMT').decLength, $('ABLE_AMT').zeroDec));
					}
				}
			// 計算區域放款率
			}else if(type == "3"){
				successAction = function(resp){
					var limit_Map = resp.limit_Map;
					if(limit_Map){//若債信等級(CRED_ADD)、GFS分數(GFS_SCORE)無值，則不計算
						// 放款率(承作成數)
						$('LOAN_LIMIT').innerHTML = formatInput.patternNumber(limit_Map.LOAN_LIMIT, false, formatInput.getPattern($('LOAN_LIMIT').intLength, $('LOAN_LIMIT').decLength, $('LOAN_LIMIT').zeroDec));
						// 可貸金額
						$('ABLE_AMT').innerHTML = formatInput.patternNumber(limit_Map.ABLE_AMT, false, formatInput.getPattern($('ABLE_AMT').intLength, $('ABLE_AMT').decLength, $('ABLE_AMT').zeroDec));
						// 區域放款率(表定放款率)
						$('LOAN_LIMIT_C').innerHTML = formatInput.patternNumber(limit_Map.LOAN_LIMIT_C, false, formatInput.getPattern($('LOAN_LIMIT_C').intLength, $('LOAN_LIMIT_C').decLength, $('LOAN_LIMIT_C').zeroDec));
						// 放款值
						$('LIMIT_AMT').innerHTML = formatInput.patternNumber(limit_Map.LIMIT_AMT, false, formatInput.getPattern($('LIMIT_AMT').intLength, $('LIMIT_AMT').decLength, $('LIMIT_AMT').zeroDec));
					}
				}
			}
		}else if (type == "4"){//計算本金彈性還上下限
			calData["AGREE_AMT"] = $('AGREE_AMT').getValue();
			successAction = function(resp){
				var DataMap = resp.DataMap;
				$('FLEX_MIN_SP').update(CSRUtil.$fmt(DataMap.FLEX_MIN, "#,###"));
				$('FLEX_MAX_SP').update(CSRUtil.$fmt(DataMap.FLEX_MAX, "#,###"));
				$('FLEX_MIN').setValue(DataMap.FLEX_MIN);
				$('FLEX_MAX').setValue(DataMap.FLEX_MAX);
			}
		}else{
			return;
		}
		var chkResult = validates.checkInput("calculate", type, calData);

		if((type=='1' || type=='2' )&& !chkResult){
			return;
		}

		var params = {"calData":Object.toJSON(calData), "TYPE":type};
		var actionName = "calculate";
		ajaxPost(actionName, params, successAction);
	},
	// 超連結
	doLink:function(type){
		if(!validates.checkInput("link", type)){
			return;
		}

		var url;
		var name;
		// 償債能力分析表
		if(type == "1"){
			url = "<%=dispatcher%>/DSA2_0800/prompt?APPLY_ID=" + $('DEBT_APPLY_ID').value;
			name = "DSA2_0800";
		}
		// 客戶資料照會表
		else if(type == "2"){
			url = "<%=dispatcher%>/DSA2_0700/prompt?APPLY_ID=" + $('TEL_APPLY_ID').value;
			name = "DSA2_0700";
		}
		// 收支比
		else if(type == "3"){
			url = "<%=dispatcher%>/DSA2_0500/prompt?APPLY_ID=" + $('APPLY_ID').innerHTML;
			name = "DSA2_0500";
		}else{
			return;
		}

		var win = window.open(url, name, "location=0, scrollbars=1, status=1, titlebar=1, resizable=1");
		win.moveTo(win.screen.availLeft , win.screen.availTop );
		win.resizeTo(win.screen.availWidth , win.screen.availHeight);
	},

	//導頁至DSA21006,DSA21007
	doLinkToPDF:function(target){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID=" + $('APPLY_ID').innerHTML;
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
				'APPLY_ID' : DataMap.APPLY_ID,
				'BORROW_ID' : DataMap.BORROW_ID,
				'APPLY_DATE' : DataMap.SEND_DATE <%--20200424 申請書200407001711 徵信報告書加強審查作業：調整為送件日前三個月--%>
			}
		});
  	
  	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var length_Limit = {
	APPR_APPLY_ID:11,
	CRED_APPLY_ID:11,
	DEBT_APPLY_ID:11,
	TEL_APPLY_ID:11,
	ASSESS_APPLY_ID:11,
	MM_ID:10,
	CRED_NOTE:2000,
	IR_ADJ_DESC:200
};

// 檢查
function checkIDLength(value, checkLength){
	if(value.length != checkLength){
		return false;
	}

	return true;
}

var validates = {
	// 畫面欄位
	checkInput:function(action, type, calData){
		validate4define.clear();	// 清define
		validate4define.reset();	// 清背景色

		// 試算
		if(action == "update1"){
			var APPLY_ID = $('APPLY_ID').innerHTML;
			if(validates.isBlank(APPLY_ID, false)){
				alert("請先查詢，再進行試算!");
				return false;
			}

			if(parent.form1){
				var qAPPLY_ID = parent.form1.APPLY_ID.value;
				if(qAPPLY_ID != APPLY_ID){
				 	alert('欲異動的受理編號: ' + qAPPLY_ID + ' 與原先查詢的 ' + APPLY_ID + ' 不同，請重新查詢!');
				 	return false;
				}
			}

			// 擔保品使用狀況 是否為買賣件 是否為保戶  餘額轉貸方案 房仲買賣專案件 銀行轉介件
			validates.checkRadio("GAGE_USE IS_TRADE IS_INSU CRED_STATUS8 INSU_PRANK5 INSU_PRANK6", "", "");

			//---------- 字數與位數檢核 ----------
			// 鑑價報告編號, 徵信報告書參照案件編號, 償債能力分析表參照案件編號, 客戶資料照會表參照案件編號, 清償理財型帳號
			var keys = "APPR_APPLY_ID CRED_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID MM_ID";
			$w(keys).each(
				function(key){
					if(validates.isNotBlank(key, true)){
						var value = $(key).value;
						var maxLength = length_Limit[key];

						if(!checkIDLength(value, maxLength)){
							var msg = "字數必須等於" + maxLength;
							validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
						}else if(key == "MM_ID"){
							if(value.substring(value.length-1) != "X"){
								var msg = "最後一碼須為X";
								validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
							}
						}
					}
				}
			);

			// 平均單價, 已保火險金額(有效), 火險年期(年), 火險年期(月), 要保人年繳化保費, 保單可貸金額, 保單已貸金額, 一般型擬准金額, 理財型擬准金額, 設定金額, 買契價格, 火險保額, 一般型調整後利率
			validates.checkInput_M("AVG_PRICE FIREINSU_AMT_VALID FIREINSU_YY FIREINSU_MM TOTAL_PREMIUM LOAN_ABLE LOAN_REMAIN AGREE_AMT AGREE_AMT_M SET_AMT CRED_TRADE_AMT FIREINSU_AMT INTEREST INTEREST_M", "", "", false);

			// 徵信說明,「利率減項原因」減項原因說明
			var keys2 = 'CRED_NOTE IR_ADJ_DESC';
			$w(keys2).each(
				function(key){
					if(validates.isNotBlank(key, true)){
						var newKey = "" + key + "";
						var maxLength = length_Limit[key];

						if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
							var msg = "字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + maxLength;
							validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
						}
					}
				}
			);

			//銀行轉介件
			if($('INSU_PRANK6_1').checked){
				if(validates.isBlank($('BRANCH_BANK').value, false)){
					validate4define.define( "customize_returnFalse" , [{ id :"BRANCH_BANK" , errMsg : "不可為空"}] , { useTitle: false });
				}
				if(!validates.isTextAreaLengthLegal('BRANCH_BANK', 16)){
					var msg = "字數(中文佔2個字)為" + $('BRANCH_BANK').value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + 16;
					validate4define.define( "customize_returnFalse" , [{ id :'BRANCH_BANK' , errMsg : msg}] , { useTitle: false });
				}
				if(!validation.checkID($('BRANCH_ID').value)){
					validate4define.define( "customize_returnFalse" , [{ id :"BRANCH_ID" , errMsg : "轉介人員ID有誤"}] , { useTitle: false });
				}

				if($('INSU_PRANK5_1').checked){
					validate4define.define( "customize_returnFalse" , [{ id :"INSU_PRANK5_1" , errMsg : "房仲買賣專案件與銀行轉介件不得同時選擇「是」!"}] , { useTitle: false });
				}
			}else{
				$('BRANCH_BANK').value='';
				$('BRANCH_ID').value='';
			}

			//區域加成條件選單
			if(validates.isBlank($F('AREA_ADD'), true)){
				validate4define.define( "customize_returnFalse" , [{ id :"AREA_ADD" , errMsg : "區域加成條件選單請選取有效選項!"}] , { useTitle: false });
			}

			<%-- 20201217 申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：若為法人購住，則必須輸入戶數--%>
			if($('IS_COPRATION_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_COPRATION_CNT" , errMsg:"請選擇法人購住戶數!"}] );
			}	
			<%-- 20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為高價住宅或購置第3戶，則必須輸入對應的戶數--%>
			if($('IS_MANSION_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_MANSION_CNT" , errMsg:"請選擇高價住宅戶數!"}] );
			}
			if($('IS_THIRD_CODE_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_THIRD_CODE_CNT" , errMsg:"請選擇購置第3戶戶數!"}] );
			}
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
			if($('SPEC_CHECK_990625_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_CHANGE_HOUSE" , errMsg:"請選擇是否換屋!"}] );
			}
			
			<%-- 210708011693 買賣件帳管費及業佣設控：案件不為央行受限戶（法人購住、高價住宅、購置特定地區、購置第3戶）卡控買賣件帳管費及業佣設控 --%>
			if(!$('IS_COPRATION_1').checked && !$('IS_MANSION_1').checked && !$('SPEC_CHECK_990625_1').checked && !$('IS_THIRD_CODE_1').checked){
				<%-- 若有輸入買契價格但勾選不為買賣件時，點試算跳出ALERT訊息：已填入買契價格，是否為買賣件請勾選「是」 --%>
				if($F('CRED_TRADE_AMT') && $F('CRED_TRADE_AMT')!=0 && !$('IS_TRADE_1').checked){
					validate4define.define( "customize_returnFalse" , [{ id :"IS_TRADE_1" , errMsg : "已填入買契價格，是否為買賣件請勾選「是」"}] , { useTitle: false });
				}
			}
			<%-- [20221227] 若IS_FLEX = "Y"，則[本金彈性還擬准類型(AGREE_FLEX_TYPE)]必選，否則顯示錯誤訊息"請選擇[本金彈性還擬准類型]!"。--%>
			if($F('IS_FLEX') == 'Y'){
				if(!$('AGREE_FLEX_TYPE_0').checked && !$('AGREE_FLEX_TYPE_1').checked && !$('AGREE_FLEX_TYPE_2').checked){
					validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_TYPE_0" , errMsg : "請選擇[本金彈性還擬准類型]!"}] , { useTitle: false });
				}
				if($('AGREE_FLEX_TYPE_2').checked){
					var AGREE_FLEX_AMT = parseInt($F('AGREE_FLEX_AMT'));
					if(AGREE_FLEX_AMT > parseInt($F('FLEX_MAX')) || AGREE_FLEX_AMT < parseInt($F('FLEX_MIN'))){
						validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_AMT" , errMsg : "[自行約定金額]需於上下限金額內!"}] , { useTitle: false });
					}
					if(AGREE_FLEX_AMT % 1000 != 0){ <%-- 除以1000餘數不等於0拋錯 --%>
						validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_AMT" , errMsg : "[自行約定金額]需以仟元為單位!"}] , { useTitle: false });
					}
				}
			}
		}
		// 簽件
		else if(action == "update2"){
			var APPLY_ID = $('APPLY_ID').innerHTML;

			if(validates.isBlank(APPLY_ID, false)){
				alert("請先查詢，再進行簽件!");
				return false;
			}

			if(parent.form1){
				var qAPPLY_ID = parent.form1.APPLY_ID.value;
				if(qAPPLY_ID != APPLY_ID){
				 	alert('欲異動的受理編號: ' + qAPPLY_ID + ' 與原先查詢的 ' + APPLY_ID + ' 不同，請重新查詢!');
				 	return false;
				}
			}

			if(!doUpdate1){
				alert("請先試算，再進行簽件!");
				return false;
			}

			// 若主要建材 MATERIAL = ‘0’ 則錯誤訊息=“主要建材資料錯誤!”
			if(Number(DataMap.MATERIAL) == 0){
				alert("主要建材資料錯誤!");
				return false;
			}

			var REJECT_DATA = DataMap.REJECT_DATA;
			if(REJECT_DATA){
				if(!confirm(REJECT_DATA)){
					return false;
				}
			}

			// 擔保品使用狀況 是否為買賣件 央行限制─購置特定地區 央行限制─高價住宅 央行限制─法人購住 央行限制─購置第3戶  是否為保戶 房仲買賣專案件 銀行轉介件 餘額轉貸方案  貸款全期不更新保戶優惠
			validates.checkRadio("GAGE_USE IS_TRADE SPEC_CHECK_990625 IS_MANSION IS_COPRATION IS_THIRD_CODE IS_INSU INSU_PRANK5 INSU_PRANK6 CRED_STATUS8 IS_FIX_VIPGRADE", "", "");

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
			//---------- 字數與位數檢核 ----------
			// 平均單價, 火險年期(年), 火險年期(月), 要保人年繳化保費, 保單可貸金額, 保單已貸金額, 一般型擬准金額, 理財型擬准金額, 設定金額, 火險保額, 一般型調整後利率
			validates.checkInput_M("AVG_PRICE FIREINSU_YY FIREINSU_MM TOTAL_PREMIUM LOAN_ABLE LOAN_REMAIN AGREE_AMT AGREE_AMT_M SET_AMT FIREINSU_AMT INTEREST INTEREST_M", "", "", false);

			// 已保火險金額(有效)
			validates.checkInput_M("FIREINSU_AMT_VALID", "", "", true);

			// 鑑價報告編號, 徵信報告書參照案件編號, 償債能力分析表參照案件編號, 客戶資料照會表參照案件編號, 清償理財型帳號
			var keys = "APPR_APPLY_ID CRED_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID MM_ID";
			$w(keys).each(
				function(key){
					if(validates.isNotBlank(key, true)){
						var value = $(key).value;
						var maxLength = length_Limit[key];

						if(!checkIDLength(value, maxLength)){
							var msg = "字數必須等於" + maxLength;
							validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
						}else if(key == "MM_ID"){
							if(value.substring(value.length-1) != "X"){
								var msg = "最後一碼須為X";
								validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
							}
						}
					}
				}
			);

			// 徵信說明,「利率減項原因」減項原因說明
			var keys2 = 'CRED_NOTE IR_ADJ_DESC';
			$w(keys2).each(
				function(key){
					if(validates.isNotBlank(key, true)){
						var newKey = "" + key + "";
						var maxLength = length_Limit[key];
						if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
							var msg = "字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + maxLength;
							validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
						}
					}
				}
			);


			//銀行轉介件
			if($('INSU_PRANK6_1').checked){
				if(validates.isBlank($('BRANCH_BANK').value, false)){
					validate4define.define( "customize_returnFalse" , [{ id :"BRANCH_BANK" , errMsg : "不可為空"}] , { useTitle: false });
				}
				if(!validates.isTextAreaLengthLegal('BRANCH_BANK', 16)){
					var msg = "字數(中文佔2個字)為" + $('BRANCH_BANK').value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + 16;
					validate4define.define( "customize_returnFalse" , [{ id :'BRANCH_BANK' , errMsg : msg}] , { useTitle: false });
				}
				if(!validation.checkID($('BRANCH_ID').value)){
					validate4define.define( "customize_returnFalse" , [{ id :"BRANCH_ID" , errMsg : "轉介人員ID有誤"}] , { useTitle: false });
				}

			}else{
				$('BRANCH_BANK').value='';
				$('BRANCH_ID').value='';
			}

			//買賣件如有勾選
			/*
			20130620 配合築巢優利貸案件不需製作買賣件查證事項
			調整為簽件時有勾選買賣件不檢查是否有輸入"買賣件查證事項或 客戶資料照會表參照案件編號"
			統一進到檢核模組再做檢核是否有作買賣件查證事項或 客戶資料照會表參照案件編號
			if($('IS_TRADE_1').checked){
				if(validates.isBlank($F('TEL_APPLY_ID'), true)){
					validate4define.define( "customize_returnFalse" , [{ id :"TEL_APPLY_ID" , errMsg : "請輸入"}] , { useTitle: false });
				}
			}
			*/
			//區域加成條件選單
			if(validates.isBlank($F('AREA_ADD'), true)){
				validate4define.define( "customize_returnFalse" , [{ id :"AREA_ADD" , errMsg : "區域加成條件選單請選取有效選項!"}] , { useTitle: false });
			}
			
			<%-- 20201217 申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：若為法人購住，則必須輸入戶數--%>
			if($('IS_COPRATION_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_COPRATION_CNT" , errMsg:"請選擇法人購住戶數!"}] );
			}		
			<%-- 20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為高價住宅或購置第3戶，則必須輸入對應的戶數--%>
			if($('IS_MANSION_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_MANSION_CNT" , errMsg:"請選擇高價住宅戶數!"}] );
			}
			if($('IS_THIRD_CODE_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_THIRD_CODE_CNT" , errMsg:"請選擇購置第3戶戶數!"}] );
			}
			<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
			if($('SPEC_CHECK_990625_1').checked){
				validate4define.define('validate-selection' , [{ id : "IS_CHANGE_HOUSE" , errMsg:"請選擇是否換屋!"}] );
			}
			<%-- 210708011693 買賣件帳管費及業佣設控：案件不為央行受限戶（法人購住、高價住宅、購置特定地區、購置第3戶）卡控買賣件帳管費及業佣設控 --%>
			if(!$('IS_COPRATION_1').checked && !$('IS_MANSION_1').checked && !$('SPEC_CHECK_990625_1').checked && !$('IS_THIRD_CODE_1').checked){
				<%-- 若有輸入買契價格但勾選不為買賣件時，點試算跳出ALERT訊息：已填入買契價格，是否為買賣件請勾選「是」 --%>
				if($F('CRED_TRADE_AMT') && $F('CRED_TRADE_AMT')!=0 && !$('IS_TRADE_1').checked){
					validate4define.define( "customize_returnFalse" , [{ id :"IS_TRADE_1" , errMsg : "已填入買契價格，是否為買賣件請勾選「是」"}] , { useTitle: false });
				}
			}
			
			<%-- [20221227] 若IS_FLEX = "Y"，則[本金彈性還擬准類型(AGREE_FLEX_TYPE)]必選，否則顯示錯誤訊息"請選擇[本金彈性還擬准類型]!"。--%>
			if($F('IS_FLEX') == 'Y'){
				if(!$('AGREE_FLEX_TYPE_0').checked && !$('AGREE_FLEX_TYPE_1').checked && !$('AGREE_FLEX_TYPE_2').checked){
					validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_TYPE_0" , errMsg : "請選擇[本金彈性還擬准類型]!"}] , { useTitle: false });
				}
				if($('AGREE_FLEX_TYPE_2').checked){
					var AGREE_FLEX_AMT = parseInt($F('AGREE_FLEX_AMT'));
					if(AGREE_FLEX_AMT > parseInt($F('FLEX_MAX')) || AGREE_FLEX_AMT < parseInt($F('FLEX_MIN'))){
						validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_AMT" , errMsg : "[自行約定金額]需於上下限金額內!"}] , { useTitle: false });
					}
					if(AGREE_FLEX_AMT % 1000 != 0){ <%-- 除以1000餘數不等於0拋錯 --%>
						validate4define.define( "customize_returnFalse" , [{ id :"AGREE_FLEX_AMT" , errMsg : "[自行約定金額]需以仟元為單位!"}] , { useTitle: false });
					}
				}
			}
			
		}
		// 取消
		else if(action == "delete"){

			var APPLY_ID = $('APPLY_ID').innerHTML;

			if(validates.isBlank(APPLY_ID, false)){
				alert("請先查詢，再進行取消!");
				return false;
			}

			if(parent.form1){
				var qAPPLY_ID = parent.form1.APPLY_ID.value;
				if(qAPPLY_ID != APPLY_ID){
				 	alert('欲異動的受理編號: ' + qAPPLY_ID + ' 與原先查詢的 ' + APPLY_ID + ' 不同，請重新查詢!');
				 	return false;
				}
			}

			alert("請注意！核貸前補全仍有待補全項目，若已不需補全，請刪除補全內容!");

		}
		// 計算
		else if(action == "calculate"){
			var keyMap = {APPR_AMT:"鑑估總值", GAGE_AMT:"擔已貸金額", 
					GAGE_AMT_M:"已生效理財型額度", RENT:"押金", VIP_ADD_RATE:"優質客戶加成", 
					INVEST_ADD_RATE:"投資戶加成", AREA_ADD_RATE:"區域加成條件", 
					CRED_ADD_RATE:"債信指標調整", GFS_SCORE:"GFS分數", 
					LOAN_LIMIT_C:"區域放款率(表定放款率)"};

			// 計算擔累貸金額╱鑑估總值
			if(type == "1"){
				if(validates.checkInput_M("AGREE_AMT AGREE_AMT_M", "", "", true)){
					// 鑑估總值, 擔已貸金額, 已生效理財型額度, 押金
					var msg = "";

					$w('APPR_AMT GAGE_AMT GAGE_AMT_M RENT').each(
						function(key){
							if(isNaN(parseInt(calData[key], 10))){
								msg = msg + keyMap[key] + ", ";
							}
						}
					);

					if(msg){
						msg = msg.substring(msg.length-2) + "不存在，無法計算";
						alert(msg);
						return false;
					}
				}
			}
			// 計算放款率(承作成數)
			else if(type == "2" || type == "3"){
				var chkResult = true;
				//參數檢核:債信等級(CRED_ADD)、GFS分數(GFS_SCORE)無值，則不計算
				$w('CRED_ADD GFS_SCORE').each(
					function(key){
						if(isNaN(parseInt(calData[key], 10))){
							chkResult = false;
						}
					}
				);

				return chkResult;
			}

		}
		// 超連結
		else if(action == "link"){
			// 償債能力分析表
			if(type == "1"){
				validates.checkInput_C("DEBT_APPLY_ID", "", "", true);
			}
			// 客戶資料照會表
			else if(type == "2"){
				validates.checkInput_C("TEL_APPLY_ID", "", "", true);
			}
			// 收支比
			else if(type == "2"){
				if(validates.isBlank("APPLY_ID", false)){
					alert("請先輸入受理編號查詢一筆資料，再執行此作業");
					return false;
				}
			}
		}

		return validate4define.validate();
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
	checkInput_C:function(keys, preKey, postKey, checkEmpty, checkfull, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(checkfull === true && validation.hasHalfType($(newKey).value)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "必須為全形字"}] , { useTitle: useTitle });
					result = false;
				}
			}
		);

		return result;
	},
	// 輸入欄位的檢核(數字)
	checkInput_N:function(keys, preKey, postKey, checkEmpty, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(!validates.isNumber(newKey)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "只能輸入數字"}] , { useTitle: useTitle });
					result = false;
				}
			}
		);

		return true;
	},
	// 輸入欄位的檢核(金額)
	checkInput_M:function(keys, preKey, postKey, checkEmpty, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				if(validates.isBlank(newKey, true)){
					if(checkEmpty === true){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(!validates.isNumber(newKey)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "只能輸入數字"}] , { useTitle: useTitle });
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
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: useTitle });
						result = false;
					}
				}
			}
		);

		return result;
	},
	// RadioButton的檢核
	checkRadio:function(keys, preKey, postKey, useTitle){
		var result = true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				var firstRadio;
				var checked = false;
				CSS_Selectors.doActionWhenGetElement($$('#body input'), {'name':newKey},
					function(radio){
						if(!firstRadio){
							firstRadio = radio;
						}

						if(!checked){
							if(radio.checked){
								checked = true;
							}
						}
					}
				);

				if(!checked && firstRadio){
					validate4define.define( "customize_returnFalse" , [{ id :firstRadio.id , errMsg : "必須選擇一項"}] , { useTitle: useTitle });
					result = false;
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
				}else if(INT.length > intLength){
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
				if(Number(value) < 0 && INT.length > intLength+1){
					return false;
				}else if(Number(value) >= 0 && INT.length > intLength+1){
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
	// alert訊息
	alertMsg:function(msg){
		if(msg){
			alert(msg);
		}
	},
	// confirm訊息
	confirmMsg:function(msg){
		if(msg){
			return confirm(msg);
		}

		return true;
	},
	// 初始畫面
	initial:function(){
		$$('#body input[type="text"]').each(
			function(text){
				text.value = '';
			}
		);

		$$('#body span').each(
			function(span){
				if(span.id && span.id !="GAGE_USE_radio"){
					span.innerHTML = '';
				}
			}
		);

		$$('#body input[type="checkbox"]').each(
			function(checkbox){
				checkbox.checked = false;
			}
		);

		$$('#body input[type="radio"]').each(
			function(radio){
				if(radio.value == 0){
					radio.checked = true;
				}
			}
		);

		$$('#body select').each(
			function(select){
				select.selectedIndex = 0;
			}
		);
	},
	// 優質客戶加成
	VIP_ADD_control:function(key){
		//if($(key).checked){
		if($(key).value == '1'){
			$('VIP_ADD_RATE').innerHTML = "+5";
		}else{
			$('VIP_ADD_RATE').innerHTML = "0";
		}
	},
	// 投資戶加成
	INVEST_ADD_control:function(key){
		if($(key).checked){
			$('INVEST_ADD_RATE').innerHTML = "-5";
			if($('AREA_ADD').value == 5){
			    $('AREA_ADD').value = 1;
				layout.AREA_ADD_control("AREA_ADD");
			}

		}else{
			$('INVEST_ADD_RATE').innerHTML = "0";
		}
	},
	// 區域加成條件
	AREA_ADD_control_load:function(key){
		var value = $(key).value;

		if(value != "" && value != "1"){
			$('AREA_ADD_RATE').innerHTML = "+5";

		}else{
			$('AREA_ADD_RATE').innerHTML = "0";
		}
	},
	// 區域加成條件
	AREA_ADD_control:function(key){
		var value = $(key).value;

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
	},
	// 載入資料
	loadData:function(resp){

		if(resp){
			DataMap = resp.DataMap;
		}
		DataMap.TYPE = "1";
		var update=DataMap.update; //N:prompt，Y:試算、簽件、刪除
		

		//=====利率個調資料=======================================================
		$('IS_ADJUST').value=DataMap.IS_ADJUST;
		$('IS_ADJUST_M').value=DataMap.IS_ADJUST_M;  //2016-12-12新增
		count=AdjList_size;
		countA=AdjList_size;
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
		if($('IS_ADJUST').value=='1'&&update=='N'){//LOAD 資料 147有資料
			$('table_A_tr1').show();
			$('table_A_tr2').show();
				for(var i=0;i<AdjList_size;i++){
					var adjData = AdjList[i];
	
					var radioBox_isFix = new Element('input', {type:'radio',id:'text7_'+i,name:'IS_FIX_'+i, value:'0'}).addClassName('radioBoxIsFix');
					var radioBox_NotFix = new Element('input', {type:'radio',name:'IS_FIX_'+i, value:'1'}).addClassName('radioBoxIsFix');
	
					var oTr = new Element('tr', { id:'tr_'+i,'id2':'tr_'+i});
						oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
						var oInput_BEG_TERM = new Element('input', {type:'text', id:'text1_'+i, size:'2',maxlength:"3",name:'BEG_TERM',value:(AdjList[i]['BEG_TERM']||AdjList[i]['BEG_TERM']===0)?AdjList[i]['BEG_TERM']:''});
	
						var otd = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(oInput_BEG_TERM);
	
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
						oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(DataMap.LOAN_PERIOD||DataMap.LOAN_PERIOD===0)?DataMap.LOAN_PERIOD:''});
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
						otd.insert("期，加減碼").insert(new Element('input', {type:'text', id:'text3_'+i, size:'3',name:'RT_ADJ',value:(AdjList[i]['RT_ADJ']||AdjList[i]['RT_ADJ']===0)?AdjList[i]['RT_ADJ']:''}))
						otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+i, size:'3', name:'BAS_RT'}).update((AdjList[i]['BAS_RT']||AdjList[i]['BAS_RT']===0)?AdjList[i]['BAS_RT']:''))
						otd.insert("+").insert(new Element('span', {type:'text', id:'text5_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ'])||CSRUtil.round(AdjList[i]['IR_RT'])));//加減碼利率
						otd.insert("=").insert(new Element('span', {type:'text', id:'text6_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ']),6)||CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']),6)));//貸款利率
						otd.insert('<br>');
						otd.insert(radioBox_isFix).insert("浮動 ");
						otd.insert(radioBox_NotFix).insert("固定");
					if(adjData['IS_FIX']==0){
						radioBox_isFix.checked=true;
					}else if(adjData['IS_FIX']==1){
						radioBox_NotFix.checked=true;
					}
	
				oTr.insert(otd);
				$('grid_body').insert(oTr);
				
				//var otd_Fin = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("加減碼").insert(new Element('input', {type:'text', id:'text3_Fin_'+i, size:'3',name:'RT_ADJ',value:(MAdjList[i]['RT_ADJ']||MAdjList[i]['RT_ADJ']===0)?MAdjList[i]['RT_ADJ']:''}))
				//otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text4_Fin_'+i, size:'3', name:'BAS_RT'}).update((MAdjList[i]['BAS_RT']||MAdjList[i]['BAS_RT']===0)?MAdjList[i]['BAS_RT']:''))
				//otd_Fin.insert("+").insert(new Element('span', {type:'text', id:'text5_Fin_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ'])||CSRUtil.round(MAdjList[i]['IR_RT'])));//加減碼利率
				//otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text6_Fin_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ']),6)||CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']),6)));//貸款利率
				//var oTr_Fin = new Element('tr', { id:'tr_Fin_'+i,'id2':'tr_Fin_'+i});
				//oTr_Fin.insert(otd_Fin);
				//$('grid_body_Fin').insert(oTr_Fin);    //2016-12-12新增加		
				
				if($('text4_'+i).innerHTML===0||$('text4_'+i).innerHTML=='0'){
					$('text7_'+i).disabled=true;
				}
				$("text3_"+i).observe('change',function(event){buttons.doChangText(event);})
				//$("text3_Fin_"+i).observe('change',function(event){buttons.doChangTextFin(event);})  //2016-12-12新增加
			}
	
		}else if(update=='N'){
			$('IS_ADJUST').value='';
	
			for(var i=0;i<AdjList_size;i++){
	
				var radioBox_isFix = new Element('input', {type:'radio',id:'text7_'+i,name:'IS_FIX_'+i, value:'0'}).addClassName('radioBoxIsFix');
				var radioBox_NotFix = new Element('input', {type:'radio',name:'IS_FIX_'+i, value:'1'}).addClassName('radioBoxIsFix');
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
					oInput_END_TERM=new Element('input', {type:'text', id:'text2_'+i,  size:'3',maxlength:"3",name:'END_TERM',value:(DataMap.LOAN_PERIOD||DataMap.LOAN_PERIOD===0)?DataMap.LOAN_PERIOD:''});
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
	
				otd.insert("期，加減碼").insert(new Element('input', {type:'text', id:'text3_'+i, size:'3', name:'RT_ADJ',value:(AdjList[i]['RT_ADJ']||AdjList[i]['RT_ADJ']===0)?AdjList[i]['RT_ADJ']:''}))
	
				otd.insert("=").insert(new Element('span', {type:'text', id:'text4_'+i, size:'3', name:'BAS_RT'}).update((AdjList[i]['BAS_RT']||AdjList[i]['BAS_RT']===0)?AdjList[i]['BAS_RT']:''))
				otd.insert("+").insert(new Element('span', {type:'text', id:'text5_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ'])||CSRUtil.round(AdjList[i]['IR_RT'])));//加減碼利率
				otd.insert("=").insert(new Element('span', {type:'text', id:'text6_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']+AdjList[i]['RT_ADJ']),6)||CSRUtil.round((AdjList[i]['BAS_RT']+AdjList[i]['IR_RT']),6)));//貸款利率
				otd.insert('<br>');//.insert(new Element('input', {type:'radio', id:'text7_'+i,name:'IS_FIX_'+i, value:'0'}));
				otd.insert(radioBox_isFix).insert("浮動 ");
				otd.insert(radioBox_NotFix).insert("固定");
				//otd.insert("浮動 ").insert(new Element('input', {type:'radio', id:'text8_'+i,name:'IS_FIX_'+i, value:'1'}));
				//otd.insert("固定");
				if(AdjList[i]['IS_FIX']==0){
					radioBox_isFix.checked=true;
				}else if(AdjList[i]['IS_FIX']==1){
					radioBox_NotFix.checked=true;
				}
				oTr.insert(otd);
				$('grid_body').insert(oTr);
				
				
				if($('text4_'+i).innerHTML===0||$('text4_'+i).innerHTML=='0'){
					$('text7_'+i).disabled=true;
				}
				$("text3_"+i).observe('change',function(event){buttons.doChangText(event);})
				
			}
	
			$$('#grid_body tr').each(
					function(obj){
						obj.hide();
					}
				);
		}
		//理財型利率個調
		if($('IS_ADJUST_M').value=='1'&&update=='N'){//LOAD 資料 147有資料
			for(var i=0;i<MAdjList_size;i++){
							
				var otd_Fin = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("加減碼").insert(new Element('input', {type:'text', id:'text3_Fin_'+i, size:'3',name:'RT_ADJ',value:(MAdjList[i]['RT_ADJ']||MAdjList[i]['RT_ADJ']===0)?MAdjList[i]['RT_ADJ']:''}))
				otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text4_Fin_'+i, size:'3', name:'BAS_RT'}).update((MAdjList[i]['BAS_RT']||MAdjList[i]['BAS_RT']===0)?MAdjList[i]['BAS_RT']:''))
				otd_Fin.insert("+").insert(new Element('span', {type:'text', id:'text5_Fin_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ'])||CSRUtil.round(MAdjList[i]['IR_RT'])));//加減碼利率
				otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text6_Fin_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ']),6)||CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']),6)));//貸款利率
				var oTr_Fin = new Element('tr', { id:'tr_Fin_'+i,'id2':'tr_Fin_'+i});
				oTr_Fin.insert(otd_Fin);
				$('grid_body_Fin').insert(oTr_Fin);    //2016-12-12新增加		
				$("text3_Fin_"+i).observe('change',function(event){buttons.doChangTextFin(event);})  //2016-12-12新增加
			}
		}else if(update=='N'){
			$('IS_ADJUST_M').value='';
			for(var i=0;i<MAdjList_size;i++){
			
				//2016-12-12新增加
				var otd_Fin = new Element('td',{'class':"tbYellow2",colspan:"15"}).update("加減碼").insert(new Element('input', {type:'text', id:'text3_Fin_'+i, size:'3', name:'RT_ADJ',value:(MAdjList[i]['RT_ADJ']||MAdjList[i]['RT_ADJ']===0)?MAdjList[i]['RT_ADJ']:''}))
				otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text4_Fin_'+i, size:'3', name:'BAS_RT'}).update((MAdjList[i]['BAS_RT']||MAdjList[i]['BAS_RT']===0)?MAdjList[i]['BAS_RT']:''))
				otd_Fin.insert("+").insert(new Element('span', {type:'text', id:'text5_Fin_'+i, size:'3', name:'TOT_ADJ'}).update(CSRUtil.round(MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ'])||CSRUtil.round(MAdjList[i]['IR_RT'])));//加減碼利率
				otd_Fin.insert("=").insert(new Element('span', {type:'text', id:'text6_Fin_'+i, size:'3', name:'TOT_RT'}).update(CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']+MAdjList[i]['RT_ADJ']),6)||CSRUtil.round((MAdjList[i]['BAS_RT']+MAdjList[i]['IR_RT']),6)));//貸款利率
				var oTr_Fin = new Element('tr', { id:'tr_Fin_'+i,'id2':'tr_Fin_'+i});
				oTr_Fin.insert(otd_Fin);
				$('grid_body_Fin').insert(oTr_Fin);    //2016-12-12新增加			
				$("text3_Fin_"+i).observe('change',function(event){buttons.doChangTextFin(event);}) //2016-12-12新增加
			
			}
			$$('#grid_body_Fin tr').each(
					function(obj){
						obj.hide();
					}
			);
		}



		//=====提前清償違約金資料=======================================================
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
		$('IS_RENEGE').value=DataMap.IS_RENEGE;
		//$('table_B_tr1').hide();
		//$('table_B_tr2').hide();
		if($('IS_RENEGE').value=='1'&&update=='N'){//LOAD 資料
			$('table_B_tr1').show();
			$('table_B_tr2').show();
			for(var i=0;i<ReneList_size;i++){
				var oTr = new Element('tr',{id:'trB_'+i,'idB':'trB_'+i});
				oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
				var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(new Element('input', {type:'text', id:'text1_1_'+i, size:'2',maxlength:"3",name:'BEG_TERM',value:(ReneList[i]['BEG_TERM']||ReneList[i]['BEG_TERM']===0)?ReneList[i]['BEG_TERM']:''}));
				otd.insert('-').insert(new Element('input', {type:'text', id:'text2',  size:'3',maxlength:"3",name:'END_TERM',value:(ReneList[i]['END_TERM']||ReneList[i]['END_TERM']===0)?ReneList[i]['END_TERM']:''}))
				otd.insert('期，比率').insert(new Element('input', {type:'text', id:'text3', size:'4', name:'RENEGE_RATE',value:(ReneList[i]['RENEGE_RATE']||ReneList[i]['RENEGE_RATE']===0)?ReneList[i]['RENEGE_RATE']:''}))
				otd.insert('%')
				oTr.insert(otd);
				$('grid_body1').insert(oTr);
			}
		}else if(update=='N'){
			$('IS_RENEGE').value='';
			for(var i=0;i<ReneList_size;i++){
				var oTr = new Element('tr',{id:'trB_'+i,'idB':'trB_'+i});
				oTr.insert(new Element('td',{'class':"tbYellow",align:'center'}).insert(new Element('input', {type:'radio', id:'radioGroup_'+i,name:'radioGroup' ,value:'1'})));
				var otd=new Element('td',{'class':"tbYellow2",colspan:"15"}).update("第").insert(new Element('input', {type:'text', id:'text1_1_'+i, size:'2',maxlength:"3",name:'BEG_TERM',value:(ReneList[i]['BEG_TERM']||ReneList[i]['BEG_TERM']===0)?ReneList[i]['BEG_TERM']:''}));
				otd.insert('-').insert(new Element('input', {type:'text', id:'text2',  size:'3',maxlength:"3",name:'END_TERM',value:(ReneList[i]['END_TERM']||ReneList[i]['END_TERM']===0)?ReneList[i]['END_TERM']:''}))
				otd.insert('期，比率').insert(new Element('input', {type:'text', id:'text3', size:'4', name:'RENEGE_RATE',value:(ReneList[i]['RENEGE_RATE']||ReneList[i]['RENEGE_RATE']===0)?ReneList[i]['RENEGE_RATE']:''}))
				otd.insert('%')
				oTr.insert(otd);
				$('grid_body1').insert(oTr);

			}
			$$('#grid_body1 tr').each(
				function(obj){
					obj.hide();
				}
			);
		}
		//=====「區域加成」下拉選單=======================================================
		var AreaAdd_mapList =  resp ? resp.AreaAdd_mapList.evalJSON() : '${AreaAdd_mapList}'.evalJSON();
		AreaAdd_mapList = AreaAdd_mapList? AreaAdd_mapList:[];
		$('AREA_ADD').update();
		$w('AREA_ADD').each(
			function(key){
				selection.createAll(key, AreaAdd_mapList, "", "", "");
			}
		);
		
		$('IS_ADJUST').checked = $('IS_ADJUST').value=='1';
		$('IS_ADJUST_M').checked = $('IS_ADJUST_M').value=='1';
		$('IS_RENEGE').checked = $('IS_RENEGE').value=='1';
		
		//=====其他資料=======================================================
		oldValue.VIP_ADD = DataMap.VIP_ADD;
		oldValue.INVEST_ADD = DataMap.INVEST_ADD;
		oldValue.AREA_ADD = DataMap.AREA_ADD;
		oldValue.GAGE_USE = DataMap.GAGE_USE;
		auxiliary.dataInput(DataMap);

		//=====「區域加成」下拉選單 [失效項選取調整]=======================================================
		var AREA_ADD_OPTS = $('AREA_ADD').options;
		if(AREA_ADD_OPTS.length > 0){
			var hasValue = false;
			for(var i =0 ; i<AREA_ADD_OPTS.length;i++){
				if(AREA_ADD_OPTS[i].value == DataMap.AREA_ADD){
					hasValue = true;
					break;
				}
			}
			if(!hasValue){
				if( DataMap.AREA_ADD == "" || DataMap.AREA_ADD == undefined ){
					$('AREA_ADD').value = "1";//無值時預設1:無
				}else{
					$('AREA_ADD').value = "";//失效項選取
				}
			}
		}

		//若PREFER_TYPE等於56 或是 MM_CODE等於1，則適用保戶123不可勾選且DISABLED
		PREFER_TYPE = DataMap.PREFER_TYPE;
		MM_CODE = DataMap.MM_CODE;
		if(PREFER_TYPE == '56' || MM_CODE == '1' || DataMap.IS_MANSION == '1' || DataMap.SPEC_CHECK_990625 == '1'){
			$('INSU_NOTE').checked = false;
			$('INSU_NOTE').disabled = true;

		} else if (DataMap.INSU_NOTE == "" || DataMap.INSU_NOTE == undefined){
			//若A130中無INSU_NOTE值，則 適用保戶123 預設打勾
			$('INSU_NOTE').checked = true;
		}

		// 載入資料後，要做的控制
		layout.VIP_ADD_control("VIP_ADD");
		layout.INVEST_ADD_control("INVEST_ADD");
		layout.AREA_ADD_control_load("AREA_ADD");

		//銀行轉介件(資料若為’X’,則畫面無預設值)
		if(DataMap.INSU_PRANK6 == 'X'){
			$('INSU_PRANK6_0').checked = false;
			$('INSU_PRANK6_1').checked = false;
		}

		//房仲買賣專案件(資料若為’X’,則畫面無預設值)
		if(DataMap.INSU_PRANK5 == 'X'){
			$('INSU_PRANK5_0').checked = false;
			$('INSU_PRANK5_1').checked = false;
		}

		if($('SPEC_CHECK_990625_0').checked){
			DataMap.SPEC_CHECK_990625 = '0';
		} else if ($('SPEC_CHECK_990625_1').checked) {
			DataMap.SPEC_CHECK_990625 = '1';
		}

		if($('IS_MANSION_0').checked){
			DataMap.IS_MANSION = '0';
		} else if ($('IS_MANSION_1').checked) {
			DataMap.IS_MANSION = '1';
		}

		if($('IS_COPRATION_0').checked){
			DataMap.IS_COPRATION = '0';
		} else if ($('IS_COPRATION_1').checked) {
			DataMap.IS_COPRATION = '1';
		}

		if($('IS_THIRD_CODE_0').checked){
			DataMap.IS_THIRD_CODE = '0';
		} else if ($('IS_THIRD_CODE_1').checked) {
			DataMap.IS_THIRD_CODE = '1';
		}

		//貸款期間全期不調整客戶等級 (資料若為空白,則畫面無預設值)
		if(DataMap.IS_FIX_VIPGRADE == undefined ||DataMap.IS_FIX_VIPGRADE == '' ){
			$('IS_FIX_VIPGRADE_0').checked = false;
			$('IS_FIX_VIPGRADE_1').checked = false;
		}

		//移轉年月只顯示年月
		var TRANS_DATE = DataMap.TRAN_DATE ? Date.toROC(DataMap.TRAN_DATE):'';
		if(TRANS_DATE!=''){
			$('TRAN_DATE').innerHTML = TRANS_DATE.substr(0,TRANS_DATE.length-3);
		}
		//1051220
 		$('IR_ADJ_DESC').setValue(DataMap.IR_ADJ_DESC);
  		$('CRED_NOTE').setValue(DataMap.CRED_NOTE);

		//是否首月免息
		if (!$('REMISSION_INT').checked && DataMap.REMISSION_NOTE == 'Y'){
			$('REMISSION_INT').checked = true;
		} else {
			$('REMISSION_INT').checked = false;
		}

		//帳管費
		if($('IS_EXPENSE').checked){
			$('EXPENSE_AMT').disabled = false;
		}

		if($('AGREE_HISTORY').innerHTML != ''){
			$('div_I').style.display = 'block';
		} else {
			$('div_I').style.display = 'none';
		}
		<%-- 20200901 效能問題，畫面改成一律顯示超連結，由另一個畫面去查新契約資料 --%>
		//近3個月是否有投保新契約
		/*if('Y'==DataMap.hasATApply){
			$$('.hasATApply').each(function(ele){
				ele.show();
			});
		}else{
			$$('.hasATApply').each(function(ele){
				ele.hide();
			});
		}*/
		<%--20201217 申請書201210001931 配合央行規定恢復受限戶簽件作業卡控及切結書底稿更新：增加法人購屋戶數--%>
		<%--法人購住戶數--%>
		if('1' == DataMap.IS_COPRATION){
			$('IS_COPRATION_CNT').enable();
			$('IS_COPRATION_CNT').setValue(DataMap.IS_COPRATION_CNT||'');
		}else{
			$('IS_COPRATION_CNT').disable();
			$('IS_COPRATION_CNT').setValue('');
		}
		<%--20230805 申請書230627005927 配合央行信用管制措施修改核心放款系統卡控：增加是否換屋選項--%>
		<%--購置特定地區--%>
		if('1' == DataMap.SPEC_CHECK_990625){
			$('IS_CHANGE_HOUSE').enable();
			$('IS_CHANGE_HOUSE').setValue(DataMap.IS_CHANGE_HOUSE||'');
		}else{
			$('IS_CHANGE_HOUSE').disable();
			$('IS_CHANGE_HOUSE').setValue('');
		}
		<%-- 20210401 申請書210326001405 配合央行規範修正簽件作業、核貸案件修正、核貸(後)補全通知：若為高價住宅和購置第3戶戶數--%>
		<%-- 高價住宅戶數 --%>
		if('1' == DataMap.IS_MANSION){
			$('IS_MANSION_CNT').enable();
			$('IS_MANSION_CNT').setValue(DataMap.IS_MANSION_CNT||'');
		}else{
			$('IS_MANSION_CNT').disable();
			$('IS_MANSION_CNT').setValue('');
		}
		<%--購置第3戶--%>
		if('1' == DataMap.IS_THIRD_CODE){
			$('IS_THIRD_CODE_CNT').enable();
			$('IS_THIRD_CODE_CNT').setValue(DataMap.IS_THIRD_CODE_CNT||'');
		}else{
			$('IS_THIRD_CODE_CNT').disable();
			$('IS_THIRD_CODE_CNT').setValue('');
		}
		<%--[申請書:220908003741]新增本金彈性還還款方式--%>
		var AGREE_FLEX_TYPE = DataMap.AGREE_FLEX_TYPE
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
		$('FLEX_MIN_SP').update(CSRUtil.$fmt(DataMap.FLEX_MIN, "#,###"));
		$('FLEX_MAX_SP').update(CSRUtil.$fmt(DataMap.FLEX_MAX, "#,###"));
	},
	// 取得畫面上的資料
	getAllData:function(){
		if(DataMap){
			// [20221227]
			// radio－房仲買賣專案件, 銀行轉介件, 整批分戶件,餘額轉貸方案, 是否為買賣件, 央行限制─購置特定地區 , 央行限制─高價住宅, 是否為保戶, 保單平均經過期間是否3年以上, 央行限制─法人購住, 央行限制─購置第3戶 每月約定還本擬准金額
			$w('INSU_PRANK5_0 INSU_PRANK5_1 INSU_PRANK6_0 INSU_PRANK6_1 INSU_PRANK7_0 INSU_PRANK7_1 CRED_STATUS8_0 CRED_STATUS8_1 GAGE_USE_0 GAGE_USE_1 IS_TRADE_0 IS_TRADE_1 SPEC_CHECK_990625_0 SPEC_CHECK_990625_1 IS_MANSION_0 IS_MANSION_1 IS_INSU_0 IS_INSU_1 IS_INSU_3YEAR_0 IS_INSU_3YEAR_1 IS_FIX_VIPGRADE_0 IS_FIX_VIPGRADE_1 IS_COPRATION_0 IS_COPRATION_1 IS_THIRD_CODE_0 IS_THIRD_CODE_1 AGREE_FLEX_TYPE_0 AGREE_FLEX_TYPE_1 AGREE_FLEX_TYPE_2').each(
				function(key){
					var radio = $(key);
					if(radio && radio.checked){
						DataMap[radio.name] = radio.value;
					}
				}
			);
			
			//[20221227]
			var AGREE_FLEX_TYPE = DataMap['AGREE_FLEX_TYPE'];
			if(AGREE_FLEX_TYPE) {
				if(AGREE_FLEX_TYPE == '0') {
					DataMap['AGREE_FLEX_AMT'] = $F('FLEX_MIN');
				}else if(AGREE_FLEX_TYPE == '1'){
					DataMap['AGREE_FLEX_AMT'] = $F('FLEX_MAX');
				} else {
					DataMap['AGREE_FLEX_AMT'] = $F('AGREE_FLEX_AMT');
				}
			}

			// checkbox－優質客戶加成, 投資戶加成, 新屋, 個案適用保戶123, 贈送火險及地震險, 是否首月免息, 是否投保火險, 繳息正常, 支存正常, 聯徵正常, 無自用查詢中, 無自用符合資格, 符合利害關係人授信作業規定, 符合保險業同一關係人、同一關係企業授信規定,是否需管理費
			$w('INVEST_ADD NEW_HOUSE INSU_NOTE INSUFREE_CODE REMISSION_INT IS_FIREINSU CRED_STATUS1 CRED_STATUS2 CRED_STATUS3 CRED_STATUS4 CRED_STATUS5 CRED_STATUS9 CRED_STATUSA IS_EXPENSE IR_ADJ_REASON1 IR_ADJ_REASON2 IR_ADJ_REASON3 IR_ADJ_REASON4 IR_ADJ_REASON5').each(
				function(key){
					var checkbox = $(key);
					if(checkbox.checked){
						DataMap[key] = checkbox.value;
					}else{
						DataMap[key] = 0;
					}
				}
			);

			// 輸入－平均單價, 鑑價報告編號, 徵信報告書參照案件編號, 償債能力分析表參照案件編號, 客戶資料照會表參照案件編號, 一般型擬准金額, 理財型擬准金額, 設定金額, 已保火險金額(有效), 火險年期(年), 火險年期(月), 清償理財型帳號, 買契價格, 鑑價報告買賣價, 火險保額, 要保人年繳化保費, 保單可貸金額, 一般型調整後利率, 保單已貸金額, 徵信說明, 轉介分行, 轉介人員,帳管費 , 「利率減項原因」減項原因說明 主要用途 受理進度
			$w('VIP_ADD AVG_PRICE APPR_APPLY_ID CRED_APPLY_ID DEBT_APPLY_ID ASSESS_APPLY_ID TEL_APPLY_ID AGREE_AMT AGREE_AMT_M SET_AMT FIREINSU_AMT_VALID FIREINSU_YY FIREINSU_MM MM_ID CRED_TRADE_AMT APPR_TRADE_AMT FIREINSU_AMT TOTAL_PREMIUM LOAN_ABLE INTEREST INTEREST_M LOAN_REMAIN CRED_NOTE BRANCH_BANK BRANCH_ID EXPENSE_AMT IR_ADJ_DESC MAIN_USE APPLY_PROCESS').each(
				function(key){
					DataMap[key] = $(key).getValue();
				}
			);

			// 下拉選單－區域加成條件, 實際用途, 業績A值 , 個調原因, 法人購住戶數, 高價住宅戶數, 購置第3戶戶數, 是否換屋
			$w('AREA_ADD REAL_USE A_VALUE IS_COPRATION_CNT IS_MANSION_CNT IS_THIRD_CODE_CNT IS_CHANGE_HOUSE').each(
				function(key){
					var value = $(key).value;
					if(value || Number(value)==0){
						DataMap[key] = value;
					}
				}
			);

			// 顯示－放款率(承作成數), 可貸金額, 區域放款率, 放款值 ,擔累貸金額╱鑑估總值 ,分區代碼
			$w('LOAN_LIMIT ABLE_AMT LOAN_LIMIT_C LIMIT_AMT GA_RATE AREA_CODE_930318').each(
				function(key){
					DataMap[key] = formatInput.getSplitValue($(key).innerHTML, ",");
				}
			);

			return DataMap;
		}else{
			return {};
		}
	},
	//批示歷程超連結(顯示/隱藏div)
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
};

//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var auxiliary = {
	// 將資料放進對應的欄位
	dataInput:function(datas){
		function trim(s) {
			var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
			return (m == null) ? "" : m[1];
		}

		var dataKey = Object.keys(datas);

		dataKey.each(
			function(key){
				try {
			 		var value = datas[key];
					var element = $(key);
					//IE11時,$(key)只能用ID,用NAME抓不到了(EX:$('GAGE_USE')抓不到radio box,因為其ID不是GAGE_USE是GAGE_USE_0跟GAGE_USE_1)
					if(!element){
						var objs = document.getElementsByName(key);
						if(objs.length!=0){
							element = objs[0];											
						}
					}
					if (element) {
						//var tagType = element.getAttribute('tagName');
						var tagType = element.tagName;
						if ( tagType != null) {
							tagType = trim(tagType).toLocaleLowerCase();
							var datatype = element.getAttribute('datatype');	// 自訂的型態(可能需要format)
							var pattern = element.getAttribute('pattern');		// 自訂的format格式

							if (tagType == 'div' || tagType == 'span' || tagType == 'td') {
								value = auxiliary.trim(value, datatype, pattern, key);
								element.update( value );
							} else {
								var type = element.getAttribute('type');
								if (type == 'checkbox' || type == 'radio') {
									var objs = document.getElementsByName(key);
									for (var j=0; j<objs.length; j++) {
										if (objs[j].value == value && objs[j].value == '1') {
											objs[j].checked = true;
										}else if(type == 'checkbox'){
											objs[j].checked = false;

										}
									}
									
									<%-- [20211216] --%>
									if(element.id == 'AGREE_ITEM_02') {
										
										if(value != '' && value != '0') {
											$('AGREE_ITEM_02_MAP').setValue(value);
											element.checked = true;
										} else {
											$('AGREE_ITEM_02_MAP').setValue('');
											element.checked = false;
										}
									}
									if(element.id == 'TRANS_CODE_2') { // 呈核層級事項-一年內重簽件
										if(value == '2') {
											$('TRANS_CODE_2').checked = true;
										} else {
											$('TRANS_CODE_2').checked = false;
										}
									}
									
									if(element.id=='IS_ADJUST'){
										if(datas['PROD_ID']=='56'||datas['MM_CODE']=='1'){
											$('IS_ADJUST').checked=true;
											$('IS_ADJUST').enable();
											$('IS_ADJUST').click();
											$('IS_ADJUST').disable();
										}/*else{
											$('IS_ADJUST').checked=false;
											$('IS_ADJUST').enable();
											$('IS_ADJUST').click();
										}*/

									}
									//debugger;
									if(element.id=='IS_ADJUST_M'){  //2016-12-12新增
										if(datas['PROD_ID']=='56'||datas['MM_CODE']=='0'){
											
											$('IS_ADJUST_M').checked=true;
											$('IS_ADJUST_M').enable();
											$('IS_ADJUST_M').click();
											$('IS_ADJUST_M').disable();
										}/*else{
											$('IS_ADJUST_M').checked=false;
											$('IS_ADJUST_M').enable();
											$('IS_ADJUST_M').click();
											//$('IS_ADJUST_M').disable();
										}*/
									}									
									if(element.id=='IS_RENEGE'){
										if(datas['PROD_ID']=='56'||datas['MM_CODE']=='1'){
											$('IS_RENEGE').checked=true;
											$('IS_RENEGE').enable();
											$('IS_RENEGE').click();
											$('IS_RENEGE').disable();
										}
									}
								}else {
									if(element.id=='INTEREST'&&$('IS_ADJUST').checked){
										$('INTEREST').value=$('text6_0').innerHTML;
										//$('INTEREST').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
									}else if(element.id=='INTEREST_M'&&$('IS_ADJUST_M').checked){
										$('INTEREST_M').value=$('text6_Fin_0').innerHTML;
										//$('INTEREST_M').readOnly=true; //20190402 欄位：「一般型調整後利率」、「理財型調整後利率」不得人工修改
									}else{
										var tmpNum = auxiliary.trim(value, datatype, pattern, key);
										element.setValue(tmpNum);
										
										//[20221227] 若IS_FLEX = N 則disable
										if(element.id == 'IS_FLEX' && 'Y' != tmpNum){
											$('AGREE_FLEX_TYPE_0').disable();
											$('AGREE_FLEX_TYPE_1').disable();
											$('AGREE_FLEX_TYPE_2').disable();
											$('AGREE_FLEX_AMT').disable();
										}
									}
								}
							}
						}
					}
				} catch (e) {
					//alert(e.message);
				}
			}
		);

		return;
	},
	// 將傳進來的字串去掉空白，或是當字串為null時回傳""
	trim:function(v, datatype, pattern, key){
		if(!isNaN(parseInt(v, 10))){
			v = v + "";
		}else if(!v){
			return "";
		}
		if(datatype == "number"){
			//return formatInput.patternNumber(v, false, formatInput.getPattern($(key).intLength, $(key).decLength, $(key).zeroDec));
			return formatInput.patternNumber(v, false, formatInput.getPattern($(key).getAttribute("intLength"), $(key).getAttribute("decLength"), $(key).getAttribute("zeroDec")));
		}else if(datatype == "date"){
			if(pattern == "time"){
				pattern = pattern_time;
			} else{
				pattern = pattern_date;
			}

			var result = (!v) ? '':v.match(pattern);
		    return (!result) ? '' : result[0];
		}else if(datatype == "ROCdate"){
			if(pattern == "time"){
				pattern = pattern_time;
			} else{
				pattern = pattern_date;
			}
 			var result = (!v) ? '':v.match(pattern);
			return (!result) ? '' : formatInput.Y2KDate2ROCDate(result[0], true, "/");
		}else if(datatype == "cm"){

		}

		return v.trim();
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
// radioButton && checkBox
//--------------------------------------------------------------------------
var radio_check = {
	// 依照傳入資料與id，產生radioButton或checkBox
	createAll:function(mode, tagID, eleName, optionList, key, value, choiceValue, isCode_CodeNM){
		if(mode == "radio" || mode == "checkbox"){
			if(!key){
				key = "CODE";
			}
			if(!value){
				value = "CODE_NM";
			}

			var target = $(tagID);
			if(target){
				if(optionList){
					for(var i = 0; i < optionList.length; i++){
						if(isCode_CodeNM){
							radio_check.create(mode, tagID, eleName, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
						}else{
							radio_check.create(mode, tagID, eleName, optionList[i][key], optionList[i][value], choiceValue);
						}
					}
				}
			}
		}
	},
	// 產生單一radioButton或checkBox
	create:function(mode, tagID, eleName, optionValue, optionText, choiceValue){
		var id;
		var name;
		if(mode == "radio"){
			id = eleName + "_" + optionValue;
			name = eleName;
		}else if(mode == "checkbox"){
			id = eleName;
			name = eleName;
		}

		var config = {
			id:id,
			name:name,
			type:mode,
			value:optionValue
		};
		//var input = tableElement.createElement("input", config);
		var input = new Element("input", config);
		input.setAttribute('name', name);

		$(tagID).appendChild(input);
		if(optionValue == choiceValue){
			$(input.id).checked = true;
		}

		var textNode = document.createTextNode(optionText);
		$(tagID).appendChild(textNode);
	},
	// 清空
	clean:function(tagID){
		$(tagID).innerHTML = "";
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
				className: "tbBlue",
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
			config.rows = config.rows ? config.rows : "5";
			config.disabled = config.disabled ? config.disabled : false;
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
						element.setAttribute(key, attribute);
					}
				}
			);
		}

		return element;
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
			pattern = pattern_number2;
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
			return pattern_number;
		}else{
			return pattern_number2;
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
function ajaxPost( actionName, params, successAction, errorAction, func_id){
	if(!func_id){
		func_id = "DSA2_1001";
	}
	new Ajax.Request(
		"<%=dispatcher%>/" +func_id + "/" + actionName,
		{ parameters: params,
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
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

	<%-- 區塊 A --%>
		<table id="area_A" name="area_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td align="center" colspan="6" class="tbYellow">
					<input id="btn_update1" name="btn_update1" type="button" class="button" value="試算">
					<input id="btn_update2" name="btn_update2" type="button" class="button" value="簽件">
					<input id="btn_delete" name="btn_delete" type="button" class="button" value="取消">
					<input id="btn_DSA21007" type="button" class="button" value="批覆書">
					<input id="btn_DSA21006" type="button" class="button" value="不動產明細">
					<input id="btn_DSA21008" type="button" class="button" value="鑑估表">
				</td>
			</tr>
		</table>

         <input type="hidden" id="POLICY_YEAR" name="POLICY_YEAR" value="" />
	<%-- 區塊 B --%>
	<table id="area_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="18%">
				受理編號
			</td>
			<td class="tbYellow2" colspan="3">
				<span id="APPLY_ID"></span>　<span id="IS_FAST_AGREE" style="color:red"></span><%-- 是否快速審核件 --%>
			</td>
			<td class="tbYellow" width="14%">
				借款人姓名
			</td>
			<td class="tbYellow2" width="18%">
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="BORROW_NAME" style="font-family:'EUDC'"></span>&nbsp;&nbsp;<span id="LEVEL_CH_NM"></span>
				
				<img id="img_getfile" class="hasATApply" style="cursor: hand;" src="<%=imageBase%>/DS/star5.gif" border=0 onClick="buttons.linkToDSA21018()">
				<span id="hasATApply_s" class="hasATApply">三個月內新契約資訊</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				受理進度
				
			</td>
			<td class="tbYellow2" width="16%">
				<span id="APPLY_PROCESS_NM"></span>
				<input id="APPLY_PROCESS" name="APPLY_PROCESS" type="hidden"/>
			</td>
			<td class="tbYellow" width="16%">
				批示進度
			</td>
			<td class="tbYellow2" width="16%">
				<span id="AGREE_PROCESS_NM"></span>
			</td>
			<td class="tbYellow">
				核定層級
			</td>
			<td class="tbYellow2">
				<span id="AGREE_LEVEL_NM"></span>
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
				<span id="LAND_SPACE" datatype="number" intLength="5" decLength="3"></span>&nbsp;<span>坪</span>
			</td>
			<td class="tbYellow">
				建坪
			</td>
			<td class="tbYellow2">
				<span id="BUILD_SPACE" datatype="number" intLength="5" decLength="3"></span>&nbsp;<span>坪</span>
			</td>
			<td class="tbBlue" colspan="2" rowspan="22" valign="top">
				<table width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbBlue" width="40%">
							房仲買賣專案件
						</td>
						<td class="tbBlue2">
							<input id="INSU_PRANK5_0" name="INSU_PRANK5" fieldName="房仲買賣專案件" type="radio" value="0" checked><span>否</span>
							<input id="INSU_PRANK5_1" name="INSU_PRANK5" fieldName="房仲買賣專案件" type="radio" value="1"><span>是</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							銀行轉介件
						</td>
						<td class="tbBlue2">
							<input id="INSU_PRANK6_0" name="INSU_PRANK6" fieldName="銀行轉介件" type="radio" value="0" checked><span>否</span>
							<input id="INSU_PRANK6_1" name="INSU_PRANK6" fieldName="銀行轉介件" type="radio" value="1"><span>是</span>
							<br>轉介分行<input id="BRANCH_BANK" name="BRANCH_BANK" fieldName="轉介分行" type="text" class="textBox2" size="10" maxlength="16" value="">
							<%--[20240729] 修改件 陳勁谷 難字修改 --%>
							<br>轉介人員<input id="BRANCH_ID" name="BRANCH_ID" fieldName="轉介人員" type="text" class="textBox2" size="10" maxlength="10" value="" alt="ch">
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							餘額轉貸方案
						</td>
						<td class="tbBlue2">
							<input id="CRED_STATUS8_0" name="CRED_STATUS8" fieldName="餘額轉貸方案" type="radio" value="0" checked><span>否</span>
							<input id="CRED_STATUS8_1" name="CRED_STATUS8" fieldName="餘額轉貸方案" type="radio" value="1"><span>是</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							整批分戶件
						</td>
						<td class="tbBlue2">
							<input id="INSU_PRANK7_0" name="INSU_PRANK7" fieldName="整批分戶件" type="radio" value="0" checked><span>否</span>
							<input id="INSU_PRANK7_1" name="INSU_PRANK7" fieldName="整批分戶件" type="radio" value="1"><span>是</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							帳管費
						</td>
						<td class="tbBlue2">
							<input id="IS_EXPENSE" name="IS_EXPENSE" type="checkbox" value="1">
							<input id="EXPENSE_AMT" name="EXPENSE_AMT" fieldName="帳管費" type="text" class="textBox2 validate-positive validate-number0 " datatype="number"  pattern="#,###" size="8" maxlength="9" value="" disabled><span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							承作成數
						</td>
						<td class="tbBlue2">
							<span id="LOAN_LIMIT" datatype="number" intLength="3" decLength="2"></span>&nbsp;<span>%</span><br/><%-- 承作成數 --%>
							<span>1.債信指標調整：</span><span id="CRED_ADD_RATE"></span><br/>
							<span>2.優質客戶加成</span><input id="VIP_ADD" name="VIP_ADD" fieldName="優質客戶加成" type="hidden" value="0"><span>：</span><span id="VIP_ADD_RATE"></span><br/>
							<span>3.區域加成條件</span><span>：</span><span id="AREA_ADD_RATE"></span><br/>
							<select id="AREA_ADD" style="width:120px" fieldName="區域加成條件"></select><br/>
							<span>4.投資戶</span><input id="INVEST_ADD" name="INVEST_ADD" fieldName="投資戶" type="checkbox" value="1"><span>：</span><span id="INVEST_ADD_RATE"></span>

						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							貸放成數
						</td>
						<td class="tbBlue2">
							<span id="GA_RATE" datatype="number" intLength="3" decLength="2" zeroDec="2"></span>&nbsp;<span>%</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							一般型擬准金額
						</td>
						<td class="tbBlue2">
							<input id="AGREE_AMT" name="AGREE_AMT" fieldName="一般型擬准金額" type="text" class="textBox2" datatype="number" intLength="11" pattern="#,###" size="10" maxlength="15" value=""><span>萬</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							理財型擬准金額
						</td>
						<td class="tbBlue2">
							<input id="AGREE_AMT_M" name="AGREE_AMT_M" fieldName="理財型擬准金額" type="text" class="textBox2" datatype="number" intLength="11" pattern="#,###" size="10" maxlength="15" value=""><span>萬</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							設定金額
						</td>
						<td class="tbBlue2">
							<input id="SET_AMT" name="SET_AMT" fieldName="設定金額" type="text" class="textBox2" datatype="number" intLength="11" pattern="#,###" size="10" maxlength="15" value=""><span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							放款值
						</td>
						<td class="tbBlue2">
							<span id="LIMIT_AMT" datatype="number" intLength="11"></span>&nbsp;<span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							可貸金額
						</td>
						<td class="tbBlue2">
							<span id="ABLE_AMT" datatype="number" intLength="11"></span>&nbsp;<span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							淨值比
						</td>
						<td class="tbBlue2">
							<span id="REALVALUE_RATE" datatype="number" intLength="3" decLength="2"></span>&nbsp;<span>%</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							屋齡
						</td>
						<td class="tbBlue2">
							<span id="BUILD_AGE" datatype="number" intLength="3"></span>&nbsp;<span>年</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							土地增值稅
						</td>
						<td class="tbBlue2">
							<span id="LAND_TAX" datatype="number" intLength="11"></span>&nbsp;<span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							鑑估總值
						</td>
						<td class="tbBlue2">
							<span id="APPR_AMT" datatype="number" intLength="11"></span>&nbsp;<span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							判定時價
						</td>
						<td class="tbBlue2">
							<span id="APPR_REALVALUE" datatype="number" intLength="11"></span>&nbsp;<span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							買契價格
						</td>
						<td class="tbBlue2">
							<input id="CRED_TRADE_AMT" name="CRED_TRADE_AMT" fieldName="買契價格" type="text" class="textBox2" datatype="number" intLength="7" decLength="1" pattern ="#,###.#" size="11" maxlength="11" value=""><span>萬</span>
							<input id="APPR_TRADE_AMT" name="APPR_TRADE_AMT" type="hidden" />
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							火險保額
						</td>
						<td class="tbBlue2">
							<input id="FIREINSU_AMT" name="FIREINSU_AMT" fieldName="火險保額" type="text" class="textBox2" datatype="number" intLength="7" pattern ="#,###" size="10" maxlength="10" value=""><span>萬</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							是否投保火險
						</td>
						<td class="tbBlue2">
							<input id="IS_FIREINSU" name="IS_FIREINSU" fieldName="是否投保火險" type="checkbox" value="1"><span>（勾選）</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							業績A值
						</td>
						<td class="tbBlue2">
							<select id="A_VALUE" fieldName="業績A值"></select>
						</td>
					</tr>
					<tr>
						<td class="tbBlue"> <%-- [20221227] --%>
							每月約定還本擬准金額
						</td>
						<td class="tbBlue2">
							<input id="IS_FLEX" name="IS_FLEX" fieldName="是否本金彈性還" type="hidden" value="">
							<input id="FLEX_MIN" name="FLEX_MIN" fieldName="下限金額" type="hidden" value="${FLEX_MIN}">
							<input id="AGREE_FLEX_TYPE_0" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="0">
							<span>下限金額</span><span id="FLEX_MIN_SP" datatype="number" intLength="11"></span><span>元</span>
							<br>
							<input id="AGREE_FLEX_TYPE_2" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="2">自行約定金額
							<input id="AGREE_FLEX_AMT" name="AGREE_FLEX_AMT" fieldName="自行約定金額" type="text" class="textBox2" datatype="number" intLength="11" pattern="#,###" size="10" maxlength="15" value=""><span>元</span>
							<br>
							<input id="FLEX_MAX" name="FLEX_MAX" fieldName="上限金額" type="hidden" value="${FLEX_MAX}">
							<input id="AGREE_FLEX_TYPE_1" name="AGREE_FLEX_TYPE" fieldName="每月約定還本擬准金額" type="radio" value="1">
							<span>上限金額</span><span id="FLEX_MAX_SP" datatype="number" intLength="11"></span><span>元</span>
						</td>
					</tr>
					<tr>
						<td class="tbBlue" colspan="2">
							利率
						</td>
					</tr>
					<tr>
						<td class="tbBlue2" colspan="2" rowspan="2" valign="top">
							一般型表定利率：<span id="INTEREST_C" datatype="number" intLength="2" decLength="4"></span>&nbsp;%<br/>
							理財型表定利率：<span id="INTEREST_C_M" datatype="number" intLength="2" decLength="4"></span>&nbsp;%<br/>
							(一般型調整後利率)：<input id="INTEREST" name="INTEREST" fieldName="一般型調整後利率" type="text" class="textBox2" datatype="number" intLength="2" decLength="4" pattern ="##.####" size="10" maxlength="7" value="" readonly>%<br/>
							(理財型調整後利率)：<input id="INTEREST_M" name="INTEREST_M" fieldName="理財型調整後利率" type="text" class="textBox2" datatype="number" intLength="2" decLength="4" pattern ="##.####" size="10" maxlength="7" value="" readonly>%<br/>
							理財型帳號設定：<span id="ACCOUNT_STATUS_NM"></span>
						</td>
					</tr>
				</table>
				<table id="table_A" width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbBlue" colspan="15">
							一般型利率個調
							<input id="IS_ADJUST"  type="checkbox" value="">
						</td>
					</tr>
					<tr id="table_A_tr1">
						<td class="tbBlue2" width="2%" align='center'>
							選取
						</td>
						<td class="tbBlue2" colspan="15" width="15%" align='center'>
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
						<td class="tbBlue" colspan="15">
							提前清償違約金
							<input id="IS_RENEGE"  type="checkbox" value="">
						</td>
					</tr>
					<tr id="table_B_tr1">
						<td class="tbBlue2" width="2%" align='center'>
							選取
						</td>
						<td class="tbBlue2" colspan="15" width="15%" align='center'>
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
				<table width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbBlue" width="50%">
							利率減項原因
						</td>
						<td class="tbBlue2">
							<input id="IR_ADJ_REASON1" name="IR_ADJ_REASON1" type="checkbox" value="1"> 經營策略${IR_ADJ_REASON1RATE}<br/>
							<input id="IR_ADJ_REASON2" name="IR_ADJ_REASON2" type="checkbox" value="1"> 客戶貢獻度${IR_ADJ_REASON2RATE}<br/>
							<input id="IR_ADJ_REASON3" name="IR_ADJ_REASON3" type="checkbox" value="1"> 償債能力${IR_ADJ_REASON3RATE}<br/>
							<input id="IR_ADJ_REASON4" name="IR_ADJ_REASON4" type="checkbox" value="1"> 職業收入${IR_ADJ_REASON4RATE}<br/>
							<input id="IR_ADJ_REASON5" name="IR_ADJ_REASON5" type="checkbox" value="1"> 其他${IR_ADJ_REASON5RATE}
						</td>
					</tr>

					<tr>
						<td class="tbBlue" colspan="2">
							減項原因說明
						</td>
					</tr>
					<tr>
						<td class="tbBlue2" colspan="2">
							<textarea id="IR_ADJ_DESC" name="IR_ADJ_DESC" fieldName="減項原因說明" rows="8" cols="60"></textarea>
						</td>
					</tr>
				</table>
			</td>

		</tr>
		<tr>
			<td class="tbYellow">
				公告現值
			</td>
			<td class="tbYellow2">
				<span id="ANNOU_VALUE" datatype="number" intLength="8"></span>&nbsp;<span>元/坪</span>
			</td>
			<td class="tbYellow">
				移轉現價
			</td>
			<td class="tbYellow2">
				<span id="TRAN_VALUE" datatype="number" intLength="8"></span>&nbsp;<span>元/坪</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				平均單價
			</td>
			<td class="tbYellow2">
				<input id="AVG_PRICE" name="AVG_PRICE" fieldName="平均單價" type="text" class="textBox2" datatype="number" intLength="4" decLength="2" zeroDec="2" pattern="#,###.00" size="10" maxlength="10" value=""><span>萬</span>
			</td>
			<td class="tbYellow">
				總樓層
			</td>
			<td class="tbYellow2">
				<span id="FLOOR" datatype="number" intLength="3">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				鑑價報告編號
			</td>
			<td class="tbYellow2">
				<input id="APPR_APPLY_ID" name="APPR_APPLY_ID" fieldName="鑑價報告編號" type="text" class="textBox2" size="15" maxlength="11" value="">
			</td>
			<td class="tbYellow">
				收支比/償債能力分析表<br/>參照案件編號
			</td>
			<td class="tbYellow2">
				<input id="DEBT_APPLY_ID" name="DEBT_APPLY_ID" fieldName="償債能力分析表參照案件編號" type="text" class="textBox2" size="15" maxlength="11" value="">
				<!--<input id="btn_link1" name="btn_link1" type="button" class="button" value="進入">-->
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				信用評分表<br/>參照案件編號
			</td>
			<td class="tbYellow2">

				<input id="ASSESS_APPLY_ID" name="ASSESS_APPLY_ID" fieldName="信用評分表參照案件編號" type="text" class="textBox2" size="15" maxlength="11" value="">
			</td>
			<td class="tbYellow">
				買賣件查證事項或 <br/>客戶資料照會表<br/>參照案件編號
			</td>
			<td class="tbYellow2">
				<input id="TEL_APPLY_ID" name="TEL_APPLY_ID" fieldName="客戶資料照會表參照案件編號" type="text" class="textBox2" size="15" maxlength="11" value=""><br>
				<input id="btn_link2" name="btn_link2" type="button" class="button" value="進入">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				徵信報告書參照案件編號
			</td>
			<td class="tbYellow2">
				<input id="CRED_APPLY_ID" name="CRED_APPLY_ID" fieldName="徵信報告書參照案件編號" type="text" class="textBox2" size="15" maxlength="11" value="">
			</td>
			<td class="tbYellow">
				主要建材
			</td>
			<td class="tbYellow2">
				<span id="MATERIAL_NM"></span>
			</td>

		</tr>
		<tr>
			<td class="tbYellow">
				建築完成日
			</td>
			<td class="tbYellow2">
				<span id="FINISH_DATE" datatype="ROCdate"></span>
			</td>
			<td class="tbYellow">
				建築型態
			</td>
			<td class="tbYellow2">
				<span id="BUILD_TYPE_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				移轉年月
			</td>
			<td class="tbYellow2">
				<span id="TRAN_DATE" datatype="ROCdate"></span>
			</td>
			<td class="tbYellow">
				主要用途
			</td>
			<td class="tbYellow2">
				<span id="MAIN_USE_NM"></span>
				<input id = "MAIN_USE" name = "MAIN_USE" type = "hidden"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				建物使用情形
			</td>
			<td class="tbYellow2">
				<span id="USE_STATUS_NM"></span>
			</td>
			<td class="tbYellow">
				押金
			</td>
			<td class="tbYellow2">
				<span id="RENT" pattern ="#,###.##" intLength="7" decLength="2"></span>&nbsp;<span>元</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				火險單價
			</td>
			<td class="tbYellow2">
				<span id="FIREINSU_PRICE" datatype="number" intLength="6"></span>&nbsp;<span>元/坪</span>
			</td>
			<td class="tbYellow">
				火險年期
			</td>
			<td class="tbYellow2">
				<input id="FIREINSU_YY" name="FIREINSU_YY" fieldName="火險年期(年)" type="text" class="textBox2" datatype="number" intLength="2" pattern="##" size="2" maxlength="2" value=""><span>年</span>
				<input id="FIREINSU_MM" name="FIREINSU_MM" fieldName="火險年期(月)" type="text" class="textBox2" datatype="number" intLength="2" pattern="##" size="2" maxlength="2" value=""><span>月</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				已保火險金額(有效)
			</td>
			<td class="tbYellow2">
				<input id="FIREINSU_AMT_VALID" name="FIREINSU_AMT_VALID" fieldName="已保火險金額(有效)" type="text" class="textBox2" datatype="number" intLength="7" decLength="2" pattern ="#,###.##" size="10" maxlength="13" value=""><span>萬</span>
			</td>
			<td class="tbYellow">
				已生效理財型額度
			</td>
			<td class="tbYellow2">
				<span id="GAGE_AMT_M" datatype="number" intLength="11"></span>&nbsp;<span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				擔已貸金額
			</td>
			<td class="tbYellow2">
				<span id="GAGE_AMT" datatype="number" intLength="11"></span>&nbsp;<span>萬</span>
			</td>
			<td class="tbYellow">
				區域放款率<br/>
				(生活圈)
			</td>
			<td class="tbYellow2">
				<span id="LOAN_LIMIT_C" datatype="number" intLength="3" decLength="2"></span>&nbsp;<span>%</span>　<span id="AREA_CODE_930318" style="color:red"></span>&nbsp;<span style="color:red">區</span><br/>
				<span id="GAGE_USE_radio"></span><br/>
				<span id="SUBMKT_NAME"></span>
				<span id="SUBMKT_NAME_MEMO"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				新屋
			</td>
			<td class="tbYellow2">
				<input id="NEW_HOUSE" name="NEW_HOUSE" fieldName="新屋" type="checkbox" value="1"><span>（勾選）</span>
			</td>
			<td class="tbYellow">
				實際用途
			</td>
			<td class="tbYellow2">
				<select id="REAL_USE" fieldName="實際用途"></select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				適用保戶優惠
			</td>
			<td class="tbYellow2">
				<input id="INSU_NOTE" name="INSU_NOTE" fieldName="個案適用保戶優惠" type="checkbox" value="1"><span>（勾選）</span>
			</td>
			<td class="tbYellow">
				清償理財型帳號
			</td>
			<td class="tbYellow2">
				<input id="MM_ID" name="MM_ID" fieldName="清償理財型帳號" type="text" class="textBox2" size="15" maxlength="10" value="">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				贈送火險及地震險
			</td>
			<td class="tbYellow2">
				<input id="INSUFREE_CODE" name="INSUFREE_CODE" fieldName="贈送火險及地震險" type="checkbox" value="1"><span>（勾選）</span>
			</td>
			<td class="tbYellow">
				優質等級
			</td>
			<td class="tbYellow2">
				<span id="VIP_GRADE_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				是否首月免息
			</td>
			<td class="tbYellow2">
				<input id="REMISSION_INT" name="REMISSION_INT" fieldName="是否首月免息" type="checkbox" value="1"><span>（勾選）</span>
			</td>
			<td class="tbYellow">
				貸款期間全期不調整客戶等級
			</td>
			<td class="tbYellow2">
				<input id="IS_FIX_VIPGRADE_0" name="IS_FIX_VIPGRADE" fieldName="貸款期間全期不調整客戶等級" type="radio" value="0" checked><span>否</span>
				<input id="IS_FIX_VIPGRADE_1" name="IS_FIX_VIPGRADE" fieldName="貸款期間全期不調整客戶等級" type="radio" value="1"><span>是</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				收支比
			</td>
			<td class="tbYellow2">
				<span id="INCOME_EXP_RATE" datatype="number" intLength="3" decLength="1" zeroDec="1"></span>&nbsp;<span>%</span>
				<!--input id="btn_link3" name="btn_link3" type="button" class="button" value="進入">-->
			</td>
			<td class="tbYellow">
				是否為買賣件
			</td>
			<td class="tbYellow2">
				<input id="IS_TRADE_0" name="IS_TRADE" fieldName="是否為買賣件" type="radio" value="0" checked><span>否</span>
				<input id="IS_TRADE_1" name="IS_TRADE" fieldName="是否為買賣件" type="radio" value="1"><span>是</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				央行限制─法人購住
			</td>
			<td class="tbYellow2">
				<input id="IS_COPRATION_0" name="IS_COPRATION" fieldName="央行限制─法人購住" type="radio" value="0" checked><span>否</span>
				<input id="IS_COPRATION_1" name="IS_COPRATION" fieldName="央行限制─法人購住" type="radio" value="1"><span>是</span>
				&nbsp;
				<select  id="IS_COPRATION_CNT" name = "IS_COPRATION_CNT" fieldName = "央行限制─法人購住戶數"></select>
			</td>
			<td class="tbYellow">
				是否為保戶
			</td>
			<td class="tbYellow2">
				<input id="IS_INSU_0" name="IS_INSU" fieldName="是否為保戶" type="radio" value="0" checked><span>否</span>
				<input id="IS_INSU_1" name="IS_INSU" fieldName="是否為保戶" type="radio" value="1"><span>是</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				央行限制─高價住宅
			</td>
			<td class="tbYellow2">
				<input id="IS_MANSION_0" name="IS_MANSION" fieldName="央行限制─高價住宅" type="radio" value="0" checked><span>否</span>
				<input id="IS_MANSION_1" name="IS_MANSION" fieldName="央行限制─高價住宅" type="radio" value="1"><span>是</span>
				&nbsp;
				<select  id="IS_MANSION_CNT" name = "IS_MANSION_CNT" fieldName = "央行限制─高價住宅戶數"></select>
			</td>
			<td class="tbYellow">
				保單平均3年以上
			</td>
			<td class="tbYellow2">
				<input id="IS_INSU_3YEAR_0" name="IS_INSU_3YEAR" fieldName="保單平均3年以上" type="radio" value="0" checked><span>否</span>
				<input id="IS_INSU_3YEAR_1" name="IS_INSU_3YEAR" fieldName="保單平均3年以上" type="radio" value="1"><span>是</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				央行限制─購置特定地區或全國地區
			</td>
			<td class="tbYellow2">
				<input id="SPEC_CHECK_990625_0" name="SPEC_CHECK_990625" fieldName="央行限制─購置特定地區" type="radio" value="0" checked><span>否</span>
				<input id="SPEC_CHECK_990625_1" name="SPEC_CHECK_990625" fieldName="央行限制─購置特定地區" type="radio" value="1"><span>是</span>
				&nbsp;
				<select  id="IS_CHANGE_HOUSE" name = "IS_CHANGE_HOUSE" fieldName = "央行限制─是否換屋"></select>
			</td>
			<td class="tbYellow">
				要保人年繳化保費
			</td>
			<td class="tbYellow2">
				<input id="TOTAL_PREMIUM" name="TOTAL_PREMIUM" fieldName="要保人年繳化保費" type="text" class="textBox2" datatype="number" intLength="6" decLength="2" pattern ="#,###.##" size="10" maxlength="11" value=""><span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				央行限制─購置第3戶
			</td>
			<td class="tbYellow2">
				<input id="IS_THIRD_CODE_0" name="IS_THIRD_CODE" fieldName="央行限制─購置第3戶" type="radio" value="0" checked><span>否</span>
				<input id="IS_THIRD_CODE_1" name="IS_THIRD_CODE" fieldName="央行限制─購置第3戶" type="radio" value="1"><span>是</span>
				&nbsp;
				<select  id="IS_THIRD_CODE_CNT" name = "IS_THIRD_CODE_CNT" fieldName = "央行限制─購置第3戶戶數"></select>
			</td>
			<td class="tbYellow">
				保單可貸金額
			</td>
			<td class="tbYellow2">
				<input id="LOAN_ABLE" name="LOAN_ABLE" fieldName="保單可貸金額" type="text" class="textBox2" datatype="number" intLength="6" decLength="2" pattern ="#,###.##" size="10" maxlength="11" value=""><span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" colspan="2">
				徵信狀況
			</td>
			<td class="tbYellow">
				保單已貸金額
			</td>
			<td class="tbYellow2">
				<input id="LOAN_REMAIN" name="LOAN_REMAIN" fieldName="保單已貸金額" type="text" class="textBox2" datatype="number" intLength="6" decLength="2" pattern ="#,###.##" size="10" maxlength="11" value=""><span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="2" valign="top">
				<input id="CRED_STATUS1" name="CRED_STATUS1" fieldName="繳息正常" type="checkbox" value="1"><span>繳息正常</span><br/>
				<input id="CRED_STATUS2" name="CRED_STATUS2" fieldName="支存正常" type="checkbox" value="1"><span>支存正常</span><br/>
				<input id="CRED_STATUS3" name="CRED_STATUS3" fieldName="聯徵正常" type="checkbox" value="1"><span>聯徵正常</span><br/>
				<input id="CRED_STATUS4" name="CRED_STATUS4" fieldName="無自用查詢中" type="checkbox" value="1"><span>無自用查詢中</span><br/>
				<input id="CRED_STATUS5" name="CRED_STATUS5" fieldName="無自用符合資格" type="checkbox" value="1"><span>無自用符合資格</span><br/>
				<input id="CRED_STATUS9" name="CRED_STATUS9" fieldName="符合利害關係人授信作業規定" type="checkbox" value="1"><span>符合利害關係人授信作業規定</span><br/>
				<input id="CRED_STATUSA" name="CRED_STATUSA" fieldName="符合保險業同一關係人、同一關係企業授信規定" type="checkbox" value="1"><span>符合保險業同一關係人、同一關係企業授信規定</span>
			</td>
			<td class="tbYellow2" colspan="2">
				<span>徵信人員：</span><span id="INPUT_NAME"></span><br/>
				<span>作業日期：</span><span id="INPUT_DATE" datatype="ROCdate"></span><br/>
				<span>連絡電話：</span><span id="CRED_TEL"></span>
			</td>
			<td class="tbYellow2" colspan="2"> <%-- [20211216] 新增呈核層級事項 --%>
				<span>呈核層級事項:</span><br/>
				<input id="AGREE_ITEM_01" name="AGREE_ITEM_01" fieldName="不予承作事項" type="checkbox" value="1"><span>不予承作事項</span><br/>
				<input id="AGREE_ITEM_02" name="AGREE_ITEM_02" fieldName="提高授權事項" type="checkbox"><span>提高授權事項</span><select id="AGREE_ITEM_02_MAP" name="AGREE_ITEM_02_MAP" fieldName="提高授權事項選單"></select><br/>
				<input id="AGREE_ITEM_03" name="AGREE_ITEM_03" fieldName="洗錢防制高風險客戶" type="checkbox" value="1"><span>洗錢防制高風險客戶</span><br/>
				<input id="TRANS_CODE_2" name="TRANS_CODE_2" fieldName="一年內重簽件" type="checkbox" value="2"><span>一年內重簽件</span><br/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="6">
				<font color="red">徵信說明：</font><br>
				<textarea id="CRED_NOTE" name="CRED_NOTE" fieldName="徵信說明" rows="8" cols="60"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="6">
				<a href="#A_div_I" onClick="layout.doShowHistory()" name="A_div_I">＊批示歷程</a>
				<div id="div_I" style="overflow:auto; display:none;">
					<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					<span id="AGREE_HISTORY" style="font-family:'EUDC'"></span>
				</div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="6">
				<a href="#A_div_J" onClick="layout.doShowFileList()" name="A_div_J">＊取消核貸批覆書</a>
				<div id="div_J" style="overflow:auto; display:none;">
					<span id="FILE_LIST">
						<table id="grid" class="grid" width="100%"></table>
					</span>
				</div>
			</td>
		</tr>
	</table>
</body>
</html>