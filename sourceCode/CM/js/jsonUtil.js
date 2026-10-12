function JSONUtil() {}

JSONUtil.addOptions = function(ele, data, textKey, valueKey) {

	ele = $(ele);
	if (ele == null) {
		return;
	} else {
		ele.length = 0;
	}

	if (data == null) return;

	var text;
	var value;
	var opt;

	if (Object.isArray(data)) {
		for (var i = 0; i < data.length; i++) {
			if (textKey == null && valueKey == null ) {
				value = data[i];
				text = value;
			} else if (textKey == null) {
 				value = data[i][valueKey];
				text = value;
			} else if (valueKey == null) {
 				text = data[i][textKey];
				value = text;
			} else {
 				text = data[i][textKey];
 				value = data[i][valueKey];
			}
			if (text || value) {
				opt = new Option(text, value);
				ele.options[ele.options.length] = opt;
			}
		}
	}
	return;
}

JSONUtil.addOptions2 = function(ele, obj) {

	if(Object.isUndefined(ele) || ele==null){
		return;
	}

	ele = $(ele).update();

	if (Object.isUndefined(obj) || obj==null){
		return;
	}

	Object.keys(obj).each(function(key){
		ele.insert(new Element('option', {'value': key}).update(obj[key]));
	});

	return;

}

JSONUtil.sampleJSON2Form= function(formId,obj) {

	if (Object.isUndefined(obj) || obj==null){
		return;
	}

	function trim(s) {
		var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
   		return (m == null) ? "" : m[1];
	}

	var ps = Object.keys(obj);
	ps.each(
		function(name){

			var formElement = $(name);
			var s = obj[name];

			if ( formElement != null) {

				 if (s == null) {
				 	 s = "";
				 } else {
				 	s = trim( ""+s )
				 }


			 	Form.Element.setValue(name, s);

			}

		});

	return;
	/**
	var inputs = $(formId).getInputs();
	var selects = $(formId).getElements('select');

	inputs = inputs.concat(selects);
	alert(inputs.length);

	inputs.each(
		function(input){

			var id = input.identify();

			try {
				var value = obj[id];

				if (value != null ) {
					var s = ""+value;


				}
			} catch(e) {
				alert(e.message);
			}
		}
	);*/
}

JSONUtil.sampleJSON2Form2= function(formId,obj) {

	var form = $(formId);

	if(Object.isUndefined(form) || form==null || Object.isUndefined(obj) || obj==null){
		return;
	}
    
    var tmpEles = form.select('*');
    if(!tmpEles || tmpEles.length == 0){ return; }

	function trim(s) {
		var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
   		return (m == null) ? "" : m[1];
	}

	Object.keys(obj).each(function(name){

		try {
			
			var eles = [];
			for(var i=0; i<tmpEles.length; i++){
				var tmpEle = tmpEles[i];
				if(tmpEle.getAttribute('name') == name || tmpEle.getAttribute('submitName') == name ){
					eles.push(tmpEle);
				}
			}

			if(eles.length==0){
				eles = form.select('#'+name);
			}
            
            if(eles.length==0){
                return;
            }

			var value = obj[name];

			if(value === undefined || value === null){
				value = "";
			}else if(Object.isString(value)){
				value = trim(value);
			}

			eles.each(function(ele){

				var tagName = ele.tagName.toUpperCase();
				if(tagName == 'DIV' || tagName == 'SPAN' || tagName == 'TD' || tagName == 'TEXTAREA'){
                     if(ele.update){
						ele.update(value);
					}else{
                        ele.innerHTML = value;
                    }
				}else if(tagName == 'INPUT'){

					var type = ele.getAttribute('type').toUpperCase();

					if(type == 'CHECKBOX' || type == 'RADIO'){

						if(ele.value == value){
							ele.checked = true;
						}

					}else if(ele.setValue){
						ele.setValue(value);
					}else{
                        ele.setAttribute('value',value);
                    }
                    
				}else if(tagName == 'SELECT'){
					if(ele.setValue){
						ele.setValue(value);
					}else{
                        ele.setAttribute('value',value);
                    }
				}else{
					ele.setAttribute('value', value);
				}

			});

		} catch (e) {
		}

	});

}

