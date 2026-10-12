<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
[20240111] 申請書:24010245446 
1. 新增4項與修改現行1項查詢種類，與相關檢核規則新增
2. 新增受理編號/貸款帳號欄位、企業負責人ID欄位與取得方式
[20240125] 修改為J21才顯示，其餘hide
[20240126] 新增輸入時轉成大寫字母
[20240205] 變更檢核條件 若受編/貸款帳號或查詢項目有值時 進行申請書2-4判斷
-->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type='text/javascript' src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
</head>
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
<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;
var valid;
var index=0;

function initApp(){

	cleanMsgBoard();
	
	displayMessage();
	
	buttonAuth();
	
	initValidation();
	
	
	valid = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});

	PageUI.createPageWithAllBodySubElement("DSA20400" , "核貸作業" , "新聯徵查詢送出", 1);

	new UI().init();

	// 預設
	$('btn_delete').disabled = true;
	// 查詢按鈕
	$("btn_query").observe('click', function(event){
			doQuery();
		}
	);
	
	// 刪除按鈕
	$("btn_delete").observe('click', function(event){
			doDelete();
		}
	);

	// 送出按鈕
	$("btn_submit").observe('click', function(event){
			doSubmit();
		}
	);

	
	//於ABC3區輸入資料 ，RADIO BUTTON自動核選
	$w('CRED_DEPT CRED_ID PACK_DATES PACK_DATEE ITEM_A').each( 
		function(key){
			$(key).observe('click', function(event){
				document.getElementsByName('CHK_TYPE')[0].checked = true;
			});
		}
	);
	
	$w('BORROW_ID_B ITEM_B').each( 
		function(key){
			$(key).observe('click', function(event){
				document.getElementsByName('CHK_TYPE')[1].checked = true;
			});
		}
	);
	
	$("BORROW_ID_C").observe('click', function(event){
			document.getElementsByName('CHK_TYPE')[2].checked = true;
		}
	);
	
	//200622 詩婷：
	//選擇601時，旁邊增加紅色文字提示：「需取得客戶同意且申請書上明示「租賃與分期交易」及「勞工退休準備金資料」方得查詢。
	//選擇006時，旁邊增加紅色文字提示：「需取得客戶同意且申請書上明示「租賃與分期交易」方得查詢。
	$('ITEM_B').observe('change',function(){
		$('COUPLE_ID_B').hide(); <%--[20240125] 修改為J21才顯示，其餘hide--%>
		$('COUPLE_ID_B').setValue('');
		if('4'==$F('ITEM_B')){
			$('ITEM_B_MEMO').update('需取得客戶同意且申請書上明示「租賃與分期交易」方得查詢');
		}else if('5'==$F('ITEM_B')){
			$('ITEM_B_MEMO').update('需取得客戶同意且申請書上明示「租賃與分期交易」及「勞工退休準備金資料」方得查詢');
		}else if('7'==$F('ITEM_B')){ <%--[20240111] 新增J21判斷顯示紅字--%>
			$('ITEM_B_MEMO').update('需取得企業負責人同意方可查詢');
			$('COUPLE_ID_B').show();<%--[20240125] 修改為J21才顯示--%>
			doGetCOUPLE_ID();
		}else {
			$('ITEM_B_MEMO').update('');
		}
	});

	// 以承辦科別查詢承辦人員下拉選單
	$("CRED_DEPT").observe('change', function(event){
			doQueryCredIdList();
			//[20200611]申請書-200520002109：新增法金組合：(08)組合查詢006、(09)組合查詢601
			//承辦科別=總公司，查詢項目預設為"法金組合查詢006、601"
			if('2'==$F('CRED_DEPT')){
				$('ITEM_A').setValue('0809');
			}else{
				$('ITEM_A').setValue('06');//非總公司，預設「申請貸款(組合005)」
			}
		}
	);
	$("CRED_DEPT").simulate('change');
	$('APPLY_ID_B').observe('change', doGetCOUPLE_ID);
	$('COUPLE_ID_B').hide(); <%--[20240125] 預設為hide--%>
	$('COUPLE_ID_B').observe('change', function(){
		$("COUPLE_ID_B").setValue($F('COUPLE_ID_B').toUpperCase());<%--[20240126]新增輸入時轉成大寫字母--%>
	});
	
	// 日期欄處理
	autoFormatToDate();
	
	PageUI.resize(true);
}

