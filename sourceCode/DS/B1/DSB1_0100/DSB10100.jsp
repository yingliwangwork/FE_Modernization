
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB10100.jsp
作者：張智翔
功能：員工對保資格查詢。
完成：2012/06/08
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript'>

// 產生畫面物件
var DSB10100 = new DSB10100();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB10100.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB10100(){

	var grid;
	
	//查詢的檢核
	var valid1;
	var valid2;
	//新增的檢核
	var valid3;	
	//刪除的檢核
	var valid4;		
	//修改的檢核
	var valid5;	
	var valid6;
	var valid7;
	//前次查詢條件
	var queryInputMap = {} ;
				
	var rtnMap ={};			
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert"<%--新增--%> ,
				B0004:"btn_update"<%--修改--%> ,
				B0005:"btn_delete"<%--刪除--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB10100" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([	
			[ 'IDLength',  '請輸入正確ID查詢!(需為10碼)', 
				function(v){
					if(v !== ''){
						var queryType = $$('#form input:checked[type = radio]')[0].value;
						if(queryType === '1'){
							return v.length == 10 ? true : false;									
						}
					}
					return true;
			}],
			[ 'NOLength',  '請輸入正確編號查詢!(需小於6碼且為數字)', 
				function(v){
					if(v !== ''){
						var queryType = $$('#form input:checked[type = radio]')[0].value;
						if(queryType === '2'){
							return v.length <= 6 && JsUtils.isNumeric(v) ? true : false;									
						}
					}
					return true;
			}],
			
			[ 'IDLength_insert',  '請輸入正確對保人ID!(需為10碼)', 
				function(v){
					if(v !==''){
						return v.length == 10 ? true : false;
					}	
				return true;		
			}],
			
			[ 'NOLength_insert',  '請輸入正確對保編號!(需小於6碼且為數字)', 
				function(v){
					if(v !==''){
						return v.length <= 6 && JsUtils.isNumeric(v) ? true : false;		
					}
				return true;
			}],
			
			[ 'diff_ID',  '對保人ID與原先查詢後的資料不同，無法作業!請重新輸入或重查', 
				function(v){
					
					return shareDiffCondMethod(v , '1' , rtnMap.GUARANTOR_ID);
				}
			],
			
			[ 'diff_NO',  '對保人編號與原先查詢後的資料不同，無法作業!', 
				function(v){
					return shareDiffCondMethod(v , '2' , rtnMap.GUARANTOR_NO);
				}
			]
			
		]);
		
		
		//查詢用檢核
		valid1 = new Validation("form", { focusOnError:true, immediate:false });	
		valid1.define( "required" , { id: "QUERY_COND" , errMsg : '請輸入對保人ID或對保人編號查詢!!'} );
		valid1.define( "IDLength" , { id: "QUERY_COND" } );		
		//查詢用檢核
		valid2 = new Validation("form", { focusOnError:true, immediate:false });	
		valid2.define( "NOLength" , { id: "QUERY_COND" } );		
		//新增用檢核
		valid3 = new Validation("form", { focusOnError:true, immediate:false });
		valid3.define( "required" , { id: "GUARANTOR_ID" } );	
		valid3.define( "IDLength_insert" , { id: "GUARANTOR_ID" } );	
		//valid3.define( "required" , { id: "GUARANTOR_NO" } );	
		//valid3.define( "NOLength_insert" , { id: "GUARANTOR_NO" } );	
		valid3.define( "validate-ROCDate" , { id: "END_DATE" } );			
		valid3.define( "validate-ROCDate" , { id: "BEGIN_DATE" } );		

		//刪除用檢核
		valid4 = new Validation("form", { focusOnError:true, immediate:false });		
		valid4.define( "required" , { id: "GUARANTOR_ID" } );			
		valid4.define( "diff_ID" , { id: "GUARANTOR_ID" } );	
		valid4.define( "required" , { id: "UPDATE_REASON" } );

		//修改用檢核
		valid5 = new Validation("form", { focusOnError:true, immediate:false });		
		valid5.define( "required" , { id: "GUARANTOR_ID" } );	
		//valid5.define( "required" , { id: "GUARANTOR_NO" } );
		valid5.define( "required" , { id: "UPDATE_REASON" } );
		
		valid5.define( "diff_ID" , { id: "GUARANTOR_ID" } );			
		valid5.define( "IDLength_insert" , { id: "GUARANTOR_ID" } );
		//valid5.define( "NOLength_insert" , { id: "GUARANTOR_NO" } );
		valid6 = new Validation("form", { focusOnError:true, immediate:false });	
		valid6.define( "required" , { id: "END_REASON" ,errMsg : '請輸入終止原因!!'} );
		valid7 = new Validation("form", { focusOnError:true, immediate:false });	
		valid7.define( "required" , { id: "END_DATE" ,errMsg : '請輸入資格終止日!!'} );
					
	}	
	
	function shareDiffCondMethod(v , type , compareValue){
		if(v !== ''){			
			return v == compareValue ? true : false;	
		}
		return true;		
	}
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB1_0100/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {
		//查詢資料
		doQuery : function(event){			
			
			valid3.reset();
			valid4.reset();
			valid5.reset();	
			valid6.reset();	
			valid7.reset();	
			if(!valid1.validate() || !valid2.validate()){ 
				return; 
			}					
			
			//將畫面查詢條件轉大寫
			$('QUERY_COND').value = $('QUERY_COND').value.toUpperCase();
			
			var sendRecord = makeRecord();
			//確定可查詢 將查詢條件代入 方便重查
			queryInputMap = sendRecord;
		
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){						
					actions.writeRecord(resp);	
					grid.load(resp.B024List);
				},
				function(resp){
					rtnMap = {}
					actions.doClear();
					grid.load([]);
				}
			);		
		},	
		
		//新增
		doInsert : function(event){		
			if(!queryInputMap.QUERY_KIND  || !queryInputMap.QUERY_COND ){
				alert('請先查詢再作新增！');
				return;
			}
			valid1.reset();
			valid2.reset();			
			valid4.reset();
			valid5.reset();	
			valid6.reset();
			valid7.reset();			
			if(!valid3.validate() ){ 
				return; 
			}	
			//畫面要新增的record
			var insertRecord = makeModifyRecord();			
			
			var requeryValue;
			var requeryType = $$('#form input:checked[type = radio]')[0].value ;
			if(requeryType == '1'){
				requeryValue = $('GUARANTOR_ID').value;
			}else{
				alert('新增時請以對保人ID為重查條件');
				return;
			}
			
			//將重查的條件map放入
			var requeryMap = {
				QUERY_COND : requeryValue,
				QUERY_KIND : requeryType
			}			
			
			//發送ajax
			ajaxPost( 'insert' , 
				{
					sendRecord : Object.toJSON(requeryMap),
					insertRecord : Object.toJSON(insertRecord)					
				},
				function(resp){	
					actions.writeRecord(resp);
					grid.load(resp.B024List);
					$('QUERY_COND').value = requeryMap.QUERY_COND;
				}
			);	
		},
		
		//刪除
		doDelete : function(event){
			if(!queryInputMap.QUERY_KIND  || !queryInputMap.QUERY_COND ){
				alert('請先查詢再作刪除！');
				return;
			}
			valid1.reset();
			valid2.reset();
			valid3.reset();		
			valid5.reset();	
			valid6.reset();		
			valid7.reset();					
			if(!valid4.validate()){ 
				return; 
			}		
			
			if(!confirm('是否確認刪除?')){
				return;
			}			
			
			//發送ajax
			ajaxPost( 'delete' ,
				{
					deleteRecord : Object.toJSON({GUARANTOR_ID : rtnMap.GUARANTOR_ID}),
					sendRecord : Object.toJSON(queryInputMap),
					UPDATE_REASON : $('UPDATE_REASON').value
				},
				function(resp){	
					//清除畫面
					actions.doClear();				
					actions.writeRecord(resp);	
					grid.load(resp.B024List);
				}
			);	
		},
		
		//修改
		doUpdate : function(event){
			if(!queryInputMap.QUERY_KIND  || !queryInputMap.QUERY_COND ){
				alert('請先查詢再作修改！');
				return;
			}
		
			valid1.reset();
			valid2.reset();
			valid3.reset();		
			valid4.reset();	
			valid6.reset();		
			valid7.reset();									
			if(!valid5.validate()){ 
				return; 
			}
			if(!valid3.validate() ){ 
				return; 
			}	
			
			//如果是第二種修改 ,就要把重查條件放入查詢條件map
			if(queryInputMap.QUERY_KIND === '2'){
				queryInputMap.QUERY_COND = $('GUARANTOR_NO_TXT').innerHTML;
			}
			
			//如果END_DATE為空,跑出其確認訊息 檢核中止原因必輸
			if($('END_DATE').value !== ''){
				if(!valid6.validate()){ 
					return; 
				}			
			}
			//若有輸入終止原因 ，則資格終止日必輸
			if($('END_REASON').value !== ''){
				if(!valid7.validate()){ 
					return; 
				}			
			}
			
			if($('END_DATE').value !== '' && !confirm('確定要終止對保資格?')){
				return;			
			}
			
			
			var updateRecord = makeModifyRecord();			
			
			//發送ajax
			ajaxPost( 'update' ,
				{
					sendRecord : Object.toJSON(queryInputMap),
					updateRecord : Object.toJSON(updateRecord)				
				},
				function(resp){	
					if(queryInputMap.QUERY_KIND === '2'){
						$('QUERY_COND').value = queryInputMap.QUERY_COND;
					}
					//清除畫面
					actions.doClear();					
					actions.writeRecord(resp);					
					grid.load(resp.B024List);
				}
			);	
		}
	}
	
	//將畫面資訊存成map
	function makeModifyRecord(){
		var viewRecord = CSRUtil.inputsToVo('form1');
		//自動轉大寫
		var Upper_ID = $('GUARANTOR_ID').value.toUpperCase();
		viewRecord.GUARANTOR_ID = Upper_ID
		$('GUARANTOR_ID').value = Upper_ID;
		//將END_DATE BEGIN_DATE 轉成西元
		var END_DATE = $('END_DATE').value;
		if(END_DATE !== ''){
			viewRecord.END_DATE = toY2K(END_DATE);
		}
		var BEGIN_DATE = $('BEGIN_DATE').value;
		if(BEGIN_DATE !== ''){
			viewRecord.BEGIN_DATE = toY2K(BEGIN_DATE);
		}
		viewRecord.UPDATE_REASON = $('UPDATE_REASON').value;
		viewRecord.GUARANTOR_NO = $('GUARANTOR_NO_TXT').innerHTML;
		return viewRecord;
	}
	
	//將畫面資料存成record
	function makeRecord(){
		var tempRecord = {
			QUERY_KIND : $$('#form input:checked[type = radio]')[0].value,
			QUERY_COND : $('QUERY_COND').value
		};		
		return tempRecord;
	}	
	
	var actions = {
		//將資料寫入畫面上
		writeRecord : function(resp){				 
			var record = resp.rtnMap;			
			//先清乾欄位,也許原本沒那個欄位
			actions.doClear();
			if(record){
				rtnMap = record;				
				//將record寫入顯示區			
				CSRUtil.voToInputs('form1' , record);
				//客制化日期成 民國 YY/MM/DD
				$('GUARANTOR_NO_TXT').innerHTML = record.GUARANTOR_NO || "";
				$('BEGIN_DATE').value = toROC(record.BEGIN_DATE || "");	
				$('END_DATE').value = toROC(record.END_DATE || "");	
				$('INPUT_DATE_TXT').innerHTML = Date.toInputROC(record.INPUT_DATE || "","/");	
			}else{
				rtnMap ={};
			}
		},
		
		//清除畫面 回到初始狀況
		doClear : function(){					
			//清空C區
			$('form1').reset();				
			$$('#form1 span').each(
				function(elem){
					elem.innerHTML = '';
				}
			);
		}	
	};
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSB10100", "匯款維護", "員工對保資格查詢");

		
				grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true,				
					column:[
						{header: "對保人編號",key: "GUARANTOR_NO"},	
						{header: "對保人ID",key: "GUARANTOR_ID"},		
						{header: "資格取得日",key: "BEGIN_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}						
						},		
						{header: "資格終止日",key: "END_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}
						},	
						{header: "建檔日期",key: "INPUT_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}
						},		
						{header: "終止原因",key: "END_REASON"},		
						{header: "異動日期",key: "CHG_DATE", 
							render : function(rec ,val ){							
								return Date.toInputROC(val || '' , '/');	
							
							}										
						},
						{header: "異動種類",key: "CHG_KIND",
							render : function(rec ,val){
								return rec.CHG_KIND === 'D' ? '刪除' : rec.CHG_KIND === 'U' ? '修改' : '' ;
							}						
						},	
						{header: "異動原因",key: "UPDATE_REASON"},	
						<%-- [20240607] 難字調整 --%>
						{header: "異動人員",key: "CHG_NAME", attrs:{ style:"font-family:'EUDC'" }}						
												
					]
					
				});
		
				//註冊DOM物件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_insert").observe("click", buttons.doInsert );					
				$("btn_delete").observe("click", buttons.doDelete );
				$("btn_update").observe("click", buttons.doUpdate );
				
				//終止原因選單
				$("END_REASON_VIEW").observe('change',
					function(event){ 
						$("END_REASON").value = $('END_REASON_VIEW').options[$('END_REASON_VIEW').selectedIndex].text;
					}
				);
							
				initValidation();	
				
				fix();
				
				displayMessage();					
				
				buttonAuth();
								
			}
	};	
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="35%" align="left" id = "SELECT_TYPE">
					<input type = "radio" name  ="QUERY_KIND" value ="1" checked />對保人ID
					<input type = "radio" name  ="QUERY_KIND" value ="2"/>對保人編號
				</td>			
				
				<td class="tbYellow2" width ="40%">
					<input id = "QUERY_COND" name = "QUERY_COND" type = "text" class = "textBox2" size = "12" maxlength ="10" fieldName = "查詢條件" />
				</td>	
				<td class="tbYellow2" align="center" >
					<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				</td>		
			</tr>
			<tr>
				<td colspan = "3" align = "center"> 
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>
					<input id = "btn_update" type = "button" class = "button" value = "修改"/>
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>
				</td>
			</tr>
		</table>	
			
	</form>
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="9%" align="left" >
					對保人編號
				</td>	
				<td class="tbYellow2" width ="30%" colspan="3">	
					<span id ="GUARANTOR_NO_TXT" name ="GUARANTOR_NO_TXT"></span>
				</td>							
			</tr>
			<tr>
				<td class="tbYellow" width="9%" align="left" >
					對保人ID
				</td>	
				<td class="tbYellow2" width ="30%" >
					<input id = "GUARANTOR_ID" name = "GUARANTOR_ID" type = "text" class = "textBox2" size = "12" maxlength ="10" fieldName = "對保人ID"/>	
				</td>				
				<td class="tbYellow" width="10%" align="left" >
					對保人姓名
				</td>	
				<%-- [20240607] 難字調整 --%>				
				<td class="tbYellow2" width ="30%">
					<span id ="GUAR_NAME_TXT" name ="GUAR_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					對保人職級
				</td>	
				<td class="tbYellow2" >
					<span id ="POS_NAME_TXT" name ="POS_NAME_TXT"></span>
				</td>	
				<td class="tbYellow"  align="left" >
					對保人單位
				</td>	
				<td class="tbYellow2" >
					<span id ="GUAR_DEPT_TXT" name ="GUAR_DEPT_TXT"></span>
				</td>						
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					資格取得日
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "BEGIN_DATE" name ="BEGIN_DATE" size = "8" maxlength = "7" datatype="ROCDate" fieldName = "資格取得日"/>
					<img src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('BEGIN_DATE'))">	
				</td>
				<td class="tbYellow"  align="left" >
					對保資格
				</td>
				<td class="tbYellow2" >
					<span id ="GUAR_CONTROL_TXT" name ="GUAR_CONTROL_TXT" class = 'textRed'></span>
				</td>							
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					資格終止日
				</td>							
				<td class="tbYellow2" >
					<input type = "text" class = "textBox2" id = "END_DATE" name ="END_DATE" size = "8" maxlength = "7" datatype="ROCDate" fieldName = "資格終止日"/>
					<img src="<%=imageBase%>/CM/calendar.gif"  alt="Date" onclick="getCalendarFor($('END_DATE'))">	
				</td>	
				<td class="tbYellow"  align="left" >
					終止原因
				</td>	
				<td class="tbYellow2" >
					<select id="END_REASON_VIEW">
						<c:forEach var="map" items="${END_REASON_LIST}">
							<option value='${map.key}'>${map.value}</option>
				       	</c:forEach>
					</select>
					<input id = "END_REASON" name = "END_REASON" type = "text" class = "textBox2" size = "40" />	
				</td>		
			</tr>			
			<tr>
				<td class="tbYellow"  align="left" >
					建檔日期
				</td>	
				<td class="tbYellow2"  >
					<span id ="INPUT_DATE_TXT" name ="INPUT_DATE_TXT"></span>
				</td>	
				<%-- [20240607] 難字調整 --%>
				<td class="tbYellow"  align="left" style="font-family:'EUDC'">
					建檔人員
				</td>	
				<td class="tbYellow2" >
					<span id ="INPUT_NAME_TXT" name ="INPUT_NAME_TXT"></span>
				</td>							
			</tr>
			<tr>
				<td class="tbYellow"  align="left" >
					異動原因
				</td>	
				<td class="tbYellow2"  colspan = "3">
					<input id = "UPDATE_REASON" name = "UPDATE_REASON" type = "text" maxlength = "100" class = "textBox2" size = "80" fieldName = "異動原因"/>	
				</td>
			</tr>
		</table>
		<table id='grid' width="100%"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>				
				<td class="tbYellow" colspan ="4">		
					<b><font class = 'textBlue'>一、作業規定</font></b><BR>
					1.各種貸款規定請參照放款作業手冊及發文規定。<BR>
					2.對保資格取得依照放款對保認證作業管理辦法之規定。<BR>
					3.本作業提供對保人資格查詢。<BR><BR>
					<b><font class = 'textBlue'>二、操作方式</font></b><BR>
					1.查詢：輸入對保人ID或對保人編號，按<b><font class = 'textBlue'>[查詢]</font></b>即可。<BR>
					2.建立對保人資格：查詢後若尚無對保資格，輸入資格取得日、異動原因，按<b><font class = 'textBlue'>[新增]</font></b>即可。<BR>
					3.取消對保人資格：查詢出要取消資格的人員，輸入資格終止日、異動原因及終止原因，按<b><font class = 'textBlue'>[修改]</font></b>即可。<BR>
					4.復原對保人資格：若被取消資格要做復原，清空資格終止日及終止原因後，輸入異動原因，再按<b><font class = 'textBlue'>[修改]</font></b>即可。<BR>
					5.終止原因選項說明：<b><font class = 'textBlue'>未依規定對保(業務員)</font></b>-永久取消資格、<b><font class = 'textBlue'>未依規定對保(其他人員)</font></b>-停權一年、
					<b><font class = 'textBlue'>例外對保查證</font></b>-仍有對保權，惟匯款人員將個案查證。	
				</td>								
			</tr>			
		</table>
	</form>		
</body>
</html>