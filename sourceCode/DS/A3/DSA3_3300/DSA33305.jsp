<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33305.jsp
作者：張晉瑋
功能：車位資料。
完成：2018/05/07

[20221215]
1. 調整初始查詢條件
2. 調整確認檢核及SQL條件
高強禾

[20230630]【呈核】調整車位單價與坪數檢核規則邏輯
[20240423]
1.修正車位資料表欄位，調整車位編輯區成清單跟單筆編輯區塊
2.調整操作處理邏輯，新增、刪除、修改(確認)
3.增加車位查詢

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
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src='${htmlBase}/CM/js/ui/InputUtility.js'></script>

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
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA33305().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA33305(){
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3305/');
	var grid1;
	var valid1;
	
	<%--欄位檢核--%>
	function initValidation(){
		<%--車位清單資料用檢核--%>
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		Validation.addAllThese([
			['checkNum5', '上限為5碼數字 (0 ~ 99999)', function(v) {
				return checkNumeralFormat(v, 5, 0) && v!='';
			}],
			['checkNum3', '上限為3碼數字 (0 ~ 999)', function(v) {
				return checkNumeralFormat(v, 5, 0) && v!='';
			}],
			['checkNum15', '上限為15碼數字 (1 ~ 999,999,999,999,999)', function(v) {
				return checkNumeralFormat(v, 15, 0) && v!='' && parseInt(v) > 0;
			}],			
			['checkNum2-3', '上限為整數2位小數3位數字(0 ~ 99.999)', function(v) {
				return checkNumeralFormat(v, 2, 3) && v!='';
			}],			
			['select_validate', '請選擇車位型態，不得為「無」!', function(v) {
				return (v != '0' && v != '1') ;
			}]
		]);		
		valid1.define('checkNum5', [{ id:'CAUX_NO1', errMsg:"建號母號上限為5碼數字 (0 ~ 99999)"}]);
		valid1.define('checkNum3', [{ id:'CAUX_NO2', errMsg:"建號子號上限為3碼數字 (0 ~ 999)"}]);
		valid1.define('checkNum15', [{ id: 'REGIST_UP', errMsg:"謄本登記持分分子欄位，上限為15碼數字 (1 ~ 999,999,999,999,999)" }] );
		valid1.define('checkNum15', [{ id: 'REGIST_BASE', errMsg:"謄本登記持分分母欄位，上限為15碼數字 (1 ~ 999,999,999,999,999)" } ] );
		valid1.define('checkNum15', [{ id: 'HOLD_UP', errMsg:"車位拆分持分分子欄位，上限為15碼數字 (1 ~ 999,999,999,999,999)" }] );
		valid1.define('checkNum15', [{ id: 'HOLD_BASE', errMsg:"車位拆分持分分母欄位，上限為15碼數字 (1 ~ 999,999,999,999,999)" } ] );
		valid1.define('select_validate', [{ id:'PARK', errMsg: '車位型態下拉式選單，必須選擇' }]);		
		valid1.define('checkNum3', [{ id:'PARK_NUM', errMsg:"數量上限為3碼數字 (0 ~ 999)"}]);
		valid1.define('validate-selection', [{id:'INDE_PARK', errMsg:'獨立產權下拉式選單，必須選擇'}]);
		valid1.define('validate-selection', [{id:'PUBLIC_PARK', errMsg:'是否車公下拉式選單，必須選擇'}]);
		valid1.define('checkNum2-3', [{ id:'PARK_SPACE', errMsg:"面積(坪/1位)為整數2位小數3位數字 (0 ~ 99.999)"}]);
		valid1.define('checkNum3', [{ id:'PARK_PRICE', errMsg:"均價(萬/1位)上限為3碼數字 (0 ~ 999)"}]);		
		valid1.define('validate-selection', [{id:'PARK_OUTPUT', errMsg:'是否輸出下拉式選單，必須選擇'}]);
	}
	
	var actions = {
		getDataB: function(){
			var reqMap = {};
			$('blockB').select('input, select').each(function(elem){
				var key = elem.name ? elem.name : elem.id;
				reqMap[key]=elem.getValue();
			});
			return reqMap;
		},
		setDataB: function(qryMap){
			valid1.reset();
			$('blockB').select('input, select').each(function(elem){
				var key = elem.name ? elem.name : elem.id;
				var val = qryMap[key] == undefined ? '' : qryMap[key];
				elem.setValue(val.toString());
			});
		},
		initDataB: function(qryMap){
			valid1.reset();
			$('blockB').select('input, select').each(function(elem){
				elem.setValue('');
			});
			$('COMMUNITY_NO').setValue(qryMap['COMMUNITY_NO']);
			$('VALID').setValue(qryMap['VALID']);
			$('PARK').setValue('0');
		}
	};
	var buttons = {	
		doQuery: function (reqMap){	
			ajaxRequest.post('query', { reqMap : Object.toJSON(reqMap) },
				function(resp){ 
					actions.setDataB(resp.qryMap || {});
				}
			);
		},
		<%--新增按鈕--%>
		doInsert : function (){	
			if(!valid1.validate()){
				return;
			}
			var reqMap = actions.getDataB();
			ajaxRequest.post('insert', { reqMap : Object.toJSON(reqMap) },
				function(resp){ 
					grid1.load(resp.A354List || []);
					actions.initDataB(resp.qryMap || {});
				}
			);
		},
		<%--修改按鈕--%>	
		doUpdate : function (){
			if(!valid1.validate()){
				return;
			}
			var reqMap = actions.getDataB();
			ajaxRequest.post('update', { reqMap : Object.toJSON(reqMap) },
				function(resp){ 
					grid1.load(resp.A354List || []);
					actions.initDataB(resp.qryMap || {});
				}
			);
		},
		<%--刪除--%>
		doDelete : function (rec){	
			if(!confirm('確認要刪除車位資料?')){
			    return;
	     	}
			
			ajaxRequest.post('delete', { reqMap : Object.toJSON(rec) },
				function(resp){ 
					grid1.load(resp.A354List || []);
					actions.initDataB(resp.qryMap || {});
				}
			);
		}
	}	
	return {
		initApp : function() {	
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement(
					'DSA33305',
					'鑑價作業',
					'車位資料',
					'',
					true
				);
						
			<%-- TableUI--%>
			grid1 = new TableUI(                         
				{                   				
					table: $('grid1'),
					title: '車位資料清單',
					pageSize: 10, 
					column:[    
						{ header: '序號', key: 'SHOW_SEQ',
							render: function(rec, val){
								var link = new Element('a', {href:'javascript:;'}).update(val);
								link.observe('click', function(){
									buttons.doQuery(rec);
								});
								return link;
							}
						},
						{ header: '建號', key: '',
							render: function(rec, val){								
								return rec.CAUX_NO1 + '-' + rec.CAUX_NO2;
							}
						},
						{ header: '謄本登記持分', key: '',
							render: function(rec, val){								
								return localeDisplay.formatNumber(rec.REGIST_UP, 0) + '/' + localeDisplay.formatNumber(rec.REGIST_BASE, 0);
							}
						},
						{ header: '車位拆分持分', key: '',
							render: function(rec, val){								
								return localeDisplay.formatNumber(rec.HOLD_UP, 0) + '/' + localeDisplay.formatNumber(rec.HOLD_BASE, 0);
							}
						},
						{ header: '車位型態', key: 'PARK_NM'},
						{ header: '數量', key: 'PARK_NUM', sortRule: 'number' },
						{ header: '獨立產權', key: 'INDE_PARK_NM'},
						{ header: '是否車公', key: 'PUBLIC_PARK_NM'},
						{ header: '面積(坪/1位)', key: 'PARK_SPACE', sortRule: 'number' },
						{ header: '均價(萬/1位)', key: 'PARK_PRICE', sortRule: 'number' },
						{ header: '修正人員', key: 'INPUT_NAME', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						{ header: '修正時間', key: 'UPDATE_DATE', sortRule: 'date' },
						{ header: '是否輸出', key: 'PARK_OUTPUT_NM'},
						{ header: '編輯', key: '' ,
							input:{
								type:"button",
								text:"刪除",
		                        action:function( node , dataObj , value){ 	
									buttons.doDelete(dataObj[0]);	
								}
							}

						}	
					]					
				}                 
			);
			
			//註冊DOM物件
			$("btn_insert").observe("click", buttons.doInsert );
			$("btn_update").observe("click", buttons.doUpdate );

			grid1.load(<c:out value = '${A354List}' default = '[]' escapeXml = "false"/>);

			<%-- [20221215] --%>
			<c:if test="${BTN_STATUS ne '1'}">
			    <%-- [20240521 調整非編輯狀態，換頁按鈕 可以作業] --%>    
				$$('button[type="button"]').each(function(btn) {
					if(btn.className == 'button') {
						btn.disable();						
					}
				});
				$$('input[type="button"]').each(function(btn) {
					btn.disable();
				});				
			</c:if>
			
			initValidation();	
			displayMessage();				
			PageUI.resize();
			autoFormatToNumber();
			
			<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
			parseEUDC();
		}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id='grid1' class='grid'></table>
		<table id = "blockB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class='tbYellow'>建號</td>
				<td class='tbYellow'>謄本登記持分</td>
				<td class='tbYellow'>車位拆分持分</td>
				<td class='tbYellow'>車位型態</td>
				<td class='tbYellow'>數量</td>
				<td class='tbYellow'>獨立產權</td>
				<td class='tbYellow'>是否車公</td>
				<td class='tbYellow'>面積(坪/1位)</td>
				<td class='tbYellow'>均價(萬/1位)</td>
				<td class='tbYellow'>是否輸出</td>
			</tr>
			<tr>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="CAUX_NO1" name="CAUX_NO1" maxlength='5' size='8' datatype="number" pattern='####' />
					<input type="text" class="textBox2" id="CAUX_NO2" name="CAUX_NO2" maxlength='3' size='5' datatype="number" />
					<input type="hidden" class="textBox2" id="COMMUNITY_NO" name="COMMUNITY_NO" value='${qryMap.COMMUNITY_NO}' />
					<input type="hidden" class="textBox2" id="VALID" name="VALID" value='${qryMap.VALID}' />
					<input type="hidden" class="textBox2" id="SEQ_NO" name="SEQ_NO" />
				</td>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="REGIST_UP" name="REGIST_UP" maxlength='19' datatype="number" pattern='#,###' />/
					<input type="text" class="textBox2" id="REGIST_BASE" name="REGIST_BASE" maxlength='19' datatype="number" pattern='#,###' />
				</td>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="HOLD_UP" name="HOLD_UP" maxlength='19' datatype="number" pattern='#,###' />/
					<input type="text" class="textBox2" id="HOLD_BASE" name="HOLD_BASE" maxlength='19' datatype="number" pattern='#,###' />
				</td>				
				<td class='tbYellow2'>
					<select id="PARK" name="PARK" class="textBox2">
						<c:forEach var="map" items="${PARK_LIST}" >
							 <option value="${map.key}" > ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="PARK_NUM" name="PARK_NUM" maxlength='3' size='5' datatype="number" pattern='#,###' />
				</td>
				<td class='tbYellow2'>
					<select id="INDE_PARK" name="INDE_PARK" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${INDE_PARK_LIST}" >
							 <option value = "${map.key}" > ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class='tbYellow2'>
					<select id="PUBLIC_PARK" name="PUBLIC_PARK" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${PUBLIC_PARK_LIST}" >
							 <option value = "${map.key}" > ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="PARK_SPACE" name="PARK_SPACE" maxlength='6' size='8' datatype="number" pattern='##.###' />
				</td>
				<td class='tbYellow2'>
					<input type="text" class="textBox2" id="PARK_PRICE" name="PARK_PRICE" maxlength='3' size='5' datatype="number" pattern='#,###' />
				</td>				
				<td class='tbYellow2'>
					<select id="PARK_OUTPUT" name="PARK_OUTPUT" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${PARK_OUTPUT_LIST}" >
							 <option value = "${map.key}" > ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
			</tr>
		</table>
		<div style="text-align:center">
			<button type="button" class="button" id="btn_insert">新增</button>
			<button type="button" class="button" id="btn_update">修改</button>
		</div>
	</form>
</body>
</html>