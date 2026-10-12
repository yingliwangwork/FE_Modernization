//**********************************************************************************
// 提供交易頁面建立 validate list 的物件。
//**********************************************************************************

if(!window.mi){
	window.mi = {};
}

window.mi.Validator =
function(){
	this.checkObjectList = new Array();
	this.define = Validator_define;
	this.validate = Validator_validate;
	this.clear = Validator_clear;
	this.errHandler = new mi.AlertHandler();
	$(':input').removeClass('error');
}
//**********************************************************************************
// 清除已定義好的 validate list，以利重新定義 validate list
//**********************************************************************************
function Validator_clear(){
	this.checkObjectList = new Array();
	this.errHandler = new mi.AlertHandler();
}
//**********************************************************************************
// 逐一執行 validate list 中的每一個 check ojbect 的 validate method
// 若執行 validate 的結果是 false 的，則會看是否有定義 errHandler。
// 若有的話會將 check object 傳給 errHandler。
//**********************************************************************************
function Validator_validate(){
	var tmpObj;
	var elem;
	var result = true;
	for(var i=0;i<this.checkObjectList.length;i++){
		tmpObj = this.checkObjectList[i];
		elem = tmpObj.element;
		if(tmpObj.element.disabled){ continue; }
		var rt = tmpObj.validate(tmpObj.element.value,tmpObj.min,tmpObj.max,tmpObj);
		if(typeof(rt) == 'string'){
			tmpObj.errMsg = rt;
			rt = false;	
		}else if(typeof(rt)=='object' && rt['errMsg']){
			tmpObj.errMsg = rt['errMsg'];
			rt = false;
		}
		
		if(!rt){
			result = false;
			if(this.errHandler){
				if(typeof(this.errHandler)=='function'){
					this.errHandler(tmpObj);
				}else{
					this.errHandler.handle(tmpObj);
				}
			}	
		}else{	
			//通過驗證的時候，移除錯誤的CSS
			$(elem).removeClass('error');
		}
		
	}
	
	if(this.errHandler && this.errHandler['display']){
		this.errHandler.display();
	}	
		
	return result;
}
//**********************************************************************************
// 將每一個要檢核的欄位名稱及檢核型態、限制、或自定的方法設定進去。
// n - field name (Required)
// desc - 欄位的說明 (Should define)
// errMsg - 若是檢核錯誤的回應訊息 (Should define)
// type - validate type (string, num, date, option Function Name) (Required)
// min - 最小值
// max - 最大值
//**********************************************************************************
//function Validator_define(n,desc,errMsg,type,min,max){
function Validator_define(selector,desc,errMsg,type,min,max){
	var checkObjectList = this.checkObjectList;
	var $selector = $(selector);
	$.each($selector, function(index,elem){ 
		checkObjectList.push(new CheckObject(elem, desc, errMsg, type, min, max));
	});
		
}
//-------------------------------------------------------------------------
// 此 check object 為 Validator 相關操作的資料物件。
// 每一個 check object 攜帶了對一個欄位檢核的相關資料。
// 屬性及資料描述如下:
// name - 要被檢核的欄位名稱(element 的 name)
// element - 要被檢核的 element
// desc - 該欄位的說明
// errMsg - 若檢核錯誤時要顯示的錯誤訊息
// type - 設定的檢核型態(或自定的檢核 function name)
// min - 檢核的條件1
//	    (字串檢核時為長度的最小值，數字時為數值的最小值。
//       若為自定的 function，則會將此變數所帶的限制傳給
//       該 function 當為限制條件)
// max - 檢核的條件2
//	    (字串檢核時為長度的最大值，數字時為數值的最大值。
//       若為自定的 function，則會將此變數所帶的限制傳給
//       該 function 當為限制條件)
// validate - 實際執行 validate 的 function。會由 Validator 來呼叫。
// 
//-------------------------------------------------------------------------
//function CheckObject(n,desc,errMsg,type,min,max){
function CheckObject(elemt,desc,errMsg,type,min,max){
	this.name = elemt.name;
	this.element = elemt;
	this.desc = desc;
	this.errMsg = errMsg;
	this.type = type;
	this.min = min;
	this.max = max;
	this.validate;
	
	if(typeof(type) == 'function'){
		this.validate = type;
	}else{	
		switch(type.toUpperCase()){
			default: {var func=window[type]; if(func){this.validate=func;}else{throw new Error("Can't find the Validate function [" + type + "]");}break;}
			case 'STRING' : {this.validate=validateString;break;}
			case 'NUM' : {this.validate=validateNum;break;}
			case 'EMAIL' : {this.validate=validateEMAIL;break;}
			case 'SELECT' : {this.validate=validateSelect;break;}
			case 'DATE' : {this.validate=validateDateInput;break;}
			case 'STRING_BYTES' : {this.validate=validateStringBytes;break;}
			case 'CHECKED' : {this.validate=validateChecked;break;}
			case 'DATE_INPUT' : {this.validate=validateDateInput;break;}
			case 'AMT' : {this.validate=validateAmt;break;}
			case 'ROC_DATE' : {this.validate=validateRocDate;break;}
		}
	}	

}

