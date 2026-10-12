<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!-- Default import and taglib declare -->
<%@ include file="/html/CM/header.jsp"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA11500.jsp
功能：退件明細查詢

[20201130]修改件  外網多筆個資遮蔽  @author 何宗霖
[2021-04-09] 配合申請書-放款相關核心畫面個資遮蔽， 移除「點我」後呈現該列明碼文字
[20240730] 修改件 難字調整
[20250217]修改件 配合Win11無IE瀏覽器，請協助使用CHROME瀏覽器程式優化 李世予
 -->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<%--[20240730]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<title></title>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script><!--檢核輸入參數-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script><!--alert訊息-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script><!--判斷isRocDate用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script><!--判斷button用-->
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/PageControllerObj.js"></script>

<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<script language="javascript" type="text/javascript">

var valid1;

var ppcIE = ( navigator.appName == "Microsoft Internet Explorer" );

var validateDate = function(){		
	if(diffDay($F('QUERY_STR_DATE'),$F('QUERY_END_DATE'), true) < 0)
		return false;
	return true;		
}

var chkDiffDay = function(){		
	if(diffDayROC($F('QUERY_STR_DATE'),$F('QUERY_END_DATE')) > 60)
		return false;
	return true;		
}

var requiredOne = function(){		
	if($F('CRED_DEPT')=='' && $F('DEPT')=='')
		return false;
	return true;		
}

function initApp(){  

	PageUI.createPageWithAllBodySubElement("DSA11500" , "受理作業" , "退件明細查詢", 1);
	
	new UI().init();

	// 顯示執行結果
	displayMessage();	
	
	// 查詢
	$("btn_query").observe('click',function(event){
		buttons.doQuery();
	});

	// 匯出
	$("btn_export").observe('click',function(event){
		buttons.doExport();
	});

	$("CRED_DEPT").observe('change',function(event){
		$("DEPT").value ='';
	});
	
	$("DEPT").observe('click',function(event){
		$("CRED_DEPT").selectedIndex = 0;
	});
	
	
	valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
	
	Validation.addAllThese([
		[ 'validateDate',  '終止日期需大於起始日期，請檢查後重新輸入查詢條件', validateDate]	,
		[ 'diffDayROC',  '查詢日期區間不得超過60天', chkDiffDay]	,
		[ 'requiredOne',  '請輸入受理單位或承辦科別查詢!', requiredOne]			
	]);	 
	
	<c:if test="${not empty rtnList}">
		if(ppcIE){
			grid.load(${rtnList});
		}else{
			appendGridtoList(${rtnList}, 'grid1');
		}
	</c:if>
	
	//[20250217]修改件 配合Win11無IE瀏覽器，請協助使用CHROME瀏覽器程式優化
	if(ppcIE){
		$('grid').style.display='';
		$('grid1').style.display='none';
	}else{
		$('grid').style.display='none';
		$('grid1').style.display='';
	}
		
	PageUI.resize(true);
	
	fix();
		
}
var grid;
var grid1_pageObj = {};
var grid1rtnList;

