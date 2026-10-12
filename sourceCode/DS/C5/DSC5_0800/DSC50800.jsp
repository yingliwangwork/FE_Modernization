<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--

程式功能:DSC50800.jsp
程式名稱:取消利率限制作業
作者:邱建禕
完成:2022年8月4日

-->
<!DOCTYPE html>
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
<!--匯入外部Javascript 與 css-->
<meta charset="BIG5">
<title></title>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
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
<script type="text/javascript">
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSC50800().initApp);

function DSC50800(){
	<%-- TablE UI物件 --%>
	var grid;		
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC5_0800/');
	var FUNC_ID = 'DSC50800';
	<%-- 驗證物件 --%>
	var valid1;

	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0005:"btn_delete",<%--刪除--%>
		    B0117:'btn_glConfirm',<%--組長覆核--%>
		    B0123: "btn_cgmConfirm", <%--科主管覆核--%>
			B0003:"btn_insert"<%--新增--%>
		};
		<dz:grantButtons FUNC_ID="DSC50800" />
	}
	<%-- actions 方法  --%>
	var actions = {	
		<%-- 檢核初始化 --%>
		initValidation : function(){
			Validation.addAllThese([
				[ 'validateQueryParam',  '請輸入查詢條件!', 
					function() {
						return !(Validation.get('IsEmpty').test($F('INPUT_DEPT')) &&
								 Validation.get('IsEmpty').test($F('INPUT_DATE_S')) &&
								 Validation.get('IsEmpty').test($F('INPUT_DATE_E')) &&
								 Validation.get('IsEmpty').test($F('REFER_ID')) &&
								 Validation.get('IsEmpty').test($F('BORROW_ID')) &&
								 Validation.get('IsEmpty').test($F('LOAN_ID'))
							 	);
					}
				],
				['validate-REFER_ID-LENGTH', "請輸入正確原貸帳號!(至少十個字元)" , 
					function(REFER_ID){
						if(!REFER_ID){
							return true;
						}					
						return !(REFER_ID.length < 10);					
					}
				],
				['validate-BORROW_ID-LENGTH', "請輸入正確借款人ID!(至少十個字元)" , 
					function(BORROW_ID){
						if(!BORROW_ID){
							return true;
						}					
						return !(BORROW_ID.length < 10);					
					}
				],
				['validate-LOAN_ID-LENGTH', "請輸入正確貸款帳號!(至少十個字元)" , 
					function(LOAN_ID){
						if(!LOAN_ID){
							return true;
						}					
						return !(LOAN_ID.length < 10);					
					}
				],
				['validate-DATE-30', '請將查詢期間縮短成一個月', 
	                function() { 
	                    if(diffDay($F('INPUT_DATE_S'), $F('INPUT_DATE_E')) > 30) {               			
	               			return false;
	               		}
	                	return true;
	                }                			
		        ],
		        ['validate-Q_LOAN_ID', '貸款帳號已異動，請重新查詢!', 
	                function() { 
                		return $F('Q_LOAN_ID') == $F('LOAN_ID_C');
                	}                			
	        	],
	        	['validate-Q_LOAN_ID', '貸款帳號已異動，請重新查詢!', 
	                function() { 
                		return $F('Q_LOAN_ID') == $F('LOAN_ID_C');
                	}                			
	        	]
			]);
			valid1 = new Validation('form1', { mode : 'validator' });
		},
		<%-- 檢核類型 --%>
		validType : function(type){
			valid1.reset();
			valid1.clear();
			if(type == 'query'){
				valid1.define('validateQueryParam', {id:'LOAN_ID',errMsg:'請至少輸入其中一個查詢條件!'} );
				valid1.define('validate-REFER_ID-LENGTH', { id: 'REFER_ID'} );
				valid1.define('validate-BORROW_ID-LENGTH', { id: 'BORROW_ID'} );
				valid1.define('validate-LOAN_ID-LENGTH', { id: 'LOAN_ID'} );
				valid1.define('validate-Date-Interval', [{id: 'INPUT_DATE_S', errMsg: '', ignore: true}, {id: 'INPUT_DATE_E', errMsg: '日期起迄有誤'}]);
				valid1.define('validate-DATE-30', [{id:'INPUT_DATE_E'}]);
				//valid1.define('required',{ id: 'OP_STATUS',errMsg: '狀態不得為空'});
			} else if(type == 'queryForInsert'){
				valid1.define('required',{ id: 'LOAN_ID_C',errMsg: '請輸入貸款帳號!'});
				valid1.define('validate-REFER_ID-LENGTH', { id: 'LOAN_ID_C'} );
			} else if(type == 'insert'){
				valid1.define('required',{ id: 'Q_LOAN_ID',errMsg: '請先以貸款帳號查詢!'});
				valid1.define('validate-Q_LOAN_ID',{ id: 'LOAN_ID_C',errMsg: '貸款帳號已異動，請重新查詢!'});
				valid1.define('required', { id: 'CANCEL_TERM',errMsg: '請輸入取消期數!'});
				valid1.define('validate-digits',{ id: 'CANCEL_TERM',errMsg: '取消期數須為正整數'});
			}
			
			return valid1.validate();
		},	
		getReqMap : function(){
			var reqMap = {};
			$('tableA').select('input[type!=button],select').each(function(ele){
				reqMap[ele.id] = ele.getValue() || '';
			});
			return reqMap;
		},
		getInsertMap : function(){
			var reqMap = {};
			$('tableC').select('input[type!=button],span').each(function(ele){
				if(ele.tagName == 'SPAN'){
					reqMap[ele.id] = ele.innerHTML || '';
				}else{
					reqMap[ele.id] = ele.getValue() || '';
				}
			});
			reqMap['LOAN_ID'] = $F('LOAN_ID_C');
			return reqMap;
		},
		setTableC : function(rtnMap){
			
			if(!rtnMap){
				return;
			}
			
			$('tableC').select('input[type!=button],span').each(function(ele){
				if('LOAN_ID_C' == ele.id){
					return;
				}
				var val = rtnMap[ele.id] || '';
				if(ele.tagName == 'SPAN'){
					ele.update(val);
				}else{
					ele.setValue(val);
				}
			});
		}	
	};
	
	<%-- buttons 方法  --%>
	var buttons = {
		<%-- 查詢 --%>
		doQuery : function(){
			
			if (!actions.validType('query')){
				return;
			}
			
			ajaxRequest.post( 'query', {reqMap : Object.toJSON(actions.getReqMap())}			
				,function(resp){											
					grid.load(resp.rtnList || []);						
				},
				function(resp){											
					grid.load([]);					
				}
			);
			
		},
		<%-- 刪除 --%>
		doDelete : function(){
			
			if(grid.getAllRecords().length == 0){
				alert('請先進行查詢');
				return;	
			}
			
			var checkedRec = grid.getCheckedRecord();
			
			if(checkedRec.length == 0){
				alert('請至少選取一筆資料，再執行作業');
				return;	
			}
			
			ajaxRequest.post( 'delete', {dataList : Object.toJSON(checkedRec),reqMap : Object.toJSON(actions.getReqMap())}			
				,function(resp){											
					grid.load(resp.rtnList || []);
		            //[20221111]已審件要可以刪除，並且提醒要到個別優惠利率作業自行刪除
					alert('刪除完成，若有需要刪除對應的個別優惠，請自行到個別優惠利率(畫面編號DSC50800)作業')
				}
			);
			
		},
		<%-- 組長覆核 --%>
		doGlConfirm : function(){
			
			if(grid.getAllRecords().length == 0){
				alert('請先進行查詢');
				return;	
			}
			
			var checkedRec = grid.getCheckedRecord();
			
			//員工件則跳出確認訊息
			var ERRMSG = '';
			checkedRec.forEach(function(item, i) {
				if(item.IS_EMP_NM=='是'){//有員工貸款件
					ERRMSG+='貸款帳號'+item.LOAN_ID+'此為員工件貸款件，原則上不可額外輸入個別優惠減碼，若是特殊需求請繼續作業，覆核完成後將於期數內暫時取消減碼限制';
					ERRMSG+='\n';
				}
			});
			if(ERRMSG.length!=0){
				if(!confirm(ERRMSG)){				
					return;
				}
			}

			
			if(checkedRec.length == 0){
				alert('請至少選取一筆資料，再執行作業');
				return;	
			}
			
			ajaxRequest.post( 'glconfirm', {dataList : Object.toJSON(checkedRec),reqMap : Object.toJSON(actions.getReqMap())}			
				,function(resp){											
					grid.load(resp.rtnList || []);						
				}
			);
		},
		
		<%-- 科主管覆核 --%>
		doCGMConfirm : function(){
			if(grid.getAllRecords().length == 0){
				alert('請先進行查詢');
				return;	
			}
			
			var checkedRec = grid.getCheckedRecord();
			
			//員工件則跳出確認訊息
			var ERRMSG = '';
			checkedRec.forEach(function(item, i) {
				if(item.IS_EMP_NM=='是'){//有員工貸款件
					ERRMSG+='貸款帳號'+item.LOAN_ID+'此為員工件貸款件，原則上不可額外輸入個別優惠減碼，若是特殊需求請繼續作業，覆核完成後將於期數內暫時取消減碼限制';
					ERRMSG+='\n';
				}
			});
			if(ERRMSG.length!=0){
				if(!confirm(ERRMSG)){				
					return;
				}
			}

			
			if(checkedRec.length == 0){
				alert('請至少選取一筆資料，再執行作業');
				return;	
			}
			
			ajaxRequest.post( 'cgmconfirm', {dataList : Object.toJSON(checkedRec),reqMap : Object.toJSON(actions.getReqMap())}			
				,function(resp){											
					grid.load(resp.rtnList || []);						
				}
			);
		},
		
		
		<%-- 新增查詢 --%>
		doQueryForInsert : function(){
			
			if (!actions.validType('queryForInsert')){
				return;
			}
			$('Q_LOAN_ID').setValue('');
			var LOAN_ID_C = $F('LOAN_ID_C');
			ajaxRequest.post( 'queryForInsert', {LOAN_ID : LOAN_ID_C}			
				,function(resp){	
					actions.setTableC(resp.rtnMap || '');		
					$('Q_LOAN_ID').setValue(LOAN_ID_C);
				}
			);
		},
		<%-- 新增 --%>
		doInsert : function(){
			
			//員工件則跳出確認訊息
			if ($('IS_EMP_NM').innerText=='是' ){
				if(!confirm('此為員工件貸款件，原則上不可額外輸入個別優惠減碼，若是特殊需求請繼續作業，覆核完成後將於期數內暫時取消減碼限制')){				
					return;
				}
			}
			
			if (!actions.validType('insert')){
				return;
			}
			
			if ($('LIMIT_DESC').innerText=='無' ){
				alert('查無利率限制，無須取消');
				return;
				
			}
			
			ajaxRequest.post( 'insert', {insertMap : Object.toJSON(actions.getInsertMap()),reqMap : Object.toJSON(actions.getReqMap())}			
				,function(resp){	
					grid.load(resp.rtnList || []);						
				}
			);
		}
	};

	return {
		
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateFields='INPUT_DATE_S INPUT_DATE_E BEGIN_DATE' />
			PageUI.createPageWithAllBodySubElement(
				'DSC50800',
				'利率計算',
				'取消利率限制作業'
			);
			
			grid = new TableUI({	
				table:$('gridB'), pageSize: 10, allSortable: false, overDiv :true,
				autoCheckBox:{isSelectAll:true },
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[
					{ header:'貸款帳號',key:'LOAN_ID' },
					{ header:'起始日',key:'BEGIN_DATE' },
					{ header:'取消期數',key:'CANCEL_TERM' },
					{ header:'到期日',key:'END_DATE' },
					{ header:'原利率限制',key:'LIMIT_DESC' },
					{ header:'狀態',key:'OP_STATUS_NM' },
					{ header:'輸入日期',key:'INPUT_DATE',sortRule:'date' },
					{ header:'輸入人員',key:'INPUT_NAME', attrs:{style:"font-family:'EUDC'"} },
					{ header:'組長覆核',key:'CHECK_NAME1', attrs:{style:"font-family:'EUDC'"} },
					{ header:'科主管覆核',key:'CHECK_NAME2', attrs:{style:"font-family:'EUDC'"} },
					{ header:'科主管覆核日期',key:'CHECK_DATE2' },
					{ header:'備註',key:'COMMENT' },
					{ header:'員工件',key:'IS_EMP_NM' }
				]
			});
			
			
			<%--註冊事件--%>
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_delete').observe('click', buttons.doDelete);
			$('btn_glConfirm').observe('click', buttons.doGlConfirm);
			$('btn_cgmConfirm').observe('click', buttons.doCGMConfirm);
			$('btn_queryForInsert').observe('click', buttons.doQueryForInsert);
			$('btn_insert').observe('click', buttons.doInsert);
				 
			<%-- 檢核物件初始化 --%>
			actions.initValidation();
			buttonAuth();
			displayMessage();		
		}	
	};	
}


