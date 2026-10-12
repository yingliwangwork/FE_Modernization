(function( factory ) {
	if ( typeof define === "function" && define.amd ) {
		define( ["jquery", "../jquery.validate"], factory );
	} else if (typeof module === "object" && module.exports) {
		module.exports = factory( require( "jquery" ) );
	} else {
		factory( jQuery );
	}
}(function( $ ) {

/*
 * Translated default messages for the jQuery validation plugin.
 * Locale: ZH (Chinese; ¤¤¤å (ZhU+014DngwU+00E9n), U+6C49U+8BED, º~»y)
 * Region: TW (Taiwan)
 */
$.extend( $.validator.messages, {
	required: "\u5fc5\u9808\u586b\u5beb",
	remote: "\u8acb\u4fee\u6b63\u6b64\u6b04\u4f4d",
	email: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u96fb\u5b50\u90f5\u4ef6",
	url: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u7db2\u5740",
	date: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u65e5\u671f",
	dateISO: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u65e5\u671f \u0028\u0059\u0059\u0059\u0059\u002d\u004d\u004d\u002d\u0044\u0044\u0029",
	number: "\u8acb\u8f38\u5165\u6b63\u78ba\u7684\u6578\u503c",
	digits: "\u53ea\u53ef\u8f38\u5165\u6578\u5b57",
	creditcard: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u4fe1\u7528\u5361\u865f\u78bc",
	equalTo: "\u8acb\u91cd\u8907\u8f38\u5165\u4e00\u6b21",
	extension: "\u8acb\u8f38\u5165\u6709\u6548\u7684\u5f8c\u7db4",
	maxlength: $.validator.format( "\u6700\u591a {0} \u500b\u5b57" ),
	minlength: $.validator.format( "\u6700\u5c11 {0} \u500b\u5b57" ),
	rangelength: $.validator.format( "\u8acb\u8f38\u5165\u9577\u5ea6\u70ba {0} \u81f3 {1} \u4e4b\u9593\u7684\u5b57\u4e32" ),
	range: $.validator.format( "\u8acb\u8f38\u5165 {0} \u81f3 {1} \u4e4b\u9593\u7684\u6578\u503c" ),
	max: $.validator.format( "\u8acb\u8f38\u5165\u4e0d\u5927\u65bc {0} \u7684\u6578\u503c" ),
	min: $.validator.format( "\u8acb\u8f38\u5165\u4e0d\u5c0f\u65bc {0} \u7684\u6578\u503c" ),
	serverException : "\u4f3a\u670d\u7aef\u57f7\u884c\u7570\u5e38",
	firstText		: '\u56de\u7b2c\u4e00\u9801',
	prevBufferText	: '\u4e0a\u0031\u0030\u9801',
	lastText		: '\u6700\u5f8c\u4e00\u9801',
	nextBufferText  : '\u4e0b\u0031\u0030\u9801'
} );

}));