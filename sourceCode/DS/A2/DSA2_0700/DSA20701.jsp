<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA20701.jsp
作者：i9300615
功能：買賣件查證事項作業
完成：2011/10/27
更新：
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<title></title>
<%--共用定義的css--%>
<style>
	.starColor {
		color: red;
	}
	.blueColor{
		color: blue;
	}
</style>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
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
<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var valid;

function initApp(){

	PageUI.createPage('DSA20701', '核貸作業' , '買賣件查證事項作業', '${titleNotDisplay}' == 'Y');

	PageUI.loadin(['form1','form2'] , 1);

	// 檢核物件
	valid  = new Validation('body',{useTitles:true} );
	Validation.addAllThese([
		[ 'customize_returnFalse', '請自訂訊息',
			function(obj){
				return false;
			}
		],
		[ 'validateAPPLY_ID',  '請輸入正確受理編號!', 
			function(){ 
				if($F('TRADE_DATA13_ID') && $F('TRADE_DATA13_ID').length != 11){ 
					return false; 
				} 
				$('TRADE_DATA13_ID').value = $F('TRADE_DATA13_ID').toUpperCase(); 
				return true; 
			} 
		] 
	]);

	new UI().init();

	displayMessage();

	PageUI.resize(true);
	
	fix();

}

function checkInput(){

	$$('#form2 input[type=radio]').each(
		function(ele){
			ele.removeClassName('required');
	});

	if($('TRADE_DATA1_0').checked == true){
		$('TRADE_DATA1_DESC').addClassName('required');
	}else{
		$('TRADE_DATA1_DESC').removeClassName('required');
	}

	if($('TRADE_DATA2_0').checked == true){
		$('TRADE_DATA2_DESC').addClassName('required');
	}else{
		$('TRADE_DATA2_DESC').removeClassName('required');
	}

	if($('TRADE_DATA3_1').checked == true){
		$('TRADE_DATA3_DESC_1').addClassName('required');
	}else{
		$('TRADE_DATA3_DESC_1').removeClassName('required');
	}

	if($('TRADE_DATA3_2').checked == true){
		$('TRADE_DATA3_DESC_2').addClassName('required');
	}else{
		$('TRADE_DATA3_DESC_2').removeClassName('required');
	}

	if($('TRADE_DATA4_0').checked == true){
		$('TRADE_DATA4_DESC').addClassName('required');
	}else{
		$('TRADE_DATA4_DESC').removeClassName('required');
	}

	if($('TRADE_DATA5_0').checked == true){
		$('TRADE_DATA5_DESC').addClassName('required');
	}else{
		$('TRADE_DATA5_DESC').removeClassName('required');
	}

	if($('TRADE_DATA6_0').checked == true){
		$('TRADE_DATA6_DESC').addClassName('required');
	}else{
		$('TRADE_DATA6_DESC').removeClassName('required');
	}

	if($('TRADE_DATA7_0').checked == true){
		$('TRADE_DATA7_DESC').addClassName('required');
	}else{
		$('TRADE_DATA7_DESC').removeClassName('required');
	}

	if($('TRADE_DATA8_0').checked == true){
		$('TRADE_DATA8_DESC').addClassName('required');
	}else{
		$('TRADE_DATA8_DESC').removeClassName('required');
	}

	if($('TRADE_DATA9_0').checked == true){
		$('TRADE_DATA9_DESC').addClassName('required');
	}else{
		$('TRADE_DATA9_DESC').removeClassName('required');
	}

	if($('TRADE_DATA10_0').checked == true){
		$('TRADE_DATA10_DESC').addClassName('required');
	}else{
		$('TRADE_DATA10_DESC').removeClassName('required');
	}

	if($('TRADE_DATA11_0').checked == true){
		$('TRADE_DATA11_DESC').addClassName('required');
	}else{
		$('TRADE_DATA11_DESC').removeClassName('required');
	}

	if($('TRADE_DATA12_0').checked == true){
		$('TRADE_DATA12_DESC').addClassName('required');
	}else{
		$('TRADE_DATA12_DESC').removeClassName('required');
	}

	if($('TRADE_DATA13_0').checked == true){
		$('TRADE_DATA13_DESC').addClassName('required');
	}else{
		$('TRADE_DATA13_DESC').removeClassName('required');
	}
	
	if($('TRADE_DATA13_0').checked || $('TRADE_DATA13_1').checked){
		$('TRADE_DATA13_ID').addClassName('required');
	}else{
		$('TRADE_DATA13_ID').removeClassName('required');
	}
        
        <%-- 欄位長度檢核--%>
	checkMaxLength();

	valid.reset();

	if( !valid.validate() ) {
		return false;
	}

	return true;
}

