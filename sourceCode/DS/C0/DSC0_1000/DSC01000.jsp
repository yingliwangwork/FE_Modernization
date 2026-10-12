<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/jsonUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
</head>
<script type="text/javascript" >
<!--
var dsc01000 = new DSC0_1000();

Event.observe(window, 'load', dsc01000.initApp );

function DSC0_1000(){
	var grid1,grid2,grid3;
	var c100vo,initC100vo;	
	var AdjKindList = {};		//個件加減碼種類
	var AdjTypeList = {};		//加減碼方式		
	var isPreferPeriod = { "Y" : "是" , "N" : "否" };
	var INSU_PREFER_List = { "0" : "否" , "1" : "是" };
	var valid1,valid2,valid3;	//查詢的檢核、新增修改的檢核
	var previousRecord;
	var changeTerm='N';
	function ajaxPost( txBean , actionName, params, successAction , failAction)
    {
        new Ajax.Request( "<%=dispatcher%>/" + txBean + "/" + actionName,
        {
			method: "post", parameters: params,
			onSuccess:function(xht, resp){
				if(CSRUtil.isSuccess(resp)){
					if( successAction ) {
						successAction(resp);
					}
				}else{
					if( failAction ){
						failAction(resp);
					}						
				}
			}
        });
    }
	
	function initSelectList(){
		<c:forEach var="map" items="${AdjKindList}">
		AdjKindList["${map.key}"] = "${map.value}";
		</c:forEach>
		
		<c:forEach var="map" items="${AdjTypeList}">
		AdjTypeList["${map.key}"] = "${map.value}";
		</c:forEach>
	}

	
	function refreshDisplay(resp){
		var section = $('section2');
		c100vo = resp.c100vo || {};
		//initC100vo=resp.c100vo || {};
		
		section.select('input').each(function(elm){
			if( elm.getAttribute("datatype") == "ROCDate" ){
				elm.value = Date.toInputROC( c100vo[elm.id], "");
			}else if(elm.getAttribute("datatype") == "number"){
				//elm.value = c100vo[elm.id]|| "";
				elm.value=isNaN(c100vo[elm.id])?"0":c100vo[elm.id];				
			}else{
				elm.value = c100vo[elm.id]|| "";
			}
			
		
			var spanId=	elm.id+"_span";
			//alert('spanId:'+spanId+',content:'+$(spanId).innerHTML)
			$(spanId).innerHTML=elm.value;
					
			
		});
		
		section.select('select').each(function(elm){			
			if("PROD_ID"==elm.id){
				elm.value=resp.PROD_ID;
			}else if("SALARY_GROUP"==elm.id){
				elm.value="";
				if(c100vo[elm.id]){
					elm.value="1";
				}
			}else{
				elm.value = c100vo[elm.id] || "";
			}
			
			
			if("INSU_PRANK" != elm.id){
				var spanId=	elm.id+"_span";
				//alert('spanId:'+spanId);	
				$(spanId).innerHTML=elm.options[elm.selectedIndex].text;
			}			
			
		});
		
		
		
		
		//將保戶等級清單載入		
		producePrankList(resp.prankList);
		
		previousRecord = null;
		
		grid1.load( resp.prefList || [] );
		grid2.load( [] );
		
		grid3.load( resp.initRateList || [] );
		
		valid2.reset();
		
		autoFormatToNumber();
	}
	
	
	function genPrankList(){
		if(c100vo){
			ajaxPost( "DSC0_1000" , "getPrankList" , { INSU_NOTE : $F('INSU_NOTE') , INDIV_ADJUST : c100vo.INDIV_ADJUST , LOAN_KIND : $F('LOAN_KIND') } , function(resp){
				var prankList=resp.prankList;
				producePrankList(prankList);
			});
						
		}
		/*
		else{
			alert("請先查詢該帳號的收息主檔資料!");
		}
		*/
	}
	
	//changeProd
	function changeProd(){
		ajaxPost( "DSC0_1000" ,"changeProd" , { PROD_ID : $F('PROD_ID') } , function(resp){
				var ProdComponent=resp.ProdComponent;				
				$('LOAN_KIND').value=ProdComponent.LOAN_KIND;
				$('PREFER_TYPE').value=ProdComponent.PREFER_TYPE;
			});
	}
	
	function producePrankList(prankList){
		var selectObj = $('INSU_PRANK');
		selectObj.options.length=0;
		var oneOptInit=document.createElement("option");
		oneOptInit.text="請選擇";
		oneOptInit.value="";
		selectObj.add(oneOptInit);
		
		for(i=0;i<prankList.length;i++){
			var oneOpt = document.createElement("option");
			oneOpt.text=prankList[i].value;
			oneOpt.value=prankList[i].key;
			selectObj.add(oneOpt);
		}
	}
	function genC100Data(){
		/*
		section.select('input').each(function(elm){
			if( elm.getAttribute("datatype") == "ROCDate" ){
				elm.value = Date.toInputROC( c100vo[elm.id], "");
			}else if(elm.getAttribute("datatype") == "number"){
				//elm.value = c100vo[elm.id]|| "";
				elm.value=isNaN(c100vo[elm.id])?"0":c100vo[elm.id];				
			}else{
				elm.value = c100vo[elm.id]|| "";
			}
			
		
			var spanId=	elm.id+"_span";
			//alert('spanId:'+spanId+',content:'+$(spanId).innerHTML)
			$(spanId).innerHTML=elm.value;
					
			
		});
		*/
		
		c100vo=CSRUtil.inputsToVo('section2');
		c100vo.LOAN_STATUS="10";
		c100vo.LOAN_DATE=toY2K(c100vo.LOAN_DATE);
		
		c100vo.NEXT_PAYDT=toY2K(c100vo.NEXT_PAYDT);
		c100vo.LAST_PAYDT=addDate(c100vo.NEXT_PAYDT,0,-1,0);
		c100vo.PREFER_BEGNO="0";
		c100vo.PREFER_TERM="0";
		c100vo.GROUP_NOTE="000XX0000000";
		c100vo.VICTIM_KIND="0";
		/*
		alert('NEXT_PAYDT:'+c100vo.NEXT_PAYDT+',length:'+c100vo.NEXT_PAYDT.length+',y2k:'+toY2K(c100vo.NEXT_PAYDT));
		var year=c100vo.NEXT_PAYDT.substr(0,c100vo.NEXT_PAYDT.length-4);
		var month=c100vo.NEXT_PAYDT.substr(year.length,2);
		var day=c100vo.NEXT_PAYDT.substr(year.length+month.length,2);		
		alert('year:'+year+',month:'+month+',day:'+day);
		*/

		
	}
	function getData(){
		
		var data = {
			PAY_KIND : $F('PAY_KIND'),
			CAL_DATE : $F('CAL_DATE'),
			CAL_TERM : $F('CAL_TERM'),
			PROD_ID:$F('PROD_ID')
		};
		
		var CAL_TYPE="1"; 
		if($('CAL_TYPE_0').checked){
			CAL_TYPE="0";
		}
		data.CAL_TYPE=CAL_TYPE;
		
		var form1=$('form1');
		form1.select('input').each(function(elm){
			c100vo[elm.id] = elm.getValue()||'';
		});
		
		var section2 = $('section2');
		section2.select('select').each(function(elm){			
			c100vo[elm.id] = elm.value;
		});
		
		section2.select('input').each(function(elm){
			c100vo[elm.id] = elm.getValue();
		});
		
		data.c100vo = Object.toJSON(c100vo);
		
		data.prefList = Object.toJSON( grid1.getAllRecords() );		
		return data;
	}
	
	
	
	var actions = {
		"Btn_query" : function(event){
			valid1.reset();
			if( !valid1.validate()){
				return;
			}
			
			var params={'info' : Object.toJSON( $("form1").serialize( true ))};
			/*
			ajaxPost( "DSC0_1000" , "query" , { LOAN_ID : $F('LOAN_ID') , PAY_KIND : $F('PAY_KIND') , CAL_DATE : toY2K($F('CAL_DATE')) } , function(resp){
				refreshDisplay(resp);
			});
			*/
			ajaxPost( "DSC0_1000" , "query" , params, function(resp){
				refreshDisplay(resp);
			});
		},
		"Btn_add" : function(event){
			var button = event.target;
			grid1.addRecords( [{ BEG_TERM: "0", END_TERM: "0", ADJ_KIND: "1", ADJ_TYPE: "1", INSU_PREFER: "1" , RT_ADJ : "0" , FIX_RT : "0" }] );
			if(!grid1.isNew){
				var div = $('grid1').up('div');
				div.scrollTop = div.scrollHeight;
				autoFormatToNumber();
				divResize();
			}
		},	
		"Btn_delete" : function(event){
			var record = getSelected();
			if( !record ){
				return;
			}
			
			var records = grid1.getAllRecords();
			var index = records.indexOf(record);
			records.splice( index , 1 );
			
			grid1.load(records);
			
			previousRecord = null;
		},
		"Btn_update" : function(event){
			getSelected(true);
		},
		"Btn_calculate" : function(event){
			
			if(!c100vo ){				
				/*
				alert("請先查詢再計算");
				return;
				*/				
				//var section = $('section2');
				genC100Data();
			}
			
			//alert('c100vo.NEXT_PAYDT:'+c100vo.NEXT_PAYDT+',c100vo:'+Object.toJSON(c100vo));
			if( !valid2.validate() ){
				//return;
			}
			
						
			ajaxPost( "DSC0_1000" , "calculate" , getData() , function(resp){
				grid2.load( resp.RateInfoList || [] );
			});
		}
	};
	
	function getSelected( isUpdateRecord ){
			
		
		
		if( previousRecord && isUpdateRecord ){
			var records = grid1.getAllRecords;
			var record = previousRecord.record;
			if( valid3.validate() ){
			//if( valid2.validate() ){
				if( record.ADJ_KIND == "2" ){										
					var insu_prank=$F('INSU_PRANK');
					if(insu_prank){   //若為空字串、null、undefined都為false，視為INSU_PRANK未輸入						
						ajaxPost( "DSC0_1000" , "getRT_ADJ" , 
						 { INSU_NOTE : $F('INSU_NOTE') , 
						 INDIV_ADJUST : c100vo.INDIV_ADJUST, 
						 LOAN_KIND : $F('LOAN_KIND') ,
						 PREFER_TYPE : $F('PREFER_TYPE'),
						 INSU_PRANK: $F('INSU_PRANK')  },
						function(resp){								
							c100vo.INSU_PRANK = resp.INSU_PRANK;				
							updateRecord( records , record , previousRecord.tr , resp.RT_ADJ );
						});
					}else{
						alert("請選取保戶等級");
						return;
					}				
				}else{
					updateRecord( records, record, previousRecord.tr );
				}
			}
		}else{
			return previousRecord ? previousRecord.record : false;
		}		
	}
	
	function updateRecord( records, record, radio , RT_ADJ ){
		
		if(grid1.isNew){
			Object.extend( previousRecord.record, record );
			delete previousRecord.record.isSelect;
			previousRecord = null;
			valid3.reset();		
			changeTerm="N";
			grid1.reload();
			return;
		}
		
		var tr = radio.up('tr');
		var selects = tr.select('select');
		record.ADJ_KIND = selects[0].value;
		record.ADJ_TYPE = selects[1].value;
		record.INSU_PREFER = selects[2].value;
		
		var inputs = tr.select('input');
		record.BEG_TERM = inputs[1].getValue();
		record.END_TERM = inputs[2].getValue();
		
		if('Y'==changeTerm){
			record.BEG_DT = toY2K('1911-01-01');
			record.END_DT = toY2K('1911-01-01');
		}else{
			record.BEG_DT = toY2K(inputs[3].value);
			record.END_DT = toY2K(inputs[4].value);
		}
		
		inputs[3].up('div').adjacent('div')[0].update( Date.toInputROC( record.BEG_DT , "/"));
		inputs[4].up('div').adjacent('div')[0].update( Date.toInputROC( record.END_DT , "/"));
			
		if( typeof RT_ADJ == "number" ){
			inputs[5].value= RT_ADJ ;
			inputs[5].simulate('change');	//觸發onchange
		}
		
		record.RT_ADJ = inputs[5].getValue();
		inputs[5].adjacent('div')[0].update( record.RT_ADJ );
		
		record.FIX_RT = inputs[6].getValue();
		inputs[6].adjacent('div')[0].update( record.FIX_RT );
		/*
		inputs[3].up('div').adjacent('div')[0].update( Date.toInputROC( record.BEG_DT , "/"));
		inputs[4].up('div').adjacent('div')[0].update( Date.toInputROC( record.END_DT , "/"));
		
		if( typeof RT_ADJ == "number" ){
			inputs[5].value= RT_ADJ ;
			inputs[5].simulate('change');	//觸發onchange
		}
		
		record.RT_ADJ = inputs[5].getValue();
		inputs[5].adjacent('div')[0].update( record.RT_ADJ );
		
		record.FIX_RT = inputs[6].getValue();
		inputs[6].adjacent('div')[0].update( record.FIX_RT );
		*/
		radio.checked = false;
		var transferInput=['ADJ_KIND','BEG_TERM','END_TERM','ADJ_TYPE','RT_ADJ','FIX_RT','INSU_PREFER'];
		grid1.exchangeAutoInput( tr ,transferInput);
		
		previousRecord = null;
		
		valid3.reset();		
		changeTerm="N";
		divResize();
		//valid2.reset();
	}
	
	//切換資料時恢復上次選取的record值
	function resetRecord(){
		
		if(!previousRecord){ return;}
		
		Object.extend( previousRecord.record, previousRecord.origin );
		var record = previousRecord.record;
		
		if(grid1.isNew){ 
			delete record.isSelect;
			valid3.reset();
			return;
		}
		
		var tds = previousRecord["tr"].select('td');
		
		//個件加減碼種類
		tds[1].down('div').update(AdjKindList[record.ADJ_KIND] || "");
		tds[1].down('select').value = record.ADJ_KIND;
		
		//生效期數
		tds[2].down('div').update(record.BEG_TERM);
		tds[2].down('input').value = record.BEG_TERM;
		
		//終止期數
		tds[3].down('div').update(record.END_TERM);
		tds[3].down('input').value = record.END_TERM;
		
		//生效日期
		tds[4].down('div').update(Date.toInputROC(record.BEG_DT , "/" ));
		tds[4].down('input').value = Date.toInputROC(record.BEG_DT , "" );
		
		//終止日期
		tds[5].down('div').update(Date.toInputROC(record.END_DT , "/" ));
		tds[5].down('input').value = Date.toInputROC(record.END_DT , "" ); 
		
		//加減碼方式
		tds[6].down('div').update(AdjTypeList[record.ADJ_TYPE] || "");
		var adj_type_select = tds[6].down('select');
		adj_type_select.value = record.ADJ_TYPE;
		ADJ_TYPEchanged(adj_type_select);
		
		//利率加減碼數
		tds[7].down('div').update(record.RT_ADJ);
		tds[7].down('input').value = record.RT_ADJ; 
		
		//優惠的固定利率
		tds[8].down('div').update(record.FIX_RT);
		tds[8].down('input').value = record.FIX_RT; 
		
		//是否有保戶優惠
		tds[9].down('div').update(INSU_PREFER_List[record.INSU_PREFER] || "");
		tds[9].down('select').value = record.INSU_PREFER;
		var transferInput=['ADJ_KIND','BEG_TERM','END_TERM','ADJ_TYPE','RT_ADJ','FIX_RT','INSU_PREFER'];
		grid1.exchangeAutoInput( previousRecord["tr"] ,transferInput);
		
		valid3.reset();
		//valid2.reset();
	}
	
	function ADJ_TYPEchanged(select){
		
		var td = select.up('td');
		var RT_ADJ = td.next('td').down('input');
		var FIX_RT = td.next('td',1).down('input');
		
		if( select.value == "1" ){
			RT_ADJ.enable();
			FIX_RT.disable();
		}else if( select.value == "2" ){
			RT_ADJ.disable();
			FIX_RT.enable();
		}else if( select.value == "3" ){
			RT_ADJ.enable();
			FIX_RT.enable();
		}
	}
	
	function initTableUI(){
		var genRule = function(rec){
			return !!rec.isSelect;
		};
		
		grid1 = new TableUI({	
			table: $("grid1"),allSortable: false,
			autoCheckBox:{ isSelectAll: false, 
				type : "radio", 
				valueKey : 'isSelect',
				disableRule: function(record){
					if( record.ADJ_KIND != "1" && record.ADJ_KIND != "2" ){
						return true;
					}				
					return false;
				},
				action: function(radio , boxStatus ,records){					
					resetRecord();
					
					previousRecord = { tr : Element.up(radio,'tr') , record: records[0] , origin: {}};
					Object.extend( previousRecord.origin , records[0] );	//記錄舊資料
					if(grid1.isNew){
						records[0].isSelect = 'Y';
						grid1.reload(['Y']);
						return;
					}
					var transferInput=['ADJ_KIND','BEG_TERM','END_TERM','ADJ_TYPE','RT_ADJ','FIX_RT','INSU_PREFER'];
					/*
					if(records[0].ADJ_KIND!="1"){
						transferInput=['ADJ_KIND','BEG_TERM','END_TERM','RT_ADJ'];						
					}
					*/
					grid1.exchangeAutoInput( previousRecord.tr, transferInput);
					//divResize(true);
					divResize(); 
				}
			},
			column:[
				{header: "加減碼種類" ,key: "ADJ_KIND",input:{ type:"select", opts: AdjKindList, "genRule": genRule },
				 render: function(record,value){
						return AdjKindList[value] || "";
					}
				},
				{header: "生效期數" ,key: "BEG_TERM",input:{ type:"text", "genRule": genRule, className: "validate-number-BEG_TERM", maxlength:3,
						actionWhenStart : true,
						action: function(inputNode ,records,DTextElement,orgData,isOnChange ){
							if( !isOnChange ){
								inputNode.setStyle( {"textAlign" : "right"});
								inputNode.setAttribute("fieldName","生效期數");
							}else{
								changeTerm='Y';
							}
						}
					} 
				},
				{header: "終止期數" ,key: "END_TERM",input:{ type:"text", "genRule": genRule, className: "validate-number-BEG_TERM", maxlength:3,
						actionWhenStart : true,
						action: function(inputNode ,records,DTextElement,orgData,isOnChange ){
							if( !isOnChange ){
								inputNode.setStyle( {"textAlign" : "right"});
								inputNode.setAttribute("fieldName","終止期數");
							}else{
								changeTerm='Y';
							}
						}
					} 
				},
				{header: "生效日" ,key: "BEG_DT",input:{ type:"date",imgBase : "<%=imageBase%>","genRule": genRule,
						actionWhenStart : true,
						action: function(inputNode ,records,DTextElement,orgData,isOnChange ){
							inputNode.disable();
							if( !isOnChange ){
								inputNode.setAttribute("fieldName","生效日期");
								inputNode.setAttribute("datatype","ROCDate");
								inputNode.value = Date.toInputROC( records[0]["BEG_DT"] , "");
							}
						}//, className: "validate-date-BEG_DATE validate-ROCDate"
					},render:function(record,value){						
							return Date.toInputROC(value , "/" );
					}
				},
				{header: "終止日" ,key: "END_DT",input:{ type:"date",imgBase : "<%=imageBase%>","genRule": genRule, 
						actionWhenStart : true,
						action: function(inputNode ,records,DTextElement,orgData,isOnChange ){
							inputNode.disable();
							if( !isOnChange ){
								inputNode.setAttribute("fieldName","終止日期");
								inputNode.setAttribute("datatype","ROCDate");
								inputNode.value = Date.toInputROC( records[0]["END_DT"] , "");
							}
						}//, className: "validate-date-BEG_DATE validate-ROCDate"
					},render:function(record,value){
						return Date.toInputROC(value , "/" );
					}
				},
				{header: "加減碼方式" ,key: "ADJ_TYPE",input:{ type:"select" , opts: AdjTypeList,"genRule": genRule,
				 action:function(inputNode ,records,DTextElement,orgData,isOnChange ){
						ADJ_TYPEchanged(inputNode);
					}
				},
				 render: function(record,value){
						return AdjTypeList[value] || "";
					}
				},
				{header: "加減碼數" ,key: "RT_ADJ",input:{ type:"number",
				 actionWhenStart : true,
				 action:function(inputNode ,records,DTextElement,orgData,isOnChange ){
						if( !isOnChange ){
							inputNode.setAttribute("fieldName","利率加減碼數");
							if( records[0].ADJ_TYPE == "2" ){
								inputNode.disable();
							}
						}
					}, "genRule": genRule, className: "validate-required-RT_ADJ validate-number"
				}},
				{header: "固定利率" ,key: "FIX_RT",input:{ type:"number",
				 actionWhenStart : true,	
				 action:function(inputNode ,records,DTextElement,orgData,isOnChange ){
						if( !isOnChange ){
							inputNode.setAttribute("fieldName","優惠的固定利率");
							if( records[0].ADJ_TYPE == "1" ){
								inputNode.disable();
							}
						}
					},"genRule": genRule, className: "validate-required-FIX_RT validate-number"
				}},
				{header: "保戶優惠" ,key: "INSU_PREFER",input:{ type:"select", opts: INSU_PREFER_List, "genRule": genRule},
					 render: function(record,value){
						return INSU_PREFER_List[value] || "";
					}
				}
			]
		});
	
		grid2 = new TableUI({	
			table: $("grid2"),allSortable: false,
			column:[
				{header: "計息日" ,key: "INT_STR_DATE"},
				{header: "期數" ,key: "RATE_TERM"},
				{header: "優惠期間" ,key: "IS_PREF_PERIOD",
				 render: function(record,value){
						return isPreferPeriod[value] || "";
					}
				},
				{header: "計息利率" ,key: "RATE_VAL",
				 render: function(record,value){
						//return popupWin.createPopupLink( value , { src : "<%=dispatcher%>/DSC0_1001/prompt", parameters : { "RATE_MSG" : record.RATE_MSG } } );					
						return popupWin.createPopupLink( value , { src : "<%=dispatcher%>/DSC0_1001/prompt", 
							parameters : { "PREF_RATE":record.PREF_RATE,
										   "PROD_RATE":record.PROD_RATE,
										   "IR_VALUE":record.IR_VALUE,
										   "IR_RT_IDX":record.IR_RT_IDX,
										   "IR_RT":record.IR_RT,
										   "IS_FIX_RATE":record.IS_FIX_RATE,
										   "PRJ_Map":Object.toJSON(record.PRJ_Map),
										   "AVGRATE_LIST":Object.toJSON(record.AVGRATE_LIST),
										   "PREF_VALUE1":record.PREF_VALUE1,
										   "PREF_VALUE2":record.PREF_VALUE2,
										   "PREF_VALUE3":record.PREF_VALUE3,
										   "PREF_VALUE4":record.PREF_VALUE4,
										   "PREF_VALUE5":record.PREF_VALUE5,
										   "LIMIT_MSG":encodeURIComponent(record.LIMIT_MSG||''),
										   "LINK_FROM":"DSC0_1000",
										   "DATA_TYPE":"1" //顯示利率欄位:1
										   } } );
					}
				},
				{header: "指標" ,key: "IR_RT_IDX_NM"},
				{header: "商品利率" ,key: "PROD_RATE",
				 render: function(record,value){
						return record.PROD_RATE || "-";
					}
				},
				{header: "個別優惠" ,key: "PREF_VALUE1"},
				{header: "保戶優惠" ,key: "PREF_VALUE2"},
				{header: "利率限制" ,key: "LIMIT_MSG",
				 render: function(record,value){
						return record.LIMIT_MSG || "";
					}
				},
				{header: "有巢氏優惠" ,key: "PREF_VALUE3"},
				{header: "災戶優惠" ,key: "PREF_VALUE4"},
				{header: "專案加碼" ,key: "PREF_VALUE5"}
			]
		});	
		
		grid3 = new TableUI({	
			table: $("grid3"),allSortable: false,pageSize: 20,
			column:[
				{header: "計息日" ,key: "INT_STR_DATE"},
				{header: "期數" ,key: "RATE_TERM"},
				{header: "優惠期間" ,key: "IS_PREF_PERIOD",
				 render: function(record,value){
						return isPreferPeriod[value] || "";
					}
				},
				{header: "計息利率" ,key: "RATE_VAL",
				 render: function(record,value){
				 		/*
				 		alert("PREF_RATE:"+record.PREF_RATE+",PROD_RATE:"+record.PROD_RATE+",IR_VALUE:"+record.IR_VALUE+",IR_RT:"+record.IR_RT+"\n,"
				 		+"IS_FIX_RATE:"+record.IS_FIX_RATE+",PREF_VALUE1:"+record.PREF_VALUE1+",PREF_VALUE2:"+record.PREF_VALUE2);
				 		*/
						//return popupWin.createPopupLink( value , { src : "<%=dispatcher%>/DSC0_1001/prompt", parameters : { "RATE_MSG" : record.RATE_MSG } } );
						return popupWin.createPopupLink( value , { src : "<%=dispatcher%>/DSC0_1001/prompt", 
							parameters : { "PREF_RATE":record.PREF_RATE,
										   "PROD_RATE":record.PROD_RATE,										   
										   "IR_VALUE":record.IR_VALUE,
										   "IR_RT_IDX":record.IR_RT_IDX,
										   "IR_RT":record.IR_RT,
										   "IS_FIX_RATE":record.IS_FIX_RATE,
										   "PRJ_Map":Object.toJSON(record.PRJ_Map),
										   "IS_WEIGHTED":record.IS_WEIGHTED,
										   "AVGRATE_LIST":Object.toJSON(record.AVGRATE_LIST),
										   "PREF_VALUE1":record.PREF_VALUE1,
										   "PREF_VALUE2":record.PREF_VALUE2,
										   "PREF_VALUE3":record.PREF_VALUE3,
										   "PREF_VALUE4":record.PREF_VALUE4,
										   "PREF_VALUE5":record.PREF_VALUE5,										   
										   "LIMIT_MSG":encodeURIComponent(record.LIMIT_MSG||''),
										   "LINK_FROM":"DSC0_1000",
										   "DATA_TYPE":"1" //顯示利率欄位:1
										   } } );
					}
				},
				{header: "指標" ,key: "IR_RT_IDX_NM"},
				{header: "商品利率" ,key: "PROD_RATE",
				 render: function(record,value){
						return record.PROD_RATE || "-";
					}
				},
				{header: "個別優惠" ,key: "PREF_VALUE1"},
				{header: "保戶優惠" ,key: "PREF_VALUE2"},
				{header: "利率限制" ,key: "LIMIT_MSG",
				 render: function(record,value){
						return record.LIMIT_TYPE || "";
					}
				},
				{header: "有巢氏優惠" ,key: "PREF_VALUE3"},
				{header: "災戶優惠" ,key: "PREF_VALUE4"},
				{header: "專案加碼" ,key: "PREF_VALUE5"}
			]
		});	
	}
	
	function initValidation(){
		
		var testRequired = function(value){
			if( previousRecord.record.ADJ_KIND == "2" ){
				return !Validation.get('IsEmpty').test(value);
			}
			return true;
		};
		
		Validation.addAllThese([
			// 若個件加減碼種類為保戶優惠才檢核
			['validate-required-INSU_NOTE', '請選擇保戶優惠種類', testRequired ],			
			//生效期數、終止期數若有輸入須為數字，否則顯示錯誤訊息”生效/終止期數輸入不正確。”
			['validate-number-BEG_TERM', '生效/終止期數輸入不正確。', function(value){				
				return Validation.get('IsEmpty').test(value) || Validation.get('validate-digits').test(value);
			}],
			//若生效期數、終止期數未輸入，則生效日期、終止日期必須輸入且須為日期，否則顯示錯誤訊息 “生效/終止日期輸入不正確。”
			/*
			['validate-date-BEG_DATE', '生效/終止日期輸入不正確。', function(value){
				var record = previousRecord.record;
				if( Validation.get('IsEmpty').test(record.BEG_TERM) && Validation.get('IsEmpty').test(record.END_TERM) ){
					return !Validation.get('IsEmpty').test(value);
				}
				return true;
			}],
			*/
			//若加減碼方式為依加碼數 or 依加碼數計算，不得低於固定利率，則利率加減碼數必須有輸入且須為數字，
			['validate-required-RT_ADJ', '請輸入正確數值', function(value){
				var ADJ_TYPE = previousRecord.record.ADJ_TYPE;
				if( ADJ_TYPE == "1" || ADJ_TYPE == "3" ){
					return !Validation.get('IsEmpty').test(value);
				}
				return true;
			}],
			//若加減碼方式為固定利率 or 依加碼數計算，不得低於固定利率，則優惠的固定利率必須有輸入
			['validate-required-FIX_RT', '請輸入正確數值', function(value){
				var ADJ_TYPE = previousRecord.record.ADJ_TYPE;
				if( ADJ_TYPE == "2" || ADJ_TYPE == "3" ){
					return !Validation.get('IsEmpty').test(value);
				}
				return true;
			}],
			//每月應繳日必須有輸入且須為1～31數字，否則顯示錯誤訊息：”請輸入正確的值”
			['validate-Number-DutyDay', '請輸入正確的值.', function(v) {
					return Validation.get('validate-integer').test(v);
				}, {gt:0,lt:32}],
			//每月應繳日必須有輸入且須為1～31數字，否則顯示錯誤訊息：”請輸入正確的值”
			['validate-Number-PAID_TIMES', '請輸入正確的值.', function(v,elm) {
					return !Validation.get('IsEmpty').test(v) && Validation.get('validate-digits').test(elm.getValue());
			}],
			[ 'chkLOAN_ID',  '請輸入貸款帳號!', function(){ 
				if($('QUERY_TYPE_0').checked && $F('LOAN_ID') === ""){ return false; } $('LOAN_ID').value=$F('LOAN_ID').toUpperCase(); return true; 
			}] ,
			[ 'chkAPPLY_ID',  '請輸入受理編號!', function(){ 
				if($('QUERY_TYPE_1').checked && $F('APPLY_ID') === ""){ return false; } $('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); return true; 
			}],
			[ 'chkCAL_DATE1',  '請輸入試算日期!', function(){ 
				if($('CAL_TYPE_0').checked && $F('CAL_DATE') === ""){ return false; }  return true; 
			}],
			[ 'chkCAL_TERM1',  '請輸入試算期數!', function(){ 
				if($('CAL_TYPE_1').checked && $F('CAL_TERM') === ""){ return false; }  return true; 
			}],
			[ 'chkCAL_DATE2',  '試算日期輸入有誤!', function(){ 
				if($('CAL_TYPE_0').checked && !isROCdate($F('CAL_DATE'))){ return false; } return true; 
			}],
			[ 'chkCAL_TERM2',  '試算期數輸入有誤!', function(){ 
				if($('CAL_TYPE_1').checked && isNaN($F('CAL_TERM'))){ return false; } return true; 
			}]
		]);	
		
		
		//valid1 = new Validation(new Element('form1'));
		valid1 = new Validation('form1');
		//valid1.define("required" , { id : "LOAN_ID" , errMsg : "請輸入貸款帳號" } );
		//valid1.define("required" , { id : "CAL_DATE" , errMsg : "查詢日期輸入有誤" } );
		//valid1.define("validate-ROCDate" , { id : "CAL_DATE" , errMsg : "查詢日期輸入有誤" } );
		
		valid2 = new Validation('form2');
		//valid2.define("required" , { id : "CAL_DATE" , errMsg : "查詢日期輸入有誤" } );
		//valid2.define("validate-ROCDate" , { id : "CAL_DATE" , errMsg : "查詢日期輸入有誤" } );
		
		//valid2.define( "validate-required-INSU_NOTE" , { id: "INSU_NOTE" } );
		
		
		/*
		valid3 = new Validation($('form3'));		
		valid3.define( "validate-required-INSU_NOTE" , { id: "INSU_NOTE" } );
		*/
		
		valid3 = new Validation($('grid1'));		
		valid3.define( "validate-required-INSU_NOTE" , { id: "INSU_NOTE" } );
		
	}
	
	return{
	
		initApp :function(){
			PageUI.createPageWithAllBodySubElement("DSC0_1000" , "核心放款" , "利率試算" );
			initSelectList();
			initTableUI();
			initValidation();
			
			$('Btn_add','Btn_calculate','Btn_delete','Btn_query','Btn_update').each(function(elm){
				elm.observe( 'click' , actions[elm.id] );
			});
			
			
			
			$("INSU_NOTE").observe('change',function(event){				
					genPrankList();
			  });	
			$("PROD_ID").observe('change',function(event){				
					changeProd();
			  });
			  	
			if('${LOAN_ID}'){
				$('LOAN_ID').value='${LOAN_ID}';
				$('CAL_TYPE_0').checked=true;
				$('CAL_DATE').value='${CAL_DATE}';
				actions.Btn_query();
			}
			
			autoFormatToNumber();
			
			displayMessage();
			
		}//end init()--		
	};//end return--
	//-------------------------------------------------------------------------- 
}
//-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" > 
	<form id="form1" name="form1" method="post">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="15%">
					<input type="radio" name="QUERY_TYPE" id="QUERY_TYPE_0" value="0" checked />貸款帳號</td>
				<td class="tbYellow2"  >
					<input type="text" name="LOAN_ID" id="LOAN_ID" class="textBox2 chkLOAN_ID" maxLength="11" size="15" value="'${LOAN_ID}'" />
				</td>
				<td class="tbYellow" width="15%">
					<input type="radio" name="QUERY_TYPE" id="QUERY_TYPE_1" value="1" />受理編號</td>
				<td class="tbYellow2"  >
					<input type="text" name="APPLY_ID" id="APPLY_ID" class="textBox2 chkAPPLY_ID" maxLength="11" size="15" value="" />
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
					<input type="button" id="Btn_query" class="button" value="查詢" />
					<input type="hidden" name="PAY_KIND" id="PAY_KIND" value="0" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">
					<input type="radio" name="CAL_TYPE" id="CAL_TYPE_1" value="1" checked/>試算期數</td>
				<td class="tbYellow2"  >
					<input type="text" name="CAL_TERM" id="CAL_TERM" class="textBox2 chkCAL_TERM1 chkCAL_TERM2" maxLength="5" size="5" value="2" />
				</td>
				<td class="tbYellow" width="15%">
					<input type="radio" name="CAL_TYPE" id="CAL_TYPE_0" value="0" />試算日期</td>
				<td class="tbYellow2"  >
					<input type="text" id ="CAL_DATE" name="CAL_DATE" datatype="ROCDate" class="textBox2 chkCAL_DATE1 chkCAL_DATE2" size="10" maxlength="8" value=${SYS_DATE}  >
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('CAL_DATE'))">
				</td>				
			</tr>
		</table>
	</form>
	
	
	<form id="form2" name="form2" >
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="section2" >
			<tr>
				<td colSpan="4" class="tbYellow0 textBold">
					收息主檔資料
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">貸放日期</td>
				<td class="tbYellow2" width="35%" >
					<input type="text" fieldName="貸放日期" id="LOAN_DATE" name="LOAN_DATE" datatype="ROCDate" class="textBox2 required validate-ROCDate" size="10" maxlength="7" />
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('LOAN_DATE'))" />
					<font color="red"><span id="LOAN_DATE_span"></span></font>
				</td>
				<td class="tbYellow" width="15%">每月應繳日</td>
				<td class="tbYellow2" width="35%" >
					<input type="text" fieldName="每月應繳日" id="DUTY_DAY" name="DUTY_DAY" class="textBox2 validate-Number-DutyDay" size="10" maxlength="2" datatype="number" >
					<font color="red"><span id="DUTY_DAY_span"></span></font>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">下次應繳日</td>	
				<td class="tbYellow2" width="35%">
					<input type="text" fieldName="下次應繳日" id ="NEXT_PAYDT" name="NEXT_PAYDT" datatype="ROCDate" class="textBox2 required validate-ROCDate" size="10" maxlength="7" >
					<img class="img" src="<%=imageBase%>/CM/calendar.gif" width="20" height="20" onClick="getCalendarFor($('NEXT_PAYDT'))">
					<font color="red"><span id="NEXT_PAYDT_span"></span></font>
				</td>	
				<td class="tbYellow" width="15%">已繳次數</td>
				<td class="tbYellow2" width="35%" >
					<input type="text" fieldName="已繳次數" id ="PAID_TIMES" name="PAID_TIMES" class="textBox2" datatype="number" size="10" maxlength="7" />
					<font color="red"><span id="PAID_TIMES_span"></span></font>
				</td>
			</tr>
			<!--
			<tr>
				<td class="tbYellow" width="15%">有效次數</td>	
				<td class="tbYellow2" width="35%">
					<input type="text" fieldName="有效次數" id ="VALID_TIMES" name="VALID_TIMES" class="textBox2 validate-Number-PAID_TIMES" datatype="number" size="10" maxlength="7" />
				</td>	
				<td class="tbYellow" width="15%">預繳次數</td>
				<td class="tbYellow2" width="35%" >
					<input type="text" fieldName="預繳次數" id ="PREPAY_TIMES" name="PREPAY_TIMES" class="textBox2 validate-Number-PAID_TIMES" datatype="number" size="10" maxlength="7" />
				</td>
			</tr>
			-->
			<tr>
				<td class="tbYellow" width="15%">扣薪組別</td>	
				<td class="tbYellow2" width="35%">
					<SELECT name="SALARY_GROUP" id="SALARY_GROUP" >
					<!--  <option value="">請選擇</option> -->
					<c:forEach var="map" items="${SalaryGroupList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="SALARY_GROUP_span"></span></font>
				</td>
				<!--  	
				<td class="tbYellow" width="15%">繳款方式</td>
				<td class="tbYellow2" width="35%" >
					<SELECT name="PAY_TYPE" id="PAY_TYPE" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${PayTypeList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
				</td>
				-->
				<td class="tbYellow" width="15%">地區代號</td>	
				<td class="tbYellow2" width="35%">
					<SELECT name="AREA_CODE" id="AREA_CODE" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${AreaCodeList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="AREA_CODE_span"></span></font>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%">商品種類</td>
				<td class="tbYellow2" width="35%" >
					<SELECT name="PROD_ID" id="PROD_ID" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${prodNmsList}">
					<option value="${map.PROD_ID}">${map.PROD_ID}_${map.PROD_SRT_NAME}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="PROD_ID_span"></span></font>
				</td>						
				<td class="tbYellow" width="15%">優質客戶優惠等級</td>
				<td class="tbYellow2" width="35%" >
					<SELECT name="VIP_GRADE" id="VIP_GRADE" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${VIPGradeList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="VIP_GRADE_span"></span></font>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" width="15%">優惠種類</td>	
				<td class="tbYellow2" width="35%">
					<SELECT name="PREFER_TYPE" id="PREFER_TYPE" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${PreferTypeList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="PREFER_TYPE_span"></span></font>
				</td>	
				<td class="tbYellow" width="15%">貸款種類</td>
				<td class="tbYellow2" width="35%" >
					<SELECT name="LOAN_KIND" id="LOAN_KIND" >
					<option value="">請選擇</option>
					<c:forEach var="map" items="${LoanKindList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>
					</SELECT>
					<font color="red"><span id="LOAN_KIND_span"></span></font>
				</td>
			</tr>			
			<tr>					
				
				<td class="tbYellow" width="15%">保戶優惠</td>	
				<td class="tbYellow2" width="35%"  colSpan="3">
					<span>保戶優惠種類:</span>
					<SELECT name="INSU_NOTE" id="INSU_NOTE">
					<option value="">請選擇</option>
					<c:forEach var="map" items="${InsuNoteList}">
					<option value="${map.key}">${map.value}</option>
					</c:forEach>					
					</SELECT>
					<font color="red"><span id="INSU_NOTE_span"></span></font>
					<br>
					<span>保戶等級:</span>
					<select name="INSU_PRANK" id="INSU_PRANK" >
					<option value="">請選擇</option>
					</select>
				</td>
			</tr>
		</table>
		 
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		
			<tr>
				<td class="tbYellow0 textBold">
					優惠利率
				</td>
			</tr>
			
			<tr>
				<td>
					<table id="grid1">
						</table>
				</td>
			</tr>
			
			<tr>
				<td class="tbYellow2" align="center">
					<input type="button" id="Btn_add" class="button" value="新增" />
					<input type="button" id="Btn_update" class="button" value="修改" />
					<input type="button" id="Btn_delete" class="button" value="刪除" />
				</td>
			</tr>
		</table>
	 
	</form>
	
	<!-- 
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		
		<tr>
			<td class="tbYellow0 textBold">
				優惠利率
			</td>
		</tr>
		
		<tr>
			<td>
				<form id="form3" name="form3" >		
								
					<table id="grid1">
					</table>
					
				</form>
			</td>
		</tr>
		
		<tr>
			<td class="tbYellow2" align="center">
				<input type="button" id="Btn_add" class="button" value="新增" />
				<input type="button" id="Btn_update" class="button" value="修改" />
				<input type="button" id="Btn_delete" class="button" value="刪除" />
			</td>
		</tr>
	</table>
	 -->
	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr><td class="tbYellow2" align="center" colSpan="2">
				<input type="button" id="Btn_calculate" class="button" value="試算" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow0 textBold">
				試算結果
			</td>
		</tr>
		<tr>
			<td>
				<table id="grid2">
				</table>
			</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0 textBold">
				原始利率
			</td>
		</tr>
		<tr>
			<td>
				<table id="grid3">
				</table>
			</td>
		</tr>
	</table>
</body>
</html>