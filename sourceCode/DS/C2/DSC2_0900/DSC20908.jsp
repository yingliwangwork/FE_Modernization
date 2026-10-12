<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC20908.jsp
作者：張憶如 
功能：總帳帳務查詢-貸款明細表查詢    
完成：2013/9/13

[20241030]修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC20908().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC20908(){
	
	var grid1;
	var grid2;
	var grid3;
	var grid4;
	var grid5;
	var grid6;
	var grid7;
	
	//表格格式
	<%-- [20241030] 難字調整 --%>
	var gridList = [
		[	//rtnListA_2
			{header:"筆數", key:'ROW_NO'},
			{header:"借款人ID", key:'BORROW_ID'},
			{header:"扣薪金額", key:'REAL_PAYMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"工作年月", key:'WORK_YM'},			
			{header:"薪津組別", key:'SALARY_GROUP_NM'},	
			{header:"產生日期", key:'REAL_PAYDT'},
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}}
		],
		[	//rtnListB
			{header:"筆數", key:'ROW_NO'},
			{header:"劃撥帳號", key:'ACCOUNT'},
			{header:"劃撥日期", key:'TRANS_DATE'},
			{header:"交易局號", key:'POST_NO'},			
			{header:"交易代號", key:'TRANS_CODE_NM'},	
			{header:"交易序號", key:'TRANS_SEQNO', attrs:{align:'right'}},
			{header:"交易別", key:'TRANS_TYPE'},
			{header:"劃撥金額", key:'TRANS_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}}
		],
		[	//rtnListC
			{header:"筆數", key:'ROW_NO'},
			{header:"行庫代號", key:'BANK_CODE'},
			{header:"票據號碼", key:'CHECK_NO'},
			{header:"貸款帳號", key:'LOAN_ID'},			
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}},	
			{header:"繳款別", key:'PAY_KIND_NM'},
			{header:"繳款方式", key:'PAY_TYPE_NM'},
			{header:"開票人帳號", key:'CHECK_ACCNO'},
			{header:"序號", key:'SEQ_NO'},
			{header:"票據日期", key:'CHECK_DATE'},
			{header:"票面金額", key:'CHECK_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"繳票金額", key:'TICKET_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"繳現金額", key:'CASH_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"託收行庫", key:'AGENT_BANK'},
			{header:"收費代號", key:'GETINT_CODE'},
			{header:"票據組號", key:'CHECK_GROUP'}
		],
		[	//rtnListD
			{header:"筆數", key:'ROW_NO', attrs:{rowSpan:2}},
			{header:"暫應收編號", key:'BALC_NO'},
			{header:"沖帳貸款帳號", key:'LOAN_ID'},
			{header:"沖帳繳款期數", key:'PAY_TERM', attrs:{align:'right'}},			
			{header:"沖帳繳款別", key:'PAY_KIND_NM'},	
			{header:"暫應收原因", key:'BALC_REASON_NM'},
			{header:"沖帳前剩餘金額", key:'REMAIN_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"沖帳金額", key:'WASH_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },
			{header:"沖帳部入序號", key:'SEQ_NO', attrs:{align:'right'}},
			{header:"沖帳方式", key:'WASH_TYPE_NM'},
			{header:"暫應收備註", key:'BALC_MEMO'}
		],
		[ //rtnListE, rtnListG
			{header:"筆數", key:'ROW_NO'},
			{header:"受理編號", key:'APPLY_ID'},
			{header:"單據序號", key:'RECEIPT_SERNO', attrs:{align:'right'}},
			{header:"繳款金額", key:'PAYMENT_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },			
			{header:"收據狀態", key:'PAYMENT_STATUS_NM'},	
			{header:"輸入單位", key:'INPUT_DEPT_NM'},
			{header:"輸入人員", key:'EMP_NAME', style:"font-family:'EUDC'"},
			{header:"輸入日期", key:'INPUT_DATE'},
			{header:"結帳序號", key:'ACNT_NO', attrs:{align:'right'}},
			{header:"轉新件編號", key:'NEW_APPLY_ID'},
			{header:"轉出收據狀態", key:'RECEIPT_STATUS_NM'}
		],
		[ //rtnListF, rtnListH
			{header:"筆數", key:'ROW_NO'},
			{header:"受理編號", key:'APPLY_ID'},
			{header:"單據序號", key:'RECEIPT_SERNO', attrs:{align:'right'}},
			{header:"轉出金額", key:'PAYMENT_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },			
			{header:"收據狀態", key:'PAYMENT_STATUS_NM'},	
			{header:"轉出單位", key:'EXPORT_DEPT_NM'},
			{header:"轉出人員", key:'EMP_NAME', style:"font-family:'EUDC'"},
			{header:"轉出日期", key:'EXPORT_DATE'},
			{header:"結帳序號", key:'EXPORT_ACNT_NO', attrs:{align:'right'}},
			{header:"轉新件編號", key:'NEW_APPLY_ID'},
			{header:"轉出收據狀態", key:'RECEIPT_STATUS_NM'}
		],
		[ //rtnListI
			{header:"筆數", key:'ROW_NO'},
			{header:"流水序號", key:'SER_NO', attrs:{align:'right'}},
			{header:"處理序號", key:'PROC_SER_NO', attrs:{align:'right'}},
			{header:"專款金額", key:'AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },			
			{header:"專款單位", key:'DIV_NO'},	
			{header:"輸入單位", key:'INPUT_DEPT_NM'},
			{header:"輸入人員", key:'EMP_NAME', style:"font-family:'EUDC'"},
			{header:"輸入日期", key:'INPUT_DATE'},
			{header:"結帳序號", key:'ACNT_NO', attrs:{align:'right'}},
			{header:"摘要", key:'MEMO'}
		],
		[	//rtnListA_3
			{header:"筆數", key:'ROW_NO'},
			{header:"劃撥帳號", key:'TRANS_NO'},
			{header:"劃撥日期", key:'TRANS_DATE'},
			{header:"劃撥序號", key:'TRANS_SERNO', attrs:{align:'right'}},			
			{header:"劃撥金額", key:'TRANS_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },	
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}},
			{header:"繳款別", key:'PAY_KIND_NM'},
			{header:"序號", key:'SEQ_NO', attrs:{align:'right'}},
			{header:"備註", key:'REMARK'}
		],
		[	//rtnListA_5
			{header:"筆數", key:'ROW_NO'},
			{header:"電匯帳號", key:'TRANS_NO'},
			{header:"電匯日期", key:'TRANS_DATE'},
			{header:"電匯序號", key:'TRANS_SERNO', attrs:{align:'right'}},			
			{header:"電匯金額", key:'TRANS_AMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },	
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}},
			{header:"繳款別", key:'PAY_KIND_NM'},
			{header:"序號", key:'SEQ_NO'},
			{header:"備註", key:'REMARK'}
		],
		[	//rtnListA_6_14
			{header:"筆數", key:'ROW_NO'},
			{header:"扣帳日期", key:'DEDUCT_DATE'},
			{header:"轉帳帳號", key:'ACCOUNT'},
			{header:"實繳金額", key:'REAL_PAYMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },			
			{header:"轉帳單位", key:'UNIT_NO'},	
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}},
			{header:"轉帳年月", key:'TRANS_YM'},
			{header:"借款人ID", key:'BORROW_ID'},
			{header:"貸款餘額", key:'REMAIN_AMT',attrs:{align:'right'},
				render : function (rec , val){					 
					return CSRUtil.$fmt(val,"#,###");
				}
			 },
			{header:"代扣稅款", key:'TAX_CODE'}
		],
		[	//rtnListA_7
			{header:"筆數", key:'ROW_NO'},
			{header:"扣帳日期", key:'TRANS_DATE'},
			{header:"轉帳帳號", key:'ACCOUNT'},
			{header:"實繳金額", key:'REAL_PAYMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },	
			{header:"貸款帳號", key:'LOAN_ID'},	
			{header:"銷帳時間", key:'TRANS_TIME'},			
			{header:"交易序號", key:'SEQ_NO', attrs:{align:'right'}},			
			{header:"轉帳種類", key:'TRANS_KIND_NM'},			
			{header:"手續費", key:'HANDLE_FEE',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },			
			{header:"備註", key:'MEMO'},
			{header:"發卡銀行", key:'CREDIT_BANK'},
			{header:"扣帳情形", key:'TRANS_STATUS_NM'},
			{header:"ATM狀態", key:'ATM_CSTATUS'}
		],
		[	//rtnListA_8
			{header:"筆數", key:'ROW_NO'},
			{header:"存款帳戶", key:'DEPOST_KIND_NM'},
			{header:"扣帳日期", key:'DEDUCT_DATE'},
			{header:"轉帳年月", key:'TRANS_YM'},
			{header:"轉帳帳號", key:'ACCOUNT'},
			{header:"借款人ID", key:'BORROW_ID'},
			{header:"實繳金額", key:'REAL_PAYMT',renderInCount: true,
				render : function (rec , val){					 
					return '<div align="right">' + CSRUtil.$fmt(val,"#,###") + '</div>';
				}
			 },	
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM', attrs:{align:'right'}},			
			{header:"轉帳組別", key:'TRANS_GROUP'},
			{header:"入帳狀態", key:'ACNT_CSTATUS'}
		]
			
	];
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_0908/" + actionName,
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
			}
		);
	}	
	
	var actions = {		
		//初始查詢		
		doQuery : function(){
			
			//發送ajax
			ajaxPost( 'query', {ACNT_DATE: '${ACNT_DATE}', ACNT_GROUP: '${ACNT_GROUP}'},
				function(resp){
					
					$('TITLE_NAME').update(resp.TITLE_NAME);
					$('ACNT_DATE_F').update(Date.toROC('${ACNT_DATE}'));
					
					<c:choose>
						<c:when test="${ACNT_GROUP == 1}">
							actions.gridTable("票據繳現資料檔", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							//actions.gridTable("電子謄本資料", null, 4);
							//actions.gridTable("轉出電子謄本資料", null, 5);
							//actions.gridTable("信用查詢資料", null, 4);
							//actions.gridTable("轉出信用查詢資料", null, 5);
							actions.gridTable("專款借支放款資料", null, 6);
							grid1.load(resp.rtnList1C||[]);
							grid2.load(resp.rtnList1D||[]);
							//grid3.load(resp.rtnList1E||[]);
							//grid4.load(resp.rtnList1F||[]);
							//grid5.load(resp.rtnList1G||[]);
							//grid6.load(resp.rtnList1H||[]);
							//grid7.load(resp.rtnList1I||[]);
							grid3.load(resp.rtnList1I||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 2}">
							actions.gridTable("員工扣薪", null, 0);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'REAL_PAYMT':resp.REAL_PAYMT || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 3}">
							actions.gridTable("劃撥紀錄檔(線上資料輸入)", null, 7);
							actions.gridTable("郵局劃撥銷帳檔(批次)", null, 1);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj_A = [{ text: '合計' , value:{'TRANS_AMT':resp.TRANS_AMT_A || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj_A||[]);
							var TOTobj_B = [{ text: '合計' , value:{'TRANS_AMT':resp.TRANS_AMT_B || 0}}];
							grid2.load(resp.rtnList1B||[], TOTobj_B||[]);
							grid3.load(resp.rtnList1C||[]);
							grid4.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 4}">
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							grid1.load(resp.rtnList1C||[]);
							grid2.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 5}">
							actions.gridTable("電匯紀錄檔", null, 8);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'TRANS_AMT':resp.TRANS_AMT || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 6}">
							actions.gridTable("匯通轉帳銷帳檔", null, 9);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'REAL_PAYMT':resp.REAL_PAYMT || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 7}">
							actions.gridTable("匯通ATM銷帳檔", null, 10);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'REAL_PAYMT':resp.REAL_PAYMT || 0, 'HANDLE_FEE':resp.HANDLE_FEE || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 8}">
							actions.gridTable("郵局轉帳銷帳檔", null, 11);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'REAL_PAYMT':resp.REAL_PAYMT || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 9}">
							actions.gridTable("世華轉帳銷帳檔", null, 9);
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							var TOTobj = [{ text: '合計' , value:{'REMAIN_AMT':resp.REMAIN_AMT || 0}}];
							grid1.load(resp.rtnList1A||[], TOTobj||[]);
							grid2.load(resp.rtnList1C||[]);
							grid3.load(resp.rtnList1D||[]);
						</c:when>
						<c:when test="${ACNT_GROUP == 99}">
							actions.gridTable("票據繳現資料", "SEQ_NO", 2);
							actions.gridTable("人工沖暫收退現資料", "REMAIN_AMT", 3);
							grid1.load(resp.rtnList1C||[]);
							grid2.load(resp.rtnList1D||[]);
						</c:when>
					</c:choose>
					
				}
			);				
		},
		//產生表格物件
		<%-- [20241030] 難字調整 --%>
		gridTable:function(titleName, splitName, i){
			if(grid1 == null){
				grid1 =  new TableUI({
				table: $("grid1"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}else if(grid2 == null){
				grid2 =  new TableUI({
				table: $("grid2"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}else if(grid3 == null){
				grid3 =  new TableUI({
				table: $("grid3"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				column: gridList[i]
				});
			}else if(grid4 == null){
				grid4 =  new TableUI({
				table: $("grid4"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}else if(grid5 == null){
				grid5 =  new TableUI({
				table: $("grid5"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}else if(grid6 == null){
				grid6 =  new TableUI({
				table: $("grid6"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}else{ //grid7
				grid7 =  new TableUI({
				table: $("grid7"), allSortable:false, pageSize: 20,overDiv:false, title: titleName, headClass:"tbBlue2", split: [splitName],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: gridList[i]
				});
			}
		}
	}
	
	
	return{
		initApp:function(){	
		PageUI.createPageWithAllBodySubElement( "DSC20908" , "收息帳務", "總公司帳務明細表" );
			
			
			actions.doQuery();
			// 回上一頁
			$('btn_back').observe('click', function(event){
				CSRUtil.linkBack();
			});
			displayMessage();
			PageUI.resize();
			
		}//end init()--
	};//end return--	
}//end DSC20908
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<th class="tbYellow0" align="center" colspan="2"><span id = "TITLE_NAME"></span></th>
			</tr>
			<tr>
				<td class="tbYellow" width="20%">帳務日期</td>
				<td class="tbYellow2" width="80%"><span id = "ACNT_DATE_F"></span></td>
			</tr>
		</table>
		<table id="grid1"></table>
		<table id="grid2"></table>
		<table id="grid3"></table>
		<table id="grid4"></table>
		<table id="grid5"></table>
		<table id="grid6"></table>
		<table id="grid7"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow1" align="center" colspan="2"><input id="btn_back" type="button" class="button" value="回上一頁"/></td>
			</tr>
		</table>
	</form>
</body>
</html>