<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
[20240729] 修改件 陳勁谷 難字修改
 -->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>

<script type="text/javascript">

var VaildationSaves = {};
var ContentSaves = {};
var recordsControlButtonArea;
var isClearEMailSelect = true;

var dataMainMap = {};

vaildationRules();

function buttonsAuth(){
	var authButtons = {
			B0072:"BTN_UPDATE<%--試算--%>",
			B0073:"BTN_CONFIRM<%--呈核--%>",
			B0085:"BTN_CELCONFIRM<%--取消呈核--%>",
			B0075:"BTN_AGREE<%--核准--%>",
			B0008:"BTN_REJCT<%--退回--%>",
			B0068:"BTN_REJCT1<%--退件--%>",
			B0069:"BTN_CANCELREJCT1<%--取消退件--%>",
			B0076:"E_UPLOAD<%--新增檔案--%>"
	};
	<dz:grantButtons FUNC_ID="DSA22400" ignored="false"/>
}

var selectionOptions = {
	// 「保人戶籍地址碼」、「戶籍地址碼」、「目前經營事業-事業處所碼」、「目前服務單位-詳細地址碼」下拉選單
	MAIL_LIST:<c:choose><c:when test="${not empty MAIL_LIST}">${MAIL_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	,AGREE_LEVEL_LIST:<c:choose><c:when test="${not empty AGREE_LEVEL_LIST}">${AGREE_LEVEL_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose>	
	,PLS_CHOOSE:[{CODE:"" , CODE_NM:"請選擇"}]
	,AREA_CODE:[{CODE:"" , CODE_NM:"(區碼)"}]
}

function E_STROP_change(){
	$('E_DOM2').show();
	if($F("E_STROP")=='1'){
			$('title1').innerHTML = '服務中心別1';
			$('title2').innerHTML = '服務中心別2';
			$('title3').innerHTML = '承辦人員ID';
			$('TYPE').value = '1';
	}
	else if($F("E_STROP")=='2'){
			$('title1').innerHTML = '區部單位別';
			$('title2').innerHTML = '營業單位別';
			$('title3').innerHTML = '送件人員ID';
			$('TYPE').value = '2';
	}else{
		$('E_DOM2').hide();
	}
}

function init(){

	displayMessage();
	createUserInterface();
	buttonsAuth();
	autoFormatToNumber();

	if ('${REFER_ID}' != "") {//接值
    	$('A_REFER_ID').value = '${REFER_ID}';
  	}

  	if ('${SEQ_NO}' != "") {//接值
    	$('A_SEQ_NO').value = '${SEQ_NO}';
  	}


   	if($('A_REFER_ID').value){
    	buttonActions.query();
   	}

 	$("uploadFrame").observe('load', function(event){
			uploadEnd();
		}
	);

	//selection.createAll("E_AGENT_DEPT", selectionOptions.MAIL_LIST, "", "CODE", "CODE_NM");
	
	E_STROP_change();

	$("E_STROP").observe('change', function(event){
		E_STROP_change();
		$('E_AGENT_DEPT').selectedIndex = 0;
		$('ADCD').length = 0;
		$('ADCD').options.add(new Option('請選擇', ''));
		$('DIV_NO').length = 0;
		$('DIV_NO').options.add(new Option('請選擇', ''));
	});
	

	$("E_AGENT_DEPT").observe('change', function(event){
		var obj = {};
		obj.AGENT_DEPT = $F('E_AGENT_DEPT');
		obj.TYPE = $F('TYPE');
		tools.ajaxPost( "getADCD_LIST", obj, function (resp) {
				if(CSRUtil.isSuccess(resp)){
					if(resp.ADCD_LIST){
						JSONUtil.addOptions2( $('ADCD') , resp.ADCD_LIST );
						if($('ADCD').value==''){
							$('ADCD').length = 0;
							$('ADCD').options.add(new Option('請選擇', ''));	
						}else{
							changeDIV_NO();
						}
					}else{
						$('ADCD').length = 0;
						$('ADCD').options.add(new Option('請選擇', ''));	
					}
					$('DIV_NO').length = 0;
					$('DIV_NO').options.add(new Option('請選擇', ''));
				}else{
					$('ADCD').length = 0;
					$('ADCD').options.add(new Option('請選擇', ''));
					$('DIV_NO').length = 0;
					$('DIV_NO').options.add(new Option('請選擇', ''));
				}
										
			}
		);
	});

	$("ADCD").observe('change', function(event){
		changeDIV_NO();
	});

	$("AGENT_ID").observe('change', function(event){
		var obj = {};
		obj.AGENT_ID = $('AGENT_ID').value;
		
		$('AGENT_ID').value = $('AGENT_ID').value.toUpperCase();

		tools.ajaxPost( "getAGENT_NAME", obj, function (resp) {
				if(CSRUtil.isSuccess(resp)){
					$('AGENT_NAME').innerHTML = resp.AGENT_NAME;
				}
			}
		);
	});
	
	
	$("E_AGREE_LEVEL").observe('change', function(event){
		var records = areaB_grid.getCheckedRecord();
		doButtonControl(records[0]);
	});
	
	
	<c:if test="${INST_LEVEL ne 20}">
		$("E_STROP").hide();
	</c:if>
	
	<c:if test="${INST_LEVEL ne 30 && INST_LEVEL ne 40}">
		$("E_AGREE_LEVEL").hide();
	</c:if>
}

var areaB_grid;
var areaE_grid;

var ESetting;

var emptyE = {};
emptyE.PAY_STATUS = "0";
emptyE.JCIC_STATUS = "0";
emptyE.IS_GUARDIAN = "0";
emptyE.IS_REAPPR = "0";

//---------- 利用 pageUI 產生畫面 ----------
function changeDIV_NO(){
	var obj = {};
	obj.ADCD = $('ADCD').value;
	obj.TYPE = $F('TYPE');

	tools.ajaxPost( "getDIV_NO", obj, function (resp) {
			if(CSRUtil.isSuccess(resp)){					
				if(resp.DIV_NO_LIST){
					JSONUtil.addOptions2( $('DIV_NO') , resp.DIV_NO_LIST );
					if($('DIV_NO').value==''){
						$('DIV_NO').length = 0;
						$('DIV_NO').options.add(new Option('請選擇', ''));	
					}
				}else{
					$('DIV_NO').length = 0;
					$('DIV_NO').options.add(new Option('請選擇', ''));	
				}
			}else{
				$('DIV_NO').length = 0;
				$('DIV_NO').options.add(new Option('請選擇', ''));
			}
		}
	);
}


function createUserInterface(){

//PageUI create
	PageUI.createPage("DSA22400" , "核貸作業" , "變更年期簽件",'${titleNotDisplay}' == 'Y');
	PageUI.loadin(["areaA","areaButton","areaB","areaC","areaD","areaD1","areaD2","areaE","areaF","areaG"] ,2)

//-------------------------------------------------------------------------------------------------
// area A Query
//
//-------------------------------------------------------------------------------------------------
	var areaAcontent = PageUI.createContent( {
		elem:"areaA", id:"areaA", headerInTop:false, dataColumns: 2, noContent:false, noHeader:false
		,columnProps:[20,20], clearChildElements:true, KeyToId:function(key){ return "A_"+key; },
		contents:[
			{ header:"原貸帳號", values:[
				 { key:"REFER_ID", type:"text" , attrs:{ className:"required" , size :13 , maxLength:11} }
			]},
			{ header:"變更年期序號", values:[
				 { key:"SEQ_NO", type:"text" , attrs:{  datatype:"number" , pattern:"#" , size :13 , maxLength:11} }
			]},
			{ header:"一、年期規定", colSpan:"3", values:[
				 "1.最長兩年且不可超過貸款期限五分之一。"
				 ,document.createElement("br")
				 ,"2.借款年期不得逾20年。"
			]},
			{ header:"二、資格條件", colSpan:"3", values:[
				 <%--"1.本息收支比≦%70且貸款成數≦「表定成數」90%。"--%> //2019-01-31放企科妍伶：該項說明是舊的，不符合現行規定，故調整
				 "1.貸放成數≦區域放款率。"
				 ,document.createElement("br")
				 ,"2.聯徵及繳息正常。"
			]}
		]
	} , null , 0 );
	var queryButtonArea = PageUI.createButtonArea( areaAcontent , { changeForOneButton:false, buttonOnRight:true,
		buttons:{
			B0001:{ id:"BTN_QUERY", header:"查詢",ignoreAuth:true, events:{ "click":buttonActions.query}	},
			B0011:{ id:"BTN_CLEAR", header:"清除",ignoreAuth:true, events:{ "click":buttonActions.clearAll }	},
			B0005:{ id:"BTN_PRINT", header:"列印",ignoreAuth:true, events:{ "click":buttonActions.print } }
		}
	});
	ContentSaves["A"] = areaAcontent;
	VaildationSaves["A"] = new Validation( areaAcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});

	//debugMode
	//PageUI.setContentValues( areaAcontent ,{"REFER_ID":"A000011477"} , true , true );
	//PageUI.setContentValues( areaAcontent ,{"SEQ_NO":"1"} , true , true );


//-------------------------------------------------------------------------------------------------
// area  Control Buttons
//
//-------------------------------------------------------------------------------------------------
	recordsControlButtonArea = PageUI.createButtonArea( "areaButton" , { changeForOneButton:false, buttonOnRight:false, clearChildElements:true,
		buttons:{
			 B0072:{ id:"BTN_UPDATE",header:"試算",ignoreAuth:true,events:{
			  	"click":function(target){
					doTrimTextArea ('E_INPUT_COMMENT');
					buttonActions.doUpdate();
				}
			 }}
			,B0073:{ id:"BTN_CONFIRM" , header:"呈核",ignoreAuth:true,events:{
				"click":function(target){
					doTrimTextArea ('E_INPUT_COMMENT');
					buttonActions.doConfirm();
				}
			 }}
			,B0085:{ id:"BTN_CELCONFIRM" , header:"取消呈核",ignoreAuth:true,events:{
				"click": buttonActions.doCelConfirm
			 }}
			,B0075:{ id:"BTN_AGREE" , header:"核准",ignoreAuth:true,events:{
				"click":function(target){
					doTrimTextArea ('E_INPUT_COMMENT');
					buttonActions.doAgree();
				}
			 }}
			,B0008:{ id:"BTN_REJCT" , header:"退回",ignoreAuth:true,events:{
				"click":buttonActions.doReject
			 }}
			 ,B0068:{ id:"BTN_REJCT1" , header:"退件",ignoreAuth:true,events:{
				"click":buttonActions.doReject1
			 }}
			 ,B0069:{ id:"BTN_CANCELREJCT1" , header:"取消退件",ignoreAuth:true,events:{
				"click":buttonActions.doCancelReject1
			 }}
		}
	});

	PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_UPDATE","BTN_CONFIRM","BTN_CELCONFIRM","BTN_AGREE","BTN_REJCT","BTN_REJCT1","BTN_CANCELREJCT1"] );

//-------------------------------------------------------------------------------------------------
// area B
//
//-------------------------------------------------------------------------------------------------
	areaB_grid = new TableUI({
		table:$('tableUiGrid'), pageSize: 5, allSortable: true, overDiv:false,
		autoCheckBox:{
			type:"radio",
			valueKey:"SEQ_NO",
			action:function( checkbox , boxStatus , records){
			   if(!boxStatus){return;}
			
				buttonActions.queryDetail(records[0]);
			}
		},
		column:[
				{ key: 'SPEC_PROCESS_NM', header: '批示進度',render: function(record , value){					
					return value + "(" + record.AGREE_PROCESS_NM + ")";
				}},
				{ key: 'SEQ_NO', header: '變更年期序號'},
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				{ key: 'INPUT_NM', header: '作業人員', attrs: {style:"font-family:'EUDC'"}},
				{ key: 'INPUT_DATE', header: '作業日期'}
		]
	});
	ContentSaves["B"] = areaB_grid;


//-------------------------------------------------------------------------------------------------
// area C
//
//-------------------------------------------------------------------------------------------------
	var areaCcontent = PageUI.createContent( {
		elem:"areaC", id:"areaC", headerInTop:false, dataColumns: 5, noContent:false, noHeader:false
		, clearChildElements:true, KeyToId:function(key){ return "C_"+key; },
		contents:[
			{ header:"批示進度", values:[
				{key:"SPEC_PROCESS_NM" }
			]},
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			{ header:"借款人姓名", attrs: {style:"font-family:'EUDC'"}, values:[
				{key:"BORROW_NAME" }
			]},
			{ header:"借款人ID", values:[
				{key:"BORROW_ID" }, " ", 
				{key:"BORROW_ID_GROUP", 
					type:"link", 
					events:{ 
						click:function(target){ 
							popupWin.popup({
								src : '${dispatcher}/DSH0_0320/prompt', <%--開新視窗顯示客戶分群資料查詢頁面DSH0_0320--%>
								parameters : {
									TYPE : '2', <%--依借款人ID查詢,固定給2--%>
									CASE_ID : $('C_BORROW_ID').innerHTML
								}
							});
						}
					}
				}<%--總擔分群超連結--%>
			]},
			{ header:"原貸帳號", values:[
				{key:"REFER_ID"}, " ", 
				{key:"REFER_ID_GROUP", 
					type:"link", 
					events:{
						click:function(target){ 
							popupWin.popup({
								src : '${dispatcher}/DSH0_0320/prompt', <%--開新視窗顯示客戶分群資料查詢頁面DSH0_0320--%>
								parameters : {
									TYPE : '1', <%--依借款人ID查詢,固定給2--%>
									CASE_ID :  $('C_REFER_ID').innerHTML
								}
							});
						}
					}
				}<%--個擔分群超連結--%>
			]},
			{ header:"變更年期序號", values:[
				{key:"SEQ_NO" }
			]}
		]
	} , null , 0 );

	ContentSaves["C"] = areaCcontent;
	VaildationSaves["C"] = new Validation( areaCcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});


//-------------------------------------------------------------------------------------------------
// area D
// 基本資料
//-------------------------------------------------------------------------------------------------
	var areaDsetting =
	{
		elem:"areaD", dataColumns: 11, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true,columnProps:[5,10,10,10,10,10,10,10,10,10,5], KeyToId:function(key){ return "D_"+key; },
		contents:[
			 { header:"",values:[
				{key:"CHOOSE", type:"radio", items:{1:""}, attrs:{name:"delTagD"} , events :{ click:function(target){ RecrodsControl.selectToDelete("D" , target); } } }
			 ]}
			,{ header: '帳號',	values:[
					{key:"LOAN_ID", type:"text" , attrs:{ size:'12', maxLength:'10', className:"required" } , events:{ 
							blur:function(target){ 			
								target.value = target.value.toUpperCase();
							} 
						} 
					}
			 	]
			}
			<%-- [20221227] [申請書:220725005491]新增本金彈性還還款方式 --%>
			<%-- [20240326] [申請書:220725005491]新增本金彈性還還款方式_貸後變更 --%>
			,{ header: '本金彈性還每月還本金額', values:[
				"變更前:"
				,{key:"OLD_FLEX_AMT", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number"},
					setFunc: function(node , value , values ){
						if(value || value === 0){
							return value;
						}
						<%--現在B區選到的那筆資料是IS_FLEX==Y--%>
						if(values.IS_FLEX === 'Y'){
							return values.FLEX_AMT;
						}
						return 0;
					} 
				 }
				,"元"
				,document.createElement("br")
				,"變更後:"
				,{key:"NEW_FLEX_AMT", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" },
					setFunc: function(node , value , values ){
						if(value || value === 0){
							return value;
						}
						return 0;
					}	
				}
				,"元"
			]}
			,{ header: '變更前還款方式', values:[
					"("
					,{key:"OLD_FIX_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" } }
					,"∕12) 年定期+("
					,document.createElement("br")
					<%--[20240326]變更前還款方式欄位新增本金彈性還欄位，預設為0--%>
					,{key:"OLD_FLEX_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" },
						setFunc: function(node , value , values ){
							if(value || value === 0){
								return value;
							}
							return 0;
						} 	
					}
					,"∕12) 年本金彈性還+("
					,document.createElement("br")
					,{key:"OLD_SPR_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" } }
					,"∕12) 年分期"
			]}
			,{ header: '變更後還款方式', values:[
					"("
					,{key:"NEW_FIX_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" } }
					,"∕12) 年定期+("
					,document.createElement("br")
					<%--[20240326]變更後還款方式欄位新增本金彈性還欄位，預設為0--%>
					,{key:"NEW_FLEX_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number"},
						setFunc: function(node , value , values ){
							if(value || value === 0){
								return value;
							}
							return 0;
						}	
					}
					,"∕12) 年本金彈性還+("
					,document.createElement("br")
					,{key:"NEW_SPR_PERIOD", type:"text" ,attrs:{ datatype:"number" , pattern:"#" , maxLength:8 ,size:10 , className:"required validate-positive-number" } }
					,"∕12) 年分期"
			]}
			
			,{ header:"適用年月、期數", values:[
				{key:"SUIT_YEAR", type:"text" , attrs:{ datatype:"number" , pattern:"#" , maxLength:3 ,size:5 , className:"required validate-positive-number" } }
				,"年"
				,{key:"SUIT_MONTH", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: <c:choose><c:when test="${not empty MONTH_LIST}">${MONTH_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose> }
				,"起"
				,document.createElement("br")
				,"期數"
				,{key:"PAY_TERM", type:"text" , attrs:{  datatype:"number", pattern:"#" , size:'8', maxLength:'6', className:"required validate-positive-number" } }
				,"期"
			] }
			,{ header:"目前利率",values:[
				{key:"RATE", type:"text" , attrs:{ datatype:"number",pattern :"#,###.####" ,size:'10', maxLength:'8', className:"required" } }
				,"%"
			 ] }
			,{ header:"適用利率",values:[
				{key:"RATE_KIND", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: <c:choose><c:when test="${not empty RATE_KIND_LIST}">${RATE_KIND_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose> }
				,document.createElement("br")
				,{key:"SUIT_RATE", type:"text" , attrs:{ datatype:"number",pattern :"#,###.####" ,size:'10', maxLength:'8', className:"required" } }
				,"%"
			 ] }
			 ,{ header:"手續費",values:[
				{key:"EXPENSE_AMT", type:"text" , attrs:{ datatype:"number",pattern :"#,###" ,size:'15', maxLength:'10', className:"required validate-positive-number" } }
				,"元"
			 ] }
			 
			,{ header:"每期應繳",values:[
				{key:"OLD_DUTY_PAYMENT", type:"text" , attrs:{ datatype:"number",pattern :"#,###" ,size:'15', maxLength:'10', className:"required validate-positive-number" }
					, events:{ 
						blur:function(target){ 
							var sum = 0;
							$$('#areaD input[datatype="number"]').each(
								function(obj){
									var id = obj.id;
									if(id.indexOf("OLD_DUTY_PAYMENT") > 0){
										var value = obj.getValue();
										
										if(!isNaN(parseInt(value, 10))){
											sum = sum + Number(value);
										}else{
											obj.value="";
										}
									}
								}
							);
							
							$('F_SUM_OLD_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt(sum, "#,###.##");							
						} 
					} 
				}
				,"元"
				,{key:"NEW_DUTY_PAYMENT", type:"text" , attrs:{ datatype:"number",pattern :"#,###" ,size:'15', maxLength:'10', className:"required validate-positive-number" } 
					, events:{ 
						blur:function(target){ 
							var sum = 0;
							$$('#areaD input[datatype="number"]').each(
								function(obj){
									var id = obj.id;
									if(id.indexOf("NEW_DUTY_PAYMENT") > 0){
										var value = obj.getValue();
										if(!isNaN(parseInt(value, 10))){
											sum = sum + Number(value);
										}else{
											obj.value="";
										}
									}
								}
							);
							
							$('F_SUM_NEW_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt(sum, "#,###.##");							
						} 
					} 
				}
				,"元"
			 ] }
			,{ header:"餘額",values:[
				{key:"REMAIN_AMT", type:"text" , attrs:{ datatype:"number",pattern :"#,###" ,size:'12', maxLength:'10', className:"required validate-positive-number" }
					, events:{ 
						blur:function(target){ 
							reCalculate();
						} 
					} 
				}
				,"元"
			 ] }
			,{ header:"發送簡訊",values:[
				{key:"IS_SEND", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: <c:choose><c:when test="${not empty YES_NO_LIST}">${YES_NO_LIST}</c:when><c:otherwise>[]</c:otherwise></c:choose> }
			 ] }
		]
	}
	var areaDcontent = RecrodsControl.createRecord( "D" , areaDsetting ).parentNode;
	ContentSaves["D"] = areaDcontent;

	VaildationSaves["D"] = new Validation( areaDcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});

	var D1Setting =
	{
		elem:"areaD1", dataColumns: 3, className:"contentBlue", headerInTop:false, noContent:true, clearChildElements:true, KeyToId:function(key){ return "F_"+key; },
		columnProps:[73,14,14],
		contents:[
			{ key: 'GAGE_ADDR', header: '擔保品地址',	rowSpan:'2', values:[
					{key: 'GAGE_ADDR'}
			 	]
			}
			,{ key: 'INDEX_STS_NM', header: '合計',colSpan:'2', values:[

			]}
			,{ header:"每期應繳",values:[
				"前："
				,{key:"SUM_OLD_DUTY_PAYMENT", attrs:{ datatype:"number",pattern :"#,###" ,size:'15', maxLength:'10', className:"required validate-positive-number" } }
				,"元"
				,document.createElement("br")
				,"後："				
				,{key:"SUM_NEW_DUTY_PAYMENT", attrs:{ datatype:"number",pattern :"#,###" ,size:'15', maxLength:'10', className:"required validate-positive-number" } }
				,"元"
			 ] }
			,{ header:"餘額",values:[
				{key:"SUM_REMAIN_AMT", attrs:{ datatype:"number",pattern :"#,###" ,size:'12', maxLength:'10', className:"required validate-positive-number" } }
				,"元"
			 ] }
		]
	}
	var areaD1content = PageUI.createContent( D1Setting, null , 0 );
	D1Setting.noContent = false;
	D1Setting.noHeader = true;
	D1Setting.clearChildElements = false;
	D1Setting.elem = areaD1content.parentNode;
	areaD1content = PageUI.createContent( D1Setting, null , 0 );

	ContentSaves["D1"] = areaD1content;
	VaildationSaves["D1"] = new Validation( areaD1content, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});


	var areaD2content = PageUI.createContent( {
	elem:"areaD2", dataColumns: 1, clearChildElements:true, KeyToId:function(key){ return "F_"+key; }, columnProps:[20,80],
	contents:[
			 { header:"※存續期間" , colSpan:3 , values:[
				 {key:"YEAR_EXISTS_BEG", type:"text" ,attrs:{ datatype:"number", pattern :"###", size:5 , maxLength:3 , className:"required validateROCYear" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_YEAR_EXISTS_BEG').length==3){
								$('F_MONTH_EXISTS_BEG').focus();
							}
						} 
					}
				 }
				 ,"年"
				 ,{key:"MONTH_EXISTS_BEG", type:"text" ,attrs:{ datatype:"number",pattern :"##" ,size:5 , maxLength:2 , className:"required validateROCMonth" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_MONTH_EXISTS_BEG').length==2){
								$('F_YEAR_EXISTS_END').focus();
							}
						} 
					}
				 }
				 ,"月~"
				 ,{key:"YEAR_EXISTS_END", type:"text" ,attrs:{ datatype:"number", pattern :"###", size:5 , maxLength:3 , className:"required validateROCYear" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_YEAR_EXISTS_END').length==3){
								$('F_MONTH_EXISTS_END').focus();
							}
						} 
					}
				 }
				 ,"年"
				 ,{key:"MONTH_EXISTS_END", type:"text" ,attrs:{ datatype:"number",pattern :"##" , size:5 , maxLength:2 , className:"required validateROCMonth" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_MONTH_EXISTS_END').length==2){
								$('F_YEAR_FIREINSU_BEG').focus();
							}
						} 
					}
				 }
				 ,"月"
			 ] }
			,{ header:"※火險期間", colSpan:3, values:[
				 {key:"YEAR_FIREINSU_BEG", type:"text" ,attrs:{ datatype:"number", pattern :"###", size:5 , maxLength:3 , className:"required validateROCYear" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_YEAR_FIREINSU_BEG').length==3){
								$('F_MONTH_FIREINSU_BEG').focus();
							}
						} 
					}
				 }
				 ,"年"
				 ,{key:"MONTH_FIREINSU_BEG", type:"text" ,attrs:{ datatype:"number",pattern :"##" , size:5 , maxLength:2 , className:"required validateROCMonth" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_MONTH_FIREINSU_BEG').length==2){
								$('F_YEAR_FIREINSU_END').focus();
							}
						} 
					}
				 }
				 ,"月~"
				 ,{key:"YEAR_FIREINSU_END", type:"text" ,attrs:{ datatype:"number", pattern :"###", size:5 , maxLength:3 , className:"required validateROCYear" } 
				 	, events:{ 
						keyup:function(target){
							if($F('F_YEAR_FIREINSU_END').length==3){
								$('F_MONTH_FIREINSU_END').focus();
							}
						} 
					}
				 }
				 ,"年"
				 ,{key:"MONTH_FIREINSU_END", type:"text" ,attrs:{ datatype:"number",pattern :"##" , size:5 , maxLength:2 , className:"required validateROCMonth" } }
				 ,"月"
			 ] }

		]
	} , null , 0 );
	ContentSaves["D2"] = areaD2content;
	VaildationSaves["D2"] = new Validation( areaD2content, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});

