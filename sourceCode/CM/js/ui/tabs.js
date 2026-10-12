if (!window.CSS_locate_base || window.CSS_locate_base !== false) {
    window.CSS_locate_base = false;
    var css_regExp = new RegExp(/.css$/i);
    var css = document.getElementsByTagName('link');
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
var css_filePath = 'html/CM/css/ui/tabs.css';
if (window.CSS_locate_base) {
    document.write('<link rel="stylesheet" type="text/css" href="' + CSS_locate_base + css_filePath + '" />');
} else if (window.HTML_locate_base) {
    var PROD_CssBase = HTML_locate_base.replace(/Web\//, 'Docs/');
    document.write('<link rel="stylesheet" type="text/css" href="' + HTML_locate_base + css_filePath + '" />');
    document.write('<link rel="stylesheet" type="text/css" href="' + PROD_CssBase + css_filePath + '" />');
}

var tabs_js_path = document.getElementsByTagName('script');
if (tabs_js_path.length) {
    var tabs_js_regExp = new RegExp(/tabs.js$/i);
    for (var i = tabs_js_path.length - 1 ; i >= 0  ; i--) {
        if (tabs_js_regExp.test(tabs_js_path[i].src)) {
            tabs_js_path = tabs_js_path[i].src;
            break;
        }
    }
    if (i < 0) {
        tabs_js_path = false;
    }
} else {
    tabs_js_path = false;
}

/* ¬ö¿ý¥»­¶©Ò·s¼Wªºtabs */
var _tab_setting_map = {};
var _tab_vertical_resize = null
var _tab_stop_resize_cover = null;
var _tab_lock = 0;

var _tab_pageResizeFunction = function (e) {
    if (_tab_lock > 0) { return; }
    //if (_tab_popupwin_changeTopScrollHeight_tag) { return; }
    for (key in _tab_setting_map) {
        if (_tab_setting_map[key]) {
            _tab_setting_map[key].resize('O');
        }
    }
};

/* ­Y¬O¥]¦bpopupwin¤¤¡A»Ý­nÀË¬dpopupwin°ª«× */
var _tab_popupwin_changeTopScrollHeight = false;
var _tab_lock = 0;
function _tabs_globe_lock() {
    _tab_lock++;
}

function _tabs_globe_unlock() {
    _tab_lock--;
    if (_tab_popupwin_changeTopScrollHeight && _tab_lock == 0) {
        _tab_popupwin_changeTopScrollHeight(Math.max(document.body.scrollHeight, document.documentElement.scrollHeight));
    }
}
function Tabs(id, config) {

    /* ÂÂ³]©w¤èªkÂà´« */
    if (isObject(id)) {
        config = id;
        id = config.id;
    }
    config = config || {};
    config.onClickAction = isFunction(config.onClickAction) ? { all_clickAction: config.onClickAction } : (isObject(config.onClickAction) ? config.onClickAction : {});

    /* ¨ú±o©w¦ì¤¸¯À */
    if (!isBasicType(id)) { alert("tabs.js ªì©l¿ù»~¡Aª«¥ó«¬ºA¤£²Å id= '" + id + "'"); return; }
    var main_node = getDOMs('#' + id)[0];
    if (!isElement(main_node)) { alert("tabs.js ªì©l¿ù»~¡AµLªk¨ú±o§@¥Îª«¥ó id= '" + id + "'"); return; }

    /* debug¼Ò²Õ */
    var isDebug = window.console && config.debug === true;
    this.setDebug = function (sts) { isDebug = window.console && sts === true; }
    function debug(func, msg) { isDebug && console.log('[tabs - ' + func + ' ] ' + msg); }

    /* ¨ú±o¦X¨Öª«¥ó */
    var tabs = config.tabs;
    if (!isArray(tabs)) {
        /* ±qDOM³]©w¨ú±o¤¸¯À */
        var find_id = main_node.getAttribute("find");
        if (find_id) {
            tabs = getDOMs("*[tabs=" + find_id + "]");
        } else {
            tabs = main_node.childNodes;
        }
        if (tabs) {
            var temp_tabs = []; /* ¦]¬°¥Îchildren·|°ÊºA´î¤Ö¡A¬G­n¥t¥~Àx¦s */
            for (var i = 0 ; i < tabs.length ; i = i + 1) {
                var tab = tabs[i];
                if (!isElement(tab)) { continue; }
                temp_tabs.push(tab)
                if (!tab.id) {
                    tab.id = id + "_tab_" + i;
                }
                if (tab.getAttribute('subTab') == 'Y') {
                    if (getDOMs("*[is_subTab]", tab).length == 0) {
                        var child = tab.firstChild;
                        while (child) {
                            child.setAttribute('is_subTab', 'Y');
                            child = child.nextSibling;
                        }
                    }
                    var subs = getDOMs("*[is_subTab]", tab);
                    for (var j = 0 ; subs && j < subs.length ; j = j + 1) {
                        if (!subs[j].id) {
                            subs[j].id = id + "_tab_" + i + "+" + j;
                        }
                    }
                }
            }
            tabs = temp_tabs;
        }
    } else {
        /* ±q³]©wÀÉ¨ú±o¤¸¯À -- Âà´«©w¸qªºfunction  */
        var getElementFromSetting = function (tabs_setting) {

            if (!isObject(tabs_setting) || !isBasicType(tabs_setting.id)) { return; }

            var node = getDOMs("#" + tabs_setting.id)[0];
            if (!isElement(node)) { return; }

            node.setAttribute("blockTitle", tabs_setting.title);

            if (!!tabs_setting.defaultSelect) {
                node.setAttribute("init", "Y");
            } else {
                node.removeAttribute("init");
            }

            if (isFunction(tabs_setting.onClickAction)) {
                config.onClickAction[tabs_setting.id] = tabs_setting.onClickAction;
            }

            /* §PÂ_¬O§_­n¦³subTabs  */
            if (isArray(tabs_setting.subTabs)) {
                node.setAttribute("subTab", "Y");
                /*while (node.firstChild) {
                    node.parentNode.appendChild(node.firstChild);
                }*/
                for (var i = 0 ; i < tabs_setting.subTabs.length ; i++) {
                    var tab = getElementFromSetting(tabs_setting.subTabs[i]);
                    if (tab) {
                        tab.setAttribute('is_subTab', 'Y');
                        node.appendChild(tab);
                    }
                }
            } else {
                node.removeAttribute("subTab");
            }

            return node;
        }
        /* ±q³]©wÀÉ¨ú±o¤¸¯À¡A±N¿é¥X´«¦¨Array<DOM>*/
        var temp_tabs = [];
        for (var i = 0 ; i < tabs.length ; i = i + 1) {
            var tab = getElementFromSetting(tabs[i]);
            if (tab) {
                temp_tabs.push(tab);
            }
        }
        tabs = temp_tabs;
    }
    if (tabs.length <= 0) { alert("tabs.js ªì©l¿ù»~¡AµLªk¨ú±o¤º³¡ª«¥ó"); return; }

    /* ´«­¶®Éªºcover */
    var coverPage;
    if (config.beforeSwitchShowCover === true) {
        coverPage = CSRUtil ? CSRUtil.createCoverPage('_frontCover') : null;
        if (coverPage) { coverPage.hide(); }
    }

    /* ¥~®Ø */
    var tabs_main = createElement("DIV", { id: id, noBlockBorder: true }, null, ["tabs"]);

    /* ²Ä¤@¼h¿ï³æ */
    var tabs_menu_div = createElement("DIV", null, null, ["tabs_menu"], null, tabs_main);
    var tabs_menu = createElement("UL", null, null, ['tabs_menu_ul'], null, tabs_menu_div);

    /* ²Ä¤G¼h¿ï³æ */
    var tabs_sub_menu = createElement("DIV", null, null, ["tabs_sub_title"], null, tabs_main);

    /* ¦s©ñ©Ò¦³¤º®e­¶ªº¤¸¯À  */
    var content_container = createElement("DIV", null, null, ["content_container"], null, tabs_main);
    var tabs_content = createElement("UL", null, null, ["tabs_content"], null, content_container);

    /* ¥Ø«e³Q¿ï¾Üªº¬ö¿ý */
    var active_page = null;

    /* ªì©ltab ( from 0) */
    var defaultSelect = config.selected;
    var isShowAll;

    /* ±N¿é¤J¤¸¯À¡A«Ø¥ß¿ï³æ¶µ¥Ø¡A¨Ã«Ê¸Ë¨ì content li ¨Ã¸ÑªR¥X subTabs */
    var newTabs = [];
    for (var i = 0 ; i < tabs.length ; i = i + 1) {
        var tab_node = tabs[i];
        createMenuItemAndContentItem(newTabs, tab_node, tabs_menu);
    }
    tabs = newTabs;

    /* ­Y¨Ï¥ÎªÌ»Ý­n"¥þ³¡"­¶ÅÒ  */
    var all_node;
    if (config.all === true) { config.all = {}; }
    if (isObject(config.all)) {
        all_node = createElement("LI", {'id':'tabMenuItem-'+id+'-show_all'}, null, ["all", "menu_li"], { click: showAll }, null, config.all.title || "¥þ³¡");
        if (config.all.position == "left") {
            tabs_menu.insertBefore(all_node, tabs_menu.firstChild);
        } else {
            tabs_menu.appendChild(all_node);
        }

        if (config.all.selected === true) {
            defaultSelect = "showAll";
        }
    }

    /* ±N¨S¦³¥Î¨ìªº¤¸¯À·hÂ÷ tabs ¤¸¥ó  */
    while (main_node.firstChild) {
        if (isElement(main_node.firstChild)) {
            main_node.firstChild.style.display = 'none';
        }
        main_node.parentNode.appendChild(main_node.firstChild);
    }

    /* ±N¤¸¥ó©w¦ì¨ì­¶­±¤W(´À´«) */
    main_node.parentNode.replaceChild(tabs_main, main_node);

    //¬O§_¤Þ¤Jpopupwin
    if (!_tab_popupwin_changeTopScrollHeight) {
        try {
            _tab_popupwin_changeTopScrollHeight = window.parent && window.parent.popupWin && window.parent.popupWin.changeTopScrollHeight;
            if (!_tab_popupwin_changeTopScrollHeight || !Object.isFunction(_tab_popupwin_changeTopScrollHeight)) {
                _tab_popupwin_changeTopScrollHeight = false;
            }
        } catch (exception) {
            debug('popupwin Exception',exception);
            _tab_popupwin_changeTopScrollHeight = false;
        }
    }

    /* ¬O§_¦³Cover­n¼È°±resize */
    if (window.CSRUtil && !_tab_stop_resize_cover) {
        _tab_stop_resize_cover = CSRUtil.createCoverPage({ 'id': '_frontCover' });
    }

    /* «Ø¥ß­¶­±°»´ú¾¹ */
    if (!_tab_vertical_resize) {
        _tab_vertical_resize = createElement(
            'div'
		    , { id: '_tab-vertical-resize-detection' }
		    , null
		    , ['tab-resize-detection', 'vertical']
		    , null
		    , document.body
	    );
    }

    /* µù¥U¦Ü¥þ°ì  */
    _tab_setting_map[id] = this;

    /* iframe ­Yªì©lµL­È ªì©l³]©w dummy.jsp ¥HÁ×§K¸Ñ½X¥X²{¶Ã½X */
    var iFrames = window.HTML_locate_base && tabs_main.getElementsByTagName('iframe');
    for(var i = 0 ; i <iFrames.length ; i++ ){
        var src = iFrames[i].getAttribute('src');
        if(!src || src == '#'){
            try{
                iFrames[i].contentWindow.location.replace(window.HTML_locate_base+'html/CM/js/ajax/dummy.jsp' );
            }catch(e){
                iFrames[i].setAttribute('src' , window.HTML_locate_base+'html/CM/js/ajax/dummy.jsp' );
            }
        }
        
    }
    
    /* Åã¥Üªì©lµe­± */
    if (defaultSelect == "showAll") {
        showAll(all_node);
    } else {
        defaultSelect = defaultSelect || tabs_menu.getAttribute('init') || 0;
        selectContent(defaultSelect, false);
    }

    var resizing = false;
    /* ¥HIntervalÀË¬d¬O§_»Ý­n¶i¦æresize */
    window.setInterval(function () {
        if (resizing) { return; }
        if (checkElementSizeIsChange(content_container)) { resize('content_container'); }
        else if (checkElementSizeIsChange(tabs_content)) { resize('tabs_content'); }
    }, 200);

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
        node.setAttribute('org_width', getStyle(node, 'display') == 'none' ? '-5' : node.offsetWidth);
        node.setAttribute('org_hight', getStyle(node, 'display') == 'none' ? '-5' : node.offsetHeight);
    }
    

    /*************************************************** methods ***************************************************/

    /* ¿ï¾Ü¤º®eÅã¥Ü */
    this.select = selectContent;
    function selectContent(oEvent) {
        if (isResizing) { return; }

        if (isBasicType(oEvent)) {
            /* ¦pªG¿é¤Jid¨Ó¥´¶}¤º®e  */
            var li_node = getDOMs(".tabs LI[mappingId=" + oEvent + "]")[0];
            if (li_node) {
                /* ¿é¤Jid ===> §ä¨ìLIª«¥ó */
                selectContent(li_node);
                return;
            } else {
                /* ¿é¤Jindex ===> ¤ÀªRindex ===> §ä¨ìLIª«¥ó */
                /* ¤ÀªRindex */
                var index_split = (oEvent + '').split('+');
                var index_level_1 = index_split[0];
                var index_level_2 = index_split[1];

                if (!isNumeric(index_level_1)) { return; }

                /* ¥D¿ï³æª«¥ó */
                var select_Main = index_level_1 < 0 || index_level_1 >= tabs.length ? 0 : index_level_1;
                var actionTargat = tabs_menu.childNodes[select_Main];
                if (actionTargat.getAttribute("hasSub") == 'Y') {
                    if (isNumeric(index_level_2)) {
                        actionTargat.setAttribute("user_init", index_level_2);
                    } else {
                        actionTargat.removeAttribute("user_init", index_level_2);
                    }
                }

                selectContent(actionTargat);
                return;
            }

        }

        /* ÀË®Öª«¥ó¬O§_¬° content li*/
        var callFromUser = !isElement(oEvent);
        var target =  !callFromUser ? oEvent : (oEvent && (oEvent.target || oEvent.srcElement)) || this;
        if (!isElement(target, 'li')) { return; }

        /* ¿é¤Jªº¬O liª«¥ó*/
        isShowAll = false;
        var mappingId = target.getAttribute("mappingId");
        var index = target.getAttribute("index");
        var mainMenuToSub = !(target.getAttribute("hasSub") != 'Y');

        /* ¤ÀªRindex */
        var index_split = (index + '').split('+');
        var index_level_1 = index_split[0];
        var index_level_2 = index_split[1];

        if (!isNumeric(index_level_1)) { return; }

        /* ­Y¤£¬O¿ï¾Ü¤¤ªºª«¥ó */
        setSelect(target, mappingId);

        /* ¨Ï¥Î³o«ö¤U¤~©I¥sClickAction */
        if (callFromUser) {
            if (isFunction(config.onClickAction[mappingId])) {
                config.onClickAction[mappingId].call(target, mappingId, target);
            } else if (isFunction(config.onClickAction["all_clickAction"])) {
                config.onClickAction["all_clickAction"].call(target, mappingId, target);
            }
        }

        /*  ³B²z²Ä¤G¼h¿ï³æÅã¥Ü hasSub¬O²Ä¤@¼h¿ï³æªºÄÝ©Ê¡A¦pªG¬O²Ä¤G¼h¿ï³ælevel2·|¦³¼Æ¦r */
        var hasSub = mainMenuToSub || isNumeric(index_level_2);

        /* ¥NªíÂI¿ïªº¬O¤l¿ï³æ */
        var sub_menus = tabs_sub_menu.childNodes;
        for (var i = 0 ; i < sub_menus.length ; i = i + 1) {
            if (!hasSub) {
                /* ÁôÂÃ©Ò¦³¤l¿ï³æ */
                sub_menus[i].style.display = 'none';
            } else {
                var active_sub = sub_menus[i];
                var subIndex = active_sub.getAttribute("index");

                if ((subIndex == index_level_1)) {
                    /* §ä¨ìªì©lªº¿ï¶µ */
                    var defaultSelect = index_level_2;
                    if (!isNumeric(defaultSelect)) {
                        if (mainMenuToSub) {
                            defaultSelect = target.getAttribute("uesr_init");
                            target.removeAttribute("user_init");
                        } else {
                            defaultSelect = active_sub.getAttribute("pre_click");
                        }
                    }

                    if (!isNumeric(defaultSelect)) {
                        defaultSelect = active_sub.getAttribute("init");
                    }

                    defaultSelect = !isNumeric(defaultSelect) || defaultSelect < 0 || defaultSelect >= active_sub.childNodes.length ? 0 : defaultSelect;

                    index_level_2 = defaultSelect;
                    active_sub.setAttribute("pre_click", defaultSelect);

                    /* §ó·starget¦¨¤l¿ï³æªºª«¥ó */
                    target = active_sub.childNodes[defaultSelect];
                    mappingId = target.getAttribute("mappingId");
                    index = target.getAttribute("index");

                    active_sub.style.display = '';

                    /* ­Y¤£¬O¿ï¾Ü¤¤ªºª«¥ó */
                    setSelect(target, mappingId);

                } else {
                    /* ¤£»Ý­nªºªF¦è´NÁôÂÃ */
                    active_sub.style.display = 'none';
                }
            }
        }

        /* ­«ºâ¼e«× */
        configMenuWidth(tabs_menu);
        for (var i = 0 ; i < tabs_sub_menu.childNodes.length ; i++) {
            configMenuWidth(tabs_sub_menu.childNodes[i]);
        }

        /* ----------------------- ³B²z¨ú±oª«¥ó -------------------------  */
       
        /* ¨ú±o­nÅã¥Üªºliª«¥ó */
        if (hasSub) {
            index_level_2 = parseInt(index_level_2, 10) + 1;
            if (tabs[index_level_1][0]) {
                display_content(tabs[index_level_1][0], false);
                display_content(tabs[index_level_1][index_level_2], true);
            } else {
                display_content(tabs[index_level_1][index_level_2]);
            }
        } else {
            display_content(tabs[index_level_1]);
        }
    }

    function display_content(content_cell, updateActivePage) {

        if (!content_cell) { return; }

        /* ¨ú±o­nÅã¥Üªºcontent ª«¥ó */
        var tab_content_element = content_cell.firstChild;

        var clearPage = updateActivePage !== true;
        updateActivePage = !(updateActivePage === false);

        /* ¨Ñ´«­¶«e¡A´«­¶«áªºfunction¨Ï¥Î¸ê°T */
        var from_id = active_page ? active_page.getAttribute("mappingId") : null;
        var to_id = content_cell.getAttribute("mappingId");

        var info_map = {
            from: from_id,
            from_elem: active_page ? active_page.firstChild : null,
            to: to_id,
            to_elem: tab_content_element
        };

        var is_iframe = isElement(tab_content_element, "iframe");

        if (updateActivePage) { active_page = content_cell; }

        /* ´«­¶«e°Ê§@¡A­º¦¸¤Á­¶¤£°µ°Ê§@¡C */

        var from_src = is_iframe && tab_content_element.getAttribute("src");
        if (isFunction(config.beforeSwitch)) {
            try {
                config.beforeSwitch(info_map);
                /* ¦pªG¦bbeforeSwitch´«¹L­¶ÅÒ¡C°±¤î°Ê§@¡C */
                if (updateActivePage && active_page != content_cell) { /*resize();*/ return; }
            } catch (e) {
                debug('selectContent',"°õ¦æ beforeSwitch ¿ù»~¡AFROM_ID = [" + from_id + "] TO_ID = [" + to_id + "] " + e.description);
            }
        }

        if (is_iframe) {
            //try_call_iframe_resize(tab_content_element);
            var to_src = tab_content_element.getAttribute("src");
            if (to_id == from_id && from_src == to_src) {
                return;
            }
            if (to_src && from_src != to_src && coverPage) {
                coverPage.show();
            }
        } else if (to_id == from_id) {
            return;
        }

        if (clearPage) {
            /* ÁôÂÃ©Ò¦³²{¦bªºtabs */
            var all_tabs = tabs_content.childNodes;
            for (var i = 0 ; i < all_tabs.length ; i = i + 1) {
                all_tabs[i].style.display = 'none';
            }
        }
        
       
        if (to_id != from_id) {
            //´«­¶--¤¸¯ÀÅã¥Ü§óÅÜ
            content_cell.style.display = '';
        }

        //´«­¶«á°Ê§@¡A­º¦¸¤Á­¶¤£°µ°Ê§@¡C
        if (isFunction(config.afterSwitch)) {
            try {
                config.afterSwitch(info_map);
            } catch (e) {
                debug('selectContent', "°õ¦æ afterSwitch ¿ù»~¡AFROM_ID = [" + from_id + "] TO_ID = [" + to_id + "] " + e.description);
            }
        }

       // updateActivePage && resize();

    }

    function showAll(oEvent) {

        if (isResizing) { return; }

        isShowAll = true;

        var target = isElement(oEvent) ? oEvent : oEvent.target || oEvent.srcElement || this;
        if (!hasClassName(target, "onSelected")) {
            setSelect(target);
        }

        var sub_menus = tabs_sub_menu.childNodes;
        for (var i = 0 ; i < sub_menus.length ; i = i + 1) {
            sub_menus[i].style.display = 'none';
        }

        //¨Ñ´«­¶«e¡A´«­¶«áªºfunction¨Ï¥Î¸ê°T
        var info_map = {
            from: active_page ? active_page.getAttribute("id") : null,
            from_elem: active_page ? active_page : null,
            to: "all",
            to_elem: null
        };

        //´«­¶«e°Ê§@
        if (isFunction(config.beforeSwitch)) {
            try {
                config.beforeSwitch(info_map);
                //¦pªG¦bbeforeSwitch´«¹L­¶ÅÒ¡C°±¤î°Ê§@¡C
                if (active_page != content_cell) { return; }
            } catch (e) {
                debug('selectContent', "°õ¦æ beforeSwitch ¿ù»~(all)¡AFROM_ID = [" + from_id + "] TO_ID = [" + to_id + "] " + e.description);
            }
        }

        //´«­¶
        var contents = tabs_content.childNodes;
        for (var i = 0 ; i < contents.length ; i = i + 1) {
            contents[i].style.display = '';
            var tab_content_element = contents[i].firstChild;
            tab_content_element.style.width = '';
        }

        if (isFunction(config.afterSwitch)) {
            try {
                config.afterSwitch(info_map);
                //¦pªG¦bafterSwitch´«¹L­¶ÅÒ¡C°±¤î°Ê§@¡C
                //if (active_page != content_cell) { return; }
            } catch (e) {
                debug('selectContent', "°õ¦æ afterSwitch ¿ù»~(all)¡AFROM_ID = [" + from_id + "] TO_ID = [" + to_id + "] " + e.description);
            }
        }

        active_page = null;

        //resize();
    }


    /* ¨ú±o¥Ø«eÅã¥Ü elemnt ªº id */
    this.getDisplayId = getDisplayId;
    function getDisplayId() {
        return active_page ? active_page.getAttribute("mappingId") : null;
    }

    /* ¨ú±o§@¥Î¤¤ªº tab index (zero base) */
    this.getSelectedIndex = getSelectedIndex;
    function getSelectedIndex() {
        return active_page ? active_page.getAttribute("index") : null || -1;
    }

    this.show = show;
    function show() {
        tabs_main.style.display = "";
        resize();
    }

    this.hide = hide;
    function hide() {
        tabs_main.style.display = "none";
    }

    /* ¥»¨Ó·Q¼g§R°£¡A¤£¹L¦Ò¼{¨ì¤º®eª«¥ó¥²¶·«O¯d¦b­¶­±¤W¨Ñ«á­±¨Ï¥Î¡C©Ò¥H¶ÈÁôÂÃ */
    this.removeAll = removeAll;
    function removeAll() {
        tabs_main.style.display = "none";
        tabs_main.removeChild(tabs_menu_div);
        tabs_main.removeChild(tabs_sub_menu);
        tabs_main.removeChild(content_container);

        for (var i = 0 ; i < tabs.length ; i++) {
            if (isArray(tabs[i])) {
                for (var j = 0 ; j < tabs[i].length ; j++) {
                    tabs_main.appendChild(tabs[i][j]);
                }
            } else {
                tabs_main.appendChild(tabs[i]);
            }
        }

        _tab_setting_map[id] = null;
    }

    /* ÂI¿ï¤@­Ó¼ÐÅÒ¡A³]©wÃC¦âclassName */
    function setSelect(node, mappingId) {
        if (!isElement(node, "LI")) { return; }
        if (hasClassName(node, 'onSelected')) { return; }

        var all_LI = node.parentNode.childNodes;
        for (var i = 0 ; i < all_LI.length ; i = i + 1) {
            removeClassName(all_LI[i], "onSelected");
        };
        addClassName(node, "onSelected");

        configMenuWidth(node.parentNode);
    }

    /*************************************************** for create a tab method ***************************************************/
    function createMenuItemAndContentItem(contentArray, contentElement, menuElement, parent_index) {
        if (!isElement(contentElement)) { return; }

        var hasSubTabs = contentElement.getAttribute("subTab");
        hasSubTabs = (hasSubTabs == "true") || (hasSubTabs === true) || (hasSubTabs == 'Y');

        var my_index = contentArray.length;
        var index = my_index;
        if (parent_index || parent_index === 0) {
            my_index = my_index - 1;
            index = parent_index + "+" + my_index;
        }
        var mappingId = contentElement.getAttribute("id");
        var tabsTitle = contentElement.getAttribute("blockTitle") || mappingId || ("TAB " + index);

        if (contentElement.getAttribute('init') == 'Y') {
            menuElement.setAttribute('init', my_index);
        }

        /* ¥D¿ï³æ¿ï¶µ */
        createElement("LI", { 'index': index, 'hasSub': hasSubTabs ? 'Y' : 'N', 'id': 'tabMenuItem-'+id+'-'+mappingId, 'mappingId': mappingId, 'title': tabsTitle }, null, ['menu_li'], { click: selectContent }, menuElement, tabsTitle);

        /* ¤º®e */
       var contentLI = createElement("LI", { 'index': index, 'mappingId': mappingId }, { 'display': 'none' }, ['tabs_content_li'], null, tabs_content);
        contentLI.appendChild(contentElement);
        
        
       
        if (hasSubTabs) {
            /* ¦³sub_tabsªº±¡ªp*/
            /* «Ø¥ß¦¸¿ï³æ*/
            var sub_menu = createElement("UL", { index: index }, { display: 'none' }, ['sub_menu_ul']);
            var newsub_nodes = [contentLI];

            var sub_nodes = getDOMs("*[is_subTab=Y]", contentElement);
            for (var i = 0 ; i < sub_nodes.length ; i = i + 1) {
                createMenuItemAndContentItem(newsub_nodes, sub_nodes[i], sub_menu, index);
            }
            
            if (newsub_nodes.length > 1) {
                tabs_sub_menu.appendChild(sub_menu);
                contentArray.push(newsub_nodes);
                if (!trim(contentElement.textContent || contentElement.innerText)) {
                    tabs_content.removeChild(contentLI);
                    if (isElement(contentElement)) {
                        contentElement.display = 'none';
                    }
                    main_node.parentNode.appendChild(contentElement);
                    contentLI = null;
                    newsub_nodes[0] = null;
                }
            } else {
                contentArray.push(contentLI);
            }
        }else{
            contentArray.push(contentLI);
        }

        if (contentLI) {
            contentElement.style.display = "";
            if (contentElement.tagName == "IFRAME") {
                contentElement.style.border = 'none';
                contentElement.setAttribute('border', 0);
                contentElement.setAttribute('scrolling', 'auto');
                contentElement.setAttribute('frameBorder', 0);
            }
        }

    }

    /*************************************************** for resize methods ***************************************************/

    /* ­pºâ¼ÐÅÒªº³Ì¤j¼e«× */
    function configMenuWidth(ul) {
        if (!isElement(ul, "UL") || ul.style.display == 'none') { return; }
        var all_LI = ul.childNodes;
        var selectWidth = 0;
        for (var i = 0 ; i < all_LI.length ; i = i + 1) {

            if (hasClassName(all_LI[i], "onSelected")) {
                all_LI[i].style.width = '';
                selectWidth = all_LI[i].offsetWidth;
            }
            all_LI[i].style.width = "1px";
        };

        ul.style.width = '';

        var ul_width = ul.offsetWidth;
        if (ul_width < 10) { setTimeout(function () { configMenuWidth(ul); }, 100); return; }

        ul_width = ul_width - 58 - ((all_LI.length + 1) * 8) - (selectWidth);
        var one_width = Math.ceil(ul_width / (all_LI.length - 1), 10);

        if (one_width < 2) { setTimeout(function () { configMenuWidth(ul); }, 500); return; }

        one_width = one_width + 4;

        for (var i = 0 ; i < all_LI.length ; i = i + 1) {
            if (!hasClassName(all_LI[i], "onSelected")) {
                all_LI[i].style.width = '';
                all_LI[i].style.width = Math.min(one_width, all_LI[i].offsetWidth) + 'px';
            } else {
                all_LI[i].style.width = (selectWidth + 4) + 'px'
            }
        };
    }

    var isResizing = false;
    this.resize = resize;
    function resize(caller) {

        if (resizing) { return; }

        _tabs_globe_lock();

        resizing = true;

        content_container.style.height = '';
        var maxWidth = content_container.offsetWidth - 10;
        var iframes = [];

        var iframeHeight = parseInt(_tab_vertical_resize.offsetHeight * 2 / 3) ||  200;
        for (var i = 0 ; i < tabs_content.childNodes.length ; i++) {
            var subTabs = tabs_content.childNodes[i];
            if (subTabs.style.display != 'none') {
                subTabs.style.width = maxWidth + 'px';
                if (subTabs.firstChild.tagName == "IFRAME") {
                    var iframe = subTabs.firstChild;
                    iframe.style.height = iframeHeight + 'px';
                    iframe.style.width = (maxWidth) + 'px';
                    iframes.push(iframe);
                }
            } else {
                subTabs.style.width = '';
            }
        }
        content_container.style.height = tabs_content.offsetHeight + 'px';

        saveNodeSize(content_container)
        saveNodeSize(tabs_content)

        resizing = false;

        for (var i = 0 ; i < iframes.length ; i++) {
            try_call_iframe_resize(iframes[i]);
        }

        _tabs_globe_unlock();
        
    }

    function try_call_iframe_resize(tab_content_element) {
        var iframe_element = tab_content_element;
        if (tab_content_element.tagName != "IFRAME") {
            return;
        }

        try {
            if (tab_content_element.contentWindow.startTabsContentResize_alreadyStart && tab_content_element.contentWindow.saved_content_body_height > 10) {
                if (Math.abs(tab_content_element.contentWindow.saved_content_body_height - iframe_element.offsetHeight) < 30) {
                    return;
                }

                resizing = true;
                iframe_element.style.height = tab_content_element.contentWindow.saved_content_body_height + 'px';
                content_container.style.height = tabs_content.offsetHeight + 'px';
                saveNodeSize(content_container)
                saveNodeSize(tabs_content)
                resizing = false;
               return;
            }
        } catch (e) {
            debug('try_call_iframe_resize', ' ¹Á¸Õ¹ïiframe¤w¦s¦b¤§°ª«×¤§±Ñ¡CException:' + e.description);
        }

        var defaultHeight = parseInt(_tab_vertical_resize.offsetHeight * 2 / 3);
        defaultHeight = Math.min(defaultHeight,300);
        if (Math.abs(defaultHeight - iframe_element.offsetHeight) < 50) {
            iframe_element.style.height = defaultHeight+'px';
        }
        debug('try_call_iframe_resize', ' ¹Á¸Õ¹ïiframe ' + tab_content_element.id + ' ¤¸¯Àªì©l¤Æ¡A¨Ã³]©w°ª«×¦Ü·~­±°ª«×2/3 ');
        try {
            iframe_resize.call(iframe_element, event);
        } catch (e) {
            iframe_element.style.height = Math.max(parseInt(document.body.offsetHeight - 200), 300) + 'px';
            debug('try_call_iframe_resize', ' ¹Á¸Õ¹ïiframe¤º®e©I¥s§ì¨ú°ª«×¥¢±Ñ , ³]©w°ª«×¦Ü ' + iframe_element.style.height + ' ¡CException:' + e.description);
        }
        Event.observe(iframe_element, 'load', iframe_resize);
    }

    function iframe_resize(event) {
        if (coverPage) {
            coverPage.hide();
        }
        var iframe_element = this;
        var tab_content_element_id = iframe_element.getAttribute('tabs_content') || iframe_element.getAttribute('id');
        if (tabs_js_path) {
            try {
                iframe_element.contentWindow.document.body.setAttribute('tabs_content', tab_content_element_id);
                iframe_element.contentWindow.document.body.setAttribute('tabs_id', id);
                if (!iframe_element.contentWindow.startTabsContentResize) {
                    debug('iframe_resize', '¤÷­¶­±¹Á¸Õ¹ï¤l­¶­± ' + tab_content_element_id + ' ªþ¥[ startTabsContentResize ¨ç¦¡¡I');
                    var eJS = document.createElement("script");
                    eJS.type = 'text/javascript';
                    eJS.src = tabs_js_path;
                    try {
                        iframe_element.contentWindow.document.body.insertAdjacentElement('beforeEnd', eJS);
                    } catch (e) {
                        debug('iframe_resize', '¤÷­¶­±µLªk±Ä¥ÎinsertAdjacentElement¹ï¤l­¶­± ' + tab_content_element_id + ' ªþ¥[jsÀÉ®×¡I ' + e.description);
                        try {
                            iframe_element.contentWindow.document.body.appendChild(eJS);
                        } catch (e) {
                            debug('iframe_resize', '¤÷­¶­±µLªk±Ä¥ÎappendChild¤è¦¡¹ï¤l­¶­± ' + tab_content_element_id + ' ªþ¥[jsÀÉ®×¡I ' + e.description);
                        }
                    }
                }
                if (iframe_element.contentWindow.startTabsContentResize) {
                    debug('iframe_resize', '¤÷­¶­±¤wªþ¥[jsÀÉ®×...¹Á¸Õ¹ï¤l­¶­± ' + tab_content_element_id + ' °õ¦æ startTabsContentResize ¨ç¦¡¡I');
                    iframe_element.contentWindow.startTabsContentResize();
                } else {
                    debug('iframe_resize', '¤÷­¶­±¤wªþ¥[jsÀÉ®×...¹Á¸Õ¹ï¤l­¶­± ' + tab_content_element_id + ' °õ¦æ startTabsContentResize ¨ç¦¡¡A¦ý¤l­¶­±µL¦¹¨ç¦¡¡I¹Á¸Õ100²@¬í«á­«·s§PÂ_¡F');
                    iframe_element.style.height = Math.max(_tab_vertical_resize.offsetHeight - 100, 500) + 'px';
                    setTimeout(function () {
                        if (iframe_element.contentWindow.startTabsContentResize) {
                            iframe_element.contentWindow.startTabsContentResize();
                        } else {
                            debug('iframe_resize', '¤÷­¶­±¤wªþ¥[jsÀÉ®×...¹Á¸Õ¹ï¤l­¶­± ' + tab_content_element_id + ' °õ¦æ startTabsContentResize ¨ç¦¡¥¢±Ñ¡I©ñ±ó°õ¦æ¸Ó¨ç¦¡¡C');
                            //resize();
                        }
                    }, 100);
                }
            } catch (e) {
                debug('iframe_resize', '¤÷­¶­±¹Á¸Õ¹ï¤l­¶­± ' + tab_content_element_id + ' µo¥ÍµLªk¦s¨úbodyªºª¬ºA¡I ' + e.description);
                iframe_element.style.height = Math.max(_tab_vertical_resize.offsetHeight - 100, 700) + 'px';
                //resize();
            }
        } else {
            debug('iframe_resize', 'µLªk¨ú±otabs_js_path');
            iframe_element.style.height = Math.max(_tab_vertical_resize.offsetHeight - 100, 700) + 'px';
            //resize();
        }

        if (event) {
            var target = getEventTarget(event) || this;
            stopEventObserving(target, 'load', iframe_resize);
        }
    }

    this.child_iframe_call_parent_resize = child_iframe_call_parent_resize;
    function child_iframe_call_parent_resize(iframe_id, height) {
        if (resizing) { return false; }
        debug('child_iframe_call_parent_resize', '¤l­¶­± ' + iframe_id + ' ©I¥s¤÷­¶­±§ó·s°ª«×¦Ü ' + height);
        var iframe = document.getElementById(iframe_id);
        if (!iframe || getStyle(iframe, 'display') == 'none'
            || !hasClassName(iframe.parentNode, 'tabs_content_li') || getStyle(iframe.parentNode, 'display') == 'none') {
            return false;
        }

        resizing = true;

        iframe.style.height = height + 'px';
        content_container.style.height = tabs_content.offsetHeight + 'px';

        saveNodeSize(content_container)
        saveNodeSize(tabs_content)

        resizing = false;
        return true;
    }


    /** utils **/
    function getDOMs(selection , parent) {
        if(isElement(parent)){
            return $(parent).select(selection);
        }else{
            return $$(selection);
        }
    }

    function createElement(node, attrs, styles, classes, events, appendAt, content) {

        if (!isElement(node)) {
            node = document.createElement(node);
        }

        if (isObject(attrs)) {
            for (var key in attrs) {
                if (isBasicType(attrs[key])) {
                    node.setAttribute(key, attrs[key]);
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

        if (isBasicType(content)) {
            node.innerHTML = content;
        }

        if (isElement(appendAt)) {
            appendAt.appendChild(node);
        }

        return node;
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

    function trim(value) {
        return (value || "").replace(/(^[\s]*)|([\s]*$)/g, "");
    }

    function getType(node) {
        if (typeof (node) === 'undefined') { return "undefined"; }
        return Object.prototype.toString.apply(node);
    }

    function isBasicType(node) {
        var type = typeof (node);
        return !!(type === 'string' || type === 'number' || type === 'boolean');
    }

    function isNumeric(node) {
        return isBasicType(node) && (/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node));
    }

    function isString(node) {
        return !!(isBasicType(node) && getType(node) === '[object String]');
    }

    function isObject(node) {
        return !!(node && getType(node) == '[object Object]' && !isArray(node) && !isFunction(node));
    }

    function isArray(node) {
        return !!(node && getType(node) === '[object Array]' && isNumeric(node.length));
    }

    function isElement(node, tagName) {
        return (!!(node && node.tagName && node.nodeType === 1)) && (isString(tagName) ? (tagName.toUpperCase() == node.tagName) : true);
    }

    function isFunction(node) {
        return !!(node && getType(node) === '[object Function]');
    }

    function clearAllChild(node) {
        while (node.firstChild) {
            node.removeChild(node.firstChild);
        }
    }

    function setEventObserve(elem, eventName, func) {
        if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName) || !isFunction(func)) { return; }
        if (elem.removeEventListener) {						//DOM2±µ¤f with bubble
            elem.addEventListener(eventName, func, false);
        } else if (elem.detachEvent) {					//IE DOM2±µ¤f  with bubble
            elem.attachEvent('on' + eventName, func);
        } else {											//DOM0±µ¤f without bubble
            elem['on' + eventName] = func;
        }
    }

    function stopEventObserving(elem, eventName, func) {
        if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName)) { return; }
        if (elem.removeEventListener) {						//DOM2±µ¤f with bubble
            elem.removeEventListener(eventName, func);
        } else if (elem.detachEvent) {						//IE DOM2±µ¤f  with bubble
            elem.detachEvent('on' + eventName, func);
        } else {											//DOM0±µ¤f without bubble
            elem['on' + eventName] = null;
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

    function setNodeText(node, text) {
        if (node.textContent != undefined)
            node.textContent = text;
        else
            node.innerText = text;
    }
}

window.saved_content_body_height = 0;
window.startTabsContentResize_alreadyStart = false;
window.startTabsContentResize = function () {
    saved_content_body_height = 0;
    if (startTabsContentResize_alreadyStart) { return; }
    if (!document.body || !document.body.getAttribute('tabs_content')) { return; }
    var parent_iframe_id = document.body.getAttribute('tabs_content');
    var parent_tabs_id = document.body.getAttribute('tabs_id');
    var stop_resize_cover;

    try {
        var parent_tabs = window.parent && window.parent._tab_setting_map[parent_tabs_id];
        if (!parent_tabs) { return; }
        var parent_iframe = window.parent.document && window.parent.document.getElementById(parent_iframe_id);
        if (!parent_iframe) { return; }
        
        var confirm_content_body_height = 0;
        var test_limit_times = 3;
        var already_test_times = 0;

        window.setInterval(function () {
            //ajax®É°±¤î§PÂ_
            if (!stop_resize_cover) { stop_resize_cover = document.getElementById('_frontCover'); }
            if (stop_resize_cover && stop_resize_cover.style.display != 'none') {
                if (!saved_content_body_height) {
                    saved_content_body_height = 1;
                    parent_tabs.child_iframe_call_parent_resize(parent_iframe_id, 500);
                }
                return;
            }

            var PageUiOverDiv = document.getElementById('PageUiOverDiv');
            if (PageUiOverDiv) {
                PageUiOverDiv.style.overflowY = 'visible';
            }

            var nowHeight = document.body.scrollHeight;
            if(nowHeight == 0){ return;} //°±¤î¦b¨S¦³°ª«×ªºª¬ºA¤U§ó·s
            var diff_saved_height = Math.abs(saved_content_body_height - nowHeight);
            if (diff_saved_height <= 10 ) { return; } // ¤Ó¤pªº®t²§¤£±Ò°Ê°ª«×­×§ï¡C
            if (Math.abs(diff_saved_height - 30 ) <= 2) { return; } // 30 == bar1 ·|¼vñ°ª«×­pºâ³y¦¨µL½a°j°é¡C
            if (Math.abs(confirm_content_body_height - nowHeight) < 35) {
                if (already_test_times > test_limit_times) {
                    confirm_content_body_height = 0;
                    nowHeight += 10;
                    //console.log("saved_content_body_height" + saved_content_body_height);
                    if (parent_tabs.child_iframe_call_parent_resize(parent_iframe_id, nowHeight)) {
                        saved_content_body_height = nowHeight;
                    }
                } else {
                    already_test_times++;
                }
                return;
            }
            already_test_times = 0;
            confirm_content_body_height = nowHeight;
        }, 100);

        startTabsContentResize_alreadyStart = true;

        /* 
         if (title_bar) {
             title_bar.id = 'title_bar';
             title_bar.style.position = "static";
             alert('aaa');
         }*/

    } catch (e) {
        window.console && window.console.log('¤l­¶­±©I¥s¹Á¸Õ©I¥s¤÷­¶­± child_iframe_call_parent_resize ²[¦¡®Éµo¥Í¿ù»~¡I ' + e.description);
    }
}