JSONUtil.sampleJSON2Form3 = function( formId, obj, tagNames, keys, alias )
{
    var element, value;
	var form = $(formId);
	var inputs = form.match( "form" ) ? form.getElements() : [];
	var tags = form.select( "[id]" ).reject( function( tag ) { return inputs.include( tag ); } );
	if( !Object.isArray( tagNames ) ) { tagNames = [ "td", "span" ]; }
	if( !Object.isArray( keys ) ) { keys = Object.keys( obj ); }

	keys.each( fillForm );

	function fillForm( key )
	{
	    try
	    {
	        value = obj[key] == undefined ? "" : trim( obj[key].toString() );

	        key = alias ? key + alias : key;
	        element = inputs.find( function( input ) { return input.name == key || input.id == key; } );
	        if( element )
	        {
	            if( element.type.toLowerCase() == 'radio' || element.type.toLowerCase() == 'checkbox' )
	            {
	                $A( form[key] ).each( function( radio ) { if( radio.value == value ) { radio.checked = true; } } );
	            }
	            else { element.setValue( value ); }
	        }

	        element = tags.find( function( tag ) { return tag.id == key; } );
	        if( element && tagNames.include( element.tagName.toLocaleLowerCase() ) )
	        {
	            element.update( value );
	        }
	    }
	    catch( e ) {}
	}

	function trim( s )
	{
		var m = s.match( /^\s*(\S+(\s+\S+)*)\s*$/ );
   		return m ? m[1] : "";
	}
}

JSONUtil.form2JSONString= function(formId) {

	return Object.toJSON( JSONUtil.form2JSON(formId) );

}

JSONUtil.form2JSON = function(formId) {

	var binds = $A( $(formId).getElementsByClassName('bind') );

	var json = {};
	binds.each(
		function(bind){

			var index = bind.name.indexOf('.');

			if (index > -1 ) { // is a object property

				var beanName = bind.name.substr(0,index);
				var propertyName = bind.name.substr(index+1,bind.name.length);;

				if (json[beanName] == null) { // first
					json[beanName] = {};
				}
				json[beanName][propertyName] = bind.value;
			} else {
				json[bind.name] = bind.value;
			}
		}
	);

	return json;
}

JSONUtil.JSON2form = function(source) {

	//alert("call JSON2form");

	function expandObject(result,pre,obj,isElement) {

		function Property(name,value,type) {
			this.name = name;
			this.value = value;
			this.type = type;

			this.toString = function() {
				return this.name + "=" + this.value + " " + this.type;
			}
		}

		if (Object.isArray(obj)) {

			for (var i=0;i<obj.length;i++) {

				expandObject(result,pre + "[" + i + "]",obj[i],true);

			}

		} else {

			var properties = Object.keys(obj);

			for (var i = 0, length = properties.length; i < length; i++) {

	      		var property = properties[i], value = source[property];

	      		 if (Object.isFunction(value) == false) {

	      			if ( typeof(value) == 'object' ) {

	      				if (value == null) {
	      					expandObject(result,property,{});
	      				} else {
	      					expandObject(result,property,value);
	      				}

	      			} else {

	      				var type = "";
	      				if (isElement == true) {
	      					type = 'element';
	      				}

	      				if (pre == '') {
	      					result.push( new Property(property,value,type) );
	      				} else {
	      					result.push( new Property(pre + "." + property,value,type) );
	      				}
	      			}
	      		 }
	      	}
		}
	}

	var result = [];
	expandObject(result,'',source)

	var msg = '';
	for (var i=0;i<result.length;i++) {

		var property = result[i];

		//alert(property);

		var objs = document.getElementsByName(property.name);

		if (property.type == 'element') {

			var name = property.name;
			var start = name.indexOf('[');
			var end = name.indexOf(']');
			var index = name.substr(start+1,end-start-1) * 1;
			var relName = name.replace("["+index+"]","");

			var items = document.getElementsByName(relName);

			//alert(relName +" index = " + index + " size = " + items.length);

			if (items.length >= (index+1) ) {
				items[index].checked = true;
			}

		} else {

			if (objs.length == 1) { // text,select

			var obj = objs[0];
			if (obj.type == 'textarea') {

			} else {
				obj.value = property.value.trim();
			}

			} else { // checkbox,radio

				for (var j=0;j<objs.length;j++) {

					var obj = objs[j];

					if (obj.value == property.value) {
						obj.checked = true;
					} else {
						obj.checked = false;
					}
				}
			}
		}

		msg = msg + result[i] + "\n";
	}

	alert(msg);

	/**
	var binds = $A( $(formId).getElementsByClassName('bind') );
	binds.each(
		function(bind){
		}
	);*/
	//return Object.toJSON(json);
}

JSONUtil.CheckButtons= function(legal,buttons) {
	for (var i=0;i<legal.length;i++) {
		var idKey = buttons[legal[i]];
		var button = $(idKey);
		if (button) {
			button.disabled = false;
		}
	}
}

JSONUtil.filterEscape = function(str) {
  	if ((/[/\n|\r]+/).test(str)) {
		var ss='';
		for (i=0; i<str.length; i++) {
			var code = str.charCodeAt(i);
			if (code == 10) {
				ss = ss.concat("\\n");
			} else if (code == 13) {
				ss = ss.concat("\\r");
			} else {
				ss += str.charAt(i);
			}
		}
		return ss;
  	} else {
  		return str;
  	}
}
