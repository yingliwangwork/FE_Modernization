<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSD10200.jsp
作者：i9300615
功能：DSD1_0200 逾四日未繳件查詢作業
完成：
更新：2013-12-03
-->


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
			 url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	   font-weight: normal;
	   font-style: normal
	}
	</style>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type="text/javascript" type="text/JavaScript">

//Event.observe(window, 'load', initApp);

var grid;

<!-- Define UI Class Start----------------------------------------------------- -->
function UI(){

	//--------------------------------------------------------------------------  
	//UI() private variable
	//-------------------------------------------------------------------------- 	
	var valid1;
	
	var nextchecktype = "${nextchecktype}";
	var grid_type;
	var rtnList;
	var reqMap_rc;
	
	var isLastWorkDate = <c:out value="${isLastWorkDate}" default="false" escapeXml="false" />;	
	
	var gridList = [	
	
		[			
            {header:"單位", key:"DIV_NM",  
				render: function( record, value ){
												
					if(nextchecktype=='12' || nextchecktype=='13'){						
	       				var link = document.createElement( "a" );
	                  	link.href = "#";
	                 	link.innerHTML = value;
	                 	
	                 	var LP_JSON = {
							action:'<%=dispatcher%>/DSD1_0200/prompt',							
							LINK_FROM:'DSD10200', 
							STAT_DATE:record.STAT_DATE, 
							DIV_NO:record.DIV_NO,
							CHECK_TYPE:nextchecktype
						};	                 	
	                 	
	                 	link.onclick = function() { CSRUtil.linkTo(LP_JSON, 'form1'); };
	                 	return link;
					}
					
              		return value;
            	}
            },

			{header: "每月逾四日未繳總件數", key:"MONTH_URGE_CNT", attrs: {align:"right"} ,sortRule:'number', 
				render: function( record, value ){				
              		return CSRUtil.$fmt(value, "#,##0.##");
            	}
            },
			
			{header: "每日逾四日未繳總件數", key:"DAILY_URGE_CNT" , attrs: {align:"right"} ,sortRule:'number', 
				render: function( record, value ){
				
       				var link = document.createElement( "a" );
                  	link.href = "#";
                 	link.innerHTML = CSRUtil.$fmt(value, "#,##0");
                 	
                 	var LP_JSON = {
						action:'<%=dispatcher%>/DSD1_0201/prompt',							
						LINK_FROM:'DSD10200', 
						STAT_DATE:record.STAT_DATE, 
						DIV_NO:record.DIV_NO,
						DIV_NM:record.DIV_NM,
						CHECK_TYPE:"${CHECK_TYPE}",
						BQ_ARG: { STAT_DATE: $F('STAT_DATE') }   
             		    };         
                 
                 	link.onclick = function() { CSRUtil.linkTo(LP_JSON, 'form1'); };
                 	return link;

            	}
            },
		
			{header: "目前收取率", key:"URGE_CNT_PAID_RATIO" , attrs: {align:"right"},
				render: function( record, value ){
					var isLess = value < 75 ;
					return (isLess && isLastWorkDate) ? '<font color="red">' + value + '</font>' : value;
				}
			}
							
		],

		[
			{header:"帳號", key:'LOAN_ID',
					render :function(rec,val){									
						var link = new Element('a',{ href : "#"}).update(val);
							link.observe('click',function(event){						
								var url = "<%=dispatcher%>/DSD1_1800/prompt?LOAN_ID="+val+"&INPUT_TYPE=1";									
								window.open(url, "DSD1_1501", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");	
							});
							return link;
					}
			},
			{header:"催收簡訊發送", key:"NEXT_PAYDATE" ,
					render : function(rec , val){
						//var int_dd = parseInt(val.substr(8,10));
						//if(val && int_dd <= 20 ){													
							var link = new Element("a" , { href : "#" } ).update('催收簡訊發送');
							link.observe( 'click', function (event){ 
							/*	
								var LP_JSON = {
									action :'<%=dispatcher%>/DSD1_0410/prompt',
									LOAN_ID : rec.LOAN_ID,
									FUNC_ID : 'DSD10201',
									STAT_DATE : $('STAT_DATE').value ,
									CHECK_TYPE : '11',
									MOBILE : rec.MOBILE
								}
								*/
								var source = '<%=dispatcher%>/DSD1_0410/prompt'; 
										popupWin.popup({
										parameters : {  'LOAN_ID':rec.LOAN_ID,FUNC_ID : 'DSD10201',MOBILE : rec.MOBILE,
										TableInfo : grid.getTableInfo()},
										src : source								
									});
								
								//CSRUtil.linkTo(LP_JSON , 'form1');		
							});		
							return link;														
						//}	
						return '';
					}
				},		
			{header:"姓名", key:'PAY_TYPE'},
			{header:"本金餘額", key:"PRINCIPAL" , attrs: {align:"right"} ,sortRule:'number', 
					render: function( record, value ){				
	              		return CSRUtil.$fmt(value, "#,##0");
	            	}
            	},
			{header:"收費代號", key:'RECEIVE_ID'},
			{header:"已繳期數", key:'PAY_TERM'},
			{header:"上次實繳日", key:'REAL_PAYDT',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}					
			},
			{header:"下次應繳日", key:'NEXT_PAYDATE',
					render : function (rec , val){
						return Date.toROC(val || "");									
					}
			},
			{header:"聯絡電話(日)", key:'DAY_TEL_AREA'
				,render : function(record, value){
					var DAY_TEL_NUM=record.DAY_TEL_NUM||'';
					var DAY_TEL_EXT=record.DAY_TEL_EXT||'';
					var DAY_TEL_AREA;
					if(value){
						DAY_TEL_AREA= value +"-"+(DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||'');
					}else{
						DAY_TEL_AREA= (DAY_TEL_NUM ||'')+(DAY_TEL_EXT?"#":"")+(DAY_TEL_EXT||''); 
					}
					return DAY_TEL_AREA;		
				}
			},
			{header:"聯絡電話(夜)", key:'NIGHT_TEL_AREA'
				,render : function(record, value){
					var NIGHT_TEL_NUM=record.NIGHT_TEL_NUM||'';
					var NIGHT_TEL_EXT=record.NIGHT_TEL_EXT||'';
					var NIGHT_TEL_AREA;
					if(value){
						NIGHT_TEL_AREA= value +"-"+(NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||'');
					}else{
						NIGHT_TEL_AREA= (NIGHT_TEL_NUM ||'')+(NIGHT_TEL_EXT?"#":"")+(NIGHT_TEL_EXT||''); 
					}					
					return NIGHT_TEL_AREA;					
				}
			},
			{header:"行動電話", key:'MOBILE'},
			{header:"經手人單位", key:'AGENT_DIV_NM'},
			{header:"經手人姓名", key:'AGENT_NAME', style:"font-family:'EUDC'" },			
			{header:"經手人行動電話", key:'AGENT_MOBILE'}
		]
	]	
	
	//------------------------------------------------------------------------
	var actions = {
		
		//查詢
		doQuery : function(){
		
			valid1.reset();
			if(!valid1.validate()){return;}
			
			var STAT_DATE = $F('STAT_DATE');
			var reqMap = {
				DIV_NO :  $F('DIV_NO'),//單位代號
				CHECK_TYPE : $F('CHECK_TYPE'),//統計類別
				STAT_DATE : STAT_DATE//查詢日期			
			};			
			var DEPT_ID = $F('DEPT_ID') || '';
			var RECEIVE_ID = $F('RECEIVE_ID') || '';
			
			//DEPT_ID 有值或RECEIVE_ID有值
			if(DEPT_ID ||RECEIVE_ID){
				reqMap['DEPT_ID'] = DEPT_ID;
				reqMap['RECEIVE_ID'] = RECEIVE_ID;
				actions.gridtable(1);	
			}else{			
				actions.gridtable(0);	
			}
			reqMap_rc =reqMap;	
			
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap),STAT_DATE : STAT_DATE},
				function(resp){
					grid_type = resp.grid_type;
					rtnList = resp.rtnList || [];
					if(grid_type == "0"){
						isLastWorkDate = resp.isLastWorkDate;
						grid.load(rtnList, resp.sumList ||[]);
						$('btn_print').hide();
					}else if(grid_type == "1"){	
						grid.load(rtnList);
						$('btn_print').show();
					}
				    $('CHECK_TYPE').value = resp.CHECK_TYPE;
				},function(resp){
					//isLastWorkDate = resp.isLastWorkDate;
					grid_type = '';
					grid.load([]);
					$('btn_print').hide();	
				}
			);			
			//ajaxPost('query', Form.serialize("form1"), successAction, errorAction);
		}		
		
		//table UI 共同方法
		,gridtable : function(i){
			grid = new TableUI(
				 {table: $("grid"), allSortable: true, pageSize: 20,
				 afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				}, column:gridList[i]}
			);				  
		}
		//列印
		,doPrint : function(event) {
			
			if(!rtnList || grid_type != "1"){
				alert('需做過查詢才能列印!');
				return;
			}
			var STAT_DATE = $F('STAT_DATE');
			var reqMap = {
				DIV_NO :  $F('DIV_NO'),//單位代號
				CHECK_TYPE : $F('CHECK_TYPE'),//統計類別
				STAT_DATE : STAT_DATE//查詢日期			
			};			
			var DEPT_ID = $F('DEPT_ID') || '';
			var RECEIVE_ID = $F('RECEIVE_ID') || '';
			
			//DEPT_ID 有值或RECEIVE_ID有值
			if(DEPT_ID ||RECEIVE_ID){
				reqMap['DEPT_ID'] = DEPT_ID;
				reqMap['RECEIVE_ID'] = RECEIVE_ID;				
			}
			
			for(key in reqMap ){
				if(reqMap[key] != reqMap_rc[key]){
					alert('與查詢時條件不同，請重新查詢!');
					return;
				}			
			}	
			ajaxPost('print', {reqMap : Object.toJSON(reqMap),STAT_DATE :STAT_DATE},
				function(resp){				
					RPTUtil.executePrintByResponse(resp, true);			
				}		
			);	
		}
	};


	
	//--------------------------------------------------------------------------	

	var validateDate = function(){		
		if($F('STAT_DATE'))
			return isROCdate($F('STAT_DATE'));		
	}
	
	//--------------------------------------------------------------------------
	//以下為UI() public method,放在 return 中
	//--------------------------------------------------------------------------  
	return{
	
		//init Function for 初始整個UI Class
		init:function(){

			Validation.addAllThese([
				[ 'validateDate',  '請輸入正確民國年格式', validateDate],				
				[ 'limitlength',   '請輸入3或5碼',
					function(v){  
						return Validation.get('IsEmpty').test(v) || v.length == 3 || v.length == 5;
					}
				],	
				[ 'limitlength2',   '請輸入3或4或5碼',
					function(v){  
						return Validation.get('IsEmpty').test(v) || v.length == 3 || v.length == 4 || v.length == 5;
					}
				]			
			]);	
			
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false}); 
			
			var LP_JSON = CSRUtil.isBackLink('form1');     
			$('CHECK_TYPE').value = "${CHECK_TYPE}";
			
			displayMessage();
			
			var index = 0;
			actions.gridtable(0);
				

			//查詢
	 		$('btn_query').observe('click', function(event){
	 			actions.doQuery();
	 		});	
			//列印
	 		$('btn_print').observe('click', function(event){
	 			actions.doPrint();
	 		});	
			
			$('DEPT_ID').observe('keyup',  function(event){	
				$('DEPT_ID').value = $F('DEPT_ID').toUpperCase();
			});	
			$('RECEIVE_ID').observe('keyup',  function(event){	
				$('RECEIVE_ID').value = $F('RECEIVE_ID').toUpperCase();

			});	
			
			$('btn_print').hide();
	 		
			<c:if test="${not empty STAT_DATE and not empty CHECK_TYPE}">
				actions.doQuery();		
			</c:if>
			
			
	 		
		}//end init()--
		
	}//end return--
	//-------------------------------------------------------------------------- 
	
}
<!--Define UI Class End-------------------------------------------------------->


