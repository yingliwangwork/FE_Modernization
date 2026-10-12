<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSE11900.jsp
作者：謝進修
功能：異常案件報表剔件覆核
完成：2013/03/14

[20230922] 立案單號: 230418009027
1. 新增"是否委外"下拉選單
2. 查詢及匯出新增"是否委外"條件

[20240215]難字調整
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI_Beta.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script> 
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>

<%--[20240215]難字css  --%>
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

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 
Event.observe(window, 'load', new DSE11900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11900() {
	var grid;
	var valid;

	//共用AJAX
	var ajaxPost = function ( actionName, params, successAction){   
	    new Ajax.Request( '${dispatcher}/DSE1_1900/' + actionName,{  
	            parameters: params, 
	            onSuccess: function(response){ successAction(response.responseJSON);
	        }
	    });
	};
        
	// 檢核
	var initValidation = function(){
		valid = new Validation('form1', { focusOnError:true, immediate:false , mode : 'validator'});    
	};

	var actions = {
            // 頁面資料
            getDataMap : function(){
                var dataMap = {};
                dataMap['INPUT_ID'] = $F('INPUT_ID');
                dataMap['BORROW_TYPE'] = $F('BORROW_TYPE');
          
                //[20230922]「是否委外」下拉選單
                dataMap['OUTSOURCE'] = $F('OUTSOURCE');
                
				dataMap['REPORT_TYPE1'] = $F('REPORT_TYPE1');
                dataMap['REPORT_TYPE2'] = $F('REPORT_TYPE2');
                dataMap['REPORT_DATE'] = toY2K($F('REPORT_DATE'));
				<%--dataMap['DAYS'] = $F('DAYS');--%>

                return dataMap;
            },

			// 連動產生承辦法務
			/*changeCRED_DEPT : function() {
				$('INPUT_ID').options.length = 1;

				if (!$F('CRED_DEPT')) { return; }

				ajaxPost('changeCRED_DEPT', {CRED_DEPT : $F('CRED_DEPT')}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var INPUT_ID_LIST  = resp.INPUT_ID_LIST || [];
							for (var i = 0; i < INPUT_ID_LIST.length; i++){
								var optMap = INPUT_ID_LIST[i];
								if (optMap.ID){
									var oOption = new Element('option');
									oOption.innerText = optMap.NAME;
									oOption.value = optMap.ID;
									$('INPUT_ID').insert(oOption);
								}
							}
                        }
                    }
                );
			}, */

			// 連結至 DSE12001
			linkToDSE12001 : function(record) {
				ajaxPost('linkToDSE12001', { inputMap : Object.toJSON(record) }, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var conf = {};
							conf.src = '${dispatcher}/DSE1_2001/prompt';
							conf.parameters = {
								'inputMap': resp.inputMap
							};
							popupWin.popup(conf);
                        }
                    }
                );
			}
			<%--
			// 報表種類一連動
			, changeREPORT_TYPE1 : function(){
				// 當 REPORT_TYPE1 的 value 為 2 時，下拉選單選項為「中斷時效」
				// 當 REPORT_TYPE1 的 value 為 4 時，下拉選單選項為「調查財產報表」
				// 當 REPORT_TYPE1 的 value 為 5 時，下拉選單選項為「調查財產費用」
				if ('2' == $F('REPORT_TYPE1') || '4' == $F('REPORT_TYPE1') || '5' == $F('REPORT_TYPE1')) { 
					$('DAYS').readOnly = true;
					$('DAYS').value= '';
					$('REPORT_DATE').readOnly = false;
					$('REPORT_DATE').value= '${default_REPORT_DATE}';
					$('calendarREPORT_DATE').show();
				}
				// 當 REPORT_TYPE1 的 value 為 6 時，下拉選單選項為「追償作業」
				// 當 REPORT_TYPE1 的 value 為 7 時，下拉選單選項為「債權憑證」
				else if ('6' == $F('REPORT_TYPE1') || '7' == $F('REPORT_TYPE1')) { 
					$('DAYS').readOnly = false;
					$('DAYS').value= '30';
					$('calendarREPORT_DATE').hide();
					$('REPORT_DATE').readOnly = true;
					$('REPORT_DATE').value= '';
				} else {
					$('DAYS').readOnly = true;
					$('DAYS').value= '';
					$('calendarREPORT_DATE').hide();
					$('REPORT_DATE').readOnly = true;
					$('REPORT_DATE').value= '';
				}
			}
			--%>
	};

	var buttons = {
            // 查詢
            doQuery : function(){
				valid.reset();
				valid.clear();
				<%--
				// 當 REPORT_TYPE1 的 value 為 2 時，下拉選單選項為「中斷時效」
				// 當 REPORT_TYPE1 的 value 為 4 時，下拉選單選項為「調查財產報表」
				// 當 REPORT_TYPE1 的 value 為 5 時，下拉選單選項為「調查財產費用」
				if ('2' == $F('REPORT_TYPE1') || '4' == $F('REPORT_TYPE1') || '5' == $F('REPORT_TYPE1')) { 
				--%>
					valid.define( 'required' , [{ id : 'REPORT_DATE'}] );
				<%--
				}

				// 當 REPORT_TYPE1 的 value 為 6 時，下拉選單選項為「追償作業」
				// 當 REPORT_TYPE1 的 value 為 7 時，下拉選單選項為「債權憑證」
				if ('6' == $F('REPORT_TYPE1') || '7' == $F('REPORT_TYPE1')) { 
					valid.define( 'required' , [{ id : 'DAYS'}] );
				}
				--%>

                if ( !valid.validate() ) { return; }

				var params = { 'reqMap' : Object.toJSON(actions.getDataMap()) };
				grid.load( '${dispatcher}/DSE1_1900/query', params );

				<%--
                ajaxPost('query', {reqMap : Object.toJSON(actions.getDataMap())}, 
                    function(resp){
                        if(CSRUtil.isSuccess(resp)){
                            var rtnList = resp.rtnList || [];
                            grid.load(rtnList);
                        } else {
                            grid.load([]);
                        }
                    }
                );
                --%>
            },
            // 匯出
            doExport : function () {
				valid.reset();
				valid.clear();

				<%--
				// 當 REPORT_TYPE1 的 value 為 2 時，下拉選單選項為「中斷時效」
				// 當 REPORT_TYPE1 的 value 為 4 時，下拉選單選項為「調查財產報表」
				// 當 REPORT_TYPE1 的 value 為 5 時，下拉選單選項為「調查財產費用」
				if ('2' == $F('REPORT_TYPE1') || '4' == $F('REPORT_TYPE1') || '5' == $F('REPORT_TYPE1')) {
				--%>
					valid.define( 'required' , [{ id : 'REPORT_DATE'}] );
				<%--
				}
				// 當 REPORT_TYPE1 的 value 為 6 時，下拉選單選項為「追償作業」
				// 當 REPORT_TYPE1 的 value 為 7 時，下拉選單選項為「債權憑證」
				if ('6' == $F('REPORT_TYPE1') || '7' == $F('REPORT_TYPE1')) { 
					valid.define( 'required' , [{ id : 'DAYS'}] );
				}
				--%>

                if ( !valid.validate() ) { return; }

                $('gridJSON').value = grid.getXlsSettingJSON('異常案件報表_' + $('REPORT_TYPE1').options[$('REPORT_TYPE1').selectedIndex].innerText.trim() + '_' + '${todayROC}');

                var dataMap = actions.getDataMap();
                dataMap['gridJSON'] = $('gridJSON').value;

                var params = {
                	  'reqMap' : Object.toJSON(dataMap)
                	, 'REPORT_TYPE1' : $('REPORT_TYPE1').options[$('REPORT_TYPE1').selectedIndex].innerText.trim()
                };

                RPTUtil.executeCreateXlsFile('${dispatcher}/DSE1_1900/export', params); 
            },

			// 清除
			doClear : function() {
                valid.reset();

                $('form1').reset();				

				<%--
				$('calendarREPORT_DATE').hide();//初始時時限不得輸入，故將小日曆隱藏起來
				--%>

				grid.load([]);
            }
	};

	// 金額格式化
	var gridFmtRender = function(record, value) { return (value || value === '0') ? CSRUtil.$fmt(value,'#,##0.####') : ''; };

	return {
		'initApp' : function() {
                PageUI.createPageWithAllBodySubElement( 'DSE11900', '法務作業', '異常案件報表' );

				grid = new TableUI( {
					  table:$('grid')
					, isLoadByFatch : 20
					, pageSize: 20
					<%-- [20240215] 難字調整 --%>
					,afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					}
					, column:[
                            {header:'貸款帳號', key:'LOAN_ID',
						render : function(record , value){
							if(value){
								var link = new Element("a" , { href : "#" } ).update(value);
								link.observe('click', //監聽click事件
								function( event ) {
								    var url = "${dispatcher}/DSE1_1200/prompt?LOAN_ID="+value;									
									window.open(url, "DSE1_1900", "top=250, left=250, toolbar=no, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=900, height=600");
							
								});
								return link;
							}else{
								return "";
							}				
						}
					},
                            {header:'原貸帳號', key:'REFER_ID'},
                            {header:'借款人', key:'BORROW_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
                            {header:'法務進度', key:'LAW_PROCESS_NM'},
                            {header:'法務進度日', key:'LAW_PROCESS_DATE', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'拍不足額歸戶', key:'BAD_AMT', sortRule:'number',
                                render:gridFmtRender
                            },
                            {header:'中斷時效日', key:'BREAK_OFF_DATE', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'調查財產報表日', key:'INVESTIGATE_DATE', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'調查財產費用日', key:'INVESTIGATE_FEE_DATE', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'有無實益', key:'IS_BENEFIT_NM'},
                            {header:'追償作業聲請日', key:'DATE5', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'債權憑證換發日', key:'DATE4', 
                                render: function(record, value) {
                                    return value ? Date.toROC(value) : ''; 
                                } 
                            },
                            {header:'備註', key:'MEMO'},
                            {header:'債務人', key:'BORROW_TYPE_NM', attrs:{style:"font-family:'EUDC'"} },<%--[20240215]難字調整 --%>
                            {header:'剔件原因', key:'DELETE_REASON_NM', 
                                render: function(record, value) {
                                	if('Y'==record.IS_DELETE){
										return value;
                                	} else if(record.E190_DELETE_REASON){
										return record.E190_DELETE_REASON_NM;
                                	} else {
										return '';
									}
                                }},
                            {header:'剔件狀態', key:'DELETE_STATUS_NM', 
                                render: function(record, value) {
                                	if('Y'==record.IS_DELETE){
										return value;
                                	} else if(record.E190_DELETE_STATUS){
										return record.E190_DELETE_STATUS_NM;
                                	} else {
										return '';
									}
                                }},
                            {header:'剔件', key:'DELETE', 
                                render: function(record, value) {
                                	//[20210916]申請書210901004799：債管免予列帳及參與分配畫面調整
                                    //每日晚上批次(DSE1_B020)產生當日的異常案件時，會抓該筆貸款帳號的異常件剔件紀錄(DTDSE190)更新至DTDSE191
                                    //故如果E191.DELETE_TYPE1包含查詢的報表種類一(REPORT_TYPE1)，表示已被剔除，畫面不顯示"剔除"的連結，並顯示E191的剔除狀態即可
                                    //若E191.DELETE_TYPE1不包含，但該報表種類一有查到E190，可能為當日剔除案件，顯示E190的剔除狀態，另外若剔除狀態<20(覆核)，仍需顯示"剔除"的連結
                                	if('Y'==record.IS_DELETE || record.E190_DELETE_STATUS > 10){
										return '';
									} else {
										var link = new Element('a' , { href : '#' } ).update('剔件');
										link.observe( 'click', function (event){ 																			
												actions.linkToDSE12001(record);
										});		
										return link;
									}
                                } 
                            }
                        ]<%----%>
                    }
                );

                // 查詢
                $('BTN_query').observe('click', buttons.doQuery );
                
                // 匯出
                $('BTN_export').observe('click', buttons.doExport );
                
                // 清除
                $('BTN_clear').observe('click', buttons.doClear );;
                
                // 行政中心連動
                //$('CRED_DEPT').observe('change', actions.changeCRED_DEPT );

				<%--
				// 報表種類一連動
				$('REPORT_TYPE1').observe('change', actions.changeREPORT_TYPE1 );
				--%>
				
                displayMessage();
                initValidation();
				<%--
                $('calendarREPORT_DATE').hide();//初始時時限不得輸入，故將小日曆隱藏起來
                --%>
            }
	};
}
</script>
</head>

