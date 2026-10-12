function OneElement(key,value){
	this.key = key;
	this.value = value;
}
function JSHashMap(initStr){
	this.elements = new Array();
	this.type = "JSHashMap";
	this.size = JSHashMap_size;
	this.put = JSHashMap_put;
	this.get = JSHashMap_get;
	this.keys = JSHashMap_keys;
	this.updateView = JSHashMap_updateView;
	this.contains = JSHashMap_contains;
	this.init = JSHashMap_init;
	this.toString = JSHashMap_toString;
	this.remove = JSHashMap_remove;
	if(initStr){this.init(initStr);} 
}
function JSHashMap_init(str){
	str = str.substring(1,str.length-1);
	var arry = str.split(",");
	for(var i=0; i<arry.length; i++ ){
		var tmp = '';
		for (var j = 0; j < arry[i].length; j++) {
			if (arry[i].charCodeAt(j)!=32){
				tmp += arry[i].charAt(j);
			}
		}
		var kk = tmp.split("=");
		this.put(kk[0],kk[1]);
	}
}
function JSHashMap_put(key, value){
	if(this.contains(key,value))
		return;
	newElement = new OneElement(key,value);
	this.elements.push(newElement);
}
function JSHashMap_remove(key){
	for(var i=0;i<this.size();i++){
		if(this.elements[i].key==key){
			this.elements.splice(i,1);
			break;
		}
	}
}
function JSHashMap_contains(key,value){
	for(var i=0;i<this.size();i++){
		if(this.elements[i].key==key){
			this.elements[i].value=value;
			return true;
		}	
	}
	return false;
}
function JSHashMap_get(key){
	for(var i=0;i<this.size();i++){
		if(this.elements[i].key==key)
			return this.elements[i].value;
	}
}
function JSHashMap_keys(){
	var keyArray=new Array();
	for(var i=0;i<this.size();i++)
		keyArray.push(this.elements[i].key);
	return keyArray;
}
function JSHashMap_size (){
	return this.elements.length;
}
function JSHashMap_updateView(d){
	if(!d){d=document;}
	for(var i=0;i<this.size();i++){
		
		var elems = d.all(this.elements[i].key);
		if(!elems){continue;}
		
		if(elems.length){
			if(elems.type == 'select-one'){
				elems.value = this.elements[i].value;
				continue;
			}
			for(var j=0; j<elems.length; j++){
				var e = elems[j];
				if(e.type =='radio'){
					if(this.elements[i].value == e.value){
						e.checked = true;
					}
				}
			}			
		}else if( elems.type == 'checkbox' ){
			if( elems.value == this.elements[i].value)
				elems.checked = true;
		}else{
			elems.value = this.elements[i].value;
		}	
	}
}
function JSHashMap_toString(token){
	if(!token){token=",";}
	var str = "";
	for(var i=0;i<this.elements.length;i++){
		var e = this.elements[i];
		str += e.key+"="+e.value;		
		if(i!=this.elements.length-1){
			str += token;
		}
	}
	return str;
}