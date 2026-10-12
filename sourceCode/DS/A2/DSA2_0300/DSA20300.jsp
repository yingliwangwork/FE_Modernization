<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA20300.jsp
功能：核貸前補全通知

[2018-07-06] 修改件
申請書180524000589 開放核貸前電子補全功能
@author 劉芷均

[2021-02-26] 修改件
申請書210120000993 聯徵公務機關資料查調作業
@author 蔡明芳
 -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>			<!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>		<!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>				<!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>			<!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/pageController.js"></script>	<!--頁碼-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
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
<script language="javascript" type="text/javascript">

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var valid1;
var valid2;
var operation = "";
var List_A106_fromQ;
var validateAPPLY_ID = function(){				
		if($F('APPLY_ID').length < 11){
			return false;
		}
		
		return true;		
}

var validate_50 = function(v){				
	if(v.length==0 || v.length>50){
		return false;
	}
	
	return true;
}


function checkInputField() {
	var status = true;
	var textAreas = $('List_A105').getElementsByTagName('textarea');
	for(var i=0 ;i<textAreas.length;i++){
		textAreas[i].style.backgroundColor = "#FFFFFF";									
	}
	
	if("input" != operation)
	{
		return true;
	}
	
	var status = true;
	var textAreas = $('List_A105').getElementsByTagName('textarea');
	for(var i=0 ;i<textAreas.length;i++){
		var td = textAreas[i];
		while(td.tagName != 'TD'){
			td = td.parentNode;
		}
		//取得對應的checkbox
		var boxs = td.getElementsByTagName('input');
		for(var j=0 ;j<boxs.length;j++){
			if(boxs[j].type == 'checkbox'){
				if(boxs[j].checked){
					if(textAreas[i].value === '') {
						textAreas[i].style.backgroundColor = "#FF8888";
						status = false;
					}
				}
				break;
			}
		}
	}
	return status;
}

//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		"B0005":'btn_delete<%--刪除--%>',
		"B0016":'btn_insert<%--輸入--%>',		
		"B0028":'btn_finish<%--補件完成--%>'		
	};	
	<dz:grantButtons FUNC_ID="DSA20300" ignored="false"/>	
}

