 
function Store(opts) {
	
	var records = [];
	var root = opts.root;
	var recordID = opts.recordID;
	var events = []; 
	if (opts.listeners) {
		events = opts.listeners;
	}
	
	build = function(obj,callback) {
			
			records = [];
			
			var result = obj[root];
			
			for (var i=0;i<result.length;i++) {
				
				var row = result[i];
				
				var id = null;
				var fields = new Array();	
				for (var cell in row) {
				
					fields.push(
						new Field(cell,row[cell])
					);
					
					if (cell == recordID) {
						id = row[cell];
					}
				}
				
				var record = new Record(id,fields,2);
				
				records.push(record);	
				
			}
			
			if (callback) {
				callback();
			}
			
	};
	
	loadData = function(parameters) {
			
			var p = {};
		    if ( parameters  != null) {
		  	     p = parameters;
		    }
			   
			new Ajax.Request(opts.url,{
			    method:'post',
			    parameters: p ,
			    onSuccess: function(transport){
			      
			      var json = transport.responseText.evalJSON();
				  
				  Sys.check(json,function(status) {
						  						if (status) {
						  							 build(json,function() {
						  							 				EventHandle.fire(events,Store.EVENT_AFTER_LOAD); // event fire
						  							 			});
						  						} 
							  				  }
						  				  );
			    },
			    onFailure:Sys.SystemError
			 });
	};		
	
	return {
		
		init:function() {
			
		},
		load:function(parameters) {
			
			loadData(parameters);
		
		},
		getRecords:function() {
			return records;
		},
		getRecordById:function(id) {
			for (var i=0;i<records.length;i++) {
				var record = records[i];
				if (record.id == id) {
					return record;
				}
			} 
			return null;
		},
		addListener:function(event) {
			
			events.push(event);
		
		},
		addRecord:function(record) {
			
			records.push(record);
			
			// 不管其他處理為何,繼續後續的工作
			EventHandle.fire(events,Store.EVENT_DATA_CHANGE,{type:'insert'});	

		},
		updateRecord:function(update) {
			
			for (var i=0;i<records.length;i++) {
				var record = records[i];
				if (record.id == update.id) {
					update.isDirty = true;
					records[i] = update;
				}
			}
			
			EventHandle.fire(events,Store.EVENT_DATA_CHANGE,{type:'update'});	

		},
		removeRecord:function(recordId) {
			
			// 產生新的陣列
			var newArray = [];
			
			var record = this.getRecordById(recordId);
			
			if (record.type == 2) {
			
				// server
				record.isDelete = true;
				
			} else {
			
				// client
				for (var i=0;i<records.length;i++) {
					var record = records[i];
					if (record.id != recordId) {
					
						newArray.push(records[i]);
					}
				}
				
				records.clear();
				for (var i=0;i<newArray.length;i++) {
					records.push(newArray[i]);
				}
			}
			
			EventHandle.fire(events,Store.EVENT_DATA_CHANGE,{type:'delete'});	

		}
	};

}


Store.EVENT_BEFORE_LOAD = "EVENT_BEFORE_LOAD";
Store.EVENT_AFTER_LOAD = "EVENT_AFTER_LOAD";
Store.EVENT_DATA_CHANGE = "EVENT_DATA_CHANGE";
	
function Record(id,values,type) {
		
	this.id = id;	
	this.fields = values;
	this.type = 1; // 1:client 2:server
	this.isDirty = false;
	this.isDelete = false;
	
	if (type) {
		this.type =type;
	}
	
	
	this.getFieldByName = function(name) {
		
		for (var i=0;i<this.fields.length;i++) {
			var field = this.fields[i];
			if (field.name == name) {
				return field;
			}
		}

		return null;	
	};
	
	this.getFieldValueByName = function(name) {
		
		for (var i=0;i<this.fields.length;i++) {
			var field = this.fields[i];
			if (field.name == name) {
				return field.value;
			}
		}

		return null;	
	};
	
	
	this.setFieldValue = function(name,value) {
		
		var field = this.getFieldByName(name);
		
		if (field != null) {
			field.value = value;
		} 
	};
	
	this.toObject = function() {
	
		var json = {
					'id':this.id,
					'dirty':true,
					'remove':this.isDelete
					};
		
		var item = {};
		for (var i=0;i<this.fields.length;i++) {
			
			var field = this.fields[i];
			var index = field.name.indexOf('.');
			
			
			if (index > -1 ) { // is a object property
				
				var beanName = field.name.substr(0,index);
				var propertyName = field.name.substr(index+1,field.name.length);;
				
				if (item[beanName] == null) { // first
					item[beanName] = {};
				}
				item[beanName][propertyName] = field.value;
			} else {
				item[field.name] = field.value;
			}	
			
		}
		json['item'] = item;
		
		return json;
	
	};
	
	this.toJSON = function() {
		
		return Object.toJSON( toObject() );
	}
	
}

function Field(name,value) {
	
	this.name = name;
	
	this.value = value;
	
	this.render = function() {
		
		return "<span>" + this.value + "</span>";
		
	}
}

function SelectRadioField(rowId,action) {
	
	this.e = new Element('input', { 'type': 'radio', name: 'SelectRadioField'});
	this.e.observe('click', function(event){
  		action(rowId,event);
 	});
	
	this.render = function() {
		
		return '<input type=\'radio\' name=\'SelectRadioField\' />';
		
	}
}	

function Button(opts) {
	
	this.e = new Element('input', { type:'button',value: opts.title});
	this.e.observe('click',opts.handler);
	
}

function EventHandle() {}
	
EventHandle.fire = function(events,type,opts) {
	
	for (var i=0;i<events.length;i++) {
		var event = events[i];
		if (event.type == type) {
			//alert("event type:" + type + " event.type:" + event.type  +  " call" );
			if (opts) {
				event.handler(opts,event);
			} else {
				event.handler(event);
			}
		}
	}
}

// set some default var for UI lib usage
var UICore = {
	
	webBase:'',
	
	imageBase:'',
	
	setup: function (){
	
		var js = /prototype\.js(\?.*)?$/;
	    $$('head script[src]').findAll(function(s){
	      return s.src.match(js);
	    }).each(function(s) {
	      var eles = s.src.split('/');
	      
	      eles.each(function(ele){
	      	 
	      	 if(ele.include('Web')){
	      	 	UICore.webBase = '/' + ele;
	      	 }
	      });
	      
	    });		
	    
	    //set up the images base by css path
	    var css = $$('head link[href$=css]');
	    if(css.length > 0){
			var i = css[0].href.indexOf('html');
			UICore.imageBase = css[0].href.substring(0, i) + 'images';
	    }
	    
	}
};
UICore.setup();