/**
 * TableUI v1
 * function: multi key, multi group,
 * limit: split col can't group,  no1 gk to one key[for: page, sort]
 *
 **/

/** @static */
var SORT_NONE = "\u25C6";
/** @static */
var SORT_INCREASE = "\u25B2";
/** @static */
var SORT_DECREASE = "\u25BC";
/** @static */
var separateSign = "&";

/** 
 * @private
 * @class 判斷並取代原本fix function 
 * @author dark liu ws9300604
 * @version 1.00
 * */
/*
var orgWinHeight = 0 ;
var orgWinWidth = 0 ;
var divResize = function( uncheckWindowResize ){
	if(uncheckWindowResize){
		var bodyw = document.body.clientWidth;
		var bodyh = document.body.clientHeight;
		if( !(Math.abs(bodyw-orgWinWidth)>10 || Math.abs(bodyh-orgWinHeight)>10 )){ return; }
		orgWinHeight = bodyh ;
		orgWinWidth = bodyw ;
	}

	$$('div.over_div').each(function(overDiv){
		overDiv.setStyle({'width': "1px"});
	});
	$$('div.over_div').each(function(d){
		//var innerbw = d.parentNode.offsetWidth;
		var innerbw;
		var parent = d;
		while( parent = parent.parentNode ){
			innerbw = parent.offsetWidth;
			if( innerbw > 50 ){
				break;
			}
		}
		
		var usrSettingDivWidth = d.divWidth;
		if(usrSettingDivWidth > 1){
			d.setStyle({'width': usrSettingDivWidth+"px"});
		}else if(usrSettingDivWidth < 0){
			d.setStyle({'width': (innerbw+usrSettingDivWidth)+"px"});
		}else{
			d.setStyle({'width': (innerbw*usrSettingDivWidth)+"px"});
		}
		if(typeof(d.resetDivHeight) == 'function' ){
			d.resetDivHeight();
		}
	});
}*/

/** 
* @private
* @class 判斷並取代原本fix function
* @see divResize 
* @author dark liu ws9300604
* @version 1.00
* */
/*
var callFix = function(){};
if(!window.fix){ var fix; }
if( !Object.isUndefined(fix) && Object.isFunction(fix) ){
	fix = fix.wrap(divResize);
	callFix = fix;
}else{
	callFix = divResize;
}

Event.observe(window, 'resize', callFix);
 */
/**
 *  @public
 *	@class 於頁面上產生一個table，並可依照傳入JSON資料將資料轉換至Table
 *	@param config (Map)
 *	@param config.table (Element) : 對應的table實體，可以不必設定任何參數，本UI在產生時將會進行通用參數設定。
 *	@param config.pageSize (Number) : 每頁顯示的頁數，本UI有另外提供動態更改數量，請見 resetPageSize(pageSize) 。
 *  @param config.simplePageInfo (boolean) : 當有群組時頁數資訊的顯示設定，預設為false(顯示群組數量，資料數量)，或設為true，僅顯示資料數量。
 *	@param config.pageChange (function) : 當換頁時需要觸發之動作，呼叫格式:function(pageNO)
 *	@param config.allSortable (boolean) : 是全部產生排序功能，預設為是。
 *	@param config.afterLoad (function) : 結束Load時需要執行的動作，呼叫格式:function(tableElement);
 *	@param config.split (Array) : 若您需要進行換行，請在此參數輸入換行的欄位key值，該換行沒有限定是否為empty。
 *	@param config.title (String/Element) : 自動產生標頭資訊。
 *	@param config.headClass (String) : 自行定義標頭CSS屬性，預設為深黃色。
 *	@param config.selectNum (false/Number) : 明顯提示的欄位數量，選擇false則不限定數量，(預設為1)
 *	@param config.selectRowWithGroup (boolean) : 明顯提示是否以群組為單位，預設為否
 *  @param config.rowClick (function) : 定義當row換色時的自訂動作，呼叫格式:function(TR,dataObj);
 *	@param config.fixedColumns (boolean) : 是否使用欄位的點選浮動功能，預設為是。
 *	@param config.whenDataNull (String) : 當資料是Null時，用此參數代換。
 *	@param config.overDiv (boolean/Map) : 若輸入false，則不使用overDiv(fixedColumn也會關閉)，預設為開。
 *	@param config.overDiv.alwaysFixedSize : 永遠使用設定的高，寬，不要自動調整。
 *	@param config.overDiv.tableWidth (Number) : 設定table寬度，預設為1800，若產生折行，請自行加大此參數。
 *	@param config.overDiv.divHeight (Number) : 定義div的最大高度，若不設定則高度永遠追隨table高度。 	
 *	@param config.overDiv.divWidth	(Number) : 定義div的寬度，設定 0 ~ 1 則設定為可用最大寬度乘上該值，大於1，則Div固定為該值，小於0，則由最大寬度減去該值
  *	@param config.overDiv.bottomSpace	(Number) : 定義div的與頁面下方之預留空間，預設是絕對不會超過該頁面。
 *	@param config.autoCheckBox (Map): 因資料產生非全部產生，若需使用checkBox選擇資料請設定此項。
 *	@param config.autoCheckBox.isSelectAll (boolean) : 是否在標頭產生全選。
 *	@param config.autoCheckBox.withoutGroup (boolean) : 是否依照群組產生checkBox按鍵
 *	@param config.autoCheckBox.text (String) : 標頭產生文字，預設為'選取'。
 *	@param config.autoCheckBox.type (String) : 使用 radio 或是 checkBox 型態，預設為checkBox，且使用radio時，autoSelectAll自動失效。
 *	@param config.autoCheckBox.valueKey (String) : 每個checkBox上所需要附加的value的Key值。 
 *	@param config.autoCheckBox.insertPosition (Number) : 欄位插入的位置，預設為0(第一個)
 *	@param config.autoCheckBox.attrs (Map) : 此欄位屬性。
 *	@param config.autoCheckBox.returnValue	(String/Array) : 依據此屬性，呼叫 getCheckedRecord() 時將會給予設定的值，若不設定直接回傳Map。
 *	@param config.autoCheckBox.action (function(Element checkbox , boolean boxStatus , Array records) ) : 點選欄位之後進行的動作，第三個參數回傳值會依照returnValue設定格式回傳。
 *	@param config.autoCheckBox.genRule ( function( Map record ) ) : 產生checkBox條件，請回傳boolean值。(注意：一開始若沒有產生，之後進行資料修改也不會產生！)
 *	@param config.column (Array) : 使用者定義的標頭資訊。
 *	@param config.column.key (String) : 此欄位對應的資料Key值。
 *	@param config.column.header (String) : 此欄位於標頭時所要顯示的文字。
 *	@param config.column.empty (String) : 設定此欄位不顯示在資料列中，請設定 rowSpan_down : 由下方欄往上合併，rowSpan_up : 由上方欄往下合併，請注意，設定該值後僅有 key header attrs 有效。 
 *	@param config.column.attrs (Map) : 加入此欄位所需屬性。ex:{ colSpan:2 ,rowSpan:3, ...  }
 *	@param config.column.sortable (boolean) : 是可以以排序此標籤，若未設置，預設值為config.allSortable。
 *	@param config.column.sortRule (String) : 排序資料以 number 型態或以 String 型態排序
 *	@param config.column.fixedColumn (bool) :  單獨設定該欄是可以固定，預設皆為開。
 *	@param config.column.groupKey (Array) : 欄位是否需要與前/後筆資料結合，請輸入結合欄位。注意：產生資料時請先對資料做好排序，以免發生欄位破碎狀況。 
 *	@param config.column.render ( function( Map record , String value) ) : 產生資料時是否需要進行資料的更動，若設置此項，資料將以return值呈現。 
 *	@param config.column.renderInCount ( boolean ) : 小計合計資料是否需要套用render function 預設為false
  *	@param config.column.exportNumber ( boolean ) : 是否將數字欄位輸出強制換成數字型態，預設為是。
 *  @param config.column.escapeOff (boolean) : 設定是否代換"&"為"&amp;"，預設為false(進行代換);
 *	@param config.column.input (Map) : 自動產生一個可供輸入的欄位。
 *	@param config.column.input.type (String) : 可使用五種型態 'text' 'date' 'select' 'button' 'radio'。
  *	@param config.column.input.maxlength (number) : 僅對 text , number 有效，設定該欄位最多輸入字數。
 *	@param config.column.input.width (number) : 僅對 text , number 有效，設定該值顯示大小。
 *	@param config.column.input.size (number) : 僅對 text , number 有效，設定欄位可輸入自數大小。
 *	@param config.column.input.opts (Map) : 僅對 select 有效，此將成為該select選項。
  *	@param config.column.easyEdit (bool) : 快速的切換修改資料
*	@param config.column.input.text (String) : 僅對 button radio 有效，此將取代原來值，呈現在button上(或radio右方)。
 *	@param config.column.input.imgBase (String) : 僅對date有效，給予imageBase路徑。 ex:<%=imageBase%>
 *	@param config.column.input.action ( function ) : 當對input進行更動時所要呼叫的動作。對於輸入欄位，參數條件為 function( Element inputNode , Array Records , Element<Div> TextElement , String orgData<數值變換前的資料> ,  boolean isOnChange )，選取類型之input為 function( Element inputNode , Array Records , Element<Div> TextElement ,  boolean isOnChange )
 *	@param config.column.input.genRule ( function( Map record , String value) ) : 當產生時需要隱藏的條件，若回傳true則顯示，反之。若不設定則預設式顯示。
 *	@param config.column.input.keyPress ( function( inputNode ) ) : onkeypress 時所呼叫的參數，僅於Text，Date有效
 *	@param config.column.input.className ( String ) : 需要加入的CSS類別
 *	@param config.column.input.actionWhenStart ( boolean ) : 控制在產生input時，就先做一次action動作
 *	@param config.column.input.shortTextLength ( number ) : 控制在產生input之TextArea顯現出的簡短文字長度，若不給或0，則依照換行符號縮短。
 *
 *	@author Liang-hsun , Huang ws9300618
 *	@version 1.01
 **/ 
