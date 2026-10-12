<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSA33320.jsp
功能：社區資料查詢作業
作者：吳誌倫
完成：2022/11/14

[20221202]問題單20221201210551
1.更新下拉選單社區狀態、維護狀態、建築形態
2.移除建置人員、建置日期欄位，調整欄位擺放位置，與變數命名，傳值參數名稱
3.調整調整查詢必要欄位檢核
4.調整查詢清單顯示欄位
5.調整社區編號超連結
6.新增，呼叫模組寫入社區資料
郭曉慧

[20221214][20221214094934]
調整查詢條件可以用社區編號 或是 縣市行政區兩個角度進行查詢
高強禾

[20230118] 修改件 陳勁谷
1.查詢檢核改為 社區編號 或【縣市】+【行政區/社區狀態/維護項目】擇一必填
2.匯出產生報表，維護人員及覆核人員需遮蔽

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible">

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>
<%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/suggest.js'></script>
<%-- 搜尋提示用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>

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
Event.observe(window, 'load', new DSA33320().initApp);

function DSA33320() {
	var grid;
	var isQuery = false;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3320/');
	var valid;
	
	var actions = {
		getReqMap : function(target){
			var reqMap = {};
			$('queryArea').select('input', 'select').each(function(ele){
				reqMap[ele.id] = $F(ele);
			});
			<%-- [20221214] --%>
			if ($F('POSTCODE')) {
				reqMap.DIST = $('POSTCODE').options[$('POSTCODE').selectedIndex].text;
			}
			if(target && target.id == 'btn_insert'){
				reqMap.FINISH_DATE = reqMap.FINISH_DATE_E;
			}
			return reqMap;
	    },
	    <%--縣市連動取得行政區--%>
	    getPostCodeList : function(){
	    	var select = $('POSTCODE');
	    	select.length = 1;
			var val = $F('CITY') ;
			if(val == ''){
				alert("請先選擇縣市。");
				return;
			}
			ajaxRequest.post('getPostCodeList', {CITY_NAME : val},
					function(resp){
						var POSTCODE_LIST = resp.POSTCODE_LIST;
						POSTCODE_LIST.each(function(opt){
							select.insert(new Option(opt.TOWN_NAME, opt.POSTCODE));
						});
					}
			);	
		},
		<%--行政區連動取得次分區--%>
		getSubmktList : function(){
			var select = $('SUBMKT_NAME');
			select.length = 1;
			var city_val = $F('CITY');
			if(!city_val){
				alert("請先選擇縣市。");
				return;
			}
			var postcode_val = $F('POSTCODE');
			if(!postcode_val){
				alert("請先選擇行政區。");
				return;
			}
			var distName = $('POSTCODE').options[$('POSTCODE').selectedIndex].text;
			ajaxRequest.post('getSubmktList', {CITY_NAME : city_val, DIST_NAME : distName},
					function(resp){
						var SUBMKT_LIST = resp.SUBMKT_LIST;
						SUBMKT_LIST.each(function(opt){
							select.insert(new Option(opt.NAME, opt.NAME));
						});
					}
			);	
		},
		<%--鑑價科連動取得建置人員、維護人員、覆核人員--%>
		getApprIdList : function(){
			<%--[20221202]移除CREATE_ID相關/MAINTAIN_ID改為UPDATE_ID/MAINTAIN_CONFIRM_ID改為CONFIRM_ID--%>
	    	var U_select = $('UPDATE_ID'); //維護人員下拉選單
	    	U_select.length = 1;
	    	var C_select = $('CONFIRM_ID'); //覆核人員下拉選單
	    	C_select.length = 1;
	    	
			var val = $F('APPR_DEPT');
			if(val == ''){
				alert("請先選擇鑑價科。");
				return;
			}
			ajaxRequest.post('getApprIdList', {APPR_DEPT : val},
					function(resp){
						var APPR_ID_LIST = resp.APPR_ID_LIST;
						APPR_ID_LIST.each(function(opt){
							U_select.insert(new Option(opt.NAME, opt.ID));
							C_select.insert(new Option(opt.NAME, opt.ID));
						});
					}
			);	
		},
		resetLAND_NO: function(){ <%--[20221202]檢核--%>
			if($F(this).length == 4 || $F(this).length == 0){
				return;
			}
			var value = '0'.times(4 - $F(this).length) + $F(this);
			$(this).setValue(value);
		},
		validates: function(target){ <%--[20221202]檢核--%>
			valid.reset();
			valid.clear();
			if(target.id == 'btn_query'){
				<%-- [20221214] --%>
				valid.define("validate-digits", {id: 'LAND_NO1', errMsg: '僅能輸入數字'});
				valid.define("validate-digits", {id: 'LAND_NO2', errMsg: '僅能輸入數字'});
				<%--[20221207]補LOCATION3檢核--%>
				valid.define("validate-LOCATION3", {id: 'LOCATION3'});
				$w('FINISH_DATE MAINTAIN_DATE CONFIRM_DATE UPDATE_PIC_DATE').each(function(eleId){
					valid.define('validate-Date-Range', [{id: eleId + "_S", ignore: true}, {id: eleId + "_E"}]);
					valid.define('validate-ROCDate-Interval', [{id: eleId + "_S", ignore: true}, {id: eleId + "_E"}]);
				});
			}else if(target.id == 'btn_insert'){
				<%--[20221207]移除LOCATION3必輸檢核--%>
				<%--[20231026]新增 ADDR_NO 必輸檢核--%>
				$w('CITY POSTCODE ADDR_NO CASE_NAME LOCATION2 LAND_NO1 LAND_NO2').each(function(eleId){
					if($(eleId).type == 'text'){
						valid.define("required", {id: eleId});
					}else{
						valid.define("validate-selection", {id: eleId});
					}
				});
				<%--[20221207]補LOCATION3檢核--%>
				valid.define("validate-LOCATION3", {id: 'LOCATION3'});
				$w('FINISH_DATE_S FINISH_DATE_E').each(function(eleId){
					valid.define("required", {id: eleId});
				});
				valid.define('validate-Date-Same', [{id: "FINISH_DATE_S", ignore: true}, {id: "FINISH_DATE_E"}]);
			}
			return valid.validate();
		},
		initValidation: function(){ <%--[20221202]初始檢核--%>
			Validation.addAllThese([
				['validate-Date-Range', '日期起迄需皆有值', function(str_dt, end_dt, inputs){
					var strIsEmpty = str_dt.blank();
					var endIsEmpty = end_dt.blank();
					return strIsEmpty == endIsEmpty;
				}],
				['validate-Date-Same', '日期起迄需相同', function(str_dt, end_dt, inputs){
					if(!str_dt.blank() && !end_dt.blank()){
						return str_dt == end_dt;
					}
					return true;
				}],
				['validate-LOCATION3', '請確認是否為國字數字', function(v){
					if(!Validation.get('IsEmpty').test(v)){
						if(/^[0-9]*$/g.test(v) || ["１","２","３","４","５","６","７","８","９","０"].include(v)){
							return false
						}
					}
					return true;
				}]
			]);
			valid = new Validation("form1", {focusOnError:true, immediate: false, mode: 'validator'});
		}
	};
	var buttons = {
		<%--查詢--%>
		doQuery : function(){
			if(!actions.validates($(this))){
				return;
			}

			<%-- [20221214] --%>
			<%--[20230118] 修改件 陳勁谷1.查詢檢核改為 社區編號 或【縣市】+【行政區/社區狀態/維護項目】擇一必填--%>
			if (!$F('COMMUNITY_NO') && (!($F('CITY') && ($F('POSTCODE') || $F('STATUS') || $F('MA_KD'))))) {
				alert('社區編號 或【縣市】+【行政區/社區狀態/維護項目】擇一必填');
				return;
			}

			//如果小段號有輸入，檢核不能輸入阿拉伯數字
			<%--[20221207]改放到valid檢核--%>
			ajaxRequest.post( 'query' , { reqMap : Object.toJSON(actions.getReqMap($(this)))} ,
				function(resp){
					grid.load(resp.rtnList||[]);
					isQuery = true;
				},
				function(resp){ 	
					grid.load([]);
					isQuery = false;
				}
			);	
		},
		<%--新增社區--%>
		doInsert : function(){
			if(!actions.validates($(this))){
				return;
			}
			var reqMap = actions.getReqMap($(this));
			var isConfirm = 'N';
			ajaxRequest.post('insert' ,{ reqMap : Object.toJSON(reqMap)},
				function(resp){
					if(resp.CFM_MSG){
						if(confirm(resp.CFM_MSG)){
							isConfirm = 'Y';
						}
					}else{
						isConfirm = 'Y';
					}
					if(isConfirm == 'Y'){
						reqMap.isConfirm = isConfirm;
						ajaxRequest.post('insert' ,{ reqMap : Object.toJSON(reqMap)},
							function(resp){
								var mapA349 = resp.mapA349;
								var paramMap = {
									LINK_FROM: 'DSA33320',
									LINK_TYPE: 'IN',
									COMMUNITY_NO: mapA349.COMMUNITY_NO,
									UPDATE_TIME: mapA349.UPDATE_TIME
								};
								popupWin.popup({
									src : '${dispatcher}/DSA3_3390/prompt'
									,scrolling : 'yes'
									,parameters : paramMap
									,width : "100%"
									,height : "100%"
									,left : "0"
									,top : "0"
									,onclose: function(){
										$('btn_query').simulate('click');
									}
								}); 
							}
						);
					}
				}
			);	
		},
		<%--匯出--%>
		doExport : function(event){
			if(!isQuery){
				alert('請先執行查詢');
				return;
			}
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_3320/export',
				{
					reqMap : Object.toJSON(actions.getReqMap()),
					gridJSON : grid.getXlsSettingJSON('覆審分派移轉作業')
				}
			);
		}
	};
	<%--判斷是否為數字--%>
	<%--[20221207]移除isNumeric--%>
	
    return{
    
    initApp : function(){
    		<cathay:LocaleDisplay sysCode = "DS" var = "localeDisplay" dateFields = "FINISH_DATE_S FINISH_DATE_E MAINTAIN_DATE_S MAINTAIN_DATE_E UPDATE_PIC_DATE_S UPDATE_PIC_DATE_E CONFIRM_DATE_S CONFIRM_DATE_E"/>
		    PageUI.createPageWithAllBodySubElement("DSA33320", "鑑價作業", "社區資料查詢作業");
		    <%--[20221202]移除建置人員/日期--%>
		    grid = new TableUI({
			    table : $("grid"),
			    pageSize : 10,
				allSortable : true,
				split: ['DIST'],
			    column:[
			    	{header:"縣市", key :'CITY'},
					{header:"社區名稱", key :'CASE_NAME'},
					{header:"門牌地址", key :'ADDR_NO', attrs:{rowSpan:2}, styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:"社區價格", key :'VALUATION_4', attrs:{rowSpan:2},
						render : function(rec, val){
							return ( rec.VALUATION_4_LOW || '' ) + '~' + ( rec.VALUATION_4_HIGH || '' );
						}	
					},
					{header:"社區狀態", key :'STATUS_NM'},
					{header:"生活圈", key :'SUBMKT_NAME'},
					{header:"屋齡", key :'BUILD_AGE'},
					{header:"維護人員", key :'UPDATE_NM', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:"覆核人員", key :'CONFIRM_NM', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					//第二行
					{header:"行政區", key:'DIST'},
					{header:"社區編號", key :'COMMUNITY_NO',
						render : function (rec, val){
							var link = new Element('a', { href : 'javascript:;' });
							link.update(val);	
							link.observe('click', 
								function(){
									var paramMap = {
										LINK_FROM: 'DSA33320',
										LINK_TYPE: 'IN',
										COMMUNITY_NO: rec.COMMUNITY_NO,
										UPDATE_TIME: rec.UPDATE_TIME
									};
									popupWin.popup({
										src : '${dispatcher}/DSA3_3390/prompt'
										,scrolling : 'yes'
										,parameters : paramMap
										,width : "100%"
										,height : "100%"
										,left : "0"
										,top : "0"
										,onclose: function(){
											<%--[20221206]補重查--%>
											$('btn_query').simulate('click');
										}
									}); 
							});
							return link;
						}
					},
					{header:"維護項目", key :'MA_KD_NM'},
					{header:"建築型態", key :'USE_FOR_NM'},
					{header:"影像更新日期", key :'UPDATE_PIC_DATE', sortRule: 'date'},
					{header:"維護日期", key :'UPDATE_TIME', sortRule: 'date'},
					<%--[20221207]調整覆核日期key--%>
					{header:"覆核日期", key :'CONFIRM_TIME', sortRule: 'date'}
			    ]
			});
		    
		    <%--按鈕註冊--%>
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_insert').observe('click', buttons.doInsert);
			$('btn_export').observe('click', buttons.doExport);
			
			<%--下拉選單連動--%>
			$('CITY').observe('change', actions.getPostCodeList); //「縣市」下拉選單連動 「行政區」下拉選單
			$('POSTCODE').observe('change', actions.getSubmktList); //「行政區」下拉選單連動 「次分區」下拉選單
			$('APPR_DEPT').observe('change', actions.getApprIdList); //「鑑價科」下拉選單連動 「建置人員」「維護人員」「覆核人員」下拉選單$('LAND_NO1') ')
			$w('LAND_NO1 LAND_NO2').each(function(ele){
				$(ele).observe('blur', actions.resetLAND_NO);
			});
			<%--「社區名稱」建議選單--%>
			Suggest.add( 
				'CASE_NAME', 			  
			     Suggest.URL,
				'${dispatcher}/DSA3_3320/getSuggestCaseName',
					{						
			           ignoreCase:true,
			           startLength:2,
			           option_key:"CASE_NAME",
			           remark_key:"COMMUNITY_NO",	
			           noCookies:true
					}
			);
		    actions.initValidation();
			PageUI.resize();
		    displayMessage();
   	}
   };
}

