/**
 *  version: 20130221001
 *
 *       Date         Author                                                    Description
 *  ==============  ==========  ==============================================================================================================
 *    2004/03/30      林秉毅      增加 submitToUpper
 *    2005/05/19      IBM         增加 submitOnce、enableElements
 *    2005/06/10      IBM         修改 submitOnce
 *    2005/06/13      laycf       修改 disableButton
 *    2007/01/10                  增加 keyWordReplaceFullSpace、replaceFullSpace、trimSpace、showHintBox、hideHintBox、formatCurrency
 *    2012/04/19      劉本傑      交易效能檢測機制導入相關異動
 *
 *       public function                                                        Description
 *  =========================   =============================================================================================================
 *    submitToUpper               給 submit 時小寫轉大寫用。
 *    addPrefix                   將欄位前補 prestr 成長度 length 的字串。
 *    MoneyFormat                 轉成 MONEY 格式 123,456,789。
 *    DateFormat                  民國年轉成格式 92.01.01。
 *    disableButton               防止重複 submit。
 *    enableButton                將指定 form 中所有的 submit 及 reset type 的 button enable。
 *    copyKey                     將畫面主要查詢條件複製。
 *    stat                        固定畫面 MainTitle。
 *    fix                         固定畫面。
 *    timeForTextfield            轉換 DB 時間格式為 hhmmss。
 *    jump                        指定欄位若為達到指定長度時，則跳至下一個指定的輸入欄位
 *    submitOnce
 *    coverDocument               於指定之物件上加上 coverPage
 *    enableElements
 *    keyWordReplaceFullSpace     將全型空白以空字串取代，只要 text、hidden 包含 keyWord (ex : NAME , ADDRESS.....)，就會針對該欄位執行去除全型空白的功能
 *    replaceFullSpace            將全型空白以空字串取代，只要是 text、hidden 的型態，就會執行去除全型空白
 *    trimSpace                   去除輸入參數的右側空白，將 text、hidden 的型態的欄位，去除右側的空白
 *    showHintBox
 *    hideHintBox
 *    formatCurrency
 *
 **/

var _utilitySubmitOnceCoverPage;
var _utilitySubmitOnceButton;

/**
 * @public
 * @class 給 submit 時小寫轉大寫用。 <br>
 *        注意事項：
 *        1. EMail欄位不做轉換，欄位名稱請以EMAIL開頭為區別。 <br>
 *           例如:EMAIL,EMAIL1,EMAIL_HOME。 <br>
 *        2. 屬性「autoToUppercase」設定為 false 時，不進行轉換 <br>
 * @param formx (Object) : 指定的 form 物件。
 **/
function submitToUpper(element) {
    //傳入參數非DOM物件或Fragment
    if (!element || !(element.nodeType === 1 || element.nodeType === 11)) { return false; }
    var inputs = element.getElementsByTagName('input');
    for (var i = 0; i < inputs.length ; i++) {
    	var ele = inputs[i];
        if ((ele.getAttribute('type') || '').toLowerCase() != 'text' || (ele.getAttribute('autoToUppercase')==='false')) { continue; }
        //2004/04/01林秉毅－EMail欄位不做轉換，欄位名稱請以EMAIL開頭還區別
        if (/^EMAIL/i.test(ele.getAttribute('name')) || /^EMAIL/i.test(ele.getAttribute('id'))) { continue; }
        ele.value = ele.value.toUpperCase();
    }
    return true;
}
//===========================================================================
/**
 * 將欄位前補prestr成長度length的字串。 <br>
 * 例； A='5' ->addprefix(A,5,'0')->A='00005'。 <br>
 *
 */
function addPrefix(str, len, prestr) {
    len = parseInt(len, 10);
    str = str + '';
    while (str.length < len) { str = prestr + '' + str; }
    return str + '';
}

//===========================================================================
/**
 * 轉成MONEY格式123,456,789。 <br>
 */
function MoneyFormat(inputString) {
    var objType = typeof (inputString);
    if (!(objType === 'number' || (objType === 'string' && (/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(inputString))))) {
        return inputString;
    }
    var lenPoint = 0;
    var isNeg = false;
    var string_int = '';
    var string_float = '';
    if (!inputString) { return inputString === 0 ? '0' : ''; }
    inputString = inputString + '';

    isNeg = inputString.indexOf('-') == 0;
    lenPoint = inputString.indexOf('.');
    var stringToBigNumber = function (inputString) {
        inputString = inputString + '';
        var reg = /\d+/g;
        var integers = inputString.match(reg);
        if (!integers) { return '0'; }
        var output = ''
        for (var i = 0 ; i < integers.length ; i++) {
            output = output + '' + integers[i];
        }
        return output || 0;
    };

    if (lenPoint > 0) {
        string_int = stringToBigNumber(inputString.substring(0, lenPoint));
        string_float = stringToBigNumber(inputString.substring(lenPoint + 1, inputString.length));
        lenPoint = true;
    } else {
        string_int = stringToBigNumber(inputString);
        lenPoint = false;
    }

    while (string_int.length % 3 != 0) {
        string_int = '0' + string_int;
    }

    var reg = /\d{3}/g;
    var integers = string_int.match(reg);
    var output = ''
    for (var i = 0 ; i < integers.length ; i++) {
        var _int = integers[i];
        if (i === 0) {
            if (_int === 0) {
                continue;
            }
            _int = parseInt(integers[i], 10);
        }
        output = output + '' + _int + ',';
    }
    output = output.substring(0, output.length - 1);

    if (isNeg) { output = '-' + output; }
    if (lenPoint) { output = output + '.' + string_float; }
    return output;
}

//===========================================================================
/**
 * 轉成DATE格式。 <br>
 * 範例：92.01.01。 <br>
 */
function DateFormat(strDate) {
    var Tempstr = '_' + strDate;
    var TextString = '';
    var IntCommon = 0;
    for (var i = 0; i < Tempstr.length - 1 ; i++) {
        if (IntCommon == 2 && i < 6) {
            IntCommon = 0;
            TextString = '.' + TextString;
        }
        IntCommon = IntCommon + 1;
        TextString = Tempstr.charAt(Tempstr.length - 1 - i) + TextString;
    }
    return TextString
}

