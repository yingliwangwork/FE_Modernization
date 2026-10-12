<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSC91200.jsp
作者：鄭明修
功能：資金流向查核審查作業
完成：2016/02/16

[20230325]難字修改
-->

<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<title></title>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/javascript" src="<%=htmlBase%>/CM/js/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<style type="text/css"><%-- [20230325]難字修改 --%>
	@font-face{
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
			url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
		font-weight:normal;
		font-style:normal
	}	
</style>
<script type="text/javascript">

// 產生畫面物件
var DSC91200 = new DSC91200();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, "load", DSC91200.initApp);
Event.observe(window, "resize", fix);
Event.observe(window, "scroll", fix);

function DSC91200(){

	var grid;
	var reqMap;
	var isQuery = false; //是否已查詢過
	var oldReqMap; //上一次的查詢條件:用來判斷與新的查詢條件是否一樣, 列印前會檢查
	var APPLY_ID;
	
	function buttonAuth() {
		var authButtons = { 
			B0168 : 'btn_sendJCIC' <%--聯徵送出--%>,
			B0169 : 'btn_checkCred' <%--徵信作業--%>,
			B0117 : 'btn_confirm' <%--組長覆核--%>,
			B0118 : 'btn_final' <%--主管覆核--%>
		};	
		<dz:grantButtons FUNC_ID="DSC91200" ignored="false"/>
	}
	
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateAPPLY_ID_11',  '受理編號不正確，長度 需為11碼且為英數字!',
				function(v){				
					return (v.length != 11 && (/^[a-zA-Z0-9@]+$/.test(v))) ? false : true ;
				}
			]
		]);
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define('validateAPPLY_ID_11' , [{ id : "APPLY_ID" }] );
		
	
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSC9_1200/');
 
	var actions = {
		//儲存查詢條件
		storeMap :function(){
			return{
		    	APPLY_ID:$F('APPLY_ID'), //受理編號
				CRED_DEPT:$F('CRED_DEPT'), //承辦科別
				CHECK_YYMM:$F('CHECK_YYMM'), //查核月份
				SORT_KEY:$F('SORT_KEY'), //排序方式
				CRED_ID: $F('CRED_ID'), //徵信人員
				PROC_STATUS:$F('PROC_STATUS'), //處理進度
				BANK_KIND:$F('BANK_KIND') //銀行別
				
		    }
		},

		//承辦科別下拉選單連動徵信人員下拉選單
		doChangeCRED_ID :function(event){
			var rec_CRED_DEPT = event.target.value;
			ajaxRequest.setSynchronous(true);
			ajaxRequest.post( 'changeCRED_ID' , {CRED_DEPT : rec_CRED_DEPT},
				function(resp){
					var RLDS2_LIST = resp.RLDS2_LIST;
					$('CRED_ID').options.length = 1;
					if(RLDS2_LIST){						
						RLDS2_LIST.each(
							function(data) {
								$('CRED_ID').add(new Option(data.NAME, data.ID));
							}		
						); 	
					}
				}
			);
			ajaxRequest.setSynchronous(false);	
		},
		
		//開啟新視窗(WINDOW OPEN)至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
/*		linkTo2200 :function(rec, innerHTML){
			var link = '';
		  	if(rec.REQUESTID && rec.HYPER_AUTH == '1'){
		  		link = new Element('a', {href: '#'}).update(innerHTML);
               	link.observe('click', function(event){
               	      var chkList = [
	               		{   
	               			TXID : rec.TXID,
							MSGID : rec.MSGID,
							QDATE : rec.QDATE,
							QUERYKEY1 : rec.QUERYKEY1,
							QUERYKEY2 : rec.QUERYKEY2,
							ISPRINT : rec.ISPRINT	
						}
	               	  ];
					 
                 	  popupWin.windowOpen('${dispatcher}/DSA2_2200/prompt',{
	 	                'parameters': {'chkList': Object.toJSON(chkList), LINK_FROM:'DSC91200'}
	 	              });
                 
                 });
		  	}
			return link;
		},
*/		
		//超連結至DSC9_1201(資金查核銀行交易明細查詢)畫面，供使用者查詢銀行交易明細紀錄
		linkTo1201: function(rec){
			//BANK_DETAIL == “1”(超連結功能是否顯示)時才有超連結
			var link = '';
			if(rec.IS_CATHAY_BANK == '1'){
			  if(rec.BANK_DETAIL == '1'){
				link = new Element('a', {href : '#'}).update('交易明細');
				link.observe('click', function(event){
					var LP_JSON = actions.storeMap();
					LP_JSON.action = '<%=dispatcher%>/DSC9_1201/prompt';
					LP_JSON.BORROW_ID = rec.BORROW_ID;
					LP_JSON.APPLY_ID = rec.APPLY_ID;
					LP_JSON.CRED_DEPT = rec.CRED_DEPT;
					LP_JSON.CRED_ID = rec.CRED_ID;
					LP_JSON.PROC_STATUS = rec.PROC_STATUS;
					LP_JSON.BANK_KIND = rec.BANK_KIND;
					LP_JSON.CHECK_YYMM = rec.CHECK_YYMM;
                	CSRUtil.linkTo(LP_JSON, 'form1');
				});
			  }else{
				//link = '資料未匯入'
				//20191016因TC400080017無交易明細(C981)卻顯示資料未匯入，導致USER誤解，故與家淳討論過改為無交易明細
				link = '無交易明細'
			  }
			}else{
				link = ''
			}
			return link;
		}
		
	}	
	
	var buttons = {
		//查詢
		doQuery: function(){
		    valid1.reset();
		    if ($F('APPLY_ID') != "") {	
		       if(!valid1.validate()){
				   return;
			   }  
		    }
		    		    				
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(actions.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
					isQuery = true;
					oldReqMap = actions.storeMap(); //上一次的查詢條件		
				},function(resp){  // 查詢失敗清除先前的查詢資料		
					grid.load([]);
				}
			);	
		},
		//聯徵送出
		doSendJCIC: function() {	
		    var data = grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲送出資料，才能作業");
			  return;		
			}			
			ajaxRequest.post( 'sendJCIC' , {rtnList:Object.toJSON(data), reqMap:Object.toJSON(actions.storeMap())},
				function(resp){
					//開啟新視窗(WINDOW OPEN)至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
					popupWin.windowOpen('${dispatcher}/DSA2_2200/prompt',{
	 	                'parameters': {'chkList': Object.toJSON(resp.sendList), LINK_FROM:'DSC91200'}
	 	            });
				}
			);
		},
		//徵信作業
		doCheckCred: function() {
			var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲徵信作業資料，才能作業");
			  return;
			} 
			ajaxRequest.post( 'checkCred' , {rtnList:Object.toJSON(data), reqMap:Object.toJSON(actions.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);	
		},
		//組長覆核
		doConfirm: function() {
			var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲覆核資料，才能作業");
			  return;
			}
			ajaxRequest.post( 'confirm' , {rtnList:Object.toJSON(data), reqMap:Object.toJSON(actions.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);	
		},
		//主管覆核
		doFinal: function() {
			var data =grid.getCheckedRecord();	
			if(data.length==0){
			  alert("請先勾選欲覆核資料，才能作業");
			  return;
			}
			ajaxRequest.post( 'final' , {rtnList:Object.toJSON(data), reqMap:Object.toJSON(actions.storeMap())},
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);	
		},
		//列印
		doPrint: function() {
			//請先查詢再列印
			if(!isQuery){
				alert('請先查詢再列印');
				return;
			}					
			reqMap = actions.storeMap();	
			for(key in reqMap){
				if(reqMap[key] != oldReqMap[key]){
					alert('查詢條件與前次不同，請重新查詢後再作業');
					return;
				}				
			}
			
			reqMap.gridJSON = grid.getXlsSettingJSON('資金流向查核審核作業'); 	
			
			// 傳入所需參數
			RPTUtil.executeCreateXlsFile(
				'<%=dispatcher%>/DSC9_1200/print',
				{ reqMap : Object.toJSON(reqMap)}
			);
		}
	};
	
	
	return {
		initApp : function() {			
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" />
			PageUI.createPageWithAllBodySubElement( "DSC91200" , "覆審作業", "資金流向查核審查作業" );
			
			grid = new TableUI({
				table: $("grid"), pageSize: 10, split: ['GUARANTEE_NAME'],
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }<%-- [20230325]難字修改 --%>
				},
				autoCheckBox:{
				    isSelectAll:true
				},	
				column:[	
			     	{ header:"查核月份", key:"CHECK_DATE", attrs:{rowSpan:2}, sortRule:'date'},				
					{ //以紅色顯示
					  header:"註記", key:"REMARK", attrs:{rowSpan:2},
					  render:function(rec, val){
					  	var div = new Element('div');
					  	var span = new Element('span', {innerHTML:'<font color="red">'+val+'</font>'});
					  	div.insert(span);
					  	return div;
					  } 
					},
					{ header:"受理編號", key:"APPLY_ID", attrs:{rowSpan:2} },
					{ header:"借款人", key:"BORROW_NAME", attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{ header:"借款人ID", key:"BORROW_ID" },
					{ header:"原貸款金額", key:"LOAN_AMT", attrs:{rowSpan:2, align:'right'}, sortRule:'number'},
					{ header:"入戶金額", key:"REMIT_AMT", attrs:{rowSpan:2, align:'right'}, sortRule:'number'},
					{ 
					  header:"銀行交易明細", key:"BANK_DETAIL", attrs:{rowSpan:2},
					  render:function(rec, val){
					  	return actions.linkTo1201(rec);
					  } 
					},
					{ 
					  header:"簽件時聯徵記錄", key:"REQUESTID", attrs:{rowSpan:2}, 
					  render:function(rec, val){
						  var link = '';
		                  if(rec.REQUESTID && rec.HYPER_AUTH == '1'){
		            		link = new Element('a', {href: '#'}).update("005");
                        	link.observe( 'click', function (event){ 
											//開啟新視窗(WINDOW OPEN)至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
                                            var chkList=[{
											    TXID: rec.TXID, //查詢項目
											    MSGID: rec.MSGID, //訊息編號
												QDATE: rec.QDATE, //查詢日期
												QUERYKEY1: rec.QUERYKEY1, //被查詢者的ID
												QUERYKEY2: rec.QUERYKEY2, //關係年月/月/季(標準)
											    ISPRINT: rec.ISPRINT, //是否要列印查詢記錄
											    CASE_ID : rec.APPLY_ID, //[申請書:24120444624]建立聯徵查詢存取軌跡紀錄:多傳入受理編號or貸款帳號
											    NAME: rec.BORROW_NAME
											}]
											//@ 2018/09/28 王文進 調整查詢聯徵歷史資料來源
											var toDay = addDate(getY2KToday(),0,0,-7);
											var qDate = toY2K(rec.QDATE);
											if(diffDay(qDate, toDay) >= 0){
												popupWin.windowOpen('<%=dispatcher%>/DSA2_0410/queryDetail',{
													'windowName': rec.MSGID,
													'parameters': {
														'LINK_FROM': "DSC91200",
														'chkList' : Object.toJSON(chkList)				
													}
												});
											}else{
												popupWin.windowOpen('<%=dispatcher%>/DSA2_2200/prompt',{
													'windowName': rec.MSGID,
													'parameters': {
														'LINK_FROM': "DSC91200",
														'chkList' : Object.toJSON(chkList)				
													}
												});
											}
										});	
										return link; 			
		                 }else{
									    return "";  
						 }
		              	return val;	
					  }
					},					
					{ 
					  header:"聯徵記錄", key:"REQUESTID_B42", attrs:{rowSpan:2}, 
					  render:function(rec, val){
						  var link = '';
		                  if(rec.REQUESTID_B42 && rec.HYPER_AUTH == '1'){
		            		link = new Element('a', {href: '#'}).update("B42");
                        	link.observe( 'click', function (event){ 
											//開啟新視窗(WINDOW OPEN)至 “DSA2_2200”(聯徵系統連結)畫面，將資料傳至聯徵系統
                                            var chkList=[{
											    TXID: rec.TXID_B42, //查詢項目
											    MSGID: rec.MSGID_B42, //訊息編號
												QDATE: rec.QDATE_B42, //查詢日期
												QUERYKEY1: rec.QUERYKEY1_B42, //被查詢者的ID
												QUERYKEY2: rec.QUERYKEY2_B42, //關係年月/月/季(標準)
											    ISPRINT: rec.ISPRINT_B42, //是否要列印查詢記錄
											    CASE_ID : rec.APPLY_ID, //[申請書:24120444624]建立聯徵查詢存取軌跡紀錄:多傳入受理編號or貸款帳號
											    NAME: rec.BORROW_NAME
											}]
											//@ 2018/09/28 王文進 調整查詢聯徵歷史資料來源
											var toDay = addDate(getY2KToday(),0,0,-7);
											var qDate = toY2K(rec.QDATE_B42);
											if(diffDay(qDate, toDay) >= 0){
												popupWin.windowOpen('<%=dispatcher%>/DSA2_0410/queryDetail',{
													'windowName': rec.MSGID_B42,
													'parameters': {
														'LINK_FROM': "DSC91200",
														'chkList' : Object.toJSON(chkList)				
													}
												});
											}else{
												popupWin.windowOpen('<%=dispatcher%>/DSA2_2200/prompt',{
													'windowName': rec.MSGID_B42,
													'parameters': {
														'LINK_FROM': "DSC91200",
														'chkList' : Object.toJSON(chkList)				
													}
												});
											}
										});	
										return link; 			
		                 }else{
									    return "";  
						 }
		              	return val;	
					  }
					},
		       /*	{ 
					  header:"銀行件", key:"IS_CATHAY_BANK", attrs:{rowSpan:2},
					  render:function(rec, val){
					  	if(rec.IS_CATHAY_BANK == '1'){
					  	    return "是";
					  	}else{
							return "否";    
					    } 
					    return val;	
					  }
					}, */
					{ 
					  header:"是否正常", key:"IS_NORMAL", attrs:{rowSpan:2},
					  render:function(rec, val, sn){
						  	var div = new Element('div');
						  	var radio1 = new Element('input', {type:'radio', value:'0', name:'IS_NORMAL'+sn});
						  	var span1 = new Element('span', {innerHTML:'正常'});
						  	var radio2 = new Element('input', {type:'radio', value:'1', name:'IS_NORMAL'+sn});
						  	var span2 = new Element('span', {innerHTML:'待釐清'});
						  	div.insert(radio1);
						  	div.insert(span1);
						  	div.insert(radio2);
						  	div.insert(span2);
						  	if(val && val == radio1.value){ //已有值且值=該radio->checked
								radio1.checked = true;
							}else if(val && val == radio2.value){
								radio2.checked = true;								
							}
						  	radio1.observe('click', function(event){
								rec.IS_NORMAL = this.value;
							});
							radio2.observe('click', function(event){
								rec.IS_NORMAL = this.value;
							});
														
							return div;
					  } 
					},
					{ header:"查核人員", key:"CRED_NAME", attrs:{rowSpan:2} },
					{ header:"查核日期", key:"PROC_DATE", attrs:{rowSpan:2}, sortRule:'date'},
					{ 
					  header:"說明", key:"CHECK_NOTE", attrs:{rowSpan:2 ,style:"font-family:'EUDC'"}, <%-- [20230325]難字修改 --%>
					  render:function(rec, val){
					    var CHECK_NOTE = "CHECK_NOTE";
					  	var TextArea = new Element("TextArea", {id: CHECK_NOTE, name: CHECK_NOTE, rows:3, cols:40, maxlength:500, alt:"ch"});<%-- [20230325]難字修改 --%>
					  	TextArea.value = val;
					  	TextArea.observe('change', 
					  		function(event){ rec.CHECK_NOTE = TextArea.value }
					  	);
					  	return TextArea;
					  } 
					},
					{ header:"覆核人員", key:"CONFIRM_NAME", attrs:{rowSpan:2 ,style:"font-family:'EUDC'"} },<%-- [20230325]難字修改 --%>
					{ header:"覆核日期", key:"CONFIRM_DATE", attrs:{rowSpan:2}, sortRule:'date'},
					{ header:"主管覆核", key:"FINAL_NAME", attrs:{rowSpan:2} },
					{ header:"主管覆核日期", key:"FINAL_DATE", attrs:{rowSpan:2}, sortRule:'date'},
					{ header:"保證人", key:"GUARANTEE_NAME" , attrs:{style:"font-family:'EUDC'"} },	<%-- [20230325]難字修改 --%>
					{ header:"保證人ID", key:"GUARANTEE_ID" }
				]
			});
			
			buttonAuth();
			initValidation();
				   
			$('btn_query').observe('click', buttons.doQuery);
            $('btn_sendJCIC').observe('click', buttons.doSendJCIC);
            $('btn_checkCred').observe('click', buttons.doCheckCred);
            $('btn_confirm').observe('click', buttons.doConfirm);
            $('btn_final').observe('click', buttons.doFinal);
            $('btn_print').observe('click', buttons.doPrint);
            //連動徵信人員
			$("CRED_DEPT").observe('change', actions.doChangeCRED_ID);
			          
			if($F('APPLY_ID')){
				buttons.doQuery();			
			}
					
						
			//-----------------------------------------------------
			//以下為進入初始頁面時需要執行的動作
			//-----------------------------------------------------			
			PageUI.resize();
			displayMessage();
			
			var LP_JSON = CSRUtil.isBackLink('form1');			
			if(LP_JSON){
		        $("CRED_DEPT").simulate('change');	
		        $('CRED_ID').setValue(LP_JSON.CRED_ID);  
				buttons.doQuery();
			}			
		}
	};	
};

