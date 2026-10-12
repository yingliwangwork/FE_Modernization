<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<%--

[20190801]問題單(20190730151718)：改以幣別分類顯示退票摘要 



[20200727][200721001725]申請書200713000929 法金_優化徵信報告書
詹紘銘 

[20210728] 修改程式  楊青峰 
申請書210114001823聯徵公務機關資料查調作業
 --%>

<html>
<head>
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/InputUtility.js'></script>
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
<script type="text/javascript" >
Event.observe(window, 'load', new DSA20600().initApp);

function DSA20600(){

	function buttonAuth(){
		var authButtons = {
			B0003:'btn_insert',<%--新增--%>
			B0004:'btn_modify',<%--修改--%>
			B0005:'btn_delete',<%--刪除--%>
			B0083:'btn_popup'<%--聯徵記錄--%>
		};
		<dz:grantButtons FUNC_ID="DSA20600" ignored="false"/>
	}

	var grid;

	var rtnList;

	var ld;
	var valid1;

	var checkDataSer = 0;

	var LOG_CNT;

	var applyId;

	/* 共用ajaxpost function */
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0600/');
	
	//--------------------------------------------------------------------------
	// 畫面操作
	//--------------------------------------------------------------------------
	var layout = {
		// 產生list
		createList : function(records){
			grid.load(records);
		},
		// 產生明細
		createDetail : function(obj){
			layout.clear();

			var QRY_MAP = obj.QRY_MAP||{};
			//按鈕控制
			$('btn_insert').enable();
			$('btn_modify').enable();
			$('btn_delete').enable();
			if (QRY_MAP && QRY_MAP.IS_SENT_YN =='Y'){
				$('btn_insert').disable();
			}
			if (QRY_MAP.IS_SENT_YN =='N' || (!QRY_MAP.IS_SENT_YN)){
				$('btn_modify').disable();
			}
			if (QRY_MAP.IS_SENT_YN =='N' || (!QRY_MAP.IS_SENT_YN)){
				$('btn_delete').disable();
			}
				
				
			//【受理編號】
			$('OLD_APPLY_ID').innerHTML = applyId;
			$('NEW_APPLY_ID').setValue($F('APPLY_ID'));
				
			//【被查詢人姓名】
			$('SHOW_NAME').innerHTML = QRY_MAP.NAME||'';
			$('SHOW_ID').setValue(QRY_MAP.ID);
			$('TYPE').setValue(QRY_MAP.TYPE);
			<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
			<%--start--%>
			var CRED_DEPT = QRY_MAP.CRED_DEPT;
			var isCORP = QRY_MAP.isCORP;
			<%--隱藏欄位--%>
			$('STEP1MAP_VM107_DIV').style.display = 'block';
			$('STEP1MAP_VM106_DIV').style.display = 'block';
			$('BAS001_Map_BAS002_DIV').style.display = 'none';
			$('BAS001_Map_BAS6_DIV').style.display = 'none';
			$('CHECK_JUDICIAL_TR').show();
			$('CASHCARDMAP_CASH_CARD_TR').show();
			$('STEP10MAP_TR').hide();
			$('STEP12MAP_TR').hide();
			//$('STEP13MAP_FAS503_TR').hide();//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
			$('STEP13MAP_BA_TR').hide();
			//$('STEP13MAP_POLLUTION_TR').hide();//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
			$('STEP14MAP_TR').hide();
			$('STEP11MAP_RAI002_TR').hide();
			if(CRED_DEPT == '2') {//承辦單位為總公司:法金件
				$('STEP11MAP_RAI002_TR').show();
				if(isCORP == 'Y') {//借款人為法人
					$('STEP1MAP_VM107_DIV').style.display = 'none';
					$('STEP1MAP_VM106_DIV').style.display = 'none';
					$('BAS001_Map_BAS002_DIV').style.display = 'block';
					$('BAS001_Map_BAS6_DIV').style.display = 'block';
					$('CHECK_JUDICIAL_TR').style.display = 'none';
					$('CASHCARDMAP_CASH_CARD_TR').hide();
					$('STEP10MAP_TR').show();
					$('STEP12MAP_TR').show();
					//$('STEP13MAP_FAS503_TR').show();//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
					$('STEP13MAP_BA_TR').show();
					//$('STEP13MAP_POLLUTION_TR').show();//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
					$('QUERYSTEP6_PAY_DIV').style.display = 'none';
				} else if(isCORP == 'N') {
					$('STEP14MAP_TR').show();
					$('QUERYSTEP6_PAY_DIV').style.display = 'block';
				}	
			}
			<%--end%--%>
			
			
			//【通報及補充註記】========================================================================================================
			var STEP1MAP = obj.STEP1MAP;
			if (STEP1MAP){
				//區域:銀行公會消債協商註記
				if (STEP1MAP.VM107){
					if (STEP1MAP.VM107 == 'Y'){
						$('STEP1MAP_VM107_Y').checked = true;
						$('STEP1MAP_VM107_Y').value = STEP1MAP.VM107;
						$('STEP1MAP_VM107_Y').disabled = true;
						$('STEP1MAP_VM107_Y_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					} else {
						$('STEP1MAP_VM107_N').checked = true;
						$('STEP1MAP_VM107_N').value = STEP1MAP.VM107;
						$('STEP1MAP_VM107_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}
				//區域:消債條例信用註記
				if (STEP1MAP.VM106){
					if (STEP1MAP.VM106 == 'Y'){
						$('STEP1MAP_VM106_Y').checked = true;
						$('STEP1MAP_VM106_Y').value = STEP1MAP.VM106;
						$('STEP1MAP_VM106_Y_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					} else {
						$('STEP1MAP_VM106_N').checked = true;
						$('STEP1MAP_VM106_N').value = STEP1MAP.VM106;
						$('STEP1MAP_VM106_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}
				
				//區域:其他補充註記
				if (STEP1MAP.VM108){
					if (STEP1MAP.VM108 == 'Y'){
						$('STEP1MAP_VM108_Y').checked = true;
						$('STEP1MAP_VM108_Y').value = STEP1MAP.VM108;
						$('STEP1MAP_VM108_Y_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					} else {
						$('STEP1MAP_VM108_N').checked = true;
						$('STEP1MAP_VM108_N').value = STEP1MAP.VM108;
						$('STEP1MAP_VM108_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}
				//區域:通報案件記錄
				if (STEP1MAP.VAM2){
					if (STEP1MAP.VAM2 == 'Y'){
						$('STEP1MAP_VAM2_Y').checked = true;
						$('STEP1MAP_VAM2_Y').value = STEP1MAP.VAM2;
						$('STEP1MAP_VAM2_Y_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					} else {
						$('STEP1MAP_VAM2_N').checked = true;
						$('STEP1MAP_VAM2_N').value = STEP1MAP.VAM2;
						$('STEP1MAP_VAM2_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}
			}

			//【授信異常記錄】========================================================================================================
			var BAS001_MAP = obj.BAS001_MAP;
			if (BAS001_MAP){
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				if (BAS001_MAP.BAS002 == "Y") {
					$('BAS001_Map_BAS002_Y').checked = true;
				} else {
					$('BAS001_Map_BAS002_N').checked = true;
				}
				if (BAS001_MAP.BAS6 == "Y") {
					$('BAS001_Map_BAS6_Y').checked = true;
				} else {
					$('BAS001_Map_BAS6_N').checked = true;
				}
				if (BAS001_MAP.EVER_DELINQUENT == 'Y'){
					$('EVER_DELINQUENT_Y').checked = true;  // 'checked'
					$('EVER_DELINQUENT_Y').value = BAS001_MAP.EVER_DELINQUENT || '';
					$('DELINE_NM').innerHTML = BAS001_MAP.DELINE_NM || '';
					$('EVER_DELINQUENT_Y_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
				} else {
					$('EVER_DELINQUENT_N').checked = true;  // 'checked'
					$('EVER_DELINQUENT_N').value = BAS001_MAP.EVER_DELINQUENT;
					$('DELINE_NM').innerHTML = '';
					$('EVER_DELINQUENT_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}
			}else{
				$('EVER_DELINQUENT_N').checked = true;  // 'checked'
				$('DELINE_NM').innerHTML = '';
				$('EVER_DELINQUENT_Y_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
			}
			
			//【票據查詢記錄(徵信紀錄)】========================================================================================================
			var CHECKMAP = obj.CHECKMAP;
			if (CHECKMAP){
				//區域:拒絕往來記錄
				$('NO_DAS002').innerHTML = CHECKMAP.NO_DAS002 || '' ;
				//拒絕往來記錄
				var REJECT_YN_NM1 = CHECKMAP.REJECT_YN_NM1 || '' ;
				var REJECT_YN_NM2 = CHECKMAP.REJECT_YN_NM2 || '' ;
				var REJECT_YN_NM3 = CHECKMAP.REJECT_YN_NM3 || '' ;
				if (CHECKMAP.REJECT_COLOR == 'RED'){
					$('REJECT_YN').innerHTML = REJECT_YN_NM1 + '<span style="color:red" >' + REJECT_YN_NM2 + '</span>' + REJECT_YN_NM3;
				} else {
					$('REJECT_YN').innerHTML = REJECT_YN_NM1 + REJECT_YN_NM2 + REJECT_YN_NM3;
				}
				
				//區域:退票摘要記錄
				if (!CHECKMAP.NO_DAS006){
					$('LOG_FONT').setStyle({'color': 'red', 'fontWeight': 'bold'});//聯徵紀錄整塊區域變紅字粗體
					var RJC_LIST = CHECKMAP.RJC_LIST;
					//退票摘要記錄
					<%-- [20190801]問題單：改以幣別分類顯示退票摘要 --%>	
					for(var i=0; i < RJC_LIST.length;i++){
						var RJC_MAP = RJC_LIST[i]||{};
						//幣別
						var CUR_CODE = new Element('span');
						CUR_CODE.innerHTML = '<br>&emsp;&emsp;&emsp;幣別：'+ RJC_MAP.CURRENCY_CODE;
						$('CUR_CODE').insert(CUR_CODE);
						
						//受查戶之退票(未清償)
						var HEADERB = RJC_MAP.HEADERB||'';
						
						//受查戶之退票(已清償)
						var HEADERC = RJC_MAP.HEADERC||'';
						
						//受查戶擔任負責人企業之退票(未清償)
						var HEADERE = RJC_MAP.HEADERE||'';
						
						//受查戶擔任企業之退票(已清償)		
						var HEADERF = RJC_MAP.HEADERF||'';
						
						if(HEADERB + HEADERC){
							$('HEADERA').update('<br>&emsp;&emsp;&emsp;' + '【受查戶之退票】');
						}
						if (HEADERB){
							var SPANb = '<br>&emsp;&emsp;&emsp;';
							if (RJC_MAP.HEADERB_STYPE == 'RED&&U'){
								SPANb = SPANb + '<span style="color:red" class="textBold" >';
								SPANb = SPANb + HEADERB + '</span>';
							} else {
								SPANb = SPANb + HEADERB;
							}
							var SPAN = new Element('span');
							SPAN.innerHTML = SPANb;
							$('HEADERB').insert(SPAN);	
						}
						if (HEADERC){
							var SPANc = '<br>&emsp;&emsp;&emsp;';
							if (RJC_MAP.HEADERC_STYPE == 'RED&&U'){
								SPANc = SPANc + '<span style="color:red" class="textBold" >';
								SPANc = SPANc + HEADERC + '</span>';
							} else {
								SPANc = SPANc + HEADERC;
							}
							var SPAN = new Element('span');
							SPAN.innerHTML = SPANc;
							$('HEADERC').insert(SPAN);	
						}
						
						if(HEADERE + HEADERF){
							$('HEADERD').update('<br>&emsp;&emsp;&emsp;' + '【受查戶擔任負責人之企業退票】');
						}
						if (HEADERE){
							var SPANe = '<br>&emsp;&emsp;&emsp;';
							if (RJC_MAP.HEADERE_STYPE == 'RED&&U'){
								SPANe = SPANe + '<span style="color:red" class="textBold" >';
								SPANe = SPANe + HEADERE + '</span>';
							} else {
								SPANe = SPANe + HEADERE;
							}
							var SPAN = new Element('span');
							SPAN.innerHTML = SPANe;
							$('HEADERE').insert(SPAN);	
						}
						if (HEADERF){
							var SPANf = '<br>&emsp;&emsp;&emsp;';
							if (RJC_MAP.HEADERF_STYPE == 'RED&&U'){
								SPANf = SPANf + '<span style="color:red" class="textBold" >';
								SPANf = SPANf + HEADERF + '</span>';
							} else {
								SPANf = SPANf + HEADERF;
							}
							var SPAN = new Element('span');
							SPAN.innerHTML = SPANf;
							$('HEADERF').insert(SPAN);	
						}
					}
				} else {
					$('LOG_FONT').setStyle({'color': 'black', 'fontWeight': 'normal'});//聯徵紀錄整塊區域變紅字粗體
					$('NO_DAS006').innerHTML = CHECKMAP.NO_DAS006||'';
				}
			}else{
				$('LOG_FONT').setStyle({'color': 'black', 'fontWeight': 'normal'});//聯徵紀錄整塊區域變紅字粗體
			}
			
			//【授信異常記錄(備註)、票據查詢記錄(票交所查詢記錄)、監護/輔助宣告查證、案件照會及告知作業】========================================================================================================
			var QUERYSTEP9 = obj.QUERYSTEP9;
			if (QUERYSTEP9){
				//【授信異常記錄】-備註
				if (QUERYSTEP9.MSG){
					$('QUERYSTEP9_MSG').value = QUERYSTEP9.MSG;
				} else {
					$('QUERYSTEP9_MSG').value = '';
				}
			
				//【票據查詢記錄】
				//區域:票交所查詢記錄
				if (QUERYSTEP9.CHECK_QUERY_STATUS_YN){//是否有查詢
					//票交所查詢紀錄-說明
					$('QUERYSTEP9_CHECK_STATUS_DESC').setValue(QUERYSTEP9.CHECK_STATUS_DESC||'');
					if (QUERYSTEP9.CHECK_QUERY_STATUS_YN == 'Y'){//有查詢
						$('QUERYSTEP9_CHECK_QUERY_STATUS_Y').checked = true;//有查詢
						$("QUERYSTEP9_CHECK_QUERY_STATUS_N").disable();//無查詢
						$('QUERYSTEP9_CHECK_STATUS_Y').enable();//正常
						$('QUERYSTEP9_CHECK_STATUS_N').enable();//異常
						$('CHECK_QUERY_STATUS').value = QUERYSTEP9.CHECK_QUERY_STATUS_YN;
						if (QUERYSTEP9.CHECK_STATUS_YN){
							if (QUERYSTEP9.CHECK_STATUS_YN == 'Y'){
								$('QUERYSTEP9_CHECK_STATUS_Y').checked = true;
								$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
							} else {
								$('QUERYSTEP9_CHECK_STATUS_N').checked = true;
								$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
							}
						}
					} else {//無查詢
						$('QUERYSTEP9_CHECK_QUERY_STATUS_N').checked = true;
						$("QUERYSTEP9_CHECK_QUERY_STATUS_Y").disable();
						$('QUERYSTEP9_CHECK_STATUS_Y').disable();//正常
						$('QUERYSTEP9_CHECK_STATUS_N').disable();//異常
						$('CHECK_QUERY_STATUS').value = QUERYSTEP9.CHECK_QUERY_STATUS_YN;								
						$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}
								
				//【監護/輔助宣告查證】
				if (QUERYSTEP9.CHECK_JUDICIAL){
					$('JUDICIAL_DESC').value = QUERYSTEP9.JUDICIAL_DESC;//說明
					if (QUERYSTEP9.CHECK_JUDICIAL == '1'){
							$('CHECK_JUDICIAL_Y').checked = true;//本案關係人-是
						} else {
							$('CHECK_JUDICIAL_N').checked = true;
						}
				}
				
				//【案件照會及告知作業】
				//[20200420]新增欄位
				//區域:客戶照會資料
				if(QUERYSTEP9.IS_TEL){//是否照會
					if (QUERYSTEP9.IS_TEL == '1'){//是
						$('IS_TEL_Y').checked = true;
					} else if (QUERYSTEP9.IS_TEL == '0'){//否
						$('IS_TEL_N').checked = true;
					}
				}
				$('IS_TEL_DESC').setValue(QUERYSTEP9.IS_TEL_DESC||'');//是否照會-說明
				
				//區域:客戶照會電話
				$('TEL_TYPE').setValue(QUERYSTEP9.TEL_TYPE || '');//照會電話種類
				$('TEL').update( QUERYSTEP9.TEL || '');
				$('TEL_DATE').setValue(QUERYSTEP9.TEL_DATE || '');//照會日期
				$('HOUR').setValue(QUERYSTEP9.TEL_HOUR || '');
				$('MIN').setValue(QUERYSTEP9.TEL_MIN || '');
				
				//【信用及其他特殊狀況說明】說明
				$('CRED_DESC').setValue(QUERYSTEP9.CRED_DESC||'');
				
				//【經辦人員】
				$('QUERYSTEP9_INPUT_NAME').innerHTML = (QUERYSTEP9.INPUT_NAME||'') + '　' + (ld.formatDate(QUERYSTEP9.INPUT_DATE||''));

				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				<%--企業重大污染資訊(其他說明)--%>//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
				//$('QUERYSTEP9_POLLUTION_DESC').setValue(QUERYSTEP9.POLLUTION_DESC||'');
			}else{
				$('CRED_DESC').setValue('');//信用及其他特殊狀況說明-說明
				$('QUERYSTEP9_INPUT_NAME').innerHTML = '';//經辦人員
				$('IS_TEL_DESC').setValue('');//客戶照會資料-說明
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				<%--企業重大污染資訊(其他說明)--%>//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
				//$('QUERYSTEP9_POLLUTION_DESC').setValue('');
			}
			
			//區域:經手人同時推介保險與房貸	
			//區域:申貸前是否已知悉權益事項
			//區域:疑似勸誘購買新契約
			if(QRY_MAP.TYPE == '0'){//借款人
				$('TD_AGENT_INSU_LOAN').style.display = 'block';
				$('TD_CONFIRM_BEF_LOAN').style.display = 'block';
				$('TD_SUS_INDUCE_BUY_INSU').style.display = 'block';
				$('TD_AGENT_INSU_LOAN_1').style.display = 'none'; //保證人不需照會此項目
				$('TD_CONFIRM_BEF_LOAN_1').style.display = 'none'; //保證人不需照會此項目
				$('TD_SUS_INDUCE_BUY_INSU_1').style.display = 'none'; //保證人不需照會此項目
				$('STEP15MAP_TR').show();//借款人需顯示"所得清單資料"欄位

				if(QUERYSTEP9){
					//區域:經手人同時推介保險與房貸	
					if (QUERYSTEP9.AGENT_INSU_LOAN && QUERYSTEP9.AGENT_INSU_LOAN == '1'){
						$('AGENT_INSU_LOAN_1').checked = true;
					} else if (QUERYSTEP9.AGENT_INSU_LOAN && QUERYSTEP9.AGENT_INSU_LOAN == '0'){
						$('AGENT_INSU_LOAN_0').checked = true;
					} else if (QUERYSTEP9.AGENT_INSU_LOAN && QUERYSTEP9.AGENT_INSU_LOAN == '2'){//經手人自貸件
						$('AGENT_INSU_LOAN_2').checked = true;
					}
					
					//區域:申貸前是否已知悉權益事項
					if (QUERYSTEP9.CONFIRM_BEF_LOAN && QUERYSTEP9.CONFIRM_BEF_LOAN == '1'){
						$('CONFIRM_BEF_LOAN_1').checked = true;
					} else if (QUERYSTEP9.CONFIRM_BEF_LOAN && QUERYSTEP9.CONFIRM_BEF_LOAN == '0'){
						$('CONFIRM_BEF_LOAN_0').checked = true;
					} else if (QUERYSTEP9.CONFIRM_BEF_LOAN && QUERYSTEP9.CONFIRM_BEF_LOAN == '3'){//不適用
						$('CONFIRM_BEF_LOAN_3').checked = true;
					}
					$('CONFIRM_BEF_LOAN_DESC').setValue(QUERYSTEP9.CONFIRM_BEF_LOAN_DESC || '');//說明
					
					//區域:疑似勸誘購買新契約
					if (QUERYSTEP9.SUS_INDUCE_BUY_INSU && QUERYSTEP9.SUS_INDUCE_BUY_INSU == '1'){//是
						$('SUS_INDUCE_BUY_INSU_1').checked = true;
					} else if (QUERYSTEP9.SUS_INDUCE_BUY_INSU && QUERYSTEP9.SUS_INDUCE_BUY_INSU == '0'){//否
						$('SUS_INDUCE_BUY_INSU_0').checked = true;
					} else if (QUERYSTEP9.SUS_INDUCE_BUY_INSU && QUERYSTEP9.SUS_INDUCE_BUY_INSU == '2'){//經手人自貸件
						$('SUS_INDUCE_BUY_INSU_2').checked = true;
					}
					$('SUS_INDUCE_BUY_INSU_DESC').setValue(QUERYSTEP9.SUS_INDUCE_BUY_INSU_DESC || '');//說明
				}
				
				if(obj.IS_SAME == '1' ){ <%--借款人和第一經手人相同，選項鎖定經手人自貸件--%>
					if($('AGENT_INSU_LOAN_2')){
						$('AGENT_INSU_LOAN_2').checked = true;
						$$('div[id="TD_AGENT_INSU_LOAN"] input').each(
								function(obj){
									obj.disabled = true;
									if(obj.type == 'text'){
										obj.setValue('');
									}
								}
							)
						$('AGENT_INSU_LOAN_2').disabled = false;
					}
					if($('SUS_INDUCE_BUY_INSU_2')){
						$('SUS_INDUCE_BUY_INSU_2').checked = true;
						$$('div[id="TD_SUS_INDUCE_BUY_INSU"] input').each(
								function(obj){
									obj.disabled = true;
									if(obj.type == 'text'){
										obj.setValue('');
									}
								}
							)
						$('SUS_INDUCE_BUY_INSU_2').disabled = false;
					}
				}else{ <%--借款人和第一經手人不同，開放所有選項--%>
					$$('div[id="TD_AGENT_INSU_LOAN"] input,div[id="TD_SUS_INDUCE_BUY_INSU"] input').each(
						function(obj){
							obj.enable();
						}
					);
				}
				
			}else if(QRY_MAP.TYPE == '1'){//保證人
				
				$('TD_AGENT_INSU_LOAN').style.display = 'none';
				$('TD_CONFIRM_BEF_LOAN').style.display = 'none';
				$('TD_SUS_INDUCE_BUY_INSU').style.display = 'none';
				$('TD_AGENT_INSU_LOAN_1').style.display = 'block';//保證人不需照會此項目
				$('TD_CONFIRM_BEF_LOAN_1').style.display = 'block';//保證人不需照會此項目
				$('TD_SUS_INDUCE_BUY_INSU_1').style.display = 'block';//保證人不需照會此項目
				$('STEP15MAP_TR').style.display = 'none';//保證人不需顯示"所得清單資料"欄位
				
				<%--照會資料清空--%>
				$$('div[id="TD_AGENT_INSU_LOAN"] input,div[id="TD_CONFIRM_BEF_LOAN"] input,div[id="TD_SUS_INDUCE_BUY_INSU"] input').each(
					function(obj){
						if(obj.type == 'radio'){
							obj.checked = false;
						}else if(obj.type == 'text'){
							obj.setValue('');
						}
					}
				);
			}

			//【金融機構授信總餘額】========================================================================================================
			var QUERYSTEP5 = obj.QUERYSTEP5;
			if (QUERYSTEP5){
				//授信資料日期
				$('BAM087DATE').innerHTML = QUERYSTEP5.BAM087DATE||'';
				$('STEP5MAP_LOAN_AMTA').innerHTML = ld.formatNumber(QUERYSTEP5.LOAN_AMTA ||0) + '仟元';//擔保 正常
				$('STEP5MAP_LOAN_AMTB').innerHTML = ld.formatNumber(QUERYSTEP5.LOAN_AMTB ||0) + '仟元';//無擔保 正常
				$('STEP5MAP_LOAN_AMT302').innerHTML = ld.formatNumber(QUERYSTEP5.LOAN_AMT302 ||0) + '仟元';//共同債務 正常
				$('STEP5MAP_LOAN_AMT303').innerHTML = ld.formatNumber(QUERYSTEP5.LOAN_AMT303 ||0) + '仟元';//從債務 正常
				$('STEP5MAP_PASS_DUE_AMTA').innerHTML = ld.formatNumber(QUERYSTEP5.PASS_DUE_AMTA ||0) + '仟元';//擔保 逾期
				$('STEP5MAP_PASS_DUE_AMTB').innerHTML = ld.formatNumber(QUERYSTEP5.PASS_DUE_AMTB ||0) + '仟元';//無擔保 逾期
				$('STEP5MAP_PASS_DUE_AMT302').innerHTML = ld.formatNumber(QUERYSTEP5.PASS_DUE_AMT302 ||0) + '仟元';//共同債務 逾期
				$('STEP5MAP_PASS_DUE_AMT303').innerHTML = ld.formatNumber(QUERYSTEP5.PASS_DUE_AMT303 ||0) + '仟元';//從債務 逾期
				//擔保 近一年繳款紀錄
				if (QUERYSTEP5.PAY_CODE12A_COLOR && QUERYSTEP5.PAY_CODE12A_COLOR == "RED"){
					$('STEP5MAP_PAY_CODE12A_NM').innerHTML = '<font color="red">' + QUERYSTEP5.PAY_CODE12A_NM + '</font>';
				} else {
					$('STEP5MAP_PAY_CODE12A_NM').innerHTML = '<font color="blue">' + QUERYSTEP5.PAY_CODE12A_NM + '</font>';
				} 
				//無擔保 近一年繳款紀錄
				if (QUERYSTEP5.PAY_CODE12B_COLOR && QUERYSTEP5.PAY_CODE12B_COLOR == "RED"){
					$('STEP5MAP_PAY_CODE12B_NM').innerHTML = '<font color="red">' + QUERYSTEP5.PAY_CODE12B_NM + '</font>';
				} else {
					$('STEP5MAP_PAY_CODE12B_NM').innerHTML = '<font color="blue">' + QUERYSTEP5.PAY_CODE12B_NM + '</font>';
				}
				//債權轉讓註記
				if (QUERYSTEP5.COUNT608_COLOR && QUERYSTEP5.COUNT608_COLOR == "RED"){
					$('STEP5MAP_COUNT608_NM').innerHTML = '<font color="red">' + QUERYSTEP5.COUNT608_NM + '</font>';
				} else {
					$('STEP5MAP_COUNT608_NM').innerHTML = '<font color="blue">' + QUERYSTEP5.COUNT608_NM + '</font>';
				}
				//催收款項呆帳
				if (QUERYSTEP5.ACCOUNT_CODEA087_COLOR && QUERYSTEP5.ACCOUNT_CODEA087_COLOR == "RED"){
					$('STEP5MAP_ACCOUNT_CODE087').innerHTML = '<font color="red">' + QUERYSTEP5.ACCOUNT_CODE087_NM + QUERYSTEP5.ACCOUNT_CODE302_NM + QUERYSTEP5.ACCOUNT_CODE303_NM + '</font>';
				} else {
					$('STEP5MAP_ACCOUNT_CODE087').innerHTML = '<font color="blue">' + QUERYSTEP5.ACCOUNT_CODE087_NM + QUERYSTEP5.ACCOUNT_CODE302_NM + QUERYSTEP5.ACCOUNT_CODE303_NM + '</font>';
				}
				
				//區域:新增授信及清償
				$('STEP5MAP_NEW_LOAN_AMT').innerHTML = '　' + ld.formatNumber(QUERYSTEP5.NEW_LOAN_AMT ||0) + '　';//新增授信金額
				$('STEP5MAP_NEW_PAY_LOAN_AMT').innerHTML = '　' + ld.formatNumber(QUERYSTEP5.NEW_PAY_LOAN_AMT ||0) + '　';//新增清償金額
			} else {
				$('BAM087DATE').innerHTML = '';
				$('STEP5MAP_LOAN_AMTA').innerHTML = '0仟元';
				$('STEP5MAP_LOAN_AMTB').innerHTML = '0仟元';
				$('STEP5MAP_LOAN_AMT302').innerHTML = '0仟元';
				$('STEP5MAP_LOAN_AMT303').innerHTML = '0仟元';
				$('STEP5MAP_PASS_DUE_AMTA').innerHTML = '0仟元';
				$('STEP5MAP_PASS_DUE_AMTB').innerHTML = '0仟元';
				$('STEP5MAP_PASS_DUE_AMT302').innerHTML = '0仟元';
				$('STEP5MAP_PASS_DUE_AMT303').innerHTML = '0仟元';
				$('STEP5MAP_PAY_CODE12A_NM').innerHTML = '<font color="blue">無</font>';
				$('STEP5MAP_PAY_CODE12B_NM').innerHTML = '<font color="blue">無</font>';
				$('STEP5MAP_COUNT608_NM').innerHTML = '<font color="blue">無</font>';
				$('STEP5MAP_ACCOUNT_CODE087').innerHTML = '<font color="blue">無</font>';
				$('STEP5MAP_NEW_LOAN_AMT').innerHTML = '　0　';
				$('STEP5MAP_NEW_PAY_LOAN_AMT').innerHTML = '　0　';
			}

			//【現金卡記錄】========================================================================================================
			var CASHCARDMAP = obj.CASHCARDMAP;
			if (CASHCARDMAP){
				//張數
				$('CASHCARDMAP_CASH_CARD_CNT').innerHTML =  '　' + (CASHCARDMAP.CASH_CARD_CNT||'0') + '　';
				//可動用額度
				$('CASHCARDMAP_CONTRACT_AMT').innerHTML =  '　' + ld.formatNumber(CASHCARDMAP.CONTRACT_AMT||'0') + '　';
				//已動用額度
				$('CASHCARDMAP_TOTAL_AMT').innerHTML =   '　' + ld.formatNumber(CASHCARDMAP.TOTAL_AMT||'0') + '　';
					
				//可動用餘額>0且已動用餘額>0
				if (CASHCARDMAP.CASH_CARD_CNT && CASHCARDMAP.CASH_CARD_CNT > 0 && CASHCARDMAP.TOTAL_AMT && CASHCARDMAP.TOTAL_AMT >0){
					//是否逾期
					var PASS_DUE_AMT = CASHCARDMAP.PASS_DUE_AMT||0;
					if (PASS_DUE_AMT <= 0){
						$('CASHCARDMAP_PASS_DUE_AMT_Y').checked = true;
						$('CASHCARDMAP_PASS_DUE_AMT_Y').value = PASS_DUE_AMT;
						$('CASHCARDMAP_PASS_DUE_AMT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					} else {
						$('CASHCARDMAP_PASS_DUE_AMT_N').checked = true;
						$('CASHCARDMAP_PASS_DUE_AMT_N').value = PASS_DUE_AMT;
						$('CASHCARDMAP_PASS_DUE_AMT_N_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					}
					//繳款狀況
					var PAY_CODE068_CNT = CASHCARDMAP.PAY_CODE068_CNT||0;
					if (PAY_CODE068_CNT <= 0){
						$('CASHCARDMAP_PAY_CODE_068_CNT_Y').checked = true;
						$('CASHCARDMAP_PAY_CODE_068_CNT_Y').value = PAY_CODE068_CNT;
						$('CASHCARDMAP_PAY_CODE_068_CNT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					} else {
						$('CASHCARDMAP_PAY_CODE_068_CNT_N').checked = true;
						$('CASHCARDMAP_PAY_CODE_068_CNT_N').value = PAY_CODE068_CNT;
						$('CASHCARDMAP_PAY_CODE_068_CNT_N_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					}
				}else{
					$('CASHCARDMAP_PASS_DUE_AMT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});//有逾期
					$('CASHCARDMAP_PAY_CODE_068_CNT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});//有延遲
				}
			} else {
				$('CASHCARDMAP_CASH_CARD_CNT').innerHTML = '　0　';//張數
				$('CASHCARDMAP_CONTRACT_AMT').innerHTML = '　0　';//可動用額度
				$('CASHCARDMAP_TOTAL_AMT').innerHTML = '　0　';//已動用額度
				
				$('CASHCARDMAP_PAY_CODE_068_CNT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				$('CASHCARDMAP_PASS_DUE_AMT_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
			}

			//【信用卡記錄】========================================================================================================
			var QUERYSTEP6 = obj.QUERYSTEP6;
			if (QUERYSTEP6){
				//有效卡數
				$('QUERYSTEP6_LIVE_CNT').innerHTML = '　' + Number(QUERYSTEP6.LIVE_CNT)  + '　';
				//有無強停
				if (QUERYSTEP6.DEAD_CNT){
					if (Number (QUERYSTEP6.DEAD_CNT) > 0){
						$('QUERYSTEP6_DEAD_CNT_1').checked = true;
						$('QUERYSTEP6_DEAD_CNT_1').value = Number (QUERYSTEP6.DEAD_CNT);
						$('QUERYSTEP6_AB_CODE_NM').innerHTML = QUERYSTEP6.AB_CODE_NM;//最近一次強制停卡原因
						$('QUERYSTEP6_DEAD_CNT_1_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
					} else {
						$('QUERYSTEP6_DEAD_CNT_0').checked = true;
						$('QUERYSTEP6_DEAD_CNT_0').value = Number (QUERYSTEP6.DEAD_CNT);
						$('QUERYSTEP6_DEAD_CNT_1_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					}
				}else{
					$('QUERYSTEP6_DEAD_CNT_1_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}
				
				//過去一年內，有兩次以上超過30天的遲繳記錄
				if (Number (QUERYSTEP6.PAY_CODE1) > 1){
					$('QUERYSTEP6_PAY_CODE1').checked = true;
					$('QUERYSTEP6_PAY_CODE1').value = Number (QUERYSTEP6.PAY_CODE1);
				} 
				//過去一年內，有一次以上超過60天的遲繳記錄
				if (Number (QUERYSTEP6.PAY_CODE2) > 0){
					$('QUERYSTEP6_PAY_CODE2').checked = true;
					$('QUERYSTEP6_PAY_CODE2').value = Number (QUERYSTEP6.PAY_CODE2);
				} 			
				//近六個月內循環有2個月使用率
				if (Number (QUERYSTEP6.PAY_CODE3) > 1){
					$('QUERYSTEP6_PAY_CODE3').checked = true;
					$('QUERYSTEP6_PAY_CODE3').value = Number (QUERYSTEP6.PAY_CODE3);
				}
				//近六個月內有任2個月使用信用卡預借現金
				if (Number (QUERYSTEP6.PAY_CODE4) > 1){
					$('QUERYSTEP6_PAY_CODE4').checked = true;
					$('QUERYSTEP6_PAY_CODE4').value = Number (QUERYSTEP6.PAY_CODE4);
				}
				//預借現金
				if (QUERYSTEP6.CASH_YN){
					if (Number (QUERYSTEP6.CASH_YN) > 0){
						$('QUERYSTEP6_CASH_YN_1').checked = true;
						$('QUERYSTEP6_CASH_YN_1').value = Number (QUERYSTEP6.CASH_YN);
						$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　' + (QUERYSTEP6.CASHLENT_STR||'') + '　';//年份
						$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　' + (QUERYSTEP6.CASHLENT_INT||'') + '　';//期數
						$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　' + ld.formatNumber(QUERYSTEP6.SUM_CASHLENT_INT ||0) + '　';//最高金額
					} else {
						$('QUERYSTEP6_CASH_YN_0').checked = true;
						$('QUERYSTEP6_CASH_YN_0').value = Number (QUERYSTEP6.CASH_YN);
						$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　0　';
						$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　0　';
						$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　0　';
					}
				}else{
					$('QUERYSTEP6_CASH_YN_0').checked = true;
					$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　0　';
					$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　0　';
					$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　0　';
				}
				//繳款狀況
				if (QUERYSTEP6.PAY_CODE034_CNT){
					if (Number (QUERYSTEP6.PAY_CODE034_CNT) > 0){
						$('QUERYSTEP6_PAY_CODE034_CNT_YN').checked = true;
						$('QUERYSTEP6_PAY_CODE034_CNT_YN_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
						$('QUERYSTEP6_PAY_CODE034_CNT_YN').value = Number (QUERYSTEP6.PAY_CODE034_CNT);
						$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　' + QUERYSTEP6.PAY_CODE034_CNT + '　';
					} else {
						$('QUERYSTEP6_PAY_CODE034_CNT_YN').checked = false;
						$('QUERYSTEP6_PAY_CODE034_CNT_YN_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
						$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';
					}
				} else {
					$('QUERYSTEP6_PAY_CODE034_CNT_YN').checked = false;
					$('QUERYSTEP6_PAY_CODE034_CNT_YN_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
					$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';
				}
				//債權狀態
				if (Number (QUERYSTEP6.DEBT_CODE) > 0){
					$('QUERYSTEP6_DEBT_CODE').checked = true;
					$('QUERYSTEP6_DEBT_CODE_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
				}else{
					$('QUERYSTEP6_DEBT_CODE').checked = false;
					$('QUERYSTEP6_DEBT_CODE_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}
			} else {
				$('QUERYSTEP6_LIVE_CNT').innerHTML = '　0　';//有效卡數
				$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　0　';//預借現金-年份
				$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　0　';//預借現金-期數
				$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　0　';//預借現金-最高金額
				$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';//繳款狀況-期數
				
				$('QUERYSTEP6_DEAD_CNT_1_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				$('QUERYSTEP6_PAY_CODE034_CNT_YN_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				$('QUERYSTEP6_DEBT_CODE_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				
			}

			//【近三個月被查詢次數】========================================================================================================
			var QRY_CNT_MAP = obj.QRY_CNT_MAP;
			if (obj.QRY_CNT_MAP){
				$('QRY_CNT_MAP_CNT1').innerHTML = '　' + ld.formatNumber(QRY_CNT_MAP.CNT1 || 0 )+ '　';//新業務
				$('QRY_CNT_MAP_CNT2').innerHTML = '　' + ld.formatNumber(QRY_CNT_MAP.CNT2 || 0 )+ '　';//舊業務
			} else {
				$('QRY_CNT_MAP_CNT1').innerHTML = '　0　';//新業務
				$('QRY_CNT_MAP_CNT2').innerHTML = '　0　';//舊業務
			}
			
			<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
			<%--start--%>
			//【勞工退休準備金】========================================================================================================
			var STEP10MAP = obj.QUERYSTEP10;
			if (STEP10MAP) {
				$('STEP10MAP_ARREARS_INFO').innerHTML = (STEP10MAP.NO_RAS004||''); //積欠工資墊償基金提撥情形
				$('STEP10MAP_ARREARS_MONTHS').innerHTML = '　' + ld.formatNumber(STEP10MAP.ARREARS_MONTHS || 0 )+ '　';
				//勞工退休準備金帳戶現況
				if (STEP10MAP.RAM006_STATUS_CNT) {
					$('STEP10MAP_RAM006_STATUS').innerHTML = STEP10MAP.RAM006_STATUS_CNT;
				} else {
					$('STEP10MAP_RAM006_STATUS').innerHTML = STEP10MAP.RAM006_STATUS_NM || '無該項資訊';
				}
				//勞工退休準備金專戶餘額>=預估舊制退休金+預估舊制資遣費
				if(STEP10MAP.NO_RAM005) {
					$('STEP10MAP_NO_RAM005').innerHTML = (STEP10MAP.NO_RAM005||'');
				} else {
					if("Y" == STEP10MAP.BALANCE_IS_OVER) {
						$('STEP10MAP_BALANCE_IS_OVER_Y').checked = true;
					} else {
						$('STEP10MAP_BALANCE_IS_OVER_N').checked = true;
					}
				}
				$('STEP10MAP_BALANCE').innerHTML = '　' + ld.formatNumber(STEP10MAP.BALANCE || 0)+ '　';
				$('STEP10MAP_RETIRE_SERVERANCE_AMT').innerHTML = '　' + ld.formatNumber(STEP10MAP.RETIRE_SERVERANCE_AMT || 0)+ '　';
			} else {
				$('STEP10MAP_ARREARS_INFO').innerHTML = '無該項資訊';
				$('STEP10MAP_ARREARS_MONTHS').innerHTML = '';
				$('STEP10MAP_RAM006_STATUS').innerHTML = '無該項資訊';
				$('STEP10MAP_NO_RAM005').innerHTML = '';
				$('STEP10MAP_BALANCE_IS_OVER_Y').checked = false;
				$('STEP10MAP_BALANCE_IS_OVER_N').checked = false;
				$('STEP10MAP_BALANCE').innerHTML = '';
				$('STEP10MAP_RETIRE_SERVERANCE_AMT').innerHTML = '';
			}
			//【融資租賃交易資訊】========================================================================================================
			var STEP11MAP = obj.QUERYSTEP11;
			if (STEP11MAP) {
				$('STEP11MAP_RAI002_DATA_YYYMM').innerHTML =(STEP11MAP.RAI002_DATA_YYYMM || ''); //資料年月
				$('STEP11MAP_RAM00_Y').checked = ("Y" == STEP11MAP.RAM00);
				$('STEP11MAP_RAM00_N').checked = ("N" == STEP11MAP.RAM00);
				$('STEP11MAP_DELAY_AMT_0_Y').checked = ("Y" == STEP11MAP.DELAY_AMT_0);
				$('STEP11MAP_DELAY_AMT_0_N').checked = ("N" == STEP11MAP.DELAY_AMT_0);
			} else {
				$('STEP11MAP_RAI002_DATA_YYYMM').innerHTML = ''; //資料年月
				$('STEP11MAP_RAM00_Y').checked = false;
				$('STEP11MAP_RAM00_N').checked = false;
				$('STEP11MAP_DELAY_AMT_0_Y').checked = false;
				$('STEP11MAP_DELAY_AMT_0_N').checked = false;
			}
			//【企業信用評分資訊】========================================================================================================
			var STEP12MAP = obj.QUERYSTEP12;
			if (STEP12MAP && "Y"!=STEP12MAP.NO_KCS2) {//查有KCS210或KCS200
				if ("1" == STEP12MAP.SCORE_STAT) {
					//當"1" == STEP12MAP.SCORE_STAT(無法評分)，本向所有欄位皆為空白
					$('STEP12MAP_SCORE_STAT').innerHTML = "無法評分"; //企業評分
					$('STEP12MAP_PCT_LO').innerHTML = ''; //所有受評者之百分點位
					$('STEP12MAP_PCT_HI').innerHTML = '';
					$('STEP12MAP_IND_EXPR').innerHTML = ''; //所屬受評行業別
					$('STEP12MAP_IND_PCT_LO').innerHTML = ''; //所有同業受評者之百分點位
					$('STEP12MAP_IND_PCT_HI').innerHTML = '';
					$('STEP12MAP_FA_YYYY').innerHTML = ''; //財報使用之最近年度
				} else {
					//企業評分
					if ("2"== STEP12MAP.SCORE_STAT) {//固定評分
						$('STEP12MAP_SCORE_STAT').innerHTML = '　' + ld.formatNumber(STEP12MAP.SCORE || 0) + '　' + '分 (固定評分)';
					} else {//SCORE_STAT = 0
						$('STEP12MAP_SCORE_STAT').innerHTML = '　' + ld.formatNumber(STEP12MAP.SCORE || 0) + '　' + '分';
					}
					$('STEP12MAP_PCT_LO').innerHTML = '　' + ld.formatNumber(STEP12MAP.PCT_LO || 0) + '　'; //所有受評者之百分點位
					$('STEP12MAP_PCT_HI').innerHTML = '　' + ld.formatNumber(STEP12MAP.PCT_HI || 0) + '　';
					$('STEP12MAP_IND_EXPR').innerHTML = STEP12MAP.IND_EXPR || ''; //所屬受評行業別
					$('STEP12MAP_IND_PCT_LO').innerHTML = '　' + ld.formatNumber(STEP12MAP.IND_PCT_LO || 0) + '　'; //所有同業受評者之百分點位
					$('STEP12MAP_IND_PCT_HI').innerHTML = '　' + ld.formatNumber(STEP12MAP.IND_PCT_HI || 0) + '　';
					$('STEP12MAP_FA_YYYY').innerHTML =  STEP12MAP.FA_YYYY || '' ; //財報使用之最近年度
				}
				//無法評分之理由
				$('STEP12MAP_REASON_EXPR').innerHTML = STEP12MAP.REASON_EXPR || '';
			} else {
				$('STEP12MAP_SCORE_STAT').innerHTML = ''; //企業評分
				$('STEP12MAP_PCT_LO').innerHTML = ''; //所有受評者之百分點位
				$('STEP12MAP_PCT_HI').innerHTML = '';
				$('STEP12MAP_IND_EXPR').innerHTML = ''; //所屬受評行業別
				$('STEP12MAP_IND_PCT_LO').innerHTML = ''; //所有同業受評者之百分點位
				$('STEP12MAP_IND_PCT_HI').innerHTML = '';
				$('STEP12MAP_FA_YYYY').innerHTML = ''; //財報使用之最近年度
				$('STEP12MAP_REASON_EXPR').innerHTML = '';//無法評分之理由
			}
			//【與同業比較資訊(比例與結構)、關係人名單與借款資訊、企業重大污染資訊】========================================================================================================
			var STEP13MAP = obj.QUERYSTEP13;
			if (STEP13MAP) {
				//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
				//$('STEP13MAP_FAS503_YYY').innerHTML =  '　' + (STEP13MAP.FAS503_YYY || '') + '　'; //同業資訊-查詢年度
				//$('STEP13MAP_FR_TYPE_NM').innerHTML = STEP13MAP.FR_TYPE_NM || ''; //同業資訊-財報類型
				//$('STEP13MAP_CFN_NAME').innerHTML = STEP13MAP.CFN_NAME || ''; //同業資訊-行業名稱
				$('STEP13MAP_BA_YYYMM').innerHTML = STEP13MAP.BA_YYYMM || ''; //關係人名單-資料年月
				$('STEP13MAP_REL_CNT').innerHTML =  '　' + ld.formatNumber(STEP13MAP.REL_CNT || 0) + '　'; //關係人名單-關係人人數
				//關係人名單-是否已借款
				$('STEP13MAP_LOAN_FACILITY_Y').checked = ("Y" == STEP13MAP.LOAN_FACILITY);
				$('STEP13MAP_LOAN_FACILITY_N').checked = ("N" == STEP13MAP.LOAN_FACILITY);
				//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
				//$('STEP13MAP_INFO').innerHTML = STEP13MAP.NO_RAM009||''; //重大污染-處分資訊
				//$('STEP13MAP_JUDGEDATE').innerHTML = STEP13MAP.JUDGEDATE || ''; //重大污染-處分日期
			} else {
				//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
				//$('STEP13MAP_FAS503_YYY').innerHTML = ''; //同業資訊-查詢年度
				//$('STEP13MAP_FR_TYPE_NM').innerHTML = ''; //同業資訊-財報類型
				//$('STEP13MAP_CFN_NAME').innerHTML = ''; //同業資訊-行業名稱
				$('STEP13MAP_BA_YYYMM').innerHTML = ''; //關係人名單-資料年月
				$('STEP13MAP_REL_CNT').innerHTML = ''; //關係人名單-關係人人數
				$('STEP13MAP_LOAN_FACILITY_Y').checked = false; //關係人名單-是否已借款
				$('STEP13MAP_LOAN_FACILITY_N').checked = false; //關係人名單-是否已借款
				//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
				//$('STEP13MAP_INFO').innerHTML = ''; //重大污染-處分資訊
				//$('STEP13MAP_JUDGEDATE').innerHTML = ''; //重大污染-處分日期
			}
			
			// [20210728] 所得清單資料 ========================================================================================================
			var STEP15MAP = obj.QUERYSTEP15;
			if (STEP15MAP && STEP15MAP.NO_TAM500 == 'N') {
				
				var postfix = ['_01', '_02', '_03', '_04', '_05', '_OTHER', '_SUM'];
				
				$('INQ_YR').innerHTML = STEP15MAP.INQ_YR || '';
				for(var i=0;i<postfix.length;i++) {
					
					// 資料筆數
					var incmTpId = 'INCM_TP' + postfix[i];
					var incmTpVal = STEP15MAP[incmTpId];
					if(incmTpVal != '0') {
						$(incmTpId).innerHTML = ld.formatNumber(incmTpVal);
					}
					
					// 所得額, 轉換為仟元，小數點無條件捨去
					var paymentTAmtId = 'PAYMENT_T_AMT' + postfix[i];
					var paymentTAmtVal = STEP15MAP[paymentTAmtId];
					if(paymentTAmtVal != '0') {
						$(paymentTAmtId).innerHTML = ld.formatNumber(Math.floor(parseInt(paymentTAmtVal, 10)/1000)) + '仟元';
					}
					if(postfix[i] != '_SUM'){
						// 主要所得單位
						var whUnitNmMaxId = 'WH_UNIT_NM_MAX' + postfix[i];
						$(whUnitNmMaxId).innerHTML = STEP15MAP[whUnitNmMaxId] || '';
						
						// 主要單位所得, 轉換為仟元，小數點無條件捨去
						var paymentTAmtMaxId = 'PAYMENT_T_AMT_MAX' + postfix[i];
						var paymentTAmtMaxVal = STEP15MAP[paymentTAmtMaxId];
						if(paymentTAmtMaxVal != '0') {
							$(paymentTAmtMaxId).innerHTML = ld.formatNumber(Math.floor(parseInt(paymentTAmtMaxVal, 10)/1000)) + '仟元';
						}
					}
				}
			}
			
			//【擔任事業體負責人或經理人】========================================================================================================
			var STEP14MAP = obj.QUERYSTEP14;
			if (STEP14MAP) {
				//任職公司董監事/經理人
				$('STEP14MAP_NO_ACM009_N').checked = (STEP14MAP.NO_ACM009 == 'Y');
				$('STEP14MAP_NO_ACM009_Y').checked = (STEP14MAP.NO_ACM009 == 'N');
				$('STEP14MAP_ACM009_CNT').innerHTML = '　' + ld.formatNumber(STEP14MAP.ACM009_CNT || 0) + '　';
				//任職獨資合夥事業負責人/經理人
				$('STEP14MAP_NO_ACM022_N').checked = (STEP14MAP.NO_ACM022 == 'Y');
				$('STEP14MAP_NO_ACM022_Y').checked = (STEP14MAP.NO_ACM022 == 'N');
				$('STEP14MAP_ACM022_CNT').innerHTML = '　' + ld.formatNumber(STEP14MAP.ACM022_CNT || 0) + '　';
				//任職有限合夥事業合夥人/經理人
				$('STEP14MAP_NO_ACM025_N').checked = (STEP14MAP.NO_ACM025 == 'Y');
				$('STEP14MAP_NO_ACM025_Y').checked = (STEP14MAP.NO_ACM025 == 'N');
				$('STEP14MAP_ACM025_CNT').innerHTML = '　' + ld.formatNumber(STEP14MAP.ACM025_CNT || 0) + '　';
			} else {
				//任職公司董監事/經理人
				$('STEP14MAP_NO_ACM009_N').checked = false;
				$('STEP14MAP_NO_ACM009_Y').checked = false;
				$('STEP14MAP_ACM009_CNT').innerHTML = '　　';
				//任職獨資合夥事業負責人/經理人
				$('STEP14MAP_NO_ACM022_N').checked = false;
				$('STEP14MAP_NO_ACM022_Y').checked = false;
				$('STEP14MAP_ACM022_CNT').innerHTML = '　　';
				//任職有限合夥事業合夥人/經理人
				$('STEP14MAP_NO_ACM025_N').checked = false;
				$('STEP14MAP_NO_ACM025_Y').checked = false;
				$('STEP14MAP_ACM025_CNT').innerHTML = '　　';
			}
			<%--end--%>
			
			//區域:客戶照會資料-健康情形
			//非正常件，才顯示
			if(obj.HEALTHY_NM){
				$('HEALTHY_NM').innerHTML = "健康情形："+obj.HEALTHY_NM;
			}
			
			//【貸款來源】
			//若貸款來源為「代辦」需顯示紅色字型
			if(obj.CASE_ORIGIN == '6'){
				$('CASE_ORIGIN_NM').update('<font color="red">'+obj.CASE_ORIGIN_NM||''+'</font>');
			}else{
				$('CASE_ORIGIN_NM').update(obj.CASE_ORIGIN_NM||'');
			}
				
		},
		// 清除畫面欄位
		clear:function(type){
			$$('#detailTable input[type="text"]').each(
				function(text){
					// 執行清除
					if(type == "1"){
						text.setValue('');
					}else if(text.id != "APPLY_ID"){
						text.setValue('');
					}
				}
			);
			
			$$('#detailTable input[type="checkbox"]').each(
				function(checkbox){
					checkbox.enable();
					checkbox.checked = false;
				}
			);
			
			$$('#detailTable input[type="radio"]').each(
				function(radio){
					radio.enable();
					radio.checked = false;
				}
			);
	
			$$('#detailTable span').each(
				function(span){
					if(span.innerHTML.indexOf("第") <= 0){
						span.innerHTML = ''; 
					}
				}
			);
			
			$('CRED_DESC').setValue('');
			
			//先將欄位回覆成初始狀況
			$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
			$('TD_AGENT_INSU_LOAN').style.display = 'block';
			$('TD_CONFIRM_BEF_LOAN').style.display = 'block';
			$('TD_SUS_INDUCE_BUY_INSU').style.display = 'block';			
			$('TD_AGENT_INSU_LOAN_1').style.display = 'none';
			$('TD_CONFIRM_BEF_LOAN_1').style.display = 'none';
			$('TD_SUS_INDUCE_BUY_INSU_1').style.display = 'none';
			<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
			<%--start--%>
			$('STEP1MAP_VM107_DIV').style.display = 'block';
			$('STEP1MAP_VM106_DIV').style.display = 'block';
			$('BAS001_Map_BAS002_DIV').style.display = 'block';
			$('BAS001_Map_BAS6_DIV').style.display = 'block';
			$('CHECK_JUDICIAL_TR').hide();
			$('CASHCARDMAP_CASH_CARD_TR').hide();
			$('STEP10MAP_TR').hide();
			$('STEP14MAP_TR').hide();
			$('STEP11MAP_RAI002_TR').hide();
			$('STEP12MAP_TR').hide();
			//$('STEP13MAP_FAS503_TR').hide();//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
			$('STEP13MAP_BA_TR').hide();
			//$('STEP13MAP_POLLUTION_TR').hide();//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
			<%--end--%>
			<%--照會資料清空--%>
			/*$$('div[id="TD_AGENT_INSU_LOAN"] input,div[id="TD_CONFIRM_BEF_LOAN"] input,div[id="TD_SUS_INDUCE_BUY_INSU"] input').each(
				function(obj){
					obj.disabled = false;
					if(obj.type == 'radio'){
						obj.checked = false;
					}else if(obj.type == 'text'){
						obj.setValue('');
					}
				}
			)*/
		}//end clear
	};

	var doTrimTextArea = function (){
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
		if($F('CRED_DESC').length>0){
			$('CRED_DESC').value = $F('CRED_DESC').replace(/'/gi, "").replace(/"/gi, "");
			while(true){
				ln0 = $F('CRED_DESC').length;
				while(true){
					ln1 =$F('CRED_DESC').length;
					if($F('CRED_DESC').indexOf('\r\n')>=0){
						//trim掉最後一個\r\n
						$('CRED_DESC').value = $F('CRED_DESC').replace(/\r\n$/g, "");
						if(ln1 == $F('CRED_DESC').length){
							break;	
						}
					}else{
						break;
					}
				}
				while(true){
					ln2 = $F('CRED_DESC').length;
					if($F('CRED_DESC').indexOf(' ')>=0){
						$('CRED_DESC').value = $F('CRED_DESC').replace(/ $/g, "");
						if(ln2 == $F('CRED_DESC').length){
							break;	
						}
					}else{
						break;
					}
				}
				if(ln0 == $F('CRED_DESC').length){
					break;	
				}
			}
		}
		//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
	}
	
	
	//按鈕動作
	<%--查詢作業--%>
	function query() {
		if(!validates.checkInput("query")){
			return;
		}
		applyId = $F('APPLY_ID');

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': applyId});

		checkDataSer = 0;
		ajaxRequest.post('query',{"APPLY_ID":$F('APPLY_ID')},
		 	function(resp){
				LOG_CNT = 0;
				rtnList = resp.returnList;
				var dataArray = [];
				for(var i=0; i<rtnList.length; i++){
					rtnList[i].QRY_MAP['SER_NO'] = i;
					//檢核LOG_CNT是否有值(大於1)
					LOG_CNT = Number(LOG_CNT) + Number(rtnList[i].QRY_MAP['LOG_CNT']);
					<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
					dataArray.push(rtnList[i].QRY_MAP);
				}				
				grid.load(dataArray, null, null, ['0']);
			},
		 	function(resp){
				if(resp.DATA_NOT_FOUND){
					grid.load([]);
					layout.clear();
				}
			}
		);

	};
	
	<%--新增作業--%>
	var doInsert = function (){
			
		doTrimTextArea();
		
		if(!checkSelect()){
			return;
		}
		if(!validates.checkInput("insert")){
			return;
		}
		var checkedRec = grid.getCheckedRecord();
		var jsonData = $("form1").serialize( true );
		jsonData.TEL = $('TEL').innerHTML;
		checkDataSer = checkedRec[0].SER_NO;
		
		ajaxRequest.post('insert', 
				{ 	'qryMap' : Object.toJSON(checkedRec[0]),
					'jsonData' : Object.toJSON(jsonData),
					'TEL_TYPE' : $F('TEL_TYPE'),
					'HOUR' : $F('HOUR'),
					'MIN' : $F('MIN')
				}, 
				function(resp) {
					rtnList = resp.returnList;
					var dataArray = [];
					for(var i=0; i<rtnList.length; i++){
						rtnList[i].QRY_MAP['SER_NO'] = i;
						<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
						dataArray.push(rtnList[i].QRY_MAP);
					}				
					grid.load(dataArray, null, null, [checkDataSer.toString()]);
				}			
		);
	};

	<%--修改作業--%>
	var doUpdate = function (){
			
		doTrimTextArea();
		
		if(!checkSelect()){
			return;
		}
		if(!validates.checkInput("update")){
			return;
		}
		var checkedRec = grid.getCheckedRecord();
		var jsonData = $("form1").serialize( true );
		jsonData.TEL = $('TEL').innerHTML;
		//alert("共勾選 " + Object.toJSON(checkedRec) + " 筆資料");
		checkDataSer = checkedRec[0].SER_NO;
		
		ajaxRequest.post('update', 
				{ 	'qryMap' : Object.toJSON(checkedRec[0]),
					'jsonData' : Object.toJSON( jsonData),
					'TEL_TYPE' : $F('TEL_TYPE'),
					'HOUR' : $F('HOUR'),
					'MIN' : $F('MIN')
				}, 
				function(resp) {
					rtnList = resp.returnList;
					var dataArray = [];
					for(var i=0; i<rtnList.length; i++){
						rtnList[i].QRY_MAP['SER_NO'] = i;
						<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
						dataArray.push(rtnList[i].QRY_MAP);
					}			
					//修改玩僅更新明細資料，不更新table UI
					layout.createDetail(rtnList[checkDataSer]);
				}
		);
	};

	<%--刪除作業--%>
	var doDelete = function (){

		//alert("共勾選 " + Object.toJSON(checkedRec) + " 筆資料");
		
		if(checkSelect() && confirm('確定刪除?')){ 
			var checkedRec = grid.getCheckedRecord();
			checkDataSer = checkedRec[0].SER_NO;
			ajaxRequest.post('delete', 
					{ 	'qryMap' : Object.toJSON(checkedRec[0]),
						'jsonData' : Object.toJSON( $("form1").serialize( true ))
					}, 
					function(resp) {
						rtnList = resp.returnList;
						var dataArray = [];
						for(var i=0; i<rtnList.length; i++){
							rtnList[i].QRY_MAP['SER_NO'] = i;
							<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
							dataArray.push(rtnList[i].QRY_MAP);
						}				
						grid.load(dataArray, null, null, [checkDataSer.toString()]);
					}
			);
		}
	};

	var doPopup = function (){
	  	if(!checkPopup()){
			return;
		}
		var indexUrl="<%=request.getContextPath()%>/servlet/HttpDispatcher/DSA2_0410/prompt?APPLY_ID=" + applyId + '&LINK_FROM=DSA20600';
			popupWin.popup( indexUrl );    

	};

	//檢核新增、刪除、修改前必須選一筆資料
	var checkSelect  = function (){
		if(!grid.getCheckedRecord().length){
			alert('請點選一筆資料');		
			return false;
		} 	
		return true;				
	};

	var checkPopup  = function (){
		if(!grid.getCheckedRecord().length){
			alert('請先以受理編號查詢');		
			return false;
		} else if(LOG_CNT ==='undefined' || LOG_CNT == 0){
			alert('無法開啟聯徵記錄畫面:無聯徵檔記錄');		
			return false;
		}
		return true;				
	};
	

	//連動照會電話
	function getTEL(){
		if($F('TEL_TYPE') && $('OLD_APPLY_ID').innerHTML){
			ajaxRequest.post('getTEL', 
				{ 	'APPLY_ID' : $('OLD_APPLY_ID').innerHTML,
					'TEL_TYPE' : $F('TEL_TYPE'),
					'ID' : $F('SHOW_ID'),
					'TYPE' : $F('TYPE')
				}, 
				function(resp) {
					$('TEL').update( resp.TEL || '');
				}			
			);	
		}else{
			$('TEL').update('');
		}
	  
	}

	//--------------------------------------------------------------------------
	// 註冊事件
	//--------------------------------------------------------------------------
	var register = {
		// 欄位去空白
		textNoSpace:function (keys, type){	
			$w(keys).each(function(key){
				$(key).observe('blur', function(event){
					formatInput.text(key);
					
					if($(key).value){
						if(type == "upper"){//轉大寫
							$(key).value = $(key).value.toUpperCase();
						}else if(type == "lower"){//轉小寫
							$(key).value = $(key).value.toLowerCase();
						}
					}
				});
			});
		}
	};

	//--------------------------------------------------------------------------
	// 格式化
	//--------------------------------------------------------------------------
	var formatInput = {
		// 一般輸入
		text : function(key_Value, isKey, defaultVaule){
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
			
			// 設定或回傳value
			if(isKey){
				$(key_Value).value = value.trim();
			}else{
				return value.trim();
			}
		}
	};
	
	var validates = {
		init : function(){
			Validation.addAllThese([
				[ 'required4RadioCheckbox', '請選擇', function(v,elm) {
					return validates.chkRequired4RadioCheckbox(elm.name);
				}]
			]);

			valid1 = new Validation('form1', {focusOnError:true, immediate:false,mode:"validator"});
			
		},
		//檢核checkbox或radio是否有選取(by element name)
		chkRequired4RadioCheckbox:function(eleName){
			var isCheck = false;
			$$('input[name='+eleName+']').each(
				function(obj){
					if(obj.checked){
						isCheck = true;
					} 
				}
			);
			return isCheck;
		},
		// 畫面欄位
		checkInput:function(type){
			valid1.clear();
			valid1.reset();

			if(type == "query"){
				valid1.define('required' , [{ id : "APPLY_ID" , errMsg:"您必須填入受理編號的資料!!"}] );
			}else if(type == "insert" || type == "update"){
				valid1.define('required4RadioCheckbox' , [{ id : "QUERYSTEP9_CHECK_QUERY_STATUS_N" , errMsg:"請選擇票交所查詢記錄!!"}] );
				if ($('QUERYSTEP9_CHECK_QUERY_STATUS_Y').checked){
					valid1.define('required4RadioCheckbox' , [{ id : "QUERYSTEP9_CHECK_STATUS_Y" , errMsg:"請選擇票交所查詢記錄!!"}] );
					if($('QUERYSTEP9_CHECK_STATUS_N').checked){
						valid1.define('required' , [{ id : "QUERYSTEP9_CHECK_STATUS_DESC" , errMsg:"請輸入票交所查詢說明!!"}] );	
					}
				}
				
				valid1.define('required4RadioCheckbox' , [{ id : "CHECK_JUDICIAL_Y" , errMsg:"請選擇是否關係人監護!!"}] );
				if ($('CHECK_JUDICIAL_Y').checked){
					valid1.define('required' , [{ id : "JUDICIAL_DESC" , errMsg:"請輸入輔助宣告事由!!"}] );
				}
				
				if ($('IS_TEL_N').checked){
					valid1.define('required' , [{ id : "IS_TEL_DESC" , errMsg:"請輸入照會狀況說明!!"}] );
				}
				
				/*改用inputUtility.lengthLimit
				if ($('CRED_DESC').value.length > 2000 ){
					var CRED_DESC_LENGTH = $('CRED_DESC').value.length;
					validator.define("CRED_DESC", "", "信用狀況說明資料長度" + CRED_DESC_LENGTH + "超過限制(2000個, 中文字長度算2),請簡述之", validates.returnFalse);
				}*/
				
				//[20200420]新增檢核
				if($('IS_TEL_Y').checked){
					valid1.define('required' , [{ id : "TEL_TYPE" , errMsg:"請輸入電話種類!!"}] );
					valid1.define('required' , [{ id : "TEL_DATE" , errMsg:"請輸入照會日期!!"}] );
					valid1.define('required' , [{ id : "HOUR" , errMsg:"請輸入照會時間(時)!!"}] );
					valid1.define('required' , [{ id : "MIN" , errMsg:"請輸入照會時間(分)!!"}] );
				}
				if($('CONFIRM_BEF_LOAN_0').checked){
					valid1.define('required' , [{ id : "CONFIRM_BEF_LOAN_DESC" , errMsg:"請說明「申貸前是否已知悉權益事項」照會內容!!"}] );
				}
				if($('SUS_INDUCE_BUY_INSU_1').checked){
					valid1.define('required' , [{ id : "SUS_INDUCE_BUY_INSU_DESC" , errMsg:"請說明「疑似勸誘購買新契約」照會內容!!"}] );
				}
			}
			
			return valid1.validate();
		}
	};
	
	//-------------------------------------------------------------------------- 
	return{
		initApp:function(){
			<cathay:LocaleDisplay dateFields="TEL_DATE" sysCode= 'DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement( "DSA20600" , "核貸作業" ,"徵信報告書 " , 3, '${titleNotDisplay}'=='Y');
			
			buttonAuth();
			validates.init();
			
			ld = window.localeDisplay;

			register.textNoSpace('APPLY_ID', "upper");
			
			grid = new TableUI( 
				{
					table: $("grid"),  
					overDiv:false,
					afterLoad:function(tableElement){
						var inputs = $('grid').select("input[type='radio']");
						var length = inputs.length;
						if(length > 0){							
							layout.createDetail(rtnList[checkDataSer]);								
						}
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20240729] 難字調整 --%>
					},
					<%-- [20240729] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					autoCheckBox:{type:'radio', text:'選取',
						valueKey:'SER_NO',
						action:function(checkbox, boxStatus, records){
							if(!boxStatus){ return; }
							layout.createDetail(rtnList[records[0].SER_NO]);
							<%--難字調整--%>
							parseEUDC("ap");
						}
					},
					column:[
							{header: '身分別',sortable: true, key:'TYPE_NM',
								render:function(rec,val){
									return val ? val : "";
								}
							},
					
							{header: '姓名',sortable: true, key:'NAME', attrs:{style:"font-family:'EUDC'"},<%--[20240729] 難字調整 --%>
								render:function(rec,val){
									return val ? val : "";
								}
							},
							{header: '是否送出',sortable: true, key:'IS_SENT_NM',
								render:function(rec,val){
									return val ? val : "";
								}
							},
							{header: '查詢訊息',sortable: true, key:'QRY_MESSAGE', attrs:{style:"font-family:'EUDC'"},<%--[20240729] 難字調整 --%>
								render:function(rec,val){
									return val ? val : "";
								}
							}
					]
				}
			);

			//查詢 button click event   
			$('btn_query').observe('click',query);
			
			//新增 button click event                        
			$('btn_insert').observe('click',doInsert);
			
			//修改 button click event
			$('btn_modify').observe('click',doUpdate);
			
			//刪除 button click event
			$('btn_delete').observe('click',doDelete);
			
			//聯徵記錄 button click event
			$('btn_popup').observe('click',doPopup);
			
			//電話種類連動電話號碼
			$('TEL_TYPE').observe('change',getTEL);

			//宣告連動：票交所查詢記錄-有查詢
			$("QUERYSTEP9_CHECK_QUERY_STATUS_Y").observe('click', function(event){
				if(this.checked){
					$("QUERYSTEP9_CHECK_QUERY_STATUS_N").disable();
					$("QUERYSTEP9_CHECK_STATUS_Y").enable();
					$("QUERYSTEP9_CHECK_STATUS_N").enable();
				} else {
					$("QUERYSTEP9_CHECK_QUERY_STATUS_N").enable();
					$("QUERYSTEP9_CHECK_STATUS_Y").disable();
					$("QUERYSTEP9_CHECK_STATUS_N").disable();
					$('QUERYSTEP9_CHECK_STATUS_Y').checked = false;
					$('QUERYSTEP9_CHECK_STATUS_N').checked = false;
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}
			});	
			
			//宣告連動：票交所查詢記錄-無查詢
			$("QUERYSTEP9_CHECK_QUERY_STATUS_N").observe('click', function(event){
				if(this.checked){
					$("QUERYSTEP9_CHECK_QUERY_STATUS_Y").disable();
					$('QUERYSTEP9_CHECK_STATUS_Y').checked = false;
					$('QUERYSTEP9_CHECK_STATUS_N').checked = false;
					$('QUERYSTEP9_CHECK_STATUS_Y').disable();//正常
					$('QUERYSTEP9_CHECK_STATUS_N').disable();//異常
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				} else {
					$("QUERYSTEP9_CHECK_QUERY_STATUS_Y").enable();
					$('QUERYSTEP9_CHECK_STATUS_Y').enable();//正常
					$('QUERYSTEP9_CHECK_STATUS_N').enable();//異常
				}
			});
			//宣告連動：票交所查詢記錄-異常 (點選後"異常"字變紅色粗體)
			$('QUERYSTEP9_CHECK_STATUS_N').observe('click',function(event){
				if(this.checked){
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
				}else{
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}
			});
			//宣告連動：票交所查詢記錄-正常 (點選後"異常"字變紅色粗體)
			$('QUERYSTEP9_CHECK_STATUS_Y').observe('click',function(event){
				if(this.checked){
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'black', 'fontWeight': 'normal'});
				}else{
					$('QUERYSTEP9_CHECK_STATUS_N_S').setStyle({'color': 'red', 'fontWeight': 'bold'});
				}
			});

			InputUtility.lengthLimit.add("CRED_DESC", 2000, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
			
			<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
			//InputUtility.lengthLimit.add("QUERYSTEP9_POLLUTION_DESC", 100, true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
			
			//初始set APPLY_ID，並查詢
			if ('${LINK_FROM}' && '${APPLY_ID}' != "") {
				$('APPLY_ID').setValue('${APPLY_ID}');
			} else { 
				//保留參數管理-取得受理編號
				$('APPLY_ID').setValue(CSRUtil.keepParamsManager.get('APPLY_ID'));
			}			
			if($F('APPLY_ID')){
				query();
			}
			
			//[20200424]隱藏保證人文字
			$('TD_AGENT_INSU_LOAN_1').style.display = 'none';
			$('TD_CONFIRM_BEF_LOAN_1').style.display = 'none';
			$('TD_SUS_INDUCE_BUY_INSU_1').style.display = 'none';
			
			PageUI.resize();
			displayMessage();
		}//end init()--
		
	};//end return--
}

</script>
</head>
<body>
<form name="form1" id="form1" method="post">
	<table id="queryArea" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<tr>
			<td width="15%" class="tbYellow">受理編號</td>
			<td class="tbYellow2" width="85%">
	            <input type="text" class="textBox" id="APPLY_ID" name="APPLY_ID" size="15" maxLength="11" value="">
				<input type="button" name="btn_query" id="btn_query" class="button" value="查詢"> 
			</td>	
		</tr>
		<tr>
			<td colspan="2" class="tbYellow2"  align="center">
				<input type="button" name="btn_insert" id="btn_insert" class="button" value="新增"/>
				<input type="button" name="btn_modify" id="btn_modify" class="button" value="修改"/>
				<input type="button" name="btn_delete" id="btn_delete" class="button" value="刪除"/>
				<input type="button" name="btn_popup" id="btn_popup" class="button" value="聯徵記錄"/>
			</td>
		</tr>
	</table>
	<table id='grid' class="grid"></table>	
	<table id='detailTable' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >						
		<tr>
			<td colspan="7" align="center" class="tbYellow0"><font color="red" >＊＊資料日期為核准日期前最後一次聯徵查詢記錄＊＊</font></td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2" width="25%"><strong>受理編號</strong></td>
			<td colspan="5" class="tbYellow2"><span ID="OLD_APPLY_ID"></span><input type="hidden" id="NEW_APPLY_ID" name="NEW_APPLY_ID"/></td>
			
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>被查詢人姓名</strong></td>
			<td colspan="5" class="tbYellow2"><span ID="SHOW_NAME" style="font-family:'EUDC'"/></span><%--[20240729]難字調整 --%>
			<input type="hidden" id="SHOW_ID" name="SHOW_ID"/><input type="hidden" id="TYPE" name="TYPE"/></td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>通報及補充註記</strong></td>
			<td colspan="2" class="tbYellow2">
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				<div id="STEP1MAP_VM107_DIV"> 1.銀行公會消債協商註記：
					<input type="checkbox" name="STEP1MAP_VM107" id="STEP1MAP_VM107_Y" value="" onclick="return false"/><font id="STEP1MAP_VM107_Y_S">有</font>
					<input type="checkbox" name="STEP1MAP_VM107" id="STEP1MAP_VM107_N" value="" onclick="return false"/>無<br>
				</div>
				<div id="STEP1MAP_VM106_DIV">2.消債條例信用註記：
					<input type="checkbox" name="STEP1MAP_VM106" id="STEP1MAP_VM106_Y" value="" onclick="return false"/><font id="STEP1MAP_VM106_Y_S">有</font>
					<input type="checkbox" name="STEP1MAP_VM106" id="STEP1MAP_VM106_N" value="" onclick="return false"/>無<br>
				</div>
				1.其他補充註記：
				<input type="checkbox" name="STEP1MAP_VM108" id="STEP1MAP_VM108_Y" value="" onclick="return false"/><font id="STEP1MAP_VM108_Y_S">有</font>
				<input type="checkbox" name="STEP1MAP_VM108" id="STEP1MAP_VM108_N" value="" onclick="return false"/>無<br>
				2.通報案件記錄：
				<input type="checkbox" name="STEP1MAP_VAM2" id="STEP1MAP_VAM2_Y" value="" onclick="return false"/><font id="STEP1MAP_VAM2_Y_S">有</font>
				<input type="checkbox" name="STEP1MAP_VAM2" id="STEP1MAP_VAM2_N" value="" onclick="return false"/>無
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>授信異常記錄</strong></td>
			<td colspan="2" class="tbYellow2">
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書 --%>
				<%--start --%>
				<div id="BAS001_Map_BAS002_DIV">有無逾催或呆帳：
					<input type="checkbox" name="BAS001_Map_BAS002" id="BAS001_Map_BAS002_Y" value="" onclick="return false"/>有</font>
					<input type="checkbox" name="BAS001_Map_BAS002" id="BAS001_Map_BAS002_N" value="" onclick="return false"/>無</font><br>
				</div>
				<div id="BAS001_Map_BAS6_DIV">相關人員是否AMC報送資訊：
					<input type="checkbox" name="BAS001_Map_BAS6" id="BAS001_Map_BAS6_Y" value="" onclick="return false"/>有</font>
					<input type="checkbox" name="BAS001_Map_BAS6" id="BAS001_Map_BAS6_N" value="" onclick="return false"/>無</font><br>
				</div>
				<%--end --%>
				<input type="checkbox" id="EVER_DELINQUENT_N" name="EVER_DELINQUENT" value="" onclick="return false"/>正常
				<input type="checkbox" id="EVER_DELINQUENT_Y" name="EVER_DELINQUENT" value="" onclick="return false"/><font id="EVER_DELINQUENT_Y_S">授信異常<SPAN ID="DELINE_NM"></SPAN></font>&emsp;
				<font color="blue">備註</font>
				<input type="text" name="QUERYSTEP9_MSG" id="QUERYSTEP9_MSG"  class="textBox2" size="59" maxlength="100" value="" />
			</td>
		</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="2"><strong>票據查詢記錄</strong></td>
					<td colspan="2" class="tbYellow2">
						<font id="LOG_FONT">
							1.聯徵記錄：<br>
							&emsp;&emsp;(1).拒往記錄：<SPAN ID="NO_DAS002"></SPAN><br>
							&emsp;&emsp;&emsp;&nbsp;拒絕往來記錄：<SPAN ID="REJECT_YN"></SPAN><br>
							&emsp;&emsp;(2).退票摘要記錄：<SPAN ID="NO_DAS006"></SPAN>
							<SPAN ID="CUR_CODE"></SPAN>
							<SPAN ID="HEADERA"></SPAN>
							<SPAN ID="HEADERB"></SPAN>
							<SPAN ID="HEADERC"></SPAN>
							<SPAN ID="HEADERD"></SPAN>
							<SPAN ID="HEADERE"></SPAN>
							<SPAN ID="HEADERF"></SPAN>
						</font>
						
						<br>2.票交所查詢記錄：<br>
						&emsp;<input type="checkbox" name="QUERYSTEP9_CHECK_QUERY_STATUS" id="QUERYSTEP9_CHECK_QUERY_STATUS_Y" value="1">有查詢：
						<input type="radio" name="QUERYSTEP9_CHECK_STATUS" id="QUERYSTEP9_CHECK_STATUS_Y" value="1">正常
						<input type="radio" name="QUERYSTEP9_CHECK_STATUS" id="QUERYSTEP9_CHECK_STATUS_N" value="0"><font id="QUERYSTEP9_CHECK_STATUS_N_S">異常</font>
						，說明：<input type="text" name="QUERYSTEP9_CHECK_STATUS_DESC" id="QUERYSTEP9_CHECK_STATUS_DESC" class="textBox2" size="53" maxlength="200" value="" ><br>
						&emsp;<input type="checkbox" name="QUERYSTEP9_CHECK_QUERY_STATUS" id="QUERYSTEP9_CHECK_QUERY_STATUS_N" value="0">
						<input type="hidden" id="CHECK_QUERY_STATUS" name="CHECK_QUERY_STATUS"/>無查詢
					</td>
				</tr>
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				<tr id="CHECK_JUDICIAL_TR">
					<td class="tbYellow" align="center" colspan="2"><strong>監護/輔助宣告查證</strong></td>
					<td colspan="2" class="tbYellow2">
						1.本案關係人
						<input type="radio" name="CHECK_JUDICIAL" id="CHECK_JUDICIAL_Y" value="1">是
						<input type="radio" name="CHECK_JUDICIAL" id="CHECK_JUDICIAL_N" value="0">否
						&emsp;監護/輔助宣告事由(勾選是，須於說明欄說明原因)(
						<a href="http://jirs.judicial.gov.tw/GNNWS/NNWSS001.asp?classFlag=z&Search=y" target="_blank">連結到司法院</a>)<br>
						說明：<input type="text" name="JUDICIAL_DESC" id="JUDICIAL_DESC" class="textBox2" size="53" maxlength="200" value="">
					</td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="2"><strong>金融機構授信總餘額</strong></td>
					<td colspan="2" class="tbYellow2" id="LOAN_KND_List">
						1.授信資料日期：<SPAN style="color:blue" ID="BAM087DATE"/></SPAN><br>
						<table width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
							<tbody>
								<tr>
									<td class="tbYellow2" align="center" colspan="1"></td>
									<td class="tbYellow2" align="center" colspan="1">擔保</td>
									<td class="tbYellow2" align="center" colspan="1">無擔保</td>
									<td class="tbYellow2" align="center" colspan="1">共同債務</td>
									<td class="tbYellow2" align="center" colspan="1">從債務</td>
									<td class="tbYellow2" align="center" colspan="1">債權轉讓註記</td>
									<td class="tbYellow2" align="center" colspan="1">催收款項呆帳</td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="1">正常</td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMTA"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMTB"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMT302"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMT303"/></td>
									<td class="tbYellow2" align="center" colspan="1" rowspan="3"><SPAN ID="STEP5MAP_COUNT608_NM"/></td>
									<td class="tbYellow2" align="center" colspan="1" rowspan="3"><SPAN ID="STEP5MAP_ACCOUNT_CODE087"/></td>
								</tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="1">逾期</td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMTA"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMTB"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMT302"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMT303"/></td></tr>
								<tr>
									<td class="tbYellow2" align="center" colspan="1">最近一年繳款記錄</td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN ID="STEP5MAP_PAY_CODE12A_NM"/></td>
									<td class="tbYellow2" align="center" colspan="1"><SPAN ID="STEP5MAP_PAY_CODE12B_NM"/></td>
									<td class="tbYellow2" align="center" colspan="1">－</td>
									<td class="tbYellow2" align="center" colspan="1">－</td></tr>
							</tbody>
						</table>
						2.新增授信及清償：(授信資料日期後，有新報送之授信及清償金額)<br>
						&emsp;(1).新增授信金額：<SPAN ID="STEP5MAP_NEW_LOAN_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元<br>
						&emsp;(2).新增清償金額：<SPAN ID="STEP5MAP_NEW_PAY_LOAN_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元
			</td>
		</tr>
		<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
		<tr id="CASHCARDMAP_CASH_CARD_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>現金卡記錄</strong></td>
			<td colspan="2" class="tbYellow2">
				張數：<SPAN ID="CASHCARDMAP_CASH_CARD_CNT" style='text-decoration:underline;color:blue'></SPAN>張；可動用額度<SPAN ID="CASHCARDMAP_CONTRACT_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元，已動用額度<SPAN ID="CASHCARDMAP_TOTAL_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元<br>
				是否逾期：
				<input type="checkbox" name="CASHCARDMAP_PASS_DUE_AMT" id="CASHCARDMAP_PASS_DUE_AMT_Y" value="" onclick="return false"/>正常
				<input type="checkbox" name="CASHCARDMAP_PASS_DUE_AMT" id="CASHCARDMAP_PASS_DUE_AMT_N" value="" onclick="return false"/><font id="CASHCARDMAP_PASS_DUE_AMT_N_S">有逾期</font><br>
				繳款狀況：
				<input type="checkbox" name="CASHCARDMAP_PAY_CODE_068_CNT" id="CASHCARDMAP_PAY_CODE_068_CNT_Y" value="" onclick="return false"/>正常
				<input type="checkbox" name="CASHCARDMAP_PAY_CODE_068_CNT" id="CASHCARDMAP_PAY_CODE_068_CNT_N" value="" onclick="return false"/><font id="CASHCARDMAP_PAY_CODE_068_CNT_N_S">有延遲</font>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>信用卡記錄</strong></td>
			<td colspan="2" class="tbYellow2">
				有效卡數<SPAN ID="QUERYSTEP6_LIVE_CNT" style="text-decoration:underline;color:blue"></SPAN>張，
				強停：
				<input type="checkbox" name="QUERYSTEP6_DEAD_CNT" id="QUERYSTEP6_DEAD_CNT_0" value="" onclick="return false"/>無
				<input type="checkbox" name="QUERYSTEP6_DEAD_CNT" id="QUERYSTEP6_DEAD_CNT_1" value="" onclick="return false"/><font id="QUERYSTEP6_DEAD_CNT_1_S">有</font><SPAN ID="QUERYSTEP6_AB_CODE_NM"></SPAN></SPAN><br>
				<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書--%>
				<div id = "QUERYSTEP6_PAY_DIV">【使用情形】：
					<input type="checkbox" name="QUERYSTEP6_PAY_CODE" id="QUERYSTEP6_PAY_CODE1" value="" onclick="return false"/>過去一年內，有兩次以上超過30天的遲繳記錄<br>
	　　　　　　　		<input type="checkbox" name="QUERYSTEP6_PAY_CODE" id="QUERYSTEP6_PAY_CODE2" value="" onclick="return false"/>過去一年內，有一次以上超過60天的遲繳記錄<br>
					&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;<input type="checkbox" name="QUERYSTEP6_PAY_CODE" id="QUERYSTEP6_PAY_CODE3" value="" onclick="return false"/>近六個月內循環有2個月使用率<span style='font-size: 12.0pt; mso-bidi-font-size: 11.0pt; font-family: "新細明體", "serif"; mso-ascii-theme-font: minor-fareast; mso-fareast-theme-font: minor-fareast; mso-hansi-theme-font: minor-fareast; mso-bidi-font-family: "Times New Roman"; mso-bidi-theme-font: minor-bidi; mso-ansi-language: EN-US; mso-fareast-language: ZH-TW; mso-bidi-language: AR-SA'></span>≧50%<br>
					&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;<input type="checkbox" name="QUERYSTEP6_PAY_CODE" id="QUERYSTEP6_PAY_CODE4" value="" onclick="return false"/>近六個月內有任2個月使用信用卡預借現金<br>
					【預借現金】：
					<input type="checkbox" name="QUERYSTEP6_CASH_YN" id="QUERYSTEP6_CASH_YN_0" value="" onclick="return false"/>無
					<input type="checkbox" name="QUERYSTEP6_CASH_YN" id="QUERYSTEP6_CASH_YN_1" value="" onclick="return false"/>有&emsp;近<SPAN ID="QUERYSTEP6_CASHLENT_STR" style='text-decoration:underline;color:blue'></SPAN>年共<SPAN ID="QUERYSTEP6_CASHLENT_INT" style='text-decoration:underline;color:blue'></SPAN>期有預借現金，最高金額<SPAN ID="QUERYSTEP6_SUM_CASHLENT_INT" style='text-decoration:underline;color:blue'></SPAN>元<br>
					【繳款狀況】：
					<input type="checkbox" name="QUERYSTEP6_PAY_CODE034_CNT_YN" id="QUERYSTEP6_PAY_CODE034_CNT_YN" value="" onclick="return false"/><font id="QUERYSTEP6_PAY_CODE034_CNT_YN_S">有遲延繳款記錄，共<SPAN ID="QUERYSTEP6_PAY_CODE034_CNT" style='text-decoration:underline;color:blue'></SPAN>期(以月統計)</font><br>
					【債權狀態】：
					<input type="checkbox" name="QUERYSTEP6_DEBT_CODE" id="QUERYSTEP6_DEBT_CODE" value="" onclick="return false"/><font id="QUERYSTEP6_DEBT_CODE_S">異常</font><br>
					<b>【說明：信用卡繳款使用狀況為近一年資訊】</b>
				</div>
			</td>
	 	</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>近三個月被查詢次數</strong></td>
			<td colspan="2" class="tbYellow2">
				新業務<SPAN ID="QRY_CNT_MAP_CNT1" style='text-decoration:underline;color:blue'></SPAN>家，
				原業務<SPAN ID="QRY_CNT_MAP_CNT2" style='text-decoration:underline;color:blue'></SPAN>家
			</td>
		</tr>
		
		<%-- [20210728] 新增所得清單資料區塊 --%>
		<tr id="STEP15MAP_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>所得清單資料</strong></td>
			<td colspan="2" class="tbYellow2">
				查調年度：<SPAN style="color:blue" ID="INQ_YR"></SPAN><br>
				<table width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
					<tbody>
						<tr>
							<td class="tbYellow2" align="center">所得代碼</td>
							<td class="tbYellow2" align="center">所得類別</td>
							<td class="tbYellow2" align="center">所得額</td>
							<td class="tbYellow2" align="center">資料筆數</td>
							<td class="tbYellow2" align="center">主要所得單位</td>
							<td class="tbYellow2" align="center">主要單位所得</td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">1</td>
							<td class="tbYellow2" align="center">營利所得</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_01"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_01"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_01"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_01"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">2</td>
							<td class="tbYellow2" align="center">執行業務所得</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_02"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_02"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_02"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_02"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">3</td>
							<td class="tbYellow2" align="center">薪資所得</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_03"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_03"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_03"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_03"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">4</td>
							<td class="tbYellow2" align="center">利息所得</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_04"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_04"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_04"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_04"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">5</td>
							<td class="tbYellow2" align="center">租賃所得及權利金所得</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_05"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_05"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_05"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_05"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center"></td>
							<td class="tbYellow2" align="center">其他所得類別</td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_OTHER"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_OTHER"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="WH_UNIT_NM_MAX_OTHER"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_MAX_OTHER"></span></td>
						</tr>
						<tr>
							<td class="tbYellow2" align="center">合計</td>
							<td class="tbYellow2" align="center"></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="PAYMENT_T_AMT_SUM"></span></td>
							<td class="tbYellow2" align="center"><span style="color:blue" id="INCM_TP_SUM"></span></td>
							<td class="tbYellow2" align="center"></td>
							<td class="tbYellow2" align="center"></td>
						</tr>
					</tbody>
				</table>
				<b>【說明】</b><br>
				1.其他所得類別包含6自力耕作、漁、牧、林、礦之所得、7財產交易所得、8競技、競賽及機會中獎之獎金或給與、9退職所得、A其他所得或不分類之所得。<br>
				2.主要所得單位及其所得額，以同一所得類別中，所得額最高之單位資料顯示。<br>
				3.財稅資料係為課稅目的蒐集，僅供金融徵信案件之參考，若有資料內容疑問時，應向資料主管機關洽詢。
			</td>
		</tr>
		
		<%--[20200727][200721001725]申請書200713000929 法金_優化徵信報告書 --%>
		<%--start--%>
		<tr id="STEP14MAP_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>擔任事業體負責人或經理人</strong></td>
			<td colspan="2" class="tbYellow2">
				1.任職公司董監事/經理人：
				<input type="checkbox" name="STEP14MAP_NO_ACM009" id="STEP14MAP_NO_ACM009_Y" value="" onclick="return false"/>有
				<input type="checkbox" name="STEP14MAP_NO_ACM009" id="STEP14MAP_NO_ACM009_N" value="" onclick="return false"/>無&emsp;任職公司共<SPAN ID="STEP14MAP_ACM009_CNT" style='text-decoration:underline;color:blue'></SPAN>家<br>
				2.任職獨資合夥事業負責人/經理人：
				<input type="checkbox" name="STEP14MAP_NO_ACM022" id="STEP14MAP_NO_ACM022_Y" value="" onclick="return false"/>有
				<input type="checkbox" name="STEP14MAP_NO_ACM022" id="STEP14MAP_NO_ACM022_N" value="" onclick="return false"/>無&emsp;任職公司共<SPAN ID="STEP14MAP_ACM022_CNT" style='text-decoration:underline;color:blue'></SPAN>家<br>
				3.任職有限合夥事業合夥人/經理人：
				<input type="checkbox" name="STEP14MAP_NO_ACM025" id="STEP14MAP_NO_ACM025_Y" value="" onclick="return false"/>有
				<input type="checkbox" name="STEP14MAP_NO_ACM025" id="STEP14MAP_NO_ACM025_N" value="" onclick="return false"/>無&emsp;任職公司共<SPAN ID="STEP14MAP_ACM025_CNT" style='text-decoration:underline;color:blue'></SPAN>家
			</td>
		</tr>
		<tr id="STEP10MAP_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>勞工退休準備金</strong></td>
			<td colspan="2" class="tbYellow2">
				1.積欠工資墊償基金提撥情形：<SPAN ID="STEP10MAP_ARREARS_INFO" style="color:blue"></SPAN><br>
				&emsp;欠繳月數：<SPAN ID="STEP10MAP_ARREARS_MONTHS" style="text-decoration:underline;color:blue"></SPAN>個月<br>
				2.勞工退休準備金專戶現況：<br>
				&emsp;基金戶現況：<SPAN ID="STEP10MAP_RAM006_STATUS" style="color:blue"></SPAN><br>
				3.勞工退休準備金專戶餘額≧預估舊制退休金+預估舊制資遣費：<SPAN ID="STEP10MAP_NO_RAM005" style="color:blue"></SPAN><br>
				&emsp;<input type="checkbox" name="STEP10MAP_BALANCE_IS_OVER" id="STEP10MAP_BALANCE_IS_OVER_Y" value="" onclick="return false"/>是</font>
				<input type="checkbox" name="STEP10MAP_BALANCE_IS_OVER" id="STEP10MAP_BALANCE_IS_OVER_N" value="" onclick="return false"/>否</font><br>
				&emsp;專戶餘額<SPAN ID="STEP10MAP_BALANCE" style="text-decoration:underline;color:blue"></SPAN>元
				&emsp;預估舊制退休金+預估舊制資遣費=<SPAN ID="STEP10MAP_RETIRE_SERVERANCE_AMT" style="text-decoration:underline;color:blue"></SPAN>元
			</td>
		</tr>
		<tr id="STEP11MAP_RAI002_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>融資租賃交易資訊</strong></td>
			<td colspan="2" class="tbYellow2">
				1.融資租賃資料日期：<SPAN ID="STEP11MAP_RAI002_DATA_YYYMM" style="color:blue"></SPAN><br>
				2.是否有融資租賃交易資訊：
				<input type="checkbox" name="STEP11MAP_RAM00" id="STEP11MAP_RAM00_Y" value="" onclick="return false"/>有</font>
				<input type="checkbox" name="STEP11MAP_RAM00" id="STEP11MAP_RAM00_N" value="" onclick="return false"/>無</font><br>
				3.是否有延遲租金： 
				<input type="checkbox" name="STEP11MAP_DELAY_AMT_0" id="STEP11MAP_DELAY_AMT_0_Y" value="" onclick="return false"/>有</font>
				<input type="checkbox" name="STEP11MAP_DELAY_AMT_0" id="STEP11MAP_DELAY_AMT_0_N" value="" onclick="return false"/>無</font>
			</td>
		</tr>
		<tr id="STEP12MAP_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>企業信用評分資訊</strong></td>
			<td colspan="2" class="tbYellow2">
				1.企業信用評分：<SPAN ID="STEP12MAP_SCORE_STAT" style="text-decoration:underline;color:blue"></SPAN><br>
				2.借款人位於所有受評者之百分位點：<SPAN ID="STEP12MAP_PCT_LO" style="text-decoration:underline;color:blue"></SPAN>%-<SPAN ID="STEP12MAP_PCT_HI" style="text-decoration:underline;color:blue"></SPAN>%<br>
				3.所屬受評行業別：<SPAN ID="STEP12MAP_IND_EXPR" style="color:blue"></SPAN><br>
				4.借款人於所有同業受評者之百分點位：<SPAN ID="STEP12MAP_IND_PCT_LO" style="text-decoration:underline;color:blue"></SPAN>%-<SPAN ID="STEP12MAP_IND_PCT_HI" style="text-decoration:underline;color:blue"></SPAN>%<br>
				5.財報使用之最近年度：<SPAN ID="STEP12MAP_FA_YYYY" style="color:blue"></SPAN><br>
				6.無法評分理由：<SPAN ID="STEP12MAP_REASON_EXPR" style="color:blue"></SPAN>
			</td>
		</tr>
		<%--//20200827 俊成：與同業比較資訊在組合查詢內的查詢結果會有問題(需多丟查詢條件，改請單位另外用標準查詢F10查)，故先不加入徵信報告書
		<tr id="STEP13MAP_FAS503_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>與同業比較資訊(比例與結構)</strong></td>
			<td colspan="2" class="tbYellow2">
				1.查詢年度：<SPAN ID="STEP13MAP_FAS503_YYY" style="text-decoration:underline;color:blue"></SPAN>年<br>
				2.查詢財報類別：<SPAN ID="STEP13MAP_FR_TYPE_NM" style="color:blue"></SPAN><br>
				3.行業名稱：<SPAN ID="STEP13MAP_CFN_NAME" style="color:blue"></SPAN>
			</td>
		</tr>
		--%>
		<tr id="STEP13MAP_BA_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>關係人名單與借款資訊</strong></td>
			<td colspan="2" class="tbYellow2">
				1.授信資料年月：<SPAN ID="STEP13MAP_BA_YYYMM" style="color:blue"></SPAN><br>
				2.關係法人：<SPAN ID="STEP13MAP_REL_CNT" style="text-decoration:underline;color:blue"></SPAN>人&emsp;
				關係法人是否已借款：<input type="checkbox" name="STEP13MAP_LOAN_FACILITY" id="STEP13MAP_LOAN_FACILITY_Y" value="" onclick="return false"/>是</font>
				<input type="checkbox" name="STEP13MAP_LOAN_FACILITY" id="STEP13MAP_LOAN_FACILITY_N" value="" onclick="return false"/>否</font>
			</td>
		</tr>
		<%--//20200824 俊成：企業重大污染資訊會查的案件真的少，先不加入徵信報告書
		<tr id="STEP13MAP_POLLUTION_TR">
			<td class="tbYellow" align="center" colspan="2"><strong>企業重大污染資訊</strong></td>
			<td colspan="2" class="tbYellow2">
				1.重大汙染裁罰處分資訊：<SPAN ID="STEP13MAP_INFO" style="color:blue"></SPAN><br>
				2.最近一次受處分日期：<SPAN ID="STEP13MAP_JUDGEDATE" style="text-decoration:underline;color:blue"></SPAN><br>
				<div>3.其他說明：</div>
				<div>
					<textarea id="QUERYSTEP9_POLLUTION_DESC" name="QUERYSTEP9_POLLUTION_DESC" cols="75" class="textBox2" rows="8"></textarea>
				</div>
			</td>
		</tr>
		--%>
		<%--end--%>
		<tr>
			<td class="tbYellow" align="center" width="9%" rowspan="5"><strong>案件照會及</br>告知作業</strong></td>
			<td class="tbYellow" ><strong>客戶照會資料</strong></td>
			<td colspan="2" class="tbYellow2">
				<input type="radio" name="IS_TEL_YN" id="IS_TEL_Y" value="1">是
				<input type="radio" name="IS_TEL_YN" id="IS_TEL_N" value="0">否&emsp;
				<font color="blue">說明</font><input type="text" name="IS_TEL_DESC" id="IS_TEL_DESC" class="textBox2" size="53" maxlength="100" value="">
				<span id="HEALTHY_NM" style='color:red'></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" ><strong>客戶照會電話</strong></td>
			<td colspan="2" class="tbYellow2">
				<select class="textBox2" name="TEL_TYPE" id="TEL_TYPE" >
	                <option value="">請選擇</option>
	                <c:forEach var="map" items="${TEL_KIND_LIST}">
	                	<option value="${map.key}">${map.value}</option>
	                </c:forEach>
               	</select>
                <span id="TEL"></span>
                &emsp;照會日期<input id="TEL_DATE" name="TEL_DATE" type="text" class="textBox">
                &emsp;照會時間
                <select id="HOUR">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${HOUR_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>時
				<select id="MIN">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${MIN_List}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>分
			</td>
		</tr>
		<tr>
			<td class="tbYellow" ><strong>經手人同時推介保險與房貸</strong></td>
			<td colspan="2" class="tbYellow2">
				<div id="TD_AGENT_INSU_LOAN">
					<c:forEach var="map" items="${AGENT_INSU_LOAN_LIST}">
						<label class="box_label"><input type="radio" name="AGENT_INSU_LOAN" id="AGENT_INSU_LOAN_${map.key}" value="${map.key}">${map.value }</label>
					</c:forEach>
				</div>
				<div id="TD_AGENT_INSU_LOAN_1">
					<font color="red">保證人不需照會此項目</font>
				</div>
			</td>				
		</tr>
		<tr>
			<td class="tbYellow" ><strong>申貸前是否已知悉權益事項</strong></td>
			<td colspan="2" class="tbYellow2">
			<div id="TD_CONFIRM_BEF_LOAN">
				<c:forEach var="map" items="${CONFIRM_BEF_LOAN_LIST}">
					<label class="box_label"><input type="radio" name="CONFIRM_BEF_LOAN" id="CONFIRM_BEF_LOAN_${map.key}" value="${map.key}">${map.value }</label>
				</c:forEach>
				&emsp;<font color="blue">說明</font><input type="text" name="CONFIRM_BEF_LOAN_DESC" id="CONFIRM_BEF_LOAN_DESC" class="textBox2" size="53" maxlength="100" value="">
			</div>
			<div id="TD_CONFIRM_BEF_LOAN_1">
				<font color="red">保證人不需照會此項目</font>
			</div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" ><strong>疑似勸誘購買新契約</strong></td>
			<td colspan="2" class="tbYellow2">
			<div id="TD_SUS_INDUCE_BUY_INSU">
				<c:forEach var="map" items="${SUS_INDUCE_BUY_INSU_LIST}">
					<label class="box_label"><input type="radio" name="SUS_INDUCE_BUY_INSU" id="SUS_INDUCE_BUY_INSU_${map.key}" value="${map.key}">${map.value }</label>
				</c:forEach>
				&emsp;<font color="blue">說明</font><input type="text" name="SUS_INDUCE_BUY_INSU_DESC" id="SUS_INDUCE_BUY_INSU_DESC" class="textBox2" size="53" maxlength="100" value=""> 
			</div>
			<div id="TD_SUS_INDUCE_BUY_INSU_1">
				<font color="red">保證人不需照會此項目</font>
			</div>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>貸款來源</strong></td>
			<td colspan="2" class="tbYellow2">
				<span id="CASE_ORIGIN_NM"></span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="center" colspan="2"><strong>信用及<br>其他特殊狀況說明</strong></td>
			<td colspan="2" class="tbYellow2">
				<textarea id="CRED_DESC" name="CRED_DESC" cols="75" class="textBox2" rows="8"></textarea>
			</td>
		</tr>
		<tr>
			<td class="tbBlue" align="center" colspan="2">經辦人員</td>
			<td colspan="2" class="tbblue2"><SPAN ID="QUERYSTEP9_INPUT_NAME" style="font-family:'EUDC'"></SPAN></td> <%--[20240729]難字調整 --%>
		</tr>			
	</table>
</form>
</body>
</html>