//將List增加到清單中
function appendGridtoList(list , target){
	//先清除
	var dataTable1 = $(target);
	var le = dataTable1.rows.length;
	for( i = le ; i > 1 ; i--){
		dataTable1.deleteRow(i-1);
	}
	//加入List
	if(list){
		grid1rtnList = list;
		// 逐筆顯示list
		for(var mover=0; mover < list.length ; mover++) {
			var valMap = list[mover];
			var clas = 'tbBlue3';
			if(mover%2==0){
				clas = 'tbYellow2';
			}
			APPLY_ID = valMap.APPLY_ID ? valMap.APPLY_ID : '';
			REJ_DATE = valMap.REJ_DATE ? Date.toROC(valMap.REJ_DATE) : '';
			REJ_REASON_C = valMap.REJ_REASON_C ? valMap.REJ_REASON_C : '';
			BORROW_NAME_MASK = valMap.BORROW_NAME_MASK ? valMap.BORROW_NAME_MASK : '';
			AGENT_NAME = valMap.AGENT_NAME ? valMap.AGENT_NAME : '';
			CRED_NAME = valMap.CRED_NAME ? valMap.CRED_NAME : '';
			CRED_TEL = valMap.CRED_TEL ? valMap.CRED_TEL : '';
			CRED_TEL = valMap.CRED_TEL ? valMap.CRED_TEL : '';
			//var url = '${linkToDPURL}' + "?checkPerm=X102&SYS=DS&__UserID__=" + '${UserID}' + "&APPLY_ID=" + valMap.APPLY_ID_LINK;
			
			insertString1 = "<tr ID='ROWID1' class="+clas+" align=middle style='display: none'>";
			insertString1 += "<td align=center>" + APPLY_ID + "</td>";
			insertString1 += "<td align=center>" + REJ_DATE + "</td>";
			insertString1 += "<td align=center>" + REJ_REASON_C + "</td>";
			insertString1 += "<td align=center>" + BORROW_NAME_MASK + "</td>";
			insertString1 += "<td align=center>" + AGENT_NAME + "</td>";
			insertString1 += "<td align=center>" + CRED_NAME + "</td>";
			insertString1 += "<td align=center>" + CRED_TEL + "</td>";
			
			insertString1 += "<td>" + '<a href="#" onClick="buttons.doPrint('+mover+')">點此</a></td>';
			
			insertString1 += "</tr>";
			dataTable1.insert({	bottom:insertString1 });
		}
		
		var insertString1 = "<tr class='tbBlue2'>" ;
		insertString1 = insertString1 + "<td colspan='11'>";
		insertString1 = insertString1 + "<b>";
		insertString1 = insertString1 + "<div align='right'>";
		insertString1 = insertString1 + "<span class='text10'>";
		insertString1 = insertString1 + "<a href='javascript:gotoFirstPage(grid1_pageObj);fix();' title='第一頁' ><img border='0' src='<%=imageBase%>/CM/previous2.gif' width='20' height='15'></a>";
		insertString1 = insertString1 + "<a href='javascript:gotoPrevPage(grid1_pageObj);fix();' title='上一頁' ><img border='0' src='<%=imageBase%>/CM/previous1.gif' width='20' height='15'></a>";
		insertString1 = insertString1 + "<a href='javascript:gotoNextPage(grid1_pageObj);fix();' title='下一頁' ><img border='0' src='<%=imageBase%>/CM/next1.gif' width='20' height='15'></a>";
		insertString1 = insertString1 + "<a href='javascript:gotoLastPage(grid1_pageObj);fix();' title='最末頁' ><img border='0' src='<%=imageBase%>/CM/next2.gif' width='20' height='15'></a>";
		insertString1 = insertString1 + "</span>";
		//insertString1 = insertString1 + "<span id='pageControlerBoard1' style='width:100px' >&nbsp;</span>";
		insertString1 = insertString1 + "</div>";
		insertString1 = insertString1 + "</b>";
		insertString1 = insertString1 + "</td>";
		insertString1 = insertString1 + "</tr>";
		dataTable1.insert({	bottom:insertString1 });
		
		//第一個參數是javaScript中的Form的物件
		//第二個參數是每一頁要顯示的資料筆數
		//第三個參數是每一行資料中的id名稱<TR ID="row">
		//第四個參數是要顯示分頁資訊的id名稱<td id="pageControlerBoard">&nbsp;</td>
		if($('ROWID1')){
			page(grid1_pageObj, document.form1, 20, "ROWID1", "pageControlerBoard1", 1);
		}
	}
}

//--------------------------------------------------------------------------
//	以下為UI() public method,放在 return 中
//--------------------------------------------------------------------------  

