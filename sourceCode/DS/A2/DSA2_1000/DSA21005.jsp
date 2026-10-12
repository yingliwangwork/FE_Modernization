<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!-- 
[20240729] 修改件 陳勁谷 難字修改
 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'scroll', fix);

var validator;

var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)

var optionList2;

//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0050:'btn_insert',<%--退件輸入--%>
		B0051:'btn_confirm',<%--退件呈核--%>
		B0085:'btn_cancel',<%--取消呈核--%>
		B0084:'btn_delete'<%--退件取消--%>
	};
	<dz:grantButtons FUNC_ID="DSA21005" ignored="false"/>
}

function initApp(){
	PageUI.createPageWithAllBodySubElement("DSA21005" , "核貸作業" , "退件簽件作業 ",1,'${titleNotDisplay}' == 'Y');
	buttonAuth();
	validator = new Validator();

	new UI().init();

	if($F("REJ_ITEM")){
		createList2();
	}

	$("REJ_ITEM").setValue('${REJ_DATA.REJ_ITEM}');
	$("REJ_REASON").setValue('${REJ_DATA.REJ_REASON}');

	if($('AGREE_HISTORY').innerHTML != ''){
		$('div_I').style.display = 'block';
	} else {
		$('div_I').style.display = 'none';
	}
	<%--[20240729] 修改件 陳勁谷 難字修改--%>
	parseEUDC();
}

var item1 = [10,11,12];
var item2 = [21,22,23,24,25];
var item3 = [33,34,41,42,43,44,51,52];
var item4 = [61,71,82,83,84,87,91,92,93,94,95];

function createList2(){

	$('REJECT_RATE1').removeClassName("required");
	$('REJECT_RATE1').title= "";

	var rej_item = $F("REJ_ITEM");
	var item=[];
	if(rej_item == '1'){
		item = item1;
	}
	else if(rej_item == '2'){
		item = item2;
		$('REJECT_RATE1').addClassName("required");
		$('REJECT_RATE1').title= "請輸入擬承做放款率!";
	}
	else if(rej_item == '3'){
		item = item3;
	}
	else if(rej_item == '4'){
		item = item4;
	}

	var options = [];
	
	optionList2 = '${REJ_REASON}'.evalJSON();
	
	for(var i = 0; i < optionList2.length; i++){		
		for(var j=0;j<item.length;j++){							
			if(item[j] == optionList2[i].key ){
				options.push(optionList2[i]);
				break;
			}
		}								
	}
	
	var size = $("REJ_REASON").length;
	
	for(var i = 1; i < size; i++){
		$("REJ_REASON").remove(1);				
	}
	
	for(var i=0;i<options.length;i++){
		var new_opt = new Option(options[i].value,options[i].key);
		$('REJ_REASON').add(new_opt);
	}
}

function checkInput(msg){
	

	if(parent.form1){
		var APPLY_ID = parent.form1.APPLY_ID.value;
	
		if(APPLY_ID==''){
			alert(msg);
			return false;
		}
		if($F('REJ_ITEM')==""){
		    alert('請選擇，退件大項！！');
		    return false;
		}
		if($F('REJ_REASON')==""){
		    alert('請選擇，退件細項！！');
		    return false;
		}
		
		
		if(APPLY_ID != $F('APPLY_ID')){
		 	alert('欲異動的受理編號:'+APPLY_ID+'與原先查詢的'+$F('APPLY_ID')+'不同，請重新查詢!');
		 	return false;
		}
	}
	
	valid1.reset();
		
	if( !valid1.validate() ) {
		return false;
	}
	
	
	return true;
}


function checkInput2(msg){
	

	if(parent.form1){
		var APPLY_ID = parent.form1.APPLY_ID.value;
	
		if(APPLY_ID==''){
			alert(msg);
			return false;
		}
		
		if(APPLY_ID != $F('APPLY_ID')){
		 	alert('欲異動的受理編號:'+APPLY_ID+'與原先查詢的'+$F('APPLY_ID')+'不同，請重新查詢!');
		 	return false;
		}
	}	
	
	return true;
}

