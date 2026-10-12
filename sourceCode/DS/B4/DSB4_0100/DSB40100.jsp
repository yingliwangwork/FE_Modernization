<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<fmt:setBundle basename="TextResource" />
<!--
程式：DSB40100.jsp
作者：簡睿甫
功能：匯款資料輸入
完成：
版本：2018-01-24申請書-洗錢防制新增受款人ID及檢核作業:新增匯款戶ID，代償一匯不需填且反白，其他匯款種類需檢核是否輸入

[20240613]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<%-- [20240613] 難字調整 --%>
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

Event.observe(window, 'load', new DSB40100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

// 連結到電子謄本系統
function doLinkTo0700(){       
		var url = "<%=dispatcher%>/DSA1_0700/prompt?";
		var win = window.open(url, "DSB4_0100", "location=0, scrollbars=1, status=1, titlebar=1, resizable=1");
		win.moveTo(win.screen.availLeft , win.screen.availTop );
		win.resizeTo(win.screen.availWidth , win.screen.availHeight);
}
    
function DSB40100(){
	var grid;
	var isFori='${isFori}';
	var APPLY_ID = '<c:out value="${APPLY_ID}" default="" escapeXml="false" />';
	var A010Map = <c:out value="${A010Map}" default="{}" escapeXml="false" />;
	var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false" />;
	
	var B200_COMP_DIV = '<c:out value="${B200_COMP_DIV}" default="" escapeXml="false" />';
	var B200_COMP_DIV_NM = '<c:out value="${B200_COMP_DIV_NM}" default="" escapeXml="false" />';
	
	// 與查詢的條件比對是否修改(for修改Only)
	//var updateMap = {};
	//updateMap.B200_REMIT_TYPE = "";
	//updateMap.B200_REMIT_DATE = ""; 
	//updateMap.B200_REMIT_AMT = "";
    //按鈕權限

	function buttonAuth(){
		var authButtons = {
			B0003:"BTN_0002"<%--新增--%>, 
			B0028:"BTN_0054"<%--確認--%>, 
			B0005:"BTN_0003"<%--刪除--%>,
			B0004:"BTN_0004"<%--修改--%>
		};
		<dz:grantButtons FUNC_ID="DSB40100" ignored="false"/>
	}
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSB4_0100/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
	
	// 按鈕控制
	var button = {
		// 查詢
		doQuery: function() {
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.queryChecked();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'query' ,  {Form: Object.toJSON($('form').serialize(true))}, action.returnDataHandler,
				function(resp){	//查詢失敗處理
					grid.load([]); 
					action.doClearBlockC();
					action.doClearBlockD();
				}				
			);	
		},
		
		// 新增
		doInsert: function() {
			// 清空檢核
			validates.clear();

			// 檢核設定
			validates.insertChecked();
			
			//trim掉單引號
			$('B200_ACCOUNT_NAME').value=$('B200_ACCOUNT_NAME').value.replace(/'/gi,"").replace(/"/gi, "");
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			if (!confirm("請注意，謄本日期是否為三日內")){
				return  ;
			}
			
			if (!confirm("請確認本案關係人無監護╱輔助宣告事由")){
				return  ;
			}
			
			ajaxPostIM( 'insert' ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler("")}, action.returnDataHandler4Insert);		
		},
		
		// 確認
		doConfirm: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0) {
				alert("請先選取資料後再作確認!");
				return;
			}	
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.confirmChecked();
			
			//trim掉單引號
			$('B200_ACCOUNT_NAME').value=$('B200_ACCOUNT_NAME').value.replace(/'/gi,"").replace(/"/gi, "");
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'confirm' ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler(records[0])}, 
					function(resp){
						action.returnDataHandler(resp, 'confirm');
					}
			);		
		},
		
		// 刪除
		doDelete: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0) {
				alert("請先選取資料後再作刪除!");
				return;
			}	
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.deleteChecked();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			if (!confirm("確認是否要刪除該筆資料")){
				return  ;
			}
			
			ajaxPostIM( 'delete' ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler(records[0])}, action.returnDataHandler);
		},
		
		//回上一頁
		doBack : function(event){
			CSRUtil.linkBack();	
		},
		// 修改
		doUpdate: function() {
			var records = grid.getCheckedRecord();
			if(records.length == 0) {
				alert("請先選取資料後再作修改!");
				return;
			}	
		
			// 清空檢核
			validates.clear();
			
			// 檢核設定
			validates.updateChecked();
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'update' ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler(records[0])}, 
					function(resp){
						action.returnDataHandler(resp, 'update');
					}
			);
		}
		
	};
	
	// 行為
	var action = {
		// 填入C 區塊資料
		doFillupBlockC: function(A010Map) {
			
			if(A010Map) {
				<%-- [20240613] td塞值時，排除td_BORROW_NAME --%>
				$$('#block_C .tbYellow2:not(#td_BORROW_NAME)').each(function(td) {
					td.update(A010Map[td.id]);
				});

				<%-- [20240613] 增加input#BORROW_NAME set value --%>
				$('BORROW_NAME').setValue(A010Map['BORROW_NAME']);

			}/* else {
				$$('#block_C td[className=tbYellow2]').each(function(td) {
					td.update("");
				});
			}*/
		},
		
		// 填入D 區塊資料
		doFillupBlockD: function(record, A010Map) {
			// 清空檢核
			validates.clear();
			if(record) {
				$$('#block_D td[name=inner]').each(function(td) {
					var id = td.id;
					if(id){
						td.update(record[id.replace("B200_", "")]);
					}
				});
				
				$$('#block_D input[type=text]').each(function(ele) {
					var id = ele.id;
					if(id) {
						var value = record[id.replace("B200_", "")];
						if(id == "B200_REMIT_AMT"){
							ele.setValue(action.formatValue("", record[id.replace("B200_", "")]));
						} else if (value && id == 'B200_REMIT_DATE') {
							ele.setValue(toROC(value));
						} else {
							ele.setValue(value || "");
							if(id == 'B200_ACCOUNT_NAME'){
								$('B200_ACCOUNT_NAME').simulate('change');//觸發連動
							}
						}
					}
				});
				
				var MULTI_REMIT_CHECK1 = record['MULTI_REMIT_CHECK1'];
			    var MULTI_REMIT_CHECK2 = record['MULTI_REMIT_CHECK2'];
		     	var MULTI_REMIT_CHECK3 = record['MULTI_REMIT_CHECK3'];
			    var MULTI_REMIT_CHECK4 = record['MULTI_REMIT_CHECK4'];
				if (MULTI_REMIT_CHECK1 == '1'){
	                $('MULTI_REMIT_CHECK1').checked = true;
            	} else {
	             	$('MULTI_REMIT_CHECK1').checked = false;
	            }	
	            if (MULTI_REMIT_CHECK2 == '1'){
	                $('MULTI_REMIT_CHECK2').checked = true;
            	} else {
	             	$('MULTI_REMIT_CHECK2').checked = false;
	            }	
	            if (MULTI_REMIT_CHECK3 == '1'){
	                $('MULTI_REMIT_CHECK3').checked = true;
            	} else {
	             	$('MULTI_REMIT_CHECK3').checked = false;
	            }	
	            if (MULTI_REMIT_CHECK4 == '1'){
	                $('MULTI_REMIT_CHECK4').checked = true;
            	} else {
	             	$('MULTI_REMIT_CHECK4').checked = false;
	            }	           
	            
				var REMIT_TYPE = record['REMIT_TYPE'];
				if(REMIT_TYPE) {
					var onList = false;
					$$('#B200_REMIT_TYPE option').each(function(option){
						if(option.value == REMIT_TYPE){
							onList = true;
						}
					})
					
					if(!onList){
						$('B200_REMIT_TYPE').value = "00";
						$('B200_REMIT_TYPE_Hidden').value = REMIT_TYPE;
					} else {
						$('B200_REMIT_TYPE').value = REMIT_TYPE;
						$('B200_REMIT_TYPE_Hidden').value = "";
					}
					
					// 畫面欄位連動(匯款種類、代償單位、代償單位中文、代償戶姓名)
					//20190704因理財型查詢出未匯款完畢資料時，點選取仍帶出預設的主檔帳號，非當次的匯款帳號，故調整
					//若為查詢已輸入匯款的選取要改呈現B200的內容
					action.REMIT_TYPEgearing(REMIT_TYPE, record, A010Map, 'Q');
				}
				
				<%--幣別填空及連動--%>
				var CURR = record['CURR'];
				$('B200_CURR').setValue(CURR);
				action.changeCURR(record['EX_RATE']);
				
				
				<%--受款地區國籍--%>
				$('B200_COUNTRY').setValue(record['COUNTRY']);
				
				<%--受款人國籍--%>
				$('B200_ACPT_NAME_COUNTRY').setValue(record['ACPT_NAME_COUNTRY']);
				
				<%--受款人是否為契約利害關係人--%>
				$('B200_IS_CONTRACT').setValue(record['IS_CONTRACT']);
				
				//updateMap.B200_REMIT_TYPE = $F('B200_REMIT_TYPE'); 
				//updateMap.B200_REMIT_DATE = $F('B200_REMIT_DATE'); 
			    //updateMap.B200_REMIT_AMT = $F('B200_REMIT_AMT');
			}
		},
		
		// 畫面欄位連動(匯款種類、代償單位、代償單位中文、代償戶姓名)
		REMIT_TYPEgearing: function(REMIT_TYPE, record, A010Map, TYPE) {
			if(REMIT_TYPE == '21') {   // 匯款種類=21.代償一匯(主辦)
				$('B200_ACCOUNT_ID').value = '';
				action.gearing(B200_COMP_DIV, B200_COMP_DIV_NM, record['COMP_NAME'] || "", true);
				//action.gearing_delete();
			} else if( REMIT_TYPE == '40') { // 匯款種類=40.借新還舊
				action.gearing("", "", record['COMP_NAME'], false);
				// 貸款類別不為借新還舊，跳出警示訊息
				var LOAN_TYPE = A010Map['LOAN_TYPE'] || "";
				if( LOAN_TYPE != '3' && LOAN_TYPE != '4' && LOAN_TYPE != '5') {  
					alert("貸款類別必須是借新還舊，才能輸入借新還舊匯款!");
				}
				//action.gearing_delete();
			} else if( REMIT_TYPE == '50') { // 匯款種類=50.理財型動撥
			   if(TYPE == 'Q'){
				 $('B200_BANK').value =record['BANK']|| '';
				 $('B200_BRANCH').value =record['BRANCH']|| '';
				 $('B200_ACCOUNT').value =record['ACCOUNT']|| '';
				 $('B200_ACCOUNT_ID').value =record['ACCOUNT_ID'] || ''; //ID也要預帶
				 $('B200_ACCOUNT_NAME').value =record['ACCOUNT_NAME']|| '';
			   }else { 
				  //2019-04-15申請書-匯款資料輸入作業優化
				  //理財型「匯款帳號」帶出規則排序為：
				  //(1) 放款理財型資料檔DTDSC104、欄位：REMIT_ACCOUNT動撥連結帳戶。
				  //(2) 放款案件受理檔DTDSA010、欄位：REMIT_ACCOUNT動撥連結帳戶
				  //故原抓B200的部分拿掉，A0101Map內已經有判斷有C104的抓C104，沒有才抓A010
				  $('B200_BANK').value =A010Map.REMIT_ACCOUNT.length>=3 ?A010Map.REMIT_ACCOUNT.substring(0,3) : "";
				  $('B200_BRANCH').value =A010Map.REMIT_ACCOUNT.length>=7 ?A010Map.REMIT_ACCOUNT.substring(3,7) : "";
				  $('B200_ACCOUNT').value =A010Map.REMIT_ACCOUNT.length>=8 ?A010Map.REMIT_ACCOUNT.substring(7) : "";
				  $('B200_ACCOUNT_ID').value =A010Map.BORROW_ID|| '';
				  $('B200_ACCOUNT_NAME').value =A010Map.BORROW_NAME|| '';
				  $('B200_ACCOUNT_NAME_RM').value =A010Map.BORROW_NAME_RM|| '';
				}
				action.gearing("", "", "", false);
				var MM_CODE = A010Map['MM_CODE'];
				if( !A010Map.MM_CODE){
					alert("本件非理財型，無法作理財型動撥!");
				}
			
			} else {
				action.gearing("", "", record['COMP_NAME'], false);
				//action.gearing_delete();
				
			}
		},
		
		// 畫面欄位連動(匯款種類、代償單位、代償單位中文、代償戶姓名)
		gearing: function(COMP_DIV, COMP_DIV_NM, COMP_NAME, isChangeFieldTypetoText) {
			$('B200_COMP_DIV').update((COMP_DIV || "") +' '+ (COMP_DIV_NM || ""));
			if(isChangeFieldTypetoText) {
				$('B200_COMP_NAME').update(new Element('input',
					{ type:'text',
					  id: 'COMP_NAME',
					  size: '60',
					  maxlength: '25',
					  value: COMP_NAME || "附言：國泰人壽代償，代償失敗請退回原匯款帳戶"
					} 
				));
			} else {
				var maxlength = ('Y'==isFori && 'NTD'!=$F('B200_CURR'))?'80':'25';
				$('B200_COMP_NAME').update(new Element('input',
					{ type:'text',
					  id: 'COMP_NAME',
					  size: '60',
					  maxlength: maxlength,
					  value: COMP_NAME||""
					}
				));
			}
		},
		// 畫面欄位連動(匯款戶名)
		gearing_delete: function() {
			$('B200_BANK').setValue("");
			$('B200_BRANCH').setValue("");
			$('B200_ACCOUNT').setValue("");
			$('B200_ACCOUNT_ID').setValue("");		
			$('B200_ACCOUNT_NAME').setValue("");
			$('B200_ACCOUNT_ID').disable();	
		},
		
		// 傳送前資料整理
		dataHandler: function(record){
			var SER_NO = "";
			var REMIT_PROCESS = "";
			var INPUT_ID = "";
			var INPUT_DATE = "";
			var CRED_INPUT_ID = "";
			var CRED_INPUT_DATE = "";
			var COMP_DIV;
			if( record) {
				SER_NO = record['SER_NO']; 
				REMIT_PROCESS = record['REMIT_PROCESS']; 
				INPUT_ID = record['INPUT_ID']; 
				INPUT_DATE = record['INPUT_DATE']; 
				CRED_INPUT_ID = record['CRED_INPUT_ID']; 
				CRED_INPUT_DATE = record['CRED_INPUT_DATE']; 
				COMP_DIV = record['COMP_DIV'];
			} else if($F('B200_REMIT_TYPE') == '21'){
				COMP_DIV = B200_COMP_DIV;
			} else {
				COMP_DIV = "";
			}
		
			var REMIT_TYPE = "00";
			if( $F('B200_REMIT_TYPE')=="00" && $F('B200_REMIT_TYPE_Hidden')) {
				REMIT_TYPE = $F('B200_REMIT_TYPE_Hidden');
			} else if($F('B200_REMIT_TYPE')!="00"){
				REMIT_TYPE = $F('B200_REMIT_TYPE');
			}
		
			var B200_COMP_NAME;
			if($('COMP_NAME')) {
				B200_COMP_NAME = $F('COMP_NAME');
			} else {
				B200_COMP_NAME = $('B200_COMP_NAME').innerHTML;
			}
			
			var B200_MULTI_REMIT_CHECK1;
			var B200_MULTI_REMIT_CHECK2;
			var B200_MULTI_REMIT_CHECK3;
			var B200_MULTI_REMIT_CHECK4;
		    if ($('MULTI_REMIT_CHECK1').checked) {
		         B200_MULTI_REMIT_CHECK1 = "1";
		    } else {
		         B200_MULTI_REMIT_CHECK1 = "0";
		    }
		    if ($('MULTI_REMIT_CHECK2').checked) {
		         B200_MULTI_REMIT_CHECK2 = "1";
		    } else {
		         B200_MULTI_REMIT_CHECK2 = "0";
		    }
		    if ($('MULTI_REMIT_CHECK3').checked) {
		         B200_MULTI_REMIT_CHECK3 = "1";
		    } else {
		         B200_MULTI_REMIT_CHECK3 = "0";
		    }
		    if ($('MULTI_REMIT_CHECK4').checked) {
		         B200_MULTI_REMIT_CHECK4 = "1";
		    } else {
		         B200_MULTI_REMIT_CHECK4 = "0";
		    }

			var mapA = {
			
				// A010Map
				APPLY_ID: A010Map['APPLY_ID'],	// 受理編號
				APPLY_PROCESS: A010Map['APPLY_PROCESS'],	// 受理進度
				CRED_DEPT: A010Map['CRED_DEPT'],	// 承辦科別
				LOAN_ID_M: A010Map['LOAN_ID_M'],	// 理財型帳號
				MM_CODE: A010Map['MM_CODE'],	// 理財型判別碼
				LOAN_KIND: A010Map['LOAN_KIND'],	// 貸款類別
				LOAN_PERIOD: A010Map['LOAN_PERIOD'],	// 貸款期數
				BORROW_ID: A010Map['BORROW_ID'],	// 借款人ID
				BORROW_NAME: A010Map['BORROW_NAME'],	// 借款人姓名
				FILE_FIREINSU: A010Map['FILE_FIREINSU'],	// 火險狀況
				LOAN_KIND: A010Map['LOAN_KIND'],	// 貸款類別
				FIX_PERIOD: A010Map['FIX_PERIOD'],	// 定期期數
				SPR_PERIOD: A010Map['SPR_PERIOD'],	// 分期期數
				
	
				// 畫面
				B200_REMIT_TYPE: REMIT_TYPE, // 匯款種類
				B200_REMIT_DATE: toY2K($F('B200_REMIT_DATE')),	// 匯款日期
				B200_REMIT_AMT: $F('B200_REMIT_AMT'),	// 匯款金額
				B200_BANK: $F('B200_BANK'),	// 匯款帳號(1)
				B200_BRANCH: $F('B200_BRANCH'),	// 匯款帳號(2)
				B200_ACCOUNT: $F('B200_ACCOUNT'),	// 匯款帳號(3)
				B200_ACCOUNT_ID: $F('B200_ACCOUNT_ID'),	// 匯款戶ID
				B200_ACCOUNT_NAME: $F('B200_ACCOUNT_NAME'),	// 匯款戶名
				B200_MULTI_REMIT_CHECK1: B200_MULTI_REMIT_CHECK1,	// 分次動撥檢核項目1_繳息情形
				B200_MULTI_REMIT_CHECK2: B200_MULTI_REMIT_CHECK2,	// 分次動撥檢核項目2_司法院監護、輔助宣告
				B200_MULTI_REMIT_CHECK3: B200_MULTI_REMIT_CHECK3,	// 分次動撥檢核項目3_聯徵正常
				B200_MULTI_REMIT_CHECK4: B200_MULTI_REMIT_CHECK4,	// 分次動撥檢核項目4_電子謄本查詢
				B200_COMP_DIV: COMP_DIV,/*function() { 
					var COMP_DIVtext = $('B200_COMP_DIV').innerHTML;
					if(COMP_DIVtext.length > 5) {
						return COMP_DIVtext.substring(0, 5);
					} else {
						return COMP_DIVtext;
					}
				}(),*/	// 代償單位
				B200_COMP_NAME: B200_COMP_NAME, // 代償戶姓名(備註)
				//B200_UPDATE_REASON: $F('B200_UPDATE_REASON'), // 修改原因
				
				// record[]
				B200_SER_NO : SER_NO, // 序號
				B200_REMIT_PROCESS: REMIT_PROCESS, // 處理進度
				B200_INPUT_ID: INPUT_ID, // 輸入人員
				B200_INPUT_DATE: INPUT_DATE, // 輸入日期
				B200_CRED_INPUT_ID: CRED_INPUT_ID, // 徵信輸入人員
				B200_CRED_INPUT_DATE: CRED_INPUT_DATE, // 徵信輸入日期
				
				B200_COUNTRY: $F('B200_COUNTRY'),	
				B200_ACPT_NAME_COUNTRY: $F('B200_ACPT_NAME_COUNTRY'),	
				B200_CURR: $F('B200_CURR'),	
				B200_IS_CONTRACT: $F('B200_IS_CONTRACT'),	
				B200_EX_RATE: $F('B200_EX_RATE'),	
				B200_ACCOUNT_NAME_RM: $F('B200_ACCOUNT_NAME_RM')	
			}
			return Object.toJSON(mapA);
		},
		
		// 清空 C 區
		doClearBlockC: function(){
			<%-- [20240613] td塞值時，排除td_BORROW_NAME --%>
			$$('#block_C .tbYellow2:not(#td_BORROW_NAME)').each(function(td) {
				td.update("");
			});

			<%-- [20240613] 增加input#BORROW_NAME set value --%>
			$('BORROW_NAME').setValue('');
		},
		
		// 清空 D 區
		doClearBlockD: function(){
			$$('#block_D td[name=inner]').each(function(td) {
				var id = td.id;
				if(id){
					td.update();
				}
			});
				
			$$('#block_D input').each(function(ele) {
				var id = ele.id;
				if(id) {
					ele.setValue("");
					if("B200_ACCOUNT_ID"==id){
						ele.disable();
					}
				}
			});
			
			$('B200_REMIT_TYPE').value = "00";
			$('MULTI_REMIT_CHECK1').checked = false;
			$('MULTI_REMIT_CHECK2').checked = false;
			$('MULTI_REMIT_CHECK3').checked = false;
			$('MULTI_REMIT_CHECK4').checked = false;
			
			<%--2019-04-30 申請書-190409001075--%>
			var APPLY_ID_5 = APPLY_ID ? APPLY_ID.substring(0,5) : '';
			$("B200_IS_CONTRACT").setValue(''); <%--受款人是否為受益人或契約利害關係人-清空--%>
			$("B200_ACPT_NAME_COUNTRY").setValue('72006'==APPLY_ID_5?'':'TW'); <%--受款地區國籍-受編開頭為72006(法金件)，不預設/台灣或中華民國--%>
			$("B200_COUNTRY").setValue('72006'==APPLY_ID_5?'':'TW'); <%--受款地區國籍-受編開頭為72006(法金件)，不預設/台灣或中華民國--%>
			<%--幣別-台幣--%>
			action.CURR_CONTROL();
		},
		
		// AJAX完成後，頁面處理
		returnDataHandler: function(resp, actionName){
			var confirmMsg = resp.confirmMsg;
			var records = grid.getCheckedRecord();
			if(actionName && confirmMsg){
				if(confirm(confirmMsg)){
					ajaxPostIM( actionName ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler(records[0]), hasConfirm:"Y"}, action.returnDataHandler);
				}
			}else{
				isFori = resp.isFori||'N';
				
				rtnList = resp.rtnList;
				A010Map = resp.A010Map;
				APPLY_ID = (A010Map['APPLY_ID']) ? A010Map['APPLY_ID'] : '';
				grid.load(rtnList || []); 
				
				action.doFillupBlockC(A010Map);
				action.doClearBlockD();
			}
		},
		
		// AJAX完成後，頁面處理(新增)
		returnDataHandler4Insert: function(resp){
			var checkMoneyLaunderMsg = resp.checkMoneyLaunderMsg;
			var confirmMsg = resp.confirmMsg;
			var CHK_ID = resp.CHK_ID; //洗錢防制檢核紀錄畫面傳入ID
			if(confirmMsg){
				if(confirm(confirmMsg)){
					ajaxPostIM( 'insert' ,  {Form: Object.toJSON($('form').serialize(true)), mapA: action.dataHandler(""), hasConfirm:"Y"}, action.returnDataHandler4Insert);
				}
			}else if (checkMoneyLaunderMsg) {
				alert(checkMoneyLaunderMsg);
				if (CHK_ID) {
                    //190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
					var parms = { 
						'QUERY_ID' : CHK_ID,
						'QUERY_START_DATE' : resp.CURRENT_DATE,
						'QUERY_END_DATE' : resp.CURRENT_DATE
					}; 		
					action.doPopupWin(parms);	
				}	
			} else {
				rtnList = resp.rtnList;
				A010Map = resp.A010Map;
				grid.load(rtnList || []); 
				
				action.doFillupBlockC(A010Map);
				action.doClearBlockD();
			}
		},

		// 數字欄位格式
		pattern : '#,###.###', 
		
		// 數字欄位處理(三位一撇)
		formatValue : function(record, value) {
			if(Object.isNumber(value)) {
				return value ? CSRUtil.$fmt(value, action.pattern) : '';
			} else {
				return value ?  value : '';
			}
		},
		
		//開啟新視窗(洗錢防制檢核紀錄)
	  	doPopupWin:function(parms){			
			popupWin.popup({
				'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
				'parameters' :  {
					'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
				}
			});
	  	},
	  	//是否為契約利害關係人連動
	  	IS_CONTRACT_CHANGE : function() {
			var APPLY_ID_5 = '';
			var BORROW_ID = '';
			
			if (A010Map) {
				APPLY_ID_5 = (A010Map['APPLY_ID'])?A010Map['APPLY_ID'].substring(0,5):'';
				BORROW_ID = A010Map['BORROW_ID'];
			}
			
			if (BORROW_ID == $F("B200_ACCOUNT_ID")) {//受款人=借款人
				$('B200_IS_CONTRACT').setValue('Y');
			}else  if ($F('B200_REMIT_TYPE')=="21" || $F('B200_REMIT_TYPE')=='30') {//代償
				$('B200_IS_CONTRACT').setValue('Y');
			}else if (APPLY_ID_5 == '72006') {//法金件
				$('B200_IS_CONTRACT').setValue('');
			}else {//其它:賣方或履保專戶
				$('B200_IS_CONTRACT').setValue('N');
			}
		},
		//依案件判斷是否為外幣件
		CURR_CONTROL : function(){
			if('N'==isFori){//非外幣件預設台幣
				$('B200_CURR').setValue('NTD');
				$('B200_CURR').disable();
			}else{
				$('B200_CURR').setValue("NTD");
				$('B200_CURR').enable();
			}
			action.changeCURR();
		},
		changeCURR : function(EX_RATE) {
			//連動調整備註欄位長度
			var maxlength = ('Y'==isFori && 'NTD'!=$F('B200_CURR'))?'80':'25';
			$('COMP_NAME').setAttribute('maxlength',maxlength);
			
			if($F('B200_CURR') == 'NTD'){
				$('B200_EX_RATE').setValue('1');
				$('B200_EX_RATE').disable();
				$('B200_COUNTRY').setValue('TW');//190624:與出納確認,若為台幣件受款地區均為台灣
				$('B200_COUNTRY').disable();
			}else{
				$('B200_EX_RATE').setValue(EX_RATE?EX_RATE:'');
				$('B200_EX_RATE').enable();
				$('B200_COUNTRY').enable();
			}
		},
		//匯款戶名連動
		changeAccountName : function(){
			var accountName = $F('B200_ACCOUNT_NAME');
			var REMIT_TYPE = $F('B200_REMIT_TYPE');
			//20200702 問題單:當匯款資料輸入(DSB40100)匯款種類選擇「代償一匯(21)」或「借新還舊(40)」者，匯款戶ID欄位不預帶，開放讓人員自行輸入。
			//詩婷：匯款單位回覆說 匯款戶名跟ID都是代償行庫指定的  所以實務上沒辦法讓ID跟戶名一致
			if('21' == REMIT_TYPE || '40' == REMIT_TYPE){
				$('B200_ACCOUNT_ID').setValue("");
				$('B200_ACCOUNT_ID').enable();
			}else if(accountName == '國泰人壽保險股份有限公司'){
				$('B200_ACCOUNT_ID').setValue('03374707');	
				$('B200_ACCOUNT_ID').disable();
			}else if(accountName == A010Map['BORROW_NAME']){
				$('B200_ACCOUNT_ID').setValue(A010Map['BORROW_ID']||'');	
				$('B200_ACCOUNT_NAME_RM').setValue(A010Map['BORROW_NAME_RM']||'');	
				$('B200_ACCOUNT_ID').disable();
			}else{
				$('B200_ACCOUNT_ID').setValue("");
				$('B200_ACCOUNT_ID').enable();
			}
	
			//20200706 問題單：連動產生匯款人ID後要在觸發一次ID的連動
			action.IS_CONTRACT_CHANGE(); //觸發連動
		}
	}
	
	//檢核匯款戶ID格式
	var chkUsableID = function (ID) {		
		var chk = false;
		if(ID == ''){
			chk = true;
		} else if(ID != '') {	
			//外幣件不檢核ID格式: 
			if('Y'==isFori && 'NTD'!=$F('B200_CURR')){	        
			    chk = true;
			}else{
				if(validation.checkUniSN(ID) || validation.checkROCID(ID) || validation.checkROCARC(ID)) { 
					chk = true;
				}
			}
		}
		return chk; 	
	};
	
	// 檢核
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 輸入欄位長度及資料型態檢核
				['length-check', '欄位長度有誤',
					function( v,ele,info ) {
					    if ($F('QUERY_KIND_1') == 1) {
							if( v && v.length != 11) {
								return false
							}
						} else if ($F('QUERY_KIND_2') == 2) {
							if( v && v.length != 10) {
								return false
							}						
						}
						return true;
					}
				],
				// 匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號 必須有值，且匯款戶名要為全形字，若無，則跳出警示訊息
				['multiple_required', '匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號  必須有值，且匯款戶名要為全形字',
					function( v,ele,info ) {
						var isEmpty = true;
						$w('B200_REMIT_TYPE B200_REMIT_DATE B200_REMIT_AMT B200_ACCOUNT_NAME B200_BANK B200_BRANCH B200_ACCOUNT').each(function(id){
						var ele = $(id);
						/*$$('#block_D input[type=text]').each(function(ele) {
							var someOne =ele.id;
							if(someOne != 'COMP_NAME' && someOne != 'B200_ACCOUNT_ID' 
							   && someOne != 'B200_EX_RATE' && someOne != 'B200_ACCOUNT_NAME_RM' && !ele.value) {*/
							if(!ele.value){
								//外幣件不檢核:B200_BANK B200_BRANCH 
								if(!('Y'==isFori && 'NTD'!=$F('B200_CURR') && ('B200_BANK'==id || 'B200_BRANCH'==id))){
									ele.style.backgroundColor = "#FF8888";
									isEmpty = false;
								}
							}
						});
						if($F('B200_REMIT_TYPE') == '00') {
							$('B200_REMIT_TYPE').style.backgroundColor = "#FF8888";
							isEmpty = false;
						}
						return isEmpty;
					}
				],
				
				// 若匯款種類選擇代償一匯(=21),則檢核必須輸入代償戶姓名，且要為全形字，若無，則跳出警示訊息:"代償一匯須輸入代償戶姓名(全形)!"
				// 若匯款種類非代償一匯(!=21),則檢核匯款戶名與借款人姓名是否相符，若無，則跳出警示訊息:"本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料!"
				['remitTypeis21', '本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料!',
					function( v,ele,info ) {
						return false;
					}
				],

				// 新增及確認時未檢核匯款金額必須大於0
				['must-positive', '匯款金額必須大於0',
					function( v,ele,info ) {
						var value = ele.getValue();
						if(value && value > 0) {
							return true;
						}
						return false;
					}
				],
				
				[ 'chkAccountID', '匯款戶ID格式錯誤', function( v ) { return chkUsableID($F('B200_ACCOUNT_ID'));}],
				
				//擔保品種類為國外動產/不動產，幣別不可為台幣
				[ 'chkCURR', '擔保品種類為「國外動產/不動產」，幣別不可為台幣', function( v ) { return isFori && 'NTD'!=v ;}]
				// 檢核匯款種類 匯款日期 匯款金額 不能修改
				//['updateDenied', '匯款種類 匯款日期 匯款金額 不能修改',
				//	function( v,ele,info ) {
				//		var isUpdate = false;
				//		$w('B200_REMIT_TYPE B200_REMIT_DATE B200_REMIT_AMT').each(function(id) {
				//			if($F(id) != updateMap[id]) {
				//				isUpdate = true;
				//				$(id).style.backgroundColor = "#FF8888";
				//			}
				//		});
						
				//		if(isUpdate) {
				//			return false;
				//		}
				//		return true;
				//	}
				//]
			] );
		},
		
		// 查詢檢核
		queryChecked: function(){
			validates.valid.define('required', {id:'QUERY_COND', errMsg: "請輸入受理編號或貸款帳號查詢!!" });
		},
		
		// 新增檢核
		insertChecked: function(){
			validates.valid.define('chkCURR', {id:'B200_CURR', errMsg: "擔保品種類為「國外動產/不動產」，幣別不可為台幣" });
			
			var isForiCurr = ("Y"==isFori && $F('B200_CURR') != 'NTD');
			validates.valid.define('required', {id:'QUERY_COND', errMsg: "無受理編號，無法新增!" });
			validates.valid.define('multiple_required', {id:'B200_REMIT_TYPE',errMsg:(isForiCurr?"匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號  必須有值":null)});
			validates.valid.define('must-positive', {id:'B200_REMIT_AMT'});	
			validates.valid.define('validate-number', {id:'B200_ACCOUNT', errMsg: "帳號需為數字格式!" });	
			validates.valid.define('required', {id:'B200_COUNTRY', errMsg: "無受款地區國籍，無法新增!" });
			validates.valid.define('chkAccountID', {id:'B200_ACCOUNT_ID', errMsg: "匯款戶ID格式錯誤!" });	
			
			//2019-04-30 申請書:可疑交易檢核新增欄位
			validates.valid.define('required', {id:'B200_ACPT_NAME_COUNTRY', errMsg: "無受款人國籍，無法新增!" });
			validates.valid.define('required', {id:'B200_CURR', errMsg: "無幣別，無法新增!" });
			validates.valid.define('required', {id:'B200_IS_CONTRACT', errMsg: "請選擇受款人是否為契約利害關係人!" });
			
			if($F('B200_ACCOUNT_NAME_RM')){
				var hasHalfTypeResult = validation.hasHalfType($F('B200_ACCOUNT_NAME_RM'));				
					if(hasHalfTypeResult){
						validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME_RM', errMsg: "匯款戶名(羅馬拼音)若有輸入，須輸入全形!" });
					}
			}
				
			//2019-05-31 與庭筠確認後:外幣件匯款資料輸入時可先不輸匯率,待匯款檢核輸入時輸入
			if($F('B200_EX_RATE')) {
				validates.valid.define('validate-number', {id:'B200_EX_RATE', errMsg: "外幣匯率需為數字格式!" });	
			}	
			// 若匯款種類選擇一般件(=10),則檢核必須輸入代償戶姓名，且要為全形字，若無，則跳出警示訊息:"代償一匯須輸入代償戶姓名(全形)!"
			if($F('B200_REMIT_TYPE') != '00') {
				if ($F('COMP_NAME') && !("Y"==isFori && $F('B200_CURR') != 'NTD')) {
					var hasHalfTypeResult = validation.hasHalfType($F('COMP_NAME'));				
					if(hasHalfTypeResult){
						validates.valid.define('remitTypeis21', {id:'COMP_NAME', errMsg: "備註須輸入全形!" });
					}
					if($F('COMP_NAME').length>25){
						validates.valid.define('remitTypeis21', {id:'COMP_NAME', errMsg: "備註欄為最多為25個中文字!!" });
					}
				}
			}	
			if($F('B200_ACCOUNT_NAME').length>50 && !isForiCurr){
			   validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "匯款戶名最多為50個中文字!!" });
			}else if($F('B200_ACCOUNT_NAME').length>100 && isForiCurr){
				validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "外幣件，匯款戶名最多為100個英文字!!" });
			}
			if($F('B200_REMIT_TYPE') == 10) {
				<%-- [20240613] 難字調整，將$('BORROW_NAME').innerHTML改為$F('BORROW_NAME') --%>
				if($F('B200_ACCOUNT_NAME') != $F('BORROW_NAME')) {
					return confirm("本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料?");	
					//validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "本件匯款戶名與借款人姓名不相符，請確認是否新增匯款資料!" });
					//$('BORROW_NAME').style.backgroundColor = "#FF8888";
				}
			}
			
		},
		
		// 確認檢核
		confirmChecked: function(){
			validates.valid.define('chkCURR', {id:'B200_CURR', errMsg: "擔保品種類為「國外動產/不動產」，幣別不可為台幣" });
			
			var isForiCurr = ("Y"==isFori && $F('B200_CURR') != 'NTD');
			validates.valid.define('multiple_required', {id:'B200_REMIT_TYPE',errMsg:(isForiCurr?"匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號  必須有值":null)});
			validates.valid.define('must-positive', {id:'B200_REMIT_AMT'});
			
			//2019-04-30 申請書:可疑交易檢核新增欄位
			validates.valid.define('required', {id:'B200_ACPT_NAME_COUNTRY', errMsg: "無受款人國籍，無法新增!" });
			validates.valid.define('required', {id:'B200_CURR', errMsg: "無幣別，無法新增!" });
			validates.valid.define('required', {id:'B200_IS_CONTRACT', errMsg: "請選擇受款人是否為契約利害關係人!" });
			
			//2019-05-31 與庭筠確認後:外幣件匯款資料輸入時可先不輸匯率,待匯款檢核輸入時輸入
			if($F('B200_EX_RATE')) {
				validates.valid.define('validate-number', {id:'B200_EX_RATE', errMsg: "外幣匯率需為數字格式!" });	
			}	
			
			if($F('B200_ACCOUNT_NAME_RM')){
				var hasHalfTypeResult = validation.hasHalfType($F('B200_ACCOUNT_NAME_RM'));				
					if(hasHalfTypeResult){
						validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME_RM', errMsg: "匯款戶名(羅馬拼音)若有輸入，須輸入全形!" });
					}
			}
				
			if($F('B200_ACCOUNT_NAME').length>50 && !isForiCurr){
			   validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "匯款戶名最多為50個中文字，且需為全形!!" });
			}else if($F('B200_ACCOUNT_NAME').length>100 && isForiCurr){
				validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "外幣件，匯款戶名最多為100個英文字!!" });
			}
		},
		
		// 刪除檢核
		deleteChecked: function(){
			var isForiCurr = ("Y"==isFori && $F('B200_CURR') != 'NTD');
			validates.valid.define('multiple_required', {id:'B200_REMIT_TYPE',errMsg:(isForiCurr?"匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號  必須有值":null)});
		},
		
		// 修改檢核
		updateChecked: function(){
			validates.valid.define('chkCURR', {id:'B200_CURR', errMsg: "擔保品種類為「國外動產/不動產」，幣別不可為台幣" });
			
			var isForiCurr = ("Y"==isFori && $F('B200_CURR') != 'NTD');
			validates.valid.define('multiple_required', {id:'B200_REMIT_TYPE',errMsg:(isForiCurr?"匯款種類、匯款日期、匯款金額、匯款戶名、匯款帳號  必須有值":null)});
		    validates.valid.define('must-positive', {id:'B200_REMIT_AMT'});
			validates.valid.define('chkAccountID', {id:'B200_ACCOUNT_ID', errMsg: "匯款戶ID格式錯誤!" });	
			//validates.valid.define('updateDenied', {id:'B200_REMIT_TYPE'});
			//validates.valid.define('required', {id:'B200_UPDATE_REASON', errMsg:"修改原因必須有值"});
			
			//2019-04-30 申請書:可疑交易檢核新增欄位
			validates.valid.define('required', {id:'B200_ACPT_NAME_COUNTRY', errMsg: "無受款人國籍，無法新增!" });
			validates.valid.define('required', {id:'B200_CURR', errMsg: "無幣別，無法新增!" });
			validates.valid.define('required', {id:'B200_IS_CONTRACT', errMsg: "請選擇受款人是否為契約利害關係人!" });
			
			//2019-05-31 與庭筠確認後:外幣件匯款資料輸入時可先不輸匯率,待匯款檢核輸入時輸入
			if($F('B200_EX_RATE')) {
				validates.valid.define('validate-number', {id:'B200_EX_RATE', errMsg: "外幣匯率需為數字格式!" });	
			}	
			
			if($F('B200_ACCOUNT_NAME_RM')){
				var hasHalfTypeResult = validation.hasHalfType($F('B200_ACCOUNT_NAME_RM'));				
					if(hasHalfTypeResult){
						validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME_RM', errMsg: "匯款戶名(羅馬拼音)若有輸入，須輸入全形!" });
					}
			}
				
			if($F('B200_ACCOUNT_NAME').length>50 && !isForiCurr){
			   validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "匯款戶名最多為50個中文字!!" });
			}else if($F('B200_ACCOUNT_NAME').length>100 && isForiCurr){
				validates.valid.define('remitTypeis21', {id:'B200_ACCOUNT_NAME', errMsg: "外幣件，匯款戶名最多為100個英文字!!" });
			}
		},
		
		// 清除檢核設定及記錄
		clear: function(){
			validates.valid.reset();
			validates.valid.clear();
			
			$$('#block_D input[type=text]').each(function(ele) {
				ele.style.backgroundColor = "";
			});
			
			$('B200_REMIT_TYPE').style.backgroundColor = "";
			$('BORROW_NAME').style.backgroundColor = "";
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB40100" , "匯款作業", "匯款資料輸入" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 10, whenDataNull:'', title: "匯款資料",
				autoCheckBox:{
					type:'radio',
					action: function( node , boxStatus, record ) {
						action.doFillupBlockD(record[0], A010Map);
					},
					genRule: function(rec) {
						if(rec.REMIT_PROCESS == '10' || rec.REMIT_PROCESS == '11'){
							return true;
						} else {
							return false;
						}
					}
				},
				<%-- [20240613] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{header:"序號",key:"SER_NO"},
					{header:"匯款種類",key:"REMIT_TYPE_NM"},
					{header:"帳號",key:"REMIT_ACCOUNT_NM"},
					<%-- [20240613] 難字調整：匯款戶名 --%>
					{header:"匯款戶名",key:"ACCOUNT_NAME",attrs:{ style:"font-family:'EUDC'" }},
					{header:"匯款戶名(羅馬拼音)",key:"ACCOUNT_NAME_RM"},
					{header:"備註",key:"COMP_NAME"},
					{header:"匯款金額",key:"REMIT_AMT",
						render: action.formatValue
					},
					{header:"匯款日期",key:"REMIT_DATE",
						render: function(record, value) {
							if (value.length!=10) return "";
							if (value==""){
								ROCdate="";
							}else{
								ROCdate = ((parseInt(value.substring(0,4),10))-1911)+ '/' +value.substring(5,7)+ '/' +value.substring(8,10);
							}
							return ROCdate;
						}
					},
					{header:"處理進度",key:"REMIT_PROC_NM"}
				]
			});
			
			// 檢核初始化
			validates.initValidation();
			
			$('QUERY_COND').value = APPLY_ID;
			grid.load(rtnList || []);
			action.doFillupBlockC(A010Map);
			
			// 監聽: 查詢
			$("BTN_0001").observe('click', button.doQuery );
			
			// 監聽: 新增
			$("BTN_0002").observe('click', button.doInsert );
			
			// 監聽: 確認
			$("BTN_0054").observe('click', button.doConfirm );
			
			// 監聽: 刪除
			$("BTN_0003").observe('click', button.doDelete );
			
			// 監聽:回上一頁
			$("btn_back").observe("click", button.doBack );
			
			// 監聽: 修改
			$("BTN_0004").observe('click', button.doUpdate );
			
			// 監聽: 匯款種類
			$("B200_REMIT_TYPE").observe('change', function() {
				if(rtnList && rtnList.length > 0) {
					var B200_REMIT_TYPE = $('B200_REMIT_TYPE').value;
					var is50=0;
					if(B200_REMIT_TYPE == "50"){
						for(var i=rtnList.length-1; i>=0; i--){
							if(B200_REMIT_TYPE == rtnList[i].REMIT_TYPE){
								action.REMIT_TYPEgearing(B200_REMIT_TYPE, rtnList[i], A010Map, 'I');
								is50=1;
								break;
							}							 
						}
					}
					if(is50==0){
						action.REMIT_TYPEgearing($F('B200_REMIT_TYPE'), {}, A010Map, 'I');
					}
					
				} else {
					action.REMIT_TYPEgearing($F('B200_REMIT_TYPE'), [], A010Map, 'I'); 
				}
				action.IS_CONTRACT_CHANGE(); //TODO
			});
			
			// 監聽: 受理編號轉大寫
			$("QUERY_COND").observe('change', function() {$("QUERY_COND").value = $F("QUERY_COND").toUpperCase();} );	
			
			<%--監聽: 幣別--%>
			$("B200_CURR").observe('change', function() {action.changeCURR();} );
			<%--監聽: 受款人是否為受益人或契約利害關係人--%>
			$('B200_ACCOUNT_ID').observe('change', action.IS_CONTRACT_CHANGE);
			
			<%-- [20200611]申請書-200520002109：增加匯款戶名連動--%>
			$('B200_ACCOUNT_NAME').observe('change',action.changeAccountName);
			
			<%--幣別-台幣--%>
			action.CURR_CONTROL();
			
			
			
			PageUI.resize();
			autoFormatToNumber();
			buttonAuth();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSB40100
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td class="tbYellow" width="15%" >
					<input id="QUERY_KIND_1" name="QUERY_KIND" class="validate-one-required" type="radio" value="1" checked >受理編號
					<input id="QUERY_KIND_2" name="QUERY_KIND" class="validate-one-required" type="radio" value="2" >貸款帳號
				</td>
				<td  class="tbYellow2" width="60%" >
					<input id="QUERY_COND" class="length-check" name="QUERY_COND" type="text" size="11" maxLength="11" value="" >
				</td>
				<td class="tbYellow2" align="center" >
					<input id="BTN_0001" type="button" value='查詢' class="button"> 
				</td>
			</tr>
			
			<tr>
				<td colspan="3"  align="center" >
					<input id="BTN_0002" type="button" value='新增' class="button"> 
					<input id="BTN_0054" type="button" value='確認' class="button"> 
					<input id="BTN_0003" type="button" value='刪除' class="button"> 
					<input id="BTN_0004" type="button" value='修改' class="button">
					<input id ="btn_back" type = "button"  value = "回上一頁" class = "button"/>
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
	<table id='grid'></table>
	<table id='block_C' width="100%" class="tbBox2" >
		<tbody>
			<tr>
				<td colspan='6' class="tbYellow0" align='center' vlign='center' >
					案件資料
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >借款人ID</td>
				<td id="BORROW_ID" class="tbYellow2" align="center" >
				
				</td>
				<td class="tbYellow" width="15%" >借款人姓名</td>
				<%-- [20240613] 難字調整：借款人姓名，td內增加input，並把td的ID移到input上 --%>
				<td id="td_BORROW_NAME" class="tbYellow2" align="center">
				<input type="text" id="BORROW_NAME" class="textDisable" alt="ch" readonly>
				</td>
				<td class="tbYellow" width="15%" >火險狀況</td>
				<td id="FILE_FIREINSU" class="tbYellow2" align="center" >
				
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >貸款種類</td>
				<td id="LOAN_KIND_NM" class="tbYellow2" align="center" >
				
				</td>
				<td class="tbYellow" width="15%" >定期期數</td>
				<td id="FIX_PERIOD" class="tbYellow2" align="center" >
				
				</td>
				<td class="tbYellow" width="15%" >分期期數</td>
				<td id="SPR_PERIOD" class="tbYellow2" align="center" >
				
				</td>
			<%-- 尚未上版，先註解
			</tr>
				<td class="tbYellow" width="15%" >本金彈性還期間</td>
				<td id="FLEX_PERIOD_NM" class="tbYellow2" align="center" colspan="5">
				
				</td>
			<tr>
			--%>
			</tr>
				<td class="tbYellow" width="15%" >本金彈性還期間</td>
				<td id="FLEX_PERIOD_NM" class="tbYellow2" align="center" colspan="5">
				
				</td>
			<tr>
			</tr>
		</tbody>	
	</table>	
	<table id='block_D' width="100%" class="tbBox2" >
		<tbody>		
			<tr>
				<td colspan='6' class="tbYellow0" align='center' vlign='center' >
					匯款明細
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >匯款種類</td>
				<td class="tbYellow2" >
					<select id="B200_REMIT_TYPE" class="choose-one" >
						<c:forEach var="map" items="${REMIT_TYPE_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
					<input id="B200_REMIT_TYPE_Hidden" type="hidden" value="">
				</td>
				<td class="tbYellow" width="15%" >匯款日期</td>
				<td class="tbYellow2" >
					<input id="B200_REMIT_DATE" datatype="ROCDate" type="text" 	class="textBox2  validate-ROCDate" size="12" maxlength="7" value="${LAST_MONTH}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('B200_REMIT_DATE'))">
				</td>
				<td class="tbYellow" width="15%" >匯款金額</td>
				<td class="tbYellow2" >
					<input id="B200_REMIT_AMT" type="text" datatype="number" value="">
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" rowspan='2'>匯款帳號</td>
				<td class="tbYellow2" rowspan='2'>
				<input id="B200_BANK" type="text" size="3" maxLength="3" value=""
				onKeyUP="jump(this,document.getElementById('B200_BRANCH'),3)"> -
				<input id="B200_BRANCH" type="text" size="4" maxLength="4" value=""
				onKeyUP="jump(this,document.getElementById('B200_ACCOUNT'),4)"> -
				<input id="B200_ACCOUNT" type="text" size="16" maxLength="16" value="">
				</td>				
				<td class="tbYellow" width="15%" >匯款戶名</td>
				<td class="tbYellow2" >
					<%-- [20240613] 難字調整：匯款戶名 --%>
					<input id="B200_ACCOUNT_NAME" type="text" value="" class="input" alt="ch"><br>
				</td>	
				<td class="tbYellow" width="15%" rowspan='2'>匯款戶ID</td>
				<td class="tbYellow2" rowspan='2'>
					<input id="B200_ACCOUNT_ID" size="12" maxLength="10" type="text" value="" disabled>
				</td>			
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >匯款戶名(羅馬拼音)</td>
				<td class="tbYellow2" >
					<input id="B200_ACCOUNT_NAME_RM"   type="text" value="" placeholder="羅馬拼音" class="input">
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >幣別</td>
				<td class="tbYellow2" width="15%" >
					<select id="B200_CURR" class="choose-one" >
						<c:forEach var="map" items="${CURR_LIST}" >
							 <option value = "${map.key}" <c:if test="${map.key eq 'NTD'}">selected</c:if> > ${map.value} </option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="15%" >外幣匯率</td>
				<td class="tbYellow2" width="15%" >
					<input id="B200_EX_RATE" size="7" maxLength="5" type="text" value="" disabled>
				</td>
				<td class="tbYellow" width="15%" >受款人是否為契約利害關係人</td>
				<td class="tbYellow2" width="15%">
					<select id="B200_IS_CONTRACT" class="choose-one" >
						<option value = "" selected>請選擇</option>
						<c:forEach var="map" items="${IS_CONTRACT_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select>
				</td>
				
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >受款地區國籍</td>
				<td class="tbYellow2" width="15%" >
					<select id="B200_COUNTRY" class="choose-one" >
						<option value = "" selected>請選擇</option>
						<c:forEach var="map" items="${COUNTRY_LIST}" >
							 <option value = "${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if> > ${map.CODE} ${map.NAME_CH} </option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="15%" >受款人國籍</td>
				<td class="tbYellow2" width="15%"  colspan="3">
					<select id="B200_ACPT_NAME_COUNTRY" class="choose-one" >
						<option value = "" selected>請選擇</option>
						<c:forEach var="map" items="${ACPT_NAME_COUNTRY_LIST}" >
							 <option value = "${map.CODE}" <c:if test="${map.CODE=='TW'}">selected</c:if> > ${map.CODE} ${map.NAME_CH} </option>
						</c:forEach>
					</select>
				</td>
			
			
			</tr>
			
			<tr>
				<td class="tbYellow" width="15%" >代償單位</td>
				<td id="B200_COMP_DIV" name="inner" class="tbYellow2" >
				
				</td>
				<td class="tbYellow" width="15%" >備註</td>
				<td id="B200_COMP_NAME" name="inner" class="tbYellow2" colspan="3" >
				
				</td>								
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >中長期動撥檢核項目</td>
				<td class="tbYellow2" colspan="5" >
				   <input id="MULTI_REMIT_CHECK1" name="MULTI_REMIT_CHECK1" type="checkbox">繳息情形
				   <input id="MULTI_REMIT_CHECK2" name="MULTI_REMIT_CHECK2" type="checkbox">司法院監護、輔助宣告
				   <input id="MULTI_REMIT_CHECK3" name="MULTI_REMIT_CHECK3" type="checkbox">聯徵正常
				   <input id="MULTI_REMIT_CHECK4" name="MULTI_REMIT_CHECK4" type="checkbox">電子謄本查詢<a href="#" onClick="doLinkTo0700()">(連結到電子謄本系統)</a>
				   <font color="green">※中長期動撥請確認前列各項檢核項目是否均已處理※</font>
				</td>										
			</tr>
			
			
			<tr>
				<td class="tbYellow" width="15%" >洗錢防制檢核結果</td>
				<td class="tbYellow2" colspan="5" id="MONEY_LAUDER_NM" name="inner" ></td>
			</tr>
		</tbody>	
	</table>
</body>
</html>
