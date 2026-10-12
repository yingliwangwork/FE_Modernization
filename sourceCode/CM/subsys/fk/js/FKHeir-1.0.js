var FKHeir = {
		isNumeric: function(obj){
			// 從 CM\js\jquery\jquery-3.6.0.js 剪貼的 程式碼，
			// jQuery 要 deprecate 這個 function，故剪貼過來使用
			// jQuery.type 改為 typeof
			// As of jQuery 3.0, isNumeric is limited to
			// strings and numbers (primitives or objects)
			// that can be coerced to finite numbers (gh-2662)
			var type = typeof obj;
			return ( type === "number" || type === "string" ) &&

				// parseFloat NaNs numeric-cast false positives ("")
				// ...but misinterprets leading-number strings, particularly hex literals ("0x...")
				// subtraction forces infinities to NaN
				!isNaN( obj - parseFloat( obj ) );
		},
		trim: function(text){
			var textType = typeof text;
			if(textType === 'string'){
				return text.trim();
			}
			if(textType === 'number'){
				return String(text);
			}
			if(textType === 'undefined'){
				return "";
			}
			return text.toString();
		},
		dataWithProperty:function(data,propertyName){
			var dataType = typeof data;
			if (dataType === 'object' && data.hasOwnProperty(propertyName)){
				return data[propertyName];
			}
			return data;
		},
		parseJSON: function(jsonString){
			//傳入jsonString 為 String，才會呼叫JSON.parse()進行解析
			if (typeof jsonString === 'string'){
				//若傳入不正常的 JSON String
				//$.parseJSON('a')拋錯，$.parseJSON('abc')拋錯，$.parseJSON('3{]')拋錯
				//$.parseJSON('3')回傳3，JSON.parse('3.14')回傳3.14
				//$.parseJSON('[]')回傳object，JSON.parse('{}')回傳object
				//空字串，$.parseJSON('')回傳null	
				//上述情況，這個 function 與 $.parseJSON() 回傳值相同
				var source = (jsonString.trim().length == 0) ? null : jsonString;
				return JSON.parse(source);		
			}
			
			//typeof jsonString === 'number'，$.parseJSON(3)回傳null
			//typeof jsonString === 'object'，$.parseJSON(new Object())回傳null
			//typeof jsonString === 'function'，$.parseJSON(function myFun(){})回傳null					
			//上述情況，這個function回傳null，與 $.parseJSON() 回傳值相同
			//typeof jsonString === 'undefined'，$.parseJSON()拋 exception，這個function回傳null			
			return null;
		}
}