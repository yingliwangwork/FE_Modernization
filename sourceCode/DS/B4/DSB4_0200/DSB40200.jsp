<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB40200.jsp
作者：李俊德
功能：匯款進度查詢
完成：

 [20180129] 修改件 
  201712契約書改版

 [20180620]
   列印改成另存新檔形式
 @ 劉芷均
 [20201130]修改件  
   外網多筆個資遮蔽  @author 何宗霖
 [20210127] 問題單編號 20200824-0050  因隔日退匯並不會把匯款紀錄檔(DTDSB200)刪除，畫面上仍查的到資料。當日退匯件則是在此畫面會查不到。
        	將畫面上的【退匯再處理件】(B200.FAIL_REMIT現行已無使用)，改成【隔日退匯】(B200.IS_FAIL=1代表隔日退匯件)，避免查詢時有所誤解。
        	BY余凱鈞

[20240613]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<%-- [20240613] 難字調整 --%>
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
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', new DSB40200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//查詢條件顯示區塊
var reqMap = {};

//--------------------------------------------------------------------------
//	以下為DSB40200() public method,放在 return 中
//--------------------------------------------------------------------------  
function DSB40200(){
	
	var grid1;
	var day = getToday();
	var today= day.substring(0,3)+"/"+day.substring(3,5)+"/"+day.substring(5,7);
	<%--[20201130]外網多筆個資遮蔽
	var preTd;
	var preBORROW_NAME_MASK, preBORROW_ID_MASK, preREMIT_ACCOUNT_NM_MASK, preACCOUNT_ID_MASK, preACCOUNT_NAME_MASK;
	--%>
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
			B0100:"btn_confirm1"<%--新放匯款初審--%>,
			B0101:"btn_checkInput"<%--匯款檢核輸入--%>,
			//B0102:"btn_confirm2"<%--新放匯款審核--%>,
			B0103:"btn_confirmM"<%--理財型生效審核--%>,
			B0068:"btn_reject"<%--退件--%>,
			B0071:"btn_cancelRemit"<%--取消匯款--%>,
			B0253:"btn_print"<%--匯款明細列印--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB40200" ignored="false"/>
	}

	var valid;
	
	var actions = {
	
		//共用ajax
		ajaxPost : function( actionName, params, successAction){	
			new Ajax.Request( "<%=dispatcher%>/DSB4_0200/" + actionName,{  
					parameters: params, 
					onSuccess: function(response){ successAction(response.responseJSON );
				}
			});
		},
		// 查詢
		doQuery : function(){

			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			
			//自動轉大寫
			$('QUERY_COND').value = $F('QUERY_COND').toUpperCase();
			
			//preTd = null ;//再次查詢時清除preTd，避免顯示到上一次的暫存個資
			
			reqMap = {};
			reqMap.QUERY_KIND = $F('QUERY_KIND');
			reqMap.QUERY_COND = $F('QUERY_COND');
			reqMap.REMIT_PROCESS = $F('REMIT_PROCESS');
			reqMap.QUERY_DATE = $F('QUERY_DATE') ? toY2K($F('QUERY_DATE')) : '';
			reqMap.CRED_DEPT = $F('CRED_DEPT');
			reqMap.REMIT_DEPT = $F('REMIT_DEPT');
			actions.ajaxPost( 'query' ,  { reqMap : Object.toJSON(reqMap) } ,
				function(resp){
					actions.doLoadData(resp);
				}
			);				
		},
		// 列印
		doPrint : function(){		
		
			//勾選的資料存成list
			var checkRecord = grid1.getCheckedRecord();	
			if(checkRecord.length == 0){			
				alert("請至少選取一筆資料");
				return;
			}	
			
			if(checkRecord.length > 10){			
				alert("選取資料不能超過10筆");
				return;
			}
			
			<%-- [20180620] 列印改成另存新檔形式--%>
			var parameters = {
	    		rtnList :  Object.toJSON(checkRecord)
	    		,REPORT_ID: 'DSA1_1301'
	    		,LINK_FORM: 'DSA11300'
	    	};
	    	RPTUtil.downloadFile ( "${dispatcher}/DSA1_1301/prompt" , parameters, true );
	
			
		},
		// 新放匯款初審
		doConfirm1 : function(){

			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length == 0){
				alert('請至少選取一筆資料，再作新放匯款初審!');
				return;
			}
			
			var B200List = [];
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];
				var map = {};
				map['APPLY_ID'] = obj['APPLY_ID'];
				B200List.push(map);
			}
			
			var allDataList = grid1.getAllRecords();
			
			/* [20180129] 201712契約書改版*/		
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}
			if(selectedList.length == 1 && check_REMIT_TYPE > 0){
				alert('借新還舊件無法作業!!');
				return;
			}
			if(check_REMIT_TYPE > 0 ){
			   if(!confirm("選取資料中有借新還舊件，將自動忽略不處理")){
			      return;
			   }
			}
			
			actions.ajaxPost( 'confirm1' ,  { reqMap : Object.toJSON(reqMap), B200List : Object.toJSON(B200List), AllB200List : Object.toJSON(allDataList) } ,
				function(resp){
					actions.doLoadData(resp);
				}
			);				
		},
		// 新放匯款審核
		/*
		doConfirm2 : function(){

			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length == 0){
				alert('請至少選取一筆資料，再作新放匯款審核!');
				return;
			}
			
			actions.ajaxPost( 'confirm2' ,  { reqMap : Object.toJSON(reqMap), B200List : Object.toJSON(selectedList) } ,
				function(resp){
					actions.doLoadData(resp);
				}
			);				
		}, 
		*/
		// 理財型生效審核
		doConfirmM : function(){

			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length == 0){
				alert('請至少選取一筆資料，再作理財型生效審核!');
				return;
			}
		
			/* [20180129] 201712契約書改版*/		
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}
			if(selectedList.length == 1 && check_REMIT_TYPE > 0){
				alert('借新還舊件無法作業!!');
				return;
			}
			if(check_REMIT_TYPE > 0 ){
			   if(!confirm("選取資料中有借新還舊件，將自動忽略不處理")){
			      return;
			   }
			}
			
			actions.ajaxPost( 'confirmM' ,  { reqMap : Object.toJSON(reqMap), B200List : Object.toJSON(selectedList) } ,
				function(resp){
					actions.doLoadData(resp);
				}
			);				
		},
		// 取消匯款
		doCancelRemit : function(){
			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length == 0){
				alert('請至少選取一筆資料，再作取消匯款!');
				return;
			}
			
			/* [20180129] 201712契約書改版*/		
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}
			if(selectedList.length == 1 && check_REMIT_TYPE > 0){
				alert('借新還舊件無法作業!!');
				return;
			}
			if(check_REMIT_TYPE > 0 ){
			   if(!confirm("選取資料中有借新還舊件，將自動忽略不處理")){
			      return;
			   }
			}
			
			actions.ajaxPost( 'cancelRemit' ,  { reqMap : Object.toJSON(reqMap), B200List : Object.toJSON(selectedList) } ,
				function(resp){
					actions.doLoadData(resp);
				}
			);				
		},
		
		//退件-錯誤歸類
		doLink : function(){
			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length != 1){
				alert('請選取單筆資料作退件!');
				return;
			}
			
			if($F('CANCEL_REASON') == '0'){
				alert('請選擇退件原因!');
				return;
			}
			
			/* [20180129] 201712契約書改版*/		
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}
			if(check_REMIT_TYPE > 0 ){
			   alert("借新還舊件無法作業!!") 
			    return;	
			}
			
			var APPLY_ID_S = selectedList[0].APPLY_ID || '';
							
			actions.ajaxPost( 'link' ,  { 'APPLY_ID' : APPLY_ID_S, 'B200List' : Object.toJSON(selectedList), 'CANCEL_REASON' : $F('CANCEL_REASON') } ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){	
						if (resp.IsWorkCell) {
							popupWin.popup({
								src: '/DSWeb/servlet/HttpDispatcher/DSA2_1901/prompt',
								parameters: {'APPLY_ID':APPLY_ID_S, 'LINK_FROM':'DSB4_0200'},
								width: 800, 
								height: 450,
								scrolling : 'no'
							});	
							popupWin.callbackHandler = function(){actions.doReject();};
						} else {
							actions.doReject();
						}
					}
				}
			);	
		},		
		// 退件
		doReject : function(){

			var selectedList = grid1.getCheckedRecord();	
			/*if(selectedList.length != 1){
				alert('請選取單一資料作退件!');
				return;
			}
			
			if($F('CANCEL_REASON') == '0'){
				alert('請選擇退件原因!');
				return;
			}*/
			
			/* [20180129] 201712契約書改版*/		
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}
			if(check_REMIT_TYPE > 0 ){
			    alert("借新還舊件無法作業!!") 
			    return;	
			}
			
			actions.ajaxPost( 'reject' ,  { reqMap : Object.toJSON(reqMap), B200List : Object.toJSON(selectedList), CANCEL_REASON : $F('CANCEL_REASON') } ,
				function(resp){
					if (CSRUtil.isSuccess(resp)){	
						$('CANCEL_REASON').value = '0';
					}
					actions.doLoadData(resp);
				}
			);				
		},
		// 超連結至DSB4_0300(匯款檢核輸入)畫面
		doCheckInput : function(){
		
			var selectedList = grid1.getCheckedRecord();	
			if(selectedList.length == 0){
				alert('請選取一筆資料，再作匯款檢核輸入!');
				return;
			} else if(selectedList.length > 1){
				alert("只能選取一筆資料作匯款檢核輸入!");
				return;
			}
			
			/* [20180129] 201712契約書改版*/
			var check_REMIT_TYPE = 0;			
			for( var i = 0 ; i < selectedList.length ; i++ ){
				var obj = selectedList[i];				
				var  REMIT_TYPE = obj['REMIT_TYPE'];
				if(REMIT_TYPE == '40'){
					check_REMIT_TYPE = check_REMIT_TYPE + 1;
				}				
			}			
			if(check_REMIT_TYPE > 0 ){
				alert("借新還舊件無法作業!!") 
			    return;			  
			}
			
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSB4_0300/prompt";	
			LP_JSON.APPLY_ID = selectedList[0].APPLY_ID; //受理編號
			LP_JSON.SER_NO = selectedList[0].SER_NO; //序號
			LP_JSON.REMIT_PROCESS = selectedList[0].REMIT_PROCESS; //匯款進度
			CSRUtil.linkTo(LP_JSON, 'form1');
		},
		// 超連結至DSB4_0220(匯款審核查詢)畫面
		doLinkByRemitAmt : function(APPLY_ID, SER_NO){
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSB4_0220/prompt";	
			LP_JSON.APPLY_ID = APPLY_ID; //受理編號
			LP_JSON.SER_NO = SER_NO; //序號
			CSRUtil.linkTo(LP_JSON, 'form1');
		},
		// 超連結至DSB4_0210(匯款審核進度查詢)畫面
		doLinkByRemitProcess : function(APPLY_ID, SER_NO){
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSB4_0210/prompt";	
			LP_JSON.APPLY_ID = APPLY_ID; //受理編號
			LP_JSON.SER_NO = SER_NO; //序號
			CSRUtil.linkTo(LP_JSON, 'form1');
		},
		doLoadData : function(resp){
			
			var showSumList = $F('QUERY_KIND') == '0' && ( $F('REMIT_PROCESS') == '10' || $F('REMIT_PROCESS') == '11' || $F('REMIT_PROCESS') == '12' || $F('REMIT_PROCESS') == '21' || $F('REMIT_PROCESS') == '30' || $F('REMIT_PROCESS') == '99' || $F('REMIT_PROCESS') == 'XX');

			if (CSRUtil.isSuccess(resp)){
				rtnList = resp.rtnList ? resp.rtnList : [];
				sumTotalList = resp.sumTotalList ? resp.sumTotalList : [];
				if (showSumList){
					grid1.load(rtnList, sumTotalList);
				} else {
					grid1.load(rtnList);
				}
			} else {
				if (showSumList){
			        var sumTotalMap = {
			        	APPLY_ID : '合計',
			        	BORROW_ID : '0件', 
			        	REMIT_TYPE_NM : '<div align="right">0元</div>'
			        };

					var totalObj = [
						{text: "" ,textAlign : 'center' , value: sumTotalMap}
					];

					grid1.load([], totalObj);
					
				} else {
					grid1.load([]);
				}
			}
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSB40200" , "匯款作業", "匯款進度查詢" );
			
			grid1 = new TableUI(
				{	
					table:$('grid1'), pageSize: 20, allSortable: true, overDiv: false, split:["LOAN_ID"], 
					autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true 
					},
					column:[
						<%--[20201130]外網多筆個資遮蔽_增加切換按鈕
						{ header: "個資顯示", key: "",
							render:function(rec, val, sn){
								var button = new Element('button',{ 'type' : 'button' , 'class' : 'button' });
								button.update("點我");
								button.observe('click', function(){
									if(preTd){
										grid1.setValueToTD(preTd, "BORROW_NAME_MASK", preBORROW_NAME_MASK);
										grid1.setValueToTD(preTd, "BORROW_ID_MASK", preBORROW_ID_MASK);
										grid1.setValueToTD(preTd, "REMIT_ACCOUNT_NM_MASK", preREMIT_ACCOUNT_NM_MASK);
										grid1.setValueToTD(preTd, "ACCOUNT_ID_MASK", preACCOUNT_ID_MASK);
										grid1.setValueToTD(preTd, "ACCOUNT_NAME_MASK", preACCOUNT_NAME_MASK);
									}
									preTd = this;
									preBORROW_NAME_MASK = rec['BORROW_NAME_MASK'];
									preBORROW_ID_MASK = rec['BORROW_ID_MASK'];
									preREMIT_ACCOUNT_NM_MASK = rec['REMIT_ACCOUNT_NM_MASK'];
									preACCOUNT_ID_MASK = rec['ACCOUNT_ID_MASK'];
									preACCOUNT_NAME_MASK = rec['ACCOUNT_NAME_MASK'];
									grid1.setValueToTD(this, "BORROW_NAME_MASK", rec['BORROW_NAME']);
									grid1.setValueToTD(this, "BORROW_ID_MASK", rec['BORROW_ID']);
									grid1.setValueToTD(this, "REMIT_ACCOUNT_NM_MASK", rec['REMIT_ACCOUNT_NM']);
									grid1.setValueToTD(this, "ACCOUNT_ID_MASK", rec['ACCOUNT_ID']);
									grid1.setValueToTD(this, "ACCOUNT_NAME_MASK", rec['ACCOUNT_NAME']);
								});
	                			return button;
							},
							attrs:{rowSpan:2}
						},--%>
						{ header: "受理編號", key: "APPLY_ID"},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						{ header: "借款人ID", key: "BORROW_ID"},
						{ header: "匯款種類", key: "REMIT_TYPE_NM"},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						{ header: "匯款帳號∕動撥帳號", key: "REMIT_ACCOUNT_NM",attrs:{colSpan:2},
							render:function(record, value){
				                 	return value.replace('\r\n', '<BR>').replace('\n', '<BR>'); 
							}
						},
						{ header: "核准金額", key: "AGREE_AMT"},
						{ header: "隔日退匯", key: "IS_FAIL"},
						{ header: "處理進度", key: "REMIT_PROC_NM", attrs:{rowSpan:2}, 
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value;
				                	link.onclick = function( event ) { actions.doLinkByRemitProcess( record.APPLY_ID, record.SER_NO ); };
				                 	return link;
							}
						},
						{ header: "理財型帳號", key: "LOAN_ID_M", attrs:{rowSpan:2}},
						{ header: "火險掛帳管費切結", key: "FIRE_EXP"},
						{ header: "匯款方式", key: "REMIT_KIND", attrs:{rowSpan:2}},
						{ header: "清償帳號", key: "B400_LOAN_ID"},
						{ header: "清償原貸", key: "B400_REFER_ID"},
						{ header: "貸款帳號", key: "LOAN_ID"}, 
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						<%-- [20240613] 難字調整：借款人姓名 --%>
						{ header: "借款人姓名", key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }}, 
						{ header: "匯款金額", key: "REMIT_AMT", attrs:{align:'right'},
							render:function(record, value){
							  		var link = document.createElement( "a" );
				                 	link.href = "#";
				                 	link.innerHTML = value ? CSRUtil.$fmt( value, "#,###" ) : 0;
				                	link.onclick = function( event ) { actions.doLinkByRemitAmt( record.APPLY_ID, record.SER_NO ); };
				                 	return link;
							}
						},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						{ header: "匯款∕動撥帳號戶ID", key: "ACCOUNT_ID"},
						<%--[20201130]外網多筆個資遮蔽_預設為遮蔽後欄位--%>
						<%-- [20240613] 難字調整：匯款/動撥帳號戶名 --%>
						{ header: "匯款∕動撥帳號戶名", key: "ACCOUNT_NAME", attrs:{ style:"font-family:'EUDC'" }},
						{ header: "匯款日期", key: "REMIT_DATE",
							render : function(record , value){
								return value ? Date.toROC(value) : ''; 
							}
						},
						{ header: "分隔帳戶", key: "SPR_ACCOUNT_NM"},
						{ header: "借款期間", key: "LOAN_DATE_PERIOD"},
						{ header: "清償金額", key: "B400_LOAN_AMT"},
						<%-- [20240613] 難字調整：清償借款人姓名 --%>
						{ header: "清償借款人姓名", key: "B400_BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }}
					]
					,validateRecord:function(rec,sn){
						if(!rec['REMIT_DATE']){ return false; }
						return Date.toROC(rec['REMIT_DATE']) == today;
					} 
					,pageChange:function(pageNO){
						<%-- [20240613] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						if(grid1.isNew){return;}
						$$('table.grid td[name=REMIT_DATE]').each(function(elem){
							if(elem.innerHTML != today){
								var tr = elem.up('tr');
								var dataObjs = [ tr.dataObj ];
								setValidRecord(elem , dataObjs , false );
							}
						});
						grid1.validTable(); 
					}  
				}
			);

			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validQueryCond', '請輸入正確查詢條件!', function(v , node) { 
					if($F('QUERY_KIND') != '0' && $F('QUERY_COND') == '' ){
						return false;
					}else if($F('QUERY_KIND') == '1' && $F('QUERY_COND').length != 11 ){
						return false;
					}else if($F('QUERY_KIND') == '2' && $F('QUERY_COND').length != 10 ){
						return false;
					}else if($F('QUERY_KIND') == '3' && $F('QUERY_COND').length != 10 ){
						return false;
					}else{
						return true;
					}
				}]
				
			]);
			
			$('btn_query').observe('click', actions.doQuery ); // 查詢按鈕
			
			$('btn_print').observe('click', actions.doPrint ); // 查詢按鈕
			
			$('btn_confirm1').observe('click', actions.doConfirm1 ); // 新放匯款初審按鈕
			
			$('btn_checkInput').observe('click', actions.doCheckInput ); // 匯款檢核輸入按鈕
			
			//$('btn_confirm2').observe('click', actions.doConfirm2 ); // 新放匯款審核按鈕
			
			$('btn_confirmM').observe('click', actions.doConfirmM ); // 理財型生效審核按鈕
			
			//$('btn_reject').observe('click', actions.doReject ); // 退件按鈕
			$('btn_reject').observe('click', actions.doLink ); // 退件按鈕
			
			$('btn_cancelRemit').observe('click', actions.doCancelRemit ); // 取消匯款按鈕
			
			buttonAuth();
			
			autoFormatToDate();

			displayMessage();
			
			//若是回上頁所發送回來的，還原 form 的輸入欄值後，執行重新查詢
			if (CSRUtil.isBackLink('form1')){
				actions.doQuery();
			}
			
		}// end initApp()--
	}// end return--
}// end DSB40200

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form name="form1" id="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td class="tbYellow">查詢方式</td>
				<td class="tbYellow2" width="5%">
					<select name="QUERY_KIND" id="QUERY_KIND">
						<option value="0"></option>
						<c:forEach var="map" items="${QUERY_KIND_LIST}">
							<option value="${map.key}" >${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2">
					<input name="QUERY_COND" id='QUERY_COND' type="text"class="textBox2 validQueryCond" fieldName="查詢方式" size="13" maxlength="11">
				</td>
				<td class="tbYellow">匯款進度</td>
				<td class="tbYellow2"  colspan="3">
					<select name="REMIT_PROCESS" id="REMIT_PROCESS" fieldName="匯款進度">
						<option value="00">全部</option>
						<c:forEach var="map" items="${REMIT_PROCESS_LIST}">
							<option value="${map.key}" >${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
				    <input type="button" id="btn_query" value="查詢" class="button">
				    <input type="button" name="btn_print" id="btn_print" class="button" value="列印" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">匯款日期</td>
				<td class="tbYellow2" colspan="2">
					<input name="QUERY_DATE" id="QUERY_DATE" datatype="ROCDate" type="text" class="textBox2 validate-ROCDate" fieldName="匯款日期" size="10" maxlength="7"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('QUERY_DATE'))">
				</td>
				<td class="tbYellow">承辦科別</td>
				<td class="tbYellow2">
					<select name="CRED_DEPT" id="CRED_DEPT" fieldName="承辦科別">
						<c:if test="${CRED_DEPT_ALL eq true}">
							<option value="0">全部</option> 
						</c:if>
						<c:forEach var="map" items="${CRED_DEPT_LIST}">
							<option value="${map.key}" <c:if test="${Creddept eq map.key}"><c:out value=" selected"/></c:if>>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow">匯款案件單位</td>
				<td class="tbYellow2">
					<select name="REMIT_DEPT" id="REMIT_DEPT" fieldName="匯款案件單位">
						<option value=""></option>
						<c:forEach var="map" items="${REMIT_DEPT_LIST}">
							<option value="${map.key}" >${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
			<tr align="center">
				<td colspan="5">
					<input type="button" id="btn_confirm1" value="新放匯款初審" class="button">
					<input type="button" id="btn_checkInput" value="匯款檢核輸入" class="button">
					<input type="button" id="btn_confirmM" value="理財型生效審核" class="button">
					<input type="button" id="btn_reject" value="退件" class="button">
					<input type="button" id="btn_cancelRemit" value="取消匯款" class="button">
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" >
			<tr>
				<td>
					退件原因：
					<select name="CANCEL_REASON" id="CANCEL_REASON" fieldName="退件原因">
						<c:forEach var="map" items="${CANCEL_REASON_LIST}">
							<option value="${map.key}" <c:if test="${0 eq map.key}"><c:out value=" selected"/></c:if>>${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
		<table id='grid1' width="100%"></table>
	</form>
</body>
</html>