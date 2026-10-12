<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<%--
程式：DSD40132.jsp
功能：補發附件查詢
作者：廖哲祥
完成：2021-05-19
 --%>
 
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
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
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ImageUtil.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>	

<script type='text/javascript'>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSD40132().initApp);

function DSD40132(){
	var AUTH_TYPE = '${AUTH_TYPE}'; //1是內網 2是外網
	var D060Map;
	var grid;
	
	<%-- 按鈕權限 --%>	
	var authButtons = {
		B0064 : 'BTN_imageUpload',	<%--影像上傳--%>
		B0252 : 'BTN_reissue',		<%--補發申請書--%>
		B0159 : [],	<%--檢視--%>
		B0077 : [] <%--刪除--%>
	};
		
	var buttonAuth = function() {
		<dz:grantButtons FUNC_ID='DSD40132'/>
	}
	
	<%-- TablE UI物件 --%>	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_0132/');

    <%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
    function englishToUpperCase() {
    	this.value = this.value.toUpperCase();
    }
    
	var buttons = {
		<%--[20230327163211][20230329]查詢--%>
		doQuery : function(){
			ajaxRequest.post('query', {reqMap: Object.toJSON({'REFER_ID': $F('REFER_ID')})},
				function(resp){
					D060Map = resp.D060Map || {};
					$('APPLY_DATE').setValue(D060Map.REMIT_DATE||'${APPLY_DATE}');
					grid.load(resp.FILE_NAME_LIST || []);
					buttons.doClear();
				},function(resp){
					D060Map = resp.D060Map || {};
					$('APPLY_DATE').setValue(D060Map.REMIT_DATE||'${APPLY_DATE}');
					grid.load([]);
					buttons.doClear();
				}
			)
		},
		<%--[20230327163211][20230329]影像上傳--%>
		doImageUpload: function() {
			ajaxRequest.post('imageUpload', {D060Map: Object.toJSON(D060Map)},
					function(resp){
						popupWin.popup({
							src: '${dispatcher}/DSD4_0131/prompt',
							scrolling : 'yes',
							parameters: { 
								REFER_ID: $F('REFER_ID'),
								APPLY_DATE:$F('APPLY_DATE')
							},
							onclose: function(){
								buttons.doQuery();
							}
						});
					}
				)
		},
		<%--[20230327163211][20230329]補發申請書--%>
		doReissue: function(){
			ajaxRequest.post('reissue', {REFER_ID: $F('REFER_ID'),APPLY_DATE:$F('APPLY_DATE')},
					function(resp){
						popupWin.popup({
							src: '${dispatcher}/DSD4_0130/prompt',
							scrolling : 'no',
							width: '95%',
							parameters: {
								REFER_ID: $F('REFER_ID'), // 原貸帳號,
								APPLY_DATE:$F('APPLY_DATE'),
								APPLYMAN_NAME: D060Map.APPLYMAN_NAME, // 申請人姓名
								APPLYMAN_ID: D060Map.APPLYMAN_ID, // 身分證字號
								APPLYMAN_ADD: D060Map.APPLYMAN_ADD, // 住址
								APPLYMAN_TEL: D060Map.APPLYMAN_TEL // 電話
							},
							onclose: function(){
								buttons.doQuery();
							}
						});
					}
				)
		},
		<%-- [20230410] 清空 --%>
		doClear : function() {
			$('imageName').update('');
			$('imageTd').update('');
		},
		authAgain : function() {
			$$('#grid button[type=button]').each(function(obj) {
				if (obj.innerHTML == '檢視') {
					authButtons.B0159.push(obj.id);
				} else if (obj.innerHTML == '刪除') {
					authButtons.B0077.push(obj.id);
				}
			});
			buttonAuth();
		},
		doView : function(FILE_ID, FILE_NAME){
			var FILE_TYPE = FILE_NAME.split('.')[1];
			if('pdf' == FILE_TYPE.toLowerCase()){
				RPTUtil.downloadFile('${dispatcher}/DSD4_0132/download', 
						{ 'FILE_ID': FILE_ID, 'FILE_NAME': FILE_NAME}, false);
			} else {
				ajaxRequest.post('showImage', {'FILE_ID': FILE_ID, 'FILE_NAME': FILE_NAME},
					function(resp){
						document.getElementById("imageName").innerHTML = FILE_NAME;
						var IMAGE = new Element('DIV', { width:'100%',id:'image',name:'PIC'});
						$('imageTd').insert(IMAGE);
						var FILE_PATH = resp.filePath;
						if(FILE_PATH){
							ImageUtil.showImage({
								imagePath : FILE_PATH
								,showImageDivId : 'image'
								,imageWidth : '700px'
								,imageHeight : '100%'
							});	
						}
				});
			}
		},
		doDelete : function(FILE_ID, ORG_FILE_NM){
			if(!confirm('確認刪除【'+ORG_FILE_NM+'】?')){
				return;
			}
			
			ajaxRequest.post('delete', {'FILE_ID': FILE_ID, 'REFER_ID': $F('REFER_ID')}, function(resp) {
				grid.load(resp.FILE_NAME_LIST || []);
				buttons.doClear();
			});
		}
	};
	
	return {
		initApp : function() {

			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>
			PageUI.createPageWithAllBodySubElement('DSD40132' ,'清償作業' ,'補發附件查詢' ,1 );

			buttonAuth();
			
			grid = new TableUI({
				table: 'grid',
				pageSize: 20,
				pageChange : buttons.authAgain,
				afterLoad : buttons.authAgain,
				column:[
					{header: '補發申請日', key: 'REMARK', sortRule: 'date'},
					{header: '檔案類型', key: 'FILE_KIND_NM', attrs:{align:'left'}},
					{header: '檔案序號', key: 'FILE_ID'},
					{header: '檔案名稱', key: 'ORG_FILE_NM', attrs:{align:'left'}},
					{header: '檢視', key: 'view',
						render: function(rec, val, sn){
							if(D060Map.FINAL_CHECK != '1'){
								var FILE_NAME = rec.ORG_FILE_NM;
								if(!FILE_NAME){
									return '';
								} else {
									var button = new Element('button',{'id':'btn_grid1View' + sn, 'type' : 'button' , 'class' : 'button' }).update("檢視");
									button.observe('click', function(){
										buttons.doView(rec.FILE_ID,FILE_NAME);
									});
									if(AUTH_TYPE != '1'){
										button.disable();
									}
		                			return button;
								}
							} else {
								return '';
							}
						 }	
					},
					{header: '刪除', key: 'delete',
						render: function(rec, val, sn){
							if(rec.REMARK == $F('APPLY_DATE') && D060Map.FINAL_CHECK != '1'){
								var button = new Element('button',{'id':'btn_grid2Del' + sn, 'type' : 'button' , 'class' : 'button' }).update("刪除");
								button.observe('click', function(){
									buttons.doDelete(rec.FILE_ID,rec.ORG_FILE_NM);
								});
								if(AUTH_TYPE != '1' || D060Map.D060_CK == '1'){
									button.disable();
								}
	                			return button;
							} else {
								return '';
							}
						 }
					}
				]
			});
			
			$('BTN_query').observe('click', buttons.doQuery);
			$('BTN_imageUpload').observe('click', buttons.doImageUpload);
			$('BTN_reissue').observe('click', buttons.doReissue);
			<%-- [20230410] --%>
			$('btn_clear').observe('click', buttons.doClear);

			<%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
			$('REFER_ID').observe('change', englishToUpperCase);
			
			if('${REFER_ID}' && '${REFER_ID}' !=''){
				<%--初始查詢--%>
				buttons.doQuery();
			}
			
			displayMessage();
		}
	};	
}	

