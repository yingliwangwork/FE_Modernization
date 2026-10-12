var css = document.getElementsByTagName('link');
var hasCss = false;
var css_regExp = new RegExp(/TableUI\.css$/i);
for (var i = 0 ; i < css.length ; i++) {
    var cssHref = css[i].href + '';
    if (css_regExp.test(cssHref)) {
        hasCss = true;
        break;
    }
}

if(!hasCss){
    if (!window.CSS_locate_base || window.CSS_locate_base !== false) {
        window.CSS_locate_base = false;
        var css_regExp = new RegExp(/\.css$/i);
        for (var i = 0 ; i < css.length ; i++) {
            var cssHref = css[i].href + '';
            if (css_regExp.test(cssHref)) {
                var html_i = cssHref.indexOf('html');
                window.CSS_locate_base = cssHref.substring(0, html_i);
                break;
            }
        }
    } 

    if (!window.HTML_locate_base || window.HTML_locate_base !== false) {
        window.HTML_locate_base = location.href.split("servlet");
        if (HTML_locate_base.length <= 1) {
            HTML_locate_base = location.href.split("html");
        }
        if (HTML_locate_base.length > 1) {
            HTML_locate_base = HTML_locate_base[0];
        } else {
            HTML_locate_base = false;
        }
    }
    /* ¤Þ¤JCSS¨Ï¥Î */
    var css_filePath = 'html/CM/css/ui/TableUI.css';
    if (window.CSS_locate_base) {
        document.write('<link rel="stylesheet" type="text/css" href="' + CSS_locate_base + css_filePath + '" />');
    } else if (window.HTML_locate_base) {
        var PROD_CssBase = HTML_locate_base.replace(/Web\//, 'Docs/');
        document.write('<link rel="stylesheet" type="text/css" href="' + HTML_locate_base + css_filePath + '" />');
        document.write('<link rel="stylesheet" type="text/css" href="' + PROD_CssBase + css_filePath + '" />');
    }
}




/* ÂÂª©¥þ°ì¨ç¦¡ */
var divResize = function () { };

/* ¬ö¿ý¥»­¶©Ò·s¼WªºTableUI */
var _tableui_setting_maping = { length: 0 };
var _tableui_vertical_resize = null;
var _tableui_stop_resize_cover = null;
var _tableui_ask_resize_height = -1;
var _tableui_ask_times = 0;
var _tableui_lock = 0;

/* ­Y¬O¥]¦bpopupwin¤¤¡A»Ý­nÀË¬dpopupwin°ª«× */
var _tableui_popupwin_changeTopScrollHeight = false;

var _tableUI_all_ui_resizing = false;
function _tableUI_all_ui_resize() {
    if (_tableUI_all_ui_resizing) { return; }
    var now = _tableui_vertical_resize.offsetHeight;
    if (now != _tableui_ask_resize_height) {
        _tableui_ask_resize_height = now;
        _tableui_ask_times = 0;
        return;
    }
    if (_tableui_ask_times < ( _tableui_setting_maping.length + 1) ) {
        _tableui_ask_times++;
        return;
    }

    _tableUI_all_ui_resizing = true;
    _tableui_ask_resize_height = -1;

    _tableUI_globe_lock();
    for (var ui_id in _tableui_setting_maping) {
        if (ui_id == 'length') { continue; }
        _tableui_setting_maping[ui_id].resize('globeHeightChange');
    }
    _tableui_vertical_resize.setAttribute('org_width', _tableui_vertical_resize.offsetWidth);
    _tableui_vertical_resize.setAttribute('org_hight', _tableui_vertical_resize.offsetHeight);
    _tableUI_globe_unlock();
    _tableUI_all_ui_resizing = false;

}

function _tableUI_globe_lock(){
    _tableui_lock++;
}

function _tableUI_globe_unlock() {
    _tableui_lock--;
    if (_tableui_popupwin_changeTopScrollHeight && _tableui_lock == 0) {
        var org_hight = parseInt(_tableui_vertical_resize.getAttribute('org_hight')||0);
        var now_height = _tableui_vertical_resize.offsetHeight ;
        if (now_height != org_hight && now_height - org_hight != 30 )
        _tableui_popupwin_changeTopScrollHeight(Math.max(document.body.scrollHeight, document.documentElement.scrollHeight));
    }
}

/* table©w¸q¦@¦PÅÜ¼Æ */
var _tableuiScrollBarWidth = 0;
var SORT_NONE = "\u25C6";
var SORT_INCREASE = "\u25B2";
var SORT_DECREASE = "\u25BC";

function TableUI(config) {

    if (!isObject(config)) {
        alert("¿é¤Jconfig¿ù»~¡A¥²¶·¬°Object®æ¦¡");
        return;
    }

    var table = config.table;
    if (!isElement(table) && isString(table)) {
        table = document.getElementById(table);
    }
    if (!isElement(table)) {
        alert("¿é¤Jconfig¿ù»~¡AµLªk¨ú±o¥Ø¼Ðtable¡C");
        return;
    }

    var table_id = table.getAttribute("id");
    if (!table_id) {
        table_id = new Date().getTime();
    }

    /* µ²ºc¨Ï¥Îªº elements */
    var main_div = createElement("div", { 'id': table.id, 'isTableUIParent': 'Y' }, null, ["tableParent"], null);

    /* ¤wÁôÂÃÄæ¦ì¿ï³æ */
    var carry_div = createElement("div", null, null, ['hidden_column_position'], null, main_div);
    var hidden_columns_ul = createElement("ul", { id: "hidden_columns" }, null, null, null, carry_div);
    createElement("li", { id: "hidden_columns_open", title: "¥´¶}ÁôÂÃÄæ¦ì" }, null, null, { click: function (e) { addClassName(hidden_columns_ul, "open"); } }, hidden_columns_ul);
    createElement("li", { id: "hidden_columns_close", title: "Ãö³¬¿ï³æ" }, null, null, { click: function (e) { removeClassName(hidden_columns_ul, "open"); } }, hidden_columns_ul, "¤wÁôÂÃÄæ¦ì");

    /* ¸ê®ÆÅã¥Ü°Ï */
    var dataArea = createElement("div", null, null, ["childOfTableParent", "dataArea"], null, main_div);
    var fixedDataArea = createElement("div", null, null, ["childOfDataArea", "fixedDataArea"], null, dataArea);
    var displayDataArea = createElement("div", null, null, ["childOfDataArea", "displayDataArea"], {
        'scroll': function (e) {
            var target = getEventTarget(e);
            if (target.style.overflowY != 'scroll') { return; }
            var top = target.scrollTop;
            if (fixedDataArea.style.display != 'none') { 
                fixedDataArea.scrollTop = top;
            }
            sizeController.headerRePosition();
        }
    }, dataArea);

    var fixed_table = createElement("table", { name: "fixed", width: "100%", cellPadding: "0px", cellSpacing: "0px" }, null, ["tableGrid"], null, fixedDataArea);
    var main_table = createElement("table", { name: "main", width: "100%", cellPadding: "0px", cellSpacing: "0px" }, null, ["tableGrid"], null, displayDataArea);

    /* ¹w¨¾­«·s²£¥Í®É¡A³B²z±¼¤§«etableuiªºoverdiv; */
    if (table.parentNode.tagName == 'div' && createRecordame(table.parentNode, 'tableParent')) {
        table.parentNode.parentNode.replaceChild(main_div, table.parentNode);
    } else {
        table.parentNode.replaceChild(main_div, table);
    }

    /* ÂÐ¼g¿é¤J¤¸¯À ¬°²{¦bUIªº¥À¤¸¯À */
    config.table = main_div;

    /* !!!! quircks for old !!!! */
    main_div.parentNode.resetDivHeight = function () { };
    /* !!!! quircks for old !!!! */

    /* tableUIÀË®Ö¸ê®Æ null=¤£ÀË®Ö, true=allRecords, false=check only*/
    var validate_type = null;

    /* ¥u°w¹ïIEþ§@¥Î¡A¦Ó¥B¦Ò¼{IE¥Î¤á¦Û¿ï¤å¥ó¼Ò¦¡¡BQuirks¼Ò¦¡¡B¤ä´©IE5¡B6¡B7¡B8¡B9¤Î10¤§§PÂ_¡C*/
    var ie_ver = false;
    /*@cc_on ie_ver = ((document.documentMode||( document.compatMode == "CSS1Compat" ? "XMLHttpRequest" in window ? @_jscript_version*10-50 : 6 : 5)))  @*/
    //isLessThenIE8 = false;

    /* ¬O§_¤Þ¤Jprototype */
    var hasPrototype = !!window.Prototype;
    var hasjQuery = !!window.jQuery;

    var hasJsFramework = hasPrototype || hasjQuery;

    /* ¬O§_¤Þ¤JlocaleDisplay */
    var hasLocaleDisplay = hasPrototype && !!window.localeDisplay;

    //¬O§_¤Þ¤Jpopupwin
    if (!_tableui_popupwin_changeTopScrollHeight) {
        try {
            _tableui_popupwin_changeTopScrollHeight = window.parent && window.parent.popupWin && window.parent.popupWin.changeTopScrollHeight;
            if (!_tableui_popupwin_changeTopScrollHeight || !isFunction(_tableui_popupwin_changeTopScrollHeight)) {
                _tableui_popupwin_changeTopScrollHeight = false;
            }
        } catch (exception) {
            window.console && console.log(exception);
            _tableui_popupwin_changeTopScrollHeight = false;
        }
    }

    /* ¬O§_¦³Cover­n¼È°±resize */
    if (window.CSRUtil && !_tableui_stop_resize_cover) {
        _tableui_stop_resize_cover = CSRUtil.createCoverPage({ 'id': '_frontCover' });
    }

    /* --------------------------«Ø¥ß¹êÅé-------------------------- */
    /* ³B²z¿é¤J°Ñ¼Æ */
    var settingCtrl = new setting_impl();

    /* ²£¥Ítitle¤Î±±¨î¶µ */
    var pageControl = settingCtrl.settings.isFatchMode ? (new pageControlFatch_impl()) : new pageControl_impl();

    /* ²£¥Í¥~®Ø±±¨î¶µ */
    var sizeController = new sizeController_impl();

    /* ²£¥Í¸ê®Æ±±¨î¶µ */
    var dataControl = new dataControl_impl();

    /* ¥~³¡§PÂ_ tag  */
    this.isNew = true;

    /* ¥~³¡¨ú±o¥Dª«¥ó  */
    this.getElement = main_div;

    /* ´£¨Ñªºfunctions */
    this.pageCtrl = pageControl;
    this.load = pageControl.loadin;
    this.loadin = pageControl.loadin;
    this.reload = pageControl.loadAgain;
    this.reloadin = pageControl.loadAgain;
    this.clear = pageControl.clearData;
    
    /* table info*/
    this.getTableInfo = dataControl.getTableInfo;
    this.setTableInfo = dataControl.setTableInfo;
    
    /* total datas */
    this.resetTotalCount = pageControl.resetTotalCount || (function () { });
    this.resetSubTotalCount = pageControl.resetSubTotalCount || (function () { });
    this.getTotalCount = pageControl.getTotalCount || (function () { });
    this.getSubTotalCount = pageControl.getSubTotalCount || (function () { });

    /* sort */
    this.sort = dataControl.sort;

    /* get serial number */
    this.getSerialNumber = dataControl.getSerialNumber;
    this.getSerialNumbers = dataControl.getSerialNumbers;

    /* get Records */
    this.getRecordsBySerialNo = pageControl.getRecordsBy;
    this.getRecordsByCell = dataControl.getRecordsByCell;
    this.getRecordByCell = dataControl.getRecordByCell;
    this.getDataObjs = dataControl.getRecordsByCell;
    this.getDataObj = dataControl.getRecordByCell;
    this.hasRecords = pageControl.hasRecords;
    this.addRecords = pageControl.addRecords;
    this.deleteRecords = pageControl.deleteRecords;
    this.getAllRecords = pageControl.getAllRecords;
    this.getDeletedRecords = pageControl.getDeletedRecords;
    this.getCurrentPageRecords = pageControl.getCurrentPageRecords;
    this.getCheckedRecord = pageControl.getCheckedRecords;
    this.getCheckedRecords = pageControl.getCheckedRecords;
    this.getUncheckedRecords = pageControl.getUncheckedRecords;
    this.getErrorRecords = pageControl.getErrorRecords;
    this.getCorrectRecords = pageControl.getCorrectRecords;
    this.getCheckedErrorRecords = pageControl.getCheckedErrorRecords;
    this.getCheckedCorrectRecords = pageControl.getCheckedCorrectRecords;

    /* set validate*/
    this.setValidRecord = pageControl.setValidRecord || (function () { });
    this.setValidRecordByRecord = pageControl.setValidRecordByRecord || (function () { });
    this.resetValidate = pageControl.resetValidate;
    this.validTable = pageControl.validTable || (function () { });
    this.validCheckedOnTable = pageControl.validCheckedOnTable || (function () { });

    /* auto checkbox function */
    this.checkAll = dataControl.autoCheckBoxSelectAll;
    this.setCurrentPageAutoCheckBox = dataControl.setCurrentPageAutoCheckBox;
    this.isAutoCheckBoxSelected = dataControl.isAutoCheckBoxSelected;
    this.setThisAutoCheckBox = dataControl.setThisAutoCheckBox;
    this.setAutoCheckBox = dataControl.setAutoCheckBoxByValue;
    this.setAnotherCheckBox = dataControl.setAutoCheckBoxByValue;
    this.showAutoCheckBox = dataControl.showAutoCheckBox;
    this.hideAutoCheckBox = dataControl.hideAutoCheckBox;
    
    /* cell control function */
    this.getThisRecordTD = dataControl.getThisRecordTD;
    this.setValueToTD = dataControl.setValueToTD;

    /* auto input function */
    this.getAutoInput = dataControl.getAutoInput;
    this.disableAutoInput = dataControl.disableAutoInput;
    this.exchangeAutoInput = dataControl.exchangeAutoInput;
    this.setValueToAutoInput = dataControl.setValueToAutoInput;
    this.isAutoInputHidden = dataControl.isAutoInputHidden;

    /* excel export*/
    this.getXlsSettingJSON = settingCtrl.getXlsSettingJSON;
    this.exportToXLS = dataControl.exportToXLS;
    this.exportAllToXLS = pageControl.exportAllToXLS;
    this.exportCheckToXLS = pageControl.exportCheckToXLS;

    /* resize */
    this.resize = sizeController.doResize;
    this.resetDiv = sizeController.doResize;
    this.resetDivHeight = sizeController.doResize;

    /* ui controls */
    this.hide = function () { main_div.style.display = 'none'; };
    this.show = function () { main_div.style.display = ''; sizeController.doResize('show'); };
    this.scrollTop = sizeController.scrollTop;
    this.scrollBottom = sizeController.scrollBottom;

    //_tableui_settings.push(this);
    _tableui_setting_maping[table_id] = this;
    _tableui_setting_maping['length']++;

    /* ¨ú±oÂsÄý¾¹¤§¨÷¶b¼e«× */
    if (!_tableuiScrollBarWidth) {
        displayDataArea.style.height = '';
        displayDataArea.style.overflowY = 'visible';
        displayDataArea.style.overflowX = 'scroll';
        var table_height = main_table.offsetHeight;
        var div_height = displayDataArea.offsetHeight;
        _tableuiScrollBarWidth = div_height - table_height;
        //alert(table_height + "/" + div_height + "/" + _tableuiScrollBarWidth);
    }

    /* °»´ú­¶­±¤j¤pÅÜ°Ê  */
    if ( !_tableui_vertical_resize) {
        _tableui_vertical_resize = createElement('DIV'
			, { id: '_tableUI-vertical-resize-detection' }
			, null
			, ['tableUI-resize-detection', 'vertical']
			, null
			, document.body
		);

    }


   
    /* --------------------------  ¤º³¡  -------------------------- */
    /* ³B²z³]©wÀÉ */
    function setting_impl() {

        /*  ¤U­±¨â­Ó°Ñ¼Æ¬O«÷¿ù¦r¡A­×¥¿¦¨¥¿½Tªº */
        if (config.hiddenColmuns !== undefined && config.hiddenColumns === undefined) {
            config.hiddenColumns = config.hiddenColmuns;
        }
        if (config.fixedColmuns !== undefined && config.fixedColumns === undefined) {
            config.fixedColumns = config.fixedColmuns;
        }

        var settings = {};
        this.settings = settings;

        /* ¨Ñ­¶­±¸ê®Æ²£¥ÍªºÅÜ¼Æ */
        var fixedColumns = [];
        var hiddenColumns = [];
        var hidden_headerSetting;
        var main_headerSetting;
        var main_recordSetting;
        var fixed_headerSetting;
        var fixed_recordSetting;

        /* §PÂ_¬O§_¤À­¶¬d¸ß */
        var isFatchMode = !(!isNumeric(config.isLoadByFatch) && config.isLoadByFatch !== true);
        var isPrintMode = getBoolean(config.printMode, false);
        var overDiv = config.overDiv;
        /* §PÂ_¬O§_¬°¦C¦L¼Ò¦¡ */
         if (isPrintMode) {
             if (isFatchMode){
                 alert("¦C¦L¼Ò¦¡¤U¡A¤£±o¨Ï¥Î¯u¤À­¶¬d¸ß¡A²{¦b²£¥Í±N·|°±¤î¨Ï¥Î¯u¤À­¶¼Ò¦¡ ");
                 isFatchMode = false; 
             }
             addClassName(main_div, 'simple_mode');
             config.pageSize = 0;
            overDiv = false;
        }
        /* §PÂ_overdivª¬ªp */
         if (overDiv === false) {
             config.fixedColumns = false;
         } else if (!isObject(overDiv)) {
             overDiv = true;
         }
        settings.isFatchMode = isFatchMode;
        settings.isPrintMode = isPrintMode;
        settings.overDiv = overDiv;
        /* Settings for generate the DOMs */
        var needHeader = getBoolean(config.needHeader, true);
        if (!needHeader) {
            addClassName(dataArea, 'no-header');
        }
        var hasHeaderColumns = isArray(config.headerColumn);
        var headSetting = hasHeaderColumns ? settingToArrayArray(config.headerColumn) : settingToArrayArray(config.column, config.split);
        var recordSetting = settingToArrayArray(config.column, config.split);
        
        if (!recordSetting || !headSetting) { throw "TableUIªì©l¤Æ¿ù»~"; }

        /* «Ø¥ßautoCheckBox */
        createAutoCheckBox(config, headSetting, recordSetting);
        
        /* ¹ïHeader³]©w½Õ¾ã */
        headSetting = createHeaderSetting(fullMatrixSetting(headSetting), getBoolean(config.allSortable, true));
        /* ¹ïrecord³]©w½Õ¾ã */
        recordSetting = createRecordSetting(fullMatrixSetting(recordSetting));
        
        /* ¨ú±o¨Ã­«·s³]©wgroups  */
        getGroupKeys(recordSetting);

        /* ³]©w¸s²Õ½s¸¹ */
        settingFixedGroup(headSetting, recordSetting);

        createTitle(config);

        reCreateSettings();

        /* «Ø¥ß¼ÐÀY¦C³]©wÀÉ(¤g¶À¦â°Ï°ì) */
        function createTitle(config) {
            if (config.title) {
                var isTitleSetting = isObject(config.title);
                var title = getElement(isTitleSetting ? config.title.text : config.title);
                if (trim(title)) {
                    var headClass = stringToArray("childOfTableParent,tableTitle," + (config.headClass || (isTitleSetting ? config.title.className : "")), ",");
                    var headStyle = isTitleSetting ? isObject(config.title.styles) ? config.title.styles : {} : {};
                    headStyle.whiteSpace = "nowrap";

                    var headAttrs = isTitleSetting ? isObject(config.title.attrs) ? config.title.attrs : {} : {};
                    headAttrs.name = "tableTitle";

                    var temp_titleElem = createElement("div", headAttrs, headStyle, headClass, null, null, title);
                    main_div.insertBefore(temp_titleElem, dataArea);
                }
            }
        }

        /* ¹ïHeader³]©w½Õ¾ã */
        function createHeaderSetting(matrix_setting, isAllSortable) {
            //return matrix_setting;
            var rtn_setting = [];
            for (var i = 0 ; i < matrix_setting.length ; i += 1) {
                var matrix_line = matrix_setting[i];
                var rtn_setting_line = [];
                for (var j = 0 ; j < matrix_line.length ; j += 1) {
                    var matrix_node = matrix_line[j];

                    if (isString(matrix_node) || isFunction(matrix_node) || isElement(matrix_node)) {
                        rtn_setting_line.push({
                            header: matrix_node
                        });
                    } else if (isObject(matrix_node)) {
                        /**   !!!important!!!  **/
                        var isSort = (!settings.isFatchMode) && (matrix_node.empty === undefined) ? (matrix_node.sortable !== undefined ? getBoolean(matrix_node.sortable, true) : getBoolean(isAllSortable, true)) : false;

                        var newSortRule = isBasicType(matrix_node.sortRule) ? (matrix_node.sortRule) : null;
                        newSortRule = ((newSortRule + '') || 'string').toLowerCase();

                        if (newSortRule == 'string' && isObject(matrix_node.input)) {
                            var inputType = (matrix_node.input.type || '').toLowerCase();
                            if (inputType == 'number' || inputType == 'date' || inputType == 'rocdate') {
                                newSortRule = inputType;
                                if (hasLocaleDisplay && inputType == 'rocdate') {
                                    newSortRule = 'date';
                                }
                            }
                        }

                        var setting_obj = {
                            'header': matrix_node.header,
                            'key':matrix_node.key,
                            'sortKey': isSort ? (matrix_node.sortKey || matrix_node.key) : '',
                            'sortRule': newSortRule,
                            'attrs': cloneObject(matrix_node.attrs),
                            'colGroup': matrix_node.colGroup,
                            'fixedColumn': (settings.overDiv !== false ? (matrix_node.fixedColumns !== undefined) ? getBoolean(matrix_node.fixedColumn, true) : getBoolean(config.fixedColumns, true) : false),
                            'hiddenColumn': (matrix_node.hiddenColumn !== undefined) ? getBoolean(matrix_node.hiddenColumn, true) : getBoolean(config.hiddenColumns, true)
                        };
                        setting_obj.attrs.name = matrix_node.key;
                        setting_obj.attrs.width = null;
                        setting_obj.attrs.height = null;
                        rtn_setting_line.push(setting_obj);
                    } else {
                        rtn_setting_line.push(null);
                    }
                }
                rtn_setting.push(rtn_setting_line);
            }
            rtn_setting = removeBlankLine(rtn_setting)
            /* ±N³]©w¿é¥X */
            settings.headSetting = rtn_setting;
            return rtn_setting;
        }

        /* ¹ïrecord³]©w½Õ¾ã */
        function createRecordSetting(matrix_setting) {
            var rtn_setting = [];
            for (var i = 0 ; i < matrix_setting.length ; i += 1) {
                var matrix_line = matrix_setting[i];
                var rtn_setting_line = [];
                for (var j = 0 ; j < matrix_line.length ; j += 1) {
                    var matrix_node = matrix_line[j];
                    if (isObject(matrix_node)) {
                        /**   !!!important!!!  **/
                        var newDataType = isBasicType(matrix_node.sortRule) ? (matrix_node.sortRule) : null;
                        var newDataType = (newDataType || 'string').toLowerCase();

                        var newAttrs = isObject(matrix_node.attrs) ? cloneObject(matrix_node.attrs) : {};
                        newAttrs.height = null;

                        var newPattern = newAttrs.pattern;

                        if (!newPattern && matrix_node.pattern) {
                            newPattern = matrix_node.pattern;
                        }

                        if (isObject(matrix_node.input)) {
                            var inputSetting = matrix_node.input;
                            var inputType = (inputSetting.type || "").toLowerCase();
                            if (!inputType) {
                                matrix_node.input = null;
                            } else {

                                var input_attrs = isObject(inputSetting.attrs) ? inputSetting.attrs : {};
                                inputSetting.attrs = input_attrs;

                                var input_pattern = inputSetting.attrs.pattern;

                                if (!input_pattern && inputSetting.pattern) {
                                    input_pattern = inputSetting.pattern;
                                    inputSetting.pattern = null;
                                }

                                if (!input_pattern && newPattern) {
                                    input_pattern = newPattern;
                                }

                                if (!hasLocaleDisplay && !input_pattern) {
                                    if (inputType == 'date') {
                                        input_pattern = 'yyyy-MM-dd';
                                    } else if (inputType == 'rocdate') {
                                        input_pattern = 'yyyMMdd';
                                    } else if (inputType == 'number') {
                                        input_pattern = '#,###.####';
                                    }

                                }

                                if (input_pattern) {
                                    inputSetting.attrs.pattern = input_pattern;
                                    if (!newPattern) {
                                        newPattern = input_pattern;
                                    }
                                }

                                if (newDataType == 'string') {
                                    if (inputType == 'number' || inputType == 'date' || inputType == 'rocdate') {
                                        newSortRule = inputType;
                                        if (hasLocaleDisplay && inputType == 'rocdate') {
                                            newSortRule = 'date';
                                        }
                                    }
                                }

                                //ÂÂª©ÄÝ©Ê
                                if (isNumeric(inputSetting.maxlength) && (!isNumeric(inputSetting.size) || inputSetting.size <= 0)) {
                                    inputSetting.attrs.size = inputSetting.maxlength + 2;
                                    inputSetting.attrs.maxlength = (inputSetting.maxlength - 0);
                                } else if (isNumeric(inputSetting.size) && (!isNumeric(inputSetting.maxlength) || inputSetting.maxlength <=0)) {
                                    inputSetting.attrs.size = inputSetting.size;
                                    //inputSetting.attrs.maxlength = (inputSetting.size - 0) + 2;
                                } else if (isNumeric(inputSetting.maxlength) && inputSetting.maxlength > 0 && isNumeric(inputSetting.size) && inputSetting.size > 0) {
                                    inputSetting.attrs.maxlength = inputSetting.maxlength;
                                    inputSetting.attrs.size = inputSetting.size;
                                }

                                if (isBasicType(inputSetting.className)) {
                                    inputSetting.className = (inputSetting.className + "").split(" ");
                                }

                                if (isFunction(inputSetting.keyPress)) {
                                    if (!isObject(inputSetting.events)) {
                                        inputSetting.events = {};
                                    }
                                    inputSetting.events['keyPress'] = inputSetting.keyPress;
                                }

                                inputSetting.maxlength = null;
                                inputSetting.size = null;
                                inputSetting.keyPress = null;

                                if (inputSetting.opts) {
                                    var opts_map = inputSetting.opts;
                                    var optionKey = inputSetting.optionKey;
                                    var optionValue = inputSetting.optionValue;
                                    if (isArray(opts_map) && optionKey && optionValue) {
                                        var valueIsFunction = isFunction(optionValue);
                                        opts_map = {};
                                        for (var opt_i = 0 ; opt_i < inputSetting.opts.length ; opt_i += 1) {
                                            var objData = inputSetting.opts[opt_i];
                                            var opt_value_key = objData[optionKey];
                                            if (!isBasicType(opt_value_key)) {
                                                continue;
                                            }
                                            var opt_value_value;
                                            if (valueIsFunction) {
                                                opt_value_value = optionValue(opt_value_key, objData);
                                            } else {
                                                opt_value_value = objData[optionValue];
                                            }
                                            opts_map[opt_value_key] = opt_value_value;
                                        }
                                        inputSetting.opts = opts_map;
                                    } else if (!isObject(opts_map)) {
                                        opts_map = null;
                                    }
                                }
                            }

                        } else if (!hasLocaleDisplay && !newPattern) {
                            if (newDataType == 'date') {
                                newPattern = 'yyyy-MM-dd';
                            } else if (newDataType == 'rocdate') {
                                newPattern = 'yyyMMdd';
                            } else if (newDataType == 'number') {
                                newPattern = '#,###.####';
                            }
                        }

                        if (newPattern) {
                            newAttrs.pattern = newPattern;
                        }

                        var newClasses = matrix_node.classes || matrix_node.className;
                        if (isString(newClasses)) {
                            newClasses = newClasses.split(' ');
                        } else if (!isArray(newClasses)) {
                            newClasses = [];
                        }
                        newClasses.push('type_' + newDataType);

                        newAttrs.name = matrix_node.key;

                        var newStyles = matrix_node.styles;
                        if (!isObject(newStyles)) {
                            newStyles = {};
                        }
                        if (!newStyles['textAlign'] && newAttrs['align']) {
                            newStyles['textAlign'] = newAttrs['align'];
                            newAttrs['align'] = null;
                        }

                        var renderInCount = matrix_node.renderInCount;
                        if (!renderInCount && renderInCount !== false) {
                            renderInCount = config.allRenderInCount;
                        }
                        if (!renderInCount && renderInCount !== false) {
                            renderInCount = false;
                        }

                        var staticWidth = matrix_node.staticWidth;
                        if(!isNumeric(staticWidth)){
                            if(isNumeric(matrix_node.width)){
                                staticWidth = matrix_node.width;
                            }else if(newAttrs['width'] && (newAttrs['width']+'').match(/[^%]$/) && isNumeric(parseInt(newAttrs['width'],10))){
                                staticWidth = parseInt(newAttrs['width'],10);
                            }else if(newStyles['width'] && (newStyles['width']+'').match(/[^%]$/) && isNumeric(parseInt(newStyles['width'],10))){
                                staticWidth = parseInt(newStyles['width'],10);
                            }else if(newStyles['maxWidth'] && (newStyles['maxWidth']+'').match(/[^%]$/) && isNumeric(parseInt(newStyles['maxWidth'],10))){
                                staticWidth = parseInt(newStyles['maxWidth'],10);
                            }else{
                                staticWidth = false;
                            }
                            newAttrs['width'] && ( delete newAttrs['width'] );
                            newStyles['width'] && ( delete newStyles['width'] );
                            newStyles['maxWidth'] && ( delete newStyles['maxWidth'] );
                            newStyles['max-width'] && ( delete newStyles['max-width'] );
                            newStyles['whiteSpace'] && ( delete newStyles['whiteSpace'] );
                            newStyles['white-space'] && ( delete newStyles['white-space'] );
                        }
                        

                        var setting_obj = {
                            'key': matrix_node.key,
                            'empty': matrix_node.empty,
                            'ignoreGroup': matrix_node.ignoreGroup,
                            'groupKey': matrix_node.groupKey,
                            'whenDataNull': matrix_node.whenDataNull,
                            'dataType': newDataType,
                            'format': matrix_node.format,
                            'render': matrix_node.render,
                            'input': matrix_node.input,
                            'staticWidth' : staticWidth,
                            'attrs': newAttrs,
                            'classes': newClasses,
                            'styles': newStyles,
                            'colGroup': matrix_node.colGroup,
                            'defaultValue': isBasicType(matrix_node.defaultValue) || isFunction(matrix_node) ? matrix_node.defaultValue : null,
                            'renderInCount': renderInCount
                        };

                        rtn_setting_line.push(setting_obj);
                    } else {
                        rtn_setting_line.push(null);
                    }
                }
                rtn_setting.push(rtn_setting_line);
            }

            //format For rowSpanByUp
            //±q²Ä¤G¦æ¶}©lÀË®Ö§Y¥i¡A¦]¬°ÀË®Ö²Ä¤@¦æ¨S¦³·N¸q
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
            /*¤£ÀË®Ö³Ì«á¤@¦æ¡A¦]¬°ÀË®Ö³Ì«á¤@¦æ¨S¦³·N¸q*/
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
            /* ±N³]©w¿é¥X */
            settings.recordSetting = rtn_setting;
            return rtn_setting;
        }

        /* «Ø¥ßautoCheckBox³]©w */
        function createAutoCheckBox(config, head_matrix_setting, record_matrix_setting) {

            if(!hasJsFramework){ return; }
            
            if (settings.isPrintMode || !config.autoCheckBox) { return; }

            if (settings.isFatchMode) { window.tableUI_getFatchRecords = true; }

            settings.checkAllBox = null;
            settings.hasAutoCheckBox = true;

            var autoCheckBoxsetting = isObject(config.autoCheckBox) ? config.autoCheckBox : {};

            var doNotRowSpan = getBoolean(autoCheckBoxsetting.doNotRowSpan, false);
            var settingColSpan = doNotRowSpan && isNumeric(autoCheckBoxsetting.colSpan) ? autoCheckBoxsetting.colSpan : 1;
            var settingRowSpan = doNotRowSpan && isNumeric(autoCheckBoxsetting.rowSpan) ? autoCheckBoxsetting.rowSpan : 1;

            var typeIsCheckBox = (autoCheckBoxsetting.type || "").toUpperCase() !== "RADIO";

            var valueKey = autoCheckBoxsetting.valueKey || "";
            settings.autoCheckBoxKey = valueKey;

            if (isString(autoCheckBoxsetting.returnValue) || isArray(autoCheckBoxsetting.returnValue)) {
                settings.autoCheckTemplate = autoCheckBoxsetting.returnValue;
            }

            if (isFunction(autoCheckBoxsetting.action)) {
                settings.autoCheckAction = autoCheckBoxsetting.action;
            }

            var insertPosition = autoCheckBoxsetting.insertPosition;
            if (!isNumeric(insertPosition) || insertPosition < 0) {
                insertPosition = 0;
            } else {
                var maxPosition = Math.max(record_matrix_setting[0] , head_matrix_setting[0].length);
                if (insertPosition >= maxPosition) {
                    insertPosition = maxPosition;
                }
            }

            if (insertPosition === 0 && settings.overDiv !== false) {
                fixedColumns.push(0);
            }

            /* createHeaderSetting */
            var header = (autoCheckBoxsetting.text || "¿ï¨ú");
            /* ¦pªG»Ý­n¥þ¿ï */
            var isSelectAll = !settings.isFatchMode && typeIsCheckBox && (autoCheckBoxsetting.isSelectAll === true || isFunction(autoCheckBoxsetting.isSelectAll));
            if (isSelectAll) {
                var input = createElement("input", { id: "autoCheckBox_" + table_id + "_SelectAll", name:"autoCheckAll", type: "checkbox" }, null, null, {
                    click: function (e) {
                        dataControl.autoCheckBoxSelectAll();
                        if (isFunction(autoCheckBoxsetting.isSelectAll)) {
                            var thisNode = getEventTarget(e);
                            autoCheckBoxsetting.isSelectAll.call(thisNode, thisNode, thisNode.checked, pageControl.getAllRecords());
                        }
                    }
                });
                if(getBoolean(autoCheckBoxsetting.noBreakLine , false )){
                    header = createFragment([input, header]);
                }else{
                    header = createFragment([input, createElement("br"), header]);
                }
                input.disabled = true;
                settings.checkAllBox = input;
            }
            /* ¼ÐÀY³]©wÀÉ*/
                
            var headerSettingRowSpan = doNotRowSpan ? settingRowSpan : head_matrix_setting.length;
            headerSettingRowSpan = Math.min( headerSettingRowSpan, head_matrix_setting.length );
            var setting_obj = {
                'header': createElement("div", null, null, null, null, null, header),
                'attrs': { colSpan:settingColSpan, rowSpan:headerSettingRowSpan },
                'fixedColumn': false
            };
            /* ¼ÐÀY¦ì¸m */
            head_matrix_setting[0].splice(Math.min(insertPosition,head_matrix_setting[0].length), 0, setting_obj);

            /* createRecordSetting */
            /* §PÂ_¬O§_»Ý­ngroup¿ï¾Ü¡A­Y¨Ï¥ÎªÌ³]©w¤£­nROWSPAN¦Ó¥B¸ê®Æ°ª«×¤j©ó 2¡CÂ÷¶}¡C */
            var newGroupKey = null;
            var recordSettingRowSpan = doNotRowSpan ? settingRowSpan : record_matrix_setting.length;
            recordSettingRowSpan = Math.min(recordSettingRowSpan, record_matrix_setting.length);

            /* groupLevel start from 1*/
            var withoutGroup = getBoolean(autoCheckBoxsetting.withoutGroup, false);
            var groupLevel = autoCheckBoxsetting.groupLevel;
            var groupKey = 1;
            if (isNumeric(groupLevel)) {
                groupKey = groupLevel;
            }else if (withoutGroup) {
                groupKey = null;
            } else if (isArray(autoCheckBoxsetting.groupKey)) {
                groupKey = autoCheckBoxsetting.groupKey;
            }
            /* ¨Ï¥ÎªÌ³]©wªºattrs */
            var records_attrs = autoCheckBoxsetting.attrs;
            if (!isObject(records_attrs)) { records_attrs = {}; }
            /*  ³]©wRowSpan  */
            records_attrs.rowSpan = recordSettingRowSpan;
            records_attrs.colSpan = settingColSpan;
                
            var setting_obj = {
                key: valueKey,
                groupKey: groupKey,
                ignoreGroup : valueKey && isArray(groupKey) ?  groupKey[0] != valueKey : false,
                renderInCount: true,
                attrs: records_attrs,
                render: function (r, v, sn) {
                    /* ¦X­pÄæ¦ì¤£Åã¥Ü */
                    if (!isNumeric(sn)) { return '¡@'; }

                    var autoCheckBoxResult = r['_tableuiAutoCheckBoxResult'];
                    /* -99 = ¤£²£¥Í */
                    if (autoCheckBoxResult == -99) { return '¡@'; }
                    
                    var input_id = "autoCheckBox_" + table_id;

                    var input = createElement("input",
						{ type: typeIsCheckBox ? "checkbox" : "radio", id: input_id+"_"+sn, name: input_id },
						null,
                        [input_id],
						{ click: dataControl.autoCheckBoxSingle }
					);
                    /* ³]©w¸ê®Æ¨ìinput */
                    if (v !== undefined || v !== null) {
                        input.value = v;
                        input.setAttribute('autoCheckBoxValue', v);
                    }
                    /* 1 & 0(disabled) À³¸Ó­n¥´¤Ä */
                    if (autoCheckBoxResult >= 0) {
                        addClassName(input,'shouldBeChecked');
                    }
                    /* 0 & -1 ¶i¦ædisabled */
                    if (autoCheckBoxResult === 0 || autoCheckBoxResult === -2) {
                        input.disabled = true;
                    }
                    /* §PÂ_¨Ï§_­nÅã¬O¦b­¶­±¤W */
                    if (!getBoolean(autoCheckBoxsetting.displayRule, true, [r, v, sn])) {
                        input.style.display = 'none';
                    }
                    return input;
                }
            };

            record_matrix_setting[0].splice(Math.min(insertPosition, record_matrix_setting[0].length), 0, setting_obj);
            
        }

        /* ±N³]©w°}¦C¤Æ */
        function settingToArrayArray(column_setting, split_setting) {
            if (!isArray(column_setting) || !column_setting[0]) {
                alert("¸ÑªR³]©w¿ù»~¡A½Ð½T»{¿é¤Jconfig.column­È¬°¤@­ÓArray!");
                return false;
            }
            /* ¶i¤Jª½±µ¬OArray<Array<Object>>*/
            if (isArray(column_setting[0])) {
                var newList = [];
                for (var i = 0 ; i < column_setting.length ; i += 1) {
                    var col_node = column_setting[i];
                    if (!isArray(col_node)) {
                        alert("¸ÑªR³]©w¿ù»~¡A½Ð½T»{¿é¤Jconfig.column­È¬°¤@­ÓArray<Array>!");
                        return;
                    }
                    newList.push([]);
                    for (var j = 0 ; j < col_node.length ; j += 1) {
                        if (isObject(col_node[j])) {
                            newList[i].push(col_node[j]);
                        } else {
                            alert('TableUI¸ÑªRÄæ¦ì³]©w®É¡A¥X²{¿ù»~ªº³]©w¡C½ÐÀË¬d¶Ç¤J³]©w­È¡C\n¨Ò¦p:³Ì«á¤@­ÓÄæ¦ì¦h¤F³r¸¹¡C1');
                        }
                    }
                }
                return newList;
            }
            /* ¶i¤Jª½±µ¬OArray<Object> ¨S¦³¤À¦æ*/
            if (!isArray(split_setting) || split_setting.length == 0) {
                var newList = [];
                for (var i = 0 ; i < column_setting.length ; i += 1) {
                    if (isObject(column_setting[i])) {
                        newList.push(column_setting[i]);
                    } else {
                        alert('TableUI¸ÑªRÄæ¦ì³]©w®É¡A¥X²{¿ù»~ªº³]©w¡C½ÐÀË¬d¶Ç¤J³]©w­È¡C\n¨Ò¦p:³Ì«á¤@­ÓÄæ¦ì¦h¤F³r¸¹¡C2');
                    }
                }
                return [newList];
            }
            /* ¶i¤Jª½±µ¬OArray<Object> ¦³¤À¦æ*/
            var rtnObj = [];
            var innerObj = [];
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
                } else {
                    alert('TableUI¸ÑªRÄæ¦ì³]©w®É¡A¥X²{¿ù»~ªº³]©w¡C½ÐÀË¬d¶Ç¤J³]©w­È¡C\n¨Ò¦p:³Ì«á¤@­ÓÄæ¦ì¦h¤F³r¸¹¡C3');
                }
            }

            if (innerObj.length > 0) {
                rtnObj.push(innerObj);
            }
            return rtnObj;
        }

        /* ¨ú±ogroups */
        function getGroupKeys(record_setting) {
            var allGroupKeys = [];
            var ignoreGroupKeys = [];

            var setting_height = record_setting.length;
            for (var setting_i = 0 ; setting_i < record_setting.length ; setting_i += 1) {
                var setting_line = record_setting[setting_i];
                for (var setting_j = 0 ; setting_j < setting_line.length ; setting_j += 1) {
                    var setting_node = setting_line[setting_j];
                    /* ³]©w¤£¬O¦b²Ä¤@¦æ©Î¸ÓÄæ¦ì¬°null(span¯d¤UªºªÅ®æ) */
                    if(!setting_node){
                        continue;
                    }
                    if (setting_i != 0 ) {
                        setting_node.groupKey = false;
                        continue;
                    }
                    /* ¤@©w­n¸ó¥þÄæ¤~¥i¥H°µgroup */
                    var rowSpan = setting_node.attrs && setting_node.attrs.rowSpan;
                    rowSpan = isNumeric(rowSpan) && rowSpan > 0 ? parseInt(rowSpan) : 1;
                    if (rowSpan != setting_height) {
                        setting_node.groupKey = false;
                        continue;
                    }
                    /* ¥²¶·¬°¼Æ¦r(­q¬°groupLevel)¡C©Î¬Ogroup array*/
                    var groupKey = setting_node.groupKey;
                    var groupLevel = isNumeric(groupKey) ? groupKey : null;
                    if (!(groupLevel || (isArray(groupKey) && groupKey.length > 0))) {
                        setting_node.groupKey = false;
                        continue;
                    }
                    
                    /* ­ì©l³]©w */
                    for (var group_count = 0 ; !groupLevel && group_count < groupKey.length ; group_count++) {
                        var test_key = groupKey[group_count];
                        var isMatch = false;
                        for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length || allGroup_count <= group_count ; allGroup_count++) {
                            var compareArray = allGroupKeys[allGroup_count];
                            if (!compareArray) {
                                compareArray = [];
                                allGroupKeys[allGroup_count] = compareArray;
                            }
                            var isInGroup = isInArray(compareArray, test_key);
                            if (isMatch && isInGroup >= 0) {
                                compareArray.splice(isInGroup, 1);
                            } else if (allGroup_count < group_count) {
                                if (isInGroup >= 0) {   
                                    isMatch = true;
                                }
                            } else if (allGroup_count == group_count) {
                                if (isInGroup < 0) {
                                    compareArray.push(test_key);
                                }
                                isMatch = true;
                            }
                        }
                    }

                    if (groupLevel !== null) {
                        continue;
                    }

                    /*¥[¤J³o­Ókey*/
                    var key = setting_node.key;
                    if (!key) {
                        key = '_autoEmptyKey_' + table_id + setting_i + '' + setting_j;
                        setting_node.key = key;
                        ignoreGroupKeys.push(key);
                    } else {
                        var isIgnore = getBoolean(setting_node.ignoreGroup, false);
                        if (isIgnore) {
                            ignoreGroupKeys.push(key);
                        }
                    }
                    if (isInArray(groupKey, key) >= 0) {
                        continue;
                    }
                    groupLevel = groupKey.length - 1;
                    var isMatch = false;
                    for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length; allGroup_count++) {
                        var compareArray = allGroupKeys[allGroup_count];
                        var isInGroup = isInArray(compareArray, key);
                        if (isMatch && isInGroup >= 0) {
                            compareArray.splice(isInGroup, 1);
                        } else if (allGroup_count < groupLevel) {
                            if (isInGroup >= 0) {
                                isMatch = true;
                            }
                        } else if (allGroup_count == groupLevel) {
                            if (isInGroup < 0) {
                                compareArray.push(key);
                            }
                            isMatch = true;
                        }
                    }
                }
            }

            if (allGroupKeys.length == 0) {
                return;
            }

            /*´M§ä¦UÄæ¦ì¦b²Ä´X¼hgroup...*/
            var groupLevelMark = [];
            for (var setting_j = 0 ; setting_j < record_setting[0].length ; setting_j += 1) {
                var setting_node = record_setting[0][setting_j];
                if (!setting_node || !setting_node.groupKey) { continue; }
                var groupKey = setting_node.groupKey;
                var leftKey = groupKey.length;
                for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length ; allGroup_count++) {
                    var compareArray = allGroupKeys[allGroup_count];
                    for (var group_count = 0 ; group_count < groupKey.length ; group_count++) {
                        var test_key = groupKey[group_count];
                        if(isInArray(compareArray, test_key) >= 0){
                            leftKey--;
                        }
                    }
                    if (leftKey <= 0) {
                        //console.log(setting_node.key + '/' + allGroup_count);
                        //setting_node.groupKey = allGroup_count;
                        groupLevelMark[allGroup_count] = true;
                        break;
                    }
                }
            }

            /* ¦X¨Ö¥¼¨Ï¥Îªº¶¥¼h */
            var merge_id=0;
            for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length ; allGroup_count++) {
                /* ­Y¨S¦³Äæ¥¼©w¸q¦b³o­Ótable­n¦X¨Ö¨ì¤W¤@¼h*/
                if(merge_id != allGroup_count){
                    allGroupKeys[merge_id] = allGroupKeys[merge_id].concat(allGroupKeys[allGroup_count]);
                    allGroupKeys[allGroup_count] = null;
                }
                if (groupLevelMark[allGroup_count]) {
                    merge_id = allGroup_count + 1;
                }
            }

            /* §R°£ªÅ¥Õ¶¥¼h */
            for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length ; allGroup_count++) {
                if(!allGroupKeys[allGroup_count] || !allGroupKeys[allGroup_count].length){
                    allGroupKeys.splice(allGroup_count,1);
                    allGroup_count--;
                }
            }

            /* §ó·s³]©wªº groupKey */
            var setting_line = record_setting[setting_i];
            for (var setting_j = 0 ; setting_j < record_setting[0].length ; setting_j += 1) {
                var setting_node = record_setting[0][setting_j];
                /* ³]©wÄæ¦ì¬°null(span¯d¤UªºªÅ®æ) ©Î¤£»Ý°µgroup¡Aªð¦^*/
                if (!setting_node || !setting_node.groupKey !== false) {
                    continue;
                }
                var newGroupKey = [];
                if (isNumeric(setting_node.groupKey)) {
                    for (var i = 0 ; i < allGroupKeys.length && i < setting_node.groupKey; i += 1) {
                        newGroupKey = newGroupKey.concat(allGroupKeys[i]);
                    }
                } else {
                    for (var i = 0 ; i < allGroupKeys.length ; i += 1) {
                        newGroupKey = newGroupKey.concat(allGroupKeys[i]);
                        if (isInArray(allGroupKeys[i], setting_node.key) >= 0) { break; }
                    }
                }
                for (var i = 0 ; i < ignoreGroupKeys.length ; i += 1) {
                    var isInGroup = isInArray(newGroupKey, ignoreGroupKeys[i]);
                    if (isInGroup >= 0) {
                        newGroupKey.splice(isInGroup, 1);
                    }
                }
                setting_node.groupKey = newGroupKey;

                //console.log(setting_node.key + '/' + Object.toJSON(newGroupKey));
                if (setting_node.key.indexOf('_autoEmptyKey_') == 0) {
                    setting_node.key = '';
                }
            }

            //console.log(Object.toJSON(allGroupKeys));

            /* ±N­n©¿²¤ªºkey§R°£ */
            for (var allGroup_count = 0 ; allGroup_count < allGroupKeys.length && 0 < ignoreGroupKeys.length ; allGroup_count++) {
                for (var ignoreGroup_count = 0 ; ignoreGroup_count < ignoreGroupKeys.length ; ignoreGroup_count++) {
                    var isInGroup = isInArray(allGroupKeys[allGroup_count], ignoreGroupKeys[ignoreGroup_count]);
                    if (isInGroup >= 0) {
                        allGroupKeys[allGroup_count].splice(isInGroup, 1);
                        ignoreGroupKeys.splice(ignoreGroup_count, 1);
                        ignoreGroup_count--;
                    }
                }
            }
            
            //console.log(Object.toJSON(allGroupKeys));

            settings.allGroupKeys = allGroupKeys;
        }

        /* ±N°}¦C¤Æ³]©w¸É»ôªÅ¥Õ */
        function fullMatrixSetting(matrix_setting) {
            var max_height = matrix_setting.length;
            var lines_length = [];
            var max_length = 0;
            for (var i = 0 ; i < max_height ; i += 1) {
                var line_length = matrix_setting[i].length;
                lines_length[i] = line_length;
                max_length = Math.max(max_length, line_length);
            }

            var nowPosition = 0;

            while (nowPosition < max_length) {
                for (var i = 0 ; i < max_height ; i += 1) {
                    var action_line = matrix_setting[i];
                    if (action_line.length <= nowPosition) {
                        action_line.push(null);
                        continue;
                    }
                    var test_elem = action_line[nowPosition];
                    if (!test_elem) {
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
                            if (add_row == 0 && add_col == 0) {
                                continue;
                            }
                            add_column_line.splice(nowPosition + add_col, 0, null);
                        }
                        max_length = Math.max(max_length, add_column_line.length);
                    }

                    test_elem.attrs.colSpan = node_colSpan;
                    test_elem.attrs.rowSpan = node_rowSpan;
                }
                nowPosition++;
            }

            return matrix_setting;
        }

        /* ³]©w©T©wÄæ¦ìªº¸s²Õ½s¸¹ */
        function settingFixedGroup(hSetting, rSetting) {
            var group_count = settings.hasAutoCheckBox ? -1 : 0;
            var now_position = 0;
            var max_ingore = 0;

            var hSetting_height = hSetting.length;
            var rSetting_height = rSetting.length;

            do {
                if (max_ingore == 0) {
                    group_count++;
                }
                var temp_ingore = -1;
                // header setting  figure
                for (var i = 0 ; i < hSetting_height ; i++) {
                    var elem = hSetting[i][now_position];
                    var isIngore = 0;
                    if (elem) {
                        elem.colGroup = group_count;
                        isIngore = elem.attrs.colSpan || 1;
                    }
                    isIngore--;
                    temp_ingore = Math.max(temp_ingore, isIngore);
                }

                // setting 2 figure
                for (var i = 0 ; i < rSetting_height ; i++) {
                    var elem = rSetting[i][now_position];
                    var isIngore = 0;
                    if (elem) {
                        elem.colGroup = group_count;
                        isIngore = elem.attrs.colSpan || 1;
                    }
                    isIngore--;
                    temp_ingore = Math.max(temp_ingore, isIngore);
                }

                now_position++;
                if (temp_ingore < 0) {
                    break;
                }
                max_ingore = Math.max(max_ingore - 1, temp_ingore);
            } while (max_ingore >= 0);

            /* ¼W¥[ÃÑ§O§Ç¸¹*/
            for (var i = 0 ; i < rSetting.length ; i += 1) {
                for (var j = 0 ; j < rSetting[i].length ; j += 1) {
                    var recordSetting_node = rSetting[i][j];
                    if (!recordSetting_node) { continue; }
                    recordSetting_node.attrs['_tableui_col_i'] = i;
                    recordSetting_node.attrs['_tableui_col_j'] = j;
                }
            }
        }

        /* ¥h°£§¹¥þªÅ¥Õ¦æ */
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

        /* ­«·s¨ú±o³]©w */
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
                            } else {
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

        /* ¨Ì·Óserial no ¨ú±o³]©w */
        this.getRecordColSetting = function (node) {
            if (!isElement(node)) { return; }
            var td = getCellByTagName(node, 'td');
            if (!isElement(td)) { return; }
            var col_i = td.getAttribute('_tableui_col_i');
            var col_j = td.getAttribute('_tableui_col_j');
            if (isNumeric(col_i) && isNumeric(col_j)) {
                return recordSetting[col_i][col_j];
            }
        }

        /* ±NÄæ¦ì(²Õ)¸m©ó«e¤è©T©w */
        this.fixedGroup = fixedGroup;
        function fixedGroup(groupNO) {

            groupNO = parseInt(groupNO, 10);

            var fixed_position = isInArray(fixedColumns, groupNO);
            if (fixed_position >= 0) {
                fixedColumns.splice(fixed_position, 1);
            } else {
                var setting_length = main_headerSetting[0].length - 1;
                while (!isObject(main_headerSetting[0][setting_length])) {
                    setting_length = setting_length - 1;
                }
                if (setting_length == 0 || main_headerSetting[0][0].colGroup == main_headerSetting[0][setting_length].colGroup) {
                    alert("¤w¸g¬O³Ì«á¤@­ÓÄæ¦ì¤F!");
                    return;
                }
                fixedColumns.push(groupNO);
            }
            reCreateSettings();
            dataControl.createHeader();
        }

        /* ±NÄæ¦ì(²Õ)ÁôÂÃ */
        this.hiddenGroup = hiddenGroup;
        function hiddenGroup(groupNO) {
            groupNO = parseInt(groupNO, 10);

            var hidden_position = isInArray(hiddenColumns, groupNO);
            if (hidden_position >= 0) {
                hiddenColumns.splice(hidden_position, 1);
            } else {
                var setting_length = main_headerSetting[0].length - 1;
                while (!isObject(main_headerSetting[0][setting_length])) {
                    setting_length = setting_length - 1;
                }
                if (setting_length == 0 || main_headerSetting[0][0].colGroup == main_headerSetting[0][setting_length].colGroup) {
                    alert("¤w¸g¬O³Ì«á¤@­ÓÄæ¦ì¤F!");
                    return;
                }
                hiddenColumns.push(groupNO);
            }

            reCreateSettings();
            dataControl.createHeader();

            while (hidden_columns_ul.childNodes.length > 2) {
                hidden_columns_ul.removeChild(hidden_columns_ul.lastChild);
            }
            hidden_columns_ul.style.display = "none";


            if (hidden_headerSetting.length) {
                removeClassName(hidden_columns_ul, "open");
                hidden_columns_ul.style.display = "block";
                hidden_headerSetting.sort(function (node1, node2) {
                    var compare1 = node1.colGroup;
                    compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
                    var compare2 = node2.colGroup;
                    compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
                    return compare1 - compare2;
                });

                var setCol = -1;
                for (var i = 0 ; i < hidden_headerSetting.length ; i += 1) {
                    var colGroup = hidden_headerSetting[i].colGroup;
                    var lastChild = hidden_columns_ul.lastChild;
                    if (colGroup != setCol) {
                        setCol = colGroup;
                        createElement("li", { colGroup: colGroup, title: "Åã¥ÜÄæ¦ì" }, null, null, {
                            click: function (e) {
                                var target = getEventTarget(e);
                                hiddenGroup(target.getAttribute("colGroup"));
                            }
                        }, hidden_columns_ul, getElement(hidden_headerSetting[i].header));
                    } else {
                        lastChild.appendChild(createElement("br"));
                        lastChild.appendChild(getElement(hidden_headerSetting[i].header));
                    }
                }
            }


        }

        /* ¨ú±o¥Ø«eÁôÂÃ/©T©wÄæ¦ì³]©w */
        this.getFixedHiddenInfo = getFixedHiddenInfo;
        function getFixedHiddenInfo(info) {
            info.fixedColumns = fixedColumns;
            info.hiddenColumns = hiddenColumns;
        }

        /* ³]©w¥Ø«eÁôÂÃ/©T©wÄæ¦ì */
        this.setFixedHiddenInfo = setFixedHiddenInfo;
        function setFixedHiddenInfo(info) {
            var shouldBeUpdate = false;
            if (isArray(info.fixedColumns) && info.fixedColumns.length > 0) {
                fixedColumns = info.fixedColumns;
                shouldBeUpdate = true;
            }
            if (isArray(info.hiddenColumns) && info.hiddenColumns.length > 0) {
                hiddenColumns = info.hiddenColumns;
                shouldBeUpdate = true;
            }
            if (shouldBeUpdate) {
                reCreateSettings();
                dataControl.createHeader();
            }
        }

        /* ±N³]©w¿é¥X¦¨json®æ¦¡´£¨Ñ·|¥Xxls¨Ï¥Î */
        this.getXlsSettingJSON = getXlsSettingJSON;
        function getXlsSettingJSON(sheetName) {

            var titleSetting = [];
            var detailSetting = [];

            var ColumnStartWith = config.autoCheckBox ? 1 : 0;

            for (var i = 0 ; i < headSetting.length ; i = i + 1) {
                var aCol = [];
                titleSetting.push(aCol);
                for (var j = ColumnStartWith ; j < headSetting[i].length ; j = j + 1) {
                    if (headSetting[i][j]) {
                        aCol.push({
                            'key': headSetting[i][j].key,
                            'header': headSetting[i][j].header,
                            'sortRule': isBasicType(headSetting[i][j].sortRule) ? headSetting[i][j].sortRule : 'string',
                            'groupKey': isArray(headSetting[i][j].groupKey)?headSetting[i][j].groupKey:[],
                            'attrs': headSetting[i][j].attrs
                        });
                    } else {
                        aCol.push({ 'key': 'N/A', 'sortRule': 'copy', 'attrs': {} });
                    }

                }
            }


            for (var i = 0 ; i < recordSetting.length ; i = i + 1) {
                var aCol = [];
                detailSetting.push(aCol);
                for (var j = ColumnStartWith ; j < recordSetting[i].length ; j = j + 1) {
                    if (recordSetting[i][j]) {
                        aCol.push({
                            'key': recordSetting[i][j].key,
                            'header': recordSetting[i][j].header,
                            'sortRule': isBasicType(recordSetting[i][j].dataType) ? recordSetting[i][j].dataType : 'string',
                            'groupKey': isArray(recordSetting[i][j].groupKey)?recordSetting[i][j].groupKey:[],
                            'attrs': recordSetting[i][j].attrs
                        });
                    } else {
                        aCol.push({ 'key': 'N/A', 'sortRule': 'copy', 'attrs': {} });
                    }

                }
            }

            var rtn_allGroupKeys = null;
            if (settings.allGroupKeys) {
                rtn_allGroupKeys = [];
                for (var i = 0 ; i < settings.allGroupKeys.length ; i++) {
                    rtn_allGroupKeys = rtn_allGroupKeys.concat(settings.allGroupKeys[i])
                }
            }

            var returnVar = { sheetName: sheetName, titleSetting: titleSetting, recordSetting: detailSetting, groupKeys: rtn_allGroupKeys };
            return toJSON(returnVar , true);
            
        }

    }

    //¸ê®Æ±±¨î¶µ functions
    function dataControl_impl() {
        var main_table_head = createElement('thead', null, null, null, null, main_table);
        var fixed_table_head = createElement('thead', null, null, null, null, fixed_table);
        
        var sortGroupKeys;
        var dataWhenNULL = isBasicType(config.whenDataNull) ?  config.whenDataNull  : "¡@";

        var setRecordBackground = isFunction(config.setRecordBackground) ? config.setRecordBackground : false;
        var setRecordClass = isFunction(config.setRecordClass) ? config.setRecordClass : false;

        var settings = settingCtrl.settings;

        var SimpleDateFormatSave = {};
        var saved_radios = {};

        var sortRules = [];

        var rowClick = isFunction(config.rowClick) ? config.rowClick : false;


        createHeader();

        /* ²£¥Íheader°Ï¶ô */
        this.createHeader = createHeader;
        function createHeader() {
            createOneHeader(settings.main_headerSetting, main_table_head);
            createOneHeader(settings.fixed_headerSetting, fixed_table_head);
            //sizeController.doResize();
            compareCellHeight(main_table_head, fixed_table_head);
            pageControl.reloadPage();
        }
        /* ²£¥Íheader°Ï¶ô */
        function createOneHeader(headSetting, append_head_parent, isFixedTable) {
            while (append_head_parent.hasChildNodes()) {
                append_head_parent.removeChild(append_head_parent.lastChild);
            }
            if (!headSetting || headSetting.length == 0) { return; }

            var firstLine_ignoreCount = 1;
            var lastLine_ignoreCount = 1;

            for (var i = 0 ; i < headSetting.length ; i += 1) {

                var temp_line = createElement("tr");
                for (var j = 0  ; j < headSetting[i].length ; j += 1) {
                    var matrix_node = headSetting[i][j];
                    if (isObject(matrix_node)) {
                        var temp_elem = createElement("th", matrix_node.attrs, null, null, null, temp_line, matrix_node.header 
							//,(matrix_node.attrs?"("+(matrix_node.attrs.colSpan||1)+","+(matrix_node.attrs.rowSpan||1)+")":"(1,1)")
						);
                        temp_elem.setAttribute("orgRowSpan", matrix_node.attrs.rowSpan || 1);
                        temp_elem.setAttribute("colGroup", matrix_node.colGroup);
                        //temp_elem.appendChild( getElement("<br>aaaaa"+matrix_node.colGroup) );

                        if (j == 0) {
                            firstLine_ignoreCount -= 1;
                            if (firstLine_ignoreCount <= 0) {
                                addClassName(temp_elem, "firstOfLine");
                                firstLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1, 10);
                            }
                        }

                        if (j == (headSetting[i].length - 1)) {
                            lastLine_ignoreCount -= 1;
                            if (lastLine_ignoreCount <= 0) {
                                addClassName(temp_elem, "lastOfLine");
                                lastLine_ignoreCount = parseInt(matrix_node.attrs.rowSpan || 1, 10);
                            }
                        }

                        /* ¦C¦L¼Ò¦¡¤@²v¤£²£¥Í¿ï³æ */
                        if(settingCtrl.settings.isPrintMode){ continue; }

                        var func_menu = createElement("ul", null, null, ["menu"]);
                        if (matrix_node.sortKey) {
                            addClassName(temp_elem, "sortable");
                            createElement("li", { title: "¥¿¦V±Æ§Ç", rule: matrix_node.sortRule, key: matrix_node.sortKey }, null, ["header_sort_az"]
									, {
									    click: function (e) {
									        var target = getEventTarget(e);
									        var menu = target.parentNode;
									        var th = target.parentNode.parentNode.parentNode;
									        sortDetail(target.getAttribute("key"), true, target.getAttribute("rule"));
									        menu.style.display = "none";
									        th.style.position = "";
									        /*
                                            addClassName(th, "sort_az");
									        removeClassName(th, "sort_za");
                                            */
									        sizeController.doResize('sort_az');
									    }
									}
								, func_menu
							);
                            createElement("li", { title: "°f¦V±Æ§Ç", rule: matrix_node.sortRule, key: matrix_node.sortKey }, null, ["header_sort_za"]
									, {
									    click: function (e) {
									        var target = getEventTarget(e);
									        var menu = target.parentNode;
									        var th = target.parentNode.parentNode.parentNode;
									        sortDetail(target.getAttribute("key"), false, target.getAttribute("rule"));
									        menu.style.display = "none";
									        th.style.position = "";
                                            /*
									        addClassName(th, "sort_za");
									        removeClassName(th, "sort_az");
                                            */
									        sizeController.doResize('sort_za');
									    }
									}
								, func_menu
							);

                            var sort_status = getSortRule(matrix_node.sortKey);
                            if (sort_status !== null) {
                                addClassName(temp_elem, sort_status ? "sort_az" : "sort_za");
                                removeClassName(temp_elem, sort_status ? "sort_za" : "sort_az");
                            }

                        }

                        if (matrix_node.colGroup > 0 && (matrix_node.fixedColumn !== false)) {
                            createElement("li", { title: "¸Ñ°£/©T©wÄæ¦ì" }, null, ["header_pin"]
									, {
									    click: function (e) {
									        var target = getEventTarget(e);
									        var colGroup = target.parentNode.parentNode.parentNode.getAttribute("colGroup");
									        settingCtrl.fixedGroup(colGroup);
									    }
									}
								, func_menu
							);
                        }
                        var isSetHidden = 0;
                        if (matrix_node.colGroup > 0 && getBoolean(matrix_node.hiddenColumn, true)) {
                            createElement("li", { title: "ÁôÂÃÄæ¦ì" }, null, ["header_hidden"]
									, {
									    click: function (e) {
									        var target = getEventTarget(e);
									        var colGroup = target.parentNode.parentNode.parentNode.getAttribute("colGroup");
									        settingCtrl.hiddenGroup(colGroup);
									    }
									}
								, func_menu
							);
                            isSetHidden = 1;
                        }

                        if (func_menu.childNodes.length > isSetHidden) {
                            createElement("li", { title: "Ãö³¬" }, null, ["header_close"]
									, {
									    click: function (e) {
									        var target = getEventTarget(e);
									        target.parentNode.style.display = "none";
									        target.parentNode.parentNode.parentNode.style.position = "";
									        var th = getParentByTagName(target, 'TH');
									        if (th) {
									            th.style.zIndex = 0;
									            removeClassName(th, "menu_open")
									        }
									    }
									}
								, func_menu
							);

                            var menu_carry_div = createElement("div", null, null, ['option_menu_position'], null, temp_elem, func_menu);

                            //temp_elem.appendChild(func_menu);

                            createElement(temp_elem, { "title": "¥\¯à¿ï³æ" }, null, ["mouse_pointer"], {
                                click: function (e) {
                                    var allTh = dataArea.getElementsByTagName('th');
                                    for(var i = 0 ; i < allTh.length ; i++ ){
                                        if(!hasClassName(allTh[i],'menu_open')){ continue; }
                                        allTh[i].style.zIndex = 0;
                                        removeClassName(allTh[i], "menu_open");
                                        allTh[i].lastChild.firstChild.style.display = "none";
                                    }

                                    var target = getEventTarget(e);
                                    if (target.tagName != 'TH') { return; }
                                    if (!pageControl.hasRecords()) { /* alert("¥²¶·¥ýÅª¤J¸ê®Æ¡A¤~¯à¶i¦æ¿ï³æ¾Þ§@¡I"); */ return; }
                                    
                                    target.style.zIndex = 50;
                                    addClassName(target, 'menu_open');
                                    var menu = target.lastChild.firstChild;
                                    if (menu && menu.tagName == "UL") {
                                        menu.style.display = "block";
                                        menu.style.width = (menu.lastChild.offsetLeft + 27) + "px";
                                    }
                                    /* ¦Û°ÊÃö³¬* /
                                    setTimeout(function () {
                                        target.parentNode.style.display = "none";
                                        target.parentNode.parentNode.style.position = "";
                                    }, 5000); */
                                }
                            });
                        }
                    }
                }

                if (temp_line.hasChildNodes()) {
                    append_head_parent.appendChild(temp_line);
                } else {
                    var checkRowSpan = 2;
                    var checkRow = append_head_parent.lastChild;
                    while (checkRow) {
                        var checkCell = checkRow.firstChild;
                        while (checkCell) {
                            var cutRowSpan = parseInt(checkCell.getAttribute("cutRowSpan"), 10) || 0;
                            var orgRowSpan = parseInt(checkCell.getAttribute("orgRowSpan"), 10) || 1;
                            if (orgRowSpan - cutRowSpan >= checkRowSpan) {
                                checkCell.setAttribute("cutRowSpan", cutRowSpan + 1);
                                checkCell.setAttribute("rowSpan", orgRowSpan - cutRowSpan - 1);
                            }
                            checkCell = checkCell.nextSibling;
                        }
                        checkRowSpan++;
                        checkRow = checkRow.previousSibling;
                    }
                    firstLine_ignoreCount -= 1;
                    lastLine_ignoreCount -= 1;
                }
            }

            countMinRowSapn(append_head_parent);
        }

        /* ²£¥Í¸ê®ÆÅã¥Ü°Ï¶ô¡A¥]§t¤p­pªº²£¥Í */
        this.createRecordsBody = createRecordsBody;
        function createRecordsBody(recordsInBody, recordsCount, body_serial_no) {
            createOneRecordsBody(settings.main_recordSetting, main_table, recordsInBody, recordsCount, body_serial_no, true);
            createOneRecordsBody(settings.fixed_recordSetting, fixed_table, recordsInBody, recordsCount, body_serial_no, false);

            /*
            //³]©w­I´ºÃC¦â¶¡®æ
            var main_table_tBodies = main_table.tBodies;
			var fixed_table_tBodies = fixed_table.tBodies;
			var last_tBody_num = main_table_tBodies.length - 1;
			if(last_tBody_num%2 == 1){
				addClassName(main_table_tBodies[last_tBody_num],"evenRecord");
				if(fixed_table_tBodies[last_tBody_num]){ addClassName(fixed_table_tBodies[last_tBody_num],"evenRecord"); }
			}*/
        }
        /* ²£¥Í¸ê®ÆÅã¥Ü°Ï¶ô¡A¥]§t¤p­pªº²£¥Í */
        function createOneRecordsBody(recordSetting, append_parent, records, recordsCount, body_serial_no, addTotalTitle) {
            if (!recordSetting || recordSetting.length == 0) { return; }
            if (isObject(records)) {
                records = [records];
            }
            else if (!isArray(records)) {
                return;
            }

            var groupSaving = {};
            var record_height = recordSetting.length;
            var preRecord;

            var record_body = createElement(
                "tbody"
                , { body_serial_no: body_serial_no }
                , null
                , null
                , hasJsFramework ?  {
                    mouseover: bodyMouseMoveOver,
                    mouseout: bodyMouseMoveOut,
                    click: bodyMouseClick
                } : null
                , append_parent
            );

            for (var records_count = 0 ; records_count < records.length ; records_count += 1) {
                var record = records[records_count];
                // !!!! quircks !!!!!!
                if (addTotalTitle) {
                    record.tRows = [];
                }
                // !!!! quircks !!!!!!
                var serial_no = record['_tableuiSerialNumber'];
                for (var i = 0 ; i < recordSetting.length ; i += 1) {
                    var temp_line = createElement("tr", { sn: serial_no });
                    for (var j = 0, line_length = recordSetting[i].length ; j < line_length ; j += 1) {
                        var matrix_node = recordSetting[i][j];
                        if (isObject(matrix_node)) {
                            var contentKey = matrix_node.key;
                            var hasGroup = isArray(matrix_node.groupKey);
                            var staticWidth = matrix_node.staticWidth;
                            if (preRecord && hasGroup) {
                                var isGroup = true;
                                var contentGroup = matrix_node.groupKey;
                                for (var group_count = 0 ; group_count < contentGroup.length ; group_count += 1) {
                                    if (preRecord[contentGroup[group_count]] != record[contentGroup[group_count]]) {
                                        isGroup = false;
                                    }
                                }
                                if (isGroup && groupSaving[contentKey]) {
                                    var savingCell = groupSaving[contentKey];
                                    savingCell.setAttribute("rowSpan", getCellAttributeToInteger(savingCell, "rowSpan", 1) + record_height);
                                    savingCell.setAttribute("orgRowSpan", getCellAttributeToInteger(savingCell, "orgRowSpan", 1) + record_height);
                                    savingCell.setAttribute("groupRecordNumbers", getCellAttributeToInteger(savingCell, "groupRecordNumbers", 1) + 1);
                                    savingCell.setAttribute("sn", savingCell.getAttribute("sn") + "," + serial_no);
                                    continue;
                                }
                            }

                            //¨ú±o¤º®e
                            var temp_elem = createElement("td", matrix_node.attrs, matrix_node.styles, matrix_node.classes, null, temp_line);
                            temp_elem.setAttribute("sn", serial_no);
                            temp_elem.setAttribute("orgRowSpan", matrix_node.attrs.rowSpan || 1);

                            if (hasGroup) {
                                groupSaving[contentKey] = temp_elem;
                            }

                            //³]©w¤º®e
                            createRecordCell(temp_elem, matrix_node, record);

                            if(staticWidth){
                                temp_elem.style.width = staticWidth+'px';
                                addClassName( temp_elem , 'staticWidthTd');
                                var tempStaticDiv = createElement('div',null,{width:staticWidth+'px'},['staticWidthContainer']);
                                while(temp_elem.firstChild){
                                    tempStaticDiv.appendChild(temp_elem.firstChild);
                                }
                                temp_elem.appendChild(tempStaticDiv);
                            }

                            //temp_elem.appendChild( getElement(firstLine_ignoreCount +" X "+lastLine_ignoreCount +"<br>"+matrix_node.attrs.colSpan +" X "+matrix_node.attrs.rowSpan) );
                            //temp_elem.appendChild( getElement("<br>aaaaa"+matrix_node.colGroup) );
                        }
                    }

                    if (temp_line.hasChildNodes()) {

                        /** !!!!  quircks !!!! **/
                        temp_line.dataObj = record;
                        if (addTotalTitle) {
                            record.tRows.push(temp_line);
                        }
                        /** !!!!  quircks !!!! **/

                        record_body.appendChild(temp_line);
                        if (validate_type != null && ( validate_type || !settingCtrl.settings.hasAutoCheckBox || record['_tableuiAutoCheckBoxResult'] == 1 ) && record['_tableuiValidateStatus'] === false) {
                            addClassName(temp_line, 'error_record');
                        }
                    } else {
                        /* ¥h°£ªÅ¥Õ¦æ */
                        var limit_rowSpan = 2;
                        var test_line = record_body.lastChild;
                        while (isElement(test_line)) {
                            var test_cell = test_line.firstChild;
                            while (isElement(test_cell)) {
                                var test_orgRowSpan = getCellAttributeToInteger(test_cell, 'orgRowSpan', 1);
                                var test_cutRowSpan = getCellAttributeToInteger(test_cell, 'cutRowSpan', 0);
                                if (test_orgRowSpan - test_cutRowSpan >= limit_rowSpan) {
                                    test_cell.setAttribute('cutRowSpan', test_cutRowSpan + 1);
                                }
                                test_cell = test_cell.nextSibling;
                            }
                            limit_rowSpan++;
                            test_line = test_line.previousSibling;
                        }
                    }
                }
                preRecord = record;
            }

            /* ¥[¤J¨C¦æ²Ä¤@­Ó¤Î³Ì«á¤@­ÓÄæ¦ìªºcss */
            var test_line = record_body.firstChild;
            var first_position = getCellAttributeToInteger(test_line.firstChild, '_tableui_col_j');
            var last_position = getCellAttributeToInteger(test_line.lastChild, '_tableui_col_j') + getCellAttributeToInteger(test_line.lastChild, 'colSpan',1);
            addClassName(test_line.firstChild, "firstOfLine");
            addClassName(test_line.lastChild, "lastOfLine");
            test_line = test_line.nextSibling;
            while (isElement(test_line)) {
                if (getCellAttributeToInteger(test_line.firstChild, '_tableui_col_j') == first_position) {
                    addClassName(test_line.firstChild, "firstOfLine");
                }
                if ((getCellAttributeToInteger(test_line.lastChild, '_tableui_col_j') + getCellAttributeToInteger(test_line.lastChild, 'colSpan',1) ) == last_position) {
                    addClassName(test_line.lastChild, "lastOfLine");
                }
                test_line = test_line.nextSibling;
            }

            if (setRecordBackground) {
                var rtnColor = setRecordBackground(records);
                if (rtnColor && isString(rtnColor)) {
                    record_body.style.backgroundColor = rtnColor;
                }
            }
            if (setRecordClass) {
                var rtnClass = setRecordClass(records);
                if (rtnClass && isString(rtnClass)) {
                    addClassName(record_body, rtnClass);
                }
            }

            //¤p­p³¡¤À
            createOneTotalRecordsBody(recordSetting, record_body, recordsCount, addTotalTitle);

            countMinRowSapn(record_body);
            
           	//³]©w­I´ºÃC¦â¶¡®æ
			var last_tBody_num = append_parent.tBodies.length - 1;
			if(last_tBody_num%2 == 1){
				addClassName(record_body,"evenRecordBody");
			}else{
				addClassName(record_body,"oddRecordBody");
			}

            return record_body;

        }

        /* ²£¥Í¤p­p©Î¦X­p°Ï¶ô */
        this.createTotalRecordBody = createTotalRecordBody;
        function createTotalRecordBody(createTotalInBody) {

            /*var main_table_tBodies = main_table.tBodies;
            var fixed_table_tBodies = fixed_table.tBodies;
            last_tBody_num = main_table_tBodies.length - 1;
            for (var i = last_tBody_num ; i >= 0  ; i--) {
                if (hasClassName(main_table_tBodies[i], 'totalCountRecord')) {
                    main_table_tBodies[i].parentNode.removeChild(main_table_tBodies[i]);
                }
                if (fixed_table_tBodies[i] && hasClassName(fixed_table_tBodies[i], 'totalCountRecord')) {
                    fixed_table_tBodies[i].parentNode.removeChild(fixed_table_tBodies[i]);
                }
            }*/

            if (!isArray(createTotalInBody) || createTotalInBody.length <= 0) {
                if (isElement(main_table.tFoot)) {
                    main_table.removeChild(main_table.tFoot);
                }
                if (isElement(fixed_table.tFoot)) {
                    fixed_table.removeChild(fixed_table.tFoot);
                }
                return;
            }
            createOneTotalRecordsBody(settings.main_recordSetting, main_table, createTotalInBody, true);
            createOneTotalRecordsBody(settings.fixed_recordSetting, fixed_table, createTotalInBody, false);

        }
        /* ²£¥Í¤p­p©Î¦X­p°Ï¶ô */
        function createOneTotalRecordsBody(recordSetting, record_body, records, addTotalTitle) {
            if (!recordSetting || recordSetting.length == 0) { return; }
            if (!isArray(records) || records.length <= 0) { return; }

            var isTotalCount = record_body.tagName == "TABLE";
            if (isTotalCount) {
                var record_table = record_body;
                record_body = createElement("tfoot");
                if (record_table.tFoot) {
                    record_table.replaceChild(record_body, record_table.tFoot);
                } else {
                    record_table.appendChild(record_body);
                }
            }

            for (var records_count = 0 ; records_count < records.length ; records_count += 1) {
                var count_data = records[records_count];
                if (!isObject(count_data)) {
                    continue;
                }
                var record = count_data;
                if (isObject(record.value)) {
                    record = record.value;
                }
                var setting_tableui_col_j = [];
                var count_lines = [];
                var first_line_is_empty = false;
                for (var i = 0 ; i < recordSetting.length ; i += 1) {
                    var temp_line = createElement("tr", null, null, ["count_data"]);
                    var line_is_not_empty = false;
                    for (var j = 0 ; j < recordSetting[i].length ; j += 1) {
                        var matrix_node = recordSetting[i][j];
                        if (!isObject(matrix_node)) { continue; }

                        var contentKey = matrix_node.key;
                        //¨ú±o¤º®e
                        var content = doSettingRender(record, matrix_node, null, matrix_node.renderInCount, true);
                        var orgRowSpan = getInteger(matrix_node.attrs.rowSpan, 1);
                        var orgColSpan = getInteger(matrix_node.attrs.colSpan, 1);
                        var tableui_col_j = getInteger(matrix_node.attrs._tableui_col_j);

                        setting_tableui_col_j[tableui_col_j] = true;

                        //³]©w¤º®e
                        if (content !== undefined) {
                            var temp_elem = createElement("td", matrix_node.attrs, matrix_node.styles, matrix_node.classes, null, temp_line, content);
                            temp_elem.setAttribute("orgRowSpan", orgRowSpan);
                            line_is_not_empty = true;
                        } else {
                            for (var k = 0 ; k < orgColSpan ; k++) {
                                var temp_elem = createElement("td", matrix_node.attrs, matrix_node.styles, matrix_node.classes, null, temp_line, "¡@");
                                temp_elem.setAttribute('colSpan', 1);
                                temp_elem.setAttribute("orgRowSpan", orgRowSpan);
                                temp_elem.setAttribute('_isEmpty', k);
                            }
                        }
                    }

                    if (line_is_not_empty) {
                        if (first_line_is_empty) {
                            first_line_is_empty = false;
                            var this_line_test_node = temp_line.firstChild
                            var first_line_test_node = count_lines[0].firstChild;
                            while (first_line_test_node) {
                                var test_node = first_line_test_node;
                                first_line_test_node = first_line_test_node.nextSibling;

                                var orgRowSpan = getCellAttributeToInteger(test_node, 'orgRowSpan', 1);
                                var cutRowSpan = getCellAttributeToInteger(test_node, 'cutRowSpan', 0);
                                if (orgRowSpan - cutRowSpan > 1) {
                                    test_node.setAttribute('cutRowSpan', cutRowSpan + 1);
                                    var this_col_j = getCellAttributeToInteger(this_line_test_node, '_tableui_col_j');
                                    var first_col_j = getCellAttributeToInteger(test_node, '_tableui_col_j');
                                    while (this_line_test_node && this_col_j < first_col_j) {
                                        this_line_test_node = this_line_test_node.nextSibling;
                                        this_col_j = getCellAttributeToInteger(this_line_test_node, '_tableui_col_j');
                                    }
                                    if (this_line_test_node) {
                                        temp_line.insertBefore(test_node, this_line_test_node);
                                    } else {
                                        temp_line.appendChild(test_node);
                                    }
                                }
                            }
                            //delete
                            record_body.removeChild(count_lines.splice(0, 1)[0]);
                        }
                        record_body.appendChild(temp_line);
                        count_lines.push(temp_line);
                    } else if (i == 0) {
                        first_line_is_empty = true;
                        record_body.appendChild(temp_line);
                        count_lines.push(temp_line);
                    }else {
                        /* ¥h°£ªÅ¥Õ¦æ¡A¦]¬°¦b¥¼append¤§«e¡ArowSpan¨ú±o·|¤@ª½¬O1 */
                        var limit_rowSpan = 2;
                        for (var k = count_lines.length - 1 ; k >= 0 ; k--) {
                            var test_cell = count_lines[k].firstChild;
                            while (isElement(test_cell)) {
                                var test_orgRowSpan = getCellAttributeToInteger(test_cell, 'orgRowSpan', 1);
                                var test_cutRowSpan = getCellAttributeToInteger(test_cell, 'cutRowSpan', 0);
                                if ((test_orgRowSpan - test_cutRowSpan) >= limit_rowSpan) {
                                    test_cell.setAttribute('cutRowSpan', test_cutRowSpan + 1);
                                }
                                test_cell = test_cell.nextSibling;
                            }
                            limit_rowSpan++;
                        }
                    }
                }
                    
                /* ®æ¦¡¤Æsetting_tableui_col_j¡A¸ÓMap¥Nªí¸Ótableui_col_j¸¹½X¸õ¤U¤@­ÓÄæ¦ìªº¸¹½X(¦]¬°¦³rowSpan¡Atableui_col_j¤£·|³s¸¹)*/
                var next_num = 9999;
                for (var k = setting_tableui_col_j.length-1 ; k >=0  ; k--) {
                    if (setting_tableui_col_j[k]) {
                        setting_tableui_col_j[k] = next_num;
                        next_num = k;
                    } else {
                        setting_tableui_col_j[k] = false;
                    }
                }

                /* ¦X¨ÖEmptycell¡A¥ý¦X¨Ö¤W¤U¡A¦A¦X¨Ö¥ª¥k */
                /* ¦X¨ÖÄæ¦ì¤W¤U */
                merge_test_cell = [];
                for (var k = 0 ; k < count_lines.length ; k++) {
                    merge_test_cell.push(count_lines[k].firstChild);
                }
                var test_number = 0;
                var all_end;
                do {
                    all_end = true;
                    var firstCell = null;
                    for (var k = 0 ; k < merge_test_cell.length ; k++) {
                        var testCell = merge_test_cell[k];
                        if (!testCell || !isElement(testCell)) { continue; }
                        all_end = false;
                        if (getCellAttributeToInteger(testCell, '_tableui_col_j') > test_number) { continue; }
                        merge_test_cell[k] = testCell.nextSibling;
                        if (!isNumeric(testCell.getAttribute('_isEmpty'))) { continue; }
                        if (!firstCell) {
                            firstCell = testCell
                        } else {
                            firstCell.setAttribute('cutRowSpan', getCellAttributeToInteger(firstCell, 'cutRowSpan', 0) - getCellAttributeToInteger(testCell, 'orgRowSpan', 1));
                            testCell.parentNode.removeChild(testCell);
                        }
                    }
                    test_number = test_number + 1;
                } while (!all_end);
                /* ¦X¨ÖÄæ¦ì¥ª¥k */
                for (var k = 0 ; k < count_lines.length ; k++) {
                    var test_cell = count_lines[k].firstChild;
                    while (isElement(test_cell)) {
                        var test_empty_no = getCellAttributeToInteger(test_cell, '_isEmpty', -1);
                        var next_cell = test_cell.nextSibling;
                        if (test_empty_no >= 0 && isElement(next_cell)) {
                            var testRowSpan = getCellAttributeToInteger(test_cell, 'orgRowSpan', 1) - getCellAttributeToInteger(test_cell, 'cutRowSpan', 0);
                            var limit_total_position = setting_tableui_col_j[getCellAttributeToInteger(test_cell, '_tableui_col_j')];
                            while (
                                limit_total_position >= 0
                                && isElement(next_cell)
                                && (getCellAttributeToInteger(next_cell, 'orgRowSpan', 1) - getCellAttributeToInteger(next_cell, 'cutRowSpan', 0)) == testRowSpan
                            ) {
                                var next_total_position = getCellAttributeToInteger(next_cell, '_tableui_col_j');
                                if (limit_total_position < next_total_position) { break; }

                                var next_empty_no = getCellAttributeToInteger(next_cell, '_isEmpty', -1);
                                if (next_empty_no < 0) { break; }

                                if (limit_total_position == next_total_position) {
                                    limit_total_position = setting_tableui_col_j[next_total_position];
                                } else if (next_empty_no != test_empty_no + 1) {
                                    break;
                                }
                                test_empty_no = next_empty_no;
                                test_cell.setAttribute('cutColSpan', getCellAttributeToInteger(test_cell, 'cutColSpan', 0) - 1); // 1 = test_cellªºorgColSpan
                                test_cell.parentNode.removeChild(next_cell);
                                next_cell = test_cell.nextSibling;
                            }
                        }
                        test_cell = next_cell;
                    }
                }
                /* ¥[¤J¨C¦æ²Ä¤@­Ó¤Î³Ì«á¤@­ÓÄæ¦ìªºcss */
                var first_position = getCellAttributeToInteger( count_lines[0].firstChild , '_tableui_col_j' );
                var last_position = getCellAttributeToInteger(count_lines[0].lastChild, '_tableui_col_j')
                    + 1 // 1 = count_lines[0].lastChildªºorgColSpan
                    - getCellAttributeToInteger(count_lines[0].lastChild, 'cutColSpan', 1)
                    + getCellAttributeToInteger(count_lines[0].lastChild, '_isEmpty');
                addClassName(count_lines[0].firstChild, "firstOfLine");
                addClassName(count_lines[0].lastChild, "lastOfLine");
                for (var i = count_lines.length - 1 ; i > 0  ; i--) {
                    if (!count_lines[i].childNodes.length) {
                        if (count_lines[i].parentNode) {
                            count_lines[i].parentNode.removeChild(count_lines[i]);
                        }
                        count_lines.splice(i, 1);
                        continue;
                    }
                    if (getCellAttributeToInteger(count_lines[i].firstChild, '_tableui_col_j') == first_position) {
                        addClassName(count_lines[i].firstChild, "firstOfLine");
                    }
                    if (
                            (getCellAttributeToInteger(count_lines[i].lastChild, '_tableui_col_j')
                            + 1 // 1 = count_lines[i].lastChildªºorgColSpan
                            -  getCellAttributeToInteger(count_lines[i].lastChild, 'cutColSpan', 0)
                            + getCellAttributeToInteger(count_lines[i].lastChild, '_isEmpty')
                        ) == last_position) {
                        addClassName(count_lines[i].lastChild, "lastOfLine");
                    }
                }
                /* ¥[¤J¦X­p¼ÐÃD */
                if (addTotalTitle && isNumeric(count_lines[0].firstChild.getAttribute('_isEmpty'))) {
                    /* ÂÂª© */
                    var total_header = count_data.text || count_data.header;
                    /* §PÂ_¸ê®ÆÀx¦s¦³¨S¦³ */
                    if (!total_header) {
                        if (record.tableui_headerKey) {
                            total_header = record[record.tableui_headerKey];
                        } else {
                            total_header = record.header;
                        }
                    }
                    /* ui¹w³] */
                    if (!total_header) {
                        total_header = isTotalCount ? config.default_total_header : config.default_subTotal_header;
                    }

                    if (total_header) {
                        count_lines[0].firstChild.innerHTML = '';
                        count_lines[0].firstChild.appendChild(getElement(total_header));
                        addClassName(count_lines[0].firstChild, "total_header");
                    }
                }
            }
            if (isTotalCount) {
                countMinRowSapn(record_body);
            }
        }

        /* ÀË¬d¨Ã³]©w¸ê®Æ¸ó¦æ¸ê°T */
        function countMinRowSapn(data_body) {
            var checkRow = data_body.firstChild;
            while (checkRow) {
                var minRowSpan = 9999;
                var checkCell = checkRow.firstChild;
                while (checkCell) {
                    var test_orgRowSpan = getCellAttributeToInteger(checkCell, 'orgRowSpan', 1);
                    var test_cutRowSpan = getCellAttributeToInteger(checkCell, 'cutRowSpan', 0);
                    minRowSpan = Math.min(test_orgRowSpan, minRowSpan);
                    checkCell.setAttribute('rowSpan', test_orgRowSpan - test_cutRowSpan);
                    checkCell.removeAttribute("cutRowSpan");
                    checkCell.removeAttribute("orgRowSpan");

                    var test_cutColSpan = getCellAttributeToInteger(checkCell, 'cutColSpan', 0);
                    if (test_cutColSpan != 0) {
                        checkCell.setAttribute('colSpan', 1 - test_cutColSpan); // 1 = ­ì¥»ªºcolSpan
                    }
                    checkCell.removeAttribute("cutColSpan");

                    checkCell = checkCell.nextSibling;
                }
                if (minRowSpan == 9999) {
                    minRowSpan = 1;
                }
                checkRow.setAttribute("minRowSpan", minRowSpan);
                checkRow = checkRow.nextSibling;
            }
        }

        /* ¤ÀªR³]©w¡A²£¥ÍÅã¥Ü¤º®e¦Ütd¤W */
        function createRecordCell(cell, cell_setting, record) {

            var serial_no = record['_tableuiSerialNumber'];
            var contentKey = cell_setting.key;
            var contentValue = (contentKey ? record[contentKey] : null);

            if (!contentValue && contentValue !== 0 && contentValue !== '' && cell_setting.defaultValue) {
                if (isFunction(cell_setting.defaultValue)) {
                    contentValue = cell_setting.defaultValue(record, contentValue, serial_no, contentKey);
                } else {
                    contentValue = cell_setting.defaultValue;
                }
                contentKey && (record[contentKey] = contentValue);
            }

            var contentValue_render = doSettingRender(record, cell_setting);
            var inputSetting = cell_setting.input;

            /* ¥H¤U¨âºØ±¡ªpª½±µ°±¤îinput²£¥Í 
                    1. ¦C¦L¼Ò¦¡
                    2. ¨S¦³¤Þ¥Îprototype.js ©Î jQuery.js (¤G¾Ü¤@)
            */
            if (settingCtrl.settings.isPrintMode  || (!hasJsFramework) || !isObject(inputSetting)) {
                if (isElement(contentValue_render)) {
                    cell.appendChild(contentValue_render);
                } else {
                    cell.innerHTML = contentValue_render;
                }
                return;
            }

            /* ¥H¤U¬°autoInput */
            /* ²£¥Íinput©Ò»Ý³]©w */

            addClassName(cell, 'autoInputCell');

            var elemAttrs = isObject(inputSetting.attrs) ? inputSetting.attrs : {};
            var elemEvents = isObject(inputSetting.events) ? inputSetting.events : {};
            var elemStyles = isObject(inputSetting.styles) ? inputSetting.styles : {};
            var elemClasses = isArray(inputSetting.className) ? inputSetting.className : null;

            var elemAction = isFunction(inputSetting.startAction) ? inputSetting.startAction : null;
            var actionWhenStart = !elemAction && isFunction(inputSetting.action) && getBoolean(inputSetting.actionWhenStart, false, [record, contentValue, serial_no, contentKey]);
            if (actionWhenStart) {
                elemAction = inputSetting.action;
            }

			var displayBlock = createElement("div", { type: "textNode" }, null, ['displayBlock'], null, null, contentValue_render);
            var inputBlock = createElement("div", { type: "inputNode", key: contentKey }, null, ['inputBlock']);
			

            var isEasyEdit = getBoolean(inputSetting.easyEdit, false, [record, contentValue, serial_no, contentKey]);

			cell.appendChild(displayBlock);
			cell.appendChild(inputBlock);
			
            var input_name = 'autoInput_' + contentKey + "_" + serial_no;

            var inputType = inputSetting.type.toLowerCase();

            var isDisabled = getBoolean(inputSetting.disableRule, false, [record, contentValue, serial_no, contentKey]);
            var isReadOnly = getBoolean(inputSetting.readOnlyRule, false, [record, contentValue, serial_no, contentKey]);

            var followText = inputSetting.followText || inputSetting.text;
            if (followText && isFunction(followText)) {
                followText = followText(record, contentValue, serial_no, contentKey);
            }

            switch (inputType) {
                case 'text':
                    var input = createElement (
                        'input',  
                        { 
                            'type': 'text', 
                            'name': input_name, 
                            'key': contentKey , 
                            'tableui_key': contentKey 
                        }, 
                        null, 
                        ['textBox2'],
                        {
                            'change': function (e) {
                                var target = getEventTarget(e);

                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);

                                var unChangeData = record[key];
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    (records[i])[key] = contentValue;
                                }

                                //update display_cell
                                var textNode = getCellByTagName(target, "TD").firstChild;
                                var contentValue_render = doSettingRender(record, col_setting);
                                updateElement(textNode , contentValue_render);

                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['change'])) {
                                    col_setting.events['change'].call(target, e);
                                }

                                if (isEasyEdit) { exchangeAutoInput(target, [key], true); }

                            }
                        }
                    );

                    setFormElementValue(input , contentValue);

                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            input.setAttribute(key, elemAttrs[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'change' && isFunction(elemEvents[key])) {
                            setEventObserve(input, key, elemEvents[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(input, null, elemStyles, elemClasses);

                    appendElement( inputBlock , input);

                    if (followText) { appendElement( inputBlock , followText); }

                    if (isDisabled) { input.disabled = true; }

                    if (isReadOnly) { input.readOnly = true; }

                    if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }

                    break;

                case 'number':

                     var input = createElement (
                        'input',  
                        { 
                            'type': 'text', 
                            'datatype': 'number',
                            'name': input_name, 
                            'key': contentKey , 
                            'tableui_key': contentKey 
                        }, 
                        null, 
                        ['textBox2'],
                        {
                            'blur': function (e) {
                                var target = getEventTarget(e);

                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);

                                if (isNumeric(contentValue)) {
                                    contentValue = parseFloat(contentValue)
                                }

                                var isChange = false;
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    var recordsValue = (records[i])[key];
                                    if (isNumeric(recordsValue)) {
                                        recordsValue = parseFloat(recordsValue)
                                    }
                                    if (recordsValue !== contentValue) { isChange = true; }
                                }
                                if (!isChange) { return; }

                                var unChangeData = record[key];
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    (records[i])[key] = contentValue;
                                }

                                //update display_cell
                                var textNode = getCellByTagName(target, "TD").firstChild;
                                var contentValue_render = doSettingRender(record, col_setting);
                                updateElement(textNode , contentValue_render);

                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['blur'])) {
                                    col_setting.events['blur'].call(target, e);
                                }

                                //if (isEasyEdit) { exchangeAutoInput(target, [key], true); }

                            }
                        }
                    );

                    /* format content value */
                    if (isString(contentValue_render) && contentValue_render == '¡@') { contentValue_render = ''; }
                    /* ²Ä¤@¦¸³]©w¼Æ­È¡A­n³]©w¦³¤d¤À¦ìªº */
                    setFormElementValue(input , contentValue_render);


                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            input.setAttribute(key, elemAttrs[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'blur' && isFunction(elemEvents[key])) {
                            setEventObserve(input, key, elemEvents[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(input, null, elemStyles, elemClasses);

                    appendElement(inputBlock , input);

                    if (followText) { appendElement( inputBlock , followText); }

                    if (isDisabled) { input.disabled = true; }

                    if (isReadOnly) { input.readOnly = true; }

                    if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }

                    break;


                case 'date':
                case 'rocdate':
                    if (contentValue_render == '¡@') { contentValue_render = ''; }

                    var input = createElement (
                        'input',  
                        { 
                            'type': 'text', 
                            'datatype': inputType,
                            'name': input_name, 
                            'key': contentKey , 
                            'tableui_key': contentKey 
                        }, 
                        null, 
                        ['textBox2'],
                        {
                            'change': function (e) {
                                var target = getEventTarget(e);

                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);
                                var datatype = target.getAttribute('datatype').toLowerCase();
                                if (contentValue && datatype == 'rocdate' && isFunction(window.toY2K)) {
                                    contentValue = toY2K(contentValue);
                                }

                                var unChangeData = record[key];
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    (records[i])[key] = contentValue;
                                }

                                //update display_cell
                                var textNode = getCellByTagName(target, "TD").firstChild;
                                var contentValue_render = doSettingRender(record, col_setting);
                                updateElement(textNode , contentValue_render);

                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['change'])) {
                                    col_setting.events['change'].call(target, e);
                                }

                                //if (isEasyEdit) { exchangeAutoInput(target, [key], true); }

                                

                            }
                        }
                    );

                    setFormElementValue( input , contentValue_render);

                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            input.setAttribute(key, elemAttrs[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'change' && isFunction(elemEvents[key])) {
                            setEventObserve( input, key, elemEvents[key]);
                        }
                    }
                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(input, null, elemStyles, elemClasses);

                    appendElement(inputBlock , input);

                    //if (followText) { appendElement( inputBlock , followText); }

                    if (isDisabled) { input.disabled = true; }

                    if (isReadOnly) { input.readOnly = true; }

                    if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }

                    break;


                case 'textarea':

                    if (isString(contentValue)) {
                        contentValue = contentValue.replace(/&/gi, '&amp;').replace(/amp;amp;/gi, 'amp;');
                        contentValue = contentValue.replace(/<br>/gi, '\n').replace(/<\/br>/gi, '\n').replace(/<br.*?\/>/gi, '\n');
                        //contentValue = contentValue.replace(/</gi, '&lt;');
                        //contentValue = contentValue.replace(/>/gi, '&gt;');
                        contentValue = contentValue.replace(/\n/g, '</br>');
                    }

                    var input = createElement (
                        'textarea',  
                        { 
                            'name': input_name, 
                            'key': contentKey, 
                            'tableui_key': contentKey,
                            'wrap': 'Virtual',
                            'isEasyEdit':(isEasyEdit ? 'Y' : 'N')
                        }, 
                        null, 
                        ['textBox2'],
                        {
                            'change': function (e) {
                                var target = getEventTarget(e);

                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                if (isObject(window.InputUtility) && isFunction(target.doLengthLimit)) {
                                    target.doLengthLimit();
                                }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);
                                var unChangeData = record[key];
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    (records[i])[key] = contentValue;
                                }

                                //update display_cell
                                var textNode = getCellByTagName(target, "TD").firstChild;
                                var contentValue_render = doSettingRender(record, col_setting);
                                var newText = ExchangeToShortText(contentValue_render, col_setting.input.shortTextLength);
                                if (target.getAttribute('isEasyEdit') == 'Y') {
                                    var clickText = col_setting.input.clickText;
                                    if (clickText && ((!newText && newText !== false && newText !== 0) || newText == '...' || newText == '¡@')) {
                                        newText = '<font color="lightgray">(' + (isString(clickText) || isNumeric(clickText) ? clickText : '«ö¦¹¿é¤J') + ')</font>';
                                    } else if (!newText) {
                                        newText = '...';
                                    }
                                }
                                updateElement( textNode , newText);
                                
                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['change'])) {
                                    col_setting.events['change'].call(target, e);
                                }

                                //if (isEasyEdit) { exchangeAutoInput(this, [key], true); }

                                

                            }
                        }
                    );

                    setFormElementValue(input , contentValue);
                    
                    // update short text to display block!
                    var newText = ExchangeToShortText(contentValue_render, inputSetting.shortTextLength);
                    if (isEasyEdit) {
                        var clickText = inputSetting.clickText;
                        if (clickText && ((!newText && newText !== false && newText !== 0) || newText == '...'¡@|| newText == '¡@'¡@)) {
                            newText = '<font color="lightgray">(' + (isString(clickText) || isNumeric(clickText) ? clickText : '«ö¦¹¿é¤J') + ')</font>';
                        } else if (!newText) {
                            newText = '...';
                        }
                    }
                    updateElement( displayBlock , newText);
                    

                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            input.setAttribute(key, elemAttrs[key]);
                        }
                    }
                    isNumeric(inputSetting.cols) && input.setAttribute('cols', inputSetting.cols);
                    isNumeric(inputSetting.rows) && input.setAttribute('rows', inputSetting.rows);

                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'change' && isFunction(elemEvents[key])) {
                            setEventObserve(input , key , elemEvents[key]);
                        }
                    }

                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(input, null, elemStyles, elemClasses);

                    //if (followText) { inputBlock.insert(followText); }

                    if (isDisabled) { input.disabled = true; }

                    if (isReadOnly) { input.readOnly = true; }

                    if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }

                    if (isObject(window.InputUtility) && isObject(InputUtility.lengthLimit)  && isObject(inputSetting.lengthLimit) && isNumeric(inputSetting.lengthLimit.length)) {
                        input = InputUtility.lengthLimit.add(input, inputSetting.lengthLimit.length, inputSetting.lengthLimit.countByByte, inputSetting.lengthLimit.customMsg);
                    }

                    appendElement( inputBlock , input);

                    break;

                case 'select':
                    var selectObj = createElement (
                        'select',  
                        { 
                            'name': input_name, 
                            'key': contentKey, 
                            'tableui_key': contentKey
                        }, 
                        null, 
                        ['textBox2'],
                        {
                            'change': function (e) {
                                var target = getEventTarget(e);
                                
                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);

                                var unChangeData = record[key];
                                for (var i = 0 ; i < records.length ; i = i + 1) {
                                    (records[i])[key] = contentValue;
                                }

                                //update display_cell
                                var textNode = getCellByTagName(target, "TD").firstChild;
                                var contentValue_render = "";
                                var opts = target.options;
                                for (var i = 0 ; i < opts.length ; i = i + 1) {
                                    if (opts[i].selected) {
                                        contentValue_render = doSettingRender(record, col_setting, opts[i].innerHTML);
                                    }
                                }
                                updateElement(textNode , contentValue_render);

                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['change'])) {
                                    col_setting.events['change'].call(target, e);
                                }

                                if (isEasyEdit) { exchangeAutoInput(target, [key], true); }

                            }
                        }
                    );

                    // add options 
                    var optionKey = isString(inputSetting.optionKey) ? inputSetting.optionKey : 'key';
                    var optionValue = isString(inputSetting.optionValue) || isFunction(inputSetting.optionValue) ? inputSetting.optionValue : 'value';
                        
                    var createOptions = function (opts_map) {
                        if (isObject(opts_map)) {
                            for (var opt_key in opts_map) {
                                var option = createElement('option',{ 'value': opt_key });
                                updateElement(option, opts_map[opt_key]);
                                if (opt_key == contentValue) {
                                    option.selected = true;
                                }
                                appendElement(selectObj , option);
                            }
                        } else if (isArray(opts_map)) {
                            for (var opt_i = 0 ; opt_i < opts_map.length ; opt_i++) {
                                var opt_map = opts_map[opt_i];
                                if (!isObject(opt_map)) { continue; }

                                var opt_key = opt_map[optionKey];
                                if (!isBasicType(opt_key)) { continue; }

                                var opt_display;
                                if (isString(optionValue)) {
                                    opt_display = opt_map[optionValue];
                                } else {
                                    opt_display = optionValue(opt_map, opt_key);
                                }

                                if (!isBasicType(opt_display)) { opt_display = opt_key; }

                                var option = createElement('option',{ 'value': opt_key });
                                updateElement(option, opt_display); 
                                if (opt_key == contentValue) {
                                    option.selected = true;
                                }
                                appendElement(selectObj , option);
                            }
                        }
                    }
                                
                            
                    createOptions(inputSetting.opts_before);
                    createOptions(inputSetting.opts);
                    createOptions(inputSetting.opts_after);

                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            selectObj.setAttribute(key, elemAttrs[key]);
                        }
                    }

                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'change' && isFunction(elemEvents[key])) {
                            setEventObserve( selectObj , key , elemEvents[key]);
                        }
                    }

                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(selectObj, null, elemStyles, elemClasses);

                    appendElement(inputBlock , selectObj);
                    
                    if (followText) { appendElement( inputBlock , followText); }

                    if (isDisabled || isReadOnly) { input.disabled = true; }

                    if (elemAction) { elemAction(selectObj, [record], displayBlock, contentValue, false); }

                    break;
                case 'checkbox':
                case 'radio':
                    //break;
                    if (inputSetting.opts) {
                        var opts_map = inputSetting.opts;
                        var checked_values = isBasicType(contentValue) ? (contentValue + "").split(',') : [];

                        for (var opt_key in opts_map) {
                            var input = createElement (
                                'input',  
                                { 
                                    'type': inputType,
                                    'name': input_name, 
                                    'key': contentKey, 
                                    'tableui_key': contentKey
                                }, 
                                null, 
                                null,
                                {
                                    'click': function (e) {
                                        var target = getEventTarget(e);
                                        var inputType_radio = target.getAttribute('type') == 'radio';
                                        var inputName = target.getAttribute('name')
                                        var prev_radio = saved_radios[inputName];
                                        if (inputType_radio) {
                                            if (prev_radio == target) {
                                                return;
                                            } else {
                                                saved_radios[inputName] = target;
                                            }
                                        }

                                        var col_setting = settingCtrl.getRecordColSetting(target);
                                        if (!col_setting) { return; }

                                        var key = col_setting.key;
                                        var record = dataControl.getRecordByCell(target);
                                        var records = dataControl.getRecordsByCell(target);

                                        var td_cell = getCellByTagName(target, "TD");
                                        var checkValues = [];
                                        var inputs = td_cell.getElementsByTagName('input');
                                        for(var i = 0 ; i < inputs.length ; i++){
                                            if(inputs[i].getAttribute('name') != inputName){ continue; }
                                            if(inputs[i].checked){
                                                checkValues.push(inputs[i].getAttribute('value'));
                                            }
                                        }
                                        
                                        var contentValue = checkValues + '';
                                        for (var i = 0 ; i < records.length ; i = i + 1) {
                                            (records[i])[key] = contentValue;
                                        }

                                        //update text
                                        var textNode = td_cell.firstChild;
                                        var contentValue_render = doSettingRender(record, col_setting);
                                        updateElement(textNode , contentValue_render);

                                        //doAction
                                        var actionFunc = col_setting.input.action;
                                        var clickFunction = col_setting.events && isFunction(col_setting.events['click']) && isFunction(col_setting.events['click']);
                                        if (isFunction(actionFunc)) {
                                            actionFunc.call(target, target, records, textNode, true, true);
                                        }
                                        //user action
                                        if (clickFunction) { clickFunction.call(target, e); }

                                        // pre radio action
                                        if (prev_radio && isFunction(actionFunc)) {
                                            prev_radio.checked = false;
                                            actionFunc.call(target, prev_radio , records , textNode , false , true);
                                        }
                                    }
                                }
                            );

                            input.setAttribute('value' , opt_key);

                            var label = createElement('label');
                            appendElement( label , input );
                            appendElement( label , ' ' + opts_map[opt_key] + '¡@');
                            appendElement(inputBlock , label);

                            input.checked = false;

                            if (isInArray(checked_values, opt_key) >= 0) {
                                addClassName( input, 'shouldBeChecked');
                            }

                            /*¨Ï¥ÎªÌÄÝ©Ê*/
                            for (var key in elemAttrs) {
                                key = key.toLowerCase();
                                if (!(key == 'type' || key == 'name' || key == 'key')) {
                                    input.setAttribute(key, elemAttrs[key]);
                                }
                            }

                            /*¨Ï¥ÎªÌ°Ê§@*/
                            for (var key in elemEvents) {
                                if (key != 'click' && isFunction(elemEvents[key])) {
                                    setEventObserve( input, key, elemEvents[key]);
                                }
                            }

                            /*¨Ï¥ÎªÌstyle¤Îclass*/
                            createElement(input, null, elemStyles, elemClasses);
                            
                            if (followText) { appendElement( inputBlock, followText); }
                            
                            if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); };
                            /*if (opt_key == contentValue) {
			                    option.selected = true;
			                }*/
                            if (isDisabled || isReadOnly) { input.disabled = true; }

                        }

                    } else {
                        var isChangeAll = getBoolean(inputSetting.isChangeAll, false, [record, contentValue, serial_no]);
                        input_name = isChangeAll ? 'auto_' + inputType + '_' + contentKey : 'auto_' + inputType + '_' + contentKey + '_' + serial_no;
                        var input = createElement (
                            'input',  
                            { 
                                'type': inputType,
                                'name': input_name, 
                                'key': contentKey, 
                                'tableui_key': contentKey
                            }, 
                            null, 
                            null,
                            {
                                'click': function (e) {
                                    var target = getEventTarget(e);

                                    var inputType_radio = target.getAttribute('type') == 'radio';
                                    var prev_radio = saved_radios[key];
                                    if (inputType_radio) {
                                        if (prev_radio == target) {
                                            return;
                                        } else {
                                            saved_radios[key] = target;
                                        }
                                    }

                                    var col_setting = settingCtrl.getRecordColSetting(target);
                                    if (!col_setting) { return; }

                                    var key = col_setting.key;
                                    var record = dataControl.getRecordByCell(target);
                                    var records = dataControl.getRecordsByCell(target);

                                    var contentValue = target.checked ? 'Y' : 'N';
                                    for (var i = 0 ; i < records.length ; i = i + 1) {
                                        (records[i])[key] = contentValue;
                                    }

                                    //update text
                                    var textNode = getCellByTagName(target, "TD").firstChild;
                                    var contentValue_render = doSettingRender(record, col_setting);
                                    updateElement( textNode , contentValue_render);

                                    //doAction
                                    var actionFunc = col_setting.input.action;
                                    var clickFunction = col_setting.events && isFunction(col_setting.events['click']) && isFunction(col_setting.events['click']);
                                    if (isFunction(actionFunc)) {
                                        actionFunc.call(target, target, records, textNode, true, true);
                                    }

                                    //user action
                                    if (clickFunction) { clickFunction.call(target, e); }

                                    // pre radio action
                                    if (prev_radio && isFunction(actionFunc)) {
                                        prev_radio.checked = false;
                                        actionFunc.call(target, prev_radio , records , textNode , false , true);
                                    }
                                    
                                }
                            }
                        );
                        
                        if (isBasicType(contentValue) && contentValue !== '' && contentValue !== 'N') {
                            addClassName(input , 'shouldBeChecked');
                        }

                        /*¨Ï¥ÎªÌÄÝ©Ê*/
                        for (var key in elemAttrs) {
                            key = key.toLowerCase();
                            if (!(key == 'type' || key == 'name' || key == 'key')) {
                                input.setAttribute(key, elemAttrs[key]);
                            }
                        }

                        /*¨Ï¥ÎªÌ°Ê§@*/
                        for (var key in elemEvents) {
                            if (key != 'click' && isFunction(elemEvents[key])) {
                                setEventObserve( input, key, elemEvents[key]);
                            }
                        }

                        /*¨Ï¥ÎªÌstyle¤Îclass*/
                        createElement(input, null, elemStyles, elemClasses);

                        var label = createElement('label');

                        appendElement(label , input );
                        appendElement(inputBlock , label);

                        if (followText) { appendElement(label, followText); }

                        if (isDisabled || isReadOnly) { input.disabled = true; }

                        if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }


                    }

                    break;

                case 'button':

                    isEasyEdit = false;

                    var input = createElement (
                        'input',  
                        { 
                            'type': 'button',
                            'name': input_name, 
                            'key': contentKey, 
                            'tableui_key': contentKey
                        }, 
                        null, 
                        ['button'],
                        {
                            'click': function (e) {
                                var target = getEventTarget(e);
                                var col_setting = settingCtrl.getRecordColSetting(target);
                                if (!col_setting) { return; }

                                var key = col_setting.key;
                                var record = dataControl.getRecordByCell(target);
                                var records = dataControl.getRecordsByCell(target);

                                var contentValue = getFormElementValue(target);
                                //var contentValue_render = doSettingRender(contentValue, record, index, col_setting);

                                var unChangeData = record[key];

                                var textNode = getCellByTagName(target, "TD").firstChild;

                                //do action
                                var actionFunc = col_setting.input.action;
                                if (isFunction(actionFunc)) {
                                    actionFunc.call(target, target, records, textNode, unChangeData, true);
                                }

                                //user action
                                if (col_setting.events && isFunction(col_setting.events['click'])) {
                                    col_setting.events['click'].call(target, e);
                                }
                                
                            }
                        }
                    );

                    /*¨Ï¥ÎªÌÄÝ©Ê*/
                    for (var key in elemAttrs) {
                        key = key.toLowerCase();
                        if (!(key == 'type' || key == 'name' || key == 'key')) {
                            input.setAttribute(key, elemAttrs[key]);
                        }
                    }

                    /*¨Ï¥ÎªÌ°Ê§@*/
                    for (var key in elemEvents) {
                        if (key != 'click' && isFunction(elemEvents[key])) {
                            setEventObserve(input, key, elemEvents[key]);
                        }
                    }

                    /*¨Ï¥ÎªÌstyle¤Îclass*/
                    createElement(input, null, elemStyles, elemClasses);

                    var button_text = inputSetting.button_display_text || inputSetting.button_text || contentValue_render;
					
                    if (!isBasicType(button_text) || !trim(button_text) || button_text == '¡@') {
                        button_text = followText || null;
                    }

                    if (!isBasicType(button_text) || !trim(button_text) || button_text == '¡@') {
                        button_text = '«ö¶s¦WºÙ¥¼©w¸q';
                    }
                    
                    setFormElementValue(input , button_text)
                    
                    /*
                    var button_display_text = inputSetting.button_display_text || button_text;
                    if (!isBasicType(button_display_text)) {
                        button_display_text = '¡@';
                    }
                    updateElement(displayBlock, button_display_text);
                    */
                    
                    appendElement(inputBlock,input);

                    if (isDisabled || isReadOnly) { input.disabled = true; }

                    if (elemAction) { elemAction(input, [record], displayBlock, contentValue, false); }

                    break;

                case 'show':
                    if (!contentValue_render || !trim(contentValue_render) || contentValue_render == '¡@') {
                        removeElement(displayBlock);
                        removeElement(inputBlock);
                        updateElement(cell, contentValue_render);
                        removeClassName(cell, 'autoInputCell');
                        return;
                    }
                    var newText = ExchangeToShortText(contentValue_render, inputSetting.shortTextLength);

                    updateElement(displayBlock , newText );
                    setEventObserve(displayBlock , 'click' , function (e) {
                        var target = getEventTarget(e);
                        target.style.display = 'none';
                        target.nextSibling.style.display = '';
                    } );
                    displayBlock.setAttribute('title', 'Åã¥Ü§¹¾ã¸ê°T');

                    updateElement(inputBlock, contentValue_render);
                    setEventObserve(inputBlock , 'click', function (e) {
                        var target = getEventTarget(e);
                        target.style.display = 'none';
                        target.previousSibling.style.display = '';
                    });

                    inputBlock.setAttribute('title', 'ÁôÂÃ§¹¾ã¸ê°T');
                    inputBlock.style.display = 'none';

                    displayBlock.style.cursor = "pointer";
                    inputBlock.style.cursor = "pointer";

                    addClassName(cell, 'doWrap');
                    return;

                default:
                    removeElement(displayBlock);
                    removeElement(inputBlock);
                    updateElement(cell, contentValue_render);
                    removeClassName(cell, 'autoInputCell');
                    return;
            }

            if (!isEasyEdit && getBoolean(inputSetting.genRule, true, [record, contentValue, serial_no])) {
                displayBlock.style.display = 'none';
            } else {
                inputBlock.style.display = 'none';
            }

            if (isEasyEdit) {
                displayBlock.setAttribute('title', '«ö¤@¤U§Ö³t½s¿è');

                var confirmEdit = createElement(
                    'div', 
                    { 'title': '½T»{­×§ï' },
                    null,
                    ['close_easyEdit'],
                    {
                        'click':function (e) {
                            var td = getCellByTagName( getEventTarget(e) , 'TD');
                            removeClassName(td , 'editing');
                            exchangeAutoInput(td, [td.getAttribute('name')], true);
                        }
                    } 
                );

                appendElement( cell , confirmEdit);

                displayBlock.style.cursor = "pointer";
                setEventObserve(displayBlock,'click', function (e) {
                    var td = getCellByTagName( getEventTarget(e) , 'TD');
                    addClassName(td, 'editing');
                    exchangeAutoInput(td, [td.getAttribute('name')], false);
                });
            }

            return;
        }

        /* ¤ÀªR³]©w¡A±N¸ê®Æ¨Ì·ÓÃþ«¬format */
        function doSettingRender(record, cell_setting, value, doRender , ignore_undefined) {
            // formatDatas
            var dataType = cell_setting.dataType;
            var serial_no = record['_tableuiSerialNumber'];
            if (!value && value !== false && value !== 0) {
                value = record[cell_setting.key];
                if (!value && value !== false && value !== 0) {
                    if (ignore_undefined === true && value === undefined) {
                        return value;
                    }
                    value = '';
                }
            }

            // get Pattern from attrs --> input.attrs
            var settingPattern = (dataType) && cell_setting.attrs && cell_setting.attrs.pattern;

            if (dataType) {
                dataType = dataType.toLowerCase();
                var isLocaleDisplayEnabled = hasLocaleDisplay && !settingPattern;
                if (isLocaleDisplayEnabled) {
                    switch (dataType) {
                        case 'number':
                            if (isNumeric(value)) {
                                value = localeDisplay.formatNumber(value, (cell_setting.attrs && cell_setting.attrs.scale));
                            }
                            break;
                        case 'date':
                            value = localeDisplay.formatDate(value);
                            break;
                        case 'datetime':
                            value = localeDisplay.formatTimestamp(value);
                            break;
                        case 'dateym':
                            value = localeDisplay.formatDateym(value);
                            break;
                        case 'datey':
                            value = localeDisplay.formatDatey(value);
                            break;
                        case 'rocdate':
                            isLocaleDisplayEnabled = false;
                    }
                }
            }

            if (value === null || value === undefined) {
                value = '';
            }

            var renderFunction = cell_setting.render;
            if (isFunction(doRender)) {
                renderFunction = doRender;
                doRender = true;
            }
            if (doRender !== false && isFunction(renderFunction)) {
                value = renderFunction(record, value, serial_no, cell_setting.key);
            } else if (dataType && !isLocaleDisplayEnabled) {
                switch (dataType) {
                    case 'number':
                        if (isObject(cell_setting.format) && isString(cell_setting.format.type)) {
                            var type = cell_setting.format.type.toLowerCase();
                            var kind = ( isString(cell_setting.format.kind) ? cell_setting.format.kind.toUpperCase() : '' ) || 'AMT';
                            var code = isString(cell_setting.format.code) ? cell_setting.format.code : '';
                            if (!code) {
                                code = isString(cell_setting.format.key) ? cell_setting.format.key : '';
                                if (code) {
                                    code = record[code];
                                }
                            }
                            if (code) {
                                if (type == 'im') {
                                    if (window['ImFormat'] && isFunction(window['ImFormat']['doFormat'])) {
                                        value = window['ImFormat']['doFormat']( kind , code , value, true);
                                        break;
                                    }
                                } else if (type == 'rc') {
                                    if (window['rcFormat'] && isFunction(window['rcFormat']['doFormat'])) {
                                        value = window['rcFormat']['doFormat'](kind, code, value, true);
                                        break;
                                    }
                                } else if (type == 'rz') {
                                    if (window['rzFormat'] && isFunction(window['rzFormat']['doFormat'])) {
                                        value = window['rzFormat']['doFormat'](code, value, true);
                                        break;
                                    }
                                }
                            }
                        }

                        if (window.CSRUtil && isNumeric(value)) {
                            var numberPattern = settingPattern || "#,##0.####";
                            value = CSRUtil.$fmt(value, numberPattern);
                        }
                        break;
                    case 'date':
                        if (!window.SimpleDateFormat) { break; }
                        if (!SimpleDateFormatSave[cell_setting.key]) {
                            var datePattern = settingPattern || "yyyy-MM-dd";
                            SimpleDateFormatSave[cell_setting.key] = new SimpleDateFormat(datePattern, SimpleDateFormat.US);
                        }
                        value = (SimpleDateFormatSave[cell_setting.key]).format(value);
                        break;
                    case 'rocdate':
                        if (!window.SimpleDateFormat) { break; }
                        if (!SimpleDateFormatSave[cell_setting.key]) {
                            var datePattern = settingPattern || "yyyMMdd";
                            SimpleDateFormatSave[cell_setting.key] = new SimpleDateFormat(datePattern, SimpleDateFormat.TW);
                        }
                        value = (SimpleDateFormatSave[cell_setting.key]).format(value);
                        break;
                    case 'datetime':
                        value = value + "";
                        if (value.length > 19) {
                            value = value.substr(0, 19);
                        }
                        break;

                }
            }

            if (isArray(value)) {
                //¬°°ò¥»«¬ºA¡A­Y¬Oarrayª½±µÂà¦¨string
                value = value + "";
            }

            /* ¹LÂo¯S®í¿ù»~µ²ªG¡A°£¤FFalse family¥~¡A¤]³B²zfamily³QÂà«¬¦¨stringªºª¬ºA... */
            if (value === null || value=== undefined || value === Number.NaN || value == 'NaN' || value == 'undefined' || value == 'null' || value ==='') {  
                value = isBasicType(cell_setting.whenDataNull) ? cell_setting.whenDataNull : dataWhenNULL;
            }

            value = trim(value);

            /* ³B²z²Å¸¹­Ì */
            if (isString(value)) {
                value = value.replace(/&/gi, '&amp;').replace(/amp;amp;/gi, 'amp;');
                value = value.replace(/<br>/gi, '\n').replace(/<\/br>/gi, '\n').replace(/<br.*?\/>/gi, '\n');
                //value = value.replace(/</gi, '&lt;');
                //value = value.replace(/>/gi, '&gt;');
                value = value.replace(/\n/g, '</br>');
            }
            return value;
        }

        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®Æsn */
        this.getSerialNumber = getSerialNumber;
        function getSerialNumber(TR) {
            TR = getCellByTagName(TR, 'TR');
            var row_serialNo = TR.getAttribute("sn");
            if (!isNumeric(row_serialNo)) { return; }
            return row_serialNo;
        }
        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®Æsn(¸óÄæ¨ú±o¦h­Ó) */
        this.getSerialNumbers = getSerialNumbers;
        function getSerialNumbers(inputNode) {
            var td = getCellByTagName(inputNode, 'TD');
            if (!td) {
                var findfromTR = getSerialNumber(inputNode);
                return isNumeric(findfromTR) ? [findfromTR] : [];
            }
            var records_sn = td.getAttribute("sn");
            if (records_sn !== 0 && (!records_sn || records_sn == "null" || records_sn == "undefined")) {
                var findfromTR = getSerialNumber(inputNode);
                return isNumeric(findfromTR) ? [findfromTR] : [];
            }
            return (records_sn + "").split(',');
        }

        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®ÆDataObj */
        this.getRecordByCell = getRecordByCell;
        function getRecordByCell(td, dataExpireAlert) {
            var dataObjs = getRecordsByCell(td, dataExpireAlert);
            if (isArray(dataObjs) && dataObjs.length > 0) { return dataObjs[0]; }
            return null;
        }
        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®ÆDataObj(¸óÄæ¨ú±o¦h­Ó) */
        this.getRecordsByCell = getRecordsByCell;
        function getRecordsByCell(td, dataExpireAlert) {
            return pageControl.getRecordsBy(getSerialNumbers(td), null, dataExpireAlert);
        }

        /* -------------------- td cell ctrl -------------------- */
        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®ÆTDÄæ¦ì(¸óÄæ¨ú±o¦h­Ó)  */
        /* output: Array<Map<key, (cell / Array<cell>) >> */
        this.getThisRecordTD = getThisRecordTD;
        function getThisRecordTD(TR, template) {
            var row_serialNos = getSerialNumbers(TR);
            if (!isArray(row_serialNos) || row_serialNos.length == 0) { return []; }

            if (isString(template)) { template = [template]; }
            //if (!isArray(template)) { return []; }

            var getAll = !isArray(template);
            var returnList = [];

            for(var i = 0, maxCount = row_serialNos.length ; i < maxCount ; i++){
				var row_serialNo = row_serialNos[i];
                if (!isNumeric(row_serialNo)) { return; } 
                var tds = selectElement(dataArea , "TR[sn=" + row_serialNo + "] td" );
                if (!tds || !tds.length) { return; }

                if (getAll) {
                    returnList.push(getMapFormDomList(tds, "name"));
                } else {
                    var newList = [];
                    for (var i = 0 ; i < template.length ; i++) {
                        var filter_key = trim(template[i]);
                        if (!filter_key) { continue; }
                        for (var j = 0 ; j < tds.length ; j++) {
                            var td_key = tds[j].getAttribute("name");
                            if (filter_key == td_key) {
                                newList.push(tds[j]);
                            }
                        }
                    }
                    returnList.push(getMapFormDomList(newList, 'name'));
                }
            };
            return returnList;
        }

        /* ­×§ïTDÄæ¦ì­È(¤]·|­×¥¿dataObj) */
        this.setValueToTD = setValueToTD;
        function setValueToTD(TR, target_name, value) {
            var targets = getThisRecordTD(TR, target_name);
            var records = getRecordsByCell(TR);
            if (records) {
                for (var i = 0 ; i < records.length ; i++) {
                    records[i][target_name] = value;
                }
            }
            if (!targets || !targets.length) { return; }
            for (var t = 0 ; t < targets.length ; t++) {
                target = targets[t][target_name];
                if (!target) { continue; }
                if (isArray(target)) {
                    for (var i = 0 ; i < target.length ; i++) {
                        updateValueToCell(target[i], value);
                    }
                } else {
                    updateValueToCell(target, value);
                }
            }
        }
        /* °õ¦æformat¨Ã³]­È¦Ücell*/
        function updateValueToCell(node, value) {
            if (!isElement(node)) { return; }
            node.innerHTML = doSettingRender(getRecordByCell(node), settingCtrl.getRecordColSetting(node), value);
        }

        /* -------------------- autoInput cell ctrl -------------------- */
        /* ¨Ì·Ó¿é¤JDOM¡A¨ú±o¸Ó¸ê®ÆautoInputÄæ¦ì(¸óÄæ¨ú±o¦h­Ó)  */
        /* output: Array<Map<key, (cell / Array<cell>) >> */
        this.getAutoInput = getAutoInput;
        function getAutoInput(TR, template) {
            var row_serialNos = getSerialNumbers(TR);
            if (!isArray(row_serialNos) || row_serialNos.length == 0) { return []; }

            if (isString(template)) { template = [template]; }
            //if (!isArray(template)) { return []; }

            var getAll = !isArray(template);
            var returnList = [];

			for(var i=0, maxCount = row_serialNos.length ; i < maxCount ; i++){
				var row_serialNo = row_serialNos[i];
                if (!isNumeric(row_serialNo)) { return; }
                var inputs = selectElement( dataArea , "TR[sn=" + row_serialNo + "] *[tableui_key]");
				
                if (!inputs || !inputs.length) { return; }

                if (getAll) {
                    returnList.push(getMapFormDomList(inputs, "tableui_key"));
                } else {
                    var newList = [];
                    for (var i = 0 ; i < template.length ; i++) {
                        var filter_key = trim(template[i]);
                        if (!filter_key) { continue; }
                        for (var j = 0 ; j < inputs.length ; j++) {
                            var input_key = inputs[j].getAttribute("tableui_key");
                            if (filter_key == input_key) {
                                newList.push(inputs[j]);
                            }
                        }
                    }
                    returnList.push(getMapFormDomList(newList, "tableui_key"));
                }
            }
            return returnList;
        }

        /* ¤Á´« autoInput Äæ¦ì */
        this.exchangeAutoInput = exchangeAutoInput;
        function exchangeAutoInput(TR, template, isCloseInput) {

            var inputs = getAutoInput(TR, template);

            isCloseInput = (isCloseInput !== true && isCloseInput !== false) ? null : isCloseInput;

            for (var t = 0 ; t < inputs.length ; t++) {
                for (var key in inputs[t]) {
                    var dom = inputs[t][key];
                    if (isElement(dom)) {
                        exchangeOneCell(dom, isCloseInput);
                    } else if (isArray(dom)) {
                        for (var i = 0 ; i < dom.length ; i++) {
                            var array_dom = dom[i];
                            if (isElement(array_dom)) {
                                exchangeOneCell(array_dom, isCloseInput);
                            }
                        }
                    }
                }
            }
            sizeController.doResize('exchangeInput');
        }

        /* ¤Á´« autoInput Äæ¦ì */
        function exchangeOneCell(input, isCloseInput) {
            var inputdiv = getParentByTagName(input, "div");
            while (!hasClassName(inputdiv, 'inputBlock')) {
                inputdiv = getParentByTagName(inputdiv, "div");
            }
            var textdiv = inputdiv.previousSibling;
            if (textdiv.getAttribute("type") == "textNode" && inputdiv.getAttribute("type") == "inputNode") {
                isCloseInput = (isCloseInput === null) ? textdiv.style.display == "none" : isCloseInput;
                textdiv.style.display = isCloseInput ? "" : "none";
                inputdiv.style.display = !isCloseInput ? "" : "none";
            }
        }

        /* §PÂ_²{¦bªºinput¬O§_Ãö³¬ª¬ºA */
        this.isAutoInputHidden = isAutoInputHidden;
        function isAutoInputHidden(input) {
            var inputdiv = getParentByTagName(input, "div");
            while (inputdiv && !hasClassName(inputdiv, 'inputBlock')) {
                inputdiv = getParentByTagName(inputdiv, "div");
            }
            if (!inputdiv) {  return null; }
            return inputdiv.style.display != 'none';
        }

        /* µL®Ä¤Æ autoInput Äæ¦ì */
        this.disableAutoInput = disableAutoInput;
        function disableAutoInput(TR, template, isDisabled) {

            var inputs = getAutoInput(TR, template);

            isDisabled = (isDisabled !== true && isDisabled !== false) ? null : isDisabled;

            for (var t = 0 ; t < inputs.length ; t++) {
                for (var key in inputs[t]) {
                    var dom = inputs[t][key];
                    if (isElement(dom)) {
                        if (isDisabled !== null) {
                            dom.disabled = isDisabled;
                        } else {
                            dom.disabled = !dom.disabled;
                        }
                    } else if (isArray(dom)) {
                        for (var i = 0 ; i < dom.length ; i++) {
                            var array_dom = dom[i];
                            if (isElement(array_dom)) {
                                if (isDisabled !== null) {
                                    array_dom.disabled = isDisabled;
                                } else {
                                    array_dom.disabled = !array_dom.disabled;
                                }
                            }
                        }
                    }
                }
            }
            sizeController.doResize('disableInput');
        }

        /* ­×§ïautoInputÄæ¦ì­È(¤]·|­×¥¿dataObj) */
        this.setValueToAutoInput = setValueToAutoInput;
        function setValueToAutoInput(TR, target_name, value) {
            var targets = getAutoInput(TR, target_name);
            if (!targets || !targets.length) {
                /*­Y¨S¦³§ä¨ìautoinput¡A¶i¦æ§ó·sTD*/
                setValueToTD(TR, target_name, value);
                return;
            }
            for (t = 0 ; t < targets.length ; t += 1) {
                var target = targets[t][target_name]
                if (isArray(target)) {
                    for (var i = 0 ; i < target.length ; i++) {
                        updateValueToAutoInput(target[i], value);
                    }
                } else {
                    updateValueToAutoInput(target, value);
                }
            }
        }
        /* °õ¦æformat¨Ã³]­È¦ÜautoInput */
        function updateValueToAutoInput(dom, value) {
            if (!isElement(dom)) { return; }
            var testDisabled = dom;
            while (isElement(testDisabled) && testDisabled.tagName != "TD") {
                if (testDisabled.style.display == 'none') {
                    return;
                }
                testDisabled = testDisabled.parentNode;
            }
            var target_type = (dom.getAttribute("type") || "").toLowerCase();
            if ((target_type == 'checkbox' || target_type == 'radio')) {
                if(value === true || value == 'Y' ){
                    dom.checked = true;
                    fireEventObserving(dom, 'click');
                    return;
                }

                if(value === false || value == 'N' ){
                    dom.checked = false;
                    fireEventObserving(dom, 'click');
                    return;
                }

                var hasValue = value !== null && value !== undefined && value !== ''; 

                if(hasValue && dom.getAttribute('value') === value) {
                    dom.checked = true;
                    fireEventObserving(dom, 'click');
                    return;
                }

                value = value + '';
                
                selectElementThenEach(dataArea , 'input[name='+dom.getAttribute('name')+']' , function(sn , elem){
                    var isValueEquals = (value == elem.getAttribute('value'));
                    if(!hasValue){
                        if(elem.checked){
                            elem.checked = false;
                            (target_type == 'checkbox') && fireEventObserving(elem, 'click');
                            return;
                        }
                    }else if( isValueEquals ){
                        elem.checked = true;
                        fireEventObserving(elem, 'click');
                        return;
                    }
                    
                });
                
            } else if (dom.tagName == "BUTTON" || target_type == 'button') {
                fireEventObserving(dom, 'click');
            } else {
                if (dom.tagName == "TEXTAREA") {
                    dom.innerHTML = value;
                } else {
                    if (isFunction(dom.setValue)) {
                        dom.setValue(value);
                    } else {
                        dom.value = value;
                    }
                }

                if ((dom.getAttribute('datatype') + '').toLowerCase() == 'number') {
                    //fireEventObserving(dom, 'blur');
                    var isDisabled = dom.disabled;
                    dom.disabled = false;
                    dom.focus();
                    dom.blur();
                    dom.disabled = isDisabled;
                } else {
                    fireEventObserving(dom, 'change');
                }
            }
        }

        /* ±NList«¬ºA¸ê®Æ¨Ì«ü©wkey ®æ¦¡¤Æ¦¨Map®æ¦¡ */
        function getMapFormDomList(domList, attr_key) {
            if (!isArray(domList) || !domList.length) { return {}; }
            var rtn_map = {};
            for (var i = 0 ; i < domList.length ; i++) {
                var dom = domList[i];
                if (!isElement(dom)) { continue; }
                var dom_key = trim(dom.getAttribute(attr_key));

                var otherDomAtMap = rtn_map[dom_key];
                if (otherDomAtMap) {
                    if (isArray(otherDomAtMap)) {
                        otherDomAtMap.push(dom);
                    } else {
                        rtn_map[dom_key] = [otherDomAtMap, dom];
                    }
                } else {
                    rtn_map[dom_key] = dom;
                }
            }
            return rtn_map;
        }

        /* -------------------- autoCheckBox ctrl -------------------- */
        /* §PÂ_¬O§_¸Óµ§¸ê®Æ¤w¿ï¾Ü  */
        this.isAutoCheckBoxSelected = isAutoCheckBoxSelected;
        function isAutoCheckBoxSelected(td) {
            var dataObjs = getRecordsByCell(td);
            if (!dataObjs || !dataObjs.length) { return false; }
            return !!(dataObjs[0]['_tableuiAutoCheckBoxResult'] >= 0);
        }

        /* °õ¦æ¥þ¿ï«ö¶s(¶È³]©w¸ê®Æ) */
        this.autoCheckBoxSelectAll = autoCheckBoxSelectAll;
        function autoCheckBoxSelectAll(isChecked) {

            var records = pageControl.getAllRecords();
            if (!isArray(records) || !records.length) {
                return;
            }

            if (isChecked !== true && isChecked !== false) {
                isChecked = settingCtrl.settings.checkAllBox.checked;
            }
            
            selectElementThenEach( dataArea ,"table tbody input.autoCheckBox_" + table_id ,
				function (sn , elem) {
				    if (!elem.disabled) {
				        elem.checked = isChecked;
				    }
				}
			);

            for (var i = 0 ; i < records.length ; i += 1) {
                if (records[i]['_tableuiAutoCheckBoxResult'] == 1 || records[i]['_tableuiAutoCheckBoxResult'] == -1) {
                    records[i]['_tableuiAutoCheckBoxResult'] = isChecked ? 1 : -1;
                }
            }

            checkCheckAllStatus();
        }

        this.setCurrentPageAutoCheckBox = setCurrentPageAutoCheckBox;
        function setCurrentPageAutoCheckBox(check_status) {
            var currentRecords = pageControl.getCurrentPageRecords();
            if (!isArray(currentRecords) || !currentRecords.length) {
                return;
            }

            check_status = !!check_status;

            selectElementThenEach( dataArea , "table tbody input.autoCheckBox_" + table_id , 
				function (sn , elem) {
				    if (!elem.disabled) {
				        elem.checked = check_status;
				    }
				}
			);

            for (var i = 0 ; i < currentRecords.length ; i += 1) {
                if (currentRecords[i]['_tableuiAutoCheckBoxResult'] == 1 || currentRecords[i]['_tableuiAutoCheckBoxResult'] == -1) {
                    currentRecords[i]['_tableuiAutoCheckBoxResult'] = check_status ? 1 : -1;
                }
            }

            checkCheckAllStatus();

        }

        /* ³]©w³æ¤@«ö¶sª¬ºA */
        this.setAutoCheckBoxByValue = setAutoCheckBoxByValue;
        function setAutoCheckBoxByValue(findValue, check_status) {
            if (!isString(findValue)) { return; }
            if (!settingCtrl.settings.autoCheckBoxKey) { return; }

            check_status = getBoolean(check_status, !!check_status);
            selectElementThenEach(dataArea, "table tbody input.autoCheckBox_" + table_id, function (sn, elem) {
                if((elem.getAttribute('autoCheckBoxValue')+'') != findValue ){
                    return;
                }
                if (elem.checked != check_status) {
                    elem.checked = check_status;
                    autoCheckBoxSingle(elem);
                }
            }
			);
        }

        this.setThisAutoCheckBox = setThisAutoCheckBox;
        function setThisAutoCheckBox(td, checkStatus) {
            var chk_box = getAutoCheckBoxByElement(td);
            if (!chk_box) { return; }
            if (checkStatus != chk_box.checked) {
                chk_box.checked = checkStatus;
                autoCheckBoxSingle(chk_box);
            }
        }

        this.showAutoCheckBox = showAutoCheckBox;
        function showAutoCheckBox( td , checkStatus ) {
            var chk_box = getAutoCheckBoxByElement(td);
            if (!chk_box) { return; }
            chk_box.style.display = '';
            if (checkStatus != chk_box.checked) {
                chk_box.checked = checkStatus;
                autoCheckBoxSingle(chk_box);
            }
        }

        this.hideAutoCheckBox = hideAutoCheckBox;
        function hideAutoCheckBox(td, checkStatus) {
            var chk_box = getAutoCheckBoxByElement(td);
            if (!chk_box) { return; }
            chk_box.style.display = 'none';
            if (checkStatus !== true || checkStatus !== false) {
                checkStatus = false;
            }
            if (checkStatus != chk_box.checked) {
                chk_box.checked = checkStatus;
                autoCheckBoxSingle(chk_box);
            }
        }

        function getAutoCheckBoxByElement(td) {
            var sn = getSerialNumber(td);
            while ( sn > 0) {
                var find_chk = selectElement(dataArea , "table tbody input#autoCheckBox_" + table_id + "_"+sn);
                if (find_chk.length > 0) {
                    return find_chk[0];
                } else {
                    sn--;
                }
            }
            return null;
        }

        /* ÂI¿ï³æ¤@«ö¶sª¬ºA°Ê§@ */
        var previousRadio = null;
        var previousRecords = null;

        this.autoCheckBoxSingle = autoCheckBoxSingle;
        function autoCheckBoxSingle(e) {

            var checkBox = getEventTarget(e);

            var isChecked = checkBox.checked;
            var key = settingCtrl.settings.autoCheckBoxKey;
            var value = checkBox.getAttribute("value");
            var isTypeRadio = checkBox.getAttribute("type").toLowerCase() == "radio";

            var records = dataControl.getRecordsByCell(checkBox);
            var allRecords = pageControl.getAllRecords();

            var autoCheckAction = isFunction(settingCtrl.settings.autoCheckAction) ? settingCtrl.settings.autoCheckAction : false;
            // 1 = checked
            // 0 = checked & disabled
            // -1 = unchecked
            // -2 = unchecked & disabled
            //-99 = no this Element
            if (isTypeRadio) {
                //Radio«¬ºA¡A¥ý§â¥þ³¡Âk¹s¡A¦A§ó·s¥»¦¸¡Cradio¤£·|¦³uncheckªº°ÝÃD¡A¦ý·|¦³¨ú®øªºª«¥ó¤]­n§ó·sª¬ºA
                for (var i = 0 ; i < allRecords.length ; i += 1) {
                    var tableuiAutoCheckBoxResult = allRecords[i]['_tableuiAutoCheckBoxResult'];
                    if (isNumeric(tableuiAutoCheckBoxResult)) {
                        tableuiAutoCheckBoxResult = parseInt(tableuiAutoCheckBoxResult);
                    } 
                    if (tableuiAutoCheckBoxResult === 0 || tableuiAutoCheckBoxResult === 1) {
                        allRecords[i]['_tableuiAutoCheckBoxResult'] = tableuiAutoCheckBoxResult - 2;
                    }
                }

                /*³Q¨ú®ø¿ï¨úªºÄæ¦ì*/
                if (previousRadio && previousRecords) {
                    var now_record = dataControl.getRecordsByCell(previousRadio,false);
                    if (now_record && now_record.length > 0 && previousRecords.length == now_record.length) {
                        var isThisTableUIDatas = true;
                        for (var m = 0 ; m < now_record.length ; m++) {
                            if (now_record[m] != previousRecords[m]) {
                                isThisTableUIDatas = false;
                            }
                        }
                        if (isThisTableUIDatas) {
                            previousRadio.checked = false;
                            if (autoCheckAction) {
                                autoCheckAction.call(previousRadio, previousRadio, false, now_record);
                            }

                            if (previousRadio.checked) {
                                // ­Y¿ï¨ú³Q¨Ï¥ÎªÌ¦b¦Û©w¨ç¦¡¤¤´_­ì¡AÂ÷¶}±µ¤U¨Óªº°Ê§@¡C
                                for (var i = 0 ; i < now_record.length ; i += 1) {
                                    var tableuiAutoCheckBoxResult = records[i]['_tableuiAutoCheckBoxResult'];
                                    if (isNumeric(tableuiAutoCheckBoxResult)) {
                                        tableuiAutoCheckBoxResult = parseInt(tableuiAutoCheckBoxResult);
                                    }
                                    if (tableuiAutoCheckBoxResult === -1 || tableuiAutoCheckBoxResult === -2) {
                                        records[i]['_tableuiAutoCheckBoxResult'] = tableuiAutoCheckBoxResult + 2;
                                    }
                                }
                                return;
                            }

                            if (previousRadio == checkBox) {
                                // ­Y¬OÂI¿ï¨ì«e­±¤@¦¸ªº¿ï¾Ü¡A²M°£«áÂ÷¶}
                                previousRadio = null;
                                previousRecords = null;
                                return;
                            }
                        }
                    }
                }

               
                
                /*³]©w³o¦¸¿ï¨ú*/
               
                previousRadio = checkBox;
                previousRecords = records;
                for (var i = 0 ; i < records.length ; i += 1) {
                    var tableuiAutoCheckBoxResult = records[i]['_tableuiAutoCheckBoxResult'];
                    if (isNumeric(tableuiAutoCheckBoxResult)) {
                        tableuiAutoCheckBoxResult = parseInt(tableuiAutoCheckBoxResult);
                    }
                    if (tableuiAutoCheckBoxResult === -1 || tableuiAutoCheckBoxResult === -2) {
                        records[i]['_tableuiAutoCheckBoxResult'] = tableuiAutoCheckBoxResult + 2;
                    }
                }
                
                if (autoCheckAction) {
                    autoCheckAction.call(checkBox, checkBox, true, records);
                }

            } else {
                //checkbox«¬ºA¡A¶È³B²z¸ê®Æ¡F
                for (var i = 0 ; i < records.length ; i += 1) {
                    var tableuiAutoCheckBoxResult = records[i]['_tableuiAutoCheckBoxResult'];
                    if (isNumeric(tableuiAutoCheckBoxResult)) {
                        tableuiAutoCheckBoxResult = parseInt(tableuiAutoCheckBoxResult);
                    }
                    if (isChecked && tableuiAutoCheckBoxResult === -1 || tableuiAutoCheckBoxResult === -2) {
                        records[i]['_tableuiAutoCheckBoxResult'] = tableuiAutoCheckBoxResult + 2;
                    } else if (!isChecked && tableuiAutoCheckBoxResult === 0 || tableuiAutoCheckBoxResult === 1) {
                        records[i]['_tableuiAutoCheckBoxResult'] = tableuiAutoCheckBoxResult - 2;
                    }
                }

                if (autoCheckAction) {
                    autoCheckAction.call(checkBox, checkBox, !!checkBox.checked, records);
                }

                checkCheckAllStatus();
            }

          

        }

        /* §PÂ_²{¦b¬O§_¤w¥þ¿ï */
        this.checkCheckAllStatus = checkCheckAllStatus;
        function checkCheckAllStatus() {
            if (!settingCtrl.settings.checkAllBox) { return; }
            settingCtrl.settings.checkAllBox.checked = false;
            settingCtrl.settings.checkAllBox.disabled = true;

            var allRecords = pageControl.getAllRecords();
            if (!allRecords || !allRecords.length) { return; }

            var has0 = false;
            var has1 = false;
            var hasCheckable = false;
            for (var i = 0 ; i < allRecords.length ; i += 1) {
                var rec_checkStatus = parseInt(allRecords[i]['_tableuiAutoCheckBoxResult'], 10);
                if (rec_checkStatus == 1 || rec_checkStatus === -1) {
                    hasCheckable = true;
					if (rec_checkStatus == 1 ) {
						has1 = true;
					} else {
						has0 = true;
					}	
				}

				if (has0 && has1 && hasCheckable) {
                    break;
                }
            }
            settingCtrl.settings.checkAllBox.checked = !has0 && has1;
            settingCtrl.settings.checkAllBox.disabled = !hasCheckable;

        }

        /*  ------------  °ª«×compare functions ------------ */
        /* §PÂ_¨â­Ótable°ª«×¬O§_¤@¼Ë */
        this.compareAllTableCellHeight = compareAllTableCellHeight;
        function compareAllTableCellHeight() {
            compareCellHeight(main_table_head, fixed_table_head);
            var main_table_tBodies = main_table.tBodies;
            var fixed_table_tBodies = fixed_table.tBodies;
            for (var i = 0 ; i < main_table_tBodies.length ; i += 1) {
                compareCellHeight(main_table_tBodies[i], fixed_table_tBodies[i]);
            }
            compareCellHeight(main_table.tFoot, fixed_table.tFoot);
        }

        /*±N¨â­Ó thead tbody tfoot¦æ°ª©T©w*/
        function compareCellHeight(parent1, parent2) {
            if (!parent1 || !parent2) { return; }
            if (!parent2.hasChildNodes() || !parent1.hasChildNodes()) { return; }

            var line_1 = parent1.firstChild;
            var line_2 = parent2.firstChild;
            var buffer_line_1 = 0;
            var buffer_line_2 = 0;
            var saved_line_1 = [];
            var saved_line_2 = [];

            while (line_1 && line_2) {
                if (buffer_line_1 == 0) {
                    line_1.style.height = '';
                    saved_line_1.push(line_1);
                    buffer_line_1 = parseInt(line_1.getAttribute("minRowSpan") || 1, 10);
                }

                if (buffer_line_2 == 0) {
                    line_2.style.height = '';
                    saved_line_2.push(line_2);
                    buffer_line_2 = parseInt(line_2.getAttribute("minRowSpan") || 1, 10);
                }

                while (buffer_line_1 > 0 && buffer_line_2 > 0) {
                    buffer_line_1--;
                    buffer_line_2--;
                }

                if (buffer_line_1 == 0 && buffer_line_2 == 0) {
                    var height1 = getOffsetHeightOfLines(saved_line_1);
                    var height2 = getOffsetHeightOfLines(saved_line_2);

                    var setHeight = Math.max(height1, height2, 0);

                    setHeightOfLines(saved_line_1, setHeight);
                    setHeightOfLines(saved_line_2, setHeight);
                }

                if (buffer_line_1 == 0) {
                    line_1 = line_1.nextSibling;
                }

                if (buffer_line_2 == 0) {
                    line_2 = line_2.nextSibling;
                }
            }
        }

        /* ¬Û¹ï³Ì°ª°ª«×*/
        function getOffsetHeightOfLines(saved_lines) {
            var height = 0;
            for (var i = 0 ; i < saved_lines.length ; i++) {
                height += saved_lines[i].offsetHeight;
            }
            return height;
        }

        /* ¹ïtr³]©w°ª«× */
        function setHeightOfLines(saved_lines, max_height) {
            saved_lines.sort(function (cell_1, cell_2) {
                var compare1 = cell_1.offsetHeight;
                compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
                var compare2 = cell_2.offsetHeight;
                compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
                return compare1 - compare2;
            });

            for (var j = saved_lines.length ; j > 0  ; j--) {
                var workingNode = saved_lines[j - 1];
                var guess_height = Math.max(parseInt(max_height / j, 10), workingNode.offsetHeight);
                workingNode.style.height = guess_height + "px";
                max_height -= guess_height;
            }

            saved_lines.splice(0, saved_lines.length);
        }

        /*  ------------  ·Æ¹«·Æ¹LÅÜ¦â functions ------------ */
        var bodyHighlight;
        var bodyHighlight_saved;
        var waitToRemoveHighlight;
        function bodyMouseMoveOver(e) {
            var target = getEventTarget(e);
            target = target && getParentByTagName(target, "tr");
            if (!target) { return; }

            var body_serial_no = target.getAttribute("sn");
            if (hasJsFramework && bodyHighlight != body_serial_no) {
                //console.log("highlight"+body_serial_no);
                selectElementThenEach(dataArea , "tr[sn='" + body_serial_no + "']" , function (sn , element) {
                    addClassName(element, "recordHighlight");
                });

            }
            bodyHighlight = body_serial_no;
            bodyHighlight_saved = body_serial_no;
        }

        function bodyMouseMoveOut(e) {
            if (waitToRemoveHighlight) { removeHighlight(); }
            waitToRemoveHighlight = bodyHighlight_saved;
            bodyHighlight_saved = null;
            setTimeout(removeHighlight, 2);
        }

        function removeHighlight() {
            if (isNumeric(waitToRemoveHighlight)) {
                if (bodyHighlight_saved === null || waitToRemoveHighlight !== bodyHighlight) {
                    //console.log("remove"+waitToRemoveHighlight);
                    selectElementThenEach(dataArea , "tr[sn='" + waitToRemoveHighlight + "']" , function (sn , element) {
                        removeClassName(element, "recordHighlight");
                    });
                    if (bodyHighlight_saved === null) {
                        bodyHighlight = null;
                    }
                }
                waitToRemoveHighlight = null;
            }
        }

        function bodyMouseClick(e) {
            var target = getEventTarget(e);
            if (!target || target.tagName != 'TD'){
                return;
            }
            target =  getParentByTagName(target, "tr");
            if (!target) { return; }
            
            var body_serial_no = target.getAttribute("sn");
            var isCancel = false;
            if (hasJsFramework) {
                //console.log("select"+body_serial_no);
                selectElementThenEach(dataArea , "tr[sn='" + body_serial_no + "']" , function (sn ,element) {
                    if (hasClassName(element, "recordSelected")) {
                        removeClassName(element, "recordSelected");
                        removeClassName(element, "error_recordSelected");
                        isCancel = true;
                    } else {
                        addClassName(element, "recordSelected");
                        if (hasClassName(element, "error_record")) {
                            addClassName(element, "error_recordSelected");
                        }
                    }
                });
            }

            if (rowClick && (!isCancel || !hasJsFramework)) {
                rowClick(target, getRecordByCell(target), body_serial_no);
            }
        }

        /* ------------ Event±Æ§Ç¨Æ¥ó ------------ */
        function sortData(e) {
            var target = getEventTarget(e);
            if (target.tagName != "A") {
                target = target.parentNode;
            }
            sortDetail(target.getAttribute("key"), target.innerHTML == SORT_DECREASE, target.getAttribute("rule"));
        }

        this.sort = function (key, isIncrease, sortRule) {
            if (isIncrease === true || isIncrease === false) {
                sortDetail(key, isIncrease, sortRule);
            } else {
                sortDetail(key, isIncrease != SORT_DECREASE, sortRule);
            }
        };

        /* ±Æ§Ç¥DÅé */
        function sortDetail(key, isIncrease, sortRule) {
            if (!isBasicType(key)) { return; }
            
            sortGroupKeys = [];
            if (settings.allGroupKeys) {
                for (var i = 0 ; i < settings.allGroupKeys.length ; i += 1) {
                    if (isInArray(settings.allGroupKeys[i], key) >= 0) { break; }
                    sortGroupKeys = sortGroupKeys.concat(settings.allGroupKeys[i]);
                }
            }
            sortGroupKeys.push(key);

            isIncrease = !!isIncrease;

            var records = pageControl.getAllRecords();

            sortRule = sortRule && (sortRule + "").toLowerCase();

            if (sortRule == "number") {
                records.sort(isIncrease ? sortByNumericIncrease : sortByNumericDecrease);
            } else if (sortRule == "date" || sortRule == "rocdate") {
                records.sort(isIncrease ? sortByDateIncrease : sortByDateDecrease);
            } else {
                records.sort(isIncrease ? sortByStringIncrease : sortByStringDecrease);
            }

            setSortRule(key, isIncrease, sortRule);
            pageControl.reLoadin(records);

            var sort_elements = main_table_head.getElementsByTagName("th");

            for (var i = 0 ; i < sort_elements.length ; i += 1) {
                var elem = sort_elements[i];
                removeClassName(elem, "sort_az");
                removeClassName(elem, "sort_za");
                if (elem.getAttribute("name") == key) {
                    addClassName(elem, isIncrease ? "sort_az" : "sort_za");
                }
            }
            sort_elements = fixed_table_head && fixed_table_head.getElementsByTagName("th");

            for (var i = 0 ; i < sort_elements.length ; i += 1) {
                var elem = sort_elements[i];
                removeClassName(elem, "sort_az");
                removeClassName(elem, "sort_za");
                if (elem.getAttribute("name") == key) {
                    addClassName(elem, isIncrease ? "sort_az" : "sort_za");
                }
            }
        }

        this.sortGroup = sortGroup;
        function sortGroup( group_data ) {
            if (!sortRules || sortRules.length == 0) { return null; }
            var sortRule_map = sortRules[sortRules.length - 1];
            
            var key = sortRule_map.key;
            var sortRule = sortRule_map.sortRule;
            var isIncrease = sortRule_map.direction;
            
            sortGroupKeys = [key];
            if (sortRule == "number") {
                group_data.sort(isIncrease ? sortByNumericIncrease : sortByNumericDecrease);
            } else if (sortRule == "date" || sortRule == "rocdate") {
                group_data.sort(isIncrease ? sortByDateIncrease : sortByDateDecrease);
            } else {
                group_data.sort(isIncrease ? sortByStringIncrease : sortByStringDecrease);
            }

        }

        /* ½T©w¸ê®Æ¬O§_¬°¦P¤@GROUP */
        function checkIsGroup(rec1, rec2) {
            if (!sortGroupKeys || sortGroupKeys.length == 1) { return sortGroupKeys[0]; }
            for (var i = 0 ; i < sortGroupKeys.length - 1 ; i += 1) {
                var key = sortGroupKeys[i];
                if (rec1[key] !== rec2[key]) {
                    return false;
                }
            }
            return sortGroupKeys[sortGroupKeys.length - 1];
        }

        /* ±Æ§Ç¼Æ¦r³W«h */
        function sortByNumericIncrease(rec1, rec2) {
            if (isArray(rec1)) {
                rec1 = rec1[0];
                rec2 = rec2[0];
            } 
            var key = checkIsGroup(rec1, rec2);
            if (!key) { return 0; }
            var compare1 = rec1[key];
            compare1 = isNumeric(compare1) ? parseFloat(compare1) : 0;
            var compare2 = rec2[key];
            compare2 = isNumeric(compare2) ? parseFloat(compare2) : 0;
            return compare1 - compare2;
        }
        function sortByNumericDecrease(rec1, rec2) { return sortByNumericIncrease(rec2, rec1); }

        /* ±Æ§Ç¤é´Á³W«h */
        function sortByDateIncrease(rec1, rec2) {
            if (!window.isADdate) { return sortByStringIncrease(rec1, rec2); }
            if (isArray(rec1)) {
                rec1 = rec1[0];
                rec2 = rec2[0];
            }
            var key = checkIsGroup(rec1, rec2);
            if (!key) { return 0; }
            var compare1 = rec1[key];
            compare1 = compare1 && isADdate(compare1) ? compare1 : "1900-01-01";
            var compare2 = rec2[key];
            compare2 = compare2 && isADdate(compare2) ? compare2 : "1900-01-01";
            return diffDay(compare1, compare2, false) * -1;
        }
        function sortByDateDecrease(rec1, rec2) { return sortByDateIncrease(rec2, rec1); }

        /* ±Æ§Ç¤å¦r³W«h */
        function sortByStringIncrease(rec1, rec2) {
            if (isArray(rec1)) {
                rec1 = rec1[0];
                rec2 = rec2[0];
            }
            var key = checkIsGroup(rec1, rec2);
            if (!key) { return 0; }
            var compare1 = rec1[key] || "";
            var compare2 = rec2[key] || "";
            return compare1 < compare2 ? -1 : 1;
        }
        function sortByStringDecrease(rec1, rec2) { return sortByStringIncrease(rec2, rec1); }

        /* ¨ú¥X¤w±Æ§Ç¸ê®Æ */
        function getSortRule(key) {
            if (sortRules.length == 0) { return null; }
            for (var i = 0 ; i < sortRules.length ; i += 1) {
                if (sortRules[i].key == key) {
                    return sortRules[i].direction;
                }
            }
            return null;
        }

        /* ¼W¥[¤@²Õ±Æ§Ç¸ê®Æ */
        function setSortRule(key, direction, sortRule) {
            if (sortRules.length != 0) {
                for (var i = 0 ; i < sortRules.length ; i += 1) {
                    if (sortRules[i].key == key) {
                        sortRules.splice(i, 1);
                        break;
                    }
                }
            }
            sortRules.push({ key: key, direction: direction, sortRule: sortRule });
        }

        /* ±Nµe­±¸ê®Æ²M°£ */
        this.clearRecordsBodies = clearRecordsBodies;
        function clearRecordsBodies() {
            if(sizeController){
                selectElementThenEach( dataArea , 'thead th' ,function(sn, elem){
                    elem.style.top = 0;
                });
                fixedDataArea.scrollTop = 0;
                displayDataArea.scrollTop = 0;
            }
            clearOneRecordsBodies(main_table);
            clearOneRecordsBodies(fixed_table);
        }
        /* ±Nµe­±¸ê®Æ²M°£ */
        function clearOneRecordsBodies(table) {
            var nodes = table.tBodies;
            for (var i = nodes.length - 1 ; i >= 0 ; i -= 1) {
                table.removeChild(nodes[i]);
            }
        }

        /* ¹ïrecords³]©wsn */
        this.setSerialNnmber = setSerialNnmber;
        function setSerialNnmber(records, sn_start_from) {

            if (!isNumeric(sn_start_from)) { sn_start_from = 0; }

            var setAutoCheckAllData = false;
            var autoCheckBoxsetting;

            if (config.autoCheckBox) {
                setAutoCheckAllData = true;
                autoCheckBoxsetting = isObject(config.autoCheckBox) ? config.autoCheckBox : {};
            }

            var hasCheckRule = setAutoCheckAllData && isFunction(autoCheckBoxsetting.checkRule);
            var canCheck = setAutoCheckAllData && autoCheckBoxsetting.type == 'radio' ? true : null;

            for (var i = 0 ; i < records.length ; i += 1) {
                //³]©w§Ç¸¹
                var sn = i + sn_start_from + 1;
                records[i]["_tableuiSerialNumber"] = sn;

                //³]©wautoCheckBoxª¬ºA
                if (setAutoCheckAllData) {
                    var checkResult = records[i]['_tableuiAutoCheckBoxResult'];
                    

                    if (!getBoolean(autoCheckBoxsetting.genRule, true, [records[i], sn])) {
                        checkResult = -99;
                    } else {
                        if (checkResult !== 1) {
                            checkResult = -1; //unChecked
                        }

                        if (hasCheckRule) {
                            var checkStatus = null;
                            if (checkResult === 1) {
                                checkStatus = true;
                            } else if (checkResult === -1) {
                                checkStatus = false;
                            }
                            checkResult = getBoolean(autoCheckBoxsetting.checkRule, false, [records[i], sn, checkStatus]) ? 1 : -1;
                        }

                        //­Y¬Oradio¡A¥u¯à³B²z¤@µ§¥´¤Ä
                        if ((checkResult === 1) && canCheck !== null) {
                            if (canCheck === false) {
                                checkResult = -1;
                            } else {
                                canCheck = false;
                            }
                        }

                        if (getBoolean(autoCheckBoxsetting.disableRule, false, [records[i], sn])) {
                            checkResult = checkResult - 1;
                        }
                    }
                    records[i]['_tableuiAutoCheckBoxResult'] = checkResult;
                }
            }
            checkCheckAllStatus();
        }

        /* ¨Ì·Ó¸ê®Ætemplate¨ú¥X»Ý­nªº¸ê®Æ */
        this.getRecordsByTemplate = getRecordsByTemplate;
        function getRecordsByTemplate(filterRecords, template) {
            if (isString(template)) {
                var tempRecords = [];
                for (var i = 0 ; i < filterRecords.length ; i += 1) {
                    var filterValue = filterRecords[i][template];
                    if (filterValue || filterValue === 0) {
                        tempRecords.push(filterValue);
                    }
                }
                return tempRecords;
            } else if (isArray(template)) {
                for (var i = template.length - 1 ; i >= 0 ; i -= 1) {
                    if (!isString(template[i])) {
                        template.splice(i, 1);
                    }
                }
                if (template.length) {
                    var rtnRecords = [];
                    for (var i = 0 ; i < filterRecords.length ; i += 1) {
                        var tempRecords = {};
                        for (var j = 0 ; j < template.length ; j += 1) {
                            tempRecords[template[j]] = filterRecords[i][template[j]];
                        }
                        rtnRecords.push(tempRecords);
                    }
                    return rtnRecords;
                }
            }
            return filterRecords;

        }

        /* ²M°£table¾Þ§@¾úµ{³]©w */
        this.clearTableInfo = clearTableInfo;
        function clearTableInfo() {
            sortRules = [];

            var sort_elements = main_table_head.getElementsByTagName("th");
            for (var i = 0 ; i < sort_elements.length ; i += 1) {
                var elem = sort_elements[i];
                removeClassName(elem, "sort_az");
                removeClassName(elem, "sort_za");
                elem.style.position = "";
                var menu = elem.lastChild;
                if (elem.tagName == "UL") {
                    menu.style.display = "none";
                }
            }

            sort_elements = fixed_table_head ? fixed_table_head.getElementsByTagName("th") : [];
            for (var i = 0 ; i < sort_elements.length ; i += 1) {
                var elem = sort_elements[i];
                removeClassName(elem, "sort_az");
                removeClassName(elem, "sort_za");
                elem.style.position = "";
                var menu = elem.lastChild;
                if (elem.tagName == "UL") {
                    menu.style.display = "none";
                }
            }

        }

        /* ¨ú±otable¾Þ§@¾úµ{³]©w */
        this.getTableInfo = getTableInfo;
        function getTableInfo(setPage, setSort) {
            var info = setPage !== false ? pageControl.getRecordsInfo() : {};

            settingCtrl.getFixedHiddenInfo(info);

            if (!settingCtrl.settings.isFatchMode && setSort !== false) {
                info.sortRecords = sortRules;
            }
            return info;
        }

        /* ³]©wtable¾Þ§@¾úµ{ */
        this.setTableInfo = setTableInfo;
        function setTableInfo(info) {
            if (isObject(info)) {
                settingCtrl.setFixedHiddenInfo(info);
                if (!settingCtrl.settings.isFatchMode && isArray(info.sortRecords)) {
                    for (var i = 0 ; i < info.sortRecords.length ; i += 1) {
                        sortDetail(info.sortRecords[i].key, info.sortRecords[i].direction, info.sortRecords[i].sortRule);
                    }
                }
                pageControl.setRecordsInfo(info);
            }
        }

        /* ¶×¥XXLS */
        this.exportToXLS = exportToXLS;
        function exportToXLS(fileName, records, isCount, bgColorType, sheetName) {

            if (!records || !records.length) {
                if (!fileName) {
                    return { sheetName: sheetName || "", isMultiCols: true, multiColsData: [[{ dataIndex: "", header: "", type: "copy", rowSpan: 0, colSpan: 0 }]], bgColorType: isNumeric(bgColorType) ? bgColorType : 1 };
                } else {
                    return false;
                }
            }

            var headerCol = settingCtrl.settings.headSetting;
            var recordCol = settingCtrl.settings.recordSetting;

            var exportData = [];
            var posit = 0;
            //alert(headerCol.length);
            for (var i = 0 ; i < headerCol.length ; i = i + 1) {
                exportData[posit] = [];
                for (var j = 0 ; j < headerCol[i].length ; j = j + 1) {
                    var columnSet = headerCol[i][j];
                    if (columnSet) {
                        //¤å¦r
                        var dataIndex = formatDataToText(columnSet.header);

                        exportData[posit].push({
                            dataIndex: dataIndex,
                            header: columnSet.key,
                            type: "string",
                            rowSpan: (columnSet.attrs && columnSet.attrs.rowSpan) ? columnSet.attrs.rowSpan : 1,
                            colSpan: (columnSet.attrs && columnSet.attrs.colSpan) ? columnSet.attrs.colSpan : 1
                        });
                    } else {
                        exportData[posit].push({ dataIndex: "", header: "", type: "copy", rowSpan: 0, colSpan: 0 });
                    }
                }
                posit = posit + 1;
            }

            //var groupColRec = new Hash();
            var setRec, preRec, nextRec;
            var bgColor = 1;
            var changeNextColor = false;
            //alert(records.length);
            for (var k = 0 ; k < records.length ; k = k + 1) {
                setRec = records[k];
                if (k < records.length - 1) {
                    nextRec = records[k + 1];
                } else {
                    nextRec = null;
                }

                if (k > 0) {
                    preRec = records[k - 1];
                } else {
                    preRec = null;
                }

                changeNextColor = true;
                for (var i = 0 ; i < recordCol.length ; i = i + 1) {
                    exportData[posit] = [];

                    for (var j = 0 ; j < recordCol[i].length ; j = j + 1) {
                        var setCol = recordCol[i][j];
                        if (setCol) {
                            //³B²zgroup!!
                            /*if (setCol.groupKey && setCol.attrs.rowSpan == recordCol.length) {
                                var isGroup = 0;
                                var nextGroup = 0;
                                for (var l = 0 ; l < setCol.groupKey.length ; l = l + 1) {
                                    if (preRec && setRec[setCol.groupKey[l]] === preRec[setCol.groupKey[l]]) {
                                        isGroup = isGroup + 1;
                                    }
                                    if (nextRec && setRec[setCol.groupKey[l]] === nextRec[setCol.groupKey[l]]) {
                                        nextGroup = nextGroup + 1;
                                    }
                                }
                                if (nextGroup > 0 && nextGroup === setCol.groupKey.length) { changeNextColor = false; }

                                if (isGroup == 0) {
                                    groupColRec.set(setCol.key, { i: posit + 0, j: exportData[posit].length });
                                } else {
                                    exportData[posit].push({ dataIndex: "", header: "", type: "copy", rowSpan: 0, colSpan: 0 });
                                    var gupcell = exportData[(groupColRec.get(setCol.key)).i][(groupColRec.get(setCol.key)).j];
                                    gupcell.rowSpan = gupcell.rowSpan + recordCol.length;
                                    continue;
                                }
                            }*/

                            //³B²z¸ê°T!!
                            var dataIndex = doSettingRender(setRec, setCol);
                            dataIndex = formatDataToText(dataIndex);

                            if ((setCol.dataType || "").toLowerCase() == 'number' && setCol.exportNumber !== false) {
                                dataIndex = dataIndex.replace(/,/g, '');
                            }
                            exportData[posit].push({
                                dataIndex: dataIndex,
                                header: setCol.key,
                                type: setCol.sortRule ? setCol.sortRule.toLowerCase() : "string",
                                rowSpan: (setCol.attrs && setCol.attrs.rowSpan) ? setCol.attrs.rowSpan : 1,
                                colSpan: (setCol.attrs && setCol.attrs.colSpan) ? setCol.attrs.colSpan : 1,
                                bgColor: bgColor
                            });
                        } else {
                            exportData[posit].push({ dataIndex: "", header: "", type: "copy", rowSpan: 0, colSpan: 0, bgColor: bgColor });
                        }
                    }
                    posit = posit + 1;
                }
                if (changeNextColor) {
                    bgColor = (bgColor === 1 ? 2 : 1);
                    //¥[¤J¤p­p³¡¤À
                    /*if (isCount) {
                        setSubCountInfoInXLS(exportData, setRec);
                    }*/
                }
            }
            //¥[¤JÁ`­p
            /* if (isCount) {
                setTotalCountInfoInXLS(exportData);
            } */

            //¿é¥X
            if (!fileName) {
                return { sheetName: sheetName || "", isMultiCols: true, multiColsData: exportData, bgColorType: isNumeric(bgColorType) ? bgColorType : 1 };
            } else {
                return TableUIsExportToXLS(fileName, [{ sheetName: sheetName || "", isMultiCols: true, multiColsData: exportData, bgColorType: isNumeric(bgColorType) ? bgColorType : 1 }]);
            }

        }

        function formatDataToText(data) {
            if (!isBasicType(data)) {
                if (isElement(data)) {
                    data = data.innerText;
                } else {
                    data = "";
                }
            }
            /* ´«¦æ¦r¤¸®æ¦¡¤Æ */
            if (isString(data)) {
                data = data.replace(/<br>/gi, "\012");
                data = data.replace(/<\/br>/gi, "\012");
                data = data.replace(/<br.*?\/>/gi, "\012");
            }
            return data + "";
        }

        function TableUIsExportToXLS(fileName, fileData) {
            if (!hasJsFramework) { return false; }
            if (!isArray(fileData)) {
                alert("¿é¥X¸ê®Æ®æ¦¡¿ù»~");
                return false;
            }
            for (var i = 0 ; i < fileData.length ; i = i + 1) {
                if (!fileData[i]) {
                    alert("¿é¥X¸ê®Æ®æ¦¡¿ù»~");
                    return false;
                }
            }

            var datasJSON = toJSON({ fileName: fileName + '.xls', sheets: fileData });

            var submitForm = createElement("form", {
                'target': 'submitForm',
                'action': '/ZRWeb/xls',
                'method': 'post'
            },{
                'display': 'none'
            });

            var input = createElement('input', {
                'name': 'xlsData',
                'value': datasJSON
            });
            
            appendElement( submitForm , input);

            document.body.appendChild(submitForm);
            submitForm.submit();
            document.body.removeChild(submitForm);

            return true;
        }

    }

    /*´«­¶±±¨î(¹w¥ý¦s¤J¸ê®Æ) */
    function pageControl_impl() {
        //¿é¤J¸ê®Æ
        var records = null;
        var recordsTotalCount = null;
        var recordsSubTotalCount_org = null;
        var deletedRecoreds = null;

        //¤À²Õ¸ê®Æ
        var recordsWithGroup = null;
        var recordsSubTotalCount = null;

        var active_records = null;

        var pageSize = isNumeric(config.pageSize) ? parseInt(config.pageSize, 10) : 10;
        if ( pageSize <= 0) {
            pageSize = false;
        }

        var nowPage = 0;
        var totalPage = 0;
        var totalRecord = 0;
        var nowRecord_start = 0;
        var nowRecord_pervious_start = 0;
        var nowRecord_next_start = 0;

        var settings = settingCtrl.settings;

        var hasGroup = settings.allGroupKeys && settings.allGroupKeys.length > 0;

        var textPattern =
			isString(config.recordInfoPattern) ?
			config.recordInfoPattern
			: (
                !pageSize
                    ? "¦@ {totalRecord} µ§"
                    : (
				       !hasGroup
                       ? "²Ä {nowPage} ­¶/¦@ {totalPage} ­¶ ¦@ {totalRecord} µ§"
				        : "²Ä {nowPage} ­¶/¦@ {totalPage} ­¶ ¸s²Õ {totalGroup} ²Õ/¦@ {totalRecord} µ§"
                    )
            );

        var beforeLoad = isFunction(config.beforeLoad) ? config.beforeLoad : null;
        var afterLoad = isFunction(config.afterLoad) ? config.afterLoad : null;
        var beforePageChange = isFunction(config.beforePageChange) ? config.beforePageChange : null;
        var pageChange = isFunction(config.pageChange) ? config.pageChange : null;

        var needPageInfo = getBoolean(config.pageInfo, !!pageSize);

        var controlDiv = null;
        var controlSelect = null;
        var controlText = null;

        if (needPageInfo || pageSize) {
            controlDiv = createElement("DIV", { name: "tableControl" }, { right: "10px" }, ["childOfTableParent", "tableControl"], null, main_div);
            if (pageSize) {
                createElement("button", { type: "button" }, null, ['first'], { click: loadFirst }, controlDiv);
                createElement("button", { type: "button" }, null, ['pervious'], { click: loadPrevious }, controlDiv);
                controlSelect = createElement("select", null, null, null, { change: function (e) { loadPage(getEventTarget(e).value); } }, controlDiv);
                createElement("button", { type: "button" }, null, ['next'], { click: loadNext }, controlDiv);
                createElement("button", { type: "button" }, null, ['last'], { click: loadLast }, controlDiv);
            }
            if(needPageInfo){
                controlText = createElement("span", { id: table_id +'_pageInfo'}, null, null, null, controlDiv);
                updateInformation();
            }
        }


        this.getRecordsInfo = getRecordsInfo;
        function getRecordsInfo() {
            return { pageNo: nowPage };
        }

        this.setRecordsInfo = setRecordsInfo;
        function setRecordsInfo(info) {
            loadPage(info.pageNo);
        }

        this.addRecords = addRecords;
        function addRecords(input_records , autoCheckStatus ) {
            //¤£¤¹³\Group¼W¥[¸ê®Æ
            if (hasGroup) { return; }

            /* ½Æ»s¤@¥÷¡AÁ×§K¨Ó·½¸ê®Æ³Q²¾°£ */
            input_records = cloneObject(input_records);

            if (!isObject(input_records) && ((!isArray(input_records) || !input_records.length))) { return; }

            if (autoCheckStatus === true && config.autoCheckBox) {
                if (isObject(input_records)) {
                    input_records['_tableuiAutoCheckBoxResult'] = 1;
                } else {
                    for (var i = 0 ; i < input_records.length ; i++) {
                        input_records[i]['_tableuiAutoCheckBoxResult'] = 1;
                    }
                }
            }

            var numOfRecords = 0;
            if (!records) {
                if (isObject(input_records)) {
                    records = [input_records];
                } else if (isArray(input_records)) {
                    records = input_records;
                } else {
                    return;
                }
                numOfRecords = records.length;
            } else if (isObject(input_records)) {
                records.push(input_records);
                numOfRecords = 1;
            } else if (isArray(input_records)) {
                records = records.concat(input_records);
                numOfRecords = input_records.length;
            } else {
                return;
            }

            if (pageSize) {
                init(totalPage + Math.ceil(numOfRecords / pageSize));
            } else {
                init();
            }
            sizeController.scrollBottom();
        }

        this.deleteRecords = deleteRecords;
        function deleteRecords(del_records) {
            if((!records || !isArray(records) || !records.length)) { return; }
            if (!isObject(del_records) && ((!isArray(del_records) || !del_records.length))) { return; }
            if (isObject(del_records)) {
                del_records = [del_records];
            }
            if (!isArray(deletedRecoreds)) { deletedRecoreds = []; }
            var alreadyDeleteReocrds = [];
            while (del_records.length) {
                for (var i = 0 ; i < records.length ; i++) {
                    if (del_records[0] == records[i]) {
                        del_records.splice(0, 1);
                        deletedRecoreds.push(records.splice(i, 1)[0])
                    }
                }
            }
            
            if(!records.length){
                var tempSave = deletedRecoreds;
                clearData();
                deletedRecoreds = tempSave;
            }else{
                init();
            }
        }

        this.resetTotalCount = resetTotalCount;
        function resetTotalCount(total_count) {
            //®æ¦¡¤Æ¦X­p
            recordsTotalCount = null;
            if (isArray(total_count) && total_count.length > 0 && isObject(total_count[0])) {
                recordsTotalCount = total_count;
            } else if (isObject(total_count)) {
                if (isObject(total_count.value)) {
                    recordsTotalCount = [total_count];
                } else {
                    recordsTotalCount = [{ value: total_count }];
                }
            }
            
            dataControl.createTotalRecordBody(recordsTotalCount);
        }

        this.resetSubTotalCount = resetSubTotalCount;
        function resetSubTotalCount(subtotal_count) {
            loadin(records, recordsTotalCount, subtotal_count);
        }

        this.getTotalCount = function () {
            return recordsTotalCount || null;
        };

        this.getSubTotalCount = function () {
            return recordsSubTotalCount_org || null;
        };

        this.loadin = loadin;
        function loadin(input_records, total_count, subtotal_count, preCheckedValues) {

            clearData();

            if (isObject(input_records)) { input_records = [input_records]; }
            if (!input_records || !isArray(input_records) || !input_records.length) {
                clearData();
                return;
            }

            /* ½Æ»s¤@¥÷¡AÁ×§K¨Ó·½¸ê®Æ³Q²¾°£ */
            input_records = cloneObject(input_records);

            //®æ¦¡¤Æ¦X­p
            if (isArray(total_count) && total_count.length > 0 && isObject(total_count[0])) {
                recordsTotalCount = total_count;
            } else if (isObject(total_count)) {
                if (isObject(total_count.value)) {
                    recordsTotalCount = [total_count];
                } else {
                    recordsTotalCount = [{ value: total_count }];
                }
            }

            //®æ¦¡¤Æ¤p­p
            if (isArray(subtotal_count) && subtotal_count.length > 0) {
                recordsSubTotalCount_org = [];
                for (var i = 0 ; i < subtotal_count.length ; i++) {
                    if (isArray(subtotal_count[i])) {
                        for (var j = 0 ; j < subtotal_count[i].length ; j++) {
                            if (isObject(subtotal_count[i][j]) && subtotal_count[i][j].key && isObject(subtotal_count[i][j].value)) {
                                recordsSubTotalCount_org.push(subtotal_count[i][j]);
                            }
                        }
                    } else if (isObject(subtotal_count[i]) && subtotal_count[i].key && isObject(subtotal_count[i].value)) {
                        recordsSubTotalCount_org.push(subtotal_count[i]);
                    }
                }
            }

            //§PÂ_¬O§_¹w¥ý¿ï¨ú
            var autoCheckBoxKey = settingCtrl.settings.autoCheckBoxKey;
            var preCheckedValues_available =  autoCheckBoxKey && isArray(preCheckedValues) && preCheckedValues.length > 0;
            for (var i = 0 ; i < input_records.length ; i++) {
                if (preCheckedValues_available) {
                    var checkValue = input_records[i][autoCheckBoxKey];
                    // console.log( "isInArray( " + preCheckedValues+", "+checkValue+")  / "+ isInArray(preCheckedValues, checkValue))
                    if (isBasicType(checkValue) && isInArray(preCheckedValues, checkValue) >= 0) {
                        input_records[i]['_tableuiAutoCheckBoxResult'] = 1;
                    } else {
                        input_records[i]['_tableuiAutoCheckBoxResult'] = -1;
                    }
                } else {
                    delete input_records[i]['_tableuiAutoCheckBoxResult'];
                }
            }
            
            //¿ù»~Åã¥Ü
            resetValidate(input_records);

            dataControl.clearTableInfo();
            reLoadin(input_records);

        }

        this.clearData = clearData;
        function clearData() {
            active_records = null;
            records = null;
            deletedRecoreds = null;
            recordsTotalCount = null;
            recordsSubTotalCount = null;
            recordsWithGroup = null;
            if (settingCtrl.settings.checkAllBox) {
                settingCtrl.settings.checkAllBox.disabled = true;
                settingCtrl.settings.checkAllBox.checked = false;
            }
            totalPage = 0;
            totalRecord = 0;
            nowPage = 0;
            nowRecord_start = 0;
            nowRecord_pervious_start = 0;
            nowRecord_next_start = 0;
            while (pageSize && controlSelect.hasChildNodes()) {
                controlSelect.removeChild(controlSelect.firstChild);
            }
            updateInformation();
            dataControl.clearRecordsBodies();
            dataControl.createTotalRecordBody();
        }

        this.reLoadin = reLoadin;
        function reLoadin(input_records) {
            recordsWithGroup = null;
            records = input_records;
            /* ­Y¸ê®Æ»Ý­n¶i¦æ¸s²Õ¤Æ¡A²£¥Í¸s²Õ¸ê®Æ */
            if (hasGroup) {
                var splitGroupKey = cloneObject(settings.allGroupKeys[0]);
                
                recordsWithGroup = [];
                recordsSubTotalCount = [];

                var preRecord = records[0];
                var tempGroupSaveing = [];
                tempGroupSaveing.push(preRecord);
                recordsWithGroup.push(tempGroupSaveing);
                //group datas 
                for (var records_count = 1 ; records_count < records.length ; records_count += 1) {
                    var testRecord = records[records_count];
                    var isGroup = true;
                    for (var gk = 0 ; gk < splitGroupKey.length ; gk++) {
                        if (testRecord[splitGroupKey[gk]] != preRecord[splitGroupKey[gk]]) {
                            isGroup = false;
                        }
                    }
                    if (!isGroup) {
                        tempGroupSaveing = [];
                        recordsWithGroup.push(tempGroupSaveing);
                    }

                    tempGroupSaveing.push(testRecord);
                    preRecord = testRecord;
                }
                
                //±Æ§Çgroup
                dataControl.sortGroup(recordsWithGroup);

                //if has subTotal
                if (recordsSubTotalCount_org) {
                    var hasNonObjectKeys = false;
                    for (var tot_count = 0 ; tot_count < recordsSubTotalCount_org.length ; tot_count += 1) {
                        var group_keys = recordsSubTotalCount_org[tot_count].key;
                        if (isBasicType(group_keys)) {
                            hasNonObjectKeys = true;
                            continue;
                        } else if (isObject(group_keys)) {
                            for (var split_i = 0 ; split_i < splitGroupKey.length ; split_i++) {
                                if (group_keys[splitGroupKey[split_i]] === undefined) {
                                    splitGroupKey.splice(split_i, 1);
                                    split_i--;
                                }
                            }
                        } else {
                            splitGroupKey = [];
                        }
                        if (!splitGroupKey.length) {
                            break;
                        }
                    }

                    if (hasNonObjectKeys ? splitGroupKey.length == 1 : splitGroupKey.length > 0 ) {
                        /*²Ä¤@¼h¡A©Ò¦³¸s²Õ¸ê®Æ¡A¨ú²Ä¤@µ§´ú¸Õ¡C*/
                        for (var group_i = 0 ; group_i < recordsWithGroup.length ; group_i++) {
                            var testRecord = recordsWithGroup[group_i][0];
                            var tempGroupSubRecordsSaveing = [];
                            recordsSubTotalCount.push(tempGroupSubRecordsSaveing);
                            /* ­ì©lªº¤p­p¸ê®Æ */
                            for (var tot_count = 0 ; tot_count < recordsSubTotalCount_org.length ; tot_count += 1) {
                                var group_data = recordsSubTotalCount_org[tot_count];
                                var group_keys = group_data.key;

                                if (isBasicType(group_keys) && group_keys == testRecord[splitGroupKey[0]]) {
                                    tempGroupSubRecordsSaveing.push(group_data);
                                } else {
                                    var isMatch = true;
                                    for (var gk = 0 ; gk < splitGroupKey.length ; gk++) {
                                        var testKey = splitGroupKey[gk];
                                        if (group_keys[testKey] !== testRecord[splitGroupKey[gk]]) {
                                            isMatch = false;
                                            break;
                                        }
                                    }
                                    if (isMatch === true) {
                                        tempGroupSubRecordsSaveing.push(group_data);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            init();
        }

        function init(setPageTo) {

            if (!records) {
                clearData();
                return;
            }

            dataControl.setSerialNnmber(records);
            active_records = recordsWithGroup ? recordsWithGroup : records;

            totalPage = Math.ceil(active_records.length / (pageSize + 0.0));
            totalRecord = records.length;
            nowPage = 0;
            nowRecord_start = 0;
            nowRecord_pervious_start = 0;
            nowRecord_next_start = 0;

            if (beforeLoad) { beforeLoad.call(main_div, main_div, table_id, this); }

            if (pageSize && isNumeric(setPageTo)) {
                loadPage(Math.min(setPageTo, totalPage));
            } else {
                loadFirst();
            }
            dataControl.createTotalRecordBody(recordsTotalCount);

            if (afterLoad) { afterLoad.call(main_div, main_div, table_id, this); }

            while (pageSize && controlSelect.hasChildNodes()) {
                controlSelect.removeChild(controlSelect.firstChild);
            }
            for (var select_count = 1 ; pageSize && select_count <= totalPage ; select_count += 1) {
                createElement("OPTION", { value: select_count }, null, null, null, controlSelect, "&nbsp;-&nbsp;" + select_count + "&nbsp;-&nbsp;");
            }
            updateInformation();
        }

        function updateInformation() {
            if (window.autoCreateDate) { autoCreateDate(dataArea); }

            if (window.autoFormatToNumber) { autoFormatToNumber(dataArea); }
            if (window.autoFormatToDate) { autoFormatToDate(); }

            //check¿ï¾Ü
            if (records && records.length) {

                if (pageChange) { pageChange.call(main_div, nowPage, totalPage, main_div, table_id, this); }
                
                if(hasJsFramework){
                    selectElementThenEach(dataArea , "input.shouldBeChecked" , function (sn,elem) {
                        elem.checked = true;
                        removeClassName(elem , "shouldBeChecked");
                    });
                }
            }

            //if (sizeController) { sizeController.doResize('updateInfo'); }

            if (pageSize) { controlSelect.value = nowPage; }

            if (!needPageInfo) { return; }

            var text = textPattern
			.replace("{nowPage}", nowPage)
			.replace("{totalPage}", totalPage)
			.replace("{totalRecord}", totalRecord)
			.replace("{totalGroup}", recordsWithGroup ? recordsWithGroup.length : 0);
            controlText.innerHTML = text;

        }

        this.loadAgain = loadAgain
        function loadAgain(preCheckedValues) {
            if (!records) { return; }
            //§PÂ_¬O§_¹w¥ý¿ï¨ú
            var autoCheckBoxKey = settingCtrl.settings.autoCheckBoxKey;
            var preCheckedValues_available = autoCheckBoxKey && isArray(preCheckedValues) && preCheckedValues.length > 0;
            for (var i = 0 ; i < records.length ; i++) {
                if (preCheckedValues_available) {
                    var checkValue = records[i][autoCheckBoxKey];
                    // console.log( "isInArray( " + preCheckedValues+", "+checkValue+")  / "+ isInArray(preCheckedValues, checkValue))
                    if (isBasicType(checkValue) && isInArray(preCheckedValues, checkValue) >= 0) {
                        records[i]['_tableuiAutoCheckBoxResult'] = 1;
                    } else {
                        records[i]['_tableuiAutoCheckBoxResult'] = -1;
                    }
                } else {
                    delete  records[i]['_tableuiAutoCheckBoxResult'];
                }
            }

            //­«³]¿ù»~Åã¥Ü
            resetValidate();
            //­«·sÅª¤Jpage
            init(nowPage);
        }

        this.loadPrevious = loadPrevious;
        function loadPrevious() {
            if (nowPage <= 1) { return; }
            loadFrom(nowRecord_pervious_start);
            nowPage -= 1;
            updateInformation();
        }

        this.loadNext = loadNext;
        function loadNext() {
            if (nowPage >= totalPage) { return; }
            nowPage = parseInt(nowPage, 10) + 1;
            loadFrom(nowRecord_next_start);

        }

        this.loadFirst = loadFirst;
        function loadFirst() {
            if (nowPage == 1) { return; }
            nowPage = 1;
            loadFrom(0);
        }

        this.loadLast = loadLast;
        function loadLast() {
            if (nowPage >= totalPage) { return; }
            nowPage = totalPage;
            loadFrom((totalPage - 1) * pageSize);
        }

        this.reloadPage = reloadPage;
        function reloadPage() {
            loadFrom((nowPage - 1) * pageSize);
            if (dataControl) {
                dataControl.createTotalRecordBody(recordsTotalCount);
            }
        }

        this.loadPage = loadPage;
        function loadPage(pageNO) {
            if (!isNumeric(pageNO)) { return; }
            if (pageNO < 1) {
                loadFirst();
            } else if (pageNO > totalPage) {
                loadLast();
            } else {
                nowPage = pageNO;
                loadFrom((pageNO - 1) * pageSize);
            }
        }

        function loadFrom(start) {

            if (!active_records) {
                return;
            }

            if (!pageSize) {
                dataControl.clearRecordsBodies();
                for (var rwg_count = 0 ; rwg_count < active_records.length ; rwg_count += 1) {
                    dataControl.createRecordsBody(active_records[rwg_count], ( recordsSubTotalCount ? recordsSubTotalCount[rwg_count]:null ), rwg_count);
                }
                return;
            }

            if (!isNumeric(start)) {
                return;
            }

            /* ­Y³oÃäbeforePageChange¦^¶Ç false ¡A°±¤îÂ½­¶ */
            if (beforePageChange && beforePageChange.call(main_div, nowPage, totalPage, main_div, table_id, this) === false) { return; }

            if (start >= active_records.length) {
                loadLast();
                return;
            }

            if (start < 0) {
                loadFirst();
                return;
            }

            dataControl.clearRecordsBodies();

            var end = parseInt(start, 10) + pageSize;
            if (end > active_records.length) {
                end = active_records.length;
            }

            var load_Records = active_records.slice(start, end);

            for (var rwg_count = 0 ; rwg_count < load_Records.length ; rwg_count += 1) {
                dataControl.createRecordsBody(load_Records[rwg_count], ( recordsSubTotalCount ? recordsSubTotalCount[start + rwg_count] : null ), start + rwg_count);
            }
            nowRecord_start = start;
            nowRecord_pervious_start = start < pageSize ? 0 : start - pageSize;
            nowRecord_next_start = end;

            updateInformation();
        }

        this.hasRecords = function () { return records && records.length > 0; };

        //¨ú±o¸ê®Æ
        this.getAllRecords = getAllRecords;
        function getAllRecords(template) {
            if (template) {
                return dataControl.getRecordsByTemplate(records || [], template);
            } else {
                return records || [];
            }
        }

        this.getDeletedRecords = getDeletedRecords;
        function getDeletedRecords(template) {
            if (template) {
                return dataControl.getRecordsByTemplate(deletedRecoreds || [], template);
            } else {
                return deletedRecoreds || [];
            }
        }

        this.getCurrentPageRecords = getCurrentPageRecords;
        function getCurrentPageRecords(template) {
            var currentRecords = [];

            for (var i = nowRecord_start ; i < nowRecord_next_start && i < active_records.length ; i++) {
                var load_record = active_records[i];
                if (isArray(load_record)) {
                    currentRecords = currentRecords.concat(load_record);
                } else {
                    currentRecords.push(load_record)
                }
            }

            if (template) {
                return dataControl.getRecordsByTemplate(currentRecords || [], template);
            } else {
                return currentRecords || [];
            }
        }

        this.getCheckedRecords = getCheckedRecords;
        function getCheckedRecords(template , includeDisabled) {
            var checkedRecords = [];
            var includeDisabled = getBoolean(includeDisabled, false);
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiAutoCheckBoxResult'] == 1 || (includeDisabled && records[i]['_tableuiAutoCheckBoxResult'] === 0 )) {
                    checkedRecords.push(records[i]);
                }
            }

            if (checkedRecords.length == 0) {
                return checkedRecords;
            }

            if (!isString(template) && !isArray(template) && settingCtrl.settings.autoCheckTemplate) {
                template = settingCtrl.settings.autoCheckTemplate;
            }

            return dataControl.getRecordsByTemplate(checkedRecords, template);
        }

        this.getUncheckedRecords = getUncheckedRecords;
        function getUncheckedRecords(template, includeDisabled ) {
            var checkedRecords = [];
            var includeDisabled = getBoolean(includeDisabled, false);
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiAutoCheckBoxResult'] == -1 || (includeDisabled && records[i]['_tableuiAutoCheckBoxResult'] == -2 )) {
                    checkedRecords.push(records[i]);
                }
            }

            if (checkedRecords.length == 0) {
                return checkedRecords;
            }

            if (!isString(template) && !isArray(template) && settingCtrl.settings.autoCheckTemplate) {
                template = settingCtrl.settings.autoCheckTemplate;
            }

            return dataControl.getRecordsByTemplate(checkedRecords, template);
        }

        this.getErrorRecords = getErrorRecords;
        function getErrorRecords(template) {
            var errorRecords = [];
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiValidateStatus'] === false) {
                    errorRecords.push(records[i]);
                }
            }

            if (errorRecords.length == 0) {
                return errorRecords;
            }

            return dataControl.getRecordsByTemplate(errorRecords, template);

        }

        this.getCorrectRecords = getCorrectRecords;
        function getCorrectRecords(template) {
            var non_errorRecords = [];
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiValidateStatus'] !== false) {
                    non_errorRecords.push(records[i]);
                }
            }

            if (non_errorRecords.length == 0) {
                return non_errorRecords;
            }

            return dataControl.getRecordsByTemplate(non_errorRecords, template);
        }

        this.getCheckedErrorRecords = getCheckedErrorRecords;
        function getCheckedErrorRecords(template, includeDisabled) {
            var errorRecords = [];
            var includeDisabled = getBoolean(includeDisabled, false);
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiValidateStatus'] === false && (records[i]['_tableuiAutoCheckBoxResult'] == 1 || (includeDisabled && records[i]['_tableuiAutoCheckBoxResult'] === 0))) {
                    errorRecords.push(records[i]);
                }
            }

            if (errorRecords.length == 0) {
                return errorRecords;
            }

            if (!isString(template) && !isArray(template) && settingCtrl.settings.autoCheckTemplate) {
                template = settingCtrl.settings.autoCheckTemplate;
            }

            return dataControl.getRecordsByTemplate(errorRecords, template);
        }

        this.getCheckedCorrectRecords = getCheckedCorrectRecords;
        function getCheckedCorrectRecords(template, includeDisabled) {
            var non_errorRecords = [];
            includeDisabled = getBoolean(includeDisabled, false);
            for (var i = 0 ; records && (i < records.length) ; i += 1) {
                if (records[i]['_tableuiValidateStatus'] !== false && (records[i]['_tableuiAutoCheckBoxResult'] == 1 || (includeDisabled && records[i]['_tableuiAutoCheckBoxResult'] === 0))) {
                    non_errorRecords.push(records[i]);
                }
            }
            
            if (non_errorRecords.length == 0) {
                return non_errorRecords;
            }

            if (!isString(template) && !isArray(template) && settingCtrl.settings.autoCheckTemplate) {
                template = settingCtrl.settings.autoCheckTemplate;
            }

            return dataControl.getRecordsByTemplate(non_errorRecords, template);
        }

        this.getRecordsBy = getRecordsBy;
        function getRecordsBy(getTemplate, recordTemplate) {
            if (!getTemplate) {
                return [];
            }

            if (isBasicType(getTemplate)) {
                getTemplate = (getTemplate + "").split(",");
            } else if (!isArray(getTemplate)) {
                return [];
            }

            var rtnList = [];
            for (var i = 0  ; i < getTemplate.length ; i += 1) {
                var recNo = getTemplate[i] - 1;
                if (isNumeric(recNo) && recNo >= 0 && recNo < records.length) {
                    rtnList.push(records[recNo]);
                }
            }
            return dataControl.getRecordsByTemplate(rtnList, recordTemplate);
        }

        /* ¶×¥X */
        this.exportAllToXLS = exportAllToXLS;
        function exportAllToXLS(fileName, isCount, bgColorType, sheetName) {
            return dataControl.exportToXLS(fileName, getAllRecords(), isCount, bgColorType, sheetName);
        }

        this.exportCheckToXLS = exportCheckToXLS;
        function exportCheckToXLS(fileName, isCount, bgColorType, sheetName) {
            return dataControl.exportToXLS(fileName, getCheckedRecord(), isCount, bgColorType, sheetName);
        }

        /* validate datas */
        this.setValidRecord = setValidRecord;
        function setValidRecord(node, validResult) {
            var dataObjs = dataControl.getRecordsByCell(node);
            return setValidRecordByRecord(dataObjs, validResult)
        }

        this.setValidRecordByRecord = setValidRecordByRecord;
        function setValidRecordByRecord(dataObjs, validResult) {
            if (config.validateRecord !== undefined && config.validateRecord !== null) {
                alert('TableuUI¤w¸g©w¸q validateRecord , ½Ð§ï©I¥s validTable ­«·sÀË®Ö¸ê®Æ¡C');
                return;
            }
            validResult = getBoolean(validResult,true);
            if (isArray(dataObjs)) {
                for (var i = 0 ; i < dataObjs.length ; i++) {
                    setValidRecordByRecord( dataObjs[i] , validResult );
                }
            } else if (isObject(dataObjs)) {
                dataObjs['_tableuiValidateStatus'] = validResult;
            }

            return validResult;
        }

        this.resetValidate = resetValidate;
        function resetValidate(input_records) {
            /* ¬O§_¬°ªì©l®æ¦¡¤Æ¡A¥u¦³ªì©l¤Æ®É¤~·|¶Ç¤J°Ñ¼Æ */
            var isOnLoad = true;
            if (!isArray(input_records)) {
                input_records = records;
                isOnLoad = false;
            }
            if (!isArray(input_records)) {
                return;
            }

            var validateRecord = config.validateRecord;
            if (validateRecord !== undefined || validateRecord !== null) {
                if (isOnLoad) {
                    /* ªì©l®É¤~»Ý§ó·sÀË®ÖÃþ«¬ */
                    validate_type = !(getBoolean(config.validateRecordCheckedOnly, false));
                }
                for (var i = 0 ; i < input_records.length ; i++) {
                    input_records[i]['_tableuiValidateStatus'] = getBoolean(validateRecord, true, [input_records[i], (i + 1)]);
                }
            } else if (isOnLoad) {
                validate_type = null;
                for (var i = 0 ; i < input_records.length ; i++) {
                    input_records[i]['_tableuiValidateStatus'] = true;
                }
            }

            if (!isOnLoad) {
                resetErrorColor();
            }
        }

        this.validTable = validTable;
        function validTable() {
            if (!records) { return; }
            resetValidate();
            validate_type = true;
            var hasError = 0;
            for (var i = 0 ; i < records.length ; i++) {
                if(records[i]['_tableuiValidateStatus'] === false){
                    hasError = hasError  + 1;
                }
            }
            resetErrorColor();
            return hasError;
        }

        this.validCheckedOnTable = validCheckedOnTable;
        function validCheckedOnTable(includeDisabled) {
            if (!records) { return; }
            resetValidate();
            validate_type = false;
            var hasError = 0;
            includeDisabled = getBoolean(includeDisabled, false);
            for (var i = 0 ; i < records.length ; i++) {
                if (records[i]['_tableuiValidateStatus'] === false && (records[i]['_tableuiAutoCheckBoxResult'] == 1 || (includeDisabled && records[i]['_tableuiAutoCheckBoxResult'] === 0))) {
                    hasError = hasError + 1;
                }
            }
            resetErrorColor(includeDisabled);
            return hasError;
        }

        function resetErrorColor(includeDisabled) {
            if (!hasJsFramework) { return; }
            if (!records) { return; }

            selectElementThenEach(main_div , 'tbody tr' , function (sn, elem) {
                if (hasClassName(elem, 'count_data')) { return; }
                var record = dataControl.getRecordByCell(elem);
                var errorStatus = false;
                if (validate_type != null && record['_tableuiValidateStatus'] === false) {
                    if (validate_type === true) {
                        errorStatus = true;
                    } else if ((record['_tableuiAutoCheckBoxResult'] == 1 || (includeDisabled && record['_tableuiAutoCheckBoxResult'] === 0))) {
                        errorStatus = true;
                    }
                }
                if (errorStatus) {
                    addClassName(elem, 'error_record');
                } else {
                    removeClassName(elem, 'error_record');
                }
            });
        }

    }

    //´«­¶±±¨î(°ÊºA¨ú±o¸ê®Æ)
    function pageControlFatch_impl() {

        var queryUrl = null;
        var queryRules = null;

        var records = null;
        var pervious_records = null;
        var next_records = null;

        var successFunction = null;
        var failFunction = null;
        var fetchSuccessFunction = null;
        var fetchFailFunction = null;

        var pageSize = config.pageSize && isNumeric(config.pageSize) ? parseInt(config.pageSize, 10) : 10;

        var nowPage = 0;
        var totalPage = 0;
        var totalRecord = 0;

        var nowRecord_start = 0;
        var nowRecord_pervious_start = 0;
        var nowRecord_next_start = 0;

        var thisAjaxRecordFrom = 0;
        var nextAjaxRecordFrom = 0;
        var perviousAjaxRecordFrom = 0;

        //³]©w¬°¤@¦¸load 5­¶ªº¶q¡A¦ý¨C¦¸¤£±o¤j©ó200µ§¸ê®Æ
        var recordNumOfFatch = isNumeric(config.isLoadByFatch) && config.isLoadByFatch >= pageSize ? config.isLoadByFatch : (pageSize * 5);
        if (recordNumOfFatch > 200) { recordNumOfFatch = 200; alert("¤À§å¬d¸ß¨C¦¸¤£±o¤j©ó200µ§¸ê®Æ¡A½Ð­×§ï[isLoadByFatch]°Ñ¼Æ!"); }

        if (pageSize > recordNumOfFatch) {
            pageSize = recordNumOfFatch;
        } else if (recordNumOfFatch % pageSize != 0) {
            recordNumOfFatch = recordNumOfFatch - (recordNumOfFatch % pageSize);
        }


        var settings = settingCtrl.settings;

        var textPattern = isString(config.recordInfoPattern) ?
			config.recordInfoPattern
			: "²Ä {nowPage} ­¶/¦@ {totalPage} ­¶ ¦@ {totalRecord} µ§";

        var beforeLoad = isFunction(config.beforeLoad) ? config.beforeLoad : null;
        var afterLoad = isFunction(config.afterLoad) ? config.afterLoad : null;
        var beforePageChange = isFunction(config.beforePageChange) ? config.beforePageChange : null;
        var pageChange = isFunction(config.pageChange) ? config.pageChange : null;

        var controlDiv = createElement("DIV", { name: "tableControl" }, { right: "10px" }, ["childOfTableParent", "tableControl"], null, main_div);
        createElement("button", { type: "button" }, null, ['first'], { click: loadFirst }, controlDiv);
        createElement("button", { type: "button" }, null, ['pervious'], { click: loadPrevious }, controlDiv);
        var controlSelect = createElement("select", null, null, null, { change: function (e) { loadPage(getEventTarget(e).value); } }, controlDiv);
        createElement("button", { type: "button" }, null, ['next'], { click: loadNext }, controlDiv);
        createElement("button", { type: "button" }, null, ['last'], { click: loadLast }, controlDiv);
        var controlText = createElement("span", { id: table_id + '_pageInfo' }, null, null, null, controlDiv);
        createElement("button", { type: "button" }, null, ['refresh'], { click: loadAgain }, controlDiv);

        updateInformation();

        this.getRecordsInfo = getRecordsInfo;
        function getRecordsInfo() {
            return { thisAjaxRecordFrom: ((nowPage - 1) * pageSize), queryUrl: queryUrl, queryRules: queryRules };
        }

        this.setRecordsInfo = setRecordsInfo;
        function setRecordsInfo(info) {
            if (isString(info.queryUrl) && isString(info.queryRules)) {
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

                ajaxRecords(isNumeric(info.thisAjaxRecordFrom) ? info.thisAjaxRecordFrom : 0, true);
            }
        }


        this.addRecords = addRecords;
        function addRecords() {
            alert("§å¦¸¬d¸ßµLªk¦Û¦æ¼W¥[¸ê®Æ");
        }

        this.deleteRecords = deleteRecords;
        function deleteRecords() {
            alert("§å¦¸¬d¸ßµLªk¦Û¦æ§R°£¸ê®Æ");
        }

        this.loadin = loadin;
        function loadin(ajax_url, input_rules, successFunc, failFunc , fetchSuccessFunc , fetchFailFunc ) {

            if (!input_rules || !isObject(input_rules)) {
                clearData();
                return;
            }

            // !!! important !!! 
            queryUrl = ajax_url;
            queryRules = toJSON(input_rules);
            totalRecord = null;
            // !!! important !!!

            successFunction = (isFunction(successFunc) ? successFunc : null);
            failFunction = (isFunction(failFunc) ? failFunc : null);
            
            fetchSuccessFunction = (isFunction(fetchSuccessFunc) ? fetchSuccessFunc : null);
            fetchFailFunction = (isFunction(fetchFailFunc) ? fetchFailFunc : null);

            totalPage = 0;
            totalRecord = 0;
            nowPage = 0;

            records = null;
            pervious_records = null;
            next_records = null;

            thisAjaxRecordFrom = 0;
            nextAjaxRecordFrom = 0;
            perviousAjaxRecordFrom = 0;

            ajaxRecords(0, true);

        }

        function updateInformation() {

            if (sizeController) { sizeController.doResize('updateInfo'); }

            controlSelect.value = nowPage;
            var text = textPattern
			.replace("{nowPage}", nowPage)
			.replace("{totalPage}", totalPage)
			.replace("{totalRecord}", totalRecord);
            controlText.innerHTML = text;
            if (pageChange) { pageChange.call(main_div, nowPage, totalPage, main_div, table_id, this); }
            if (window.UI_Manager) {
                UI_Manager.callShareingObserve("resize", "tableUI");
            } else if (window.fix) {
                fix();
            }
            try {
                if (window.parent && window.parent.UI_Manager) {
                    window.parent.UI_Manager.callShareingObserve("resize");
                }
            } catch (err) {
            }
        }

        this.loadPrevious = loadPrevious;
        function loadPrevious() {
            if (nowPage <= 1) { return; }
            nowPage -= 1;
            loadFrom(nowRecord_pervious_start);
        }

        this.loadNext = loadNext;
        function loadNext() {
            if (nowPage >= totalPage) { return; }
            nowPage = parseInt(nowPage, 10) + 1;
            loadFrom(nowRecord_next_start);
        }

        this.loadFirst = loadFirst;
        function loadFirst() {
            if (nowPage == 1) { return; }
            nowPage = 1;
            loadFrom(0);
        }

        this.loadLast = loadLast;
        function loadLast() {
            if (nowPage >= totalPage) { return; }
            loadFrom((totalPage - 1) * pageSize);
            nowPage = totalPage;
            updateInformation();
        }

        this.resetValidate = reloadPage;
        this.reLoadin = reloadPage;
        function reloadPage() {
            ajaxRecords(0, true);
        }

        this.loadPage = loadPage;
        function loadPage(pageNO) {
            if (!isNumeric(pageNO)) { return; }
            if (pageNO < 1) {
                loadFirst();
            } else if (pageNO > totalPage) {
                loadLast();
            } else {
                nowPage = pageNO;
                loadFrom((pageNO - 1) * pageSize);
            }
        }

        this.loadAgain = loadAgain;
        this.reloadPage = loadAgain;
        function loadAgain() {
            ajaxRecords((nowPage - 1) * pageSize, true);
        }

        function loadFrom(start) {
            if (!isNumeric(start) || !records || !records.length) {
                return;
            }

            /* ­Y³oÃäbeforePageChange¦^¶Ç false ¡A°±¤îÂ½­¶ */
            if (beforePageChange && beforePageChange.call(main_div, nowPage, totalPage, main_div, table_id, this) === false ) { return; }

            start = parseInt(start, 10);
            if (start >= totalRecord) {
                loadLast();
                return;
            }
            if (start < 0) {
                loadFirst();
                return;
            }
            
            if (pervious_records && start >= perviousAjaxRecordFrom && start < thisAjaxRecordFrom) {
                next_records = records;
                records = pervious_records;
                pervious_records = null;
            } else if (next_records && start >= nextAjaxRecordFrom && start < (nextAjaxRecordFrom + recordNumOfFatch)) {
                pervious_records = records;
                records = next_records;
                next_records = null;
            } else if (!(start >= thisAjaxRecordFrom && start < nextAjaxRecordFrom)) {
                ajaxRecords(start, false);
                return;
            }

            /* ²M°£©Ò¦³¤Ä¿ï¸ê°T */
            if (window.tableUI_getFatchRecords === true) {
                for (var i = 0 ; i < records.length ; i += 1) {
                    records[i]['_tableuiAutoCheckBoxResult'] = -1;
                }
            }

            updateAjaxFromInfo(start, true);

            dataControl.clearRecordsBodies();

            if (!records) {
                return;
            }

            var end = start + pageSize;
            if (end > totalRecord) {
                end = totalRecord + 1;
            }
            var load_Records = records.slice((start - thisAjaxRecordFrom), (end - thisAjaxRecordFrom));

            for (var rwg_count = 0 ; rwg_count < load_Records.length ; rwg_count += 1) {
                dataControl.createRecordsBody(load_Records[rwg_count]);
            }

            updateInformation();

            nowRecord_start = start;
            nowRecord_pervious_start = start < pageSize ? 0 : start - pageSize;
            nowRecord_next_start = end;
        }

        function updateAjaxFromInfo(start, noMoveRecords) {

            var new_ajax_from = recordNumOfFatch * (Math.floor(start / recordNumOfFatch));

            nextAjaxRecordFrom = new_ajax_from + recordNumOfFatch;
            if (totalRecord && nextAjaxRecordFrom > totalRecord) {
                nextAjaxRecordFrom = totalRecord;
            }
            perviousAjaxRecordFrom = new_ajax_from - recordNumOfFatch;
            if (perviousAjaxRecordFrom < 0) {
                perviousAjaxRecordFrom = 0;
            }

            if (!noMoveRecords && records) {
                if (thisAjaxRecordFrom == perviousAjaxRecordFrom) {
                    pervious_records = records;
                    next_records = null;
                } else if (thisAjaxRecordFrom == nextAjaxRecordFrom) {
                    next_records = records;
                    pervious_records = null;
                } else {
                    next_records = null;
                    pervious_records = null;
                }
            }

            thisAjaxRecordFrom = new_ajax_from;
        }

        this.clearData = clearData;
        function clearData() {

            // !!! important !!! 
            totalRecord = null;
            queryUrl = null;
            queryRules = null;
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
            dataControl.clearRecordsBodies();
            dataControl.createTotalRecordBody();
        }

        function ajaxRecords(start, noCheckRecordIsExist) {

            if (!(isString(queryUrl))) {
                updateSelectOptions(false);
                return;
            }

            updateAjaxFromInfo(start, false);

            var isFirstQuery = (!totalRecord);

            var loadStart = thisAjaxRecordFrom + 1; //«áºÝ­pºâ±q1¶}©l
            var loadEnd = nextAjaxRecordFrom && nextAjaxRecordFrom === loadStart ? nextAjaxRecordFrom + 1 : nextAjaxRecordFrom; // «áºÝ¨ú±o·|¥]§t³o­Ó¼Æ¦r¡A¦ýloadStart¤£±o»PloadEnd¬Û¦P..©_©Çªº«áºÝÅÞ¿è

            //if(!hasJsFramework){ return; }

	        var parameters = {
	            param: queryRules
	            , loadStrat: loadStart
	            , loadEnd: loadEnd
	            , isFirstQuery: (isFirstQuery ? "Y" : "N")
	        };

            if (hasPrototype) {
                //CSRUtil && CSRUtil.defaultAjaxHandler && Ajax.Responders.unregister(CSRUtil.defaultAjaxHandler);
                new Ajax.Request(queryUrl, {
                    parameters: parameters
                    , onSuccess: function (XHT, resp) {
                        try {
                            if (ajaxIsSuccess(resp)) {
                                ajaxSuccess(resp, start, isFirstQuery);
                            } else {
                                ajaxFail(resp, isFirstQuery);
                            }
                        } catch (e) {
                            alert('°õ¦æajax.onSuccess¥¢±Ñ');
                            if (window.console) {
                                console.log('[TableUI fetch ajax(prototype.js)]°õ¦æajax.onSuccess¥¢±Ñ');
                                console.log(e);
                            }
                        }
                    }
                    /*,onComplete:function(){
                        setTimeout(function(){
                            CSRUtil && CSRUtil.defaultAjaxHandler && Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
                        }, 100);
                    }
                    */
                });
            } else if (hasjQuery) {
                jQuery.ajax({
                    url: queryUrl,
                    type: 'post',
                    data: parameters
                    //,global: false
                }).done(function (resp) {
                    try {
                        if (ajaxIsSuccess(resp)) {
                            ajaxSuccess(resp, start, isFirstQuery);
                        } else {
                            ajaxFail(resp, isFirstQuery);
                        }
                    } catch (e) {
                        alert('°õ¦æajax.onSuccess¥¢±Ñ');
                        if (window.console) {
                            console.log('[TableUI fetch ajax(jQuery.js)]°õ¦æajax.onSuccess¥¢±Ñ');
                            console.log(e);
                        }
                    }
                });
            } else if (window.JSON && JSON.parse) {
                var http = new XMLHttpRequest();
                var params = "";
                for (var key in parameters) {
                    if (params != "") {
                        params += "&";
                    }
                    params += key + "=" + encodeURIComponent(parameters[key]);
                }
                http.open("POST", queryUrl, true);
                http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                http.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                http.onreadystatechange = function () {
                    if (http.readyState == 4 && http.status == 200) {
                        var resp = http.responseText;
                        if (resp) {
                            resp = JSON.parse(resp);
                        } else {
                            return;
                        }
                        try {
                            if (ajaxIsSuccess(resp)) {
                                ajaxSuccess(resp, start, isFirstQuery);
                            } else {
                                ajaxFail(resp, isFirstQuery);
                            }
                        } catch (e) {
                            alert('°õ¦æajax.onSuccess¥¢±Ñ');
                            if (window.console) {
                                console.log('[TableUI fetch ajax(XMLHttpRequest)]°õ¦æajax.onSuccess¥¢±Ñ');
                                console.log(e);
                            }
                        }
                    }
                }
                http.send(params);

            } else {
                alert('µLªk±Ò°ÊAJAXÅª¨ú¸ê®Æ');
            }
        }

        function ajaxSuccess(resp, start, isFirstQuery){
            var totalOfRecords = parseInt(resp.totalOfRecords, 10);

            // ­º¦¸¬d¸ß¤@©w­nµ§¼Æ¸ê®Æ
            if (isFirstQuery && !isNumeric(totalOfRecords)) {
                alert("µLªkÅª¨ú¸ê®Æ¡A¦]¬°¯Ê¤Ö¥²­n¦^¶Ç­È[totalOfRecords]");
                clearData();
                if (isFunction(failFunction)) {
                    failFunction(resp);
                }
                return;
            }

            var rtnRecords = resp.records;
            if (!rtnRecords || !isArray(rtnRecords) || !rtnRecords.length) {
                alert("µLªkÅª¨ú¸ê®Æ¡A¦]¬°§ä¤£¨ì¦^¶Çªº[records]­È,¸Ó­È¥i¯à¨S¦³³]©w©Î¬Oªø«×¬°¹s¡C");
                if (!totalRecord) {
                    clearData();
                    if (isFirstQuery && failFunction) {
                        failFunction(resp);
                    }
                }
                return;
            }

            records = rtnRecords;
            // ³]©w§Ç¸¹
            dataControl.setSerialNnmber(records, thisAjaxRecordFrom);
            // ³]©wÀË®Ö¸ê®Æ
            var validateRecord = config.validateRecord;
            if (validateRecord !== undefined || validateRecord !== null) {
                validate_type = false;
                for (var i = 0; i < records.length; i++) {
                    records[i]['_tableuiValidateStatus'] = (getBoolean(validateRecord, true, [records[i], (i + 1)]));
                }
            }

            if (isFunction(beforeLoad)) { beforeLoad.call(main_div, main_div, table_id, this); }

            //²Ä¤@¦¸¬d¸ß¡A­n§ó·s°T®§
            if (isFirstQuery) {
                updateSelectOptions(totalOfRecords);
            }
            nowPage = Math.floor(start / pageSize) + 1;
            loadFrom(start);

            // fatch¼Ò¦¡¾É¤J¦X­p
            if (dataControl && resp.totalCountOfRecords) {
                dataControl.createTotalRecordBody(resp.totalCountOfRecords);
            }

            if (isFunction(afterLoad)) { afterLoad(main_div, main_div, table_id, this); }

  
            if (isFirstQuery && isFunction(successFunction)) {
                successFunction(resp);
			}else if(isFunction(fetchSuccessFunction)){
				fetchSuccessFunction(resp);
			}

        };

        function ajaxFail(resp , isFirstQuery) {
            clearData();
            if (isFirstQuery && isFunction(failFunction)) {
                failFunction(resp);
            }else if(isFunction(fetchFailFunction)){
				fetchFailFunction(resp);
			} else {
                // var msgDesc =  isObject(resp) &&  isObject(resp['ErrMsg']) && resp['ErrMsg']['displayMsgDescs'];
                // msgDesc = msgDesc ? ((msgDesc+'').replace(/\\n/g,'<br>'))  : '¸ê®Æªí¦b¶i¦æ¸ê®Æ§ó·s®Éµo¥Í¿ù»~';
                // alert(msgDesc);
                // updateToBottom( resp , '¸ê®Æªí¦b¶i¦æ¸ê®Æ§ó·s®Éµo¥Í¿ù»~');
            }
        };

        function ajaxIsSuccess(resp) {
            if (window.CSRUtil && isFunction(CSRUtil.isSuccess)) {
                return CSRUtil.isSuccess(resp);
            }
            if (!isObject(resp)) { return false; }

            var errMsg = resp['ErrMsg'];
            var returnCode = isObject(errMsg) && errMsg['returnCode'];
            var isSuccsee = isNumeric(returnCode) && paresInt(returnCode,10) >= 0;
            return isSuccsee;
        }

        function updateToBottom(resp, defaultMsg, isClear) {
            if (!isObject(resp)) { return; }
            var errMsg = resp['ErrMsg'];
            if(!isObject(errMsg)){ return; }
            var returnCode = errMsg.returnCode;
            var msgDesc = ((defaultMsg ? defaultMsg : (errMsg.displayMsgDescs))+'').replace(/\\n/g,'<br>');

            var getMsgBoard = function () {

                if (window.CSRUtil && isFunction(CSRUtil.getMsgBoard)) {
                    return CSRUtil.getMsgBoard();
                }

                var bottomFrame;
                if (top.frames['leftFrame'] && top.frames['leftFrame'].frames['bottomFrame']) {
                    bottomFrame = top.frames['leftFrame'].frames['bottomFrame'];
                } else if (parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame']) {
                    bottomFrame =  parent.frames['leftFrame'] && parent.frames['leftFrame'].frames['bottomFrame'];
                } else if (top.frames['bottomFrame']) {
                    bottomFrame =  top.frames['bottomFrame'];
                } else if (parent.frames['bottomFrame']) {
                    bottomFrame =  parent.frames['bottomFrame'];
                } else{
                    return null;
                }

                if (bottomFrame) {
                    if (bottomFrame.contentWindow) {
                        return bottomFrame.contentWindow.document.getElementById('cathay_common_msgBoard'); //¥]ÂÐ¦b IFRAME ¤¤
                    } else {
                        return bottomFrame.cathay_common_msgBoard; //ÂÂª©¡A±ÄFRAME¤À®Ø
                    }
                }
            };

            try {
                var msgBoard = getMsgBoard();
                if(!msgBoard){
                    return;
                }
                if (msgDesc) {
                    if (isNumeric(returnCode) && paresInt(returnCode,10) >= 0) {
                        msg = '<font color="DarkRed">' + msgDesc + '</font>';
                    } else {
                        msg = '<font color="DarkBlue ">' + msgDesc + '</font>';
                    }
                }else if(isClear === true){
                    msgBoard.innerHTML = '';
                }
                
            } catch (e) {
                if (window.console) {
                    console.log("¦s¨úbottomFrameµo¥Í¿ù»~:");
                    console.log(e);
                }
            }

        }

        function updateSelectOptions(newTotalRecord) {
            if (newTotalRecord === false || newTotalRecord != totalRecord) {
                while (controlSelect.hasChildNodes()) {
                    controlSelect.removeChild(controlSelect.firstChild);
                }
                if (newTotalRecord) {
                    totalRecord = newTotalRecord;
                    totalPage = Math.ceil(totalRecord / (pageSize + 0.0));
                    for (var select_count = 1 ; select_count <= totalPage ; select_count += 1) {
                        createElement("OPTION", { value: select_count }, null, null, null, controlSelect, "&nbsp;-&nbsp;" + select_count + "&nbsp;-&nbsp;");
                    }
                } else {
                    totalRecord = 0;
                    totalPage = 0;
                }
            }
        }

        this.hasRecords = function () { return records && records.length > 0; };

        //¨ú±o¸ê®Æ
        this.getAllRecords = getAllRecords;
        function getAllRecords(template) {
            if (window.tableUI_getFatchRecords === true) {
                if (template) {
                    return dataControl.getRecordsByTemplate(records || [], template);
                } else {
                    return records || [];
                }
            }
            alert("§å¦¸¬d¸ßµLªk¨ú±o¥þ³¡¸ê®Æ");
            return [];
        }

        this.getDeletedRecords = getDeletedRecords;
        function getDeletedRecords() {
            alert("§å¦¸¬d¸ßµLªk§R°£¸ê®Æ");
        }

        this.getCurrentPageRecords = getCurrentPageRecords;
        function getCurrentPageRecords(template) {
            if (!records || records.length === 0 ) { return [];}
            var start = (nowRecord_start - thisAjaxRecordFrom);
            var end = (nowRecord_next_start - thisAjaxRecordFrom);

            if(end <= start  || start < records.length ){ return []; }

            var currentRecord = records.slice(start, end);

            if (template) {
                return dataControl.getRecordsByTemplate(currentRecord || [], template);
            } else {
                return currentRecord || [];
            }
        }

        this.getErrorRecords = getErrorRecords;
        function getErrorRecords(template) {
            var errorRecords = [];
            var fatchRecords = getAllRecords();
            for (var i = 0 ; fatchRecords && (i < fatchRecords.length) ; i += 1) {
                if (fatchRecords[i]['_tableuiValidateStatus'] === false) {
                    errorRecords.push(fatchRecords[i]);
                }
            }

            if (errorRecords.length == 0) {
                return errorRecords;
            }

            return dataControl.getRecordsByTemplate(errorRecords, template);

        }

        this.getCorrectRecords = getCorrectRecords;
        function getCorrectRecords(template) {
            var non_errorRecords = [];
            var fatchRecords = getAllRecords();
            for (var i = 0 ; fatchRecords && (i < fatchRecords.length) ; i += 1) {
                if (fatchRecords[i]['_tableuiValidateStatus'] !== false) {
                    non_errorRecords.push(fatchRecords[i]);
                }
            }

            if (non_errorRecords.length == 0) {
                return non_errorRecords;
            }

            return dataControl.getRecordsByTemplate(non_errorRecords, template);
        }

        this.getUncheckedRecords = returnEmptyArray;
        this.getCheckedRecords = returnEmptyArray;
        this.getCheckedErrorRecords = returnEmptyArray;
        this.getCheckedCorrectRecords = returnEmptyArray;
        function returnEmptyArray() {
            return [];
        }

        this.getRecordsBy = getRecordsBy;
        function getRecordsBy(getTemplate, recordTemplate , dataExpireAlert) {
            if (!getTemplate) {
                return [];
            }

            if (isBasicType(getTemplate)) {
                getTemplate = (getTemplate + "").split(",");
            } else if (!isArray(getTemplate)) {
                return [];
            }

            var rtnList = [];
            var notInRangeRecNo = [];
            for (var i = 0  ; i < getTemplate ; i += 1) {
                var recNo = getTemplate[i];
                if (isNumeric(recNo) && recNo > 0 ) {
                    recNo = recNo - 1;
                    if (recNo >= thisAjaxRecordFrom && recNo < nextAjaxRecordFrom) {
                        rtnList.push(records[recNo - thisAjaxRecordFrom]);
                    } else {
                        notInRangeRecNo.push(recNo);
                    }
                }
            }
            if (notInRangeRecNo.length != 0) {
                var display_str = window.JSON ? JSON.stringify(notInRangeRecNo) : hasJsFramework ? toJSON(notInRangeRecNo) : notInRangeRecNo;
                if (dataExpireAlert !== false) {
                    alert("¥H¤U¸ê®ÆµLªk¨ú±o¡A¦]¬°¸Ó¸ê®Æ¤wµL¼È¦s\n" + display_str);
                } else {
                    window.console && window.console.log("¥H¤U¸ê®ÆµLªk¨ú±o¡A¦]¬°¸Ó¸ê®Æ¤wµL¼È¦s\n" + display_str);
                }
            }
            return dataControl.getRecordsByTemplate(rtnList, recordTemplate);
        }


        /* ¶×¥X */
        this.exportAllToXLS = exportEmptyArray;
        this.exportCheckToXLS = exportEmptyArray;
        function exportEmptyArray() {
            alert('«Ü©êºp fetch ¼Ò¦¡¤U¤£´£¨Ñ¶×¥X');
            return [];
        }


    }

    //¥~®Ø±±¨î¶µ functions
    function sizeController_impl() {

        var resizing = false;

        /* ¥HIntervalÀË¬d¬O§_»Ý­n¶i¦æresize */
        window.setInterval(function () {
            if (resizing) { return; }
            if (checkElementSizeIsChange(_tableui_vertical_resize)) { _tableUI_all_ui_resize(); }
            else if (checkElementSizeIsChange(main_div)) { resizeContent('outerDiv'); }
            else if (checkElementSizeIsChange(main_table)) { resizeContent('main_table'); }
            else if (checkElementSizeIsChange(fixed_table)) { resizeContent('fixed_table'); }
            else {
                if (displayDataArea.style.overflowY != 'scroll') {
                    //console.log(Math.abs(main_table.offsetHeight - displayDataArea.offsetHeight));
                    var displayAreaHeight = displayDataArea.offsetHeight;
                    if(main_table.offsetWidth >displayDataArea.offsetWidth ){  displayAreaHeight = displayAreaHeight - _tableuiScrollBarWidth; } 
                    if (Math.abs(main_table.offsetHeight - displayAreaHeight) > 3) { resizeContent('diffTableHeight'); return; }
                } 
                else  if (Math.abs(dataArea.offsetHeight - displayDataArea.offsetHeight) > 3) { resizeContent('diffContentHeight'); return; }
                else if (Math.abs(dataArea.offsetWidth - (displayDataArea.offsetWidth + fixedDataArea.offsetWidth)) > 3) {
                    resizeContent('diffContentWidth'); return;
                }
            }
        }, 100);

        
        var rePositing = -1 ;
        this.headerRePosition = headerRePosition;
        function headerRePosition() {
            if(rePositing >= 0 ){ return; }
            if (displayDataArea.style.overflowY != 'scroll') { return; }
            rePositing = 0;
            testHeaderIsChange(parseInt(getStyle(selectElement(dataArea,'thead th')[0],'top')||0,10));
        }
        function testHeaderIsChange(prevTop){

            if (!hasJsFramework){ return; }
            
            var hasPrevTop = isNumeric(prevTop); 
            var nowTop = displayDataArea.scrollTop;
            
            if( !hasPrevTop ){
                prevTop = nowTop;
            } else if (prevTop > nowTop) {
                selectElementThenEach(dataArea , "thead th" , function (sn , ele) { ele.style.top = '0px'; });
                prevTop = 0;
            }else if( prevTop == nowTop ){
                rePositing = -1;
                return;
            }
            // console.log("[TableUI:" + table_id + " - testHeaderIsChange] ­ì¥»Top: "  + prevTop + " ¥Ø«eÀ³¸ÓªºTop:" + nowTop);
            if ( hasPrevTop && Math.abs( prevTop - nowTop) > 2) {
                var to = Math.max(nowTop , 0);
                var from = Math.max(to - 20, 0);
                headerSildein(from, to);
            } else if( rePositing > 10){
                rePositing = -1;
                return;
            } else {
                rePositing = rePositing + ( hasPrevTop ? 2 : 1 );
                setTimeout(function () { testHeaderIsChange(prevTop); }, 300 );
            }
        }
        function headerSildein(from, to , isNext) {
            if( Math.abs(to - parseInt(displayDataArea.scrollTop)) > 2 ){
                rePositing++;
                setTimeout(function () { testHeaderIsChange(from); }, 300);
                return;
            }
            if (from > to || to == parseInt( selectElement(main_table,"thead")[0].style.top)) {
                rePositing = -1;
                return;
            }
            from = from+3;
           var target =  Math.min(from, Math.max(0,to-3));
           selectElementThenEach(dataArea , "thead th" , function (sn, ele) { ele.style.top = target + 'px'; });
           //console.log("headerSilde to " + target);
            setTimeout(function () { headerSildein(from, to, true); }, 4);
        }

        function checkElementSizeIsChange(node) {

            if (node && node.style.display == 'none') { return false; }
            
            var hor_width = node ? node.offsetWidth : -1;
            var org_hor_width = node ? parseInt(node.getAttribute('org_width') || 0, 10) : -1;

            var ver_height = node ? node.offsetHeight : -1;
            var org_ver_height = node ? parseInt(node.getAttribute('org_hight') || 0, 10) : -1;

            // console.log('outside resize check ver: '+ver_height+'  / '+org_ver_height+'  hor:'+hor_width+'  / '+org_hor_width);

            if ((hor_width > 0 && Math.abs(hor_width - org_hor_width) > 5)) {
                return true;
            }
            if ((ver_height > 0 && Math.abs(ver_height - org_ver_height) > 5)) {
                return true;
            }

            return false;
        }

        function saveNodeSize(node) {
            node.setAttribute('org_width', getStyle(node,'display') == 'none' ? '-5' : node.offsetWidth);
            node.setAttribute('org_hight', getStyle(node, 'display') == 'none' ? '-5' : node.offsetHeight);
        }

        this.doResize = resizeContent;

        function resizeContent(caller) {

            var maxAreaWidth = dataArea.offsetWidth ; // 2 = ¸ê®ÆÃä®Ø

            if (!maxAreaWidth || maxAreaWidth <= 5) {
                window.console && console.log("[TableUI:" + table_id + " - resizeContent] ¹ï¤º®e¨ú±oÅã¥Ü¤j¤p¿ù»~¡AµLªk¨ú±odataArea¼e«×(" + maxAreaWidth + ")  ¤w¤¤¤î ");
                return;
            }

            resizing = true;
            _tableUI_globe_lock();

            //console.log("[TableUI:" + table_id + " - resizeContent] caller : " + caller);
            displayDataArea.style.width = "10px";
            fixedDataArea.style.width = "10px";
         
            /* ¾ã²z¸ê®Æ¨C¦æ°ª«× */
            dataControl && dataControl.compareAllTableCellHeight();

            var overDiv = settingCtrl.settings.overDiv;
            var maxHeight = isObject(overDiv) ? overDiv.maxHeight : null;
            maxHeight = isNumeric(maxHeight) && maxHeight;

            var minHeight = isObject(overDiv) ? overDiv.minHeight : null;
            minHeight = isNumeric(minHeight) ? parseInt(minHeight, 10) : 200;

            var dataHeight = main_table.offsetHeight;
            var screenHeight = _tableui_vertical_resize.offsetHeight;

            if(overDiv === false){
                maxHeight = dataHeight + 2;
            } else if (!maxHeight || (maxHeight < 1 && maxHeight > 0)) {
                if (!maxHeight) {
                    /* ­Y¨Ï¥ÎªÌ¨S¦³¹w³]TableUI¤j¤p¡A¹w³]¤j¤p¬°¥i¥H¤£­n°Ê¥Î¨ì­¶­±±²¶b¡C */
                    maxHeight = screenHeight - main_div.offsetTop;
                    var testCell = main_div.parentNode;
                    while (testCell && testCell.tagName != 'BODY') {
                        var test_cell_position = getStyle(testCell, 'position');
                        var test_cell_display = getStyle(testCell, 'display');
                        /* ¤U­±¤T­Óª¬ºA·|³y¦¨¤l¤¸¯À offset ­«ºâ */
                        if (test_cell_position == 'absolute' || test_cell_position == 'fixed' || test_cell_position == 'relative' || test_cell_display.indexOf('inilne') >= 0) {
                            maxHeight = maxHeight - testCell.offsetTop;
                        }
                        testCell = testCell.parentNode;
                    }
                    maxHeight = maxHeight - 40;
                } else {
                    /* ­Y¨Ï¥ÎªÌ¹w´Á¤j¤p¥eµe­±ªº¬Y%¡C */
                    maxHeight = parseInt(screenHeight * maxHeight, 10);
                }

                /* ­Y³Ì¤j°ª«×¤p©ó³Ì¤p°ª«×(¹w³]400)¡A«h³Ì¤j°ª«×§ï¬°¿Ã¹õ°ª«×ªº85%¡C */
                if (maxHeight <= minHeight) {
                    maxHeight = parseInt(screenHeight * 0.85);
                }
            }

            //console.log("[TableUI:" + table_id + " - resizeContent] ¿Ã¹õ°ª«× : " + screenHeight + " ¥i¥Î°ª«× : " + maxHeight + " ###  ¸ê®Æ°ª«× : " + dataHeight);

            maxHeight = Math.min(maxHeight, dataHeight);

            if (dataHeight <= maxHeight || maxHeight <= minHeight) {
                maxHeight = null;
                displayDataArea.style.overflowY = 'visible';
                fixedDataArea.style.overflowY = 'visible';
                displayDataArea.style.height = '';
                fixedDataArea.style.height = '';
            } else {
                maxHeight = maxHeight - (main_div.offsetHeight - dataArea.offsetHeight) - 50;
                displayDataArea.style.overflowY = 'scroll';
                fixedDataArea.style.overflowY = 'hidden';
            }

            

            if (settingCtrl.settings.has_fixed) {
                /* ¥]§tfixedÄæ¦ì */
                fixedDataArea.style.display = '';
                var fixedAreaWidth = fixed_table.offsetWidth;
                var mainAreaWidth = main_table.offsetWidth;
                //console.log("[TableUI:" + table_id + " - resizeContent] ¥i¥Î¼e«× : " + maxAreaWidth + " ### ©T©w¸ê®Æ¼e«× : " + fixedAreaWidth + " + ¤@¯ë¸ê®Æ¼e«× : " + mainAreaWidth + " = " + (fixedAreaWidth + mainAreaWidth));

                if ((fixedAreaWidth + mainAreaWidth) <= maxAreaWidth) {

                    displayDataArea.style.overflowX = 'visible';
                    displayDataArea.style.width = (maxAreaWidth - fixedAreaWidth) + "px";
                    fixedDataArea.style.overflowX = 'visible';
                    fixedDataArea.style.width = fixedAreaWidth + 'px';

                    if (maxHeight) {
                        displayDataArea.style.height = maxHeight + 'px';
                        fixedDataArea.style.height = maxHeight + 'px';
                    }

                } else {
                    var helfPageSize = maxAreaWidth / 2;
                    var helfPageSize_f = Math.ceil(helfPageSize);
                    var helfPageSize_d = Math.floor(helfPageSize);

                    if (fixedAreaWidth < helfPageSize_f) {
                        //console.log("fixed small " + _tableuiScrollBarWidth);
                        displayDataArea.style.overflowX = 'scroll';
                        displayDataArea.style.width = (maxAreaWidth - fixedAreaWidth) + "px";
                        fixedDataArea.style.overflowX = 'visible';
                        fixedDataArea.style.width = fixedAreaWidth + 'px';
                        if (maxHeight) {
                            displayDataArea.style.height = maxHeight + 'px';
                            fixedDataArea.style.height = (maxHeight - _tableuiScrollBarWidth) + 'px';
                        }

                    } else if (mainAreaWidth < helfPageSize_d) {
                        //console.log("main small");
                        displayDataArea.style.overflowX = 'visible';
                        displayDataArea.style.width = mainAreaWidth + "px";
                        fixedDataArea.style.overflowX = 'scroll';
                        fixedDataArea.style.width = (maxAreaWidth - mainAreaWidth) + 'px';
                        if (maxHeight) {
                            displayDataArea.style.height = (maxHeight - _tableuiScrollBarWidth) + 'px';
                            fixedDataArea.style.height = maxHeight + 'px';
                        }
                    } else {
                        //console.log("half half");
                        displayDataArea.style.overflowX = 'scroll';
                        displayDataArea.style.width = helfPageSize_f + "px";
                        fixedDataArea.style.overflowX = 'scroll';
                        fixedDataArea.style.width = helfPageSize_d + 'px';
                        if (maxHeight) {
                            displayDataArea.style.height = maxHeight + 'px';
                            fixedDataArea.style.height = maxHeight + 'px';
                        }
                    }
                }
                addClassName(dataArea, 'hasFixed');
                displayDataArea.style.left = fixedDataArea.offsetWidth + 'px';
            } else {
                /* ¨S¦³fixedÄæ¦ì */
                fixedDataArea.style.display = "none";
                var mainAreaWidth = main_table.offsetWidth;
                //console.log("[TableUI:" + table_id + " - resizeContent] ¥i¥Î¼e«× : " + maxAreaWidth + " ### ¸ê®Æ¼e«× : " + mainAreaWidth);
                
                if (maxAreaWidth > mainAreaWidth) {
                    displayDataArea.style.overflowX = 'visible';
                } else {
                    displayDataArea.style.overflowX = 'scroll';
                }
                if (maxHeight) {
                    displayDataArea.style.height = maxHeight + 'px';
                }
                displayDataArea.style.left = '0px';
                displayDataArea.style.width = maxAreaWidth + "px";
                removeClassName(dataArea, 'hasFixed');
            }

            dataArea.style.height = displayDataArea.offsetHeight + 'px';

            headerRePosition();

            saveNodeSize(main_div);
            saveNodeSize(main_table);
            saveNodeSize(fixed_table);

            _tableUI_globe_unlock();
            resizing = false;

        }


        this.scrollTop = function () {
            if (fixedDataArea.style.display != 'hidden' && fixedDataArea.style.overflowY != 'visible') {
                fixedDataArea.scrollTop = 0;
            }
            if (displayDataArea.style.overflowY != 'visible') {
                displayDataArea.scrollTop = 0;
                //hasPrototype && $(dataArea).select("thead th").each(function (ele) { ele.style.top = '0px'; });
            }
        }

        this.scrollBottom= function () {
            if (fixedDataArea.style.display != 'hidden' && fixedDataArea.style.overflowY != 'visible') {
                fixedDataArea.scrollTop = fixedDataArea.scrollHeight;
            }
            if (displayDataArea.style.overflowY != 'visible') {
                displayDataArea.scrollTop = displayDataArea.scrollHeight;
                //hasPrototype && $(dataArea).select("thead th").each(function (ele) { ele.style.top = Math.max(displayDataArea.scrollTop-3,0) + 'px'; });
            }
        }

    }


    //utilitys 

    function setValueIfEmpty(obj, key, value) {
        if (!key || !value || !isObject(obj)) { return; }
        if (!obj[key]) { obj[key] = value; }
    }

    function getOptions(type, valueObj, optionKey, optionValue, elemAttrs, elemStyles, elemClasses, elemActions, defaultValue) {
        if (!type) { return; }
        type = type.toLowerCase();
        if (type != "checkbox" && type != "radio" && type != "option") { return; }
        var objIsArray = isArray(valueObj);
        var valueIsFunction = isFunction(optionValue);
        if (!objIsArray && !isObject(valueObj)) {
            return;
        } else if (objIsArray && !isBasicType(optionKey) && !(isBasicType(optionValue) && valueIsFunction)) {
            return;
        }
        if (!isObject(elemAttrs)) {
            elemAttrs = {};
        }
        var tagName;
        var isSelection = false;
        if (type == "option") {
            tagName = type;
            isSelection = true;
        } else {
            tagName = "input";
            elemAttrs.type = type;
        }
        var isCheckbox = !isSelection && type == "checkbox";

        if (isCheckbox && defaultValue) {
            defaultValue = defaultValue.split(",");
        }

        var fragment = document.createDocumentFragment();
        if (objIsArray) {
            for (var i = 0 ; i < valueObj.length ; i += 1) {
                var objData = valueObj[i];
                var key = objData[optionKey];
                var value;
                if (valueIsFunction) {
                    value = optionValue(key, objData);
                } else {
                    value = objData[optionValue];
                }

                var option = createElement(tagName, elemAttrs, elemStyles, elemClasses, elemActions);
                
                option.setAttribute('value' , key );
                
                var shouldBeSelect = false;
                if (!isCheckbox) {
                    if (defaultValue == key) {
                        shouldBeSelect = true;
                    }
                } else if (defaultValue) {
                    for (var x = 0 ; x < defaultValue.length ; x += 1) {
                        if (defaultValue[x] == key) {
                            shouldBeSelect = true;
                        }
                    }
                }
                if(shouldBeSelect){
                    if(isSelection){
                        option.setAttribute('selected' , true );
                    }else{
                        addClassName(option , 'shouldBeChecked');
                    }
                }

                var value_text = document.createTextNode(value);
                
                if (isSelection) {
                    fragment.appendChild(option);
                    option.appendChild(value_text);
                } else {
                    var label = createElement("label");
                    fragment.appendChild(label);
                    label.appendChild(option);
                    label.appendChild(value_text);
                }
            }
        } else {
            var k_v_exchange = (optionKey === true);
            for (key in valueObj) {
                var value;
                if (k_v_exchange) {
                    value = key;
                    key = valueObj[value];
                } else {
                    value = valueObj[key];
                }
                if (valueIsFunction) {
                    value = optionValue(key, value);
                }
                
                var option = createElement(tagName, elemAttrs, elemStyles, elemClasses, elemActions);
                
                option.setAttribute('value' , key );
                
                var shouldBeSelect = false;
                if (!isCheckbox) {
                    if (defaultValue == key) {
                        shouldBeSelect = true;
                    }
                } else if (defaultValue) {
                    for (var x = 0 ; x < defaultValue.length ; x += 1) {
                        if (defaultValue[x] == key) {
                            shouldBeSelect = true;
                        }
                    }
                }
                if(shouldBeSelect){
                    if(isSelection){
                        option.setAttribute('selected' , true );
                    }else{
                        addClassName(option , 'shouldBeChecked');
                    }
                }
                
                var value_text = document.createTextNode(value);
                
                if (isSelection) {
                    fragment.appendChild(option);
                    option.appendChild(value_text);
                } else {
                    var label = createElement("label");
                    fragment.appendChild(label);
                    label.appendChild(option);
                    label.appendChild(value_text);
                }
            }
        }
        return fragment;
    }
    function getOptionValues(target) {
        var rtnValue = "";
        var test_opts = target.getElementsByTagName("input");
        for (var i = 0 ; i < test_opts.length ; i++) {
            var test_opt = test_opts[i];
            if ((test_opt.checked || hasClassName(test_opt, "shouldBeChecked"))) {
                rtnValue = rtnValue + test_opt.getAttribute("value") + ",";
            }
        }
        return rtnValue.substring(0, rtnValue.length - 1);
    }

    function getOptionDisplay(target, value) {
        if (target.tagName == "SELECT") {
            var test_opt = target.firstChild;
            while (test_opt) {
                if (test_opt.tagName == "OPTION" && test_opt.value == value) {
                    return test_opt.textContent;
                }
                test_opt = test_opt.nextSibling;
            }
            return "";
        } else {
            var rtnValue = "";
            var test_opts = target.getElementsByTagName("input");
            for (var i = 0 ; i < test_opts.length ; i++) {
                var test_opt = test_opts[i];
                if ((test_opt.checked || hasClassName(test_opt, "shouldBeChecked"))) {
                    rtnValue = rtnValue + test_opt.nextSibling.textContent + ",";
                }
            }
            return rtnValue.substring(0, rtnValue.length - 1);
        }

    }

    function ExchangeToShortText(input, length) {
        if (!input) { return "..."; }
        var content = input.split("\n")[0];
        if (isNumeric(length)) {
            var byteCount = 0;
            var charCount = 0;
            for (var i = 0; i < content.length; i++) {
                content.charCodeAt(i) < 256 ? byteCount++ : byteCount += 2;
                if (byteCount > length) {//³Ì«á¬°¤¤¤å¡A¥B¶W¥XÀ³Åã¥Ü¦r¼Æ
                    break;
                } else if (byteCount == length) {
                    charCount++;
                    break;
                } else {
                    charCount++;
                }
            }
            return content.substr(0, charCount) + "...";
        } else {
            return content + "...";
        }
    }

    function getBoolean(value, default_boolean, params) {
        if (isFunction(value)) {
            if (params && isArray(params)) {
                value = value.apply(this, params);
            } else {
                value = value();
            }
        }
        if (value !== (!default_boolean)) {
            return default_boolean;
        }
        return !default_boolean;
    }

    function getElement(testElement, whenNULL, function_params, function_input_params_part) {

        if (isElement(testElement, true)) {
            return testElement;
        }

        if (isFunction(testElement)) {
            if (function_params) {
                if (function_input_params_part && isArray(function_params)) {
                    testElement = testElement.apply(this, function_params);
                } else {
                    testElement = testElement.call(this, function_params);
                }
            } else {
                testElement = testElement();
            }
        }

        if (!isElement(testElement, true)) {
            if (!isBasicType(testElement)) {
                testElement = isBasicType(whenNULL) ? whenNULL : "¡@";
            }

            /* Âà¦¨html¿é¥X¡A¦]¬°fragment¤£¯à¨Ï¥ÎinnerHTML¡A©Ò¥H¥ý«Ø¥ß¤@­Óspan¡A¦A±Nspan¤UªºªF¦è·h²¾fragment */
            var temp_span = createElement("span");
            temp_span.innerHTML = testElement;

            testElement = createFragment(temp_span.childNodes);
            
        }

        return testElement;
    }

    function setAttr( target , attr_name , attr_val){
        if (!isElement(target)) {
            return;
        }
        if(hasPrototype){
            Element.writeAttribute(target , attr_name , attr_val);
        }else if(hasjQuery){
            $(target).attr(attr_name,attr_val);
        }else{
            target.setAttribute(attr_name,attr_val);
        }
    }

    function getEventTarget(e) {
        if (!e) e = window.event;
        var target = e.target || e.srcElement;
        if (isElement(target)) {
            return target;
        }
        if (isElement(e)) {
            return e;
        }
        return false;
    }

    function getParentByTagName(node, tagName) {
        if (!isElement(node) || !isBasicType(tagName)) { return null; }
        tagName = tagName.toUpperCase();
        do {
            node = node.parentNode;
            if (!node || node.tagName == "BODY") { return null; }
        } while (node.tagName != tagName);
        return node;
    }

    function setEventObserve(elem, eventName, func) {
        if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName) || !isFunction(func)) { return; }
        if (hasPrototype) {
            Event.observe(elem, eventName, func);
        } else if (hasjQuery) {
            $(elem).on(eventName, func);
        } else if (elem.removeEventListener) {						//DOM2±µ¤f with bubble
            elem.addEventListener(eventName, func, false);
        } else if (elem.detachEvent) {					//IE DOM2±µ¤f  with bubble
            elem.attachEvent('on' + eventName, func);
        } else {											//DOM0±µ¤f without bubble
           elem['on' + eventName] = func;
        }
    }

    function stopEventObserving(elem, eventName, func) {
        if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName)) { return; }
        if (hasPrototype) {
            Event.stopObserving(elem, eventName, func);
        } else if (hasjQuery) {
            $(elem).off(eventName, func);
        } else if (elem.removeEventListener) {						//DOM2±µ¤f with bubble
            elem.removeEventListener(eventName, func);
        } else if (elem.detachEvent) {						//IE DOM2±µ¤f  with bubble
            elem.detachEvent('on' + eventName, func);
        } else {											//DOM0±µ¤f without bubble
            elem['on' + eventName] = null;
        }
    }

    function cancelEventBubble(e) {
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

    function fireEventObserving(elem, eventName) {
        if (!isElement(elem)) { return; }
        if(hasPrototype){
            try{
                Event.fire(elem, eventName);
            }catch(e){}
            return;
        }
        if(hasjQuery){
            try{
                $(elem).trigger(eventName);
            }catch(e){}
            return;
        }
        try {
            elem[eventName]();
        } catch (exception) {
            try {
                var a = document.createEvent('MouseEvents');
                a.initEvent(eventName, true, true);
                elem.dispatchEvent(a);
            } catch (exception) {
                try {
                    elem.fireEvent('on' + eventName);
                } catch (exception) {
                    try {
                        elem['on' + eventName]();
                    } catch (exception) {
                    }
                }
            }
        }
    }

    function isElement(node, allowFragment) {
        //nodeType == 1 --> DOM
        //nodeType == 3 --> TextNode
        //nodeType == 11 --> Fragment
        return !!(node && ((node.tagName && node.nodeType === 1) || node.nodeType === 3 || (allowFragment && node.nodeType === 11)));
    }

    function isString(node) {
        return !!(isBasicType(node) && getType(node) === '[object String]');
    }

    function isNumeric(node) { return isBasicType(node) && (/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); }

    function isBasicType(node) {
        var type = typeof (node);
        return !!(type === 'string' || type === 'number' || type === 'boolean');
    }

    function isArray(node) {
        return !!(node && getType(node) === '[object Array]' && isNumeric(node.length));
    }

     function isNodeList(node) {
         if(ie_ver && ie_ver <= 8 ){
             if(!(node && getType(node) === '[object Object]' && isNumeric(node.length))){
                 return false;
             }
             for( var i = 0 ; i < node.length ; i++ ){
                 if(!node[i] || !isElement(node[i]) ){
                     return false;
                 }
             }
             return true;
         }

        return !!(node && getType(node) === '[object NodeList]' && isNumeric(node.length));
    }

    function isObject(node) {
        return !!(node && getType(node) == '[object Object]' && !isArray(node) && !isFunction(node));
    }

    function isFunction(node) {
        return !!(node && getType(node) === '[object Function]');
    }

    function isInArray(array, obj) {
        if (!isArray(array)) { return -1; }
        for (var i = 0 ; i < array.length ; i++) {
            if (("" + array[i]) === ("" + obj)) { return i; }
        }
        return -1;
    }

    function getType(node) {
        if (typeof (node) === 'undefined') { return "undefined"; }
        return Object ? Object.prototype.toString.apply(node) : "";
    }

    function getInteger(val, default_int) {
        default_int = default_int || 0;
        if (!isNumeric(val)) { return default_int; }
        return parseInt(val, 10);
    }

    function getCellAttributeToInteger(cell, attr, default_int) {
        default_int = default_int || 0;
        if (!isElement(cell)) { return default_int; }
        var val = cell.getAttribute(attr);
        if (!isNumeric(val)) { return default_int; }
        return parseInt(val, 10);
    }

    function addClassName(node, className) {
        if (isBasicType(className) && !hasClassName(node, className)) {
            node.className = trim((node.className || "") + " " + className);
        }
    }

    function getClassName(node) {
        var classes = node.className;
        if (!isBasicType(classes)) { return []; }
        classes = trim(classes.replace(/\s\s/g, " "));
        return stringToArray(classes, " ");
    }

    function removeClassName(node, compare) {
        if (!isBasicType(compare)) { return false; }
        var classes = node.className;
        if (!isBasicType(classes)) { return false; }
        compare = compare.replace(/\\/gi, "\\\\");

        var reg = new RegExp("(^" + compare + "\\s)|(\\s" + compare + "\\s)|(\\s" + compare + "$)|(^" + compare + "$)", "gi");
        node.className = classes.replace(reg, " ").replace(/\s\s/gi, " ");
    }

    function hasClassName(node, compare) {
        if (!isElement(node) || !isBasicType(compare)) { return false; }
        var classes = node.className;
        if (!isBasicType(classes)) { return false; }
        compare = compare.replace(/\\/gi, "\\");

        var reg = new RegExp("(^" + compare + "\\s)|(\\s" + compare + "\\s)|(\\s" + compare + "$)|(^" + compare + "$)", "gi");

        return classes.match(reg) != null;
    }

    function getFormElementValue(formElement){
        if(!isElement(formElement)){return '';}
        if(formElement.tagName != 'INPUT' && formElement.tagName != 'SELECT' && formElement.tagName != 'TEXTAREA'){
            return '';
        }
        if(hasPrototype){
            return Form.Element.getValue(formElement);
        }
        if(hasjQuery){
            return $(formElement).val();
        }
        if(isFunction(formElement.getValue)){
            return formElement.getValue();
        }
        if(formElement.tagName == 'TEXTAREA'){
            return formElement.innerHTML;
        }
        return formElement.value;

    }

    function setFormElementValue(formElement , value){
    	if(formElement.tagName == 'BUTTON'){
	    	if(!formElement.type){
				formElement.type= 'button';
			}
	    	formElement.innerHTML = value;
	    	return;
	    }
        if(!isElement(formElement)){return;}
        if(formElement.tagName != 'INPUT' && formElement.tagName != 'SELECT' && formElement.tagName != 'TEXTAREA'){
            return;
        }
        if(formElement.tagName == 'TEXTAREA'){
            if(value === null || value === undefined){
                value = '';
            }else if( isString(value) ){
                value = value.replace(/<br>/gi,'\n').replace(/<\/br>/gi,'\n');
            }else{
                value = '' + value;
            }
            formElement.innerHTML = value;
            return;
        }
	    if(formElement.tagName == 'INPUT'){
	    	var type = (''+formElement.type).toLowerCase();
	    	if(type == 'button'){
		    	formElement.value = value;
		    	return;
			}else if(!type){
				formElement.type = 'text';
			}
	    }
        if(hasPrototype){
            return Form.Element.setValue(formElement,value);
        }
        if(hasjQuery){
            $(formElement).val(value);
            return;
        }
        if(isFunction(formElement.setValue)){
            formElement.setValue(value);
            return;
        }
        formElement.value = value;

    }


    function stringToArray(stringValue, splitChar) {
        if (isArray(stringValue)) { return stringValue; }
        if (!isBasicType(stringValue)) { return [trim(stringValue)]; }
        var strings = stringValue.split(splitChar);
        var rtnArray = [];
        for (var i = 0 ; i < strings.length ; i = i + 1) {
            var str = trim(strings[i]);
            if (isBasicType(str) && str != "undefined") {
                rtnArray.push(str);
            }
        }
        return rtnArray;
    }

    function trim(value) {
        return isString(value) ? value.replace(/(^\s*)|(\s*$)/g, "").replace(/^&nbsp;|&nbsp;$/g, "") : value;
    }

    function toJSON( data , isAlertWhenError ){
        try{
            if(hasPrototype){
                return Object.toJSON(data);
            }
            if(window.JSON && JSON.stringify){
                return JSON.stringify(data);
            }
            if(isAlertWhenError === true){ alert('TableUI toJSON Error! no stringify method definded.');}
            return '';

        }catch(e){
            if(isAlertWhenError === true){ alert('TableUI toJSON Error! ' + e);}
            return "";
        }
    }

    function createElement(node, attrs, styles, classes, events, appendAt, content, createDocument) {

        if (!isElement(node)) {
            if (isString(node)) {
                node = (createDocument || document).createElement(node);
            } else {
                return;
            }
        }

        if (isObject(attrs)) {
            for (var key in attrs) {
                if (isBasicType(attrs[key])) {
                    var lowerCaseKey = (key + "").toLowerCase();
                    if(lowerCaseKey == 'class' || lowerCaseKey == 'classname'){
                        node.className = attrs[key];
                    }else if(lowerCaseKey == 'innerhtml' || lowerCaseKey == 'innertext' || lowerCaseKey == 'contenttext'){
                        if(content === null){
                            content = attrs[key];
                        }
                    }else if ( lowerCaseKey != 'value') {
                        node.setAttribute(key, attrs[key]);
                    } else {
                        if (isFunction(node.setValue)) {
                            node.setValue(attrs[key]);
                        } else {
                            node.value = attrs[key];
                        }
                    }
                }
            }
        }

        if (isObject(styles)) {
            for (var key in styles) {
                if (isBasicType(styles[key])) {
                    node.style[key] = styles[key];
                }
            }
        }

        if (isArray(classes)) {
            for (var i = 0  ; i < classes.length ; i = i + 1) {
                addClassName(node, classes[i]);
            }
        }

        if (isObject(events)) {
            for (var key in events) {
                setEventObserve(node, key, events[key]);
            }
        }

        /*
        if (content !== null && content !== undefined && content !== "null" && content !== "undefined") {
            node.appendChild(getElement(content));
        }
        */
        appendElement( node , content);

        if (isElement(appendAt, true)) {
            appendAt.appendChild(node);
        }

        return hasPrototype ? $(node) : node;
    }

    function updateElement(target , val){
        if (!isElement(target)) { return; }
        target. innerHTML = '';
        appendElement(target , val);
    }

    function appendElement(target , val){
        if (!isElement(target)) { return; }
        if(isBasicType(val)){
            var tempElement = createElement('div');
            tempElement.innerHTML = val;
            var newFrag = createFragment(tempElement.childNodes);
            target.appendChild(newFrag);
        }else if(isElement(val,true)){
            target.appendChild(val);
        }
    }

    function removeElement(target){
        if (!isElement(target)) { return; }
        var parent = target.parentNode;
        if(parent){
            parent.removeChild(target);
        }
    }


    function createFragment(elems) {
        var fragment = document.createDocumentFragment();
        if (isArray(elems) || isNodeList(elems)) {
            for (var i = elems.length - 1 ; i >= 0  ; i = i - 1) {
                var elem = getElement(elems[i]);
                if (elem) {
                    if(!fragment.childNodes.length){
                        fragment.appendChild(elem);
                    }else{
                        fragment.insertBefore(elem, fragment.firstChild);
                    }
                }
            }
        }
        return fragment;
    }

    function selectElement( parent , selection ){
        if(!hasPrototype && !hasjQuery ){ alert('[TableUI - selectElement] needs javascript framework: prototype.js or jQuery.js!'); return;}
        if(!isElement(parent)){ return []; }
        if(!isString( selection)){ return []; }
        if(hasPrototype){
            return Element.select( parent , selection );
        }else{
            return $(parent).find(selection);
        }
    }

    function selectElementThenEach( parent , selection , func ){
        var items = selectElement( parent , selection );
        if( !items || items.length == 0 ){ return items; }
        if( !isFunction(func) ){ return item; }
        for(var i = 0 ; i < items.length ; i++ ){
            func.call( parent , i ,items[i] );
        }
        return items;
    }

    function cloneObject(orgObject) {
        var returnObject;
        var hasValue = false;
        if (isElement(orgObject)) {
            hasValue = false;
        }else if (isArray(orgObject)) {
            returnObject = [];
            for (var i = 0 ; i < orgObject.length ; i = i + 1) {
                var cloneData = cloneObject(orgObject[i]);
                //if(cloneData === null){ continue; }
                returnObject[i] = cloneData;
            }
            hasValue = true;
        } else if (isObject(orgObject)) {
            returnObject = {};
            for (var key in orgObject) {
                var cloneData = cloneObject(orgObject[key]);
                //if (cloneData === null) { continue; }
                returnObject[key] = cloneData;
            }
            hasValue = true;
        } else if (isBasicType(orgObject)) {
            returnObject = orgObject;
            hasValue = true;
        }

        if (!hasValue) { return null; }

        return returnObject;
    }

    function getStyle(elem, name) {
        if (elem.style[name])
            return elem.style[name];
        else if (elem.currentStyle)
            return elem.currentStyle[name];
        else if (document.defaultView && document.defaultView.getComputedStyle) {
            name = name.replace(/([A-Z])/g, "-$1");
            name = name.toLowerCase();
            var s = document.defaultView.getComputedStyle(elem, "");
            return s && s.getPropertyValue(name);
        }
        else
            return null;
    }

}

