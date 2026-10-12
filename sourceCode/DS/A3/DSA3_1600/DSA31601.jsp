<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA31601.jsp
作者：簡睿甫
功能：捷運站名設定
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

Event.observe(window, 'load', new DSA31601().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31601(){
	var grid;
	var grid2;
	var A212VOLIST = <c:out value="${A212VOLIST}" default="[]" escapeXml="false" />;
	var A224List = <c:out value="${A224List}" default="[]" escapeXml="false" />;		
	var maxSEQ = 0;
	var L_SEQ = '${L_SEQ}';
	var POST_CODE = '${POST_CODE}';
	var TYPE = '${TYPE}';

	//--------------------------------------------------------------------------	
	//按鈕授權
	//--------------------------------------------------------------------------	
	function buttonAuth() {
		var authButtons = { 
			B0028:'BTN_0028'<%--確認--%>
		};
		
		<dz:grantButtons FUNC_ID="DSA31601" ignored="false"/>
		
	}
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSA3_1601/" + actionName, 
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
			var temp;
			if(maxSEQ<10) {
				temp = '0'+maxSEQ; // 補足兩位
			} else {
				temp = maxSEQ;
			}
			var newLine;
			if('0' == TYPE) {
				newLine = {"s_SEQ": temp, "L_SEQ":'${L_SEQ}', "setUp": true};
				A212VOLIST.push(newLine);
				grid.load(A212VOLIST);
			}else if('1' == TYPE){
				newLine = {"SER_NO": maxSEQ, "POST_CODE":'${POST_CODE}',"LEVEL":'2', "setUp": true};
				A224List.push(newLine);
				grid2.load(A224List);
			}
			
			
		},

		// 刪除
		doDelete: function() {
			var records;
			var allRecords;
			var SEQ;
			if('0' == TYPE) {
				records = grid.getCheckedRecord();	
				if(records.length == 0){
					alert("請至少選取一筆資料");  
					return;
				}	
				allRecords = grid.getAllRecords();
				SEQ = records[0].s_SEQ;
				for(var i = 0; allRecords.length; i++) {
					if(allRecords[i].s_SEQ == SEQ ) {
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
				SEQ = records[0].SER_NO;
				for(var i = 0; allRecords.length; i++) {
					if(allRecords[i].SER_NO == SEQ ) {
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
				ajaxPostIM( "confirm" , { newList: Object.toJSON(grid.getAllRecords()), L_SEQ: L_SEQ, TYPE: TYPE}, 
						function(resp){	
							maxSEQ = 0;
							A212VOLIST = resp.A212VOLIST || [];
							grid.load(A212VOLIST); 
						}				
					);
			}else if('1' == TYPE){
				ajaxPostIM( "confirm" , { newList: Object.toJSON(grid2.getAllRecords()), POST_CODE: POST_CODE, TYPE: TYPE}, 
						function(resp){	
							maxSEQ = 0;
							A224VOLIST = resp.A224VOLIST|| [];
							grid2.load(A224VOLIST); 
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
				FUNC_NAME = '捷運站名設定';
			}else if('1' == TYPE){
				FUNC_NAME = '都市計畫案設定';
			}
			PageUI.createPageWithAllBodySubElement( "DSA31601" , "鑑價作業", FUNC_NAME );
			
			if('0' == TYPE) {
				grid = new TableUI(
						{table: $("grid"), allSortable: true, autoCheckBox:{type:'radio' }, pageSize: 100, whenDataNull:'',
						column:[
							{header:"捷運線名",key:"L_NAME",
								render: function(rec, v) {
									return '${L_NAME}';
								}
							},
							{header:"編號",key:"s_SEQ",
								render: function(render, value) {
									if(value > maxSEQ) {
										maxSEQ = parseInt(value);
									}
									return value;
								}
							},
							{header:"捷運站名",key:"s_NAME",
								input:{
									type:'text',
									size:25 ,
									maxlength:25,
									className: 'required'
								}
							}
						]
					});
				if(A212VOLIST) {
					grid.load(A212VOLIST);
				}
			}else if('1' == TYPE){
				grid2 = new TableUI(
						{table: $("grid"), allSortable: true, autoCheckBox:{type:'radio' }, pageSize: 100, whenDataNull:'',
						column:[
							{header:"行政區",key:"POST_CODE_NM",
								render: function(rec, v) {
									return '${POST_CODE_NM}';
								}
							},
							{header:"編號",key:"SER_NO",
								render: function(render, value) {
									if(value > maxSEQ) {
										maxSEQ = parseInt(value);
									}
									return POST_CODE+'_'+value;
								}
							},
							{header:"都市計畫區",key:"URBAN_PROJECT_NM",
								input:{
									type:'text',
									size:100 ,
									maxlength:100,
									className: 'required',
									fieldName: '都市計畫區'
								}
							},
							{header:"地區別",key:"AREA_CODE",
								input:{
									type:'text',
									size:2 ,
									maxlength:2,
									className: 'required',
									fieldName: '地區別'
								}
							}
						]
					});
				if(A224List) {
					grid2.load(A224List);
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
			
			// 監聽: 回上頁
			$("BTN_0009").observe('click', function() {CSRUtil.linkBack('', { 'isSubmitParameters' : true });});
			
			PageUI.resize();
			buttonAuth();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSA31601
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td  align='center' >
					<input id="BTN_0028" type="button" value='確認' class="button"> 
					<input id="BTN_0009" type="button" value='回上頁' class="button"> 
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