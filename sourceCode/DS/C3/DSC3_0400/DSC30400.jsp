<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename='TextResource' />

<!--
程式：DSC30400.jsp
功能：轉帳組別設定
作者：林秉宏
完成：2013/07/22

240313 BY余凱鈞
資訊部門內部專用申請書:240312008585 自提優化：轉帳扣款遇長假處理優化
1.新增【轉帳合併扣款設定作業】功能，供單位自行依據不同長假情境做合併扣款輸入。
2.合併扣款設定搭配排程自動化合併抽件資料，避免人工介入合併抽件，判斷複雜又易造成疏失的困擾。
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript'><!--

	// 透過 prototype 的 Event 物件監聽 onloRad 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC30400().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC30400(){	

		var grid;
		var grid_allSelect = false;
		var valid;
		var TRANS_BANK;
		var TRANS_YM;
		
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0028 : 'BTN_update',	<%--確認--%>		
				B0270 : 'BTN_merge'		<%--合併--%>	
			};
			<dz:grantButtons FUNC_ID='DSC30400'/>
		};
		
		// 檢核
		var initValidation = function(){	
		
			valid = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
		}
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '<%=dispatcher%>/DSC3_0400/' + actionName,
			{  
				parameters: params, 
				onSuccess: function(response)
				{
					var resp = response.responseJSON
					if(CSRUtil.isSuccess(resp)){
						if(successAction){
							successAction(resp);
						}
					}else{
						if(errorAction){
							errorAction(resp);
						}
					}
				}
			});
		};	
	
		var actions = {
			validation: function(type){
				valid.reset();
				valid.clear();
				
				if(type == "doQuery"){
					valid.define('required', {id: "TRANS_YM", errMsg: '請輸入轉帳年月'});
					valid.define('validate-number', {id: "TRANS_YM", errMsg: '轉帳年月請輸入有效數字格式'});	
				}else if(type == "doMerge"){					
					valid.define('required', {id: "MERGE_TRANS_YM", errMsg: '請輸入合併轉帳年月'});
					valid.define('validate-number', {id: "MERGE_TRANS_YM", errMsg: '合併轉帳年月請輸入有效數字格式'});				
					valid.define('required', {id: "MERGE_TRANS_GROUP", errMsg: '請輸入合併轉帳組別'});
					valid.define('validate-number', {id: "MERGE_TRANS_GROUP", errMsg: '合併轉帳組別請輸入有效數字格式'});	
					valid.define('required', {id: "MERGE_MEMO", errMsg: '請輸入合併轉帳說明'});	
				}
				
				return valid.validate();
			},
		
			// 查詢
			doQuery: function(){
				
				// 檢核
				if(!actions.validation("doQuery")){
					return;
				}
				if(!isROCdate($F('TRANS_YM')+'01')) {
					alert('轉帳年月請輸入正確的民國年月格式'); 
					return;
				}

				// 頁面傳入參數
				ajaxPost( 'query' , { 'TRANS_BANK' : $F('TRANS_BANK'), 'TRANS_YM' : $F('TRANS_YM') },
					function(resp){			
						grid.load(resp.rtnList || []);
						grid_allSelect = false;
						TRANS_BANK = resp.TRANS_BANK;
						TRANS_YM = resp.TRANS_YM;
						//查詢完清空合併資訊
						$('MERGE_TRANS_YM').value ='';
						$('MERGE_TRANS_BANK').value ='1';
						$('MERGE_TRANS_GROUP').value ='';
						$('MERGE_MEMO').value ='';
					},function(resp){
						grid_allSelect = false;
						grid.load([]);
					}
				);	
			},
			
			// 確認
			doUpdate: function(){

				var chkList = grid.getCheckedRecord();
	            if(chkList.length==0){
				  alert("請至少勾選一筆資料");
				  return;
				}
							
				// 頁面傳入參數
				ajaxPost( 'update' , { 'checkList' : Object.toJSON(chkList), 'TRANS_BANK' : TRANS_BANK, 'TRANS_YM' : TRANS_YM },
					function(resp){		
						grid_allSelect = false;	
						grid.load(resp.rtnList || []);
						//確認完清空合併資訊
						$('MERGE_TRANS_YM').value ='';
						$('MERGE_TRANS_BANK').value ='1';
						$('MERGE_TRANS_GROUP').value ='';
						$('MERGE_MEMO').value ='';
					}
				);	
			},
			
			// 合併
			doMerge: function(){
				// 檢核
				var chkList = grid.getCheckedRecord();
	            if(chkList.length != 1){
				  alert("請勾選一筆資料再做合併");
				  return;
				}

				if(!actions.validation("doMerge")){
					return;
				}
				
				if(!isROCdate($F('MERGE_TRANS_YM')+'01')) {
					alert('合併轉帳年月請輸入正確的民國年月格式'); 
					return;
				}
								
				// 頁面傳入參數
				ajaxPost( 'merge' , { 'checkList' : Object.toJSON(chkList), 'TRANS_BANK' : TRANS_BANK, 'TRANS_YM' : TRANS_YM, 'MERGE_TRANS_BANK' : $F('MERGE_TRANS_BANK'), 'MERGE_TRANS_YM' : $F('MERGE_TRANS_YM'), 'MERGE_TRANS_GROUP' : $F('MERGE_TRANS_GROUP'), 'MERGE_MEMO' : $F('MERGE_MEMO')  },
					function(resp){		
						grid_allSelect = false;	
						grid.load(resp.rtnList || []);
						//合併完清空合併資訊
						$('MERGE_TRANS_YM').value ='';
						$('MERGE_TRANS_BANK').value ='1';
						$('MERGE_TRANS_GROUP').value ='';
						$('MERGE_MEMO').value ='';
					}
				);	
			},
			
			// 產生input物件
			makeInput : function(id, value, str){
				var input = new Element('input', {'id':id, 'type':'text', 'class':'textBox2 required validate-ROCDate', 'datatype':'rocdate',
					'fieldname':str, 'size':'9', 'maxlength':'7', 'value':value});
					
				input.observe('change', function(event) {
					// 重新給值									
		          	var tr=this.up('tr');
		          	dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
		          	dataObj[id] = event.target.value;		
				})	
				if( grid.isNew ? !grid_allSelect : true){
					input.disable(); 
				}
				return input;
			},
			
			// 產生處理狀況中文
			getSTATUS : function(TRANS_STATUS, DEDUCT_DATE){
				var input;
				if (TRANS_STATUS == "0") {
					input = "尚未抽件";
				} else if (TRANS_STATUS == "1") {
					input = "轉帳抽件";
				} else if (TRANS_STATUS == "2") {
					if (diffDay(DEDUCT_DATE, getToday()) > 0) {
						input = "抽件確認";
					} else {
						input = "扣款中";
					}
				} else if (TRANS_STATUS == "3") {
					input = "轉帳送回";
				} else if (TRANS_STATUS == "4") {
					input = "入帳完成";
				} else if (TRANS_STATUS == "9") {
					input = "不處理";
				} 
				return input;
			}
		};
		
		// 取得轉帳銀行中文
		var getBankName = function(value){
			<c:forEach var='map' items='${TRANS_List}'>	
				if('${map.key}' == value) {	
					return '${map.value}';
				}
			</c:forEach>
		};

		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement(
					'DSC30400' ,
					'銀行轉帳' , 
					'轉帳組別設定'
				);			
				
				// 產生 grid 物件	
				grid = new TableUI(
					{	
						table: $('grid'), allSortable:true, overDiv:false,
						autoCheckBox:{
							isSelectAll:function(node){
								grid_allSelect = this.checked;
								$('grid').select("input[type=text]").each(
									function(ele){
										if(grid_allSelect){
											$(ele).enable();
										}else{
											$(ele).disable();
										}
									}
								)
							} ,
							valueKey:'TRANS_STATUS',
						    action:function(node, boxStatus, records ){
						    	var EXTRACT_DATE_input , DEDUCT_DATE_input;
						    	if(grid.isNew){
                    				var tds = grid.getThisRecordTD(node,['EXTRACT_DATE','DEDUCT_DATE'])[0];
                    				EXTRACT_DATE_input = Element.select( tds['EXTRACT_DATE'] , 'input')[0];
									DEDUCT_DATE_input = Element.select( tds['DEDUCT_DATE'] , 'input')[0];
                    			}else{
									var tr = $(node).up('tr');
									EXTRACT_DATE_input = tr.select("td input")[1];
									DEDUCT_DATE_input = tr.select("td input")[2];
								}
								
								if (node.value == '0' && $(node).checked) {
									EXTRACT_DATE_input.enable();
									DEDUCT_DATE_input.enable();
								} else {
									EXTRACT_DATE_input.disable();
									DEDUCT_DATE_input.disable();
								}
							}
						},
						column:[
							{header:'轉帳銀行', key:'TRANS_BANK',
								render: function(record, value){
									return getBankName(value);
								}
							},
							{header:'轉帳年月', key:'TRANS_YM'},
							{header:'轉帳組別', key:'TRANS_GROUP'},
							{header:'應繳起始日', key:'BEGIN_DATE'},
							{header:'應繳終止日', key:'END_DATE'},
							{header:'系統抽件日', key:'EXTRACT_DATE',
								render : function (record , value){						
									return actions.makeInput('EXTRACT_DATE', value, '系統抽件日');
								}
							},
							{header:'銀行扣款日', key:'DEDUCT_DATE',
								render : function (record , value){						
									return actions.makeInput('DEDUCT_DATE', value, '銀行扣款日');
								}
							},
							{header:'處理狀況', key:'TRANS_STATUS',
								render : function (record , value){						
									return actions.getSTATUS(value, record.DEDUCT_DATE);
								}	
							},
							{header:'合併說明', key:'MEMO'}
						]						
					}
				);		
					
				initValidation();
				
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
				
				// 確認
				$('BTN_update').observe('click', actions.doUpdate);
				
				// 合併
				$('BTN_merge').observe('click', actions.doMerge);
				
				// 轉帳銀行預設：新郵局
				$('TRANS_BANK').value = '7';
				
				buttonAuth();
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

