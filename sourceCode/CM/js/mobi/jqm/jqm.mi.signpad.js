/*
* 簽名按鈕的部件，點擊時會開啟簽名 panel，簽名 panel 作業完成時將圖形回傳。
* 回傳的圖形會重新繪製到這個按鈕上。所傳回的圖形會被保留在 myImage 的屬性中，
* 這麼做的目的是要保留原圖的大小及清晰度，因為圖形重繪到較小的區塊上後，
* 原圖的解析及大小都取不回來了。另說明一下， myImage 是一個 Image 物件，
* 但此 Image 物件的 src 會是一個 dataURL，方便後續用 Ajax 的方式將圖形資料
* 送到後端保留。
*/
(function( $, undefined ) {
	
	window._guessRTP_HOME = function () {
		
		if( window.location.hostname.indexOf( 'mi.cathaylife.com' ) != -1 ) {
			return '/ZMWeb/task';	
		} else {
			return '/ALWeb/task';
		}
		
	};
	
	$.widget('mi.signbutton', {
	
		//預設的 options
		options: {
            PX:         10,
            PY:         10,
            PW:         190,
            PH:         50,
            CONFIT_WIDTH: 794,
            ratio:      1,       //設定檔圖形與目前顯示圖形的比例(currentWidth/configWidth)
            scale:      1,       
            text:       '請簽名',
            disabled:   true,
            IMG_NAME:    '',
            REPORT_ID:  '',
            APPLY_NO:   '',
            SIGN_ROLE:  'CUSTOM',
            BTN_ID:      -1,
            RPT_HOME:   _guessRTP_HOME(),
            SYS_NO:     ''
		},
		
		//初始設定
		_create: function() {
			
			var $btn, self, pos, dim, $parentOffset;
			$btn = $('<div>');
			self = this;
			$parentOffset = this.element.parent().offset();
			
			this.buttonContainer = $btn;
						
			//$btn.text(this.options.text);
			$btn.bind('click', $.proxy(this._click, this));

			$btn.appendTo(this.element);
			
			pos = {
				left: Math.round(self.options.PX * self.options.ratio) - 1,
				top : Math.round(self.options.PY * self.options.ratio) - 1				
			};

			dim = {
				w: Math.round(self.options.PW * self.options.ratio) - 1,
				h: Math.round(self.options.PH * self.options.ratio) - 1
			};

			//位置及方塊大小各減 1 調整後比較接近原設定位置
			this.element.css({
				'position':'absolute',
				'backgroundColor':'yellow',
				'padding': '0',
				width: dim.w,
				height: dim.h,
				top: pos.top,
				left: pos.left
			})
			.bind('click', $.proxy(this._click, this));

			var myCanvas = $("<canvas>").get(0);
			myCanvas.width = this.element.width();
			myCanvas.height = this.element.height();

			var imgCanvas = $('<canvas>').get(0);

			$(myCanvas).appendTo($btn);

			this.myCanvas = myCanvas;
			this.imgCanvas = imgCanvas;
			this.pos = pos; //保留設定的位置，避免當元素未顯示時，沒有 position 的值
			this.dim = dim; //保留設定寬高
			this._setOption('disabled', this.options.disabled);
			this.options.IMG && this._drawSign({dataURL:'data:image/png;base64,' + this.options.IMG, drawed:true, cleared:false});
			delete this.options.IMG;
					
		},
		
		_setOption: function( key, value ) {
			
			if(key === 'disabled'){

				if(value){
					this.element.css({
						'background': '',
						'height':0
					});
				}else{
					this.element.css({
						'background': 'rgba(255,255,0, 0.5)',
						'height': this.dim.h
					});
				}

			}

			if(key === 'IMG'){

				if(value){
					this._drawSign({dataURL: 'data:image/png;base64,' + value, drawed: true, cleared:false});
				}

			}

			//use with jQuery UI 1.8
			$.Widget.prototype._setOption.apply( this, arguments );	
		},
		
		//清除
		destroy: function() {
			//若是使用 jQuery UI 1.8 必需自己再呼叫 base widget 的 destroy 方法
            $.Widget.prototype.destroy.call( this );
		},
		
		//點擊
		_click: function(e) {
		
			$.mi.stopEvent(e);

			if(this.options.disabled) return;

			var thisOffset = this.element.offset();
			var parentOffset = this.element.parent().offset();
			
			var config = {
				x: thisOffset.left,
				y: thisOffset.top,
				w: this.element.width(),
				h: this.element.height(),
				img: this.imgCanvas,
				desc:this.options.BTN_DESC				
			};
		
			this.options.signpanel.data('signpanel').showPage(config);
			//this.options.signpanel.bind('signpaneldone', $.proxy(this._drawSign, this));
			this.options.signpanel.bind('signpaneldone', $.proxy(this._saveSign, this));
			
		},
		
		//畫回簽名
		_drawSign: function(data) {
		
			var drawed  = data.drawed,
				cleared = data.cleared,
				dataURL = data.dataURL,  //only img from server will pass
				self    = this,
				canvas  = self.myCanvas,
				imgCanvas = self.imgCanvas,
				drawedCanvas = data.drawedCanvas; //drawed img from signpanel

			if(!drawed) return; //no drawed happened, do nothing

			//img from server
			if(dataURL){

				var img = new Image();
				img.onload = function() {

					//keep img from server to canvas
					imgCanvas.width = img.width;
					imgCanvas.height = img.height;

					var imgContext = imgCanvas.getContext('2d');
					imgContext.clearRect(0, 0, imgCanvas.width, imgCanvas.height);
					imgContext.drawImage(img, 0, 0, imgCanvas.width, imgCanvas.height);

					//img to present on the button
					var context = canvas.getContext('2d');
					context.clearRect(0, 0, canvas.width, canvas.height);
					context.drawImage(img, 0, 0, canvas.width, canvas.height);
					self._trigger('drawed', null, {drawed:drawed, cleared:cleared});

				};

				img.src = dataURL;

			}else{

				//img from drawed canvas	
				//keep the original img drawed
				imgCanvas.width = drawedCanvas.width;
				imgCanvas.height = drawedCanvas.height;
				var imgContext = imgCanvas.getContext('2d');
				imgContext.clearRect(0, 0, imgCanvas.width, imgCanvas.height);
				imgContext.drawImage(drawedCanvas, 0, 0, imgCanvas.width, imgCanvas.height);

				//img to present on the button
				var context = canvas.getContext('2d');
				context.clearRect(0, 0, canvas.width, canvas.height);
				context.drawImage(drawedCanvas, 0, 0, canvas.width, canvas.height);
				self._trigger('drawed', null, {drawed:drawed, cleared:cleared});
				
			}
			
		},

		//存回簽名圖
		_saveSign: function(event, data) {

			var self = this,
				drawed  = data.drawed,
				cleared = data.cleared,
				drawedCanvas = data.drawedCanvas, //drawed img from signpanel
				dataURL = drawedCanvas.toDataURL('image/png'),
				postData = self.signData();

			postData.cleared = cleared;
			postData.img = dataURL.substring(dataURL.indexOf(',') + 1);

			$.mi.ajax({

				url: this.options.RPT_HOME + '/SaveSign',
				data: postData,
				dataType: 'text',
				timeout: 90000, //timeout 給一分半 
				loadingMsg: '儲存簽名中',
				success: function() {
					//存檔成功後畫回簽名圖
					self._drawSign(data);

					if(self.options.signpanel.data('signpanel').closed){
						return;
					}

					alert('簽名存檔完成');
					//關閉簽名板
					self.options.signpanel.data('signpanel')._closePanel();
				},
				error: function(jqXHR, textStatus, error) {
					alert("簽名存檔失敗，請再試一次");
				}

			});

		},

		//取回簽名結果資料
		signData: function() {

			var opts = this.options;

			var signInfo = {
				x: opts.PX,
				y: opts.PY,
				w: opts.PW,
				h: opts.PH,
				cw:opts.CONFIG_WIDTH,
				REPORT_ID: this.options.REPORT_ID,
				APPLY_NO: this.options.APPLY_NO,
				imgName: this.options.IMG_NAME,
				SIGN_ROLE: this.options.SIGN_ROLE,
				BTN_ID: this.options.BTN_ID,
				SYS_NO: this.options.SYS_NO
			};

			return signInfo;

		}
							
	});
		
})( jQuery );