function UI(){

	return{
	
		init:function(){
		
			//產生 Grid 物件
			grid = new TableUI(
				{	
					table:$('grid'), pageSize: 20, allSortable: true,
					<%--[20240730] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{ header: "受理編號", key: "APPLY_ID" },
						{ header: "退件日期", key: "REJ_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{ header: "退件原因", key: "REJ_REASON_C"},
						<%--[20240730] 難字調整 --%>
						{ header: "借款人姓名", key: "BORROW_NAME_MASK", attrs:{style:"font-family:'EUDC'"}},			
						{ header: "經手人姓名", key: "AGENT_NAME", attrs:{style:"font-family:'EUDC'"}},						
						{ header: "承辦人員姓名", key: "CRED_NAME", attrs:{style:"font-family:'EUDC'"}},
						{ header: "承辦人員電話", key: "CRED_TEL"},
						{ header: "退件通知信", key: "NON",
							render: function( record, value ){		              			
								var link = document.createElement( "a" );
			                 	link.href = "#";
			                 	link.innerHTML = "點此";
			                	link.onclick = function( event ) { 
			                		buttons.doPrint(record);		                	
			                	};
			                 	return link;	
		            	}}
					]
				}
			);
			
			PageUI.resize(true);
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 查詢
	doQuery:function(){
		valid1.reset();
		if( !valid1.validate() ) {return;}

		columnToUpperCase('DEPT');
		
		var obj = {};
		obj.QUERY_STR_DATE = $F('QUERY_STR_DATE');
		obj.QUERY_END_DATE = $F('QUERY_END_DATE');
		obj.DEPT = $F('DEPT');
		obj.CRED_DEPT = $F('CRED_DEPT');
				
		new Ajax.Request("<%=dispatcher%>/DSA1_1500/query", 
		{
			parameters:obj,
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){					
					if(ppcIE){
						grid.load(resp.rtnList);
					}else{
						rtnList = resp.rtnList ? resp.rtnList : [];
						appendGridtoList(rtnList, 'grid1');
					}
				}else{	
					if(ppcIE){
						grid.load([]);
					}else{
						appendGridtoList([], 'grid1');
					}	
				}
				fix();
			}
		});
	},
	// 列印
	doPrint:function(record){
		if(!isNaN(record)){
			record = grid1rtnList[record];
		}
		
		valid1.reset();
		if( !valid1.validate() ) {return;}

		RPTUtil.executePrintByLink(
			'<%=dispatcher%>/DSA1_1500/print',
			{BORROW_NAME:record.BORROW_NAME,AGENT_DEPT:record.AGENT_DEPT,
			AGENT_NAME:record.AGENT_NAME, APPLY_ID:record.APPLY_ID,CRED_TEL:record.CRED_TEL}
		);
	},
	
	// 匯出
	doExport:function(){	
		valid1.reset();
		if( !valid1.validate() ) {return;}

		columnToUpperCase('DEPT');
		
		var obj = {};
		obj.QUERY_STR_DATE = $F('QUERY_STR_DATE');
		obj.QUERY_END_DATE = $F('QUERY_END_DATE');
		obj.DEPT = $F('DEPT');
		obj.CRED_DEPT = $F('CRED_DEPT');
		obj.gridJSON = grid.getXlsSettingJSON('退件明細查詢'); //讀進頁面回傳資料項目

		RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSA1_1500/exportXls', { reqMap : Object.toJSON(obj) });
	}
};

<%--
	轉大寫
--%>
function columnToUpperCase(columnName) {
	$(columnName).value = $(columnName).value.toUpperCase();
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="initApp();" onResize="fix();"	onScroll="fix();">

<form name="form1" id="form1" method="post" action="">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="left">退件日期</td>
		<td class="tbYellow2" width="30%">
			<input type="text" datatype="ROCDate" value="${QUERY_STR_DATE}" class="textBox2 required" size="10" maxlength="7" name="QUERY_STR_DATE" id="QUERY_STR_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_STR_DATE'))">
			~
			<input type="text" datatype="ROCDate" value="${QUERY_END_DATE}" class="textBox2 required diffDayROC validateDate" size="10" maxlength="7" name="QUERY_END_DATE" id="QUERY_END_DATE" />
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('QUERY_END_DATE'))">
		</td>
		<td class="tbYellow" width="15%" align="left">受理單位</td>
		<td class="tbYellow2" width="30%">
			<input type="text" value="${DEPT}" class="textBox requiredOne" id="DEPT" name="DEPT" size="7" maxlength="5">
			<font color='red'>可輸入兩碼區部代號查詢</font>
		</td>
		<td class="tbYellow2" align="left" rowspan="2">
		<input type="button" name="btn_query" id="btn_query" class="button" value="查詢" />
		<input type="button" name="btn_export" id="btn_export" class="button" value="匯出" />
		</td>
		
	</tr>
	<tr>
		<td class="tbYellow" width="15%" align="left">承辦科別</td>
		<td class="tbYellow2" width="30%">
			<select class="textBox2 requiredOne" name="CRED_DEPT" id="CRED_DEPT">
                          <option value=""></option>
                          <c:forEach var="item" items="${CRED_DEPT_LIST}">
                            <option value="${item.key}">${item.value}</option>
                          </c:forEach>
                        </select>
		</td>
		<td class="tbYellow" width="15%" align="left"></td>
		<td class="tbYellow2" width="30%">									
		</td>								
	</tr>

</table>

<table id='grid1' width="100%" border="0" align="center" cellpadding="0" cellspacing="1" class="tbBox2" style='display: none'>
	<tr class=tbBlue align=middle>
		<td>受理編號</td>
		<td>退件日期</td>
		<td>退件原因</td>
		<td>借款人姓名</td>
		<td>經手人姓名</td>
		<td>承辦人員姓名</td>
		<td>承辦人員電話</td>
		<td>退件通知信</td>
	</tr>
</table>


<table id='grid' class="grid" style='display: none'></table>	

</form>



</body>
</html>