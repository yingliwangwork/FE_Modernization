<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->


<!--
程式：DSC80300.jsp
功能：擔保地址變更  
作者：溫子?
完成：2013/06/

[20230317] 修改程式  楊青峰
難字調整
 -->
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>

<%-- [20230317] --%>
<style type="text/css">
	@font-face {
		font-family: 'EUDC';
		src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
	         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
	      font-weight: normal;
	      font-style: normal
	}
</style>
 
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<!--自行定義的javaScript-->		
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/validation.js'></script>   <%-- 檢核用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	   <%-- 地址用 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/validation.js'></script>   <%-- 檢核地址用 --%>

<script type='text/javascript'>
Event.observe(window, 'load', new DSC80300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSC80300(){
var grid;
var NEW_GAGE_ADDR;
var SPEC_AREA_List={};
var rtnMap;//查詢出來的地址
var query_LOAN_ID;
var DATA_MAP1_OLD;
var delete_OWNER_CNT;
function initValidation(){		
			Validation.addAllThese([
				['validateAddress', '新擔保品地址有誤', function validateAddress(addr) {
					var isCounty=0,isCity=0,isVillage=0,isArea=0,isRoad=0,isNo=0;
					var intError=0;
					for (var j=0 ; j < addr.length ; j++)
					{
						isCounty+=addr.charAt(j)=="縣" ? 1:0;
						isCity+=addr.charAt(j)=="市" ? 1:0;
						isVillage+=addr.charAt(j)=="鄉" ? 1:0;
						isVillage+=addr.charAt(j)=="鎮" ? 1:0;
						isVillage+=addr.charAt(j)=="市" ? 1:0;
						/*因有些地址還是沒有村里路街巷，
						isRoad+=s.charAt(j)=="村" ? 1:0;
						isRoad+=s.charAt(j)=="里" ? 1:0;
						isRoad+=s.charAt(j)=="路" ? 1:0;
						isRoad+=s.charAt(j)=="街" ? 1:0;
						isRoad+=s.charAt(j)=="巷" ? 1:0;
						*/
						isNo+=addr.charAt(j)=="號" ? 1:0;
					}
					//有縣就有鄉鎮市或只有直轄市
					if (isCounty>0){if(isVillage<1) intError++;}
					else {if(isCity<1) intError++;}
					//if (isRoad<1){ intError++;}
					if (isNo<1) { intError++;}
					return intError == 0;
				}],
				['validateRocIDAndUniSN', '所有權人ID必須為中華民國身份證字號或統一編號', function validateRocAndUniId(v) {					
					return validation.checkROCID( v ) || validation.checkUniSN( v );
				}]
			]);
			//查詢用檢核
			valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid1.define( "required" , { id: "BUILD_NO1" , errMsg:"請輸入地(建)號1" } );			
			valid1.define( "required" , { id: "BUILD_NO2" , errMsg:"請輸入地(建)號2" } );
			valid1.define( "validate-ROCDate" , { id: "FINISH_DATE" , errMsg:"請輸入正確的民國日期格式" } );
			valid1.define( "required" , { id: "FINISH_DATE" , errMsg:"請輸入建築完成日期" } );
			valid1.define( "required" , { id: "NAME" , errMsg:"請輸入所有權人姓名" } );
			valid1.define( "required" , { id: "ID" , errMsg:"請輸入所有權人ID" } );
			valid1.define( "validate-ROCDate" , { id: "BIRTHDAY" , errMsg:"請輸入正確的民國日期格式" } );
			valid1.define( "required" , { id: "BIRTHDAY" , errMsg:"請輸入所有權人生日" } );
			valid1.define( "required" , { id: "HOLD_BASE" , errMsg:"請輸入持份" } );
			valid1.define( "required" , { id: "HOLD_UP" , errMsg:"請輸入持份" } );
			valid1.define( "required" , { id: "MEASURE" , errMsg:"請輸入面積" } );
			valid1.define( "required" , { id: "PARK_SPACE" , errMsg:"請輸入單獨登記車位面積" } );
			valid1.define('validate-selection' , [{ id : "OWN_KIND" , errMsg:"請選擇所有權類別"}] );
			
			valid2 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid2.define( "validateRocIDAndUniSN" , { id: "ID" , errMsg:"身份證字號格式錯誤" } );	
			
			
			valid3 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});
			valid3.define( "required" , { id: "NEW_GAGE_ZIP" , errMsg:"請輸入新擔保品地址" } );
			valid3.define( "required" , { id: "NEW_AREA_CODE" , errMsg:"請輸入新擔保品區域代碼" } );	
			valid3.define( "required" , { id: "NEW_AREA_CODE_930318" , errMsg:"請輸入新承作區別" } );		
			valid3.define( "validateAddress" , { id: "NEW_GAGE_ADDR_INPUT_ADDR"} );
			
		}
