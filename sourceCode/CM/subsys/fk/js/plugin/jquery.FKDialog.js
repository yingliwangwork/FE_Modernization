$.widget('ui.fkdialog', {
	/**
	 * url         - 要開啟的URL
	 * params      - 傳給URL的參數
	 * dialogClass - 對話區塊css
	 * newWindow:  - 是否開啟新視窗
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
			else if($.type(self.options.dialogClass) === 'string') {
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
		
		$form.submit();
		
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
			
			self.overlay = new $.ui.dialog.overlay();
			
			//解除jQuery ui的dialog keydown事件(不然會出錯)
			$(document).unbind('keydown.dialog-overlay');
			
			var max = function(){
				var max = 0;
				
				$(document).find('*').each(function(index, element) {
					var zIndex = $.isNumeric($(this).css('z-index')) ? parseInt($(this).css('z-index')) : 0;
					
					max = Math.max(max, zIndex);
				});
				
				return max;
			}();
			
			self.overlay.$el.css('z-index', max+1);
			
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
			self.overlay.destroy();
			delete self.overlay; 
		}
	}
});