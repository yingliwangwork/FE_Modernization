<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSC23310.jsp
作者：卓達瑋
功能：理則型房貸帳務明細表查詢 
完成：2013/05/07
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>

<script type="text/JavaScript">

Event.observe(window, 'load', new DSC23310().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC23310(){
	var grid;
    var gridList=[
			    [		//SHORT 和INT table			
					{header:"筆數",key:"COUNT_NO"},
                    {header:"貸款帳號",key:"LOAN_ID"},	
					{header:"繳款別",key:"PAY_KIND_NM"},
					{header:"交易類別",key:"TASK_TYPE_NM"},
					{header:"動撥方式",key:"PAY_TYPE_NM"},
                    {header:"金額",key:"PRINCIPAL",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"借款人ID",key:"BORROW_ID"},
					{header:"連結帳號",key:"MM_ACCOUNT"},
					{header:"實繳日",key:"REAL_PAYDT",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}

					},
					{header:"計息狀態",key:"ROLL_STATUS"},
					{header:"交易時間",key:"TRAN_TIME",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					}
				],
				[			//CASH table		
					{header:"筆數",key:"COUNT_NO"},
					{header:"身份證ID",key:"ACCOUNT_ID"},
                    {header:"銀行帳號",key:"ACCOUNT_NO"},
					{header:"交易種類",key:"TASK_ID_NM"},
					{header:"借貸方",key:"DBCR_NM"},
                    {header:"金額",key:"LOAN_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"通路",key:"CHANNEL_TYPE"},
					{header:"行庫",key:"BANK_NO"},
					{header:"ATM機號",key:"ATM_NO"},
					{header:"ATM序號",key:"ATM_SEQNO"},	
					{header:"交易時間",key:"TRAN_TIME",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					}					
				],
			    [			//WCA TAble		
					{header:"筆數",key:"COUNT_NO"},
					{header:"暫應收編號",key:"BALC_NO"},
                    {header:"沖帳貸款帳號",key:"LOAN_ID"},	
					{header:"沖帳繳款期數",key:"PAY_TERM"},
					{header:"沖帳繳款別",key:"PAY_KIND_NM"},
					{header:"暫應收原因",key:"BALC_REASON_NM"},
					{header:"入帳單位",key:"INPUT_DEPT"},
                    {header:"沖帳前剩餘金額",key:"REMAIN_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
                    {header:"沖帳金額",key:"WASH_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value != ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"沖帳部入序號",key:"SEQ_NO"},
					{header:"沖帳方式",key:"WASH_TYPE_NM"},
					{header:"暫應收備註",key:"BALC_MEMO"}	
				],
			    [			//LSFEE TABLE		
					{header:"筆數",key:"COUNT_NO"},
                    {header:"帳號",key:"LOAN_ID"},	
                    {header:"費用金額",key:"EXPENSE_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"管理費項目",key:"EXPENSE_ITEM_NM"},
					{header:"生效日",key:"EFFECT_DATE",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					
					},
					{header:"沖銷日期",key:"PAY_DATE",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					
					},
					{header:"期數",key:"PAY_TERM"}	
				],
				[			//DA TABLE		
					{header:"筆數",key:"COUNT_NO"},
					{header:"暫應收編號",key:"BALC_NO"},
                    {header:"貸款帳號",key:"LOAN_ID"},	
					{header:"繳款期數",key:"PAY_TERM",
					        render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"繳款別",key:"PAY_KIND_NM"},
					{header:"暫應收原因",key:"BALC_REASON_NM",
					    render : function (rec , val){
							var PAY_TYPE =rec.PAY_TYPE
							if(PAY_TYPE){
							    return PAY_TYPE+"-"+val;
							}
							return val||'';									
						}
					},
					{header:"入帳單位",key:"INPUT_DEPT"},
                    {header:"原應收金額",key:"BALC_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
                    {header:"沖帳金額",key:"REMAIN_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"部入序號",key:"SEQ_NO"},
					{header:"實繳日",key:"REAL_PAYDT",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					
					},
					{header:"暫應收備註",key:"BALC_MEMO"}	
				],
                [	//QUERY_TYPE == “WDB” or QUERY_TYPE == “WCB”	TABLE
					{header:"筆數",key:"COUNT_NO"},
					{header:"身份證ID",key:"ACCOUNT_ID"},
                    {header:"銀行帳號",key:"ACCOUNT_NO"},
					{header:"交易種類",key:"TASK_ID_NM"},
					{header:"借貸方",key:"DBCR_NM"},
                    {header:"金額",key:"LOAN_AMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"通路",key:"CHANNEL_TYPE"},
					{header:"行庫",key:"BANK_NO"},
					{header:"ATM機號",key:"ATM_NO"},
					{header:"ATM序號",key:"ATM_SEQNO"},	
					{header:"交易時間",key:"TRAN_TIME",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					
					}					
				],
				[		//CA	TABLE		
					{header:"筆數",key:"COUNT_NO"},
					{header:"帳號",key:"LOAN_ID"},
                    {header:"繳款別",key:"PAY_KIND_NM"},
					{header:"繳款期數",key:"PAY_TERM",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"貸款種類",key:"LOAN_KIND_NM"},
					{header:"計息起日",key:"INT_BEGDT",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					},
					{header:"計息迄日",key:"INT_ENDDT",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					},
					{header:"應繳日",key:"NEXT_PAYDT",
					    render : function (rec , val){
							return val ? Date.toROC(val):"";									
						}
					},
					{header:"延滯天",key:"DELAY_DAY"},
					{header:"利率",key:"RATE"},
                    {header:"上期本金",key:"LAST_PRINCIPAL",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},					
					{header:"入帳單位",key:"INPUT_DEPT"},
					{header:"上期結餘",key:"LAST_BALANCE",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "0";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
				    {header:"本期結餘",key:"THIS_BALANCE",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
                    {header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
                    {header:"本金",key:"PRINCIPAL",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
                    {header:"利息",key:"INTEREST",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
                    {header:"災戶攤繳",key:"VICTIM_INT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
                    {header:"應利",key:"RETAIN_INT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
                    {header:"延滯息",key:"DELAY_INT",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
                    {header:"違約金",key:"RENEGE",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},	
 					{header:"代扣稅款",key:"TAX",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					},
					{header:"管理費",key:"LAWSUIT_FEE",
					    render: function (record,value){
							//return value ? MoneyFormat(value) : "";
							if(value != null && value !== ""){
								return MoneyFormat(value);
							}
							return "";
						}
					}
				]
	]
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_3310/" + actionName,
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
	};
	var actions= {
        //將畫面寫入Map	

		//table UI 共同方法
		gridtable : function(i){
		    grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20,			
			column:gridList[i]});
		      
		
		}

	}	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
		    
            var TOT_NAME;
			var QUERY_TYPE=$F('QUERY_TYPE')
            //條件式給table UI
			if(QUERY_TYPE=='SHORT'||QUERY_TYPE=='INT'){
			    actions.gridtable(0);
			}else if(QUERY_TYPE=='CASH'){
			    actions.gridtable(1);
	
			}else if(QUERY_TYPE=='WCA'||QUERY_TYPE=='WDA'){
			    actions.gridtable(2);
	
			}else if(QUERY_TYPE=='LSFEE'){
			    actions.gridtable(3);
	
			}else if(QUERY_TYPE=='DA'){
			    actions.gridtable(4);
	
			}else if(QUERY_TYPE=='WDB'||QUERY_TYPE=='WCB'){
			    actions.gridtable(5);
		
			}else if(QUERY_TYPE=='CA'){
			    actions.gridtable(6);
	
			}
			ajaxPost( 'query', {'QUERY_TYPE' :QUERY_TYPE,'ACNT_DATE':'${ACNT_DATE}','ACNT_GROUP':'${ACNT_GROUP}'}
				,function(resp){
				    $('CONDITION').update(resp.CONDITION||'');
					$('ACNT_DATE').update(Date.toROC('${ACNT_DATE}')||'');
	
					if(QUERY_TYPE=='SHORT'||QUERY_TYPE=='INT'){
                        grid.load(resp.rtnList,[{value:{COUNT_NO:"合計",PRINCIPAL : MoneyFormat(resp.TOT_AMT)}}]);							
					}else if(QUERY_TYPE=='CASH'){
						grid.load(resp.rtnList,[{value:{COUNT_NO:"合計",LOAN_AMT : MoneyFormat(resp.TOT_AMT)}}]);	
		
					}else if(QUERY_TYPE=='WCA'||QUERY_TYPE=='WDA'){
						grid.load(resp.rtnList,[{ value:{COUNT_NO:"合計",WASH_AMT : MoneyFormat(resp.TOT_AMT)}}]);	

					}else if(QUERY_TYPE=='LSFEE'){
						grid.load(resp.rtnList,[{ value:{COUNT_NO:"合計",EXPENSE_AMT : MoneyFormat(resp.TOT_AMT)}}]);	
	
					}else if(QUERY_TYPE=='DA'){
						grid.load(resp.rtnList,[{ value:{COUNT_NO:"合計",BALC_AMT : MoneyFormat(resp.TOT_AMT)}}]);		
					}else if(QUERY_TYPE=='WDB'||QUERY_TYPE=='WCB'){
						grid.load(resp.rtnList,[{value:{COUNT_NO:"合計",LOAN_AMT : MoneyFormat(resp.TOT_AMT)}}]);		
					}else if(QUERY_TYPE=='CA'){
						grid.load(resp.rtnList,[{value:{COUNT_NO:"合計",THIS_BALANCE : MoneyFormat(resp.TOT_AMT)}}]);			
					}
					
				}
				,function(resp){
				    $('CONDITION').update(resp.CONDITION||'');
					$('ACNT_DATE').update(Date.toROC('${ACNT_DATE}'||''));
				}
			);
		},
		// 上一頁
		doBack : function() {	
			if (window['callbackHandler']) {
				callbackHandler();
				close();
			} else if (parent && parent.popupWin ) {
				if (parent.popupWin.callbackHandler) { parent.popupWin.callbackHandler(); }
				close();
			} else {
				CSRUtil.linkBack();
			}
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC23310" , "收息帳務", "理則型房貸帳務明細表查詢 " );
		
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			// 監聽
			button.doQuery();
			$("BTN_BACK").observe('click', button.doBack);		
			PageUI.resize();	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <input type="hidden" id="QUERY_TYPE" value="${QUERY_TYPE}" />
	<tr>
		<td class='tbYellow0' width='15%' colspan='2' align="center" >
			<b><span  id="CONDITION" ></span></b> 
		</td>
		
	</tr>
    <tr>
		<td class='tbYellow' width='5%' align="center">
			帳務日期
		</td>
		<td class='tbYellow2' width='15%'>
			<span  id="ACNT_DATE" >   </span> 
		</td>
	</tr>
</table>
  
<table id='grid' width='100%'></table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    <tr>   
        <td  width='5%' colspan="2" align="center">
	        <input type="button" class="button" id="BTN_BACK" value="回上一頁"/>	
	    </td>
	</tr>
</table>
    
	
	
</form>

</body>
</html>	