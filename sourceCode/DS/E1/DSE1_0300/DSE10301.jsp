<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>

<!--
程式：DSE10301.jsp
作者：黃子玹 
功能：債信索引作業明細
完成：2013/4/2

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>  
<%-- [20240207] 難字調整 --%>
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

// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE10301().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

//以下為UI() public method,放在 return 中
function DSE10301(){

	var grid;
	var REFER_ID;
	var CREDIT_MAP_SELECT; 
		
		
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese( [
			[ 'valid_credit', '',
				function( value , elem ) {
				
					var CREDIT_MAP = $F("CREDIT_MAP");
					var CREDIT_ID = $F("CREDIT_ID");
					var CREDIT_NAME = $F("CREDIT_NAME");
				
					var isSelect = !!CREDIT_MAP; //有值
					var isInput = !!CREDIT_ID || !!CREDIT_NAME;//其中一個有值
					//!(!isSelect && !isInput) 兩組都有值(債務人欄位，下拉選單與文字輸入二擇一輸入)
					//!(isSelect && isInput)   兩組都沒值(請輸入債權人資訊)
					//!isSelect沒值 //沒選下拉選單
					if ( !(!isSelect && !isInput) && !(isSelect && isInput) && !isSelect ){
						if(!CREDIT_ID && elem.id == 'CREDIT_ID'){ return false; }
						if(!CREDIT_NAME && elem.id == 'CREDIT_NAME'){ return false; }							
					}else if(!(!isSelect && !isInput) && !(isSelect && isInput) && isSelect){
						if(!CREDIT_MAP && elem.id == 'CREDIT_MAP'){ return false; }					
					}					
					return true;
				}
			]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode:'validator'});			
		valid1.define('required' , [{ id : "CREDITOR_NAME" ,errMsg : '債權人 為必輸欄位!' }] );
		valid1.define('required' , [{ id : "COURT" ,errMsg : '法院 為必輸欄位!' }] );
		valid1.define('required' , [{ id : "CREDIT_REASON" ,errMsg : '原因代碼 為必輸欄位!' }] );
		valid1.define('required' , [{ id : "OCCUR_DATE" ,errMsg : '原因發生日 為必輸欄位!' }] );
		valid1.define('required' , [{ id : "DATA_SOURCE" ,errMsg : '資料來源 為必輸欄位!' }] );
		valid1.define('required' , [{ id : "CASE_NO" ,errMsg : '案號 為必輸欄位!' }] );		
			
		valid1.define('valid_credit' , [{ id : "CREDIT_MAP" ,errMsg : '請選擇債務人姓名' }] );
		valid1.define('valid_credit' , [{ id : "CREDIT_ID" ,errMsg : '請輸入債務人ID' }] );
		valid1.define('valid_credit' , [{ id : "CREDIT_NAME" ,errMsg : '請輸入債務人姓名!' }] );
	}
		
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_0301/" + actionName,
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
	
		//單選RADIO，選取後資料顯示於債信索引記錄輸入區塊
		getDetailList : function(record){		
			$('CREDITOR_NAME').value = record.CREDITOR_NAME || '' ;//債權人設值			
			$('COURT').value = record.COURT || '';//法院設值
			$('CREDIT_REASON').value = record.CREDIT_REASON || '' ;//原因代碼
			$('CREDIT_REASON_hidden').value = record.CREDIT_REASON || '' //原因代碼隱藏欄位設值
			$('OCCUR_DATE').value = Date.toInputROC(record.OCCUR_DATE || '' );//原因發生日
			$('DATA_SOURCE').value = record.DATA_SOURCE || '';//資料來源
			$('CASE_NO').value = record.CASE_NO || '' ;//案號					
			$('CREDIT_ID').value = record.CREDIT_ID || '' ;//債務人姓名
			$('CREDIT_NAME').value = record.CREDIT_NAME || '' ;//債務人姓名	
			$('CREDIT_ID').disable();//點選後disable	
			$('SEQ_NO').value = record.SEQ_NO || '' ;//序號			
		},		
		
		//初始查詢
		doQuery : function(event) {
			REFER_ID = $('REFER_ID').innerHTML;
			ajaxPost( 'query',	{REFER_ID : REFER_ID},
				function(resp){			
					var rtnList = resp.rtnList;					
					grid.load(rtnList);						
				},function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}					
			);		
		},
		//新增、修改共用
		doAction : function(action){			
		
			var reqMap ={};		
			if(action == 'update'){
				//必須點選一筆資料
				var chkData = grid.getCheckedRecord();	
				if(chkData.length == 0){		
					alert("請選取一筆資料");
					return;
				}	
				reqMap['SEQ_NO'] = $F('SEQ_NO');				
			}						
			
			var CREDIT_MAP_SELECT = $('CREDIT_MAP').selectedIndex;
			
			if(CREDIT_MAP_SELECT == 0 && $F('CREDIT_ID') == '' && $F('CREDIT_NAME')== ''){
				alert('請使用下拉選單或文字輸入債務人資訊!');
				return;	
			}				
			//債務人欄位，下拉選單與文字輸入二擇一輸入
			if( CREDIT_MAP_SELECT!= 0 && ($F('CREDIT_ID')!= '' || $F('CREDIT_NAME')!= '' )){
				alert('下拉選單與文字輸入請選擇一種方式輸入即可!');
				return;	
			}			
						
			valid1.reset();            			
			if(!valid1.validate()){				
				return; 
			}	
			if(action == 'update'){				
				//原因代碼，不可修改，否則顯示錯誤訊息:“索引原因不得變更!”				
				var CREDIT_REASON_CHECK;
				$$('#CREDIT_REASON option:selected').each(function(ele){
					CREDIT_REASON_CHECK = ele.value;					
				});		
							
				if($F('CREDIT_REASON_hidden') != CREDIT_REASON_CHECK){
					alert('索引原因不得變更!');
					return;	
				}
			}	
			reqMap['REFER_ID'] = REFER_ID//設定原貸帳號至reqMap			
						
			$$('#table_A input[type=text]','select').each(function(ele){
				reqMap[ele.id] = $(ele).getValue();				
			})
			
			if($('CREDIT_MAP').selectedIndex != 0){
				
				$$('#CREDIT_MAP option:selected').each(function(ele){
					reqMap['CREDIT_ID'] = ele.value;
					reqMap['CREDIT_NAME'] = ele.innerHTML;
				});		
			}			
			
			ajaxPost( action,	{reqMap : Object.toJSON(reqMap), REFER_ID : REFER_ID},
					function(resp){						
						var rtnList = resp.rtnList;			
						grid.load(rtnList);
						actions.doClear();	
					},function(resp){
						//失敗把前次內容清掉 
						grid.load([]);			
					}					
			);				
		},
		//刪除
		doDelete : function(event){
			
			//必須點選一筆資料
				var chkData = grid.getCheckedRecord();	
				if(chkData.length == 0){		
					alert("請選取一筆資料");
					return;
			}	
			var reqMap ={};				
			reqMap['REFER_ID'] = REFER_ID//設定原貸帳號	
			reqMap['SEQ_NO'] = $F('SEQ_NO');//設定畫面上序號
			reqMap['CREDIT_ID'] = $F('CREDIT_ID'); //設定畫面上債務人ID
			
			ajaxPost( 'delete',	{reqMap : Object.toJSON(reqMap), REFER_ID : REFER_ID},
					function(resp){			
						var rtnList = resp.rtnList;				
						grid.load(rtnList);
						actions.doClear();		
					},function(resp){
						//失敗把前次內容清掉 
						grid.load([]);			
					}					
			);				
		},
		
		//清除
		doClear : function(event){
			form1.reset();//債信索引記錄清單區塊	
			$('CREDIT_ID').enable();
		}
		
	};

	return{
	
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement( "DSE10301" , "法務作業" , "債信索引作業明細");
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: true,
								  autoCheckBox:{text:'選取',
								  type:'radio',
								  action: function(elem, status, data){
										var record = data[0];
										//回傳選取詳細清單
										actions.getDetailList(record);	
										}				   
								},
				<%-- [20240207] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [					
					{header:"序號", key:'SEQ_NO'},
					<%-- [20240207] 難字調整：債權人 --%>
					{header:"債權人", key:'CREDITOR_NAME', attrs:{ style:"font-family:'EUDC'" }},		
					{header:"法院", key:'COURT',
						render : function (record , value){
							return record.COURT_NM || '' ;			
						}					
					},
					{header:"原因代碼", key:'CREDIT_REASON',
						render : function (record , value){
							return record.CREDIT_REASON_NM || '' ;			
						}			
					},					
					{header:"原因發生日",key:'OCCUR_DATE',
							render : function (rec , val){
							return Date.toInputROC(val || '');									
							}				
					},
					{header:"索引狀態", key:'IS_VALID',
						render : function (record , value){
							return record.IS_VALID_NM || '' ;			
						}					
					},
					{header:"失效日期", key:'DELT_DATE',
							render : function (rec , val){
							return Date.toInputROC(val || '' );									
							}			
					},		
					{header:"資料來源", key:'DATA_SOURCE',
						render : function (record , value){
							return record.DATA_SOURCE_NM || '' ;			
						}		
					},
					{header:"案號", key:'CASE_NO'},
					<%-- [20240207] 難字調整：輸入人員 --%>
					{header:"輸入人員", key:'INPUT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header:"輸入日期", key:'INPUT_DATE',
							render : function (rec , val){
							return Date.toInputROC(val || '' );									
							}			
					},	
					<%-- [20240207] TODO 難字調整：債務人 --%>
					{header:"債務人", key:'CREDIT_ID', attrs:{ style:"font-family:'EUDC'" },
							render:function(record , value){
								return record.CREDIT_NAME || '' ;								
							}				
					}		
				]	
			});
				
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------			
			initValidation(); 
			
			actions.doQuery();//初始查詢
								
			$("btn_insert").observe('click',
				function(event){
					actions.doAction('insert');//新增
				}
			);
			$("btn_update").observe('click',
				function(event){
					actions.doAction('update');//修改	
				}
			);
			$("btn_delete").observe('click', actions.doDelete);	//刪除
			$("btn_clear").observe('click', actions.doClear);	//清空
			
					
			//Input欄位自動轉大寫
			$('CREDIT_ID').observe('blur',function(){
				$('CREDIT_ID').value = $F('CREDIT_ID').toUpperCase();
			});	
					
			PageUI.resize();
			displayMessage();
			
		}//end init()--
	};//end return--	
}//end DSE10301
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="0" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "10%" align="left">原貸帳號</td>
				<td class="tbYellow2" width ="10%" colspan="6"><span id="REFER_ID">${REFER_ID}</span></td>				
			</tr>		
			<tr>
				<td  width="100%" colspan="7" align="center">
					<input id="btn_insert" type="button" class="button" value='新增' />
					<input id="btn_update" type="button" class="button" value='修改' />				
					<input id="btn_delete" type="button" class="button" value='刪除' />					
					<input id="btn_clear" type="button" class="button" value='清除' />
				</td>
			</tr>					
			<tr>
				<td class="tbBlue" width= "10%" align="center">債權人</td>
				<td class="tbBlue" width="10%" align="center">法院</td>
				<td class="tbBlue" width="10%" align="center">原因代碼</td>
				<td class="tbBlue" width= "10%" align="center">原因發生日	</td>
				<td class="tbBlue" width="10%" align="center">資料來源</td>
				<td class="tbBlue" width= "10%" align="center">案號</td>	
				<td class="tbBlue" width="10%" align="center">債務人</td>				
			</tr>	
			<tr>			
				<td class="tbYellow2" width = "10%" align="center">
					<%-- [20240207] 難字調整：債權人 --%>
					<input id="CREDITOR_NAME" type="text" class="textBox2"  size="12" maxlength="10" alt="ch" />				
				</td>
				
				<td class="tbYellow2" width = "20%">
					<select id="COURT" class="textBox2" align="center">
						<option value="">請選擇</option>
						<c:forEach items="${COURT_MAP}" var="map">							
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				
				<td class="tbYellow2" width = "18%">
					<select id="CREDIT_REASON" class="textBox2" align="center">
						<option value="">請選擇</option>
						<c:forEach items="${CREDIT_REASON_MAP}" var="map">							
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>				
				
				<td class="tbYellow2" width = "10%" rowspan='2' align="center">
						<input id="OCCUR_DATE" type="text" class="textBox2"  size="10" maxlength="7" /><br>
						例:	920101
				</td>				
				<td class="tbYellow2" width = "2%">
					<select id="DATA_SOURCE" class="textBox2" align="center">
						<option value="">請選擇</option>
						<c:forEach items="${DATA_SOURCE_MAP}" var="map">							
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>		
				<td class="tbYellow2" width = "15%" align="center">
						<input id="CASE_NO" type="text" class="textBox2"  size="22"/>				
				</td>
			
				<td class="tbYellow2" width = "10%" align="center">
					<%-- [20240207] 難字調整：債務人 --%>
					<select id="CREDIT_MAP" class="textBox2" align="center" alt="ch">
						<option value="">請選擇</option>
						<c:forEach items="${CREDIT_MAP}" var="map">							
							<option value='${map.CREDIT_ID}'>${map.CREDIT_NAME}</option>
						</c:forEach>
					</select><br>
					ID:<input id="CREDIT_ID" type="text" class="textBox2"  size="12" maxlength="10" /><br>
					<%-- [20240207] 難字調整：姓名 --%>
					姓名:<input id="CREDIT_NAME" type="text" class="textBox2"  size="8" maxlength="6" alt="ch" />		
				</td>
					<input id="SEQ_NO" type="hidden" class="textBox2"  size="12" maxlength="10" />
					<input id="CREDIT_REASON_hidden" type="hidden" class="textBox2"  size="12" maxlength="10" />				
				
			</tr>			
		</table>
	</form>
		<table id="grid" width="100%" class="grid" ></table>
</body>
</html>		