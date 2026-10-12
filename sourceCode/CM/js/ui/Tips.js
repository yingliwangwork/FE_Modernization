/**
 *  @public
 *  @class 提示視窗
 *         範例如下：
 *             var tips = new Tips({
 *                 url: '<%=dispatcher%>/AKZ0_0400/getFuncInfo',
 *                 cacheKeys: ['FUND_ID','FUND_DATE'],
 *                 elements: [{tips:'FUND'}],
 *                 contentFormatFunc: function(record){
 *                 	   return record['FUND_C_NAME']||'查無資料';
 *                 }
 *                 contentExt: {
 *                     bgColor:'#FEFFE7',
 *                     canDrag: true
 *                 }
 *             });
 *  @param opts (Map) :
 *	       opts.url(String) : 請求連結（必輸欄位）
 *         opts.urlParams(String) : 請求連結參數
 *	       opts.cacheKeys(String) : 載入資料要作為 cache key 的欄位名稱（必輸欄位）
 *	       opts.elements(Array)   : 處理的頁面物件（必輸欄位）
 *	       opts.contentFormatFunc(Function) :  得到該筆資料所要顯示的內容（必輸欄位）
 *         opts.contentExt(Map) 內容延伸設定屬性
 *                  fontSize(Number) : 文字大小（預設為 10pt）
 *                  bgColor(String)  : 背景顏色（預設為白色）
 *                  canDrag(Boolean) : 是否可拖拉提示視窗（預設為 false）
 *  @author 劉本傑
 *  @version 1.00
 **/
