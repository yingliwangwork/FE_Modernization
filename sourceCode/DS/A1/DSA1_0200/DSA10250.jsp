<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
Date        Version Description Author
2011/8/25   1.0     Created     柯玉芳 

@author 楊宗翰
@since 2011-09-06

[20191217] 修改件：
		   申請書190829001411-法金專案(受理) : 
           1 增欄位「ID種類」、「註冊國家」
           2 調整檢核
           3 取消保證人與借款人關係之卡控

[20220826] 修改件 立案單號:220713008387 修改人員:何宇倫
	1.目前服務單位「電話」：若「職業類別」為703家庭主婦、707退休人員、710無業、股票投資人，電話非必填。
	2.非法金件時，(日)(夜)連絡電話：調整為非必輸值。

[20221121]
[申請書:221102005585]行動房貸送件年齡與資料保存時間調整
高強禾
-->


<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>



<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>

<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script><%-- 搜尋提示用 --%>

<%-- [20190626] 增加羅馬拼音欄位 --%>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javascript">

var VaildationSaves = {};
var ContentSaves = {};
var recordsControlButtonArea;

var dataMainMap = {};

//擔保品種類
var GAGE_TYPE = '';

//是否為外幣
var isFori =false;
var isCORP_DEPT;/* [20191217] */

//全形轉半形
var hForm = [" ","`","1","2","3","4","5","6","7","8","9","0","-","=","\\","!","@","#","$","%","^","&","*","(",")","_","+","|","[","]","{","}",";","'",":","\"",",",".","/","<",">","?","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
var fForm = ["　","、","１","２","３","４","５","６","７","８","９","０","－","＝","﹨","！","＠","＃","＄","％","︿","＆","＊","（","）","＿","＋","｜","〔","〕","｛","｝","；","’","：","”","，","。","∕","＜","＞","？","ａ","ｂ","ｃ","ｄ","ｅ","ｆ","ｇ","ｈ","ｉ","ｊ","ｋ","ｌ","ｍ","ｎ","ｏ","ｐ","ｑ","ｒ","ｓ","ｔ","ｕ","ｖ","ｗ","ｘ","ｙ","ｚ","Ａ","Ｂ","Ｃ","Ｄ","Ｅ","Ｆ","Ｇ","Ｈ","Ｉ","Ｊ","Ｋ","Ｌ","Ｍ","Ｎ","Ｏ","Ｐ","Ｑ","Ｒ","Ｓ","Ｔ","Ｕ","Ｖ","Ｗ","Ｘ","Ｙ","Ｚ"];

//建議清單：國家
var COUNTRY_List;

vaildationRules();

function init(){
	
	displayMessage();
	
	createUserInterface();
	buttonsAuth();
	
			
	if ('${APPLY_ID}' != "") {//接值
    	$('A_APPLY_ID').value = '${APPLY_ID}';
  	} else {
    	//保留參數管理-取得受理編號
    	$('A_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
   	}   
   	if($('A_APPLY_ID').value){
    	buttonActions.query();
   	}
	
	<%-- [20191216] 註冊國家 suggest --%>		
	//建議清單：國家
    <c:if test="${not empty COUNTRY_List}">
		COUNTRY_List = ${COUNTRY_List};
	</c:if>	 			 
	Suggest.add( 
		"C_COUNTRY_NM",            
		Suggest.LIST,
		COUNTRY_List, 
		{ 				
			noCookies : true,
			option_key : "COUNTRY_NM", 
			remark_key : "COUNTRY", 					
			startLength : 2,
			callBackFunc : function(node,rec){						
				$('C_COUNTRY').value = rec ? rec['COUNTRY'] : '';
			}
		}
	);
	//初始預設「中華民國」
	$('C_COUNTRY_NM').setValue('中華民國');
	$('C_COUNTRY').hide();

}

function buttonsAuth(){ 
	if(window.authButtons){
		<dz:grantButtons FUNC_ID="DSA10250" ignored="true"/> 
	}
}

function createUserInterface(){
//PageUI create
	PageUI.createPage("DSA10250" , "受理作業" , "保人資料輸入", '${param.titleNotDisplay}' == 'Y');
	PageUI.loadin(["areaA","areaButton","areaB","areaC","areaD","areaE","areaF","areaG","areaH"] ,2)
	
//-------------------------------------------------------------------------------------------------
// area A Query
//	
//-------------------------------------------------------------------------------------------------
	
	var areaAcontent = PageUI.createContent( { 
		elem:"areaA", id:"areaA", headerInTop:false, dataColumns: 1, noContent:false, noHeader:false
		,columnProps:[10,80], clearChildElements:true, KeyToId:function(key){ return "A_"+key; },
		contents:[
			{ header:"受理編號", values:[
				 { key:"APPLY_ID", type:"text" , attrs:{ className:"required validateMaxLength validationAPPLY_ID" , size :13 , maxLength:11} }
			]}
		]
	} , null , 0 );
	var queryButtonArea = PageUI.createButtonArea( areaAcontent , { changeForOneButton:false, buttonOnRight:true,
		buttons:{
			B0001:{ id:"BTN_QUERY", header:"查詢",ignoreAuth:true, events:{ "click":buttonActions.query }	}
		}
	});
	
	
	ContentSaves["A"] = areaAcontent;
	VaildationSaves["A"] = new Validation( areaAcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle : "條件"});
	
	//debugMode
	//PageUI.setContentValues( areaAcontent ,{"APPLY_ID":"06014925007"} , true , true );
	
	
//-------------------------------------------------------------------------------------------------
// area  Control Buttons
//	
//-------------------------------------------------------------------------------------------------
	recordsControlButtonArea = PageUI.createButtonArea( "areaButton" , { changeForOneButton:false, buttonOnRight:false, clearChildElements:true, 
		buttons:{
			 B0002:{ id:"BTN_CLEAR",header:"清除",ignoreAuth:true,events:{ 
			  	"click":function(target){
					buttonActions.clearDetails();
					PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD"] );
				} 
			 }}
			,B0003:{ id:"BTN_ADD" , header:"新增",events:{ 
				"click": buttonActions.addDetail
			 }}
			,B0004:{ id:"BTN_MODIFY" , header:"修改",events:{ 
				"click":buttonActions.updateDetail
			 }}
			,B0005:{ id:"BTN_DELETE" , header:"刪除",events:{ 
				"click":buttonActions.deleteDetail
			 }}
		}
	});
	
	PageUI.setButtonsEnable( recordsControlButtonArea , ["A0001"] );
	
//-------------------------------------------------------------------------------------------------
// area B
//	
//-------------------------------------------------------------------------------------------------
	var areaB_grid = new TableUI({
		table:$('tableUiGrid'), pageSize: 5, allSortable: true, overDiv:false,
		<%-- [20240722] 難字調整 --%>
		afterLoad: function() {
			if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		},
		pageChange: function() {
			if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		},
		autoCheckBox:{
			type:"radio",
			action:function( checkbox , boxStatus , records){
				if(boxStatus){
					buttonActions.queryDetail(records[0]);
				}
			}
		},
		column:[
			{ header:"受理編號", key:"APPLY_ID"},
			{ header:"統一編號", key:"ID"},
			{ header:"姓名", key:"NAME", attrs:{style:"font-family:'EUDC'"}},<%-- [20240722]難字調整 --%>
			{ header:"姓名(羅馬拼音)", key:"NAME_RM"},
			{ header:"保證人與借款人關係", key:"RELATION_NM"},
			{ header:"保證人種類", key:"GUAR_KIND_NM"}
		]/*,
		afterLoad :function(){
			var radioBox = $('tableUiGrid').select("input[type=radio]");
			if(radioBox.length > 0){
				radioBox[0].checked = true;
				radioBox[0].fireEvent("onclick");
			}
		}*/
	});
	ContentSaves["B"] = areaB_grid;
//-------------------------------------------------------------------------------------------------
// area c
// 基本資料	
//-------------------------------------------------------------------------------------------------
	<%-- [20221121] "出生日期"和"歲"改用span並改ID,用於切換保人種類時改變顯示文字 --%>
	var birthdayHeader = new Element('span', {id:'C_BIRTHDAY_HEADER'}).update('出生日期');
	var ageDesc = new Element('span', {id:'C_AGE_DESC'}).update('歲');

	var areaCcontent = PageUI.createContent( { 
		 elem:"areaC", clearChildElements:true, KeyToId:function(key){ return "C_"+key; }
		,contents:[
			 { header:"受理編號", values:[ 
				 {key:"APPLY_ID" } 
			 ] }
			,{ header:"受理進度", values:[ 
				 {key:"APPLY_PROCESS_NM" } 
			 ] }
			,{ header:"姓名", values:[ 
				 {key:"NAME", type:"text" ,attrs:{ value:"", maxLength:32 ,size:30 ,fieldName:"姓名",  className:"required validateFullType validateHalfType validateMaxLength", alt:"ch" } }<%--[20240722]難字調整 --%>
                 <%-- [20191217] 增加 欄位,檢核 --%>
				,{key:"ID_TYPE", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.PLS_CHOOSE ,opts: selectionOptions.A020_ID_TYPE_List ,attrs:{ fieldName:"保人種類" , className:"required" }
					 <%-- [20191217] 增加 連動 --%>
					 ,events:{ "change":function(target){
						 <%-- [20221121] 下拉選單值抽出共用 --%>
						var val = target.value;
					 	ID_TYPE_changeController(isCORP_DEPT,target.value);	
						
						<%-- [20221121] 依保人種類改變顯示文字 --%>
						if (val == '2' || val == '4') {
							$('C_BIRTHDAY_HEADER').update('成立日期');
							$('C_AGE_DESC').update('年');
						} else {
							$('C_BIRTHDAY_HEADER').update('出生日期');
							$('C_AGE_DESC').update('歲');
						}
					 } }
				 }				 
			 ] }
			 <%-- [20221121] header改用span物件 --%>
			,{ header:birthdayHeader, values:[ 
				 <%-- [20221121] 綁定檢核 --%>
				 {key:"BIRTHDAY", type:"date" ,attrs:{ datatype:"ROCDate" , pattern:"yyyMMdd", className:"required checkIsROCDate validate-age" } 
				 	, events:{ 
						change:function(target){ 
							if(isROCdate(target.value,false)){
								var countValue = JsUtils.getDateInput( target , true );
								var displayValue = JsUtils.getDateInput( target , false );
								buttonActions.getAge(countValue); 
								target.value = displayValue;
							}
						} 
					} 
				 } 
				 ," - "
				,{key:"AGE"} 
				<%-- [20221121] 歲改用span物件 --%>
				,ageDesc
			 ] }
			 <%-- [20190626] 增加羅馬拼音欄位 --%>
			 ,{ header:"姓名(羅馬拼音)", values:[ 
				 {key:"NAME_RM", type:"text" ,attrs:{ value:"", maxLength:100 ,size:50 ,fieldName:"姓名(羅馬拼音)",  className:"validateFullType validateMaxLength" } } 
			 ] }
			,{ header:"統一編號", values:[ 
				 {key:"ID", type:"text" ,attrs:{ value:"", maxLength:10 ,size:12 , className:"required validateId validateMaxLength" } } 
			 ] }
			 <%-- [20191217] 修改 檢核--%>
			,{ header:"通訊地址", values:[
				 {key:"CON_CODE", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.BUSS_CODE1_List ,attrs:{ className:"vaildateNotZero checkDSZ01000value" }
				 	,events:{ "change":function(target){
						var value = target.value;
						var nextSpan = target.parentNode.nextSibling;
						theDSZ01000control.displayControl2( nextSpan , value );
					}
				 }} 
				 ,{ key:"CON_ADDR_ZIP",type:"dom",attrs:{ preKey:"CON" }
				 	,elem:theDSZ01000control.create
					,getFunc:theDSZ01000control.get
					,setFunc:theDSZ01000control.set  
				  }
			 ] }
			 ,{}
			 <%-- [20191217] 新增選項：”” (空白) , 檢核--%>
			,{ header:"通訊地址所有人", values:[ 
				 {key:"OWN_CODE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.OWN_CODE_List, events:{
					 change:function( target ){
						 displayChange( 
							target.value 
							,target.getAttribute("textAllow") 
							,target.getAttribute("changeNode") 
							,target.getAttribute("changeType") 
						 );
					 }
				 },attrs:{textAllow:"3" , changeNode:"C_OWN_CODE_CONTENT" , changeType:true  ,className:"requiredWhenAbled"} } 
				,{key:"OWN_CODE_CONTENT", type:"text",attrs:{value:"", size:30 ,className:"requiredWhenAbled validateFullType validateHalfType"} }
			 ] }
			 <%-- [20191217] 增加 檢核--%>
			,{ header:"通訊地址使用狀況", values:[ 
				 {key:"USE_STATUS", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM" ,opts: selectionOptions.USE_STATUS_List, events:{
					 change:function( target ){
						 displayChange( 
							target.value 
							,target.getAttribute("textAllow") 
							,target.getAttribute("changeNode") 
							,target.getAttribute("changeType") 
						 );
					 }
				 },attrs:{textAllow:"9" , changeNode:"C_USE_STATUS_CONTENT" , changeType:true } } 
				,{key:"USE_STATUS_CONTENT", type:"text",attrs:{value:"", className:"requiredWhenAbled"}}
			 ] }
			,{ header:"連絡電話", values:[ 
				 "日：" 
				,{key:"DAY_TEL_AREA", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.AREA_CODE ,opts: selectionOptions.TEL_AREA_List ,attrs:{ fieldName:"日間連絡電話區碼"} }
				,"-" 
				 <%-- [20191217] 增加 檢核--%>
				,{key:"DAY_TEL_NUM", type:"number" ,attrs:{ value:"", pattern:"##########" ,maxLength:10 ,size:10 , className:"required validateMaxLength" , fieldName:"日間連絡電話"} } 
				,"#" 
				,{key:"DAY_TEL_EXT", type:"number" ,attrs:{ value:"", pattern:"######" ,maxLength:6 ,size:6, className:"validateMaxLength" } } 
				,document.createElement("br")
				,"夜：" 
				,{key:"NIGHT_TEL_AREA", type:"select",optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.AREA_CODE ,opts: selectionOptions.TEL_AREA_List,attrs:{  fieldName:"夜間連絡電話區碼"} }
				,"-" 
				 <%-- [20191217] 增加 檢核--%>
				,{key:"NIGHT_TEL_NUM", type:"number" ,attrs:{ value:"", pattern:"##########" , maxLength:10 ,size:10 , className:"required validateMaxLength" , fieldName:"夜間連絡電話區碼" } } 
				,"#" 
				,{key:"NIGHT_TEL_EXT", type:"number" ,attrs:{ value:"", pattern:"######" , maxLength:6 ,size:6, className:"validateMaxLength" } } 
				,document.createElement("br")
				,"行動電話：" 
				,{key:"MOBILE", type:"number" ,attrs:{ value:"", pattern:"##################" ,maxLength:18 ,size:11, className:"validateMaxLength" } } 
			 ] }
			 <%-- [20191217] 新增選項：”” (空白) , 檢核--%>
			,{ header:"學歷", values:[ 
				 {key:"DEGREE", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM", opts: selectionOptions.DEGREE_List } 
				,document.createElement("br")
				,"學校："				
				,{key:"SCHOOL", type:"text" ,attrs:{ value:"", maxLength:20 ,size:20, className:"validateMaxLength" , fieldName:"學校" } } 
				,document.createElement("br")
				,"科系："
				,{key:"DEPARTMENT", type:"text" ,attrs:{ value:"", maxLength:30 ,size:20, className:"validateMaxLength" } } 
			] }
			<%-- [20191217] 新增選項：”” (空白) --%>
			,{ header:"婚姻狀況", values:[ 
				 {key:"MARRY", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.MARRY_List , events:{
					 change:function( target ){
						 displayChange( 
							target.value 
							,target.getAttribute("textAllow") 
							,target.getAttribute("changeNode") 
							,target.getAttribute("changeType") 
						 );
					 }
				 },attrs:{textAllow:"1" , changeNode:"C_SPOUSE_NAME,C_SPOUSE_LIVE,C_SPOUSE_NAME_RM" , changeType:false ,className:"requiredWhenAbled"}}
				,document.createElement("br")
				,"配偶姓名："
				,{key:"SPOUSE_NAME",type:"text",attrs:{ value:"", maxLength:100 ,size:50 ,fieldName:"配偶姓名", className:"requiredWhenAbled validateFullType validateHalfType validateMaxLength", alt:"ch" } }<%--[20240722]難字調整 --%>
				<%-- [20190626] 增加羅馬拼音欄位 --%>
				,document.createElement("br")
				,"配偶姓名(羅馬拼音)："
				,{key:"SPOUSE_NAME_RM",type:"text",attrs:{ value:"", maxLength:100 ,size:50  ,fieldName:"配偶姓名(羅馬拼音)", className:"validateFullType validateMaxLength"}  }
				,document.createElement("br")
				<%-- [20191217] 新增選項：”” (空白) --%>				
				,{key:"SPOUSE_LIVE", type:"select",optKey:"CODE",optValueKey:"CODE_NM", opts: selectionOptions.SPOUSE_LIVE_List ,attrs:{ className:"requiredWhenAbled"} }
			] }
			,{ header:"子女人數", values:[ 
				 "男："
				,{key:"SON_NO", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.SON_NO_List }
				,"女："
				,{key:"GIRL_NO", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.SON_NO_List }
			] }			
			,{ header:"保證人與借款人關係", values:[ 
				 "企業關係："
				,{key:"RELATION_E", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.RELATION_E_List 
					,setFunc: function(node , value , values ){
						if(JsUtils.isObject(values)){
							var relation = values["RELATION"];
							if(JsUtils.isString(relation) && relation.length > 0){
								return relation.substr(0,1);
							}
						}
						return "";
					} 
					//20200213 法金件導入：法金件可同時選擇企業關係及個人關係
					/*,getFunc: function( node , value , rtnValues){
						if(!node.disabled){
							rtnValues["RELATION"] = value + "X";
						}
						return value;
					}*/
					,attrs:{className:"vaildateRelationE"}
				 }
				,document.createElement("br")				
				,"自然人關係："
				,{key:"RELATION_P", type:"select",optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.PLS_CHOOSE,opts: selectionOptions.RELATION_P_List 
					,setFunc: function(node , value , values ){
						if(JsUtils.isObject(values)){
							var relation = values["RELATION"];
							if(JsUtils.isString(relation) && relation.length > 1){
								return relation.substr(1,1);
							}
						}
						return "";
					}
					//20200213 法金件導入：法金件可同時選擇企業關係及個人關係
					/*,getFunc: function( node , value , rtnValues){
						if(!node.disabled){
							rtnValues["RELATION"] = "X" + value;
						}
						return value;
					}*/
					,attrs:{className:"vaildateRelationP"}
				 }
			] }
			,{ header:"保證人種類", values:[ 
				 {key:"GUAR_KIND", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.GUAR_KIND_List, preOpts: selectionOptions.PLS_CHOOSE,attrs:{ className:"required" } }
			] }
			<%-- [20191217] 新增 註冊國家 --%>
			,{ header:"註冊國家", values:[ 
			     {key:"COUNTRY_NM", type:"text" ,attrs:{ value:"", maxLength:40 ,size:40, className:"validateMaxLength" } } 				  
				,{key:"COUNTRY", type:"text" ,attrs:{ value:"", maxLength:10,size:10 ,className:"validateMaxLength" ,style:"display:none;"} } 
			] }
			,{}
			,{ header:"檢附相關資料", values:[ 
				 {key:"DOCS", type:"checkbox",itemKey:"CODE",itemValueKey:"CODE_NM", items: selectionOptions.DOCS_CODE_List 
				 	,events:{click:function(target){ checksControl(target.parentNode.parentNode.parentNode); } } 
					,attrs:{className:"vaildateChecks"}
				 }
				,{key:"DOCS_CONTENT", type:"text" ,attrs:{ value:"", maxLength:60,size:20 ,fieldName:"其他相關資料說明", className:"vaildatePreCheck validateMaxLength"} } 
			] }
			
		
			
			
		] 
	} , {} , 0 );
	ContentSaves["C"] = areaCcontent;
	VaildationSaves["C"] = new Validation( areaCcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle : "基本資料"});
	
