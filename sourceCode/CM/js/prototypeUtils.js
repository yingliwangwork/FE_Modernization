/*
prototypeUtils.js from http://jehiah.com/
Licensed under Creative Commons.
version 1.0 December 20 2005

Contains:
+ Form.Element.setValue()
+ unpackToForm()

*/
String.prototype.trim = function(s) {
	if(typeof s != 'undefined'){
		var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
	    return (m == null) ? "" : m[1];		
	}
	return this.replace(/^\s+|\s+$/g,"");
};

/* Form.Element.setValue("fieldname/id","valueToSet") */
Form.Element.setValue = function(element,newValue) {
    element_id = element;
    element = $(element);
    if (!element){element = document.getElementsByName(element_id)[0];}
    if (!element){return false;}
    var method = element.tagName.toLowerCase();
    var parameter = Form.Element.SetSerializers[method](element,newValue);
}

Form.Element.SetSerializers = {
  input: function(element,newValue) {
    switch (element.type.toLowerCase()) {
      case 'submit':
      case 'hidden':
      case 'password':
      case 'text':
        return Form.Element.SetSerializers.textarea(element,newValue);
      case 'checkbox':
      case 'radio':
        return Form.Element.SetSerializers.inputSelector(element,newValue);
    }
    return false;
  },

  inputSelector: function(element,newValue) {
    fields = document.getElementsByName(element.name);
    for (var i=0;i<fields.length;i++){
      if (fields[i].value == newValue){
        fields[i].checked = true;
      }
    }
  },

  textarea: function(element,newValue) {
    element.value = newValue;
  },

  select: function(element,newValue) {
    var value = '', opt, index = element.selectedIndex;
    for (var i=0;i< element.options.length;i++){
      if (element.options[i].value == newValue){
        element.selectedIndex = i;
        return true;
      }        
    }
  }
};

function unpackToForm(data){
   for (i in data){
     Form.Element.setValue(i,data[i].toString());
   }
}

Form.Element.getSelectText = function(element,value) {
	
	var select = $(element);
	for (var i=0;i<select.options.length;i++) {
		var itemValue = select.options[i].value;
		if ( itemValue == value ) {
			 return select.options[i].text;
		}
	}
	
	alert("not find the value (" + value + ") on " + element);
	
}


Form.serializeAllElements = function(form, options) {

	var elements = Form.getElements(form);

    if (typeof options != 'object') options = { hash: !!options };
    else if (options.hash === undefined) options.hash = true;
    var key, value, submitted = false, submit = options.submit;

    var data = elements.inject({ }, function(result, element) {
      if (element.name) {
        key = element.name; value = $(element).getValue();
        if (value != null && (element.type != 'submit' || (!submitted &&
            submit !== false && (!submit || key == submit) && (submitted = true)))) {
          if (key in result) {
            // a key is already present; construct an array of values
            if (!Object.isArray(result[key])) result[key] = [result[key]];
            result[key].push(value);
          }
          else result[key] = value;
        }
      }
      return result;
    });

    return options.hash ? data : Object.toQueryString(data);
  }
