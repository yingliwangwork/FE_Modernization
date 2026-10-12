<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!--
程式：DSC31616.jsp
作者：余凱鈞
功能：劃撥入帳金額分配
完成：2013/09/24
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
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSC31616().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSC31616(){
	var gridB;
	var gridC;
	var gridD;
	var valid;
	var BillList;
	var ISTIC="";
	var PAY_TYPE="";	
	var dataList =[];
	var dataListC =[];
	var dataListD =[];
	var cfmPayList="N";
	var SPEC="0";
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC3_1616/" + actionName,
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
					return v.length == 10;
				}
			],
			[ 'AMT_Required', '請輸入繳劃撥金額',
				function(value,elem){  				
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || value;
				}
			]
		])
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});	
	}
	
	function defineValid(type){
		if(type=='insert'){
			//valid.define( "required" , { id: "SER_NO" , errMsg:"請輸入劃撥序號!" } );	
			valid.define( "required" , { id: "TRANS_DATE" , errMsg:"請輸入劃撥日期!" } );	
			valid.define( "required" , { id: "FACE_AMT" , errMsg:"請輸入劃撥金額!" } );	
		}else if(type=='billin'){
			valid.define( "validateRECEIPT_SERNO" , { id: "RECEIPT_SERNO" , errMsg:"單據序號輸入長度有誤!" } );	
			valid.define( "validate-number" , { id: "RECEIPT_SERNO" , errMsg:"單據序號需輸入數字!" } );		
		}
	}
		
	var actions = {
		//POP UP 開啟新視窗
	  	doPopup : function( parms ) {	
			var LINK_TO = parms.LINK_TO;
	  		if('AIL0_1300'==LINK_TO){
	  			//190211 禹含(內部申請書190212000817)：AIL01300初始查詢條件檢核調整(需傳入查詢區間)
	  			parms.QUERY_START_DATE = parms.CURRENT_DATE;
	  			parms.QUERY_END_DATE = parms.CURRENT_DATE;
	  			
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL0_1300/query',
					'parameters' :  {
						'dataObj' : Object.toJSON(parms)  //配合壽五科 洗錢防制檢核紀錄覆核及盡職/加強審查連結調整=>導頁參數調整
					}
				});
			}else if('AIL1_1000'==LINK_TO){//180917:申請書(180828001571):新增可疑交易檢核
				popupWin.popup({
					'src': '/AIWeb/servlet/HttpDispatcher/AIL1_1000/query',
					'parameters' :  {
						'QUR_ID': parms.QUERY_ID,//客戶ID/繳款人ID 
						'QUR_DATE_STR':parms.CURRENT_DATE,
						'QUR_DATE_END':parms.CURRENT_DATE,
						'COUNT':'0',
						'PAGE':'0',
						'TotalPage':'0'
					}
				});
			}
	  	}
	}
					
	var buttons = {		
		//新增
		doInsert : function(){
			valid.reset();			
			valid.clear();
			
			//新增檢核
			defineValid('insert');
			if(!valid.validate()){
				return;
			}
				
			var dataMap = {}; //A區新增資料

			$('table_A').select('input[type!=button]','select').each(function(ele){						
				dataMap[ele.id] = ele.value;
			});
			
			dataMap.TRANS_SERNO = $('TRANS_SERNO').innerHTML;
			dataMap.TRANS_DATE = toY2K($('TRANS_DATE').value || '');
			dataMap.FACE_AMT = $('FACE_AMT').getValue();
			dataMap.TRANS_NO = $('TRANS_NO').innerHTML;
			
			dataList.push(dataMap); //將A區新增資料，逐筆加入到dataList中
			
			ajaxPost( 'insert', {dataList : Object.toJSON(dataList), CASH_PAYMT : 0}
				,function(resp){
					dataListB = resp.rtnList;
					gridB.load(dataListB);
					var totalAmt=parseInt(resp.TOTAL_TRANS_AMT);
					$('TOTAL_AMT').value = CSRUtil.$fmt(totalAmt,"#,###") ; 
				}
			);
		
			$('TRANS_SERNO').update(parseInt(dataMap.TRANS_SERNO) + 1);			
		},
		//清除
		doClear : function(){	
			valid.reset();			
			valid.clear();
			
			$('TRANS_SERNO').update('${TRANS_SERNO}'); //劃撥序號還原初始劃撥序號
			$('FACE_AMT').value = '';
			$('MEMO').value = '';
			
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
			$('aTRANS_SERNO').update();
			
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
				alert("請先新增劃撥清單再進行確認!")
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
					gridB.load(dataListB);	
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
					$('aTRANS_SERNO').update("<font color='red'><B> 劃撥序號:"+record.TRANS_SERNO+" </B></font>");
				}
			);

		},
		//選取確認
		doChkAssign : function(){
			valid.reset();			
			valid.clear();
			
			var CheckedRecordB = gridB.getCheckedRecord();
			if(CheckedRecordB.length==0){
				alert("請先選取一筆劃撥資料!");
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
					alert("請檢查繳劃撥金額是否大於0!");
					return;				
				}
			}

			ajaxPost( 'chkassign', {CheckMap : Object.toJSON(CheckedRecordB[0]), BillList : Object.toJSON(CheckedRecord), dataListC : Object.toJSON(gridC.getAllRecords()),	SPEC : '${SPEC}'}
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
					$('aTRANS_SERNO').update();
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
				alert("請產生劃撥入帳試算結果後，再做入帳確認!")
				return;
			}
			
			//入帳確認檢核
			defineValid('billin');
			if(!valid.validate()){
				return;
			}
		
			ajaxPost( 'billin', {BillList : Object.toJSON(dataListD), PAY_TYPE : '${PAY_TYPE}',ISTIC : '${ISTIC}',RECEIPT_SERNO:$F('RECEIPT_SERNO'), SPEC : '${SPEC}'}
				,function(resp){				
					if(resp.ERR_MSG){
					    alert(resp.ERR_MSG);
						var parms = { //180917:申請書(180828001571):借款人保證人也都要作洗錢防制檢核(寫C117),繳款人不用檢核及寫繳款服務單
							'LINK_TO' : resp.LINK_TO,
							'QUERY_ID' : resp.QUERY_ID,
							'CURRENT_DATE' : resp.CURRENT_DATE
						}; 		
						actions.doPopup( parms );	
					} else {
						if(resp.TIPS_MSG){
							alert(resp.TIPS_MSG); //180917:申請書(180828001571):負責人或具控制權自然人若無ID，且為制裁名單，需提示(因無ID資訊無法填寫洗錢防制檢核紀錄，請確實申報，並與收費管理科聯繫)
						}			
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
				}			
			);
		}
	};

	return{	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSC31616" , "核心放款" , "給付方式 劃撥");
			
			gridB = new TableUI({
				table: $('gridB'), allSortable: false,
				autoCheckBox:{
					text:'選取', 
					type:'radio',
					action:function(node, boxStatus, records ){
						if(!boxStatus) return;
						buttons.doAssign(records[0]);
					},
					genRule:function(record , value){ 
						//return dataListC.size()>0 ;
						return cfmPayList=="Y" ? true : false;
					}
				},				
				column: [
					{header:"劃撥序號", key:'TRANS_SERNO'},
					{header:"劃撥帳號", key:'TRANS_NO'},
					{header:"劃撥日期", key:'TRANS_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}},
					{header:"劃撥金額", key:'FACE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"備註", key:'MEMO'}		
				]	
			});
					
			gridC = new TableUI({
				table: $('gridC'), pageSize: 20, allSortable: false, overDiv : false,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					valueKey: 'preCheck'
				},				
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM'},
					{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"繳劃撥金額", key:'TRADE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
						},  
						input:{type:'number' , size:10 , maxlength:10 , className : 'textBox2 AMT_Required validate-number'}   
					}					
				]		
			});
			
			gridD = new TableUI({
				table: $('gridD'), pageSize: 20, allSortable: false, overDiv : false,		
				column: [
					{header:"貸款帳號", key:'LOAN_ID'},
					{header:"期數", key:'PAY_TERM'},
					{header:"應繳金額", key:'DUTY_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"實繳金額", key:'REAL_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"繳劃撥金額", key:'REAL_PAYMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"劃撥序號", key:'TRANS_SERNO'},
					{header:"劃撥金額", key:'FACE_AMT', attrs: {align:"right"},
						render:function(rec,val){
							return (val||val===0) ? CSRUtil.$fmt(val,"#,###") : 0 ; 
					}},
					{header:"劃撥日期", key:'TRANS_DATE',
						render : function (rec , val){
							return Date.toROC(val || "");
					}}						
				]	
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
			
			//輸入完畢自動跳下一欄位
			$('TRANS_DATE').observe('keyup', function(event){
				if ($F('TRANS_DATE').length == 7){ 
						$('FACE_AMT').focus();
					}
				} 
			);
			
			<c:choose>
				<c:when test='${not empty BillList}'>
				   BillList = ${BillList};
				   ISTIC = ${ISTIC};
				   PAY_TYPE = ${PAY_TYPE};		
				   SPEC = '${SPEC}';				   
				</c:when>
				<c:otherwise>
				   BillList = [];
				</c:otherwise>
			</c:choose>	
						
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
			
			$('TRANS_SERNO').update('${TRANS_SERNO}');
			
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
				<td class="tbYellow0" colspan='6'><B>劃撥</B>
					<input type="button" class="button" id="btn_INSERT" value="新增"/>	
					<input type="button" class="button" id="btn_return" value="回上一頁" />						
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align='center'>劃撥序號</td>
				<td class="tbYellow" width="15%" align='center'>劃撥帳號</td>
				<td class="tbYellow" width="15%" align='center'>劃撥日期</td>
				<td class="tbYellow" width="20%" align='center'>劃撥金額</td>
				<td class="tbYellow" width="40%" align='center'>備註</td>
			</tr>
			<tr>
				<td class="tbYellow2" align='center'>
					<span id="TRANS_SERNO"></span>
				</td>
				<td class="tbYellow2" align='center'>
					<span id="TRANS_NO">00041496</span>
				</td>				
				<td class="tbYellow2" align='center'>
					<input id="TRANS_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="9" maxlength="7" value='${TODAY}'/>
					<img src="<%=imageBase%>/CM/calendar.gif"  onclick="getCalendarFor($('TRANS_DATE'))" />		
				</td>
				<td class="tbYellow2" align='center'>
					<input id="FACE_AMT" type="text" datatype="number" class="textBox2 validate-number" size='15' maxlength="11" />
				</td>
				<td class="tbYellow2" align='center'>
					<input id="MEMO" type="text" class="textBox2" size='40' maxlength="40" />
				</td>
			</tr>
		</table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0" colspan='4'><B>劃撥清單</B>
					<input type="button" class="button" id="btn_CLEAR" value="清除"/>	
					<input type="button" class="button" id="btn_CONFIRM" value="確認"/>	
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width= "10%">合計</td>
				<td class="tbYellow2" width= "90%" >
					<input id="TOTAL_AMT" type="text" datatype="number" class="textBox2 validate-number" size='15' maxlength="11" value='0' readOnly/>
				</td>
			</tr>
		</table>
		<table id="gridB" width="100%" class="grid" ></table>
		<table id="table_C" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>劃撥金額分配設定</B>
					<span id = "aTRANS_SERNO"></span>
					<input type="button" class="button" id="btn_CHKASSIGN" value="選取確認"/>
				</td>
			</tr>
		</table>
		<table id="gridC" width="100%" class="grid" ></table>
		<table id="table_D" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow0"><B>劃撥入帳試算結果</B>
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