function TableUI( config ){
	
	//========== 共用的參數定義 ==========
	//是否引入localeDisplay
	var hasLocaleDisplay = !!window.localeDisplay;
	
	//定義groupKey : 參數GroupKey X---或是GroupKeys的第一個---X  new : 不支援GroupKeys取得
	var groupKey ;
	//定義sortKeys : 參數sortKeys X---或是GroupKeys的最後一組參數---X new : 不支援GroupKeys取得
	var sortKeys ;
	//使用者定義的column資訊
	var column = config.column;
	//紀錄傳入的records
	var allRecords = [];
	//OverDiv功能，設產生的table可以超過Div，達到資料躺平的功能。
	var overDiv = ( config.overDiv || config.overDiv===false )?config.overDiv:true;
	var resizeDetectionDiv;
	
	//欄位固定功能。
	config.fixedColumns = overDiv===false?false:(Object.isUndefined(config.fixedColumns)?true:config.fixedColumns);

	var sortRecord = [];

	var root_element = null;

	var page;

	var CoverFrame;
	var EditFrame;
	
	bulidUI();
	
	//block:
	//========== 主體創建函式 ==========
	
	/**
	 * @constructor
	 * @private 
	 * @memberOf TableUI
	 * @class 創建主體的Div , table , header , foot , body 等區塊。 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function bulidUI(){
		//建立Div區塊
		if(overDiv!==false){
			//var bodyw = document.body.clientWidth;
			var bodyw;
			var parent = config.table;
			while( parent = parent.parentNode ){
				bodyw = parent.offsetWidth;
				if( bodyw > 50 ){
					break;
				}
			}
			
			var divWidth = overDiv.divWidth?overDiv.divWidth:1;
			var _TableUIDivStyleHeight = '1';
			var _TableUIDivStyleWidth = bodyw;
			if(divWidth > 1){
				_TableUIDivStyleWidth = divWidth
			}else if(divWidth < 0){
				_TableUIDivStyleWidth = bodyw+divWidth;
			}else{
				_TableUIDivStyleWidth = bodyw*divWidth;
			}
			
			if(overDiv && overDiv.alwaysFixedSize ){
				if(overDiv.divHeight){_TableUIDivStyleHeight = overDiv.divHeight;}
			}

			var div = config.table.parentNode;
			if(div.tagName != 'DIV' || div.className != 'over_div' ){
				div = new Element('div');
				div.addClassName('over_div');
				config.table.parentNode.replaceChild(div, config.table);
				div.insert(config.table);
			}
			
			resizeDetectionDiv = new Element("div")
				.setStyle({'position':'absolute','top':'0px','left':'0px','height':'100%','width':'100%' });
			
			Element.insert(document.body,{top:
				new Element("div")
				.setStyle({'position':'absolute','top':'0px','left':'0px','height':'1px','width':'100%' })
				.observe('resize',function(e){ if(!resizeDetectionDiv.getAttribute("again")){ resetDivHeight(); }})
			});
			
			Element.insert(document.body,{top:
				new Element("div")
				.setStyle({'position':'absolute','top':'0px','left':'0px','height':'100%','width':'1px' })
				.observe('resize',function(e){ if(!resizeDetectionDiv.getAttribute("again")){ resetDivHeight(); }})
			}); 
				
			div.setStyle({
				'overflow': 'auto',
				'overflow-x': 'auto',
				'overflow-y': 'visible',
				'background': '#FFFFFF',
				'position':'relative' , 'background':''
			}).insert(resizeDetectionDiv);
			
			
			root_element = div;
			
		}
		//建立table區塊
		var newTable = new Element("TABLE", {
			'id': config.table.id
		});
		newTable.width = config.table.width;
		newTable.className = 'grid';
		newTable.width='100%';
		
		config.table.parentNode.replaceChild( newTable , config.table );
		config.table = newTable;
		
		//建立header區塊，並將傳入的column格式化成矩陣格式
		fotmatColumnInfo(config.column);
		config.head = new Element("THEAD");
		creatHeadPlus( config.head , config.columnPlus );
		config.table.insert(config.head);
		//若有設定title，將title加到header的fixed屬性設定好；
		if(config.title && config.overDiv !== false ){
			config.title.orgOffsetWidth = config.title.offsetWidth+0;
			config.title.className = 'fixedTableTitle';
		}
		//建立body區塊，並將矩陣式的column換成矩陣式的Record產生型態
		//轉換最主要做的就是empty column的轉換。
		fotmatRecordsInfo();
		config.body = new Element("TBODY");
		config.table.insert(config.body);
		//建立換頁控制bar(foot) !! 總計資訊會產生在foot這裡 !!
		config.foot = new Element("TFOOT");
		config.table.insert(config.foot);
		creatFootPlus(config.foot);
		
		if(!root_element){
			root_element = newTable;
		}
		
		if(resizeDetectionDiv){
			newTable.observe('resize',function(e){ if(resizeDetectionDiv.getAttribute("resizing")!='Y'){ resetDivHeight(false); }});
		}
		
		
		//重新定義Div高度
		resetDivHeight(false);
	}
	
	this.show = function(){
		root_element && (root_element.style.display = '');
	}
	
	this.hide = function(){
		root_element && (root_element.style.display = 'none');
	}
	
	//block:
	//========== 格式化Column設定 ==========
	/**
	 * @private
	 * @memberOf TableUI
	 * @param cols {array} 使用這設定的Column資訊
	 * @class 格式化成矩陣式的column設定。
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function fotmatColumnInfo(cols){
		//將原本的split設定轉換成Hash Map方便後面取用
		var splitHash = new Hash();
		if(!cols[0].key){
			cols[0].key = "emptyColumnKey0";
		}
		splitHash.set(cols[0].key,cols[0].key);	
		if(config.split && Object.isArray(config.split) ){
			for(var i = 0 ; i < config.split.length ; i = i + 1 ){
				splitHash.set(config.split[i],config.split[i]);
			}
			config.splitlength = config.split.length + 1 ;
		}else{
			config.splitlength = 1;
		}
		config.splitHash = splitHash;
		
		//開始轉換 column 
		var ColumnPlus = new Array();
		var colSpan = 0;
		var i = 0;
		var rows = -1;
		while(i<cols.length){
			var col = cols[i];
			if(	splitHash.get(col.key) && colSpan == 0  ){ 
				ColumnPlus.push( new Array() );
				rows = ColumnPlus.length - 1;
				col.split = true;
			}
			
			//處理colSpan在矩陣column的位置
			if(colSpan > 0 ){
				ColumnPlus[rows].push( { copy:true , copyType:"colSpan" , key:col.key , attrs:col.attrs , empty:col.empty } );
				colSpan = colSpan - 1;
				if(colSpan == 0 ){
					i = i + 1;
				}
			}else{
				if(!col.key){ col.key = 'emptyColumnKey'+i; }
				
				if(!col.attrs){ col.attrs = {}; }
				//設定固定標頭屬性
				col.attrs.name = col.key||'x';	
				//------  
				//這裡將值設定進去
				ColumnPlus[rows].push( col );
				//------
				
				//順便設定 groupKey 和 sortKeys !!
				if(col.groupKey){
					//自訂定義GroupKey : 來自column資訊
					if( groupKey == null || col.groupKey.length < groupKey.length ){
						groupKey = col.groupKey;
					}			
					//自訂定義sortKeys : 來自column資訊
					if( sortKeys == null || col.groupKey.length > sortKeys.length ){
						sortKeys = col.groupKey;
					}
				}
				//如果有colSpan則下次回圈處理他的位置
				if(col.attrs.colSpan && col.attrs.colSpan > 1 ){
					colSpan = col.attrs.colSpan - 1;
				}else{
					i = i + 1;
				}
			}
		}
		
		//處理rowSpan在矩陣column的位置
		var longest_length = 0;
		for(var i = 0 ; i < ColumnPlus.length ; i = i + 1 ){
			for(var j = 0 ; j < ColumnPlus[i].length ; j = j + 1 ){
				/*if( !ColumnPlus[i][j].copy || ColumnPlus[i][j].copyType == 'colSpan' ){
					if(ColumnPlus[i][j].attrs.rowSpan){
						for(var z = 1 ; z < ColumnPlus[i][j].attrs.rowSpan ; z = z + 1 ){
							if( z+i >= config.splitlength ){  break; }
							ColumnPlus[i+z].splice( j , 0 , { copy:true , copyType:'rowSpan' , key:ColumnPlus[i][j].key , attrs:ColumnPlus[i][j].attrs , empty:ColumnPlus[i][j].empty } );
						}
					}
				}*/
				if(ColumnPlus[i][j].attrs.rowSpan > 1 ){
					if( i+1 >= config.splitlength ){  break; }
					var insertCopyCell = { copy:true , copyType:'rowSpan' , key:ColumnPlus[i][j].key , attrs:Object.clone(ColumnPlus[i][j].attrs) , empty:ColumnPlus[i][j].empty };
					insertCopyCell.attrs.rowSpan = insertCopyCell.attrs.rowSpan - 1;
					ColumnPlus[i+1].splice( j , 0 ,  insertCopyCell );
				}
			}
			if( ColumnPlus[i].length > longest_length ){ longest_length = ColumnPlus[i].length; }
		}
		
		//處理每行未達最高行數狀況，加上empty column
		for(var i = 0 ; i < ColumnPlus.length ; i = i + 1 ){
			if( ColumnPlus[i].length != longest_length ){ 
				for(var j =  ColumnPlus[i].length ; j < longest_length ; j = j + 1 ){
					ColumnPlus[i].push( { header:"Undefined column" , empty:true });
				}
			}
		}
		
		//將長度，矩陣輸出，然後去看看他有沒有設定autoCheckBox
		config.colCounter = longest_length;
		config.columnPlus = ColumnPlus;
		genAutoCheckBox();
	}
	
	/** 
	 * @private
	 * @memberOf TableUI
	 * @class 格式化成矩陣式的Records設定。
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function fotmatRecordsInfo(){
		//先copy一份head設定給Rrecord設定
		var columnPlus = config.columnPlus;
		var recordCol = new Array();
		for(var i = 0 ; i < columnPlus.length ; i = i + 1 ){
			recordCol.push(new Array());
			for(var j = 0 ; j < columnPlus[i].length ; j = j + 1 ){
				recordCol[i].push( Object.clone(columnPlus[i][j]) );
				if(columnPlus[i][j].attrs){
					recordCol[i][j].attrs = Object.clone(columnPlus[i][j].attrs);
				}
			}
		}
		var the_First_Line = 0;
		var the_Last_Line = recordCol.length - 1;
		for(var j = 0 ; j < recordCol[0].length ; j = j + 1 ){
			for(var i = 0 ; i < recordCol.length ; i = i + 1 ){
				if(recordCol[i][j].empty){
					//如果取到empty欄位，而且他是需要從上面的實體欄位往下面長	
					if(recordCol[i][j].empty =='rowSpan_down'){
						var colSpan, valRow;
						//取得目標的colSpan資訊
						for( var k = i + 1 ; k <= the_Last_Line ; k = k + 1 ){
							if(!recordCol[k][j].empty){
								colSpan = (recordCol[k][j].attrs.colSpan || 1)-1 ;
								valRow = k;
								break;
							}
						}
						//alert("  i:"+i+"  j:"+j+"  valRow:"+valRow+"  colSpan:"+colSpan+"  recordCol[i][j].empty:"+recordCol[i][j].empty);
						//若取得目標，要求必須要包含在此列及目標列中間的列，都確保有足夠的空間合併
						if(valRow){
							for( var k = i  ; k < valRow ; k = k + 1 ){
								for( var l = j  ; l <= j+colSpan ; l = l + 1 ){
									if(!recordCol[k][l].empty){
										valRow = -1;
										break;
									}
								}
							}
							//若得以合併，將合併過的empty值加上done
							if(valRow > 0){
								for( var k = i  ; k <= valRow ; k = k + 1 ){
									for( var l = j  ; l <= j+colSpan ; l = l + 1 ){
										if( k == i && l == j){
											recordCol[k][l] = Object.clone(recordCol[valRow][j]);
											recordCol[k][l].attrs.rowSpan = (recordCol[k][l].attrs.rowSpan||1) + valRow - i ; 
										}else{
											//alert("set("+k+","+l+") ==> empty=done");
											recordCol[k][l].empty = 'done';
											recordCol[k][l].copy = true;
										}
									}
								}
							}
						}
					//如果取到empty欄位，而且他是需要從下面的實體欄位往上面長
					}else if(recordCol[i][j].empty =='rowSpan_up'){
						var colSpan, valRow;
						//取得目標的colSpan資訊
						for( var k = i - 1 ; k >= the_First_Line ; k = k - 1 ){
							if(!recordCol[k][j].empty){
								colSpan = (recordCol[k][j].attrs.colSpan || 1)-1 ;
								valRow = k;
								break;
							}
						}
						//若取得目標，要求必須要包含在此列確保有足夠的空間合併，以及中間的列都必需都被合併完成。
						if(valRow){
							for( var k = i  ; k > valRow ; k = k - 1 ){
								for( var l = j  ; l <= j+colSpan ; l = l + 1 ){
									if(!recordCol[k][l].empty){
										valRow = -1;
										break;
									}	
									if(k != i){
										if(recordCol[k][l].empty == 'done' ){
											valRow = -1;
											break;
										}
									}
									
								}
							}
							//若得以合併，將合併過的empty值加上done
							if(valRow > 0){
								for( var l = j  ; l <= j+colSpan ; l = l + 1 ){
									recordCol[valRow][l].attrs.rowSpan = recordCol[valRow][l].attrs.rowSpan + 1;
									recordCol[i][l].copy = true;
								}
							}
						}
					}
					
				}
			}
		}
		//回傳前，去除所有都是copy的欄以及RowSpan過大的處理， 
		for(var i = 0 ; i < recordCol.length ; i = i + 1 ){
			var isCopyRow = true;
			for(var j = 0 ; j < recordCol[i].length ; j = j + 1 ){
				if( !recordCol[i][j].copy  && isCopyRow){ isCopyRow = false; }
			}
			if(isCopyRow){ 
				for(var k = 0 ; k < i ; k = k + 1){
					for(var l = 0 ; l < recordCol[k].length ; l = l + 1 ){
						if(!recordCol[k][l].copy){
							var thisRowSpan = (recordCol[k][l].attrs?(recordCol[k][l].attrs.rowSpan||1):1)-1;
							if( k+thisRowSpan >= i){
								recordCol[k][l].attrs.rowSpan = recordCol[k][l].attrs.rowSpan - 1;
							}
						}
					}
				}
				recordCol.splice( i , 1 );
				i=i-1;
			}
		}
		config.recordCol = recordCol;
	}
	
	
	//block:
	//========== 建立table實體資訊 ==========
	/** 
	 * @private
	 * @memberOf TableUI
	 * @class 建立標題列資訊實體。
	 * @param head : 要加入的table位置
	 * @param cols : 產生資訊所要用的column設定
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function creatHeadPlus(head , cols){
		var tRow;
		//建立title實體
		if( config.title )
        {
			tRow = createTRow( config.headClass||"tbYellow0" , "center" );
            var attrs = { colSpan: config.colCounter };
			var titleHead = createCell( "th", attrs ).update(config.title);
			tRow.insert( titleHead );
			tRow.name = "multiGroupTableTitle";
			head.insert( tRow );	
			config.title = titleHead;
		}
		//開始建立header實體
		var tHead;
		for(var i = 0 ; i < config.columnPlus.length ; i = i + 1 ){
			//建立TR實體，供TD append
			tRow = createTRow( "tbBlue" , "center" );
			for(var j = 0 ; j < config.columnPlus[i].length ; j = j + 1 ){
				var col = config.columnPlus[i][j];
				if( !col.copy ){
					//如果不是copy來的，建立TH實體
					tHead = createCell( "th", col.attrs );
					if( Object.isUndefined( col.header )){
						tHead.update("　");
					}else if( Object.isString( col.header )){
						col.header = col.header.replace('&' ,'&amp;');
						tHead.update(col.header);
					}else if( isNumeric( col.header ) ){
						tHead.update(col.header);
					}else{
						tHead.appendChild(col.header);						
					}
					//如果需要建立固定header設定屬性
					if( overDiv !== false ){
						tHead.className = 'fixedth';
					}
					tHead.seq = j+0;
					//處理若是有fixedColumn
					var fonts = tHead.getElementsByTagName("FONT");
					if(fonts.length > 0 ){
						for(var k = 0 ; k < fonts.length ; k = k + 1 ){ 
							if(config.fixedColumns && col.fixedColumn !== false ){
								fonts[k].seq = j;
								fonts[k].onclick = function(){ fixedColumn( this ); } ;
							}
							fonts[k].removeAttribute("size");
						}
					}else{
						if(config.fixedColumns  && col.fixedColumn !== false ){
							var font = new Element("FONT").update(col.header||"　").observe('click', function(){ fixedColumn( this ); });
							tHead.update();
							font.seq = j; 
							tHead.insert(font);
						}
					}
				
					//處理sort
					if( !col.empty && ( col.sortable || ( col.sortable == null && ( typeof(config.allSortable)=='undefined' || config.allSortable ) ) )){
						 tHead.insert(createSortLink(col.sortRule));
					}
					//把對齊都對到中間
					tHead.align = 'center';
					tRow.insert(tHead);
				}
				
			}
			head.insert( tRow );
		}
	}
	/** 
	 * @private
	 * @memberOf TableUI
	 * @class 建立頁數控制器。
	 * @param foot : 要加入的table位置
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	//產生專用的foot 
    function creatFootPlus(foot){
    	//建立TH供PAGE使用
		var tHeader = new Element( "th" );
		tHeader.setAttribute( "colSpan", config.colCounter );
		//建立TR實體
		tRow = createTRow( "tbBlue2", "right" );
		tRow.insert( tHeader );
		foot.insert( tRow );
		//建立PAGE控制項
		page = new PagePlus( tHeader );
		//設定給FixedColumn用
		if( config.overDiv !== false ){
			tHeader.orgOffsetWidth = tHeader.offsetWidth;
			tHeader.orgOffsetBottom = tHeader.offsetTop + tHeader.offsetHeight;
			tHeader.className = "fixedtfootTh";
			config.footTh = tHeader;
		}
	}
	
	
	//block:
  	//========== 建立table實體資訊的輔助函式 ==========
	
	/** 
	 * @private
	 * @memberOf TableUI
	 * @class 設定遮罩物件。。
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function setCoverFrame(){
		
		if(!CoverFrame){
			CoverFrame = new Element("Div");
			CoverFrame.className = 'tableUICover';
			//CoverFrame.style.display = 'none';
			config.table.parentNode.insert(CoverFrame);
			CoverFrame.onclick = closeCover;
		}
		if(!EditFrame){
			EditFrame = new Element("Div");
			EditFrame.className = 'tableUIEditArea';
			//EditFrame.style.display = 'none';
			config.table.parentNode.insert(EditFrame);
		}
	}
	
	/** 
	 * @private
	 * @memberOf TableUI
	 * @class 產生sortLink連結。。
	 * @param sortRule : 排序的方法為 String 或是 Number
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function createSortLink( sortRule){
		var alink = new Element("A").update(SORT_NONE);
			alink.writeAttribute( "href", "#" );
			alink.writeAttribute( "sortRule", sortRule );
			alink.observe("click" , function(){
				this.innerHTML = this.innerHTML == SORT_DECREASE ? SORT_INCREASE : SORT_DECREASE;
				sort( this.parentNode.name, this.innerHTML, this.sortRule, this );
			});
		return alink;
	}
	
	/**  
	 * @private
	 * @memberOf TableUI
	 * @class 將sortLink排序圖示清除。現只用於load();
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    function cleanSortLink()
    {
		var head = config.head;
		var links = head.getElementsByTagName("A");
		for(var i = 0; i < links.length ; i = i +1 ){
			if( links[i].innerHTML == SORT_INCREASE || links[i].innerHTML == SORT_DECREASE){
				links[i].innerHTML = SORT_NONE;
        	}
		}
		sortRecord = [];
    }
    
    /**   
	 * @private
	 * @memberOf TableUI
	 * @class 產生 TR DOM元素
	 * @param className : 產生元素的CSS
	 * @param align : 物件對齊方式
	 * @param Obj : 附加元素至dataObj
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
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
    
    /**   
	 * @private
	 * @memberOf TableUI
	 * @class 產生任意DOM元素
	 * @param tag : 產生元素的Tag Name
	 * @param attrs : 附加元素的屬性(MAP)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    function createCell( tag, attrs )
    {
		var cell = new Element( tag );
        for( var attr in attrs ) { cell.writeAttribute( attr, attrs[attr] ); }
        return cell;
    }

    /**   
	 * @private
	 * @class 自動產生功能完整的checkBox
	 * @memberOf TableUI
	 * @param className : 產生元素的Tag Name
	 * @param align : 物件對齊方式
	 * @param Obj : 附加元素至dataObj
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function genAutoCheckBox(){
		if(config.autoCheckBox){
			autoCheckBox = config.autoCheckBox;
			//顯示文字 : 預設為 "選取"
			var text = Object.isUndefined(autoCheckBox.text) ? "選取":autoCheckBox.text;
			//回傳值的形態: 可給予 單一參數; 多重參數(Array); 不輸入擇回傳整筆資料;
			var returnValue = autoCheckBox.returnValue ? autoCheckBox.returnValue : [];
			//使用者定義的欄位屬性值
			var attrs = autoCheckBox.attrs ? autoCheckBox.attrs : {};
			//插入位置 : 預設插在第一個(0)
			var insertPosition = autoCheckBox.insertPosition?autoCheckBox.insertPosition : 0;
			//定義valueKey = 一般colmun的GroupKey, 現定義此功能只能在最的的Group使用, 他也將會是此checkBox的Key 
			if(!autoCheckBox.valueKey){ autoCheckBox.valueKey = groupKey?groupKey:column[0].key; }
			//定義未產生欄位中，若有全選(全取消)狀況時, 應該要取消勾選(勾選)的checkBox
			config.table.prepareCheck = new Hash();
			this.prepareCheck = config.table.prepareCheck;
			
			var type = autoCheckBox.type?autoCheckBox.type.toLowerCase():"";
				type = ( type==='checkbox' || type ==='radio' )?type:'checkbox';

			if(type ==='radio'){ autoCheckBox.isSelectAll = false; }

			//是否產生全選checkBox，預設為false
			var isSelectAll = autoCheckBox.isSelectAll === true ||  Object.isFunction(autoCheckBox.isSelectAll);
			
			//產生column定義
			var col = new Hash();
			if(isSelectAll){
				var chk = new Element('input', {
					'type': 'checkBox',
					'name': 'autoCheckAll'
				});
				config.autoCheckEle = chk;
				chk.onclick = function(){ 
					autoCheckAll(this) 
					if( Object.isFunction(autoCheckBox.isSelectAll)){
						 autoCheckBox.isSelectAll(this);
					}
				};
				col.header = document.createDocumentFragment();
				col.header.appendChild( chk );
				if(font!==''){
					var font = new Element('font').update(text);
					col.header.appendChild( new Element('br') );
					col.header.appendChild( font );
				}
			}else{
				col.header=text;
			}
			if(autoCheckBox.action){
				attrs.action = autoCheckBox.action;
			}
			attrs.returnValue = returnValue;
			attrs.parentTable = config.table;
			attrs.rowSpan = !autoCheckBox.doNotRowSpan?config.splitlength:1;
			col.attrs = attrs;
			col.key = "autoCheckBoxs";
			col.sortable=false;
			attrs.name = col.key;
			if(groupKey && !autoCheckBox.withoutGroup ){
				col.groupKey = groupKey ;
			}
			//定義產生的checkbox實體；
			col.render=function(record,value){
				if(config.autoCheckBox.genRule && Object.isFunction(config.autoCheckBox.genRule) && !config.autoCheckBox.genRule(record)){ return "　"; }
				var box=new Element('input', {
					'type': type,
					'name': 'autoCheckBox_'+config.table.id
				});
				box.writeAttribute('funcName', 'autoCheckBox');
				if( config.autoCheckBox.valueKey ){
					box.value=Object.isArray(config.autoCheckBox.valueKey)? record[config.autoCheckBox.valueKey[0]]: record[config.autoCheckBox.valueKey];
				}
				box.observe('click', function(){ clickAutoCheckBox(this); });	
				
				if(config.autoCheckBox.disableRule && Object.isFunction(config.autoCheckBox.disableRule) && config.autoCheckBox.disableRule(record)){ box.setAttribute('disabled',true); }
				return box;
			};
			//將此column設定插入指定的位置
			if(insertPosition == 0 ){config.columnPlus[0][0].split = false;}
			config.columnPlus[0].splice(insertPosition,0,col);
			if(!autoCheckBox.doNotRowSpan){
				for( var i = 1 ; i < config.splitlength; i++ ){
					config.columnPlus[i].splice( insertPosition , 0 , { copy:true , copyType:'rowSpan' } );
				}
				config.colCounter = config.colCounter + 1;
			}else{
				config.columnPlus[0].pop();
			}
			
		}
	}
    
    /**   
	 * @private
	 * @class 自動點選所有的checkBox ( nodes )
	 * @memberOf TableUI
	 * @param node : 全選checkBox實體
	 * @author Liang-hsun , Huang ws9300618
	 * @version 2.00
	 * */
    function autoCheckAll(node){;
    	//autoCheckBox
		checkAll(node.checked);
	}
	
	/**   
	 * @public
	 * @class 自動點選所有的checkBox ( boolean )
	 * @memberOf TableUI
	 * @param node : 全選checkBox實體
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.checkAll = checkAll;
	function checkAll(isChecked){
		isChecked = !!isChecked;
    	var table = config.table;
		
		//前面只是畫面做給使用者看
		var inputs = table.getElementsByTagName("INPUT");
		for(var i = 0 ; i < inputs.length ; i = i + 1 ){
    		if(inputs[i].type == 'checkbox' && inputs[i].funcName == 'autoCheckBox' && !inputs[i].disabled ){
    			inputs[i].checked = isChecked;
    		}
    	}
		
		//真正重點在這邊:是否全選? 是否有點選資料狀態清空， 點選list清空
    	table.autoCheckAll = isChecked;
    	table.autoChecked = 0;
    	table.prepareCheck=new Hash();
    }
	
    /**   
	 * @private
	 * @class 點選checkBox動作
	 * @memberOf TableUI
	 * @param node : 點選checkBox實體
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    function clickAutoCheckBox( node ){
		var action = node.parentNode.action;
    	var table = config.body;
    	//點選任一個，點選狀態激活
    	if(config.autoCheckEle && config.table.autoCheckAll ){
			if( config.table.autoCheckAll != node.checked ){ 
				config.table.autoChecked = config.table.autoChecked + 1;
			}else{
				config.table.autoChecked = config.table.autoChecked - 1;
			}
			if( config.table.autoChecked ){ 
				config.autoCheckEle.checked = false; 
			}else{
				config.autoCheckEle.checked = true; 
			}
		}else{
			if(node.checked){ 
				config.table.autoChecked = config.table.autoChecked + 1;
				if(config.autoCheckEle && config.table.totCheckBox && config.table.totCheckBox == config.table.autoChecked ){
					config.autoCheckEle.checked = true; 
					autoCheckAll(config.autoCheckEle);
				}
			}else{
				config.table.autoChecked = config.table.autoChecked - 1;
			}
			
		}
    	
    	//執行使用者設定函式
    	if(action && Object.isFunction(action)){
    		var inputs = getValueByElement( node , node.parentNode.returnValue );
    		action(node, node.value, inputs );
    	}
    }
    
    /**   
	 * @public
	 * @memberOf TableUI
	 * @class 取得點選所有的資料
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.getCheckedRecord = getCheckedRecord;
	function getCheckedRecord(valueTemplate){
		var returnArray = [];
		if(!allRecords || allRecords.length==0){ return returnArray; }
		if(!config.table.autoCheckAll && !config.table.autoChecked ){ return returnArray; }
		
		valueTemplate = 
			(valueTemplate && (Object.isArray(valueTemplate) || Object.isString(valueTemplate))) 
			? valueTemplate 
			: (
				(config.autoCheckBox.returnValue &&  (Object.isArray(config.autoCheckBox.returnValue) || Object.isString(config.autoCheckBox.returnValue))) 
				? config.autoCheckBox.returnValue 
				: false
			);
		var isTemplateArray = valueTemplate && Object.isArray(valueTemplate);
		
		var actionRec = [];
		var inputs = config.table.getElementsByTagName("INPUT");
		for(var i = 0 ; i < inputs.length ; i = i + 1 ){
			if(inputs[i].funcName == 'autoCheckBox' && inputs[i].checked == !config.table.autoCheckAll && !inputs[i].disabled ){
				actionRec = actionRec.concat(getValueByElement(inputs[i]));
			}
		}
		var perpareRec = [];
		if(config.table.prepareCheck && config.table.prepareCheck.size() > 0 && config.autoCheckBox.valueKey ){
			for( var i = config.table.startLoad ; i <= config.table.endLoad ; i = i + 1 ){
				if(config.table.prepareCheck.get(allRecords[i][config.autoCheckBox.valueKey])){
					if(config.autoCheckBox.genRule && Object.isFunction(config.autoCheckBox.genRule) && !config.autoCheckBox.genRule(allRecords[i])){ continue; }
					if(config.autoCheckBox.disableRule && Object.isFunction(config.autoCheckBox.disableRule) && config.autoCheckBox.disableRule(allRecords[i])){ continue; }
					perpareRec.push(allRecords[i]);
				}
			}
		}		
		
		
		if(config.table.autoCheckAll){
			//假使全選狀況有被點起來的狀況
			var limitLen1 = actionRec.length;
			var limitLen2 = perpareRec.length;
			var countLen1 = 0  ,countLen2 = 0 ;
			
			for( var i = 0 ; i < allRecords.length ; i = i + 1 ){
				var obj = allRecords[i];
				var isVal = true;
				if(countLen1 < limitLen1 && actionRec[countLen1] == obj){ countLen1 = countLen1 + 1;  isVal = false; }else 
				if(countLen2 < limitLen2 && perpareRec[countLen2] == obj){ countLen2 = countLen2 + 1;  isVal = false; }
				if(isVal){
					if(config.autoCheckBox.genRule && Object.isFunction(config.autoCheckBox.genRule) && !config.autoCheckBox.genRule(allRecords[i])){ continue; }
					if(config.autoCheckBox.disableRule && Object.isFunction(config.autoCheckBox.disableRule) && config.autoCheckBox.disableRule(allRecords[i])){ continue; }
					returnArray.push(obj);
				}
			}

		}else{
			returnArray = actionRec.concat(perpareRec);
		}
		
		var newRtn = [];
		for( var i = 0 ; i < returnArray.length ; i = i + 1 ){
			var obj = Object.clone(returnArray[i]);
			if(valueTemplate){
				if(isTemplateArray){
					var temp = {};
					for( var j = 0 ; j < valueTemplate.length ; j = j + 1 ){
						temp[valueTemplate[j]] = obj[valueTemplate[j]];
					}
					newRtn.push(temp);
				}else{
					newRtn.push(obj[valueTemplate]);
				}
			}else{
				newRtn.push(obj);
			}
		}
		return newRtn;
	}
	 /**   
	 * @public
	 * @class 設定當勾選一個chk，要連動另一個chk狀況。
	 * @memberOf TableUI
	 * @param findValue : 尋找的chk
	 * @param checkStstus : 要連動的狀態
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.setAnotherCheckBox = setAnotherCheckBox;
	function setAnotherCheckBox( findValue , checkStatus ){
		if( !findValue || findValue == "" ){ return; }
		if( !config.autoCheckBox.valueKey ){ return; }
		var checks  = config.table.getElementsByTagName("INPUT");
		var checked = false;
		for (var i = 0 ;  i<checks.length ; i=i+1){
			if(checks[i].funcName =="autoCheckBox" && checks[i].value == findValue ){
				checks[i].checked = checkStatus ;
				if(checkStatus){
					config.table.autoChecked = config.table.autoChecked + 1 ;
				}else{
					config.table.autoChecked = config.table.autoChecked - 1 ;
				}
				checked = true;
			}
		}
		if(!checked && config.table.autoCheckAll != checkStatus ){
			config.table.prepareCheck.set(findValue,findValue);	
		}else{
			config.table.prepareCheck.unset(findValue);	
		}
		
	}
    
    
    
    /**   
	 * @public
	 * @class base在group下的sort , 若是上層有Group，上層的順序將不會變動。 
	 * @memberOf TableUI
	 * @param key : 排序欄位key值
	 * @param direction : 排序方向
	 * @param sortRule : 排序種類(String or Number)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    this.sort = sort;
    function sort( key, direction, sortRule, nodeEle , doNotReload )
    {
		if(!key){ return; }
		//取得該欄位
		
		//處理點選紀錄
		for(var i = 0 ; i < sortRecord.length ; i = i + 1 ){
			if(sortRecord[i].key == key ){
				sortRecord.splice(i,1);
				i = i - 1;
			}
		}
		sortRecord.push( {key:key , direction:direction, sortRule:sortRule} );

		if(!allRecords || allRecords.length == 0 ){return;}
		//取得該值下的Group設定
		var colGroup;
		var colLastGroup=false;
		var colSettingGroup = false;
		config.column.each( function(col){
			if(col.key == key){
				colGroup = col.groupKey?col.groupKey:sortKeys;
				colLastGroup = col.groupKey?colGroup[colGroup.length-1]:false;
				colSettingGroup = col.groupKey?colGroup[0]:false;
			}
		} );
		if(colLastGroup && colLastGroup == key) { colLastGroup = false; }
		//取得其上方階層的group
		var sortKey = [];
		if(colGroup){
			for( var i = 0; i < colGroup.length; i = i + 1 ){
				if(colGroup[i] == key ||( colLastGroup && colGroup[i] == colLastGroup )){ 
					break; 
				}
				sortKey.push(colGroup[i]);
			}
		}/*else if(sortKeys){
			sortKey = sortKeys[sortKeys.length-1];
		}*/
		//alert(sortKey);
		//設定sort格式
		if( !sortRule || ( sortRule != "number" && sortRule != "datey" && sortRule != "dateym") ) {
            sortRule = "string";
        }
        //若有sort每一個Group組自行排序，若否全部排序。
		if(sortKey.length > 0 ){
			var start = 0 , end = 0 , length = allRecords.length ;
			var currNode , nextNode;
			for(var i = 0 ; i < length ; i = i +1  ){
				currNode = allRecords[i];
				if( i+1 == length){ nextNode = null; }else{ nextNode=allRecords[i+1]; }
				if(nextNode){
					var isGroupWithPreRec = true  
					for( var j = 0 ; j < sortKey.length ; j = j + 1 ){
						if(currNode[sortKey[j]] != nextNode[sortKey[j]]){
							isGroupWithPreRec = false;
							break;
						}
					}
					if(!isGroupWithPreRec){
						selectionSort( start , end  , key, direction, sortRule);
						start = i + 1;
					}
					end = i + 1;
				}else{
					selectionSort( start , end  , key, direction, sortRule);
				}		
			}
		}else{
			if(colSettingGroup){
				GroupSort(key, direction, sortRule);
				//selectionSort( 0 , allRecords.length -1  , colSettingGroup, direction, sortRule);
			}else{
				selectionSort( 0 , allRecords.length -1  , key, direction, sortRule);
			}
		}
		
		if(!doNotReload){
			if(nodeEle){
				var sortTD = nodeEle;
				while(sortTD.tagName != 'TH'){ sortTD = sortTD.parentNode; }
			}
			//取得該排序欄位原定位
			var beforePosition = (nodeEle && sortTD.className=='fixedth' && overDiv ) ? ( sortTD.offsetLeft - config.table.parentNode.scrollLeft ) : false;
			//alert(sortTD.offsetLeft +" - "+ config.table.parentNode.scrollLeft +" = "+ beforePosition);
			//重新讀取page
			reload();
			page.updatePageInfo();
			
			//若是有設定讀取結束動作，執行!
			if( config.afterLoad && typeof(config.afterLoad)=='function' ){
				config.afterLoad(config.table);
			}
			
			if(beforePosition){
				if( beforePosition+sortTD.offsetWidth > config.table.parentNode.offsetWidth ){
					beforePosition = config.table.parentNode.offsetWidth - sortTD.offsetWidth;
				}
				config.table.parentNode.scrollLeft = sortTD.offsetLeft - beforePosition;
			}
		}
    }
    
	
    /**   
	 * @private
	 * @class selectSort 
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function selectionSort( start , end , key, direction, sortRule){
		//alert("sort --- start: " +start+"  end: "+end );
		if ( start < end ) {
			var selectionPosition;
			var selectionNode;
			var currentNode;
			do{
				selectionPosition = start;
				selectionNode = allRecords[selectionPosition];
				for(var i = 0 ; i <= end-start ; i = i + 1){
					currentNode = allRecords[start+i];
					if(direction == SORT_INCREASE){
						if(sortRule == "number"){
							if( parseFloat(selectionNode[key]||0) > parseFloat(currentNode[key]||0) ){ 
								selectionPosition = start+i;
								selectionNode = allRecords[selectionPosition];
							}
						}
						else{
							if( (selectionNode[key]||"") > (currentNode[key]||"") ){ 
								selectionPosition = start+i; 
								selectionNode = allRecords[selectionPosition];
							}
						}
					}else{
						if(sortRule == "number"){
							if( parseFloat(selectionNode[key]||0) < parseFloat(currentNode[key]||0) ){ 
								selectionPosition = start+i; 
								selectionNode = allRecords[selectionPosition];
							}
						}
						else{
							if( (selectionNode[key]||"") < (currentNode[key]||"") ){
								selectionPosition = start+i;
								selectionNode = allRecords[selectionPosition];
							}
						}
					}
				}
				if(start != selectionPosition ){
					var old = allRecords[start];
					allRecords[start] = allRecords[selectionPosition] ;
					allRecords[selectionPosition] = old;
				}
				start = start + 1;
			}while( start < end )
	 	} 
	}
	/**   
	 * @private
	 * @class GroupSort 
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function GroupSort( sortkey , direction, sortRule ){
		var tempRecs = [];
		var keyRec = false;
		var cability;
		if(! groupKey ){ return;  } 
		//將group組合起來成為新的array
		for( var i = 0 ; i < allRecords.length ; i=i+1 ){
			
			if(!keyRec || keyRec[groupKey] != allRecords[i][groupKey] ){
				keyRec = allRecords[i];
				cability = [];
				tempRecs.push( {key:allRecords[i][sortkey] , records:cability });
			}
			cability.push( allRecords[i] );
		}
		//alert(tempRecs.length);
		//for( var i = 0 ; i < tempRecs.length ; i=i+1 ){
		//	alert("XXX "+tempRecs[i].key+" BBB "+ tempRecs[i].records.length );
		//}
		
		//排序新的array
		var start = 0;
		var end = tempRecs.length - 1;
		var key = "key";
		var selectionPosition;
		var selectionNode;
		var currentNode;
		do{
			selectionPosition = start;
			selectionNode = tempRecs[selectionPosition];
			for(var i = 0 ; i <= end-start ; i = i + 1){
				currentNode = tempRecs[start+i];
				if(direction == SORT_INCREASE){
					if(sortRule == "number"){
						if( parseFloat(selectionNode[key]||0) > parseFloat(currentNode[key]||0) ){ 
							selectionPosition = start+i;
							selectionNode = tempRecs[selectionPosition];
						}
					}
					else{
						if( (selectionNode[key]||"") > (currentNode[key]||"") ){ 
							selectionPosition = start+i; 
							selectionNode = tempRecs[selectionPosition];
						}
					}
				}else{
					if(sortRule == "number"){
						if( parseFloat(selectionNode[key]||0) < parseFloat(currentNode[key]||0) ){ 
							selectionPosition = start+i; 
							selectionNode = tempRecs[selectionPosition];
						}
					}
					else{
						if( (selectionNode[key]||"") < (currentNode[key]||"") ){
							selectionPosition = start+i;
							selectionNode = tempRecs[selectionPosition];
						}
					}
				}
			}
			if(start != selectionPosition ){
				var old = tempRecs[start];
				tempRecs[start] = tempRecs[selectionPosition] ;
				tempRecs[selectionPosition] = old;
			}
			start = start + 1;
		}while( start < end )
		
		// 將排序完成的資料更新至allRecords
		allRecords = [];
		for( var i = 0 ; i < tempRecs.length ; i=i+1 ){
			allRecords = allRecords.concat(tempRecs[i].records);
		} 
	}
	
	/**   
	 * @private
	 * @class 產生頁數控制項 
	 * @memberOf TableUI
	 * @param 	tHeader : 要append的元素TD
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 function PagePlus (tHeader){
	 	//頁數相關資訊
		var pageSize = config.pageSize;
		var recordSize = 0;
		var begin = 0, end = 0;
		var currentPage = 0;
		var totalPage = 0;
		//已產生的page紀錄
		var grnPageMap;
		//附加元素實體位置
		var pageInfo;
	
		this.recordSize = recordSize;
		
		this.getCurrentPage = function(){ return currentPage; }
		this.getTotalPage = function (){ return totalPage; }
		this.getGenPageMap = function(){ return grnPageMap; }
		
		var selectList = new Element("select");
		selectList.style.visibility = 'visible';
		selectList.onchange =  function(){ if(this.value &&this.value!=currentPage ){ setTableInfo({pageNo:parseInt(this.value)}); } } ;
		/**   
		 * @private
		 * @class 產生頁數控制項按鈕及初始文字 
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		function buildPageUI()
		{
			addControl( "previous2.gif", function() { showPage( 1 ); } );
			addControl( "previous1.gif", function() { showPage( currentPage - 1 ); } );
			tHeader.insert(selectList);
			addControl( "next1.gif", function() { showPage( currentPage + 1 ); } );
			addControl( "next2.gif", function() { showPage( totalPage ); } );
			pageInfo = new Element('span');
			tHeader.insert( pageInfo );
			if(groupKey && (!config.simplePageInfo) ){
				pageInfo.innerHTML = "&nbsp;第0頁/共0頁  群組0組/共0筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}else{
				pageInfo.innerHTML = "&nbsp;第0頁/共0頁  共0筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}
			tHeader.onclick = function(){
			/*	alert("expression(table.offsetWidth["+this.parentElement.parentElement.parentElement.offsetWidth
						+"]<=div.offsetWidth["+this.parentElement.parentElement.parentElement.parentElement.offsetWidth
						+"]?0:div.scrollLeft["+this.parentElement.parentElement.parentElement.parentElement.scrollLeft
						+"]- ((th.width["+this.orgOffsetWidth
						+"] - div.width["+parseFloat(this.parentElement.parentElement.parentElement.parentElement.style.width)+"])/2) );  ==");
				alert(this.parentElement.parentElement.parentElement.offsetWidth<=this.parentElement.parentElement.parentElement.parentElement.offsetWidth?0:this.parentElement.parentElement.parentElement.parentElement.scrollLeft - ((this.orgOffsetWidth - parseFloat(this.parentElement.parentElement.parentElement.parentElement.style.width))/2) );
				*/
			}
	
		}
		
		/**   
		 * @private
		 * @class 產生單一頁數控制項按鈕 
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		function addControl( src, action )
		{
			var image = new Element( "img" ).writeAttribute( "src", "../../../images/CM/" + src ).observe('click', action);
			tHeader.insert( image );
		}
		
		/**   
		 * @private
		 * @class 更換頁面，若以產生過的直接修改屬性，若否，送入render產生 
		 * @memberOf TableUI.PagePlus
		 * @param pageNo : 欲產生的頁面
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		 this.showPage = showPage;
		function showPage( pageNo )
		{
			if( pageNo == currentPage || pageNo > totalPage || pageNo < 1 ) { return; }
			
			displayNone();
			currentPage = pageNo;
			
			if(grnPageMap.get(pageNo)){
				displayData( currentPage );
			}else{
				end = pageNo * pageSize;
				begin = end - pageSize;
				if( end > recordSize ) { end = recordSize; }
				var i = 1 
				do{
					if(!grnPageMap.get(i)){break;}
					i=i+1;
				}while(i<pageNo)
				if(i == pageNo || pageNo == 1){
					refresh( end - begin , currentPage );
				}else{
					refresh( begin - end , currentPage );
				}
				grnPageMap.set(pageNo,pageNo);
			}
			if(groupKey && (!config.simplePageInfo) ){
				pageInfo.innerHTML = "&nbsp;第" + currentPage + "頁/共" + totalPage + "頁  群組" + recordSize + "組/共" + allRecords.length + "筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}else{
				pageInfo.innerHTML = "&nbsp;第" + currentPage + "頁/共" + totalPage + "頁  共" + recordSize + "筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}

			if(Object.isFunction(window.autoCreateDate)){ autoCreateDate(config.table); }
			
			if(config.pageChange && Object.isFunction(config.pageChange)){
				config.pageChange(pageNo);
			}
			if( !config.table.totCheckBox && config.table.endLoad - config.table.startLoad < 0 ){
				config.table.totCheckBox = 0;
				var tempinputs = config.body.getElementsByTagName("input");
				for( var m = 0 ; m < tempinputs.length ; m = m + 1 ){
					if( tempinputs[m].funcName == 'autoCheckBox' ){
						config.table.totCheckBox = config.table.totCheckBox + 1;
					}	
				}
				
			}

			selectList.value = pageNo;

			//若是有設定讀取結束動作，執行!
			if( config.afterLoad && typeof(config.afterLoad)=='function' ){
				config.afterLoad(config.table);
			}

			resetDivHeight(false);

		}
		/**   
		 * @private
		 * @class 將全部紀錄隱藏
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		function displayNone()
		{
			var trs = config.body.getElementsByTagName("TR");
			for(var i = 0 ; i < trs.length ; i = i + 1 ){
				trs[i].style.display = 'none';
			};
			var pages = config.body.getElementsByTagName("PAGE");
			for(var i = 0 ; i < pages.length ; i = i + 1 ){
				pages[i].isHide = true;
			}
		}
		/**   
		 * @private
		 * @class 顯示指定頁面
		 * @memberOf TableUI.PagePlus
		 * @param showPage : 欲產生的頁面
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		function displayData( showPage )
		{
			var pages = config.body.getElementsByTagName("PAGE");
			for(var i = 0 ; i < pages.length ; i = i + 1 ){
				if(pages[i].PageID == showPage){
					var trs = pages[i].getElementsByTagName("TR");
					for( var j = 0 ; j < trs.length ; j = j + 1){
						trs[j].style.display = '';	
					}
					pages[i].isHide = false;
				}
			};
		}
		
		/**   
		 * @public
		 * @class 將頁數控制器格式化
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		this.updatePageInfo = updatePageInfo;
		function updatePageInfo()
		{
			reflashTotalCount();
			tHeader.parentNode.style.display = '';
			//若沒有pageSize，直接產生全部的rec，並將原本的資料清除
			pageSize = config.pageSize;
			if( !pageSize ){
				if( allRecords && allRecords.length){
					//alert(allRecords.length);
					refresh( allRecords.length , 1 );
					if(config.pageChange && Object.isFunction(config.pageChange)){
						config.pageChange(0);
					}
				}
				var old_th = tHeader; 
				tHeader.parentNode.style.display = 'none';
				pageInfo = false;
				return;
			}
			//若尚未產生控制項，則先產生控制項
			if(! pageInfo ){
				buildPageUI();
				if(! allRecords ){ return; }
			}
			//alert(allRecords.length);
			if( allRecords.length > 0  ){
				//計算頁數，分成有group和沒有group的資料筆數計算，有Group的話，每一個Group算一筆資料
				if(groupKey){
					var rec1 , rec2;
					recordSize = 1;
					for(var i = 1 ; i < allRecords.length ; i = i + 1){
						rec1 = allRecords[i-1];
						rec2 = allRecords[i];
						var addRec = 0;
						for(var x = 0 ; x < groupKey.length ; x = x + 1 ){
							if(rec1[groupKey[x]]!=rec2[groupKey[x]]){
								addRec = 1 ;
								break;
							}
						}
						recordSize = recordSize + addRec ;
					}
				}else{
					recordSize = allRecords.length;
				}
				//計算頁數
				totalPage = Math.ceil( (recordSize/pageSize) );
				if(selectList.length < totalPage){
					for(var i = selectList.length+1 ; i <= totalPage ; i = i + 1){
						var tempChild = new Element("option");
						tempChild.value = i;
						tempChild.innerText = i;
						selectList.insert(tempChild);
					}
				}else if(selectList.length > totalPage){
					while(selectList.length > totalPage ){
						selectList.remove( selectList.length-1 );
					}
				}
			}else{
				recordSize = 0;
				totalPage = 0;
				while(selectList.length > totalPage ){
					selectList.remove( selectList.length-1 );
				}
			}
			//清除已產生頁數資訊
			grnPageMap = new Hash();
			currentPage = 0;
			if(groupKey  && (!config.simplePageInfo) ){
				pageInfo.innerHTML = "&nbsp;第0頁/共0頁  群組0組/共0筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}else{
				pageInfo.innerHTML = "&nbsp;第0頁/共0頁  共0筆&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
			}
			showPage( 1 );
		 }
		 
		 /**   
		 * @public
		 * @class 從外部產生新的一頁，並將已產生的一頁放至已產生的HASH
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		 this.getNewPageWhenAddRec = getNewPageWhenAddRec;
		 function getNewPageWhenAddRec(){
			totalPage  = totalPage + 1
			var newPage = totalPage + 0;
			grnPageMap.set( newPage , newPage );
			return newPage;
		 }
		 
		 /**   
		 * @public
		 * @class 重新整理 總計，總頁數，資料筆數資訊。
		 * @memberOf TableUI.PagePlus
		 * @author Liang-hsun , Huang ws9300618
		 * @version 1.00
		 * */
		 this.updatePageSizeInfo = updatePageSizeInfo;
		 function updatePageSizeInfo(){
			//若沒有pageSize，直接產生全部的rec，並將原本的資料清除
			pageSize = config.pageSize;
			if( !pageSize ){
				return;
			}
			//alert(allRecords.length);
			if( allRecords.length > 0  ){
				//計算頁數，分成有group和沒有group的資料筆數計算，有Group的話，每一個Group算一筆資料
				if(groupKey){
					var rec1 , rec2;
					recordSize = 1;
					for(var i = 1 ; i < allRecords.length ; i = i + 1){
						rec1 = allRecords[i-1];
						rec2 = allRecords[i];
						var addRec = 0;
						for(var x = 0 ; x < groupKey.length ; x = x + 1 ){
							if(rec1[groupKey[x]]!=rec2[groupKey[x]]){
								addRec = 1 ;
								break;
							}
						}
						recordSize = recordSize + addRec ;
					}
				}else{
					recordSize = allRecords.length;
				}
				//計算頁數
				totalPage = Math.ceil( (recordSize/pageSize) );
				if(selectList.length < totalPage){
					for(var i = selectList.length+1 ; i <= totalPage ; i = i + 1){
						var tempChild = new Element("option");
						tempChild.value = i;
						tempChild.innerText = i;
						selectList.insert(tempChild);
					}
				}else if(selectList.length > totalPage){
					while(selectList.length > totalPage ){
						selectList.remove( selectList.length-1 );
					}
				}
			}else{
				recordSize = 0;
				totalPage = 0;
				while(selectList.length > totalPage ){
					selectList.remove( selectList.length-1 );
				}
				
			}
			var temp = currentPage+0;
			currentPage = 0 ;
			showPage( temp );
		}
		
		 updatePageInfo();
	}
	
	
	
	
	//==========-------------==========
	//========== 資料處理函式 ==========
	//==========-------------==========
    
	
	/**     
	 * @public
	 * @class 讀取資料
	 * @memberOf TableUI
	 * @param newRecords (Array<Record>): 需要顯示的Record資料
	 * @param newDataTotalRecord (Array<value(Map)>>) : 總計資料 
	 * @param newDataSubTotalRecord (Array<Map<key(Map),value(Map)>>) : 小計資料
	 * @param prepareCheckData (Array<String>) : 若您有使用autoCheckBox，可在此處設定需要預先勾選的數值。
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.load = load;
	this.loadin = load;
	function load( newRecords, newDataTotalRecord ,newDataSubTotalRecord , prepareCheckData )
    {
		config.totalCount = newDataTotalRecord || null;
		config.subTotalCount = newDataSubTotalRecord || null;

		if(newRecords){
			if(Object.isUndefined(newRecords.length)){
				allRecords = [];
				if(Object.isUndefined(newRecords[0])){
					allRecords.push(newRecords);
				}else{
					for(var nrsIndex in newRecords){
						allRecords.push(newRecords[nrsIndex]);	
					}
				}

			}else{
				allRecords = newRecords;	
			}
		}else{
			allRecords = [];
		}
    	reload();
		cleanSortLink();
		
		if(config.table.prepareCheck && prepareCheckData && Object.isArray(prepareCheckData)){
			for( var i = 0 ; i < prepareCheckData.length ; i = i + 1 ){
				config.table.prepareCheck.set(prepareCheckData[i],prepareCheckData[i]);
			}
		}
		page.updatePageInfo();
		
		//若是有設定讀取結束動作，執行!
		if( config.afterLoad && typeof(config.afterLoad)=='function' ){
			config.afterLoad(config.table);
		}
		
		resetDivHeight(false);
	}
	
	/**    
	 * @private 
	 * @class 設定table屬性
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function reload(){
		
		//換置tbody
        var oldBody = config.body;
        config.body = new Element( "tbody" );
        config.table.replaceChild( config.body, oldBody );
		config.table.startLoad = 0;
		config.table.endLoad = allRecords.length-1;
		//config.table.nowPage = 1;
		
		//清除autoCheckBox設定
		if(config.autoCheckBox){
			config.table.autoCheckAll = false;
			config.table.autoChecked = 0;
			config.table.totCheckBox = 0;
			if(config.autoCheckBox.isSelectAll){
				config.autoCheckEle.checked = false;
			}
			config.table.prepareCheck=new Hash();
		}
		
	}
    
	
	 /**    
	 * @private 
	 * @class 產生資料實體
	 * @memberOf TableUI
	 * @param displaySize: 產生displaySize筆資料，若displaySize>0 順向產生 displaySize<0 反向產生；
	 * @param page: 用於寫入LogTr
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    function refresh( displaySize , page ){
		//alert(  "refresh( "+displaySize+" , "+page+" )" );		
		var pageSize = config.pageSize;
		if(!displaySize){ displaySize = pageSize; }
		if(!page){ page = 1; }
		if(config.table.endLoad < 0 ){ return; }
		var startLoad = config.table.startLoad ;
		var endLoad = config.table.endLoad ;
		var startInsert , endInsert;
		var body = config.body;
		
		
		//準備是要插在中間還是插入在最後
		//insertType: true-插在中間； false-直接插在最後
		//insertNode: insertType-true有效，將插在此Row前面
		var insertBeforeType = true; 
		var insertBeforeNode;
		//是否插入小計
		var subTotalCount = config.subTotalCount ? true:false;
		
		//插入資料
		if( displaySize > 0){
			//正向算法 --> 0--->1--->2
			var i = 0;
			var j = 0;
			startInsert = startLoad;
			do{
				var count = render( j+startLoad );
				if(count == 0 || count == 1 || j+startLoad == allRecords.length-1 ){ 
					i = i + 1; 
				}
				j = j + 1;
			}while( i < displaySize && j+startLoad < allRecords.length );
			endInsert = j+startLoad-1;
			config.table.startLoad = j+startLoad;	
			
		}else if( displaySize < 0){
			//反向 
			var loadSize;
			var temp;
			//先算出應該從哪個資料開始算。
			if(!groupKey){ 
				loadSize = ((-1)*displaySize); 
			}else{
				loadSize = 0;
				temp = 0;
				var rec1 , rec2;
				do{
					if(endLoad-temp == 0){
						loadSize = loadSize + 1;
						break;
					}
					rec1 = allRecords[endLoad-loadSize];
					rec2 = allRecords[endLoad-loadSize-1];
					var addRec = 0;
					for(var x = 0 ; x < groupKey.length ; x = x + 1 ){
						if(rec1[groupKey[x]]!=rec2[groupKey[x]]){
							addRec = 1 ;
							break;
						}
					}
					temp = temp + addRec ;
					loadSize = loadSize + 1;
				}while(temp < ((-1)*displaySize) )
			}
			temp = 1;
			startInsert = endLoad-(loadSize-temp);
			do{
				var count = render( endLoad-(loadSize-temp) );
				temp = temp + 1;
			}while(temp <= loadSize)
			endInsert = endLoad
			config.table.endLoad = config.table.endLoad - loadSize;
		}
		
		
		//插入page資訊
		//若是插在中間，擇取應該插入的位置。
		if(endLoad == allRecords.length -1 ){ 
			insertBeforeType = false; 
		}else{
			var rows = body.getElementsByTagName("PAGE");
			var temp = rows.length-1;
			do{
				if((rows[temp]+1) == page){
					break;
				}
				insertBeforeNode = rows[temp];
				temp = temp - 1;
			}while( temp >= 0  )
		}
		//插入page tr
		var pageTag = new Element('page');
		pageTag.PageID = page;
		pageTag.PageSize = Math.abs(displaySize);
		var tbColor = "tbYellow2";
		for(var m = startInsert ; m <= endInsert ; m = m + 1){
			var count = allRecords[m].countType;
			if(count == 0 || count == 2){
				tbColor = tbColor != "tbYellow2" ? "tbYellow2" : "tbBlue3";
			}
			var tRows = allRecords[m].tRows;
			var splitLog = false;
			tRows.each( function( tRow ) {
				tRow.writeAttribute( "className", tbColor );
				tRow.writeAttribute( "split", splitLog );
				tRow.observe( "click" , function(){whenSelectRec(this);});
				splitLog = true;
				pageTag.insert( tRow );
			});
			if(count == 0 || count == 1 || m == endInsert){
				if(subTotalCount){
					insertSubTotalCount( m , pageTag );
				}
			}
		}
		if(insertBeforeType){
			body.insertBefore( pageTag , insertBeforeNode );
		}else{
			body.insert( pageTag );
		}
		var tds = body.getElementsByTagName('TD');
		for(var n = 0 ; n < tds.length ; n = n + 1 ){
			if(tds[n].updateRowSpan){
				tds[n].rowSpan = tds[n].updateRowSpan;
				tds[n].removeAttribute('updateRowSpan');
			}
		}
		
	}
	
	var SimpleDateFormatSave = {};
	
	
	 /**     
	 * @private 
	 * @class 產生record實體
	 * @memberOf TableUI
	 * @param index : 資料位置
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
    function render( index ) {
		//alert("render("+index+")");
		//取得資料。
		var colsInfo = config.recordCol;
		var record = allRecords[index];
		var perRecord = ( index == 0 ? false : allRecords[index-1] );
		var nextRecord = ( index == allRecords.length-1 ? false : allRecords[index+1] );
		record.tRows = new Array();
		var maxRowSpan = colsInfo.length;
		var TR,TD,DATA;
		var indexTab;
		
		var isGorupWithPRec = false;
		var isGorupWithNRec = false;
		
		for( var i = 0 ; i < colsInfo.length ; i = i + 1 ){
			TR = createTRow( "", "center", record );
			indexTab = 0;
			for( var j = 0 ; j < colsInfo[i].length ; j = j + 1 ){
				var col = colsInfo[i][j];
				if(!col.copy){
					
					if(!col.attrs){ col.attrs = {}; }
					col.attrs.rowSpan = col.attrs.rowSpan || 1 ;
					//真正產生資料的地方開始
					//先檢查是否Group
					//alert('key: ' +col.key+' group: '+Object.toJSON(col.groupKey));
					if( col.groupKey ){
						var isGorup = 0;
						var isNextGroup = 0;
						for( var k = 0 ; k < col.groupKey.length ; k = k + 1 ){
							if(perRecord &&  record[col.groupKey[k]] === perRecord[col.groupKey[k]] ){
								isGorup = isGorup + 1 ;
							}
							if( nextRecord && record[col.groupKey[k]] === nextRecord[col.groupKey[k]] ){
								isNextGroup = isNextGroup + 1 ;
							}
						}
						if(isNextGroup > 0 && isNextGroup === col.groupKey.length ){
							isGorupWithNRec = true;
						}
						//將前一筆的資料的Group格拉長，然後退出。
						if(isGorup > 0 && isGorup === col.groupKey.length ){
							isGorupWithPRec = true;
							if( (col.attrs.rowSpan||1) == maxRowSpan ){
								record[col.key+'TDCell'] = perRecord[col.key+'TDCell'];
								var groupTD = perRecord[col.key+'TDCell'];
								//alert(Object.toJSON(groupTDs.length));
								if(groupTD){
									groupTD.setAttribute('updateRowSpan' ,  (groupTD.getAttribute('updateRowSpan')||maxRowSpan)+maxRowSpan );
								}
								continue;
							}
						}
					}
					
					DATA = Object.isUndefined(record[col.key])?( Object.isUndefined(config.whenDataNull)?'':config.whenDataNull):record[col.key];
					var type = col.sortRule;
					if(!type && col.input){
						type = col.type;
					}
					if(type){
						var settingPattern = (col.attrs && col.attrs.pattern) || (col.input && col.input.attrs && col.input.datatype) || "";
						type = type.toLowerCase();
						if(type == "number"){
							if(isNumeric(DATA)){
								if ( hasLocaleDisplay && !numberPattern ){
									DATA = localeDisplay.formatNumber(DATA , col.attrs.scale);
								}else{
									var numberPattern = settingPattern ||  "#,##0.####";
									DATA = CSRUtil.$fmt(DATA, numberPattern);	
								}
							}
						}else if(type == "date"){
							if( hasLocaleDisplay && !settingPattern ){
								DATA = localeDisplay.formatDate(DATA);
							}else{
								if(!SimpleDateFormatSave[col.key]){
									var datePattern = settingPattern || "yyyy-MM-dd";
									SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.US);
								}
								DATA = (SimpleDateFormatSave[col.key]).format(DATA);
							}
						}else if(type == "rocdate"){
							if(!SimpleDateFormatSave[col.key]){
								var datePattern = settingPattern || "yyyMMdd";
								SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.TW);
							}
							DATA = (SimpleDateFormatSave[col.key]).format(DATA);
						}else if(hasLocaleDisplay){
							if(type == "datetime"){
								DATA = localeDisplay.formatTimestamp(DATA);
							}else if(type == "dateym"){
								DATA = localeDisplay.formatDateym(DATA);
							}else if(type == "datey"){
								DATA = localeDisplay.formatDatey(DATA);
							}
							
						}
						
					}
					
					var cloneRec = Object.clone(record);
					var isAutoInput = false;
					if( col.input ){
						isAutoInput = true;
						if(col.input.genRule){
							isAutoInput = col.input.genRule( cloneRec , Object.isUndefined(cloneRec[col.key])?'':cloneRec[col.key] );
						}
						var cell = document.createDocumentFragment();
						var orgData = new Element('div', {
							'name': 'inputData' 
						});
						if(col.render){
							var tempDATA = col.render( cloneRec , DATA , index);
							if(!Object.isUndefined(tempDATA) && tempDATA != null){
								DATA = tempDATA;
							}
							//if( typeof( value ) == "string" ) {
							//	value = new Template( value ).evaluate( cloneRecord );
							//}
						}
						if(col.input.easyEdit){
							var font = new Element("FONT");
							font.appendChild(document.createTextNode(DATA));
							font.onclick = setCellToCover;
							orgData.appendChild(font);
							isAutoInput = false;
						}else{
							orgData.appendChild(document.createTextNode(DATA));
						}
						orgData.style.display = isAutoInput?'none':'';
						cell.appendChild(orgData);
						switch( (col.input.type||'').toUpperCase() ){
							case 'TEXT':
								
								var text = createCell( "input", { 
									name:'autoText_'+col.key,
									type:'text' , 
									key:col.key, 
									className: col.input.className ?'textBox2 '+col.input.className : 'textBox2', 
									value:DATA, 
									action: col.input.action, 
									keyPress: col.input.keyPress,
									render:col.render?col.render:false
								}).observe('change', function(){
									var dataObjs = getValueByElement(this);
									var orgData = [];
									for(var i = 0 ;  i < dataObjs.length ; i = i + 1){
										orgData.push( (dataObjs[i])[this.key] ); 
										(dataObjs[i])[this.key] = this.value;
									}
									var tr , td = this;
									while(td.tagName != 'TD'){ td = td.parentNode ;}
									tr = td.parentNode;
									td.firstChild.innerHTML = this.render?this.render( tr.dataObj ,this.value):this.value;
									this.value = this.render?this.render( tr.dataObj ,this.value):this.value;
									if(this.action && Object.isFunction(this.action) ){
										this.action(this , dataObjs , this.parentNode.firstChild, orgData.length==1?orgData[0]:orgData, true );
									}
								}).observe('keypress', function(){
									if(this.keyPress && Object.isFunction(this.keyPress)){
										this.keyPress(this , event );
									}
								});
								
								if(col.input.size && typeof(col.input.size)=='number'){ 
									text.size = col.input.size; 
								}else if(col.input.maxlength && typeof(col.input.maxlength)=='number'){ 
									text.size = col.input.maxlength+2;
								}else{
									text.style.width = col.input.width||70;
								}
								if(col.input.maxlength && typeof(col.input.maxlength)=='number'){ text.maxLength = col.input.maxlength; }
								if(col.render){ text.value = col.render(cloneRec,text.value); }
								if(col.input.actionWhenStart && col.input.action){ col.input.action(text,[cloneRec],orgData, DATA , false); }
								if(col.input.text){
									var div = new Element('div');
									div.style.display = isAutoInput?'':'none';
									div.insert(text);
									div.appendChild(document.createTextNode(col.input.text));
									cell.appendChild(div);
								}else{
									cell.appendChild(text);
									text.style.display = isAutoInput?'':'none';
								}
								break;
							case 'NUMBER':
								var text = createCell( "input", { 
									name:'autoText_'+col.key,
									type:'text' , 
									key:col.key, 
									className: col.input.className ?'textBox2 '+col.input.className : 'textBox2', 
									value:DATA, 
									action: col.input.action, 
									keyPress: col.input.keyPress || validNumber,
									render:col.render?col.render:false,
									floatNum: isNumeric(col.input.floatNum)?col.input.floatNum : 10
								}).observe('change', function(){

									var value = this.value;
									var dataObjs = getValueByElement(this);
									var orgData = [];
									var valueSplit = this.value.split(",");
									var tempValue = "a";
									for(var i = 0 ;  i < valueSplit.length ; i = i + 1){
										tempValue=tempValue+valueSplit[i];
									}
									this.value=parseFloat(tempValue.substr(1,tempValue.length-1));
									for(var i = 0 ;  i < dataObjs.length ; i = i + 1){
										orgData.push( (dataObjs[i])[this.key] ); 
										(dataObjs[i])[this.key] = this.value;
									}
									var tr , td = this;
									while(td.tagName != 'TD'){ td = td.parentNode ;}
									tr = td.parentNode;
									var textCell = td.firstChild;
									if(textCell.firstChild && textCell.firstChild.tagName == "FONT"){ textCell =textCell.firstChild; }
									textCell.innerHTML = this.render?this.render( tr.dataObj ,this.value):this.value;
									this.value = this.render?this.render( tr.dataObj ,this.value):this.value;
									
									if(this.value == 'NaN' || this.value == Number.NaN){ this.value = value; td.firstChild.innerHTML = value; }
									
									if(this.action && Object.isFunction(this.action) ){
										this.action(this , dataObjs , this.parentNode.firstChild, orgData.length==1?orgData[0]:orgData ,true );
									}

								}).observe('keypress', function(){
									if(this.keyPress && Object.isFunction(this.keyPress)){
										this.keyPress(this , event ,this.floatNum );
									}
								});

								text.setStyle({ 'textAlign': 'right', 'paddingRight': '1px' });

								if(col.input.size && isNumeric(col.input.size)){ 
									text.size = col.input.size; 
								}else if(col.input.maxlength && isNumeric(col.input.maxlength)){ 
									text.size = col.input.maxlength;
								}else{
									text.style.width = col.input.width||70;
								}
								if(col.input.maxlength && typeof(col.input.maxlength)=='number'){ text.maxLength = col.input.maxlength; }
								if(col.render){ text.value = col.render(cloneRec,text.value); }
								if(col.input.actionWhenStart && col.input.action){ col.input.action(text,[cloneRec],orgData , DATA , false); }
								if(col.input.text){
									var div = new Element('div');
									div.style.display = isAutoInput?'':'none';
									div.insert(text);
									div.appendChild(document.createTextNode(col.input.text));
									cell.appendChild(div);
								}else{
									cell.appendChild(text);
									text.style.display = isAutoInput?'':'none';
								}
								break;	
							case 'DATE':
								var div = new Element('div');
								div.style.display = isAutoInput?'':'none';
								var text = createCell( "input", {
									name:'autoDate_'+col.key,
									type:'text', 
									key:col.key, 
									className: col.input.className ?'textBox2 '+col.input.className : 'textBox2',
									value:DATA, 
									datatype: ((type == 'rocdate') ? 'ROCDate' : 'Date'),
									action:col.input.action, 
									render:col.render?col.render:false,
									keyPress: col.input.keyPress|| validDate ,
									size:12,
									maxlength:10
								}).observe('change', function(){
									var value = this.value;
									var getValue = $(this).getValue ? $(this).getValue() : value;
									
									if(Object.isFunction(isROCdate)){
										if(isROCdate(getValue,false,false)){
											getValue = toY2K(getValue);
										}else if(!isADdate(getValue)){
											getValue = "";
											value = "";
											this.value = "";
										}
									}
									
									var dataObjs = getValueByElement(this);
									var orgData = [];
									for(var i = 0 ;  i < dataObjs.length ; i = i + 1){
										orgData.push( (dataObjs[i])[this.key] ); 
										(dataObjs[i])[this.key] = getValue;
									}
									var tr = this;
									while(tr.tagName != 'TR'){ tr = tr.parentNode ;}
									
									// 取到TD，再取TD的第一個子節點(顯示用的DIV)做設值
									var textCell = this.parentNode.parentNode.firstChild;
									if(textCell.firstChild && textCell.firstChild.tagName == "FONT"){ textCell =textCell.firstChild; }
									textCell.innerHTML = this.render?this.render( tr.dataObj ,getValue):value;
									
									if(this.action && Object.isFunction(this.action) ){
										this.action(this , dataObjs, this.parentNode.parentNode.firstChild, orgData.length==1?orgData[0]:orgData , true );
									}
								}).observe('keypress', function(){
									if(this.keyPress && Object.isFunction(this.keyPress)){
										this.keyPress(this , event  );
									}
								});

								if( col.input.className ){
									text.className = text.className + ' ' + col.input.className;  
								}
								if(col.input.actionWhenStart && col.input.action){ col.input.action(text,[cloneRec],orgData ,cloneRec[col.key],false ); }
								div.insert(text);
								if(!window.autoCreateDate && Object.isFunction(window.getCalendarFor)){
									var img = createCell("img" ,{
										src:col.input.imgBase + "/CM/calendar.gif"
									}).setStyle({
										'width':20,
										'height':18									
									}).observe('click', function(){
										var img = this;
										while( img.previousSibling.tagName != 'INPUT'){
											img = img.previousSibling;
										}
										getCalendarFor( img.previousSibling ); 										
									});
								}

								div.insert(img);
								cell.appendChild(div);
								break;
							case 'SELECT':
								var selectObj = createCell( "select", { 
									name:'autoSelect_'+col.key,
									key:col.key, 
									className: col.input.className ?'textBox2 '+col.input.className : 'textBox2', 
									action:col.input.action
								}).observe('change', function(){
									var dataObjs = getValueByElement(this);
									var orgData = [];
									for(var i = 0 ;  i < dataObjs.length ; i = i + 1){
										orgData.push( (dataObjs[i])[this.key] ); 
										(dataObjs[i])[this.key] = this.value;
									}
									var opts = this.options;
									for(var i = 0 ;  i < opts.length ; i = i + 1){
										if(opts[i].selected){

											var textCell = this.parentNode.firstChild;
											if(textCell.firstChild && textCell.firstChild.tagName == "FONT"){ textCell =textCell.firstChild; }
											textCell.innerHTML = opts[i].text;
										}
									}
									if(this.action && Object.isFunction(this.action) ){
										this.action(this , dataObjs, this.parentNode.firstChild, orgData.length==1?orgData[0]:orgData , true);
									}
								});

								selectObj.style.display = isAutoInput?'block':'none';
								selectObj.style.visibility = 'visible';
								if(col.input.opts){
									for( var key in col.input.opts ){
										var option = createCell( "option" , { value:key } );
										option.update(col.input.opts[key]);
										if(key == cloneRec[col.key]){
											option.selected = true;
										}
										selectObj.insert(option);
									}
								}
								if( col.input.className ){
									selectObj.className = selectObj.className + ' ' + col.input.className;  
								}
								if(col.input.actionWhenStart && col.input.action){ col.input.action(selectObj,[cloneRec],orgData,cloneRec[col.key],false); }
								cell.appendChild(selectObj);
								break;
							case 'BUTTON' :
								var button = createCell( "input", { 
									name:'autoButton_'+col.key,
									type:'button' ,
									className: col.input.className ?'button '+col.input.className : 'button',
									value:col.input.text||DATA, 
									action:col.input.action
								}).observe('click', function(){
									if(this.action && Object.isFunction(this.action) ){
										var dataObjs = getValueByElement(this);
										this.action(this , dataObjs, this.parentNode.firstChild,true );
									}
								});

								button.style.display = isAutoInput?'':'none';
								if( col.input.className ){
									button.className = button.className + ' ' + col.input.className;  
								}
								if(col.input.actionWhenStart && col.input.action){ col.input.action(button,[cloneRec],orgData,false); }
								cell.appendChild(button);
								break;
							case 'RADIO' :
								var isChangeAll = col.input.isChangeAll || false;
								var div = new Element('div');
								div.style.display = isAutoInput?'':'none';
								var radio = createCell( "input", { 
									name:(isChangeAll?'autoRadio_'+col.key+'_'+index:'autoRadio_'+col.key),
									submitName:(isChangeAll?'autoRadio_'+col.key+'_'+index:'autoRadio_'+col.key),
									arrayName:'autoRadio_'+col.key,
									type:'radio' , 
									value:cloneRec[col.key], 
									action:col.input.action
								}).observe('click', function(){
									if(this.action && Object.isFunction(this.action) ){
										if(isChangeAll){
											var checkArray = config.table[this.arrayName];
											//while(checkArray.tagName = 'TABLE'){ checkArray = checkArray.parentNode; }
											for( var i = 0 ; i < checkArray.length ; i = i + 1 ){
												if( checkArray[i].checked ){
													if(checkArray[i].orgCheck ){
														checkArray[i].orgCheck = false;
														checkArray[i].checked = false;
													}else{
														checkArray[i].orgCheck = true;
													}
													var dataObjs = getValueByElement(checkArray[i]);
													checkArray[i].action(checkArray[i] , dataObjs, checkArray[i].parentNode.parentNode.firstChild,true);
												}
											}	
										}else{
											var dataObjs = getValueByElement(this);
											this.action(this , dataObjs, this.parentNode.parentNode.firstChild,orgData,false);
										}
									}
								});

								if( col.input.className ){
									radio.writeAttribute('className', col.input.className);  
								}
								div.insert(radio);
								if(isChangeAll){
									if(!config.table['autoRadio_'+col.key]){ config.table['autoRadio_'+col.key] = []; }
									config.table['autoRadio_'+col.key].push(radio);
								}
								if(col.input.text){
									div.appendChild(document.createTextNode(col.input.text));
								}else if(Object.isString(DATA)){
									div.appendChild(document.createTextNode(DATA));
								}else{
									div.insert(DATA);
								}
								if(col.input.actionWhenStart && col.input.action){ col.input.action(radio,[cloneRec],orgData); }
								cell.appendChild(div);
								break;
							case 'CHECKBOX' :
								var div = new Element('div');
								div.style.display = isAutoInput?'':'none';
								var checkBoxObj = createCell( "input", { 
									name:'autoCheckBox_'+col.key,
									submitName:'autoCheckBox_'+col.key,
									type:'checkbox' , 
									value:cloneRec[col.key], 
									action:col.input.action
								}).observe('change', function(){
									if(this.action && Object.isFunction(this.action) ){
										var dataObjs = getValueByElement(this);
										this.action(this , dataObjs, this.parentNode.parentNode.firstChild , true);
									}
								});

								if( col.input.className ){
									checkBoxObj.writeAttribute('className', col.input.className);
								}
								div.insert(checkBoxObj);
								if(col.input.text){
									div.appendChild(document.createTextNode(col.input.text));
								}else if(Object.isString(DATA)){
									div.appendChild(document.createTextNode(DATA));
								}else{
									div.insert(DATA);
								}
								if(col.input.actionWhenStart && col.input.action){ col.input.action(checkBoxObj,[cloneRec],orgData ,false); }
								cell.appendChild(div);
								break;
							case 'TEXTAREA':
								var div = new Element('div');
								var dataarea = createCell( "textarea", { 
									name:'autoTextarea_'+col.key,
									key:col.key, 
									rows:3,
									className: col.input.className ?'textBox2 '+col.input.className : 'textBox2', 
									action: col.input.action, 
									render:col.render?col.render:false,
									shortTextLength:col.input.shortTextLength
								}).observe('change', function(){
									var dataObjs = getValueByElement(this);
									var orgData = [];
									for(var i = 0 ;  i < dataObjs.length ; i = i + 1){
										orgData.push( (dataObjs[i])[this.key] ); 
										(dataObjs[i])[this.key] = this.innerText;
									}
									var tr , td = this;
									while(td.tagName != 'TD'){ td = td.parentNode ;}
									tr = td.parentNode;
									var textCell = td.firstChild;
									if(textCell.firstChild && textCell.firstChild.tagName == "FONT"){ textCell =textCell.firstChild; }
									var content = this.render?this.render( tr.dataObj ,this.innerText):this.innerText;
									textCell.title = content;
									textCell.innerHTML = ExchangeToShortText(content , this.shortTextLength);
									this.innerText = this.render?this.render( tr.dataObj ,this.innerText):this.innerText;
									if(this.action && Object.isFunction(this.action) ){
										this.action(this , dataObjs , this.parentNode.firstChild, orgData.length==1?orgData[0]:orgData, true );
									}
								});

								dataarea.innerText = DATA;
								dataarea.setStyle({
									'width': col.input.width||200
								});
								dataarea.style.display = isAutoInput?'':'none';
								
								var textCell = cell.firstChild;
								if(textCell.firstChild && textCell.firstChild.tagName == "FONT"){ textCell =textCell.firstChild; }
								var content = this.render?this.render( record ,textCell.innerText):textCell.innerText;
								textCell.title = content;
								textCell.innerHTML = ExchangeToShortText(content , col.input.shortTextLength);
								
								if(col.render){ dataarea.innerText = col.render(cloneRec,dataarea.innerText); }
								if(col.input.actionWhenStart && col.input.action){ col.input.action(dataarea,[cloneRec],orgData, DATA , false); }
								cell.appendChild(dataarea);
								break;
							default:
								DATA = orgData.innerHTML;
								break;
						}
						DATA = cell;
						
					}else if(col.render){
						DATA = col.render( cloneRec , DATA );
						//if(DATA.search(";")>0 && !col.escapeOff && Object.isString( DATA ) ){ DATA = DATA.replace('&' ,'&amp;'); }
						//if( typeof( DATA ) == "string" ) {
						//	value = new Template( value ).evaluate( cloneRecord );
						//}
					}
					
					TD = createCell( "td", col.attrs );
					if(type == "number"){
						TD.setAttribute("align","right");
					}
					
					if(Object.isElement(DATA) || (DATA && DATA.nodeType)){
						TD.appendChild( DATA ); 
						//------ auto check box 使用 ---- 若有預設的資訊
						if(col.key=="autoCheckBoxs"){
							 if(!(config.autoCheckBox.disableRule && Object.isFunction(config.autoCheckBox.disableRule) && config.autoCheckBox.disableRule(record))){
								DATA.checked = config.table.autoCheckAll;
								if(config.table.prepareCheck.get(DATA.value)){
									DATA.checked = !DATA.checked;
									config.table.autoChecked = config.table.autoChecked + 1 ;
									//config.table.prepareCheck.unset(DATA.value);
								}
							 }
						}
						//--------------------------------	
					}else{ 
						if(Object.isUndefined(DATA) || DATA == null || (DATA) ===''){
							DATA = "　";
						}else if(Object.isString( DATA ) && DATA.search(";")<0 && !col.escapeOff){ 
							DATA = DATA.replace('&' ,'&amp;'); 
						}
						TD.update(DATA);
					}
					TR.insert(TD);
					if(col.groupKey){
						record[col.key+'TDCell'] = TD;
					}
					//結束產生一個TD			
					indexTab = indexTab + 1;
				}
			}
			record.tRows.push(TR);
			
		}
		
		//回傳 0 : 上下皆無GROUP (換色)
		//	   1 : 僅上面有GROUP
		//     2 : 下面有GROUP (換色)
		//     3 : 上下皆有GRUP
		if( isGorupWithPRec && isGorupWithNRec ){
			record.countType=3;
		}else if( isGorupWithNRec ){
			record.countType=2;
		}else if( isGorupWithPRec ){
			record.countType=1;
		}else{
			record.countType=0;
		}
		return record.countType;
	}
	
	
	
	
	//==========-----------------==========
	//========== 資料處理函式  END ==========
	//==========-----------------==========
    
	
	//========== 其他資料處理函式 ==========
	
	/** 
	 * @private
	 * @class 處理隱藏
	 * @memberOf TableUI
	 * @param input {String} 處理字串
	 * @param length {int} 處理字串長度
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 
	 function ExchangeToShortText(input , length ){
        if(!input){return "..."; }
		var content = input.split("\n")[0];
		if(isNumeric(length)){
			var byteCount = 0;
			var charCount = 0;
	　　　  for(var i=0;i<content.length;i++ ){　
	　　　　　 content.charCodeAt(i)<256?byteCount++:byteCount+=2;　
				
			   if(byteCount>length){//最後為中文，且超出應顯示字數
					break;
				}else if(byteCount==length){
					charCount++;
					break;
				}else{
					charCount++;
				}
	　　　　}　
			return content.substr(0, charCount)+"...";	
		}else{
			return content+"...";
		}	 
 	}
	 
	 
	
	/** 
	 * @public
	 * @class 重新讀入小計欄位
	 * @memberOf TableUI
	 * @param subTotalCountData {array} 新的subTotalCount資訊 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 this.resetSubTotalCount = resetSubTotalCount;
	 function resetSubTotalCount( subTotalCountData ){
		config.subTotalCount = subTotalCountData||null;
		var pages = config.body.getElementsByTagName('PAGE');
		for(var i = 0 ; i < pages.length ; i = i + 1 ){
			var row = pages[i].firstChild;
			do{
				var nextRow = row.nextSibling;
				if(row.className =='tbBlue2'){
					pages[i].removeChild(row);
				}
				row = nextRow;
			}while( row );
		}
		if(config.subTotalCount){
			for(var l = 0 ; l < pages.length ; l = l + 1 ){
				var row = pages[l].firstChild;
				do{
					var nextRow = row.nextSibling;
					if( !nextRow || row.className !=  nextRow.className ){
						var rec = row.dataObj;
						for(var i = 0 ; i < config.subTotalCount.length ; i = i + 1 ){
							var oneSubTotalCount = config.subTotalCount[i];
							for(var j = 0 ; j < oneSubTotalCount.length ; j = j + 1 ){
								var subTotalRec = oneSubTotalCount[j];
								var isGen = true;
								for(var k = 0 ; k < groupKey.length ; k = k + 1 ){
									//alert(groupKey[k]+" ccc "+rec[groupKey[k]]+" != "+subTotalRec.key[groupKey[k]]);
									if(rec[groupKey[k]] != subTotalRec.key[groupKey[k]]){
										isGen = false;
										break;
									}
								}
								if(isGen){
									insertTotalCount( subTotalRec.value , nextRow?true:false , nextRow , pages[l] , typeof(subTotalRec.text)!='undefined'?subTotalRec.text:'' , config.totalCount[i].textAlign );			
								}
							}
						}
					}
					row = nextRow;
				}while( row );
			}
		}
		
	}
	
	 /** 
	 * @private 
	 * @class 預備產生小計實體
	 * @memberOf TableUI
	 * @param index : 插入recodrs資訊值
	 * @param pageTag : 插入位置  
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function insertSubTotalCount( index , pageTag ){
		//alert('insertSubTotalCount start');
		var rec = allRecords[index];
		for(var i = 0 ; i < config.subTotalCount.length ; i = i + 1 ){
			var oneSubTotalCount = config.subTotalCount[i];
			for(var j = 0 ; j < oneSubTotalCount.length ; j = j + 1 ){
				var subTotalRec = oneSubTotalCount[j];
				var isGen = true;
				for(var k = 0 ; k < groupKey.length ; k = k + 1 ){
					//alert(groupKey[k]+" ccc "+rec[groupKey[k]]+" != "+subTotalRec.key[groupKey[k]]);
					if(rec[groupKey[k]] != subTotalRec.key[groupKey[k]]){
						isGen = false;
						break;
					}
				}
				if(isGen){
					insertTotalCount( subTotalRec.value , false , null , pageTag , (typeof(subTotalRec.text)!='undefined'?subTotalRec.text:'') , subTotalRec.textAlign );
				}
			}
		}
	}
	/** 
	 * @public
	 * @class 重新讀入總計欄位
	 * @memberOf TableUI
	 * @param TotalCountData {array} 新的TotalCount資訊 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 this.resetTotalCount = resetTotalCount;
	 function resetTotalCount( TotalCountData){
		config.totalCount = TotalCountData||null;
		reflashTotalCount();
	}
	
	/** 
	 * @public
	 * @class 取得總計欄位資訊
	 * @memberOf TableUI
	 * @return {Array} 現在的合計資料 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.getTotalCount = getTotalCount;
	function getTotalCount(){
		return config.totalCount;
	}
	/** 
	 * @private 
	 * @class 預備產生合計實體
	 * @memberOf TableUI
	 * @param index : 插入recodrs資訊值
	 * @param pageTag : 插入位置  
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 function reflashTotalCount(){
		//清除之前的總計
		while( config.foot.firstChild && config.foot.childNodes.length > 1 ){
			config.foot.removeChild(config.foot.firstChild);
		}
		//加上新增的總計
		if(config.totalCount){
			for(var i = 0 ; i < config.totalCount.length ; i = i + 1 ){
				if(config.foot.rows.length > 0){
					insertTotalCount( config.totalCount[i].value, true , config.foot.rows[(config.foot.rows.length)-1] , config.foot , typeof(config.totalCount[i].text)!='undefined'?config.totalCount[i].text:'' , config.totalCount[i].textAlign );
				}else{
					insertTotalCount( config.totalCount[i].value, false , null , config.foot , typeof(config.totalCount[i].text)!='undefined'?config.totalCount[i].text:'' , config.totalCount[i].textAlign );
				}
			}
		}
	}
	
	/** 
	 * @private 
	 * @class 插入小計合計實體
	 * @memberOf TableUI
	 * @param subTotalData: 插入資訊值
	 * @param insertType: true-插在中間； false-直接插在最後
	 * @param insertNode: insertType-true有效，將插在此Row前面
	 * @param appendParent: 插在哪個區塊下 - head , body , foot;
	 * @param msg: 可顯示在第一個欄位文字
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */

	function insertTotalCount( insertData , insertType , insertNode , appendParent , msg , textAlign){
		//alert(appendParent);
		//alert("start create insertTotalData " + msg);
		var colsInfo = config.recordCol;
		var tRows = new Array();
		var TR; 
		var indexTab;
		for( var i = 0 ; i < colsInfo.length ; i = i + 1 ){
			var perCell=null;
			TR = createTRow( "", "center" );
			indexTab = 0;
			for( var j = 0 ; j < colsInfo[i].length ; j = j + 1 ){
				var col = colsInfo[i][j];
				
				if(!col.copy){
					var colData = insertData[col.key];
					//alert(j + " : " + col.key + " : "+ colData);
					if(Object.isUndefined(colData) || colData === null || colData === ''){
						if(!perCell || !perCell.hasAttribute('isEmpty')){
							perCell = createCell("TD", {'isEmpty':'true'});
							TR.insert(perCell);
						}else{
							perCell.setAttribute('colSpan',(perCell.getAttribute("colSpan")||1 )+1);		
						}
					}else{
						// formatDatas
						var type = col.sortRule;
						if(!type && col.input){
							type = col.type;
						}
						if(type){
							var settingPattern = (col.attrs && col.attrs.pattern) || (col.input && col.input.attrs && col.input.datatype) || "";
							
							type = type.toLowerCase();
							if(type == "number"){
								if(isNumeric(colData)){
									if ( hasLocaleDisplay && !numberPattern ){
										colData = localeDisplay.formatNumber(colData , col.attrs.scale);
									}else{
										var numberPattern = settingPattern ||  "#,##0.####";
										colData = CSRUtil.$fmt(colData, numberPattern);	
									}
								}
							}else if(type == "date"){
								if( hasLocaleDisplay && !settingPattern ){
									colData = localeDisplay.formatDate(colData);
								}else{
									if(!SimpleDateFormatSave[col.key]){
										var datePattern = settingPattern || "yyyy-MM-dd";
										SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.US);
									}
									colData = (SimpleDateFormatSave[col.key]).format(colData);
								}
							}else if(type == "rocdate"){
								if(!SimpleDateFormatSave[col.key]){
									var datePattern = settingPattern || "yyyMMdd";
									SimpleDateFormatSave[col.key] = new SimpleDateFormat( datePattern, SimpleDateFormat.TW);
								}
								colData = (SimpleDateFormatSave[col.key]).format(colData);
							}else if(hasLocaleDisplay){
								if(type == "datetime"){
									colData = localeDisplay.formatTimestamp(colData);
								}else if(type == "dateym"){
									colData = localeDisplay.formatDateym(colData);
								}else if(type == "datey"){
									colData = localeDisplay.formatDatey(colData);
								}
							}
						}
						//insert
						perCell = createCell("TD",{'rowSpan': 1, 'name': col.key}).update('<b>'+( col.render&&col.renderInCount?col.render(insertData,colData):colData )+'</b>');
						if(type == "number"){
							perCell.setAttribute("align","right");
						}
						TR.insert(perCell);
						indexTab = indexTab+1;
					}
				}else{
					if(!perCell || !perCell.hasAttribute('isEmpty')){
						perCell = createCell("TD",{'isEmpty':'true'});
						TR.insert(perCell);
					}else{
						perCell.setAttribute('colSpan',( perCell.getAttribute("colSpan")||1 )+1);		
					}
				}
			}
			tRows.push(TR);
			if(indexTab == 0 ){
				TR.writeAttribute('isEmpty', 'true');
			}
		}
		var insertMsg = false;
		for( var i = 0 ; i < tRows.length ; i = i + 1 ){
			var tRow = tRows[i];
			if(!tRow.hasAttribute('isEmpty')){
				tRow.writeAttribute( "className", "tbBlue2" );
				if(insertType){
					appendParent.insertBefore( tRow , insertNode );
				}else{
					appendParent.insert( tRow );
				}
				if(!insertMsg){
					if(tRow.firstChild.hasAttribute('isEmpty')){
						tRow.firstChild.update('<b>'+msg+'</b>');
						tRow.firstChild.align = textAlign||'left';
					}
					insertMsg = true;
				}
			}
		}
	}
	
	/** 
	 * @public 
	 * @class 取得dataObj
	 * @memberOf TableUI
	 * @param node :  任意在tr下的元素
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */	
	this.getDataObj = getDataObj;
	function getDataObj( node ){
		getCellByTagName(node);
	}
	
	/** 
	 * @public 
	 * @class 取得dataObj
	 * @memberOf TableUI
	 * @param node :  任意在tr下的元素
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.isAutoCheckBoxSelected = isAutoCheckBoxSelected;
	function isAutoCheckBoxSelected(td){
		if(config.autoCheckBox){
			var tr = getRecordsByCell(td);
			var nowBackgroundColor = tr.style.backgroundColor;
			var getCheckedBox = false;
			while(tr && !getCheckedBox){
				var autoCheckBox_td =  $(tr).select("td[name='autoCheckBoxs']")[0];
				if( autoCheckBox_td ){
					getCheckedBox = true;
					var checkBox = autoCheckBox_td.select("input[funcName='autoCheckBox']")[0];
					if(checkBox){ return checkBox.checked; }
				}else{
					tr = tr.previousSibling;
					if(!tr || nowBackgroundColor != tr.style.backgroundColor){ break; }
				}
			}
		}
		return false;
	}
	
	 /** 
	 * @private 
	 * @class 準備固定HEADER
	 * @memberOf TableUI
	 * @param index : 插入recodrs資訊值
	 * @param pageTag : 插入位置  
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */	
	function fixedColumn( node ){
		//alert('fixedColumn()');
		while( node.tagName != 'TH'){
			node = node.parentNode;
		}
		var colNum = node.seq;
		var colInfo = config.columnPlus;
		var maxColSpan = 1;
		var isCheckAgain = true;
		//取得最長大小
		while(isCheckAgain){
			for( var i = 0 ; i < colInfo.length ; i = i + 1){
				isCheckAgain = false;
				if( colInfo[i][colNum].copy ){
					if(colInfo[i][colNum].copyType == 'colSpan'){
						var isReDo = true;
						while( isReDo ){
							colNum = colNum - 1;
							isReDo = false;
							if( colInfo[i][colNum].copy){
								if(colInfo[i][colNum].copyType == 'colSpan'){
									isReDo =true;
								}
							}
							
						}
						isCheckAgain = true;
						break;
					}
				}else if(colInfo[i][colNum].attrs){
					if(colInfo[i][colNum].attrs.colSpan > maxColSpan){
						maxColSpan = colInfo[i][colNum].attrs.colSpan;
					}
					if( colInfo[i][colNum+maxColSpan-1 ].attrs.colSpan ){
						if( colInfo[i][colNum+maxColSpan-1].colSpan > 1){
							maxColSpan = (maxColSpan-1) + colInfo[i][colNum+maxColSpan-1 ].attrs.colSpan;
							isCheckAgain = true;
						}
					}
				}
			}
		}
		//alert(colNum+'//'+maxColSpan);
		var status = (node.className == 'fixedth');
		if(! config.fixedColumnSetting ){ config.fixedColumnSetting = []; }
		for(var i = 0 ; i < config.colCounter ; i = i + 1 ){
			if( i >= colNum && i < (colNum+maxColSpan) ){
				config.fixedColumnSetting[i] = status;
			}
		}
		//alert(Object.toJSON(config.fixedColumnSetting));
		resetFixedWidth();
	}
	
	/** 
	 * @private 
	 * @class 重新設定所有fixed column的位置大小資訊
	 * @memberOf TableUI
	 * @param RSpace : 右方保留空白
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function resetFixedWidth(){
		//alert('resetFixedWidth');
		
		if(! config.fixedColumnSetting ){ config.fixedColumnSetting = []; return; }
		if(config.fixedColumnSetting.length == 0 ){ return; }
		var tempArray = [];
		var THs = config.head.getElementsByTagName('TH');
		for(var i = 0 ; i < THs.length ; i = i + 1 ){
			var TH = THs[i];
			TH.className = 'fixedth';
			if( !TH.getAttribute("colSpan") <= 1 ){
				if( config.fixedColumnSetting[TH.seq] && !tempArray[TH.seq] ){
					tempArray[TH.seq] = { width: TH.offsetWidth , left: TH.offsetLeft , right: TH.offsetWidth+TH.offsetLeft };
				}
			}
		}
		var shiftLength = 0;
		for(var i = 0 ; i < tempArray.length ; i = i + 1 ){
			if(	tempArray[i] ){
				tempArray[i].sLeft = shiftLength;
				shiftLength = shiftLength + tempArray[i].width;
			}
		}
		shiftLength = config.table.offsetHeight > config.table.parentNode.offsetHeight?18:0;
		for(var i = tempArray.length-1 ; i >= 0  ; i = i - 1 ){
			if(	tempArray[i] ){
				tempArray[i].sRight = shiftLength;
				shiftLength = shiftLength + tempArray[i].width;
			}
		}
		//alert(Object.toJSON(tempArray));

		config.fixedTHInfo = new Hash();
		for(var i = 0 ; i < THs.length ; i = i + 1 ){
			var TH = THs[i];
			if( tempArray[TH.seq] ){
				var colSpan = (!TH.colSpan||TH.colSpan==0)?1:TH.colSpan;
				var valueMap = { width: 0 , left: 0 , right: 0 , sLeft: 0 , sRight:0 };
				for(var j = 0 ; j < colSpan ; j = j + 1 ){
					valueMap.width = valueMap.width + tempArray[TH.seq+j].width;
					if(j==0){
						valueMap.left = tempArray[TH.seq+j].left;
						valueMap.sLeft = tempArray[TH.seq+j].sLeft;
					}
					valueMap.right = tempArray[TH.seq+j].right;
					valueMap.sRight = tempArray[TH.seq+j].sRight;
				}
				config.fixedTHInfo.set( TH.name , valueMap );
				TH.className = 'fixedColmunth';
				TH.orgOffsetWidth = valueMap.width;
				TH.orgOffsetRight = valueMap.right;
				TH.orgOffsetLeft = valueMap.left;
				TH.shiftLeft = valueMap.sLeft;
				TH.shiftRight = valueMap.sRight;
			}
		}
		setFixed();
	}
	
	 /** 
	 * @private 
	 * @class 固定row
	 * @memberOf TableUI
	 * @param TR : 作用列
	 * @param isHide : 設定false則強制移除屬性。  
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */	
	function setFixedOneRow( TR , isHide , findTag ){
		if(!TR ||  TR.tagName != 'TR'  || !config.fixedTHInfo ){return;}
		var TDs = TR.getElementsByTagName( (findTag||"TD") );
		for(var i = 0 ; i < TDs.length ; i = i + 1 ){ setFixedOneCell( TDs[i] , TR , isHide ); }
	} 
	 /** 
	 * @private 
	 * @class 固定一個TD/TH
	 * @memberOf TableUI
	 * @param TD : 作用目標
	 * @param TR : 作用列
	 * @param isHide : 設定false則強制移除屬性。  
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */	
	function setFixedOneCell( TD , TR, isHide ){
		if(!TD || ( TD.tagName != 'TD' && TD.tagName != 'TH' ) || !config.fixedTHInfo ){return;}
		var colInfo = config.fixedTHInfo;
		if( colInfo.get(TD.name) && !isHide ){
			var set = colInfo.get(TD.name);
			var currentTrClassName = TR.className;
			if(currentTrClassName == "tbYellow2"){
				TD.writeAttribute('className', 'fixedColmun1');
			}else if(currentTrClassName == "tbBlue3"){
				TD.writeAttribute('className', 'fixedColmun2');
			}else if(currentTrClassName == "tbBlue2"){
				TD.writeAttribute('className', 'fixedColmun3');
			}
			TD.orgOffsetWidth = set.width;
			TD.orgOffsetRight = set.right;
			TD.orgOffsetLeft = set.left;
			TD.shiftLeft = set.sLeft;
			TD.shiftRight = set.sRight;
			
		}else{
			var currentTdClassName = TD.className;
			if(currentTdClassName=="fixedColmun1" || currentTdClassName=="fixedColmun2" || currentTdClassName=="fixedColmun3"){
				TD.writeAttribute('className', '');
			}
		}
	}
	
	/** 
	 * @private 
	 * @class 將頁面所有的TR設置Fix屬性
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function setFixed(){
		
		var TRs = config.table.getElementsByTagName('TR');
		for(var j = 0 ; j < TRs.length ; j = j + 1 ){
			setFixedOneRow( TRs[j] , TRs[j].parentNode.isHide );		
		}
		
		if(config.totalCount){
			var TRs = config.foot.getElementsByTagName('TR');
			for(var j = 0 ; j < TRs.length ; j = j + 1 ){
				setFixedOneRow( TRs[j] , false ,"TH");		
			}	
		}
	}
	
	 /** 
	 * @public 
	 * @class 將頁面所有的FIX清除
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 this.clearFixed = clearFixed;
	 function clearFixed(){
		config.fixedTHInfo = new Hash();
		setFixed();
	}
	
	 /** 
	 * @public 
	 * @class 將Div高度重設
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.resize = function(){resetDivHeight(false); };
	this.resetDivHeight = function(){resetDivHeight(false); };
	if(overDiv!==false){
		config.table.parentNode.resetDivHeight = resetDivHeight;
	}
	var count = 0;
	function resetDivHeight(waiting){
		if(resizeDetectionDiv && !overDiv.alwaysFixedSize && (count++) < 1000){
			if(count == 100){alert(count);}
			
			var mainTable =  config.table;
			var div_overDiv = mainTable.parentNode;

			if(resizeDetectionDiv.getAttribute('resizing') == 'Y'){
				if(!resizeDetectionDiv.getAttribute('again')){
					resizeDetectionDiv.setAttribute('again','Y');
					return;
				}
			}else{
				resizeDetectionDiv.setAttribute('resizing','Y');
			}
			
			div_overDiv.style.width = '2px';
			div_overDiv.style.height = 'auto';
			resizeDetectionDiv.style.height = mainTable.offsetHeight + "px";
			resizeDetectionDiv.style.width = '1px';
			mainTable.hide();
			resizeDetectionDiv.appendChild(mainTable);
			if(waiting !== false){
				setTimeout(resetDivHeight_end,200);
			}else{
				resetDivHeight_end();
			}
		}
	}
			
	function resetDivHeight_end(){		
			
		if(resizeDetectionDiv.getAttribute('resizing') == 'Y'){
			var mainTable =  config.table;
			var div_overDiv = resizeDetectionDiv.parentNode;
			
			div_overDiv.style.width = 'auto';
			resizeDetectionDiv.style.width = "20000px";
			mainTable.style.width = 'auto';
			mainTable.show();
			var overDiv_width = div_overDiv.parentNode.offsetWidth;
			var table_width = mainTable.offsetWidth;
			
			var maxWidth = overDiv_width;
			if( table_width > overDiv_width ){
				maxWidth =  Math.floor(table_width*1.2);
			}
			//alert(maxWidth +"==="+ overDiv_width + "/" +table_width );
			div_overDiv.style.width = overDiv_width +'px';
			mainTable.style.width = maxWidth  +'px';
			div_overDiv.appendChild(mainTable);
			div_overDiv.style.overflowX = 'auto';
			div_overDiv.style.overflowY =  'visible';
			resizeDetectionDiv.style.height = '100%';
			resizeDetectionDiv.style.width = '100%';
			
			//for固定所以要設定值
			if(config.title){ config.title.orgOffsetWidth = maxWidth; }
			if(config.footTh){ config.footTh.orgOffsetWidth = maxWidth;}
			
			if(mainTable.offsetWidth>div_overDiv.offsetWidth){
				div_overDiv.style.height = (div_overDiv.offsetHeight+17)+'px';
			}
			resetFixedWidth();
			
			var again = resizeDetectionDiv.hasAttribute('again') && resizeDetectionDiv.getAttribute('again');
			if( again == 'Y'){
				resizeDetectionDiv.setAttribute('again','N');
				resetDivHeight(false);
			}else{
				setTimeout(function(){
				if( again == 'N'){
					resizeDetectionDiv.removeAttribute('again');
				}
				resizeDetectionDiv.setAttribute('resizing','N');
				},100);
			}
		}
	}
	
	/** 
	 * @public 
	 * @class 將自動產生的input物件換置成文字
	 * @param TR (Element): Table Row 物件
	 * @param template (Array) : 限定在Array的元素置換
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.exchangeAutoInput = exchangeAutoInput;
	function exchangeAutoInput( TR , template  , isCloseInput ){
		
		isCloseInput = (isCloseInput !== true && isCloseInput!==false) ? null : isCloseInput;

		var tempMap; 
		
		if(Object.isArray(template) && template.length > 0 ){ 
			tempMap = {};
			for(var i = 0 ; i < template.length ; i = i + 1  ){
				tempMap[template[i]] = true;
			}
		}else if(Object.isString(template)){
			tempMap = {};
			tempMap[template] = true;
		}else if(template){
			return {};
		}
		
		TR = getCellByTagName( TR , "TR");
		
		while(TR.getAttribute("split")){
			TR =TR.previousSibling;
		}

		do{
			var tds = TR.getElementsByTagName('TD');
			for(var i = 0 ; i < tds.length ; i = i + 1  ){
				var active_td = tds[i];
				var td_name = active_td.getAttribute("name");
				var isAutoInput = active_td.childNodes.length > 1 && active_td.firstChild.getAttribute("name") == "inputData";
				if( (!tempMap || tempMap[td_name]) && isAutoInput ){
					var status = isCloseInput != null ? isCloseInput : tds[i].childNodes[0].style.display=='none';
					tds[i].childNodes[0].style.display = !status?'none':'';
					tds[i].childNodes[1].style.display = status?'none':'';
				}
			}
			TR = TR.nextSibling;
		}while( TR && TR.getAttribute("split") );
		resetDivHeight(false);
	}
	
		
	/** 
	 * @public 
	 * @class 將自動產生的input物件設定為失效
	 * @param TR (Element): Table Row 物件
	 * @param template (Array) : 限定在Array的元素置換
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.disableAutoInput = disableAutoInput;
	function disableAutoInput( TR , template  , isDisableInput ){
		
		isDisableInput = (isDisableInput !== true && isDisableInput!==false) ? null : isDisableInput;

		var dataMap = getAutoInput(TR,template);

		for(var key in dataMap){
			var active_data = dataMap[key];
			if(!active_data.length){ active_data = [active_data]; }
			
			for(var j = 0 ; j < active_data.length ; j = j + 1  ){
				
				var isDisable = isDisableInput != null ? isDisableInput : !active_data[j].disabled;
				active_data[j].disabled = isDisable;
			}
		}
		resetDivHeight(false);
	}
	
	this.getThisRecordTD = getThisRecordTD;
	function getThisRecordTD( TR , template ){
		
		TR = getCellByTagName( TR , "TR");
		if(!TR){ return {}; }
		
		var tempMap; 
		if(Object.isArray(template) && template.length > 0 ){ 
			tempMap = {};
			for(var i = 0 ; i < template.length ; i = i + 1  ){
				tempMap[template[i]] = true;
			}
		}else if(Object.isString(template)){
			tempMap = {};
			tempMap[template] = true;
		}else if(template){
			return {};
		}
		
		//至紀錄第一行
		while(TR.getAttribute("split")){
			TR =TR.previousSibling;
		}
		
		var rtn_map = {};
		do{
			var tds = TR.getElementsByTagName('TD');
			for(var i = 0 ; i < tds.length ; i = i + 1  ){
				var active_td = tds[i];
				var td_name = active_td.getAttribute("name");
				if(!tempMap || tempMap[td_name]){
					rtn_map[td_name] = active_td;
				}
			}
			TR = TR.nextSibling;
		}while( TR && TR.getAttribute("split") );
		return rtn_map;
	}
	
	this.getAutoInput = getAutoInput;
	function getAutoInput( TR , template ){
		
		var dataMap = getThisRecordTD(TR,template);
		
		var rtnMap ={};
		for(var key in dataMap){
			var td = dataMap[key];
			if(!(td.childNodes.length > 1 && td.firstChild.getAttribute("name") == "inputData")){
				continue;
			}
			
			var inputs = td.getElementsByTagName("INPUT");
			if(inputs.length){
				if(inputs.length == 1){
					rtnMap[key] = inputs[0];
				}else{
					rtnMap[key] = inputs
				}
				continue;
			}
			
			inputs = td.getElementsByTagName("SELECT");
			if(inputs.length){
				rtnMap[key] = inputs[0];
				continue;
			}
			
			inputs = td.getElementsByTagName("BUTTON");
			if(inputs.length){
				rtnMap[key] = inputs[0];
				continue;
			}
			
			inputs = td.getElementsByTagName("TEXTAREA");
			if(inputs.length){
				rtnMap[key] = inputs[0];
				continue;
			}
		}
		return rtnMap;
	}
	
	this.setValueToTD = setValueToTD;
	function setValueToTD( TR , target_name , value ){
		
		var target = getThisRecordTD( TR , target_name )[target_name];
		if(!target){ return; }
		
		if(Object.isArray(target)){
			for(var i = 0 ; i < target.length ; i++ ){
				executeBlur(target[i]);
			}
		}else{
			target.innerHTML = value;
		}
	}
	
	this.setValueToAutoInput = setValueToAutoInput;
		function setValueToAutoInput( TR , target_name , value ){
			var target = getAutoInput( TR , target_name )[target_name];
			if(Object.isArray(target)){
				for(var i = 0 ; i < target.length ; i++ ){
					executeBlur(target[i] , value);
				}
			}else{
				executeBlur(target , value);
			}
		}
		
		function executeBlur( dom , value ){
			if(!dom.tagName || dom.disabled ){return; }
			var testDisabled = dom;
			while( testDisabled && testDisabled.tagName!="TD"){
				if(testDisabled.style.display == 'none'){
					return;
				}
				testDisabled = testDisabled.parentNode;
			}
			var target_type = (dom.getAttribute("type")||"").toLowerCase();
			if( (target_type == 'checkbox' || target_type == 'radio')){
				if(dom.getAttribute("value") != value){
					return;
				}
				dom.checked = true;
				dom.click();
			}else if(dom.tagName == "BUTTON" || target_type == 'button' ){
				dom.click();
			}else{
				dom.focus();
				if(dom.tagName == "TEXTAREA"){
					dom.innerHTML = value;
				}else{
					dom.value = value;
				}
				dom.blur();
			}
		}
	
	/** 
	 * @public 
	 * @class 取得傳入的所有資料
	 * @memberOf TableUI
	 * @return {Array} allRecords
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.getAllRecords = getAllRecords;
	function getAllRecords( valueTemplate ){
		valueTemplate = (valueTemplate && ( Object.isArray(valueTemplate) ||  Object.isString(valueTemplate))) ? valueTemplate : false; 
		if(!valueTemplate){
			return allRecords; 
		}
		var isTemplateArray = Object.isArray(valueTemplate);
		var rtnList = [];
		
		for(var i = 0 ; i < allRecords.length ; i +=1){
			if(isTemplateArray){
				var newRecMap = {};
				for(var j = 0 ; j < valueTemplate.length ; j +=1){
					var key = valueTemplate[j];
					if(Object.isString(key) || isNumeric(key)){
							newRecMap[key] = allRecords[i][key];
					}
				}
				rtnList.push(newRecMap);
			}else{
				rtnList.push(allRecords[i][valueTemplate]);
			}
			
		}
		return rtnList;
		
	}
	
	/** 
	 * @public 
	 * @class 動態重設每一頁所包含的資料數
	 * @memberOf TableUI
	 * @param {number} pageValue 設定每頁新的資料筆數
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.resetPageSize = resetPageSize;
	function resetPageSize(pageValue){
		config.pageSize = pageValue;
		load( allRecords , config.totalCount||null , config.subTotalCount||null );
	}
	
	/** 
	 * @public 
	 * @class 動態加入record
	 * @memberOf TableUI
	 * @param {array} dataArrayMap 要加入的資料
	 * @param {array} sortTemplate 加入後要做的排序值(若已有Group,自動依照Group排序); 若都未設置，則直接加于table最後方
	 * @param {array} newTotalCount 要更新的總計
	 * @param {array} addSubCount 將此資料加到現有的subCount，請注意，當有newSubCount時本參數失效。
	 * @param {array} newSubCount 將subCount更新為此資料，請注意，當有此參數時addSubCount參數失效。
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.addRecords = addRecords;
	function addRecords( dataArrayMap , sortTemplate , newTotalCount , addSubCount , newSubCount ){
		
		if(!allRecords || allRecords.length==0){
			load(dataArrayMap,newTotalCount,newSubCount||addSubCount);
			return;
		}
		
		if( newTotalCount ){ config.totalCount = newTotalCount; }
		if( newSubCount ){ resetSubTotalCount(newSubCount); }
		else if (addSubCount){
			if(config.subTotalCount){ config.subTotalCount = config.subTotalCount.concat(addSubCount); }
			else { config.subTotalCount = addSubCount; }
		}
		
		if( !dataArrayMap || dataArrayMap.length == 0 ){ return; }
		if( sortKeys ){ sortTemplate = sortTemplate; }
		if( sortTemplate ){
			for( var i = 0 ; i < dataArrayMap.length ; i = i + 1 ){
				allRecords.push(dataArrayMap[i]);
			}
			for( var i = 0 ; i < sortTemplate.length ; i = i + 1 ){
				sort(sortTemplate[i]);
			}
			return;
		}
		var RecordsLength = allRecords.length + 0;
		if( config.table.endLoad < config.table.startLoad || config.table.endLoad != RecordsLength - 1 ){
			var subTotalCount = config.subTotalCount?true:false;
			var isEndPageGen;
			var lastPage = config.body.lastChild;
			if(config.pageSize){
				isEndPageGen = config.pageSize - lastPage.PageSize;
			}else{
				isEndPageGen = 	dataArrayMap.length ;
			}
			var tempLastDom = document.createDocumentFragment();
			var tempPageDom = document.createDocumentFragment();
			var tempPage;
			var recordInsert = 0 ;
			var tbColor = isEndPageGen==0?"tbYellow2":lastPage.lastChild.className;
			for( var i = 0 ; i < dataArrayMap.length ; i = i + 1 ){
				allRecords.push(dataArrayMap[i]);
				var count = render( allRecords.length - 1 );
				var tempDom = document.createDocumentFragment();
				if(count == 0 || count == 2){
					tbColor = tbColor != "tbYellow2" ? "tbYellow2" : "tbBlue3";
					var tRows = allRecords[allRecords.length - 1].tRows;
					var splitLog = false;
					tRows.each( function( tRow ) {
						tRow.setAttribute( "className", tbColor );
						tRow.setAttribute( "split", splitLog );
						splitLog = true;
						tempDom.appendChild( tRow );
					});
				}
				if( recordInsert < isEndPageGen ){
					//加在已產生的最後一頁
					tempLastDom.appendChild(tempDom);
					if(count == 0 || i == dataArrayMap.length - 1 ){
						recordInsert = recordInsert + 1; 
						lastPage.pageSize = lastPage.PageSize + 1 ;
						if(subTotalCount){
							insertSubTotalCount( allRecords.length - 1 , lastPage );
						}
					}
					if(recordInsert == isEndPageGen-1){
						tbColor == "tbYellow2";
					}	
				}else{
					//加在新的一頁
					if( !tempPage || tempPage.PageSize == config.PageSize ){
						tempPage = new Element("page");
						tempPage.PageID = page.getNewPageWhenAddRec();
						tempPage.PageSize = 0;
						tempPageDom.appendChild( tempPage );
					}
					tempPage.insert(tempDom);
					if(count == 0 || i == dataArrayMap.length - 1 ){
						tempPage.PageSize = tempPage.PageSize + 1 ;
						if(subTotalCount){
							insertSubTotalCount( allRecords.langth - 1 , tempPage );
						}
					}
				}
			}
			lastPage.appendChild(tempLastDom);
			if(tempPage){
				config.body.appendChild(tempPageDom);
			}
		}else{
			for( var i = 0 ; i < dataArrayMap.length ; i = i + 1 ){
				allRecords.push(dataArrayMap[i]);
			}
			config.table.endLoad = allRecords.length - 1;
		}
		if( config.table.endLoad - config.table.startLoad < 0 ){
			config.table.totCheckBox = 0;
			var tempinputs = config.body.getElementsByTagName("input");
			for( var m = 0 ; m < tempinputs.length ; m = m + 1 ){
				if( tempinputs[m].funcName = 'autoCheckBox' ){
					config.table.totCheckBox = config.table.totCheckBox + 1;
				}	
			}
			
		}
		page.updatePageSizeInfo();
	}
	
	/** 
	 * @public 
	 * @class 檢核資料是否有誤，需搭配 setValidRecord 使用
	 * @memberOf TableUI
	 * @return {boolean} 資料是否含有非合法資訊，若是，回傳array:{dataObj , validHash}，若否回傳false(檢核無誤)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.validTable = validTable;
	function validTable(){
		var trs = config.body.select("TR");
		var returnValid = [];
		for(var i = 0 ; i < trs.length ; i = i + 1 ){
			var oTr = trs[i];
			if(oTr.className =='tbBlue3' || oTr.className =='tbYellow2'){
				if(oTr.dataObj.validHash && oTr.dataObj.validHash.size()>0 ){
					//alert( 'set color ' + oTr.dataObj.validHash.size() + '**' + Object.toJSON(oTr.dataObj.validHash));
					if(oTr.style.backgroundColor == '#c2ffbc' ){
						 whenSelectRec(oTr);
					}
					oTr.style.backgroundColor = '#EB98AB';
					if( !oTr.split ){
						var Obj = Object.clone(oTr.dataObj);
						returnValid.push( {dataObj:Obj , validHash:Obj.validHash });
					}
				}else{
					if(oTr.style.backgroundColor == '#eb98ab'){oTr.style.backgroundColor = ''} ;
				}
			}
		}
		return returnValid;
	}
	
	/** 
	 * @public 
	 * @class 檢核勾選資料是否有誤，需搭配 setValidRecord 及 autoCheckBox 使用
	 * @memberOf TableUI
	 * @return {boolean} 資料是否含有非合法資訊，若是，回傳array:{dataObj , validHash}，若否回傳false(檢核無誤)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.validCheckedOnTable = validCheckedOnTable;
	function validCheckedOnTable(){
		var inputs = config.body.getElementsByTagName('INPUT');
		var Objs = [];
		for(var i = 0 ; i < inputs.length ; i = i + 1 ){
			if(inputs[i].funcName == 'autoCheckBox' && inputs[i].checked ){
				var tr = inputs[i];
				while(tr.tagName != 'TD'){ tr =tr.parentNode; }
				var rows = tr.rowSpan||1;
				while(tr.tagName != 'TR'){ tr =tr.parentNode; }
				while(rows > 0 ){
					if( !tr.split ){
						valid = getValidRecord(tr);
						if( valid ){ Objs.push(valid); }
					}
					tr = tr.nextSibling;
					if(!tr){ break; }
					rows = rows -1;
				}
			}
		}
		return Objs; 
	}
	
	/** 
	 * @private 
	 * @class 當右鍵點選資料時，變色；可設定是否選擇幾筆
	 * @memberOf TableUI
	 * @author Liang-hsun , Huang ws9300618 
	 * @version 1.00
	 * */
	function whenSelectRec( selectNode ){
		if(config.selectNum === 0){ return; }
		if(!selectNode){ selectNode = this; }
		selectNum = config.selectNum || 1  ;
		while(selectNode.tagName != 'TR' ){
			selectNode = selectNode.parentNode;
		}
		var selectClass = selectNode.className;
		if(selectClass != 'tbBlue3' && selectClass != 'tbYellow2'){ return; }
		
		var maxCellNum = 0 ;
		if(config.selectRowWithGroup){
			maxCellNum = config.columnPlus[0].length;
		}
		
		while( maxCellNum==0?selectNode.split:selectNode.cells.length!=maxCellNum  ){
			selectNode = selectNode.previousSibling;
		}
		if(selectNode.style.backgroundColor == '#c2ffbc'){
			if(selectNum){
				for( var i = 0 ; i < config.selectTr.length ; i = i + 1){
					if(config.selectTr[i] == selectNode){ config.selectTr.splice( i , 1 ); break;}
				}
			}
			do{
				selectNode.style.backgroundColor = '';
				selectNode = selectNode.nextSibling;
			}while( selectNode && (maxCellNum==0?selectNode.split:selectNode.cells.length!=maxCellNum) );
		}else if(selectNode.style.backgroundColor == '#eb98ab'){
			return;
		}else{
			if(selectNum){
				if(! config.selectTr ){config.selectTr = []; }
				if( config.selectTr.length == selectNum ){
					var delTr = config.selectTr.shift();
					var delClass = delTr.className;
					var isFind = false;
					for( var i = 0 ; i < config.body.rows.length ; i = i + 1){
						if(config.body.rows[i] == delTr){ isFind = true; }
						if(isFind){
							do{
								config.body.rows[i].style.backgroundColor = '';
								i = i +1; 
							}while(config.body.rows[i] && (maxCellNum==0?config.body.rows[i].split:config.body.rows[i].cells.length!=maxCellNum) );
							break;
							
						}
					}	
				}
				config.selectTr.push( selectNode );	
			}
			
			if(config.rowClick && typeof(config.rowClick)=='function'){
				config.rowClick( selectNode , selectNode.dataObj );
			}
			
			do{
				selectNode.style.backgroundColor = '#C2FFBC';
				selectNode = selectNode.nextSibling;
			}while( selectNode && (maxCellNum==0?selectNode.split:selectNode.cells.length!=maxCellNum) );
			
			
		}
	}
	
	/** 
	 * @public
	 * @class 全部資料輸出成XLS檔
	 * @memberOf TableUI
	 * @param {String} fileName 設定輸出檔案名稱，若此欄為false family 回傳輸出資訊。
 	 * @param {boolean} isCount 是否輸出小計合計欄位(預設為false)
     * @param {int} bgColorType 輸出顏色樣式 0-無色 1-彩色(預設) 2-灰色
	 * @param {String} sheetName 輸出之活頁名稱
 	 * @param {boolean} isRetuenValue 是否不要直接輸出XLS，若是，回傳輸出資訊
	 * @return {boolean} 資料是否正確輸出(或是輸出資訊值)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.exportAllToXLS = exportAllToXLS;
	function exportAllToXLS( fileName , isCount , bgColorType , sheetName ){
		
		return exportToXLS( fileName , allRecords , isCount , bgColorType , sheetName );
	}
	
	/** 
	 * @public
	 * @class autoCheckBox資料輸出成XLS檔
	 * @memberOf TableUI
	 * @param {String} fileName 設定輸出檔案名稱，若此欄為false family 回傳輸出資訊。
  	 * @param {boolean} isCount 是否輸出小計合計欄位(預設為false)
     * @param {int} bgColorType 輸出顏色樣式 0-無色 1-彩色(預設) 2-灰色
     * @param {String} sheetName 輸出之活頁名稱
	 * @param {boolean} isRetuenValue 是否不要直接輸出XLS，若是，回傳輸出資訊
	 * @return {boolean} 資料是否正確輸出(或是輸出資訊值)	 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.exportCheckToXLS = exportCheckToXLS;
	function exportCheckToXLS( fileName , isCount , bgColorType , sheetName ){
		
		return exportToXLS( fileName , getCheckedRecord() , isCount , bgColorType , sheetName );
	}
	
	/** 
	 * @public
	 * @class 輸出傳入資料成XLS檔
	 * @memberOf TableUI
	 * @param {String} fileName 設定輸出檔案名稱，若此欄為false family 回傳輸出資訊。
	 * @param {Array} records 輸出的資料
 	 * @param {boolean} isCount 是否輸出小計合計欄位(預設為false)
     * @param {int} bgColorType 輸出顏色樣式 0-無色 1-彩色(預設) 2-灰色	 
     * @param {String} sheetName 輸出之活頁名稱
	 * @return {boolean} 資料是否正確輸出(或是輸出資訊值)
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.exportToXLS = exportToXLS;
	function exportToXLS( fileName , records , isCount , bgColorType , sheetName ){
		
		if(!records || !records.length ){ 
			if(!fileName){
				return { sheetName:sheetName||"" , isMultiCols:true , multiColsData:[[{ dataIndex:"" , header:"", type:"copy", rowSpan:0 , colSpan: 0 }]] , bgColorType:isNumeric(bgColorType)?bgColorType:1 };
			}else{
				return false;
			}
		}
		
		var headerCol = config.columnPlus;
		var recordCol = config.recordCol;
		
		var exportData = [];
		var posit = 0 ;
		//alert(headerCol.length);
		for(var i = 0 ; i < headerCol.length ; i = i + 1 ){
			exportData[posit] = [];
			for(var j = 0 ; j < headerCol[i].length ; j = j + 1 ){
				var columnSet = headerCol[i][j];
				if( ! columnSet.copy ){
					//push the infomation
					var dataIndex = columnSet.header;
					if( !(Object.isString(dataIndex) || isNumeric(dataIndex) || typeof(dataIndex)=='boolean') ){
						if(Object.isElement(dataIndex)){
							dataIndex = dataIndex.innerText;
						}else{
							dataIndex = "";
						}
					}
					if(typeof(dataIndex)=='string'){
						dataIndex = dataIndex.replace(/<br>/gi,"\012");
						dataIndex = dataIndex.replace(/<\/br>/gi,"\012");
						dataIndex = dataIndex.replace(/<BR>/gi,"\012");
						dataIndex = dataIndex.replace(/<\/BR>/gi,"\012");
					}
					exportData[posit].push( { 
						dataIndex:dataIndex , 
						header:columnSet.key, 
						type:"string", 
						rowSpan:( columnSet.attrs && columnSet.attrs.rowSpan )?columnSet.attrs.rowSpan:1 , 
						colSpan:( columnSet.attrs && columnSet.attrs.colSpan )?columnSet.attrs.colSpan:1   
					}  );
				}else{
					exportData[posit].push( { dataIndex:"" , header:"", type:"copy", rowSpan:0 , colSpan: 0 }  );
				}
			}
			posit = posit + 1 ;
		}
		
		var groupColRec = new Hash();
		var setRec , preRec , nextRec;
		var bgColor = 1;
		var changeNextColor = false;
		//alert(records.length);
		for(var k = 0 ; k < records.length ; k = k + 1 ){
			setRec = records[k];
			if(k < records.length-1){ nextRec = records[k+1]; }else{nextRec = null; }
			changeNextColor = true;
			for(var i = 0 ; i < recordCol.length ; i = i + 1 ){
				exportData[posit] = [];
				for(var j = 0 ; j < recordCol[i].length ; j = j + 1 ){
					var setCol = recordCol[i][j];
					if( ! setCol.copy ){
						//處理group!!
						if( setCol.groupKey && setCol.attrs.rowSpan == recordCol.length ){
							var isGroup = 0;	
							var nextGroup = 0;
							for(var l = 0 ; l < setCol.groupKey.length ; l = l + 1  ){
								if( preRec && setRec[setCol.groupKey[l]] === preRec[setCol.groupKey[l]]){
									isGroup = isGroup + 1;
								}
								if( nextRec && setRec[setCol.groupKey[l]] === nextRec[setCol.groupKey[l]]){
									nextGroup = nextGroup + 1 ;
								}
							}
							if(nextGroup > 0 && nextGroup === setCol.groupKey.length ){ changeNextColor = false; }
							
							if( isGroup == 0  ){
								groupColRec.set(setCol.key , {i:posit+0,j:exportData[posit].length });
							}else{
								exportData[posit].push( { dataIndex:"" , header:"", type:"copy", rowSpan:0 , colSpan: 0 }  );
								var gupcell = exportData[ (groupColRec.get(setCol.key)).i ][ (groupColRec.get(setCol.key)).j ];
								gupcell.rowSpan = gupcell.rowSpan + recordCol.length ;
								continue;
							}
							

						}
						//處理資訊!!
						var dataIndex = setRec[ setCol.key ];
						if(setCol.render){
							dataIndex = setCol.render( setRec , dataIndex );
							if( !(Object.isString(dataIndex) || isNumeric(dataIndex) || typeof(dataIndex)=='boolean') ){
								dataIndex = setRec[ setCol.key ];
							}
						}
						if( !(Object.isString(dataIndex) || isNumeric(dataIndex) || typeof(dataIndex)=='boolean') ){
							if(Object.isElement(dataIndex)){
								dataIndex = dataIndex.innerText;
							}else{
								dataIndex = "";
							}
						}
						if(typeof(dataIndex)=='string'){
							dataIndex = dataIndex.replace(/<br>/gi,"\012");
							dataIndex = dataIndex.replace(/<\/br>/gi,"\012");
							dataIndex = dataIndex.replace(/<BR>/gi,"\012");
							dataIndex = dataIndex.replace(/<\/BR>/gi,"\012");
						}
						if( typeof(dataIndex) === 'string' && (setCol.sortRule||"").toLowerCase() == 'number' && setCol.exportNumber !== false ){ 
							var valueSplit = dataIndex.split(",");
							var tempValue = "a";
							for(var o = 0 ;  o < valueSplit.length ; o = o + 1){
								tempValue=tempValue+valueSplit[o];
							}
							dataIndex=parseFloat(tempValue.substr(1,tempValue.length-1));
						}
						exportData[posit].push( { 
							dataIndex:dataIndex , 
							header:setCol.key , 
							type:setCol.sortRule?setCol.sortRule.toLowerCase():"string", 
							rowSpan:( setCol.attrs && setCol.attrs.rowSpan )?setCol.attrs.rowSpan:1 , 
							colSpan:( setCol.attrs && setCol.attrs.colSpan )?setCol.attrs.colSpan:1 , 
							bgColor:bgColor 
						}  );
					}else{
						exportData[posit].push( { dataIndex:"" , header:"", type:"copy", rowSpan:0 , colSpan: 0 , bgColor:bgColor }  );
					}
				}
				posit = posit + 1 ;
			}
			if(changeNextColor){ 
				bgColor = (bgColor===1?2:1); 
				//加入小計部分
				if(isCount){
					setSubCountInfoInXLS( exportData , setRec );
				}
			}
			preRec = allRecords[k];
		}
		//加入總計
		if(isCount){
			setTotalCountInfoInXLS(exportData);
		}
		//輸出
		if(!fileName){
			return { sheetName:sheetName||"" , isMultiCols:true , multiColsData:exportData , bgColorType:isNumeric(bgColorType)?bgColorType:1 };
		}else{
			return TableUIsExportToXLS( fileName , [ { sheetName:sheetName||"" , isMultiCols:true , multiColsData:exportData , bgColorType:isNumeric(bgColorType)?bgColorType:1 } ] );
		}
		
	}
	
	/** 
	 * @private
	 * @class 檢查XLS是否加入小計
	 * @memberOf TableUI
	 * @param {Array} appendArray 附加的主資料檔
 	 * @param {Map} compareMap	比對條件
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function setSubCountInfoInXLS( appendArray , compareMap ){
		var datas = config.subTotalCount;
		if(!datas || !compareMap || !appendArray  ){ return; } 
		for(var i = 0 ; i < datas.length ; i = i + 1 ){
			for(var j = 0 ; j < datas[i].length ; j = j + 1 ){
				var testMap = datas[i][j].key;
				if(!testMap){ continue; }
				var testResult = true;
				for(var k = 0 ; k < groupKey.length ; k = k + 1 ){
					if( testMap[groupKey[k]] !== compareMap[groupKey[k]] ){
						testResult = false;
						break;
					}
				}
				if(testResult){
					setCountInfoInXLS( appendArray , datas[i][j].value , datas[i][j].text?datas[i][j].text+":":""  );
					break;
				}
			}
		}
	}
	
	/** 
	 * @private
	 * @class XLS加入合計
	 * @memberOf TableUI
	 * @param {Array} appendArray 附加的主資料檔
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function setTotalCountInfoInXLS( appendArray ){
		var datas = config.totalCount;
		if(!datas || !appendArray ){ return; }
		for(var i = 0 ; i < datas.length ; i = i + 1 ){
			setCountInfoInXLS( appendArray , datas[i].value , datas[i].text?datas[i].text+":":""  );
		}
		
	}
	
	/** 
	 * @private
	 * @class XLS加入合計小計資料實體
	 * @memberOf TableUI
	 * @param {Array} appendArray 附加的主資料檔
	 * @param {Map} infoMap 要加入的資料檔
     * @param {String} text 資料標題
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	function setCountInfoInXLS( appendArray , infoMap , text  ){
		var tempResult = [];
		var recordCol = config.recordCol;
		for(var i = 0 ; i < recordCol.length ; i = i + 1 ){
			tempResult[i] = [];
			for(var j = 0 ; j < recordCol[i].length ; j = j + 1 ){
				var setCol = recordCol[i][j];
				if( !setCol.copy ){
					var data = infoMap[setCol.key];
					if( setCol.render && setCol.renderInCount){
						data = setCol.render( infoMap , data );
						if(typeof(data) !== 'string' &&  typeof(data) !== 'number' ){
							data = infoMap[setCol.key]
						}
					}
					if(typeof(data) !== 'string' &&  typeof(data) !== 'number' ){
						if( tempResult[i].length == 0 && typeof(text) != 'undefined' ){
							data = text;
						}else{
							data = '';
						}
					}
					if(typeof(dataIndex)=='string'){
						data = data.replace("<br>","\012");
						data = data.replace("<\br>","\012");
						data = data.replace("<BR>","\012");
						data = data.replace("<\BR>","\012");
					}
					if( typeof(data) === 'string' && (setCol.sortRule||"").toLowerCase() == 'number' && setCol.exportNumber !== false ){ 
						var valueSplit = data.split(",");
						var tempValue = "a";
						for(var o = 0 ;  o < valueSplit.length ; o = o + 1){
							tempValue=tempValue+valueSplit[o];
						}
						data=parseFloat(tempValue.substr(1,tempValue.length-1));
					}
					tempResult[i].push( { dataIndex:data , header:data, type:setCol.sortRule?setCol.sortRule.toLowerCase():"string", rowSpan:1 , colSpan: 1  }  );
				}else{
					tempResult[i].push( { dataIndex:"" , header:"", type:"copy", rowSpan:0 , colSpan: 0  }  );
				}
			}
		}
		for(var i = 0 ; i < tempResult.length ; i = i + 1 ){
			var spanCell;
			var isEmpty = true;
			for(var j = 0 ; j < tempResult[i].length ; j = j + 1 ){
				var testResult = tempResult[i][j];
				if(testResult.dataIndex === '' || testResult.dataIndex === text ){
					if(!spanCell){
						spanCell = testResult;
					}else{
						spanCell.colSpan = spanCell.colSpan + 1 ;
						testResult.type = 'copy';
						testResult.rowSpan = 0 ;
						testResult.colSpan = 0 ;
					}
				}else{
					spanCell = null;
					isEmpty = false;
				}
			}
			if(!isEmpty){
				appendArray.push(tempResult[i])
			}
		}
	}
	/** 
	 * @public
	 * @class 重新調整DIV比例
	 * @memberOf TableUI
	 * @param {Nunber} divWidth 介於0及1的數字
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.resizeDiv = resizeDiv;
	function resizeDiv(divWidth){
		if( overDiv){
			config.table.parentNode.divWidth = divWidth;
			if(divWidth >= 0 && divWidth <= 1){
				config.table.parentNode.setStyle({'width': (document.body.clientWidth-25)*0.98*divWidth});
			}else if( divWidth > 1){
				config.table.parentNode.setStyle({'width': divWidth});
			}else{
				config.table.parentNode.setStyle({'width': (document.body.clientWidth-25)+0.98*divWidth});
			}
		}
	}
	
	/** 
	 * @public
	 * @class 輸出跳頁，排序資訊
	 * @memberOf TableUI
	 * @param {boolean} setPage 紀錄當前頁面
 	 * @param {boolean} setSort 紀錄當前頁面所操作的排序
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.getTableInfo = getTableInfo;
	function getTableInfo( setPage , setSort ){
		var infoMap = {};
		if(typeof(setPage)=='undefined' || setPage ){ infoMap.pageNo = page.getCurrentPage(); }
		if(typeof(setSort)=='undefined' || setSort ){ infoMap.sortRecords = sortRecord; }
		return infoMap;
	}
	
	/** 
	 * @public
	 * @class 設定跳頁，排序資訊
	 * @memberOf TableUI
	 * @param {Map} infoMap 設定的資訊
	 * @param {String} infoMap.pageNo 欲跳至頁面
	 * @param {Array(Map)} infoMap.sortRecords 排序設定的資訊
	 * @param {Map} sortRecords_Maps key:排序的key值， direction:排序方向( SORT_INCREASE = "\u25B2"(預設)、SORT_DECREASE = "\u25BC" )、 sortRule: String(預設) 或 number	 	 	 
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.setTableInfo = setTableInfo;
	function setTableInfo( infoMap ){
		if(!infoMap){ return; }
		if( infoMap.sortRecords && Object.isArray(infoMap.sortRecords) && infoMap.sortRecords.length > 0  ){
			var sortRecords = infoMap.sortRecords;
			for(var i = 0 ; i < sortRecords.length ; i = i + 1 ){
				sort( sortRecords[i].key, sortRecords[i].direction||SORT_INCREASE, sortRecords[i].sortRule, null , i != (sortRecords.length-1) );
			}
		}

		if( infoMap.pageNo && isNumeric(infoMap.pageNo) ){
			var totalPage = page.getTotalPage();
			var pageNo = infoMap.pageNo>totalPage?totalPage:infoMap.pageNo;
			var genPageMap = page.getGenPageMap();
			if(genPageMap.get(pageNo)){
				page.showPage(pageNo);
			}else{
				var maxP = 0  , minP = 0  ; 
				for(var i = 1 ; i <= totalPage ; i = i + 1 ){
					if(!genPageMap.get(i)){
						if(minP==0){ minP = i ;}
						maxP = i;
					}
				}
				if(pageNo <= ((maxP-minP+1)/2)){
					//正向
					for(var i = minP ; i <= pageNo ; i = i + 1 ){
						page.showPage(i);
					}
				}else{
					//反向
					for(var i = maxP ; i >= pageNo ; i = i - 1 ){
						page.showPage(i);
					}
				}				
			}
		}
	}
	
	/** 
	 * @public
	 * @class 將欄位設定資料輸出成json格式供後端程式處理輸出資料
	 * @memberOf TableUI
	 * @param {String} sheetName 輸出XLS檔時，該頁籤的名稱
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	this.getXlsSettingJSON = getXlsSettingJSON;
	function getXlsSettingJSON(sheetName){
		var headerCol = config.columnPlus;
		var recordCol = config.recordCol;
		
		var titleSetting = [];
		var recordSetting = [];
		
		var  start = 0 ;
		if(config.autoCheckBox){
			start = 1;	
		}
		
		for(var i = 0 ; i < headerCol.length ; i = i + 1){
			var aCol = [];
			titleSetting.push(aCol);
			for(var j = start ; j < headerCol[i].length ; j = j + 1){
				aCol.push( { key:headerCol[i][j].key , header:headerCol[i][j].header , sortRule:headerCol[i][j].copy?"copy":(headerCol[i][j].sortRule?headerCol[i][j].sortRule:"string") , groupKey:headerCol[i][j].groupKey , attrs:headerCol[i][j].attrs } );
			}
		}
		
		for(var i = 0 ; i < recordCol.length ; i = i + 1){
			var aCol = [];
			recordSetting.push(aCol);
			for(var j = start ; j < recordCol[i].length ; j = j + 1){
				aCol.push( { key:recordCol[i][j].key , header:recordCol[i][j].header , sortRule:recordCol[i][j].copy?"copy":(recordCol[i][j].sortRule?recordCol[i][j].sortRule:"string") , groupKey:recordCol[i][j].groupKey , attrs:recordCol[i][j].attrs } );
			}
		}
		
		var returnVar = {sheetName:sheetName , titleSetting:titleSetting , recordSetting:recordSetting , groupKeys:groupKey};
		
		return Object.toJSON(returnVar);
		
		
	}
	
	
	/** 
	 * @private 
	 * @class 依照格式化完成的JSON資料輸出XLS
	 * @param JSON (String): json格式的輸出資料
	 * @author Liang-hsun , Huang ws9300618
	 * @version 1.00
	 * */
	 this.setCellToCover = setCellToCover;
	function setCellToCover(){
		setCoverFrame();
		if(!CoverFrame || !EditFrame){ return; }
		Cell = this;
		if(!Cell){return;}
		
		Cell = getCellByTagName(Cell , "TD");
		if(!Cell){return;}
		var tr = getCellByTagName(Cell , "TR");
		exchangeAutoInput(tr , [Cell.name])
		EditFrame.editTd = Cell;
		EditFrame.oldClass = Cell.className;
		EditFrame.style.width = Cell.offsetWidth+16;
		EditFrame.style.height = Cell.offsetHeight+16;
		EditFrame.style.top = Cell.offsetTop-8;
		//EditFrame.style.left= Cell.offsetLeft; 
		
		Cell.className = Cell.className +' tableUIEditTd';	
		
		CoverFrame.style.width = config.table.offsetWidth;
		CoverFrame.style.height = config.table.offsetHeight;

		CoverFrame.style.display = '';
		EditFrame.style.display = '';
	}
	
	function closeCover(){
		if(!CoverFrame || !EditFrame){ return; }
		
		var Cell = EditFrame.editTd;
		var tr = getCellByTagName(Cell , "TR");
		exchangeAutoInput(tr , [Cell.name])
		
		Cell.className = EditFrame.oldClass;
		EditFrame.editTd = null;
		CoverFrame.style.display = 'none';
		EditFrame.style.display = 'none';
	}
	
	function isNumeric(node){ return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); } 
	
	function isBasicType( node ){
		var type = typeof(node);
		return !!( type === 'string' || type ==='number' || type === 'boolean' );
	}
	
	
} // end of TableUIPlus


