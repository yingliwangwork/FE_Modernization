/*
程式：AGA1.js 保險給付建檔
作者：何志輝
功能：AGA1.js 畫面checkbox檢核
完成：2004/08/11
更新：2004/09/14
*/

/*
 * 存放資料。
 */
function DataGroup() {
	this.head = arguments[0];
	this.nameAy = new Array();
	this.errMsg = "";
	for(var pos = 1; pos < arguments.length; pos++)
		this.nameAy[pos - 1] = arguments[pos];
		
	this.setErrMsg = function(msg) {
		this.errMsg = msg;
	};
}

/*
 * 檢查在一組 dataGroup下所核取或填入的element數目，假如符合條件則true，反之則false。
 * @ param isSingle		是否只要核取單筆，是則true，反之則false
 * @ param dataGroup	欲驗證的資料集合
 * @ param formx		form物件
 * @ modified date		2004/09/06 08:50上午增加
 */
function validateElementCount(isSingle,dataGroup,formx) {
	var count = 0;
	var isGoValidate = true;
	if(dataGroup.head != null) 
		if(!parseStrToObj(dataGroup.head,formx).checked)
			isGoValidate = false;
	if(isGoValidate) {
		for(var i = 0; i < dataGroup.nameAy.length; i ++) {
			//2004/09/06 08:50上午增加
			if(typeof dataGroup.nameAy[i] != "object") {
				if(formx[dataGroup.nameAy[i]].type == "text") {
					if(formx[dataGroup.nameAy[i]].value != "" && 
						formx[dataGroup.nameAy[i]].value != "0")
						count ++;
				}
				else {
					if(formx[dataGroup.nameAy[i]].checked)
						count ++;
				}
			}
			else {
				if(validateRadioCount(dataGroup.nameAy[i].nameAy[0],formx,dataGroup.nameAy[i].errMsg,dataGroup.nameAy[i]))
					count ++;
			}
		}
		if(isSingle) {
			if(count == 1) 
				return true;
			else {
				alert(dataGroup.errMsg);
				formx[dataGroup.nameAy[0]].focus();
				return false;
			}
		}
		else {
			if(count >= 1)
				return true;	
			else {
				alert(dataGroup.errMsg);
				formx[dataGroup.nameAy[0]].focus();
				return false;
			}
		}
	}
	return true;
}

/*
 * 檢查在一組 dataGroup下所核取的radio方塊的數目，假如符合條件則true，反之則false。
 * @ param destName	    欲驗證的元素名稱
 * @ param formx			form物件
 * @ param msg				錯誤訊息
 * @ param dataGroup	欲驗證的資料集合
 */
function validateRadioCount(destName,formx,msg,dataGroup) {
	var count = 0;
	var isGoValidate = true;
	//2004/09/06 08:30上午增加
	if(dataGroup != null && dataGroup.head != null) {
		if(!parseStrToObj(dataGroup.head,formx).checked) 
			isGoValidate = false;
	}
	if(isGoValidate) {
		for(var i = 0; i < formx[destName].length; i ++) {
			if(formx[destName][i].checked) {
				count ++;
				break;
			}
		}
		if(count == 0) {
			alert(msg);
			formx[destName][0].checked = 'true';
			if(dataGroup != null)
				checkboxFactory(formx[destName][0].checked,destName+"$0",formx);
			return false;
		}
	}
	return true;
}

/*
 * 檢查在一組 dataGroup下的checkbox方塊有沒有核取。
 * @ param isChecked	是否核取了
 * @ param groupName	資料群組頭名稱
 * @ param formx			form物件
 */
