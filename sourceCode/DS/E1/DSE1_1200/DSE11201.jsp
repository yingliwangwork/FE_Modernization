<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11201.jsp
功能：法務個件異動-首頁
作者：卓達瑋
完成：2013/08/15

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	      <%-- 地址用 --%>
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


Event.observe(window, 'load', new DSE11201().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11201(){
	var valid
    var LOAN_ID ='${LOAN_ID}';//貸款帳號
	var SEQ_NO ='${SEQ_NO}';//序號
    var grid1;
	var grid2;
	var grid3;
	var grid4_1;
	var grid4_2;
	var grid5;
	var grid6;
	var grid7;
	var grid8;
	var grid9;
	var TEL_AREA_Map ; //「電話區碼」下拉選單 map
	var CR_ADDR;
	var checkedList1 = [];
	var checkedList2 = [];
	var checkedList3 = [];
	var checkedList4 = [];
	var oldrtnMap9={};//初始前I區的紀錄
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 		
			B0004 : 'btn_update'					
		};
		<dz:grantButtons FUNC_ID ="DSE11201"/>
	}
	
	function initValidation(){
		Validation.addAllThese([
			[ 'TEL_required',  '市內電話有誤!',
				function(v,elem){
					return Validation.get('IsEmpty').test(v) || /^\d+$/.test(v);
				}
			]		
			
		]);
		
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode : 'validator'});	
				
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1201/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}		
	
	function popupCenter(url, title, w, h) {
	    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
	    var width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
	    var height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;
	
	    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
	    var top = ((height / 2) - (h / 2)) ;
	    var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
	
	    if (window.focus) {
	        newWindow.focus();
	    }
	}
	//各種action
	var actions = {
		//超連結
		POP_UP :function(event){
			
			var id= event.target.id;
			var strlink;
			if(id=='BTN_DSH0'){
			    strlink='<%=dispatcher%>/DSH0_0200/prompt';
			}else if(id=='BTN_DSE101'){
			    strlink='<%=dispatcher%>/DSE1_0100/prompt';
			}else if(id=='BTN_DSE105'){
			    strlink='<%=dispatcher%>/DSE1_0500/prompt';  
			}else if(id=='BTN_DSF0'){
			    strlink='<%=dispatcher%>/DSF0_0210/prompt';  
			}else if(id=='BTN_DSE118'){
			    strlink='<%=dispatcher%>/DSE1_1800/prompt';  
			}
			alert("超連結至"+strlink+"，LOAN_ID為"+LOAN_ID);
			return;
			popupWin.popup({									
				src : strlink ,		
				scrolling : 'yes',	
				parameters : { 
					'LOAN_ID' : LOAN_ID	
				}  			
			});	
		}
	};
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			ajaxPost( 'query' , { 'LOAN_ID' : LOAN_ID,'SEQ_NO':SEQ_NO},
				function(resp){						
                    TEL_AREA_Map = resp.TEL_AREA_List||[];
					var rtnList1=resp.rtn_List1||[];
					var rtnList2=resp.rtn_List2||[];
					var rtnList3=resp.rtn_List3||[];
					var rtnList4=resp.rtn_List4||[];
					var rtnList5=resp.rtn_List5||[];
					var rtnList6=resp.rtn_List6||[];
					var rtnList7=resp.rtn_List7||[];
					var rtnList8=resp.rtn_List8||[];
				    rtnMap9=resp.rtnMap9||{};
					//紀錄修改前狀態
					
					$w('SW_OUT_CK LAW_CK INT_CK NOLOCK_CK').each(
						function(ele){
							oldrtnMap9[ele]=rtnMap9[ele];
						}
					)
                    
					
					for(var i=0 ;i<rtnList4.length;i++){
					    if(rtnList4[i].SEC_KD=='E112'){
							var List4_1=[];
							List4_1.push(rtnList4[i]);
							grid4_1.load(List4_1);
						}else{
						    var List4_2=[];
							List4_2.push(rtnList4[i]);
						    grid4_2.load(List4_2);
						}
						
					}
					grid1.load(rtnList1);
					grid2.load(rtnList2);
					grid3.load(rtnList3);
					grid5.load(rtnList5);
					grid6.load(rtnList6);
					grid7.load(rtnList7);
					grid8.load(rtnList8);
					var rtnList9=[];
					rtnList9.push(rtnMap9);
					grid9.load(rtnList9);
					//隱藏區域
					if(rtnList7==[]){
					    $('grid7').hide();
						
					}
					if(rtnList8==[]){
					    $('grid8').hide();
					}					
				},
				function(resp){
					grid1.load([]);
                    grid2.load([]);
					grid3.load([]);
					grid4_1.load([]);
					grid4_2.load([]);
					grid5.load([]);
					grid6.load([]);
					grid7.load([]);
					grid8.load([]);
			    }
			);

		},
		//修改
		doUpdate : function(){
			
			var tmpList = grid2.getAllRecords();			
			var tmpList2 = grid9.getAllRecords();	
			var newrtnMap9={};
		    var new_rtn_List2=[];
			//將可以修改的資料傳回
			/*
		    for(var i=0 ;i<tmpList.length ;i++){
			    if(tmpList[i].ISDEAD=="N"){
			        new_rtn_List2.push(tmpList[i]);
			    }
			
			}
		    */
		
			$w('SW_OUT_CK LAW_CK INT_CK NOLOCK_CK').each(
				function(ele){
					newrtnMap9[ele]=tmpList2[0][ele];
				}
			)
            var obj1 = Object.toJSON(newrtnMap9);
			var	obj2 = Object.toJSON(oldrtnMap9);
            //比對I區修改前 跟修改後是否相同 跳出訊息
			if(obj1!=obj2){
			    if(!confirm('系統控管有異動，確認是否更新?')){
			        return;
			    }
			}
			
			
			//檢核區塊A			
			if(!valid1.validate()){
				return;
			}
						
			//發送ajax
			ajaxPost( 'update' , {
					'LOAN_ID' : LOAN_ID,
					'SEQ_NO'  : SEQ_NO,
					'oldrtnMap9' : obj2 ,
					'newrtnMap9' : obj1 
					//'new_rtn_List2' :Object.toJSON(new_rtn_List2)
				},
				function(resp){
					var rtnList1=resp.rtn_List1||[];
					var rtnList2=resp.rtn_List2||[];
					var rtnList3=resp.rtn_List3||[];
					var rtnList4=resp.rtn_List4||[];
					var rtnList5=resp.rtn_List5||[];
					var rtnList6=resp.rtn_List6||[];
					var rtnList7=resp.rtn_List7||[];
					var rtnList8=resp.rtn_List8||[];
				    rtnMap9=resp.rtnMap9||{};
					//紀錄修改前狀態
					
					$w('SW_OUT_CK LAW_CK INT_CK NOLOCK_CK').each(
						function(ele){
							oldrtnMap9[ele]=rtnMap9[ele];
						}
					)
					for(var i=0 ;i<rtnList4.length;i++){
					    if(rtnList4[i].SEC_KD=='E112'){
							var List4_1=[];
							List4_1.push(rtnList4[i]);
							grid4_1.load(List4_1);
						}else{
						    var List4_2=[];
							List4_2.push(rtnList4[i]);
						    grid4_2.load(List4_2);
						}
						
					}
					grid1.load(rtnList1);
					grid2.load(rtnList2);
					grid3.load(rtnList3);
					grid5.load(rtnList5);
					grid6.load(rtnList6);
					grid7.load(rtnList7);
					grid8.load(rtnList8);
					
					var rtnList9=[];
					rtnList9.push(rtnMap9);
					grid9.load(rtnList9);
                    			
				}				
			);		
			
		}
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11201','法務件','法務個件異動-首頁',1,true);
			
			//產生 Grid 物件	
			grid1 = new TableUI (
				{ table: $('grid1'),title:'催收紀錄',overDiv:false,
				  allSortable:false,			  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
				  column : [
					
					{header : '約定繳款日', key : 'DUE_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：催收人員 --%>
					{header : '催收人員', key : 'INPUT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '催收日期', key : 'INPUT_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '催收情形', key : 'NOTE'}
				]
			});
								
			//產生 Grid2 物件	
			grid2 = new TableUI ( 
				{ table: $('grid2'), allSortable:false,title:'客戶資料', overDiv:false,	
		        <%-- [20240207] 難字調整 --%>
	            afterLoad: function() {
	                if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
	            pageChange: function() {
	                if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	            },
				column : [
					{header : '種類', key : 'CUS_TYPE_NM'},
					<%-- [20240207] 難字調整：姓名 --%>
					{header : '姓名', key : 'CUS_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : 'ID', key : 'CUS_ID'},
					{header :'郵遞區號' ,key :'CON_ZIP'},
					<%-- [20240207] 難字調整：戶籍地址 --%>
					{header:"戶籍地址", key:'CON_ADDR', attrs:{ style:"font-family:'EUDC'" }, 
						render : function(rec, val){
							if(val){
								var link = new Element("a" , { href : "#" } ).update( val );
								link.observe( 'click', function (event){
									var url = 'https://maps.google.com.tw/?q='+encodeURI(val);
									popupCenter(url,'GoogleMap','900','500');  
								});		
								return link;
							}else{
								return "";
							}
						}
					    /*
						,attrs:{colSpan:2},
						render : function( rec , val){		
							//var city = val.substring(0,3);
							//var town = val.substring(3,5);						
							var span = new Element('span');	
							CR_ADDR = new DSZ01000(span, '1');  
							//CR_ADDR.setCITY_NAME(city);
							//CR_ADDR.setTOWN_NAME(town);
							CR_ADDR.setINPUT_ADDR(val);
							CR_ADDR.setINPUT_ZIPCODE(rec.CON_ZIP);	
                            if(rec.ISDEAD=="Y"){
							CR_ADDR.displayOnly(true);			
							}
							var obj = CR_ADDR.getAllSelectObject();			
									obj['INPUT_ADDR'].observe('blur', function(event){
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.CON_ADDR = this.value;
                                        dataObj.CON_ZIP = CR_ADDR.getINPUT_ZIPCODE();									
							});						
							return span;  
						}
						*/
					},
					{header:"電話", key:'TEL_DATA'
					            /*
								,render : function( rec , val){								
									var span = new Element('span');	
									var TEL_AREA_LIST = new Element("select",{id:'DAY_TEL_AREA',className : 'required'});
									TEL_AREA_LIST.add(new Option('請選擇','')); 
									for(key in TEL_AREA_Map){
										TEL_AREA_LIST.add(new Option(TEL_AREA_Map[key],key));
									}									
									TEL_AREA_LIST.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];											
											dataObj.DAY_TEL_AREA = this.value;
									    }   
									);
									TEL_AREA_LIST.value = val || ''
									//判別死亡條件下，顯示和輸入欄位
									if(rec.ISDEAD!="Y"){
										var input_DAY_TEL_NUM = new Element("input" , {id:'DAY_TEL_NUM', type : 'TEXT',size:12 , maxlength:12, datatype : "number",className : 'required TEL_required',fieldName : '電話-市內電話'});
										input_DAY_TEL_NUM.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.DAY_TEL_NUM = this.value;									
										});
										input_DAY_TEL_NUM.value = rec.DAY_TEL_NUM || '';
										
										var input_DAY_TEL_EXT = new Element("input" , {id:'DAY_TEL_EXT', type : 'TEXT',size:12 , maxlength:12, datatype : "number",className : 'TEL_required',fieldName : '電話-分機'});
										input_DAY_TEL_EXT.observe('change', function(event){
											var tr=this.up('tr');
											dataObj = tr.dataObj || grid2.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
											dataObj.DAY_TEL_EXT = this.value;									
										});
										input_DAY_TEL_EXT.value = rec.DAY_TEL_EXT || '';
										span.insert(TEL_AREA_LIST).insert('&nbsp;').insert(input_DAY_TEL_NUM).insert('#').insert(input_DAY_TEL_EXT);		
                                    }else{
									    var span_DAY_TEL_NUM = new Element("span" , {id:'DAY_TEL_NUM'});
									    var span_DAY_TEL_EXT = new Element("span" , {id:'DAY_TEL_EXT'});
                                        TEL_AREA_LIST.disable();
								        span_DAY_TEL_NUM.update(rec.DAY_TEL_NUM || '');
										span_DAY_TEL_EXT.update(rec.DAY_TEL_EXT || '');
										span.insert(TEL_AREA_LIST).insert('&nbsp;').insert(span_DAY_TEL_NUM).insert('#').insert(span_DAY_TEL_EXT);
									}
									
									return span;					
								}
                                */ 								
					},
					{header:"行動電話", key:'MOBILE'/*,
						render : function( rec , val){								
							var input_MOBILE = new Element("input" , {id:'MOBILE', type : 'TEXT',size:10 , maxlength:12, datatype : "number"});
							input_MOBILE.observe('change', function(event){
								var tr=this.up('tr');
								dataObj = tr.dataObj || grid1.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								dataObj.MOBILE = this.value;									
							});
							input_MOBILE.value = rec.MOBILE || '';
						    if(rec.ISDEAD!="Y"){
								return input_MOBILE;
                            }else{
							    return val;
							}						
						}
						*/
					},
					{header : '死亡', key : 'ISDEAD'},
					{header : '在職員工', key : 'IS_EMPLOYEE'}					
				]
			});						
			//產生 Grid 物件	
			grid3 = new TableUI (
				{ table: $('grid3'),title:'取得執行名義',overDiv:false,
				  allSortable:false, 	  				  
			      <%-- [20240207] 難字調整 --%>
		          afterLoad: function() {
		              if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		          },
		          pageChange: function() {
		              if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
		          },
			  	  column : [
					{header : '種類', key : 'EXEC_TYPE_NM'
						,render : function(record, value){
							return  "<font color='blue'><strong>"+ value +"</strong></font>";
						}
					},
					{header : '聲請日期', key : 'APPLY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '確定/換發日期', key : 'CERTAIN_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header : '相對人', key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
                    {header : '法院', key : 'COURT_CODE_NM'},
                    {header : '案號', key : 'CASE_NO'}					
				]
			});			
            grid4_1 = new TableUI (
				{ table: $('grid4_1'),title:'保全程序',overDiv:false,
				  allSortable:false, 	  				  
			  	  column : [
					{header : '', key : 'SEC_KD_NM'
						,render : function(record, value){
							return  "<font color='blue'><strong>"+ value +"</strong></font>";
						}
					},
					{header : '聲請日期', key : 'APPLY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '種類', key : 'SEC_TYPE_NM'},
					{header : '案號', key : 'CASE_NO'},
					{header : '裁定日期', key : 'CERTAIN_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '提存日期', key : 'DRAW_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '取回日期', key : 'BACK_DATE'
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					}
				]
			});				
            grid4_2 = new TableUI (
				{ table: $('grid4_2'),overDiv:false,
				  allSortable:false, 	  				  
			  	  column : [
					{header : '', key : 'SEC_KD_NM'
						,render : function(record, value){
							return  "<font color='blue'><strong>"+ value +"</strong></font>";
						}
					},
					{header : '聲請日期', key : 'APPLY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '案號', key : 'CASE_NO'},
					{header : '執行標的', key : 'TARGET',attrs:{width:"60%"}}
				]
			});
			grid5 = new TableUI (
				{ table: $('grid5'),title:"調查財產",overDiv:false,
				  allSortable:false, 	  				  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
				  column : [
					
					{header : '查調日期', key : 'INVESTIGATE_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header : '相對人', key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '年所得合計', key : 'YEAR_INCOME'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '實益', key : 'IS_INCOME_NM'},
					{header : '財產總額合計', key : 'TOTAL_WEALTH'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'0';
						}
					},
					{header : '實益', key : 'IS_WEALTH_NM'}
				]
			});	
			grid6 = new TableUI (
				{ table: $('grid6'),title:"拍賣程序",overDiv:false,
				  allSortable:false, 	  				  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
			  	  column : [
					{header : '拍賣種類', key : 'SALE_TYPE_NM'
						,render : function(record, value){
							return  "<font color='blue'><strong>"+ value +"</strong></font>";
						}
					},
					{header : '聲請日期', key : 'APPLY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header : '相對人', key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '案號', key : 'CASE_NO'},
					{header : '法院鑑價', key : 'COURT_APPR'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					
					{header : '第一拍', key : 'MIN_PRICE1'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '第二拍', key : 'MIN_PRICE2'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '第三拍', key : 'MIN_PRICE3'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '特別變賣', key : 'MIN_PRICE4'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '減價拍賣', key : 'MIN_PRICE5'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					}
				]
			});
			grid7 = new TableUI (
				{ table: $('grid7'),title:"追償程序",overDiv:false,
				  allSortable:false, 	  				  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
				  column : [
					
					{header : '聲請日期', key : 'APPLY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header : '相對人', key : 'OPPOSITE_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '案號', key : 'CASE_NO'},
					{header : '詢價日期', key : 'INQUIRY_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '	法院鑑價', key : 'COURT_APPR'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '撤回日期', key : 'WITHDRAW_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '拍定日期', key : 'SALE_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					}
				]
			});	
			grid8 = new TableUI (
				{ table: $('grid8'),title:'協議清償',overDiv:false,
				  allSortable:false, 	  				  
	              <%-- [20240207] 難字調整 --%>
	              afterLoad: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
	              pageChange: function() {
	                  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
	              },
				  column : [
			  		<%-- [20240207] 難字調整：聲請人 --%>
					{header : '聲請人', key : 'APPLICANT_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header : '簽准日期', key : 'BARGAIN_APPR_DATE'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					{header : '協議條件', key : 'BARGAIN_COND_NM'},
					{header : '協議總金額鑑價', key : 'TOTAL_AMT'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '累計還款金額', key : 'PAID_AMT'
					    ,render : function(record, value){
							return  value ? MoneyFormat(value):'';
						}
					},
					{header : '最近繳款日', key : 'REAL_PAYDT'
					    ,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					}
				]
			});	
			
			grid9 = new TableUI (
				{   table: $('grid9'),title:'系統控管',overDiv:false,
				    allSortable:false 
                    ,
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
						
						for(var i=0; i<checkedList4.length; i++){
							checkedList4[i].checked = true;
						}
						
						checkedList1 = [];
						checkedList2 = [];
						checkedList3 = [];
						checkedList4 = [];
					},

				  
			  	    column : [
					{header : '暫不轉出', key : 'SW_OUT_CK'
					    ,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', name:'SW_OUT_CK', type : 'checkbox', value : value});
							if(value == 'Y'){
								checkedList1.push(thechk);
							}
							thechk.observe('click' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid9.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									if(thechk.checked){
										dataObj['SW_OUT_CK'] = 'Y';
									}else{
										dataObj['SW_OUT_CK'] = 'N';
									}
								}
							);
						    return thechk;
						}
					
					},
					{header : '轉出法務', key : 'LAW_CK'
					    ,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', name:'LAW_CK', type : 'checkbox', value : value});
							if(value == 'Y'){
							    checkedList2.push(thechk);	
							}
							thechk.observe('click' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid9.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									if(thechk.checked){
										dataObj['LAW_CK'] = 'Y';
									}else{
										dataObj['LAW_CK'] = 'N';
									}
								}
							);
						    return thechk;
						}
					},
					
					{header : '收息控管', key : 'INT_CK'
					    ,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', name:'INT_CK', type : 'checkbox', value : value});
							if(value == 'Y'){
								checkedList3.push(thechk);	
								
							}
							thechk.observe('click' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid9.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									if(thechk.checked){
										dataObj['INT_CK'] = 'Y';
									}else{
										dataObj['INT_CK'] = 'N';
									}
								}
							);
						    return thechk;
						}
					},
					{header : '保單不控管', key : 'NOLOCK_CK'
					    ,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', name:'NOLOCK_CK', type : 'checkbox', value : value});
							if(value == 'Y'){
								checkedList4.push(thechk);		
							    
							}
							thechk.observe('click' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid9.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									if(thechk.checked){
										dataObj['NOLOCK_CK'] = 'Y';
									}else{
										dataObj['NOLOCK_CK'] = 'N';
									}
								}
							);
						    return thechk;
						}
					},
					{header : '保單控管狀態', key : 'LOCK_STS'}
				]
			});
			
			//按鈕事件監聽
			initValidation();//畫面日期檢核
			
			buttonAuth();//按鈕授權
			

            $('btn_update').observe('click', buttons.doUpdate); //修改
			
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
	    
		<div align = "center">
            
			<table id = "grid1" ></table>
        </div>
		<div  align="center">
			
			<table id = "grid2" ></table>
		</div>
		<div  align="center">
			
			<table id = "grid3" ></table>
		</div>
		<div  align="center">
			
			<table id = "grid4_1" ></table>
			<table id = "grid4_2" ></table>			
		</div>
		<div  align="center">
			
			<table id = "grid5" ></table>
			
		</div>
		<div  align="center">
			
			<table id = "grid6" ></table>
			
		</div>
		<div  align="center">
			
			<table id = "grid7" ></table>
			
		</div>
		<div  align="center" >
			
			<table id = "grid8" ></table>
			
		</div>
		<div align="center" >
			<table id = "grid9" ></table>
		</div>	
		<div align = "center">
			<tr>
				<td  colspan="8" align="center">
					<input id = "btn_update" type = "button" class = "button" value = "異動"   />											
				</td>
			</tr>
		</div>
</form>	
</body>
</html>