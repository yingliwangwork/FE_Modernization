<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>

<!--
程式：DSA32103.jsp
作者：簡睿甫
功能：初估申請輸入
完成：
[20240930]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>         <%-- 判斷BUTTON用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

Event.observe(window, 'load', new DSA32103().initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA32103(){
	var PREAPPR_NO = '${PREAPPR_NO}';
	var LOAN_ID = '<c:out value="${LOAN_ID}" default="" escapeXml="false" />';
	var sourceChoose = '<c:out value="${sourceChoose}" default="" escapeXml="false" />';
	var A280VO = <c:out value="${A280VO}" default="[]" escapeXml="false" />;
	
	var TOWN_LIST = <c:out value="${TOWN_LIST}" default="[]" escapeXml="false" />;
	
	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSA3_2103/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
	
	var button = {
		// 暫存
		doSave: function(){
			// 清空檢核
			validates.clear();
			
			validates.checkSaveOnly();
			// 暫存、結案、結案案件變更檢核
			validates.checkSaveInput();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var newA280VO =  CSRUtil.inputsToVo( form, false);
			newA280VO.AREA_CODE = $F('AREA_CODE');
			ajaxPostIM( 'save' ,  {Form: Object.toJSON(newA280VO), PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	
					A280VO = resp.A280VO;
					action.initAction(A280VO);
					parent.DSA32100.isDSA32103Next = true;
				}				
			);
		}, 
		
		// 結案
		doClose: function(){
			// 清空檢核
			validates.clear();
			// 暫存、結案、結案案件變更檢核
			validates.checkSaveInput();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var newA280VO =  CSRUtil.inputsToVo( form, false);
			ajaxPostIM( 'close' ,  {Form: Object.toJSON(newA280VO), PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	
					A280VO = resp.A280VO;
					action.initAction(A280VO);
					parent.DSA32100.isDSA32103Next = true;
				}				
			);
		}, 
		
		// 列印
		doPrint: function(){
			// 清空檢核
			validates.clear();
			// 列印、刪除檢核
			validates.checkPrintInput();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			ajaxPostIM( 'check' ,  {PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	
					popupWin.windowOpen('<%=dispatcher%>/DSA3_2103/print',{
						'parameters': {'PREAPPR_NO': $F('PREAPPR_NO'),'sourceChoose':sourceChoose,'LOAN_ID':LOAN_ID},
						'fullScreen': false,
						'attributes': {'resizable': 'yes'}
					});
					//window.open('<%=dispatcher%>/DSA3_2103/print?PREAPPR_NO='+$F('PREAPPR_NO')+'&sourceChoose='+sourceChoose+'&LOAN_ID='+LOAN_ID,'_blank', "top=50, left=50, toolbar=yes, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=1024, height=768");
				}				
			);
		}, 
		
		// 結案案件變更
		doChange: function(){
			// 清空檢核
			validates.clear();
			// 暫存、結案、結案案件變更檢核
			validates.checkSaveInput();			
			
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var newA280VO =  CSRUtil.inputsToVo( form, false);
			ajaxPostIM( 'change' ,  {Form: Object.toJSON(newA280VO), PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	
					A280VO = resp.A280VO;
					action.initAction(A280VO);
					parent.DSA32100.isDSA32103Next = true;
				}				
			);
		}, 
		
		// 刪除
		doDelete: function(){
			// 清空檢核
			validates.clear();
			// 列印、刪除檢核
			validates.checkPrintInput();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var newA280VO =  CSRUtil.inputsToVo( form, false);
			ajaxPostIM( 'delete' ,  {Form: Object.toJSON(newA280VO), PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	

					/*A280VO = resp.A280VO;
					action.initAction(A280VO);
					parent.DSA32100.isDSA32103Next = true;*/
					parent.DSA32100.afterDSA32103Delete();
				}				
			);
		},
		
		// 計算
		doCalculate:  function(){
			// 清空檢核
			validates.clear();
			// 計算檢核
			validates.checkCalculateInput();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			var calMap =  new Hash();
			calMap.set('BUILD_MEASURE', $('BUILD_MEASURE').getValue());
			calMap.set('PER_PRICE', $('PER_PRICE').getValue());
			calMap.set('LIMIT_RATE', $('LIMIT_RATE_C').getValue());
			calMap.set('PREAPPR_NO', $('PREAPPR_NO').getValue());
			calMap.set('AREA_CODE', $F('AREA_CODE'));

			ajaxPostIM( 'calculate' ,  {calMap: Object.toJSON(calMap), PREAPPR_NO: $F('PREAPPR_NO')}, 
				function(resp){	
					A280VO = resp.A280VO;
					$('A280VO').value =  Object.toJSON(A280VO);
					$('TOTAL_PRICE').value = A280VO['TOTAL_PRICE'] ? CSRUtil.$fmt(A280VO['TOTAL_PRICE'], action.pattern) : '0';
					parent.DSA32100.isDSA32103Next = true;
				}				
			);
		}
	};
	
	var action = {
		<%--[20240930]初始畫面--%>
		initPage: function(){
			if('${PREAPPR_NO}' == ''){
				return;
			}
			ajaxPostIM( 'initQuery',  {PREAPPR_NO: '${PREAPPR_NO}'}, 
				function(resp){	
					A280VO = resp.A280VO || {};				
					$('A280VO').value = Object.toJSON(A280VO);
					action.initAction(A280VO);
				}				
			);
		},
		// 初始畫面設值
		initAction:　function(A280VO) {
			$('A280VO').value =  Object.toJSON(A280VO);
			$('PREAPPR_NO_TD').update(PREAPPR_NO);
			$('PREAPPR_NO').value = PREAPPR_NO;
			if(A280VO) {
				CSRUtil.voToInputs(form, A280VO);
				
				$('BUILD_MEASURE_C').value = action.formatValue('${BUILD_MEASURE}');
				$('BORROW_NAME_TD').update(A280VO['BORROW_NAME'] ? CSRUtil.maskHandler.getMaskName(A280VO['BORROW_NAME']) : '');
				$('BORROW_ID_TD').update(A280VO['BORROW_ID'] ? CSRUtil.maskHandler.getMaskID(A280VO['BORROW_ID']) : '');
				
				$('APPLY_AMT_TD').update($F('APPLY_AMT') ? action.formatValue($F('APPLY_AMT'))+'萬' : '');
				$('PREAPPR_ZIP_TD').update(A280VO['PREAPPR_ZIP']);
				var LAND_MEASURE = "${LAND_MEASURE}" ? "土地${LAND_MEASURE}坪" : "";
				var BUILD_MEASURE = "${BUILD_MEASURE}" ? " 建物${BUILD_MEASURE}坪" : "";
				var PF_MEASURE = "${PF_MEASURE}" ? " (含公設${PF_MEASURE}坪)" : "";
				$('MEASURE').update( LAND_MEASURE+BUILD_MEASURE+PF_MEASURE );
				$('AGENT_DATE').value = getY2KToday();
				$('AGENT_DATE_VIEW').innerHTML = Date.toROC(getY2KToday());
				
				$('AREA_CODE').value = A280VO['AREA_CODE'];
				
			}
		},

		// 數字欄位格式
		pattern : '#,###.####',  
		
		// 數字欄位處理(三位一撇)
		formatValue : function(value) {
			return value ? CSRUtil.$fmt(value, action.pattern) : '';
			
		},
		
		//區域連動 公司放款區域成數
		changeAREA_CODE : function(event){
			var value = event.target.value;
			
			var MAIN_USE_check = $$('#MAIN_USE_LIST input:checked[type = radio]')[0];
			var	MAIN_USE;	
			if(MAIN_USE_check){
				MAIN_USE = MAIN_USE_check.value
			}
		
			if(value){
				ajaxPostIM( 'changeAREA_CODE' ,  {AREA_CODE: $F('AREA_CODE') , MAIN_USE : MAIN_USE}, 
					function(resp){
						$('LIMIT_RATE').value = resp.LIMIT_RATE;
						$('LIMIT_RATE_C').value = resp.LIMIT_RATE;		
						button.doCalculate();			
					}				
				);			
			}else{
				$('LIMIT_RATE_C').value = '';	
				$('LIMIT_RATE').value = '';
			}		
		}
	};
	
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 申請日期需不可小於今日
				['after-today', '申請日期需不可小於今日',
					function( v,ele,info ) {
						if(v &&　diffDayROC( v, '${SYS_ROC_DATE}' ) <= 0　) {
							return true;
						} else {
							return false;
						}
					}
				],
				
				// 建物坪數,輸入均價,放款成數為必輸欄位,且需為>0之數字
				['reqiured-and-positive-number', '請輸入正確',
					function( v,ele,info ) {
						var value = ele.getValue();
						if( value && value > 0) {
							return true;
						}
						
						return false;
					}
				],
				
				// 郵遞區號為必輸欄位
				['TD_required', '請輸入郵遞區號',
					function( v,ele,info ) {
						if( ele.innerHTML ) {
							return true;
						} else {
							return false;
						}
					}
				],
				
				// 初估編號為必輸欄位
				['TD1_required', '請先輸入基本資料',
					function( v,ele,info ) {
						if( ele.innerHTML ) {
							return true;
						} else {
							return false;
						}
					}
				]
			] );
		}, 
		
		clear: function() {
			// 清空檢核標記
			validates.valid.reset();
			// 清空檢核設定
			validates.valid.clear();
		},
		
		// 計算檢核
		checkCalculateInput: function(){
			validates.valid.define('reqiured-and-positive-number', {id:'BUILD_MEASURE_C', errMsg:"請輸入正確建物坪數"});
			validates.valid.define('reqiured-and-positive-number', {id:'PER_PRICE', errMsg:"請輸入正確平均單價(萬)"});
			validates.valid.define('reqiured-and-positive-number', {id:'LIMIT_RATE_C', errMsg:"請輸入正確放款成數"});
		},
		
		// 暫存、結案、結案案件變更檢核
		checkSaveInput: function(){
			validates.valid.define('reqiured-and-positive-number', {id:'TOTAL_PRICE', errMsg:'請輸入正確初估貸放金額' });
			validates.valid.define('reqiured-and-positive-number', {id:'PER_PRICE', errMsg:"請輸入正確平均單價(萬)"});
		},
		
		// 列印、刪除檢核
		checkPrintInput: function(){
			validates.valid.define('TD1_required', {id:'PREAPPR_NO_TD'});
		},
		
		checkSaveOnly : function(){
			validates.valid.define('required', {id:'AREA_CODE', errMsg:'請選取公司放款區域成數' });		
		}
	};
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement( "DSA32103" , "鑑價作業", "初估申請輸入", 0, true);
			
			autoFormatToNumber();
			
			<%--[20240930] 初始畫面--%>
			action.initPage();
			/*
			$('AREA_CODE').value = '';
			$('LIMIT_RATE').value = '';
			$('LIMIT_RATE_C').value = '';
			*/
			// 檢核初始化
			validates.initValidation();
			
			// 監聽: 暫存
			$("BTN_0083").observe('click', button.doSave );	
			
			// 監聽: 結案
			$("BTN_0020").observe('click', button.doClose );
			
			// 監聽: 列印
			$("BTN_0005").observe('click', button.doPrint );	
			
			// 監聽: 結案案件變更
			$("BTN_0495").observe('click', button.doChange );
			
			// 監聽: 刪除
			$("BTN_0003").observe('click', button.doDelete );
			
			// 監聽: 計算
			$("PER_PRICE").observe('keyup', button.doCalculate );
			 
			$("BTN_TODSA31900").observe('click', 
				function(){
					var XML = {};
					XML.PREAPPR_NO = $F('PREAPPR_NO');
					XML.PREAPPR_ADDR = $F('PREAPPR_ADDR');
		
				    popupWin.windowOpen('<%=dispatcher%>/DSA3_1900/prompt',{
		        		'parameters': {'XML':Object.toJSON(XML)}
		    		});
				}
			 );
			 
			 
			// 監聽: 刪除
			$("AREA_CODE").observe('change', action.changeAREA_CODE );
			
			autoFormatToDate();
			PageUI.resize();
			displayMessage();					
		}, // end initApp()--
		
		isChanged: function(info) {
			var hasChange = false;
			A280VO = $('A280VO').value.evalJSON();
			$$('#block_A input[type=text]').each(function(ele){
				if( (ele.value || A280VO[ele.id]) && ele.value != A280VO[ele.id] ){
					if(ele.id == "LIMIT_RATE_C") {
						if( ele.value != A280VO['LIMIT_RATE'] ){
							hasChange = true;
						}
					} else if(ele.id == "BUILD_MEASURE_C" || ele.id == "CITY" || ele.id == "TOWN" || ele.id == "AGENT_DATE") {
					
					} else if(ele.id == "TOTAL_PRICE" || ele.id == "PER_PRICE") {
						trimVal = ele.value.replace(/,/gi,'');
						if(trimVal != A280VO[ele.id]){
							hasChange = true;
						}
					} else {
						hasChange = true;
					}
				}
			});
		
			$$('#block_A input:checked[type=radio]').each(function(ele){
				if( ele.value != A280VO[ele.name]){
					hasChange = true;
				}
			});
			
			if(hasChange){
				alert("畫面資料有異動,請按暫存或結案案件變更");
				parent.DSA32100.TABS.select(info.from);
			}
			

		}
	}// end return--
}// end DSA32103

