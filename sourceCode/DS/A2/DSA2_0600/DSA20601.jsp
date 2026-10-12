<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<%--

[20190801]問題單(20190730151718)：改以幣別分類顯示退票摘要 

 --%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script src="<%=htmlBase%>/CM/js/date.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script src="<%=htmlBase%>/CM/js/utility.js"></script>
<script src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

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
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'scroll', fix);

var grid;

var rtnList;

var validator;

var checkDataSer = 0;

var applyId;

function initApp(){
	PageUI.createPageWithAllBodySubElement( "DSA20601" , "核貸作業" ,"簡易徵信報告書" , 2,'${titleNotDisplay}' == 'Y');

	cleanMsgBoard();
	
	displayMessage();
		
	validator = new Validator();
	
	new UI().init();
	
	PageUI.resize();
}


//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){

				register.textNoSpace('APPLY_ID', "upper");

				grid = new TableUI( 
					{
						table: $("grid"),  
						overDiv:false,
						pageSize: 0,
						afterLoad:function(tableElement){
							var inputs = $('grid').select("input[type='radio']");
							
							var length = inputs.length;
							if(length > 0){							
								inputs[checkDataSer].checked = true;				
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
							}
						},
						column:[
								{header: '身分別',sortable: true, key:'ID_TYPE_NM',
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

				if ('${APPLY_ID}' != "") {
					$('APPLY_ID').value = '${APPLY_ID}';
				} else { 
					//保留參數管理-取得受理編號
					$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
				}			
				if($('APPLY_ID').value){
					query();
				}

		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	// 產生list
	createList:function(records){
		grid.load(records);
	},
	// 產生明細
	createDetail:function(obj){
		layout.clear();
		$('HEADER').innerHTML = "";
		
		//if(QRY_MAP){
			//受理編號
			$('OLD_APPLY_ID').innerHTML = applyId;
			$('NEW_APPLY_ID').value = $F('APPLY_ID');
			
			//被查詢人姓名
			$('SHOW_NAME').innerHTML = obj.QRY_MAP.NAME ? obj.QRY_MAP.NAME : '';
			$('SHOW_ID').value = obj.QRY_MAP.ID;
			
			//通報及補充註記
			if (obj.STEP1MAP){
				if (obj.STEP1MAP.VM108){
					if (obj.STEP1MAP.VM108 == 'Y'){
						$('STEP1MAP_VM108_Y').checked = true;
						$('STEP1MAP_VM108_Y').value = obj.STEP1MAP.VM108;
					} else {
						$('STEP1MAP_VM108_N').checked = true;
						$('STEP1MAP_VM108_N').value = obj.STEP1MAP.VM108;
					}
				}
				
				if (obj.STEP1MAP.VAM2){
					if (obj.STEP1MAP.VAM2 == 'Y'){
						$('STEP1MAP_VAM2_Y').checked = true;
						$('STEP1MAP_VAM2_Y').value = obj.STEP1MAP.VAM2;
					} else {
						$('STEP1MAP_VAM2_N').checked = true;
						$('STEP1MAP_VAM2_N').value = obj.STEP1MAP.VAM2;
					}
				}
			}
			
			//授信異常記錄
			if (obj.BAS001_MAP && obj.BAS001_MAP.EVER_DELINQUENT){
				if (obj.BAS001_MAP.EVER_DELINQUENT == 'N' || obj.BAS001_MAP.EVER_DELINQUENT == ''){
					$('EVER_DELINQUENT_N').checked = true;  // 'checked'
					$('EVER_DELINQUENT_N').value = obj.BAS001_MAP.EVER_DELINQUENT;
					$('DELINE_NM').innerHTML = '';
				} else {
					$('EVER_DELINQUENT_Y').checked = true;  // 'checked'
					$('EVER_DELINQUENT_Y').value = obj.BAS001_MAP.EVER_DELINQUENT;
					$('DELINE_NM').innerHTML = obj.BAS001_MAP.DELINE_NM;
				}
			}else{
				$('EVER_DELINQUENT_N').checked = true;  // 'checked'
				$('DELINE_NM').innerHTML = '';
			}
			
			
			//拒絕往來記錄
			if (obj.CHECKMAP){
				
					var NO_DAS002 = (typeof obj.CHECKMAP.NO_DAS002 === 'undefined') ? '' : obj.CHECKMAP.NO_DAS002;
					var REJECT_YN_NM1 = (typeof obj.CHECKMAP.REJECT_YN_NM1 === 'undefined') ? '' : obj.CHECKMAP.REJECT_YN_NM1;
					var REJECT_YN_NM2 = (typeof obj.CHECKMAP.REJECT_YN_NM2 === 'undefined') ? '' : obj.CHECKMAP.REJECT_YN_NM2;
					var REJECT_YN_NM3 = (typeof obj.CHECKMAP.REJECT_YN_NM3 === 'undefined') ? '' : obj.CHECKMAP.REJECT_YN_NM3;
					
					if (obj.CHECKMAP.REJECT_COLOR == 'RED'){
						$('NO_DAS002').innerHTML = NO_DAS002;
						$('REJECT_YN').innerHTML = REJECT_YN_NM1 + '<span style="color:red" >' + REJECT_YN_NM2 + '</span>' + REJECT_YN_NM3;
					} else {
						$('NO_DAS002').innerHTML = NO_DAS002;
						$('REJECT_YN').innerHTML = REJECT_YN_NM1 + REJECT_YN_NM2 + REJECT_YN_NM3;
					}
				
				if (!obj.CHECKMAP.NO_DAS006){
					var RJC_LIST = obj.CHECKMAP.RJC_LIST;
					var HEADERA = "";
					var HEADERB = "";
					var HEADERD = "";
					var HEADERF = "";
					//退票摘要記錄
					<%-- [20190801]問題單：改以幣別分類顯示退票摘要 --%>
					for(var i=0; i < RJC_LIST.length;i++){
						var SPAN = new Element('span');
						//受查戶之退票(未清償)
						var HEADERA1 = (typeof RJC_LIST[i].HEADERA1 === 'undefined') ? '' : RJC_LIST[i].HEADERA1;
						var HEADERA2 = (typeof RJC_LIST[i].HEADERA2 === 'undefined') ? '' : Number(RJC_LIST[i].HEADERA2);
						var HEADERA3 = (typeof RJC_LIST[i].HEADERA3 === 'undefined') ? '' : RJC_LIST[i].HEADERA3;
						var HEADERA4 = (typeof RJC_LIST[i].HEADERA4 === 'undefined') ? '' : CSRUtil.$fmt(RJC_LIST[i].HEADERA4 ||0, "#,###");
						var HEADERA5 = (typeof RJC_LIST[i].HEADERA5 === 'undefined') ? '' : RJC_LIST[i].HEADERA5;
						var HEADERA6 = (typeof RJC_LIST[i].HEADERA6 === 'undefined') ? '' : RJC_LIST[i].HEADERA6;						
						
						//受查戶之退票(已清償)
						var HEADERB1 = (typeof RJC_LIST[i].HEADERB1 === 'undefined') ? '' : RJC_LIST[i].HEADERB1;
						var HEADERB2 = (typeof RJC_LIST[i].HEADERB2 === 'undefined') ? '' : Number(RJC_LIST[i].HEADERB2);
						var HEADERB3 = (typeof RJC_LIST[i].HEADERB3 === 'undefined') ? '' : RJC_LIST[i].HEADERB3;
						var HEADERB4 = (typeof RJC_LIST[i].HEADERB4 === 'undefined') ? '' : CSRUtil.$fmt(RJC_LIST[i].HEADERB4 ||0, "#,###");
						var HEADERB5 = (typeof RJC_LIST[i].HEADERB5 === 'undefined') ? '' : RJC_LIST[i].HEADERB5;
						var HEADERB6 = (typeof RJC_LIST[i].HEADERB6 === 'undefined') ? '' : RJC_LIST[i].HEADERB6;
						
						//受查戶擔任負責人企業之退票(未清償)
						var HEADERD1 = (typeof RJC_LIST[i].HEADERD1 === 'undefined') ? '' : RJC_LIST[i].HEADERD1;
						var HEADERD2 = (typeof RJC_LIST[i].HEADERD2 === 'undefined') ? '' : Number(RJC_LIST[i].HEADERD2);
						var HEADERD3 = (typeof RJC_LIST[i].HEADERD3 === 'undefined') ? '' : RJC_LIST[i].HEADERD3;
						var HEADERD4 = (typeof RJC_LIST[i].HEADERD4 === 'undefined') ? '' : CSRUtil.$fmt(RJC_LIST[i].HEADERD4 ||0, "#,###");
						var HEADERD5 = (typeof RJC_LIST[i].HEADERD5 === 'undefined') ? '' :	RJC_LIST[i].HEADERD5;
						var HEADERD6 = (typeof RJC_LIST[i].HEADERD6 === 'undefined') ? '' : RJC_LIST[i].HEADERD6;
						
						//受查戶擔任企業之退票(已清償)						
						var HEADERF1 = (typeof RJC_LIST[i].HEADERF1 === 'undefined') ? '' : RJC_LIST[i].HEADERF1;
						var HEADERF2 = (typeof RJC_LIST[i].HEADERF2 === 'undefined') ? '' : Number(RJC_LIST[i].HEADERF2);
						var HEADERF3 = (typeof RJC_LIST[i].HEADERF3 === 'undefined') ? '' : RJC_LIST[i].HEADERF3;
						var HEADERF4 = (typeof RJC_LIST[i].HEADERF4 === 'undefined') ? '' : CSRUtil.$fmt(RJC_LIST[i].HEADERF4 ||0, "#,###");
						var HEADERF5 = (typeof RJC_LIST[i].HEADERF5 === 'undefined') ? '' : RJC_LIST[i].HEADERF5;
						var HEADERF6 = (typeof RJC_LIST[i].HEADERF6 === 'undefined') ? '' : RJC_LIST[i].HEADERF6;
						
						var CUR_CODE = new Element('span');
						CUR_CODE.innerHTML = '<br/>　　&nbsp;&nbsp;幣別：'+ RJC_LIST[i].CURRENCY_CODE;
						$('HEADER').insert(CUR_CODE);
						if (HEADERA1 + HEADERA2 + HEADERA3 + HEADERA4 + HEADERA5 + HEADERA6){
							if (RJC_LIST[i].HEADERA_STYPE == 'RED&&U'){
								HEADERA = '<br>　　&nbsp;&nbsp;' + '【受查戶之退票】' + '<br>　　&nbsp;&nbsp;'  + '<span style="color:red" class="textBold" >' + HEADERA1 + '</span>' + '<span style="color:red" class="textBold" >'+ HEADERA2 + '</span>' + HEADERA3 + '<span style="color:red" class="textBold" >'+ HEADERA4 + '</span>' + HEADERA5 + '<span style="color:red" class="textBold" >' + HEADERA6+ '</span>';
							} else {
								HEADERA = HEADERA1 + HEADERA2 + HEADERA3 + HEADERA4 + HEADERA5 + HEADERA6;
							}
							$(SPAN).innerHTML = HEADERA;
							$('HEADER').insert(SPAN);	
						}
											
						var SPAN2 = new Element('span');
						if (HEADERB1 + HEADERB2 + HEADERB3 + HEADERB4 + HEADERB5 + HEADERB6){
							if (RJC_LIST[i].HEADERB_STYPE == 'RED&&U'){
								HEADERB = HEADERB1 + '<span style="color:red" class="textBold" >'+ HEADERB2 + '</span>' + HEADERB3 + '<span style="color:red" class="textBold" >'+ HEADERB4 + '</span>' + HEADERB5 + '<span style="color:red" class="textBold" >' + HEADERB6+ '</span>';
							} else {
								HEADERB = HEADERB1 + HEADERB2 + HEADERB3 + HEADERB4 + HEADERB5 + HEADERB6;
							}
							$(SPAN2).innerHTML = '<br>　　&nbsp;&nbsp;' + HEADERB;
							$('HEADER').insert(SPAN2);
						}					
						
						var SPAN3 = new Element('span');
						if (RJC_LIST[i].HEADERC1){
							$(SPAN3).innerHTML = '<br>　　' + RJC_LIST[i].HEADERC1;
							$('HEADER').insert(SPAN3);
						}					
						
						var SPAN4 = new Element('span');
						if (HEADERD1 + HEADERD2 + HEADERD3 + HEADERD4 + HEADERD5 + HEADERD6){
							if (RJC_LIST[i].HEADERD_STYPE == 'RED&&U'){
								HEADERD = HEADERD1 + '<span style="color:red" class="textBold" >'+ HEADERD2 + '</span>' + HEADERD3 + '<span style="color:red" class="textBold" >'+ HEADERD4 + '</span>' + HEADERD5 + '<span style="color:red" class="textBold" >' + HEADERD6+ '</span>';
							} else {
								HEADERD = HEADERD1 + HEADERD2 + HEADERD3 + HEADERD4 + HEADERD5 + HEADERD6;
							}
							$(SPAN4).innerHTML = '<br>　　&nbsp;&nbsp;' + HEADERD;
							$('HEADER').insert(SPAN4);
						}
						
						var SPAN5 = new Element('span');
						if (RJC_LIST[i].HEADERE1){
							$(SPAN5).innerHTML = '<br>　　' + RJC_LIST[i].HEADERE1;
							$('HEADER').insert(SPAN5);
						}
						
						var SPAN6 = new Element('span');
						if (HEADERF1 + HEADERF2 + HEADERF3 + HEADERF4 + HEADERF5 + HEADERF6){
							if (RJC_LIST[i].HEADERF_STYPE == 'RED&&U'){
								HEADERF = HEADERF1 + '<span style="color:red" class="textBold" >'+ HEADERF2 + '</span>' + HEADERF3 + '<span style="color:red" class="textBold" >'+ HEADERF4 + '</span>' + HEADERF5 + '<span style="color:red" class="textBold" >' + HEADERF6+ '</span>';
							} else {
								HEADERF = HEADERF1 + HEADERF2 + HEADERF3 + HEADERF4 + HEADERF5 + HEADERF6;
							}
							$(SPAN6).innerHTML = '<br>　　&nbsp;&nbsp;' + '' +HEADERF;
							$('HEADER').insert(SPAN6);
						}					
					}
				} else {
					$('HEADER').innerHTML = (typeof obj.CHECKMAP.NO_DAS006 === 'undefined') ? '' : obj.CHECKMAP.NO_DAS006;
				}
			}
			
			//授信異常記錄-
			if (obj.QUERYSTEP9){
				if (obj.QUERYSTEP9.MSG){
					$('QUERYSTEP9_MSG').value = obj.QUERYSTEP9.MSG;
				} else {
					$('QUERYSTEP9_MSG').value = '';
				}
			}
			
			//金融機構授信總餘額
			if (obj.QUERYSTEP5){
				$('STEP5MAP_LOAN_AMTA').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.LOAN_AMTA,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_LOAN_AMTB').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.LOAN_AMTB,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_LOAN_AMT302').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.LOAN_AMT302,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_LOAN_AMT303').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.LOAN_AMT303,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_PASS_DUE_AMTA').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.PASS_DUE_AMTA,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_PASS_DUE_AMTB').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.PASS_DUE_AMTB,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_PASS_DUE_AMT302').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.PASS_DUE_AMT302,CSRUtil.defaultPattern) + '仟元';
				$('STEP5MAP_PASS_DUE_AMT303').innerHTML = CSRUtil.$fmt(obj.QUERYSTEP5.PASS_DUE_AMT303,CSRUtil.defaultPattern) + '仟元';
				
				if (obj.QUERYSTEP5.PAY_CODE12A_COLOR && obj.QUERYSTEP5.PAY_CODE12A_COLOR == "RED"){
					$('STEP5MAP_PAY_CODE12A_NM').innerHTML = '<font color="red">' + obj.QUERYSTEP5.PAY_CODE12A_NM + '</font>';
				} else {
					$('STEP5MAP_PAY_CODE12A_NM').innerHTML = '<font color="blue">' + obj.QUERYSTEP5.PAY_CODE12A_NM + '</font>';
				} 
				
				if (obj.QUERYSTEP5.PAY_CODE12B_COLOR && obj.QUERYSTEP5.PAY_CODE12B_COLOR == "RED"){
					$('STEP5MAP_PAY_CODE12B_NM').innerHTML = '<font color="red">' + obj.QUERYSTEP5.PAY_CODE12B_NM + '</font>';
				} else {
					$('STEP5MAP_PAY_CODE12B_NM').innerHTML = '<font color="blue">' + obj.QUERYSTEP5.PAY_CODE12B_NM + '</font>';
				}
				
				
				if (obj.QUERYSTEP5.COUNT608_COLOR && obj.QUERYSTEP5.COUNT608_COLOR == "RED"){
					$('STEP5MAP_COUNT608_NM').innerHTML = '<font color="red">' + obj.QUERYSTEP5.COUNT608_NM + '</font>';
				} else {
					$('STEP5MAP_COUNT608_NM').innerHTML = '<font color="blue">' + obj.QUERYSTEP5.COUNT608_NM + '</font>';
				}
				
				
				if (obj.QUERYSTEP5.ACCOUNT_CODEA087_COLOR && obj.QUERYSTEP5.ACCOUNT_CODEA087_COLOR == "RED"){
					$('STEP5MAP_ACCOUNT_CODE087').innerHTML = '<font color="red">' + obj.QUERYSTEP5.ACCOUNT_CODE087_NM + obj.QUERYSTEP5.ACCOUNT_CODE302_NM + obj.QUERYSTEP5.ACCOUNT_CODE303_NM + '</font>';
				} else {
					$('STEP5MAP_ACCOUNT_CODE087').innerHTML = '<font color="blue">' + obj.QUERYSTEP5.ACCOUNT_CODE087_NM + obj.QUERYSTEP5.ACCOUNT_CODE302_NM + obj.QUERYSTEP5.ACCOUNT_CODE303_NM + '</font>';
				}
			} else {
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
			}
			
			//現金卡記錄
			if (obj.CASHCARDMAP){
				$('CASHCARDMAP_CASH_CARD_CNT').innerHTML = (typeof obj.CASHCARDMAP.CASH_CARD_CNT === 'undefined') ? '　0　' : '　' + CSRUtil.$fmt(obj.CASHCARDMAP.CASH_CARD_CNT,CSRUtil.defaultPattern) + '　';
				$('CASHCARDMAP_CONTRACT_AMT').innerHTML = (typeof obj.CASHCARDMAP.CONTRACT_AMT === 'undefined') ? '　0　' : '　' + CSRUtil.$fmt(obj.CASHCARDMAP.CONTRACT_AMT,CSRUtil.defaultPattern) + '　';
				$('CASHCARDMAP_TOTAL_AMT').innerHTML = (typeof obj.CASHCARDMAP.TOTAL_AMT === 'undefined') ? '　0　' : '　' + CSRUtil.$fmt(obj.CASHCARDMAP.TOTAL_AMT,CSRUtil.defaultPattern) + '　';

				if (obj.CASHCARDMAP.TOTAL_AMT && Number (obj.CASHCARDMAP.TOTAL_AMT) > 0){
					if(obj.CASHCARDMAP.CASH_CARD_CNT && obj.CASHCARDMAP.CASH_CARD_CNT>0){
						if ((typeof obj.CASHCARDMAP.PASS_DUE_AMT !== 'undefined') && obj.CASHCARDMAP.PASS_DUE_AMT <= 0){
							$('CASHCARDMAP_PASS_DUE_AMT_Y').checked = true;
							$('CASHCARDMAP_PASS_DUE_AMT_Y').value = obj.CASHCARDMAP.PASS_DUE_AMT;
						} else {
							$('CASHCARDMAP_PASS_DUE_AMT_N').checked = true;
							$('CASHCARDMAP_PASS_DUE_AMT_N').value = obj.CASHCARDMAP.PASS_DUE_AMT;
						}
		                    
						if ((typeof obj.CASHCARDMAP.PAY_CODE068_CNT !== 'undefined') && obj.CASHCARDMAP.PAY_CODE068_CNT <= 0){
							$('CASHCARDMAP_PAY_CODE_068_CNT_Y').checked = true;
							$('CASHCARDMAP_PAY_CODE_068_CNT_Y').value = obj.CASHCARDMAP.PAY_CODE_068_CNT;
						} else {
							$('CASHCARDMAP_PAY_CODE_068_CNT_N').checked = true;
							$('CASHCARDMAP_PAY_CODE_068_CNT_N').value = obj.CASHCARDMAP.PAY_CODE_068_CNT;
						}
					}
				}
			} else {
				$('CASHCARDMAP_CASH_CARD_CNT').innerHTML = '　0　';
				$('CASHCARDMAP_CONTRACT_AMT').innerHTML = '　0　';
				$('CASHCARDMAP_TOTAL_AMT').innerHTML = '　0　';
			
			}
			
			//信用卡記錄
			if (obj.QUERYSTEP6){
			
				
					$('QUERYSTEP6_LIVE_CNT').innerHTML = '　' + CSRUtil.$fmt(Number(obj.QUERYSTEP6.LIVE_CNT),CSRUtil.defaultPattern)  + '　';
					if (obj.QUERYSTEP6.DEAD_CNT){
						if (Number (obj.QUERYSTEP6.DEAD_CNT) > 0){
							$('QUERYSTEP6_DEAD_CNT_1').checked = true;
							$('QUERYSTEP6_DEAD_CNT_1').value = Number (obj.QUERYSTEP6.DEAD_CNT);
							$('QUERYSTEP6_AB_CODE_NM').innerHTML = obj.QUERYSTEP6.AB_CODE_NM;
						} else {
							$('QUERYSTEP6_DEAD_CNT_0').checked = true;
							$('QUERYSTEP6_DEAD_CNT_0').value = Number (obj.QUERYSTEP6.DEAD_CNT);
						}
					}
					
					if(Number (obj.QUERYSTEP6.LIVE_CNT) <= 0){
					    $('QUERYSTEP6_PAY_CODE_TOT').checked = false;
					}else{
					    if (obj.QUERYSTEP6.PAY_CODE_TOT && Number (obj.QUERYSTEP6.PAY_CODE_TOT) > 0){
    						$('QUERYSTEP6_PAY_CODE_TOT').checked = false;
	    					$('QUERYSTEP6_PAY_CODE_TOT').value = Number (obj.QUERYSTEP6.PAY_CODE_TOT);
		    			}else{
		    				$('QUERYSTEP6_PAY_CODE_TOT').checked = true;
		    			} 					
					}
					if (obj.QUERYSTEP6.PAY_CODE2N && Number (obj.QUERYSTEP6.PAY_CODE2N) > 0){
						$('QUERYSTEP6_PAY_CODE2N_YN').checked = true;
						$('QUERYSTEP6_PAY_CODE2N').innerHTML = '　' + Number (obj.QUERYSTEP6.PAY_CODE2N) + '　';
					}else{
						$('QUERYSTEP6_PAY_CODE2N').innerHTML = '　' + 0 + '　';
					}
					
					if(obj.QUERYSTEP6.REVOL_HEADER1){
						var REVOL_HEADER1 = (typeof obj.QUERYSTEP6.REVOL_HEADER1 === 'undefined') ? '' : obj.QUERYSTEP6.REVOL_HEADER1;
						var REVOL_RATE = (typeof obj.QUERYSTEP6.REVOL_RATE === 'undefined') ? '' : obj.QUERYSTEP6.REVOL_RATE;
						var REVOL_HEADER2 = (typeof obj.QUERYSTEP6.REVOL_HEADER2 === 'undefined') ? '' : obj.QUERYSTEP6.REVOL_HEADER2;
						var PERM_LIMIT = (typeof obj.QUERYSTEP6.PERM_LIMIT === 'undefined') ? '' : obj.QUERYSTEP6.PERM_LIMIT;
						var REVOL_HEADER3 = (typeof obj.QUERYSTEP6.REVOL_HEADER3 === 'undefined') ? '' : obj.QUERYSTEP6.REVOL_HEADER3;
						$('QUERYSTEP6_REVOL_HEADER1').innerHTML = REVOL_HEADER1;
						$('QUERYSTEP6_REVOL_RATE').innerHTML = '　' + REVOL_RATE + '　';
						$('QUERYSTEP6_REVOL_HEADER2').innerHTML = REVOL_HEADER2;
						$('QUERYSTEP6_PERM_LIMIT').innerHTML = '　' + PERM_LIMIT + '　';
						$('QUERYSTEP6_REVOL_HEADER3').innerHTML = REVOL_HEADER3;
					}else{
						$('QUERYSTEP6_REVOL_HEADER1').innerHTML = '';
						$('QUERYSTEP6_REVOL_RATE').innerHTML = '';
						$('QUERYSTEP6_REVOL_HEADER2').innerHTML = '';
						$('QUERYSTEP6_PERM_LIMIT').innerHTML = '';
						$('QUERYSTEP6_REVOL_HEADER3').innerHTML = '';
					}
					
					if (Number (obj.QUERYSTEP6.PAY_CODE3N) > 0){
						$('QUERYSTEP6_PAY_CODE3N_YN').checked = true;
						$('QUERYSTEP6_PAY_CODE3N').innerHTML = '　' + Number (obj.QUERYSTEP6.PAY_CODE4N) + '　';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM1').innerHTML = obj.QUERYSTEP6.PAY_CODE034_CNT_NM1;
						$('QUERYSTEP6_PAY_CODE034_CNT1').innerHTML = '　' + obj.QUERYSTEP6.PAY_CODE034_CNT + '　';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM2').innerHTML = obj.QUERYSTEP6.PAY_CODE034_CNT_NM2;
						$('QUERYSTEP6_LAST_PAYA').innerHTML = '　' + obj.QUERYSTEP6. LAST_PAYA + '　';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM3').innerHTML = obj.QUERYSTEP6.PAY_CODE034_CNT_NM3 ;
					}else{
						$('QUERYSTEP6_PAY_CODE3N').innerHTML = '　' + 0 + '　';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM1').innerHTML = '';
						$('QUERYSTEP6_PAY_CODE034_CNT1').innerHTML = '';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM2').innerHTML = '';
						$('QUERYSTEP6_LAST_PAYA').innerHTML = '';
						$('QUERYSTEP6_PAY_CODE034_CNT_NM3').innerHTML = '';
					}
				

				if (obj.QUERYSTEP6.CASH_YN){
					if (Number (obj.QUERYSTEP6.CASH_YN) > 0){
						$('QUERYSTEP6_CASH_YN_1').checked = true;
						$('QUERYSTEP6_CASH_YN_1').value = Number (obj.QUERYSTEP6.CASH_YN);
						$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　' + obj.QUERYSTEP6.CASHLENT_STR + '　';
						$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　' + obj.QUERYSTEP6.CASHLENT_INT + '　';
						$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　' + CSRUtil.$fmt(obj.QUERYSTEP6.SUM_CASHLENT_INT,CSRUtil.defaultPattern) + '　';
					} else {
						$('QUERYSTEP6_CASH_YN_0').checked = true;
						$('QUERYSTEP6_CASH_YN_0').value = Number (obj.QUERYSTEP6.CASH_YN);
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
				
				if (obj.QUERYSTEP6.PAY_CODE034_CNT){
					if (Number (obj.QUERYSTEP6.PAY_CODE034_CNT) > 0){
						$('QUERYSTEP6_PAY_CODE034_CNT_YN').checked = true;
						$('QUERYSTEP6_PAY_CODE034_CNT_YN').value = Number (obj.QUERYSTEP6.PAY_CODE034_CNT);
						$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　' + obj.QUERYSTEP6.PAY_CODE034_CNT + '　';
					} else {
						$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';
					}
				}else{
						$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';
				}
				
				if (obj.QUERYSTEP6.DEBT_CODE && Number (obj.QUERYSTEP6.DEBT_CODE) > 0){
					$('QUERYSTEP6_DEBT_CODE').checked = true;
				}else{
					$('QUERYSTEP6_DEBT_CODE').checked = false;
				}
			} else {
				$('QUERYSTEP6_LIVE_CNT').innerHTML = '　0　';
				$('QUERYSTEP6_CASHLENT_STR').innerHTML = '　0　';
				$('QUERYSTEP6_CASHLENT_INT').innerHTML = '　0　';
				$('QUERYSTEP6_SUM_CASHLENT_INT').innerHTML = '　0　';
				$('QUERYSTEP6_PAY_CODE034_CNT').innerHTML = '　0　';
				
			}
			//近三個月被查詢次數
			if (obj.QRY_CNT_MAP){
				var CNT1 = obj.QRY_CNT_MAP.CNT1 || '0';
				var CNT2 = obj.QRY_CNT_MAP.CNT2 || '0';
				$('QRY_CNT_MAP_CNT1_ADD_CNT2').innerHTML = '　' + (Number (CNT1)+Number (CNT2)) + '　';
			} else {
				$('QRY_CNT_MAP_CNT1_ADD_CNT2').innerHTML = '　0　';
			}
			
			
		//}
	},
	// 清除畫面欄位
	clear:function(type){
			$$('#form1 input[type="text"]').each(
				function(text){
					// 執行清除
					if(type == "1"){
						text.value = "";
					}else if(text.id != "APPLY_ID"){
						text.value = "";
					}
				}
			);
			
	
			$$('#form1 input[type="checkbox"]').each(
				function(checkbox){

					checkbox.checked = false;

				}
			);
			
			$$('#form1 input[type="radio"]').each(
				function(radio){
					radio.checked = false;

				}
			);
	
			$$('#form1 span').each(
				function(span){
					if(span.innerHTML.indexOf("第") <= 0){
						span.innerHTML = ''; 
					}
				}
			);
		
		}
};

<%--
	查詢作業
--%>
function query() {
	if(!validates.checkInput("query")){
		return;
	}
	applyId = $F('APPLY_ID');

	//保留參數管理-更新受理編號
	CSRUtil.keepParamsManager.put({'APPLY_ID': applyId});

	checkDataSer = 0;
  	new Ajax.Request("<%=dispatcher%>/DSA2_0601/query", 
	{
			parameters:{"APPLY_ID":$F('APPLY_ID')},
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					
					rtnList = resp.returnList;
					var dataArray = [];
					for(var i=0; i<rtnList.length; i++){
						rtnList[i].QRY_MAP['SER_NO'] = i;
						dataArray.push(rtnList[i].QRY_MAP);
					}				
					grid.load(dataArray, null, null, ['0']);
					
					
					
					
				}else{
					if(resp.DATA_NOT_FOUND){
						grid.load([]);
						layout.clear();
					}
				}
			}
	});

};

