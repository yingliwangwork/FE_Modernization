<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
[20200620]問題單(202006200074): 
1. 上傳Xlsx檔案改成Csv
!-->
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script> 
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
	

<script type="text/JavaScript">

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var gridDataList = new Array();

function initApp(){
    buttonAuth();
    new UI().init();  
    
}
<%-- button控制 --%>
function buttonAuth(){
	var authButtons = {
		//B0003:"btn_insert", //新增		
		//B0015:"btn_upload"//匯入
	};
	<dz:grantButtons FUNC_ID="DSA22101" ignored="false" /> 	
}
<!---------------------------Define UI Class Start------------------------------>
function UI(){
	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 
	//--------------------------------------------------------------------------  
	//UI() private method
	//--------------------------------------------------------------------------  
	
	//開始Function
	function upload(){
		var fileName = $('IMPORT_FILE').value;
		if(fileName == ""){
			alert("「匯入檔案」必須存在。");
			return;
		}
	    <%--[20200620] 上傳xlsx檔案改成csv ， .CSV or csv都可以--%>
		if(fileName.lastIndexOf('.csv') < 0 && fileName.lastIndexOf('.CSV') < 0){
			return;
		}
		var form = document.form2;	
		
		form.action = "<%=dispatcher%>/DSA2_2101/upload?LP_JSON="  + $('LP_JSON').value;		
		submitOnce($('btn_upload'));
		form.submit();
		
	}
	
	
	
	//確認Function
	function doInsert(){					
		new Ajax.Request( 
			"<%=dispatcher%>/DSA2_2101/insert" ,
			{ 	parameters: {GridData:Object.toJSON(gridDataList) }, 
	    		onSuccess: function(XHT, resp){
		    		if(CSRUtil.isSuccess(resp)){
		    			CSRUtil.linkBack();	
		    		}
				}
			}
		);	
	}	
	
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){
			
			displayMessage();
			
			$("btn_insert").disabled = true; 
						
			//產生 Grid 物件
			var grid = new TableUI(
				{	
					table: $('grid'), pageSize: 12, allSortable: true, overDiv:{divHeight:20000},                        
					column:[
						{header:'檢核結果', sortable: true, key:'checkmsg' ,
							render : function (record , value){
								return record.check ? "<font color='blue'>"+value+"</font>" : "<font color='red'>"+value+"</font>" ;
							}					
						},
						{header:'年月', sortable: true,  key:'YYMM_R'},
						{header:'物價指數', sortable: true,  key:'INDEX',
							render:function(record,value){
								return CSRUtil.$fmt(value,'#,##0.0') ;
							}
						},											
						{header:'作業人員', sortable: true,  key:'INPUT_ID' },
						{header:'作業日期', sortable: true,  key:'INPUT_DATE'}
					]			
				}
			);
			
			$('LP_JSON').value = Object.toJSON(${LP_JSON});				

			//匯入		
			$("btn_upload").observe('click',function(event){
					upload();
	 			}
			);
			
 			//新增
			$("btn_insert").observe('click',function(event){
	  				doInsert();
	 			}
 			);
 			
			//上一頁		
			$("btn_back").observe('click',function(event){
					CSRUtil.linkBack();
	 			}
			);
			
			gridDataList = '${rtnList}';			
			
			if(gridDataList != "" ){
			
				gridDataList = gridDataList.evalJSON();
				
				if('true'==='${Enable}'){					
					$("btn_insert").disabled = false;				
				}
				grid.load(gridDataList);
				grid.sort( 'checkmsg', SORT_NONE , "String", null , false );//SEQ_NO欄位遞增
			}
			
		}//end init()--
	}//end return--
	//-------------------------------------------------------------------------- 
}

//-------------------------------------------------------------------------- 
<!---------------------------全域 函數 UI 與 畫面 公用--------------------------->

//-------------------------------------------------------------------------- 

</script>

</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >

<!--此網頁自建使用的JavaScript 放下面 -->

<center>
	<!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號--> 
	<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>核貸作業</b></td>
				<td>
				<div align="right">畫面編號：DSA22101</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->

<table width="100%" height="30" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>

<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
					
						<tr>
							<td class="tbBox2"><img src="<%=imageBase%>/CM/icon_dot11.gif" width="18" height="16">物價指數明細匯入</td>
						</tr>
						<tr bgcolor=#FFFFFF>
							<td><!-- Bolck_4_Start 輸入區塊-->
							<form name="form1" id="form1" method="post" action="">
							<%-- 儲存畫面查詢條件for連結其他畫面時傳送 --%>							
							
							<input name="Enable" id="Enable" type="hidden" value="${Enable}" >
							<input name="rtnList" id="rtnList" type="hidden" value="${rtnList}">							
							<input name="LP_JSON" id="LP_JSON" type="hidden" value="${LP_JSON}" >
							</form>
							
							<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
								<tr><form name="form2" id="form2" method="post" action="" enctype="multipart/form-data">

									<td class="tbYellow" width="12%">匯入檔案</td>
									<td class="tbYellow2" width="38%">
									<input id="IMPORT_FILE" name="IMPORT_FILE" type="file" size="30" maxLength="100" class="button" /><%--瀏覽--%>														
									</td>
									<!-- 按鈕區 Start -->
									<td class="tbYellow2" colspan="2"  align="center">
										<input type="button" name="btn_upload" id="btn_upload" class="button" value="匯入" />
										<input type="button" name="btn_insert" id="btn_insert" class="button" value="新增" />
										<input type="button" name="btn_back" id="btn_back" class="button" value="上一頁" />
									</td>
									<!-- 按鈕區End -->	
								</tr>
															
							</table>
							
							<!-- Query Result (Grid Table) -->
							<table id="grid" class="grid"></table>	
							</form>														

							<!--Bolck_4_End--></td>
						</tr>
					
				</table>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End--></center>
</body>
</html>