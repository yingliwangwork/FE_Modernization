<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSC5_0300.java
作者：陳思涵 
功能：個別優惠利率作業
完成：2013-08-27	
 -->
<!--
[20200623]問題單(202006200074):
1.上傳Xlsx檔案改成Csv

[20241104] 修改件 難字調整 吳志鴻
 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript"
	src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<!-- 必要 -->
<script type="text/javascript"
	src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<!-- 檢核訊息的顯示 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<!-- 目前系統常用的表格工具 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<!-- 目前畫面的版面設定 -->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<!-- 檔案上傳、下載(pdf, csv, xls等) -->

<%-- [20241104] 難字調整 --%>
<style type="text/css">
	@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
	}
</style>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC50300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC50300(){
	var grid1;
	var grid2;
	var valid1;
	var validQuery;
	var queryMap={};
	var encrypt_path;
	
	function  initValidation(){
			Validation.addAllThese([
				 <%-- [20200623] 上傳Xlsx檔案改成Csv --%>
				[ 'validate-isCsv',  '請上載csv檔案', 
					function(v,elm) {
						var path = $('DOC_PATH').value;
						if(path.lastIndexOf('.csv') < 0 && path.lastIndexOf('.CSV')< 0 ){
							return false;
						}
						return true;
					}
				],
				[ 'validateQueryParam',  '請輸入查詢條件!', 
					function(v,elm) {
						return !(Validation.get('IsEmpty').test($F('REFER_ID')) && Validation.get('IsEmpty').test($F('BORROW_ID')) && Validation.get('IsEmpty').test($F('LOAN_ID')));
					}
				],
				[ 'validateID',  '原貸帳號格式有誤', 
					function(v,elm) {
						if(v){
							<%--原貸帳號、貸款帳號10碼英數字--%>
							return v.length == 10 && (/^[a-zA-Z0-9]+$/.test(v)); 
						}
						return true;
					}
				],
				[ 'validateBORROW_ID',  '借款人ID格式有誤', 
					function(v,elm) {
						if(v){
							<%--借款人ID身分證字號檢核--%>
							return validation.checkROCID( v );
						}
						return true;
					}
				]
			]);
			
		 	valid1 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define("required", { id: "DOC_PATH", errMsg: "請先選擇欲上載的檔案"} );
			valid1.define("validate-isCsv", { id: "DOC_PATH"} );
			
			validQuery = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
			validQuery.define("validateQueryParam", { id: "REFER_ID"} );
			validQuery.define("validateID", { id: "REFER_ID", errMsg: "原貸帳號格式有誤"} );
			validQuery.define("validateID", { id: "LOAN_ID", errMsg: "貸款帳號格式有誤"} );
			validQuery.define("validateBORROW_ID", { id: "BORROW_ID"} );
			
	}
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0003:"btn_update",<%--新增--%>
			B0005:"btn_delete",<%--刪除--%>
			B0070:"btn_confirm",<%--覆核--%>
			B0064:"btn_upload",<%--上傳--%>
			B0066:"btn_import"<%--匯入--%>
		};
		
		<dz:grantButtons FUNC_ID="DSC50300" />
	}	
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0300/" + actionName,
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
	}//END   共用AJAX
	
	var columnObj = {
		a : [
				{header: "貸款<BR>帳號",key: "LOAN_ID",
					render: function(record,value){						
							var link = new Element('a', { href : "#"}).update(value);
							link.observe('click',function(event){
								CSRUtil.linkTo({
									action : "<%=dispatcher%>/DSC5_0310/prompt",
									LOAN_ID : record.LOAN_ID,
									BEGIN_DATE : record.BEGIN_DATE,
									OP_STATUS : record.OP_STATUS
								}, 'form1');
							});
							return link;
						}
				},
				{header: "生效日",key: "BEGIN_DATE",
					render : function(rec , val){						
						return 	val ?  toROC(val) : "";
					}},	
				{header: "優惠<BR>原因",key: "ADJUST_REASON_NM"},	
				{header: "固定利率<BR>期數",key: "FRATE_TERM"},	
				{header: "固定優惠<BR>利率",key: "FIX_RATE"},	
				{header: "加減碼",key: "SPEC_ADJUST"},	
				{header: "固定利率<BR>終止日",key: "FRATE_ENDDATE",
					render : function(rec , val){
						return 	val ?  toROC(val) : "";
					}},		
				{header: "到期日",key: "END_DATE",
					render : function(rec , val){
						return 	val ?  toROC(val) : "";
					}
				},
				//{header: "案件編號",key: "REGISTER_NO"},	
				{header: "狀態",key: "OP_STATUS_NM"},	
				{header: "輸入<BR>人員",key: "INPUT_NAME",attrs:{style:"font-family:'EUDC'"}},	 <%-- [20241104] 難字調整: 輸入人員 --%>
				{header: "輸入日",key: "INPUT_DATE",
					render : function(rec , val){
						return 	val ?  toROC(val) : "";
					}},
				{header: "個調附約",key: "IS_AUTO_NM"},
				{header: "是否email<BR>通知客戶",key: "INFORM_SEND_NM"},
				{header: "中止原因",key: "REJECT_CODE_NM"}					
				],
		b: [	
				{header: "貸款帳號",key: "LOAN_ID"},
				{header: "生效日期",key: "BEGIN_DATE",
					render : function(rec , val){						
						val = JsUtils.trim(val);
						return 	val ?  toROC(val) : "";
					}},	
				{header: "總優惠期數",key: "PREFER_TERM"},	
				{header: "優惠原因",key: "ADJUST_REASON_NM"},	
				{header: "固定優惠期數",key: "FRATE_TERM"},	
				{header: "固定利率",key: "FIX_RATE"},	
				{header: "加減碼",key: "SPEC_ADJUST"},	 
				{header: "是否為保戶優惠",key: "INSU_PREFER_NM"},	
				{header: "個調附約",key: "IS_AUTO_NM"},
				{header: "是否email通知客戶",key: "INFORM_SEND_NM"},
				{header: "手續費用",key: "EXPENSE_AMT"}
				]
	};
	
	
	var buttons = {
		//查詢
		doQuery : function(event){
			valid1.reset();
			if(!validQuery.validate()){
				return;
			}
			/*if(Validation.get('IsEmpty').test($F('REFER_ID')) && Validation.get('IsEmpty').test($F('BORROW_ID')) && Validation.get('IsEmpty').test($F('LOAN_ID'))){
				alert("請輸入查詢條件!");
				return;
			}
			
			var msg = '';
			if($F('REFER_ID')!='' && $F('REFER_ID').length!=10){
				msg = msg+"請輸入正確原貸帳號!\n";
			}
			if($F('BORROW_ID')!='' && $F('BORROW_ID').length!=10){
				msg = msg+"請輸入正確借款人ID!\n";
			}
			if($F('LOAN_ID')!='' && $F('LOAN_ID').length!=10){
				msg = msg+"請輸入正確貸款帳號!";
			}
			if(msg){
				alert(msg);
				return;
			}*/
			
			
			var reqMap = {
				REFER_ID : $F('REFER_ID'),
				BORROW_ID : $F('BORROW_ID'),
				LOAN_ID : $F('LOAN_ID'),
				OP_STATUS : $F('OP_STATUS')
			};
			ajaxPost('query' , { reqMap : Object.toJSON(reqMap) },
				function(resp){					
				    grid1.load(resp.rtnList || []);
					grid2.load([]);
				},
                function(resp){

				    grid1.load([]);
					grid2.load([]);
				}				
			);
			
			queryMap = reqMap;
		
		},
		//待覆核查詢
		doConfirmQuery : function(event){
			
			ajaxPost('confirmQuery' , {  },
				function(resp){
					grid1.load(resp.rtnList || []);
					grid2.load([]);
				},
                function(resp){
				    grid1.load([]);
					grid2.load([]);
				}					
			);
		},
		//刪除
		doDelete : function(event){
		
			var dataList = grid1.getCheckedRecord(['LOAN_ID','BEGIN_DATE','OP_STATUS']);
			
			if( dataList.length == 0 ){
				alert("請至少選取一筆資料");
				return;
			}
			
			ajaxPost('delete' , { dataList : Object.toJSON(dataList) , 
									CHECK_DELETE : $F('CHECK_DELETE'),
									queryMap : Object.toJSON(queryMap) },
				function(resp){
				    grid1.load(resp.rtnList || []);
					grid2.load([]);
				}	
			
			);
			
			
		},
		//覆核
		doConfirm : function(event){
			var dataList = grid1.getCheckedRecord();
			
			if( dataList.length == 0 ){
				alert("請至少選取一筆資料");
				return;
			}
			ajaxPost('confirm' , { dataList : Object.toJSON(dataList) , 
									queryMap : Object.toJSON(queryMap) },
				function(resp){
				
					grid1.load(resp.rtnList || []);
					grid2.load([]);
				}	
			
			);
			
		
		},
		//上傳
		doUpload : function(event){
			valid1.reset();	
			validQuery.reset();
			if(!valid1.validate()){
				return;
			}
			
			auxiliary.createCoverPage();
			document.form2.submit();
		
		},
		// 上傳結束
		importEnd : function(){
			auxiliary.closeCoverPage();
			
			
						
			
			var obj = window.importFrame.document.getElementById("filedata").innerHTML.evalJSON();
			
			if(CSRUtil.isSuccess(obj)){
				grid2.load(obj.rtnList || []) ;
				encrypt_path = obj.encrypt_path;
				$('form2').reset();
					
			}else{
				grid2.load([]) ;
				encrypt_path = '';
			}				
			var Msg = obj.ErrMsg.msgDesc.replace("\\n","");
			if(Msg){
				alert(Msg);
			}
			
		},
		//匯入資料庫
		doImport : function(event){
			if(!encrypt_path){
				alert("匯入的暫存檔路徑不存在");
				return ;
			}
			
			var dataList = grid2.getCheckedRecord();
			if( dataList.length == 0 ){
				alert("請至少選取一筆資料");
				return;
			}
			
			var selectMap = {};
			for(var i=0;i<dataList.length;i++){
			var NO = dataList[i]['NO'];
				selectMap[NO] = NO;				
			}
       
			ajaxPost('import' , {encrypt_path : encrypt_path,  selectMap :	Object.toJSON(selectMap),queryMap : Object.toJSON(queryMap)},				 
				function(resp){
					grid1.load(resp.rtnList || []);
				}						
			
			
			);
		}
	};

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
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC50300', '利率調整', '個別優惠利率作業');
			//240613問題單編號20240613-0022	個別優惠整批匯入優化 BY余凱鈞
			grid1 = new TableUI({
				table: $('grid1'),
				autoCheckBox:{isSelectAll:true},
				pageSize: 10, 
				column:columnObj.a
			});
			grid2 = new TableUI({
				table: $('grid2'),
				autoCheckBox:{isSelectAll:true},
				pageSize: 10, 
				column:columnObj.b
			});
			
			
			initValidation();
			buttonAuth();
			
						
			/*var CHECK_UPLOAD = '${CHECK_UPLOAD}' || '';
			$('CHECK_UPLOAD').value = CHECK_UPLOAD;*/
			$('CHECK_DELETE').value =  '${CHECK_DELETE}'  || '';

			/*if(CHECK_UPLOAD != '1'){
				$('form2').style.display = "none"; 
			}*/
			
			$w('REFER_ID BORROW_ID LOAN_ID').each(
						function(id){
							$(id).observe('blur', function(){this.value = this.value.toUpperCase();});
			});
			
			$('importFrame').observe('load', function(event){
					buttons.importEnd();
				});
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_confirmQuery').observe('click', buttons.doConfirmQuery);
			$('btn_update').observe('click', 
				function(event){
					CSRUtil.linkTo({
						action : "<%=dispatcher%>/DSC5_0310/prompt"
					}, 'form1');
				});
			$('btn_delete').observe('click', buttons.doDelete);
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_upload').observe('click', buttons.doUpload);
			$('btn_import').observe('click', buttons.doImport);
			
			
			//接上一頁回來的欄位資訊
			var LP_JSON = CSRUtil.isBackLink('form1');				
			if(LP_JSON){ //根據name去放值	
				//alert('here'+ '${LOAN_ID}');	
				buttons.doQuery();
			}else if('${LOAN_ID}'){
				$('LOAN_ID').value = '${LOAN_ID}';
				buttons.doQuery();
			}
			
			PageUI.resize();			
			displayMessage();			
		}
	};

}