function objectLength( obj ) {
	var count = 0;
	for ( var i in obj )
		count++;
	return count;
}

//***************************************************************************
// Default validate function for string and number type.
//***************************************************************************
function validateString(v,min,max){
	var len = v.length;
	//var len = objectLength(v);
	if( min && max && (len<min || len>max) ){
		return false;
	}else if( min && !max && (len<min) ){
		return false;
	}else if( !min && max && (len>max)){
		return false;
	}else if( !min && !max && (len<=0) ){
		return false;
	}
	return true;
}
function validateNum(v,min,max){
	var re = /^[0-9+$]/;
	var len = v.length;
	if( (len<=0) || (!re.test(v)) ){
		return false;
	}else if( min && max && (v<min || v>max) ){
		return false;
	}else if( !min && max && (v>max) ){
		return false;
	}else if( min && !max && (v<min) ){
		return false;
	}
	return true;
}
function validateEMAIL(v,min,max){
	var len = v.length;
	if( min && max && (len<min || len>max) ){
		return false;
	}else if( min && !max && (len<min) ){
		return false;
	}else if( !min && max && (len>max)){
		return false;
	}else if( !min && !max && (len<=0) ){
		return false;
	}		
	var r = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
	return r.test( v );
}
//------------------------------------------------------------------------------
function validateSelect(v) {
	if (v == '') {
		return false;
	}
	return true;
}
//------------------------------------------------------------------------------
//檢核西元年 YYYYMMDD or YYYY-MM-DD or YYYY/MM/DD
function validateDateInput(v) {

	v = v.replace('/',  '');
	v = v.replace('-',  '');
	v = v.replace('/',  '');
	v = v.replace('-',  '');
		
	var data = v.match(/^(\d{4})(\d{2})(\d{2})$/);
	if (!data || !v) {
		return false;
	}
	var d = new Date(RegExp.$1 + "/" + RegExp.$2 + "/" + RegExp.$3);
	if (d.getMonth() != (RegExp.$2-1) || d.getDate() != RegExp.$3) {
		return false;
	}
	return true;
	
}
//------------------------------------------------------------------------------
//檢核西元年
function validateDate(v) {
	return validateDateInput(v);
}
//------------------------------------------------------------------------------
// add by dave
function validateChecked(value,min,max,obj) {

	var list = $('[name="'+obj.name+'"]');
	
	for (var i=0;i<list.length;i++) {
		if (list[i].checked == true) {
			return true;
		}
	}

	return false;
}
//------------------------------------------------------------------------------
function validateAmt(v,min,max){
	v=v.replace(/,/g, "");
	var len = v.length;
	var checkMin = !isNaN(parseInt(min,10));
	var checkMax = !isNaN(parseInt(max,10)); 
	if( (len<=0) || (isNaN(v)) ){
		return false;
	}else if( checkMin && checkMax && (v<min || v>max) ){
		return false;
	}else if( !checkMin && checkMax && (v>max) ){
		return false;
	}else if( checkMin && !checkMax && (v<min) ){
		return false;
	}
	return true;
}
/**
 *	@class check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyyMMDD, yyy/MM/DD」。 <br>
 *	       若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。 <br>
 *	       若為民國前之年月日時，會在日期前加上 - ，如 民國前 1 年 2 月 3 日為 -000203，民國前 2 年 2 月 3 日為 -010203。 <br>
 *	       Ex : isROCdate('191231')                 return  false。 <br>
 *	            isROCdate('191231', false)          return  true 。 <br>
 *	            isROCdate('-010203', false)         return  false。 <br>
 *	            isROCdate('-010203', false, true)   return  true 。 <br>
 *	            isROCdate('1000203')                return  true 。 <br>
 *	            isROCdate('200/01/01')              return  true 。 <br>
 *	@param String : 民國年月日。
 *	@param boolean : 民國年是否限制在 20 年以前（不含），若不限制，請傳入 false，預設為限制。
 *	@param boolean : 是否為民國年前，若輸入參數為民國前，請傳入 true ，預設為 false。
 **/
