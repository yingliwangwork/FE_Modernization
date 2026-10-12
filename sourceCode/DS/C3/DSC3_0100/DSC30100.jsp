<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>


<!--
程式：DSC30100.jsp
作者：熊偉翔
功能：銀行轉帳查詢
完成：2012/12/06
      2018-02-05申請書-調整銀行轉帳申請作業洗錢防制風險等級檢核規則：增加關係欄位
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--執行結果顯示-->

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script> <!--alert訊息-->
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
<script type="text/javascript">


var DSC30100 = new DSC30100();

//透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
Event.observe(window, 'load', DSC30100.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


//以下為UI() public method,放在 return 中
function DSC30100(){

	var grid;
	var valid1;	
	
	//畫面檢核(設定)
	function initValidation(){
		valid1 = new Validation("form1", { focusOnError:true, immediate:false});
		
		Validation.addAllThese([
		[ 'chkUsableID',  '請輸入正確ID', 
			function(v){ 
			    if($F('BORROW_ID') != '' ){
			        
					if(v.length >= 8){
					    if(validation.checkUniSN(v) || validation.checkROCID(v) || !validation.checkROCPassport(v) || validation.checkROCARC(v)) { 
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
		], 
		[ 'chkUsableID2',  '請輸入正確ID', 
			function(v){ 
			    if($F('TRUST_ID') != ''){
			   
					if(v.length >= 8){
					    if(validation.checkUniSN(v) || validation.checkROCID(v) || !validation.checkROCPassport(v) || validation.checkROCARC(v)) { 
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
		
		
	}	
	
	//檢核 Radio Button
	function checkedisEmpty(){
	    var i = 0;
		$w('BORROW_ID TRUST_ID LOAN_ID').each(
			function(id) {
			     if($F(id) != ''){
			       i++;
			     }
				
			}
		);
		if(i==0){
		
		  alert("查詢條件至少輸入一項!"); 
		  return false;
		
		}else if(i > 1){
		
		   alert("查詢條件只能輸入一項!"); 
		   return false;
		
		}
		return true;
		
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_0100/" + actionName,
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
	
	//--------------------------------------------------------------------------
	// 功能按鈕
	//--------------------------------------------------------------------------	
	
	var buttons = {
		
		//查詢
		doQuery: function(event){
		
			valid1.reset();
			valid1.clear();
			
			//檢核選取的Radio Button
			if(!checkedisEmpty()){
			  return;
			}
			
			//畫面檢核
			if(!valid1.validate()){
				return; 
			}
			
			//將畫面上的欄位存成MAP
			var queryMap = {	
				'BORROW_ID': $F('BORROW_ID'),
				'TRUST_ID': $F('TRUST_ID'),
				'LOAN_ID' : $F('LOAN_ID') 
			};
			
			
			
			ajaxPost( 'query', {'queryMap' :Object.toJSON(queryMap)}
			
				,function(resp){
					
					//產生序號
					var gridList = resp.rtnList || [];
					
					for(var i = 0 ;  i < gridList.size() ; i++ ){
						gridList[i]['SER_NO'] = i+1;
					}
					
					grid.load(gridList);  //載入資料
					
				}
				,function(resp){	
					//如果失敗,把前一次的內容清掉
					grid.load([]);
				}
			);
		}  
	};


	return {
	
			initApp : function() {
				
				PageUI.createPageWithAllBodySubElement("DSC30100", "繳款方式", "銀行轉帳查詢");
				
				//產生 Grid 物件	
				grid = new TableUI ( { table: $('grid'), pageSize: 10, allSortable : false, split:["FILE_NO"],
					<%--[20241101] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
					
						{header: '序號',key: 'SER_NO'  ,attrs:{rowSpan:2}},
						{header: '貸款帳號',key: 'LOAN_ID' },
						{header: '借款人姓名',key: 'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },
						{header: '期數',key: 'PAY_TERM' ,
							render : function(rec , val){
								return val || '0';
							}
						},
						{header: '委託人ID',key: 'TRUST_ID' },
						{header: '委託人姓名',key: 'TRUST_NAME', attrs:{style:"font-family:'EUDC'"} },
						{header: '關係',key: 'RELATION_NAME' }, //2018-02-05新增顯示關係
						{header: '經手人ID',key: 'AGENT_ID' },
						{header: '輸入人員姓名',key: 'INPUT_NAME', attrs:{style:"font-family:'EUDC'"} },
						{header: '檔案編號',key: 'FILE_NO' },
						{header: '當期應繳日',key: 'TRANS_DATE' //2014-12-18調成民國年顯示
							,render : function(rec , val){						
								return Date.toROC(val || "");						
							} },
						{header: '首次扣款日',key: 'DEDUCT_DATE' //2014-12-18調成民國年顯示
							,render : function(rec , val){						
								return Date.toROC(val || "");						
							} },	
						{header: '行庫代號',key: 'BANK_CODE' },
						{header: '銀行帳號',key: 'ACCOUNT' },
						{header: '轉帳狀態',key: 'TRANS_STATUS'  },
						{header: '輸入日期',key: 'INPUT_DATE' //2014-12-18調成民國年顯示
							,render : function(rec , val){						
								return Date.toROC(val || "");						
							} },
						{header: '',key: ''  }						
					]
				});
				
				
				//-----------------------------------------------------
				//以下為進入初始頁面時需要執行的動作
				//-----------------------------------------------------
				//畫面日期檢核
				initValidation();
					
				//註冊DOM物件 : 監聽	
				$('BTN_0001').observe('click', buttons.doQuery);//查詢
				
				//Input欄位自動轉大寫
				$w('BORROW_ID TRUST_ID LOAN_ID').each(
					function(id){
						$(id).observe('change', 
							function(){
								$(id).value = $F(id).toUpperCase();
							}
						);					
					}
				);
				
				//初始頁面alert訊息用	
				displayMessage();
				
				PageUI.resize();
				
			}// end initApp()
	};// end return--
}

</script>
</head>
<body>
<form name="form1" id="form1"  style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px" action="">

<table width='100%' border='0' cellpadding='0' cellspacing='1' class='tbBox2'>
		<tr>
		<td class='tbYellow' width='10%'>
			
				借款人ID
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='BORROW_ID' type='text' class= 'textBox2 chkUsableID'   size='12' maxlength='10' /> 
		</td>
		<td class='tbYellow' width='10%'>
			
				委託人ID
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='TRUST_ID' type='text' class= 'textBox2 chkUsableID2'  size='12' maxlength='10'/> 
		</td>
		<td class='tbYellow' width='10%'>
			
				貸款帳號
		</td>
		<td class='tbYellow2' width='15%'>
			<input id='LOAN_ID' type='text' class= 'textBox2' size='13' maxlength='11'  />
		</td>
		<td class='tbYellow2' align='center' >
			<input id='BTN_0001' type='button' class='button' value='查詢' />
		</td>
	</tr>
</table>
</form>
<table id='grid' width='100%'></table>
</body>
</html>