//**********************************************************************************
// 基本上和 \CM\js\Validator.js 一樣
//**********************************************************************************
// 提供交易頁面建立 validate list 的物件。
//**********************************************************************************
function Validator(){
	this.checkObjectList = new Array();
	this.define   = Validator_define;

	//克服：若物件為ARRAY,無法用 ObjectName 抓到各個 Element。
	this.define1  = Validator_define1;

	this.validate = Validator_validate;
	this.clear = Validator_clear;
	this.errHandler;
}
//**********************************************************************************
// 清除已定義好的 validate list，以利重新定義 validate list
//**********************************************************************************
function Validator_clear(){
	this.checkObjectList = new Array();
	this.errHandler = null;
}
//**********************************************************************************
// 逐一執行 validate list 中的每一個 check ojbect 的 validate method
// 若執行 validate 的結果是 false 的，則會看是否有定義 errHandler。
// 若有的話會將 check object 傳給 errHandler。
//**********************************************************************************
function Validator_validate(){
	var tmpObj;
	var result = true;
	for(var i=0;i<this.checkObjectList.length;i++){
		tmpObj = this.checkObjectList[i];
		if(tmpObj.element.disabled){ continue; }
		if(!tmpObj.validate(tmpObj.element.value,tmpObj.min,tmpObj.max)){
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
//**********************************************************************************
// 將每一個要檢核的欄位名稱及檢核型態、限制、或自定的方法設定進去。
// n - field name (Required)
// desc - 欄位的說明 (Should define)
// errMsg - 若是檢核錯誤的回應訊息 (Should define)
// type - validate type (string, num, date, option Function Name) (Required)
// min - 最小值
// max - 最大值
//**********************************************************************************
function Validator_define(n,desc,errMsg,type,min,max){
	this.checkObjectList.push(new CheckObject(n,desc,errMsg,type,min,max));
}
function Validator_define1(n,desc,errMsg,type,min,max){
	this.checkObjectList.push(new CheckObject1(n,desc,errMsg,type,min,max));
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
function CheckObject(n,desc,errMsg,type,min,max){
	this.name = n;
	this.element = document.getElementById(n);
	this.desc = desc;
	this.errMsg = errMsg;
	this.type = type;
	this.min = min;
	this.max = max;
	this.validate;
	switch(type.toUpperCase()){
		default: {this.validate=window[type];break;}
		case 'STRING' : {this.validate=validateString;break;}
		case 'NUM' : {this.validate=validateNum;break;}
	}
}

function CheckObject1(n,desc,errMsg,type,min,max){
	this.element = n;
	this.desc = desc;
	this.errMsg = errMsg;
	this.type = type;
	this.min = min;
	this.max = max;
	this.validate;
	switch(type.toUpperCase()){
		default: {this.validate=window[type];break;}
		case 'STRING' : {this.validate=validateString;break;}
		case 'NUM' : {this.validate=validateNum;break;}
	}
}

//***************************************************************************
// Default validate function for string and number type.
//***************************************************************************
function validateString(v,min,max){
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
	return true;
}
function validateNum(v,min,max){
	var len = v.length;
	if( (len<=0) || (isNaN(v)) ){
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
