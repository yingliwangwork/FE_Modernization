var UI_Manager = new function(){
	
	var UIConfigs={};
	var config_count = 0;
	
	this.addUIConfig = addUIConfig;
	function addUIConfig( UI_Name , UI ){
		if(!JsUtils.isString(UI_Name)){
			UI_Name = "autoUIid"+config_count;
		}
		UIConfigs[UI_Name] = UI;
		config_count = config_count + 1;
	}
	
	function callResize(){
		for(var key in UIConfigs){
			if(JsUtils.isFunction(UIConfigs[key].resize)){
				UIConfigs[key].resize();
			}
		}
	}
	
	if(window.Prototype){ 
		var callFix = function(){};
		if(!window.fix){ var fix; }
		if( !!(fix && Object.prototype.toString.apply(fix) === '[object Function]')){
			fix = fix.wrap(callResize);
			callFix = fix;
		}else{
			callFix = callResize;
		}

		Event.observe(window, 'resize', callFix);
	}

}




function PaperUI(config){
	
	if(!config){ return; }

	var GroupLevel = config.groupLevel;
	var GroupLevelSetting = {};
	var Columns = config.columns;
	var table = createNewGrid();
	var overDiv;
	
	if( !table ){
		alert("設定值config.table有誤");
		return;
	}
	if( !GroupLevel || !JsUtils.isNotEmptyArray(GroupLevel) ){
		alert("設定值config.groupLevel有誤");
		return;
	}
	if( !Columns || !JsUtils.isNotEmptyArray(Columns) ){ 
		alert("設定值config.column有誤");
		return; 
	}
	
	this.config = config;
	this.overDiv = overDiv;
	
	var defaultValueWhenNull = ( JsUtils.getType(config.defaultValue) !== 'undefined' ) ? config.defaultValue : "\u3000";
	
	var allRecords = [];
	
	var GroupLevelHasObject = false;
	for(var i = 0 ; i < GroupLevel.length ; i = i + 1 ){
		if( JsUtils.isObject(GroupLevel[i]) ){ 
			GroupLevelHasObject = true;
			break;	
		}else if(!JsUtils.isString(GroupLevel[i])){
			alert("config.groupLevel內，第"+i+"欄位設定錯誤");
			return;
		}
	}
	if(GroupLevelHasObject){
		for(var i = 0 ; i < GroupLevel.length ; i = i + 1 ){
			if(JsUtils.isObject(GroupLevel[i])){ 
				var key = GroupLevel[i].key || "emptyGroup"+i;
				GroupLevelSetting[key] = GroupLevel[i];
				GroupLevel[i] = key;
			}	
		}
	}
	
	/*==================================================
		SETTING VARIABLE AREA START
	====================================================*/
	var EMPTY_COLUMN_SET = "systemEmpty";
	
	var EMPTY_FILL_BY_TOP_CELL = "topCelltoFill";
	var EMPTY_FILL_BY_BTM_CELL = "bettomCelltoFill";
	
	var HEAD_SETTING_1 = "headSetting1";
	var HEAD_SETTING_2 = "headSetting2";
	var RECORD_SETTING_1 = "recordSetting1";
	var RECORD_SETTING_2 = "recordSetting2";
	
	var DEFAULT_TABLE_WIDTH = 30000;
	var DEFAULT_MIN_TABLE_RANGE = 50;

	/*==================================================
		SETTING VARIABLE AREA END
	====================================================*/
	
	var headerConfig = createHeader( Columns );
	if(JsUtils.isString(headerConfig)){ 
		alert(headerConfig); return; 
	}
	
	var recordConfig = createRecordFormat(headerConfig);
	if(JsUtils.isString(recordConfig)){ 
		alert(recordConfig); return; 
	}
	
	createGrid( config  , table ,  headerConfig , GroupLevel);
	
	UI_Manager.addUIConfig( table.getAttribute("id") , this );
	
	
	function createNewGrid(){
		var table = JsUtils.getDOM( config.table );
		if(!table ){ return false; }
		var newTable = document.createElement("table");
		newTable.setAttribute("id" , table.getAttribute("id") );
		JsUtils.setClass( newTable , "PaperUI");
		newTable.setAttribute("cellSpacing",0);
		newTable.setAttribute("cellPadding",0);
		newTable.width='100%';
		config.table = newTable;
		
		if(config.overDiv === false){
			table.parentNode.replaceChild( newTable , table );
		}else{
			if(table.parentNode.tagName === "div" ){
				if(JsUtils.compareClass( table.parentNode , "overDiv ")){
					overDiv = table.parentNode;	
					while(overDiv.hasChildNodes()){
						overDiv.removeChild(overDiv.firstChild);
					}
				}else{
					overDiv = document.createElement("div");
					table.parentNode.replaceChild( overDiv , table );
					JsUtils.setClass( overDiv , "overDiv");
				}
			}else{
				overDiv = document.createElement("div");
				table.parentNode.replaceChild( overDiv , table );
				JsUtils.setClass( overDiv , "overDiv");
			}
			overDiv.appendChild(newTable);
		}
		return newTable;
	}
	
	
	function createHeader( Columns ){
		
		Columns = JsUtils.cloneObject(Columns);
		
		var columnSplit = config.split;
		
		var configBySplit = JsUtils.isObject(Columns[0]) && columnSplit && JsUtils.isNotEmptyArray(columnSplit);
		
		var newColumns = [];
		
		var keyGen = 0;
		
		if(configBySplit){
			var activeColumn = [];
			var splitCount = 0;
			newColumns[splitCount] = activeColumn;
			
			for(var i = 0 ; i < Columns.length ; i=i+1){
				if(splitCount <= columnSplit.length && Columns[i].key === columnSplit[splitCount] ){
					splitCount = splitCount + 1 ;
					activeColumn = [];
					newColumns[splitCount] = activeColumn;
				}
				activeColumn[activeColumn.length] = Columns[i];
			}
		}else{
			if(JsUtils.isObject(Columns[0])){
				newColumns[0] = Columns;
			}else if(JsUtils.isNotEmptyArray(Columns[0])){
				newColumns = Columns;
			}else{
				return false;
			};
		}
		
		
		
		for(var i = 0 ; i < newColumns.length ; i = i + 1 ){
			var activeRow = newColumns[i];
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				var settingColumn = activeRow[j];
				if( !settingColumn.empty || settingColumn.empty !== EMPTY_COLUMN_SET ){
					
					if(!settingColumn.key){
						settingColumn.key = "autoKey"+keyGen;
						keyGen = keyGen + 1;
					}
					
					var colSpan = JsUtils.getSpan( settingColumn ,"colSpan");
					var rowSpan = JsUtils.getSpan( settingColumn ,"rowSpan");
	
					for(var k = 1 ; k < rowSpan ; k = k + 1  ){
						for(var l = 0 ; l < colSpan ; l = l + 1  ){
							newColumns[i+k].splice( j , 0 , { empty:EMPTY_COLUMN_SET , key:settingColumn.key } );
						}
					}
					for(var k = 1 ; k < colSpan ; k = k + 1  ){
						j = j + 1;
						activeRow.splice( j , 0 , { empty:EMPTY_COLUMN_SET , key:settingColumn.key } );
					}
				}
			}
		}
		
		var maxLength = newColumns[0].length;
		var isEqualsEveryRow = true;
		for(var i = 1 ; i < newColumns.length ; i = i + 1 ){
			if(maxLength !== newColumns[i].length){
				isEqualsEveryRow = false;
				if(maxLength < newColumns[i].length){
					maxLength = newColumns[i].length;
				}
			}
		}
		if(!isEqualsEveryRow){
			for(var i = 0 ; i < newColumns.length ; i = i + 1 ){
				var activeRow = newColumns[i];
				for(var j = activeRow.length ; j < maxLength ; j = j + 1 ){
					activeRow.splice(activeRow.length,0,{header:"?",key:"autoKey"+keyGen , empty:EMPTY_COLUMN_SET });
					keyGen = keyGen + 1;
				}
			}
		}
		
		var rows = newColumns.length;
		var columnMark = true;
		for( var i = 0 ; i < maxLength ; i = i + 1 ){
			var changeMark = true;
			var saveKey = "";
			for( var j = 0 ; j < rows ; j = j + 1  ){
				var setting = newColumns[j][i];
				if(setting.empty !== EMPTY_COLUMN_SET ){
					saveKey = setting.key;
				}else{
					if(setting.key !== saveKey){
						changeMark = false;
					}
				}
				setting.columnMark = columnMark;
			}
			if(changeMark){
				columnMark = !columnMark;
				for( var j = 0 ; j < rows ; j = j + 1  ){
					newColumns[j][i].columnMark = columnMark;
				}
			}
		}
		return newColumns;
	}
	
	
	function createRecordFormat( headerColumn ){
		
		var headColumnSetting = JsUtils.cloneObject(headerColumn);
		
		for(var i = 0 ; i  < headColumnSetting.length ; i = i + 1 ){
			var activeRow = headColumnSetting[i];
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				var settingColumn = activeRow[j];
				if( settingColumn.empty  && settingColumn.empty === EMPTY_FILL_BY_BTM_CELL ){
					var colSpan = JsUtils.getSpan( settingColumn ,"colSpan");
					var testRow = i + 1;
					do{
						var testCell = checkSelectRowCanSpan ( testRow, j, colSpan, headColumnSetting )
						if( !testCell ) { break; }
						if( !testCell.empty ){
							moveCellFormTo( i , testRow , j , headColumnSetting );
							break;
						}
						testRow = testRow + 1;
					}while(true);
				}
			}
		}
		
		for(var i = headColumnSetting.length-1 ; i  >= 0 ; i = i - 1 ){
			var activeRow = headColumnSetting[i];
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				var settingColumn = activeRow[j];
				if( settingColumn.empty  && settingColumn.empty === EMPTY_FILL_BY_TOP_CELL ){
					var colSpan = getSpan( settingColumn ,"colSpan");
					var testRow = i - 1;
					do{
						var testCell = checkSelectRowCanSpan ( testRow, j, colSpan, headColumnSetting )
						if( !testCell ) { break; }
						if( !testCell.empty ){
							moveCellFormTo( i , testRow , j , headColumnSetting );
							break;
						}
						testRow = testRow - 1;
					}while(true);
				}
			}
		}
		
		for(var i = 0 ; i  < headColumnSetting.length ; i = i + 1 ){
			var activeRow = headColumnSetting[i];
			var allEmpty = true;
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				if(!(activeRow[j].empty && activeRow[j].empty === EMPTY_COLUMN_SET)){
					allEmpty = false;
					break;
				}
			}
			if(allEmpty){
				for(var k = i - 1 ; k >= 0 ; k = k - 1 ){
					var tempRow = headColumnSetting[k];
					var minColSpan = i - k;
					for(var l = 0 ; l < tempRow.length ; l = l + 1 ){
						var tempCell = tempRow[l];
						var rowSpan = JsUtils.getSpan( tempCell , "rowSpan" );
						if( rowSpan > minColSpan){
							JsUtils.setSpan(tempCell , "rowSpan" , rowSpan-1 );
						}
					}
				}
				headColumnSetting.splice(i,1);
				i = i - 1;
			}
		}
		
		return headColumnSetting;
	}
	
	function moveCellFormTo( from , to , startColumn , headColumnSetting){
		if(to == from){ return; }
		
		var changeCell = to > from;
		
		var copyCells = JsUtils.getSpan( headColumnSetting[from][startColumn] , "colSpan" );
		var fromCellRowSpan = JsUtils.getSpan( headColumnSetting[from][startColumn] , "rowSpan" );
		for( var i = 0 ; i < copyCells ; i = i + 1  ){
			var cellNum = startColumn+i;
			var settingToCell =  headColumnSetting[to][cellNum];
			var settingFromCell =  headColumnSetting[from][cellNum];
			if(!settingToCell.empty){
				var settingToCellRowSpan = JsUtils.getSpan( settingToCell , "rowSpan" );

				JsUtils.setSpan( settingToCell , "rowSpan" , settingToCellRowSpan + fromCellRowSpan );
				
				settingFromCell.empty = EMPTY_COLUMN_SET;
				
				if(changeCell){
					headColumnSetting[to][cellNum] = settingFromCell;
					headColumnSetting[from][cellNum] = settingToCell;
				}
			}
		}
	}
	
	
	function checkSelectRowCanSpan( row_num , startColumn , col_num  , headColumnSetting ){
		var testColumnLimit = startColumn-1+col_num;
		if(
		   row_num < 0
		   || headColumnSetting.length <= row_num 
		   || headColumnSetting[row_num].length <= startColumn 
		   || headColumnSetting[row_num].length <= testColumnLimit
		){ return false; }
		
		var testRow = headColumnSetting[row_num];
		if( startColumn > 0 ){
			if( testRow[startColumn-1].key === testRow[startColumn].key ){return false;}
		}
		if( testColumnLimit < (testRow.length-1) ){
			if( testRow[testColumnLimit].key === testRow[testColumnLimit+1].key ){return false;}
		}
		var firstCell = testRow[startColumn];
		var isAllEmpty = firstCell.empty && firstCell.empty === EMPTY_COLUMN_SET;
		for( var i = startColumn ; i <= testColumnLimit ; i = i + 1 ){
			var testCell = testRow[i];
			if(isAllEmpty){
				if( !testCell.empty || testCell.empty !== EMPTY_COLUMN_SET ){ return false;}
			}else{
				if( testCell.empty && testCell.empty !== EMPTY_COLUMN_SET ){return false; }
			} 
		}
		return firstCell;
		
	}
	
	
	function createGrid( config  , table , headerConfig , groupLevel ){
		
		var thead = document.createElement("thead");
		
		var isColSpanTo2 = headerConfig.length === 1;
		
		for(var i =  0 ; i < headerConfig.length ; i = i + 1 ){
			var activeRow = headerConfig[i];
			var tr = document.createElement("TR");
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				var settingColumn = activeRow[j];
				if(settingColumn.empty !== EMPTY_COLUMN_SET){
					var th = document.createElement("TH");
					setAttributeToElement(th , settingColumn.attrs );
					if(isColSpanTo2){
						th.setAttribute("colSpan",2);
					}
					if( i === 0 ){
						JsUtils.setClass( th , "topBorder" );
					}
					JsUtils.setClass( th , "rightBorder" );
					JsUtils.setClass( th , "bottomBorder" );
					JsUtils.setClass( th , settingColumn.columnMark ? HEAD_SETTING_1 : HEAD_SETTING_2);
					
					var value = settingColumn.header || settingColumn.key || defaultValueWhenNull;
					value = createSuperLink( value , settingColumn.headerSuperLink );
					if(!JsUtils.isDOMObject(value)){
						 value = document.createTextNode(value);
					}
					th.appendChild( value );
					tr.appendChild(th);
				}
				
			}
			thead.appendChild(tr)
		}
		
		var desp = JsUtils.isObject(config.desp) ? config.desp : {};
		
		var blankArea = document.createElement("TH");
		blankArea.setAttribute("colSpan" , groupLevel.length );
		blankArea.setAttribute("rowSpan" , isColSpanTo2 ? 1 : headerConfig.length-1 );

		JsUtils.setClass( blankArea , "topBorder" );
		JsUtils.setClass( blankArea , "leftBorder" );
		JsUtils.setClass( blankArea , "rightBorder" );
		JsUtils.setClass( blankArea , HEAD_SETTING_1);
		if(JsUtils.isBasicType(desp.row)){
			blankArea.appendChild(document.createTextNode(desp.row));
		}
		
		var firstTr = thead.firstChild;
		firstTr.insertBefore( blankArea , firstTr.firstChild);
		
		
		var LastTr;
		if(isColSpanTo2){
			LastTr = document.createElement("TR");
			thead.appendChild(LastTr);
		}else{
			LastTr = thead.lastChild;
		}
	
		blankArea = document.createElement("TH");
		blankArea.setAttribute("align","left");
		JsUtils.setClass( blankArea , "rightBorder" );
		JsUtils.setClass( blankArea , "bottomBorder" );
		JsUtils.setClass( blankArea , HEAD_SETTING_1);
		if(JsUtils.isObject(desp.column)){
			var colSpanCount = 0 ;
			for( var i = groupLevel.length - 1 ; i >= 0  ; i = i - 1 ){
				var value = desp.column[groupLevel[i]];
				if(JsUtils.isBasicType(value)){
					if(colSpanCount !== 0 ){
						blankArea.setAttribute("colSpan" , colSpanCount );
						if(LastTr.hasChildNodes()){
							LastTr.insertBefore( blankArea , LastTr.firstChild);
						}else{
							LastTr.appendChild( blankArea );
						}
						blankArea = document.createElement("TH");
						blankArea.setAttribute("align","left");
						JsUtils.setClass( blankArea , "bottomBorder" );
						JsUtils.setClass( blankArea , HEAD_SETTING_1);
					}
					blankArea.appendChild(document.createTextNode(value));
					colSpanCount = 1;
				}else{
					colSpanCount = colSpanCount + 1;
				}
			}
			blankArea.setAttribute("colSpan" , colSpanCount );
			JsUtils.setClass( blankArea , "leftBorder" );
		}else{
			blankArea.setAttribute("colSpan" , groupLevel.length );
		}
		
		if(LastTr.hasChildNodes()){
			LastTr.insertBefore( blankArea , LastTr.firstChild);
		}else{
			LastTr.appendChild( blankArea );
		}
		table.appendChild(thead);
		
		resize();

	}
	
	this.load = load;
	function load(records){
		
		while( table.tBodies && table.tBodies.length > 0){
			table.removeChild( table.tBodies[0] );
		}
		allRecords = JsUtils.isArray(records)?records:[];
		
		createBodies( records , GroupLevel , recordConfig );
		
		resize();
	}
	
	var preHeadSetting;
	var preRecordSetting;

	function createBodies( records , groupLevel , recordConfig ){
		
		var tbody = document.createElement("tbody");
		
		preHeadSetting = HEAD_SETTING_1;
		preRecordSetting = "";
		
		groupLevelSave = {};
		
		for( var i = 0 ; i < records.length ; i = i + 1 ){
		 	groupLevelSave = createRecord( tbody , records[i] , i , groupLevel , groupLevelSave , recordConfig );
		}
		
		table.appendChild(tbody);
			
	}
	
	function createRecord(  tbody , record , record_ser , groupLevel , groupLevelSave , recordConfig  ){

		var stopGroup = -1 ;

		if(JsUtils.isDOMObject( groupLevelSave[groupLevel[groupLevel.length-1]]) ){
			for(var i = 0 ; i <  groupLevel.length ; i = i + 1  ){
				var recordValue = record[groupLevel[i]];
				var saveValue = groupLevelSave[groupLevel[i]];
				saveValue = JsUtils.isDOMObject(saveValue) ? saveValue.getAttribute("orgValue") : 'undefined';
				if( saveValue !== (saveValue === 'undefined' ? JsUtils.getType(recordValue) : recordValue ) ){
					break;
				}
				stopGroup = i;
			}
		}
		var tr = document.createElement("TR");
		var defaultRowSpan = recordConfig.length;
		var colSpanCount = 1;
		var inNewLine = true;
		for(var i = 0 ; i <  groupLevel.length ; i = i + 1  ){
			var value = record[groupLevel[i]];
			value = JsUtils.isBasicType(value) ? value : JsUtils.getType(value);
			if(value !== 'undefined'){
				var activeDOM = groupLevelSave[groupLevel[i]];
				if(i <= stopGroup && JsUtils.isDOMObject(activeDOM) ){
					var rowSpan = parseInt(activeDOM.getAttribute("tempRowSpan") || defaultRowSpan);
					activeDOM.setAttribute("tempRowSpan" , rowSpan + defaultRowSpan );
					activeDOM.setAttribute("rowSpan" , rowSpan + defaultRowSpan );
				}else if( i > stopGroup){
					for( var j = 1 ; j < colSpanCount ; j = j + 1 ){
						var removeDOM = groupLevelSave[groupLevel[i-j]];
						if(JsUtils.isDOMObject(removeDOM)){
							removeDOM.removeAttribute("tempRowSpan");
							removeDOM.removeAttribute("orgValue");
						}
						groupLevelSave[groupLevel[i-j]] = "";	
					}
					var td = document.createElement("TD");
					if(inNewLine){
						JsUtils.setClass( td , "leftBorder");
						preHeadSetting = preHeadSetting === HEAD_SETTING_2 ? HEAD_SETTING_1 : HEAD_SETTING_2;
					}
					JsUtils.setClass( td , preHeadSetting);
					JsUtils.setClass( td , "rightBorder");
					JsUtils.setClass( td , "bottomBorder");
					td.setAttribute("align" , "center" );
					td.setAttribute("colSpan" , colSpanCount );
					td.setAttribute("rowSpan" , defaultRowSpan );
					td.setAttribute("orgValue" , value );
					
					var groupLevelSetting = GroupLevelSetting[groupLevel[i]];
					if(JsUtils.isObject(groupLevelSetting)){
						setAttributeToElement(td , groupLevelSetting.attrs );
						value = createSuperLink( value , groupLevelSetting.superLink , record );
					}
					if(!JsUtils.isDOMObject(value)){
						value = document.createTextNode(value);
					}
					td.appendChild(value);
					tr.appendChild(td);
					groupLevelSave[groupLevel[i]] = td;
					activeDOM = td;
				}	
				colSpanCount = 1;
				inNewLine = false;
			}else{
				colSpanCount = colSpanCount + 1;
			}
		}

		preRecordSetting = preRecordSetting === RECORD_SETTING_1 ? RECORD_SETTING_2 : RECORD_SETTING_1 ;
		
		for(var i =  0 ; i < recordConfig.length ; i = i + 1 ){
			var activeRow = recordConfig[i];
			for(var j = 0 ; j < activeRow.length ; j = j + 1 ){
				var settingColumn = activeRow[j];
				var td = document.createElement("TD");
				setAttributeToElement(td , settingColumn.attrs );
				tr.setAttribute("record_serial", record_ser);
				var value = record[settingColumn.key];
				if( JsUtils.isFunction(settingColumn.render)){
					value = settingColumn.render( cloneObject(record) , cloneObject(value) , record_ser );
				}
				if( JsUtils.isString(settingColumn.datatype) || JsUtils.isObject(settingColumn.datatype) ){
					var datatypeIsString =  JsUtils.isString(settingColumn.datatype);
					var datatype = ( datatypeIsString ? settingColumn.datatype : settingColumn.datatype.type ).toLowerCase();
					if(datatype =="number"){
						td.setAttribute("align" , "right" );
						value = formatIntegerByPatten( value ,  datatypeIsString?null:settingColumn.datatype.pattern );
					}
				}
				value = JsUtils.isBasicType(value) ? value : JsUtils.getType(value);
				value = createSuperLink( value , settingColumn.superLink , record );
				if(!JsUtils.isDOMObject(value)){
					value = document.createTextNode( value !== 'undefined' ? value || defaultValueWhenNull : defaultValueWhenNull );
				}
				JsUtils.setClass( td , preRecordSetting+(settingColumn.columnMark ? "_2" : "_1") );
				JsUtils.setClass( td , "rightBorder");
				JsUtils.setClass( td , "bottomBorder");
				td.appendChild( value );
				tr.appendChild(td);
			}
			tbody.appendChild(tr);
			tr.setAttribute("record_serial", record_ser);
			tr = document.createElement("TR");
		}
		
		
		return groupLevelSave;
	}

	function createSuperLink( value , LinkSetting , record ){
		if(!JsUtils.isObject(LinkSetting) || value === 'undefined' || value === '' ){ return value; }
		if(JsUtils.isFunction(LinkSetting.genRule) && !LinkSetting.genRule(record)){ return value; }
		var superLink = document.createElement("a");
		if(LinkSetting.onclick && JsUtils.isFunction(LinkSetting.onclick)){
			superLink.setAttribute("href","#");
			superLink.onclick = LinkSetting.onclick;
		}else if(LinkSetting.href){
			if(JsUtils.isString(LinkSetting.href)){
				superLink.setAttribute("href",LinkSetting.href);
			}else if(JsUtils.isFunction(LinkSetting.href) && JsUtils.isObject(record) ){
				var href = LinkSetting.href(record);
				if(! href){return value; }
				superLink.setAttribute("href",href);
			}
		}else{
			return value;
		}
		superLink.appendChild(document.createTextNode(value));
		setAttributeToElement(superLink,LinkSetting.attrs,true);
		return  superLink;
	}
	
	this.getAllrecords = getAllrecords;
	function getAllrecords(){
		return JsUtils.cloneObject(allRecords);
	}
	
	this.getRecordBySerial = getRecordBySerial;
	function getRecordBySerial( serial , isCloneObject){
		if(!JsUtils.isNumeric(serial) || !JsUtils.isNotEmptyArray(allRecords) || serial < 0 || serial >= allRecords.length ){return {}; }
		if( isCloneObject === false){
			return allRecords[serial];
		}else{
			return JsUtils.cloneObject(allRecords[serial]);
		}
	}
	
	this.getRecordByElement = getRecordByElement;
	function getRecordByElement( node , isCloneObject){
		
		if(!JsUtils.isDOMObject(node) || !node.parentNode){return {}; }

		while(node.tagName != "BODY" ){
			var serial = node.getAttribute("record_serial");
			if(JsUtils.isNumeric( serial )){ return getRecordBySerial( serial , isCloneObject); }
			node = node.parentNode;
		}
		return {};
	}
	
	function setAttributeToElement( elem , attrs , withoutSpan){
		if( !JsUtils.isDOMObject(elem) || !JsUtils.isObject(attrs) ){ return; }
		for( var attr in attrs ){
			if(withoutSpan && ( attr.toLowerCase() === "rowspan" || attr.toLowerCase() === "colspan" ) ){ continue; }
			elem.setAttribute( attr , attrs[attr]);
		}
	}
	
	function formatIntegerByPatten( value , pattern ){
		if(JsUtils.isNumeric(value) && window.CSRUtil){
			return CSRUtil.$fmt( value , pattern || CSRUtil.defaultPattern || "#,###.####" );
		}
		return value;
	}
	
	this.resize = resize;
	function resize(){
		if(!JsUtils.isDOMObject(overDiv)){ return; }
		var settings = JsUtils.isObject(config.overDiv) ? config.overDiv : {};
		
		// default settings 
		var MIN_DIV_HEIGHT = 500;
		var MAX_TABLE_WIDTH = 50000;
		var MIN_TABLE_TEST = 100;
		
		var settingDivWidth = document.body.offsetWidth-50;
		var settingDivHeight = document.body.offsetHeight-70;
		var settingTableWidth = MAX_TABLE_WIDTH;
		var settingTableHeight = 0;

		//divWidth

		if(JsUtils.isFunction(settings.divWidth)){
			settingDivWidth = settings.divWidth();
		}else if(JsUtils.isNumeric(settings.divWidth)){
			settingDivWidth = settings.divWidth;
		}
		if(JsUtils.isNumeric(settingDivWidth)){
			if(settingDivWidth < 0){
				settingDivWidth = document.body.offsetWidth + settingDivWidth;
			}else if ( settingDivWidth > 0 && settingDivWidth <= 1 ){
				settingDivWidth = document.body.offsetWidth * settingDivWidth;
			}
		}else{
			settingDivWidth = document.body.offsetWidth;
		}

		
		//table width
		if(settings.fixedTableWidth){
			if(JsUtils.isFunction(settings.fixedTableWidth)){
				settingTableWidth = settings.fixedTableWidth();
			}else if(JsUtils.isNumeric(settings.fixedTableWidth)){
				settingTableWidth = settings.fixedTableWidth;
			}else{
				settingTableWidth = settingDivWidth;
			}
		}else{ 
			if(settings.tableWidth){
				if(JsUtils.isNumeric(settings.tableWidth)){
					settingTableWidth = settings.tableWidth;
				}
			}
			var startPosition = 0;
			var endPosition = settingTableWidth;
			var diff2Position = endPosition - startPosition;
			
			table.style.width = diff2Position;
			var settingTableHeight =  table.offsetHeight;
			
			while( diff2Position > MIN_TABLE_TEST ){
				var testTableWidth = (endPosition + startPosition)/2;
				table.style.width = testTableWidth;
				var testTableHeight = table.offsetHeight;
				
				if( testTableHeight > settingTableHeight ){
					startPosition = testTableWidth;
				}else{
					endPosition = testTableWidth;
				}
				diff2Position = endPosition - startPosition;
			}
			if(endPosition < settingDivWidth){
				settingTableWidth = settingDivWidth;
			}else{
				settingTableWidth = endPosition;
			}
			
		}
		
		//divHeight
		if(settings.divHeight){
			if(JsUtils.isFunction(settings.divHeight)){
				settingDivHeight = settings.divHeight();
			}else if(JsUtils.isNumeric(settings.divHeight)){
				settingDivHeight = settings.divHeight;
			}
			if(JsUtils.isNumeric(settingDivHeight)){
				if(settingDivHeight < 0){
					settingDivHeight = document.body.offsetHeight + settingDivHeight;
				}else if ( settingDivHeight > 0 && settingDivWidth <= 1 ){
					settingDivHeight = document.body.offsetHeight * settingDivHeight;
				}
			}else{
				var divOffsetTop = overDiv.offsetTop;
				if( (settingDivHeight - divOffsetTop) > MIN_DIV_HEIGHT){
					settingDivHeight = settingDivHeight - divOffsetTop;
				}
			}
		}else{
			settingDivHeight = settingTableHeight;
		}
		if( settingDivHeight < MIN_DIV_HEIGHT ){
			settingDivHeight = MIN_DIV_HEIGHT;
		}
		
		if(settingDivHeight >= settingTableHeight){ 
			settingDivHeight = settingTableHeight;
			if( settingDivWidth < settingTableWidth ){
				settingDivHeight = settingDivHeight + 18;
			}
		}else if(settingDivWidth == settingTableWidth){
			settingTableWidth = settingTableWidth - 18;
		}
		
		overDiv.style.width = settingDivWidth+'px';
		overDiv.style.height = settingDivHeight+'px';
		table.style.width = settingTableWidth+'px';
	}
	
}











