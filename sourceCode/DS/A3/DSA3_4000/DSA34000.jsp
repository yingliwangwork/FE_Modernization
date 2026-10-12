<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA34000.jsp
作者：李曼華
功能：AVM命中率統計
完成：2021/06/18

[20210624] 問題單 增加Table欄位 & 日期區間
[20210701] 問題單 增加queryDetail
[20210705] 問題單 20210705083140  增加AVM統計命中率明細Table

[20210715][20210714093419]:
          1.查詢種類若選統計明細，分類種類及歸類依據可不用必填
          2.新增統計明細表格欄位，匯出也一併修改
          
[20210722]20210719191348
1. 查詢表格百分比數值皆取到小數點第一位
2. G區表格新增欄位
3. 以命中率統計查詢改使用真分頁查詢搭配DS_A34000.queryDetail方法
4. B~G區表格匯出xls資料可拆成一列一列顯示
5. 修改欄位名稱:’派件件數’改成’案件件數’
備註:3與4待SA確認
郭曉慧	        

[20210802] 問題單 20210730171405 1. 鑑價日期起訖預設系統日 2. 表頭案件件數改成計算件數        
[20210817][20210810150112] 查詢種類若選統計明細，歸類依據不卡，改卡鑑價科
[20240930]難字調整
-->


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/date.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
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
Event.observe(window, 'load', new DSA34000().initApp);