function initApp(){
  	// 頁面 title 定位
	//PageUI.createPageWithAllBodySubElement( "DSA20300" , "核貸作業" ,"核貸前補全通知" , 1);
	PageUI.createPage("DSA20300" , "核貸作業" ,"核貸前補全通知");
    PageUI.loadin(["form1","form2"] ,1);
	
	// 顯示執行結果
	displayMessage();
	
	//按鈕權限設定
	buttonAuth();

	<%-- [2018-07-06] 刪除程式碼--%>
	$('List_A105').hide();
	
	if ('${APPLY_ID}' != "") {
		$('APPLY_ID').value = '${APPLY_ID}';	
	} else { 
		//保留參數管理-取得受理編號
		$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	} 
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});
	
	// 輸入
	$("btn_insert").observe('click',function(event){
		buttons.doInsert();
	});
	
	// 刪除
	$("btn_delete").observe('click',function(event){
		buttons.doDelete();
	});
	
	// 補件完成
	$("btn_finish").observe('click',function(event){
		buttons.doFinish();
	});
	
	Validation.addAllThese([
		[ 'validateAPPLY_ID',  '受理編號不可空白，且長度不可小於11', validateAPPLY_ID]				
	]);	
	
	/*Validation.addAllThese([
		[ 'validate-50',  '必須輸入值以及輸入值長度不得超過50字元', checkInputLength]				
	]);*/	
	
	Validation.addAllThese([
		[ 'inputAPPLY_ID',  '受理編號不一致，請重新查詢後再作業!', function () {
				if("input" != operation)
				{
					return true;
				}
				if( $F('APPLY_ID')!= $('APPLY_ID_SHOW').innerText ){
					return false;
				}
				return true;
		}]				
	]);	
	
	Validation.addAllThese([
		[ 'inputAtLeastOne',  '請至少勾選一件補全勾選事項!!', function() {
			if("input" != operation)
			{
				return true;
			}
			var hasChecked = false;
			$$('#form2 input').each( 
				function(ele){ 
					if(ele.getAttribute('name')=='ADD_ITEM' && ele.checked == true){
						hasChecked = true;
					} 
				});
			if(!hasChecked){
				return false;
			}
			return true;			
		}]				
	]);	
	
	
	Validation.addAllThese([
		[ 'removeAPPLY_ID',  '受理編號不一致，請重新查詢後再作業!', function () {
			if("remove" != operation)
			{
				return true;
			}
			if( $F('APPLY_ID')!= $('APPLY_ID_SHOW').innerText ){
				return false;
			}
			return true;
		}]				
	]);	
		
	Validation.addAllThese([
		[ 'deleteAtLeastOne',  '請至少勾選一件待補全事項!!', function() {
			if("remove" != operation)
			{
				return true;
			}
			var hasChecked = false;
			$$('#form1 input').each( 
				function(ele){ 
					if(ele.getAttribute('name')=='REMOVE_ITEM' && ele.checked == true){
						hasChecked = true;
					} 
				});
			if(!hasChecked){
				return false;
			}
			return true;
		}]				
	]);	
	
	Validation.addAllThese([
		[ 'finishAPPLY_ID',  '受理編號不一致，請重新查詢後再作業!', function () {
				if("finish" != operation)
				{
					return true;
				}
				if( $F('APPLY_ID')!= $('APPLY_ID_SHOW').innerText ){
					return false;
				}
				return true;
		}]				
	]);	
	
	Validation.addAllThese([
		[ 'mustInputField',  '尚有輸入欄未輸入值!', checkInputField]				
	]);		
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false}); 
	valid2 = new Validation("form2", {useTitles:true,focusOnError:false,immediate:false});

	
	if ('${APPLY_ID}' != "") {
		$('APPLY_ID').value = '${APPLY_ID}';
	} else { 
		//保留參數管理-取得受理編號
		$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
	}	
		
	if($('APPLY_ID').value){
		buttons.doQuery();
	}
	
	PageUI.resize(true);
		
}

//全選監聽事件
function checkAll(obj){
	if(obj.name=='SELECT_ALL'){//全選
		if(obj.checked){
			$$('#form1 input').each(
				 function(ele){ 
				 	if(ele.getAttribute('name')=='REMOVE_ITEM'){
				 		ele.checked= true; 
				 	}				 	
				}
			);
		}else{
			$$('#form1 input').each( 
				function(ele){ 
					if(ele.getAttribute('name')=='REMOVE_ITEM'){
						ele.checked= true; 	
					}
				}
			);
		}
	}else{
		if(obj.checked){
			var boxs = document.getElementsByName('REMOVE_ITEM');
			$('SELECT_ALL').checked= true;
			for(var j=0 ;j<boxs.length;j++){
				if(!boxs[j].checked){
					$('SELECT_ALL').checked= false;
					break;
				}
			}
			
		}else{
			$('SELECT_ALL').checked= false;
		}		
	}
}

