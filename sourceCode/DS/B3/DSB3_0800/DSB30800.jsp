<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30800.jsp
作者：王文進
功能：火險招攬資格查詢。
完成：2012/05/17

[20240613]
難字調整
高強禾
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
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
<script type='text/javascript'>

// 產生畫面物件
var DSB30800 = new DSB30800();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30800.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30800(){
	
	var grid;
	<%--[20201130]外網多筆個資遮蔽
	var preTd;
	var preAGENT_ID_MASK;
	--%>
	var columnLoad = [
		[ //【B區】火險招攬資格
			<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
			{ header: "個資顯示", key: "",
				render:function(rec, val, sn){
					var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
					button.update("點我");
					button.observe('click', function(){
						if(preTd){
							grid.setValueToTD(preTd, "AGENT_ID_MASK", preAGENT_ID_MASK);
						}
						preTd = this;
						preAGENT_ID_MASK = rec['AGENT_ID_MASK'];
						grid.setValueToTD(this, "AGENT_ID_MASK", rec['AGENT_ID']);
					});
        			return button;
				}
			},--%>
			{header: "單位代號",key: "DIV_NO"},			
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			{header: "經手人ID",key: "AGENT_ID"},
			{header: "登錄字號",key: "AGENT_NO"},
			{header: "職級",key: "POS_NAME"},
			<%-- [20240613] 難字調整：姓名 --%>
			{header: "姓名",key: "AGENT_NAME",attrs:{ style:"font-family:'EUDC'" }},
			{header: "招攬資格",key: "IS_LOGIN"}
		],
		
		//【B區】火險招攬資格異動紀錄
		[
			<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
			{ header: "個資顯示", key: "",
				render:function(rec, val, sn){
					var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
					button.update("點我");
					button.observe('click', function(){
						if(preTd){
							grid.setValueToTD(preTd, "AGENT_ID_MASK", preAGENT_ID_MASK);
						}
						preTd = this;
						preAGENT_ID_MASK = rec['AGENT_ID_MASK'];
						grid.setValueToTD(this, "AGENT_ID_MASK", rec['AGENT_ID']);
					});
        			return button;
				}
			},--%>
			{header: "單位代號",key: "DIV_NO"},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			{header: "經手人ID",key: "AGENT_ID"},
			{header: "職級",key: "POS_NAME"},
			<%-- [20240613] 難字調整：姓名 --%>
			{header: "姓名",key: "AGENT_NAME",attrs:{ style:"font-family:'EUDC'" }},
			{header: "異動日",key: "CHG_DATE",
				render : function (rec , val){
					return Date.toInputROC(val || "","/");
				}			
			},
			{header: "異動狀態",key: "STATUS"}
		]		
	];
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'validateQUERY_SELECT1',  '需符合10碼自然人身份證號碼格式', 
				//請輸入查詢條件再執行查詢
				function(v){				
					// 經手人ID
					return 	$('QUERY_SELECT1').checked && !validation.checkROCID(v) ? false : true;
				}
			],
			[ 'validateQUERY_SELECT2',  '總公司及行政單位代號請輸入２～５碼', 
				//請輸入查詢條件再執行查詢
				function(v){				
					// 單位代號 
					return 	$('QUERY_SELECT2').checked && !isNaN(v) && v.length<2 ? false : true;
				}
			],
			[ 'validateQUERY_SELECT2_1',  '區部請輸入前２碼，業務單位請輸入前３碼，獨立課請輸入前４碼。', 
				//請輸入查詢條件再執行查詢
				function(v){				
					// 單位代號 
					return 	$('QUERY_SELECT2').checked && isNaN(v) && (v.length==1 || v.length==5) ? false : true;
				}
			],
			[ 'validateQUERY_SELECT3',  '銀行單位代號請輸入２～５碼', 
				//請輸入查詢條件再執行查詢
				function(v){
					// 銀行單位代號 
					return 	$('QUERY_SELECT3').checked && !isNaN(v) && v.length==1 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validateQUERY_SELECT1" , { id: "AGENT_ID" } );
		valid1.define( "validateQUERY_SELECT2" , { id: "DIV_NO" } );
		valid1.define( "validateQUERY_SELECT2_1" , { id: "DIV_NO" } );
		valid1.define( "validateQUERY_SELECT3" , { id: "DIV_NO_BANK" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB3_0800/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var sendRecord = makeRecord();
			
			//preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
			
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					grid.load(resp.rtnList);	
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		}
	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {}
		if($('QUERY_TYPE1').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE1').value // 資格查詢
		}else if($('QUERY_TYPE2').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE2').value // 異動查詢
		}
		if($('QUERY_SELECT1').checked){
			$('AGENT_ID').value = $('AGENT_ID').value.toUpperCase();
			sendRecord.AGENT_ID	= $('AGENT_ID').value // 經手人ID
		}else if($('QUERY_SELECT2').checked){
			$('DIV_NO').value = $('DIV_NO').value.toUpperCase();
			sendRecord.DIV_NO	= $('DIV_NO').value // 單位代號
		}else if($('QUERY_SELECT3').checked){
			$('DIV_NO_BANK').value = $('DIV_NO_BANK').value.toUpperCase();
			sendRecord.DIV_NO_BANK	= $('DIV_NO_BANK').value // 銀行單位代號
		}
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB30800", "火險作業", "火險招攬資格查詢");			
				grid = new TableUI ( {
						table: $("grid"), pageSize: 20, allSortable:true ,					
						<%-- [20240613] 難字調整 --%>
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:	columnLoad[0]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );	

				$("QUERY_TYPE1").observe("click", 
					function(event){
						grid = new TableUI ( {
							table: $("grid"), pageSize: 20, allSortable:true ,					
							<%-- [20240613] 難字調整 --%>
							pageChange: function() {
								if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
							},
							column:	columnLoad[0]
						});
				});
				
				$("QUERY_TYPE2").observe("click", 
					function(event){
						grid = new TableUI ( {
							table: $("grid"), pageSize: 20, allSortable:true ,					
							<%-- [20240613] 難字調整 --%>
							pageChange: function() {
								if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
							},
							column:	columnLoad[1]
						});
				});			
				
				initValidation();	
				
				fix();

				displayMessage();	

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" rowspan="3" width="8%">
					查詢方式
				</td>
				<td class="tbYellow" rowspan="3" width="20%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE1' value=1 checked>資格查詢
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE2' value=2 >異動查詢
				</td>
				<td class="tbYellow">
					<input type='radio' name='QUERY_SELECT' id="QUERY_SELECT1" checked>經手人ＩＤ
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" size="15" maxlength="10" id="AGENT_ID" value="">
				</td>
				<td class="tbYellow2" align="center" rowspan="3">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">
					<input type='radio' name='QUERY_SELECT' id="QUERY_SELECT2" >單位代號
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" size="5" maxlength="5" id="DIV_NO" value="">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">
					<input type='radio' name='QUERY_SELECT' id="QUERY_SELECT3" >銀行單位代號
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" size="5" maxlength="5" id="DIV_NO_BANK" value="">
				</td>
			</tr>    
		</table>
	</form>	
	<table id='grid' width="100%"></table>	
</body>
</html>