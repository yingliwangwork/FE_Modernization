<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11207.jsp
功能：追償程序作業
作者：陳宥銓
完成：2013/07/03

[20180824] 修改件:  
1.input 欄位不設type='DATE'
2.input 欄位增加name = theID+'_input'

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
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
<script type="text/javascript">


Event.observe(window, 'load', new DSE11207().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11207(){
	
	var valid1; //畫面檢核物件	
	var valid2; //執行標的畫面檢核
	var LOAN_ID = '${LOAN_ID}';//貸款帳號
	var COURT_List;//法院下拉選單
	var HANDOVER_List;//是否點交下拉選單
	var OPPOSITE_List;//相對人下拉選單
	var grid1List;
	var grid2List;
	var grid3List;
	var grid;	
	var grid1;
	var grid2;
	var tmpList1;
	var isLock;
	var checkedList1 = [];
	var checkedList2 = [];
	var checkedList3 = [];
	var rtnList;

	
	function initValidation(){
		//檢核
		Validation.addAllThese([
			[ 'OPPOSITE_ID_Input_required',  '請輸入其他相對人的ＩＤ及姓名!',
				function(v,elem){
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];				
					return !checks || v;
				}
			],
			[ 'OPPOSITE_ID_Select_required',  '請選擇相對人!',
				function(v,elem){
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];				
					return !checks || v;
				}
			],			
			[ 'checkID',  '身份證字號格式錯誤',
				function(v,elem){
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];
					return !checks || validation.checkROCID(v);
				}
			],			
			[ 'checkAfterToday',  '日期不可大於今日!',
				function(v){ 
					var today = getToday();			
					if( diffDay(today, v) > 0 ){
						return false;					
					}
					return true;
				}
			],
			[ 'APPLY_DATE_required', '聲請日期錯誤，請檢查後重新輸入!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];
					return !checks || v;
					
				}
			],
			[ 'COURT_CODE_required', '請選擇法院!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];
					return !checks || v;
					
				}
			],
			[ 'CASE_NO_required', '請輸入案號!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];
					return !checks || v;
					
				}
			],
			[ 'INQUIRY_DATE_check', '詢價日期不可小於聲請日期!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var APPLY_DATE = dataObj.APPLY_DATE;			
					
						if(( v && APPLY_DATE) && diffDay(APPLY_DATE , toY2K(v)) < 0 ){
							
							return false;					
						}
						return true;
					}
					
				}
			],
			[ 'COURT_APPR_check_in_sale', '請輸入正確鑑價金額', 
				function(v,elem){ 					
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var SALE_DATE = dataObj.SALE_DATE;	
						var SALE_AMT = dataObj.SALE_AMT;	
						var INQUIRY_DATE = dataObj.INQUIRY_DATE;
						if(( SALE_DATE || SALE_AMT || INQUIRY_DATE) && (v == null || v.length == 0)){							
							return false;					
						}
						if((v != null) && (v.length > 0) && (v <=0)){							
							return false;					
						}
						return true;
					}
					
				}
			],
			[ 'INQUIRY_DATE_check_in_sale', '請輸入詢價日期', 
				function(v,elem){ 					
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var SALE_DATE = dataObj.SALE_DATE;	
						var SALE_AMT = dataObj.SALE_AMT;
						var COURT_APPR = dataObj.COURT_APPR;
						if(( SALE_DATE || SALE_AMT || COURT_APPR) &&  ((v == null) || (v.length == 0)) ){							
							return false;					
						}
						return true;
					}
					
				}
			],
			[ 'SALE_DATE_check_in_sale', '請輸入拍定日期', 
				function(v,elem){ 					
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var SALE_DATE = dataObj.SALE_DATE;	
						var SALE_AMT = dataObj.SALE_AMT;	
						
						if(( SALE_DATE || SALE_AMT) &&  ((v == null) || (v.length == 0)) ){							
							return false;					
						}
						return true;
					}
					
				}
			],	
			[ 'SALE_AMT_check_in_sale', '請輸入拍定價', 
				function(v,elem){ 					
					var checks = elem.up('tr').previousSibling.select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var SALE_DATE = dataObj.SALE_DATE;							
						if( SALE_DATE  && (v == null || v.length == 0 || v <=0)){							
							return false;					
						}
						return true;
					}
					
				}
			],
			[ 'WITHDRAW_DATE_check_in_sale', '有輸入拍定日期或拍定價，則不可輸入撤回日期', 
				function(v,elem){ 					
					var checks = elem.up('tr').select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var SALE_DATE = dataObj.SALE_DATE;	
						var SALE_AMT = dataObj.SALE_AMT;	
						
						if(( SALE_DATE || SALE_AMT) &&  !((v == null) || (v.length == 0)) ){							
							return false;					
						}
						return true;
					}
					
				}
			],	
			[ 'check_PARK_NO', '請輸入車位編號!', 
				function(v,elem){ 
					var checks = elem.up('tr').previousSibling.select("input[type=radio]:checked")[0];					
					if(!checks){
						return true;					
					}else{	
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var PARK = dataObj.PARK;					
						if(PARK == 1 &&  ((v == null) || (v.length == 0)) ){							
							return false;					
						}
						return true;
					}
					
				}
			],
			[ 'check_B_SALE_BID_DATE', '拍賣不可小於聲請日期!', 
				function(v,elem){					
					
					var APPLY_DATE = grid.getCheckedRecord()[0].APPLY_DATE;					
					var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var SALE_BID_DATE = dataObj.SALE_BID_DATE;	
					var MIN_PRICE = dataObj.MIN_PRICE;
					var SECURITY_DEPOSIT = dataObj.SECURITY_DEPOSIT;					
					if( (SALE_BID_DATE || MIN_PRICE || SECURITY_DEPOSIT) && (APPLY_DATE && v && diffDay(APPLY_DATE , toY2K(v)) < 0) ){							
						return false;					
					}
					return true;	
				}
			],
				[ 'check_B_SALE_DATE', '拍定日不可小於詢價日期!', 
				function(v,elem){					
					
					var INQUIRY_DATE = grid.getCheckedRecord()[0].INQUIRY_DATE;					
					var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					if( (INQUIRY_DATE && v && diffDay(INQUIRY_DATE , toY2K(v)) < 0)){							
						return false;					
					}
					return true;	
				}
			],
			[ 'check_B_requred', '不可為空!', 
				function(v,elem){					
									
					var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var SALE_BID_DATE = dataObj.SALE_BID_DATE;	
					var MIN_PRICE = dataObj.MIN_PRICE;
					var SECURITY_DEPOSIT = dataObj.SECURITY_DEPOSIT;
					if( (SALE_BID_DATE || MIN_PRICE || SECURITY_DEPOSIT) && ((v == null) || (v.length == 0))  ){							
						return false;					
					}
					return true;	
				}
			],
			[ 'check_B_MIN_PRICE', '底價不可小於保證金!', 
				function(v,elem){	
					var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var SALE_BID_DATE = dataObj.SALE_BID_DATE;	
					var MIN_PRICE = dataObj.MIN_PRICE;
					var SECURITY_DEPOSIT = dataObj.SECURITY_DEPOSIT;					
					if( (SALE_BID_DATE || MIN_PRICE || SECURITY_DEPOSIT) && (parseFloat(MIN_PRICE) < parseFloat(SECURITY_DEPOSIT))  ){							
						return false;					
					}
					return true;	
				}
			],
			[ 'check_B_NO_HANDOVER_MEMO', '請輸入不點交原因!', 
				function(v,elem){	
					var tr = elem.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var HANDOVER = dataObj.HANDOVER;		
					var SALE_BID_DATE = dataObj.SALE_BID_DATE;	
					var MIN_PRICE = dataObj.MIN_PRICE;
					var SECURITY_DEPOSIT = dataObj.SECURITY_DEPOSIT;					
					if( ((SALE_BID_DATE || MIN_PRICE || SECURITY_DEPOSIT) && (!HANDOVER || HANDOVER == '0') ) && ((v == null) || (v.length == 0))  ){							
						return false;					
					}
					return true;	
				}
			]
		]);
	
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode : 'validator'});	
		
		valid2 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		//valid2.define( "required" , { id: "INVESTIGATE_DATE" , errMsg:"請輸入查調日期" } );		
		//valid2.define( "validate-ROCDate" , { id: "INVESTIGATE_DATE" , errMsg:"日期格式錯誤" } );
		valid2.define( "required" , { id: "OPPOSITE_ID_Query" , errMsg:"請於上方區點選一筆資料並選擇相對人再行查詢" } );
		
		
	}
	
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'btn_insert',
			B0004 : 'btn_update',
			B0005 : 'btn_delete',
			B0001 : 'btn_queryinv',
			B0028 : 'btn_confirm'

			
		};
		<dz:grantButtons FUNC_ID ="DSE11207"/>
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1207/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	
	//各種action
	var actions = {
		//檢核C區拍賣日期若有輸入，表示其拍次需要新增，需檢核相關欄位
		chkInputData : function(){
			var isCheck = [];
			for(var i=1; i<=5; i++){
				var SALE_BID_DATE_id = 'SALE_BID_DATE' +  i;
				var PARK_id = 'PARK' +  i;
				var MIN_PRICE_id = 'MIN_PRICE' + i;
				var SECURITY_DEPOSIT_id =  'SECURITY_DEPOSIT' + i;
				var PARK_NO_id = 'PARK_NO' + i;	
				
				if($F(SALE_BID_DATE_id) != ''){
					isCheck.push(Validation.test('required', $(MIN_PRICE_id)));
					isCheck.push(Validation.test('required', $(SECURITY_DEPOSIT_id)));
					if($(PARK_id).checked == true){
						isCheck.push(Validation.test('required', $(PARK_NO_id)));
					}
				}				
				
				
			}
			var result = true;
			for(var j=0; j<isCheck.length; j++){
				if(isCheck[j] == false){
					result = false;
					break;
				}
			}
			return result;
		},
		//將選取資料放入區塊C
		showGridData : function(SALE_ROUND , INVESTIGATE_DATE){
			if(INVESTIGATE_DATE){
				$('INVESTIGATE_DATE').value = toROC(INVESTIGATE_DATE) || '';
			}
			
			if(grid1List[SALE_ROUND-1]){
				grid1.load(grid1List[SALE_ROUND-1]);
			}else{
			   //若是新的輪次  B區必須給空值
			    var newRtnList=[];
			    for (var j = 0; j < 5; j++) {
					var tmpvo = {};
					tmpvo['LOAN_ID']=LOAN_ID;
					tmpvo['SALE_ROUND']=SALE_ROUND;
					tmpvo["SALE_TIMES"]=j + 1;
					tmpvo.HANDOVER = '1';
					newRtnList.push(tmpvo);
				}
			   grid1.load(newRtnList);
			}
			
			
		},
		//產生TableUI中裡面的input欄位
		createInputElement : function(colkey,value,type,col_nm,table,ser_no){
			var theID = colkey+ser_no;
			if(type == 'date'){
				var td = new Element('td');
				var input;
				//[20180824] 不設type='DATE', 增加name = theID+'_input'
				if(colkey=='APPLY_DATE'){
					input = new Element('input', {className : 'textBox2 APPLY_DATE_required validate-ROCDate checkAfterToday', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });			
				}else if(colkey=='WITHDRAW_DATE'){
					input = new Element('input', {className : 'textBox2 validate-ROCDate checkAfterToday WITHDRAW_DATE_check_in_sale', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });
				}else if(colkey=='INQUIRY_DATE' ){
					input = new Element('input', {className : 'textBox2 validate-ROCDate INQUIRY_DATE_check INQUIRY_DATE_check_in_sale', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });
				}else if( colkey=='SALE_DATE'){
					input = new Element('input', {className : 'textBox2  validate-ROCDate SALE_DATE_check_in_sale', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });							
				}else if( colkey=='SALE_BID_DATE'){
					input = new Element('input', {className : 'textBox2  validate-ROCDate check_B_SALE_BID_DATE check_B_requred', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });							
				}else{
					input = new Element('input', {className : 'textBox2  validate-ROCDate', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'7' ,fieldName : col_nm });							
				}
				input.value = Date.toInputROC( value || '' ,'');
				input.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || table.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					dataObj[colkey] = toY2K(event.target.value||'');
					}
				);
				var clan = '<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($(' + theID + '))"/>';
				td.insert(input).insert(clan);
				return td;
			}else if(type == 'number'){
				var input;
				//[20180824] 增加name = theID+'_input'
				if(colkey=='COURT_APPR'){
					input = new Element('input', {className : 'textBox2 validate-integer COURT_APPR_check_in_sale', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : col_nm });				
				}else if(colkey=='MIN_PRICE'){
					input = new Element('input', {className : 'textBox2 validate-integer check_B_requred check_B_MIN_PRICE', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : col_nm });				
				}else if(colkey=='SECURITY_DEPOSIT'){
					input = new Element('input', {className : 'textBox2 validate-integer check_B_requred', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : col_nm });				
				}else if(colkey=='SALE_AMT'){
					input = new Element('input', {className : 'textBox2 validate-integer SALE_AMT_check_in_sale', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : col_nm });				
				}else{
					input = new Element('input', {className : 'textBox2 validate-integer', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : col_nm });				
				}
				input.value = value ? CSRUtil.$fmt(value,'#,###') : '';
				input.observe('blur' , function(event){						
					var tr = this.up('tr');
					var dataObj = tr.dataObj || table.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var new_value = event.target.value;
					dataObj[colkey] = new_value.replace(/,/g,'');
					}
				);
				return input; 
			}else if(type == 'text'){
				var input;
				//[20180824] 增加name = theID+'_input'
				if(colkey=='CASE_NO'){
					input = new Element('input' , {className : 'textBox2 CASE_NO_required', id:theID, name:theID+'_input', type:'text', size : '20' , maxLength : '20' ,fieldName : col_nm});
				}else if(colkey=='PARK_NO'){
				    input = new Element('input' , {className : 'textBox2 check_PARK_NO', id:theID, name:theID+'_input', type:'text', size : '20' , maxLength : '20' ,fieldName : col_nm});
				}else if(colkey=='NO_HANDOVER_MEMO'){
					input = new Element('input' , {className : 'textBox2 check_B_NO_HANDOVER_MEMO', id:theID, name:theID+'_input', type:'text', size : '16' , maxLength : '16' ,fieldName : col_nm});
				}else{
					input = new Element('input' , {className : 'textBox2', id:theID, name:theID+'_input', type:'text', size : '20' , maxLength : '20' ,fieldName : col_nm});
				}
				input.value = value||'';
				input.observe('change' , function(event){						
					var tr = this.up('tr');
					var dataObj = tr.dataObj || table.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					dataObj[colkey] = event.target.value;
					}
				);
				return input;
			}		
		
			
		},
		//產生chcekbox
		createCheckbox : function(colkey,value,col_nm,checkedList,ser_no){
			var theID = colkey+ser_no;
			var thechk = new Element('input', {className : 'textBox2', id: theID , name:colkey, type : 'checkbox', value : value, fieldName : col_nm});
			if(value == '1'){
				checkedList.push(thechk);
			}
			thechk.observe('click' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					if(thechk.checked){
						dataObj[colkey] = '1';
					}else{
						dataObj[colkey] = '';
					}
				}
			);
			return thechk;
		},
		//產生相對人選單及輸入欄位
		createEle : function(type , inputName , inputValue){
		
			if( type == 'select'){
				//下拉選單欄位
				<%-- [20240207] 難字調整：相對人 --%>
				var select = new Element('select' , {className : 'textBox2' , fieldName : '相對人資訊', alt:'ch' });
				var option = new Element('option' , { value : ''}).update("其他");
				select.insert(option);	
							
				//放入相對關係人資料到選單中
				OPPOSITE_List.each(
					function(data) {
						var OPPOSITE_ID = data.ID;
						select.add(new Option(data.NAME, data.ID));					
					}
				);			
				
				//註冊事件
				select.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var targetValue = event.target.value;
					var currentTd = this.up('td');
					
					//如果下拉選單沒值,也就是選了'其他' , 就產生ID與NAME欄位
					if( !targetValue){
						var INPUT_ID = actions.createEle('input','OPPOSITE_ID', '');		
						var INPUT_NAME = actions.createEle('input','OPPOSITE_NAME', '');
						
						//產生ID與NAME後,下拉選單就會被檢核出來中
						select.setAttribute( 'className' , 'textBox2');
						//新增輸入欄位
						currentTd.insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
						//並且將原本資料內容清掉，
						dataObj.OPPOSITE_ID = '';
						dataObj.OPPOSITE_NAME = '';
						if(tr.select("input[type=radio]:checked")[0]){		
							$('OPPOSITE_ID_Query').value ='';
							$('OPPOSITE_ID2').update ( '');
						}
					}else{
						//如果有選值 , 有可能從"其他"變成選有值 , 所以就要將ID跟NAME刪掉, 再重做一個下拉選單加進去
						var select_New = actions.createEle('select', '' , '');
						select_New.value =  targetValue;
						currentTd.update(select_New);//清空並重加選單
						dataObj.OPPOSITE_ID = targetValue;
						dataObj.OPPOSITE_NAME = select_New.options[select_New.selectedIndex].text;
						if(tr.select("input[type=radio]:checked")[0]){		
							$('OPPOSITE_ID_Query').value = targetValue;
							$('OPPOSITE_ID2').update(select_New.options[select_New.selectedIndex].text);
						}
					}					
					
					<%-- [20240207] 難字調整，動態新增需呼叫parseEUDC --%>
					parseEUDC();
				});
				
				return select;
				
			}else if(type =='input'){
			
				//產生INPUT欄位的共用方法
				var input = new Element('input' , {className : 'textBox2 OPPOSITE_ID_Input_required' , value : inputValue ||'' , size : '12' , maxLength : '10' ,fieldName : '相對人資訊'});			
				if(inputName == 'OPPOSITE_NAME'){				
					input.setAttribute( 'maxLength' , '30');				
					<%-- [20240207] 難字調整：姓名 --%>
					input.setAttribute('alt', 'ch');
				}					
				input.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
					
					//動態將值直接改掉
					if( inputName == 'OPPOSITE_ID'){
						input.setAttribute( 'className' , 'checkID textBox2 checkRequiredINV');
						dataObj[inputName] = event.target.value.toUpperCase();
						if(tr.select("input[type=radio]:checked")[0]){		
							$('OPPOSITE_ID_Query').value = event.target.value.toUpperCase();
						}
					}else if(inputName == 'OPPOSITE_NAME'){
						dataObj[inputName] = event.target.value;
						if(tr.select("input[type=radio]:checked")[0]){		
							$('OPPOSITE_ID2').update(event.target.value);
						}
					}			
				});
				return input;
			}		
		}
			
	};
	
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
		     
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){		
				  	COURT_List = resp.COURT_List;
					HANDOVER_List = resp.HANDOVER_List || [];
					OPPOSITE_List = resp.OPPOSITE_List || [];
					 grid2List= resp.E126_List;
					if(grid2List.length==0){
					    //alert("執行標的無資料");
					 }	else	{		 
				         isLock='Y';
					 }
					 grid2.load(grid2List||[]);
					grid1List = resp.DTDSE127_voList;
					grid1.load([]);
			    	tmpList1=[];
			        rtnList=resp.rtnList || [];
				   if(rtnList!=''){
					    grid.load(rtnList);
					}else{
					var tempList = [];
						//如果沒資料, 就新增一筆其他可以給user新增
						tempList.push(
							{ 	LOAN_ID : LOAN_ID,
								SALE_ROUND : '1', 
								OPPOSITE_ID : '',
								CASE_NO : '', 
								INQUIRY_DATE : '',
								COURT_APPR : '',
								WITHDRAW_DATE :'',
								SALE_DATE :''
							}
						);
						grid.load(tempList);
					}
					
				},
				function(resp){
					COURT_List = resp.COURT_List;
					OPPOSITE_List = resp.HANDOVER_List || [];
					HANDOVER_List = resp.HANDOVER_List || [];
					OPPOSITE_List =resp.OPPOSITE_List || [];
					grid1List = [];
					grid2List = [];
					/*if(grid2List.length==0){
					    alert("執行標的無資料");
					 }*/
					var tempList = [];
					//如果沒資料, 就新增一筆其他可以給user新增
					tempList.push(
						{ 	LOAN_ID : LOAN_ID,
							SALE_ROUND : '1', 
							OPPOSITE_ID : '',
							CASE_NO : '', 
							INQUIRY_DATE : '',
							COURT_APPR : '',
							WITHDRAW_DATE :'',
							SALE_DATE :''
						}
					);
					grid.load(tempList || []);					
					grid1.load([]);	
					grid2.load([]);
					tmpList1=[];
					
				}
			);

		},
	
		
		//查詢調查財產紀錄
		doQueryINV : function(event){
		
			grid2.load([]);
			
			 if(!valid2.validate()){
				return;			
		     }
			
			//發送ajax
			ajaxPost( 'queryinv' , {LOAN_ID : LOAN_ID, 'INVESTIGATE_DATE':$F('INVESTIGATE_DATE'), ID : $('OPPOSITE_ID_Query').value},
				function(resp){
					
						grid3List= resp.Detail_List;
					if(grid3List.length !=0){
					    isLock= 'N';
					}
					
					grid2.load(resp.Detail_List || []);
				
					
					
				}				
			);				

			
		},
		
		//確認調查財產紀錄
		doConfirm : function(event){
		
			tmpList1 = grid2.getCheckedRecord();	
			
			if( tmpList1.length == 0 ){
				alert('請選擇 [執行標的] 資料!');
				return;			
			}
			
			isLock = 'Y';
			
			grid2.load(tmpList1);

			
		},
		
		
		//新增
		doInsert : function(){
			
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇資料!');
				return;			
			}
			
			
			//檢核區塊A
			valid1.reset();			
			if(!valid1.validate()){
				return;
			}
			
						
			if( tmpList1.length == 0 || isLock=='N'){
				alert('請選擇執行標的並確認!');
				return;			
			}
			
			/*
			//檢核區塊C
			if(!actions.chkInputData()){
				alert('請輸入拍賣資料');
				return;
			}*/
			
			var DTDSE125_vo = tmpList[0];
			DTDSE125_vo.INVESTIGATE_DATE = $('INVESTIGATE_DATE').value;
			var DTDSE127_voList = grid1.getAllRecords();
			var E126_List= tmpList1;
			
				
			//發送ajax
			ajaxPost( 'insert' , {
					LOAN_ID : LOAN_ID,
					DTDSE125_vo : Object.toJSON(DTDSE125_vo),
					DTDSE127_voList : Object.toJSON(DTDSE127_voList),
					E126_List:Object.toJSON(E126_List)
				},
				function(resp){
					grid1List = resp.DTDSE127_voList || [];
					grid2List= resp.E126_List || [];
					grid.load(resp.rtnList || []);
					grid1.load([]);
					grid2.load([]);
				
				}				
			);
		},
		
		//修改
		doUpdate : function(action){
			
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇資料!');
				return;			
			}
			
			//檢核區塊A
			valid1.reset();			
			if(!valid1.validate()){
				return;
			}
			
		 var E126_List=grid2.getAllRecords();
		 	if( E126_List.length == 0 ){
				alert('執行標的無資料!');
				return;			
			}
		 
		 if(isLock=='N'){
				alert('請先 [調查財產紀錄]後，選擇並確認!');
				return;			
			}
			
			/*
			//檢核區塊C
			if(!actions.chkInputData()){
				alert('請輸入拍賣資料');
				return;
			}*/
			
			var DTDSE127_voList = grid1.getAllRecords();
			var DTDSE125_vo  = tmpList[0];
			DTDSE125_vo.INVESTIGATE_DATE = $('INVESTIGATE_DATE').value;
												
			//發送ajax
			ajaxPost( 'update' , {
					LOAN_ID : LOAN_ID,
					DTDSE125_vo : Object.toJSON(DTDSE125_vo),
					DTDSE127_voList : Object.toJSON(DTDSE127_voList),
					E126_List:Object.toJSON(E126_List)
				},
				function(resp){
					grid1List = resp.DTDSE127_voList || [];
					grid2List= resp.E126_List  || [];
					grid.load(resp.rtnList || []);
					grid1.load([]);	
					grid2.load([]);
					
                     					
				}				
			);		
			
		},
		
		//刪除
		doDelete : function(action){
		
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE125_vo = tmpList[0];
		
			//發送ajax
			ajaxPost( 'delete' , {LOAN_ID : LOAN_ID , DTDSE125_vo : Object.toJSON(DTDSE125_vo)},
				function(resp){	
					grid1List = resp.DTDSE127_voList || [];
					grid2List= resp.E126_List || [];
					grid.load(resp.rtnList || []);
					grid1.load([]);
					grid2.load([]);
				}				
			);	
			
		},
		
		//新增輪次
		doAddRound : function(event){
			var DTDSE125_List = grid.getAllRecords();
			//發送ajax
			ajaxPost( 'addRound' , {LOAN_ID : LOAN_ID},
				function(resp){
					if(resp.SALE_ROUND > DTDSE125_List.length){
						var newVO = resp.DTDSE125_vo;
						newVO.LOAN_ID = LOAN_ID;						
						DTDSE125_List.push(newVO);
						grid.load(DTDSE125_List);					
					}
					grid2.load([]);
				}				
			);				

			
		}
		,doQuerybyID: function(ID){
			ajaxPost( 'querybyID' , {ID : ID},
				function(resp){
					
					grid2.load(resp.E105List||[]);
				},function(resp){
					grid2.load([]);
				});
		}
		
		
		
		
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11207','法務作業','追償程序',1,true);
			
			//產生 Grid 物件	
			grid = new TableUI (
				{ table: $('grid'), pageSize: 10,  split : ['ADD_BUILD'],
				  allSortable:false, 
				  autoCheckBox :{ 
						type :'radio',
						action: function(checkbox , boxStatus , records) {
						//每點選A區一筆資料，將點選資料帶入B區相對人
						$('OPPOSITE_ID2').update(records[0].OPPOSITE_NAME||'');
						$('OPPOSITE_ID_Query').value=records[0].OPPOSITE_ID||'';
						
						//將資料帶入區塊C
						actions.showGridData(records[0].SALE_ROUND, records[0].INVESTIGATE_DATE);
						
						var alist=[];
						for (var i=0; i< grid2List.length; i++){
							if(grid2List[i].SALE_ROUND==records[0].SALE_ROUND){
							alist.push(grid2List[i]);
							}
						};
						
						grid2.load(alist || []);
						//取得最新查調日期資料
						//buttons.doQuerybyID(records[0].OPPOSITE_ID);
						
					}	
				  },
				  overDiv:false,
				  afterLoad: function(ele){
				  	var checks = $('grid').select("input[type=checkbox]");
					for( var i = 0 ; i < checks.length ; i++ ){
						if(checks[i].value == '1'){
							checks[i].checked = true;
						}
					}
					autoFormatToNumber();
				  },				  				  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	            	  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	            	  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
			  	  column : [
					{header : '序號', key : 'SALE_ROUND', attrs : {rowSpan : 2}},
					{header : '聲請日期', key : 'APPLY_DATE', attrs : {rowSpan : 2}
						,render : function(record, value){
							return actions.createInputElement('APPLY_DATE',value,'date','聲請日期',grid,record.SALE_ROUND);
						}
					},
				  	{header : '相對人', key : 'OPPOSITE_ID', attrs : {rowSpan : 2}
						,render : function(record, value){
							
							//製作相對人下拉選單
							var select = actions.createEle('select','', '');
							//檢查ID是否在相對人下拉選單內									
							var isOther = true;															
							for(var i = 0 ; i < OPPOSITE_List.length ; i++){
								if(value == OPPOSITE_List[i].ID){
									isOther = false;
									break;
								}
							}
							//ID不存在於下拉選單中
							if(isOther){
								var span = new Element('span' );
								var INPUT_ID = actions.createEle('input','OPPOSITE_ID', record.OPPOSITE_ID);
								var INPUT_NAME = actions.createEle('input','OPPOSITE_NAME', record.OPPOSITE_NAME);
								span.insert(select).insert('&nbsp&nbspID ：').insert(INPUT_ID).insert('&nbsp&nbsp姓名 ：').insert(INPUT_NAME);
								return span;
								
							}						
							select.value = value;
							return select;				
						}	
					},
					{header : '法院', key : 'COURT_CODE', attrs : {rowSpan : 2}
						,render : function(record, value){
							var select = new Element('select' , {className : 'textBox2 COURT_CODE_required' , fieldName : '法院'});	
							for (key in COURT_List){
								select.add(new Option(COURT_List[key], key));
							}
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj['COURT_CODE'] = event.target.value;
								}
							);							
							select.value = value;//預設值
							return select;						
		
						}
					},
					{header: '案號' , key : 'CASE_NO', attrs : {rowSpan : 2}
						,render : function(record, value){
							return actions.createInputElement('CASE_NO',value,'text','案號',grid,record.SALE_ROUND);
						}
					},
					
					{header : '詢價日期', key : 'INQUIRY_DATE'
						,render : function(record, value){
							return actions.createInputElement('INQUIRY_DATE',value,'date','詢價日期',grid,record.SALE_ROUND);
						}
					},
					{header: '鑑價金額' , key : 'COURT_APPR'
						,render : function(record, value){
							return actions.createInputElement('COURT_APPR',value,'number','鑑價金額',grid,record.SALE_ROUND);
						}
	                },
					{header : '撤回日期', key : 'WITHDRAW_DATE'
						,render : function(record, value){
							return actions.createInputElement('WITHDRAW_DATE',value,'date','撤回日期',grid,record.SALE_ROUND);
						}
					},					
					{header : '拍定日期', key : 'SALE_DATE'						
						,render : function(record, value){
							return actions.createInputElement('SALE_DATE',value,'date','拍定日期',grid,record.SALE_ROUND);
						}
											
					},					
					{header: '增建' , key : 'ADD_BUILD'
						,render : function(record, value){
							return actions.createCheckbox('ADD_BUILD',value,'增建',checkedList1,record.SALE_TIMES);
						}
					},
					{header: '車位' , key : 'PARK'
						,render : function(record, value){
							return chkbox = actions.createCheckbox('PARK',value,'車位',checkedList2,record.SALE_TIMES);
						}
					},					
					{header: '車位編號' , key : 'PARK_NO'
						,render : function(record, value){
							return actions.createInputElement('PARK_NO',value,'text','車位編號',grid1,record.SALE_TIMES);
						}
					},							
					{header: '拍定價' , key : 'SALE_AMT'
						,render : function(record, value){
							return actions.createInputElement('SALE_AMT',value,'number','拍定價',grid1,record.SALE_TIMES);
						}						
					}
				]
			});
						
					
			//產生 Grid1 物件 -- 拍賣資訊	
			grid1 = new TableUI ( 
				{ table: $('grid1'), allSortable:false, overDiv:false,title:'拍賣資訊',
					afterLoad: function(ele){
						for(var i=0; i<checkedList1.length; i++){
							checkedList1[i].checked = true;
						}
						for(var i=0; i<checkedList2.length; i++){
							checkedList2[i].checked = true;
						}
						for(var i=0; i<checkedList3.length; i++){
							checkedList3[i].checked = true;
						}
						checkedList1 = [];
						checkedList2 = [];
						checkedList3 = [];
						autoFormatToNumber();	
					},			
				column : [
					{header: '拍次' , key : 'SALE_TIMES'
						,render : function(record, value){
							var times_name;
							switch (value) {
								case 1: times_name = '一拍';
										break;
								case 2: times_name =  '二拍';
								        break;
								case 3: times_name =  '三拍';
										break;
								case 4: times_name =  '特別變賣';
										break;
								case 5: times_name =  '減價拍賣';
										break;
								default:
									times_name =  '';
							}
							return times_name;
						}
					},
					{header: '拍賣日期' , key : 'SALE_BID_DATE'
						,render : function(record, value){
							return actions.createInputElement('SALE_BID_DATE',value,'date','拍賣日期',grid1,record.SALE_TIMES);
						}
					},
					{header: '底價' , key : 'MIN_PRICE'
						,render : function(record, value){
							return actions.createInputElement('MIN_PRICE',value,'number','底價',grid1,record.SALE_TIMES);
						}						
					},
					{header: '保證金' , key : 'SECURITY_DEPOSIT'
						,render : function(record, value){
							return actions.createInputElement('SECURITY_DEPOSIT',value,'number','保證金',grid1,record.SALE_TIMES);
						}
					},
					{header: '是否點交' , key : 'HANDOVER'
						,render : function(record, value){
							var select = new Element('select' , {id:'HANDOVER' + record.SALE_TIMES ,className : 'textBox2 required' , fieldName : '是否點交'});														
							for (key in HANDOVER_List){
								select.add(new Option(HANDOVER_List[key], key));
							}
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj['HANDOVER'] = event.target.value;
								}
							);
							select.value = value;
							return select;	
						}						
					},
					{header: '不點交原因' , key : 'NO_HANDOVER_MEMO'
						,render : function(record, value){
							return actions.createInputElement('NO_HANDOVER_MEMO',value,'text','不點交原因',grid1,record.SALE_TIMES);
						}						
					},	
					{header: '除租' , key : 'DEL_RENT'
						,render : function(record, value){
							return actions.createCheckbox('DEL_RENT',value,'除租',checkedList3,record.SALE_TIMES);
						}
					}
				]
			});						

               //產生Grid2物件--執行標的
			 grid2 = new TableUI(
			 {table: $("grid2"), pageSize : 10, allSortable: false, overDiv:false,
			    autoCheckBox:{
							text:'選取', 
							type:'checkbox',
							disableRule : function(record){
							 return isLock =='Y' ? true : false;
						 },			  
						  
							isSelectAll:true 
				},
	            <%-- [20240207] 難字調整 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
				column:[			
					{header :"查調日期", key :"INVESTIGATE_DATE",
						render : function(record, value){
							return value ? Date.toInputROC( value ,"/") : '';
						}
					},
				    {header :"種類", key :"PROEPRTY_TYPE_NM"},
					{header:"項目", key:"PROEPRTY_ITEM_NM"},
					<%-- [20240207] 難字調整：第三人 --%>
					{header:"第三人",key:"THIRD_NAME", attrs:{ style:"font-family:'EUDC'" }}
										
				]
			 
			 });


               			
						
							
			//按鈕事件監聽
			$('btn_insert').observe('click', buttons.doInsert); //新增
			$('btn_update').observe('click', buttons.doUpdate); //修改
			$('btn_delete').observe('click', buttons.doDelete); //刪除
			$('btn_add_round').observe( 'click', buttons.doAddRound);//新增輪次
			$('btn_queryinv').observe( 'click', buttons.doQueryINV);//查詢調查財產記錄
			$('btn_confirm').observe( 'click', buttons.doConfirm);//確認調查財產記錄

			initValidation();//畫面日期檢核
			
			buttonAuth();//按鈕授權
			
			ajaxRequest.closeSuccMsg();
			buttons.doQuery();//初始查詢
		
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow1" colspan="8" align="center">
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />
				</td>
			</tr>		
		</table>
		<table id = "grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_add_round" type = "button" class = "button" value = "新增序號"/>
				</td>
			</tr>			
		</table>
         <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
         <tr>
			<td class="tbYellow0" width="5%" align='center' colspan='8'><B>執行標的</B></td>
		</tr>
		<tr>
			<td class="tbYellow" width="2%">查調日期</td>
			<td class="tbYellow2" width="2%">
			     <input id='INVESTIGATE_DATE' datatype ='ROCDate' type='text' class= 'textBox2'  size='9' maxlength='7' /> 
			     <img src="/DSWeb/images/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('INVESTIGATE_DATE'))">
			</td>
			<td class="tbYellow" width="2%">相對人</td>
			<td class="tbYellow2" width="1%">
				<%-- [20240207] 難字調整：相對人 --%>
				<span id="OPPOSITE_ID2" style="font-family:'EUDC'"></span>
				<input id="OPPOSITE_ID_Query" type='hidden' class= 'textBox2'  size='8' maxlength='8' />
			</td>
			<td class='tbYellow2' width="6%" align='left' >
			<input id='btn_queryinv' type='button' class='button' value='調查財產記錄查詢' />
			<input id='btn_confirm' type='button' class='button' value='確認' />
		  </td>
		  </tr>
		 </table>			
		<table id = "grid2"></table>
		<table id = "grid1"></table>
</form>	
<form id="form2" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
</form>
</body>
</html>