function getCellByTagName(node, tagName , allowFragment) {
    if (!(node && ((node.tagName && node.nodeType === 1) || node.nodeType === 3 || (allowFragment && node.nodeType === 11)))) { return; }
    tagName = tagName.toUpperCase();
    while (node.tagName != tagName) {
        node = node.parentNode;
        if (!node || node.tagName == "BODY") { return null; }
    };
    return node;
}


function ExportXLSWithJSON(JSON){
    var submitForm = document.createElement("form");
    submitForm.setAttribute('target', 'submitForm');
    submitForm.setAttribute('action', '/ZRWeb/xls');
    submitForm.setAttribute('method', 'post');
    submitForm.style.display = 'none';

    var input1 = document.createElement("input");
    input1.setAttribute('name', 'xlsData');
    input1.setAttribute('value', JSON);
    
    submitForm.appendChild(input1);
    document.body.appendChild(submitForm);
    submitForm.submit();
    document.body.removeChild(submitForm);
}

function TableUIsExportToXLS( fileName , fileData ){
    if (!Object.isArray(fileData)) { return false; }
    for (var i = 0; i < fileData.length; i = i + 1) {
        if (!fileData[i]) { return false; }
    }
    var jsonString = { fileName: fileName + '.xls', sheets: fileData };
    try {
        if (window.Prototype) {
            jsonString = Object.toJSON(jsonString);
        } else if (window.JSON && JSON.stringify) {
            jsonString = JSON.stringify(jsonString);
        } else {
            alert('TableUIsExportToXLS Error! no stringify method definded.');
            return false;
        }
    } catch (e) {
        alert('TableUIsExportToXLS Error! ' + e);
        return false;
    }
    ExportXLSWithJSON(jsonString);
    return true;
}

