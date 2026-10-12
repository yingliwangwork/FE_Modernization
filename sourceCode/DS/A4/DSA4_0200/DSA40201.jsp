<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--

         程式功能概要說明：
         程式功能　名單匯入

	@author 李佳興
	@since 2013-09-26
-->
<!--
[20200709] 房貸應收帳款委外 
1. 新增 "房貸應收債權催收委外" 上傳類別

[20230224]修改件
增加選項【總經變數表】、【村里人口收入變數表】、【建照變數表】，調整【匯入】與【新增】處理邏輯
郭曉慧
 -->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>

<script type="text/JavaScript">


Event.observe(window, 'load', new DSA40201().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function DSA40201(){

	var grid;
	var valid;
	var validInsert;
	var gridDataList;
	var dataIsInsert = "1";	// 1:沒有資料 2:有資料, 未新增 3:有資料, 已新增
	var encrypt_path; //加密檔案路徑
	var uploadLandListDone = false, landListDirPath;
	
	<%--共用Ajax--%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA4_0201/');
	
	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validate'});		
		valid.define( 'required', [ { id: 'A_PATH', errMsg: '請選取正確的檔案資料' } ] );
		validInsert = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validate'});		
		validInsert.define( 'required', [ { id: 'TYPE', errMsg: '資料種類需有值' } ] );
		validInsert.define( 'required', [ { id: 'TYPE_NM', errMsg: '資料種類需有值' } ] );
		//validInsert.define( 'required', [ { id: 'MEMO', errMsg: '說明必須輸入' } ] );
	}
	
	function buttonControl(){
		if('${isValid}' == 'N'){
			$("A_btn_import").disable();
		}
	}

	var buttons = {
		// 匯入
		doImport:function(){
			validInsert.reset();
			if(!valid.validate()){
				return;
			}
			
			var fileName = $('A_PATH').value;
		
			auxiliary.createCoverPage();
			document.form1.submit();
		},
		
		// 匯入結束
		importEnd:function(){

			auxiliary.closeCoverPage();
			var ele_filedata = window.importFrame.document.getElementById("filedata");
			if(ele_filedata){
				var obj = ele_filedata.innerHTML.evalJSON();
				var Msg = obj.ErrMsg.msgDesc.replace('\\n','');      
			}
			//var obj = window.importFrame.document.getElementById("filedata").innerHTML.evalJSON();
			
			if(CSRUtil.isSuccess(obj)){
				uploadLandListDone = obj['uploadLandListDone'] === 'true';
				if(uploadLandListDone){
					landListDirPath = obj['landListDirPath'];
					grid.load(obj['unzipFileList']);
					$("btn_addLandList").enable();
				} else{
					hasError = obj.hasError;
					grid.load(obj.fileList);
					gridDataList = grid.getAllRecords();
					encrypt_path = obj.encrypt_path;			   
				}
			    $('import').update(new Element( "input", { id:"A_PATH", name:"A_PATH", type:"file", 'class': "textBox2", size:"50"}));	
			} else{
				hasError = null;
				gridDataList = null;
			}
			
			if(!uploadLandListDone){
				if(gridDataList && gridDataList.length > 0){
					dataIsInsert = "2";
					$("A_btn_add").enable();
				}else{
					dataIsInsert = "1";
					$("A_btn_add").disable();
				}
			}
			
			//var Msg = obj.ErrMsg.msgDesc.replace("\\n","");
			if(Msg != null && Msg != ""){
				alert(obj.ErrMsg.msgDesc.replace("\\n",""));
			}
		},
		
		// 新增
		doAdd:function(){
			valid.reset();
			if($F('TYPE') != 'LIGHT_LIST'){
				validInsert.define( 'required', [ { id: 'MEMO', errMsg: '說明必須輸入' } ] );
			}
			if(!validInsert.validate()){
				return;
			}
			if(gridDataList.length == 0){
				alert('請先匯入再進行新增');
				return;
			}
			if(!encrypt_path){
				alert('匯入的暫存檔路徑不存在');
				return ;
			}	
			
			var params = {"encrypt_path" : encrypt_path, "MEMO": $F('MEMO'), "TYPE": $F('TYPE')};
			var successAction = function(resp){
			    
				dataIsInsert = "3";
				grid.load([]);
			};
			var errorAction = function(resp){
				
			};
			ajaxRequest.post('add', params, successAction, errorAction);
		},
		
		// 新增不動產實價登錄資料
		doAddLandList:function(){
			valid.reset();
			if(!validInsert.validate()){
				return;
			}
			ajaxRequest.post('addLandList', 
				{
					"landListDirPath" : landListDirPath
				}
			);
		},
	
		// 上一頁
		doBack:function(){
			if(!layout.compareData()){
				if(!confirm("資料未存檔是否放棄儲存?")){
					return;
				}
			}
	
			CSRUtil.linkBack();
		}
	};
	
	//--------------------------------------------------------------------------
	// 畫面操作
	//--------------------------------------------------------------------------
	var layout = {
		// 資料比較
		compareData:function(){
			if(dataIsInsert == "2"){
				return false;
			}else{
				return true;
			}
		}
	};

	//--------------------------------------------------------------------------
	// 輔助工具
	//--------------------------------------------------------------------------
	var auxiliary = {
		createCoverPage:function(){
			var docBody = document.body;
			var cover = $('_frontCover');
			if(!cover){
				cover = document.createElement('div');
				cover.id = '_frontCover';
				cover.style.background = 'white';
				cover.style.filter = 'alpha(opacity=35)';
				cover.style.position = 'absolute';
				cover.style.cursor = 'progress';
				cover.style.posLeft = 0;
				cover.style.posTop = 0;
				cover.style.zIndex = 150;
				docBody.appendChild(cover);
			}
			cover.style.width = (docBody.clientWidth>docBody.scrollWidth)?docBody.clientWidth:docBody.scrollWidth;
			cover.style.height = (docBody.clientHeight>docBody.scrollHeight)?docBody.clientHeight:docBody.scrollHeight;
			Element.show('_frontCover');
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};

	return {
		initApp : function() {

			PageUI.createPageWithAllBodySubElement("DSA40201" , "經手人專區" , "名單匯入");
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay"/>
			
			<c:choose>
            	<c:when test="${TYPE eq 'LIGHT_LIST'}">
	            	grid = new TableUI(
						{
							table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
							column:[
								{header:'期間', key:'PERIOD'},
								{header:'期間開始日', key:'LIGHT_DATE_STR', sortRule:'date'},
								{header:'期間結束日', key:'LIGHT_DATE_END', sortRule:'date'},
								{header:'郵遞區號', key:'GAGE_ZIP'},
								{header:'燈號', key:'LIGHT'}
							]
						}
					);
            	</c:when>
				<c:when test="${TYPE eq 'LAND_LIST'}">
	            	grid = new TableUI(
						{
							table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
							column:[
								{header:'序號', key:'SEQ'},
								{header:'檔名', key:'FILE_NM'}
							]
						}
					);
            	</c:when>
            	<%--[20230224]增-AVMPRAM系列---%>
            	<c:when test="${TYPE eq 'EVAL_PRICE_LIST' || TYPE eq 'EVAL_PRICE_LIST2' || TYPE eq 'COMM_PREDATA' || TYPE eq 'LEJU_COMMUNITY'|| TYPE eq 'AVMPRAM_MCE' || TYPE eq 'AVMPRAM_VLG' || TYPE eq 'AVMPRAM_BLD'}">
	            	grid = new TableUI(
						{
							table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
							column:[
								{ header: "資料種類", key: "TYPE_NM" },
								{ header: "序號", key: "SEQ_NO", sortable: true},
								{ header: "上傳件數", key: "INPUT_CNT", sortable: true},
								{ header: "上傳日期", key: "INPUT_DATE1", sortRule:'date'},
								{ header: "上傳說明", key: "MEMO" , sortable: true}
							]
						}
					);
            	</c:when>
            	
            	<%-- [20200709]  新增 "房貸應收債權催收委外" 上傳類別  --%>
        		<%-- [20210810]  申請書-備呆明細上載-配合監理報表調整為部份自動化：新增 "備呆明細提列方法三清單" 上傳類別    BY余凱鈞--%>
            	<c:when test="${TYPE eq 'MORTGAGE_RECEIVE' || TYPE eq 'BAD_DEBTS3' }">
            	grid = new TableUI(
					{
						table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
						column:[
							{ header: "資料種類", key: "TYPE_NM" },
							{ header: "序號", key: "SEQ_NO", sortable: true},
							{ header: "上傳件數", key: "INPUT_CNT", sortable: true},
							{ header: "上傳日期", key: "INPUT_DATE1", sortRule:'date'}
						]
					}
				);
        		</c:when>
        		<%-- [20230111] 增加匯入種類「平均萬數」--%>
            	<c:when test="${TYPE eq 'AVERAGE_SETTING' }">
            	grid = new TableUI(
					{
						table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
						column:[
							{ header: "區部", key: "DIV_CODE", sortable: true },
							{ header: "單位代號", key: "AREA_CODE", sortable: true},
							{ header: "平均萬數", key: "LOAN_AMT"},
							{ header: "核貸率", key: "APPROVAL_RATE"}
						]
					}
				);
        		</c:when>
           		<c:otherwise>
                 	 grid = new TableUI(
						{
							table: $('table_B'), pageSize: 10, allSortable: true, overDiv:false,
							column:[
								{header:'資料種類', key:'TYPE_NM'},
								{header:'ID', key:'ID'},
								{header:'序號', key:'SEQ_NO'},
								{header:'資料基準日', key:'BASE_DATE', sortRule:'date'},
								{header:'備註', key:'MEMO'}
							]
						}
					);
            	</c:otherwise>
       		</c:choose>
			
			<c:choose>
				<c:when test="${TYPE eq 'LAND_LIST'}">
					$('A_btn_add').hide();
					$('btn_addLandList').show();
				</c:when>
			</c:choose>
			
			buttonControl();
			initValidation();
			
			//--------- 註冊按鈕 ----------
			// 匯入
			$("A_btn_import").observe('click', function(event){
				buttons.doImport();
			});

			$("importFrame").observe('load', function(event){
				buttons.importEnd();
			});

			// 新增
			$('A_btn_add').observe('click', function(event){
				buttons.doAdd();
			});
			
			// 不動產實價登錄資料新增
			$('btn_addLandList').observe('click', function(event){
				buttons.doAddLandList();
			});

			// 上一頁
			$('A_btn_back').observe('click', function(event){
				buttons.doBack();
			});
	
			displayMessage();
		}
	}
}


</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0"	marginwidth="0" marginheight="0">
<form id="form1" name="form1" method="post" target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSA4_0201/import">
<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
<table id="table_A" name="table_A" width="100%" border="0"
	cellpadding="0" cellspacing="1" class="tbBox2">
	
	<tr>
		<td class="tbYellow" width="16%">資料種類
			<input type="hidden" name="TYPE" id="TYPE" class="textBox2" value='${TYPE}' />
			<input type="hidden" name="TYPE_NM" id="TYPE_NM" class="textBox2" value='${TYPE_NM}' />
		</td>
		<td class="tbYellow2" width="16%">${TYPE_NM}</td>
		<td class="tbYellow" width="16%">檔案</td>
		<td class="tbYellow2">
			<span id="import">
				<input id="A_PATH" name="A_PATH" fieldName="來源檔案路徑" type="file" size="50" class="textBox2"> 
			</span>
			<input id="A_btn_import" name="A_btn_import" type="button" class="button"value="匯入">
			<input id="A_btn_back" name="A_btn_back" type="button" class="button" value="上一頁">
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="16%">說明</td>
		<td class="tbYellow2" width="16%" colspan="3">
			<input id="MEMO" name="MEMO" type="text" class="textBox2" maxlength="50" size="60"/>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="4">
			<input id="A_btn_add" name="A_btn_add" type="button" class="button" value="新增" disabled>
			<input id="btn_addLandList" type="button" class="button" value="新增" style="display:none;" disabled>
		</td>
	</tr>
</table>
<table id="table_B" name="table_B" width="100%" class="grid"></table>
</form>
</body>
</html>
