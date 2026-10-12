<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSD11805.jsp
作者：余凱鈞
功能：催收通知作業
完成：2013/08/15

[20240326]
難字調整
高強禾
 -->	

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %><!--匯入外部Javascript 與 css-->
<fmt:setBundle basename="TextResource" />

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<!--自行定義的javaScript-->	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>     <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>      <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script> <%-- 地址用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<%-- [20240326] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/JavaScript">
// 產生畫面物件
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSD11805().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11805(){
	var grid;
	var valid;
	var valid2;
	var NEW_GAGE_ADDR;
	var i =1;
	
	function buttonAuth(){
		var authButtons = {	
			B0028:"btn_CONFIRM"			
		};
		<dz:grantButtons FUNC_ID="DSD11805" />
	}
	
	// 地址輸入不檢核的欄位
	var notCheck = {
		CITY_NAME : "CITY_NAME",
		TOWN_NAME : "TOWN_NAME",
		INPUT_ZIPCODE : "INPUT_ZIPCODE",
		INPUT_ADDR : "INPUT_ADDR"
	};

	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSD1_1805/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}	
	
	
	//確認用檢核
	function initValidation(){	

		Validation.addAllThese([					
		[ 'addr_Required',  '受文者地址或郵遞區號不得為空白',
			function(value,elem){  				
				var checks = elem.up('tr').select("input[type=checkbox]:checked")[0];
				return !checks || value;
			}
		]
		]);	
		valid = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});				
		valid.define( "required", { id: "SENDER_ZIP" , errMsg:"寄件人郵遞區號不可空白!" } );
		valid.define( "required", { id: "SENDER_ADDR" , errMsg:"寄件人地址不可空白!" } );
		valid.define( "required", { id: "TEL_AREA" , errMsg:"聯絡電話區碼不可空白!" } );
		valid.define( "required", { id: "TEL_NUM" , errMsg:"連絡電話不可空白!" } );
		valid.define( "required", { id: "EMAIL" , errMsg:"EMAIL不可空白!" } );
        valid.define( "validate-ROCDate", { id: "SALE_DATE" , errMsg:"拍定日期格式錯誤!" } );
        valid.define( "required", { id: "SALE_DATE" , errMsg:"拍定日期不可空白!" } );
       		

		valid2 = new Validation("form", {useTitles:true, focusOnError:false, immediate:false});			

	}
	
	//查詢時進行欄位填值
	function getData(resp){
		grid.load(resp.rtnList||[]);

		var rtnMap=resp.rtnMap;
		$('table_A').select('input[type!=button]').each(function(ele){						
			ele.value=rtnMap[ele.id] || '';
		});
		$('table_A').select('span').each(function(ele){	
			ele.update(rtnMap[ele.id] || '');
		});
		
		//拍定日期：轉成民國年
		$('SALE_DATE').setValue(Date.toROC(rtnMap.SALE_DATE||'').replace(/\//g,''));
		
		//拍賣不足本金合計：千分位表示
		var SALE_AMT = rtnMap.SALE_AMT;
		$('SALE_AMT').setValue((SALE_AMT||SALE_AMT===0) ? CSRUtil.$fmt(SALE_AMT,"#,###") : 0)
		
		//地址下拉選單取得郵遞區號及地址
		NEW_GAGE_ADDR.setINPUT_ZIPCODE(rtnMap.SENDER_ZIP);	
		NEW_GAGE_ADDR.setINPUT_ADDR(rtnMap.SENDER_ADDR);
		$('SENDER_ADDR').simulate("click");
	}
	
	//將地址下拉選單更動的值帶到寄件人郵遞區號、地址
	function getAddr(){
		if (NEW_GAGE_ADDR) {
			$('SENDER_ZIP').value = NEW_GAGE_ADDR.getINPUT_ZIPCODE();
			$('SENDER_ADDR').value = NEW_GAGE_ADDR.getINPUT_ADDR();
		} else {
			$('SENDER_ZIP').value = '';
			$('SENDER_ADDR').value = '';
		}	
	}
	
	
		
	var buttons = {	
		doQuery : function(){ //查詢
			var reqMap = {
				'LOAN_ID' : $('LOAN_ID').value
			};
			ajaxPost( 'query', {reqMap : Object.toJSON(reqMap)}
				,function(resp){
					getData(resp);
				},function(resp){
					grid.load([]);
				}
			);
		},
		doConfirm : function(){ //確認
		
			valid.reset();
			
			//將畫面A區的部分填入reqMap
			var reqMap = {};
			$('table_A').select('input[type!=button]').each(function(ele){						
				reqMap[ele.id] = ele.value;
			});			
			
			$('table_A').select('span').each(function(ele){						
				reqMap[ele.id] = ele.innerHTML;
			});
					
			reqMap.SALE_DATE = toY2K($('SALE_DATE').value.replace(/,/g,'') || '');
			reqMap.SALE_AMT = $('SALE_AMT').getValue();		
			if(NEW_GAGE_ADDR){
				reqMap.SENDER_ADDR =  NEW_GAGE_ADDR.getINPUT_ADDR();			
			}
		
			//將畫面B區的部分填入reqList
			var reqList = grid.getCheckedRecord();
	
			//檢核是否至少勾選一筆資料
			if(reqList.length==0){
				alert("請至少選取一筆資料");
				return;
			}

			//基本欄位檢核
			if(!valid.validate()){
				return;
			}
			
			//檢核寄件人地址格式(是否與下拉地址相同)
			valid2.clear();
			NEW_GAGE_ADDR.checkData(valid2, notCheck);			
			if(!valid2.validate()){
				return;
			}
		
			ajaxPost( 'confirm', {reqMap : Object.toJSON(reqMap), reqList : Object.toJSON(reqList)}
				,function(resp){
				
				}
			);	
		}		
	};

	return{	
		initApp:function(){	
			
			PageUI.createPageWithAllBodySubElement( "DSD11805" , "催收作業" , "催收通知",1,true);
			
			grid = new TableUI({
				table: $('grid'), pageSize: 20, allSortable: false,	
				autoCheckBox:{
					text:'選取受文者', 
					type:'checkbox'
				},
				<%-- [20240326] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column: [
				    {header:"最新列印日", key:'PRINT_DATE'},
					{header:"種類", key:'KIND_NM'},
					<%-- [20240326] 難字調整：姓名 --%>
					{header:"姓名", key:'NAME', attrs:{ style:"font-family:'EUDC'" }},

					{header:"地址", key:'CON_ADDR',
						render : function(rec, val){
							/*
							var ele = new Element('input', {className : 'textBox2 addr_Required',type:'TEXT',size:'40', maxlength:'80',fieldName:'CON_ADDR', value:val});
							ele.observe('change',function(ele){
								this.up('tr').dataObj['CON_ADDR']=ele.target.value;
							})
							return ele;*/
							
							var span = new Element('span',{id:i});	
							var CR_ADDR = new DSZ01000(span, '1');                    						
							CR_ADDR.setINPUT_ADDR(val);
							CR_ADDR.setINPUT_ZIPCODE(rec.CON_ZIP);	
							i++;
							
							var obj = CR_ADDR.getAllSelectObject();	
								obj['TOWN_NAME'].observe('blur', function(event){
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.CON_ADDR = CR_ADDR.getINPUT_ADDR();									
                                        dataObj.CON_ZIP = CR_ADDR.getINPUT_ZIPCODE();									
								}); 
							    obj['INPUT_ADDR'].observe('blur', function(event){
										var tr=this.up('tr');
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.CON_ADDR = this.value;										
                                        dataObj.CON_ZIP = CR_ADDR.getINPUT_ZIPCODE();									
								});
													
							return span; 
							
							
						}				
					}				
				]	
			});
			
			//產生地址下拉選單
			NEW_GAGE_ADDR = new DSZ01000("SENDER_ADDR", "1" , 60);	
			ajaxRequest.closeSuccMsg();
			buttons.doQuery(); //初始查詢
			
			$('btn_CONFIRM').observe('click',buttons.doConfirm);
			$('SENDER_ADDR').observe('click',getAddr); 
			
			initValidation();
			autoFormatToNumber();
			
			//buttonAuth();
			displayMessage();
			PageUI.resize();
		}
	};	
}
</script>
</head>
<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
		<table id="table" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td align="center" >
					<input id="btn_CONFIRM" type="button" class="button" value="確認">
				</td>
			</tr>			
		</table>
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>					
				<td class="tbYellow" width= "8%" align="center">原貸帳號</td>
				<td class="tbYellow2" width= "10%" >
					<span id="REFER_ID"></span>
				</td>
				<td class="tbYellow" width="15%" align='center'>寄件人郵遞區號</td>
				<td class="tbYellow2" width="20%">
					<input id="SENDER_ZIP" type="text" size='10' maxlength="5" Readonly />
				</td>
				<td class="tbYellow" width="10%" align='center'>寄件人地址</td>
				<td class="tbYellow2" width="40%" id="SENDER_ADDR">				
				</td>				
			</tr>
			<tr>					
				<td class="tbYellow" align="center">拍定日期</td>
				<td class="tbYellow2"  >
                    <input name="SALE_DATE" id="SALE_DATE" datatype="ROCDate" type="text" class="textBox2" size="12" maxlength="7" value="" >
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" onclick="getCalendarFor($('SALE_DATE'))">					
				</td>
				<td class="tbYellow" align='center'>拍賣不足本金合計</td>
				<td class="tbYellow2" >
				
					<input  type="text" id="SALE_AMT" name="SALE_AMT" datatype='number'/>	
				</td>
				<td class="tbYellow" align='center'>擔保品門牌</td>
				<td class="tbYellow2" >
					<%-- [20240326] 難字調整：擔保品門牌，因為會取得文字，所以span改為input --%>
					<input type="text" id="GAGE_ADDR" name="GAGE_ADDR" alt="ch" class="textDisable" readonly />
				</td>				
			</tr>
			<tr>					
				<td class="tbYellow" align="center">承辦法務</td>
				<td class="tbYellow2"  >
					<%-- [20240326] 難字調整：承辦法務，因為會取得文字，所以span改為input --%>
					<input type="text" id="INPUT_NAME" name="INPUT_NAME" alt="ch" class="textDisable" readonly />
					<input type="hidden" id="INPUT_ID" >
					<input type="hidden" id="INPUT_DIV_NO" >
					<input type="hidden" id="INPUT_DIV_NAME" >					
				</td>
				<td class="tbYellow"  align='center'>聯絡電話</td>
				<td class="tbYellow2" >
					<input id="TEL_AREA" type="text" size='5' maxlength="4" />-
					<input id="TEL_NUM" type="text" size='15' maxlength="15" />
				</td>
				<td class="tbYellow" align='center'>分機</td>
				<td class="tbYellow2" >
					<input id="TEL_EXT" type="text" size='10' maxlength="6" />
				</td>				
			</tr>
			<tr>					
				<td class="tbYellow" align='center'>Email</td>
				<td class="tbYellow2" colspan='5'>
					<input id="EMAIL" type="text" size='30' maxlength="30" />
				<td>				
			</tr>
			<input type="hidden" id="LOAN_ID" name="LOAN_ID" value='${LOAN_ID}' />
			<input type="hidden" id="BORROW_NAME" name="BORROW_NAME" value="" />
			<input type="hidden" id="LOAN_DATE" name="LOAN_DATE" value="" />
		</table>
		<table id="grid" width="100%" class="grid" >	
		</table>
	</form>
</body>
</html>		