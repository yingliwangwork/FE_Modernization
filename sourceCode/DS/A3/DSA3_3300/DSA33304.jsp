<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33304.jsp
作者：張晉瑋
功能：環境資料。
完成：2018/04/27
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

<script type='text/javascript'>
// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA33304().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA33304(){

	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3304/');
	var grid1;
	var valid1;
	var valid2;
	var valid3;
	<%--init時要顯示的資料list--%>
	var DISLIKE_FACILITY_LIST = <c:out value = '${DISLIKE_FACILITY_LIST}' default = '[]' escapeXml = "false"/>;
	var DISLIKE_EFFECT_LIST = <c:out value = '${DISLIKE_EFFECT_LIST}' default = '[]' escapeXml = "false"/>;
	var SPC_KD_GOOD_LIST = <c:out value = '${SPC_KD_GOOD_LIST}' default = '[]' escapeXml = "false"/>;
	
	<%--欄位檢核 Validation.js--%>
	function initValidation(){
		<%--捷運說明 用檢核--%>
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });
		Validation.addAllThese([	
			['validLength20', '最多為20碼', function(v , node) { 
				<%--判斷Big5 StringLength--%>
				if(actions.getChtLength(v) > 20 ){
					return false;
				}else{
					return true;
				}
			}],
			[ 'validate1DESC_VIEW', '補充說明請勿輸入單引號!!',
				function(v){
					return (v.indexOf('\'') != -1) ? false : true ;
				}
			],
			[ 'validate2DESC_VIEW', '補充說明請勿輸入半形逗號!!',
				function(v){
					return (v.indexOf(',') != -1) ? false : true ;
				}
			]
		]);
			
		valid1.define('validLength20',{id:'BUILD_LINE',errMsg:"共構捷運線名稱最多為20碼"});
		valid1.define('validLength20',{id:'BUILD_STATION',errMsg:"共構捷運站名稱最多為20碼"});
		valid1.define('validLength20',{id:'ROUND_LINE',errMsg:"圓心捷運線名稱最多為20碼"});
		valid1.define('validLength20',{id:'ROUND_STATION',errMsg:"圓心捷運站名稱最多為20碼"});
		valid1.define('validLength20',{id:'ROUND_EXIT',errMsg:"圓心捷運站出口最多為20碼"});
		valid1.define( "validate1DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid1.define( "validate2DESC_VIEW" , { id: "DISLIKE_DESC_VIEW" } );
		valid1.define( "validate1DESC_VIEW" , { id: "SPC_DESC_VIEW" } );
		valid1.define( "validate2DESC_VIEW" , { id: "SPC_DESC_VIEW" } );

		<%--設施清單 用檢核--%>
		valid2 = new Validation("form2", { focusOnError:true, immediate:false });
		Validation.addAllThese([	
			['validLength100', '設施名稱最多為100碼', function(v , node) { 
				<%--使用BLEN，判斷Big5 StringLength--%>
				if(actions.getChtLength(v) > 100 ){
					return false;
				}else{
					return true;
				}
			}],
			['checkNumeralFormat', '數值輸入格式錯誤，整數僅接受5位整數，小數點僅接受到小數點後3位!', function(v , node) { 
				return checkNumeralFormat(v , 5 , 3);
			}]
		]);

		<%--環域分析 用檢核--%>
		valid3 = new Validation("form2", { focusOnError:true, immediate:false });
		Validation.addAllThese([	
			[ 'validateAPPLY_ID',  '受理編號長度不正確 需為11碼',
				function(v){				
					return (v.length != 11) ? false : true ;
				}
			]
		]);	
		
		valid3.define( "validateAPPLY_ID" , { id: "APPLY_ID" } )
	}
	
	var buttons = {	
		<%--新增按鈕--%>
		doInsert : function (){	
			grid1.addRecords([{'COMMUNITY_NO':'${COMMUNITY_NO}', 'SPC_KIND':'', 'SPC_NAME':'', 'SPC_FACILITY':'','SPC_DISTANCE':'','SPC_EFFECT':''}]);
		},
		<%--確認按鈕--%>
		doConfirm : function (){	
			valid1.reset();
			valid2.reset();
			valid3.reset();
			if(!valid2.validate()){
				return;
			}
			var DATA_LIST = grid1.getAllRecords();
			for(var i = 0; i < DATA_LIST.length; i++){
				var DATA = DATA_LIST[i];
				if(DATA.SPC_KIND == '0'){	
					alert("請選擇設施種類");
					return;
				}
				<%--若選擇嫌惡設施，下拉選單必須選擇--%>
				<%--if(record.SPC_KIND == 'B' && !record.SPC_EFFECT){		
					alert("設施種類選擇嫌惡，請選擇影響下拉選單!!");
					return;
				}--%>
				if(DATA.SPC_EFFECT == '0'){		
					alert("請選擇影響");
					return;
				}
				if(DATA.SPC_FACILITY == '0'){
					alert("請選擇類別");
					return;
				}
			}
			<%--發送ajax--%>
			ajaxRequest.post('confirm', 
			{ 
				DATA_LIST : Object.toJSON(DATA_LIST),
				COMMUNITY_NO : '${COMMUNITY_NO}',
				UPDATE_TIME : '${UPDATE_TIME}'
			},function(resp){ 
				if(resp.A353_List){
					grid1.load(resp.A353_List);
					$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
				//模擬textarea keyup動作
				$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW').each( 
					function(id){
						$(id).simulate('keyup');
					}
				);
			});
		},
		<%--修改按鈕--%>
		doModify : function(){
			valid1.reset();
			valid2.reset();
			valid3.reset();
			if(!valid1.validate()){
				return;
			}
			<%--讀取畫面欄位--%>
			var reqMap = actions.makeRecord();
			<%--發送ajax--%>
			ajaxRequest.post('modify', 
			{ 
				reqMap : Object.toJSON(reqMap),
				COMMUNITY_NO : '${COMMUNITY_NO}',
				UPDATE_TIME : '${UPDATE_TIME}'
			},function(resp){ 
				$('METRO').options[0].selected = true;
				$('METRO1').options[0].selected = true;
				$('STATION').options.length = 1;
				$('STATION1').options.length = 1;
				if(resp.A350Map){
					actions.setData2(resp.A350Map);
				}
				//模擬textarea keyup動作
				$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW').each( 
					function(id){
						$(id).simulate('keyup');
					}
				);
			});
		},
		<%--環域分析按鈕(By受編)--%>
		getA353List : function(){
			
			$('APPLY_ID').value = $('APPLY_ID').value.toUpperCase();
			
			valid1.reset();
			valid2.reset();
			valid3.reset();
			if(!valid3.validate()){ 
				return; 
			}
			<%--發送ajax--%>
			ajaxRequest.post('getA353List', 
			{ 
				APPLY_ID : $('APPLY_ID').value
			},function(resp){ 
				if(resp.A353_List){
					grid1.load(resp.A353_List);
					//$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
				//模擬textarea keyup動作
				$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW').each( 
					function(id){
						$(id).simulate('keyup');
					}
				);
			});	
		},
		<%--環域分析按鈕(By社區)--%>
		getA353ListNew : function(){
			valid1.reset();
			valid2.reset();
			valid3.reset();
			<%--發送ajax--%>
			ajaxRequest.post('getA353ListNew', 
			{ 
				COMMUNITY_NO : '${COMMUNITY_NO}',
				UPDATE_TIME : '${UPDATE_TIME}'
			},function(resp){ 
				if(resp.A353_List){
					grid1.load(resp.A353_List);
					//$('UPDATE_DATE').innerHTML = "資料更新日期：" + resp.UPDATE_DATE;
				}
				//模擬textarea keyup動作
				$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW').each( 
					function(id){
						$(id).simulate('keyup');
					}
				);
			});		
		}
	}	
	var actions = {
		<%--將畫面A資料存成Record--%>
		 makeRecord : function(reportVlaue){
			var reqMap = {};
			reqMap['BUILD_LINE'] = $F('BUILD_LINE');
			reqMap['BUILD_STATION'] = $F('BUILD_STATION');
			reqMap['ROUND_LINE'] = $F('ROUND_LINE');
			reqMap['ROUND_STATION'] = $F('ROUND_STATION');
			reqMap['ROUND_EXIT'] = $F('ROUND_EXIT');
			reqMap['ROUND_DISTANCE'] = $F('ROUND_DISTANCE');
			reqMap['DISLIKE_DESC'] = $F('DISLIKE_DESC_VIEW');
			reqMap['SPC_DESC'] = $F('SPC_DESC_VIEW');
			return reqMap;	
		},		
		<%--捷運說明下拉選單連動--%>
		setData : function(text, key, value, station, station_text){
			$(station).options.length = 1; 
			$(station_text).setValue('');

			if(!value){
				$(key).setValue('');
				return;
			}
			
			$(key).setValue(text);

			<%--發送ajax--%>
			ajaxRequest.post('getSTATION_LIST',
			{
				'L_SEQ' :value
			},function(resp){
				var dataList = resp.STATION_LIST;			
				for(var i = 0; i < dataList.length; i++){
					$(station).insert(new Option(dataList[i].s_NAME , dataList[i].s_SEQ));
				}					
			});
		},
		setStationData : function(text, key, value){
			if(!value){
				$(key).setValue('');
				return;
			}
			$(key).setValue(text);
		},
		setData2 : function(A350Map){
			$('BUILD_LINE').setValue(A350Map.BUILD_LINE || '');
			$('BUILD_STATION').setValue(A350Map.BUILD_STATION || '');
			$('ROUND_LINE').setValue(A350Map.ROUND_LINE || '');
			$('ROUND_STATION').setValue(A350Map.ROUND_STATION || '');
			$('ROUND_EXIT').setValue(A350Map.ROUND_EXIT || '');
			$('ROUND_DISTANCE').setValue(A350Map.ROUND_DISTANCE || '');
			$('DISLIKE_DESC_VIEW').setValue(A350Map.DISLIKE_DESC || '');
			$('SPC_DESC_VIEW').setValue(A350Map.SPC_DESC || '');
		},
		<%--產生對應下拉選單--%>
		dropDownList1 : function(sn ,status){
			$('SPC_FACILITY_' + sn).options.length = 0;
			$('SPC_EFFECT_' + sn).options.length = 0;
			if(status == 'B'){
				for (key in DISLIKE_FACILITY_LIST){
					$('SPC_FACILITY_' + sn).add(new Option(DISLIKE_FACILITY_LIST[key], key));
				}
				<%--for(key in DISLIKE_EFFECT_LIST){
					$('SPC_EFFECT_' + sn).add(new Option(DISLIKE_EFFECT_LIST[key], key));
				}--%>
			}else{
				for (key in SPC_KD_GOOD_LIST){
					$('SPC_FACILITY_' + sn).add(new Option(SPC_KD_GOOD_LIST[key], key));
				}
			}
			for(key in DISLIKE_EFFECT_LIST){
				$('SPC_EFFECT_' + sn).add(new Option(DISLIKE_EFFECT_LIST[key], key));
			}
			
		},
		<%--檢核中文長度--%>		
		getChtLength : function(str){
		    if(!str){
		    	return 0;
		    }
		    if(window.charCountsByte == '2'){
		    	<%--BIG5--%>
		    	var arr = str.match(/[^\x00-\xff]/ig);
		        return arr == null ? str.length : str.length + arr.length;
		    }
		    <%--UTF8--%>
		    var m = encodeURIComponent(str).match(/%[89ABab]/g);
		   	return str.length + (m ? m.length : 0);
		},
		<%--環境設施清單點選後會展開--%>		
		doShowdiv_Grid : function(){
			if($('div_Grid').style.display != 'none'){
				$('div_Grid').hide();
			}else{
				$('div_Grid').show();
			}			
		}
	}

	return {
		initApp : function() {		
			PageUI.createPageWithAllBodySubElement(
					'DSA33304',
					'鑑價作業',
					'環境資料',
					'',
					true
				);
			var SPC_KIND_LIST = <c:out value = '${SPC_KIND_LIST}' default = '[]' escapeXml = "false"/>;
			var A350Map = <c:out value = '${A350Map}' default = '{}' escapeXml = "false"/>;

			<%-- TableUI--%>
			grid1 = new TableUI(                         
				{                   				
					table: $('grid1'),
					pageSize:0, 
					column:[           						
						{ header: '設施種類', key: 'SPC_KIND' , attrs : { Width : '10%'},
							render: function( record , value ,sn ){
								var SELECT1 = new Element('SELECT', {'id' : 'SPC_KIND_' + sn });
								if(SPC_KIND_LIST && SPC_KIND_LIST.length != 0){
									for (key in SPC_KIND_LIST){
										SELECT1.add(new Option(SPC_KIND_LIST[key], key));
									}
									SELECT1.value = record.SPC_KIND;
								}
								<%--註冊事件--%>
								SELECT1.observe('change',function(){
									var status = $(this).value;
									record.SPC_KIND = status;
									actions.dropDownList1(sn, status);
								});
								return SELECT1;
							}
						},
						{ header: '名稱', key: 'SPC_NAME', attrs : { Width : '25%'},
							input:{	type:"text" , 'className' : 'required validLength100', 'size':'20' }
						},
						{ header: '類別', key: 'SPC_FACILITY', attrs : { Width : '25%'},
							render: function( record , value , sn){
								var SELECT2 = new Element('SELECT',{'id' : 'SPC_FACILITY_' + sn});
								//若設施種類 = 嫌惡設施
								if(record.SPC_KIND){
									if(record.SPC_KIND == 'B'){ 
										if(DISLIKE_FACILITY_LIST && DISLIKE_FACILITY_LIST.length != 0){
											for (key in DISLIKE_FACILITY_LIST){
												SELECT2.add(new Option(DISLIKE_FACILITY_LIST[key], key));
											}
										}
									}else{
										if(SPC_KD_GOOD_LIST && SPC_KD_GOOD_LIST.length != 0){
											for (key in SPC_KD_GOOD_LIST){
												SELECT2.add(new Option(SPC_KD_GOOD_LIST[key], key));
											}
										}
									}
									SELECT2.value = record.SPC_FACILITY;
								}
								

								<%--註冊事件--%>
								SELECT2.observe('change',function(){
									record.SPC_FACILITY = $(this).value;
								});
								return SELECT2;
							}
						},
						{ header: '距離(公尺)', key: 'SPC_DISTANCE', attrs : { Width : '20%'},
							input:{	type:"text" , 'className' : 'required validate-positive-number checkNumeralFormat', 'size':'10' }
						},
						{ header: '影響', key: 'SPC_EFFECT' ,attrs : { Width : '10%'},
							render: function( record , value , sn){
								var SELECT3 = new Element('SELECT', {'id' : 'SPC_EFFECT_' + sn });
								<%--若設施種類 = 嫌惡設施，才產生影響下拉選單--%>
								<%--if(record.SPC_KIND == 'B'){ 
									if(DISLIKE_EFFECT_LIST && DISLIKE_EFFECT_LIST.length != 0){
										for (key in DISLIKE_EFFECT_LIST){
											SELECT3.add(new Option(DISLIKE_EFFECT_LIST[key], key));
										}
										SELECT3.value = record.SPC_EFFECT;
									}
								}else{
									record.SPC_EFFECT = '';
								}--%>
								if(DISLIKE_EFFECT_LIST && DISLIKE_EFFECT_LIST.length != 0){
									for (key in DISLIKE_EFFECT_LIST){
										SELECT3.add(new Option(DISLIKE_EFFECT_LIST[key], key));
									}
									SELECT3.value = record.SPC_EFFECT;
								}

								<%--註冊事件--%>
								SELECT3.observe('change',function(){
									record.SPC_EFFECT = $(this).value;
								});
								return SELECT3;
							}
						},
						{ header: '編輯', key: '' ,attrs : { Width : '10%'},
							input:{
								type:"button" ,
								text:"刪除",
		                        action:function( node , dataObj , value){ 	
									grid1.deleteRecords(dataObj[0]);		
								}
							}

						}	
					]					
				}                 
			);
			
			//註冊DOM物件
			$('METRO').observe('change',function(){
				actions.setData($('METRO').options[$('METRO').selectedIndex].text, 'BUILD_LINE', $F('METRO'),'STATION','BUILD_STATION');
			});
			$('METRO1').observe('change',function(){
				actions.setData($('METRO1').options[$('METRO1').selectedIndex].text, 'ROUND_LINE', $F('METRO1'),'STATION1','ROUND_STATION');
			});
			$('STATION').observe('change',function(){
				actions.setStationData($('STATION').options[$('STATION').selectedIndex].text, 'BUILD_STATION' ,$F('STATION'));
			});
			$('STATION1').observe('change',function(){
				actions.setStationData($('STATION1').options[$('STATION1').selectedIndex].text, 'ROUND_STATION' ,$F('STATION1'));
			});
			$("BTN_INSERT").observe("click", buttons.doInsert );
			$("BTN_COMFIRM").observe("click", buttons.doConfirm );
			$("BTN_MODIFY").observe("click", buttons.doModify );				

			grid1.load(<c:out value = '${A353_List}' default = '[]' escapeXml = "false"/>);
			$("A_div_Grid").observe("click", actions.doShowdiv_Grid );
			$("btn_Get_A353List_VIEW").observe("click", buttons.getA353List );//環域分析(受編)
			$("btn_Get_A353ListNew_VIEW").observe("click", buttons.getA353ListNew );//環域分析(社區)
			actions.setData2(A350Map);
			
			<%-- [20221215] --%>
			<c:if test="${BTN_STATUS ne '1'}">
				$$('input[type="button"]', 'button[type="button"]').each(function(btn) {
					btn.disable();
				});
			</c:if>

			initValidation();	
			displayMessage();				
			PageUI.resize();	
		}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr class=tbYellow0 align="center">
				<td colspan="2">
					<strong>區域環境</strong>
					<button id="BTN_MODIFY" name="BTN_MODIFY" type="button" class="button">修改</button>
				</td>
			</tr>
			<tr align="left">
				<td class="tbYellow" width="10%">
					嫌惡設施
				</td>	
				<td class="tbYellow2">
					<textarea rows=3 cols=80 id="DISLIKE_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr align="left">
				<td class="tbYellow" width="10%">
					環境設施
				</td>	
				<td class="tbYellow2">
					<textarea rows=3 cols=80 id="SPC_DESC_VIEW" class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>
			<tr align="left">
				<td class="tbYellow" rowspan="2" width="10%">
					捷運說明
				</td>
				<td class="tbYellow2">屬
					<select id="METRO" name = "METRO">				
						<option value="">選捷運線別</option>	
						<c:forEach items="${METRO_LIST}" var="row">
							<option value="${row.l_SEQ}"/>${row.l_NAME}</option>						
						</c:forEach>							
					</select>
					<input type="text" name="BUILD_LINE" id='BUILD_LINE' size="20" maxlength="20">
					<select id="STATION" name = "STATION">				
						<option value="">選站名</option>
					</select>
					<input type="text" name="BUILD_STATION" id='BUILD_STATION' size="20" maxlength="20">
					之捷運共構產品
				</td>	
			</tr>
			<tr align="left">
				<td class="tbYellow2">屬
					<select id="METRO1" name = "METRO1">				
						<option value="">選捷運線別</option>
						<c:forEach items="${METRO_LIST}" var="row">
							<option value="${row.l_SEQ}"/>${row.l_NAME}</option>						
						</c:forEach>							
					</select>
					<input type="text" name="ROUND_LINE" id='ROUND_LINE' size="20" maxlength="20">
					<select id="STATION1" name = "STATION1">				
						<option value="">選站名</option>
					</select>
					<input type="text" name="ROUND_STATION" id='ROUND_STATION' size="20" maxlength="20">
					<input type="text" name="ROUND_EXIT" id='ROUND_EXIT' size="2" maxlength="2">
					號出口，為圓心
					<select id="ROUND_DISTANCE" name = "ROUND_DISTANCE">				
						<c:forEach items="${ROUND_DISTANCE_LIST}" var="row">
							<option value="${row.key}"/>${row.value}</option>						
						</c:forEach>							
					</select>
					之建物
				</td>
			</tr>
		</table>
	</form>	
	<form id="form2" name="form2" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "tableB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr class=tbYellow0 align="center">
				<td>
					<a href="#A_div_Grid" id="A_div_Grid"><strong>環境設施清單</strong></a>
					<button id="BTN_INSERT" name="BTN_INSERT" type="button" class="button">新增</button>
					<button id="BTN_COMFIRM" name="BTN_COMFIRM" type="button" class="button">(4)儲存</button>
					<button id="btn_Get_A353ListNew_VIEW" name="btn_Get_A353ListNew_VIEW" type="button" class="button">(3)環域分析</button>
					<div id="UPDATE_DATE" datatype="ROCDate" style="float:right">資料更新日期：${UPDATE_DATE}</div>
				</td>
			</tr>
		</table>
		<div id="div_Grid" style="overflow-y:auto; overflow-x:hidden; display:none;">
			<table id = "tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
				<tr>
					<td class="tbYellow" width="10%" align="left">
						<span>受理編號</span>	
					</td>
					<td class="tbYellow2">
						<input name="APPLY_ID" id="APPLY_ID" type="text" class="textBox2" maxlength="11">
					</td>
					<td class="tbYellow2" width="50%">
						<input id="btn_Get_A353List_VIEW" name="btn_Get_A353List_VIEW" type="button" class="button" value="環域分析">			
					</td>
				</tr>
			</table>
		</div>
		<table id='grid1' class='grid'></table>
	</form>
</body>
</html>