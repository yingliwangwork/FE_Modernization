<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" pageEncoding="BIG5"%>


<!--
程式：DSC2_1600.java
作者：陳思涵 
功能：帳務轉出試算
完成：2013-09-14
240614資訊部門內部專用申請書:240611006875自提優化：放款相關帳務查詢畫面移除線上出帳按鈕 BY余凱鈞

[20241030]修改件 CHROME瀏覽器難字調整
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script><!-- 必要 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script><!-- 必要 -->

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script><!-- 檢核訊息的顯示 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script><!-- 目前畫面的版面設定 -->
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSC21600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC21600(){

	var ACNT_GROUP;
	var ACNT_DATE;
	var ACNT_STATUS;
	var Detail_List;
	
	function  initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define("required", { id: "ACNT_DATE" , errMsg: "請輸入結帳日期"} );
	}
	
	//共用AJAX
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC2_1600/" + actionName,
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
	}//END   共用AJAX
	
	// 金額格式化
	var gridFmtRender = function(value) { 
	   return value || value === 0 ? CSRUtil.$fmt(value, '#,##0.#####', 0) : '0'; 
	};
	
	var items = {
		'擔保貸款':'LOAN',
		'擔保貸款-無自用':'NLOAN',
		'利息收入':'INT',
		'應收利息':'RINT',
		'沖其他暫收':'WCA',
		'其他應收款':'DA',
		'沖人工暫收款':'WCB',
		'人工應收款':'DB',
		'管理費用':'EXPENSE',
		//'帳戶管理費':'LSFEE2',
		//'代收火險費':'LSFEE3',
		//'法律事務費':'LSFEE1',
		//'利率調整換約收費':'LSFEE4',
		'催收款項-法院分配款':'COURT',
		'催收款項-提前沖轉':'D_RECEIVE2',
		'收回呆帳':'OVERDUE',
		'催收款項':'RECEIVE1',
		'銀行存款':'BANK',
		'票據':'BILL',
		'預付稅款':'TAX',
		'其他暫收':'CA',
		'沖其他應收':'WDA',
		'人工暫收':'CB',
		'沖人工應收':'WDB',
		'催收款項-提沖不足':'C_RECEIVE1',
		'催收款項-協議不足':'RECEIVE2'
	};

	function showData(rtnMap,Detail_List){
		showNoData();
	
		$$('.areaB').each(function(ele){
			var id = ele.id;
			ele.update(gridFmtRender(rtnMap[id]));
		});
		
		for(var i=0;i<Detail_List.length;i++){
			var item = items[Detail_List[i]['ITEM']];		
		
			if(!(item=='BANK'||item=='BILL')){
				$(item).update(buttons.doLink(Detail_List[i]['ITEM'],item));
			}
			
			$(item+'_CNT').update(Detail_List[i]['CNT']);
			$(item+'_AMT').update(gridFmtRender(Detail_List[i]['AMT']));
			
		}
	
	}
	
	function showNoData(){
		$$('.areaB', '.cnt', '.amt').each(function(ele){
			ele.update();
		});
		
		Object.keys(items).each(function(key){
			$(items[key]).update(key);
		});
					
	}
	
	var buttons = {
		//查詢
		doQuery : function(event){
			valid1.reset();
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			
			ACNT_DATE = toY2K($F('ACNT_DATE'));
			
			ajaxPost( 'query', {ACNT_DATE : ACNT_DATE}
						,function(resp){
							var rtnMap=resp.rtnMap;
							Detail_List=rtnMap.outList;
							ACNT_GROUP = "D";//帳務轉出
							ACNT_STATUS = resp.ACNT_STATUS;
							showData(rtnMap, Detail_List);
							
						},function(resp){
							showNoData();
							ACNT_DATE = '';
						}
							
					);
		},
		
		//退票轉出查詢
		doQueryBack : function(event){
			valid1.reset();
			// 檢核
			if(!valid1.validate()){ 
				return; 
			}
			
			ACNT_DATE = toY2K($F('ACNT_DATE'));
			
			ajaxPost( 'queryBackCheck', {ACNT_DATE : ACNT_DATE}
						,function(resp){
							var rtnMap=resp.rtnMap;
							Detail_List=rtnMap.outList;							
							ACNT_GROUP = "D_BACK";//退票轉出
							ACNT_STATUS = resp.ACNT_STATUS;							
							showData(rtnMap, Detail_List);
							
						},function(resp){
							showNoData();
							ACNT_DATE = '';
						}
							
					);			
		},
		
		//超連結
		doLink :function(val,item){
			var link = new Element('a', { href : "#" }).update(val);
			var LPJSON = {
					action : "<%=dispatcher%>/DSC2_2710/prompt",
					ACNT_DATE : $F('ACNT_DATE'), 
					ACNT_GROUP : ACNT_GROUP, //結帳組別
					ACNT_STATUS : ACNT_STATUS,//結帳狀況
					QUERY_TYPE : item					
				}
			link.observe('click',function(event){
				CSRUtil.linkTo(LPJSON, 'form1');
			});
			return link;
		}
	};
	
	return{
		initApp:function() {
			PageUI.createPageWithAllBodySubElement('DSC21600', '收息帳務', '帳務轉出試算');
	
			initValidation();
							
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_queryBack').observe('click', buttons.doQueryBack);
						
			//PageUI.resize();
		    fix();				
			displayMessage();			
		}
	};
	
	
	
	

}
</script>
</head>
<body>


