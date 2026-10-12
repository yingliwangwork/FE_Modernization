<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%--
程式：DSC31611.jsp
作者：余凱鈞
功能：現金入帳金額分配
完成：2013/09/23
調整：2018-01-02先回復正式版本供問題單編號20180102-0172測試，再調整回前一版本
      2018-01-29因應繳款服務單調整，新增負責人ID、具控制權自然人1~3的ID欄位

[20190802] 修改件
           入帳確認：[繳款/發票]人姓名/法人名稱(PAY_NAME)：
           a.可輸入長度調整為VARCHAR 100 (若有檢核順便調整) [20190802] (a)
           b.增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) [20190802] (b)
           c.後端檢核(DSC3_1610_mod().checkPayinfo)
           【PAY_NAME_RM】需符合原住民羅馬拼音格式(STRING.isROCAboriginesName_RM)
           d.【PAY_NAME_RM】寫入：DTDSC117.PAY_NAME_RM
--%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->
<script type="text/javascript" src='${htmlBase}/CM/js/ui/TableUI.js'></script>     <%-- 表格用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/PageUI.js'></script>      <%-- 標準外框表格 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/JavaScript" src='${htmlBase}/CM/js/calendar.js'></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/validation.js'></script>	<%-- 檢核用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC31611().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31611(){
	var gridA;
	var gridB;
	var valid;
	var BillList;
	var ISTIC="";
	var PAY_TYPE="";
	var GETINT_CODE="";
	var SPEC="0";
	var isXZeroPayOff="";
	var borrowCount = "0";
	var PayRelationList = ${PayRelationList} || [];

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){
		new Ajax.Request( "<%=dispatcher%>/DSC3_1611/" + actionName,
			{
				parameters: params,
				onSuccess:function(response){
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successFunction){
							successFunction(resp);
						}
					}else{
						if(errorFunction){
							errorFunction(resp);
						}
					}
				}
			});
	}

	//檢核
	function initValidation(){
		Validation.addAllThese([
			[ 'validateRECEIPT_SERNO', '單據序號輸入有誤!',
				function(v){
					return v.length == 10;
				}
			],
			[ 'AMT_Required', '請輸入現金匯款金額',
				function(v){
					return v.length > 0;
				}
			],
			// ====================== 繳款服務單檢核 START ======================
			['validPAY_RELATION', '請選擇繳款人關係',
				function(v) {
					return '請選擇' != v;
				}],
			//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
			//繳款人為法人(1)->關係不可為CPSW(配偶父母子女負責人)
			['validPAY_RELATION2', '繳款人為[法人]，關係別不可選[配偶、父母、子女、負責人]',
				function(v) {
					if($F('COPR_CODE') == '1'){
						if(v=='C'||v=='P'||v=='S'||v=='W'){
							return false;
						}
					}
					return true;
				}],
			[ 'checkPAY_RELATION', '若繳款人關係為[其他]需填入其他關係、代繳原因',
				function(v, node){
					var selectValue = '';
					var pre = node.previousSiblings();
					for(var i = 0; i < pre.length; i++){
						var item = pre[i];
						if(item.nodeName == 'SELECT'){
							selectValue = item.getValue();
						}
					}
					if(selectValue == 'O'){
						return !Validation.get('IsEmpty').test(v);
					}
					return true;
				}
			],
			[ 'checkCHIEF', '繳款人為[法人]需填入負責人姓名',
				function(v){
					if ($('COPR_CODE').value == '1'){
						return !Validation.get('IsEmpty').test(v);
					}
					return true;
				}
			],
			[ 'checkPAY_ID', '請輸入正確身分證字號、統一編號或居留證號',
				function(v){
					if ($('COPR_CODE').value == '1'){
							if ($('NATION_CODE').value != 'TW'){
								return v.length == 10;
							} else {

								var checkUniSN = validation.checkUniSN( v );
								//需符合統編規則，否則顯示提示訊息："繳款種類為法人，必須符合統編規則，是否繼續作業"，若選擇是，則往下繼續執行作業
								if(checkUniSN != true) {
									if(!confirm('繳款種類為[法人]，輸入值不符合統編規則，是否繼續作業')) {
										return;
									}
								}
								return true;
							}
					} else if ($('NATION_CODE').value != 'TW'){
							return v != '';
					} else {
							return validation.checkROCID( v );
					}
					return true;
				}
			],
			//2018-01-03調整判斷是否需填電話之規則
			[ 'checkTEL_NO', '若繳款人關係非為[借款人]且繳款方式為[現金]需填正確[電話]',
				function(v){
					var re = actions.getPayRelations();
					if (re != null){
						for (i = 0; i < re.length; i++){
							if (re[i]['PAY_RELATION'] =="B"){
								return true;
							}
						}
						var checkTable = "#-0123456789"; //2018-01-09規則同繳款服務單畫面，僅能填入0~9,-,#
							if($F('TEL_NO')){
								for ( var i = 0 ; i < v.length ; i ++ ) {
									var val = v.charAt(i) ;
									if (checkTable.indexOf(val) == -1){
									return false;
									}
								}
								return !Validation.get('IsEmpty').test(v);
							} else {
								return !Validation.get('IsEmpty').test(v);
							}
					}
					return true;
				}
			],
			//2018-01-12跟壽二毓華確認繳款服務單檢核生日與電話規則皆為 繳現非借款人需填
			[ 'checkBIRTH_DATE', '若繳款人關係非為[借款人]且繳款方式為[現金]需填[生日/法人註冊日期]',
				function(v){
					var re = actions.getPayRelations();
					if (re != null){
						for (i = 0; i < re.length; i++){
							if (re[i]['PAY_RELATION'] =="B"){
								return true;
							}
						}
						return !Validation.get('IsEmpty').test(v)
					}
					return true;
				}
			],
			//姓名是否輸入檢核
			[ 'checkCHIEF_ID', '若有輸入負責人ID，請也輸入負責人姓名',
				function(v){
					if (v){
						return !Validation.get('IsEmpty').test($('CHIEF').value);
					}
					return true;
				}
			],
			[ 'checkNATURAL_PERSON1_ID', '若有輸入具控制權之自然人1 ID，請也輸入具控制權之自然人1姓名',
				function(v){
					if (v){
						return !Validation.get('IsEmpty').test($('NATURAL_PERSON1').value);
					}
					return true;
				}
			],
			[ 'checkNATURAL_PERSON2_ID', '若有輸入具控制權之自然人2 ID，請也輸入具控制權之自然人2姓名',
				function(v){
					if (v){
						return !Validation.get('IsEmpty').test($('NATURAL_PERSON2').value);
					}
					return true;
				}
			],
			[ 'checkNATURAL_PERSON3_ID', '若有輸入具控制權之自然人3 ID，請也輸入具控制權之自然人3姓名',
				function(v){
					if (v){
						return !Validation.get('IsEmpty').test($('NATURAL_PERSON3').value);
					}
					return true;
				}
			],
			//姓名長度檢核
			<%-- [20190802] (a) 修改：可輸入長度調整為VARCHAR 100 (若有檢核順便調整) --%>
			[ 'checkLength100', '姓名長度超過50中文字或100個英文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 100){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_C', '負責人姓名長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_1', '具控制權之自然人姓名1長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_2', '具控制權之自然人姓名2長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			[ 'checkLength60_3', '具控制權之自然人姓名3長度超過30個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 60){
						return false;
					}
					return true;
				}
			],
			//問題單編號 20211022-0134 其他關係輸入超過10個中文字，導致寫入不了繳款服務單DTACE017 BY余凱鈞 
			[ 'checkLength20', '其他關係長度超過10個全形文字，請確認',
				function(v){
					var fullWordArray = v.match(/[^\x00-\xff]/g);
					var halfWordArray = v.match(/[\x00-\xff]/g);

					var fullWordLength = fullWordArray==null?0:fullWordArray.length;
					var halfWordLength = halfWordArray==null?0:halfWordArray.length;
					if((fullWordLength*(window.charCountsByte || 2)+halfWordLength) > 20){
						return false;
					}
					return true;
				}
			]
			// ====================== 繳款服務單檢核 END ======================
		])
		valid = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator', checkDisabled:true});
		valid.define('validateRECEIPT_SERNO' , { id: "RECEIPT_SERNO" , errMsg:"單據序號輸入有誤!" } );
	}

	var buttons = {
		//入帳確認
		doBillIn : function(){
			valid.reset();

			var dataList = gridA.getAllRecords();

			//判斷是否有值
			if(!dataList.size()>0){
				alert("無現金匯款入帳試算結果，不得入帳確認!")
				return;
			}

			//入帳確認檢核
			if(!valid.validate()){
				return;
			}

			//關係人選單檢核
			if ("Y" != $F('noWrite')){ //2018-01-15問題單20180115-0068，因繳現低於5萬者不需填繳款服務單資訊，故不需檢核繳款人關係
				if(!actions.checkSelectedPAY_RELATIONS()){
					alert("繳款人關係選取有誤，需為同一繳款人，請確認後再重新入帳!");
					return;
				};
			}

			$('CHIEF').value = methods.unAsc($('CHIEF').value);
			$('NATURAL_PERSON1').value = methods.unAsc($('NATURAL_PERSON1').value);
			$('NATURAL_PERSON2').value = methods.unAsc($('NATURAL_PERSON2').value);
			$('NATURAL_PERSON3').value = methods.unAsc($('NATURAL_PERSON3').value);
			//$('NATURAL_PERSON4').value = methods.unAsc($('NATURAL_PERSON4').value);
			$('PAY_NAME').value = methods.unAsc($('PAY_NAME').value);
			<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
			$('PAY_NAME_RM').value = methods.unAsc($('PAY_NAME_RM').value);

			var PAY_INFO ={};
			PAY_INFO['noWrite'] = $('noWrite').value;
			if ("N" == $F('noWrite')){//需寫繳款服務單(繳款人)
				PAY_INFO = {
					RELATION : actions.getPayRelations(),
					PAY_ID : $('PAY_ID').value,
					COPR_CODE : $F('COPR_CODE'),
					PAY_NAME : $F('PAY_NAME'),
					<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
					PAY_NAME_RM : $F('PAY_NAME_RM'),
					BIRTH_DATE : $F('BIRTH_DATE'),
					TEL_NO : $F('TEL_NO'),
					NATION_CODE : $F('NATION_CODE'),
					OCR_NATION_CODE : $F('OCR_NATION_CODE'),
					CHIEF : $F('CHIEF'),
					NATURAL_PERSON1 : $F('NATURAL_PERSON1'),
					NATURAL_PERSON2 : $F('NATURAL_PERSON2'),
					NATURAL_PERSON3 : $F('NATURAL_PERSON3'),
					CHIEF_ID : $F('CHIEF_ID'),
					NATURAL_PERSON1_ID : $F('NATURAL_PERSON1_ID'),
					NATURAL_PERSON2_ID : $F('NATURAL_PERSON2_ID'),
					NATURAL_PERSON3_ID : $F('NATURAL_PERSON3_ID'),
					noWrite : $F('noWrite')
					//NATURAL_PERSON4 : $F('NATURAL_PERSON4')
				};
			}else{//不需寫繳款服務單,還是要檢核借款人及保證人的洗錢防制(需寫C117)
				//180828:問題單20180828-0010 只抓第一筆就好,否則一次銷多筆會造成資料重複
				var RELATION = [];
				for(var i=0;i<PayRelationList.length;i++){
					var payRelationMap = PayRelationList[i];
					var RELATION_MAP = {
						BORROW_ID : payRelationMap.BORROW_ID,
						BORROW_NAME : payRelationMap.BORROW_NAME,
						PAY_RELATION : "O",
						OTHER_RELATION: "",
						PAY_REASON : ""
					};
					RELATION.push(RELATION_MAP);
				}

				PAY_INFO = {
					RELATION : RELATION,
					noWrite : $F('noWrite')
				};
			}

			ajaxPost( 'billin', {	BillList : Object.toJSON(dataList),
									PAY_TYPE : '${PAY_TYPE}',
									ISTIC : '${ISTIC}',
									SPEC : '${SPEC}',
									GETINT_CODE : '${GETINT_CODE}',
									isXZeroPayOff :'${isXZeroPayOff}',
									RECEIPT_SERNO: $F('RECEIPT_SERNO'),
									PAY_INFO : Object.toJSON(PAY_INFO)}
				,function(resp){

					if(resp.ERR_MSG){
						alert(resp.ERR_MSG);
						var parms = {//180917:申請書(180828001571):新增可疑交易檢核
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						};
						actions.doPopup( parms );
					}
					//2019-01-28：申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
					//威國：該繳款人為業務同仁，比照保費部作業，依「受理保戶以匯款方式繳交保險費應注意事項」不得收取大於五萬元之現金保費後，再以匯款單、支票等其他方式入帳，
					else if(resp.BEFORE_TIPS_MSG){//執行前提示訊息
						if(!confirm(resp.BEFORE_TIPS_MSG)){//點選確認後繼續作業
							return;
						}
						ajaxPost( 'billin', {	BillList : Object.toJSON(dataList),
							PAY_TYPE : '${PAY_TYPE}',
							ISTIC : '${ISTIC}',
							SPEC : '${SPEC}',
							GETINT_CODE : '${GETINT_CODE}',
							isXZeroPayOff :'${isXZeroPayOff}',
							RECEIPT_SERNO: $F('RECEIPT_SERNO'),
							PAY_INFO : Object.toJSON(PAY_INFO),
							isSecondTime : 'Y',
							TIPS_MSG : resp.TIPS_MSG }
						,function(resp){
							successFuncForBillin(resp);
						});
					}else {
						successFuncForBillin(resp);
					}
				}
			);
		}
	};

	function successFuncForBillin(resp){
		if(resp.TIPS_MSG){//執行後提示訊息
			alert(resp.TIPS_MSG); //2018-01-29提示：負責人或具控制權自然人若無ID，且為制裁名單，需提示(因無ID資訊無法填寫洗錢防制檢核紀錄，請確實申報，並與收費管理科聯繫)
		}
		var LP_JSON = {
			action : '<%=dispatcher%>/DSC3_1620/prompt',
			BillListStr : resp.BillListStr,
			PAY_TYPE : '${PAY_TYPE}',
			ISTIC : '${ISTIC}',
			SPEC : '${SPEC}',
			GETINT_CODE : '${GETINT_CODE}',
			isXZeroPayOff : '${isXZeroPayOff}',
			INPUT_ID : resp.INPUT_ID,
			INPUT_DEPT : resp.INPUT_DEPT,
			RECEIPT_SERNO: $('RECEIPT_SERNO').value
		};
		CSRUtil.linkTo(LP_JSON , 'form');
	};

	var methods = {
		//轉全形
		unAsc : function (text) {
			var asciiTable = "!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
			var big5Table = "%uFF01%u201D%uFF03%uFF04%uFF05%uFF06%u2019%uFF08%uFF09%uFF0A%uFF0B%uFF0C%uFF0D%uFF0E%uFF0F%uFF10%uFF11%uFF12%uFF13%uFF14%uFF15%uFF16%uFF17%uFF18%uFF19%uFF1A%uFF1B%uFF1C%uFF1D%uFF1E%uFF1F%uFF20%uFF21%uFF22%uFF23%uFF24%uFF25%uFF26%uFF27%uFF28%uFF29%uFF2A%uFF2B%uFF2C%uFF2D%uFF2E%uFF2F%uFF30%uFF31%uFF32%uFF33%uFF34%uFF35%uFF36%uFF37%uFF38%uFF39%uFF3A%uFF3B%uFF3C%uFF3D%uFF3E%uFF3F%u2018%uFF41%uFF42%uFF43%uFF44%uFF45%uFF46%uFF47%uFF48%uFF49%uFF4A%uFF4B%uFF4C%uFF4D%uFF4E%uFF4F%uFF50%uFF51%uFF52%uFF53%uFF54%uFF55%uFF56%uFF57%uFF58%uFF59%uFF5A%uFF5B%uFF5C%uFF5D%uFF5E";

			var result = "";
			for ( var i = 0 ; i < text.length ; i ++ ) {
				var val = text.charAt(i) ;
				if (val == " "){
					result += "　";
				} else {
					var j = asciiTable.indexOf(val) * 6 ;
					result += ( j > -1 ? unescape(big5Table.substring( j , j + 6 ) ) : val );
				}
			}
			return result;
		}
	};

	var actions = {
		//POP UP 開啟新視窗
		doPopup : function ( parms ) {
			var LINK_TO = parms.LINK_TO;
			if('AIL0_1300'==LINK_TO){
				//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
				parms.QUERY_START_DATE = parms.CURRENT_DATE;
				parms.QUERY_END_DATE = parms.CURRENT_DATE;

				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
					'parameters' :  {
						'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
					}
				});
			}else if('AIL1_1000'==LINK_TO){//180917:申請書(180828001571):新增可疑交易檢核
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL1_1000/query',
					'parameters' :  {
						'QUR_ID': parms.QUERY_ID,//客戶ID/繳款人ID
						'QUR_DATE_STR':parms.CURRENT_DATE,
						'QUR_DATE_END':parms.CURRENT_DATE,
						'COUNT':'0',
						'PAGE':'0',
						'TotalPage':'0'
					}
				});
			}
		},
		observeEvent : function(){
			$('btn_BILLIN').observe('click',buttons.doBillIn);
			$('btn_BILLIN_2').observe('click',buttons.doBillIn);

			$('btn_return').observe('click', function(){
				CSRUtil.linkBack();
			});

			//僅第一筆繳款人關係連動帶出繳款人ID及姓名
			var PAY_RELATION = $('PAY_RELATION1');
			if(PAY_RELATION != null){
				PAY_RELATION.observe('change', function(event){
					var selectItem = $('PAY_RELATION1').options[$('PAY_RELATION1').selectedIndex];
					$('PAY_ID').value = selectItem.getAttribute('RELATION_ID') || '';
					$('PAY_NAME').value = selectItem.getAttribute('RELATION_NAME') || '';
					<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
					$('PAY_NAME_RM').value = selectItem.getAttribute('RELATION_NAME_RM') || '';
					$('BIRTH_DATE').value = selectItem.getAttribute('BIRTH_DATE') || '';
					$('TEL_NO').value = selectItem.getAttribute('DAY_TEL_NUM') || '';
					$('OTHER_RELATION1').value = '';
					$('PAY_REASON1').value = '';


					//2019-01-28 申請書 181128001539(新增繳款服務單修正功能) - 繳款服務單新增檢核
					//select連動:關係為BG(借款人,保證人)->ID,NAME disable
					if(selectItem.value == 'B'||selectItem.value == 'G'){
						$('PAY_ID').disable();
						$('PAY_NAME').disable();
						<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
						$('PAY_NAME_RM').disable();
					}else{
						$('PAY_ID').enable();
						$('PAY_NAME').enable();
						<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
						$('PAY_NAME_RM').enable();
					}
				});
			}

			//繳款人種類連動負責人姓名、自然人姓名
			$('COPR_CODE').observe('change', function(event){
				if ($('COPR_CODE').value == "1") {
					$('CHIEF').enable();
					$('NATURAL_PERSON1').enable();
					$('NATURAL_PERSON2').enable();
					$('NATURAL_PERSON3').enable();
					$('CHIEF_ID').enable();
					$('NATURAL_PERSON1_ID').enable();
					$('NATURAL_PERSON2_ID').enable();
					$('NATURAL_PERSON3_ID').enable();
					//$('NATURAL_PERSON4').enable();
				} else {
					$('CHIEF').disable();
					$('NATURAL_PERSON1').disable();
					$('NATURAL_PERSON2').disable();
					$('NATURAL_PERSON3').disable();
					//$('NATURAL_PERSON4').disable();
					$('CHIEF').value = '';
					$('NATURAL_PERSON1').value = '';
					$('NATURAL_PERSON2').value = '';
					$('NATURAL_PERSON3').value = '';
					//$('NATURAL_PERSON4').value = '';
					$('CHIEF_ID').disable();
					$('NATURAL_PERSON1_ID').disable();
					$('NATURAL_PERSON2_ID').disable();
					$('NATURAL_PERSON3_ID').disable();
					//$('NATURAL_PERSON4').disable();
					$('CHIEF_ID').value = '';
					$('NATURAL_PERSON1_ID').value = '';
					$('NATURAL_PERSON2_ID').value = '';
					$('NATURAL_PERSON3_ID').value = '';
				}
			});

			//轉全形
			$('CHIEF').observe('blur', function(event){
				$('CHIEF').value = methods.unAsc($('CHIEF').value);
			});
			$('NATURAL_PERSON1').observe('blur', function(event){
				$('NATURAL_PERSON1').value = methods.unAsc($('NATURAL_PERSON1').value);
			});
			$('NATURAL_PERSON2').observe('blur', function(event){
				$('NATURAL_PERSON2').value = methods.unAsc($('NATURAL_PERSON2').value);
			});
			$('NATURAL_PERSON3').observe('blur', function(event){
				$('NATURAL_PERSON3').value = methods.unAsc($('NATURAL_PERSON3').value);
			});
			/* $('NATURAL_PERSON4').observe('blur', function(event){
				$('NATURAL_PERSON4').value = methods.unAsc($('NATURAL_PERSON4').value);
			}); */
			$('PAY_NAME').observe('blur', function(event){
				$('PAY_NAME').value = methods.unAsc($('PAY_NAME').value);
			});
			<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
			$('PAY_NAME_RM').observe('blur', function(event){
				$('PAY_NAME_RM').value = methods.unAsc($('PAY_NAME_RM').value);
			});
		},
		uiControl : function(){
			if(SPEC=="0" && (PAY_TYPE=="1" ||PAY_TYPE=="7" ||PAY_TYPE=="4") && (isXZeroPayOff =="N" )){
				$('billWithNoPaper').hide();
			}else{
				$('billWithPaper').hide();
			}

			if ($('COPR_CODE').value == "1") {
				$('CHIEF').enable();
				$('NATURAL_PERSON1').enable();
				$('NATURAL_PERSON2').enable();
				$('NATURAL_PERSON3').enable();
				$('CHIEF_ID').enable();
				$('NATURAL_PERSON1_ID').enable();
				$('NATURAL_PERSON2_ID').enable();
				$('NATURAL_PERSON3_ID').enable();
			} else {
				$('CHIEF').disable();
				$('NATURAL_PERSON1').disable();
				$('NATURAL_PERSON2').disable();
				$('NATURAL_PERSON3').disable();
				$('CHIEF').value = '';
				$('NATURAL_PERSON1').value = '';
				$('NATURAL_PERSON2').value = '';
				$('NATURAL_PERSON3').value = '';
				$('CHIEF_ID').disable();
				$('NATURAL_PERSON1_ID').disable();
				$('NATURAL_PERSON2_ID').disable();
				$('NATURAL_PERSON3_ID').disable();
				$('CHIEF_ID').value = '';
				$('NATURAL_PERSON1_ID').value = '';
				$('NATURAL_PERSON2_ID').value = '';
				$('NATURAL_PERSON3_ID').value = '';
			}
		},
		setGrid_A : function(){
			gridA = new TableUI({
				table: $('gridA'), pageSize: 20, allSortable: false, overDiv : false,
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM',
						render: function (record,value){
							if("4"==record.PAY_KIND){
								return "暫收款";
							}else if("3"==record.PAY_KIND){
								return "清償";
							}else if("2"==record.PAY_KIND){
								return "部入";
							}else if("1"==record.PAY_KIND){
								return "變更應繳日";
							}else{
								return value;
							}
						}
					},
					{header:"應繳金額", key:'DUTY_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ;
					}},
					{header:"實繳金額", key:'REAL_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ;
						},
						input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}
					}
				]
			});
		},
		setGrid_B : function(){
			gridB = new TableUI({
				table: $('gridB'),
				pageSize:0,
				column:[
					{header:'借款人', key:'BORROW_NAME', attrs:{Width:"50%", style:"text-align: left"}},
					{header:'繳款人關係', key:'PayRelationList', attrs:{style:"text-align: left"},
						render: function(record, value, sn){
							var div = new Element('div');
							var select = new Element('select', {'class':'validPAY_RELATION validPAY_RELATION2', 'id':'PAY_RELATION'+sn}).insert(new Element('option').update('請選擇'));
							var inputOTHER_RELATION = new Element('input',{'class':'textBox2 checkPAY_RELATION checkLength20', 'id':'OTHER_RELATION'+sn, 'type':'text', 'size':'30', 'maxlength':'60'});
							var inputPAY_REASON = new Element('input',{'class':'textBox2 checkPAY_RELATION', 'id':'PAY_REASON'+sn, 'type':'text', 'size':'30', 'maxlength':'60'});
							var hasC = false, hasP = false, hasS = false, hasW = false;

							for(var i = 0; i < value.size(); i++){
								var birthday = value[i].BIRTH_DATE;
								var tel = value[i].DAY_TEL_NUM;
								if(birthday){
									birthday = toROC(birthday);
								}else{
									birthday = '';
								}
								if(!tel){
									tel = '';
								}
								switch (value[i].PAY_RELATION) {
									case "C":
										hasC = true;
										break;
									case "P":
										hasP = true;
										break;
									case "S":
										hasS = true;
										break;
									case "W":
										hasW = true;
										break;
								}
								var option = new Element('option',{'value':value[i].PAY_RELATION, 'relation_id':value[i].RELATION_ID, 'relation_name':value[i].RELATION_NAME, 'relation_name_rm':(value[i].RELATION_NAME_RM||''), 'birth_date':birthday, 'day_tel_num':tel});
								option.update(value[i].PAY_RELATION_NAME + ':' + value[i].RELATION_ID + '(' + value[i].RELATION_NAME + ')');
								select.insert(option);
							}
							if(!hasC){
								var option = new Element('option',{'value':'C'}).update('配偶');
								select.insert(option);
							}
							if(!hasP){
								var option = new Element('option',{'value':'P'}).update('父母');
								select.insert(option);
							}
							if(!hasS){
								var option = new Element('option',{'value':'S'}).update('子女');
								select.insert(option);
							}
							if(!hasW){
								var option = new Element('option',{'value':'W'}).update('負責人');
								select.insert(option);
							}
							select.insert(new Element('option',{'value':'O'}).update('其他'));

							div.insert(select).insert('其他關係').insert(inputOTHER_RELATION).insert('代繳原因').insert(inputPAY_REASON);
							return div;
						}}
				]
			});
		},
		getPayRelations : function(){
			var relations = [];
			for(i = 0; i < gridB.getAllRecords().length; i++){
				var pay_relation = 'PAY_RELATION' + (i+1);
				var other_relation = 'OTHER_RELATION' + (i+1);
				var pay_reason = 'PAY_REASON' + (i+1);
				var relation = {
					BORROW_ID : gridB.getAllRecords()[i].BORROW_ID,
					BORROW_NAME : gridB.getAllRecords()[i].BORROW_NAME,
					PAY_RELATION : $F(pay_relation),
					OTHER_RELATION: $F(other_relation),
					PAY_REASON : $F(pay_reason)
				};
				relations.push(relation);
			}
			return relations;
		},
		initLoadDatas : function(){
			<c:choose>
				<c:when test='${not empty BillList}'>
					BillList = ${BillList};
					ISTIC = '${ISTIC}';
					PAY_TYPE = '${PAY_TYPE}';
					SPEC = '${SPEC}';
					isXZeroPayOff = '${isXZeroPayOff}';
					if(PAY_TYPE=="2"){
						GETINT_CODE = '${GETINT_CODE}';
					}
				</c:when>
				<c:otherwise>
					BillList = [];
				</c:otherwise>
			</c:choose>

			gridA.load(BillList);
			gridB.load(${PayRelationList} || []);
			borrowCount = gridB.getAllRecords().length || 0;  //2018-01-03調整取關係人清單筆數

			var LastPayList = <c:out value="${LastPayList}" default ="[]" escapeXml = "false"/>;

			var LastPayBorrowList = [];
			hasSetPayInfo = false;
			for(var i = 0; i < LastPayList.length; i++){
				if(LastPayList[i].hasOwnProperty("BORROW_ID") && !hasSetPayInfo){
					hasSetPayInfo = true;
					var LastPay = LastPayList[i];
					$('PAY_ID').value = LastPay.PAY_ID || '';
					$('PAY_NAME').value = LastPay.PAY_NAME || '';
					<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
					$('PAY_NAME_RM').value = LastPay.PAY_NAME_RM || '';
					var birthday = LastPay.BIRTH_DATE;
					if(birthday){
						birthday = toROC(birthday);
					}else{
						birthday = '';
					}
					$('BIRTH_DATE').value = birthday;
					$('TEL_NO').value = LastPay.TEL_NO || '';
					$('COPR_CODE').value = LastPay['COPR_CODE'] || '';
					if (LastPay['COPR_CODE'] == "1") {
						$('CHIEF').enable();
						$('NATURAL_PERSON1').enable();
						$('NATURAL_PERSON2').enable();
						$('NATURAL_PERSON3').enable();
						$('CHIEF_ID').enable();
						$('NATURAL_PERSON1_ID').enable();
						$('NATURAL_PERSON2_ID').enable();
						$('NATURAL_PERSON3_ID').enable();
					} else {
						$('CHIEF').disable();
						$('NATURAL_PERSON1').disable();
						$('NATURAL_PERSON2').disable();
						$('NATURAL_PERSON3').disable();
						$('CHIEF').value = '';
						$('NATURAL_PERSON1').value = '';
						$('NATURAL_PERSON2').value = '';
						$('NATURAL_PERSON3').value = '';
						$('CHIEF_ID').disable();
						$('NATURAL_PERSON1_ID').disable();
						$('NATURAL_PERSON2_ID').disable();
						$('NATURAL_PERSON3_ID').disable();
						$('CHIEF_ID').value = '';
						$('NATURAL_PERSON1_ID').value = '';
						$('NATURAL_PERSON2_ID').value = '';
						$('NATURAL_PERSON3_ID').value = '';
					}
				}
				//以借款人對應下拉選單
				var BORROW_ID = LastPayList[i].BORROW_ID;
				var PAY_RELATION = LastPayList[i].PAY_RELATION;
				if(BORROW_ID){
					var obj = {};
					obj[BORROW_ID] = PAY_RELATION;
					LastPayBorrowList.push(obj);
				}
			}
			var getRelation = function(list,key){
				for(var i = 0; i < list.length; i++){
					var obj = list[i];
					if(obj[key]){
						return obj[key];
					}
				}
				return false;
			}

			//loop每個下拉選單
			for(var i = 1; i <= borrowCount; i++){
				var PAY_RELATION = $('PAY_RELATION'+i);
				if(PAY_RELATION != null){
					var borrow_id = "";
					var pay_relation = "";
					for(var j = 1; j < PAY_RELATION.length; j++){ //j=0為"請選擇"
						//取得借款人ID
						if(PAY_RELATION[j].value == "B"){
							borrow_id = PAY_RELATION[j].getAttribute("relation_id");
							pay_relation = getRelation(LastPayBorrowList,borrow_id) //非每個帳號皆帶回繳款人資料
							//該借款人無繳款人資料
							if(!pay_relation){
								break;
							}
						}
						//選擇對應到的關係
						if(PAY_RELATION[j].value == pay_relation){
							PAY_RELATION[j].selected = true;
							break;
						}
					}
				}
			}
		},
		checkSelectedPAY_RELATIONS : function(){
			var onlyOnePayID = []
			//loop每個下拉選單
			for(var i = 1; i <= borrowCount; i++){
				var PAY_RELATION = $('PAY_RELATION'+i);
				if(PAY_RELATION != null){
					var borrow_id = PAY_RELATION[PAY_RELATION.selectedIndex].getAttribute("relation_id");
					if(borrow_id){ //null不理他
						if(onlyOnePayID.length == 0){ //沒有紀錄則放入
							var obj = {};
							obj['PayID'] = borrow_id;
							onlyOnePayID.push(obj);
						}else{ //有紀錄則檢查一不一樣
							if(onlyOnePayID[0]['PayID'] != borrow_id){
								return false;
							}
						}
					}
				}
			}
			if(onlyOnePayID.length != 0 && onlyOnePayID[0]['PayID'] != $F('PAY_ID')){
				return false;
			}
			return true;
		}
	};

	return{
		initApp:function(){
			<cathay:LocaleDisplay sysCode="DS" 	var="localeDisplay" dateFields="BIRTH_DATE"/>
			PageUI.createPageWithAllBodySubElement( "DSC31611" , "核心放款" , "繳款方式現金");

			actions.setGrid_A();
			actions.setGrid_B();

			actions.initLoadDatas();

			actions.observeEvent();

			initValidation();

			actions.uiControl();

			autoFormatToNumber();

			//2017-12-29是否需填寫繳款服務單，現金交易單筆超過5萬元才需寫繳款服務單
			if ("Y" == $F('noWrite')){
				$('table_C').hide();
			}

			PageUI.resize();
			displayMessage();
		}
	};
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<input  type = 'hidden'  id = 'noWrite' value="${noWrite}"/>
			<tr>
				<td class="tbYellow0"><B>現金匯款入帳試算結果</B>
				<input id="btn_return" type="button" class="button" value="回上一頁" /></td>
			</tr>
		</table>
		<table id="gridA" width="100%" class="grid" ></table>
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" colspan= "8"><B>繳款人資訊</B>
				</td>
			</tr>
			<tr><td colspan= "8"><div id="gridB" class="grid"></div></td></tr>
			<tr>
				<td class="tbYellow" rowspan="2" width="10%">繳款人ID</td>
				<td class="tbYellow2" rowspan="2" width="15%">
					<input id="PAY_ID" type="text" class="textBox2 checkPAY_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
					<select id="COPR_CODE" name="COPR_CODE" >
						<option value="0">個人</option>
						<option value="1">法人</option>
					</select>
				</td>
				<td class="tbYellow" width="10%">繳款人姓名/法人名稱</td>
				<td class="tbYellow2" width="15%">
					<%-- [20190802] (a) 修改：可輸入長度調整為VARCHAR 100 (若有檢核順便調整) --%>
					<input id="PAY_NAME" type="text" class="textBox2 checkLength100" size='30' maxlength="100" value=""/>
				</td>
				<td class="tbYellow" rowspan="2" width="10%">繳款人生日/法人註冊日期</td>
				<td class="tbYellow2" rowspan="2" width="15%">
					<input id="BIRTH_DATE" type="text" class="textBox2 checkBIRTH_DATE" size='30' maxlength="60" value=""/>
				</td>
				<td class="tbYellow" rowspan="2" width="10%">繳款人電話</td>
				<td class="tbYellow2" rowspan="2" width="15%">
					<input id="TEL_NO" type="text" class="textBox2 checkTEL_NO" size="30" maxlength="30" value=""/>(請填：0~9,-,#)
				</td>
			</tr>
			<%-- [20190802] (b) 新增：增加輸入欄位（[繳款/發票]人姓名/法人名稱(羅馬拼音)【PAY_NAME_RM】VARCHAR100），畫面檢核需為全形字且長度不可大於50個全型字(非必輸欄位) --%>
			<tr>
				<td class="tbYellow" width="10%">繳款人姓名/法人名稱(羅馬拼音)</td>
				<td class="tbYellow2" width="15%">
					<input id="PAY_NAME_RM" type="text" class="textBox2 checkLength100" size='30' maxlength="100" value=""/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">繳款人國籍</td>
				<td class="tbYellow2" width="15%">
					<select id="NATION_CODE" name="NATION_CODE" >
						<c:forEach var="map" items="${NATION_CODEList}">
								<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">繳款人居住國</td>
				<td class="tbYellow2" width="15%">
					<select id="OCR_NATION_CODE" name="OCR_NATION_CODE" >
						<c:forEach var="map" items="${NATION_CODEList}">
								<option value="${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if>>${map.CODE} ${map.NAME_CH}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">負責人ID</td>
				<td class="tbYellow2" width="15%">
					<input id="CHIEF_ID" type="text" class="textBox2 checkCHIEF_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">負責人姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="CHIEF" type="text" class="textBox2 checkCHIEF checkLength60_C" size='30' maxlength="60" value=""/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">具控制權之自然人1 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON1_ID" type="text" class="textBox2 checkNATURAL_PERSON1_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">具控制權之自然人1 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON1" type="text" class="textBox2 checkLength60_1" size='30' maxlength="60" value=""/>
				</td>
				<td class="tbYellow" width="10%">具控制權之自然人2 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON2_ID" type="text" class="textBox2 checkNATURAL_PERSON2_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">具控制權之自然人2 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON2" type="text" class="textBox2 checkLength60_2" size='30' maxlength="60" value=""/>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">具控制權之自然人3 ID</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON3_ID" type="text" class="textBox2 checkNATURAL_PERSON3_ID" size='15' maxlength="10" onblur="this.value = this.value.toUpperCase()" value=""/>
				</td>
				<td class="tbYellow" width="10%">具控制權之自然人3 姓名</td>
				<td class="tbYellow2" width="15%">
					<input id="NATURAL_PERSON3" type="text" class="textBox2 checkLength60_3" size='30' maxlength="60" value=""/>
				</td>
				<td class="tbYellow2" colspan="4"></td>
			</tr>
		</table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0">
					<div id="billWithPaper">
					<B>請在印表機放入您的空白單據，其單據序號為</B>
							<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10" value="${RECEIPT_SERNO}"/>
							<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>
							<br><B>註：若此交易為"繳多期款項"，請您務必放入"連續之有效空白單據"，因系統會自動給定上述空白單據之下一連續單據序號(序號不可中斷)</B>
					</div>
					<div id="billWithNoPaper">
					<input type="button" class="button" id="btn_BILLIN_2" value="入帳確認"/>
					</div>
				</td>
				<!--
				<td class="tbYellow0"><B>請在印表機放入您的空白單據，其單據序號為</B>
					<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10" value="${RECEIPT_SERNO}" />
					<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>
					<br><B>註：若此交易為"繳多期款項"，請您務必放入"連續之有效空白單據"，因系統會自動給定上述空白單據之下一連續單據序號(序號不可中斷)</B>
				</td>
				 -->
			</tr>
		</table>
	</form>
</body>
</html>