var popupWin = new PopupWinUI();

function PopupWinUI()
{

	// 指定初始視窗寬及高的比例，( width or height) * numerator / denominator
	// 參數（widthNumerator:寬的分子, widthDenominator:寬的分母, heightNumerator:高的分子, heightDenominator:高的分母）
	var assignWidthAndHeight = {
		LAZ: { widthNumerator: 3, widthDenominator: 5, heightNumerator: 3, heightDenominator: 5 }
	};

	// 保留在開啟目前頁面時，最上層之高度
	var keepInitTopPopupWinDIVStyleHeight;
	var mainFrame = getMainFrame();
	if(mainFrame && mainFrame._popupWinDIV && mainFrame._popupWinDIV.style){
		keepInitTopPopupWinDIVStyleHeight = mainFrame._popupWinDIV.style.height;
	}

    var win, iframe, onclose, closeConfirm, active, fixed, scrolTop, scrolLeft, titleDiv, titleSpan, closeIcon, dragDiv, surroundDiv;

    var winPos, winDim;

    var orgWinStyle;

    var ctlCorner;

    var isAdjWin = true;

    var x, y, w, h, cbFunc;
    
    //八個控制角及中央主區塊
    var ltCorner, ctCorner, rtCorner, lmCorner, cmCorner, rmCorner, lbCorner, cbCorner, rbCorner;
    
    //corner 預設 css
	var c_default = {'position':'absolute', 'width':'3px', 'height':'3px', 'opacity':'0', 'backgroundColor':'#C7E497'};
	var c_left = {'left':0};
	var c_center = {'left':'3px'};
	var c_right = {};
	var c_top = {'top':0};
	var c_middle = {'top':'3px'};
	var c_bottom = {};

	function buildCorner() {

		ltCorner = new Element('div', {'class':'c_left c_top'}).setStyle(c_default).setStyle({'cursor':'nw-resize'});
		ctCorner = new Element('div', {'class':'c_center c_top'}).setStyle(c_default).setStyle({'cursor':'n-resize'});
		rtCorner = new Element('div', {'class':'c_right c_top'}).setStyle(c_default).setStyle({'cursor':'ne-resize'});

		lmCorner = new Element('div', {'class':'c_left c_middle'}).setStyle(c_default).setStyle({'cursor':'w-resize'});
		cmCorner = new Element('div', {'class':'c_center c_middle'}).setStyle(c_default);
		rmCorner = new Element('div', {'class':'c_right c_middle'}).setStyle(c_default).setStyle({'cursor':'w-resize'});		

		lbCorner = new Element('div', {'class':'c_left c_bottom'}).setStyle(c_default).setStyle({'cursor':'sw-resize'});
		cbCorner = new Element('div', {'class':'c_center c_bottom'}).setStyle(c_default).setStyle({'cursor':'s-resize'});
		rbCorner = new Element('div', {'class':'c_right c_bottom'}).setStyle(c_default).setStyle({'cursor':'se-resize'});		

	}

    function buildUI()
    {

    	buildCorner();

    	dragDiv = new Element('div');
    	/*
		dragDiv.setStyle({
			'position': 'absolute',
			'border':'solid 1px #000',
			'zIndex': '10',
			'-ms-filter': 'progid:DXImageTransform.Microsoft.Glow(color=#666666,strength=3) DXImageTransform.Microsoft.Shadow(color=#000000,direction=135,strength=3)',
			'filter': 'progid:DXImageTransform.Microsoft.Glow(color=#666666,strength=3) progid:DXImageTransform.Microsoft.Shadow(color=#000000,direction=135,strength=3)'
		});
		*/
		dragDiv.setStyle({
			'background':'#000',
			'position': 'absolute',
			'border':'solid 1px #ADADAD',
			'zIndex': '10',
			'margin':'-4px -4px',
			'-ms-filter':'progid:DXImageTransform.Microsoft.Blur(PixelRadius=3, MakeShadow=true, ShadowOpacity=0.60)',
			'filter':'progid:DXImageTransform.Microsoft.Blur(PixelRadius=3, MakeShadow=true, ShadowOpacity=0.60)',
			'filter': 'alpa(opacity=60)',	// old IE
			'filter': 'progid:DXImageTransform.Microsoft.Alpha(Opacity=60,FinishOpacity=15, Style=3, StartX=0, FinishX=100, StartY=0,FinishY=16)', // supported by current IE
			'-moz-opacity': '0.6',			// Moz + FF
			'opacity': '0.6'				// 支持新版瀏覽器
		});

        win = new Element('div', {'id':'_popupWinDIV'}).setStyle({
        	'backgroundColor':'#C7E497',
        	'position': 'absolute',
        	'border':'1px solid #000',
        	'zIndex':'10'
        });

		surroundDiv = new Element('div').setStyle({
			'background':'#000',
			'position': 'absolute',
			'border':'solid 1px #ADADAD',
			'zIndex': '9',
			'margin':'-4px -4px',
			'-ms-filter':'progid:DXImageTransform.Microsoft.Blur(PixelRadius=5, MakeShadow=true, ShadowOpacity=0.60)',
			'filter':'progid:DXImageTransform.Microsoft.Blur(PixelRadius=5, MakeShadow=true, ShadowOpacity=0.60)'
		});

        win.insert(ltCorner);
        win.insert(ctCorner);
        win.insert(rtCorner);
        win.insert(lmCorner);
        win.insert(cmCorner);
        win.insert(rmCorner);
        win.insert(lbCorner);
        win.insert(cbCorner);
        win.insert(rbCorner);

        titleDiv = new Element('div').setStyle({'padding':'0', 'margin':'0', 'fontSize':'1px'});;
        titleSpan = new Element('span').setStyle({'padding':'0', 'margin':'0', 'height':'14px', 'cursor':'move'});
		//closeIcon = new Element('img', {'src':UICore.imageBase + '/CM/close.gif'});
		closeIcon = new Element('img', {'src':'../../../images/CM/close.png'}).setStyle({'width':'16px', 'height':'14px', 'cursor':'hand'});

        titleDiv.insert(titleSpan);
        titleDiv.insert(closeIcon);

		iframe = new Element('iframe', {'width':'100%', 'height':'100%', 'id':'_popupWinIframe'});

        closeIcon.observe('click', function() {

       		active = false;

       		if(closeConfirm){
       			var assignConfirmType = closeConfirm['assignConfirmType']===false? false:true;
       			if(confirm(closeConfirm['msg']) !== assignConfirmType){
       				return;
       			}
       		}

       		if(onclose){onclose();}

       		delete cbFunc;
       		Event.stopObserving(window, 'scroll', fixPosition);

	        iframe.contentWindow.document.open();
	        iframe.contentWindow.document.write('');
	        iframe.contentWindow.document.close();       		

			surroundDiv.remove();
       		win.remove();
  		
        });
/*
        titleSpan.observe('mousedown', startDrag);

        //if resizing is not allow, don't attach event observe for follow corners
        ltCorner.observe('mousedown', startDrag);
		ctCorner.observe('mousedown', startDrag);
        rtCorner.observe('mousedown', startDrag);
		lmCorner.observe('mousedown', startDrag);
        rmCorner.observe('mousedown', startDrag);
		lbCorner.observe('mousedown', startDrag);
        cbCorner.observe('mousedown', startDrag);
		rbCorner.observe('mousedown', startDrag);						
*/
        cmCorner.insert(titleDiv);
        cmCorner.insert(iframe);

    }
    
    //若是開啟時以百分比指定寬、高，則在 window resize 時重新調整 win
    function adjWinByPercentage(event){

    	if(!active){
    		return;
    	}

    	Event.stop(event);
    	
    	if(orgWinStyle.width.indexOf('%') != -1){
    		win.setStyle({width:orgWinStyle.width});	
    	}
    	
    	if(orgWinStyle.height.indexOf('%') != -1){
    		win.setStyle({height:orgWinStyle.height});	
    	}

    	adjWin(win.getDimensions());
    	
    }

    function startDrag(event)
    {
    	surroundDiv.hide();
    	win.hide();
    	event.element().stopObserving('mousedown', startDrag);
        
        winPos = win.positionedOffset();
        winDim = win.getDimensions();
        
	    dragDiv.setStyle({
	      	'width':winDim.width,
	       	'height':winDim.height,
	       	'left':winPos.left,
	       	'top':winPos.top
	    });

        document.body.appendChild(dragDiv);
        dragDiv.show();
        
        var pointer = Event.pointer(event);
        x = pointer.x;
        y = pointer.y;
        	
        w = x - winPos.left;
        h = y - winPos.top;        
                
        if(event.element() == titleSpan){
        	
	        Event.observe(document, 'mousemove', drag);
	        Event.observe(document, 'mouseup', stopDrag);
	        
 	    }else{
 	    	
 	    	Event.observe(document, 'mousemove', sizing);
 	    	Event.observe(document, 'mouseup', resize);
 	    	ctlCorner = event.element();
 	    	
 	    }        

    }
    
    function sizing(event){

		var pointer = Event.pointer(event);
        x = pointer.x;
        y = pointer.y;
        
        Event.stop(event);

        var dy = y - winPos.top;
        var dx = x - winPos.left;
        
        var theCss;

        switch(ctlCorner){

        	case rtCorner : {
        		theCss = {
					top: y,
					height: (winDim.height - dy),
					width: dx
        		};
        		break;

        	}

        	case ctCorner : {
        		theCss = {
        			top: y,
        			height: (winDim.height - dy)
        		};
        		break;
        	}

        	case ltCorner : {
        		theCss = {
					top: y,
					left: (winPos.left + dx),
					height: (winDim.height - dy),
					width: (winDim.width - dx)
        		};
        		break;
        	}

        	case lmCorner : {
        		theCss = {
					left: (winPos.left + dx),
					width: (winDim.width - dx)
        		};
        		break;
        	}

        	case rmCorner : {
        		theCss = {width: dx};
        		break;
        	}

			case lbCorner : {
        		theCss = {
					left: (winPos.left + dx),
					height: dy,
					width: (winDim.width - dx)
        		};
				break;
			}

        	case cbCorner : {
        		theCss = {height: dy};
        		break;	
        	}

        	default : {
        		//rbCorner	
				theCss = {
					height:dy,
					width:dx
				};
				break;    		
        	}

        }

		dragDiv.setStyle(theCss);        

    }
    
    function resize(event){
    	
    	Event.stopObserving(document, 'mousemove', sizing);
    	Event.stopObserving(document, 'mouseup', resize);
    	Event.stopObserving(window, 'resize', adjWinByPercentage);
    	Event.stop(event);

    	//document.onmousemove = null;
    	//document.onmouseup = null;

    	var pos = dragDiv.positionedOffset();

    	win.setStyle({
    		width: dragDiv.getWidth() + 'px',
    		height: dragDiv.getHeight() + 'px',
    		top: pos.top,
    		left: pos.left
    	});

		adjWin(dragDiv.getDimensions());

		dragDiv.remove();
		win.show();
		adjSurroundDiv();
		surroundDiv.show();

        ctlCorner.observe('mousedown', startDrag);
        ctlCorner = null;

    }
    
    function drag(event)
    {
		
		var pointer = Event.pointer(event);
		Event.stop(event);
		
        x = pointer.x;
        y = pointer.y;
		
		dragDiv.setStyle({
			top:(y - h) + 'px',
			left:(x - w) + 'px'
		});
		
    }
    
    function stopDrag()
    {
    	Event.stopObserving(document, 'mousemove', drag);
    	Event.stopObserving(document, 'mouseup', stopDrag);
        Event.stop(event);
        
        var pos = dragDiv.positionedOffset();

        win.setStyle({
        	top:pos.top,
        	left:pos.left
        });
        
        dragDiv.remove();
        win.show();
		adjSurroundDiv();
		surroundDiv.show();

        titleSpan.observe('mousedown', startDrag);

    }

	function adjWin(dim, inFixedDim) {

		var fixDim;
		if(inFixedDim){
			fixDim=inFixedDim;
		}else{
			fixDim={
				c_centerWidth: 6,
				c_middleHeight: 20,
				c_rightLeft: 3,
				c_bottomTop: 3,
				titleSpanWidth: 22
			};
		}

		//中央區塊的寬度 = 視窗寬度減掉兩邊的 corner 寬度
		c_center.width = (dim.width - fixDim.c_centerWidth) + 'px';

		//中央區塊的高度 = 視窗高度 - 上下 corner 高度 - icon 高度
		c_middle.height = (dim.height - fixDim.c_middleHeight) + 'px';

		//右邊 corner 的 left = 視窗寬度減掉一邊的寬度
		c_right.left = (dim.width - fixDim.c_rightLeft) + 'px';
		
		//底部 corner 的 top = 視窗高度 - 一邊 corner 的高度
		c_bottom.top = (dim.height - fixDim.c_bottomTop) + 'px';

		//titleSpan holder 寬度 = 視窗寬度 - 兩邊 corner 寬度 - icon 寬度
		titleSpan.setStyle({'width':(dim.width - fixDim.titleSpanWidth) + 'px'});

		titleDiv.setStyle(c_center);

		win.select('.c_center').each(function(it){
			it.setStyle(c_center);
		});

		win.select('.c_right').each(function(it){
			it.setStyle(c_right);
		});

		win.select('.c_middle').each(function(it){
			it.setStyle(c_middle);
		});

		win.select('.c_bottom').each(function(it){
			it.setStyle(c_bottom);
		});

	}

	function adjSurroundDiv(){
        var winPos = win.positionedOffset();
        var winDim = win.getDimensions();
        var surroundDivWidth = winDim.width;
        var surroundDivHeight = winDim.height;
        var surroundDivLeft = winPos.left+6;
        var surroundDivTop = winPos.top+6;

	    surroundDiv.setStyle({
	      	'width':surroundDivWidth,
	       	'height':surroundDivHeight,
	       	'left':surroundDivLeft,
	       	'top':surroundDivTop
	    });

	}

	function getPupWinRatio(src){

		var obj;
		for(var key in assignWidthAndHeight){
			if(src.indexOf(key)>=0){
				obj = assignWidthAndHeight[key];
				break;
			}
		}

		if(!obj){
			obj = { widthNumerator: 2, widthDenominator: 3, heightNumerator: 2, heightDenominator: 3 };
		}

		return obj;
	}
    
    buildUI();

 
	/**
	 *  @public
	 *	@class 利用 DIV 產生視窗
	 *	@param config (Map)
	 *	@param config.src (String) : 所要連結之 url。
	 *	@param config.width (Number) : 開啟視窗寬度。
	 *	@param config.height (Number) : 開啟視窗寬度。
	 *	@param config.left (Number) : 開啟視窗距離左邊之寬度。
	 *	@param config.top (Number) : 開啟視窗距離上方之高度。
	 *	@param config.scrolling (String<yes/no>): 是否產生 scroll bar。
	 *	@param config.parameters (Array/Map/String) : 傳遞參數。
	 *	@param config.closeConfirm (Map)
	 *	@param config.closeConfirm.assignConfirmType (Boolean) : 判斷當出現 confirm 時，關閉 popupWin 的時機是在點選「確認 (true)」還是「取消 (false)」；若不設定則預設為「確認」。 
	 *	@param config.closeConfirm.msg (String) : confirm 時所顯示之訊息內容。
	 **/
    this.popup = function( inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters )
    {

		var config;
    	if( typeof(inConfig) == 'string' ) {
			// 此段處理是提供給國際投資部份子系統使用舊版的 popupWin 使用
			config = {
				src: inConfig,
				width: inWidth,
				height: inHeight,
				left: inLeft,
				top: inTop,
				scrolling: inScrolling,
				parameters: inParameters
			};

	    } else{
			config = inConfig;
	    }

		var src = config.src || '';

		var inputParam = config['parameters'];

		// while src large than 2083 bytes, iframe will fail to load the URI via src
		// so, we create a form and post it.
		// 2010/12/27 增加 parameters，可傳遞大量參數及資料
		if(src.length > 2083 || inputParam){

			//add a dummy src for trigger event
			iframe.writeAttribute( 'src', '');
			iframe.onreadystatechange = function(src){
				if(this.readyState == 'complete'){
					this.onreadystatechange = null;
					var doc = this.contentWindow.document;

					var f = new Element('form', {
						'action': src,
						'method': 'post'
					});

					var createSubmitParameter = function(n,v){
						return new Element('input', { 'type': 'hidden', 'name': n }).setValue(v);
					}

					if( Object.isString(inputParam) ){
						f.insert(createSubmitParameter('parameters', inputParam));

					}else if( Object.isArray(inputParam)){
						for( var i=0; i<inputParam.length; i++){
							var input = inputParam[i];

							for( ipn in input ){
								f.insert(createSubmitParameter(ipn, input[ipn]));
							}
						}

					}else{
						for( ipn in inputParam ){
							f.insert(createSubmitParameter(ipn, inputParam[ipn]));
						}
					}

					doc.appendChild(f);

					//doc.open();
					//doc.write('<form action="' + src + '" method="post" ></form>');
					//doc.close();

					f.submit();
				}
			}.bind(iframe, src);// bind the iframe object as the execute context, and src as the argument

        }else{
        	iframe.setAttribute( "src", config['src'] );	
        }

        fixed = config.fixed;

        iframe.scrolling = config['scrolling'] ? config['scrolling'] : "yes";
        onclose = config.onclose;
        closeConfirm = config['closeConfirm'];

        var callbackHandler;
        var closeHandler = this.close;

        if(config['cb']){
        	cbFunc = config['cb'];
			callbackHandler = this.callbackProxy;
        }else{
        	delete cbFunc;
        }

		$(iframe).observe('load', function(e){

			if(callbackHandler){
				iframe.contentWindow.callbackHandler = callbackHandler;
			}
			iframe.contentWindow.close = closeHandler;
		});

		//set the position while inactive
      	if(!active){

			var obj = getPupWinRatio(src);

			var dbsw = document.body.scrollWidth;
			var dbsh = document.body.scrollHeight;
			var defaultWidth = dbsw*obj['widthNumerator']/obj['widthDenominator'];
			var defaultHeight = dbsh*obj['heightNumerator']/obj['heightDenominator'];
			var defaultLeft = (dbsw-defaultWidth)/2;
			var defaultTop = (dbsh-defaultHeight)/4;

	        win.style.width = config['width'] ? config['width'] : defaultWidth;
	        win.style.height = config['height'] ? config['height'] : defaultHeight;
	        win.style.left = config['left'] ? config['left'] : defaultLeft;
	        win.style.top = config['top'] ? config['top'] : defaultTop;

	        document.body.appendChild( win );

			cmCorner.setOpacity(1);

			isAdjWin = config['isAdjWin']!=='no';
			if(!isAdjWin){

				adjWin(win.getDimensions(),{
					c_centerWidth: 1,
					c_middleHeight: 0,
					c_rightLeft: 0,
					c_bottomTop: 0,
					titleSpanWidth: 22
				});

				surroundDiv.hide();
				closeIcon.hide();
		        titleSpan.stopObserving('mousedown');

		        //if resizing is not allow, don't attach event observe for follow corners
		        ltCorner.stopObserving('mousedown');
				ctCorner.stopObserving('mousedown');
		        rtCorner.stopObserving('mousedown');
				lmCorner.stopObserving('mousedown');
		        rmCorner.stopObserving('mousedown');
				lbCorner.stopObserving('mousedown');
		        cbCorner.stopObserving('mousedown');
				rbCorner.stopObserving('mousedown');

				win.select('.c_center').each(function(it){
					it.setStyle({'left':'0px', 'right':'0px'});
				});

				win.select('.c_right').each(function(it){
					it.setStyle({'left':'0px', 'right':'0px'});
				});

				win.select('.c_middle').each(function(it){
					it.setStyle({'top':'0px', 'left':'0px', 'right':'0px'});
				});

				win.select('.c_bottom').each(function(it){
					it.setStyle({'top':'0px', 'left':'0px', 'right':'0px'});
				});

			}else{

				adjWin(win.getDimensions());
	        	adjSurroundDiv();
				surroundDiv.show();
	        	document.body.appendChild( surroundDiv );

				closeIcon.show();
		        titleSpan.observe('mousedown', startDrag);

		        //if resizing is not allow, don't attach event observe for follow corners
		        ltCorner.observe('mousedown', startDrag);
				ctCorner.observe('mousedown', startDrag);
		        rtCorner.observe('mousedown', startDrag);
				lmCorner.observe('mousedown', startDrag);
		        rmCorner.observe('mousedown', startDrag);
				lbCorner.observe('mousedown', startDrag);
		        cbCorner.observe('mousedown', startDrag);
				rbCorner.observe('mousedown', startDrag);

				if(fixed){
					var scrol = document.viewport.getScrollOffsets();
					scrolTop = scrol.top;
					scrolLeft = scrol.left;
			        Event.observe(window, 'scroll', fixPosition);
				}

				var strW = new String(win.style.width);
				var strH = new String(win.style.height);

				if(strW.indexOf('%') != -1
				   	|| strH.indexOf('%') != -1){
	
					orgWinStyle = {
						width: strW,
						height: strH		   
					};

					Event.observe(window, 'resize', adjWinByPercentage);
				}
			}

			active = true;

		}

    }

	var hasFullPopup = false;

    function changeHeight( event )
    {
        var tagetHeight = event.element().contentWindow.document.body.scrollHeight;

        // 調整頁面的高度
        if( document.body.scrollHeight < tagetHeight ) {
    		win.setStyle({height:tagetHeight});
    		event.element().style.height=tagetHeight;
        }

        if(top.leftFrame.mainFrame._popupWinDIV){
        	top.leftFrame.mainFrame._popupWinDIV.style.height=win.style.height;
        }

    }

	/**
	 *  @public
	 *	@class 利用 DIV 產生視窗（與目前所瀏覽之頁面大小相同）
	 *	@param config (Map)
	 *	@param config.src (String) : 所要連結之 url。
	 *	@param config.parameters (Array/Map/String) : 傳遞參數。
	 **/
    this.fullPopup = function( inConfig ) {

        if( !hasFullPopup ) {
            isFullPopup = true;
            $( iframe ).observe( "load", changeHeight );

            var fixWinSize = function(event){

            	var popupWinIfram = $('_popupWinIframe');
            	if(!popupWinIfram){return;}

            	var bodycw = document.body.clientWidth-1+'px';
            	var bodysh = document.body.scrollHeight-1+'px';

            	// 若 width 及 height 相同時，不進行更換
            	if(popupWinIfram.style.width==bodycw && popupWinIfram.style.height==bodysh){return; }

            	popupWinIfram.setStyle({
            		width: bodycw,
            		height: bodysh
            	});

            	win.style.width=bodycw;
        		win.select('.c_center').each(function(it){
        			it.setStyle({width: bodycw});
        		});

        		titleDiv.style.width=bodycw;
        		titleSpan.style.width=bodycw;

            }

            var callFix;
            if(!window.fix){ var fix; }
            if( !Object.isUndefined(fix) && Object.isFunction(fix) ){
            	fix = fix.wrap(fixWinSize);
            	callFix = fix;
            }else{
            	callFix = fixWinSize;
            }

            Event.observe(window, 'resize', callFix);

        }

		var config;
    	if( typeof(inConfig) == 'string' ) {
			// 此段處理是提供給國際投資部份子系統使用舊版的 popupWin 使用
			config = {
				src: inConfig
			};
	    } else{
			config = inConfig;
	    }

		var url = config.src;
		var isInternational = (url.match(/\/R.*Web*/)==null && url.match(/\/QBWeb*/)==null)?'yes':'no';

		config['width'] = document.body.scrollWidth-1;
		config['height'] = document.body.scrollHeight+100;
		config['left'] = '0px';
		config['top'] = '-14px';
		config['scrolling'] = isInternational;
		config['isAdjWin'] = isInternational;
        popupWin.popup(config);

    }

    function fixPosition(event){
    	var top = parseInt(win.style.top);
    	var left = parseInt(win.style.left);
    	
    	var scrl = document.viewport.getScrollOffsets();
    	
    	win.style.top = (top - scrolTop) + scrl.top;
    	win.style.left = (left - scrolLeft) + scrl.left;
    	
    	scrolTop = scrl.top;
    	scrolLeft = scrl.left;
    }

    this.callbackProxy = function(obj){
    	if(cbFunc){
    		//recreate the obj for current page used
    		obj = Object.toJSON(obj).evalJSON();
    		cbFunc(obj);
    	}
    }

    this.close = function ()
    {
	    iframe.contentWindow.document.open();
	    iframe.contentWindow.document.write('');
	    iframe.contentWindow.document.close();
	    iframe.style.height='100%';
	    iframe.style.width='100%';

		if(isAdjWin){
			document.body.removeChild( surroundDiv );
		}
	    document.body.removeChild( win );
	    if(onclose){onclose()};
	    active = false;
	    Event.stopObserving(window, 'scroll', fixPosition);
	    delete cbFunc;

		parent.focus();

		// 關閉時調整畫面
		if (!Object.isUndefined(window.fix) && Object.isFunction(window.fix)){
			window.fix();
			window.onscroll=window.fix;
		}
    }

	/**
	 *  @public
	 *	@class 利用 DIV 產生視窗
	 *	@param text (String): 於畫面所要顯示之文字。
	 *	@param config (Map)
	 *	@param config.src (String) : 所要連結之 url。
	 *	@param config.width (Number) : 開啟視窗寬度。
	 *	@param config.height (Number) : 開啟視窗寬度。
	 *	@param config.left (Number) : 開啟視窗距離左邊之寬度。
	 *	@param config.top (Number) : 開啟視窗距離上方之高度。
	 *	@param config.scrolling (String<yes/no>): 是否產生 scroll bar。
	 *	@param config.parameters (Array/Map/String) : 傳遞參數。
	 *	@param config.closeConfirm (Map)
	 *	@param config.closeConfirm.assignConfirmType (Boolean) : 判斷當出現 confirm 時，關閉 popupWin 的時機是在點選「確認 (true)」還是「取消 (false)」；若不設定則預設為「確認」。 
	 *	@param config.closeConfirm.msg (String) : confirm 時所顯示之訊息內容。
	 **/
    this.createPopupLink = function( text, inConfig, inWidth, inHeight, inLeft, inTop, inScrolling, inParameters )
    {

		var config;
    	if( typeof(inConfig) == 'string' ) {
			// 此段處理是提供給國際投資部份子系統使用舊版的 popupWin 使用
			config = {
				src: inConfig,
				width: inWidth || '100%',
				height: inHeight || document.body.scrollHeight,
				left: inLeft || '0px',
				top: inTop || '-14px',
				scrolling: inScrolling || 'no',
				parameters: inParameters || ''
			};

	    } else{
			config = inConfig;
	    }

        var link = new Element( "a", { 'href': "#" }).update(text).observe('click', function(){
        	popupWin.popup( config );
        });
        return link;
    }

	/**
	 *  @public
	 *	@class 利用 DIV 產生視窗（與目前所瀏覽之頁面大小相同）
	 *	@param text (String): 於畫面所要顯示之文字。
	 *	@param config (Map)
	 *	@param config.src (String) : 所要連結之 url。
	 *	@param config.parameters (Array/Map/String) : 傳遞參數。
	 **/
	this.createFullPopupLink = function( text, url )
    {
        var link = new Element( "a", { 'href': "#" }).update(text).observe('click', function(){
        	popupWin.popup( url );
        });

        return link;
    }

	/**
	 * 增加 Function「changeTopScrollHeight」，提供自動調整或指定最上層之頁面高度
	 * @param changeHeight 指定高度
	 */
	this.changeTopScrollHeight = function(changeHeight){

		var mainFrame = getMainFrame();
		if(!mainFrame || !mainFrame._popupWinDIV){
			return;
		}

		var topPopupWinDIV = mainFrame._popupWinDIV;
		if(changeHeight){
			topPopupWinDIV.style.height = changeHeight;
			if(parent._popupWinDIV){
				parent._popupWinDIV.style.height = changeHeight;
			}
			return;
		}

		var bodyScrollHeight = document.body.scrollHeight+50;
		if(topPopupWinDIV.style.height < bodyScrollHeight){
			topPopupWinDIV.style.height = bodyScrollHeight+'px';
			if(parent._popupWinDIV){
				parent._popupWinDIV.style.height = bodyScrollHeight+'px';
			}
		}

		// 調整顯示內容之高度
		$(topPopupWinDIV).select('[id="_popupWinIframe"]').each(function(o){
			o.style.height = bodyScrollHeight+'px';
		});

	}

	/**
	 * 增加 Function「rollBackTopScrollHeight」，提供回復連結進入頁面時，最上層之初始頁面高度
	 */
	this.rollBackTopScrollHeight = function(){
		var mainFrame = getMainFrame();
		if(mainFrame && mainFrame._popupWinDIV && keepInitTopPopupWinDIVStyleHeight){
			mainFrame.scrollTo( 0, 0 );
			mainFrame._popupWinDIV.style.height = keepInitTopPopupWinDIVStyleHeight;
		}
	}

	function getMainFrame(){
		var topLeftFrame = top.leftFrame;
		if(topLeftFrame && topLeftFrame.mainFrame){
			return topLeftFrame.mainFrame;
		}
	}

}