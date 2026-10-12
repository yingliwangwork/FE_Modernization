
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


function GridPanelUI(config) {

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
	var emptyColumn = config.emptyColumn;

	var clientPage;
	var sort;
	var caption;
	var buttom;
	var buttomContainer;
	var emptyTitle;

	// drap
	var lineDrap = config.drap ? config.drap : false;
	var dragGroup = config.dragGroup;
	var dragSource;
	var dragTarget;
    var listeners = config.listeners ? config.listeners : [];

	this.getColumns = function(){
		return column.clone();
	}

	this.getEmptyColumns = function() {
		if(emptyColumn){
			return emptyColumn.clone();
		}

		return null;
	}

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
	}

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
	}

	this.renderRecords = function(showList) {

		dragSource = [];

		clean();

		for (var i=0;i<showList.length;i++) {
			var obj = showList[i];
			var tr = document.createElement("tr");
			tr.setAttribute('id',id + "_line_" + i);
			tr.dataObj = obj; //<----- 這裡要放Obj，不能用setAttribute

			if(onRowClick){

				tr.onclick = function(){
					var trs = this.parentElement.rows;
					for(var x=0; x<trs.length; x++){
						var tdd = trs[x].firstChild;
						if(tdd.name == '_grid_onRowClick'){
							//tdd.innerHTML = '';
							tdd.style.backgroundColor = '';
						}
					}
					this.firstChild.style.backgroundColor = 'orange';
					//this.firstChild.innerHTML = '→';
					onRowClick(this.dataObj);
				}
			}

			if (i%2 == 0) {
				tr.className = "tbYellow2";
			} else {
				tr.className = "tbBlue3";
			}

			for (var j=0;j<column.length;j++) {

				var col = column[j];
				var td = document.createElement("td");

				var tdAlign = col.align;
				if (tdAlign == null){
					tdAlign = "center";
				}

				td.setAttribute('align', tdAlign);

				var value = obj[ col.dataIndex ];

				//資料列選取表示欄
				if(col.dataIndex == '_grid_onRowClick'){
					td.innerHTML = '';
					td.setAttribute('name', col.dataIndex);
					tr.insertBefore(td,null);
					continue;
				}

				var box;

				if(col.dataIndex == '_grid_selected_row'){

					box = document.createElement('input');
					var callback = col.callback;
					if(Object.isFunction(callback)){
						box._customCallback = callback; //<----- 這裡要放function，不能用setAttribute，但是未來可能會有問題
					}
					box.setAttribute('name', '_grid_selected_row');
					box.dataObj = obj; //<----- 這裡要放Obj，不能用setAttribute

					if(col.multiSelect){
						box.setAttribute('type', 'checkbox');
						//handle the checked status change from script
						box.onpropertychange = function(){
							if(this.dataObj['_data_grid_selected'] == this.checked){
								return;
							}
							this.dataObj['_data_grid_selected'] = this.checked;
							if(this._customCallback) this._customCallback(this.dataObj);
						}

						box.onclick = function(){
							if(this.dataObj['_data_grid_selected'] == this.checked){
								return;
							}
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

		}// end of showList loop

		// add event handel
		for (var i=0;i<listeners.length;i++) {

			 var listener = listeners[i];

			 if (listener.name == 'afterRender' ) { listener.handler(showList); }
		}
	}

	function build() {

		//emptyColumn
		if(emptyColumn){

			listeners.push({

				name:'afterRender',
				handler:function(){

					emptyTitle = new Element('tr');
					emptyTitle.addClassName('tbBlue');

					emptyColumn.each(function(it){

						var attrs = it.attrs;
						var titleTH = new Element('th');
						titleTH.innerHTML = it.header || '';
						if(attrs && attrs.colSpan){
							titleTH.writeAttribute('colSpan', attrs.colSpan);
						}
						emptyTitle.insert(titleTH);

					});

					$(id).insert({top:emptyTitle});
				}

			});

		}

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

		if(onRowClick){
			column = [{
				header:'  ',
				dataIndex:'_grid_onRowClick',
				width:25,
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
				th.setAttribute('caption',"<b>" + col.header + "</b>");
				th.innerHTML = col.header ;
			}

			th.className = "tbBlue";
			th.setAttribute('width',col.width);

			th.setAttribute('dataIndex',col.dataIndex);

			var t = new Sort({sortKey:col.dataIndex, grid:this});

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
	}

	function cleanCaption() {

		var children = $(captionID).childElements()

		children.each(
			function(child){

				if(child.getAttribute('dataIndex') == '_grid_selected_row'){
					return;
				}

				child.innerHTML = child.innerHTML.replace("▼","");
				child.innerHTML = child.innerHTML.replace("▲","");

			}
		);
	}

	function compareByProps (condition, dataObj) {

		for(var p in condition){

			if(condition[p] != dataObj[p]){
				return false;
			}

		}

		return true;

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

	this.disableAllCheck = function() {
		var tmpEles = $(id).select('input');
		var boxes = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxes.push(tmpEle);
			}
		}

		boxes.each(function(it){
			it.disabled = true;
		});
	};

	this.enableAllCheck = function() {
		var tmpEles = $(id).select('input');
		var boxes = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxes.push(tmpEle);
			}
		}

		boxes.each(function(it){
			it.disabled = false;
		});
	};

	this.checkAll = function(checked) {
		var tmpEles = $(id).select('input');
		var boxes = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxes.push(tmpEle);
			}
		}

		if(boxes.length == 0) return;

		boxes.each(function(it){
			it.checked = checked;
		});

		this.getRecords().each(function(dataObj){
			dataObj['_data_grid_selected'] = checked;
		});

	}

	/**
	 *	conditions(勾選條件) 可為物件，或物件陣列，以指定勾選單、多筆
	 *  每個 condition 物件指定該被勾選起來的屬性及值，如：
	 *  {'STK_NO':'1234', 'SNO':'1003'} -- 單筆
	 *
	 *  [{'STK_NO':'1234', 'SNO':'1003'},
	 *   {'STK_NO':'1235', 'SNO':'1004'}]  -- 多筆
	 */
	this.setSelected = function(conditions){
		var tmpEles = $(id).select('input');
		var boxes = [];
		for(var i=0; i<tmpEles.length; i++){
			var tmpEle = tmpEles[i];
			if(tmpEle.getAttribute('name') == '_grid_selected_row'){
				boxes.push(tmpEle);
			}
		}

		if(boxes.length == 0) return;

		if(Object.isArray(conditions)){
			//指定多筆勾選

			for(var i=0; i<conditions.length; i++){

				var c = conditions[i];

				for(var x=0; x<boxes.length; x++){

					if(compareByProps(c, boxes[x].dataObj)){
						boxes[x].checked = true;
						boxes[x].dataObj['_data_grid_selected'] = true;
						break;
					}

				}

			}

		}else{
			//指定單筆勾選

			for(var i=0; i<boxes.length; i++){
				if(compareByProps(conditions, boxes[i].dataObj)){
					boxes[i].checked = true;
					boxes[i].dataObj['_data_grid_selected'] = true;
					break;
				}
			}

		}

	}

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

	this.removeItem = function(checkRemove,value) {

		var newArray = [];
		for (var i=0;i<records.length;i++) {
			if ( checkRemove(records[i],value) != true ) {
				newArray.push(records[i]);
			}
		}

		this.load(newArray);
	};

	build();

};

function Sort(config) {

	var sortKey = config.sortKey;

	this.direction = config.direction || Sort.NONE; // obverse , reverse

	function sortString(a, b) {

		var valueA = a[sortKey];
		var valueB = b[sortKey];

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

	function sortNumber(a, b) {

		var valueA = a[sortKey];
		var valueB = b[sortKey];

		if(isNaN(valueA) && isNaN(valueB))
			return 0;

		if(isNaN(valueA))
			return -1;

		if(isNaN(valueB))
			return 1;

		return valueA - valueB;
	}

	this.sort = function(array) {

		if(!array || array.length < 2)
			return;

		//依元素的第一筆資料型別決定 sort 的比較方式
		//預設使用字串比較
		if (sortKey != null) {

			var elem = array[0];

			if (typeof(elem[sortKey]) == 'number') {
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