</script>
</head>
<body>
<form name="form1" id="form1">
	<table id='table1' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	    <tr>
            <td width="20%" class="tbYellow">原貸帳號</td>
            <td width="60%" class="tbYellow2">
            	<input type="text" class="textBox2" size="14"  maxlength="10"  id="REFER_ID" value="${REFER_ID}">
            	<input type="hidden"  id="APPLY_DATE"  value="${APPLY_DATE}">
            </td>
            <td width="20%" class="tbYellow2" align="center">
            	<button type="button" class="button" id="BTN_query">查詢</button>
            </td>
        </tr>
        <tr>
        	<td class="tbYellow" colspan="3" align="center">
        		<button type="button" class="button" id="BTN_imageUpload">影像上傳</button>
        		<button type="button" class="button" id="BTN_reissue">電子補發申請書</button>
        	</td>
        </tr>
    </table>
	<table id='grid'></table>
	<table id='table1' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">      	
		<%-- [20230410] 增加清空按鈕 --%>
		<tr>
			<td style="text-align:center;">
				<button type="button" id="btn_clear" class="button">清空</button>
			</td>
		</tr>
		<tr> 
			<td width="100%" bgcolor="white" id = 'imageName'></td>						
		</tr>	
		<tr> 				
			<td width="100%" bgcolor="white" align="center" id = 'imageTd' ></td>	
		</tr>			
	</table>	
</form>
</body>
</html>