//-------------------------------------------------------------------------------------------------
// area E
// 目前服務單位
//-------------------------------------------------------------------------------------------------

	ESetting = {
		elem:"areaE", dataColumns: 2, clearChildElements:true, KeyToId:function(key){ return "E_"+key; },
		contents:[
			 { header:"1.繳息狀況" , colSpan:3 , values:[
				 {key:"PAY_STATUS",items:{"0":"正常" , "1":"不正常"}, type:"radio" ,attrs:{ size:30 , maxLength:30 , className:"" } }
				 ,{key:"PAY_NOTE", type:"text" ,attrs:{ size:50 , maxLength:50 , className:"vaildatePreCheck" } }
			 ] }
			,{ header:"2.目前放款率", colSpan:3, values:[
				 {key:"RATE1", attrs:{ datatype:"number",pattern :"####.##" ,size:20 , maxLength:10 , className:"" } }
				 ,"% （貸放餘額"
				 ,{key:"REMAIN_AMT" ,attrs:{ datatype:"number",pattern :"#,###.####" ,size:20 , maxLength:10 , className:"" } }
				 ,"萬∕鑑估總值"
				 ,{key:"APPR_AMT", type:"text" ,attrs:{ datatype:"number",pattern :"#,###.####" ,size:20 , maxLength:14 , className:"" }
				 	,events:{ 
						blur:function(target){ 
							var appr_amt = $('E_APPR_AMT').getValue();
							var valREMAIN_AMT = $('E_REMAIN_AMT').innerHTML.replace(/,/gi,'');
							if(!isNaN(parseInt(appr_amt)) && appr_amt != 0){
								$('E_RATE1').innerHTML = CSRUtil.$fmt(valREMAIN_AMT / appr_amt * 100, "####.##");
							} else {
								$('E_RATE1').innerHTML = "0";
							}							
						} 
					}
				 }
				 ,"萬）"
			 ] }
			,{ header:"市價比", colSpan:3, values:[
				 {key:"RATE2", attrs:{ datatype:"number",pattern :"####.##" ,size:20 , maxLength:10 , className:"" } }
				 ,"% （貸放餘額"
				 ,{key:"REMAIN_AMT2" ,attrs:{ datatype:"number", pattern :"#,###.####", size:20 , maxLength:10 , className:"" } }
				 ,"萬∕判定市價"
				 ,{key:"APPR_REALVALUE", type:"text" ,attrs:{ datatype:"number", pattern :"#,###.####", size:20 , maxLength:14 , className:"" }
				 	,events:{ 
						blur:function(target){ 
							var appr_realvalue = $('E_APPR_REALVALUE').getValue();
							var valREMAIN_AMT = $('E_REMAIN_AMT').innerHTML.replace(/,/gi,'');
							if(!isNaN(parseInt(appr_realvalue)) && appr_realvalue != 0){
								$('E_RATE2').innerHTML = CSRUtil.$fmt(valREMAIN_AMT / appr_realvalue * 100, "####.##");
							} else {
								$('E_RATE2').innerHTML = "0";
							}							
						} 
					}
				 }
				 ,"萬）"
			 ] }
			,{ header:"3.聯徵情況" , colSpan:3 , values:[
				 {key:"JCIC_STATUS",items:{"0":"正常" , "1":"異常"}, type:"radio" ,attrs:{ size:30 , maxLength:30 , className:"" } }
				 ,{key:"JCIC_NOTE", type:"text" ,attrs:{ size:50 , maxLength:50 , className:"vaildatePreCheck" } }
			 ] }
			,{ header:"4.本息收支比", colSpan:3, values:[
				 {key:"PAYMENT_RATE", type:"text" ,attrs:{ datatype:"number",pattern :"####.##" ,size:20 , maxLength:10 , className:"tbYellow0" , disabled:true } }
				 ,"%"
				 ,{key:"PAYMENT_NOTE", type:"text" ,attrs:{ size:20 , maxLength:10 ,className:"tbYellow0" , disabled:true} }
			 ] }
			,{ header:"5.監護及補助宣告查詢" , colSpan:3 , values:[
				 {key:"IS_GUARDIAN",items:{"0":"正常" , "1":"異常"}, type:"radio" ,attrs:{ size:30 , maxLength:30 , className:"" } }
				 ,{key:"GUARDIAN_NOTE", type:"text" ,attrs:{ size:50 , maxLength:50 , className:"vaildatePreCheck" } }
				 ,{type:"dom", key:"DOM4" , elem:"E_DOM4"}
			 ] }
			,{ header:"6.擔保品是否重新估價" , colSpan:3 , values:[
				 {key:"IS_REAPPR",items:{"0":"是" , "1":"無 請輸入受編"}, type:"radio" ,attrs:{ size:30 , maxLength:30 , className:"" } }
				 ,{key:"APPR_APPLY_ID", type:"text" ,attrs:{ size:12 , maxLength:11 , className:"vaildatePreCheck" } , events:{ 
							blur:function(target){ 			
								target.value = target.value.toUpperCase();
							} 
						} 
				  }
			 ] }
			,{ header:"7.適用年月" , colSpan:3 , values:[
				 "自",
				 ,{key:"YEAR_BEGIN", type:"text" ,attrs:{ datatype:"number", pattern :"###", size:5 , maxLength:3 , className:"required validateROCYear" } }
				 ,"年"
				 ,{key:"MONTH_BEGIN", type:"text" ,attrs:{ datatype:"number",pattern :"##" ,size:5 , maxLength:2 , className:"required validateROCMonth" } }
				 ,"月起期款適用"
			 ] }
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			,{ header:"8.核准mail通知" , colSpan:3, attrs: {style:"font-family:'EUDC'"}, values:[
				 "核准mail通知單位",
				 ,{key:"SHOW_DIV_NO"}
				 ,{key:"SHOW_DIV_NM"}
				 ," 承辦(送件)人員"
				 ,{key:"SHOW_AGENT_ID"}				
				 ,{key:"SHOW_AGENT_NM"}
				 ,document.createElement("br")
				 <c:if test="${INST_LEVEL eq 20}">
				 ,"選項"
				 </c:if>
				 ,{key:"STROP", type:"select", optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.MAIL_LIST ,attrs:{ className:"" } }
				 ,{type:"dom", key:"DOM2" , elem:"E_DOM2"}
			 ] }
			,{ header:"9.徵信說明" , colSpan:3 , values:[
				 <c:if test="${INST_LEVEL eq 30 || INST_LEVEL eq 40}">
				 "核定層級"
				 </c:if>
				 ,{key:"AGREE_LEVEL", type:"select", optKey:"CODE", optValueKey:"CODE_NM", opts: selectionOptions.AGREE_LEVEL_LIST, attrs:{ className:"" } }
				 ,{key:"CRED_COMMENT"}
			 ] }
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			,{ header:"10.主管意見" , colSpan:3, attrs: {style:"font-family:'EUDC'"}, values:[				
				 {type:"dom", key:"DOM3" , elem:"E_DOM3"}
			 ] }
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			,{ header:"作業人員", attrs: {style:"font-family:'EUDC'"}, values:[
				 {key:"INPUT_NM"}
			 ] }
			,{ header:"作業日期" ,  values:[
				 {key:"INPUT_DATE"}
			 ] }
			,{ header:"作業內容" , colSpan:3 , values:[
				{key:"INPUT_COMMENT", type:"textarea" ,attrs:{ Wrap:"hard", cols:80 , rows:3 , className:"vaildateCharCnts" }}
			 ] }
			,{ header:"上傳附件", colSpan:3, values:[
				 {type:"dom", key:"DOM1" , elem:"E_DOM1"}
			 ] }
		]
	}

	var areaEcontent = PageUI.createContent( ESetting , emptyE , 0 );
	ContentSaves["E"] = areaEcontent;
	VaildationSaves["E"] = new Validation( areaEcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});

	areaE_grid = new TableUI({
		table:$('tableUiGrid1'), pageSize: 5, allSortable: true, overDiv:false,
		column:[
				{ key: 'FILE_NM', header: '檔名',render: function(record , value){
						var link = document.createElement('a') ;
						link.href = '#' ;
						link.onclick = function(){
							var obj={};
							obj.FILE_ID = record.FILE_ID;

							tools.ajaxPost( "download", obj, function (resp) {
									if(CSRUtil.isSuccess(resp)){
										RPTUtil.download({
											'downloadFileName': resp.FILE_NM,
											'downloadFileFullPath': resp.FILE_PATH
										})
									}
								}
							);
						} ;
						link.innerHTML = value ;

						return link ;
					}
				},
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				{ key: 'LST_PROC_NAME', header: '上傳人員', attrs: {style:"font-family:'EUDC'"}},
				{ key: 'LST_PROC_DT', header: '上傳時間'},
				{ key: 'INPUT_NAME', header: '刪除附件' , render:function( rec , val){					
					var button = new Element('input',{name:'singleRG',type:'button',value:'刪除'});					
					button.observe('click',function(){
						obj = {};
						obj.REFER_ID = rec.REFER_ID;
						obj.SEQ_NO = rec.SEQ_NO;
						obj.BORROW_ID = rec.BORROW_ID;
						obj.FILE_ID = rec.FILE_ID;
						tools.ajaxPost( "deleteFile", obj, function (resp) {
								if(CSRUtil.isSuccess(resp)){
									areaE_grid.load((resp.FILE_LIST) ? resp.FILE_LIST:[]);
								}
							}
						);
					});					
					return button;
				}}
		]
	});


	//-------------------------------------------------------------------------------------------------
