<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11211.jsp
功能：實體訴訟作業
作者：徐麗雲
完成：2013/05/10

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


Event.observe(window, 'load', new DSE11211().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11211(){
	
	var valid1; //畫面檢核物件	
	var LOAN_ID = '${LOAN_ID}';//貸款帳號
	var OPPOSITE_STS_List;//狀態下拉選單
	var OPPOSITE_List;//相對人下拉選單
	var grid;	
	var grid1;
	var oriList=[];
	
	function initValidation(){
		//檢核
		Validation.addAllThese([
			[ 'checkID',  '身份證字號格式錯誤',
				function(v){  
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v );
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
			[ 'chkADJ_DATE', '確認日期需大於等於聲請日期', function() { return chkADJ_DATE($('APPLY_DATE'), $('CERTAIN_DATE'));}]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode : 'validator'});
		valid1.define( "required" , { id: "APPLY_DATE"  } );//聲請日	
		valid1.define( "checkAfterToday" , { id: "APPLY_DATE"  } );
		valid1.define( "required" , { id: "CERTAIN_DATE"  } );//確定日期
		valid1.define( "checkAfterToday" , { id: "CERTAIN_DATE"  } );
		valid1.define( "required" , { id: "COURT_CODE"  } );//法院
		valid1.define( "required" , { id: "CASE_NO"  } );//案號
		valid1.define( "chkADJ_DATE" , {id:"CERTAIN_DATE",errMsg:"確認日期需大於等於聲請日期" } );
	}
	
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'btn_insert' ,
			B0004 : 'btn_update',
			B0005 : 'btn_delete'		
		};
		<dz:grantButtons FUNC_ID="DSE11211"/>
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
		new Ajax.Request( "<%=dispatcher%>/DSE1_1211/" + actionName,
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
			}
		);
	}
	
	//各種action
	var actions = {
		//初始查詢
		doQuery : function(){
		
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){	
					//將下拉選單內容加到頁面
					
					OPPOSITE_STS_List = resp.OPPOSITE_STS_List;
					OPPOSITE_List = resp.OPPOSITE_List||[];
					//grid.load([]);
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
		initGrid : function(){
			//初始的Map , 讓一開始什麼都沒有的都可以新增
			var iniinsertMap = [{ 	
				LOAN_ID : LOAN_ID , 
				CASE_KIND : '0' , 
				SEQ_NO : '1' ,
				OP_TYPE : '095'
			}]
		
			grid.load(iniinsertMap);		
		
		},
		
		//將選取資料放入區塊A與區塊B
		showGridData : function(record){
		
			//將資料放入A區塊
			$('APPLY_DATE').value = toROC(record.APPLY_DATE||'') ;
			$('CERTAIN_DATE').value = toROC(record.CERTAIN_DATE||'') ;
			$w('COURT_CODE CASE_NO').each(
				function(ele){						
					$(ele).value = record[ele];
				}			
			);
		
			//將資料放入B區塊 
			var DTDSE180_voList = record.DTDSE180_voList;
			
			//oriList用來check id 是否重複
			oriList = new Object([]);
			
			//產生一個物件 Temp , 用來load grid , 因為這樣才不會因為沒copy物件 而改到原始的物件內容
			var tempList = new Object([]);
			
			//如果List內有資料 , 就將資料一個copy到各List中
			if(DTDSE180_voList.length > 0){
				for(var i = 0 ; i < DTDSE180_voList.length ; i ++){
					var temp_vo = DTDSE180_voList[i];
					tempList.push(Object.clone(temp_vo));
					oriList.push(Object.clone(temp_vo));
				}	
			}else{
				//如果沒資料, 就新增一筆其他可以給user新增
				tempList.push(
					{ 	LOAN_ID : LOAN_ID , 
						CASE_KIND : record.CASE_KIND , 
						SEQ_NO : record.SEQ_NO ,
						OP_TYPE : '095'
					}
				);
				
			}
			
			//載入list
			grid.load(tempList);
			
		
		}, 		
		
		//產生TableUI中裡面的select與input欄位
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
						select.add(new Option(data.NAME, OPPOSITE_ID));					
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
						select.setAttribute( 'className' , 'textBox2 required');
						//新增輸入欄位
						currentTd.insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
						//重設TABLE高度
						grid.resetDivHeight();
						//並且將原本資料內容清掉，
						dataObj.OPPOSITE_ID = '';
						dataObj.OPPOSITE_NAME = '';
					}else{
						//如果有選值 , 有可能從"其他"變成選有值 , 所以就要將ID跟NAME刪掉, 再重做一個下拉選單加進去
						var select_New = actions.createEle('select', '' , '');
						select_New.value =  targetValue;
						currentTd.update(select_New);//清空並重加選單
						dataObj.OPPOSITE_ID = targetValue;
						dataObj.OPPOSITE_NAME = select_New.options[select_New.selectedIndex].text;
					}					
					
					<%-- [20240207] 難字調整，動態新增需呼叫parseEUDC --%>
					parseEUDC();
				});
				
				return select;
				
			}else if(type =='input'){
			
				//產生INPUT欄位的共用方法
				var input = new Element('input' , {className : 'textBox2 required' , value : inputValue ||'' , size : '12' , maxLength : '10' ,fieldName : '相對人資訊'});			
				if( inputName == 'OPPOSITE_ID'){						
					input.setAttribute( 'className' , 'checkID textBox2 required');
				}
				if( inputName == 'OPPOSITE_NAME'){						
					input.setAttribute( 'maxLength' , 30);
					<%-- [20240207] 難字調整：姓名 --%>
					input.setAttribute('alt', 'ch');
				}
				input.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
					
					//動態將值直接改掉
					if( inputName == 'OPPOSITE_ID'){						
						input.setAttribute( 'className' , 'checkID textBox2 required');
						dataObj[inputName] = event.target.value.toUpperCase();
					}else if(inputName == 'OPPOSITE_NAME'){
						dataObj[inputName] = event.target.value;
					}			
				});
				return input;
			}		
		}
		
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//新增
		doInsert : function(){
			
			var DTDSE180_voList = grid.getAllRecords();
			
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}
			
			if(!valid1.validate()){
				return;
			}
			
			var DTDSE095_vo = grid1.getCheckedRecord()[0] || {};
		
			//取得畫面(A區)資料
			DTDSE095_vo.LOAN_ID = LOAN_ID;
			DTDSE095_vo.APPLY_DATE = $F('APPLY_DATE');
			DTDSE095_vo.CERTAIN_DATE = $F('CERTAIN_DATE');
			DTDSE095_vo.COURT_CODE = $F('COURT_CODE');
			DTDSE095_vo.CASE_NO = $F('CASE_NO');
						
			//發送ajax
			ajaxPost( 'insert' , { 
					DTDSE095_vo : Object.toJSON(DTDSE095_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){					
					grid1.load(resp.rtnList || []);
					actions.initGrid();								
				}				
			);			

		},
		
		//修改
		doUpdate : function(action){
						
			var chkList = grid1.getCheckedRecord();
			
			if(chkList.length == 0 ){
				alert('請選擇要修改資料!');
				return;
			}
			
			var DTDSE180_voList = grid.getAllRecords();
			if(DTDSE180_voList.length == 0){
				alert('請輸入相對人!');
				return;
			}			
			
			var DTDSE095_vo  = chkList[0];
			
			
			if(!valid1.validate()){
				return;
			}
			
			var DTDSE095_vo = grid1.getCheckedRecord()[0] || {};
		
			//將畫面資料取代
			DTDSE095_vo.APPLY_DATE = $F('APPLY_DATE');
			DTDSE095_vo.CERTAIN_DATE = $F('CERTAIN_DATE');
			DTDSE095_vo.COURT_CODE = $F('COURT_CODE');
			DTDSE095_vo.CASE_NO = $F('CASE_NO');
			
			//發送ajax
			ajaxPost( 'update' , {
					DTDSE095_vo : Object.toJSON(DTDSE095_vo),
					DTDSE180_voList : Object.toJSON(DTDSE180_voList)
				},
				function(resp){					
					grid1.load(resp.rtnList || []);	
					actions.initGrid();									
				}				
			);		
			
		},
		
		//刪除
		doDelete : function(action){
		
			var delList = grid1.getCheckedRecord();
			
			if(delList.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE095_vo  = delList[0];
		
			//發送ajax
			ajaxPost( 'delete' , {DTDSE095_vo : Object.toJSON(DTDSE095_vo)},
				function(resp){					
					grid1.load(resp.rtnList || []);	
					actions.initGrid();								
				}				
			);	
			
		},
		
		//新增相對人
		doInsertOpposite : function(event){
			valid1.reset();
			var DTDSE180_voList = grid.getAllRecords();
			var map=DTDSE180_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.OPPOSITE_ID='';
			tmpMap.OPPOSITE_NAME='';
			DTDSE180_voList.push(tmpMap);
			grid.load(DTDSE180_voList);
			/*
			valid1.reset();
			
			var choseRec = grid.getCheckedRecord();
			if( choseRec.length == 0  ){
				alert('請選擇要新增的資料!');
				return;
			}
			
		    var DTDSE180_vo = choseRec[0];
			var new_rec_id = DTDSE180_vo.OPPOSITE_ID;
			var DTDSE180_voList = [];
			
			var isDup = false;
			for(var i=0; i < oriList.length; i++){
				if ( new_rec_id == oriList[i].OPPOSITE_ID){ 
					isDup = true;
					break;
				}
				//如果沒有重複，就把原本的資料進來
				DTDSE180_voList.push(Object.clone(oriList[i]));
			}			

			if(isDup){
				alert('相對人資料重複!');
				
			}else{		
				//新增一筆資料
				DTDSE180_voList.push(Object.clone(DTDSE180_vo));
				oriList.push(Object.clone(DTDSE180_vo));			
				grid.load(DTDSE180_voList);		
				alert('相對人資料有變更，請於相對人資料輸入完畢後，請按下新增或修改按鈕');
			}
			*/
		},		
		
		//移除相對人
		doDeleteOpposite : function(event){
			
			valid1.reset();
			
			var choseRec = grid.getCheckedRecord();
			
			if( choseRec.length == 0  ){
				alert('請選取一筆資料!');
				return;
			}
			
			var DTDSE180_vo = choseRec[0];
			var DTDSE180_voList = grid.getAllRecords();		
			
			for ( var i = 0 ; i < DTDSE180_voList.length ; i++){
					var temp_vo = DTDSE180_voList[i];
						if( temp_vo.OPPOSITE_ID == DTDSE180_vo.OPPOSITE_ID ) {
							oriList.splice( i,1);
							if(DTDSE180_voList.length == 1){//一筆資料的處理
								//清空欄位
								DTDSE180_voList[i].OPPOSITE_ID ='';
								DTDSE180_voList[i].OPPOSITE_NAME ='';
								DTDSE180_voList[i].OPPOSITE_STS ='';	
							}else{
								//移除資料
								DTDSE180_voList.splice(i,1);
							}
							break;
						}
			}
			
			grid.load(DTDSE180_voList);
			alert('相對人資料有變更，請於相對人資料輸入完畢後，按下新增或修改按鈕');
			
		}
		,doBack : function(){
			CSRUtil.linkBack();
		}
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11211','法務作業','實體訴訟作業',1);
			
			//產生 Grid 物件	
			grid = new TableUI ( 
				{ table: $('grid'), allSortable:false, autoCheckBox :{ type :'radio'}, overDiv:false,
	            <%-- [20240207] 難字調整 --%>
                afterLoad: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
                pageChange: function() {
                	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
                },
				column : [
					{header : '相對人', key : 'OPPOSITE_ID' 
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
							
							//下拉選單顯示
							select.value = value;
							return select;				
						}	
					},
					{header : '狀態', key : 'OPPOSITE_STS'
						,render : function(record, value){
							var select = new Element('select' , {className : 'textBox2 required' , fieldName : '狀態'});
							var option = new Element('OPTION' , { value : ''}).update("請選擇");
							select.insert(option);
							//加入狀態下拉選單
							for (key in OPPOSITE_STS_List){
								select.add(new Option(OPPOSITE_STS_List[key], key));
							}
							
							//如果改下拉選單
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.OPPOSITE_STS = event.target.value;												
								}
							);
							
							select.value =value;
														
							return select;						
		
						}
					}
				]
			});
						
						
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 10, allSortable:false, overDiv:false, 
					autoCheckBox :{
						type :'radio',
						disableRule : function(record){
						//	if(record.CASE_KIND != '0'){
						//		return true;
						//	}
							return false;
						},
						
						action: function(checkbox , boxStatus , records) {
							//將資料帶入區塊B
							actions.showGridData(records[0]);
						}						
					},
	            <%-- [20240207] 難字調整 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
				column : [

				//	{header: '案件種類' , key : 'CASE_KIND_NM', groupKey : ['SEQ_NO']},
					{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
					{header: '聲請日期' , key : 'APPLY_DATE', groupKey : ['SEQ_NO']
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}					
					},
					{header: '確定日期' , key : 'CERTAIN_DATE', groupKey : ['SEQ_NO']
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}										
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header: '相對人' , key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '狀態', key : 'OPPOSITE_STS', groupKey : ['SEQ_NO']
						,render : function(record, value){
							return OPPOSITE_STS_List[value] || '';
						}
					},
					{header: '法院' , key : 'COURT_CODE_NM', groupKey : ['SEQ_NO']},					
					{header: '案號' , key : 'CASE_NO', groupKey : ['SEQ_NO']}
					
				]
			});						
						
							
			//按鈕事件監聽
			$('btn_insert').observe('click', buttons.doInsert); //新增
			$('btn_update').observe('click', buttons.doUpdate); //修改
			$('btn_delete').observe('click', buttons.doDelete); //刪除
			$('btn_insert_opposite').observe( 'click', buttons.doInsertOpposite);//新增相對人
			$('btn_delete_opposite').observe( 'click', buttons.doDeleteOpposite);//移除相對人
			$('btn_back').observe('click',buttons.doBack);
			
			
			initValidation();//畫面日期檢核

			buttonAuth();//按鈕授權
			
			actions.doQuery();//初始查詢
			
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
        <div align = "center">
			<tr>
				<td>
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
					<input id="APPLY_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "聲請日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('APPLY_DATE'))" /></td>		
				<td class="tbYellow" width="8%" align="left" >
					確定日期
				</td>
				<td class="tbYellow2" >
					<input id="CERTAIN_DATE" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate" size="10" maxlength="7" fieldName = "確定日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('CERTAIN_DATE'))" /></td></td>	
				<td class="tbYellow" width="6%" align="left" >
					法院
				</td>
				<td class="tbYellow2" >
					<select id="COURT_CODE" class="textBox2" fieldName = "法院">
						<option value="">請選擇
						<c:forEach items="${COURT_List}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>		
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					案號
				</td>
				<td class="tbYellow2">
					<input id="CASE_NO"  type="text" class="textBox2" fieldName = "案號"/>
				</td>
			</tr>			
		</table>
		<table id = "grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_opposite" type = "button" class = "button" value = "新增相對人"/>
					<input id = "btn_delete_opposite" type = "button" class = "button" value = "移除相對人"/>
				</td>
			</tr>			
		</table>	
		<table id = "grid1"></table>		
</form>	
</body>
</html>