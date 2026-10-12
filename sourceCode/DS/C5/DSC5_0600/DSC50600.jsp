<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix='dz' tagdir='/WEB-INF/tags/csr/dz'%>

<!--
程DSC50600.jsp
功能：違約金控管 
作者：溫子?
完成：2013/08/
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
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
<script type='text/javascript'>
Event.observe(window, 'load', new DSC50600().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC50600(){
var grid;
var tempMap={};
var recordCount;
	function initValidation(){
		//查詢用檢核
			valid1 = new Validation("table1", { focusOnError:true, immediate:false , mode : 'validator'})	
			valid1.define( "required" , { id: "QUERY_LOAN_ID" , errMsg:"貸款帳號不可空白!!" } );
			valid1.define( "validateLOAN_ID_10" , { id: "QUERY_LOAN_ID"});
			valid1.define( "validateLOAN_ID_X" , { id: "QUERY_LOAN_ID"});
			//valid1.define('validate-digits' , [{ id : "QUERY_BEGIN_TIMES" , errMsg:"生效期數請輸入有效整數!!"}] );
		Validation.addAllThese([
			[ 'validateLOAN_ID_10',  '貸款帳號長度須為10碼!',
				function(v){				
					return (v.length != 10) ? false : true ;
				}
			],
			[ 'validateLOAN_ID_X',  '理財型不可做違約金控管!',
				function(v){
					if(v.length ==10){
						return (v.substring(9,10) =='X') ? false : true ;
					}else{
						return true;
					}
				}
			],		
			[ 'END_TIMES_Required',  '請輸入終止期數!',
				function( v , elem ) {
					return !Validation.get('IsEmpty').test(v);
				},
			],
			[ 'BEGIN_TIMES_Required',  '請輸入生效期數!',
				function( v , elem ) {
					return !Validation.get('IsEmpty').test(v);
				},
			],
			[ 'RENEGE_RATE_Required',  '請輸入違約金利率!',
				function( v , elem ) {
					return !Validation.get('IsEmpty').test(v);
				},
			],
			[ 'RENEGE_AMT_Required',  '請輸入提前清償控管金額!',
				function( v , elem ) {
					return !Validation.get('IsEmpty').test(v);
				},
			],
			[ 'ADJUST_REASON_Required',  '請輸入加減碼原因!',
				function( v , elem ) {
					return !Validation.get('IsEmpty').test(v);
				},
			],
			[ 'BEGIIN_END_TIMES_COMPARE',  '生效期數必須小於等於終止期數!',
				function( v , elem ) {
					
					var end ;
					if(grid.isNew){
						end=grid.getAutoInput(elem,['END_TIMES'])[0]['END_TIMES'];
					}else{
						end=elem.up('tr').select("input")[2];	
					}
					
					if(end){
						if(CSRUtil.getNumber(v)>end.value){						
							return false;
						}else{						
							return true;
						}
					}else{
						return true;
					}
				},
			],
			[ 'RENEGE_RATE_CHECK',  '請輸入正確違約金比率!',
				function( v , elem ) {
					return checkRENEGE_RATE(v);
				},
			],
			[ 'RENEGE_AMT_CHECK',  '控管違約金金額需為正值!',
				function( v , elem ) {
					if(!v||v<0){
						return false;
					}
					return  Validation.get('IsEmpty').test(v) || /^\d+$/.test(v.replace(/,/g,''));
				},
			]
		]);
			
			valid2 = new Validation("grid", { focusOnError:true, immediate:false , mode : 'validator'})	
}
	var checkRENEGE_RATE=function (val){
		if(val&&!isNaN(val)){
			if(val>=0&&val<100){
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}	
	// 按鈕權限
		var buttonAuth = function(){
			var authButtons = {
				B0003 : 'BTN_INSERT',
				B0005 : 'BTN_DELETE',
				B0028 : 'BTN_CONFIRM'
			};
			<dz:grantButtons FUNC_ID='DSC50600'/>
		};
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC5_0600/" + actionName,
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
function initGRID(rtnList){
		var temp=rtnList[0];
		/*
		var tmpMap = Object.clone(temp);
		tmpMap.BEGIN_TIMES='';
		tmpMap.END_TIMES='';
		tmpMap.RENEGE_RATE='';
		tmpMap.RENEGE_AMT='';
		tmpMap.ADJUST_REASON='';
		tmpMap.ADJUST_MEMO='';
		tmpMap.CONTROL_REFER_ID='';
		tmpMap.REGISTER_NO='';
		tmpMap.AREA_NAME='${AREA_NAME}';
		tmpMap.INPUT_NAME='${INPUT_NAME}';
		tmpMap.INPUT_DEPT_NAME='${INPUT_DEPT_NAME}';
		tmpMap.INPUT_DATE='${INPUT_DATE}';
		tmpMap.AREA_CODE='${AREA_CODE}';
		tmpMap.INPUT_ID='${INPUT_ID}';
		tmpMap.INPUT_DEPT='${INPUT_DEPT}';
		rtnList.push(tmpMap);*/
		grid.load(rtnList);
}
var buttons = {

	doQuery : function(){
		valid1.reset();
		if(!valid1.validate()){				
			return; 
		}	
		$('HID_BEGIN_TIMES').value = $F('QUERY_BEGIN_TIMES');
		ajaxPost( 'query', {QUERY_LOAN_ID : $F('QUERY_LOAN_ID') ,QUERY_BEGIN_TIMES:$F('QUERY_BEGIN_TIMES')}
				,function(resp){					
					var rtnMap=resp.C100Map;
					$$('.dataMap').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					})
					if(resp.rtnList){
						initGRID(resp.rtnList);
					}else{
						grid.load([]);	
					}
					//grid.load(resp.rtnList);
				},function(resp){
					
					buttons.doClear();
				}
			);
	}
	,doInsert : function(){
		
		if(!valid2.validate()){				
			return; 
		}
		
		var datas=grid.getAllRecords();		
		
		datas.each(function(data){
			data.isOpen = false;
		});
		
		var temp=datas[0];
		var tmpMap = Object.clone(temp);
		tmpMap.BEGIN_TIMES='';
		tmpMap.END_TIMES='';
		tmpMap.RENEGE_RATE='';
		tmpMap.RENEGE_AMT='';
		tmpMap.ADJUST_REASON='1';	
		tmpMap.ADJUST_MEMO='防止流失';
		tmpMap.CONTROL_REFER_ID='';
		tmpMap.REGISTER_NO='';
		tmpMap.AREA_NAME='${AREA_NAME}';
		tmpMap.INPUT_NAME='${INPUT_NAME}';
		tmpMap.INPUT_DEPT_NAME='${INPUT_DEPT_NAME}';
		tmpMap.INPUT_DATE='${INPUT_DATE}';
		tmpMap.AREA_CODE='${AREA_CODE}';
		tmpMap.INPUT_ID='${INPUT_ID}';
		tmpMap.INPUT_DEPT='${INPUT_DEPT}';
		tmpMap.LOAN_ID=$F('QUERY_LOAN_ID');	
		tmpMap.isNew = true;
		if(datas.length!=0){
			recordCount = datas[datas.length-1]['SEQ_NO'];
		}else{
			recordCount = 0;
		}
		recordCount++;
		tmpMap.SEQ_NO = recordCount;
		datas.push(tmpMap);
		var keys = [];
		keys.push(recordCount);
		recordCount++;
		grid.load(datas,null,null,keys);
		
	}
	,doConfirm :function(){
		if($F('QUERY_LOAN_ID')!=$('LOAN_ID').innerHTML){
			alert("貸款帳號與查詢時不同，請重新查詢!");
			return;
		}
		if($F('QUERY_BEGIN_TIMES')!=$('HID_BEGIN_TIMES').value){
			alert("生效期數與查詢時不同，請重新查詢!");
			return;
		}
		
		if(!valid2.validate()){				
			return; 
		}
		ajaxPost( 'confirm', {dataList : Object.toJSON(grid.getAllRecords()),QUERY_LOAN_ID : $F('QUERY_LOAN_ID') ,QUERY_BEGIN_TIMES:$F('QUERY_BEGIN_TIMES')}
				,function(resp){
					var rtnMap=resp.C100Map;
					$$('.dataMap').each(function(ele){
						var id = ele.id;
						ele.update(rtnMap[id] || '');
					})
					if(resp.rtnList){
						initGRID(resp.rtnList);
					}
					//grid.load(resp.rtnList);
				},function(resp){
					grid.load([]);	
				}
			);
		
	}
	,doDelete : function(){
		var grid_check=grid.getCheckedRecord();
		var grid_List=grid.getAllRecords();
		if( grid_check.length == 0  ){
			alert('請先選擇一筆要刪除的資料!');
			return;
		}
		if(!confirm("確定要刪除此筆資料?")){
			return;
		}
		
		var check=grid_check[0]		
		for ( var i = 0 ; i < grid_List.length ; i++){
			if(check.LOAN_ID == grid_List[i].LOAN_ID&&check.BEGIN_TIMES==grid_List[i].BEGIN_TIMES){					
				//checkIDList.splice( i,1);
				/*
				//如果只剩一筆,因為還要讓USER加回來					
				if( grid_List.length == 1){
					grid_List.splice( i,1);
					var temp=grid_List[0];
					var tmpMap = Object.clone(temp);
					tmpMap.BEGIN_TIMES='';
					tmpMap.END_TIMES='';
					tmpMap.RENEGE_RATE='';
					tmpMap.RENEGE_AMT='';
					tmpMap.ADJUST_REASON='';
					tmpMap.ADJUST_MEMO='';
					tmpMap.CONTROL_REFER_ID='';
					tmpMap.REGISTER_NO='';
					tmpMap.AREA_NAME='${AREA_NAME}';
					tmpMap.INPUT_NAME='${INPUT_NAME}';
					tmpMap.INPUT_DEPT_NAME='${INPUT_DEPT_NAME}';
					tmpMap.INPUT_DATE='${INPUT_DATE}';
					tmpMap.AREA_CODE='${AREA_CODE}';
					tmpMap.INPUT_ID='${INPUT_ID}';
					tmpMap.INPUT_DEPT='${INPUT_DEPT}';
					grid_List.push(tmpMap);
				}else{
					//如果不止一筆 , 就將資料從LIST中刪除
					grid_List.splice( i,1);
				}*/				
				grid_List.splice( i,1);//直接刪除此筆資料
				break;
			}				
		}
		grid.load(grid_List);
	}
	,doClear :function(){
		$$('.dataMap').each(function(ele){
			ele.update('');
		})
		grid.load([]);
		$('QUERY_LOAN_ID').value='';
		$('QUERY_BEGIN_TIMES').value='';
		$('HID_BEGIN_TIMES').value='';
	}
}
	return {
		initApp : function() {
			 <c:forEach var="map" items="${ADJUST_REASON_LIST}">
				var key="${map.key}";	
				tempMap[key]="${map.value}"
			</c:forEach>
			PageUI.createPageWithAllBodySubElement('DSC50600', '利率計算', '違約金控管');
			
			grid = new TableUI(
					{table: $("grid"), allSortable: false, pageSize: 20, overDiv:false,allSortable:true,
					autoCheckBox:{
						text:'選取',
						type:'radio',
						valueKey:"SEQ_NO",	
						isChangeAll :true,
						action: function(radio , boxStatus , records ){
							
							var node = $(radio).up('tr');
							var dataObj = grid.isNew ? grid.getDataObj(radio) : node.dataObj;
							if(!radio.checked){
								dataObj.isOpen = false;
								dataObj.isNew = false;
								grid.setValueToAutoInput( radio , 'ADJUST_REASON' , dataObj.ADJUST_REASON_NAME );
								grid.exchangeAutoInput( radio, ['BEGIN_TIMES','END_TIMES','RENEGE_RATE','RENEGE_AMT','ADJUST_REASON','ADJUST_MEMO','CONTROL_REFER_ID'] , true);//關
							}else{
								dataObj.isOpen = true;
								grid.setValueToAutoInput( radio , 'ADJUST_REASON' , dataObj.ADJUST_REASON_NAME );								
								grid.exchangeAutoInput( radio, ['BEGIN_TIMES','END_TIMES','RENEGE_RATE','RENEGE_AMT','ADJUST_REASON','ADJUST_MEMO','CONTROL_REFER_ID'] , false);//開
							}
							
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

						{header:"生效期數",key:"BEGIN_TIMES",							
							input:{type:'NUMBER',size:3 , maxlength:5,className :'BEGIIN_END_TIMES_COMPARE END_TIMES_Required',style:'text-align:right',sortable:true,attrs:{className:'BEGIIN_END_TIMES_COMPARE END_TIMES_Required'}
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
										//dataObj = dataObj[0];							 
										//dataObj.BEGIN_TIMES= dataObj.BEGIN_TIMES;					
								}				    
								,genRule:function(record , value){
									 return record.isNew ? record.isNew : false;
								}
							}
							
						},				
						{header:"終止期數",key:"END_TIMES",
							
							input:{type:'NUMBER',size:3 , maxlength:5,className :'BEGIN_TIMES_Required',attrs:{className:'BEGIN_TIMES_Required'}/*,style:'text-align:right'*/
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
										//dataObj = dataObj[0];							 
										//dataObj.END_TIMES= dataObj.END_TIMES;					
								}				    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}							
						},
						{header:"違約金利率",key:"RENEGE_RATE",attrs:{align:'right'},
								
							input:{type:'NUMBER',size:8 , maxlength:7,className :'RENEGE_RATE_Required RENEGE_RATE_CHECK',attrs:{className:'RENEGE_RATE_Required RENEGE_RATE_CHECK'}/*,style:'text-align:right'*/
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
										//dataObj = dataObj[0];							 
										//dataObj.RENEGE_RATE= dataObj.RENEGE_RATE;					
								}				    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}				
						},
						{header:"提前清償控管金額",key:"RENEGE_AMT",attrs:{align:'right'},
								
							input:{type:'NUMBER',size:11 , maxlength:10,className :'RENEGE_AMT_Required RENEGE_AMT_CHECK',attrs:{className:'RENEGE_AMT_Required RENEGE_AMT_CHECK'}/*,style:'text-align:right'*/
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
										if(!grid.isNew){
											dataObj = dataObj[0];							 
											dataObj.RENEGE_AMT= dataObj.RENEGE_AMT.replace(/,/g,'');
										}
								}				    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}
							,render:function(record,value){  // 非輸入模式時的處理
									return value || value === 0 ? CSRUtil.$fmt(value,'#,###') : '';
							}  								
						},
						{header:"加減碼原因",key:"ADJUST_REASON",
							input:{type:'select',className :'ADJUST_REASON_Required',attrs:{className:'ADJUST_REASON_Required'}
								,opts:tempMap
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
									if(isOnChange){
										var td = node.up('td');
										var ADJUST_REASON_NAME = node.options[node.selectedIndex].innerText.trim();
										if(grid.isNew){
										    if (node.value != orgData) {
												grid.setValueToAutoInput(node,'ADJUST_MEMO',ADJUST_REASON_NAME);	
											}											
										}else{
											if (node.value != orgData) {
												td.next().select('input[type=text]')[0].setValue(ADJUST_REASON_NAME);
												td.next().select('div')[0].innerText=ADJUST_REASON_NAME;
											}
										}
										dataObj = dataObj[0];							 
										//dataObj.ADJUST_REASON= dataObj.ADJUST_REASON;								
										dataObj.ADJUST_REASON_NAME= ADJUST_REASON_NAME;
										//if (node.value != orgData) {
											//dataObj.ADJUST_MEMO = ADJUST_REASON_NAME;
										//}
									}
								}										    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}
							,render:function(record,value){  // 非輸入模式時的處理
								return record.ADJUST_REASON_NAME ? record.ADJUST_REASON_NAME: '';
							} 							
						
						},
						{header:"加減碼原因備註",key:"ADJUST_MEMO",
						
							input:{type:'TEXT',size:25 , maxlength:200
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
									//dataObj = dataObj[0];							 
									//dataObj.ADJUST_MEMO= dataObj.ADJUST_MEMO;					
								}				    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}
						},
						{header:"共同控管帳號",key:"CONTROL_REFER_ID",
							input:{type:'TEXT',size:12 , maxlength:15
								,action:function(node, dataObj , textDiv, orgData, isOnChange){
										//dataObj = dataObj[0];							 
										//dataObj.ADJUST_MEMO= dataObj.ADJUST_MEMO;					
								}				    
								,genRule:function(record , value){
									return record.isNew ? record.isNew : false;
								}
							}	
						},
						{header:"案件編號",key:"REGISTER_NO"},
						{header:"展業區部",key:"AREA_CODE_NAME"},
						{header:"作業人員",key:"INPUT_NAME", 
							render: function(rec, val, sn){
								<%--[20241101] 難字調整 --%>
								var span = new Element('span',{style:"font-family:'EUDC'"}).update(val);
								return span;
							}
						},
						{header:"作業人員單位中文",key:"INPUT_DEPT_NAME"},
						{header:"作業日期",key:"INPUT_DATE",
							render: function (rec,val){
								return Date.toROC(val) || '';
							}
						}
					]
				});
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_CONFIRM').observe('click',buttons.doConfirm);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				$('BTN_CLEAR').observe('click',buttons.doClear);
			
				buttonAuth();	
				initValidation();
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
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id ='table1'>
	<tr>
		<td class="tbYellow"  width='10%'>貸款帳號</td>
			<td class="tbYellow2" width="10%">
				<input id="QUERY_LOAN_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" maxlength="10" size="12"/>
			</td>
		<td class="tbYellow"  width='10%'>生效期數</td>
			<td class="tbYellow2" width="10%">
				<input id="QUERY_BEGIN_TIMES" type="text" class="textBox2 "  size="5"/>
			</td>	
		<td class="tbYellow2" width='10%' >
			<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
		</td>
	</tr>
	<tr>
		<td width='30%' align='center' colspan='5'>
			<input id="BTN_CONFIRM" type="button" value="確認" class="button" >	
			<input id="BTN_CLEAR" type="button" value="清除" class="button" >
		</td>
	</tr>
	<tr>
		<td class="tbYellow"  width='10%'>貸款帳號</td>
			<td class="tbYellow2" width="4%" colspan='4'>
				<span id="LOAN_ID" class='dataMap'></span>
				<input id="HID_BEGIN_TIMES" type='hidden' class= 'textBox2'  size='12' maxlength='10'/>
			</td>
	</tr>
	<tr>
		<td class="tbYellow"  width='10%'>借款人</td>
			<td class="tbYellow2" width="4%">
				<span id="BORROW_ID" class='dataMap'></span
			</td>
		<td class="tbYellow"  width='10%'>借款人姓名</td>
			<td class="tbYellow2" width="4%" colspan='2'>
				<span id="BORROW_NAME" class='dataMap' style="font-family:'EUDC'"></span><%--[20241101]難字調整 --%>
			</td>	
	</tr>
	<tr>
		<td class="tbYellow"  width='10%'>優惠種類</td>
			<td class="tbYellow2" width="4%" >
				<span id="PREFER_TYPE_NAME" class='dataMap'></span>
			</td>
		<td class="tbYellow"  width='10%'>貸款種類</td>
			<td class="tbYellow2" width="4%" colspan='2'>
				<span id="LOAN_KIND_NAME" class='dataMap'></span.
			</td>	
	</tr>
	<tr>
		<td class="tbYellow"  width='10%'>地區代號</td>
			<td class="tbYellow2" width="4%">
				
				<span id="AREA_CODE_NAME" class='dataMap'></span>
			</td>
		<td class="tbYellow"  width='10%'>每月應繳日</td>
			<td class="tbYellow2" width="4%" colspan='2'>
				<span id="DUTY_DAY" class='dataMap'></span.
			</td>	
	</tr>
</table>
<table id = "grid" ></table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow2" width='30%' align='center' colspan='5'>
			<input id="BTN_INSERT" type="button" value="新增" class="button" >	
			<input id="BTN_DELETE" type="button" value="刪除" class="button" >
		</td>
	</tr>
</table>
</form>
</body>
</html>