</script>
</head>
<body>		
<form id="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
	<tr>
		<td class="tbYellow">承辦科別</td>
		<td class="tbYellow2">
			<select id="CRED_DEPT" name="CRED_DEPT" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${CRED_DEPT_LIST}" >
					<option value="${map.key}">${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">查核月份</td>
		<td class="tbYellow2">
			<select id="CHECK_YYMM" name="CHECK_YYMM" class="textBox2">
				<c:forEach var="map" items="${CHECK_YYMM_LIST}" >
					<option value = "${map.CHECK_YYMM}" > ${map.CHECK_YYMM}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">受理編號</td>
		<td class="tbYellow2" colspan="3">
			<input type="text" name="APPLY_ID" id="APPLY_ID" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="15" maxLength='11' value="${APPLY_ID}"/>
		</td>
		<td align="center" class="tbYellow2" width="10%" rowspan="2">
			<input id="btn_query" type="button" class="button" value="查詢"/><br>
			<input id="btn_print" type="button" class="button" value="列印"/>
		</td>
	</tr>	
	<tr>
		<td class="tbYellow">徵信人員</td>
		<td class="tbYellow2">
			<select id="CRED_ID" name="CRED_ID" class="textBox2" style="font-family:'EUDC'" alt="ch"><%-- [20230325]難字修改 --%>
				<option value="">全部</option>
			</select>
		</td>
		<td class="tbYellow">處理進度</td>
		<td class="tbYellow2">
			<select id="PROC_STATUS" name="PROC_STATUS" class="textBox2">
				<c:forEach var="map" items="${PROC_STATUS_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">銀行別</td>
		<td class="tbYellow2">
			<select id="BANK_KIND" name="BANK_KIND" class="textBox2">
				<option value="">全部</option>
				<c:forEach var="map" items="${BANK_KIND_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">排序方式</td>
		<td class="tbYellow2">
			<select id="SORT_KEY" name="SORT_KEY" class="textBox2">
				<c:forEach var="map" items="${SORT_KEY_LIST}">							
					<option value='${map.key}'>${map.value}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="9">
			<input id="btn_sendJCIC" type="button" class="button" value="聯徵送出"/>
			<input id="btn_checkCred" type="button" class="button" value="徵信作業"/>
			<input id="btn_confirm" type="button" class="button" value="組長審核"/>
			<input id="btn_final" type="button" class="button" value="主管審核"/>
		</td>
	</tr>
	
</table>
</form>
<table id='grid' width='100%'></table>
</body>
</html>