// area F
//審核資料	//-------------------------------------------------------------------------------------------------
	var areaFcontent = PageUI.createContent( {
		elem:"areaF", dataColumns: 9, className:"contentBlue", headerInTop:true, clearChildElements:true, KeyToId:function(key){ return "F_"+key; },
		contents:[
			 { header:"副總經理" , values:[
			 	{key:"SVP_NAME" }
			 	,document.createElement("br")
			 	,{key:"SVP_DATE" }
			 ] }
			,{ header:"經理", values:[
				{key:"GM_NAME" }
				,document.createElement("br")
			 	,{key:"GM_DATE" }
			 ] }
			,{ header:"審核科長", values:[
				{key:"AUDIT_CHIEF_NAME" }
				,document.createElement("br")
			 	,{key:"AUDIT_CHIEF_DATE" }
			 ] }
			,{ header:"審查組長", values:[
				{key:"AUDIT_LEADER_NAME" }
				,document.createElement("br")
			 	,{key:"AUDIT_LEADER_DATE" }
			 ] }
			,{ header:"審查人員", values:[
				{key:"AUDIT_NAME" }
				,document.createElement("br")
			 	,{key:"AUDIT_DATE" }
			 ] }
			,{ header:"管理科長", values:[
				{key:"CHIEF_NAME" }
				,document.createElement("br")
			 	,{key:"CHIEF_DATE" }
			 ] }
			,{ header:"徵信組長", values:[
				{key:"LEADER_NAME" }
				,document.createElement("br")
			 	,{key:"LEADER_DATE" }
			 ] }
			,{ header:"徵信人員", values:[
				{key:"CRED_NAME" }
				,document.createElement("br")
			 	,{key:"CRED_DATE" }
			 ] }
		]
	} , null , 0 );
	ContentSaves["F"] = areaFcontent;
	VaildationSaves["F"] = new Validation( areaFcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});

