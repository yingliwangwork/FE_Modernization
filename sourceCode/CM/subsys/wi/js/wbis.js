/*! @version 20140711
 */


// 限制在<div class="wbis=main">內，
// 避免對外衝突

$scope = $('.wbis-main > *:not(.infobox)');




// 自訂表單元件 <input type="radio">, <input type="checkbox">
// @requires iCheck
// ------------------------------------------

$.fn.input_iCheck  = function(){
	return this.each(function(){
		$(this).iCheck({
			checkboxClass: 'icheckbox'
		});
	});
};
$.fn.input_iRadio  = function(){
	return this.each(function(){
		$(this).iCheck({
			checkboxClass: 'iradio'
		});
	});
};




// 自訂表單元件 <select>
// ------------------------------------------

$.fn.input_iSelect = function(){
	return this.each(function() {
		
		var o = $(this),
			w = parseInt(o.css('width')) || 100,
			iselect, toggle;
	
		//console.log( o, ' w =>', w );
		
		o.wrap('<span class="iselect" />');
		iselect = o.parent();
		
		iselect.css('width', w );
		o.css('width', w + 20);
		
		toggle = $('<i />').appendTo(iselect);
		
		// avoid text overlaps <i>
		iselect.on('mouseenter', function(){
			toggle.css('z-index', 1);
		}).on('mouseleave', function(){
			toggle.css('z-index', '');
		});
	});
}



$.fn.initCustomInputs = function(){
	return this.each(function(){
		$(':checkbox', this).input_iCheck();
		$(':radio', this).input_iRadio();
		$('select', this).input_iSelect();
	});
}


$(function(){
	
	$('body').on('focus', '.iselect select', function(){
		$(this).parent().addClass('focus');
	});
	$('body').on('blur', '.iselect select', function(){
		$(this).parent().removeClass('focus');
	});
	
	$scope.initCustomInputs();
});





// 表單元件功能
// ------------------------------------------



/* 錯誤欄位標上qTip2
 * 
 * @requires qTip2
 * 相關api @see http://qtip2.com/api#global
 */
$.fn.input_errortip = function() {
	return this.each(function() {
		
		var o = $(this),
			tip = o.next('.errortip');
		if(!tip[0] )
			return;
		
		var position = { //@see http://qtip2.com/options#position
			my: tip.attr('data-my') || 'left center',
			at: tip.attr('data-at') || 'center right'
		};
		
		//console.log( 'input_errortip', this);
		
		o.qtip({
			content: {
				text: tip,
				title: false
			},
			show: {
				event: false,
				ready: false,
				effect: false // avoid animation trainning that causes bug
			},
			hide: {
				event: false,
				effect: false,
				fixed: true, leave: false // for link inside  @see http://qtip2.com/options#hide.leave
			},
			position: position,
			style: {
				classes: 'qtip-rounded qtip-shadow errorqtip'
			}
		});
	});
}



/* 設定表單元件為錯誤狀態
 * ex: <input class="error">
 * @argument {Boolean} bool true => 設定失效(default) | false => 設定可編輯
 */
$.fn.input_error = function( bool, msg ) {
	
	return this.each(function() {
		var el = $(this), // native input element
			o = $(this).input_who(),
			_bool = bool != undefined ? bool : true;
		
		el.toggleClass('error', _bool);
		o.toggleClass('error', _bool);
		
		
		if( _bool ) {
			if( !o.is(':visible') )
				return;
			
			
			if( !o.attr('data-hastip') )
				o.input_errortip();
			
			o.qtip('show');
			
			// User互動時立刻隱藏qTip2
			
			// use iCheck event instead of jQuery event on radiobutton and checkbox
			var evt = el.is(':checkbox, :radio') && el.parent('.iradio')[0] ?
					'ifChanged.input_error' : 'change.input_error';
					
			el.off( evt ).on( evt, function(){
				o.qtip('hide');
			});
			
			
			
			//console.log( 'input_error el=>', el );
			
			if( msg != '' && typeof msg == 'string' )
				o.qtip('option', 'content.text', msg);
		}
		else {
			o.qtip('hide');
		}
	});
}



/* 設定表單元件為失效
 * ex: <input disabed="disabed">
 * @argument {Boolean} bool true => 設定失效(default) | false => 設定可編輯
 */
$.fn.input_disabled = function( bool ) {
	
	return this.each(function(){
		var o = $(this).input_who(),
			_bool = bool != undefined ? bool : false;
		
		o.toggleClass( 'disabled', _bool );
		
		// Native element "disabled" attribute
		if( _bool )
			$(this).attr('disabled', 'disabled');
		else
			$(this).removeAttr('disabled');
	});
}



/* 設定表單元件為必填，
 * 供程式驗證判斷
 * ex: <input required="required">
 * @argument {Boolean} bool true => 設定必填(default) | false => 設定非必填
 */
$.fn.input_required = function( bool ) {
	
	return this.each(function(){
		var o = $(this).input_who(),
			_bool = bool != undefined ? bool : true;
		
		o.toggleClass( 'required', _bool );
		
		// Native element "required" attribute
		if( _bool )
			$(this).attr('required', 'required');
		else
			$(this).removeAttr('required');
	});
}



/* 因<select>, <input radio>, <input checkbox>三者自訂樣式，生成外層自訂HTML結構
 * 需透過表單元件指向正確外層結構
 */
$.fn.input_who = function(){
	
	var el = $(this), // native input element
		o;
	
	// <input typ="checkbox">, <input typ="radio">
	if( el.is(':checkbox,:radio'))
		o = el.parents('label');
	
	// <select>
	else if( el.is('select') )
		o = el.parents('.iselect');
	
	// Other input like: <input type="text">, <input type="email">
	else
		o = el;
		
	return o;
}



