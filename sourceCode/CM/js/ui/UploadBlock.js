// dynamic add css style function and naming space
;(function(document, window){
    'use strict';
    
    window.$U = window.$U || {};
    var _$UStyle = undefined,
        $U = window.$U;

    // Simple add for IE11
    if(Object.assign === undefined) {
        Object.assign = function (target, srouce) {
            var args = Array.prototype.slice.call(arguments);
            return args.reduce(function(r, o){
                    if(o) {
                        Object.keys(o).forEach(function(k){
                            r[k] = o[k];
                        });
                    }
                    return r;
                    }, {});
        }
    }        

    function createMyStyleSheet() {
        if(_$UStyle !== undefined) return;
        var styleElement = document.createElement('style');
        styleElement.tyle = 'text/css';
        document.getElementsByTagName('head')[0].appendChild(styleElement);
        _$UStyle = styleElement.sheet;
    };

    function cssExist(selector) {
        for(var i = 0; i < _$UStyle.cssRules.length; i++) {
            var rule = _$UStyle.cssRules[i];
            if(selector == rule.selectorText) {
                return true;
            }
        }
        return false;
    }

    $U.createCssClass = function(selector, style) {

        if(_$UStyle === undefined) createMyStyleSheet();

        if(selector.indexOf('.') != 0) selector = '.' + selector;

        if(cssExist(selector)) return;

        if(typeof style === 'object') {
            var styleStr = ' {';
            for(var p in style) {
                styleStr += p + ':' + style[p] + ';'
            }
            styleStr += '}';
            _$UStyle.insertRule(selector + styleStr, _$UStyle.cssRules.length);    
        } else {
            _$UStyle.insertRule(selector + ' ' + style, _$UStyle.cssRules.length);
        }

    }
    
})(document, window);

