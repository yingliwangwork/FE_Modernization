<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC32100.jsp
功能：電匯入人工帳
作者：溫子?
完成：2013/05/22

[20220705]
	1.房貸債務清理帳務作業
[20221109] 
 	修正輸入貸款帳號連動下拉選單
[20230201]
	暫收原因為"其它"時，控制不需去檢核"債務人"必須填寫
[20230209]
	取消債務人輸入欄位，調整暫收原因及債務人位置
[20241104]
	修改件 難字調整 吳志鴻
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>		  <%-- 月曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			 <%-- 日期用 --%>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>

<%-- [20241104] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type='text/javascript'><!--
Event.observe(window, 'load', new DSC32100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC32100(){
var count;
var newSerNO;
var tempMap={};
var Temp_AMT=0;
var grid;
var records;
<%-- [20221109] 修正輸入貸款帳號連動下拉選單 --%>
var debtorList = <c:out value="${DEBTOR_IDList}" default="[]" escapeXml="false" />;
<%-- [20221109] 修正輸入貸款帳號連動下拉選單 顯示邏輯--%>
<%-- [20230209] 取消債務人輸入欄位，調整暫收原因及債務人位置--%>
	//畫面檢核
	function initValidation(){
	
	    Validation.addAllThese([
				
			[ 'TRANS_AMT_NOT0', '請輸入正確電匯金額',
				function( v , elem ) {
					if(v>0){
						return true;
					}else{
						return false;
					}
				},
			],
			[ 'TRANS_DATE_CHK', '電匯日期須小於等於作業當時日期',
				function( v , elem ) {
					var sysDT=toROC('${SYS_DT}');
					if(diffDay(sysDT,v,true)>0){
						return false;
					}else{
						return true;
					}
				},
			],
			['validFormat', '單位代號/貸款帳號格式有誤', function(v , node) { 
				if(v){
					return (/^[a-zA-Z0-9]+$/.test(v));  //檢核英數
				}
				return true;
			}],
			['validDateLength', '電匯日期格式有誤', function(v , node) { 
				if(v){
					return v.length == 7;
				}
				return false;
			}]			
			
	    	
		]);
	
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	

	}

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSC3_2100/" + actionName,
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
	var actions = {

		//產生TableUI中裡面的input欄位(B區)
		createInputElement : function(colkey,value,type,col_nm){
			var theID = colkey;
			if(type == 'date'){ //電匯日期
				var td = new Element('span');
				var input;
				input = new Element('input', 
					{className:'textBox2 validate-ROCDate required TRANS_DATE_CHK validDateLength', id:theID, name:theID+'_input', datatype:'ROCdate', size:'9', maxlength:'7', fieldName:col_nm}
					//原寫法chrome會有問題
				);
				//input.value = value || '';
				input.value = Date.toInputROC( value || '' ,'');
				input.observe('change' , function(event){
					var tr = this.up('tr');	
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					dataObj[colkey] = toY2K(event.target.value||'');
				});
				
				var clan =  new Element('img', { src : '<%=imageBase%>/CM/calendar.gif' , alt : 'Date'});			
				clan.observe('click' , function(event){					
					getCalendarFor(input);
				});
				td.insert(input).insert(clan);
				
				return td;
			}else if(type == 'number'){ //電匯金額
				//for自動化測試：input name
				var input = new Element('input', 
					{className:'textBox2', id:theID, name:theID+'_input', type:'text', datatype:'number', pattern:'#,###', size:'15', maxLength:'15', fieldName:col_nm}
				);				
				input.value = value || value===0 ? CSRUtil.$fmt(value,'#,###') : '';
				
				input.observe('blur' , function(event){						
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var new_value = event.target.value;
					/*if('TRANS_AMT'==colkey){
						Temp_AMT=Temp_AMT-dataObj.TRANS_AMT+parseInt(new_value.replace(/,/g,'')); 
						$('TOTAL_AMT').update(CSRUtil.$fmt(Temp_AMT,'#,###')); //暫收款資料 合計金額
					}*/
				
					input.value = new_value || new_value===0 ? CSRUtil.$fmt(new_value,'#,###') : ''; //加三位一撇
					dataObj[colkey] = new_value.replace(/,/g,'');
					
					ajaxPost( 'getTotalAmt' ,{'transList':Object.toJSON(grid.getAllRecords(['TRANS_AMT']))},
						function(resp){	
							$('TOTAL_AMT').update(CSRUtil.$fmt(resp.TOTAL_AMT,'#,###')); //暫收款資料 合計金額
						}
					);
				});
				
				return input; 
			}
		},
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
	  	},
	  	
	  	<%-- [20221109] 修正輸入貸款帳號連動下拉選單 --%>
	  	<%-- [20220204] 修正輸入貸款帳號連動下拉選單 移除請選擇 增加前贅字--%>
		<%-- [20230209] 取消債務人輸入欄位，恢復請選擇選項--%>
		doQueryDebtor :function (){
			$('DEBTOR_ID_SELECT').innerHTML = "";;
			ajaxPost( 'queryDebtor' ,{LOAN_ID:$F('LOAN_ID')},
				function(resp){
					debtorList = resp.DEBTOR_IDList || [];
					var opt = new Element('option', { 'value': '' }).update('請選擇');
					$('DEBTOR_ID_SELECT').insert(opt);
					for(var i = 0; i < debtorList.length; i++){
						var e = debtorList[i];	
						var opt = document.createElement('option');
						opt.value = e.DEBTOR_ID;
						var DEBTOR_TYPE = e.DEBTOR_TYPE
						var TYPE;
						switch(DEBTOR_TYPE){
							case ('DEB'):
							TYPE = "借款人_";
							break
							case ('GUA'):
							TYPE = "保證人_";
							break
							case ('ANC'):
							TYPE = "繼承人_";
							break
						}
						opt.innerHTML = TYPE + e.DEBTOR_NAME;
						$('DEBTOR_ID_SELECT').appendChild(opt);
					};
					<%-- [20230213] 如果暫收原因選其它，債務人下拉連動預設有"請選擇"，別的選項皆預設"借款人"--%>
					if($F('BALC_REASON') == 99){
						$('DEBTOR_ID_SELECT').options[0].selected = true;
					} else if($F('BALC_REASON') != 99 && debtorList.length > 0) {
						$('DEBTOR_ID_SELECT').options[1].selected = true;
					}
				}
			);
		},
		<%-- [20230213] 如果暫收原因選其它，債務人下拉連動預設有"請選擇"，別的選項皆預設"借款人"--%>
		changeDEBTOR :function (){
			if($F('BALC_REASON') == 99){
				$('DEBTOR_ID_SELECT').options[0].selected = true;
			} else if($F('BALC_REASON') != 99 && debtorList.length > 0) {
				$('DEBTOR_ID_SELECT').options[1].selected = true;
			}
		}
	};
	
	
	var buttons={
		//新增
		doInsert :function (){

			if(!$F('LOAN_ID')){
				alert("單位代號/貸款帳號不可空白!!");
				return;
			}

			<%-- [20230213] 暫收原因為"其它"時，控制不需去檢核"債務人"必須填寫 --%>
			if($F('BALC_REASON') != 99){
				if(!$F('DEBTOR_ID_SELECT')){
					alert("請選擇債務人!!");
					return;
				}
			}
			
			var dataList = grid.getAllRecords();
			count=count+1;
			dataList.push(
				{TRANS_SERNO:count, TRANS_NO:'${TRANS_NO}', TRANS_DATE:'${TRANS_DATE}', TRANS_AMT:0, REMARK:'',preCheck:'Y'}
			);
			grid.load(dataList, null, null, ["Y"]);
			
			autoFormatToNumber();
		},
		//確認
		doConfirm : function (){

			<%-- [20230209] 取消債務人輸入欄位--%>
			//grid1 資料輸入檢核
			if(grid.validCheckedOnTable()){
				alert("備註字數不可大於20個中文字");
				return;
			}
				
			valid1.reset();
			if($('BALC_REASON').value==17&&!confirm('確定暫收原因為入追償款，且已經輸入貸款貸號？')){//暫收原因為入追償款
				return;
			}
			if($('BALC_REASON').value==15&&!confirm('確定暫收原因為入案款，且已經輸入貸款貸號？')){//暫收原因為入案款
				return;
			}
			if(!valid1.validate()){				
				return; 
			}

			if($F('LOAN_ID').length!=7 && $F('LOAN_ID').length!=10) {
				if(!confirm('請確認單位代號/貸款帳號的長度不為7碼或10碼？')){
					return;
				}
			}				
			<%--[20220705]--%>
			<%-- [20221109] 修正輸入貸款帳號連動下拉選單  --%>
			<%-- [20220204] 修正輸入貸款帳號連動下拉選單 移除請選擇 增加前贅字--%>
			var DEBTOR_ID;
			var DEBTOR_NAME;
			<%-- [20230209] 債務人下拉是"請選擇"時，債務人就塞空值--%>
			DEBTOR_ID = $('DEBTOR_ID_SELECT').value;
			if (DEBTOR_ID ==''){
				DEBTOR_NAME ='';
			} else {
				DEBTOR_NAME = $('DEBTOR_ID_SELECT').options[$('DEBTOR_ID_SELECT').selectedIndex].text;
				DEBTOR_NAME = DEBTOR_NAME.split('_')[1];
			}
			
			var transList = grid.getCheckedRecord();	
			for(var i=0; i<transList.length; i++){
				var selectMap=transList[i];	
				var TRANS_AMT=selectMap['TRANS_AMT'];
				if(!TRANS_AMT && TRANS_AMT!=0){
					selectMap['TRANS_AMT']=0;
				}
				
				TRANS_AMT=selectMap['TRANS_AMT'];
				if((!TRANS_AMT || TRANS_AMT<=0)){
					alert('請輸入正確的電匯金額:電匯序號'+selectMap['TRANS_SERNO']);
					return;
				}		
				<%--[20220705]--%>
				selectMap['DEBTOR_ID'] = DEBTOR_ID;
				selectMap['DEBTOR_NAME'] = DEBTOR_NAME;
			}
			var TOTAL_AMT = $('TOTAL_AMT').innerHTML.replace(/,/g,'');

			ajaxPost( 'confirm', {transList:Object.toJSON(transList),LOAN_ID:$F('LOAN_ID'),BALC_REASON:$F('BALC_REASON'),TOTAL_AMT:TOTAL_AMT,DEBTOR_ID:DEBTOR_ID}
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
						
						var rtnList=[{TRANS_SERNO:resp.TRANS_SERNO, TRANS_NO:resp.TRANS_NO, TRANS_DATE:resp.TRANS_DATE, TRANS_AMT:0, REMARK:'',preCheck:'Y'}];
						grid.load(rtnList, null, null, ["Y"]);		
						count=resp.TRANS_SERNO;
						newSerNO=resp.TRANS_SERNO;
					}
				}
			);
		},
		//刪除
		doDelete :function (){
			var selectData=grid.getCheckedRecord();
			if(selectData.length==0){
				  alert("請勾選欲刪除的電匯資料");
				  return;
			}
			var initSERNO=newSerNO;
			var records = grid.getAllRecords();
			var newDataList=[];
			if(selectData.length==records.length){
				var item={TRANS_SERNO:newSerNO, TRANS_NO:'${TRANS_NO}', TRANS_DATE:'${TRANS_DATE}', TRANS_AMT:0, REMARK:'',preCheck:'Y'};
				Temp_AMT=0;
				count=newSerNO;
				newDataList.push(item);				
			}else{
				var del_flag;
				var counter=0;
				Temp_AMT=0;
				for(var i = 0 ; i < records.size() ; i++){
						var item =records[i];
						del_flag=false;
						for(var j=0;j<selectData.size();j++){
							var delItem=selectData[j];
							if(item.TRANS_NO==delItem.TRANS_NO && item.TRANS_SERNO==delItem.TRANS_SERNO){
								del_flag=true;
								break;
							}
						}
						if(!del_flag){
							item['TRANS_SERNO']=parseInt(initSERNO)+counter;						
							newDataList.push(item);
							Temp_AMT=Temp_AMT+parseInt(item.TRANS_AMT, 10) ;
							counter++;
						}
				}
				count=parseInt(initSERNO)+counter-1;
				
			}				
			grid.load(newDataList,null,null,['Y']);
			$('TOTAL_AMT').update(CSRUtil.$fmt(Temp_AMT,'#,###')); //暫收款資料 合計金額			
			previousRecord = null;
		}
	}
	
	
	return {
		initApp : function() {
			<c:forEach var="map" items="${TRANS_NOList}">
				tempMap["${map.key}"]="${map.value}";
			</c:forEach>
		
			PageUI.createPageWithAllBodySubElement('DSC32100', '繳款方式', '電匯入人工帳');
			
			initValidation();
			
			grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:false,
				autoCheckBox:{
					text:'選取', 
					type:'checkbox',
					isSelectAll:true,
					valueKey: 'preCheck',
					action:function( node , boxStatus , records ){ 						
						//下拉選單沒change時的處理
						var tr = node.up('tr');
						var dataObj = tr.getAttribute('dataObj');
						tr.select('select').each(function(ele){
							if(!dataObj[ele.name]){
								dataObj[ele.name] = ele.value;
							}
						});		
					} 
				}, 
				validateRecord:function( rec , sn ){ 
					if(!validation.checkInputLength(rec['REMARK'], 40)){
						return false; 
					}
				},
				column:[
					{header:"電匯序號", key:"TRANS_SERNO"},
					{header:"電匯帳號",key:"TRANS_NO",
					    input:{
						    type:'select',
							opts:tempMap
						}
					},
					{header:"電匯日期",key:"TRANS_DATE",
						render : function(record, value){
							return actions.createInputElement('TRANS_DATE',value,'date','電匯日期');
						}
					},
					{header:"電匯金額",key:"TRANS_AMT", 
						render : function(record, value){
							return actions.createInputElement('TRANS_AMT',value,'number','電匯金額');
						}
					},
					{header:"備註",key:"REMARK",
						input:{type:'TEXT' , size:40 , maxlength:40 , width:30 }
					}
				]}
			);		
				
			//預設電匯資料
			records=[{TRANS_SERNO:'${TRANS_SERNO}', TRANS_NO:'${TRANS_NO}', TRANS_DATE:'${TRANS_DATE}', TRANS_AMT:0, REMARK:'',preCheck:'Y'}];
			grid.load(records, null, null, ["Y"]);
			
			autoFormatToNumber();
			
			count=${TRANS_SERNO};
			newSerNO=${TRANS_SERNO};
			$('TOTAL_AMT').update('0');
			$('BALC_REASON').value=99;
			$('BTN_INSERT').observe('click',buttons.doInsert);
			$('BTN_CONFIRM').observe('click', buttons.doConfirm);
			$('BTN_DELETE').observe('click', buttons.doDelete);
			<%-- [20221109] 修正輸入貸款帳號連動下拉選單  --%>
			$('LOAN_ID').observe('change', actions.doQueryDebtor);
			<%-- [20230213] 取消債務人輸入欄位，調整暫收原因及債務人位置--%>
			$('BALC_REASON').observe('change', actions.changeDEBTOR);
			//先把畫面區塊都調整到位再顯示訊息
			fix();	

			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}

