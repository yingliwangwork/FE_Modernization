<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA50100.jsp
作者：謝雅筑
功能：受理進度追蹤
完成：2012/06/04
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA50100().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA50100(){
	
	var valid;
	var grid;

	function getColumnType(isPrompt){
		var xHeader = '';
		var xKey = '';
		var type1 = $F('TYPE1');
		if(isPrompt ||type1 == '3' || type1 == '4'){
			xHeader = '派件日期';
			xKey = 'ASSIGN_DATE';
		}else{
			xHeader = '送件日期';
			xKey = 'SEND_DATE';				
		}
		
		var cloumnHeader;
		if(isPrompt || type1 != '0'){	//if 查詢項目1下拉選單有輸入
		
			if(type1=='7'){//變更年期異常
			  cloumnHeader  =  	[
			    	{header: "序號" ,key: "SEQ_NO" },
	       			{header: "貸款帳號" ,key: "LOAN_ID" },
	       			{header: "借款人" ,key: "BORROW_NAME" },
	       			{header: "受理進度" ,key: "SPEC_PROCESS_NM" },
					{header: "派件日期" ,key: "ASSIGN_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: "徵信人員" ,key: "CRED_NAME" }
					];			
			}else{
			  cloumnHeader  =  	[
			    	{header: "序號" ,key: "SEQ_NO" },
					{header: "受理編號",key: "APPLY_ID" ,
	              		render:function(record,value){
	              			if(value){
	              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doLink(record.APPLY_ID)});
	              			}	          
	              			return value;
	              		}
	          			},
	       			{header: "借款人" ,key: "BORROW_NAME" },
	       			{header: "受理進度" ,key: "SPEC_PROCESS_NM" },
	       			{header: "貸款種類" ,key: "LOAN_KIND_NM" },
	       			{header: "貸款類別" ,key: "LOAN_TYPE_NM" },
	       			{header: "貸款金額(萬元)" ,key: "LOAN_AMT"  , 
	               		render:function(record,value){
	               		 	return CSRUtil.$fmt(value , '#,###.####')  ;
	               		}
	            	},
					{header: "受理日期" ,key: "APPLY_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: xHeader ,key: xKey , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
					{header: "包裹日期",key: "PACK_DATE" , 
	               		render:function(record,value){
	               			return Date.toROC(value);
	               		}
	            	},
	            	{header: "鑑價輸入日" ,key: "APPR_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
	            	{header: "鑑價覆核日" ,key: "REPORT_DATE" , 
	               		render:function(record,value){
	               		 	return Date.toROC(value);
	               		}
	            	},
					{header: "核准日期",key: "AGREE_DATE" , 
	               		render:function(record,value){
	               			if($F('TYPE1') == '5'){
	               				return '-';
	               			}else{
	               		 		return Date.toROC(value);
	               		 	}
	               		}
	            	},
					{header: "徵信人員" ,key: "CRED_NM" },
					{header: "匯款人員" ,key: "REMIT_NM" },
					{header: "鑑價人員" ,key: "APPR_NM" }
					];
			}
				
		}else{//if查詢項目2下拉選單有輸入	
			cloumnHeader  =  	[
				{header: "序號" ,key: "SEQ_NO" },
				{header: "受理編號",key: "APPLY_ID" ,
              		render:function(record,value){
              			if(value){
              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doLink(record.APPLY_ID)});
              			}	          
              			return value;
              		}
          			},
       			{header: "借款人" ,key: "BORROW_NAME" },
       			{header: "貸款種類" ,key: "LOAN_KIND_NM" },
       			{header: "貸款類別" ,key: "LOAN_TYPE_NM" },
       			{header: "貸款金額(萬元)" ,key: "LOAN_AMT"  , 
               		render:function(record,value){
               		 	return CSRUtil.$fmt(value , '#,###.####')  ;
               		}
            	},
				{header: "受理日期" ,key: "APPLY_DATE" , 
               		render:function(record,value){
               		 	return Date.toROC(value);
               		}
            	},
				{header: "包裹日期",key: "PACK_DATE" , 
               		render:function(record,value){
               			return Date.toROC(value);
               		}
            	},
				{header: "徵信人員" ,key: "CRED_NM" },
				{header: "匯款人員" ,key: "REMIT_NM" }
			];
		}
		return cloumnHeader;
	}
					
	var actions = {
		
		//查詢
		doQuery:function(){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
	    	
	    	var reqMap = commonTools.getInputData();
	    	
			ajaxPost('query',{reqMap:Object.toJSON(reqMap)},
				function(resp){
					actions.loadData(resp.rtnList);
				},
				function(){
					actions.loadData([]);
				}
			);
			
		},
		
		//清除
		doReset:function(){
			valid.reset();
			$('form1').reset();
			actions.doGetCRED_ID_LIST();
			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
					column:getColumnType(true)
				
			});	
			
		},
		
		//列印
		doPrint:function(event){
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			var reqMap = commonTools.getInputData();

			window.open('<%=dispatcher%>/DSA5_0100/print?reqMap='+Object.toJSON(reqMap)+'&CRED_DEPT='+$F('CRED_DEPT'),'_blank', "top=50, left=50, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=1024, height=768");

		},
		
		
		//取得徵信人員
		doGetCRED_ID_LIST:function(){
			$('CRED_ID').update().insert(new Element('option', {value: ""}).update("全部"));
			var val = $F('CRED_DEPT') ;
			if(val == ''){
				return;
			}

			ajaxPost('getCRED_ID_LIST',{CRED_DEPT : val},
				function(resp){
						commonTools.createSelect(resp.CRED_ID_LIST);
				}
			);	
		},
		
		//取得查詢項目1值
		doGetTYPE1_VAL:function(){
			var val = $F('TYPE1');
			if(val=='1' || val=='4'){
				TYPE1_VAL = 0;
			}else if(val=='2' ){
				TYPE1_VAL = 1;
			}else if(val=='3' || val=='5'){
				TYPE1_VAL = 2;
			}else if(val=='6'){
				TYPE1_VAL = 5;
			}else if(val=='7'){
				TYPE1_VAL = 7;
			}else {
				TYPE1_VAL = 0;
			}		
			$('TYPE1_VAL').value = TYPE1_VAL;
		},
		
		//取得查詢項目2值
		doGetTYPE2_VAL:function(){
			var val = $F('TYPE2');
			if(val=='1'){
				TYPE2_VAL = 3;
			}else if(val=='2' ){
				TYPE2_VAL = 14;
			}else if(val=='3'){
				TYPE2_VAL = 60;
			}else if(val=='4'){
				TYPE2_VAL = 7;
			}else {
				TYPE2_VAL = 0;
			}		
			$('TYPE2_VAL').value = TYPE2_VAL;
		},
		
		//載入查詢資料
		loadData:function(rtnList){
			rtnList = rtnList ? rtnList:[];
			var index = 0;
			rtnList.each(function(map){
				index++;
				map.SEQ_NO = index;
			
			});
			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
					column:getColumnType()
				
			});				
			grid.load(rtnList);
		},
		
		//受理編號超連結
		doLink:function(apply_id){
			//儲存徵信人員選單 
			var opts = $('CRED_ID').options;
			var CRED_ID_LIST = [];
			for(var i=0;i<opts.length;i++){
				var opt = opts[i];
				var map = {};
				map.ID = opt.value;
				map.NAME = opt.text;
				CRED_ID_LIST.push(map);
			}

			var LP_JSON = {
				action:'${dispatcher}/DSA1_1700/prompt',
				LINK_FROM:'DSA50100',
				APPLY_ID:apply_id,
				BQ_ARG: {
					CRED_ID_LIST:Object.toJSON(CRED_ID_LIST),//徵信人員選單 
					CRED_ID:$F('CRED_ID')
				}
			};
			CSRUtil.linkTo(LP_JSON, 'form1');	
		}
		
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA5_0100/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}
	

	var commonTools = {			
		
		//取得A區塊資料
		getInputData:function(){
			var dataMap = {};
			$$('#tableA input[type=text]','#tableA select').each(function(o){
				if(o.datatype == 'number'){
					dataMap[o.id] = o.getValue();
				}else{
					dataMap[o.id] = o.value;
				}
			});

			return dataMap;
		},
		
		createSelect:function(opts){
			var selectElement = $('CRED_ID');
			opts = opts?opts:[];
			if(opts){
				opts.each(function(opt){
					selectElement.insert(new Element('option', {value: opt.ID}).update(opt.NAME));
				});
			}
		}
	};
	
	return{                              
		initApp:function(){
			PageUI.createPage("DSA50100" , "管理作業" , "受理進度追蹤", false);
			PageUI.loadin(["tableA","grid","tableB"] ,1);

			grid = new TableUI ( {
				table: $("grid"), pageSize: 20, allSortable:true,
					column:getColumnType(true)
				
			});	
						
			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			
			Validation.addAllThese([
				['chooseOne', '查詢項目1跟查詢項目2請擇一查詢', function(v) { 
					var v1 = $F('TYPE1');
					var v2 = $F('TYPE2');
					if((v1==0 && v2==0 )|| (v1!=0 && v2!=0 )){
						return false;
					}else{
						return true;
					}
				}],
				['type1check', '請輸入查詢項目值：0或以上之天數', function(v) { 
					var v1 = $F('TYPE1');
					var v2 = $F('TYPE2');
					if(v1!=0 && v2!=0 ){//僅顯示'請擇一項目查詢'
						return true;
					}
					if(v==''){
						return false;
					}else if(v1!=0){
						return ((v == '0') ||  Validation.get('validate-digits').test(v));
					}else{
						return true;
					}
				}],
				['type2check', '請輸入查詢項目值：0或以上之天數', function(v ) { 
					var v1 = $F('TYPE1');
					var v2 = $F('TYPE2');
					if(v1!=0 && v2!=0 ){//僅顯示'請擇一項目查詢'
						return true;
					}
					if(v==''){
						return false;
					}else if(v2!=0){
						return ((v == '0') ||  Validation.get('validate-digits').test(v));
					}else{
						return true;
					}
				}]
				
			]);
			

			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);
			
			//清除
			$('btn_reset').observe('click',function(event){
					actions.doReset();
				}
			);
			
			//列印
			$('btn_print').observe('click',function(event){
					actions.doPrint();
				}
			);
			
			//「承辦科別」下拉選單連動 「徵信人員」下拉選單
			$('CRED_DEPT').observe('change',function(event){
					actions.doGetCRED_ID_LIST();
				}
			);		
			
			//查詢項目1
			$('TYPE1').observe('change',function(event){
					actions.doGetTYPE1_VAL();
				}
			);	
			
			//查詢項目2
			$('TYPE2').observe('change',function(event){
					actions.doGetTYPE2_VAL();
				}
			);	
			autoFormatToNumber();
			displayMessage();
			
			
			var LP_JSON = CSRUtil.isBackLink('form1');
			if(LP_JSON){
				 var BQ_ARG = LP_JSON.BQ_ARG || {};
				 //徵信人員處理
				 $('CRED_ID').update();
				 commonTools.createSelect(BQ_ARG.CRED_ID_LIST?BQ_ARG.CRED_ID_LIST.evalJSON():[]);
				 $('CRED_ID').value  = BQ_ARG.CRED_ID;
				 //重查
				 actions.doQuery();
        	}

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body >	
<!------------------------ A區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<form id="form1" name="form1" method="post">
				<tr>
					<td class="tbYellow" width="15%">承辦科別</td>
                    <td class="tbYellow2" width="15%" >
						<select name="CRED_DEPT" id="CRED_DEPT" fieldName="承辦科別">
							<c:forEach var="map" items="${CRED_DEPT_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow" width="15%">徵信人員</td>
                    <td class="tbYellow2" width="15%" >
						<select name="CRED_ID" id="CRED_ID" fieldName="徵信人員">
							<option value="">全部</option>
							<c:forEach var="map" items="${CRED_ID_LIST}">
								<option value="${map.ID}">${map.NAME}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow2" rowSpan="3" align="center" width="40%">
						<input id="btn_query" type="button" class="button" value="查詢" />
						<input id="btn_print" type="button" class="button" value="列印" />
						<input id="btn_reset" type="button" class="button" value="清除" />
					</td>
				</tr>
	 			<tr>
	 				<td class="tbYellow" rowSpan="2">查詢項目</td>
                    <td class="tbYellow2" colspan="3">
						<select name="TYPE1" id="TYPE1" class="textBox2 chooseOne" fieldName="查詢項目1">
							<c:forEach var="map" items="${TYPE1_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">請選擇</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
						<span>&gt;</span>
						<input id="TYPE1_VAL" name="TYPE1_VAL" type="text" datatype="number" pattern="#,###.###"  class="textBox2 type1check" size="5" value="0"/>
					</td>
                </tr>
	 			<tr>
                    <td class="tbYellow2" colspan="3">
						<select name="TYPE2" id="TYPE2" class="textBox2 chooseOne" fieldName="查詢項目2">
							<c:forEach var="map" items="${TYPE2_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">請選擇</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
						<span>&ndash;逾期天數</span>
						<input id="TYPE2_VAL" name="TYPE2_VAL" type="text" datatype="number" pattern="#,###.###" class="textBox2 type2check" size="5" value="0" />
					</td>
                </tr>
               </form>
			</table>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
				<tr>				
					<td class="tbYellow" >		
						<b><font class = 'textBlue'>一、作業規定</font></b><BR>
						１、各項業務規定請參照放款作業手冊及發文規定。<BR><BR>
						<b><font class = 'textBlue'>二、操作方式</font></b><BR>
						（１）<BR>
					    １、送件異常：查詢日-受理日> 0(可自行變更)，且無送件日。<BR>	
					    ２、包裹異常：查詢日-送件日> 1(可自行變更)，且無包裹日。<BR>
					    ３、鑑價異常：查詢日-送件日> 2(可自行變更)，且鑑價中。<BR>
					    ４、鑑價完成異常：查詢日-鑑價輸入日> 0(可自行變更)，且鑑價未覆核。<BR>
					    ５、簽核異常：查詢日-鑑價覆核日> 2(可自行變更)，或免鑑價件，查詢日-包裹日> 2(可自行變更)。<BR>
					    ６、匯款異常：查詢日-核准日> 5(可自行變更)。<BR>
					          （２）<BR>
					    １、送件後逾期未派件：查詢日-包裹日> 3(可自行變更)，且單位送件。<BR>	
					    ２、匯款後逾期未結案：查詢日-一匯日> 7(可自行變更)，且未結案。<BR>	
					</td>								
				</tr>
			</table>

</body>
<!-- InstanceEnd -->
</html>