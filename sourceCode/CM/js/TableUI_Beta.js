if(!window.HTML_locate_base || window.HTML_locate_base !== false){
	HTML_locate_base = location.href.split("servlet");

	if(HTML_locate_base.length <= 1 ){
		HTML_locate_base = location.href.split("html");
	}
	if(HTML_locate_base.length > 1 ){
		HTML_locate_base = HTML_locate_base[0];
	}else{
		HTML_locate_base = false;
	}
}

//引入CSS使用
if(HTML_locate_base){
	var calendarCssBase = HTML_locate_base +"html/CM/css/ui/TableUI.css";
	document.write('<link rel="stylesheet" type="text/css" href="'+calendarCssBase+'" />');
}

//紀錄本頁所新增的TableUI
var TableUI_settings = [];
var TableUI_horizontal_resize = null;
var TableUI_vertical_resize = null;

/** @static */
var SORT_NONE = "\u25C6";
/** @static */
var SORT_INCREASE = "\u25B2";
/** @static */
var SORT_DECREASE = "\u25BC";

function TableUI(config){
	
	if(!isObject(config)){ return; }
	
	var table = config.table;
	if(!isDOMObject(table)){
		table = document.getElementById(table);
	}
	if(!isDOMObject(table)){
		return;
	}
	
	var table_id = table.getAttribute("id");
	if(!table_id){
		table_id = new Date().getTime();
	}
	
	//DOM elemsnts
	var main_div = createDOM("div",{id:table.id},null,["tableParent"],null);
	
	var dataArea = createDOM("div",null,null,["childOfTableParent","dataArea"],null,main_div);
	var fixedDataArea = createDOM("span",null,null,["childOfDataArea","fixedDataArea"],null,dataArea);
	var displayDataArea = createDOM("span",null,null,["childOfDataArea","displayDataArea"],null,dataArea);
	
	var fixed_table = createDOM("table" , {name:"fixed",width:"100%",cellPadding:"0px",cellSpacing:"0px"} ,null,["tableGrid"],null,fixedDataArea);
	var main_table = createDOM("table", { name: "main", width: "100%", cellPadding: "0px", cellSpacing: "0px" }, null, ["tableGrid"], null, displayDataArea);
	
	table.parentNode.replaceChild(main_div ,table);

    //判斷是否分頁查詢
	var isFatchMode = !(!isNumeric(config.isLoadByFatch) && config.isLoadByFatch !== true);

    //只針對IE起作用，而且考慮IE用戶自選文件模式、Quirks模式、支援IE5、6、7、8、9及10之判斷。
	var ie_ver = false;
    /*@cc_on ie_ver = ((document.documentMode||( document.compatMode == "CSS1Compat" ? "XMLHttpRequest" in window ? @_jscript_version*10-50 : 6 : 5)))  @*/
	//isLessThenIE8 = false;
	
	//是否引入prototype 
	var hasPrototype = !!window.Prototype;
	
	//是否引入localeDisplay
	var hasLocaleDisplay = hasPrototype && !!window.localeDisplay;

    //--------------------------建立實體--------------------------
    //處理輸入參數
	var settingCtrl = new setting_impl();

	//產生title及控制項
	var pageControl = isFatchMode ? (new pageControlFatch_impl()) : new pageControl_impl();

    //產生外框控制項
	var divFitControl = new divFitControl_impl();

	//產生資料控制項
	var dataControl = new dataControl_impl();

	 //提供的functions
	this.pageCtrl = pageControl;
	this.load = pageControl.loadin;
	this.loadin = pageControl.loadin;
	this.addRecords = pageControl.addRecords;
	this.getAllRecords = pageControl.getAllRecords;
	this.getCheckedRecords = pageControl.getCheckedRecords;
	this.getCheckedRecord = pageControl.getCheckedRecords;
	this.getRecordsBySerialNo = pageControl.getRecordsBy;
	this.resetTotalCount = pageControl.resetTotalCount || (function(){});
	this.resetSubTotalCount = pageControl.resetSubTotalCount || (function(){});
	this.getTotalCount = pageControl.resetTotalCount || (function(){});
	this.getSubTotalCount = pageControl.resetSubTotalCount || (function(){});
	
	this.sort = dataControl.sort;
	this.getRecordsByCell = dataControl.getRecordsByCell;
	this.getDataObj = dataControl.getRecordsByCell;
	this.isAutoCheckBoxSelected = dataControl.isAutoCheckBoxSelected;
	this.checkAll = dataControl.autoCheckBoxSelectAll;
	this.getTableInfo = dataControl.getTableInfo;
	this.setTableInfo = dataControl.setTableInfo;
	this.disableAutoInput = dataControl.disableAutoInput;
	this.exchangeAutoInput = dataControl.exchangeAutoInput;
	this.setValueToTD = dataControl.setValueToTD;
	this.setValueToAutoInput = dataControl.setValueToAutoInput;
	this.getThisRecordTD = dataControl.getThisRecordTD;
	this.getAutoInput = dataControl.getAutoInput;
	
	this.getXlsSettingJSON = settingCtrl.getXlsSettingJSON;
	
	this.resize = divFitControl.fit;
	this.resetDiv = divFitControl.fit;
	this.resetDivHeight = divFitControl.fit;
	
	this.validTable = function(){};
	this.validCheckedOnTable = function(){};
	
	this.hide = function(){ main_div.style.display = 'none'; };
	this.show = function(){ main_div.style.display = ''; divFitControl.fit(); };
	
	
	window.setInterval( function(){
		var hor_width = main_div.offsetWidth;
		var org_hor_width =  parseInt(main_div.getAttribute('org_width')||0,10);
		var ver_height = main_div.offsetHeight;
		var org_ver_height =  parseInt(main_div.getAttribute('org_hight')||0,10);
		//console.log('outside resize check ver: '+ver_height+'  / '+org_ver_height+'  hor:'+hor_width+'  / '+org_hor_width);

		if( hor_width > 0 && ver_height > 0 && 
			( hor_width!=org_hor_width || ver_height!=org_ver_height )
		){
			main_div.setAttribute('org_width',hor_width);
			main_div.setAttribute('org_hight',ver_height);
			//console.log('inside resize call resize');
			divFitControl.fit('I');
		}
	} , 200);
	
	
	TableUI_settings.push(this);
	if(TableUI_settings.length == 1 && !TableUI_horizontal_resize && !TableUI_vertical_resize){
		TableUI_horizontal_resize = createDOM('DIV'
			,{id:'_tableUI-horizontal-resize-detection'}
			,null
			,['tableUI-resize-detection','horizontal']
			,null
			,document.body
		);
		/*TableUI_vertical_resize = createDOM('DIV'
			,{id:'_tableUI-vertical-resize-detection'}
			,null
			,['tableUI-resize-detection','vertical']
			,null
			,document.body
		);*/
		
		window.setInterval( function(){
			var hor_width = TableUI_horizontal_resize.offsetWidth;
			var org_hor_width =  parseInt(TableUI_horizontal_resize.getAttribute('org')||0,10);
			//console.log('outside resize check ver: '+ver_height+'  / '+org_ver_height+'  hor:'+hor_width+'  / '+org_hor_width);

			if(!org_hor_width){ //第一次產生不做resize
				TableUI_horizontal_resize.setAttribute('org',hor_width);
				return;
			}
			
			if( hor_width > 0 && hor_width!=org_hor_width){
				
				TableUI_horizontal_resize.setAttribute('org',hor_width);

				//console.log('outside resize call resize');
				for(var i = 0 ; i < TableUI_settings.length ; i++ ){
					if( TableUI_settings[i].resize('O' , (TableUI_settings.length * 10) ) === true ){
					/*	console.log('TableUI_settings '+i+' is delete form page, remove resize register.');
						TableUI_settings.splice( i , 1 );
						i--;*/
					} 
				}
			}
		} , 200);
	}

    //--------------------------  內部  --------------------------
    //處理設定檔
	function setting_impl() {

	    var allGroupKeys = null;
	    var settings = {};
	    this.settings = settings;
	    
	    var autoCheckBox_key;
	    this.getAutoCheckBoxKey = function(){ return autoCheckBox_key; };
	    
	    var autoCheckBox_doNotRowSpan = isObject(config.autoCheckBox) && config.autoCheckBox.doNotRowSpan === true;
	
	    //Settings for generate the DOMs
	    var hasHeaderColumns = isArray(config.headerColumn);
	    var recordSetting = formatColumnsToMatrix(config.column, config.split);
	    var headSetting = hasHeaderColumns ? formatColumnsToMatrix(config.headerColumn, config.headerSplit) : recordSetting;
	    
	    
	    
		var fixedColumns = [];
	    var hiddenColumns = [];
		var hidden_headerSetting;
		
	    var main_headerSetting;
	    var main_recordSetting;
	    var fixed_headerSetting;
	    var fixed_recordSetting;
		
		var hidden_columns_ul = createDOM("ul", { id: "hidden_columns" }, null, null, null, dataArea);
		createDOM("li", { id: "hidden_columns_open", title:"打開隱藏欄位" }, null, null, {click:function(e){ addClassName(hidden_columns_ul,"open"); }}, hidden_columns_ul);
		createDOM("li", { id: "hidden_columns_close", title:"關閉選單" }, null, null, {click:function(e){ removeClassName(hidden_columns_ul,"open"); }}, hidden_columns_ul , "已隱藏欄位");

	    //對Header設定調整
	    headSetting = createHeaderSetting(headSetting, config.allSortable !== false);
	    //對record設定調整
	    recordSetting = createRecordSetting(recordSetting);

		//設定固定欄位的群組編號
	    settingFixedGroup(headSetting, recordSetting);

	    //建立autoCheckedBox
	    createAutoCheckedBox(config, headSetting, recordSetting);

	   	createTitle(config);

	    reCreateSettings();

        //將欄位(組)置於前方固定
		this.fixedGroup = fixedGroup;
	    function fixedGroup(groupNO) {
			groupNO = parseInt(groupNO);
			
			if(isNumeric(autoCheckBox_doNotRowSpan) && autoCheckBox_doNotRowSpan == groupNO){
				alert("對不起，這個欄位已經被預設為固定，不得取消固定。");
				return;
			}
			
	        var fixed_position = isInArray(fixedColumns, groupNO);
			
	        if (fixed_position >= 0) {
	            fixedColumns.splice(fixed_position, 1);
			} else {
				var setting_length = main_headerSetting[0].length-1;
				while( !isObject(main_headerSetting[0][setting_length]) ){
					setting_length = setting_length-1;
				}
				if(setting_length == 0 || main_headerSetting[0][0].colGroup == main_headerSetting[0][setting_length].colGroup){
					alert("已經是最後一個欄位了!");
					return;
				}
	            fixedColumns.push(groupNO);
	        }
	        reCreateSettings();
			dataControl.createHeader();
		}
	    //將欄位(組)隱藏
		this.hiddenGroup = hiddenGroup;
	    function hiddenGroup(groupNO) {
			
			groupNO = parseInt(groupNO);
			
			if(isNumeric(autoCheckBox_doNotRowSpan) && autoCheckBox_doNotRowSpan == groupNO){
				alert("對不起，這個欄位已經被預設為顯示，不得隱藏。");
				return;
			}
			
			var hidden_position = isInArray(hiddenColumns, groupNO);
	        if (hidden_position >= 0) {
	            hiddenColumns.splice(hidden_position, 1);
			}else {
				var setting_length = main_headerSetting[0].length-1;
				while( !isObject(main_headerSetting[0][setting_length]) ){
					setting_length = setting_length-1;
				}
				if(setting_length == 0 || main_headerSetting[0][0].colGroup == main_headerSetting[0][setting_length].colGroup){
					alert("已經是最後一個欄位了!");
					return;
				}
	            hiddenColumns.push(groupNO);
	        }
			
	        reCreateSettings();
			dataControl.createHeader();
			
			while(hidden_columns_ul.childNodes.length > 2 ){
				hidden_columns_ul.removeChild(hidden_columns_ul.lastChild);
			}
			hidden_columns_ul.style.display = "none";
			
			
			if(hidden_headerSetting.length){
				removeClassName(hidden_columns_ul,"open");	
				hidden_columns_ul.style.display = "block";
				hidden_headerSetting.sort(function( node1 , node2 ){
					var compare1 = node1.colGroup;
					compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
					var compare2 = node2.colGroup;
					compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
					return compare1-compare2;
				});
			
				var setCol = -1;
				for(var i = 0 ; i < hidden_headerSetting.length ; i += 1 ){
					var colGroup = hidden_headerSetting[i].colGroup;
					var lastChild = hidden_columns_ul.lastChild;
					if(colGroup != setCol){					
						setCol= colGroup;
						createDOM( "li",{colGroup:colGroup , title:"顯示欄位"},null,null,{click:function(e){
							var target  = getEventTarget(e);
							hiddenGroup(target.getAttribute("colGroup"));
						}},hidden_columns_ul,getContent(hidden_headerSetting[i].header));
					}else{
						lastChild.appendChild(createDOM("br"));
						lastChild.appendChild(getContent(hidden_headerSetting[i].header));
					}
				}
			}
			
			
	    }
        //重新取得設定
	    function reCreateSettings() {
	        var has_fixed = !!fixedColumns.length; //!isLessThenIE8 &&
			
			hidden_headerSetting = [];
			
	        main_headerSetting = [];
	        main_recordSetting = [];
	        fixed_headerSetting = has_fixed && [];
	        fixed_recordSetting = has_fixed && [];

	        for (var i = 0 ; i < headSetting.length ; i += 1) {
	            var temp_m_header = [];
	            var temp_f_header = has_fixed && [];
	            for (var j = 0 ; j < headSetting[i].length ; j += 1) {
	                var node = headSetting[i][j];
	                if (isObject(node)) {
	                    var node_group = node.colGroup;
	                    if (!has_fixed || isInArray(fixedColumns, node_group) < 0) {
	                        if (isInArray(hiddenColumns, node_group) < 0) {
	                            temp_m_header.push(node);
	                        }else{
								hidden_headerSetting.push(node);
							}
	                    } else {
	                        temp_f_header.push(node);
	                    }
	                }
	            }
	            main_headerSetting.push(temp_m_header);
	            has_fixed && fixed_headerSetting.push(temp_f_header);
	        }

	        for (var i = 0 ; i < recordSetting.length ; i += 1) {
	            var temp_m_header = [];
	            var temp_f_header = has_fixed && [];
	            for (var j = 0 ; j < recordSetting[i].length ; j += 1) {
	                var node = recordSetting[i][j];
	                if (isObject(node)) {
	                    var node_group = node.colGroup;
	                    if (!has_fixed || isInArray(fixedColumns, node_group) < 0) {
	                        if (isInArray(hiddenColumns, node_group) < 0) {
	                            temp_m_header.push(node);
	                        }
	                    } else {
	                        temp_f_header.push(node);
	                    }
	                }
	            }
	            main_recordSetting.push(temp_m_header);
	            has_fixed && fixed_recordSetting.push(temp_f_header);
	        }

	        //settings.fixedColumns = fixedColumns;
	        //settings.hiddenColumns = hiddenColumns;
	        settings.has_fixed = has_fixed;
	        settings.main_headerSetting = main_headerSetting;
	        settings.main_recordSetting = main_recordSetting;
	        settings.fixed_headerSetting = fixed_headerSetting;
	        settings.fixed_recordSetting = fixed_recordSetting;
			
		}

	    //重新建立標頭列設定檔(土黃色區域)
	    function createTitle(config) {
	        if (config.title) {
	            var isTitleSetting = isObject(config.title);
	            var title = getContent(isTitleSetting ? config.title.text : config.title);
	            if (trim(title)) {
	                var headClass = stringToArray("childOfTableParent,tableTitle," + (config.headClass || (isTitleSetting ? config.title.className : "")), ",");

	                var headStyle = isTitleSetting ? isObject(config.title.style) ? config.title.style : {} : {};
	                headStyle.whiteSpace = "nowrap";

	                var headAttrs = isTitleSetting ? isObject(config.title.attrs) ? config.title.attrs : {} : {};
	                headAttrs.name = "tableTitle";

	                var temp_titleElem = createDOM("div", headAttrs, headStyle, headClass, null, null, title);
	                main_div.insertBefore(temp_titleElem, dataArea);
	            }
	        }
	    }

	    //對Header設定調整
	    function createHeaderSetting(matrix_setting, isAllSortable) {
	        //return matrix_setting;
	        var rtn_setting = [];
	        for (var i = 0 ; i < matrix_setting.length ; i += 1) {
	            var matrix_line = matrix_setting[i];
	            var rtn_setting_line = [];
	            for (var j = 0 ; j < matrix_line.length ; j += 1) {
	                var matrix_node = matrix_line[j];

	                if (isString(matrix_node) || isFunction(matrix_node) || isDOMObject(matrix_node)) {
	                    rtn_setting_line.push({
	                        header: matrix_node
	                    });
	                } else if (isObject(matrix_node)) {
	                    /**   !!!important!!!  **/
	                    var isSort = (!isFatchMode) &&
							matrix_node.empty == null ?
								((matrix_setting.isSortable === true || matrix_setting.isSortable === false) ? matrix_setting.isSortable : isAllSortable
								)
								: false;
								
						var newSortRule =  (matrix_node.sortRule||"string").toLowerCase();
						if(isObject(matrix_node.input)){
							var inputType = (matrix_node.input.type ||"").toLowerCase();
							if( inputType == "date" || inputType == "rocdate" || inputType == "number"){
								newSortRule = inputType;
							}
						}
													
	                    var setting_obj = {
	                        header: matrix_node.header,
	                        sortKey: isSort ? (matrix_node.sortKey || matrix_node.key) : "",
	                        sortRule: newSortRule,
	                        attrs: cloneObject(matrix_node.attrs),
	                        colGroup: matrix_node.colGroup
	                    };
	                    setting_obj.attrs.name = matrix_node.key;
	                    rtn_setting_line.push(setting_obj);
	                } else {
	                    rtn_setting_line.push(null);
	                }
	            }
	            rtn_setting.push(rtn_setting_line);
	        }
	        return removeBlankLine(rtn_setting);
	    }
	    //對record設定調整
	    function createRecordSetting(matrix_setting) {
	        var rtn_setting = [];
	        for (var i = 0 ; i < matrix_setting.length ; i += 1) {
	            var matrix_line = matrix_setting[i];
	            var rtn_setting_line = [];
	            for (var j = 0 ; j < matrix_line.length ; j += 1) {
	                var matrix_node = matrix_line[j];
	                if (isObject(matrix_node)) {
	                    /**   !!!important!!!  **/
						var newDataType =  (matrix_node.sortRule||"string").toLowerCase();
						var newPattern = matrix_node.attrs.newPattern;
						if(isObject(matrix_node.input)){
							var inputType = (matrix_node.input.type ||"").toLowerCase();
							if( inputType == "date" || inputType == "rocdate" || inputType == "number"){
								newDataType = inputType;	
								if(!matrix_node.input.pattern && matrix_node.attrs.pattern){
									matrix_node.input.pattern = matrix_node.attrs.pattern;
								}
								if(!matrix_node.input.pattern){
									if(inputType == "number"){
										matrix_node.input.pattern = "#,##0.#";
									}else if(inputType == "date"){
										matrix_node.input.pattern = "yyyy-MM-dd";
									}else{
										matrix_node.input.pattern = "yyy/MM/dd";
									}
								}
								if(!newPattern){
									newPattern = matrix_node.input.pattern;
								}
							}
						}else if(!newPattern){
							if(newDataType == "number"){
								newPattern = "#,##0.#";
							}else if(newDataType == "date"){
								newPattern = "yyyy-MM-dd";
							}else if(newDataType == "rocdate"){
								newPattern = "yyy/MM/dd";
							}
						}
						matrix_node.attrs.pattern = newPattern;
					
						
						var setting_obj = {
	                        key: matrix_node.key,
	                        empty: matrix_node.empty,
	                        groupKey: matrix_node.groupKey,
	                        dataType: newDataType,
	                        render: matrix_node.render,
	                        input: matrix_node.input,
	                        attrs: cloneObject(matrix_node.attrs),
	                        colGroup: matrix_node.colGroup,
							renderInCount: ( isBasicType(matrix_node.renderInCount)? matrix_node.renderInCount  : config.allRenderInCount )|| false
	                    };
						
	                    setting_obj.attrs.name = matrix_node.key;
						if(!setting_obj.attrs.align){ 
							setting_obj.attrs.align = ( newDataType == "number" ) ? "right" : "center"; 
						}
						
	                    rtn_setting_line.push(setting_obj);
	                } else {
	                    rtn_setting_line.push(null);
	                }
	            }
	            rtn_setting.push(rtn_setting_line);
	        }

	        //format For rowSpanByUp
	        //從第二行開始檢核即可，因為檢核第一行沒有意義
	        for (var i = 1 ; i < rtn_setting.length ; i += 1) {
	            var rtn_line = rtn_setting[i];
	            for (var j = 0 ; j < rtn_line.length ; j += 1) {
	                var rtn_node = rtn_line[j];
	                if (isObject(rtn_node) && rtn_node.empty == "rowSpan_up") {
	                    for (var target_Line = i - 1 ; target_Line >= 0 ; target_Line -= 1) {
	                        var test_node = rtn_setting[target_Line][j];
	                        if (isObject(test_node) && !test_node.empty) {
	                            target_node = test_node;
	                            break;
	                        } else if (test_node != null) {
	                            break;
	                        }
	                    }
	                    if (target_node) {
	                        var rtn_node_colSpan = rtn_node.attrs.colSpan || 1;
	                        var rtn_node_rowSpan = rtn_node.attrs.rowSpan || 1;
	                        var target_node_colSpan = target_node.attrs.colSpan || 1;
	                        var target_node_rowSpan = target_node.attrs.rowSpan || 1;
	                        //alert(rtn_node.key+"("+rtn_node_rowSpan+")---->"+target_node.key+"("+target_node_rowSpan+")");
	                        if (rtn_node_colSpan == target_node_colSpan) {
	                            target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                            rtn_line[j] = null;
	                        } else if (rtn_node_colSpan > target_node_colSpan) {
	                            target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                            rtn_line[j] = null;
	                            rtn_line[j + target_node_colSpan] = { empty: "rowSpan_up", attrs: { rowSpan: rtn_node_rowSpan, colSpan: rtn_node_colSpan - target_node_colSpan } };
	                        } else {
	                            var span_test = j + target_node_colSpan > rtn_line.length || isObject(rtn_line[j + target_node_colSpan]);
	                            for (var test_index = j + rtn_node_colSpan ; span_test && (test_index < j + target_node_colSpan) ; test_index) {
	                                var test_node = rtn_line[test_index];
	                                if (isObject(test_node) && test_node.empty == "rowSpan_up") {
	                                    test_index += (test_node.attrs.colSpan || 1);
	                                } else {
	                                    span_test = false;
	                                }
	                            }
	                            if (span_test) {
	                                target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                                for (var test_index = j + rtn_node_colSpan ; span_test && (test_index < j + target_node_colSpan) ; test_index++) {
	                                    rtn_line[test_index] = null;
	                                }
	                            } else {
	                                rtn_node.empty = true;
	                            }
	                        }
	                    } else {
	                        rtn_node.empty = true;
	                    }
	                }
	            }
	        }

	        //format For rowSpanByDown
	        //不檢核最後一行，因為檢核最後一行沒有意義
	        for (var i = rtn_setting.length - 2 ; i >= 0 ; i -= 1) {
	            var rtn_line = rtn_setting[i];
	            for (var j = 0 ; j < rtn_line.length ; j += 1) {
	                var rtn_node = rtn_line[j];
	                if (isObject(rtn_node) && rtn_node.empty == "rowSpan_down") {
	                    var target_node;
	                    var target_Line;
	                    for (target_Line = i + 1 ; target_Line < rtn_setting.length  ; target_Line += 1) {
	                        var test_node = rtn_setting[target_Line][j];
	                        if (isObject(test_node)) {
	                            if (!test_node.empty) {
	                                target_node = test_node;
	                                break;
	                            } else if (test_node.empty == "rowSpan_down") {
	                                continue;
	                            } else {
	                                break;
	                            }
	                        } else if (test_node != null) {
	                            break;
	                        }
	                    }
						if (target_Line < rtn_setting.length && target_node) {
	                        var isEmpty = (target_node.empty == "rowSpan_down");
	                        var rtn_node_colSpan = rtn_node.attrs.colSpan || 1;
	                        var rtn_node_rowSpan = rtn_node.attrs.rowSpan || 1;
	                        var target_node_colSpan = target_node.attrs.colSpan || 1;
	                        var target_node_rowSpan = target_node.attrs.rowSpan || 1;

	                        if (rtn_node_colSpan == target_node_colSpan) {
	                            target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                            rtn_line[j] = target_node;
								rtn_setting[target_Line][j] = null;
							} else if (rtn_node_colSpan > target_node_colSpan) {
	                            target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                            rtn_line[j] = target_node;
	                            rtn_line[j + target_node_colSpan] = { empty: "rowSpan_down", attrs: { rowSpan: rtn_node_rowSpan, colSpan: rtn_node_colSpan - target_node_colSpan } };
	                            rtn_setting[target_Line][j] = null;
	                        } else {
	                            var span_test = j + target_node_colSpan > rtn_line.length || isObject(rtn_line[j + target_node_colSpan]);
	                            for (var test_index = j + rtn_node_colSpan ; span_test && (test_index < j + target_node_colSpan) ; test_index) {
	                                var test_node = rtn_line[test_index];
	                                if (isObject(test_node) && test_node.empty == "rowSpan_up") {
	                                    test_index += (test_node.attrs.colSpan || 1);
	                                } else {
	                                    span_test = false;
	                                }
	                            }
	                            if (span_test) {
	                                for (var test_index = j + rtn_node_colSpan ; span_test && (test_index < j + target_node_colSpan) ; test_index++) {
	                                    rtn_line[test_index] = null;
	                                }
	                                target_node.attrs.rowSpan = rtn_node_rowSpan + target_node_rowSpan;
	                                rtn_line[j] = target_node;
	                                rtn_setting[target_Line][j] = null;
	                            } else {
	                                rtn_node.empty = true;
	                            }
	                        }
	                    } else {
	                        rtn_node.empty = true;
	                    }
	                }
	            }
	        }
	        rtn_setting = removeBlankLine(rtn_setting);

	        var clearGroup = true;
	        //groupSet = {}; 
	        allGroupKeys = [];
	        var setting_height = rtn_setting.length;
	        for (var i = rtn_setting.length - 1 ; i >= 0 ; i -= 1) {
	            var rtn_line = rtn_setting[i];
	            for (var j = 0 ; j < rtn_line.length ; j += 1) {
	                var rtn_node = rtn_line[j];
	                if (rtn_node && isArray(rtn_node.groupKey)) {
	                    if (i == 0 && (rtn_node.attrs.rowSpan || 1) == setting_height) {
	                        //groupSet[rtn_node.key] = rtn_node.groupKey;
	                        for (var thisGroupKeyCount = rtn_node.groupKey.length - 1 ; thisGroupKeyCount >= 0 ; thisGroupKeyCount -= 1) {
	                            var testKey = rtn_node.groupKey[thisGroupKeyCount];
	                            if (isBasicType(testKey)) {
	                                var addKey = true;
	                                for (var allGroupKeyCount = allGroupKeys.length - 1 ; allGroupKeyCount >= 0 ; allGroupKeyCount -= 1) {
	                                    if (allGroupKeys[allGroupKeyCount] == testKey) {
	                                        addKey = false;
	                                        break;
	                                    }
	                                }
	                                if (addKey) {
	                                    allGroupKeys.push(testKey);
	                                }
	                            } else {
	                                rtn_node.groupKey.splice(thisGroupKeyCount, 1);
	                            }
	                        }
	                        clearGroup = false;
	                    } else {
	                        rtn_node.groupKey = null;
	                    }
	                }
	            }
	        }
	        if (clearGroup) {
	            allGroupKeys = null;
	        }
	        settings.allGroupKeys = allGroupKeys;

	        return rtn_setting;
	    }

	    //建立autoCheckedBox
	    function createAutoCheckedBox(config, head_matrix_setting, record_matrix_setting) {
	        settings.checkAllBox = null;
			if (config.autoCheckBox) {
				
				var colGroup = 0;
				
				if(autoCheckBox_doNotRowSpan){
					colGroup = head_matrix_setting[0][0].colGroup;
					head_matrix_setting[0].splice(0,1);
					record_matrix_setting[0].splice(0,1);
					autoCheckBox_doNotRowSpan = colGroup;
				}
				fixedColumns.push(colGroup);
				
				
	            var autoCheckBoxsetting = isObject(config.autoCheckBox) ? config.autoCheckBox : {};
	            var typeIsCheckBox = (autoCheckBoxsetting.type || "").toUpperCase() !== "RADIO";
                
	            //createHeaderSetting
	            var headerSettingHeight = autoCheckBox_doNotRowSpan ? 1 : head_matrix_setting.length;

	            var isSelectAll = !isFatchMode && typeIsCheckBox && (autoCheckBoxsetting.isSelectAll === true || isFunction(autoCheckBoxsetting.isSelectAll));

	            var header = (autoCheckBoxsetting.text || "選取");

	            if (isSelectAll) {
	                var selectAllFunc = isFunction(autoCheckBoxsetting.isSelectAll);
	                var input = createDOM("input", { name: "autoCheckBox_"+table_id+"_SelectAll", type: "checkbox" }, null, null, {
	                    click: function (e) {
	                        dataControl.autoCheckBoxSelectAll();
	                        if (selectAllFunc) {
	                            selectAllFunc(getEventTarget(e));
	                        }
	                    }
	                });
	                header = createFragment( [ input, createDOM("br"), header ]);
					settings.checkAllBox = input;
	            }

                var setting_obj = {
	                header: createDOM("div",null,null,null,null,null,header),
	                attrs: { nowrap: true, rowSpan: headerSettingHeight },
					fixedColmun: false,
	                colGroup: colGroup
                };
                head_matrix_setting[0].splice(0, 0, setting_obj);
                for (var i = 1 ; i < headerSettingHeight.length ; i = i + 1) {
                    head_matrix_setting[i].splice(0, 0, setting_obj);
                }


	            // createRecordSetting
                var recordSettingHeight = autoCheckBox_doNotRowSpan ? 1 : record_matrix_setting.length;

                var withGroup = isArray(allGroupKeys) && allGroupKeys.length > 0 && autoCheckBoxsetting.withoutGroup !== true ; 
                if (withGroup ){
                    if (isNumeric(autoCheckBoxsetting.groupLevel)) {
                        withGroup = autoCheckBoxsetting.groupLevel;
                        if (!(withGroup > 0 && withGroup <= allGroupKeys.length)) {
                            withGroup = false;
                        }
                    } else {
                        withGroup = 1;
                    }
                    if (withGroup) {
                        withGroup = allGroupKeys.slice(0, withGroup);
                    }
                }
                var records_attrs = autoCheckBoxsetting.attrs;
                if(!isObject(records_attrs)){
                    records_attrs = {};
                }
                records_attrs.rowSpan = recordSettingHeight;
				records_attrs.align = "center";

                var valueKey =  autoCheckBoxsetting.valueKey || "";
              
                autoCheckBox_key = valueKey;
                
                var action = isFunction(autoCheckBoxsetting.action) && autoCheckBoxsetting.action;
                
                var setting_obj = {
                    key: valueKey,
                    groupKey: withGroup,
                    render: function (r, v, sn) {
						var input = createDOM("input", 
							{ 
								type: typeIsCheckBox ? "checkbox" : "radio" , 
								name:"autoCheckBox_"+table_id , 
								//shouldBeChecked : r.tableuiAutoCheckBoxResult || 0 , 
								value : (v || "")
							}, 
							null, 
							null, 
							{
                            	click: function (e) {
									var target = getEventTarget(e);
									var key = target.parentNode.getAttribute("name");
									var records = dataControl.getRecordsByCell(target);
									dataControl.autoCheckBoxSingle( target, records , key );
									if (action) { action(target, target.checked, records); }
								}
							}
						);
						return input;
                    },
                    attrs: records_attrs,
                    colGroup: colGroup
                };
                record_matrix_setting[0].splice(0, 0, setting_obj);
                for (var i = 1 ; i < recordSettingHeight.length ; i = i + 1) {
                    record_matrix_setting[i].splice(0, 0, null);
                }
	        }
	        
	    }

        //將設定陣列化
	    function formatColumnsToMatrix(column_setting, split_setting) {
	        if (!isArray(column_setting) || !column_setting[0]) { return false; }
	        if (isArray(column_setting[0])) { return fullMatrixSetting(column_setting); }
	        if (!isArray(split_setting) || split_setting.length == 0) { return fullMatrixSetting([column_setting]); }

	        var rtnObj = [];
	        var innerObj = [];
	        if(autoCheckBox_doNotRowSpan){
	        	innerObj.push({empty:"checkedBox"});
	        }
	        for (var i = 0 ; i < column_setting.length ; i += 1) {
	            var col_node = column_setting[i];
	            if (isObject(col_node)) {
	                var col_key = col_node.key;
	                for (var j = 0 ; j < split_setting.length ; j += 1) {
	                    var split_node = split_setting[j];
	                    if (split_node == col_key) {
	                        if (innerObj.length > 0) {
	                            rtnObj.push(innerObj);
	                            innerObj = [];
	                        }
	                        break;
	                    }
	                }
	                innerObj.push(col_node);
	            }
	        }

	        if (innerObj.length > 0) {
	            rtnObj.push(innerObj);
	        }

	        return fullMatrixSetting(rtnObj);
	    }
        
		//將陣列化設定補齊空白
	    function fullMatrixSetting(matrix_setting) {
	        var max_height = matrix_setting.length;
			var lines_length = [];
			var max_length = 0;
			for (var i = 0 ; i < max_height ; i += 1) {
				var line_length = matrix_setting[i].length;
				lines_length[i] = line_length;
				max_length = Math.max(max_length , line_length);
			}
			
			var nowPosition = 0;
			
			while(nowPosition < max_length){
				for (var i = 0 ; i < max_height ; i += 1) {
					var action_line = matrix_setting[i];
					if( action_line.length <= nowPosition){
						action_line.push(null);
						continue;
					}
					var test_elem = action_line[nowPosition];
					if(!test_elem){
						continue;
					}
					
					if (!isObject(test_elem.attrs)) {
	                    test_elem.attrs = {};
	                }
					
					var node_colSpan = test_elem.colSpan || test_elem.attrs.colSpan || 1;
	                var node_rowSpan = test_elem.rowSpan || test_elem.attrs.rowSpan || 1;
					
					//console.log("nowPosition:"+nowPosition+"  / i:"+i+"   / col:"+node_colSpan+"   / row:"+node_rowSpan);
					for (var add_row = 0 ; add_row < node_rowSpan ; add_row++) {
						if (i + add_row >= max_height) {
							node_rowSpan = add_row - 1;
							break;
						}
						var add_column_line = matrix_setting[i + add_row];
						for (var add_col = 0 ; add_col < node_colSpan ; add_col++) {
							if(add_row == 0 && add_col == 0 ){
								continue;
							}
							add_column_line.splice( nowPosition+add_col , 0, null);
						}
						max_length = Math.max(max_length , add_column_line.length);
					}
					
					test_elem.attrs.colSpan = node_colSpan;
	                test_elem.attrs.rowSpan = node_rowSpan;
	                test_elem.attrs.nowrap = true;
				}
				nowPosition++;
			}
			
			return matrix_setting;
		}
		
        //設定固定欄位的群組編號
	    function settingFixedGroup(setting1, setting2) {
	        var group_count = 0;
			
			var now_position = 0;
			
			var max_ingore = 0;
			
			var setting1_height = setting1.length;
			var setting2_height = setting2.length;
			
			/*for(var i = 0 ; i < setting1_height ; i++){
				console.log("--------------- " + setting1[i].length);
				for(var j = 0 ; j < setting1[i].length ; j++){
					console.log("=== " + setting1[i][j]);
				}
			}*/
			
			do{
				if(max_ingore == 0){
					group_count++;
				}
				var temp_ingore = -1;
				// setting 1 figure
				for(var i = 0 ; i < setting1_height ; i++){
					var elem = setting1[i][now_position];
					var isIngore = 0;
					if(elem){
						elem.colGroup = group_count;
						isIngore = elem.attrs.colSpan || 1;
					}
					isIngore--;
					temp_ingore = Math.max(temp_ingore , isIngore );
				}
				
				// setting 2 figure
				for(var i = 0 ; i < setting2_height ; i++){
					var elem = setting2[i][now_position];
					var isIngore = 0;
					if(elem){
						elem.colGroup = group_count;
						isIngore = elem.attrs.colSpan || 1;
					}
					isIngore--;
					temp_ingore = Math.max(temp_ingore , isIngore );
				}
				
				now_position++;
				if(temp_ingore < 0){
					break;
				}
				max_ingore = Math.max(max_ingore-1,temp_ingore);
			}while( max_ingore >= 0);
		}
		
        //去除完全空白行
	    function removeBlankLine(rtn_setting) {
	        for (var i = rtn_setting.length - 1 ; i >= 0  ; i -= 1) {
	            var rtn_line = rtn_setting[i];
	            var isEmpty = true;
	            for (var j = 0 ; j < rtn_line.length ; j += 1) {
	                if (rtn_line[j] != null) {
	                    isEmpty = false;
	                    break;
	                }
	            }
	            if (isEmpty) {
	                var checkColSpan = 2;
	                for (var check_i = i - 1 ; check_i >= 0 ; check_i -= 1) {
	                    var check_line = rtn_setting[check_i];
	                    for (var check_j = 0 ; check_j < check_line.length ; check_j += 1) {
	                        var check_node = check_line[check_j];
	                        if (isObject(check_node) && check_node.attrs.rowSpan >= checkColSpan) {
	                            check_node.attrs.rowSpan = check_node.attrs.rowSpan - 1;
	                        }
	                    }
	                    checkColSpan += 1;
	                }
	                rtn_setting.splice(i, 1);
	            }
	        }
	        return rtn_setting;
	    }
		
		this.getXlsSettingJSON = getXlsSettingJSON;
		function getXlsSettingJSON(sheetName){

			var titleSetting = [];
			var detailSetting = [];
			
			var ColumnStartWith = config.autoCheckBox ? 1 : 0;
			
			for(var i = 0 ; i < headSetting.length ; i = i + 1){
				var aCol = [];
				titleSetting.push(aCol);
				for(var j = ColumnStartWith ; j < headSetting[i].length ; j = j + 1){
					if(headSetting[i][j]){
						aCol.push( { 
							key : headSetting[i][j].sortKey , 
							header : headSetting[i][j].header , 
							sortRule : isBasicType(headSetting[i][j].sortRule) ? headSetting[i][j].sortRule : "string" , 
							groupKey : headSetting[i][j].groupKey , 
							attrs : headSetting[i][j].attrs 
						} );
					}else{
						aCol.push( { sortRule:"copy" } );
					}
					
				}
			}
			
			
			for(var i = 0 ; i < recordSetting.length ; i = i + 1){
				var aCol = [];
				detailSetting.push(aCol);
				for(var j = ColumnStartWith ; j < recordSetting[i].length ; j = j + 1){
					if(recordSetting[i][j]){
						aCol.push( { 
							key : recordSetting[i][j].key , 
							header : recordSetting[i][j].header , 
							sortRule : isBasicType(recordSetting[i][j].dataType) ? recordSetting[i][j].dataType : "string" , 
							groupKey : recordSetting[i][j].groupKey , 
							attrs : recordSetting[i][j].attrs 
						} );
					}else{
						aCol.push( { sortRule:"copy" } );
					}
					
				}
			}
			
			var returnVar = {sheetName:sheetName , titleSetting:titleSetting , recordSetting:detailSetting , groupKeys:allGroupKeys};
			return Object.toJSON(returnVar);
		}
		
		this.getFixedHiddenInfo = getFixedHiddenInfo;
		function getFixedHiddenInfo(info){
			info.fixedColumns = fixedColumns;
			info.hiddenColumns = hiddenColumns;
		}
		
		this.setFixedHiddenInfo = setFixedHiddenInfo;
		function setFixedHiddenInfo(info){
			var shouldBeUpdate = false;
			if(isArray(info.fixedColumns) && info.fixedColumns.length > 0 ){
				fixedColumns = info.fixedColumns;
				shouldBeUpdate = true;
			}
			if(isArray(info.hiddenColumns) && info.hiddenColumns.length > 0 ){
				hiddenColumns = info.hiddenColumns;
				shouldBeUpdate = true;
			}
			if(shouldBeUpdate){
				reCreateSettings();
				dataControl.createHeader();
			}
		}
		
	}

    //資料控制項 functions
	function dataControl_impl(){
		var main_table_head = createDOM("thead" , null ,null,null,null,main_table);
		var main_table_foot = createDOM("tfoot" , null ,null,null,null,main_table);
		var fixed_table_head = createDOM("thead" , null ,null,null,null,fixed_table);
		var fixed_table_foot = createDOM("tfoot" , null ,null,null,null,fixed_table);
		
		var sortGroupKeys;
		var dataWhenNULL = config.whenDataNull || " ";
		
		var setRecordBackground = isFunction(config.setRecordBackground) ? config.setRecordBackground : false;
		var setRecordClass = isFunction(config.setRecordClass) ? config.setRecordClass : false;
		
		var settings = settingCtrl.settings;
		
		var sortRules = [];

		//產生header區塊
		createHeader();
		
		this.createHeader = createHeader;
		function createHeader(){
			createOneHeader( settings.main_headerSetting , main_table_head );
			createOneHeader( settings.fixed_headerSetting , fixed_table_head );
			divFitControl.fit();
			compareCellHeight(main_table_head,fixed_table_head);
			pageControl.reloadPage();
		}
		
		function createOneHeader( headSetting , append_head_parent , isFixedTable ){
			while(append_head_parent.hasChildNodes()){
				append_head_parent.removeChild(append_head_parent.lastChild);
			}
			if(!headSetting || headSetting.length == 0 ){ return; }
			
			var firstLine_ignoreCount = 1;
			var lastLine_ignoreCount = 1;
			
			for(var i = 0 ; i < headSetting.length ; i += 1 ){
				if(headSetting[i].length == 0){
					var checkRowSpan = 2;
					var checkRow = append_head_parent.lastChild;
					while(checkRow){
						var checkCell = checkRow.firstChild;
						while(checkCell){
							var cutRowSpan = parseInt(checkCell.getAttribute("cutRowSpan")) || 0;
							var orgRowSpan = parseInt(checkCell.getAttribute("orgRowSpan")) || 1;
							if( orgRowSpan-cutRowSpan >= checkRowSpan ){
								checkCell.setAttribute("cutRowSpan",cutRowSpan+1);
								checkCell.setAttribute("rowSpan",orgRowSpan-cutRowSpan-1);
							}
							checkCell = checkCell.nextSibling;
						}
						checkRowSpan++;
						checkRow = checkRow.previousSibling;
					}
					firstLine_ignoreCount -= 1;
					lastLine_ignoreCount -= 1;
					continue;
				}
				
				var temp_line = createDOM("tr" , null ,null,null,null,append_head_parent);
				for(var j = 0  ; j < headSetting[i].length ; j += 1 ){
					var matrix_node = headSetting[i][j];
					if(isObject(matrix_node)){
						var temp_elem = createDOM("th",matrix_node.attrs,null,null,null,temp_line, matrix_node.header
							//,(matrix_node.attrs?"("+(matrix_node.attrs.colSpan||1)+","+(matrix_node.attrs.rowSpan||1)+")":"(1,1)")
						);
						temp_elem.setAttribute("orgRowSpan",matrix_node.attrs.rowSpan || 1);
						temp_elem.setAttribute("colGroup",matrix_node.colGroup);
						temp_elem.setAttribute("align","center");
						//temp_elem.appendChild( getContent("<br>aaaaa"+matrix_node.colGroup) );
						
						var func_menu = createDOM("ul",null,null,["menu"]);
						if(matrix_node.sortKey){
							addClassName(temp_elem,"sortable");
							createDOM( "li",{title:"正向排序",rule:matrix_node.sortRule,key:matrix_node.sortKey},null,["header_sort_az"]
									,{click:function(e){
										var target = getEventTarget(e);
										var menu = target.parentNode;
										var th = target.parentNode.parentNode;
										sortDetail( target.getAttribute("key") , true , target.getAttribute("rule") );
										menu.style.display = "none";
										th.style.position = "";
										addClassName(th,"sort_az");
										removeClassName(th,"sort_za");
										divFitControl.fit();
									}}
								,func_menu
							);
							createDOM( "li",{title:"逆向排序",rule:matrix_node.sortRule,key:matrix_node.sortKey},null,["header_sort_za"]
									,{click:function(e){
										var target = getEventTarget(e);
										var menu = target.parentNode;
										var th = target.parentNode.parentNode;
										sortDetail( target.getAttribute("key") , false , target.getAttribute("rule") );
										menu.style.display = "none";
										th.style.position = "";
										addClassName(th,"sort_za");
										removeClassName(th,"sort_az");
										divFitControl.fit();
									}}
								,func_menu
							);
							
							var sort_status = getSortRule(matrix_node.sortKey);
							if(sort_status !== null){
								addClassName(temp_elem,sort_status?"sort_az":"sort_za");
								removeClassName(temp_elem,sort_status?"sort_za":"sort_az");
							}
							
						}
						
						if(config.fixedColmuns !== false && matrix_node.fixedColmun !== false ){
							createDOM("li",{title:"解除/固定欄位"},null,["header_pin"]
									,{click:function(e){
										var target = getEventTarget(e);
										var colGroup = target.parentNode.parentNode.getAttribute("colGroup");
										settingCtrl.fixedGroup(colGroup);
									}}
								,func_menu
							);
						}
						var isSetHidden = 0;
						if(config.HiddenColmuns !== false && matrix_node.HiddenColmun !== false ){
							createDOM("li",{title:"隱藏欄位"},null,["header_hidden"]
									,{click:function(e){
										var target = getEventTarget(e);
										var colGroup = target.parentNode.parentNode.getAttribute("colGroup");
										settingCtrl.hiddenGroup(colGroup);
									}}
								,func_menu
							);
							isSetHidden = 1;
						}
						if(func_menu.childNodes.length > isSetHidden){
							createDOM("li",{title:"關閉"},null,["header_close"]
									,{click:function(e){
										var target = getEventTarget(e);
										target.parentNode.style.display = "none";
										target.parentNode.parentNode.style.position = "";
									}}
								,func_menu
							);
							
							temp_elem.appendChild(func_menu);
							
							createDOM(temp_elem,{"title":"功能選單"},null,["mouse_pointer"],{click:function(e){ 
								if(hasPrototype){
									$$(".tableGrid th ul.menu").each(function(elem){ 
										elem.style.display="none";
										elem.parentNode.style.position = "";
									});
								}
								if(!pageControl.hasRecoeds()){ alert("必須先讀入資料，才能進行選單操作！"); return; }
								var target = getEventTarget(e);
								var menu = target.lastChild;
								if(menu && menu.tagName == "UL"){
									target.style.position = "relative";
  									menu.style.display = "block";
									menu.style.top = (target.offsetHeight)+"px";
									menu.style.width = (menu.lastChild.offsetLeft+27)+"px";
								}
							}});
						}
						
						if(j == 0 ){
							firstLine_ignoreCount -= 1;
							if(firstLine_ignoreCount <= 0){
								addClassName(temp_elem,"firstOfLine");
								firstLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
							}		
						}
						
						if( j == (headSetting[i].length-1)){
							lastLine_ignoreCount -=1;
							if(lastLine_ignoreCount <= 0){
								addClassName(temp_elem,"lastOfLine");
								lastLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
							}
						}
					}
				}
			}
			
			countMinRowSapn( append_head_parent );
		}
		
		//產生資料顯示區塊，包含小計及合計的產生
		this.createRecordsBody = createRecordsBody;
		function createRecordsBody( recordsInBody , recordsCount , body_serial_no ){
		    createOneRecordsBody(settings.main_recordSetting, main_table, recordsInBody, recordsCount , body_serial_no ,true );
		    createOneRecordsBody(settings.fixed_recordSetting, fixed_table, recordsInBody, recordsCount , body_serial_no , false);
			//divFitControl.fit();

			/*var main_table_tBodies = main_table.tBodies;
			var fixed_table_tBodies = fixed_table.tBodies;
			var last_tBody_num = main_table_tBodies.length - 1;
			//compareCellHeight(main_table_tBodies[last_tBody_num],fixed_table_tBodies[last_tBody_num]);
			//背景顏色
			if(last_tBody_num%2 == 1){
				addClassName(main_table_tBodies[last_tBody_num],"evenRecord");
				if(fixed_table_tBodies[last_tBody_num]){ addClassName(fixed_table_tBodies[last_tBody_num],"evenRecord"); }
			}*/
		}

		this.createTotalRecordBody = createTotalRecordBody;
		function createTotalRecordBody(createTotalInBody) {
		    createOneTotalRecordsBody(settings.main_recordSetting, main_table, createTotalInBody , true);
		    createOneTotalRecordsBody(settings.fixed_recordSetting, fixed_table, createTotalInBody ,false);
			//divFitControl.fit();
		    var main_table_tBodies = main_table.tBodies;
		    var fixed_table_tBodies = fixed_table.tBodies;
		    var last_tBody_num = main_table_tBodies.length - 1;
		    //compareCellHeight(main_table_tBodies[last_tBody_num], fixed_table_tBodies[last_tBody_num]);
		    //背景顏色
		    addClassName(main_table_tBodies[last_tBody_num], "totalCountRecord");
			countMinRowSapn( main_table_tBodies[last_tBody_num] );
			
			if (fixed_table_tBodies[last_tBody_num]) { 
				addClassName(fixed_table_tBodies[last_tBody_num], "totalCountRecord"); 
				countMinRowSapn( fixed_table_tBodies[last_tBody_num] );
			}

		    return [main_table_tBodies[last_tBody_num], fixed_table_tBodies[last_tBody_num]];
		}

		function createOneRecordsBody( recordSetting , append_parent , records, recordsCount , body_serial_no , addTotalTitle){
			if(!recordSetting || recordSetting.length == 0){ return; }
			if(isObject(records)){ 
				records = [records]; 
			}
			else if(!isArray(records)){ 
				return; 
			}

			var firstLine_ignoreCount = 1;
			var lastLine_ignoreCount = 1;

			var groupSaving = {};
			var record_height = recordSetting.length;
			var preRecord;
			
			var record_body = createDOM("tbody" , {body_serial_no:body_serial_no} ,null,null,{mouseover:bodyMouseMoveOver,mouseout:bodyMouseMoveOut},append_parent);
			for(var records_count = 0 ; records_count < records.length ; records_count += 1){
				var record = records[records_count];
				var serial_no = record.tableUI_serialNumber;
				for(var i = 0 ; i < recordSetting.length ; i += 1 ){
					
					if(recordSetting[i].length == 0){
						var checkRowSpan = 2;
						var checkRow = record_body.lastChild;
						while(checkRow){
							var checkCell = checkRow.firstChild;
							while(checkCell){
								var cutRowSpan = parseInt(checkCell.getAttribute("cutRowSpan")) || 0;
								var orgRowSpan = parseInt(checkCell.getAttribute("orgRowSpan")) || 1;
								if( orgRowSpan-cutRowSpan >= checkRowSpan ){
									checkCell.setAttribute("cutRowSpan",cutRowSpan+1);
									checkCell.setAttribute("rowSpan",orgRowSpan-cutRowSpan-1);
								}
								checkCell = checkCell.nextSibling;
							}
							checkRowSpan++;
							checkRow = checkRow.previousSibling;
						}
						firstLine_ignoreCount -= 1;
						lastLine_ignoreCount -= 1;
						continue;
					}
					
					var temp_line = createDOM("tr" , {sn:serial_no} ,null,null,null,record_body);
					for(var j = 0 , line_length = recordSetting[i].length ; j < line_length ; j += 1 ){
						var matrix_node = recordSetting[i][j];
						if(isObject(matrix_node)){
							var contentKey = matrix_node.key;
							var hasGroup = isArray(matrix_node.groupKey);
							if(preRecord && hasGroup){
								var isGroup = true;
								for(var group_count = 0 ; group_count<matrix_node.groupKey.length ; group_count += 1){
									if(preRecord[matrix_node.groupKey[group_count]] != record[matrix_node.groupKey[group_count]]){
										isGroup = false;
									}
								}
								if(isGroup && groupSaving[contentKey] ){
									var savingCell = groupSaving[contentKey];
									 savingCell.setAttribute("rowSpan" , (parseInt(savingCell.getAttribute("rowSpan")||1)+record_height));
									 savingCell.setAttribute("orgRowSpan" , (parseInt(savingCell.getAttribute("orgRowSpan")||1)+record_height));
									 savingCell.setAttribute("groupRecordNumbers" , (parseInt(savingCell.getAttribute("groupRecordNumbers")||1)+1));
									 savingCell.setAttribute("sn" , savingCell.getAttribute("sn")+","+serial_no);
									 
									 if(j==0){
										 firstLine_ignoreCount = firstLine_ignoreCount + record_height -1 ;
									 }
									 
									 if(j==(recordSetting[i].length-1)){
										 lastLine_ignoreCount = lastLine_ignoreCount + record_height -1 ;
									 }
									 
									 continue;
								}
							}
							
							//取得內容
							matrix_node.attrs.sn = serial_no;
							var temp_elem = createDOM("td", matrix_node.attrs, null, null, null, temp_line);
							temp_elem.setAttribute("orgRowSpan",matrix_node.attrs.rowSpan || 1);

							if(hasGroup){
								groupSaving[contentKey] = temp_elem;
							}
							
							//設定內容
							temp_elem.appendChild( createInput(matrix_node,record,contentKey,matrix_node.render, serial_no, dataWhenNULL) );
							//temp_elem.appendChild( getContent(firstLine_ignoreCount +" X "+lastLine_ignoreCount +"<br>"+matrix_node.attrs.colSpan +" X "+matrix_node.attrs.rowSpan) );
							//temp_elem.appendChild( getContent("<br>aaaaa"+matrix_node.colGroup) );
							
							if(j == 0 ){
								firstLine_ignoreCount -= 1;
								if(firstLine_ignoreCount <= 0){
									addClassName(temp_elem,"firstOfLine");
									firstLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
								}		
							}
							
							if( j == (recordSetting[i].length-1)){
								lastLine_ignoreCount -=1;
								if(lastLine_ignoreCount <= 0){
									addClassName(temp_elem,"lastOfLine");
									lastLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
								}
							}
						}
					}
				}
				preRecord = record;
			}
			
			if(setRecordBackground){
				var rtnColor = setRecordBackground(records);
				if(rtnColor && isString(rtnColor)){
					record_body.style.backgroundColor = rtnColor;
				}
			}
			if(setRecordClass){
				var rtnClass = setRecordClassName(records);
				if(rtnClass && isString(rtnClass)){
					addClassName(record_body,rtnClass);
				}
			}
			
			//小計部分
			createOneTotalRecordsBody(recordSetting, record_body, recordsCount, addTotalTitle);
			
			countMinRowSapn( record_body );

			return record_body;

		}
		
		var bodyHighlight;
		var bodyHighlight_saved;
		var waitToRemoveHighlight;
		function bodyMouseMoveOver(e){
			var target = getEventTarget(e);
			target = target && getParentByTagName( target , "tr");
			if(!target){ return; }
			var body_serial_no = target.getAttribute("sn");
			
			if(hasPrototype && bodyHighlight != body_serial_no){
				//console.log("highlight"+body_serial_no);
				$(dataArea).select("tr[sn='"+body_serial_no+"']").each(function(element) {
					addClassName(element,"recordHighlight");
				});
				
			}
			bodyHighlight = body_serial_no;
			bodyHighlight_saved = body_serial_no;
		}
		
		function bodyMouseMoveOut(e){
			if(waitToRemoveHighlight){removeHighlight();}
			waitToRemoveHighlight = bodyHighlight_saved;
			bodyHighlight_saved = null;
			setTimeout(removeHighlight,2);
		}
		
		function removeHighlight(){
			if(isNumeric(waitToRemoveHighlight)){
				if(bodyHighlight_saved === null || waitToRemoveHighlight !== bodyHighlight){
					//console.log("remove"+waitToRemoveHighlight);
					$(dataArea).select("tr[sn='"+waitToRemoveHighlight+"']").each(function(element) {
						removeClassName(element,"recordHighlight");	
					});
					if(bodyHighlight_saved === null){
						bodyHighlight = null;
					}
				}
				waitToRemoveHighlight = null;
			}
		}

		

		function createOneTotalRecordsBody(recordSetting, record_body, records, addTotalTitle) {
		    if(!recordSetting || recordSetting.length == 0){ return; }
		    if (!isArray(records) || records.length <= 0) { return; }

			if (record_body.tagName == "TABLE") {
				record_body = createDOM("tbody", null, null, null, null, record_body);
			}

			var maxSettingLength = recordSetting[0].length;
			for(var i = 1 ; i < recordSetting.length ; i += 1 ){
				if(recordSetting[i].length  > maxSettingLength){
					maxSettingLength = recordSetting[i].length;
				}
			}
			
			var firstLine_ignoreCount = 1;
			var lastLine_ignoreCount = 1;
			
			var keepTotalTitle = addTotalTitle;
			
			for (var records_count = 0 ; records_count < records.length ; records_count += 1) {
				var count_data = records[records_count];
				if (!isObject(count_data)) {
					continue;
				}
				var record = count_data;
				if (isObject(record.value)) {
					record = record.value;
				}
				
				var count_lines = [];
				for (var i = 0 ; i < recordSetting.length ; i += 1) {
					
					if(recordSetting[i].length == 0){
						var checkRowSpan = 2;
						var checkRow = record_body.lastChild;
						while(checkRow){
							var checkCell = checkRow.firstChild;
							while(checkCell){
								var cutRowSpan = parseInt(checkCell.getAttribute("cutRowSpan")) || 0;
								var orgRowSpan = parseInt(checkCell.getAttribute("orgRowSpan")) || 1;
								if( orgRowSpan-cutRowSpan >= checkRowSpan ){
									checkCell.setAttribute("cutRowSpan",cutRowSpan+1);
									checkCell.setAttribute("rowSpan",orgRowSpan-cutRowSpan-1);
								}
								checkCell = checkCell.nextSibling;
							}
							checkRowSpan++;
							checkRow = checkRow.previousSibling;
						}
						firstLine_ignoreCount -= 1;
						lastLine_ignoreCount -= 1;
						continue;
					}
					
					var temp_line = createDOM("tr", null, null, ["count_data"], null , record_body);
					count_lines.push(temp_line);
				
					for (var j = 0, line_length = recordSetting[i].length ; j < line_length ; j += 1) {
						var matrix_node = recordSetting[i][j];
						if (isObject(matrix_node)) {
							var contentKey = matrix_node.key;
							//取得內容
							var content = contentKey ? foramtValueByType( record[contentKey] , matrix_node) : null;
							
							if (matrix_node.renderInCount && isFunction(matrix_node.render)) {
								content = getContent(matrix_node.render, content, [record, content , ""], true);
							}else{
								content = getContent(content);
							}
							
							//設定內容
							var temp_elem = createDOM("td", matrix_node.attrs, null, null, null, temp_line, content);
							temp_elem.setAttribute("orgRowSpan",matrix_node.attrs.rowSpan || 1);
							
							if(j == 0 ){
								firstLine_ignoreCount -= 1;
								if(firstLine_ignoreCount <= 0){
									addClassName(temp_elem,"firstOfLine");
									firstLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
								}		
							}
							
							if( j == (recordSetting[i].length-1)){
								lastLine_ignoreCount -=1;
								if(lastLine_ignoreCount <= 0){
									addClassName(temp_elem,"lastOfLine");
									lastLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1);
								}
							}
						}
					}
				}

				if(keepTotalTitle){
					var total_header = count_data.text || count_data.header;
					if(!trim(count_lines[0].firstChild.innerHTML) && total_header){
						count_lines[0].firstChild.appendChild(getContent(total_header));
						addClassName(count_lines[0].firstChild,"total_header");
					}else{
						keepTotalTitle = false;
					}
				}
			}
			
			return;
			
			if(record_body.hasChildNodes()){
				
				//取得最多合併寬度
				if(keepTotalTitle){
					var lestLengthOfBlankColumns = maxSettingLength;

					var rec_line = record_body.firstChild;
					var now_row = 0;
					var rowSpanCount = [];
					while(rec_line){
						var blankColumnCount = rowSpanCount[now_row] || 0;
						var rec_cell = rec_line.firstChild;
						while(rec_cell){
							if( !trim(rec_cell.innerHTML) || hasClassName(rec_cell,"total_header") ){
								var colSpan =  parseInt(rec_cell.getAttribute("colSpan") || 1 );
								var rowSpan =  parseInt(rec_cell.getAttribute("rowSpan") || 1 );
								blankColumnCount += colSpan;
								for( var addRow = 1 ; addRow < rowSpan ; addRow++ ){
									rowSpanCount[now_row+addRow] += colSpan;	
								}
							}else{
								break;
							}
							rec_cell = rec_cell.nextSibling;
						}
						if(blankColumnCount < lestLengthOfBlankColumns){
							lestLengthOfBlankColumns = blankColumnCount;
						}
						rec_line = rec_line.nextSibling;
						now_row++;
					}
					
					//合併前面的空白欄
					if(lestLengthOfBlankColumns){
						var titleCell;
						var rec_line = record_body.firstChild;
						var now_row = 0;
						var rowSpanCount = [];
						while(rec_line){
							var blankColumnCount = rowSpanCount[rowSpanCount] || 0;
							var rec_cell = rec_line.firstChild;
							while(rec_cell && lestLengthOfBlankColumns > blankColumnCount){
								var colSpan =  parseInt(rec_cell.getAttribute("colSpan") || 1 );
								var rowSpan =  parseInt(rec_cell.getAttribute("rowSpan") || 1 );
								var deleteCell = true;
								if( blankColumnCount == 0 ){
									if(hasClassName(rec_cell,"total_header") ){
										rec_cell.setAttribute("colSpan",lestLengthOfBlankColumns);
										if(lestLengthOfBlankColumns == maxSettingLength){
											rec_cell.innerHTML = "";
										}
										titleCell = rec_cell;
										deleteCell = false;
									}else{
										titleCell.setAttribute("rowSpan",rowSpan + parseInt(titleCell.getAttribute("rowSpan") || 1 ));
									}
								}
								blankColumnCount += colSpan;
								for( var addRow = 1 ; addRow < rowSpan ; addRow++ ){
									rowSpanCount[now_row+addRow] += colSpan;	
								}
								
								if(rec_cell.nextSibling){
									rec_cell = rec_cell.nextSibling;
									if(deleteCell){
										rec_line.removeChild(rec_cell.previousSibling);
									}
								}else{
									if(deleteCell){
										rec_line.removeChild(rec_cell);
										rec_cell == null;
									}
								}
							}
							rec_line = rec_line.nextSibling;
							now_row++;
						}
						
					}
				}else if(!keepTotalTitle){
					var rec_line = record_body.firstChild;
					while(rec_line){
						if( hasClassName(rec_line.firstChild,"total_header")){
							rec_line.firstChild.innerHTML = "";
						}
						rec_line = rec_line.nextSibling;
					}
				}
				
			}else if(record_body.parentNode){
				record_body.parentNode.removeChild(record_body);
			}
			
		}
		
		function countMinRowSapn( data_body ){
			var checkRow = data_body.firstChild;
			while(checkRow){
				var minRowSpan = 9999;
				var checkCell = checkRow.firstChild;
				while(checkCell){
					minRowSpan = Math.min( orgRowSpan = parseInt(checkCell.getAttribute("orgRowSpan")) || 1 , minRowSpan);
					checkCell.removeAttribute("cutRowSpan");
					checkCell.removeAttribute("orgRowSpan");
					checkCell = checkCell.nextSibling;
				}
				checkRow.setAttribute("minRowSpan",minRowSpan);
				checkRow = checkRow.nextSibling;
			}
		}
		
		

		//分析設定，產生顯示內容
		function createInput(matrix_node,record,contentKey,render,serial_no, dataWhenNULL){
			
			var contentValue = ( contentKey ? record[contentKey] : null );
			if( !contentValue && contentValue !== 0 && contentValue !== false){
				contentValue = dataWhenNULL || "";
			}
			
			contentValue = foramtValueByType( contentValue , matrix_node);
			
			
			var contentRenderDOM = getContent( render , contentValue , [record,contentValue,serial_no] , true );
			
			var inputSetting = matrix_node.input;
			if( !(hasPrototype && isObject(inputSetting))){
				return contentRenderDOM;
			}
			
			//產生input
			var tagName="";
			var elemAttrs = isObject(inputSetting.attrs)?inputSetting.attrs:{};
			var elemEvents = isObject(inputSetting.events)?inputSetting.events:{};
			var elemStyles = isObject(inputSetting.styles)?inputSetting.styles:{};
			var elemClasses = isArray(inputSetting.className)?inputSetting.className:[];
			var elemActions = isFunction(inputSetting.action)?inputSetting.action:null;
			var appendChildren = null;
			
			//舊版屬性
			if(isBasicType(inputSetting.maxlength)){ 
				elemAttrs.size = inputSetting.maxlength; 
				elemAttrs.maxlength = inputSetting.maxlength+2; 
				inputSetting.maxlength=null; 
				inputSetting.size=null; 
			}
			if(isBasicType(inputSetting.size)){ 
				elemAttrs.size = inputSetting.size;
				elemAttrs.maxlength = inputSetting.size+2;
				inputSetting.size=null; 
			}
			inputSetting.attrs = elemAttrs;
			
			var showAtStart = !! (isFunction(inputSetting.genRule)?inputSetting.genRule(record,contentValue,serial_no):(false!==inputSetting.genRule) );
			
			var textNode = createDOM("span",{type:"textNode"},{display:showAtStart?"none":""});
			var inputNode = createDOM("span",{type:"inputNode",key:contentKey},{display:showAtStart?"":"none"});
			
			elemAttrs.name = contentKey+"_"+serial_no;
			elemAttrs.value = contentValue;
			elemAttrs.tableui_key = contentKey;
			
			var inputType = inputSetting.type.toLowerCase();
			
			switch(inputType){
				case 'button':
					elemAttrs.type = "button";
					var buttonValue = inputSetting.text||contentValue;
					contentRenderDOM = document.createTextNode(buttonValue);
					createDOM("button",elemAttrs,elemStyles,elemClasses,{click:function(e){elemActions(getEventTarget(e));}},inputNode,buttonValue);
					break;
					
				case 'textarea':
					onBlurTextAction = function( target , span , record , value ){
						span.previousSibling.title = value;
						var shortTextLength_attr = target.getAttribute("shortTextLength");
						if(isNumeric(shortTextLength_attr)){
							value = ExchangeToShortText( value , parseInt(shortTextLength_attr) );
						}
						return value.replace(/\/r\/n/gi,"<br>").replace(/\/n/gi,"<br>");
					};
					elemAttrs.value =null;
					setValueIfEmpty(elemAttrs,"rows",3);
					if(isNumeric(inputSetting.shortTextLength)){
						elemAttrs.shortTextLength = inputSetting.shortTextLength;
						textNode.title = contentValue;
						contentRenderDOM = getContent( ExchangeToShortText(contentValue , inputSetting.shortTextLength ) );
					}
					createDOM("textarea",elemAttrs,elemStyles,elemClasses,createBlurAction( render , onBlurTextAction , null , elemActions ),inputNode).appendChild(document.createTextNode(contentValue));
					break;
					
				case 'text':
				case 'number':
				case 'date':
				case 'rocdate':
					var isNumber = inputType == 'number';
					var isDate = inputType == 'date';
					var isROCDate = inputType == 'rocdate';
				
					elemAttrs.type = "text";
					
					var onBlurTextAction = null;
					var onBlurValueAction = null;
					
					if(isNumber){
						elemAttrs.datatype = "number";
						setValueIfEmpty(elemAttrs,"pattern","#,###.00");
						setValueIfEmpty(elemAttrs,"align","right");
						
						onBlurTextAction = function( target , span , record , value ){
							if(!window.CSRUtil){ return value;}
							if(!isNumeric(value)){
								value = 0;
							}
							return CSRUtil.$fmt( value , target.getAttribute("pattern") || "#,###.00");
						};
					}else if(isDate || isROCDate){
						elemAttrs.datatype = isDate?"date":"ROCDate";
						setValueIfEmpty(elemAttrs,"pattern",isDate?"yyyy-MM-dd":"yyyMMdd");	
						if(isROCDate && window.toROC && isADdate(contentValue)){
							elemAttrs.value = toROC(contentValue);
						}
						onBlurTextAction = function( target , span , record , value ){
							if(!window.SimpleDateFormat){ return value;}
							var dataTypeIsROC = target.getAttribute("datatype").toUpperCase() == "ROCDATE";
							var pattern = target.getAttribute("pattern");
							
							if(isROCdate(value)){
								value = toY2K(value);
							}
							return ( new SimpleDateFormat( pattern , dataTypeIsROC ? SimpleDateFormat.TW:SimpleDateFormat.US).format(value));
						};
						
						onBlurValueAction = function( target , span , record , value ){
							if(!window.isADdate){ return value;}
							if(isADdate(value)){
								return value;
							}else if(isROCdate(value)){
								return toY2K(value);
							}
							return "";
						};
					}
					
					var input = createDOM("input",elemAttrs,elemStyles,elemClasses, createBlurAction( render , onBlurTextAction , onBlurValueAction , elemActions ) ,inputNode);
					break;
				
				case 'select':
					onBlurTextAction = function( target , span , record , value ){
						getOptionDisplay(target , value);
					};
					var selectNode = createDOM("select",elemAttrs,elemStyles,elemClasses, createBlurAction( render , onBlurTextAction , null , elemActions ),inputNode);
					selectNode.appendChild( getOptions( "option", inputSetting.opts ,inputSetting.optionKey ,inputSetting.optionValue,null,null,null,null,contentValue ) );
					
					contentRenderDOM = getContent( getOptionDisplay(selectNode , contentValue) );
					break;
					
				case 'radio':
				case 'checkbox':
					if(isArray(inputSetting.opts) || isObject(inputSetting.opts) ){
						elemAttrs.name = contentKey+"_"+serial_no;
						inputNode.appendChild( 
							getOptions( 
								inputType
								,inputSetting.opts 
								,inputSetting.optionKey 
								,inputSetting.optionValue
								,elemAttrs
								,elemStyles
								,elemClasses
								,createBlurAction( 
									render 
									,function( target , span , record , value ){ return getOptionDisplay(span,value); } 
									,function( target , span , record , value ){ return getOptionValues(span); }  
									, elemActions 
									, "click" 
								)
								,contentValue 
							) 
						);
						contentRenderDOM = getContent( getOptionDisplay(inputNode , contentValue) );
					}
					/*else{
						tagName = "input";
						elemAttrs.type = type;
						elemAttrs.name = contentKey;
					}*/
					break;
				default:
					return contentRenderDOM;
			
			}
			var fragment = document.createDocumentFragment();
			
			textNode.appendChild(contentRenderDOM);
			
			fragment.appendChild(textNode);
			fragment.appendChild(inputNode);
			
			var actionWhenStart = inputSetting.actionWhenStart;
			
			if(isFunction(actionWhenStart)){
				actionWhenStart(inputNode.firstChild, [record], textNode, ( contentKey ? record[contentKey] : null ) || dataWhenNULL || "" );
			}else if(elemActions && actionWhenStart == true){
				elemActions(inputNode.firstChild, [record], textNode, ( contentKey ? record[contentKey] : null ) || dataWhenNULL || "", false );
			}
			return fragment;
			
		}
		
		var SimpleDateFormatSave = {};
		function foramtValueByType( contentValue , matrix_node ){
			var type = matrix_node.dataType;
			if(type){
				var settingPattern = matrix_node.attrs.pattern;
				type = type.toLowerCase();
				if(type == "number"){
					if(!isNumeric(contentValue)){ contentValue = contentValue ? ( parseFloat(contentValue)||0) : 0 ;  }
					if(isNumeric(contentValue)){
						if ( hasLocaleDisplay && !numberPattern ){
							return localeDisplay.formatNumber(contentValue , col.attrs.scale);
						}else if(window.CSRUtil){
							var numberPattern = settingPattern ||  "#,##0.####";
							return CSRUtil.$fmt(contentValue, numberPattern);	
						}
					}
				}else if(type == "date"){
					if( hasLocaleDisplay && !settingPattern ){
						return localeDisplay.formatDate(contentValue);
					}else if(window.SimpleDateFormat){
						if(!SimpleDateFormatSave[col.key]){
							var datePattern = settingPattern || "yyyy-MM-dd";
							SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.US);
						}
						return (SimpleDateFormatSave[col.key]).format(contentValue);
					}
				}else if(type == "rocdate" && window.SimpleDateFormat ){
					if(!SimpleDateFormatSave[col.key]){
						var datePattern = settingPattern || "yyyMMdd";
						SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.TW);
					}
					return (SimpleDateFormatSave[col.key]).format(contentValue);
				}else if(hasLocaleDisplay){
					if(type == "datetime"){
						return localeDisplay.formatTimestamp(contentValue);
					}else if(type == "dateym"){
						return localeDisplay.formatDateym(contentValue);
					}else if(type == "datey"){
						return localeDisplay.formatDatey(contentValue);
					}
					
				}
				
			}
			return contentValue;
		}
		
		function createBlurAction( renderAction , blurTextAction , blurValueAction , userAction , notBlur){
			var newAction = {};
			
			newAction[(notBlur || "blur")] = function (e){
				//取得元素
				var target = getEventTarget(e);
				var span = target;
				while(span.tagName != "SPAN"){
					span = span.parentNode;
					if(!span){
						return;
					}
				}
				var td = span;
				while(td.tagName != "TD"){
					td = td.parentNode;
					if(!td){
						return;
					}
				}
				var display_span = span.previousSibling;
				
				//取得資料
				var key = span.getAttribute("key");
				var records_sn = td.getAttribute("sn");
				var records = pageControl.getRecordsBy(records_sn);
				
				var new_value = (target.getValue ? target.getValue() : target.getAttribute("value")) || "";
				var old_value = (records[0][key] || "")+"";
				
				//資料轉移
				var update_value  = new_value;
				if(isFunction(blurValueAction)){
					update_value = blurValueAction( target , span , records[0] , new_value );
				}
				
				if(old_value === (update_value+"")){
					return;
				}
				
				var update_text_value  = new_value;
				if(isFunction(renderAction)){
					update_text_value = getContent( renderAction , new_value , [records[0],new_value,records_sn] , true );
				}else if(isFunction(blurTextAction)){
					update_text_value = blurTextAction( target , span , records[0] , new_value );
				}
				
				//更新到原始資料
				for(var i = 0 ; i < records.length ; i += 1){
					records[i][key] = update_value;
				}
				//更新到文字區塊
				while(display_span && display_span.hasChildNodes()){
					display_span.removeChild(display_span.firstChild);
				}
				display_span.appendChild( getContent(update_text_value) );
				
				//執行使用者定義功能	
				if(isFunction(userAction)){
					userAction(target, records, display_span, old_value, true);
				}
			};
			
			return newAction;
		}
		
		function getSerialNumber(TR){
			if(!isDOMObject(TR)){return;}
			while(TR && TR.tagName!="TR"){
				TR = TR.parentNode;
				if(TR.tagName == "BODY"){
					return;
				}
			}
			var row_serialNo = TR.getAttribute("sn");
			if(!isNumeric(row_serialNo)){ return; }
			return row_serialNo;
		}
		
		this.exchangeAutoInput = exchangeAutoInput;
		function exchangeAutoInput( TR , template  , isCloseInput ){
			
			var inputs = getAutoInput( TR , template );
			
			isCloseInput = (isCloseInput !== true && isCloseInput!==false) ? null : isCloseInput;
			
			for(var key in inputs){
				var dom = inputs[key];
				if(isDOMObject(dom)){
					exchangeOneCell(dom,isCloseInput);
				}else if(isArray(dom)){
					for(var i = 0 ; i < dom.length ; i ++ ){
						var array_dom = dom[i];
						if(isDOMObject(array_dom)){
							exchangeOneCell(array_dom,isCloseInput);
						}
					}
				}
			}
			divFitControl.fit();
		}
		
		function exchangeOneCell( input , isCloseInput ){
			var inputSpan = getParentByTagName(input,"span");
			var textSpan = inputSpan.previousSibling;
			if(textSpan.getAttribute("type") == "textNode" && inputSpan.getAttribute("type") == "inputNode" ){
				isCloseInput = (isCloseInput === null) ? textSpan.style.display == "none" : isCloseInput;
				textSpan.style.display = isCloseInput? "" : "none";
				inputSpan.style.display = !isCloseInput? "" : "none";
			}
		}
		
		
		
		this.disableAutoInput = disableAutoInput;
		function disableAutoInput( TR , template , isDisabled ){

			var inputs = getAutoInput( TR , template );
			
			isDisabled = (isDisabled !== true && isDisabled!==false) ? null : isDisabled;
			
			for(var key in inputs){
				var dom = inputs[key];
				if(isDOMObject(dom)){
					if(isDisabled !== null){
						dom.disabled = isDisabled;
					}else{
						dom.disabled = !dom.disabled;
					}
				}else if(isArray(dom)){
					for(var i = 0 ; i < dom.length ; i ++ ){
						var array_dom = dom[i];
						if(isDOMObject(array_dom)){
							if(isDisabled !== null){
								array_dom.disabled = isDisabled;
							}else{
								array_dom.disabled = !array_dom.disabled;
							}
						}
					}
				}
			}
			divFitControl.fit();
		}
		
		this.getAutoInput = getAutoInput;
		function getAutoInput( TR , template ){
			var row_serialNo = getSerialNumber(TR);
			if(!isNumeric(row_serialNo)){ return; }
			
			var inputs = $(dataArea).select("TR[sn="+row_serialNo+"] *[tableui_key]");
			if(!inputs || !inputs.length ){ return {}; }
			
			if(isString(template)){ template = [template]; }
			if(!isArray(template)){ return getMapFormDomList( inputs , "tableui_key" ); }
			
			for( var i = 0 ; i < template.length ; i++ ){
				var filter_key = trim(template[i]);
				if(!filter_key){ continue; }
				for( var j = 0 ; j < inputs.length ; j++ ){
					var input_key = inputs[j].getAttribute("tableui_key");
					if( filter_key != input_key ){
						inputs.splice(j,1);
						j--;
						continue;
					}
				}
			}
			return getMapFormDomList( inputs , "tableui_key" );
			
		}
		
		this.getThisRecordTD = getThisRecordTD;
		function getThisRecordTD( TR , template ){
			var row_serialNo = getSerialNumber(TR);
			if(!isNumeric(row_serialNo)){ return; }
			
			var tds = $(dataArea).select("TR[sn="+row_serialNo+"] td");
			if(!tds || !tds.length ){ return {}; }
			
			if(isString(template)){ template = [template]; }
			if(!isArray(template)){ return getMapFormDomList( tds , 'name' ); }
			
			for( var i = 0 ; i < template.length ; i++ ){
				var filter_key =  trim(template[i]);
				if(!filter_key){ continue; }
				for( var j = 0 ; j < tds.length ; j++ ){
					var td_key = tds[j].getAttribute("name");
					if( filter_key != td_key ){
						tds.splice(j,1);
						j--;
						continue;
					}
				}
			}
			return getMapFormDomList( tds , 'name') ;
		}
		
		function getMapFormDomList( domList , attr_key ){
			if(!isArray(domList) || !domList.length){ return {}; }
			var rtn_map = {};
			for( var i = 0 ; i < domList.length ; i++ ){
				var dom = domList[i];
				if(!isDOMObject(dom)){ continue; }
				var dom_key =  trim(dom.getAttribute(attr_key));

				var otherDomAtMap = rtn_map[dom_key];
				if(otherDomAtMap){
					if(isArray(otherDomAtMap)){
						otherDomAtMap.push(dom);
					}else{
						rtn_map[dom_key] = [otherDomAtMap,dom];
					}
				}else{
					rtn_map[dom_key] = dom;
				}
			}
			return rtn_map;
		}
		
		this.setValueToTD = setValueToTD;
		function setValueToTD( TR , target_name , value ){
			var target = getThisRecordTD( TR , target_name )[target_name];
			if(!target){ return; }
			
			if(isArray(target)){
				for(var i = 0 ; i < target.length ; i++ ){
					executeBlur(target[i]);
				}
			}else{
				target.innerHTML = value;
			}
		}
		
		this.setValueToAutoInput = setValueToAutoInput;
		function setValueToAutoInput( TR , target_name , value ){
			var target = getAutoInput( TR , target_name )[target_name];
			if(isArray(target)){
				for(var i = 0 ; i < target.length ; i++ ){
					executeBlur(target[i] , value);
				}
			}else{
				executeBlur(target , value);
			}
		}
		
		function executeBlur( dom , value ){
			if(!isDOMObject(dom) || dom.disabled ){return; }
			var testDisabled = dom;
			while( isDOMObject(testDisabled) && testDisabled.tagName!="TD"){
				if(testDisabled.style.display == 'none'){
					return;
				}
				testDisabled = testDisabled.parentNode;
			}
			var target_type = (dom.getAttribute("type")||"").toLowerCase();
			if( ( target_type == 'checkbox' || target_type == 'radio')){
				if(dom.getAttribute("value") != value){
					return;
				}
				dom.checked = true;
				dom.click();
			}else if(dom.tagName == "BUTTON" || target_type == 'button' ){
				dom.click();	
			}else{
				dom.focus();
				if(dom.tagName == "TEXTAREA"){
					dom.innerHTML = value;
				}else{
					dom.value = value;
				}
				dom.blur();
			}
		}
		
		this.getRecordsByCell = getRecordsByCell;
		function getRecordsByCell( td ){
			if(!isDOMObject(td)){ return []; }
			while(td.tagName != "TD"){
				td = td.parentNode;
				if(td.tagName == "BODY"){
					return [];
				}
			}
			var records_sn = td.getAttribute("sn");
			if(!records_sn || records_sn =="null" || records_sn == "undefined"){ return []; }
			return pageControl.getRecordsBy(records_sn);
		}
		
		this.isAutoCheckBoxSelected = isAutoCheckBoxSelected;
		function isAutoCheckBoxSelected(td){
			var dataObjs = getRecordsByCell(td);
			if(!dataObjs || !dataObjs.length ){ return false; }
			return !!(dataObjs[0].tableuiAutoCheckBoxResult > 0);
			
		}
		
		//點選全選按鈕
		this.autoCheckBoxSelectAll = autoCheckBoxSelectAll;
		function autoCheckBoxSelectAll(isChecked){
			
			if(isChecked!==true || isChecked !== false){
				isChecked = getSelectAllBox().checked;
			}
			checked_status = isChecked;
			$(dataArea).select("table tbody input[name=autoCheckBox_"+table_id+"]").each(
				function(elem)	{
					if(!elem.disabled){
						elem.checked = isChecked;
					}
				}
			);
			var records = pageControl.getAllRecords();
			if(!isArray(records)){
				return;
			}
			for(var i = 0 ; i < records.length ; i += 1){
				if(records[i].tableuiAutoCheckBoxResult >= 0 ){
					records[i].tableuiAutoCheckBoxResult = isChecked ? 1 : 0 ;
				}
			}
		}
		
		//點選單一
		this.autoCheckBoxSingle = autoCheckBoxSingle;
		function autoCheckBoxSingle( checkBox , records , key ){
			var isChecked = checkBox.checked;
			var value = checkBox.getAttribute("value");
			var isTypeRadio = checkBox.getAttribute("type").toLowerCase() == "radio";
			var allRecords = pageControl.getAllRecords();
			if(isTypeRadio){
				//Radio型態，先把全部歸零，再更新本次
				for(var i = 0 ; i < allRecords.length ; i += 1){
					allRecords[i].tableuiAutoCheckBoxResult = 0;
				}
				for(var i = 0 ; i < records.length ; i += 1){
					records[i].tableuiAutoCheckBoxResult = isChecked ? 1 : 0;
				}
			}else{
				//checkbox型態，若有key，要從checkBox取資料修正。無key，僅處理資料；
				if(key && value){
					$(dataArea).select("table tbody input[name=autoCheckBox_"+table_id+"][value="+value+"]").each(
						function(elem){
							var elem_records = dataControl.getRecordsByCell(elem);
							if(elem_records[0].tableuiAutoCheckBoxResult >= 0){
								for(var i = 0 ; i < elem_records.length ; i += 1){
									elem_records[i].tableuiAutoCheckBoxResult = isChecked ? 1 : 0;
								}
							}
						}
					);
				}else{
					for(var i = 0 ; i < records.length ; i += 1){
						records[i].tableuiAutoCheckBoxResult = isChecked ? 1 : 0;
					}		
				}
			}
			
			
			var selectAllBox = getSelectAllBox();
			if(selectAllBox){
				var has0 = false;
				var has1 = false;
				for(var i = 0 ; i < allRecords.length ; i += 1){
					var rec_checkStatus = parseInt(allRecords[i].tableuiAutoCheckBoxResult);
					if(has0 && has1){
						break;
					}else if( rec_checkStatus== 1){
						has1 = true;
					}else if(rec_checkStatus == 0){
						has0 = true;
					}
					
				}
				selectAllBox.checked =  !has0 && has1;
			}
		}
		
		function getSelectAllBox(){
			//alert($(dataArea).select("table thead input[name=autoCheckBox_"+table_id+"_SelectAll]").length);
			return $(dataArea).select("table thead input[name=autoCheckBox_"+table_id+"_SelectAll]")[0];
		}
		
		this.compareAllTableCellHeight = compareAllTableCellHeight;
		function compareAllTableCellHeight(){
			compareCellHeight(main_table_head,fixed_table_head);
			var main_table_tBodies = main_table.tBodies;
			var fixed_table_tBodies = fixed_table.tBodies;
			for( var i = 0 ; i < main_table_tBodies.length ; i += 1){
				compareCellHeight(main_table_tBodies[i],fixed_table_tBodies[i]);	
			}
			
			compareCellHeight(main_table_foot,fixed_table_foot);
		}
		
		//將兩個Table行高固定
		function compareCellHeight( parent1 , parent2 ){
			if(!parent1 || !parent2 ){ return; }
			if( !parent2.hasChildNodes()|| !parent1.hasChildNodes() ){ return; }
			
			var line_1 = parent1.firstChild;
			var line_2 = parent2.firstChild;
			var buffer_line_1 = 0;
			var buffer_line_2 = 0;
			var saved_line_1 = [];
			var saved_line_2 = [];
			
			while (line_1 && line_2) {
				if(buffer_line_1 == 0){
					saved_line_1.push(line_1);
					buffer_line_1 = parseInt(line_1.getAttribute("minRowSpan")) || 1;
				}
				
				if(buffer_line_2 == 0){
					saved_line_2.push(line_2);
					buffer_line_2 = parseInt(line_2.getAttribute("minRowSpan")) || 1;
				}				
				
				while (buffer_line_1 > 0 && buffer_line_2 > 0){
					buffer_line_1--;
					buffer_line_2--;
				}
				
				if( buffer_line_1 == 0 && buffer_line_2 == 0){
					
					var height1 = getOffsetHeightOfLines(saved_line_1);
					var height2 = getOffsetHeightOfLines(saved_line_2);
					
					var setHeight = Math.max(height1,height2,0);
					
					setHeightOfLines(saved_line_1,setHeight);
					setHeightOfLines(saved_line_2,setHeight);
				}
				
				if( buffer_line_1 == 0){
					line_1 = line_1.nextSibling;
				}
				
				if( buffer_line_2 == 0){
					line_2 = line_2.nextSibling;
				}
			}
		}
		
		function getOffsetHeightOfLines(saved_lines){
			var height = 0
			for(var j = 0 ; j < saved_lines.length ; j++ ){
				saved_lines[j].style.height = "";
				height += saved_lines[j].offsetHeight;
			}
			return height;
		}
		
		function setHeightOfLines(saved_lines , max_height){
			saved_lines.sort(function( cell_1 , cell_2 ){
				var compare1 = cell_1.offsetHeight;
				compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
				var compare2 = cell_2.offsetHeight;
				compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
				return compare1-compare2;
			});
			
			for(var j = saved_lines.length ; j > 0  ; j-- ){
				var workingNode = saved_lines[j-1];
				var guess_height = Math.max( parseInt(max_height/j), workingNode.offsetHeight);
				workingNode.style.height = guess_height+"px";
				max_height -= guess_height;
			}
			
			saved_lines.splice(0,saved_lines.length);
		}
		
		
		//Event排序事件
		function sortData(e){
			var target = getEventTarget(e);
			if(target.tagName != "A"){
				target = target.parentNode;
			}
			sortDetail( target.getAttribute("key") , target.innerHTML==SORT_DECREASE , target.getAttribute("rule")  );
		}
		
		this.sort = function(key, isIncrease, sortRule){
			if(isIncrease === true || isIncrease === false){
				sortDetail(key, isIncrease , sortRule );
			}else{
				sortDetail(key, isIncrease != SORT_DECREASE , sortRule );
			}
		};
		
		//排序主體
		function sortDetail(key, isIncrease, sortRule ){
			if(!isBasicType(key)){return;}
			sortGroupKeys = [];
			if(settings.allGroupKeys){
				for(var i = 0 ; i < settings.allGroupKeys.length ; i += 1){
					if(key == settings.allGroupKeys[i]){ break;}
					sortGroupKeys.push(settings.allGroupKeys[i]);
				}
			}
			sortGroupKeys.push(key);
	
			isIncrease = !!isIncrease;
			
			var records = pageControl.getAllRecords();
			
			sortRule = sortRule && sortRule.toUpperCase();
				
			if(sortRule == "NUMBER"){
				records.sort(isIncrease?sortByNumericIncrease:sortByNumericDecrease);
			}else if(sortRule == "DATE" || sortRule == "ROCDATE"){
				records.sort(isIncrease?sortByDateIncrease:sortByDateDecrease);
			}else{
				records.sort(isIncrease?sortByStringIncrease:sortByStringDecrease);
			}
		
			
			var sort_elements = main_table_head.getElementsByTagName("th");
			
			for(var i = 0 ; i < sort_elements.length ; i += 1){
				var elem = sort_elements[i];
				if(elem.getAttribute("name") == key){
					addClassName(sort_elements,isIncrease?"sort_az":"sort_za");
				}
			}
			sort_elements = fixed_table_head && fixed_table_head.getElementsByTagName("th");
			
			for(var i = 0 ; i < sort_elements.length ; i += 1){
				var elem = sort_elements[i];
				if(elem.getAttribute("name") == key){
					addClassName(sort_elements,isIncrease?"sort_az":"sort_za");
				}
			}
			
			setSortRule(key,isIncrease);
			pageControl.reLoadin(records);
		}
		
		//確定資料是否為同一GROUP
		function checkIsGroup( rec1 , rec2 ){
			if(!sortGroupKeys || sortGroupKeys.length == 1){ return sortGroupKeys[0]; }
			for(var i = 0 ; i < sortGroupKeys.length-1 ; i += 1){
				var key = sortGroupKeys[i];
				if(rec1[key] !== rec2[key] ){
					return false;
				}
			}
			return sortGroupKeys[sortGroupKeys.length-1];
		}
		
		//排序數字規則
		function sortByNumericIncrease( rec1 , rec2 ){
			var key = checkIsGroup( rec1 , rec2 );
			if(!key){ return 0;}
			var compare1 = rec1[key];
			compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
			var compare2 = rec2[key];
			compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
			return compare1-compare2;
		}
		function sortByNumericDecrease( rec1 , rec2 ){ return sortByNumericIncrease( rec2 , rec1 ); }
		
		//排序日期規則
		function sortByDateIncrease( rec1 , rec2 ){
			var key = checkIsGroup( rec1 , rec2 );
			if(!key){ return 0;}
			if(!window.isADdate){ return sortByStringIncrease( rec1 , rec2 ); }
			var compare1 = rec1[key];
			compare1 = isADdate(compare1) ? compare1 : "1900-01-01";
			var compare2 = rec2[key];
			compare2 = isADdate(compare2) ? compare2 : "1900-01-01";
			return diffDay(compare1, compare2 , false);
		}
		function sortByDateDecrease( rec1 , rec2 ){ return sortByDateIncrease( rec2 , rec1 ); 	}
		
		//排序文字規則
		function sortByStringIncrease( rec1 , rec2 ){
			var key = checkIsGroup( rec1 , rec2 );
			if(!key){ return 0;}
			var compare1 = rec1[key] || "";
			var compare2 = rec2[key] || "";
			return compare1 < compare2 ? -1 : 1 ;
		}
		function sortByStringDecrease( rec1 , rec2 ){ return sortByStringIncrease( rec2 , rec1 ); }
	
		//將畫面資料清除
		this.clearAll = clearAll;
		function clearAll(){
			clearOneTableRecords(main_table);
			clearOneTableRecords(fixed_table);
		}
		function clearOneTableRecords(table){
			var nodes = table.childNodes;
			for(var i = nodes.length-1 ; i >= 0 ; i -= 1  ){
				if(isDOMObject(nodes[i]) && (nodes[i].tagName == "THEAD" || nodes[i].tagName == "TFOOT" )){
					continue;
				}
				table.removeChild(nodes[i]);
			}
		}
		
		//對records設定sn
		this.setSerialNnmber = setSerialNnmber;
		function setSerialNnmber( records , sn_start_from ){
			
			if(!isNumeric(sn_start_from)){sn_start_from = 0; }

			var setAutoCheckAllData = false;
			var genRule = false;
			var disabledRule = false;
			
			if (config.autoCheckBox) {
				setAutoCheckAllData = true;
				var autoCheckBoxsetting = isObject(config.autoCheckBox) ? config.autoCheckBox : {};
				genRule = isFunction(autoCheckBoxsetting.genRule) && autoCheckBoxsetting.genRule ;
				disabledRule = isFunction(autoCheckBoxsetting.disabledRule) && autoCheckBoxsetting.disabledRule ;
			}
			
			for(var i = 0 ; i < records.length ; i += 1){
				//設定序號
				var sn = i+sn_start_from+1;
				records[i]["tableUI_serialNumber"] = sn;
				//設定autoCheckBox狀態
				if(setAutoCheckAllData){
					if(!isNumeric(records[i].tableuiAutoCheckBoxResult)){
						records[i].tableuiAutoCheckBoxResult = 0;
					}
					if (genRule && !genRule(records[i], sn)) {
						records[i].tableuiAutoCheckBoxResult = -2;
                    }else if(disabledRule && !!disabledRule(records[i], sn)){
						records[i].tableuiAutoCheckBoxResult = -1;
					}
				}
			}
		}
		
		//依照資料template取出需要的資料
		this.getRecordsByTemplate = getRecordsByTemplate;
		function getRecordsByTemplate( filterRecords , template ){
			if(isString(template)){
				var tempRecords = [];
				for(var i = 0 ; i < filterRecords.length ; i += 1){
					var filterValue = filterRecords[i][template];
					if( filterValue || filterValue === 0){
						tempRecords.push(filterValue);
					}
				}
				return 	tempRecords;
			}else if(isArray(template)){
				for(var i = template.length-1 ; i >=  0 ; i -= 1){
					if(!isString(template[i])){
						template.splice(i,1);
					}
				}
				if(template.length) {
					var rtnRecords = [];
					for(var i = 0 ; i < filterRecords.length ; i += 1){
						var tempRecords = {};
						for(var j = 0 ; j < template.length ; j += 1){
							tempRecords[template[j]] = filterRecords[i][template[j]];
						}
						rtnRecords.push(tempRecords);
					}
					return 	rtnRecords;
				}
			}
			return filterRecords;
			
		}
		
		function getSortRule(key){
			if(sortRules.length == 0 ){ return null; }
			for(var i = 0 ; i < sortRules.length ; i += 1){
				if(sortRules[i].key == key){
					return sortRules[i].direction;
				}
			}
			return null;
		}
		
		function setSortRule(key , direction , sortRule ){
			if( sortRules.length != 0 ){ 
				for(var i = 0 ; i < sortRules.length ; i += 1){
					if(sortRules[i].key == key){
						sortRules.splice(i,1);
						break;
					}
				}
			}
			sortRules.push({key:key,direction:direction,sortRule:sortRule});
		}
		
		
		this.clearTableInfo = clearTableInfo;
		function clearTableInfo(){
			sortRules = [];
			
			var sort_elements = main_table_head.getElementsByTagName("th");
			for(var i = 0 ; i < sort_elements.length ; i += 1){
				var elem = sort_elements[i];
				removeClassName(elem,"sort_az");
				removeClassName(elem,"sort_za");
				elem.style.position = "";
				var menu = elem.lastChild;
				if(elem.tagName == "UL"){
					menu.style.display = "none";
				}
			}
			
			sort_elements = fixed_table_head ? fixed_table_head.getElementsByTagName("th") : [];
			for(var i = 0 ; i < sort_elements.length ; i += 1){
				var elem = sort_elements[i];
				removeClassName(elem,"sort_az");
				removeClassName(elem,"sort_za");
				elem.style.position = "";
				var menu = elem.lastChild;
				if(elem.tagName == "UL"){
					menu.style.display = "none";
				}
			}
			
		}
		
		
		
		this.getTableInfo = getTableInfo;
		function getTableInfo( setPage , setSort ){
			var info = setPage!==false ? pageControl.getRecordsInfo() : {};
			
			settingCtrl.getFixedHiddenInfo(info);
			
			if(!isFatchMode && setSort!==false){
				info.sortRecords = sortRules;
			}
			return info;
		}
		
		this.setTableInfo = setTableInfo;
		function setTableInfo(info){
			if(isObject(info)){
				settingCtrl.setFixedHiddenInfo(info);
				if(!isFatchMode && isArray(info.sortRecords)){
					for(var i = 0 ; i < info.sortRecords.length ; i += 1 ){
						sortDetail( info.sortRecords[i].key, info.sortRecords[i].direction, info.sortRecords[i].sortRule );
					}
				}
				pageControl.setRecordsInfo(info);
			}	
		}
		
	}
	
    //換頁控制(已預先存入資料)
	function pageControl_impl(){
		//輸入資料
	    var records = null;
	    var recordsTotalCount = null;
	    var recordsSubTotalCount_org = null;
		//分組資料
		var recordsWithGroup = null;
		var recordsSubTotalCount = null;
		
		var active_records = null;

		var pageSize = config.pageSize && isNumeric(config.pageSize) ? parseInt(config.pageSize) : false;
		
		var nowPage = 0;
		var totalPage = 0;
		var totalRecord = 0;
		var nowRecord_pervious_start = 0;
		var nowRecord_next_start = 0;
		
		var settings = settingCtrl.settings;
		
		var hasGroup = settings.allGroupKeys && settings.allGroupKeys.length > 0;
		
		var textPattern = 
			isString(config.recordInfoPattern) ?
			config.recordInfoPattern
			:(
				! hasGroup
				? "第 {nowPage} 頁/共 {totalPage} 頁 共 {totalRecord} 筆"
				: "第 {nowPage} 頁/共 {totalPage} 頁 群組 {totalGroup} 組/共 {totalRecord} 筆" 
			);
		
		var afterLoad = isFunction(config.afterLoad) ? config.afterLoad : null;
		var pageChange = isFunction(config.pageChange) ? config.pageChange : null;

		if(pageSize){
			var controlDiv = createDOM("DIV",{name:"tableControl"},{right:"10px"},["childOfTableParent","tableControl"],null,main_div);
			
			createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_first.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadFirst},controlDiv));
			createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_pervious.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadPrevious},controlDiv));
			var controlSelect = createDOM("select", null,null,null,{change:function(e){ loadPage(getEventTarget(e).value);}},controlDiv);
			createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_next.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadNext},controlDiv));
			createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_last.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadLast},controlDiv));
			var controlText = createDOM("SPAN", null,null,null,{click:loadPrevious},controlDiv);
			//this.controlDiv = controlDiv;
			updateInformation();
		}

		
		this.getRecordsInfo=getRecordsInfo;
		function getRecordsInfo(){
			return {pageNo:nowPage};
		}
		
		this.setRecordsInfo=setRecordsInfo;
		function setRecordsInfo(info){
			loadPage(info.pageNo);
		}
		
		this.addRecords = addRecords;
		function addRecords(input_records ){
			//不允許Group增加資料
			if(hasGroup){ return; } 
			if(!isObject(input_records) || (!isArray(input_records) || !input_records.length) ){ return; }
			if(!records){
				records = [];
			}
			if(isObject(input_records)){
				records.push(input_records);
			}else if(isArray(input_records)){
				records.concat(input_records);
			}
			
			init(nowPage);
		}
		
		this.resetTotalCount = resetTotalCount;
		function resetTotalCount(total_count){
			loadin(records , total_count , recordsSubTotalCount );
		}
		
		this.resetSubTotalCount = resetSubTotalCount;
		function resetSubTotalCount(subtotal_count){
			loadin(records , recordsTotalCount , recordsSubTotalCount );
		}
		
		this.getTotalCount = function (){
			return recordsTotalCount || null;
		}
		
		this.getSubTotalCount = function (){
			return recordsSubTotalCount || null;
		}
		
		this.loadin = loadin;
		function loadin(input_records , total_count , subtotal_count , preCheckedValues ){
			//格式化資訊
		    records = null;
		    recordsTotalCount = null;
		    recordsSubTotalCount = null;
		    recordsWithGroup = null;
			
			if( !input_records || !isArray(input_records) || !input_records.length){ 
			    dataControl.clearAll();
				active_records = null;
				totalPage = 0;
				totalRecord = 0;
				nowPage = 0;
				nowRecord_pervious_start = 0;
				nowRecord_next_start = 0;
				updateInformation();
			    return; 
			}
			
			//格式化合計
			recordsTotalCount = null;
			if (isArray(total_count) && total_count.length > 0 && isObject(total_count[0])) {
			    recordsTotalCount = total_count;
			}else if(isObject(total_count)){
			    if(isObject(total_count.value)){
			        recordsTotalCount = [total_count];
			    }else{
			        recordsTotalCount = [{value:total_count}];
			    }
			}
			
			//格式化小計
			recordsSubTotalCount_org = null;
			if(isArray(subtotal_count) && subtotal_count.length > 0){
				if(isArray(subtotal_count[0]) && subtotal_count[0].length > 0){
					recordsSubTotalCount_org = subtotal_count;
				}else if(isObject(subtotal_count[0]) && isObject(subtotal_count[0].value)){
					recordsSubTotalCount_org = [subtotal_count];
				}
			}
			
			if(settingCtrl.settings.checkAllBox){
				settingCtrl.settings.checkAllBox.checked = false;
			}
			
			//判斷是否預先選取
			var autoCheckBoxKey = settingCtrl.getAutoCheckBoxKey();
			if(autoCheckBoxKey && isArray(preCheckedValues) && preCheckedValues.length > 0){
				for(var i = 0 ; i < input_records.length ; i++ ){
					var checkValue = input_records[i][autoCheckBoxKey];
					if( isBasicType(checkValue) && isInArray(preCheckedValues , checkValue)){
						input_records.tableuiAutoCheckBoxResult = 1;
					}
				}
			}
			
			dataControl.clearTableInfo();
			
			reLoadin(input_records);
			
		}
		
		this.reLoadin = reLoadin;
		function reLoadin(input_records){
			recordsWithGroup = null;
			records = input_records;
			if (hasGroup) {
			    
			    var splitGroupKey = settings.allGroupKeys[0];
			    recordsWithGroup = [];
			    recordsSubTotalCount = [];

				var preRecord = records[0];
				var tempGroupSaveing = [];
				tempGroupSaveing.push(preRecord);
				recordsWithGroup.push(tempGroupSaveing);
				
				var tempGroupSubRecordsSaveing = [];
				recordsSubTotalCount.push(tempGroupSubRecordsSaveing);
				
				var nowGroupKey = preRecord[splitGroupKey];
				

				for(var records_count = 1 ; records_count < records.length ; records_count+=1 ){
					var testRecord = records[records_count];
					var isGroup = testRecord[splitGroupKey] == nowGroupKey;
					if (!isGroup) {
						if(recordsSubTotalCount_org){
							for (var g1 = 0 ; g1 < recordsSubTotalCount_org.length ; g1 += 1) {
								for (var g2 = 0 ; g2 < recordsSubTotalCount_org[g1].length ; g2 += 1) {
									var key = recordsSubTotalCount_org[g1][g2].key;
									if (isString(key) && key == nowGroupKey ) {
										tempGroupSubRecordsSaveing.push(recordsSubTotalCount_org[g1][g2]);
									} else if (isObject(key) && key[splitGroupKey] == nowGroupKey ) {
										tempGroupSubRecordsSaveing.push(recordsSubTotalCount_org[g1][g2]);
									}
								}
							}
						}
						tempGroupSaveing=[];
						recordsWithGroup.push(tempGroupSaveing);
						
						tempGroupSubRecordsSaveing = [];
						recordsSubTotalCount.push(tempGroupSubRecordsSaveing);
						
						nowGroupKey = testRecord[splitGroupKey];
					}
					tempGroupSaveing.push(testRecord);
				}
				//最後一筆
				if(recordsSubTotalCount_org){
					for (var g1 = 0 ; g1 < recordsSubTotalCount_org.length ; g1 += 1) {
						for (var g2 = 0 ; g2 < recordsSubTotalCount_org[g1].length ; g2 += 1) {
							var key = recordsSubTotalCount_org[g1][g2].key;
							if (isString(key) && key == nowGroupKey ) {
								tempGroupSubRecordsSaveing.push(recordsSubTotalCount_org[g1][g2]);
							} else if (isObject(key) && key[splitGroupKey] == nowGroupKey ) {
								tempGroupSubRecordsSaveing.push(recordsSubTotalCount_org[g1][g2]);
							}
						}
					}
				}
			}
			
			init();
		}
		
		function init( setPageTo ){
			
			dataControl.setSerialNnmber(records);
			
			while(pageSize && controlSelect.hasChildNodes()){
				controlSelect.removeChild(controlSelect.firstChild);
			}
			
			if(!records){
				active_records = null;
				totalPage = 0;
				totalRecord = 0;
				nowPage = 0;
				nowRecord_pervious_start = 0;
				nowRecord_next_start = 0;
			}else{
				active_records = recordsWithGroup?recordsWithGroup:records;
				totalPage = Math.ceil(active_records.length/(pageSize+0.0));
				totalRecord = active_records.length;
				if(pageSize){
					for(var select_count = 1 ; select_count<=totalPage ; select_count+=1){
						createDOM("OPTION", {value:select_count},null,null,null,controlSelect,"&nbsp;-&nbsp;"+select_count+"&nbsp;-&nbsp;");
					}
				}
				nowPage = 0;
				nowRecord_pervious_start = 0;
				nowRecord_next_start = 0;
				if(pageSize && isNumeric(setPageTo) && setPageTo < totalPage){
					loadPage(setPageTo);
				}else{
					loadFirst();
				}
				if(afterLoad){ afterLoad(main_table); }
			}
			updateInformation();
		}
		
		function updateInformation(){
			if(window.autoCreateDate){ autoCreateDate(dataArea); }
			
			if(window.autoFormatToNumber){ autoFormatToNumber(dataArea); }
			if(window.autoFormatToDate){ autoFormatToDate(); }
			
			
			if(divFitControl){	divFitControl.fit(); }
			
			if(!pageSize){ return; }
			
			controlSelect.value = nowPage;
			
			var text = textPattern
			.replace("{nowPage}",nowPage)
			.replace("{totalPage}",totalPage)
			.replace("{totalRecord}",totalRecord)
			.replace("{totalGroup}",recordsWithGroup? recordsWithGroup.length : 0);
			controlText.innerHTML = text;
			//check選擇
			if(records){
				$(dataArea).select("tbody input[name=autoCheckBox_"+table_id+"]").each(
					function(elem)	{
						var dataObj = dataControl.getRecordsByCell(elem);
						var tableuiAutoCheckBoxResult = dataObj[0].tableuiAutoCheckBoxResult;
						if(tableuiAutoCheckBoxResult > 0 ){
							elem.checked = true;
						}else if( tableuiAutoCheckBoxResult < 0 ){
							elem.disabled = true;
							if(tableuiAutoCheckBoxResult < -1){
								elem.style.display = "none";
							}
						}
					}
				);
				if(pageChange){ pageChange(nowPage); }
				
				$(dataArea).select("input[shouldBeChecked]").each( function(elem){ elem.checked = true; elem.removeAttribute("shouldBeChecked"); } );
				
				if(window.UI_Manager){
					UI_Manager.callShareingObserve("resize" , "tableUI");
				}else if(window.fix){
					fix();
				}
				try{
					if(window.parent && window.parent.UI_Manager){
						window.parent.UI_Manager.callShareingObserve("resize");
					}
				}catch(err){
				}
			}
			
		}
		
		this.loadPrevious = loadPrevious;
		function loadPrevious(){
			if(nowPage <= 1){ return; }
			loadFrom(nowRecord_pervious_start);
			nowPage -= 1;
			updateInformation();
		}
		
		this.loadNext = loadNext;
		function loadNext(){
			if (nowPage >= totalPage) { return; }
		    nowPage = parseInt(nowPage) + 1;
			loadFrom(nowRecord_next_start);
			
		}
		
		this.loadFirst = loadFirst;
		function loadFirst(){
			if(nowPage == 1){ return; }
			nowPage = 1;
			loadFrom(0);
		}
		
		this.loadLast = loadLast;
		function loadLast(){
			if(nowPage >= totalPage){ return; }
			nowPage = totalPage;
			loadFrom((totalPage-1)*pageSize);
		}
		
		this.reloadPage = reloadPage;
		function reloadPage(){
			loadFrom((nowPage-1)*pageSize);
		}
		
		this.loadPage = loadPage;
		function loadPage(pageNO){
			if(!isNumeric(pageNO)){ return; }
			if(pageNO<1){
				loadFirst();
			}else if(pageNO>totalPage){
				loadLast();
			}else{
				nowPage = pageNO;
				loadFrom((pageNO-1)*pageSize);
			}
		}
		
		function loadFrom(start) {
		    
			if(!active_records){
				return;
			}
			
			if(!pageSize){
				dataControl.clearAll();
				for(var rwg_count = 0 ; rwg_count < active_records.length ; rwg_count+=1 ){
					dataControl.createRecordsBody( active_records[rwg_count] ,null, rwg_count );
				}
				return;
			}
			
			if(!isNumeric(start)){
				return;
			}
			
			if( start >= active_records.length){
				loadLast();
				return;
			}
			
			if( start < 0 ){
				loadFirst();
				return;
			}
			
			dataControl.clearAll();
			
			var end = parseInt(start)+ pageSize;
			if(end > active_records.length ){
				end = active_records.length;
			}
			
			var load_Records = active_records.slice(start,end);
			
			for (var rwg_count = 0 ; rwg_count < load_Records.length ; rwg_count += 1) {
			    dataControl.createRecordsBody(load_Records[rwg_count], recordsSubTotalCount ? recordsSubTotalCount[start+rwg_count] : null , start + rwg_count);
			}
			
			if (recordsTotalCount) {
			    dataControl.createTotalRecordBody(recordsTotalCount);
			}

			nowRecord_pervious_start = start < pageSize ? 0 : start - pageSize;
			nowRecord_next_start = end;
			
			updateInformation();
		}
		
		this.hasRecoeds = function(){ return records && records.length > 0;	};
		
		//取得資料
		this.getAllRecords = getAllRecords;
		function getAllRecords( template ){
			if(template){
				return dataControl.getRecordsByTemplate( records || [] , template );
			}else{
				return records || [];
			}
		}
		
		this.getCheckedRecords = getCheckedRecords;
		function getCheckedRecords( template ){
			var checkedRecords = [];
			for(var i = 0 ; records && ( i < records.length ) ; i += 1){
				if(records[i].tableuiAutoCheckBoxResult > 0){
					checkedRecords.push(records[i]);
				}
			}	
			
			if( checkedRecords.length == 0  ){
				return checkedRecords;
			}
			
			return dataControl.getRecordsByTemplate( checkedRecords , template );
			
		}
		
		this.getRecordsBy = getRecordsBy;
		function getRecordsBy( getTemplate , recordTemplate ){
			if( !getTemplate ){
				return [];
			}
			getTemplate = (getTemplate+"").split(",");
			var rtnList = [];
			for(var i = 0  ; i < getTemplate.length ; i+=1 ){
				var recNo = getTemplate[i] -1 ;
				if(isNumeric(recNo) && recNo >= 0  && recNo < records.length){
					rtnList.push(records[recNo]);
				}
			}
			return dataControl.getRecordsByTemplate( rtnList , recordTemplate );
		}
		
	}
	
    //換頁控制(動態取得資料)
	function pageControlFatch_impl(){
		
		var queryUrl = null;
		var queryRules = null;
		
		var records = null;
		var pervious_records = null;
		var next_records = null;
		
		var successFunction = null;
		var failFunction = null;
		
		var pageSize = config.pageSize && isNumeric(config.pageSize) ? parseInt(config.pageSize) : 10;
		
		var nowPage = 0;
		var totalPage = 0;
		var totalRecord = 0;
		
		var nowRecord_pervious_start = 0;
		var nowRecord_next_start = 0;
		
		var thisAjaxRecordFrom = 0;
		var nextAjaxRecordFrom = 0;
		var perviousAjaxRecordFrom = 0;
		
		//設定為一次load 5頁的量，但每次不得大於200筆資料
		var recordNumOfFatch = isNumeric(config.isLoadByFatch) && config.isLoadByFatch >= pageSize ? config.isLoadByFatch : (pageSize*5) ;
		if(recordNumOfFatch > 200){ recordNumOfFatch = 200; alert("分批查詢每次不得大於200筆資料，請修改[isLoadByFatch]參數!"); }
		
		if( pageSize > recordNumOfFatch){
			pageSize = recordNumOfFatch;
		}else if(recordNumOfFatch % pageSize != 0 ){ 
			recordNumOfFatch = recordNumOfFatch - (recordNumOfFatch % pageSize); 
		}
		
		
		var settings = settingCtrl.settings;
		
		var textPattern = isString(config.recordInfoPattern) ?
			config.recordInfoPattern
			:"第 {nowPage} 頁/共 {totalPage} 頁 共 {totalRecord} 筆";
		
		var afterLoad = isFunction(config.afterLoad) ? config.afterLoad : null;
		var pageChange = isFunction(config.pageChange) ? config.pageChange : null;
		
		var controlDiv = createDOM("DIV",{name:"tableControl"},{right:"10px"},["childOfTableParent","tableControl"],null,main_div);
		createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_first.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadFirst},controlDiv));
		createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_pervious.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadPrevious},controlDiv));
		var controlSelect = createDOM("select", null,null,null,{change:function(e){ loadPage(getEventTarget(e).value);}},controlDiv);
		createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_next.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadNext},controlDiv));
		createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_last.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadLast},controlDiv));
		var controlText = createDOM("SPAN", null,null,null,{click:loadPrevious},controlDiv);
		createDOM("IMG", {src:HTML_locate_base+"images/CM/ui/TableUI_go_refresh.png"},null,null,null,createDOM("button",{type:"button"},null,null,{click:loadAgain},controlDiv));
		
		updateInformation();
		
		this.getRecordsInfo=getRecordsInfo;
		function getRecordsInfo(){
			return {thisAjaxRecordFrom:thisAjaxRecordFrom , queryUrl:queryUrl, queryRules:queryRules };
		}
		
		this.setRecordsInfo=setRecordsInfo;
		function setRecordsInfo(info){
			if(isString(info.queryUrl) && isString(info.queryRules)){
				// !!! important !!! 
				queryUrl = info.queryUrl;
				queryRules = info.queryRules;
				totalRecord = null;
				// !!! important !!!
				
				totalPage = 0;
				totalRecord = 0;
				nowPage = 0;
				
				records = null;
				pervious_records = null;
				next_records = null;
				
				thisAjaxRecordFrom = 0;
				nextAjaxRecordFrom = 0;
				perviousAjaxRecordFrom = 0;
				
				ajaxRecords( isNumeric(info.thisAjaxRecordFrom) ? info.thisAjaxRecordFrom : 0 , true );
			}
		}
		
		
		this.addRecords = addRecords;
		function addRecords(){
			alert("批次查詢無法自行增加資料");
		}
		
		this.loadin = loadin;
		function loadin(ajax_url , input_rules , successFunc , failFunc){
	
			if( !input_rules || !isObject(input_rules)){ 
				clearAll();
				return; 
			}
			
			// !!! important !!! 
			queryUrl = ajax_url;
			queryRules = Object.toJSON(input_rules);
			totalRecord = null;
			// !!! important !!!
			
			successFunction = (isFunction(successFunc) ? successFunc : null);
			failFunction = (isFunction(failFunc) ? successFunc : null);
			
			
			totalPage = 0;
			totalRecord = 0;
			nowPage = 0;
			
			records = null;
			pervious_records = null;
			next_records = null;
			
			thisAjaxRecordFrom = 0;
			nextAjaxRecordFrom = 0;
			perviousAjaxRecordFrom = 0;

			ajaxRecords( 0 , true );
			
		}
		
		function updateInformation(){
			
			if(divFitControl){	divFitControl.fit(); }
			
			controlSelect.value = nowPage;
			var text = textPattern
			.replace("{nowPage}",nowPage)
			.replace("{totalPage}",totalPage)
			.replace("{totalRecord}",totalRecord);
			controlText.innerHTML = text;
			if(pageChange){ pageChange(nowPage); }
			if(window.UI_Manager){
				UI_Manager.callShareingObserve("resize" , "tableUI");
			}else if(window.fix){
				fix();
			}
			try{
				if(window.parent && window.parent.UI_Manager){
					window.parent.UI_Manager.callShareingObserve("resize");
				}
			}catch(err){
			}
		}
		
		this.loadPrevious = loadPrevious;
		function loadPrevious(){
			if(nowPage <= 1){ return; }
			nowPage -= 1;
			loadFrom(nowRecord_pervious_start);
		}
		
		this.loadNext = loadNext;
		function loadNext(){
			if(nowPage >= totalPage){ return; }
			nowPage = parseInt(nowPage) + 1;
			loadFrom(nowRecord_next_start);
		}
		
		this.loadFirst = loadFirst;
		function loadFirst(){
			if(nowPage == 1){ return; }
			nowPage = 1;
			loadFrom(0);
		}
		
		this.loadLast = loadLast;
		function loadLast(){
			if(nowPage >= totalPage){ return; }
			loadFrom((totalPage-1)*pageSize);
			nowPage = totalPage;
			updateInformation();
		}
		
		this.reLoadin = reloadPage;
		function reloadPage(){
			ajaxRecords( 0 , true );
		}
		
		this.loadPage = loadPage;
		function loadPage(pageNO){
			if(!isNumeric(pageNO)){ return; }
			if(pageNO<1){
				loadFirst();
			}else if(pageNO>totalPage){
				loadLast();
			}else{
				nowPage = pageNO;
				loadFrom((pageNO-1)*pageSize);
			}
		}
		
		this.loadAgain = loadAgain;
		this.reloadPage = loadAgain;
		function loadAgain(){
			ajaxRecords((nowPage-1)*pageSize , true );
		}
		
		function loadFrom(start){
			if(!isNumeric(start) || !records || !records.length){
				return;
			}
			start = parseInt(start);
			if( start >= totalRecord){
				loadLast();
				return;
			}
			if( start < 0 ){
				loadFirst();
				return;
			}
			
			if( pervious_records && start >= perviousAjaxRecordFrom  && start < thisAjaxRecordFrom ){
				next_records = records;
				records = pervious_records;
				pervious_records = null;
			}else if( next_records && start >= nextAjaxRecordFrom  && start < ( nextAjaxRecordFrom + recordNumOfFatch ) ){
				pervious_records = records;
				records = next_records;
				next_records = null;
			}else if( !( start >= thisAjaxRecordFrom  && start < nextAjaxRecordFrom) ){
				ajaxRecords(start , false);
				return;
			}	
			
			updateAjaxFromInfo(start , true);
			
			dataControl.clearAll();
			
			if(!records){
				return;
			}
			
			var end = start+ pageSize;
			if(end > totalRecord ){
				end = totalRecord+1;
			}
			var load_Records = records.slice((start-thisAjaxRecordFrom),(end-thisAjaxRecordFrom));
			
			for(var rwg_count = 0 ; rwg_count < load_Records.length ; rwg_count+=1 ){
				dataControl.createRecordsBody( load_Records[rwg_count] );
			}
			
			 updateInformation();
			
			nowRecord_pervious_start = start<pageSize?0:start-pageSize;
			nowRecord_next_start = end;
		}
		
		function updateAjaxFromInfo(start , noMoveRecords ){
			
			var new_ajax_from = recordNumOfFatch * (Math.floor(start / recordNumOfFatch));
			
			nextAjaxRecordFrom = new_ajax_from + recordNumOfFatch;
			if(totalRecord && nextAjaxRecordFrom > totalRecord){
				nextAjaxRecordFrom = totalRecord;
			}
			perviousAjaxRecordFrom = new_ajax_from - recordNumOfFatch;
			if(perviousAjaxRecordFrom < 0 ){
				perviousAjaxRecordFrom = 0;
			}
			
			if( !noMoveRecords && records ){
				if( thisAjaxRecordFrom == perviousAjaxRecordFrom ){
					pervious_records = records;
					next_records = null;
				}else if(thisAjaxRecordFrom == nextAjaxRecordFrom ){
					next_records = records;
					pervious_records = null;
				}else{
					next_records = null;
					pervious_records = null;
				}
			}
			
			thisAjaxRecordFrom = new_ajax_from;
		}
		
		function clearAll(){
			
			// !!! important !!! 
			totalRecord = null;
			queryUrl=null;
			queryRules =null;
			// !!! important !!!
			
			totalPage = 0;
			totalRecord = 0;
			nowPage = 0;
			
			records = null;
			pervious_records = null;
			next_records = null;
			
			thisAjaxRecordFrom = 0;
			nextAjaxRecordFrom = 0;
			perviousAjaxRecordFrom = 0;
			
			updateSelectOptions(false);
			updateInformation();
			dataControl.clearAll();
		}
		
		function ajaxRecords(start , noCheckRecordIsExist ){
			
			if(!(isString(queryUrl))){ 
				updateSelectOptions(false);
				return; 
			}
			
			updateAjaxFromInfo(start , false);
			
			var isFirstQuery = (!totalRecord);
			
			
			new Ajax.Request(queryUrl, { 
					parameters: { 
						param:queryRules
						,loadStrat:thisAjaxRecordFrom+1
						,loadEnd:nextAjaxRecordFrom
						,isFirstQuery:(isFirstQuery?"Y":"N") 
					} 
					,onSuccess: function(XHT, resp){
						if(CSRUtil.isSuccess(resp)){
							
							var totalOfRecords = parseInt(resp.totalOfRecords);
							var rtnRecords = resp.records;
							
							if(!rtnRecords || !isArray(rtnRecords) || !rtnRecords.length){
								alert("無法讀取資料，因為找不到回傳的[records]值,該值可能沒有設定或是長度為零。");
								if(!totalRecord){
									clearAll();
									if(isFirstQuery && failFunction){
										failFunction();
									}
								}
								return;
							}
							
							records = rtnRecords;
							dataControl.setSerialNnmber(records , thisAjaxRecordFrom);
							
							if(isFirstQuery){
								//代表為第一次查詢，要更新訊息
								if(!isNumeric(totalOfRecords)){
									alert("無法讀取資料，因為缺少必要回傳值[totalOfRecords]");
									clearAll();
									if(failFunction){
										failFunction();
									}
									return;
								}
								updateSelectOptions( totalOfRecords );
								nowPage = Math.floor(start / pageSize)+1;
								loadFrom(start);
								if(afterLoad){ afterLoad(main_table); }
								
							}else{
								nowPage = Math.floor(start / pageSize)+1;
								loadFrom(start);
							}
							
							if(isFirstQuery && successFunction){
								successFunction();
							}
							
						}else{
							clearAll();
							if(isFirstQuery && failFunction){
								failFunction();
							}
						}
					}
				}
			);
		}
		
		function updateSelectOptions( newTotalRecord ){
			if( newTotalRecord === false || newTotalRecord != totalRecord){
				while(controlSelect.hasChildNodes()){
					controlSelect.removeChild(controlSelect.firstChild);
				}
				if(newTotalRecord){
					totalRecord = newTotalRecord;
					totalPage = Math.ceil(totalRecord/(pageSize+0.0));
					for(var select_count = 1 ; select_count<=totalPage ; select_count+=1){
						createDOM("OPTION", {value:select_count},null,null,null,controlSelect,"&nbsp;-&nbsp;"+select_count+"&nbsp;-&nbsp;");
					}
				}else{
					totalRecord = 0;
					totalPage = 0;
				}
			}
		}
		
		this.hasRecoeds = function(){ return records && records.length > 0;	};
		
		//取得資料
		this.getAllRecords = getAllRecords;
		function getAllRecords( template ){
			if(window.tableUI_getFatchRecords === true){
				if(template){
					return dataControl.getRecordsByTemplate( records || [] , template );
				}else{
					return records || [];
				}
			}
			alert("批次查詢無法取得全部資料");
			return [];
		}
		
		this.getCheckedRecords = getCheckedRecords;
		function getCheckedRecords( template ){
			return [];
		}
		
		this.getRecordsBy = getRecordsBy;
		function getRecordsBy( getTemplate , recordTemplate ){
			if( !getTemplate ){
				return [];
			}
			getTemplate = getTemplate.split(",");
			var rtnList = [];
			var notInRangeRecNo = [];
			for(var i = 0  ; i < getTemplate ; i+=1 ){
				var recNo = getTemplate[i];
				if(isNumeric(recNo) && recNo >= 0  && recNo < records.length){
					if(recNo >= thisAjaxRecordFrom && recNo < nextAjaxRecordFrom)
					{
						rtnList.push(records[recNo-thisAjaxRecordFrom]);
					}else{
						notInRangeRecNo.push(recNo);
					}
				}
			}
			if(notInRangeRecNo.length != 0 ){
				alert("以下資料無法取得，因為該資料已無暫存\n"+Object.toJSON(notInRangeRecNo));
			}
			return  dataControl.getRecordsByTemplate( rtnList , recordTemplate );
		}
		
		
	}
	
	//外框控制項 functions
	function divFitControl_impl() {
	    var pageContent;
	    var isIFrame = false;
	    if (window.parent != window) {
	        try {
	            isIFrame = false;
	            pageContent = window.parent.document;
	            var iframes = pageContent.getElementsByTagName("IFRAME");
	            for (var i = 0 ; i < iframes.length ; i += 1) {
	                if (iframes[i].contentWindow == window) {
	                    pageContent = iframes[i];
	                    isIFrame = true;
	                    break;
	                }
	            }
	            if (!isIFrame) {
	                throw "iframe not found!";
	            }
	        } catch (err) {
	            alert(err);
	            isIFrame = false;
	            pageContent = window;
	        }
	    } else {
	        isIFrame = false;
	        pageContent = window;
	    }

		var fitTarget = '';
	    var fitAgain = false;
		this.fit = fit;
	    function fit( caller , wait_time ) {
			//console.log("resize");
			if(!main_div || !main_div.offsetHeight){ return; }
			
			if(!main_div.parentNode){ return true;  } //刪除resize註測
			
			if(fitTarget){
				if(fitAgain){
					if(caller){
						return;
					}
					caller = 'again';
				}else if(caller){
					if(fitAgain === null && caller !='I' && fitTarget == 'I' ){
						fitAgain = true; 
						//console.log("[TableUI - fit] set agein caller: " + caller );
					}
					return;
				}else{
					return;
				}
			}
			
			//console.log("[TableUI - fit] org caller: " + fitTarget + " / now Caller : "+ (caller || 'callByUI') + " # again:"+fitAgain);
			
			fitTarget = caller || 'callByUI';
			
			//現在是否有固定欄位
			var hasFixed = settingCtrl.settings.has_fixed;
			
			//縮起固定欄位部分
			if(hasFixed) {
	            fixedDataArea.style.display = "";
	            fixedDataArea.style.width = '1px';
	            fixedDataArea.style.overflowX = 'hidden';
	        }else{
				fixedDataArea.style.display = "none";
			}
			
			//縮起普通欄位部分
			displayDataArea.style.width = '1px';
	        displayDataArea.style.overflowX = 'hidden';
			
			if(isNumeric(wait_time) && wait_time > 0){			
				setTimeout(fit_next,wait_time);
			}else{
				fit_next();
			}
			
		}
		
		function fit_next(){
			var hasFixed = fixedDataArea.style.display != "none";
			
			//將資料高度整理完成
			if(dataControl){ dataControl.compareAllTableCellHeight(); }

			var maxAreaWidth = main_div.offsetWidth-2;
			if(!maxAreaWidth || maxAreaWidth < 0 ){
				setTimeout(fit_next,500);
				//console.log("[tableUi] resize錯誤，無法取得dataArea寬度 0.5秒後重取");
				return;
			}
			
			var mainAreaWidth = main_table.offsetWidth;
			var fixedAreaWidth = hasFixed ? ( fixed_table.offsetWidth) : 0;
			//console.log("[TableUI - fit] 可用空間 : "+ maxAreaWidth +" ### 固定空間 : "+ fixedAreaWidth+" + 資料空間 : "+mainAreaWidth+" = "+(fixedAreaWidth+mainAreaWidth));
			
			if (hasFixed) {
				maxAreaWidth = maxAreaWidth - 2;
				//console.log("[TableUI - fit] 可用空間 : "+ maxAreaWidth );
				if ((fixedAreaWidth + mainAreaWidth) <= maxAreaWidth) {
					
					displayDataArea.style.overflowX = 'visible';
					displayDataArea.style.width = (maxAreaWidth - fixedAreaWidth) + "px";
					fixedDataArea.style.overflowX = 'visible';
					fixedDataArea.style.width = fixedAreaWidth + 'px';
					
				} else {
					var helfPageSize = maxAreaWidth / 2;
					var helfPageSize_f = Math.ceil(helfPageSize);
					var helfPageSize_d = Math.floor(helfPageSize);
					
					if (fixedAreaWidth < helfPageSize_f ) {
						
						displayDataArea.style.overflowX = 'scroll';
						displayDataArea.style.width = (maxAreaWidth - fixedAreaWidth) + "px";
						fixedDataArea.style.overflowX = 'visible';
						fixedDataArea.style.width = fixedAreaWidth + 'px';
						
					} else if (mainAreaWidth < mainAreaWidth ) {
						displayDataArea.style.overflowX = 'visible';
						displayDataArea.style.width = mainAreaWidth + "px";
						fixedDataArea.style.overflowX = 'scroll';
						fixedDataArea.style.width = (maxAreaWidth - mainAreaWidth) + 'px';
					} else {
						displayDataArea.style.overflowX = 'scroll';
						displayDataArea.style.width = mainAreaWidth + "px";
						fixedDataArea.style.overflowX = 'scroll';
						fixedDataArea.style.width = fixedAreaWidth + 'px';
					}
				}
				addClassName(dataArea,'hasFixed');
			} else {
				fixedDataArea.style.display = "none";
				displayDataArea.style.width = maxAreaWidth + "px";
				if (maxAreaWidth > mainAreaWidth) {
					displayDataArea.style.overflowX = 'visible';
				}else{
					displayDataArea.style.overflowX = 'scroll';
				}
				removeClassName(dataArea,'hasFixed');
			}
			
			//console.log("[TableUI - fit] 可用空間 : "+ maxAreaWidth +" ### 固定空間 : "+ fixedDataArea.style.width+" + 資料空間 : "+displayDataArea.style.width);
			
			if(fitAgain === true ){
				fitAgain = false;
				setTimeout( fit , 500);
				return;
			}else if( fitAgain === false){
				fitAgain = null;
			}			
			fitTarget = null;
		}
		
		function setTablesWidth( fixedAreaWidth , mainAreaWidth , pageWidth ){
			
			
		}
	}
	
	
    	
    //utilitys 
	
	function setValueIfEmpty(obj,key,value){
		if(!key || !value || !isObject(obj)){ return; }
		if(!obj[key]){ obj[key] = value; }
	}
	
	function getOptions( type, valueObj ,optionKey ,optionValue ,elemAttrs, elemStyles, elemClasses, elemActions, defaultValue ){
		if(!type){return;}
		type = type.toLowerCase();
		if( type!="checkbox" && type!="radio" && type!="option"){ return;}  
		var objIsArray = isArray(valueObj);
		var valueIsFunction = isFunction(optionValue);
		if( !objIsArray && !isObject(valueObj) ){
			return;
		}else if(objIsArray &&  !isBasicType(optionKey) && !( isBasicType(optionValue) && valueIsFunction ) ){
			return;
		}	
		if(!isObject(elemAttrs)){
			elemAttrs = {};
		}
		var tagName;
		var isSelection = false;
		if(type=="option"){
			tagName = type;
			isSelection = true;
		}else{
			tagName = "input";
			elemAttrs.type = type;
		}
		var isCheckbox = !isSelection && type=="checkbox";
		
		if(isCheckbox && defaultValue){
			defaultValue = defaultValue.split(",");
		}
		
		var fragment = document.createDocumentFragment();
		if(objIsArray){
			for(var i = 0 ; i < valueObj.length ; i +=1 ){
				var objData = valueObj[i];
				var key = objData[optionKey];
				var value;
				if(valueIsFunction){
					value = optionValue(key,objData);
				}else{
					value = objData[optionValue];
				}
				
				elemAttrs.value = key;
				elemAttrs["selected"] = null;
				elemAttrs["shouldBeChecked"] = null;
				if(!isCheckbox){
					if(defaultValue == key){
						elemAttrs[(isSelection?"selected" :"shouldBeChecked")] = "1";
					}
				}else if(defaultValue){
					elemAttrs["shouldBeChecked"] = null;
					for(var x = 0 ; x < defaultValue.length ; x += 1){
						if(defaultValue[x] == key){
							elemAttrs["shouldBeChecked"] = "1";
						}
					}
				}
				
				var option = createDOM(tagName,elemAttrs,elemStyles,elemClasses,elemActions);
				var value_text = document.createTextNode(value);
				if(isSelection){
					fragment.appendChild(option);
					option.appendChild(value_text);
				}else{
					var label = createDOM("label");
					fragment.appendChild(label);
					label.appendChild(option);
					label.appendChild(value_text);
				}
			}
		}else{
			var k_v_exchange = (optionKey === true);
			for(key in valueObj){
				var value;
				if(k_v_exchange){
					value = key;
					key = valueObj[value];
				}else{
					value = valueObj[key];
				}
				if(valueIsFunction){
					value = optionValue(key,value);
				}
				
				elemAttrs.value = key;
				elemAttrs["selected"] = null;
				elemAttrs["shouldBeChecked"] = null;
				if(!isCheckbox){
					if(defaultValue == key){
						elemAttrs[(isSelection?"selected" :"shouldBeChecked")] = "1";
					}
				}else if(defaultValue){
					for(var x = 0 ; x < defaultValue.length ; x += 1){
						if(defaultValue[x] == key){
							elemAttrs["shouldBeChecked"] = "1";
						}
					}
				}

				var option = createDOM(tagName,elemAttrs,elemStyles,elemClasses,elemActions);
				var value_text = document.createTextNode(value);
				if(isSelection){
					fragment.appendChild(option);
					option.appendChild(value_text);
				}else{
					var label = createDOM("label");
					fragment.appendChild(label);
					label.appendChild(option);
					label.appendChild(value_text);
				}
			}
		}
		return fragment;
	}
	function getOptionValues(target){
		var rtnValue = "";
		var test_opts = target.getElementsByTagName("input");
		for(var i = 0 ; i < test_opts.length ; i++ ){
			var test_opt = test_opts[i];
			if( ( test_opt.checked || test_opt.getAttribute("shouldBeChecked")) ){
				rtnValue = rtnValue + test_opt.getAttribute("value") + ",";
			}
		}
		return rtnValue.substring(0,rtnValue.length-1);
	}
	
	function getOptionDisplay(target , value){
		if(target.tagName=="SELECT"){
			var test_opt = target.firstChild;
			while(test_opt){
				if(test_opt.tagName == "OPTION" && test_opt.value == value){
					return test_opt.textContent;
				}
				test_opt = test_opt.nextSibling;
			}
			return "";
		}else{
			var rtnValue = "";
			var test_opts = target.getElementsByTagName("input");
			for(var i = 0 ; i < test_opts.length ; i++ ){
				var test_opt = test_opts[i];
				if( ( test_opt.checked || test_opt.getAttribute("shouldBeChecked")) ){
						rtnValue = rtnValue + test_opt.nextSibling.textContent + ",";
					}
				}
			return rtnValue.substring(0,rtnValue.length-1);
		}
		
	}
	
	function ExchangeToShortText(input , length ){
		if(!input){return "..."; }
		var content = input.split("\n")[0];
		if( isNumeric(length) ){
			var byteCount = 0;
			var charCount = 0;
			for(var i=0;i<content.length;i++ ){
				content.charCodeAt(i)<256?byteCount++:byteCount+=2;
				if(byteCount>length){//最後為中文，且超出應顯示字數
					break;
				}else if(byteCount==length){
					charCount++;
					break;
				}else{
					charCount++;
				}
			}
			return content.substr(0, charCount)+"...";	
		}else{
			return content+"...";
		}	 
	}

	function getContent(testNode, whenNULL, function_params, function_input_params_part) {

	    if (isDOMObject(testNode, true)) {
			return testNode;
	    }

		if(isFunction(testNode)){
			if(function_params){
				if( function_input_params_part && isArray(function_params) ){
					testNode = testNode(function_params[0],function_params[1],function_params[2],function_params[3],function_params[4],function_params[5]);
				}else{
					testNode = testNode(function_params);
				}
			}else{
				testNode = testNode();
			}
		}
		if (!isDOMObject(testNode,true)) {
            if(!isBasicType(testNode)){
				testNode = isBasicType(whenNULL) ? whenNULL : "&nbsp;" ;
			}
			var frag = createDOM("span");
			frag.innerHTML = testNode;
			testNode = document.createDocumentFragment();
			while(frag.hasChildNodes()){
				testNode.appendChild(frag.firstChild);
			}
		}
		return testNode;
	}
	
	function getEventTarget(e){
		if (!e) e = window.event;
		var target = e.target || e.srcElement;
		if(isDOMObject(target)){
			return target;
		}
		if(isDOMObject(e)){
			return e;
		}
		return false;
	}
	
	function getParentByTagName( node , tagName ){
		if(!isDOMObject(node) || !isBasicType(tagName)){return null;}
		tagName = tagName.toUpperCase();
		do{
			node = node.parentNode;
			if( !node||node.tagName == "BODY"){return null;}
		}while(node.tagName!=tagName);
		return node;
	}
	
	function setEventObserve( elem , eventName , func){
		if( !(isDOMObject(elem) || elem==window || elem==document )  || !isString(eventName) || !isFunction(func) ){ return; }
		if(Event.observe){
			Event.observe(elem,eventName,func)
		}else if(elem.removeEventListener) {						//DOM2接口 with bubble
			elem.addEventListener(eventName, func, false);  
		} else if(elem.detachEvent) {					//IE DOM2接口  with bubble
			elem.attachEvent('on'+eventName, func);  
		} else {											//DOM0接口 without bubble
			if( window.Prototype){
				Event.observe(elem, eventName, func);
			}else{
				elem['on'+eventName]=func; 
			}
		}
	}
	
	function stopEventObserving( elem , eventName , func  ){
		if( !(isDOMObject(elem) || elem==window || elem==document )  || !isString(eventName) ){ return; }
		if(Event.observe){
			Event.stopObserving(elem,eventName,func)
		}else if(elem.removeEventListener) {						//DOM2接口 with bubble
			elem.removeEventListener(eventName, func);  
		} else if(elem.detachEvent) {						//IE DOM2接口  with bubble
			elem.detachEvent('on'+eventName, func);
		} else {											//DOM0接口 without bubble
			if( window.Prototype){
				Event.stopObserving(elem, eventName);
			}else{
				elem['on'+eventName]=null; 
			}
		}
	}
	
	function cancelEventBubble(e){ 
		if (!e) 
		  e = window.event; 
	 
		//IE9 & Other Browsers 
		if (e.stopPropagation) { 
		  e.stopPropagation(); 
		} 
		//IE8 and Lower 
		else { 
		  e.cancelBubble = true; 
		} 
	}
	
	function isDOMObject(node, allowFragment) {
	    //nodeType == 1 --> DOM
	    //nodeType == 3 --> TextNode
	    //nodeType == 11 --> Fragment
	    return !!(node && ((node.tagName && node.nodeType === 1) || node.nodeType === 3 || (allowFragment && node.nodeType === 11)));
	}
	
	function isString( node ){
		return !!(isBasicType( node ) && getType(node) === '[object String]');
	}
	
	function isNumeric(node){ return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); } 
	
	function isBasicType( node ){
		var type = typeof(node);
		return !!( type === 'string' || type ==='number' || type === 'boolean' );
	}
	
	function isArray( node ){
		return !!(node && getType(node) === '[object Array]' && isNumeric( node.length ));
	}
	 
	function isObject(node){
		return !!(node && getType(node) == '[object Object]' && !isArray(node) && !isFunction(node) );
	}
	
	function isFunction( node ){
		return !!(node && getType(node) === '[object Function]');
	}
	
	function isInArray( array , obj) {
		if(!isArray(array)){ return -1; }
		for (var i = 0 ; i < array.length ; i++) {
			if ((""+array[i]) === (""+obj) ) { return i; }
		}
		return -1;
	}	
		
	function getType(node){
		if(typeof(node) === 'undefined' ) {return "undefined"; }
		return Object ? Object.prototype.toString.apply(node) : "";
	}
	
	function addClassName( node , className){
		if( isBasicType(className) && !hasClassName( node , className)){
			node.className = trim((node.className||"") +" "+ className);
		}
	}
	
	function getClassName( node ){
		var classes = node.className;
		if(!isBasicType(classes)) { return []; }
		classes = trim(classes.replace(/\s\s/g," "));
		return stringToArray(classes ," ");
	}
	
	function removeClassName(node , compare ){
		if(!isBasicType(compare)){ return false; }
		var classes = node.className;
		if(!isBasicType(classes)) { return false; }
		compare = compare.replace(/\\/gi,"\\\\");
		
		var reg=new RegExp("(^"+compare+"\\s)|(\\s"+compare+"\\s)|(\\s"+compare+"$)|(^"+compare+"$)","gi");
		node.className = classes.replace(reg," ").replace(/\s\s/gi," ");
	}
	
	function hasClassName(node , compare ){
		if(!isDOMObject(node) || !isBasicType(compare)){ return false; }
		var classes = node.className;
		if(!isBasicType(classes)) { return false; }
		compare = compare.replace(/\\/gi,"\\");
		
		var reg=new RegExp("(^"+compare+"\\s)|(\\s"+compare+"\\s)|(\\s"+compare+"$)|(^"+compare+"$)","gi");
		
		return classes.match(reg) != null;
	} 
	
	function stringToArray( stringValue , splitChar ){
		if(isArray(stringValue)){ return stringValue; }
		if(!isBasicType(stringValue)){ return [ trim(stringValue) ];}
		var strings = stringValue.split(splitChar);
		var rtnArray = [];
		for(var i = 0 ; i < strings.length ; i = i + 1 ){
		    var str = trim(strings[i]);
		    if (isBasicType(str) && str != "undefined") {
		        rtnArray.push(str);
		    }
		}
		return rtnArray;
	}
	
	function trim(value)
	{
	    return isString(value) ? value.replace(/(^\s*)|(\s*$)/g, "").replace(/^&nbsp;|&nbsp;$/g,"") : value; 
	}
	
	function createDOM( node , attrs , styles , classes , events , appendAt , content , createDocument ){
		
		if(!isDOMObject( node )){
			if(isString(node)){
				node = (createDocument||document).createElement(node);	
			}else{
				return;
			}
		}
		
		if( isObject(attrs) ){
			for( var key in attrs ){
				if(isBasicType(attrs[key])){
					node.setAttribute( key , attrs[key] );
				}
			}
		}
		
		if( isObject(styles) ){
			for( var key in styles ){
				if(isBasicType(styles[key])){
					node.style[key] =  styles[key];
				}
			}
		}
				
		if( isArray(classes) ){
			for( var i = 0  ; i < classes.length ; i = i + 1  ){
				addClassName( node , classes[i] );
			}
		}
		
		if( isObject(events) ){
			for( var key in events ){
				 setEventObserve( node , key , events[key] );
			}
		}
		
		if(content){
		    node.appendChild(getContent(content));
		}
		
		if(isDOMObject( appendAt , true )){
			appendAt.appendChild(node);
		}
		
		return node;
	}
	
	function createFragment(elems) {
	    var fragment = document.createDocumentFragment();
	    if (isArray(elems)) {
	        for (var i = 0 ; i < elems.length ; i = i + 1) {
	            var elem = getContent(elems[i]);
	            if (elem) {
	                fragment.appendChild(elem);
	            }
	        }
	    }
	    return fragment;
	}

	function cloneObject(orgObject) {
		var returnObject;
		if(isArray(orgObject)){
			returnObject = [];
			for(var i = 0 ; i < orgObject.length ; i = i + 1 ){
				returnObject[i]=cloneObject(orgObject[i]);
			}
		}else if(isDOMObject(orgObject)){
			returnObject = null;
		}else if(isObject(orgObject)){
			returnObject = {};
			for(var key in orgObject){
				returnObject[key]=cloneObject(orgObject[key]);
			}
		}else{
			returnObject = orgObject;
		}
		return returnObject;
	}
	
}

function getCellByTagName( node , tagName ){
	if(!(node && ((node.tagName && node.nodeType === 1) || node.nodeType === 3 || (allowFragment && node.nodeType === 11)))){ return; }
	tagName = tagName.toUpperCase();
	do{
		node = node.parentNode;
		if( !node||node.tagName == "BODY"){return null;}
	}while(node.tagName!=tagName);
	return node;
}

