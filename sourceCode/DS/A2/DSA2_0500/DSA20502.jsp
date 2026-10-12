<%@ page language="java" contentType="text/html; charset=BIG5"
	pageEncoding="BIG5"%>
<!-- 
程式功能:財報輸入作業
程式名稱:DSA2_0502
作者:邱建禕
完成:2020/09/14	
 -->
<!DOCTYPE html>
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<meta charset="BIG5">
<title>財報輸入作業</title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script><!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script><!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script><!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script><!--判斷isRocDate用-->
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script>

<script type="text/javascript">
Event.observe(window, 'load', new DSA20502().initApp);
function DSA20502(){
	var valid;
	var reQueryMap = {};
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0502/');
	var selectOptions = { //下拉選單選項
		'ACNT_OPINION' : {}
	}
	
	function initValidation(){
		valid = new Validation('form1', {useTitles:false});
	}
	
	function defineValid(actionType){
		valid.reset();
		valid.clear();
		if('save'==actionType){
			valid.define( 'required' , [{ id : 'APPLY_ID' , errMsg : '受理編號不可為空'}] );	
			valid.define( 'required' , [{ id : 'ID' , errMsg : '統一編號不可為空'}] );	
			valid.define( 'required' , [{ id : 'CURR' , errMsg : '幣別不可為空'}] );	
			valid.define( 'required' , [{ id : 'UNIT' , errMsg : '單位不可為空'}] );	
		}
	}
	
	var actions = {
			<%-- 查詢取得受理編號 --%>
			getQueryParams : function(){
				var reqMap = {
					'APPLY_ID' : $F('APPLY_ID'),
					'ID' : $F('ID')
				};
				return reqMap;
			},
			getYear : function(date){
				return date.substring(0,4);
			},
			setValue : function(a010Map){
				if(a010Map){
					$('APPLY_ID').setValue(a010Map['APPLY_ID']||'');
					$('ID').setValue(a010Map['BORROW_ID']||'');
					$('APPLY_PROCESS').setValue(a010Map['APPLY_PROCESS']||'');
				}
			},
			btnControl : function(){
				if(!$F('APPLY_ID')){//未輸入受理編號僅提供查詢功能
					$('btnSave').disable();
					$('btnAddYear').disable();
				}else{
					if($F('APPLY_PROCESS') == 90 && false){ //已貸放，覆審階段可修改當年或新增年度  //TODO 覆審導入要加判斷覆審的條件
						$('btnSave').enable();
						$('btnAddYear').enable();
					}else if($F('APPLY_PROCESS') >= 60){ //簽件後不可修改
						$('btnSave').disable();
						$('btnAddYear').disable();
					}else{
						$('btnSave').enable();
						$('btnAddYear').enable();
					}
				}
				
			},
			setGrid : function(rtnList){
				//查詢結果未滿4筆的情況依舊要顯示4筆
				for(var i=rtnList.length;i<3;i++){
					rtnList.push({});
				}
				actions.clearTable();
				
				//顯示table
				$w('tableB tableB_1 tableC tableD tableE').each(function(tableid){
					$(tableid).setAttribute('style','display: "";');
				});
				
				$('dataRecord').setValue(rtnList.length);
				
				actions.genTableB(rtnList);
				actions.genTableCD(rtnList);
				actions.genTableE(rtnList);
				actions.registerLocaleDisplay();
				actions.controlField();
				actions.btnControl();
			},
			disableField : function(i){
				$$('tr.colTr input[rowNo="'+i+'"]','tr.colTr select[rowNo="'+i+'"]','tr.colTr textarea[rowNo="'+i+'"]').each(function(inputEle){
					inputEle.disable();
				});
			},
			controlField : function(){
				var APPLY_PROCESS = $F('APPLY_PROCESS');
				var DATA_YEAR = actions.getYear(getY2KToday());
				var listSize = $F('dataRecord');
				if(APPLY_PROCESS == 90 && false){ //已貸放，覆審階段可修改當年或新增年度  //TODO 覆審導入要加判斷覆審的條件
					for(var i = 0;i<listSize;i++){
						var ACNT_YEAR = $F('ACNT_YEAR_'+i);
						if(ACNT_YEAR){//該列已輸入才要控制
							var mapYear =  actions.getYear(ACNT_YEAR);
							if(mapYear<DATA_YEAR && $F('MONTHS_'+i) >= 12){
								actions.disableField(i);
							}
						}
					}
				}else if(APPLY_PROCESS >= 60){ //簽件後不可修改
					$('btnSave').disable();
					$('btnAddYear').disable();
					$$('tr.colTr input','tr.colTr select','tr.colTr textarea').each(function(ele,sn){
						ele.disable();
					})
				}
			},
			genAddYear : function(){
				if(5==$F('dataRecord')){//最多新增5行
					return;
				}
				
				var saveList = actions.getSaveList(true);
				var lastMap = saveList[saveList.length-1];
				var newMap = {};
				
				newMap['CHG_FIRM_DESC'] = lastMap['CHG_FIRM_DESC'];
				newMap['OPERATE_HYPOTHE_DESC'] = lastMap['OPERATE_HYPOTHE_DESC'];
				newMap['OTHER_MEMO'] = lastMap['OTHER_MEMO'];
				newMap['CURR'] = lastMap['CURR'];
				newMap['UNIT'] = lastMap['UNIT'];
				
				saveList.push(newMap);		
				actions.setGrid(saveList);
				
				if(5==$F('dataRecord')){//最多新增5行
					$('btnAddYear').disable();
				}
			},
			getSaveMap : function(){
				var saveMap = {};
				saveMap['APPLY_ID'] = $F('APPLY_ID');
				saveMap['ID'] = $F('ID');
				return saveMap;
			},
			getSaveList : function(getAll){
				var listSize = $F('dataRecord');
				var saveList = [];
				
				//儲存時，只抓enable的那行
				for ( var i=0; i<listSize; i++ ){
					var map = {};
					$$('tr.colTr input[rowNo="'+i+'"]'+((!getAll)?':enabled':''),'tr.colTr select[rowNo="'+i+'"]'+((!getAll)?':enabled':'')).each(function(elem){
						var name = elem.getAttribute('name');
						if('ACNT_YEAR'==name){
							map['ORG_ACNT_YEAR'] = elem.getAttribute('ACNT_YEAR');
						}
						map[name] = $F(elem.id);
					});
					
					$$('tr.colTr span[rowNo="'+i+'"]').each(function(elem){
						map[elem.getAttribute('name')] = (elem.getAttribute('colValue')||0);
					});
					
					if(map.ACNT_YEAR || getAll){
						//幣別、單位
						map['CURR'] = $F('CURR');
						map['UNIT'] = $F('UNIT');
						saveList.push(map);
					}
				}
				
				//最後一筆抓近三年是否有更換事務所或會計師、近三年是否有繼續經營假設疑慮、其他備註說明
				if(saveList.length>0){
					tmpMap = saveList[saveList.length-1];
					
					$$('tr.colTr textarea'+((!getAll)?':enabled':'')).each(function(elem){
						tmpMap[elem.getAttribute('name')] = $F(elem.id);
					});
				}
				
				return saveList;
			},
			<%-- 清空各欄位td --%>
			clearTable : function(){
				//隱藏table
				$w('tableB tableB_1 tableC tableD tableE').each(function(tableid){
					$(tableid).setAttribute('style','display: none;');
				});
				
				$w('tableB tableC tableD tableE').each(function(tableid){
					$(tableid).select('.colTr','.head_ACNT_YEAR').each(function(tr){
						actions.removeChild(tr.childElements(),false);
					});
					
					$(tableid).select('.sub_head').each(function(tr){
						actions.removeChild(tr.childElements(),true);//delete all
					});
					
					$(tableid).select('.table_head').each(function(tr){
						tr.removeAttribute('colspan');
					});
				});
				
				
				$('tableB_1').select('.colTr').each(function(tr){
					$('CURR').setValue('');
					$('UNIT').setValue('');
				});

			},
			removeChild :function(childArray,delAll){ 
				
				for(var i = 0;i<childArray.length;i++){
					if(i == 0 && delAll == false){//title
						continue;
					}
					childArray[i].remove();
				}
			},
			<%-- 產生各欄位td --%>
			createTD : function(rowNo,colid,val,ACNT_YEAR,setting,elemType,colType){
				if(setting){//有傳入tr的抓tr中設定的
					elemType = setting.getAttribute('elemType');
					colType = setting.getAttribute('colType'); 
				}
				
				var tmptd = new Element("td");
				tmptd.setAttribute("align", "center");
				if (rowNo%2 == 0) {
					tmptd.addClassName("tbBlue2");
				} else {
					tmptd.addClassName("tbBlue3");
				}
				
				var elemid = colid+'_'+rowNo;
				
				var elem = new Element(elemType);
				elem.setAttribute('rowNo',rowNo);
				elem.setAttribute('id',elemid);
				elem.setAttribute('name',colid);
				elem.setAttribute('ACNT_YEAR',ACNT_YEAR||'');
				if('span'==elemType){
					elem.setAttribute('colValue',val||'');
					if('number'==colType||'pctNumber'==colType){
						actions.updateNumberIntoSpan(elem,val,colType);
					}else{
						elem.update(val||'');
					}
				}else if('input'==elemType){
					elem.setAttribute('type','text');
					if(colType){
						elem.setAttribute('colType',colType);
					}
					
					if(setting){
						//欄位大小
						if(setting.getAttribute('colSize')){
							elem.setAttribute('size',setting.getAttribute('colSize'));
						}
						//欄位長度
						if(setting.getAttribute('colMaxlength')){
							elem.setAttribute('maxlength',setting.getAttribute('colMaxlength'));
						}
						//註冊連動事件
						var chgfunc = setting.getAttribute('chgfunc');
						if(chgfunc){
							var chgevent = actions[chgfunc];
							if('function'==typeof chgevent){
								if('number'==colType){
									elem.observe('blur',chgevent);
								}else{
									elem.observe('change',chgevent);
								}
							}
							elem.setAttribute('chgfunc',chgfunc);
						}
					}
					
					elem.setValue(val);
				}else if('select'==elemType){
					elem.insert(new Element('option', {value: ''}).update('請選擇'));
					var optionList = selectOptions[colid];
					for(var key in optionList){
						elem.insert(new Element('option', {value: key}).update(optionList[key]));
					}
					elem.setValue(val);
				}else if('textarea'==elemType){
					elem.cols = 100;
					elem.rows = 3;
					
					if(setting){
						//欄位長度
						if(setting.getAttribute('colSize')){
							elem.setAttribute('colSize',setting.getAttribute('colSize'));
						}
					}
					
					elem.update(val||'');	
				}
				
				tmptd.appendChild(elem);
				
				return tmptd;
			},
			<%-- 連動ACNT_YEAR欄位 --%>
			chgACNT_YEAR : function(event){
				var target = event.target || event.srcElement;
				var index = target.getAttribute('rowNo');
				var val = target.value;
				
				$('tableC_ACNT_YEAR_'+index).update(val);
				$('tableD_ACNT_YEAR_'+index).update(val);
				$('tableE_ACNT_YEAR_'+index).update(val);
			},
			<%-- 連動欄位 --%>
			chgColumns : function(event){
				var target = event.target || event.srcElement;
				var index = target.getAttribute('rowNo');
				
				var PRO_AMT = parseInt($F('PRO_AMT_'+index)||0);
				var OE_AMT = parseInt($F('OE_AMT_'+index)||0);
				var NNOI_AMT = parseInt($F('NNOI_AMT_'+index)||0);
				var TAX_AMT = parseInt($F('TAX_AMT_'+index)||0);
				var OCI_AMT = parseInt($F('OCI_AMT_'+index)||0);
				var INTE_AMT = parseInt($F('INTE_AMT_'+index)||0);
				var DEP_AMT = parseInt($F('DEP_AMT_'+index)||0);
				var AMO_AMT = parseInt($F('AMO_AMT_'+index)||0);
				var CA_AMT = parseInt($F('CA_AMT_'+index)||0);
				var INV_AMT = parseInt($F('INV_AMT_'+index)||0);
				var PRE_AMT = parseInt($F('PRE_AMT_'+index)||0);
				var CASH_AMT = parseInt($F('CASH_AMT_'+index)||0);
				var NCA_AMT = parseInt($F('NCA_AMT_'+index)||0);
				var CL_AMT = parseInt($F('CL_AMT_'+index)||0);
				var NCL_AMT = parseInt($F('NCL_AMT_'+index)||0);
				var CASHO_AMT = parseInt($F('CASHO_AMT_'+index)||0);
				var CASHI_AMT = parseInt($F('CASHI_AMT_'+index)||0);
				var CASHF_AMT = parseInt($F('CASHF_AMT_'+index)||0);

				var OI_AMT = PRO_AMT-OE_AMT;
				var BTAX_AMT = parseInt(OI_AMT||0)+NNOI_AMT;
				var CONT_AMT = parseInt(BTAX_AMT||0)-TAX_AMT;
				var TCI_AMT = parseInt(CONT_AMT||0)+OCI_AMT;
				var QA_AMT = CA_AMT-INV_AMT-PRE_AMT;
				var TOT_ASS_AMT = CA_AMT+NCA_AMT;
				var TOT_LIA_AMT = CL_AMT+NCL_AMT;
				var NCASH_AMT = CASHO_AMT+CASHI_AMT+CASHF_AMT;
				var FCF_AMT = CASHO_AMT+CASHI_AMT;
				var EBITDA_AMT = parseInt(BTAX_AMT||0)+INTE_AMT+DEP_AMT+AMO_AMT;
				
				
				actions.updateNumberIntoSpan($('OI_AMT_'+index),OI_AMT);
				actions.updateNumberIntoSpan($('BTAX_AMT_'+index),BTAX_AMT);
				actions.updateNumberIntoSpan($('CONT_AMT_'+index),CONT_AMT);
				actions.updateNumberIntoSpan($('TCI_AMT_'+index),TCI_AMT);
				actions.updateNumberIntoSpan($('QA_AMT_'+index),QA_AMT);
				actions.updateNumberIntoSpan($('TOT_ASS_AMT_'+index),TOT_ASS_AMT);
				actions.updateNumberIntoSpan($('TOT_LIA_AMT_'+index),TOT_LIA_AMT);
				actions.updateNumberIntoSpan($('NCASH_AMT_'+index),NCASH_AMT);
				actions.updateNumberIntoSpan($('FCF_AMT_'+index),FCF_AMT);
				actions.updateNumberIntoSpan($('EBITDA_AMT_'+index),EBITDA_AMT);
			},
			updateNumberIntoSpan : function(span,val,colType){
				if(!val || val == ''){
					val = 0;
				}
				
				//若顯示欄位(數字或百分比)為負值，以-XX,XXX顯示
				if (val < 0) {
					span.setAttribute('style', 'color:red; font-weight:bold;');
				}else{
					span.removeAttribute('style');
				}
				
				span.setAttribute('colValue',val);
				
				if(val != '無法計算'){
					if(colType && 'pctNumber'==colType){
						val = localeDisplay.formatNumber(val)+'%';
					}else{
						val = localeDisplay.formatNumber(val);
					}
				}
				span.update(val);
			},
			<%-- 產生會計年度結束日顯示欄位 --%>
			createACNT_YEARspan : function(tableid,ACNT_YEAR,rowno,tdwidth,span2){
				
				var tmptd = new Element('td');
				tmptd.setAttribute('align', 'center');
				tmptd.addClassName('tbYellow');
				if(span2){
					tmptd.setAttribute('colspan', '2');
				}
				if(tdwidth){
					tmptd.setAttribute('width', tdwidth+'%');
				}
				
				var tmpspan = new Element('span').update(ACNT_YEAR||'');//=【B區】會計年度結束日 顯示欄位
				tmpspan.setAttribute('id', tableid+'_ACNT_YEAR_'+rowno);
				tmpspan.setAttribute('style','font-weight:bold;');
				tmptd.appendChild(tmpspan);
				
				return tmptd;
			},
			registerLocaleDisplay : function(){
				//註冊日期欄位localedisplay
				$$('tr.colTr input[colType="date"]').each(function(ele){
					localeDisplay.registerToDate(ele.id);
					ele.setValue($F(ele.id));
				});
				
				//註冊數字欄位localedisplay
				$$('tr.colTr input[colType="number"]').each(function(ele){
					localeDisplay.registerToAmount(ele.id);
					ele.setValue($F(ele.id));
				});
				
				
				$$('tr.colTr textarea').each(function(ele){
					InputUtility.lengthLimit.add(ele.id, ele.getAttribute('colSize'), true, "中文或全型算2個字，已輸入{enter}字，尚可輸入{left}字。");
				});
				
			},
			<%-- 產生table B 財報-會計師意見 資料欄位 --%>
			genTableB : function(rtnList){
				$w('tableB tableB_1').each(function(tableid){
					//tr：【B區】財報-會計師意見
					$(tableid).select('.table_head').each(function(td){
						td.setAttribute('colspan', 1+rtnList.length);
					});
					
					//各欄位
					$(tableid).select('.colTr').each(function(tr){
						var colid = tr.getAttribute('colname');
						
						//幣別、單位、近三年是否有更換事務所或會計師、近三年是否有繼續經營假設疑慮、其他備註說明 
						if('CURR_UNIT'==colid||'CHG_FIRM_DESC'==colid||'OPERATE_HYPOTHE_DESC'==colid||'OTHER_MEMO'==colid){
							var latestIndex=0;
							for (var j=0; j<rtnList.length; j++) {
								if(rtnList[j]['ACNT_YEAR']){
									latestIndex = j;
								}else{
									break;
								}
							}
							var latestMap=rtnList[latestIndex]||{};//僅放有輸入過的最後一筆紀錄
							
							if('CURR_UNIT'==colid){//幣別、單位
								$('CURR').setValue(latestMap['CURR']);
								$('UNIT').setValue(latestMap['UNIT']);
							}else {
								var ACNT_YEAR = latestMap['ACNT_YEAR'];
								var val = latestMap[colid];
								
								//rowNo,colid,val,ACNT_YEAR,tr,elemType,colType
								var td = actions.createTD(latestIndex,colid,val,ACNT_YEAR,tr);
								td.setAttribute('colspan', rtnList.length+1);
								tr.appendChild(td);
							}
						}else{
							for (var j=0; j<rtnList.length; j++) {
								var ACNT_YEAR = rtnList[j]['ACNT_YEAR'];
								var val = rtnList[j][colid];
								
								//rowNo,colid,val,ACNT_YEAR,tr
								var td = actions.createTD(j,colid,val,ACNT_YEAR,tr);
								tr.appendChild(td);
							}
						}
					});
				});
			},
			<%-- 產生table C 財報-財報資訊(損益表);table D 財報-財報資訊(資產負債表) 資料欄位 --%>
			genTableCD : function(rtnList){
				$w('tableC tableD').each(function(tableid){
					//tr：【C區】財報-財報資訊、本業、營業外收入及支出;【D區】資產、負債
					$(tableid).select('.table_head').each(function(td){
						td.setAttribute('colspan', 1+(rtnList.length*2));
					});
				
					var tdwidth=(90/rtnList.length);
					for (var i=0; i<rtnList.length; i++) {
					
						$(tableid).select('.head_ACNT_YEAR').each(function(tr){
							
							//tableid,ACNT_YEAR,rowno,tdwidth,span2
							tr.appendChild(actions.createACNT_YEARspan(tableid,rtnList[i].ACNT_YEAR,i,tdwidth,true));
						});
						
						//金額、%
						$(tableid).select('.sub_head').each(function(tr){
							var td_amt = new Element('td');
							var td_pct = new Element('td');
							td_amt.setAttribute('class', 'tbYellow');
							td_amt.setAttribute('align', 'center');
							td_pct.setAttribute('class', 'tbYellow');
							td_pct.setAttribute('align', 'center');
							
							var span_amt = new Element('span').update('金額');
							var span_pct = new Element('span').update('%');
							td_amt.appendChild(span_amt);
							td_pct.appendChild(span_pct);
							tr.appendChild(td_amt);
							tr.appendChild(td_pct);
						});
					}

					//各數字欄位
					$(tableid).select('.colTr').each(function(tr){
						var key = tr.getAttribute('colname');
						
						var amtColid = key+'_AMT';
						var pctColid = key+'_PCT';

						for (var j=0; j<rtnList.length; j++) {
							var ACNT_YEAR = rtnList[j]['ACNT_YEAR'];
							var amtVal = rtnList[j][amtColid];
							var pctVal = rtnList[j][pctColid];
							
							//rowNo,colid,val,ACNT_YEAR,tr,elemType,colType
							var amtTD = actions.createTD(j,amtColid,amtVal,ACNT_YEAR,tr);
							var pctTD = actions.createTD(j,pctColid,pctVal,ACNT_YEAR,null,'span','pctNumber');
							tr.appendChild(amtTD);
							tr.appendChild(pctTD);
						}
					});
				});
				
			},
			<%-- 產生table E 財報-財報資訊(現金流量表) 資料欄位 --%>
			genTableE : function(rtnList){
				$w('tableE').each(function(tableid){
				
					var tdwidth=(90/rtnList.length);
					for (var i=0; i<rtnList.length; i++) {
					
						$(tableid).select('.head_ACNT_YEAR').each(function(tr){
							//tableid,ACNT_YEAR,rowno,tdwidth,span2
							tr.appendChild(actions.createACNT_YEARspan(tableid,rtnList[i].ACNT_YEAR,i,tdwidth));
						});
					}

					//各數字欄位
					$(tableid).select('.colTr').each(function(tr){
						var key = tr.getAttribute('colname');
						
						var amtColid = key+'_AMT';
						var pctColid = key+'_PCT';

						for (var j=0; j<rtnList.length; j++) {
							var ACNT_YEAR = rtnList[j]['ACNT_YEAR'];
							var amtVal = rtnList[j][amtColid];
							
							//rowNo,colid,val,ACNT_YEAR,tr,elemType,colType
							var amtTD = actions.createTD(j,amtColid,amtVal,ACNT_YEAR,tr);
							tr.appendChild(amtTD);
						}
					});
				});
			}
			
	};
	var buttons = {
		doQuery : function(){
			defineValid('query');
			if(!valid.validate()){
				return;
			}
			
			//保留參數管理-更新受理編號
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID')});
			
			ajaxRequest.post('query',{ 'reqMap' : Object.toJSON(actions.getQueryParams()) } ,
					function(resp){<%--成功--%>
						reQueryMap = resp.reQueryMap || [];
						
						var A010Map = resp.A010Map;
						actions.setValue(A010Map);
						
						var rtnList = resp.rtnList||[];
						actions.setGrid(rtnList);
						
					},
					function(resp){<%--失敗--%>
						actions.clearTable();
					}
				);
		},
		doSave : function(){
			defineValid('save');
			if(!valid.validate()){
				return;
			}
			
			if($F('APPLY_ID') == reQueryMap.APPLY_ID && $F('ID') == reQueryMap.ID){
				var saveMap = actions.getSaveMap();
				var saveList = actions.getSaveList();

				ajaxRequest.post('save', { 'reqList' : Object.toJSON(saveList), 'reqMap' : Object.toJSON(saveMap) },
						function(resp){<%--成功--%>
							reQueryMap = resp.reQueryMap || [];
							
							var A010Map = resp.A010Map;
							actions.setValue(A010Map);
							
							var rtnList = resp.rtnList || [];
							actions.setGrid(rtnList);
						}
				);
			} else{
				alert('查詢條件有異動，請重新查詢');
				return false;
			}
		},
		doAddYear : function(){
			actions.genAddYear();
		}
	};
	
	
	
	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode='' var='localeDisplay' />
			PageUI.createPageWithAllBodySubElement(
					'DSA20502',
					'核貸作業',
					'財報輸入作業'
				);

			initValidation();
			
			<c:forEach var="map" items="${ACNT_OPINION_LIST}">
				selectOptions['ACNT_OPINION']['${map.key}'] = '${map.value}';
			</c:forEach>
			
			<%--註冊事件--%>
			$('btnQuery').observe('click', buttons.doQuery);
			$('btnSave').observe('click', buttons.doSave);
			$('btnAddYear').observe('click', buttons.doAddYear);
			
			<%--若LINK_FROM有值，= 傳入.APPLY_ID --%>
			if ('${LINK_FROM}' != ''){
				$('APPLY_ID').setValue('${APPLY_ID}');
				buttons.doQuery();
			}else if(CSRUtil.keepParamsManager.get('APPLY_ID') != ''){<%--或 保留參數管理-受理編號 有值 --%>
				$('APPLY_ID').setValue(CSRUtil.keepParamsManager.get('APPLY_ID'));
				buttons.doQuery();
			}
			
			displayMessage();
			autoCreateDate();
		}
	};
}

	
</script>
</head>
<body>
	<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table id="tableQuery" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td width="15%" class="tbYellow" align="center">受理編號</td>
				<td width="30%" class="tbYellow2">
					<input id="APPLY_ID" name="APPLY_ID" type="text" size="15" maxlength="11" class="textBox2" title="受理編號"/>
				</td>
				<td width="15%" class="tbYellow" align="center">統一編號</td>
				<td width="30%" class="tbYellow2">
					<input id="ID" name="ID" type="text" size="12" maxlength="8" class="textBox2" title="統一編號" />
					<input id="APPLY_PROCESS" name="APPLY_PROCESS" type="hidden" title="受理進度"/>
				</td>
				<td width="10%" class="tbYellow2">
					<button type="button" class="button" id="btnQuery">查詢</button>
				</td>
			</tr>
			<tr>
				<td colspan="5" align="center" class="tbYellow2">
					<button type="button" class="button" id="btnSave">儲存</button>
					<button type="button" class="button" id="btnAddYear">新增會計年度</button>
				</td>
			</tr>
		</table>
		<table id="tableB" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display: none;">
			<tr>
				<td id="tableB_head" class="tbYellow0 table_head" align="center"><b>財報-會計師意見</b></td>
			</tr>
			<tr id="tr_ACNT_YEAR" class="colTr" colname="ACNT_YEAR" elemType="input" colType="date" chgfunc="chgACNT_YEAR">
				<td class="tbYellow" align="center">會計年度結束日</td>
			</tr>
			<tr id="tr_MONTHS" class="colTr" colname="MONTHS" elemType="input" colType="number" colSize="5" colMaxlength="2" >
				<td class="tbYellow" align="center" width="10%" >月數(1~12)</td>
			</tr>
			<tr id="tr_ACNT_FIRM" class="colTr" colname="ACNT_FIRM" elemType="input" colMaxlength="30" >
				<td class="tbYellow" align="center" width="10%" >會計師事務所</td>
			</tr>
			<tr id="tr_ACNT_OPINION" class="colTr" colname="ACNT_OPINION" elemType="select">
				<td class="tbYellow" align="center" width="10%" >會計師出具意見</td>
			</tr>
			<tr id="tr_CHG_FIRM_DESC" class="colTr" colname="CHG_FIRM_DESC" elemType="textarea" colSize="200">
				<td class="tbYellow" align="center" width="10%" >近三年是否有更換事務所或會計師</td>
			</tr>
			<tr id="tr_OPERATE_HYPOTHE_DESC" class="colTr" colname="OPERATE_HYPOTHE_DESC" elemType="textarea" colSize="200">
				<td class="tbYellow" align="center" width="10%" >近三年是否有繼續經營假設疑慮</td>
			</tr>
			<tr id="tr_OTHER_MEMO" class="colTr" colname="OTHER_MEMO" elemType="textarea" colSize="200">
				<td class="tbYellow" align="center" width="10%" >其他備註說明</td>
			</tr>
		</table>
		<table id="tableB_1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display: none;">
			<tr id="tr_CURR_UNIT" class="colTr" colname="CURR_UNIT">
				<input id="dataRecord" type="hidden">
				<td class="tbYellow" width="10%">幣別</td>
				<td class="tbYellow2" width="10%">
					<select name="CURR" id="CURR" title="幣別" >
						<option value="">請選擇</option>
						<c:forEach var="map" items="${CURR_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="10%">單位</td>
				<td class="tbYellow2" width="70%">
					<select name="UNIT" id="UNIT" title="單位" >
						<option value="">請選擇</option>
						<c:forEach var="map" items="${UNIT_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
		</table>
		<table id="tableC" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display: none;">
			<tr>
				<td class="tbYellow0 table_head" align="center"><b>財報-財報資訊</b></td>
			</tr>
			<tr class="head_ACNT_YEAR" colname="ACNT_YEAR" elemType="span">
				<td class="tbYellow" align="center" rowspan="2"><b>損益表</b></td>
				 <!--會計年度結束日-->
			</tr>
			<tr class="sub_head" ></tr>
			<tr>
				<td class="tbBlue table_head" align="left"><b>本業</b></td>
			</tr>
			<tr id="tr_NNOR" class="colTr" colname="NNOR" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >營業收入(銷貨收入淨額)/營收成長率</td>
			</tr>
			<tr id="tr_COST" class="colTr" colname="COST" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >營業成本(銷貨成本)</td>
			</tr>
			<tr id="tr_PRO" class="colTr" colname="PRO" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >營業毛利</td>
			</tr>
			<tr id="tr_OE" class="colTr" colname="OE" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >營業費用</td>
			</tr>
			<tr id="tr_OI" class="colTr" colname="OI" elemType="span" colType="number">
				<td class="tbYellow" align="center">營業利益(損失)</td>
			</tr>
			<tr>
				<td class="tbBlue table_head" align="left"><b>營業外收入及支出</b></td>
			</tr>
			<tr id="tr_INTE" class="colTr" colname="INTE" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >財務成本(利息費用)</td>
			</tr>
			<tr id="tr_NNOI" class="colTr" colname="NNOI" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >營業外收入及支出合計</td>
			</tr>
			<tr id="tr_BTAX" class="colTr" colname="BTAX" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >稅前淨利(淨損)</td>
			</tr>
			<tr id="tr_TAX" class="colTr" colname="TAX" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >所得稅費用(利益)</td>
			</tr>
			<tr id="tr_CONT" class="colTr" colname="CONT" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >本期淨利(淨損)</td>
			</tr>
			<tr id="tr_OCI" class="colTr" colname="OCI" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >其他綜合損益(淨額)</td>
			</tr>
			<tr id="tr_TCI" class="colTr" colname="TCI" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >本期綜合損益總額</td>
			</tr>
		</table>
		<table id="tableD" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display: none;">
			<tr class="head_ACNT_YEAR" colname="ACNT_YEAR" elemType="span">
				<td class="tbYellow" align="center" rowspan="2"><b>資產負債表</b></td>
				 <!--會計年度結束日-->
			</tr>
			<tr class="sub_head" ></tr>
			<tr>
				<td class="tbBlue table_head" align="left"><b>資產</b></td>
			</tr>
			<tr id="tr_CA" class="colTr" colname="CA" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >流動資產</td>
			</tr>
			<tr id="tr_CASH" class="colTr" colname="CASH" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >現金及約當現金</td>
			</tr>
			<tr id="tr_RCV" class="colTr" colname="RCV" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >應收帳款及票據</td>
			</tr>
			<tr id="tr_INV" class="colTr" colname="INV" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >存貨</td>
			</tr>
			<tr id="tr_PRE" class="colTr" colname="PRE" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >預付款項</td>
			</tr>
			<tr id="tr_QA" class="colTr" colname="QA" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >速動資產<br>(流動資產-存貨-預付款項)</td>
			</tr>
			<tr id="tr_NCA" class="colTr" colname="NCA" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >非流動資產</td>
			</tr>
			<tr id="tr_PROP" class="colTr" colname="PROP" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >不動產、廠房及設備</td>
			</tr>
			<tr id="tr_LT" class="colTr" colname="LT" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >長期投資</td>
			</tr>
			<tr id="tr_TOT_ASS" class="colTr" colname="TOT_ASS" elemType="span" colType="number">
				<td class="tbYellow0" align="center" width="10%" >資產總計</td>
			</tr>
			<tr>
				<td class="tbBlue table_head" align="left"><b>負債</b></td>
			</tr>
			<tr id="tr_CL" class="colTr" colname="CL" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >流動負債</td>
			</tr>
			<tr id="tr_ST" class="colTr" colname="ST" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >短期借款</td>
			</tr>
			<tr id="tr_STNP" class="colTr" colname="STNP" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >應付短期票據(票券)</td>
			</tr>
			<tr id="tr_CURLT" class="colTr" colname="CURLT" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >一年或一營業週期內到期長期借款</td>
			</tr>
			<tr id="tr_NCL" class="colTr" colname="NCL" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >非流動負債</td>
			</tr>
			<tr id="tr_LTL" class="colTr" colname="LTL" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >長期借款(應付公司債)</td>
			</tr>
			<tr id="tr_TOT_LIA" class="colTr" colname="TOT_LIA" elemType="span" colType="number">
				<td class="tbYellow0" align="center" width="10%" >負債總計</td>
			</tr>
			<tr id="tr_TOT_EQU" class="colTr" colname="TOT_EQU" elemType="input" colType="number">
				<td class="tbYellow" align="center" width="10%" >權益總計</td>
			</tr>
		</table>
		<table id="tableE" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" style="display: none;">
			<tr class="head_ACNT_YEAR" colname="ACNT_YEAR" elemType="span">
				<td class="tbYellow" align="center" width="10%" ><b>現金流量表</b></td>
				 <!--會計年度結束日-->
			</tr>
			<tr id="tr_CASHO" class="colTr" colname="CASHO" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >營業活動之淨現金流入<br>(流出)</td>
			</tr>
			<tr id="tr_DEP" class="colTr" colname="DEP" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >折舊費用</td>
			</tr>
			<tr id="tr_AMO" class="colTr" colname="AMO" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >攤銷費用</td>
			</tr>
			<tr id="tr_CASHI" class="colTr" colname="CASHI" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >投資活動之淨現金流入<br>(流出)</td>
			</tr>
			<tr id="tr_CASHF" class="colTr" colname="CASHF" elemType="input" colType="number" chgfunc="chgColumns">
				<td class="tbYellow" align="center" width="10%" >籌資活動之淨現金流入<br>(流出)</td>
			</tr>
			<tr id="tr_NCASH" class="colTr" colname="NCASH" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >淨現金流</td>
			</tr>
			<tr id="tr_FCF" class="colTr" colname="FCF" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >自由現金流<br>(營業現金流入 - 投資現金流出)</td>
			</tr>
			<tr id="tr_EBITDA" class="colTr" colname="EBITDA" elemType="span" colType="number">
				<td class="tbYellow" align="center" width="10%" >EBITDA</td>
			</tr>
		</table>
	</form>
</body>
</html>