/**--------------------------------------------------------------------------------------
 * 建立簽名板的 jqm Page 
 */
(function( $, undefined ) {
		
	$.widget('mi.signpanel', {
		
		_create: function() {

			function getAndroidVersion() {

				var ua = navigator.userAgent,
					regx = /Android\s+([\d\.]+)/,
					result = ua.match(regx);

				if(result)	{
					return parseFloat(result[1]);
				}

				return 0;

			}

			this.android_version = getAndroidVersion();
			
			this.signPanel = this._createSignPanel();
			this.canvas = this.signPanel.find('canvas').get(0);
			this.canvasContext = this.canvas.getContext('2d');
			this.canvasContext.lineWidth = '5';
			this.signPanel.bind('pagehide', $.proxy(this._releasePanel, this));
			this.signPanel.bind('pageshow', $.proxy(this._displayPanel, this));

			this.closed = true;
			
		},
		
		/**
		 * 建立塗鴉版頁面，這個動作只有在這個 widget 被建立時被呼叫一次
		 */
		_createSignPanel: function() {

			var $page = $(
				'<div id="signPanel" data-role="dialog" data-dom-cache="true">' +
			    '<div data-role="header" data-theme="mi">' +
			    '<h1>' + this.options.SHOW_TITLE + '</h1>' +
			    
			    '<div data-role="controlgroup" data-type="horizontal" align="center">' +
				'<a id="btnCancel" data-role="button" data-theme="c"><div style="width:65px;">取消</div></a>' +
				'<a id="btnClear" data-role="button" data-theme="c"><div style="width:65px;">清除</div></a>' +
				'<a id="btnSignConfirm" data-role="button" data-theme="c"><div style="width:65px;">儲存</div></a>' +
				'</div>' +
			    '</div>' +
			    '<div data-role="content" style="background-color:#FFFFFF;padding:0; ' +
			    ((this.android_version > 4) ? 'overflow-x:visible;' : '') + '">' +
				'<div id="my_draw_div"><canvas></canvas></div>' +
				'</div>' + 
				'<div data-role="footer" data-theme="mi">' +
				//2013-01-10 將按鈕移至header，以利客戶簽名
				'</div>' +
				'</div>'
			);
			
			//setting the data url for use
			$page.jqmData('url', 'signPanel');   
			
			//inject to pageContainer first
			$page.appendTo($.mobile.pageContainer);
			
			//init the page
			$page.page();
			
			$page.find('#btnCancel').bind('click', $.proxy(this._closePanel, this));
			$page.find('#btnClear').bind('click', $.proxy(this._clearCanvas, this));
			$page.find('#btnSignConfirm').bind('click', $.proxy(this._signConfirm, this));
			
			return $page;
				
		},
		
		/**
		 * 顯示簽名塗鴉頁時，會依據簽名按鈕的寬高比來調整 jqm page 的寬高。
		 * 先以全螢幕的寬度為準來縮放按鈕的寬高比，若是縮放後的高度超過了
		 * 螢幕可顯示的高度，則改以螢幕的高度為準來縮放。因為在簽名塗鴉時，
		 * 必須鎖定住螢幕，不使畫面可以滑動，才有辦法算出筆畫的位置。故我們
		 * 不能讓塗鴉的區塊超出螢幕之外。
		 */		
		_displayPanel: function() {

			var $page = this.signPanel;
			var config = this.config;			
			//調整簽名頁的title
			$('.ui-title',$page).html("<font style='color:#666666;'>" + this.options.SHOW_TITLE + "</font><font style='color:red;'>("+config.desc+")</font>");
			
			//先將 page 寬度調為全螢幕刎寬
			$page.width($(window).width());

			//取得 page header 區塊的 div 來計算該給 canvas 的寬度
			var $headerDiv = $page.children('div').first();
			var dw = $headerDiv.width();
			var ratio = dw/config.w;

			var h = Math.round(ratio * config.h) + 1;

			// canvas 最大的高度應是 view 的高度減掉 header 及 footer 的高度
			var maxH = $('body').height()
						- $page.find(":jqmData(role='header')").height() 
						- $page.find(":jqmData(role='footer')").height();

			//經比例調整後的高度超過最大高度時，改用
			//最大高度來調整 canvas 的寬度			
			if(h > maxH){
				h = maxH - 40;
				ratio = h/config.h;
				dw = Math.round(ratio * config.w) + 1;
				$page.width(dw);
				
				//用 page 的底圖設定，將整個 body 厎圖著為同一款顏色
				$('body').css({
					'background-color': $page.css('background-color'),
					'background-image': $page.css('background-image')
				});
			}

			//設定畫布尺寸
			this.canvas.width = dw;
			this.canvas.height = h;

			//綁定繪圖事件
			this._bindCanvasEvent(config.img);

			var $canvas = $(this.canvas);
			$canvas.data('drawed', false);
			$canvas.data('cleared', false);
				
			this.closed = false;
			
		},

		/**
		 * 綁定繪圖事件
		 */
		_bindCanvasEvent: function(orgImg) {

			var $canvas = $(this.canvas);
			var context = this.canvasContext;

			context.lineWidth = 5;
			if(orgImg){
				context.drawImage(orgImg, 0, 0, this.canvas.width, this.canvas.height);
			}
			
			// create a drawer which tracks touch movements
			var drawer = {
				isDrawing: false,
				isDrawed: false,
				startPoint: {x:0, y:0},
				vmousedown: function(coors){
					context.beginPath();
					context.moveTo(coors.x, coors.y);
					this.isDrawing = true;
					this.startPoint = coors;
				},
				vmousemove: function(coors){

					if (this.isDrawing) {
						context.lineTo(coors.x, coors.y);
						context.stroke();

						if(this.checkDrawed(coors)){
							this.isDrawed = true;
						}

					}
				},
				vmouseup: function(coors){
					if (this.isDrawing) {
						this.vmousemove(coors);

						if(this.isDrawed){
							$canvas.data('drawed', true);
							$canvas.data('cleared', false);
							this.isDrawed = false;
						}

					}
					this.isDrawing = false;
				},
				checkDrawed: function(coors){
					return ((this.startPoint.x - coors.x) != 0) 
							|| ((this.startPoint.y - coors.y) != 0);
				}
			};
			
			var offset = $canvas.offset();
			//alert('offset = {left:' + offset.left + ', top:' + offset.top + '}' );
			
			// create a function to pass touch events and coordinates to drawer
			function draw(e){
				
				$.mi.stopEvent(e);
				
				var orgEvent = e.originalEvent;
						
				if(orgEvent.targetTouches){
					e =  orgEvent.targetTouches [0];
				}
						
				var coors = {
					x: (e.pageX - offset.left),
					y: (e.pageY - offset.top)
				};				
							
				// pass the coordinates to the appropriate handler
				drawer[e.type](coors);
				//alert('coors(x,y) = ' + coors.x + ', ' + coors.y);
			}
			
			$canvas.bind({
				
				'vmousedown': draw,
				'vmousemove': draw,
				'vmouseup'  : draw
				
			});	
			
			// prevent elastic scrolling
			$.mi.lockView();

		},
		
		/**
		 * 塗鴉確認後將圖形以 base64 的 dataURL 回傳
		 */
		_signConfirm: function (e) {
			
			var $canvas = $(this.canvas),
				drawed  = $canvas.data('drawed'),
				cleared = $canvas.data('cleared');

			$.mi.stopEvent(e);

			this._trigger('done', null, {drawed:drawed, cleared:cleared, drawedCanvas:this.canvas});
		
		},
		
		/* 按鈕取消 */
		_closePanel: function(e) {

			if(this.closed){
				return;
			}

			this.closed = true;
			
			//this._trigger('done', null, {});
			this.signPanel.dialog('close');
			
		},

		/* 按鈕清除 */
		_clearCanvas: function(e) {

			var context = this.canvasContext,
				$canvas  = $(this.canvas),
				$container = $canvas.parent();

			context.clearRect(0, 0, this.canvas.width, this.canvas.height);

			//=============================================================
			//Fix for android > 4.1.* canvas clear bug
			if(this.android_version > 4.0){

				var $newCanvas = $('<canvas>');
				$newCanvas.attr('width', this.canvas.width);
				$newCanvas.attr('height', this.canvas.height);

 				$canvas.remove();

				this.canvas = $newCanvas.get(0);
				this.canvasContext = this.canvas.getContext('2d');

				$container.append($newCanvas);
				$canvas = $newCanvas;

				//重新綁定繪圖事件
				if(!this.closed){
					this._bindCanvasEvent();	
				}
				
			}
			//=============================================================

			$canvas.data('drawed', true).data('cleared', true);

		},

		/* panel dialog 關閉後的清除動作 */
		_releasePanel: function() {

			this._clearCanvas();
			$(this.canvas).unbind();
			this.element.unbind('signpaneldone'); //取消所有的簽名完成監聽動作
			$.mi.unlockView();

		},
		
		/* 顯示簽名 panel */
		showPage: function(config) {
			
			var options = {
				transition: 'pop'
			};
			
			this.config = config;
				
			$.mobile.changePage( this.signPanel, options );
			
		},

		//清除
		destroy: function() {
			//若是使用 jQuery UI 1.8 必需自己再呼叫 base widget 的 destroy 方法
            $.Widget.prototype.destroy.call( this );
		}		
		
	});
	
})( jQuery );