if(! window.JsUtils ){
	window.JsUtils = new function(){
		this.getSpan = getSpan;
		function getSpan( col , span ){
			return col.attrs ? ( col.attrs[span] || 1 ) : 1;
		}
		
		this.setSpan = setSpan;
		function setSpan( col , span , span_num){
			if( !col.attrs ){ col.attrs = {}; }
			col.attrs[span] = span_num;
		}
		
		this.getDOM = getDOM;
		function getDOM( node ){
			if( isString(node) ){
				if(window.Prototype){ 
					return $(node);
				}else{
					var temp_node = document.getElementById(node);
					if(!temp_node){
						temp_node = document.getElementsByName(node);
						if(temp_node.length > 0 ){
							temp_node = temp_node[0];
						}else{
							return false;
							
						}
					}
					node = temp_node;
				}
			}
			return isDOMObject(node) ? node : false ;
		}
		
		this.cloneObject = cloneObject;
		function cloneObject(orgObject){
			var returnObject
			if(isArray(orgObject)){
				returnObject = [];
				for(var i = 0 ; i < orgObject.length ; i = i + 1 ){
					returnObject[i]=cloneObject(orgObject[i]);
				}
			}else if(isObject(orgObject)){
				returnObject = {};
				for(var key in orgObject){
					returnObject[key]=cloneObject(orgObject[key]);
				}
			}else{
				returnObject = orgObject;
			}
			return returnObject;
		}
		
		this.isArray = isArray;		
		function isArray( node ){
			return !!(node && getType(node) === '[object Array]' && isNumeric( node.length ));
		}
		
		this.isNotEmptyArray = isNotEmptyArray;
		function isNotEmptyArray( node ){
			return !!(isArray(node) && node.length > 0);
		}
		
		this.isFunction = isFunction;
		function isFunction( node ){
			return !!(node && getType(node) === '[object Function]');
		}
		
		this.isDOMObject = isDOMObject;
		function isDOMObject( node ){
			return !!( node && node.tagName && node.nodeType == 1); 
		}
		
		this.isObject = isObject;
		function isObject(node){
			return !!( getType(node) == '[object Object]' && !isArray(node) && !isFunction(node) );
		}
		
		this.isString = isString;
		function isString( node ){
			return !!(isBasicType( node ) && getType(node) === '[object String]');
		}
		
		this.isNumeric = isNumeric;
		function isNumeric(node){ return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); } 
		
		this.isBasicType = isBasicType;
		function isBasicType( node ){
			var type = typeof(node);
			return !!( type === 'string' || type ==='number' || type === 'boolean' );
		} 
		
		this.getType = getType;
		function getType(node){
			if(typeof(node) === 'undefined' ) {return "undefined"; }
			return Object.prototype.toString.apply(node);
		}	
		
		this.setClass = setClass;
		function setClass( node , className){
			node.className = ((node.className||"") +" "+ className);
		}
		
		this.getClass = getClass;
		function getClass( node ){
			var classes = node.className;
			if(!classes) { return []; }
			return classes.split(" ");
		}
		
		this.compareClass = compareClass;
		function compareClass(node , compare ){
			compare = compare.toLowerCase();
			var classes = getClass(node);
			for(var i = 0 ; i < classes.length ; i = i + 1 ){
				if(compare === classes[i].toLowerCase()){
					return true;
				}
			}
			return false;
		} 
		
		this.getParentByTagName = getParentByTagName;
		function getParentByTagName(cell , TagName){
			TagName = TagName.toUpperCase();
			if( !isString(cell.tagName) || !cell.parentNode ){return false; }
			while(cell.tagName != TagName ){
				cell = cell.parentNode;
				if(!cell.tagName|| cell.TagName == "HTML" || !cell.parentNode  ){return false; }
			}
			return cell;
		}
		
		
	}
}