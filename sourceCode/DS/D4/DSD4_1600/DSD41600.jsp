<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41600.jsp
功能：清償文件簽收查詢作業
作者：吳誌倫
完成：2021/07/15

[20220301]問題單[20220225170023]
1.新增領取單位查詢、貸款帳號查詢
2.簽收條進度:新增待服中主管覆核(已簽收)、文件不全、退回金庫
3.退回金庫，簽收條進度呈空白，需呈現。
4.影像擋簽收條進度大於50時不呈現。
作者：高強禾

[20240328]
難字調整
高強禾
-->	
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script language="JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script> 
<%-- [20240328] 難字調整 --%>
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
Event.observe(window, 'load', new DSD41600().initApp);

function DSD41600() {
	var grid;
	var valid;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1600/');
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0252: 'btn_confirm',//簽收確認
			B0070: 'btn_check',//覆核
			B0008: 'btn_back'//退回前一關
		};		

		<dz:grantButtons FUNC_ID="DSD41600"/>
	};
	
	//畫面檢核
	function initValidation(){		
		valid = new Validation('form1', {focusOnError:true, immediate:false , mode: 'validator'});
		valid.define('requiredifblank2', {id: 'DATE_S', errMsg: '輸入日期(起)不得為空'});
		valid.define('requiredifblank3', {id: 'DATE_E', errMsg: '輸入日期(迄)不得為空'});
		valid.define('validate-date-db', {id: 'DATE_S', errMsg: '輸入日期(起)須為日期格式'});
		valid.define('validate-date-db', {id: 'DATE_E', errMsg: '輸入日期(迄)須為日期格式'});

		<%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，只能輸英文數字 --%>
		Validation.addAllThese([
			['validate-refer_id', '貸款帳號須為英數字', function(val) {
				return /^[a-zA-Z0-9]*$/.test(val);
			}]
		]);
		valid.define('validate-refer_id', {id: 'REFER_ID'});
	}
	var actions = {
		getreqMap : function(){
			var sendRecord = {
				CASE_STATUS : $F('CASE_STATUS'), 
				TXT_STATUS : $F('TXT_STATUS'),
				DATE_S : $F('DATE_S'),
				DATE_E : $F('DATE_E'),
				<%-- [20220301]問題單[20220225170023] 1.新增領取單位查詢、貸款帳號、客戶id查詢 --%>
				RECEIVE_DEPTNO : $F('RECEIVE_DEPTNO'),
				REFER_ID : $F('REFER_ID'),
				BORROW_ID : $F('BORROW_ID')
			};
			return sendRecord;
	    },
	    <%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
	    englishToUpperCase : function() {
	    	this.value = this.value.toUpperCase();
	    }
	};
	var buttons = {
		doQuery : function(){		
			valid.reset();
			if(!valid.validate()){
				return;			
			}
			ajaxRequest.post('query', { reqMap : Object.toJSON(actions.getreqMap())} ,
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){ 	
					grid.load([]);
				}
			);	
		},
		doCheck : function(){		
			valid.reset();
			var dataList = grid.getAllRecords();
			if(dataList.length == 0){
				alert("請先查詢再執行覆核作業");
				return;
			}
			
			var checkList = grid.getCheckedRecord();
			if(!checkList || checkList.length === 0){
				alert('請至少選取一筆資料再執行覆核作業');
				return;
			}
			
			ajaxRequest.post('check', {checkList : Object.toJSON(checkList)} ,
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){ 	
					grid.load([]);
				}
			);
		},
		<%--[20210923][20210909151037]簽收確認--%>
		doConfirm : function(){		
			valid.reset();
			var dataList = grid.getAllRecords();
			if(dataList.length == 0){
				alert("請先查詢再執行簽收確認作業");
				return;
			}
			
			var checkList = grid.getCheckedRecord();
			if(!checkList || checkList.length === 0){
				alert('請至少選取一筆資料再執行簽收確認作業');
				return;
			}
			
			ajaxRequest.post('confirm', {checkList : Object.toJSON(checkList)} ,
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){ 	
					grid.load([]);
				}
			);
		},
		<%--[20230627]退回前一關--%>
		doBack : function(){		
			valid.reset();
			var dataList = grid.getAllRecords();
			if(dataList.length == 0){
				alert("請先查詢再執行退回前一關作業");
				return;
			}
			
			var checkList = grid.getCheckedRecord();
			if(!checkList || checkList.length === 0){
				alert('請至少選取一筆資料再執行退回前一關作業');
				return;
			}
			
			ajaxRequest.post('back', {checkList : Object.toJSON(checkList)} ,
				function(resp){
					grid.load(resp.rtnList||[]);
				},
				function(resp){ 	
					grid.load([]);
				}
			);
		}
	};
	
    return{
    
    initApp : function(){
    		<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" dateFields="DATE_S DATE_E"/>
		    PageUI.createPageWithAllBodySubElement("DSD41600","清償作業","清償文件簽收查詢作業");
		    grid = new TableUI({
		    table : $("grid"),
		    pageSize : 10,
			allSortable : true, 
			autoCheckBox : {
				 type: "checkbox", 
				 text:'全選', 
				 isSelectAll: true
			},
			<%-- [20240328] 難字調整 --%>
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
		    column:[
		    	{header:"案件進度", key :'CASE_STATUS_NM'},
		    	<%-- [20240328] 難字調整：文件確認 --%>
		    	{header:"文件確認", key:'RECEIVE_ID', attrs:{ style:"font-family:'EUDC'" },
		    		render:function(obj, val){
		    			if('Y'!=obj.SIGN_STATUS && (val == null || val == "")){
		    				var link = new Element('a', {href : 'javascript:void(0)'}).update("未確認");
		            		link.observe('click', function(){
		            			popupWin.popup({
			            			src : '${dispatcher}/DSD4_1601/prompt',
			            			scolling : 'yes',
			            			parameters : {
			            				REFER_ID : obj.REFER_ID,
			            				APPLY_DATE : obj.APPLY_DATE,
			            				CASE_STATUS : obj.CASE_STATUS,
			            				BORROW_NAME : obj.BORROW_NAME
			            			},  	
			        				cb : function(obj){						
			        					buttons.doQuery();
			        				}
		            			});
		            		});
							return link ;
		    			} 
	    				//優先抓姓名
	    				return obj['RECEIVE_NAME']||val ;
	            	}	
		    	},
				{header:"簽收狀態", key :'SIGN_ID',
		    		render:function(obj, val){
		    			if('Y'!=obj.SIGN_STATUS && (val == null || val == "")){
		    				var link = new Element('a', {href : 'javascript:void(0)'}).update("未簽收");
		            		link.observe('click', function(){
		            			popupWin.popup({
			            			src : '${dispatcher}/DSD4_1603/prompt',
			            			scolling : 'yes',
			            			parameters : {
			            				REFER_ID : obj.REFER_ID,
			            				APPLY_DATE : obj.APPLY_DATE,
			            				CASE_STATUS : obj.CASE_STATUS
			            			},  	
			        				cb : function(obj){						
			        					buttons.doQuery();
			        				}
		            			});
		            		});
							return link ;
		    			} 
		    			return (val)?"已簽收" :"";
	            	}
				},
				{header:"影像檔", key :'FILE',
					render:function(obj, val){
						<%-- [20220301]問題單[20220225170023] 4.影像擋簽收條進度大於50時不呈現。 --%>
		    			if (obj.CASE_STATUS < 50 && obj.SIGN_STATUS != 'Y' ) {
		    				var link = new Element('a', {href : 'javascript:void(0)'}).update("影像查詢");
		            		link.observe('click', function(){
		            			popupWin.popup({
			            			src : '${dispatcher}/DSD4_1605/prompt',
			            			scolling : 'yes',
			            			parameters : {
			            				REFER_ID : obj.REFER_ID,
			            				APPLY_DATE : obj.APPLY_DATE,
			            				BORROW_NAME : obj.BORROW_NAME,
			            				CASE_STATUS : obj.CASE_STATUS
			            			}
		            			});
		            		});
							return link ;
		    			} 
		    			return '';
	            	}
				}, 
				<%-- [20240328] 難字調整：承辦初核、主管覆核 --%>
				{header:"承辦初核", key :'SIGN_ID', attrs:{ style:"font-family:'EUDC'" },
					render:function(obj, val){
							//優先抓姓名
		    				return obj['SIGN_NAME']||val ;
					}},
				{header:"主管覆核", key :'CHECK_ID', attrs:{ style:"font-family:'EUDC'" },
					render:function(obj, val){
							//優先抓姓名
		    				return obj['CHECK_NAME']||val ;
					}},
				{header:"備註", key :'REMARK',
					render:function(obj, val){
		    			if(obj.CASE_STATUS == '25'){
		    				var link = new Element('a', {href : 'javascript:void(0)'}).update("補全事項");
		            		link.observe('click', function(){
		            			popupWin.popup({
			            			src : '${dispatcher}/DSD4_1606/prompt',
			            			scolling : 'yes',
			            			parameters : {
			            				REFER_ID : obj.REFER_ID,
			            				APPLY_DATE : obj.APPLY_DATE,
			            				CASE_STATUS : obj.CASE_STATUS
			            			}
		            			});
		            		});
							return link ;
		    			} 
	            	}
				},
				{header:"塗銷申請日", key :'APPLY_DATE',
					render:function(obj, val){
		    			return obj.ROC_APPLY_DATE
	            	}
				},
				{header:"原貸帳號", key :'REFER_ID'},
				<%-- [20240328] 難字調整：借款人姓名、資管科經辦 --%>
				{header:"借款人姓名", key :'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
				{header:"資管科經辦", key :'SEND_ID', attrs:{ style:"font-family:'EUDC'" },
					render:function(obj, val){
						//優先抓姓名
	    				return obj['SEND_NAME']||val ;
				}}
		    ]
		    });
		    initValidation();
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_check').observe('click', buttons.doCheck);
			$('btn_confirm').observe('click', buttons.doConfirm); //[20210924][20210909151037]新增按鈕[簽收確認]
			$('btn_back').observe('click', buttons.doBack); //[20230627]新增按鈕[退回前一關]
			
		    <%-- [20220301]問題單[20220225170023] 1.新增貸款帳號查詢，英文輸入主動轉大寫 --%>
			$('REFER_ID').observe('change', actions.englishToUpperCase);


			buttonAuth();
		    displayMessage();
   	}
   };
}

