<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSC30300.jsp
作者：卓達瑋
功能：銀行轉帳申請
完成：2013/04/18
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

Event.observe(window, 'load', new DSC30300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSC30300(){
	var grid;		
	
	//檢核
	var valid1;
	
	Validation.addAllThese([ 
	   [ 'chkUsableID',  '請輸入正確ID', 
			function(v){ 
			    if($F('BORROW_ID')){
			        
					if(v.length >= 8){
					    if(validation.checkUniSN(v) || validation.checkROCID(v)) { 
							return true ;
						}else{ 
							return false ;
						}  
					}else{
				  		return false;
					}
				}
				return true;
				
			} 
		]
	  ]);	

	
	//檢核欄位
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});		
        valid1.define('required' , [{ id : "BORROW_ID" , errMsg:"借款人ID未輸入"}] );	
        valid1.define('chkUsableID' , [{ id : "BORROW_ID"}] );
		

	}	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0300/" + actionName,
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
	
		appendTable : function(confirmList){
		    $('appendArea').update('');
		        var tr = new Element('tr');
				var td1 = actions.makeTr({className : 'tbYellow',align:'center'},"檔案編號");
				var td3 = actions.makeTr({className : 'tbYellow',align:"center" },"貸款編號or受理編號");
				var td5 = actions.makeTr({className : 'tbYellow',align:"center" },"辦理情形");
				tr.insert(td1).insert(td3).insert(td5);
				$('appendArea').insert(tr);
		    
		    if (confirmList){
				for(var i = 0 ;  i < confirmList.size() ; i++ ){
						var tr = new Element('tr');
						var td2 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['FILE_NO']);
						var td4 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['NO']);
						var td6 = actions.makeTr({className : 'tbYellow2',align:'center'},confirmList[i]['STS']);
						tr.insert(td2).insert(td4).insert(td6);
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
	// 功能按鈕
	var button = {
			
		// 查詢
		doQuery: function() {	
			 //檢核	
			if(!valid1.validate()){
				return; 
			}
			//發送AJAX	
			ajaxPost( 'query', {'BORROW_ID' :$F('BORROW_ID')}
				,function(resp){
					grid.load(resp.rtnList || []);
					actions.appendTable('');
				}
				,function(resp){
					//如果失敗,把前一次的內容清掉
					grid.load([]);
					actions.appendTable('');
					//$('FILE_NO').update('');
					//$('NO').update('');
					//$('STS').update('');	
				}
			);
		},
        //確認
        doConfirm: function() {
		     //檢核	
			if(!valid1.validate()){
				return; 
			}
			
			var checkRec = grid.getCheckedRecord();
            if(checkRec.length==0){
			  alert("請至少勾選一筆資料");
			  return;
			}
			
			//發送AJAX	
			ajaxPost( 'confirm', { 'BORROW_ID' :$F('BORROW_ID'),'DATA_LIST':Object.toJSON(checkRec)}
				,function(resp){
					grid.load(resp.rtnList || []);
					//$('FILE_NO').update(resp.confirmList[0].FILE_NO||'');
					//$('NO').update(resp.confirmList[0].NO||'');
					//$('STS').update(resp.confirmList[0].STS||'');
					actions.appendTable(resp.confirmList||'');	
				},function(resp){
					//如果失敗,把前一次的內容清掉
					grid.load([]);
					actions.appendTable('');
				}
			);
		}
		
	};	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSC30300" , "繳款方式", "銀行轉帳終止" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 20,allSortable:false,split: ['AGENT_ID'],			
				autoCheckBox:{
				    isSelectAll:false,
					genRule:function(record,value){
					    return  record.TRANS_STATUS == '1' || record.TRANS_STATUS == '4';	
					}
				},
				<%--[20241101] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[					
					{header:"委託人ID",key:"TRUST_ID" ,attrs:{rowSpan:2}},
					{header:"序號/新舊別",key:"SER_NO"},
					{header:"貸款帳號",key:"LOAN_ID"},
					{header:"借款人姓名",key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"}},
					{header:"期數",key:"PAY_TERM"},
					{header:"當期應繳日",key:"TRANS_DATE",
					    render : function (rec , val){
								return Date.toROC(val || "");									
						}
					},
					{header:"經手人ID",key:"AGENT_ID"},
					{header:"檔案編號",key:"FILE_NO"},
					{header:"行庫代號",key:"BANK_CODE"},
                    {header:"銀行帳號",key:"ACCOUNT"},
					{header:"轉帳狀態",key:"TRANS_STATUS",
					    render: function(record, value) {
						    var TRANS_STATUS = record.TRANS_STATUS;
						    if(TRANS_STATUS=="1"){
						       	return "已辦理轉帳";
						    }else if(TRANS_STATUS=="3"){
								if (record.APPLY_PROCESS =="1"){
									return "取消核印送件";
								}
							    return "申請後終止";
						    }else if(TRANS_STATUS=="4"){
							    return "待郵局核印";								
							}else if(TRANS_STATUS==""){
							    return "未辦理轉帳";
							}else{
							    return "";
							}
						}
					}					
				]
			});
			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------
				
			//畫面檢核
			initValidation();
			
			// 監聽: 查詢
			$("BTN_QUERY").observe('click', button.doQuery);
			$("BTN_CONFIRM").observe('click', button.doConfirm);
			//Input欄位自動轉大寫
			$('BORROW_ID').observe('change',function(){
				$('BORROW_ID').value = $F('BORROW_ID').toUpperCase();
			});					
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
			<input id='BORROW_ID' name='BORROW_ID' type='text' class= 'textBox2' size='12' maxlength='10' /> 
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
<table id='grid' width='100%'></table>
<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
   
    <tbody id = "appendArea" >		
	   <tr>
	    <td class='tbYellow' align="center">
			檔案編號
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