//-------------------------------------------------------------------------------------------------
// area G
//-------------------------------------------------------------------------------------------------
	var areaGcontent = PageUI.createContent( {
		elem:"areaG", dataColumns: 6, className:"contentBlue", headerInTop:true, clearChildElements:true, KeyToId:function(key){ return "G_"+key; },
		contents:[
			<%--[20200514] 修改件 新增 副總經理(二)邏輯判斷--%>
			{ header:"副總經理" , values:[
			 	{key:"SVP_NAME2" }
			 	,document.createElement("br")
			 	,{key:"SVP_DATE2" }
			 ] }
			,  { header:"副總經理" , values:[
			 	{key:"SVP_NAME" }
			 	,document.createElement("br")
			 	,{key:"SVP_DATE" }
			 ] }
			,{ header:"部室主管", values:[
				{key:"GM_NAME" }
				,document.createElement("br")
			 	,{key:"GM_DATE" }
			 ] }
			,{ header:"審查科主管", values:[
				{key:"CHIEF_NAME" }
				,document.createElement("br")
			 	,{key:"CHIEF_DATE" }
			 ] }
			,{ header:"審查組長", values:[
				{key:"LEADER_NAME" }
				,document.createElement("br")
			 	,{key:"LEADER_DATE" }
			 ] }
			,{ header:"徵信人員", values:[
				{key:"CRED_NAME" }
				,document.createElement("br")
			 	,{key:"CRED_DATE" }
			 ] }
		]
	} , null , 0 );


	ContentSaves["G"] = areaGcontent;
	VaildationSaves["G"] = new Validation( areaGcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});	

}

function upload(){
	if(!$F("filePath")){
			alert( "請選取要上載的檔案" );
			return;
	}

	//取得上傳檔案路徑
	var pathArray = $F("filePath").split("\\");
	pathArray = pathArray[pathArray.length-1].split("/");
	$("FILE_NM_ALT").value = pathArray;
	$("E_REFER_ID").value = $("C_REFER_ID").innerHTML;
	$("E_BORROW_ID").value = $("C_BORROW_ID").innerHTML;
	$("E_SEQ_NO").value = $("C_SEQ_NO").innerHTML;

	$('aForm').target = "uploadFrame";
	//showProgress();
	//送回後端
	$('aForm').submit();
}

//匯入的結果回傳至畫面上
function uploadEnd() {
	var records = areaB_grid.getCheckedRecord();
	if(records.length==0){
		alert('請先選取資料後才可新增檔案');
		return;
	}
	var filedata = window.uploadFrame.document.getElementById("filedata");	
	var json = filedata.innerHTML.evalJSON();	
	var Msg = json.ErrMsg.displayMsgDescs.replace("\\n","");
	if(Msg != null && Msg != "") {
		alert(Msg);
	}

	if(CSRUtil.isSuccess(json)) {
		var rtnList = json.rtnList;
		//顯示成功失敗筆數
		areaE_grid.load((rtnList) ? rtnList:[]);
	} else {
		areaE_grid.load([]);
	}
	//stopProgress();
}

function hideBlock(blocknm){
	var block = $(blocknm);
	while( block ){
		block = JsUtils.getParentByTagName( block  , "table" );
		if(JsUtils.compareClass( block, "contentDivTable") ){ break; }
		block = block.parentNode;
	}
	if(block){ block.style.display="none"; }

}

function showBlock(blocknm){
	var block = $(blocknm);
	while( block ){
		block = JsUtils.getParentByTagName( block  , "table" );
		if(JsUtils.compareClass( block, "contentDivTable") ){ break; }
		block = block.parentNode;
	}
	if(block){ block.style.display=""; }

}

function doValidation(){
	VaildationSaves["D"].reset();
	if( !VaildationSaves["D"].validate() ) {return false;}

	VaildationSaves["D1"].reset();
	if( !VaildationSaves["D1"].validate() ) {return false;}

	VaildationSaves["D2"].reset();
	if( !VaildationSaves["D2"].validate() ) {return false;}

	VaildationSaves["E"].reset();
	if( !VaildationSaves["E"].validate() ) {return false;}

	if($F('A_REFER_ID') != $('C_REFER_ID').innerHTML){
		alert('查詢用之原貸帳號與作業用之原貸帳號不同，請重新查詢');
		return false;
	}

	return true;
}

<%--[20240326]資料檢核--%>
function doFlexValidation(){
	var A271TmpMap = PageUI.getContentValues( ContentSaves["D"] );
	
	var needConfirm_SPEC_KIND = false;
	var needConfirm_IS_SEND = false;
	var keyList = Object.keys(A271TmpMap);
	for(var i= 0; i<keyList.length ;i++){
	    var vo = A271TmpMap[keyList[i]];
	    if(!vo.LOAN_ID){
			continue;
	    }
	    if(vo.SPEC_KIND == 16){
	    	needConfirm_SPEC_KIND = true;
        	break;
		}
	}
	for(var i= 0; i<keyList.length ;i++){
	    var vo = A271TmpMap[keyList[i]];
	    if(!vo.LOAN_ID){
			continue;
	    }
	    if(vo.IS_SEND == 1){
	    	needConfirm_IS_SEND = true;
        	break;
		}
	}
	
	if(needConfirm_SPEC_KIND && needConfirm_IS_SEND){
		return confirm("此案件類別為本金彈性還，請確認發送簡訊欄位正確與否，是否繼續試算/呈核?");
	}
	return true;
}