</script>
</head>
<body>
<form name='form1' id='form1' style="PADDING:0px;MARGIN:0px;" >
	<table id="tableA" name="tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow">貸款帳號</td>
			<td class="tbYellow2">
				<input id="LOAN_ID" name="LOAN_ID" type="text">
			</td>
			<td class="tbYellow">原貸帳號</td>
			<td class="tbYellow2">
				<input id="REFER_ID" name="REFER_ID" type="text">
			</td>
			<td class="tbYellow">借款人ID</td>
			<td class="tbYellow2">
				<input id="BORROW_ID" name="BORROW_ID" type="text">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">輸入單位</td>
			<td class="tbYellow2">
				<input id="INPUT_DEPT" name="INPUT_DEPT" type="text">
			</td>
			<td class="tbYellow">查詢日期起訖</td>
			<td class="tbYellow2">
				<input id="INPUT_DATE_S" name="INPUT_DATE_S" type="text"> ~
				<input id="INPUT_DATE_E" name="INPUT_DATE_E" type="text">
			</td>
			<td class="tbYellow">狀態</td>
			<td class="tbYellow2">
				<select id="OP_STATUS" name="OP_STATUS">
					<option value="">全部</option>
					<c:forEach var="map" items="${OP_STATUS_LIST}">
						<option value="${map.key}">${map.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" colspan="6" style="text-align:center">
				<button id="btn_query" type="button" class="button">查詢</button>
				<button id="btn_delete"  type="button" class="button">刪除</button>
				<button id=btn_glConfirm  type="button" class="button">組長覆核</button>
				<button id="btn_cgmConfirm"  type="button" class="button">科主管覆核</button>
			</td>
		</tr>
	</table>
	<table id="gridB" class="gridB"></table>
	<table id="tableC" name="tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<thead>
	        <tr>
	        	<th class="tbYellow0" colspan="4" style="text-align:center">新增解除利率限制</th>
	        </tr>
    	</thead>
		<tr>
			<td class="tbYellow2" colspan="4" style="text-align:center">
				<button id="btn_queryForInsert" type="button" class="button">查詢</button>
				<button id="btn_insert"  type="button" class="button">新增</button>
				<%-- 隱藏欄位 --%>
				<input id="GROUP_NOTE" name="GROUP_NOTE" type="hidden">
				<input id="LIMIT_CODE" name="LIMIT_CODE" type="hidden">
				<input id="Q_LOAN_ID" name="Q_LOAN_ID" type="hidden">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">貸款帳號</td>
			<td class="tbYellow2">
				<input id="LOAN_ID_C" name="LOAN_ID_C" type="text">
			</td>
			<td class="tbYellow">起始日</td>
			<td class="tbYellow2">
				<input id="BEGIN_DATE" name="BEGIN_DATE" type="text">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">原利率限制</td>
			<td class="tbYellow2">
				<span id="LIMIT_DESC"></span>
			</td>
			<td class="tbYellow">取消期數</td>
			<td class="tbYellow2">
				<input id="CANCEL_TERM" name="CANCEL_TERM" type="text">
			</td>
		</tr>
		<tr>
			<td class="tbYellow">備註</td>
			<td class="tbYellow2">
				<input id="COMMENT" name="COMMENT" type="text" maxlength="100" size="25">
			</td>
			<td class="tbYellow">員工件</td>
			<td class="tbYellow2">
				<span id=IS_EMP_NM></span>
				<input id="IS_EMP" type="hidden" name = 'IS_EMP'>
			</td>
		</tr>
	</table>
</form>
</body>
</html>