/**--------------------------------------------------------------------------------------------------------
 *
 * Report Create And Image/Config Loaded. Only use internally.
 *   1.	依據提供的報表資料，送給 RPTWeb 產生 PDF 報表
 *   2. 載回該報表的圖檔
 */
(function( $, undefined ){

	$.widget("mi.reporter", {

		//預設的 options
        options: {

		},

		_create: function() {

			this.element.bind('reporterimgload', $.proxy(this._loadButtonConfig, this));

		},

		_setOption: function( key, value ) {

			//use with jQuery UI 1.8
			$.Widget.prototype._setOption.apply( this, arguments );	
		},		

		//載入報表圖檔
		_loadImage: function(APPLY_NO, REPORT_ID, imgNames) {

			var self = this;

			$.mi.ajax({
				url: this.options.RPT_HOME + '/ViewImg',
				data: {APPLY_NO:APPLY_NO, REPORT_ID:REPORT_ID},
				timeout: 60000,
				dataType: 'text',
				loadingMsg :'圖檔載入中',
				success: function(imgs){
					
					imgs = imgs.split(',');
					var loadCnt = imgs.length;
					var loadedImgs = [];

					$.each(imgs, function(index, imgStr){
						
						var img = new Image();
						loadedImgs[index] = img;

						img.src = 'data:image/png;base64,' + imgStr;
						img.onload = function(){
							loadCnt--;

							if(loadCnt == 0){
								var bodyWidth = $('body').width(),
                                	scale     = bodyWidth / img.width;
								
								self._trigger('imgload', null, {
									imgs:loadedImgs, 
									imgNames:imgNames, 
									bodyWidth:bodyWidth, 
									scale:scale,
									APPLY_NO: APPLY_NO,
									REPORT_ID: REPORT_ID
								});	
							}
						}
											
					});

				},
				error: function(jqXHR, textStatus, error){
					if(error == 'timeout'){
						$.mi.error('載入圖檔失敗,系統忙碌請稍後再試');	
					}else{
						$.mi.error('載入圖檔失敗');	
					}							
				}
			});			

		},

		_loadButtonConfig: function (event, data) {

			var self = this;

			
			$.mi.ajax({
				url: this.options.RPT_HOME + '/LoadSignData',
				data: {APPLY_NO:data.APPLY_NO, REPORT_ID:data.REPORT_ID , SHOW_BTN:this.options.SHOW_BTN},
				timeout: 60000,
				dataType: 'text',
				loadingMsg :'簽名載入中',
				success: function(resp){

					resp = $.parseJSON(resp);
					
					self._trigger('configload', null, {
						buttonConfig:resp.configData, 
						bodyWidth:data.bodyWidth, 
						scale:data.scale
					});

				}				

			});

		},		

		//清除
		destroy: function() {
			//若是使用 jQuery UI 1.8 必需自己再呼叫 base widget 的 destroy 方法
            $.Widget.prototype.destroy.call( this );
		},		

		createReport: function () {

			var RPT_DATA = this.options.RPT_DATA;
			var self = this;
			RPT_DATA.RPT_PARAM['REPORT_ID'] = RPT_DATA.REPORT_ID;
			var rpt2JpgUrl = this.options.IS_PLAT == 'Y' ? "/PDFRpt2Jpg" : '/Rpt2Jpg';
			
			
			$.mi.ajax({
				url: this.options.RPT_HOME + rpt2JpgUrl,
				timeout: 60000,
				data : {
                    'APPLY_NO':         RPT_DATA.APPLY_NO,
                    'REPORT_ID':        RPT_DATA.REPORT_ID,
                    'RPT_URL':          this.options.RPT_URL,
                    'SYS_NO':           this.options.SYS_NO,  
                    'RPT_PARAM':        JSON.stringify(RPT_DATA.RPT_PARAM),
                    'RPT_DETAIL':       JSON.stringify(RPT_DATA.RPT_DETAIL),
                    'regen' : 			this.options.regen,
                    'PDF_READY':        this.options.PDF_READY
				},
				dataType: 'text',
				loadingMsg : '影像處理中，約須 1 分鐘請耐心等候！',
				success: function( imgList ){
							
					//取得回傳的圖檔清單，為一個 js 陣列
					var imgNames = imgList.split(',');
					self._loadImage(RPT_DATA.APPLY_NO, RPT_DATA.REPORT_ID, imgNames);
					
				},
				error: function(jqXHR, textStatus, error){
					if(error == 'timeout'){
						$.mi.error('產生報表失敗,系統忙碌請稍後再試');	
					}else{
						$.mi.error('產生報表失敗');	
					}
				}
					
			});


		}

	});

})( jQuery );

