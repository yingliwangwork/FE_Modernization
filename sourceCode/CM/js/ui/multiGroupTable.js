/**
 *multigroup table v1
 * ref: groupTable
 * function: multi key, multi group,
 * limit: split col can't group,  no1 gk to one key[for: page, sort]
 *
 **/

var SORT_NONE = "\u25C6";
var SORT_INCREASE = "\u25B2";
var SORT_DECREASE = "\u25BC";
var separateSign = "&";

var GLOBAL_DEBUG_FLAG = true;
function debug(msg){
	if(GLOBAL_DEBUG_FLAG){
		alert(msg);
	}
}

function askIfDebug(){
	if( confirm("是否繼續debug?") ){
		GLOBAL_DEBUG_FLAG = true;
	}else{
		GLOBAL_DEBUG_FLAG = false;
	}
}

var divResize = function(){
	var bodyw = document.body.clientWidth;
	var innerbw = (bodyw-25)*0.98;
	$$('div.over_div').each(function(d){
		d.setStyle({'width': innerbw});
	});
}

var callFix = function(){};
if(!window.fix){ var fix; }
if( !Object.isUndefined(fix) && Object.isFunction(fix) ){
	fix = fix.wrap(divResize);
	callFix = fix;
}else{
	callFix = divResize;
}

Event.observe(window, 'resize', callFix);

