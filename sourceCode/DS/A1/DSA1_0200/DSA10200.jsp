<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description Author
    2011/8/25   1.0     Created     柯玉芳

    UCDSA10200_借款資料輸入

    程式功能概要說明：
    程式功能　借款資料輸入
    程式名稱　DSA1_0200
    作業方式　ONLINE
    概要說明　(1) 查詢-依輸入的受理編號查詢借款明細資料。
　　　　　　　(2) 新增–新增該受理編號之借款基本資料、目前經營事業、目前服務單位、前職單位、個人(含配偶)全年收支情形、本人其他不動產暨設定明細。
　　　　　　　(3) 修改–修改所選之借款相關資料:基本資料、目前經營事業、目前服務單位、前職單位、個人(含配偶)全年收支情形、本人其他不動產暨設定明細。
　　　　　　　(4) 刪除–刪除所選之借款相關資料:基本資料、目前經營事業、目前服務單位、前職單位、個人(含配偶)全年收支情形、本人其他不動產暨設定明細。
　　　　　　　(5) 變更-將保證人改為借款人，異動相關TABLE
    系統別　SYS_NO = DS
    按鈕授權　FUNC_ID = DSA10200
    郵遞區號與地址輸入　方式同DSZ09101取得地址、清除

	@author 楊宗翰
	@since 2011-09-06
	
	[20191216] 修改件：
               申請書190829001411-法金專案(受理) : 
               (1) 欄位名稱調整
               (2) 新增欄位「註冊國家」

[20220714]修改件
配合行動房貸APP調整及自動徵審專案，增加系統欄位及資料寫入規則。
郭曉慧               

[20221121]
[申請書:221102005585]行動房貸送件年齡與資料保存時間調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/date.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/comm.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/Validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/utility.js"></script>
<script type="text/JavaScript" src="${htmlBase}/DS/js/DSZ01000.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script><%-- 搜尋提示用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
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
<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//---------- 下拉選單(start) ----------
// 「保人戶籍地址碼」、「戶籍地址碼」、「目前經營事業-事業處所碼」、「目前服務單位-詳細地址碼」
var BUSS_CODE_List;

// 「目前經營事業-區碼」、「目前服務單位-區碼」
var TEL_AREA_List;

// 「目前經營事業-營業處所使用情形」
var USE_STATUS_A021_List;

// 「本人其他不動產暨設定明細-使用情形」
var USE_STATUS_A023_List;

// 「目前服務單位-身分別」
var WORK_TYPE_List;

// 「目前經營事業-行業別」
var A021_BUSINESS_CODE_List;

// 「目前經營事業-職業類別」
var A021_OCCU_CODE_List;

// 「目前服務單位-行業別」
var A022_BUSINESS_CODE_List;

// 「目前服務單位-職業類別」
var A022_OCCU_CODE_List;

//建議清單：國家
var COUNTRY_List;

//---------- 下拉選單(end) ----------

// 取得地址的種類
var address_Map = {A:null, B1:null, B2:null, C:{}, D:{}};

// 地址輸入不檢核的欄位
var notCheck = {
	CITY_NAME:"CITY_NAME",
	TOWN_NAME:"TOWN_NAME",
	ROAD_NAME:"ROAD_NAME",
	ADDR_NAME:"ADDR_NAME"
};
//擔保品種類
var GAGE_TYPE = '';

// B區狀態
var B_type;

// 多筆區塊的最大與正在異動的索引值
var MaxIndex = {C:0, D:0, G:0};	// 目前最大的index
var UpdateIndex = {C:null, D:null, G:null};	// 正在操作的index

var DSA020;

// 檢核
var isFori = false; //是否為外幣件
var validate4define;
var APPLY_DATE;
var A_ID_Map;
var isCORP_DEPT;/* [20191216] 法金專案 */

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)
var pattern_money = "#,###";	// 金額格式(無小數)
var pattern_money2 = "#,###.##";	// 金額格式(小數2位)

var USE_STATUS_Map = {
	B1_USE_STATUS:"B1_USE_STATUS_CONTENT",
	B2_USE_STATUS:"B2_USE_STATUS_CONTENT"
};
var MARRY_Map = {
	B1_MARRY:"B1_SPOUSE_NAME"
};

//全形轉半形
var hForm = [" ","`","1","2","3","4","5","6","7","8","9","0","-","=","\\","!","@","#","$","%","^","&","*","(",")","_","+","|","[","]","{","}",";","'",":","\"",",",".","/","<",">","?","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
var fForm = ["　","、","１","２","３","４","５","６","７","８","９","０","－","＝","﹨","！","＠","＃","＄","％","︿","＆","＊","（","）","＿","＋","｜","〔","〕","｛","｝","；","’","：","”","，","。","∕","＜","＞","？","ａ","ｂ","ｃ","ｄ","ｅ","ｆ","ｇ","ｈ","ｉ","ｊ","ｋ","ｌ","ｍ","ｎ","ｏ","ｐ","ｑ","ｒ","ｓ","ｔ","ｕ","ｖ","ｗ","ｘ","ｙ","ｚ","Ａ","Ｂ","Ｃ","Ｄ","Ｅ","Ｆ","Ｇ","Ｈ","Ｉ","Ｊ","Ｋ","Ｌ","Ｍ","Ｎ","Ｏ","Ｐ","Ｑ","Ｒ","Ｓ","Ｔ","Ｕ","Ｖ","Ｗ","Ｘ","Ｙ","Ｚ"];


//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0003:'A_btn_add',<%--新增--%>
		B0004:'A_btn_update',<%--修改--%>
		B0005:'A_btn_delete',<%--刪除--%>
		B0054:'A_btn_change'<%--變更--%>
	};
	<dz:grantButtons FUNC_ID="DSA10200" ignored="false"/>
}

function initApp(){
	// 日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();
	<cathay:LocaleDisplay sysCode='DS' dateFields='B1_QUERY_DATE_S B1_QUERY_DATE_E B2_QUERY_DATE_S B2_QUERY_DATE_E' var='localeDisplay' />
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
		[ 'threeMonthInterval', '[查調公務機關授權]之[授權起迄日]區間限三個月內'
			, function(date_str , date_end) {
				
				if(!Validation.get('IsEmpty').test(date_str) && !Validation.get('IsEmpty').test(date_end)){	
		//確認有輸入
					if(isROCdate(date_str)){
						return !(diffDayROC(date_str, date_end) > 92);
					}else{
						return !(diffDayY2K(date_str, date_end) > 92);
					}
				}
				return true;
			}
		],

		[ 'validationAPPLY_ID',  '受理編號有誤，請檢查後重新輸入!', 
			function(v){ 
				<%--受理編號：11英數字+@--%>
				return v.length == 11 && (/^[a-zA-Z0-9@]+$/.test(v)); 
			} 
		]
	]);

	new UI().init();
}