<%--
	設定錯誤訊息
--%>
function setFalseCheck(ID,errorMessage) {
	valid.define( "customize_returnFalse" , [{ 'id' :ID , 'errMsg' : errorMessage}] , { 'useTitle': false });
}

<%--
	檢核值的長度
--%>
function setLengthCheck(chineseName,ID,maxLength) {
	var value = null;
        
        value = $(ID).value;

	if(!validation.checkInputLength(value, maxLength)){
		valid.define( "customize_returnFalse" , [{ id :ID , errMsg : chineseName + "長度超過" + maxLength + " (全形字為2)"}] , { useTitle: false });
		result = false;
	}
}

<%-- 長度檢核 --%>
function checkMaxLength() {
	
	setLengthCheck('查證事項1','TRADE_DATA1_DESC',60);
        setLengthCheck('查證事項2','TRADE_DATA2_DESC',60);
        setLengthCheck('查證事項3','TRADE_DATA3_DESC_1',60);
        setLengthCheck('查證事項3','TRADE_DATA3_DESC_2',60);
        setLengthCheck('查證事項4','TRADE_DATA4_DESC',60);
        setLengthCheck('查證事項5','TRADE_DATA5_DESC',60);
        setLengthCheck('查證事項6','TRADE_DATA6_DESC',60);
        setLengthCheck('查證事項7','TRADE_DATA7_DESC',60);
        setLengthCheck('查證事項8','TRADE_DATA8_DESC',60);
        setLengthCheck('查證事項9','TRADE_DATA9_DESC',60);
        setLengthCheck('查證事項10','TRADE_DATA10_DESC',60);
        setLengthCheck('查證事項11','TRADE_DATA11_DESC',60);
        setLengthCheck('查證事項12','TRADE_DATA12_DESC',60);
        setLengthCheck('查證事項13','TRADE_DATA13_DESC',60);
        setLengthCheck('查證事項13受編','TRADE_DATA13_ID',11);
        setLengthCheck('其他照會說明','TRADE_DATA_DESC',100);
        
	
}

