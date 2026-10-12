document.write('<div id="msgBoxLayer" style="position: absolute; z-index: 9; left: 0; top:  0; visibility: hidden;"><table class="tbBox3" id="ttr"><tr><td id="msgBlock" NOWRAP></td></tr></table></div>');

function showMsgBoxRight(msg,top,left){

	msgBlock.innerHTML=msg;
	
	if(top&&left){
		msgBoxLayer.style.top=top;
		msgBoxLayer.style.left=left;
	}else{
		msgBoxLayer.style.top=event.clientY-(msgBoxLayer.clientHeight/2);
		msgBoxLayer.style.left=event.clientX+20;
	}
	
	msgBoxLayer.style.visibility="visible";
	
}

function showMsgBoxLeft(msg,top,left){

	msgBlock.innerHTML=msg;
	
	if(top&&left){
		msgBoxLayer.style.top=top;
		msgBoxLayer.style.left=left;
	}else{
		msgBoxLayer.style.top=event.clientY-(msgBoxLayer.clientHeight/2);
		msgBoxLayer.style.left=event.clientX-(msgBoxLayer.clientWidth+20);
	}
	
	msgBoxLayer.style.visibility="visible";
	
}

function hideMsgBox(){
	msgBoxLayer.style.visibility="hidden";
}