function getTableUIByElement(elem) {
    var div = getCellByTagName(elem, "div");
    while (div && div.getAttribute('isTableUIParent') != 'Y') {
        div = getCellByTagName(div.parentNode, "div");
    }
    if (!div || !div.getAttribute('id')) { return; }
    return _tableui_setting_maping[div.getAttribute('id')];
    
}

//¨ú±o¤Ä¿ïªº¦h(³æ)µ§¸ê®Æ (¦^¶Ç¤@­ÓArray)
function getValueByElement(elem, valueTemplate) {
    var grid = getTableUIByElement(elem);
    if (!grid) { return []; }
    return grid.getRecordsByCell(elem, valueTemplate);
}


function validNumber(node, event, floatNum) {
    if (!event) { return true; }
    event.returnValue = true;

}

function validDate(node, event) {
    if (!event) { return true; }
    event.returnValue = true;
}

function setValidRecord( node , dataObjs , validResult , msg ){
    var grid = getTableUIByElement(node);
    if (!grid) { return false; }
    return !grid.setValidRecord(node, validResult);
}

function getValidRecord( node ){
    var grid = getTableUIByElement(node);
    if (!grid) { return false; }
    var errorRecords = grid.getErrorRecords(node);
    if (errorRecords && errorRecords.length > 0) {
        return errorRecords;
    }
    return false;
}