//---------------------------------按鈕功能---------------------------------
var doAction = {
	//查詢
	doQuery : function(){
                valid.clear();
		valid.reset();
		if( !Validation.test('required', $('APPLY_ID'), {useTitle:true}, {showAlert:true}) ) {return;}
		
		// 受理編號轉大寫
		$('APPLY_ID').value=$F('APPLY_ID').toUpperCase();
		
		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});

		new Ajax.Request( '<%=dispatcher%>/DSA2_0701/query',
		{
			parameters:  { 'APPLY_ID':$F('APPLY_ID')},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					doAction.load(resp);
				}else{
					doAction.doClear();
				}
			}
		});
	}
	,doInsert : function(){
                valid.clear();
		valid.reset();
		if( !checkInput() ) {return;}

		//受理編號轉大寫
		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		
		var formObj = $("form2").serialize( true );
			formObj.APPLY_ID=$F('APPLY_ID');
		
		new Ajax.Request( '<%=dispatcher%>/DSA2_0701/insert',
		{
			parameters: {"data":Object.toJSON(formObj)},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					doAction.load(resp);
				}
			}
		});
	}

	,doDelete : function(){
                valid.clear();
		valid.reset();
		if( $F('APPLY_ID') != $F('OLD_APPLY_ID')) {
			alert('欲異動的受理編號和原先查詢受理編號不同，請重新查詢!');
			return;
		}

		//受理編號轉大寫
		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		
		var formObj = $("form2").serialize( true );
			formObj.APPLY_ID=$F('OLD_APPLY_ID');
		
		new Ajax.Request( '<%=dispatcher%>/DSA2_0701/delete',
		{
			parameters:  formObj ,
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					doAction.load(resp);
				}
			}
		});
	}
	,doUpdate : function(){
                valid.clear();
		valid.reset();
		if( $F('APPLY_ID') != $F('OLD_APPLY_ID')) {
			alert('欲異動的受理編號和原先查詢受理編號不同，請重新查詢!');
			return;
		}

		if( !checkInput() ) {return;}
		
		//受理編號轉大寫
		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		
		var formObj = $("form2").serialize( true );
		formObj.APPLY_ID=$F('OLD_APPLY_ID');
		
		new Ajax.Request( '<%=dispatcher%>/DSA2_0701/update',
		{
			parameters: {"data":Object.toJSON(formObj)},
			onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					doAction.load(resp);
				}
			}
		});
	}
	// 超連結－個人資料表影像
	//,doLinkTo0100:function(){
	//	if($F('OLD_APPLY_ID')){
	//		var form = document.form1;
        //	        var FILE_NAMEs =[{FILE_NAME:'借款人個人資料表'},{FILE_NAME:'保證人個人資料表'}];
	//		var url = "<%=dispatcher%>/DSA0_0100/prompt?APPLY_ID=" + $F('OLD_APPLY_ID') +"&FILE_NAME="+ Object.toJSON(FILE_NAMEs);
	//		var win = window.open(url, "DSA0_0100", "location=0, scrollbars=1, status=1, titlebar=1, resizable=1");
	//		win.moveTo(win.screen.availLeft , win.screen.availTop );
	//		win.resizeTo(win.screen.availWidth , win.screen.availHeight);
	//	}else{
	//		alert('請先查詢資料再作影像連結!');
	//	}
	//}
	// 超連結－經手人告知事項影像
	,doLinkTo0200:function(){
		if($F('APPLY_ID')){
			popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
				'parameters': {'APPLY_ID': $F('APPLY_ID')},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		}else{
			alert('請先查詢資料再作影像連結!');
		}			
	}
	// 連結到電子謄本系統
	,doLinkTo0700:function(){
		var form = document.form1;
		var url = "<%=dispatcher%>/DSA1_0700/prompt?";
		var win = window.open(url, "DSA2_0701", "location=0, scrollbars=1, status=1, titlebar=1, resizable=1");
		win.moveTo(win.screen.availLeft , win.screen.availTop );
		win.resizeTo(win.screen.availWidth , win.screen.availHeight);
	}
	// 連結到查擔保品行情
	,doLinkTo0900:function(){
		var form = document.form1;
		var url = "<%=dispatcher%>/DSA3_0900/prompt?";
		var win = window.open(url, "DSA2_0701", "location=0, scrollbars=1, status=1, titlebar=1, resizable=1");
		win.moveTo(win.screen.availLeft , win.screen.availTop );
		win.resizeTo(win.screen.availWidth , win.screen.availHeight);
	},
	// 清空畫面
	doClear:function(){
		$$('#form2 input').each(			
			function(obj){
				if(obj.getAttribute('type')=='text' && obj.id != "APPLY_ID"){
					obj.value = "";
				}
			}
		);
		
		$$('#form2 input').each(
			function(obj){
				if(obj.getAttribute('type')=='hidden'){
					obj.value = "";	
				}				
			}
		);		

		$$('#form2 span').each(
			function(obj){
				obj.innerHTML = "";
			}
		);

		$$('#form2 textarea').each(
			function(obj){
				obj.innerHTML = "";
			}
		);

		$$('#form2 input').each(
			function(obj){
				if(obj.getAttribute('type')=='radio'){
					obj.checked = false;
				}					
			}
		);
	}
	,load:function(resp){
		//將畫面清空
		doAction.doClear();
			
		var rtnMap = resp.rtnMap;
		if(rtnMap){
			JSONUtil.sampleJSON2Form2( 'form2', rtnMap );
			
			$$('#form2 input[name="TRADE_DATA3"]').each(
				function(obj){
					if(obj.value == "1"){
						if(obj.checked){
							$('TRADE_DATA3_DESC_1').value = rtnMap.TRADE_DATA3_DESC;
						}else{
							$('TRADE_DATA3_DESC_1').value = "";
						}
					}else if(obj.value == "2"){
						if(obj.checked){
							$('TRADE_DATA3_DESC_2').value = rtnMap.TRADE_DATA3_DESC;
						}else{
							$('TRADE_DATA3_DESC_2').value = "";
						}
					}
				}
			);
			$('OLD_APPLY_ID_SHOW').innerHTML = rtnMap.OLD_APPLY_ID;
			$('APPLY_PROCESS_NM').innerHTML = rtnMap.APPLY_PROCESS_NM;
			$('INPUT_NAME').innerHTML = rtnMap.INPUT_NAME;
			$('INPUT_DATE').innerHTML = rtnMap.INPUT_DATE;
		}
	}
};

