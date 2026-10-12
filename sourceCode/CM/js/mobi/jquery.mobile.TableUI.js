(function($){
	if( ! $.cathay ){
		$.cathay = {};
	}
	
	function appendToFrag( tagName ,frag ){
		var elm = document.createElement(tagName);
		frag.appendChild(elm);
		return $(elm);
	}
	
	function PageController( config ){
		var pageSize= config.pageSize || 0,
			totalPageNo,
			currentPageNo,
			currentPage,
			allRecords,
			pageFooter,		// 底部bar的DIV
			prePageBtn,	 	// 上一頁Button
			pageCurrent,	// 目前頁數的span
			pageSelect,		// 目前頁數的select
			nextPageBtn;	// 下一頁Button
		
		// 產生必要 DOM 物件 
		function createDOM(){
			var	prePage = $('<div>').css( { width: "20%", float: "left" } ),
				currentPageBar = $('<div>').css( { width: "60%", float: "left", "text-Align": "center" } ),
				nextPage = $('<div>').css( { width: "20%", float: "left" } );			
				tempSelectDiv = $('<div>').addClass('ui-select');
			
			pageFooter = $('<div>').addClass( 'ui-footer-fixed ui-body-a tableUIpageFooter' );
			prePageBtn = $('<input>').attr( { type: "button", "data-icon": "arrow-l", "data-theme": "b", "data-mini": true } ).val("上一頁"),
			pageCurrent = $('<span>').css( "font-size", "24px" ),
			pageTotal = $('<span>'),
			pageSelect = $('<select>').css( { width: "100%", position: "absolute", left: "0px", top: "0px", "z-index": "2", opacity: 0, "min-height" : "100%" , "max-height" : "100%" } ),
			nextPageBtn = $('<input>').attr( { type: "button", "data-icon": "arrow-r", "data-theme": "b", "data-iconpos": "right", "data-mini": true } ).val("下一頁");
			
			tempSelectDiv.append( $('<span>').css( { "line-height": "47px" }).append( pageCurrent ).append( $('<span>').text(" / ")).append( pageTotal ) )
						 .append( pageSelect );
			currentPageBar.append( tempSelectDiv );
			prePage.append( prePageBtn );
			nextPage.append( nextPageBtn );
			
			pageFooter.append(prePage).append(currentPageBar).append(nextPage).hide();
			config.table.parents('div[data-role="page"]').append( pageFooter );
			
			prePageBtn.bind( 'tap', prePageHandler );
			nextPageBtn.bind( 'tap', nextPageHandler );
			pageSelect.bind( 'change', toPageHandler );
			
			prePageBtn.button();
			nextPageBtn.button();
		}
		
		var createPage = function( pageNo ){
			var table = config.table,
				columns = config.column,
				count = columns.length,			
				frag = document.createDocumentFragment(),
				splitKeys = config.split,
				renderRow,
				css,
				page = document.createElement('tbody'),
				startIndex,	
				endIndex;
			
			startIndex = pageNo == 1 ? 0 : ( pageNo - 1 ) * pageSize;
			endIndex = startIndex + pageSize;
			if( endIndex >= allRecords.length ){
				endIndex = allRecords.length ;
			}

			frag.appendChild( page );
			page = $(page).attr("pageNo", pageNo).hide();
			if( splitKeys ){
				renderRow = function( index, record ){
					css = index % 2 == 0 ? 'oddTR' : 'evenTR'; 
					var tr = $('<tr>').appendTo( page ).addClass( css ); 
					for(var i = 0; i < count ; i=i+1 ){
						var key = columns[i].key;
						if( splitKeys[key] ){
							tr = $('<tr>').appendTo( page ).addClass( css ); 
						}
						
						var render = columns[i].render;
						var value = $.isFunction(render) ? render( record, record[key] ) : record[key]; 
						tr.append( $('<td>').attr('align','center').append( value ));						
					}
				}
			}else{
				renderRow = function( index, record ){
					var tr = $('<tr>').appendTo( page ); 
					for(var i = 0; i < count ; i=i+1 ){
						var key = columns[i].key;
						var render = columns[i].render;
						var value = $.isFunction(render) ? render( record, record[key] ) : record[key]; 
						tr.append( $('<td>').attr('align','center').addClass('tbYellow').append( value ));						
					}
				}					
			}
			
			$.each( allRecords.slice( startIndex, endIndex ) , renderRow );
			
			table.append(frag);
			
			return page;
		};		
		
		function nextPageHandler(event){
			if( (currentPageNo + 1 ) > totalPageNo ){
				return;
			}
			
			showPage( currentPageNo + 1 );	
			pageSelect.val( currentPageNo + 1 );
		};
		
		function prePageHandler (event){
			if( ( currentPageNo - 1 ) <= 0 ){
				return;
			}
			
			showPage( currentPageNo - 1 );	
			pageSelect.val( currentPageNo - 1 );			
		};
		
		function toPageHandler(event){
			var pageNo = new Number(event.target.value);
			showPage( pageNo );	
		};
		
		function createPageSelect(){
			pageSelect.empty();
			
			for( var i = 1 ; i <= totalPageNo; i++ ){
				pageSelect.append( $('<option>').val( i ).text( "第 " + i + " 頁")); 
			}
		};
		
		function adjustButton(){
			if( currentPageNo == 1 ){
				prePageBtn.button('disable');
				if( totalPageNo > 1 ){
					nextPageBtn.button('enable');
				}else{
					nextPageBtn.button('disable');
				}
			}else if ( currentPageNo == totalPageNo ){
				prePageBtn.button('enable');
				nextPageBtn.button('disable');
			}else{
				prePageBtn.button('enable');
				nextPageBtn.button('enable');
			}
		}
		
		this.initPage = function( records ){
			if( !pageFooter ){	// 如果沒產生過 footer
				createDOM();
			}
			currentPageNo = 0;
			currentPage = null;
			
			allRecords = records;
			if( allRecords.length > 0 ){
				if( pageSize ){
					totalPageNo = Math.ceil( allRecords.length / pageSize );
				}else{
					totalPageNo = 1;
					pageSize = allRecords.length;
				}
				showPage( 1 );				
				pageTotal.text( totalPageNo );
				pageFooter.slideDown('slow');
				config.table.parents('div[data-role="content"]').css( "margin-bottom" , "47px" );	// 要預留底下換頁bar空間
			}else{
				totalPageNo = 0;
				pageFooter.slideUp('slow');
				config.table.parents('div[data-role="content"]').css( "margin-bottom" , "0px" );
			}
			createPageSelect();
		};
		
		function showPage( pageNo ){
			var pagePanel;
			if( pageNo ){
				if( currentPageNo == pageNo ){
					return;
				}
			
				var pages = config.table.children('tbody[pageNo="' + pageNo + '"]' );
				pagePanel = pages.length == 0 ? createPage( pageNo ) : pages;
				
				if( currentPage ){
					currentPage.hide();
				}
			}else{	// 表示是要秀出全部
				pagePanel = createPage( 1 );
			}
			
			pagePanel.show();
			
			currentPageNo = pageNo;
			currentPage = pagePanel;
			pageCurrent.text( currentPageNo.toString() );
			adjustButton();
		};
		this.showPage = showPage;
	}
	
	var TableUI = function( config ){
		this.config = config;
		
		var table = config.table;
		if( $.type(table) == 'string' ){
			table = $('#'+ table );
		}		
		config.table = table.css( 'width' , '100%' ).addClass('grid ui-shadow');
		
		this.PageController = new PageController(config);
		
		function createHead( thead ){
			var frag = document.createDocumentFragment(),
				tr = appendToFrag( 'tr', frag ).addClass('ui-bar-c');
				
			if( $.isArray( config.split )){
				var temp = {};
				$.each( config.split , function( index, splitKey ){
					temp[splitKey] = true;
				});
				config.split = temp;
				
				$.each( config.column, function( index, col ){
					var key = col.key;
					if( temp[key] ){
						tr = appendToFrag('tr' , frag).addClass('ui-bar-c');
					}
					
					var th = $('<th>').text( col.header );
					tr.append( th );
				});
			}else{
				$.each( config.column, function( index, col ){
					var td = $('<td>').text( col.header );
					tr.append( td );
				});
			}
			thead.append(frag);
		}
		
		
		function buildUI(){
			//建立header區塊，並將傳入的column格式化成矩陣格式
			var frag = document.createDocumentFragment();
			var head = appendToFrag( 'thead', frag );
			
			createHead( head );
			
			var tfoot = appendToFrag( 'tfoot', frag );
			table.append( frag );		
		}

		buildUI();
	};
	
	function reload(config){
		//換置tbody
		config.table.children('tbody').remove();
	}
		
	$.extend( TableUI.prototype, 
	{ 
		getAllRecords : function(){
			return this.records;
		},
		load : function( records ){
			var config = this.config;
			if( $.isArray(records)){
				this.allRecords = records;
			}else{
				this.allRecords = [];	
			}
			
			reload(config);
			
			this.PageController.initPage( records );
			
			//若是有設定讀取結束動作，執行!
			if( $.isFunction(config.afterLoad) ){
				config.afterLoad( config.table );
			}
		}
	});
	
	TableUI.create = function( config ){
		return new TableUI(config);
	};
	
	$.cathay.TableUI = TableUI;

})(jQuery);