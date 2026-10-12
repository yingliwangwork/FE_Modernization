<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11210.jsp
作者：黃子玹
功能：拍賣抵押物裁定作業
完成：2013/5/20

[20240207]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<title></title>
<!--匯入外部Javascript 與 css-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>   <%-- CSR相關處理用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
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
<script type='text/javascript'>


// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSE11210().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11210(){
	
	//貸款帳號
	var LOAN_ID = '${LOAN_ID}';
		
	//Table UI
	var gridB;	
	var gridC;
	var gridD1;	
	var gridD2;	
	var gridF;
	
	var checkIDList =[];
	var E103_mapList = [];	
	
	//檢核
	var valid1;
	var valid2;	
	
	
	//畫面檢核
	function initValidation(){		
		//查詢用檢核
		Validation.addAllThese([
			
			[ 'checkID',  '身份證字號格式錯誤',
				function(v){  
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v );
				}
			],
			[ 'checkAfterToday',  '日期不可大於今日!',
				function(v,elem){ 
					var today = getToday();					
					if(  diffDay(today, v) > 0 ){
						return false;					
					}
					return true;
				}
			],
			
			[ 'OWNER_NAME_Required', '請輸入姓名!', 
				function(value,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];

					return !checks || value;
					
				}
			],
			[ 'OWNER_ID_Required', '請輸入ID!', 
				function(value,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];

					return !checks || value;
					
				}
			],
			[ 'CON_ADDR_Required', '請輸入住址!', 
				function(value,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];

					return !checks || value;
					
				}
			],
			['validateFullType', '', function(v) { if(!v){return true;} return !validation.hasHalfType(v); }],
			['validateFullType_ADDR', '住址欄位須為全形文字，請檢查後重新輸入!', 			
				function(v,elem) {					
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					//if(!v){return true;} 
					return !checks || !validation.hasHalfType(v); 				
				}
			],
			[ 'chkADJ_DATE', '確認日期需大於等於聲請日期', function() { return chkADJ_DATE($('APPLY_DATE'), $('CERTAIN_DATE'));}]
			
		]);
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define( "required" , { id: "APPLY_DATE"  } );	
		valid1.define( "checkAfterToday" , { id: "APPLY_DATE"  } );
		//valid1.define( "required" , { id: "CERTAIN_DATE"  } );	
		valid1.define( "checkAfterToday" , { id: "CERTAIN_DATE"  } );
		valid1.define( "required" , { id: "COURT_CODE"  } );	
		valid1.define( "required" , { id: "CASE_NO"  } );
		valid1.define( "chkADJ_DATE" , {id:"CERTAIN_DATE",errMsg:"確認日期需大於等於聲請日期" } );
		
		valid2 = new Validation("form3", { focusOnError:true, immediate:false ,mode : 'validator'});
		valid2.define('validateFullType' , [{ id : "GAGE_ADDR_REORG" , errMsg:"門牌整編欄位須為全形文字，請檢查後重新輸入!"}] );
		valid2.define('required' , [{ id : "GAGE_ADDR_REORG" , errMsg:"請輸入門牌整編"}] );
		
		Validation.addAllThese([					
			[ 'checkID_ROC',  '身份證字號格式錯誤',
				function(value,elem){  
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];					
					return !checks||validation.checkROCID(value);
				}
			]						
		]);
		valid3 = new Validation("form4", { focusOnError:true, immediate:false ,mode : 'validator'});		
			
	}
	var chkADJ_DATE = function (strObj, endObj) 
		{	
			if(!isROCdate(strObj.value) || !isROCdate(endObj.value)){
				return true;
			}
		
			if(diffDay(strObj.value, endObj.value)<0){
				return false;
			}
			
			return true;
		};
	//按扭權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert" ,				
				B0004:"btn_update" ,
				B0005:"btn_delete" ,
				B0172:"btn_print" ,
				B0173:"btn_hostageno_change" ,
				B0174:"btn_owner_change" 	
		};
	
		<dz:grantButtons FUNC_ID="DSE11210" />
	}
	
	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1210/" + actionName,
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
	
		
		//讓使用者在【B區】拍賣抵押物裁定異動-相對人區塊，可以新增相對人資料
		initGrid : function(){
			
			var initinsertMap = [{ 	
				LOAN_ID : LOAN_ID , 
				CASE_KIND : '0' , 
				SEQ_NO : '1' ,
				OP_TYPE : '071'
			}]

			gridB.load(initinsertMap);		
		},
		initGridF : function(){
			var initinsertMapF = [{ 
				LOAN_ID : LOAN_ID , 
				INPUT_DATE : '',
				INPUT_ID : '',		
				OWNER_ID : '' , 
				OWNER_IDOLD : '',
				OWNER_NAME : '' , 
				CON_ADDR : '' ,
				MEMO : ''
			}]
			gridF.load(initinsertMapF);
		
		},
		
		//單選RADIO，選取後資料顯示於【C區】拍賣抵押物裁定明細區塊
		showDetailList : function(rec){
			
			var DTDSE180_voList = rec.DTDSE180_voList ;			
					
			//產生用來load grid的物件temp  
			var temp = new Object([]);
			
			//產生用來check grid中有無重複id的物件
			checkIDList = new Object([]);		
			
			
			//如果DTDSE180_voList內有資料 , 就將資料copy到各List中
			if(DTDSE180_voList.length > 0){
				for(var i = 0 ; i < DTDSE180_voList.length ; i ++){
					temp.push(Object.clone(DTDSE180_voList[i]));
					checkIDList.push(Object.clone(DTDSE180_voList[i]));
				}
			}else{
				//如果沒資料, 就新增一筆"其他"讓user新增
				temp.push(
					{ 	LOAN_ID : LOAN_ID , 
						CASE_KIND : rec.CASE_KIND , 
						SEQ_NO : rec.SEQ_NO ,
						OP_TYPE : '071'
					}
				);				
			}
			//載入List
			gridB.load(temp);
			
			//將資料放入A區塊			
			var IS_SEND = rec.IS_SEND;
			
			if(IS_SEND == '1'){
				$('IS_SEND').checked = true;			
			}else{
				$('IS_SEND').checked = false;
			}
			var IS_CERTAIN = rec.IS_CERTAIN;
			
			if(IS_CERTAIN == '1'){
				$('IS_CERTAIN').checked = true;			
			}else{	
				$('IS_CERTAIN').checked = false;
			}
			
			$w('COURT_CODE CASE_NO').each(
				function(elem){						
					$(elem).value = rec[elem];				
				}			
			);
			
			$('APPLY_DATE').value = toROC(rec.APPLY_DATE|| '') ;
			$('CERTAIN_DATE').value = toROC(rec.CERTAIN_DATE|| '') ;	

		},		
	
		//查詢
		doQuery : function(){	
		
			//發送ajax
			ajaxPost( 'query' , { LOAN_ID : '${LOAN_ID}'},
				function(resp){						
					
					OPPOSITE_List = resp.OPPOSITE_List || [];
					
					gridC.load(resp.rtnList || []);
					gridD1.load(resp.E041_mapList || []);
					E103_mapList = resp.E103_mapList || [];
					var initinsertMapF = { 
							LOAN_ID : LOAN_ID , 
							INPUT_DATE : '',
							INPUT_ID : '',		
							OWNER_ID : '' , 
							OWNER_IDOLD : '',
							OWNER_NAME : '' , 
							CON_ADDR : '' ,
							MEMO : ''												
					}
					
					E103_mapList.push(initinsertMapF);
					
					gridF.load( E103_mapList || [] );					
					
					/*
					if(E103_mapList){
						var i=1;
						var E103_mapListlength = E103_mapList.length ;
						$$('#gridF input[type ="checkbox"]').each(
							
							function(elem){	
								if(i!=E103_mapListlength){								
									elem.checked = true;								
								}
								i++;
							}		
						)
					}*/				
					var E010Map = resp.E10Map || '';
					$('GAGE_ADDR').innerHTML = E010Map['GAGE_ADDR'] || '';
					$('GAGE_ADDR_REORG').value = E010Map['GAGE_ADDR_REORG'] || ''; 	
					actions.initGrid();
				},
				function(resp){					
					
					OPPOSITE_List = resp.OPPOSITE_List || [];
					gridC.load([]);	
					gridD1.load([]);					
					gridF.load([]);		
					
					actions.initGrid();
					actions.initGridF();
				}
			);				
		},
				
		//產生TableUI裡面的select與input欄位
		makeElement : function(type , inputName , inputValue){
			if( type == 'select'){
				//下拉選單欄位
				<%-- [20240207] 難字調整：相關人 --%>
				var SELECT = new Element('SELECT' , {className : 'textBox2' , fieldName : '相對人資訊', alt:'ch' });
				var option = new Element('OPTION' , { value : ''}).update("其他");
				SELECT.insert(option);	
				//放入相對關係人資料到選單中
				OPPOSITE_List.each(
					function(data) {
						var OPPOSITE_ID = data.ID;
						SELECT.add(new Option(data.NAME, OPPOSITE_ID));					
					}
				);			
				
				//註冊事件
				SELECT.observe('change' , function(event){
					
					//只要修改上面的資料 , 就改掉實體的資料
					var tr = this.up('tr');
					var dataObj = tr.dataObj || gridB.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					
					var targetValue = event.target.value;
					var currentTd = this.up('td');		
					
					//如果下拉選單沒值,也就是選了'其他' , 就產生ID與NAME欄位
					if( !targetValue){
					
						var INPUT_ID = actions.makeElement('input','OPPOSITE_ID', '');		
						var INPUT_NAME = actions.makeElement('input','OPPOSITE_NAME', '');	
						
						//產生ID與NAME後,下拉選單就會被檢核出來中
						SELECT.setAttribute( 'className' , 'textBox2');
						
						//將原本的欄位放入這兩個欄位
						currentTd.insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
						
						//重設TABLE高度
						gridB.resetDivHeight();
						
						//並且將原本資料內容清掉 , 讓user可以輸入
						dataObj.OPPOSITE_ID = '';
						dataObj.OPPOSITE_NAME = '';
						
					}else{
					
						//如果有選值 , 有可能從"其他"變成選有值 , 所以就要將ID跟NAME刪掉, 再重做一個下拉選單加進去
						var SELECT_A = actions.makeElement('select', '' , '');
						SELECT_A.value =  targetValue;
						currentTd.update(SELECT_A);	
						dataObj.OPPOSITE_ID = targetValue;
						dataObj.OPPOSITE_NAME = SELECT_A.options[SELECT_A.selectedIndex].text;
						
					}					
					
					<%-- [20240207] 難字調整，動態新增需呼叫parseEUDC --%>
					parseEUDC();
				});
				return SELECT;
			}else if(type =='input'){
				
				//產生INPUT欄位的共用方法
				var INPUT = new Element('INPUT' , {className : 'textBox2 required' , value : inputValue ||'' , size : '12' , maxLength : '10' ,fieldName : '相對人資訊'});			
				
				//動態將值直接改掉
				if( inputName == 'OPPOSITE_ID'){						
					INPUT.setAttribute( 'className' , 'checkID textBox2 required');
				}
				if( inputName == 'OPPOSITE_NAME'){						
					INPUT.setAttribute( 'maxLength' , 30);
					<%-- [20240207] 難字調整：姓名 --%>
					INPUT.setAttribute('alt', 'ch');
				}
				INPUT.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || gridB.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					//動態將值直接改掉
					if( inputName == 'OPPOSITE_ID'){
						dataObj[inputName] = event.target.value.toUpperCase();
					}else if(inputName == 'OPPOSITE_NAME'){
						dataObj[inputName] = event.target.value;
					}			
				});
				return INPUT;
			}		
		},
		
		//新增
		doInsert : function(event){
		
			var DTDSE180_voList = gridB.getAllRecords();
			
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			valid2.reset();	
			valid3.reset();	
			if(!valid1.validate()){
				return;
			}
		
			var DTDSE071_vo = gridC.getCheckedRecord()[0] || {};
			
			//將畫面資料取代			
			DTDSE071_vo.LOAN_ID = LOAN_ID;
			DTDSE071_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE071_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ;		
			DTDSE071_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE071_vo.CASE_NO = $('CASE_NO').value ; 
			
			if($('IS_SEND').checked){
				DTDSE071_vo.IS_SEND = '1'
			}else{
				DTDSE071_vo.IS_SEND = '0'
			}
			
			if($('IS_CERTAIN').checked){
				DTDSE071_vo.IS_CERTAIN = '1'
			}else{
				DTDSE071_vo.IS_CERTAIN = '0'
			}
			
			//發送ajax
			ajaxPost( 'insert' , { 
					DTDSE071_vo : Object.toJSON(DTDSE071_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){	
					$('form').reset();
					gridC.load(resp.rtnList || []);
					gridC.resetDivHeight();
					
					actions.initGrid();									
				}				
			);	
		},
		//修改
		doUpdate : function(event){
			
			var temp = gridC.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇要修改資料!');
				return;
			
			}
			
			var DTDSE180_voList = gridB.getAllRecords();
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			
			var DTDSE071_vo  = temp[0];		
			valid2.reset();	
			valid3.reset();	
			if(!valid1.validate()){
				return;
			}
					
		
			//將畫面資料取代
			DTDSE071_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE071_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ; 
			DTDSE071_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE071_vo.CASE_NO = $('CASE_NO').value ; 
			if($('IS_SEND').checked){
				DTDSE071_vo.IS_SEND = '1'
			}else{
				DTDSE071_vo.IS_SEND = '0'
			}
			
			if($('IS_CERTAIN').checked){
				DTDSE071_vo.IS_CERTAIN = '1'
			}else{
				DTDSE071_vo.IS_CERTAIN = '0'
			}
			
			
			//發送ajax
			ajaxPost( 'update' , { 
					DTDSE071_vo : Object.toJSON(DTDSE071_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){	
					$('form').reset();
					gridC.load(resp.rtnList || []);	
					gridC.resetDivHeight();	
					
					actions.initGrid();									
				}				
			);		
		},
		
		//刪除
		doDelete : function(event){
			
			var temp = gridC.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE071_vo  = temp[0];
		
			//發送ajax
			ajaxPost( 'delete' , { 
					DTDSE071_vo : Object.toJSON(DTDSE071_vo)					
				},
				function(resp){		
					$('form').reset();
					gridC.load(resp.rtnList || []);	
					gridC.resetDivHeight();	
					
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();								
				}				
			);	
		},
		
		//新增相對人
		doInsertOppositeparty : function(event){
			
			valid1.reset();	
			var DTDSE180_voList = gridB.getAllRecords();
			
			var map  =DTDSE180_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.OPPOSITE_ID='';
			tmpMap.OPPOSITE_NAME='';
			DTDSE180_voList.push(tmpMap);
			gridB.load(DTDSE180_voList);			
			
			/*
			var tempVo = gridB.getCheckedRecord();
			
			if( tempVo.length == 0  ){
				alert('請先選擇一筆要新增的資料!');
				return;
			}
			var DTDSE180_vo = tempVo[0];
								
			var DTDSE180_voList = gridB.getAllRecords();		
			
			//因為一修改上面的資料就直接改掉了，因此先把資料內容清光
			DTDSE180_voList = [];
			
			//要新增的資料是否有重複
			var is_dup = false;
			for ( var i = 0 ; i < checkIDList.length ; i++){
				
				//因為table上資料修改後會直接改到實體資料, 因此用checkIDList放入原本的資料
				if(DTDSE180_vo.OPPOSITE_ID == checkIDList[i].OPPOSITE_ID){	
					is_dup = true;					
				}
				//如果沒有重複，就把原本的資料加回來
				DTDSE180_voList.push(Object.clone(checkIDList[i]));
			}
			//如果重複 , 就不做任何事 , 將原本的list載入
			if(is_dup){
				alert('相對人資料重複!');				
			}else{
				//沒重複 , 將資料加入清單 , checkIDList也要加
				checkIDList.push(Object.clone(DTDSE180_vo));
				DTDSE180_voList.push(DTDSE180_vo);
				alert('相對人資料有變更，請於相對人資料輸入完畢後，請按下新增或修改按鈕');
			}
			gridB.load(DTDSE180_voList);*/				
		},
		//刪除相對人
		doDeleteOppositeparty : function(event){
			
			valid1.reset();
			var tempVo = gridB.getCheckedRecord();
			if( tempVo.length == 0  ){
				alert('請先選擇一筆要刪除的資料!');
				return;
			}
			var DTDSE180_vo = tempVo[0];
			var DTDSE180_voList = gridB.getAllRecords();		
		
			//找到List中相同ID的資料
			for ( var i = 0 ; i < DTDSE180_voList.length ; i++){
			
				if(DTDSE180_vo.OPPOSITE_ID == DTDSE180_voList[i].OPPOSITE_ID){					
					checkIDList.splice(i,1);
					//如果只剩一筆,因為還要讓USER加回來 , 所以不刪掉 , 只是將他變成'其他' 供人新增
					if( DTDSE180_voList.length == 1){						
						DTDSE180_voList[i].OPPOSITE_ID ='';
						DTDSE180_voList[i].OPPOSITE_NAME ='';
						DTDSE180_voList[i].OPPOSITE_STS ='';						
					}else{						
					//如果不止一筆 , 就將資料從LIST中刪除
						DTDSE180_voList.splice(i,1);
					}
					break;
				}				
			}			
			
			gridB.load(DTDSE180_voList);
			alert('相對人資料有變更，請於相對人資料輸入完畢後，請按下新增或修改按鈕');
		},
		//擔保品門牌異動
		doChangeHostageNo : function(event){
			
			valid1.reset();
			valid3.reset();
			if(!valid2.validate()){
				return;
			}
		
			var GAGE_ADDR_REORG = $('GAGE_ADDR_REORG').value;			
		
			//發送ajax
			ajaxPost( 'changehostage' , { 
					GAGE_ADDR_REORG : GAGE_ADDR_REORG,
					LOAN_ID : '${LOAN_ID}'	
				},function(resp){
					var E010Map = resp.E10Map;
					$('GAGE_ADDR').innerHTML = E010Map['GAGE_ADDR'];
					$('GAGE_ADDR_REORG').value = E010Map['GAGE_ADDR_REORG']; 
				
										
				}
						
			);			
			
		},
		//所有權人異動
		doChangeOwner: function(event){						
			
			var chkData_F = gridF.getCheckedRecord();
			
			if(chkData_F.length == 0){		
				alert("請先勾選要保留的資料!");
				return;
			}
			
			valid1.reset();	
			valid2.reset();		
			if(!valid3.validate()){
				return;
			}
			
			var chkData_OWNER_ID = gridF.getCheckedRecord(['OWNER_ID']);
			
			//已勾選ID重複要重新輸入
			for(var i = 0;i < chkData_OWNER_ID.length;i++){
						
				var count = 0;				
				for(var j = 0;j < chkData_OWNER_ID.length;j++){	
				
					if(chkData_OWNER_ID[i].OWNER_ID  == chkData_OWNER_ID[j].OWNER_ID){								
						count =count+1;						
					}			
				}				
				if(count==2){
					alert("ID重複，請重新輸入!");
					return;
				}
			}		
			var ischecked = false;			
			if(E103_mapList){
				var i=1;				
				var E103_mapListlength = E103_mapList.length || 0 ;
				
				$$('#gridF input[type ="checkbox"]').each(					
					function(elem){						
						if(!elem.checked & i!=E103_mapListlength){
							ischecked = true;																	
						}
						i++;
					}		
				)

			}
			
			if(ischecked && !confirm('未勾選資料在異動後將被移除，請確認!')){
				return;			
			}
			var E103_mapListlast = gridF.getCheckedRecord();		
			//發送ajax
			ajaxPost( 'changeowner' , { 
					E103_mapList : Object.toJSON(E103_mapListlast),
					LOAN_ID : '${LOAN_ID}'	
				},function(resp){
					var E103_mapList = resp.E103_mapList || [];
					var initinsertMapF = { 
							LOAN_ID : LOAN_ID , 
							INPUT_DATE : '',
							INPUT_ID : '',		
							OWNER_ID : '' , 
							OWNER_IDOLD : '',
							OWNER_NAME : '' , 
							CON_ADDR : '' ,
							MEMO : ''												
					}
					E103_mapList.push(initinsertMapF);
					gridF.load(E103_mapList || []);			
				}						
			);			
		},	
		doPrint : function(event){	
			
			var chkData_D1 = gridD1.getCheckedRecord();
			var hasChkData_D2 = false;
			var chkData_D2 = {};
			
			$$("input[name=rtnList2_check]").each(
				function(elem){
					if(elem.checked){
						hasChkData_D2 = true;
						chkData_D2[ elem.value ] = true;
					}			
					
				}
			);			
			var chkData_D1 = gridD1.getCheckedRecord();

			if(chkData_D1.length == 0 && hasChkData_D2 == false){		
				alert("請至少選取一筆資料");
				return;
			}		
				
			var E041_mapList = gridD1.getCheckedRecord();			
			
			RPTUtil.executePrintByLink('print' , {E041_mapList : Object.toJSON(E041_mapList),LOAN_ID : '${LOAN_ID}' , chkData_D2 : Object.toJSON(chkData_D2)}, true );		
		}
		,doBack : function(){
			CSRUtil.linkBack();
		}
	};
		
		
	return{
		initApp:function(){	

			PageUI.createPageWithAllBodySubElement("DSE11210", "法務作業", "拍賣抵押物裁定作業" , 1);	
				
				//gridB
				gridB = new TableUI({
					table: $('gridB'),allSortable:false,overDiv:false,
								  autoCheckBox:{text:'選取',
								  type:'radio'
								  },
					<%-- [20240207] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [										
							{header: '相對人' , key : 'OPPOSITE_ID', attrs:{width:'90%'},
								
								render : function (rec , val){
									
									//製作相對人下拉選單
									var SELECT = actions.makeElement('select','', '');	
									
									//檢查是否在相對人下拉選單內									
									var is_other = true;															
																		
									for(var i = 0 ; i < OPPOSITE_List.length ; i++){
										if(OPPOSITE_List[i].ID == val){							
											is_other = false;
											break;
										}										
									}
									
									//如果沒有在下拉選單
									if(is_other){
										var SPAN = new Element('SPAN' );
										//創兩個input , ID跟NAME
										var INPUT_ID = actions.makeElement('input','OPPOSITE_ID', rec.OPPOSITE_ID);		
										var INPUT_NAME = actions.makeElement('input','OPPOSITE_NAME', rec.OPPOSITE_NAME);											
										SPAN.insert(SELECT).insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
										return SPAN;
									
									}
									//將值放到下拉選單
									SELECT.value = val;
									return SELECT;							
								}
							}	
					]		 									
				});
				//gridC
				gridC = new TableUI({
					table: $('gridC'),  pageSize: 20, allSortable: false,
								        autoCheckBox:{text:'選取',
								        type:'radio',
								        action: function(elem, status, data){
											var record = data[0];  
											//回傳選取的詳細清單
											actions.showDetailList(record);	
										}	
								  },
					<%-- [20240207] 難字調整 --%>
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [	
								{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
								{header: '聲請日期' , key : 'APPLY_DATE',  groupKey : ['SEQ_NO'],
									render : function(rec , val){
										return val ? Date.toInputROC( val ,"/") : '';							
									}
								},
								{header: '確定日期' , key : 'CERTAIN_DATE',  groupKey : ['SEQ_NO'],
									render : function(rec , val){
										return val ? Date.toInputROC( val ,"/") : '';			
									}
								},
								<%-- [20240207] 難字調整：相對人 --%>
								{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},							
								{header: '法院' , key : 'COURT_CODE_NM',  groupKey : ['SEQ_NO']},
								{header: '案號' , key : 'CASE_NO', groupKey : ['SEQ_NO']},
								{header: '公示送達' , key : 'IS_SEND', groupKey : ['SEQ_NO'] ,
									render : function (rec , val){	
										return new Element('INPUT' , { type : 'checkbox' , value : val} );
									}							
								},
								{header: '確定' , key : 'IS_CERTAIN', groupKey : ['SEQ_NO'] ,
									render : function (rec , val){	
										return new Element('INPUT' , { type : 'checkbox' , value : val} );									
									}		
								}
							],
							afterLoad:function(){
								var checks = $('gridC').select("input[type=checkbox]");
								
								for( var i = 0 ; i < checks.length ; i = i + 1 ){
									checks[i].disabled =true;
									if(checks[i].value == '1'){
										checks[i].checked = true;
									}
								}

								<%-- [20240207] 難字調整 --%>
								if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
							}	
				});
				
				//gridD1
				gridD1 = new TableUI({
					table: $('gridD1'), allSortable: false, split: ['LAND_CITY'],
								  autoCheckBox:{isSelectAll:true },
					<%-- [20240207] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [	
								{header: '土地座落' , attrs:{colSpan:5} },
								{header: '地目' , key : 'LAND_POS', attrs:{rowSpan:2} },							
								{header: '面積<br>(單位:平方公尺)', key : 'LAND_MEASURE', attrs:{rowSpan:2} },			
								{header: '設定權利範圍' , key : 'LAND_HOLD', attrs:{rowSpan:2},
										render : function(record , value){
											return (record.HOLD_BASE || '')  +"分之"+(record.HOLD_UP || '');						
										}								
								},							
								<%-- [20240207] 難字調整：所有權人 --%>
								{header: '所有權人' , key : 'OWNER', attrs:{rowSpan:2,style:"font-family:'EUDC'"},
										render : function(record , value){
											return (record.OWNER_ID || '') +"<br>"+(record.OWNER_NAME || '');						
										}	

								},
								{header: '備考' , key : 'MEMO', attrs:{rowSpan:2} },
								{header: '查詢日期' , key : 'INPUT_DATE', attrs:{rowSpan:2}, 
									render : function(rec , val){
										return  Date.toInputROC( val || "" ,"/")						
									}
								},
								{header: "縣市" , key:'LAND_CITY'},     
								{header: "鄉鎮市區" , key:'LOCATION1'},
								<%-- [20240207] 難字調整：段 --%>
								{header: "段" , key:'LOCATION2', attrs:{ style:"font-family:'EUDC'" }},     
								{header: "小段" , key:'LOCATION3'},
								{header: "地號" , key:'LAND_NO',
										render : function(record , value){
											return (record.LAND_NO1 || '') +"-"+(record.LAND_NO2 || '');								
										}								
								}	
							]							
				});

				//gridF
				gridF = new TableUI({
					table: $('gridF'), pageSize: 20, allSortable: false, overDiv: false,autoCheckBox:{isSelectAll:true },
					<%-- [20240207] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: [
								<%-- [20240207] 難字調整：姓名 --%>
								{header: '姓名' , key : 'OWNER_NAME',
									render : function( rec , val){								
									
										var input_name = new Element("input" , {type : 'TEXT',size:8,maxlength:8 ,className:'OWNER_NAME_Required', alt:'ch'} );										
									
										input_name.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || gridF.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.OWNER_NAME = event.target.value;
									    });
										input_name.value=val;
										var span = new Element('span');									
										span.insert(input_name);
										return span;  
									}
							
								},    
								{header: 'ID' , key : 'OWNER_ID',
									render : function( rec , val){		
										var input_id = new Element("input" , {id:'OWNER_ID', type : 'TEXT',size:12,maxlength:12 ,className:'OWNER_ID_Required checkID_ROC'} );										
									
										input_id.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || gridF.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.OWNER_ID = event.target.value;
									    });
										input_id.value=val;
										var span = new Element('span');									
										span.insert(input_id);
										return span; 
									}	
										
								},
								<%-- [20240207] 難字調整：住址 --%>
								{header: '住址' , key : 'CON_ADDR',
									render : function( rec , val){		
										var CON_ADDR = new Element("input" , {id:'CON_ADDR',type : 'TEXT',size:20,maxlength:15 ,className:'CON_ADDR_Required validateFullType_ADDR', alt:'ch'} );										
									
										CON_ADDR.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || gridF.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.CON_ADDR = event.target.value;
									    });
										CON_ADDR.value=val;
										var span = new Element('span');									
										span.insert(CON_ADDR);
										return span; 
									}								
								}, 	

								{header: '備考' , key : 'MEMO',
									render : function(rec, val) {
										var TextArea = new Element("TextArea",{id:'MEMO'});										
										
										TextArea.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || gridF.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.MEMO = event.target.value;
									    });
										TextArea.value = val ||'';										
										return TextArea;
									}	
								}		
							]							
				});			
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------					
			
			$('btn_insert').observe( 'click', actions.doInsert);				
			$('btn_update').observe( 'click', actions.doUpdate);		
			$('btn_delete').observe( 'click', actions.doDelete);
			
			$('btn_insert_oppositeparty').observe( 'click', actions.doInsertOppositeparty);	
			$('btn_delete_oppositeparty').observe( 'click', actions.doDeleteOppositeparty);	
			
			$('btn_hostageno_change').observe( 'click', actions.doChangeHostageNo);
			$('btn_owner_change').observe( 'click', actions.doChangeOwner);	
			$('btn_back').observe('click',actions.doBack);			
			$('check_ALL').observe('click', function(event){		
				if($('check_ALL').checked){
					$$('#form2 input[name="rtnList2_check"]').each(					
						function(ele){ele.checked = true;					
					});					
				}else{
					$$('#form2 input[name="rtnList2_check"]').each(					
						function(ele){ele.checked = false;					
					});	
				}				
			});				

			//列印
			$('btn_print').observe('click', function(event){
				actions.doPrint();
			});	
			
							
			actions.doQuery();
			initValidation();
			
			PageUI.resize();
			displayMessage();		

			
		}//end init()--
	};//end return--	
};//end DSE11210
		