//轉大寫
function toUpperChar(keys){
	$w(keys).each(
		function(key){
			$(key).value = $(key).value.toUpperCase();
		});
}
//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		toUpperChar("APPLY_ID");
		
		operation = 'query';
		valid1.reset();
		if( !valid1.validate() ) {return;}
		
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});
		var actionName = "query"; 
		var params = Form.serialize("form1");
		ajaxPost(actionName, params);
	},
	//輸入
	doInsert:function(){
		toUpperChar("APPLY_ID");
		
		operation = 'input';
		
		
		toUpperChar("APPLY_ID");
		var actionName = "insert"; 
		//將TextArea值傳給對應的checkbox值
		getTextAreaValue();
		getInputTextValue();
		
		valid1.reset();
		if( !valid1.validate() ) {return;}
		
		var params = $("form2").serialize( true );
		params.APPLY_ID = $F('APPLY_ID');
		ajaxPost(actionName, params);
	},
	//刪除
	doDelete:function(){
		toUpperChar("APPLY_ID");
		
		operation = 'remove';
		valid1.reset();
		if( !valid1.validate() ) {return;}
		
		var actionName = "delete"; 
		var params = $("form1").serialize( true );
		params.all_List_A106 = Object.toJSON(List_A106_fromQ);
		ajaxPost(actionName, params);
	},
	//補件完成
	doFinish:function(){
		toUpperChar("APPLY_ID");
		
		operation = 'finish';
		valid1.reset();
		if( !valid1.validate() ) {return;}
		
		var actionName = "finish"; 
		var params = $("form1").serialize( true );
		ajaxPost(actionName, params);
	}
};

//--------------------------------------------------------------------------
// 表格元素產生器
//--------------------------------------------------------------------------
var tableElement = {
	// 產生tr
	createTR:function(target, position, config){
		var tr = target.insertRow(position);
		
		tr = tableElement.addAttributes(tr, config);
		return tr;
	},
	// 產生td
	createTD:function(tr, position, config){
		var td = tr.insertCell(position);
		
		var config = config;
		if(!config){
			config = {
				'class': "tbBlue",
				align: "center"
			};
		}else if(!config.align){
			config.align = "center";
		}

		td = tableElement.addAttributes(td, config);
		
		return td;
	},
	// 產生元素
	createElement:function(elementNM, config){
		var element = document.createElement(elementNM);
		if(elementNM == "textarea"){
			config.wrap = config.wrap ? config.wrap : "soft";
			config.cols = config.cols ? config.cols : "40";
			config.rows = config.rows ? config.rows : "2";
			config.disabled = config.disabled;
			
		}
		element = tableElement.addAttributes(element, config);
		
		return element;
	},
	// 將屬性設定給指定的元素 
	addAttributes:function(element, config){
		if(config){
			var key = Object.keys(config);
			key.each(
				function(key){
					var attribute = config[key];
					if(attribute){
						if(key == 'innerHTML'){
							element.innerHTML = attribute;
						}else if(key == 'class'){
							$(element).addClassName(attribute);
						}else if(key == 'EUDC'){ <%--[20240729]難字調整--%>
							element.setStyle({"font-family": 'EUDC'});
						}else{
							element.setAttribute(key, attribute);
						}
					}
				}
			);
		}
		
		return element;
	},
	
	clearShowData:function(){

		create_List_A106_table([], 0);		
		create_List_A105_table([]); <%-- [2018-07-06] 修改方法--%>
		
		$('APPLY_ID_SHOW').innerText = '';
		$('APPLY_PROCESS').innerText = '';
		$('CRED_ID').innerText = '';
		$('BORROW_NAME').innerText = '';
		$('LC_NAME').innerText = '';

	}	

};