<!--全域 函數 UI 與 畫面 公用 Start-------------------------------------------------->
//--------------------------------------------------------------------------  
//共用ajaxpost function
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request( 
		"<%=dispatcher%>/DSD1_0200/" + actionName,
		{ parameters: params,
          onSuccess: function(XHT, resp){
			if(CSRUtil.isSuccess(resp)){
				if(successAction){
	 				successAction(resp);
	 			}
			}else if(errorAction){
	 			errorAction();
	 		}
        }}
	);
}	


//-------------------------------------------------------------------------- 
<!--全域 函數 UI 與 畫面 公用 End---------------------------------------------------->
</script>

</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onload="new UI().init()" onResize='fix()' onScroll="fix()">

<!--此網頁自建使用的JavaScript 放下面 -->

<center><!-- Bolck_1_Start 表單的開頭 功能名稱 畫面編號--> 
<span id="bar1" style="position: absolute; left: 0; top: 0; width: 100%; z-index: 9; visibility: visible">
<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif"><img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12"></td>
		<td valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" background="<%=imageBase%>/CM/border_03.gif">
			<tr>
				<td height="4"><img src="<%=imageBase%>/CM/border_03.gif" width="12" height="4"></td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="2" cellspacing="0" class="subTitle">
			<tr>
				<td width="20" height="24">
				<div align="center"><font size="-5">●</font></div>
				</td>
				<td><b>逾繳催收</b></td>
				<td>
				<div align="right">畫面編號：DSD10200</div>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
