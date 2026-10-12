<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<%--
[20241030]修改件 CHROME瀏覽器難字調整
--%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<%--[20241030]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>  
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<script type="text/javascript" >
<!--
var dsc01100 = new DSC01100();

Event.observe(window, 'load', dsc01100.initApp );

function DSC01100(){
	var grid1;
	var valid1,valid2;	//查詢、修改的檢核
	var selectedRecord;
	
	function ajaxPost( actionName, params, successAction , failAction)
    {
        new Ajax.Request( "<%=dispatcher%>/DSC0_1100/" + actionName,
        {
			method: "post", parameters: params,
			onSuccess:function(xht, resp){
				if(CSRUtil.isSuccess(resp)){
					if( successAction ) {
						successAction(resp);
					}
				}else{
					if( failAction ){
						failAction(resp);
					}						
				}
			}
        });
    }
	
	function buttonAuth(){
		var authButtons = {
			B0003:"Btn_add", 	   <%--新增 --%>
			B0004:"Btn_update",    <%--修改 --%>	
			B0005:"Btn_delete",    <%--刪除 --%>	
			B0006:"Btn_submit",    <%--提交 --%>
			B0007:"Btn_agree",     <%--同意 --%>
			B0008:"Btn_reject"     <%--退回 --%>		
		};
		
		<dz:grantButtons FUNC_ID="DSC01100" ignored="false"/>	
	}
	
	function setData( record ){
		$('LIMIT_TYPE').value = record.LIMIT_TYPE || "";
		$('EFT_DATES').value = Date.toInputROC( record.EFT_DATES , "" );
		$('EFT_DATEE').value = Date.toInputROC( record.EFT_DATEE , "" );
		$('EFT_DATE_TYPE').value = record.EFT_DATE_TYPE;
		$('LIMIT_WAY').value = record.LIMIT_WAY;
		$('IR_RT').value = record.IR_RT || "";
		if( typeof record.IR_RT_IDX == "string" && !record.IR_RT_IDX.blank() ){	//prototype判斷字串是否為空白
			$('IR_RT_IDX').value = record.IR_RT_IDX;
		}else{
			$('IR_RT_IDX').value = "";
		}
		$('LIMIT_DESC').value = record.LIMIT_DESC || "";
	}
	
	function getData(){
		var obj = {};
		obj.LIMIT_TYPE = $('LIMIT_TYPE').value;
		obj.EFT_DATES = toY2K($('EFT_DATES').value);
		obj.EFT_DATEE = toY2K($('EFT_DATEE').value);
		obj.EFT_DATE_TYPE = $('EFT_DATE_TYPE').value;
		obj.LIMIT_WAY = $('LIMIT_WAY').value;
		obj.IR_RT = $('IR_RT').getValue();
		obj.IR_RT_IDX = $('IR_RT_IDX').value;
		obj.LIMIT_DESC = $('LIMIT_DESC').value;
		
		return { DTDSZ124_VO : Object.toJSON(obj), LIMIT_TYPE_Q : $F('LIMIT_TYPE_Q') , OP_STATUS_Q : $F("OP_STATUS_Q") };
	}
	
	function refreshData( resp ){
		grid1.load(resp.rtnList || []);
		actions.Btn_clear();
	}
	
	var actions = {
		"Btn_query" : function(event){
			ajaxPost( 'query' , { LIMIT_TYPE_Q : $F('LIMIT_TYPE_Q') , OP_STATUS_Q : $F("OP_STATUS_Q") } , refreshData ,
				function(resp){
					if( resp.ErrMsg && resp.ErrMsg.returnCode == -3 ){
						refreshData(resp);
					}
				}
			);
		},
		"Btn_clear" : function(event){
			var grid2 = $('grid2');
			grid2.select('input').each(function(elm){
				elm.value = "";
			});
			
			grid2.select('select').each(function(elm){
				elm.value = "";
			});
			
			valid1.reset();
		},
		"Btn_add" : function(event){
			if( !valid1.validate()){
				return;
			}
			
			ajaxPost( 'add' , getData() , refreshData );
		},	
		"Btn_delete" : function(event){
			var records = grid1.getCheckedRecord();
			if( records.length == 0 ){
				alert("請選取一筆資料");
				return;
			}
			
			ajaxPost( 'delete' , {CHK_SEQ: records[0].CHK_SEQ, LIMIT_TYPE: records[0].LIMIT_TYPE, LIMIT_TYPE_Q: $F('LIMIT_TYPE_Q'), OP_STATUS_Q: $F("OP_STATUS_Q") } , refreshData );
		},
		"Btn_update" : function(event){
			var records = grid1.getCheckedRecord();
			if( records.length == 0 ){
				alert("請選取一筆資料");
				return;
			}
			
			selectedRecord = records[0];
			
			if( !valid2.validate()){
				return;
			}
		
			var data = getData();
			data.LIMIT_TYPE = records[0].LIMIT_TYPE;
			data.CHK_SEQ = records[0].CHK_SEQ;
		
			ajaxPost( 'update' , data , refreshData );
		},
		"approveFlow" : function(event){
			var records = grid1.getCheckedRecord();
			if( records.length == 0 ){
				alert("請選取一筆資料");
				return;
			}
			
			var action = event.target.id.replace("Btn_","");
			
			ajaxPost( action , {CHK_SEQ: records[0].CHK_SEQ, LIMIT_TYPE: records[0].LIMIT_TYPE, LIMIT_TYPE_Q: $F('LIMIT_TYPE_Q'), OP_STATUS_Q: $F("OP_STATUS_Q") } , refreshData );
		}
	};
	
	function initTableUI(){
		<%-- [20241030] 難字調整 --%>
		grid1 = new TableUI({	
			table: $("grid1"),allSortable: false,pageSize:10,
			autoCheckBox:{ isSelectAll: false, type : "radio", 
				action: function(radio , boxStatus ,records){
					setData( records[0] );
				}
			},
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			column:[
				{header: "限制種類" ,key: "LIMIT_TYPE_NM" },
				{header: "檢核順序" ,key: "CHK_SEQ" },
				{header: "生效起日" ,key: "EFT_DATES",
				 render: function(record,value){
						return Date.toInputROC(value , "/" );
					}
				},
				{header: "生效迄日" ,key: "EFT_DATEE",
				 render: function(record,value){
						return Date.toInputROC(value , "/" );
					}
				},
				{header: "生效日種類" ,key: "EFT_DATE_TYPE_NM"},
				{header: "限制方式" ,key: "LIMIT_WAY_NM"},
				{header: "加碼數%" ,key: "IR_RT"},
				{header: "利率指標" ,key: "IR_RT_IDX_NM"},
				{header: "利率限制敘述" ,key: "LIMIT_DESC"},
				{header: "審批狀態" ,key: "OP_STATUS_NM"},
				{header: "最後作業人員" ,key: "LST_PROC_NAME", style:"font-family:'EUDC'"},
				{header: "最後作業時間" ,key: "LST_PROC_DATE",
				 render: function(record, value ){
						if( value ){
							return value.substring(0,19);
						}
						return "";
					}
				}
			]
		});
	}
	
	function initValidation(){
		Validation.addAllThese([
			// 若個件加減碼種類為保戶優惠才檢核
			['validate-update-LIMIT_TYPE', '不能修改限制種類。若限制種類輸入錯誤，請先刪除後重新新增', 
				function(value){
					if( selectedRecord.LIMIT_TYPE != value ){
						return false;
					}	
					return true;
				}
			]
		]);
		valid1 = new Validation('form1');
		valid2 = new Validation('form1');
		valid2.define('validate-update-LIMIT_TYPE' , { id : "LIMIT_TYPE" } );
	}
	
	return{
	
		initApp :function(){
			PageUI.createPageWithAllBodySubElement("DSC0_1100" , "利率限制維護作業" , "利率限制設定作業" );
			buttonAuth();
			initTableUI();
			initValidation();
			
			divResize(true);
			
			$('Btn_query','Btn_clear','Btn_add','Btn_update','Btn_delete').each(function(elm){
				elm.observe('click', actions[elm.id] );
			});
			
			$('Btn_submit' , 'Btn_agree' , 'Btn_reject').each(function(elm){
				elm.observe('click', actions['approveFlow'] );
			});
			
			autoFormatToNumber();
			
			displayMessage();
		}//end init()--		
	};//end return--
	//-------------------------------------------------------------------------- 
}
//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="15%">限制種類</td>
			<td class="tbYellow2" width="25%" >
				<SELECT name="LIMIT_TYPE_Q" id="LIMIT_TYPE_Q" >
				<option value="">全部</option>
				<c:forEach var="map" items="${LIMIT_TYPE_LIST}">
				<option value="${map.key}">${map.value}</option>
				</c:forEach>
				</SELECT>
			</td>
			<td class="tbYellow" width="15%">作業狀態</td>
			<td class="tbYellow2" width="25%" >
				<SELECT name="OP_STATUS_Q" id="OP_STATUS_Q" >
				<option value="">全部</option>
				<c:forEach var="map" items="${OP_STATUS_LIST}">
				<option value="${map.OP_STATUS}">${map.OP_STATUS_NM}</option>
				</c:forEach>
				</SELECT>
			</td>
			<td class="tbYellow2" width="20%" align="center" >
				<input type="button" id="Btn_query" class="button" value="查詢" />
			</td>				
		</tr>
		<tr>
			<td colSpan="5" align="center">
				<input type="button" id="Btn_add" class="button" value="新增" />
				<input type="button" id="Btn_update" class="button" value="修改" />
				<input type="button" id="Btn_delete" class="button" value="刪除" />
				<input type="button" id="Btn_clear" class="button" value="清除" />
				<input type="button" id="Btn_submit" class="button" value="提交" />
				<input type="button" id="Btn_agree" class="button" value="同意" />
				<input type="button" id="Btn_reject" class="button" value="退回" />
			</td>
		</tr>
		<tr>
			<td colSpan="5">
				<table id="grid1" >						
				</table>
			</td>
		</tr>
	</table>	
		
	<form name="form1" id="form1" >	
		<div class="over_div" divWidth="1" style="overflow:auto;background:#FFFFFF;height:85px;" >
			<table  id="grid2" width="100%" class="grid tbBox2">
				<tr>
					<td class="tbBlue" align="center" >限制種類</td>
					<td class="tbBlue" align="center" >生效起日</td>
					<td class="tbBlue" align="center" >生效迄日</td>
					<td class="tbBlue" align="center" >生效日種類</td>
					<td class="tbBlue" align="center" >限制方式</td>
					<td class="tbBlue" align="center" >加碼數</td>
					<td class="tbBlue" align="center" >利率指標</td>
					<td class="tbBlue" align="center" >利率限制敘述</td>
				</tr>
				<tr>
					<td class="tbBlue2" align="center" >
						<SELECT id="LIMIT_TYPE" name="LIMIT_TYPE" fieldName="限制種類" class="required">
						<option value="">全部</option>
						<c:forEach var="map" items="${LIMIT_TYPE_LIST}">
						<option value="${map.key}">${map.value}</option>
						</c:forEach>					
						</SELECT>
					</td>
					<td class="tbBlue2" align="center" style="white-space: nowrap" >
						<input type="text" fieldName="生效起日" id ="EFT_DATES" name="EFT_DATES" datatype="ROCDate" class="required validate-ROCDate" class="textBox2" size="10" maxlength="8" >
						<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('EFT_DATES'))">
					</td>
					<td class="tbBlue2"  align="center" style="white-space: nowrap">
						<input type="text" fieldName="生效迄日" id ="EFT_DATEE" name="EFT_DATEE" datatype="ROCDate" class="required validate-ROCDate" class="textBox2" size="10" maxlength="8" >
						<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('EFT_DATEE'))">
					</td>
					<td class="tbBlue2"  align="center" >
						<SELECT id="EFT_DATE_TYPE" name="EFT_DATE_TYPE" class="required" fieldName="生效日種類">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${EFT_DATE_TYPE_LIST}">
						<option value="${map.key}">${map.value}</option>
						</c:forEach>
						</SELECT>
					</td>
					<td class="tbBlue2"  align="center" >
						<SELECT id="LIMIT_WAY" name="LIMIT_WAY" class="required" fieldName="限制方式">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${LIMIT_WAY_LIST}">
						<option value="${map.key}">${map.value}</option>
						</c:forEach>					
						</SELECT>
					</td>
					<td class="tbBlue2"  align="center" >
						<input type="text" id="IR_RT" name="IR_RT" size="10" datatype="number" class="required validate-number" fieldName="加碼數"/>%
					</td>
					<td class="tbBlue2"  align="center" >
						<SELECT id="IR_RT_IDX" name="IR_RT_IDX" fieldName="利率指標">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${IR_RT_IDX_LIST}">
						<option value="${map.key}">${map.value}</option>
						</c:forEach>	
						</SELECT>
					</td>
					<td class="tbBlue2"  align="center" >
						<input type="text"  id="LIMIT_DESC" name="LIMIT_DESC" class="required"  fieldName="利率限制敘述" />
					</td>
				</tr>
			</table>
		</div>
	</form> 	
</body>
</html>