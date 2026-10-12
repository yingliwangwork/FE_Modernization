/**
 * 網頁檢核公用程式
 * Add by I9200309 at 2010.11.04
 * Modify by I9200309 at 2010.11.04 for 瀏覽器相容性修改
 */
/*
 * 使用方法
 * 1. 網頁中以二維陣列宣告檢核設定, 
 *    第一維陣列中放置多筆檢核設定: [[setting1], [setting2], [setting3]...], 
 *    第二維陣列中放置設定明細: [[Element ID, Error Message, Check Rule, Limit], [...], [...]], 
 *    Element ID 為欲檢核欄位之 ID, Error Message 為檢核失敗時所要顯示的訊息, Check Rule 為檢核規則, Limit 為檢核限制, 
 *    Check Rule 的部份, 提供 not null, max, email, date, number, select, check, idno 等, 
 *      not null: 空值檢核
 *      max: 字元長度檢核, 須搭配 Limit 指定長度
 *      email: Email 檢核
 *      date: 日期檢核, Limit 若為 chinese, 則為民國日期
 *      number: 數字檢核
 *      select: 選單檢核
 *      check: CheckBox 或 RadioBox 檢核
 *      idno: 身份證字號檢核
 *    範例: 
 *    var settings = [["id", "請輸入身份證字號（非本國籍請輸入居留證號碼）", "not null"], ["id", "身份證字號輸入錯誤", "idno"], ["password", "請輸入密碼", "not null"]]
 * 2. 表單提交前須先觸發檢核功能, 回傳值為 true, 代表檢核成功
 *    範例: 
 *    validation.validate(settings);
 */
if(!window.validation){
	validation = {};
}
validation.validate = function validate(settings) {
    if (settings == null || settings.length <= 0) {
        return false;
    }
    
    for (var i = 0; i < settings.length; i++) {
        var fields = document.getElementsByName(settings[i][0]);
        
        if (fields != null && fields.length > 0) {
        	for (var j = 0; j < fields.length; j++) {
        		fields[j].style.backgroundColor = "";
        	}
        }
    }

    for (i = 0; i < settings.length; i++) {
        fields = document.getElementsByName(settings[i][0]);

        if (fields != null && fields.length > 0) {
        	if (settings[i][2] == "check") {
        		if (!this.check(fields, settings[i][2], settings[i][3])) {
        			alert(settings[i][1]);
        			
        			return false;
        		}
        	} else if (settings[i][2] == "max") {
        		for (var ii = 0; ii < fields.length; ii++) {
        			var length = this.getLength(fields[ii].value);
        			
        			if (length > parseInt(settings[i][3], 10)) {
        				this.setError(fields[ii]);
        				
        				fields[ii].focus();
        				
        				alert(settings[i][1] + "(最大字元數: " + settings[i][3] + ", 目前字元數: " + length + ")");
        				
        				return false;
        			}
        		}
        	} else {
        		for (ii = 0; ii < fields.length; ii++) {
        			if (!this.check(fields[ii], settings[i][2], settings[i][3])) {
                        if (settings[i][2] == "not null" || settings[i][2] == "email" || settings[i][2] == "date" || settings[i][2] == "number" || settings[i][2] == "select" || settings[i][2] == "idno") {
                            this.setError(fields[ii]);
                        }
                        
                        fields[ii].focus();
                        
                        alert(settings[i][1]);
                        
                        return false;
        			}
        		}
        	}
        }
        
    }
    
    return true;
}

validation.check = function(field, type, limit) {
    if (type == "not null") {
        if (field.value != null && field.value != "") {
            return true;
        }
    } else if (type == "email") {
        if (field.value == null || field.value == "" || this.checkEmail(field.value)) {
            return true;
        }
    } else if (type == "date") {
        if (field.value == null || field.value == "" || this.checkDate(field.value, limit)) {
            return true;
        }
    } else if (type == "number") {
        if (field.value == null || field.value == "" || this.checkNumber(field.value)) {
            return true;
        }
    } else if (type == "select") {
        if (field.value != null && field.value != "") {
            return true;
        }
    } else if (type == "check") {
        for (var ii = 0; ii < field.length; ii++) {
            if (field[ii].checked) {
                return true;
            }
        }
    } else if (type == "idno") {
        if (field.value == null || field.value == "" || this.checkId(field.value)) {
            return true;
        }
    }
    
    return false;
}