var valid1;

function UI(){
	return {
		init:function() {
			displayMessage();


			// 當承辦科別改變時
			$("REJ_ITEM").observe('change',function(event){								
				createList2();				
			});
			
			
			$("btn_insert").observe('click',function(event){
				doTrimTextArea ('REJ_NOTE');
				buttons.doInsert();										
			});
			
			$("btn_confirm").observe('click',function(event){
				doTrimTextArea ('REJ_NOTE');
				buttons.doConfirm();										
			});
			
			$("btn_cancel").observe('click',function(event){
				buttons.doCancel();										
			});
			
			$("btn_delete").observe('click',function(event){
				buttons.doDelete();										
			});
			
			//不動產明細
			$("btn_DSA21006").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1006');
			});
			
			//批覆書
			$("btn_DSA21007").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1007');
			});	

			//鑑估表
			$("btn_DSA21008").observe('click',function(event){
				buttons.doLinkToPDF('DSA2_1008');
			});	

			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				[ 'required2',  '請輸入!', 
					function(){ 
						if($F('REJ_NOTE').trim() ==''){ 
							return false; 
						}
						return true; 
					} ],
				[ 'chkTextArea1',  '字數限制1000字大小', function(v){
							return validation.checkInputLength(v, 1000, null, null);
						 } ]	
				] 				
			);	

		}
	};
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doInsert:function(){
		var msg = '請先查詢，再進行退件輸入!';
		if(!checkInput(msg)){
				return;
		}
		
			
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}',
			REJ_ITEM: $F('REJ_ITEM'),
			REJ_REASON: $F('REJ_REASON'),
			SEND_CHECK: $('SEND_CHECK').checked ? '1':'0',
			REJECT_RATE1: $F('REJECT_RATE1'),
			REJECT_RATE2: $F('REJECT_RATE2'),
			REJ_NOTE: $F('REJ_NOTE').trim()
		};

		var actionName = "insert"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params);
	},
	doConfirm:function(){
		var msg = '請先查詢，再進行取消呈核!';
		if(!checkInput(msg)){
				return;
		}		
						
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}',
			REJ_ITEM: $F('REJ_ITEM'),
			REJ_REASON: $F('REJ_REASON'),
			SEND_CHECK: $('SEND_CHECK').checked? '1':'0',
			REJECT_RATE1: $F('REJECT_RATE1'),
			REJECT_RATE2: $F('REJECT_RATE2'),
			REJ_NOTE: $F('REJ_NOTE').trim(),
			IS_REJ: $F('IS_REJ'),
			//20191114 申請書190911001639:不當招攬,查詢受理日前三個月內是否有投保新契約
			//20190424 申請書200407001711 徵信報告書加強審查作業：調整為送件日前三個月
			BORROW_ID: '${A010_VO.BORROW_ID}', 
			SEND_DATE: '${A010_VO.SEND_DATE}' 
		};
		var actionName = "confirm"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params, 
			function(resp){				
				$('PROCESS_NM').innerHTML = resp.REJ_PROCESS_NM;
				$('REJ_NOTE').readOnly = true;	
			}
		);
	},
	doCancel:function(){
		var msg = '請先查詢，再進行退件取消!';
		if(!checkInput(msg)){
				return;
		}		
						
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}'
		};
		var actionName = "cancel"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params, 
			function(){
				$('PROCESS_NM').innerHTML = '';	
				$('REJ_NOTE').readOnly = false;
			}
		);
	},
	doDelete:function(){
		var msg = '請先查詢，再進行退件取消!';
		if(!checkInput(msg)){
				return;
		}		
		
		if(!confirm("退件取消將會刪除退件資料，請確認是否繼續？")){
			return;
		}
						
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}'
		};
		var actionName = "delete"; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params, 
			function(){
				$('PROCESS_NM').innerHTML = '';	
				$('REJ_NOTE').readOnly = false;
			}
		);
	},
	doAction:function(action,msg){		
		if(!checkInput2(msg)){
				return;
		}		
						
		var queryData = {
			APPLY_ID: '${A010_VO.APPLY_ID}'
		};
		var actionName = action; 
		var params = {"queryData":Object.toJSON(queryData)};
		ajaxPost(actionName, params);
	},
	
	//導頁至DSA21006,DSA21007
	doLinkToPDF:function(target){
		var url = "<%=dispatcher%>/"+target+"/prompt?APPLY_ID="+$F('APPLY_ID');
		window.open(url,target, "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
	}
};

//檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim
function doTrimTextArea (val){
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
	if($F(val).length>0){
		$(val).setValue($F(val).replace(/'/gi, "").replace(/"/gi, ""));
		while(true){
			ln0 = $F(val).length;
			while(true){
				ln1 = $F(val).length;
				if($F(val).indexOf('\r\n')>=0){
					//trim掉最後一個\r\n
					$(val).setValue($F(val).replace(/\r\n$/g, ""));
					if(ln1 == $F(val).length){
						break;	
					}
				}else{
					break;
				}
			}
			while(true){
				ln2 = $F(val).length;
				if($F(val).indexOf(' ')>=0){
					$(val).setValue($F(val).replace(/ $/g, ""));
					if(ln2 == $F(val).length){
						break;	
					}
				}else{
					break;
				}
			}

			if(ln0 == $F(val).length){
				break;	
			}
		}
	}
	//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
}

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSA2_1005/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
					successAction(resp);
				}	
			}
        }}
	);
}

//批示歷程超連結(顯示/隱藏div)
function doShowHistory(){
	if($('div_I').style.display != 'none'){
		$('div_I').style.display = 'none';
	}else{
		$('div_I').style.display = 'block';
	}
}


//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<form name="form1" id="form1" method="post" action="">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<input type='hidden' id='APPLY_ID' value='${A010_VO.APPLY_ID}'>
				<input type='hidden' id='IS_REJ' name='IS_REJ' value='${REJ_DATA.IS_REJ}'>
				<tr>
					<td class="tbYellow" width="15%">
						受理編號
					</td>
					<td class="tbYellow2" width="29%">
						${A010_VO.APPLY_ID}    <font color="red">${IS_FAST}</font>
					</td>
					<td class="tbYellow" width="12%">
						借款人姓名
					</td>
					<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					<td class="tbYellow2" width="32%" id="BORROW_NAME" style="font-family:'EUDC'">
						${A010_VO.BORROW_NAME}
					</td>
					
				</tr>
				<tr>
					<td class="tbYellow" width="15%">
						受理進度
					</td>
					<td class="tbYellow2" width="29%" id="APPLY_PROCESS_NM">
						${APPLY_PROCESS_NM}
					</td>
					<td class="tbYellow" width="12%">
						退件進度
					</td>
					<td class="tbYellow2" width="32%" id="PROCESS_NM">
						${REJ_PROCESS_NM}
					</td>
				</tr>
				<tr>
					<td class="tbYellow2" colspan="4" align="center" width="12%">
						<input id="btn_insert" name="btn_insert" type="button" class="button" value="退件輸入">
						<input id="btn_confirm" name="btn_confirm" type="button" class="button" value="退件呈核">
						<input id="btn_cancel" name="btn_cancel" type="button" class="button" value="取消呈核">	
						<input id="btn_delete" name="btn_delete" type="button" class="button" value="退件取消">	
						<input id="btn_DSA21007" type="button" class="button" value="批覆書">		
						<input id="btn_DSA21006" type="button" class="button" value="不動產明細">
                                                <input id="btn_DSA21008" type="button" class="button" value="鑑估表">													
					</td>
				</tr>																
				
			</table>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="15%">
						申請金額：
					</td>
					<td class="tbYellow2" width="29%" id="C_LOAN_AMT">
						${C_LOAN_AMT}
					</td>								
					
				</tr>
				<tr>
					<td class="tbYellow" width="15%">
						退件大項：
					</td>
					<td class="tbYellow2" width="29%">
						<select id="REJ_ITEM" name="REJ_ITEM" class="textBox2 validate-selection" <c:if test="${REJ_DATA.REJ_PROCESS >= 20 }">disabled</c:if> >
							<option value="" selected>請選擇</option>
                                        <c:forEach var="item" items="${REJ_ITEM_LIST}">
                                        	<option value="${item.key}" >${item.value}</option>
                                        </c:forEach>
						</select>
					</td>								
				</tr>
				<tr>
					<td class="tbYellow" width="15%">
						退件細項：
					</td>
					<td class="tbYellow2" width="29%">
						<select id="REJ_REASON" name="REJ_REASON" class="textBox2 validate-selection"  <c:if test="${REJ_DATA.REJ_PROCESS >= 20 }">disabled</c:if> >
							<option value="" selected>請選擇</option>
                                        <c:forEach var="item" items="${REJ_REASON_LIST}">
                                            <option value="${item.key}" >${item.value}</option>
                                        </c:forEach>
						</select>
					</td>								
				</tr>
				
				<tr>
					<td class="tbYellow" width="15%">
						是否要送件控管：
					</td>
					<td class="tbYellow2" width="29%">
						<input type='checkBox' name='SEND_CHECK' id='SEND_CHECK' value='1' <c:if test="${REJ_DATA.SEND_CHECK eq 1}">checked</c:if> <c:if test="${REJ_DATA.REJ_PROCESS >= 20}">disabled</c:if>>
					</td>								
				</tr>
				
				<tr>
					<td class="tbYellow" width="15%">
						擬承做放款率：
					</td>
					<td class="tbYellow2" width="29%">
						<input class="validate-number"  fieldName="擬承做放款率" type="text" size="3" name="REJECT_RATE1" id="REJECT_RATE1" value="<c:out value="${REJ_DATA.PREPARE_REJECT_RATE1}" />" <c:if test="${REJ_DATA.REJ_PROCESS >= 20}">readOnly</c:if>>% 、客戶要求放款率：
						<input class="validate-number"  fieldName="客戶要求放款率" type="text" size="3" name="REJECT_RATE2" id="REJECT_RATE2" value="<c:out value="${REJ_DATA.PREPARE_REJECT_RATE2}" />" <c:if test="${REJ_DATA.REJ_PROCESS >= 20}">readOnly</c:if>>%
					</td>								
				</tr>
				
				
				
				<tr>
					<td class="tbYellow" width="15%">
						退件人員：
					</td>
					<%--[20240729] 修改件 陳勁谷 難字修改 --%>
					<td class="tbYellow2" width="29%" id="REJ_NAME" style="font-family:'EUDC'">
						${REJ_DATA.REJ_NAME}
					</td>								
				</tr>
				
				<tr>
					<td class="tbYellow" width="15%">
						退件原因說明：
					</td>
					<td class="tbYellow2" width="29%">
						<textarea class="required2 chkTextArea1" fieldName="退件原因說明"  id="REJ_NOTE" name="REJ_NOTE" cols="80" rows="10" <c:if test="${REJ_DATA.REJ_PROCESS >= 20}">readOnly</c:if>>${REJ_DATA.REJ_NOTE}</textarea>
					</td>								
				</tr>
				
				<tr>
					<td class="tbYellow" width="15%">
						退件核定層級：
					</td>
					<td class="tbYellow2" width="29%" id="REJ_LEVEL">
						${REJ_DATA.REJ_LEVEL_NM}
					</td>								
				</tr>
				
				<tr>
					<td class="tbYellow" width="15%">
						主管意見：
					</td>
					<td class="tbYellow2" width="29%" id="REJ_COMMENT">${REJ_DATA.REJ_COMMENT}</td>								
				</tr>
				<tr>
					<td class="tbYellow" width="15%">
						<a href="#A_div_I" onClick="doShowHistory()" name="A_div_I">＊批示歷程</a>
					</td>
					<td class="tbYellow2" width="29%">
						<div id="div_I" style="overflow:auto; display:none;">
							<span id="AGREE_HISTORY">${AGREE_HISTORY}</span>
						</div>
					</td>	
				</tr>
			</table>
		</form>
</body>
</html>