<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11700.jsp
作者：張智翔
功能：實體訴訟費用作業。
完成：繼承管理作業

[20240215]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%-- 匯入外部Javascript 與 css --%>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>

<%--[20240215]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript'>

// 產生畫面物件
var DSE11700 = new DSE11700();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSE11700.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11700(){

	//貸款帳號
	var LOAN_ID = '<c:out value="${LOAN_ID}"/>';

	var checkIDList = [];
		
	//相對人下拉選單
	var OPPOSITE_List;
	
	//Table UI
	var grid;			
	
	//檢核
	var valid1;		

	//畫面檢核
	function initValidation(){		
		//查詢用檢核
		Validation.addAllThese([
			[ 'checkID',  '身份證字號格式錯誤',
				function(v){  
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v );
				}
			],
			[ 'checkBothOfIDName',  '請輸入被繼承人ID或被繼承人姓名!',
				function(){ 
					if(!$('ANCESTOR_ID').value && !$('ANCESTOR_NAME').value){
						return false;
					}
					return true;
				}
			]
			
		]);
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define( "checkBothOfIDName" , { id: "ANCESTOR_ID"  } );	
		valid1.define( "checkID" , { id: "ANCESTOR_ID"  } );	
		valid1.define( "checkBothOfIDName" , { id: "ANCESTOR_NAME"  } );
		
		
	}	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1700/" + actionName,
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
	
	
	
	//按鈕功能
	var buttons = {
	
		//查詢
		doQuery : function(){	
			if(!valid1.validate()){
				return;
			}
			
			var reqMap = {
				ANCESTOR_ID : $F('ANCESTOR_ID'),
				ANCESTOR_NAME : $F('ANCESTOR_NAME')
			}
			
			//發送ajax
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){	
					grid.load(resp.rtnList||[]);
				},
				function(resp){	
					grid.load([]);						
				}
			);				
		},
		
		//輸入繼承資料
		doInput : function(){
		
			var allRecords = grid.getAllRecords();			
			if(!allRecords || allRecords.length == 0 ){
				alert('查無被繼承人資料，無法輸入');
				return;
			}

			var last_id = allRecords[0]['ANCESTOR_ID'];
			for(var i = 0 ; i < allRecords.length ; i ++){
				if( last_id != allRecords[i]['ANCESTOR_ID']){				
					alert('該被繼承人姓名有不同ID，請改用被繼承人ID查詢');
					return;
				}
				last_id = allRecords[i]['ANCESTOR_ID'];
			}
			
			//發送ajax
			ajaxPost( 'input' , { allRecords : Object.toJSON(allRecords)},
				function(resp){	
					var ancestorMap = resp.ancestorMap;					
					var LP_JSON = {
						action :'<%=dispatcher%>/DSE1_1701/prompt',
						ANCESTOR_ID : ancestorMap.ANCESTOR_ID,  //被繼承人ID
						ANCESTOR_NAME :  ancestorMap.ANCESTOR_NAME_H,//被繼承人姓名
						BIRTHDAY 	:  ancestorMap.BIRTHDAY,	 //被繼承人出生年月日
						ANCESTOR_KND 	:  ancestorMap.ANCESTOR_KND	 //被繼承人種類:0借款人、1保證人、2繼承人
					}
					CSRUtil.linkTo(LP_JSON , 'form');		
				}
			);		
		}
		
		
		
	}

	//各種action
	var actions = {		
		//轉大寫
		upperCase : function(event){
			event.target.value = event.target.value.toUpperCase();
		}
	};

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSE11700", "法務件", "繼承管理作業" );					
				
				
				//table B
				grid = new TableUI ( {
					table: $('grid'),  allSortable:false, pageSize: 10, 		
					<%-- [20240215] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [	
								{header: '貸款帳號' , key : 'LOAN_ID'},
								{header: '原貸帳號' , key : 'REFER_ID'},
								{header: '借款人' , key : 'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header: '保證人' , key : 'GUARANTOR_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header: '被繼承人' , key : 'ANCESTOR_NAME', attrs:{style:"font-family:'EUDC'"}, <%-- [20240215]難字調整 --%>
									render : function(rec , val){
										if(val){
											var link = new Element("a" , { href : "#" } ).update( val );
											link.observe( 'click', function (event){ 													
												var LP_JSON = {
													action :'<%=dispatcher%>/DSE1_1701/prompt',
													ANCESTOR_ID : rec.ANCESTOR_ID,
													ANCESTOR_NAME :  val,
													BIRTHDAY 	:  rec.BIRTHDAY,
													ANCESTOR_KND 	:  rec.ANCESTOR_KND	
												}
												CSRUtil.linkTo(LP_JSON , 'form');		
											});		
											return link;
										}else{
											return "";
										}				
									}
								},
								{header: '擔保品門牌' , key : 'GAGE_ADDR' ,attrs:{align:'left',style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
								{header: '法務進度' , key : 'LAW_PROCESS_NM'},
								{header: '法務進度日' , key : 'LAW_PROCESS_DATE',
									render : function(rec , val){
										return val ? toROC(val)  : '';									
									}
								},
								{header: '承辦法務' , key : 'INPUT_NM', attrs:{style:"font-family:'EUDC'"} }<%-- [20240215]難字調整 --%>
							]	
									
				});	
				//click事件
				$('btn_query').observe( 'click', buttons.doQuery);
				$('btn_input').observe( 'click', buttons.doInput);
				$('ANCESTOR_ID').observe( 'change', actions.upperCase);
				fix();

				displayMessage();
				
				initValidation();		

				if(CSRUtil.isBackLink('form')){    
					 buttons.doQuery();
				}else{
					var paramANCESTOR_ID='<c:out value="${ANCESTOR_ID}"/>';
					if(paramANCESTOR_ID){
						$('ANCESTOR_ID').value=paramANCESTOR_ID;
						buttons.doQuery();
					}
				}
			}
	};
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="10%" align="left" >
					被繼承人ID
				</td>
				<td class="tbYellow2" >
					<input id="ANCESTOR_ID"  name = "ANCESTOR_ID" type="text" class="textBox2" size = "12" maxlength = "10" fieldName = "被繼承人ID"/>
				</td>
				<td class="tbYellow" width="12%" align="left" >
					被繼承人姓名
				</td>
				<td class="tbYellow2" >
					<input id="ANCESTOR_NAME"  name = "ANCESTOR_NAME" type="text" class="textBox2" fieldName="被繼承人姓名" alt="ch"/><%-- [20240215]難字調整 --%>
				</td>				
				<td class="tbYellow2">
					<input id = "btn_query" type = "button" class = "button" value = "查詢"   />	
				</td>
			</tr>	
			<tr>
				<td class="tbYellow2" colspan = "5" align = "center">
					<input id = "btn_input" type = "button" class = "button" value = "輸入繼承資料"   />	
				</td>
			<tr>
		</table>
		<table id = "grid" ></table>		
	</form>	
</body>
</html>