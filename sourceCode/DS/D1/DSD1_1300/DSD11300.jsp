<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>


<!--
程式：DSD11300.jsp
功能：轉帳扣款異常查詢
作者：卓達瑋
完成：2013/08/28

[20240322]難字
 --> 

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>

<%-- [20240322]難字 --%>
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


Event.observe(window, 'load', new DSD11300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11300(){
	
	var valid1; //畫面檢核物件	
    var grid;
	var rtnList;
	var reqMap_rc;
	var NOW_DATE='${NOW_DATE}';
	function buttonAuth(){
		var authButtons = {	
			B0174:"BTN_PRINT"		
		};
		<dz:grantButtons FUNC_ID="DSD11300" />
	}
	
	function initValidation(){
		Validation.addAllThese([
			[ 'length_required',  '請輸入3或5碼的收息單位!',
				function(v,elem){

					return !Validation.get('IsEmpty').test(v) &&((v.length==3||v.length==5));
				}
			]		
			
		]);	
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode : 'validator'});			
		valid1.define( "required", { id: "TRANS_YM" , errMsg:"請輸入查詢年月!" } );
        //valid1.define( "length_required", { id: "GETINT_DEPT" } );
	}
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1300/" + actionName,
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
	
		//共用AJAX
	function ajaxPost1 ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1300/" + actionName,
		{
			asynchronous: false,
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
	}//END   共用AJAX

	//各種action
	var actions = {
        //連動扣款期間
		dochangeday:function(){
			var T_GROUP=$F('TRANS_GROUP');
            var T_BANK=$F('TRANS_BANK');
			if(T_GROUP=="1"){
			    $('DAY_2').innerHTML="5";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_1').innerHTML="1";
				}else{
				     $('DAY_1').innerHTML="30";
				}
			}
			if(T_GROUP=="2"){
			    $('DAY_1').innerHTML="6";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_2').innerHTML="10";	
				}else{
				    $('DAY_2').innerHTML="9";
				}
			}
			if(T_GROUP=="3"){
			    $('DAY_2').innerHTML="15";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_1').innerHTML="11";	
				}else{
				    $('DAY_1').innerHTML="10";
				}
			}
			if(T_GROUP=="4"){
			    $('DAY_1').innerHTML="16";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_2').innerHTML="20";	
				}else{
				    $('DAY_2').innerHTML="19";
				}
			} 
            if(T_GROUP=="5"){
			    $('DAY_2').innerHTML="25";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_1').innerHTML="21";	
				}else{
				    $('DAY_1').innerHTML="20";
				}
			}
            if(T_GROUP=="6"){
			    $('DAY_1').innerHTML="26";
			    if(T_BANK=="1"||T_BANK=="2"){
				    $('DAY_2').innerHTML="31";	
				}else{
				    $('DAY_2').innerHTML="";
				}
			} 	
	    },
		//區域選單連動服務中心一下拉選單
		doChangeSRV_DEPT_List :  function(ADM_CENTER){	

			$('SRV_DEPT').options.length = 1;
			
			ajaxPost1( 'changesrv_dept_list',	{ADM_CENTER: ADM_CENTER},
				function(resp){			
					var SRV_DEPT_List = resp.SRV_DEPT_List || '';					
					SRV_DEPT_List.each(
						function(data) {							
							$('SRV_DEPT').add(new Option(data.SRV_DEPT_NAME, data.SER_DEPT_NO));
						}  
					); 	
				}					
			);

		},
		//服務中心一選單連動服務中心二三下拉選單
		doChangeSRV_DEPT2_List :  function(SRV_DEPT){	

			$('SRV_DEPT2').options.length = 1;
			
			ajaxPost1( 'changesrv_dept2_list',	{SRV_DEPT: SRV_DEPT},
				function(resp){			
					var SRV_DEPT2_List = resp.SRV_DEPT2_List || '';	
					
					//點選服務中心一選項連動服務中心二三時，將當下點選的服務中心一選項帶到服務中心二三下拉選單
					var SRV_DEPT_NAME = $('SRV_DEPT').options[$('SRV_DEPT').selectedIndex].innerText.trim()
					$('SRV_DEPT2').add(new Option(SRV_DEPT_NAME, SRV_DEPT));
						
					SRV_DEPT2_List.each(
						function(data) {							
							$('SRV_DEPT2').add(new Option(data.SRV_DEPT_NAME, data.SER_DEPT_NO));
						}  
					); 	
				}					
			);

		}
		
	};

	//按鈕功能	
	var buttons = {
		//初始查詢
		doQuery : function(){		
			if(!valid1.validate()){			
				return;
			}
			var reqMap={};
			reqMap['TRANS_YM']=$F('TRANS_YM');
			reqMap['TRANS_BANK']=$F('TRANS_BANK');				
			reqMap['TRANS_GROUP']=$F('TRANS_GROUP');
			
			
			var DEPT_ID =  $F('GETINT_DEPT');
			var DEPT_CODE =  $F('GETINT_CODE');
			if($('DEPT_ID_check').checked){
				
				if(!(DEPT_ID.length == 3 || DEPT_ID.length == 5|| DEPT_ID.length == 7 || DEPT_CODE.length == 3 || DEPT_CODE.length == 5|| DEPT_CODE.length == 7 )){
					alert('請輸入3或5或7碼的收息單位代號/或收費代號!');
					return;
				}
				
				reqMap['GETINT_DEPT'] = DEPT_ID;
				reqMap['GETINT_CODE'] = DEPT_CODE;
				
			}else if($('ADM_CENTER_check').checked){
				var ADM_CENTER =  $F('ADM_CENTER');
				if(!ADM_CENTER){
					alert('請至少選擇一個區域!');
					return;				
				}
				var SRV_DEPT2 = $F('SRV_DEPT2');
				var SRV_DEPT = $F('SRV_DEPT');				
				
				if(SRV_DEPT2){
					reqMap['SRV_DEPT2'] = SRV_DEPT2;
					reqMap['ADM_CENTER'] = ADM_CENTER;						
				}else if(SRV_DEPT){
					reqMap['SRV_DEPT'] = SRV_DEPT;	
					reqMap['ADM_CENTER'] = ADM_CENTER;			
				}else{
					reqMap['ADM_CENTER'] = ADM_CENTER;				
				}					
			}
			reqMap_rc = reqMap;			
		
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){						
				    rtnList = resp.rtnList || [];
					grid.load(rtnList);
					PageUI.resize(true);

					
				},
				function(resp){
					grid.load([]);
					PageUI.resize(true);
				}
			);
		},
		//管理大師連過來的查詢
		doQuery1 : function(){		
            <c:if test="${empty INPUT_DATE }">
			   alert("輸入日期不可為空值");
		       return;
			</c:if>
			 <c:if test="${empty LOAN_ID }">
			   alert("輸入貸款帳號不可為空值");
		       return;
			</c:if>
			var reqMap={};
			reqMap['LOAN_ID']='${LOAN_ID}';
			reqMap['INPUT_DATE']='${INPUT_DATE}';
			reqMap_rc = reqMap;
			
			ajaxPost( 'query1' , { reqMap : Object.toJSON(reqMap)},
				function(resp){						
				    rtnList = resp.rtnList || [];
					grid.load(rtnList);
				},
				function(resp){
					grid.load([]);
				}
			);
		},
		//列印
		doPrint : function(event) {
			
			if(!rtnList || rtnList.length == 0){
				alert('需做過查詢才能列印!');
				return;
			}
			var reqMap={};
			reqMap['TRANS_YM']=$F('TRANS_YM');
			reqMap['TRANS_BANK']=$F('TRANS_BANK');
			reqMap['TRANS_GROUP']=$F('TRANS_GROUP');
			
			var DEPT_ID =  $F('GETINT_DEPT');
			var DEPT_CODE =  $F('GETINT_CODE');
			if($('DEPT_ID_check').checked){
				
				CHECKED = "1";				
				reqMap['GETINT_DEPT'] = DEPT_ID;
				reqMap['GETINT_CODE'] = DEPT_CODE;
				
			}else if($('ADM_CENTER_check').checked){
				var ADM_CENTER =  $F('ADM_CENTER');
				if(!ADM_CENTER){
					alert('請至少選擇一個區域!');
					return;				
				}
				var SRV_DEPT2 = $F('SRV_DEPT2');
				var SRV_DEPT = $F('SRV_DEPT');				
				
				if(SRV_DEPT2){
					reqMap['SRV_DEPT2'] = SRV_DEPT2;
					reqMap['ADM_CENTER'] = ADM_CENTER;							
				}else if(SRV_DEPT){
					reqMap['SRV_DEPT'] = SRV_DEPT;
					reqMap['ADM_CENTER'] = ADM_CENTER;					
				}else{
					reqMap['ADM_CENTER'] = ADM_CENTER;				
				}
				CHECKED = "2";	
			}

			for(key in reqMap ){
				if(reqMap[key] != reqMap_rc[key]){
					alert('與查詢時條件不同，請重新查詢!');
					return;
				}			
			}	
			
			reqMap['TRANS_BANK_NM']= $('TRANS_BANK').options[$('TRANS_BANK').selectedIndex].innerText.trim();
			reqMap['DAY_1']= $('DAY_1').innerHTML || '';			
			reqMap['DAY_2']= $('DAY_2').innerHTML || '';

			ajaxPost('print', {rtnList: Object.toJSON(rtnList),CHECKED : CHECKED, reqMap : Object.toJSON(reqMap)},
				function(resp){				
					RPTUtil.executePrintByResponse(resp, true);			
				}		
			);	
		}
	};
	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11300','催收作業','轉帳扣款異常查詢');
			
			//產生 Grid 物件	
			grid = new TableUI({
				table: $('grid'), pageSize: 15, allSortable:true,	
				
				<%-- [20240322]難字 --%>
	            afterLoad: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240322]難字 --%>
	            },
				
				column: [
				    {header:"貸款帳號", key:'LOAN_ID', attrs:{align : "center"},
				    /*  render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}
                        }
                    */    
                        render :function(record,value){
                            var link = new Element('a', { 'href' : '#'}).update(value);
							link.observe('click', //監聽click事件
								function( event ) {
								    var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+value+"&INPUT_TYPE=2";									
									window.open(url, "DSD1_0500", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");
							
								});
								return link;
						}
						
					},
					{header:"期數", key:'PAY_TERM', sortRule:'number', attrs:{align : "center"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							var PAY_TERM=(value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  PAY_TERM+ "</span>";		
							}else{
							    return PAY_TERM;
							}

						}
					},
					{header:"姓名", key:'BORROW_NAME', attrs:{align : "center", style:"font-family:'EUDC'"},<%-- [20240322]難字 --%>
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}

					},
					{header:"應繳日", key:'NEXT_PAYDT', sortRule:'date', attrs:{align : "center"},
					    render :function(record,value){
						    
						    if(value &&  diffDay(value,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  Date.toInputROC( value|| '' ,'')+ "</span>";		
							}else{
							    return Date.toInputROC( value|| '' ,'');
							}	
						}
					},
					{header:"應繳金額", key:'REAL_PAYMT', sortRule:'number', attrs:{align : "right"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							var REAL_PAYMT=(value||value===0) ? CSRUtil.$fmt(value,"#,###") : 0;
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  REAL_PAYMT+ "</span>";		
							}else{
							    return REAL_PAYMT;
							}
						}
					},
					{header:"異常原因", key:'TRANS_CSTATUS', attrs:{align : "center"},
                      	render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}				
					},
					{header:"名稱", key:'TRANS_BANK', attrs:{align : "center"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}
					},
					{header:"收費代號", key:'GETINT_CODE', attrs:{align : "center"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}
					},
				    {header:"白天電話", key:'DAY_TEL_AREA', sortRule:'number', attrs:{align : "right"},
					    render : function(record, value){
							var DAY_TEL_NUM=record.DAY_TEL_NUM||'';
							var DAY_TEL_EXT=record.DAY_TEL_EXT||'';
						    var DAY_TEL_AREA;
							if(value){
						       	DAY_TEL_AREA= value +"-"+(DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||'');
						    }else{
						        DAY_TEL_AREA= (DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||''); 
							}
                            
							
							var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  DAY_TEL_AREA+ "</span>";		
							}else{
							    return DAY_TEL_AREA;
							}
						}
					},
					{header:"夜間電話", key:'NIGHT_TEL_AREA', sortRule:'number', attrs:{align : "right"},
					    render : function(record, value){
							var NIGHT_TEL_NUM=record.NIGHT_TEL_NUM||'';
							var NIGHT_TEL_EXT=record.NIGHT_TEL_EXT||'';
						    var NIGHT_TEL_AREA;
							if(value){
						       	NIGHT_TEL_AREA= value +"-"+(NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||'');
						    }else{
						        NIGHT_TEL_AREA= (NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||''); 
							}
							
							
                            var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  NIGHT_TEL_AREA+ "</span>";		
							}else{
							    return NIGHT_TEL_AREA;
							}

							
						}
					},
					{header:"行動電話", key:'MOBILE', sortRule:'number', attrs:{align : "center"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}					
					},
					{header:"經手人姓名", key:'AGENT_NAME', attrs:{align : "center", style:"font-family:'EUDC'"},<%-- [20240322]難字 --%>
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}					
					},
					{header:"經手人電話", key:'AGENT_MOBILE', sortRule:'number', attrs:{align : "center"},
					    render :function(record,value){
						    var NEXT_PAYDT=record.NEXT_PAYDT;
							
							if(diffDay(NEXT_PAYDT,NOW_DATE)>0){
							    return "<span class = 'textRed'>" +  value+ "</span>";		
							}else{
							    return value;
							}

						}					
					}
				]	
			});	
			
			initValidation();//畫面日期檢核

			//按鈕事件監聽
			$('TRANS_GROUP').observe('change',actions.dochangeday); //連動扣款期間
			$('TRANS_BANK').observe('change',actions.dochangeday);  //連動扣款期間
			$('BTN_QUERY').observe('click',buttons.doQuery); 						
			$('BTN_PRINT').observe('click', function(event){
				buttons.doPrint();
			});
			
			//區域選單連動服務中心一下拉選單
			$('ADM_CENTER').observe('change', function(event){
				
				actions.doChangeSRV_DEPT_List(this.value); 
			});
			//服務中心一選單連動服務中心二三下拉選單
			$('SRV_DEPT').observe('change', function(event){
				
				actions.doChangeSRV_DEPT2_List(this.value); 
			});
			
			if('${SRV_DEPT}'){//如果初始服務中心一有值則重帶選單
				$('SRV_DEPT').simulate('change');				
				if('${SRV_DEPT2}'){
					$('SRV_DEPT2').value = '${SRV_DEPT2}';
				}	
			}
			
			//240521自動化測試：DSD11800催收明細作業，建案例發現從DSD11800導頁過來會跳出[輸入日期不可為空值]的訊息，故此段改成兩個參數都有傳才自動做doQuery1查詢
			<c:if test="${not empty LOAN_ID and not empty INPUT_DATE }">
			   buttons.doQuery1();//管理大師查詢
		    </c:if>
			//預設設值
			$('TRANS_BANK').value=1;
			$('DAY_1').innerHTML="1";
			$('DAY_2').innerHTML="5";
			
			buttonAuth();
			
			PageUI.resize();
            
			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow"  width= "7%" align="left">查詢年月</td>
				<td class="tbYellow2" width= "10%">
					<input id="TRANS_YM" type="text" size="7" maxlength="5" value="${TRANS_YM}"/>
				</td>
				<td class="tbYellow"  width= "7%"  align='left'>轉帳銀行</td>
				<td class="tbYellow2" width= "10%">
					<select name="TRANS_BANK" id="TRANS_BANK" class="textBox2" >
						<c:forEach items="${TRANS_BANK_MAP}" var="map">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>	
				</td>
				<td class="tbYellow" width= "7%"='left'>轉帳組別</td>
                <td class="tbYellow2" width= "10%" >				
				    <select name="TRANS_GROUP" id="TRANS_GROUP" class="textBox2" >
						<option value="1">1
						<c:forEach var="current" begin="2" end="6" step="1">  
							<option value="${current}">${current}</option>
						</c:forEach>
					</select>	
				</td>
				<td class="tbYellow" width= "7%" align='left'>扣款期間</td>
                <td class="tbYellow2" width= "10%">
				    <span id="DAY_1"></span>日~
					<span id="DAY_2"></span>日
     	        </td>
				<td class="tbYellow2" rowSpan ="3" width= "10%">    
					<input id="BTN_QUERY" type="button" class="button"  value="查詢"/>
					<input id="BTN_PRINT" type="button" class="button" value="列印">	
			    </td>
			</tr>	
			<tr>	
				<td class="tbYellow"  width= "7%" align="left" >
					<input id ='DEPT_ID_check' name='QUERY_TYPE' type ='radio'  value='QUERY_ByDEPT_ID' checked/>收息單位
				</td>		
				<td class="tbYellow2" width ="10%" >
					<input id="GETINT_DEPT" type="text" class="textBox2"  size="9" maxlength="7" value = "${DIV_NO}" onKeyUp="this.value=this.value.toUpperCase();"/>
				</td>
				<td class="tbYellow"  width= "7%" align="left" >收費代號</td>		
				<td class="tbYellow2" width ="30%"  colSpan ="5">
					<input id="GETINT_CODE" type="text" class="textBox2"  size="9" maxlength="7" onKeyUp="this.value=this.value.toUpperCase();"/>
				</td>
						
			</tr>
			<tr>
				<td class="tbYellow" width= "7%" >
					<input id ='ADM_CENTER_check' name='QUERY_TYPE' type ='radio'  value='QUERY_ByCRED_DEPT' />區域					
				</td>										
				<td class="tbYellow2" width= "10%">
					<select id="ADM_CENTER" class="textBox2">
						<option value="">請選擇</option> 
						<c:forEach items="${ADM_CENTER_List}" var="map">						
							<option value="${map.key}"<c:if test="${map.key eq ADCD}">selected</c:if>>${map.value}</option>		
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width= "8%" >服務中心一</td>										
				<td class="tbYellow2"  width= "10%" >
					<select id="SRV_DEPT" name="SRV_DEPT" class="textBox2">	
						<option value="">全部</option>	
						<c:forEach items="${SRV_DEPT_List}" var="map">							
							<option value="${map.SER_DEPT_NO}"<c:if test="${map.SER_DEPT_NO eq SRV_DEPT}">selected</c:if>>${map.SRV_DEPT_NAME}</option>
						</c:forEach>	
					</select>
				</td>
				<td class="tbYellow" width= "9%" >服務中心二三</td>										
				<td class="tbYellow2"  colSpan ="3" >
					<select id="SRV_DEPT2" class="textBox2">
						<option value="">全部</option>
						<c:forEach items="${SRV_DEPT2_List}" var="map">							
							<option value="${map.SER_DEPT_NO}"<c:if test="${map.SER_DEPT_NO eq SRV_DEPT2}">selected</c:if>>${map.SRV_DEPT_NAME}</option>
						</c:forEach>
					</select>
				</td>
			</tr>	
		</table>
		<table id="grid" width="100%" class="grid" ></table>
	    <table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		    <tr>
			    <td class="tbYellow2">    
			        <font color="blue"><b>一、作業說明</b></font><br>   
			        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.本作業供查詢銀行轉帳扣款異常件。<br>
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.查詢條件為[轉帳年月+轉帳組別+收息單位]。<br>
					
					<font color="blue"><b>二、操作方式</b></font><br>  
				    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.輸入欲查詢之轉帳年月、轉帳組別、以及收息單位，按[查詢]。
			</tr>
        </table>
	</form>	
</body>
</html>