<form name="form1" id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
<table id="table1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="20%">結帳日期</td>
		<td class="tbYellow2" width="60%">
			<input id="ACNT_DATE" type="text" class="textBox2" size='12' maxlength='10' datatype="ROCDate" value="${TODAY}"/> 
			<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('ACNT_DATE'))">
		</td>
		<td class="tbYellow2" width="20%">
			<input id="btn_query" type="button" class="button" value="查詢" />
			<input id="btn_queryBack" type="button" class="button" value="退票轉出查詢" />
		</td>
	</tr>
</table>

<table id="table2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" 	>
	<tr align='center'>
		<td class="tbBlue" width="10%" >項目</td>
		<td class="tbBlue" width="10%">借方金額</td>
		<td class="tbBlue" width="10%">借方件數</td>
		<td class="tbBlue" width="10%">貸方金額</td>
		<td class="tbBlue" width="10%">貸方件數</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='LOAN' >擔保貸款</td>
		<td class="tbBlue2">
		<Div id='LOAN_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LOAN_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow"  class='item' width="10%" id='NLOAN' >擔保貸款-無自用</td>
		<td class="tbBlue2">
		<Div id='NLOAN_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='NLOAN_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='INT'>利息收入</td>
		<td class="tbBlue2">
		<Div id='INT_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='INT_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" >
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='RINT'>應收利息</td>
		<td class="tbBlue2">
		<Div id='RINT_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='RINT_CNT' class='cnt' align='right'></Div>	
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='WCA'>沖其它暫收</td>
		<td class="tbBlue2">
		<Div id='WCA_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='WCA_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='DA'>其他應收款</td>
		<td class="tbBlue2">
		<Div id='DA_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='DA_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='WCB'>沖人工暫收款</td>
		<td class="tbBlue2">
		<Div id='WCB_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='WCB_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='DB'>人工應收款</td>
		<td class="tbBlue2">
		<Div id='DB_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='DB_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
		<tr>
		<td class="tbYellow" class='item' width="10%" id='EXPENSE'>管理費用</td>
		<td class="tbBlue2">
		<Div id='EXPENSE_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='EXPENSE_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<!-- 
	<tr>
		<td class="tbYellow" class='item' width="10%" id='LSFEE2'>帳戶管理費</td>
		<td class="tbBlue2">
		<Div id='LSFEE2_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LSFEE2_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='LSFEE3'>代收火險費</td>
		<td class="tbBlue2">
		<Div id='LSFEE3_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LSFEE3_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='LSFEE1'>法律事務費</td>
		<td class="tbBlue2">
		<Div id='LSFEE1_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LSFEE1_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='LSFEE4'>利率調整換約收費</td>
		<td class="tbBlue2">
		<Div id='LSFEE4_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='LSFEE4_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	-->
	<tr>
		<td class="tbYellow" class='item' width="10%" id='COURT'>催收款項-法院分配款</td>
		<td class="tbBlue2">
		<Div id='COURT_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='COURT_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='D_RECEIVE2'>催收款項-提前沖轉</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE2_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='D_RECEIVE2_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='OVERDUE'>收回呆帳</td>
		<td class="tbBlue2">
		<Div id='OVERDUE_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='OVERDUE_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='RECEIVE1'>催收款項</td>
		<td class="tbBlue2">
		<Div id='RECEIVE1_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbBlue2">
		<Div id='RECEIVE1_CNT' class='cnt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='BANK'>銀行存款</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='BANK_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='BANK_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='BILL'>票據</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='BILL_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='BILL_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='TAX'>預付稅款</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='TAX_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='TAX_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='CA'>其他暫收</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CA_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CA_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='WDA'>沖其他應收</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='WDA_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='WDA_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='CB'>人工暫收</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CB_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='CB_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
<tr>
		<td class="tbYellow" class='item' width="10%" id='WDB'>沖人工應收</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='WDB_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='WDB_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='C_RECEIVE1'>催收款項-提沖不足</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='C_RECEIVE1_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='C_RECEIVE1_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" class='item' width="10%" id='RECEIVE2'>催收款項-協議不足</td>
		<td class="tbBlue2">
		</td>
		<td class="tbBlue2">
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE2_AMT' class='amt' align='right'></Div>
		</td>
		<td class="tbYellow2" width="10%" align='center'>
		<Div id='RECEIVE2_CNT' class='cnt' align='right'></Div>
		</td>
	</tr>

	<tr>
		<td class="tbYellow" width="20%">總計</td>
		<td class="tbYellow2" width="20%" align="right" ><span id="DTOTAL_AMT" class='areaB' ></span></td>
		<td class="tbYellow2" width="20%" align="right"><span id="DTOTAL_CNT" class='areaB' ></span></td>
		<td class="tbYellow2" width="20%" align="right"><span id="CTOTAL_AMT" class='areaB' ></span></td>
		<td class="tbYellow2" width="20%" align="right"><span id="CTOTAL_CNT" class='areaB' ></span></td>
	</tr>
	<tr class="tbYellow" >
		<td class="tbYellow">結帳人員</td>
		<td class="tbYellow2" colspan="4">
			<%-- [20241030] 難字調整 --%>
			<span id="EMP_NAME" class='areaB' style="font-family:'EUDC'"></span>
		</td>
	</tr>
</table>
</form>
</body>
</html>