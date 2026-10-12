<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>

<!--
程式：DSC23600.jsp
功能：沖暫收匯款作業
作者：i93006iisi10 許凱傑
完成：2020/08/19
[20200826/20200825111934/曾柏勳] 移除checkBox, C區呈現第一筆資料, Insert改為全部insert
-->

<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<!-- 目前系統常用的表格工具 -->
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/InputUtility.js"></script> 
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<%-- [20241104]難字 css --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight: normal;
		font-style: normal
	}
</style>
<script type='text/javascript'>

<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSC23600().initApp);

function DSC23600(){

	var grid;
	var validQuery, validInsert, validUpdate;
	var validAction = {
		// 欄位檢核
		init: function(){ <%--整批產生部位移轉單 匯入--%>
		
			validQuery = new Validation('form1', {focusOnError:true, immediate:false});	
 			validQuery.define( "required" , { id : "LOAN_ID", errMsg:'請輸入貸款帳號'} );
			
			validInsert = new Validation('form1', {focusOnError:true, immediate:false});

			validInsert.define( "required" , { id : "REMIT_DATE_C", errMsg:'請輸入匯款日期'} );
			
			validInsert.define( "required" , { id : "REMIT_KIND", errMsg:'請輸入匯款種類'} );
			validInsert.define( "required" , { id : "BANK", errMsg:'請輸入銀行代號'} );
			validInsert.define( "required" , { id : "BRANCH", errMsg:'請輸入分行代號'} );
			validInsert.define( "required" , { id : "ACCOUNT", errMsg:'請輸入匯款帳號'} );
			validInsert.define( "validate-MM_ACCOUNT" , { id : "ACCOUNT"} );
			validInsert.define( "required" , { id : "ACCOUNT_ID", errMsg:'請輸入匯款戶ID'} );
			validInsert.define( "required" , { id : "ACCOUNT_NAME", errMsg:'請輸入匯款戶名'} );
			validInsert.define( "required" , { id : "IS_CONTRACT", errMsg:'請輸入受款人是否為契約利害關係人'} );
			//[20200826] DB新增匯款總額
			//validInsert.define( "hasFullType" , { id : "ACCOUNT_ID", errMsg:'匯款戶ID請輸入全形'} );
			validInsert.define( "validateInteger" , { id : "BALC_AMT", errMsg:'匯款金額大於0'} );
				
		},
		reset : function(){
			validQuery.reset();
			validInsert.reset();
		}
	};
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC2_3600/');	

	var actions = {
		
		getReqMap : function (){
			var sendRecord = {};
			var strTemp = 'BORROW_ID LOAN_ID REMIT_DATE REMIT_KIND BANK BRANCH ACCOUNT ACCOUNT_ID BALC_AMT ACCOUNT_NAME ACCOUNT_NAME_RM IS_CONTRACT COUNTRY ACPT_NAME_COUNTRY MEMO REMIT_PROCESS INPUT_ID';		
			$w(strTemp).each ( function (id) {
				sendRecord[id] = $F(id);
			} );
            return sendRecord;
        },
			//[20200826] insert改為list
        getList : function(records){
        	var strTemp = 'REMIT_KIND BANK BRANCH ACCOUNT ACCOUNT_ID BALC_AMT ACCOUNT_NAME ACCOUNT_NAME_RM '
    			+ 'IS_CONTRACT COUNTRY ACPT_NAME_COUNTRY MEMO';         	
        	for(var i=0;i<records.length;++i){
    			$w(strTemp).each ( function (id) {
    				records[i][id] = $F(id);
    			} );
    			records[i]['REMIT_DATE'] = $F('REMIT_DATE_C');
    			records[i]['REMIT_AMT'] = records[i]['REMAIN_AMT'];
        	}
        	return records;
        },
    		//[20200826] 要帶出第一筆資料塞C區
        setPageValue : function(rtnList){
			grid.load(rtnList);
			var rtnData = {};
			if( rtnList.length > 0 ){
				rtnData = rtnList[0];
			}
			
			<%--計算總和--%>
        	var records = grid.getAllRecords() ;
       		var temp = 0;
       		for(var i=0;i<records.length;++i){
       			temp = temp + records[i]['REMAIN_AMT']; 
       		}
       		$('REMIT_AMTspan').update(temp);
       		$('BALC_AMT').setValue(temp);
       		
       		<%--設定參數--%>
       		//$('REMIT_KIND').setValue(rtnData['REMIT_KIND'] || '' );
       		$('REMIT_DATE_C').setValue(rtnData['REMIT_DATE'] || '' );
       		$('BANK').setValue(rtnData['BANK'] || '' );
       		$('BRANCH').setValue(rtnData['BRANCH'] || '' );
       		$('ACCOUNT').setValue(rtnData['ACCOUNT'] || '' );
       		$('ACCOUNT_ID').setValue(rtnData['ACCOUNT_ID'] || '' );
       		$('ACCOUNT_NAME').setValue(rtnData['ACCOUNT_NAME'] || '' );
       		$('ACCOUNT_NAME_RM').setValue(rtnData['ACCOUNT_NAME_RM'] || '' );
       		$('ORIG_ACCOUNT_ID').setValue(rtnData['ACCOUNT_ID'] || '' );
       		$('IS_CONTRACT').setValue(rtnData['IS_CONTRACT'] || '' );
       		$('COUNTRY').setValue(rtnData['COUNTRY'] || 'TW' );
       		$('ACPT_NAME_COUNTRY').setValue(rtnData['ACPT_NAME_COUNTRY'] || 'TW' );
       		$('MEMO').setValue(rtnData['MEMO'] || '' );
			$('REMIT_PROCESS').setValue(rtnData['REMIT_PROCESS'] || '' );
			$('INPUT_ID').setValue(rtnData['B201_INPUT_ID'] || '');
			
        },
		// AJAX完成後，頁面處理(新增)
		returnDataHandler4Insert: function(resp){
			var checkMoneyLaunderMsg = resp.checkMoneyLaunderMsg;
			var CHK_ID = resp.CHK_ID; //洗錢防制檢核紀錄畫面傳入ID
			if (checkMoneyLaunderMsg) {
				alert(checkMoneyLaunderMsg);
				if (CHK_ID) {
                    //190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
					var parms = { 
						'QUERY_ID' : CHK_ID,
						'QUERY_START_DATE' : resp.CURRENT_DATE,
						'QUERY_END_DATE' : resp.CURRENT_DATE
					}; 		
					actions.doPopupWin(parms);	
				}	
			} else {
				actions.setPageValue(resp.rtnList || []);
			}
		},
		//開啟新視窗(洗錢防制檢核紀錄)
	  	doPopupWin:function(parms){			
			popupWin.popup({
				'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
				'parameters' :  {
					'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
				}
			});
	  	},

	};
	
	var buttons = {
		
		doQuery : function(){
			validAction.reset();
			if( !validQuery.validate() ){
				return;
			}
			ajaxRequest.post('query', { reqMap : Object.toJSON(actions.getReqMap()) },
				function(resp){
    	       	    //[20200826] 要帶出第一筆資料塞C區							
					actions.setPageValue(resp.rtnList || []);
				},
				function(resp){
					grid.load([]);
					$('REMIT_AMTspan').update('');
					$('BALC_AMT').setValue('');
					
					<%--清空參數--%>
					var str = "REMIT_KIND REMIT_DATE_C BANK BRANCH ORIG_ACCOUNT_ID ACCOUNT ACCOUNT_ID ACCOUNT_NAME ACCOUNT_NAME_RM IS_CONTRACT COUNTRY ACPT_NAME_COUNTRY MEMO REMIT_PROCESS INPUT_ID";
					
					$w(str).each ( function (id) {
						$(id).setValue('');
					} );

				}
			);			
		},
		doInsert : function(){
			validAction.reset();
    	       	    //[20200826] 移除checkbox
 			var records = grid.getAllRecords() ;
			if ( records.length == 0 ) {
				alert('請先查得資料');
				return;
			}
			if ( (records[0]['NEW_LOAN_ID'] || '' ) != '' ) {
				alert('資料已新增');
				return;
			}			
			if( !validInsert.validate() ){
				return ;
			}
			var ORIG_ACCOUNT_ID = $F('ORIG_ACCOUNT_ID');
			if(ORIG_ACCOUNT_ID){
				if($F('ACCOUNT_ID') != ORIG_ACCOUNT_ID){
					if(!confirm("借款人ID與匯款戶ID不相同，是否繼續?")){
						return;
					}
				}
			}
			ajaxRequest.post('insert', { reqMap : Object.toJSON(actions.getReqMap()),
			     reqList : Object.toJSON(actions.getList(records))
							   },
			function(resp){
				actions.returnDataHandler4Insert(resp);
				//actions.setPageValue(resp.rtnList || []);					
				}
			);		
		},
		doDelete : function(){
			validAction.reset();			
 			var records = grid.getAllRecords() ;
			if ( records.length == 0 ) {
				alert('請先查得資料');
				return;
			}		
			if ( (records[0]['NEW_LOAN_ID'] || '' ) == '' ) {
				alert('請先新增資料');
				return;
			}					
			if ( !confirm('是否要刪除') ) {
				return;
			}	
			if($F('ACCOUNT_ID') != $F('ORIG_ACCOUNT_ID')){
				if(!confirm("借款人ID與匯款戶ID不相同，是否繼續?")){
					return;
				}
			}
			
			ajaxRequest.post('delete', { reqMap : Object.toJSON(actions.getReqMap() ),
			     ListA : Object.toJSON(records)
				},
			function(resp){
				actions.setPageValue(resp.rtnList || []);						
				}
			);
			
		},		
		doUpdate : function(){
			validAction.reset();			
 			var records = grid.getAllRecords() ;
			if( !validInsert.validate() ){
				return ;
			}	
			if ( records.length == 0 ) {
				alert('請先查得資料');
				return;
			}	
			if ( (records[0]['NEW_LOAN_ID'] || '' ) == '' ) {
				alert('請先新增資料');
				return;
			}			
			if($F('ACCOUNT_ID') != $F('ORIG_ACCOUNT_ID')){
				if(!confirm("借款人ID與匯款戶ID不相同，是否繼續?")){
					return;
				}
			} 
				
			ajaxRequest.post('update', { reqMap : Object.toJSON(actions.getReqMap() ),
			     ListA : Object.toJSON(actions.getList(records))
					},
					function(resp){
						actions.setPageValue(resp.rtnList || []);						
					}
			);

		},
		doConfirm : function(){
			validAction.reset();			
 			var records = grid.getAllRecords() ;
			if( !validInsert.validate() ){
				return ;
			}
			
			if($F('ACCOUNT_ID') != $F('ORIG_ACCOUNT_ID')){
				if(!confirm("借款人ID與匯款戶ID不相同，是否繼續?")){
					return;
				}	
			} 
			ajaxRequest.post('confirm', { reqMap : Object.toJSON(actions.getReqMap() ),
				  ListA : Object.toJSON(records) } );	
		
		}
	};	
	
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' dateFields='REMIT_DATE REMIT_DATE_C' var='localeDisplay' />
						
			PageUI.createPageWithAllBodySubElement(
				'DSC23600',
				'帳戶',
				'沖暫收匯款作業'
			);

			grid = new TableUI({
				table : $('grid'),
				title : '匯款資料',				
				pageSize : 10,
				allSortable : true,
				column : [
					//{ header : '借款人ID', key : 'C100_BORROW_ID' },
					{ header : '暫收款編號', key : 'C140_BALC_NO' },
					{ header : '貸款帳號', key : 'C140_LOAN_ID' },
					{ header : '暫收實繳日', key : 'REAL_PAYDT' , sortRule:'date'},
					{ header : '匯款戶名', key : 'ACCOUNT_NAME' },
					{ header : '匯款戶名(羅馬拼音)', key : 'ACCOUNT_NAME_RM' },
					{ header : '暫應收金額', key : 'REMAIN_AMT', sortRule:'number' }
				]	
			});			
			Validation.addAllThese([
			['validate-MM_ACCOUNT', '匯款帳號必需為16碼.', function(value) {
				if( value != "" && value.length != 16  ){
					return false;
				}
				return true;
			}]
			
			]);
			
			validAction.init();
    	       	    //[20200826]調整接值
			var rtnData = <c:out value='${rtnData}' default="[]" escapeXml="false" />;
			actions.setPageValue(rtnData);
 			
  			$('BTN_QUERY').observe('click', buttons.doQuery); 
 			$('BTN_INSERT').observe('click', buttons.doInsert); 
 			$('BTN_DELETE').observe('click', buttons.doDelete); 
 			$('BTN_UPDATE').observe('click', buttons.doUpdate);
 			$('BTN_CONFIRM').observe('click', buttons.doConfirm);
 			
			
			//匯款種類新增「沖暫收款」，設為不可更改
			$('REMIT_KIND').setValue('3');
			$('REMIT_KIND').disabled = true;
			$('REMIT_DATE_C').disabled = true;
			
			//國家預設中華民國
			$('COUNTRY').setValue('TW');
			$('ACPT_NAME_COUNTRY').setValue('TW');
			
			displayMessage();			
		}
	};	
}
	
