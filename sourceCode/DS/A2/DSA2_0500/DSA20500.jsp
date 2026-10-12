<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA20500.jsp
作者：i9100607
功能：本息收支表
完成：2011/10/14
更新：
-->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css">
<%--共用定義的javaScript--%>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/date.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/Validator.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<%--[20240729]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<%--自行定義的javaScript--%>
<script type="text/javascript">

<!--
<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var validator;

function initApp() {
	PageUI.createPage("DSA20500" , "核貸作業" , "本息收支表",'${titleNotDisplay}' == 'Y');
	PageUI.loadin(["tableA","grid_B","tableB","grid_D","tableC","grid_E","tableD","grid_F","tableE","grid_G","tableF"] ,1);

	cleanMsgBoard();

	buttonAuth();
	validator = new Validator();
	//TableUI的產生        
	new UI().init();
	
	PageUI.resize(true);
}

<%-- button控制 --%>
function buttonAuth(){
	var authButtons = {
		B0003:"btn_add",		
		B0004:"btn_update",
		B0005:"btn_delete"	
	};
	<dz:grantButtons FUNC_ID="DSA20500" /> 	
}

function UI(){                
   
	var grids = [] ;        
	var QRY_ID = '' ;
	var IS_DATA = '' ;
	var NO = 1 ; 
	var fmt0 = '#,##0';             // 金額格式(無小數)
	var tempValue = 0 ;
	var getDatatemp = [['tempMSG_'],['tempYEAR_E_'],['tempYEAR_F_'],['tempCARD_','tempCARD_NUM_','tempYEAR_RATE_','tempMONTH_RATE_','tempYEAR_G_']] ;
	var getData = [['INCOME_MSG'],['YEAR_AMT'],['YEAR_AMT'],['CARD_TYPE','CARD_COUNT','YEAR_RATE','MONTH_RATE','YEAR_AMT']] ;
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "${dispatcher}/DSA2_0500/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction();
		 		}
		 		PageUI.resize(true);
	        }}
		);
	}      

	<%--TableUI 物件初始化--%>
	function initTableUI() {
		grids[0] = new TableUI( {
			  table : $('grid_B')
			, overDiv : false
			, allSortable : false,
			<%-- [20240729] 難字調整 --%>
			afterLoad: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			},
			pageChange: function() {
				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
			}
			, autoCheckBox : {
				  type : 'radio'
				, valueKey : 'ID'
				, attrs : { width: "6%" }
				, action : function(checkbox , boxStatus, records) {
					QRY_ID = records[0].ID;
					doQuery();
				}
			}
			, column : [
				{ key: 'TYPE', header: '身分別'
					, render: function(record, value) {
						return (value == '0') ? '借款人' : '保證人';
					}
				}
				, { key: 'NAME', header: '姓名', attrs:{style:"font-family:'EUDC'"}}<%--[20240729]難字調整 --%>
				, { key: 'HAS_DATA', header: '是否輸入'
					, render: function(record, value) {
						return (value == 'Y') ? '已輸入' : '未輸入';
					}
				}
			]
       	} );

       	grids[1] = new TableUI( {
			  table : $('grid_D')
			, title : '收入部分'
			, overDiv : false
			, allSortable:false
			, autoCheckBox : {
				  type : 'radio'
				, attrs : { width: "6%" }
			},
	       	<%-- [20240729] 難字調整 --%>
	       	afterLoad: function() {
	       		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	       	},
	       	pageChange: function() {
	       		if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	       	}
			, column : [
				{ key: 'INCOME_NAME', header: '當事人',
					render: function(rec, val, sn){
						<%--[20240729] 難字調整 --%>
						var input = new Element('input',{type:'text',id:'INCOME_NAME'+sn,size:10,maxlength:60, alt:"ch" });
						input.setValue(val);
						input.observe('blur', function(){
							rec.INCOME_NAME =  this.value;
						});
						return input;
					}
				},
				{ key: 'INCOME_ITEM', header: '收入項目',
					input:{
						type:'TEXT' ,size:20 ,maxlength:20
					}
				},
				{ key: 'INCOME', header: '年所得(萬)',
					input:{
						type:'NUMBER' ,size:10,floatNum:0 ,maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){
							getSum(true);
						}
					},
					render:function(record,value){
						return (value) ? CSRUtil.$fmt(value,fmt0) : value ;
					}
				},
				{ key: 'INCOME_MSG', header: '說明',
					render:function(record,value){
						var aTA = document.createElement('TextArea') ;
						aTA.id = 'tempMSG_' + record.NO ;
						aTA.value = value || '' ;
						aTA.rows = 2 ; 
						aTA.cols = 60 ;
						
						aTA.onpropertychange = function(){
							
							this.style.height=this.scrollHeight+'px';
							grids[1].resetDivHeight();
						}

						return aTA ;
					}			
				}
			]<%----%>
       	} );

       	grids[2] = new TableUI( {
			table: $('grid_E'), autoCheckBox:{type:'radio',attrs:{width:"6%"}} ,title:'本金與利息支出估計', overDiv:false, allSortable:false,
			column:[	
				{ key: 'BANK_NAME', header: '本公司貸款',
					input:{
						type:'TEXT' ,size:60 ,maxlength:80
					}
				},
				{ key: 'LOAN_AMT', header: '金額(仟)',
					input:{
						type:'NUMBER' ,size:10 ,floatNum:0 , maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){	
							
							getSum(true);
							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial_Cathay('tempYEAR_E_',data) ;
						}
					},
					render:function(record,value){
						return (value) ? CSRUtil.$fmt(value,fmt0) : value ;
					}
				},
				{ key: 'RATE', header: '利率%',
					input:{
						type:'NUMBER' ,size:7 ,floatNum:4, maxlength:7,
						action:function(node , dataObj , textDiv, orgValue ){
							var val = node.value;
							if(eval(val)>100){
								var le = val.indexOf('.');
								if(le>=0){
									node.value = val.substring(le-2);
								}else{
									node.value = val.substring(val.length-2);
								}
							}

							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial_Cathay('tempYEAR_E_',data) ;							
						}
					}
				},
				{ key: 'LOAN_PERIOD', header: '年期(期數)',
					input:{
						type:'NUMBER' ,size:10 ,floatNum:0 , maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){	
							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial_Cathay('tempYEAR_E_',data) ;	
						}
					}
				},
				{ key: 'YEAR_AMT', header: '本金與利息(仟/年)',
					render:function(record,value){
						var aDiv = document.createElement('div') ;						
						var id = 'tempYEAR_E_'+record.NO ;
						aDiv.id = id;
						aDiv.innerHTML = value;
						aDiv.style.backgroundColor="Sandybrown";
						return aDiv ;
					}
				}

			]<%----%>
       	} );

       	grids[3] = new TableUI( {
			table: $('grid_F'), autoCheckBox:{type:'radio',attrs:{width:"6%"}} , overDiv:false, allSortable:false,
			column:[	
				{ key: 'BANK_NAME', header: '其他行庫貸款',
					input:{
						type:'TEXT' ,size:60 ,maxlength:80
					}
				},
				{ key: 'LOAN_AMT', header: '金額(仟)',
					input:{
						type:'NUMBER' ,size:10 ,floatNum:0 , maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){	
							
							getSum(true);
							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial('tempYEAR_F_',data) ;
						}
					},
					render:function(record,value){
						return (value) ? CSRUtil.$fmt(value,fmt0) : value ;
					}
				},
				{ key: 'RATE', header: '利率%',
					input:{
						type:'NUMBER' ,size:7 ,floatNum:4, maxlength:7,
						action:function(node , dataObj , textDiv, orgValue ){
							var val = node.value;
							if(eval(val)>100){
								var le = val.indexOf('.');
								if(le>=0){
									node.value = val.substring(le-2);
								}else{
									node.value = val.substring(val.length-2);
								}
							}

							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial('tempYEAR_F_',data) ;							
						}
					}
				},
				{ key: 'LOAN_PERIOD', header: '年期(期數)',
					input:{
						type:'NUMBER' ,size:10 ,floatNum:0 , maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){	
							var data = dataObj[0] ;
							if (data.LOAN_AMT && data.RATE && data.LOAN_PERIOD )
								doTrial('tempYEAR_F_',data) ;	
						}
					}
				},
				{ key: 'YEAR_AMT', header: '本金與利息(仟/年)',
					render:function(record,value){
						var aDiv = document.createElement('div') ;						
						var id = 'tempYEAR_F_'+record.NO ;
						aDiv.id = id;
						aDiv.innerHTML = value;
						aDiv.style.backgroundColor="Sandybrown";
						return aDiv ;
					}
				}
			]<%----%>
       	} );
       	
       	grids[4] = new TableUI( {
			table: $('grid_G'), autoCheckBox:{type:'radio',attrs:{width:"6%"}} , overDiv:false, allSortable:false,
			column:[	
				{ key: 'CARD_TYPE', header: '現金/信用卡使用情形',
					render:function(record,value){
						var aDiv = document.createElement('div') ;
						
						var aSelect = document.createElement('select') ;
						aSelect.id = 'tempCARD_'+ record.NO ;
						
						var aOption = document.createElement('option') ;
						aOption.value = 'A' ;
						aOption.innerText = '現金卡' ;
						aSelect.appendChild(aOption) ;
						
						var bOption = document.createElement('option') ;
						bOption.value = 'B' ;
						bOption.innerText = '信用卡' ;
						aSelect.appendChild(bOption) ;
						
						aSelect.value = value || 'A' ;
						aSelect.onchange = function(){
							$('tempMONTH_RATE_'+record.NO).value = (aSelect.value == 'A') ?'2.0' : '5.0' ;
							doTrial_CARD(record.NO) ;
						}
						aDiv.appendChild(aSelect) ;
						
						var onchange = function(){
							doTrial_CARD(record.NO) ;
						}
						
						var aText = document.createTextNode('(') ;
						aDiv.appendChild(aText) ;
												
						aDiv.appendChild(createInput(record.CARD_COUNT || '0' , 10, 4, 'tempCARD_NUM_' +record.NO , onchange)) ;
						
						var bText = document.createTextNode('張)') ;
						aDiv.appendChild(bText) ;													
 						
						return aDiv ;
						
					}
					
				},
				{ key: 'LOAN_AMT', header: '金額(元)',
					input:{
						type:'NUMBER' ,size:10 ,floatNum:0 , maxlength:10 ,
						action:function(node , dataObj , textDiv, orgValue ){	
							doTrial_CARD(dataObj[0].NO) ;
						}
					},
					render:function(record,value){
						return (value) ? CSRUtil.$fmt(value,fmt0) : value ;
					}
				},
				{ key: 'YEAR_RATE', header: '利率%(最低應繳)',
					render:function(record,value){
						var aDiv = document.createElement('div') ;
						var onchange = function(){
							var val = $('tempYEAR_RATE_'+record.NO).value;
							if(eval(val)>100){
								var le = val.indexOf('.');
								if(le>=0){
									$('tempYEAR_RATE_'+record.NO).value = val.substring(le-2);
								}else{
									$('tempYEAR_RATE_'+record.NO).value = val.substring(val.length-2);
								}
							}
							
							doTrial_CARD(record.NO) ;
						}

						aDiv.appendChild(createInput(value || '', 7, 7, 'tempYEAR_RATE_'+record.NO, onchange, 4)) ;
						
						var aText = document.createTextNode('%(') ;
						aDiv.appendChild(aText) ;
												
						var bInput = createInput(record.MONTH_RATE || '2.0', 5, 7, 'tempMONTH_RATE_'+record.NO) ; 
						bInput.readOnly = true ;		
						aDiv.appendChild(bInput) ;		
						
						var bText = document.createTextNode('%)') ;
						aDiv.appendChild(bText) ;	
						
						return aDiv ;
					}
				},
				{ key: 'YEAR_AMT', header: '應繳金額(元)',
					render:function(record,value){
						var aDiv = document.createElement('div') ;
						
						var id = 'tempYEAR_G_'+record.NO ;

						aDiv.id = id;
						aDiv.innerHTML = value;
						aDiv.style.backgroundColor="Sandybrown";
						
						return aDiv ;
					}
				}
			]<%----%>
       	} );	
	}

	//產生Input
	function createInput(value,size,maxLength,id,onChange,isDot){
		var aInput = document.createElement('input') ;
		aInput.type = 'text' ;
		aInput.style.textAlign = 'right' ;
		aInput.value = (value) ? CSRUtil.$fmt(value,fmt0) : value ;
		aInput.size = size ;
		aInput.id = id ;
		if(maxLength!=''){
			aInput.maxLength = maxLength;
		}
		if(onChange){
			aInput.onchange = onChange ; 
		}			
		aInput.onfocus = function(){
			tempValue = $F(id) || 0 ;
		}	
		aInput.onkeyup = function(){
			var val = $F(id) ;
			var len = val.length ;
			var index = val.indexOf('.') ;
			if(index <0){
				return false ;
			}
			var dot = isDot || 0 ;
			var nums = val.split('.') ;		
			$(id).value = nums[0].substring(0,Math.min(nums[0].length,2)) + ((dot)?'.':'') + nums[1].substring(0,Math.min(nums[1].length,dot)) ;
			
		}
		aInput.onkeypress = function(){
			return ((event.keyCode > 47 && event.keyCode < 58 ) || event.keyCode == 46);
		}
		
		return aInput ;		
	}
	
	//--------------------------------------------------------------------------	
	//	按鈕功能Function
	//--------------------------------------------------------------------------
	
	//查詢
	function doQuery(isPrompt) {
		if (!checkAPPLY_ID()) { return; }

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});
		
		$('APPLY_ID').value = $F('APPLY_ID').toUpperCase() ;
		if (isPrompt){
			QRY_ID = '' ;
		}
	
		var params = { info:Object.toJSON({'APPLY_ID':$F('APPLY_ID'),'QRY_ID':QRY_ID}) };

		ajaxPost( 'query', params, successAction, errorAction);	
	}
	
	//列印
	function doPrint(){

		if(!checkAPPLY_ID()){
			return;
		}
		
		var grid1 = grids[1].getAllRecords();
		var grid2 = grids[2].getAllRecords();
		var grid3 = grids[3].getAllRecords();
		var grid4 = grids[4].getAllRecords();
		
		var queryData = {
			APPLY_ID: $F('APPLY_ID'),
			NAME: $('firstMap_NAME').getValue(),<%--[202401729]難字調整，改用input readonly --%>
			QRY_ID: QRY_ID,
			Total_INCOME:$('Total_INCOME').innerHTML.replace(/,/g,''),
			Total_LOAN:$('Total_LOAN').innerHTML.replace(/,/g,''),
			Total_YEAR:$('Total_YEAR').innerHTML.replace(/,/g,''),
			INCOME_EXP_RATE:$('INCOME_EXP_RATE').innerHTML.replace(/,/g,''),
			A152_List:getAllDatas(1),
			A153_ListA:getAllDatas(2),
			A153_ListB:getAllDatas(3),
			A158_List:getAllDatas(4)
		};		
		
		window.open("", "DSA2_0501", "top=50, left=50,  toolbar=no, resizable=yes, location=0, status=0, scrollbars=1, titlebar=0, width=800, height=600");

		var url = "${dispatcher}/DSA2_0501/prompt";			
		var form1 = $('form1');
		form1.target='DSA2_0501';
		form1.action=url;
		$('queryData').value = Object.toJSON(queryData);		
		form1.submit();		
	}
	
	//新增按鈕
	function doAdd(index){
		var APPLY_ID = $F('APPLY_ID') ;
		var TYPE = $F('firstMap_TYPE') ;
		var ID = $F('firstMap_ID') ;
		
		if (APPLY_ID == '' || TYPE == '' || ID == ''){
			alert('無受理編號，無法新增') ;
			return ;
		}		
		
		var datas = getAllDatas(index) ;
		
		var data = {
			APPLY_ID :APPLY_ID ,
			TYPE :TYPE ,
			ID :ID ,
			NO: 'tempNO_'+ NO 	
		} ;
		if (index == 2){
			data.BANK_TYPE = 'A' ;
		}else if (index == 3){
			data.BANK_TYPE = 'B' ;
		}else if (index == 4){
			data.YEAR_RATE= '${DEFAULT_CARD_YEAR_RATE}';
		}
		
		datas.push(data) ;
		NO++ ;
		
		grids[index].load(datas) ;
		if (index == 1){
			$$('#grid_D [TextArea]').each(function(obj){
				obj.style.height=obj.scrollHeight+'px';
			});	
			grids[index].resetDivHeight();
		}
	}
	
	//刪除按鈕(DFEG)
	function doDelete(index,delKey,ITEM,isSubmit,isCARD){	
		
		var delData = checkOne(index) ;
		if (!delData){
			return ;
		}
	
		var grid = grids[index] ;
		var datas = getAllDatas(index) ;
		
		for (i = 0 ; i < datas.length ; i++){
			var data = datas[i] ;
			if (data.NO == delData.NO){
				datas.splice(i,1) ;
				break ;
			}
		}
		
		grid.load(datas) ;

		getSum(true);
	}
	
	//計算合計
	function getSum(isSubmit){
		
		var bigVal = 0;
		///////////////Total_LOAN/////////////
		$$('#grid_E td[name="LOAN_AMT"] input[type="text"]').each(function(obj){
			if(obj.value!=''){
				bigVal += parseInt(obj.value.replace(/,/gi,''));
			}	
		});	
		$$('#grid_F td[name="LOAN_AMT"] input[type="text"]').each(function(obj){
			if(obj.value!=''){
				bigVal += parseInt(obj.value.replace(/,/gi,''));
			}	
		});
		$('Total_LOAN').innerHTML = CSRUtil.$fmt( bigVal ,fmt0,true) ;	
		///////////////Total_YEAR/////////////
		bigVal = 0;
		//$$('#grid_E input[type="text"][id!=""]').each(function(obj){
		//	if(obj.id.indexOf('tempYEAR_E_')>=0){
		//		if(obj.value!=''){
		//			bigVal += parseInt(obj.value.replace(/,/gi,''));
		//		}
		//	}	
		//});
		$$('#grid_E div[id]').each(function(obj){
			if(obj.id.indexOf('tempYEAR_E_')>=0){
				if(obj.innerHTML!=''){
					bigVal += parseInt(obj.innerHTML.replace(/,/gi,''));
				}
			}	
		});
		$$('#grid_F div[id]').each(function(obj){
			if(obj.id.indexOf('tempYEAR_F_')>=0){
				if(obj.innerHTML!=''){
					bigVal += parseInt(obj.innerHTML.replace(/,/gi,''));
				}
			}	
		});
		$$('#grid_G div[id]').each(function(obj){
			if(obj.id.indexOf('tempYEAR_G_')>=0){
				if(obj.innerHTML!=''){
					bigVal += Math.round(parseInt(obj.innerHTML.replace(/,/gi,''))/ 100)/10;
				}
			}	
		});
		$('Total_YEAR').innerHTML = CSRUtil.$fmt( bigVal ,'#,##0.#',true) ;
		///////////////Total_INCOME/////////////
		bigVal = 0;
		$$('#grid_D td[name="INCOME"] input[type="text"]').each(function(obj){
			if(obj.value!=''){
				bigVal += parseInt(obj.value.replace(/,/gi,''));
			}
		});
		$('Total_INCOME').innerHTML = CSRUtil.$fmt( bigVal ,'#,##0',true) ;	

		if (isSubmit){		
			var datas = {
				'Total_INCOME' : $('Total_INCOME').innerHTML.replace(/,/gi,'') ,				
				'Total_YEAR' : $('Total_YEAR').innerHTML.replace(/,/gi,'') 
			} ;

			var params = { datas:Object.toJSON(datas) };
			var successAction = function(resp){
				$('INCOME_EXP_RATE').innerHTML = resp.INCOME_EXP_RATE ;
			};
			ajaxPost( 'getSum', params, successAction);	
		
		}
	}
	
	//試算本公司貸款
	function doTrial_Cathay(tempKey,data){
		var trialData ;
		if (data){
			trialData = data ;
			trialData.YEAR_AMT = $('tempYEAR_E_'+trialData.NO).innerHTML ;
		}else{		
			var trialData = checkOne(2) ;
			if (!trialData){
				return ;
			}			
		}		
		trialData.Total_YEAR = $('Total_YEAR').innerHTML.replace(/,/gi,'') ;
		trialData.Total_INCOME = $('Total_INCOME').innerHTML.replace(/,/gi,'') ;
		
		var params = { data:Object.toJSON(trialData)};
		var successAction = function(resp){					
			if($(tempKey+trialData.NO).type == 'text'){
				$(tempKey+trialData.NO).value = CSRUtil.$fmt(resp.YEAR_AMT , fmt0);
			}else{
				$(tempKey+trialData.NO).innerHTML = CSRUtil.$fmt(resp.YEAR_AMT , fmt0);
			}			

			getSum(true);
		};
		ajaxPost( 'trial', params, successAction);	
	}
	
	//試算其他行庫貸款
	function doTrial(tempKey,data){
		var trialData ;
		if (data){
			trialData = data ;
			trialData.YEAR_AMT = $('tempYEAR_F_'+trialData.NO).innerHTML ;
		}else{		
			var trialData = checkOne(2) ;
			if (!trialData){
				return ;
			}			
		}		
		trialData.Total_YEAR = $('Total_YEAR').innerHTML.replace(/,/gi,'') ;
		trialData.Total_INCOME = $('Total_INCOME').innerHTML.replace(/,/gi,'') ;
		
		var params = { data:Object.toJSON(trialData)};
		var successAction = function(resp){					
			if($(tempKey+trialData.NO).type == 'text'){
				$(tempKey+trialData.NO).value = CSRUtil.$fmt(resp.YEAR_AMT , fmt0);
			}else{
				$(tempKey+trialData.NO).innerHTML = CSRUtil.$fmt(resp.YEAR_AMT , fmt0);
			}			

			getSum(true);
		};
		ajaxPost( 'trial', params, successAction);	
	}
	
	//試算CARD
	function doTrial_CARD(NO){
	
		var bigVal = 0;
		//$$('#grid_E input[type="text"][id!=""]').each(function(obj){
		//	if(obj.id.indexOf('tempYEAR_E_')>=0){
		//		bigVal += parseInt(obj.value.replace(/,/gi,''));
		//	}	
		//});
		$$('#grid_E div[id]').each(function(obj){
			if(obj.id.indexOf('tempYEAR_E_')>=0){
				bigVal += parseInt(obj.innerHTML.replace(/,/gi,''));
			}	
		});
		$$('#grid_F div[id]').each(function(obj){
			if(obj.id.indexOf('tempYEAR_F_')>=0){
				bigVal += parseInt(obj.innerHTML.replace(/,/gi,''));
			}	
		});

		var trialData = $('tempCARD_'+NO).parentNode.parentNode.parentNode.dataObj ;
		trialData.CARD_TYPE = $F('tempCARD_'+NO) ;
		trialData.YEAR_AMT = $('tempYEAR_G_'+NO).innerHTML ;
		trialData.YEAR_RATE = $F('tempYEAR_RATE_'+NO) ;
		trialData.Total_YEAR = bigVal ;
		trialData.Total_INCOME = $('Total_INCOME').innerHTML.replace(/,/gi,'') ;
		if (!trialData.LOAN_AMT || !trialData.YEAR_RATE){	
			return ;
		}

		if (trialData.LOAN_AMT=='NaN' || trialData.YEAR_RATE=='NaN'){	
			return ;
		}
		
		var params = { data:Object.toJSON(trialData)};
		var successAction = function(resp){
			$('tempYEAR_G_'+NO).innerHTML = CSRUtil.$fmt(resp.YEAR_AMT , fmt0);			
			
			getSum(true);
		};
		ajaxPost( 'trialCARD', params, successAction);		
	}
	
	//新增
	function doAdd_All() {
		var A_APPLY_ID = $F('APPLY_ID') || '' ;
		var C_APPLY_ID = $('firstMap_APPLY_ID').innerHTML || '' ;

		//畫面程序檢核
		if (!A_APPLY_ID){
			alert('請輸入受理編號') ;
			return ;
		}else if (!C_APPLY_ID){
			alert('請先查詢，再做新增、刪除、修改') ;
			return ;
		}else if (IS_DATA != 'N' && A_APPLY_ID == C_APPLY_ID){
			alert('資料已存在，無法新增!') ;
			return ;		
		}else if (A_APPLY_ID != C_APPLY_ID){
			if(!confirm('受理編號不一致，請確認是否將資料新增到受理編號'+A_APPLY_ID+'中?')){
				return ;		
			}
		}else if($('Total_YEAR').innerHTML <=0){
			alert('本金與利息支出合計不得為0') ;
			return ;
		}else if( grids[1].getAllRecords().size() == 0){
			alert('收入部分至少要有一筆資料') ;
			return ;
		}

		doAction('add');
	}

	//修改
	function doUpdate_All() {
		var A_APPLY_ID = $F('APPLY_ID') || '' ;
		var C_APPLY_ID = $('firstMap_APPLY_ID').innerHTML || '' ;
	
		//畫面程序檢核
		if (!C_APPLY_ID){
			alert('請先查詢，再做新增、刪除、修改') ;
			return ;
		}else if (IS_DATA != 'Y' ){
			alert('請先新增資料後，再做刪除、修改!') ;
			return ;		
		}else if (A_APPLY_ID != C_APPLY_ID){
			alert('欲異動的受理編號:'+A_APPLY_ID+'與原先查詢的'+C_APPLY_ID+'不同，請重新查詢') ;
			return ;
		}else if($('Total_YEAR').innerHTML <=0){
			alert('本金與利息支出合計不得為0') ;
			return ;
		}else if( grids[1].getAllRecords().size() == 0){
			alert('收入部分至少要有一筆資料') ;
			return ;
		}

		doAction('update');
	}	

	//刪除
	function doDelete_All() {
		var A_APPLY_ID = $F('APPLY_ID') || '' ;
		var C_APPLY_ID = $('firstMap_APPLY_ID').innerHTML || '' ;
	
		//畫面程序檢核
		if (!C_APPLY_ID){
			alert('請先查詢，再做新增、刪除、修改') ;
			return ;
		}else if (IS_DATA != 'Y' ){
			alert('請先新增資料後，再做刪除、修改!') ;
			return ;		
		}else if (A_APPLY_ID != C_APPLY_ID){
			alert('欲異動的受理編號:'+A_APPLY_ID+'與原先查詢的'+C_APPLY_ID+'不同，請重新查詢') ;
			return ;
		}else if (!confirm('確定刪除'+C_APPLY_ID+',評估對象'+$('firstMap_NAME').getValue()+'的本息支出/收入比?')){<%--[202401729]難字調整，改用input readonly --%>
			return ;
		}			

		doAction('delete');
	}

	function doAction(action) {
		var A_APPLY_ID = $F('APPLY_ID') || '' ;
		var C_APPLY_ID = $('firstMap_APPLY_ID').innerHTML || '' ;

		var B_data = grids[0].getCheckedRecord()[0] ;
		var reqMap = getDatas(A_APPLY_ID, B_data);

		var chkMap = {
			  'APPLY_ID'     : A_APPLY_ID
			, 'QRY_ID'       : B_data['ID']
			, 'SUM_YEAR_AMT' : $('Total_YEAR').innerHTML.replace(/,/gi, '')
		};

		var msg = '';
		if (action == 'update' || action == 'add') {
			msg = checkInputD(reqMap.A152_List);
			msg = checkInputEF(msg, 'E', reqMap.A153_ListA);
			msg = checkInputEF(msg, 'F', reqMap.A153_ListB);
			msg = checkInputG(msg, reqMap.A158_List);
		}

		if (msg) {
			alert(msg);
			return;
		}

		var params = { reqMap:Object.toJSON(reqMap) ,chkMap:Object.toJSON(chkMap) , info:Object.toJSON({'APPLY_ID':A_APPLY_ID,'QRY_ID':B_data.ID}) };

		ajaxPost(action, params, successAction);
	}

	function getDatas(A_APPLY_ID, B_data) {
		var reqMap = {
			  APPLY_ID   : A_APPLY_ID
			, QRY_ID     : B_data.ID
			, QRY_NAME   : B_data.NAME
			, TYPE       : B_data.TYPE
			, A152_List  : getAllDatas(1)
			, A153_ListA : getAllDatas(2)
			, A153_ListB : getAllDatas(3)
			, A158_List  : getAllDatas(4)
		};

		return reqMap;
	}

	function successAction(resp) {
		QRY_ID = resp.QRY_ID;
		IS_DATA = resp.IS_DATA;

		grids[0].load(resp.A020_List, null, null, [QRY_ID]);
		grids[1].load(resp.A152_List);
		grids[2].load(resp.A153_ListA);
		grids[3].load(resp.A153_ListB);
		grids[4].load(resp.A158_List);

		$$('#grid_D [TextArea]').each(function(obj) {
			obj.style.height = obj.scrollHeight + 'px';
		});	
		grids[1].resetDivHeight();

		$('firstMap_APPLY_ID').innerHTML = resp.firstMap.APPLY_ID ;
		$('firstMap_NAME').setValue(resp.firstMap.NAME);<%--[202401729]難字調整，改用input readonly --%>
		$('firstMap_ID').value = resp.firstMap.ID ;
		$('firstMap_TYPE').value = resp.firstMap.TYPE ;
		$('Total_INCOME').innerHTML = CSRUtil.$fmt(resp.sumList[0] ,fmt0) ;
		$('Total_LOAN').innerHTML = CSRUtil.$fmt(resp.sumList[1] ,fmt0) ;
		$('Total_YEAR').innerHTML = CSRUtil.$fmt(resp.sumList[2] ,fmt0) ;
		$('INCOME_EXP_RATE').innerHTML = resp.sumList[3] ;
	}
	
	function errorAction(resp){		
		QRY_ID = '' ;
		IS_DATA = '' ;
		grids[0].load([]);
		grids[1].load([]);
		grids[2].load([]);
		grids[3].load([]);
		grids[4].load([]);
		
		$('firstMap_APPLY_ID').innerHTML = '' ;
		$('firstMap_NAME').setValue('');<%--[202401729]難字調整，改用input readonly --%>
		$('firstMap_ID').value = '' ;
		$('firstMap_TYPE').value = '' ;
		$('Total_INCOME').innerHTML = '' ;
		$('Total_LOAN').innerHTML = '' ;
		$('Total_YEAR').innerHTML = '' ;
		$('INCOME_EXP_RATE').innerHTML = '' ;
	};
		
	//--------------------------------------------------------------------------	
	//	檢核Function
	//--------------------------------------------------------------------------
	function checkAPPLY_ID() {
		validator.clear();
		if (!$F('APPLY_ID')){
			validator.define('APPLY_ID','受理編號','請輸入正確受理編號', returnFalse);
		}	
		return validator.validate();
	}
	
	function returnFalse(){
		return false ;
	}
	
	//檢查D區不得為空的值
	function checkInputD( datas ) {
		var msg = '';
		var INCOME_NAMEvalue = '';
		var INCOME_ITEMvalue = '';
		for (i = 0 ; i < datas.length ; i++) {
			var data = datas[i];
			INCOME_NAMEvalue = data['INCOME_NAME'];
			INCOME_ITEMvalue = data['INCOME_ITEM'];
			if (!INCOME_NAMEvalue) {
				msg = '當事人';
			}
			if (INCOME_NAMEvalue) {
				if (!validation.checkInputLength( INCOME_NAMEvalue , 60 )) {
					msg += (((msg) ? '，' : '')+'當事人長度不可大於60');
				}
			}

			if (!INCOME_ITEMvalue) {
				if (msg) {
					msg += '、' ;
				}
				msg += '收入項目';
			}

			if (msg) {
				msg += '不得為空值';
			}
			if (INCOME_ITEMvalue) {
				if (!validation.checkInputLength( INCOME_ITEMvalue , 20 )) {
					msg += (((msg) ? '，' : '')+'收入項目長度不可大於20');
				}
			}

			var value = data['INCOME'];
			<%-- [20240301]問題單：簽件作業分頁中修改時未正確觸發檢核 --%>	
			if (!value || isNaN(value) || value === 0) {
				msg += (((msg) ? '，' : '') + '年所得必須為數值，且不得為零') ;
			}

			if (!validation.checkInputLength( data['INCOME_MSG'] , 1000 )){
				msg += (((msg) ? '，' : '')+'說明長度不可大於1000') ;
			}

			if (msg) {
				return '[收入部分]' + msg ;
			}
		}
		return msg;		
	}

	//檢查EF區不得為空的值
	function checkInputEF(msg, groupType, datas) {
		var msg1 = '' ;
		var BANK_NAMEvalue = '';
		for (i = 0 ; i < datas.length ; i++) {
			var data = datas[i];
			BANK_NAMEvalue = data['BANK_NAME'];
			if (!BANK_NAMEvalue) {
				msg1 = (groupType == 'E') ? '本公司貸款不得為空白' : '其他行庫貸款不得為空白' ;
			}
			if (BANK_NAMEvalue) {
				if (!validation.checkInputLength( data['BANK_NAME'] , 80 )) {
					msg1 += (((msg1) ? '，' : '') + ((groupType == 'E') ? '本公司貸款' : '其他行庫貸款') + '長度不可大於80');
				}
			}

			var theLOAN_AMT = data['LOAN_AMT'];
			var theRATE = data['RATE'];
			var theLOAN_PERIOD = data['LOAN_PERIOD'];

			<%-- [20240301]問題單：簽件作業分頁中修改時未正確觸發檢核 --%>
			if (!theLOAN_AMT || isNaN(theLOAN_AMT) || theLOAN_AMT === 0
				|| !theRATE || isNaN(theRATE) || theRATE === 0
				|| !theLOAN_PERIOD || isNaN(theLOAN_PERIOD) || theLOAN_PERIOD === 0) {

				msg1 += (((msg1) ? '，' : '') + ((groupType == 'E') ? '本公司貸款' : '其他行庫貸款') + '金額(仟)、利率%、年期(期數)必須為數值且不得為零');
			}

			var value = data['YEAR_AMT'];

			if (!value || isNaN(value) || value <= 0){
				msg1 += (((msg1) ? '，' : '') + '本息金額必須為數值且不得為0');
			}

			if (msg1) {
				return msg + ((groupType == 'E') ? '\n[本金與利息支出估計-本公司]' : '\n[本金與利息支出估計-其他行庫]') + msg1 ;
			}
		}

		return msg;		
	}

	//檢查G區不得為空的值
	function checkInputG(msg, datas ){
		var msg1 = '' ;
		for (i = 0 ; i < datas.length ; i++){
			var data = datas[i] ;  
			var value = data['LOAN_AMT']  ;
			if (!value || isNaN(value) || value <= 0){
				msg1 = '金額' ;
			}
			value = data['YEAR_RATE']  ;
			if (!value || isNaN(value) || value <= 0){
				msg1 = msg1 + ((msg1) ? '、' : '' ) + '利率' ;
			}
			if (msg1){
				return msg + '\n[本金與利息支出估計-卡片]' + msg1 +'必須為數值且不得為0' ;
			}
		}		
		return msg;		
	}
	
	//檢查是否選取一筆資料
	function checkOne(index){
		var data = getAllDatas(index,true)  ;
		if (data.length == 0 ){
			alert('請選取一筆資料') ;
			return false ;
		}
		
		return data[0] ;
	}
	
	//有自己建的input時   取得records
	function getAllDatas(index, isOne) {
		var datas;
		if (isOne){
			datas = grids[index].getCheckedRecord() ;
		}else{
			datas = grids[index].getAllRecords() ;
		}
		
		var tempKeys = getDatatemp[index-1] ;
		var keys = getData[index-1] ;
		for (i = 0 ; i < datas.length ; i++){

			var data = datas[i] ;
			var dataNO = data.NO ;
			data.ID = data.ID || QRY_ID ;
			for (j = 0 ; j < tempKeys.length ; j++){
				var elem = $(tempKeys[j]+dataNO);
				if(!elem){ continue; } 				
				if(elem.type=='textarea'){
					//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==S==
					if(elem.value.length>0){
						elem.value = elem.value.replace(/'/gi, "").replace(/"/gi, "");
						while(true){
							ln0 = elem.value.length;
							while(true){
								ln1 = elem.value.length;
								if(elem.value.indexOf('\r\n')>=0){
									//trim掉最後一個\r\n
									elem.value = elem.value.replace(/\r\n$/g, "");
									if(ln1 == elem.value.length){
										break;	
									}
								}else{
									break;
								}
							}
							while(true){
								ln2 = elem.value.length;
								if(elem.value.indexOf(' ')>=0){
									elem.value = $elem.value.replace(/ $/g, "");
									if(ln2 == elem.value.length){
										break;	
									}
								}else{
									break;
								}
							}
							if(ln0 == elem.value.length){
								break;	
							}
						}
					}
					//==檢核欄位輸入的資料包含單引號或字尾有空白或換行需trim==E==
					data[keys[j]] = elem.value ;
				}else if(elem.type!='text'){
					data[keys[j]] = elem.innerHTML.replace(/,/gi,'') ;
				}else{
					data[keys[j]] = elem.value.replace(/,/gi,'') ;
				}
			}
			
			if(index == 4){				
				data.CARD_TYPE = $('tempCARD_'+data.NO).value;
			}
		}
		
		
		return datas ;		
	}

	return {
		'init' : function() {
			initTableUI();

			autoFormatToNumber() ;
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery(true);					
				}                        
			);
			
			//A區新增
			$('btn_add').observe('click', function(event) { doAdd_All(); } );
			//A區修改
			$('btn_update').observe('click',function(event){                                        
					doUpdate_All() ;				
				}                        
			);			
			//A區刪除
			$('btn_delete').observe('click', function(event) { doDelete_All(); } );
			
			//列印
			$("btn_print").observe('click',function(event){
					doPrint();
				}
			);
			
			//試算
			//$('btn_trial').observe('click',function(event){
			//		doTrial('tempYEAR_E_') ;
			//	}
			//) ;
			
			//新增
			$('btn_add_D').observe('click',function(event){                                        
					doAdd(1);
				}                        
			);
			$('btn_add_E').observe('click',function(event){                                        
					doAdd(2);
				}                        
			);
			$('btn_add_F').observe('click',function(event){                                        
					doAdd(3);
				}                        
			);
			$('btn_add_G').observe('click',function(event){                                        
					doAdd(4);
				}                        
			);
			
			//刪除
			$('btn_delete_D').observe('click',function(event){                                        
					doDelete(1,'INCOME','Total_INCOME',true,false);					
				}                        
			);
			$('btn_delete_E').observe('click',function(event){                                        
					doDelete(2,'YEAR_AMT','Total_YEAR',true,false);					
				}                        
			);
			$('btn_delete_F').observe('click',function(event){                                        
					doDelete(3,'YEAR_AMT','Total_YEAR',true,false);										
				}                        
			);
			$('btn_delete_G').observe('click',function(event){                                        
					doDelete(4,'YEAR_AMT','Total_YEAR',true,true);										
				}                        
			);


			if ('${APPLY_ID}' != "") {
				$('APPLY_ID').value = '${APPLY_ID}';
			} else { 
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}						
			if($('APPLY_ID').value){
				doQuery(true);	
			}
		}                 
	};
}

