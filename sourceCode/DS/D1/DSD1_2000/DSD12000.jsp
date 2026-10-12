<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSD12000.jsp
作者：卓達瑋
功能：客戶資料維護
完成：2013/10/28

[20240327]難字
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
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	      <%-- 地址用 --%>

<%-- [20240327]難字 --%>
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
var DSD12000 = new DSD12000();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSD12000.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD12000(){
	
	// 資料來源A:催收作業、B:法務作業、C:倉儲行銷資料
	var DATA_SRC = '${DATA_SRC}';
	//下拉選單
	var TEL_KIND_MAP={};
	var TEL_AREA_MAP={};
    var addr_control=[];
	//Table UI
	var grid;	
	var grid1;	
	var grid2;
	var gridE;
	var gridF;
	var quarMap={};
	var TelList=[];
	//檢核
	var valid1;		
    var validADDR;
	//畫面檢核
	function initValidation(){		
		//查詢用檢核
		Validation.addAllThese([
			[ 'TEL_NUM_required', '請輸入號碼', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];

					return !checks || v;
					
				}
			],
			[ 'NUMBER_required', '請輸入0~9的數字', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    return Validation.get('IsEmpty').test(v) || /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);
					}
					return true;
					
				}
			],
			[ 'select_AREA_required', '請選擇區碼', 
				function(v,elem){ 
					var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
                    if(checks){
					    return !Validation.get('IsEmpty').test(v) || elem.selectedIndex > 0;
					}
					return true;
					
				}
			]
			
			
		]);
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
	    validADDR = new Validation("form", { focusOnError:true, immediate:false, mode:'validator'});	
	}
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert" ,				
				B0004:"btn_update" ,
				B0005:"btn_delete",
                B0028:"btn_confirm"				
		};
	
		<dz:grantButtons FUNC_ID="DSD12000" />
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSD1_2000/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	
	
	//按鈕功能
	var buttons = {
	
		//查詢
		doQuery : function(){	
		    if(!$F('REFER_ID')&&!$F('LOAN_ID')&&!$F('QID')&&!$F('QNAME')){
			    alert("請至少輸入一項查詢條件");
			    return;
			}
			//發送ajax
			ajaxPost( 'query' , { reqMap : Object.toJSON(actions.queryMap())},
				function(resp){	
					grid.load(resp.rtnList || []);
                    grid1.load([]);
                    grid2.load([]);
                    gridE.load([]);
                    gridF.load([]);
				},
				function(resp){
					grid.load([]);	
					grid1.load([]);
                    grid2.load([]);
                    gridE.load([]);
                    gridF.load([]);
				} 
			);				
		},
	    //確認
		doConfirm : function(event){
		    
			var querymap_ID=quarMap.ID||'';

			if(!querymap_ID){
			    alert("請先選取借款人或保證人");
			    return;
			}
			var inputdata = grid1.getAllRecords();
			/*
			var doNotCheckColumn = {
				'CITY_NAME': 'CITY_NAME',
				'TOWN_NAME': 'TOWN_NAME',
				'INPUT_ZIPCODE': 'INPUT_ZIPCODE'	
			};
			*/
	       	var INPUT_ADDR=addr_control['1'].getINPUT_ADDR();	
			var INPUT_ZIPCODE=addr_control['1'].getINPUT_ZIPCODE();	
			
			if(!INPUT_ADDR){
			    alert("地址不可為空");
			    return;
			}
			if(!INPUT_ZIPCODE){
			    alert("請選擇正確縣市別與鄉鎮區");
			    return;
			}
			/* 
			
			Object.keys(addr_control).each(
				function(key){
                    alert(key);
					alert(Object.toJSON(addr_control[key].getINPUT_ADDR()));	
                    validADDR.reset();							
					addr_control[key].checkData(validADDR,doNotCheckColumn);
				}
			);		
            
			if(!validADDR.validate()){ 				
				return; 
			}
            */ 		
			//發送ajax
			ajaxPost( 'confirm' , { 
					reqMap : Object.toJSON(quarMap),
					inputMap : Object.toJSON(inputdata[0])
				},
				function(resp){		
					grid1.load(resp.rtnList || []);								
				}				
			);	

		},
		//新增
		doInsert : function(event){		
			var querymap_ID=quarMap.ID||'';
			
			if(!querymap_ID){
			    alert("請先選取借款人或保證人");
			    return;
			}
			var inputdata = grid2.getCheckedRecord();
			if(inputdata.length==0){
			    alert("至少須選取一筆資料");
				return;
			}
			valid1.reset();
			if(!valid1.validate()){
				return;
			}

			//發送ajax
			ajaxPost( 'insert' , { 
					reqMap : Object.toJSON(quarMap),
					inputList : Object.toJSON(inputdata)
				},
				function(resp){
                    TelList=resp.telList || [];			
					grid2.load(TelList);								
				}				
			);	
		
		},
		
		//修改
		doUpdate : function(event){
		
			var querymap_ID=quarMap.ID||'';
				
			if(!querymap_ID){
				alert("請先選取借款人或保證人");
				return;
			}
			var inputdata = grid2.getCheckedRecord();
			if(inputdata.length==0){
				alert("至少須選取一筆資料");
				return;
			}
			valid1.reset();
			if(!valid1.validate()){
				return;
			}

			//發送ajax
			ajaxPost( 'update' , { 
					reqMap : Object.toJSON(quarMap),
					inputList : Object.toJSON(inputdata)
				},
				function(resp){	
                    TelList=resp.telList || [];					
					grid2.load(TelList);								
				}				
			);	
			
		
		},
		
		//刪除
		doDelete : function(event){
			var querymap_ID=quarMap.ID||'';
				
			if(!querymap_ID){
				alert("請先選取借款人或保證人");
				return;
			}
			var inputdata = grid2.getCheckedRecord();
			if(inputdata.length==0){
				alert("至少須選取一筆資料");
				return;
			}
			if(!confirm('是否確認刪除?')){
				return;			
			}
			//發送ajax
			ajaxPost( 'delete' , { 
					reqMap : Object.toJSON(quarMap),
					inputList : Object.toJSON(inputdata)				
				},
				function(resp){		
					TelList=resp.telList || [];
					grid2.load(resp.telList || []);								
				},
				function(resp){
					TelList=[];
					grid2.load(TelList);								
				}
			);	
		
		
		},
		
		//下層的新增
		doInsertUnder : function(event){
			//valid1.reset();
			
			var querymap_ID=quarMap.ID||'';

			if(!querymap_ID){
			    alert("請先選取借款人或保證人");
			    return;
			}
			var voList = grid2.getAllRecords();
			var tmpMap = {};
			tmpMap.ID=querymap_ID;
			tmpMap.SEQ_NO='0';
			tmpMap.NAME=quarMap.NAME||'';
			tmpMap.DATA_SRC=quarMap.DATA_SRC||'';
			tmpMap.TEL_KIND='A';
			voList.push(tmpMap);
			grid2.load(voList);
		},
		<%--E區和F區的匯入--%>
		doImport: function(type){
		
			var querymap_ID=quarMap.ID||'';
				
			if(!querymap_ID){
				alert('請先選取借款人或保證人');
				return;
			}
			
			var inputList = [];
			if('E' == type){
				inputList = gridE.getCheckedRecord();
			}else{
				inputList = gridF.getCheckedRecord();
			}
			if(inputList.length == 0){
				alert('至少須選取一筆資料');
				return;
			}
			
			ajaxPost( 'import' , { reqMap : Object.toJSON(quarMap), inputList: Object.toJSON(inputList), BLOCK: type},
				function(resp){	
					TelList=resp.telList || [];
					grid2.load(resp.telList || []);					
				},
				function(resp){
					TelList=[];
					grid2.load(TelList);					
				} 
			);
		}
		
	}
	
	//各種action
	var actions = {				
		
		//將畫面查詢條件寫入Map	
	    queryMap : function(){
			return  {
				'LOAN_ID' : $F('LOAN_ID'), 
				'REFER_ID' : $F('REFER_ID'), 
				'QID' : $F('QID'),
                'QNAME' : $F('QNAME') 				
			}		
	    },
		
		//產生TableUI裡面的select與input欄位
		makeElement : function(type , inputName , inputValue,SEQ_NO,grid){
            var  id;
			if(SEQ_NO){
			    id=inputName+SEQ_NO;
			}else{
			    id=inputName
			}
			
			if( type == 'select'){
				var SELECT = new Element('SELECT' , {className : 'textBox2' , fieldName : '',id:id});
				if(inputName=='TEL_KIND'){
				     //下拉選單欄位
					for(key in TEL_KIND_MAP){
						SELECT.add(new Option(TEL_KIND_MAP[key],key ));	
					}
				
					
				}else{
				    SELECT.setAttribute( 'className' , 'textBox2 select_AREA_required');
					
					SELECT.add(new Option("",""));	
					for(key in TEL_AREA_MAP){
						SELECT.add(new Option(TEL_AREA_MAP[key],key ));	
					}
				
				
				}
				//註冊事件
				SELECT.observe('change' , function(event){
				    var tr = this.up('tr');
					var dataObj;
					if(grid=='grid1' ){
					    dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
					
					}else{
					    dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];			
					}					
					//動態將值直接改掉
					var targetvalue= event.target.value;
				    dataObj[inputName] = targetvalue;
                    //if選擇手機(E)，則區碼(顯示空白)、分機DISABLE，不可輸入            
					if(inputName=='TEL_KIND'){
					    if(targetvalue=='E'){
						    $("TEL_AREA"+SEQ_NO).update("");
						    $("TEL_EXT"+SEQ_NO).disable();     
						    $("TEL_AREA"+SEQ_NO).disable();
							//$("TEL_NUM"+SEQ_NO).setValue("");
							$("TEL_EXT"+SEQ_NO).setValue("");

						}else{
						    for(key in TEL_AREA_MAP){
								 $("TEL_AREA"+SEQ_NO).add(new Option(TEL_AREA_MAP[key],key ));	
							}
						    $("TEL_EXT"+SEQ_NO).enable();     
						    $("TEL_AREA"+SEQ_NO).enable();
						
						}
					}
				});
				SELECT.value=inputValue;
				
				
				return SELECT;
			}else if(type =='input'){
				
				//產生INPUT欄位的共用方法
				var INPUT = new Element('INPUT' , {className : 'textBox2' , value : inputValue ||'' , size : '12' ,id:id ,fieldName : ''});			
				//動態將值直接改掉
				if( inputName == 'TEL_EXT'){						
					INPUT.setAttribute( 'maxLength' , 6);
					 INPUT.setAttribute( 'className' , 'textBox2 NUMBER_required');			
				}
				if( inputName == 'NOTE'){
                    INPUT.setAttribute( 'size' , 50);
					INPUT.setAttribute( 'maxLength' , 200);
                    INPUT.setAttribute( 'fieldName' , '備註');									
				}
				if( inputName == 'TEL_NUM'){
					INPUT.setAttribute( 'maxLength' , 15);	
                    INPUT.setAttribute( 'className' , 'textBox2 TEL_NUM_required NUMBER_required');					
				}
				
				
				INPUT.observe('change' , function(event){
					var tr = this.up('tr');
					var dataObj ;
					//動態將值直接改掉
					if(grid=='grid1' ){
					    dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];						
					
					}else{
					    dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];			
					}
				    dataObj[inputName] = event.target.value;
					
				});
				return INPUT;
			}		
		}
		
	};
	
	//控制div開關
	var layout = {
		showBlock_E: function(){
			if($('block_E').style.display != 'none'){
				$('block_E').style.display = 'none';
			}else{
				$('block_E').style.display = 'block';
			}
		},
		showBlock_F: function(){
			if($('block_F').style.display != 'none'){
				$('block_F').style.display = 'none';
			}else{
				$('block_F').style.display = 'block';
			}
		}
	}
	
	return {

			initApp : function() {
				
				var noPageFrame = '${FUNC_ID}' == 'DSD11800' ?  true : false;	
				PageUI.createPageWithAllBodySubElement("DSD12000", "逾繳催收", "客戶資料維護", 0,noPageFrame);	
				
				//table A
				grid = new TableUI ( {
					table: $('grid'),  allSortable:false, pageSize: 10,
					
					<%-- [20240327]難字 --%>
		            afterLoad: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
							
					column: [										
							{header: '原貸帳號' , key : 'REFER_ID'},
							{header: '貸款帳號' , key : 'LOAN_ID'},
							{header: '借款人' , key : 'BORROW_NAME', attrs:{ style:"font-family:'EUDC'" },<%-- [20240327]難字 --%>
								render : function (rec , val){
									var SPAN = new Element('SPAN' );									
										var link = new Element( 'a' , { href : "#" ,id :rec.BORROW_ID+rec.REFER_ID} ).update(val);
										link.observe('click', function(){
							                
											validADDR.reset();
											quarMap.ID=rec.BORROW_ID;
											quarMap.NAME=val;
											quarMap.DATA_SRC=DATA_SRC;
											quarMap.TYPE="0";
											//發送ajax
											
											ajaxPost( 'query2' , { reqMap : Object.toJSON(quarMap)},
												function(resp){	
												    TEL_KIND_MAP=resp.TEL_KIND_LIST||{};
													TEL_AREA_MAP=resp.TEL_AREA_LIST||{};
													TelList=resp.telList || [];
													var rntList=resp.rtnList || [];
													var mtelList = resp.mtelList || [];
													var ctelList = resp.ctelList || [];
													if(rntList.length==0){
														var rtnMaptemp={};
														rtnMaptemp.ID=quarMap.ID;
														rtnMaptemp.DATA_SRC=quarMap.DATA_SRC;
														rtnMaptemp.NAME=quarMap.NAME;	
														rntList.push(rtnMaptemp);
													}
													grid1.load(rntList);	
													grid2.load(TelList);
													gridE.load(mtelList);	
													gridF.load(ctelList);	
												   
												},
												function(resp){	
													TEL_KIND_MAP=resp.TEL_KIND_LIST||{};
													TEL_AREA_MAP=resp.TEL_AREA_LIST||{};
													TelList=resp.telList || [];
													var rntList=resp.rtnList || [];
													var mtelList = resp.mtelList || [];
													var ctelList = resp.ctelList || [];
							
													if(rntList.length==0){
									
														var rtnMaptemp={};
														rtnMaptemp.ID=quarMap.ID;
														rtnMaptemp.DATA_SRC=quarMap.DATA_SRC;
														rtnMaptemp.NAME=quarMap.NAME;	
														rntList.push(rtnMaptemp);
													}
													grid1.load(rntList);	
													grid2.load(TelList);
													gridE.load(mtelList);	
													gridF.load(ctelList);	
												
												}
												
												
											);	
										
										
										});
			                            return link;
								}
							},
                            {header: '保證人' , key : 'guarList', attrs:{ style:"font-family:'EUDC'" },<%-- [20240327]難字 --%>
								render : function (rec , val){
									var SPAN = new Element('SPAN' );
										//創兩個input , ID跟NAME
									
									var guarList=rec.guarList||[];

									
									for(var i = 0 ; i < guarList.length ; i++){
										if(i!=0){
										     SPAN.insert("、"); 
										}
										var link = new Element( 'a' , { href : "#",id:guarList[i].ID+rec.LOAN_ID ,guarList_ID:guarList[i].ID,guarList_NAME:guarList[i].NAME }).update(guarList[i].NAME);
											link.observe('click', function(event){
					 
											quarMap.ID=event.target.getAttribute("guarList_ID");
											
											quarMap.NAME=event.target.getAttribute("guarList_NAME");
											quarMap.DATA_SRC=DATA_SRC;
											quarMap.TYPE="1";
											//發送ajax
											ajaxPost( 'query2' , { reqMap : Object.toJSON(quarMap)},
													function(resp){	
													    
													    TEL_KIND_MAP=resp.TEL_KIND_LIST||{};
													    TEL_AREA_MAP=resp.TEL_AREA_LIST||{};
														TelList=resp.telList || [];
														var rntList=resp.rtnList || [];
														var mtelList = resp.mtelList || [];
														var ctelList = resp.ctelList || [];
														if(rntList.length==0){
														  
															var rtnMaptemp={};
															rtnMaptemp.ID=quarMap.ID;
															rtnMaptemp.DATA_SRC=quarMap.DATA_SRC;
															rtnMaptemp.NAME=quarMap.NAME;	
														    rntList.push(rtnMaptemp);
														}
														grid1.load(rntList);	
														grid2.load(TelList);
														gridE.load(mtelList);	
														gridF.load(ctelList);												        
														
													},
													function(resp){	
														TEL_KIND_MAP=resp.TEL_KIND_LIST||{};
													    TEL_AREA_MAP=resp.TEL_AREA_LIST||{};
														TelList=resp.telList || [];
														var rntList=resp.rtnList || [];
														var mtelList = resp.mtelList || [];
														var ctelList = resp.ctelList || [];
														
														if(rntList.length==0){
															var rtnMaptemp={};
															rtnMaptemp.ID=quarMap.ID;
															rtnMaptemp.DATA_SRC=quarMap.DATA_SRC;
															rtnMaptemp.NAME=quarMap.NAME;	
														    rntList.push(rtnMaptemp);
														}
														grid1.load(rntList);	
														grid2.load(TelList);
														gridE.load(mtelList);	
														gridF.load(ctelList);		
													
													}
												);	

											});
											SPAN.insert(link); 
                                        										
									}	
								    return SPAN;
								}
							}	

							
						]			
				});	
				
				//table B
				grid1 = new TableUI ( {
					table: $('grid1'),  allSortable:false,title:'戶籍地址', 
					
					<%-- [20240327]難字 --%>
		            afterLoad: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
					
					column: [										
						//	{header: '案件種類' , key : 'CASE_KIND_NM' , groupKey : ['SEQ_NO']},
							{header: '姓名' , key : 'NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header: '郵遞區號' , key : 'REG_ZIP'},
							{header: '地址' , key : 'REG_ADDR',
								render : function( rec , val){		
								//var city = val.substring(0,3);
								//var town = val.substring(3,5);						
								var span = new Element('span',{id:"1",className : 'textBox2 required', alt:"ch"});<%-- [20240327]難字 --%>
								var CR_ADDR = new DSZ01000(span, '1');  
								CR_ADDR.display4INPUT_ZIPCODE("3");
								//CR_ADDR.setCITY_NAME(city);
								//CR_ADDR.setTOWN_NAME(town);
								CR_ADDR.setINPUT_ADDR(val);
								CR_ADDR.setINPUT_ZIPCODE(rec.REG_ZIP);	
								
								var obj = CR_ADDR.getAllSelectObject();			
                                obj['INPUT_ADDR'].setAttribute( 'maxLength' , 80);
                                obj['INPUT_ADDR'].setAttribute( 'alt' , 'ch');<%-- [20240327]難字 --%>
								obj['TOWN_NAME'].observe('click', function(event){
										
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.REG_ADDR = CR_ADDR.getINPUT_ADDR();									
                                        dataObj.REG_ZIP = CR_ADDR.getINPUT_ZIPCODE();
                                        var span_B=$(tr).select('td[name=REG_ZIP]')[0];
										span_B.update(CR_ADDR.getINPUT_ZIPCODE());
										
								}); 
							
								
							    obj['INPUT_ADDR'].observe('blur', function(event){
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.REG_ADDR = this.value;										
                                        dataObj.REG_ZIP = CR_ADDR.getINPUT_ZIPCODE();									
								        CR_ADDR.setINPUT_ADDR(this.value);
								});
							
								addr_control[span.id] = CR_ADDR;	
								return span;  
								}
							},
							{header: '備註' , key : 'NOTE',
							    render : function (rec , val){
                                return actions.makeElement('input','NOTE',val,'','grid1');
							
							}},
							{header:"最後異動人員", key:'LST_PROC_NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header:"最後異動日期", key:'LST_PROC_DATE',
								render :function(record,value){
									return Date.toROC( value|| '');
								}
							}					
						]
									
				});	
				//table B
				grid2 = new TableUI ( {
					table: $('grid2'),  allSortable:false,title:'連絡電話', 
					
					<%-- [20240327]難字 --%>
		            afterLoad: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
					
					autoCheckBox:{						
						type :"checkbox"          
					},
                    afterLoad: function(ele){
						for( var i = 0 ; i < TelList.length ; i++ ){
							if(TelList[i].TEL_KIND=='E'){
							    
								var SEQ_NO=TelList[i].SEQ_NO||'';
								$("TEL_EXT"+SEQ_NO).disable();     
								$("TEL_AREA"+SEQ_NO).disable();
								
							}
				        }

					},
					column: [										
							{header: '姓名' , key : 'NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header: '種類' , key : 'TEL_KIND',
							    render : function( rec , val){		
								    //製作種類下拉選單
									var SELECT = actions.makeElement('select','TEL_KIND', val,rec.SEQ_NO,'grid2');	
									return SELECT;  
								}
							},
							{header: '區碼' , key : 'TEL_AREA', 
								render : function( rec , val){		
								    //製作區碼下拉選單
									var SELECT = actions.makeElement('select','TEL_AREA', val,rec.SEQ_NO,'grid2');	
									return SELECT;  
								}
							},
							{header: '號碼' , key : 'TEL_NUM', 
								render : function( rec , val){		
								    return actions.makeElement('input','TEL_NUM',val,rec.SEQ_NO,'grid2');
								}
							},
							{header: '分機' , key : 'TEL_EXT', 
								render : function( rec , val){		
								    return actions.makeElement('input','TEL_EXT',val,rec.SEQ_NO,'grid2');
								}
							},
							{header: '備註' , key : 'NOTE',
							    render : function (rec , val){
                                return actions.makeElement('input','NOTE',val,rec.SEQ_NO,'grid2');
							
							}},
							{header:"最後異動人員", key:'LST_PROC_NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header:"最後異動日期", key:'LST_PROC_DATE',
								render :function(record,value){
									return Date.toROC( value|| '');
								}
							}					
						]
									
				});	
				
				//行銷超市電話grid
				gridE = new TableUI ( {
					table: $('gridE'),  allSortable:false, pageSize:0,
					
					<%-- [20240327]難字 --%>
		            afterLoad: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
					
					autoCheckBox:{},
					column: [
							{header: '姓名' , key : 'NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header: '種類' , key : 'TEL_KIND_NM'},							
							{header: '區碼' , key : 'TEL_AREA_NM'},
							{header: '號碼' , key:'TEL_NUM'},
							{header: '分機' , key:'TEL_EXT'},
							{header: '最後異動日期', key:'LST_PROC_DATE',
								render :function(record,value){
									return Date.toROC( value|| '');
								}
							}					
						]
				});	
				
				//收息電話grid
				gridF = new TableUI ( {
					table: $('gridF'),  allSortable:false, pageSize:0, 
					
					<%-- [20240327]難字 --%>
		            afterLoad: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
		            pageChange: function() {
		            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
		            },
					
					autoCheckBox:{},
					column: [
							{header: '姓名' , key : 'NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
							{header: '種類' , key : 'TEL_KIND_NM'},							
							{header: '區碼' , key : 'TEL_AREA_NM'},
							{header: '號碼' , key:'TEL_NUM'},
							{header: '分機' , key:'TEL_EXT'}
						]
				});	
				
				
				//click事件
				$('btn_query').observe( 'click', buttons.doQuery);
				$('btn_confirm').observe( 'click', buttons.doConfirm);
				$('btn_insert').observe( 'click', buttons.doInsert);				
				$('btn_update').observe( 'click', buttons.doUpdate);		
				$('btn_delete').observe( 'click', buttons.doDelete);		
				$('btn_insert_under').observe( 'click', buttons.doInsertUnder);
				$('A_Block_E').observe('click', layout.showBlock_E);
				$('A_Block_F').observe('click', layout.showBlock_F);
				$('btn_importE').observe('click', function(){
					buttons.doImport('E');
				});
				$('btn_importF').observe('click', function(){
					buttons.doImport('F');
				});
				

                //查詢連動轉大小寫和清空其他欄位
                $('REFER_ID').observe('keyup',  function(event){	
					$('REFER_ID').value = $F('REFER_ID').toUpperCase();

				});	
				$('REFER_ID').observe('focus',  function(event){	
					$('LOAN_ID').setValue("");
					$('QID').setValue("");
					$('QNAME').setValue("");
				});	
                $('LOAN_ID').observe('keyup',  function(event){	
					$('LOAN_ID').value = $F('LOAN_ID').toUpperCase();

				});	
				$('LOAN_ID').observe('focus',  function(event){	
					$('REFER_ID').setValue("");
					$('QID').setValue("");
					$('QNAME').setValue("");
				});	
                $('QID').observe('keyup',  function(event){	
					$('QID').value = $F('QID').toUpperCase();

				});	
				$('QID').observe('focus',  function(event){	
					$('REFER_ID').setValue("");
					$('LOAN_ID').setValue("");
					$('QNAME').setValue("");
				});	
                $('QNAME').observe('focus',  function(event){	
					$('REFER_ID').setValue("");
					$('QID').setValue("");
					$('LOAN_ID').setValue("");
				});	 	 			
				fix();

				displayMessage();	
				
				initValidation();		

				buttonAuth();
				if($('REFER_ID').value){
					ajaxRequest.closeSuccMsg();
					buttons.doQuery();
				}
							
				
			}
	};
};

</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
		    <td class="tbYellow" width="8%" align="left" >
					原貸帳號
			</td>
			<td class="tbYellow2">
					<input name="REFER_ID" id="REFER_ID"  type="text" class="textBox2" size='12' maxlength='10' fieldName = "原貸帳號" value='${REFER_ID}'/>
			</td>
		    <td class="tbYellow" width="8%" align="left" >
					貸款帳號
			</td>
			<td class="tbYellow2">
					<input name="LOAN_ID" id="LOAN_ID"  type="text" class="textBox2" size='12' maxlength='10'  fieldName = "貸款帳號" value='${LOAN_ID}'/>
			</td>
		    <td class="tbYellow" width="8%" align="left" >
					ID
			</td>
			<td class="tbYellow2">
					<input name="QID" id="QID"  type="text" class="textBox2" size='12' maxlength='10'  fieldName = "ID"/>
			</td>
		    <td class="tbYellow" width="8%" align="left" >
					姓名
			</td>
			<td class="tbYellow2">
					<input name="QNAME" id="QNAME"  type="text" class="textBox2" size='12' maxlength='10'  fieldName = "姓名" alt="ch"/><%-- [20240327]難字 --%>
			</td>
			<td class="tbYellow2">
			    <input id = "btn_query" type = "button" class = "button" value = "查詢" />		
			
			</td>
		</table>
		<table id = "grid" ></table>
		<div align = "center">
			<tr>
				<td >
					<input id = "btn_confirm" type = "button" class = "button" value = "異動戶籍地址"   />						
				
				</td>				
			</tr>		
		</div>
	    <table id = "grid1" ></table>
        <div align = "center">
			<tr>
				<td >
					<input id = "btn_insert" type = "button" class = "button" value = "新增電話"   />						
					<input id = "btn_update" type = "button" class = "button" value = "修改電話"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除電話"   />
				</td>				
			</tr>		
		</div>
		<table id = "grid2" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_under" type = "button" class = "button" value = "新增空白列"   />	
				</td>
			</tr>			
		</table>
		<table  width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td align="center">
					<input id = "btn_importE" type = "button" class = "button" value = "匯入"/>
				</td>				
			</tr>
			<tr class='tbYellow0' align='center'>
				<td align='center'>
					<strong>
						<a href="#A_Block_E" id="A_Block_E">行銷超市電話</a>
					</strong>
				</td>
			</tr>
			<tr class='tbYellow0' align='center'>
				<td align='center'>
					<div id="block_E" style="overflow:auto; display:none;">
						<table id='gridE' width="100%"></table>
					</div>
				</td>
			</tr>
			<tr>
				<td align="center">
					<input id = "btn_importF" type = "button" class = "button" value = "匯入"/>
				</td>				
			</tr>
			<tr class='tbYellow0' align='center'>
				<td align='center'>
					<strong>
						<a href="#A_Block_F" id="A_Block_F">收息電話</a>
					</strong>
				</td>
			</tr>
			<tr class='tbYellow0' align='center'>
				<td align='center'>
					<div id="block_F" style="overflow:auto; display:none;">
						<table id='gridF' width="100%"></table>
					</div>
				</td>
			</tr>
		</table>
	</form>	
</body>
</html>