
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB10200.jsp
作者：張智翔
功能：單位對保資格查詢。
完成：2012/06/11
-->

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type='text/javascript'>

// 產生畫面物件
var DSB10200 = new DSB10200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB10200.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB10200(){

	//TabluUI
	var grid;
	//查詢的檢核
	var valid1;
	
	var lastGUAR_DEPT;
	function buttonAuth(){
		var authButtons = {
				B0021:"btn_export"<%--匯出--%> 				
		};
		
		<dz:grantButtons FUNC_ID="DSB10200" ignored="false"/>
	}
	
	
	//畫面檢核
	function initValidation(){		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false });	
		valid1.define( "required" , { id: "GUAR_DEPT" , errMsg : '請輸入單位代號查詢!!'} );
	}	
	
	
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB1_0200/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {
		//查詢資料
		doQuery : function(event){	
			
			if(!valid1.validate()){ 
				return; 
			}					
			
			//將畫面查詢條件轉大寫
			$('GUAR_DEPT').value = $('GUAR_DEPT').value.toUpperCase();		
		
			lastGUAR_DEPT = $('GUAR_DEPT').value;
		
			ajaxPost( 'query' , {GUAR_DEPT : $('GUAR_DEPT').value	},
				function(resp){					
					$('makeTitle').innerHTML = resp.GUAR_DEPT_NM;					
					grid.load(resp.rtnList);		
					CSRUtil.voToInputs('form' , resp.cntMap);
				},
				function(resp){
					//查詢失敗就清空
					grid.load([]);
					actions.doClear();
				}
			);		
		},
		
		doExport : function(event){			
			if(grid.getAllRecords().length ==0){
				alert('請先查詢再作匯出');
				return;			
			}
			
			if(lastGUAR_DEPT!=$('GUAR_DEPT').value){
				alert('匯出時的條件與查詢時不同,請重新查詢後再匯出');
				return;			
			}
			//查詢條件加入Form中 submit		
			$('gridJSON').value = grid.getXlsSettingJSON('對保資格查詢明細_'+getToday());				
			$('isExport').value = 'Y';		
		
			RPTUtil.executeCreateCsvFile("<%=dispatcher%>/DSB1_0200/export", Form.serialize("form") );				
		}
	}
	
	//actions
	var actions = {
		doClear : function(){
			$$('#count span').each(
				function(elem){
					elem.innerHTML = 0;;
				}			
			);
			//table UI回到初始TITLE
			$('makeTitle').innerHTML = '單位名稱';		
		}
	};
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB10200", "匯款維護", "單位對保資格查詢");
				//
				grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true, title : "<div align = 'left' id ='makeTitle'>單位名稱</div>",		
					<%-- [20240607] 難字調整 --%>
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
		            },
					column:[
						{header: "單位代號",key: "DIV_NO"},						
						//{header: "對保人編號",key: "GUARANTOR_NO"},	
						{header: "單位名稱",key: "DIV_NAME"},
						{header: "職級",key: "POS_NAME"},		
						<%-- [20240607] 難字調整 --%>
						{header: "姓名",key: "EMP_NAME", attrs:{ style:"font-family:'EUDC'" }},	
						{header: "對保資格",key: "GUAR_CONTROL"},	
						{header: "資格取得日",key: "BEGIN_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val || rec.INPUT_DATE, '/');	
							
							}
						},
						//{header: "資格取得方式",key: "BEGIN_REASON"},
						{header: "資格終止日",key: "END_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val, '/');	
							}
						},
						{header: "資格終止原因",key: "END_REASON"},
						{header: "年資滿一年",key: "ARRIVAL_1_YEAR"},
						{header: "放款舉績1件(含)以上",key: "C100_AGENT"},
						//{header: "線上對保課程",key: "B025_EMP_ID"}	
						{header: "線上對保課程",key: "B025_CLASS_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val, '/');	
							}
						}					
					]
					
				});
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );				
				$("btn_export").observe("click", buttons.doExport );						
							
				buttonAuth();
				
				initValidation();	
				
				fix();
				
				displayMessage();		
				//前方有接值就查詢 P.S AM = 管理大師連結
				<c:if test = "${SYS eq 'AM'}">						
					buttons.doQuery();
				</c:if>				
			}
	};	
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<input type="hidden" name="gridJSON" id="gridJSON" value=""><%--  匯出內容 --%>
		<input type="hidden" name="isExport" id="isExport" value=""><%--  是否匯出 --%>		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>	
				<td class="tbYellow"  align="left" width = "10%">
					單位查詢
				</td>	
				<td class="tbYellow2" width ="40%">
					<input id = "GUAR_DEPT" name = "GUAR_DEPT" value = "${UserDivNO}" type = "text" class = "textBox2" size = "6" maxlength ="5" fieldName = "查詢單位" />
				</td>	
				<td class="tbYellow2" align="center" >
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
					<input id = "btn_export" type = "button" class = "button" value = "匯出"/>
				</td>		
			</tr>			
		</table>	
		<table id='grid' width="100%"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td id = "count" class = "tbBlue" align = "left">
					授權取得資格者&nbsp <b><span class = "textRed" id = "intCntNo_TXT" name = "intCntNo_TXT" ></span></b>&nbsp位
					、認證取得資格者&nbsp <b><span id = "intCntYes_TXT" class = "textBlue" name = "intCntYes_TXT"></span></b>&nbsp位
					、總計有對保資格者&nbsp <b><span id = "intCnt_TXT" name = "intCnt_TXT"></span></b>&nbsp位
				</td>
			</tr>
			<tr>
				<td class="tbYellow" align = "left">					
					<b><font class = "textBlue">一、作業規定</font></b><br>
					1.各種貸款規定請參照放款作業手冊及發文規定。<br>
					2.取得對保資格依照放款對保認證作業管理辦法之規定。<br>
					3.本作業提供所屬單位對保人資格查詢功能。<br><br>
					<b><font class = "textBlue">二、操作方式</font></b><br>
					1.查詢：輸入單位代號，按<b><font class = 'textBlue'>[查詢]</font></b>即可。<br>
					2.可輸入單位代號查詢：
					<b><font class = 'textBlue'>總公司、區域單位</font></b>請輸入<b><font class = 'textRed'>２～５碼</font></b>代號、
					<b><font class = 'textBlue'>營業單位</font></b>請輸入<b><font class = 'textRed'>３碼</font></b>、
					<b><font class = 'textBlue'>獨立課</font></b>請輸入<b><font class = 'textRed'>４碼</font></b>查詢
				</td>
			</tr>
		</table>	
	</form>		
</body>
</html>