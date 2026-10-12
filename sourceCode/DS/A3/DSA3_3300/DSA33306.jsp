<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33306.jsp
作者：張晉瑋
功能：使照資料。
完成：2018/05/09

[20221215]
1. 調整初始查詢條件
2. 調整確認檢核及SQL條件
高強禾
-->

<fmt:setBundle basename='TextResource' />	

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javascript'>
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA33306().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA33306(){

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3306/');
	var grid1;
	var valid1;
	
	<%--欄位檢核--%>
	function initValidation(){	
		<%--使照清單資料用檢核--%>
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		Validation.addAllThese([	
			['checkNumeralFormat1', '樓層高度輸入錯誤，整數僅接受最多3位整數，小數點僅接受到小數點後兩位!', function(v , node) { 
				return checkNumeralFormat(v, 3, 2);
			}],
			['validLength20', '樓層別長度最多為20碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.getChtLength(v) <= 20
			}],
			['validLength80', '樓層用途長度最多為80碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				return actions.getChtLength(v) <= 80
			}]
		]);		
	}
	
	var actions = {
		<%--檢核中文長度--%>		
		getChtLength : function(str){
		    if(!str){
		    	return 0;
		    }
		    if(window.charCountsByte == '2'){
		    	<%--BIG5--%>
		    	var arr = str.match(/[^\x00-\xff]/ig);
		        return arr == null ? str.length : str.length + arr.length;
		    }
		    <%--UTF8--%>
		    var m = encodeURIComponent(str).match(/%[89ABab]/g);
		   	return str.length + (m ? m.length : 0);
		}
	}
	var buttons = {	

		<%--新增按鈕--%>
		doInsert : function (){	
			grid1.addRecords([{'COMMUNITY_NO':'${COMMUNITY_NO}', 'FLOOR':'', 'FLOOR_USE':'', 'FLOOR_HIGH':''}]);
		},
		<%--確認按鈕--%>	
		doConfirm : function (){	
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			var DATA_LIST = grid1.getAllRecords();
			
			<%--發送ajax--%>
			ajaxRequest.post('confirm', 
			{ 
				DATA_LIST : Object.toJSON(DATA_LIST),
				COMMUNITY_NO : '${COMMUNITY_NO}'
			},function(resp){ 
				if(resp.A355_List){
					grid1.load(resp.A355_List);
					$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
			});
		}
	};	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement(
					'DSA33306',
					'鑑價作業',
					'使照資料',
					'',
					true
				);		
			grid1 = new TableUI({
				table: $('grid1'),
				column:[           						
					{ header: '樓層別', key: 'FLOOR' , attrs : { Width : '25%'},
						input:{	type:"text", 'className':'required validLength20', 'size':10 }
					},
					{ header: '樓層用途', key: 'FLOOR_USE', attrs : { Width : '50%'},
						input:{	type:"text", 'className':'required validLength80', 'size':80 }
					},
					{ header: '樓層高度(m)', key: 'FLOOR_HIGH', attrs : { Width : '15%'},
						input:{	type:"text", 'className':'required validate-positive-number checkNumeralFormat1', 'size':5 }
					},
					{ header: '編輯', key: '' ,attrs : { Width : '10%'},
						input:{
							type:"button" ,
							text:"刪除",
							action:function( node , dataObj , value){ 	
								grid1.deleteRecords(dataObj[0]);		
							}
						}
					}	
				]					
			});
			
			//註冊DOM物件
			$("BTN_INSERT").observe("click", buttons.doInsert );
			$("BTN_COMFIRM").observe("click", buttons.doConfirm );

			grid1.load(<c:out value = '${A355_List}' default = '[]' escapeXml = "false"/>);

			<%-- [20221215] --%>
			<c:if test="${BTN_STATUS ne '1'}">
				$$('input[type="button"]', 'button[type="button"]').each(function(btn) {
					btn.disable();
				});
			</c:if>

			initValidation();	
			displayMessage();				
			PageUI.resize();		
		}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr class=tbYellow0 align=middle>
				<td align="center">
					<strong>使照資料清單</strong>
					<button id="BTN_INSERT" name="BTN_INSERT" type="button" class="button">新增</button>
					<button id="BTN_COMFIRM" name="BTN_COMFIRM" type="button" class="button">確認</button>
					<div id="UPDATE_DATE" datatype="ROCDate" style="float:right">資料更新日期：${UPDATE_DATE}</div>
				</td>
			</tr>
		</table>
		<table id='grid1' class='grid'></table>	
	</form>
</body>
</html>