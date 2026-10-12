<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
 
<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA21400.jsp
作者：i9100621
功能：貸款限額試算作業
完成：2011/10/24
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">

<%--共用定義的css--%>
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<%--共用定義的javaScript--%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>

<%--自行定義的javaScript--%>
<script type="text/JavaScript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
var valid1;
var pattern_4 = "#,##0.####";	// 金額格式(小數4位)
function initApp(){
	
	PageUI.createPageWithAllBodySubElement("DSA21400" , "核貸作業" ,"貸款限額試算作業", 0);
	
	cleanMsgBoard();
	displayMessage();
	
	//buttonAuth();

	//TableUI的產生        
	new UI().init();     
	
	autoFormatToNumber();
	
	PageUI.resize(true);
	
}

function buttonAuth(){
	var authButtons = {

	};
	<dz:grantButtons FUNC_ID="DSA21400" ignored="true"/> 	
}

function UI(){

	var trialValues = {};//儲存查詢出的試算內容

	//數字欄位檢核
	var ValidNumberColumns = {
		AVG_PRICE : "每坪時價",
		LOAN_LIMIT : "放款率",
		LAND_SPACE : "地坪",
		LAND_SPACE : "建坪",
		BUILD_SPACE : "建坪",
		ANNOU_VALUE : "公告現值(坪)",
		TRANS_VALUE : "移轉現價(坪)",
		FLOOR : "樓層",
		RENT : "押金",
		BUILD_AGE : "屋齡"
	};

	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		
		new Ajax.Request( "<%=dispatcher%>/DSA2_1400/" + actionName,
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT, resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
		 		PageUI.resize(true);
	        }}
		);
	}     
	
	//查詢
	function doQuery(){
		valid1.reset();
		
		$('APPLY_ID').className='textBox2 chkAPPLY_ID validateAPPLY_ID';
		
		//B區不需檢核
		for(col in ValidNumberColumns){
			$(col).className =  $(col).className.replace("chkNumber","");
		}
		$('FINISH_DATE').className = $('FINISH_DATE').className.replace("chkROCDate","");
		$('TRANS_DATE').className = $('TRANS_DATE').className.replace("chkYM","");

		if(!valid1.validate()){
			return;
		}
		
		var params = { APPLY_ID:$F('APPLY_ID')};

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});
		
		//成功
		var successAction = function(resp){
			loadData.detailB(resp.rtnMap);
			loadData.detailC(resp.rtnMap);
		};
		
		//失敗
		var errorAction = function(resp){
			loadData.detailB({});
			loadData.detailC({});
		};

		ajaxPost( 'query', params, successAction, errorAction);	
	}
	
	
	//取得畫面試算條件內容
	function getValues(){
		var tmpValue = {};
		tmpValue.AVG_PRICE = $F('AVG_PRICE');
		tmpValue.LOAN_LIMIT = $F('LOAN_LIMIT');
		tmpValue.LAND_SPACE = $F('LAND_SPACE');
		tmpValue.BUILD_SPACE = $F('BUILD_SPACE');
		tmpValue.ANNOU_VALUE = $F('ANNOU_VALUE');
		tmpValue.TRANS_VALUE = $F('TRANS_VALUE');
		tmpValue.FLOOR = $F('FLOOR');
		tmpValue.RENT = $F('RENT');
		tmpValue.MATERIAL = $F('MATERIAL');
		tmpValue.MAIN_USE = $F('MAIN_USE');
		tmpValue.FINISH_DATE = $F('FINISH_DATE');
		tmpValue.BUILD_AGE = $F('BUILD_AGE');
		tmpValue.TRANS_DATE = $F('TRANS_DATE');	
		
		return tmpValue;
	}
	
	function changeCheck(){
		var currentValue = getValues();
		for( k in trialValues){
			if(trialValues[k] != currentValue[k]){
				return true;
			}
		}
		return false;
	}
	
	//試算
	function doTrial(){
		var isChange = changeCheck();
		var isConfirm = true;
		if(isChange){
			isConfirm = confirm('畫面資料已修正,請確認是否以畫面資料試算?');
		}
		
		if(!isConfirm){
			if($F('APPLY_ID')){alert('請重新查詢受理編號再試算!');}
			return;
		
		}else{
			//若畫面上輸入欄位有異動,”受理編號”欄位清空
			if(isChange){	$('APPLY_ID').value  = '';}
			
			valid1.reset();
			
			$('APPLY_ID').className='textBox2';
			
			//設定B區檢核
			for(col in ValidNumberColumns){
				appendVaildName(col,"chkNumber");
			}
			appendVaildName("FINISH_DATE","chkROCDate");
			appendVaildName("TRANS_DATE","chkYM");
	
			if(!valid1.validate()){
				return;
			}		
		
			var dataMap = $('form1').serialize( true );
			dataMap.FINISH_DATE = toY2K($F('FINISH_DATE'));
			dataMap.TRANS_DATE = toY2K($F('TRANS_DATE')+'01');
			var params = { info:Object.toJSON(dataMap)};
			
			//成功
			var successAction = function(resp){
				loadData.detailC(resp.rtnMap);
				//火險應保金額、火險單價清為0
				if(isChange){	
					$('FIREINSU_AMT').innerHTML  = '0萬';
					$('FIREINSU_PRICE').innerHTML  = '0元';
				}
			};
			
			//失敗
			var errorAction = function(resp){
				loadData.detailC({});				
			};
					
			ajaxPost( 'trial', params, successAction);
		}
	}		
	
	var loadData ={
		//載入B區資料
		detailB:function(rtnMap){

			$('AVG_PRICE').value =  CSRUtil.$fmt(rtnMap.AVG_PRICE ,pattern_4);
			$('LOAN_LIMIT').value = CSRUtil.$fmt(rtnMap.LOAN_LIMIT,pattern_4);
			$('LAND_SPACE').value = CSRUtil.$fmt(rtnMap.LAND_SPACE,pattern_4);
			$('BUILD_SPACE').value = CSRUtil.$fmt(rtnMap.BUILD_SPACE,pattern_4);
			$('ANNOU_VALUE').value = CSRUtil.$fmt(rtnMap.ANNOU_VALUE,pattern_4);
			$('TRANS_VALUE').value = CSRUtil.$fmt(rtnMap.TRANS_VALUE,pattern_4);
			$('FLOOR').value = rtnMap.FLOOR || '';
			$('RENT').value = CSRUtil.$fmt(rtnMap.RENT,pattern_4);
			$('MATERIAL').value = rtnMap.MATERIAL;
			$('MAIN_USE').value = rtnMap.MAIN_USE;
			$('FINISH_DATE').value = rtnMap.FINISH_DATE ? Date.toInputROC(rtnMap.FINISH_DATE ,''):'';
			$('BUILD_AGE').value = rtnMap.BUILD_AGE || '';
			
			TRANS_DATE = rtnMap.TRAN_DATE ? Date.toInputROC(rtnMap.TRAN_DATE ,''):'';
			if(TRANS_DATE!=''){
				TRANS_DATE = TRANS_DATE.substr(0,TRANS_DATE.length-2);
			}
			$('TRANS_DATE').value = TRANS_DATE;
			$('GAGE_ZIP').value = rtnMap.GAGE_ZIP || '';
			
			//取得畫面試算條件內容
			trialValues = getValues();

		},
		
		//載入C區資料
		detailC:function(rtnMap){
			var tmp = CSRUtil.$fmt(rtnMap.LAND_TAX,pattern_4);
			$('LAND_TAX').innerHTML = tmp!= ''?tmp+'元':'';
			
			tmp = CSRUtil.$fmt(rtnMap.LIMIT_AMT,pattern_4);
			$('LIMIT_AMT').innerHTML = tmp!= ''?tmp+'元':'';

			tmp = CSRUtil.$fmt(rtnMap.DEPRECIATION,pattern_4);
			$('DEPRECIATION').innerHTML = tmp!= ''?tmp+'元':'';
			
			tmp = CSRUtil.$fmt(rtnMap.REALVALUE_RATE,pattern_4);
			$('REALVALUE_RATE').innerHTML = tmp!= ''?tmp+'%':'';
			
			tmp = CSRUtil.$fmt(rtnMap.APPR_AMT,pattern_4);
			$('APPR_AMT').innerHTML = tmp!= ''?tmp+'元':'';
			
			tmp = CSRUtil.$fmt(rtnMap.APPR_REALVALUE,pattern_4);
			$('APPR_REALVALUE').innerHTML = tmp!= ''?tmp+'元':'';
			
			tmp = CSRUtil.$fmt(rtnMap.FIREINSU_AMT,pattern_4);
			$('FIREINSU_AMT').innerHTML = tmp!= ''?tmp+'萬':'';
			
			tmp = CSRUtil.$fmt(rtnMap.FIREINSU_PRICE,pattern_4);
			$('FIREINSU_PRICE').innerHTML = tmp!= ''?tmp+'元':'';	
		}	
	
	};
	 
	function initValidation(){
		valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
		Validation.addAllThese([
			[ 'chkAPPLY_ID',  '請輸入受理編號!', function(){ 
					if($F('APPLY_ID') == ""){ return false; } 
					$('APPLY_ID').value=$F('APPLY_ID').toUpperCase(); 
					return true;
				 } ] ,
			[ 'validateAPPLY_ID',  '受理編號需為11碼，請重新輸入!!', function(){
					if($F('APPLY_ID').length != 11){ return false; } 
					$('APPLY_ID').value=$F('APPLY_ID').toUpperCase();
					return true; 
				} ],

			[ 'chkNumber',  '必輸欄位，請輸入數字!',function(value){
				if(value==""){return false; }
				return !isNaN(value) && /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(value);
			}],
			
			[ 'chkROCDate',  '必輸欄位，請輸入民國日期!',function(value){
				return isROCdate(value);
			}],
			
			[ 'chkYM',  '必輸欄位，請輸入民國年月!',function(value){
				if(value==""){return false;}
				return isROCdate(value+"01");
			}]	
		]);

	}
	
	//在className加上要檢核的項目
	function appendVaildName(col,vaildName){
		var className = $(col).className;
		return $(col).className = className.indexOf(vaildName)==-1 ? className + (" "+vaildName):className;
	}
    
	return{                              
              
		init:function(){                                        

			initValidation();
			
			//查詢                    
			$('btn_query').observe('click',function(event){                                        
					doQuery();					
				}                        
			);
			
			//試算                    
			$('btn_trial').observe('click',function(event){                                        
					doTrial();					
				}                        
			);			

			//取保留參數管理的受理編號
			$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			if($('APPLY_ID').value){
				doQuery();
			}

		}                 
	}
}

