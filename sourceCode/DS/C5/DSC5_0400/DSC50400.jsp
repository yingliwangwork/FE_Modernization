<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程式：DSC50400.jsp
功能：收息調整輸入作業
作者：溫子
完成：2013/09/
 -->
 <!--
 [20200629]問題單(202006200074):
 1.上傳Xlsx檔案改成Csv 
 -->
 
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>	
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<%--[20241101]難字css  --%>
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
Event.observe(window, 'load', new DSC50400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
var grid1;
var grid2;
var reqMap;
var encrypt_path;
function DSC50400(){
	function initValidation(){
	
					Validation.addAllThese([
						 <%-- [20200629] 上傳Xlsx檔案改成Csv --%>
						[ 'validate-isCsv',  '請上載csv檔案' , 
							function(v,elm) {
								var path = $('DOC_PATH').value;
								if(path.lastIndexOf('.csv') < 0 && path.lastIndexOf('.CSV') < 0){
									return false;
								}
								return true;
							}
						],
						
					]);
					
			
			valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'})	
			//valid1.define( "required" , { id: "LOAN_ID" , errMsg:"貸款帳號不可空白!!" } );
			//valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID"});
			valid1.define( "validate-selection" , { id: "OP_STATUS", errMsg:"請選擇狀態!!" });
			valid2 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'})
			valid2.define( 'validate-isCsv' , { id: "DOC_PATH", errMsg:'請上載csv檔案' });	
			
	}
	function chkINPUT_DATE(strObj, endObj){
		if(!isROCdate(strObj.value) || !isROCdate(endObj.value)){
			return true;
		}
		if(diffDay(strObj.value, endObj.value)>30){
			return false;
		}
		if(diffDay(strObj.value, endObj.value)<0){
			return false;
		}
		
		return true;
	
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0400/" + actionName,
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
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0005:"BTN_DELETE",<%--刪除--%>
			B0070:"BTN_CONFIRM",<%--覆核--%>
			B0064:"BTN_UPLOAD",<%--上傳--%>
			B0066:"BTN_IMPORT"<%--匯入--%>
		};
		
		<dz:grantButtons FUNC_ID="DSC50400" />
	}
	function OP_Button_Del(){
		if($F('OP_STATUS')=='3'){
			$('BTN_DELETE').disable();
			$('BTN_CONFIRM').disable();
		}else{
			$('BTN_DELETE').enable();
			$('BTN_CONFIRM').enable();
		}
	}
	var buttons={
	
		doQuery : function(){
			valid1.reset();
			if(Validation.get('IsEmpty').test($F('REFER_ID')) && Validation.get('IsEmpty').test($F('BORROW_ID')) && Validation.get('IsEmpty').test($F('LOAN_ID'))&&Validation.get('IsEmpty').test($F('INPUT_DEPT'))&&(Validation.get('IsEmpty').test($F('INPUT_DATE_S'))||Validation.get('IsEmpty').test($F('INPUT_DATE_E')))){
				alert("請輸入查詢條件!");
				return;
			}
			var msg = '';
			if($F('REFER_ID') && $F('REFER_ID').length!=10){
				msg = msg+"請輸入正確原貸帳號!\n";
			}
			if($F('BORROW_ID') && $F('BORROW_ID').length!=10){
				msg = msg+"請輸入正確借款人ID!\n";
			}
			if($F('LOAN_ID') && $F('LOAN_ID').length!=10){
				msg = msg+"請輸入正確貸款帳號!\n";
			}
			if(($F('INPUT_DATE_S')||$F('INPUT_DATE_E'))){
				if(!isROCdate($F('INPUT_DATE_S')) || !isROCdate($F('INPUT_DATE_E'))){
					msg = msg+"請輸入正確日期格式";
				}
				if(diffDay($F('INPUT_DATE_S') ,$F('INPUT_DATE_E')) >30){
					msg = msg+"請將查詢期間縮短成一個月!\n";
				}
				if(diffDay($F('INPUT_DATE_S') ,$F('INPUT_DATE_E')) <0){
					msg = msg+"請將查詢期間起日不可大於訖日\n";
				}
			}
			if(msg){
				alert(msg);
				return;
			}
			if(!valid1.validate()){ 
				return; 
			}
			reqMap = {
				REFER_ID : $F('REFER_ID'),
				BORROW_ID : $F('BORROW_ID'),
				LOAN_ID : $F('LOAN_ID'),
				OP_STATUS : $F('OP_STATUS'),
				INPUT_DATE_S : $F('INPUT_DATE_S'),
				INPUT_DATE_E : $F('INPUT_DATE_E'),
				INPUT_DEPT : $F('INPUT_DEPT')
			};
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
					,function(resp){
						grid1.load(resp.rtnList||[]);
						grid2.load([]) ;
						OP_Button_Del();
					},function(resp){
						grid1.load([]);
						grid2.load([]) ;
						OP_Button_Del();
						
					});
		}
		,doInsert : function(){
			var LP_JSON = {
					action : '<%=dispatcher%>/DSC5_0410/prompt',
					LINK_FROM : 'DSC50400'
				};
						
				CSRUtil.linkTo(LP_JSON , 'form1');
		}
		,doDelete : function(){
			var dataList =grid1.getCheckedRecord();	
				if(dataList.length==0){
				  alert("請至少勾選一筆資料");
				  return;
				}
				if(!confirm("確定要刪除此利息調整之資料?")){
					return ;
				}
				ajaxPost( 'delete', {reqMap : Object.toJSON(reqMap), dataList:Object.toJSON(dataList)}
					,function(resp){
						grid1.load(resp.rtnList||[]);
						OP_Button_Del();
					},function(resp){
						grid1.load([]);
						OP_Button_Del();
					});
		}
		,doConfirm :function(){
			var dataList =grid1.getCheckedRecord();	
				if(dataList.length==0){
				  alert("請至少勾選一筆資料");
				  return;
				}
				if( dataList.length > ${count} ){
					alert("覆核筆數不可高於"+${count}+"筆");
					return;
				}
				ajaxPost( 'confirm', {reqMap : Object.toJSON(reqMap), dataList:Object.toJSON(dataList)}
					,function(resp){
						grid1.load(resp.rtnList||[]);
						OP_Button_Del();
					},function(resp){
						//grid1.load([]);
						OP_Button_Del();
					});
		}
		,doUpload :function(){	
			valid2.reset();
			if(!$F('DOC_PATH')){
				alert('請先選擇檔案後再上載');
				return;
			}
			if(!valid2.validate()){ 
				return; 
			}
			auxiliary.createCoverPage();
			document.form2.submit();
		}
		,// 上傳結束
		importEnd : function(){
			auxiliary.closeCoverPage();
			

			var obj = window.importFrame.document.getElementById("filedata").innerHTML.evalJSON();
			
			if(CSRUtil.isSuccess(obj)){
			    grid1.load([]) ;
				grid2.load(obj.rtnList || []) ;
				encrypt_path = obj.encrypt_path;
				$('form2').reset();
					
			}else{
				grid1.load([]) ;
				grid2.load([]) ;
				encrypt_path = '';
			}				
			var Msg = obj.ErrMsg.msgDesc.replace("\\n","");
			if(Msg){
				alert(Msg);
			}
			
		}
		,doImport : function(){
			if(!encrypt_path){
				alert("匯入的暫存檔路徑不存在");
				return ;
			}
			var dataList = grid2.getCheckedRecord();
			if( dataList.length == 0 ){
				alert("請至少選取一筆資料");
				return;
			}
			if( dataList.length > ${count} ){
				alert("匯入筆數不可高於"+${count}+"筆");
				return;
			}
			
			var selectMap = {};
			for(var i=0;i<dataList.length;i++){
				var NO = dataList[i]['NO'];
					selectMap[NO] = NO;				
			}
			ajaxPost( 'import', {dataList:Object.toJSON(selectMap),encrypt_path:encrypt_path}
					,function(resp){
						grid2.load([]);
					},function(resp){

					});			
		}
		
	}
	var cover;
	var auxiliary = {
		createCoverPage:function(){
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		closeCoverPage: function(){
			cover.hide();
		}
	};
	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC50400', '利率調整', '收息調整輸入作業');
				grid1 = new TableUI(
				{table: $("grid1"), allSortable: false, pageSize: 20,overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					isSelectAll:true
				},		
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
						{header: "貸款帳號",key: "LOAN_ID"},
						{header: "期數",key: "PAY_TERM"},	
						{header: "繳別",key: "PAY_KIND_NM"},	
						{header: "序號",key: "SEQ_NO"},	
						{header: "異動原因",key: "ADJUST_REASON_NM"},
						{header: "本金調整",key: "PRINCIPAL",
							render: function (rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},	
						{header: "利息調整",key: "INTEREST",
							render: function (rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},	
						{header: "延滯息調整",key: "DELAY_INT",
							render: function (rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},	
						{header: "違約金調整",key: "RENEGE",
							render: function (rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},		
						{header: "代扣稅款調整",key: "TAX",
							render: function (rec,val){
								return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},
						{header: "入帳",key: "ACNT_NOTE_NM"},	
						{header: "入帳日期",key: "ACNT_DATE",
							render : function(rec , val){
								return 	val ?  Date.toROC(val) : "";
							}
						},	
						{header: "狀態",key: "OP_STATUS_NM"},	
						{header: "輸入日期",key: "INPUT_DATE",
							render : function(rec , val){
								return 	val ?  Date.toROC(val) : "";
							}
						},	
						{header: "輸入人員",key: "INPUT_NAME", attrs:{style:"font-family:'EUDC'"}}	
					]
				});
				grid2 = new TableUI(
				{table: $("grid2"), allSortable: false, pageSize: 20,overDiv:false,
				autoCheckBox:{
				    text:'選取',
					type:'checkbox',
					isSelectAll:true
				},				
				column:[
						{header: "貸款帳號",key: "LOAN_ID"},
						{header: "期數",key: "PAY_TERM"},	
						{header: "繳別",key: "PAY_KIND_NM"},	
						{header: "異動原因",key: "ADJUST_REASON_NM"},	
						{header: "利息調整",key: "INTEREST",
							render: function (rec,val){
									return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},	
						{header: "延滯息調整",key: "DELAY_INT",
							render: function (rec,val){
									return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},	
						{header: "違約金調整",key: "RENEGE",
							render: function (rec,val){
									return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						},		
						{header: "代扣稅款調整",key: "TAX",
							render: function (rec,val){
									return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
							}
						}
					]
				});
				initValidation();
				buttonAuth();
				if($('CHECK_UPLOAD').value!='1'){
					$('form2').style.display = "none"; 
				}
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_CONFIRM').observe('click',buttons.doConfirm);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_UPLOAD').observe('click', buttons.doUpload);//上傳
				$('importFrame').observe('load', function(event){buttons.importEnd();});
				$('BTN_IMPORT').observe('click', buttons.doImport);
				var LP_JSON = CSRUtil.isBackLink('form1');	
				
				if(LP_JSON){ //根據name去放值
					if($F('OP_STATUS')){
						buttons.doQuery();
					}
				}
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table id='table1' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
	<tr>
		<input id="CHECK_UPLOAD" type="hidden" class="textBox2" name="CHECK_UPLOAD" value='${CHECK_UPLOAD}'/> 
		<td class="tbYellow">輸入單位</td>
		<td class="tbYellow2" width="20%">
		<input id="INPUT_DEPT" type="text"class="textBox2" name="INPUT_DEPT" size='12' maxlength='7' value='${INPUT_DEPT}'/></td>
		<td class="tbYellow">查詢日期</td>
		<td class="tbYellow2" width="35%">
		<input id="INPUT_DATE_S"  type="text" class="textBox2" name="INPUT_DATE_S" value='${INPUT_DATE}'  datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('INPUT_DATE_S'))">~
		<input id="INPUT_DATE_E"  type="text" class="textBox2" name="INPUT_DATE_E" value='${INPUT_DATE}'  datatype="ROCDate" maxlength="7"/>
			<img id = "img_date" src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('INPUT_DATE_E'))">
		</td>
		<td class="tbYellow2" rowspan="3" align='center'>
		<input id="BTN_QUERY" type="button" class="button" value="查詢" /> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >貸款帳號</td>
			<td class="tbYellow2">
			<input id="LOAN_ID" type="text" class="textBox2" name="LOAN_ID" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
		<td class="tbYellow" >借款人ID</td>
			<td class="tbYellow2">
			<input id="BORROW_ID" type="text" class="textBox2" name="BORROW_ID" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >原貸帳號</td>
			<td class="tbYellow2">
			<input id="REFER_ID" type="text" class="textBox2" name="REFER_ID" onblur="this.value = this.value.toUpperCase()" size="12" maxlength="10"/>
		</td>
		<td class="tbYellow" >狀態</td>
		<td class="tbYellow2">
			<select id="OP_STATUS" name="OP_STATUS">	
				<option value="">請選擇</option>			
				<c:forEach items="${OP_STATUS_LIST}" var="row">
					<option value="${row.key}" />${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" align='center' colspan="6">
		<input id="BTN_INSERT" type="button" class="button" value="新增" />
		<input id="BTN_DELETE" type="button" class="button" value="刪除" />
		<input id="BTN_CONFIRM" type="button" class="button" value="覆核" />		
		</td>
	</tr>
</table>
<table id="grid1" class="grid"></table>
</form>

</form>
<form name="form2" id="form2" method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSC5_0400/upload">
<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbBlue" colspan="2">檔案上傳</td>
	</tr>
	<tr>
		<td class="tbYellow">檔案</td>
		<td class="tbYellow2">
		<input id="DOC_PATH" name="DOC_PATH" type="file" class='button' size="50"> 
		<input id="BTN_UPLOAD" type="button" class="button" value="上傳" /> 
		<input id="BTN_IMPORT" type="button"class="button" value="匯入" /></td>
	</tr>
</table>
<table id="grid2" class="grid"></table>
</form>
<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe>
<%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>