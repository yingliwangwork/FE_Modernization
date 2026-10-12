/**
 * 簡易的 table 組件，用來搭配後台的真分頁查詢
 */
$.widget('ui.fktable', {
	/**
	 * 	pageSize    	- 設定每頁幾筆資料
	 *	bufferPages 	- 設定每次預載幾頁的資料
	 *	rowRender   	- 繪出每一行的自定 function 
	 *	dataURL     	- 查詢的URL
	 *	params      	- 傳遞參數
	 *	firstText		- 回第一頁文字
	 *	prevBufferText	- 上10頁文字
	 *	lastText		- 最後一頁文字
	 *	nextBufferText  - 下10頁文字
	 *	loadAll			- 是否載入全部資料(真、假分頁)
	 *  onPageChange	- 換頁時會觸發的行為
	 */
	options: {
		pageSize    	: 10,
		bufferPages 	: 10,
		rowRender   	: $.noop,
		dataURL     	: '',
		params      	: {},
		firstText		: $.validator.messages.firstText||'First',
		prevBufferText	: $.validator.messages.prevBufferText||'Prev',
		lastText		: $.validator.messages.lastText||'Last',
		nextBufferText  : $.validator.messages.nextBufferText||'Next',
		loadAll			: false,
		onPageChange	: function(){return true;}
	},
	
	/** 
	 * 初始設定
	 */
	_create: function() {
		var self   = this,
		    $table = this.element,
		    $tbody = $table.children('tbody');

		if($tbody.length > 0) {
			$tbody.remove();
		}
		
		$tbody = $('<tbody>');
		
		$table.append($tbody);		
		
		self.dataList    = [];
		self.currentPage = 0;
		self.totalPages  = 0;
		self.pageStart	 = 0;
		self.pageEnd 	 = 0;
		self.totalRows	 = 0;
		self.$tbody 	 = $tbody;
		self.$table 	 = $table;
	},
	
	/** 
	 * 建立下方的分頁控制按鈕
	 */
	_buildControlBar: function() {
		var self       = this,
			$container = $('<div>').addClass('page_number border square radius mt20 mb20'),
			$inner     = $('<div>').addClass('inner');

		if(self.$container) {
			self.$container.remove();
		}

		var showBufferPageButton = self.totalPages > self.options.bufferPages;
			
		$inner.append('<a class="prev_first">'+self.options.firstText+'</a>')
		      .append(showBufferPageButton ? '<a class="prev_10">'+self.options.prevBufferText+'</a>' : '')
		      .append('<a class="prev"><');

		$inner.append('<a data-type="page">'+self.pageStart+'</a>');

		for(var i = self.pageStart+1; i <= self.pageEnd; i++) {
			$inner.append('&nbsp;<a data-type="page">'+i+'</a>');
		}

		$inner.append('<a class="next">>')
			  .append(showBufferPageButton ? '<a class="next_10">'+self.options.nextBufferText+'</a>' : '')
		      .append('<a class="next_final">'+self.options.lastText+'</a>');
		      
		$container.append($inner);
		
		self.$table.after($container);
		
		self.$inner = $inner;
		self.$container = $container;
	},
	
	_bind: function() {
		var self   = this,
		    $inner = self.$inner;

		$inner.children('a.prev').bind('click', $.proxy(self._prevPage, self));
		$inner.children('a.prev_10').bind('click', {}, $.proxy(self._prevBufferPages, self));
		$inner.children('a.prev_first').bind('click', $.proxy(self._firstPage, self));
		$inner.children('a.next').bind('click', $.proxy(self._nextPage, self));
		$inner.children('a.next_10').bind('click', {}, $.proxy(self._nextBufferPages, self));
		$inner.children('a.next_final').bind('click', $.proxy(self._lastPage, self));
		$inner.children('a').filter(function(index, element) {
			return $(element).data('type') == 'page';
		}).bind('click', $.proxy(self._changePage, self));
	},
	
	_renderPage: function() {
		var self      = this;
			rowRender = self.options.rowRender,
			period 	  = self._getPeriod(self.currentPage, self.options.pageSize, self.dataList.length);
		
		if($.isFunction(rowRender)) {
			self.$tbody.empty();
			
			for(var i = period.startIdx; i <= period.endIdx; i++) {
				var $tr  = $('<tr>'),
					data = self.dataList[i];
					
				$tr.data('rowData', data);
				$tr.data('index', i+1);
				
				rowRender($tr, data);
				
				self.$tbody.append($tr);			
			}
			
			if(self.$tbody.find(':checkbox, :radio').length) {
				setupLabel();
			}
		}
	},
	
	_getPeriod: function(currentPage, pageSize, dataSize) {
		var result = {startIdx: 0, endIdx: 0};
		
		result.startIdx = (currentPage-1)*pageSize,
		result.endIdx = (currentPage*pageSize)-1;
		result.endIdx = (result.endIdx >= dataSize) ? dataSize-1 : result.endIdx;
		
		return result;
	},

	_changePage: function(event) {
		if(this.options.onPageChange()) {
			var $currentPage = $(event.target);
			var curnIndex = parseInt($currentPage.text());
			
			this.$inner.children('a.active').removeClass('active');
			$currentPage.addClass('active');
	
			this.currentPage = curnIndex;
			this._renderPage();
		}
	},
	
	_firstPage: function(event) {
		if(this.totalPages > this.options.bufferPages) {
			this.pageStart = this.options.bufferPages+1;
			event.data = {currentPage: 1};

			this._prevBufferPages(event);
		}
		else {
			this.currentPage = 1;

			this._findWithPage(this.currentPage).trigger('click');
		}
	},
	
	_lastPage: function(event) {
		var leftPages = this.totalPages%this.options.bufferPages;
		
		if(this.totalPages > this.options.bufferPages) {
			this.pageStart = this.totalPages-(leftPages == 0 ? this.options.bufferPages : leftPages)+1-this.options.bufferPages;
			
			event.data = {currentPage: this.totalPages};

			this._nextBufferPages(event);
		}
		else {
			this.currentPage = this.totalPages;

			this._findWithPage(this.currentPage).trigger('click');
		}
	},
	
	_nextPage: function(event) {
		if(this.currentPage+1 > this.totalPages) {
			this.currentPage = this.totalPages;
		}
		else {
			this.currentPage++;
		}
		
		if(this.currentPage > this.pageEnd) {
			event.data = {currentPage: this.currentPage};
			
			this._nextBufferPages(event);
		}
		else {
			this._findWithPage(this.currentPage).trigger('click');
		}
	},
	
	_prevPage: function(event) {
		if(this.currentPage-1 < 1) {
			this.currentPage = 1;
		}
		else {
			this.currentPage--;
		}
		
		if(this.currentPage < this.pageStart) {
			event.data = {currentPage: this.currentPage};

			this._prevBufferPages(event);
		}
		else {
			this._findWithPage(this.currentPage).trigger('click');
		}
	},
	
	_nextBufferPages: function(event) {
		if(this.pageStart+this.options.bufferPages <= this.totalPages && this.options.onPageChange()) {
			this.pageStart = this.pageStart+this.options.bufferPages;
			this.pageEnd = this._getPageEnd(this.pageStart, this.options.bufferPages, this.totalPages);
			
			this._buildControlBar();
			this._bind();

			this.currentPage = event.data.currentPage||this.pageStart;
			
			if(!this.options.loadAll) {
				this.loadWithAjax('N', (this.pageStart-1)*this.options.pageSize+1, this.pageStart, this.currentPage, true);
			}
			else {
				this._findWithPage(this.currentPage).trigger('click');
			}
		}
	},
	
	_prevBufferPages: function(event) {
		if(this.pageStart - this.options.bufferPages >= 1 && this.options.onPageChange()) {
			this.pageStart = this.pageStart - this.options.bufferPages;
			this.pageEnd = this._getPageEnd(this.pageStart, this.options.bufferPages, this.totalPages);
			this.dataList = this.options.loadAll ? this.dataList : this.dataList.slice(0, this.pageEnd*this.options.pageSize);
			
			this._buildControlBar();
			this._bind();

			this.currentPage = event.data.currentPage||this.pageStart;
			
			/** 
			 * 全部的element為undefined，執行重查產生資料
			 */
			if(!this.options.loadAll && (function(dataList, period){
					for(var i = period.startIdx; i <= period.endIdx; i++) {
						if(typeof dataList[i] != 'undefined') {
							return false;
						}
					}
					
					return true;
				})(this.dataList, this._getPeriod(this.currentPage, this.options.pageSize, this.dataList.length))) {
				
				this.loadWithAjax('N', (this.pageStart-1)*this.options.pageSize+1, this.pageStart, this.currentPage, true);
			}
			else {
				this._findWithPage(this.currentPage).trigger('click');
			}
		}
	},

	_getPageEnd: function(pageStart, bufferPages, totalPages) {
		var pageEnd = pageStart+bufferPages-1;

		if(pageEnd > totalPages) {
			pageEnd = totalPages;
		}

		return pageEnd;
	},

	_findWithPage: function(pageIndex) {
		return this.$inner.children('a').filter(function(index, element) {
			return $(element).data('type') == 'page' && $(element).text() == pageIndex;
		});
	},
	
	load: function(totalOfRecords, dataList, loadStart, pageStart, currentPage, append) {
		var self = this;
		
		self.dataList = append ? (function(oldDataList, newDataList, startIndex) {
			for(var i = 0; i < newDataList.length; i++) {
				oldDataList[startIndex+i] = newDataList[i];
			}
				
			return oldDataList;
		})(self.dataList, dataList, loadStart-1) : dataList;
		self.totalRows = totalOfRecords;
		self.totalPages = Math.ceil(self.totalRows/self.options.pageSize);
		self.pageStart = pageStart;
		self.pageEnd = self._getPageEnd(self.pageStart, self.options.bufferPages, self.totalPages);
		self.currentPage = currentPage;
		
		if(self.totalRows > 0) {
			self._buildControlBar();
			self._bind();
			self._findWithPage(self.currentPage).trigger('click');
		}
		else {
			self.$tbody.empty();
			
			if(self.$container) {
				self.$container.remove();
			}
		}
	},
	
	loadWithoutAjax: function(dataList) {
		var self = this;
		
		this.options.loadAll = true;
		
		self.load(dataList.length, dataList, 1, 1, 1, false);
	},
	
	loadWithAjax: function(isFirstQuery, loadStart, pageStart, currentPage, append) {
		var self = this,
			dataURL = self.options.dataURL,
			params = self.options.params,
			loadAll = self.options.loadAll;
		
		if(!$.isPlainObject(params)) {
			throw 'params must be a plain object';
		}
		
		if(!loadAll) {
			params.isFirstQuery = isFirstQuery||'Y';
			params.loadStart = loadStart||1;
			params.loadEnd = params.loadStart+self.options.pageSize*self.options.bufferPages-1;
		}
		
		return $.ajax({
			url: dataURL,
			data: params,
			dataType: 'json',
			success: function(data, textStatus, jqXHR) {
				var dataList = $.isArray(data.records) ? data.records : [],
					dataLength = dataList.length;
				
				loadStart = params.loadStart||1;
				pageStart = pageStart||1;
				currentPage = currentPage||1;
				
				if(!loadAll) {
					if(self.totalRows > 0) {
						dataLength = self.totalRows;
					}
					else {
						dataLength = $.isNumeric(data.totalOfRecords) ? parseInt(data.totalOfRecords) : 0;
					}
				}
				
				self.load(dataLength, dataList, loadStart, pageStart, currentPage, append);
			},
			error: function(jqXHR, errorMessage) {
				self.$tbody.empty();
				
				if(self.$container) {
					self.$container.remove();
				}
			}
			
		});
	},
	
	getTotalCount: function() {
		return this.totalRows;
	},
	
	clear: function() {
		var self = this;
		
		self._create();
		
		if(self.$container) {
			self.$container.remove();
		}
		
		delete self.$inner;
		delete self.$container;
	}
});