</script>
</head>
<body>
<form name="form1" id="form1"  target="importFrame"  method="POST" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px"  enctype="multipart/form-data">

	<table id="queryTable" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow">借款人ID</td>
			<td class="tbYellow2"><input id="BORROW_ID" name="BORROW_ID" type="text" size="22" maxlength="11" class="textBox2"  /></td>
			<td class="tbYellow">貸款帳號</td>
			<td class="tbYellow2"><input id="LOAN_ID" name="LOAN_ID" type="text" size="22" maxlength="10" class="textBox2"  /></td>
			<td class="tbYellow">匯款日期</td>
			<td class="tbYellow2"><input id="REMIT_DATE" name="REMIT_DATE" type="text" size="22" maxlength="20" class="textBox2"  /></td>
			<td class="tbYellow2" width="1%"><button id="BTN_QUERY" title="查詢" type="button" class="button">查詢</button></td>
		</tr>
		<tr>
			<td colspan="7" align="center">
			<button id="BTN_INSERT" title="新增" type="button" class="button">新增</button>
			<button id="BTN_DELETE" title="刪除" type="button" class="button">刪除</button>
			<button id="BTN_UPDATE" title="修改" type="button" class="button">修改</button>
			<button id="BTN_CONFIRM" title="確認" type="button" class="button">確認</button>
			</td>
		</tr>
	</table>
	<table id='grid'>
	</table>	
	
