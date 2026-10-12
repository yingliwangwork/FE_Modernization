<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSC22710.jsp
作者：黃子玹 
功能：帳務明細查詢
完成：2013/10/23
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->


<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/date.js"></script>      <%-- 標準外框表格 --%>
<%-- [20241104]難字 css --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight: normal;
		font-style: normal
	}
</style>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC22710().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
	
//以下為UI() public method,放在 return 中
function DSC22710(){
	
	var grid;	
	var QUERY_TYPE = '${QUERY_TYPE}';	
	
	var gridList = [
		//畫面一: 接值.QUERY_TYPE = "CHECK" (票據) 
		[	
			{header:"筆數", key:'ROW_NO'},
			{header:"行庫代號", key:'BANK_CODE'},
			{header:"票據號碼", key:'CHECK_NO'},
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM'},			
			{header:"繳款別", key:'PAY_KIND_NM'},
			{header:"繳款方式", key:'PAY_TYPE_NM'},
			{header:"開票人帳號", key:'CHECK_ACCNO'},
			{header:"入帳單位", key:'INPUT_DEPT'},
			{header:"序號", key:'SEQ_NO'},
			{header:"票據日期", key:'CHECK_DATE',
					render : function (rec , val){
							return Date.toROC(val || "");									
					}					
			},
			{header:"票面金額", key:'CHECK_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"繳票金額", key:'TICKET_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"繳現金額", key:'CASH_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"託收行庫", key:'AGENT_BANK'},	
			{header:"收費代號", key:'GETINT_CODE'},
			{header:"票據組號", key:'CHECK_GROUP'}		
		],
		//畫面二: 接值.QUERY_TYPE = "CASH" OR "LOAN" OR "NLOAN" OR "INT" OR "RINT" OR "TAX" OR "EXPENSE" 
		//(銀行存款、擔保貸款、擔保貸款-無自用、利息收入、應收利息、預付稅款、管理費用)
		[
			{header:"序號", key:'ROW_NO'},
			{header:"帳號", key:'LOAN_ID'},
			{header:"繳款別", key:'PAY_KIND_NM'},	
			{header:"繳款期數", key:'PAY_TERM'},
			{header:"貸款種類", key:'LOAN_KIND_NM'},
			{header:"計息起日", key:'INT_BEGDT',
					render : function (rec , val){
							return Date.toROC(val || "");									
					}					
			},
			{header:"計息迄日", key:'INT_ENDDT',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"應繳日", key:'DUTY_PAYDT',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"延滯天", key:'DELAY_DAY'},							
			{header:"利率", key:'RATE'},
			{header:"上期本金", key:'LAST_PRINCIPAL',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},		
			{header:"入帳單位", key:'INPUT_DEPT'},	
			{header:"上期結餘", key:'LAST_BALANCE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"本期結餘", key:'THIS_BALANCE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"實繳金額", key:'REAL_PAYMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"本金", key:'PRINCIPAL',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"利息", key:'INTEREST',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"災戶攤繳", key:'VICTIM_INT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"應利", key:'RETAIN_INT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"延滯息", key:'DELAY_INT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"違約金", key:'RENEGE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"代扣稅款", key:'TAX',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"管理費", key:'LAWSUIT_FEE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}
		],
		//2:畫面三:　 接值.QUERY_TYPE = "WCA" OR "WCB" OR "WDA" OR "WDB"　(沖其他暫收、沖人工暫收款、沖其他應收、沖人工應收)
		[
			{header:"筆數", key:'ROW_NO'},
			{header:"暫應收編號", key:'BALC_NO'},
			{header:"沖帳貸款帳號", key:'LOAN_ID'},
			{header:"沖帳繳款期數", key:'PAY_TERM'},
			{header:"沖帳繳款別", key:'PAY_KIND_NM'},	
			{header:"暫應收原因", key:'BALC_REASON_NM'},
			{header:"入帳單位", key:'INPUT_DEPT'},			
			{header:"沖帳前剩餘金額", key:'REMAIN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},			
			{header:"沖帳金額", key:'WASH_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"沖帳部入序號", key:'SEQ_NO'},
			{header:"沖帳方式", key:'WASH_TYPE_NM'},
			{header:"暫應收備註", key:'BALC_MEMO'}	
		],
		//畫面四:接值.QUERY_TYPE = "DA" OR "DB" OR "CA" OR "CB" (其他應收款、人工應收款、其他暫收、人工暫收)
		[	
			{header:"筆數", key:'ROW_NO'},
			{header:"暫應收編號", key:'BALC_NO'},			
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"繳款期數", key:'PAY_TERM'},			
			{header:"繳款別", key:'PAY_KIND_NM'},
			{header:"繳款方式", key:'PAY_TYPE_NM'},
			{header:"暫應收原因", key:'BALC_REASON_NM'},			
			{header:"入帳單位", key:'INPUT_DEPT'},
			{header:"原暫收金額", key:'BALC_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"剩餘金額", key:'REMAIN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"部入序號", key:'SEQ_NO'},
			{header:"實繳日", key:'REAL_PAYDT',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"票據狀態", key:'CHECK_STATUS_NM'},
			{header:"暫應收備註", key:'BALC_MEMO'}		
		],
		//畫面五:接值.QUERY_TYPE = "RECEIVE1"(催收款項)
		[
			{header:"序號", key:'ROW_NO'},
			{header:"帳號", key:'LOAN_ID'},
			{header:"貸款種類", key:'LOAN_KIND_NM'},
			{header:"計息起日", key:'INT_BEGDT',
					render : function (rec , val){
							return Date.toROC(val || "");									
					}					
			},
			{header:"計息迄日", key:'INT_ENDDT',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"下次應繳日", key:'NEXT_PAYDATE',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"上次實繳日", key:'PRE_PAYDATE',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"轉出日期", key:'OUT_DATE',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"已繳期數", key:'PAY_TERM'},
			{header:"逾期期數", key:'OVER_TERM'},		
			{header:"本金", key:'PRINCIPAL',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"利息", key:'INTEREST',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"上期結餘", key:'LAST_BALANCE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"應收利息", key:'RECEIVE_INT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"催收款項", key:'LOAN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"沖轉金額", key:'WASH_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"催收款項餘額", key:'REMAIN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}
		],
		//畫面六:接值.QUERY_TYPE = "BAD" OR  "OVERDUE" (備抵呆帳、催收款項-拍賣不足)
		[	
			{header:"筆數", key:'ROW_NO'},					
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"姓名", key:'BORROW_NAME'},	
			{header:"催收款項", key:'LOAN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"備抵呆帳", key:'BAD_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}		
		],
		//畫面七:接值.QUERY_TYPE = "RECEIVE2"(催收款項-協議不足)
		[	
			{header:"筆數", key:'ROW_NO'},					
			{header:"貸款帳號", key:'LOAN_ID'},		
			{header:"催收款項", key:'LOAN_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"催收款項-協議不足", key:'BAD_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"利息收入", key:'INTEREST',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"管理費用", key:'LAWSUIT_FEE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}				
		],
		//畫面八: 接值.QUERY_TYPE = "D_RECEIVE2" OR "C_RECEIVE1" (催收款項-提前沖轉、催收款項-提沖不足) 
		[	
			{header:"筆數", key:'ROW_NO'},					
			{header:"貸款帳號", key:'LOAN_ID'},			
			{header:"入帳金額", key:'PAY_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"催收款項－提前沖轉", key:'D_RECEIVE2_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"催收款項－提沖不足", key:'C_RECEIVE1_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"收回呆帳及過期帳", key:'OVERDUE_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"管理費用", key:'LAWSUIT_FEE',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}				
		],
		//畫面九: 接值.QUERY_TYPE = "LSFEE1" OR "LSFEE2" OR "LSFEE3" OR "LSFEE4" (法律事務費、帳戶管理費、代收火險費、利率調整換約收費)
		[	
			{header:"筆數", key:'ROW_NO'},					
			{header:"貸款帳號", key:'LOAN_ID'},
			{header:"生效日期", key:'EFFECT_DATE',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"管理費項目", key:'EXPENSE_ITEM_NM'},
			{header:"項目序號", key:'SER_NO'},		
			{header:"費用金額", key:'EXPENSE_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}		
		],
		//畫面十: 接值.QUERY_TYPE = "OVERDUE"(收回呆帳、收回呆帳及過期帳)
		[	
			{header:"筆數", key:'ROW_NO'},
			{header:"區域", key:'CRED_DEPT'},	
			{header:"貸款帳號", key:'LOAN_ID'},		
			{header:"收回呆帳", key:'BAD_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"期數", key:'PAY_TERM'},
			{header:"繳款別", key:'PAY_KIND'},
			{header:"序號", key:'SEQ_NO'}				
		],
		//畫面十一: 接值.QUERY_TYPE = "COURT" (催收款項-法院分配款)
		[	
			{header:"筆數", key:'ROW_NO'},
			{header:"貸款帳號", key:'LOAN_ID'},		
			{header:"總債權額", key:'TOTAL_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"法院分配款", key:'COURT_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"不足金額", key:'BAD_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}
			
		],
		//畫面十二: 接值.QUERY_TYPE = "RECEIVE1" AND ACNT_GROUP = "K" (提前沖轉調整:催收款項－提前沖轉)
		//接值.QUERY_TYPE = "OVERDUE" AND ACNT_GROUP = "K" (提前沖轉調整:收回呆帳)
		[	
			{header:"筆數", key:'ROW_NO'},
			{header:"貸款帳號", key:'LOAN_ID'},		
			{header:"作業金額", key:'ALL_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"入帳前餘額", key:'LAST_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"入帳後餘額", key:'THIS_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			},
			{header:"入帳金額", key:'PAY_AMT',renderInCount:true,
					render : function (rec , val){
							return '<div align="right">' + formatNumber(val) + '</div>';						
					}
			}
			
		]
	]


	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_2710/" + actionName,
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
	
	// 金額格式化
	function formatNumber(value){
		 return (value||value===0) ? CSRUtil.$fmt(value,"#,###.##") : '' ; 
	}
	var actions = {
	
		//table UI 共同方法
		gridtable : function(i){
			grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20, column:gridList[i]}
			);				  
		},
		//查詢
		doQuery : function(event) {
			ajaxPost( 'query',	{QUERY_TYPE : QUERY_TYPE, ACNT_DATE:'${ACNT_DATE}', ACNT_GROUP:'${ACNT_GROUP}', ACNT_STATUS:'${ACNT_STATUS}'},
				function(resp) {
					actions.gridtable(resp.QRY_NO || 0);
					if(10 == resp.QRY_NO || 8 == resp.QRY_NO || 4 == resp.QRY_NO || 1 == resp.QRY_NO || 5 == resp.QRY_NO
						|| 2 == resp.QRY_NO || 9 == resp.QRY_NO || 3 == resp.QRY_NO  || 11 == resp.QRY_NO){
						grid.load(resp.rtnList || '',resp.rtnSumList || '');
					}else{
						grid.load(resp.rtnList || '');
					}
				}
				, function(resp) {
					actions.gridtable(resp.QRY_NO || 0);
					//失敗把前次內容清掉
					grid.load([]);
				}
			);
		},
		//回上一頁
		doBack : function(event){
			
			CSRUtil.linkBack();
		}
			
	};
	
	
	return{
		initApp:function(){	
		
			PageUI.createPageWithAllBodySubElement( "DSC22710" , "收息帳務" , "帳務明細查詢");
			
			actions.gridtable(0);
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
								
			// 查詢
			//$('btn_query').observe('click', actions.doQuery);
			actions.doQuery();			
			//回上一頁
			$('btn_back').observe('click',actions.doBack);	
			
			var LP_JSON = CSRUtil.isBackLink('form1');	
							
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//DSC22710
//-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="grid" width="100%" class="grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>			
				<td class="tbYellow2" align="center"  >				
					<input id="btn_back" type="button" class="button" value="回上一頁">
				</td>	
			</tr>			
		</table>
	</form>		
</body>
</html>