<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSC33700.jsp
功能：劃撥單列印
作者：張至偉
完成：2018/06/15
2018-07-18問題單編號 20180718-0029因畫面查詢條件欄位貸款帳號、借款人ID雖然看起來有自動將英文轉大寫，但送到後端時還是以原本key的小寫查詢，導致查無資料。  
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type='text/javascript'>

Event.observe(window, 'load', new DSC33700().initApp);

function DSC33700(){

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC3_3700/');

	var grid;
	var log_grid;
	var has_LOAN_ID_Q = '${has_LOAN_ID_Q}'; // Y or null
	var valid1;

	function initValidation(){
		Validation.addAllThese([
			[ 'validateLOAN_ID_10', '貸款帳號格式錯誤，應為10碼',
				function(v){
					if(v){
						return (v.length != 10) ? false : true ;
					}
					return true;
				}
			],
			[ 'chkUsableID', '借款人ID格式錯誤，需符合身分證或統一編號格式',
				function(v){
					if(v){
						if(v.length == 8){
							return iscmpid(v); 
						}else{
							return validation.checkROCID(v); 
						}
					}
					return true;
				}
			],
			[ 'validSelectOne', '貸款帳號與借款人ID只能擇一輸入',
				function(v1,v2){
					var v1Empty = Validation.get('IsEmpty').test(v1);
					var v2Empty = Validation.get('IsEmpty').test(v2);
					if(v1Empty ^ v2Empty){
						return true; 
					}
					return false; 
				}
			]
		]);
		// 查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode:'validator'});
		valid1.define( "validateLOAN_ID_10" , { id: "LOAN_ID"});
		valid1.define( "chkUsableID" , { id: "BORROW_ID"});
		valid1.define( "validSelectOne" , [{ id: "LOAN_ID"},{ id: "BORROW_ID"}]);
	}

	var actions={
		printConfirm : function(checkRecord){
			<%--
			迴圈比對選取的Ｂ區資料與Ｃ區資料，若Ｂ區貸款帳號(LOAN_ID)、期數(PAY_TERM)有存在在Ｃ區的話，
			提示【貸款帳號XXXXXXXXXX(、XXXXXXXXXX)欲列印之期數曾有過列印紀錄，請提醒客戶持最新的劃撥單繳款。】，
			若按下確定則往下做，否則提留在原畫面。有多筆貸款帳號則用、接在前個貸款帳號後。
			--%>
			var logRecord = log_grid.getAllRecords();
			var logJSON = Object.toJSON(logRecord);
			var B_list = {};
			var alert_list = [];
			
			<%-- 紀錄 B 區待確認資料 --%>
			for( var i=0; i<checkRecord.length; i++){
				var LOAN_ID = checkRecord[i]['LOAN_ID'];
				var PAY_TERM = checkRecord[i]['PAY_TERM'].toString();
				if(LOAN_ID in B_list){
					B_list[LOAN_ID].push(PAY_TERM);
				}else{
					B_list[LOAN_ID] = []
					B_list[LOAN_ID].push(PAY_TERM);
				}
			}
			
			<%-- 確認需串接的帳號 --%>
			for( var i=0; i<logRecord.length; i++){
				var LOAN_ID = logRecord[i]['LOAN_ID'];
				var PAY_TERM = logRecord[i]['APPLY_ID'];

				if(LOAN_ID in B_list){
					if(B_list[LOAN_ID].indexOf(PAY_TERM)>-1){
						if(alert_list.indexOf(LOAN_ID)<0){
							alert_list.push(LOAN_ID);
						}
					}
				}
			}
			
			<%-- 串接提示訊息 --%>
			if(alert_list.length>0){
				var alertMsg = "";
				for( var i=0; i<alert_list.length; i++){
					alertMsg += ", "+alert_list[i];
				}
				alertMsg = "貸款帳號"+alertMsg.substring(1)+" 欲列印之期數曾有過列印紀錄，請提醒客戶持最新的劃撥單繳款。";
				
				return confirm(alertMsg);
			}
			
			return true;
		}
	};

	var buttons={

		<%-- 查詢 --%>
		doQuery : function(){

			valid1.reset();

			if (!$F('LOAN_ID') && !$F('BORROW_ID')) {
				alert('請輸入貸款帳號或借款人ID查詢！');
				return;
			}
			
			if (!valid1.validate()) {
				return;
			}

			ajaxRequest.post( 'query', {LOAN_ID: $F('LOAN_ID'), BORROW_ID: $F('BORROW_ID')},
				function(resp){
					grid.load(resp.rtnList||[]);
					
					<%-- C 區: 檢查是否有列印記錄 --%>
					var logList = resp.logList;
					if(logList.length!=0){
						$('log_table').show();
						log_grid.load(logList||[]);
					}else{
						$('log_table').hide();
					}
					
					<%-- D 區 : 檢查是否有警告訊息 --%>
					if(resp.WARN_MSG){
						$('MSG').update(resp.WARN_MSG);
						$('WARN_MSG_AREA').show();
					}else{
						$('WARN_MSG_AREA').hide();
					}
				},
				function(resp){
					grid.load([]);
				}
			);
		},
		
		doPrint : function(){

			if(grid.getAllRecords().length == 0){
				alert('請先執行查詢！');
				return;
			}
			
			var checkRecord = grid.getCheckedRecords();
			var checkRecordlength = checkRecord.length;
			
			if(checkRecordlength==0){
				alert("請選擇欲列印劃撥單的項目！");
				return;
			}
			
			if(!actions.printConfirm(checkRecord)){
				return;
			}
			RPTUtil.downloadFile('${dispatcher}/DSC3_3700/print' , {printList: Object.toJSON(checkRecord)}, true ); //2018-07-17浮水印報表
			//RPTUtil.executePrintByLink('print' , {printList: Object.toJSON(checkRecord)}, true );
		}
	}
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay'/>
				
			PageUI.createPageWithAllBodySubElement('DSC33700', '放款繳息', '劃撥單列印');
			
			<%-- 初始檢核 --%>
			initValidation();
			
			<%-- B 區: 查詢結果 --%>
			grid = new TableUI({
				table: $("grid"),
				pageSize : 10,
				allSortable: false,
				overDiv:true,
				autoCheckBox:{
					text:'選取', 
					isSelectAll:true,
					valueKey:'preCheck',
					action:function(node, boxStatus, records){

						var chkList = grid.getCheckedRecord();
						var allList = grid.getAllRecords();
						
						ajaxRequest.post( 'select', {'chkList':Object.toJSON(chkList),'allList':Object.toJSON(allList)},
							function(resp){
								grid.load(resp.allList || [], [], null, ["Y"]);
							}
						);	
					}
				},
				column:[
					{header:"貸款帳號", key:"LOAN_ID"},
					{header:"期數", key:"PAY_TERM"},
					{header:"應繳日", key:"NEXT_PAYDT", sortRule:"date"},
					{header:"應繳金額", key:"DUTY_PAYMT", sortRule:"number", attrs:{align:"right"}}
				]
			});
			
			<%-- C 區: 已列印記錄 --%>
			log_grid = new TableUI({
				table: $("log_grid"),
				pageSize: 10,
				allSortable: false,
				overDiv: true,
				column:[
					{header:"貸款帳號", key:"LOAN_ID"},
					{header:"期數", key:"APPLY_ID"},
					{header:"應繳日", key:"MSG", sortRule:"date"},
					{header:"應繳金額", key:"OTHER_ID", sortRule:"number", attrs:{align:"right"}},
					{header:"列印日期", key:"EXEC_TIME", sortRule:"date"}
				]
			});

			<%-- 按鈕監聽 --%>
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_PRINT').observe('click',buttons.doPrint);
			
			<%-- 當輸入「貸款帳號」欄位需連動清空「借款人ID」 --%>
			$('LOAN_ID').observe('click', function(){
				$('BORROW_ID').value = '';
			});
			
			<%-- 當輸入「借款人ID」欄位需連動清空「貸款帳號」 --%>
			$('BORROW_ID').observe('click', function(){
				$('LOAN_ID').value = '';
			});

			<%-- C 區: 列印記錄, 初始無查詢時，該區隱藏 --%>
			$('log_table').hide();
			<%-- 警告訊息, 初始無查詢時，該區隱藏 --%>
			$('WARN_MSG_AREA').hide();
			
			<%-- 若貸款帳號 LOAN_ID_Q 有值, INPUT 欄位反白，不得修改查詢條件 --%>
			if(has_LOAN_ID_Q){
				$('LOAN_ID').value = '${LOAN_ID}';
				$('LOAN_ID').disabled = true;
				$('BORROW_ID').disabled = true;
				buttons.doQuery();
			}

			//初始頁面alert訊息用
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<%-- A 區 --%>
		<tr>
			<td class="tbYellow" width="15%">貸款帳號</td>
			<td class="tbYellow2" width="15%">
				<input id="LOAN_ID" title="貸款帳號" type="text" class="textBox2" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
			</td>
			
			<td class="tbYellow" width="15%">借款人ID</td>
			<td class="tbYellow2" width="15%">
				<input id="BORROW_ID" title="借款人ID" type="text" class="textBox2" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
			</td>
			
			<td class="tbYellow2">
				<button id="BTN_QUERY" type="button" class="button">查詢</button>
				<button id="BTN_PRINT" type="button" class="button">列印劃撥單</button>
			</td> 			
		</tr>
		<%-- B 區 --%>
		<tr>
			<td class="tbYellow0" width="15%" align='left' colspan='5'><B>可列印劃撥單明細</td>
		</tr>
		<tr>
			<td colspan='5'><table id = "grid" ></table></td>
		</tr>
		<tr id= "WARN_MSG_AREA">
		<td class="tbYellow0" colspan='5'>			
			<B>◎訊息:		
			<span id="MSG"></span>
			</B>
		</td>
	</tr>
	</table>
</form>
<%-- C 區 --%>
<table id="log_table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow0" width="15%" align='left' colspan='5'><B>已列印記錄</td>
	</tr>
	<tr>
		<td colspan='5'><table id="log_grid" ></table></td>
	</tr>
</table>
</body>
</html>