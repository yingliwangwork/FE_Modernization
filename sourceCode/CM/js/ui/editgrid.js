
function ClientPage(grid,config) {

	var pageSize = config.size;
	var pageCount;
	var pageCurrentlyNo = 1;
	var pageStartNo;
	var pageEndNo;
	var recordSize = grid.getRecords().length;

	function compute() {

 		if ( recordSize % pageSize == 0 ) {
		     pageCount = recordSize / pageSize;
		} else {
			 pageCount = Math.floor(recordSize / pageSize) + 1;
		}

		pageStartNo = ( (pageCurrentlyNo-1) * pageSize ) + 1;
		pageEndNo = pageCurrentlyNo * pageSize;
	}

	function inPage(index) {

		if ( ( index * 1 >= pageStartNo * 1 ) && ( index * 1 <= pageEndNo * 1 ) ) {
			return true;
		} else {
			return false;
		}
	}

	function page() {

		compute();

		var show = new Array();
		var records = grid.getSortRecords();

		for (var i=0;i<records.length;i++) {
			if ( inPage(i+1) ) {

				show.push( records[i] );
			}
		}

		grid.renderRecords( show );

		renderPage();
	}

	this.first = function() {
		pageCurrentlyNo = 1;
		page();
	}

	this.last = function() {
		pageCurrentlyNo = pageCount;
		page();
	}

	this.next = function() {
		pageCurrentlyNo++;
		page();
	}

	this.pre = function() {
		pageCurrentlyNo--;
		page();
	}

	function appendButton(id,src,handler,buttonContainer) {

		var button = document.createElement("input");
		button.setAttribute('id',id);
		button.setAttribute('type',"image");
		button.setAttribute('src',src);
		button.onclick = handler;

		buttonContainer.appendChild(button);
	}

	function appendInfo(buttonContainer) {

		var info = document.createElement("span");

		var value = {pageCurrentlyNo:pageCurrentlyNo,pageCount:pageCount,recordSize:recordSize};

		info.innerHTML = new Template("<span class='text10'>&nbsp;第&nbsp;#{pageCurrentlyNo}&nbsp頁&nbsp;/&nbsp;共&nbsp;#{pageCount}&nbsp;頁&nbsp;共&nbsp;#{recordSize}&nbsp;筆</span>").evaluate(value);

		buttonContainer.insertBefore(info,null);
	}


	function renderPage() {

		var container = grid.getButtomContainer();

		if ( container == null) {
			return;
		}

		container.innerHTML = "";

		var imageBase;
		if(!window.UICore){

		    var css = $$('head link[href$=css]');
		    if(css.length > 0){
				var i = css[0].href.indexOf('html');
				imageBase=css[0].href.substring(0, i) + 'images';
		    }else{
		    	imageBase = '/RZWeb/images';
		    }

		}else{
			imageBase = UICore.imageBase;
		}

		// pre
		if (pageCurrentlyNo * 1 > 1) {

			appendButton( grid.getID() + '_page-first', imageBase + "/CM/previous2.gif",function() {grid.getPage().first();return false;},container);

			appendButton( grid.getID() + '_page-pre', imageBase + "/CM/previous1.gif",function() {grid.getPage().pre();return false;},container);
		}

		// next
		if (pageCurrentlyNo * 1 < pageCount * 1  ) {

			appendButton( grid.getID() + '_page-next', imageBase + "/CM/next1.gif",function() {grid.getPage().next();return false;},container);

			appendButton( grid.getID() + '_page-last', imageBase + "/CM/next2.gif",function() {grid.getPage().last();return false;},container);
		}

		// info
		appendInfo(container);

	}

	this.page = page;


}

