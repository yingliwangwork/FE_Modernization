<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA23000.jsp
功能：案件明細作業(for WorkCell小組新流程使用)
作者：溫子?
完成：2013/

[20240729] 修改件 陳勁谷 難字修改
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/javascript" src='<%=htmlBase%>/CM/js/ui/popupWin.js'></script>

<script type='text/javascript'>
Event.observe(window, 'load', new DSA23000().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSA23000(){
var Q_APPLY_ID;
	// 建立 ajax request 物件    
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSA2_3000/');
	
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
		        B0010 : 'BTN_ASSIGN',      <%--案件派件--%>
		        B0028 : 'BTN_CONFIRM',     <%--作業確認--%>
		        B0008 : 'BTN_CANCEL',       <%--退回--%>
		        B0093 : 'BTN_SUPPORT',      <%--借出申請--%>	
		        B0095 : 'BTN_CANCELSUPPORT'  <%--取消申請--%>		

		};
		
		<dz:grantButtons FUNC_ID="DSA23000" />
	}
	function initValidation(){	
		Validation.addAllThese([
			[ 'validateAPPLY_ID_11',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v.length != 11) ? false : true ;
				}
			],
			[ 'validateMEMO',  '受理編號長度不正確 需小於100個字',
				function(v){				
					return (v.length > 100) ? false : true ;
				}
			]
			
		]);
		//查詢用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		valid1.define('required' , [{ id : "Q_APPLY_ID" , errMsg:"請輸入受理編號!"}] );
		valid1.define('validateAPPLY_ID_11' , [{ id : "Q_APPLY_ID" }] );
		
		valid2 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});
		//valid2.define('required' , [{ id : "DOC_ID" , errMsg:"請選擇文件初審人員!"}] );
		//valid2.define('required' , [{ id : "LST_DOC_ID" , errMsg:"請選擇文件覆審人員!"}] );
		//valid2.define('required' , [{ id : "CRED_ID" , errMsg:"請選擇房貸專員!"}] );
		valid2.define('validateMEMO' , [{ id : "MEMO" }] );
	
	}
	function setView(resp){
		var rtnMap=resp.rtnMap;
		$('table1').select('span').each(function(elem){
			var oID = elem.id;					
			var v = rtnMap[oID];	
			elem.update(v);
		});
	
		var CRED_ID_LIST=resp.CRED_ID_LIST;	
		var REMIT_ID_LIST=resp.REMIT_ID_LIST;
		var DOC_ID_LIST=resp.DOC_ID_LIST;	
		
        //20200114 申請書190829001411-法金專案(受理)：法金件無房貸專員
        if('2'==rtnMap.CRED_DEPT){
        	$('CRED_ID').disable();
        }else{
        	$('CRED_ID').enable();
			if(CRED_ID_LIST){
				$('CRED_ID').options.length = 1;
				for(var i=0;i<CRED_ID_LIST.length;i++){
					$('CRED_ID').add(new Option(CRED_ID_LIST[i]['NAME'],CRED_ID_LIST[i]['ID']));
				}
			}
		}
		if(REMIT_ID_LIST){
			$('REMIT_ID').options.length = 1;
			for(var i=0;i<REMIT_ID_LIST.length;i++){
				$('REMIT_ID').add(new Option(REMIT_ID_LIST[i]['NAME'],REMIT_ID_LIST[i]['ID']));
			}
		}

        if(DOC_ID_LIST){
			$('DOC_ID').options.length = 1;
			$('LST_DOC_ID').options.length = 1;
			for(var i=0;i<DOC_ID_LIST.length;i++){
				$('DOC_ID').add(new Option(DOC_ID_LIST[i]['NAME'],DOC_ID_LIST[i]['ID']));
				$('LST_DOC_ID').add(new Option(DOC_ID_LIST[i]['NAME'],DOC_ID_LIST[i]['ID']));
			}
		}
		
		//移除文初&文複預帶，避免影響實際簽報及查核單位
		$w('MEMO CRED_ID REMIT_ID').each(function(ele){
			$(ele).value=rtnMap[ele]||"";
		})
		$('ASSIGN_TIME').innerHTML=$('ASSIGN_TIME').innerHTML.split(".")[0];
	}
	function getMap(){
		var reqMap={
			APPLY_ID : $F('Q_APPLY_ID'),
			CRED_DEPT : $('CRED_DEPT').innerHTML,
			OP_STATUS : $('OP_STATUS').innerHTML,
			SUPPORT_CD : $('SUPPORT_CD').innerHTML,
			MEMO : $F('MEMO'),
			APPLY_PROCESS : $('APPLY_PROCESS').innerHTML,
			DOC_ID : $F('DOC_ID')||'',
			LST_DOC_ID : $F('LST_DOC_ID')||'',
			CRED_ID : $F('CRED_ID')||'',
			REMIT_ID : $F('REMIT_ID')||'',
			A159_CRED_ID : $('A159_CRED_ID').innerHTML,
            A159_DOC_ID : $('A159_DOC_ID').innerHTML,
            A159_LST_DOC_ID : $('A159_LST_DOC_ID').innerHTML,
            A159_REMIT_ID : $('A159_REMIT_ID').innerHTML,
			ASSIGN_EMP_ID : $('ASSIGN_EMP_ID').innerHTML,
			CHECK_GROUP : $('CHECK_GROUP').innerHTML,
			CHECK_COUNTRY : $('CHECK_COUNTRY').innerHTML
		}
		return reqMap;
	}
	var buttons={
		doQuery : function(){
			valid1.reset();
			if(!valid1.validate()){
				return;
			}
			Q_APPLY_ID=$F('Q_APPLY_ID');

			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': Q_APPLY_ID });

			ajaxRequest.post('query', {'Q_APPLY_ID': $F('Q_APPLY_ID')}        
			, function(resp){
				setView(resp);
			}        
			, function(resp){           
				$('table1').select('span').each(function(elem){
					elem.update('');
				});
				$w('DOC_ID LST_DOC_ID CRED_ID REMIT_ID MEMO').each(function(ele){
					$(ele).value="";
				})
			});
			
		}
		,doAssign : function(){
			valid2.reset();
			if(Q_APPLY_ID!=$F('Q_APPLY_ID')){
				alert("案件派件受理編號與原先查詢的資料不同，無法作業!");
				return;
			}			
			if(!valid2.validate()){
				return;
			}
			
			ajaxRequest.post('assign', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				setView(resp);
			});       
			
		}
		,doConfirm : function(){
			if(Q_APPLY_ID!=$F('Q_APPLY_ID')){
				alert("案件派件受理編號與原先查詢的資料不同，無法作業!");
				return;
			}
			ajaxRequest.post('confirm', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				setView(resp);
			});
		}
		,doSupport : function(){
			if(Q_APPLY_ID!=$F('Q_APPLY_ID')){
				alert("案件派件受理編號與原先查詢的資料不同，無法作業!");
				return;
			}
			ajaxRequest.post('support', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				setView(resp);
			});
		}
		,doCancelSupport : function(){
			if(Q_APPLY_ID!=$F('Q_APPLY_ID')){
				alert("案件派件受理編號與原先查詢的資料不同，無法作業!");
				return;
			}
			ajaxRequest.post('cancelsupport', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				setView(resp);
			});
		}
		,doLink : function(){
			if(Q_APPLY_ID!=$F('Q_APPLY_ID')){
				alert("案件派件受理編號與原先查詢的資料不同，無法作業!");
				return;
			}
			ajaxRequest.post('link', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				popupWin.popup({
					src: '/DSWeb/servlet/HttpDispatcher/DSA2_1901/prompt',
					parameters: {'APPLY_ID':Q_APPLY_ID, 'LINK_FROM':'DSA2_3000'},
					width: 800, 
					height: 450,
					scrolling : 'no'
				});	
				popupWin.callbackHandler = function(){buttons.doCancel();};
			});
		}
		,doCancel : function(){
			ajaxRequest.post('cancel', {'reqMap': Object.toJSON(getMap())}        
			, function(resp){
				setView(resp);
			});
		}
		,doErrInput : function(){
			var LP_JSON = {
				APPLY_ID : $F('Q_APPLY_ID'),
				OP_STATUS : $('OP_STATUS').innerHTML,
				OP_STATUS_NAME : $('OP_STATUS_NAME').innerHTML,
				LINK_FROM : 'DSA23000',
				action : '${dispatcher}/DSA2_1901/prompt'
			};
			CSRUtil.linkTo(LP_JSON, 'form1');
		}
		,doClear : function(){
			$('table1').select('span').each(function(elem){
				elem.update('');
			});
			$$('#table1 input[type!=button] , #table1 select').each(function(ele){
				ele.value="";
			})
		}

	}
	return {
		initApp : function(){
			PageUI.createPageWithAllBodySubElement('DSA23000', '核貸作業', '案件明細作業');			
			initValidation();
			buttonAuth();
			$('BTN_QUERY').observe('click',buttons.doQuery);
			$('BTN_ASSIGN').observe('click',buttons.doAssign);
			$('BTN_CONFIRM').observe('click',buttons.doConfirm);
			//$('BTN_CANCEL').observe('click',buttons.doCancel);
			$('BTN_CANCEL').observe('click',buttons.doLink);
			//$('BTN_ERRINPUT').observe('click',buttons.doErrInput);
			$('BTN_SUPPORT').observe('click',buttons.doSupport);
			$('BTN_CANCELSUPPORT').observe('click',buttons.doCancelSupport);
			$('BTN_CLEAR').observe('click',buttons.doClear);
			 if ('${APPLY_ID}' != "") {
			  $('Q_APPLY_ID').value = '${APPLY_ID}';
			 } else { 
			  //保留參數管理-取得受理編號
			  $('Q_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			 } 
			if($F('Q_APPLY_ID')){
				buttons.doQuery();
			}
			PageUI.resize();
			displayMessage();
		}
		
	}

}
</script>
</head>
<body>
<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="table1">
	<tr>
		<td class="tbYellow"  width="20%">受理編號</td>
		<td class="tbYellow2" >
			<input id="Q_APPLY_ID" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()" size="15" maxLength='11' value="${APPLY_ID}"/>
			<span id="APPLY_PROCESS" style="display:none"></span>
			<span id="ASSIGN_EMP_ID" style="display:none"></span>
			<span id="CRED_DEPT" style="display:none"></span>
			<span id="OP_STATUS" style="display:none"></span>
			<span id="SUPPORT_CD" style="display:none"></span>
			<span id="A159_CRED_ID" style="display:none"></span>
			<span id="A159_DOC_ID" style="display:none"></span>
			<span id="A159_LST_DOC_ID" style="display:none"></span>
			<span id="A159_REMIT_ID" style="display:none"></span>
			<span id="CHECK_GROUP" style="display:none"></span>
			<span id="CHECK_COUNTRY" style="display:none"></span>
		</td>
		<td class="tbYellow2" colspan="6">
			<input id="BTN_QUERY" type="button" class="button" value="查詢" />	
			<input id="BTN_CLEAR" type="button" class="button" value="清除" />	
		</td>
	</tr>
	<tr>
		<td class="tbYellow1" align="center" colspan="8">
			<input id="BTN_ASSIGN" type="button" class="button" value="案件派件移轉" />	
			<input id="BTN_CONFIRM" type="button" class="button" value="文件初審完成" />
			<input id="BTN_CANCEL" type="button" class="button" value="文件覆審退回" />	
			<input id="BTN_SUPPORT" type="button" class="button" value="支援workcell件" />
			<input id="BTN_CANCELSUPPORT" type="button" class="button" value="取消支援" />	
		</td>
	</tr>
	<tr>
		<td class="tbYellow0" align="center" colspan="8">作業功能
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="15%">承辦科別</td>
		<td class="tbYellow2">
			
				<span id="CRED_DEPT_NM" ></span>
			
		</td>
		<td class="tbYellow" width="10%">派件進度</td>
		<td class="tbYellow2"  width="15%">
			
				<span id="OP_STATUS_NAME" ></span>
		
		</td>
		<td class="tbYellow"  width="10%">審查案件單位</td>
		<td class="tbYellow2" >
			
				<span id="W_CRED_DEPT_NM" ></span>
			
		</td>
		<td class="tbYellow" width="10%">匯款案件單位</td>
		<td class="tbYellow2">
			
				<span id="W_REMIT_DEPT_NM" ></span>
			
		</td>	
	</tr>
	<tr>
	   <td class="tbYellow" width="15%">房貸專員</td>
		<td class="tbYellow2">
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="CRED_NM" style="font-family:'EUDC'"></span>
			
		</td>
		<td class="tbYellow" width="10%">文件初審人員</td>
		<td class="tbYellow2"   width="15%">
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="DOC_NM" style="font-family:'EUDC'"></span>
		
		</td>
		<td class="tbYellow"  width="10%">文件覆審人員</td>
		<td class="tbYellow2" >
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="LST_DOC_NM" style="font-family:'EUDC'"></span>
			
		</td>
		<td class="tbYellow" width="10%">匯款初審人員</td>
		<td class="tbYellow2">
				<%--[20240729] 修改件 陳勁谷 難字修改 --%>
				<span id="REMIT_NM" style="font-family:'EUDC'"></span>
			
		</td>	
	</tr>
	<tr>
		<td class="tbYellow"  width="15%">房貸專員</td>
		<td class="tbYellow2" >
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<select id="CRED_ID" alt="ch">
			<option value="">請選擇</option>
			</select> 
		</td>
		<td class="tbYellow"  width="10%">文件初審人員</td>
		<td class="tbYellow2"   width="15%">
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<select id="DOC_ID" alt="ch">
			<option value="">請選擇</option>
			</select> 
		</td>
		<td class="tbYellow"  width="10%">文件覆審人員</td>
		<td class="tbYellow2" >
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<select id="LST_DOC_ID" alt="ch">
			<option value="">請選擇</option>
			</select> 
		</td>
		<td class="tbYellow"  width="10%">匯款初審人員</td>
		<td class="tbYellow2">
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<select id="REMIT_ID" alt="ch">
			<option value="">請選擇</option>
			</select> 
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >備註說明</td>
		<td class="tbYellow2" colspan="7">
			<input id="MEMO" type="text" class="textBox2"   maxLength='100' size="60"/>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >派件人員</td>
		<td class="tbYellow2">	
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<span id="ASSIGN_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" >派件日期</td>
		<td class="tbYellow2" colspan="5">	
			<span id="ASSIGN_DATE" ></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow0" align="center" colspan="8">案件明細
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >受理編號</td>
		<td class="tbYellow2" colspan="7">	
			<span id="APPLY_ID" ></span>
		</td>
		
	</tr>
	<tr>
		<td class="tbYellow" >借款人姓名</td>
		<td class="tbYellow2">	
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<span id="BORROW_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" >貸款種類</td>
		<td class="tbYellow2" colspan="5">	
			<span id="LOAN_KIND_NM" ></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >影像件</td>
		<td class="tbYellow2">	
			<span id="IMAGE_TYPE" ></span>
		</td>
		<td class="tbYellow" >貸款類別</td>
		<td class="tbYellow2" colspan="5">	
			<span id="LOAN_TYPE_NAME" ></span>
		</td>		
	</tr>
	<tr>
		<td class="tbYellow" >擔保品地址</td>
		<td class="tbYellow2" colspan="7">	
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<span id="GAGE_ADDR" style="font-family:'EUDC'"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >受理進度</td>
		<td class="tbYellow2">	
			<span id="PROCESS_NAME" ></span>
		</td>
		<td class="tbYellow" >送件日期</td>
		<td class="tbYellow2" colspan="5">	
			<span id="SEND_DATE" ></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" >案件指派人員</td>
		<td class="tbYellow2">	
			<%--[20240729] 修改件 陳勁谷 難字修改 --%>
			<span id="ASSIGN_EMP_NAME" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow" >案件指派時間</td>
		<td class="tbYellow2" colspan="5">	
			<span id="ASSIGN_TIME" ></span>
		</td>
	</tr>
	</table>
</form>
</body>
</html>