validation.getLength = function(value) {
    var reg = /[^\u0000-\u00FF]/;
    var len = 0;
    for (var iii = 0; iii < value.length; iii++) {
        var each = value.charAt(iii);
        if (each.match(reg) != null) {
            len += window.charCountsByte || 2;
        } else {
            len++;
        }
    }
    return len;
}

validation.checkEmail = function(email) {
    var objRe = /^[_a-zA-Z0-9-]{1}(\.?[_a-zA-Z0-9-]+)*@([_a-zA-Z0-9-]+\.)+[a-zA-Z0-9]{2,3}$/;

    if (objRe.test(email)) {
        return true;
    }

    return false;
}

validation.checkDate = function(value, type) {
    var pattern;
    
    var lenYear;
    
    if (type == "chinese") {
        if (value.length >= 7) {
            pattern = /^(\d{3})(0[1-9]|1[0-2])(3[0-1]|[0-2][0-9])$/;
            lenYear = 3;
        } else {
            pattern = /^(\d{2})(0[1-9]|1[0-2])(3[0-1]|[0-2][0-9])$/;
            lenYear = 2;
        }
    } else {
        pattern = /^(\d{4})(0[1-9]|1[0-2])(3[0-1]|[0-2][0-9])$/;
        lenYear = 4;
    }
    
    if (value.match(pattern)) {
        var year = parseInt(value.substring(0, lenYear), 10);
        var month = parseInt(value.substring(lenYear, lenYear + 2), 10) - 1;
        var day = parseInt(value.substring(lenYear + 2, lenYear + 4), 10);
        
        if (lenYear < 4) {
            year += 1911;
        }
        
        var date = new Date(year, month, day);
        
        if (year == date.getFullYear() && month == date.getMonth() && day == date.getDate()) {
            return true;
        }
    }
    
    return false;
}

validation.checkNumber = function(value) {
    var pattern = /^\d+$/;
    
    if (value.match(pattern)) {
        return true;
    }
    
    return false;
}

validation.setError = function(field) {
    field.style.backgroundColor = "#ff8888";
}

/**
 * 功能說明: 身份證檢查。<br>
 * 使用說明: 公司內部採用3套身份證檢核。<br>
 * 1.國內身份證(idCheck1)。<br>
 * 2.護照(idCheck2)。<br>
 * 3.無戶籍身份證(idCheck3)。<br>
 */
/*2020-04-14 先行註解
validation.checkId = function(idno) {
	if (idno == null) {
		return false;
	}

	idno = idno.toUpperCase();
	//2020-04-09 配合移民署新政策,第二碼為8or9也是外國人
	if (("ABCD".indexOf(idno.charAt(1))) < 0 && ("89".indexOf(idno.charAt(1)) < 0 )) {
		if (chkID(idno)) {
			return false;
		} else {
			return true;
		}
	}
	
	return this.checkId4Foreign(idno);
}
*/
/**
 * 功能說明 : 無戶籍身份證檢查。 <br>
 * 使用說明 :  <br>
 * 1.第一碼為區域碼(同國民身份證)。 <br>
 * 2.第二碼為性別碼(入出境管理局使用AB；警察區外事科／課使用CD)。 <br>
 *   其中A與C為男性；B與D為女性。 <br>
 * 3.第三碼至第九碼為流水號。 <br>
 * 4.第十碼為檢查號碼。 <br>
 **/
