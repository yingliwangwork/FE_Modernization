<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11204.jsp
作者：卓達瑋
功能：保全程序作業
完成：2013/08/05

[20240207]
難字調整
高強禾
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>


<!--匯入外部Javascript 與 css-->

<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
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
<script type='text/javascript'>

// 產生畫面物件
var DSE11204 = new DSE11204();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSE11204.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11204(){
	
	//貸款帳號
	var LOAN_ID = '${LOAN_ID}';
	
	var checkIDList =[];	
	
	//相對人下拉選單
	var OPPOSITE_List;  //保全裁定
	var OPPOSITE_List2;  //保全執行
	
	//Table UI
	var grid;   //保全裁定(相對人)	
	var grid1;	//保全裁定
    var grid2;	//保全執行(相對人)	
	var grid3;	//保全執行
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
				function(v){ 
					var today = getToday();					
					if(  diffDay(today, v) > 0 ){
						return false;					
					}
					return true;
				}
			],
			[ 'checkCERTAIN_DATE',  '裁定日期不可小於聲請日期!',
				function(v){ 
					var today = getToday();					
					if(  diffDay(v, $('APPLY_DATE').value) > 0 ){
						return false;					
					}
					return true;
				}
			],
			[ 'checkDRAW_DATE',  '提存日期不可小於裁定日期!',
				function(v){ 
					var today = getToday();					
					if(  diffDay(v, $('CERTAIN_DATE').value) > 0 ){
						return false;					
					}
					return true;
				}
			],
			[ 'checkBACK_DATE',  '取回日期不可小於提存日期!',
				function(v){ 
					var today = getToday();					
					if(  diffDay(v, $('DRAW_DATE').value) > 0 ){
						return false;					
					}
					return true;
				}
			]
			
		]);
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define( "required" , { id: "APPLY_DATE"  } );	
		valid1.define( "checkAfterToday" , { id: "APPLY_DATE"  } );
		valid1.define( "checkAfterToday" , { id: "CERTAIN_DATE"  } );	
		valid1.define( "checkCERTAIN_DATE" , { id: "CERTAIN_DATE"  } );	
		valid1.define( "checkDRAW_DATE" , { id: "DRAW_DATE"  } );	
		valid1.define( "checkBACK_DATE" , { id: "BACK_DATE"  } );		
		valid1.define( "required" , { id: "COURT_CODE" ,errMsg : '請選擇法院!' } );	
		valid1.define( "required" , { id: "CASE_NO" ,errMsg : '請輸入案號!' } );	
        valid1.define( "required" , { id: "SEC_TYPE" ,errMsg : '請選擇種類!' } );			
		
		valid2 = new Validation("form2", { focusOnError:true, immediate:false , mode : 'validator'});
		valid2.define( "required" , { id: "APPLY_DATE2"  } );	
		valid2.define( "checkAfterToday" , { id: "APPLY_DATE2"  } );
		valid2.define( "required" , { id: "COURT_CODE2"  ,errMsg : '請選擇法院!'} );	
		valid2.define( "required" , { id: "CASE_NO2" ,errMsg : '請輸入案號!' } );
		valid2.define( "required" , { id: "TARGET" ,errMsg : '請輸入執行標的!' } );			
	}
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {
				B0003:["btn_insert","btn_insert2"] ,		
				B0004:["btn_update" ,"btn_update2"],
				B0005:["btn_delete"	,"btn_delete2"]
		};
		<dz:grantButtons FUNC_ID="DSE11204" />
	}
	
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1204/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	
	
	//按鈕功能
	var buttons = {
	
		//查詢(保全裁定)
		doQuery : function(){	
		
			//發送ajax
			ajaxPost( 'query' , { LOAN_ID : '${LOAN_ID}'},
				function(resp){	
					//將下拉選單內容加到頁面					
					OPPOSITE_List = resp.OPPOSITE_List||[];
					grid1.load(resp.rtnList || []);			
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid('112',grid);
				},
				function(resp){					
					OPPOSITE_List = resp.OPPOSITE_List||[];
					grid1.load([]);	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid('112',grid);

				}
			);				
		},
		//查詢(保全執行)
		doQuery2 : function(){	
		
			//發送ajax
			ajaxPost( 'query2' , { LOAN_ID : '${LOAN_ID}'},
				function(resp){	
					//將下拉選單內容加到頁面					
					OPPOSITE_List2 = resp.OPPOSITE_List2||[];
					grid3.load(resp.rtnList2 || []);			
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid('113',grid2);
				},
				function(resp){					
					OPPOSITE_List2 = resp.OPPOSITE_List2||[];
					grid3.load([]);	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid('113',grid2);

				}
			);				
		},
		//新增(保全裁定)
		doInsert : function(event){		
			var DTDSE180_voList = grid.getAllRecords();
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			if(!valid1.validate()){
				return;
			}
			
			var DTDSE112_vo = grid1.getCheckedRecord()[0] || {};
		
			//將畫面資料取代
			DTDSE112_vo.LOAN_ID = LOAN_ID;
			DTDSE112_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE112_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ; 
			DTDSE112_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE112_vo.CASE_NO = $('CASE_NO').value ;
            DTDSE112_vo.SEC_TYPE = $('SEC_TYPE').value ;			
		    DTDSE112_vo.DRAW_DATE = $('DRAW_DATE').value ; 
            DTDSE112_vo.BACK_DATE = $('BACK_DATE').value ; 	
      	
			//發送ajax
			ajaxPost( 'insert' , { 
					DTDSE112_vo : Object.toJSON(DTDSE112_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);
					grid1.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("112",grid);							
				}				
			);	
		},
		
		//修改(保全裁定)
		doUpdate : function(event){
		
			var temp = grid1.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇要修改資料!');
				return;
			
			}
			
			var DTDSE180_voList = grid.getAllRecords();
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			
			var DTDSE112_vo  = temp[0];
			
			
			if(!valid1.validate()){
				return;
			}
		    
		
			//將畫面資料取代
			DTDSE112_vo.LOAN_ID = LOAN_ID;
			DTDSE112_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE112_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ; 
			DTDSE112_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE112_vo.CASE_NO = $('CASE_NO').value ; 
		    DTDSE112_vo.DRAW_DATE = $('DRAW_DATE').value ; 
            DTDSE112_vo.BACK_DATE = $('BACK_DATE').value ; 			
			DTDSE112_vo.SEC_TYPE = $('SEC_TYPE').value ;
			//發送ajax
			ajaxPost( 'update' , { 
					DTDSE112_vo : Object.toJSON(DTDSE112_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);	
					grid1.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("112",grid);									
				}				
			);	
		
		
		},
		
		//刪除(保全裁定)
		doDelete : function(event){
			var temp = grid1.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE112_vo  = temp[0];
			var DRAW_DATE = DTDSE112_vo.DRAW_DATE;
			
			if(DRAW_DATE){
				if(!confirm('系統會將保全執行資料一併刪除，是否確定刪除?')){
					return;
				}			
			}
			//發送ajax
			ajaxPost( 'delete' , { 
					DTDSE112_vo : Object.toJSON(DTDSE112_vo)					
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);	
					grid1.resetDivHeight();					
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("112",grid);										
				}				
			);	
		
		
		},
		//新增(保全執行)
		doInsert2 : function(event){		
			var DTDSE180_voList2 = grid2.getAllRecords();
			if(DTDSE180_voList2.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			if(!valid2.validate()){
				return;
			}
			
			var DTDSE113_vo = grid3.getCheckedRecord()[0] || {};
		
			//將畫面資料取代
			DTDSE113_vo.LOAN_ID = LOAN_ID;
			DTDSE113_vo.APPLY_DATE = $('APPLY_DATE2').value ; 
			DTDSE113_vo.COURT_CODE = $('COURT_CODE2').value ; 
			DTDSE113_vo.CASE_NO = $('CASE_NO2').value ;		
            DTDSE113_vo.TARGET = $('TARGET').value ; 	

			//發送ajax
			ajaxPost( 'insert2' , { 
					DTDSE113_vo : Object.toJSON(DTDSE113_vo),
					DTDSE180_voList2 : Object.toJSON(DTDSE180_voList2)
				},
				function(resp){		
					$('form2').reset();
					grid3.load(resp.rtnList2 || []);
					grid3.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("113",grid2);							
				}				
			);	
		},
		//修改(保全執行)
		doUpdate2 : function(event){
		
			var temp = grid3.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇要修改資料!');
				return;
			
			}
			
			var DTDSE180_voList2 = grid2.getAllRecords();
			if(DTDSE180_voList2.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			
			var DTDSE113_vo  = temp[0];
			
			
			if(!valid2.validate()){
				return;
			}
		    
		
			//將畫面資料取代
			DTDSE113_vo.LOAN_ID = LOAN_ID;
			DTDSE113_vo.APPLY_DATE = $('APPLY_DATE2').value ; 
			DTDSE113_vo.COURT_CODE = $('COURT_CODE2').value ; 
			DTDSE113_vo.CASE_NO = $('CASE_NO2').value ;		
            DTDSE113_vo.TARGET = $('TARGET').value ; 	
			//發送ajax
			ajaxPost( 'update2' , { 
					DTDSE113_vo : Object.toJSON(DTDSE113_vo),
					DTDSE180_voList2 : Object.toJSON(DTDSE180_voList2)
				},
				function(resp){		
					$('form2').reset();
					grid3.load(resp.rtnList2 || []);	
					grid3.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("113",grid2);									
				}				
			);	
		
		
		},
		//刪除(保全執行)
		doDelete2 : function(event){
			var temp = grid3.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE113_vo  = temp[0];
		
			//發送ajax
			ajaxPost( 'delete2' , { 
					DTDSE113_vo : Object.toJSON(DTDSE113_vo)					
				},
				function(resp){		
					$('form2').reset();
					grid3.load(resp.rtnList2 || []);	
					grid3.resetDivHeight();					
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid("113",grid2);										
				}				
			);	
		
		
		},
		
		//下層的新增(保全裁定)
		doInsertUnder : function(event){
			valid1.reset();
			var DTDSE180_voList = grid.getAllRecords();
			var map=DTDSE180_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.OPPOSITE_ID='';
			tmpMap.OPPOSITE_NAME='';
			DTDSE180_voList.push(tmpMap);		
			grid.load(DTDSE180_voList);
			
			
		},		
		//下層的新增(保全執行)
		doInsertUnder2 : function(event){
			valid1.reset();
			var DTDSE180_voList = grid2.getAllRecords();
			var map=DTDSE180_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.OPPOSITE_ID='';
			tmpMap.OPPOSITE_NAME='';
			DTDSE180_voList.push(tmpMap);		
			grid2.load(DTDSE180_voList);
			
			
		},
		//下層的刪除(保全裁定)
		doDeleteUnder : function(event){
			valid2.reset();
			var tempVo = grid.getCheckedRecord();
			if( tempVo.length == 0  ){
				alert('請先選擇一筆要刪除的資料!');
				return;
			}
			var DTDSE180_vo = tempVo[0];
			var DTDSE180_voList = grid.getAllRecords();		
		
			//找到List中相同ID的資料
			for ( var i = 0 ; i < DTDSE180_voList.length ; i++){
			
				if(DTDSE180_vo.OPPOSITE_ID == DTDSE180_voList[i].OPPOSITE_ID){					
					checkIDList.splice( i,1);
					//如果只剩一筆,因為還要讓USER加回來 , 所以不刪掉 , 只是將他變成'其他' 供人新增
					if( DTDSE180_voList.length == 1){						
						DTDSE180_voList[i].OPPOSITE_ID ='';
						DTDSE180_voList[i].OPPOSITE_NAME ='';
						DTDSE180_voList[i].OPPOSITE_STS ='';						
					}else{						
					//如果不止一筆 , 就將資料從LIST中刪除
						DTDSE180_voList.splice( i,1);
					}
					break;
				}				
			}			
			
			grid.load(DTDSE180_voList);
			alert('保全裁定相對人資料有變更，請於相對人資料輸入完畢後，請於保全裁定區塊按下新增或修改按鈕');
		},
		//下層的刪除(保全執行)
		doDeleteUnder2 : function(event){
			valid2.reset();
			var tempVo = grid2.getCheckedRecord();
			if( tempVo.length == 0  ){
				alert('請先選擇一筆要刪除的資料!');
				return;
			}
			var DTDSE180_vo2 = tempVo[0];
			var DTDSE180_voList2 = grid2.getAllRecords();		
		
			//找到List中相同ID的資料
			for ( var i = 0 ; i < DTDSE180_voList2.length ; i++){
			
				if(DTDSE180_vo2.OPPOSITE_ID == DTDSE180_voList2[i].OPPOSITE_ID){					
					checkIDList.splice( i,1);
					//如果只剩一筆,因為還要讓USER加回來 , 所以不刪掉 , 只是將他變成'其他' 供人新增
					if( DTDSE180_voList2.length == 1){						
						DTDSE180_voList2[i].OPPOSITE_ID ='';
						DTDSE180_voList2[i].OPPOSITE_NAME ='';
						DTDSE180_voList2[i].OPPOSITE_STS ='';						
					}else{						
					//如果不止一筆 , 就將資料從LIST中刪除
						DTDSE180_voList2.splice( i,1);
					}
					break;
				}				
			}			
			
			grid2.load(DTDSE180_voList2);
			alert('保全執行相對人資料有變更，請於相對人資料輸入完畢後，請於保全執行區塊按下新增或修改按鈕');
		}
		
		
	}
	
	//各種action
	var actions = {				
		
		initGrid : function(OP_TYPE_STR,grid){
			//初始的Map , 讓一開始什麼都沒有的都可以新增 
			var iniinsertMap = [{ 	
				LOAN_ID : LOAN_ID , 
				//CASE_KIND : '0' , 
				SEQ_NO : '1' ,
				OP_TYPE : OP_TYPE_STR
			}]
			grid.load(iniinsertMap);		
		},
		
		
		
		//將資料放入table A
		showGridDate : function(rec,str){
			var DTDSE180_voList ;
			var OP_TYPE;
			if(str=='1'){
			    DTDSE180_voList=rec.DTDSE180_voList1;
				OP_TYPE='112';
			}else{
			    DTDSE180_voList=rec.DTDSE180_voList2;	
                OP_TYPE='113';
				
			}
			
			//產生一個物件 Temp , 用來load grid , 因為這樣才不會因為沒copy物件 而改到原始的物件內容
			var temp = new Object([]);
			//用來做check grid 有沒重複id的勿件
			checkIDList = new Object([]);
			//如果List內有資料 , 就將資料一個copy到各List中
			if(DTDSE180_voList.length > 0){
				
				for(var i = 0 ; i < DTDSE180_voList.length ; i ++){
					temp.push(Object.clone(DTDSE180_voList[i]));
					checkIDList.push(Object.clone(DTDSE180_voList[i]));
				}
			}else{
				
				
				//如果沒資料, 就新增一筆其他可以給user新增
				temp.push(
					{ 	'LOAN_ID' : LOAN_ID , 
						//CASE_KIND : rec.CASE_KIND , 
						'SEQ_NO' : rec.SEQ_NO ,
						'OP_TYPE' : OP_TYPE
					}
				);
				
			}
			if(str=='1'){
				//載入list
				grid.load(temp);
				//將資料放入A區塊			
				$w('APPLY_DATE CERTAIN_DATE DRAW_DATE BACK_DATE').each(
					function(elem){						
						$(elem).value = toROC(rec[elem]||'') || '';		
					}			
				);
				$w('COURT_CODE CASE_NO SEC_TYPE').each(
					function(elem){						
						$(elem).value = rec[elem];				
					}			
				);
		    }else {
			    //載入list
				grid2.load(temp);
				//將資料放入D區塊						
				$('APPLY_DATE2').value = toROC(rec['APPLY_DATE']||'') || '';		
                $('COURT_CODE2').value = rec['COURT_CODE'];	
				$('CASE_NO2').value = rec['CASE_NO'];
                $('TARGET').value = rec['TARGET'];					
				
				
			
			}
		}, 
		
		//產生TableUI裡面的select與input欄位(保全裁定)
		makeElement : function(type , inputName , inputValue,str1,grid_1){
			if( type == 'select'){
				//下拉選單欄位
				<%-- [20240207] 難字調整：相對人 --%>
				var SELECT = new Element('SELECT' , {className : 'textBox2' , fieldName : '相對人資訊', alt:'ch' });
				var option = new Element('OPTION' , { value : ''}).update("其他");
				SELECT.insert(option);	
				//放入相對關係人資料到選單中
				var tempList;
				if(str1=="1"){
				    tempList=OPPOSITE_List;
				}else{
				    tempList=OPPOSITE_List2;
				}
				tempList.each(
					function(data) {
						var OPPOSITE_ID = data.ID;
						SELECT.add(new Option(data.NAME, OPPOSITE_ID));					
					}
				);
				//註冊事件
				SELECT.observe('change' , function(event){
					//只要修改上面的資料 , 就改掉實體的資料
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid_1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					
					var targetValue = event.target.value;
					var currentTd = this.up('td');		
					//如果下拉選單沒值,也就是選了'其他' , 就產生ID與NAME欄位
					if( !targetValue){											
						var INPUT_ID = actions.makeElement('input','OPPOSITE_ID', '',str1,grid_1);		
						var INPUT_NAME = actions.makeElement('input','OPPOSITE_NAME', '',str1,grid_1);	
						//產生ID與NAME後,下拉選單就會被檢核出來中
						SELECT.setAttribute( 'className' , 'textBox2');
						//將原本的欄位放入這兩個欄位
						currentTd.insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
						//重設TABLE高度						
						grid_1.resetDivHeight();
						//並且將原本資料內容清掉 , 讓user可以輸入
						dataObj.OPPOSITE_ID = '';
						dataObj.OPPOSITE_NAME = '';
					}else{
						//如果有選值 , 有可能從"其他"變成選有值 , 所以就要將ID跟NAME刪掉, 再重做一個下拉選單加進去
						var SELECT_A = actions.makeElement('select', '' , '',str1,grid_1);
						SELECT_A.value =  targetValue;
						currentTd.update(SELECT_A);	
						dataObj.OPPOSITE_ID = targetValue;
						dataObj.OPPOSITE_NAME = SELECT_A.options[SELECT_A.selectedIndex].text;						
						grid_1.resetDivHeight();
						
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
				if(inputName == 'OPPOSITE_NAME'){				
					INPUT.setAttribute( 'maxLength' , '30');				
					<%-- [20240207] 難字調整：姓名 --%>
					INPUT.setAttribute('alt', 'ch');
				}
				INPUT.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid_1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					//動態將值直接改掉
					if( inputName == 'OPPOSITE_ID'){
						dataObj[inputName] = event.target.value.toUpperCase();
					}else if(inputName == 'OPPOSITE_NAME'){
						dataObj[inputName] = event.target.value;
					}			
				});
				return INPUT;
			}		
		}
		
		
	};
	
	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSE11204", "法務作業", "保全程序作業",1,true);
				//table A
				grid = new TableUI ( {
					table: $('grid'),  allSortable:false,
					autoCheckBox:{						
						type :"radio" 
					},		
					overDiv:false,
					fixedColumns:false,
	                <%-- [20240207] 難字調整 --%>
	                afterLoad: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
	                pageChange: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
					column: [										
							{header: '相對人' , key : 'OPPOSITE_ID',
								render : function (rec , val){
									
									//製作相對人下拉選單
									var SELECT = actions.makeElement('select','', '','1',grid);	
									
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
										var INPUT_ID = actions.makeElement('input','OPPOSITE_ID', rec.OPPOSITE_ID,'1',grid);		
										var INPUT_NAME = actions.makeElement('input','OPPOSITE_NAME', rec.OPPOSITE_NAME,'1',grid);											
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
				
				//table B
				grid1 = new TableUI ( {
					table: $('grid1'),  allSortable:false, pageSize: 10,overDiv:false, 
					autoCheckBox:{					
						type :"radio" , 						
						disableRule : function(rec){
							//if(rec.CASE_KIND != '0'){
							//	return true;
							//}
							return false;
						},
						action: function(checkbox , boxStatus , records) {
							//連動將資料帶入TableA
							actions.showGridDate(records[0],"1");
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
							{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
							{header: '聲請日期' , key : 'APPLY_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return Date.toInputROC( val || "" ,"/")							
								}
							},
							{header: '裁定日期' , key : 'CERTAIN_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return  Date.toInputROC( val || "" ,"/")						
								}
							},
							<%-- [20240207] 難字調整：相對人 --%>
							{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header: '種類' , key : 'SEC_TYPE_NM', groupKey : ['SEQ_NO']},
							{header: '法院' , key : 'COURT_CODE_NM',  groupKey : ['SEQ_NO']},
							{header: '案號' , key : 'CASE_NO', groupKey : ['SEQ_NO']},
                            {header: '提存日期' , key : 'DRAW_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return  Date.toInputROC( val || "" ,"/")						
								}
							},
                            {header: '取回日期' , key : 'BACK_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return  Date.toInputROC( val || "" ,"/")						
								}
							}
							
						]
									
				});	
				//保全執行下的table(相對人)
				grid2 = new TableUI ( {
					table: $('grid2'),  allSortable:false,
					autoCheckBox:{						
						type :"radio" 
					},		
					overDiv:false,
					fixedColumns:false,
	                <%-- [20240207] 難字調整 --%>
	                afterLoad: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
	                pageChange: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
					column: [										
							{header: '相對人' , key : 'OPPOSITE_ID',
								render : function (rec , val){
									
									//製作相對人下拉選單
									var SELECT2 = actions.makeElement('select','', '','2',grid2);	
									
									//檢查是否在相對人下拉選單內									
									var is_other = true;															
																		
									for(var i = 0 ; i < OPPOSITE_List2.length ; i++){
										if(OPPOSITE_List2[i].ID == val){							
											is_other = false;
											break;
										}										
									}
									//如果沒有在下拉選單
									if(is_other){
										var SPAN = new Element('SPAN' );
										//創兩個input , ID跟NAME
										var INPUT_ID = actions.makeElement('input','OPPOSITE_ID', rec.OPPOSITE_ID,'2',grid2);		
										var INPUT_NAME = actions.makeElement('input','OPPOSITE_NAME', rec.OPPOSITE_NAME,'2',grid2);											
										SPAN.insert(SELECT2).insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
										return SPAN;
									
									}
									//將值放到下拉選單
									SELECT2.value = val;
									return SELECT2;
								
								}
							
							}			
						]			
				});	
				
				//保全執行下的table
				grid3 = new TableUI ( {
					table: $('grid3'),  allSortable:false, pageSize: 10, 
					autoCheckBox:{					
						type :"radio" , 
						overDiv:false,
						disableRule : function(rec){
							//if(rec.CASE_KIND != '0'){
							//	return true;
							//}
							return false;
						},
						action: function(checkbox , boxStatus , records) {
							//連動將資料帶入TableA
							actions.showGridDate(records[0],"2");
						}
					},	
					fixedColumns:false,					
	                <%-- [20240207] 難字調整 --%>
	                afterLoad: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
	                pageChange: function() {
	                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	                },
					column: [										
							{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
							{header: '聲請日期' , key : 'APPLY_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return Date.toInputROC( val || "" ,"/")							
								}
							},
							<%-- [20240207] 難字調整：相對人 --%>
							{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header: '法院' , key : 'COURT_CODE_NM',  groupKey : ['SEQ_NO']},
							{header: '案號' , key : 'CASE_NO', groupKey : ['SEQ_NO']},
                            {header: '執行標的' , key : 'TARGET', groupKey : ['SEQ_NO']}
							
						]
									
				});	
				
				
				
				//click事件
				$('btn_insert').observe( 'click', buttons.doInsert);				
				$('btn_update').observe( 'click', buttons.doUpdate);		
				$('btn_delete').observe( 'click', buttons.doDelete);
                $('btn_insert2').observe( 'click', buttons.doInsert2);
                $('btn_update2').observe( 'click', buttons.doUpdate2);					
                $('btn_delete2').observe( 'click', buttons.doDelete2);
 				
				$('btn_insert_under').observe( 'click', buttons.doInsertUnder);		
				$('btn_delete_under').observe( 'click', buttons.doDeleteUnder);	
                $('btn_insert_under2').observe( 'click', buttons.doInsertUnder2);		
				$('btn_delete_under2').observe( 'click', buttons.doDeleteUnder2);					

				
				fix();

				displayMessage();	
				
				initValidation();		
                
				buttonAuth();
				
				buttons.doQuery();
				ajaxRequest.closeSuccMsg();				
				buttons.doQuery2();		
				/*
				//特別處理保全執行按鈕權限
				$('btn_insert2').disable();
				$('btn_update2').disable();
                $('btn_delete2').disable();

				
				if(legal2[0]=="B0005"){
				$('btn_insert2').enable();
				}
				if(legal2[1]=="B0004"){
				$('btn_update2').enable();
				}
				if(legal2[2]=="B0003"){
				$('btn_delete2').enable();
				}
				*/
				
			}
	};
};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
			    <td class="tbYellow0" width="6%" align="center" colspan='14'>
					<b>保全裁定</b>
				</td>

			</tr>
			<tr>
				<td align="center" colspan='14'>
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />	
				</td>				
			</tr>	
			<tr>
				<td class="tbYellow" width="6%" align="left" >
					聲請日期
				</td>
				<td class="tbYellow2" >
					<input name="APPLY_DATE" id="APPLY_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName = "聲請日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('APPLY_DATE'))" /></td>		
				<td class="tbYellow" width="6%" align="left" >
					裁定日期
				</td>
				<td class="tbYellow2" >
					<input name="CERTAIN_DATE" id="CERTAIN_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName = "裁定日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CERTAIN_DATE'))" /></td>	
				<td class="tbYellow" width="4%" align="left" >
					種類
				</td>
				<td class="tbYellow2" >
					<select name="SEC_TYPE" id="SEC_TYPE" class="textBox2" fieldName = "總類">
						<option value="">請選擇
						<c:forEach items="${SEC_KIND_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				
				
				<td class="tbYellow" width="4%" align="left" >
					法院
				</td>
				<td class="tbYellow2" >
					<select name="COURT_CODE" id="COURT_CODE" class="textBox2" fieldName = "法院">
						<option value="">請選擇
						<c:forEach items="${COURT_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" width="4%" align="left" >
					案號
				</td>
				<td class="tbYellow2">
					<input name="CASE_NO" id="CASE_NO"  type="text"  size='15' class="textBox2" fieldName = "案號"/>
				</td>
				<td class="tbYellow" width="6%" align="left" >
					提存日期
				</td>
				<td class="tbYellow2" >
					<input name="DRAW_DATE" id="DRAW_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName = "提存日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DRAW_DATE'))" /></td>		
			    				<td class="tbYellow" width="6%" align="left" >
					取回日期
				</td>
				<td class="tbYellow2" >
					<input name="BACK_DATE" id="BACK_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName = "取回日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BACK_DATE'))" /></td>		
			
				
				
			</tr>			
		</table>
		<table id = "grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_under" type = "button" class = "button" value = "新增相對人"   />	
					<input id = "btn_delete_under" type = "button" class = "button" value = "移除相對人"   />	
				</td>
			</tr>			
		</table>	
		<table id = "grid1"></table>
	</form>	
	
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
			    <td class="tbYellow0" width="6%" align="center" colspan='14'>
					<b>保全執行</b>
				</td>

			</tr>
			<tr>
				<td align="center" colspan='14'>
					<input id = "btn_insert2" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update2" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete2" type = "button" class = "button" value = "刪除"   />	
				</td>				
			</tr>	
			<tr>
				<td class="tbYellow" width="6%" align="left" >
					聲請日期
				</td>
				<td class="tbYellow2" >
					<input name="APPLY_DATE2" id="APPLY_DATE2" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="7" maxlength="7" fieldName = "聲請日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('APPLY_DATE2'))" /></td>		
				
				<td class="tbYellow" width="4%" align="left" >
					法院
				</td>
				<td class="tbYellow2" >
					<select name="COURT_CODE2" id="COURT_CODE2" class="textBox2" fieldName = "法院">
						<option value="">請選擇
						<c:forEach items="${COURT_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" width="4%" align="left" >
					案號
				</td>
				<td class="tbYellow2" >
					<input name="CASE_NO2" id="CASE_NO2"  type="text"  size='15' class="textBox2" fieldName = "案號"/>
				</td>
				<td class="tbYellow" width="6%" align="left" >
					執行標的
				</td>
				<td class="tbYellow2">
					<input name="TARGET" id="TARGET"  type="text"  size='15' class="textBox2" fieldName = "執行標的"/>
				</td>
			</tr>			
		</table>
		<table id = "grid2" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_under2" type = "button" class = "button" value = "新增相對人"   />	
					<input id = "btn_delete_under2" type = "button" class = "button" value = "移除相對人"   />	
				</td>
			</tr>			
		</table>	
		<table id = "grid3"></table>
	</form>	
	
</body>
</html>