/* 找到所有已綁上error class的表單元件，
 * 並將樣上設為error狀態、qTip2提示框
 */
function showAllErrorInputs() {
	
	$('input.error, select.error, textarea.error, label.error', $scope).input_error( true );
}



/* 找到所有已綁上class="error"的表單元件
*/
function getAllErrorInputs() {
	
	return $('input.error, select.error, textarea.error, label.error', $scope);
}



/* 顯示上方公用錯誤訊息列 (errorbar)
 * @argument {String} msg 顯示文字，預設空值
 */
function showErrorBar( msg ){
	
	if( msg != '' && typeof msg == 'string' ) 
		$('#errorbar').html( '<i class="icon-alert"></i> ' + msg );

	$('#errorbar').show();
	
	// 強制更新qTip2的位置
	$('[data-hasqtip]').qtip('reposition', null, false);
	setTimeout(function(){
		$('[data-hasqtip]').qtip('reposition', null, false);
	}, 240);
	
}


/* 設為required的必填欄位 基本輸入值驗證
 */
function commonValidate() {
	
	$( '[required]', $scope ).each(function(){
		var o = $(this),
			value = $.trim( o.val() );
		
		// Check empty value for all text input element except radiobutton and checkbox
		if( o.is( 'input, textarea' ) && !o.is( ':checkbox, :radio' ) )
			o.input_error( value == '' );
			
		// Radiobutton, checkbox
		if( o.is(':checkbox, :radio') ) 
			o.input_error( !o.is(':checked') );
		
		// Select
		if( o.is( 'select' ) ) 
			o.input_error( this.selectedIndex == 0 || /請選擇/.test( value ) );
		
		
		// Email
		if( o.is( '[type="email"]' ) )
			o.input_error( !checkEmail( value ), 'Email格式錯誤');
		
		
		// Custom validations <input data-validate=XXXXX>
		// ------------------------------------------------------
		// 8-12位英文字母與數字
		if( o.is( '[data-validate="password"]' ) ) 
			o.input_error( value.length > 12 || value.length < 8 || /[^a-zA-Z\d]/.test( value ), '密碼不符規定'  );
		
		// 身份證	
		if( o.is('[data-validate="identityid"]' ) )
			o.input_error( !checkIdentityID( value ), '身分證字號有誤' );
	
		// 手機
		if( o.is('[data-validate="mobile"]' ) )
			o.input_error( !checkMobile( value ), '請檢查手機格式' );
		
		console.log( value, value.length, o );
	});
}





// 輸入格式檢查
// ------------------------------------------
function checkCreditCard( value ) {
	return /^\d{4}-\d{4}-\d{4}-\d{4}$/.test( value );
}
function checkMobile( value) {
	return /^[09]{2}[0-9]{8}$/.test( value );
}
function checkEmail( value ) {
	return /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/.test( value );
}
function checkIdentityID( value ) {
	var tab = "ABCDEFGHJKLMNPQRSTUVXYWZIO";                  
	var A1 = new Array (1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3 );
	var A2 = new Array (0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5 );
	var Mx = new Array (9,8,7,6,5,4,3,2,1,1);
	var sum, i, v;
	
	if ( value.length != 10 )
		return false;
	i = tab.indexOf( value.charAt(0).toUpperCase() );
	if ( i == -1 )
		return false;
	sum = A1[i] + A2[i]*9;
	
	for ( i=1; i<10; i++ ) {
		v = parseInt( value.charAt(i) );
		if ( isNaN(v) )
			return false;
		sum = sum + v * Mx[i];
	}
	if ( sum % 10 != 0 )
		return false;
	
	return true;
}









// 一般Tooltip
//
// @requires qTip2
// 相關api @see http://qtip2.com/api#global
// ------------------------------------------
$(function(){
	$('[data-tooltip]').each(function() {
		
		var position = { //@see http://qtip2.com/options#position
			my: $(this).attr('data-my') || 'right center',
			at: $(this).attr('data-at') || 'center left'
		}
		
		$(this).qtip({ 
			content: {
				attr: 'data-tooltip'
			},
			show: {
				event: 'click mouseenter',
				delay: 75
			},
			hide: {
				event: 'unfocus mouseleave',
				fixed: true,
				leave: false // for link inside  @see http://qtip2.com/options#hide.leave
			},
			position: position,
			style: {
				classes: 'qtip-rounded qtip-shadow toolqtip'
			}
		});
	});
});






// Fancybox
//
// 相關api @see http://fancyapps.com/fancybox/#docs
// ------------------------------------------

$(function() {
	/*
	if( $.fancybox ) {
		$.fancybox.defaults.parent = $(".wbis-main",parent.document);
		$.fancybox.defaults.wrapCSS = 'infobox-fancybox';
		$.fancybox.defaults.type = 'inline';
		$.fancybox.defaults.padding = 0;
		$.fancybox.defaults.margin = 0;
		$.fancybox.defaults.closeClick = false;
		$.fancybox.defaults.autoSize = true;
		$.fancybox.defaults.width = 'auto';
		$.fancybox.defaults.height = 'auto';
		$.fancybox.defaults.helpers = { 
			title: null,
			overlay: {
				closeClick : false,  // if true, fancyBox will be closed when user clicks on the overlay
				locked : false // if true, the content will be locked into overlay,  @see http://jsfiddle.net/XaWZE/
			}
		}
		// Green close button 
		$.fancybox.defaults.afterShow = function(){
			//console.log( $(this.element) );
			if( !$('.infobox-header', this.wrap)[0] )
				$('.fancybox-close', this.wrap).addClass('fancybox-close2');
		}
	}*/
	$('a[data-infobox]').fancybox();
	
});