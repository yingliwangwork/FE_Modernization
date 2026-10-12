<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA36000.jsp
作者：陳忻葇
功能：地震風險查詢作業
完成：2023/04/07

-->


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css' />
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>

<script type='text/JavaScript'>
Event.observe(window, 'load', new DSA36000().initApp);

function DSA36000(){
	
	var grid;
	var valid;
	
	<%-- 已查詢的鄉鎮市區清單 --%>
	var TOWN_Map = {};
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_6000/');	

	function initValidation(){
		valid = new Validation('form1', {useTitles:true, mode : 'validate'});
		valid.define('required', {id:'RESOURCE'});
		valid.define('required', {id:'APPR_DATE_S'});
		valid.define('required', {id:'APPR_DATE_E'});
		valid.define('required', {id:'EQ_LEVEL'});
		valid.define('required', {id:'ORIGIN_DATE_S'});
		valid.define('required', {id:'ORIGIN_CLOCK_S'});
		valid.define('required', {id:'ORIGIN_MIN_S'});
		valid.define('required', {id:'ORIGIN_DATE_E'});
		valid.define('required', {id:'ORIGIN_CLOCK_E'});
		valid.define('required', {id:'ORIGIN_MIN_E'});
	}
	
	var actions = {
			<%-- 取得鄉鎮市區 --%>
			getTOWN_LIST : function() {
				var selectElement = $("selectTOWN");
				selectElement.length = 1;
				var val = $F("selectCITY");
				if(val == ''){
					return;
				}
				//已查詢過就不用再做查詢
				if(TOWN_Map[val] && TOWN_Map[val].length > 0){
					var opts = TOWN_Map[val];
					if(opts){
						opts.each(function(opt){
							var nm = opt.TOWN_NAME;
							selectElement.insert(new Option(nm, nm));
						});
					}				
				} else {
					ajaxRequest.post('getTOWN_LIST',{CITY_NAME : val},
						function(resp){
							var opts = resp.TOWN_LIST;
							TOWN_Map[val] = opts;
							if(opts){
								opts.each(function(opt){
									var nm = opt.TOWN_NAME;
									selectElement.insert(new Option(nm, nm));
								});
							}
						}
					);
				}
			},
			<%-- 依案件來源改動顯示項目 --%>
			setResource : function() {
				var res = $F("selectRESOURCE");
				if(0 == res) {
					<%-- 人壽件 --%>
					$("VALID").show();
					$("validNM").show();
				} else {
					<%-- 銀行件 --%>
					var valid = $("VALID");
					valid.writeAttribute("checked", false);
					valid.hide();
					$("validNM").hide();
				}
				actions.changeGrid();
			},
			<%-- 依案件來源改動結果Table --%>
			changeGrid : function() {
				if(0 == $F("selectRESOURCE")) {
					<%-- 人壽件Table --%>
					grid = new TableUI({
						table : $('grid') , allSortable: true,
						column : [
							{ header:'原貨帳號' , key:'REFER_ID' },
							{ header:'擔保品受編' , key:'APPLY_ID', render: function(rec, val, sn, key){
			            		var aEle = new Element('a',{href:'javascript:void(0)'}).update(val);
			            		aEle.observe("click", actions.PopUpDSA30500);
			            		return aEle;	
			            	}},
							{ header:'縣市' , key:'CITY' },
							{ header:'行政區' , key:'TOWN' },
							{ header:'期間最大震度' , key:'INTENSITY_MAX' },
							{ header:'測站代碼' , key:'EQSTATION_CODE' },
							{ header:'測站名稱' , key:'EQSTATION_NAME' }, 
							{ header:'地震報告編號' , key:'EARTHQUAKE_NO', render: function(rec, val, sn, key){
								var url = rec.URL || '';
			            		var aEle = new Element('a',{href:'javascript:void(0)',url:url}).update(val);
			            		aEle.observe("click", actions.PopUpEQReport);
			            		return aEle;	
			            	}}
						]
					});
				}else{
					grid = new TableUI({
						table : $('grid') , allSortable: true,
						column : [
							{ header:'擔保品受編' , key:'APPLY_ID', render: function(rec, val, sn, key){
			            		var aEle = new Element('a',{href:'javascript:void(0)'}).update(val);
			            		aEle.observe("click", actions.PopUpDSA30500);
			            		return aEle;	
			            	}},
							{ header:'縣市' , key:'CITY' },
							{ header:'行政區' , key:'TOWN' },
							{ header:'期間最大震度' , key:'INTENSITY_MAX' },
							{ header:'測站代碼' , key:'EQSTATION_CODE' },
							{ header:'測站名稱' , key:'EQSTATION_NAME' }, 
							{ header:'地震報告編號' , key:'EARTHQUAKE_NO', render: function(rec, val, sn, key){
								var url = rec.URL || '';
			            		var aEle = new Element('a',{href:'javascript:void(0)',url:url}).update(val);
			            		aEle.observe("click", actions.PopUpEQReport);
			            		return aEle;	
			            	}}
						]
					});
				}
			},
			<%-- 擔保品受編超連結(PopupWin) --%>
			PopUpDSA30500 : function(e) {
				var applyId = e.target.innerText;
				 
				popupWin.popup({
					src : '${dispatcher}/DSA3_0500/prompt?APPLY_ID=' + applyId,
					title : applyId.replace('@', "")
				});
			},
			<%-- 地震報告編號超連結(PopupWin) --%>
			PopUpEQReport : function(e) {
				popupWin.popup({
					src : e.target.getAttribute('url'),
					'fullScreen': true,
				});
			},
			<%--設定值給span或其他可以用setValue的--%>
			setElementValue : function(elem , val) {
				var $elem = $(elem);
				if(!$elem){
					return;
				}	
				var tagName = $elem.tagName.toUpperCase();
				if(tagName === 'SPAN'){
					$elem.update(val || '');
				} else{
					$elem.setValue(val || '');
				}
			},
			getInputs : function() {
				var rtnObj = {};
				$$("#tableA input", "#tableA select").each(function(ele) {
					rtnObj[ele.name] = $F(ele);
				});
				<%-- 串接地震時間，秒數：起00，迄59 --%>
				var ORIGIN_TIME_S = $F("ORIGIN_DATE_S");
				ORIGIN_TIME_S += (" "+$F("ORIGIN_CLOCK_S"));
				ORIGIN_TIME_S += (":"+$F("ORIGIN_MIN_S"));
				rtnObj.ORIGIN_TIME_S = (ORIGIN_TIME_S + ":00");
				var ORIGIN_TIME_E = $F("ORIGIN_DATE_E");
				ORIGIN_TIME_E += (" "+$F("ORIGIN_CLOCK_E"));
				ORIGIN_TIME_E += (":"+$F("ORIGIN_MIN_E"));
				rtnObj.ORIGIN_TIME_E = (ORIGIN_TIME_E + ":59");
				return rtnObj;
			}
	};
	
	var buttons = {
			<%-- 查詢 --%>
			doQuery : function() {
				valid.reset();
				if( !valid.validate() ) {
		    		return;
		    	}	
				ajaxRequest.post('query', {qryMap: Object.toJSON(actions.getInputs())},
						function(resp) {
							actions.changeGrid()
							grid.load(resp.rtnList||[]);
						},
						function(resp){
							grid.clear();
						}
					);
			},
			<%-- 清除 --%>
			doClear : function() {
				valid.reset();
				actions.setElementValue('selectRESOURCE','');
				$("VALID").writeAttribute("checked", false);
				actions.setElementValue('APPR_DATE_S','');
				actions.setElementValue('APPR_DATE_E','');
				actions.setElementValue('selectCITY','');
				actions.setElementValue('selectTOWN','');
				actions.setElementValue('selectEQ_LEVEL','');
				actions.setElementValue('ORIGIN_DATE_S','');
				actions.setElementValue('ORIGIN_CLOCK_S','00');
				actions.setElementValue('ORIGIN_MIN_S','00');
				actions.setElementValue('ORIGIN_DATE_E','');
				actions.setElementValue('ORIGIN_CLOCK_E','00');
				actions.setElementValue('ORIGIN_MIN_E','00');
				grid.clear();
			},
			<%-- 匯出(CSV 檔案 編碼 BIG5) --%>
			doExport : function(){
				valid.reset();
				if( !valid.validate() ) {
		    		return;
		    	}	
				<%--檢查查詢區是否有資料--%>
				if(grid.getAllRecords().length == 0){
					alert('請先執行地震風險查詢紀錄！');
					return;
				}
				var reqMap = actions.getInputs();
				reqMap['gridJSON'] = grid.getXlsSettingJSON("test");
				ajaxRequest.post('export', {qryMap: Object.toJSON(reqMap)},
						function(resp) {
							var options = {
									downloadFileName : resp.downloadFileName,
									downloadFileFullPath : resp.downloadFileFullPath,
									isOpenNewBrowse : false
							}
							<%--下載檔案--%>
							RPTUtil.download(options); 
						}
					);
			}
	};
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement('DSA36000', '鑑價作業', '地震風險查詢');
			<cathay:LocaleDisplay 
			dateFields='APPR_DATE_S APPR_DATE_E ORIGIN_DATE_S ORIGIN_DATE_E' 
			sysCode='DS' var='localeDisplay' />
			
			<%-- tableUI 初始化 --%>
			actions.changeGrid();
			
			$('selectCITY').observe('change', actions.getTOWN_LIST); <%--「縣市別」下拉選單連動 「鄉鎮區」下拉選單 --%>
			$('selectRESOURCE').observe('change', actions.setResource); <%--「案件來源」下拉選單連動「有效件」核取方塊 & grid table欄位 --%>
			$('btnQuery').observe('click', buttons.doQuery);
			$('btnClear').observe('click', buttons.doClear);
			$('btnExport').observe('click', buttons.doExport);
			//actions.initSelects(); <%-- 選單初始化 --%>
			
			initValidation();
			displayMessage();
		}
	}
}