</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<div align = "center">
			<tr>
				<td >
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />
					<input id = "btn_back" type = "button" class = "button" value = "回上一頁"/>
				</td>				
			</tr>		
		</div>	
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="8%" align="left">聲請日期</td>
				
				<td class="tbYellow2"  width="12%" align="left">
					<input name="APPLY_DATE" id="APPLY_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "聲請日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('APPLY_DATE'))" /></td>		
				<td class="tbYellow" width="8%" align="left">確定日期</td>
				<td class="tbYellow2" width="12%" align="left">
					<input name="CERTAIN_DATE" id="CERTAIN_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "確定日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CERTAIN_DATE'))" /></td>	
				<td class="tbYellow" width="6%" align="left" >法院</td>
				<td class="tbYellow2" width="17%" align="left">
					<select name="COURT_CODE" id="COURT_CODE" class="textBox2" fieldName = "法院">
						<option value="">全部
						<c:forEach items="${COURT_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" width="8%" align="left">案號</td>
				
				<td class="tbYellow2">
					<input name="CASE_NO" id="CASE_NO"  type="text" class="textBox2" size="16" fieldName = "案號"/>
				</td>
				<td class="tbYellow" width="6%" align="left">公示送達</td>
				
				<td class="tbYellow2">
					<input name="IS_SEND" id="IS_SEND"  type="checkbox" class="textBox2" fieldName = "公示送達"/>
				</td>
				<td class="tbYellow" width="6%" align="left">確定</td>
				<td class="tbYellow2">
					<input name="IS_CERTAIN" id="IS_CERTAIN"  type="checkbox" class="textBox2" fieldName = "確定"/>
				</td>
			</tr>			
		</table>
		<table id = "gridB" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_oppositeparty" type = "button" class = "button" value = "新增相對人"/>	
					<input id = "btn_delete_oppositeparty" type = "button" class = "button" value = "移除相對人"/>	
				</td>
			</tr>			
		</table>	
		<table id = "gridC"></table>
	</form>
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center">
					<input id = "btn_print" type = "button" class = "button" value = "列印附表"/>						
				</td>				
			</tr>	
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>			
				<td class="tbYellow0" align="center" colspan="10"><b>附表-土地資料</b></td>				
			</tr>	
		</table>		   
		<table id = "gridD1"></table>
		<table id="table_D2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
            <tr>
				<td class="tbYellow0" align="center" colspan="10"><b>附表-建物資料</b></td>
			</tr>
			<tr>
				<td class="tbBlue" align="center"  rowspan = '2'>
					<input id="check_ALL" type="CHECKBOX" name="check_ALL"/><BR>
					<b>選取</b>
				</td>
				<td class="tbBlue" align="center" rowspan = '2'><b>建號</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>基地座落</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>建物門牌</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>建築式樣<br>主要建築材料<br>房屋樓層</b></td>
				<td class="tbBlue" align="center" colspan = '2'><b>建物面積(單位:平方公尺)</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>權利範圍</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>所有權人</b></td>
				<td class="tbBlue" align="center" rowspan = '2'><b>查詢日期</b></td>
			</tr>
			<tr>
				<td class="tbBlue" align="center" ><b>樓層面積</b></td>
				<td class="tbBlue" align="center" ><b>附屬建物</b></td>
			</tr>
			
		    <c:forEach var="dataMap" items="${rtnList2}" varStatus="status">
			
			<tr class="tbYellow2<c:if test="${status.count%2 == 1}"> tbBlue3</c:if>">
					<td width="5%" align="center" <c:if test="${not empty dataMap.OTHER_DATA}">rowspan='3'</c:if>>
						<input id="check" type="CHECKBOX" name="rtnList2_check" value="${status.index}"/>
					</td>
					<td width="7%" align="center">
						<span align="left" >${dataMap.BUILD_NO1}-${dataMap.BUILD_NO2} </span>
					</td>					
					<td width="7%" align="center">
						<c:forEach var="LAND_DATA" items="${dataMap.LAND_DATA}">
							<span align="left" >${LAND_DATA}<br></span>		
						</c:forEach>			
					</td>
					<td width="15%" align="center">
						<span align="left" >${dataMap.ADDR_NO}</span>
					</td>
					<td width="7%" align="center">
						<span align="left" >${dataMap.MIX_DATA}</span>
					</td>
					<td width="7%" align="center">
						<c:forEach var="CELL_DATA" items="${dataMap.CELL_DATA}">
							<span align="left" >${CELL_DATA}<br></span>		
						</c:forEach>			
					</td>
					<td width="7%" align="center">
						<c:forEach var="ITEM_DATA" items="${dataMap.ITEM_DATA}">									
								<span align="left" >${ITEM_DATA}<br></span>						
						</c:forEach>			
					</td>
					<td width="7%" align="center">
						<span align="left" >${dataMap.BUILD_HOLD_DATA}</span>
					</td>
					<td width="7%" align="center">
						<%-- [20240207] 難字調整：所有權人 --%>
						<span align="left" style="font-family:'EUDC'">${dataMap.OWNER_ID}<br>${dataMap.OWNER_NAME}</span>
					</td>
					<td width="7%" align="center" <c:if test="${not empty dataMap.OTHER_DATA}">rowspan='3'</c:if>>
						<span align="left" >${dataMap.INPUT_DATE}</span>
					</td>
				</tr>
				<c:if test="${not empty dataMap.OTHER_DATA}">
				<tr class="tbYellow<c:if test="${status.count%2 == 1}"> tbBlue</c:if>">
					<td align="center" colspan='8'><b>共同使用部分</b></td>
				</tr>
				<tr class="tbYellow2<c:if test="${status.count%2 == 1}"> tbBlue3</c:if>">	
					<td width="7%" align="left" colspan='8'>
						<c:forEach var="OTHER_DATA" items="${dataMap.OTHER_DATA}">
							<span align="left" >${OTHER_DATA}<br></span>		
						</c:forEach>			
					</td>
				</tr>
				</c:if>
				
		  </c:forEach>
		</table>
	</form>
	<form id="form3" name="form3" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">		
		<table id="table_E" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center" colspan="2">
					<input id = "btn_hostageno_change" type = "button" class = "button" value = "擔保品門牌異動"/>						
				</td>				
			</tr>
            <tr>
				<td class="tbYellow0" align="center" colspan="2"><b>擔保品門牌</b></td>
			</tr>
			<tr>
				
				<td class="tbBlue" width="5%" align="left"><b>門牌:</b></td>							
				<td class="tbYellow2" width = "45%">				 
					<%-- [20240207] 難字調整：門牌 --%>
					<span id="GAGE_ADDR" style="font-family:'EUDC'"/>
				</td>
				 
			</tr>
			<tr>				
				<td class="tbBlue" width="5%" align="left"><b>門牌整編:</b></td>				
				<td class="tbYellow2" width = "45%">
					<%-- [20240207] 難字調整：門牌整編 --%>
					<input id="GAGE_ADDR_REORG" type="text" class="textBox2" size="50" alt="ch" />
				</td>			
			</tr>
		</table>
	</form>	
	<form id="form4" name="form4" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center">
					<input id = "btn_owner_change" type = "button" class = "button" value = "所有權人異動"/>						
				</td>				
			</tr> 
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>			
				<td class="tbYellow0" align="center" colspan="10"><b>所有權人</b></td>				
			</tr>	
		</table>
		<table id = "gridF"></table>
	</form>
</body>
</html>