<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->

<!--
程式：DSB10600.jsp
作者：謝雅筑
功能：待認證人員查詢
完成：2012/06/13

更新：
[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
[20201225]問題單20201225093456 修改匯出報表問題以及表格位置問題 何宗霖
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
Event.observe(window, 'load', new DSB10600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB10600(){
	
	var grid;
	var grid2;
	<%--[20201130]外網多筆個資遮蔽
	var preTd;
	var preEMP_ID_MASK;--%>
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0021:"btn_export"<%--匯出--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB10600" ignored="false"/>
	}
					
	var actions = {
		
		//查詢
		doQuery:function(){
	    	
			preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
			
			ajaxPost('query',{SRV_CRED:$F('SRV_CRED'),MKT_DEPT:$F('MKT_DEPT')},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);
			
		},
		//匯出
		doExport:function(){
	    	
			$('gridJSON').value = grid2.getXlsSettingJSON('待認證人員查詢明細');
			
			RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSB1_0600/export', Form.serialize("form"));
			
		},		
		//取得區部下拉選單
		doGetMKT_DEPT_LIST:function(event){
			$('MKT_DEPT').update();
			$('SRV_CRED').value='';
			//申請書221031007009:北南服務部組織調整配套作業調整
			$('MKT_DEPT').update().insert(new Element('option', {value: "AAAAA"}).update("全部"));
			var val = $F('CRED_DEPT') ;
			if(val == ''){
				return;
			}

			ajaxPost('getMKT_DEPT_LIST',{CRED_DEPT : val},
				function(resp){
					commonTools.createSelect(resp.MKT_DEPT_LIST);
					if(resp.SrvCred != undefined){
						$('SRV_CRED').value = resp.SrvCred;
					}
				}
			);	
		}
	};	

	var commonTools = {			
		createSelect:function(opts){
			var selectElement = $('MKT_DEPT');
			//申請書221031007009:北南服務部組織調整配套作業調整
			/*opts = opts?opts:{};
			for(key in opts){
				selectElement.insert(new Element('option', {value: key}).update(opts[key]));
			}*/
			opts = opts?opts:[];
			if(opts){
				opts.each(function(opt){
					selectElement.insert(new Element('option', {value: opt.DIV_NO}).update(opt.DIV_NAME));
				});
			}
		}
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSB1_0600/" + actionName,
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
			<%--[20201225處理表格會被放到form外的問題--%>
			<%--PageUI.createPage("DSB10600" , "匯款維護" , "待認證人員查詢", false);--%>
			<%--PageUI.loadin(["tableA","grid"] ,1);--%>
			PageUI.createPageWithAllBodySubElement("DSB10600" , "匯款維護" , "待認證人員查詢");

			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
				<%-- [20240607] 難字調整 --%>
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
	            },
					column:[
						{header: "序號" ,key: "SER_NO" },
						<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
						{ header: "個資顯示", key: "",
							render:function(rec, val, sn){
								var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
								button.update("點我");
								button.observe('click', function(){
									if(preTd){
										grid.setValueToTD(preTd, "EMP_ID_MASK", preEMP_ID_MASK);
									}
									preTd = this;
									preEMP_ID_MASK = rec['EMP_ID_MASK'];
									grid.setValueToTD(this, "EMP_ID_MASK", rec['EMP_ID']);
								});
	                			return button;
							}
						},--%>
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						{header: "經手人ID" ,key: "EMP_ID" },
						{header: "最近兩年件數<BR>(不含最近一年)" ,key: "YEAR2_CNT" ,
		               		render:function(record,value){
		               		 	return CSRUtil.$fmt(value ,'#,###.####') ;
		               		}
		            	},
						{header: "最近一年件數" ,key: "YEAR1_CNT" ,
		               		render:function(record,value){
		               		 	return CSRUtil.$fmt(value ,'#,###.####') ;
		               		}
		            	},
		            	<%-- [20240607] 難字調整 --%>
						{header: "經手人姓名" ,key: "EMP_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{header: "職稱" ,key: "POS_NAME" },
						{header: "單位" ,key: "DIV_NAME" },
						{header: "服務中心" ,key: "SRV_DEPT_NAME" },
						{header: "區域" ,key: "CRED_DEPT_NAME" }
					]
				
			});	
			<%--[20201225]修改匯出時報表格式--%>
			grid2 = new TableUI ( {
				table: $("grid2"), pageSize: 20, allSortable:true,
					column:[
						{header: "序號" ,key: "SER_NO" },
						{header: "經手人ID" ,key: "EMP_ID" },
						{header: "最近兩年件數<BR>(不含最近一年)" ,key: "YEAR2_CNT"},
						{header: "最近一年件數" ,key: "YEAR1_CNT"},
						{header: "經手人姓名" ,key: "EMP_NAME" },
						{header: "職稱" ,key: "POS_NAME" },
						{header: "單位" ,key: "DIV_NAME" },
						{header: "服務中心" ,key: "SRV_DEPT_NAME" },
						{header: "區域" ,key: "CRED_DEPT_NAME" }
					]
				
			});	
			$('grid2').setAttribute("style","display:none");
			
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

			//行政中心連動區部
			$('CRED_DEPT').observe('change',function(event){
					actions.doGetMKT_DEPT_LIST();
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
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<input id="SRV_CRED" name="SRV_CRED" type="hidden" value="${SrvCred}" />
				<tr>
					<td class="tbYellow" width="15%">區域</td>
                    <td class="tbYellow2" width="25%" >
						<select name="CRED_DEPT" id="CRED_DEPT" >
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}" <c:if test="${map.key eq CRED_DEPT}">selected</c:if>>${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow" width="15%">區部</td>
                    <td class="tbYellow2" width="25%" >
						<!-- <select name="MKT_DEPT" id="MKT_DEPT" >
							<c:forEach var="map" items="${MKT_DEPT_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select> -->
						<%--申請書221031007009:北南服務部組織調整配套作業調整--%>
						<select name="MKT_DEPT" id="MKT_DEPT" >
							<option value='AAAAA'>全部</option>
							<c:forEach var="map" items="${MKT_DEPT_LIST}">
								<option value="${map.DIV_NO}">${map.DIV_NAME}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow2" align="center" width="20%">
						<input id="btn_query" type="button" class="button" value="查詢" />
						<input id="btn_export" type="button" class="button" value="匯出" />
						<input type="hidden" name="gridJSON" id="gridJSON" value="">
					</td>
				</tr>
			</table>
<!------------------------ B區--------------------->											
	</form>
	<table id="grid" class="grid"></table>
	<table id="grid2" class="grid"></table>
</body>
<!-- InstanceEnd -->
</html>