</script>
</head>
<body style='PADDING: 0px; MARGIN: 0px;'>
	<form name='form1' id='form1'>
		<table id='tableA' width='100%' class='tbBox2'>
			<tr>
				<td class='tbYellow'>案件來源<span style="color:red;">*</span></td>
				<td class='tbYellow2'>
					<select name="RESOURCE" id="selectRESOURCE">
						<option value="0">人壽件</option>
						<option value="1">銀行件</option>
					</select>
					<input type="checkbox" id="VALID" name="VALID" value="Y"/><span id="validNM">有效件</span>
				</td>
				<td class='tbYellow'>鑑價日期<span style="color:red;">*</span></td>
				<td class='tbYellow2'>
					<input id="APPR_DATE_S" name="APPR_DATE_S" />
					~
					<input id="APPR_DATE_E" name="APPR_DATE_E" />
				</td>
				<td class='tbYellow2' rowspan="3" align="center">
					<button type="button" id="btnQuery" class="button">查詢</button>
					<button type="button" id="btnClear" class="button">清除</button>
					<button type="button" id="btnExport" class="button">下載</button>
				</td>
			</tr>
			<tr>
				<td class='tbYellow'>縣市行政區</td>
				<td class='tbYellow2' colspan="3">
					<select name='CITY' id='selectCITY' title='縣市別' fieldName='縣市別'>
                        <option value=''>縣市別</option>
                        <c:forEach items="${CITY_LIST}" var="cityMap">
                        	<c:forEach items="${cityMap}" var="cityNmae">
						   		<option value='${cityNmae.value}'>${cityNmae.value}</option>
						   	</c:forEach>
						</c:forEach>
                    </select>
					<select name='TOWN' id='selectTOWN' title='鄉鎮區' fieldName='鄉鎮區'>
                        <option value=''>鄉鎮區</option>
                    </select>
				</td>
			</tr>
			<tr>
			    <td class='tbYellow'>震度門檻<span style="color:red;">*</span></td>
				<td class='tbYellow2' >
					<select name='EQ_LEVEL' id='selectEQ_LEVEL' title='震度門檻'>
                        <option value=''>請選擇</option>
                        <c:forEach var="eqLevel" items="${EQ_LEVEL_Map}">
                        <option value='${eqLevel.key}'>${eqLevel.value}</option>
						</c:forEach>
                    </select>
                    <span>（含）以上</span>
				</td>
				<td class='tbYellow'>地震時間<span style="color:red;">*</span></td>
				<td class='tbYellow2'>
					<input id="ORIGIN_DATE_S" name="ORIGIN_DATE_S" />
					<select id="ORIGIN_CLOCK_S" name="ORIGIN_CLOCK_S">
						<c:forEach var="orgClock" items="${ORIGIN_CLOCK}">
                        <option value='${orgClock}'>${orgClock}</option>
						</c:forEach>
					</select> 時
					<select id="ORIGIN_MIN_S" name="ORIGIN_MIN_S">
						<c:forEach var="orgMin" items="${ORIGIN_MIN}">
                        <option value='${orgMin}'>${orgMin}</option>
						</c:forEach>
					</select> 分 
					~
					<input id="ORIGIN_DATE_E" name="ORIGIN_DATE_E" />
					<select id="ORIGIN_CLOCK_E" name="ORIGIN_CLOCK_E">
						<c:forEach var="orgClock" items="${ORIGIN_CLOCK}">
                        <option value='${orgClock}'>${orgClock}</option>
						</c:forEach>
					</select> 時 
					<select id="ORIGIN_MIN_E" name="ORIGIN_MIN_E">
						<c:forEach var="orgMin" items="${ORIGIN_MIN}">
                        <option value='${orgMin}'>${orgMin}</option>
						</c:forEach>
					</select> 分 
				</td>
			</tr>
			<tr>
			<td class='tbYellow' colspan="5">※案件來源：人壽件（有效件－不含法務件或放貸前；非有效件－已覆核）、銀行件（已覆核）</td>
			</tr>
		</table>
		<table id="grid"></table>
	</form>
</body>
</html>
