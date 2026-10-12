<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<fmt:setBundle basename="TextResource" />

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/JavaScript">

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

//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0072:'btn_update1'
	};
	<dz:grantButtons FUNC_ID="DSA21009" ignored="true"/>
}

function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA21009" , "核貸作業" , "新件初核件作業", 1,'${titleNotDisplay}' == 'Y');

	displayMessage();
	// 日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();

	// 按鈕權限
	buttonAuth();

	// 檢核物件
	validate4define = new Validation("body", {useTitles:true, focusOnError:false, immediate:false});
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',function(obj){return false;}],
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

function UI(){
	return {
		init:function() {
			//--------- 註冊按鈕 ----------
			// 試算
			$("btn_update1").observe('click',function(event){
				buttons.doUpdate1();
			});
			// 初核同意
			$("btn_agree").observe('click',function(event){
				buttons.doAgree();
			});
			// 初核同意取消
			$("btn_cancelagree").observe('click',function(event){
				buttons.doCancelAgree();
			});
			//不動產明細
			$("btn_DSA21006").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1006');
			});
			//影像連結
			$("btn_image").observe('click',function(event){
				buttons.doLinkToPDF('DSA0_0200');
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
			$w('VIP_ADD').each(
				function(key){
					$(key).observe('click',function(event){
						layout.VIP_ADD_control(key);
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
			});
			// 計算擔累貸金額╱鑑估總值
			$w('AGREE_AMT AGREE_AMT_M').each(
				function(key){
					$(key).observe('blur',function(event){
						buttons.doCalculate("1");
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
			//--------- 註冊事件 ----------
			// 輸入(去空白、轉大寫)
			register.textNoSpace('APPR_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID', "upper");
			// 輸入(去空白)
			register.textNoSpace('LEADER_COMMENT');
			// 格式化數字
			register.isPatternNumber('AVG_PRICE TOTAL_PREMIUM LOAN_ABLE LOAN_REMAIN AGREE_AMT AGREE_AMT_M INTEREST');
			// 「實際用途」下拉選單
			<c:if test="${not empty RealUse_mapList}">
				var RealUse_mapList = ${RealUse_mapList};
				$w('REAL_USE').each(function(key){
					selection.createAll(key, RealUse_mapList, "", "", "");
				});
			</c:if>
			// 「業務A值」下拉選單
			<c:if test="${not empty AValue_mapList}">
				var AValue_mapList = ${AValue_mapList};
				$w('A_VALUE').each(function(key){
					selection.createAll(key, AValue_mapList, "", "", "","1.00");
				});
			</c:if>
			// 擔保品使用狀況radio選單
			<c:if test="${not empty GageUse_mapList}">
				var GageUse_mapList = ${GageUse_mapList};
				$w('GAGE_USE_radio').each(function(key){
					radio_check.createAll("radio", key, "GAGE_USE", GageUse_mapList, "", "", "0", "");
				});
				// 擔保品使用狀況－選取時計算區域放款率
				$w('GAGE_USE_0 GAGE_USE_1').each(function(key){
					if($(key)){
						$(key).observe('click',function(event){
							buttons.doCalculate("3");
						});
					}
				});
			</c:if>
			// 一般件簽件資料
			<c:if test="${not empty DataMap}">
				DataMap = ${DataMap};
				layout.loadData();
				alert('查詢完成');
			</c:if>
		}
	};
}

//--------------------------------------------------------------------------
// 註冊事件
//--------------------------------------------------------------------------
var register = {
	// 欄位去空白
	textNoSpace:function (keys, type, toFullwidth){
		$w(keys).each(function(key){
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
		});
	},
	// 數字欄位轉換
	isNumber:function (keys){
		$w(keys).each(function(key){
			$(key).observe('blur', function(event){
				formatInput.number(key);
			});
		});
	},
	// 數字(有位數或格式限制)欄位轉換
	isPatternNumber:function (keys){
		$w(keys).each(function(key){
			$(key).observe('blur', function(event){
				formatInput.patternNumber(key, true, $(key).pattern);
			});
		});
	},
	doTrimTextArea : function (){
		if($('LEADER_COMMENT').value.length>0){
			$('LEADER_COMMENT').value = $('LEADER_COMMENT').value.replace(/'/gi, "").replace(/"/gi, "");
			while(true){
				ln0 = $('LEADER_COMMENT').value.length;
				while(true){
					ln1 = $('LEADER_COMMENT').value.length;
					if($('LEADER_COMMENT').value.indexOf('\r\n')>=0){
						//trim掉最後一個\r\n
						$('LEADER_COMMENT').value = $('LEADER_COMMENT').value.replace(/\r\n$/g, "");
						if(ln1 == $('LEADER_COMMENT').value.length){
							break;	
						}
					}else{
						break;
					}
				}
				while(true){
					ln2 = $('LEADER_COMMENT').value.length;
					if($('LEADER_COMMENT').value.indexOf(' ')>=0){
						$('LEADER_COMMENT').value = $('LEADER_COMMENT').value.replace(/ $/g, "");
						if(ln2 == $('LEADER_COMMENT').value.length){
							break;	
						}
					}else{
						break;
					}
				}
				if(ln0 == $('LEADER_COMMENT').value.length){
					break;	
				}
			}
		}
	}
};

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 試算
	doUpdate1:function(){
		register.doTrimTextArea();
		var actionName = "update1";
		if(!validates.checkInput(actionName)){
			return;
		}
		var queryData = layout.getAllData();
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
		
			layout.loadData(resp);
			doUpdate1 = true;
			
		};
		var errorAction = function(resp){
			doUpdate1 = false;
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 計算
	doCalculate:function(type){
		var calData = {};
		var successAction;
		
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
			calData["TYPE"] = "1";	// 案件種類:1=一般件
			
			calData["GAGE_AMT_M"] = $('GAGE_AMT_M').innerHTML ? formatInput.getSplitValue($('GAGE_AMT_M').innerHTML, ",") : "0";	// 已生效理財型額度

			successAction = function(resp){
				// 擔累貸金額╱鑑估總值
				$('GA_RATE').innerHTML = formatInput.patternNumber(resp.ga_rate, false, formatInput.getPattern($('GA_RATE').intLength, $('GA_RATE').decLength, $('GA_RATE').zeroDec));
				//$('AGREE_AMT').value = formatInput.patternNumber(resp.AGREE_AMT, false, formatInput.getPattern($('AGREE_AMT').intLength, $('AGREE_AMT').decLength, $('AGREE_AMT').zeroDec));
				//$('AGREE_AMT_M').value = formatInput.patternNumber(resp.AGREE_AMT, false, formatInput.getPattern($('AGREE_AMT_M').intLength, $('AGREE_AMT_M').decLength, $('AGREE_AMT_M').zeroDec));
			}
		}
		// 計算放款率(承作成數)
		else if(type == "2"){
			calData["AREA_CODE_930318"] = $('AREA_CODE_930318').innerHTML;	// 擔保品地區
			calData["VIP_ADD_RATE"] = formatInput.getSplitValue($('VIP_ADD_RATE').innerHTML, "+");	// 優質客戶加成
			calData["AREA_ADD_RATE"] = formatInput.getSplitValue($('AREA_ADD_RATE').innerHTML, "+");	// 區域加成條件
			calData["CRED_ADD_RATE"] = formatInput.getSplitValue($('CRED_ADD_RATE').innerHTML, ",");	// 債信指標調整
			calData["CRED_ADD"] = DataMap['CRED_ADD'];	// 債信等級
			calData["GFS_SCORE"] = DataMap['GFS_SCORE'];	// GFS分數
			calData["NEW_VERSION"] = DataMap['NEW_VERSION'];//案件版本
			calData["LOAN_LIMIT_C"] = formatInput.getSplitValue($('LOAN_LIMIT_C').innerHTML, ",");;	// 區域放款率(表定放款率)
			calData["RENT"] = formatInput.getSplitValue($('RENT').innerHTML, ",");	// 租押金
			calData["APPR_AMT"] = formatInput.getSplitValue($('APPR_AMT').innerHTML, ",");	// 鑑估總值

			successAction = function(resp){
				var limit_Map = resp.limit_Map;
				if(limit_Map){
					// 放款率(承作成數)
					$('LOAN_LIMIT').innerHTML = formatInput.patternNumber(limit_Map.LOAN_LIMIT, false, formatInput.getPattern($('LOAN_LIMIT').intLength, $('LOAN_LIMIT').decLength, $('LOAN_LIMIT').zeroDec));

					// 可貸金額
					$('ABLE_AMT').innerHTML = formatInput.patternNumber(limit_Map.ABLE_AMT, false, formatInput.getPattern($('ABLE_AMT').intLength, $('ABLE_AMT').decLength, $('ABLE_AMT').zeroDec));
				}
			}
		}
		// 計算區域放款率
		else if(type == "3"){
			calData["AREA_CODE_930318"] = $('AREA_CODE_930318').innerHTML;	// 擔保品地區
			calData["VIP_ADD_RATE"] = $('VIP_ADD_RATE').innerHTML;	// 優質客戶加成
			calData["AREA_ADD_RATE"] = formatInput.getSplitValue($('AREA_ADD_RATE').innerHTML, ",");	// 區域加成條件
			calData["CRED_ADD_RATE"] = formatInput.getSplitValue($('CRED_ADD_RATE').innerHTML, ",");	// 債信指標調整
			calData["CRED_ADD"] = DataMap['CRED_ADD'];	// 債信等級
			calData["GFS_SCORE"] = DataMap['GFS_SCORE'];	// GFS分數
			calData["NEW_VERSION"] = DataMap['NEW_VERSION'];//案件版本
			calData["LOAN_LIMIT_C"] = formatInput.getSplitValue($('LOAN_LIMIT_C').innerHTML, ",");;	// 區域放款率(表定放款率)
			calData["RENT"] = formatInput.getSplitValue($('RENT').innerHTML, ",");	// 租押金
			calData["APPR_AMT"] = formatInput.getSplitValue($('APPR_AMT').innerHTML, ",");	// 鑑估總值
			calData["GAGE_USE"] = ($('GAGE_USE_1').checked) ? 1 : 0;	// 擔保品使用狀況

			successAction = function(resp){
				var limitC_Map = resp.limitC_Map;
				var limit_Map = resp.limit_Map;
				if(limitC_Map){

					if(limit_Map){//若債信等級(CRED_ADD)、GFS分數(GFS_SCORE)無值，則不計算
						// 放款率(承作成數)
						$('LOAN_LIMIT').innerHTML = formatInput.patternNumber(limit_Map.LOAN_LIMIT, false, formatInput.getPattern($('LOAN_LIMIT').intLength, $('LOAN_LIMIT').decLength, $('LOAN_LIMIT').zeroDec));

						// 可貸金額
						$('ABLE_AMT').innerHTML = formatInput.patternNumber(limit_Map.ABLE_AMT, false, formatInput.getPattern($('ABLE_AMT').intLength, $('ABLE_AMT').decLength, $('ABLE_AMT').zeroDec));
					}

					// 區域放款率(表定放款率)
					$('LOAN_LIMIT_C').innerHTML = formatInput.patternNumber(limitC_Map.LOAN_LIMIT_C, false, formatInput.getPattern($('LOAN_LIMIT_C').intLength, $('LOAN_LIMIT_C').decLength, $('LOAN_LIMIT_C').zeroDec));

					// 放款值
					$('LIMIT_AMT').innerHTML = formatInput.patternNumber(limitC_Map.LIMIT_AMT, false, formatInput.getPattern($('LIMIT_AMT').intLength, $('LIMIT_AMT').decLength, $('LIMIT_AMT').zeroDec));
				}
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
	//
	doAgree:function(){
		register.doTrimTextArea();
		var actionName = "agree";
		if(!validates.checkInput(actionName)){
			return;
		}
		if(!doUpdate1){
			alert("請先試算，再進行初核!");
			return false;				
		}
		var queryData = layout.getAllData();
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		ajaxPost(actionName, params, successAction);
	},
	doCancelAgree:function(){
		register.doTrimTextArea();
		var actionName = "cancelagree";
		if(!validates.checkInput(actionName)){
			return;
		}
		var queryData = layout.getAllData();
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
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
	//導頁至DSA2_1006
	doLinkToPDF:function(target){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID=" + $('APPLY_ID').innerHTML;
		window.open(url,target, "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
	//影像連結DSA0_0200
	/*doImage:function(){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID=" + $('APPLY_ID').innerHTML;
		window.open(url,target, "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}*/
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var length_Limit = {
	APPR_APPLY_ID:11,
	DEBT_APPLY_ID:11,
	TEL_APPLY_ID:11,
	LEADER_COMMENT:2000
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

			/*if(parent.form1){
				var qAPPLY_ID = parent.form1.APPLY_ID.value;
				if(qAPPLY_ID != APPLY_ID){
				 	alert('欲異動的受理編號: ' + qAPPLY_ID + ' 與原先查詢的 ' + APPLY_ID + ' 不同，請重新查詢!');
				 	return false;
				}
			}*/

			// 擔保品使用狀況 是否為買賣件 是否為保戶  餘額轉貸方案 房仲買賣專案件 
			validates.checkRadio("GAGE_USE IS_TRADE IS_INSU CRED_STATUS8 INSU_PRANK5", "", "");

			//---------- 字數與位數檢核 ----------
			// 鑑價報告編號, 償債能力分析表參照案件編號, 客戶資料照會表參照案件編號
			var keys = "APPR_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID";
			$w(keys).each(
				function(key){
					if(validates.isNotBlank(key, true)){
						var value = $(key).value;
						var maxLength = length_Limit[key];

						if(!checkIDLength(value, maxLength)){
							var msg = "字數必須等於" + maxLength;
							validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : msg}] , { useTitle: false });
						}
					}
				}
			);

			// 平均單價, 要保人年繳化保費, 保單可貸金額, 保單已貸金額, 一般型擬准金額, 理財型擬准金額, 一般型調整後利率
			validates.checkInput_M("AVG_PRICE TOTAL_PREMIUM LOAN_ABLE LOAN_REMAIN AGREE_AMT AGREE_AMT_M INTEREST", "", "", false);

			// 徵信說明
			var key = 'LEADER_COMMENT';
			if(validates.isNotBlank(key, true)){
				var newKey = "" + key + "";
				var maxLength = length_Limit[key];

				if(!validates.isTextAreaLengthLegal(newKey, maxLength)){
					var msg = "字數(中文佔2個字)為" + $(newKey).value.replace(twoBytesRegExp, "rr").length + "，已經超過上限" + maxLength;
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : msg}] , { useTitle: false });
				}
			}
			
			//區域加成條件選單
			if(validates.isBlank($F('AREA_ADD'), true)){
				validate4define.define( "customize_returnFalse" , [{ id :"AREA_ADD" , errMsg : "區域加成條件選單請選取有效選項!"}] , { useTitle: false });
			}

			
			
		}
		// 計算
		else if(action == "calculate"){
			var keyMap = {APPR_AMT:"鑑估總值", GAGE_AMT:"擔已貸金額", GAGE_AMT_M:"已生效理財型額度", RENT:"押金", VIP_ADD_RATE:"優質客戶加成", AREA_ADD_RATE:"區域加成條件", CRED_ADD_RATE:"債信指標調整", GFS_SCORE:"GFS分數", LOAN_LIMIT_C:"區域放款率(表定放款率)"};

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
		}else if(action=='agree'){
			validates.checkRadio("IS_INSU", "", "");
			if($('IS_INSU_1').checked){
				if($('TOTAL_PREMIUM').value=='0'||$('LOAN_ABLE').value=='0'){
					if(!confirm("請確認年繳化保費及保單可貸金額是否正確！")){
						return;
					}
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
					var intLength = $(newKey).intLength ? $(newKey).intLength : 0;
					var	decLength = $(newKey).decLength ? $(newKey).decLength : 0;
					var	numberType = $(newKey).numberType ? $(newKey).numberType : "5";

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
				$$('#body input[name="'+newKey+'"]').each(
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

				if(!checked){
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
			var intLength = $(key).intLength;
			var decLength = $(key).decLength ? $(key).decLength : 0;
			var pattern = $(key).pattern;
			var numberType = $(key).numberType;	// 1:大於0 2:大於等於0 3:小於等於0 4:小於0

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
		if($(key).checked){
			$('VIP_ADD_RATE').innerHTML = "+5";
		}else{
			$('VIP_ADD_RATE').innerHTML = "0";
		}
	},
	// 區域加成條件
	AREA_ADD_control:function(key){
		var value = $(key).value;

		if(value != "" && value != "1"){
			$('AREA_ADD_RATE').innerHTML = "+5";
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

		//「區域加成」下拉選單
		var AreaAdd_mapList =  resp ? resp.AreaAdd_mapList.evalJSON() : '${AreaAdd_mapList}'.evalJSON();
		AreaAdd_mapList = AreaAdd_mapList? AreaAdd_mapList:[];
		$('AREA_ADD').update();
		$w('AREA_ADD').each(
			function(key){
				selection.createAll(key, AreaAdd_mapList, "", "", "");
			}
		);
				
		oldValue.VIP_ADD = DataMap.VIP_ADD;
		oldValue.AREA_ADD = DataMap.AREA_ADD;
		oldValue.AREA_ADD_RATE = DataMap.AREA_ADD_RATE;
		oldValue.GAGE_USE = DataMap.GAGE_USE;
		auxiliary.dataInput(DataMap);
		
		//「區域加成」下拉選單 [失效項選取調整]
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

		// 載入資料後，要做的控制
		layout.VIP_ADD_control("VIP_ADD");
		layout.AREA_ADD_control("AREA_ADD");
		
		
		//房仲買賣專案件(資料若為’X’,則畫面無預設值)
		if(DataMap.INSU_PRANK5 == 'X'){
			$('INSU_PRANK5_0').checked = false;
			$('INSU_PRANK5_1').checked = false;			
		}
		
		//央行特定地區購屋貸款件(資料若為空白,則畫面無預設值)
		if(DataMap.SPEC_CHECK_990625 == undefined ||DataMap.SPEC_CHECK_990625 == '' ){
			$('SPEC_CHECK_990625_0').checked = false;
			$('SPEC_CHECK_990625_1').checked = false;			
		}
		
		//高價住宅購屋貸款件(資料若為空白,則畫面無預設值)
		if(DataMap.IS_MANSION == undefined ||DataMap.IS_MANSION == '' ){
			$('IS_MANSION_0').checked = false;
			$('IS_MANSION_1').checked = false;
		}
		//貸款期間全期不調整客戶等級 (資料若為空白,則畫面無預設值)
		if(DataMap.IS_FIX_VIPGRADE == undefined ||DataMap.IS_FIX_VIPGRADE == '' ){
			$('IS_FIX_VIPGRADE_0').checked = false;
			$('IS_FIX_VIPGRADE_1').checked = false;
		}
		
		//帳管費
		if($('IS_EXPENSE').checked){
			$('EXPENSE_AMT').disabled = false;
		}
		
		if(DataMap.TOTAL_PAGE=='0'){
			$('btn_image').disabled = true;
		}
	
	},
	// 取得畫面上的資料
	getAllData:function(){
		if(DataMap){
			// radio－房仲買賣專案件, 整批分戶件,餘額轉貸方案, 是否為買賣件, 本件為央行特定地區購屋貸款件 , 本件為高價住宅購屋貸款件, 是否為保戶
			$w('INSU_PRANK5_0 INSU_PRANK5_1 INSU_PRANK7_0 INSU_PRANK7_1 CRED_STATUS8_0 CRED_STATUS8_1 GAGE_USE_0 GAGE_USE_1 IS_TRADE_0 IS_TRADE_1 SPEC_CHECK_990625_0 SPEC_CHECK_990625_1 IS_MANSION_0 IS_MANSION_1 IS_INSU_0 IS_INSU_1 IS_FIX_VIPGRADE_0 IS_FIX_VIPGRADE_1 ').each(
				function(key){
					var radio = $(key);
					if(radio && radio.checked){
						DataMap[radio.name] = radio.value;
					}
				}
			);
			// checkbox－優質客戶加成, 繳息正常, 支存正常, 聯徵正常, 符合利害關係人授信作業規定, 符合保險業同一關係人、同一關係企業授信規定,是否需管理費
			$w('VIP_ADD CRED_STATUS1 CRED_STATUS2 CRED_STATUS3 CRED_STATUS9 CRED_STATUSA IS_EXPENSE').each(
				function(key){
					var checkbox = $(key);
					if(checkbox.checked){
						if(key=='VIP_ADD'){
							DataMap['VIP_ADD'] = checkbox.value;
							DataMap['VIP_ADD_RATE'] = checkbox.value;
						}else{
							DataMap[key] = checkbox.value;
						}
					}else{
						if(key=='VIP_ADD'){
							DataMap['VIP_ADD'] = '0';
							DataMap['VIP_ADD_RATE'] = 0;
						}else{
							DataMap[key] = 0;
						}
					}
				}
			);
			// 輸入－平均單價, 鑑價報告編號, 償債能力分析表參照案件編號, 客戶資料照會表參照案件編號, 一般型擬准金額, 理財型擬准金額, 要保人年繳化保費, 保單可貸金額, 一般型調整後利率, 保單已貸金額, 徵信說明, 帳管費
			$w('AVG_PRICE APPR_APPLY_ID DEBT_APPLY_ID TEL_APPLY_ID AGREE_AMT AGREE_AMT_M TOTAL_PREMIUM LOAN_ABLE INTEREST LOAN_REMAIN LEADER_COMMENT EXPENSE_AMT').each(
				function(key){
					DataMap[key] = $(key).getValue();
				}
			);
			// 下拉選單－區域加成條件, 實際用途, 業績A值
			$w('AREA_ADD REAL_USE A_VALUE').each(
				function(key){
					var value = $(key).value;
					if(value || Number(value)==0){
						if(key=='AREA_ADD'){
							//DataMap['AREA_ADD'] = value;
							DataMap['AREA_ADD_RATE'] = value;
						}else{
							DataMap[key] = value;
						}
					}
				}
			);
			// 顯示－放款率(承作成數), 可貸金額, 區域放款率, 放款值 ,擔累貸金額╱鑑估總值
			$w('LOAN_LIMIT ABLE_AMT LOAN_LIMIT_C LIMIT_AMT GA_RATE RENT INTEREST_C INTEREST_M').each(
				function(key){
					DataMap[key] = formatInput.getSplitValue($(key).innerHTML, ",");
				}
			);
			return DataMap;
		}else{
			return {};
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
					if (element) {
						var tagType = element.tagName;
						if ( tagType != null) {
							tagType = trim(tagType).toLocaleLowerCase();
							var datatype = element.getAttribute("datatype");	// 自訂的型態(可能需要format)
							var pattern = element.getAttribute("pattern");		// 自訂的format格式

							if (tagType == 'div' || tagType == 'span' || tagType == 'td') {
								value = auxiliary.trim(value, datatype, pattern, key);
								element.update( value );
							} else {
								var type = element.type;
								if (type == 'checkbox' || type == 'radio') {
									var objs = document.getElementsByName(key);
									for (var j=0; j<objs.length; j++) {
										if (objs[j].value == value) {
											objs[j].checked = true;
										}else if(type == 'checkbox'){
											objs[j].checked = false;
										}
									}
								}else {
									var tmpNum = auxiliary.trim(value, datatype, pattern, key);
									element.setValue(tmpNum);
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
			return formatInput.patternNumber(v, false, formatInput.getPattern($(key).intLength, $(key).decLength, $(key).zeroDec));
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
		var input = tableElement.createElement("input", config);

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
			key.each(function(key){
				var attribute = config[key];
				if(attribute){
					element.setAttribute(key, attribute);
				}
			});
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
		func_id = "DSA2_1009";
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

</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	
	<%-- 區塊 A --%>
		<table id="area_A" name="area_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align="center" colspan="6" class="tbYellow">
					<input id="btn_update1" name="btn_update1" type="button" class="button" value="試算">
					<input id="btn_agree" name="btn_agree" type="button" class="button" value="初核同意">
					<input id="btn_cancelagree" name="btn_cancelagree" type="button" class="button" value="初核同意取消">
					<input id="btn_image" name="btn_image" type="button" class="button" value="影像連結">
					<input id="btn_DSA21006" type="button" class="button" value="不動產明細">
				</td>
			</tr>
		</table>

	<%-- 區塊 B --%>
	<table id="area_B_1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		
		<tr>
			<td class="tbYellow" width="20%">
				受理編號
			</td>
			<td class="tbYellow2" width="30%">
				<span id="APPLY_ID"></span>　<span id="IS_FAST_AGREE" style="color:red"></span><%-- 是否快速審核件 --%>
			</td>
			<td class="tbYellow" width="20%">
				借款人姓名
			</td>
			<td class="tbYellow2" width="30%">
				<span id="BORROW_NAME"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				受理進度
			</td>
			<td class="tbYellow2">
				<span id="APPLY_PROCESS_NM"></span>
			</td>
			<td class="tbYellow">
				批示進度
			</td>
			<td class="tbYellow2">
				<span id="AGREE_PROCESS_NM"></span>
			</td>
		</tr>
	</table>
	<table id="area_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
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
			<td class="tbBlue" colspan="2" rowspan="20" valign="top">
				<table width="100%" cellspacing="1" class="tbBox2">
					<tr>
						<td class="tbBlue">
							房仲買賣專案件
						</td>
						<td class="tbBlue2">
							<input id="INSU_PRANK5_0" name="INSU_PRANK5" fieldName="房仲買賣專案件" type="radio" value="0" checked><span>否</span>
							<input id="INSU_PRANK5_1" name="INSU_PRANK5" fieldName="房仲買賣專案件" type="radio" value="1"><span>是</span>
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
							<span>2.優質客戶加成</span><input id="VIP_ADD" name="VIP_ADD" fieldName="優質客戶加成" type="checkbox" value="1"><span>：</span><span id="VIP_ADD_RATE"></span><br/>
							<span>3.區域加成條件</span><span>：</span><span id="AREA_ADD_RATE"></span><br/>
							<select id="AREA_ADD" style="width:120px" fieldName="區域加成條件"></select>
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							擔累貸金額╱鑑估總值
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
							業績A值
						</td>
						<td class="tbBlue2">
							<select id="A_VALUE" fieldName="業績A值"></select>
						</td>
					</tr>
					<tr>
						<td class="tbBlue" colspan="2">
							利率
						</td>			
					</tr>
					<tr>
						<td class="tbBlue2" colspan="2" rowspan="2" valign="top">
							一般型表定利率： <span id="INTEREST_C" datatype="number" intLength="2" decLength="4"></span>&nbsp;%<br/>
							理財型表定利率：<span id="INTEREST_M" datatype="number" intLength="2" decLength="4"></span>&nbsp;%<br/>
							(一般型調整後利率)：<input id="INTEREST" name="INTEREST" fieldName="一般型調整後利率" type="text" class="textBox2" datatype="number" intLength="2" decLength="4" pattern ="##.####" size="10" maxlength="7" value="">%<br/>
							理財型帳號設定：<span id="ACCOUNT_STATUS_NM"></span>
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
				償債能力分析表<br/>參照案件編號
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
				<span id="ASSESS_APPLY_ID"></span>
			</td>
			<td class="tbYellow">
				買賣件查證事項或 <br/>客戶資料照會表<br/>參照案件編號
			</td>
			<td class="tbYellow2">
				<input id="TEL_APPLY_ID" name="TEL_APPLY_ID" fieldName="客戶資料照會表參照案件編號" type="text" class="textBox2" size="15" maxlength="11" value="">
				<input id="btn_link2" name="btn_link2" type="button" class="button" value="進入">
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
				主要建材
			</td>
			<td class="tbYellow2">
				<span id="MATERIAL_NM"></span>
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
				建築型態
			</td>
			<td class="tbYellow2">
				<span id="BUILD_TYPE_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				押金
			</td>
			<td class="tbYellow2">
				<span id="RENT" pattern ="#,###.##" intLength="7" decLength="2"></span>&nbsp;<span>元</span>
			</td>
			<td class="tbYellow">
				主要用途
			</td>
			<td class="tbYellow2">
				<span id="MAIN_USE_NM"></span>
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
				已生效理財型額度
			</td>
			<td class="tbYellow2">
				<span id="GAGE_AMT_M" datatype="number" intLength="11"></span>&nbsp;<span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				實際用途
			</td>
			<td class="tbYellow2">
				<select id="REAL_USE" fieldName="實際用途"></select>
			</td>
			<td class="tbYellow">
				區域放款率
			</td>
			<td class="tbYellow2">
				<span id="LOAN_LIMIT_C" datatype="number" intLength="3" decLength="2"></span>&nbsp;<span>%</span>　<span id="AREA_CODE_930318" style="color:red"></span>&nbsp;<span style="color:red">區</span><br/>
				<span id="GAGE_USE_radio"></span>
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
				優質等級
			</td>
			<td class="tbYellow2">
				<span id="VIP_GRADE_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				本件為高價住宅購屋貸款件
			</td>
			<td class="tbYellow2">
				<input id="IS_MANSION_0" name="IS_MANSION" fieldName="本件為高價住宅購屋貸款件" type="radio" value="0" checked><span>否</span>
				<input id="IS_MANSION_1" name="IS_MANSION" fieldName="本件為高價住宅購屋貸款件" type="radio" value="1"><span>是</span>
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
				是否為買賣件
			</td>
			<td class="tbYellow2">
				<input id="IS_TRADE_0" name="IS_TRADE" fieldName="是否為買賣件" type="radio" value="0" checked><span>否</span>
				<input id="IS_TRADE_1" name="IS_TRADE" fieldName="是否為買賣件" type="radio" value="1"><span>是</span>
			</td>	
			<td class="tbYellow">
				本件為央行特定地區購屋貸款件
			</td>
			<td class="tbYellow2">
				<input id="SPEC_CHECK_990625_0" name="SPEC_CHECK_990625" fieldName="本件為央行特定地區購屋貸款件" type="radio" value="0" checked><span>否</span>
				<input id="SPEC_CHECK_990625_1" name="SPEC_CHECK_990625" fieldName="本件為央行特定地區購屋貸款件" type="radio" value="1"><span>是</span>
			</td>	             
		</tr>
		<tr>
			<td class="tbYellow" colspan="2">
				徵信狀況
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
			<td class="tbYellow2" colspan="2" rowspan="5" valign="top">
				<input id="CRED_STATUS1" name="CRED_STATUS1" fieldName="繳息正常" type="checkbox" value="1"><span>繳息正常</span><br/>
				<input id="CRED_STATUS2" name="CRED_STATUS2" fieldName="支存正常" type="checkbox" value="1"><span>支存正常</span><br/>
				<input id="CRED_STATUS3" name="CRED_STATUS3" fieldName="聯徵正常" type="checkbox" value="1"><span>聯徵正常</span><br/>
				<input id="CRED_STATUS9" name="CRED_STATUS9" fieldName="符合利害關係人授信作業規定" type="checkbox" value="1"><span>符合利害關係人授信作業規定</span><br/>
				<input id="CRED_STATUSA" name="CRED_STATUSA" fieldName="符合保險業同一關係人、同一關係企業授信規定" type="checkbox" value="1"><span>符合保險業同一關係人、同一關係企業授信規定</span>
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
				保單可貸金額
			</td>
			<td class="tbYellow2">
				<input id="LOAN_ABLE" name="LOAN_ABLE" fieldName="保單可貸金額" type="text" class="textBox2" datatype="number" intLength="6" decLength="2" pattern ="#,###.##" size="10" maxlength="11" value=""><span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				保單已貸金額
			</td>
			<td class="tbYellow2">
				<input id="LOAN_REMAIN" name="LOAN_REMAIN" fieldName="保單已貸金額" type="text" class="textBox2" datatype="number" intLength="6" decLength="2" pattern ="#,###.##" size="10" maxlength="11" value=""><span>萬</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="2">
				<span>組長：</span><span id="LEADER_NAME"></span><span>　</span>
				<span>作業日期：</span><span id="LEADER_DATE" datatype="ROCdate"></span><br/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="2">
				組長批示：<br>
				<textarea id="LEADER_COMMENT" name="LEADER_COMMENT" fieldName="組長批示" rows="8" cols="60"></textarea>
			</td>
		</tr>
	</table>
</body>
</html>