</script>
</head>
<body>
<form name="form1" id="form1"
	style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table id="table1" width="100%" border="0" cellpadding="0"
	cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow">原貸帳號</td>
		<td class="tbYellow2"><input id="REFER_ID" type="text"
			class="textBox2" size='12' maxlength='10' /></td>
		<td class="tbYellow">借款人ID</td>
		<td class="tbYellow2"><input id="BORROW_ID" type="text"
			class="textBox2" size='12' maxlength='10' /></td>

		<td class="tbYellow2" rowspan="2"><input id="btn_query"
			type="button" class="button" value="查詢" /> <input
			id="btn_confirmQuery" type="button" class="button" value="待覆核件查詢" />
		</td>
	</tr>
	<tr>
		<td class="tbYellow">貸款帳號</td>
		<td class="tbYellow2"><input id="LOAN_ID" name="LOAN_ID" type="text"
			class="textBox2" size='12' maxlength='10' /></td>
		<td class="tbYellow">狀態</td>
		<td class="tbYellow2"><select id="OP_STATUS">
			<option value=''>全部</option>
			<c:forEach var="map" items="${OP_STATUS_LIST}">
				<option value='${map.key}'>${map.value}</option>
			</c:forEach>
		</select></td>
	</tr>
	<tr>
		<td class="tbYellow2" align="center" colspan="5"><input
			id="btn_update" type="button" class="button" value="新增" /> <input
			id="btn_delete" type="button" class="button" value="刪除" /> <input
			id="btn_confirm" type="button" class="button" value="覆核" /> <%-- <input
			id="CHECK_UPLOAD" type="hidden" class="textBox2" size='12'
			maxlength='10' /> --%> <input id="CHECK_DELETE" type="hidden"
			class="textBox2" size='12' maxlength='10' /></td>
	</tr>

</table>
<table id="grid1" class="grid"></table>
</form>
<form name="form2" id="form2" method="post" target="importFrame"
	enctype="multipart/form-data" action="<%=dispatcher%>/DSC5_0300/upload">
<table id="table2" width="100%" border="0" cellpadding="0"
	cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbBlue" colspan="2">檔案上傳</td>
	</tr>
	<tr>
		<td class="tbYellow">檔案</td>
		<td class="tbYellow2"><input id="DOC_PATH" name="import_file"
			type="file" size="50"> <input id="btn_upload" type="button"
			class="button" value="上傳" /> <input id="btn_import" type="button"
			class="button" value="匯入" /></td>
	</tr>
</table>
<table id="grid2" class="grid"></table>
</form>

<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe>
<%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>