var ie=document.all;
var dom=document.getElementById;
var ns4=document.layers;
var calunits=document.layers? "" : "px";

var bouncelimit=32; //(must be divisible by 8)
var direction="up";

function initbox(msg){
if (!dom&&!ie&&!ns4)
return;
crossobj=(dom)?document.getElementById("dropin").style : ie? document.all.dropin : document.dropin;
scroll_top=(ie)? truebody().scrollTop : window.pageYOffset;
crossobj.top=scroll_top-250+calunits;
crossobj.visibility=(dom||ie)? "visible" : "show";
dropstart=setInterval("dropin()",50);
document.getElementById("alertBoard").innerText=msg;
}

function dropin(){
scroll_top=(ie)? truebody().scrollTop : window.pageYOffset;
if (parseInt(crossobj.top)<100+scroll_top)
crossobj.top=parseInt(crossobj.top)+40+calunits;
else{
clearInterval(dropstart);
bouncestart=setInterval("bouncein()",50);
}
}

function bouncein(){
crossobj.top=parseInt(crossobj.top)-bouncelimit+calunits;
if (bouncelimit<0)
bouncelimit+=8;
bouncelimit=bouncelimit*-1;
if (bouncelimit==0){
clearInterval(bouncestart);
}
}

function dismissbox(){
if (window.bouncestart) clearInterval(bouncestart);
crossobj.visibility="hidden";
}

function truebody(){
return (document.compatMode!="BackCompat")? document.documentElement : document.body;
}
with(document){
	writeln("<div id=\"dropin\" style=\"position:absolute;visibility:hidden;left:600px;top:50px;width:150px;height:500px;background-color:#E8E8FF\">");
	writeln("<div align=\"right\"><a href=\"#\" style=\"background-color:RED\" onClick=\"dismissbox();return false\">[X]</a></div>");
	writeln("<div id=\"alertBoard\" align=\"left\"></div>");
	writeln("</div>");
}
//**********************************************************************************
// Use Object to define a err Handler for use
//**********************************************************************************
var focusObj;
var flashFlag = false;
function DefaultHandler(){
	this.appendMsg = new Array();
	this.handle = Default_append;
	this.display = Default_display;
	this.reset = Default_reset;
	this.mark = Default_mark;
	this.focusThis = Default_focus;
	this.isFinish = false;
	this.reset();
}
function Default_append(obj){
	if(this.isFinish){this.reset();}
	this.appendMsg.push(obj.desc + "(" +obj.errMsg + ")" );
	this.mark(obj.element);
}
function Default_mark(e){
	e.style.backgroundColor="#FF0066";
	this.focusThis(e);
}
function Default_display(){
	var msg = "Error collect form ObjectHandler are follows:\n";
	for(var i=0;i<this.appendMsg.length;i++){
		msg += this.appendMsg[i] + "\n";
	}
	this.isFinish = true;
	initbox(msg);
}
function Default_reset(){
	unMarkAllTextField();
	focusObj = null;
	this.appendMsg = new Array();
	this.isFinish = false;
}
function flashText(){
	if(!focusObj)return;
	if(flashFlag)
		focusObj.style.backgroundColor="#FFFFFF";
	else
		focusObj.style.backgroundColor="#FF0066";	
	flashFlag = !flashFlag;	
}
function Default_focus(e){
	if(!focusObj){
		e.focus();
		focusObj=e;
		setInterval("flashText()",500);
	}
}
function unMarkAllTextField(){
	var nodes = document.getElementsByTagName("INPUT");
	for(i=0; i<nodes.length; i++){
		if(nodes[i].getAttribute("TYPE").toUpperCase()=="TEXT"){
			nodes[i].style.backgroundColor="#FFFFFF";
		}
	}
}