//--------------------------------------------------------------------------
// 註冊事件
//--------------------------------------------------------------------------
var register = {
	// 欄位去空白
	textNoSpace:function (keys, type){	
		$w(keys).each( 
			function(key){
				$(key).observe('blur', function(event){
					formatInput.text(key);
					
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
	// 金額欄位轉換
	isMoney:function (keys){
		$w(keys).each( 
			function(key){
				$(key).observe('blur', function(event){
					formatInput.money(key, true, $(key).pattern);
				});
			}
		);
	}
};

//--------------------------------------------------------------------------
// 格式化
//--------------------------------------------------------------------------
var formatInput = {
	// 一般輸入
	text:function(key_Value, isKey, defaultVaule){
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
	// 金額輸入
	money:function(key_Value, isKey, pattern, mode, defaultVaule){
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
			pattern = ($(key_Value).pattern) ? $(key_Value).pattern : pattern;
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
		if(isNaN(parseInt(value))){
			value = defaultVaule.trim();
		}else {
			var bigNum = new BigNumber(value, scale).toString();
			if(value === 0){
				return "0";
			}else if(mode == "0"){
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
	// 取得金額位數(台幣：整數、非台幣：兩位小數)
	getMoneyPattern:function(CURR){
		if(CURR == "NTD"){
			return pattern_money;
		}else{
			return pattern_money2;
		}
	},
	// 民國年轉西元年
	ROCDate2Y2KDate:function(date){
		var rocDate;
		var isKey;
		if(date && $(date)){
			rocDate = $(date).value;
			isKey = true;
		}else{
			rocDate = date;
			isKey = false;
		}
		
		if(rocDate){
			var dateLength = rocDate.length;

			if(dateLength == 5 && isROCdate("0" + rocDate, true)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
				
				if($(date)){
					$(date).value = value;
				}
				
				return value;
			}else if(dateLength > 5 && isROCdate(rocDate, true)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);
				
				if($(date)){
					$(date).value = value;
				}
				
				return value;
			}
		}
		
		if(isKey){
			alert("輸入的日期：" + rocDate + "，不符合民國年格式(例：1000101)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年轉民國年 
	Y2KDate2ROCDate:function(date, symbol){
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

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
			if(isADdate(y2kDate)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1] + symbol + dates[2];
				
				if(splitTool.length > 1){
					y2kDate = y2kDate + " " + splitTool[1];
				}
				
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
	},
	// 西元年月轉民國年月
	Y2KMonth2ROCMonth:function(date, symbol){
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

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
			
			if(y2kDate.length < 10){
				y2kDate = y2kDate + "-01";
			}
			if(isADdate(y2kDate)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
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
var validates = {
	// 畫面欄位
	checkInput:function(type){
		$$('#form1 input[type="text"]').each( 
			function(text){ 
				text.style.backgroundColor = '';
			}
		);
		
		validator.clear();

		if(type == "query"){
			if($('APPLY_ID').value == ""){
				validator.define("APPLY_ID", "", "您必須填入受理編號的資料!!", validates.returnFalse);
			}
		}
		
		return validator.validate();
	},
	// 檢查輸入日期是否合法
	checkDate:function(date, checkEmpty, mod){
		var inputDate;
		if($(date)){
			inputDate = $(date).value;
		}else{
			inputDate = date;
		}
	
		if(checkEmpty != "true" && inputDate == ""){
			return true;
		}else{
			if(mod == "ROC"){
				return isROCdate(inputDate, true);
			}else{
				return isADdate(inputDate);
			}
		}
	},
	// 檢核傳進來的值是否為正確的數字格式？是，則將該欄位依照pattern(自訂或預設)格式化；否，則將該欄位清空
	checkedNum:function(key){
		var value = $(key).getValue().trim();

		if(isNaN(parseInt(value))){
			return false;
		}else{
			return true;
		}
	},
	// 檢核數字欄位是否符合規定的長度
	checkNumPattern:function(key, isPositive){
		if(validates.checkedNum(key)){
			var intLength = $(key).intLength;
			var decLength = $(key).decLength ? $(key).decLength : 0;
			
			if(!isNaN(parseInt(intLength, 10)) && !isNaN(parseInt(decLength, 10))){
				var value = $(key).getValue();
				
				var tmp1 = value.split(".");
				var INT = tmp1[0];
				var DEC = (tmp1.length > 1) ? tmp1[1] : "";
				
				if(isPositive === true){
					if(INT < 0){
						return false;
					}else if(INT.length > intLength){
						return false;
					}
				}else if(isPositive === false){
					if(INT >= 0){
						return false;
					}else if(INT.length > intLength++){
						return false;
					}
				}else{
					if(INT < 0 && INT.length > intLength){
						return false;
					}else if(INT >= 0 && INT.length > intLength++){
						return false;
					}
				}
				
				if(DEC.length > decLength){
					return false;
				}else{
					return true;
				}
			}else{
				return true;
			}
		}else{
			return false;
		}
	},
	
	// 回傳false
	returnFalse:function(){
		return false;
	}
};

/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_0601/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	    	onSuccess: successAction
		});
	}  


//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

	<table id="queryArea" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<tr>
			<td width="15%" class="tbYellow">受理編號</td>
			<td class="tbYellow2" width="85%">
	            <input type="text" class="textBox" id="APPLY_ID" name="APPLY_ID" size="15" maxLength="11" value="">
				<input id="btnQuery" name="btnQuery" onClick="query()" type="button" class="button" value="查詢"> 
			</td>
		</tr>
	</table>
	<table id='grid' class="grid"></table>	
				
	
			<!-- Block_3_Start 表單主功能區塊-->
			
		<form name="form1" id="form1" method="post">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
				<tr>
					<td colspan="7" align="center" class="tbYellow0"><font color="red" >＊＊資料日期為核准日期前最後一次聯徵查詢記錄＊＊</font></td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>受理編號</strong></td>
					<td colspan="5" class="tbYellow2"><span ID="OLD_APPLY_ID"></span><input type="hidden" id="NEW_APPLY_ID" name="NEW_APPLY_ID"/></td>
					
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>被查詢人姓名</strong></td>
					<td colspan="5" class="tbYellow2"><span ID="SHOW_NAME" style="font-family:'EUDC'"/></span><%-- [20240729]難字調整 --%>
					<input type="hidden" id="SHOW_ID" name="SHOW_ID"/></td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>通報及補充註記</strong></td>
					<td colspan="2" class="tbYellow2">
					1.其他補充註記：
					<input type="checkbox" name="STEP1MAP_VM108_Y" id="STEP1MAP_VM108_Y" value="" onclick="return false">有
					&nbsp;
					<input type="checkbox" name="STEP1MAP_VM108_N" id="STEP1MAP_VM108_N" value="" onclick="return false">無<br>
					2.通報案件記錄：
					<input type="checkbox" name="STEP1MAP_VAM2_Y" id="STEP1MAP_VAM2_Y" value="" onclick="return false">有
					&nbsp;
					<input type="checkbox" name="STEP1MAP_VAM2_N" id="STEP1MAP_VAM2_N" value="" onclick="return false">無</td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>授信異常記錄</strong></td>
					<td colspan="2" class="tbYellow2">
						<input type="checkbox" id="EVER_DELINQUENT_N" name="EVER_DELINQUENT_N" value="" onclick="return false">正常
						<input type="checkbox" id="EVER_DELINQUENT_Y" name="EVER_DELINQUENT_Y" value="" onclick="return false">授信異常<font id="DELINE_NM"></font>&nbsp;&nbsp;&nbsp;&nbsp;<font
	color="blue">備註</font>&nbsp;
						<input type="text" name="QUERYSTEP9_MSG" id="QUERYSTEP9_MSG"  class="textBox2" size="59" maxlength="100" value="" readonly="readonly"/>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>金融機構授信總餘額</strong></td>
					<td colspan="2" class="tbYellow2" id="LOAN_KND_List">
						1.授信資料日期<br>
<table width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
	<tbody>
		<tr>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">擔保</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">無擔保</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">共同債務</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">從債務</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">債權轉讓註記</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">催收款項呆帳</td>
		</tr>
		<tr>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">正常</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMTA"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMTB"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMT302"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_LOAN_AMT303"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1" rowspan="3"><SPAN ID="STEP5MAP_COUNT608_NM"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1" rowspan="3"><SPAN ID="STEP5MAP_ACCOUNT_CODE087"/></td>
		</tr>
		<tr>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"">逾期</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMTA"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMTB"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMT302"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN style="color:blue" ID="STEP5MAP_PASS_DUE_AMT303"/></td></tr>
		<tr>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">最近一年繳款記錄</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN ID="STEP5MAP_PAY_CODE12A_NM"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1"><SPAN ID="STEP5MAP_PAY_CODE12B_NM"/></td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">－</td>
			<td valign="middle" class="tbYellow2" align="center" colspan="1">－</td></tr>
	</tbody>
</table>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>現金卡記錄</strong></td>
					<td colspan="2" class="tbYellow2">張數：<SPAN ID="CASHCARDMAP_CASH_CARD_CNT" style='text-decoration:underline;color:blue'></SPAN>張，可動用額度<SPAN ID="CASHCARDMAP_CONTRACT_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元；已動用額度<SPAN ID="CASHCARDMAP_TOTAL_AMT" style='text-decoration:underline;color:blue'></SPAN>仟元<br>是否逾期：
					<input type="checkbox" name="CASHCARDMAP_PASS_DUE_AMT_Y" id="CASHCARDMAP_PASS_DUE_AMT_Y" value="" onclick="return false">正常
					<input type="checkbox" name="CASHCARDMAP_PASS_DUE_AMT_N" id="CASHCARDMAP_PASS_DUE_AMT_N" value="" onclick="return false">有逾期&nbsp;&nbsp;&nbsp;&nbsp;繳款狀況：
					<input type="checkbox" name="CASHCARDMAP_PAY_CODE_068_CNT_Y" id="CASHCARDMAP_PAY_CODE_068_CNT_Y" value="" onclick="return false">正常
					<input type="checkbox" name="CASHCARDMAP_PAY_CODE_068_CNT_N" id="CASHCARDMAP_PAY_CODE_068_CNT_N" value="" onclick="return false">有延遲</td>
				</tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>信用卡記錄</strong></td>
					<td colspan="2" class="tbYellow2">
						有效卡數<SPAN ID="QUERYSTEP6_LIVE_CNT" style='text-decoration:underline;color:blue'></SPAN>張&nbsp;&nbsp;&nbsp;&nbsp;強停：
						<input type="checkbox" name="QUERYSTEP6_DEAD_CNT_0" id="QUERYSTEP6_DEAD_CNT_0" value="" onclick="return false">無&nbsp;&nbsp;&nbsp;
						<input type="checkbox" name="QUERYSTEP6_DEAD_CNT_1" id="QUERYSTEP6_DEAD_CNT_1" value="" onclick="return false">有<SPAN ID="QUERYSTEP6_AB_CODE_NM"></SPAN></SPAN><br>【使用情形】：
						<input type="checkbox" name="QUERYSTEP6_PAY_CODE_TOT" id="QUERYSTEP6_PAY_CODE_TOT" value="" onclick="return false">正常<br>
 　　　　　　　			<input type="checkbox" name="QUERYSTEP6_PAY_CODE2N_YN" id="QUERYSTEP6_PAY_CODE2N_YN" value="" onclick="return false">有循環信用，
                              					<SPAN id="QUERYSTEP6_PAY_CODE2N" style='text-decoration:underline;color:blue'></SPAN>期
                              					<SPAN id="QUERYSTEP6_REVOL_HEADER1" ></SPAN>
                              					<SPAN id="QUERYSTEP6_REVOL_RATE" style='text-decoration:underline;color:blue'></SPAN>
                              					<SPAN id="QUERYSTEP6_REVOL_HEADER2" ></SPAN>
                              					<SPAN id="QUERYSTEP6_PERM_LIMIT" style='text-decoration:underline;color:blue'></SPAN>
                              					<SPAN id="QUERYSTEP6_REVOL_HEADER3" ></SPAN>&nbsp;<br>
						　　　　　　　			<input type="checkbox" name="QUERYSTEP6_PAY_CODE3N_YN" id="QUERYSTEP6_PAY_CODE3N_YN" value="" onclick="return false">有未繳，其中
                                    			<SPAN id="QUERYSTEP6_PAY_CODE3N" style='text-decoration:underline;color:blue'></SPAN>期全額未繳
                                    			<SPAN id="QUERYSTEP6_PAY_CODE034_CNT_NM1" ></SPAN>
                                    			<SPAN id="QUERYSTEP6_PAY_CODE034_CNT1" style='text-decoration:underline;color:blue'></SPAN>
                                    			<SPAN id="QUERYSTEP6_PAY_CODE034_CNT_NM2" ></SPAN>
                                    			<SPAN id="QUERYSTEP6_LAST_PAYA" style='text-decoration:underline;color:blue'></SPAN>
                                    			<SPAN id="QUERYSTEP6_PAY_CODE034_CNT_NM3" ></SPAN>
                                    			<br>【預借現金】：
						<input type="checkbox" name="QUERYSTEP6_CASH_YN_0" id="QUERYSTEP6_CASH_YN_0" value="" onclick="return false">無&nbsp;&nbsp;&nbsp;
						<input type="checkbox" name="QUERYSTEP6_CASH_YN_1" id="QUERYSTEP6_CASH_YN_1" value="" onclick="return false">有&nbsp;&nbsp;近<SPAN ID="QUERYSTEP6_CASHLENT_STR" style='text-decoration:underline;color:blue'></SPAN>年共<SPAN ID="QUERYSTEP6_CASHLENT_INT" style='text-decoration:underline;color:blue'></SPAN>期有預借現金，最高金額<SPAN ID="QUERYSTEP6_SUM_CASHLENT_INT" style='text-decoration:underline;color:blue'></SPAN>元<br>【繳款狀況】：
						<input type="checkbox" name="QUERYSTEP6_PAY_CODE034_CNT_YN" id="QUERYSTEP6_PAY_CODE034_CNT_YN" value="" onclick="return false">有遲延繳款記錄，共<SPAN ID="QUERYSTEP6_PAY_CODE034_CNT" style='text-decoration:underline;color:blue'></SPAN>期(以月統計)<br>【債權狀態】：
						<input type="checkbox" name="QUERYSTEP6_DEBT_CODE" id="QUERYSTEP6_DEBT_CODE" value="" onclick="return false">異常<br><b>【說明：信用卡繳款使用狀況為近一年資訊】</b></td>

			  </tr>
				<tr>
					<td class="tbYellow" align="center" colspan="1"><strong>票據查詢記錄</strong></td>
					<td colspan="2" class="tbYellow2">
						1.聯徵記錄：<br>　
						(1).拒往記錄：<SPAN ID="NO_DAS002"></SPAN><br>
						　　&nbsp;&nbsp;拒往往來記錄：<SPAN ID="REJECT_YN"></SPAN><br>　
						(2).退票摘要記錄：<SPAN ID="HEADER"></SPAN><br>
						</td>
				</tr>
				<tr>
					<td valign="middle" class="tbYellow" align="center" colspan="1"><strong>近三個月被查詢次數</strong></td>
					<td colspan="2" class="tbYellow2">
						近三個月被查詢次數<SPAN ID="QRY_CNT_MAP_CNT1_ADD_CNT2" style='text-decoration:underline;color:blue'></SPAN>家</td>
				</tr>
			</table>
		</form>
		
			
									
									
	</body>
</html>