function buttonAuth(){
	var authButtons = {
			B0005:"btn_delete<%--刪除--%>",
			B0031:"btn_submit<%--送出--%>"
	};
	<dz:grantButtons FUNC_ID="DSA20400" ignored="false"/>
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: true,
					autoCheckBox:{ isSelectAll :true,
                        disableRule:function(record , value){
							if ($F('QRY_CHK_TYPE') == '1'){
			                	return (record.MSGID != null && record.MSGID.trim() != '');
							} else if ($F('QRY_CHK_TYPE') == '2'){
								return (record.MSGID != null && record.MSGID.trim() != '');
							} else {
								return false;
							}
                        }                        
					},
					<%-- [20240729] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "受理編號/貸款帳號", key: "APPLY_ID",
							input:{
								type:'TEXT', size:13, maxlength:11, attrs :{disabled :true}, 
								action:function( inputNode , Records , TextElement , orgData , isOnChange ){
									if(isOnChange){
										inputNode.value = inputNode.value.toUpperCase();
									}
								},actionWhenStart:false,
								genRule:function(record, value){
									if ($F('QRY_CHK_TYPE') == '2' && (record.MSGID == null || record.MSGID.trim() == '')){
										return (record.PACK_DATE == null)? true:false; 
									} else {
										return false;
									}
								}
							}
						},
						{ header: "被查詢人ID", key: "BORROW_ID"},
						{ header: "被查詢人姓名", key: "BORROW_NAME", attrs:{style:"font-family:'EUDC'"}, 
							render:function(record,value,sn){
		                		if ($F('QRY_CHK_TYPE') == '2' && (record.MSGID == null || record.MSGID.trim() == '') && record.PACK_DATE == null){
									<%--[20240729] 難字調整 --%>
									var input = new Element('input',{type:'text',name:'BORROW_NAME',size:12,maxlength:20, alt:"ch" });
									input.setValue(value);
									input.observe('blur', function(){
										record.BORROW_NAME = this.value;
									});
									return input;
								}
								return value;
							}
						},
						{ header: "保證人種類", key: "GUAR_KIND_NM"},
						{ header: "業務別", key: "NEW_CODE_NM"},
						{ header: "查詢項目", key: "QUERY_ITEM_NM"},
						{ header: "查詢人員", key: "QUERY_NAME", attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
						{ header: "查詢日期", key: "QUERY_DATE"},
						{ header: "處理狀態", key: "APPLY_PROCESS_NM"},
						{ header: "處理時間", key: "QDATE"},
						{ header: "備註", key: "MEMO",
							input:{
								type:'TEXT', size:20, maxlength:60,
								genRule:function(record, value){
									if ($F('QRY_CHK_TYPE') == '2' && (record.MSGID == null || record.MSGID.trim() == '')){
										return (record.PACK_DATE == null)? true:false;
									} else {
										return false;
									}
								}
							},
							render:function(record, value){
								if ($F('QRY_CHK_TYPE') == '1'){
				                	return '';
								} else {
									return value;
								}
							}
						},
						<%-- [20211230] 申請書211118003371-授審和資管流程與系統調整：增加顯示二次套印狀態 --%>
						{ header: "公務機關查調<br>授權書", key: "A193_SECOND_PRINT_NM"},
						<%-- [20210205] 聯徵公務機關資料查調作業--%>
						{ header: "是否一併發查<br>聯徵公務機關", key: "AGREE_JCIC",
							render: function(rec, val, sn){
								rec.sn = sn;
								if('Y'==rec.AGREE_JCIC){
									var div = new Element('div');
									var label = new Element('label');
									var radio =  new Element('input', {'type' : 'radio','name' : rec.sn +'IS_JCIC', 'value' : 'Y'});
									radio.checked= true;
									label.insert(radio);
									var radio2 = new Element('input', {'type' : 'radio','name' : rec.sn +'IS_JCIC', 'value' : 'N'});									
									label.insert('是 &nbsp;');									
									div.insert(label);
									var link = new Element('a').update(rec.AV_FILE_NAME);
									//var link = new Element('a', { href:'javascript:void(0);'}).update(rec.AV_FILE_NAME);
									//link.observe('click', function(){
										//linkDSA2_0431(rec.APPLY_ID);
									//});
									
									div.insert(link);
									var label2 = new Element('label');
									label2.insert(radio2);									
									label2.insert('否');
									div.insert(label2);
									
									return div;
									
								}else{
									return '';
								}					
													
							}
						}
					]
				}
			);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------	
