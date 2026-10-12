
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30300.jsp
作者：張智翔
功能：案件分派移轉作業。

2019-08-28 林孟平  鑑價RPA調整畫面查詢條件
[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->

<fmt:setBundle basename='TextResource' />

<html> 
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/date.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<style type="text/css">
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</style>

<script type='text/javascript'>

// 產生畫面物件
var DSA30300 = new DSA30300();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA30300.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30300(){
	//查詢的檢核
	var valid1;
	//派件的檢核
	var valid2;
	var grid;		
	//前次查詢條件
	var queryCondition = {APPR_DEPT : "" , APPR_GROUP :"" , APPLY_PROCESS : "", RPA_STATUS : "", APPLY_ID : ""};
				
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0021:"btn_export"<%--匯出--%>,
				B0067:"btn_assign"<%--派件--%>,
				B0097:"btn_transfer"<%--移轉--%>,
				B0256:"btn_smart"<%--智能派件--%>
		};
		
		<dz:grantButtons FUNC_ID="DSA30300" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([	
		[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼', 
			function(v){				
				return (v!=="" && v.length != 11) ? false : true ;   
			} ],
		[ 'validateChooseAPPR_ID',  '鑑價人員與支援人員請擇一輸入', 
			//當APPLY_ID為空值,其中兩個只能擇一輸入
			function(){				
				var APPR_ID = $("APPR_ID").value;
				var SUPPORT_ID = $("SUPPORT_ID").value;		
				if( (APPR_ID !=="" && SUPPORT_ID !=="") || (APPR_ID ==="" && SUPPORT_ID ==="")){					
					return false;
				}else{
					return true;
				}
			}]
		]);
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validateAPPLY_ID" , { id: "APPLY_ID" } );
		
		//派件,移轉用檢核
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid2.define( "validateChooseAPPR_ID" , { id: "APPR_ID" } );	
		valid2.define( "validateChooseAPPR_ID" , { id: "SUPPORT_ID" } );	
	}
    

	
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSA3_0300/" + actionName,
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
			
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			
			if(!valid1.validate()){ 
				return; 
			}
			//將畫面欄位存成record
			var sendRecord = makeRecord();	
			//將查詢條件存起來
			queryCondition = sendRecord;	
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					grid.load(resp.rtnList);
					appendList(resp.APPR_ID_LIST , $("APPR_ID"));
					appendList(resp.SUPPORT_ID_LIST ,$("SUPPORT_ID"));					
				},
				function(resp){					
					//失敗把前次內容清掉 並把鑑價,支援人員list清掉
					grid.load([]);				
					updateList($("APPR_ID"));
					updateList($("SUPPORT_ID"));
				}
			);		
		},	
		//匯出Excel
		doExport : function(event){
		
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
		
			if(!valid1.validate()){ 
				return; 
			}	
			$('gridJSON').value = grid.getXlsSettingJSON('案件分派移轉作業');
			RPTUtil.executeCreateXlsFile('<%=dispatcher%>/DSA3_0300/export', Form.serialize("form1"));
		},
		//派件
		doAssign : function(event){	
			valid1.reset();
			var checkAssignList = grid.getCheckedRecord();
			if(!checkAssignList.length >0){
				alert("尚未點選任何案件!!");
				return;
			}
			//頁面 檢核
			if(!valid2.validate()){ 
				return; 
			}	
			
			//將條件Map存起來
			var assignRecord = makeEditRecord(checkAssignList); 
			//發送ajax
			ajaxPost( 'assign' , 
			{
				assignRecord : Object.toJSON(assignRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件		
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid.load(resp.rtnList);					
				}
			);	
		},
		
		//移轉
		doTransfer : function(event){
			valid1.reset();
			var checkTransferList = grid.getCheckedRecord();
			if(!checkTransferList.length >0){
				alert("尚未點選任何案件!!");
				return;
			}
			//頁面 檢核
			if(!valid2.validate()){ 
				return; 
			}
			
			//將條件Map存起來
			var transferRecord = makeEditRecord(checkTransferList); 
			//發送ajax
			ajaxPost( 'transfer' , 
			{
				transferRecord : Object.toJSON(transferRecord), //畫面勾選的records
				sendRecord : Object.toJSON(queryCondition) //上次查詢的條件
			},
				function(resp){			
					//重查,並紀錄新的List			
					grid.load(resp.rtnList);					
				}
			);			
		},
		
		//智能派件
		doSmart : function(){
    		
    		popupWin.windowOpen('<%=dispatcher%>/DSA3_1900/prompt',{
		    	'windowName': 'DSA3_1900',
        		'parameters': {'CASE_NO' : $("APPR_DEPT").value, 'CASE_TYPE' : 'DSB'}
    			//20200421 智能派件透過CASE_NO傳送APPR_DEPT的值給電子地圖
    		});
		},
		
		//清除畫面 回到初始狀況
		doClear : function(event){
			//將 鑑價人員 支援人員 ,清空
			updateList($("APPR_ID"));
			updateList($("SUPPORT_ID"));
			$('form1').reset();		
		}
	}
	
	//將畫面資料存成要派件或轉移的List
	function makeEditRecord(list){
		var editList = [];
		for(var i = 0 ; i < list.length ; i++){
			var tempMap = {};
			tempMap["APPLY_ID"] = list[i]["APPLY_ID"];           //受理編號
			tempMap["APPR_ID"] = $("APPR_ID").value ;            //鑑價人員
			tempMap["SUPPORT_ID"] = $("SUPPORT_ID").value  ;     //支援人員
			editList.push(tempMap);
		}
		return editList;
	}
	
	//將畫面A資料存成Record
	function makeRecord(){
		var sendRecord = {
			APPR_DEPT	: $('APPR_DEPT').value ,// 鑑價科
			APPR_GROUP	: $('APPR_GROUP').value ,// 鑑價組	
			APPLY_PROCESS	: $('APPLY_PROCESS').value ,// 鑑價組
			USE_SECT_UPD_STATUS : $('USE_SECT_UPD_STATUS').value ,
			APPLY_ID	: $('APPLY_ID').value //受理編號			
		}
		return sendRecord;	
	}			
	
	//將List增加到下拉選單中
	function appendList(list , target){
		//先清除
		updateList(target);	
		//加入List	
		if(list){
			for(var i = 0; i < list.length; i++){ 
				target.options.add(new Option(list[i]['NAME'], list[i]['ID'])); 
			}
		}
		<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
		parseEUDC();
	}

	//將收下拉選單清除,加入請選擇 , target為要清除的dom物件
	function updateList(target){
		target.update();
		//請選擇
		target.options.add(new Option( "請選擇" , "")); 
	}

	return {

			initApp : function() {

				PageUI.createPageWithAllBodySubElement("DSA30300", "鑑價作業", "案件分派移轉作業", 0);

				grid = new TableUI ( {
					table: $("grid"), pageSize: 20, allSortable:true,
					autoCheckBox:{					
						isSelectAll:true
					},
					column:[
						//{header: "受理編號",key: "APPLY_ID"},
						{header: "受理編號",key: "APPLY_ID",
							render:function(record, value){
								CSRUtil.keepParamsManager.put({'APPLY_ID': record.APPLY_ID });
								var alink = document.createElement("a");
								alink.href = "#";
								alink.innerHTML = record.APPLY_ID;
								alink.onclick = function(){
									var url = "<%=dispatcher%>/DSA3_0200/prompt";
					 				popupWin.windowOpen( url ,{
						        		'parameters': {
						        			'APPLY_ID' : record.APPLY_ID},
											'windowName' : record.APPLY_ID.replace('@', "")
						    		});
								};
								return alink;
							}
						},		
						//{header: "借款人 ",key: "BORROW_NAME_MASK"},
						{header: "收件日期",key: "RECEIVE_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{header: "擔保品地址",key: "GAGE_ADDR1", attrs:{align:'left'}, styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						{header: "案名",key: "CASE_NAME"},
						{header: "社區外觀照日期",key: "UPDATE_PIC_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{header: "前件外觀照日期",key: "APPR_PIC_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
	                    //{header: "前件建築型態",key: "USE_FOR_NM"},
						{header: "受理進度",key: "APPLY_PROCESS_NM"},
						{header: "智能流程進度",key: "IS_AUTOAPPR"},
						{header: "是否免拍",key: "IS_PHOTO"},
						{header: "RPA分區更新",key: "USE_SECT_UPD_STATUS_NM"},
						//{header: "增貸",key: "LOAN_TYPE"},					
						//{header: "同時",key: "COSEND_NOTE"},
						//{header: "重複",key: "RESEND_NOTE"},	
						/*{header: "優先承辦",key: "ELITE_AGENT",
						   render:function(record,value){
								if(value){
									value = '<font color="red">' + value + '</font>';
								}
							 	return value;
							}
						},*/
						/*{header: "派件日期",key: "ASSIGN_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},*/
						{header: "土地面積(坪)",key: "A040_LAND_SPACE",
							render : function(rec , val){
								return val ? CSRUtil.$fmt(val, '#,###.###') :'';
							}
						},
						{header: "建物面積(坪)",key: "A050_BUILD_SPACE",
							render : function(rec , val){
								return val ? CSRUtil.$fmt(val, '#,###.###') :'';
							}
						},
						{header: "鑑價組",key: "APPR_GROUP_NM"},													
						{header: "鑑價人員",key: "APPR_NM", styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						{header: "派件日期",key: "ASSIGN_DATE",
							render:function(record,val){
							 	return val ? Date.toROC(val) : "";
							}
						},
						{header: "社區建築型態",key: "A350_USE_FOR_NM"},
						{header: "前件建築型態",key: "USE_FOR_NM"}
					]
					
				});
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );
				$("btn_export").observe("click", buttons.doExport );
				$("btn_assign").observe("click", buttons.doAssign );	
				$("btn_transfer").observe("click", buttons.doTransfer );
				$("btn_smart").observe("click", buttons.doSmart );	
				$("btn_clear").observe("click", buttons.doClear );
				
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
		<input type="hidden" name="gridJSON" id="gridJSON" value="">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="7%" align="left" >
				鑑價科
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPR_DEPT" name="APPR_DEPT">				
						<option value="">全部</option>
					<c:forEach items="${APPR_DEPT_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" width="7%" align="left" >
				鑑價組
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPR_GROUP" name="APPR_GROUP">				
						<option value="">全部</option>
					<c:forEach items="${APPR_GROUP_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" width="7%" align="left" >
				受理編號
			</td>
			<td class="tbYellow2" width="9%" >
				<input id="APPLY_ID" name="APPLY_ID" type="text" class="text2" size="12" maxlength="11" />				
			</td>
			<td class="tbYellow2"  align = "center" rowspan = "2" width="20%" >
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				<input id = "btn_export" type = "button" class = "button" value = "匯出"/>
				<input id = "btn_clear" type = "button" class = "button" value = "清除"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="7%" align="left" >
				受理進度
			</td>
			<td class="tbYellow2" width="9%" >
				<select id="APPLY_PROCESS" name="APPLY_PROCESS">				
						<option value="">全部</option>
					<c:forEach items="${APPLY_PROCESS_Map}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>
			<td class="tbYellow" width="7%" align="left" >
				RPA分區更新
			</td>
			<td class="tbYellow2" width="9%" colspan = "3">
				<select id="USE_SECT_UPD_STATUS" name="USE_SECT_UPD_STATUS">
						<option value="">全部</option>
					<c:forEach items="${USE_SECT_UPD_STATUS_Map}" var="row">
						<option value="${row.key}"/>${row.value}</option>
					</c:forEach>
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				鑑價人員
			</td>
			<td class="tbYellow2">
				<select  id="APPR_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<option value="">請選擇</option>
				</select>
			</td>	
			<td class="tbYellow" width="8%" align="left" >
				支援人員
			</td>
			<td class="tbYellow2" colspan = "3">
				<select  id="SUPPORT_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<option value="">請選擇</option>
				</select>
			</td>
			<td class="tbYellow2" colspan = "1" align = "center">
				<input id = "btn_assign" type = "button" class = "button" value = "派件"/>
				<input id = "btn_transfer" type = "button" class = "button" value = "移轉"/>
				<input id = "btn_smart" type = "button" class = "button" value = "智能派件"/>
			</td>
		</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>		
		
</body>
</html>