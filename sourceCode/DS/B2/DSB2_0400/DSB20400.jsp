<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20400.jsp
作者：王文進
功能：簽收回條作業。
完成：2012/05/18
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20240607] 難字調整 --%>
<style type="text/css"> 
@font-face {
    font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>

<script type='text/javascript'>

// 產生畫面物件
var DSB20400 = new DSB20400();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20400.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20400(){
	
	var grid;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0028:"btn_confirm"<%--確認--%>,
				B0009:"btn_cancel"<%--取消--%> 
		};
		
		<dz:grantButtons FUNC_ID="DSB20400" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkAPPLY_ID',  '請輸入受理編號再執行查詢', 
				function(v){				
					return 	$('QUERY_TYPE1').checked && v == '' ? false : true;
				}
			],
			[ 'validateAPPLY_IDLength',  '受理編號長度不正確 需為11碼', 
				//檢核受理編號長度
				function(v){
					if($('QUERY_TYPE1').checked && v!==""){
						return v.length === 11 ? true : false;
					}
					return true;
				}
			],
			[ 'validateAPPLY_IDContent',  '受理編號格式有誤', 
				//檢核受理編號長度
				function(v){
					if($('QUERY_TYPE1').checked && v!==""){
						return (/^[a-zA-Z0-9@]+$/.test(v));
					}
					return true;
				}
			],
			[ 'checkDIV_NO',  '請輸入查詢單位再執行查詢', 
				function(v){
					return 	$('QUERY_TYPE2').checked && v == '' ? false : true;
				}
			],
			[ 'validateDIV_NOLength',  '查詢單位長度不正確 需為7碼', 
				function(v){
					if($('QUERY_TYPE2').checked && v!==""){
						return v.length == 7;
					}
					return true;
				}
			],
			[ 'validateDIV_NOContent',  '查詢單位格式有誤', 
				function(v){
					if($('QUERY_TYPE2').checked && v!==""){
						return (/^[a-zA-Z0-9@]+$/.test(v));
					}
					return true;
				}
			],
			[ 'checkDate',  '請輸入一匯日期再執行查詢',
				function(v){
					return 	$('QUERY_TYPE2').checked && v.length==0 ? false : true;
				}
			],
			[ 'checkREMIT1_DATE',  '一匯日期起日大於迄日',
				function(v){
					return 	$('QUERY_TYPE2').checked && diffDay($F('REMIT1_DATE_STR'),$F('REMIT1_DATE_END'), true) < 0 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkAPPLY_ID" , { id: "APPLY_ID" } );
		valid1.define( "validateAPPLY_IDLength" , { id: "APPLY_ID" } );
		valid1.define( "validateAPPLY_IDContent" , { id: "APPLY_ID" } );
		valid1.define( "checkDIV_NO" , { id: "DIV_NO" } );
		valid1.define( "validateDIV_NOLength" , { id: "DIV_NO" } );
		valid1.define( "validateDIV_NOContent" , { id: "DIV_NO" } );
		valid1.define( "checkREMIT1_DATE" , { id: "REMIT1_DATE_STR" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB2_0400/" + actionName,
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
			});
	}	
	
	//buttons對應的event function
	var buttons = {	
		
		//查詢資料
		doQuery : function(event){	
		
		    if($('QUERY_TYPE1').checked){
				$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			}else if ($('QUERY_TYPE2').checked){
			    //單位代號後補0到七碼
				var DIV_NO = $('DIV_NO');
				for (i=DIV_NO.value.length;i<7;i++) {
					DIV_NO.value=DIV_NO.value+"0";
				}
			}
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					grid.load(resp.rtnList);	
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		},
		
		//確認
		doConfirm : function(event){	
			
			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲確認資料，才能作業");
				return;
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'confirm' , { sendRecord : Object.toJSON(sendRecord) ,checkRecords : Object.toJSON(checkRecords) },
				function(resp){
					grid.load(resp.rtnList);	
				}
			);		
		},

		//取消
		doCancel : function(event){	
			
			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲取消確認資料，才能作業");
				return;
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'cancel' , {sendRecord : Object.toJSON(sendRecord) ,checkRecords : Object.toJSON(checkRecords) },
				function(resp){
					grid.load(resp.rtnList);	
				}
			);		
		}

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {}
		if($('QUERY_TYPE1').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE1').value // 受理編號
			sendRecord.APPLY_ID	= $('APPLY_ID').value;
		}else if($('QUERY_TYPE2').checked){
			sendRecord.QUERY_TYPE	= $('QUERY_TYPE2').value; // 查詢單位
			$('DIV_NO').value = $('DIV_NO').value.toUpperCase();
			sendRecord.DIV_NO	= $('DIV_NO').value; // 單位代號
			sendRecord.RECEIVE_TYPE	= $('RECEIVE_TYPE').value; // 簽收別
			sendRecord.REMIT1_DATE_STR	= toY2K($('REMIT1_DATE_STR').value); // 畫面上之一匯日期(起)
			sendRecord.REMIT1_DATE_END	= toY2K($('REMIT1_DATE_END').value); // 畫面上之一匯日期(迄)
		}
		return sendRecord;	
	}			
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20400", "匯款文件", "簽收回條作業", 1);			
				grid = new TableUI ( {
						table:$("grid"), pageSize: 20, allSortable:true ,					
						autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true },
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
			            },
						column:[
							{header: "服務中心",key: "SVR_DEPT"},
							{header: "受理編號",key: "APPLY_ID"},
							{header: "一匯日期",key: "REMIT1_DATE",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},
							<%-- [20240607] 難字調整 --%>
							{header: "借款人姓名",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},
							<%-- [20240607] 難字調整 --%>
							{header: "代書姓名",key: "SCRIVENER_NAME", attrs:{ style:"font-family:'EUDC'" }},
							<%-- [20240607] 難字調整 --%>
							{header: "經手人",key: "AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},
							<%-- [20240607] 難字調整 --%>
							{header: "徵信人員",key: "CRED_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "簽收條",key: "RECEIVE_TYPE_NM"},
							{header: "確認",key: "RECEIVE_DATE",
								render : function (rec , val){
								    return isADdate(val) ? Date.toInputROC(val || "","/") : val;
								}
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_confirm").observe("click", buttons.doConfirm );
				$("btn_cancel").observe("click", buttons.doCancel );
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				buttonAuth();

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE1' value=1 checked>受理編號
				</td>
				<td class="tbYellow2" colspan="5">
					<input type="text" class="textBox2" size="15" maxlength="11" id="APPLY_ID" value="">
				</td>
				<td class="tbYellow2" align="center" rowspan="2">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%">
					<input type='radio' name='QUERY_TYPE' id='QUERY_TYPE2' value=2 >查詢單位
				</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" size="15" maxlength="7" id="DIV_NO" value="${DIV_NO}">
				</td>
				<td class="tbYellow" width="10%">
					簽收別
				</td>
				<td class="tbYellow2">
					<select name="RECEIVE_TYPE" id="RECEIVE_TYPE">
						<option value=''>全部</option>
						<c:forEach var="map" items="${RECEIVE_TYPE_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">
					一匯日期
				</td>
				<td class="tbYellow2">
					<input name="REMIT1_DATE_STR" id='REMIT1_DATE_STR' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${REMIT1_DATE_STR}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REMIT1_DATE_STR'))">
					~
					<input name="REMIT1_DATE_END" id='REMIT1_DATE_END' type="text" class="textBox2 checkDate validate-ROCDate" size="10" maxlength="7" datatype="ROCDate" value="${REMIT1_DATE_END}">
					<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REMIT1_DATE_END'))">
				</td>
			</tr>
			<tr>
				<td align="center" colspan="7">
					<input type="button" class="button" id="btn_confirm" value="確認">
					<input type="button" class="button" id="btn_cancel" value="取消">
				</td>
			</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>	
</body>
</html>