function TableUI( config )
{
    var column = config.column;
    var split = config.split ? config.split : [];
    var empty = config.empty ? config.empty : [];
    var emptyHash;
    var totalColumns;
    var allRecords = [];
    var dataTotalRecord;
    var sorter = new Sorter();
    var sortLinks = [];
    var body, counter, subCounter, page;



	var overDiv = ( config.overDiv || config.overDiv===false )?config.overDiv:true;
	var fixedColumns = config.fixedColumns?config.fixedColumns:true;

	if(empty && empty.length > 0){
		emptyHash = new Hash();
		empty.each(function(n){
			emptyHash.set(n, n);
		});
	}

	//add by Adin
	var subtotalColumns;
	var dataSubTotalRecord;   //放小計的record，之後會轉換成<tr>的Element
	//------------

	function buildUI()
    {

		if(overDiv!==false){

			var bodyw = document.body.clientWidth;
			var _tableUIDivStyleHeight = '360px';
			var _tableUIDivStyleWidth = (bodyw-25)*0.98;
			var _tableUITableWidth = '1800';

			if(overDiv){
				if(overDiv.divHeight){_tableUIDivStyleHeight = overDiv.divHeight;}
				if(overDiv.tableWidth){_tableUITableWidth = overDiv.tableWidth;}
			}

			var div = new Element('div').addClassName('over_div').setStyle({
				'overflow': 'auto',
				'height': _tableUIDivStyleHeight,
				'width': _tableUIDivStyleWidth,
				'background': '#FFFFFF'
			});

			config.table.parentNode.insertBefore(div, config.table);

			div.insert(config.table);

			config.table.writeAttribute('width', _tableUITableWidth);

		}
        var tRow, tHeader, col, colCounter = 0;

		// initial config
		split.unshift( column[0].key );

		column.each( function( col ) {
			if( !col.attrs ) { col.attrs = {}; }
			colCounter += col.attrs.colSpan ? col.attrs.colSpan : 1;
			colCounter += col.attrs.rowSpan > 1 ? col.attrs.rowSpan - 1 : 0;
		} );

		if(config.totalColumns){

			totalColumns = new Hash();

			config.totalColumns.each(function(col){
				if(col.showIndex || col.showIndex==0){
					totalColumns.set(col.showIndex, col);
				}
			});

		}

		if(config.subtotalColumns){

			subtotalColumns = new Hash();

			config.subtotalColumns.each(function(col){
				if(col.showIndex || col.showIndex==0){
					subtotalColumns.set(col.showIndex, col);
				}
			});
		}

        colCounter = Math.ceil( colCounter / split.length );
        if( !config.headClass ) { config.headClass = "tbBlue"; }

        // head
        var head = config.table.getElementsByTagName( "thead" )[0] || new Element( "thead" );
        if( config.title )
        {
			tRow = createTRow( config.headClass, "center" );

            var attrs = { colSpan: colCounter };
			tHeader = createCell( "th", attrs );
            tHeader.update(config.title);
			tRow.insert( tHeader );

			// 若未定義，則給予預設值
            tRow.writeAttribute('className', config.titleClass?config.titleClass:'tbYellow0');

			head.insert( tRow );

			tRow.name = "multiGroupTableTitle";
        }

        if( config.emptyColumn )
        {
            tRow = createTRow( config.headClass, "center" );
            head.insert( tRow );

            config.emptyColumn.each( function( col ) {
                tHeader = createCell( "th", col.attrs ? col.attrs : {} );

				if( col.escapeOff !== true ){
					if(col.header.indexOf(";") < 0 ){
						col.header = col.header.replace(/&/g ,'&amp;');
					}
				}
                tHeader.update(col.header);
                tRow.insert( tHeader );
            } );
        }

		var reSetRowSpan = false;
        for( var i = 0, rowIndex = 0; i < column.length; i++ )
        {
            col = column[i];

            if( split[rowIndex] == col.key )
            {
                tRow = createTRow( config.headClass, "center" );
                head.insert( tRow );
                rowIndex++;
            }

            if( col.header )
            {
                tHeader = createCell( "th", col.attrs );
				//add by shung 如果可以設定固定欄位
				if( checkColumnIsEmpty(col.key) ) {
					if(col.parentKey){
						tHeader.name = col.parentKey;
					}else{
						if(col.key){
							tHeader.name = col.key;
						}else{
							tHeader.name = "x";
						}
					}
				}else{
                	tHeader.name = col.key;
				}

				if( col.escapeOff !== true ){
					if(col.header.indexOf(";") < 0 ){
						col.header = col.header.replace(/&/g ,'&amp;');
					}
				}

				tHeader.update(col.header);
				if( overDiv && fixedColumns ){
					if(tHeader.getElementsByTagName("INPUT").length == 0 && tHeader.getElementsByTagName("A").length == 0){
						tHeader.update("<font onclick='fixedColumn(this)' >"+tHeader.innerHTML+"<\/font>");
					} else {
						var tagFontObjs = tHeader.getElementsByTagName("FONT");
						var tagNum = tagFontObjs.length;
						if(tagFontObjs.length > 0 ){
							for(var x = 0; x < tagFontObjs.length; x=x+1){
								var tagFontObj = (tagFontObjs)[x];
									tagFontObj.removeAttribute("size");
									tagFontObj.onclick = new Function("fixedColumn(this)");
							}
						}
					}
				} else {
					var tagFontObjs = tHeader.getElementsByTagName("FONT");
					if(tagFontObjs.length > 0 ){
						for(var x = 0; x < tagFontObjs.length; x=x+1){
							(tagFontObjs[x]).removeAttribute("size");
						}
					}
				}
				tRow.insert( tHeader );
			}else {
                tHeader = config.table.select( "th[class~=" + col.key + "]" )[0];
            }
			//自動產生checkbox or radio button
			if(col.multiSelect!=undefined){
				var callback;
				if(col.callback){
					callback=col.callback;
				}
				if(col.multiSelect){    //true的話使用checkbox
					col.render=function(record,value){
						var box=new Element('input', {'type': 'checkbox'});
						if(callback){
							callback(record,value,box);
						}
						return box;
					};
				}else{                        //false的話使用radiobutton
					col.render=function(record,value){
						// 解決於在 IE6 、 IE7 中，自動產生的 radio button 會有不能點選的問題
						var box = new Element('input', {'type':'radio', 'name':'_data_grid_selected'});
						if(callback){
							callback(record,value,box);
						}
						return box;
					};
				}
			}

			var isSetSortable = ( col.sortable || ( col.sortable == null && config.allSortable ) );

            if( checkColumnIsEmpty(col.key) ) {

				var columnSortKey = col.sortKey;
				var columnParentKey = col.parentKey;

				if(tHeader){
		            if(columnSortKey) {
		                tHeader.insert( createSortLink( columnSortKey, col.sortRule ) );
		            }else if(isSetSortable && columnParentKey){
		            	tHeader.insert( createSortLink( columnParentKey, col.sortRule ) );
		            }
				}

				// 若所設定之斷行欄位設定為empty時，則當還有下一欄位時，則指定輸後之斷行欄位為下一欄位
				for(var j=0; j<split.length;j++){
					if(split[j]==col.key){
						var nextIndex = i+1;
						if(nextIndex<column.length){
							split[j] = column[nextIndex].key;
						}else if(nextIndex==column.length){
							split.splice(j,1);
							reSetRowSpan = true;
						}
						break;
					}
				}

            	column.splice(i,1);
            	i--;

            	continue;
            }

            if( tHeader && isSetSortable ) {
            	tHeader.insert( createSortLink( col.key, col.sortRule ) );
            }

        }

		// 若當所有split的欄位皆設定為empty時，將產生資料的rowSpan改為1
        if(reSetRowSpan){
	        for( var i = 0, rowIndex = 0; i < column.length; i++ ){
	            var col = column[i];
	            if(col.attrs.rowSpan){
	            	col.attrs.rowSpan=1;
	            }
			}
        }

        config.table.insert( head );

        // body
        body = new Element( "tbody" );
        config.table.insert( body );

        if( config.subtotalColumn ) {
            subCounter = createCounter( config.subtotalColumn, config.subtotalSplit );
        }
        if( config.totalColumn ) {
            counter = createCounter( config.totalColumn, config.totalSplit );
        }

        // foot
		var foot = null;
        if( config.pageSize > 0 )
        {
            tHeader = new Element( "th" ).writeAttribute( "colSpan", colCounter );

			//舊版
            //page = new Page( tHeader, config.pageSize, pageChange, config.groupKeys ? config.groupKeys[0][0] : false );

			//add by Adin
			page = new Page( tHeader, config.pageSize, pageChange, config.groupKeys ? config.groupKeys[0] : false );
			//----

            tRow = createTRow( "tbBlue2", "right" );
            tRow.insert( tHeader );


            foot = new Element( "tfoot" );
            foot.insert( tRow );
            config.table.insert( foot );

        }
		//add by shung 使用css固定標頭及最下面換頁欄位
		if( overDiv ){
			head.className = "fixedthead";
			headrows = head.rows;
			for(var x = 0; x <headrows.length; x=x+1){
				if(headrows[x].name != "multiGroupTableTitle" ){
					for(var z = 0; z <headrows[x].cells.length; z=z+1){
						headrows[x].cells[z].className= "fixedth";
					}
				}
				else{
					headrows[x].cells[0].orgOffsetWidth = headrows[x].cells[0].offsetWidth;
					headrows[x].cells[0].className= "fixedTableTitle";
				}
			}
			if(foot != null){
				//foot.className = "fixedtfoot";
				var footCells0 = foot.rows[0].cells[0];
				footCells0.orgOffsetWidth = footCells0.offsetWidth;
				footCells0.orgOffsetBottom = footCells0.offsetTop + footCells0.offsetHeight;
				footCells0.className = "fixedtfootTh";
			}
		}
		config.head = head;
		config.colCounter = colCounter;
		config.body = body;
		config.foot = foot;

    }
    buildUI();

    function createCounter( column, split )
    {
        if( !split ) { split = []; }
        split.unshift( column[0].key );

        var tBody = new Element( "tbody" );
        //config.table.insert( tBody );

        var tRow, tData, rowIndex = 0;
        column.each( function( col ) {
            if( split[rowIndex] == col.key )
            {
                tRow = createTRow( "tbBlue2", "center" );
                tBody.insert( tRow );
                rowIndex++;
            }
            tData = createCell( "td", col.attrs );
            if( col.text ) { tData.update(col.text); }
            else { col.td = tData; }
            tRow.insert( tData );
        } );
        return new Counter( column, tBody );
    }

    function createSortLink( key, sortRule )
    {
        var link = new Element( "a" ).writeAttribute( "href", "#" ).update(SORT_NONE);
			link.sortRule = sortRule;
	        link.observe('click', function() {
	            this.update(this.innerHTML == SORT_DECREASE ? SORT_INCREASE : SORT_DECREASE);
				sort( key, this.innerHTML, sortRule );
	        });
        sortLinks.push( link );
        return link;
    }

    function cleanSortLink()
    {
        sortLinks.each( function( link ) { link.update(SORT_NONE); } );
    }

    function createTRow( className, align, obj )
    {
        var tRow = new Element( "tr" );
	        tRow.writeAttribute( "className", className );
	        tRow.writeAttribute( "align", align );
        if(obj){
        	tRow.writeAttribute( "dataObj", obj);
    	}
        return tRow;
    }

    function createCell( tag, attrs )
    {
        var cell = new Element( tag );
        for( var attr in attrs ) { cell.writeAttribute( attr, attrs[attr] ); }
        return cell;
    }

	function checkColumnIsEmpty(key){
		if(Object.isHash(emptyHash) && !Object.isUndefined(emptyHash.get(key))){
			return true;
		}
		return false;
	}

    function render( records )
    {

        var tRow, tData, rowIndex, value, cloneRecord;

        //build group key map
        var gkmap ={};
        if( config.groupKeys ){
            var gkv;
            config.groupKeys.each( function( gks, kindex ) {
                records.each( function( record, rindex ) {
                    gkv = "";
                    gks.each( function( gk ) {
                        gkv += record[gk];
                    } );
                    gkmap[gkv] = ( gkmap[gkv] || 0 ) +1;
                } );
            } );
            //var m = "";
            //for( var o in gkmap){
                //m += o + ":" + gkmap[o] + "\n";
            //}
            //alert("gkmap:\n"+m);
            //alert(m);
        }

        //alert("to render");
        //alert("records size:"+records.length);

        records.each( function( record, index ) {
            record.tRows = new Array();
            rowIndex = 0;

            column.each( function( col ) {

            	//debug("render col:"+col.key);
                value = record[col.key];

            	//debug("render col value before:"+value);
                if( col.render )
                {
                    cloneRecord = Object.clone( record );
                    value = col.render( cloneRecord, value );
                    if( typeof( value ) == "string" ) {
                        value = new Template( value ).evaluate( cloneRecord );
                    }

					//add by adin
					if(col.multiSelect != undefined){
						record['_data_grid_selected']=value;
					}
					//-------------------------------
                }

            	//debug("render col value after:"+value);

                tData = createCell( "td", col.attrs );
				//設定每一個資料td 的Name供固定資料欄使用
                tData.name = col.key!=null?col.key:"x";

                if(Object.isUndefined(value) || value == null){
                	tData.update(!config.showNull?"":value);
                } else if(Object.isString(value)) {
                	if(col.escapeOff !== true){
						if(value.indexOf(";") < 0 ){
							value = value.replace(/&/g ,'&amp;');
						}
                	}
                	tData.update(value);
                } else if(Object.isNumber(value)) {
                	tData.update(value);
                } else if(Object.isElement(value)) {
                	tData.insert(value);
                } else {
                    tData.update((Object.keys(value).length == 0 && !config.showNull ) ? "" : value);
                }

            	//debug("render col to split:");
                if( split[rowIndex] == col.key )
                {
                    tRow = createTRow( "", "center", record );
                    record.tRows[rowIndex++] = tRow;
                }

            	//debug("render col to group:");

                if( col.groupKey ){

                    var multiply = 1;
                    for( var attr in col.attrs ) {
                        if( attr=="rowSpan" ) {
                            multiply = col.attrs[attr] ;
                            break;
                        }
                    }

                    gkv = "";
                    col.groupKey.each( function( gk ) {
                        gkv += record[gk];
                    } );
                    if( index == 0 ){
                        tData.rowSpan = multiply * gkmap[gkv] ;
                    }else{
                        var gkv2 = "";
                        col.groupKey.each( function( gk ) {
                            gkv2 += records[index-1][gk];
                        } );
                        if( gkv!=gkv2 ){
                            tData.rowSpan = multiply * gkmap[gkv] ;
                        }else{
                            return;
                        }
                    }
                }

                tRow.insert( tData );
            } );

        } );


    }

    function pageChange()
    {
        if( !page ) { return; }

        var pageInfo = page.info();
        if( subCounter ) { subCounter.count( allRecords.slice( pageInfo.begin, pageInfo.end ) ); }
        if( config.pageChange ) { config.pageChange( pageInfo ); }
    }

    this.pageInfo = function() { return page ? page.info() : null; }

    function refresh(){

    	//alert("refresh");
    	var rowCellsMaxLength = 0;

		var maxCellsInHead = 0;
		var colorSet = true;

		headrows = config.table.getElementsByTagName("THEAD")[0].rows;
		for( var x = 0 ; x < headrows.length ; x=x+1){
			if(headrows[x].cells.length > maxCellsInHead){ maxCellsInHead = headrows[x].cells.length; }
		}

		//add by adin
		var rowMaxTdLength = 0 ;
		var td_name= [];    //用來暫存header td的name，給小計、總計使用
		var max_td_name;    //td_name的結果
		if( allRecords.length > 0 ){
			var record = allRecords[0];
			record.tRows.each( function( tRow ) {
				var thisLength=0;
				var td_name = [];
				var TDCells = tRow.getElementsByTagName("TD");
				for(var i =0 ; i < TDCells.length ; i++){
					thisLength += TDCells[i].colSpan;
					for(var j =0 ; j < TDCells[i].colSpan ; j++){
						td_name.push( TDCells[i].name );
					}
				}
				if(rowMaxTdLength < thisLength){
					rowMaxTdLength = thisLength;
					max_td_name=td_name;
				}
			} );
		}
		//------------------

		if(maxCellsInHead == 0){
			allRecords.each( function( record, index ) {
				record.tRows.each( function( tRow ) {
					tRow.writeAttribute( "className", index%2 == 0 ? "tbYellow2" : "tbBlue3" );
					body.insert( tRow );
					/*
					var TDCells = tRow.getElementsByTagName("TD");
					for(var i =0 ; i < TDCells.length ; i++){
						thisLength += TDCells[i].colSpan;
					}
					if(rowCellsMaxLength < thisLength){
						rowCellsMaxLength = thisLength;
					}*/
				});

			} );
		}else{

			//alert("maxCellsInHead:"+maxCellsInHead);
			allRecords.each( function( record, index ) {
				var thisMaxCells = 0
				record.tRows.each( function( tRow ) {
					var thisLength = 0;
					var TDCells = tRow.getElementsByTagName("TD");

					for(var i =0 ; i < TDCells.length ; i++){
						thisLength += TDCells[i].colSpan;
					}
					if(rowCellsMaxLength < thisLength){
						rowCellsMaxLength = thisLength;
					}

				});
				//alert("thisMaxCells:"+thisMaxCells);
				if( rowMaxTdLength == thisMaxCells ){ colorSet = !colorSet; }

				record.tRows.each( function( tRow ) {
					tRow.writeAttribute( "className", colorSet ? "tbYellow2" : "tbBlue3" );
					body.insert( tRow );
				} );

			} );
		}

		if(totalColumns && dataTotalRecord!=undefined){
			if(!Object.isElement(dataTotalRecord)){
				var totRow = createTRow( "tbBlue2 textBold", "center", dataTotalRecord );
				for(var i=0;i< rowMaxTdLength ;i++){
					var totTd;

					var col = totalColumns.get(i);
					if(col){
						var attrs = col.attrs ;
						totTd = createCell("td" , attrs );
						var updateTxt = '<b>';
						if(col.render){
							updateTxt += col.render(dataTotalRecord,dataTotalRecord[col.key]);
						}else{
							updateTxt += dataTotalRecord[col.key];
						}
						updateTxt += '</b>';
						totTd.update(updateTxt)
					}else{
						totTd = createCell("td");
					}
					totTd.name= max_td_name[i];
					totRow.insert(totTd);
				}
				dataTotalRecord=totRow;
			}
			body.insert(dataTotalRecord);
		}

		//add by adin
		// 判斷是否要顯示小計
		if(subtotalColumns && dataSubTotalRecord!=undefined){

			//keys()回傳Map的所有key
			var mapKey=dataSubTotalRecord.keys();

			//如果已經轉換過，就不轉換了(例如使用者按sort時，其實之前就已經轉換過了)
			if(!Object.isElement(dataSubTotalRecord.get(mapKey[0]))){

				mapKey.each(function(key){//將key變換為tr element並放回原來的Map

					var totRow = createTRow( "tbBlue2 textBold", "center" );

					for(var i=0;i< rowMaxTdLength ;i++){
						var totTd;

						var col = subtotalColumns.get(i);
						if(col){
							var attrs = col.attrs ;
							totTd = createCell("td" , attrs );

							var updateTxt = '<b>';
							if(col.render){
								updateTxt += col.render(dataSubTotalRecord.get(key),dataSubTotalRecord.get(key)[col.key]);
							}else{
								updateTxt += dataSubTotalRecord.get(key)[col.key];
							}
							updateTxt += '</b>';

							totTd.update(updateTxt)
						}else{
							totTd = createCell("td");
						}
						totTd.name= max_td_name[i];

						totRow.insert(totTd);
					}

					// 將原來小計的內容，轉換為<tr>的element了
					dataSubTotalRecord.set(key,totRow);
				});
			}
		}
		//-----------------------------------


        //if( page ) { page.refresh( allRecords ); }

		//add by adin
		if( page ) { page.refresh( allRecords,dataTotalRecord,dataSubTotalRecord); }

		//add by shung
		if( overDiv && fixedColumns){
			reflashFixedTBODY( config.table );
		}

    }

    function sort( key, direction, sortRule )
    {

        sorter.sort( allRecords, key, direction, sortRule );

        if( config.groupKeys ){
            //var sortKey = config.groupKeys[0][0];
			var sortKey = config.groupKeys[0];
			sorter.groupSort( allRecords, sortKey, direction, sortRule ); //sortKey的sortRule要另外給
        }

        reload();
        refresh();
    }
    this.sort = sort;

    this.repaint = function( records )
    {
        var oldTRows = records.pluck( "tRows" );
        render( records );
        records.each( function( record, index ) {
            record.tRows.each( function( tRow, rowIndex ) {
                tRow.writeAttribute( "className", oldTRows[index][rowIndex].getAttribute( "className" ) );
                body.replaceChild( tRow, oldTRows[index][rowIndex] );
            } );
        } );

        if( counter ) { counter.count( allRecords ); }
        if( subCounter ) {
            var pageInfo = page.info();
            subCounter.count( allRecords.slice( pageInfo.begin, pageInfo.end ) );
        }
    }

    function reload(){

        var oldBody = body;
        body = new Element( "tbody" );
        config.table.replaceChild( body, oldBody );

        render( allRecords );
    }

	//add by adin

	this.selectAllBox = function(status){
		if(allRecords.length == 0) return;
		for(var i=0; i<allRecords.length; i++){
			var obj = allRecords[i];
			if(obj['_data_grid_selected']!=undefined){
				obj['_data_grid_selected'].checked=status;
			}
		}
	}

	this.getSelectedCount = function(){
		if(allRecords.length == 0) return 0;
		var cnt = 0;
		for(var i=0; i<allRecords.length; i++){
			var obj = allRecords[i];
			if(obj['_data_grid_selected']!=undefined && obj['_data_grid_selected'].checked){
				cnt++;
			}
		}
		return cnt;
	}

	this.getSelectedRecords = function(){
		if(allRecords.length == 0) return allRecords;
		var list = [];
		for(var i=0; i<allRecords.length; i++){
			var obj = allRecords[i];
			if(obj['_data_grid_selected']!=undefined && obj['_data_grid_selected'].checked){
				list.push(obj);
			}
		}
		return list;
	}
	//--------------------------------------

    this.load = function( newRecords, newDataTotalRecord ,newDataSubTotalRecord)
    {

    	var undefined;
        if( !newRecords ) { newRecords = []; }


        allRecords = newRecords;

        if(newDataTotalRecord && newDataTotalRecord!=undefined){
        	dataTotalRecord = newDataTotalRecord;
        }

		//add by Adin
		if(newDataSubTotalRecord && newDataSubTotalRecord!=undefined){

			dataSubTotalRecord = new Hash();

			$A(newDataSubTotalRecord).each(function(subTotalRecord){

				var gks = config.groupKeys[0];
				var key = '';

				// 依groupKeys組成鍵值
				for(var i=0;i<gks.length;i++){
					if(key!=''){
						key+=separateSign;
					}
					key +=subTotalRecord[gks[i]];
				}

				dataSubTotalRecord.set(key, subTotalRecord);

			});

        }

		reload();
        //render( newRecords );
        refresh();
        if( counter ) { counter.count( allRecords ); }
        cleanSortLink();
    }

    this.add = function( newRecords )
    {
        if( !newRecords ) { return; }

        newRecords.each( function( record ) { allRecords.push( record ); } );

        render( newRecords );
        refresh();
        if( counter ) { counter.count( allRecords ); }
        cleanSortLink();
    }

    this.remove = function( key, value )
    {
        var index = -1;
        if( key == "tRow" ) {
            index = indexOfRow( value );
        }
        else {
            for( var i = 0; i < allRecords.length; i++ ) {
                if( allRecords[i][key] == value ) { index = i; break; }
            }
        }
        if( index == -1 ) { return; }

        allRecords[index].tRows.each( function( tRow ) { body.removeChild( tRow ); } );
        allRecords.splice( index, 1 );
        refresh();
        if( counter ) { counter.count( allRecords ); }
    }

    function indexOfRow( tRow )
    {
        for( var i = 0; i < allRecords.length; i++ ) {
            for( var j = 0; j < split.length; j++ ) {
                if( allRecords[i].tRows[j] == tRow ) { return i; }
            }
        }
        return -1;
    }
    this.indexOfRow = indexOfRow;

    this.getRecords = function() { return allRecords; }

    this.getCloneRecords = function( keys )
    {
        var newRecords = new Array();
        if( allRecords.length == 0 ) { return newRecords; }

        if( !keys )
        {
            keys = Object.keys( allRecords[0] ).without( "tRows" );
        }
        if( Object.isArray( keys ) )
        {
            var obj = {};
            keys.each( function( key ) { obj[key] = key; } );
            keys = obj;
        }

        var cloneRecord;
        allRecords.each( function( record ) {
            cloneRecord = {};
            for( var key in keys ) { cloneRecord[key] = record[keys[key]]; }
            newRecords.push( cloneRecord );
        } );
        return newRecords;
    }
}