/**
 * 轉換 DB 時間格式為 hhmmss。 <br>
 * 如：hh:mm:dd >> hhmmss。 <br>
 */
function timeForTextfield(timevalue) {
    if (timevalue) {
        var timeArray;
        if (timevalue.indexOf(':') >= 0) {
            timeArray = timevalue.split(':');
        } else if (timevalue.indexOf('.') >= 0) {
            timeArray = timevalue.split('.');
        } else {
            return timevalue;
        }
        // 組合 ，若數字長度不足2，前面會先補零
        timevalue = '';
        for (var index = 0; index < timeArray.length; index++) {
            var value = parseInt(timeArray[index], 10) + '';
            while (value.length < 2) { value = '0' + value; }
            timevalue = timevalue + value;
        }
        //長度若大於6，則取到6位(去除毫秒)，若不足6位則後面加上0
        if (timevalue.length > 6) {
            timevalue = timevalue.substr(0, 6);
        } else {
            while (timevalue.length < 6) { timevalue = timevalue + '0'; }
        }
    } else {
        return '';
    }
    return timevalue;
}

//=================================================================================================
/**
 * 複製畫面主要查詢條件。 <br>
 *
 * 欄位需為hidden，欄位名稱為K_+主要查詢欄位)。 <br>
 */
function copyKey(formx) {
    //將查詢條件保留??
    for (var j = 0; j < formx.elements.length; j++) {
        checkName = formx.elements[j].name;
        checkName12 = (checkName.length > 1 ? checkName.substring(0, 2) : checkName);
        if (checkName12.toUpperCase() == 'K_') {
            originName = (checkName.length > 1 ? checkName.substring(2, checkName.length) : '');
            formx.elements[checkName].value = formx.elements[originName].value;
        }
    }
}

/**
 * 固定畫面MainTitle。 <br>
 */
function stat() {
    fix();
    setTimeout(stat, 2);
}

/**
 * 固定畫面。 <br>
 */
function fix() {
    var bar1Obj = document.getElementById('bar1') || (document.all ? document.all.bar1 : null);
    if (!bar1Obj) { return; }
    bar1Obj.style.top = ((document.body.scrollTop - bar1Obj.offsetHeight + 30) || 0) + 'px';
}

/**
 * 跳格。 <br>
 */
function jump(current_element, next_element, len) {
    if (!current_element || current_element.nodeType !== 1) { return; }
    if (!next_element || next_element.nodeType !== 1) { return; }
    if (current_element.value.length == len) {
        next_element.focus();
    }
}

function uncoverDocument(doc){
	try{
	doc = doc || document;
	var cover = doc.getElementById('utility_frontCover');
	if (cover) {
	    cover.style.display = 'none';
	    if (doc.parentWindow._utilitySubmitOnceCoverPage) {
	        doc.parentWindow._utilitySubmitOnceCoverPage = null;
	    }
	}
	if(doc.parentWindow._utilitySubmitOnceButton){
		doc.parentWindow._utilitySubmitOnceButton.disabled = false;
		doc.parentWindow._utilitySubmitOnceButton = null;
	}
	}catch(e){
		window.console && console.log("[ERROR][utility uncoverDocument] execute error." + e);
	}
}

function coverDocument(doc) {
    doc = doc || document;

    var cover = doc.getElementById('utility_frontCover');

    if (!cover) {
        cover = doc.createElement('div');
        cover.id = 'utility_frontCover';
    }
    cover.style.display = 'block';
    cover.style.background = '#FFF';
    cover.style.opacity = '0.25';
    cover.style.filter = 'alpha(opacity=25)';
    cover.style.position = 'absolute';
    cover.style.cursor = 'progress';
    cover.style.left = '0px';
    cover.style.top = '0px';
    cover.style.width = '100%';
    cover.style.height = '100%';
    cover.style.zIndex = 9999;

    var docBody = doc.body;
    doc.body.appendChild(cover);
    cover.style.width = Math.max(cover.offsetWidth, docBody.scrollWidth) + 'px';
    cover.style.height = Math.max(cover.offsetHeight, docBody.scrollHeight) + 'px';

    return cover;
}

/**
 * @public
 * @class 防止重複submit <br>
 * @param submitOnce(element, openWindow)
 * @param element 任意form下元素或form元素
 * @param openWindow 是否為開新視窗? 若是，將不會產生cover
 **/