function linkToJY(){
	var url="http://jirs.judicial.gov.tw/GNNWS/NNWSS001.asp?classFlag=z&Search=y";
	window.open(url,"DSA2_2400");
}
var checkRecords;
var buttonActions = {
	 query:function(isASync, isNotShowMsg){
		tools.nodesToUpperCase(['A_REFER_ID']);
		VaildationSaves["A"].reset();
		if( !VaildationSaves["A"].validate() ) {return;}
		//action Name
		var actionName = "query";
		//傳遞參數
		var queryData = PageUI.getContentValues( ContentSaves["A"] );
		CSRUtil.keepParamsManager.put(queryData);
		queryData.INST_LEVEL = $('INST_LEVEL').value;				
		checkRecords = areaB_grid.getCheckedRecord();
		//成功動作
		var successAction = function(resp){	
			<%--[20240326] 資料檢核--%>
			if(resp.checkAlertMsg && !isNotShowMsg){
				alert(resp.checkAlertMsg);
			}
			ContentSaves["B"].load(resp.rtnList);
			var records = areaB_grid.getAllRecords();
			var SEQ_NO = records[records.size()-1].SEQ_NO;
			if(checkRecords.size()!=0){
				SEQ_NO = checkRecords[0].SEQ_NO;
			}
			if(isNotShowMsg && isNotShowMsg!=true){
				$$('#tableUiGrid input[type="radio"]').each( 
					function(ele){;		
						if(ele.value==SEQ_NO){
							ele.click();
						}
					}
				);
			}
		};
		//失敗動作
		var errorAction = function(resp){ };
			
    	  	 
		buttonActions.clearAll();
		//呼叫AJAX
		tools.ajaxPost(actionName, queryData, successAction, errorAction, isASync, isNotShowMsg);
	}
	,queryDetail:function(record, isNotShowMsg){
		//動作名稱
		var actionName = "queryDetail";
		//傳遞參數
		var queryData = PageUI.getContentValues( ContentSaves["A"] );
		queryData["recordMap"] = record;

		var params = {"queryData":Object.toJSON(queryData)};
		//成功動作

		var successAction = function(resp){
			//取得各欄位資料
			var A271voList = resp.A271voList;
			var record = resp.recordMap;
			var FILE_LIST = resp.FILE_LIST;
			var hisMap = resp.hisMap;

			PageUI.setContentValues( ContentSaves["C"] , record , true , true );
			RecrodsControl.loadin("D" , A271voList);

			var sumMap = resp.sumMap;
			sumMap.GAGE_ADDR = record.GAGE_ADDR;
			PageUI.setContentValues( ContentSaves["D1"] , sumMap , true , true );

			record.YEAR_EXISTS_BEG = record.EXISTS_BEGDT ? stringToDate_Y2K(record.EXISTS_BEGDT).getFullYear()-1911 : "";
			record.MONTH_EXISTS_BEG = record.EXISTS_BEGDT ? stringToDate_Y2K(record.EXISTS_BEGDT).getMonth()+1 : "";
			record.YEAR_EXISTS_END = record.EXISTS_ENDDT ? stringToDate_Y2K(record.EXISTS_ENDDT).getFullYear()-1911 : "";
			record.MONTH_EXISTS_END = record.EXISTS_ENDDT ? stringToDate_Y2K(record.EXISTS_ENDDT).getMonth()+1 : "";
			
			

			record.YEAR_FIREINSU_BEG = record.FIREINSU_BEGDT ? stringToDate_Y2K(record.FIREINSU_BEGDT).getFullYear()-1911 : "";
			record.MONTH_FIREINSU_BEG = record.FIREINSU_BEGDT ? stringToDate_Y2K(record.FIREINSU_BEGDT).getMonth()+1 : "";
			record.YEAR_FIREINSU_END = record.FIREINSU_ENDDT ? stringToDate_Y2K(record.FIREINSU_ENDDT).getFullYear()-1911 : "";
			record.MONTH_FIREINSU_END = record.FIREINSU_ENDDT ? stringToDate_Y2K(record.FIREINSU_ENDDT).getMonth()+1 : "";

			PageUI.setContentValues( ContentSaves["D2"] , record , true , true );
			record.YEAR_BEGIN = record.BEGIN_DATE ? stringToDate_Y2K(record.BEGIN_DATE).getFullYear()-1911 : "";
			record.MONTH_BEGIN = record.BEGIN_DATE ? stringToDate_Y2K(record.BEGIN_DATE).getMonth()+1 : "";			
			record.PAY_STATUS = record.PAY_STATUS ? record.PAY_STATUS : "0";
			record.JCIC_STATUS = record.JCIC_STATUS ? record.JCIC_STATUS : "0";
			record.IS_GUARDIAN = record.IS_GUARDIAN ? record.IS_GUARDIAN : "0";
			record.IS_REAPPR = record.IS_REAPPR ? record.IS_REAPPR : "0";
			PageUI.setContentValues( ContentSaves["E"] , record , true , true );
						
			$('E_DOM3').innerHTML = record.BOSS_COMMENT;

			areaE_grid.load(FILE_LIST);
			if(resp.showF){
				PageUI.setContentValues( ContentSaves["F"] , hisMap , true , true );
				hideBlock('areaG');
				showBlock('areaF');
			}else{
				PageUI.setContentValues( ContentSaves["G"] , hisMap , true , true );
//				if (hisMap.CHIEF_DATE) {
//					var CHIEF_DATE_HTML = hisMap.CHIEF_DATE.replace('.','').replace('.','');
//					if(CHIEF_DATE_HTML && diffDayROC(CHIEF_DATE_HTML, "1010201") > 0){
//						$('areaG').innerHTML = $('areaG').innerHTML.replace('審查副理','審查科長');
//					}
//				}
				hideBlock('areaF');
				showBlock('areaG');
			}

			//button顯示控制
			doButtonControl(record);
			
			//金額欄位請自動加千分號
			$$('#areaD input[datatype="number"]').each(
				function(obj){
					obj.value = CSRUtil.$fmt(obj.value, "#,###.####");
				}
			);			

			$('F_SUM_REMAIN_AMT').innerHTML = CSRUtil.$fmt($('F_SUM_REMAIN_AMT').innerHTML, "#,###.##");
			$('F_SUM_OLD_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt($('F_SUM_OLD_DUTY_PAYMENT').innerHTML, "#,###.##");
			$('F_SUM_NEW_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt($('F_SUM_NEW_DUTY_PAYMENT').innerHTML, "#,###.##");

			//$('E_RATE1').value = CSRUtil.$fmt($('E_RATE1').innerHTML, "####.##");
			//$('E_RATE2').value = CSRUtil.$fmt($('E_RATE2').innerHTML, "####.##");
			$('E_PAYMENT_RATE').value = CSRUtil.$fmt($F('E_PAYMENT_RATE'), "####.##");
		
			$('E_REMAIN_AMT').value = CSRUtil.$fmt($('E_REMAIN_AMT').innerHTML, "#,###.####");
			$('E_APPR_AMT').value = CSRUtil.$fmt($F('E_APPR_AMT'), "#,###.####");
			$('E_REMAIN_AMT2').value = CSRUtil.$fmt($('E_REMAIN_AMT2').innerHTML, "#,###.####");
			$('E_APPR_REALVALUE').value = CSRUtil.$fmt($F('E_APPR_REALVALUE'), "#,###.####");
			$('E_CRED_COMMENT').innerHTML = record.CRED_COMMENT;
			$('E_INPUT_COMMENT').value = record.INPUT_COMMENT;
			
			var C_BORROW_ID_GROUP = $('C_BORROW_ID_GROUP');
			if(C_BORROW_ID_GROUP.innerHTML == '非有效件'){
				C_BORROW_ID_GROUP.hide();
				C_BORROW_ID_GROUP.next().show();
			}else{
				C_BORROW_ID_GROUP.show();
				C_BORROW_ID_GROUP.next().hide();
			}
			var C_REFER_ID_GROUP = $('C_REFER_ID_GROUP');
			if(C_REFER_ID_GROUP.innerHTML == '非有效件'){
				C_REFER_ID_GROUP.hide();
				C_REFER_ID_GROUP.next().show();
			}else{
				C_REFER_ID_GROUP.show();
				C_REFER_ID_GROUP.next().hide();
			}
			
			if(!isClearEMailSelect){
				isClearEMailSelect = true;
			}
			
		};
		//失敗動作
		var errorAction = function(resp){ };

		buttonActions.clearDetails();

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction, true, isNotShowMsg);
	}

	,doUpdate:function(record){
		if(!doValidation()){
			return;
		}
		<%--[20240326]資料檢核--%>
		if(!doFlexValidation()){
			return;
		}
		
		
  		isClearEMailSelect = false;

		//動作名稱
		var actionName = "update";
		//傳遞參數
		var queryData = {};
		queryData.A271voList = PageUI.getContentValues( ContentSaves["D"] );
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REMAIN_AMT = $('E_REMAIN_AMT').innerHTML.replace(/,/gi,'') * 10000;
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;
		queryData.DTDSA270vo.SEQ_NO = $("C_SEQ_NO").innerHTML;
		
		queryData.DTDSA270vo.EXISTS_BEGDT = toY2K($("F_YEAR_EXISTS_BEG").value + append0($("F_MONTH_EXISTS_BEG").value) + '01');
		queryData.DTDSA270vo.EXISTS_ENDDT = toY2K($("F_YEAR_EXISTS_END").value + append0($("F_MONTH_EXISTS_END").value) + '01');
		queryData.DTDSA270vo.FIREINSU_BEGDT = toY2K($("F_YEAR_FIREINSU_BEG").value + append0($("F_MONTH_FIREINSU_BEG").value) + '01');
		queryData.DTDSA270vo.FIREINSU_ENDDT = toY2K($("F_YEAR_FIREINSU_END").value + append0($("F_MONTH_FIREINSU_END").value) + '01');
		queryData.DTDSA270vo.BEGIN_DATE = toY2K($("E_YEAR_BEGIN").value + append0($("E_MONTH_BEGIN").value) + '01');


		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){			
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		buttonActions.clearDetails();

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);		
		

	}
	,doConfirm:function(record){
		if(!doValidation()){
			return;
		}
		<%--[20240326]資料檢核--%>
		if(!doFlexValidation()){
			return;
		}
  		isClearEMailSelect = false;
		
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;
		queryData.DTDSA270vo.REMAIN_AMT = $('E_REMAIN_AMT').innerHTML.replace(/,/gi,'') * 10000;
		
		queryData.DTDSA270vo.EXISTS_BEGDT = toY2K($("F_YEAR_EXISTS_BEG").value + append0($("F_MONTH_EXISTS_BEG").value) + '01');
		queryData.DTDSA270vo.EXISTS_ENDDT = toY2K($("F_YEAR_EXISTS_END").value + append0($("F_MONTH_EXISTS_END").value) + '01');
		queryData.DTDSA270vo.FIREINSU_BEGDT = toY2K($("F_YEAR_FIREINSU_BEG").value + append0($("F_MONTH_FIREINSU_BEG").value) + '01');
		queryData.DTDSA270vo.FIREINSU_ENDDT = toY2K($("F_YEAR_FIREINSU_END").value + append0($("F_MONTH_FIREINSU_END").value) + '01');
		queryData.DTDSA270vo.BEGIN_DATE = toY2K($("E_YEAR_BEGIN").value + append0($("E_MONTH_BEGIN").value) + '01');

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//動作名稱
		var actionName = "confirm";
		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};
		//呈核確認動作
		var confirmAction = function(resp){
			var checkConfirmMsg = resp.checkConfirmMsg;
			if(checkConfirmMsg){
				checkConfirmMsg = checkConfirmMsg.replace(/\\r|\\n|\\r\\n/g, "\n");
				if(confirm(checkConfirmMsg)){
					params["STEP"] = "2";
					tools.ajaxPost(actionName, params, successAction, errorAction);
				}
			}else{
				successAction(resp);
			}			
		}

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, confirmAction, errorAction);

	}
	,doCelConfirm:function(record){
		if(!doValidation()){
			return;
		}
		
  		isClearEMailSelect = false;

		//動作名稱
		var actionName = "celconfirm";
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;
		queryData.DTDSA270vo.REMAIN_AMT = $('E_REMAIN_AMT').innerHTML.replace(/,/gi,'') * 10000;
		
		queryData.DTDSA270vo.EXISTS_BEGDT = toY2K($("F_YEAR_EXISTS_BEG").value + append0($("F_MONTH_EXISTS_BEG").value) + '01');
		queryData.DTDSA270vo.EXISTS_ENDDT = toY2K($("F_YEAR_EXISTS_END").value + append0($("F_MONTH_EXISTS_END").value) + '01');
		queryData.DTDSA270vo.FIREINSU_BEGDT = toY2K($("F_YEAR_FIREINSU_BEG").value + append0($("F_MONTH_FIREINSU_BEG").value) + '01');
		queryData.DTDSA270vo.FIREINSU_ENDDT = toY2K($("F_YEAR_FIREINSU_END").value + append0($("F_MONTH_FIREINSU_END").value) + '01');
		queryData.DTDSA270vo.BEGIN_DATE = toY2K($("E_YEAR_BEGIN").value + append0($("E_MONTH_BEGIN").value) + '01');

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);

	}
	,doAgree:function(record){
		if(!doValidation()){
			return;
		}

		//動作名稱
		var actionName = "agree";
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}

	,doReject:function(record){
		if(!doValidation()){
			return;
		}

		//動作名稱
		var actionName = "reject";
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}

	,doReject1:function(record){
		//if(!doValidation()){
		//	return;
		//}

		//動作名稱
		var actionName = "reject1";
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
	,doCancelReject1:function(record){
		//if(!doValidation()){
		//	return;
		//}

		//動作名稱
		var actionName = "cancelreject1";
		//傳遞參數
		var queryData = {};
		queryData.DTDSA270vo = PageUI.getContentValues( ContentSaves["E"] );
		queryData.DTDSA270vo.REFER_ID = $("C_REFER_ID").innerHTML;

		queryData.DTDSA195vo = {};
		queryData.DTDSA195vo.AGENT_DEPT = $("E_AGENT_DEPT").value;
		queryData.DTDSA195vo.AGENT_ID = $("AGENT_ID").value;
		queryData.DTDSA195vo.AGENT_NAME = $("AGENT_NAME").innerHTML;
		queryData.DTDSA195vo.DIV_NO = $("DIV_NO").value;
		queryData.STROP = $("E_STROP").value;

		queryData.INPUT_COMMENT = $F('E_INPUT_COMMENT');
		queryData.INST_LEVEL = $("INST_LEVEL").value;

		var params = {"queryData":Object.toJSON(queryData)};
		var SEQ_NO = $("C_SEQ_NO").innerHTML;

		//成功動作
		var successAction = function(resp){
			reQuery(SEQ_NO);
		};

		var errorAction = function(resp){ };

		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
		
	,clearDetails:function(){
		if(isClearEMailSelect){
			emptyE.STROP = $("E_STROP").value;
		}else{
			emptyE = {};
			emptyE.PAY_STATUS = "0";
			emptyE.JCIC_STATUS = "0";
			emptyE.IS_GUARDIAN = "0";
			emptyE.IS_REAPPR = "0";
		}
		
		PageUI.setContentValues( ContentSaves["C"] , {APPLY_ID:dataMainMap["APPLY_ID"] , APPLY_PROCESS_NM:dataMainMap["APPLY_PROCESS_NM"]} , true , true );
		RecrodsControl.clearAll("D");		
		PageUI.setContentValues( ContentSaves["D1"] , null , true , true );
		PageUI.setContentValues( ContentSaves["D2"] , null , true , true );
		PageUI.setContentValues( ContentSaves["E"] , emptyE , true , true );
		PageUI.setContentValues( ContentSaves["F"] , null , true , true );
		PageUI.setContentValues( ContentSaves["G"] , null , true , true );
		PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD"] );
		
		VaildationSaves["D"].reset();
		VaildationSaves["D1"].reset();
		VaildationSaves["D2"].reset();
		VaildationSaves["E"].reset();
		
		if(isClearEMailSelect){
			$("E_STROP").selectedIndex = 0;
			E_STROP_change();
		}
		$('E_DOM3').innerHTML = '';
		$('E_AGREE_LEVEL').selectedIndex = 0;
		
		//清除file欄位
     	$('divR').innerHTML = '';
     	$('divR').innerHTML = '<input id="filePath" name="filePath" type="file" class="button" size="50" value="瀏覽"  >';
	}
	,clearAll:function(){
		dataMainMap = {};
		ContentSaves["B"].load();
		areaE_grid.load([]);
		buttonActions.clearDetails();
		PageUI.setButtonsEnable( recordsControlButtonArea , [] );
	}
	,print:function(){
		
		var records = areaB_grid.getCheckedRecord();
		if(records.length==0){
			alert('請先選取資料後才可列印');
			return;
		}

		var queryData = {};			
		queryData.REFER_ID = $('A_REFER_ID').value;	
		queryData.SEQ_NO = records[0].SEQ_NO;	
		queryData.INST_LEVEL = $('INST_LEVEL').value;			
					
		
		var url = "<%=dispatcher%>/DSA2_2401/prompt?queryData="+Object.toJSON(queryData);	
		window.open(url,"DSA2_2401", "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");			
	}
}

function reQuery(SEQ_NO){	
	buttonActions.query(false, true);
	
	var records = areaB_grid.getAllRecords();
	for(var i=0;i<records.length;i++){				
		if(records[i].SEQ_NO == SEQ_NO){
			buttonActions.queryDetail(records[i], true);
			break;
		}
	}
	
	RadioOnClick(SEQ_NO);
}

function doButtonControl(record){

	//預設
	$('BTN_CONFIRM').value = '呈核';

	var INST_LEVEL = $F('INST_LEVEL');
	var AGREE_PROCESS = record.AGREE_PROCESS || 0;
	var AGREE_LEVEL = record.AGREE_LEVEL;
	var IS_AGREE = record.IS_AGREE;
	var IS_END = record.IS_END;	
	
	$('E_UPLOAD').disabled = true;	
	$$('input[name=singleRG]').each(function(btn) {
		$(btn).disabled = true;
	});	

	if(INST_LEVEL == 20){ //徵信組員
		if (AGREE_PROCESS <= 20 || IS_AGREE == 'N'){
			$('BTN_CONFIRM').value = '繼續呈核';
			
			//呈核、新增檔案、刪除檔案:enable
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM"] );
			
		}
		if (AGREE_PROCESS <= 20 && IS_AGREE == 'Y'){
		    //取消呈核:enable
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CELCONFIRM"] );
		}
		
		//試算:
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/

		if( AGREE_PROCESS == 20 && IS_AGREE != 'Y'){
			$('BTN_UPDATE').disabled = false;
		}else{
			$('BTN_UPDATE').disabled = true;
		}
		
		if( IS_END != 'Y'){//案件未結案
			$('E_UPLOAD').disabled = false;//新增檔案按鈕
			$$('input[name=singleRG]').each(function(btn) {
				$(btn).disabled = false;//刪除按鈕
			});			
		}
	} else if (INST_LEVEL == 30){
		if ((AGREE_PROCESS == 20 || IS_AGREE == 'Y') || (AGREE_PROCESS == 30 || IS_AGREE == 'N')){
		
			$('BTN_CONFIRM').value = '繼續呈核';

			if (AGREE_LEVEL == 30 || $F('E_AGREE_LEVEL') == 30 && IS_END != 'Y') {
				//核准:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_AGREE","BTN_REJCT1","BTN_CANCELREJCT1"] );
			} else {
				//繼續呈核、退回:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_REJCT1","BTN_CANCELREJCT1"] );
			}
		}
				
		//試算:
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/
		$('BTN_UPDATE').disabled = true;
		
		
	} else if (INST_LEVEL == 40){
		if ((AGREE_PROCESS == 30 || IS_AGREE == 'Y') || (AGREE_PROCESS == 40 || IS_AGREE == 'N')){
					
			if (AGREE_LEVEL == 40 || $F('E_AGREE_LEVEL') == 40 && IS_END != 'Y') {
				//核准:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_AGREE"] );
			} else {
				//繼續呈核、退回:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT"] );
			}
		}
		
		//試算:
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/
		$('BTN_UPDATE').disabled = true;
		
	} else if (INST_LEVEL == 50){
		if ((AGREE_PROCESS == 40 || IS_AGREE == 'Y') || (AGREE_PROCESS == 50 || IS_AGREE == 'N')){
		
			if (AGREE_LEVEL == 50 && IS_END != 'Y') {
				//核准:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_AGREE"] );
			} else {
				//繼續呈核、退回:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT"] );
			}
		}	
		
		//試算: 
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/
		$('BTN_UPDATE').disabled = true;
		
	} else if (INST_LEVEL == 60){
		if ((AGREE_PROCESS == 50 || IS_AGREE == 'Y') || (AGREE_PROCESS == 60 || IS_AGREE == 'N')){
			
			if (AGREE_LEVEL == 60 && IS_END != 'Y') {
				//核准:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_AGREE"] );
			} else {
				//繼續呈核、退回:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT"] );
			}
		}
		
		//試算:
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/
		$('BTN_UPDATE').disabled = true;
		<%--[2020514] 修改件 新增 副總經理(二)邏輯判斷--%>
	} else if (INST_LEVEL == 70){
		if ((AGREE_PROCESS == 60 || IS_AGREE == 'Y') || (AGREE_PROCESS == 70 || IS_AGREE == 'N')){
			
			if (AGREE_LEVEL == 70 && IS_END != 'Y') {
				//核准:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT","BTN_AGREE"] );
			} else {
				//繼續呈核、退回:enable
				PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CONFIRM","BTN_REJCT"] );
			}
		}
		
		<%--//試算:
		/*	若批示層級為徵信人員(INST_LEVEL=20)
			且核准進度非為徵信人員處理中(rtnMap.AGREE_PROCESS==20)
			且尚未核准(rtnMap.IS_AGREE <>Y)，試算按鈕可使用，否則試算按鈕disabled。*/--%>
		$('BTN_UPDATE').disabled = true;
	}
	
	if (IS_END == 'Y') {  //是否結案
   		// 繼續呈核、呈核:disable
   		$('BTN_CONFIRM').disabled = true;
	}

}


//重新計算餘額、放款率、貸放餘額
function reCalculate(){
	var sum = 0;
	$$('#areaD input[datatype="number"]').each(
		function(obj){
			var id = obj.id;
			if(id.indexOf("REMAIN_AMT") > 0){
				var value = obj.getValue();
				if(!isNaN(parseInt(value, 10))){
					sum = sum + Number(value);
				}else{
					obj.value="";
				}
			}
		}
	);							
	$('F_SUM_REMAIN_AMT').innerHTML = CSRUtil.$fmt(sum, "#,###.##");
	var valREMAIN_AMT = sum / 10000;
	$('E_REMAIN_AMT').innerHTML = CSRUtil.$fmt(valREMAIN_AMT, "#,###.####");
	$('E_REMAIN_AMT2').innerHTML = CSRUtil.$fmt(valREMAIN_AMT, "#,###.####");
	if ($('E_APPR_AMT').getValue() != 0) {
		$('E_RATE1').innerHTML = CSRUtil.$fmt(valREMAIN_AMT / $('E_APPR_AMT').getValue() * 100, "####.##");
	} else {
		$('E_RATE1').innerHTML = "0";
	}
	if ($('E_APPR_REALVALUE').getValue() != 0) {
		$('E_RATE2').innerHTML = CSRUtil.$fmt(valREMAIN_AMT / $('E_APPR_REALVALUE').getValue() * 100, "####.##");
	} else {
		$('E_RATE2').innerHTML = "0";
	}
	
	var sum = 0;
	var sum2 = 0;
	$$('#areaD input[datatype="number"]').each(
		function(obj){
			var id = obj.id;
			if(id.indexOf("OLD_DUTY_PAYMENT") > 0){
				var value = obj.getValue();
				
				if(!isNaN(parseInt(value, 10))){
					sum = sum + Number(value);
				}else{
					obj.value="";
				}
			}
			
			if(id.indexOf("NEW_DUTY_PAYMENT") > 0){
				var value = obj.getValue();
				if(!isNaN(parseInt(value, 10))){
					sum2 = sum2 + Number(value);
				}else{
					obj.value="";
				}
			}		
		}
	);
	
	$('F_SUM_OLD_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt(sum, "#,###.##");	
	$('F_SUM_NEW_DUTY_PAYMENT').innerHTML = CSRUtil.$fmt(sum2, "#,###.##");				
}

function RadioOnClick(SEQ_NO){
	$$('#tableUiGrid input[type="radio"]').each( 
		function(ele){
			ele.checked=false;
			if(SEQ_NO==ele.value){
				ele.checked=true;						
			}
		}
	);
}

function append0(v){
	if( v<10 && v.substring(0,1) !='0'){		
	  	return '0'+v;
	}
	
	return v;
}


var RecrodsControl = {
	 createRecord : function ( area , value ){
		/*var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		if(type !== 2){
			var areaTable = RecrodsControl.ContentsSave[area];
			if(type === 1){
				RecrodsControl.commitRecords( area, areaTable );
			}*/
			var areaTable = RecrodsControl.ContentsSave[area];
			var isCreate = areaTable ? false : true ;
			var setting = isCreate ? value : RecrodsControl.ContentsSettingSave[area];
			if(!JsUtils.isObject(setting)){
				return;
			}
			var copySetting = JsUtils.cloneObject(setting);
			copySetting.KeyToId = function(key){ return (area+"_"+key+(isCreate ? "_HEADER" : "_"+( RecrodsControl.contentsCount[area]|| 0)));  };

			if(!isCreate){
				copySetting.elem = areaTable;
				var isValueObject = value && JsUtils.isObject(value);
				//var showType = isValueObject ? 1 : 0;
				var showType = 0;
				var tbody = PageUI.createContent( copySetting , null , showType  );
				if(isValueObject){
					PageUI.setContentValues( tbody , value , true , true );
					RecrodsControl.contentsStatusSave[area] = 0;
				}else{
					RecrodsControl.contentsStatusSave[area] = 2;
				}
				var records = RecrodsControl.records[area]
				records[records.length] = tbody;
				RecrodsControl.contentsCount[area] =  RecrodsControl.contentsCount[area] + 1;
				if(isValueObject){
					if(RecrodsControl.deleteNodeSave[area]){
						PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD" , area+"_DEL"] );
					}else{
						PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"] );
					}
				}else{
					PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_CAN"] );
				}
				theDSZ01000control.createDSZ01000( tbody );
				RecrodsControl.contentsValidationSave[tbody.getAttribute("id")] = new Validation( tbody, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});
				return tbody;
			}else{
				copySetting.clearChildElements = true;
				copySetting.noContent = true;
				copySetting.noHeader = false;
				var tbody =  PageUI.createContent( copySetting , null , 1  );
				RecrodsControl.ContentsSave[area] = tbody.parentNode;
				RecrodsControl.records[area] = [];
				RecrodsControl.contentsCount[area] = 0;
				RecrodsControl.ContentsSettingSave[area] = setting;
				RecrodsControl.createButtons( area );
				PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"] );
				return tbody;
			}
		/*}else{
			 RecrodsControl.editRecords( area, areaTable );
		}*/
	}
	,createButtons: function( area ){
		var contentTable = RecrodsControl.ContentsSave[area];
		var buttons = {};
		buttons[area+"_ADD"] = { header:"新增", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.createRecord( area ); } } };
		//buttons[area+"_MOD"] = { header:"修改", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.editRecords( area ); } } };
		//buttons[area+"_CAN"] = { header:"取消", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.rollbackRecords( area ); } } };
		buttons[area+"_DEL"] = { header:"刪除", ignoreAuth:true,	events:{ "click":function(target){ RecrodsControl.deleteRecords( area ); } } };

		RecrodsControl.ButtonContentsSave[area] = PageUI.createButtonArea( contentTable , { changeForOneButton:false, buttonOnRight:false, clearChildElements:false, buttons:buttons });
	}
	,editRecords:function( area ){
		var contentTable = RecrodsControl.ContentsSave[area];
		var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		if( type === 0){
			PageUI.setContentsDisplay( contentTable , 0 );
			RecrodsControl.contentsStatusSave[area] = 1;
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_MOD",area+"_CAN" ], [area+"_DEL"] );
		}else if ( type === 1 ){
			RecrodsControl.commitRecords( area, contentTable  );
		}else if( type === 2){
			RecrodsControl.commitRecords( area, contentTable.lastChild );
		}
	}
	,selectToDelete:function( area , node ){
		var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		//if( type == 2){ return; }
		 RecrodsControl.deleteNodeSave[area] = node;
		 PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_DEL"] ,[area+"_ADD",area+"_MOD",area+"_CAN"]);
	}
	,commitRecords:function( area, commitElem ){
		var checkResult = true;
		if(commitElem.tagName == "TBODY"){
			var tbodyId = commitElem.getAttribute("id");
			if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
				RecrodsControl.contentsValidationSave[tbodyId].reset();
				checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
			}else{
				alert("發生不明錯誤(MISSING ID)");
				checkResult = false;
			}
		}else if(commitElem.tagName == "TABLE"){
			var testBody = commitElem.firstChild.nextSibling;
			while(testBody){
				var tbodyId = testBody.getAttribute("id");
				if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
					RecrodsControl.contentsValidationSave[tbodyId].reset();
					checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
				}else{
					alert("發生不明錯誤(MISSING ID)");
					checkResult = false;
					break;
				}
				testBody = testBody.nextSibling;
			}
		}else{
			alert("發生不明錯誤(ERROR TYPE)");
			checkResult = false;
		}/*
		if(!checkResult) {return; }
		PageUI.commitContentValues( commitElem );
		PageUI.setContentsDisplay( commitElem , 1 );
		RecrodsControl.contentsStatusSave[area] = 0;
		var records = RecrodsControl.records[area];
		if( records && records.length > 0){
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"], [area+"_DEL"]);
		}else{
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"], [area+"_DEL"] );
		}*/
	}
	,rollbackRecords:function( area ){
		var contentTable = RecrodsControl.ContentsSave[area];
		var records = RecrodsControl.records[area];
		var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		if( type === 1){
			PageUI.rollbackContentValues( contentTable );
			PageUI.setContentsDisplay( contentTable , 1 );
		}else  if( type === 2){

			var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
			contentTable.removeChild(records[records.length - 1]);
			contentTable.lastChild.appendChild(buttonArea);
			records = records.splice(records.length-1 , 1 );
		}
		RecrodsControl.contentsStatusSave[area] = 0;
		if( records && records.length > 0){
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"], [area+"_DEL"] );
		}else{
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"], [area+"_DEL"] );
		}
	}
	,deleteRecords:function( area ){
		var deleElem = RecrodsControl.deleteNodeSave[area];
		if(!deleElem){ return; }
		var tbody = JsUtils.getParentByTagName(deleElem , "TBODY");
		if(!tbody) { return; }
		var contentTable = RecrodsControl.ContentsSave[area];
		var records = RecrodsControl.records[area];
		var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
		for( var i = 0 ; i < records.length ; i = i + 1 ){
			if(records[i] == tbody ){
				records = records.splice( i , 1 );
				RecrodsControl.contentsCount[area] = RecrodsControl.contentsCount[area] - 1;
				tbody.parentNode.removeChild(tbody);
				break;
			}
		}
		contentTable.lastChild.appendChild(buttonArea);
		if( RecrodsControl.contentsCount[area] > 0 ){
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [0] ,[area+"_ADD",area+"_MOD",area+"_CAN"]);
		}else{
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"]);
		}
		RecrodsControl.deleteNodeSave[area] = null;
		
		reCalculate();

	 }
	,loadin:function( area , records ){
		if(!JsUtils.isObject(RecrodsControl.ContentsSettingSave[area])){ return; }
		if(JsUtils.isArray(records)){
			for(var i = 0 ; i < records.length ; i = i + 1 ){
				 var tbody = RecrodsControl.createRecord( area , records[i] );
			}
		}
	}
	,clearAll:function(area){
		var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		if( type != 0 ){
			RecrodsControl.rollbackRecords(area);
		}
		var contentTable = RecrodsControl.ContentsSave[area];
		if(!JsUtils.isDOMObject(contentTable)){ return; }
		var buttonArea = RecrodsControl.ButtonContentsSave[area].parentNode.parentNode;
		var delBodys = RecrodsControl.records[area];
		for( var i = 0 ; i < delBodys.length  ; i = i + 1 ){
			contentTable.removeChild(contentTable.lastChild);
		}
		RecrodsControl.records[area] = [];
		RecrodsControl.contentsCount[area] = 0;
		contentTable.lastChild.appendChild(buttonArea);
		PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"]);
	}
	/*設定儲存*/
	,ContentsSave:{}
	,ButtonContentsSave:{}
	,ContentsSettingSave:{}
	/*產生的資料儲存*/
	,records:{}
	/* 0:saved , 1:edit , 2:new */
	,contentsStatusSave:{}
	,contentsCount:{}
	,contentsValidationSave:{}
	,deleteNodeSave:{}
}