<body>
    <form name="form1" id="form1" method="post" action="" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
        <table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
            <tr>
				 <input type="hidden" name="gridJSON" id="gridJSON" value="">
                <td class="tbYellow" width="10%">承辦法務</td>
                <td class="tbYellow2" width="15%">
                    <select name="INPUT_ID" id="INPUT_ID" class="textBox2 validate-selection" fieldName="承辦法務" alt="ch"> <%-- [20240215]難字調整 --%>
                        <option value="">請選擇</option>
                        <c:forEach items="${INPUT_ID_LIST}" var="map">
                            <option value="${map.key}" >${map.value}</option>
                        </c:forEach>
					</select>
                </td>
                <td class="tbYellow" width="10%">債務人種類</td>
                <td class="tbYellow2" width="15%">
                    <select name="BORROW_TYPE" id="BORROW_TYPE" class="textBox2">
						<option value="">全部</option>
                        <c:forEach items="${BORROW_TYPE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>" <c:if test="${map.key == '0' }">selected</c:if>><c:out value="${map.value}"/></option>
                        </c:forEach>
                    </select>
                </td>
                
                <!-- [20230922]「是否委外」下拉選單 -->
                <td class="tbYellow" width="10%">是否委外</td>
                <td class="tbYellow2" width="15%" colspan="3">
                    <select name="OUTSOURCE" id="OUTSOURCE" class="textBox2" fieldName="是否委外">
                        <option value="">請選擇</option>
                        <c:forEach items="${OUTSOURCE_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>" ><c:out value="${map.value}"/></option>
                        </c:forEach>
					</select>
                </td>
                
                <td class="tbYellow2" rowspan="2">
                    <input id="BTN_query" type="button" class="button" value="查詢"/>
                    <input id="BTN_export" type="button" class="button" value="匯出"/>
			        <input id="BTN_clear" type="button" class="button" value="清除"/>
			    </td>
            </tr>
            <tr>
                <td class="tbYellow">報表種類一</td>
                <td class="tbYellow2">
                    <select name="REPORT_TYPE1" id="REPORT_TYPE1" class="textBox2">
                        <c:forEach items="${REPORT_TYPE1_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
                <td class="tbYellow">報表種類二</td>
                <td class="tbYellow2">
                    <select name="REPORT_TYPE2" id="REPORT_TYPE2" class="textBox2">
                        <c:forEach items="${REPORT_TYPE2_LIST}" var="map">
                            <option value="<c:out value='${map.key}'/>"><c:out value="${map.value}" /></option>
                        </c:forEach>
                    </select>
                </td>
                <td class="tbYellow">統計期限</td>
                <td class="tbYellow2">
                    <input id="REPORT_DATE" name="REPORT_DATE" type="text" class="textBox2 validate-ROCDate" size="8" maxlength="7" datatype="ROCDate" fieldName="統計期限" value="${default_REPORT_DATE}">
					<img id="calendarREPORT_DATE" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('REPORT_DATE'))">
					<%--或天數<input id="DAYS" name="DAYS" type="text" class="textBox2 validate-digits" size="4" fieldName="天數" readonly/>--%>
                </td>
            </tr>
        </table>
        <table id="grid"></table>
    </form>
</body>
</html>