//取得企業負責人ID Function 與 轉大寫
//--------------------------------------------------------------------------
function doGetCOUPLE_ID(){
	var APPLY_ID = $F('APPLY_ID_B');
	$("APPLY_ID_B").setValue(APPLY_ID.toUpperCase());<%--[20240126]新增輸入時轉成大寫字母--%>
	<%--[20231225] 判斷如果是J21企業信用評分-含負責人--%>
	if(APPLY_ID != '' && '7' == $F('ITEM_B')) {
		new Ajax.Request("<%=dispatcher%>/DSA2_0400/getCOUPLE_ID",
		{
			parameters:	{
				'APPLY_ID' : $F('APPLY_ID_B') 
			},
			onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){		
					$('COUPLE_ID_B').setValue(resp.COUPLE_ID);
				}
			}
		});
	}
}

//--------------------------------------------------------------------------	
//	查詢承辦人員下拉選單Function
//--------------------------------------------------------------------------
function doQueryCredIdList(){

	if ($F('CRED_DEPT') == ''){
		var selectionName = $('CRED_ID');
		selectionName.length = 0;
		
		var	option = document.createElement('option');
		option.innerText = "全部";
		option.value = "";
	 	selectionName.appendChild(option);
	 	
	 	return;
	}

	
	new Ajax.Request("<%=dispatcher%>/DSA2_0400/queryCredIdList", 
		{
			parameters:{CRED_DEPT:$F('CRED_DEPT')},
			onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					// 載入承辦人員下拉選單
					loadCredIdList(resp['CRED_ID_LIST']);
				}else{
					loadCredIdList([]);
				}
			}			 	
		});	
}

//--------------------------------------------------------------------------	
//	載入承辦人員下拉選單Function
//--------------------------------------------------------------------------
function loadCredIdList(objList){
	var selectionName = $('CRED_ID');
	selectionName.length = 0;
	
	var	option = document.createElement('option');
	option.innerText = "全部";
	option.value = "";
 	selectionName.appendChild(option);
	
	objList.each(
		function(vo) {
 			option = document.createElement('option');
 			option.innerText = vo.NAME;
 			option.value = vo.ID;
 			selectionName.appendChild(option);
		}
	);
}
	
