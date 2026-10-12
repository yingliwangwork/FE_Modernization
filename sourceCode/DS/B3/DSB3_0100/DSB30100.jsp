
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSB30100.jsp
作者：張智翔
功能：火險資料輸入及維護作業。
完成：2012/04/27
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

<script  language='javascript' type='text/javascript'>
if (typeof WebRootPath=='undefined') {
   var WebRootPath='/DSWeb/'; //【BGWeb】請依各子系統替換成自己的 Web
   var imeServer='https://mi.cathaylife.com.tw/wf/';
   var jscript = document.createElement('script');
   jscript.setAttribute('lang', 'text/javascript');
   jscript.setAttribute('src', '/DSWeb/hanlinks/wf_links.js'); //【BGWeb】請依各子系統替換成自己的 Web
   document.getElementsByTagName('head').item(0).appendChild(jscript);
}
</script>

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/RPTUtil.js'></script>
<script type='text/javascript'>

// 產生畫面物件
var DSB30100 = new DSB30100();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSB30100.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSB30100(){
	//檢核變數宣告
	var valid1;	
	var valid2;	
	var valid3;
    var valid4;	
	
	//前次查詢條件
	var lastQueryCondition;
	
	//門牌號碼下拉選單
	var ADDR_NO_LIST;
	
	var grid;
	//查詢資料的最新資訊
	var dataMapForNew;
	 //「建物內動產保額(萬元)」Radio清單 CONSTR_CODE_LIST
	var CONSTR_CODE_LIST = <c:out value = "${CONSTR_CODE_LIST}" default = "{}" escapeXml = "false" />;
	
	//--------------------------------------------------------------------------
	// 建立/關閉coverPage(不讓使用者在上載時做任何事)
	//--------------------------------------------------------------------------
	var auxiliary = {
		createCoverPage:function(){
			CSRUtil.createCoverPage('_frontCover');
			$('_frontCover').show();
		},
		closeCoverPage: function(){
			$('_frontCover').hide();
		}
	};
	
		//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0003:"btn_insert"<%--新增--%>,
				B0004:"btn_update"<%--修改--%>,			
				B0005:"btn_delete"<%--刪除--%>,			
				B0028:"btn_confirm"<%--確認--%>					
		};
		
		<dz:grantButtons FUNC_ID="DSB30100" ignored="false"/>
	}
	
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'validatequery4InOne',  '受理編號,借款人ID,貸款帳號,原貸帳號請至少輸入一欄再執行查詢作業', 
			//4個欄位要選一個輸入
			function(){				
				var bl_APPLY_ID = $("APPLY_ID_QUERY").value ==="";
				var bl_BORROW_ID = $("BORROW_ID_QUERY").value ==="";
				var bl_LOAN_ID = $("LOAN_ID_QUERY").value ==="";
				var bl_REFER_ID= $("REFER_ID_QUERY").value ==="";		
				return 	bl_APPLY_ID  && bl_BORROW_ID && bl_LOAN_ID && bl_REFER_ID ? false : true;				
			}],
			
			[ 'validateAPPLY_ID_QUERYLength',  '受理編號長度不正確 需為11碼', 
			//檢核受理編號長度
			function(v){
				if(v!==""){
					return v.length === 11 ? true : false;
				}
				return true;
			}],
			[ 'validateBORROW_ID_QUERYLength',  '借款人ID長度不正確 需為10碼', 
			//檢核借款人ID長度
			function(v){
				if(v!==""){
					return v.length === 10 ? true : false;
				}
				return true;
			}],
			[ 'validateLOAN_ID_QUERYLength',  '貸款帳號長度不正確 需為10碼', 
			//檢核貸款帳號長度
			function(v){
				if(v!==""){
					return v.length === 10 ? true : false;
				}
				return true;
			}],
			[ 'validateREFER_ID_QUERYLength',  '原貸帳號長度不正確 需為10碼', 
			//檢核原貸帳號長度
			function(v){
				if(v!==""){
					return v.length === 10 ? true : false;
				}
				return true;
			}],
			
			[ 'validateFIREINSU_KIND',  '請選擇投保公司!', 
			//投保公司檢核
			function(){				
				var FIREINSU_KIND = $('FIREINSU_KIND').value;
				var FIREINSU_COMPANY = $('FIREINSU_COMPANY').value;
				return FIREINSU_KIND ==="2" && (FIREINSU_COMPANY === "00" || FIREINSU_COMPANY ==="XX") ?  false : true ;
				
			}],
			
			[ 'validateFIREINSU_MM',  '請輸入0-12之間整數', 
			//1-12之間正整數
			function(){				
				var FIREINSU_MM = $('FIREINSU_MM').value;
				if(FIREINSU_MM!==""){
					return 	FIREINSU_MM >= 0 && FIREINSU_MM < 13  ? true : false ;	
				}
				return true;
			}],
			
			[ 'validateFIREINSU_POLNO',  '請輸入保單號碼!', 
			//檢核保單號碼
			function(v){				
				var FIREINSU_KIND = $('FIREINSU_KIND').value;
				var CASE = $('CASE').value;
				return (FIREINSU_KIND ==="2" || CASE!=="1") && v ==="" ? false : true;
			}],
			[ 'validateFIREINSU_POLNOLength',  '輸入保單號碼長度不合，請重新輸入!!' + '\n' +"註：中間請勿加 ' - ' !", 
			//檢核保單號碼長度
			function(v){				
				var FIREINSU_KIND = $('FIREINSU_KIND').value;
				var CASE = $('CASE').value;
				
				if(v!=="" && FIREINSU_KIND === "1" && (CASE ==="0" || CASE ==="2")){
					return v.length === 14 ? true : false;
				}
				return true;
			}],
			[ 'validateEarth',  '請輸入地震險保額!', 
			//檢核地震險保額
			function(v){								
				var CASE = $('CASE').value;
				return (CASE === "1" && v ==="") ? false : true;
				
			}],
			[ 'validateFIREINSU_BEGDT',  '請輸入火險起日!', 
			//檢核火險起日
			function(v){				
				var FIREINSU_KIND = $('FIREINSU_KIND').value;
				var CASE = $('CASE').value;
				return (FIREINSU_KIND ==="2" && CASE==="1") && v ==="" ? false : true;
			}],
			
			[ 'validateFIREINSU_KIND_COM',  '國泰件投保公司必須為國泰產險!', 
			//投保公司檢核要為產險a
			function(){				
				var FIREINSU_KIND = $('FIREINSU_KIND').value;
				var FIREINSU_COMPANY = $('FIREINSU_COMPANY').value;
				return FIREINSU_KIND ==="1" && FIREINSU_COMPANY !== "00" ?  false : true ;
				
			}],
			[ 'validateREINSU',  '複保險序號長度需為15碼', 
			//投保公司檢核要為產險
			function(v){				
				return v.length === 15 ? true : false;				
			}],	
			[ 'validateREINSU_AREA',  '複保險分支機構代碼長度需為2碼', 
			//投保公司檢核要為產險
			function(v){				
				return v.length === 2 ? true : false;				
			}]	
			
		]);
		//查詢用檢核
		valid1 = new Validation("fakeForm", { focusOnError:true, immediate:false });		
		valid1.define( "validatequery4InOne" , { id: "APPLY_ID_QUERY" } );	
		valid1.define( "validatequery4InOne" , { id: "BORROW_ID_QUERY", ignore : true} );	
		valid1.define( "validatequery4InOne" , { id: "LOAN_ID_QUERY", ignore : true} );	
		valid1.define( "validatequery4InOne" , { id: "REFER_ID_QUERY", ignore : true} );	
		valid1.define( "validateAPPLY_ID_QUERYLength" , { id: "APPLY_ID_QUERY" } );	
		valid1.define( "validateBORROW_ID_QUERYLength" , { id: "BORROW_ID_QUERY"} );	
		valid1.define( "validateLOAN_ID_QUERYLength" , { id: "LOAN_ID_QUERY"} );	
		valid1.define( "validateREFER_ID_QUERYLength" , { id: "REFER_ID_QUERY"} );	

		//新增用檢核	
		valid2 = new Validation("fakeForm", { focusOnError:true, immediate:false });	
		valid2.define( "validate-selection" , { id: "CASE" } );	
		valid2.define( "required" , { id: "FIREINSU_YY" } );		
		valid2.define( "required" , { id: "FIREINSU_MM" } );			
		valid2.define( "validateFIREINSU_MM" , { id: "FIREINSU_MM" } );	
		valid2.define( "validateFIREINSU_KIND" , { id: "FIREINSU_COMPANY" } );	
		valid2.define( "validateFIREINSU_KIND_COM" , { id: "FIREINSU_COMPANY" } );	
		valid2.define( "validateFIREINSU_POLNO" , { id: "FIREINSU_POLNO"} );		
		valid2.define( "validateFIREINSU_POLNOLength" , { id: "FIREINSU_POLNO"} );
		valid2.define( "required" , { id: "FIREINSU_AMT" } );
		valid2.define( "validateEarth" , { id: "EARTH_AMT" } );
		valid2.define( "validateFIREINSU_BEGDT" , { id: "FIREINSU_BEGDT" } );
		
		//修改用檢核	
		valid3 = new Validation("fakeForm", { focusOnError:true, immediate:false });	
		valid3.define( "required" , { id: "FIREINSU_AMT" } );
		valid3.define( "required" , { id: "EARTH_AMT" } );
		
		//確認用檢核	
		valid4 = new Validation("fakeForm", { focusOnError:true, immediate:false });	
		valid4.define( "required" , { id: "REINSU" } );
		valid4.define( "required" , { id: "REINSU_COMP" } );
		//valid4.define( "required" , { id: "REINSU_POLNO" }, { id : "REINSU_COMP" } );
		//valid4.define( "required" , { id: "REINSU_AREA" }, { id : "REINSU_COMP" } );
		valid4.define( "validateREINSU" , { id: "REINSU" } );	
		//valid4.define( "validateREINSU_AREA" , { id: "REINSU_AREA" }, { id : "REINSU_COMP" } );	
			
	}    

	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB3_0100/" + actionName,
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
		
		function ajaxPost2 ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSB3_0100/" + actionName,
				{  
					parameters: params,
					asynchronous: false,
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
		
		    $('APPLY_ID_QUERY').value = $('APPLY_ID_QUERY').value.toUpperCase();
		    $('BORROW_ID_QUERY').value = $('BORROW_ID_QUERY').value.toUpperCase();
		    $('LOAN_ID_QUERY').value = $('LOAN_ID_QUERY').value.toUpperCase();
		    $('REFER_ID_QUERY').value = $('REFER_ID_QUERY').value.toUpperCase();

		
			//先把下面資料清掉,因為dataMapForNew裡面不包含B區TABLE UI裡面的欄位
			
			valid2.reset();
			valid3.reset();
			valid4.reset();
			
			if(!valid1.validate()){
				return;			
			}
			
			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID_QUERY').value});

			var sendRecord = makeRecord();			
			
			lastQueryCondition = sendRecord;
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){
					var rtnList = resp.rtnList;
					grid.load(rtnList);	
					dataMapForNew = resp.rtnMap;					
					clearAreaC();
					ADDR_NO_LIST = resp.A050_LIST||[];
					
					$("E_POLICY").disabled = false;
					if(rtnList != null && rtnList[0].E_POLICY == '1'){
						 $("E_POLICY").checked = true;
					}

					if(dataMapForNew){//如果用Apply_id , LOAN_ID查,才會有 dataMapForNew
						inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
					}
				},
				function(resp){	
					//失敗把前次內容清掉 
					grid.load([]);	
					clearAreaC();
					$("E_POLICY").disabled = true;		
				}
			);		
		},
		
		//新增
		doInsert : function(event){		
			valid1.reset();
			valid3.reset();
			valid4.reset();		
			
			if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
				alert("請先查詢再執行新增作業");
				return;
			}
			
			var selectRecord = grid.getCheckedRecord();			
			//將畫面的輸入欄位存成Map 有選資料,APPLY_ID就用選的資料,不然用dataMapForNew
			var insertRecord =  CSRUtil.inputsToVo('form2',false);
			var A106_98;
			if(selectRecord.length >0){
				insertRecord.APPLY_ID = selectRecord[0].APPLY_ID;
				insertRecord.LOAN_ID = selectRecord[0].LOAN_ID;			
				A106_98 = selectRecord[0].A106_98;	
			}else if(dataMapForNew){
				insertRecord.APPLY_ID = dataMapForNew.APPLY_ID;
				insertRecord.LOAN_ID = dataMapForNew.LOAN_ID;
				A106_98 = dataMapForNew.A106_98;
			}else{
				alert("請先選取一筆資料再行新增!");
				return;
			}
			
			if(!valid2.validate()){
				return;			
			}
			
			if(insertRecord.CASE == '0' && insertRecord.FIREINSU_KIND == '1' ){
				if(!confirm('人工出單不會自動掛管理費，若要掛帳管費，需自行新增管理費用')){
					return;
				}
			}

			//var A106_98 = dataMapForNew.A106_98;
			if(A106_98 == '1' && $F('NOTE') == '1'){
				if(!confirm('核貸後補全通知有98(本案需出商業火單)，請確認是否仍要出住宅火險?')){
					return;
				}
			}else if(A106_98 == '0' && $F('NOTE') == '3'){
				if(!confirm('核貸後補全通知沒有98(本案需出商業火單)，請確認是否仍要出商業火險?')){
					return;
				}
			}
			
			//調整日期格式
			//insertRecord.FIREINSU_BEGDT = toY2K(insertRecord.FIREINSU_BEGDT );
			insertRecord.FIREINSU_BEGDT = insertRecord.FIREINSU_BEGDT ? toY2K(insertRecord.FIREINSU_BEGDT) : ""; 
			
			
			//這兩個value有可能被dsiabled,那 CSRUtil.inputsToVo會抓不到,因此再把他手動加上去
			insertRecord.FIREINSU_COMPANY = $('FIREINSU_COMPANY').value
			insertRecord.MATERIAL = $('MATERIAL').value
			insertRecord.E_POLICY = $('E_POLICY').checked ? "1" : "0";
		
			//發送ajax
			ajaxPost( 'insert' , 
				{
					dataMapForNew : Object.toJSON(dataMapForNew),
					sendRecord : Object.toJSON(lastQueryCondition),
					insertRecord : Object.toJSON(insertRecord)
				},
				function(resp){		
					//如果insertB有錯誤訊息			
					if(resp.errAlert){	
						//確認ok , 繼續執行
						if(!confirm(resp.tempErrMsg)){
							return;
						}
						var newRecord = resp.insertRecord||{};
						ajaxPost( 'insertA' , 
						{
							sendRecord : Object.toJSON(lastQueryCondition),
							insertRecord : Object.toJSON(newRecord)
						},
						function(respA){	
							loadResp = respA;
							grid.load(respA.rtnList);	
							dataMapForNew = respA.rtnMap;	
							ADDR_NO_LIST = respA.A050_LIST||[];
							clearAreaC();
							if(dataMapForNew){
								inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
							}
						});
					}else{					
						grid.load(resp.rtnList);	
						dataMapForNew = resp.rtnMap;
						ADDR_NO_LIST = resp.A050_LIST||[];	
						clearAreaC();
						if(dataMapForNew){
							inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
						}
					}
				}
			);		
		},
		
		//修改
		doUpdate : function(event){
		
			valid1.reset();
			valid2.reset();
			valid4.reset();	
			
			var selectRecord = grid.getCheckedRecord();			
			if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
				alert("請先查詢再執行修改作業");
				return;
			}else if(selectRecord.length ===0){
				alert("請先選擇一筆資料再執行修改作業");
				return;			
			}
			
			if(!valid3.validate()){
				return;			
			}		
			
			//新經手人ID
			var FIRE_AGENT_ID = $('FIRE_AGENT_ID').value;
			
			var AGENT_IS_CHANGE = "0";
			if($('CREDIT_YN').checked){			
				if(FIRE_AGENT_ID === ""){
					alert("如欲變更火險經手人，請輸入新火險經手人ID");
					return;			
				}else if(!confirm('確定要變更火險經手人為'+FIRE_AGENT_ID+'？')){
					return;				
				}
				AGENT_IS_CHANGE = "1";
			}
			
			//存成修改Map
			var updateRecord =  {
				APPLY_ID : selectRecord[0].APPLY_ID, //受理編號
				SEQ_NO : selectRecord[0].SEQ_NO, //序號
				LOAN_ID : selectRecord[0].LOAN_ID, //貸款帳號
				FIREINSU_AMT : $('FIREINSU_AMT').value, //火險保額
				EARTH_AMT :  $('EARTH_AMT').value, //火險保額
				AGENT_IS_CHANGE : AGENT_IS_CHANGE,//是否換經手
				NEW_AGENT_ID : $('FIRE_AGENT_ID').value,//經手人ID
				FIREINSU_YY : $('FIREINSU_YY').value,//年
				FIREINSU_MM : $('FIREINSU_MM').value,//月
				FIREINSU_BEGDT : $('FIREINSU_BEGDT').value, //火險起日
				NOTE : $('NOTE').value, //住火/商火 
				CASE : $('CASE').value,  
				FIREINSU_POLNO : $('FIREINSU_POLNO').value,
				E_POLICY : $('E_POLICY').checked ? "1" : "0"
			}			
		
			//發送ajax
			ajaxPost( 'update' , 
				{
					sendRecord : Object.toJSON(lastQueryCondition),
					updateRecord : Object.toJSON(updateRecord)
				},
				function(resp){						
					grid.load(resp.rtnList);	
					dataMapForNew = resp.rtnMap;
					ADDR_NO_LIST = resp.A050_LIST||[];	
					clearAreaC();
					if(dataMapForNew){
						inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
					}
				}
			);		
		
		},
		
		//刪除
		doDelete : function(event){
		
			valid1.reset();
			valid2.reset();
			valid3.reset();
			valid4.reset();	
			
			var selectRecord = grid.getCheckedRecord();			
			if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
				alert("請先查詢再執行刪除作業");
				return;
			}else if(selectRecord.length ===0){
				alert("請先選擇一筆資料再執行刪除作業");
				return;			
			}else if (!confirm('確定要刪除受理編號'+selectRecord[0].APPLY_ID+'？')){
				return;
			}
			
			//存成刪除Map
			var deleteRecord =  {
				APPLY_ID : selectRecord[0].APPLY_ID, //受理編號
				SEQ_NO : selectRecord[0].SEQ_NO, //序號
				LOAN_ID : selectRecord[0].LOAN_ID //貸款帳號
			}
			
			//發送ajax
			ajaxPost( 'delete' , 
				{
					sendRecord : Object.toJSON(lastQueryCondition),
					deleteRecord : Object.toJSON(deleteRecord)
				},
				function(resp){						
					grid.load(resp.rtnList);	
					dataMapForNew = resp.rtnMap;	
					ADDR_NO_LIST = resp.A050_LIST||[];	
					clearAreaC();
					if(dataMapForNew){
						inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
					}
				}
			);		
		
		},
		
		//確認
		doConfirm : function(event){
		
			valid1.reset();
			valid2.reset();
			valid3.reset();	
			valid4.reset();			
		
			var selectRecord = grid.getCheckedRecord();	
			var REINSU = $('REINSU').value;
			var REINSU_COMP = $('REINSU_COMP').value;
			var REINSU_POLNO = $('REINSU_POLNO').value;
			var REINSU_AREA = $('REINSU_AREA').value;
			//是否為行政中心人員
			var IS_ROLE = "0";
			//住火/商火 
			var NOTE = $('NOTE').value;
						
	/*
			if(!REINSU_COMP) {
				alert('請輸入複保險出單公司');
				return;
			}
			if (REINSU_COMP != "00" && REINSU_COMP != "99") {
				if(!valid4.validate()){
					return;
				}
			}*/
			
			
			if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
				alert("請先查詢再執行確認作業");
				return;
			}else if(selectRecord.length ===0){
				alert("請先選擇一筆資料再執行確認作業");
				return;		
		    }else if(NOTE == '1'){	
		    	if (!valid4.validate()) {
		    		return;		
		    	}
			//}else if(!valid4.validate() && NOTE == '1'){
			//	return;			
			}else{ 
				if(REINSU != '' && REINSU.substring(13,14) !=="0"){
					//發送ajax
					
					ajaxPost2( 'checkRoles' , {},
						function(resp){
							IS_ROLE = resp.IS_ROLE;
						}
					);
					if(!confirm("本建物己另有投保火險請慎重考慮是否要再出單？")){
						return;
					}
				}
				
				if(selectRecord[0].LOAN_ID.substring(9,10) == 'X' && $('SET_EXPENSE').checked ){ //如果貸款帳號是理財型(第10碼為X)，且同意掛帳管費(SET_EXPENSE)有勾選
					if (!confirm("理財型房貸如掛帳管費未繳，會自動滾入本金計息，是否仍要掛帳？")){
						return;
					} 
				}

				if (!confirm("是否已確認對保人ID與保險金額？")){
					return;			
				}
				if ($F('NOTE') == '3') {
					if (!confirm("商業火單將自動修改地震險保額為0，是否同意？")){
						return;			
					}
				}
			}
			
			//var A106_98 = dataMapForNew.A106_98;
			var A106_98_C = selectRecord[0].A106_98;	
			if(A106_98_C == '1' && $F('NOTE') == '1'){
				if(!confirm('核貸後補全通知有98(本案需出商業火單)，請確認是否仍要出住宅火險?')){
					return;
				}
			}else if(A106_98_C == '0' && $F('NOTE') == '3'){
				if(!confirm('核貸後補全通知沒有98(本案需出商業火單)，請確認是否仍要出商業火險?')){
					return;
				}
			}
			
			//存成確認Map
			var confirmRecord =  {
				APPLY_ID : selectRecord[0].APPLY_ID, //受理編號
				SEQ_NO : selectRecord[0].SEQ_NO, //序號
				LOAN_ID : selectRecord[0].LOAN_ID, //貸款帳號
				//出單確認資訊維護區塊存成B300Map
				GUARANTOR_ID : $('GUARANTOR_ID').value,
				OTHER_CODE : format.getRadioCheck($('OTHER_CODE')), //判斷是否有把checkbox打勾
				CONSTR_CODE : format.getCONSTR_CODE_Value(),
				SET_EXPENSE : format.getRadioCheck($('SET_EXPENSE')), 
				INSUFREE_CODE : selectRecord[0].INSUFREE_CODE, //是否為贈送件
				REINSU : REINSU,
				REINSU_COMP : $F('REINSU_COMP'), //複保險公司代碼
				//REINSU_COMP_NM : $F('REINSU_COMP_NM'), //複保險公司名稱
				REINSU_POLNO : $F('REINSU_POLNO'), //複保險保單號碼
				REINSU_AREA : $F('REINSU_AREA'), //複保險區域別
				IS_ROLE : IS_ROLE,  //是否為行政中心人員
				NOTE : $F('NOTE'), //住火/商火
				E_POLICY : $('E_POLICY').checked ? "1" : "0" //電子保單
			}			
			
			//發送ajax
			ajaxPost( 'confirm' , 
				{
					sendRecord : Object.toJSON(lastQueryCondition),
					confirmRecord : Object.toJSON(confirmRecord)
				},
				function(resp){						
					grid.load(resp.rtnList);	
					dataMapForNew = resp.rtnMap;	
					ADDR_NO_LIST = resp.A050_LIST||[];	
					clearAreaC();
					if(dataMapForNew){
						inputsByRcord(dataMapForNew,ADDR_NO_LIST);//載入C,D,E區
					}
				}
			);		
		},
		
		//複保險查詢
		doInsureq : function(event){
			var NOTE = $('NOTE').value;	
			
			if(NOTE == '3'){
				alert("商業火險無需取得複保險資訊");
				return;			
			}
				
			window.open('https://doubleinsurance.treif.org.tw/KR/K_R_NH_001.aspx');				
		},
		
		//資格查詢
		doCredit : function(event){
		
			valid1.reset();
			valid2.reset();
			valid3.reset();
			valid4.reset();
			
			var selectRecord = grid.getCheckedRecord();	
			var AGENT_ID = $('AGENT_ID_TXT').innerHTML;
			if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
				alert("請先查詢再執行資格查詢作業");
				return;
			}else if(AGENT_ID===""){
				alert("請先選擇一筆資料再執行查詢作業");
				return;			
			}
			
			//發送ajax
			ajaxPost( 'queryAgent' , 
				{ 
					AGENT_ID : AGENT_ID,
					<%-- [20240607] 難字調整 --%>
					AGENT_NAME : $('AGENT_NAME_TXT_VALUE').getValue()
				}
			);		
			
		},
		
		//清除
		doClear : function(event){			
			grid.load([]);
			clearAreaC();
		},
		
		//自動取得複保險資訊
		doGetREINSU: function() {
			if(!$('APPLY_ID_TXT').innerHTML) {
				alert('請先查詢');
				return;
			}
			
			var NOTE = $('NOTE').value;	
			
			var selectRecord = grid.getCheckedRecord();			
			if(selectRecord.length ===0){
				alert("請先選擇一筆資料再執行取得複保險序號作業");
				return;			
			}
			
			if(NOTE == '3'){
				alert("商業火險無需取得複保險資訊");
				return;			
			}		
			
			var B300Map = {
				SEQ_NO : $F('SEQ_NO'), //序號
				NOTE : $F('NOTE'), //住火/商火
				APPLY_ID : selectRecord[0].APPLY_ID,  //受理編號
				LOAN_ID : selectRecord[0].LOAN_ID	//貸款帳號
			}
			
			//發送ajax
			ajaxPost( 'getReinsu' , { B300Map : Object.toJSON(B300Map)},
				function(resp){	
					var B300Map = resp.B300Map;
					$('REINSU').value = B300Map.REINSU //顯示於E區重複序號欄位上，
					//var REINSU_COMP_NM = B300Map.REINSU_COMP_NM.toUpperCase()=='NULL' ? '' : B300Map.REINSU_COMP_NM;
					//$('REINSU_COMP_NM').value = REINSU_COMP_NM;
					//$('SP_REINSU_COMP_NM').update(REINSU_COMP_NM);
					$('REINSU_COMP').value = B300Map.REINSU_COMP;
					$('REINSU_POLNO').value = B300Map.REINSU_POLNO;
					$('REINSU_AREA').value = B300Map.REINSU_AREA;

				}
			);
		}
		//上傳
		,doUpload: function(event){				
				if(!$F('import_file')){
					alert('請選擇資料檔再執行上載!');
					return;
				}
				
				
				var selectRecord = grid.getCheckedRecord();
				if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
					alert("請先選取要出商火單的清單資料");
					return;
				}else if(selectRecord.length ===0){
					alert("請先選取要出商火單的清單資料");
					return;			
				}
				
				$('recData').value = Object.toJSON(selectRecord);
				auxiliary.createCoverPage();
				$('upLoadform').submit();
		}
		//上傳結束
		,importEnd: function(event){
			var filedata;
			filedata = window.importFrame.document.getElementById('filedata');
			if(!filedata){
				return;
			}
		
			var obj = filedata.innerHTML.evalJSON();
			
			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
			if(Msg){
				alert(Msg);
			}	
			
			if(CSRUtil.isSuccess(obj)){			
				$('FILE_NM_UPLOAD').update(obj.FILE_NM||[]);
				$('FILE_ID_UPLOAD').value = obj.FILE_ID||[];
				$('upLoadform').reset();
			}							
			auxiliary.closeCoverPage();
		}
		//刪除附件
		,deleteAttach: function(event){
		
				var selectedRecord = grid.getCheckedRecord();
				if(grid.getAllRecords().length ===0 && !dataMapForNew){//都兩邊都空,代表沒資料
					alert("請先選取要刪除附件的清單資料");
					return;
				}else if(selectedRecord.length ===0){
					alert("請先選取要刪除附件的清單資料");
					return;			
				}else if(!$F('FILE_ID_UPLOAD')){
					alert("請先選取要刪除附件的清單資料");
					return;			
				}
				
				if(!confirm('確定要刪除附件資料?')){
					return;
				}

				var B300Map = {};
				B300Map.FILE_ID1 = $F('FILE_ID_UPLOAD');
				
				//發送ajax
				ajaxPost( 'deleteAttach' , 
							{ selectedRecord : Object.toJSON(selectedRecord)
							  ,B300Map : Object.toJSON(B300Map)
							  ,sendRecord : Object.toJSON(lastQueryCondition)
							}
					,function(resp){	
						$('FILE_ID_UPLOAD').value = '';
						$('FILE_NM_UPLOAD').innerHTML = '';
						selectedRecord.FILE_NM = '';
					}
			);
		}
	};
	
	//觸發的動作
	var actions = {
			
		//重構InputFile欄位，避免輸入問題
		refactorInputCol : function(){
			var input = $("import_file");
			$("import_file").remove();
			parseEUDC('ap');
			$("import").insert(input);
		},
		
		//保單種類下拉選單連動投保公司,保單狀況 , 保單號碼
		doFIREINSU_KIND : function(event_value){	
			if( event_value ===  "1"){//國泰
				//連動投保公司
				$('FIREINSU_COMPANY').value = "00";//選國泰			
				$('FIREINSU_COMPANY').disable();
				//連動保單狀況
				$('CASE').value = "1";//選新件	
				actions.doCase($('CASE').value);
			}else {	//非國泰
				if(!event_value){	//如果傳進來沒值,就是dataMapForNew , 裡面並沒有FIREINSU_KIND , 因此選非國泰,公司選XX
					$('FIREINSU_KIND').value = "2";
					$('FIREINSU_COMPANY').value = "XX";
				}
				$('FIREINSU_COMPANY').enable();	
				$('FIREINSU_POLNO').readOnly = false;//只要是非國泰件,都可以改保單號碼	
				actions.doCase($('CASE').value);
			}		
		},
		
		//住火/商火下拉選單連動複保險
		doNOTE : function(event_value){	
			if( event_value ===  "1"){//住火
				$('REINSU_COMP').enable();	
				$('REINSU').readOnly = false;//只要是住火,都可以輸入複保險序號	
				$('REINSU_POLNO').readOnly = false;//只要是住火,都可以輸入出單公司
				$('REINSU_AREA').readOnly = false;//只要是住火,都可以輸入分支機構代碼	
				$('REINSU_COMP').enable();	
			}else {	//商火
				$('REINSU_COMP').value = "";//清空	
				$('REINSU_COMP').disable();	
				$('REINSU').value = "";//清空	
				$('REINSU').readOnly = true;
				$('REINSU_POLNO').value = "";//清空	
				$('REINSU_POLNO').readOnly = true;
				$('REINSU_AREA').value = "";//清空	
				$('REINSU_AREA').readOnly = true;
			}		
		},

		//保單狀況下拉選單連動
		doCase : function(value){
			var check;
			
			//先判斷是否有點一筆record	
			var originalDataMap ;
			var checkedRecord = grid.getCheckedRecord()[0];		
			if(checkedRecord){			//有點就用選取的record,不然用originalDataMap
				originalDataMap = checkedRecord;
			}else if(dataMapForNew){
				originalDataMap = dataMapForNew;
			}
			if(originalDataMap){//只更新連動到的輸格,建材,平方公尺 ,樓層起迄
				$('MATERIAL').value =  originalDataMap.MATERIAL ||'';
				$('BUILD_MEASURE').value =  originalDataMap.BUILD_MEASURE ||'';
				$('FLOOR').value =  originalDataMap.FLOOR ||'';
				$('FLOOR_BEGIN').value =  originalDataMap.FLOOR_BEGIN ||'';
				$('FLOOR_END').value =  originalDataMap.FLOOR_END ||'';		
			}	
			if(value ==="1" && $('FIREINSU_KIND').value ==="1"){//判斷是否為國泰件
				$('FIREINSU_POLNO').value = "";//清空	
				$('FIREINSU_POLNO').readOnly = true;				
			}else{
				$('FIREINSU_POLNO').readOnly = false;	
			}	
			check = value !=="3" ? true : false;//當為長年件,可以修改欄位
			
			$('MATERIAL').disabled = check;
			$('BUILD_MEASURE').readOnly = check;	
			$('FLOOR').readOnly = check;	
			$('FLOOR_BEGIN').readOnly = check;	
			$('FLOOR_END').readOnly = check;	
			
			//新件與續保件自動帶1年0月
			if(value=="1" || value=="2"){
				$('FIREINSU_YY').value = 1;	
				$('FIREINSU_MM').value = 0;	
				$('FIREINSU_YY').readOnly = true;	
				$('FIREINSU_MM').readOnly = true;	
			} else {
				$('FIREINSU_YY').value = '';	
				$('FIREINSU_MM').value = '';	
				$('FIREINSU_YY').readOnly = false;	
				$('FIREINSU_MM').readOnly = false;	
			}
			
			//20190906 資管三科-盧文華:火險新件出單，火險起日原鎖定當天，與產險IT確認火險出單日可大於當天小於2個月內，為避免火險斷保，故解除鎖定確認日期
			//新件火險起日清空,待確認時自動帶入當天日期
			/*if(value=="1"){
				$('FIREINSU_BEGDT').value = "";//清空	
				$('FIREINSU_BEGDT').disabled = true;	
			}else{
				$('FIREINSU_BEGDT').disabled = false;
			}*/
		},
		
		doADDR_NO : function(value){
			if(value){
				var data;
				for(var i=0;i<ADDR_NO_LIST.length;i++){
					if(value===(ADDR_NO_LIST[i].BUILD_NO1+ADDR_NO_LIST[i].BUILD_NO2)){
						data = ADDR_NO_LIST[i];
					}
				}
				
				$('MATERIAL').setValue(data.MATERIAL);
				$('BUILD_MEASURE').setValue(data.BUILD_MEASURE);
				$('FLOOR').setValue(data.FLOOR);
				$('FLOOR_BEGIN').setValue(data.FLOOR_BEGIN);
				$('FLOOR_END').setValue(data.FLOOR_END);
				$('FINISH_DATE').setValue(data.FINISH_DATE);
				$('BUILD_NO1').setValue(data.BUILD_NO1);
				$('BUILD_NO2').setValue(data.BUILD_NO2);
				$('ADDR_NO').setValue(data.ADDR_NO);
			}
		}
		
		//下載檔案
		,doDownLoad : function()  {
				RPTUtil.downloadFile( '${dispatcher}/DSB3_0100/download', {'FILE_ID': $F('FILE_ID_UPLOAD')});						
			}

		,doEPolicy : function(){	

			var reqMap = {
				APPLY_ID : $("APPLY_ID_TXT").innerHTML
			}

			if($("E_POLICY").checked){
				ajaxPost( 'getEmailOrPhone' , 
						{ reqMap : Object.toJSON(reqMap)}
				);
			}
		}
	};
	
	//各種資料的format method
	var format = {
		//依checkbox是否有勾選指定回傳值
		getRadioCheck : function(target){
			if(target.checked){
				return 1;
			}
			return 0;
		},
	
		//當為某值,checkbox讓他選取
		checkboxCheck :function (target , checkValue , compareValue){
			if(checkValue === compareValue){
				target.checked = true;
			}else{
				target.checked = false;
			}
		},
		
		//將日期轉為ROC
		dateformat : function (date){
			if(date){
				return Date.toInputROC(date || "","/");
			}
			return '';
		},
		
		//得到建物內動產保額(萬元)的值
		getCONSTR_CODE_Value : function(){
			var fun = $$('#CONSTR_CODE input[type = radio]');
			var returnValeu ='';
			fun.each(
				function(elem){					
					if(elem.checked){
						returnValeu = elem.value;
					}
				}
			)
			return returnValeu;
		},
		
		//判斷有沒有值 , 再轉換成金錢格式
		moneyToFormat : function(value){			
				return value ? MoneyFormat(value) : 0;
		}
	}
	
	//指定record將資料放入vo當中
	function inputsByRcord(inputRecord,A050_LIST){
		//門號下拉選單
		$('ADDR_NO_SELECT').childElements().each(function(id){
				id.remove();
			});
		$('ADDR_NO_SELECT').options.add(new Option('請選擇', ''));
		for(var i=0;i<A050_LIST.length;i++){
			var A050Map = A050_LIST[i];
			$('ADDR_NO_SELECT').options.add(new Option(A050Map.ADDR_NO, A050Map.BUILD_NO1+A050Map.BUILD_NO2));
		}
		//A050_LIST.size>1:下拉選單enable
		if(A050_LIST.length>1){
			$('ADDR_NO_SELECT').enable();
		}else{
			$('ADDR_NO_SELECT').disable();
		}
		
		
		//一開始 新火險經手人ID都是空的,先清空
		$('FIRE_AGENT_ID').value ="";
		$('CREDIT_YN').checked = false;
		CSRUtil.voToInputs('form2' , inputRecord);	
		
		<%-- [20240607] 難字調整 --%>
		var AGENT_NAME_TXT_VALUE = inputRecord.AGENT_NAME;
		if(AGENT_NAME_TXT_VALUE){
			$('AGENT_NAME_TXT_VALUE').setValue(AGENT_NAME_TXT_VALUE);
		}
		
		//原保單號碼改為顯示於span不顯示於input欄位
		$('FIREINSU_POLNO_OLD').value = "";//清空		
		
		//客制化各種資料
		//var FIREINSU_BEGDT = inputRecord.FIREINSU_BEGDT ;
		//$('FIREINSU_BEGDT').value = FIREINSU_BEGDT ? toROC(FIREINSU_BEGDT) : ""; 
		
		$('BORROW_NAME_TXT').innerHTML = format.moneyToFormat(inputRecord.BORROW_NAME_NEW);
		$('OWNER_NAME_TXT').innerHTML = format.moneyToFormat(inputRecord.OWNER_NAME_NEW);
	
		//金錢模式		
		$('FIREINSU_PAYMENT_TXT').innerHTML = format.moneyToFormat(inputRecord.FIREINSU_PAYMENT);
		$('EARTH_PAYMENT_TXT').innerHTML = format.moneyToFormat(inputRecord.EARTH_PAYMENT);
		
		$('FIREINSU_AMT').value = format.moneyToFormat(inputRecord.FIREINSU_AMT_FT);
		$('EARTH_AMT').value =  format.moneyToFormat(inputRecord.EARTH_AMT_FT);	
		$('AGREE_AMT_TXT').innerHTML =  format.moneyToFormat(inputRecord.AGREE_AMT);	
		$('REMAIN_AMT_FT_TXT').innerHTML =  format.moneyToFormat(inputRecord.REMAIN_AMT_FT);
		$('SUGGEST_AMT_FT_TXT').innerHTML =  format.moneyToFormat(inputRecord.SUGGEST_AMT_FT);	
		
		$('INPUT_DATE_TXT').innerHTML =  format.dateformat(inputRecord.INPUT_DATE);
		$('ISSUE_DATE_TXT').innerHTML =  format.dateformat(inputRecord.ISSUE_DATE);
		$('FILE_DATE_TXT').innerHTML =  format.dateformat(inputRecord.FILE_DATE);
		$('FIREINSU_ENDDT_TXT').innerHTML =  format.dateformat(inputRecord.FIREINSU_ENDDT);
		
		//判斷值來決定要不要把checkbox打勾
		format.checkboxCheck($('SET_EXPENSE') , inputRecord.SET_EXPENSE , '1');
		//如果rtnMap.SET_EXPENSE == “”，預設勾取
		/*
		if(inputRecord.SET_EXPENSE == ''){
			$('SET_EXPENSE').checked = true;
		}
		*/		

		format.checkboxCheck($('OTHER_CODE') , inputRecord.OTHER_CODE ,'1');	
		
		actions.doFIREINSU_KIND(inputRecord.FIREINSU_KIND);
		
		//由於選取新件時連動火險起日清空,若資料內有火險起日須在actions.doFIREINSU_KIND後寫入
		$('FIREINSU_BEGDT').value = inputRecord.FIREINSU_BEGDT ? toROC(inputRecord.FIREINSU_BEGDT) : ""; 
		
		//如資料內有符合 建物內動產保額(萬元),就把它選取
		var hide = $$('#CONSTR_CODE input[type = radio]');		
		hide.each(
			function(elem){
				if(elem.value === inputRecord.CONSTR_CODE){
					elem.checked = true;					
				}
			}
		)
		//如果rtnMap.CONSTR_CODE == “”，預設勾0
		if(inputRecord.CONSTR_CODE == ''){
			$('CONSTR_CODE_0').checked = true;
		}
		
		$('FILE_ID_UPLOAD').value = inputRecord.FILE_ID1||'';
		$('FILE_NM_UPLOAD').update(inputRecord.FILE_NM||'');

		if(inputRecord.E_POLICY == '1'){
			$('E_POLICY').checked = true;
		}
	}
	
	//將畫面查詢資料存成Record
	function makeRecord(){
		var sendRecord = {
			APPLY_ID	: $('APPLY_ID_QUERY').value ,// 受理編號
			BORROW_ID	: $('BORROW_ID_QUERY').value ,// 借款人ID
			LOAN_ID	: $('LOAN_ID_QUERY').value ,// 貸款帳號
			REFER_ID	: $('REFER_ID_QUERY').value // 原貸帳號			
		}
		return sendRecord;	
	}			
	
	
	//清空下方顯示區塊
	function clearAreaC(){
		$('form2').reset();
		var func = $$('#TableC span');
		func.each(
			function(elem){
				elem.innerHTML = "";
			}
		)
	}	
	
	
	//客制化tableUi的title
	function hideTitle(){
		$$("#grid th[name=BORROW_NAME]" , "#grid th[name=AGENT_NAME]").each(function(elem){ elem.rowSpan=2; });
		$$("#grid th[name=BORROW_ID_NEW]" , "#grid th[name=AGENT_ID]").each(function(elem){ elem.style.display='none'; });
	
	}
	
	//動態產生radio button
	function makeRadiobuttons(){			
		for(var key in CONSTR_CODE_LIST){	
			var link = new Element( "input" , {  type : "radio" , name : "CONSTR_CODE" , id : "CONSTR_CODE_" +key , value : key } ); 				
			$("CONSTR_CODE").appendChild(link);
			$("CONSTR_CODE").insert(CONSTR_CODE_LIST[key]);
		}	
	}

	
	return {

			initApp : function() {		
				PageUI.createPageWithAllBodySubElement("DSB30100", "火險作業", "火險資料輸入" , 2);			
				grid = new TableUI ( {
						table: $("grid"), pageSize: 10, allSortable:true , split: ['BORROW_ID_NEW'],		
						autoCheckBox:{						
							type :"radio" ,
							action: function(checkbox , boxStatus , records) {		
								//清掉不必要的欄位
								valid1.reset();								
								valid2.reset();
								valid3.reset();
								valid4.reset();
								
								inputsByRcord(records[0],ADDR_NO_LIST);
								$('SEQ_NO').value = records[0].SEQ_NO;
							}
						},
						<%-- [20240607] 難字調整 --%>
			            pageChange: function() {
			            	if ( "function" === typeof(parseEUDC) ) { actions.refactorInputCol(); }
			            },
						column:	[	
										
							<%-- [20240607] 難字調整 --%>
							{header: "借款人",key: "BORROW_NAME", attrs:{ style:"font-family:'EUDC'" }},						
							{header: "受理編號",key: "APPLY_ID"},
							<%-- [20240607] 難字調整 --%>
							{header: "經手人",key: "AGENT_NAME", attrs:{ style:"font-family:'EUDC'" }},											
							{header: "火險保額(萬元)",key: "FIREINSU_AMT_FT",
								render : function(rec , val){									
									return val ? MoneyFormat(val) : 0
								}							
							},
							{header: "火險保費(元)",key: "FIREINSU_PAYMENT",
								render : function(rec , val){
									return val ? MoneyFormat(val) : 0
								}					
							},
							{header: "火險起日",key: "FIREINSU_BEGDT",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							},	
							<%-- [20241224] 申請書-資管MIS統計表及火險系統優化作業：出單狀況如果是已退件或已註銷，在出單狀況下方顯示退件∕註銷日期  --%>
							{header: "出單狀況",key: "ISSUE_CODE_NM",attrs : { rowSpan : 2},
								render : function (rec , val){
									if (val && rec.ISSUE_CODE == '4') { //已註銷
										return val + '<br>' + (Date.toInputROC(rec.CANCEL_DATE || "","/"));
									} else if (val && rec.ISSUE_CODE == '9') { //已退件
										return val + '<br>' + (Date.toInputROC(rec.REJECT_DATE || "","/"));
									} else {
										return val;
									}
								}	
							},
							{header: "借款人ID",key: "BORROW_ID_NEW"},	
							{header: "貸款帳號",key: "LOAN_ID"},
							{header: "經手人ID",key: "AGENT_ID"},			
							{header: "地震保額(萬元)",key: "EARTH_AMT_FT",
								render : function(rec , val){
									return val ? MoneyFormat(val) : 0
								}					
							},
							{header: "地震保費(元)",key: "EARTH_PAYMENT",
								render : function(rec , val){
									return val ? MoneyFormat(val) : 0
								}					
							},
							{header: "火險迄日",key: "FIREINSU_ENDDT",
								render : function (rec , val){
									return Date.toInputROC(val || "","/");
								}							
							}
						]
					});		
					
				//處理Table UI title
				hideTitle();
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );				
				$("btn_insert").observe("click", buttons.doInsert);		
				$("btn_insureq").observe("click", buttons.doInsureq);
				$("btn_delete").observe("click", buttons.doDelete);		
				$("btn_update").observe("click", buttons.doUpdate);
				$("btn_confirm").observe("click", buttons.doConfirm);
				$("btn_clear").observe("click", buttons.doClear);
				$("btn_creditq").observe("click", buttons.doCredit);
				$("BTN_0158").observe("click", buttons.doGetREINSU);
				$('btn_upload').observe('click', buttons.doUpload);//上傳
				$('FILE_NM_UPLOAD').observe('click', actions.doDownLoad);//下載
				$('btn_delete_attach').observe('click', buttons.deleteAttach);//刪除附件
				$("E_POLICY").observe('click', actions.doEPolicy);

				//change事件				
				$("FIREINSU_KIND").observe("change", function(event){
					actions.doFIREINSU_KIND(event.target.value);
				});	
				$("CASE").observe("change", function(event){
					actions.doCase(event.target.value);
				});
				$("NOTE").observe("change", function(event){
					actions.doNOTE(event.target.value);
				});
				//load事件
				$('importFrame').observe('load', buttons.importEnd); //匯入結束
						
				//連動			
				$('ADDR_NO_SELECT').observe("change", function(event){
					actions.doADDR_NO(this.value);
				});	
				//加入radio 	
				makeRadiobuttons();
				
				initValidation();	
				
				fix();

				displayMessage();					
				
				buttonAuth();				
				autoFormatToNumber();	
				
				$('FIRE_AGENT_ID').observe('blur', function(event){			
					event.target.value = event.target.value.toUpperCase();
				});	
				$('FIREINSU_POLNO_OLD').observe('blur', function(event){			
					event.target.value = event.target.value.toUpperCase();
				});	
				$('FIREINSU_POLNO').observe('blur', function(event){			
					event.target.value = event.target.value.toUpperCase();
				});	
				$('REINSU_POLNO').observe('blur', function(event){			
					event.target.value = event.target.value.toUpperCase();
				});	
				
				//該欄位有值則清空其他3個欄位
				$('LOAN_ID_QUERY').observe('focus',function(){		
					
					$w('REFER_ID_QUERY BORROW_ID_QUERY APPLY_ID_QUERY').each(
					function(id){
							$(id).value ='';
						}
					);
					
				});	
				//該欄位有值則清空其他3個欄位
				$('BORROW_ID_QUERY').observe('focus',function(){		
					
					$w('REFER_ID_QUERY LOAN_ID_QUERY APPLY_ID_QUERY').each(
					function(id){
							$(id).value ='';
						}
					);
					
				});	
				//該欄位有值則清空其他3個欄位
				$('REFER_ID_QUERY').observe('focus',function(){		
					
					$w('LOAN_ID_QUERY BORROW_ID_QUERY APPLY_ID_QUERY').each(
					function(id){
							$(id).value ='';
						}
					);
					
				});	
				//該欄位有值則清空其他3個欄位
				$('APPLY_ID_QUERY').observe('focus',function(){		
					
					$w('REFER_ID_QUERY BORROW_ID_QUERY LOAN_ID_QUERY').each(
					function(id){
							$(id).value ='';
						}
					);
					
				});		

				//保留參數管理-取得受理編號
				if("${LINK_FORM}" != "DSH0_0100" && "${LINK_FORM}" != "DSM5_1300"){
					$('APPLY_ID_QUERY').value = CSRUtil.keepParamsManager.get('APPLY_ID');
				}
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="10%" align="left">
				受理編號
			</td>
			<td class="tbYellow2">
				<input id="APPLY_ID_QUERY" name="APPLY_ID_QUERY" type="text" size="12" maxlength = "11" class="text2" value = "${APPLY_ID}" />				
			</td>
			<td class="tbYellow" width="10%" align="left" >
				借款人ID
			</td>	
			<td class="tbYellow2">
				<input id="BORROW_ID_QUERY" name="BORROW_ID_QUERY" type="text" size="12" maxlength = "10" class="text2" />				
			</td>
			<td class="tbYellow2"  align = "center" rowspan="2">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>				
			</td>
		</tr>
		<tr>
			<td class="tbYellow" align="left">
				貸款帳號
			</td>
			<td class="tbYellow2">
				<input id="LOAN_ID_QUERY" name="LOAN_ID_QUERY" type="text" size="12" maxlength = "10" class="text2" />			
			</td>	
			<td class="tbYellow" align="left" >
				原貸帳號
			</td>
			<td class="tbYellow2">
				<input id="REFER_ID_QUERY" name="REFER_ID_QUERY" type="text" size="12" maxlength = "10" class="text2" />			
			</td>	
		</tr>
		</table>
	</form>	
	<form id="upLoadform" method="post" target="importFrame" enctype="multipart/form-data" 
		action="${dispatcher}/DSB3_0100/upload" style="PADDING: 0px; MARGIN: 0px;">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" align="left">
					要保書及KYC表
				</td>
				<td class="tbYellow2">
					<span id="import" field="FILE">
						<input id="import_file" name="import_file" fieldName="附件上載" type="file" size="40" class="button" />
					</span>
					<font color="red">商火出單確認前請先上傳</font>
					<iframe id="importFrame" name="importFrame" style="display:none"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>
				</td>	
			</tr>
			<tr>
				<td colspan = "2" align = "center">
					<input type="hidden" id="recData" name="recData">
					<input id = "btn_clear" type = "button" class = "button" value = "清除"/>		
					<input id = "btn_insert" type = "button" class = "button" value = "新增"/>		
					<input id = "btn_update" type = "button" class = "button" value = "修改"/>		
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"/>		
					<input id = "btn_confirm" type = "button" class = "button" value = "確認"/>
					<input id = "btn_upload" type="button" class="button" value="附件上傳" />
					<input id = "btn_delete_attach" type="button" class="button" value="附件刪除" />	
				</td>
			</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>	
	<form id="form2" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">	
		<table id  = "TableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">	
			<tr>
				<td class="tbYellow" width="12%" align="left">
					受理編號
				</td>
				<td class="tbYellow2" width ="22%">
					<span id="APPLY_ID_TXT" name="APPLY_ID_TXT"></span>
				</td>
				<td class="tbYellow" width="12%" align="left" >
					貸款帳號
				</td>	
				<td class="tbYellow2" width ="20%">
					<span id="LOAN_ID_TXT" name="LOAN_ID_TXT"></span>		
				</td>		
				<td class="tbBlue"  align = "center" colspan = "2">
					<b>擔保品資訊</b>			
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					受理單位
				</td>
				<td class="tbYellow2" width ="20%" colspan ="3">
					<span id="APPLY_DIV_NAME_TXT" name="APPLY_DIV_NAME_TXT"></span>		
				</td>					
				<td class="tbBlue" width = "18%">
					要保人(借款人)		
				</td>
				<td class="tbBlue2" id ="BORROW_NAME" name = "BORROW_NAME">
					<%-- [20240607] 難字調整 --%>
					<span id="BORROW_NAME_TXT" name="BORROW_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					貸款種類/類別
				</td>
				<td class="tbYellow2" width ="20%" >
					<span id="LOAN_KIND_NM_TXT" name="LOAN_KIND_NM_TXT"></span> / 
					<span id="LOAN_TYPE_NM_TXT" name="LOAN_TYPE_NM_TXT"></span>							
				</td>	
				<td class="tbYellow" width="10%" align="left">
					優惠種類
				</td>
				<td class="tbYellow2" width ="20%" >
					<span id="PREFER_TYPE_NM_TXT" name="PREFER_TYPE_NM_TXT"></span>		
				</td>					
				<td class="tbBlue" width = "15%">
					被保險人		
				</td>
				<td class="tbBlue2" >
				<%-- [20240607] 難字調整 --%>
					<span id="OWNER_NAME_TXT" name="OWNER_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					核准年期
				</td>
				<td class="tbYellow2" width ="20%">				
					<span id="LOAN_PERIOD_YY_TXT" name="LOAN_PERIOD_YY_TXT"></span> 年 		
					<span id="LOAN_PERIOD_MM_TXT" name="LOAN_PERIOD_MM_TXT"></span> 月 		
				</td>	
				<td class="tbYellow" width="10%" align="left">
					核准金額(萬元)
				</td>
				<td class="tbYellow2" width ="20%" >
					<span id="AGREE_AMT_TXT" name="AGREE_AMT_TXT"></span>		
				</td>					
				<td class="tbBlue" width = "15%">
					區域代碼	
				</td>
				<td class="tbBlue2">
					<span id="GAGE_ZIP_TXT" name="GAGE_ZIP_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					保單種類與狀況
				</td>
				<td class="tbYellow2" width ="20%">
					<select  id="FIREINSU_KIND" name = "FIREINSU_KIND" fieldName = "保單種類">			
						<c:forEach items="${FIREINSU_KIND_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>
					<select  id="CASE" name = "CASE" fieldName = "保單狀況">	
						<c:forEach items="${CASE_LIST}" var="row">
							<option value="${row.key}" <c:if test="${row.key == '1'}">selected </c:if>  />${row.value}</option>						
						</c:forEach>							
					</select>
				</td>	
				<td class="tbYellow" width="10%" align="left">
					投保公司
				</td>
				<td class="tbYellow2" width ="20%" >
					<select  id="FIREINSU_COMPANY" name = "FIREINSU_COMPANY" fieldName = "投保公司" disabled>		
						<c:forEach items="${FIREINSU_COMPANY_LIST}" var="row">
							<option value="${row.key}" />${row.value}</option>						
						</c:forEach>							
					</select>
				</td>					
				<td class="tbBlue" width = "15%">
					建築結構	
				</td>
				<td class="tbBlue2">
					<span id="MATERIAL_NM_TXT" name="MATERIAL_NM_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					原保單號碼
				</td>
				<td class="tbYellow2" width ="20%">
					<input id="FIREINSU_POLNO_OLD" name="FIREINSU_POLNO_OLD" type="text" size="16" class="text2" />
					<span id = "FIREINSU_POLNO_OLD_TXT" name = "FIREINSU_POLNO_OLD_TXT"></span>	
				</td>	
				<td class="tbYellow" width="10%" align="left">
					保單號碼
				</td>
				<td class="tbYellow2" width ="20%">
					<input id="FIREINSU_POLNO" name="FIREINSU_POLNO" type="text" size="16" class="text2" FieldName = "保單號碼" readOnly />	
					<span id = "FIREINSU_POLNO_TXT" name = "FIREINSU_POLNO_TXT"></span>
				</td>					
				<td class="tbBlue" width = "15%">
					平方公尺	
				</td>
				<td class="tbBlue2">
					<span id="BUILD_MEASURE_TXt" name="BUILD_MEASURE_TXt"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					房屋門牌號碼
				</td>
				<td class="tbYellow2" colspan="3">
					<select  id="ADDR_NO_SELECT" name = "ADDR_NO_SELECT" fieldName = "房屋門牌號碼">				
							<option value="">請選擇</option>
					</select>
					同一受理編號多主建物才需選擇
					<input id="FINISH_DATE" name="FINISH_DATE" type="hidden" />
					<input id="BUILD_NO1" name="BUILD_NO1" type="hidden" />
					<input id="BUILD_NO2" name="BUILD_NO2" type="hidden" />
					<input id="ADDR_NO" name="ADDR_NO" type="hidden" />
				</td>	
				<td class="tbBlue"  width = "15%">
					樓層	
				</td>
				<td class="tbBlue2">
					<span id="FLOOR_TXT" name="FLOOR_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					建材
				</td>
				<td class="tbYellow2" width ="20%">
					<select  id="MATERIAL" name = "MATERIAL" class ="notOne" fieldName = "建材" disabled>				
							<option value="">全部</option>
						<c:forEach items="${MATERIAL_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>
				</td>	
				<td class="tbYellow" width="10%" align="left">
					平方公尺
				</td>
				<td class="tbYellow2" width ="20%">
					<input id="BUILD_MEASURE" name="BUILD_MEASURE" type="text" size="16" class="text2 notOne" />	
				</td>					
				
				<td class="tbBlue" width = "15%">
					樓層起迄	
				</td>
				<td class="tbBlue2" >
					起 <span id="FLOOR_BEGIN_TXT" name="FLOOR_BEGIN_TXT"></span> - 
					迄 <span id="FLOOR_END_TXT" name="FLOOR_END_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					樓層
				</td>
				<td class="tbYellow2" width ="20%">
					<input id="FLOOR" name="FLOOR" type="text" size="4" class="text2 notOne" />	
				</td>	
				<td class="tbYellow" width="10%" align="left">
					樓層起迄
				</td>
				<td class="tbYellow2" width ="20%">
					第
					<input id="FLOOR_BEGIN" name="FLOOR_BEGIN" type="text" size="4"  maxlength = "3" class="text2 notOne" />樓起~
					第
					<input id="FLOOR_END" name="FLOOR_END" type="text" size="4" maxlength = "3" class="text2 notOne" />樓迄
				</td>					
				
				<td class="tbBlue" width = "15%">
					保險標的
				</td>
				<td class="tbBlue2">
					<%-- [20240607] 難字調整 --%>
					<span id="GAGE_ADDR_TXT" name="GAGE_ADDR_TXT" style="font-family:'EUDC'"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險年期
				</td>
				<td class="tbYellow2" width ="20%">			
					<input id="FIREINSU_YY" name="FIREINSU_YY" type="text" size="4" maxlength = "3" class="text2" datatype ="number" FieldName = "火險年期(年)"/>
					年
					<input id="FIREINSU_MM" name="FIREINSU_MM" type="text" size="4" maxlength = "3" class="text2" datatype ="number" FieldName = "火險年期(月)"/>
					月				
				</td>	
				<td class="tbYellow" width="10%" align="left">
					出單狀況
				</td>
				<td class="tbYellow2" width ="20%">
					<span id="ISSUE_CODE_NM_TXT" name="ISSUE_CODE_NM_TXT"></span>
				</td>					
				
				<td class="tbBlue" width = "15%">
					貸放餘額(萬元)
				</td>
				<td class="tbBlue2">
					<span id="REMAIN_AMT_FT_TXT" name="REMAIN_AMT_FT_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險保額
				</td>
				<td class="tbYellow2" width ="20%">			
					<input id="FIREINSU_AMT" name="FIREINSU_AMT" type="text" size="10" class="text2" fieldName = "火險保額" datatype = "number"/>萬元							
				</td>	
				<td class="tbYellow" width="10%" align="left">
					地震險保額
				</td>
				<td class="tbYellow2" width ="20%">			
					<input id="EARTH_AMT" name="EARTH_AMT" type="text" size="10" class="text2" fieldName = "地震險保額" datatype = "number"//>萬元							
				</td>					
				
				<td class="tbBlue"  width = "15%">
					試算保額(萬元)
				</td>
				<td class="tbBlue2">
					<span id="SUGGEST_AMT_FT_TXT" name="SUGGEST_AMT_FT_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險保費
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="FIREINSU_PAYMENT_TXT" name="FIREINSU_PAYMENT_TXT"></span>					
				</td>	
				<td class="tbYellow" width="10%" align="left">
					地震保額費
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="EARTH_PAYMENT_TXT" name="EARTH_PAYMENT_TXT"></span>			
				</td>					
				
				<td class="tbBlue" width = "15%">
					原貸款資料是否贈送火險
				</td>
				<td class="tbBlue2">
					<span id="A130_INSUFREE_CODE_NM_TXT" name="A130_INSUFREE_CODE_NM_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					是否贈送火險
				</td>
				<td class="tbYellow2" width ="20%">			
					<select  id="INSUFREE_CODE" name = "INSUFREE_CODE" fieldName = "是否贈送火險">	
						<c:forEach items="${INSUFREE_CODE_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>			
				</td>	
				<td class="tbYellow" width="10%" align="left">
					使用用途
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="REAL_USE_TXT" name="REAL_USE_TXT"></span>			
				</td>					
				
				<td class="tbBlue" width = "15%">
					最後有效投保是否贈送火險
				</td>
				<td class="tbBlue2">
					<span id="LSFREE_INSU_NM_TXT" name="LSFREE_INSU_NM_TXT"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險起日
				</td>
				<td class="tbYellow2" width ="20%">			
					<input name="FIREINSU_BEGDT" id='FIREINSU_BEGDT' type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate" fieldName = "火險起日">
					<img id="calImg1" src="<%=imageBase%>/CM/calendar.gif" class = "date1" alt="Date" onclick="getCalendarFor($('FIREINSU_BEGDT'))">	
				</td>	
				<td class="tbYellow" width="10%" align="left">
					火險迄日
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="FIREINSU_ENDDT_TXT" name="FIREINSU_ENDDT_TXT"></span>			
				</td>					
				
				<td class="tbBlue" width = "15%" align = "center" colspan = "2">
					<b>出單確認資訊維護</b>
					<input id = "btn_insureq" type = "button" class = "button" value = "複保險查詢"/>			
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left" rowspan = "2">
					經手人員
				</td>
				<td class="tbYellow2" width ="20%" rowspan = "2">			
					<span id="AGENT_ID_TXT" name="AGENT_ID_TXT"></span><br>
					<%-- [20240607] 難字調整 --%>
					<span id="AGENT_NAME_TXT" name="AGENT_NAME_TXT" style="font-family:'EUDC'"></span><br>
					<input type="hidden" id="AGENT_NAME_TXT_VALUE">
					<span id="AGENT_DEPT_TXT" name="AGENT_DEPT_TXT"></span><br>
				</td>	
				<td class="tbYellow" width="10%" align="left" rowspan = "2">
					承辦人員
				</td>
				<td class="tbYellow2" width ="20%" rowspan = "2">			
					<span id="CRED_ID_TXT" name="CRED_ID_TXT"></span><br>
					<%-- [20240607] 難字調整 --%>
					<span id="CRED_NAME_TXT" name="CRED_NAME_TXT" style="font-family:'EUDC'"></span><br>
					<span id="CRED_DEPT_TXT" name="CRED_DEPT_TXT"></span><br>
				</td>					
				
				<td class="tbBlue" width = "15%" >
					對保人ID
				</td>
				<td class="tbBlue2">
					<input id="GUARANTOR_ID" name="GUARANTOR_ID" type="text" size="12" class="text2" />				
				</td>			
			</tr>
			<tr>
				
				<td class="tbBlue" width = "15%">
					第三責任險
				</td>
				<td class="tbBlue2">
					<input id = "OTHER_CODE" type = "checkbox" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					變更火險經手人
				</td>
				<td class="tbYellow2" width ="20%">			
					<input id = "btn_creditq" type = "button" class = "button" value = "資格查詢"/>	
					<input id = "CREDIT_YN" type = "checkbox" />是否要變更？
				</td>	
				<td class="tbYellow" width="10%" align="left">
					新火險經手人ID
				</td>
				<td class="tbYellow2" width ="20%">			
					<input id="FIRE_AGENT_ID" name="FIRE_AGENT_ID" type="text" size="10" class="text2" />		
				</td>					
				
								
				<td class="tbBlue" width = "15%">
					建物內動產保額(萬元)
				</td>
				<td class="tbBlue2" id = "CONSTR_CODE" >
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險資料輸入人員
				</td>
				<td class="tbYellow2" width ="20%">
					<%-- [20240607] 難字調整 --%>			
					<span id="INPUT_NAME_TXT" name="INPUT_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>	
				<td class="tbYellow" width="10%" align="left">
					火險資料輸入日期
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="INPUT_DATE_TXT" name="INPUT_DATE_TXT"></span>
				</td>	
				<td class="tbBlue" width = "15%">
					同意掛帳管費
				</td>
				<td class="tbBlue2">
					<input id = "SET_EXPENSE" type = "checkbox" />
				</td>
				
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險出單確認人員
				</td>
				<td class="tbYellow2" width ="20%">			
					<%-- [20240607] 難字調整 --%>
					<span id="ISSUE_NAME_TXT" name="ISSUE_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>	
				<td class="tbYellow" width="10%" align="left">
					火險出單確認日期
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="ISSUE_DATE_TXT" name="ISSUE_DATE_TXT"></span>
				</td>					
				
				<td class="tbBlue" rowspan = "2">
					<input id="BTN_0158" type = "button" class = "button" value = "自動取得複保險資訊" /><br>
						複保險序號<BR>出單公司<BR>保單號碼<BR>分支機構代碼
						<!-- <input id="REINSU_COMP_NM" name="REINSU_COMP_NM" type="hidden" />
						<input id="REINSU_COMP" name="REINSU_COMP" type="hidden" />
						<input id="REINSU_POLNO" name="REINSU_POLNO" type="hidden" />
						<input id="REINSU_AREA" name="REINSU_AREA" type="hidden" />-->
						<input id="SEQ_NO" name="SEQ_NO" type="hidden" />
				</td>
				<td class="tbBlue2" rowspan = "2">
					<input id="REINSU" name="REINSU" type="text" size="18" fieldName = "複保險序號" clas99s="text2" /><br>
					<!--  <span id="SP_REINSU_COMP_NM"></span>-->
					<select  id="REINSU_COMP" name = "REINSU_COMP" fieldName = "複保險出單公司" >
					    <option value=''>請選擇</option>		
						<c:forEach items="${REINSU_COMP_LIST}" var="row">
							<option value="${row.key}" />${row.value}</option>						
						</c:forEach>							
					</select><br>
					<input id="REINSU_POLNO" name="REINSU_POLNO" type="text" size="11" maxlength = "10" fieldName = "複保險保單號碼" clas99s="text2" /><br>
					<input id="REINSU_AREA" name="REINSU_AREA" type="text" size="3" maxlength = "2" fieldName = "複保險分支機構代碼  " clas99s="text2" /><br>
				</td>				
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					火險歸檔確認人員
				</td>
				<td class="tbYellow2" width ="20%">			
					<%-- [20240607] 難字調整 --%>
					<span id="FILE_NAME_TXT" name="FILE_NAME_TXT" style="font-family:'EUDC'"></span>
				</td>	
				<td class="tbYellow" width="10%" align="left">
					火險歸檔確認日期
				</td>
				<td class="tbYellow2" width ="20%">			
					<span id="FILE_DATE_TXT" name="FILE_DATE_TXT"></span>
				</td>					
			</tr>
			<tr>
				<td class="tbYellow" width="10%" align="left">
					要保書及KYC表
				</td>
				<td class="tbYellow2">
					<input type="hidden" id="FILE_ID_UPLOAD" name="FILE_ID_UPLOAD" />
					<a id="FILE_NM_UPLOAD" href="#"></a>

				</td>

				<td class="tbYellow" width="10%" align="left">
					電子保單
				</td>
				<td class="tbYellow2">
					<input type="checkbox" id="E_POLICY" name="E_POLICY" disabled/>
				</td>

				<td class="tbBlue" >
					住火/商火
				</td>
				<td class="tbBlue2">			
					<select id="NOTE" name="NOTE">
						<c:forEach var="map" items="${NOTE_LIST}">
								<option value="${map.key}" 
									<c:if test="${map.key eq NOTE}">selected</c:if>>
									${map.value}
								</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
	</form>	
	<form id ="fakeForm">
	</form>
</body>
</html>