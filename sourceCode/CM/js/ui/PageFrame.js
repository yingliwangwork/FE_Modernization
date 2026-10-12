window.PageFrame = new ( function(){


var configs = {
	startMark : '\u25CB',
	spanMark : '\u003E',
	minimizeMark: '\u2581',
	exploreMark : '\u25BD',
	pageCodeDesp: 'PAGE ID ',//'畫面編號：',
	changeFontSize: true,
	changeFontSizeTitle: 'Font size : ',
	changeFontSizeDisplay: ['S','M','L'],//['小','中','大'],
	backToTop: true,
	themeClass: 'theme-primary',
	isDebug: false
}

var noBorderTag = [
	'FORM'
];

var noBorderClass = [
	'table'
];

/* 資料欄位 */
var fixed_block , scroll_block , hidden_block;

var keepContents = [];

var dummyPageUrl = location.href.substr(0,location.href.indexOf('Web/')) + 'Web/html/CM/js/ajax/dummy.jsp';


/**
	* @param {Object} new_configs
	*
*/
this.setConfigs = setConfigs;

function setConfigs( new_configs ){
	for(var key in new_configs){
		if(isBasicType(configs[key]) && isBasicType(new_configs[key])){
			configs[key] = new_configs[key];
		}
	}
}


this.setTheme = function(){
    addClassName(document.body,configs.themeClass);
}


this.createPage = createPage;
function createPage( page_code , main_title , sub_title , noPageFrame ){

	if(scroll_block){
		alert('[PageFrame addBlack] Create Page already, Please do not execute again.');
		return;
	}

    if(window.CSRUtil && !window.CSRUtil.UICore.imageBase){
        var includeCSSs = document.getElementsByTagName('link');
        for( var i = 0 ; i<includeCSSs.length ; i++ ){
            var includeCSS = includeCSSs[i];
            var cssHref = includeCSS.href || '';
            if(!cssHref || cssHref.indexOf('PageFrame.css') < 0 ){
                continue;
            }
            window.CSRUtil.UICore.imageBase = cssHref.substring(0, cssHref.indexOf('html')) + 'images';
            break;
        }
	}

	hidden_block = createElement('div', {id:'pageFrame-hidden-content'});

	var test_Org_child = document.body.firstChild;

	while(test_Org_child){
		//wm_div_id : 底層浮水印預設id
		var test_result = isElement(test_Org_child) && (isTextNode(test_Org_child) || ( getCellAttr(test_Org_child,'id') != 'wm_div_id' && test_Org_child.tagName != 'SCRIPT' && test_Org_child.tagName != 'STYLE' && test_Org_child.tagName != 'LINK'  ))
		test_result = test_result && ( isTextNode(test_Org_child) ? true : !( (test_Org_child.className||'').indexOf('calendar_') >=0 || (test_Org_child.getAttribute('class')||'').indexOf('calendar_') >=0));

		if(test_result){
			var temp_next = test_Org_child.nextSibling;
			hidden_block.appendChild(test_Org_child);
			test_Org_child = temp_next;
		}else{
			test_Org_child = test_Org_child.nextSibling;
		}
	}

	insertFirstChild(hidden_block , document.body);

	var iframes = hidden_block.getElementsByTagName('iframe');
	for(var i = 0 ; i < iframes.length ; i++){
		iframes[i].setAttribute('frameBorder','no');
		iframes[i].setAttribute('marginHeight','0');
		iframes[i].setAttribute('marginWidth','0');
		iframes[i].setAttribute('scrolling','no');
		iframes[i].style.borderWidth = '0px';
		iframes[i].style.borderColor = '#FFF';

        var org_src = iframes[i].getAttribute('src');
        if(org_src && org_src !== 'null' && org_src !== 'undefined' && org_src !== '#'){
            iframes[i].setAttribute('data-src' , org_src);
        }
         try{
            iframes[i].contentWindow.location.replace(dummyPageUrl);
        }catch(e){
            iframes[i].setAttribute('src',dummyPageUrl);
        }
	}

	var menuWindow = null;

	try{
		menuWindow = window;
		while(!isArray(menuWindow.menuDatas)){
			if(menuWindow.parent == menuWindow){
				menuWindow = false;
				break;
			}
			menuWindow = menuWindow.parent;
		}
	}catch(exception){
		menuWindow = false;
		try{
			window.console && console.log('[PageFrame] get menuWindow : ' + exception);
		}catch(exception){

		}
	}

	/* 標頭欄位 */
	var navDiv = createElement('div', 'pageFrame-nav' );

	var navLeft = createElement('div', null, null,['pageFrame-nav-block','pageFrame-nav-left'],null,navDiv);

	//startMarker
	createElement('span',null,null,['pageFrame-nav-marker'],null,navLeft,configs.startMark);
	//mainTitle
	createElement('span',null,null,['pageFrame-nav-title'],null,navLeft,main_title);
	//spanMarker
	createElement('span',null,null,['pageFrame-nav-marker'],null,navLeft,configs.spanMark);
	//subTitle
	createElement('span',null,null,['pageFrame-nav-title'],null,navLeft,sub_title);


	var navRight = createElement('div', null, null,['pageFrame-nav-block','pageFrame-nav-right'],null,navDiv);
	//startMarker 2016/10/12 協理指示拿掉
	//createElement('span',null,null,['pageFrame-nav-marker'],null,navRight,configs.pageCodeDesp);
	//mainTitle
	createElement('span',null,null,['pageFrame-nav-code'],null,navRight,page_code.replace('_',''));


	if(configs.changeFontSize !== false ){

		var click_func = function(e){
			var target = getEventTarget(e);
			if(hasClassName(target,'active')){ return; }
			var firstBtn = target.parentNode.firstChild;
			while(firstBtn){
				removeClassName(firstBtn,'active');
				firstBtn = firstBtn.nextSibling;
			}

			var set_value = getCellAttr(target,'data-set-to');
			document.body.style.fontSize = set_value;
			addClassName(target,'active');

			/* 往下處理  */
			var iframes = document.getElementsByTagName('iframe');
			for(var i = 0 ; i < iframes.length ; i++ ){
				try {
					if(!iframes[i].contentWindow || !iframes[i].contentWindow.document ){ continue; }
					var iframe = iframes[i];
					var same_btn = iframe.contentWindow.document.getElementById( target.getAttribute('id'));
					if(!same_btn){ continue; }
					if(isFunction(same_btn.dispatchEvent)){
						var a = iframe.contentWindow.document.createEvent('MouseEvents');
						a.initEvent('click', true, true);
						same_btn.dispatchEvent(a);
					}else if(isFunction(same_btn.fireEvent)){
						same_btn.fireEvent('on' + 'click');
					}else if(iframe.contentWindow.Prototype){
						iframe.contentWindow.Event.fire(same_btn, 'click');
					}else if(iframe.contentWindow.jQuery){
							iframe.contentWindow.jQuery(same_btn).trigger('click');
					}
				} catch (exception) {
					window.console && console.log('[PageFrame runFire] phase 1 error : ' + exception);
					try {
						same_btn['on' + 'click']();
					} catch (exception) {
						window.console && console.log('[PageFrame runFire] phase 2 error : ' + exception);
					}
				}

				doResetSubIframeSize(iframe);
			}
			
			/* 處理MENU TREE 字型大小 */
			if(menuWindow){
				try {
					menuWindow.document.getElementById('menutree').style.fontSize = set_value;
				} catch (exception) {
					window.console && console.log('[PageFrame runFire] phase 3 error : ' + exception);
				}
			}

			/* 向上記錄 */
			window.top.document.body.setAttribute('data-contentFontSizeTarget',target.getAttribute('id'));
			window.top.document.body.setAttribute('data-contentFontSizeValue',set_value);
			
			
		};

		var savedFontSize = '';
		try {
			savedFontSize = window.top.document.body.getAttribute('data-contentFontSizeTarget');
			if(savedFontSize){
				document.body.style.fontSize = window.top.document.body.getAttribute('data-contentFontSizeValue');
			}
		} catch (exception) {
			window.console && console.log('[PageFrame runFire] phase (init) error : ' + exception);
		}
		

		navRight = createElement('ul', 'fontSizeChange', null,['pageFrame-nav-block','pageFrame-nav-right'],null,navDiv);
		createElement('li',{id:'fontSizeChangeTitle'},null,null,null,navRight,configs.changeFontSizeTitle);
		createElement('li',{id:'font-sm','data-set-to':'1em'},null,['button','button-sm','pageFrame-nav-button',(!savedFontSize || (savedFontSize == 'font-sm') ? 'active' : null)],{click:click_func},navRight,configs.changeFontSizeDisplay[0]);
		createElement('li',{id:'font-md','data-set-to':'1.1666em'},null,['button','button-sm','pageFrame-nav-button',(savedFontSize == 'font-md' ? 'active' : null)],{click:click_func},navRight,configs.changeFontSizeDisplay[1]);
		createElement('li',{id:'font-lg','data-set-to':'1.3333em'},null,['button','button-sm','pageFrame-nav-button',(savedFontSize == 'font-lg' ? 'active' : null)],{click:click_func},navRight,configs.changeFontSizeDisplay[2]);

		try {
			if( window.parent != window && !!window.parent.PageFrame){
				navRight.style.display = 'none';
			}
		} catch (exception) {
			window.console && console.log('[PageFrame runFire] phase 5 error : ' + exception);
		}
	}

	if( noPageFrame === true){
		navDiv.style.display = 'none';
		addClassName(document.body,'pageFrame-noFrame');
	}
	insertFirstChild(navDiv , document.body);

	if(noPageFrame !== true && configs.backToTop !== false ){
		createElement('span','pageFrame-back-top',null,['button','button-sm'],{click:function(e){
			document.body.scrollTop = 0;
			if(document.documentElement && document.documentElement.scrollTop){
				document.documentElement.scrollTop = 0;
			}
		}},document.body,'\u039B');
	}

	/* 建立資料欄位 */
	fixed_block = createElement('div','pageFrame-fixed',null,['pageFrame-contents']);
	insertAfter(fixed_block , navDiv);

	scroll_block = createElement('div','pageFrame-scroll',null,['pageFrame-contents']);
	insertAfter(scroll_block , fixed_block);

    /*
	if(!hasClassName(document.body,'theme-.*')){
		addClassName(document.body,configs.themeClass);
	}
    */

	doResetSubIframeSizeWithWindow();

}

function doResizeSubIFrames(block) {
	if (!isElement(block)) { return; }
	var iframes = block.getElementsByTagName("IFRAME");
	for (var i = 0; i < iframes.length; i++) { doResetSubIframeSize(iframes[i]); }
	setTimeout(doResetSubIframeSizeWithWindow, 100);
}

this.resize = doResetSubIframeSizeWithWindow;
function doResetSubIframeSizeWithWindow(){
	try{
		if(window.parent == window || !window.parent.PageFrame){ return; }
		var parentWindow = window.parent;
		var iframes = parentWindow.document.getElementsByTagName('iframe');
		for(var i = 0 ; i < iframes.length ; i++ ){
			if( window == iframes[i].contentWindow ){
				parentWindow.PageFrame.doResetSubIframe(iframes[i]);
				break;
			}
		}
	}catch(exception){
		window.console && console.log('[PageFrame doResetSubIframeSizeWithWindow] error : ' + exception);
	}
}

this.doResetSubIframe = doResetSubIframeSize;
function doResetSubIframeSize( iframe ){
	try{
		if((iframe.getAttribute('name')||iframe.getAttribute('id')||'').match(/^popupwin_/)){ return; }
		if(!isElement(iframe) || iframe.tagName != 'IFRAME' || !iframe.contentWindow || !iframe.contentWindow.PageFrame){ return; }
		var iframeHeight = iframe.offsetHeight;
		var iframeBodyHeight = window.innerHeight || document.body.clientHeight;
		var smallHeight = 50;
		iframe.style.height = smallHeight + 'px';
		iframe.style.marginBottom = (iframeHeight - smallHeight) + 'px';

		setTimeout( function(){
			try{
				var iframeHeight = iframe.offsetHeight;
				var iframeScrollHeight = iframe.contentDocument.body.scrollHeight;
				var iframeBodyHeight = iframe.contentWindow.innerHeight || iframe.contentDocument.body.clientHeight;
				iframe.style.height = (10+parseInt(Math.max(iframeScrollHeight,iframeBodyHeight),10))+'px';
				iframe.style.marginBottom = '0';
			}catch(exception){
				window.console && console.log('[PageFrame doResetSubIframeSize(timeout)] error : ' + exception);
			}
		} , 150);
	}catch(exception){
		window.console && console.log('[PageFrame doResetSubIframeSize] error : ' + exception);
	}
}

this.addBlock = addBlock;
function addBlock( contents , block_configs , isFixed ){

	if(!scroll_block){
		alert('[PageFrame addBlack] please execute function "createPage" first!');
		return;
	}
	// 取得區塊資料
	var import_contents;
	if(isElement(contents)){
		import_contents = [contents];
	}else if( isBasicType(contents) ){
		var elem = findElement(contents);
		if(isElement(elem)){
			import_contents = [elem];
		}
	}else if (isArray(contents)){
		import_contents = [];
		for(var i = 0 ; i < contents.length ; i++){
			if(isElement(contents[i])){
				import_contents.push(contents[i]);
			}else if( isBasicType(contents[i]) ){
				var elem = findElement(contents[i]);
				if(isElement(elem)){
					import_contents.push(elem);
				}
			}
		}
	}

	if(!import_contents || import_contents.length == 0){
		alert('[PageFrame addBlack] No import contents');
		return;
	}

    // 建立標頭
	if(isBasicType(block_configs)){
		block_configs = { title : block_configs };
	}else if(!isObject(block_configs)){
		block_configs = {};
	}

	// 建立欄位區塊
	var block = createElement("DIV",null,null,['pageFrame-content-block']);

    if(!hasClassName(document.body,'theme-.*')){
        addClassName(block,isString(block_configs.theme) ? block_configs.theme : configs.themeClass);
    }

	// 此欄位是否要固定
	if(isFixed === true){
		fixed_block.appendChild(block);
	}else{
		scroll_block.appendChild(block);
	}

	var block_id = block_configs.id;
	if(isString(block_id)){
		block.setAttribute('id','pageFrame-block-'+block_id);
		if( block_configs.show === false ){
			addClassName(block,'pageFrame-content-hidden');
		}
	}


	if(block_configs.noOutter === true){
		addClassName(block,'pageFrame-content-block-noOutter');
	}else if(block_configs.noHeader === true){
		addClassName(block,'pageFrame-content-block-noHeader');
	}else{
		var block_header = createElement("DIV",null,null,['pageFrame-content-block-header']);
		if(isBasicType(block_configs.title)){
			createElement("DIV",null,null,['pageFrame-content-block-title'],null,block_header,block_configs.title);
		}

		var block_buttons = createElement("DIV",null,null,['pageFrame-content-block-buttons']);
		if(isObject(block_configs.actions)){
			for(var key in block_configs.actions){
				var action = block_configs.actions[key];
				if(isFunction(action)){
					createElement('button',{type:'button'},null,['button'],{click:action},block_buttons,key);
				}else if(isObject(action) && isFunction(action.func)){
					createElement('button',{id:action.id,type:'button'},null,['button'],{click:action.func},block_buttons,key);
				}
			}
		}

		if(block_configs.noClose !== true){
			var size_adj_btn = createElement('button',{type:'button',id:'pageFrame-block-'+block_id+'-minimize-btn'},null,['button','close-btn'],{click:function(e){
				var target = getEventTarget(e);
				var block = target.parentNode.parentNode.parentNode;
				if(hasClassName(block,'pageFrame-content-close')){
					removeClassName(block,'pageFrame-content-close');
					target.innerHTML  = configs.minimizeMark;
				}else{
					addClassName(block,'pageFrame-content-close');
					target.innerHTML = configs.exploreMark;
				}
				target.blur();
				doResizeSubIFrames(block);
			}},block_buttons,configs.minimizeMark);

			if(block_configs.minimize == true){
				addClassName(block,'pageFrame-content-close');
				size_adj_btn.innerHTML = configs.exploreMark;
			}
		}

		if(block_buttons.childNodes.length){
			block_header.appendChild(block_buttons);
		}
		if(block_header.childNodes.length){
			block.appendChild(block_header);
		}else{
			addClassName(block,'pageFrame-content-block-noHeader');
		}
	}


	// 建立內容區塊
	var block_body = createElement("DIV",null,null,['pageFrame-content-block-body'],null,block);
	var body_uq = new Date().getTime();
	for(var i = 0 ; i < import_contents.length ; i++ ){
		var thisContent = import_contents[i];
		if(getCellAttrToInt(thisContent,'pageFrame_block_uq') == body_uq ){
			debug('get one repeat element','addBlock');
			continue;
		}
		thisContent.setAttribute('pageFrame_block_uq',body_uq);
		var detail = createElement("DIV",null,null,['pageFrame-content-block-detail'],null,block_body,thisContent);

		keepContents.push(detail);

		var isNoBorder = isInArray(noBorderTag, thisContent.tagName) > -1 ||  isTableUI(thisContent);
		if(!isNoBorder){
			var content_classses = getClassNames(thisContent);
			for(var j = 0 ; j < content_classses.length ; j++){
				if(isInArray(noBorderClass , content_classses[j]) > -1){
					isNoBorder = true;
					break;
				}
			}
		}
		if(isNoBorder){
			addClassName( detail , 'noBorder' );
			addClassName( thisContent , 'border-radius' );
		}

	}

	if(import_contents.length == 1 && isTableUI(import_contents[0])){
		addClassName(block_body,'noPadding');
	}


    var iframesInBody = block_body.getElementsByTagName('iframe');
    for(var i = 0 ; i < iframesInBody.length ; i++ ){
        var src = iframesInBody[i].getAttribute('data-src');
        if(iframesInBody[i].removeAttribute){
            iframesInBody[i].removeAttribute('data-src');
        }else{
            iframesInBody[i].setAttribute('data-src','');
        }

        if(!src || src.indexOf('dummy.jsp') > 0 ){ continue; }
         try{
            iframesInBody[i].contentWindow.location.replace(src);
        }catch(e){
            iframesInBody[i].setAttribute('src',src);
        }
    }

}

this.reset = reset;
function reset(){
	if(!scroll_block){
		alert('[PageFrame addBlack] please execute function "createPage" first!');
		return;
	}

	for(var i = 0 ; i < keepContents.length ; i++ ){
		while(keepContents[i].firstChild){
			hidden_block.appendChild(keepContents[i].firstChild);
		}
	}

    var iframes = hidden_block.getElementsByTagName('iframe');
	for(var i = 0 ; i < iframes.length ; i++){
        if(iframes[i].getAttribute('data-src')){
            continue;
        }
		var org_src = iframes[i].getAttribute('src');
        if(org_src && org_src !== 'null' && org_src !== 'undefined' && org_src !== '#'){
            iframes[i].setAttribute('data-src' , org_src);
        }
        try{
            iframes[i].contentWindow.location.replace(dummyPageUrl);
        }catch(e){
            iframes[i].setAttribute('src',dummyPageUrl);
        }
	}

	keepContents = [];
	fixed_block.innerHTML = '';
	scroll_block.innerHTML = '';

}

this.showBlock = showBlock;
function showBlock(block_id){
	var block = document.getElementById('pageFrame-block-'+block_id);
	if(block){
		removeClassName(block,'pageFrame-content-hidden');
		doResizeSubIFrames(block);
	}
}

this.hideBlock = hideBlock;
function hideBlock(block_id){
	var block = document.getElementById('pageFrame-block-'+block_id);
	if(block){
		addClassName(block,'pageFrame-content-hidden');
		doResetSubIframeSizeWithWindow();
	}
}

this.showBlockByDetailId = showBlockByDetailId;
function showBlockByDetailId(detail_id){
	var detail = document.getElementById(detail_id);
	var detail_outer = detail && detail.parentNode;
	if(!detail_outer || !hasClassName(detail_outer,'pageFrame-content-block-detail')){ return; }
	removeClassName(detail_outer,'pageFrame-content-hidden');
	var block = getParentByClassName(detail_outer,'pageFrame-content-block');
	if(block){
		removeClassName(block,'pageFrame-content-hidden');
	}
	doResizeSubIFrames(block);
}

this.hideBlockByDetailId = hideBlockByDetailId;
function hideBlockByDetailId(detail_id){
	var detail = document.getElementById(detail_id);
	var detail_outer = detail && detail.parentNode;
	if(!detail_outer || !hasClassName(detail_outer,'pageFrame-content-block-detail')){ return; }
	addClassName(detail_outer,'pageFrame-content-hidden');
	var block = getParentByClassName(detail_outer,'pageFrame-content-block');
	if(block && !hasClassName(block,'pageFrame-content-hidden')){
		var hasChildShow = false;
		var p = detail_outer.parentNode.firstChild;
		while(p){
			if(!hasClassName(p,'pageFrame-content-hidden')){
				hasChildShow == true;
				break;
			}
			p = p.nextSibling;
		}
		if(!hasChildShow){
			addClassName(block,'pageFrame-content-hidden');
		}
		doResetSubIframeSizeWithWindow();
	}
}

this.showDetail = showDetail;
function showDetail(block_id){
	var block = document.getElementById('pageFrame-block-'+block_id);
	if(block){
		removeClassName(block,'pageFrame-content-close');
		var ctrl_btn = document.getElementById('pageFrame-block-'+block_id+'-minimize-btn');
		if(ctrl_btn){
			ctrl_btn.innerHTML = configs.minimizeMark;
		}
		doResizeSubIFrames(block);
	}
}

this.hideDetail = hideDetail;
function hideDetail(block_id){
	var block = document.getElementById('pageFrame-block-'+block_id);
	if(block){
		addClassName(block,'pageFrame-content-close');
		var ctrl_btn = document.getElementById('pageFrame-block-'+block_id+'-minimize-btn');
		if(ctrl_btn){
			ctrl_btn.innerHTML = configs.exploreMark;
		}
		doResetSubIframeSizeWithWindow();
	}
}

this.Page = { init: createPage, reset: reset, resize: doResetSubIframeSizeWithWindow };

this.Block = { add: addBlock, show: showBlock, hide: hideBlock, showByDetailId: showBlockByDetailId, hideByDetailId: hideBlockByDetailId, minimize: showDetail, explore: hideDetail };

//utilitys
function isTableUI(elem){
	if ( hasClassName(elem,'grid') ){ return true; }
	if ( hasClassName(elem,'tableParent') ) { return true; }
	if ( ( elem.getAttribute('id') || '' ).match(/^grid/i)) { return true; }
	return false;
}


function debug(msg,func_name){
	if(configs.isDebug === true){
		window.console && console.log('[PageFrame]['+func_name+'] '+msg);
	}
}

function findElement( element_id ){
	if(!isString(element_id)){ return; }
	return document.getElementById(element_id);
}

function getElement(testElement, whenNull, function_params, function_input_params_part) {

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
			testElement = isBasicType(whenNull) ? whenNull : "　";
		}

		/* 轉成html輸出，因為fragment不能使用innerHTML，所以先建立一個span，再將span下的東西搬移fragment */
		var temp_span = createElement("span");
		temp_span.innerHTML = testElement;

		testElement = document.createDocumentFragment();
		while (temp_span.hasChildNodes()) {
			testElement.appendChild(temp_span.firstChild);
		}
	}

	return testElement;
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

function getParentByClassName(node, include_class) {
	if (!isElement(node) || !isBasicType(include_class)) { return null; }
	do {
		node = node.parentNode;
		if (!node || node.tagName == "BODY") { return null; }
	} while (!hasClassName(node,include_class));
	return node;
}

function setEventObserve(elem, eventName, func) {
	if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName) || !isFunction(func)) { return; }
	if (Event.observe) {
		Event.observe(elem, eventName, func);
	} else if (elem.removeEventListener) {						//DOM2接口 with bubble
		elem.addEventListener(eventName, func, false);
	} else if (elem.detachEvent) {					//IE DOM2接口  with bubble
		elem.attachEvent('on' + eventName, func);
	} else {											//DOM0接口 without bubble
		if (window.Prototype) {
			Event.observe(elem, eventName, func);
		} else {
			elem['on' + eventName] = func;
		}
	}
}