</script>
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<form name="form1" id="form1" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>					
		<td class="tbYellow" align="center" width="10%">
			<font>塗銷申請日</font>
		</td>
		<td class="tbYellow2" align="center" width="10%">
			<input type="text" class="input" name="DATE_S" id="DATE_S" value="${DATE_S}"/>
			~
			<input type="text" class="input" name="DATE_E" id="DATE_E" value="${DATE_E}"/>
		</td>
		<td class="tbYellow" align="center" width="10%">文件確認</td>
		<td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">	
			<select class="input" name="TXT_STATUS" id="TXT_STATUS">
				<option value="">全部</option>
				<option value="0">未確認</option>
				<option value="1">確認</option>
			</select>
		</td>
		<%-- [20220301]問題單[20220225170023] 與SA確認後合併儲存格 --%>
		<td class="tbYellow2" align="center" width="10%" rowspan="3">
			<button type="button" class="button" id="btn_query">查詢</button>
			<button type="button" class="button" id="btn_confirm">簽收確認</button>
		</td>
		<%-- [20230627]新增退回前一關按鈕 --%>
		<td class="tbYellow2" align="center" width="10%" rowspan="3">
			<button type="button" class="button" id="btn_back">退回前一關</button>
			<button type="button" class="button" id="btn_check">覆核</button>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" align="center" width="10%">
			<font>案件狀態</font>
		</td>
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">
        	<select class="input" name="CASE_STATUS" id="CASE_STATUS">
					<option value="">全部</option>
					<c:forEach var="entry" items="${CASE_STATUS_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
		</td>
		<td class="tbYellow" align="center" width="10%">
			<font>貸款帳號</font>
		</td>
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">	
			<input type="text" id="REFER_ID" name="REFER_ID" maxlength="10" />
		</td>
	</tr>
	<%-- [20220301]問題單[20220225170023] 1.新增領取單位查詢、貸款帳號查詢 --%>
	<tr>
		<td class="tbYellow" align="center" width="10%">
			<font>領取單位</font>
		</td>
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">	
			<input type="text" id="RECEIVE_DEPTNO" name="RECEIVE_DEPTNO" maxlength="7" value="${RECEIVE_DEPTNO}" ${modify eq 'Y' ? '' : 'disabled'} />
		</td>
		<td class="tbYellow" align="center" width="10%">
			<font>客戶ID</font>
		</td>
        <td class="tbYellow2" bgcolor="#FAFBE1" align="center" width="10%">	
			<input type="text" class="input" maxlength="10" name="BORROW_ID" id="BORROW_ID"/>
		</td>
	</tr>
</table>
<table id='grid' class='grid' width="100%"></table>
</form>
</body>
</html>