<%--Define UI Class End--------------------------------------------------------%>-->
</script>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >


									<form id="form1" name="form1" method="post">	
									<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
										<tr>
											<td class="tbYellow" width="15%" >受理編號</td>
											<td class="tbYellow2" colSpan="5" width="85%">
												<input id="APPLY_ID" name="APPLY_ID" type="text" fieldName="受理編號" class="textBox2 chkAPPLY_ID validateAPPLY_ID" size="15" maxlength="11">
												<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
											</td>										
										</tr>
										<tr>
											<td colSpan="6" align="center">
												<input id="btn_trial" name="btn_trial" type="button" class="button" value="試算" />												
											</td>
										</tr>
										<tr>
											<td class="tbYellow" width="15%">每坪時價：</td>
											<td class="tbYellow2" width="20%">
												<input type="text" id="AVG_PRICE" name="AVG_PRICE" datatype="number" fieldName="每坪時價" class="textBox2 chkNumber" size=10>萬
											</td>											
											<td class="tbYellow" width="15%">放款率：</td>	
											<td class="tbYellow2" width="20%">
												<input type="text" id="LOAN_LIMIT" name="LOAN_LIMIT" datatype="number" fieldName="放款率" class="textBox2 chkNumber" size=6 maxlength=6>%
											</td>
											<td class="tbYellow" width="15%">土地增值稅：</td>
											<td class="tbYellow2" width="15%" align=right><span id="LAND_TAX"></span></td>													
										</tr>
										<tr>
											<td class="tbYellow" >地坪：</td>
											<td class="tbYellow2" >
												<input type="text" id="LAND_SPACE" name="LAND_SPACE" datatype="number" fieldName="地坪" class="textBox2 chkNumber" size=10>
											</td>											
											<td class="tbYellow" >建坪：</td>	
											<td class="tbYellow2" >
												<input type="text" id="BUILD_SPACE" name="BUILD_SPACE" datatype="number" fieldName="建坪" class="textBox2 chkNumber" size=10>
											</td>
											<td class="tbYellow" >放款值：</td>	
											<td class="tbYellow2" align=right><span id="LIMIT_AMT"></span></td>																																												
										</tr>		
										<tr>
											<td class="tbYellow" >公告現值(坪)：</td>
											<td class="tbYellow2" >
												<input type="text" id="ANNOU_VALUE" name="ANNOU_VALUE" datatype="number" fieldName="公告現值(坪)" class="textBox2 chkNumber" size=10>元
											</td>											
											<td class="tbYellow" >移轉現價(坪)：</td>	
											<td class="tbYellow2" >
												<input type="text" id="TRANS_VALUE" name="TRANS_VALUE" datatype="number" fieldName="移轉現價(坪)" class="textBox2 chkNumber" size=10>元
											</td>	
											<td class="tbYellow" >折舊：</td>
											<td class="tbYellow2" align=right><span id="DEPRECIATION"></span></td>																																													
										</tr>
										<tr>
											<td class="tbYellow" >樓層：</td>
											<td class="tbYellow2" >
												<input type="text" id="FLOOR" name="FLOOR" fieldName="樓層" class="textBox2 chkNumber" size=7 maxlength=5 >
											</td>											
											<td class="tbYellow" >押金：</td>	
											<td class="tbYellow2" >
												<input type="text" id="RENT" name="RENT" datatype="number" fieldName="押金" class="textBox2 chkNumber" size=10>
											</td>
											<td class="tbYellow" >淨值比：</td>	
											<td class="tbYellow2" align=right><span id="REALVALUE_RATE"></span></td>																																													
										</tr>
										<tr>
											<td class="tbYellow" >建築結構：</td>
											<td class="tbYellow2" >
												<select class="textBox2" name="MATERIAL" id="MATERIAL">								
					                              <c:forEach var="map" items="${MATERIAL_LIST}">
					                                <option value="${map.value}">${map.key}</option>
					                              </c:forEach>
					                            </select>
											</td>											
											<td class="tbYellow" >使用性質：</td>	
											<td class="tbYellow2" >
												<select class="textBox2" name="MAIN_USE" id="MAIN_USE">								
					                              <c:forEach var="map" items="${MAIN_USE_LIST}">
					                                <option value="${map.value}">${map.key}</option>
					                              </c:forEach>
					                            </select>
											</td>
											<td class="tbYellow" >鑑估總值：</td>
											<td class="tbYellow2" align=right><span id="APPR_AMT"></span></td>																																														
										</tr>
										<tr>
											<td class="tbYellow" >建築完成日：</td>
											<td class="tbYellow2" >
												<input type="text" id="FINISH_DATE" name="FINISH_DATE" fieldName="建築完成日" class="textBox2 chkROCDate" size=10 maxlength=7 >
											</td>											
											<td class="tbYellow" >屋齡：</td>	
											<td class="tbYellow2" >
												<input type="text" id="BUILD_AGE" name="BUILD_AGE" fieldName="屋齡" class="textBox2 chkNumber" size=10 maxlength=7 >
											</td>
											<td class="tbYellow" >判定時價：</td>	
											<td class="tbYellow2" align=right><span id="APPR_REALVALUE"></span></td>																																												
										</tr>
										<tr>
											<td class="tbYellow" >前次移轉年月：</td>
											<td class="tbYellow2" colspan=3>
												<input type="text" id="TRANS_DATE" name="TRANS_DATE" fieldName="前次移轉年月" class="textBox2 chkYM" size=7 maxlength=5 >
											</td>
											<td class="tbYellow" >火險應保金額：</td>
											<td class="tbYellow2" align=right><span id="FIREINSU_AMT"></span></td>											
											<input type="hidden" id="GAGE_ZIP" name="GAGE_ZIP" >																																												
										</tr>
										<tr>
											<td class="tbYellow2" colspan=4>&nbsp</td>	
											<td class="tbYellow" >火險單價：</td>	
											<td class="tbYellow2" align=right><span id="FIREINSU_PRICE"></span></td>																																												
										</tr>										
										<tr>
											<td class="tbYellow2" colspan="6">
											<font color="blue">
											1. 屋齡係以現在日期計算<br>
											2. 受理編號僅能作查詢用，本項作業試算依畫面資料及新制土增稅計算公式進行試算
											</font>
											</td>
										</tr>																																																																																																																	
									</table>
									</form>

							
</body>
<!-- InstanceEnd -->
</html>