//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------

function getCellByTagName(cell , TagName){
	TagName = TagName.toUpperCase();
	if(!cell.tagName || !cell.parentNode ){return false; }
	while(cell.tagName != TagName ){
		//alert(cell.tagName);
		cell = cell.parentNode;
		if(!cell.tagName|| cell.TagName == "HTML" || !cell.parentNode  ){return false; }
	}
	return cell;
}

/** 
 * @public 
 * @class 依照格式化完成的JSON資料輸出XLS
 * @param JSON (String): json格式的輸出資料
 * @author Liang-hsun , Huang ws9300618
 * @version 1.00
 * */
function ExportXLSWithJSON(JSON){
	var submitForm = new Element("form", {
		'target': 'submitForm',
		'action': '/ZRWeb/xls',
		'method': 'post'
	}).hide();

	var input1 = new Element("input", {
		'name': 'xlsData',
		'value': JSON
	});

	submitForm.insert(input1);
	document.body.appendChild(submitForm);
	submitForm.submit();
	document.body.removeChild(submitForm);
}

/** 
 * @public 
 * @class 依據傳入的資料進行XLS的輸出，支援多個sheet
 * @param fileName (String): 輸出文件名稱
 * @param fileData (Array) : 輸出值，必須為Array!!
 * @author Liang-hsun , Huang ws9300618
 * @version 1.00
 * */