//--------------------------------------------------------------------------	
//	查詢Function
//--------------------------------------------------------------------------
function doQuery(){
	
	$('BORROW_ID_B').value = $F('BORROW_ID_B').toUpperCase();
	$('BORROW_ID_C').value = $F('BORROW_ID_C').toUpperCase();
	
	var CHK_TYPE = document.getElementsByName('CHK_TYPE');

	for (var i=0;i<CHK_TYPE.length;i++){
		if (CHK_TYPE[i].checked){
			$('QRY_CHK_TYPE').value = CHK_TYPE[i].value;
			break;
		}
	}

	checkInput('Query'); //查詢條件檢核
	if(!valid.validate()){
		return;
	}

	$('QUERY_ITEM_B').value = $F('ITEM_B'); 
	
  	new Ajax.Request("<%=dispatcher%>/DSA2_0400/query", 
		{
			parameters:Form.serialize("form1"),
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					grid.load(resp.rtnList);
					
					if ($F('QRY_CHK_TYPE') == '3'){
						$('btn_delete').disabled = false;
						buttonAuth();
					}else{
						$('btn_delete').disabled = true;
					}
					
					//自動選取第一筆後, 觸發onchange事件
/*
					var lastKey;
					$('grid').select('SELECT[key=QUERY_ITEM_NM]').each(
						function(key){
							lastKey = key;
						}
					)
					
					$(lastKey).selectedIndex = 0;
					$(lastKey).onchange();
*/
				}else{
					if(resp.DNFE){
						grid.load([]);
						
						if ($F('QRY_CHK_TYPE') == '3'){
							$('btn_delete').disabled = false;
							buttonAuth();
						}else{
							$('btn_delete').disabled = true;
						}
					}						
				}
			}
		});
}

//--------------------------------------------------------------------------	
//	刪除 Function
//--------------------------------------------------------------------------
function doDelete(){
	
	var selectedList = grid.getCheckedRecord();	
	if(selectedList.length == 0){
		alert('請選取一筆資料');
		return;
	}
	
  	new Ajax.Request("<%=dispatcher%>/DSA2_0400/delete", 
	{
		parameters:	{ 
						'jsonData' : Object.toJSON(selectedList), 
						'info' : Object.toJSON( $("form1").serialize( true )) 
					},
	 	onSuccess:function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				grid.load(resp.rtnList);
			}else{
				if(resp.DNFE){
					grid.load([]);
				}						
			}
		}
	});

}