function UI(){
	return{
		init:function(){

			//查詢
			$('btn_query').observe('click',function(event){
					doAction.doQuery();
				}
			);

			//個人資料表影像
			//$('btn_0100').observe('click',function(event){
			//		doAction.doLinkTo0100();
			//	}
			//);

			//經手人告知事項影像
			$('btn_0200').observe('click',function(event){
					doAction.doLinkTo0200();
				}
			);
            
			//有傳入受理編號則帶入欄位，若無則取保留參數管理的受理編號
			$('APPLY_ID').value = '${APPLY_ID}' || CSRUtil.keepParamsManager.get('APPLY_ID');
			if($('APPLY_ID').value){
				doAction.doQuery();
			}
			
			
		}
	}
}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

				
				<form id="form1" name="form1" method="post">
				<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
					<tr>
						<td class="tbYellow" width="15%">
							受理編號
						</td>
						<td class="tbYellow2" width="85%" colSpan="7">
							<input type="text" class="textBox2" title="您必須填入受理編號的資料!!" fieldName="受理編號" size="13" maxlength="11" name="APPLY_ID" id="APPLY_ID" value="${APPLY_ID}"/>
							<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">						
						</td>
					</tr>
					<tr>
						<td colSpan="8" align="center">													
							<input id="btn_0200" name="btn_0200" type="button" class="button" value="經手人告知事項影像">															
						</td>
					</tr>				
				</table>
				</form>
				<form id="form2" name="form2" method="post">
				<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">					
					<input type='hidden' name='APPLY_PROCESS' value='${rtnMap.APPLY_PROCESS}'>
					<input type='hidden' name='CRED_ID' value='${rtnMap.CRED_ID}'>
					<input type='hidden' name='BORROW_ID' value='${rtnMap.BORROW_ID}'>
					<input type='hidden' name='OLD_APPLY_ID_NM' value='${rtnMap.OLD_APPLY_ID}'>
					<tr>
						<td class="tbYellow"  width="10%">受理編號</td>
						<td class="tbYellow2" width="15%">
							<span id="OLD_APPLY_ID_SHOW">
								${rtnMap.OLD_APPLY_ID}
							</span>
						</td>
						<td class="tbYellow" width="10%">受理進度</td>
						<td class="tbYellow2" width="15%">
							<span id="APPLY_PROCESS_NM">
								${rtnMap.APPLY_PROCESS_NM}
							</span>
						</td>
						<td class="tbYellow"  width="10%">輸入人員</td>
						<td class="tbYellow2" width="15%">
							<span id="INPUT_NAME" style="font-family:'EUDC'"><%--[20240729]難字調整 --%>
								${rtnMap.INPUT_NAME}
							</span>
						</td>
						<td class="tbYellow" width="10%">輸入日期</td>
						<td class="tbYellow2" width="15%">
							<span id="INPUT_DATE">
								${rtnMap.INPUT_DATE}
							</span>
						</td>
					</tr>

					<tr>
						<td class="tbYellow"  rowspan="8" align="center">人</td>
						<td class="tbYellow2" colSpan="7">
							1.借款人職業收入、年齡與所購置擔保品金額不對稱<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA1_0' name='TRADE_DATA1' class="validate-one-required" value='0' <c:if test="${rtnMap.TRADE_DATA1 eq 0}">checked</c:if> >是，查證內容
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA1_DESC" name="TRADE_DATA1_DESC" title="請輸入查證內容!" value="<c:out value="${rtnMap.TRADE_DATA1_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA1_1' name='TRADE_DATA1' class="validate-one-required" title="買賣件查證事項皆需選擇!" value='1' <c:if test="${rtnMap.TRADE_DATA1 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							2.代書∕建商∕仲介等介紹件，加強介紹人與前後手間關係、買契真實性的查證<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA2_0' name='TRADE_DATA2' value='0' <c:if test="${rtnMap.TRADE_DATA2 eq 0}">checked</c:if> >異常，說明
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA2_DESC" name="TRADE_DATA2_DESC" title="請輸入說明內容!" value="<c:out value="${rtnMap.TRADE_DATA2_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA2_1' name='TRADE_DATA2' title="買賣件查證事項皆需選擇!" value='1' <c:if test="${rtnMap.TRADE_DATA2 eq 1}">checked</c:if> >無異常
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							3.借、保人與前手關係<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA3_0' name='TRADE_DATA3' value='0' <c:if test="${rtnMap.TRADE_DATA3 eq 0}">checked</c:if> >無關係
							<input type='radio' class="validate-one-required"  id='TRADE_DATA3_1' name='TRADE_DATA3' value='1' <c:if test="${rtnMap.TRADE_DATA3 eq 1}">checked</c:if> >有關係，關係為
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA3_DESC_1" name="TRADE_DATA3_DESC_1" title="請輸入關係內容!" <c:if test="${rtnMap.TRADE_DATA3 eq 1}"> value="<c:out value="${rtnMap.TRADE_DATA3_DESC}" />"</c:if> >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA3_2' name='TRADE_DATA3' value='2' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA3 eq 2}">checked</c:if> >戶藉已遷入擔保品，關係為
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA3_DESC_2" name="TRADE_DATA3_DESC_2" title="請輸入關係內容!" <c:if test="${rtnMap.TRADE_DATA3 eq 2}"> value="<c:out value="${rtnMap.TRADE_DATA3_DESC}" />"</c:if> >
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							4.借款人或保證人為建設公司員工、股東或承包商等<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA4_0' name='TRADE_DATA4' value='0' <c:if test="${rtnMap.TRADE_DATA4 eq 0}">checked</c:if> >是，為
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA4_DESC" name="TRADE_DATA4_DESC" title="請輸入內容!" value="<c:out value="${rtnMap.TRADE_DATA4_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA4_0' name='TRADE_DATA4' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA4 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							5.有不相干的人（如代書或借款親友）主動查詢貸款案件細節或催促案件甚急者<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA5_0' name='TRADE_DATA5' value='0' <c:if test="${rtnMap.TRADE_DATA5 eq 0}">checked</c:if> >是，來電者為
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA5_DESC" name="TRADE_DATA5_DESC" title="請輸入來電者!" value="<c:out value="${rtnMap.TRADE_DATA5_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA5_0' name='TRADE_DATA5' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA5 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							6.借、保人職業與聯徵報送資料有不一致情形<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA6_0' name='TRADE_DATA6' value='0' <c:if test="${rtnMap.TRADE_DATA6 eq 0}">checked</c:if> >是，查證內容
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA6_DESC" name="TRADE_DATA6_DESC" title="請輸入查證內容!" value="<c:out value="${rtnMap.TRADE_DATA6_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA6_0' name='TRADE_DATA6' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA6 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							7.近三個月他行有非ｚ類查詢記錄（新業務尤須注意）<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA7_0' name='TRADE_DATA7' value='0' <c:if test="${rtnMap.TRADE_DATA7 eq 0}">checked</c:if> >有，照會結果
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA7_DESC" name="TRADE_DATA7_DESC" title="請輸入照會結果!" value="<c:out value="${rtnMap.TRADE_DATA7_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA7_0' name='TRADE_DATA7' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA7 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							8.客戶主動檢附完整的收入及職業證明<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA8_0' name='TRADE_DATA8' value='0' <c:if test="${rtnMap.TRADE_DATA8 eq 0}">checked</c:if> >是，查證結果
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA8_DESC" name="TRADE_DATA8_DESC" title="請輸入查證結果!" value="<c:out value="${rtnMap.TRADE_DATA8_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA8_0' name='TRADE_DATA8' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA8 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow" rowspan="5" align="center">物</td>
						<td class="tbYellow2" colSpan="7">
							9.所購置房屋地點『無』地緣關係或合理性<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA9_0' name='TRADE_DATA9' value='0' <c:if test="${rtnMap.TRADE_DATA9 eq 0}">checked</c:if> >是，查證結果
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA9_DESC" name="TRADE_DATA9_DESC" title="請輸入查證結果!" value="<c:out value="${rtnMap.TRADE_DATA9_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA9_0' name='TRADE_DATA9' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA9 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							10.對所購房屋之買價、坪數、屋齡等不甚了解<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA10_0' name='TRADE_DATA10' value='0' <c:if test="${rtnMap.TRADE_DATA10 eq 0}">checked</c:if> >是，查證結果
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA10_DESC" name="TRADE_DATA10_DESC" title="請輸入查證結果!" value="<c:out value="${rtnMap.TRADE_DATA10_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA10_0' name='TRADE_DATA10' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA10 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							11.買價及鑑估價格差異過大<br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA11_0' name='TRADE_DATA11' value='0' <c:if test="${rtnMap.TRADE_DATA11 eq 0}">checked</c:if> >是，查證結果
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA11_DESC" name="TRADE_DATA11_DESC" title="請輸入查證結果!" value="<c:out value="${rtnMap.TRADE_DATA11_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA11_0' name='TRADE_DATA11' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA11 eq 1}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							12.前手取得時間在一年內或屋齡新，惟建物登記次序多筆（請調閱異動謄本）<a href="#" onClick="doAction.doLinkTo0700()">(連結到電子謄本系統)</a> <br/>
							<input type='radio' class="validate-one-required"  id='TRADE_DATA12_0' name='TRADE_DATA12' value='0' <c:if test="${rtnMap.TRADE_DATA12 eq 0}">checked</c:if> >異常說明
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA12_DESC" name="TRADE_DATA12_DESC" title="請輸入異常說明!" value="<c:out value="${rtnMap.TRADE_DATA12_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA12_0' name='TRADE_DATA12' value='1' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA12 eq 1}">checked</c:if> >無異常
						</td>
					</tr>

					<tr>
						<td class="tbYellow2" colSpan="7">
							13.擔保品曾有送件記錄（請進行擔保品行情查詢）<a href="#" onClick="doAction.doLinkTo0900()">(連結到查擔保品行情)</a> <br/>
							受編<input type="text" class="textBox2 validateAPPLY_ID"  maxlength="11" size="15" id="TRADE_DATA13_ID" name="TRADE_DATA13_ID" value="<c:out value="${rtnMap.TRADE_DATA13_ID}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA13_0' name='TRADE_DATA13' value='0' <c:if test="${rtnMap.TRADE_DATA13 eq 0}">checked</c:if> >異常說明
							<input type="text" class="textBox2"  size="30" maxlength="60" id="TRADE_DATA13_DESC" name="TRADE_DATA13_DESC" title="請輸入異常說明!" value="<c:out value="${rtnMap.TRADE_DATA13_DESC}" />" >
							<input type='radio' class="validate-one-required"  id='TRADE_DATA13_1' name='TRADE_DATA13' value='1' <c:if test="${rtnMap.TRADE_DATA13 eq 1}">checked</c:if> >無異常
							<input type='radio' class="validate-one-required"  id='TRADE_DATA13_2' name='TRADE_DATA13' value='2' title="買賣件查證事項皆需選擇!" <c:if test="${rtnMap.TRADE_DATA13 eq 2}">checked</c:if> >否
						</td>
					</tr>

					<tr>
						<td class="tbYellow"  >其他照會說明</td>
						<td class="tbYellow2" colSpan="7">
							<input type="text" class="textBox2"  size="100" maxlength="100" id="TRADE_DATA_DESC" name="TRADE_DATA_DESC" title="請輸入其他照會說明!" value="<c:out value="${rtnMap.TRADE_DATA_DESC}" />" >
						</td>
					</tr>
				</table>
				</form>
</body>
</html>
