<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->

<!--
程式：DSB10500.jsp
作者：謝雅筑
功能：區域代書查詢
完成：2012/06/13

更新：
[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSB10500().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB10500(){
	
	var grid;
	<%--[20201130]外網多筆個資遮蔽
	var preTd;
	var preSCRIVENER_NAME_MASK, preSCRIVENER_ID;--%>
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0021:"btn_export"<%--匯出--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB10500" ignored="false"/>
	}
	
	var actions = {
		
		//查詢
		doQuery:function(){
	    	
			//preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
			
			ajaxPost('query',{CRED_DEPT:$F('CRED_DEPT')},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
					$('CNT_YES').update(resp.cntMap.intCntYes||0);
					$('CNT_NO').update(resp.cntMap.intCntNo||0);
				},
				function(){
					grid.load([]);
					$('CNT_YES').update('');
					$('CNT_NO').update('');
				}
			);
			
		},
		//匯出
		doExport:function(){
			
			RPTUtil.executeCreateXlsFile("<%=dispatcher%>/DSB1_0500/export", Form.serialize("form"));					
			
		}
		
	};	
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSB1_0500/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	
	
	return{                              
		initApp:function(){
			PageUI.createPage("DSB10500" , "匯款維護" , "區域代書查詢", false);
			PageUI.loadin(["tableA","grid","tableB"] ,1);

			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
				<%-- [20240607] 難字調整 --%>
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
	            },
					column:[
						<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
						{ header: "個資顯示", key: "",
							render:function(rec, val, sn){
								var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
								button.update("點我");
								button.observe('click', function(){
									if(preTd){
										grid.setValueToTD(preTd, "SCRIVENER_NAME_MASK", preSCRIVENER_NAME_MASK);
										grid.setValueToTD(preTd, "SCRIVENER_ID_MASK", preSCRIVENER_ID_MASK);
									}
									preTd = this;
									preSCRIVENER_NAME_MASK = rec['SCRIVENER_NAME_MASK'];
									preSCRIVENER_ID_MASK = rec['SCRIVENER_ID_MASK'];
									grid.setValueToTD(this, "SCRIVENER_NAME_MASK", rec['SCRIVENER_NAME']);
									grid.setValueToTD(this, "SCRIVENER_ID_MASK", rec['SCRIVENER_ID']);
								});
	                			return button;
							}
						},--%>
						{header: "區域" ,key: "INPUT_DEPT_NM" },
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						<%-- [20240607] 難字調整 --%>
						{header: "代書姓名" ,key: "SCRIVENER_NAME", attrs:{ style:"font-family:'EUDC'" }},			
						{header: "代書ID" ,key: "SCRIVENER_ID" },
						{header: "代書資格" ,key: "IS_AGENCY" ,
		               		render:function(record,value){
		               			if(value == '取消特約代書'){
		               				value  = '<font color="red">' + value + '</font>';
		               			}
		               		 	return value;
		               		}
		            	},
		            	{header: "異動原因" ,key: "UPDATE_REASON" },
		            	<%-- [20240607] 難字調整 --%>
		            	{header: "輸入人員" ,key: "INPUT_NAME", attrs:{ style:"font-family:'EUDC'" }},			
						{header: "輸入日期" ,key: "INPUT_DATE" , 
		               		render:function(record,value){
		               		 	return Date.toROC(value);
		               		}
		            	}
					]
				
			});	
			
			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);
			
			//匯出
			$('btn_export').observe('click',function(event){
					actions.doExport();
				}
			);

			buttonAuth();
			displayMessage();

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body >	
<!------------------------ A區--------------------->	
		<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<tr>
					<td class="tbYellow" width="15%">區域</td>
                    <td class="tbYellow2" width="25%" >
						<select name="CRED_DEPT" id="CRED_DEPT" >
							<option value="0" <c:if test="${map.key eq CRED_DEPT}">selected</c:if>>全部</option>
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}" <c:if test="${map.key eq CRED_DEPT}">selected</c:if>>${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow2" align="center" width="60%">
						<input id="btn_query" type="button" class="button" value="查詢" />
						<input id="btn_export" type="button" class="button" value="匯出" />
					</td>
				</tr>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
				<tr>
					<td class="tbBlue">特約代書&nbsp;<font color="blue"><span id="CNT_YES"></span></font>&nbsp;位，非特約代書&nbsp;<font color="red"><span id="CNT_NO"></span></font>&nbsp;位</td>
				</tr>
				<tr>
					<td class="tbYellow">
					<font color="blue">一、作業規定</font>
					　<br>1. 各種貸款規定請參照放款作業手冊及發文規定。
					 <br> 2. 本作業提供區域特約代書查詢。
					<br><br>
					<font color="blue">二、操作方式</font><br>
					1. 查詢： 點選區域別，按<font color="blue">[查詢]</font>即可。
					</td>
				</tr>
			</table>
</form>
</body>
<!-- InstanceEnd -->
</html>