<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11209.jsp
功能：協議清償作業
作者：卓達瑋
完成：2013/08/13

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
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
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


Event.observe(window, 'load', new DSE11209().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11209(){
	
	var valid1; //畫面檢核物件	
	var LOAN_ID = '${LOAN_ID}';//貸款帳號
	var	SPR_TYPE_List;//分期方式清單
	var BARGAIN_COND_List;//協議條件清單下拉選單
	var	OPPOSITE_List;//相對人下拉選單
	var grid;	
	var rtnList;
	//按鈕權限紀錄	
	var legal2;
	function initValidation(){
		//檢核
		Validation.addAllThese([
			[ 'OPPOSITE_ID_Input_required',  '請輸入其他相對人的ＩＤ及姓名!',
				function(v,elem){
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];				
					return !checks || v;
				}
			],		
			[ 'checkID',  '身份證字號格式錯誤',
				function(v,elem){
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || validation.checkROCID(v);
				}
			],			
			[ 'checkAfterToday',  '簽准日期不可大於今日!',
				function(v){ 
					var today = getToday();			
					if( diffDay(today, v) > 0 ){
						return false;					
					}
					return true;
				}
			],
			[ 'APPLY_DATE_required', '簽准日期錯誤，請檢查後重新輸入!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					
					return !checks || v;
					
				}
			],
			[ 'BARGAIN_COND_required', '請選擇協議條件!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || v;
					
				}
			],
			[ 'SPR_TYPE_required', '請選擇分期方式!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					return !checks || v;
					
				}
			],
			
			[ 'NEW-ROCDate', '請輸入正確的民國年格式', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    if( !Validation.get('IsEmpty').test(v) ){
							return isROCdate(v,false);
						}
						return true;
					}
					return true;
					
				}
			],
			[ 'NEW-ROCDate2', '請輸入正確的民國年格式', 
				function(v,elem){ 
					var checks = elem.up('tr').previousSibling.select("input[type=checkbox]:checked")[0];

					if(checks){
					    if( !Validation.get('IsEmpty').test(v) ){
							return isROCdate(v,false);
						}
						return true;
					}
					return true;
					
				}
			],
			[ 'TOTAL_AMT_required', '請輸入協議總金額!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					
					return !checks || v;
					
				}
			],
			[ 'TOTAL_AMT_more', '協議總金額不可小於於累計還款金額!', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
					if(!checks){
						return true;					
					}else{							
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var PAID_AMT = dataObj.PAID_AMT;	
						if(v < PAID_AMT){
							return false;						
						}
						return true;
					}
					
				}
			],
			[ 'checkBEGIN_DATE',  '分期始日不可小於簽准日!',
				function(v,elem){ 
					var checks = elem.up('tr').previousSibling.select("input[type=checkbox]:checked")[0];					
					if(!checks){
						return true;					
					}else{					
						var tr = elem.up('tr');
						var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
						var BARGAIN_APPR_DATE = dataObj.BARGAIN_APPR_DATE;							
						if(( v && BARGAIN_APPR_DATE) && diffDay(toY2K(v), BARGAIN_APPR_DATE) > 0 ){
							
							return false;					
						}
						return true;
					}
				}
			]
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode : 'validator'});	
				
	}
	
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0004 : 'btn_update' 
		};
		<dz:grantButtons FUNC_ID ="DSE11209"/>
		legal2=legal;
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1209/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	//--------------------------------------------------------------------------
	// 建立/關閉coverPage(不讓使用者在上載時做任何事)
	//--------------------------------------------------------------------------
	var auxiliary = {
		createCoverPage:function(){
			CSRUtil.createCoverPage('_frontCover');
			$('_frontCover').show();
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};
	//各種action
	var actions = {

		//產生TableUI中裡面的input欄位
		createInputElement : function(colkey,value,type,col_nm,ser_no){
			var theID = colkey+ser_no;
			if(type == 'date'){
				var td = new Element('td');
				var input;
				//[20180824] 不設type='DATE', 增加name = theID+'_input'
				if(colkey=='BARGAIN_APPR_DATE'){
				    input = new Element('input', {className : 'textBox2 APPLY_DATE_required NEW-ROCDate checkAfterToday', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'9' ,fieldName : col_nm });			
				
				}else if(colkey == 'BEGIN_DATE'){
				    input = new Element('input', {className : 'textBox2 NEW-ROCDate2 checkBEGIN_DATE', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'9' ,fieldName : col_nm });			
				
				}else{
					input = new Element('input', {className : 'textBox2 NEW-ROCDate2', id:theID, name:theID+'_input', datatype:'ROCdate', size:'10', maxlength:'9' ,fieldName : col_nm });			
				
				}

				
				input.value = Date.toInputROC( value || '' ,'');
				
				input.observe('change' , function(event){
					var tr = this.up('tr').nextSibling;
					var span_A=$(tr).select('td[name=PAID_AMT]')[0];
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					dataObj[colkey] = toY2K(event.target.value||'');
					if(colkey=='BARGAIN_APPR_DATE'){
					    //發送AJAX
						ajaxPost( 'changePAID_AMT' , {'LOAN_ID' :LOAN_ID ,'BARGAIN_APPR_DATE' : dataObj[colkey],'TOTAL_AMT':dataObj['TOTAL_AMT']} ,
							function(resp){							
								var PAID_AMT=resp.PAID_AMT;
								span_A.update(MoneyFormat(PAID_AMT));
								dataObj['PAID_AMT'] = PAID_AMT;	
								var REMAIN_AMT=resp.REMAIN_AMT;
                                var span_B=$(tr).select('td[name=REMAIN_AMT]')[0];
								span_B.update(MoneyFormat(REMAIN_AMT));
								dataObj['REMAIN_AMT'] = REMAIN_AMT;	
								
							}
						);
					
					
					}
					}
				);
				var clan =   new Element('img', { src : '<%=imageBase%>/CM/calendar.gif' , alt : 'Date'});			
				
				clan.observe('click' , function(event){					
					getCalendarFor(input);
				});
				td.insert(input).insert(clan);
				return td;
			}else if(type == 'number'){
					var input;
					//[20180824] 增加name = theID+'_input'
				    if(colkey=='TOTAL_AMT'){
				        input = new Element('input', {className : 'textBox2 validate-integer TOTAL_AMT_required TOTAL_AMT_more', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '15' ,fieldName : col_nm });				
				    }else{
					    input = new Element('input', {className : 'textBox2 validate-integer', id:theID, name:theID+'_input', type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '15' ,fieldName : col_nm });	
					}
				input.value = value ? CSRUtil.$fmt(value,'#,###') : '';
				input.observe('blur' , function(event){						
					var tr = this.up('tr').nextSibling;
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var new_value = event.target.value;
					dataObj[colkey] = new_value.replace(/,/g,'');
					
					if(colkey=='TOTAL_AMT'){
					    //發送AJAX
						ajaxPost( 'changeREMAIN_AMT' , {'TOTAL_AMT':dataObj['TOTAL_AMT'],'PAID_AMT' : dataObj['PAID_AMT']} ,
							function(resp){							
								var REMAIN_AMT=resp.REMAIN_AMT;
                                var span_B=$(tr).select('td[name=REMAIN_AMT]')[0];
								span_B.update(MoneyFormat(REMAIN_AMT));
								dataObj['REMAIN_AMT'] = REMAIN_AMT;	
							}
						);
					
					
					}
					
					
					}
				);
				return input; 
			}
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
						var INPUT_ID = actions.createEle('input','APPLICANT_ID', '');		
						var INPUT_NAME = actions.createEle('input','APPLICANT_NAME', '');
						
						//產生ID與NAME後,下拉選單就會被檢核出來中
						select.setAttribute( 'className' , 'textBox2');
						//新增輸入欄位
						currentTd.insert('&nbsp&nbspID :').insert(INPUT_ID).insert('&nbsp&nbsp姓名 :').insert(INPUT_NAME);
						//並且將原本資料內容清掉，
						dataObj.APPLICANT_ID = '';
						dataObj.APPLICANT_NAME = '';
					}else{					
						//如果有選值 , 有可能從"其他"變成選有值 , 所以就要將ID跟NAME刪掉, 再重做一個下拉選單加進去
						var select_New = actions.createEle('select', '' , '');
						select_New.value =  targetValue;
						currentTd.update(select_New);//清空並重加選單
						dataObj.APPLICANT_ID = targetValue;
						dataObj.APPLICANT_NAME = select_New.options[select_New.selectedIndex].text;
					}					
					
					<%-- [20240207] 難字調整，動態新增需呼叫parseEUDC --%>
					parseEUDC();
				});
				
				return select;
				
			}else if(type =='input'){
			
				//產生INPUT欄位的共用方法
				var input = new Element('input' , {className : 'textBox2 OPPOSITE_ID_Input_required' , value : inputValue ||'' , size : '12' , maxLength : '10' ,fieldName : '相對人資訊'});			

				<%-- [20240207] 難字調整：姓名 --%>
				if( inputName == 'APPLICANT_NAME'){						
					input.setAttribute('alt', 'ch');
				}

				input.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
					
					//動態將值直接改掉
					if( inputName == 'APPLICANT_ID'){
						input.setAttribute( 'className' , 'checkID textBox2');
						dataObj[inputName] = event.target.value.toUpperCase();
					}else if(inputName == 'APPLICANT_NAME'){
						dataObj[inputName] = event.target.value;
					}			
				});
				return input;
			}		
		},
		//顯示附件名稱
		showupload : function(record) {
			var list=record['DTDSE207_voList'];
			var span = new Element('span');
			if(!list){
				return span.update("<br>");
			}
			
			for( var i=0 ; i<list.length ; i++ ) {
				var file = list[i];
				var link = new Element( "a", {id:'link_'+i ,href: "#", FILE_ID: file.FILE_ID,align:'left'}).update(file.FILE_NM).observe('click',  actions.getDownLoadFile );										
				var button = new Element( "input", { id:"btn_delete", name:"button", type:"button", value:"刪除",NO:i ,FILE_ID :file.FILE_ID});											
				//按下'刪除'按鈕，刪除相關物件
			    button.onclick = function(){
				/*
					var tmpList = grid.getCheckedRecord();			
					if( tmpList.length == 0 ||tmpList.length>1){
						alert('請選擇一筆資料!');
						return;			
					}  */
				
					if(confirm('是否確定要移除此附件？')){ 					
						ajaxPost('deleteFile', {FILE_ID:this.getAttribute('FILE_ID'), 'LOAN_ID':LOAN_ID,CASE_KIND:record['CASE_KIND'],SEQ_NO:record['SEQ_NO']},  
							function(resp){
								var rtnList=resp.rtnList||[];
								rtnList.push({ 	LOAN_ID : LOAN_ID,
											APPLICANT_ID : ''
										});
								grid.load(rtnList);	
							} 
						);
					}
			    };
                //按鈕控制
				if(legal2.length!=0){ 
					for(var j=0 ; j<legal2.length ; j++){
						if(legal2[j]!='B0077'){
						   button.disable();
						}else{
					       button.enable();
						   break;
						}
					}
				}else{
				button.disable();
				}				
				span.insert(link);
			    span.insert(button);				
			}
			
		   return span;
		},
		//下載檔案
		getDownLoadFile : function(event)  {
			RPTUtil.downloadFile( '<%=dispatcher%>/DSE1_1209/downFile', {'FILE_ID':this.FILE_ID});						
		}
		
		
		
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){						
					SPR_TYPE_List = resp.SPR_TYPE_List||{};
					BARGAIN_COND_List = resp.BARGAIN_COND_List||{};
					OPPOSITE_List = resp.OPPOSITE_List||[];
					rtnList=resp.rtnList||[];
					if(rtnList!=''){
					    rtnList.push({ 	LOAN_ID : LOAN_ID,
								CASE_KIND :'0'
							});
						grid.load(rtnList);
					}else{
					var tempList = [];
						//如果沒資料, 就新增一筆其他可以給user新增
						tempList.push(
							{ 	LOAN_ID : LOAN_ID,
								CASE_KIND :'0'
							}
						);
						grid.load(tempList);
					}
					

				},
				function(resp){
					SPR_TYPE_List = resp.SPR_TYPE_List||{};
					BARGAIN_COND_List = resp.BARGAIN_COND_List||{};
					OPPOSITE_List =resp.OPPOSITE_List||[];
					var tempList = [];
					//如果沒資料, 就新增一筆其他可以給user新增
					tempList.push(
						{ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0'
							
						}
					);
					grid.load(tempList);					
					
				}
			);

		},
	
		
		//新增
		doInsert : function(){	
			//檢核
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選取一筆資料!');
				return;			
			}
			if(tmpList[0].SEQ_NO){
			    alert("選擇資料無法新增!");
				return;
  			}
			if(!valid1.validate()){
				return;
			}
			//發送ajax
			ajaxPost( 'insert' , {
					DTDSE204_vo : Object.toJSON(tmpList[0])
				},
				function(resp){
					rtnList=resp.rtnList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
					grid.load(rtnList);					
				}				
			);
		},
		
		//修改
		doUpdate : function(action){
			
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇欲修改資料!');
				return;			
			}
			if(!tmpList[0].SEQ_NO){
			    alert("選擇資料無法修改!");
				return;
  			}
			//檢核區塊A
			valid1.reset();			
			if(!valid1.validate()){
				return;
			}
							
			//發送ajax
			ajaxPost( 'update' , {
					LOAN_ID : LOAN_ID,
					DTDSE204_voList : Object.toJSON(tmpList)
				},
				function(resp){
					rtnList=resp.rtnList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
					grid.load(rtnList);						
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
				if(!tmpList[0].SEQ_NO){
			    alert("選擇資料無法刪除!");
				return;
  			}
		    if(!confirm('該筆紀錄將會全部刪除，請確認是否繼續？')){
			    return;
			}
			//發送ajax
			ajaxPost( 'delete' , {LOAN_ID : LOAN_ID , DTDSE204_voList : Object.toJSON(tmpList)},
				function(resp){	
					rtnList=resp.rtnList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
					grid.load(rtnList);	
				}				
			);		
		},
		//覆核
		doConfirm : function(action){
		
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇欲覆核資料!');
				return;			
			}
			if(!tmpList[0].SEQ_NO){
			    alert("選擇資料無法覆核!");
				return;
  			}
			//發送ajax
			ajaxPost( 'confirm' , {LOAN_ID : LOAN_ID , DTDSE204_voList : Object.toJSON(tmpList)},
				function(resp){	
					rtnList=resp.rtnList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
					grid.load(rtnList);	
				}				
			);	
			
		},
		//取消覆核
		doCancel : function(action){
		
			var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇欲取消覆核資料!');
				return;			
			}	
			if(!tmpList[0].SEQ_NO){
			    alert("選擇資料無法取消覆核!");
				return;
  			}
			if(!confirm('請確認是否取消覆核？')){
			    return;
			}

			//發送ajax
			ajaxPost( 'cancel' , {LOAN_ID : LOAN_ID , DTDSE204_voList : Object.toJSON(tmpList)},
				function(resp){	
					rtnList=resp.rtnList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
					grid.load(rtnList);	
				}				
			);		
		},
		//上傳
		doUpload : function(){										
			if(!$F('import_file')){
				alert('請選擇資料檔再執行上傳!');
				return;
			}
		    var tmpList = grid.getCheckedRecord();			
			if( tmpList.length == 0 ){
				alert('請選擇一筆資料!');
				return;			
			}
			if( tmpList.length > 1 ){
				alert('只能選擇一筆資料!');
				return;			
			}
            if(!tmpList[0].SEQ_NO){
				alert("選擇資料無法上傳影像!");
				return;
			} 
			var DTDSE204_vo=tmpList[0];
			$('SEQ_NO').value=DTDSE204_vo['SEQ_NO'];
			$('CASE_KIND').value=DTDSE204_vo['CASE_KIND'];
			auxiliary.createCoverPage();
			document.form1.submit();			
		},
		
		//匯入結束
		importEnd : function(event){
		
			var obj = window.importFrame.document.getElementById('filedata').innerHTML.evalJSON();		
			
			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				alert(Msg);
			}	
			if(CSRUtil.isSuccess(obj)){			
				var rtnList=obj.File_mapList||[];
				    rtnList.push({ 	LOAN_ID : LOAN_ID,
							CASE_KIND :'0',
							APPLICANT_ID : ''
						});
				grid.load(obj.File_mapList);									
			}						
			auxiliary.closeCoverPage();
		}

	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11209','法務件','協議清償作業',1,true);
			
			//產生 Grid 物件	
			grid = new TableUI (
				{ table: $('grid'), pageSize: 10,split:["PAY_TERM","DTDSE207_voList"], 
				  allSortable:false, 
				  autoCheckBox :{ 
						type :'checkboxs'
					},
				  overDiv:false,
				  afterLoad: function(ele){
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
					{header : '序號', key : 'SEQ_NO', attrs:{rowSpan:3}},
					{header : '簽准日期', key : 'BARGAIN_APPR_DATE',attrs:{rowSpan:3}
						,render : function(record, value){
							return actions.createInputElement('BARGAIN_APPR_DATE',value,'date','簽准日期',record.SEQ_NO);
						}
					},
				  	{header : '聲請人', key : 'APPLICANT_ID'
						,render : function(record, value){
							
							//製作聲請人下拉選單
							var select = actions.createEle('select','', '');
							//檢查ID是否在聲請人下拉選單內									
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
								var INPUT_ID = actions.createEle('input','APPLICANT_ID', record.APPLICANT_ID);
								var INPUT_NAME = actions.createEle('input','APPLICANT_NAME', record.APPLICANT_NAME);
								span.insert(select).insert('&nbsp&nbspID ：').insert(INPUT_ID).insert('&nbsp&nbsp姓名 ：').insert(INPUT_NAME);
								return span;
								
							}						
							select.value = value;
							return select;				
						}	
					},
					{header: '協議總金額' , key : 'TOTAL_AMT'
						,render : function(record, value){
							return actions.createInputElement('TOTAL_AMT',value,'number','協議總金額',record.SEQ_NO);
						}
	                },
					{header : '協議條件', key : 'BARGAIN_COND'
						,render : function(record, value){
							var select = new Element('select' , {className : 'textBox2 BARGAIN_COND_required' , fieldName : '協議條件'});	
							select.add(new Option("請選擇", ""));
							for (key in BARGAIN_COND_List){
								select.add(new Option(BARGAIN_COND_List[key], key));
							}
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj['BARGAIN_COND'] = event.target.value;
								}
							);							
							select.value = value;//預設值
							return select;						
		
						}
					},
					{header: '部入金額' , key : 'BARGAIN_AMT'
						,render : function(record, value){
							return actions.createInputElement('BARGAIN_AMT',value,'number','部入金額',record.SEQ_NO);
						}
	                },
					{header : '分期方式', key : 'SPR_TYPE'
						,render : function(record, value){
							var select = new Element('select' , {className : 'textBox2 SPR_TYPE_required' , fieldName : '分期方式'});	
							select.add(new Option("請選擇", ""));
							for (key in SPR_TYPE_List){
								select.add(new Option(SPR_TYPE_List[key], key));
							}
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj['SPR_TYPE'] = event.target.value;
								}
							);							
							select.value = value;//預設值
							return select;						
		
						}
					},
					<%-- [20240207] 難字調整：覆核人員 --%>
					{header: '覆核人員' , key : 'CONFIRM_NAME', attrs:{ style:"font-family:'EUDC'" }},
					
					{header: '分期期數' , key : 'PAY_TERM'
						,render : function(record, value){
							return actions.createInputElement('PAY_TERM',value,'number','分期期數',record.SEQ_NO);
						}
	                },
					{header : '分期始日', key : 'BEGIN_DATE'
						,render : function(record, value){
							return actions.createInputElement('BEGIN_DATE',value,'date','分期始日',record.SEQ_NO);
						}
					},
					{header: '每期金額' , key : 'PAY_AMOUNT'
						,render : function(record, value){
							return actions.createInputElement('PAY_AMOUNT',value,'number','每期金額',record.SEQ_NO);
						}
	                },					
					{header: '累計還款金額' , key : 'PAID_AMT'
						,render : function(record, value){
							return value ? MoneyFormat(value):'';
						}
	                },
					{header: '剩餘還款金額' , key : 'REMAIN_AMT'
						,render : function(record, value){
							return value ? MoneyFormat(value):'';
						}
	                },
					{header: '覆核日期' , key : 'CONFIRM_DATE'
						,render : function(record, value){
							return  Date.toInputROC( value || '' ,'/');
						}
	                },
					{header: '簽擬單' , key : 'DTDSE207_voList',attrs:{colSpan:6,algin:'center'}
						,render : function(record, value){
							return actions.showupload(record);
						}
	                }
					
				]
			});   
					
						
							
			//按鈕事件監聽
			//$('btn_insert').observe('click', buttons.doInsert); //新增
			//$('btn_update').observe('click', buttons.doUpdate); //修改
			//$('btn_delete').observe('click', buttons.doDelete); //刪除
			//$('btn_confirm').observe('click', buttons.doConfirm); //覆核
			//$('btn_cancel').observe('click', buttons.doCancel); //取消覆核
            
			//$('btn_upload').observe('click', buttons.doUpload);	//上傳附件			
			//$('importFrame').observe('load', buttons.importEnd); //匯入結束
			
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
<form name="form1" id="form1" method="post"  target="importFrame" enctype="multipart/form-data" action="<%=dispatcher%>/DSE1_1209/upload" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
			    <input name="LOAN_ID" id="LOAN_ID" type="hidden" value="${LOAN_ID}"/>
				<input name="CASE_KIND" id="CASE_KIND" type="hidden" />
				<input name="SEQ_NO" id="SEQ_NO" type="hidden" />
			</tr>
            
			
		</table>
		<table id = "grid" ></table>
		
</form>	
</body>
</html>