//將TextArea值傳給對應的checkbox值
function getTextAreaValue(){
	var textAreas = document.getElementsByTagName('textarea');

	for(var i=0 ;i<textAreas.length;i++){
		var td = textAreas[i];
		while(td.tagName != 'TD'){
			td = td.parentNode;
		}
		//取得對應的checkbox
		var boxs = td.getElementsByTagName('input');
		for(var j=0 ;j<boxs.length;j++){
			if(boxs[j].type == 'checkbox'){
				if(boxs[j].checked){					
					//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
					if(textAreas[i].value.length>0){
						textAreas[i].value = textAreas[i].value.replace(/'/gi, "").replace(/"/gi, "");
						while(true){
							ln0 = textAreas[i].value.length;
							while(true){
								ln1 = textAreas[i].value.length;
								if(textAreas[i].value.indexOf('\r\n')>=0){
									textAreas[i].value = textAreas[i].value.replace(/\r\n$/g, "");
									if(ln1 == textAreas[i].value.length){
										break;	
									}
								}else{
									break;
								}
							}
							while(true){
								ln2 = textAreas[i].value.length;
								if(textAreas[i].value.indexOf(' ')>=0){
									textAreas[i].value = textAreas[i].value.replace(/ $/g, "");
									if(ln2 == textAreas[i].value.length){
										break;	
									}
								}else{
									break;
								}
							}
							if(ln0 == textAreas[i].value.length){
								break;	
							}
						}
					}
					//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
					if( validation.checkInputLength( textAreas[i].value , 100 )){
						if(boxs[j].value.indexOf(',END')>=0){
							boxs[j].value = boxs[j].value.substring(0,boxs[j].value.indexOf('：')+1);
						}
						boxs[j].value = boxs[j].value + textAreas[i].value + ',END';
					}					
					textAreas[i].setAttribute('class',"checkInputLength");
					textAreas[i].setAttribute("maxLength", "100");
					textAreas[i].setAttribute("title", "輸入值超出長度限制：補全項目編號"+boxs[j].value+' 字數：'+getWordsCnt(textAreas[i].value));
				}else{
					textAreas[i].setAttribute('class',"");
				}
				break;
			}
		}
	}
}

function getInputTextValue(){
	var inputs = document.getElementsByTagName('input');
	
	for(var j=0 ;j<inputs.length;j++){
		if(inputs[j].type == 'checkbox' && inputs[j].name != 'ADD_ITEM' && inputs[j].name != 'REMOVE_ITEM' && inputs[j].name != 'SELECT_ALL' ){
			if(inputs[j].checked){
				var name = inputs[j].name;
				var value = inputs[j].value;
				var input_texts = document.getElementsByName(name);
				for(var i=1;i<input_texts.length;i++){
					var index = value.indexOf('%');
					value = value.substring(0, index)+ input_texts[i].value +  value.substring(index+2);
				}
				inputs[j].value = value+',END';
				inputs[j].name = 'ADD_ITEM';
			}			
		}
	}

}

function getWordsCnt(str){
	var fullWordArray = str.match(/[^\x00-\xff]/g);
	var halfWordArray = str.match(/[\x00-\xff]/g);

	var fullWordLength = fullWordArray==null?0:fullWordArray.length;
	var halfWordLength = halfWordArray==null?0:halfWordArray.length;

	return fullWordLength*2+halfWordLength;
}

var orginRows = 0;
var insertSize = 0; 

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function create_List_A106_table(List_A106,ROWS){

	var table = document.getElementById('List_A106');
	var tableSize = table.rows.length;
	
	if(tableSize>orginRows){
		for(var i=orginRows; i<tableSize ;i++){						
			table.deleteRow(orginRows);
		}	
	}	

	if( List_A106.length == 0 ){
		insertSize = 0;
		return;
	}

  	var lastRow = table.rows.length;			  		
	var tr = tableElement.createTR(table, lastRow);		
	insertSize = ROWS;

	config = {		
		align: "left",					
		rowSpan:insertSize,
		'class': 'tbYellow',
		innerHTML:'<input name="SELECT_ALL" id="SELECT_ALL" type="checkbox" onclick="checkAll(this)">全選',
		width:"10%"
	};
	var td = tableElement.createTD(tr, 0, config);			
	
	var inputDate='';
	var inputId='';
	var config;	

	for(var i=0;i<List_A106.length;i=i+3){
		if(inputDate == ''){
			config = {
				'class': 'tbYellow',
				align: "left",
				innerHTML: Date.toROC(List_A106[i].INPUT_DATE)+' '+List_A106[i].INPUT_NAME,
				colSpan:5,
				width:"30%",
				EUDC: true <%--[20240729] 難字調整 --%>
			};
			var td = tableElement.createTD(tr, 1, config);
			
			inputDate = List_A106[i].INPUT_DATE;
			inputId = List_A106[i].INPUT_ID;
		}else if(inputDate != List_A106[i].INPUT_DATE || inputId != List_A106[i].INPUT_ID){
			lastRow = table.rows.length;			  		
			tr = tableElement.createTR(table, lastRow);
			
			config = {
				'class': 'tbYellow',
				align: "left",
				innerHTML: Date.toROC(List_A106[i].INPUT_DATE)+' '+List_A106[i].INPUT_NAME,
				colSpan:5,
				width:"30%",
				EUDC: true <%--[20240729] 難字調整 --%>
			};
			var td = tableElement.createTD(tr, 0, config);
			inputDate = List_A106[i].INPUT_DATE;
			inputId = List_A106[i].INPUT_ID;
		}

		lastRow = table.rows.length;			  		
		tr = tableElement.createTR(table, lastRow);
		createTDByIndex(tr, 0, 1, List_A106[i], 'tbBlue2', 'REMOVE_ITEM');					

		//若沒有值或者日期不同時要換行			
		if(List_A106[i+1] && inputDate == List_A106[i+1].INPUT_DATE && inputId == List_A106[i+1].INPUT_ID){				
			createTDByIndex(tr, 1, 2, List_A106[i+1], 'tbBlue2', 'REMOVE_ITEM');	
		}else{			
			createEmptyTD(tr, 2, 1, 'tbBlue2');
			//倒退一index 
			i--;
		}			
		
		if(List_A106[i+2] && inputDate == List_A106[i+2].INPUT_DATE && inputId == List_A106[i+2].INPUT_ID){			
			createTDByIndex(tr, 2, 2, List_A106[i+2], 'tbBlue2', 'REMOVE_ITEM');
		}else{
			createEmptyTD(tr, 2, 2, 'tbBlue2');
			i--;
		}		
	}

}

var orginRows2 = 1;
var insertSize2 = 0;
var SUPPLY_GROUP_MAP = <c:out value="${SUPPLY_GROUP_MAP}" default="{}" escapeXml="false" />;
function create_List_A105_table(List_A105){ <%-- [2018-07-06] 修改傳入參數--%>

	var table = document.getElementById('List_A105');
	var tableSize = table.rows.length;

	if(tableSize > orginRows2){
		for(var i=orginRows2;i<tableSize ;i++){						
			table.deleteRow(orginRows2);
		}
	}

	<%-- [2018-07-06] 修改參數(修改開始)--%>
	if( List_A105.length == 0){
		return;
	}
	var OLD_SUPPLY_GROUP;
	var groupList = [];

	for(var i=0;i<List_A105.length;i++){
	
		var SUPPLY_GROUP = List_A105[i].SUPPLY_GROUP;

		if(OLD_SUPPLY_GROUP && OLD_SUPPLY_GROUP!=SUPPLY_GROUP){
			
			createTable(groupList, table);
			
			groupList = [];
		}
		
		groupList.push(List_A105[i]);
		
		OLD_SUPPLY_GROUP = SUPPLY_GROUP;
	}

	if(groupList.length>0){
		createTable(groupList, table);
	}
}
<%-- [2018-07-06] 抽出共用方法--%>
function createTable (List, table){
	var lastRow;
	if (List.length > 0){
		lastRow = table.rows.length;
		var tr = tableElement.createTR(table, lastRow);
		var a105 = List[0];
		var SUPPLY_GROUP = a105.SUPPLY_GROUP;
		var SUPPLY_GROUP_NM = SUPPLY_GROUP_MAP[SUPPLY_GROUP];
		var config = {
			'class': 'tbYellow0',
			align: "center",
			innerHTML: SUPPLY_GROUP_NM,
			colSpan:3
		};
		var td = tableElement.createTD(tr, 0, config);

		for (var i=0; i<List.length ; i=i+3){
			lastRow = table.rows.length;
			tr = tableElement.createTR(table, lastRow);
			createTDByIndex(tr, 0, 1, List[i], 'tbYellow2', 'ADD_ITEM');
			if(List[i+1]){
			createTDByIndex(tr, 1, 1, List[i+1], 'tbYellow2', 'ADD_ITEM');
			}else{
				createEmptyTD(tr, 1, 1, 'tbYellow2');
			}

			if(List[i+2]){
				createTDByIndex(tr, 2, 1, List[i+2], 'tbYellow2', 'ADD_ITEM');
			}else{
				createEmptyTD(tr, 1, 2, 'tbYellow2');
			}
		}
	}
}
<%-- [2018-07-06]修改結束--%>

function createTDByIndex(tr, order, colspan, item, color, checkbox_name ){ 
	var FONT_COLOR = 'black';
	if(item.FONT_COLOR){
		FONT_COLOR = item.FONT_COLOR;
	}
	
	var oriChkboxName = checkbox_name;
	if("REMOVE_ITEM" != checkbox_name && item.SUPPLY_NAME.indexOf('%') != -1){
		checkbox_name = item.SUPPLY_ID;
	}

	var tag;
	if("REMOVE_ITEM" == oriChkboxName){
		var oi = item.OTHER_ITEM.replace("," , "/").replace("," , "/") || '';
		if("60" == item.SUPPLY_ID){
			tag = '<input name='+checkbox_name+' type="checkbox" value="'+item.SUPPLY_ID +','+ item.SUPPLY_NAME +','+ item.INPUT_ID +','+ item.INPUT_DATE +','+ oi +','+ (item.CASE_ID||'')+ ',' + (item.KIND||'')+',' + (item.ITEM||'')+',' + (item.ID||'') +','+ (item.SER_NO||'0') +'">';
		}else{
			tag = '<input name='+checkbox_name+' type="checkbox" value="'+item.SUPPLY_ID +','+ item.SUPPLY_NAME +','+ item.INPUT_ID +','+ item.INPUT_DATE +','+ (item.OTHER_ITEM||'') +','+ (item.CASE_ID||'')+ ',' + (item.KIND||'')+',' + (item.ITEM||'')+',' + (item.ID||'') +','+ (item.SER_NO||'0') +'">';
		}
	} else if ("ADD_ITEM" == oriChkboxName && "60" == item.SUPPLY_ID) {
		//[20210226] 文件補全第 60 項，號碼左邊不要 checkbox (改放在文字 T50, T51, T52 之前。所以這裡不產生 checkbox，所以也不用設定 checkbox_name.)
		tag = '';
	}else {
		tag = '<input name='+checkbox_name+' type="checkbox" value="'+item.SUPPLY_ID +','+ (item.CODE1||'') +','+ (item.CODE2||'') +','+ (item.CODE_NAME||'') +','+ (item.ID||'') +','+ (item.NAME||'') +','+ (item.SUPPLY_NAME||'') +'">';
	}


	//全選監聽事件
	if(checkbox_name =='REMOVE_ITEM'){
		var lastindex = tag.lastIndexOf(">");
		if(lastindex!=-1){
			tag = tag.substr(0,lastindex) + ' onclick="checkAll(this)" >' + tag.substr(lastindex+1);
		}
		
		config = {
			'class': color,



			align: "left",
			vAlign: 'top',
			colSpan: colspan,
			width : "30%"
		};
	
	}else {
		config = {
			'class': color,
			align: "left",
			vAlign: 'top',
			colSpan: colspan,
			width : "33%"
		};
	}
	
	if(checkbox_name =='REMOVE_ITEM'){	<%--[20240729]難字調整--%>
		config.innerHTML = tag + ' <font color=' +FONT_COLOR+'><span style="font-family:\'EUDC\'">'+ item.SUPPLY_ID 
																+'. '
																+ (isNotEmpty(item.NAME)? item.NAME:'' ) 
																+ (!isNotEmpty(item.OTHER_ITEM) ? (' '+ item.SUPPLY_NAME) : ''  ) 
																+ (isNotEmpty(item.OTHER_ITEM) ? (' '+ item.OTHER_ITEM) : ''  ) 
																+ (isNotEmpty(item.FINISH_DATE) ? (' '+'('+Date.toROC(item.FINISH_DATE)+')') : ''  ) 
							   									+ '</span></font><br/>';
	}else{
		var i=1;
		var innerHtml = item.SUPPLY_NAME;
		while(innerHtml.indexOf('%') != -1){		
			var index = innerHtml.indexOf('%');
			innerHtml = innerHtml.substring(0, index)+'<input name='+checkbox_name+' size="7" maxlength="20" class="textBox2" type="text" >' + innerHtml.substring(index+2);
			i++;
		}
		//[20210226]  文件補全第 60 項(有 # 字改 checkbox，參考前一段有 % 改成 input 欄位) ===>>> 另設一變數 j，處理 '#' (60對應文字裡只有 3個 #)
		if ("60" == item.SUPPLY_ID) {
			var j=0;
			while(innerHtml.indexOf('#') != -1){
				var index3 = innerHtml.indexOf('#');
				var QUERY_ITEM = 'JCIC_T5'+j;//查詢項目 (T50 or T51 or T52)
				//[20210226] 不應用 REMOVE_ITEM 內容修改，應使用 ADD_ITEM 內容。(原本 60 就在 ADD_ITEM 裡面，不是REMOVE_ITEM)
				innerHtml = innerHtml.substring(0, index3) + '<input name='+checkbox_name+' type="checkbox" value="'+item.SUPPLY_ID +','+ (item.CODE1||'') +','+ (item.CODE2||'') +','+ (item.CODE_NAME||'') +','+ (item.ID||'') +','+ (item.NAME||'') +','+ QUERY_ITEM +'">' + innerHtml.substring(index3+2);
				j++;
			}
		}

		if(innerHtml){<%--[20240729]難字調整--%>
			config.innerHTML = tag+' <font color=' +FONT_COLOR+'><span style="font-family:\'EUDC\'">'+ item.SUPPLY_ID +'. '+ (item.NAME||'') + innerHtml+'</span></font><br/>';
		}
		
	}	
	
	td = tableElement.createTD(tr, order, config);
	td.style.backgroundColor = item.BG_COLOR;
	
	if(item.TEXT_INPUT=='1' && checkbox_name =='ADD_ITEM'){
		var textNode1 = createTextArea(item.OTHER_ITEM , item.SUPPLY_ID);
		td.appendChild(textNode1);		
	}		
}

function createTextArea(value , SUPPLY_ID){
	var config = {
			id: "OTHER_ITEM",
			name:SUPPLY_ID,
			value: value,
			cols:30,
			rows:2,
			maxLength:100
	};
	var textNode1 = tableElement.createElement("textarea", config);	
	//textNode1.setAttribute("onblur", blurInput);	
	textNode1.setAttribute("class", "checkInputLenth");	
	
	return textNode1;
}

function blurInput() {this.value = this.value.slice(0, 100);}


function createEmptyTD(tr, colspan, order, color){
	config = {
		'class': color,
		align: "left",
		colSpan: colspan
	};
	td = tableElement.createTD(tr, order, config);	
	return td;
}

function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_0300/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){		
          		if(CSRUtil.isSuccess(resp)){
                    create_List_A106_table(resp.List_A106, resp.ROWS);
                    List_A106_fromQ = resp.List_A106 ||[];
                    
					$('List_A105').show(); <%-- [2018-07-06] 按下查詢才顯示表格--%>
				 	create_List_A105_table(resp.List_A105 || []);

					$('APPLY_ID_SHOW').innerText = resp.A010_vo.APPLY_ID;
					$('APPLY_PROCESS').innerText = resp.APPLY_PROCESS_NAME;
					$('CRED_ID').innerText = resp.CRED_NAME;
					
					$('BORROW_NAME').innerText = resp.A010_vo.BORROW_NAME;
					$('LC_NAME').innerText = resp.LC_NAME;
					if(resp.hasData == false){
						$("btn_insert").disabled = true;
						$("btn_delete").disabled = true;
						$("btn_finish").disabled = true;
					}
					<%-- [20240729]難字調整 --%>
					parseEUDC();
				}else{
					if(actionName == 'query'){
						tableElement.clearShowData();
					}
				}
				PageUI.resize(true);
			}
        }
	);
}