function stopEventObserving(elem, eventName, func) {
	if (!(isElement(elem) || elem == window || elem == document) || !isString(eventName)) { return; }
	if (Event.observe) {
		Event.stopObserving(elem, eventName, func);
	} else if (elem.removeEventListener) {						//DOM2接口 with bubble
		elem.removeEventListener(eventName, func);
	} else if (elem.detachEvent) {						//IE DOM2接口  with bubble
		elem.detachEvent('on' + eventName, func);
	} else {											//DOM0接口 without bubble
		if (window.Prototype) {
			Event.stopObserving(elem, eventName);
		} else {
			elem['on' + eventName] = null;
		}
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
					Event.fire(elem, eventName);
				} catch (exception) {
					try {
						elem['on' + eventName]();
					} catch (exception) {
					}
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

function isTextNode(node, allowFragment) {
	//nodeType == 3 --> TextNode
	return !!(node && node.nodeType === 3);
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

function getCellAttr(cell, attr, default_value) {
	default_value = default_value || '';
	if (!isElement(cell)) { return default_value; }
	var val = cell.getAttribute(attr);
	if (!val) { return default_value; }
	return val+'';
}

function getCellAttrToInt(cell, attr, default_int) {
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

function getClassNames(node) {
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
				if ((key + "").toLowerCase() != 'value') {
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
	}else if(isString(attrs)){
		node.setAttribute('id', attrs);
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

	if (content !== null && content !== undefined && content !== "null" && content !== "undefined") {
		node.appendChild(getElement(content));
	}

	if (isElement(appendAt, true)) {
		appendAt.appendChild(node);
	}

	return node;
}

function createFragment(elems) {
	var fragment = document.createDocumentFragment();
	if (isArray(elems)) {
		for (var i = 0 ; i < elems.length ; i = i + 1) {
			var elem = getElement(elems[i]);
			if (elem) {
				fragment.appendChild(elem);
			}
		}
	}
	return fragment;
}

function insertAfter(newNode, oldNode){
	if(!(isElement(newNode) && isElement(oldNode) && isElement(oldNode.parentNode))){ return; }
	if(oldNode.nextSibling){
		oldNode.parentNode.insertBefore(newNode,oldNode.nextSibling);
	}else{
		oldNode.parentNode.appendChild(newNode);
	};
}


function insertBefore(newNode, oldNode){
	if(!(isElement(newNode) && isElement(oldNode) && isElement(oldNode.parentNode))){ return; }
	oldNode.parentNode.insertBefore(newNode,oldNode);
}

function insertFirstChild(newNode, parentNode){
	if(!(isElement(newNode) && isElement(parentNode))){ return; }
	if(parentNode.childNodes.length){
		parentNode.insertBefore(newNode,parentNode.firstChild);
	}else{
		parentNode.appendChild(newNode);
	}
}

function insertLastChild(newNode, parentNode){
	if(!(isElement(newNode) && isElement(parentNode))){ return; }
	parentNode.appendChild(newNode);
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
	if(!isElement(elem) || isTextNode(elem) ){ return null;}
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
})();