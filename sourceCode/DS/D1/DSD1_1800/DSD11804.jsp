<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSD11804.jsp
功能：製作存證信函
作者：卓達瑋
完成：2013/08/28

[20240327]難字
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
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script> <%-- 地址用 --%>

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

<script type="text/javascript">


Event.observe(window, 'load', new DSD11804().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSD11804(){
	
	var valid1; //畫面檢核物件	
	var NEW_GAGE_ADDR;
	var grid;
	var rtnList;
	
	function buttonAuth(){
		var authButtons = {	
			B0028:"BTN_CONFIRM"			
		};
		<dz:grantButtons FUNC_ID="DSD11804" />
	}
	// 地址輸入不檢核的欄位
	var notCheck = {
		CITY_NAME : "CITY_NAME",
		TOWN_NAME : "TOWN_NAME"
	};	
			
	function initValidation(){
		
		
		valid1 = new Validation("form", { focusOnError:true, immediate:false, mode : 'validator'});			
		valid1.define( "required", { id: "GETINT_ZIP" , errMsg:"寄件人郵遞區號不可空白!" } );
		//valid1.define( "required", { id: "GETINT_ADDR" , errMsg:"寄件人地址不可空白!" } );
		valid1.define( "required", { id: "OVER_TERM" , errMsg:"逾期期數不可空白!" } );
 
        valid2 = new Validation("form", {useTitles:true, focusOnError:false, immediate:false});		
		
	}
	
	
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSD1_1804/" + actionName,
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
        //地址選擇後設值
		getAddr:function(){
			if (NEW_GAGE_ADDR) {
				$('GETINT_ZIP').value = NEW_GAGE_ADDR.getINPUT_ZIPCODE();
				$('GETINT_ADDR').value = NEW_GAGE_ADDR.getINPUT_ADDR();
			} else {
				$('GETINT_ZIP').value = '';
				$('GETINT_ADDR').value = '';
			}

	    },
		//查詢後設值
		getData : function(resp){
			rtnList=resp.rtnList||[];
			
			grid.load(rtnList);

			var rtnMap=resp.rtnMap||[];
			$('table_A').select('input[type!=button]').each(function(ele){						
				ele.value=rtnMap[ele.id] || '';
			});
			
			$('table_A').select('span').each(function(ele){	
				ele.update(rtnMap[ele.id] || '');
			});
			
			//轉成民國年
			$('LOAN_DATE').update(Date.toROC(rtnMap.LOAN_DATE||''));
			$('LAST_PAYDT').update(Date.toROC(rtnMap.LAST_PAYDT||''));
			$('INPUT_DATE').update(Date.toROC(resp.today||''));
			
			$('INPUT_NAME').update(resp.userid||'');
			$('INPUT_ID').setValue(resp.EMP_ID||'');
			
			//千分位表示
			var LOAN_AMT = rtnMap.LOAN_AMT;
			$('LOAN_AMT').update((LOAN_AMT||LOAN_AMT===0) ? CSRUtil.$fmt(LOAN_AMT,"#,###") : 0)
			
			//地址下拉選單取得郵遞區號及地址
			NEW_GAGE_ADDR.setINPUT_ZIPCODE(rtnMap.GETINT_ZIP);	
			NEW_GAGE_ADDR.setINPUT_ADDR(rtnMap.GETINT_ADDR);	
		} 
		
		
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			
			var reqMap={};
			reqMap['LOAN_ID']=$F('LOAN_ID_A');
			reqMap['DEPT_ID']=$F('DEPT_ID');
			ajaxPost( 'query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){						
				    actions.getData(resp);	
				},
				function(resp){
					 actions.getData([]);	
				}
			);

		},
	

		//覆核
		doConfirm : function(){
		    //基本欄位檢核
			
			if(!valid1.validate()){
				return;
			}
			//檢核寄件人地址格式(是否與下拉地址相同)
			valid2.clear();
			NEW_GAGE_ADDR.checkData(valid2, notCheck);			
			if(!valid2.validate()){
				return;
			}
            //將基本欄位存成map
			var reqMap = {};
			reqMap.GETINT_ZIP=$('GETINT_ZIP').value;
			reqMap.GETINT_ADDR=$('GETINT_ADDR_INPUT_ADDR').value;
			reqMap.LOAN_ID=$('LOAN_ID').innerHTML||'';
			reqMap.INPUT_NAME=$('INPUT_NAME').innerHTML||'';
			reqMap.LOAN_DATE = toY2K($('LOAN_DATE').innerHTML || '');
            reqMap.LAST_PAYDT = toY2K($('LAST_PAYDT').innerHTML || '');				
			reqMap.INPUT_DATE = toY2K($('INPUT_DATE').innerHTML || '');	
			reqMap.LOAN_AMT = $('LOAN_AMT').innerHTML.replace(/,/g,'');
			reqMap.OVER_TERM = $('OVER_TERM').value||'';
            reqMap.INPUT_ID=$('INPUT_ID').value||'';
			//篩選被副本收件人資料和收件人資料
			var tmpList2=grid.getAllRecords();
			var reqList=[];
			var rtnMap={};
			for(var i=0;i<tmpList2.length;i++){
			    
				if(tmpList2[i].check_NM=='Y'){
				    tmpList2[i].LOAN_ID=$('LOAN_ID').innerHTML;
					reqList.push(tmpList2[i]);
				}
				if(tmpList2[i].radio_NM=='Y'){
				   rtnMap['BORROW_NAME']=tmpList2[i].NAME;
				   rtnMap['CON_ZIP']=tmpList2[i].CON_ZIP;
				   rtnMap['CON_ADDR']=tmpList2[i].CON_ADDR;
				   rtnMap['KIND']=tmpList2[i].KIND;
				}	
			}
			if(!rtnMap.BORROW_NAME){
			    alert("收件人請至少勾選一筆");
				return;
			}
			/*
			if(reqList.length==0){
			    alert("副本收件人請至少勾選一筆");
				return;
			} 
			*/
			//發送ajax
			ajaxPost( 'confirm' , {rtnMap : Object.toJSON(rtnMap),reqMap : Object.toJSON(reqMap) , reqList : Object.toJSON(reqList)},
				function(resp){	
					
				}				
			);	
			
		}
		
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSD11804','催收作業','製作存證信函',0,true);
			
			//產生 Grid 物件	
			grid = new TableUI({
				table: $('grid'), pageSize: 10, allSortable: false,	
				
				<%-- [20240327]難字 --%>
	            pageChange: function() {
	            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
	            },
				
				autoCheckBox:{
					text:'選取收件人',				
				 	type:'radio',
					action:function(checkbox ,boxStatus , record ){
						var dataObj = getValueByElement(checkbox)[0];
						var check_NM;
						if(grid.isNew){
							check_NM = grid.getThisRecordTD(checkbox,['check_NM'])[0]['check_NM'];
							check_NM = $(check_NM).select('input')[0];
						}else{
							var tr = $(checkbox).up('tr');
							check_NM = tr.select("td[name=check_NM] input")[0];
						}
						
						if($(checkbox).checked){
							check_NM.checked=false;
						    dataObj['check_NM']='N';
                            dataObj['radio_NM']='Y';							
						}else{
						    dataObj['radio_NM']='N';
						}
				        			
					}
				},
				afterLoad: function(ele){
					
					if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }<%-- [20240327]難字 --%>
				  	
					var checks_radio = $('grid').select("input[type=radio]");
					var checks_checkbox = $('grid').select("input[type=checkbox]");
					var allList = grid.getAllRecords();
					for( var i = 0 ; i < rtnList.length ; i++ ){
						if(allList[i].KIND == '0'||allList[i].KIND == '2'){
							if(grid.isNew){
								grid.setThisAutoCheckBox(checks_radio[i],true);
							}else{
								checks_radio[i].checked = true;
							}
							checks_checkbox[i].checked = false;
							allList[i]['check_NM']='N';
                            allList[i]['radio_NM']='Y';							
						}else{
						    if(grid.isNew){
								grid.setThisAutoCheckBox(checks_radio[i],false);
							}else{
								checks_radio[i].checked = false;
							}
							checks_checkbox[i].checked = true;
                            allList[i]['check_NM']='Y';	
                            allList[i]['radio_NM']='N';
                        }
					}
					
					

				},
				column: [
				    {header:"選取副本收件人", key:'check_NM'
					    ,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', type : 'checkbox' ,name:'check_NM', value : value});
							thechk.observe('click' , function(event){
									var dataObj , radio_is_checked;
									if(grid.isNew){
										dataObj = grid.getDataObj(thechk);
										radio_is_checked = grid.isAutoCheckBoxSelected(thechk);
									}else{
										var tr = this.up('tr');
										var radio_NM = tr.select("input[type=radio]")[0];
										radio_is_checked = radio_NM.checked
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									}
									//判斷收件人和副本收件人不能同時選
									if(thechk.checked && radio_is_checked){
										alert("收件人與副本收件人不能同時選取");
										thechk.checked = false;
                                        dataObj['check_NM']='N';
                                        return;
									}
									if(thechk.checked){
									    dataObj['check_NM']='Y';
                                        dataObj['radio_NM']='N';										
									}else{
									    dataObj['check_NM']='N';
                                    }
								}
							);
							return thechk;															
						}
					},
					{header:"種類", key:'KIND_NM'},
					{header:"姓名", key:'NAME', attrs:{ style:"font-family:'EUDC'" }},<%-- [20240327]難字 --%>
				   
					{header:"郵遞區號/地址", key:'CON_ADDR',
						render : function(rec, val){									
							var span = new Element('span');	
							var CR_ADDR = new DSZ01000(span, '1');                    						
							CR_ADDR.setINPUT_ADDR(val);
							CR_ADDR.setINPUT_ZIPCODE(rec.CON_ZIP);	

							var obj = CR_ADDR.getAllSelectObject();	
							<%--[20240531]修正 未正確寫入畫面上異動之郵遞區號及地址--%>
							obj['TOWN_NAME'].observe('change', function(event){
								rec.CON_ZIP = CR_ADDR.getINPUT_ZIPCODE();	
								rec.CON_ADDR = CR_ADDR.getINPUT_ADDR();
							});	
							obj['INPUT_ADDR'].observe('blur', function(event){
								var tr=this.up('tr');
								var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								dataObj.CON_ADDR = this.value;
                                dataObj.CON_ZIP = CR_ADDR.getINPUT_ZIPCODE();									
							});						
							return span;  
						}				
					}				
				]	
			});	
						
							
			
			initValidation();//畫面日期檢核
			//產生地址下拉選單
			NEW_GAGE_ADDR = new DSZ01000("GETINT_ADDR", "1" , 60);	
		    NEW_GAGE_ADDR.display4INPUT_ZIPCODE("3");
			//按鈕事件監聽
			$('BTN_CONFIRM').observe('click', buttons.doConfirm); //覆核
			$('GETINT_ADDR').observe('click',actions.getAddr); 
			
			buttons.doQuery();//初始查詢
			buttonAuth();
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body id="body" bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id="table_A" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
			    <td   align="center" colspan='6'>
			    <input type="button" class="button" id="BTN_CONFIRM" value="確認" />					
		        </td>
			    <input id="DEPT_ID" type="hidden" value="${DEPT_ID}" /> 
				 <input id="LOAN_ID_A" type="hidden" value="${LOAN_ID_A}"/>
                <input id="INPUT_ID" type="hidden" /> 				 
			</tr>
			
			<tr>					
				<td class="tbYellow" width= "8%" align="center">貸款帳號</td>
				<td class="tbYellow2" width= "10%" >
					<span id="LOAN_ID"></span>
				</td>
				<td class="tbYellow" width="15%" align='center'>寄件人郵遞區號</td>
				<td class="tbYellow2" width="20%">
					<input id="GETINT_ZIP" type="text" size='10' maxlength="5" Readonly />
				</td>
				<td class="tbYellow" width="10%" align='center'>寄件人地址</td>
				<td class="tbYellow2" width="40%" id="GETINT_ADDR" alt="ch"><%-- [20240327]難字 --%>				
				</td>				
			</tr>
			<tr>					
				<td class="tbYellow" align="center">貸款日期</td>
				<td class="tbYellow2"  >
					<span id="LOAN_DATE"></span>
				</td>
				<td class="tbYellow" align='center'>貸款金額</td>
				<td class="tbYellow2" >
					<span id="LOAN_AMT"></span>
				</td>
				<td class="tbYellow" align='center'>上次已繳日</td>
				<td class="tbYellow2" >
					<span id="LAST_PAYDT"></span>
				</td>				
			</tr>
			<tr>					
				<td class="tbYellow" align="center">逾期期數</td>
				<td class="tbYellow2"  >
					<input id="OVER_TERM" type="text" size='5' maxlength="4" />
				</td>
				<td class="tbYellow"  align='center'>輸入人員</td>
				<td class="tbYellow2" >
					<span id="INPUT_NAME" alt="ch"></span><%-- [20240327]難字 --%>
				</td>
				<td class="tbYellow" align='center'>輸入日期</td>
				<td class="tbYellow2" >
					<span id="INPUT_DATE"></span>
				</td>				
			</tr>
			
		</table>
		<table id="grid" width="100%" class="grid" ></table>
	</form>
		
</form>	
</body>
</html>