function validateRocDate(srcData, yearLimit, isROCBefore){

	var d;
	var rocDateIsBefore = false;

	if(isROCBefore===true){
		if (srcData.substring(0,1)=="-"){ 
			srcData = srcData.substring(1,srcData.length);
			rocDateIsBefore = true;
		}
	}

	if(srcData && srcData.length == 5){
		srcData = '0' + srcData;
	}

	if(rocDateIsBefore){
		if((srcData.match(/^(\d{2})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{3})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{4})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{2})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{3})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{4})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)-1911)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else{
		if((srcData.match(/^(\d{2})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{3})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{4})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{2})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{3})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((srcData.match(/^(\d{4})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
	}

	if(!d || d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3 ){
		return false
	}

	if(yearLimit!==false){
		// 西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
		// 西元 1911-01-01（民國 000101）視為合理日期
		// Date getMonth() - Returns the month from the date object as a value from 0 through 11.
		// Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
		if( ( !( d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1 )) && d.getFullYear() < 1931){
			return false;
		}
	}

	return true;
}
//------------------------------------------------------------------------------
//以byte單位檢查字串長度
var twoBytesRegExp = /[^\x00-\xff]/g;
function validateStringBytes(v, min, max) {
  var len = v.replace(twoBytesRegExp, "rr").length;
	if (min && max && (len < min || len > max)) {
		return false;
	} else if (min && !max && len < min) {
		return false;
	} else if (!min && max && len > max) {
		return false;
	} else if (!min && !max && len <= 0) {
		return false;
	}
	return true;
}
//---------------------------------------------------
window.mi.AlertHandler = 
function () {
	this.msg = new Array();
	this.markList = new Array();
	this.handle = Alert_handle;
	this.display = Alert_display;
	this.mark = Alert_mark;
	this.clear = Alert_clear;
}
//---------------------------------------------------
//一定要定義的 method，收到的參數為 check object
function Alert_handle(obj){
	this.msg.push(obj.desc + "[" + obj.errMsg + "]");
	this.mark(obj.element);
}
//---------------------------------------------------
function Alert_mark(e){
	this.markList.push(e);
	console.log($(e));
	console.log('e.style.backgroundColor');
	$(e).addClass('error');
}
//---------------------------------------------------
function Alert_clear(){
	this.msg = new Array();
	this.focusElement = null;
	for(var i=0;i<this.markList.length;i++){
		$(this.markList[i]).addClass('error');
	}
	this.markList = new Array();
}
//---------------------------------------------------
function Alert_display(){
	if(this.msg.length>0){
		var str = "檢核錯誤如下:\n";
		for(var i=0; i<this.msg.length;i++){
			str += this.msg[i] + "\n";
		}
		$.mi.error(str);
	}
}