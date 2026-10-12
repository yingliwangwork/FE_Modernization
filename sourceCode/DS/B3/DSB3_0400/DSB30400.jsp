
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30400.jsp
作者：張智翔
功能：火險查詢作業。
完成：2012/04/23

[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖

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

<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
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
var DSB30400 = new DSB30400();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30400.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30400(){
	//檢核變數
	var valid1;	
	<%--[20201130]外網多筆個資遮蔽
	var preTd;
	var preBORROW_NAME_MASK, preGAGE_ADDR_MASK;
	--%>
	var lastQueryCondition = {};
	
	var columnLoad = [
		[ //【B區】清單區塊				
			<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
			{ header: "個資顯示", key: "",
				render:function(rec, val, sn){
					var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
					button.update("點我");
					button.observe('click', function(){
						if(preTd){
							grid.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
							grid.setValueToTD(preTd, "GAGE_ADDR_MASK", preGAGE_ADDR_MASK);
						}
						preTd = this;
						preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
						preGAGE_ADDR_MASK = rec['GAGE_ADDR_MASK'];
						grid.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
						grid.setValueToTD(this, "GAGE_ADDR_MASK", rec['GAGE_ADDR']);
					});
        			return button;
				},
				attrs:{rowSpan:2}
			},--%>
			{header: "貸款帳號",key: "LOAN_ID"},			
			{header: "火單狀態",key: "ISSUE_CODE_NM"},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火單/批單號碼",key: "FIREINSU_POLNO"},
			{header: "使用用途",key: "REAL_USE"},
			{header: "火險保額(萬元)",key: "FIREINSU_AMT_FT",
				render : function(rec , val){
					return val ? MoneyFormat(val) : 0
				}
			},
			{header: "地震險保額(萬元)",key: "EARTH_AMT_FT",
				render : function(rec , val){
					return val ? MoneyFormat(val) : 0
				}
			},
			{header: "火險迄日",key: "FIREINSU_ENDDT",
				render : function (rec , val){
					return Date.toInputROC(val || "","/");
				}
			
			},
			{header: "投保公司",key: "FIREINSU_COMPANY_NM"},
			{header: "受理編號",key: "APPLY_ID",                        
				render : function(rec , val){
					if(val){
						var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB3_0200/prompt',
								APPLY_ID : val,
								ACTION_TYPE :  "Q"
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}
				}			
			},
			{header: "火單序號",key: "SEQ_NO"},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},
			{header: "火險種類",key: "NOTE_NM"},	
			{header: "經手人單位",key: "APPLY_DIV_NAME"},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},			
			{header: "經手人手機",key: "TEL_MOBILE"},			
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }}			
		],
		[ 	
			<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
			{ header: "個資顯示", key: "",
				render:function(rec, val, sn){
					var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
					button.update("點我");
					button.observe('click', function(){
						if(preTd){
							grid.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
							grid.setValueToTD(preTd, "GAGE_ADDR_MASK", preGAGE_ADDR_MASK);
						}
						preTd = this;
						preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
						preGAGE_ADDR_MASK = rec['GAGE_ADDR_MASK'];
						grid.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
						grid.setValueToTD(this, "GAGE_ADDR_MASK", rec['GAGE_ADDR_MASK']);
					});
        			return button;
				},
				attrs:{rowSpan:2}
			},--%>
			{header: "貸款帳號",key: "LOAN_ID"},		
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火險種類",key: "NOTE_NM"},	
			{header: "匯款日期",key: "REMIT1_DATE",
				render : function (rec , val){
					return Date.toInputROC(val || "","/");
				}
			
			},
			{header: "經手人單位",key: "APPLY_DIV_NAME"},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},
			
			{header: "受理編號",key: "APPLY_ID",                        
				render : function(rec , val){
					if(val){
						var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 	
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB3_0200/prompt',
								APPLY_ID : val,
								ACTION_TYPE :  "Q"
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');									
						});		
						return link;
					}else{
						return "";
					}
				}			
			},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},				
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火單狀態",key: "ISSUE_CODE_NM"},
			{header: "經手人手機",key: "TEL_MOBILE"}		
		],
		[
			<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
			{ header: "個資顯示", key: "",
				render:function(rec, val, sn){
					var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
					button.update("點我");
					button.observe('click', function(){
						if(preTd){
							grid.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
							grid.setValueToTD(preTd, "GAGE_ADDR_MASK", preGAGE_ADDR_MASK);
						}
						preTd = this;
						preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
						preGAGE_ADDR_MASK = rec['GAGE_ADDR_MASK'];
						grid.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
						grid.setValueToTD(this, "GAGE_ADDR_MASK", rec['GAGE_ADDR_MASK']);
					});
        			return button;
				},
				attrs:{rowSpan:2}
			},--%>
			{header: "貸款帳號",key: "LOAN_ID"},
			{header: "原貸帳號",key: "REFER_ID"},
			{header: "續保處理狀態",key: "RENEW_STATUS_NM",attrs : { rowSpan : 2},
				render : function(rec , val){
					if(rec.RENEW_STATUS_LINK==='1'){
						var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 												
							popupWin.popup({
								'src':'<%=dispatcher%>/DSD1_0410/prompt',
								'parameters': {'LOAN_ID':rec.LOAN_ID,'FUNC_ID':'DSB30400','MOBILE':rec.MOBILE}
							});		
						});		
						return link;
					}else{
						return val;
					} 
				}	
			},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "借款人ID",key: "BORROW_ID"},
			{header: "匯款日期",key: "REMIT1_DATE",
				render : function (rec , val){
					return Date.toInputROC(val || "","/");
				}			
			},
			{header: "是否為贈送險",key: "INSUFREE_CODE_NM"},
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "INFO_AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "受理編號",key: "APPLY_ID",                        
				render : function(rec , val){
					if(val){
						var link = new Element("a" , { href : "#" } ).update(val);
						link.observe( 'click', function (event){ 						
							var LP_JSON = {
								action :'<%=dispatcher%>/DSB3_0200/prompt',
								APPLY_ID : val,
								ACTION_TYPE :  "Q"
							}									
							CSRUtil.linkTo(LP_JSON , 'form1');			
						});		
						return link;
					}else{
						return "";
					}
				}	
			},
			{header: "契約狀況",key: "LOAN_STATUS_NM"},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},
			{header: "原貸餘額",key: "PRINCIPAL",
				render : function(rec , val){
					return val ? MoneyFormat(val) : 0
				}
			},
			{header: "火單狀態",key: "STATUS_NM"},
			{header: "經手人單位",key: "INFO_AGENT_DIV_NAME"},
			{header: "經手人手機",key: "INFO_AGENT_TEL"}
		]		
	];
	
	<%--[20201130]外網多筆個資遮蔽_匯出XLS的格式不需要個資顯示，並且借款人需要顯示全部姓名 --%>
	var columnLoad2 = [
		[ //【B區】清單區塊				
			{header: "貸款帳號",key: "LOAN_ID"},			
			{header: "火單狀態",key: "ISSUE_CODE_NM"},
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火單/批單號碼",key: "FIREINSU_POLNO"},
			{header: "使用用途",key: "REAL_USE"},
			{header: "火險保額(萬元)",key: "FIREINSU_AMT_FT"},
			{header: "地震險保額(萬元)",key: "EARTH_AMT_FT"},
			{header: "火險迄日",key: "FIREINSU_ENDDT"},
			{header: "投保公司",key: "FIREINSU_COMPANY_NM"},
			{header: "受理編號",key: "APPLY_ID"},
			{header: "火單序號",key: "SEQ_NO"},
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},
			{header: "火險種類",key: "NOTE_NM"},	
			{header: "經手人單位",key: "APPLY_DIV_NAME"},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},			
			{header: "經手人手機",key: "TEL_MOBILE"},
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }}			
		],
		[ 	
			{header: "貸款帳號",key: "LOAN_ID"},		
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火險種類",key: "NOTE_NM"},	
			{header: "匯款日期",key: "REMIT1_DATE"},
			{header: "經手人單位",key: "APPLY_DIV_NAME", attrs:{ style:"font-family:'EUDC'" }},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "AGENT_NAME"},	
			{header: "受理編號",key: "APPLY_ID"},
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},				
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "火單狀態",key: "ISSUE_CODE_NM"},
			{header: "經手人手機",key: "TEL_MOBILE"}		
		],
		[
			{header: "貸款帳號",key: "LOAN_ID"},
			{header: "原貸帳號",key: "REFER_ID"},
			{header: "續保處理狀態",key: "RENEW_STATUS_NM",attrs : { rowSpan : 2}},
			<%-- [20240613] 難字調整：借款人姓名 --%>
			{header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "借款人ID",key: "BORROW_ID"},
			{header: "匯款日期",key: "REMIT1_DATE"},
			{header: "是否為贈送險",key: "INSUFREE_CODE_NM"},
			<%-- [20240613] 難字調整：徵信人員 --%>
			{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
			<%-- [20240613] 難字調整：經手人姓名 --%>
			{header: "經手人姓名",key: "INFO_AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},
			{header: "受理編號",key: "APPLY_ID"},
			{header: "契約狀況",key: "LOAN_STATUS_NM"},
			<%-- [20240613] 難字調整：擔保品地址 --%>
			{header: "擔保品地址",key: "GAGE_ADDR", attrs : { colSpan : 2, style:"font-family:'EUDC'"}},
			{header: "原貸餘額",key: "PRINCIPAL"},
			{header: "火單狀態",key: "STATUS_NM"},
			{header: "經手人單位",key: "INFO_AGENT_DIV_NAME"},
			{header: "經手人手機",key: "INFO_AGENT_TEL"}
		]		
	];
	
	var grid;
	var grid2
	
	//目前table的的index
	var currentTableindex = 0 ;
	
	//要load進去的 table Index 
	var changeIndex ;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'validateQUERY_TYPE1',  '請輸入查詢條件再執行查詢', 
			//請輸入查詢條件再執行查詢
			function(v){				
				var QUERY_TYPE1 = $("QUERY_TYPE1").value;
				var QUERY1_SELECT = $("QUERY1_SELECT").value;
				return 	(QUERY_TYPE1 === "1" && QUERY1_SELECT !=="" && v ==="" )? false : true;
				
			}],
			[ 'validateCRED_DEPT',  '請選擇承辦科別再執行查詢', 
			//請輸入查詢條件再執行查詢
			function(v){				
				var QUERY_TYPE1 = $("QUERY_TYPE1").value;
				var QUERY_TYPE2 = $("QUERY_TYPE2").value;
				var QUERY1_SELECT = $("QUERY1_SELECT").value;
				
				return 	( (QUERY_TYPE1 === "1" && QUERY1_SELECT ==="" && v === "") || (QUERY_TYPE2 === "1" && v === "") )? false : true;
				
			}],			
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validate-ROCDate" , { id: "FIREINSU_ENDDT_STR" } );	
		valid1.define( "validate-ROCDate" , { id: "FIREINSU_ENDDT_END" } );	
		valid1.define( "validateCRED_DEPT" , { id: "CRED_DEPT" } );	
		valid1.define( "validateQUERY_TYPE1" , { id: "QUERY1_INPUT" } );				
		valid1.define( "validate-ROCDate-Interval" , [{ id : "FIREINSU_ENDDT_STR" },{ id: "FIREINSU_ENDDT_END" }] );	
	}    

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB3_0400/" + actionName,
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
			
			lastQueryCondition = makeRecord();		
			
			if(!validData(lastQueryCondition)){
				return;
			}
			
			preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
			
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(lastQueryCondition)	},
				function(resp){	
					makeTablue(lastQueryCondition);
					grid.load(resp.rtnList);	
				},
				function(resp){	
					makeTablue(lastQueryCondition);
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		},				
		
		//根據條件連動ajax
		/*doCRED_DEPT_Ajax : function (value , type , LP_JSON){			
			if(value !== "2" && value !== ""){//全部及總公司就不做ajax
				ajaxPost( 'makeSRV' , {CRED_DEPT : value },
					function(resp){
						appendList(resp.SRV_LIST , $("SRV_DEPT"));
						if(type === "linkBack"){
							$('SRV_DEPT').value = LP_JSON.BQ_ARG.SRV_DEPT;		
							buttons.doQuery();   
						}
					}
				);
			}else{
				updateList($("SRV_DEPT"));//總公司就把服務中心清掉
			}
		},*/
		
		//匯出
		doExport : function(event){	
			
			if(grid.getAllRecords().length == 0 ){
				alert('請先查詢再匯出出');
				return;
			}
			
			//取得當前的條件與欄位
			var condition = makeRecord();
			
			for(key in condition){
				if(condition[key] != lastQueryCondition[key]){
					alert('匯出條件與查詢時不同，請先重新查詢再匯出');
					return;				
				}			
			}	
			
			var sendObj = {
				sendRecord : Object.toJSON(lastQueryCondition),
				gridJSON : grid2.getXlsSettingJSON("火險查詢作業")			
			}
		
			RPTUtil.executeCreateCsvFile("<%=dispatcher%>/DSB3_0400/export", sendObj );			
		
		}
	};
	
	//觸發的動作
	var action = {
		
		//查詢方式1-查詢項目 觸發輸入欄位 QUERY1_INPUT
		doquery1 : function(value){			
			if(value === ""){
				$('QUERY1_INPUT').value = "";
				$('QUERY1_INPUT').readOnly = true;			
			}else{
				$('QUERY1_INPUT').readOnly = false;			
			}
		}	
	};
	
	//依照狀況決定是否要產生新的table
	function makeTablue(sendRecord){
		var QUERY_TYPE = sendRecord.QUERY_TYPE; //查詢方式
		var QUERY2_SELECT = sendRecord.QUERY2_SELECT; //其他查詢方式的選項
		
		//一開始都是0,當選其他("2") , 且內容是(1 已匯款火險未歸檔   或   當選其他("2") , 且內容是(2 火險未完成續保資料	
		if( QUERY_TYPE === "2" && QUERY2_SELECT === "1" ){	
			changeIndex = 1;		
		}else if( QUERY_TYPE === "2" && QUERY2_SELECT === "2" ){
		    changeIndex = 2;
		}else{
			changeIndex = 0;
		}
		
		//當目前table與要查詢的index不同時,new一個新Table UI
		if(currentTableindex !== changeIndex){
			grid = new TableUI ( {
				table: $("grid"), pageSize: 10, allSortable:true , split: ['APPLY_ID'],				
				<%-- [20240613] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:	columnLoad[changeIndex]
			});	
			<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
			grid2 = new TableUI ( {
				table: $("grid2"), pageSize: 10, allSortable:true , split: ['APPLY_ID'],				
				<%-- [20240613] 難字調整 --%>
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:	columnLoad2[changeIndex]
			});	
			currentTableindex = changeIndex;
		}
	}
	
	//檢查對應資料的長度
	function validData(sendRecord){
	
		var QUERY1_INPUT  = sendRecord.QUERY1_INPUT;
		var QUERY1_SELECT  = sendRecord.QUERY1_SELECT;
		
		if(QUERY1_INPUT!== ""){
			var length = 0 ;
			var errMsg = "";
			if (QUERY1_SELECT==="1") {
				//受理單位
				errMsg = "受理單位";
				length = 5;
			} else if (QUERY1_SELECT==="2") {
				//受理編號
				errMsg = "受理編號";
				length = 11;
			} else if (QUERY1_SELECT==="3") {
				//貸款帳號
				errMsg = "貸款帳號";
				length = 11;
			} else if (QUERY1_SELECT==="4") {
				//火險保單號碼
				errMsg = "火險保單號碼";
				length = 20;
			} else if (QUERY1_SELECT==="6") {
				//借款人ID
				errMsg = "借款人ID";
				length = 10;
			} else if (QUERY1_SELECT==="7") {
				//借款人姓名
				errMsg = "借款人姓名";
				length = 60;
			} else if (QUERY1_SELECT==="8") {
				//經手人ID
				errMsg = "經手人ID";
				length = 10;
			} else if (QUERY1_SELECT==="9") {
				//原貸帳號
				errMsg = "原貸帳號";
				length = 11;
			} else if (QUERY1_SELECT==="10") {
				//原貸帳號
				errMsg = "批單號碼";
				length = 12;
			} 		
			if(QUERY1_INPUT.length > length){
				alert(errMsg+"超出輸入長度範圍，請輸入正確對應資料長度");
				return false;
			}			
		}
		return true;		
	}
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {
			CRED_DEPT	: $('CRED_DEPT').value ,// 承辦科別
			//SRV_DEPT	: $('SRV_DEPT').value ,// 服務中心
			FIREINSU_ENDDT_STR	: toY2K($('FIREINSU_ENDDT_STR').value) ,// 火險到期年月起
			FIREINSU_ENDDT_END	: toY2K($('FIREINSU_ENDDT_END').value) ,// 火險到期年月迄	
			//FIREINSU_TYPE	: $('FIREINSU_TYPE').value ,// 火險類別		
			//ISSUE_CODE	: $('ISSUE_CODE').value ,// 火險狀態
			QUERY_TYPE	: $$('#tableA input:checked[type=radio]')[0].value,// 查詢方式
			QUERY1_SELECT	: $('QUERY1_SELECT').value ,// 查詢方式1-查詢項目
			QUERY1_INPUT	: $('QUERY1_INPUT').value ,// 查詢方式1-查詢條件
			QUERY2_SELECT	: $('QUERY2_SELECT').value // 查詢方式2-查詢條件			
		}
		return sendRecord;	
	}			
	
	
	
	//將List增加到下拉選單中
	/*function appendList(list , target){		
		updateList(target);
		//加入List			
		if(list.length > 0){			
			for(var i = 0; i < list.length; i++){ 
				target.options.add(new Option(list[i]['SRV_DEPT_NAME'], list[i]['SER_DEPT_NO'])); 
			}
		}
	}*/

	//將收下拉選單清除,加入請選擇 , target為要清除的dom物件
	/*function updateList(target){
		//先清除
		target.update();
		//全部
		target.options.add(new Option( "全部" , "")); 
		
	}*/
	
	//選單,輸入控制
	function buttonsControl(key){	
		//全部disabled
		var input = $$('.all');		
		input.each(
			function(elem){				
				elem.disable();				
			}
		)
		var enableName;
		var classNamekey;
		//依照需求打開功能
		if(key == 1){		
			action.doquery1("");
			enableName = '.type1';			
		}else if(key == 2 ){
			enableName = '.type2';			
		}
		
		//將功能下拉選單打開			
		var func = $$(enableName);		
			func.each(
				function(elem){
					elem.enable();
			}
		)
		
		//將被disabled欄位清空
		var hide = $$('#tableA :disabled');		
		hide.each(
			function(elem){
				if(elem.id === 'QUERY2_SELECT'){
					elem.value = '1';
				}else{
					elem.value = '';
				}
			}
		)	
	}
	
	
	
	//動態產生radio button
	function makeRadiobuttons(){	
		var func =  $$('.makeGrid');				
		func.each(
			function(elem){
				elem.observe( 'click', 	function (event){ 	
					buttonsControl(event.target.value);
				});						
			}
		)
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB30400", "火險作業", "火險查詢作業");			
				grid = new TableUI ( {
					table: $("grid"), pageSize: 10, allSortable:true , split: ['APPLY_ID'],					
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:	columnLoad[0]
				});
				
				grid2 = new TableUI ( {
					table: $("grid2"), pageSize: 10, allSortable:true , split: ['APPLY_ID'],				
					<%-- [20240613] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:	columnLoad2[0]
				});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );	
				$("btn_export").observe("click", buttons.doExport );	
				
				$("CRED_DEPT").observe("change", 
					function(event){
						buttons.doCRED_DEPT_Ajax($('CRED_DEPT').value , "append" , "");
				});	
				$("QUERY1_SELECT").observe("change", 
					function(event){
						action.doquery1(event.target.value);
				});	
				
				//加入radio buttons連動
				makeRadiobuttons();				
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				var LP_JSON = CSRUtil.isBackLink('form1');
				if(LP_JSON){        					
					buttons.doCRED_DEPT_Ajax($('CRED_DEPT').value , "linkBack" , LP_JSON);					
				}
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" align="left" colspan = "2">
				承辦科別
			</td>
			<td class="tbYellow2">
				<select  id="CRED_DEPT" name = "CRED_DEPT" fieldName = "承辦科別">	
					<option value="">全部</option>
					<c:forEach items="${CRED_DEPT_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<!-- <td class="tbYellow"  align="left" >
				服務中心
			</td>
			<td class="tbYellow2">
				<select  id="SRV_DEPT" name = "SRV_DEPT"  fieldName = "服務中心">				
						<option value="">全部</option>										
				</select>
			</td> -->	
			<td class="tbYellow" align="left" >
				火險到期年月
			</td>
			<td class="tbYellow2" >
				<input name="FIREINSU_ENDDT_STR" id='FIREINSU_ENDDT_STR' type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate" fieldName = "火險到期日期起">
				<img id="calImg1" src="<%=imageBase%>/CM/calendar.gif" class = "date1" alt="Date" onclick="getCalendarFor($('FIREINSU_ENDDT_STR'))">
				~
				<input name="FIREINSU_ENDDT_END" id='FIREINSU_ENDDT_END' type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate" fieldName = "火險到期日期迄">
				<img id="calImg2" src="<%=imageBase%>/CM/calendar.gif" class ="date1" alt="Date" onclick="getCalendarFor($('FIREINSU_ENDDT_END'))">  
			</td>	
			<td class="tbYellow2"  align = "center" rowspan="4">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				<input id = "btn_export" type = "button" class = "button" value = "匯出"/>	
			</td>
		</tr>
		<!-- <tr>
			<td class="tbYellow" align="left" colspan = "2">
				火險類別
			</td>
			<td class="tbYellow2">
				<select  id="FIREINSU_TYPE" name = "FIREINSU_TYPE" fieldName = "火險類別">				
						<option value="">全部</option>
					<c:forEach items="${FIREINSU_TYPE_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" align="left" >
				火險狀態
			</td>
			<td class="tbYellow2" colspan = "3" >
				<select  id="ISSUE_CODE" name = "ISSUE_CODE" fieldName = "火險狀態">				
						<option value="">全部</option>
					<c:forEach items="${ISSUE_CODE_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
		</tr> -->
		<tr>
			<td class="tbYellow" align="left" rowspan = "2">
				查詢方式
			</td>
			<td class="tbYellow"  align="left" >
				<input type="radio" value="1" id = "QUERY_TYPE1" name="QUERY_TYPE"  class="makeGrid"  checked />
				<select  id="QUERY1_SELECT" name = "QUERY1_SELECT" fieldName = "查詢方式" class ="all type1">				
						<option value="">全部</option>
					<c:forEach items="${QUERY_TYPE1_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>
			<td class="tbYellow2" colspan = "5">
				<input id="QUERY1_INPUT" name="QUERY1_INPUT" type="text" size="16" class="text2 all type1" onKeyUp="this.value=this.value.toUpperCase();" ReadOnly />				
			</td>	
		</tr>
		<tr>
			<td class="tbYellow" align="left" >
				<input type="radio" value="2" id = "QUERY_TYPE2" name="QUERY_TYPE"  class="makeGrid" />其他
			</td>
			<td class="tbYellow2" colspan = "5" >
				<select  id="QUERY2_SELECT" name = "QUERY2_SELECT" class = "all type2" disabled >	
					<c:forEach items="${QUERY_TYPE2_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>			
		</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>	
	<table id="grid2" class="grid" style="display:none"></table>
</body>
</html>