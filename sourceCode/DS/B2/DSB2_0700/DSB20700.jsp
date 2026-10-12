<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB20700.jsp
作者：王文進
功能：設定控管輸入。
完成：2012/05/22
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
var DSB20700 = new DSB20700();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB20700.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB20700(){
	
	var grid;
	var SCRIVENER_LIST;
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0136:"btn_receive"<%--領用--%>,
				B0004:"btn_update"<%--修改--%>,
				B0137:"btn_delete"<%--作廢--%>
		};
		
		<dz:grantButtons FUNC_ID="DSB20700" ignored="false"/>
	}
	
	//檢核變數
	var valid1;	
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'checkSRV_DEPT',  '請選擇申請單位再執行查詢',
				function(v){
					return 	v.length==0 ? false : true;
				}
			]
		]);
		//查詢 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "checkSRV_DEPT" , { id: "SRV_DEPT" } );
	}    

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSB2_0700/" + actionName,
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
			
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}
			
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					SCRIVENER_LIST = resp.SCRIVENER_LIST ? resp.SCRIVENER_LIST : [];
					grid.load(resp.rtnList ? resp.rtnList : []);				
				},
				function(resp){
					//失敗把前次內容清掉 
					grid.load([]);
				}
			);		
		},
		//查詢申請單位下拉選單
		doGetSRV_LIST : function(obj){	

			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'getSRV_LIST' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					sourceList = resp.SRV_LIST ? resp.SRV_LIST : [];
					$('SRV_DEPT').length = 0;
					for(var mover=0; mover < sourceList.length ; mover++) {
						var targetMap = sourceList[mover];
						var elOptNew = document.createElement('option');
						elOptNew.text =  targetMap["SRV_DEPT_NAME"];
						elOptNew.value = targetMap["SER_DEPT_NO"];
						$('SRV_DEPT').add(elOptNew);
					}
				},
				function(resp){
					//失敗把前次內容清掉 
					$('SRV_DEPT').length = 0;
				}
			);		
		},
		//領用
		doReceive : function(obj){	

			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲領用資料，才能作業");
				return;
			}
		
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'receive' , {sendRecord : Object.toJSON(sendRecord),checkRecords : Object.toJSON(checkRecords)	},
				function(resp){
					SCRIVENER_LIST = resp.SCRIVENER_LIST ? resp.SCRIVENER_LIST : [];
					grid.load(resp.rtnList ? resp.rtnList : []);				
				}
			);		
		},
		//修改
		doUpdate : function(obj){	

			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲修改資料，才能作業");
				return;
			}
		
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'update' , {sendRecord : Object.toJSON(sendRecord),checkRecords : Object.toJSON(checkRecords)	},
				function(resp){
					SCRIVENER_LIST = resp.SCRIVENER_LIST ? resp.SCRIVENER_LIST : [];
					grid.load(resp.rtnList ? resp.rtnList : []);				
				}
			);		
		},
		//作廢
		doDelete : function(obj){	

			var checkRecords = grid.getCheckedRecord();
			if(!checkRecords.length >0){
				alert("請先勾選欲作廢資料，才能作業");
				return;
			}
		
			var sendRecord = makeRecord();

			//發送ajax
			ajaxPost( 'delete' , {sendRecord : Object.toJSON(sendRecord),checkRecords : Object.toJSON(checkRecords)	},
				function(resp){
					SCRIVENER_LIST = resp.SCRIVENER_LIST ? resp.SCRIVENER_LIST : [];
					grid.load(resp.rtnList ? resp.rtnList : []);				
				}
			);		
		}
		

	};
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {'CRED_DEPT':$('CRED_DEPT').value,'SRV_DEPT':$('SRV_DEPT').value,'TYPE':$('TYPE').value};
		return sendRecord;	
	}
	
	//特約代書
	function initSCRIVENER_LIST(node) {
		var elOptNew = document.createElement('option');
		elOptNew.text =  "請選擇";
		elOptNew.value = "";
		node.add(elOptNew);
		for(var mover=0; mover < SCRIVENER_LIST.length ; mover++) {
			var targetMap = SCRIVENER_LIST[mover];
			var elOptNew = document.createElement('option');
			elOptNew.text =  targetMap["SCRIVENER_NAME"];
			elOptNew.value = targetMap["SCRIVENER_NAME"];
			node.add(elOptNew);
		}
	}
	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB20700", "匯款文件", "設定控管輸入", 1);			
				grid = new TableUI ( {
						table:$("grid"), pageSize: 10, allSortable:true ,
						autoCheckBox:{ type: 'checkbox', text:'選取', isSelectAll: true},
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { parseEUDC('ap'); }
			            },
						column:[
							{header: "流水序號",key: "SEQ_NO"},
							{header: "類別",key: "TYPE_NM"},
							{header: "狀態 ",key: "STATUS_NM"},
							{header: "受理編號",key: "APPLY_ID",
								input:{
									type:'TEXT',
									size:12,
									genRule:function(rec , val){
										return true;
									},
									action:function( node , dataObj , textDiv, orgData , isOnChange ){
										if(!isOnChange){
											node.setAttribute("className" , "checkInputLength");
										}
										node.value = node.value.toUpperCase();
										node.maxLength = 11;
										dataObj[0]["APPLY_ID"] = (node.value ? node.value : "");
									}, actionWhenStart:true
								}
							},
							<%-- [20240607] 難字調整 --%>
							{header: "行銷專員",key: "KEEPER_NAME", attrs:{ style:"font-family:'EUDC'" }},
							{header: "特約代書",key: "SCRIVENER_NAME",
								input:{
									type:'select',
									actionWhenStart:true,
									action : function( node , dataObj , textDiv, record, isOnChange){
										if(!isOnChange){
											<%-- [20240607] 難字調整 --%>
											node.setAttribute('alt','ch');
											initSCRIVENER_LIST(node);
											//設定預設值
											if(!dataObj[0]['SCRIVENER_NAME']) {
												//node.value = "";
											}else {
												node.value = dataObj[0]['SCRIVENER_NAME'];
											}
											node.id = 'SCRIVENER_NAME_VIEW_' + dataObj[0]["SEQ_NO"];
										}
										dataObj[0]["SCRIVENER_NAME"] = (node.value ? node.value : "");
									},
									genRule:function(record , value){
										return record.SCRIVENER_NAME == '' ? true : false;
									}
								},render:function(record,value){
									return value ? value : '';
								}
							}
						]
					});
			
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_receive").observe("click", buttons.doReceive );
				$("btn_update").observe("click", buttons.doUpdate );
				$("btn_delete").observe("click", buttons.doDelete );
				$("CRED_DEPT").observe("change", buttons.doGetSRV_LIST );
				
				initValidation();	
				
				fix();

				displayMessage();	
				
				buttonAuth();
				
				buttons.doGetSRV_LIST();

			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="12%">
					行政中心別
				</td>
				<td class="tbYellow2">
					<select name="CRED_DEPT" id="CRED_DEPT">
						<c:forEach var="map" items="${CRED_DEPT_LIST}">
							<option value='${map.key}'>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="12%">
					文件類別
				</td>
				<td class="tbYellow2">
					<select name="TYPE" id="TYPE">
						<option value='0'>舊式</option>
						<option value='1'>新式</option>
					</select>
				</td>
				<td class="tbYellow" width="12%">
					申請單位
				</td>
				<td class="tbYellow2">
					<select name="SRV_DEPT" id="SRV_DEPT">
					</select>
				</td>
				<td class="tbYellow2" align="center">
					<input type="button" class="button" id="btn_query" value="查詢">
				</td>
			</tr>
			<tr>
				<td align="center" colspan="5">
					<input type="button" class="button" id="btn_receive" value="領用">
					<input type="button" class="button" id="btn_update" value="修改">
					<input type="button" class="button" id="btn_delete" value="作廢">
				</td>
			</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>
</body>
</html>