<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!-- 
[20240729] 修改件 陳勁谷 難字修改
 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/comm.js"></script>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/Validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

</head>

<script type="text/javascript" >
<!--
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var grid;
var validator;
var rtnList;

function initApp(){

	//PageUI.createPageWithAllBodySubElement( "DSA2130" , "核貸作業" ,"舊件貸限查詢 " , 1);
	PageUI.createPage("DSA2130" , "核貸作業" ,"舊件貸限查詢 ");
    PageUI.loadin(["tableA","grid","tableC"] ,1);
	
	cleanMsgBoard();
	
	displayMessage();
	
	validator = new Validator();

	new UI().init();

	// 查詢按鈕
	$("btn_query").observe('click', function(event){
			doQuery();
		}
	);
	
	PageUI.resize(true);
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
					column:[
						{ header: "貸款帳號", key: "LOAN_ID", attrs: { width : '40%'},
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { linkByLOAN_ID( value ); };
				                 	return link;
							}
						},
						{ header: "核准日期", key: "AGREE_DATE", attrs: { width : '60%'},
							render:function(record, val){
							 	return val ? Date.toROC(val) : "";
							}
						}
					]
				}
			);

			//取保留參數管理的借款人ID
			$('BORROW_ID').value = CSRUtil.keepParamsManager.get('BORROW_ID');
			if($('BORROW_ID').value){
				doQuery();
			}
			
		}//end init()--
		
	};//end return--
	//-------------------------------------------------------------------------- 
}

//--------------------------------------------------------------------------	
//	查詢Function
//--------------------------------------------------------------------------
function doQuery(){

	$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();
	
	var validator = checkInput(); //查詢條件檢核
	if(!validator.validate()){		
		return false;
	}

	//保留參數管理-更新借款人ID
	CSRUtil.keepParamsManager.put({'BORROW_ID': $('BORROW_ID').value});
		
  	new Ajax.Request("<%=dispatcher%>/DSA2_1300/query", 
		{
			parameters: { BORROW_ID : $F('BORROW_ID') },
		 	onSuccess:function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){

					grid.load(resp.rtnList);
					loadDetail(resp.rtnList[0]);
					rtnList = resp.rtnList;

				} else {
					grid.load([]);
					
					// 清除明細資料
					clearDetail();
				}
			}
		});
}

//--------------------------------------------------------------------------	
//	貸款帳號連結Function
//--------------------------------------------------------------------------
function linkByLOAN_ID(LOAN_ID) {

	for( var i = 0 ; i < rtnList.length ; i++ ){
	
		if (LOAN_ID == rtnList[i].LOAN_ID){
		
			// 載入明細資料
			loadDetail(rtnList[i]);
			return true;
		}
	}
}

//--------------------------------------------------------------------------	
//	載入明細資料Function
//--------------------------------------------------------------------------
function loadDetail(rtnMap) {

	$('BORROW_NAME').innerHTML = rtnMap['BORROW_NAME'] ? CSRUtil.maskHandler.getMaskName(rtnMap['BORROW_NAME']) : '';
	
	$('tableC').select('span').each(function(elm){
		var id = elm.id;
		
		if(id == 'APPR_DATE' || id == 'AGREE_DATE' || id == 'FINISH_DATE'){
			elm.innerHTML = rtnMap[id] ? Date.toROC(rtnMap[id]) : '';
		} else {
			elm.innerHTML = rtnMap[id] || '';
		} 			
	});
}

//--------------------------------------------------------------------------	
//	清除明細資料Function
//--------------------------------------------------------------------------
function clearDetail() {

	$('BORROW_NAME').innerHTML = '';
	$('tableC').select('span').each(function(elm){
		var id = elm.id;
		elm.innerHTML = '';
	});
}

//--------------------------------------------------------------------------	
//	檢核Function
//--------------------------------------------------------------------------
function checkInput() {
	validator.clear();
	validator = new Validator();
	validator.errHandler = new AlertHandler();

	validator.define('BORROW_ID', '借款人ID', '請輸入借款人ID', function(value){
		return $F('BORROW_ID').trim() != "";
	});

	if ($F('BORROW_ID').trim() != ""){
		validator.define('BORROW_ID', '借款人ID', '借款人ID 錯誤', 'idCheck1');
	}

	return validator;
}

//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 

										<form name="form1" id="form1" method="post">
											<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
												<!-- Block_4_Start 輸入區塊-->
												<tr>
													<td class="tbYellow" width="15%">借款人ID</td>
													<td class="tbYellow2" width="25%">
														<input type="text" class="textBox" id="BORROW_ID" name="BORROW_ID" size="12" maxlength="10">
														<%--[20240729] 修改件 陳勁谷 難字修改 --%>
														&nbsp;<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
													</td>
													<td class="tbYellow2" width="60%">
														<input type="button" id="btn_query" value="查詢" class="button">
													</td>
												</tr>
												<tr>
													<td class="tbYellow2" colspan='3'>
														<font color='blue'>
															&nbsp;1.實際貸限金額以簽准為準<br>
															&nbsp;2.同擔保品以最新核准日期之貸限為準<br>
															<!--&nbsp;3.鑑估日期與查詢日期差距二年內免鑑估，否則需重新鑑估-->
														</font>
													</td>
												</tr>
												<!-- Block_4_End 輸入區塊-->
											</table>
											<table id='grid' class="grid"></table>
											<table id='tableC' width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
												<tr align="center">
													<td class="tbYellow0" colspan='6'>　</td>
												</tr>
												<tr align="center">
													<td class="tbYellow" width="15%">貸款帳號</td>
													<td class="tbYellow2" width="18%">
														<font color='red'><span id="LOAN_ID"></span></font>
													</td>
													<td class="tbYellow" width="15%">總樓層</td>
													<td class="tbYellow2" width="19%">
														<span id="FLOOR"></span>
													</td>
													<td class="tbYellow" width="15%">貸款限額</td>
													<td class="tbYellow2" width="18%">
														<span id="LIMIT_AMT"></span>&nbsp;萬
													</td>
												</tr>
												<tr align="center">
													<td class="tbYellow" width="15%">鑑估日期</td>
													<td class="tbYellow2" width="18%">
														<span id="APPR_DATE"></span>
													</td>
													<td class="tbYellow" width="15%">核准日期</td>
													<td class="tbYellow2" width="19%">
														<span id="AGREE_DATE"></span>
													</td>
													<td class="tbYellow" width="15%">建築完成日</td>
													<td class="tbYellow2" width="18%">
														<span id="FINISH_DATE"></span>
													</td>
												</tr>
												<tr align="center">
													<td class="tbYellow" width="15%">地坪</td>
													<td class="tbYellow2" width="18%">
														<span id="LAND_SPACE"></span>
													</td>
													<td class="tbYellow" width="15%">建坪</td>
													<td class="tbYellow2" width="19%">
														<span id="BUILD_SPACE"></span>
													</td>
													<td class="tbYellow2" width="33%" colspan='2'></td>
												</tr>
												<tr align="center">
													<td class="tbYellow" width="15%">擔保品地址</td>
													<%--[20240729] 修改件 陳勁谷 難字修改 --%>
													<td class="tbYellow2" width="85%" colspan='5' align="left">
														&nbsp;&nbsp;<span id="GAGE_ADDR" style="font-family:'EUDC'"></span>
													</td>
												</tr>
											</table>
										</form>
										
</body>
</html>
