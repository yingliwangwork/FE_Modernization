<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE10800.jsp
作者：黃子玹 
功能：法務組長派件
完成：2013/5/27

[20240207]
難字調整
高強禾
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
Event.observe(window, 'load', new DSE10800().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE10800(){

	var grid;
	var rtnList;

	//按扭權限
	function buttonAuth(){
		var authButtons = {			
				B0067:"btn_assign",
				B0068:"btn_cancel" 			
		};
	
		<dz:grantButtons FUNC_ID="DSE10800" />
	}	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0800/" + actionName,
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

	var actions = {
		
		//駐點下拉選單連動承辦法務選單
		doChangeList :  function(CRED_DEPT_CODE){	

			$('INPUT_ID').options.length = 1;
			
			ajaxPost( 'changelist',	{CRED_DEPT_CODE: CRED_DEPT_CODE},
				function(resp){			
					var INPUT_ID_LIST = resp.INPUT_ID_LIST;
					INPUT_ID_LIST.each(
						function(data) {
							$('INPUT_ID').add(new Option(data.NAME, data.ID));
						}  
					); 	
				}					
			);	


		},	
		
		//查詢
		doQuery : function(event) {			
			
			ajaxPost( 'query',	{CRED_DEPT: $('CRED_DEPT').value,COURT_CODE : $('COURT_CODE').value},
				function(resp){			
					rtnList = resp.rtnList;						
					grid.load(rtnList);						
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}					
			);		
		},
		//派件
		doAssign : function(event){
			
			var chkData = grid.getCheckedRecord(['LOAN_ID']);
							
			if(chkData.length == 0){		
				alert("請至少選取一筆資料");
				return;
			}		
			if(!$F('INPUT_ID')){
				alert("請由駐點下拉選單取得承辦法務!");
				return;
			}	
				
			ajaxPost( 'assign',	{inputList : Object.toJSON(chkData), CRED_DEPT: $F('CRED_DEPT'),  CRED_DEPT_NEW: $F('CRED_DEPT_NEW'), COURT_CODE : $('COURT_CODE').value,INPUT_ID :$F('INPUT_ID')},
				function(resp){			
					rtnList = resp.rtnList;					
					grid.load(rtnList);				
				},function(resp){
					grid.load([]);				
				}					
			);
			
		},
		//退件
		doCancel : function(event){
			
			var chkData = grid.getCheckedRecord(['LOAN_ID','REFER_ID']);				
						
			if(chkData.length == 0){		
				alert("請至少選取一筆資料");
				return;
			}	
						
			ajaxPost( 'cancel',	{inputList : Object.toJSON(chkData), CRED_DEPT: $F('CRED_DEPT'),COURT_CODE : $('COURT_CODE').value},
				function(resp){			
					rtnList = resp.rtnList;					
					grid.load(rtnList);				
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

			PageUI.createPageWithAllBodySubElement( "DSE10800" , "法務作業" , "法務組長派件");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true, autoCheckBox:{isSelectAll:true },
                <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"原貸帳號", key:'REFER_ID'},			
					<%-- [20240207] 難字調整：借款人姓名 --%>
					{header:"借款人姓名", key:'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"最近應繳日", key:'NEXT_PAYDT',
								render : function (rec , val){
								return Date.toInputROC(val || "");									
							}
				
					},					
					{header:"本金餘額", key:'TOT_AMT',
							render : function (rec , val){					 
							            return CSRUtil.$fmt(val,"#,###") || 0
						    }						
					},			
					{header:"移送日期", key:'TRANS_DATE',
								render : function (rec , val){
								return Date.toInputROC(val || "");									
							}
					},
					<%-- [20240207] 難字調整：擔保品地址 --%>
					{header:"擔保品地址", key:'GAGE_ADDR' ,attrs:{align:'left',style:"font-family:'EUDC'"}}		
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
			
						
			// 查詢
			$('btn_query').observe('click', function(event){
				actions.doQuery();
			});
			//清除
			$('btn_clear').observe('click', function(event){
				actions.doClear(); 
			});
			
			//派件
			$('btn_assign').observe('click', function(event){
				actions.doAssign();
			});
			//退件
			$('btn_cancel').observe('click', function(event){
				actions.doCancel(); 
			});
			//駐點下拉選單連動
			$('CRED_DEPT_NEW').observe('change', function(event){
				actions.doChangeList(this.value); 
			});
			
			buttonAuth();
			
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSE10800
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "12%" align="left">駐點</td>
				<td class="tbYellow2" width ="15%">								
					<select name="CRED_DEPT" id="CRED_DEPT" class="textBox2" fieldName = "駐點">						
						<c:forEach items="${CRED_DEPT_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow" width= "12%" align="left">法院</td>
				<td class="tbYellow2" width ="28%">								
					<select name="COURT_CODE" id="COURT_CODE" class="textBox2" fieldName = "法院">
						<option value="">請選擇</option>
						<c:forEach items="${COURT_LIST}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>					
				</td>				
				<td class="tbYellow2" width = "40%" align="center" >
				<input id="btn_query" type="button" class="button" value="查詢">
				<input id="btn_clear" type="button" class="button" value="清除">
				</td>	
			</tr>
			<tr>
				<td  width="100%" colspan="5" align="center">					
					<input id="btn_assign" type="button" class="button" value='派件' />
					<input id="btn_cancel" type="button" class="button" value='退件' />
				</td>
			</tr>	
			<tr>
				<td class="tbYellow">駐點</td>
				<td class="tbYellow2">								
					<select name="CRED_DEPT_NEW" id="CRED_DEPT_NEW" class="textBox2" fieldName = "駐點">
					<option value="">請選擇</option>
						<c:forEach items="${CRED_DEPT_LIST}" var="map">
							<option value="${map.CODE}">${map.CODE_NM}</option>
						</c:forEach>
					</select>					
				</td>
				<td class="tbYellow">承辦法務</td>
				<td class="tbYellow2" colspan='2'>					
					<%-- [20240207] 難字調整：承辦法務 --%>
					<select name="INPUT_ID" id="INPUT_ID" class="textBox2" fieldName = "承辦法務" alt="ch">
					<option value="">請選擇</option>
						<c:forEach items="${INPUT_ID_LIST}" var="map">
							<option value="${map.ID}">${map.NAME}</option>
						</c:forEach>
					</select>					
				</td>	
			</tr>			
		</table>
	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		