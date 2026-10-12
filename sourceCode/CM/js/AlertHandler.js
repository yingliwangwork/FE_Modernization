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
/*---------------------------------------------------
一定要定義的 method，收到的參數為 check object
---------------------------------------------------*/
function Alert_handle(obj){
	this.msg.push(obj.desc + "[" + obj.errMsg + "]");
	this.mark(obj.element);
}
//---------------------------------------------------
function Alert_mark(e){
	this.markList.push(e);
	e.style.backgroundColor = "#FF8888";
}
//---------------------------------------------------
function Alert_clear(){
	this.executeDisplayMessage = true;
	this.msg = [];
	this.focusElement = null;

	for(var i=0;i<this.markList.length;i++){		
		this.markList[i].style.backgroundColor = "";
	}
	this.markList = [];
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