//--------------------------------------------------------------------------	
//	送出 Function
//--------------------------------------------------------------------------
function doSubmit(){

	var selectedList = grid.getCheckedRecord();
	
	if(selectedList.length == 0){
		alert('請選取一筆資料');
		return;
	} else if (selectedList.length > 5){
		alert('聯徵送出筆數不得超過五筆');
		return;
	}
	
	if ($F('QRY_CHK_TYPE') == '1'||$F('QRY_CHK_TYPE') == '3'){
	    //2019/05/28 陳詩婷 取得放款保證人種類
		// 檢核保證人種類不得為空
		var chkMsg = '';
		var isType0 = false;//借款人
		var isType1 = false;//保證人
		var isGuarKind1 = false;//一般保證人
		var isGuarKind2 = false;//連帶
		var isGuarKind3 = false;//物保
		var tmpQUERY_ITEM = '';//查詢項目(暫存)
		for(var i = 0; i < selectedList.length; i++){
			var record = selectedList[i];
			if (record.TYPE == '1'){
				isType1 = true;
				if (record.GUAR_KIND != '1' && record.GUAR_KIND != '2' && record.GUAR_KIND != '3'){
					chkMsg += '受理編號'+record.APPLY_ID+'(保證人'+record.BORROW_NAME+')，請先輸入保證人種類 \n';
				}
				if(record.GUAR_KIND == '1'){
					isGuarKind1 = true;
				}
				if(record.GUAR_KIND == '2'){
					isGuarKind2 = true;
				}
				if(record.GUAR_KIND == '3'){
					isGuarKind3 = true;
				}
			}
			if (record.TYPE == '0'){
				isType0 = true;
			}
			
			//[20200611]申請書-200520002109：新增法金組合：(08)組合查詢006、(09)組合查詢601
			//不可同時發送自然人及法人
			if(i==0){
				tmpQUERY_ITEM = record['QUERY_ITEM'];
			}else{
				if(tmpQUERY_ITEM!=record['QUERY_ITEM']){
					alert("不可同時發送不同查詢項目，請重新選取!");
					return;
				}
			}
			<%-- [20210205] 聯徵公務機關資料查調作業--%>
			if('Y'==record.AGREE_JCIC){
				if('N' == $$('input[name=' +record.sn +'IS_JCIC'+']:checked')[0].getValue()){
					record.AGREE_JCIC = 'N';
				}
				record.APPLY_FORM = 'DSA20400';//申請來源
				record.FILE_FROM = '2';//檔案來源:1(自行上傳)/2(AV影像系統選取)
			}

		}
		//2019/05/28 陳詩婷 取得放款保證人種類
		if (chkMsg != ''){
			alert(chkMsg);
			return;
		}
		
		if ((isType0 && isGuarKind3) || (isGuarKind3 && (isGuarKind1 || isGuarKind2))){
			alert("擔保物提供人不得與借款人、一般或連帶保證人同時選取進行聯徵查詢送出，請重新選取!");
			return;
		}
	}

	if ($F('QRY_CHK_TYPE') == '2'){
		//2019/05/28 陳詩婷 取得放款保證人種類
		// 檢核保證人種類不得為空
		var chkMsg = '';
		var isType0 = false;//借款人
		var isType1 = false;//保證人
		var isGuarKind1 = false;//一般保證人
		var isGuarKind2 = false;//連帶
		var isGuarKind3 = false;//物保
		// 檢核輸入資料不得為空
		for(var i = 0; i < selectedList.length; i++){
			var record = selectedList[i];
			if (!record.APPLY_ID || record.APPLY_ID == '' || !record.BORROW_NAME || record.BORROW_NAME == '' || record.QUERY_ITEM_NM == ''){
				alert('請輸入完整待送出資料');
				return;
			} else if (record.APPLY_ID.length != 10 && record.APPLY_ID.length != 11){
				alert('請輸入正確的受理編號');
				return;
			}
			//2019/05/28 陳詩婷 取得放款保證人種類
			if (record.TYPE == '1'){
				isType1 = true;
				if (record.GUAR_KIND != '1' && record.GUAR_KIND != '2' && record.GUAR_KIND != '3'){
					chkMsg += '受理編號'+record.APPLY_ID+'(保證人'+record.BORROW_NAME+')，請先輸入保證人種類 \n';
				}
				if(record.GUAR_KIND == '1'){
					isGuarKind1 = true;
				}
				if(record.GUAR_KIND == '2'){
					isGuarKind2 = true;
				}
				if(record.GUAR_KIND == '3'){
					isGuarKind3 = true;
				}
			}
			if (record.TYPE == '0'){
				isType0 = true;
			}
			<%-- [20210205] 聯徵公務機關資料查調作業--%>		
			if('Y'==record.AGREE_JCIC){
				if('N' == $$('input[name=' +record.sn +'IS_JCIC'+']:checked')[0].getValue()){
					record.AGREE_JCIC = 'N';
				}
				record.APPLY_FORM = 'DSA20400';
				record.FILE_FROM = '2';//檔案來源:1(自行上傳)/2(AV影像系統選取)
			}
			
		}
		//2019/05/28 陳詩婷 取得放款保證人種類
		if($('QUERY_ITEM_B').value=='1'){
			if (chkMsg != ''){
				alert(chkMsg);
				return;
			}
			
			if ((isType0 && isGuarKind3) || (isGuarKind3 && (isGuarKind1 || isGuarKind2))){
				alert("擔保物提供人不得與借款人、一般或連帶保證人同時選取進行聯徵查詢送出，請重新選取!");
				return;
			}
		}
		
	}
	
	new Ajax.Request("<%=dispatcher%>/DSA2_0400/submit", 
	{
		parameters:	{
						'jsonData' : Object.toJSON(selectedList), 
						'info' : Object.toJSON( $("form1").serialize( true )) 
					},
	 	onSuccess:function(XHT, resp){

			if(CSRUtil.isSuccess(resp)){
			
				grid.load(resp.rtnList);
				
				// 超連結至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
				linkDSA22200(resp.listMap);
			}
		}
	});
	
}

