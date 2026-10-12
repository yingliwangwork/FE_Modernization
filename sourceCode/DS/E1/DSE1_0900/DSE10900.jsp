<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE10900.jsp
作者：黃子玹 
功能：法務案件移轉
完成：2013/6/6

[20210922] 修改程式  楊青峰
新增整批移轉功能

[20240207]
難字調整
高強禾

[20240315]問題單號:20240312145514
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>        <%-- 投資共用 --%>
<%-- [20240207] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE10900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE10900(){

	var grid;
	var count;	
	var reqMap;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0097:"btn_transfer",     	<%--移轉--%>
			B0070:"btn_confirm", 	  	<%--覆核--%>		
			B0216:"btn_cancel", 	  	<%--取消--%>
			B0138:"btn_transferAll",		<%--整批移轉--%>
			B0265:"btn_outsource",		<%--[20230705]整批委外--%>
			B0266:"btn_cancelOutsource"		<%--[20230705]整批取消委外--%>
		};
		<dz:grantButtons FUNC_ID="DSE10900" />
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0900/" + actionName,
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
	}
	
	<%-- [20210922] --%>
	var auxiliary = {
		<%--CoverPage(鎖定畫面)--%>
		createCoverPage:function(){
			cover = CSRUtil.createCoverPage('_frontCover');
			cover.show();
		},
		<%--CoverPage(開放畫面)--%>
		closeCoverPage: function(){
			cover.hide();
		}
	}

	var actions = {
		<%--[20240315]問題單號:20240312145514--%>
		removeInputTypeFile : function(){
			var input = $('UPLOAD_FILE');
			$('UPLOAD_FILE').remove();
			parseEUDC('ap');
			$('import').insert(input);
		},	
		getMap : function(){
			var info = {};
			count = 0;
			$$('#table_A input[type!=button]','#table_A select').each(function(ele){
				info[ele.id] = $(ele).getValue();
				if($(ele).getValue()){
				   count += 1;	
				}
			})
			return 	info;				
		},	
		//駐點下拉選單連動法務人員選單
		doChangeOldList :  function(OLD_DEPT){	

			$('OLD_ID').options.length = 1;
			
			ajaxPost( 'changeoldlist',	{OLD_DEPT: OLD_DEPT},
				function(resp){			
					var INPUT_OLD_ID_LIST = resp.INPUT_OLD_ID_LIST;
					INPUT_OLD_ID_LIST.each(
						function(data) {
							$('OLD_ID').add(new Option(data.NAME, data.ID));
						}  
					); 	
				}					
			);
		},
		//移轉後科別連動移轉後法務選單
		doChangeList :  function(NEW_DEPT){	

			$('NEW_ID').options.length = 1;
			
			ajaxPost( 'changelist',	{NEW_DEPT: NEW_DEPT},
				function(resp){			
					var INPUT_ID_LIST = resp.INPUT_ID_LIST;
					INPUT_ID_LIST.each(
						function(data) {
							$('NEW_ID').add(new Option(data.NAME, data.ID));
						}  
					); 	
				}					
			);
		},		
		//查詢
		doQuery : function(event) {	
				
			reqMap = actions.getMap();
			if(count===0){
				alert('貸款帳號、原貸帳號、借款人ID、駐點、法務人員、案件種類、移轉狀態至少必須輸入其中一項!');
				return;
			}
			
			ajaxPost( 'query',	{reqMap : Object.toJSON(reqMap)},
				function(resp){	
					grid.load(resp.rtnList);					
				},function(resp){					
					grid.load([]);			
				}					
			);		
		},
		
		//移轉
		doTransfer : function(event){
		
			var tempCondition = actions.getMap();
			for(key in tempCondition){
				if(tempCondition[key] != reqMap[key]){
					alert('與查詢時條件不同，請重新查詢');
					return;
				}				
			}
			
			var chkData = grid.getCheckedRecord();		
					
			if(chkData.length == 0){		
				alert("請至少選取一筆資料");
				return;
			}		
				
			if(!$F('NEW_ID')){
				alert("請由移轉後駐點下拉選單取得移轉後法務!");
				return;
			}	
		
			ajaxPost( 'transfer',{reqMap : Object.toJSON(reqMap) ,inputList : Object.toJSON(chkData), NEW_DEPT : $F('NEW_DEPT'), NEW_ID : $F('NEW_ID')},
				function(resp){		
					grid.load(resp.rtnList);				
				},function(resp){
					grid.load([]);				
				}					
			);
			
		},
		
		// [20210922] 整批移轉
		doTransferAll: function(event) {
			
			//檢核「檔案」是否有選取	
			if(!$F('UPLOAD_FILE')) {
				alert('請先選擇上傳資料再執行!');
				return;
			}
			
			if(!$F('NEW_DEPT') || !$F('NEW_ID')) {
				alert("請由移轉後駐點下拉選單取得移轉後法務!");
				return;
			}
			
			auxiliary.createCoverPage();
			$('form1').action="${dispatcher}/DSE1_0900/transferAll";
			$('form1').submit();
		},		
		doOutsource: function(event) {<%--[20230705] 整批委外--%>	
			if(!$F('UPLOAD_FILE')) {
				alert('請先選擇上傳資料再執行!');
				return;
			}			
			auxiliary.createCoverPage();
			$('form1').action="${dispatcher}/DSE1_0900/outsource";
			$('form1').submit();
		},		
		doCancelOutsource: function(event) {<%--[20230705] 整批取消委外--%>
			if(!$F('UPLOAD_FILE')) {
				alert('請先選擇上傳資料再執行!');
				return;
			}			
			auxiliary.createCoverPage();
			$('form1').action="${dispatcher}/DSE1_0900/cancelOutsource";
			$('form1').submit();
		},
		// [20210922] 匯入結束 
		importEnd : function(event){
		
			auxiliary.closeCoverPage();
			var ele_filedata = window.importFrame.document.getElementById("filedata");
			if(ele_filedata){
				var obj = ele_filedata.innerHTML.evalJSON();
				var Msg = obj.ErrMsg.msgDesc.replace('\\n','');      
			}
			
			if(CSRUtil.isSuccess(obj)) {
				
			    $('import').update(new Element( "input", { id:"UPLOAD_FILE", name:"UPLOAD_FILE", type:"file", 'class': "textBox2", size:"50"}));	
			}
			
			if(Msg != null && Msg != ""){
				alert(obj.ErrMsg.msgDesc.replace("\\n",""));
			}
		},
		
		//取消移轉
		doCancel : function(event){
		
			var tempCondition = actions.getMap();
			for(key in tempCondition){
				if(tempCondition[key] != reqMap[key]){
					alert('與查詢時條件不同，請重新查詢');
					return;
				}				
			}
			
			var chkData = grid.getCheckedRecord();		
					
			if(chkData.length == 0){		
				alert("請至少選取一筆資料");
				return;
			}				
			
			ajaxPost( 'cancel',{reqMap : Object.toJSON(reqMap) ,inputList : Object.toJSON(chkData)},
				function(resp){		
					grid.load(resp.rtnList||[]);				
				},function(resp){
					grid.load([]);				
				}					
			);			
		},
		
		//覆核
		doConfirm : function(event){
		
			var tempCondition = actions.getMap();
			for(key in tempCondition){
				if(tempCondition[key] != reqMap[key]){
					alert('與查詢時條件不同，請重新查詢');
					return;
				}				
			}
			
			var chkData = grid.getCheckedRecord();		
					
			if(chkData.length == 0){		
				alert("請至少選取一筆資料");
				return;
			}				
			
			ajaxPost( 'confirm',{reqMap : Object.toJSON(reqMap) ,inputList : Object.toJSON(chkData), NEW_DEPT : $F('NEW_DEPT'), NEW_ID : $F('NEW_ID')},
				function(resp){		
					grid.load(resp.rtnList);				
				},function(resp){
					grid.load([]);				
				}					
			);			
		},
		
		//清空	
		doClear :　function(event) {		
			grid.load([]);			
			form1.reset();	
		}	
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE10900" , "法務作業" , "法務案件移轉");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true, autoCheckBox:{isSelectAll:true },	
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240312145514--%>
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { actions.removeInputTypeFile(); }<%--[20240315]問題單號:20240312145514--%>
                },
				column: [
					{header:"狀態", key:'TRAN_STS'},
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"原貸帳號", key:'REFER_ID'},
					<%-- [20240207] 難字調整：借款人姓名、擔保品門牌 --%>
					{header:"借款人姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"擔保品門牌", key:'GAGE_ADDR', attrs:{ style:"font-family:'EUDC'" }},
					{header:"法務進度", key:'LAW_PROCESS_NAME'},					
					{header:"法務進度日", key:'LAW_PROCESS_DATE',
								render : function (rec , val){
								return Date.toROC(val || '');									
							}				
					},
					<%-- [20240207] 難字調整：承辦法務 --%>
					{header:"承辦法務", key:'INPUT_NM', attrs:{ style:"font-family:'EUDC'" }},
					{header:"法院", key:'COURT_NAME'},
					<%-- [20240207] 難字調整：移轉後法務、覆核人員 --%>
					{header:"移轉後法務", key:'NEW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"覆核人員", key:'CFM_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"覆核日期", key:'CFM_DATE',
						render : function (rec , val){
						return Date.toROC(val || '');									
						}					
					}
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
			
			// 查詢
			$('btn_query').observe('click', function(event){
				actions.doQuery();
			});
				
			//移轉
			$('btn_transfer').observe('click', function(event){
				actions.doTransfer();
			});
			
			// [20210922] 整批移轉
			$('btn_transferAll').observe('click', function(event) {
				actions.doTransferAll();
			});
			$('importFrame').observe('load', actions.importEnd);
			
			//取消移轉
			$('btn_cancel').observe('click', function(event){
				actions.doCancel(); 
			});
				
			//覆核
			$('btn_confirm').observe('click', function(event){
				actions.doConfirm(); 
			});
			
			//清除
			$('btn_clear').observe('click', function(event){
				actions.doClear(); 
			});
			
			$('btn_outsource').observe('click', actions.doOutsource);<%-- [20230705] 整批委外--%>
			$('btn_cancelOutsource').observe('click', actions.doCancelOutsource);<%-- [20230705] 整批取消委外--%>
						
			//駐點下拉選單連動			
			$('OLD_DEPT').observe('change', function(event){
				actions.doChangeOldList(this.value); 
			});
			
			//移轉後科別下拉選單連動			
			$('NEW_DEPT').observe('change', function(event){
				actions.doChangeList(this.value); 
			});
			
			//Input欄位自動轉大寫
			$('LOAN_ID').observe('change',function(){
				$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();
			});	
			$('REFER_ID').observe('change',function(){
				$('REFER_ID').value = $F('REFER_ID').toUpperCase();
			});
			$('BORROW_ID').observe('change',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();
			});
			
			buttonAuth();
			
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSE10900
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" enctype="multipart/form-data", target="importFrame" ><%-- [20210922] --%>
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "10%" align="left">貸款帳號</td>
				<td class="tbYellow2" width ="10%">
					<input id="LOAN_ID" name="LOAN_ID" type="text" class="textBox2" size='12' maxlength='10'/>
				</td>
				<td class="tbYellow" width= "10%" align="left">原貸帳號</td>
				<td class="tbYellow2"  width ="10%">
					<input id="REFER_ID" name="REFER_ID" type="text" class="textBox2" size='12' maxlength='10'/>
				</td>
				<td class="tbYellow" width= "10%" align="left">借款人ID</td>
				<td class="tbYellow2"  width ="10%">
					<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" size='12' maxlength='10'/>
				</td>
				<%--[20230705]新增欄位--%>
				<td class="tbYellow" width= "10%" align="left">是否委外</td>
				<td class="tbYellow2"  width ="10%">
					<select id="OUTSOURCE" name="OUTSOURCE" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach items="${IS_OUTSOURCE_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>						
				</td>				
				<td class="tbYellow2" width = "10%" align="center" rowspan='2'>
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" type="button" class="button" value="清除">
				</td>	
			</tr>
			<tr>
				<td class="tbYellow" align="left">駐點</td>
				<td class="tbYellow2">						
					<select id="OLD_DEPT" name="OLD_DEPT" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach items="${CRED_DEPT_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow"align="left">法務人員</td>
				<td class="tbYellow2">						
					<%-- [20240207] 難字調整：法務人員 --%>
					<select id="OLD_ID" name="OLD_ID" class="textBox2" alt="ch">
						<option value="">請選擇</option>
						<c:forEach items="${INPUT_OLD_ID_LIST}" var="map">
							<option value="${map.ID}">${map.NAME}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" align="left">案件種類</td>
				<td class="tbYellow2">						
					<select id="CASE_KIND" name="CASE_KIND" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach items="${CASE_KIND_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>					
				</td>	
				<td class="tbYellow"align="left">移轉狀態</td>
				<td class="tbYellow2">								
					<select id="COURT_CODE" name="COURT_CODE" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach items="${COURT_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>					
				</td>		
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tbBox2">		
			<tr>
				<td  width="100%" colspan="9" align="center">					
					<input id="btn_transfer" type="button" class="button" value='移轉' />
					<input id="btn_cancel" type="button" class="button" value='取消移轉' />
					<input id="btn_confirm" type="button" class="button" value='覆核' />
					<input id="btn_transferAll" type="button" class="button" value='整批移轉' /> <%-- [20210922] --%>
					<input id='btn_outsource' type="button" class="button" value='整批委外' ><%-- [20230705] --%>
					<input id='btn_cancelOutsource' type="button" class="button" value='整批取消委外' /><%-- [20230705] --%>
				</td>
			</tr>
		</table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width= "10%">移轉後駐點</td>
				<td class="tbYellow2" width= "14%">								
					<select id="NEW_DEPT" name="NEW_DEPT" class="textBox2">	
						<option value="">請選擇</option>
						<c:forEach items="${CRED_DEPT_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" width= "10%">移轉後法務</td>
				<td class="tbYellow2" width= "14%">
					<%-- [20240207] 難字調整：債務人 --%>
					<select id="NEW_ID" name="NEW_ID" class="textBox2" alt="ch">
						<option value="">請選擇</option>
						<c:forEach items="${INPUT_ID_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" width= "12%">移轉人員</td>
				<td class="tbYellow2" width= "14%">
					<input id="INPUT_ID"  type="hidden" class="textBox2" size="12" value=${INPUT_ID}/>
					<%-- [20240207] 難字調整：移轉人員 --%>
					<span id="INPUT_NM" style="font-family:'EUDC'">${INPUT_NM}</span>
				</td>
				
				<td class="tbYellow" width= "10%">移轉日期</td>
				<td class="tbYellow2" width= "14%"><span id="INPUT_DATE">${CURR_DT}</span></td>		
			</tr>			
			<%-- [20210922] --%>
			<tr>
				<td class="tbYellow">檔案</td>
				<td class="tbYellow2" colspan="7">
					<span id="import"><input type="file" class="textBox2" id="UPLOAD_FILE" name="UPLOAD_FILE" size='50' /></span>
				</td>
			</tr>
		</table>
	</form>
	<table id="grid" width="100%" class="grid" ></table>
	<iframe id="importFrame" style="display:none;" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
</body>
</html>		