function submitOnce(button, openWindow, coverOnly) {
    if (!button || button.nodeType !== 1) { window.console && console.log('[ERROR][utility submitOnce] button is not a element, cancel function.'); return; }
    var form = button;
    while (form.tagName.toUpperCase() != 'FORM') {
        form = form.parentNode;
        if (form.tagName == 'BODY') { window.console && console.log('[ERROR][utility submitOnce] button cant found parentNode "form".'); return; }
    }

    _utilitySubmitOnceButton = null;

    try {
        var doc = button.ownerDocument || document;

        var form_target = (form.getAttribute('target') || '').replace(/\s/g, '').toLowerCase();

        // target是有意義的值，且target不為 _self , _top , _parent , _blank
        var isLoadToFrame = false;
        if (!openWindow && form_target && !(/^_/.test(form_target))) {
            var frames = document.getElementsByTagName('frame')
            for (var i = 0; frames && i < frames.length; i++) {
                var frame = frames[i];
                var frame_name = (frame.getAttribute('name') || '').replace(/\s/g, '').toLowerCase();
                if (form_target == frame_name) {
                    frame.frameElement.onreadystatechange = function () {
                        if (this.readyState == 'complete') {
                            if (_utilitySubmitOnceCoverPage) { _utilitySubmitOnceCoverPage.style.display = 'none'; }
							if (_utilitySubmitOnceButton) { _utilitySubmitOnceButton.disabled = false; }
                            _utilitySubmitOnceCoverPage = null;
                            _utilitySubmitOnceButton = null;
                        }
                    }
                    frames = false;
                    isLoadToFrame = true;
                    break;
                }
            }
            if (frames !== false) {
                frames = document.getElementsByTagName('iframe')
                for (var i = 0; frames && i < frames.length; i++) {
                    var frame = frames[i];
                    var frame_name = (frame.getAttribute('name') || '').replace(/\s/g, '').toLowerCase();
                    if (form_target == frame_name) {
                        var loaded_function = function () {
                            if (_utilitySubmitOnceCoverPage) { _utilitySubmitOnceCoverPage.style.display = 'none'; }
                            if (_utilitySubmitOnceButton) { _utilitySubmitOnceButton.disabled = false; }
                            _utilitySubmitOnceCoverPage = null;
                             _utilitySubmitOnceButton = null;
                        };
                        if (frame.addEventListener) {
                            frame.addEventListener("load", loaded_function);
                        } else if (frame.attachEvent) {
                            frame.attachEvent("onload", loaded_function);
                        } else {
                            frame.onload = loaded_function;
                        }
                        isLoadToFrame = true;
                        break;
                    }
                }
            }
        }

        var action_target = form.getAttribute('action')+'-'+form.getAttribute('target');
        if (!_utilitySubmitOnceCoverPage && !openWindow && form_target != '_blank') {
            if(!!form.getAttribute('already-submit') == action_target){
                 if (window.console){
                    window.console.log('[log][utility submitOnce] '+action_target+' already submited! ');
                }
                return;
            }
            _utilitySubmitOnceCoverPage = coverDocument(doc);
        }

        utility.overrideSubmitByForm(form);
        form.setAttribute('already-submit', action_target);

        var is_btn = false;
        var btn_value = '';
        if (button.tagName == 'BUTTON') {
            is_btn = true;
            btn_value = button.textContent || button.innerHTML || '';
        } else if (button.tagName == 'INPUT' && (button.getAttribute('type') || '').toLowerCase() == 'button') {
            is_btn = true;
            btn_value = button.getAttribute('value');
        }

        if (is_btn) {
            var btn_id = button.getAttribute('id');
            var btn_name = button.getAttribute('name');
            // 移除btnName，改成id屬性
            if (btn_name) {
                if (!btn_id) {
                    button.setAttribute('id', btn_name);
                }
                button.removeAttribute('name');
            } else {
                btn_name = btn_id || 'submitOnce';
            }

            //附加此次action名稱
            var field = doc.createElement('input');
            field.setAttribute('type', 'hidden');
            field.setAttribute('name', btn_name);
            field.setAttribute('submitName', btn_name);
            field.setAttribute('value', btn_value);
            form.appendChild(field);

            //將此BTN設為失效避免再度重複送出
            button.disabled = true;
            _utilitySubmitOnceButton = button;
        }
        if (window.console){
            window.console.log('[log][utility submitOnce] ' + btn_value);
            window.console.log(form);
        }

    } catch (e) {
        window.console && console.log('[ERROR][utility submitOnce] Exception: ' + e);
    }
    if (coverOnly === true) { return; }
    if (form.dispatchEvent) {
        var event = document.createEvent("HTMLEvents");
        event.initEvent("submit", true, false);
        form.dispatchEvent(event);
    } else {
        form.submit();
    }
}

/**
 * @public
 * @class 防止重複submit <br>
 * @param disableButton(element)
 * @param element 任意form下元素或form元素
 **/
function disableButton(theform) {
    submitOnce(theform, false, true);
}

/**
 * 將指定 form 中所有的 submit 及 reset type 的 button enable。 <br>
 */
function enableButton(theform) {
    if (document.all || document.getElementById) {
        /* 取出指定 form 中所有的 submit 及 reset type 的 button disable 掉 */
        for (var i = 0; i < theform.length; i++) {
            var tempobj = theform.elements[i]
            if (tempobj.type.toLowerCase() == 'submit' || tempobj.type.toLowerCase() == 'button') {
                tempobj.disabled = false;
            }
        }
    }
    if(!!theform.getAttribute('already-submit')){
        theform.setAttribute('already-submit', '');
    }
}


//enable elements
function enableElements(elems) {
    var arry = elems.split(',');
    for (var i = 0; i < arry.length; i++) {
        var e = document.getElementById('' + arry[i]);
        if (e) {
            if (e.type.toLowerCase() == 'text') {
                e.readOnly = false;
            } else {
                e.disabled = false;
            }
        }
    }
}

/**
*將全型空白以空字串取代 , 只要 text , hidden 包含 keyWord (ex : NAME , ADDRESS.....),
*就會針對該欄位執行去除全型空白的功能 ,
*text name='AGENT_NAME' 有包含 keyWord
*'　小青蛙' ->'小青蛙'
*'小　青蛙' ->'小青蛙'
*'小青蛙　' ->'小青蛙'
*'　小　青　蛙　' ->'小青蛙'
*傳入 任意DOM元素
*傳入 關鍵字
*傳入 是否要無視大小寫(預設為否)
*/
function keyWordReplaceFullSpace(frm, keyWord, ingornCase) {
    if (!frm || frm.nodeType !== 1) { return; }
    var keyWordExp = keyWord ? new RegExp((keyWord+'').toUpperCase() , ingornCase ? 'i':'' ) : null;
    //找出頁面上所有的element
    var inputs = frm.getElementsByTagName('input');
    for (var i = 0; inputs && i < inputs.length; i++) {
        var ele = inputs[i];
        //若是 text 或是 hidden 才要處理
        var type = (ele.getAttribute('type') || '').toLowerCase();
        if (type != 'text' && type != 'hidden') { continue;}
        //若是有關鍵字才要作處理
        if (keyWordExp && !keyWordExp.test(ele.name || '')) { continue; }
        //將全型空白以空字串取代
        ele.value = ele.value.replace(/　/g, '');
    }
}

/**
*將全型空白以空字串取代 ,
*只要是 text , hidden 的型態
*就會執行去除全型空白 ,
*傳入 form
*'　小青蛙' ->'小青蛙'
*'小　青蛙' ->'小青蛙'
*'小青蛙　' ->'小青蛙'
*'　小　青　蛙　' ->'小青蛙'	　
*/
function replaceFullSpace(frm) {
    keyWordReplaceFullSpace(frm);
}

/**
 * @public
 * @class 去除輸入參數的右側空白，將 text、hidden 的型態的欄位，去除右側的空白 <br>
 *	       清除範例 : 'aa ' -> 'aa' <br>
 *	                  ' a ' -> ' a' <br>
 *	                  'aaa' -> 'aaa'<br>
 * @param frm (Form)
 **/
