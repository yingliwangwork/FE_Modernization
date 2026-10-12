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
程式：DSC81400.jsp
功能：聯絡電話變更
作者：林秉宏
完成：2013/07/18

[20170530]修改件
作業畫面揭露借款戶所有帳號,並可全選或勾選指定帳號,一次動作完成變更

[20230321]
難字調整
高強禾
 -->

<title></title>
 
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
 
<!--自行定義的javaScript-->
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>

<%-- [20230321] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
		url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>

<script type='text/javascript'>

	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
	Event.observe(window, 'load', new DSC81400().initApp);
	Event.observe(window, 'resize', fix);
	Event.observe(window, 'scroll', fix);
		
	//--------------------------------------------------------------------------
	function DSC81400(){
		
		var grid1;
		var valid1;
		var valid2;
	
		// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0054 : 'BTN_update'		<%--變更--%>		
			};
			<dz:grantButtons FUNC_ID='DSC81400'/>
		};
		
		// 檢核
		var initValidation = function(){	

			valid1 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			
			Validation.addAllThese( [
				[ 'chkUsableID', '借款人ID格式錯誤!', function(){
					var ID = $F('BORROW_ID');
					if(!ID.blank()){
						if(validation.checkUniSN(ID) || validation.checkROCID(ID) || validation.checkROCARC(ID)) { 
							return true;
						}
						return false;
					}
					return false;
				}],
				[ 'chkTelArea', '', function(area, num){
					return !(num && Validation.get('IsEmpty').test(area));
				}]
			] );
			
			valid1.define( "chkUsableID" , [{ id : "BORROW_ID" } ] );
			
			valid2 = new Validation('form1', { focusOnError:true, immediate:false, mode : 'validator' });
			
			valid2.define( "validate-email" , [{ id : "EMAIL" } ] );
			//20231016 問題單20230419-0175：判斷連絡電話有值才檢核連絡電話區碼
			valid2.define( "chkTelArea" , [{ id: 'DAY_TEL_AREA',  errMsg:"連絡電話(日一)區碼未選擇" }, {id: 'DAY_TEL_NUM', ignore: true } ] );
			valid2.define( "chkTelArea" , [{ id: 'DAY_TEL_AREA2',  errMsg:"連絡電話(日二)區碼未選擇" }, {id: 'DAY_TEL_NUM2', ignore: true } ] );
			valid2.define( "chkTelArea" , [{ id: 'DAY_TEL_AREA3',  errMsg:"連絡電話(日三)區碼未選擇" }, {id: 'DAY_TEL_NUM3', ignore: true } ] );
			valid2.define( "chkTelArea" , [{ id: 'NIGHT_TEL_AREA',  errMsg:"連絡電話(夜一)區碼未選擇" }, {id: 'NIGHT_TEL_NUM', ignore: true } ] );
			valid2.define( "chkTelArea" , [{ id: 'NIGHT_TEL_AREA2',  errMsg:"連絡電話(夜二)區碼未選擇" }, {id: 'NIGHT_TEL_NUM2', ignore: true } ] );
			valid2.define( "chkTelArea" , [{ id: 'NIGHT_TEL_AREA3',  errMsg:"連絡電話(夜三)區碼未選擇" }, {id: 'NIGHT_TEL_NUM3', ignore: true } ] );
			//20211207 問題單20210608-0030：因單位使用複製貼上的方式將中文貼到輸入框，datatype設定無法卡控，故再增加validation檢核
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_NUM", errMsg:"連絡電話(日一)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_EXT", errMsg:"連絡電話(日一)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_NUM", errMsg:"連絡電話(夜一)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_EXT", errMsg:"連絡電話(夜一)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_NUM2", errMsg:"連絡電話(日二)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_EXT2", errMsg:"連絡電話(日二)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_NUM2", errMsg:"連絡電話(夜二)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_EXT2", errMsg:"連絡電話(夜二)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_NUM3", errMsg:"連絡電話(日三)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "DAY_TEL_EXT3", errMsg:"連絡電話(日三)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_NUM3", errMsg:"連絡電話(夜三)號碼必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "NIGHT_TEL_EXT3", errMsg:"連絡電話(夜三)分機必須為數字格式" } ] );
			valid2.define( "validate-positive" , [{ id : "MOBILE", errMsg:"行動電話必須為數字格式" } ] );
			
			
			//[20180531]修改件
			//拔掉有關電話輸入框檢核規則(不可輸入非數字)改綁該輸入框只能輸入數字
		};
		
		// 共用AJAX
		var ajaxPost = function (actionName, params, successAction, errorAction)
		{	
			new Ajax.Request( '${dispatcher}/DSC8_1400/' + actionName,
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
		
			// 查詢
			doQuery: function(){
			
				actions.clearEditArea();
				grid1.clear();
				$('BORROW_NAME_span').update('');
				
				valid1.reset();
				// 檢核
				if(!valid1.validate()){ 
					return; 
				}
				//[20180531]修改件
				//查詢參數由LOAD_ID改成BORROW_ID且回傳結果由單筆改成多筆
				//頁面傳入參數
				ajaxPost( 'query' , { 'BORROW_ID' : $F('BORROW_ID') },
					function(resp){	
						var rtnList = resp.rtnList;
						grid1.load(rtnList || []);
						if(rtnList && rtnList.length > 0){
							$('BORROW_NAME_span').update(rtnList[0].BORROW_NAME || '');
						}
					}
				);	
			},
			
			// 變更
			doUpdate: function(){
				//[20180531]修改件
				//增加是否有查詢資料或無選取資料檢核
				var checkedRecs =  grid1.getCheckedRecords(['LOAN_ID']);
				if(!checkedRecs || checkedRecs.length == 0){
					alert('無查詢資料或被選取資料，無法變更!');
					return;
				}
				
				//[20180531]修改件
				//比較的欄位由LOAN_ID改成BORROW_ID
				var BORROW_ID = $F('BORROW_ID');
				var BORROW_ID_OLD = grid1.getCheckedRecords()[0].BORROW_ID;		
				if(BORROW_ID != BORROW_ID_OLD){
					alert("欲變更的借款人ID:"+BORROW_ID+"與原先查詢的借款人ID:"+BORROW_ID_OLD+"不同，無法作業!!");
					return;
				}
				
				valid2.reset();
				// 檢核
				if(!valid2.validate()){ 
					return; 
				}

				//[20180531]修改件
				//呼叫doChange多傳一個參數，grid勾選清單
				// 頁面傳入參數
				ajaxPost( 'update' , { 'info' : Object.toJSON(reqMap()), 'dataList': Object.toJSON(checkedRecs) },
					function(resp){						
						var rtnList = resp.rtnList;
						grid1.load(rtnList || []);
						if(rtnList && rtnList.length > 0){
							$('BORROW_NAME_span').update(rtnList[0].BORROW_NAME || '');
						}
						actions.clearEditArea();				
					}
				);	
			},
			//組grid區塊中聯絡電話資料
			genTELInfo: function(record, type){
				var Prefix = ['(一):', '(二):', '(三):'];
				var TEL_INFO = '';
				for(var i=0; i<Prefix.length; i++){
					var index = (i==0) ? '' : i+1;
					var val = record[type+'_TEL_NUM'+index] || '';
					TEL_INFO = TEL_INFO + Prefix[i];
					if(val != ''){
						var areaVal = record[type+'_TEL_AREA'+index];
						if(areaVal != ''){
							TEL_INFO = TEL_INFO +'('+record[type+'_TEL_AREA'+index]+')';
						}
						TEL_INFO = TEL_INFO + val;
						var ext = record[type+'_TEL_EXT'+index] || '';
						if(ext != ''){
							TEL_INFO = TEL_INFO+'#'+ext;
						}
					}
					if(i != Prefix.length){
						TEL_INFO = TEL_INFO + '<BR>';
					}
				}
				return TEL_INFO;
			},
			//清除[聯絡電話變更]區塊的資料 
			clearEditArea: function(){
				$('editArea').select('input', 'select').each(function(elem){
					$(elem.id).setValue('');
				});
			},
			//選取grid資料，連動[聯絡電話變更]區塊的資料
			chgNewTelInfo: function(){
				actions.clearEditArea();
				var checkedRecs =  grid1.getCheckedRecords();
				if(!checkedRecs || checkedRecs.length == 0){
					return;
				}
				var TelInfo = checkedRecs[0];
				$('editArea').select('input', 'select').each(function(elem){
					$(elem.id).setValue(TelInfo[elem.id] || '');
				});
				$('E_POLNO').update(TelInfo['E_POLNO'] || '');
				
				<%-- [20230321] 難字調整 --%>
				parseEUDC("ap");
			}
		};
		
		//產生查詢回傳資料
		var reqMap = function(){
		
			var reqMap = {};
			
			$('editArea').select('input', 'select').each(function(elem){
				reqMap[elem.id] = $F(elem.id);
			});
			reqMap['BORROW_ID'] = $F('BORROW_ID');
			
			return reqMap;
			
		};

		return {
			
			initApp : function() {
	
				PageUI.createPageWithAllBodySubElement('DSC81400', '變更作業', '聯絡電話變更');	
				
				grid1 = new TableUI({
					table: $('grid1'),
					autoCheckBox:{
						isSelectAll:function(){
							actions.chgNewTelInfo();
						},
						action: function( node, boxStatus, records){
							actions.chgNewTelInfo();
						} 
					},
					allSortable:true, 
					overDiv:false,
					pageSize:0,
					column: [
						{header: '貸款帳號' , key : 'LOAN_ID'},
						{header: '原貸帳號' , key : 'REFER_ID'},
						{header: '聯絡電話（日）' , key : 'DAY_TEL_AREA',attrs:{align:"left"},
							render: function(rec, val, sn){
								return actions.genTELInfo(rec, 'DAY');
							}
						},
						{header: '聯絡電話（夜）' , key : 'NIGHT_TEL_AREA',attrs:{align:"left"},
							render: function(rec, val, sn){
								return actions.genTELInfo(rec, 'NIGHT');
							}
						},
						{header: '行動電話' , key : 'MOBILE'},
						{header: '電子信箱' , key : 'EMAIL',
							render: function(rec, val, sn){
								if(rec.E_POLNO == ''){
									return val;
								}
								var span = new Element('span').update(val);
								var span2 = new Element('span', {style:'color:red;'}).update(rec.E_POLNO);
								return span.insert('<BR>').insert(span2);;
							}
						},
						<%-- [20230321] 難字調整 --%>
						{header: '備註' , key : 'UPDATE_MEMO', attrs : {style:"font-family:'EUDC'"}}
					]
				});		
					
				initValidation();	
					
				// 查詢
				$('BTN_query').observe('click', actions.doQuery);
					
				// 變更
				$('BTN_update').observe('click', actions.doUpdate);
				
				$('BORROW_ID').observe('blur', function(){
					$('BORROW_ID').setValue($F('BORROW_ID').toUpperCase());
				});
				
				autoFormatToNumber();
				
				buttonAuth();
				var BORROW_ID = '${BORROW_ID}';
				if(BORROW_ID != ''){
					$('BORROW_ID').setValue(BORROW_ID);
					$('BORROW_ID').simulate('blur');	
					actions.doQuery();
				}
	
				PageUI.resize();
				displayMessage();
		
			} // end initApp()		
		}; // end return
	}

