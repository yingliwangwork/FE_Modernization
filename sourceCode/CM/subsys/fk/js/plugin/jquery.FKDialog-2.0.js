/**
 * [20240223][LISYSFK-4171] 陳慶州
 * 1.jQuery升級3.6.0 程式語法調整
 **/
$.widget('ui.fkdialog', {
	/**
	 * url         - 要開啟的URL
	 * params      - 傳給URL的參數
	 * dialogClass - 對話區塊css
	 * newWindow:  - 是否開啟新視窗
	 * jquery migration
	 */
	options: {
		url: 		 '',
		params: 	 {},
		dialogClass: 'section',
		newWindow: false
	},

	_create: function() {
		var self = this,
			element = self.element;

		if(!self.options.newWindow) {
			var $target = $('.section.hasHmenu');

			$target.siblings(':ui-fkdialog').each(function(index, domElement) {
				if(element[0].id == domElement.id) {
					$(domElement).remove();
				}
			});
			
			element.draggable({
				cursor: 'move',
				handle: '#FKDialog_dargArea'
			});
			
			element.hide();
			
			if($.isPlainObject(self.options.dialogClass)) {
				var i;
				
				for(i in self.options.dialogClass) {
					element.css(i, self.options.dialogClass[i]);
				}
			}
			else if(typeof(self.options.dialogClass) === 'string') {
				element.addClass(self.options.dialogClass);
			}
			
			element.detach().insertAfter($target);
		}
	},
	
	openNewWindow: function() {
		var self 	= this,
			element = self.element;
			
		if(!self.options.newWindow) {
			throw 'Not supported. The parameter, named newWindow, you set is FALSE';
		}
		
		var $form = $('<form method="post" action="'+self.options.url+'" target="_blank"></form>'),
			i;
		
		for(i in self.options.params) {
			$form.append('<input type="hidden" name="'+i+'" value="'+self.options.params[i]+'" />');
		}
		
		element.append($form);
		
		$form.trigger('submit');
		
		setTimeout(function() {
			$('body').uncover();
		}, 1000);
	},

	open: function() {
		var self 	= this,
			element = self.element;
			
		if(self.options.newWindow) {
			throw 'Not supported. The parameter, named newWindow, you set is TRUE';
		}
		
		element.load(self.options.url, self.options.params, function(responseText, textStatus, jqXHR) {
			if(element.data('errorMessage')) {
				element.removeData('errorMessage');
				
				return false;
			}
			var browserWidth = document.documentElement.clientWidth;
			var browserHeight = document.documentElement.clientHeight;
			//[20240227]jQuery升級調整self.overlay = new $.ui.dialog.overlay()寫法 改為直接創建
			self.overlay = $('body').append($('<div>', {"style": "width: "+browserWidth+"px; height: " + browserHeight + "px;", "class": "fkheir-ui-widget-overlay"}));
			//解除jQuery ui的dialog keydown事件(不然會出錯)
			$(document).off('keydown.dialog-overlay');
			
			var max = function(){
				var max = 0;
				
				$(document).find('*').each(function(index, element) {
					//!isNaN改為FKHeir.isNumeric
					var zIndex = FKHeir.isNumeric($(this).css('z-index')) ? parseInt($(this).css('z-index')) : 0;
					max = Math.max(max, zIndex);
				});
				
				return max;
			}();
			
			//[20240227]jQuery升級調整 Jquself.overlay.$el.css('z-index', max+1) 
			self.overlay.css('z-index', max+1);
			var topPosition = (($(window).height() - element.outerHeight()) / 2) + $(window).scrollTop();
			element.wrapInner('<div class="dialog shadowBox txtAc">').css({
		        "position": "absolute",
		        "top": ((topPosition >= 0 ? topPosition : 0) + "px"),
		        "left": ((($(window).width() - element.outerWidth()) / 2) + $(window).scrollLeft() + "px"),
		        "z-index": max+2
		    }).show();
			
			$('.dialog', this).prepend('<div class="section2">'+
				'<div id="FKDialog_dargArea" style="cursor:move" class="txtAr">'+
				'<img id="FKDialog_closeIcon" src="../../../html/CM/subsys/fk/images/icons/icon24.png">'+
				'</div></div>');

			$('#FKDialog_closeIcon').css({cursor: 'pointer'}).on('click', function(event) {
				self.close();
			});
		});
	},

	close: function() {
		var self 	= this,
			element = self.element;

		element.empty();
		element.hide();

		if(self.overlay) {
			//[20240227]jQuery升級調整 self.overlay.destroy()
			$('.fkheir-ui-widget-overlay').remove();
			delete self.overlay; 
		}
	}
	
});