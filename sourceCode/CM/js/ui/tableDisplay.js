var SORT_NONE = "\u25C6";
var SORT_INCREASE = "\u25B2";
var SORT_DECREASE = "\u25BC";

function TableUI( config )
{
    var column = config.column;
    var split = config.split ? config.split : [];
    var allRecords = [];
    var sorter = new Sorter();
    var sortLinks = [];
    var body, counter, subCounter, page;
    
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
        var head = document.createElement( "thead" );
        if( config.title )
        {
            tRow = createTRow( config.headClass, "center" );
            head.appendChild( tRow );
            
            var attrs = { colSpan: colCounter };
            if( config.titleClass ) { attrs.className = config.titleClass; }
            tHeader = createCell( "th", attrs );
            tHeader.innerHTML = config.title;
            tRow.appendChild( tHeader );
        }
        if( config.emptyColumn )
        {
            tRow = createTRow( config.headClass, "center" );
            head.appendChild( tRow );
            
            config.emptyColumn.each( function( col ) {
                tHeader = createCell( "th", col.attrs ? col.attrs : {} );
                tHeader.innerHTML = col.header;
                tRow.appendChild( tHeader );
            } );
        }
        for( var i = 0, rowIndex = 0; i < column.length; i++ )
        {
            col = column[i];
            if( split[rowIndex] == col.key )
            {
                tRow = createTRow( config.headClass, "center" );
                head.appendChild( tRow );
                rowIndex++;
            }
            if( col.header )
            {
                tHeader = createCell( "th", col.attrs );
                tHeader.innerHTML = col.header;
                if( col.sortable || ( col.sortable == null && config.allSortable ) ) {
                    tHeader.appendChild( createSortLink( col.key, col.sortRule ) );
                }
                tRow.appendChild( tHeader );
            }
        }
        config.table.appendChild( head );
        
        // body
        body = document.createElement( "tbody" );
        config.table.appendChild( body );
        
        if( config.subtotalColumn ) {
            subCounter = createCounter( config.subtotalColumn, config.subtotalSplit );
        }
        if( config.totalColumn ) {
            counter = createCounter( config.totalColumn, config.totalSplit );
        }
        
        // foot
        if( config.pageSize > 0 )
        {
            tHeader = document.createElement( "th" );
            tHeader.setAttribute( "colSpan", colCounter );
            page = new Page( tHeader, config.pageSize, pageChange );
            
            tRow = createTRow( "tbBlue2", config.pageFootAlign ? config.pageFootAlign : "right" );
            tRow.appendChild( tHeader );
            
            var foot = document.createElement( "tfoot" );
            foot.appendChild( tRow );
            config.table.appendChild( foot );
        }
    }
    buildUI();
    
    function createCounter( column, split )
    {
        if( !split ) { split = []; }
        split.unshift( column[0].key );
        
        var tBody = document.createElement( "tbody" );
        config.table.appendChild( tBody );
        
        var tRow, tData, rowIndex = 0;
        column.each( function( col ) {
            if( split[rowIndex] == col.key )
            {
                tRow = createTRow( "tbBlue2", "center" );
                tBody.appendChild( tRow );
                rowIndex++;
            }
            
            tData = createCell( "td", col.attrs );
            if( col.text ) { tData.innerHTML = col.text; }
            else { col.td = tData; }
            tRow.appendChild( tData );
        } );
        return new Counter( column, tBody );
    }
    
    function createSortLink( key, sortRule )
    {
        var link = document.createElement( "a" );
        link.setAttribute( "href", "#" );
        link.innerHTML = SORT_NONE;
        link.onclick = function() {
            this.innerHTML = this.innerHTML == SORT_DECREASE ? SORT_INCREASE : SORT_DECREASE;
            sort( key, this.innerHTML, sortRule );
        }
        sortLinks.push( link );
        return link;
    }
    
    function cleanSortLink()
    {
        sortLinks.each( function( link ) { link.innerHTML = SORT_NONE; } );
    }
    
    function createTRow( className, align )
    {
        var tRow = document.createElement( "tr" );
        tRow.setAttribute( "className", className );
        tRow.setAttribute( "align", align );
        return tRow;
    }
    
    function createCell( tag, attrs )
    {
        var cell = document.createElement( tag );
        for( var attr in attrs ) { cell.setAttribute( attr, attrs[attr] ); }
        return cell;
    }
    
    function render( records )
    {
        var tRow, tData, rowIndex, value, cloneRecord;
        records.each( function( record ) {
            record.tRows = new Array();
            rowIndex = 0;
            
            column.each( function( col ) {
                value = record[col.key];
                if( col.render )
                {
                    cloneRecord = Object.clone( record );
                    value = col.render( cloneRecord, value );
                    if( typeof( value ) == "string" ) {
                        value = new Template( value ).evaluate( cloneRecord );
                    }
                }
                
                tData = createCell( "td", col.attrs );
                if( Object.isElement( value ) ) { tData.appendChild( value ); }
                else {
                    tData.innerHTML = ( ( value == null || Object.keys( value ).length == 0 ) && !config.showNull ) ? "" : value;
                }
                
                if( split[rowIndex] == col.key )
                {
                    tRow = createTRow( "", "center" );
                    record.tRows[rowIndex++] = tRow;
                }
                tRow.appendChild( tData );
            } );
        } );
        
        records.each( function( record, index ) {
            record.tRows.each( function( tRow ) {
                tRow.setAttribute( "className", index % 2 == 0 ? "tbYellow2" : "tbBlue3" );
                body.appendChild( tRow );
            } );
        } );
    }
    
    function pageChange()
    {
        if( !page ) { return; }
        
        var pageInfo = page.info();
        if( subCounter ) { subCounter.count( allRecords.slice( pageInfo.begin, pageInfo.end ) ); }
        if( config.pageChange ) { config.pageChange( pageInfo ); }
        showTable();
    }
    
    this.pageInfo = function() { return page ? page.info() : null; }
    
    function refresh()
    {
    	/**
        allRecords.each( function( record, index ) {
            record.tRows.each( function( tRow ) {
                tRow.setAttribute( "className", index % 2 == 0 ? "tbYellow2" : "tbBlue3" );
                body.appendChild( tRow );
            } );
        } );
        */
        if( page ) { page.refresh( allRecords ); }
    }
    
    function sort( key, direction, sortRule )
    {
        sorter.sort( allRecords, key, direction, sortRule );
        refresh();
    }
    this.sort = sort;
    
    this.repaint = function( records )
    {
        var oldTRows = records.pluck( "tRows" );
        render( records );
        records.each( function( record, index ) {
            record.tRows.each( function( tRow, rowIndex ) {
                tRow.setAttribute( "className", oldTRows[index][rowIndex].getAttribute( "className" ) );
                body.replaceChild( tRow, oldTRows[index][rowIndex] );
            } );
        } );
        
        if( counter ) { counter.count( allRecords ); }
        if( subCounter ) {
            var pageInfo = page.info();
            subCounter.count( allRecords.slice( pageInfo.begin, pageInfo.end ) );
        }
    }
    
    function inPage(index) {
		var pageStartNo = page.info().begin;	
		var pageEndNo = page.info().end;		
		if ( ( index * 1 > pageStartNo * 1 ) && ( index * 1 <= pageEndNo * 1 ) ) {
			return true;
		} else {
			return false;
		}
	}
	
	function showTable(){	
	
        var oldBody = body;
        body = document.createElement( "tbody" );
        config.table.replaceChild( body, oldBody );
        
        var show = new Array();
        for (var i=0;i<allRecords.length;i++) {
			if ( inPage(i+1) ) {				
				show.push( allRecords[i] );
			}
		}
		
        render( show );
	}
	
    this.load = function( newRecords )
    {
        if( !newRecords ) { newRecords = []; }
        
        
        allRecords = newRecords;
        
        refresh();
        showTable();
        
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

function Page( tHeader, pageSize, pageChange )
{
    var records = [];
    var begin = 0, end = 0;
    var currentPage = 0;
    var totalPage = 1;
    var pageInfo = document.createElement( "span" );
    
    function buildPageUI()
    {
        addControl( "previous2.gif", function() { showPage( 1 ); } );
        addControl( "previous1.gif", function() { showPage( currentPage - 1 ); } );
        addControl( "next1.gif", function() { showPage( currentPage + 1 ); } );
        addControl( "next2.gif", function() { showPage( totalPage ); } );
        tHeader.appendChild( pageInfo );
        showPage( 1 );
    }
    buildPageUI();
    
    function addControl( src, action )
    {
        var image = document.createElement( "img" );
        image.setAttribute( "src", "../../../images/CM/" + src );
        image.onclick = action;
        tHeader.appendChild( image );
    }
    
    function showPage( pageNo )
    {
        if( pageNo == currentPage || pageNo > totalPage || pageNo < 1 ) { return; }
        
        //display( "none" );
        currentPage = pageNo;
        end = pageNo * pageSize;
        begin = end - pageSize;
        if( end > records.length ) { end = records.length; }
        //display( "block" ); // table-row
        
        pageInfo.innerHTML = "&nbsp;²Ä" + currentPage + "­¶/¦@" + totalPage + "­¶  ¦@" + records.length + "µ§&nbsp;";
        
        pageChange();
    }
    
    function display( status )
    {
        for( var i = begin; i < end; i++ ) {
            records[i].tRows.each( function( tRow ) { tRow.style.display = status; } );
        }
    }
    
    this.refresh = function( newRecords )
    {
        records = newRecords;
        begin = 0;
        end = records.length;
        currentPage = 0;
        totalPage = Math.max( Math.ceil( records.length / pageSize ), 1 );
        showPage( 1 );
    }
    this.info = function() { return { begin: begin, end: end, current: currentPage, total: totalPage }; }
}