</script>
</head>
<body>

<form id="form1" name="form1"  style="PADDING: 0px; MARGIN: 0px;">
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width='15%' align="center">借款人ID</td>
		<td class="tbYellow2" width="65%">
			<input id="BORROW_ID" name="BORROW_ID" type="text" class="textBox2" size="14" maxlength="10"/>
		</td>
		<td class="tbYellow2" width="20%">
			<input id="BTN_query" type="button" value="查詢" class="button"> 
			<input id="BTN_update" type="button" value="變更" class="button"> 
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center"  colspan='2'>原聯絡電話</td>
	</tr>
	
	<tr>
		<td class="tbYellow" width='15%' align="center">姓名</td>
		<%-- [20230321] 難字調整 --%>
		<td class="tbYellow2" width="85%"><span id="BORROW_NAME_span" style="font-family:'EUDC'"></span></td>
	</tr>
	<tr>
	
		<td class="tbYellow" colspan="2">
			<table id="grid1" width="100%" class="grid"></table>
		</td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbBox3" align="center">
			聯絡電話變更
		</td>
	</tr>
</table>

<table width="100%" id="editArea" name="editArea" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%" align="center" rowspan='3'>
			連絡電話
		</td>
		<td class="tbYellow2" width="85%">
			(日一)
			<select id="DAY_TEL_AREA" name="DAY_TEL_AREA" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="DAY_TEL_NUM" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="DAY_TEL_EXT" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
			(夜一)
			<select id="NIGHT_TEL_AREA" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="NIGHT_TEL_NUM" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="NIGHT_TEL_EXT" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="85%">
			(日二)
			<select id="DAY_TEL_AREA2" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="DAY_TEL_NUM2" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="DAY_TEL_EXT2" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
			(夜二)
			<select id="NIGHT_TEL_AREA2" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="NIGHT_TEL_NUM2" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="NIGHT_TEL_EXT2" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow2" width="85%">
			(日三)
			<select id="DAY_TEL_AREA3" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="DAY_TEL_NUM3" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="DAY_TEL_EXT3" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
			(夜三)
			<select id="NIGHT_TEL_AREA3" >
				<option value="">
					區碼
				</option>					
				<c:forEach items="${TEL_AREA_List}" var="row">
					<option value="${row.key}" />
						${row.value}
					</option>	
				</c:forEach>				
			</select>
			<input id="NIGHT_TEL_NUM3" type="text" datatype="number" pattern="######" size='17' maxlength='15'/>#
			<input id="NIGHT_TEL_EXT3" type="text" datatype="number" pattern="######" size='8' maxlength='6'/>
		</td>

	</tr>		
	<tr>
		<td class="tbYellow" width="15%" align="center">
			行動電話
		</td>
		<td class="tbYellow2" width="85%">
			<input id="MOBILE" type="text" datatype="number" pattern="######" size="17" maxLength ="15"/>
		</td>
	</tr>
		<tr>
		<td class="tbYellow" width="15%" align="center">
			電子信箱
		</td>
		<td class="tbYellow2" width="85%">
			<input id="EMAIL" type="text" size="42" maxLength ="40"/>
			<font color="red"><span id ="E_POLNO"></span></font>
		</td>
	</tr>
		<tr>
		<td class="tbYellow" width="15%" align="center">
			備註
		</td>
		<td class="tbYellow2" width="85%">
			<%-- [20230321] 難字調整 --%>
			<input id="UPDATE_MEMO" type="text" size="52" maxLength ="50" alt="ch" />
		</td>
	</tr>
</table>

</form>		
</body>
</html>