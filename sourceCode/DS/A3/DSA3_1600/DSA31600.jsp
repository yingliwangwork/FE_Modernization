<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA31600.jsp
作者：簡睿甫
功能：沿線捷運設定
完成：
[2020/11/11] 申請書-201019001927：新增都市計畫案維護功能
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>

<script type="text/JavaScript">

Event.observe(window, 'load', new DSA31600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31600(){
	var grid;
	var grid2;
	var A211VOLIST = <c:out value="${A211VOLIST}" default="[]" escapeXml="false" />;
	var A224LIST = <c:out value="${DTDSA224List}" default="[]" escapeXml="false" />;
	var TYPE = '${TYPE}';
	var maxSEQ = 0;
	
	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	
	function buttonAuth() {
		var authButtons = { 
			B0028:'BTN_0028'<%--確認--%>
		};
		
		<dz:grantButtons FUNC_ID="DSA31600" ignored="false"/>
		
	}
	
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSA3_1600/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}	
	
	var button = {
		// 新增
		doInsert: function() {
			maxSEQ++;
			if('0' == '${TYPE}'){
				var newLine = {"l_SEQ":maxSEQ, "setUp": true};
				A211VOLIST.push(newLine);
				grid.load(A211VOLIST);
			}else if('1' == '${TYPE}'){
				<%--[2020/11/11] 申請書-201019001927：新增都市計畫案維護功能  --%>
				var newLine = {"LEVEL":'1',"SER_NO":"0","setUp": true};
				A224LIST.push(newLine);
				grid2.load(A224LIST);
			}
			
		},

		// 刪除
		doDelete: function() {
			var records;
			var allRecords;
			
			if('0' == TYPE) {
				records = grid.getCheckedRecord();
				if(records.length == 0){
					alert("請至少選取一筆資料");  
					return;
				}
				allRecords = grid.getAllRecords();
				var SEQ = records[0].l_SEQ;
				for(var i = 0; allRecords.length; i++) {
					if(allRecords[i].l_SEQ == SEQ ) {
						allRecords.splice(i, 1);
						break;
					}
				}
				grid.load(allRecords);
			}else if('1' == TYPE){
				records = grid2.getCheckedRecord();
				if(records.length == 0){
					alert("請至少選取一筆資料");  
					return;
				}
				allRecords = grid2.getAllRecords();
				var PCODE = records[0].POST_CODE;
				for(var i = 0; allRecords.length; i++) {
					if(allRecords[i].POST_CODE == PCODE ) {
						allRecords.splice(i, 1);
						break;
					}
				}
				grid2.load(allRecords);
			}	
			
		},

		// 確認
		doConfirm: function() {
		
			// 清空檢核
			validates.valid.clear();
						
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			if('0' == TYPE) {
				ajaxPostIM( "confirm" , { newList: Object.toJSON(grid.getAllRecords()), TYPE: TYPE}, 
						function(resp){	
							maxSEQ = 0;
							A211VOLIST = resp.A211VOLIST;
							grid.load(A211VOLIST || []); 
						}				
					);
			}else if('1' == TYPE){
				ajaxPostIM( "confirm" , { newList: Object.toJSON(grid2.getAllRecords()), TYPE: TYPE}, 
						function(resp){	
							maxSEQ = 0;
							A224LIST = resp.A224VOLIST;
							grid2.load(A224LIST || []);
							
						}				
					);
			}
			
		}
	};
	
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );
			
		}
	};
	
	return {
		initApp : function() {
			var FUNC_NAME;
			if('0' == TYPE) {
				FUNC_NAME = '捷運沿線設定';
			}else if('1' == TYPE){
				FUNC_NAME = '都市計畫區設定';
			}
			PageUI.createPageWithAllBodySubElement( "DSA31600" , "鑑價作業", FUNC_NAME );
			
			if('0' == TYPE) {
				grid = new TableUI(
					{table: $("grid"), allSortable: true, autoCheckBox:{type:'radio' }, pageSize: 100, whenDataNull:'',
					column:[
						{header:"編號",key:"l_SEQ",
							render: function(render, value) {
								if(value > maxSEQ) {
									maxSEQ = parseInt(value);
								}
								return value;
							}
						},
						{header:"捷運線名",key:"l_NAME",
							input:{
								type:'text',
								size:25 ,
								maxlength:25 ,
								className: 'required',
								genRule:function(record , value){
									return record.setUp? true : false;
								}
							}	
						},
						{header:"異動",key:"設定", sortable:false,
							input:{
								type:'button',
								text:'設定',
								action:function( node , dataObj , textDiv, orgData ){
									var LP_JSON = {
										// 編號
										L_SEQ : dataObj[0].l_SEQ,
										// 捷運線名
										L_NAME : dataObj[0].ENCODE_L_NAME,
										TYPE : TYPE,
										action : '${dispatcher}/DSA3_1601/prompt'
									};
									
									CSRUtil.linkTo(LP_JSON, 'form');
								},
								genRule:function(record , value){
									return record.setUp? false:true;
								} 
							}
						}
					]
				});
				
				if(A211VOLIST) {
					grid.load(A211VOLIST);
				}
			}else if('1' == TYPE){
				//[2020/11/11] 申請書-201019001927：新增都市計畫案維護功能
				
				grid2 = new TableUI(
						{table: $("grid"), allSortable: true, autoCheckBox:{type:'radio' }, pageSize: 100, whenDataNull:'',
						column:[
							{header:"郵遞區號",key:"POST_CODE",
								input:{
									type:'text',
									size:3 ,
									maxlength:3 ,
									className: 'required',
									fieldName: '郵遞區號',
									action:function( node , dataObj , textDiv, orgData ){
										//連動【郵遞區號】
										ajaxPostIM( "postCode" , { POST_CODE: dataObj[0].POST_CODE}, 
												function(resp){													
													grid2.setValueToTD(node,'POST_CODE_NM',resp.POST_CODE_NM || '');
												}				
											);
									},
									genRule:function(record , value){
										return record.setUp? true : false;
									}
								}	
							},
							{header:"行政區",key:"POST_CODE_NM"},
							{header:"異動",key:"設定", sortable:false,
								input:{
									type:'button',
									text:'設定',
									action:function( node , dataObj , textDiv, orgData ){
										var LP_JSON = {
											// 郵遞區號
											POST_CODE : dataObj[0].POST_CODE,
											// 行政區
											POST_CODE_NM : dataObj[0].POST_CODE_NM,
											TYPE : TYPE,
											action : '${dispatcher}/DSA3_1601/prompt'
										};
										
										CSRUtil.linkTo(LP_JSON, 'form');
									},
									genRule:function(record , value){
										return record.setUp? false:true;
									} 
								}
							}
						]
					});
				
				if(A224LIST) {
					grid2.load(A224LIST);
				}
			}			
			
			// 檢核初始化
			validates.initValidation();
			
			// 監聽: 新增
			$("BTN_0002").observe('click', button.doInsert);

			// 監聽: 刪除
			$("BTN_0003").observe('click', button.doDelete);

			// 監聽: 確認
			$("BTN_0028").observe('click', button.doConfirm);

			PageUI.resize();
			buttonAuth();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSA31600
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td  align='center' >
					<input id="BTN_0028" type="button" value='確認' class="button"> 
				</td>
			</tr>
		</tbody>	
	</table><form id='form'>
	<table id="grid" ></table>
	
	<table id='block_C' width="100%" border="0" cellspacing="0" cellpadding="0" class="tbBox2">
		<tbody>
			<tr></form>
				<td class="tbYellow2" align='center' >
					<input id="BTN_0002" type="button" value='新增' class="button"> 
					<input id="BTN_0003" type="button" value='刪除' class="button">
					<input id="TYPE" name="TYPE" type="hidden" value="${TYPE}"/>  
				</td>
			</tr>
		</tbody>	
	</table>
</body>
</html>		