<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11202.jsp
功能：債權查詢作業
作者：卓達瑋
完成：2013/08/13
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript">


Event.observe(window, 'load', new DSE11202().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11202(){
	
    var LOAN_ID = '${LOAN_ID}';//貸款帳號
    var REFER_ID = '${REFER_ID}';//原貸帳號
    var grid;
	var grid1;
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 		
			B0226 : 'BTN_DSH0',
			B0227 : 'BTN_DSE105',
			B0228 : 'BTN_DSE118'							
		};
		<dz:grantButtons FUNC_ID ="DSE11202"/>
	}
	

	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1202/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	
	//各種action
	var actions = {
		//超連結1
		POP_UP1 :function(event){
			//alert(event.target.id);
			var id= event.target.id;
			var strlink;
			if(id=='BTN_DSH0'){
			    strlink='<%=dispatcher%>/DSH0_0200/prompt';
			}else if(id=='BTN_DSF0'){
			    strlink='<%=dispatcher%>/DSF0_0210/prompt';
			}else if(id=='BTN_DSE118'){
			    strlink='<%=dispatcher%>/DSE1_1800/prompt'; 
			}
			
			popupWin.windowOpen(strlink,{
				parameters : { 
					'LOAN_ID' : LOAN_ID	
				}
			});
			
		},
		//超連結2
		POP_UP2 :function(event){
			//alert(event.target.id);
			var id= event.target.id;
			var strlink;
			if(id=='BTN_DSE101'){
			    strlink='<%=dispatcher%>/DSE1_0100/prompt';
			}else if(id=='BTN_DSE105'){
			    strlink='<%=dispatcher%>/DSE1_0500/prompt';
			}
			popupWin.windowOpen(strlink,{
				parameters : { 
					'REFER_ID' : REFER_ID	
				}
			});
			
		}
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){						
                    var rtnList=resp.rtnList||[];
					var rtnList2=resp.rtnList2||[];
					//處理序號
					
					if(rtnList.length > 0 ){
						grid.load(rtnList,[{text: '' , value:{
					    	BALC_AMT:"合計:",
							TOT_AMT: '<div align = "right">' + MoneyFormat(resp.SUM_TOT_AMT) +'<div>'					    
						}}]);	
					}else{
						grid.load([]);
					}			
					
					if(rtnList2.length > 0 ){					
						grid1.load(rtnList2,[{text: '' , value:{
							UNDIS_FEE:"合計:",
							TOT_AMT2:'<div align = "right">' +MoneyFormat(resp.SUM_TOT_AMT2)+'<div>'							
						}}]);
					}else{
						grid1.load([]);
					}
				},
				function(resp){
					grid.load([]);
                    grid1.load([]);
			    }
			);

		}
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11202','法務件','債權查詢作業',1,true);
			
			//產生 Grid 物件	
			grid = new TableUI (
				{ table: $('grid'), pageSize: 10, 
				  allSortable:false, 	  				  
			  	  column : [					
					{header : '貸款帳號', key : 'LOAN_ID'},
					{header : '最新應繳日', key : 'NEXT_PAYDT'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '利率%', key : 'RATE'},
					{header : '本金餘額', key : 'REMAIN_AMT',attrs:{align :"right"}                
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					
					},
					{header : '利息', key : 'INT',attrs:{align :"right"}                
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					
					},	
					{header : '違約金', key : 'DEFAULT_AMT',attrs:{align :"right"}                
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					
					},										
					{header : '管理費用', key : 'EXPENSE_AMT',attrs:{align :"right"}
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '暫收款項', key : 'BALC_AMT',attrs:{align :"right"}
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '小計', key : 'TOT_AMT',attrs:{align :"right"}
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					}
				]
			});
						
						
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 20, allSortable:false, 	
				column : [					
					{header : '貸款帳號', key : 'LOAN_ID'},
					{header : '拍定日期', key : 'SALE_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '利率%', key : 'YEAR_RATE'},
					{header : '拍賣不足金額', key : 'SHORT_AMT',attrs:{align :"right"}  
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '未受分配利息', key : 'UNDIS_INT',attrs:{align :"right"}  
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '未受分配違約金', key : 'UNDIS_RENEGE',attrs:{align :"right"}  
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '未受分配程序費用', key : 'UNDIS_FEE',attrs:{align :"right"}  
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
                    {header : '小計', key : 'TOT_AMT2',attrs:{align :"right"}  
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					}					
				]
			});						
						
							
			//按鈕事件監聽
			$('BTN_DSH0').observe('click', function(event){actions.POP_UP1(event)}); 
			$('BTN_DSE101').observe('click', function(event){actions.POP_UP2(event)}); 
			$('BTN_DSE105').observe('click', function(event){actions.POP_UP2(event)}); 
			$('BTN_DSF0').observe('click', function(event){actions.POP_UP1(event)}); 
			$('BTN_DSE118').observe('click', function(event){actions.POP_UP1(event)}); 
			
			buttonAuth();//按鈕授權

			ajaxRequest.closeSuccMsg();
			buttons.doQuery();//初始查詢
		
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	    <div align = "center">
			<tr>
				<td >
					<input id = "BTN_DSH0" type = "button" class = "button" value = "繳息試算"   />						
					<input id = "BTN_DSE101" type = "button" class = "button" value = "法院陳報債權試算"   />						
					<input id = "BTN_DSE105" type = "button" class = "button" value = "陳報債權"   />
					<input id = "BTN_DSF0" type = "button" class = "button" value = "影像檔 "   />
					<input id = "BTN_DSE118" type = "button" class = "button" value = "拍賣不足債權試算"   />
				</td>
			</tr>
			<div class="tbYellow0" align="center">
		        <tr class="tbYellow0" align="center">
			       <td><b>有效件</b></td>					
		        </tr>			        
		        <table id = "grid" ></table>    		        		
			</div>			            
		</div>
		<div class="tbYellow0" align="center">
		<tr>
			<td><b>拍不足件</b></td>
					
		</tr>	
		    <table id = "grid1"></table>
		</div>
		
</form>	
</body>
</html>