//-------------------------------------------------------------------
// 檔案上傳框
// 參考來源 https://css-tricks.com/examples/DragAndDropFileUploading/ 
// 自行客製元件化並加入 CTRL + V 的處理
// 相容 IE 11 及 Chrome
//-------------------------------------------------------------------
;(function(document, window, $U){
    'use strict';

    // feature detection for drag&drop upload
    var isAdvancedUpload = function() {
            var div = document.createElement( 'div' );
            return ( ( 'draggable' in div ) || ( 'ondragstart' in div && 'ondrop' in div ) ) && 'FormData' in window && 'FileReader' in window;
        }();

    if(!isAdvancedUpload) {
        alert('\u700f\u7060\u5668\u4e0d\u652f\u63f4\u62d6\u62c9\u4e0a\u50b3\u7684\u529f\u80fd\uff0c\u8acb\u4f7f\u7528 IE11 \u6216 Chrome');
        return;
    }

    var defaultClasses = {
            box: 'u-box',
            hasAdvancedUpload: 'u-box-has-advanced-upload',
            isDragover: 'u-box-is-dragover',
            dnd: 'u-box-dragndrop',
            icon: 'u-box-icon',
            uploading: 'u-box-uploading',
            isUploading: 'u-box-is-uploading',
            pasteCover: 'u-box-paste-cover',
            inputFile: 'u-box-input-file',
            fileClick: 'u-box-file-click'
        },
        defaultOptions = {
            uploadURL: '/upload',
            dndHTML: '\u5c07\u6a94\u6848\u62d6\u9032\u6846\u88e1<br/>\u6216<span class="u-box-file-click">\u9ede\u9019\u88e1\u9078\u53d6\u6a94\u6848</span>\u4e0a\u50b3',
            pasteHTML: 'ALT + PrtScrn \u87a2\u5e55\u622a\u5716<br/>CTRL+V \u8cbc\u5165\u4e0a\u50b3',
            classes: defaultClasses
        };

    // 建立需要的 css
    function buildCss(classes) {

        //.u-box
        if(classes.box == defaultClasses.box) {
            $U.createCssClass(classes.box, '{font-size: 1.25rem; font-family:Roboto, sans-serif; line-height: 1.5rem; background-color: #c8dadf; position: relative; padding: 5px; text-align: center; color: #0f3c4b;}');
        }

        //.u-box-has-advanced-upload
        $U.createCssClass(classes.hasAdvancedUpload, 
            '{outline: 2px dashed #92b0b3; outline-offset: -1px; -webkit-transition: outline-offset .15s ease-in-out, background-color .15s linear; transition: outline-offset .15s ease-in-out, background-color .15s linear;');

        //.u-box-is-dragover
        $U.createCssClass(classes.isDragover, '{outline-offset: -20px; outline-color: #c8dadf; background-color: #fff;}');

        // .u-box-dragndrop
        $U.createCssClass(classes.dnd, '{display: inline;}');

        // .u-box-icon
        $U.createCssClass(classes.icon, '{width: 100%; height: 60px; fill: #92b0b3; display: block; margin-bottom: 10px;}');

        // .u-box-uploading
        $U.createCssClass(classes.uploading, '{display: none; font-style: italic;}');

        // .u-box.is-uploading
        $U.createCssClass(classes.isUploading, '{display: block; position: absolute; top: 50%; right: 0; left: 0; -webkit-transform: translateY( -50% ); transform: translateY( -50% );}');
        
        // .u-box-paste-cover
        $U.createCssClass(classes.pasteCover, '{z-index: 10; position: absolute; top: 0; left: 0; width: 100%; height: 100%;}');
        
        // .u-box-input-file
        $U.createCssClass(classes.inputFile, '{z-index: -1; position: absolute; width: 0.1px; height: 0.1px; overflow: hidden;}');
        
        // .u-box-file-click
        $U.createCssClass(classes.fileClick, '{z-index: 100; position: relative; cursor: pointer; color: #39bfd3; font-weight: bold; font-size: 1.5rem; text-decoration: underline;}');

    }

    var ajaxUpload = function (url, files, paste, elem) {

        var ajaxData = new FormData();
        if( files ){
            Array.prototype.forEach.call( files, function( file ){
                if(paste) {
					// 從剪貼簿來的，加給檔案名稱
                    ajaxData.append( 'file', file, '\u87a2\u5e55\u5feb\u7167_' + Math.floor(Date.now() / 100) + '.png' );
                } else {
                    ajaxData.append( 'file', file );
                }
            });
        }

        // ajax request
        var ajax = new XMLHttpRequest();
        ajax.open( 'post', url, true );
        ajax.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        ajax.onload = function(){         

            if( ajax.status >= 200 && ajax.status < 400 ){
                var data = ajax.responseText, 
                    contentType = ajax.getResponseHeader('content-type'),
                    event;

                if(data) {
                    if(contentType && contentType.indexOf('application/json') != -1) {
                        data = JSON.parse(data);
                    }
                    event = createEvent( 'success', {data:data} );
                } else {
                    event = createEvent( 'success');
                }
                elem.dispatchEvent(event);
            } else {
                var event = createEvent( 'error', {data:'\u4e0a\u50b3\u932f\u8aa4\uff0c\u8acb\u91cd\u8a66!, status:' + ajax.status} );
                elem.dispatchEvent(event);
            }
        };
        ajax.onerror = function(){
            var event = createEvent( 'error', {data:'\u4e0a\u50b3\u932f\u8aa4\uff0c\u8acb\u91cd\u8a66!'} );
            elem.dispatchEvent(event);
        };
        ajax.onloadstart = function() {
            elem.dispatchEvent(createEvent( 'start' ));
        };
        ajax.onloadend = function() {
            elem.dispatchEvent(createEvent( 'complete' ));
        };
        ajax.upload.addEventListener( 'progress', function(e){
            var event = createEvent( 'progress', {loaded:e.loaded, total:e.total} );
            elem.dispatchEvent(event);
        }, false);        
        ajax.send( ajaxData );        

    }

    function createEvent(type, data) {
        var event = undefined;
        if(typeof(Event) === 'function') {
            event = new Event(type);
        } else {
            event = document.createEvent('Event');
            event.initEvent( type, true, true);
        }
        if(data) {
            for(var p in data) {
                event[p] = data[p];
            }
        }
        return event;
    }

    // 輸出建立 UploadBlock 的方法
    $U.uploadBlock = function (selector, options) {

        if(options) {
            options.classes & (options.classes = Object.assign({}, defaultOptions.classes, options.classes));    
        }
        
        var elem = document.querySelector(selector),
            opts = Object.assign({}, defaultOptions, options),
            css  = opts.classes,
            handleIE = function (e, clipboardData) {
                // IE11 CTRL + V 的事件處理
                var fileList = clipboardData.files;
                if(!fileList || fileList.length == 0) {
                    alert('\u53ea\u53ef\u8cbc\u5165\u5716\u5f62\u6a94\u4e0a\u50b3');
                    return;
                }                  
        
                for(var i = 0; i < fileList.length; i++) {
                    if(fileList[i].type.indexOf('image') == -1) {
                        alert('\u53ea\u53ef\u8cbc\u5165\u5716\u5f62\u6a94\u4e0a\u50b3');
                        return;
                    }
                }

                ajaxUpload(opts.uploadURL, fileList, true, elem);
        
            },
            handleChrome = function(clipboardData) {
                // Chrome CTRL + V 的事件處理
                var fileList = [];
                Array.prototype.forEach.call(clipboardData.items, function(item){
                    if(item.type.indexOf('image') !== -1) {
                        fileList.push(item.getAsFile());
                    }
                });

                if(fileList.length == 0) {
                    alert('\u53ea\u53ef\u8cbc\u5165\u5716\u5f62\u6a94\u4e0a\u50b3');
                    return;                    
                }

                ajaxUpload(opts.uploadURL, fileList, true, elem);

            };
            
        buildCss(opts.classes);
        
        // 加入上傳框指定的 css
        elem.classList.add(css.box);
        elem.classList.add(css.hasAdvancedUpload);

        var inputDiv = document.createElement('div'),
            icon     = document.createElementNS('http://www.w3.org/2000/svg', 'svg'),
            iconPath = document.createElementNS('http://www.w3.org/2000/svg', 'path'),
            label    = document.createElement('label'),
            inputFile = document.createElement('input'),
            pasteCover = document.createElement('div');

        // create icon svg    
        icon.setAttribute('class', css.icon); // svg using classList.add will fail in IE11
        icon.setAttributeNS(null, 'width', '32');
        icon.setAttributeNS(null, 'height', '32');
        icon.setAttributeNS(null, 'viewBox', '0 0 32 32');

        // draw icon
        iconPath.setAttribute('d', 'M14 18h4v-8h6l-8-8-8 8h6zM20 13.5v3.085l9.158 3.415-13.158 4.907-13.158-4.907 9.158-3.415v-3.085l-12 4.5v8l16 6 16-6v-8z');

        // input file
        inputFile.setAttribute('type', 'file');
        inputFile.setAttribute('id', '_upload_block_input_file');
        inputFile.classList.add(css.inputFile);
        
        // fill label text
        label.setAttribute('for', '_upload_block_input_file');
        label.classList.add(css.dnd);
        label.innerHTML = opts.dndHTML;

        // 剪貼簿 cover
        pasteCover.setAttribute('contentEditable', 'true');
        pasteCover.classList.add(css.pasteCover);

        // 組裝所有的 ui 元件
        icon.appendChild(iconPath);
        inputDiv.appendChild(icon);
        inputDiv.appendChild(label);
        inputDiv.appendChild(inputFile);
        elem.appendChild(inputDiv);
        elem.appendChild(pasteCover);
        
        /////////////////////////////////////////////////////////////////////////////////////////
        // 傳統選檔案上傳的事件處理
        /////////////////////////////////////////////////////////////////////////////////////////
        inputFile.addEventListener('change', function(e) {
        	ajaxUpload(opts.uploadURL, e.target.files, false, elem);
        });

        /////////////////////////////////////////////////////////////////////////////////////////
        // CTRL+V 框的 cover 事件處理
        // 蓋在上傳框的上面，以接收剪貼簿的相關事件
        /////////////////////////////////////////////////////////////////////////////////////////
        pasteCover.addEventListener('focus', function(e) {
            icon.style.visibility = 'hidden';
            label.innerHTML = opts.pasteHTML;
        });

        pasteCover.addEventListener('blur', function(e) {
            icon.style.visibility = 'visible';
            label.innerHTML = opts.dndHTML;
        });
        
        // 處理 CTRL + V 事件
        pasteCover.addEventListener('paste', function(e){

            e.preventDefault();

            if(e.clipboardData) {
                handleChrome(e.clipboardData);
            } else if (window.clipboardData) {
                handleIE(e, window.clipboardData);
            }

        }, false);
        
        /////////////////////////////////////////////////////////////////////////////////////////
        // drag&drop files
        /////////////////////////////////////////////////////////////////////////////////////////        
        [ 'drag', 'dragstart', 'dragend', 'dragover', 'dragenter', 'dragleave', 'drop' ].forEach( function( event ) {
            elem.addEventListener( event, function( e ){
                e.preventDefault();
                e.stopPropagation();
            });
        });
        [ 'dragover', 'dragenter' ].forEach( function( event ){
            elem.addEventListener( event, function(){
                elem.classList.add( css.isDragover );
            });
        });
        [ 'dragleave', 'dragend', 'drop' ].forEach( function( event ){
            elem.addEventListener( event, function(){
                elem.classList.remove( css.isDragover );
            });
        });
        elem.addEventListener( 'drop', function( e ){
            var droppedFiles = e.dataTransfer.files; // the files that were dropped
            ajaxUpload(opts.uploadURL, droppedFiles, false, elem);
        });

        return elem;

    }

})(document, window, window.$U);