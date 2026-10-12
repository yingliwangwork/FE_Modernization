<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSD30400.jsp
作者：余凱鈞
功能：通報核準利率設定
完成：2013/09/09

[20240326]
難字調整
高強禾
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD30400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD30400(){
	var grid;
	var valid;
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD3_0400/" + actionName,
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
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {		
			B0111:"btn_UPDATE",
			B0005:"btn_DELETE"
		};
		<dz:grantButtons FUNC_ID="DSD30400" />
	}
	
	//檢核
	function initValidation(){
		Validation.addAllThese([
	   		[ 'validateBASE_CODE', '指標利率種類有誤!',
				function(v){
					return v == $('cBASE_CODE').value ? true : false;
				}
			],
			[ 'validateBEGIN_DATE', '生效起日有誤!',
				function(v){
					return v == $('cBEGIN_DATE').value ? true : false;
				}
			]
		])
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
	}
	
	function defineValid(type){
		if(type=='query'){	
			valid.define( "validate-ROCDate" , { id: "QUERY_DATE" , errMsg:"請輸入正確的有效日期!" } );	
		} else if(type=='update'){
			valid.define( "required" , { id: "BEGIN_DATE" , errMsg:"請輸入正確的有效日期!" } );	
			valid.define( "required" , { id: "VARIABLE" , errMsg:"請輸入X值!" } );			
			valid.define( "required" , { id: "SERV_ADJ" , errMsg:"請輸入服務中心主管調整項利率!" } );	
			valid.define( "required" , { id: "SERV_AMT" , errMsg:"請輸入服務中心主管權限金額!" } );	
			valid.define( "required" , { id: "CAPT_ADJ" , errMsg:"請輸入行政中心組長調整項利率!" } );	
			valid.define( "required" , { id: "CAPT_AMT" , errMsg:"請輸入行政中心組長權限金額!" } );			
			valid.define( "required" , { id: "BOSS_ADJ" , errMsg:"請輸入行政中心主管調整項利率!" } );	
			valid.define( "required" , { id: "BOSS_AMT" , errMsg:"請輸入行政中心主管權限金額!" } );	
			valid.define( "required" , { id: "OTHER_ADJ1" , errMsg:"請輸入調整項1!" } );	
			valid.define( "required" , { id: "OTHER_ADJ2" , errMsg:"請輸入調整項2!" } );			
			valid.define( "required" , { id: "OTHER_ADJ3" , errMsg:"請輸入調整項3!" } );	
		} else if(type=='delete'){
			valid.define( "required" , { id: "BEGIN_DATE" , errMsg:"請輸入正確的有效日期!" } );	
			valid.define( "validateBASE_CODE" , { id: "BASE_CODE" , errMsg:"刪除時請勿修改資料!" } );		
			valid.define( "validateBEGIN_DATE" , { id: "BEGIN_DATE" , errMsg:"刪除時請勿修改資料!" } );					
		} 
	}
	
	
	//點選C區項目帶出B區、D區資料
	function getDataB(record){
	
		//B區	
		$w('BASE_CODE END_DATE SER_NO').each( 
			function(ele) {
				$(ele).value = record[ele] || '';
			}
		);
		
		$w('VARIABLE SERV_ADJ SERV_AMT CAPT_ADJ CAPT_AMT BOSS_ADJ BOSS_AMT OTHER_ADJ1 OTHER_ADJ2 OTHER_ADJ3').each( 
			function(ele) { 
				$(ele).value =  CSRUtil.$fmt(record[ele],"#,###") || 0;
			}
		);
				
		$('BEGIN_DATE').value = toROC(record.BEGIN_DATE||'');	
		$('cBASE_CODE').value = record.BASE_CODE||'';	
		$('cBEGIN_DATE').value = toROC(record.BEGIN_DATE||'');	
		
			ajaxPost( 'qryratemap', { rtnMap: Object.toJSON(record)}
				,function(resp){
					//D區
					var rateMap = resp.rateMap;					
					if(rateMap && rateMap != {}){
						$('table_D').select('span').each(function(ele){	
							ele.update(rateMap[ele.id] || '');
						});
						$('table_D').show();
					} else {
						$('table_D').hide();
					}				
				 	
				},function(resp){
					$('table_D').hide();
					
				}
			);
		
	}
	
	//查詢出C、D區資料
	function getDataCD(resp){
		$('qBASE_CODE').value = $('QUERY_BASE_CODE').value;
		$('qQUERY_DATE').value = toY2K($('QUERY_DATE').value);
	
		//C區
		var rtnList = resp.rtnList;
		if (rtnList && rtnList.length > 0) {
		  grid.load(rtnList);
		} else {
		  grid.load([]);
		}
				
		//清B區
		clearData();
		
		//D區
		var rateMap = resp.rateMap;		
		if(rateMap && rateMap != {}){
			$('table_D').select('span').each(function(ele){	
				ele.update(rateMap[ele.id] || '');
			});
			$('table_D').show();
		} else {
			$('table_D').hide();
		}
	}
	
	//清空B區資料
	function clearData(){
		$('table_B').select('input','select').each(function(ele){						
			ele.value='';
		});
	}
				
	var buttons = {		
		//查詢
		doQuery : function(){ 			
			valid.reset();			
			valid.clear();
			
			//查詢檢核
			defineValid('query');
			if(!valid.validate()){
				return;
			}
			
			ajaxPost( 'query', {BASE_CODE : $('QUERY_BASE_CODE').value, QUERY_DATE : toY2K($('QUERY_DATE').value || '') }
				,function(resp){
					getDataCD(resp);
				},function(resp){
					//C區
			        grid.load(resp.rtnList);
			        
			        //清B區
			        clearData();
			        
			        $('table_D').hide();
				}
			);
		},
		//異動
		doUpdate : function(){
			valid.reset();			
			valid.clear();
			
			var checkedRecord = grid.getCheckedRecord();
			//檢核是否勾選一筆資料
			//if(checkedRecord.length!=1){
			//	alert("請點選下方資料再進行異動!");
			//	return;
			//}
			
			//異動檢核
			defineValid('update');
			if(!valid.validate()){
				return;
			}
			
			if(!confirm('是否確定異動通報核準利率設定?')){			
				return;
			}
			
			if($('BEGIN_DATE').value == getToday()){
				if(!confirm('是否確定異動今日的通報核準利率設定?')){
					return;
				}
			}
					
			//異動內容存成MAP
			var dataMap = {};

			$w('BASE_CODE END_DATE SER_NO').each( 
				function(ele) {
					dataMap[ele] = $(ele).value;
				}
			);
			
			$w('VARIABLE SERV_ADJ SERV_AMT CAPT_ADJ CAPT_AMT BOSS_ADJ BOSS_AMT OTHER_ADJ1 OTHER_ADJ2 OTHER_ADJ3').each( 
				function(ele) {
					dataMap[ele] = $(ele).getValue();
				}
			);
			
			dataMap.BEGIN_DATE = toY2K($('BEGIN_DATE').value || '');
			dataMap.qBASE_CODE = $('qBASE_CODE').value;
			dataMap.qQUERY_DATE = $('qQUERY_DATE').value;
			
			ajaxPost( 'update', {dataMap : Object.toJSON(dataMap)}
				,function(resp){
					getDataCD(resp);
				}
			);
		},
		//刪除
		doDelete : function(){
			valid.reset();			
			valid.clear();
		
			var checkedRecord = grid.getCheckedRecord();
			//檢核是否勾選一筆資料
			if(checkedRecord.length!=1){
				alert("請點選下方資料再進行刪除!");
				return;
			}
			
			//刪除檢核
			defineValid('delete');
			if(!valid.validate()){
				return;
			}
				
			//刪除條件存成MAP
			var dataMap = {						
				'BASE_CODE' : $('BASE_CODE').value,
				'SER_NO' : $('SER_NO').value,
				'BEGIN_DATE' : toY2K($('BEGIN_DATE').value || ''),
				'qBASE_CODE' : $('qBASE_CODE').value,
			    'qQUERY_DATE' : $('qQUERY_DATE').value
			};

			ajaxPost( 'delete', {dataMap : Object.toJSON(dataMap)}
				,function(resp){
					getDataCD(resp);
				}
			);		
		}
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSD30400" , "防止清償通報" , "通報核定層級利率" ,1);
			
			buttonAuth();
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: false,
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return;
						getDataB(records[0]);
					}
				},				
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
					{header:"指標利率種類", key:'BASE_CODE_NM'},
					{header:"生效起日", key:'BEGIN_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"生效迄日", key:'END_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"X值", key:'VARIABLE',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"服務中心主管調整項利率", key:'SERV_ADJ',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"服務中心主管權限金額", key:'SERV_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"行政中心組長調整項利率", key:'CAPT_ADJ',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"行政中心組長權限金額", key:'CAPT_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"行政中心主管調整項利率", key:'BOSS_ADJ',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"行政中心主管權限金額", key:'BOSS_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"調整項1", key:'OTHER_ADJ1',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"調整項2", key:'OTHER_ADJ2',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"調整項3", key:'OTHER_ADJ3',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					<%-- [20240326] 難字調整：輸入人員 --%>
					{header:"輸入人員", key:'INPUT_ID_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"輸入日期", key:'INPUT_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}}				
				]	
			});
					
			initValidation();					
			
			$('btn_QUERY').observe('click',buttons.doQuery);
			$('btn_UPDATE').observe('click',buttons.doUpdate);
			$('btn_DELETE').observe('click',buttons.doDelete);
			
			$('table_D').hide();
			autoFormatToNumber();
			
			PageUI.resize();
			displayMessage();
			
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="10%" align='center'>指標利率種類</td>
				<td class="tbYellow2" width="30%">
					<select id="QUERY_BASE_CODE" class="areaB">
					<option value=''>全部</option>
					<c:forEach var="map" items="${BASE_CODE_LIST}">
						<option value="${map.BASE_CODE}">${map.BASE_NAME}</option>
					</c:forEach></select>
				</td>
				<td class="tbYellow" width="12%" align='center'>有效日期</td>
				<td class="tbYellow2" width="15%">
					<input id="QUERY_DATE" datatype="ROCdate" type="text" class="textBox2" size="8" maxlength="7" />
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('QUERY_DATE'))" /></td>		
				</td>	
				<td class="tbYellow2" align="center">
					<input id="btn_QUERY" type="button" class="button" value="查詢">
				</td>					
			</tr>
			<tr>
				<td align="center" colspan='5'>
					<input id="btn_UPDATE" type="button" class="button" value="異動">
					<input id="btn_DELETE" type="button" class="button" value="刪除">
				</td>
			</tr>
			<input type="hidden" id="qBASE_CODE" name="qBASE_CODE" value='' />
			<input type="hidden" id="qQUERY_DATE" name="qQUERY_DATE" value='' />
		</table>
    <form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="10%">指標利率種類</td>
				<td class="tbYellow2" width="30%" colspan='3'>
					<select id="BASE_CODE" class="areaB" >
					<option value=''>請選擇</option>
					<c:forEach var="map" items="${BASE_CODE_LIST}">
						<option value="${map.BASE_CODE}">${map.BASE_NAME}</option>
					</c:forEach></select>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">生效起日</td>
				<td class="tbYellow2" width= "10%">
					<input id="BEGIN_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="8" maxlength="7" />
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('BEGIN_DATE'))" /></td>	
				</td>
				<td class="tbYellow" width= "8%">X值</td>
				<td class="tbYellow2" width= "10%">
					<input id="VARIABLE" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">服務中心主管調整項利率</td>
				<td class="tbYellow2" width= "10%">
					<input id="SERV_ADJ" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
				<td class="tbYellow" width= "8%">服務中心主管權限金額</td>
				<td class="tbYellow2" width= "10%">
					<input id="SERV_AMT" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">行政中心組長調整利率</td>
				<td class="tbYellow2" width= "10%">
					<input id="CAPT_ADJ" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
				<td class="tbYellow" width= "8%">行政中心組長權限金額</td>
				<td class="tbYellow2" width= "10%">
					<input id="CAPT_AMT" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">行政中心主管調整項利率</td>
				<td class="tbYellow2" width= "10%">
					<input id="BOSS_ADJ" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
				<td class="tbYellow" width= "8%">行政中心主管權限金額</td>
				<td class="tbYellow2" width= "10%">
					<input id="BOSS_AMT" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">調整項1</td>
				<td class="tbYellow2" width= "10%">
					<input id="OTHER_ADJ1" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
				<td class="tbYellow" width= "8%">調整項2</td>
				<td class="tbYellow2" width= "10%">
					<input id="OTHER_ADJ2" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">調整項3</td>
				<td class="tbYellow2" width= "10%" colspan='3'>
					<input id="OTHER_ADJ3" type="text" class="textBox2 validate-number" datatype="number" size='15' maxlength="11" />
				</td>
			</tr>
			<input type="hidden" id="SER_NO" name="SER_NO" value='' />
			<input type="hidden" id="END_DATE" name="END_DATE" value='' />
			<input type="hidden" id="cBASE_CODE" name="cBASE_CODE" value='' />
			<input type="hidden" id="cBEGIN_DATE" name="cBEGIN_DATE" value='' />
		</table>
		<table id="grid" width="100%" class="grid" ></table>
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" width= "8%" colspan='4' align='center'>各類客戶核定層級利率表</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%"></td>
				<td class="tbYellow" width= "8%">一般客戶指標</td>
				<td class="tbYellow" width= "8%">優質客戶指標</td>
				<td class="tbYellow" width= "8%">特定地區客戶</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">服務中心科主管</td>
				<td class="tbYellow2" width= "10%">
					<span id="SERV_A_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="SERV_S_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="SERV_G_RATE"></span>%
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">行政中心組長</td>
				<td class="tbYellow2" width= "10%">
					<span id="CAPT_A_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="CAPT_S_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="CAPT_G_RATE"></span>%
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "8%">行政中心科主管</td>
				<td class="tbYellow2" width= "10%">
					<span id="BOSS_A_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="BOSS_S_RATE"></span>%
				</td>
				<td class="tbYellow2" width= "10%">
					<span id="BOSS_G_RATE"></span>%
				</td>
			</tr>
		</table>
	</form>
</body>
</html>		