</script>
</head>
	<body>
		<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="20%">單位代號/貸款帳號</td>
					<td class="tbYellow2"  >
						<input id="LOAN_ID"  type="text" class="textBox2 validFormat" value="${LOAN_ID}" maxlength="10" onblur="this.value = this.value.toUpperCase()"/>
					</td>
					<%-- [20230209] 取消債務人輸入欄位，調整暫收原因及債務人位置--%>
					<td class="tbYellow" >暫收原因</td>
					<td class="tbYellow2" width="15%" >
						<select id="BALC_REASON">
							<option value="">請選擇</option>
							<c:forEach var="map" items="${BALC_REASONList}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select> 
						<input  type = 'hidden'  id = 'PAY_TYPE' value="7"/>
					</td>
					<%--[20220705]--%>
					<%-- [20221109] 修正輸入貸款帳號連動下拉選單 --%>
					<td class="tbYellow">債務人名稱</td>
					<td class="tbYellow2" width="15%" >
						<div id="isShowDebtorSelect">						
							<select id="DEBTOR_ID_SELECT" name="DEBTOR_ID" alt="ch">  <%-- [20241104] 難字調整:債務人名稱 --%>
								<option value="">請選擇</option>
								<c:forEach var="map" items="${DEBTOR_IDList}">
									<option value="${map.DEBTOR_ID}">${map.DEBTOR_NAME}</option>  
								</c:forEach>
							</select>
						</div>
					</td>
					<td class="tbYellow2" align="center">
						<input id="BTN_INSERT" type="button" value="新增" class="button" > 
						<input id="BTN_DELETE" type="button" value="刪除" class="button" > 
					</td>
				</tr>
				<tr>
					<td class="tbYellow0" width="7%"><B>暫收款資料 合計金額</td>
					<%-- [20221109] 修正輸入貸款帳號連動下拉選單 --%>
					<td class="tbYellow2"  colspan="8">
					<span id="TOTAL_AMT"></span>
				</tr>
				
			</table>
			<table id = "grid" ></table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
				<tr>
					<td class="tbYellow2" align="left" colspan='5'>
					<input id="BTN_CONFIRM" type="button" value="確認" class="button" align="center" > 
					</td>
				</tr>
			</table>
		</form>	
	</body>	
</html>