var tools = {
	nodesToUpperCase:function( nodes ){
		if(JsUtils.isArray(nodes)){
			for(var i = 0 ; i < nodes.length ; i = i + 1 ){
				var testNode = JsUtils.getDOM( nodes[i]);
				if(testNode && testNode.tagName == "INPUT"){
					testNode.value = testNode.value.toUpperCase();
					PageUI.commitContentValue( testNode );
				}
			}
		}
	}
	,ajaxPost:function ( actionName, params, successAction, errorAction, isASync, isNotShowMsg){
		new Ajax.Request(
			"<%=dispatcher%>/DSA2_2400/" + actionName,
			{ 
			  asynchronous: isASync,
			  parameters: params,
			  onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
						successAction(resp);
					}
				}else if(errorAction){
					errorAction(resp);
				}
				
				if(isNotShowMsg){
					if(CSRUtil.isSuccess(resp)){
			  			resp.ErrMsg = '';
			  		}
			  	}
			}}
		);
	}
}

function vaildationRules(){
	Validation.addAllThese([
		['validateId', '身份證字號有誤，請檢查後重新輸入!', function(v) { 
			if(v==''){
				return true;
			}else{
				return dataMainMap ? (dataMainMap.COPR_CODE!=1 ? idCheck1(v):iscmpid(v) ): true;
			} 
		}]
		,['validateROCYear', '需為民國年格式', function(v) {
				if(v>0 && v<1000){
					return true;
				}
				return false;
		 }]
		,['validateROCMonth', '需為民國月格式', function(v) {
				if(v>0 && v<13){
					return true;
				}
				return false;
		 }]
		,['vaildateChecks', '必須至少選擇一項.', function(v , node ) {
			if( node.tagName != "INPUT" || node.getAttribute("type")!= "checkbox"){ return true; }
		 	var nodeName = node.getAttribute("name");
			var td = JsUtils.getParentByTagName( node , "TD");
			if(td && nodeName){
				var checks = td.getElementsByTagName("INPUT");
				for(var i = 0 ; i < checks.length ; i = i + 1 ){
					if(checks[i].getAttribute("type")=="checkbox" && checks[i].checked ){
						return true;
					}
				}
				return ( node != checks[0]);
			}
			return node.checked;
		 }]
		,['vaildatePreCheck', '不得空白.', function(v , node ) {
			var td = JsUtils.getParentByTagName( node , "TD");
			if(td){
				var checks = td.getElementsByTagName("INPUT");
				if(checks[1].checked && v==''){
					return false;
				}
			}
			return true;
		 }]
		,['vaildateCharCnts', '說明文字超過500字，請縮短字數', function(v , node ) {
			if(v.length>500){
				return false;
			}
			return true;
		 }]
	]);
}

