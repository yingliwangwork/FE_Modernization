
<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA31400.jsp
作者：張智翔
功能：鑑價件數作業。
完成：2012/04/11
[20240930]難字調整
[20241211] 新增現勘數據相關判斷
[20241218] 新增設定spMemo
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
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>			<%-- 日期用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>	<%-- POP視窗用 --%>
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

// 產生畫面物件
var DSA31400 = new DSA31400();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSA31400.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31400(){
	//檢核變數
	var valid1;	
	var valid2;	
	var valid3;
	
	var columnLoad = [
		[ //鑑價件數明細查詢結果
			{header: "序號",key: "NO"},						
			{header: "受理編號",key: "APPLY_ID"},
			
			{header: "建築型態",key: "USE_FOR_NM"},
			{header: "鑑估總價",key: "BOSS_TOTAL_PRICEA"},
			{header: "擔保品分區 ",key: "AREA_CODE"},
			{header: "是否VIP客戶 ",key: "IS_VIP"},
			{header: "未照室內照原因",key: "NOPIC_REASON_NM"},
			
			{header: "案件類別",key: "APPR_TYPE_NM"},
			{header: "案件沿用編號",key: "FOLLOW_NUMBER"},
			{header: "受理進度",key: "APPR_PROCESS_NM"},
			{header: "派件日期",key: "APPLY_DATE",
				render : function(rec , val){
					return Date.toInputROC(val || "","/");
				}			
			},
			{header: "覆核(退件)日期",key: "REPORT_DATE",
				render : function(rec , val){
					return Date.toInputROC(val || "","/");
				}
			},
			{header: "郵遞區號",key: "GAGE_ZIP"},
			{header: "轉換件數",key: "APPR_COUNT"},
			{header: "鑑價組",key: "APPR_GROUP_NM"},
			{header: "鑑價員",key: "APPR_NM", attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>
			{header: "覆核組長",key: "APPR_CAPT_NM", attrs:{style:"font-family:'EUDC'"}}<%--[20210609] 立案單號:210610016185 新增覆核組長 [20240930]難字調整 --%>
		],
		
		//鑑價件數統計查詢
		[
			{header: "鑑價員",key: "APPR_NM" , attrs:{ rowSpan : 4 },                        
				render : function(rec , val){
					if(val){
						<%--[20240930]難字調整 --%>
						var link = new Element("a" , { href : "#", style:"font-family:'EUDC'" } ).update(val);
						link.observe( 'click', function (event){ 							
							popupWin.windowOpen('<%=dispatcher%>/DSA3_1401/prompt',{
								'parameters': { 											
									APPR_ID : rec.APPR_ID,
									APPR_DEPT: $('APPR_DEPT').value,
									APPR_GROUP: $('APPR_GROUP').value,
									TYPE :  rec.TYPE,
									BDATE_BEG :  queryCondition.BDATE_BEG,
									BDATE_END :  queryCondition.BDATE_END	
								}
							});						
						});		
						return link;
					}else{
						return "";
					}
				}
			},					
			//總件數
			{header: "換算件數",key: "TotalCount", attrs:{ rowSpan : 2 }},
			{header: "派件件數",key: "Count", attrs:{ rowSpan : 2 }},
			{header: "壽險端",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "銀行(消金)",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "銀行(企金)",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "土建融案",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "整批分戶",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "隱藏的群組資料 ",key: "TYPE", attrs:{ rowSpan : 4 },groupKey:["TYPE"]},
			//壽險端.換算件數
			{header: "換算件數",key : "TotalCount1"},
			{header: "派件件數",key : "Count1"},
			//銀行(消金) 
			{header: "換算件數",key : "TotalCount2"},
			{header: "派件件數",key : "Count2"},
			//銀行(企金) 
			{header: "換算件數",key : "TotalCount3"},
			{header: "派件件數",key : "Count3"},
			//土建融案 
			{header: "換算件數",key : "TotalCountA"},
			{header: "派件件數",key : "CountA"},
			//整批分戶
			{header: "換算件數",key : "TotalCountB"},
			{header: "派件件數",key : "CountB"},
			
			{header: "引導查封",key : "cut2" , empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "法務勘估",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "複查",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "產險轉送",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "其他",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			{header: "銀行訪催",empty:'rowSpan_down', attrs:{ colSpan : 2 }},
			
			//引導查封
			{header: "換算件數",key : "TotalCountC"},
			{header: "派件件數",key : "CountC"},
			//法務勘估
			{header: "換算件數",key : "TotalCountD"},
			{header: "派件件數",key : "CountD"},
			//複查
			{header: "換算件數",key : "TotalCountE"},
			{header: "派件件數",key : "CountE"},
			//產險轉送
			{header: "換算件數",key : "TotalCountF"},
			{header: "派件件數",key : "CountF"},
			//其他
			{header: "換算件數",key : "TotalCountG"},
			{header: "派件件數",key : "CountG"},
			//銀行訪催
			{header: "換算件數",key : "TotalCountH"},
			{header: "派件件數",key : "CountH"}
		],
		//鑑價時效統計_組員
		[	
			{header: "鑑價員",key: "APPR_NM", attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>					
			{header: "派件件數 ",key: "ASSIGN_COUNT"},
			{header: "換算件數",key: "APPR_COUNT"},
			{header: "鑑價天數A",key: "APPR_DAYS_A"},
			{header: "鑑價時效A",key: "APPR_TIMES_A"},
			{header: "鑑價天數B",key: "APPR_DAYS_B"},
			{header: "鑑價時效B",key: "APPR_TIMES_B"},
			{header: "鑑價天數C",key: "APPR_DAYS_C"},
			{header: "鑑價時效C",key: "APPR_TIMES_C"},
			{header: "隱藏的群組資料",key: "APPR_GROUP", groupKey:["APPR_GROUP"]}
		],
		//鑑價時效統計_組長
		[			
			{header: "姓名",key: "APPR_NM", attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>						
			{header: "派件件數",key: "ASSIGN_COUNT"},
			{header: "換算件數",key: "APPR_COUNT"},
			{header: "鑑價天數A",key: "APPR_DAYS_A"},
			{header: "鑑價時效A",key: "APPR_TIMES_A"},
			{header: "鑑價天數B",key: "APPR_DAYS_B"},
			{header: "鑑價時效B",key: "APPR_TIMES_B"},
			{header: "鑑價天數C",key: "APPR_DAYS_C"},
			{header: "鑑價時效C",key: "APPR_TIMES_C"}
		],
		//鑑價評分明細
		[			
			{header: "受理編號",key: "APPLY_ID"},						
			{header: "鑑價組",key: "APPR_GROUP_NM"},
			{header: "鑑價員",key: "APPR_NM", attrs:{style:"font-family:'EUDC'"}},<%--[20240930]難字調整 --%>
			{header: "覆核日期",key: "FIRST_BOSS_DATE",
				render : function(rec , val){
					return Date.toInputROC(val || "","/");
				}
			},
			{header: "錯誤原因",key: "RETURN_ITEM_NM"},
			{header: "錯誤說明",key: "NOTE"}
		],
		<%--[20241211] 新增現勘數據欄位--%>
		[
			{header: "現勘人員",key: "PROP_INSPECTION_NAME", attrs:{style:"font-family:'EUDC'"}},						
			{header: "現勘日期",key: "PROP_INSPECTION_DATE"},
			{header: "現勘件數",key: "PROP_INSPECTION_CNT"},
			{header: "現勘案件受編/社區編號JSON",key: "CASE_NO_JSON"},
			{header: "最順路徑順序",key: "SMOOTH_PATH_SEQ"},
			{header: "最小路程距離(公尺)",key: "SHORT_PATH_DISTANCE"},
			{header: "路程不停留時間(秒)",key: "DISTANCE_TIME"}
		]
	];
	var grid;		
	//前次查詢條件
	var queryCondition = {};
	
	var REPORT_LIST = <c:out value = "${REPORT_LIST}" default = "{}" escapeXml = "false" />;
	// 案件類別下拉選單 for type = 1
	var APPR_TYPE_LIST1 = <c:out value = "${APPR_TYPE_LIST1}" default = "{}" escapeXml = "false" />;
	// 案件類別下拉選單 for type = 3,4
	var APPR_TYPE_LIST34 = <c:out value = "${APPR_TYPE_LIST34}" default = "{}" escapeXml = "false" />;
	
	var GROUP_LIST =  <c:out value = "${GROUP_LIST}" default = "{}" escapeXml = "false" />;
	//按鈕權限
	function buttonAuth(){
		var authButtons = {
				B0021:"btn_export"<%--匯出--%> 				
		};
		
		<dz:grantButtons FUNC_ID="DSA31400" ignored="false"/>
	}
	//畫面檢核
	function initValidation(){
	
		Validation.addAllThese([		
			[ 'validateChooseAPPR_DeptGroup',  '鑑價科與鑑價組請擇一輸入一項', 
			//鑑價科與鑑價組其中兩個只能擇一輸入
			function(){				
				var APPR_DEPT = $("APPR_DEPT").value;
				var APPR_GROUP = $("APPR_GROUP").value;		
				if( (APPR_DEPT !=="" && APPR_GROUP !=="") || (APPR_DEPT ==="" && APPR_GROUP ==="")){					
					return false;
				}else{
					return true;
				}
			}],
			[ 'validateChooseAPPR_DeptGroupGroup',  '請輸入鑑價科(組)別', 
			///鑑價科與鑑價組必須輸入
			function(){				
				var APPR_DEPT = $("APPR_DEPT").value;
				var APPR_GROUP = $("APPR_GROUP").value;	
				if( (APPR_DEPT =="" && APPR_GROUP =="" ) ){					
					return false;
				}else{
					return true;
				}
			}],
			[ 'validateChooseAPPR_GroupAppr',  '鑑價組與組別請擇一輸入一項', 
			//鑑價組與組別其中兩個只能擇一輸入
			function(){				
				var GROUP = $("GROUP").value;
				var APPR_GROUP = $("APPR_GROUP").value;	
				var APPR_DEPT = $("APPR_DEPT").value;
				if( (APPR_DEPT =="" && GROUP !=="" && APPR_GROUP !=="") || (APPR_DEPT =="" && GROUP ==="" && APPR_GROUP ==="") || (APPR_DEPT !=="" && GROUP !=="" && APPR_GROUP !=="") ){					
					return false;
				}else{
					return true;
				}
			}],
			[ 'validateGroupDept',  '選擇了組別，鑑價科必須輸入！', 
			//選擇了組別，鑑價科要有值
			function(){				
				var GROUP = $("GROUP").value;
				var APPR_DEPT = $("APPR_DEPT").value;		
				return (GROUP !== ""  &&  APPR_DEPT === "" )? false : true;
			}],
			[ 'validateDiffDay',  '查詢日期區間不得超過一個月(30天)', 
			//查詢日期區間不得超過一個月(30天)
			function(){				
				var ADATE_BEG = $("ADATE_BEG").value;
				var ADATE_END = $("ADATE_END").value;
				return diffDay(ADATE_BEG , ADATE_END , true) > 30 ? false : true;				
			}]
		]);
		//查詢 鑑價件數明細 用檢核
		valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid1.define( "validate-ROCDate" , { id: "BDATE_BEG" } );	
		valid1.define( "validate-ROCDate" , { id: "BDATE_END" } );
		valid1.define( "required" , { id: "BDATE_BEG" } );	
		valid1.define( "required" , { id: "BDATE_END" } );	
		valid1.define( "validateDiffDay" , { id: "BDATE_BEG" } );	
		valid1.define( "validateDiffDay" , { id: "BDATE_END" } );	
		valid1.define( "validate-ROCDate-Interval" , [{ id : "BDATE_BEG" },{ id: "BDATE_END" }] );		
		valid1.define( "validateChooseAPPR_DeptGroup" , { id: "APPR_DEPT" } );			
		valid1.define( "validateChooseAPPR_DeptGroup" , { id: "APPR_GROUP" } );	
		
		//查詢 鑑價件數統計 用檢核
		valid2 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid2.define( "validate-ROCDate" , { id: "BDATE_BEG" } );	
		valid2.define( "validate-ROCDate" , { id: "BDATE_END" } );
		valid2.define( "required" , { id: "BDATE_BEG" } );	
		valid2.define( "required" , { id: "BDATE_END" } );
		valid2.define( "validateChooseAPPR_DeptGroupGroup" , { id: "APPR_DEPT" } );			
		valid2.define( "validateChooseAPPR_GroupAppr" , [{ id: "APPR_GROUP" }, { id: "GROUP" }] );			
		
		
		//查詢 鑑價時效統計_組員or鑑價時效統計_組長 用檢核
		valid3 = new Validation("form1", { focusOnError:true, immediate:false });	
		valid3.define( "validate-ROCDate" , { id: "BDATE_BEG" } );	
		valid3.define( "validate-ROCDate" , { id: "BDATE_END" } );
		valid3.define( "required" , { id: "BDATE_BEG" } );	
		valid3.define( "required" , { id: "BDATE_END" } );
		valid3.define( "required" , { id: "APPR_DEPT" } );
			
	}
    

	
	
	//共用的Ajax
		function ajaxPost ( actionName, params, successFunction, errorFunction){	
			new Ajax.Request( "<%=dispatcher%>/DSA3_1400/" + actionName,
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
	
	//buttons對應的event function
	var buttons = {	
		//查詢資料
		doQuery : function(event){	
			valid1.reset();
			valid2.reset();
			valid3.reset();
			var key;
			var sendRecord;
			//取得當前的選擇種類
			var changeType = $$('#queryType input:checked[type=radio]');				
			if(changeType.length == 0){				
				alert("請先選擇查詢種類");
				return;
			}else{
				key = changeType[0].value;				
				if(key == 1){
					if(!valid1.validate()){ 
						return; 
					}
				}else if(key == 2 || key == 5){
					if(!valid2.validate()){ 
						return; 
					}
				}else if(key == 3 || key == 4){
					if(!valid3.validate()){ 
						return; 
					}
				}
				//將畫面欄位存成record			
				sendRecord = makeRecord(key);					
			}			
			
			
			//將查詢條件存起來			
			queryCondition = sendRecord;				
			//發送ajax
			ajaxPost( 'query' , {sendRecord : Object.toJSON(sendRecord)	},
				function(resp){	
					var totalCoungObj = makeTotalObj(resp.totalMap);
					var subTotalObj = makeSubObj(resp.subTotalMap,key);
					var rtnList = resp.rtnList;
					if(key == 1 || key == 6){<%--[20241211] 新增現勘數據判斷--%>
						//當為 鑑價件數明細 , 不計算加總跟小計
						grid.load(rtnList);						
					}else if (key == 4){
						//當為 鑑價時效統計_組長 , 只算加總
						grid.load(rtnList , totalCoungObj );
					}else if (key == 2 || key == 5){						
						//當為 鑑價件數統計 
						grid.load(rtnList , [] , subTotalObj);					
					}else{
						//當為  鑑價時效統計_組員 算加總跟小計
						grid.load(rtnList , totalCoungObj , subTotalObj);			
					}
				},
				function(resp){					
					//失敗把前次內容清掉 
					grid.load([]);			
				}
			);		
		},				
		
		//根據條件連動ajax
		doAPPR_ID_Ajax : function APPR_ID_Ajax(eventId , eventValue){	
			//先取出查詢種類
			var changeType = $$('#queryType input:checked[type=radio]');
			var changeTypeId;
			
			//假設選出來的陣列 < 0 ,代表user還沒選查詢種類,不給做ajax
			if(changeType.length > 0 ){
				//有選,將查詢種類記下來
				changeTypeId = changeType[0].value;			
			}else{		
				$(eventId).value = "";				
				alert("請先選擇查詢種類再行設定鑑價人員！");
				return;
			}			
			//判斷 查詢種類為 1或2 且連動是否為APPR_GROUP觸發
			var checkBoolean1 = (changeTypeId ==1  && (eventId ==="APPR_GROUP"));
			var checkBoolean2 = (changeTypeId ==2 || changeTypeId ==6);<%--[20241211] 新增現勘數據判斷--%>
			//判斷 查詢種類為 3或4
			var checkBoolean34 = changeTypeId ==3 || changeTypeId ==4;
			//連動種類
			var type = "";
			if(eventValue !== "" || checkBoolean2){
				//當查詢種類為 1 , 只有鑑價組可以連動鑑價員 , 鑑價科沒連動,但是還是可以當條件
				if(checkBoolean1){
					type = "group1";
				//當查詢種類為 2 , 只有鑑價組可以連動鑑價員 , 鑑價科沒連動,但是還是可以當條件
				} else if(checkBoolean2){
					type = "group2";
				//當查詢種類為 3或4 , 只有鑑價科可以連動鑑價員
				}else if(checkBoolean34 ){
					type = "dept";
				}
				
				//如果不符合以上的條件,就不發送ajax
				if(type !==""){
					ajaxPost( 'makeList' , {idValue : eventValue , type : type, APPR_DEPT: $F('APPR_DEPT'), GROUP: $F('GROUP'), APPR_GROUP: $F('APPR_GROUP')},
						function(resp){						
							appendList(resp.APPR_ID_LIST , $("APPR_ID"));
						}
					);
				}
			} else if(checkBoolean1 || checkBoolean34){
				//如果 查詢種類為 1或2 且連動是由APPR_GROUP觸發	或是查詢種類為3,或4 才清空
				//如果為空值,代表全部,將鑑價員清空
				updateList($("APPR_ID"));
			}
		},
		
		//匯出
		doExport : function(event){
			if(!grid || grid.getAllRecords().length == 0){
				alert("請先查詢資料再匯出");
				return;
			}	
				//取得當前的選擇種類
			var key = $$('#queryType input:checked[type=radio]')[0].value;					
			var currentRecord = makeRecord(key);	
			
			for(valueKey in currentRecord){
				if(currentRecord[valueKey] !== queryCondition[valueKey]){
					alert("列印時查詢條件與查詢時不同,請依新條件重新查詢再列印");
					return;
				}
			}
		
			//要載入的表格
			var loadGrid;
			//檔名
			var fileName;
			if(key === "2" || key ==="3"){ //當為 鑑價件數統計 鑑價時效統計_組員
				//複製陣列
				var tempGridArray = columnLoad[key-1].slice();		
				//var tempGridArray = columnLoad[4];
				//將第一筆去除
				tempGridArray.splice(0,1);				
				//產生新的標頭
				var gridTemp = new TableUI ( {
					table: $("tempgrid"), pageSize: 10, allSortable:true , split: ['TotalCount1' , 'cut2' , 'TotalCountC'],					
					<%-- [20240930] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:	tempGridArray
				});	
				$("tempgrid").parentNode.style.display = "none";
				fileName = REPORT_LIST[key] + "_" + $("BDATE_BEG").value + "_" + $("BDATE_END").value;
				loadGrid = gridTemp;				
			}else{ //當為 鑑價件數明細  鑑價時效統計_組長
				fileName = REPORT_LIST[key] + "_" + $("BDATE_BEG").value + "_" + $("BDATE_END").value;
				loadGrid = grid;
			}
			//加入檔名			
			currentRecord["fileName"] = fileName;
			//加入表頭內容
			$('gridJSON').value = loadGrid.getXlsSettingJSON(fileName);			
			//查詢條件加入
			$('sendRecord').value = Object.toJSON(currentRecord);	
			//Form submit
			RPTUtil.executeCreateCsvFile("<%=dispatcher%>/DSA3_1400/export", Form.serialize("form1") );		
		
		},
		
		//清除畫面 回到初始狀況
		doClear : function(event){
			//將 鑑價人員,清空			
			$('form1').reset();		
			if(grid){
				grid.load([]);				
			}
			$("grid").parentNode.style.display = "none";
			//將 鑑價人員 案件類別,清空
			updateList($("APPR_ID"));
			$("APPR_TYPE").update();			
			//加入組別下拉選單				
			appendList(GROUP_LIST , $("GROUP"));
			//將所有下拉選單解開
			var input = $$('#tableA input[type=text]' , '#tableA select');		
			input.each(
				function(elem){
					elem.enable();
				}
			)

			$("ADATE_BEG").value = toROC("${current1stDate}");
			$("ADATE_END").value = toROC("${today}");
			
			$("BDATE_BEG").value = toROC("${current1stDate}");
			$("BDATE_END").value = toROC("${today}");

		}
	}	
	
	//將畫面A資料存成Record
	function makeRecord(reportVlaue){
		var sendRecord = {
			REPORT	: reportVlaue,// 查詢種類
			APPR_DEPT	: $('APPR_DEPT').value ,// 鑑價科	
			APPR_GROUP	: $('APPR_GROUP').value ,// 鑑價組
			GROUP	: $('GROUP').value ,// 組別
			APPR_ID	: $('APPR_ID').value ,// 鑑價員	
			APPR_PROCESS	: $('APPR_PROCESS').value ,// 案件進度		
			APPR_TYPE	: $('APPR_TYPE').value ,// 案件類別
			ADATE_BEG	: toY2K($('ADATE_BEG').value) ,// 派件日期起	
			ADATE_END	: toY2K($('ADATE_END').value) ,// 派件日期迄	
			BDATE_BEG	: toY2K($('BDATE_BEG').value) ,// 覆核日期起	
			BDATE_END	: toY2K($('BDATE_END').value) // 覆核日期迄
			
		}
		return sendRecord;	
	}			
	
	//將List增加到下拉選單中 , 傳入的可能為list或map
	function appendList(list , target , type){		
		//先清除
		if(type === 'APPR_TYPE'){
			$('APPR_TYPE').update();
		}else{
			updateList(target);	
		}
		//加入List
		if(list){//當list存在
			if(list.length > 0){			
				for(var i = 0; i < list.length; i++){ 
					target.options.add(new Option(list[i]['NAME'], list[i]['ID'])); 
				}
			}else{
				for(key in list){
					target.options.add(new Option(list[key],key)); 			
				}
			}
		}
	}

	//將收下拉選單清除,加入請選擇 , target為要清除的dom物件
	function updateList(target){
		target.update();
		//請選擇
		target.options.add(new Option( "全部" , "")); 
	}
	
	//選單,輸入控制
	function buttonsControl(key){	
		//全部disabled
		var input = $$('#tableA input[type=text]' , '#tableA select');		
		input.each(
			function(elem){				
				elem.disable();				
			}
		)
		var enableName;
		var classNamekey;
		<%--[20241218] 新增重置spMemo文字--%>
		$('spMemo').innerHTML = '';
		//依照需求打開功能
		if(key == 1){
			enableName = '.class1';
			classNamekey = '.date1';
		}else if(key == 2 || key == 5){
			enableName = '.class2';
			classNamekey = '.date2';
		}else if(key == 3 || key == 4){
			enableName = '.class34';
			classNamekey = '.date2';			
		}else if(key == 6){ <%--[20241211] 新增現勘數據判斷--%>
			enableName = '.class6';
			classNamekey = '.date2';
			<%--[20241218] 新增設定現勘數據spMemo文字--%>
			$('spMemo').innerHTML = "現勘數據查詢時，覆核日期期間為現勘日期期間";
		}
		
		dateImgControl(classNamekey);
		
		//將功能1下拉選單打開			
		var func = $$(enableName);		
			func.each(
				function(elem){
					elem.enable();
			}
		)
		
		//將被disabled欄位清空
		var hide = $$('#tableA :disabled[type!=button]');		
			hide.each(
				function(elem){
					elem.value = "";
			}
		)	
	}
	
	//小日期圖案功能開關
	function dateImgControl(classNamekey){
		//全部hide
		var input = $$('#tableA img');		
		input.each(
			function(elem){				
				elem.hide();				
			}
		)
		
		//可以使用的show
		var dateName = $$(classNamekey);		
		dateName.each(
			function(elem){
				elem.show();
			}
		)
	}
	
	//依照功能創造下拉選單
	function makeSelfList(key){		
		//先做功能控制
		buttonsControl(key);
		//再依各別產生相對應的選單
		if(key ==3 || key == 4){
			$("BDATE_BEG").value = toROC("${current1stDate}");
			$("BDATE_END").value = toROC("${today}");
			appendList(APPR_TYPE_LIST34 , $("APPR_TYPE") ,'APPR_TYPE');
			updateList($("GROUP"));
			buttons.doAPPR_ID_Ajax("APPR_DEPT" , $("APPR_DEPT").value);
		}else{
			//清空鑑價人員ID與組別, 因為有可能是KEY = 3 或 4切換到1
			if(key == 1 ){
				//當為1 加入案件種類選單
				$("BDATE_BEG").value = toROC("${today}");
				$("BDATE_END").value = toROC("${today}");
				appendList(APPR_TYPE_LIST1 , $("APPR_TYPE") , 'APPR_TYPE');		
				updateList($("GROUP"));
			}else{
				//當為2 , 有組別,因此加入組別下拉選單
				$("BDATE_BEG").value = toROC("${current1stDate}");
				$("BDATE_END").value = toROC("${today}");
				appendList(GROUP_LIST , $("GROUP"));	
				$("APPR_TYPE").update();	
			}		
			updateList($("APPR_ID"));
			buttons.doAPPR_ID_Ajax("APPR_GROUP" , $("APPR_GROUP").value);
		}
	}
	
	//動態產生radio button
	function makeRadiobuttons(){	
		
		for(var key in REPORT_LIST){	
			var link = new Element( "input" , {  type : "radio" , name : "REPORT" , id : "REPORT_" +key , value : key } ); 
			link.observe( 'click', 
			function (event){ 
				var keyValue = event.target.value;
				$("grid").parentNode.style.display = "";							
				grid = new TableUI ( {
					table: $("grid"), pageSize: 10, allSortable:true , split: ['TotalCount1' , 'cut2' , 'TotalCountC'],					
					column:	columnLoad[keyValue-1],
					<%-- [20240930] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						<%-- [20240930] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						//當為 鑑價件數統計 , 才要做Group , 因為Load的culumn不想顯示APPR_GROUP , 因此下面程式就是在把那個欄位Hide
						if(keyValue == 2 ){
							$("grid").select("*[name=TYPE]").each(
								function(elem){
									elem.hide();								
								}
							)
							/*$("grid").select("tr.tbBlue2").each(
								function(elem){ 
									if(!elem.firstChild.className) {
										elem.firstChild.colSpan = (elem.firstChild.colSpan - 1 )|| 0 
									} 
								}
							)*/
						}else if(keyValue == 3){
							$("grid").select("*[name=APPR_GROUP]").each(
								function(elem){
									elem.hide();								
								}
							)
							/*$("grid").select("tr.tbBlue2").each(
								function(elem){ 
									if(!elem.firstChild.className) {
										elem.firstChild.colSpan = (elem.firstChild.colSpan - 1 )|| 0 
									} 
								}
							)*/
						}
					}
				});	
				//當為 鑑價件數統計 , 才要做Group
				if(keyValue == 2){
					$("grid").select("th[name=TYPE]").each(
						function(elem){
							elem.style.display = "none" ; 
						}
					)
				}else if(keyValue == 3) {
					$("grid").select("th[name=APPR_GROUP]").each(
						function(elem){
							elem.style.display = "none" ; 
						}
					)
				}		
				makeSelfList(keyValue);
			});	
			$("queryType").appendChild(link);
			$("queryType").insert(REPORT_LIST[key]);
		}	
	}

	/*創造小計Obj
	SubTotalMap內的內容是依照順序將群組的小計放入
	ex , key  :   value 
		 桃園 :   桃園的小計Map*/
	function makeSubObj(subTotalMap,keyValue){
		var subTotal = [];			
		
		for(key in subTotalMap){
			var tempMap = {			
				textAlign 	: 'center', //文字靠右
				value		: subTotalMap[key] //小計Map 
			}
			if(keyValue == 2){
				tempMap.key = { TYPE : key}
				tempMap.text = '合計';
			}else{				
				tempMap.key =  { APPR_GROUP : key}
				tempMap.text = subTotalMap[key].APPR_GROUP_NM + "小計" ;
			}
			subTotal.push(tempMap); //放入陣列		
		}		
		return [subTotal];	
	}
	
	//產生合計Obj
	function makeTotalObj(totalMap){		
		//產生合計Obj
		var totalObj = [
			{text: "合計" ,textAlign : 'center' , value: totalMap}
		];	
		return totalObj;
	}

	return {

			initApp : function() {		
				PageUI.createPage("DSA31400", "鑑價作業", "鑑價件數作業", 0);			
				PageUI.loadin([{elem : "form1" },{elem : "grid" }]);	 
				
				buttons.doClear();
				
				//註冊DOM物件
				//click事件
				$("btn_query").observe("click", buttons.doQuery );				
				$("btn_clear").observe("click", buttons.doClear );		
				$("btn_export").observe("click", buttons.doExport );
				$("APPR_DEPT").observe("change", function(event){buttons.doAPPR_ID_Ajax( "APPR_DEPT" , $("APPR_DEPT").value)});	
				$("APPR_GROUP").observe("change", function(event){buttons.doAPPR_ID_Ajax( "APPR_GROUP" , $("APPR_GROUP").value)});
				$("GROUP").observe("change", function(event){buttons.doAPPR_ID_Ajax( "APPR_GROUP" , $("APPR_GROUP").value)});
				
				//加入組別下拉選單				
				appendList(GROUP_LIST , $("GROUP"));
				
				initValidation();	
				
				fix();

				displayMessage();				
						
				makeRadiobuttons();
				
				buttonAuth();
				
				autoFormatToDate();						
			}
	};	
};

</script>
</head>
<body>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<input type="hidden" name="sendRecord" id="sendRecord" value=""><%--  列印查詢條件 --%>	
		<input type="hidden" name="gridJSON" id="gridJSON" value=""><%--  匯出內容 --%>	
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				查詢種類
			</td>
			<td class="tbYellow2" id = "queryType" colspan = "7">
				
			</td>	
			<td class="tbYellow2"  align = "center" rowspan="5">
				<input id = "btn_query" type = "button" class = "button" value = "查詢"/>
				<input id = "btn_clear" type = "button" class = "button" value = "清除"  /><p>
				<input id = "btn_export" type = "button" class = "button" value = "匯出" />
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				派件日期
			</td>
			<td class="tbYellow2" colspan = "3">
				<input name="ADATE_BEG" id='ADATE_BEG' type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate" fieldName = "派件日期起">
				<img id="calImg1" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ADATE_BEG'))">
				~
				<input name="ADATE_END" id='ADATE_END' type="text" class="textBox2" size="8" maxlength="7" datatype="ROCDate" fieldName = "派件日期迄">
				<img id="calImg2" src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('ADATE_END'))">  
			</td>	
			<td class="tbYellow" width="8%" align="left" >
				覆核日期
			</td>
			<td class="tbYellow2" colspan = "3">
				<input name="BDATE_BEG" id='BDATE_BEG' type="text" class="textBox2 class1 class2 class34 class6" size="8" maxlength="7" datatype="ROCDate" fieldName = "覆核日期起">
				<img id="calImg3" src="<%=imageBase%>/CM/calendar.gif" class ="date1 date2" alt="Date" onclick="getCalendarFor($('BDATE_BEG'))">
				~
				<input name="BDATE_END" id='BDATE_END' type="text" class="textBox2 class1 class2 class34 class6" size="8" maxlength="7" datatype="ROCDate" fieldName = "覆核日期迄">
				<img id="calImg4" src="<%=imageBase%>/CM/calendar.gif" class ="date1 date2" alt="Date" onclick="getCalendarFor($('BDATE_END'))">  
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				鑑價科
			</td>
			<td class="tbYellow2">
				<select  id="APPR_DEPT" class = "class1 class2 class34 class6" fieldName = "鑑價科">				
						<option value="">全部</option>
					<c:forEach items="${APPR_DEPT_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select> 
			</td>	
			<td class="tbYellow" width="8%" align="left" >
				鑑價組
			</td>
			<td class="tbYellow2">
				<select  id="APPR_GROUP" class = "class1 class2 class6" fieldName = "鑑價組">				
						<option value="">全部</option>
					<c:forEach items="${APPR_GROUP_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>
			<td class="tbYellow" width="8%" align="left" >
				組別
			</td>
			<td class="tbYellow2">
				<select  id="GROUP" class = "class2" fieldName = "組別">				
					<option value="">全部</option>									
				</select>
			</td>	
			<td class="tbYellow" width="7%" align="left" >
				鑑價員
			</td>
			<td class="tbYellow2">
				<select  id="APPR_ID" class="class1 class2 class34 class6" alt="ch"><%--[20240930]難字調整 --%>				
					<option value="">全部</option>											
				</select>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="8%" align="left" >
				案件進度
			</td>
			<td class="tbYellow2">
				<select  id="APPR_PROCESS" class = "class1">				
						<option value="">全部</option>
					<c:forEach items="${APPR_PROCESS_LIST}" var="row">
						<option value="${row.key}"/>${row.value}</option>						
					</c:forEach>							
				</select>
			</td>	
			<td class="tbYellow" width="8%" align="left" >
				案件類別
			</td>
			<td class="tbYellow2" colspan ="5" >
				<select  id="APPR_TYPE" class= "class1 class34">
				</select>
			</td>
		</tr>
		<tr> <%-- [20241218] 新增備註行 --%>
			<td class="tbYellow2" colspan ="8" >
				<span id="spMemo"></span>
			</td>
		</tr>
		</table>
	</form>	
	<table id='grid' width="100%"></table>		
	<table id='tempgrid' width="100%"></table>		
</body>
</html>