//--------------------------------------------------------------------------	
//	超連結至 “DSA2_2200”(聯徵系統連結)畫面
//--------------------------------------------------------------------------
function linkDSA22200(listMap) {

	var url = "<%=dispatcher%>/DSA2_2200/prompt";
	$('LINK_FROM').value = "DSA20400";
	$('chkList').value = listMap;
		
	var form = document.form1;	
	form.action = url;		
	form.target='_blank';
	form.submit();
}

<%-- [20210205] 聯徵公務機關資料查調作業--%>
//--------------------------------------------------------------------------	
//顯示超連結DSA2_0431
//--------------------------------------------------------------------------

function linkDSA2_0431(rec_APPLY_ID) {
	popupWin.popup({
		src: '${dispatcher}/DSA2_0431/prompt',scrolling : 'yes',		
		parameters: { 
			APPLY_ID : rec_APPLY_ID			
		}
	});
	
}

//--------------------------------------------------------------------------	
//	檢核Function
//--------------------------------------------------------------------------
function checkInput(act) {
	valid.clear();
	valid.reset();

	if (act == 'Query'){
		if($F('QRY_CHK_TYPE') == '1'){	

			valid.define( "required" , { id : "PACK_DATES" , errMsg : "包裹日期起日不可為空"} );	
			valid.define( "required" , { id : "PACK_DATEE" , errMsg : "包裹日期迄日不可為空"} );	
			valid.define( "validate-ROCDate" , { id : "PACK_DATES" , errMsg : "包裹日期起日格式有誤"} );	
			valid.define( "validate-ROCDate" , { id : "PACK_DATEE" , errMsg : "包裹日期迄日格式有誤"} );	
			valid.define( "validate-ROCDate-Interval" , [{ id : "PACK_DATES" , errMsg : "包裹日期迄日需大於起日" },{ id : "PACK_DATEE" , errMsg : "包裹日期迄日需大於起日" }] );	
			
		} else if($F('QRY_CHK_TYPE') == '2'){

			valid.define( "required" , { id : "BORROW_ID_B" , errMsg : "被查詢人ID不可為空"} );	
			<%-- [20240111] 修改檢核方法，變為5-4. J20、21與其他四項特定查詢項目為查統編 其餘為原判斷 --%>
			var IDErrMsg;
			if('6'==$F('ITEM_B') || '7'==$F('ITEM_B') || '8'==$F('ITEM_B') || '9'==$F('ITEM_B')){
				IDErrMsg = "該查詢項目之被查詢人ID限以公司統編查詢";	
	        } else {
	        	IDErrMsg = "被查詢人ID 錯誤";	//法金也可以查詢法人
	        }
			valid.define( "checkROCIDorID" , { id: "BORROW_ID_B" , errMsg : IDErrMsg });	
			
			var APPLY_ID_B = $F('APPLY_ID_B');
			<%--[20240111] 新增判斷2-4 --%>
			<%--[20240205] 變更檢核條件 若受編/貸款帳號或查詢項目有值時 進行申請書2-4判斷--%>
			if(APPLY_ID_B || $F('ITEM_B')) {
				valid.define( "required" , { id : "ITEM_B" , errMsg : "請選擇查詢項目"} );
				valid.define( "required" , { id : "APPLY_ID_B" , errMsg : "請輸入受理編號/貸款帳號"} );
				if(APPLY_ID_B) {
					valid.define( "checkAPPLY_ID" , { id : "APPLY_ID_B" , errMsg : "受理編號/貸款帳號只限輸入英數字"});
				}
			}
			
	        //[20200611]申請書-200520002109：新增法金組合：(08)組合查詢006、(09)組合查詢601
	        // 被查詢人id為公司統編時 不能查006 若為身分證字號 不能查601
	        if('4'==$F('ITEM_B')){
	        	valid.define( "checkROCID" , { id : "BORROW_ID_B" , errMsg : "被查詢人非自然人，不可查詢組合006"} );
	        }else if('5'==$F('ITEM_B')){
	        	valid.define( "checkUniSN" , { id : "BORROW_ID_B" , errMsg : "被查詢人非法人，不可查詢組合601"} );
	        }else if('7'==$F('ITEM_B')){ <%--[20240111] 新增判斷 2-3 --%>
	        	valid.define( "checkCOUPLE_ID" , { id : "COUPLE_ID_B" , errMsg : "企業負責人ID只限輸入英數字並需為10碼"});
	        }
		} else if($F('QRY_CHK_TYPE') == '3'){
			valid.define( "required" , { id : "BORROW_ID_C" , errMsg : "被查詢人ID不可為空"} );	
			valid.define( "checkROCIDorID" , { id : "BORROW_ID_C" , errMsg : "被查詢人ID 錯誤"} );	//法金也可以查詢法人
		}
	}
}