theDSZ01000control = {
	create:function(){
		var sno = theDSZ01000control.DSZ01000saves.length;
		var div = JsUtils.createDOMElement("span" , {sno:sno , id:"autoDSZ01000"+sno , DSZ01000:true});
		theDSZ01000control.DSZ01000saves[sno] = div;
		return div;
	}
	,createDSZ01000: function( parent ){
		var saveNum = theDSZ01000control.DSZ01000saves.length;
		for( var i = saveNum-1 ; i >= 0  ; i = i - 1 ){
			var testNode = theDSZ01000control.DSZ01000saves[i];
			if(JsUtils.isDOMObject(testNode))
			{
				var aDSZ01000 = new DSZ01000(testNode, "2");
				theDSZ01000control.DSZ01000saves[i] =	aDSZ01000
				theDSZ01000control.displayControl( aDSZ01000 , testNode.getAttribute("display") );
			}else{
				break;
			}
		}
	}
	,get:function( node ,  rtnMap ){
		var preKey = node.getAttribute("preKey");
		var CODE = rtnMap[preKey+"_CODE"] || "";
		var ruleId = node.parentNode.getAttribute("autoInputValueKey");
		var ruleMap = theDSZ01000control.showRules[ruleId];
		if( ruleMap[CODE] && ruleMap[CODE] != 'none'){
			var sno = node.getAttribute("sno");
			var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
			if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
				rtnMap[preKey+"_ZIP"] = aDSZ01000.getINPUT_ZIPCODE();
				rtnMap[preKey+"_ADDR"] = aDSZ01000.getINPUT_ADDR();
			}
			if(!rtnMap[preKey+"_ADDR"] ){
				rtnMap[preKey+"_ZIP"] = "";
				rtnMap[preKey+"_ADDR"] = "";
				return "";
			}else{
				return rtnMap[preKey+"_ZIP"] +" "+ rtnMap[preKey+"_ADDR"];
			}
		}
		rtnMap[preKey+"_ZIP"] = "";
		rtnMap[preKey+"_ADDR"] = "";
		return "";
	}
	,set:function( node , value , valuesMap ){
		var sno = node.getAttribute("sno");
		var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
		if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
			if(JsUtils.isObject(valuesMap)){
				var preKey = node.getAttribute("preKey");
				aDSZ01000.setINPUT_ZIPCODE(valuesMap[preKey+"_ZIP"]);
				aDSZ01000.setINPUT_ADDR(valuesMap[preKey+"_ADDR"]);
				var CODE = valuesMap[preKey+"_CODE"];
				var ruleId = node.parentNode.getAttribute("autoInputValueKey");
				var ruleMap = theDSZ01000control.showRules[ruleId];
				theDSZ01000control.displayControl( aDSZ01000 , JsUtils.isObject(ruleMap) ? ruleMap[CODE] : '' );
			}else{
				theDSZ01000control.displayControl( aDSZ01000 , valuesMap );
			}
		}
	}
	,displayControl:function( aDSZ01000 , type ){
		type = JsUtils.isString(type) ?type.toLowerCase():"";
		switch(type){
			default:
			case 'none':
				aDSZ01000.displayOnly(true);
				aDSZ01000.display4INPUT_ZIPCODE();
				aDSZ01000.display4INPUT_ADDR();
				break;
			case 'display':
				aDSZ01000.displayOnly(true);
				aDSZ01000.display4INPUT_ZIPCODE();
				aDSZ01000.display4INPUT_ADDR();
				break;
			case 'edit':
				aDSZ01000.displayOnly(false);
				aDSZ01000.display4INPUT_ZIPCODE(1);
				aDSZ01000.display4INPUT_ADDR(2);
				break;
		}
	}
	,displayControl2:function( elem , changeValue ){
		var sno = elem.firstChild.getAttribute("sno");
		if(!JsUtils.isNumeric(sno) || sno > (theDSZ01000control.DSZ01000saves.length-1) ){ return; }
		var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
		var ruleId = elem.getAttribute("autoInputValueKey");
		var ruleMap = theDSZ01000control.showRules[ruleId];
		theDSZ01000control.displayControl( aDSZ01000 , JsUtils.isObject(ruleMap) ? ruleMap[changeValue] : '' );

	}
	,DSZ01000saves : []
	,showRules:{
		CON_ADDR_ZIP:{"4":"edit","9":"edit" }
		,BUSS_ADDR_ZIP:{"9":"edit" }
		,SERV_ADDR_ZIP:{"9":"edit" }
	}

}


