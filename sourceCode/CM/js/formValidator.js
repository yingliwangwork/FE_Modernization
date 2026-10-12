function _validate(entity, settings) {
    if (settings == null || settings.length <= 0) {
        return false;
    }
    
    for (i = 0; i < settings.length; i++) {
    	var fields = entity.elements[settings[i][0]];
        
        if (!fields) {
            if (fields.length > 1) {
            } else {
                fields.style.backgroundColor = "";
            }
        }
    }
    
    for (i = 0; i < settings.length; i++) {
    	var fields = entity.elements[settings[i][0]];

        if (!fields) {
            if (!_check(fields, settings[i][2], settings[i][3])) {
                if (settings[i][2] == "not null" || settings[i][2] == "max" || settings[i][2] == "email" || settings[i][2] == "date" || settings[i][2] == "number") {
                    fields.style.backgroundColor = "#ff8888";
                }
                
                if (fields.length > 1) {
                } else {
                    fields.focus();
                }
                
                alert(settings[i][1]);
                
                return false;
            }
        }
        
    }

    return true;
/*
    var items = entity.all;
    for (i = 0; i < items.length; i++) {
        var type = items[i].type;
        var name = items[i].name;
        var value = items[i].value;
        if (type != null && name != null) {
            if (type == "text" || type == "textarea" || type == "password" || type == "file") {
                var rtnMsg = _check(name, value, settings);
                if (rtnMsg != null) {
                    items[i].style.backgroundColor = "#ff8888";
                    items[i].focus();

                    alert(rtnMsg);

                    return false;
                }
            } else if (type == "radio" || type == "checkbox") {
                var checked = false;
                var radios = entity.all[name];
                var rtnMsg;
                if (radios.length > 1) {
                    for (v = 0; v < radios.length; v++) {
                        rtnMsg = _check(name, radios[v].checked, settings);
                        if (rtnMsg == null) {
                            checked = true;
                        }
                    }
                } else {
                    rtnMsg = 
                    if (_check(name, radios.checked, settings)) {
                        checked = true;
                    }
                }
                if (!checked) {
                    alert("請至少勾選一個項目");
                    items[i].focus();
                    return false;
                }
            } else if (type == "select-one") {
                if (!_check(name, entity.all[name].value, settings)) {
                    items[i].focus();
                    return false;
                }
            }
        }
    }
    
    return true;
 */
}

function _check(field, type, limit) {
    if (type == "not null") {
        if (field.value != null && field.value != "") {
            return true;
        }
    } else if (type == "max") {
        var length = _getLength(field.value);
        if (length <= eval(limit)) {
            return true;
        }
    } else if (type == "email") {
        if (field.value == null || field.value == "" || _checkEmail(field.value)) {
            return true;
        }
    } else if (type == "date") {
        if (field.value == null || field.value == "" || _checkDate(field.value, limit)) {
            return true;
        }
    } else if (type == "number") {
        if (field.value == null || trim(field.value) == "" || _checkNumber(trim(field.value))) {
            return true;
        }
    } else if (type == "select") {
        if (field.value != null && field.value != "") {
            return true;
        }
    } else if (type == "check") {
        if (field.length > 1) {
            for (ii = 0; ii < field.length; ii++) {
                if (field[ii].checked) {
                    return true;
                }
            }
        } else {
            if (field.checked) {
                return true;
            }
        }
    }
    
    return false;
}

function _getLength(value) {
    var reg = /[^\u0000-\u00FF]/;
    var len = 0;
    for (iii = 0; iii < value.length; iii++) {
        var each = value.charAt(iii);
        if (each.match(reg) != null) {
            len += 2;
        } else {
            len++;
        }
    }
    return len;
}

function _checkEmail(email) {
    if (email != null) {
        for (iv = 0; iv < email.length; iv++) {
            if (email.charAt(iv) == "@") {
                return true;
            }
        }
    }
    return false;
}

function _checkDate(value, type) {
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
        var year = eval(value.substring(0, lenYear));
        var month = eval(value.substring(lenYear, lenYear + 2)) - 1;
        var day = eval(value.substring(lenYear + 2, lenYear + 4));
        
        if (lenYear < 4) {
            year += 1911;
        }
        
        var date = new Date(year, month, day);
        
        if (year == date.getYear() && month == date.getMonth() && day == date.getDate()) {
            return true;
        }
    }
    
    return false;
}

function _checkNumber(value) {
    var pattern = /^\d+$/;
    
    if (value.match(pattern)) {
        return true;
    }
    
    return false;
}

function trim(value) {
    return value.replace(/^\s+|\s+$/g,"");
}