<!-- 	<input id="BALC_NO" name="BALC_NO" type="hidden" class="textBox2" title="暫應收編號" /> -->
	<input id="BALC_NO" name="BALC_NO" type="hidden" class="textBox2" title="暫應收編號" />
	<input id="REMIT_PROCESS" name="REMIT_PROCESS" type="hidden" class="textBox2" title="匯款作業進度" />
	<input id="CHECK_GROUP" name="CHECK_GROUP" type="hidden" class="textBox2" title="交易組號" />
	<input id="INPUT_ID" name="INPUT_ID" type="hidden" class="textBox2" title="輸入人員ID" />
	<table id="tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td bgcolor="#DEC87C" width="100%" colspan="6" align="center" >
				<span>匯款明細</span>
			</td>
		</tr>
		<tr>
			<td class="tbYellow">匯款種類</td>
			<td class="tbYellow2">				
				<select class="textBox2" name="REMIT_KIND" id ="REMIT_KIND">
					<option value="">請選擇</option>
					<c:forEach var="row" items="${REMIT_KIND_LIST}"><option value="${row.key}">${row.value}</option></c:forEach>					
				</select>
			</td>
			<td class="tbYellow">匯款日期</td>
			<td class="tbYellow2"><input id="REMIT_DATE_C" name="REMIT_DATE_C" type="text" size="22" maxlength="20" class="textBox2"  /></td>
			<td class="tbYellow">匯款金額</td>
			<td class="tbYellow2" colspan="">
				<span id="REMIT_AMTspan"></span>
				<input id="BALC_AMT" name="BALC_AMT" type="hidden" size="22" maxlength="20" class="textBox2"  />
			</td>
		</tr>				
		<tr>
			<td class="tbYellow" rowspan="2">匯款帳號</td>
			
			<td class="tbYellow2" rowspan="2">				
				<input id="BANK" name="BANK" type="text" class="textBox2" size="4" maxlength="3" value="" title="銀行代號">
				<input id="BRANCH" name="BRANCH" type="text" class="textBox2" size="5" maxlength="4" value="" title="分行代號">
				<input id="ACCOUNT" name="ACCOUNT" type="text" class="textBox2" size="20" maxlength="16" value="" title="匯款帳號">
			</td>
			<td class="tbYellow" rowspan="2">匯款戶ID</td>
			<td class="tbYellow2" rowspan="2">
				<input id="ACCOUNT_ID" name="ACCOUNT_ID" type="text" size="22" maxlength="10" class="textBox2"  />
				<input id="ORIG_ACCOUNT_ID" name="ORIG_ACCOUNT_ID" type="hidden" size="22" maxlength="10" class="textBox2"  />
			</td>
			<td class="tbYellow">匯款戶名</td>
			<td class="tbYellow2">
				<input id="ACCOUNT_NAME" name="ACCOUNT_NAME" type="text" size="22" maxlength="20" class="textBox2" alt="ch" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow">匯款戶名(羅馬拼音)</td>
			<td class="tbYellow2">
				<input id="ACCOUNT_NAME_RM" name="ACCOUNT_NAME_RM" type="text" size="22" maxlength="20" class="textBox2" placeholder="羅馬拼音" />
			</td>		
		</tr>
		<tr>
			<td class="tbYellow">幣別</td>
			<td class="tbYellow2">台幣</td>
			<td class="tbYellow">受款人是否為契約利害關係人</td>
			<td class="tbYellow2" colspan="3">
				<select class="textBox2" name="IS_CONTRACT" id ="IS_CONTRACT">
					<option value="">請選擇</option>
					<c:forEach var="row" items="${IS_CONTRACT_LIST}"><option value="${row.key}">${row.value}</option></c:forEach>					
				</select>			
			</td>
		</tr>
		<tr>
			<td class="tbYellow">受款地區國籍</td>
			<td class="tbYellow2">
				<select class="textBox2" name="COUNTRY" id ="COUNTRY">
					<option value="">請選擇</option>
					<c:forEach var="row" items="${NATION_CODE_LIST}"><option value="${row.CODE}">${row.NAME_CH}</option></c:forEach>					
				</select>				
			</td>
			<td class="tbYellow">受款人國籍</td>
			<td class="tbYellow2" colspan="3">
				<select class="textBox2" name="ACPT_NAME_COUNTRY" id ="ACPT_NAME_COUNTRY">
					<option value="">請選擇</option>
					<c:forEach var="row" items="${NATION_CODE_LIST}"><option value="${row.CODE}">${row.NAME_CH}</option></c:forEach>
				</select>			
			</td>
		</tr>
		<tr>
			<td class="tbYellow">洗錢防制檢核結果</td>
			<td class="tbYellow2" colspan="5"></td>
		</tr>		
		<tr>
			<td class="tbYellow">備註</td>
			<td class="tbYellow2" colspan="5">
				<input id="MEMO" name="MEMO" type="text" size="22" maxlength="20" class="textBox2"  />
			</td>
		</tr>		
	</table>
</form>	
</body>
</html>