function UI(){
	return {
		init:function() {
			displayMessage();

			PageUI.createPageWithAllBodySubElement("DSA10200" , "受理作業" , "借款資料輸入", 1);
	
			// 儲存各地址輸入的物件
            address_Map["A"] = new DSZ01000("A_DSZ01000", "2", 80);
            address_Map["B1"] = new DSZ01000("B1_DSZ01000", "2", 80);
            address_Map["B2"] = new DSZ01000("B2_DSZ01000", "2", 80);
			
			//---------- 載入下拉選單 ----------
			// 「保人戶籍地址碼」、「戶籍地址碼」、「目前經營事業-事業處所碼」、「目前服務單位-詳細地址碼」下拉選單
			<c:if test="${not empty BUSS_CODE_List}">
				BUSS_CODE_List = ${BUSS_CODE_List};

				$w('A_CHG_REG_CODE B1_REG_CODE B2_REG_CODE').each(
					function(key){
						selection.createAll(key, BUSS_CODE_List);
					}
				);
			</c:if>

			// 「保人戶籍地址所有人」、「戶籍所有人」下拉選單
			<c:if test="${not empty GAGE_CODE_List}">
				var GAGE_CODE_List = ${GAGE_CODE_List};

				$w('A_CHG_REG_OWNER B1_REG_OWNER B2_REG_OWNER').each(
					function(key){
						selection.createAll(key, GAGE_CODE_List);
					}
				);
			</c:if>

			// 「通訊地址使用狀況」下拉選單
			<c:if test="${not empty CON_STATUS_List}">
				var CON_STATUS_List = ${CON_STATUS_List};

				$w('B1_USE_STATUS B2_USE_STATUS').each(
					function(key){
						selection.createAll(key, CON_STATUS_List, " ");
					}
				);
			</c:if>

			// 「目前經營事業-區碼」、「目前服務單位-區碼」下拉選單
			<c:if test="${not empty TEL_AREA_List}">
				TEL_AREA_List = ${TEL_AREA_List};
			</c:if>

			// 「學歷」下拉選單
			<c:if test="${not empty DEGREE_List}">
				var DEGREE_List = ${DEGREE_List};

				$w('B1_DEGREE').each(
					function(key){
						selection.createAll(key, DEGREE_List);
					}
				);
			</c:if>

			// 「婚姻狀況」下拉選單
			<c:if test="${not empty MARRY_List}">
				var MARRY_List = ${MARRY_List};

				$w('B1_MARRY').each(
					function(key){
						selection.createAll(key, MARRY_List);
					}
				);
			</c:if>

			// 「婚姻狀況-存歿」下拉選單
			<c:if test="${not empty SPOUSE_LIVE_List}">
				var SPOUSE_LIVE_List = ${SPOUSE_LIVE_List};

				$w('B1_SPOUSE_LIVE').each(
					function(key){
						selection.createAll(key, SPOUSE_LIVE_List);
					}
				);
			</c:if>

			// 「子女人數」下拉選單
			<c:if test="${not empty SON_NO_List}">
				var SON_NO_List = ${SON_NO_List};

				$w('B1_SON_NO B1_GIRL_NO').each(
					function(key){
						selection.createAll(key, SON_NO_List);
					}
				);
			</c:if>

			// 「檢附相關文件」下拉選單
			<c:if test="${not empty DOCS_CODE_List}">
				var DOCS_CODE_List = ${DOCS_CODE_List};
				var length = DOCS_CODE_List.length;

				$w('B1_DOCS B2_DOCS').each(
					function(key){
						var target = $(key);
						var preKey = key.split("_")[0];
						for(var i = 0; i < length; i++){
							var CODE = DOCS_CODE_List[i].CODE;
							var CODE_NM = DOCS_CODE_List[i].CODE_NM;

							var id = key + "_" + CODE;
							var config = {
								id:id,
								name:key,
								fieldName:"檢附相關資料",
								type:'checkbox',
								value:CODE
							};
							var input = tableElement.createElement("input", config);
							<%-- [20181210] 設定 onclick 事件 --%>
							input.onclick = function(){
								if(this.value == "A"){
									// 無->其他checkbox disable
									if(this.checked){
										CSS_Selectors.doActionWhenGetElement($$('#'+key+' input'), {'name':this.name}, 
											function(obj){
												if(obj.value != "A"){
													obj.checked = false;
													obj.disable();
												}
											}
										);
										/*$$('#' + key +' input[name="' + this.name + '"]').each(
											function(obj){

												if(obj.value != "A"){
													obj.checked = false;
													obj.disable();
												}
											}
										);*/

										$(preKey + '_DOCS_CONTENT').value = "";
										$(preKey + '_DOCS_CONTENT').disable();
									}else{
										CSS_Selectors.doActionWhenGetElement($$('#'+key+' input'), {'name':this.name}, 
											function(obj){
												if(obj.value != "A"){
													obj.enable();
												}
											}
										);
										/*$$('#' + key +' input[name="' + this.name + '"]').each(
											function(obj){
												if(obj.value != "A"){
													obj.enable();
												}
											}
										);*/
									}
								}else if(this.value == "F"){
									// 其他->輸入框可輸入
									if(this.checked){
										$(preKey + '_DOCS_CONTENT').enable();
									}else{
										$(preKey + '_DOCS_CONTENT').value = "";
										$(preKey + '_DOCS_CONTENT').disable();
									}
								}
							}
							target.appendChild(input);
							var textNode = document.createTextNode(CODE_NM);
							target.appendChild(textNode);							
						}
					}
				);
			</c:if>

			// 「目前經營事業-營業處所使用情形」下拉選單
			<c:if test="${not empty USE_STATUS_A021_List}">
				USE_STATUS_A021_List = ${USE_STATUS_A021_List};
			</c:if>

            // 「目前經營事業-行業別」下拉選單
			<c:if test="${not empty A021_BUSINESS_CODE_List}">
				A021_BUSINESS_CODE_List = ${A021_BUSINESS_CODE_List};
			</c:if>
			
            // 「目前經營事業-職業類別」下拉選單
            <c:if test="${not empty A021_OCCU_CODE_List}">
				A021_OCCU_CODE_List = ${A021_OCCU_CODE_List};
			</c:if>
			
			// 「目前服務單位-身分別」下拉選單
			<c:if test="${not empty WORK_TYPE_List}">
				WORK_TYPE_List = ${WORK_TYPE_List};
			</c:if>

			// 「本人其他不動產暨設定明細-使用情形」下拉選單
			<c:if test="${not empty USE_STATUS_A023_List}">
				USE_STATUS_A023_List = ${USE_STATUS_A023_List};
			</c:if>
			
			// 「目前服務單位-行業別」下拉選單
			<c:if test="${not empty A022_BUSINESS_CODE_List}">
				A022_BUSINESS_CODE_List = ${A022_BUSINESS_CODE_List};
			</c:if>
			
            // 「目前服務單位-職業類別」下拉選單
            <c:if test="${not empty A022_OCCU_CODE_List}">
				A022_OCCU_CODE_List = ${A022_OCCU_CODE_List};
			</c:if>
			
			<%-- [20191216] 註冊國家 suggest --%>
			//建議清單：國家
            <c:if test="${not empty COUNTRY_List}">
				COUNTRY_List = ${COUNTRY_List};
			</c:if>
		
			//--------- 註冊按鈕 ----------
			// 查詢
			$("A_btn_query").observe('click',function(event){
				buttons.doQuery();
			});

			// 變更
			$("A_btn_change").observe('click',function(event){
				buttons.doChange();
			});

			// 清除
			$("A_btn_clear").observe('click',function(event){
				buttons.doClear();
			});

			// 新增
			$w('A_btn_add C_btn_add D_btn_add G_btn_add').each(
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
						var preKey = key.substring(0, 1);
						buttons.doUpdate(preKey);
					});
				}
			);

			// 刪除
			$w('A_btn_delete C_btn_delete D_btn_delete G_btn_delete').each(
				function(key){
					$(key).observe('click', function(event){
						var preKey = key.substring(0, 1);
						buttons.doDelete(preKey);
					});
				}
			);

			// 更換借款人改變
			$w('A_ID').each(
				function(key){
					$(key).observe('change', function(event){
						layout.changeID();
					});
				}
			);

			//--------- 註冊事件 ----------
			// A
			register.textNoSpace('A_APPLY_ID', "upper");

			// B1
			register.textNoSpace('B1_USE_STATUS_CONTENT B1_SCHOOL B1_DEPARTMENT B1_SPOUSE_NAME B1_DOCS_CONTENT B1_COUNTRY_NM B1_COUNTRY');

			// B2
			register.textNoSpace('B2_USE_STATUS_CONTENT B2_SPOUSE_NAME B2_DOCS_CONTENT B2_COUNTRY_NM B2_COUNTRY');

			// E
			register.textNoSpace('E_BUSS_ITEM');
			register.textNoSpace('E_SERV_NAME E_JOB_TITLE');
			register.isNumber('E_SERV_YEAR');
			register.isPatternNumber('E_YEAR_INCOME');

			// F
			register.textNoSpace('F_OTHER_CONTENT');
			register.isPatternNumber('F_REF_TIMES F_REPAIR_TIMES F_INCOME F_HOME_EXP F_OTHER_INCOME F_OTHER_EXP');

			// 重新計算合計－收入
			$w('F_INCOME F_OTHER_INCOME').each(
				function(key){
					$(key).observe('blur', function(event){
						layout.reCalculateTotal('F_INCOME_TOTAL');
					});
				}
			);

			// 重新計算合計－支出
			$w('F_HOME_EXP F_OTHER_EXP').each(
				function(key){
					$(key).observe('blur', function(event){
						layout.reCalculateTotal('F_EXP_TOTAL');
					});
				}
			);

			// 支存狀況控制
			$w('F_CHK_NOR F_CHK_REJ F_CHK_REF F_REPAIR F_OTHER').each(
				function(key){
					$(key).observe('click', function(event){
						layout.control("F", key);
					});
					layout.control("F", key);
				}
			);

			// if「戶籍地址碼」下拉選單選擇 “其他如下”，則為輸入欄位
			$w('A_CHG_REG_CODE B1_REG_CODE B2_REG_CODE').each(
				function(key){
					$(key).observe('change', function(event){
						var type = key.split("_")[0];
						if($(key).value == "9"){
							address_Map[type].displayOnly(false);
						}else{
							address_Map[type].displayOnly(true);
							address_Map[type].display4INPUT_ZIPCODE(false);
							address_Map[type].display4INPUT_ADDR(false);
							address_Map[type].setCITY_NAME("");
							
						}
					});
				}
			);

			// if「通訊地址使用狀況」下拉選單選擇 “其他”，則為輸入欄位
			$w('B1_USE_STATUS B2_USE_STATUS').each(
				function(key){
					$(key).observe('change', function(event){
						if($(key).value == "9"){
							$(USE_STATUS_Map[key]).show();
						}else{
							$(USE_STATUS_Map[key]).value = "";
							$(USE_STATUS_Map[key]).hide();
						}
					});
				}
			);

			// if「婚姻狀況」下拉選單選擇 “已婚”，則為輸入欄位(目前是任何情況皆無法修改!!!)
			$w('B1_MARRY').each(
				function(key){
					$(key).observe('change', function(event){
						<%-- [20220714]已婚->配偶姓名必輸值 --%>
						if($(key).value == "1"){
							$(MARRY_Map[key]).enable();
						}else{
							<%-- [20220714]補配偶姓名清空 --%>
							$(MARRY_Map[key]).setValue('');
							$(MARRY_Map[key]).disable();
						}
					});
				}
			);
			
			<%-- [20191216] 註冊國家 suggest --%>	
			$w('B1_COUNTRY_NM B2_COUNTRY_NM').each(function(id){
				var hiddenEleId = id.replace('_NM','');
				Suggest.add( 
					id,      
					Suggest.LIST,
					COUNTRY_List, 
					{ 				
						noCookies : false,
						option_key : "COUNTRY_NM", 
						remark_key : "COUNTRY", 							
						startLength : 2,
						callBackFunc : function(node,rec){						
							$(hiddenEleId).value = rec ? rec['COUNTRY'] : '';
						}
					}
				);	
			});

			// 設定其他連動欄位的狀態
			layout.setInitSelect();

			if ('${APPLY_ID}' != "") {
				$('A_APPLY_ID').value = '${APPLY_ID}';
			} else {
				// 保留參數管理-取得受理編號
				$('A_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}
			if($('A_APPLY_ID').value){
				buttons.doQuery();
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
		var actionName = "query";
		if(!validates.checkInput(actionName)){
			return;
		}

		// 保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('A_APPLY_ID').value});
		var queryData = {
			APPLY_ID: $('A_APPLY_ID').value
		};

		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(resp){
			layout.loadData(resp);
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 變更
	doChange:function(){
		var actionName = "change";
		if(!validates.checkInput(actionName)){
			return;
		}

		var preKey;
		if(B_type == "0"){
			preKey = "B1_";
		}else{
			preKey = "B2_";
		}

		var queryData = {
			APPLY_ID: $(preKey + 'APPLY_ID').innerHTML,
			BORROW_ID: $(preKey + 'ID').innerHTML,
			CHG_ID: $('A_ID').value,
			CHG_REG_CODE: $('A_CHG_REG_CODE').value,
			CHG_REG_ZIP: address_Map["A"].getINPUT_ZIPCODE(),
			CHG_REG_ADDR: address_Map["A"].getINPUT_ADDR(),
			CHG_REG_OWNER: $('A_CHG_REG_OWNER').value
		};
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			layout.loadData(resp);
		};
		var errorAction = function(){};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 清除
	doClear:function(){
		layout.clear4Query();	// B~G回復初始狀態
	},
	// 新增
	doAdd:function(type){
		var actionName = "add";
		if(!validates.checkInput(actionName, type)){
			return;
		}
		
		if(type == "A"){
			var data = auxiliary.getAllData(actionName, type);
			if(data === false){
				return;
			}
			
			var params = {
				"DSA020_VO":Object.toJSON(data['DSA020_VO']), 
				"DSA021_VOList":Object.toJSON(data['DSA021_VOList']),
				"now_DSA022_VOList":Object.toJSON(data['now_DSA022_VOList']),
				"before_DSA022_VO":Object.toJSON(data['before_DSA022_VO']),
				"DSA023_VOList":Object.toJSON(data['DSA023_VOList'])
			};
			
			var successAction = function(resp){
				layout.loadData(resp);
			};
			var errorAction = function(resp){};
			ajaxPost(actionName, params, successAction, errorAction);
		}else {
			if(type == "C"){
				layout.create_CBlock();
			}if(type == "D"){
				layout.create_DBlock();
			}else if(type == "G"){
				layout.create_GBlock();
			}
		}
	},
	// 修改
	doUpdate:function(type){
		var actionName = "update";

		if(type == "A"){
			if(!validates.checkInput(actionName, type)){
				return;
			}

			var data = auxiliary.getAllData();
			
			var params = {
				"DSA020_VO":Object.toJSON(data['DSA020_VO']),
				"DSA021_VOList":Object.toJSON(data['DSA021_VOList']),
				"now_DSA022_VOList":Object.toJSON(data['now_DSA022_VOList']),
				"before_DSA022_VO":Object.toJSON(data['before_DSA022_VO']),
				"DSA023_VOList":Object.toJSON(data['DSA023_VOList'])
			};
			var successAction = function(resp){
				layout.loadData(resp);
			};
			var errorAction = function(resp){};
			ajaxPost(actionName, params, successAction, errorAction);
		}
	},
	// 刪除
	doDelete:function(type){
		var actionName = "delete";
		if(type == "A"){
			if(!validates.checkInput(actionName, type)){
				return;
			}

			var preKey;
			if(B_type == "0"){
				preKey = "B1_";
			}else{
				preKey = "B2_";
			}
			var queryData = {
				APPLY_ID: $(preKey + 'APPLY_ID').innerHTML,
				ID: $(preKey + 'ID').innerHTML
			};

			var params = {"queryData":Object.toJSON(queryData)};
			var successAction = function(resp){
				layout.loadData(resp);
			};
			var errorAction = function(resp){};
			ajaxPost(actionName, params, successAction, errorAction);
		}else {
			layout.deleteData_fromXBlock(type);
		}
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var validates = {
	// 畫面欄位
	checkInput:function(actionName, type){
		validate4define.clear();	// 清define
		validate4define.reset();	// 清背景色
		
		// 查詢
		if(actionName == "query"){
			validates.checkInput_C('APPLY_ID', "A_");
		}
		// 變更
		else if(actionName == "change"){
			validates.checkInputA();
		}
		// 新增
		else if(actionName == "add"){
			
			if(type == "A"){
				if(!validates.checkInputB("新增")){
					return false;
				}

				validates.checkInputC();
				if(!validates.checkInputD()){
					return false;
				}
				validates.checkInputE();
				validates.checkInputF();
				validates.checkInputG();
			}
			// C, D, G新增
			else if(type == "C" || type == "D" || type == "G"){
				if(!validates.checkInputB("新增", true)){
					return false;
				};
			}
		}
		// 修改
		else if(actionName == "update"){

			if(type == "A"){
				if(!validates.checkInputB("修改")){
					return false;
				}

				validates.checkInputC();
				if(!validates.checkInputD()){
					return false;
				}
				validates.checkInputE();
				validates.checkInputF();
				validates.checkInputG();
			}
		}
		// 刪除
		else if(actionName == "delete"){
			if(type == "A"){
				if(!validates.checkInputB("刪除", true)){
					return false;
				}
			}
		}

		return validate4define.validate();
	},
	// 檢查A
	checkInputA:function(){
		var key;
		if(B_type === "0"){
			key = 'B1_APPLY_ID';
		}else{
			key = 'B2_APPLY_ID';
		}

		var B_APPLY_ID = formatInput.text($(key).innerHTML, false);

		if(validates.isBlank(B_APPLY_ID, false)){
			validate4define.define( "customize_returnFalse" , [{ id :"A_APPLY_ID" , errMsg : "請先查詢再做變更"}] , { useTitle: false });
		}

		var checkKey = "A_ID";
		if(validates.isBlank(checkKey)){
			validate4define.define( "customize_returnFalse" , [{ id :checkKey , errMsg : "請先選擇欲更換的保證人ID"}] , { useTitle: false });
		}

		validates.checkSelect("CHG_REG_CODE", "A_", "", true, "0");
		validates.checkSelect("CHG_REG_OWNER", "A_", "", true);

		address_Map["A"].checkData(validate4define, notCheck, "保人戶籍");
	},
	// 檢查B
	checkInputB:function(action, onlyAPPLY_ID, onlyID){
		var preKey;
		var postKey = "";

		if(B_type === "0"){
			preKey = 'B1_';
		}else{
			preKey = 'B2_';
		}
		
		var B_APPLY_ID = $(preKey + 'APPLY_ID').innerHTML;
		if(validates.isBlank(B_APPLY_ID, false)){
			alert("基本資料無受理編號，無法" + action);
			return false;
		}

		if(!onlyAPPLY_ID){
			var B_ID = $(preKey + 'ID').innerHTML;
			if(validates.isBlank(B_ID, false)){
				alert("基本資料無統一編號，無法" + action);
				return false;
			}
		}

		if(!onlyAPPLY_ID && !onlyID){
			// 自然人
			if(B_type === "0"){
				var B1_NAME = $('B1_NAME').innerHTML;
				if(validates.isBlank(B1_NAME, false)){
					alert("基本資料無姓名，無法" + action);
					return false;
				}

				var B1_BIRTHDAY = $('B1_BIRTHDAY').innerHTML;
				if(validates.isBlank(B1_BIRTHDAY, false)){
					alert("基本資料無出生日期，無法" + action);
					return false;
				}
				
				<%--[20220714]已婚->配偶姓名必輸值--%>
				if($(preKey + 'MARRY').value == "1"){
					validates.checkInput_C('SPOUSE_NAME', preKey, postKey);
				}	

				//validates.checkSelect('REG_CODE REG_OWNER USE_STATUS DEGREE', preKey, postKey);
				validates.checkSelect('REG_CODE REG_OWNER DEGREE', preKey, postKey);

				// 戶籍地址為必要欄位
				address_Map["B1"].checkData(validate4define, notCheck, "基本資料－自然人戶籍");

				// 學校、科系是否含有半形字
				validates.checkInput_C('SCHOOL DEPARTMENT', preKey, postKey, false, true);
				

				// 通訊地址使用狀況=”其他”,則通訊地址使用狀況其他說明不得為空白，若否，則跳出警示訊息: “通訊地址使用狀況需說明”
				if($(preKey + 'USE_STATUS').value == "9"){
					validates.checkInput_C('USE_STATUS_CONTENT', preKey, postKey);
				}				
				
				var chooseOne = false;
				var docNM = preKey + "DOCS";
				CSS_Selectors.doActionWhenGetElement($$('#'+docNM+' input'), {'name':docNM}, 
					function(obj){
						if(!chooseOne && obj.checked){
							chooseOne = true;
						}
					}
				);
				/*$$('#' + docNM + ' input[name="' + docNM + '"]').each(
					function(obj){
						if(!chooseOne && obj.checked){
							chooseOne = true;
						}
					}
				);*/

				if(!chooseOne){
					validate4define.define( "customize_returnFalse" , [{ id :docNM + "_A" , errMsg : "至少要勾選一項"}] , { useTitle: false });
				}

				// 檢附相關資料有選擇”其他”,則檢附相關資料其他說明不得為空白，若否，則跳出警示訊息: “檢附相關資料需說明”
				if($(preKey + 'DOCS_F').checked){
					validates.checkInput_C('DOCS_CONTENT', preKey, postKey);
				}
				<%-- [20210205] 聯徵公務機關資料查調作業--%>	
				//查調公務機關授權[同意]或[不同意]必選取。
				
				if(!($('B1_AGREE').checked || $('B1_NOT_AGREE').checked) ){					
					validate4define.define( "customize_returnFalse" , [{ id :"B1_AGREE" , errMsg : "必選取"}] , { useTitle: false });
				}else{
					
					if($('B1_AGREE').checked){
						//若選取[同意]，檢核T50年度所得/T51財產清單/T52勞保資料至少勾選一項，若無則alert"請選取是否同意[查調公務機關授權]"。
						if(!($('B1_JCIC_T50').checked || $('B1_JCIC_T51').checked || $('B1_JCIC_T52').checked)){
							
							validate4define.define( "customize_returnFalse" , [{ id :"B1_JCIC_T50" , errMsg : "至少勾選一項"}] , { useTitle: false });
						}
						//若選取[同意]，檢核[授權起迄日]是否有填寫，若無則alert"請輸入[查調公務機關授權]之[授權起迄日]"。
						validate4define.define('required', [{id : 'B1_QUERY_DATE_S', errMsg : '請輸入查調公務機關授權_授權起日'}]);
						validate4define.define('required', [{id : 'B1_QUERY_DATE_E', errMsg : '請輸入查調公務機關授權_授權迄日'}]);						
						validate4define.define('validate-ROCDate-Interval', [{ id: 'B1_QUERY_DATE_S', ignore: true }, {id: 'B1_QUERY_DATE_E', errMsg : '授權迄日 須大於 授權 起日'}]);
						//若選取[同意]，檢核[授權起迄日]是否日期區間於三個月內，若無則alert"[查調公務機關授權]之[授權起迄日]區間限三個月內"。								
						validate4define.define('threeMonthInterval', [{ id: 'B1_QUERY_DATE_S', ignore: true }, {id: 'B1_QUERY_DATE_E', errMsg : '查調公務機關授權_授權起迄日區間限三個月內'}]);
					}
				}			
				
			}
			// 法人
			else{
				var B2_NAME = $('B2_NAME').getValue();
				if(validates.isBlank(B2_NAME, false)){
					alert("基本資料無姓名，無法" + action);
					return false;
				}

				var B2_BIRTHDAY = $('B2_BIRTHDAY').innerHTML;
				if(validates.isBlank(B2_BIRTHDAY, false)){
					alert("基本資料無成立日期，無法" + action);
					return false;
				}

				//validates.checkSelect('REG_CODE REG_OWNER USE_STATUS', preKey, postKey);
				validates.checkSelect('REG_CODE REG_OWNER', preKey, postKey);

				// 戶籍地址為必要欄位
				address_Map["B2"].checkData(validate4define, notCheck, "基本資料－法人戶籍");

				// 通訊地址使用狀況=”其他”,則通訊地址使用狀況其他說明不得為空白，若否，則跳出警示訊息: “通訊地址使用狀況需說明”
				if($(preKey + 'USE_STATUS').value == "9"){
					validates.checkInput_C('USE_STATUS_CONTENT', preKey, postKey);
				}

				var chooseOne = false;
				var docNM = preKey + "DOCS";
				CSS_Selectors.doActionWhenGetElement($$('#'+docNM+' input'), {'name':docNM}, function(obj){
					if(!chooseOne && obj.checked){
						chooseOne = true;
					}
				});
				/*$$('#' + docNM + ' input[name="' + docNM + '"]').each(
					function(obj){
						if(!chooseOne && obj.checked){
							chooseOne = true;
						}
					}
				);*/

				if(!chooseOne){
					validate4define.define( "customize_returnFalse" , [{ id :docNM + "_A" , errMsg : "至少要勾選一項"}] , { useTitle: false });
				}

				// 檢附相關資料有選擇”其他”,則檢附相關資料其他說明不得為空白，若否，則跳出警示訊息: “檢附相關資料需說明”
				if($(preKey + 'DOCS_F').checked){
					validates.checkInput_C('DOCS_CONTENT', preKey, postKey);
				}
				<%-- [20210205] 聯徵公務機關資料查調作業--%>				
				//查調公務機關授權[同意]或[不同意]必選取。
				
				if(!($('B2_AGREE').checked || $('B2_NOT_AGREE').checked) ){					
					validate4define.define( "customize_returnFalse" , [{ id :"B2_AGREE" , errMsg : "必選取"}] , { useTitle: false });
				}else{
					
					if($('B2_AGREE').checked){
						//若選取[同意]，檢核T50年度所得/T51財產清單/T52勞保資料至少勾選一項，若無則alert"請選取是否同意[查調公務機關授權]"。
						if(!($('B2_JCIC_T50').checked || $('B2_JCIC_T51').checked || $('B2_JCIC_T52').checked)){
							
							validate4define.define( "customize_returnFalse" , [{ id :"B2_JCIC_T50" , errMsg : "至少勾選一項"}] , { useTitle: false });
						}
						//若選取[同意]，檢核[授權起迄日]是否有填寫，若無則alert"請輸入[查調公務機關授權]之[授權起迄日]"。
						validate4define.define('required', [{id : 'B2_QUERY_DATE_S', errMsg : '請輸入查調公務機關授權_授權起日'}]);
						validate4define.define('required', [{id : 'B2_QUERY_DATE_E', errMsg : '請輸入查調公務機關授權_授權迄日'}]);						
						validate4define.define('validate-ROCDate-Interval', [{ id: 'B2_QUERY_DATE_S', ignore: true }, {id: 'B2_QUERY_DATE_E', errMsg : '授權迄日 須大於 授權 起日'}]);
						//若選取[同意]，檢核[授權起迄日]是否日期區間於三個月內，若無則alert"[查調公務機關授權]之[授權起迄日]區間限三個月內"。								
						validate4define.define('threeMonthInterval', [{ id: 'B2_QUERY_DATE_S', ignore: true }, {id: 'B2_QUERY_DATE_E', errMsg : '查調公務機關授權_授權起迄日區間限三個月內'}]);
					}
				}
				
			}
		}

		return true;
	},
	// 檢查C
	checkInputC:function(){
		var type = "C";
		var tbody = $('tbody_' + type);
		var preKey = type + "_";

		var length = tbody.rows.length;
		for(var i = 0; i < length; i=i+2){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;

            //1031204楊智凱:營業項目、資本額、出資比例改為不檢核
			// 檢核是否為空、全形字(事業名稱, 營業項目)
			//validates.checkInput_C('BUSS_NAME BUSS_ITEM', preKey, postKey, true, true);
			validates.checkInput_C('BUSS_NAME', preKey, postKey, true, true);
			
			// 檢核下拉選單是否為空(事業處所碼 ,行業別,職業類別)
			//validates.checkSelect('BUSS_CODE BUSINESS_CODE OCCU_CODE', preKey, postKey, true, 0);
			validates.checkSelect('BUSINESS_CODE OCCU_CODE', preKey, postKey, true, 0);

			// 檢核下拉選單是否為空(營業處所使用情形)
			validates.checkSelect('USE_STATUS', preKey, postKey);

			// 檢核是否為空、數字(電話號碼)
			validates.checkInput_N('TEL_NUM', preKey, postKey);

			validates.checkInput_N('TEL_EXT', preKey, postKey, false);

			// 檢核是否為空、金額(資本額, 年營業額, 出資比例, 年淨利)
			//validates.checkInput_M('CAPITAL YEAR_VOLUME CAPITAL_RATE YEAR_PROFIT', preKey, postKey, true);
			// 檢核是否為空、金額(服務年資, 年營業額, 年淨利)
			validates.checkInput_M('SERV_YEAR YEAR_VOLUME YEAR_PROFIT', preKey, postKey, true);

			// 【C區】之統一編號若有輸入，必須為8碼法人統一編號格式
			var key = preKey + 'BUSS_CORPID' + postKey;
			if(validates.isNotBlank(key)){
				if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7' && !validation.checkUniSN($(key).value)){
					validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : "有誤，請檢查後重新輸入!"}] , { useTitle: false });
				}				
			}

			// 【C區】之創立時間(年月) 若有輸入，必須為日期格式，若只輸入年月則補01
			var key = preKey + 'BUILD_DATE' + postKey;
			if(validates.isNotBlank(key)){
				var value = $(key).value;
				if(value.length == 4 || value.length == 5){
					value = value + "01";
				}

				if(!validates.isDate(value, false, "ROC", false)){
					validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : "格式錯誤"}] , { useTitle: false });
				}else{
					$(key).value = value;
				}
			}

			// 地址長度檢核
			address_Map[type][no].checkData(validate4define, notCheck, "目前經營事業(包括合夥事業)");
		}
	},
	// 檢查D
	checkInputD:function(){
		var type = "D";
		var tbody = $('tbody_' + type);
		var preKey = type + "_";
		var length = tbody.rows.length;

		var target = $('tbody_C');
		if(target.rows.length == 0 && length == 0){
			alert("目前經營事業與目前服務單位必須擇一輸入");
			return false;
		}

		for(var i = 0; i < length; i=i+3){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;

            //1031204楊智凱:營業項目改為不檢核
			// 檢核是否為空、全形字
			//validates.checkInput_C('BUSS_ITEM SERV_NAME JOB_TITLE', preKey, postKey, true, true);
			validates.checkInput_C('SERV_NAME JOB_TITLE', preKey, postKey, true, true);

			// 檢核下拉選單是否為空
			validates.checkSelect('WORK_TYPE SERV_CODE BUSINESS_CODE OCCU_CODE', preKey, postKey, true , 0);
			//validates.checkSelect('SERV_CODE', preKey, postKey, true , 0);

			//[申請書220606065713]自動徵審:目前服務單位「電話」：若「職業類別」為703家庭主婦、707退休人員、710無業、股票投資人，電話非必填。
			var tmpKey = preKey + "OCCU_CODE" + postKey;
			var tmpValue = $(tmpKey).value;
			if('703'!=tmpValue && '707'!=tmpValue && '710'!=tmpValue){
				// 檢核是否為空、數字
				validates.checkInput_N('SERV_TEL_NUM', preKey, postKey, true);
				validates.checkInput_N('SERV_TEL_EXT', preKey, postKey, false);
			}

			// 檢核是否為空、金額
			validates.checkInput_M('SERV_YEAR SALARY YEAR_INCOME', preKey, postKey, true);

			// 郵遞區號、地址為必要欄位
			address_Map[type][no].checkData(validate4define, notCheck, "目前服務單位");

			// 【D區】之統一編號若有輸入，必須為8碼法人統一編號格式
			var key = preKey + 'SERV_CORPID' + postKey;
			if(validates.isNotBlank(key)){
				if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7' && !validation.checkUniSN($(key).value)){
					validate4define.define( "customize_returnFalse" , [{ id :key , errMsg : "有誤，請檢查後重新輸入!"}] , { useTitle: false });
				}
			}
		}

		return true;
	},
	// 檢查E
	checkInputE:function(){
		var preKey = "E_";
		var postKey = "";

		// if【E區】服務單位名稱有輸入，則【E區】之營業項目、職位、服務年資、年所得(含獎金) 為必要欄位
		if($('E_SERV_NAME').value.length > 0){
			// 檢核是否為空、全形字
			validates.checkInput_C('SERV_NAME BUSS_ITEM JOB_TITLE', preKey, postKey, true, true);

			// 檢核是否為空、金額
			validates.checkInput_M('SERV_YEAR YEAR_INCOME', preKey, postKey, true);
		}else{
			// 檢核是否為空、全形字
			validates.checkInput_C('SERV_NAME BUSS_ITEM JOB_TITLE', preKey, postKey, false, true);

			// 檢核是否為空、金額
			validates.checkInput_M('YEAR_INCOME', preKey, postKey, false);
		}
	},
	// 檢查F
	checkInputF:function(){
		var preKey = "F_";
		var postKey = "";

		// 支存狀況必須擇一(改成可以不輸入)
		/*var chooseOne = false;
		$w('F_CHK_NOR F_CHK_REJ F_CHK_REF F_REPAIR F_OTHER');
		var a = $w('F_CHK_NOR F_CHK_REJ F_CHK_REF F_REPAIR F_OTHER');
		for(var i = 0; i < a.length; i++){
			if($(a[i]).checked === true){
				chooseOne = true;
				break;
			}
		}

		if(chooseOne === false){
			validate4define.define('F_CHK_NOR', "", "支存狀況須擇一選擇", validates.returnFalse);
		}*/

		// if【F區】退票checked，退票次數為必要欄位
		if($('F_CHK_REF').checked){
			var checkKey = "REF_TIMES";
			validates.checkInput_M(checkKey, preKey, postKey, true);
		}

		// if【F區】退補checked，退補次數為必要欄位
		if($('F_REPAIR').checked){
			var checkKey = "REPAIR_TIMES";
			validates.checkInput_M(checkKey, preKey, postKey, true);
		}

		// if【F區】其他checked，其他說明為必要欄位
		if($('F_OTHER').checked){
			var checkKey = "OTHER_CONTENT";
			validates.checkInput_C(checkKey, preKey, postKey, true);
		}

		// 檢核是否為金額
		validates.checkInput_M('INCOME HOME_EXP OTHER_INCOME OTHER_EXP', preKey, postKey, false);
	},
	// 檢查G
	checkInputG:function(){
		var preKey = "G_";
		var tbody = $('tbody_G');

		var length = tbody.rows.length;
		for(var i = 0; i < length; i=i+3){
			var no = tbody.rows[i].id;
			var postKey = '_' + no;

			// 【G區】座落所在地為必要欄位
			validates.checkInput_C('ADDRESS', preKey, postKey, true, true);

			// 【G區】行庫(SET_BANK)有值，則【G區】金額(SET_AMT)為必要欄位
			var key = preKey + 'SET_BANK' + postKey;
			if(validates.isNotBlank(key)){
				validates.checkInput_M('SET_AMT', preKey, postKey, true);
			}

			// 檢核是否為金額
			validates.checkInput_M('SET_AMT', preKey, postKey, false);
		}
	},
	// 下拉選單的檢核
	checkSelect:function(keys, preKey, postKey, checkEmpty, emptyValue, useTitle){
		var result = true;

		preKey = (preKey || validates.isNumber(preKey)) ? preKey : "";
		postKey = (postKey || validates.isNumber(postKey)) ? postKey : "";
		checkEmpty = (checkEmpty === false) ? checkEmpty : true;
		emptyValue = (emptyValue || validates.isNumber(emptyValue)) ? emptyValue : "";
		useTitle = (useTitle === true) ? useTitle : false;

		if(checkEmpty){
			$w(keys).each(
				function(key){
					var newKey = preKey + key + postKey;

					if($(newKey).value == emptyValue){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "必須選擇一項"}] , { useTitle: useTitle });
						result = false;
					}
				}
			);
		}

		return result;
	},
	// 輸入欄位的檢核(中文)
	checkInput_C:function(keys, preKey, postKey, checkEmpty, checkfull, checkLength, useTitle){
		var result = true;

		preKey = (preKey || validates.isNumber(preKey)) ? preKey : "";
		postKey = (postKey || validates.isNumber(postKey)) ? postKey : "";
		checkEmpty = (checkEmpty === false) ? checkEmpty : true;
		checkfull = (checkfull === true) ? checkfull : false;
		checkLength = (checkLength === false) ? checkLength : true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;
				
				if(validates.isBlank(newKey)){
					if(checkEmpty){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else {
					var value = $(newKey).value;
					if(checkfull){
						if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7') && validation.hasFullType(value) ){
							//全形轉半形
							var old_addr = value;
							var length = old_addr.length;
							var result = "";
							for ( var i = 0 ; i < length ; i ++ ) {
								var val = old_addr.charAt(i) ;  
								var j = fForm.indexOf(val) ;        
								result += ( j > -1 ? unescape(hForm[j]) : val );    
							}
							$(newKey).setValue(result);
						}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7' && validation.hasHalfType(value)){
							validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "必須為全形字"}] , { useTitle: useTitle });
							result = false;
						}
					}
					if(newKey == 'A_APPLY_ID'){
						validate4define.define( "validationAPPLY_ID" , [{ id :newKey}] , { useTitle: useTitle });
					}
					if(checkLength){
						var maxLength = $(newKey).maxLength;
						var fullLength = $(newKey).fullLength;
						var halfLength = $(newKey).halfLength;

						if(!validation.checkInputLength(value, maxLength, fullLength, halfLength)){
							validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "長度超過" + maxLength + " (全形字為2)"}] , { useTitle: useTitle });
							result = false;
						}
					}
				}
			}
		);

		return result;
	},
	// 輸入欄位的檢核(數字)
	checkInput_N:function(keys, preKey, postKey, checkEmpty, checkLength, useTitle){
		var result = true;

		preKey = (preKey || validates.isNumber(preKey)) ? preKey : "";
		postKey = (postKey || validates.isNumber(postKey)) ? postKey : "";
		checkEmpty = (checkEmpty === false) ? checkEmpty : true;
		checkLength = (checkLength === false) ? checkLength : true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				if(validates.isBlank(newKey, true)){
					if(checkEmpty){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "不可為空"}] , { useTitle: useTitle });
						result = false;
					}
				}else if(!validates.isNumber(newKey)){
					validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "只能輸入數字"}] , { useTitle: useTitle });
					result = false;
				}else if(checkLength){
					var maxLength = $(newKey).maxLength;
					var fullLength = $(newKey).fullLength;
					var halfLength = $(newKey).halfLength;

					if(!validation.checkInputLength($(newKey).value, maxLength, fullLength, halfLength)){
						validate4define.define( "customize_returnFalse" , [{ id :newKey , errMsg : "長度超過" + maxLength + " (全形字為2)"}] , { useTitle: useTitle });
						result = false;
					}
				}
			}
		);

		return result;
	},
	// 輸入欄位的檢核(金額)
	checkInput_M:function(keys, preKey, postKey, checkEmpty, useTitle){
		var result = true;

		preKey = (preKey || validates.isNumber(preKey)) ? preKey : "";
		postKey = (postKey || validates.isNumber(postKey)) ? postKey : "";
		checkEmpty = (checkEmpty === false) ? checkEmpty : true;
		useTitle = (useTitle === true) ? useTitle : false;

		$w(keys).each(
			function(key){
				var newKey = preKey + key + postKey;

				if(validates.isBlank(newKey, true)){
					if(checkEmpty){
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
	// 檢查是否為空值
	isBlank:function(key_Value, isKey){
		isKey = (isKey === false) ? isKey : true;
		var value;
		if(isKey && $(key_Value)){
			value = $(key_Value).value;
		}else{
			value = key_Value;
			isKey = false;
		}

		if(value || validates.isNumber(key_Value, isKey)){
			return false;
		}else{
			return true;
		}
	},
	// 檢查是否不為空值
	isNotBlank:function(key_Value, isKey){
		return !validates.isBlank(key_Value, isKey);
	},
	// 檢查輸入日期是否合法
	isDate:function(key_Value, checkEmpty, mod, yearLimit){
		var date;
		if($(key_Value)){
			date = $(key_Value).value;
		}else{
			date = key_Value;
		}

		if(checkEmpty !== true && date == ""){
			return true;
		}else{
			yearLimit = (yearLimit === false) ? false : true;
			if(mod == "ROC"){
				return isROCdate(date, yearLimit);
			}else{
				return isADdate(date, yearLimit);
			}
		}
	},
	// 檢核傳進來的值是否為正確的數字格式？是，則將該欄位依照pattern(自訂或預設)格式化；否，則將該欄位清空
	isNumber:function(key_Value, isKey){
		isKey = (isKey === false) ? isKey : true;
		var value;
		if(isKey && $(key_Value)){
			value = $(key_Value).getValue();
		}else{
			value = key_Value;
		}

		if(isNaN(parseInt(value, 10))){
			return false;
		}else{
			return true;
		}
	},
	// 檢查輸入欄位(非金額格式)是否超過長度限制
	isInputLengthLegal:function(key_Value, maxLength, fullLen, halfLen){
		var value;
		if($(key_Value)){
			value = $(key).getValue();
		}else{
			value = key_Value;
		}

		return validation.checkInputLength(value, maxLength, fullLen, halfLen);
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
	// 檢查radio是否有勾選
	isRadioChecked:function(type, action){

		var selectIndex = UpdateIndex[type];
		if(!selectIndex){
			alert("沒有勾選任何一筆資料，無法" + action);
			return false;
		}

		return true;
	}
};

//--------------------------------------------------------------------------
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	// 畫面控制
	control:function(type, key){
		// 個人(含配偶)全年收支情形
		if(type == "F"){
			var keyMap = {
				F_CHK_REF:"F_REF_TIMES",
				F_REPAIR:"F_REPAIR_TIMES",
				F_OTHER:"F_OTHER_CONTENT"
			};

			// 正常
			if(key == "F_CHK_NOR"){
				if($(key).checked){
					$w('F_CHK_REJ F_CHK_REF F_REPAIR F_OTHER').each(
						function(key){
							$(key).checked = false;
							$(key).disable();

							if(keyMap[key]){
								$(keyMap[key]).value = "";
								$(keyMap[key]).disable();
							}
						}
					);
				}else{
					$w('F_CHK_REJ F_CHK_REF F_REPAIR F_OTHER').each(
						function(key){
							$(key).enable();
						}
					);
				}
			}else if(keyMap[key]){
				// 退票、退補、其他
				if($(key).checked){
					$(keyMap[key]).enable();
				}else{
					$(keyMap[key]).value = "";
					$(keyMap[key]).disable();
				}
			}
		}
	},

	// 新增一筆可輸入的【目前經營事業(包括合夥事業)】
	create_CBlock:function(datas){
		var type = "C";
		var preKey = type + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + type);
		var index = (validates.isNumber(MaxIndex[type], false)) ? Number(MaxIndex[type]) + 1 : 1;	// 編號(從1開始)
		UpdateIndex[type] = index;
		MaxIndex[type] = index;

		//---------- 產生row(選取, 事業名稱,統一編號,行業別,職業類別,事業處所) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			className: 'tbBlue3',
			rowSpan: '2'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		delete config_td.rowSpan;	// 刪除 config_td 的 rowSpan
		columnIdx++;

		var name = preKey + "index";
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			type:'radio'
		};
		var radio = tableElement.createElement("input", config);
		<%-- [20181210] 設定 onclick 事件 --%>
		radio.onclick = function(){
			var key = this.id.split("_");
			UpdateIndex[type] = key[key.length-1];
		}
		td.appendChild(radio);
		radio.checked = true;

		// 事業名稱
		//config_td.colSpan = "3";
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSS_NAME';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-事業名稱",
			type:'text',
			className:'textBox2',
			size:'32',
			maxLength:'60',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 統一編號
		//config_td.colSpan = "2";
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSS_CORPID';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-統一編號",
			type:'text',
			className:'textBox2',
			size:'8',
			maxLength:'8',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

        // 經營事業-行業別
        config_td.colSpan = "2";
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSINESS_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業-行業別",
			onchange:function(){

			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, A021_BUSINESS_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

        // 經營事業-職業類別
        config_td.colSpan = "3";
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'OCCU_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業-職業類別",
			onchange:function(){

			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, A021_OCCU_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}
		
		// 事業處所碼
		config_td.colSpan = "2";
		var tdId = preKey + 'DSZ01000_' + index;
		config_td.id = tdId;
		var td = tableElement.createTD(tr, columnIdx, config_td);	// 建立id(td)給地址輸入使用
		delete config_td.id;
		columnIdx++;

		var dataId = 'BUSS_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-事業處所碼",
			onchange:function(){
				if(this.value == "9"){
					address_Map[type][index].displayOnly(false);
				}else{
					address_Map[type][index].displayOnly(true);
					address_Map[type][index].display4INPUT_ZIPCODE(false);
					address_Map[type][index].display4INPUT_ADDR(false);
					address_Map[type][index].setCITY_NAME("");
				}
			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, BUSS_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		var br = tableElement.createElement("br");
		td.appendChild(br);

		// 事業處所.地址
		var address = new DSZ01000(tdId, "2", 80);
		address.setBlnToHalfType(isFori);
		address_Map[type][index] = address;	// 將產生的地址物件存進 address_Map ，供之後使用
		if(datas){
			address.setINPUT_ADDR(formatInput.text(datas.BUSS_ADDR, false));
		}
		if($(id).value == "9"){
			address.displayOnly(false);
		}else{
			address.displayOnly(true);
			address.display4INPUT_ZIPCODE(false);
			address.display4INPUT_ADDR(false);
			address.setCITY_NAME("");
		}
		
		//---------- 產生row(電話, 營業項目, 資本額, 年營業額, 營業處所使用情形, 創立時間(年月),服務年資(年), 出資比率, 年淨利) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;

		// 營業項目
		var columnIdx = 0;
		delete config_td.colSpan;
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSS_ITEM';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-營業項目",
			type:'text',
			className:'textBox2',
			size:'20',
			maxLength:'20',
			value:value,
			onblur:function(){
				formatInput.text(this.id, true, "", true);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 資本額
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'CAPITAL';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 8;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-資本額",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:6,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		// 年營業額
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_VOLUME';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 9;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-年營業額",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:6,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		// 年淨利
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_PROFIT';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 8;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-年淨利",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:5,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		// 出資比率
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'CAPITAL_RATE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 3;
		var decLength = 3;
		var pattern = formatInput.getPattern(intLength, decLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, decLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-出資比率",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			decLength:decLength,
			pattern:pattern,
			size:3,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				if(this.getValue() < 0 || this.getValue() > 100){
					alert("出資比率只能輸入小於100的正數");
					this.value = "";
				}else{
					formatInput.patternNumber(this.id, true, this.pattern);
				}
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("%");
		td.appendChild(textNode);

		// 創立時間(年月)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUILD_DATE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.Y2KDate2ROCDate(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-創立時間(年月)",
			type:'text',
			className:'textBox2',
			size:'7',
			maxLength:'7',
			datatype:'ROCDate',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			},
			onchange:function(){
				//連動計算「服務年資」
				ajaxPost('calculate', {'type':'BUILD_DATE','value':formatInput.ROCDate2Y2KDate(this.getValue(),false)}, 
				function(resp){
					$(preKey+'SERV_YEAR_'+index).setValue((resp.rtnValue=='0'?'0':resp.rtnValue)||'');
				}, 
				function(resp){
					$(preKey+'SERV_YEAR_'+index).setValue('');
				});
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var dataId = 'calImg';
		var id = preKey + dataId + '_' + index;
		var config = {
			id:id,
			src:'<%=imageBase%>/CM/calendar.gif',
			alt:'Date'
		};
		var img = tableElement.createElement("img", config);
		<%-- [20181210] 設定 onclick 事件 --%>
		img.onclick = function(){
			getCalendarFor(preKey + 'BUILD_DATE' + '_' + index);
		}
		td.appendChild(img);

        // 服務年資
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SERV_YEAR';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 3;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, null, true);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"經營事業-服務年資",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:maxLength,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("年");
		td.appendChild(textNode);
		
		// 電話.區碼
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'TEL_AREA';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-區碼"
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, TEL_AREA_List, "(區碼)", "", "");
		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		var textNode = document.createTextNode(" - ");
		td.appendChild(textNode);

		// 電話.電話號碼
		var dataId = 'TEL_NUM';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-電話號碼",
			type:'text',
			className:'textBox2',
			size:'10',
			maxLength:'10',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode(" # ");
		td.appendChild(textNode);

		// 電話.分機
		var dataId = 'TEL_EXT';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-分機",
			type:'text',
			className:'textBox2',
			size:'6',
			maxLength:'6',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 營業處所使用情形
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'USE_STATUS';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前經營事業(包括合夥事業)-營業處所使用情形"
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, USE_STATUS_A021_List, "", "", "");
		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		autoFormatToNumber();
	},
	// 新增一筆可輸入的【目前服務單位】
	create_DBlock:function(datas){
		var type = "D";
		var preKey = type + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + type);
		var index = (validates.isNumber(MaxIndex[type], false)) ? Number(MaxIndex[type]) + 1 : 1;	// 編號(從1開始)
		UpdateIndex[type] = index;
		MaxIndex[type] = index;

		//---------- 產生row(選取, 營業項目, 服務單位名稱, 身分別, 統一編號, 行業別) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			className: 'tbBlue3',
			rowSpan: '3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		delete config_td.rowSpan;	// 刪除 config_td 的 rowSpan
		columnIdx++;

		var name = preKey + "index";
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			type:'radio',
		};
		var radio = tableElement.createElement("input", config);
		<%-- [20181210] 設定 onclick 事件 --%>
		radio.onclick = function(){
			var key = this.id.split("_");
			UpdateIndex[type] = key[key.length-1];
		};
		td.appendChild(radio);
		radio.checked = true;

		// 營業項目
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSS_ITEM';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-營業項目",
			type:'text',
			className:'textBox2',
			size:'22',
			maxLength:'20',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 服務單位名稱
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SERV_NAME';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-服務單位名稱",
			type:'text',
			className:'textBox2',
			size:'30',
			maxLength:'60',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 身分別
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'WORK_TYPE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-身分別",
			onchange:function(){

			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, WORK_TYPE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		// 統一編號
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SERV_CORPID';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-統一編號",
			type:'text',
			className:'textBox2',
			size:'8',
			maxLength:'8',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

        // 服務單位-行業別
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUSINESS_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-行業別",
			onchange:function(){

			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, A022_BUSINESS_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		//---------- 產生row(職位, 月薪, 服務年資, 年所得(含獎金), 職業類別 ) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;
		var columnIdx = 0;

		// 職位
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'JOB_TITLE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-職位",
			type:'text',
			className:'textBox2',
			size:'20',
			maxLength:'20',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 月薪
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SALARY';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 4;
		var decLength = 2;
		var pattern = formatInput.getPattern(intLength, decLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, decLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-月薪",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			decLength:decLength,
			pattern:pattern,
			size:maxLength,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		// 服務年資
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SERV_YEAR';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 3;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, null, true);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-服務年資",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:maxLength,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("年");
		td.appendChild(textNode);

		// 年所得(含獎金)
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'YEAR_INCOME';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 7;
		var decLength = 2;
		var pattern = formatInput.getPattern(intLength, decLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, decLength);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-年所得(含獎金)",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			decLength:decLength,
			pattern:pattern,
			size:maxLength,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);
		
		// 服務單位-職業類別
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'OCCU_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-職業類別",
			onchange:function(){

			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, A022_OCCU_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		//---------- 產生row(詳細地址, 電話) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;
		var columnIdx = 0;

		// 詳細地址
		config_td.colSpan = "3";
		var tdId = preKey + 'DSZ01000_' + index;
		config_td.id = tdId;
		var td = tableElement.createTD(tr, columnIdx, config_td);	// 建立id(td)給地址輸入使用
		delete config_td.id;
		delete config_td.colSpan;
		columnIdx++;

		var dataId = 'SERV_CODE';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-詳細地址碼",
			onchange:function(){
				if(this.value == "9"){
					address_Map[type][index].displayOnly(false);
				}else{
					address_Map[type][index].displayOnly(true);
					address_Map[type][index].display4INPUT_ZIPCODE(false);
					address_Map[type][index].display4INPUT_ADDR(false);
					address_Map[type][index].setCITY_NAME("");
				}
			}
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, BUSS_CODE_List, "", "", "");

		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		var br = tableElement.createElement("br");
		td.appendChild(br);

		var address = new DSZ01000(tdId, "2", 80);
		address.setBlnToHalfType(isFori);
		address_Map[type][index] = address;	// 將產生的地址物件存進 address_Map ，供之後使用

		if(datas){
			address.setINPUT_ADDR(formatInput.text(datas.SERV_ADDR, false));
		}
		
		if($(id).value == "9"){
			address.displayOnly(false);
		}else{
			address.displayOnly(true);
			address.display4INPUT_ZIPCODE(false);
			address.display4INPUT_ADDR(false);
			address.setCITY_NAME("");
		}

		// 電話.區碼
        config_td.colSpan = "2";
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'SERV_TEL_AREA';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-區碼"
		};
		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, TEL_AREA_List, "(區碼)", "", "");
		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		var textNode = document.createTextNode(" - ");
		td.appendChild(textNode);

		// 電話.電話號碼
		var dataId = 'SERV_TEL_NUM';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-電話號碼",
			type:'text',
			className:'textBox2',
			size:'10',
			maxLength:'10',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode(" # ");
		td.appendChild(textNode);

		// 電話.分機
		var dataId = 'SERV_TEL_EXT';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"目前服務單位-分機",
			type:'text',
			className:'textBox2',
			size:'6',
			maxLength:'6',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);


		autoFormatToNumber();
	},
	// 新增一筆可輸入的【本人其他不動產暨設定明細】
	create_GBlock:function(datas){
		var type = "G";
		var preKey = type + "_";

		//---------- 取得tbody ----------
		var tBody = $('tbody_' + type);
		var index = (validates.isNumber(MaxIndex[type], false)) ? Number(MaxIndex[type]) + 1 : 1;	// 編號(從1開始)
		UpdateIndex[type] = index;
		MaxIndex[type] = index;

		//---------- 產生row(選取、座落所在地、地號1、地號2) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = index;

		// 選取
		var columnIdx = 0;	// column位置
		var config_td = {
			className: 'tbBlue3',
			rowSpan: '3'
		};
		var td = tableElement.createTD(tr, columnIdx, config_td);
		delete config_td.rowSpan;
		columnIdx++;

		var name = preKey + "index";
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			type:'radio'
		};
		var radio = tableElement.createElement("input", config);
		<%-- [20181210] 設定 onclick 事件 --%>
		radio.onclick = function(){
			var key = this.id.split("_");
			UpdateIndex[type] = key[key.length-1];
		};
		td.appendChild(radio);
		radio.checked = true;

		// 座落所在地
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'ADDRESS';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－座落所在地",
			type:'text',
			className:'textBox2',
			size:'40',
			maxLength:'80',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 地號1
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'LAND_NO1';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－地號1",
			type:'text',
			className:'textBox2',
			size:'4',
			maxLength:'4',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode(" - ");
		td.appendChild(textNode);

		// 地號2
		var dataId = 'LAND_NO2';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－地號2",
			type:'text',
			className:'textBox2',
			size:'4',
			maxLength:'4',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		//---------- 產生row(建物門牌、建號1、建號2) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[type];

		// 建物門牌
		var columnIdx = 0;	// column位置
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUILD_DOOR';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－建物門牌",
			type:'text',
			className:'textBox2',
			size:'30',
			maxLength:'60',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		// 建號1
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'BUILD_NO1';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－建號1",
			type:'text',
			className:'textBox2',
			size:'5',
			maxLength:'5',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode(" - ");
		td.appendChild(textNode);

		// 建號2
		var dataId = 'BUILD_NO2';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－建號2",
			type:'text',
			className:'textBox2',
			size:'3',
			maxLength:'3',
			value:value,
			onblur:function(){
				formatInput.number(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		//---------- 產生row(使用情形、設定情形) ----------
		var lastTBRow = tBody.rows.length;
		var tr = tableElement.createTR(tBody, lastTBRow);
		tr.id = UpdateIndex[type];

		// 使用情形
		var columnIdx = 0;	// column位置
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var dataId = 'USE_STATUS';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－使用情形"
		};

		var select = tableElement.createElement("select", config);
		td.appendChild(select);
		selection.createAll(id, USE_STATUS_A023_List, "", "", "");
		if(datas){
			selection.setOptions(id, datas[dataId]);
		}

		// 設定情形
		var td = tableElement.createTD(tr, columnIdx, config_td);
		columnIdx++;

		var textNode = document.createTextNode("行庫：");
		td.appendChild(textNode);

		var dataId = 'SET_BANK';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var value = (datas) ? formatInput.text(datas[dataId], false) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－行庫",
			type:'text',
			className:'textBox2',
			size:'12',
			maxLength:'12',
			value:value,
			onblur:function(){
				formatInput.text(this.id);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("　金額：");
		td.appendChild(textNode);

		var dataId = 'SET_AMT';
		var name = preKey + dataId;
		var id = name + "_" + index;
		var intLength = 10;
		var pattern = formatInput.getPattern(intLength);
		var maxLength = formatInput.getMaxLength4Number(intLength, null, true);
		var value = (datas) ? formatInput.patternNumber(datas[dataId], false, pattern) : "";
		var config = {
			id:id,
			name:name,
			fieldName:"本人其他不動產暨設定明細－金額",
			type:'text',
			className:'textBox2',
			datatype:'number',
			intLength:intLength,
			pattern:pattern,
			size:maxLength,
			maxLength:maxLength,
			value:value,
			onblur:function(){
				formatInput.patternNumber(this.id, true, this.pattern);
			}
		};
		var input = tableElement.createElement("input", config);
		td.appendChild(input);

		var textNode = document.createTextNode("萬");
		td.appendChild(textNode);

		autoFormatToNumber();
	},
	// 刪除多筆區塊指定的資料
	deleteData_fromXBlock:function(type){
		var	key = "tbody_" + type;
		var	preKey = type + "_";
		var postKey = "_" + MaxIndex[type];
		var	maxNo = MaxIndex[type];
		var	no = UpdateIndex[type];
		UpdateIndex[type] = null;


		// 如果要刪除的index==MaxIndex時，則將MaxIndex-1
		if(type == "C" || type == "D" || type == "G"){
			if(validates.isNumber(maxNo, false) && validates.isNumber(no, false)){
				if(Number(no)-Number(maxNo) == 0){
					MaxIndex[type] = maxNo - 1;
				}
			}
		}else{
			alert("指定的區塊錯誤：" + type);
			return false;
		}

		if($(preKey + 'index' + postKey)){
			$(preKey + 'index' + postKey).checked = true;
		}

		// [20181204] 相容性問題，將 removeNode 改用 removeChild
		var target = $(key);
		$$('#' + key +' tr[id="' + no + '"]').each(
			function(obj){
				target.removeChild(obj);
			}
		);
	},
	// 刪除C或G的所有資料(將MaxIndex歸0)
	deleteXBlock:function(type){
		var target = $('tbody_' + type);
		MaxIndex[type] = 0;
		UpdateIndex[type] = null;

		if(type != "C" && type != "D" && type != "G"){
			alert("指定的區塊錯誤：" + type);
			return false;
		}

		// 清除tr
		for(var lastRow = target.rows.length-1; lastRow >= 0; lastRow--){
			// [20181204] 相容性問題，將 removeNode 改用 removeChild
			target.removeChild(target.rows[lastRow]);
		}
	},
	// 初始畫面
	clear4Query:function(){
		// 清空地址
		address_Map["A"].setCITY_NAME("");
		address_Map["A"].setINPUT_ZIPCODE("");
		address_Map["A"].setINPUT_ADDR("");
		

		address_Map["B1"].setCITY_NAME("");
		address_Map["B1"].setINPUT_ZIPCODE("");
		address_Map["B1"].setINPUT_ADDR("");

		

		address_Map["B2"].setCITY_NAME("");
		address_Map["B2"].setINPUT_ZIPCODE("");
		address_Map["B2"].setINPUT_ADDR("");


		// 清空【更換借款人】下拉選單
		selection.clean("A_ID");

		// 刪除【目前經營事業(包括合夥事業)】
		layout.deleteXBlock("C");

		// 刪除【目前服務單位】
		layout.deleteXBlock("D");

		// 刪除【本人其他不動產暨設定明細】
		layout.deleteXBlock("G");

		// 清空輸入欄位(除了查詢的受理編號)
		$$('#body input[type="text"]').each(
			function(text){
				if(text.id != "A_APPLY_ID"){
					text.value = '';
				}
			}
		);

		// 下拉選單歸0
		$$('#body select').each(
			function(select){
				select.selectedIndex = 0;
			}
		);

		// 清空hidden欄位
		$$('#body input[type="hidden"]').each(
			function(text){
				text.value = '';
			}
		);

		// 清空顯示欄位(除了區塊標題)
		$$('#body span').each(
			function(span){
				if(span.id && span.id != "B1_DOCS" && span.id != "B2_DOCS"){
					span.innerHTML = '';
				}
			}
		);

		<%-- [20191216] 法金專案 增加 --%>
		//註冊國家預設為中華民國
		$w('B1_ B2_').each(function(type){
			var eleid = type+'COUNTRY_NM';
			$(eleid).setValue('中華民國');
			$(eleid).simulate('change');
		});
			
			
		
		layout.setInitSelect();
	},
	// 載入資料
	loadData:function(resp){
		var mainMap = resp.mainMap;
		DSA020 = resp.DSA020;
		var DSA021_List = resp.DSA021_List;
		var now_DSA022_List = resp.now_DSA022_List;
		var before_DSA022 = resp.before_DSA022;
		var DSA023_List = resp.DSA023_List;
		var rtnList = resp.rtnList;

		layout.clear4Query();

		// A區
		// 保證人清單
		selection.clean("A_ID");
		A_ID_Map = {};
		if(rtnList){
			selection.createAll("A_ID", rtnList, "", "ID", "NAME");

			for(var i = 0; i < rtnList.length; i++){
				var id_Map = {};
				id_Map.CHG_REG_CODE = rtnList[i].REG_CODE;
				id_Map.CHG_REG_ZIP = rtnList[i].REG_ZIP;
				id_Map.CHG_REG_ADDR = rtnList[i].REG_ADDR;
				id_Map.CHG_REG_OWNER = rtnList[i].REG_OWNER;

				A_ID_Map[rtnList[i].ID] = id_Map;
			}
			layout.changeID();
		}

		// B區-基本資料
		if(!mainMap){
			mainMap = {};
		}
		if(!DSA020){
			DSA020 = {};
		}

		GAGE_TYPE = mainMap.GAGE_TYPE
		B_type = mainMap.COPR_CODE;
		APPLY_DATE = mainMap.APPLY_DATE;
		//外幣貸款，地址不轉全形
		isFori = GAGE_TYPE!='6' && GAGE_TYPE!= '7'?false:true;
		address_Map["A"].setBlnToHalfType(isFori);
		address_Map["B1"].setBlnToHalfType(isFori);
		address_Map["B2"].setBlnToHalfType(isFori);
		
		for(var key in address_Map["C"]){
			address_Map["C"][key].setBlnToHalfType(isFori);
		}
		for(var key in address_Map["D"]){
			address_Map["D"][key].setBlnToHalfType(isFori);
		}
		
		// 自然人
		if(B_type === "0"){
			$('table_B1').show();
			$('table_B2').hide();

			var type = "B1";

			// 受理編號
			$('B1_APPLY_ID').innerHTML = (DSA020.APPLY_ID) ? formatInput.text(DSA020.APPLY_ID, false) : formatInput.text(mainMap.APPLY_ID, false);

			// 受理進度
			$('B1_APPLY_PROCESS_NM').innerHTML = formatInput.text(mainMap.APPLY_PROCESS_NM, false);

			// 姓名
			var B1_NAME = (DSA020.NAME) ? formatInput.text(DSA020.NAME, false) : formatInput.text(mainMap.BORROW_NAME, false);
			$('B1_NAME').innerHTML = B1_NAME;
			$('B1_NAME_INPUT').setValue(B1_NAME);
			// 出生日期
			$('B1_BIRTHDAY').innerHTML = (DSA020.BIRTHDAY) ? formatInput.Y2KDate2ROCDate(DSA020.BIRTHDAY, false, "/") : formatInput.Y2KDate2ROCDate(mainMap.BIRTHDAY, false, "/");

			// 歲
			layout.calculateAge('B1_BIRTHDAY', 'B1_AGE');

			// 統一編號
			$('B1_ID').innerHTML = (DSA020.ID) ? formatInput.text(DSA020.ID, false) : formatInput.text(mainMap.BORROW_ID, false);

			// 戶籍地址碼
			$('B1_REG_CODE').value = (DSA020.REG_CODE) ? formatInput.text(DSA020.REG_CODE, false) : "";

			// 戶籍地址.郵遞區
			address_Map[type].setINPUT_ZIPCODE(DSA020.REG_ZIP);

			// 戶籍地址.地址
			address_Map[type].setINPUT_ADDR(DSA020.REG_ADDR);

			// 戶籍所有碼
			selection.setOptions('B1_REG_OWNER', DSA020.REG_OWNER);

			// 通訊地址使用狀況
			selection.setOptions('B1_USE_STATUS', DSA020.USE_STATUS);

			// 通訊地址使用狀況.其他說明
			$('B1_USE_STATUS_CONTENT').value = formatInput.text(DSA020.USE_STATUS_CONTENT, false);

			// 學歷
			selection.setOptions('B1_DEGREE', DSA020.DEGREE);

			// 學歷.學校
			$('B1_SCHOOL').value = formatInput.text(DSA020.SCHOOL, false);

			// 學歷.系
			$('B1_DEPARTMENT').value = formatInput.text(DSA020.DEPARTMENT, false);

			// 婚姻狀況
			selection.setOptions('B1_MARRY', DSA020.MARRY);

			// 婚姻狀況.配偶姓名
			<%--[20220714]改用A020.SPOUSE_NAME--%>
			$('B1_SPOUSE_NAME').value = formatInput.text(DSA020.SPOUSE_NAME, false);

			// 婚姻狀況.存歿
			selection.setOptions('B1_SPOUSE_LIVE', DSA020.SPOUSE_LIVE);

			// 子女人數.男
			selection.setOptions('B1_SON_NO', DSA020.SON_NO);

			// 子女人數.女
			selection.setOptions('B1_GIRL_NO', DSA020.GIRL_NO);

			// 檢附相關資料
			var spanName = "B1_DOCS";
			var DOCS = DSA020.DOCS ? DSA020.DOCS.split(",") : [];

			var docLen = DOCS.length;
			for(var i = 0; i < docLen; i++){
				CSS_Selectors.doActionWhenGetElement($$('#'+spanName+' input'), {'name':spanName}, 
					function(obj){
						if(obj.value == DOCS[i]){
							obj.checked = true;
						}
					}
				);
				/*$$('#' + spanName +' input[name="' + spanName + '"]').each(
					function(obj){
						if(obj.value == DOCS[i]){
							obj.checked = true;
						}
					}
				);*/
			}

			// 檢附相關資料.其他說明
			$('B1_DOCS_CONTENT').value = formatInput.text(DSA020.DOCS_CONTENT, false);
			
			<%-- [20210205] 聯徵公務機關資料查調作業--%>			
			if('Y'==DSA020.JCIC_T50 || 'Y'==DSA020.JCIC_T51 || 'Y'==DSA020.JCIC_T52){
				$('B1_AGREE').checked = true;
				$('B1_NOT_AGREE').checked = false;
			}else{
				$('B1_AGREE').checked = false;
				$('B1_NOT_AGREE').checked = true;
			}
			if('Y'==DSA020.JCIC_T50){
				$('B1_JCIC_T50').checked = true;
			}else{
				$('B1_JCIC_T50').checked = false;
			}
			if('Y'==DSA020.JCIC_T51){
				$('B1_JCIC_T51').checked = true;
			}else{
				$('B1_JCIC_T51').checked = false;
			}
			if('Y'==DSA020.JCIC_T52){
				$('B1_JCIC_T52').checked = true;
			}else{
				$('B1_JCIC_T52').checked = false;
			}
			
			if(DSA020.QUERY_DATE_S){
				$('B1_QUERY_DATE_S').setValue(toROC(DSA020.QUERY_DATE_S));
			}else{
				$('B1_QUERY_DATE_S').setValue('');
			}
			
			if(DSA020.QUERY_DATE_E){
				$('B1_QUERY_DATE_E').setValue(toROC(DSA020.QUERY_DATE_E));
			}else{
				$('B1_QUERY_DATE_E').setValue('');
			}			
			$('B1_AGREE').disable();
			$('B1_NOT_AGREE').disable();
			$('B1_JCIC_T50').disable();
			$('B1_JCIC_T51').disable();
			$('B1_JCIC_T52').disable();
			$('B1_QUERY_DATE_S').disable();
			$('B1_QUERY_DATE_E').disable();
			
			<%-- [20191216] 法金專案 增加 --%>
			// 註冊國家					
			if(mainMap.isCORP_DEPT == 'Y'){
				if(Object.toJSON(DSA020) != '{}'){//若A020有值
					var COUNTRY = DSA020.COUNTRY || '';
					var COUNTRY_NM = '';
					for(var i in COUNTRY_List){
						if(COUNTRY == COUNTRY_List[i]['COUNTRY']){
							COUNTRY_NM = COUNTRY_List[i]['COUNTRY_NM'];
						}
					}
					$('B1_COUNTRY_NM').setValue(COUNTRY_NM);	
					$('B1_NATION_ITEM').show();				
					$('B1_COUNTRY_NM').show();
				}else{//預設值
					$('B1_COUNTRY_NM').setValue('中華民國');	
					$('B1_NATION_ITEM').show();				
					$('B1_COUNTRY_NM').show();
				}
			} else {
				$('B1_NATION_ITEM').hide();	
				$('B1_COUNTRY_NM').hide();				
			}
		}
		// 法人
		else if(B_type === "1"){
			$('table_B1').hide();
			$('table_B2').show();

			var type = "B2";

			// 受理編號
			$('B2_APPLY_ID').innerHTML = (DSA020.APPLY_ID) ? formatInput.text(DSA020.APPLY_ID, false) : formatInput.text(mainMap.APPLY_ID, false);

			// 受理進度
			$('B2_APPLY_PROCESS_NM').innerHTML = formatInput.text(mainMap.APPLY_PROCESS_NM, false);

			// 姓名
			$('B2_NAME').value = (DSA020.NAME) ? formatInput.text(DSA020.NAME, false) : formatInput.text(mainMap.BORROW_NAME, false);

			// 成立日期
			$('B2_BIRTHDAY').innerHTML = (DSA020.BIRTHDAY) ? formatInput.Y2KDate2ROCDate(DSA020.BIRTHDAY, false, "/") : formatInput.Y2KDate2ROCDate(mainMap.BIRTHDAY, false, "/");

			<%-- [20221121] 計算成立多少年 --%>
			// 年
			layout.calculateAge('B2_BIRTHDAY', 'B2_AGE');

			// 統一編號
			$('B2_ID').innerHTML = (DSA020.ID) ? formatInput.text(DSA020.ID, false) : formatInput.text(mainMap.BORROW_ID, false);

			// 戶籍地址碼
			$('B2_REG_CODE').value = (DSA020.REG_CODE) ? formatInput.text(DSA020.REG_CODE, false) : "";

			// 戶籍地址.郵遞區
			address_Map[type].setINPUT_ZIPCODE(DSA020.REG_ZIP);

			// 戶籍地址.地址
			address_Map[type].setINPUT_ADDR(DSA020.REG_ADDR);

			// 戶籍所有碼
			selection.setOptions('B2_REG_OWNER', DSA020.REG_OWNER);

			// 通訊地址使用狀況
			selection.setOptions('B2_USE_STATUS', DSA020.USE_STATUS);

			// 通訊地址使用狀況.其他說明
			$('B2_USE_STATUS_CONTENT').value = formatInput.text(DSA020.USE_STATUS_CONTENT, false);

			// 負責人
			$('B2_SPOUSE_NAME').value = (DSA020.SPOUSE_NAME) ? formatInput.text(DSA020.SPOUSE_NAME, false) : formatInput.text(mainMap.COUPLE_NAME, false);

			// 檢附相關資料
			var spanName = "B2_DOCS";
			var DOCS = DSA020.DOCS ? DSA020.DOCS.split(",") : [];
			var docLen = DOCS.length;
			for(var i = 0; i < docLen; i++){
				CSS_Selectors.doActionWhenGetElement($$('#'+spanName+' input'), {'name':spanName}, 
					function(obj){
						if(obj.value == DOCS[i]){
							obj.checked = true;
						}
					}
				);
				/*$$('#' + spanName +' input[name="' + spanName + '"]').each(
					function(obj){
						if(obj.value == DOCS[i]){
							obj.checked = true;
						}
					}
				);*/
			}

			// 檢附相關資料.其他說明
			$('B2_DOCS_CONTENT').value = formatInput.text(DSA020.DOCS_CONTENT, false);
			
			<%-- [20210205] 聯徵公務機關資料查調作業--%>			
			if('Y'==DSA020.JCIC_T50){
				$('B2_JCIC_T50').checked =true;
			}else{
				$('B2_JCIC_T50').checked =false;
			}
			if('Y'==DSA020.JCIC_T51){
				$('B2_JCIC_T51').checked =true;
			}else{
				$('B2_JCIC_T51').checked =false;
			}
			if('Y'==DSA020.JCIC_T52){
				$('B2_JCIC_T52').checked =true;
			}else{
				$('B2_JCIC_T52').checked =false;
			}
			
			if(DSA020.QUERY_DATE_S){
				$('B2_QUERY_DATE_S').setValue(toROC(DSA020.QUERY_DATE_S));
			}else{
				$('B2_QUERY_DATE_S').setValue('');
			}
			
			if(DSA020.QUERY_DATE_E){
				$('B2_QUERY_DATE_E').setValue(toROC(DSA020.QUERY_DATE_E));
			}else{
				$('B2_QUERY_DATE_E').setValue('');
			}	
			
			<%-- [20191216] 法金專案 增加 --%>
			// 註冊國家					
			if(mainMap.isCORP_DEPT == 'Y'){
				if(Object.toJSON(DSA020) != '{}'){//若A020有值
					var COUNTRY = DSA020.COUNTRY || '';
					var COUNTRY_NM = '';
					for(var i in COUNTRY_List){
						if(COUNTRY == COUNTRY_List[i]['COUNTRY']){
							COUNTRY_NM = COUNTRY_List[i]['COUNTRY_NM'];
						}
					}
					$('B2_COUNTRY_NM').setValue(COUNTRY_NM);	
					$('B2_NATION_ITEM').show();				
					$('B2_COUNTRY_NM').show();
				}else{//預設值
					$('B2_COUNTRY_NM').setValue('中華民國');	
					$('B2_NATION_ITEM').show();				
					$('B2_COUNTRY_NM').show();
				}
			} else {
				$('B2_NATION_ITEM').hide();	
				$('B2_COUNTRY_NM').hide();				
			}
		}
		
		// C區-目前經營事業(包括合夥事業)
		if(DSA021_List){
			var length = DSA021_List.length;
			for(var i = 0; i < length; i++){
				layout.create_CBlock(DSA021_List[i]);
			}

			if(length > 0){
				$('C_index_1').checked = true;
			}
		}

		// D區-目前服務單位
		if(now_DSA022_List){
			var length = now_DSA022_List.length;
			for(var i = 0; i < length; i++){
				layout.create_DBlock(now_DSA022_List[i]);
			}

			if(length > 0){
				$('D_index_1').checked = true;
			}
		}

		// E區-前職單位(目前營業或服務單位之年資未滿一年者請務必填寫)
		if(before_DSA022){
			// 受理編號
			// 資料種類
			// 保證人ID
			/*
				服務單位名稱
				營業項目
				職位
			*/
			$w('BUSS_ITEM').each(
				function(key){
					var newKey = "E_" + key;
					$(newKey).value = formatInput.text(before_DSA022[key], false, "", true);
				}
			);

			$w('SERV_NAME JOB_TITLE').each(
				function(key){
					var newKey = "E_" + key;
					$(newKey).value = formatInput.text(before_DSA022[key], false);
				}
			);

			/*
				服務年資
				年所得(含獎金)
			*/
			$w('SERV_YEAR YEAR_INCOME').each(
				function(key){
					var newKey = "E_" + key;
					$(newKey).value = formatInput.patternNumber(before_DSA022[key], false, $(newKey).pattern);
				}
			);


		}

		// F區-個人(含配偶)全年收支情形
		if(DSA020){
			/*
				支存狀況-其他說明
				收入.其他收入項目
				支出. 其他支出項目
			*/
			$w('OTHER_CONTENT REPAIR OTHER OTHER_INCOME_ITEM OTHER_EXP_ITEM').each(
				function(key){
					var newKey = "F_" + key;
					$(newKey).value = formatInput.text(DSA020[key], false);

				}
			);

			/*
				支存狀況-退票次數
				支存狀況-退補次數
				收入.經營事業/薪資收入金額
				支出.家庭生活支出金額
				收入.其他收入金額
				支出. 其他支出金額
				收入.合計
				支出.合計
			*/
			$w('REF_TIMES REPAIR_TIMES INCOME HOME_EXP OTHER_INCOME OTHER_EXP').each(
				function(key){
					var newKey = "F_" + key;
					if('INCOME'==key){
						if(DSA020[key]||DSA020[key]=='0'){
							$(newKey).value = formatInput.patternNumber(DSA020[key], false, $(newKey).pattern);
						}else{
							//收入項目_經營事業/薪資收入(年所得含獎金) 預帶
							var INCOMEs = [];
							for(var index=1; index<=MaxIndex['D'];index++){
								var income = $F('D_YEAR_INCOME_'+index);
								if(income && income!='0'){
									INCOMEs.push(income);
								}
							}
							if(INCOMEs.length==0){
								for(var index=1; index<=MaxIndex['C'];index++){
									var income = $F('C_YEAR_PROFIT_'+index);
									if(income && income!='0'){
										INCOMEs.push(income);
									}
								}
							}
							if(INCOMEs.length!=0){
								ajaxPost('calculate', {'type':'INCOME','value':Object.toJSON(INCOMEs)}, 
									function(resp){
										$(newKey).setValue(resp.rtnValue||'0');
									}, 
									function(resp){
										$(newKey).setValue('');
									},false);
							}else{
								$(newKey).setValue('');
							}
						}
					}else{
						$(newKey).value = formatInput.patternNumber(DSA020[key], false, $(newKey).pattern);
					}
				}
			);

			/*
				支存狀況-正常
				支存狀況-拒往
				支存狀況-退票
				支存狀況-退補
				支存狀況-其他
			*/
			$w('CHK_NOR CHK_REJ CHK_REF REPAIR OTHER').each(
				function(key){
					var newKey = "F_" + key;

					if(DSA020[key] == "1"){
						$(newKey).checked = true;
					}else{
						$(newKey).checked = false;
					}

					layout.control("F", newKey);
				}
			);

			layout.reCalculateTotal('F_INCOME_TOTAL');
			layout.reCalculateTotal('F_EXP_TOTAL');
		}

		// G區-本人其他不動產暨設定明細
		if(DSA023_List){
			var length = DSA023_List.length;
			for(var i = 0; i < length; i++){
				layout.create_GBlock(DSA023_List[i]);
			}

			if(length > 0){
				$('G_index_1').checked = true;
			}
		}

		layout.setInitSelect();
    },
	// 計算歲數
	calculateAge:function(key, targetKey){
		var keyDay = $(key).innerHTML;

		if(keyDay == ""){
			$(targetKey).innerHTML = "";
			return;
		}else if(!validates.isDate(keyDay, false, "ROC", false)){
			$(targetKey).innerHTML = "";
			alert("輸入日期有誤(" + keyDay + ")");
			return;
		}

		<%-- [20221121] 預設字體黑色 --%>
		$(targetKey).setStyle({color:'black'});
		
		var birthday = formatInput.ROCDate2Y2KDate(keyDay, false, "/");
		var actionName = "calculateAge";
		var params = {"BIRTHDAY":birthday, "APPLY_DATE":APPLY_DATE};
		var successAction = function(resp){
			$(targetKey).innerHTML = formatInput.number(resp.AGE, false);
			
			<%-- [20221121] 若為自然人且小於18歲，字體紅色 --%>
			if (targetKey == 'B1_AGE' && resp.AGE < 18) {
				$(targetKey).setStyle({color:'red'});
			}
		};
		var errorAction = function(resp){
			$(targetKey).innerHTML = "";
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 重新計算合計
	reCalculateTotal:function(targetKey){
		if(targetKey == "F_INCOME_TOTAL"){
			$('F_INCOME').value = formatInput.patternNumber($('F_INCOME').getValue(), false, $('F_INCOME').pattern, "", "0");
			$('F_OTHER_INCOME').value = formatInput.patternNumber($('F_OTHER_INCOME').getValue(), false, $('F_OTHER_INCOME').pattern, "", "0");

			var total = parseInt($('F_INCOME').getValue(), 10) + parseInt($('F_OTHER_INCOME').getValue(), 10);
			$(targetKey).innerHTML = formatInput.patternNumber(total, false, $(targetKey).pattern);
		}else if(targetKey == "F_EXP_TOTAL"){
			$('F_HOME_EXP').value = formatInput.patternNumber($('F_HOME_EXP').getValue(), false, $('F_HOME_EXP').pattern, "", "0");
			$('F_OTHER_EXP').value = formatInput.patternNumber($('F_OTHER_EXP').getValue(), false, $('F_OTHER_EXP').pattern, "", "0");

			var total = parseInt($('F_HOME_EXP').getValue(), 10) + parseInt($('F_OTHER_EXP').getValue(), 10);
			$(targetKey).innerHTML = formatInput.patternNumber(total, false, $(targetKey).pattern);
		}
	},
	// 設定下拉選單預設值
	setInitSelect:function(){
		// if「戶籍地址碼」下拉選單選擇“其他如下”，則為輸入欄位
		$w('A_CHG_REG_CODE B1_REG_CODE B2_REG_CODE').each(
			function(key){
				var type = key.split("_")[0];
				if($(key).value == "9"){
					address_Map[type].displayOnly(false);
				}else{
					address_Map[type].displayOnly(true);
					address_Map[type].display4INPUT_ZIPCODE(false);
					address_Map[type].display4INPUT_ADDR(false);
					address_Map[type].setCITY_NAME("");
				}
			}
		);

		// if「通訊地址使用狀況」下拉選單選擇 “其他”，則為輸入欄位
		$w('B1_USE_STATUS B2_USE_STATUS').each(
			function(key){
				if($(key).value == "9"){
					$(USE_STATUS_Map[key]).show();
				}else{
					$(USE_STATUS_Map[key]).value = "";
					$(USE_STATUS_Map[key]).hide();
				}
			}
		);

		// if「婚姻狀況」下拉選單選擇 “已婚”，則為輸入欄位
		$w('B1_MARRY').each(
			function(key){
				<%--[20220714]已婚->配偶姓名必輸值--%>
				if($(key).value == "1"){
					$(MARRY_Map[key]).enable();	// 目前皆為disable
				}else{
					$(MARRY_Map[key]).disable();
				}
			}
		);
	},
	// 改變更換借款人時
	changeID:function(){
		var type = "A";
		var ID = $('A_ID').value;
		if(A_ID_Map && A_ID_Map[ID]){
			$('A_CHG_REG_CODE').value = A_ID_Map[ID].CHG_REG_CODE;
			address_Map[type].setINPUT_ZIPCODE(A_ID_Map[ID].CHG_REG_ZIP);
			address_Map[type].setINPUT_ADDR(A_ID_Map[ID].CHG_REG_ADDR);
			$('A_CHG_REG_OWNER').value = A_ID_Map[ID].CHG_REG_OWNER;
		}else{
			$('A_CHG_REG_CODE').selectedIndex = 0;
			address_Map[type].setINPUT_ZIPCODE("");
			address_Map[type].setINPUT_ADDR("");
			$('A_CHG_REG_OWNER').selectedIndex = 0;
		}

		layout.setInitSelect();
	}
};

//--------------------------------------------------------------------------
// 輔助工具
//--------------------------------------------------------------------------
var auxiliary = {
	// 取得畫面上的資料(B~G)
	getAllData:function(action, type){
		var rtnMap = {};

		//---------- 基本資料, 個人(含配偶)全年收支情形 ----------
		if(!DSA020){
			DSA020 = {};
		}

		var preKey;
		if(B_type === "0"){//自然人
			preKey = 'B1_';
		}else{//法人
			preKey = 'B2_';
		}

		var default4A020 = {
			BIRTHDAY:null,
			AGE:0,
			SON_NO:0,
			GIRL_NO:0,
			INCOME:0,
			OTHER_INCOME:0,
			INCOME_TOTAL:0,
			HOME_EXP:0,
			OTHER_EXP:0,
			EXP_TOTAL:0
		};

		// 輸入欄位
		<%-- [20210205] 聯徵公務機關資料查調作業--%>
		<%-- [20220714]增-SPOUSE_NAME--%>
		$w('REG_CODE REG_OWNER DEGREE SCHOOL DEPARTMENT MARRY SPOUSE_NAME SPOUSE_NAME SPOUSE_LIVE SON_NO GIRL_NO USE_STATUS USE_STATUS_CONTENT DOCS_CONTENT COUNTRY JCIC_T50 JCIC_T51 JCIC_T52 QUERY_DATE_S QUERY_DATE_E').each(
			function(key){
				var newKey = preKey + key;

				if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
					DSA020[key] = $(newKey).getValue();
				}else if(!Object.isUndefined(default4A020[key])){
					DSA020[key] = default4A020[key];
				}else{
					DSA020[key] = "";
				}
			}
		);

		// 顯示欄位
		$w('APPLY_ID ID NAME AGE').each(
			function(key){
				var newKey = preKey + key;
				if($(newKey) && ($(newKey).innerHTML || !isNaN(parseInt($(newKey).innerHTML, 10)))){
					DSA020[key] = $(newKey).innerHTML;
				}else if(!Object.isUndefined(default4A020[key])){
					DSA020[key] = default4A020[key];
				}else{
					DSA020[key] = "";
				}
			}
		);

		var DOCS = "";
		var newKey = preKey + "DOCS";
		CSS_Selectors.doActionWhenGetElement($$('#'+newKey+' input'), {'name':newKey}, 
			function(obj){
				if(obj.checked){
					DOCS = DOCS + obj.value + ",";
				}
			}
		);
		/*$$('#' + newKey +' input[name="' + newKey + '"]').each(
			function(obj){
				if(obj.checked){
					DOCS = DOCS + obj.value + ",";
				}
			}
		);*/

		var docLen = DOCS.length
		if(docLen > 0){
			DOCS = DOCS.substring(0, docLen-1);
		}
		DSA020["DOCS"] = DOCS;

		preKey = "F_";

		// 輸入欄位
		$w('REF_TIMES REPAIR_TIMES OTHER_CONTENT INCOME OTHER_INCOME OTHER_INCOME_ITEM HOME_EXP OTHER_EXP OTHER_EXP_ITEM').each(
			function(key){
				var newKey = preKey + key;

				if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
					DSA020[key] = $(newKey).getValue();
				}else if(!Object.isUndefined(default4A020[key])){
					DSA020[key] = default4A020[key];
				}else{
					DSA020[key] = "";
				}
			}
		);

		// checkBox欄位
		$w('CHK_NOR CHK_REJ CHK_REF REPAIR OTHER').each(
			function(key){
				var newKey = preKey + key;
				if($(newKey)){
					if($(newKey).checked){
						DSA020[key] = "1";
					}else{
						DSA020[key] = "0";
					}
				}else if(!Object.isUndefined(default4A020[key])){
					DSA020[key] = default4A020[key];
				}else{
					DSA020[key] = "";
				}
			}
		);

		if(B_type === "0"){//自然人
			// 特殊處理
			DSA020['TYPE'] = "0";

			//2017-08-28改模組內CALL共用模組以ID判斷性別1男2女
			/*if(DSA020['ID'] && DSA020['ID'].length == 10){
				DSA020['SEX'] = DSA020['ID'].substring(1,2);
			}else{
				DSA020['SEX'] = "";
			}*/

			var date = formatInput.ROCDate2Y2KDate($('B1_BIRTHDAY').innerHTML, false, "/");
			DSA020['BIRTHDAY'] = date ? date : null;

			DSA020['REG_ZIP'] = address_Map["B1"].getINPUT_ZIPCODE();

			DSA020['REG_ADDR'] = address_Map["B1"].getINPUT_ADDR();
			<%--20240906 難字處理--%>
			DSA020['NAME'] = $('B1_NAME_INPUT').getValue();
		}else{//法人
			// 特殊處理
			DSA020['TYPE'] = "0";

			//2017-08-28改模組內CALL共用模組以ID判斷性別1男2女
			//DSA020['SEX'] = "";

			var date = formatInput.ROCDate2Y2KDate($('B2_BIRTHDAY').innerHTML, false, "/");
			DSA020['BIRTHDAY'] = date ? date : null;

			DSA020['REG_ZIP'] = address_Map["B2"].getINPUT_ZIPCODE();

			DSA020['REG_ADDR'] = address_Map["B2"].getINPUT_ADDR();
			<%--20240906 難字處理--%>
			DSA020['NAME'] = $('B2_NAME').getValue();
		}

		DSA020['RELATION'] = "XX";

		if(action == "add" && type=="A"){
			if($('A_APPLY_ID').value != "" && $('A_APPLY_ID').value != DSA020['APPLY_ID']){
				if(confirm("請確認是否將資料新增到此 "+ $('A_APPLY_ID').value +" 受理編號中?")){
					DSA020['APPLY_ID'] = $('A_APPLY_ID').value;
				}else{
					return false;
				}
			}
		}

		// ---------- 目前經營事業(包括合夥事業) ----------
		var default4A021 = {
			CAPITAL:0,
			YEAR_VOLUME:0,
			BUILD_DATE:null,
			CAPITAL_RATE:0,
			SERV_YEAR:0,
			YEAR_PROFIT:0
		};

		var type = "C";
		var DSA021_VOList = [];
		var preKey = type + "_";
		var tbody = $('tbody_' + type);
		var length = tbody.rows.length;
		for(var i = 0; i < length; i=i+2){
			var no = tbody.rows[i].id;
			var DSA021 = {};

			// 輸入欄位
			$w('BUSS_NAME BUSS_CODE BUSINESS_CODE OCCU_CODE TEL_AREA TEL_NUM TEL_EXT USE_STATUS BUSS_ITEM CAPITAL YEAR_VOLUME CAPITAL_RATE YEAR_PROFIT BUSS_CORPID SERV_YEAR').each(
				function(key){
					var newKey = preKey + key + "_" + no;

					if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
						DSA021[key] = $(newKey).getValue();
					}else if(!Object.isUndefined(default4A021[key])){
						DSA021[key] = default4A021[key];
					}else{
						DSA021[key] = "";
					}
				}
			);

			// 特殊處理
			DSA021['APPLY_ID'] = DSA020['APPLY_ID'];
			DSA021['TYPE'] = DSA020['TYPE'];
			DSA021['ID'] = DSA020['ID'];
			DSA021['BUSS_ADDR'] = address_Map[type][no].getINPUT_ADDR();
			var date = formatInput.ROCDate2Y2KDate($(preKey + 'BUILD_DATE' + "_" + no).getValue(), false);
			DSA021['BUILD_DATE'] = date ? date : default4A021['BUILD_DATE'];

			DSA021_VOList.push(DSA021);
		}

		//---------- 目前服務單位 ----------
		var default4A022 = {
			SALARY:0,
			SERV_YEAR:0,
			YEAR_INCOME:0
		};

		var type = "D";
		var now_DSA022_VOList = [];
		var preKey = type + "_";
		var tbody = $('tbody_' + type);
		var length = tbody.rows.length;
		var isAML = "N";
		for(var i = 0; i < length; i=i+3){
			var no = tbody.rows[i].id;
			var DSA022 = {};

			// 輸入欄位
			$w('BUSS_ITEM SERV_NAME WORK_TYPE SERV_CODE SERV_TEL_AREA SERV_TEL_NUM SERV_TEL_EXT JOB_TITLE SALARY SERV_YEAR YEAR_INCOME SERV_CORPID BUSINESS_CODE OCCU_CODE').each(
				function(key){
					var newKey = preKey + key + "_" + no;

					if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
						DSA022[key] = $(newKey).getValue();
					}else if(!Object.isUndefined(default4A022[key])){
						DSA022[key] = default4A022[key];
					}else{
						DSA022[key] = "";
					}
				}
			);

			//電腦作業申請書評估報告-調整放款客戶高風險職業抓取規則
			/*705軍職人員、713 政治從業人員/村里長，加註提示用語：若為洗錢防制法所定義「重要政治性職務」之人，
			例如正副總統、秘書長、五院正副院長、立委監委考試委員、地方正副首長議長、中將以上、國營事業相當於簡任13職等以上之高管等，
			請改列為「220 洗錢防制法所定義之「重要政治性職務」之人」。僅提示，不做卡控*/
			if ("705" == DSA022['OCCU_CODE'] || "713" == DSA022['OCCU_CODE'] ) {
				isAML = "Y";
			}
			
			// 特殊處理
			DSA022['APPLY_ID'] = DSA020['APPLY_ID'];
			DSA022['TYPE'] = DSA020['TYPE'];
			DSA022['ID'] = DSA020['ID'];
			DSA022['SEQ_NO'] = "1";
			DSA022['SERV_ZIP'] = address_Map[type][no].getINPUT_ZIPCODE();
			DSA022['SERV_ADDR'] = address_Map[type][no].getINPUT_ADDR();

			now_DSA022_VOList.push(DSA022);
		}
		
		if ("Y" == isAML){		
			if(!confirm('若為洗錢防制法所定義「重要政治性職務」之人，例如正副總統、秘書長、五院正副院長、立委監委考試委員、地方正副首長議長、中將以上、國營事業相當於簡任13職等以上之高管等，請改列為「220 洗錢防制法所定義之「重要政治性職務」之人」。\r\n\r\n請確認是否要繼續執行?')) {
				return;
			}
		}
		
		//---------- 前職單位(目前營業或服務單位之年資未滿一年者請務必填寫) ----------
		var before_DSA022_VO = {};
		preKey = "E_";

		// 輸入欄位
		$w('BUSS_ITEM SERV_NAME WORK_TYPE SERV_CODE SERV_TEL_AREA SERV_TEL_NUM SERV_TEL_EXT JOB_TITLE SALARY SERV_YEAR YEAR_INCOME SERV_CORPID BUSINESS_CODE OCCU_CODE').each(
			function(key){
				var newKey = preKey + key;

				if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
					before_DSA022_VO[key] = $(newKey).getValue();
				}else if(!Object.isUndefined(default4A022[key])){
					before_DSA022_VO[key] = default4A022[key];
				}else{
					before_DSA022_VO[key] = "";
				}
			}
		);

		// 特殊處理
		before_DSA022_VO['APPLY_ID'] = DSA020['APPLY_ID'];
		before_DSA022_VO['TYPE'] = DSA020['TYPE'];
		before_DSA022_VO['ID'] = DSA020['ID'];
		before_DSA022_VO['SEQ_NO'] = "0";
		before_DSA022_VO['SERV_ZIP'] = "";
		before_DSA022_VO['SERV_ADDR'] = "";

		//---------- 本人其他不動產暨設定明細 ----------
		var default4A023 = {
			SET_AMT:0
		};

		var DSA023_VOList = [];
		var preKey = "G_";
		var tbody = $('tbody_G');
		var length = tbody.rows.length;
		for(var i = 0; i < length; i=i+3){
			var no = tbody.rows[i].id;
			var DSA023 = {};

			// 輸入欄位
			$w('ADDRESS LAND_NO1 LAND_NO2 BUILD_DOOR BUILD_NO1 BUILD_NO2 USE_STATUS SET_BANK SET_AMT').each(
				function(key){
					var newKey = preKey + key + "_" + no;

					if($(newKey) && ($(newKey).getValue() || !isNaN(parseInt($(newKey).getValue(), 10)))){
						DSA023[key] = $(newKey).getValue();
					}else if(!Object.isUndefined(default4A023[key])){
						DSA023[key] = default4A023[key];
					}else{
						DSA023[key] = "";
					}
				}
			);

			// 特殊處理
			DSA023['APPLY_ID'] = DSA020['APPLY_ID'];
			DSA023['TYPE'] = DSA020['TYPE'];
			DSA023['ID'] = DSA020['ID'];
			DSA023_VOList.push(DSA023);
		}

		rtnMap['DSA020_VO'] = DSA020;
		rtnMap['DSA021_VOList'] = DSA021_VOList;
		rtnMap['now_DSA022_VOList'] = now_DSA022_VOList;
		rtnMap['before_DSA022_VO'] = before_DSA022_VO;
		rtnMap['DSA023_VOList'] = DSA023_VOList;

		return rtnMap;
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
			config.disabled = config.disabled ? config.disabled : "true";
		}
		element = tableElement.addAttributes(element, config);
		if(element.display == 'hide'){
			element.style.display = 'none';
		}
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
		if(toFullwidth === true && GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
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
		if(!validates.isNumber(intLength, false)){
			intLength = 4;
		}else{
			intLength = Number(intLength);
		}

		if(!validates.isNumber(decLength, false)){
			decLength = 0;
		}else{
			decLength = Number(decLength);
		}

		var hasZeroDec = false;
		if(validates.isNumber(zeroDec, false)){
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

			if(hasZeroDec){
				pattern = pattern + "0";
			}else{
				pattern = pattern + "#";
			}
		}

		return pattern;
	},
	// 依照整數位數與小數位數決定欄位最大長度
	getMaxLength4Number:function(intLength, decLength, positive){
		if(!validates.isNumber(intLength, false)){
			intLength = 0;
		}

		if(!validates.isNumber(decLength, false)){
			decLength = 0;
		}

		positive = (positive == true) ? positive : false;

		var maxLength = 0;
		var integer = parseInt(intLength / 3, 10);
		var remainder = intLength % 3;
		if(Number(remainder) > 0){
			maxLength = Number(integer) + Number(intLength);
		}else{
			maxLength = Number(integer) + Number(intLength) - 1;
		}

		if(!positive){
			maxLength = maxLength + 1;
		}

		if(Number(decLength) > 0){
			maxLength = maxLength + Number(decLength) + 1;
		}

		return maxLength;
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
function ajaxPost( actionName, params, successAction, errorAction,isSynchronous){
   	new Ajax.Request(
		"<%=dispatcher%>/DSA1_0200/" + actionName,
		{ parameters: params,
		  asynchronous: (isSynchronous==null?true:isSynchronous),
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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="12%">
			受理編號
		</td>
		<td class="tbYellow2" colspan="5">
			<input id="A_APPLY_ID" name="A_APPLY_ID" fieldName="受理編號" type="text" class="textBox2" size="15" maxlength="11" value="">
		</td>
		<td class="tbYellow2" align="center" rowspan="2">
			<input id="A_btn_query" name="A_btn_query" type="button" class="button" value="查詢">
			<br/>
			<input id="A_btn_change" name="A_btn_change" type="button" class="button" value="變更">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="12%">
			更換借款人
		</td>
		<td class="tbYellow2">
			<select id="A_ID" name="A_ID" fieldName="更換借款人" alt="ch"></select><%-- [20240723]難字調整 --%>
		</td>
		<td class="tbYellow" width="12%">
			保人戶籍地址
		</td>
		<td id="A_DSZ01000" class="tbYellow2" >
			<select id="A_CHG_REG_CODE" name="A_CHG_REG_CODE" fieldName="保人戶籍地址碼"></select>
			<br/>
		</td>
		<td class="tbYellow" width="15%">
			戶籍地址所有人
		</td>
		<td class="tbYellow2" >
			<select id="A_CHG_REG_OWNER" name="A_CHG_REG_OWNER" fieldName="戶籍地址所有人"></select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="7">
			<input id="A_btn_clear" name="A_btn_clear" type="button" class="button" value="清除">
			<input id="A_btn_add" name="A_btn_add" type="button" class="button" value="新增">
			<input id="A_btn_update" name="A_btn_update" type="button" class="button" value="修改">
			<input id="A_btn_delete" name="A_btn_delete" type="button" class="button" value="刪除">
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<%-- 基本資料 --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">基本資料</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<%-- 基本資料-自然人--%>
			<div id="div_B" style="display:block;">
			<table id="table_B1" name="table_B1" class="tbBox2" cellspacing="1" style="width:100%; border:0; display:block;">
				<tr>
					<td class="tbYellow" width="12%">
						受理編號
					</td>
					<td class="tbYellow2" width="32%">
						<span id="B1_APPLY_ID" fieldName="受理編號"></span>
					</td>
					<td class="tbYellow" width="16%">
						受理進度
					</td>
					<td class="tbYellow2" width="40%">
						<span id="B1_APPLY_PROCESS_NM" fieldName="受理進度"></span>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						姓名
					</td>
					<td class="tbYellow2">
						<span id="B1_NAME" fieldName="姓名" style="font-family:'EUDC'"></span><%--[20240722]難字調整 --%>
						<input type="hidden" id="B1_NAME_INPUT" name="B1_NAME_INPUT" alt="ch"/>
					</td>
					<td class="tbYellow">
						出生日期
					</td>
					<td class="tbYellow2">
						<span id="B1_BIRTHDAY" fieldName="出生日期"></span>
						&nbsp;-&nbsp;
						<span id="B1_AGE" fieldName="年紀"></span>
						歲
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						統一編號
					</td>
					<td class="tbYellow2">
						<span id="B1_ID" fieldName="統一編號"></span>
					</td>
					<td class="tbYellow">
						戶籍地址
					</td>
					<td id="B1_DSZ01000" class="tbYellow2">
						<select id="B1_REG_CODE" name="B1_REG_CODE" fieldName="戶籍地址碼"></select>
						<br/>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						戶籍所有人
					</td>
					<td class="tbYellow2">
						<select id="B1_REG_OWNER" name="B1_REG_OWNER" fieldName="戶籍所有人"></select>
					</td>
					<td class="tbYellow">
						通訊地址使用狀況
					</td>
					<td class="tbYellow2">
						<select id="B1_USE_STATUS" name="B1_USE_STATUS" fieldName="通訊地址使用狀況"></select>
						<input id="B1_USE_STATUS_CONTENT" name="B1_USE_STATUS_CONTENT" fieldName="通訊地址使用狀況－其他說明" type="text" class="textBox2" size="30" maxlength="60" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						學歷
					</td>
					<td class="tbYellow2">
						<select id="B1_DEGREE" name="B1_DEGREE" fieldName="學歷"></select>
						<br/>
						學校：<input id="B1_SCHOOL" name="B1_SCHOOL" fieldName="學校" type="text" class="textBox2" size="20" maxlength="20" value="">
						<br/>
						科系：<input id="B1_DEPARTMENT" name="B1_DEPARTMENT" fieldName="科系" type="text" class="textBox2" size="20" maxlength="30" value="">
					</td>
					<td class="tbYellow">
						婚姻狀況
					</td>
					<td class="tbYellow2">
						<select id="B1_MARRY" name="B1_MARRY" fieldName="婚姻狀況"></select>
						<br/>
						配偶姓名：
						<input id="B1_SPOUSE_NAME" name="B1_SPOUSE_NAME" fieldName="配偶姓名" type="text" class="textBox2" size="12" maxlength="60" value="">
						<select id="B1_SPOUSE_LIVE" name="B1_SPOUSE_LIVE" fieldName="配偶存歿" class="textBox2"></select>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						子女人數
					</td>
					<td class="tbYellow2">
						<select id="B1_SON_NO" name="B1_SON_NO" fieldName="子女人數(男)"></select>
						男
						<select id="B1_GIRL_NO" name="B1_GIRL_NO" fieldName="子女人數(女)"></select>
						女
					</td>
					<td class="tbYellow">
						檢附相關資料
					</td>
					<td class="tbYellow2">
						<span id="B1_DOCS"></span>
						<input id="B1_DOCS_CONTENT" name="B1_DOCS_CONTENT" type="text" fieldName="檢附相關資料－其他說明" class="textBox2" size="30" maxlength="60" value="" disabled>
					</td>
				</tr>
				<tr>											
					<%-- [20210205] 聯徵公務機關資料查調作業--%>		
					<td class="tbYellow">
						查調公務機關授權
					</td>
					<td class="tbYellow2" colspan="3">
						<input id="B1_AGREE" name="B1_AGREE" fieldName="查調公務機關授權-同意 或 -不同意" type="radio" value="Y" >
						同意
						<input id="B1_NOT_AGREE" name="B1_AGREE" fieldName="查調公務機關授權-同意 或 -不同意" type="radio" value="N" >
						不同意
						<input id="B1_JCIC_T50" name="B1_JCIC_T50" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T50年度所得
						<input id="B1_JCIC_T51" name="B1_JCIC_T51" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T51財產清單
						<input id="B1_JCIC_T52" name="B1_JCIC_T52" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T52勞保資料 &nbsp
						授權起迄
						<input name="B1_QUERY_DATE_S" id="B1_QUERY_DATE_S" type="text" class="textBox2"/>						
						~<input name="B1_QUERY_DATE_E" id="B1_QUERY_DATE_E" type="text" class="textBox2"/>
						
					</td> 
				</tr>
				<%-- [20191216] 法金專案 增加 註冊國家 --%>
				<tr>
					<td class="tbYellow" id="B1_NATION_ITEM">註冊國家</td>
					<td class="tbYellow2" colspan="3">		
						<input type="text" id="B1_COUNTRY_NM" name="B1_COUNTRY_NM" size="40" maxlength="40"/>						 			
						<input type="hidden" id="B1_COUNTRY" name="B1_COUNTRY"/>						
					</td>					
				</tr>
				
			</table>

			<%-- 基本資料-法人--%>
			<table id="table_B2" name="table_B2" class="tbBox2" cellspacing="1" style="width:100%; border:0; display:none;">
				<tr>
					<td class="tbYellow" width="12%">
						受理編號
					</td>
					<td class="tbYellow2" width="38%">
						<span id="B2_APPLY_ID" fieldName="受理編號"></span>
					</td>
					<td class="tbYellow" width="12%">
						受理進度
					</td>
					<td class="tbYellow2" width="38%">
						<span id="B2_APPLY_PROCESS_NM" fieldName="受理進度"></span>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						姓名
					</td>
					<td class="tbYellow2">
						<%--[20240722]難字調整 --%>
						<input id="B2_NAME" fieldName="姓名" alt="ch" readonly/>
					</td>
					<td class="tbYellow">
						成立日期
					</td>
					<td class="tbYellow2">
						<span id="B2_BIRTHDAY" fieldName="成立日期"></span>
						<%-- [20221121] 增加顯示成立多少年 --%>
						&nbsp;-&nbsp;
						<span id="B2_AGE" fieldName="年"></span>
						年
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						統一編號
					</td>
					<td class="tbYellow2">
						<span id="B2_ID" fieldName="統一編號"></span>
					</td>
					<%-- [20191216] 欄位名稱調整 --%>
					<td class="tbYellow">
						營登地址
					</td>
					<td id="B2_DSZ01000" class="tbYellow2">
						<select id="B2_REG_CODE" name="B2_REG_CODE" fieldName="戶籍地址碼"></select>
						<br/>
					</td>
				</tr>
				<tr>
					<%-- [20191216] 欄位名稱調整 --%>
					<td class="tbYellow">
						營登所有人
					</td>
					<td class="tbYellow2">
						<select id="B2_REG_OWNER" name="B2_REG_OWNER" fieldName="戶籍所有人"></select>
					</td>
					<td class="tbYellow">
						通訊地址使用狀況
					</td>
					<td class="tbYellow2">
						<select id="B2_USE_STATUS" name="B2_USE_STATUS" fieldName="通訊地址使用狀況"></select>
						<input id="B2_USE_STATUS_CONTENT" name="B2_USE_STATUS_CONTENT" fieldName="通訊地址使用狀況－其他說明" type="text" class="textBox2" size="30" maxlength="60" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						負責人
					</td>
					<td class="tbYellow2">
						<input id="B2_SPOUSE_NAME" name="B2_SPOUSE_NAME" fieldName="負責人" type="text" class="textBox2" size="15" maxlength="60" value="" alt="ch"/><%--[20240722]難字調整 --%>
					</td>
					<td class="tbYellow">
						檢附相關資料
					</td>
					<td class="tbYellow2" colspan="3">
						<span id="B2_DOCS"></span>
						<input id="B2_DOCS_CONTENT" name="B2_DOCS_CONTENT" fieldName="檢附相關資料－其他說明" type="text" class="textBox2" size="30" maxlength="60" value="" disabled>
					</td>
				</tr>
				<tr>											
					<%-- [20210205] 聯徵公務機關資料查調作業--%>		
					<td class="tbYellow">
						查調公務機關授權
					</td>
					<td class="tbYellow2" colspan="3">
						<input id="B2_AGREE" name="B2_AGREE" fieldName="查調公務機關授權-同意 或 -不同意" type="radio" value="Y" >
						同意
						<input id="B2_NOT_AGREE" name="B2_AGREE" fieldName="查調公務機關授權-同意 或 -不同意" type="radio" value="N" >
						不同意
						<input id="B2_JCIC_T50" name="B2_JCIC_T50" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T50年度所得
						<input id="B2_JCIC_T51" name="B2_JCIC_T51" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T51財產清單
						<input id="B2_JCIC_T52" name="B2_JCIC_T52" fieldName="T50年度所得/T51財產清單/T52勞保資料" type="checkbox" value="Y">
						T52勞保資料 &nbsp
						授權起迄						
						<input name="B2_QUERY_DATE_S" id="B2_QUERY_DATE_S" type="text" class="textBox2"/>						
						~<input name="B2_QUERY_DATE_E" id="B2_QUERY_DATE_E" type="text" class="textBox2"/>
					</td> 
				</tr>
				<%-- [20191216] 法金專案 增加 註冊國家 --%>
				<tr>
					<td class="tbYellow" id="B2_NATION_ITEM">註冊國家</td>
					<td class="tbYellow2" colspan="3">		
						<input type="text" id="B2_COUNTRY_NM" name="B2_COUNTRY_NM" size="40" maxlength="40" />						 			
						<input type="hidden" id="B2_COUNTRY" name="B2_COUNTRY"/>						
					</td>									 
				</tr>
			</table>
			</div>
		</td>
	</tr>

	<%-- 目前經營事業(包括合夥事業) --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">目前經營事業(包括合夥事業)</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<div id="div_C" style="overflow:auto; display:block;">
			<table id="table_C" name="table_C" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<thead align="center" style="font-weight: bold;">
					<tr>
						<td class="tbBlue" rowspan="2" width="6%">
							選取
						</td>
						<td class="tbBlue">
							事業名稱
						</td>
						<td class="tbBlue">
							統一編號
						</td>
						<td class="tbBlue" colspan="2">
							行業別
						</td>
						<td class="tbBlue" colspan="3">
							職業類別
						</td>
						<td class="tbBlue" colspan="2">
							事業處所
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							營業項目
						</td>
						<td class="tbBlue">
							資本額
						</td>
						<td class="tbBlue">
							年營業額
						</td>
						<td class="tbBlue">
							年淨利
						</td>
						<td class="tbBlue">
							出資比率
						</td>
						<td class="tbBlue">
							創立時間(年月)
						</td>
						<td class="tbBlue">
							服務年資
						</td>
						<td class="tbBlue">
							電話
						</td>
						<td class="tbBlue">
							營業處所使用情形
						</td>
					</tr>
				</thead>
				<tbody id="tbody_C"></tbody>
				<tfoot align="center">
					<tr>
						<td class="tbBlue2" colspan="10">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" colspan="10">
							<input id="C_btn_add" name="C_btn_add" type="button" class="button" value="新增">
							<input id="C_btn_delete" name="C_btn_delete" type="button" class="button" value="刪除">
						</td>
					</tr>
				</tfoot>
			</table>
			</div>
		</td>
	</tr>

	<%-- 目前服務單位 --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">目前服務單位</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<div id="div_D" style="overflow:auto; display:block;">
			<table id="table_D" name="table_D" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<thead align="center" style="font-weight: bold;">
					<tr>
						<td class="tbBlue" rowspan="3" width="6%">
							選取
						</td>
						<td class="tbBlue">
							營業項目
						</td>
						<td class="tbBlue">
							服務單位名稱
						</td>
						<td class="tbBlue">
							身分別
						</td>
						<td class="tbBlue">
							統一編號
						</td>
						<td class="tbBlue">
							行業別
						</td>
					</tr>	
					<tr>
						<td class="tbBlue">
							職位
						</td>
						<td class="tbBlue">
							月薪
						</td>
						<td class="tbBlue">
							服務年資
						</td>
						<td class="tbBlue">
							年所得(含獎金)
						</td>
						<td class="tbBlue">
							職業類別
						</td>
					</tr>
					<tr >
						<td class="tbBlue" colspan="4">
							詳細地址
						</td>
						<td class="tbBlue" colspan="2">
							電話
						</td>
					</tr>
				</thead>
				<tbody id="tbody_D"></tbody>
				<tfoot align="center">
					<tr>
						<td class="tbBlue2" colspan="9">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" colspan="9">
							<input id="D_btn_add" name="D_btn_add" type="button" class="button" value="新增">
							<input id="D_btn_delete" name="D_btn_delete" type="button" class="button" value="刪除">
						</td>
					</tr>
				</tfoot>
			</table>
			</div>
		</td>
	</tr>

	<%-- 前職單位(目前營業或服務單位之年資未滿一年者請務必填寫) --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">前職單位(目前營業或服務單位之年資未滿一年者請務必填寫)</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<div id="div_E" style="overflow:auto; display:block;">
			<table id="table_E" name="table_E" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<tr>
					<td class="tbYellow">
						服務單位名稱
					</td>
					<td class="tbYellow2" colspan="3">
						<input id="E_SERV_NAME" name="E_SERV_NAME" fieldName="服務單位名稱" type="text" class="textBox2" size="30" maxlength="60" value="">
					</td>
					<td class="tbYellow" width="12%">
						營業項目
					</td>
					<td class="tbYellow2" width="21%">
						<input id="E_BUSS_ITEM" name="E_BUSS_ITEM" fieldName="營業項目" type="text" class="textBox2" size="20" maxlength="20" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						職位
					</td>
					<td class="tbYellow2">
						<input id="E_JOB_TITLE" name="E_JOB_TITLE" fieldName="職位" type="text" class="textBox2" size="20" maxlength="20" value="">
					</td>
					<td class="tbYellow">
						服務年資
					</td>
					<td class="tbYellow2" width="11%">
						<input id="E_SERV_YEAR" name="E_SERV_YEAR" fieldName="服務年資" type="text" class="textBox2" datatype="number" pattern ="###" size="3" maxlength="3" value="">
						年
					</td>
					<td class="tbYellow">
						年所得(含獎金)
					</td>
					<td class="tbYellow2">
						<input id="E_YEAR_INCOME" name="E_YEAR_INCOME" fieldName="年所得(含獎金)" type="text" class="textBox2" datatype="number" intLength="7" decLength="2" pattern ="#,###.##" size="15" maxlength="13" value="">
						萬
					</td>
				</tr>
			</table>
			</div>
		</td>
	</tr>

	<%-- 個人(含配偶)全年收支情形 --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">個人(含配偶)全年收支情形</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<div id="div_F" style="overflow:auto; display:block;">
			<table id="table_F" name="table_F" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<tr>
					<td class="tbYellow" width="18%">
						支存狀況
					</td>
					<td class="tbYellow2" colspan="3">
						<input id="F_CHK_NOR" name="F_CHK_NOR" fieldName="支存狀況－正常" type="checkbox" value="1">
						正常
						<input id="F_CHK_REJ" name="F_CHK_REJ" fieldName="支存狀況－拒往" type="checkbox" value="1">
						拒往
						<input id="F_CHK_REF" name="F_CHK_REF" fieldName="支存狀況－退票" type="checkbox" value="1">
						退票
						<input id="F_REF_TIMES" name="F_REF_TIMES" fieldName="支存狀況－退票次數" type="text" datatype="number" pattern ="##" size="2" maxlength="2" value="" disabled>
						次
						<input id="F_REPAIR" name="F_REPAIR" fieldName="支存狀況－退補" type="checkbox" value="1">
						退補
						<input id="F_REPAIR_TIMES" name="F_REPAIR_TIMES" fieldName="支存狀況－退補次數" type="text" datatype="number" pattern ="##" size="2" maxlength="2" value="" disabled>
						次
						<input id="F_OTHER" name="F_OTHER" fieldName="支存狀況－其他" type="checkbox" value="1">
						其他
						<input id="F_OTHER_CONTENT" name="F_OTHER_CONTENT" fieldName="支存狀況－其他說明" type="text" size="30" maxlength="60" value="">
					</td>
				</tr>
				<tr align="center" style="font-weight: bold;">
					<td class="tbBlue" width="32%">
						收入項目
					</td>
					<td class="tbBlue" width="18%">
						金額(單位：萬元)
					</td>
					<td class="tbBlue" width="32%">
						支出項目
					</td>
					<td class="tbBlue" width="18%">
						金額(單位：萬元)
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						經營事業/薪資收入(年所得含獎金)
					</td>
					<td class="tbYellow2" align="center">
						<input id="F_INCOME" name="F_INCOME" fieldName="經營事業/薪資收入" type="text" class="textBox2" datatype="number" intLength="5" decLength="2" pattern ="#,###.##" size="10" maxlength="10" value="">
					</td>
					<td class="tbYellow">
						家庭生活支出
					</td>
					<td class="tbYellow2" align="center">
						<input id="F_HOME_EXP" name="F_HOME_EXP" fieldName="家庭生活支出" type="text" class="textBox2" datatype="number" intLength="5" decLength="2" pattern ="#,###.##" size="10" maxlength="10" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow">
						其他收入 (租賃、利息、其他<input id="F_OTHER_INCOME_ITEM" name="F_OTHER_INCOME_ITEM" fieldName="其他收入－其他" type="text" class="textBox2" size="20" maxlength="10" value="">等)
					</td>
					<td class="tbYellow2" align="center">
						<input id="F_OTHER_INCOME" name="F_OTHER_INCOME" fieldName="其他收入" type="text" class="textBox2" datatype="number" intLength="5" decLength="2" pattern ="#,###.##" size="10" maxlength="10" value="">
					</td>
					<td class="tbYellow">
						其他支出 (租賃、利息、其他<input id="F_OTHER_EXP_ITEM" name="F_OTHER_EXP_ITEM" fieldName="其他支出－其他" type="text" class="textBox2" size="20" maxlength="10" value="">等)
					</td>
					<td class="tbYellow2" align="center">
						<input id="F_OTHER_EXP" name="F_OTHER_EXP" fieldName="其他支出" type="text" class="textBox2" datatype="number" intLength="5" decLength="2" pattern ="#,###.##" size="10" maxlength="10" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" align="center">
						合計
					</td>
					<td class="tbYellow2" align="center">
						<span id="F_INCOME_TOTAL" fieldName="收入合計" intLength="6" decLength="2" pattern="#,###.##"></span>
					</td>
					<td class="tbYellow" align="center">
						合計
					</td>
					<td class="tbYellow2" align="center">
						<span id="F_EXP_TOTAL" fieldName="支出合計" intLength="6" decLength="2" pattern="#,###.##"></span>
					</td>
				</tr>
			</table>
			</div>
		</td>
	</tr>

	<%-- 本人其他不動產暨設定明細 --%>
	<tr>
		<td class="tbYellow0" align="center" colspan="7">
			<span style="font-weight: bold;">本人其他不動產暨設定明細</span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" colspan="7">
			<div id="div1" style="overflow:auto; display:block;">
			<table id="table_G" name="table_G" class="tbBox2" cellspacing="1" style="width:100%; border:0;">
				<thead align="center" style="font-weight: bold;">
					<tr>
						<td class="tbBlue" rowspan="3" width="6%">
							選取
						</td>
						<td class="tbBlue">
							座落所在地
						</td>
						<td class="tbBlue">
							地號
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							建物門牌
						</td>
						<td class="tbBlue">
							建號
						</td>
					</tr>
					<tr>
						<td class="tbBlue">
							使用情形
						</td>
						<td class="tbBlue">
							設定情形
						</td>
					</tr>
				</thead>
				<tbody id="tbody_G"></tbody>
				<tfoot align="center">
					<tr>
						<td class="tbBlue2" colspan="3">
							&nbsp;
						</td>
					</tr>
					<tr>
						<td class="tbYellow2" colspan="3">
							<input id="G_btn_add" name="G_btn_add" type="button" class="button" value="新增">
							<input id="G_btn_delete" name="G_btn_delete" type="button" class="button" value="刪除">
						</td>
					</tr>
				</tfoot>
			</table>
			</div>
		</td>
	</tr>
</table>
</body>
</html>