function DSA34000(){
	var TOTobj = [];
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_4000/');	
	var grid1;
	var current1stDate = '${current1stDate}';
	var today = '${today}'
	var yesterday = '${yesterday}'

	var valid;
	function initValidation(){
		valid = new Validation("form1", {useTitles:true, mode : "validate"});
		valid.define( "required" , [{ id : "BDATE_BEG", errMsg:'請輸入鑑價日期起日'}]);
		valid.define( "required" , [{ id : "BDATE_END", errMsg:'請輸入鑑價日期迄日'}]);
		valid.define( "validate-ROCDate-Interval", [{ id : "BDATE_BEG", errMsg :"鑑價日期起日格式錯誤"}, { id : "BDATE_END", errMsg :"鑑價日期迄日格式錯誤"}] );
		valid.define( "validate-selection", [ { id : "QUERY_TYPE", errMsg :"請選擇查詢種類"} ] );
		
		<%--[20210715][20210714093419] 查詢種類若選統計明細，分類種類可不用必填--%>
		<%--[20210817][20210810150112] 查詢種類若選統計明細，歸類依據不卡，改卡鑑價科--%>
		var thisQUERY_TYPE = $F('QUERY_TYPE');
		if(thisQUERY_TYPE != "4"){<%--統計明細--%>
			valid.define( "validate-selection", [ { id : "BASIC", errMsg :"請選擇歸類依據"} ] );
			valid.define( "validate-selection", [ { id : "KIND", errMsg :"請選擇分類種類"} ] );
		}

	}
	var actions = {
		'cleanGrid':function(){
				$('grid1').update([]);
				$('grid1').hide();				
			},
		'getReqMap':function(){
			 var reqMap = {
					QUERY_TYPE : $F('QUERY_TYPE'),
					KIND : $F('KIND'),
					BASIC : $F('BASIC'),
					WELL_CONTRACT : $F('WELL_CONTRACT'),
					BDATE_BEG :$F('BDATE_BEG'),
					BDATE_END :$F('BDATE_END'),
					APPR_DEPT :$F('APPR_DEPT'),
					APPR_ID :$F('APPR_ID'),
					CITY_NAME :$F('CITY'),
					PRICE_LOW :$F('PRICE_LOW'),
					PRICE_HIGH :$F('PRICE_HIGH'),
					TOTAL_PRICE_LOW :$F('TOTAL_PRICE_LOW'),
					TOTAL_PRICE_HIGH :$F('TOTAL_PRICE_HIGH'),
					AREA_LOW :$F('AREA_LOW'),
					AREA_HIGH :$F('AREA_HIGH'),
					TIME_RANGE : $F('TIME_RANGE'),
					APPR_DEPT : $F('APPR_DEPT')
				};
				return reqMap;
			},
			<%--[20210701]問題單 增加超連結--%>
			'popupReqMap':function(rec,kind,basic){
				<%--[20210723]調整參數來源--%>
				var reqMap= actions.getReqMap();
				if(basic=='1'){
					reqMap.APPR_DEPT =rec.APPR_CODE;
				}else if(basic == '2'){
					reqMap.APPR_ID =rec.EMP_ID;
					<%--[20210817]增加智能件判斷--%>
					if(rec.EMP_NAME == '智能件'){
						reqMap.IS_AUTOAPPR ='2';
					}
				}else if(basic == '3'){
					reqMap.CITY_CODE =rec.CITY_CODE;
				}
				return reqMap;
			},
		<%--[20210624] 問題單 增加Table欄位 & 日期區間--%>
		'doQuery' : function(){
			initValidation();
			valid.reset();
			if( !valid.validate() ) {
	    		return;
	    	}	
			
			var thisQUERY_TYPE = $F('QUERY_TYPE');
			if(thisQUERY_TYPE == "4"){<%--統計明細--%>
				if($F('APPR_DEPT')== '' && $F('CITY') == ''){
					alert("鑑價科和縣市別請擇一選擇查詢");
					return;
				}
			}
			
			ajaxRequest.post( 'query',  { reqMap : Object.toJSON(actions.getReqMap()) },
				function(resp){
						var queryType =resp.QUERY_TYPE;
						var kind =resp.KIND;
						var basic =resp.BASIC;
						var timeRange_sel =resp.TIMERANGE_SELECTED;
						var rtnList=resp.rtnList;
								
						<%--[20210715][20210714093419]--%>
						if(queryType == '4'){
							<%--[20210705] 問題單 20210705083140  增加AVM統計命中率明細Table--%>
							grid1=new TableUI(actions.buildGrid(queryType, kind, basic, timeRange_sel));
							grid1.load(rtnList);
						}else if( (kind == '1') || (kind == '2') || (kind == '3') ){
							var TOTobj = [{ text:'合計', value :resp.sumMap}];	
							grid1=new TableUI(actions.buildGrid(queryType, kind, basic, timeRange_sel));
							grid1.load(rtnList, TOTobj );
						}

				},
				function(){
					actions.cleanGrid();
				}
			);				
		},
		'doExport' : function(){
		var reqMap =actions.getReqMap();
			reqMap.gridJSON = grid1.getXlsSettingJSON('命中率統計明細');
			RPTUtil.executeCreateXlsFile('${dispatcher}/DSA3_4000/export', {reqMap: Object.toJSON(reqMap) },false);
		},
		'doClean': function(){
			$('form1').reset();
			actions.cleanGrid();
			valid.reset();
		},
		'doSetDate': function(){
			if($F('QUERY_TYPE') == '4'){
				$('BDATE_BEG').setValue(yesterday);
				$('BDATE_END').setValue(yesterday);
			}else{
				$('BDATE_BEG').setValue(current1stDate);
				$('BDATE_END').setValue(today);
			}
		},
		'doGetAPPR_ID_LIST' : function (){
			
			var inputMap = {
					APPR_DEPT : $F('APPR_DEPT')
			};
					
			ajaxRequest.post( 'getAPPR_ID_LIST',  { inputMap : Object.toJSON(inputMap) },
					function(resp){
							var optionList = resp.APPR_ID_LIST ? resp.APPR_ID_LIST:[];
							$('APPR_ID').length = 1;
							for(var i = 0; i < optionList.length; i++){
								$('APPR_ID').options.add(new Option(optionList[i]['NAME'], optionList[i]['ID']));
							}
					});	
			
		},<%--[20210817][20210810150112] 統合超連結方法--%>
		'returnLinkInfo':function( rec , basic ,kind ){	
			var updateRecord ;
			 if(basic == '1'){
				 updateRecord = rec.APPR_GROUP;				 
			 }else if(basic == '2'){
				 updateRecord = rec.EMP_NAME;				 
			 }else if(basic == '3'){
				 updateRecord = rec.CITY_NAME;
			 }
       		var link = new Element('a',{href:'javascript:void(0)'}).update(updateRecord);
       		link.observe('click', function(){
       			var url = "${dispatcher}/DSA3_4001/prompt";
       			popupWin.windowOpen( url,{
        		'parameters': {
        			reqMap: Object.toJSON(actions.popupReqMap(rec,kind,basic)) 
					}
    			});
       		});
       		return link;
		},
		'buildGrid': function(queryType, kind, basic, timeRange_sel){
			<%--[20210722]修改欄位名稱:"派件件數"改成"案件件數"/以分類種類:建物用途查詢結果增加一組"工商用"的欄位--%>
			<%--[20210723]調整排版--%>
			<%--[20210802] 問題單 20210730171405 表頭案件件數改成計算件數--%>
			var grid={}
			<%--[20210817][20210810150112] 新增歸類依據[鑑價科別]--%>
			var basicHeaderNM;
			if('1'== basic){<%--鑑價科別--%>
				basicHeaderNM = "鑑價科別" ;
			}else if ('2' == basic){<%--鑑價員--%>
				basicHeaderNM = "鑑價員" ;
			}else if ('3'== basic){<%--縣市別--%>
				basicHeaderNM = "縣市別" ;
			}
			var basicKeyNM;
			if('1'== basic){<%--鑑價科別鑑價員--%>
				basicKeyNM = "APPR_GROUP" ;
			}else if ('2' == basic){<%--鑑價員--%>
				basicKeyNM = "EMP_NAME" ;
			}else if ('3' == basic){<%--縣市別--%>
				basicKeyNM = "CITY_NAME" ;
			}
			if(queryType == '4'){//AVM命中率統計明細
				grid = {
						table:$('grid1'), allSortable: true, split:['PRICE_S'],
						<%-- [20240930] 難字調整 --%>
						afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						},
						column:[
							{ header: "序號" , key:'SN', 
				                    	render : function(rec, val , sn){
				                    		return sn;
				                    	},attrs:{rowSpan:2} 
				                    },
			                { header:"受理編號",key:'APPLY_ID',attrs:{rowSpan:2 }},
			                { header:"建築型態",key:'USE_FOR',attrs:{rowSpan:2 }},
			                { header:"自動估價建議價格",key:'PRICE_A', 
			                	render: function(record,value){
		                        return  MoneyFormat(value) ;
		                    }},
			                { header:"是否落入區間",key:'REGION_A'},
			                { header:"價格落差",key:'GAP_VALUE_A', 
			                	render: function(record,value){
			                        return  MoneyFormat(value) ;
			                    }},
				            { header:"價格落差原因一",key:'GAP_NOTE1_A'},
				            { header:"價格落差原因二",key:'GAP_NOTE2_A'},
				            { header:"單價(萬/坪)",key:'PER_PRICE',attrs:{rowSpan:2 }},
				            { header:"總價(萬)",key:'TOTAL_PRICE',attrs:{rowSpan:2 }},
				            { header:"面積(坪)",key:'AREA',attrs:{rowSpan:2 }},
				            { header:"案件類別",key:'APPLD_TYPE',attrs:{rowSpan:2 }},
				            { header:"縣市",key:'CITY_NAME',attrs:{rowSpan:2 }},
			                { header:"行政區",key:'DISTRICT',attrs:{rowSpan:2 }},
			                <%--[20210715][20210714093419]--%>
			                { header:"受理進度",key:'APPR_PROCESS',attrs:{rowSpan:2 }},
			                { header:"派件日期",key:'APPLY_DATE',attrs:{rowSpan:2 },sortRule:"date"},
			                { header:"覆核(退件)日期",key:'REPORT_DATE',attrs:{rowSpan:2 },sortRule:"date"},
			                { header:"鑑價組",key:'APPR_GROUP',attrs:{rowSpan:2 }},
			                { header:"鑑價員",key:'APPR_NM',attrs:{rowSpan:2, style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%> 
			                { header:"覆核組長",key:'CAPT_NM',attrs:{rowSpan:2, style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%> 
			                { header:"建議案例平均價格",key:'PRICE_S', 
			                	render: function(record,value){
			                        return  MoneyFormat(value) ;
			                    }},
			                { header:"是否落入區間",key:'REGION_S'},
			                { header:"價格落差",key:'GAP_VALUE_S', 
			                	render: function(record,value){
			                        return  MoneyFormat(value) ;
			                    }},
			                { header:"價格落差原因一",key:'GAP_NOTE1_S'},
			                { header:"價格落差原因二",key:'GAP_NOTE2_S'}
						]
				}
				
				return grid ;
			}else{
				if(timeRange_sel == 'N'){
					if( kind == '1' ){
						grid ={	
								table:$('grid1'), allSortable: true, split:["TOTAL_NORMAL"],
								column:[
									{ header: basicHeaderNM,
									  key:  basicKeyNM,
									  attrs:{rowSpan:2}, groupKey:[basicKeyNM],
									  render : function(rec){
			                                return  actions.returnLinkInfo(rec , basic ,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
			                            }										 
									},
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "總命中率", attrs:{colSpan:3}, empty:'rowSpan_down'},
									{ header: "壽險端", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "銀行端", attrs:{colSpan:4}, empty:'rowSpan_down'},
		
									{ header: "正常",key: "TOTAL_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "TOTAL_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "TOTAL_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "計算件數", key: "LIFE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "LIFE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "LIFE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "LIFE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "計算件數", key: "BANK_COUNT", renderInCount:true,
											render: function(record,value){
				                                return  (value || '0') ;
				                            }},
									{ header: "正常", key: "BANK_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "BANK_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "BANK_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }}
								]
							}
						return grid;
					}else if( kind == '2' ){
						grid={	table:$('grid1'), allSortable: true, split:["HOUSE_COUNT"],
								column:[
										{ header: basicHeaderNM,
										  key:  basicKeyNM,
										  attrs:{rowSpan:2}, groupKey:[basicKeyNM],
										  render :  function(rec){
				                                return  actions.returnLinkInfo(rec , basic ,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
				                            }
											 
										},
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
											render: function(record,value){
				                                return  (value || '0');
				                            }},
									{ header: "總體正常", key: "TOTAL_NORMAL", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏高", key: "TOTAL_HIGH", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏低", key: "TOTAL_LOW", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "住宅大樓", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "住辦大樓", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "公寓", attrs:{colSpan:4},empty:'rowSpan_down'},
				                    { header: "樓中樓", attrs:{colSpan:4}, empty:'rowSpan_down' },
				                    { header: "套房", attrs:{colSpan:4}, empty:'rowSpan_down' },
									<%--住宅大樓--%>
									{ header: "計算件數", key: "HOUSE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常",key: "HOUSE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "偏高", key: "HOUSE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "HOUSE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
		                            
			   						<%--住辦大樓--%>
									{ header: "計算件數", key: "OFFICE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "OFFICE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "OFFICE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "OFFICE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
			   						<%--公寓--%>
			                        { header: "計算件數", key: "APART_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "APART_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "APART_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "APART_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
			   						<%--樓中樓--%>
			   						{ header: "計算件數", key: "DUPLEX_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
			   						{ header: "正常", key: "DUPLEX_NORMAL", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏高", key: "DUPLEX_HIGH", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏低", key: "DUPLEX_LOW", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			        				<%--套房--%>
			   						{ header: "計算件數", key: "ROOM_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
			   						{ header: "正常", key: "ROOM_NORMAL", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏高", key: "ROOM_HIGH", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏低", key: "ROOM_LOW", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }}
								]
						}
						return grid ;
					}else if( kind == '3' ){
						grid = { table:$('grid1'), allSortable: true, split:["LIVE_COUNT"],
								 column:[
									{ header: basicHeaderNM,
									  key:  basicKeyNM,
									  attrs: {rowSpan:2}, groupKey:[basicKeyNM],
									  render : 
										  function(rec){
			                                return  actions.returnLinkInfo(rec , basic,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
			                            }
										 
									},
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "總體正常", key: "TOTAL_NORMAL", renderInCount:true, attrs:{rowSpan:2}, 
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "總體偏高", key: "TOTAL_HIGH", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏低", key: "TOTAL_LOW", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "住家用", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "商業用", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "工業用", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "工商用", attrs:{colSpan:4}, empty:'rowSpan_down'},
				                    { header: "住商用", attrs:{colSpan:4},empty:'rowSpan_down'},
				   					{ header: "國民住宅", attrs:{colSpan:4}, empty:'rowSpan_down'},
				   					{ header: "其他", attrs:{colSpan:4}, empty:'rowSpan_down'},
		
									<%--住家用--%>
									{ header: "計算件數", key: "LIVE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常",key: "LIVE_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        } },
									{ header: "偏高", key: "LIVE_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "LIVE_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									<%--商業用--%>
									{ header: "計算件數", key: "MARKET_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "MARKET_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "MARKET_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "MARKET_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
				                    <%--工業用--%>
				   					{ header: "計算件數", key: "FACTORY_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
				   					{ header: "正常", key: "FACTORY_NORMAL", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏高", key: "FACTORY_HIGH", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏低", key: "FACTORY_LOW", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				                    <%--[20210722]工商用--%>
				   					{ header: "計算件數", key: "BUSINESS_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
				   					{ header: "正常", key: "BUSINESS_NORMAL", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏高", key: "BUSINESS_HIGH", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏低", key: "BUSINESS_LOW", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},      
									<%--住商用--%>
				                    { header: "計算件數", key: "LIVE_MARKET_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "LIVE_MARKET_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "LIVE_MARKET_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "LIVE_MARKET_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                     	  }},
									<%--國民住宅--%>
									{ header: "計算件數", key: "PUBLIC_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "PUBLIC_NORMAL", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "PUBLIC_HIGH", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "PUBLIC_LOW", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
				   					<%--其他--%>
									{ header: "計算件數", key: "OTHER_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "OTHER_NORMAL", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "OTHER_HIGH", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                         }},
									{ header: "偏低", key: "OTHER_LOW", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }}
								]
						}
					return grid ;
					}
				}else{
					if( kind == '1' ){
						grid ={	
								table:$('grid1'), allSortable: true, split:["TOTAL_NORMAL"],
								column:[
										{ header: basicHeaderNM,
										  key:  basicKeyNM,
										  groupKey: [basicKeyNM],sortable:false,
										  attrs:{rowSpan:2},
										  render : 
											  function(rec){
				                                return  actions.returnLinkInfo(rec , basic,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
				                            }
											 
										},
									{ header: "日期區間", key: "TIME_RANGE", attrs:  {rowSpan:2} },
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') ;
			                            } },
									{ header: "總命中率", attrs:{colSpan:3}, empty:'rowSpan_down'},
									{ header: "壽險端", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "銀行端", attrs:{colSpan:4}, empty:'rowSpan_down'},
		
									{ header: "正常",key: "TOTAL_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "偏高", key: "TOTAL_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "TOTAL_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "計算件數", key: "LIFE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "LIFE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "LIFE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "LIFE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "計算件數", key: "BANK_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "BANK_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "BANK_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "BANK_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }}
								]
							}
						return grid;
					}else if( kind == '2' ){
						grid={	table:$('grid1'), allSortable: true, split:["HOUSE_COUNT"],
								column:[
										{ header: basicHeaderNM,
										  key:  basicKeyNM,
										  attrs:{rowSpan:2}, 
										  groupKey: [basicKeyNM],sortable:false,
										  render : 
											  function(rec){
				                                return  actions.returnLinkInfo(rec , basic ,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
				                            }
										},
									{ header: "日期區間", key: "TIME_RANGE", attrs:{rowSpan:2} },
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') ;
			                            } },
									{ header: "總體正常", key: "TOTAL_NORMAL", attrs:{rowSpan:2},renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏高", key: "TOTAL_HIGH",  attrs:{rowSpan:2},renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏低", key: "TOTAL_LOW",  attrs:{rowSpan:2},renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "住宅大樓", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "住辦大樓", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "公寓", attrs:{colSpan:4},empty:'rowSpan_down'},
			                        { header: "樓中樓", attrs:{colSpan:4}, empty:'rowSpan_down' },
			                        { header: "套房", attrs:{colSpan:4}, empty:'rowSpan_down' },
									<%--住宅大樓--%>
									{ header: "計算件數", key: "HOUSE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            } },
									{ header: "正常",key: "HOUSE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "偏高", key: "HOUSE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "HOUSE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
			   						<%--住辦大樓--%>
									{ header: "計算件數", key: "OFFICE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            } },
									{ header: "正常", key: "OFFICE_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "OFFICE_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "OFFICE_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
			   						<%--公寓--%>
			                        { header: "計算件數", key: "APART_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "APART_NORMAL", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏高", key: "APART_HIGH", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
									{ header: "偏低", key: "APART_LOW", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            }},
			   						<%--樓中樓--%>
			   						{ header: "計算件數", key: "DUPLEX_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            } },
			   						{ header: "正常", key: "DUPLEX_NORMAL", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏高", key: "DUPLEX_HIGH", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏低", key: "DUPLEX_LOW", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			        				<%--套房--%>
			   						{ header: "計算件數", key: "ROOM_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
			   						{ header: "正常", key: "ROOM_NORMAL", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏高", key: "ROOM_HIGH", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                               }},
			   						{ header: "偏低", key: "ROOM_LOW", renderInCount:true,
			   							render: function(record,value){
			                                   return  (value || '0') + '%';
			                        }}
								]
						}
						return grid ;
					}else if( kind == '3' ){
						grid = { table:$('grid1'), allSortable: true, split:["LIVE_COUNT"],
								 column:[
									{ header: basicHeaderNM,
									  key:  basicKeyNM,
									  attrs: {rowSpan:2},
									  groupKey: [basicKeyNM],sortable:false,
									  render : 
										  function(rec){
			                                return  actions.returnLinkInfo(rec , basic ,kind);<%--[20210817][20210810150112] 統合超連結方法--%>	
			                            }
									},
									{ header: "日期區間", key: "TIME_RANGE", attrs:  {rowSpan:2}  },
									{ header: "計算件數", key: "TOTAL_COUNT", renderInCount:true, attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "總體正常", key: "TOTAL_NORMAL", renderInCount:true,attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏高", key: "TOTAL_HIGH", renderInCount:true,attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "總體偏低", key: "TOTAL_LOW", renderInCount:true,attrs:{rowSpan:2},
										render: function(record,value){
			                                return  (value || '0') + '%';
			                            } },
									{ header: "住家用", attrs:{colSpan:4},empty:'rowSpan_down'},
									{ header: "商業用", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "工業用", attrs:{colSpan:4}, empty:'rowSpan_down'},
									{ header: "工商用", attrs:{colSpan:4}, empty:'rowSpan_down'},
				                    { header: "住商用", attrs:{colSpan:4},empty:'rowSpan_down'},
				   					{ header: "國民住宅", attrs:{colSpan:4}, empty:'rowSpan_down'},
				   					{ header: "其他", attrs:{colSpan:4}, empty:'rowSpan_down'},
									<%--住家用--%>
									{ header: "計算件數", key: "LIVE_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常",key: "LIVE_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        } },
									{ header: "偏高", key: "LIVE_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "LIVE_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									<%--商業用--%>
									{ header: "計算件數", key: "MARKET_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "MARKET_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "MARKET_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "MARKET_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
				                    <%--工業用--%>
				   					{ header: "計算件數", key: "FACTORY_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
				   					{ header: "正常", key: "FACTORY_NORMAL", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏高", key: "FACTORY_HIGH", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏低", key: "FACTORY_LOW", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				                    <%--[20210722]工商用--%>
				   					{ header: "計算件數", key: "BUSINESS_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
				   					{ header: "正常", key: "BUSINESS_NORMAL", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏高", key: "BUSINESS_HIGH", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},
				   					{ header: "偏低", key: "BUSINESS_LOW", renderInCount:true,
				   						render: function(record,value){
				                               return  (value || '0') + '%';
				                           }},       
									<%--住商用--%>
				                    { header: "計算件數", key: "LIVE_MARKET_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "LIVE_MARKET_NORMAL", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "LIVE_MARKET_HIGH", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                        }},
									{ header: "偏低", key: "LIVE_MARKET_LOW", renderInCount:true,
										render: function(record,value){
				                            return  (value || '0') + '%';
				                     	  }},
									<%--國民住宅--%>
									{ header: "計算件數", key: "PUBLIC_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0');
			                            }},
									{ header: "正常", key: "PUBLIC_NORMAL", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
									{ header: "偏高", key: "PUBLIC_HIGH", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0')  + '%';
				                        }},
									{ header: "偏低", key: "PUBLIC_LOW", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }},
				   					<%--其他--%>
									{ header: "計算件數", key: "OTHER_COUNT", renderInCount:true,
										render: function(record,value){
			                                return  (value || '0') ;
			                            }},
									{ header: "正常", key: "OTHER_NORMAL", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0')  + '%';
				                        }},
									{ header: "偏高", key: "OTHER_HIGH", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                         }},
									{ header: "偏低", key: "OTHER_LOW", renderInCount:true,
										render: function(record,value){
				                              return  (value || '0') + '%';
				                        }}
								]
						}
					return grid ;
					}
				}
			}
			
		}
	};
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement( "DSA34000", "鑑價作業", "AVM命中率統計" );
			<cathay:LocaleDisplay dateFields='BDATE_BEG BDATE_END' sysCode='DS' var='localeDisplay' />
			
			$('BDATE_BEG').setValue(current1stDate);<%--[20210802] 問題單 20210730171405  鑑價日期起訖預設系統日--%>
			$('BDATE_END').setValue(today);

			$('btn_query').observe('click', actions.doQuery );  	
			$('btn_export').observe('click', actions.doExport );
			$('btn_clean').observe('click', actions.doClean );
			
			$('QUERY_TYPE').observe('change', actions.doSetDate );

			$('APPR_DEPT').observe('change',function(){
				actions.doGetAPPR_ID_LIST();
				}
			);
			
			displayMessage();
			actions.doGetAPPR_ID_LIST();
			autoFormatToNumber();
			
		}
	}
}

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0"
	marginheight="0">
	<form name="form1" id="form1" method="post">
		<input type="hidden" name="gridJSON" id="gridJSON" value="">

		<table width="100%" border="0" cellpadding="0" cellspacing="1"
			class="tbBox2">
			<tr>
				<td class="tbYellow">查詢種類</td>
				<td class="tbYellow2"><select name="QUERY_TYPE" id="QUERY_TYPE">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${QUERY_TYPE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow">分類種類</td>
				<td colspan="5" class="tbYellow2"><select name="KIND" id="KIND">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${KIND_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow2" align="center" rowspan="6">
					<button type="button" id="btn_query" class="button">查詢</button>
					<button type="button" id="btn_clean" class="button">清除</button>
					<button type="button" id="btn_export" class="button">匯出</button>
				</td>
			</tr>

			<tr>
				<td class="tbYellow">歸類依據</td>
				<td class="tbYellow2"><select name="BASIC" id="BASIC">
						<option value=''>請選擇</option>
						<c:forEach var="map" items="${BASIC_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow">是否為買賣件</td>
				<td class="tbYellow2" colSpan="3"><select name="WELL_CONTRACT"
					id="WELL_CONTRACT">
						<option value=''>全部</option>
						<c:forEach var="map" items="${WELL_CONTRACT_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
			</tr>
			<tr>
				<td class="tbYellow">鑑價日期</td>
				<td class="tbYellow2"><input name="BDATE_BEG" id="BDATE_BEG"
					type="text" class="textBox2" size="10" maxlength="7"> ~ <input
					name="BDATE_END" id="BDATE_END" type="text" class="textBox2"
					size="10" maxlength="7"></td>
				<td class="tbYellow">日期區間</td>
				<td class="tbYellow2" colSpan="3"><select name="TIME_RANGE"
					id="TIME_RANGE">
						<option value=''>全部</option>
						<c:forEach var="map" items="${TIME_RANGE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
			</tr>
			<tr>
				<td class="tbYellow">鑑價科</td>
				<td class="tbYellow2"><select name="APPR_DEPT" id="APPR_DEPT">
						<option value=''>全部</option>
						<c:forEach var="map" items="${APPR_DEPT_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow">鑑價員</td>
				<td class="tbYellow2"><select name="APPR_ID" id="APPR_ID" alt="ch"><%--[20240930]難字調整 --%>
						<option value=''>全部</option>
						<c:forEach var="map" items="${APPR_ID_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
				<td class="tbYellow">縣市別</td>
				<td class="tbYellow2"><select name="CITY" id="CITY">
						<option value=''>全部</option>
						<c:forEach var="map" items="${CITY_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
				</select></td>
			</tr>
			<tr>
				<td class="tbYellow">單價(萬/坪)</td>
				<td class="tbYellow2"><input type="text" class="textBox2"
					size="8" maxlength="8" name="PRICE_LOW" id="PRICE_LOW"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /> ~ <input type="text" class="textBox2"
					size="8" maxlength="8" name="PRICE_HIGH" id="PRICE_HIGH"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /></td>
				<td class="tbYellow">總價(萬)</td>
				<td class="tbYellow2"><input type="text" class="textBox2"
					size="8" maxlength="8" name="TOTAL_PRICE_LOW" id="TOTAL_PRICE_LOW"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /> ~ <input type="text" class="textBox2"
					size="8" maxlength="8" name="TOTAL_PRICE_HIGH"
					id="TOTAL_PRICE_HIGH"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /></td>
				<td class="tbYellow">面積(坪)</td>
				<td class="tbYellow2"><input type="text" class="textBox2"
					size="8" maxlength="8" name="AREA_LOW" id="AREA_LOW"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /> ~ <input type="text" class="textBox2"
					size="8" maxlength="8" name="AREA_HIGH" id="AREA_HIGH"
					style="text-align: right; padding-right: 3px;" pattern="#,###.##"
					datatype="number" /></td>
			</tr>
		</table>
		<table id='grid1' width="100%"></table>

	</form>


</body>
</html>