//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSC8_0300/" + actionName,
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
var buttons={
	doshow :function( node , boxStatus , records ) {
		valid1.reset();
		valid2.reset();
		valid3.reset();
		
		$$('.areaC').each(function(ele){
				//將資料帶入下方
				var id = ele.id;
				ele.value=records[0][id];
			}
		);
		
		
		//取TABLE UI 點選的資料
		DATA_MAP1_OLD={
			 OLD_BUILD_NO1: records[0].BUILD_NO1
			,OLD_BUILD_NO2: records[0].BUILD_NO2
			,OLD_OWN_KIND: records[0].OWN_KIND
			,OLD_FINISH_DATE: records[0].FINISH_DATE
			,OLD_NAME: records[0].NAME
			,OLD_ID: records[0].ID
			,OLD_BIRTHDAY: records[0].BIRTHDAY
			,OLD_HOLD_BASE: records[0].HOLD_BASE
			,OLD_HOLD_UP: records[0].HOLD_UP
			,OLD_MEASURE: records[0].MEASURE
			,OLD_PARK_SPACE: records[0].PARK_SPACE
			,OLD_LOAN_ID: records[0].LOAN_ID
			,OLD_APPLY_ID: records[0].APPLY_ID
		}
		delete_OWNER_CNT=records[0].OWNER_CNT;
		
	}
	,doQuery :function(){
	
		valid1.reset();
		valid2.reset();
		valid3.reset();
		
		if(!$F('LOAN_ID_Q')){
			alert("請輸入貸款帳號");
			return;
		}
		
		query_LOAN_ID=$F('LOAN_ID_Q');
		ajaxPost( 'query', {LOAN_ID : query_LOAN_ID}
					,function(resp){
						var rtnList=resp.rtnList;
						
						if(rtnList.length > 0) {
							$('APPLY_ID_Q').value=rtnList[0]['APPLY_ID'];
							grid.load(rtnList);
						}else{
							grid.load([]);
							$('APPLY_ID_Q').value='';
						}
						$$('.areaC').each(function(ele){								
								ele.value='';
							}
						);
						NEW_GAGE_ADDR.setINPUT_ADDR('');
						rtnMap=resp.resultMap;
						$$('.class1').each(function(ele){
							var id = ele.id;
							ele.value=rtnMap[id] || '';
						});
						
						$('NEW_GAGE_ZIP').value = $F('GAGE_ZIP');
						$('NEW_AREA_CODE').value = $F('AREA_CODE');
						$('NEW_AREA_CODE_930318').value = $F('AREA_CODE_930318');
						$('BTN_INSERT').enable();
						$('BTN_UPDATE').enable();
						$('BTN_DELETE').enable();
						$('BTN_CHANGE').enable();
					},function(resp){
							grid.load([]);
							$('APPLY_ID_Q').value='';
							$$('.class1').each(function(ele){
								ele.value='';
							});
							$$('.areaC').each(function(ele){																	
									ele.value='';
								}
							);
							$('BTN_INSERT').disable();
							$('BTN_UPDATE').disable();
							$('BTN_DELETE').disable();
							$('BTN_CHANGE').disable();
					}
				);
	}
	,doInsert : function (){
		valid3.reset();
		if(!valid1.validate()){
			return;
		}
		var LOAN_ID=$F('LOAN_ID_Q');
		if(LOAN_ID.length!=10){
			alert("貸款帳號長度不對!!");
			return;
		}		
		if(LOAN_ID!=query_LOAN_ID){
			alert("查詢的"+query_LOAN_ID+"與輸入"+LOAN_ID+"的不符合，請檢查!!");
			return;
		}
		if(!valid2.validate()){//身分證字號
			return;
		}
		if($F('OWN_KIND')==1){
			if($F('BUILD_NO1').length!=5||$F('BUILD_NO2').length!=3){
				alert("建號一長度五碼，建號二長度三碼，請確認！");
				return ;
			}
		}else if($F('OWN_KIND')==2){
			if($F('BUILD_NO1').length!=4||$F('BUILD_NO2').length!=4){
				alert("建號一、二長度皆為四碼，請確認！");
				return ;
			}
		}
		var DATA_MAP1={};//取C區的資料
			$$('.areaC').each(function(ele){
				var id = ele.id;
				DATA_MAP1[id]=ele.getValue(); //2014-12-11調整取值方式
			});
			
		DATA_MAP1['LOAN_ID']=LOAN_ID;
		DATA_MAP1['APPLY_ID']=$F('APPLY_ID_Q');
		
		ajaxPost( 'insert', {DATA_MAP1 : Object.toJSON(DATA_MAP1),query_LOAN_ID:LOAN_ID}
					,function(resp){
						
						valid1.reset();
						valid2.reset();
						valid3.reset();
						grid.load(resp.rtnList);
						rtnMap=resp.resultMap;
						$$('.class1').each(function(ele){
						var id = ele.id;
						ele.value=rtnMap[id] || '';
					});
					}
				);
	
	}
	,doChange : function(){//地址修改
		valid2.reset();
		valid1.reset();
		
		if(rtnMap['GAGE_TYPE']=='1'){
			if(!valid3.validate()){
				return;
			}
		}
		
		var INPUT_ADDR=NEW_GAGE_ADDR.getINPUT_ADDR();
		if(!INPUT_ADDR){
			alert("請輸入新擔保品地址");
			return;
		}
		if(validation.hasHalfType(INPUT_ADDR)){
			alert("地址需輸入必須是中文全形");
			return;
		}
		
		var LOAN_ID=$F('LOAN_ID_Q');
		if(LOAN_ID.length!=10){
			alert("貸款帳號長度不對!!");
			return;
		}
		if(LOAN_ID!=query_LOAN_ID){
			alert("欲變更的"+LOAN_ID+"與原先查詢的"+query_LOAN_ID+"的不符合，無法作業!!");
			return;
		}
		var INPUT_ZIPCODE=NEW_GAGE_ADDR.getINPUT_ZIPCODE();
		if($F('SPEC_AREA')=='1'&&INPUT_ZIPCODE!='814'&&INPUT_ZIPCODE!='833'){
			alert('僅鳥松區與仁武區可選擇澄特區!!');
			return;
		}
		
		var DATA_MAP2={
			SPEC_AREA : $F('SPEC_AREA'),
			GAGE_ADDR : INPUT_ADDR,
			GAGE_ZIP : INPUT_ZIPCODE,
			AREA_CODE : $F('NEW_AREA_CODE'),
			AREA_CODE_930318 : $F('NEW_AREA_CODE_930318'),
			LOAN_ID1 : LOAN_ID
		
		}
		ajaxPost( 'change', {DATA_MAP2 : Object.toJSON(DATA_MAP2),query_LOAN_ID:LOAN_ID,DATA_MAP2_OLD:Object.toJSON(rtnMap)}
					,function(resp){
						valid1.reset();
						valid2.reset();
						valid3.reset();
						grid.load(resp.rtnList);
						rtnMap=resp.resultMap;
						$$('.class1').each(function(ele){
							var id = ele.id;
							ele.value=rtnMap[id] || '';
						});
						$('NEW_GAGE_ZIP').value = $('GAGE_ZIP').value;
						$('NEW_AREA_CODE').value = $('AREA_CODE').value;
						$('NEW_AREA_CODE_930318').value = $('AREA_CODE_930318').value;
						
					}
				);
	}
	,doDelete : function(){//刪除
		valid2.reset();
		valid3.reset();
		if(grid.getCheckedRecord().length==0){
			alert("請先點選才能刪除擔保品所有權人");
			return;
		}
		if(!valid1.validate()){
			return;
		}
		if(!confirm('確定要刪除該筆資料？')){
			return;
		}
		if(delete_OWNER_CNT=='1'&&!confirm('擔保品所有權人僅設定此一位，確定要刪除？')){
			return;
		}
		var LOAN_ID=$F('LOAN_ID_Q');
		if(LOAN_ID.length!=10){
			alert("貸款帳號長度不對!!");
			return;
		}
		if(LOAN_ID!=query_LOAN_ID){
			alert("查詢的"+query_LOAN_ID+"與輸入"+LOAN_ID+"的不符合，請檢查!!");
			return;
		}
		var DATA_MAP1={};//取C區的資料
			$$('.areaC').each(function(ele){
				var id = ele.id;
				DATA_MAP1[id]=ele.value;
			});
		DATA_MAP1['LOAN_ID']=LOAN_ID;
		DATA_MAP1['APPLY_ID']=$F('APPLY_ID_Q');
		ajaxPost( 'delete', {DATA_MAP1 : Object.toJSON(DATA_MAP1),query_LOAN_ID:LOAN_ID,DATA_MAP1_OLD:Object.toJSON(DATA_MAP1_OLD)}
					,function(resp){
						grid.load(resp.rtnList);
						rtnMap=resp.resultMap;
						$$('.class1').each(function(ele){
						var id = ele.id;
						ele.value=rtnMap[id] || '';
					});
					}
				);
	}
	,doUpdate :function(){
		valid3.reset();
		if(grid.getCheckedRecord().length==0){
			alert("請先點選才能變更擔保品所有權人");
			return;
		}
		if(!valid1.validate()){
			return;
		}
		var LOAN_ID=$F('LOAN_ID_Q');
		if(LOAN_ID.length!=10){
			alert("貸款帳號長度不對!!");
			return;
		}
		if(LOAN_ID!=query_LOAN_ID){
			alert("查詢的"+query_LOAN_ID+"與輸入"+LOAN_ID+"的不符合，請檢查!!");
			return;
		}
		if(!valid2.validate()){//身分證字號
			return;
		}
		if($F('OWN_KIND')==1){
			if($F('BUILD_NO1').length!=5||$F('BUILD_NO2').length!=3){
				alert("建號一長度五碼，建號二長度三碼，請確認！");
				return ;
			}
		}else if($F('OWN_KIND')==2){
			if($F('BUILD_NO1').length!=4||$F('BUILD_NO2').length!=4){
				alert("建號一、二長度皆為四碼，請確認！");
				return ;
			}
		}
		var DATA_MAP1={};//取C區的資料
			$$('.areaC').each(function(ele){
				var id = ele.id;
				//DATA_MAP1[id]=ele.value;
				DATA_MAP1[id]=ele.getValue();
			});
		DATA_MAP1['LOAN_ID']=LOAN_ID;
		DATA_MAP1['APPLY_ID']=$F('APPLY_ID_Q');
		if(DATA_MAP1['ID']!=DATA_MAP1_OLD['OLD_ID']){
			alert("變更所有權人的ID有誤，請使用原ID作業，謝謝！");
			return;
		}
		if(DATA_MAP1['OWN_KIND']!=DATA_MAP1_OLD['OLD_OWN_KIND']){
			alert("要修改之所有權類別與資料原始類別不符，請確認！");
			return;
		}
		ajaxPost( 'update', {DATA_MAP1 : Object.toJSON(DATA_MAP1),query_LOAN_ID:LOAN_ID,DATA_MAP1_OLD:Object.toJSON(DATA_MAP1_OLD)}
					,function(resp){
						valid1.reset();
						valid2.reset();
						valid3.reset();
						grid.load(resp.rtnList);
						rtnMap=resp.resultMap;
						$$('.class1').each(function(ele){
						var id = ele.id;
						ele.value=rtnMap[id] || '';
					});
					}
				);
	
	}
}

	return {
		initApp : function() {
				
				PageUI.createPageWithAllBodySubElement('DSC80300', '變更作業', '擔保資料變更');
								grid = new TableUI(
				{table: $("grid"), pageSize : 20, allSortable: false, overDiv:true, title:"擔保品所有權人變更",
				autoCheckBox:{
							text:'請選擇', 
							type:'radio',
							action:buttons.doshow,
							isSelectAll:false
				},
				<%-- [20230317] --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column:[			
					{header:"所有權類別", key:"OWN_KIND_NM"},
					{header:"地(建)號",key:"BUILD_NO1",
						render : function(rec ,val ){
								return val+rec.BUILD_NO2;
						}
					},
					{header:"所有權人姓名",key:"NAME"},
					{header:"持份面積",key:"HOLD_MEASURE"},
					{header:"客戶主檔的生日",key:"BIRTHDAY",
						render : function(rec ,val ){
						     if(val){
						     	if(val.length==6){
								return  val.substring(0,2)+'.'+val.substring(2,4)+'.'+val.substring(4,6);
							}else if(val.length==7){
								return  val.substring(0,3)+'.'+val.substring(3,5)+'.'+val.substring(5,7);
							}else{
								return val;
							}			 
						     }
						     return "";	
						}
					},
					{header:"地(建)號1",key:"BUILD_NO1"},
					{header:"地(建)號2",key:"BUILD_NO2"}
				]
				});
				$('BTN_INSERT').disable();
				$('BTN_UPDATE').disable();
				$('BTN_DELETE').disable();
				$('BTN_CHANGE').disable();
				$('BTN_QUERY').observe('click',buttons.doQuery);
				$('BTN_CHANGE').observe('click',buttons.doChange);//地址變更
				$('BTN_INSERT').observe('click',buttons.doInsert);
				$('BTN_UPDATE').observe('click',buttons.doUpdate);
				$('BTN_DELETE').observe('click',buttons.doDelete);
				var select = new Element('select',{id:'SPEC_AREA'});
				<c:forEach var="map" items="${SPEC_AREA_List}">
				 select.add(new Option("${map.value}","${map.key}"));
				</c:forEach>
				//產生下拉選單群
				NEW_GAGE_ADDR = new DSZ01000($('NEW_GAGE_ADDR'), '1');	
				var selects = $('NEW_GAGE_ADDR').select('select');
				Element.insert( selects[selects.length-1] , { after : select } );
				
				//特別處理民國日期的部份
				$('BIRTHDAY').observe('blur', function(ele){
					ele.value = Date.toInputROC(ele.value, "");
				
				});
				autoFormatToNumber();
				
				$('OWN_KIND').value='1';
				initValidation();
				
				//更新新擔保品區域代碼
				$('NEW_GAGE_ADDR_TOWN_NAME').observe('change', function(ele){
					setTimeout(function(){$('NEW_GAGE_ZIP').value = $('NEW_GAGE_ADDR_span_INPUT_ZIPCODE').innerHTML;}, 10);
				});
				//先把畫面區塊都調整到位再顯示訊息
				fix();	
				//初始頁面alert訊息用	
				displayMessage();
			}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="5%">貸款帳號</td>
			<td class="tbYellow2" width="4%">
				<input id="LOAN_ID_Q" type="text" class="textBox2" onblur="this.value = this.value.toUpperCase()"  maxlength="10"/>
			</td>
			<td class="tbYellow" width="5%">受理編號</td>
			<td class="tbYellow2" width="4%">
				<input id="APPLY_ID_Q" type="text" class="textBox2" readonly/>
			</td>
			<td class="tbYellow2" width="8%">
				<input id="BTN_QUERY" type="button" value="查詢" class="button" >	
			</td>
		</tr>
		<tr>
			<td class="tbYellow2" align='center' colspan='6'>
				<input id="BTN_INSERT" type="button" value="新增" class="button" >
				<input id="BTN_UPDATE" type="button" value="變更" class="button" >
				<input id="BTN_DELETE" type="button" value="刪除" class="button" >
			</td>
		</tr>
	</table>
	<table id = "grid" ></table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow" width="5%" align='center'>地(建)號</td>
			<td class="tbYellow2" width="10%">
				<input id="BUILD_NO1" type="text" class="areaC" size='15' maxlength="5"/>─
				<input id="BUILD_NO2" type="text" class="areaC" size='15' maxlength="5"/>
			</td>
			<td class="tbYellow" width="5%" align='center'>所有權類別</td>
			<td class="tbYellow2" width="8%" >
				<select id="OWN_KIND" class="areaC">
						<option value="">請選擇</option>
							<c:forEach var="map" items="${OWN_KIND_List}">
									<option value="${map.key}">${map.value}</option>
							</c:forEach>
				</select> 
			</td>
			<td class="tbYellow" width="5%" align='center'>建築完成日期/移轉年月</td>
			<td class="tbYellow2" width="10%">
				<input id="FINISH_DATE" datatype="ROCDate"type="text" class="areaC" size='15' maxlength="7"/>
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" onclick="getCalendarFor($('FINISH_DATE'))">
			</td>
		</tr
		<tr>
			<td class="tbYellow" width="5%" align='center'>所有權人姓名</td>
			<td class="tbYellow2" width="4%">
				<input id="NAME" type="text" class="areaC" size='15' alt="ch"/> <%-- [20230317] --%>
			</td>
			<td class="tbYellow" width="5%" align='center'>所有權人ID</td>
			<td class="tbYellow2" width="4%">
				<input id="ID" type="text" class="areaC" size='15' onblur="this.value = this.value.toUpperCase()" maxlength="10"/>
			</td>
			<td class="tbYellow" width="5%" align='center'>所有權人生日</td>
			<td class="tbYellow2" width="4%">
				<input id="BIRTHDAY" datatype="ROCDate"type="text" class="areaC" size='15' maxlength="7"/>
				<img id="calImg" src="<%=imageBase%>/CM/calendar.gif" onclick="getCalendarFor($('BIRTHDAY'))">
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" align='center'>持份</td>
			<td class="tbYellow2" width="4%">
				<input id="HOLD_BASE" type="text" datatype="number" class="areaC validate-number" size='15' maxlength="15"/>分之
				<input id="HOLD_UP" type="text" datatype="number" class="areaC validate-number" size='15' maxlength="15"/>
			</td>
			<td class="tbYellow" width="5%" align='center'>面積</td>
			<td class="tbYellow2" width="4%">
				<input id="MEASURE" type="text" datatype="number" class="areaC validate-number" size='15' maxlength="15"/>平方公尺
			</td>
			<td class="tbYellow" width="5%" align='center'>單獨登記車位面積</td>
			<td class="tbYellow2" width="4%">
				<input id="PARK_SPACE" type="text" datatype="number" class="areaC validate-number" size='15' maxlength="15"/>平方公尺
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
		<tr>
			<td class="tbYellow0" width="5%" align='center' colspan='6'>擔保品位址變更</td>
		</tr>
		<tr>
			<td class="tbYellow2" width="8%" align='center' colspan='6'>
				<input id="BTN_CHANGE" type="button" value="變更" class="button" >	
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" align='center'>姓名</td>
			<td class="tbYellow2" width="4%">
			<input id="BORROW_NAME" type="text" class="class1" size='15' readonly alt="ch" /> <%-- [20230317] --%>
			</td>
			<td class="tbYellow" width="5%" align='center'>原擔保品區域代碼</td>
			<td class="tbYellow2" width="4%">
			<input id="GAGE_ZIP" type="text" class="class1"  size='15' readonly/>
			</td>
			<td class="tbYellow" width="5%" align='center'>原地區代號</td>
			<td class="tbYellow2" width="4%">
			<input id="AREA_CODE" type="text" class="class1"  size='15' v/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" align='center'>原擔保品地址</td>
			<td class="tbYellow2" width="4%">
			<input id="GAGE_ADDR" type="text" class="class1"  size='60' readonly alt="ch" /> <%-- [20230317] --%>
			</td>
			<td class="tbYellow" width="5%" align='center'>原承作區別</td>
			<td class="tbYellow2" width="4%" colspan='3'>
			<input id="AREA_CODE_930318" type="text" class="class1"  size='15' readonly/>
			</td>
			<input id="LOAN_ID" type = 'hidden' class="class1" />
			
		</tr>
		<tr>
			<td class="tbYellow2" width="5%" align='center' colspan='6'>變更後地址</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" align='center'>新擔保品區域代碼</td>
			<td class="tbYellow2" width="4%">
			<input id="NEW_GAGE_ZIP" type="text" class="textBox2"  size='15' disabled/>
			</td>
			<td class="tbYellow" width="5%" align='center'>新地區代號</td>
			<td class="tbYellow2" width="4%">
			<input id="NEW_AREA_CODE" type="text" class="textBox2" size='15' disabled/>
			</td>
			<td class="tbYellow" width="5%" align='center'>新承作區別</td>
			<td class="tbYellow2" width="4%">
			<input id="NEW_AREA_CODE_930318" type="text" class="textBox2"  size='15' disabled/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="5%" align='center' rowspan='2'>新擔保品地址</td>
			<td class="tbYellow2" width ="4%" id ="NEW_GAGE_ADDR" colspan='5'></td>
		</tr>
	</table>
</form>
</body>
</html>