<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30800.jsp
作者：沈志穎
功能：特殊屋況查詢作業
完成：2021/01/19
[20240930]難字調整
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/suggest.js'></script> <%-- 搜尋提示用 --%>
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
<script type='text/javascript'>
	<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
	Event.observe(window, 'load', new DSA30800().initApp);

	function DSA30800(){

		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_0800/');

		var valid;
		var grid;

		<%-- 已查詢的鄉鎮市區清單 --%>
		var TOWN_Map = {};

		<%-- 資料表格 --%>
		var gridColumn = [
			<%--------------------- 第一列 ---------------------%>
			{ header: "編號", key: "SER_NO", attrs: {rowSpan: 2, width:'10%'}, groupKey:["SER_NO"],  <%-- 分群 --%>
				render:function(record, value) {
					if (value) {
						//[20210224]不同進度，導頁至不同畫面
						var OP = (record.STATUS == '0'||record.STATUS == '2') ? '1' : '2';
						var link = new Element('a', {href :'javascript:void(0);'}).update(value);
						link.observe('click', function() { <%-- 文字超連結至DSA30801特殊屋況輸入作業 --%>
							var LP_JSON = {
								action : '${dispatcher}/DSA3_0801/prompt',
								SER_NO : value,
								OP : OP,
								LINK_FROM : 'DSA30800'
							};
							CSRUtil.linkTo(LP_JSON, 'form1');
						});
					}	          
					return link;
				}
			},
			{ header: "門牌地址", key: "ADDR_NO", attrs: {rowSpan: 2, align:'left', style:"font-family:'EUDC'"}<%--[20240930]難字調整 --%>, groupKey:["SER_NO"] }, <%-- 分群 --%>
			{ header: "地號", empty:'rowSpan_down', attrs: {colSpan: 4} }, <%-- 表頭合併儲存格 --%> 
			{ header: "特殊屋況原因", key: "REASON_NM", attrs: {rowSpan: 2}, groupKey:["SER_NO"] },
			{ header: "社區名稱", key: "COMMUNITY_NAME", attrs: {rowSpan: 2}, groupKey:["SER_NO"],
				render : function(record, value) {
					return (record['COMMUNITY_NO'] || '') + ' ' + (record['COMMUNITY_NAME'] || '');
				}
			},
			{ header: "建檔日" , key: "INPUT_DATE", sortRule: "date", attrs: {rowSpan: 2}, groupKey:["SER_NO"] },
			{ header: "輸入單位" ,key: "INPUT_DEPT_NM", attrs: {rowSpan: 2}, groupKey:["SER_NO"] },
			{ header: "狀態", key: "STATUS_NM", attrs: {rowSpan: 2}, groupKey:["SER_NO"] },
			{ header: "公告列管", key: "IS_CONTROL_NM", attrs: {rowSpan: 2}, groupKey:["SER_NO"] },
			<%--------------------- 第二列 ---------------------%>
			{ header: "地段", key: "LAND_LOCATION1" },
			{ header: "小段", key: "LAND_LOCATION2" },
			{ header: "地號1", key: "LAND_NO1" },
			{ header: "地號2", key: "LAND_NO2" }
		];

		var actions = {

			<%-- 初始「輸入檢核」驗證條件 --%>
			initValidation : function() {
				<%-- [20210219]
					查詢時，至少須以下列一類組合為查詢條件
					1. 縣市+地段
					2. 縣市+門牌(輸入到路名)
					3. 輸入單位+公告列管
					4. 輸入單位+狀態
				--%>
				Validation.addAllThese(
						[
							[
								  'validate-QueryCondition'
								, '多筆查詢時，請至少設定下列1種查詢條件：\n1. 縣市+地段\n2. 縣市+門牌(輸入到路名)\n3. 輸入單位+公告列管\n4. 輸入單位+狀態'
								, function( v ) {
									
									var reqMap = actions.getReqMap();
									for(var key in reqMap){
										var val = reqMap[key];
										if(key == 'CITY'||key == 'LAND_LOCATION'||key == 'LAND_NO'||key == 'ADDR_NO'||key == 'INPUT_DEPT'||key == 'IS_CONTROL'||key == 'STATUS'){
											var city = $F('CITY');
											var land_location = $F('LAND_LOCATION');
											var land_no = $F('LAND_NO');
											if (city && (land_location || land_no )) { return true; }

											var addrNo = $F('ADDR_NO');
											if (city && addrNo && ( addrNo.substring(1).indexOf('路') > -1 || addrNo.substring(1).indexOf('街') > -1 ) ) { return true; }

											var inputDept = $F('INPUT_DEPT');
											var isControl = $F('IS_CONTROL');
											if (inputDept && isControl ) { return true; }

											var status = $F('STATUS');
											if (inputDept && status ) { return true; }
										}else{
											if(val && val!=""){
												 return true;
											}
										}
									}

									return false;
								}
							]
						]
				);
				valid = new Validation("form1", {useTitles:false, focusOnError:false, immediate:false});
				valid.define('validate-Date-Interval', [{ id: 'INPUT_DATE_S', errMsg: '建檔日期(起)不得大於建檔日期(迄)' }, { id: 'INPUT_DATE_E', errMsg: '', ignore : true }]);
				valid.define( 'validate-QueryCondition' , [ { id : 'btn_query' , errMsg:'多筆查詢時，請至少設定下列1種查詢條件：\n1. 縣市+地段\n2. 縣市+門牌(輸入到路名)\n3. 輸入單位+公告列管\n4. 輸入單位+狀態' } ] );
			},

			<%-- 查詢 --%>
			doQuery : function() {

				valid.reset();
				if( !valid.validate() ) {
					return;
				}	

				<%-- 啟動查詢 --%>
				ajaxRequest.post('query', { reqMap : Object.toJSON(actions.getReqMap()) },
					function(resp) {
						grid.load(resp.rtnList ? resp.rtnList : []);
					},
					function(resp) {
						grid.load([]);
					}
				);
			},

			<%-- 取得鄉鎮市區 --%>
			getDIST_LIST : function(DIST) {
				var $DIST = $('DIST');
				$DIST.update().appendChild(new Element('option', { value: '' }).update('請選擇'));
				var val = $F('CITY') ;
				if ( !val ) {
					return;
				}

				<%-- 已查詢過就不用再做查詢 --%>
				var opts = TOWN_Map[val];
				if ( opts && opts.length > 0 ) {				
					opts.each(function(opt) {
						$DIST.appendChild(new Element('option', { value: opt.TOWN_NAME }).update(opt.TOWN_NAME));
					});				
				} else { <%-- 未查詢過: call DSA3_0800.getDIST_LIST --%>
					ajaxRequest.post('getDIST_LIST', { CITY_NAME : val },
						function(resp) {
							var opts = resp.DIST_LIST;
							TOWN_Map[val] = opts; <%-- 記錄至「已查詢過」的鄉鎮市區清單 --%>
							if (opts) {
								opts.each(function(opt) {
									$DIST.appendChild(new Element('option', { value : opt.TOWN_NAME }).update(opt.TOWN_NAME));
								});
								if ( typeof DIST === 'string' ) {
									$DIST.setValue(DIST); <%-- 按上頁回來之後，回填鄉鎮市區 --%>
								}
							}
						}
					);
				}		
			},

			<%-- 取得畫面查詢條件 --%>
			getReqMap : function() {
				var reqMap = {
					SER_NO : $F('SER_NO'), <%-- 編號 --%>
					INPUT_DATE_S : $F('INPUT_DATE_S'), <%-- 建檔日期(起) --%>
					INPUT_DATE_E : $F('INPUT_DATE_E'), <%-- 建檔日期(迄) --%>
					LAND_LOCATION : $F('LAND_LOCATION'), <%-- 地段 --%>
					LAND_NO : $F('LAND_NO'), <%-- 地號 --%>
					INPUT_DEPT : $F('INPUT_DEPT'), <%-- 輸入單位 --%>
					CITY : $F('CITY'), <%-- 縣市別 --%>
					DIST : $F('DIST'), <%-- 鄉鎮市區 --%>
					ADDR_NO : $F('ADDR_NO'), <%-- 門牌地址 --%>
					STATUS : $F('STATUS'), <%-- 狀態 --%>
					COMMUNITY_NAME : $F('COMMUNITY_NAME'), <%-- 社區名稱 --%>
					COMMUNITY_NO : $F('COMMUNITY_NO'), <%-- 社區編號 --%>
					REASON : $F('REASON'), <%-- 特殊屋況原因 --%>
					IS_CONTROL : $F('IS_CONTROL'), <%-- 公告列管 --%>
				};
				return reqMap;
			}, 

			<%--「社區名稱建議清單」--%>
			suggest : function() {
				<%-- 社區名稱搜尋，加入suggestion裡面 --%>
				Suggest.add( 
					'COMMUNITY_NAME', 			  
					Suggest.URL,
					'${dispatcher}/DSA3_0800/suggestCaseName',
					{						
						ignoreCase: true,
						startLength: 2,
						option_key: 'COMMUNITY_NAME', <%-- 建議清單左值(查詢資料)，suggestList必為List<Map> --%>
						remark_key: 'COMMUNITY_NO', <%-- 建議清單右值(備註)，suggestList必為List<Map> --%>
						noCookies: true, <%-- 也會決定「歷史查詢資訊Bar」是否顯示 --%>
						callBackFunc: function(node, rec){ 
							$('COMMUNITY_NO').setValue(rec ? rec['COMMUNITY_NO'] : '');
						}	
					}
				);
			},

			<%-- 門牌地址轉全形 --%>
			toDBC : function() {
				var input = $F('ADDR_NO') || '';
				var output = "";
				var len = input.length;
				for (var i=0;i<len;i++)	{
					var cCode = input.charCodeAt(i);
					<%-- 全形與半形相差（除空格外）：65248(十進位制) --%>
					cCode = (cCode>=0x0021 && cCode<=0x007E) ? (cCode+65248) : cCode;
					<%-- 處理空格 --%>
					cCode = (cCode==0x0020) ? 0x03000 : cCode;
					output += String.fromCharCode(cCode);
				}
				$('ADDR_NO').setValue(output);
			}
		};

		return {                              
			initApp : function() {

				<%-- 統一頁面樣式 --%>
				<cathay:LocaleDisplay sysCode='DS' dateFields="INPUT_DATE_S INPUT_DATE_E" var='localeDisplay' />
				PageUI.createPage("DSA30800" , "鑑價作業" , "特殊屋況查詢作業", false);
				PageUI.loadin(["form1","grid"], 1);

				<%-- 產表格表頭&定義查詢資料來源 --%>
				grid = new TableUI ({
					table: $("grid"), 
					pageSize: 10, 
					allSortable: true, 
					selectRowWithGroup: true, 
					whenDataNull: '', <%-- 當資料是Null時，用此參數代換 --%>
					split: ['LAND_LOCATION1'], <%-- 「地段」換到下一行 --%>
					<%-- [20240930] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column: gridColumn
				});	

				<%-- 查詢 --%>
				$('btn_query').observe('click', actions.doQuery);

				<%--「縣市別」下拉選單連動 「鄉鎮區」下拉選單 --%>
				$('CITY').observe('change', actions.getDIST_LIST);		

				<%-- 門牌地址轉全形 --%>
				$('ADDR_NO').observe('blur', actions.toDBC);

				<%-- 初始「輸入檢核」驗證條件 --%>
				actions.initValidation();

				<%--「社區名稱建議清單」--%>
				actions.suggest();

				<%-- 輸入單位 - 預設User單位代號值 --%>
				<%-- [20210219] 取消預設
				$('INPUT_DEPT').setValue('${DIV_NO}' || '');
				 --%>

				<%-- 從輸入、覆核作業，點擊回上頁回來，將原本form1的輸入欄位重新填入並查詢 --%>
				var LP_JSON = CSRUtil.isBackLink('form1');
				if ( LP_JSON ) {
					actions.getDIST_LIST(LP_JSON.BQ_ARG.DIST || '');
					actions.doQuery();
				}

				<%-- 顯示底部訊息 --%>
				displayMessage();
			}                 
		}
	}
