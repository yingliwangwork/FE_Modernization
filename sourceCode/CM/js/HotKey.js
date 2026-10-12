/*
程式：HotKey.js快速鍵。
作者：新契約小組
功能：提供送出畫面的各種檢核
完成：2004/02/05
說明：	
	HotKeys.addHotKey(Keys.F6, new ButtonAction(document.forms[0].dayCloseList));
	HotKeys.addHotKey(Keys.F7, new ButtonAction(document.forms[0].insuranceList));
    new ButtonAction(按鈕的名稱)  -> 按鈕必須要指定名稱。  
    
    複合鍵的用法:(先指定 Shift, Ctrl, Alt 再加上指定鍵)
    HotKeys.addHotKey(Keys.Shift + Keys.F3, new ButtonAction(document.getElementById('btnID')));
    HotKeys.addHotKey(Keys.Ctrl + Keys.F3, new ButtonAction(document.getElementById('btnID')));
    
	注意：快速鍵 F1, F3, F4, F5, F6, F10, F11, 不適用此程式。
	目前複合鍵僅能搭配 Shift, Ctrl, Alt 使用。
	
更新：
*/
function KeysManager() {

    this.F1 = "112";
    this.F2 = "113";
    this.F3 = "114";
    this.F4 = "115";
    this.F5 = "116";
    this.F6 = "117";
    this.F7 = "118";
    this.F8 = "119";
    this.F9 = "120";
    this.F10 = "121";
    this.F11 = "122";
    this.F12 = "123";

    this.Backspace=  "8";
    this.Tab      =  "9";
    this.Enter    = "13";
    this.Esc      = "27";
    this.Space    = "32";

    this.PageUp   = "33";
    this.PageDown = "34";
    this.End      = "35";
    this.Home     = "36";
    this.Left     = "37";
    this.Up       = "38";
    this.Right    = "39";
    this.Down     = "40";

    this.Insert   = "45";
    this.Delete   = "46";
    
    this.Alt      = "Alt";
    this.Ctrl     = "Ctrl";
    this.Shift    = "Shift";
}

function HotKeyManager() {
    this.addHotKey = addHotKey;
    this.removeHotKey = removeHotKey;
    this.actions = {};
    this.count = 0;
    this.perform = perform;
}

function addHotKey(hotKey, action) {
    this.count++;
    this.actions[hotKey] = action;
}

// remove all key binding
function removeHotKey(hotkey, action) {
 	this.actions = {};
}

function ButtonAction(button) {
	if (button!=null){
		this.button = button;
		this.execute = ButtonExecute;
	}
}

function ButtonExecute() {
	this.button.click();
}

function perform(event) {
	event = event || window.event; 	//window.event for IE

	var key = event.keyCode || event.which;
	if(event.altKey){
		key = Keys.Alt + key;	
	}else if(event.ctrlKey){
		key = Keys.Ctrl + key;	
	}else if(event.shiftKey){
		key = Keys.Shift + key;	
	}
	var act = HotKeys.actions[key]; 
	if(act && act.execute){
		act.execute();
        event.returnValue = false; 		
	}
}

var HotKeys = new HotKeyManager();
var Keys = new KeysManager();
document.onkeydown = HotKeys.perform;