function EditGridPanelUI(config) {

	var id = config.id;
	var tbody = $(config.id);
	var buttomID = id + '_grid-buttom';
	var captionID = id + '_grid-caption';
	var records = config.records != null ? config.records : [];
	var sortRecords = [];
	var column = config.column;
	var size = config.size ? config.size : 1000;
	var checkboxSelect = config.checkboxSelect;
	var onRowClick = config.onRowClick;

	var clientPage;
	var sort;
	var caption;
	var buttom;
	var buttomContainer;

	// drap
	var lineDrap = config.drap ? config.drap : false;
	var dragGroup = config.dragGroup;
	var dragSource;
	var dragTarget;
    var listeners = config.listeners ? config.listeners : [];

	this.renderRecords = function(showList) {
		dragSource = [];

		clean();

		for (var i=0;i<showList.length;i++) {
			var obj = showList[i];
			var tr = document.createElement("tr");
			tr.setAttribute('id',id + "_line_" + i);

			if(onRowClick){
				tr.setAttribute('dataObj', obj);
				tr.onclick = function(){
					var trs = this.parentElement.rows;
					for(var x=0; x<trs.length; x++){
						trs[x].firstChild.style.backgroundColor = '';
					}
					this.firstChild.style.backgroundColor = 'orange';

					//pass back the dataObj and tr element
					onRowClick(this.dataObj, this);
				}
			}

			if (i%2 == 0) {				
				$(tr).addClassName('tbYellow2');
			} else {				
				$(tr).addClassName('tbBlue3');
			}

			var box;

			for (var j=0;j<column.length;j++) {

				var col = column[j];
				var td = document.createElement("td");

				var tdAlign = col.align;
				if (tdAlign == null){
					tdAlign = "center";
				}

				td.setAttribute('align', tdAlign);

				var value = obj[ col.dataIndex ];
				if(col.dataIndex == '_grid_selected_row'){

					box = document.createElement('input');
					var callback = col.callback;
					if(Object.isFunction(callback)){
						box.setAttribute('_customCallback', callback);
					}
					box.setAttribute('name', '_grid_selected_row');
					box.dataObj = obj; //<----- 這裡要放Obj，不能用setAttribute

					if(col.multiSelect){
						box.setAttribute('type', 'checkbox');
						//handle the checked status change from script
						box.onpropertychange = function(){
							if(Object.isUndefined(this.dataObj['_data_grid_selected'])
								|| this.checked != this.dataObj['_data_grid_selected']){
								this.dataObj['_data_grid_selected'] = this.checked;
								if(this._customCallback) this._customCallback(this.dataObj);
							}
						}

						box.onclick = function(){
							this.dataObj['_data_grid_selected'] = this.checked;
							if(this._customCallback) this._customCallback(this.dataObj);
						}
					}else{
						box.setAttribute('type', 'radio');
						box.onclick = function(){
							var radios = $(id).select('input[type="radio"]');
							radios.each(function(it){
								it.checked = false;
							});
							for(var z=0; z<records.length; z++){
								records[z]['_data_grid_selected'] = false;
							}
							this.dataObj['_data_grid_selected'] = true;
							this.checked = true;
							if(this._customCallback) this._customCallback(this.dataObj);
						}

					}

					td.appendChild(box);

					if(obj['_data_grid_selected']){
						box.checked = true;
					}

					tr.insertBefore(td,null);

					continue;
				}

				if (col.render) {

				    var cloneObj = Object.clone(obj);
					value= col.render( cloneObj ,value);

					if (value == null) {
						value = "";
					} else {
						value = new Template(value).evaluate(cloneObj);
					}
				}

				if (value == null) {
					td.innerHTML = "";
				} else {
					td.innerHTML = value;
				}

				if(col.editor){
					//var theElem = $(td).firstDescendant();
					var theElem = $(td);
					//僅填入文字，重新產生段落
					//if(theElem == null){
					//	theElem = new Element('p').update(td.innerHTML);
					//	$(td).update(theElem);
					//}

					theElem.addClassName('grid_eip');
					col.editor.column = col;
					col.editor.dataObject = obj;
					if(col.editor.form_type != 'popup'){
						//非 popup 編輯，將輸入結果更新回資料物件中
						col.editor.save_handler = function(dataObj, dataIndex, newValue){
							dataObj[dataIndex] = newValue;
						}.bind({}, obj, col.dataIndex);
					}
					theElem.editInPlace(col.editor);
				}

				tr.insertBefore(td,null);
			}

			tbody.insertBefore(tr,$(buttomID));

			if(box && box.dataObj['_data_grid_selected']){
				box.checked = true;
			}

			// drap
			if (lineDrap) {

				var source = new Ext.dd.DragSource(tr.id, { group: dragGroup });
				source.dragData = obj;

				dragSource.push(source);

			}

		}

		// add event handel
		for (var i=0;i<listeners.length;i++) {

			 var listener = listeners[i];

			 if (listener.name == 'afterRender' ) { listener.handler(); }
		}
	}

	function build() {

		// buttom
		if ( $(buttomID) != null) {
			 $(buttomID).remove();
		}

		if(checkboxSelect){
			column = [{
				header:checkboxSelect.header||'  ',
				multiSelect:(Object.isUndefined(checkboxSelect.multiSelect)?true:checkboxSelect.multiSelect),
				dataIndex:'_grid_selected_row',
				callback:checkboxSelect.callback,
				width:30,
				sort: false
			}].concat(column);
		}

		buttom = document.createElement("tr");
		buttom.setAttribute("id", buttomID);

		buttomContainer = document.createElement("td");
		buttomContainer.setAttribute("colSpan", column.length); // colSpan IE only
		buttomContainer.setAttribute("align", "LEFT");
		buttomContainer.setAttribute("vAlign", "BOTTOM");

		buttom.insertBefore(buttomContainer,null);
	    tbody.insertBefore(buttom,null);

		// caption
		if ( $(captionID) != null) {
			 $(captionID).remove();
		}

		caption = document.createElement("tr");
		caption.setAttribute("id", captionID);

		for (var i=0;i<column.length;i++) {
			var col = column[i];
			var th = document.createElement("th");

			if (col.header == null || col.header.length == 0) {
				th.setAttribute('id',id + '_caption_id_' + col.dataIndex);
				th.setAttribute('caption',col.dataIndex);
				th.innerHTML = col.dataIndex ;
			} else {
				th.setAttribute('id',id + '_caption_id_' + col.header);
				th.setAttribute('caption',col.header);
				th.innerHTML = col.header ;
			}
			
			$(th).addClassName('tbBlue');
			th.setAttribute('width',col.width);

			th.setAttribute('dataIndex',col.dataIndex);

			var t = new Sort({sortKey:col.dataIndex,grid:this});
			t.setKey( col.dataIndex );

			th.setAttribute('sort', t );

			if (col.sort == null || col.sort == true) {

				th.onclick = function() {

				  // 清空全部 caption 的狀態
				  cleanCaption();

				  var sort = this.sort;

				  if (sort.direction == Sort.NONE || sort.direction == Sort.REVERSE) {

				   	   sort.direction = Sort.OBVERSE;
				   	   this.innerHTML = this.caption + " ▼";

				   } else if (sort.direction == Sort.OBVERSE) {

				   	   sort.direction = Sort.REVERSE;
				   	   this.innerHTML = this.caption + " ▲";

				    }

				   sortRecords = records.clone();
				   sort.sort(sortRecords);

				   clientPage.page();
				}
			}

			caption.insertBefore(th,null);
		}

		tbody.insertBefore(caption,buttom);

		clean();

		if (lineDrap && dragTarget == null) {

			dragTarget = new Ext.dd.DDTarget(tbody.id,dragGroup);
			dragTarget.isNotifyTarget = true;

			for (var i=0;i<listeners.length;i++) {

				var listener = listeners[i];

				if (listener.name == 'notifyDrop' ) {

					dragTarget.notifyOut = function(dd, e, data){
				        if(this.overClass){

				        	//$('test').update( "removeClass " + this.overClass );

				            this.el.removeClass(this.overClass);
				        }
				    };

				    dragTarget.notifyOver = function(dd, e, data){

				    	//$('test').update( "notifyOver " + this.dropAllowed );

				         return this.dropAllowed;
				    };

				    dragTarget.notifyEnter = function(dd, e, data){

				    	//$('test').update( "addClass " + this.overClass );

				          if(this.overClass){
				            	this.el.addClass(this.overClass);
				          }
				          return this.dropAllowed;
				    };

				    dragTarget.notifyDrop = listener.handler;
				}
			}

		}

	}

	function clean() {

		var children = tbody.childElements()

		children.each(
			function(child){
				if ( child.identify() != buttomID && child.identify() != captionID ) {
					if(!child.hasClassName('grid_title')){
						child.remove();
					}
				}
			}
		);

		if($('PopUpCalendar')){
			$('PopUpCalendar').stopObserving('propertychange');
		}
	}

	function cleanCaption() {

		var children = $(captionID).childElements()

		children.each(
			function(child){
				child.innerHTML = child.innerHTML.replace("▼","");
				child.innerHTML = child.innerHTML.replace("▲","");

			}
		);
	}

	this.render = function(callback) {

		clientPage = new ClientPage(this,config.page);
		clientPage.page();

		if (callback) {
			callback(records);
		}

	};

	this.getPage = function() {

		return clientPage;
	};

	this.getButtom = function() {

		return buttom;
	};

	this.getButtomContainer = function() {

		return buttomContainer;
	};

	this.getRecords = function() {
		return records;
	};

	this.getSortRecords = function() {
		return sortRecords;
	};

	this.stopEdit = function(){
		$(id).select('.grid_eip').each(function(ele){
			ele.editor.stopEdit();
		});
	};

	this.startEdit = function(){
		$(id).select('.grid_eip').each(function(ele){
			ele.editor.startEdit();
		});
	};

	this.editLastRow = function(){
		var eles = $(id).select('.grid_eip');
		if(eles.length > 0){
			eles.each(function(ele){
				ele.editor.stopEdit();
			});
		}

		eles = eles.last().up('tr').select('.grid_eip');
		eles.each(function(ele){
			ele.editor.startEdit();
		});
	};

	this.editRow = function(row){
		$(row).select('.grid_eip').each(function(ele){
			ele.editor.startEdit();
		});
	};

	this.getErrorInputs = function(){
		return $(id).select('.input_error');
	};

	this.getSelectedCount = function(){
		if(records.length == 0) return 0;
		var cnt = 0;
		for(var i=0; i<records.length; i++){
			var obj = records[i];
			if(obj['_data_grid_selected']){
				cnt++;
			}
		}
		return cnt;
	};

	this.getSelectedRecords = function(){
		if(records.length == 0) return records;
		var list = [];
		for(var i=0; i<records.length; i++){
			var obj = records[i];
			if(obj['_data_grid_selected']){
				list.push(obj);
			}
		}
		return list;
	};

	this.getSelectedRows = function(){
		var list = [];
		if(records.length == 0) return list;

		var tmpEles = $(id).select('input:checked');
		var boxs = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxs.push(tmpEle);
			}
		}
		boxs.each(function(box){
			list.push(box.up('tr'));
		});
		return list;
	};

	this.deleteSelectedRecords = function(){
		var i = records.length - 1;
		while(i >= 0){
			if(records[i]['_data_grid_selected']){
				records.splice(i, 1);
			}
			i--;
		}

		this.load(records);
	};

	this.hasError = function(row){
		return ($(row).select('.input_error').size() != 0);
	};

	this.load = function(data,callback) {

		records = data;
		sortRecords = records.clone();
		clientPage = new ClientPage(this,config.page);
		clientPage.page();

		if (callback) {
			callback(records);
		}
	};

	this.getID = function() {
		return id;
	};

	this.checkAll = function (checked) {
		if(records.length == 0) return;

		for(var i=0; i<records.length; i++){
			var obj = records[i];
			obj['_data_grid_selected'] = checked;
		}

		var tmpEles = $(id).select('input:checked');
		var boxs = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxs.push(tmpEle);
			}
		}

		boxs.each(function(box){
			box.checked = checked;
		});
	}


	build();

};