//-------------------------------------------------------------------------------------------------
// area D
// 目前經營事業(包含合夥事業)	
//1031204楊智凱:營業項目、資本額、出資比例改為不檢核
//-------------------------------------------------------------------------------------------------
	var areaDsetting =
	{ 
		elem:"areaD", dataColumns: 9, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true,columnProps:[3,11,11,11,11,10,11,20,11],
		contents:[
			 { header:"",rowSpan:2,values:[ 
				{key:"CHOOSE", type:"radio", items:{1:""}, attrs:{name:"delTagD"} , events :{ click:function(target){ RecrodsControl.selectToDelete("D" , target); } } } 
			 ]}
			,{ header:"事業名稱",values:[ 
				{key:"BUSS_NAME", type:"text" , attrs:{ value:"", size:'32', maxLength:'60', className:"required validateFullType validateHalfType validateMaxLength" } } 
			 ]} 
			,{ header:"統一編號",values:[
				{key:"BUSS_CORPID", type:"number" , attrs:{ value:"", pattern:"########" , size:'10', maxLength:'8' , className:"validateCmpId validateMaxLength"} } 
			 ]}
			,{ header:"行業別",colSpan:2,values:[
				{key:"BUSINESS_CODE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.A021_BUSINESS_CODE_List,attrs:{ className:"vaildateNotZero" } }
			 ]}
			,{ header:"職業類別",colSpan:3,values:[
				{key:"OCCU_CODE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.A021_OCCU_CODE_List,attrs:{ className:"vaildateNotZero" } }
			 ]}
			,{ header:"事業處所",colSpan:2,values:[ 
				{key:"BUSS_CODE", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.BUSS_CODE_List ,attrs:{ className:"checkDSZ01000value" }
				 	,events:{ "change":function(target){
						var value = target.value;
						var nextSpan = target.parentNode.nextSibling;
						theDSZ01000control.displayControl2( nextSpan , value );
					}
				 }} 
				 ,{ key:"BUSS_ADDR_ZIP",type:"dom",attrs:{ preKey:"BUSS" }
				 	,elem:theDSZ01000control.create
					,getFunc:theDSZ01000control.get
					,setFunc:theDSZ01000control.set  
				  }
			 ]}
			,{ header:"營業項目",values:[
				{key:"BUSS_ITEM", type:"text" , attrs:{ value:"", size:'16', maxLength:'20' } }
			 ] }
			,{ header:"資本額",values:[
				{key:"CAPITAL", type:"money" , attrs:{ value:"", pattern :"#,###.##" ,size:'6', maxLength:'8' } }
				,"萬"
			 ] }
			,{ header:"年營業額",values:[
				{key:"YEAR_VOLUME", type:"money" , attrs:{value:"", pattern :"#,###.##" ,size:'6', maxLength:'8', className:"required validateMaxLength" } } 
				,"萬"
			 ] }
			,{ header:"年淨利",values:[
				{key:"YEAR_PROFIT", type:"money" , attrs:{ value:"", pattern :"#,###.##" ,size:'5', maxLength:'8', className:"required validateMaxLength" } } 
				,"萬"
			 ] }
			,{ header:"出資比率",values:[
				{key:"CAPITAL_RATE", type:"number" , attrs:{ value:"", size:'3', maxLength:'3' } } 
				,"％"
			 ] }
			,{ header:"創立時間(年月)",values:[
				{key:"BUILD_DATE", type:"date" 
					,getFunc:function( node , value , valueMap , isForDispaly ){
						if(isForDispaly){
							var testValue = value;
							if(isROCdate(value,false)){
								testValue = toY2K(testValue);
							}
							if(isDate(testValue)){
								df = JsUtils.getSimpleDateFormat("yyyMM" , true );
								value = df.format(testValue);
							}
						}
						return value;
					}
					,attrs:{ datatype:"rocdate" , pattern:"yyy/MM/dd", className:"checkIsROCDate" }
					,events :{ change:function(target){  
							var id = target.id;
							var index = id.substr(id.length-1,id.length);
							tools.ajaxPost('calculate', {'type':'BUILD_DATE','value':toY2K(target.getValue())}, function(resp){
									$('D_SERV_YEAR_'+index).setValue((resp.rtnValue=='0'?'0':resp.rtnValue)||'');
								}, function(resp){
									$('D_SERV_YEAR_'+index).setValue('');
								});
					 } }
				}
			]}
			,{ header:"服務年資", values:[
			 	{key:"SERV_YEAR", type:"number" , attrs:{ value:"", size:'4', maxLength:'3', className:"required validateMaxLength" } } 
				,"年"
			 ]}
			,{ header:"電話",values:[ 
				 {key:"TEL_AREA", type:"select",optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.AREA_CODE,opts: selectionOptions.TEL_AREA_List,attrs:{ fieldName:"電話區碼"} }
				,"-" 
				,{key:"TEL_NUM", type:"number" ,attrs:{ value:"", pattern:"##########", maxLength:10, size:10, className:"required validateMaxLength" , fieldName:"電話"} } 
				,"#" 
				,{key:"TEL_EXT", type:"number" ,attrs:{ value:"", pattern:"######", maxLength:6 ,size:6, className:"validateMaxLength" } } 
			 ]}
			,{ header:"事業處所使用情形",values:[ 
				 {key:"USE_STATUS", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.USE_STATUS_A021_List } 
			]}
		]
	}
	var areaDcontent = RecrodsControl.createRecord( "D" , areaDsetting ).parentNode;
	ContentSaves["D"] = areaDcontent;
	//VaildationSaves["D"] = new Validation( areaAcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator"});
	

//-------------------------------------------------------------------------------------------------
// area E
// 目前服務單位	
//1031204楊智凱:營業項目改為不檢核
//-------------------------------------------------------------------------------------------------
	
	var areaEsetting ={ 
		elem:"areaE", dataColumns: 6, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true, columnProps:[4,24,24,24,24],//[5,19,19,19,19,19],
		contents:[
			 { header:"",rowSpan:3,values:[ 
				{key:"CHOOSE", type:"radio", items:{1:""}, attrs:{name:"delTagE"} , events :{ click:function(target){ RecrodsControl.selectToDelete("E" , target); } } } 
			 ]}
			,{ header:"營業項目", values:[
				{key:"BUSS_ITEM", type:"text" , attrs:{ value:"", size:'22', maxLength:'20' } }
			 ]}
			,{ header:"服務單位名稱", values:[
				{key:"SERV_NAME", type:"text" , attrs:{ value:"", size:'32', maxLength:'60', className:"required validateFullType validateHalfType validateMaxLength" } } 
			 ]}
			,{ header:"身分別", values:[
				{key:"WORK_TYPE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.WORK_TYPE_List }
			 ]}
			,{ header:"統一編號", values:[
				{key:"SERV_CORPID", type:"number" , attrs:{ value:"", pattern:"########" , size:'8', maxLength:'8' , className:"validateCmpId validateMaxLength"} } 
			 ]}
			,{ header:"行業別", values:[
				{key:"BUSINESS_CODE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.A022_BUSINESS_CODE_List,attrs:{ className:"vaildateNotZero" } }
			 ]}
			,{ header:"職位", values:[
			 	{key:"JOB_TITLE", type:"text" , attrs:{ value:"", size:'22', maxLength:'20', className:"required validateFullType validateMaxLength" } } 
			 ]}
			,{ header:"月薪",	values:[
				 {key:"SALARY", type:"money" , attrs:{ value:"", size:'8', maxLength:'10' ,pattern :"#,###.##", className:"required validateMaxLength" } } 
				 ,"萬"
			 ]}
			,{ header:"服務年資", values:[
			 	{key:"SERV_YEAR", type:"number" , attrs:{ value:"", size:'4', maxLength:'3', className:"required validateMaxLength" } } 
				,"年"
			 ]}
			,{ header:"年所得(含獎金)", values:[
			 	{key:"YEAR_INCOME", type:"money" , attrs:{ value:"", size:'13', maxLength:'11' ,pattern :"#,###.##" , className:"required validateMaxLength"} } 
				,"萬"
			 ]}
			,{ header:"職業類別", values:[
				{key:"OCCU_CODE", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.A022_OCCU_CODE_List,attrs:{ className:"vaildateNotZero OCCU_CODE" } }
			 ]}
			,{ header:"詳細地址", colSpan:3, values:[
				 {key:"SERV_CODE", type:"select" ,optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.BUSS_CODE_List ,attrs:{ className:"vaildateNotZero checkDSZ01000value" }
				 	,events:{ "change":function(target){
						var value = target.value;
						var nextSpan = target.parentNode.nextSibling;
						theDSZ01000control.displayControl2( nextSpan , value );
					}}
				 } 
				 ,{ key:"SERV_ADDR_ZIP",type:"dom",attrs:{ preKey:"SERV" }
				 	,elem:theDSZ01000control.create
					,getFunc:theDSZ01000control.get
					,setFunc:theDSZ01000control.set  
				  }
			 ]}
			,{ header:"電話", colSpan:2, values:[ 
				 {key:"SERV_TEL_AREA", type:"select",optKey:"CODE",optValueKey:"CODE_NM", preOpts: selectionOptions.AREA_CODE,opts: selectionOptions.TEL_AREA_List,attrs:{ fieldName:"電話區碼"} }
				,"-" 
				,{key:"SERV_TEL_NUM", type:"number" ,attrs:{ value:"", pattern:"############" ,datatype:"number" , pattern:"#" , maxLength:10 ,size:10 , className:"validate_SERV_TEL_required validateMaxLength" , fieldName:"電話"} } 
				,"#" 
				,{key:"SERV_TEL_EXT", type:"number" ,attrs:{ value:"", pattern:"########" ,datatype:"number" , pattern:"#" , maxLength:6 ,size:6, className:"validateMaxLength" } } 
			 ]}		
			
			
		]
	};
	var areaEcontent = RecrodsControl.createRecord( "E" , areaEsetting ).parentNode;
	ContentSaves["E"] = areaEcontent;
	
	
	
//-------------------------------------------------------------------------------------------------
// area F
//前職單位	
//-------------------------------------------------------------------------------------------------
	var areaFcontent = PageUI.createContent( { 
		elem:"areaF", dataColumns: 3, clearChildElements:true, columnProps:[15,27,15,27,15,27], KeyToId:function(key){ return "F_"+key; },
		contents:[
			 { header:"服務單位名稱" , colSpan:2 , values:[ 
				 {key:"SERV_NAME", type:"text" ,attrs:{ value:"", size:30 , maxLength:60 , className:"validateFullType validateHalfType validateMaxLength" } } 
			 ] }
			,{ header:"營業項目", values:[ 
				 {key:"BUSS_ITEM", type:"text" ,attrs:{ value:"", size:20 , maxLength:20 , className:"requlredAreaF validateFullType validateMaxLength" } } 
			 ] }
			,{ header:"職位", values:[ 
				 {key:"JOB_TITLE", type:"text" ,attrs:{ value:"", size:20 , maxLength:20 , className:"requlredAreaF validateFullType validateMaxLength" } } 
			 ] }
			,{ header:"服務年資", values:[ 
				 {key:"SERV_YEAR", type:"number" ,attrs:{ value:"", size:4 , maxLength:3 , className:"requlredAreaF validateMaxLength" } }
				 ,"年"
			 ] }
			,{ header:"年所得(含獎金)", values:[ 
				 {key:"YEAR_INCOME", type:"money" ,attrs:{ value:"", size:13 , maxLength:11 , pattern:"#,###.##" , className:"requlredAreaF validateMaxLength" } } 
				 ,"萬"
			 ] }
		]
	} , null , 0 );
	ContentSaves["F"] = areaFcontent;
	VaildationSaves["F"] = new Validation( areaFcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle : "前職單位"});
	
//-------------------------------------------------------------------------------------------------
// area G
// 個人(含配偶)全年收支情形	
//-------------------------------------------------------------------------------------------------
	var areaGcontent = PageUI.createContent( { 
		elem:"areaG", dataColumns: 2, clearChildElements:true, columnProps:[25,25,25,25], KeyToId:function(key){ return "G_"+key; },
		contents:[
			  { header:"支存狀況", colSpan:2, values:[
				{type:"dom", key:"DOM1" , elem:"G_DOM1"
				 	,setFunc:function(node , value , values ){ 
						var G_CHK_NOR = $("G_CHK_NOR");
						var G_CHK_REJ =  $("G_CHK_REJ");
						var G_CHK_REF =  $("G_CHK_REF");
						var G_REF_TIMES =  $("G_REF_TIMES");
						var G_REPAIR =  $("G_REPAIR");
						var G_REPAIR_TIMES =  $("G_REPAIR_TIMES");
						var G_OTHER =  $("G_OTHER");
						var G_OTHER_CONTENT =  $("G_OTHER_CONTENT");
						var G_OTHER_INCOME_ITEM = $("G_OTHER_INCOME_ITEM");
						var G_OTHER_EXP_ITEM = $("G_OTHER_EXP_ITEM");
						if(G_CHK_NOR){ G_CHK_NOR.checked = !!(((values && values["CHK_NOR"]) || "") == 1); }
						if(G_CHK_REJ){ G_CHK_REJ.checked = !!(((values && values["CHK_REJ"]) || "") == 1); }
						if(G_CHK_REF){ G_CHK_REF.checked = !!(((values && values["CHK_REF"]) || "") == 1); }
						if(G_REF_TIMES) G_REF_TIMES.value = (values && values["REF_TIMES"]) || "";
						if(G_REPAIR){ G_REPAIR.checked = !!(((values && values["REPAIR"]) || "") == 1); }
						if(G_REPAIR_TIMES) G_REPAIR_TIMES.value = (values && values["REPAIR_TIMES"]) || "";
						if(G_OTHER){ G_OTHER.checked = !!(((values && values["OTHER"]) || "") == 1); }
						if(G_OTHER_CONTENT) G_OTHER_CONTENT.value = (values && values["OTHER_CONTENT"]) || "";
						if(G_OTHER_INCOME_ITEM) G_OTHER_INCOME_ITEM.value = (values && values["OTHER_INCOME_ITEM"]) || "";
						if(G_OTHER_EXP_ITEM) G_OTHER_EXP_ITEM.value = (values && values["OTHER_EXP_ITEM"]) || "";
						
						
						return "";
					} 
					,getFunc:function(node , returnValues ){ 
						var G_CHK_NOR = $("G_CHK_NOR");
						var G_CHK_REJ =  $("G_CHK_REJ");
						var G_CHK_REF =  $("G_CHK_REF");
						var G_REF_TIMES =  $("G_REF_TIMES");
						var G_REPAIR =  $("G_REPAIR");
						var G_REPAIR_TIMES =  $("G_REPAIR_TIMES");
						var G_OTHER =  $("G_OTHER");
						var G_OTHER_CONTENT =  $("G_OTHER_CONTENT");
						var G_OTHER_INCOME_ITEM = $("G_OTHER_INCOME_ITEM");
						var G_OTHER_EXP_ITEM = $("G_OTHER_EXP_ITEM");
						if(JsUtils.isObject(returnValues)){
							returnValues["CHK_NOR"] = ( G_CHK_NOR && G_CHK_NOR.checked ) ? 1 : 0;
							returnValues["CHK_REJ"] = ( G_CHK_REJ && G_CHK_REJ.checked ) ? 1 : 0;
							returnValues["CHK_REF"] = ( G_CHK_REF && G_CHK_REF.checked ) ? 1 : 0;
							returnValues["REPAIR"] = ( G_REPAIR && G_REPAIR.checked ) ? 1 : 0;
							returnValues["OTHER"] = ( G_OTHER && G_OTHER.checked ) ? 1 : 0;
							returnValues["REF_TIMES"] = ( G_REF_TIMES ) ? G_REF_TIMES.value : "";
							returnValues["REPAIR_TIMES"] = ( G_REPAIR_TIMES ) ? G_REPAIR_TIMES.value : "";
							returnValues["OTHER_CONTENT"] = ( G_OTHER_CONTENT ) ? G_OTHER_CONTENT.value : "";
							returnValues["OTHER_INCOME_ITEM"] = ( G_OTHER_INCOME_ITEM ) ? G_OTHER_INCOME_ITEM.value : "";
							returnValues["OTHER_EXP_ITEM"] = ( G_OTHER_EXP_ITEM ) ? G_OTHER_EXP_ITEM.value : "";
						}
						checksControl();
						return "";
					} 
				}
			  ] }
			, { header:createBlueNode("收入項目"),	values:[createBlueNode("金額(單位：萬元)")] }
			, { header:createBlueNode("支出項目"),	values:[createBlueNode("金額(單位：萬元)")] }
			, { header:"經營事業╱薪資收入(年所得含獎金)", values:[ 
				 {key:"INCOME", type:"money" ,attrs:{ value:"", pattern :"#,###.##" , size:9 , maxLength:9, className:"validateMaxLength"  } 
				 	,events:{ 
						blur:function(){
							PageUI.setContentValue('G_INCOME_TOTAL', parseFloat($('G_INCOME').getValue() || 0) +  parseFloat($('G_OTHER_INCOME').getValue() || 0) );
						}
					} 
				 } 
				,"萬"
			 ] }
			, { header:"家庭生活支出", values:[ 
				 {key:"HOME_EXP", type:"money" ,attrs:{ value:"", pattern :"#,###.##" , size:9 , maxLength:9, className:"validateMaxLength"  } 
				 	,events:{ 
						blur:function(){
							PageUI.setContentValue('G_EXP_TOTAL', parseFloat($('G_HOME_EXP').getValue() || 0) +  parseFloat($('G_OTHER_EXP').getValue() || 0) );
						}
					} 
				 } 
				 ,"萬"
			 ] }
			, { header:$("G_OTHER_INCOME_ITEM_TITLE"), values:[ 
				 {key:"OTHER_INCOME", type:"money" ,attrs:{ value:"", pattern :"#,###.##" , size:9 , maxLength:9, className:"validateMaxLength"  } 
				 	,events:{ 
						blur:function(){
							PageUI.setContentValue('G_INCOME_TOTAL', (parseFloat($('G_INCOME').getValue() || 0) +  parseFloat($('G_OTHER_INCOME').getValue() || 0) ) );
						}
					} 
				 } 
				 ,"萬"
			 ] }
			, { header:$("G_OTHER_EXP_ITEM_TITLE"), values:[ 
				 {key:"OTHER_EXP", type:"money" ,attrs:{ value:"", pattern :"#,###.##" , size:9 , maxLength:9, className:"validateMaxLength"  } 
				 	,events:{ 
						blur:function(){
							PageUI.setContentValue('G_EXP_TOTAL', (parseFloat($('G_HOME_EXP').getValue() || 0) +  parseFloat($('G_OTHER_EXP').getValue() || 0) ) );
						}
					} 
				 } 
				 ,"萬"
			 ] }
			, { header:"合計", values:[ 
				 {key:"INCOME_TOTAL" 
				 	,setFunc:function(node , value){
						if(value){
							return CSRUtil.$fmt( value , "#,###.##");
						}else{
							return "";
						}
					}
					,getFunc:function(node , value ){
						if(value){
							if(JsUtils.isString(value)){
								return value.replace(/,/g,"");
							}
							return value;
						}else{
							return "";
						}
					}
				 } 
				 ,"萬"
			 ] }
			, { header:"合計", values:[ 
				 {key:"EXP_TOTAL"
				 	,setFunc:function(node , value){
						if(value){
							return CSRUtil.$fmt( value , "#,###.##");
						}else{
							return "";
						}
					}
					,getFunc:function(node , value){
						if(value){
							if(JsUtils.isString(value)){
								return value.replace(/,/g,"");
							}
							return value;
						}else{
							return "";
						}
					}
				 } 
				 ,"萬"
			 ] }
		]
	} , null , 0 );
	
	function createBlueNode( text ){
		var div = document.createElement("div");
		div.setAttribute("blueblock" , true);
		div.setAttribute("align" , "center");
		div.style.fontWeight = "bold";
		div.appendChild(document.createTextNode(text));
		return div;
	}
	
	$(areaGcontent).select('div[blueblock]').each(
		function(div){
			div.parentNode.parentNode.className="contentBlue";
		}
	)
	ContentSaves["G"] = areaGcontent;
	VaildationSaves["G"] = new Validation( areaGcontent, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle : "個人(含配偶)全年收支情形"});
	
//-------------------------------------------------------------------------------------------------
// area H
// 本人其他不動產暨設定明細	
//-------------------------------------------------------------------------------------------------
	var areaHsetting =
	{ 
		elem:"areaH", dataColumns: 3, className:"contentBlue", clearChildElements:false, noContent:false, noHeader:true,columnProps:[6,47,47],
		contents:[
			 { header:"",rowSpan:3,values:[ 
				{key:"CHOOSE", type:"radio", items:{1:""} , attrs:{name:"delTagH"}, events :{ click:function(target){ RecrodsControl.selectToDelete("H" , target); } } } 
			 ]}
			,{ header:"坐落所在地",values:[ 
				 {key:"ADDRESS", type:"text" , attrs:{ size:'32', maxLength:'80' , className:"required validateFullType validateHalfType"} } 
			 ]} 
			,{ header:"地號",values:[ 
				 {key:"LAND_NO1", type:"number" , attrs:{ value:"", size:'6', maxLength:'4', className:"validateMaxLength" , pattern:"####" } }
				,"-"
				,{key:"LAND_NO2", type:"number" , attrs:{ value:"", size:'6', maxLength:'4', className:"validateMaxLength" , pattern:"####" } }
			 ]} 
			,{ header:"建物門牌",values:[ 
				 {key:"BUILD_DOOR", type:"text" , attrs:{ value:"", size:'32', maxLength:'60', className:"validateMaxLength" } } 
			 ]} 
			,{ header:"建號",values:[ 
				 {key:"BUILD_NO1", type:"number" , attrs:{ value:"", size:'7', maxLength:'5', className:"validateMaxLength" , pattern:"#####" } }
				,"-"
				,{key:"BUILD_NO2", type:"number" , attrs:{ value:"", size:'5', maxLength:'3', className:"validateMaxLength"  , pattern:"###"} }
			 ]} 
			,{ header:"使用情形",values:[ 
				 {key:"USE_STATUS", type:"select",optKey:"CODE",optValueKey:"CODE_NM",opts: selectionOptions.USE_STATUS_A023_List }
			] }
			,{ header:"設定情形",values:[ 
				  "行庫："
				 ,{key:"SET_BANK", type:"text" , attrs:{ value:"", size:'25', maxLength:'12', className:"validateMaxLength" } }
				 ,"　金額："
				 ,{key:"SET_AMT", type:"money" , attrs:{ value:"", pattern :"#,###.##" ,  size:'12', maxLength:'10', className:"validateMaxLength" } }
				 ,"萬"
				 
			] }
			
		]
	}
	var areaHcontent = RecrodsControl.createRecord( "H" , areaHsetting ).parentNode;
	ContentSaves["H"] = areaHcontent;
	//VaildationSaves["H"] = new Validation( areaAcontent, {useTitles:true,focusOnError:false,immediate:false});


	theDSZ01000control.createDSZ01000( document.body );
	SelectionChangeControl();
	
	//var tempDSA020 = {};
	//PageUI.setContentValues( ContentSaves["C"] , tempDSA020 , true , true );
	//PageUI.setContentValues( ContentSaves["G"] , tempDSA020 , true , true );
}

 <%-- [20191217] 增加 法金件 --%>
 //法金件欄位控制
function ID_TYPE_changeController(isCORP_DEPT, ID_TYPE){
	
	//限制輸入欄位
	var colDisable = false;
	//下拉選單新增空白選項
	var addBlankOpt = 'C_OWN_CODE C_USE_STATUS C_DEGREE C_MARRY';
	
	if('Y'==isCORP_DEPT){//法金件
		//註冊國家
		$('C_COUNTRY_NM').enable();
		
		//處理下拉選單(是否有空白選項)
		$w(addBlankOpt).each(function(eleId){
			if($(eleId)){
				var colName = eleId.substring(2);
				var colValue = $F(eleId);//20200311 問題單編號20200311-0115:先keep原本的value，更新好選項後再set回去
				var newList;
				if('3'==ID_TYPE || '4'==ID_TYPE || ('2'==ID_TYPE && ('C_DEGREE'==eleId||'C_MARRY'==eleId))){//國外自然人、國外法人：新增空白選項(預設為空白)，國內法人：學歷、婚姻狀況預設為空白
					newList = [
						{CODE:"",CODE_NM:""}
					];
					newList = newList.concat(selectionOptions[colName+'_List']||[]);
				}else{
					newList = selectionOptions[colName+'_List']||[];
				}
				JsUtils.addOptions(eleId,newList,"CODE","CODE_NM",true,false);
				
				$(eleId).setValue(colValue);
			}
		});	
		
		//國內法人、國外法人：學歷、學校、科系、婚姻狀況、配偶姓名、配偶姓名(羅)、配偶存歿、子女人數(男)、子女人數(女) disable
		if('2'==ID_TYPE || '4'==ID_TYPE){
			colDisable = true;
		}else{
			colDisable = false;
		}
		
		
		//檢核
		if('3'==ID_TYPE||'4'==ID_TYPE){
			$('C_OWN_CODE').className = '';
			$('C_DAY_TEL_NUM').className = 'validateMaxLength inputText';
			$('C_NIGHT_TEL_NUM').className = 'validateMaxLength inputText';
			$('C_MARRY').className = '';
		}else{
			$('C_OWN_CODE').className = 'requiredWhenAbled';
			$('C_DAY_TEL_NUM').className = 'required validateMaxLength inputText';
			$('C_NIGHT_TEL_NUM').className = 'required validateMaxLength inputText';
			$('C_MARRY').className = 'requiredWhenAbled';
		}
	}else{//非法金件：還原預設值，接enable
		//註冊國家
		$('C_COUNTRY_NM').disable();
		
		//處理下拉選單(是否有空白選項)
		$w(addBlankOpt).each(function(eleId){
			if($(eleId)){
				var colName = eleId.substring(2);
				var colValue = $F(eleId);//20200311 問題單編號20200311-0115:先keep原本的value，更新好選項後再set回去
				
				JsUtils.addOptions(eleId,(selectionOptions[colName+'_List']||[]),"CODE","CODE_NM",true,false);
				
				$(eleId).setValue(colValue);
			}
		});	
		
		colDisable = false;
		
		//檢核
		$('C_OWN_CODE').className = 'requiredWhenAbled';
		<%-- [20220829] 非法金件電話修改為非必輸值 --%>
		$('C_DAY_TEL_NUM').className = 'validateMaxLength inputText'; 
		$('C_NIGHT_TEL_NUM').className = 'validateMaxLength inputText';
		$('C_MARRY').className = 'requiredWhenAbled inputText';
	}
	
	//處理disable
	//限制輸入欄位：學歷、學校、科系、婚姻狀況、配偶姓名、配偶姓名(羅)、配偶存歿、子女人數(男)、子女人數(女)
	var disableCols = 'C_DEGREE C_SCHOOL C_DEPARTMENT C_MARRY C_SPOUSE_NAME C_SPOUSE_NAME_RM C_SPOUSE_LIVE C_SON_NO C_GIRL_NO';
	$w(disableCols).each(function(eleId){
		if($(eleId)){
			if(colDisable){
				$(eleId).setValue('');
			}
			$(eleId).disabled = colDisable;
		}
	});
}

var buttonActions = {
	 query:function(){
		tools.nodesToUpperCase(['A_APPLY_ID']);
		VaildationSaves["A"].reset();

		if( !VaildationSaves["A"].validate() ) {return;}	
		//action Name
		var actionName = "query"; 
		//傳遞參數
		var queryData = PageUI.getContentValues( ContentSaves["A"] );
		CSRUtil.keepParamsManager.put(queryData);
		//成功動作
		var successAction = function(resp){
			ContentSaves["B"].load(resp.memberList);
			dataMainMap = resp.mainMap;
			
			isCORP_DEPT = dataMainMap.isCORP_DEPT;	<%-- [20191217] 增加 --%> //是否為法金件
			
			GAGE_TYPE = dataMainMap.GAGE_TYPE;
			ID_TYPE = dataMainMap.ID_TYPE;//20191217
			isFori = (GAGE_TYPE == '6' ||GAGE_TYPE == '7' );
			 PageUI.setContentValue('C_APPLY_ID',dataMainMap , true ,true );
			 PageUI.setContentValue('C_APPLY_PROCESS_NM',dataMainMap , true ,true );
			 
			 
			var COPR_CODE = dataMainMap.COPR_CODE;//借款人是否為法人
			if(isCORP_DEPT == 'Y'){ <%-- [20191217] 增加 法金件 --%> //法金件：企業關係與自然人關係可以同時勾選或擇一輸入
				$("C_RELATION_P").disabled = false;
				$("C_RELATION_E").disabled = false;
				$("C_ID_TYPE").show();
			}else{//非法金件
				$("C_ID_TYPE").value='';
				$("C_ID_TYPE").hide();
				if(COPR_CODE != "1") { //自然人
					$("C_RELATION_P").disabled = false;
					$("C_RELATION_E").disabled = true;
				}else{//法人
					$("C_RELATION_P").disabled = true;
					$("C_RELATION_E").disabled = false;
				}
			}
			
			//自動查詢第一筆明細資料
			var radioBox = $('tableUiGrid').select("input[type=radio]");
			if(radioBox.length > 0){
				radioBox[0].checked = true;
				radioBox[0].simulate("click");
			}
			
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_ADD","BTN_CLEAR"] );
		};
		//失敗動作
		var errorAction = function(resp){ };
		
		buttonActions.clearAll();
		//呼叫AJAX
		tools.ajaxPost(actionName, queryData, successAction, errorAction);
	}
	,queryDetail:function(record){
		//動作名稱
		var actionName = "queryDetail"; 
		//傳遞參數
		
		var queryData = PageUI.getContentValues( ContentSaves["A"] );
		queryData["memberMap"] = Object.toJSON(record);
		var params = {"queryData":Object.toJSON(queryData)};
		//成功動作
		var successAction = function(resp){
			//取得各欄位資料
			var DSA020 = resp.DSA020;
			var DSA021_List = resp.DSA021_List;
			var now_DSA022_List = resp.now_DSA022_List;
			var before_DSA022 = resp.before_DSA022;
			var DSA023_List = resp.DSA023_List;
			var mainMap = resp.mainMap;
			
			DSA020["APPLY_PROCESS_NM"] = dataMainMap["APPLY_PROCESS_NM"]
			PageUI.setContentValues( ContentSaves["C"] , DSA020 , true , true );
			RecrodsControl.clearAll("D");
			RecrodsControl.loadin("D" , DSA021_List);
			RecrodsControl.clearAll("E");
			RecrodsControl.loadin("E" , now_DSA022_List);
			PageUI.setContentValues( ContentSaves["F"] , before_DSA022 , true , true );

			<%-- [20221121] 若為自然人且小於18歲，字體紅色 --%>
			if (DSA020.AGE < 18 && DSA020.ID.length != 8) {
				$('C_AGE').setStyle({color:'red'});
			} else {
				$('C_AGE').setStyle({color:'black'});
			}
			
			//收入項目_經營事業/薪資收入(年所得含獎金) 預帶
			if(!DSA020.INCOME&&DSA020.INCOME!='0'){
				var INCOMEs = [];
				for(var index=0; index<now_DSA022_List.length;index++){
					var income = now_DSA022_List[index]['YEAR_INCOME'];
					if(income && income!='0'){
						INCOMEs.push(income);
					}
				}
				if(INCOMEs.length=='0'){
					for(var index=0; index<DSA021_List.length;index++){
						var income = DSA021_List[index]['YEAR_PROFIT'];
						if(income && income!='0'){
							INCOMEs.push(income);
						}
					}
				}
				if(INCOMEs.length!=0){
					tools.ajaxPost('calculate', {'type':'INCOME','value':Object.toJSON(INCOMEs)}, 
						function(resp){
							DSA020['INCOME'] = resp.rtnValue||'0';
						}, 
						function(resp){
							DSA020['INCOME'] = '';
						},false);//isSynchronous
				}else{
					DSA020['INCOME'] = '';
				}
				
			}
			DSA020['INCOME_TOTAL'] = parseFloat(DSA020['INCOME'] || 0) +  parseFloat(DSA020['OTHER_INCOME'] || 0) || '0';
			
			<%-- [20191217] 增加 --%>
			if(isCORP_DEPT == 'Y'){					
				var COUNTRY = DSA020.COUNTRY || '';
				var COUNTRY_NM = '';
				for(var i in COUNTRY_List){
					if(COUNTRY == COUNTRY_List[i]['COUNTRY']){
						COUNTRY_NM = COUNTRY_List[i]['COUNTRY_NM'];
					}
				}		
				
				$('C_COUNTRY_NM').value =  COUNTRY_NM;
			} 
			
			PageUI.setContentValues( ContentSaves["G"] , DSA020 , true , true );
			RecrodsControl.clearAll("H");
			RecrodsControl.loadin("H" , DSA023_List);
			
			SelectionChangeControl();
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD","BTN_MODIFY","BTN_DELETE"] );

		};
		//失敗動作
		var errorAction = function(resp){ };
		
		buttonActions.clearDetails();
		
		//呼叫AJAX
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
	,addDetail:function(){
		<%-- [20221121] 檢核保證人年齡 --%>
		if ( '' !=$F('C_ID') && $F('C_ID').length != 8) {//自然人才需檢查年齡
			if( '' != $('C_AGE').innerHTML && parseInt($('C_AGE').innerHTML) <= parseInt('${AGE_MIN}') ){
				alert('請再次確認保證人已成年!');
			}
		}
		
		if(!buttonActions.validate()){return;}
		
		//動作名稱
		var actionName = "add"; 
		//傳遞參數
		var params = buttonActions.getDetailRecords(true);
		if(!params) {return;}

		var successAction = function(resp){
			ContentSaves["B"].load(resp.memberList);
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD","BTN_MODIFY","BTN_DELETE"] );
		};
		var errorAction = function(resp){
		};
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
	,updateDetail:function(){
		<%-- [20221121] 檢核保證人年齡 --%>
		if ( '' != $F('C_ID') && $F('C_ID').length != 8) {//自然人才需檢查年齡
			if( '' != $('C_AGE').innerHTML && parseInt($('C_AGE').innerHTML) <= parseInt('${AGE_MIN}') ){
				alert('請再次確認保證人已成年!');
			}
		}
		
		if(!buttonActions.validate()){return;}
		
		//動作名稱
		var actionName = "update"; 
		//傳遞參數
		var params = buttonActions.getDetailRecords();
		if(!params) {return;}
		
		var successAction = function(resp){
			ContentSaves["B"].load(resp.memberList);
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD","BTN_MODIFY","BTN_DELETE"] );
		};
		var errorAction = function(resp){
		};
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
	,deleteDetail:function(){
		//動作名稱
		var actionName = "delete"; 
		//傳遞參數
		var queryData = ContentSaves["B"].getCheckedRecord();
		if(!queryData || queryData.length == 0){
			alert('請先選擇資料');
			return;
		}
		
		VaildationSaves["A"].reset();
		
		if( !VaildationSaves["A"].validate() ) {return false;}
		
		if(dataMainMap.APPLY_ID != $('A_APPLY_ID').value){
			alert("您輸入的受理編號"+$('A_APPLY_ID').value+"與原先查詢的受理編號"+dataMainMap.APPLY_ID+"不同,無法作業!");
			return false;
		}
		
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			ContentSaves["B"].load(resp.memberList);
			buttonActions.clearDetails();
			PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD"] );
		};
		var errorAction = function(resp){
		};
		tools.ajaxPost(actionName, params, successAction, errorAction);
	}
	,getAge:function(BIRTHDAY){
		if(!JsUtils.isObject(dataMainMap)){ return; }
		var APPLY_DATE = dataMainMap["APPLY_DATE"];
		if(!JsUtils.isString(APPLY_DATE)){return;}
		//動作名稱
		var actionName = "getAge"; 
		//傳遞參數
		var queryData = { BIRTHDAY:BIRTHDAY, APPLY_DATE:APPLY_DATE };
		
		<%-- [20221121] 預設字體黑色 --%>
		$('C_AGE').setStyle({color:'black'});
		
		//成功動作
		var successAction = function(resp){
			PageUI.setContentValue("C_AGE" , resp , true , true );
			
			<%-- [20221121] 若為自然人且小於18歲，字體紅色 --%>
			if (resp.AGE < 18 && $F('C_ID').length != 8) {
				$('C_AGE').setStyle({color:'red'});
			}
		};
		//失敗動作
		var errorAction = function(resp){ 
			PageUI.setContentValue("C_AGE" , "" , true , true );		
		};
		
		//呼叫AJAX
		tools.ajaxPost(actionName, queryData, successAction, errorAction);
		
	}
	,getDetailRecords:function( checkDeferentAPPLY_ID ){
		tools.nodesToUpperCase(['C_ID']);
		PageUI.commitContentValues( ContentSaves["C"] );
		var DSA021_VOList_Map =     PageUI.getContentValues( ContentSaves["D"] );
		var now_DSA022_VOList_Map = PageUI.getContentValues( ContentSaves["E"] );
		var before_DSA022_VO =      PageUI.getContentValues( ContentSaves["F"] );
		var DSA020_VO =             PageUI.getContentValues( ContentSaves["G"] );
		var DSA023_VOList_Map =     PageUI.getContentValues( ContentSaves["H"] );

		//DSA020_VO['SEX'] = DSA020_VO['ID'].substr(1,1);  //2017-08-28改模組CALL共用模組以ID判斷性別1男2女
		DSA020_VO['DOCS'] = JsUtils.arrayToString(DSA020_VO['DOCS']);
		DSA020_VO['TYPE'] = "1"; //保人
		
		//alert(Object.toJSON(DSA021_VOList_Map));
		//return false;
		
		VaildationSaves["A"].reset();
		
		if( !VaildationSaves["A"].validate() ) {return false;}
		
		if(  checkDeferentAPPLY_ID 
		  && $('A_APPLY_ID').value 
		  && dataMainMap.APPLY_ID != $('A_APPLY_ID').value ){
			if(confirm("請確認是否將資料新增到此 "+ $('A_APPLY_ID').value +" 中?")){
				DSA020_VO['APPLY_ID'] = $('A_APPLY_ID').value;
			}else{
				return false;
			}
		}else{
			if(dataMainMap.APPLY_ID != $('A_APPLY_ID').value){
				alert("您輸入的受理編號"+$('A_APPLY_ID').value+"與原先查詢的受理編號"+dataMainMap.APPLY_ID+"不同,無法作業!");
				return false;
			}
		}
		
		//20200213 法金件導入：法金件可同時選擇企業關係及個人關係
		DSA020_VO['RELATION'] = (DSA020_VO.RELATION_E||'X') + (DSA020_VO.RELATION_P||'X');
		
		var isREG_ZIP_ADDR = (DSA020_VO.CON_CODE == "4");
		DSA020_VO.REG_CODE = isREG_ZIP_ADDR ? "2" : "";
		DSA020_VO.REG_ZIP = isREG_ZIP_ADDR ? DSA020_VO.CON_ZIP : "";
		DSA020_VO.REG_ADDR = isREG_ZIP_ADDR ? DSA020_VO.CON_ADDR : "";
		DSA020_VO.REG_OWNER = isREG_ZIP_ADDR ? DSA020_VO.OWN_CODE : "";
		
		var DSA021_VOList = [];
		var now_DSA022_VOList = [];
		var DSA023_VOList = [];
		
		/* area D edit*/
		var isHeader = true;
		for( var key in DSA021_VOList_Map ){
			if(isHeader) {
				isHeader = false;
			}else{
				var DSA021 = DSA021_VOList_Map[key]
				DSA021['APPLY_ID'] = DSA020_VO['APPLY_ID'];
				DSA021['TYPE'] = DSA020_VO['TYPE'];
				DSA021['ID'] = DSA020_VO['ID'];
				DSA021_VOList[DSA021_VOList.length] = DSA021;
			}
		}
		
		/* area E edit*/
		isHeader = true;
		var isAML = "N";
		for( var key in now_DSA022_VOList_Map ){
			if(isHeader) {
				isHeader = false;
			}else{
				var now_DSA022_VO = now_DSA022_VOList_Map[key]
				//電腦作業申請書評估報告-調整放款客戶高風險職業抓取規則
				/*705軍職人員、713 政治從業人員/村里長，加註提示用語：若為洗錢防制法所定義「重要政治性職務」之人，
				例如正副總統、秘書長、五院正副院長、立委監委考試委員、地方正副首長議長、中將以上、國營事業相當於簡任13職等以上之高管等，
				請改列為「220 洗錢防制法所定義之「重要政治性職務」之人」。僅提示，不做卡控*/
				if ("705" == now_DSA022_VO['OCCU_CODE'] || "713" == now_DSA022_VO['OCCU_CODE'] ) {
					isAML = "Y";
				}
				
				now_DSA022_VO['APPLY_ID'] = DSA020_VO['APPLY_ID'];
				now_DSA022_VO['TYPE'] = DSA020_VO['TYPE'];
				now_DSA022_VO['ID'] = DSA020_VO['ID'];
				now_DSA022_VOList[now_DSA022_VOList.length] = now_DSA022_VO;
			}
		}
		
		if ("Y" == isAML){		
			if(!confirm('若為洗錢防制法所定義「重要政治性職務」之人，例如正副總統、秘書長、五院正副院長、立委監委考試委員、地方正副首長議長、中將以上、國營事業相當於簡任13職等以上之高管等，請改列為「220 洗錢防制法所定義之「重要政治性職務」之人」。\r\n\r\n請確認是否要繼續執行?')) {
				return;
			}
		}
		
		/* area F edit*/
		before_DSA022_VO['APPLY_ID'] = DSA020_VO['APPLY_ID'];
		before_DSA022_VO['TYPE'] = DSA020_VO['TYPE'];
		before_DSA022_VO['ID'] = DSA020_VO['ID'];
		before_DSA022_VO['SEQ_NO'] = "0";
		before_DSA022_VO['SALARY'] = "0";
		before_DSA022_VO['SERV_ZIP'] = "";
		before_DSA022_VO['SERV_ADDR'] = "";
		
		/* area G edit*/
		
		/* area H edit*/
		isHeader = true;
		for( var key in DSA023_VOList_Map ){
			if(isHeader) {
				isHeader = false;
			}else{
				var DSA023 = DSA023_VOList_Map[key]
				DSA023['APPLY_ID'] = DSA020_VO['APPLY_ID'];
				DSA023['TYPE'] = DSA020_VO['TYPE'];
				DSA023['ID'] = DSA020_VO['ID'];
				DSA023_VOList[DSA023_VOList.length] = DSA023;
			}
		}
		
		//alert(Object.toJSON(DSA021_VOList));
		//alert("DSA021_VOList:"+DSA021_VOList.length);
		//alert("now_DSA022_VOList:"+now_DSA022_VOList.length);
		//alert("DSA023_VOList:"+DSA023_VOList.length);
		
		var rtnMap = {
			DSA020_VO : Object.toJSON(DSA020_VO),
			DSA021_VOList : Object.toJSON(DSA021_VOList),
			now_DSA022_VOList : Object.toJSON(now_DSA022_VOList),
			before_DSA022_VO : Object.toJSON(before_DSA022_VO),
			DSA023_VOList : Object.toJSON(DSA023_VOList)
		};
		return rtnMap;
	}
	,clearDetails:function(){
		//預設值
		var tempDSA020 = {APPLY_ID:dataMainMap["APPLY_ID"] , APPLY_PROCESS_NM:dataMainMap["APPLY_PROCESS_NM"] , TYPE:"1" , COUNTRY_NM:"中華民國", COUNTRY:"TW"};
		PageUI.setContentValues( ContentSaves["C"] , tempDSA020 , true , true );
		ID_TYPE_changeController(isCORP_DEPT,($('ID_TYPE')?$F('ID_TYPE'):null));	
		RecrodsControl.clearAll("D");
		RecrodsControl.clearAll("E");
		PageUI.setContentValues( ContentSaves["F"] , null , true , true );
		PageUI.setContentValues( ContentSaves["G"] , tempDSA020 , true , true );
		RecrodsControl.clearAll("H");
		PageUI.setButtonsEnable( recordsControlButtonArea , ["BTN_CLEAR","BTN_ADD"] );
	}
	,clearAll:function(){
		dataMainMap = {};
		ContentSaves["B"].load();
		buttonActions.clearDetails();
		PageUI.setButtonsEnable( recordsControlButtonArea , [] );
		SelectionChangeControl();
	}
	,dateFormats:{}
	
	,dateAutoFormat:function( node ){
		node = JsUtils.getDOM(node);
		if(!node || !node.value ){ return; }
		var datatype = node.getAttribute("datatype").toLowerCase();
		var pattern = node.getAttribute("pattern");
		if( pattern ){
			if( datatype == "date"){
				if(!buttonActions.dateFormats["US_"+pattern]){
					buttonActions.dateFormats["US_"+pattern] = new SimpleDateFormat(pattern , SimpleDateFormat.US);
				}
				node.value = buttonActions.dateFormats["US_"+pattern].format(node.value);
			}else if(datatype == "rocdate"){
				if(!buttonActions.dateFormats["TW_"+pattern]){
					buttonActions.dateFormats["TW_"+pattern] = new SimpleDateFormat(pattern , SimpleDateFormat.TW);
				}
				node.value = buttonActions.dateFormats["TW_"+pattern].format(node.value);
			}
		}
	}
	,validate:function(){
		var returnResult = true;
		VaildationSaves["C"].reset();
		VaildationSaves["F"].reset();
		VaildationSaves["G"].reset();
		
		var msg = "";
		/*if(RecrodsControl.commitRecords["D"]){
			msg = msg + "請先確認您 目前經營事業 的修改\n";
		}
		if(RecrodsControl.contentsStatusSave["E"]){
			msg = msg + "請先確認您 目前服務單位 的修改\n";
		}
		if(RecrodsControl.contentsStatusSave["H"]){
			msg = msg + "請先確認您 本人其他不動產暨設定明細 的修改\n";
		}*/
		if(RecrodsControl.contentsCount["D"] == 0 && RecrodsControl.contentsCount["E"] == 0){
			msg = msg + "目前經營事業 及 目前服務單位 必須擇一輸入一筆資料\n";
		}
		if(msg){
			alert(msg);
			return false;
		}
		
		returnResult = VaildationSaves["C"].validate() && returnResult;
		PageUI.commitContentValues( ContentSaves["C"] );
		returnResult = RecrodsControl.commitRecords("D")  && returnResult;
		returnResult = RecrodsControl.commitRecords("E")  && returnResult;
		returnResult = VaildationSaves["F"].validate() && returnResult;
		PageUI.commitContentValues( ContentSaves["F"] )
		returnResult = VaildationSaves["G"].validate() && returnResult;
		PageUI.commitContentValues( ContentSaves["G"] )
		returnResult = RecrodsControl.commitRecords("H")  && returnResult;
		
		return returnResult;
	}
}




var RecrodsControl = {
	 createRecord : function ( area , value ){
		/*var type = RecrodsControl.contentsStatusSave[area] || 0 ;
		if(type !== 2){
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
				RecrodsControl.contentsValidationSave[tbody.getAttribute("id")] = new Validation( tbody, {useTitles:true,focusOnError:false,immediate:false,mode:"validator",alertTitle:RecrodsControl.ValidationTitle[area]});
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
		if(commitElem && commitElem.tagName == "TBODY"){
			var tbodyId = commitElem.getAttribute("id");
			if(tbodyId && RecrodsControl.contentsValidationSave[tbodyId] ){
				RecrodsControl.contentsValidationSave[tbodyId].reset();
				checkResult = RecrodsControl.contentsValidationSave[tbodyId].validate() && checkResult;
			}else{
				alert("發生不明錯誤(MISSING ID)");
				checkResult = false;
			}	
		}else if(commitElem && commitElem.tagName == "TABLE"){
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
		}else if( area && RecrodsControl.ContentsSave[area] ){
			commitElem = RecrodsControl.ContentsSave[area]
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
		}
		
		if(checkResult){
			PageUI.commitContentValues( commitElem );
			RecrodsControl.contentsStatusSave[area] = 0;
		}
		return checkResult;
		
		/*
		if(!checkResult) {return; }
		PageUI.commitContentValues( commitElem );
		PageUI.setContentsDisplay( commitElem , 1 );
		RecrodsControl.contentsStatusSave[area] = 0;
		var records = RecrodsControl.records[area];
		if( records && records.length > 0){
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD",area+"_MOD"], [area+"_DEL"]);
		}else{
			PageUI.setButtonsEnable( RecrodsControl.ButtonContentsSave[area] , [area+"_ADD"], [area+"_DEL"] );
		}
		*/
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
			if(records.length>0){
				contentTable.removeChild(records[records.length - 1]);
			}
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
	,ValidationTitle:{D:"目前經營事業",E:"目前服務單位",H:"本人其他不動產暨設定明細"}
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
	,ajaxPost:function ( actionName, params, successAction, errorAction,isSynchronous){
		new Ajax.Request( 
			"<%=dispatcher%>/DSA1_0250/" + actionName,
			{ parameters: params,
			  asynchronous: (isSynchronous==null?true:isSynchronous),
			  onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
						successAction(resp);
					}
				}else if(errorAction){
					errorAction(resp);
				}
			}}
		);
	}
}

function vaildationRules(){
	Validation.addAllThese([
		['validateId', '身份證字號有誤，請檢查後重新輸入!', function(v) {
			var ID_TYPE = $F('C_ID_TYPE');<%-- [20191217] 增加 法金件 檢核 --%>
			var val_length = v.length;<%-- [20191217] 增加 法金件 檢核 --%>
            if(isCORP_DEPT == "N" || ID_TYPE == '1'){//非法金件		
				if(GAGE_TYPE && isFori){
					return true;
				}else if(GAGE_TYPE && !isFori){
					return dataMainMap ? (v.length==10 ? idCheck1(v):iscmpid(v) ): true;
				}
			} else { 
			  <%-- [20191217] 增加 法金件 檢核 --%>
			  if(ID_TYPE == '2'){//國內自然人
			    if(val_length != 8){
				  return false;
				} else {
				  return v ? iscmpid(v) : true ;
				}
			  } else { //ID_TYPE = ‘3’ OR ‘4’
			    return true;
			  }
			}
		}]
		<%-- [20191217] 增加 法金件 檢核 --%>	
        ,['vaildateNotBlank', '不得空白', function(v , node ) { 
		   var ID_TYPE = $F('C_ID_TYPE');
		   var value = node.value.trim();
		   if(!value || value == '0'){
			  if(isCORP_DEPT == "N"){//非法金件
				return false;
		      } else if(ID_TYPE == '1'){//國內自然人		     
				return false;
			  }			 
		   }		   
		   return true;
		 }]		
		,['vaildateNotZero', '不得空白', function(v , node ) { return node.value!==0 && node.value!=="0"; }]
		,['vaildateRelationE', '企業關係為必要欄位', function(v) { return dataMainMap ? ( dataMainMap.COPR_CODE!=1 ? true : !!v  ): true; }]
		,['vaildateRelationP', '自然人關係為必要欄位', function(v) { return dataMainMap ? ( dataMainMap.COPR_CODE!=1 ? !!v : true ): true; }]
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
				var inputFind = false;
				for(var i = checks.length-1 ; i >= 0 ; i = i - 1 ){
					if( node == checks[i] ){
						inputFind = true;
					}
					if(inputFind && checks[i].getAttribute("type")=="checkbox" ){
						return checks[i].checked ? !!v : true;
					}
				}
				return ( node != checks[0]);
			}
			return true;
		 }]
		,['requiredWhenAbled', '不得空白', function(v , node ) { return ( !node.disabled || node.style.display != 'none') && v; }]
		,['validateCmpId', '統一編號有誤，請檢查後重新輸入!', function(v) { 
			if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
				return true
			}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
				return v ? iscmpid(v) : true ; 
			}
		}]
		,['validateFullType', '內容必須為全形', function(v) { 
			if(!v){
				return true;
			}
			if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){
				return true;
			}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
				return !validation.hasHalfType(v);
			}
		}]
		,['validateHalfType', '英數必須為半形', function(v) { 
			if(!v){
				return true;
			}
			if(GAGE_TYPE && (GAGE_TYPE == '6' || GAGE_TYPE == '7')){ //TODO
				//如果包含全形英數，則跳出檢核
				var result = "";
				var old_addr = v;
				var hasFull = false;
				for ( var i = 0 ; i < length ; i ++ ) {
					var val = old_addr.charAt(i) ;  
					var j = fForm.indexOf(val) ;        
					if(j > -1){
						hasFull = true;
						break;
					}    
				}
				  
				return !hasFull;
			}else if(GAGE_TYPE && GAGE_TYPE != '6' && GAGE_TYPE != '7'){
				return true;
			}
		}]
		,['validateMaxLength', '字數過長', function(v , node) { 
			if(!v){return true;} 
			return validation.checkInputLength(v, node.maxLength, node.fullLength, node.halfLength); }]
        <%-- [20220829] 新增目前服務單位 - 電話檢核規則 --%>
        ,['validate_SERV_TEL_required', '電話不得為空', function(v, node) {
        	var OCCU_CODE = node.up('tr').previousSibling.down('select.OCCU_CODE').getValue();
			//if(!['703', '707', '710'].includes(OCCU_CODE) && !v){
			if(!v && ('703'!=OCCU_CODE && '707'!=OCCU_CODE && '710'!=OCCU_CODE) ){
				return false;
			}
			return true;}]					 
		,['requlredAreaF', '不得空白', function(v) { return $('F_SERV_NAME').value ? !!v : true; }]
		,['checkDSZ01000value' ,'必須填入詳細地址',function(v,node){
			var selectValue = node.value;
			var DSZ01000node = node.parentNode.nextSibling;
			var showRules = theDSZ01000control.showRules[DSZ01000node.getAttribute("autoInputValueKey")]
			if( showRules && showRules[selectValue] && showRules[selectValue] != 'node'){
				var preKey = DSZ01000node.firstChild.getAttribute("preKey");
				var values = {};
				values[preKey+"_CODE"] = selectValue;
				return !!(theDSZ01000control.get(DSZ01000node.firstChild , values ) );
			}
			return true;
		 }]
		,['checkIsROCDate' ,'請輸入正確時間格式',function(v,node){ return !v || isROCdate(v,false); }]
		,['between0To100' ,'必須於0~100間',function(v,node){ return v>=0 && v<=100; }]
		,[ 'validationAPPLY_ID',  '受理編號有誤，請檢查後重新輸入!', 
			function(v){ 
				<%--受理編號：11英數字+@--%>
				return (v.length == 11 && (/^[a-zA-Z0-9@]+$/.test(v))); 
			} 
		]
		<%-- [20221121] 檢核保證人年齡 
		['validate-age', '請再次確認保證人已成年!', function(value) {
			if (value && $F('C_ID').length != 8) {
				// 自然人才需檢查年齡
				return parseInt($('C_AGE').innerHTML) >= parseInt('${AGE_MIN}');
			}
			return true;
		}]--%>
	]);
}