function trimSpace(frm) {
    if (!frm || frm.nodeType !== 1) { return; }
    var inputs = frm.getElementsByTagName('input');
    for (var i = 0; inputs && i < inputs.length; i++) {
        var ele = inputs[i];
        //若是 text 或是 hidden 才要處理
        var type = (ele.getAttribute('type') || '').toLowerCase();
        if (type != 'text' && type != 'hidden') { continue;}
        ele.value = ele.value.replace(/\s*\s$/, '');
    }
}

// show hide the hint box text
function showHintBox(bID) {
    var box = document.getElementById(bID);
    if (!box) { return };
    var style = box.style;
    style.left = event.x + document.body.scrollLeft;
    style.top = event.y + document.body.scrollTop + 10;
    style.visibility = 'visible';
}

function hideHintBox(bID) {
    var box = document.getElementById(bID);
    if (!box) { return };
    box.style.visibility = 'hidden';
}

function formatCurrency(num) {
    num = num.toString().replace(/\$|\,/g, '');
    if (isNaN(num)) { num = '0'; };
    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num * 100 + 0.50000000001);
    cents = num % 100;
    num = Math.floor(num / 100).toString();
    if (cents < 10) { cents = '0' + cents; }
    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3) ; i++) { num = num.substring(0, num.length - (4 * i + 3)) + ',' + num.substring(num.length - (4 * i + 3)); }
    return (((sign) ? '' : '-') + num + '.' + cents);
}

