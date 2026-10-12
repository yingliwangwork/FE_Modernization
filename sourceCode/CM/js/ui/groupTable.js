/**
 * R:require, O:option, D:Default
 * 
 * table - R, table(tag) element
 * column - R, [{key:""}], column properties, see below
 * pageSize - D, 0(no foot), rows per page
 * pageChange - O, function( pageInfo ), call when page change
 * allSortable - D, false, add sort link to all columns or not
 * showNull - D, false, for debug, by default record value is null or undefined show ""
 * split - O, ["column.ey"], multi-row
 * group - O, column.key, column set "group: true" will use this key to group
 * title - O, (HTML)String, create table title
 * titleClass - O, String, class name of title cell(th tag)
 * emptyColumn - O, [{header:""}], ...
 * headClass - O, class name of header Row(tr tag)
 * subtotalColumn - O, [{key:""}], ...
 * subtotalSplit - O, [], ...
 * totalColumn - O, [{key:""}], ...
 * totalSplit - O, [], ...
 * 
 * column properties:
 * key - R, String, uniquely identify each column in a record, also mapping to a record value
 * header - O, String, set column head
 * render - O, function( record, value, tData ), use to format a cell, tData is a cell element(td tag)
 * attrs - O, {}, cell element attributes, like { colSpan: "2", rowSapn: "2", noWrap: "nowrap" }
 * sortable - O, boolean, add sort link to head or not, if undefined then check allSortable
 * sortRule - O, function( a, b ), defined customer compare function
 * group - O, boolean, cell group or not
**/

var SORT_NONE = "\u25C6";
var SORT_INCREASE = "\u25B2";
var SORT_DECREASE = "\u25BC";

