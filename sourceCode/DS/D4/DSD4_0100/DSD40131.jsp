<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<%--
程式：DSD40131.jsp
功能：補發附件上傳
作者：廖哲祥
完成：2021-05-24

[20230411]問題單20230327162907
調整畫面版面
郭曉慧
 --%>
 
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
	
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>

<script type='text/javascript'>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSD40131().initApp);
	
function DSD40131(){
	var grid;
	var cover;
	
	<%--CoverPage(鎖定/開放畫面)--%>
	var auxiliary = {
		createCoverPage:function(){
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		closeCoverPage: function(){
			cover.hide();
		}
	};
	
	var actions = {
		initTableUI: function(){
			<%--[20230412]上傳區塊改用tableUI--%>
			grid = new TableUI({
				table: $('grid'),
				pageSize: 0,
				headerColumn: [{header:'清償補發應備文件', attrs:{colSpan: 2} }],
				column:[
					{key: 'FILE_KIND_NM', attrs:{align:'left'},
						render: function(rec, val, sn) {
							if(rec.FILE_KIND != 'E'){
								return val;
							}
							var span = new Element('span').update(val+'【說明】：');
							var input = new Element('input', {type: 'text', id: 'FILE_COMMENT', name: 'FILE_COMMENT'
								, className: "textBox2", size: 30});
							return new Element('div').insert(span).insert(input);
						}
					},
					{key: 'FILE_KIND',
						render: function(rec, val, sn) {
							var input = new Element('input', {type: 'file', id: 'uploadFile'+val, name: val
								, className: "textBox2", size: 50, capture: "environment", accept: "image/*"});
							input.observe('change', buttons.doPreviewImg);
							var button = new Element('button', {type: 'button', id: 'uploadBtn'+sn, FILE_KIND: val
								, className: "button"}).update('確認');
							button.observe('click', buttons.doUpload);
							return new Element('div', {style: 'text-align: left'}).insert(input).insert(button);
						}
					}
				]
			});
		}
	};
	
	var buttons = {
		doPreviewImg: function(){
			<%--[20230412]預覽--%>
			var fileData = $(this).files;
			var reader = new FileReader();
			reader.onload = function(event){
				$('previewImg').src = event.target.result;
			};
			reader.readAsDataURL(fileData[0]);
			$('previewImg_div').show();
		},
		doUpload : function() {
			var fileInput = $(this).up('td').select('input[type=file]')[0];
			if(!fileInput.getValue()){
				alert('請先選擇上傳資料再執行!');
				return;
			}
			$('FILE_KIND').setValue($(this).readAttribute('FILE_KIND'));
			if($F('FILE_KIND') == 'E'){
				if(!$(this).up('tr').select('input[type=text]')[0].getValue()){
					alert('請輸入該文件檔名!');
					return;
				}
			}
			auxiliary.createCoverPage();	
			var form = $('form');			
			submitOnce(form);	
		},
		doReloadImport: function(){ <%-- 上傳完畢後執行 --%>
			var key = this.getAttribute("data-key");
			var importFrame = $('importFrame');
			var idoc = importFrame.contentDocument.getElementById('filedata');
			if(!idoc){
				return;
			}
			auxiliary.closeCoverPage();
			<%--顯示訊息--%>
			var json = idoc.innerHTML.evalJSON();
			var Msg = json.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				alert(Msg);
			}
			<%--[20230412]上傳成功清除畫面--%>
			if(json.ErrMsg.returnCode == 0){
				$('previewImg').src = '';
				$('previewImg_div').hide();
				grid.reload();
			}
		}
	};
	
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement('DSD40131' ,'清償作業' ,'補發附件上傳' ,1 );

			$('importFrame').observe('load', buttons.doReloadImport);
			$('previewImg_div').hide();
			
			
			var FILE_KIND_List = <c:out value="${FILE_KIND_List}" default="[]" escapeXml="false" />;
			actions.initTableUI();
			grid.load(FILE_KIND_List);
			$('REFER_ID').setValue('${REFER_ID}');
			$('APPLY_DATE').setValue('${APPLY_DATE}');
			
			
			displayMessage();
		}
	};	
}
</script>
</head>
<body>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	    <tr>
            <td width="30%" class="tbYellow">原貸帳號</td>
            <td width="70%" class="tbYellow3" colspan=1>${REFER_ID}</td>
        </tr>
    </table>
    <form id="form" name="form" method="post" target="importFrame" enctype="multipart/form-data" action="${dispatcher}/DSD4_0131/upload">
        <table id='grid'></table>
        <input id="REFER_ID" name="REFER_ID" type="hidden"/> 
        <input id="APPLY_DATE" name="APPLY_DATE" type="hidden"/> 
        <input id="FILE_KIND" name="FILE_KIND" type="hidden"/> 
	    <div id="previewImg_div" style='text-align: center' class="tbYellow3"><img id="previewImg" width="700px"/></div>
	    <iframe id="importFrame" class="iframe_upload" name="importFrame" width="0" height="0" style="display: none;"></iframe>
	 </form>
</body>
</html>