function Sorter()
{
    var sortKey;

    this.sort = function( records, key, direction, sortRule )
    {
        sortKey = key;
        if( !sortKey ) { return; }

        if( !sortRule || sortRule == "string" ) {
            sortRule = sortString;
        }
        else if( sortRule == "number" ) {
            sortRule = sortNumber;
        }

        records.sort( sortRule );

        if( direction == SORT_DECREASE ) {
            records.reverse();
        }
    }

	//add by Adin   這邊的records是已經分完組放資料的Array
	this.groupSort= function ( records, key, direction, sortRule)
	{
		sortKey = key;

		if( !sortKey ) { return; }

        sortRule = groupSortRule;

		records.sort( sortRule );


		if( direction == SORT_DECREASE ) {
			records.reverse();
		}
	}

	//add by adin
	function groupSortRule( a, b )
    {
		var strA="";
		var strB="";
		sortKey.each(function (key){

			if(strA!=''){
				strA +=separateSign;
			}

			if(strB!=''){
				strB +=separateSign;
			}

			strA += a[key] ? a[key].toString() : "";
			strB += b[key] ? b[key].toString() : "";

		});

        return strA.localeCompare( strB );
    }


    function sortString( a, b )
    {
        var strA = a[sortKey] ? a[sortKey].toString() : "";
        var strB = b[sortKey] ? b[sortKey].toString() : "";
        return strA.localeCompare( strB );
    }

    function sortNumber( a, b )
    {
        var numA = isNaN( a[sortKey] ) ? null : a[sortKey];
        var numB = isNaN( b[sortKey] ) ? null : b[sortKey];
        if( numA == null || numB == null ) {
            return ( numA == null && numB == null ) ? 0 : ( numA == null ? -1 : 1 );
        }
        return numA - numB;
    }

}