function validateCheckboxGroup(isChecked,groupName,formx) {
	if(isChecked) {
		var obj = eval(groupName+"_Group");
		for(var i = 0; i < obj.nameAy.length; i ++) {
			if(typeof obj.nameAy[i] == "object") {
				//validateCheckboxGroup(formx[obj.nameAy[i].head].checked,obj.nameAy[i].head,formx);
				validateCheckboxGroup(parseStrToObj(obj.nameAy[i].head,formx).checked,obj.nameAy[i].head,formx);
			}
			else {
				/*
				 * 未加判斷radio之前2004/9/3 11:30上午
				if(formx[obj.nameAy[i]].type != "checkbox") 
					formx[obj.nameAy[i]].style.backgroundColor = "#FFFFFF";				
				formx[obj.nameAy[i]].disabled = '';
				*/
				
				if(parseStrToObj(obj.nameAy[i],formx).type == "text") 
					formx[obj.nameAy[i]].style.backgroundColor = "#FFFFFF";				
				parseStrToObj(obj.nameAy[i],formx).disabled = '';
			}
		}
	}
	else {
		checkboxFactory(false,groupName,formx) ;
	}
}

/*
 * 是enableCheckboxGroup()及disableCheckboxGroup()的factory。
 * @ param isChecked	是否核取了
 * @ param groupName	資料群組頭名稱
 * @ param formx			form物件
 */
function checkboxFactory(isChecked,groupName,formx) {
	if(isChecked)
		enableCheckboxGroup(groupName,eval(groupName+"_Group"),formx);
	else
		disableCheckboxGroup(groupName,eval(groupName+"_Group"),formx);
}

/*
 * 是enableCheckboxGroup()及disableCheckboxGroup()的factory。
 * @ param groupName	資料群組頭名稱
 * @ param formx			form物件
 */
function radioFactory(groupName,formx) {
	var len = formx[groupName].length;
	for(var i = 0; i < len; i ++) {
		try {
			if(formx[groupName][i].checked) 
				enableCheckboxGroup(groupName,eval(groupName+"$"+i+"_Group"),formx);
			else 
				disableCheckboxGroup(groupName,eval(groupName+"$"+i+"_Group"),formx);
		}
		catch(e){}//doNothing
	}
}

/*
 * 檢查在一組 dataGroup下enable所有的form element，如果此dataGroup的element本身亦是
 * dataGroup則不向下做處理。
 * @ param groupName	資料群組頭名稱
 * @ param dataGroup	欲驗證的資料集合
 * @ param isChecked	是否在enable之後要把checkbox核取
 * @ param formx			form物件
 */
function enableCheckboxGroup(groupName,dataGroup,formx) {
	var isFocus = false;
	for(var i = 0; i < dataGroup.nameAy.length; i ++) {
		if(typeof dataGroup.nameAy[i] != "object") {
			//formx[dataGroup.nameAy[i]].disabled = '';
			parseStrToObj(dataGroup.nameAy[i],formx).disabled = '';
			/*
			 * 未加判斷radio之前2004/9/3 11:30上午
			if(formx[dataGroup.nameAy[i]].type == "text") {
				if(!isFocus) {
					formx[dataGroup.nameAy[i]].focus();
					isFocus = true;
				}
				formx[dataGroup.nameAy[i]].style.backgroundColor = "#FFFFFF";
			}
			*/
			if(parseStrToObj(dataGroup.nameAy[i],formx).type == "text") {
				if(!isFocus) {
					formx[dataGroup.nameAy[i]].focus();
					isFocus = true;
				}
				formx[dataGroup.nameAy[i]].style.backgroundColor = "#FFFFFF";
			}
		}
	}
}

/*
 * 檢查在一組 dataGroup下enable所有的form element，如果此dataGroup的element本身亦是
 * dataGroup則向下做處理。
 * @ param groupName	資料群組頭名稱
 * @ param dataGroup	欲驗證的資料集合
 * @ param formx			form物件
 */
function disableCheckboxGroup(groupName,dataGroup,formx) {
	for(var i = 0; i < dataGroup.nameAy.length; i ++) {
		if(typeof dataGroup.nameAy[i] != "object") {
			/*
			 * 未加判斷radio之前2004/9/3 11:30上午
			if(formx[dataGroup.nameAy[i]].type == "text")
				formx[dataGroup.nameAy[i]].style.backgroundColor = "#C0C0C0";
			else
				formx[dataGroup.nameAy[i]].checked = '';
			formx[dataGroup.nameAy[i]].disabled = 'true';
			*/
			if(parseStrToObj(dataGroup.nameAy[i],formx).type == "text")
				formx[dataGroup.nameAy[i]].style.backgroundColor = "#C0C0C0";
			else
				parseStrToObj(dataGroup.nameAy[i],formx).checked = '';
			parseStrToObj(dataGroup.nameAy[i],formx).disabled = 'true';
		}
		else 
			disableCheckboxGroup(groupName,dataGroup.nameAy[i],formx);
	}
}