var selectionOptions = {
	// 「保人戶籍地址碼」、「戶籍地址碼」、「目前經營事業-事業處所碼」、「目前服務單位-詳細地址碼」下拉選單
	 BUSS_CODE_List:<c:choose><c:when test="${not empty BUSS_CODE_List}">${BUSS_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose> 
	,BUSS_CODE1_List:<c:choose><c:when test="${not empty BUSS_CODE1_List}">${BUSS_CODE1_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「保人戶籍地址所有人」、「戶籍所有人」下拉選單
	,OWN_CODE_List:<c:choose><c:when test="${not empty GAGE_CODE_List}">${GAGE_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「戶籍使用狀況」下拉選單
	,USE_STATUS_List:<c:choose><c:when test="${not empty CON_STATUS_List}">${CON_STATUS_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「聯絡電話-區碼」、「目前經營事業-區碼」、「目前服務單位-區碼」下拉選單
	,TEL_AREA_List:<c:choose><c:when test="${not empty TEL_AREA_List}">${TEL_AREA_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「學歷」下拉選單
	,DEGREE_List:<c:choose><c:when test="${not empty DEGREE_List}">${DEGREE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「婚姻狀況」下拉選單
	,MARRY_List:<c:choose><c:when test="${not empty MARRY_List}">${MARRY_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「婚姻狀況-存歿」下拉選單
	,SPOUSE_LIVE_List:<c:choose><c:when test="${not empty SPOUSE_LIVE_List}">${SPOUSE_LIVE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「子女人數」下拉選單
	,SON_NO_List:<c:choose><c:when test="${not empty SON_NO_List}">${SON_NO_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「保證人與借款人關係.企業關係」下拉選單
	,RELATION_E_List:<c:choose><c:when test="${not empty RELATION_E_List}">${RELATION_E_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「證人與借款人關係.自然人關係」下拉選單
	,RELATION_P_List:<c:choose><c:when test="${not empty RELATION_P_List}">${RELATION_P_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「證人與借款人關係.自然人關係」下拉選單
	,GUAR_KIND_List:<c:choose><c:when test="${not empty GUAR_KIND_List}">${GUAR_KIND_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「檢附相關文件」下拉選單
	,DOCS_CODE_List:<c:choose><c:when test="${not empty DOCS_CODE_List}">${DOCS_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前經營事業-營業處所使用情形」下拉選單
	,USE_STATUS_A021_List:<c:choose><c:when test="${not empty USE_STATUS_A021_List}">${USE_STATUS_A021_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前經營事業-行業別」下拉選單
	,A021_BUSINESS_CODE_List:<c:choose><c:when test="${not empty A021_BUSINESS_CODE_List}">${A021_BUSINESS_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前經營事業-職業類別」下拉選單
	,A021_OCCU_CODE_List:<c:choose><c:when test="${not empty A021_OCCU_CODE_List}">${A021_OCCU_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前服務單位-身分別」下拉選單
	,WORK_TYPE_List:<c:choose><c:when test="${not empty WORK_TYPE_List}">${WORK_TYPE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前服務單位-行業別」下拉選單
	,A022_BUSINESS_CODE_List:<c:choose><c:when test="${not empty A022_BUSINESS_CODE_List}">${A022_BUSINESS_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「目前服務單位-職業類別」下拉選單
	,A022_OCCU_CODE_List:<c:choose><c:when test="${not empty A022_OCCU_CODE_List}">${A022_OCCU_CODE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	// 「本人其他不動產暨設定明細-使用情形」下拉選單
	,USE_STATUS_A023_List:<c:choose><c:when test="${not empty USE_STATUS_A023_List}">${USE_STATUS_A023_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	
	/* [20191217] 「保人種類」下拉選單 */
	,A020_ID_TYPE_List:<c:choose><c:when test="${not empty A020_ID_TYPE_List}">${A020_ID_TYPE_List}</c:when><c:otherwise>[]</c:otherwise></c:choose>
	
	,PLS_CHOOSE:[{CODE:"" , CODE_NM:"請選擇"}]
	,BLANK_CHOOSE:[{CODE:" " , CODE_NM:" "}]
	,AREA_CODE:[{CODE:"" , CODE_NM:"(區碼)"}]
	,isCORP_DEPT_BLANK:function(){
		if('Y'==isCORP_DEPT){
			return [{CODE:" " , CODE_NM:" "}];
		}
		return [];
	}
}

theDSZ01000control = {
	create:function(){
		var sno = theDSZ01000control.DSZ01000saves.length;
		var div = new Element("span" , {sno:sno , id:"autoDSZ01000"+sno , DSZ01000:true});
		theDSZ01000control.DSZ01000saves[sno] = div;
		return div;
	}
	,createDSZ01000: function(){
		var saveNum = theDSZ01000control.DSZ01000saves.length;
		for( var i = saveNum-1 ; i >= 0  ; i = i - 1 ){
			var testNode = theDSZ01000control.DSZ01000saves[i];
			if(JsUtils.isDOMObject(testNode))
			{
				
				var aDSZ01000 = new DSZ01000(testNode, "2", 80);
				theDSZ01000control.DSZ01000saves[i] =	aDSZ01000
				theDSZ01000control.displayControl( aDSZ01000 , testNode.getAttribute("display"), testNode );
			}else{
				break;
			}
		}
	}
	,get:function( node ,  rtnMap ){
		var preKey = node.getAttribute("preKey");
		var CODE = rtnMap[preKey+"_CODE"]  || node.parentNode.previousSibling.firstChild.value || "" ;
		var ruleId = node.parentNode.getAttribute("autoInputValueKey");
		var ruleMap = theDSZ01000control.showRules[ruleId];
		if( ruleMap[CODE] && ruleMap[CODE] != 'none'){
			var sno = node.getAttribute("sno");
			var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
			if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
				rtnMap[preKey+"_ZIP"] = aDSZ01000.getINPUT_ZIPCODE();
				rtnMap[preKey+"_ADDR"] = aDSZ01000.getINPUT_ADDR();
			}
			if(rtnMap[preKey+"_ADDR"] ){
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
		if(JsUtils.isDOMObject(aDSZ01000)){
			theDSZ01000control.createDSZ01000(aDSZ01000);
			aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
		}
		if(aDSZ01000 && !JsUtils.isDOMObject(aDSZ01000)){
			if(JsUtils.isObject(valuesMap)){
				var preKey = node.getAttribute("preKey");
				aDSZ01000.setINPUT_ZIPCODE(valuesMap[preKey+"_ZIP"]);
				aDSZ01000.setINPUT_ADDR(valuesMap[preKey+"_ADDR"]);
				var CODE = valuesMap[preKey+"_CODE"];
				var ruleId = node.parentNode.getAttribute("autoInputValueKey");
				var ruleMap = theDSZ01000control.showRules[ruleId];
				theDSZ01000control.displayControl( aDSZ01000 , JsUtils.isObject(ruleMap) ? ruleMap[CODE] : '', node );
			}else{
				theDSZ01000control.displayControl( aDSZ01000 , valuesMap, node);
			}
		}
	}
	,displayControl:function( aDSZ01000 , type, node ){
		type = JsUtils.isString(type) ?type.toLowerCase():"";
		aDSZ01000.setBlnToHalfType(isFori);
		if(isFori){ //TODO
			var preKey = node.getAttribute("preKey");
			//通訊地址的郵遞區號塞10633
			if(preKey == "CON"){
				aDSZ01000.setBlnZIPCODE(10633);
			}
		}
		switch(type){
			
			case 'editaddr':
				aDSZ01000.displayOnly(false);
				aDSZ01000.display4INPUT_ZIPCODE();
				aDSZ01000.display4INPUT_ADDR(2);
				break;
			case 'edit':
				aDSZ01000.displayOnly(false);
				aDSZ01000.display4INPUT_ZIPCODE(1);
				aDSZ01000.display4INPUT_ADDR(2);
				break;
			case 'none':
			default:
				aDSZ01000.displayOnly(true);
				aDSZ01000.display4INPUT_ZIPCODE();
				aDSZ01000.display4INPUT_ADDR();
				break;
		}
	}
	,displayControl2:function( elem , changeValue ){
		var sno = elem.firstChild.getAttribute("sno");
		if(!JsUtils.isNumeric(sno) || sno > (theDSZ01000control.DSZ01000saves.length-1) ){ return; }
		var aDSZ01000 = theDSZ01000control.DSZ01000saves[sno];
		var ruleId = elem.getAttribute("autoInputValueKey");
		var ruleMap = theDSZ01000control.showRules[ruleId];
		theDSZ01000control.displayControl( aDSZ01000 , JsUtils.isObject(ruleMap) ? ruleMap[changeValue] : '', elem.firstChild );
		
	}
	,DSZ01000saves : []
	,showRules:{
		 CON_ADDR_ZIP:{"4":"edit","9":"edit" }
		,BUSS_ADDR_ZIP:{"9":"editAddr" }
		,SERV_ADDR_ZIP:{"9":"edit" }
	}
	
}

function SelectionChangeControl(){
	$$('select[changeNode]').each(
		function(target){
			displayChange( 
				target.value 
				,target.getAttribute("textAllow") 
				,target.getAttribute("changeNode") 
				,target.getAttribute("changeType") 
			 );
		}
	);
	
	$('C_ID_TYPE').simulate('change');
}

function checksControl(parent){
	parent = JsUtils.getDOM(parent);
	if(!parent){return;}
	var inputNodes = parent.getElementsByTagName("INPUT");
	var firstCheck = inputNodes[0];
	firstCheck.disabled = false;
	var firstCheck = firstCheck.checked;
	
	for(var i = 1 ; i < inputNodes.length ; i = i + 1 ){
		var testNode = inputNodes[i] ;
		var testNodeType = testNode.getAttribute("type").toLowerCase();
		if(firstCheck){
			if(testNodeType == "checkbox"){
				testNode.checked = false;
			}else if(testNodeType == "text"){
				testNode.value = "";
			}
			testNode.disabled = true;
		}else{
			testNode.disabled = false;
			if(testNodeType == "checkbox" && testNode.checked ){
				firstCheck.checked = false;
				firstCheck.disabled = true;
			}
		}
	}
}

function displayChange( checkValue , allowValues , targetNode , isHide ){
	if( JsUtils.isString(allowValues)){
		allowValues = JsUtils.stringToArray(allowValues,',');
	}
	if( !JsUtils.isArray(allowValues) ){return; }
	var allowMap = {};
	for( var i = 0 ; i < allowValues.length ; i = i + 1 ){
		allowMap[allowValues[i]] = true;
	}
	targetNode = JsUtils.stringToArray(targetNode,",");
	for(var i = 0 ; i < targetNode.length ; i = i + 1){
		var testNode = JsUtils.getDOM(targetNode[i]);
		if(!testNode ){ continue; }
		
		if( allowMap[checkValue] ){
			if(isHide !== false){
				testNode.style.display = '';
			}else{
				testNode.disabled = false;
			}
		}else{
			if(isHide !== false){
				testNode.style.display = 'none';
				testNode.value = "";
			}else{
				testNode.disabled = true;
				testNode.value = "";
			}
		}
	}
}



</script>

</head>

<body>

<div id="areaA">A</div>
<div id="areaButton">Buttons</div>
<div id="areaB">
	<table id="tableUiGrid"></table>
</div>
<div id="areaC" blockTitle="基本資料">C</div>
<div id="areaD" blockTitle="目前經營事業(包含合夥事業)">D</div>
<div id="areaE" blockTitle="目前服務單位">E</div>
<div id="areaF" blockTitle="前職單位(目前經營或服務單位若年資未滿一年者請務必填寫)">F</div>
<div id="areaG" blockTitle="個人(含配偶)全年收支情形">G</div>
<div id="areaH" blockTitle="本人其他不動產暨設定明細">H</div>
<form id="form1" name="form1" style="display:none"></form>
<div id="bar1" style="display:none"></div>
<div id="G_DOM1" >
<input id="G_CHK_NOR" name="G_CHK_NOR" fieldName="存支狀況" type="checkbox" value="1" onClick="checksControl('G_DOM1')" class="" >正常</input>
<input id="G_CHK_REJ" name="G_CHK_REJ" type="checkbox" value="1" onClick="checksControl('G_DOM1')" >拒往</input>
<input id="G_CHK_REF" name="G_CHK_REF" type="checkbox" value="1" onClick="checksControl('G_DOM1')" >退票</input>
<input id="G_REF_TIMES" name="G_REF_TIMES" type="text" datatype="number" pattern ="#,###" size="2" maxLength="2" value="" fieldName="退票次數"  class="vaildatePreCheck validateMaxLength">次</input>
<input id="G_REPAIR" name="G_REPAIR" type="checkbox" value="1" onClick="checksControl('G_DOM1')" >退補</input>
<input id="G_REPAIR_TIMES" name="G_REPAIR_TIMES" type="text" datatype="number" pattern ="#,###" size="2" maxLength="2" value="" fieldName="退補次數"  class="vaildatePreCheck validateMaxLength">次</input>
<input id="G_OTHER" name="G_OTHER" type="checkbox" value="1" onClick="checksControl('G_DOM1')" >其他</input>
<input id="G_OTHER_CONTENT" name="G_OTHER_CONTENT" type="text" size="20" maxLength="60" value="" fieldName="其他說明"  class="vaildatePreCheck validateMaxLength"></input>
</div>
<div id="G_OTHER_INCOME_ITEM_TITLE">
其他收入 (租賃、利息、其他<input id="G_OTHER_INCOME_ITEM" name="G_OTHER_INCOME_ITEM" type="text" class="textBox2 validateMaxLength" size="12" maxLength="20" value="">等)
</div>
<div id="G_OTHER_EXP_ITEM_TITLE">
其他支出 (租賃、利息、其他<input id="G_OTHER_EXP_ITEM" name="G_OTHER_EXP_ITEM" type="text" class="textBox2 validateMaxLength" size="12" maxLength="20" value="">等)
</div>
</body>
</html>