function Counter( column, counterBody )
{
    display( "none" );

    this.count = function( records )
    {
        display( records.length == 0 ? "none" : "table-row" );//[20231120]調整chrome破版問題從block改成table-row
        column.each( function( col ) {
            if( col.text ) { return; }
            var sum = col.counter ? col.counter( records, col.key ) : sumUp( records, col.key );
            if( col.render ) { sum = col.render( sum ); }
            col.td.update(""+sum);
        } );
    }

    function display( status ) { counterBody.style.display = status; }

    function sumUp( records, key )
    {
        var sum = 0;
        records.each( function( record ) {
            if( !isNaN( record[key] ) ) { sum += Number( record[key] ); }
        } );
        return sum;
    }
}

// ============================== start of page class ==============================
function Page( tHeader, pageSize, pageChange , groupKey)
{
    var records = [], groups = [];
    var recordSize = 0;
    var begin = 0, end = 0;
    var currentPage = 0;
    var totalPage = 1;
    var pageInfo = new Element( "span" );

	//add by adin
	var isGroup;              //是否有傳入Group
	var dataTotalRecord;      //總計的trow
	var dataSubTotalRecord;   //用來接受傳入的小計 trows
	var subGroups=[];         //在display小計時用的
	//------------

    function buildPageUI()
    {
        addControl( "previous2.gif", function() { showPage( 1 ); } );
        addControl( "previous1.gif", function() { showPage( currentPage - 1 ); } );
        addControl( "next1.gif", function() { showPage( currentPage + 1 ); } );
        addControl( "next2.gif", function() { showPage( totalPage ); } );
        tHeader.insert( pageInfo );
        showPage( 1 );

    }
    buildPageUI();

    function addControl( src, action )
    {
        var image = new Element( "img" ).writeAttribute( "src", "../../../images/CM/" + src );
        image.observe('click', action);
        tHeader.insert( image );
    }

    function showPage( pageNo )
    {
        if( pageNo == currentPage || pageNo > totalPage || pageNo < 1 ) { return; }

        display( "none" );
        currentPage = pageNo;
        end = pageNo * pageSize;
        begin = end - pageSize;
        if( end > recordSize ) { end = recordSize; }
        display( "table-row" ); //[20231120]調整chrome破版問題從block改成table-row

		if( isGroup == true ){
			pageInfo.update("&nbsp;第" + currentPage + "頁/共" + totalPage + "頁  群組" + recordSize + "組/共"+records.length+"筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		}else{
			pageInfo.update("&nbsp;第" + currentPage + "頁/共" + totalPage + "頁  共" + recordSize + "筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		}
//      pageInfo.update("&nbsp;第" + currentPage + "頁/共" + totalPage + "頁<font onclick='fixedColumnsOn(this)'>&nbsp;&nbsp;</font>共" + recordSize + "筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");

        pageChange();

        callFix();
    }

	function display( status )
    {
        if( groupKey )
        {
            for( var i = begin; i < end; i++ )
            {

				if(groups[i]){
	                groups[i].each( function( record ) {
	                    record.tRows.each( function( tRow ) { tRow.style.display = status; } );
	                } );
            	}

				//add by adin
				if(subGroups.length>0 && subGroups[i]){    // >0 表示有小計的tr要顯示
					subGroups[i].style.display=status;
				}
				//-----------
            }

			if(dataTotalRecord){
				dataTotalRecord.style.display= ( end==recordSize )? 'table-row' : 'none';//[20231120]調整chrome破版問題從block改成table-row
			}

            return;
        }

        for( var i = begin; i < end; i++ ) {
            records[i].tRows.each( function( tRow ) { tRow.style.display = status; } );
        }

		if(dataTotalRecord){
			dataTotalRecord.style.display= ( end==recordSize ) ? 'table-row' : 'none';//[20231120]調整chrome破版問題從block改成table-row
		}

    }

    this.refresh = function( newRecords,totalRecord,subRecord )
    {
		/* 舊版本
        if( groupKey )
        {
            var keep, group;
            groups = [];
            newRecords.each( function( record ) {
                if( keep != record[groupKey] )
                {
                    keep = record[groupKey];
                    group = [ 	 ];
                    groups.push( group );
                }
                else {
                    group.push( record );
                }
            } );
        }
        */



		//add by adin
		if( groupKey )
        {
			isGroup=true;
			var compare="";
			var group;

			groups = [];
			subGroups=[];

			newRecords.each( function( record ,index) {

				var keep="";

				groupKey.each( function (key){
					keep+=record[key];
				});

				if( keep != compare )   //代表是新一組資料
				{
					group=[record];
					groups.push( group );
					compare=keep;
				}
				else{
					record['_data_grid_selected']=newRecords[index-1]['_data_grid_selected'];
					group.push( record );
					compare=keep;
				}
			} );

			//add by adin    插入小計的地方
			if(subRecord){
				dataSubTotalRecord=subRecord;

				for(var i=0;i<groups.length;i++){
					var keep="";  //先生成map key
					groupKey.each( function (key){
						if(keep!=""){
							keep+=separateSign;
						}
						keep+=groups[i][0][key];
					});

					var tr=groups[i].last();
					tr=tr.tRows.last();
					var td=dataSubTotalRecord.get(keep);
					Element.insert(tr,{after:td});
					subGroups.push(td);
				}
			}
		}

        //--------------------------------
		//插入總計的地方
		if(totalRecord){
			dataTotalRecord=totalRecord;
		}

        records = newRecords;
		recordSize = groups.length || records.length;
        begin = 0;
        end = recordSize;
        currentPage = 0;
        totalPage = Math.max( Math.ceil( recordSize / pageSize ), 1 );
        showPage( 1 );

		$(tHeader).up('table').select('select').each(function(sel){
        	sel.style.visibility = 'visible';
        });

    }

    this.info = function() { return { begin: begin, end: end, current: currentPage, total: totalPage }; }
}
// ============================== end of page class ==============================
function fixedColumn( node ){
	do{
		node = node.parentElement;
	}while(node.tagName != "TH");
	var table = node;
	do{
		table = table.parentElement;
	}while(table.tagName != "TABLE");
	var THEAD;
	for( var a = 0; a < table.childNodes.length; a=a+1 ){
		if(table.childNodes[a].tagName == 'THEAD'){
			THEAD = table.childNodes[a];
			break;
		}
	}
	if(THEAD.tagName != 'THEAD'){ return; }

	var keys = [];
	var keysPosition = -1;
	var keysGroup = false;
	var colInfos = [];
	var fixedOn = 1;
	var s = 0;
	for(var y = 0 ; y < THEAD.rows.length ; y = y +1 ){
		if( THEAD.rows[y].cells.length  >= 1 ){
			if(  THEAD.rows[y].cells.length == 1 &&  THEAD.rows[y].cells[0].name == "multiGroupTableTitle" ){
				continue;
			}
			colInfos.push([]);
			for(var z = 0 ; z < THEAD.rows[y].cells.length ; z = z +1 ){
				colInfos[s].push({
					cell: THEAD.rows[y].cells[z],
					copy:false
				});
			}
			s = s + 1;
		}
	}
	for(var y = 0 ; y < colInfos.length ; y = y +1 ){
		for(var z = 0 ; z < colInfos[y].length ; z = z +1 ){
			if( colInfos[y][z].cell.rowSpan != 1 && (!colInfos[y][z].copy) ){
				for(var x = 1; x < colInfos[y][z].cell.rowSpan && x+y < colInfos.length; x = x + 1 ){
					colInfos[x+y].splice(z,0,{
						cell: colInfos[y][z].cell,
						copy: true, copyType: "R"
					});
				}
			}
			if( colInfos[y][z].cell.colSpan != 1 && colInfos[y][z].copyType != "C" ){
				for(var x = 1; x < colInfos[y][z].cell.colSpan ; x = x + 1 ){
					colInfos[y].splice(x+z,0,{
						cell: colInfos[y][z].cell,
						copy: true, copyType: "C", lengthSet:false
					});
				}
			}
			if( node.name == colInfos[y][z].cell.name && keysPosition == -1 ){
				keysPosition = z;
				if( colInfos[y][z].cell.className == "fixedColmunth" ){
					fixedOn = -1;
				}
			}
		}
	}
	for(var y = 0 ; y < colInfos.length ; y = y +1 ){
			while( colInfos[y][keysPosition].copy && colInfos[y][keysPosition].copyType == "C"){
				keysPosition = keysPosition - 1;
			}
	}
/*  //DEBUG USE
	var temp;
	for(var y = 0 ; y < colInfos.length ; y = y +1 ){
		temp = temp + colInfos[y].length + "/";
	}
	temp = temp +"\n";
	for(var y = 0 ; y < 22 ; y = y +1 ){
		temp = temp + y + "    ";
		for(var z = 0 ; z < colInfos.length ; z = z +1 ){
			temp = temp +"("+(colInfos[z][y]?colInfos[z][y].cell.name:"xxx")+","+(colInfos[z][y]?colInfos[z][y].copy:"xxx")+ ") / ";
		}
		temp = temp +"\n";
	}
	alert(temp);
*/

	var longestRowTo = 0;
	var keysPositionSave = keysPosition;
	do{
		longestRowTo = longestRowTo - 1;
		for(var y = 0 ; y < colInfos.length ; y = y +1 ){
			if( colInfos[y][keysPosition].copyType != "R" ){
				var keysPositionCell = colInfos[y][keysPosition].cell;
				if( y == 0 ){
					if(keysPositionCell.colSpan == null || keysPositionCell.colSpan == 1){
						keysPositionCell.orgOffsetWidth = keysPositionCell.offsetWidth;
						keysPositionCell.orgOffsetLeft = keysPositionCell.offsetLeft;
						keysPositionCell.orgOffsetRight = keysPositionCell.offsetLeft + keysPositionCell.offsetWidth;
						if( fixedOn == 1){
							keysPositionCell.className = "fixedColmunth";
						}else{
							keysPositionCell.className = "fixedth";
						}
						keysPositionCell.shiftLeft = 0;
						keysPositionCell.shiftRight = 0;
						for(var u = 0 ; u < colInfos.length ; u = u + 1 ){
							for(var v = 0 ; v < keysPosition  ; v = v + 1){
								if( colInfos[u][v].cell.className == "fixedColmunth" && ( ! colInfos[u][v].copy ) ){
									keysPositionCell.shiftLeft = colInfos[u][v].cell.shiftLeft + (fixedOn * colInfos[u][v].cell.orgOffsetWidth);

									if(!colInfos[u][v].copy){
										colInfos[u][v].cell.shiftRight = colInfos[u][v].cell.shiftRight + (fixedOn * keysPositionCell.orgOffsetWidth);
									}
								}
							}
							for(var v = colInfos[u].length-1 ; v > keysPosition  ; v = v - 1){
								if( colInfos[u][v].cell.className == "fixedColmunth" && ( ! colInfos[u][v].copy ) ){
									keysPositionCell.shiftRight = colInfos[u][v].cell.shiftRight + (fixedOn * colInfos[u][v].cell.orgOffsetWidth);
									if(!colInfos[u][v].copy){
										colInfos[u][v].cell.shiftLeft = colInfos[u][v].cell.shiftLeft + (fixedOn * keysPositionCell.orgOffsetWidth);
									}
								}
							}
						}
					}
				}else{
					var isSet = false;
					var setRow = 0;
					var hasColSpan = false;
					//抓前面有沒有被設定寬度
					for(var w = 0 ; w < y ; w = w + 1){
						if(colInfos[w][keysPosition].cell.colSpan == null || colInfos[w][keysPosition].cell.colSpan == 1 ){
							if( !isSet){
								keysPositionCell.orgOffsetWidth = colInfos[w][keysPosition].cell.orgOffsetWidth;
								keysPositionCell.orgOffsetLeft = colInfos[w][keysPosition].cell.orgOffsetLeft;
								keysPositionCell.orgOffsetRight = colInfos[w][keysPosition].cell.orgOffsetRight;
								keysPositionCell.shiftLeft = colInfos[w][keysPosition].cell.shiftLeft;
								keysPositionCell.shiftRight = colInfos[w][keysPosition].cell.shiftRight;
								keysPositionCell.className = colInfos[w][keysPosition].cell.className;
								isSet = true;
							}
							setRow = w;
						}else{
							if( colInfos[w][keysPosition].lengthSet == null || colInfos[w][keysPosition].lengthSet == false ){
								hasColSpan = true;
							}
						}
					}
					//從沒設定過
					if( !isSet){
						if(keysPositionCell.colSpan == null || keysPositionCell.colSpan == 1 ){
							keysPositionCell.orgOffsetWidth = keysPositionCell.offsetWidth;
							keysPositionCell.orgOffsetLeft = keysPositionCell.offsetLeft;
							keysPositionCell.orgOffsetRight = keysPositionCell.offsetLeft + keysPositionCell.offsetWidth;
							if( fixedOn == 1){
								keysPositionCell.className = "fixedColmunth";
							}else{
								keysPositionCell.className = "fixedth";
							}
							keysPositionCell.shiftLeft = 0;
							keysPositionCell.shiftRight = 0;
							for(var u = 0 ; u < colInfos.length ; u = u + 1 ){
								for(var v = 0 ; v < keysPosition  ; v = v + 1){
									var colInfos_uv = colInfos[u][v];
									var colInfosCell_uv = colInfos_uv.cell;
									if( colInfosCell_uv.className == "fixedColmunth"  && ( ! colInfos_uv.copy ) ){
										keysPositionCell.shiftLeft = colInfosCell_uv.shiftLeft + (fixedOn * colInfosCell_uv.orgOffsetWidth);
										if(!colInfos_uv.copy){
											colInfosCell_uv.shiftRight = colInfosCell_uv.shiftRight + (fixedOn * keysPositionCell.orgOffsetWidth);
										}
									}
								}
								for(var v = colInfos[u].length-1 ; v > keysPosition  ; v = v - 1){
									if( colInfos[u][v].cell.className == "fixedColmunth"  && ( ! colInfos[u][v].copy ) ){
										keysPositionCell.shiftRight = colInfos[u][v].cell.shiftRight + (fixedOn * colInfos[u][v].cell.orgOffsetWidth);
										if(!colInfos[u][v].copy){
											colInfos[u][v].cell.shiftLeft = colInfos[u][v].cell.shiftLeft + (fixedOn * keysPositionCell.orgOffsetWidth);
										}
									}
								}
							}
							if(hasColSpan){
								for( var w = 0 ; w < y ; w = w + 1 ){
									if( (!colInfos[w][keysPosition].lengthSet) && colInfos[w][keysPosition].cell.colSpan != null && colInfos[w][keysPosition].cell.colSpan != 1){
										if( (!colInfos[w][keysPosition].copy ) ){
											colInfos[w][keysPosition].cell.className = keysPositionCell.className.valueOf( );
											colInfos[w][keysPosition].cell.orgOffsetWidth = 1*keysPositionCell.orgOffsetWidth.valueOf();
											colInfos[w][keysPosition].cell.orgOffsetLeft = 1*keysPositionCell.orgOffsetLeft.valueOf();
											colInfos[w][keysPosition].cell.shiftLeft = 1*keysPositionCell.shiftLeft.valueOf();
											colInfos[w][keysPosition].lengthSet = true;
										}else{
											colInfos[w][keysPosition].cell.orgOffsetWidth = 1*colInfos[w][keysPosition].cell.orgOffsetWidth.valueOf() + keysPositionCell.orgOffsetWidth.valueOf();
											colInfos[w][keysPosition].cell.orgOffsetRight = 1*keysPositionCell.orgOffsetRight.valueOf();
											colInfos[w][keysPosition].cell.shiftRight = 1*keysPositionCell.shiftRight.valueOf();
											colInfos[w][keysPosition].lengthSet = true;
										}
									}
								}
							}
						}
					//之前已有設定
					}else{
						if( (!colInfos[y][keysPosition].copy ) ){
							keysPositionCell.className = colInfos[setRow][keysPosition].cell.className.valueOf( );
							keysPositionCell.orgOffsetWidth = colInfos[setRow][keysPosition].cell.orgOffsetWidth.valueOf( );
							keysPositionCell.orgOffsetLeft = colInfos[setRow][keysPosition].cell.orgOffsetLeft.valueOf( );
							keysPositionCell.shiftLeft = colInfos[setRow][keysPosition].cell.shiftLeft.valueOf( );
							if(  keysPositionCell.colSpan != null && keysPositionCell.colSpan != 1 ){
								colInfos[y][keysPosition].lengthSet = true;
							}
						}else{
							keysPositionCell.orgOffsetWidth = keysPositionCell.orgOffsetWidth.valueOf( ) + colInfos[setRow][keysPosition].cell.orgOffsetWidth.valueOf( );
							keysPositionCell.orgOffsetRight = colInfos[setRow][keysPosition].cell.orgOffsetRight.valueOf( );
							keysPositionCell.shiftRight = colInfos[setRow][keysPosition].cell.shiftRight.valueOf( );
							colInfos[y][keysPosition].lengthSet = true;
						}
					}
				}
				if( ( !colInfos[y][keysPosition].copy ) && keysPositionCell.colSpan && (keysPositionCell.colSpan-1) > longestRowTo ){
					longestRowTo = keysPositionCell.colSpan-1;
				}
			}
		}
		if(longestRowTo > 0){
			keysPosition = keysPosition + 1;
		}
	}while( longestRowTo > 0 )
	reflashFixedTBODY( table );

}
function reflashFixedTBODY( table , plusRule ){
	if(!plusRule){ plusRule = function(){ return true; }; }
	var headers;
	var bodys;
	var foots;
	for( var a = 0; a < table.childNodes.length-1; a=a+1 ){
		if(table.childNodes[a].tagName == 'THEAD'){
			headers = table.childNodes[a];
			break;
		}
	}

	if(headers.tagName != 'THEAD'){ return; }
	//if(bodys.tagName != 'TBODY'){ return; }
	headers = headers.getElementsByTagName("TH");
	bodys = table.getElementsByTagName("TD");

	for(var w = 0 ; w < headers.length ; w = w + 1 ){
		if( headers[w].orgOffsetWidth && headers[w].orgOffsetWidth != -1 ){
			if(headers[w].className == "fixedth" ){
				headers[w].orgOffsetWidth = -1;
			}
			for(var x = 0 ; x < bodys.length ; x = x +1 ){
				if( headers[w].name == bodys[x].name){
					if( headers[w].className == "fixedColmunth" && plusRule(bodys[x]) ){
						if(bodys[x].parentNode.className == "tbYellow2"){
							bodys[x].className = "fixedColmun1";
						}else if(bodys[x].parentNode.className == "tbBlue3"){
							bodys[x].className = "fixedColmun2";
						}else if(bodys[x].parentNode.className == "tbBlue2"){
							bodys[x].className = "fixedColmun3";
						}
						bodys[x].orgOffsetWidth = headers[w].orgOffsetWidth;
						bodys[x].orgOffsetLeft = headers[w].orgOffsetLeft;
						bodys[x].orgOffsetRight = headers[w].orgOffsetRight;
						bodys[x].shiftLeft = headers[w].shiftLeft;
						bodys[x].shiftRight = headers[w].shiftRight;
					}else{
						bodys[x].className = "";
					}
				}
			}
		}
	}
}

function getPosition(node){
	var scrollLeft = node.parentElement.parentElement.parentElement.parentElement.scrollLeft;
	var divWidth = parseFloat(node.parentElement.parentElement.parentElement.parentElement.style.width);
	if( node.orgOffsetLeft <= ( scrollLeft+node.shiftLeft) ){
		return ( scrollLeft+node.shiftLeft) - node.orgOffsetLeft - 1 ;
	}else if( node.orgOffsetRight >= (scrollLeft + divWidth - node.shiftRight ) ){
		return (scrollLeft + divWidth - node.shiftRight ) - node.orgOffsetRight + 1 ;
	}else{
		return 0;
	}
}

function getfootPosition(node){
	var scrollTop = node.parentElement.parentElement.parentElement.parentElement.scrollTop;
	var divHeight = parseFloat(node.parentElement.parentElement.parentElement.parentElement.style.height);
	if( node.parentElement.parentElement.parentElement.offsetHeight >= ( scrollTop + divHeight) ){
//		alert(node.orgOffsetBottom +"XX"+ scrollTop + "XXX"+divHeight+"XXX"+(scrollTop + divHeight));
		return scrollTop + divHeight - node.parentElement.parentElement.parentElement.offsetHeight -14 ;
	}else{
		return 0;
	}
}



//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/*
function fixedColumnsOn( node ){
	do{
		node = node.parentElement;
	}while(node.tagName != "TABLE")
	if( node.parentElement.tagName == "DIV" ){
		var headers = node.childNodes[1].getElementsByTagName("TH");
		var tHeader;
		for(var z = 0 ; z < headers.length ; z = z + 1){
			var link = new Element( "a" );
        	link.writeAttribute( "href", "#" );
        	link.update(".");
        	link.onclick = function() { fixedColumn(this); };
			link.style.color="#0CF";
			//link.style.text.decoration = "none";
            headers[z].insert( link );

		}
	}
}
*/
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!