function Tips(opts){

	var url = opts['url'];
	var urlParams = opts['urlParams']||{};
	var cacheKeys = opts['cacheKeys'];
	var elements = opts['elements']||[];
	var contentFormatFunc = opts['contentFormatFunc'];
	var contentExt = opts['contentExt']||{};
	var contentFontSize = contentExt['fontSize']||'10';
	var contentBgColor = contentExt['bgColor']||'#FFFFFF';
	var contentCanDrag = contentExt['canDrag']===true;

	var dataCache = {};

	var tips = new function() {

		var win;
		var contentDiv;
		var dragDiv;
		var coverPage;
		var x, y, w, h;
		var contentDivMaxWidth = 600;

		function build(){
			win = new Element('div', {'align':'center'});
			win.setStyle({
				fontFamily:'Verdana, Arial, sans-serif, 微軟正黑體',
				contentFontSize:contentFontSize+'pt',
				position:'absolute',
				background:'url(../../../images/CM/ui/CSRUtil.coverPage.bg.png)',
				zIndex:200
			});

			contentDiv = new Element('div', {'align':'left'});
			win.insert(contentDiv);
			contentDiv.setStyle({
				backgroundColor: contentBgColor,
				overflow:'auto', 
				border: '2px solid #C9C9C9',
				paddingLeft: '10px',
				paddingBottom: '2px',
				paddingTop: '2px',
				margin:'-3px 3px 3px -3px',
				position: 'relative',
				'white-space': 'nowrap'
			});

			if(contentCanDrag){
				contentDiv.setStyle({
					cursor:'move'
				});
				dragDiv = new Element('div');
				dragDiv.setStyle({
					'position':'absolute',
					'border':'1px solid #000000'
				});
				contentDiv.observe('mousedown', startDrag);
			}

			coverPage = new function(){
				var docBody = document.body||document;
				var coverStyle = {
					width: '100%',
					height: '100%',
					position: 'absolute',
					left: 0,
					top: 0,
					posLeft: 0,
					posTop: 0,
					margin: '0 auto',
					cursor: 'progress',
					zIndex: 150
				};
				cover = new Element('div');
				docBody.appendChild(cover);
				cover.setStyle(coverStyle).hide();
				return cover;
			};

			coverPage.observe('mousedown', stopEvent);

			if(url){
				Ajax.Responders.unregister(CSRUtil.defaultAjaxHandler);
				new Ajax.Request( url,{ 	
			    	parameters: urlParams,
					onSuccess: function( XHT ) {
						var resp = XHT.responseJSON;
						if(CSRUtil.isSuccess(resp)){
							loadRecords(resp.records);
						}
					}
			    });
				Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
			}
		}

		function stopEvent(e){
			document.body.style.overflow="";
			win.remove();
			contentDiv.update('');
			Event.stop(e);
			document.stopObserving('keypress');
			document.stopObserving('click');
			coverPage.hide();
		}

		function loadRecords(records, keys){

			if(!(records && records.length && records.length>0) ){
				return;
			}

			if(!(cacheKeys && cacheKeys.length && cacheKeys.length>0) ){
				return;
			}

			if(!(keys && keys.length && keys.length>0) ){
				keys = cacheKeys;
			}

			records.each(function(record){
				var dataCacheKey='';
				for(var i=0;i<keys.length;i++){
					if(i>0){
						dataCacheKey+='--';
					}
					dataCacheKey+=record[keys[i]];
				}
				dataCache[dataCacheKey]=record;
			});
		}

		function startDrag(){
			contentDiv.stopObserving('mousedown', startDrag);
	        x = Event.pointerX(event);
	        y = Event.pointerY(event);
	
	        var pos = win.positionedOffset();
	
	        w = x - pos.left;
	        h = y - pos.top;
	
	        dragDiv.setStyle({
	        	'width':win.getWidth(),
	        	'height':win.getHeight(),
	        	'left':pos.left,
	        	'top':pos.top
	        });
	        
	        document.body.appendChild(dragDiv);
	        dragDiv.show();
	        
	        Event.observe(document, 'mousemove', drag);
	        Event.observe(document, 'mouseup', stopDrag);		
		}
		
	    function drag(event){
	        x = Event.pointerX(event);
	        y = Event.pointerY(event);
			Event.stop(event);    
			
			dragDiv.setStyle({
				top:(y - h) + 'px',
				left:(x - w) + 'px'
			});
			win.remove();
	    }
	    
	    function stopDrag(event){
	    	Event.stopObserving(document, 'mousemove', drag);
	    	Event.stopObserving(document, 'mouseup', stopDrag);
	        Event.stop(event);
	        
	        var pos = dragDiv.positionedOffset();
	        win.setStyle({
	        	top:pos.top,
	        	left:pos.left
	        });
	        dragDiv.remove();
	        document.body.appendChild(win);
	        contentDiv.observe('mousedown', startDrag);
	    }

		build();
		
		return {
	
			displayContent:function(content){

				coverPage.show();
				var content = content||'';

				var x = content.length * contentFontSize * 1.5 + 40;
				if(contentDiv.innerText==''){
					document.body.appendChild(win);

					document.observe('keypress', function(e){
						// 若按下 Enter、Esc、空白鍵時，則觸發訊息內確定的 click event
						if(e.keyCode == Event.KEY_RETURN || e.keyCode == Event.KEY_ESC || e.keyCode == 32) {
							stopEvent(e);
						}
					});

					document.observe('click', function(e){
						if(e.target.tagName.toUpperCase() !== 'DIV'){
							stopEvent(e);
						}
					});

				}

				if(x > contentDivMaxWidth){
					win.setStyle({'width':contentDivMaxWidth + 'px'});
				}else {
					win.setStyle({'width': x + 'px'});
				}

				contentDiv.update(content).focus();

				var oEvent = window.event ? window.event : e;
				var scrollTop = document.body.scrollTop;
				var scrollLeft = document.body.scrollLeft;

				var maxTop = scrollTop + document.body.offsetHeight - win.offsetHeight - 20;
				var maxLeft = scrollLeft + document.body.offsetWidth - win.offsetWidth - 20;

				var currTop = scrollTop + oEvent.clientY - 2 + 10;
				var currLeft = scrollLeft + oEvent.clientX - 2 + 10;

				win.style.top = ((maxTop>0 && currTop>maxTop)?maxTop:currTop)+'px';
				win.style.left = ((maxLeft>0 && currLeft>maxLeft)?maxLeft:currLeft)+'px';
			}
		};
	};

	function active(ele){
		if(!ele){
			return;
		}
		ele.observe('mousedown', function(){

			if(!Object.isFunction(contentFormatFunc)){
				tips.displayContent('初始時無定義取得內容的方法');
				return;
			}

			var dataCacheKey = '';
			for(var i=0;i<cacheKeys.length;i++){
				if(i>0){
					dataCacheKey+='--';
				}
				dataCacheKey+=ele.getAttribute(cacheKeys[i]);
			}

			var record = dataCache[dataCacheKey];
			if(record){
				tips.displayContent(contentFormatFunc(record));
			}else{
				tips.displayContent('無相關資料');
			}

		}).setStyle({cursor:'pointer'});
	}

	function getElementCallActive(ele){
		var id = ele['id'];
		if(id){
			active($(id));
		}else{
			$$('[tips='+ele['tips']+']').each(function(o){
				active(o);
			});
		}
	}

	elements.each(getElementCallActive);

	return {
		/**
		 *  @public 註冊要處理的 dom 物件（可用 id 或是定義 tips 的名稱），提供給初始之外才得到之物件使用
		 *          若 td 定義如下：
		 *              <td tips="FUND" FUND_ID="<c:out value="${myDataList.FUND_ID}" />" FUND_DATE="<c:out value="${myDataList.FUND_DATE}" />">
		 *          則呼叫之 javascript 如下：
		 *              tips.registerElement({tips:'FUND'});
		 *  @memberOf Tips
		 *  @param opts(Map) :
		 *	           opts.records(Array) :　載入 cache 的資料
		 *	           opts.keys(Array) : 載入資料要作為 cache key 的欄位名稱
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		registerElement: function(ele){
			elements.push(ele);
			getElementCallActive(ele);
		},
		/**
		 *  @public 載入 cache 資料
		 *          範例如下：
		 *              tips.loadDataCache({
		 *                  keys:['FUNC_ID','FUNC_DATE'],
		 *                  records:[
		 *                       {'FUNC_ID':'A1', 'FUNC_DATE':'000000', 'FUNC_NAME':'國泰'},
		 *                       {'FUNC_ID':'A2', 'FUNC_DATE':'000000', 'FUNC_NAME':'人壽'}
		 *                  ]
		 *              });
		 *
		 *  @memberOf Tips
		 *  @param opts (Map) :
		 *	           opts.records(Array) :　載入 cache 的資料
		 *	           opts.keys(Array) : 載入資料要作為 cache key 的欄位名稱
		 *  @author 劉本傑
		 *  @version 1.00
		 **/
		loadDataCache: function(opts){
			loadRecords(opts['records'],opts['keys']);
		}
	};

}