</span> <!-- Bolck_1_ End--> <!-- Bolck_2_Start 空白區塊 版面跳行-->
<table width="100%" height="30" border="0" cellpadding="0" 	cellspacing="0">
	<tr>
		<td>&nbsp;</td>
	</tr>
</table>
<!-- Bolck_2_End--> <!-- Bolck_3_Start 表單主功能區塊-->
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="4" background="<%=imageBase%>/CM/border_01.gif">
		    <img src="<%=imageBase%>/CM/border_01.gif" width="4" height="12">
		</td>
		<td width="100%" valign="top" bgcolor="#F0FBC6">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td valign="top">
				<table width=97% border=0 align=center cellpadding="5" cellspacing="1" bgcolor="#003366">
					<tbody>
						<tr>
							<td class="tbBox2" colspan="5">逾四日未繳件查詢作業</td>							
						</tr>
						<tr bgcolor=#FFFFFF>
						  <td>
							<form name="form1" id="form1" method="post" action="">								
								<input type="hidden" id="CHECK_TYPE" value="${CHECK_TYPE}">
								<input type="hidden" id="DIV_NO" value="${DIV_NO}">
								<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
								<tr>
									<td class="tbYellow" width="10%" nowrap>查詢日期</td>										
						            <td class="tbYellow2" width="15%" nowrap>
							           	<input id="STAT_DATE" datatype="ROCDate" type="text" class="textBox2 required validateDate" size="12" maxlength="7" value="${STAT_DATE}" fieldName="查詢日期" >
							           	<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('STAT_DATE'))"> 							           
							        </td>
									<td class="tbYellow" width="10%" >收息單位</td>										
						            <td class="tbYellow2" width="15%" >
							           	<input id="DEPT_ID"  type="text" class="textBox2 limitlength" size="7" maxlength="5" fieldName="收息單位"/>									           					           
							        </td>
									<td class="tbYellow" width="10%" >收費代號</td>										
						            <td class="tbYellow2" width="15%" >
							           	<input id="RECEIVE_ID"  type="text" class="textBox2 limitlength2" size="7" maxlength="5" fieldName="收費代號"/>						           					           
							        </td>									
									<td class="tbYellow2" rowspan='2' width="25%" align="left" nowrap>
									    <input 	id="btn_query" type="button" value="查詢" class="button">
										<input	id="btn_print" type="button" value="報表列印" class="button">
   									</td>
								</tr>								
							   </table>							   
							   <table class="grid" id="grid" width=100% border="1" cellpadding="0" cellspacing="0" class="tbBox2" bordercolorlight="#C7E49C" bordercolordark="#C7E49C" >
							   </table>
							   <table id="grid" width="100%" class="grid" ></table>
		<table id="table_B" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
				<tr>
					<td class="tbYellow2">
					【註】每月結束日之逾4日收取率，考量月底仍有ATM、郵局轉帳等繳款件，故每月之實績，<br>
					               請在次月第3工作日以後查詢(以結束日查詢)始為正確。
					</td>
				</tr>		
		</table>
							   	
							</form>
							  
							  </td>
						</tr>
					</tbody>
				</table>
				</td>
			</tr>
		</table>
		</td>
		<td width="4" background="<%=imageBase%>/CM/border_02.gif"><img src="<%=imageBase%>/CM/border_02.gif" width="4" height="12"></td>
		<td width="5" class="tbBox"><img src="<%=imageBase%>/CM/ecblank.gif" width="5" height="1"></td>
	</tr>
</table>
<!-- Bolck_3_End--></center>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
</BODY>
</HTML>