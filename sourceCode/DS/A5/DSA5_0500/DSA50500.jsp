<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<!--
程式：DSA50500.jsp
作者：詹鎧駿
功能：EMAIL附件上傳
完成：
-->
<html>
<head>

<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!--匯入外部Javascript 與 css-->

<title>DSA50500</title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">


<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<!-- 必要 -->
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<!-- 目前系統常用的表格工具 -->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javascript'>

<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA50500().initApp);

function DSA50500(){
	
	//查詢的檢核
	var valid1;
	
	//上傳的檢核
	var valid2;
	
	function buttonAuth() { <%--按鈕授權--%>
		var authButtons = { 
			B0001 : 'btnQuery',    <%--查詢--%>
			B0064 : 'btnUpload',   <%--上傳--%>
			B0005 : 'btnDelete'    <%--刪除--%>			
		};
		<dz:grantButtons FUNC_ID="DSA50500"/>
		
	};

	//畫面欄位檢核
	function initValidation() {
		Validation.addAllThese([
			[ 'LOAN_IDLength_insert',  '請輸入正確貸款帳號!', 
				function(v){
					if(v !==''){
						return v.length == 10 ? true : false;
					}	
				return true;		
			}],
			[ 'CODE_KND_choose',  '請選取上傳種類!', 
				function(v){
					return ( $$('input:radio:checked[name="CODE_KND"]').length != 0); //判斷取得radio的筆數
				}		
			],							
		]);

		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		valid1.define( "required" , { id: "LOAN_ID" , errMsg : '請輸入貸款帳號查詢!'} );
		valid1.define( "LOAN_IDLength_insert" , { id: "LOAN_ID" } );

		//上傳用檢核	
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid2.define( "required" , { id: "LOAN_ID" , errMsg : '請先輸入貸款帳號!'} );
		valid2.define( "required" , { id: "import_file" , errMsg : '請先選擇上傳來源!'} );
		valid2.define( "CODE_KND_choose" , { id: "CODE_KND" } );
		
	}
		
	<%-- TablE UI物件 --%>
	var grid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA5_0500/');
	
	<%--CoverPage(鎖定/開放畫面)--%>
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
				
	var buttons = {
		
		<%-- 查詢 --%>
		doQuery : function() {
			var no_queryAuth = $('btnQuery').disabled; //按鈕控制
			if(no_queryAuth){
				return;
			}
			
			valid2.reset();
			if(!valid1.validate()){ 
				return; 
			}

			<%-- 發送AJAX --%>
			ajaxRequest.post( 'query' , { 'LOAN_ID' : $F('LOAN_ID')},
				function(resp) { <%-- success --%>
					grid.load(resp.fileInfoList || []);
				},function(resp) {  <%-- failure-查詢失敗清除先前的查詢資料 --%>
					grid.load([]);
				}
			);					
		},
		
		<%-- 上傳 --%>
		doUpload : function() {
			
			valid1.reset();
			if(!valid2.validate()){ 
				return; 
			}
			
			auxiliary.createCoverPage();
			//把檔案匯入
			$('form1').submit();
		},
		
		<%--上載結束的處理(回傳至頁面處理)--%>
		doReloadImport: function(){			
			var filedata = window.importFrame.document.getElementById('filedata');
			if(!filedata){
				return;
			}
			var obj = filedata.innerHTML.evalJSON();
			if(CSRUtil.isSuccess(obj)){	<%--執行成功後重新顯示附件區--%>			
				grid.load(obj.fileInfoList);
			}else{
				grid.load([]);	
			}
			
			<%--清除檔案路徑欄位--%>
			$('import').update(new Element( 'input', { id:'import_file', name:'import_file', type:'file', 'class': 'button', 
			size:'20'}));
			
			<%--顯示訊息--%>
			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
			if(Msg != null && Msg != ""){
				alert(Msg);
			}	
			auxiliary.closeCoverPage();			
		},
		
		
			
		<%-- 刪除 --%>
		doDelete : function() {
			var hasRecords = grid.hasRecords();	<%--檔案代號--%>
			if (!hasRecords) {
				alert('請先查詢附件清單');
				return;
			}
			var FileList = grid.getCheckedRecord(["FILE_ID", "INSERT_ID", "INSERT_DATE"]);	<%--檔案代號--%>
			var Filelength = FileList.length;
			
				
			if (Filelength == 0 ){
				alert('未選取附件清單，無法刪除!');
				return;			
			}

			var TODAY = '${TODAY}';
			var nottoday = false; 
			
			for(var i = 0; i < Filelength; i++){
				if (FileList[i].INSERT_DATE.split(" ")[0] != TODAY){
					nottoday = true;
					break;
				}	
			}			
			if(nottoday){
				if(!confirm('選取資料非當日上傳件，是否仍確定刪除?')){
					return;
				}
			}
							
			<%-- 發送AJAX --%>			
			ajaxRequest.post( 'delete' , { FileList : Object.toJSON(FileList), 'LOAN_ID' : $F('LOAN_ID')},
				function(resp) { <%-- success --%>
					grid.load(resp.fileInfoList || []);
				}
			);		
		}
	};

	return {
	
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement('DSA50500', '管理作業', '附件上傳');
			
			grid = new TableUI({
					table :$('grid'),
					allSortable : false,
					autoCheckBox : {
						text : '選取',
						type : 'checkbox',
					    isSelectAll : true,
						pageSize: 10	
					},
					
					column : [
						{ header : '序號', key : 'FILE_ID' },
						{ header : '附件檔名', key : 'FILE_NM',
							render : function(rec, val) {
								var link = new Element('a', { href : 'javascript:void(0);' }).update(val);
									link.observe('click', function() {
										RPTUtil.downloadFile('${dispatcher}/DSA5_0500/download', { FILE_ID : rec.FILE_ID }, true);
										<%--檔案下載--%>
									});
									return link;
							}
						},
						{ header : '種類', key : 'CODE_KND',
							render : function(rec, val) {
								if (val == 1){
									return '利率調降';
								}
								if (val == 2){
									return '變更年期'
								}
								if (val == 3){<%--[20221229]新增--%>
									return '本金彈性還變更 '
								}
								return '';
							}
						},
						{ header : '上傳日期', key : 'INSERT_DATE', sortRule : 'datetime'},
						{ header : '上傳人員', key : 'INSERT_NAME'},
						{ header : '異動日期', key : 'LST_PROC_DATE', sortRule : 'datetime' },
						{ header : '異動人員', key : 'LST_PROC_NAME'},
						{ header : '郵寄備註', key : 'EMAIL_NOTE'}
					]
			});
															
			<%-- 註冊click事件 --%>
			$('btnQuery').observe('click', buttons.doQuery);
			$('btnUpload').observe('click', buttons.doUpload);<%-- 確認上載--%>
			$('btnDelete').observe('click', buttons.doDelete);
			$('importFrame').observe('load', buttons.doReloadImport);	<%--監視: iframe有匯入時啟動--%>
			
			
			initValidation();
			
			buttonAuth();
			<c:if test='${not empty LOAN_ID}'>
			buttons.doQuery();
			</c:if>
			<%-- 按鈕控制 --%>
			PageUI.resize();
			displayMessage();
			
		}
	};
}	
</script>				
</head>		
<body>
<form name='form1' id='form1'method="post" target="importFrame" enctype="multipart/form-data" action="${dispatcher}/DSA5_0500/upload">
<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>		
	<table width="100%" border="0" align="center" cellspacing="1" class="tbBox2" id="tableA">
		<tr>
			<td class="tbYellow" >貸款帳號</td>
			<td class="tbYellow2">
				<input type="text" id="LOAN_ID" class="textBox2" title="貸款帳號" name="LOAN_ID" value="${LOAN_ID}"/>				
			</td>
			<td class="tbYellow2" rowspan="3" >
				<button type="button" class="button" id="btnQuery">查詢</button>
				<button type="button" class="button" id="btnDelete">刪除</button>
			</td> 
		</tr>
		<tr>
			<td class="tbYellow">上傳來源</td>
			<td class="tbYellow2">
				<span id="import"> 
					<input id="import_file" id="import_file" name="import_file" type="file" title="上傳來源" />
				</span>
				<button type="button" class="button" id="btnUpload">上傳</button>
			</td>			
		</tr>
		<tr>
			<td class="tbYellow">上傳種類</td>
			<td class="tbYellow2">
				<input type="radio" name="CODE_KND" value="1" <c:if test="${COND_KND eq 1}">checked</c:if> />利率調降
				<input type="radio" name="CODE_KND" value="2" <c:if test="${COND_KND eq 2}">checked</c:if>/>變更年期
				<input type="radio" name="CODE_KND" value="3" <c:if test="${COND_KND eq 3}">checked</c:if>/>本金彈性還變更<%--[20221229]新增--%>
			</td>	
		</tr>	
</table>
<table id='grid' class='grid' ></table>
</form>
</body>
</html>	