--></script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='10%'>
			轉帳年月
		</td>
		<td class="tbYellow2" width="35%">
			<input id="TRANS_YM" name="TRANS_YM" type="text" class="textBox2"  maxlength="5" size="7" value='${SYS_YM}'/>
		</td>
		<td class="tbYellow" width='10%'>
			轉帳銀行
		</td>
		<td class="tbYellow2" width="35%">
			<select id="TRANS_BANK" name="TRANS_BANK">				
				<c:forEach items="${TRANS_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
		</td>
		<td class="tbYellow2" width='10%' align='center'>
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" class="button" value="確認" /> 
		</td>
	</tr>
	<tr>
		<td class="tbBox3" colspan="5" align='center'>
			合併轉帳年月
			<input id="MERGE_TRANS_YM" name="MERGE_TRANS_YM" type="text" class="textBox2"  maxlength="5" size="7" />
			銀行
			<select id="MERGE_TRANS_BANK" name="MERGE_TRANS_BANK">				
				<c:forEach items="${TRANS_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			組別
			<input id="MERGE_TRANS_GROUP" name="MERGE_TRANS_GROUP" type="text" class="textBox2"  maxlength="1" size="3" />
			說明
			<input id="MERGE_MEMO" name="MERGE_MEMO" type="text" class="textBox2"  maxlength="50" size="52" />
			<input id="BTN_merge" type="button" class="button" value="合併" /> 
		</td>
	</tr>
</table>

<table id="grid" class="grid"></table>

</form>		
</body>
</html>