function Sort(config) {

	var key = null;

	this.type = 'string';

	this.sortKey = null;

	this.direction = Sort.NONE; // obverse , reverse

	if (config.type != null) {
		this.type = config.type;
	}

	if (config.sortKey != null) {
		this.sortKey = config.sortKey;
	}

	if (config.direction != null) {
		this.direction = config.direction;
	}

	function sortString(a,b) {

		var valueA = a[this.sortKey];
		var valueB = b[this.sortKey];

		if(!valueA && !valueB){
			return 0;
		}

		if(!valueA){
			return -1;
		}

		if(!valueB){
			return 1;
		}

		return valueA.localeCompare(valueB);

	}

	function sortNumber(a,b) {

		var valueA = a[this.sortKey];
		var valueB = b[this.sortKey];

		if(isNaN(valueA) && isNaN(valueB))
			return 0;

		if(isNaN(valueA))
			return -1;

		if(isNaN(valueB))
			return 1;

		return valueA - valueB;
	}

	function toSort() {

		if (this.type == 'string') {
			return sortString;
		} else {
			return sortNumber;
		}

	}

	this.setKey = function(name) {

		key = name;
	};

	this.getKey = function() {

		return key;
	};



	this.sort = function(array) {

		if(!array || array.length < 2)
			return;

		//依元素的第一筆資料型別決定 sort 的比較方式
		//預設使用字串比較
		if (this.sortKey != null) {

			var elem = array[0];

			if (typeof(elem[this.sortKey]) == 'number') {
				array.sort(sortNumber);
			} else {
				array.sort(sortString);
			}

		} else {

			array.sort();
		}

		if (this.direction == Sort.REVERSE) {
			array.reverse();
		}
	}
}