</script>
</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id="queryArea" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table1'>
			<tr>
				<td class="tbYellow" width="10%">社區編號</td>
				<td class="tbYellow2" width="20%">
					<input type="text" class="textBox2" maxlength="10" name="COMMUNITY_NO" id="COMMUNITY_NO" fieldName="社區編號"/>
				</td>
				<td class="tbYellow" width="10%">社區名稱</td>
				<td class="tbYellow2" width="20%">
					<input type="text" class="textBox2" name="CASE_NAME" id="CASE_NAME" fieldName="社區名稱"/>
				</td>
				<td class="tbYellow" width="10%">鑑價科</td>
				<td class="tbYellow2" width="10%">
					<select class="textBox2" name="APPR_DEPT" id="APPR_DEPT" fieldName="鑑價科">
						<option value="">全部</option>
						<c:forEach var="entry" items="${APPR_DEPT_LIST}">
							<option value="${entry.key}">${entry.value}</option>
						</c:forEach>
					</select>
				</td>
				<!-- [20221202]移除建置人員 -->
				<td class="tbYellow" width="10%"></td>
				<td class="tbYellow2" width="10%">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">縣市別</td>
				<td class="tbYellow2">
					<select class="textBox2" name="CITY" id="CITY" fieldName="縣市">
						<option value="">請選擇</option>
						<c:forEach var="entry" items="${CITY_LIST}">
							<option value="${entry.key}">${entry.value}</option>
						</c:forEach>
					</select>
					<select class="textBox2" name="POSTCODE" id="POSTCODE" fieldName="行政區">
						<option value="">請選擇</option>
					</select>
				</td>
				<td class="tbYellow">門牌地址</td>
				<td class="tbYellow2">
					<input class="textBox2" id="ADDR_NO" type="text" size="40" fieldName="門牌地址" alt="ch"/><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow">維護人員</td>
				<td class="tbYellow2">
					<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<select class="textBox2"name="UPDATE_ID" id="UPDATE_ID" fieldName="維護人員" alt="ch">
						<option value="">全部</option>
					</select>
				</td>
				<td class="tbYellow">覆核人員</td>
				<td class="tbYellow2">
					<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<select class="textBox2" name="CONFIRM_ID" id="CONFIRM_ID" fieldName="覆核人員" alt="ch">
						<option value="">全部</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">建築完成日</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" name="FINISH_DATE_S" id="FINISH_DATE_S" value="" fieldName="建築完成起日"/>~
					<input type="text" class="textBox2" name="FINISH_DATE_E" id="FINISH_DATE_E" value="" fieldName="建築完成迄日"/>
				</td>
				<td class="tbYellow">社區狀態</td>
				<td class="tbYellow2">
					<select class="textBox2" name="STATUS" id="STATUS" fieldName="社區狀態">
						<option value="">請選擇</option>
						<c:forEach var="entry" items="${STATUS_LIST}">
							<option value="${entry.key}">${entry.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow">維護項目</td>
				<td class="tbYellow2" colspan="3">
					<select class="textBox2" name="MA_KD" id="MA_KD" fieldName="維護項目">
						<option value="">請選擇</option>
						<!-- [20221202]調整資料來源 -->
						<c:forEach var="entry" items="${MA_KD_LIST}">
							<option value="${entry.key}">${entry.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">生活圈</td>
				<td class="tbYellow2">
					<select class="textBox2" name="SUBMKT_NAME" id="SUBMKT_NAME" fieldName="生活圈">
						<option value="">請選擇</option>
					</select>
				</td>
				<td class="tbYellow">地段名</td>
				<td class="tbYellow2">
					<input class="textBox2" id="LOCATION2" type="text" fieldName="段名"/>段 
					<input class="textBox2" id="LOCATION3" type="text" fieldName="小段名" />小段
				</td>
				<td class="tbYellow">維護日期</td>
				<td class="tbYellow2" colspan="3">
					<input type="text" class="textBox2" name="MAINTAIN_DATE_S" id="MAINTAIN_DATE_S" value="" fieldName="維護起日" />~ 
					<input type="text" class="textBox2" name="MAINTAIN_DATE_E" id="MAINTAIN_DATE_E" value="" fieldName="維護?日" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">建築型態</td>
				<td class="tbYellow2">
					<select class="textBox2" name="USE_FOR" id="USE_FOR" fieldName="建築型態">
						<!-- [20221208]增-請選擇 -->
						<option value="">請選擇</option>
						<c:forEach var="entry" items="${USE_FOR_LIST}">
							<option value="${entry.key}">${entry.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow">地號</td>
				<td class="tbYellow2">
					<input id="LAND_NO1" type="text" class="textBox2" size="6" maxlength="4" fieldName="地號1"/>-
					<input id="LAND_NO2" type="text" class="textBox2" size="6" maxlength="4" fieldName="地號2"/>
				</td>
				<td class="tbYellow">覆核日期</td>
				<td class="tbYellow2" colspan="3"> 
					<input type="text" class="textBox2" name="CONFIRM_DATE_S" id="CONFIRM_DATE_S" value="" fieldName="覆核起日" />~ 
					<input type="text" class="textBox2" name="CONFIRM_DATE_E" id="CONFIRM_DATE_E" value="" fieldName="覆核?日" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">影像更新日期</td>
				<td class="tbYellow2">
					<input type="text" class="textBox2" name="UPDATE_PIC_DATE_S" id="UPDATE_PIC_DATE_S" value="" fieldName="影像更新起日"  />~
					<input type="text" class="textBox2" name="UPDATE_PIC_DATE_E" id="UPDATE_PIC_DATE_E" value="" fieldName="影像更新起日"  />
				</td>
				<td class="tbYellow2" colspan="6"></td>
			</tr>
		</table>
	</form>
	<div style="text-align: center;" class="tbYellow2">
		<button type="button" class="button" id="btn_query">查詢</button>
		<button type="button" class="button" id="btn_insert">新增社區</button>
		<button type="button" class="button" id="btn_export">匯出</button>
	</div>
	<table id="grid"></table>
</body>
</html>