</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<input id="A280VO" name="A280VO" type="hidden" value="" />
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td colspan='2' align='center' vlign='center' >
					<input type="button" class="button" id="BTN_0083" value="暫存" />
					<input type="button" class="button" id="BTN_0003" value="刪除" />
					<input type="button" class="button" id="BTN_0020" value="結案" />
					<input type="button" class="button" id="BTN_0495" value="結案案件變更" />
					<input type="button" class="button" id="BTN_0005" value="列印" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="17%" >初估編號
					<input id="PREAPPR_NO" name="PREAPPR_NO" type="hidden" value="" />
				</td>
				<td id="PREAPPR_NO_TD" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >1.借款人資料</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp借款人
					<input id="BORROW_NAME" name="BORROW_NAME" type="hidden" value="" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
				<td id="BORROW_NAME_TD" class="tbYellow2" style="font-family:'EUDC'"></td><%--[20240930]難字調整 --%>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp借款人ID
					<input id="BORROW_ID" name="BORROW_ID" type="hidden" value="" />
				</td>
				<td id="BORROW_ID_TD" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp欲申貸金額
					<input id="APPLY_AMT" name="APPLY_AMT" type="hidden"  value="" />
				</td>
				<td id="APPLY_AMT_TD" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >2.擔保品內容</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp建物郵遞區號
					<input id="PREAPPR_ZIP" name="PREAPPR_ZIP" type="hidden" value="" />
				</td>
				<td id="PREAPPR_ZIP_TD" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp建物地址</td>
				<td class="tbYellow2">
					<input id="PREAPPR_ADDR" name="PREAPPR_ADDR" type="text" value="" size="50" maxlength="100" readonly="readonly" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp總坪數
				</td>
				<td id="MEASURE" class="tbYellow2" ></td>
			</tr>
			<tr>
				<td class="tbYellow"  colspan="2" >3.區域放款率</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp主要用途</td>
				<td class="tbYellow2" id = "MAIN_USE_LIST">
					<c:forEach var="map" items="${MAIN_USE_LIST}" >
						<input name="MAIN_USE" type="radio" value = "${map.key}" disabled/> ${map.value}  
					</c:forEach>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >&nbsp&nbsp&nbsp公司放款區域成數</td>
				<td class="tbYellow2" >
					<select id="AREA_CODE">
							<option value = "" > 請選擇 </option>
						<c:forEach var="map" items="${AREA_CODE_LIST}" >
							<option value = "${map.value}" > ${map.value} </option>										
						</c:forEach>
					</select>
					<input id="LIMIT_RATE" name="LIMIT_RATE" type="text"  datatype="number" value="" pattern="#,###.##" onblur="$('LIMIT_RATE_C').value = $('LIMIT_RATE').value"  size="7" maxlength="5" readonly="readonly"/>(%)承作成數
				</td>
			</tr>
			<tr>
				<td id="" class="tbYellow2"  colspan="6" >
					<span style="color:red;">【重要說明事項1】</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(1) 擔保品若屬於主管機關認定的特定地區或高價住宅，受『購罝住宅貸款業務規範』限制。</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(2) 個案承作『工業用、農業用住宅』及『購罝住宅貸款業務規範』承作成數最高60%，不得申請只繳利息，利率亦不得低於公司規定。</span>
				</td>
			</tr>
			
			<tr>
				<td class="tbYellow"  colspan="2" >4.初估貸放金額</td>
			</tr>
			<tr>
				<td class="tbYellow2"  colspan="2" >
					&nbsp&nbsp&nbsp<a href="#" id="BTN_TODSA31900">(1)平均單價查詢</a><span style="color:red;">(*為必填)</span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow2"  colspan="2" >
					&nbsp&nbsp&nbsp(2)初估貸放金額(萬)<input id="TOTAL_PRICE" name="TOTAL_PRICE" type="text"  datatype="number" value="" pattern="#,###.##" size="10" readonly="readonly"/>
					=建物<input id="BUILD_MEASURE_C" name="BUILD_MEASURE" type="text"  datatype="number" value=""  size="10" readonly="readonly"/>
					(坪)X<input id="PER_PRICE" name="PER_PRICE" type="text"  datatype="number" value=""  size="10" pattern="#,###.##" />
					<font color='red'>*</font>平均單價(萬)X<input id="LIMIT_RATE_C" name="LIMIT_RATE" type="text"  datatype="number" value=""  size="5" readonly="readonly"/>
					(%)承作成數
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >申請日期<input id="AGENT_DATE" name="AGENT_DATE" type="hidden" value="" /></td>
				<td class="tbYellow2" id="AGENT_DATE_VIEW"></td>
			</tr>
			<tr>
				<td class="tbYellow2"  colspan="2" >
					<span style="color:red;">【重要說明事項2】</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(1) 初估貸放金額未扣除『土地增值稅』、『已貸金額』及未考慮擔保品有『嫌惡設施』情形。</span><br>
					<span style="color:red;">&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(2) 實際可承作額度、條件，需視『借款人債信收入條件』及『相關規範』重新評估。</span>
				</td>
			</tr>
		</tbody>	
	</table>
	</form>
</body>
</html>