Sort.NONE = "none";
Sort.OBVERSE = "obverse";
Sort.REVERSE = "reverse";

// Setup the EditInPlace area were we'll be keeping all our
// data and code.
var EditInPlace = Class.create();

// Default values for options, text, templates and states.
EditInPlace.defaults = {
	// Options that you'll commonly be overriding.
	id:						false,
	save_url:				false,
	form_type:				"text", // valid: text, textarea, select, date, popup
	auto_adjust:			false,
	size:					false, // calculate at run time
	max_size:				60,
	rows:					false, // calculate at run time
	max_rows:				25,
	cols:					60,
	save_on_enter:			true,
	cancel_on_esc:			true,
	focus_edit:				true,
	select_text:			false,  // problems in WebKit/Safari?
	click_event:			"click", // valid: click, dblclick
	more_data:				false,
	select_options:			false,
	external_control:		false,

	// Text we display at various points
	edit_title:				"點選編輯",
	empty_text:				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
	saving_text:			"Savings ...",
	savebutton_text:		"確定",
	cancelbutton_text:		"取消",
	savefailed_text:		"Failed to save changes.",
	error_background:       "#FF8888",
	validate_err:           "資料錯誤",

	// CSS classes and colors we use
	mouseover_highlight:	"#88aaff",
	editfield_class:		"textBox2",
	//savebutton_class:		"eip_savebutton",
	//cancelbutton_class:		"eip_cancelbutton",
	savebutton_class:		"button",
	cancelbutton_class:		"button",
	saving_class:			"eip_saving",
	empty_class:			"eip_empty",

    // Templates.  Most people won't need to change this, if you
	// do be careful, it can easily break things.
	saving:					'<span id="#{saving_id}" class="#{saving_class}" style="display: none;">#{saving_text}</span>',
	text_form:				'<input type="text" size="#{size}" value="#{value}" id="#{id}_edit" name="#{id}_edit" class="#{editfield_class}" />',
	num_text_form:			'<input type="text" size="#{size}" value="#{value}" id="#{id}_edit" name="#{id}_edit" class="#{editfield_class}" style="text-align:right; padding-right:3px" />',
	textarea_form:			'<textarea cols="#{cols}" rows="#{rows}" id="#{id}_edit" name="#{id}_edit" class="#{editfield_class}">#{value}</textarea>',
	start_select_form:		'<select id="#{id}_edit" name="#{id}_edit" class="#{editfield_class}" /> <br />',
	select_option_form:		'<option id="#{id}_option_#{option}" name="#{id}_option_#{option}" value="#{option}" #{selected}>#{option_text}</option>',
	stop_select_form:		'</select>',
	start_form:				'<div id="#{id}_editor" align="left" class="div_eip_group" style="display: none; padding:0; margin: 0; padding-left:5px; border:1px solid; background-color:F0FBC6">',
	stop_form:				'</div>',
	form_buttons:			'<div align="right" style="width:80px; padding:0; margin:0;"><input type="button" value="#{savebutton_text}" id="#{id}_save" name="#{id}_save" class="#{savebutton_class}" style="padding: 0; margin: 0" /><input type="button" value="#{cancelbutton_text}" id="#{id}_cancel" name="#{id}_cancel" class="#{cancelbutton_class}" style="padding: 0; margin: 0" /></div>',

	// Private options that are managed for you,
	// don't touch these.
	is_empty:				false,
	orig_text:				false,
	orig_text_length:		false,
	orig_text_encoded:		false,
	orig_bk_color:			false,

	//save action handle
	save_handler: false
};