function doLink(YEAR_MONTH) {
	var loan_id = document.getElementById("LOAN_ID").value;
	
	window.location = "<%=dispatcher%>/DSC1_0200/prompt?LOAN_ID=" + loan_id + "&LATEST_PAY_TERM=6";
}

<%--
	辨別是否為null or undefined
--%>
function isNotEmpty(value) {
	if(value == null || typeof(value) == 'undefined' || value=='') {
		return false;
	}else {
		return true;
	}
}


</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<form name="form1" id="form1" method="post" action="">
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" id="tableA">
	<tr>
		<td align="center">
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="15%" align="left">受理編號</td>
				<td class="tbYellow2" width="85%">
					<input type="text" name="APPLY_ID" id="APPLY_ID" class='textBox2 required validateAPPLY_ID inputAPPLY_ID removeAPPLY_ID finishAPPLY_ID'
					size='13' maxLength='11' value="" /> &nbsp;
					<input type="button" name="btn_query" id="btn_query" class="button" value="查詢" />
				</td>
			</tr>
		</table>
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td colspan="6" class="tbYellow" align="center">案件資料</td>
			</tr>
			<tr align="left">
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="20%" id="APPLY_ID_SHOW"></td>
				<td class="tbYellow" width="15%">受理進度</td>
				<td class="tbYellow2" width="20%" id="APPLY_PROCESS"></td>
				<td class="tbYellow" width="15%">徵信人員</td>
				<td class="tbYellow2" width="15%" id="CRED_ID" style="font-family:'EUDC'"></td> <%--[20240729]難字調整 --%>
			</tr>
			<tr align="left">
				<td class="tbYellow" width="15%">借款人</td>
				<td class="tbYellow2" align="left" width="20%" id="BORROW_NAME" style="font-family:'EUDC'"></td> <%--[20240729]難字調整 --%>
				<td class="tbYellow" width="15%"></td>
				<td class="tbYellow2" width="20%"></td>
				<td class="tbYellow" width="15%">LC人員</td>
				<td class="tbYellow2" width="15%" id="LC_NAME" style="font-family:'EUDC'"></td> <%--[20240729]難字調整 --%>
			</tr>
		</table>
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="List_A106"></table>
		<div align="center">
			<input type="button" name="btn_insert" id="btn_insert" class="button inputAtLeastOne mustInputField" value="輸入" />
			<input type="button" name="btn_delete" id="btn_delete" class="button deleteAtLeastOne" value="刪除" />
			<input type="button" name="btn_finish" id="btn_finish" class="button" value="補件完成" /></div>
		</td>
	</tr>
</table>
</form>
<form name="form2" id="form2" method="post" action="">
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" id="List_A105">
	<tr>
		<td colspan="3" class="tbYellow" align="center">補全勾選事項</td>
	</tr>
</table>
</form>
<div id='dtlDiv' style="position: absolute; top: 0px; left: -2px; visibility: hidden" align='center'>
	<iframe src='' name='dtlFrame' width='99%' height='500' id='dtlFrame'></iframe>
</div>
</body>
</html>