function initValidation(){
	Validation.addAllThese([
		[ 'checkROCIDorID',  '身份證字號格式錯誤',
			function(v){  
				return Validation.get('IsEmpty').test(v) || validation.checkROCID( v )|| validation.checkUniSN( v );
			}
		],
		<%-- [20240111] 新增規則(2-4) --%>
		['checkAPPLY_ID', '受理編號有誤，請檢查後重新輸入!', 
			function(v) {
				<%--貸款帳號至多11碼英數字--%>
				return v.length <= 11 && (/^[a-zA-Z0-9]+$/.test(v));  
			}
		],
		<%-- [20240111] 新增規則(2-3、5-5) --%>
		['checkCOUPLE_ID', '企業負責人ID格式有誤', 
			function(v) {
				<%--企業負責人ID至多10碼英數字--%>
				return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v));  
			}
		]
	]);
}

function diffDaysROC(strRoc1,strRoc2)
{
	var intRoc1=0;
	var intRoc2=0;
	var int11=0;
	var int12=0;
	var int21=0;
	var int22=0;
	int11=(strRoc1.length>6 ? 3:2);
	int12=(strRoc1.length>6 ? 5:4);
	strRoc1 = (parseInt(strRoc1.substr(0,int11))+1911) + "/" + strRoc1.substr(int11,2) + "/" + strRoc1.substr(int12,2);
	int21=(strRoc2.length>6 ? 3:2);
	int22=(strRoc2.length>6 ? 5:4);
	strRoc2 = (parseInt(strRoc2.substr(0,int21))+1911) + "/" + strRoc2.substr(int21,2) + "/" + strRoc2.substr(int22,2);
	intRoc1=Date.parse(strRoc1);
	intRoc2=Date.parse(strRoc2);
	return ((intRoc2-intRoc1)/86400000);
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

<form name="form1" id="form1" method="post">
	<input name="LP_JSON" id="LP_JSON" type="hidden" value="">
	<input type="hidden" name="QRY_CHK_TYPE" id="QRY_CHK_TYPE" value="1">
	<input type="hidden" name="QUERY_ITEM_B" id="QUERY_ITEM_B" value="1">
	<input type="hidden" name="LINK_FROM" id="LINK_FROM" value="">
	<input type="hidden" name="chkList" id="chkList" value="">
	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
		<!-- Block_4_Start 輸入區塊-->
		<tr>
			<td class="tbYellow" rowspan="4" width="10%">查詢方式</td>
			<td class="tbYellow" rowspan="2" width="5%">
				<input type="radio" name="CHK_TYPE" id="CHK_TYPE" value="1" checked>
			</td>
			<td class="tbYellow" width="10%">承辦科別</td>
			<td class="tbYellow2" width="15%">
				<select class="textBox2" name="CRED_DEPT" id="CRED_DEPT">
                           <c:forEach var="item" items="${CRED_DEPT_List}">
                             <option value="${item.key}">${item.value}</option>
                           </c:forEach>
                         </select>
			</td>
			<td class="tbYellow" width="10%">承辦人員</td>
			<td class="tbYellow2" width="15%">
				<select class="textBox2" name="CRED_ID" id="CRED_ID" alt="ch"> <%-- [20240729]難字調整 --%>
					<option value="">全部</option>
                           <c:forEach var="item" items="${CRED_ID_List}">
                             <option value="${item.ID}">${item.NAME}</option>
                           </c:forEach>
                         </select>
			</td>
			<td class="tbYellow" width="10%">包裹日期</td>
			<td class="tbYellow2" width="20%">
				<input type="text" datatype="ROCDate" value="${SYS_DATE}" class="textBox2" size="10" maxlength="7" name="PACK_DATES" id="PACK_DATES" />
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('PACK_DATES'))">
				~
				<input type="text" datatype="ROCDate" value="${SYS_DATE}" class="textBox2" size="10" maxlength="7" name="PACK_DATEE" id="PACK_DATEE" />
				<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('PACK_DATEE'))">
			</td>
			<td class="tbYellow2" rowspan="4" align="center" width="5%">
				<input type="button" id="btn_query" value="查詢" class="button">
			</td>
		</tr>
		<tr>		
			<td class="tbYellow">查詢項目</td>
			<td class="tbYellow2" colspan="5">
				<select class="textBox2" name="ITEM_A" id="ITEM_A">
                           <c:forEach var="item" items="${ITEM_List1}">
                             <option value="${item.key}">${item.value}</option>
                           </c:forEach>
                         </select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">
				<input type="radio" name="CHK_TYPE" id="CHK_TYPE" value="2">
			</td>
			<td class="tbYellow">被查詢人ID</td>
			<td class="tbYellow2">
				<input type="text" class="textBox" id="BORROW_ID_B" name="BORROW_ID_B" size="15" maxlength="10">
			</td>
			<%--[20240111] 新增受理編號/貸款帳號欄位 --%>
			<td class="tbYellow">受理編號/貸款帳號</td>
			<td class="tbYellow2">
				<input type="text" class="textBox" id="APPLY_ID_B" name="APPLY_ID_B" size="15" maxlength="11">
			</td>
			<td class="tbYellow">查詢項目</td>
			<td class="tbYellow2">
				<select class="textBox2" name="ITEM_B" id="ITEM_B">
				  	<option value="">請選擇</option>
                   	<c:forEach var="item" items="${ITEM_List2}">
                    	<option value="${item.key}">${item.value}</option>
                    </c:forEach>
                </select>
                <span class="textRedBold" id="ITEM_B_MEMO"></span>
                <%--[20240111] 新增企業負責人ID欄位 --%>
                <input type="text" class="textBox" id="COUPLE_ID_B" name="COUPLE_ID_B" placeholder="輸入企業負責人ID"  maxlength="10" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow"><!-- TODO -->
				<input type="radio" name="CHK_TYPE" id="CHK_TYPE" value="3" <c:if test="${isRLDS203 eq false}">disabled</c:if>>
			</td>
			<td class="tbYellow">被查詢人ID</td>
			<td class="tbYellow2" colspan="5">
				<input type="text" class="textBox" id="BORROW_ID_C" name="BORROW_ID_C" size="15" maxlength="10" <c:if test="${isRLDS203 eq false}">disabled</c:if>>
			</td>
		</tr>
		<tr>
			<td colspan="9">
				<input type="button" id="btn_delete" value="刪除" class="button">
				<input type="button" id="btn_submit" value="送出" class="button">
			</td>
		</tr>
		<!-- Block_4_End 輸入區塊-->
	</table>
	<table id='grid' class="grid"></table>
</form>
		
</body>
</html>