//--------------------------------------------------------------------------
// 下拉選單
//--------------------------------------------------------------------------
var selection = {
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, key, value, choiceValue, isCode_CodeNM){
		if(!key){
			key = "CODE";
		}
		if(!value){
			value = "CODE_NM";
		}

		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionList){
				for(var i = 0; i < optionList.length; i++){
					if(isCode_CodeNM){
						selection.create(tagID, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
					}else{
						selection.create(tagID, optionList[i][key], optionList[i][value], choiceValue);
					}
				}
			}
		}
	},
	// 依照傳入資料與id，產生下拉選單(資料為Map)
	createAll4Map:function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionMap){
				var dataKey = Object.keys(optionMap);
				dataKey.each(
					function(key){
						if(isCode_CodeNM){
							selection.create(tagID, key, key + " " + optionMap[key], choiceValue);
						}else{
							selection.create(tagID, key, optionMap[key], choiceValue);
						}
					}
				);
			}
		}
	},
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 0;
	},
	// 設定下拉選單(如果不在選項裡面，則預設為第一筆)
	setOptions:function(key, value){
		if(value || value == "0"){
			$(key).value = formatInput.text(value, false);

			if($(key).selectedIndex < 0){
				$(key).selectedIndex = 0;
			}
		}
	}
};

//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
function doTrimTextArea (val){
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
	if($(val).value.length>0){
		$(val).value = $(val).value.replace(/'/gi, "").replace(/"/gi, "");
		while(true){
			ln0 = $(val).value.length;
			while(true){
				ln1 = $(val).value.length;
				if($(val).value.indexOf('\r\n')>=0){
					//trim掉最後一個\r\n
					$(val).value = $(val).value.replace(/\r\n$/g, "");
					if(ln1 == $(val).value.length){
						break;	
					}
				}else{
					break;
				}
			}
			while(true){
				ln2 = $(val).value.length;
				if($(val).value.indexOf(' ')>=0){
					$(val).value = $(val).value.replace(/ $/g, "");
					if(ln2 == $(val).value.length){
						break;	
					}
				}else{
					break;
				}
			}

			if(ln0 == $(val).value.length){
				break;	
			}
		}
	}
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
}

</script>

</head>

<body>

<div id="areaA">A</div>
<div id="areaButton">Buttons</div>
<div id="areaB">
	<table id="tableUiGrid"></table>
</div>
<div id="areaC">C</div>
<div id="areaD" blockTitle="基本資料一">D</div>
<div id="areaD1" >D1</div>
<div id="areaD2" blockTitle="基本資料二">D2</div>
<div id="areaE" blockTitle="徵信狀況">E</div>
<div id="areaF" blockTitle="審核資料">F</div>
<div id="areaG" blockTitle="審核資料">G</div>

<div id="bar1"></div>

<div id="E_DOM1" >
	<form name="aForm" id="aForm" method="post" enctype="multipart/form-data" action="<%=dispatcher%>/DSA2_2400/upload" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<span id="divR" name="divR">
		<input id="filePath" name="filePath" type="file" class="button" size="50" value="瀏覽"  >
	</span>
	<input id="E_UPLOAD" name="E_UPLOAD" type="button" class="button" value="新增檔案" onClick="upload()" >
	<input type="hidden" name="FILE_NM_ALT" id="FILE_NM_ALT">
	<table id="tableUiGrid1"></table>
	<input type="hidden" name="REFER_ID" id="E_REFER_ID">
	<input type="hidden" name="SEQ_NO" id="E_SEQ_NO">
	<input type="hidden" name="BORROW_ID" id="E_BORROW_ID">
	<input type="hidden" name="INST_LEVEL"  value="${INST_LEVEL}" >
	</form>
</div>
<iframe id="uploadFrame" name="uploadFrame" width="0" height="0"></iframe>

<span id="E_DOM2" >
	<span>區域別</span>
	<select id="E_AGENT_DEPT" name="E_AGENT_DEPT" class="required">
		<option value="">請選擇</option>
		<c:forEach items="${CENTER_LIST}" var="item" varStatus="status">
			<option value="<c:out value="${item.DEPT_NO}"/>"><c:out value="${item.DEPT_NO}"/> <c:out value="${item.DEPT_NAME}"/></option>
		</c:forEach>
	</select>
	<span id="title1"></span>
	<span id="select1">
		<select name="ADCD" id="ADCD" class="required">
			<option value="">請選擇</option>
		</select>
	</span>
	<span id="title2"></span>
	<span id="select2">
		<select name="DIV_NO" id="DIV_NO" class="required">
			<option value="">請選擇</option>
		</select>
	</span>
	<span id="title3"></span>
	<input type="text" class="validateId" id="AGENT_ID" name="AGENT_ID"  size="12" maxlength="10" value="" >
	<span id="AGENT_NAME"></span>
	<input id="TYPE" name="TYPE" type="hidden"  >
</span>

<span id="E_DOM3" >
	
</span>

<span id="E_DOM4" >
	<a href="#" onClick="linkToJY()">(連結到司法院)</a>
</span>

<input id="INST_LEVEL" name="INST_LEVEL" type="hidden" value="${INST_LEVEL}" >

</body>
</html>