validation.checkId4Foreign = function(id) {
	var LegalID = "0123456789";
	var val = 0;
	var gender = 0;
	var sId = id.toUpperCase();

	if (sId.length != 10) {
		return false;
	}

	var convertCheckId = function(inputId){
		var convertNumMapping = 'PDKOAFNCLJQRMBEGHSIX';
		inputId = inputId.toUpperCase();
		var lastWrodIndex = inputId.length - 1;
		var lastWord = inputId.charAt(lastWrodIndex);
		var num = convertNumMapping.indexOf(lastWord);
        if (num >= 0) {
        	return null;
        }
        return inputId;
	};

	sId = convertCheckId(sId);
	if(sId === null){
        return true;
	}

	if (sId.charAt(0) == 'A') {
		val = 10;
	} else if (sId.charAt(0) == 'B') {
		val = 11;
	} else if (sId.charAt(0) == 'C') {
		val = 12;
	} else if (sId.charAt(0) == 'D') {
		val = 13;
	} else if (sId.charAt(0) == 'E') {
		val = 14;
	} else if (sId.charAt(0) == 'F') {
		val = 15;
	} else if (sId.charAt(0) == 'G') {
		val = 16;
	} else if (sId.charAt(0) == 'H') {
		val = 17;
	} else if (sId.charAt(0) == 'J') {
		val = 18;
	} else if (sId.charAt(0) == 'K') {
		val = 19;
	} else if (sId.charAt(0) == 'L') {
		val = 20;
	} else if (sId.charAt(0) == 'M') {
		val = 21;
	} else if (sId.charAt(0) == 'N') {
		val = 22;
	} else if (sId.charAt(0) == 'P') {
		val = 23;
	} else if (sId.charAt(0) == 'Q') {
		val = 24;
	} else if (sId.charAt(0) == 'R') {
		val = 25;
	} else if (sId.charAt(0) == 'S') {
		val = 26;
	} else if (sId.charAt(0) == 'T') {
		val = 27;
	} else if (sId.charAt(0) == 'U') {
		val = 28;
	} else if (sId.charAt(0) == 'V') {
		val = 29;
	} else if (sId.charAt(0) == 'X') {
		val = 30;
	} else if (sId.charAt(0) == 'Y') {
		val = 31;
	} else if (sId.charAt(0) == 'W') {
		val = 32;
	} else if (sId.charAt(0) == 'Z') {
		val = 33;
	} else if (sId.charAt(0) == 'I') {
		val = 34;
	} else if (sId.charAt(0) == 'O') {
		val = 35;
	} else {
		return false;
	}
	//2020-04-09 配合移民署新政策,第二碼為8or9也是外國人
	if("89".indexOf(sId.charAt(1)) >= 0){
		var intNum = val;
		var tmpStr = intNum + sId.substring(1, 9);
		var mulIntNew = [1, 9, 8, 7, 6, 5, 4, 3, 2, 1];
		var sum = 0;
		var chkCode = sId.charAt(sId.length - 1);
		
		for(var i = 0; i < tmpStr.length; i++){
			var c = tmpStr.charAt(i);
			if(LegalID.indexOf(c) == -1){
				return false;
			}
			sum = parseInt(sum) + (parseInt(c) * parseInt(mulIntNew[i])) % 10;
		}
		
		var mod = sum % 10;
		
		return (mod == 0 && chkCode == 0) || (parseInt(mod) + parseInt(chkCode) == 10);
	}
	
	if (sId.charAt(1) == 'A') {
		gender = 0;
	} else if (sId.charAt(1) == 'B') {
		gender = 1;
	} else if (sId.charAt(1) == 'C') {
		gender = 2;
	} else if (sId.charAt(1) == 'D') {
		gender = 3;
	} else {
		return false;	
	}

	val = Math.floor(val / 10) + (val % 10) * 9 + gender * 8 + parseInt(sId.charAt(2), 10) * 7 + parseInt(sId.charAt(3), 10) * 6 + parseInt(sId.charAt(4), 10) * 5 + parseInt(sId.charAt(5), 10) * 4 + parseInt(sId.charAt(6), 10) * 3 + parseInt(sId.charAt(7), 10) * 2 + parseInt(sId.charAt(8), 10) + parseInt(sId.charAt(9), 10);

	val = val % 10;

	if (val != 0) {
		return false;
	}

	var i;
	var c;

	for (i = 2; i < sId.length; i++) {
		c = sId.charAt(i);
		if (LegalID.indexOf(c) == -1) {
			return false;
		}
	}

	var a = 1;
	var b;

	b = sId.charAt(a);

	if (b == 'A' || b == 'B' || b == 'C' || b == 'D') {
		return true; 
	} else {
		return false;
	}
}