<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11212.jsp
作者：張智翔
功能：支付命令作業。
完成：2013/5/3

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
var DSE11212 = new DSE11212();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSE11212.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11212(){
	
	//貸款帳號
	var LOAN_ID = '${LOAN_ID}';
	
	var checkIDList =[];
	
	//狀態下拉選單
	var OPPOSITE_STS_List;
	
	//相對人下拉選單
	var OPPOSITE_List;
	
	//Table UI
	var grid;	
	var grid1;	
	
	//檢核
	var valid1;		

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
			[ 'chkADJ_DATE', '確認日期需大於等於聲請日期', function() { return chkADJ_DATE($('APPLY_DATE'), $('CERTAIN_DATE'));}]
			
		]);			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
		
	}
	function defineValidation(btnName){
		valid1.reset();
		valid1.clear();
		valid1.define( "required" , { id: "APPLY_DATE"  } );	
		valid1.define( "checkAfterToday" , { id: "APPLY_DATE"  } );
		valid1.define( "required" , { id: "COURT_CODE"  } );	
		valid1.define( "required" , { id: "CASE_NO"  } );

		<%--新增、修改button--%>
		if(btnName == 'btn_insert' || btnName == 'btn_update'){
			var OPPOSITE_STS = $F('OPPOSITE_STS');
			<%--狀態為死亡(2)、異議(3)、無法送達(4)時不必檢核確定日期是否有輸入--%>
			if(OPPOSITE_STS!='1'){
				if($F('CERTAIN_DATE')){
					valid1.define( "checkAfterToday" , { id: "CERTAIN_DATE"  } );
					valid1.define( "chkADJ_DATE" , {id:"CERTAIN_DATE",errMsg:"確認日期需大於等於聲請日期" } );					
				}
				return;
			}			
		}
		
		valid1.define( "required" , { id: "CERTAIN_DATE"  } );	
		valid1.define( "checkAfterToday" , { id: "CERTAIN_DATE"  } );
		valid1.define( "chkADJ_DATE" , {id:"CERTAIN_DATE",errMsg:"確認日期需大於等於聲請日期" } );		
	}
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert" ,				
				B0004:"btn_update" ,
				B0005:"btn_delete"				
		};
	
		<dz:grantButtons FUNC_ID="DSE11212" />
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

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1212/" + actionName,
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
	
	
	
	//按鈕功能
	var buttons = {
	
		//查詢
		doQuery : function(){	
		
			//發送ajax
			ajaxPost( 'query' , { LOAN_ID : '${LOAN_ID}'},
				function(resp){	
					//將下拉選單內容加到頁面
					OPPOSITE_STS_List = resp.OPPOSITE_STS_List;		
					OPPOSITE_List = resp.OPPOSITE_List||[];
					grid1.load(resp.rtnList || []);		
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();
				},
				function(resp){
					OPPOSITE_STS_List = resp.OPPOSITE_STS_List;	
					OPPOSITE_List = resp.OPPOSITE_List||[];
					grid1.load([]);	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();
				} 
			);				
		},
		
		//新增
		doInsert : function(event){		
			var DTDSE180_voList = grid.getAllRecords();
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			defineValidation(event.target.id);
			if(!valid1.validate()){
				return;
			}
			
			var DTDSE091_vo = grid1.getCheckedRecord()[0] || {};
		
			//將畫面資料取代
			DTDSE091_vo.LOAN_ID = LOAN_ID;
			DTDSE091_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE091_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ; 
			DTDSE091_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE091_vo.CASE_NO = $('CASE_NO').value ; 
						
			//發送ajax
			ajaxPost( 'insert' , { 
					DTDSE091_vo : Object.toJSON(DTDSE091_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);
					grid1.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();							
				}				
			);	
		},
		
		//修改
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
			
			
			var DTDSE091_vo  = temp[0];
			
			
			defineValidation(event.target.id);
			if(!valid1.validate()){
				return;
			}
		
		
			//將畫面資料取代
			DTDSE091_vo.APPLY_DATE = $('APPLY_DATE').value ; 
			DTDSE091_vo.CERTAIN_DATE = $('CERTAIN_DATE').value ; 
			DTDSE091_vo.COURT_CODE = $('COURT_CODE').value ; 
			DTDSE091_vo.CASE_NO = $('CASE_NO').value ; 
			
			//發送ajax
			ajaxPost( 'update' , { 
					DTDSE091_vo : Object.toJSON(DTDSE091_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);	
					grid1.resetDivHeight();	
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();									
				}				
			);	
		
		
		},
		
		//刪除
		doDelete : function(event){
			var temp = grid1.getCheckedRecord();
			
			if(temp.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE091_vo  = temp[0];
		
			//發送ajax
			ajaxPost( 'delete' , { 
					DTDSE091_vo : Object.toJSON(DTDSE091_vo)					
				},
				function(resp){		
					$('form').reset();
					grid1.load(resp.rtnList || []);	
					grid1.resetDivHeight();					
					//初始的Map , 讓一開始什麼都沒有的都可以新增
					actions.initGrid();										
				}				
			);	
		
		
		},
		
		//下層的新增
		doInsertUnder : function(event){
			valid1.reset();
			var DTDSE180_voList = grid.getAllRecords();
			var map=DTDSE180_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.OPPOSITE_ID='';
			tmpMap.OPPOSITE_NAME='';
			DTDSE180_voList.push(tmpMap);
			grid.load(DTDSE180_voList);
			
			/*
			var tempVo = grid.getCheckedRecord();
			if( tempVo.length == 0  ){
				alert('請先選擇一筆要新增的資料!');
				return;
			}
			var DTDSE180_vo = tempVo[0];
			//全部的資料			
			var DTDSE180_voList = grid.getAllRecords();		
			//因為一修改上面的資料就直接改掉了，因此先把資料內容清光
			DTDSE180_voList = [];
			
			//使用一個boolean放入 是否要新增的資料有重複
			var is_dup = false;
			for ( var i = 0 ; i < checkIDList.length ; i++){
				//因為table上資料修改後就回直接改到實體資料, 因此用一個List  checkIDList放入原本的資料
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
			grid.load(DTDSE180_voList);
			*/
		},		
		
		//下層的刪除
		doDeleteUnder : function(event){
			valid1.reset();
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
			alert('相對人資料有變更，請於相對人資料輸入完畢後，請按下新增或修改按鈕');
		}
		,doBack : function(){
			CSRUtil.linkBack();
		}
		
	}
	
	//各種action
	var actions = {				
		initGrid : function(){
			//初始的Map , 讓一開始什麼都沒有的都可以新增
			var iniinsertMap = [{ 	
				LOAN_ID : LOAN_ID , 
				CASE_KIND : '0' , 
				SEQ_NO : '1' ,
				OP_TYPE : '091'
			}]
		
			grid.load(iniinsertMap);		
		
		},
		
		//將資料放入table A
		showGridDate : function(rec){
			var DTDSE180_voList = rec.DTDSE180_voList;
			
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
					{ 	LOAN_ID : LOAN_ID , 
						CASE_KIND : rec.CASE_KIND , 
						SEQ_NO : rec.SEQ_NO ,
						OP_TYPE : '091'
					}
				);
				
			}
			//載入list
			grid.load(temp);
			//將資料放入A區塊			
			$('APPLY_DATE').value = toROC(rec.APPLY_DATE||'') ;  
			$('CERTAIN_DATE').value = toROC(rec.CERTAIN_DATE||'') ;
			$w('COURT_CODE CASE_NO').each(
				function(elem){						
					$(elem).value = rec[elem];				
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
					var dataObj =  tr.dataObj ||grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					
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
						grid.resetDivHeight();
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
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
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

				PageUI.createPageWithAllBodySubElement("DSE11212", "法務作業", "支付命令作業" , 1);	
				
				//table A
				grid = new TableUI ( {
					table: $('grid'),  allSortable:false,overDiv:false,
					autoCheckBox:{						
						type :"radio" 
					},		
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
							
							},
							{header: '狀態' , key : 'OPPOSITE_STS',
								render : function (rec , val){
									var SELECT = new Element('SELECT' , {className : 'textBox2 required' , fieldName : '狀態', id : 'OPPOSITE_STS'});
									var option = new Element('OPTION' , { value : ''}).update("請選擇");
									SELECT.insert(option);
									//加入狀態下拉選單
									for (key in OPPOSITE_STS_List){
										SELECT.add(new Option(OPPOSITE_STS_List[key], key));
									}
									//如果改下拉選單，直接將TABLE內的值改掉
									SELECT.observe('change' , function(event){
											var tr = this.up('tr');
											var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.OPPOSITE_STS = event.target.value;												
										}
									);
									SELECT.value = val;
																
									return SELECT;
								}
							}						
						]			
				});	
				
				//table B
				grid1 = new TableUI ( {
					table: $('grid1'),  allSortable:false, pageSize: 10, 
					autoCheckBox:{					
						type :"radio" , 
						disableRule : function(rec){
						//	if(rec.CASE_KIND != '0'){
						//		return true;
						//	}
							return false;
						},
						action: function(checkbox , boxStatus , records) {
							//連動將資料帶入TableA
							actions.showGridDate(records[0]);
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
						//	{header: '案件種類' , key : 'CASE_KIND_NM' , groupKey : ['SEQ_NO']},
							{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
							{header: '聲請日期' , key : 'APPLY_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return Date.toInputROC( val || "" ,"/")							
								}
							},
							{header: '確定日期' , key : 'CERTAIN_DATE',  groupKey : ['SEQ_NO'],
								render : function(rec , val){
									return  Date.toInputROC( val || "" ,"/")						
								}
							},
							<%-- [20240207] 難字調整：相對人 --%>
							{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
							{header: '狀態' , key : 'OPPOSITE_STS',
								render : function(rec , val){								
									return OPPOSITE_STS_List[val] || '';
								
								}
							},
							{header: '法院' , key : 'COURT_CODE_NM',  groupKey : ['SEQ_NO']},
							{header: '案號' , key : 'CASE_NO', groupKey : ['SEQ_NO']}						
						]
									
				});	
				//click事件
				$('btn_insert').observe( 'click', buttons.doInsert);				
				$('btn_update').observe( 'click', buttons.doUpdate);		
				$('btn_delete').observe( 'click', buttons.doDelete);		
				$('btn_insert_under').observe( 'click', buttons.doInsertUnder);		
				$('btn_delete_under').observe( 'click', buttons.doDeleteUnder);		
				$('btn_back').observe('click',buttons.doBack);
				
				fix();

				displayMessage();	
				
				initValidation();		

				buttonAuth();
				
				buttons.doQuery();				
				
			}
	};
};

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
	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbYellow" width="8%" align="left" >
					聲請日期
				</td>
				<td class="tbYellow2" >
					<input name="APPLY_DATE" id="APPLY_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "聲請日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('APPLY_DATE'))" /></td>		
				<td class="tbYellow" width="8%" align="left" >
					確定日期
				</td>
				<td class="tbYellow2" >
					<input name="CERTAIN_DATE" id="CERTAIN_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "確定日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CERTAIN_DATE'))" /></td></td>	
				<td class="tbYellow" width="6%" align="left" >
					法院
				</td>
				<td class="tbYellow2" >
					<select name="COURT_CODE" id="COURT_CODE" class="textBox2" fieldName = "法院">
						<option value="">全部
						<c:forEach items="${COURT_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					案號
				</td>
				<td class="tbYellow2">
					<input name="CASE_NO" id="CASE_NO"  type="text" class="textBox2" fieldName = "案號"/>
				</td>
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
</body>
</html>