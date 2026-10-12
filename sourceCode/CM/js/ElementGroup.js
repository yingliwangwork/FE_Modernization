function ElementGroup(elems){
	this.elems = elems;
	this.root = elems[0];
	this.disable = ElementGroup_disable;
	this.enable = ElementGroup_enable;
}
function ElementGroup_disable(){
	for(i=0;i<this.elems.length;i++){
	    if(this.elems[i]!=this.root)
			disable_Element(this.elems[i]);
	}
}
function ElementGroup_enable(){
	for(i=0;i<this.elems.length;i++){
		if(this.elems[i]!=this.root){
			//alert(this.elems[i].name + ' = ' + this.elems[i].checked);
			enable_Element(this.elems[i]);
		}
	}
}
function enable_Element(e){
	e.disabled = false;
	if(e.type.toUpperCase()=='TEXT'){
		e.style.backgroundColor="#FFFFFF";
	}
}
function disable_Element(e){
	e.disabled=true;
	if(e.type.toUpperCase()=='TEXT'){
		e.disabled=true;
		e.style.backgroundColor="#C0C0C0";
	}else if(e.type.toUpperCase()=='CHECKBOX'||e.type.toUpperCase()=='RADIO'){
		e.disabled=true;
	}
}