/*
 * 解析此物件名是否是radio還是其他物件類型名稱，如果是radio的物件名稱必須要做處理。
 * @ param objStr	名稱
 * @ param formx	form物件
 */
function parseStrToObj(objStr,formx) {
	if(objStr.indexOf("$") > 0) {
		var idx = objStr.substring(objStr.indexOf("$")+1,objStr.length);
		if(formx != null)
			return formx[objStr.substring(0,objStr.indexOf("$"))][idx];
	}
	else {
		if(formx != null)
			return formx[objStr];
		return objStr;
	}
}

//辨識用數字
var currentVal = 0;
//運算的型態: > , < , == , <= , >= , !=
var opType = 3;

/*
 * 設定currentVal及opType的值，用來判斷輸入數字的大小條件。
 * @ param val	數值
 * @ param op	運算子型態
 */
function setArgs(val,op) {
	currentVal = val;
	opType = op;
}

/*
 * 重設定currentVal及opType的值，用來判斷輸入數字的大小條件。
 */
function reSetArgs() {
	currentVal = 0;
	opType = 3;// <=
}

function judgeNum(val) {
	if(isNaN(val))
		opType = -1;
	switch(opType) {
		case 0 :
			return (val > currentVal);
		case 1 :
			return (val < currentVal);
		case 2 :
			return (val == currentVal);
		case 3 :
			return (val <= currentVal);
		case 4 :
			return (val >= currentVal);
		case 5 :
			return (val != currentVal);
		default :
			return false;
	}
}

function focusEleName(name,formx) {
	if(formx[name].type == "text") {
		formx[name].focus();
	}
}

function validateInteger(val,name,formx) {
	if(val != "") {
		if(isNaN(val) | judgeNum(val)) {
			formx[name].style.backgroundColor = "#C0C0C0";
			alert("請輸入數字或是大於"+currentVal+"的數字");
			formx[name].select();
			formx[name].focus();
			return false;
		}
		else {
			formx[name].style.backgroundColor = "#FFFFFF";
			return true;
		}
	}
	else {
		formx[name].style.backgroundColor = "#FFFFFF";
		return true;	
	}
}

function validateIntegerZero(val,name,formx) {
	if(val != "") {
		if(isNaN(val)) {
			formx[name].style.backgroundColor = "#C0C0C0";
			alert("請輸入數字或是大於等於"+currentVal+"的數字");
			formx[name].select();
			formx[name].focus();
			return false;
		}
		else {
			formx[name].style.backgroundColor = "#FFFFFF";
			return true;
		}
	}
	else {
		formx[name].style.backgroundColor = "#FFFFFF";
		return true;	
	}
}

function validateIntRange(val,name,formx,lowVal,highVal) {
	if(validateInteger(val,name,formx)) {
		if(val > highVal || val < lowVal) {
			formx[name].style.backgroundColor = "#C0C0C0";
			alert("請輸入的數字介於"+lowVal+"~"+highVal+"之間");
			formx[name].select();
			formx[name].focus();
			return false;
		}
		return false;
	}
}
function validateDate(val,name,formx){
	if(val != "") {
		var d;
		if((val.match(/^(\d{2})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((val.match(/^(\d{3})(\d{2})(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((val.match(/^(\d{2})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
		if((val.match(/^(\d{3})\/(\d{2})\/(\d{2})$/))) d = new Date((eval(RegExp.$1)+1911)+"/"+RegExp.$2+"/"+RegExp.$3);
	
		if(!d || d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3){
			formx[name].style.backgroundColor = "#C0C0C0";
			alert("請輸入民國年日期");
			formx[name].select();
			formx[name].focus();
			return false;
		}
		else {
			formx[name].style.backgroundColor = "#FFFFFF";
			return true;
		}
	}
	else {
		formx[name].style.backgroundColor = "#FFFFFF";
		return true;	
	}
}
