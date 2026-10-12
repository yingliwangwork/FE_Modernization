/*
提供交易頁面建立 validate list 的物件。
*/
if(!window.validateDateInput){// 檢核西元年 YYYYMMDD or YYYY-MM-DD or YYYY/MM/DD
	window.validateDateInput = function(v){
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
	};
}
/*
檢核西元年
*/
if(!window.validateDate){
	window.validateDate = function(){
		validateDateInput(v);
	};
}
function Validator(){

	function isOnTheSys(sysId){

		//know whick webcontext the page is existed
		var wls = window.location.toString();

		var judgeOnSys = function(inSysId){
			var patternString = '\/'+inSysId+'Web*';
			var regex = new RegExp(patternString);
			return regex.test(wls);
		};
		var checkOnSys = false;

		if(typeof(sysId) == 'object' && sysId.length){
			for(var i=0;i<sysId.length;i++){
				checkOnSys = judgeOnSys(sysId[i]);
				if(checkOnSys){
					break;
				}
			}
		}else{
			checkOnSys = judgeOnSys(sysId);
		}
		return checkOnSys;

	}

	/*
	若子系統為「DD、DF、DJ、AK」，不在進行檢核時自動顯示訊息
	*/
	if(isOnTheSys(['DD','DF','DJ','AK'])){
		this.validate = Validator_validateOld;
	}else{
		this.validate = Validator_validate;		
	}

	this.checkObjectList = new Array();
	this.define = Validator_define;
	this.validateOld = Validator_validateOld;
	this.clear = Validator_clear;
	this.errHandler = new AlertHandler;

}
/*
清除已定義好的 validate list，以利重新定義 validate list
*/
function Validator_clear(){
	this.checkObjectList = new Array();
	this.errHandler.clear();
}
/*
逐一執行 validate list 中的每一個 check ojbect 的 validate method
若執行 validate 的結果是 false 的，則會看是否有定義 errHandler。
若有的話會將 check object 傳給 errHandler。
*/
function Validator_validate(){
	this.errHandler.clear();
	var result = this.validateOld();
	if(!result) this.errHandler.display();
	return result;
}
/*
同上, 不會直接display message
*/
function Validator_validateOld(){

	var result = true;
	for(var i=0;i<this.checkObjectList.length;i++){
		var tmpObj = this.checkObjectList[i];
		if(!tmpObj.element || tmpObj.element.disabled){ continue; }
        var datatype = (tmpObj.element.getAttribute('datatype') + '').toLowerCase();
		var tmpObjValue = datatype != 'rocdate' && tmpObj.hasIncludePrototype?$F(tmpObj.element):tmpObj.element.value;
		var rt = tmpObj.validate(tmpObjValue,tmpObj.min,tmpObj.max, tmpObj);
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
				if((typeof this.errHandler)=='function'){
					this.errHandler(tmpObj);
				}else{
					this.errHandler.handle(tmpObj);
				}
			}	
		}
	}

	return result;
}
/*
將每一個要檢核的欄位名稱及檢核型態、限制、或自定的方法設定進去。
n - field name (Required)
desc - 欄位的說明 (Should define)
errMsg - 若是檢核錯誤的回應訊息 (Should define)
type - validate type (string, num, date, option Function Name) (Required)
min - 最小值
max - 最大值
*/
function Validator_define(n,desc,errMsg,type,min,max){
	this.checkObjectList.push(new CheckObject(n,desc,errMsg,type,min,max));
}
/*-------------------------------------------------------------------------
 此 check object 為 Validator 相關操作的資料物件。
 每一個 check object 攜帶了對一個欄位檢核的相關資料。
 屬性及資料描述如下:
 name - 要被檢核的欄位名稱(element 的 name)
 element - 要被檢核的 element
 desc - 該欄位的說明
 errMsg - 若檢核錯誤時要顯示的錯誤訊息
 type - 設定的檢核型態(或自定的檢核 function name)
 min - 檢核的條件1
	    (字串檢核時為長度的最小值，數字時為數值的最小值。
       若為自定的 function，則會將此變數所帶的限制傳給
       該 function 當為限制條件)
 max - 檢核的條件2
	    (字串檢核時為長度的最大值，數字時為數值的最大值。
       若為自定的 function，則會將此變數所帶的限制傳給
       該 function 當為限制條件)
 validate - 實際執行 validate 的 function。會由 Validator 來呼叫。
 
-------------------------------------------------------------------------*/
function CheckObject(n,desc,errMsg,type,min,max){

	if(typeof(n)=='object'){
		this.name = n.name;
		this.element = n;
	}else{
		this.name = n;
		var hasIncludePrototype = typeof(window['Prototype']) !== "undefined";
		this.hasIncludePrototype = hasIncludePrototype;
		if(hasIncludePrototype){
			this.element = $(n);
		}else{
			this.element = document.getElementById(n);
		}
	}

	this.desc = desc;
	this.errMsg = errMsg;
	this.type = type;
	this.min = min;
	this.max = max;
	this.validate;

	if(!this.element) throw new Error("Can't find the input element, name=[" + this.name + "]");

	if(typeof(type) == 'function'){
		this.validate = type;
	}else{
		switch(type.toUpperCase()){
			default: {var func=window[type]; if(func){this.validate=func;}else{throw new Error("Can't find the Validate function [" + type + "]");}break;}
			case 'STRING' : {this.validate=validateString;break;};
			case 'NUM' : {this.validate=validateNum;break;};
			case 'SELECT' : {this.validate=validateSelect;break;};
			case 'DATE' : {this.validate=validateDateInput;break;};
			case 'STRING_BYTES' : {this.validate=validateStringBytes;break;};
			case 'CHECKED' : {this.validate=validateChecked;break;};
			case 'DATE_INPUT' : {this.validate=validateDateInput;break;};
			case 'AMT' : {this.validate=validateAmt;break;};
		}
	}
}
/*-------------------------------------------------------------------------
 Default validate function for string and number type. 
-------------------------------------------------------------------------*/
function validateString(v,min,max){    
    var len;
    if(v != null) {
        len = v.length;
    }else {
        len = 0;
    }

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
//------------------------------------------------------------------------------
function validateNum(v,min,max){
    var len;
    if(v != null) {
        len = v.length;
    }else {
        len = 0;
    }	
	
	var checkMin = !isNaN(parseInt(min));
	var checkMax = !isNaN(parseInt(max)); 
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
//------------------------------------------------------------------------------
function validateSelect(v) {
	if ( typeof v === "undefined" || v === null || v === '' ) {
		return false;
	}
	return true;
}
//------------------------------------------------------------------------------
// add by dave
function validateChecked(value,min,max,obj) {

	var list = document.getElementsByName(obj.name);
	
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
//------------------------------------------------------------------------------
/*
以byte單位檢查字串長度
*/
var twoBytesRegExp = /[^\x00-\xff]/g;
function validateStringBytes(v, min, max) {
	var replacePattern = '';
	for(var cc = 0 ; cc < (window.charCountsByte || 2) ; cc++ ){
		replacePattern = replacePattern +'r';
	}
    var len = v.replace(twoBytesRegExp, replacePattern).length;
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
/*
Default AlertHandler for display error message
*/
function AlertHandler (){
	this.msg = new Array();
	this.markList = new Array();
	this.handle = Alert_handle;
	this.display = Alert_display;
	this.mark = Alert_mark;
	this.clear = Alert_clear;
	this.focus = Alert_focus();
	this.executeDisplayMessage = true;
}
//---------------------------------------------------
function Alert_focus () {
	if(this.markList && this.markList[0]){
		this.markList[0].focus();
	}
}
//---------------------------------------------------
/*
一定要定義的 method，收到的參數為 check object
*/
function Alert_handle(obj){
	this.msg.push(obj.desc + "[" + obj.errMsg + "]");
	
	/*
		2011-08-01
		傳入的物件若為 radio button，則以物件的 name 取得 radio array，
		再針對 radio array 中的每個元素做 mark
	*/
	if( obj.element && obj.element.type == 'radio' ) {
	
		var radioBtns = document.getElementsByName( obj.name );

		for(var i = 0; i < radioBtns.length; i ++) {
			this.mark( radioBtns[ i ] );
		}
		
	} else {
		this.mark(obj.element);
	}
}
//---------------------------------------------------
function Alert_mark(e){
	this.markList.push(e);
	e.style.backgroundColor = "#FF8888";
}
//---------------------------------------------------
function Alert_clear(){
	this.executeDisplayMessage = true;
	this.msg = new Array();
	this.focusElement = null;
	
	for(var i=0;i<this.markList.length;i++){
		
		this.markList[i].style.backgroundColor = "";
	}
	this.markList = new Array();
}
//---------------------------------------------------
function Alert_display(){
	if(!this.executeDisplayMessage){
		return;
	}
	this.executeDisplayMessage = false;
	var str = "檢核錯誤如下:\n";
	for(var i=0; i<this.msg.length;i++){
		str += this.msg[i] + "\n";
	}
	alert(str);
}