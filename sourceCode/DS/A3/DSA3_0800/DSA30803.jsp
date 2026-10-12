<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30803.jsp
作者：陳思涵
功能：特殊屋況列管區整批更新作業
完成：2021/08/23
[20210823]申請書210817003961：特殊屋況系欄位調整及新增更新作業
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/commView.js'></script>

<script type='text/javascript'>
	<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
	Event.observe(window, 'load', new DSA30803().initApp);

	function DSA30803(){

		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_0803/');

		var grid;
		var serNoList;

		<%-- CoverPage --%>
		var auxiliary = {
			createCoverPage : function() {
				CSRUtil.createCoverPage('_frontCover');
				$('_frontCover').show();
			},
			closeCoverPage: function() {
				$('_frontCover').hide();
			}
		};


		var buttonAuth = function() {
			var authButtons = {
				B0066 : 'btn_import'<%--匯入--%>
				, B0064 : 'btn_upload'<%--上傳--%>
			};
			<dz:grantButtons FUNC_ID="DSA30803" ignored="false"/>
		};

		<%-- 按鈕 --%>
		var buttons = {
			<%-- 上傳 --%>
			doUpload : function() {

				<%-- 顯示CoverPage --%>
				auxiliary.createCoverPage();
				<%-- 啟動上傳 --%>
				$('form1').action = '${dispatcher}/DSA3_0803/upload';
				$('form1').submit();
			},

			<%-- 修正 --%>
			doImport : function() {
				
				var dataList = grid.getAllRecords();

				<%-- 啟動修正 --%>
				ajaxRequest.post('import', {	
						serNoList : Object.toJSON(serNoList),
						dataList : Object.toJSON(dataList)
					}, 
					function(resp) { <%-- 作業完成 --%>
						<%-- 設定畫面資料 --%>
						grid.load([]);//清空table
						serNoList = [];
						actions.btnCtrl();
					}
				);
			}
		};

		<%-- 動作 --%>				
		var actions = {

			<%-- 初始「按鈕Observe Listener」--%>
			initObserve : function() {

				<%-- 上傳 --%>
				$('btn_upload').observe('click', buttons.doUpload);

				<%-- iframe有匯入時啟動 --%>
				$('importFrame').observe('load', actions.afterUploadEnd);
				
				<%-- 匯入 --%>
				$('btn_import').observe('click', buttons.doImport);

			},

			<%-- 上傳結束的處理 (回傳至form1 -> target: importFrame load -> trigger ) --%>	
			afterUploadEnd : function() {		
				<%-- 取得回傳頁面之JSON String --%>
				var ele_filedata = window.importFrame.document.getElementById('filedata');
				if( !ele_filedata ) {
					return;
				}
				var obj = ele_filedata.innerHTML.evalJSON();
				if( !obj ) {
					return;
				}

				<%-- 若上傳失敗顯示上傳結果訊息 --%>
				var ErrMsg = obj.ErrMsg;
				if ( ErrMsg.returnCode != 0 ) { <%-- 失敗皆顯示alert --%>
					alert(ErrMsg.msgDesc.replace('\\n',''));				
				} 

				<%-- 隱藏CoverPage --%>
				auxiliary.closeCoverPage();

				<%-- 檢核是否上傳成功: returnCode=0 --%>
				if(CSRUtil.isSuccess(obj)) {	
					<%-- 將上傳結果顯示於畫面 --%>
					var dataList = obj.dataList || [];
					grid.load(dataList);
					serNoList = obj.serNoList || [];
					
					<%-- 上傳成功後可匯入資料 --%>	
					actions.btnCtrl();
				}
			},

			<%-- 按鈕控制 --%>
			btnCtrl : function(){
				if(serNoList && serNoList.length>0){
					$('btn_import').enable();	
				}else{
					$('btn_import').disable();
				}
			}
		};

		return {                              
			initApp : function() {

				<%-- 統一頁面樣式 --%>
				PageUI.createPage("DSA30803" , "鑑價作業" , "特殊屋況列管區整批更新作業", false);
				
				PageUI.loadin(["form1","grid"], 1);

				<%-- 產表格表頭&定義查詢資料來源 --%>
				grid = new TableUI ({
					table: $("grid"), 
					pageSize: 20,
					split:["A_IS_CONTROL_NM"], 
					validateRecord : function(rec,sn){
						return rec['CHK_MSG'] ? false : true;
					},
					column: [
						{ header: "編號", key: "SER_NO" , attrs:{rowSpan:2}},
						{ header: "縣市", key: "CITY" , attrs:{rowSpan:2}},
						{ header: "行政區", key: "DIST" , attrs:{rowSpan:2}},
						{ header: "門牌", key: "ADDR_NO" , attrs:{rowSpan:2}},
						{ header: "修改前_公告列管", key: "B_IS_CONTROL_NM",
							render : function(rec ,val){
								return val + (rec.B_IS_CONTROL ? '('+rec.B_IS_CONTROL+')':'');
							}
						},
						{ header: "修改前_特殊屋況分級", key: "B_CATEGORY_NM" ,
							render : function(rec ,val){
								return val + (rec.B_CATEGORY ? '('+rec.B_CATEGORY+')':'');
							}
						},
						{ header: "檢核結果", key: "CHK_MSG" , attrs:{rowSpan:2}},
						{ header: "修改後_公告列管", key: "A_IS_CONTROL_NM" ,
							render : function(rec ,val){
								return val + (rec.A_IS_CONTROL ? '('+rec.A_IS_CONTROL+')':'');
							}
						},
						{ header: "修改後_特殊屋況分級", key: "A_CATEGORY_NM" ,
							render : function(rec ,val){
								return val + (rec.A_CATEGORY ? '('+rec.A_CATEGORY+')':'');
							}
						}
					]
				});	

				<%-- 初始「按鈕Observe Listener」--%>
				actions.initObserve();

				<%-- (先作)按鈕授權 --%>
				buttonAuth();
				<%-- (再作)按鈕控制 --%>
				actions.btnCtrl();

				<%-- 顯示底部訊息 --%>
				displayMessage();
			}                 
		}
	}
</script>
</head>

<body>
    <form id="form1" name="form1" method="post" target="importFrame" enctype="multipart/form-data">
		<%------------------------- 【查詢區】 -------------------------%>
        <table id="tableA" class="tbBox2" cellspacing="1" width="100%" border="0">
			<tr>
				<td class="tbYellow">上傳檔案<span style="color:red;">*</span></td>
				<td class="tbYellow2" >
					<input id="INPUT_FILE" name="INPUT_FILE" type="file" class="file" size="50" title="上傳檔案" fieldName="上傳檔案" /><br>
					<span>檔案格式(含表頭)：編號,門牌地址,公告列管,特殊屋況分級</span>
				</td>
			</tr>
			
			<tr>
				<td align="center" colspan="2">
					<button id="btn_upload" name="btn_upload" type="button" class="button" >上傳</button>
					<button id="btn_import" name="btn_import" type="button" class="button"  >匯入</button>
                </td>
            </tr>
        </table>
		<%------------------------- 【上傳結果區】 -------------------------%>
		<table id="grid" class="grid"></table>
    </form>
	<%-- 匯入檔案時，模擬Ajax的效果 --%>
	<iframe id="importFrame" name="importFrame" height="0" size="10" style="display:none"></iframe>
</body>
</html>