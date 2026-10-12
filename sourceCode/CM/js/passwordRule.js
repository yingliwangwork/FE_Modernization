/**
 * 程式：passwordRule.js 導頁相關 js
 * 作者：楊宗翰
 * 功能：統一管理密碼邏輯
 * 完成：2014/03/27
 * 更新：
 *           Date         Author                                                    Description
 *      ==============  ==========  ==============================================================================================================
 *			2014/03/27		楊宗翰      傳入參數 options(object):sysCode, minLength, maxLength
 * 
 * 說明：
 *           public function                                                        Description
 *      =========================   =============================================================================================================
 *        	check						檢核密碼是否符合規則
 **/
function PasswordRule(options){
	var sysCode;
	var minLength = 6;
	var maxLength = 12;
	var sys_Rule_Mapping = {
		//Ex: "EP":"default" 系統對應的規則編號
	};	
	var rule = sysCode&&sys_Rule_Mapping[sysCode] ? sys_Rule_Mapping[sysCode] : "default";
	
	var actions = {
		init: function(){
			if(options){
				sysCode = options.sysCode;
				minLength = options.minLength ? options.minLength : minLength;
				maxLength = options.maxLength ? options.maxLength : maxLength;
			}
		}	
		,check: function(pw){
			if(rule == "default"){
				var msg = "密碼須為 " + minLength + "~" + maxLength + " 碼英數字或英文，且不可含空白及特殊符號";
				if(pw.length > maxLength || pw.length < minLength){
					return msg;
				}
				
				if(validates.isNumber(pw, false)){
					return "密碼不可全為數字";
				}
				
				var regex = /^(?=.*\d)(?=.*[a-zA-Z])([a-zA-Z\d]){6,12}$/;
				var regex2 = /^(?=.*[a-zA-Z])([a-zA-Z]){6,12}$/;
				if(!regex.test(pw) && !regex2.test(pw)){
					return msg;
				}
			}
			
			return null;
		}
	};
	
	var validates = {
		isNumber : function(key_Value, isKey) {
			isKey = (isKey === false) ? false : true;
			var value;
			if (isKey && $(key_Value)) {
				value = $(key_Value).value;
			} else {
				value = key_Value;
			}
			
			if (isNaN(parseInt(value, 10)) || isNaN(Number(value)) || isNaN(value) || !isFinite(Number(value))) {
				return false;
			}

			return true;
		}
	};
	
	actions.init();
	
	/**
	 *  @public
	 *	@class 導頁(主要是做跨網域)
	 *	@param pw 密碼
	 *	@param type 規則種類
	 **/
	return{
		check:actions.check
	}
}