<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC30200.jsp
作者：卓達瑋
功能：銀行轉帳申請
完成：2013/04/18
      2018-11-29申請書-郵局核印作業：新增郵局轉帳申請，需先郵局核印過方得開始轉帳扣款
      
[20211123] 銀行轉帳申請作業，若同時勾選多筆案件按確認，則跳出提醒訊息
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%--[20241101]難字css  --%>
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

Event.observe(window, 'load', new DSC30200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC30200(){
	var grid;		

	//檢核
	var valid1;	
	var valid2;	
	var gridList;
	
	//檢核欄位
	function initValidation(){
		Validation.addAllThese( [
			[ 'chkBorrowID', '借款人ID格式錯誤', function( v ) { return chkUsableID1($F('BORROW_ID'));}]
		] );
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});		
        //valid1.define('checkROCID' , [{ id : "BORROW_ID" , errMsg:"借款人ID格式錯誤"}] );	
        valid1.define('chkBorrowID' , [{ id : "BORROW_ID" }] );	
	    
	    Validation.addAllThese( [
			[ 'chkTrustID', '委託人ID格式錯誤', function( v ) { return chkUsableID2($F('TRUST_ID'));}]
		] ); 
		valid2 = new Validation("form1", { focusOnError:true, immediate:false});		
        //valid2.define('checkROCID' , [{ id : "TRUST_ID" , errMsg:"委託人ID格式錯誤"}] );	
		valid2.define('chkTrustID' , [{ id : "TRUST_ID" }] );	
		//valid2.define('checkROCID' , [{ id : "AGENT_ID" , errMsg:"經手人ID格式錯誤"}] );	//20150610移除經手人ID欄位
        valid2.define('validate-number' , [{ id : "ACCOUNT" , errMsg:"銀行帳號輸入錯誤"}] );	
	}		
	
	// 檢核ID格式
	var chkUsableID1 = function (ID) 
	{		
		var chk = false;
		if(ID != '' && ID.length >= 8) {		        
		    if(validation.checkUniSN(ID) || validation.checkROCID(ID)) { 
				chk = true;
			}
		}
		return chk; 	
	};
	
	var chkUsableID2 = function (ID) 
	{		
		var chk = false;
		if(ID != '' && ID.length >= 8) {		        
		    if(validation.checkUniSN(ID) || validation.checkROCID(ID) || validation.checkROCARC(ID)) { 
				chk = true;
			}
		}
		return chk; 	
	};

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0200/" + actionName,
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
	var actions={
	
		//取畫面值
		getDATA_MAP :function(){
		   
			var queryMap = {};
			$$('#form1 input[type!="button"]','#form1 select').each(
				function(text){
					queryMap[text.id] = text.value;  
				}
			);
			queryMap['AGENT_ID'] = ''; //20150610移除經手人ID欄位
			return queryMap;
		
		},
	    //查詢後共同設值
        doSuccess: function(resp){
            gridList = resp.rtnList || [];
			//產生序號、期數
			if (gridList){
				for(var i = 0 ;  i < gridList.size() ; i++ ){
						gridList[i]['SER_NO'] = i+1;
					    //gridList[i]['PAID_TIMES']="1";
				}
			}	
			grid.load(gridList);  //載入資料
			$('BORROW_ID_B').update(resp.resultMap.BORROW_ID||'');
			$('TRUST_NAME').setValue(resp.resultMap.BORROW_NAME||'');
			$('TRUST_ID').setValue(resp.resultMap.BORROW_ID||'');
			$('BANK_CODE').setValue(resp.resultMap.BANK_CODE||'');
			$('ACCOUNT').setValue(resp.resultMap.ACCOUNT||'');
			//$('AGENT_ID').setValue(resp.resultMap.AGENT_ID||'');		
		}	
		,doBANK : function(){
			if(grid.getCheckedRecord().length==0){
				return;
			}
			
			grid.load(gridList);
			$$("#grid input:checked[type = 'checkbox']").each(
				function(elem){					
					elem.setAttribute("checked", false);				
				}
			);	
		}
		,appendTable : function(confirmList){
		    $('appendArea').update('');

		        var tr = new Element('tr');
				var td1 = actions.makeTr({className : 'tbYellow',align:'center'},"檔案編號");
				var td3 = actions.makeTr({className : 'tbYellow',align:"center" },"需送核印");				
				var td5 = actions.makeTr({className : 'tbYellow',align:"center" },"貸款編號or受理編號");
				var td7 = actions.makeTr({className : 'tbYellow',align:"center" },"辦理情形");
				tr.insert(td1).insert(td3).insert(td5).insert(td7);
				$('appendArea').insert(tr);
		    
		    if (confirmList){
				for(var i = 0 ;  i < confirmList.size() ; i++ ){
					var tr = new Element('tr');
					var td2 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['FILE_NO']);
					var td4 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['NEED_APPLY']);					
					var td6 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['NO']);
					var td8 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['STS']);
					tr.insert(td2).insert(td4).insert(td6).insert(td8);
					$('appendArea').insert(tr);
				}	
			}
		}
		//設定欄位屬性
		,makeTr :function(status , obj){
			var td = new Element('td' , status );
			td.update(obj);
			return td;
		}
	}
	
	//POP UP 開啟新視窗
  	function doPopup( parms ) {	
		popupWin.popup({
			'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
			'parameters' :  {
				'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
			}
		});
  	}
	
	
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {
		
			//檢核	
			valid2.reset();
			if(!valid1.validate()){
				return; 
			}
			//發送AJAX	
			ajaxPost( 'query', {'BORROW_ID' :$F('BORROW_ID')}
				,function(resp){
					
					actions.doSuccess(resp);
					actions.appendTable('');
					
					if(resp.resultMap.PREFER_TYPE == "Y"){
					   alert("提醒您，此ID為員工貸款件");
					}		
				}
				,function(resp){
					//如果失敗,把前一次的內容清掉
					grid.load([]);
					$('BORROW_ID_B').update('');
			        $('TRUST_NAME').setValue('');
					$('TRUST_ID').setValue('');
					$('BANK_CODE').setValue('');
					$('ACCOUNT').setValue('');
					//$('AGENT_ID').setValue('');
					actions.appendTable('');
				}
			);
		},
        //確認
        doConfirm: function() {
        
		    //檢核	
		    valid1.reset();
			if(!valid2.validate()){
				return; 
			}
			
			if($F('BANK_CODE')==''){
			    alert("行庫代號不能為空值"); 
				return;
			}
			if($F('ACCOUNT')==''){
			    alert("銀行帳號不能為空值!"); 
				return;
			}
			if($F('BANK')=='I'){
				if($F('BANK_CODE').substr(0,3)!="013"){
					alert("行庫代號有誤(必須為013開頭)!!"); 
					return;
				}
				if ($F('BANK_CODE').length != 7) {
                    alert("行庫代號長度有誤(必須7碼)!!"); 
					return;
                }
				if ($F('ACCOUNT').length != 12) {
                    alert("輸入銀行帳號長度有誤(必須12碼)!!"); 
					return;
                }	
			}else{
			    if ($F('BANK_CODE')!="7000021" && $F('BANK_CODE')!="7000010") {
                    alert("行庫代號有誤!!"); 
					return;
                }
				
				if ($F('BANK_CODE')=="7000021" && $F('ACCOUNT').length != 14){
                    alert("輸入帳號長度有誤!!"); 
					return;
                }
                if ($F('BANK_CODE')=="7000010" && $F('ACCOUNT').length == 8 ) {
                    $('ACCOUNT').value = "000000"+$F('ACCOUNT');
                }
                
                if ($F('BANK_CODE')=="7000010" && ($F('ACCOUNT').length != 14 || $F('ACCOUNT').substr(0,6) != "000000")) {
                    alert("輸入帳號長度有誤!!請在帳號左方補滿0至帳號長度為14"); 
					return;
                }	
			}
			var DATA_MAP = actions.getDATA_MAP();
			var BORROW_ID_D = DATA_MAP['BORROW_ID'];
			
			var checkRec = grid.getCheckedRecord(["LOAN_ID","BANK","BORROW_ID","INPUT_ID","INPUT_DATE","INPUT_DEPT","PAID_TIMES","NEXT_PAYDT","DEDUCT_DATE","IS_LOAN"]);
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			var BANK = $('BANK').value;		
			for ( var i = 0 ; i < checkRec.length ; i ++){
				var LOAN_ID = checkRec[i].LOAN_ID;
				//var LAST_LOAD_ID = LOAN_ID.substring(LOAN_ID.length-1 , LOAN_ID.length);
				/*if(LAST_LOAD_ID == 'X'){
					if(BANK != 'I' && BANK !='G'){
						alert('貸款帳號 : ' + LOAN_ID + ' 轉帳銀行只能選擇郵局及世華!!!');
						return;
					}					
				}else{
					if(BANK != 'I' && BANK !='B'){
						alert('貸款帳號 : ' + LOAN_ID + ' 轉帳銀行只能選擇新郵局及世華!!!');
						return;
					}
				}*/		
				if(BANK != 'I' && BANK !='B'){
					alert('貸款帳號 : ' + LOAN_ID + ' 轉帳銀行只能選擇新郵局及世華!!!');
					return;
				}		
				//2014-12-18修正未重查即以修改之資料更新前一筆資料
				var BORROW_ID = checkRec[i].BORROW_ID;	
				if(BORROW_ID != BORROW_ID_D){
					alert('查詢之借款人ID: ' + BORROW_ID_D + ' 與清單中借款人ID: ' + BORROW_ID + ' 不同，請重新查詢後再做申請!');
					return;									
				}
			}
			
			//[20211123] 銀行轉帳申請作業，若同時勾選多筆案件按確認，則跳出提醒訊息
			if(checkRec.length > 1 ){
				if(!confirm('不同張轉帳扣款委託書請分開輸入，請確認多筆案件為同一張轉帳扣款委託書，若非同一張轉帳扣款委託書之案件，請取消並分開輸入')){
					return;
				}
			}
			
			//發送AJAX	
			ajaxPost( 'confirm', { DATA_MAP :Object.toJSON(DATA_MAP),'DATA_LIST':Object.toJSON(checkRec)}
				,function(resp){
					if(resp.IS_CONFIRM == 'N'){
					    alert(resp.ERR_MSG);
						var parms = { 
							'QUERY_ID' : resp.QUERY_ID
						}; 		
						doPopup( parms );	
					} else if(resp.IS_CONFIRM == 'Y'){
						alert(resp.ERR_MSG);
					} else {
						var rtnConfirmList = resp.confirmList||'';
						actions.appendTable(rtnConfirmList);
						
						actions.doSuccess(resp);
						$('BANK').value='B';
						$('RELATION').value='0'; //預設本人
						//提醒需進行郵局核印作業
						if ("是" == rtnConfirmList[0].NEED_APPLY){
							alert("本件需送核印。")
						}
					}
				}				
			);
		}
		
	};	
	
	var getBankName = function(TBANK,record){
	
		if (TBANK=="I"){
			return "世華";	
		}else if(TBANK=="B" || (TBANK=="G" && record[0].IS_NEW=='1')){
			return "新郵局";
		}else if(TBANK=="G"){
			if(record[0].LOAN_ID.substring(9,10)=='X'){
				alert('郵局無理財型');
				return '';
			}
			return "郵局";
		}else if(TBANK=="B" ){
			return "新郵局";
		}else if(TBANK=="3"){
			return "員工扣薪";
		}else{
			return "非轉帳";  
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC30200" , "繳款方式", "銀行轉帳申請" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20
				,autoCheckBox:{isSelectAll:false,
                    action:function(checkbox ,boxStatus , record ){
                    	var BANK_input, PAID_TIMES, NEXT_PAYDT, DEDUCT_DATE;
                    	if(grid.isNew){
                    		var inputs = grid.getAutoInput(checkbox,['BANK','PAID_TIMES'])[0];
                    		BANK_input = inputs['BANK'];
							//PAID_TIMES = inputs['PAID_TIMES'];
							//NEXT_PAYDT = inputs['NEXT_PAYDT'];
							//DEDUCT_DATE = inputs['DEDUCT_DATE'];
						}else{
							var tr = $(checkbox).up('tr');
							BANK_input = tr.select("td[name=BANK] input")[0];
							PAID_TIMES = tr.select("td[name=PAID_TIMES] input")[0];
							NEXT_PAYDT = tr.select("td[name=NEXT_PAYDT]")[0];
							DEDUCT_DATE = tr.select("td[name=DEDUCT_DATE]")[0];
						}
						var dataObj = record[0];
						
						//alert(Object.toJSON(dataObj));
						if($(checkbox).checked){
							dataObj.initIS_NEW = dataObj.IS_NEW;
							
							var BankValue = $('BANK').value;
							var BankName=$('BANK').options[$('BANK').selectedIndex].text
							if(BankName=='新郵局'){
								dataObj.IS_NEW=1;
							}else if(BankName=='郵局'){
								dataObj.IS_NEW='';
							}
							
							dataObj.initBANK=BANK_input.value;								
							BANK_input.value= BankName;						
							dataObj.BANK = BankValue;
							
							//期數
							dataObj.initPAID_TIMES = dataObj.PAID_TIMES;
							var strPadtim = dataObj.strPadtim;
							if(grid.isNew){
								//alert("PAID_TIMES " + Object.toJSON(strPadtim));
								grid.setValueToAutoInput( checkbox , 'PAID_TIMES' , strPadtim[BankValue] );
								//20141113 修正setValueToTD遇到DISABLE輸入欄位無法正確取值問題
								dataObj.PAID_TIMES = strPadtim[BankValue]; 
							}else{
								PAID_TIMES.value = strPadtim[BankValue];
								dataObj.PAID_TIMES = strPadtim[BankValue];
							}
							
							var strNexpad = dataObj.strNexpad;
							if(grid.isNew){
								grid.setValueToTD( checkbox , 'NEXT_PAYDT' , strNexpad[BankValue] )
							}else{
								NEXT_PAYDT.innerHTML = Date.toInputROC( strNexpad[BankValue] || "","/" );
								dataObj.NEXT_PAYDT = strNexpad[BankValue];
							}
							
							var strDedut = dataObj.strDedut;								
							dataObj.initDEDUCT_DATE = dataObj.DEDUCT_DATE;
							if(grid.isNew){
								grid.setValueToTD( checkbox , 'DEDUCT_DATE' , strDedut[BankValue] )
							}else{
								DEDUCT_DATE.innerHTML = Date.toInputROC( strDedut[BankValue] || "","/" );
								dataObj.DEDUCT_DATE = strDedut[BankValue];
							}
							
						}else{
							dataObj.IS_NEW=dataObj.initIS_NEW
							BANK_input.value=dataObj.initBANK;		
							
							if(grid.isNew){
								grid.setValueToAutoInput( checkbox , 'PAID_TIMES' , dataObj.initPAID_TIMES )
								grid.setValueToTD( checkbox , 'NEXT_PAYDT' , '' )
								grid.setValueToTD( checkbox , 'DEDUCT_DATE' , dataObj.initDEDUCT_DATE )
							}else{
								PAID_TIMES.value =  dataObj.initPAID_TIMES ;
								NEXT_PAYDT.innerHTML = '';
								DEDUCT_DATE.innerHTML = dataObj.initDEDUCT_DATE;
								dataObj.PAID_TIMES = dataObj.initPAID_TIMES;
								dataObj.DEDUCT_DATE = dataObj.initDEDUCT_DATE;
							}
							
							delete dataObj.initIS_NEW;
							delete dataObj.BANK;
							delete dataObj.initBANK;
							delete dataObj.initPAID_TIMES;
							delete dataObj.initDEDUCT_DATE;
						}
				        			
					}/*,genRule:function(record,value){
					    return  record.IS_LOAN == '0' ? false : true;	
					}*/
				
				},
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[					
					{header:"新舊別",key:"TYPE",
					    render: function(record, value) {
						    var IS_LOAN = record.IS_LOAN;
						    if(IS_LOAN=="0"){
						       	return "新件";
						    }else{
							    return "舊件";
							}   
							
						} 

					},
					{header:"序號",key:"SER_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"契約狀況",key:"LOAN_STATUS_NM"},
					{header:"轉帳銀行",key:"BANK",
					    input:{                            
						    type:'TEXT' , actionWhenStart: true ,  size:10,
							action:function(node,dataObj , textDiv, orgData){
								var BANK = dataObj[0].PAY_TYPE;	
								var TRANS_STATUS = dataObj[0].TRANS_STATUS;
								if(TRANS_STATUS=="1"){
									if(!BANK){
										var CODE = dataObj[0].BANK_CODE;
										if (CODE) {
											if (CODE.substr(0,3)=='700') {
												BANK = 'G';
											} else {
												BANK = 'I';
											}
										} else {
											BANK = '';
										}
									}
								}else{
									BANK = '';
								}					
								node.value=getBankName(BANK,dataObj);
								$(node).disable();                      
							}	
						}
						/*,render: function(record, value) {					    
							var BANK = record.PAY_TYPE;
							return getBankName(BANK,record);
						}*/
					},
                    {header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"期數",key:"PAID_TIMES",
					    input:{                            
						    type:'NUMBER' , actionWhenStart: true ,  size:5,
							action:function(node,dataObj , textDiv, orgData){		
								$(node).disable();                      
							}	
						}						
					
					},
					{header:"下次應繳日",key:"NEXT_PAYDT"
						,render : function(rec , val){						
							return rec.BANK? Date.toROC(val || "") :'';	 //2014-12-18調成民國年顯示					
						}
					},
					{header:"首扣日",key:"DEDUCT_DATE" //2014-12-18調成民國年顯示
						,render : function(rec , val){						
							return Date.toROC(val || "");						
						}},
					{header:"轉帳銀行狀態",key:"TRANS_STATUS",
					   
						input:{                            
						    type:'TEXT' , actionWhenStart: true ,  size:10,
	
							action:function(node,dataObj , textDiv, orgData){
								var TRANS_STATUS = dataObj[0].TRANS_STATUS;
								if(TRANS_STATUS=="1"){
									node.value="已辦理轉帳";
								}else if(TRANS_STATUS=="2"){
									node.value="轉帳終止";
								}else if(TRANS_STATUS=="4"){
									node.value="待核印";									
								}else if(TRANS_STATUS==""){
									node.value="未辦理轉帳";
								}else{
									node.value="";
								}
								$(node).disable();                      
							}	
						}
						/*,render: function(record, value) {
						
						    var TRANS_STATUS = record.TRANS_STATUS;
						    if(TRANS_STATUS=="1"){
						       	return "已辦理轉帳";
						    }else if(TRANS_STATUS=="2"){
							    return "轉帳終止";
							}else if(TRANS_STATUS==""){
							    return "未辦理轉帳";
							}else{
							    return "";
							}
						}*/
						    
					}					
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面日期檢核
			initValidation();
			//按鈕權限
			// 監聽: 查詢
			$('BANK').observe('change',actions.doBANK)
			$("BTN_QUERY").observe('click', button.doQuery);
			$("BTN_CONFIRM").observe('click', button.doConfirm);
			//Input欄位自動轉大寫
			$('BORROW_ID').observe('change',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();
			});	
			$('TRUST_ID').observe('change',function(){
				$('TRUST_ID').value = $F('TRUST_ID').toUpperCase();
			});	
			/*$('AGENT_ID').observe('change',function(){ //20150610移除經手人ID欄位
				$('AGENT_ID').value = $F('AGENT_ID').toUpperCase();
			});	*/
			$('BANK').value='B';
			PageUI.resize();	
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSC31300
</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" >

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
		<td class='tbYellow' width='5%'>
				借款人ID
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='BORROW_ID' type='text' class= 'textBox2' size='12' maxlength='10' /> 
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='BTN_QUERY' type='button' class='button' value='查詢' />
		</td>
	</tr>
	<tr>
		<td class='tbYellow2' width='15%' align="center" colspan="3">
			<input id='BTN_CONFIRM' type='button' class='button'  value='確認' />
		</td>
	</tr>
	
</table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
	<tr>
	    <td class='tbYellow0' width='5%' align="center" colspan="9">
			<b>銀行轉帳委託申請書-帳戶選取</b>
		</td>  
	</tr>
	<tr>
		<td class='tbBlue' width='10%' align="center">
			借款人ID
		</td>
		<td class='tbBlue' align="center">
			委託人姓名
		</td>
		<td class='tbBlue' align="center" >
			委託人ID
		</td>
		<td class='tbBlue' align="center">
			關係
		</td>
		<td class='tbBlue' align="center">
			轉帳銀行
		</td>
		<td class='tbBlue' align="center" >
			行庫代號
		</td>
		<td class='tbBlue' align="center" >
			銀行帳號
		</td>
		<!-- 
		<td class='tbBlue' align="center">
			經手人ID
		</td> 
		-->
		<!-- 
		<td class='tbBlue' align="center">
			核印(Y/N)
		</td>		
		-->
	</tr>
	<tr>	
		<td class='tbYellow2' align="center" width='10%' >
			<span  id="BORROW_ID_B" ></span>	
		</td>
		<td class='tbYellow2' align="center">
		    <input id='TRUST_NAME' type='text' class= 'textBox2' alt='ch' /> <%--[20241101]難字調整 --%>
		</td>
		<td class='tbYellow2' align="center">
			<input id='TRUST_ID' type='text' class= 'textBox2' size='12' maxlength='10'/> 
		</td>
		<td class='tbYellow2'align="center" >
			<select id="RELATION" class="textBox2">
				<c:forEach items="${RELATION_List}" var="map">							
					<option value='${map.key}'  <c:if test="${map.key eq '0'}">selected</c:if> >${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow2' align="center">
			<select id="BANK" class="textBox2">
				<option value="">請選擇</option>
				<c:forEach items="${BANK_List}" var="map">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class='tbYellow2' align="center">
			<input id='BANK_CODE' type='text' class= 'textBox2' size='9' maxlength='7'/> 
		</td>
		<td class='tbYellow2' align="center">
			<input id='ACCOUNT' type='text' class= 'textBox2' size='16' maxlength='14'/> 
		</td>
		<!--
		<td class='tbYellow2' align="center">
			<input id='AGENT_ID' type='text' class= 'textBox2'/> 
		</td>
		-->
		<!--
		<td class='tbYellow2' align="center">
			<input id='CHECK' type='text' class= 'textBox2' value="Y" size='3' maxlength='1'/> 
		</td>	
		-->
	</tr>
</table>
<table id='grid' width='100%'></table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
    
	<tbody id = "appendArea" >		
	   <tr>
	    <td class='tbYellow' align="center">
			檔案編號
		</td>
	    <td class='tbYellow' align="center">
			需送核印
		</td>		 
	    <td class='tbYellow' align="center">
			貸款編號or受理編號
		</td>		
	    <td class='tbYellow' align="center">
			辦理情形
		</td>	
		</tr>
	</tbody>	
</table>

</form>
</body>
</html>	