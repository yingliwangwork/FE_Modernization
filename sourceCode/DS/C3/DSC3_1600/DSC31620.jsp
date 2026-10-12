<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!--
程式：DSC31620.jsp
功能：入帳結果顯示、單據列印
作者：卓達瑋
完成：2013/09/
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/javascript">


Event.observe(window, 'load', new DSC31620().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31620(){
    var ISTIC='${ISTIC}';
	var PAY_TYPE='${PAY_TYPE}';
	var RECEIPT_SERNO='${RECEIPT_SERNO}';
    var INPUT_DEPT='${INPUT_DEPT}';
	var INPUT_ID='${INPUT_ID}';
	var grid; 
	var BillList;
	var SPEC = '${SPEC}';
 	var isXZeroPayOff='${isXZeroPayOff}';   
	

	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1620/" + actionName,
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
	var gridList=[
	             //若為現金給付(ISTIC=”0”)
			    [					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
					    	return actions.gridFmtRender(value);
					    	/*
					    	if("4"==record.PAY_KIND){
					    		return 0;
					    	}else{
					    		return actions.gridFmtRender(value);
					    	}
					    	*/							
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
					    	/*
					    	if("4"==record.PAY_KIND){
					    		return 0;
					    	}else{
					    		return actions.gridFmtRender(value);
					    	}
					    	*/		
						}
					}
				],
				//為匯款單給付(ISTIC=”3”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
					    	/*
					    	if("4"==record.PAY_KIND){
					    		return 0;
					    	}else{
					    		return actions.gridFmtRender(value);
					    	}
					    	*/		
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
					    	/*
					    	if("4"==record.PAY_KIND){
					    		return 0;
					    	}else{
					    		return actions.gridFmtRender(value);
					    	}
					    	*/		
						}
					},
					{header:"補現金額",key:"CASH_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"繳匯款單金額",key:"TRADE_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
					,{header:"匯款單組號",key:"REMIT_GROUP"}
					//,{header:"匯款金額",key:"PAY_AMTS"}
					
				],
				//為票據給付(ISTIC=”1,2,4”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					   render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"補現金額",key:"CASH_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"繳票金額",key:"TRADE_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
					//{header:"行庫代號",key:"BANK_CODE"},
					//{header:"票據單號",key:"CHECK_NOS"},
					//{header:"票據金額",key:"PAY_AMTS"},
					
				],
				//為電匯給付(ISTIC=”7”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
					//,{header:"繳款金額",key:"TRADE_AMTS",
					//    render: function (record,value){
					//		return actions.gridFmtRender(value);
					//	}
					//},
					//{header:"電匯序號",key:"TRANS_NOS"},
					//{header:"電匯金額",key:"PAY_AMTS"}
				],
				//為劃撥給付(ISTIC=”5”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"繳款金額",key:"TRADE_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"劃撥序號",key:"TRANS_NOS"},
					{header:"劃撥金額",key:"PAY_AMTS"}
				],
				//為人工暫收給付(ISTIC=”C”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					   render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
					//,{header:"暫應收編號",key:"BALC_NOS"},
					//{header:"沖人工暫收金額",key:"CB_AMT"}
				],
				//異常入帳給付(ISTIC=”E”)
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					   render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"ATM手續費筆數",key:"CHARGE_CNT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
				],
				//異常入帳給付(ISTIC=”E”)PAY_TYPE!=”E”
				[					
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"繳款期數",key:"PAY_TERM",
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
					{header:"應繳金額",key:"DUTY_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"實繳金額",key:"REAL_PAYMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					},
					{header:"暫應收款",key:"BALC_AMT",
					    render: function (record,value){
							return actions.gridFmtRender(value);
						}
					}
				]
	]
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1620/" + actionName,
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
	
	//各種action
	var actions = {
	    //金錢格式化
		gridFmtRender :function(value) { 
			return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : ''; 
	    },
		//table UI 共同方法
		gridtable : function(i,TLE){
		    grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20,title:TLE,			
			column:gridList[i]});

		}
		
	}; 
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		

			if(ISTIC=='0'){
				actions.gridtable(0,"現金匯款入帳結果");	
			}else if(ISTIC=='3'){
				actions.gridtable(1,"匯款單入帳結果");	
			}else if(ISTIC=='1'||ISTIC=='2'||ISTIC=='4'){
				actions.gridtable(2,"票據入帳結果");
			}else if(ISTIC=='7'){
				actions.gridtable(3,"電匯入帳結果");
			}else if(ISTIC=='5'){
				actions.gridtable(4,"劃撥入帳結果");
			}else if(ISTIC=='C'){
				if(PAY_TYPE=='E'){
					actions.gridtable(6,"ATM沖人工入帳結果");
				} else {
					actions.gridtable(5,"人工暫收給付入帳結果");
				}
			}else if(ISTIC=='E'){
				if(PAY_TYPE=='E'){
					actions.gridtable(6,"ATM異常入帳入帳結果");
				}else{
					 actions.gridtable(7,"異常入帳入帳結果");
				}
			}
			//ajaxPost( 'query' , { BillList : Object.toJSON(BillList),'PAY_TYPE':PAY_TYPE,'RECEIPT_SERNO':RECEIPT_SERNO,'ISTIC':ISTIC,'INPUT_ID':INPUT_ID,'INPUT_DEPT':INPUT_DEPT},
			ajaxPost( 'query' , { BillList : Object.toJSON(BillList),'PAY_TYPE':PAY_TYPE,'ISTIC':ISTIC},
				function(resp){						
					var rtnList=resp.BillList||[];
					grid.load(rtnList);
				},
				function(resp){
				    grid.load([]);
			    }
			);
		},
		
		// 列印
		doPrint: function(record) {           
			//RPTUtil.executePrintByLink('print' , {	'BillList': Object.toJSON(grid.getAllRecords())}, true );
			ajaxPost( 'print' , { 'info' : Object.toJSON(record) ,'RECEIPT_SERNO':RECEIPT_SERNO},
						function(resp){			
							RPTUtil.executePrintByResponse(resp, true);
						}
					);
		},
		// 列印
		doPrintALL: function() {           
			//RPTUtil.executePrintByLink('print' , {	'BillList': Object.toJSON(grid.getAllRecords())}, true );
			RPTUtil.downloadFile('${dispatcher}/DSC3_1620/printall' , { 'info' : Object.toJSON(grid.getAllRecords()) ,'RECEIPT_SERNO':RECEIPT_SERNO}, true );			
			/*ajaxPost( 'printall' , { 'info' : Object.toJSON(grid.getAllRecords()) ,'RECEIPT_SERNO':RECEIPT_SERNO},
						function(resp){			
							RPTUtil.executePrintByResponse(resp, true);
						}
					);*/
		}
	
	};

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSC31620','收息作業','入帳確認');

			// 查詢
		    $('BTN_PRINT').observe('click', buttons.doPrintALL);
		    //if(!(PAY_TYPE=="1" ||PAY_TYPE=="7" && (ISTIC=="7" || ISTIC=="C")||PAY_TYPE=="4")){
			if(!(SPEC=="0" && (PAY_TYPE=="1" ||PAY_TYPE=="7"))){
		    	$('tableA').hide();
		    } else if (isXZeroPayOff == "Y"){
				$('tableA').hide();
			}
		    			
			BillList = ${BillList};
			buttons.doQuery();			
			
			PageUI.resize();

			displayMessage();				
		}
	}
}
</script>
</head>
<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	
	<table id='tableA' name='tableA' width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		
		<tr>
		    <td > <input align="right" id="BTN_PRINT" type="button"
			class="button" value="單據列印"></td>
		     
		</tr>

    </table>
	<table id = "grid" ></table>
</form>	
</body>
</html>