</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <%------------------------- 查詢條件區 -------------------------%>
    <form id="form1" name="form1" method="post">
        <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
            <tr>
                <td class="tbYellow">編號</td>
                <td class="tbYellow2" colspan="8">
                    <input id="SER_NO" name="SER_NO" type="text" title="編號" fieldName="編號" class="textBox2" size="15" maxlength="8" />
                </td>

				<td class="tbYellow2" rowspan="4" align="center">
                    <button id="btn_query" name="btn_query" type="button" class="button">查詢</button>
                </td>
            </tr>

            <tr>
                <td class="tbYellow">建檔日期</td>
                <td class="tbYellow2" colspan="2">
                    <input type="text" title="建檔日期(起)" fieldName="建檔日期(起)" class="textBox2" size="8" maxlength="7" name="INPUT_DATE_S" id="INPUT_DATE_S" />
                    ~
                    <input type="text" title="建檔日期(迄)" fieldName="建檔日期(迄)" class="textBox2" size="8" maxlength="7" name="INPUT_DATE_E" id="INPUT_DATE_E" />
                </td>
                <td class="tbYellow">地段</td>
                <td class="tbYellow2">
                    <input id="LAND_LOCATION" name="LAND_LOCATION" type="text" title="地段" fieldName="地段" class="textBox2" size="15" maxlength="10" />
                </td>
                <td class="tbYellow">地號</td>
                <td class="tbYellow2">
                    <input id="LAND_NO" name="LAND_NO" type="text" title="地號" fieldName="地號" class="textBox2" size="15" maxlength="10" />
                </td>
                <td class="tbYellow">輸入單位</td>
                <td class="tbYellow2">
                    <select name="INPUT_DEPT" id="INPUT_DEPT" title="輸入單位" fieldName="輸入單位">
						<option value="">全部</option>
                        <c:forEach var="map" items="${INPUT_DEPT}">
                            <option value="${map.key}">${map.value}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>

            <tr>
                <td class="tbYellow">縣市別</td>
                <td class="tbYellow2" colspan="2">
                    <select name="CITY" id="CITY" title="縣市別" fieldName="縣市別">
                        <option value="">請選擇</option>
                        <c:forEach var="map" items="${CITY_LIST}">
                            <option value="${map.CITY_NAME}">${map.CITY_NAME}</option>
                        </c:forEach>
                    </select>
                    <select name="DIST" id="DIST" title="鄉鎮市區" fieldName="鄉鎮市區">
                        <option value="">請選擇</option>
                    </select>
                </td>
                <td class="tbYellow">門牌地址</td>
				<td class="tbYellow2" colspan="3">
					<input id="ADDR_NO" name="ADDR_NO" type="text" title="門牌地址" fieldName="門牌地址" class="textBox2" size="70" maxlength="60" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
				<td class="tbYellow">狀態</td>
                <td class="tbYellow2">
                    <select name="STATUS" id="STATUS" title="狀態" fieldName="狀態">
						<option value="">全部</option>
                        <c:forEach var="map" items="${STATUS_Map}">
                            <option value="${map.key}">${map.value}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>

			<tr>
				<td class="tbYellow">社區名稱</td>
                <td class="tbYellow2" colspan="2">
                    <input id="COMMUNITY_NAME" name="COMMUNITY_NAME" type="text" title="社區名稱" fieldName="社區名稱" class="textBox2" size="45" maxlength="40" />
					<input id="COMMUNITY_NO" name="COMMUNITY_NO" type="hidden" title="社區編號" fieldName="社區編號" />
                </td>
                <td class="tbYellow">特殊屋況原因</td>
                <td class="tbYellow2" colspan="3">
                    <select name="REASON" id="REASON" title="特殊屋況原因" fieldName="特殊屋況原因">
                        <option value="">全部</option>
                        <c:forEach var="map" items="${REASON}">
                            <option value="${map.key}">${map.value}</option>
                        </c:forEach>
                    </select>
				</td>
				<td class="tbYellow">公告列管</td>
				<td class="tbYellow2">
                    <select name="IS_CONTROL" id="IS_CONTROL" title="公告列管" fieldName="公告列管">
                        <option value="">全部</option>
						<c:forEach var="map" items="${IS_CONTROL}">
                            <option value="${map.key}">${map.value}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>

        </table>

		<%------------------------- 查詢資料表格區 -------------------------%>
		<table id="grid" class="grid"></table>
    </form>
</body>
</html>