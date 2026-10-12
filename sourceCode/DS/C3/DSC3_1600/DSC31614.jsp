<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC31614.jsp
作者：余凱鈞
功能：沖人工入帳金額分配
完成：2013/09/26
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
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC31614().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31614(){
	var gridA;
	var gridB;
	var gridC;
	var gridD;
	var valid;
	var BillList;	
	var ISTIC="";
	var PAY_TYPE="";
	var SPEC="0";
	var dataList =[];
	var dataListC =[];
	var dataListD =[];
	var cfmPayList="N";	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1614/" + actionName,
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
	
	//檢核
	function initValidation(){
		Validation.addAllThese([
			[ 'validateRECEIPT_SERNO', '單據序號輸入有誤!',
				function(v){
					return v.length == 10 ;
				}
			],
			[ 'AMT_Required', '請輸入繳暫收款金額',
				function(value,elem){  				
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || value;
				}
			]
		])
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
	}
	
	function defineValid(type){
		 if(type=='billin'){
		 	//沖人工的單據序號檢查調整
		 	//有輸入單據序號才檢查單據序號及列印單據，沒有輸入單據序號就不檢查
		 	if($F('RECEIPT_SERNO')){
		 		valid.define( "validateRECEIPT_SERNO" , { id: "RECEIPT_SERNO" , errMsg:"單據序號輸入長度有誤!" } );	
				valid.define( "validate-number" , { id: "RECEIPT_SERNO" , errMsg:"單據序號需輸入數字!" } );
		 	}				
		}
	}
						
	var buttons = {	
		//查詢
		doQuery : function(){

			var PAY_KIND = 	BillList[0].PAY_KIND; //取第一筆的PAY_KIND

			ajaxPost( 'query', {PAY_KIND : PAY_KIND, PAY_TYPE : '${PAY_TYPE}'}
				,function(resp){
					gridA.load(resp.tempList);
				}
			);			
		},	
		//選取
		doInsert : function(){
			valid.reset();			
			valid.clear();
							
			dataList = gridA.getCheckedRecord(); //將A區選取資料加入到dataList中
			if(dataList.length==0){
				alert("請至少選取一筆人工暫收款資料!");
				 return;
			}

			ajaxPost( 'insert', {dataList : Object.toJSON(dataList), CASH_PAYMT : 0}
				,function(resp){
					dataListB = resp.rtnList;					
					//顯示在B區中
					$('table_B').show();
					$('gridB').show();
					gridB.load(dataListB);
					var totalAmt=parseInt(resp.TOTAL_TRANS_AMT);
					$('TOTAL_AMT').value = CSRUtil.$fmt(totalAmt,"#,###") ; 
				}
			);			
		
		
		},
		//清除
		doClear : function(){	
			valid.reset();			
			valid.clear();
			
			//B區清空
			gridB.load();
			//B區輸入欄位恢復預設值0
			$('table_B').select('input[type!=button]').each(function(ele){						
				ele.value = 0;
			});
			
			cfmPayList="N";
			
			//各暫存LIST清空
			dataList = [];	
			dataListC = [];	
			dataListD = [];	

			//C區清空
			gridC.load();
			$('table_C').hide();
			$('gridC').hide();
			
			//D區清空
			gridD.load();
			$('table_D').hide();
			$('gridD').hide();	
			$('table_E').hide();	

			$('btn_INSERT').enable();
			$('btn_CONFIRM').enable();				
		},
		//確認
		doConfirm : function(){
			valid.reset();			
			valid.clear();

			//檢核B區是否有資料
			if(!dataList.size()>0){
				alert("請先選取暫收款清單再進行確認!")
				return;
			}
			
			//檢核C區是否有資料
			if(dataListC.size()>0){
				alert("已產生暫收款金額分配設定資料!")
				return;
			}
			
			var CheckMap={
				'ISTIC' : ISTIC,
				'BillList' : BillList,
				'PAY_TYPE': PAY_TYPE,
				'CASH_PAYMT':0,
				'TOTAL_AMT':$F('TOTAL_AMT')
			}
			ajaxPost( 'chkPayList', {CheckMap :Object.toJSON(CheckMap)}
				,function(resp){
					
					$('table_C').show();
					$('gridC').show();
					gridC.load(BillList);
					dataListC = BillList; 
					
					cfmPayList="Y";
					gridB.load(dataList);	
				}
			);
			
			$('btn_INSERT').disable();
			$('btn_CONFIRM').disable();
		},
		//分配
		doAssign : function(record){
			valid.reset();			
			valid.clear();
			
			ajaxPost( 'assign', {CheckMap : Object.toJSON(record), BillList : Object.toJSON(dataListC)}
				,function(resp){
					dataListC = resp.rtnList;
					gridC.load(dataListC, null, null, ["Y"]);
				}
			);

		},
		//選取確認
		doChkAssign : function(){
			valid.reset();			
			valid.clear();
			
			var CheckedRecordB = gridB.getCheckedRecord();
			if(CheckedRecordB.length==0){
				alert("請先選取一筆暫收款資料!");
				 return;
			}			
			
			var CheckedRecord = gridC.getCheckedRecord();
			if(CheckedRecord.length==0){
				alert("請至少選取一筆資料!");
				 return;
			}
						
			if(!valid.validate()){
				return;
			}
			
			for(var i=0 ; i<CheckedRecord.length ; i++){
				if(CheckedRecord[i].TRADE_AMT <=0){
					alert("請檢查繳暫收款金額是否大於0!");
					return;				
				}
			}

			ajaxPost( 'chkassign', {
				CheckMap : Object.toJSON(CheckedRecordB[0]), 
				BillList : Object.toJSON(CheckedRecord), 
				SPEC : '${SPEC}',
				dataListC : Object.toJSON(gridC.getAllRecords())}
				,function(resp){
					var rtnList = resp.rtnList;
					//將每次選取確認之項目逐筆加入到D區清單中
					for(var i=0; i< rtnList.length ; i++){
						dataListD.push(rtnList[i]);
					}
					$('table_D').show();
					$('gridD').show();
					$('table_E').show();
					gridD.load(dataListD);
					
					//重新顯示尚未分配之清單
					gridC.load(resp.rtnListC);
					dataListC= resp.rtnListC;					
				}
			);
		},
		//取消選取確認
		doCancel : function(){
			valid.reset();			
			valid.clear();
		
			//選取確認LIST清空
			dataListD = [];	
			
			//D區清空
			gridD.load([]);
			$('table_D').hide();
			$('gridD').hide();
			$('table_E').hide();
			
			//C區重新讀取初始接值之LIST
			dataListC = BillList;	
			gridC.load(BillList);

		},
		//入帳確認
		doBillIn : function(){
			valid.reset();			
			valid.clear();
			
			//判斷D區是否有值
			if(!dataListD.size()>0){
				alert("請產生票據入帳試算結果後，再做入帳確認!")
				return;
			}
			
			//入帳確認檢核
			defineValid('billin');
			if(!valid.validate()){
				return;
			}
		
			ajaxPost( 'billin', {
				BillList : Object.toJSON(dataListD), 
				PAY_TYPE : '${PAY_TYPE}',
				ISTIC : '${ISTIC}',
				SPEC : '${SPEC}',
				TOTAL_AMT:$F('TOTAL_AMT'),
				RECEIPT_SERNO:$F('RECEIPT_SERNO')}
				,function(resp){				
					var LP_JSON = {	
						action : '<%=dispatcher%>/DSC3_1620/prompt',
						BillListStr : resp.BillListStr,
						PAY_TYPE : '${PAY_TYPE}',
						ISTIC : '${ISTIC}',
						SPEC : '${SPEC}',
						INPUT_ID : resp.INPUT_ID,	
						INPUT_DEPT : resp.INPUT_DEPT,
						RECEIPT_SERNO: $('RECEIPT_SERNO').value
					};
					CSRUtil.linkTo(LP_JSON , 'form');
				}			
			);
		}
	};
	
	var gridC_column1= [
		{header:"貸款帳號", key:'LOAN_ID'},
		{header:"期數", key:'PAY_TERM'},
		{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"繳暫收款金額", key:'TRADE_AMT', attrs: {align:"right"},
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
			},  
			input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}        
		}					
	];

	var gridC_column2= [
		{header:"貸款帳號", key:'LOAN_ID'},
		{header:"期數", key:'PAY_TERM'},
		{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"繳暫收款金額", key:'TRADE_AMT', attrs: {align:"right"},
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
			},  
			input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}        
		},
		{header:"手續費筆數", key:'CHARGE_CNT', attrs: {align:"right"},
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
			},  
			input:{type:'number' , size:2 , maxlength:2 , className : 'textBox2 validate-number'}        
		}						
	];	
	
	var gridD_column1 = [
		{header:"貸款帳號", key:'LOAN_ID'},
		{header:"期數", key:'PAY_TERM'},
		{header:"應繳金額", key:'DUTY_PAYMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"實繳金額", key:'REAL_PAYMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"暫應收編號", key:'BALC_NO'},
		{header:"沖人工暫收金額", key:'FACE_AMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}}				
	];	
	
	var gridD_column2 = [
		{header:"貸款帳號", key:'LOAN_ID'},
		{header:"期數", key:'PAY_TERM'},
		{header:"應繳金額", key:'DUTY_PAYMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"實繳金額", key:'REAL_PAYMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"暫應收編號", key:'BALC_NO'},
		{header:"沖人工暫收金額", key:'FACE_AMT',
			render:function(rec,val){
				return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
		}},
		{header:"手續費筆數",key:'CHARGE_CNT',
			render: function (rec,val){
				return val||0;
			}
		}					
	];	

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC31614" , "核心放款" , "給付方式 沖人工");
			
			gridA = new TableUI({
				table: $('gridA'), allSortable: false, 	
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					isSelectAll:true					
				},					
				column: [
					{header:"暫收款編號", key:'BALC_NO'},
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"暫收實繳日", key:'REAL_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"暫收款金額", key:'REMAIN_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"票據狀態", key:'CHECK_CSTATUS'}			
				]	
			});
			
			gridB = new TableUI({
				table: $('gridB'), pageSize: 20, allSortable: false, overDiv : false,	
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return; //檢核box狀態，避免連續點選，造成載入資料有問題					
						buttons.doAssign(records[0]);
					},
					genRule:function(record , value){ 
						//return dataListC.size()>0
						return cfmPayList=="Y" ? true : false;						
					}
				},				
				column: [
					{header:"暫收款編號", key:'BALC_NO'},
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"暫收實繳日", key:'REAL_PAYDT',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"暫收款金額", key:'FACE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"票據狀態", key:'CHECK_CSTATUS'}	
				]	
			});
					
			gridC = new TableUI({
				table: $('gridC'), pageSize: 20, allSortable: false, overDiv : false,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					valueKey: 'preCheck'
				},	
				column : '${PAY_TYPE}' == 'E' ? gridC_column2 : gridC_column1				
				/*column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM'},
					{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"繳暫收款金額", key:'TRADE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						},  
						input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}        
					}					
				]*/		
			});
			
			gridD = new TableUI({
				table: $('gridD'), pageSize: 20, allSortable: false, overDiv : false,
				column : '${PAY_TYPE}' == 'E' ? gridD_column2 : gridD_column1
				/*column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM'},
					{header:"應繳金額", key:'DUTY_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"實繳金額", key:'REAL_PAYMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"暫應收編號", key:'BALC_NO'},
					{header:"沖人工暫收金額", key:'FACE_AMT',
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"手續費筆數",key:'CHARGE_CNT',
						render: function (rec,val){
							return val||0;
						}
					}					
				]*/	
			});
					
			initValidation();	
				
			$('btn_INSERT').observe('click',buttons.doInsert);
			$('btn_CLEAR').observe('click',buttons.doClear);
			$('btn_CONFIRM').observe('click',buttons.doConfirm);
			$('btn_CHKASSIGN').observe('click',buttons.doChkAssign);
			$('btn_CANCEL').observe('click',buttons.doCancel);			
			$('btn_BILLIN').observe('click',buttons.doBillIn);	
			$('btn_BILLIN_2').observe('click',buttons.doBillIn);
			
			$('btn_return').observe('click', function(){
				CSRUtil.linkBack();
			});
			
			<c:choose>
				<c:when test='${not empty BillList}'>
				   BillList = ${BillList};
				   ISTIC = '${ISTIC}';
				   PAY_TYPE = '${PAY_TYPE}';
				   SPEC = '${SPEC}';
				   if(PAY_TYPE=="2"){
				   	GETINT_CODE = '${GETINT_CODE}';
				   }
				</c:when>
				<c:otherwise>
				   BillList = [];
				</c:otherwise>
			</c:choose>	

			ISTIC = '${ISTIC}';
			PAY_TYPE = '${PAY_TYPE}';
						
			buttons.doQuery();	
			
			$('table_B').hide();
			$('gridB').hide();
			
			$('table_C').hide();
			$('gridC').hide();
						
			$('table_D').hide();
			$('gridD').hide();
			$('table_E').hide();
			
			if(SPEC=="0" && (PAY_TYPE=="1" ||PAY_TYPE=="7")){
				$('billWithNoPaper').hide();
			}else{
				$('billWithPaper').hide();
			}
			
			autoFormatToNumber();
						
			PageUI.resize();			
			displayMessage();		
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" ><B>人工暫收款</B>
					<input type="button" class="button" id="btn_INSERT" value="選取"/>	
					<input id="btn_return" type="button" class="button" value="回上一頁" />	
				</td>
			</tr>
		</table>
		<table id="gridA" width="100%" class="grid" ></table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" colspan='2'><B>暫收款清單</B>
					<input type="button" class="button" id="btn_CLEAR" value="清除"/>	
					<input type="button" class="button" id="btn_CONFIRM" value="確認"/>	
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "10%">合計</td>
				<td class="tbYellow2" width= "90%" >
					<input  type = 'hidden'  id = 'TOTAL_TRANS_AMT' value='0'/>
					<input id="TOTAL_AMT" type="text" datatype="number" class="textBox2 validate-number" size='15' maxlength="11" value='0' readOnly/>
				</td>
			</tr>			
		</table>
		<table id="gridB" width="100%" class="grid" ></table>
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>暫收款金額分配設定</B>
					<input type="button" class="button" id="btn_CHKASSIGN" value="選取確認"/>	
				</td>
			</tr>
		</table>
		<table id="gridC" width="100%" class="grid" ></table>
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>暫收款入帳試算結果</B>
					<input type="button" class="button" id="btn_CANCEL" value="取消選取確認"/>	
				</td>
			</tr>
		</table>			
		<table id="gridD" width="100%" class="grid" ></table>
		<table id="table_E" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0">
					<div id="billWithPaper">
					<B>請在印表機放入您的空白單據，其單據序號為</B>
							<input id="RECEIPT_SERNO" type="text" class="textBox2" size='15' maxlength="10" value="${RECEIPT_SERNO}"/>
							<input type="button" class="button" id="btn_BILLIN" value="入帳確認"/>
							<br><B>註：若此交易為"繳多期款項"，請您務必放入"連續之有效空白單據"，因系統會自動給定上述空白單據之下一連續單據序號(序號不可中斷)</B>
					</div>
					<div id="billWithNoPaper">
					<input type="button" class="button" id="btn_BILLIN_2" value="入帳確認"/>
					</div>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>		