EditInPlace.prototype = {
	// Constructor
	initialize: function(options) {
		// Start with the defaults and over ride with
		// the specific options were provided.
		this.opt = {};
		Object.extend(this.opt, EditInPlace.defaults);
		Object.extend(this.opt, options || {});
	},

	// Public methods ///////////////////////////////////////////////
	// Make an element editable
	edit: function() {
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id) || opt['element'];

		// Set the title
		elem.title = opt['edit_title'];

		// Save and process original content
		this._saveOrigText();

		// Turn on event processing
		this._watchForEvents();

		//validate at create ?
		if(opt.form_type == 'popup'){
			//popup 傳入資料物件檢核
			this.validate(opt.dataObject);
		}else{
			//select 傳入 dataIndex 內的資料
			this.validate(opt.dataObject[opt.column.dataIndex]);
		}
	},

	//stop click/mouseover event listening
	stopEdit: function(){
		var opt = this.opt;
		var elem = $(opt.id) || opt.element;
		elem.stopObserving(opt['click_event'], opt['mouseclick']);
		elem.stopObserving('mouseover', opt['mouseover']);

		//錯誤時保留錯誤提示
		if(opt.error) return;
		elem.title = '';
	},

	//start click/mouseover event listening
	startEdit: function() {
		var opt = this.opt;
		var elem = $(opt.id) || opt.element;
		elem.observe(opt['click_event'], opt['mouseclick']);
		elem.observe('mouseover', opt['mouseover']);

		//錯誤時保留錯誤提示
		if(opt.error) return;
		elem.title = opt['edit_title'];
	},

	validate: function(val){
		var opt = this.opt;

		if(opt.validate){
			var elem = $(opt.id) || opt.element;

			var result = opt.validate(val);
			if(result != true){
				if(typeof(result) == 'string'){
					elem.title = result;
				}else{
					elem.title = opt['validate_err'];
				}

				elem.setStyle({'backgroundColor': opt['error_background']});
				elem.addClassName('input_error');
				opt.error = true;
				return false;
			}
			elem.removeClassName('input_error');
			elem.setStyle({'backgroundColor': ''});
			opt.error = false;
			elem.title = opt.edit_title;
		}
		return true;
	},

	// Private methods //////////////////////////////////////////////
	// Save and process the original contents
	_saveOrigText: function() {
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id) || opt['element'];

		// Save the contents and note the length

		var orgVal = opt.dataObject[opt.column.dataIndex];
		if(Object.isUndefined(orgVal) || orgVal == null){
			opt['orig_text'] = '';
		}else{
			opt['orig_text'] = new String(orgVal);
		}

		opt['orig_text_length'] = opt['orig_text'].length;
		// Find the original background color
		opt['orig_bk_color'] = elem.getStyle('background-color');
		var bk_id = id;
		while(!opt['orig_bk_color']) {
			try {
				bk_id = $(bk_id).up();
			}
			catch(err) {
				break;
			}
		}

		// If no color was found default to all white
		if(!opt['orig_bk_color']) {
			opt['orig_bk_color'] = "#ffffff";
		}

		// Ugly hack for WebKit/Safari
		if(Prototype.Browser.WebKit) {
			opt['orig_bk_color'] = '#ffffff';
		}

		// For select edits find the original option value
		if(opt['form_type'] == 'select') {
			for(var i in opt['select_options']) {
				if(opt['select_options'][i] == opt['orig_text']) {
					opt['orig_option'] = i;
					break;
				}
			}
		}

		// If auto_adjust is turned on determine the edit method to use
		if(opt['auto_adjust']) {
			if(opt['orig_text_lenth'] > opt['max_size']) {
				opt['form_type'] = 'textarea';
			}
			else {
				opt['form_type'] = 'text';
			}
		}

		// If the element was previously marked as empty but isn't
		// empty anymore then update the empty state and remove
		// the empty class
		if(opt['is_empty']) {
			if(!elem.empty()) {
				opt['is_empty'] = false;
				elem.removeClassName(opt['empty_class']);
			}
		}

		// If the element is currently empty update the empty state and class
		if(elem.empty()) {
			opt['is_empty'] = true;
			elem.innerHTML = opt['empty_text'];
			elem.addClassName(opt['empty_class']);
		}

		// Encode < > "
		opt['orig_text_encoded'] = opt['orig_text'].replace(/</g, '&lt;');
		opt['orig_text_encoded'] = opt['orig_text'].replace(/>/g, '&gt;');
		opt['orig_text_encoded'] = opt['orig_text'].replace(/"/g, '&quot;');
	},

	// Turn on event listening
	_watchForEvents: function() {
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id) || opt['element'];

		// Bind event listeners
		opt['mouseover']	= this._mouseOver.bindAsEventListener(this, id);
		opt['mouseout']		= this._mouseOut.bindAsEventListener(this, id);
		opt['mouseclick']	= this._mouseClick.bindAsEventListener(this, id);
		opt['canceledit']	= this._cancelEdit.bindAsEventListener(this, id);
		opt['saveedit']		= this._saveEdit.bindAsEventListener(this, id);

		// Watch for events
		elem.observe('mouseover', opt['mouseover']);
		elem.observe('mouseout', opt['mouseout']);
		elem.observe(opt['click_event'], opt['mouseclick']);

		// External control events
		if(opt['external_control']) {
			var ext_id = opt['external_control'];
			$(ext_id).observe('mouseover', opt['mouseover']);
			$(ext_id).observe('mouseout', opt['mouseout']);
			$(ext_id).observe(opt['click_event'], opt['mouseclick']);
		}
	},

	// Mouse over event handling
	_mouseOver: function(e) {
		var opt = this.opt;
		var id = opt['id'];

		if(opt.error){
			return;
		}
		$(id).setStyle({backgroundColor: opt['mouseover_highlight']});
	},

	// Mouse out event handling
	_mouseOut: function(e) {
		var opt = this.opt;
		var id = opt['id'];

		if(opt.error){
			return;
		}

		//$(id).setStyle({backgroundColor: opt['orig_bk_color']});
		$(id).setStyle({backgroundColor: ''});
	},

	// Mouse click event handling, go into edit mode
	_mouseClick: function(e) {
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id)||opt['element'];

		// If there is an external control hide it too
		if(opt['external_control']) {
			$(opt['external_control']).hide();
		}

		// Compile the start of the edit form
		var form			= '';
		var start_form		= new Template(opt['start_form']);
		var stop_form		= new Template(opt['stop_form']);
		var form_buttons	= new Template(opt['form_buttons']);
		form += start_form.evaluate({id: id});

		var orgVal = opt.dataObject[opt.column.dataIndex];
		if(Object.isUndefined(orgVal) || orgVal == null){
			opt['orig_text_encoded'] = '';
		}else{
			opt['orig_text_encoded'] = new String(orgVal);
		}

		// Put together the body of the form
		switch(opt['form_type']) {
			case 'num_text':
				var size = opt['orig_text_length'] + 15;
				if(size > opt['max_size']) {
					size = opt['max_size'];
				}
				size = (opt['size'] ? opt['size'] : size);

				var text_form = new Template(opt['num_text_form']);
				form += text_form.evaluate({
					id: id,
					size: size,
					value: opt['orig_text_encoded'],
					editfield_class: opt['editfield_class']
				});

				break;
			case 'text':
				var size = opt['orig_text_length'] + 15;
				if(size > opt['max_size']) {
					size = opt['max_size'];
				}
				size = (opt['size'] ? opt['size'] : size);

				var text_form = new Template(opt['text_form']);
				form += text_form.evaluate({
					id: id,
					size: size,
					value: opt['orig_text_encoded'],
					editfield_class: opt['editfield_class']
				});

				break;
			case 'textarea':
				var rows = (opt['orig_text_length'] / opt['cols']) + 2;
				for(var i = 0; i < opt['orig_text_length']; i++) {
					if(opt['orig_text'].charAt(i) == "\n") {
						rows++;
					}
				}
				if(rows > opt['max_rows']) {
					rows = opt['max_rows'];
				}
				rows = (opt['rows'] ? opt['rows'] : rows);

				var textarea_form = new Template(opt['textarea_form']);
				form += textarea_form.evaluate({
					id: id,
					cols: opt['cols'],
					rows: rows,
					value: opt['orig_text_encoded'],
					editfield_class: opt['editfield_class']
				});

				break;
			case 'select':
				var start_select_form = new Template(opt['start_select_form']);
				form += start_select_form.evaluate({
					id: id,
					editfield_class: opt['editfield_class']
				});

				var option_form = new Template(opt['select_option_form']);
				var selected = '';
				for(var i in opt['select_options']) {
					var tmpOpt = opt['select_options'][i];

					//aovid the array function
					if(Object.isFunction(tmpOpt)){
						continue;
					}

					if(Object.isString(tmpOpt)){
						if(tmpOpt == opt['orig_text']) {
							selected = 'selected="selected"';
						}else {
							selected = '';
						}
						form += option_form.evaluate({
							id: id,
							option: i,
							selected: selected,
							option_text: tmpOpt
						});
					}else{
						if(tmpOpt['value'] == opt['orig_text']){
							selected = 'selected="selected"';
						}else {
							selected = '';
						}

						form += option_form.evaluate({
							id: id,
							option: tmpOpt['value']||i,
							selected: selected,
							option_text: tmpOpt['text']||tmpOpt
						});
					}
				}

				var stop_select_form = new Template(opt['stop_select_form']);
				form += stop_select_form.evaluate({});

				break;

			case 'date':
				var implText = $(id + '_date_text');
				if(!implText){
					implText = new Element('input', {
						'type':'hidden',
						'class':'date_input_group',
						'id': id + '_date_text'
					});
				}

				implText.value = elem.innerHTML;

				var dateImg = new Element('input', {
					'type':'image',
					'alt':'Date',
					'class':'date_input_group',
					'src':UICore.imageBase + '/CM/cal.gif'
				});

				dateImg.setStyle({'marginLeft':'5px'});
				elem.insert({bottom:dateImg}).insert({after:implText});
				elem.stopObserving(opt['click_event'], opt['mouseclick']);

				dateImg.observe('click', function(event){
					getCalendarFor(implText);
					dateImg.remove();
					elem.observe(opt['click_event'], opt['mouseclick']);
				});

				var datePicker = function(event, listener, id){
					if(event.propertyName == 'style.visibility'){
						var cal = event.element();
						if(cal.getStyle('visibility') == 'hidden'){
							$(id).innerHTML = $F(id + '_date_text');
							cal.stopObserving('propertychange', listener);

							var saveAction = opt['save_handler'];
							if(saveAction && Object.isFunction(saveAction)){
								saveAction($F(id + '_date_text'));
							}
						}
					}
				}

				$('PopUpCalendar').observe('propertychange', datePicker.bindAsEventListener(this, datePicker, id));
				return;

			case 'popup':
				var openBtn = new Element('input', {
					'type':'button',
					'class':'button',
					'value':'...'
				});

				openBtn.setStyle({'padding':0, 'margin':0, 'marginLeft':'5px'});

				elem.insert({bottom:openBtn});

				elem.stopObserving(opt['click_event'], opt['mouseclick']);

				openBtn.observe('click', function(event){
					var pos = event.element().positionedOffset();
					var config = Object.clone(opt.popup_config);
					config.top = pos.top;
					config.left = pos.left;
					opt.popup_callback_flag = false;

					if(config.cb){
						config.cb = function(cb, elem, obj){
							cb(obj, elem, this.opt.dataObject);

							//執行 callback 後，於 options 留下記錄(for onclose 判斷)
							this.opt.popup_callback_flag = true;

							//callback 後檢核
							if(this.opt.validate){
								this.validate(obj);
							}
						}.bind(this, config.cb, elem);
					}

					//在視窗關閉時執行檢核
					if(opt.validate){
						if(config.onclose){
							//若交易有自定 onclose，則先呼叫 validate 再呼叫 onclose
							config.onclose = function(onclose){

								//若是未執行過，表示是使用者取消視窗，故依原資料執行檢核
								if(!this.opt.popup_callback_flag){
									this.validate(this.opt.dataObject);
								}

								onclose();
							}.bind(this, config.onclose);
						}else{
							config.onclose = function(){

								//若是未執行過，表示是使用者取消視窗，故依原資料執行檢核
								if(!this.opt.popup_callback_flag){
									this.validate(this.opt.dataObject);
								}
							}.bind(this);
						}
					}

					if(config){
						popupWin.popup(config);
						openBtn.remove();
					}

					elem.observe(opt['click_event'], opt['mouseclick']);
				}.bindAsEventListener(this));


				return;
		}// end of case switch

		// Compile the end of the edit form
		form += form_buttons.evaluate({
			id: id,
			savebutton_class: opt['savebutton_class'],
			savebutton_text: opt['savebutton_text'],
			cancelbutton_class: opt['cancelbutton_class'],
			cancelbutton_text: opt['cancelbutton_text']
		});

		form += stop_form.evaluate({});
		this._displayForm(form);
	},

	// Save edit
	_saveEdit: function(e) {
		e.stopPropagation();
		var opt = this.opt;
		var id = opt['id'];
		var theEle = $(id);

		// Gather up all of the data to pass in the XHR.
		var params = {
			'id': id,
			'form_type': opt['form_type'],
			'old_content': opt['orig_text'],
			'new_content': $F(id + '_edit')
		};

		// Provide details on the options if this was a select edit
		if(opt['form_type'] == 'select') {
			params['new_option'] = params['new_content'];
			params['new_option_text'] = $(id + '_option_' + params['new_content']).innerHTML;

			params['old_option'] = opt['orig_option'];
			params['old_option_text'] = opt['orig_text'];

			// Over ride the *_content to use the *_option_text instead
			params['old_content'] = params['old_option_text'];
			params['new_content'] = params['new_option_text'];
		}

		// Glue all of the parameters together and escape content
		var post_data = '';
		for(var i in params) {
			post_data += '&' + i + '=' + encodeURIComponent(params[i]);
		}

		// Include any additional data that was provided
		if(opt['more_data']) {
			for(var i in opt['more_data']) {
				post_data += '&' + i + '=' + encodeURIComponent(params[i]);
			}
		}

		// Strip the first & off of the front of post_data
		post_data.sub('&', '', 1);

		var my_obj = this;

		// Remove the edit form
		$(id + '_editor').remove();

		var newValue;

		if(opt['form_type'] == 'select'){
			newValue = params['new_option'];
		}else{
			newValue = params['new_content']
		}

		theEle.innerHTML = params['new_content'];

		// Need a copy of this object to deal with content issues
		//modify the save action
		var saveAction = opt['save_handler'];
		if(saveAction && Object.isFunction(saveAction)){
			saveAction(newValue);
		}

		if(opt.cb){
			opt.cb(newValue, theEle, opt.dataObject);
		}

		my_obj._saveOrigText();
		theEle.setStyle({backgroundColor: ''});

		//validate the input value after save
		this.validate(newValue);
	},

	// Cancel edit
	_cancelEdit: function(e) {
		e.stopPropagation();
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id)||opt.element;

		//validate at cancel, popup not be validated here
		this.validate(opt.dataObject[opt.column.dataIndex]);
		$(id + '_editor').remove();

		if(opt['external_control']) {
			$(opt['external_control']).show();
		}
	},

	// Display edit form
	_displayForm: function(form) {		
		var opt = this.opt;
		var id = opt['id'];
		var elem = $(id);
		// Add the form after the original element
		elem.insert({bottom: form});
		var editor = $(id + '_editor');
		var pos = elem.positionedOffset();
		editor.setStyle({
			'position':'absolute',
			'top':pos.top,
			'left':pos.left
		});

		editor.show();
		var editElem = $(id + '_edit');

		// Focus on edit
		if(opt['focus_edit']) {
			//數字型的輸入，自動加入輸入判斷
			if(opt['form_type'] == 'num_text'){
				editElem.observe('keypress', function(event){
					var code = event.keyCode;
					if((code > 47 && code < 58)||code == 46){
						return true;
					}else{
						Event.stop(event);
						return false;
					}
				});
				var rn = editElem.createTextRange();
				rn.collapse(true);
				rn.move('character', editElem.value.length);
				rn.select();
			}else{
				editElem.focus();
			}
		}

		// Select edit text
		if(opt['select_text']) {
			editElem.select();
		}

		// Watch for save and cancel button click
		$(id + '_save').observe('click', function(e){
			opt['saveedit'](e);	
		});
		$(id + '_cancel').observe('click', function(e){
			opt['canceledit'](e);	
		});

		// Need a copy of this to deal with context issues
		var my_obj = this;

		// Watch for the enter key
		if(opt['save_on_enter']) {
			editElem.observe(
				'keypress',
				function(e) {
					if(e.keyCode == Event.KEY_RETURN) {
						my_obj._saveEdit();
					}
				}
			);
		}

		// Watch for the escape key
		if(opt['cancel_on_esc']) {
			editElem.observe(
				'keypress',
				function(e) {
					if(e.keyCode == Event.KEY_ESC) {
						my_obj._cancelEdit();
					}
				}
			);
		}
	}
};

// Attach EditInPlace to $()
Element.addMethods({
	editInPlace: function(element, options) {
		if(!options) {
			var options = {};
		}

		options['id'] = $(element).identify();
		options['element'] = element;

		// Create a new object
		var eip = new EditInPlace(options);
		eip.edit();
		element.editor = eip;
	}
});