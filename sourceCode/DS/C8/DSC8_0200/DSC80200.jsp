<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSC80200.jsp
功能：通訊地址變更
作者：林秉宏
完成：2013/07/15

[20180529]修改件
作業畫面揭露借款戶所有帳號,並可全選或勾選指定帳號,一次動作完成變更
[20180625]修改件
調整set地址資訊方式,改用DSZ01000.js方法

[20230317] 修改程式  楊青峰
難字調整
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230317] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>
 
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type="text/JavaScript" src="${htmlBase}/DS/js/DSZ01000.js"></script>	   <%-- 地址用 --%>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC80200().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC80200(){
		var grid1;
		var valid1;
		var valid2;
		var address;
	
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0054 : 'BTN_change'		<%--變更--%>		
			};
			<dz:grantButtons FUNC_ID='DSC80200'/>
		};		

		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			Validation.addAllThese( [
				[ 'chkHalfType', '地址請輸入全型字!', function() { 
					return validation.chkHalfType($F('CON_ADDR'));
				}],
				[ 'chkUsableID', '借款人ID格式錯誤!', function(){
					var ID = $F('BORROW_ID');
					if(!ID.blank()){
						if(validation.checkUniSN(ID) || validation.checkROCID(ID) || validation.checkROCARC(ID)) { 
							return true;
						}
						return false;
					}
					return false;
				}]	
			]);
			
			valid1.define( "chkHalfType" , [{ id : "CON_ADDR" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			valid2.define( "chkUsableID" , [{ id : "BORROW_ID"} ] );
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '${dispatcher}/DSC8_0200/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};	
	
		var actions = {
		
			// 查詢
			doQuery: function(){
			
				$('BORROW_NAME').update('');
				grid1.clear();
				//20180625:調整set地址資訊方式,改用DSZ01000.js方法
				address.setCITY_NAME('');			
							
				valid2.reset();				
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}
				//[20180529]修改件
				//查詢條件改變且回傳值變多筆
				// 頁面傳入參數
				ajaxPost( 'query' , { 'BORROW_ID' : $F('BORROW_ID') },
					function(resp){	
						var rtnList = resp.rtnList;
						grid1.load(rtnList || []);
						if(rtnList && rtnList.length > 0){
							$('BORROW_NAME').update(rtnList[0].BORROW_NAME);
						}
					}
				);	
			},
			
			// 變更
			doChange: function(){
				
				var checkedRecs =  grid1.getCheckedRecords(['LOAN_ID']);
				if(!checkedRecs || checkedRecs.length == 0){
					alert('無查詢資料或被選取資料，無法變更!');
					return;
				}
				
				//[20180530]修改件
				//比較的欄位由LOAN_ID改成BORROW_ID
				var BORROW_ID = $F('BORROW_ID');
				var BORROW_ID_OLD = grid1.getCheckedRecords()[0].BORROW_ID;		
				if(BORROW_ID != BORROW_ID_OLD){
					alert("欲變更的借款人ID:"+BORROW_ID+"與原先查詢的借款人ID:"+BORROW_ID_OLD+"不同，無法作業!!");
					return;
				}
				
				valid1.clear();
				if(!valid1.validate()){
					return;
				}
				
				//[20180530]修改件
				//呼叫doChange多傳一個參數，grid勾選清單
				
				// 頁面傳入參數
				ajaxPost( 'change' , { 'info' : Object.toJSON(reqMap()), 'dataList': Object.toJSON(checkedRecs)},
					function(resp){	
						var rtnList = resp.rtnList;
						grid1.load(rtnList || []);
						if(rtnList && rtnList.length > 0){
							$('BORROW_NAME').update(rtnList[0].BORROW_NAME);
						}
						//20180625:調整set地址資訊方式,改用DSZ01000.js方法
						address.setCITY_NAME('');			
					}
				);	
			},
			//[20180529]修改件
			//勾選原資料連動下面新通訊地址
			chgNewAddrInfo: function(){ 
				var checkedRecs =  grid1.getCheckedRecords();
				if(!checkedRecs || checkedRecs.length == 0){
					address.setCITY_NAME('');
					return;
				}
				//20180625:調整set地址資訊方式,改用DSZ01000.js方法
				address.setINPUT_ZIPCODE(checkedRecs[0].CON_ZIP || '');
				address.setINPUT_ADDR(checkedRecs[0].CON_ADDR || '');
				parseEUDC("ap");
			}
		};
		
		// 產生回傳資料
		var reqMap = function(){
		
			var reqMap = {};

			var reqMap = {
				CON_ADDR : address.getINPUT_ADDR(),
				CON_ZIP : address.getINPUT_ZIPCODE(),
				BORROW_ID : $F('BORROW_ID')
			}
			
			return reqMap;			
		};

		return {
			
			initApp : function() {
				PageUI.createPageWithAllBodySubElement('DSC80200', '變更作業', '通訊地址變更');			
					
				grid1 = new TableUI({
					table: $('grid1'),
					autoCheckBox:{
						isSelectAll: function(){
							actions.chgNewAddrInfo();
						},
						action: function( node, boxStatus, records){
							actions.chgNewAddrInfo();
						} 
					},
					allSortable:true, 
					overDiv:false,
					pageSize:0,
					column: [
						{header: '貸款帳號' , key : 'LOAN_ID'},
						{header: '原貸帳號' , key : 'REFER_ID'},
						{header: '基本通訊資料' , key : 'CON_ADDR',
							render: function(rec, val, sn){
								return rec.CON_ZIP + val;
							}
						}
					]
				});

					
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
					
				// 變更
				$('BTN_change').observe('click', actions.doChange);
				
				$('BORROW_ID').observe('blur', function(){
					$('BORROW_ID').setValue($F('BORROW_ID').toUpperCase());
				});
	
				// 產生地址選擇器
				address = new DSZ01000($('DSC80200'), "1");	
				
				initValidation();	

				buttonAuth();	
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

</script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='15%'>借款人ID</td>
		<td class="tbYellow2" width="65%">
			<input id="BORROW_ID" name="BORROW_ID" type="text" onblur="this.value = this.value.toUpperCase()" class="textBox2" size="14" maxlength="10"/>
		</td>
		<td class="tbYellow2" width="20%" align='center'>
			<input id="BTN_query" name="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_change" name="BTN_change" type="button" value="變更" class="button"> 
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center" >原通訊地址</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center">
			姓名
		</td>
		<td class="tbYellow2" width="85%">
			<span id="BORROW_NAME" name="BORROW_NAME" style="font-family: 'EUDC'"></span> <%-- [20230317] --%>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<table id="grid1" width="100%" class="grid"></table>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center">
			變更後通訊地址
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center" rowspan="2">
			新通訊地址
		</td>
		<td class="tbYellow2" width ="85%" id ="DSC80200" name="DSC80200"></td>	
	</tr>
</table>

</form>		
</body>
</html>