<%--Define UI Class End--------------------------------------------------------%>
//-->
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" name="form1" method="post">
		<input type="hidden" id="firstMap_ID" name="firstMap_ID" value="">
		<input type="hidden" id="firstMap_TYPE" name="firstMap_TYPE" value="">
		<input type="hidden" id="queryData" name="queryData" value="">

		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
			<tr>
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="85%">
					<input type="text" class="textBox2" size="15" maxlength="11" name="APPLY_ID" id="APPLY_ID" value="" /> 
					<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
				</td>
			</tr>
			<tr>
				<td align="center" colspan="2">
					<input type="button" class="button" id="btn_add"    name="btn_add"   value="新增">
					<input type="button" class="button" id="btn_update" name="btn_update" value="修改"> 
					<input type="button" class="button" id="btn_delete" name="btn_delete" value="刪除">
					<input type="button" class="button" id="btn_print"  name="btn_print"  value="列印">
				</td>
			</tr>
		</table>
		<table id="grid_B" class="grid"></table>

		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
			<tr>
				<th class="tbYellow0" colspan=4>案件資料</th>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="35%" id="firstMap_APPLY_ID"></td>
				<td class="tbYellow" width="15%">評估對象</td>
				<td class="tbYellow2" width="35%"><input id="firstMap_NAME" alt='ch' class="textDisable" readonly="readonly" /></td><%--[20240729]難字調整 --%>
			</tr>
		</table>
		<table id="grid_D" class="grid"></table>

		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
			<tr>
				<td align="center" class="tbYellow2">
					<input id="btn_add_D" name="btn_add" type="button" class="button" value="新增"> 
					<input id="btn_delete_D" name="btn_delete" type="button" class="button" value="刪除">
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<b>總收入合計</b> 
					<!--  <input type="text" datatype="number" class="textBox2" size="15" name="Total_INCOME" id="Total_INCOME" />-->
					<span id="Total_INCOME" style="background-color: Sandybrown;"> </span>
					<b> 萬/年</b>
				</td>
			</tr>
		</table>

		<table id="grid_E" class="grid"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableD">
			<tr>
				<td align="center" class="tbYellow2">
					<input type="button" class="button" id="btn_add_E"    name="btn_add"    value="新增"> 
					<input type="button" class="button" id="btn_delete_E" name="btn_delete" value="刪除">
				</td>
			</tr>
		</table>
		<table id="grid_F" class="grid"></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableE">
			<tr>
				<td align="center" class="tbYellow2">
					<input type="button" class="button" id="btn_add_F"    name="btn_add"    value="新增"> 
					<input type="button" class="button" id="btn_delete_F" name="btn_delete" value="刪除">
				</td>
			</tr>
			<tr>
				<td class="tbYellow2">
					<b>合計貸款金額</b> <!-- <input type="text" datatype="number" class="textBox2" size="15" name="Total_LOAN" id="Total_LOAN" /> --> 
					<span id="Total_LOAN" style="background-color: Sandybrown;"> </span>
					<b> 仟/年</b>
				</td>
			</tr>
		</table>

								<table id="grid_G" class="grid"></table>
								<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableF">
									<tr>
										<td align="center" class="tbYellow2">
											<input id="btn_add_G" name="btn_add" type="button" class="button" value="新增"> 
											<input id="btn_delete_G" name="btn_delete" type="button" class="button" value="刪除">
										</td>
									</tr>
									<tr>
										<td class="tbYellow2">
											<b>本金與利息支出合計</b> 
											<!-- <input type="text" datatype="number" class="textBox2" size="15" name="Total_YEAR" id="Total_YEAR" />  -->
											<span id="Total_YEAR" style="background-color: Sandybrown;"> </span>
											<b> 仟/年</b>
										</td>
									</tr>
									<tr>
										<td class="tbYellow2">
											<b>＊本金與利息支出∕總收入</b> 
											<!--<input type="text" datatype="number" class="textBox2" size="15" name="INCOME_EXP_RATE" id="INCOME_EXP_RATE" /> -->
											<span id="INCOME_EXP_RATE" style="background-color: Sandybrown;"> </span>
											<b> %(依申貸計算)</b>
										</td>
									</tr>
								</table>
	</form>
</body>
</html>