/**--------------------------------------------------------------------------------------------------------
 *
 * Total controller with signbutton, signpanel and reporter
 */
(function( $, undefined ){

	$.widget("mi.signpad", {

		//預設的 options
        options: {
            RPT_HOME:   _guessRTP_HOME(),
            RPT_DATA:   {RPT_PARAM:{}, RPT_DETAIL:[], REPORT_ID:'', APPLY_NO:''},
            RPT_URL:    'RJT2JPG',
            SIGN_BTN:   '#btn_sign',
            regen:      false,
			SHOW_BTN:   '',
			SYS_NO:     '',
			PDF_READY:  false,
			SHOW_TITLE: '請在此簽名',
			IS_PLAT:    '',
			SHOW_ALL:  ''//新平台預設by頁數顯示簽名，若要全簽，要給Y
		},

		_create: function() {

			//取出 REPORT_ID 及 APPLY_NO
			this.REPORT_ID = this.options.RPT_DATA.REPORT_ID;
			this.APPLY_NO  = this.options.RPT_DATA.APPLY_NO;

			//依報表 ID 給系統代號
			this.options.SYS_NO = this.REPORT_ID.substring(0, 2);

			//建立 mi.reporter 部件
			var $tool = $('<div>').reporter(this.options);
			this.reporter = $tool;

			//當圖形載入後，交由 _showImage 處理
			$tool.bind('reporterimgload', $.proxy(this._showImage, this));
			$tool.bind('reporterconfigload', $.proxy(this._buildSignButton, this));

			//產生報表
			$tool.reporter('createReport');

			var myParent = this.element.parent();
			myParent.css('overflow', 'hidden');
			if(myParent.css('position') !== 'relative'){
				myParent.css('position', 'relative');
			}

			this.$signpanel = $('<div>').signpanel({SHOW_TITLE: this.options.SHOW_TITLE});
			this.$def = $.Deferred();

		},

		_init: function() {
  			
		},

		//報表重製
		regen: function() {

			var self = this,
				$tool = self.reporter;

			//清除所有已建立的 widget 的 component	
			if(self.slider){
				self.slider.destroy();
				self.slider = null;				
			}

			if(self.buttonSlider){
				self.buttonSlider.destroy();
				self.buttonSlider = null;				
			}

			self.$container && self.$container.remove();	

			self.$buttonContainer && self.$buttonContainer.remove();	
			
			$(':mi-signbutton').remove();

			$(self.options.SIGN_BTN).unbind('click').removeClass('ui-btn-active');
			self.$pageSwitchBar && self.$pageSwitchBar.remove();
			self.$def = $.Deferred();

			

			//重新產生報表
			$tool.reporter('option', 'regen', 'true');
			$tool.reporter('createReport');

		},

		//判斷簽名是否都已完成
		isSigned: function() {
			//TODO:簽名鈕完成的統計方式
			var signButtonsNum = $(':mi-signbutton').size(),
				signCount      = this.$buttonContainer.find('span.ui-icon-check').size();

			

			return (signButtonsNum == signCount);
		},

		//清除
		destroy: function() {

			if(this.slider){
				this.slider.destroy();
				this.slider = null;
			}

			//若是使用 jQuery UI 1.8 必需自己再呼叫 base widget 的 destroy 方法
            $.Widget.prototype.destroy.call( this );
		},		

		_showImage: function(event, data) {

			if(!this.$def){
				this.$def = $.Deferred();
			}

			var imgs       = data.imgs,
            	imgNames   = data.imgNames,
            	bodyWidth  = data.bodyWidth,
            	scale      = data.scale,
            	pagesX     = [],
            	$container = $('<div>'),
            	$ul        = $('<ul>').appendTo($container),
            	sh         = $('body').height()
            				 - $.mobile.activePage.children('[data-role="header"]').outerHeight()
            				 - $.mobile.activePage.children('[data-role="footer"]').outerHeight();

            //調整 canvas 外部 div 的高度及記下 scale
            this.scale = scale;
            this.element.parent().height(sh);
     
            //調整圖形的大小
			$.each(imgs, function(index, img){
				
				img.width = img.width * scale;
				img.height = img.height * scale;

				var div = $('<div>');
				div.css({
					padding: 0,
					margin:  0,
					position: 'relative'
				});
				div.append(img);

				$('<li>').append(div).appendTo($ul).attr('IMG_NAME', imgNames[index]);
				
			});

			$container.css({
				'position':'absolute',
				'padding':'0', 
				'margin':'0', 
				'top':'0', 
				'left':'0'
			}).width(bodyWidth)
			.height(sh);
			
			$ul.css({'list-style':'none','margin':'0','padding':'0'})
				.width(bodyWidth * imgs.length)
				.height(imgs[0].height);

			$('li', $ul).css({'display':'inline','float':'left','padding':'0', 'margin':'0'});

			$container.prependTo(this.element.parent());

			this.slider = new iScroll($container.get(0), {
				zoom:           false,
				momentum:       false,
				fixedScrollbar: true
			});

			//建立各頁的 x 邊界起始座標值
			var pageW = this.slider.wrapperW;
			var i = 0;
			while(i < imgs.length){
				pagesX[i] = i * pageW;
				i++;
			}

			this.pagesX = pagesX;
			this.$container = $container;
			this.$def.resolve();

			//============SHOW_PAGE start==2013-01-08  若有設定SHOW_PAGE,則要移至指定頁面===========
			if(this.options.SHOW_PAGE && parseInt(this.options.SHOW_PAGE,10)>0){
				var dx = -this.slider.wrapperW * parseInt(this.options.SHOW_PAGE,10);
				if (dx < this.slider.maxScrollX){
					dx = this.slider.maxScrollX;
				}
				this.slider.scrollTo(dx, this.slider.y, 400);	
			}
			//==============SHOW_PAGE END========================================================
		},

		/**
		 * 產生各畫面的簽名按鈕
		 */
		_buildSignButton: function(event, data) {

			var buttonConfig = data.buttonConfig,
				scale        = data.scale,
				self         = this;

			if(self.$def){

				self.$def.promise().done(function(){

					var $li = self.$container.find('li');

					$.each(buttonConfig, function( index, btnConfig ) {

						var buttonSet = btnConfig.infos,
							ratio     = data.bodyWidth / btnConfig.CONFIG_WIDTH,
							$target	  = self.$container.find('li[IMG_NAME="' + btnConfig.IMG_NAME + '"]');


						if($target.size() > 0){

							$target = $target.children('div');

							$.each(buttonSet, function( index, option){

								var $btn     = $('<div>').appendTo($target);
								option.ratio = ratio;
								option.scale = scale;
								option.signpanel = self.$signpanel;
								option.IMG_NAME =  btnConfig.IMG_NAME;
								option.REPORT_ID = self.REPORT_ID;
								option.APPLY_NO  = self.APPLY_NO;
								option.CONFIG_WIDTH = btnConfig.CONFIG_WIDTH;
								option.SYS_NO = self.options.SYS_NO;
								option.PAGE_NUM = btnConfig.PAGE_NUM;

								$btn.signbutton(option);
								$btn.attr('id', 'sign_btn_' + option.IMG_NAME + '_' + option.BTN_ID);
								//$btn.signbutton('enable');
										
							});

						}
											
					});

					//create new Deferred for next time usage
					self.$def = $.Deferred();

					self._buildControlButton();

				});

			}
	
		},

		/**
		 * 產生簽名按鈕列，供使用者指定要簽哪個地方，
		 * 點擊後會自動帶位至該簽名按鈕處，並顯示該簽名鈕。
		 */
		_buildControlButton: function() {

			//取得所有簽名按鈕
			var $signButtons = $(':mi-signbutton');
			var self = this;

			//有一個以上的按鈕，產生一個 list 清單來用
			if($signButtons.size() > 1){

				var $buttonContainer = $('<div>');
				var maxHeight = $('body').height() / 2;

				maxHeight = self._getListViewHeight($signButtons.size());
				
				$buttonContainer.css({
					width:  $('body').width() / 5,
					height: maxHeight,
					border: '1px solid',
					overflow: 'hidden',
					position: 'absolute',
					backgroundColor: '#ddd',
					padding:   10,
					paddingRight: 20,
					margin:    0,
					right:     10,
					bottom:    10,
					boxShadow: '-5px 5px 5px #888'
				}).attr('id', '_sign_control_panel');

				var $ul = $('<ul data-role="listview"></ul>');
				var showSize = 0;
				var isPlat = self.options.IS_PLAT;
				var showAll = self.options.SHOW_ALL;

				$.each($signButtons, function(index, elem){

					var $elem = $(elem);

					var $ctlLink = $('<li><a href="#">' + $elem.signbutton('option', 'BTN_DESC') + '</a></li>');
					$ctlLink.appendTo($ul);
					$ctlLink.bind('click', function() {

						$(':mi-signbutton').signbutton('disable');

						self.slider.scrollToElement(elem, 100);
						$elem.signbutton('enable').triggerHandler('click');

					});
					var pageNum = $elem.signbutton('option','PAGE_NUM');
					if(isPlat == 'Y' && showAll != 'Y'){
						var startPage = self.options.SHOW_PAGE && parseInt(self.options.SHOW_PAGE,10)>0 ? parseInt(self.options.SHOW_PAGE,10) : 1;
						if(pageNum == startPage){
							$ctlLink.css('display','' );
							showSize++;
						}else{
							$ctlLink.css('display','none');
						}
						$elem.signbutton('option','ctlLink',$ctlLink);
					}
					$elem.bind('signbuttondrawed', function(event, data){

						var $icon = $ctlLink.find('span.ui-icon')

						if(data.cleared){
							$ctlLink.removeClass('ui-btn-active');
							$icon.removeClass('ui-icon-check')
								 .addClass('ui-icon-arrow-r');
						}else{
							$ctlLink.addClass('ui-btn-active');
							$icon.removeClass('ui-icon-arrow-r')
								 .addClass('ui-icon-check');								 
						}

					});
					
				});

				if( isPlat == 'Y'  && showAll != 'Y'){
					$buttonContainer.css('height',self._getListViewHeight(showSize) );
				}
				$ul.appendTo($buttonContainer);
				self.element.parent().append($buttonContainer);

				$ul.listview();

				self.$buttonContainer = $buttonContainer;
				self.buttonSlider = new iScroll($buttonContainer.get(0), {hScroll:false});

				$buttonContainer.hide();

				$(self.options.SIGN_BTN).bind('click', function(){
					$(this).toggleClass('ui-btn-active');
					$buttonContainer.toggle();
				});				

			} else {

				//只有一個簽名按鈕的話，直接顯示該簽名按鈕
				$(self.options.SIGN_BTN).bind('click', function(){

					$(this).toggleClass('ui-btn-active');
					self.slider.scrollToElement($signButtons.get(0), 100);
					$signButtons.signbutton('enable').triggerHandler('click');

				});

			}

			//一頁以上，建立換頁按鈕 
			if(self.pagesX.length > 1){

				var $pageSwitchBar = $(
					'<div>' +
					'<a style="float:left;margin-left:0.5em;text-decoration:none;color:#FFF;" id="btn_prev_page" href="#">&lt;</a>' +
					'<span id="_page_hint" style="padding-left:0.2em;padding-right:0.2em;"></span>' + 
					'<a style="float:right;margin-right:0.5em;text-decoration:none;color:#FFF;" id="btn_next_page" href="#">&gt;</a></div>'
				);

				$pageSwitchBar.css({
					width:  $('body').width() / 5,
					border: '1px solid black',
					overflow: 'hidden',
					position: 'absolute',
					backgroundColor: '#000',
					padding:   '0',
					margin:    0,
					right:     ($('body').width() / 5) * 2,
					bottom:    8,
					opacity:   0.4,
					color:     '#FFFFFF',
					fontWeight:'bold',
					fontSize:  '2em',
					boxShadow: '-5px 5px 5px #888',
					textAlign: 'center'
				})
				.attr('id', '_page_switch_bar')
				.hover(
					function() {$(this).css('opacity', '0.7');},
					function() {$(this).css('opacity', '0.4');}
				);

				self.element.parent().append($pageSwitchBar);
				self.$pageSwitchBar = $pageSwitchBar;

				var pageHint = function() {
					$('#_page_hint').html( (self._currentPage() + 1) + '&nbsp;/&nbsp;' + self.pagesX.length );
				};

				self.slider.options.onScrollEnd = pageHint;
				pageHint();

				//上下頁切換
				$('#btn_prev_page').bind('click', function(){

					var slider = self.slider,
					    page   = self._currentPage(),
						prePage = page - 1,
					    dx     = (page == 0) ? 0 : -slider.wrapperW * (prePage);

					if (dx < slider.maxScrollX) dx = slider.maxScrollX;

					slider.scrollTo(dx, slider.y, 400);
					//有一個以上的按鈕，產生一個 list 清單來用
					//新流程才用
					if(self.options.IS_PLAT == 'Y' && self.options.SHOW_ALL != 'Y' && $signButtons.size() > 1 && prePage>=0){
						var showSize = 0;

						$.each($signButtons, function(index, elem){
	
							var $elem = $(elem);
							var option = $elem.signbutton('option');
							var $ctlLink = $(option.ctlLink);
							if(option.PAGE_NUM == (prePage + 1)){
								$ctlLink.css('display','' );
								showSize++;
							}else{
								$ctlLink.css('display','none');
							}
							$('#_sign_control_panel').css('height',self._getListViewHeight(showSize) );
						});
					}

				});

				$('#btn_next_page').bind('click', function() {

					var slider = self.slider,
					    page   = self._currentPage(),
						maxPage = self.pagesX.length,
						nextPage = page + 1,
					    dx     = -slider.wrapperW * nextPage;

					 if (dx < slider.maxScrollX) dx = slider.maxScrollX;

					 //console.log('page=' + page, 'dx=' + dx);

					 slider.scrollTo(dx, slider.y, 400);
					 var $signButtons = $(':mi-signbutton');
					 //有一個以上的按鈕，產生一個 list 清單來用
					 //新流程才用
					 if(self.options.IS_PLAT == 'Y' && self.options.SHOW_ALL != 'Y' && $signButtons.size() > 1 && nextPage < maxPage){
					 	var showSize = 0;
						$.each($signButtons, function(index, elem){

							var $elem = $(elem);
							var option = $elem.signbutton('option');
							var $ctlLink = $(option.ctlLink);
							if(option.PAGE_NUM == (nextPage + 1)){
								$ctlLink.css('display','' );
								showSize++;
							}else{
								$ctlLink.css('display','none');
							}
						});
						$('#_sign_control_panel').css('height',self._getListViewHeight(showSize) );
					 }


				});	

			}//END 換頁按鈕建立

		},

		/**
		 * 用 iscroll 的屬性計算出目前的所在頁數。 0 為第一頁。
		 * 計算方式參考 iscroll 的 _snap(), scrollToPage() 的程式內容。
		 */
		_currentPage: function() {

			var self   = this,
				slider = self.slider,         //iscroll 物件 
				pageX  = Math.abs(slider.x),  //目前的 x 軸位置
				pagesX = self.pagesX,         //各頁的 x 起點
				page   = 0;                    

			//console.log('pagesX=', pagesX, 'pageX=' + pageX)	

			for(var i = pagesX.length - 1; i > 0; i--){

				if(pageX >= pagesX[i]){
					page = i;
					break;
				}

			}

			return page;

		},
		/**
		 * 計算簽名選單長度。
		 */
		_getListViewHeight: function(listSize){
			var maxHeight = $('body').height() / 2;
			var testHeight = listSize * 42;
			return testHeight  > maxHeight ? maxHeight : testHeight;
		}

	});

})( jQuery );