function GroupTable( config )
{
    var column = config.column;
    var split = config.split ? config.split : [];
    var allRecords = [];
    var sorter = new GroupTable.Sorter();
    var sortLinks = [], groups = {};
    var body, counter, subCounter, page;
    var listeners = config.listeners ? config.listeners : [];
    config.table = $(config.table);

    function buildUI()
    {
        var tRow, tHeader, col, colCounter = 0;
        
        // initial config
        split.unshift( column[0].key );
        column.each( function( col ) {
            if( !col.attrs ) { col.attrs = {}; }
            colCounter += col.attrs.colSpan ? col.attrs.colSpan : 1;
            colCounter += col.attrs.rowSpan > 1 ? col.attrs.rowSpan - 1 : 0;
        } );
        colCounter = Math.ceil( colCounter / split.length );
        if( !config.headClass ) { config.headClass = "tbBlue"; }
        
        // head
        var configTableThead = config.table.getElementsByTagName( "thead" );
        var head;
        if(configTableThead && configTableThead[0]){
        	head = $(configTableThead[0]);
        }else{
        	head = new Element( "thead" )
        }

        if( config.title )
        {
            tRow = createTRow( config.headClass, "center" );
            head.insert( tRow );
            
            var attrs = { colSpan: colCounter };
            if( config.titleClass ) { attrs.className = config.titleClass; }
            tHeader = createCell( "th", attrs );
            tHeader.update(config.title);
            tRow.insert( tHeader );
        }
        if( config.emptyColumn )
        {
            tRow = createTRow( config.headClass, "center" );
            head.insert( tRow );
            
            config.emptyColumn.each( function( col ) {
                tHeader = createCell( "th", col.attrs ? col.attrs : {} );
                tHeader.update(config.header);
                tRow.insert( tHeader );
            } );
        }
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
                tHeader.innerHTML = col.header;
                tRow.appendChild( tHeader );
            }
            else {
                tHeader = config.table.select( "th[class~=" + col.key + "]" )[0];
            }
            if( tHeader && ( col.sortable || ( col.sortable == null && config.allSortable ) ) ) {
                tHeader.insert( createSortLink( col.key, col.sortRule ) );
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
        if( config.pageSize > 0 )
        {
            tHeader = new Element( "th" );
            tHeader.writeAttribute("colSpan", colCounter);
            page = new GroupTable.Page( tHeader, config.pageSize, pageChange, config.group );
            
            tRow = createTRow( "tbBlue2", "right" );
            tRow.insert( tHeader );
            
            var foot = new Element( "tfoot" );
            foot.insert( tRow );
            config.table.insert( foot );
        }
    }
    buildUI();
    
    function createCounter( column, split )
    {
        if( !split ) { split = []; }
        split.unshift( column[0].key );
        
        var tBody = new Element( "tbody" );
        config.table.insert( tBody );
        
        var tRow, tData, rowIndex = 0;
        column.each( function( col ) {
            if( split[rowIndex] == col.key )
            {
                tRow = createTRow( "tbBlue2", "center" );
                tBody.insert( tRow );
                rowIndex++;
            }
            
            tData = createCell( "td", col.attrs );
            if( col.text ) {
            	tData.update(col.text)
            } else {
            	col.td = tData;
            }
            tRow.insert( tData );
        } );
        return new GroupTable.Counter( column, tBody );
    }
    
    function createSortLink( key, sortRule )
    {
        var link = new Element( "a" ).writeAttribute( "href", "#" ).update(SORT_NONE);
        link.observe('click', function() {
            this.update(this.innerHTML == SORT_DECREASE ? SORT_INCREASE : SORT_DECREASE);
            sort( key, this.innerHTML, sortRule );
        });
        sortLinks.push( link );
        return link;
    }
    
    function cleanSortLink()
    {
        sortLinks.each( function( link ) { link.innerHTML = SORT_NONE; } );
    }
    
    function createTRow( className, align )
    {
        return new Element( "tr" ).addClassName(className).writeAttribute("align", align);
    }
    
    function createCell( tag, attrs )
    {
        var cell = new Element(tag);
        for( var attr in attrs ) { cell.writeAttribute( attr, attrs[attr] ); }
        return cell;
    }
    
    function render( records )
    {
        var tRow, tData, rowIndex, value, cloneRecord;
        records.each( function( record, index ) {
            record.tRows = new Array();
            rowIndex = 0;
            
            column.each( function( col ) {
                value = record[col.key];
                tData = createCell( "td", col.attrs );
                if( col.render )
                {
                    value = col.render( record, value, tData );
                    if( typeof( value ) == "string" ) {
                        value = new Template( value ).evaluate( record );
                    }
                }

                if(Object.isUndefined(value) || value == null){
                	tData.update(!config.showNull?"":value);
                } else if(Object.isString(value) || Object.isNumber(value)) {
                	tData.update(value);
                } else if(Object.isElement(value)) {
                	tData.insert(value);
                } else {
                    tData.update((Object.keys(value).length == 0 && !config.showNull ) ? "" : value);
                }

                if( split[rowIndex] == col.key )
                {
                    tRow = createTRow( "", "center" );
                    record.tRows[rowIndex++] = tRow;
                }
                if( col.group )
                {
                    if( index == 0 || records[index-1][config.group] != record[config.group] ) {
                        tData.rowSpan = groups[record[config.group]];
                    }
                    else { return; }
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
    
    function refresh()
    {
        var color;
        allRecords.each( function( record, index ) {
            color = !config.group ? index % 2 == 0 : ( ( index == 0 || allRecords[index-1][config.group] != record[config.group] ) ? !color : color );
            record.tRows.each( function( tRow ) {
                tRow.writeAttribute( "className", color ? "tbYellow2" : "tbBlue3" );
                body.insert( tRow );
            } );
        } );
        if( page ) { page.refresh( allRecords ); }
        // add event handel
		for (var i=0;i<listeners.length;i++) {
			 var listener = listeners[i];
			 if (listener.name == 'afterRender' ) { listener.handler(allRecords); }
		}
    }
    
    function reload()
    {
        var oldBody = body;
        body = new Element( "tbody" );
        config.table.replaceChild( body, oldBody );
        
        if( config.group )
        {
            groups = {};
            var groupKey;
            allRecords.each( function( record ) {
                groupKey = record[config.group];
                groups[groupKey] = ( groups[groupKey] || 0 ) + 1;
            } );
        }
        render( allRecords );
    }
    
    function sort( key, direction, sortRule, notRefresh )
    {
        sorter.sort( allRecords, key, direction, sortRule );
        if( notRefresh ) { return; }
        if( config.group ) { reload(); }
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
    
    this.load = function( newRecords )
    {
        if( !newRecords ) { newRecords = []; }
        allRecords = newRecords;
        reload();
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

        allRecords[index].tRows.each( function( tRow ) { tRow.remove(); } );
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

GroupTable.Sorter = function()
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

GroupTable.Counter = function( column, counterBody )
{
    display( "none" );
    
    this.count = function( records )
    {
        display( records.length == 0 ? "none" : "block" );
        column.each( function( col ) {
            if( col.text ) { return; }
            var sum = col.counter ? col.counter( records, col.key ) : sumUp( records, col.key );
            if( col.render ) { sum = col.render( sum ); }
            col.td.innerHTML = "" + sum;
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

GroupTable.Page = function( tHeader, pageSize, pageChange, groupKey )
{
    var records = [], groups = [];
    var recordSize = 0;
    var begin = 0, end = 0;
    var currentPage = 0;
    var totalPage = 1;
    var pageInfo = new Element( "span" );

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
        var image = new Element( "img" );
        image.writeAttribute( "src", "../../../images/CM/" + src );
        image.onclick = action;
        tHeader.insert( image );
    }
    
    function showPage( pageNo )
    {
        if( pageNo == currentPage || pageNo > totalPage || pageNo < 1 ) { return; }
        
        display( false );
        currentPage = pageNo;
        end = pageNo * pageSize;
        begin = end - pageSize;
        if( end > recordSize ) { end = recordSize; }
        display( true );

        pageInfo.update("&nbsp;²Ä" + currentPage + "­¶/¦@" + totalPage + "­¶  ¦@" + records.length + "µ§&nbsp;");
        
        pageChange();
    }
    
    function display( isShow )
    {
    	var controlRowDisplay = function(tRow){
        	if(isShow){
        		tRow.show();
        	}else{
        		tRow.hide();
        	}
    	};

        if( groupKey )
        {
            for( var i = begin; i < end; i++ )
            {
                groups[i].each( function( record ) {
                    record.tRows.each( controlRowDisplay );
                } );
            }
            return;
        }
        for( var i = begin; i < end; i++ ) {
            records[i].tRows.each( controlRowDisplay );
        }
    }
    
    this.refresh = function( newRecords )
    {
        if( groupKey )
        {
            var keep, group;
            groups = [];
            newRecords.each( function( record ) {
                if( keep != record[groupKey] )
                {
                    keep = record[groupKey];
                    group = [ record ];
                    groups.push( group );
                }
                else {
                    group.push( record );
                }
            } );
        }
        
        records = newRecords;
        recordSize = groups.length || records.length;
        begin = 0;
        end = recordSize;
        currentPage = 0;
        totalPage = Math.max( Math.ceil( recordSize / pageSize ), 1 );
        showPage( 1 );
    }
    
    this.info = function() { return { begin: begin, end: end, current: currentPage, total: totalPage }; }
}