function TableUIsExportToXLS( fileName , fileData ){
	if(!Object.isArray(fileData)){ return false; }
	for(var i = 0 ; i < fileData.length ; i = i + 1 ){
		if(!fileData[i]){ return false; }
	}

	var submitForm = new Element("form", {
		'target': 'submitForm',
		'action': '/ZRWeb/xls',
		'method': 'post'
	}).hide();

	var input1 = new Element('input', {
		'name': 'xlsData',
		'value': Object.toJSON( { fileName:fileName+'.xls', sheets:fileData } )
	});

	submitForm.insert(input1);
	document.body.appendChild(submitForm);
	submitForm.submit();
	document.body.removeChild(submitForm);

	return true;
}

/** 
 * @public 
 * @class 藉由在table上的元素 取得單/多筆資料
 * @param ele (Element): 存在tableUI及TD下之任意元素
 * @param valueTemplates (Array) : 限定在Array的元素輸出，若不設定，直接給予record
 * @return {array<record>}
 * @author Liang-hsun , Huang ws9300618
 * @version 1.00
 * */
//取得勾選的多(單)筆資料 (回傳一個Array)
function getValueByElement( ele , valueTemplate ){
	while(ele.tagName != 'TD'){
		ele = ele.parentNode;
	}	
	var recordRowSpan = ele.rowSpan?ele.rowSpan:1;
	var recordTR = ele.parentNode;
	var record; 
	var preValue = null ;
	var value;
	var repeat;
	//var returnRec = new Array();
	var returnVal = new Array();
	if(recordRowSpan > 1 && !recordTR.split){
		for(var i = 0 ; i < recordRowSpan ; i = i + 1 ){
			//alert(i+"    "+recordTR.split);
			if(!recordTR.split){
				record = recordTR.dataObj;
				//alert("in  " + Object.toJSON(valueTemplate) );
				if(valueTemplate && (Object.isString(valueTemplate) || ( Object.isArray(valueTemplate) && valueTemplate.length > 0 ) ) ){
					repeat = false;
					if(Object.isArray(valueTemplate)){
						value = {};
						repeat = true;
						for(var j = 0 ; j < valueTemplate.length ; j = j + 1 ){
							if( preValue == null || record[valueTemplate[j]] != preValue.get(valueTemplate[j]) 			){
								repeat = false;
							}
							value[valueTemplate[j]] = record[valueTemplate[j]];
						}
					}else{
						if( preValue != null && record[valueTemplate] == preValue[valueTemplate] ){
							repeat = true;;
						}
						value = record[valueTemplate];
						
					}
					if(!repeat){
						returnVal.push(value);
						preValue = value;
					}
				}else{
					returnVal.push(record);
					//alert("push");
				}
			}
			recordTR=recordTR.nextSibling;
		}
	}else if(recordRowSpan == 1 || recordTR.split){
		record = recordTR.dataObj;
		//alert("in  " + Object.toJSON(valueTemplate) );
		if(valueTemplate && (Object.isString(valueTemplate) || ( Object.isArray(valueTemplate) && valueTemplate.length > 0 ) ) ){
			repeat = false;
			if(Object.isArray(valueTemplate)){
				value = {};
				for(var j = 0 ; j < valueTemplate.length ; j = j + 1 ){
					value[valueTemplate[j]] = record[valueTemplate[j]];
				}
			}else{
				value = record[valueTemplate];
				
			}
			returnVal.push(value);
		}else{
			returnVal.push(record);
			//alert("push");
		}
	}
	//alert("returnVal: "+Object.toJSON(returnVal));
	return returnVal;
	
	
}
/** 
* @private 
* @class 取得該值應該在拖曳狀況下的位置
* @param node : TD元素
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function getPosition(node){
	while( !(node.tagName == 'TD' || node.tagName == 'TH') ){
		node = node.parentNode;
	}
	var div = node;
	while(div.tagName != 'DIV'){
		div = div.parentNode;
	}
	
	var scrollLeft = div.scrollLeft;
	var divWidth = parseFloat(div.style.width);
	if( node.orgOffsetLeft <= ( scrollLeft+node.shiftLeft) ){
		return ( scrollLeft+node.shiftLeft) - node.orgOffsetLeft  ;
	}else if( node.orgOffsetRight >= (scrollLeft + divWidth - node.shiftRight ) ){
		return (scrollLeft + divWidth - node.shiftRight ) - node.orgOffsetRight ;
	}else{
		return 0;	
	}
}

/** 
* @private 
* @class 取得page控制bar應該在拖曳狀況下的位置
* @param node : TD元素
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function getfootPosition(node){
	var table = node||this;
	while(table.tagName != 'TABLE'){
		table = table.parentNode;
	}
	if( table.parentNode.tagName != "DIV"){ return '0px' ; }
	var divHeight = parseFloat(table.parentNode.style.height);
	var scrollTop = table.parentNode.scrollTop;
	if( table.offsetHeight >= ( scrollTop + divHeight) ){
		//if(table.offsetWidth <= table.parentNode.offsetWidth){
			return (scrollTop + divHeight - table.offsetHeight - (table.parentNode.footspan||0) )+'px' ;
		//}else{
		//	return (scrollTop + divHeight - table.offsetHeight -16)+'px' ;
		//}
	}else{
		return '0px';	
	}
}

/** 
* @public
* @class 在keydown時檢核輸入是否合法(Number)
* @param node : input-text 元素
* @param event : onkeydown時event元素
* @param float : 限定之小數位數
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function validNumber( node , event , floatNum ){
	var keyCode = event.keyCode;
	var p = node.value.search('[.]');
	if((keyCode>= 96 && keyCode<=105)||(keyCode>=48 && keyCode<=57) ){      
		//數字符
		if( p > 0 && Object.isNumber(floatNum) ){
			if( floatNum >= node.value.length - p ){
				event.returnValue = true;
			}else{
				event.returnValue = false;
			}
		}else{
			event.returnValue = true;
		}      
	} else if(keyCode==110 || keyCode==190){
		// '.'
		if(p < 0  && floatNum !== 0  ){
			if(this.value == ''){ this.value = 0;}
			event.returnValue = true; 
		}else{
			event.returnValue = false;	
		}
	}else {      
		event.returnValue = true;      
	}
}

/** 
* @public
* @class 在keydown時檢核輸入是否合法(Date)
* @param node : input-text 元素
* @param event : onkeydown時event元素
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function validDate( node , event ){
	if( !event || !event.keyCode ){ return true; }
	var keyCode = event.keyCode;
	var l = node.value.length+0;
	if((keyCode>= 96 && keyCode<=105 )||(keyCode>=48 && keyCode<=57) ){      
		//數字符
		var perCode = node.value.substr( l - 1 , 1 );
		if(l>3){
			if(l == 4 || ( l == 7  && perCode != '-' ) ){
				node.value = node.value + '-';
				l = l + 1;
				perCode = '-'; 
			}
		}
		if(perCode == '-' ){
			if(l == 5 && ( keyCode > 97 || ( keyCode > 49  && keyCode <= 57 ) )){
				node.value = node.value + '0';
			}else if( l == 7 || l == 8 ){
				if( l == 7 ){
					node.value = node.value.substr(0 , 5) + '0' + node.value.substr(5 , 1);
				}
				if( keyCode > 99 || ( keyCode > 51 && keyCode <= 57 ) ){
					node.value = node.value + '0';	
				}
			}
		}
		event.returnValue = true;
	
	} else if(keyCode==109 || keyCode==189){
		// '-'
		var perCode = node.value.substr( l - 1 , 1 );
		if( l == 4 || (l >= 6 && l <= 7 && perCode != '-'  ) ){
			if(l == 6){
				node.value = node.value.substr(0 , 5) + '0' + node.value.substr(5 , 1);
			}
			event.returnValue = true; 
		}else{
			event.returnValue = false; 
		}
	}else{
		event.returnValue = true;
	}
}

/** 
* @public
* @class 在keydown時檢核輸入是否合法(Date)
* @param node : 任意TD下元素
* @param dataObjs : 進行判斷的資料
* @param validResult : 做完判斷的結果
* @param msg : 錯誤說明
* @return {boolean} 該資料是否含有非合法資訊，若是，回傳Msg，若否回傳false(檢核無誤)
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function setValidRecord( node , dataObjs , validResult , msg ){
	var td = node;
	while(td.tagName != 'TD'){
		td = td.parentNode;
	}
	for(var i = 0 ; i < dataObjs.length ; i = i + 1 ){
		if(!dataObjs[i].validHash){
			dataObjs[i].validHash = new Hash();
		}
		if( validResult ){
			//alert('start unset ' + td.name +'***'+ dataObjs[i].validHash.get(td.name) );
			if(typeof(dataObjs[i].validHash.get(td.name)) != 'undefined'){
				//alert('unset('+td.name+')');
				dataObjs[i].validHash.unset(td.name);
			}				
		}else{
			if(typeof(dataObjs[i].validHash.get(td.name)) == 'undefined'){
				dataObjs[i].validHash.set(td.name , msg );
			}
		}
	}
	//alert( 'end Hash '+ Object.toJSON(dataObjs[0].validHash));
	return validResult?false:msg;
}

/** 
* @public
* @class 在keydown時檢核輸入是否合法(Date)
* @param node : 任意TR下元素
* @return {boolean} 本行資料是否含有非合法資訊，若是，回傳Msg {dataObj,validHash}，若否回傳false(檢核無誤)
* @author Liang-hsun , Huang ws9300618
* @version 1.00
* */
function getValidRecord( node ){
	var tr = node;
	while(tr.tagName != 'TR'){
		tr = tr.parentNode;
	}
	while(tr.split && tr.previousSibling ){ tr = tr.previousSibling; }
	if( tr.dataObj.validHash ){
		var Obj = Object.clone(tr.dataObj);
		var validHash = Obj.validHash;
		if( validHash.size() > 0 ){
			if(tr.style.backgroundColor == '#c2ffbc'){ tr.onclick(); }
			do{ tr.style.backgroundColor = '#eb98ab'; tr=tr.nextSibling; }while( tr && tr.split );
			return { dataObj:Obj , validHash:validHash };
		}
	}
	do{ tr.style.backgroundColor = ''; tr=tr.nextSibling; }while( tr && tr.split );
	return false;
}