function createUtility() {

    var inputFiled_eBAF_UserObject_Flag;
    var inputFiled_eBAF_loginSystemInfo;
    var inputRequestTimeField;

    function hasDateJs() {
        return window.dateJs && dateJs.getCurrentTimeStamp;
    }

    function overrideSubmit() {
        try {
            //是否為檔案上傳
            var isMultipartContent = this.encoding == 'multipart/form-data';

            var eBAF_loginSystemInfo = top['eBAF_loginSystemInfo'];
            var eBAF_UserObject_Flag = top['eBAF_UserObject_Flag'];

            var add_eBAF_loginSystemInfo = !!eBAF_loginSystemInfo;
            var add_eBAF_UserObject_Flag = !!eBAF_UserObject_Flag;

            if (isMultipartContent) {

                var formAction = this.action;
                if (add_eBAF_loginSystemInfo && !formAction.match(/[?&]eBAF_loginSystemInfo=/)) {
                    formAction += (formAction.indexOf('?') > 0 ? '&' : '?') + 'eBAF_loginSystemInfo=' + eBAF_loginSystemInfo;
                }
                if (add_eBAF_UserObject_Flag && !formAction.match(/[?&]eBAF_UserObject_Flag=/)) {
                    formAction += (formAction.indexOf('?') > 0 ? '&' : '?') + 'eBAF_UserObject_Flag=' + eBAF_UserObject_Flag;
                }
                this.action = formAction;

            } else {

                // requestTimeField 只有在包含date.js、並且target為更新本頁而非開新視窗時使用
                var add_requestTimeField =  ( hasDateJs() && ( !this.getAttribute('target') || ( this.getAttribute('target').toLowerCase() != '_blank' && this.getAttribute('target').toLowerCase() != '_top')));

                var sub_inputs =  this.getElementsByTagName('input');
                for(var i = 0 ; i < sub_inputs.length ; i++ ){
                    var input_name = sub_inputs[i].getAttribute('name') || '';
                    var input_submitName = sub_inputs[i].getAttribute('submitName') || '';

                    add_eBAF_loginSystemInfo = add_eBAF_loginSystemInfo && input_name != 'eBAF_loginSystemInfo' && input_submitName != 'eBAF_loginSystemInfo';
                    add_eBAF_UserObject_Flag = add_eBAF_UserObject_Flag && input_name!= 'eBAF_UserObject_Flag' && input_submitName != 'eBAF_UserObject_Flag';
                    add_requestTimeField = add_requestTimeField && input_name != 'requestTimeField' && input_submitName != 'requestTimeField';

                    if(!add_eBAF_loginSystemInfo && !add_eBAF_UserObject_Flag && !add_requestTimeField){ break; }
                }
                if (add_eBAF_loginSystemInfo) {
                    if (!inputFiled_eBAF_loginSystemInfo) {
                        inputFiled_eBAF_loginSystemInfo = document.createElement('input');
                        inputFiled_eBAF_loginSystemInfo.setAttribute('type', 'hidden');
                        inputFiled_eBAF_loginSystemInfo.setAttribute('name', 'eBAF_loginSystemInfo');
                        inputFiled_eBAF_loginSystemInfo.setAttribute('submitName', 'eBAF_loginSystemInfo');
                        inputFiled_eBAF_loginSystemInfo.setAttribute('value', eBAF_loginSystemInfo);
                    }

                    this.appendChild(inputFiled_eBAF_loginSystemInfo);
                }

                if (add_eBAF_UserObject_Flag) {
                    if (!inputFiled_eBAF_UserObject_Flag) {
                        inputFiled_eBAF_UserObject_Flag = document.createElement('input');
                        inputFiled_eBAF_UserObject_Flag.setAttribute('type', 'hidden');
                        inputFiled_eBAF_UserObject_Flag.setAttribute('name', 'eBAF_UserObject_Flag');
                        inputFiled_eBAF_UserObject_Flag.setAttribute('submitName', 'eBAF_UserObject_Flag');
                        inputFiled_eBAF_UserObject_Flag.setAttribute('value', eBAF_UserObject_Flag);
                    }

                    this.appendChild(inputFiled_eBAF_UserObject_Flag);
                }

                if(add_requestTimeField){
                    if(!inputRequestTimeField){
                        inputRequestTimeField = document.createElement('input');
                        inputRequestTimeField.setAttribute('type','hidden');
                        inputRequestTimeField.setAttribute('name', 'requestTimeField');
                        inputRequestTimeField.setAttribute('submitName', 'requestTimeField');
                    }
                    inputRequestTimeField.setAttribute('value', dateJs.getCurrentTimeStamp() );
                    this.appendChild(inputRequestTimeField);

                    var responseTimeEndParameters = top['responseTimeEndParameters'];
                    if (responseTimeEndParameters && responseTimeEndParameters.length > 0) {
                        for (var i = 0; i < responseTimeEndParameters.length; i++) {
                            var responseTimeEndParameter = responseTimeEndParameters[i];

                            var inputRequestTimeEndUUID = document.createElement('input');
                            inputRequestTimeEndUUID.setAttribute('type','hidden');
                            inputRequestTimeEndUUID.setAttribute('name', 'requestTimeEndUUID');
                            inputRequestTimeEndUUID.setAttribute('submitName', 'requestTimeEndUUID');
                            inputRequestTimeEndUUID.setAttribute('value', responseTimeEndParameter['UUID']);
                            this.appendChild(inputRequestTimeEndUUID);

                            var inputRequestTimeEndField = document.createElement('input');
                            inputRequestTimeEndField.setAttribute('type','hidden');
                            inputRequestTimeEndField.setAttribute('name', 'requestTimeEndField');
                            inputRequestTimeEndField.setAttribute('submitName', 'requestTimeEndField');
                            inputRequestTimeEndField.setAttribute('value',responseTimeEndParameter['requestTimeField']);
                            this.appendChild(inputRequestTimeEndField);
                        }
                        top['responseTimeEndParameters'] = [];
                    }
                }
            }

        } catch (e) {
            window.console && console.log('[ERROR][utility overrideSubmit] Exception: ' + e);
        }
        if (this._originalSubmit) {
            this._originalSubmit();
        }
    }

    /**
	 * @public
	 * @class override submit event by form <br>
	 * @param form
	 **/
    function overrideSubmitByForm(theForm) {
        try{
            if(!theForm){
                return;
            }
            if (theForm.getAttribute('submit_rewrited')) {
                return;
            }
            if (!theForm.submit || theForm.submit.tagName) {
                window.console && window.console.log('[ERROR][utility overrideSubmitByForm] overeide object error');
                window.console && window.console.log(theForm);
                return;
            }
            var originalSubmit = theForm.submit;
            theForm._originalSubmit = originalSubmit;
            theForm.submit = overrideSubmit;

            if (window.addEventListener) {
                theForm.addEventListener('submit', overrideSubmit);
            }

            theForm.setAttribute('submit_rewrited', 'Y');
         } catch (e) {
            window.console && console.log('[ERROR][utility overrideSubmitByForm] Exception: ' + e);
        }
    }
    this.overrideSubmitByForm = overrideSubmitByForm;

    function registerOnloadFunction() {
        try {
            uncoverDocument(window.parent.document);
        } catch (e) {
        	window.console && console.log("[ERROR][utility uncoverDocument] Exception: " + e + ", try to use default to uncover document.");
        	try {
	            uncoverDocument();
	        } catch (e) {
	        	window.console && console.log("[ERROR][utility uncoverDocument] Exception: " + e + ", local document faild to.");
	        }
        }
        var theForms = document.getElementsByTagName('form');
        for (var i = 0; i < theForms.length; i++) {
            var theForm = theForms[i];
            overrideSubmitByForm(theForm);
        }

		if(!document._originalGetElementById){

			var isOverwriteFunction_getElementById = true;

			try{

				var isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");
				var docModeIE;
				if(isIE){
					var userAgentStrings = navigator.userAgent;
					var verIE_ua = (/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(userAgentStrings || "") ? parseFloat(RegExp.$1, 10) : null;
					var verIEtrue;
					try { verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
					// Get true IE version using clientCaps.
					var obj = document.createElement("div");
					// Array of classids that can give us the IE version
					var CLASSID = [
						"{45EA75A0-A269-11D1-B5BF-0000F8051515}", // Internet Explorer Help
						"{3AF36230-A269-11D1-B5BF-0000F8051515}", // Offline Browsing Pack
						"{89820200-ECBD-11CF-8B85-00AA005B4383}"
					];
					try{obj.style.behavior = "url(#default#clientcaps)"}catch(e){};

					for(var x = 0; x < CLASSID.length; x++){
						try { verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
						if (verIEtrue) break;
					};
					docModeIE = document.documentMode || ((/back/i).test(document.compatMode || "") ? 5 : parseFloat(verIEtrue || "0", 10)) || verIE_ua;
				}

				if(!isIE || docModeIE==10){
					var pageFrameJS = /PageFrame\.js(\?.*)?$/;
					var includeScripts = document.getElementsByTagName('script');
					//set up the images base by web path
					if(includeScripts.length>0){
						for(var i=0;i<includeScripts.length;i++){
							var scriptSrc = includeScripts[i].src;
							if(scriptSrc && scriptSrc.match(pageFrameJS)){
								isOverwriteFunction_getElementById = false;
								break;
							}
						}
					}
				}

			}catch(e){
			}

			if(isOverwriteFunction_getElementById){
                if(!document.getElementById){
                    delete document.getElementById;
                }
			    document._originalGetElementById = document.getElementById;
			    document.getElementById = function (id) {
			        var ele = document._originalGetElementById ? document._originalGetElementById(id) : null;
			        if (ele) {
			            return ele;
			        }

			        var elems = document.getElementsByName(id);
			        if (elems && elems.length > 0) {
			            ele = elems[0];
			        }
			        return ele;
			    };
			}
		}
    }

    if (window.addEventListener) {
        window.addEventListener('load', registerOnloadFunction);
    } else {
        window.attachEvent('onload', registerOnloadFunction);
    }

    /**
	 * @public
	 * @class 判斷輸入鍵是否為數字按鍵 <br>
	 * @param isDot (Boolean) : 是否可輸入小數點
	 * @param isNegative (Boolean) : 是否可輸入負號
	 **/
    function keypressNumberOnly(isDot, isNegative) { return (event.keyCode >= 48 && event.keyCode <= 57) || (isNegative && event.keyCode == 45) || (isDot && event.keyCode == 46); }
    this.keypressNumberOnly = keypressNumberOnly;

    /**
	 * @public
	 * @class 判斷輸入鍵是否為正確之數值 <br>
	 * @param obj (DOM Object) : keypress當前物件
	 * @param isDot (Boolean) : 是否可輸入小數點
	 * @param isNegative (Boolean) : 是否可輸入負號
	 **/
    function keypressNumberValue(obj, isDot, isNegative) {

        var inputIsNegative = event.keyCode == 45;

        if (!((event.keyCode >= 48 && event.keyCode <= 57) || (isNegative && inputIsNegative) || (isDot && event.keyCode == 46))) {
            return false;
        }

        if (inputIsNegative) {
            if (obj.value.indexOf('-') < 0) {
                obj.value = '-' + obj.value;
            }
            return false;
        }

        if (event.keyCode == 48 && obj.value == '0') {
            return false;
        }

        if (event.keyCode == 46) {
            if (obj.value.indexOf('.') >= 0) {
                return false;
            }
            if (obj.value.length == 0) {
                obj.value = '0' + obj.value;
            }
        }

        return true;
    }
    this.keypressNumberValue = keypressNumberValue;

    /**
	 * @public
	 * @class 交易效能檢測機制導入相關異動，在?動檢測時，將回應時間保留 <br>
	 * @param uuid (String)
	 **/
    function keepResponseTimeEndParameters(uuid) {
        try {
            if (!uuid || !hasDateJs()) {
                return;
            }
            var responseTimeEndParameters;
            if (!top['responseTimeEndParameters']) {
                responseTimeEndParameters = [];
                top['responseTimeEndParameters'] = responseTimeEndParameters;
            } else {
                if (top['responseTimeEndParameters'].length == 0) {
                    top['responseTimeEndParameters'] = [];
                }
                responseTimeEndParameters = top['responseTimeEndParameters'];
            }
            responseTimeEndParameters.push({ 'UUID': uuid, 'requestTimeField': dateJs.getCurrentTimeStamp() });
        } catch (e) {
        }
    }
    this.keepResponseTimeEndParameters = keepResponseTimeEndParameters;

    this.keep_eBAF_parameter = function (opt) {
        try {
            if (!opt) {
                return;
            }
            for (var k in opt) {
                if (top[k]) { continue; }
                var v = opt[k];
                if (v == '') { continue; }
                top[k] = v;
            }
        } catch (e) {
        }
    };

    window.open = function (orgWindowOpenFunc) {
        return function (url, name, specs) {

            if (url && url.indexOf('\\') != 0) {
                try {
                    var attachQueryStringParameter = function (k) {
                        var v = top[k];
                        if (!v) { return; }
                        url += url.indexOf('?') < 0 ? '?' : '&';
                        url += k + '=' + v;
                    };
                    attachQueryStringParameter('eBAF_loginPlatformInfo');
                    attachQueryStringParameter('eBAF_loginSystemInfo');
                    attachQueryStringParameter('eBAF_UserObject_Flag');
                    attachQueryStringParameter('platformDispatcher');
                } catch (e) {
                }
            }
            if (name && specs) {
                return orgWindowOpenFunc(url, name, specs);
            }
            if (name) {
                return orgWindowOpenFunc(url, name);
            }
            return orgWindowOpenFunc(url);
        };
    }(window.open);

}

if (!window.utility) {
    window.utility = new createUtility();
}

var CSS_Selectors = {
    getElementByAttr:function(source, filterParams){
        var sourceList;
        var onlyOne = typeof(source) == 'object' && (source.length === undefined);
        if(onlyOne){
            sourceList = [];
            sourceList.push(source);
        }else{
            sourceList = source;
        }
        var eleList = [];
        if(sourceList && sourceList.length > 0){
            for(var i=0; i<sourceList.length; i++){
                var ele = sourceList[i];

                var getIt = true;
                for(var key in filterParams){
                    var filterParam = filterParams[key];
                    var eleAttr = ele.getAttribute(key);
                    if(typeof(filterParam) == 'object' && (filterParam instanceof Array)){
                        for(var j=0; j<filterParam.length; j++){
                            if(!CSS_Selectors.condition(eleAttr, filterParam[j])){
                                getIt = false;
                                break;
                            }
                        }

                        if(!getIt){
                            break;
                        }
                    }else{
                        if(!CSS_Selectors.condition(eleAttr, filterParam)){
                            getIt = false;
                            break;
                        }
                    }
                }

                if(getIt){
                    eleList.push(ele);
                }
            }
        }

        return onlyOne ? eleList[0] : eleList;
    },
    doActionWhenGetElement:function(source, filterParam, action){
        if(action){
            var eleList = CSS_Selectors.getElementByAttr(source, filterParam);

            if(eleList.length === undefined){
                action(eleList);
            }else{
                for(var i=0; i<eleList.length; i++){
                    var ele = eleList[i];

                    action(ele);
                }
            }
        }
    },
    condition:function(value, filterValue){
        // not equal
        if(filterValue.indexOf('ne:') === 0){
            filterValue = filterValue.substring('ne:'.length);
            return value !== filterValue;
        }

        // equal
        return value === filterValue;
    }
};

if (!window.pageSupport) {
    window.pageSupport = new (function (_func_id) {
        var FUNC_ID = _func_id;
        var getDataAlready = false;

        var outter;
        var icon_button;
        var display_window;

        var maxRetryTimes = 6;
        var testedTimes = 0;

        var isUnitType0Avalible;
        var isUnitType1Avalible;

        var msgMap = {
            iconButtonDisplay: '\u24D8',
            iconButtonTitle: '管理單位',
            defaultMsg: '查詢中，請稍後!',
            techSupporter: '資訊管理單位',
            bussinessSupporter: '業務管理單位',
            ajaxError: [
                '無法取得網址',
                '無法取得回傳資訊',
                '無法解析回傳JSON字串',
                '解析回傳JSON字串失敗',
                '回傳資訊格式錯誤',
                '取得資料失敗',
                '回傳資料格式錯誤',
                '查無資料'
            ]
        }

        var private_function = {
            create: function () {
                icon_button = document.createElement('button');
                icon_button.setAttribute('type', 'button');
                icon_button.setAttribute('id', 'icon-button');
                icon_button.setAttribute('tabindex', '-1');
                icon_button.setAttribute('title', msgMap.iconButtonTitle);
                icon_button.innerHTML = msgMap.iconButtonDisplay;
                icon_button.onclick = public_function.toggle;
                
                if(icon_button.addEventListener){
                	icon_button.addEventListener('focusout', public_function.hide);
                }else if(icon_button.attachEvent){
                	icon_button.attachEvent('onfocusout', public_function.hide);
                }else{
                	icon_button.onfocusout = public_function.hide;
                }

                display_window = document.createElement("div");
                display_window.id = 'personInChargeShowDiv';
                display_window.innerHTML = '<div class="empty-msg">' + msgMap.defaultMsg + '</div>';
                display_window.onmouseover = function (e) {
                    outter.setAttribute('keep', 'Y');
                };
                display_window.onmouseout = function () {
                    outter.setAttribute('keep', 'N');
                };

                outter = document.createElement("span");
                outter.className = "pageSupporters";
                outter.appendChild(icon_button);
                outter.appendChild(display_window);

                return outter;
            }
            , load: function () {

                if (getDataAlready) {
                    return;
                }
                getDataAlready = true;

                var getAjaxErrorMsg = function (num) {
                    return '<div class="empty-msg" onclick="pageSupport.setForceLogCookie()">' + msgMap.ajaxError[num] + '</div>';
                };

                var regAry = /(.*)\/(.{9})\/(.*)/i.exec(window.location.href); //將URL切出兩塊：1.前段URL至HttpDispatcher、2.FUNC_ID
                if (!regAry || regAry.length < 3 || !/HttpDispatcher$/i.test(regAry[1])) {
                    display_window.innerHTML = getAjaxErrorMsg(0);
                    return;
                }
                var URL = regAry[1].replace(/\/\w*\d*?Web\//, '/ZZWeb/') + '/ZZC0_0700/queryByFuncId'; //將某某Web替換成ZZWeb
                if (!FUNC_ID) {
                    FUNC_ID = (regAry[2] || '').replace('_', '');
                }

                var http = new XMLHttpRequest();
                http.open('POST', URL, true); //非同步
                http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                http.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                http.onreadystatechange = function () {
                    if (http.readyState == 4 && http.status == 200) {
                        var resp = http.responseText;
                        if (!resp) {
                            display_window.innerHTML = getAjaxErrorMsg(1);
                            return;
                        }
                        try {
                            if (window.JSON && JSON.parse) {
                                resp = JSON.parse(resp);
                            } else if (window.Prototype && "".evalJSON) {
                                resp = resp.evalJSON();
                            } else {
                                display_window.innerHTML = getAjaxErrorMsg(2);
                            }
                        } catch (e) {
                            display_window.innerHTML = getAjaxErrorMsg(3) + "<br>" + e;
                            return;
                        }

                        var isObject = function (obj) {
                            return obj && Object.prototype.toString.call(obj) === '[object Object]';
                        };
                        var isArray = function (obj) {
                            return obj && Object.prototype.toString.call(obj) === '[object Array]';
                        };

                        if (!isObject(resp)) {
                            display_window.innerHTML = getAjaxErrorMsg(4);
                            return;
                        }
                        var errMsg = resp['ErrMsg'];
                        var returnCode = isObject(errMsg) && errMsg['returnCode'];
                        var isSuccsee = (returnCode + '').match(/^-?[0-9]+$/) && parseInt(returnCode, 10) >= 0;

                        if (!isSuccsee) {
                            if (errMsg) {
                                display_window.innerHTML = '<div class="empty-msg" onclick="pageSupport.setForceLogCookie()">' +errMsg +'</div>';
                            } else {
                                display_window.innerHTML = getAjaxErrorMsg(5);
                            }
                            return;
                        }

                        var rtnMap = resp.rtnMap;
                        if (!isObject(rtnMap)) {
                            display_window.innerHTML = getAjaxErrorMsg(6);
                            return;
                        }
                        //UNIT_TYPE 單位類型，0:資訊，1:業務
                        var oIT = rtnMap['0'];
                        var oSA = rtnMap['1'];
                        var showMsg = '';

                        var createSupportPattern = function (data) {
                            var string = '<div class="supporter">';
                            string += '<div class="supporter-div">' + data.DIV_NM + '</div>';
                            string += '<div class="supporter-name">' + data.EMP_NAME + '</div>';
                            if (data.EMP_EXT) {
                                string += '<div class="supporter-ext">#' + data.EMP_EXT + '</div>';
                            }
                            if (data.MEMO) {
                                string += '<div class="supporter-memo">' + data.MEMO.replace(/\n/g, '<br>') + '</div>';
                            } string += '</div>';
                            return string;
                        }

                        if (isUnitType1Avalible == 'Y' && oSA && isArray(oSA) && oSA.length) {
                            showMsg += '<div class="support-group" onclick="pageSupport.setForceLogCookie()"><h3>' + msgMap.bussinessSupporter + '</h3>';
                            for (var i = 0; i < oSA.length; i++) {
                                showMsg += createSupportPattern(oSA[i]);
                            }
                            showMsg += '</div>'
                        }

                        if (isUnitType0Avalible == 'Y' && oIT && isArray(oIT) && oIT.length) {
                            showMsg += '<div class="support-group" onclick="pageSupport.setForceLogCookie()"><h3>' + msgMap.techSupporter + '</h3>';
                            for (var i = 0; i < oIT.length; i++) {
                                showMsg += createSupportPattern(oIT[i]);
                            }
                            showMsg += '</div>'
                        }
                        if(showMsg){
                            display_window.innerHTML = showMsg;
                        }else{
                            display_window.innerHTML = getAjaxErrorMsg(7);
                        }
                    }else if (http.readyState == 4){
                        window.console && console.log("[utility][pageSupport][load] http status error: " + http.status );
                        return;
                    }
                }
                http.send('FUNC_ID=' + FUNC_ID);
            }
            , removeActiveClass: function (classes) {
                classes = (classes || '').split(' ');
                var newClasses = '';
                for (var i = 0; i < classes.length; i++) {
                    if (classes[i] != 'active') {
                        newClasses = newClasses + ' ' + classes[i];
                    }
                }
                return newClasses ? newClasses.substr(1) : '';
            }
            , setCookie: function(name, value , stayDays){
            	document.cookie = name + "=" + escape(value) + ";path=/;secure";
            }
            , getCookie: function(name){
                var arr = document.cookie.match(new RegExp("(^| )" + name + "=([^;]*)(;|$)"));
                return (arr != null) ? unescape(arr[2]) || "" : "";
            }
        }

        var public_function = {
            checkAvailable: function(){
                var SYS_CODE = location.href.match(/[\/]([A-Z]+?)Web[\/]/g)[0];
                if(!SYS_CODE || SYS_CODE.length < 7){
                    // window.console && console.log("[utility][pageSupport][checkAvailable] cant get SYS_CODE");
                    return;
                }
                SYS_CODE = SYS_CODE.substr(1,2);
                isUnitType0Avalible = private_function.getCookie('isUnitType0Avalible'+SYS_CODE);
                isUnitType1Avalible = private_function.getCookie('isUnitType1Avalible'+SYS_CODE);
                if(!isUnitType0Avalible || !isUnitType1Avalible){
                    var regAry = /(.*)\/(.{9})\/(.*)/i.exec(window.location.href); //將URL切出兩塊：1.前段URL至HttpDispatcher、2.FUNC_ID
                    if (!regAry || regAry.length < 3 || !/HttpDispatcher$/i.test(regAry[1])) {
                        // window.console && console.log("[utility][pageSupport][checkAvailable] not eBAF url");
                        return;
                    }
                    var URL = regAry[1].replace(/\/\w*\d*?Web\//, '/ZZWeb/') + '/ZZC0_0700/available'; //將某某Web替換成ZZWeb
                    var http = new XMLHttpRequest();
                    http.open('POST', URL, true); //非同步
                    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                    http.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
                    http.onreadystatechange = function () {
                        if (http.readyState == 4 && http.status == 200) {
                            var resp = http.responseText;
                            isUnitType0Avalible = "N";
                            isUnitType1Avalible = "N";
                            if (!resp) {
                                window.console && console.log("[utility][pageSupport][checkAvailable] no response");
                                return;
                            }
                            try {
                                if (window.JSON && JSON.parse) {
                                    resp = JSON.parse(resp);
                                } else if (window.Prototype && "".evalJSON) {
                                    resp = resp.evalJSON();
                                } else {
                                    window.console && console.log("[utility][pageSupport][checkAvailable] cant handle JSON");
                                }
                            } catch (e) {
                                window.console && console.log("[utility][pageSupport][checkAvailable] error when parseJSON");
                                return;
                            }
                            isUnitType0Avalible = resp.TYPE_0_AVAILABLE ? "Y":"N";
                            isUnitType1Avalible = resp.TYPE_1_AVAILABLE ? "Y":"N";
                            private_function.setCookie('isUnitType0Avalible'+SYS_CODE,isUnitType0Avalible);
                            private_function.setCookie('isUnitType1Avalible'+SYS_CODE,isUnitType1Avalible);
                            public_function.init();
                        }else if (http.readyState == 4){
                            window.console && console.log("[utility][pageSupport][checkAvailable] http status error: " + http.status );
                            return;
                        }
                    }
                    http.send('SYS_CODE=' + SYS_CODE);
                }else{
                    public_function.init();
                }
            },
            init: function () {
            	if(isUnitType0Avalible != "Y" && isUnitType1Avalible != "Y"){return;}
                if (outter) { return; }
                if (maxRetryTimes <= testedTimes) { return; }
	            testedTimes++;
	            if(!document.body || !document.getElementById){
	            	setTimeout(public_function.init,300);
	            	return;
	        	}
                var targetElem = document.getElementById('pageNo');
                if (targetElem) {
                    targetElem.appendChild(private_function.create());
                    return;
                }
                targetElem = document.getElementById('pageFrame-nav');
                if (targetElem) {
                    var icon = private_function.create();
                    icon.className = icon.className + " pageFrame-nav-block pageFrame-nav-right";
                    var childrenOfNav = targetElem.childNodes;
                    for(var i = 0 ; i < childrenOfNav.length ; i++){
                        console.log(i)
                        if((childrenOfNav[i].className||"").indexOf("pageFrame-nav-right")>=0){
                            targetElem.insertBefore(icon , childrenOfNav[i]);
                            break;
                        }
                    }
                    if(!icon.parentNode){
                        targetElem.appendChild(icon);
                    }
                    return;
                }

                if(document.getElementsByClassName){
		        	targetElem = document.getElementsByClassName('subTitle')[0];
		        }
		        if(!targetElem){
                	targetElem = document.getElementById('bar1');
            	}
	            if(!targetElem){
	            	targetElem = document.getElementsByName('bar1')[0];
	            }
		        
                if (targetElem) {
                	var testTags = ['td','div','span'];
                	for(var i = 0 ; i < testTags.length ; i++){
	                    var testDoms = targetElem.getElementsByTagName(testTags[i]);
	                    for (var j = 0; j < testDoms.length; j++) {
	                        if (testDoms[j].getAttribute('align') == 'right') {
		                        for(var k = 0 ; k < testDoms[j].childNodes.length ; k++){
			                        if(testDoms[j].childNodes[k].tagName){
			                        	testDoms[j].childNodes[k].style.display = 'inline';
			                        }
		                        }
	                            testDoms[j].appendChild(private_function.create());
	                            return;
	                        }
	                    }
	                }
	                window.console && console.log("[utility][pageSupport][init] can not found target element to display." );
                    return;
                }
                setTimeout(public_function.init, 300);

            }, toggle: function () {
                var classes = outter.className;
                if (classes.match(/^active\s|\sactive\s|\sactive$/)) {
                    public_function.hide();
                } else {
                    public_function.show();
                }
            }
            , show: function () {
                var newClasses = private_function.removeActiveClass(outter.className);
                outter.className = 'active ' + newClasses;
                icon_button.focus();

                private_function.load();

            }
            , hide: function () {
                if (outter.getAttribute('keep') == 'Y') {
                    icon_button.focus();
                    return;
                }
                var newClasses = private_function.removeActiveClass(outter.className);
                outter.className = newClasses;
            }
            , setForceLogCookie: function(name, value){
            	document.cookie = "EbafLog4jTrigger=True;max-age=20;path=/";
            }
        };

        return public_function;

    })();
    pageSupport.checkAvailable();
}
