/**
 * @class JavaScript公用套件
 * @author 黃亮勳
 * @version 20111101
 */
JsUtils = new function(){
	
	/** @ignore */
	this.setEventObserve = setEventObserve;
	/**  
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 設定物件Events
	 * @param {DOMElement} target 要設定Event的對象
	 * @param {String} eventName Event名稱，採用DOM2名稱。 EX:change
	 * @param {Function} func 執行動作
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function setEventObserve( elem , eventName , func){
		if( !(isDOMObject(elem) || elem==window || elem==document )  || !isString(eventName) || !isFunction(func) ){ return; }
		if(elem.removeEventListener) {						//DOM2接口 with bubble
			elem.addEventListener(eventName, func, false);  
		} else if(elem.detachEvent) {					//IE DOM2接口  with bubble
			elem.attachEvent('on'+eventName, func);  
		} else {											//DOM0接口 without bubble
			if( window.Prototype){
				Event.observe(elem, eventName, func);
			}else{
				elem['on'+eventName]=func; 
			}
		}
	}
	
	/** @ignore */
	this.stopEventObserving = stopEventObserving;
	/**   
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 移除物件Events
	 * @param {DOMElement} elem 要移除Event的對象
	 * @param {String} eventName 要移除Event名稱，採用DOM2名稱。 EX:change
	 * @param {Function} func 要移除的動作
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function stopEventObserving( elem , eventName , func  ){
		if( !(isDOMObject(elem) || elem==window || elem==document )  || !isString(eventName) ){ return; }
		if(elem.removeEventListener) {						//DOM2接口 with bubble
			elem.removeEventListener(eventName, func);  
		} else if(elem.detachEvent) {						//IE DOM2接口  with bubble
			elem.detachEvent('on'+eventName, func);
		} else {											//DOM0接口 without bubble
			if( window.Prototype){
				Event.stopObserving(elem, eventName);
			}else{
				elem['on'+eventName]=null; 
			}
		}
	}
	
	/** @ignore */
	this.getSpan = getSpan;
	/**   
	 * @function  
	 * @public  
	 * @ memberOf JsUtils
	 * @description 取得屬性設定值，若查無設定屬性，回傳1
	 * @param {Map} setting 要取得Attribute設定的對象
	 * @param {String} span Attribute名稱
	 * @returns {String} 取得屬性
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function getSpan( setting , span ){
		return setting.attrs ? ( setting.attrs[span] || 1 ) : 1;
	}
	
	/** @ignore */
	this.setSpan = setSpan;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 儲存屬性設定值
	 * @param {Map} setting 要放入Attribute設定的對象
	 * @param {String} span Attribute名稱
	 * @param {Integer} span_num Attribute數值
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function setSpan( setting , span , span_num){
		if( !setting.attrs ){ setting.attrs = {}; }
		setting.attrs[span] = span_num;
	}
	
	/** @ignore */
	this.getDOM = getDOM;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 以輸入值取得DOMElement
	 * @param {DOMElement} node 任一DOM物件，檢查後直接回傳
	 * @param {String} node DOM物件idc或name值，若有多個查詢，直接回傳第一個
	 * @returns {DOMElement} 欲取得物件，若取無資料，回傳false
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function getDOM( node ){
		if( isString(node) ){
			if(window.Prototype){ 
				return $(node);
			}else if( isDOMObject(node) ){
				return node;
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
	
	/** @ignore */
	this.cloneObject = cloneObject;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 複製一份輸入資料，除了一般型態外，也支援Object，Array，DOMElement
	 * @param {Object} orgObject 欲複製資料
	 * @returns {Object} 複製的資料
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function cloneObject(orgObject){
		var returnObject
		if(isArray(orgObject)){
			returnObject = [];
			for(var i = 0 ; i < orgObject.length ; i = i + 1 ){
				returnObject[i]=cloneObject(orgObject[i]);
			}
		}else if(isDOMObject(orgObject)){
			returnObject = orgObject.cloneNode(true);
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
	
	/** @ignore */
	this.isArray = isArray;		
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為Array
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isArray( node ){
		return !!(node && getType(node) === '[object Array]' && isNumeric( node.length ));
	}
	
	/** @ignore */
	this.isNotEmptyArray = isNotEmptyArray;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為非空Array
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isNotEmptyArray( node ){
		return !!(isArray(node) && node.length > 0);
	}
	
	/** @ignore */
	this.isFunction = isFunction;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為Function
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isFunction( node ){
		return !!(node && getType(node) === '[object Function]');
	}
	
	/** @ignore */
	this.isDOMObject = isDOMObject;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為DOM Element
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isDOMObject( node ){
		return !!( node && node.tagName && node.nodeType === 1); 
	}
	
	/** @ignore */
	this.isFragmentObject = isFragmentObject;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為Fragment Element
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isFragmentObject( node ){
		return !!( node && !node.tagName && node.nodeType === 11); 
	}
	
	/** @ignore */
	this.isObject = isObject;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為Map
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isObject(node){
		return !!(node && getType(node) == '[object Object]' && !isArray(node) && !isFunction(node) );
	}
	
	/** @ignore */
	this.isString = isString;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為String
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isString( node ){
		return !!(isBasicType( node ) && getType(node) === '[object String]');
	}
	
	/** @ignore */
	this.isNumeric = isNumeric;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為數值
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isNumeric(node){ return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); } 
	
	/** @ignore */
	this.isBasicType = isBasicType;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 檢查是否為數值，字串或布林值
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isBasicType( node ){
		var type = typeof(node);
		return !!( type === 'string' || type ==='number' || type === 'boolean' );
	} 
	
	/** @ignore */
	this.getType = getType;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 取得物件prototype屬性
	 * @param {Object} node 需檢查值
	 * @returns {Boolean} 檢查結果
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function getType(node){
		if(typeof(node) === 'undefined' ) {return "undefined"; }
		return Object.prototype.toString.apply(node);
	}	
	
	/** @ignore */
	this.setClass = setClass;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 增加DOM物件class屬性
	 * @param {DOMElement} node 欲增加class的物件
  	 * @param {String} className 欲增加className
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function setClass( node , className){
		if(!compareClass( node , className)){
			node.className = trim((node.className||"") +" "+ className);
		}
	}
	
	/** @ignore */
	this.getClass = getClass;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 取得DOM物件class屬性的陣列
	 * @param {DOMElement} node 欲取得classes的物件
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function getClass( node ){
		var classes = node.className;
		if(!isBasicType(classes)) { return []; }
		return stringToArray(classes ," ");
	}
	
	/** @ignore */
	this.compareClass = compareClass;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 比對DOM物件class屬性值是存在
	 * @param {DOMElement} node 欲比對classes的物件
	 * @param {String} compare 欲比對的className
	 * @author 黃亮勳
	 * @version 20111101
	 */
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
	
	/** @ignore */
	this.getOffsetTop = getOffsetTop;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 計算DOM物件於頁面的位置 (Top)
	 * @param {DOMElement} element 欲計算位置的DOM物件
	 * @author 陳丁群
	 * @version 20120105
	 */
	function getOffsetTop(element) {
		var valueT = 0;
		do {
			valueT += element.offsetTop || 0;
			element = element.offsetParent;
		} while (element);
		return valueT;
	}
	
	/** @ignore */
	this.getParentByTagName = getParentByTagName;
	/**    
	 * @function 
	 * @public  
	 * @ memberOf JsUtils
	 * @description 依照設定的TagName，取得上層第一個符合條件的DOM物件
	 * @param {DOMElement} node 欲尋找上層DOM的物件
	 * @param {String} TagName 欲比對的TagName
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getParentByTagName(node , TagName){
		if( !isDOMObject(node) || !isString(TagName) ){return false; }
		TagName = TagName.toUpperCase();
		while(node.tagName != TagName ){
			node = node.parentNode;
			if(!node.tagName|| node.TagName == "HTML" || !node.parentNode  ){return false; }
		}
		return node;
	}

	/** @ignore */
	this.createDOMElement = createDOMElement;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 依照設定建立DOM物件
	 * @param {DOMElement} node 欲尋找上層DOM的物件
	 * @param {String} TagName 欲比對的TagName
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function createDOMElement( elementTagName , elemantAttributes , elementActions, parentElement , insertPosition ){
		var element = document.createElement( elementTagName );
		if( JsUtils.isObject(elemantAttributes) ){
			for(var key in elemantAttributes ){
				if(isBasicType(elemantAttributes[key])){
					if( key == "className" ){		
						element.className = elemantAttributes[key];
					}else{				
						element.setAttribute( key , elemantAttributes[key]);
					}	
				}
			}
		}
		if( JsUtils.isObject(elementActions) ){
			for(var key in elementActions ){
				if(JsUtils.isFunction(elementActions[key])){
					setEventObserve( element, key ,function(event){elementActions[key]( event.srcElement, event )});
				}
			}
		}
		if(JsUtils.isDOMObject(parentElement) || JsUtils.isFragmentObject(parentElement)){
			if(JsUtils.isNumeric(insertPosition)){
				var totalChildNode = parentChild.childNodes;
				if( totalChildNode.length > insertPosition ){
					parentElement.insertBefore(element , totalChildNode[insertPosition] );
				}else{
					parentElement.appendChild(element);
				}
			}else{
				parentElement.appendChild(element);
			}
		}
		return element;
	}

	/** @ignore */
	this.removeAllChildren = removeAllChildren
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 移除傳入DOM物件下的所有子元素
	 * @param {DOMElement} node 欲移除子元素的DOM物件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function removeAllChildren( node ){
		node = getDOM(node);
		if(node){
			while( node.lastChild ){
				node.removeChild(node.lastChild);
			}
		}
	}
	
	/** @ignore */
	this.addOptions = addOptions;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 在Select DOM物件下依傳述參數增加OPTIONS
	 * @param {DOMElement} node 欲增加OPTIONS元素的SELECT DOM物件
	 * @param {Object/Array<Object>} optionValues 欲增加OPTIONS元素的傳入值
	 * @param {String} key 若optionValues為Array有效，用該值取得對應keyValue
	 * @param {String/Function}  valueKey 若optionValues為Array且valueKey為String有效，用該值取得對應Value，若設定Function則不論optionValues為何型態皆可使用傳入型態為(String/Object)
	 * @param {Boolean} [removeOldOptions=false] 是要在清除選項前，先刪除已存在的OPTIONS;
	 * @param {Boolean} [keepFirst] 是要在清除選項時，是否保留第一個選項物件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function addOptions( node , optionValues , key , valueKey , removeOldOptions, keepFirst ){
		
		if(removeOldOptions != null ? removeOldOptions : true ){ removeOptions( node , keepFirst ); }
		
		addSubSelection( node , optionValues , key , valueKey , "SELECT" , 
			function( node , nKey , nValue){
				var optionElem =  createDOMElement( "option" , {value:nKey} , null, node );
				optionElem.appendChild(document.createTextNode(nValue));															
			}
		);
	}
	
	/** @ignore */
	this.setOption = setOption;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 設定 Select DOM物件值
	 * @param {DOMElement} node 欲設定值的SELECT DOM物件
	 * @param {String} setValue 欲設定的值
	 * @param {Boolean} [selectFirstWhenNull=false] 若設定值找不到對應的選項，是否設定為第一個選項作預設值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function setOption( node , setValue , selectFirstWhenNull ){
		node = getDOM(node);
		if(node && node.tagName == "SELECT"){
			var testNode = node.firstChild;
			while( testNode.tagName!=="OPTION"){
				testNode = testNode.nextSibling;
			}
			testNode.selected = (selectFirstWhenNull && true);
			while(testNode){
				if( testNode.tagName==="OPTION"){
					var testValue = (testNode.getValue && testNode.getValue()) || testNode.getAttribute("value") || testNode.value; 
					if(testValue == setValue){
						testNode.selected = true;
						if(selectFirstWhenNull){ 
							break;
						}
					}else{
						testNode.selected = false;
					}
				}
				testNode = testNode.nextSibling;
			}
		}
	}
	
	/** @ignore */
	this.removeOptions = removeOptions;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 刪除Select DOM物件下所有OPTION物件
	 * @param {DOMElement} node 欲刪除OPTIONS的SELECT DOM物件
	 * @param {Boolean} [keepFirst=false] 刪除選項時，是否保留第一個選項
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function removeOptions( node , keepFirst ){
		node = getDOM(node);
		if(node && node.tagName == "SELECT"){
			while( keepFirst ? ( node.lastChild != node.firstChild ) :  node.lastChild ){
				node.removeChild(node.lastChild);
			}
		}
	}
	
	/** @ignore */
	this.getSelectName = getSelectName;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 取得Select DOM物件中被選取OPTION物件的畫面顯示值
	 * @param {DOMElement} node 欲取得值的SELECT DOM物件
	 * @param {Boolean} [selectedValue]可指定要取得哪一個對應value的值，若不輸入此項，則以該select物件被selected的物件值回傳
	 * @returns {String} OPTION物件的畫面顯示值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getSelectName( node , selectedValue ){
		node = getDOM(node);
		if(node && node.tagName == "SELECT"){
			var isFindSelected = !isBasicType(selectedValue);
			var isKeepBlankName = node.getAttribute("keepBlankName");
			var checkChild = node.firstChild;
			while( checkChild ){
				if(checkChild.tagName == "OPTION"){
					var value = checkChild.value;
					if(!isFindSelected){
						if( value == selectedValue ){
							if( value || isKeepBlankName ){
								return checkChild.textContent || checkChild.innerText;
							}else{
								return "";
							}
						}
					}else{
						if(checkChild.selected){
							if( value || isKeepBlankName){
								return checkChild.textContent || checkChild.innerText;
							}else{
								return "";
							}
						}
					}
				}
				checkChild = checkChild.nextSibling;
			}
		}
		return "";
	}
	
	/** @ignore */
	this.addChecks = addChecks;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 在DOM物件下依傳入參數增加一組checkBox或radio
	 * @param {String} checkType 要增加的checks類型，請填入checkBox或radio
	 * @param {DOMElement} node 欲增加一組checkBox或radio元素的DOM物件
	 * @param {Object/Array<Object>} items 欲增加checkBox或radio元素的傳入值
	 * @param {String} itemKey 若items為Array有效，用該值取得對應keyValue
	 * @param {String/Function}  itemValueKey 若items為Array且itemKey為String有效，用該值取得對應Value，若設定Function則不論optionValues為何型態皆可使用傳入型態為(String/Object)
	 * @param {Object} [attrs] 要在物件上加入的屬性值
	 * @param {Object} [events] 要在物件上加入的事件
	 * @param {Boolean} [removeOldOptions=false] 是要在建立選項前，先刪除已存在的checkBox或radio;
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function addChecks( checkType , node , items , itemKey , itemValueKey , attrs , events , removeOldOptions ){
		if(removeOldOptions != null ? removeOldOptions : true ){ removeAllChildren( node ); }
		
		addSubSelection( node , items , itemKey , itemValueKey , null , 
			function( node , nKey , nValue){
				var span = createDOMElement( "span" , null , null, node );
				attrs["inputValue"]=nKey;
				attrs["type"]=checkType;
				attrs["inputText"]=nValue;
				var optionElem =  createDOMElement( "input" , attrs , events, span );
				span.appendChild(document.createTextNode(nValue));
			}
		);
		if(attrs.name){
			var nodes = node.getElementsByTagName("input");
			//var markCount = 0;
			for( var i = 0 ; i < nodes.length ; i = i + 1 ){
				var testNode = nodes[i];
				if(testNode.getAttribute("type") === checkType ){
					testNode.setAttribute("name",attrs.name );
					//markCount = markCount + 1 ;
				}
			}
		}
	}
	
	/** @ignore */
	this.setCheck = setCheck;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 依照傳入值設定傳入的一組checkBox或radio物件值
	 * @param {String} checkType checks類型，請填入checkBox或radio
	 * @param {String} name checkBox或radio的name屬性值
	 * @param {DOMElement} node 欲設定值的checkBox或radio的parent DOM物件
	 * @param {Array} setValue 欲設定的值
	 * @param {Boolean} [clearOldChecked=false] 清除之前選取的選項
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function setCheck( checkType , name , node , setValue , clearOldChecked ){
		node = getDOM(node);
		if( clearOldChecked ){
			clearChecked( checkType , name , node );
		}
		if(!setValue) return;
		setValue = stringToArray(setValue,",");
		if(!isArray(setValue)){ return; } 
		if( setValue.length == 1){
			var testNodes = node.getElementsByTagName("INPUT");
			setValue = trim(setValue[0]);
			for(var i = 0 ; i < testNodes.length ; i = i + 1 ){
				//alert("--->"+setValue+","+checkType+","+name+"<----->"+testNodes[i].getAttribute("inputValue")+","+testNodes[i].getAttribute("type")+","+testNodes[i].getAttribute("name")+"<----");
				//alert("--->"+setValue+"<----->"+testNodes[i].getAttribute("inputValue")+"<----"+(testNodes[i].getAttribute("type") == checkType)+"&&"+(testNodes[i].getAttribute("name")== name)+"&&"+(testNodes[i].getAttribute("inputValue") == setValue ));
				if( testNodes[i].getAttribute("type") == checkType 
				 && testNodes[i].getAttribute("name")== name 
				 && testNodes[i].getAttribute("inputValue") == setValue 
				){
					testNodes[i].checked = true;
				}
			}
		}else{
			for(var i = 0 ; i < setValue.length ; i = i + 1){
				setCheck(  checkType , name , node , setValue[i] , false );
			}
		}
	}
	
	/** @ignore */
	this.getChecks = getChecks;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 取的一組checkBox或radio物件的選取值
	 * @param {String} checkType checks類型，請填入checkBox或radio
	 * @param {String} name checkBox或radio的name屬性值
	 * @param {DOMElement} node 欲設定值的checkBox或radio的parent DOM物件
	 * @returns {Array} 選取的值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getChecks ( checkType , name , node ){
		var rtnList = [];
		var testNodes = node.getElementsByTagName("INPUT");
		for(var i = 0 ; i < testNodes.length ; i = i + 1 ){
			if( testNodes[i].getAttribute("type") == checkType 
			 && testNodes[i].getAttribute("name") == name 
			 && testNodes[i].checked == true
			){
				rtnList[rtnList.length] = testNodes[i].getAttribute("inputValue");
			}
		}
		return rtnList;
	}
	
	/** @ignore */
	this.getChecksNameByValues = getChecksNameByValues;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 取得一組checkBox或radio物件的顯示值
	 * @param {String} checkType checks類型，請填入checkBox或radio
	 * @param {String} name checkBox或radio的name屬性值
	 * @param {DOMElement} node 欲取得值的checkBox或radio的parent DOM物件
	 * @param {Array} values checkBox或radio要取得顯示值的陣列
	 * @returns {Array} 輸入Array的顯示值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getChecksNameByValues( checkType , name , node , values){
		if(isBasicType(values)){
			values = stringToArray(values,',');
		}
		if(!isArray(values)){ return ""; }
		var checkValues = {};
		var hasKey = false;
		for(var i = 0 ; i < values.length ; i = i + 1 ){
			checkValues[values[i]] = true;
			hasKey = true;
		}
		if(!hasKey){ return "";}
		var rtnString = "";
		var testNodes = node.getElementsByTagName("INPUT");
		for(var i = 0 ; i < testNodes.length ; i = i + 1 ){
			var inputValue =  testNodes[i].getAttribute("inputValue");
			if( testNodes[i].getAttribute("type") == checkType 
			 && testNodes[i].getAttribute("name") == name 
			 && checkValues[inputValue]
			){
				var nameValue = testNodes[i].getAttribute("inputText");
				rtnString = rtnString + ( nameValue || inputValue ) + ", ";
			}
		}
		return rtnString.length > 2 ? rtnString.substr( 0 , rtnString.length-2) : rtnString;
	}
	
	/** @ignore */
	this.stringToArray = stringToArray;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 將以特殊符號分隔的字串輸出成陣列
	 * @param {String} stringValue 以特殊符號分隔的字串
	 * @param {String} splitChar 分隔的特殊符號
	 * @returns {Array} 輸出陣列
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function stringToArray( stringValue , splitChar ){
		if(isArray(stringValue)){ return stringValue; }
		if(!isBasicType(stringValue)){ return [ trim(stringValue) ];}
		var strings = stringValue.split(splitChar);
		var rtnArray = [];
		for(var i = 0 ; i < strings.length ; i = i + 1 ){
			var str = trim( strings[i] );
			rtnArray[rtnArray.length] = str;
		}
		return rtnArray;
	}
	
	/** @ignore */
	this.arrayToString = arrayToString;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 將陣列輸出成以逗號跟格的字串
	 * @param {Array} arrayValue 欲轉換的陣列
	 * @returns {String} 以逗號跟格的字串
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function arrayToString ( arrayValue ){
		if(!isArray(arrayValue)){ return "";}
		var rtnStr = "";
		for(var i = 0 ; i < arrayValue.length ; i = i + 1 ){
			var str = arrayValue[i];
			if(isBasicType(str)){
				rtnStr = rtnStr + str +", ";
			}
		}
		return rtnStr.length > 2 ? rtnStr.substr( 0 , rtnStr.length-2) : rtnStr;
	}
	
	
	/** @ignore */
	this.clearChecked = clearChecked;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 將一組checkBox或radio物件的選取值歸零
	 * @param {String} checkType checks類型，請填入checkBox或radio
	 * @param {String} name checkBox或radio的name屬性值
	 * @param {DOMElement} node 欲清除值的checkBox或radio的parent DOM物件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function clearChecked( checkType , name , node ){
		node = getDOM(node);
		var testNodes = node.getElementsByTagName("INPUT");
		for(var i = 0 ; i < testNodes.length ; i = i + 1 ){
			if(testNodes[i].getAttribute("type") == checkType && testNodes[i].getAttribute("name")== name ){
				testNodes[i].checked = false;
			}
		}
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf JsUtils
	 * @description 建立選項物件
	 * @param {DOMElement} node 欲增加元素的parent DOM物件
	 * @param {Object/Array<Object>} optionValues 欲增加OPTIONS元素的傳入值
	 * @param {String} key 若optionValues為Array有效，用該值取得對應keyValue
	 * @param {String/Function}  valueKey 若optionValues為Array且valueKey為String有效，用該值取得對應Value，若設定Function則不論optionValues為何型態皆可使用傳入型態為(String/Object)
	 * @param {String} chackTag 建立選項物件的tagName
	 * @param {function} addSelectionElemFunc 建立物件實體的function
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function addSubSelection( node , optionValues , key , valueKey , chackTag , addSelectionElemFunc ){
		if(!( (isArray(optionValues) && key && valueKey ) || (isObject(optionValues)) ) ){ return; }
		
		node = getDOM(node);
		if(node && ( !chackTag || node.tagName === chackTag.toUpperCase()) ){
			if( isArray(optionValues) ){
				for( var i = 0 ; i < optionValues.length ; i = i + 1 ){
					var optionMap =  optionValues[i];
					if( !isObject(optionMap) ){ continue; }
					var nKey = optionMap[key];
					var nValue;
					if( isFunction(valueKey) ){
						nValue = valueKey(optionMap , true);
					}else{
						nValue = optionMap [valueKey];
					}
					if( isBasicType(nKey) && isBasicType(nValue) ){
						addSelectionElemFunc( node , nKey , nValue );
					}
				}
			}else{
				for( var nKey in optionValues){
					var nValue = optionValues[nKey];
					if(isFunction(valueKey)){
						nValue = valueKey(nValue , false);
					}
					if( isBasicType(nKey) && isBasicType(nValue) ){
						addSelectionElemFunc( node , nKey , nValue );
					}
				}
			}
			if(node.firstChild){
				node.firstChild.selected = true;
			}
		}
	}
	
	/** @ignore */
	this.setDateInput = setDateInput;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 將日期資料放入input欄位
	 * @param {DOMElement} node date DOM物件
	 * @param {String} value 若有引用CSRUtils.js，將引用pattern屬性format資料放入
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function setDateInput( node , value ){
		node = getDOM(node);
		if(node.tagName != "INPUT" || node.getAttribute("type") !== "text" ){ return; }
		node.setValue ? node.setValue("") : node.setAttribute("value","");
		var type = (node.getAttribute("datatype") || "").toLowerCase();
		if( !type == "date" && !type == "rocdate"){ return;} 
		var pattern = node.getAttribute("pattern");
		if(!pattern){
			var dateSplit = node.getAttribute("dateSplit");
			if(isString(dateSplite)){
				if(type == "date"){
					pattern = "yyyy"+dateSplite+"MM"+dateSplite+"dd";
				}else{
					pattern = "yyy"+dateSplite+"MM"+dateSplite+"dd";
				}
			}else{
				if(type == "date"){
					pattern = "yyyy/MM/dd";
				}else{
					pattern = "yyyMMdd";
				}
			}
			node.setAttribute("pattern" , pattern );
		}
		
		if(window.isDate){
			var beforeROC20 = node.getAttribute("beforeROC20") || false;
			var beforeROC = node.getAttribute("beforeROC") ;
			var boolIsDate = isADdate(value , beforeROC20 );
			var boolIsROCdate = isROCdate(value , beforeROC20 , beforeROC );
			if(!boolIsDate && !boolIsROCdate ){ return; }
			if(type == "date"){
				if(boolIsROCdate){
					value = toY2K(value);
				}
				if(pattern){
					var df = getSimpleDateFormat( pattern , false );
					valeu = df.format(value);
				}
			}else{
				if(pattern){
					if(boolIsROCdate){
						value = toY2K(value);
					}
					var df = getSimpleDateFormat( pattern , true );
					value = df.format(value);
				}else{
					if(boolIsDate){
						value = toROC(value);
					}
				}
			}
		}
		node.setValue ? node.setValue(value) : node.setAttribute("value",value);
	}
	
	/** @ignore */
	this.getDateInput = getDateInput;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 將日期資料自input欄位取出，若有引用CSRUtils，會將值format成標準格式
	 * @param {DOMElement} node date DOM物件
	 * @param {Boolean} [isFormatToY2K=true] 是否強制將資料format成西元日期
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getDateInput( node , isFormatToY2K ){
		node = getDOM(node);
		if(node.tagName != "INPUT" || node.getAttribute("type") !== "text" ){ return ""; }
		var datatype =  (node.getAttribute("datatype") || "").toLowerCase();				
		if( !datatype == "date" && !datatype == "rocdate"){ return "";} 
		var value = ( node.getValue && node.getValue() ) || node.getAttribute("value") || node.value;
		if(window.isDate){
			var datePattern = node.getAttribute("pattern");
			if( datatype === "rocdate" ){
				var beforeROC20 = node.getAttribute("beforeROC20") || false;
				var beforeROC = node.getAttribute("beforeROC") ;
				if(!isROCdate(value , beforeROC20 , beforeROC ) ){ return ""; }
				if(isFormatToY2K !== false){
					value = toY2K(value);
				}else if(datePattern){
					value = toY2K(value);
					var df = getSimpleDateFormat( datePattern , true );
					value = df.format(value);
				}
			}else if( datatype === "date"){
				if(!isDate(value)){ 
					return ""; 
				}else if(datePattern){
					var df = getSimpleDateFormat( datePattern , false );
					value = df.format(value);
				}
			}
		}
		return value;
	}
	
	/** @ignore */
	var patternSaves = {};
	/** @ignore */
	this.getSimpleDateFormat = getSimpleDateFormat;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 取得/建立date format的物件
	 * @param {String} pattern date format pattern
	 * @param {Boolean} [isROCtype=false] 是否為民國年的format格式
	 * @returns {Object} DateFormat物件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getSimpleDateFormat( pattern , isROCtype ){
		if(!isString(pattern)){ return false; }
		var key = (isROCtype?"TW_":"US_")+pattern;
		if(patternSaves[key]){ return patternSaves[key]; }
		if(window.SimpleDateFormat){
			var df = new SimpleDateFormat( pattern , isROCtype?SimpleDateFormat.TW:SimpleDateFormat.US );
			patternSaves[key] = df;
			return df;
		}
		return false;
	}
	
	/** @ignore */
	this.trim = trim;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 去除前後空白
	 * @param {String} value 欲修正值
	 * @returns {String} 修正值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function trim(value)
	{
	    //return value.replace(/(^[\\s]*)|([\\s]*$)/g, "");
	    return isString(value) ? value.replace(/(^\s*)|(\s*$)/g, "") : value; 
	}
	/** @ignore */
	this.lTrim = lTrim;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 去除前空白
	 * @param {String} value 欲修正值
	 * @returns {String} 修正值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function lTrim(value)
	{
	    return isString(value) ? value.replace(/(^\s*)/g, "") : value;
	}
	
	/** @ignore */
	this.rTrim = rTrim;
	/**    
	 * @function 
	 * @public  
	 * @memberOf JsUtils
	 * @description 去除後空白
	 * @param {String} value 欲修正值
	 * @returns {String} 修正值
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function rTrim(value)
	{
	    return isString(value) ? value.replace(/(\s*$)/g, "") : value;
	} 


}

/**
 * @class UI控制公用套件
 * @author 黃亮勳
 * @version 20111101
 */
UI_Manager = new function(){

	var UIConfigs={};
	var config_count = 0;
	
	/** @ignore */
	this.addUIConfig = addUIConfig;
	/**    
	 * @function 
	 * @public  
	 * @memberOf UI_Manager
	 * @description 增加UI註冊
	 * @param {String} UI_Name UI註冊名稱
	 * @param {Object} UI Object
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function addUIConfig( UI_Name , UI ){
		if(!JsUtils.isObject(UI)){ return; } 
		if(!JsUtils.isString(UI_Name)){
			UI_Name = "autoUIid"+config_count;
		}
		UIConfigs[UI_Name] = UI;
		config_count = config_count + 1;
	}
	
	/** @ignore */
	this.getUI = getUI;
	/**    
	 * @function 
	 * @public  
	 * @memberOf UI_Manager
	 * @description 依UI註冊名稱取得已註冊UI
	 * @param {String} UI_Name UI註冊名稱
	 * @return {Object} UI Object
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getUI( UI_Name ){
		return UIConfigs[UI_Name];
	}
	
	/**    
	 * @field
	 * @private  
	 * @memberOf UI_Manager
	 * @description 共用函式設定，格式為{ DOM2 Event : UI function Name }
	 */
	eventMappingList = { "resize":"resize" };
	/**    
	 * @field
	 * @private  
	 * @memberOf UI_Manager
	 * @description 其他外部需手動加入的functions
	 */
	outerEventAdding = {};
	// "resize":[ window.fix ] };
	
	/** @ignore */
	this.callShareingObserve = callShareingObserve;
	/**    
	 * @function 
	 * @public  
	 * @memberOf UI_Manager
	 * @description 透過eventMappingList取得呼叫共用函式，執行所有已註冊UI內之event function 
	 * @param {String} DOM2Event 要執行所有已註冊UI內之event Name
	 * @return {Object} UI Object
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function callShareingObserve( DOM2Event ){
		//alert("exec "+DOM2Event);
		if(JsUtils.isArray(outerEventAdding[DOM2Event])){
			for(var i = 0 ; i <outerEventAdding[DOM2Event].length ; i = i + 1 ){
				if(JsUtils.isFunction(outerEventAdding[DOM2Event][i])){
					outerEventAdding[DOM2Event][i]();
				}
			}
		}
		var execFunctionName = eventMappingList[DOM2Event];
		if( JsUtils.isString(execFunctionName)){
			for(var key in UIConfigs){
				var execfunction = UIConfigs[key][execFunctionName];
				if(JsUtils.isFunction(execfunction)){
					execfunction();
				}
			}
		}
	}
	
	/**    
	 * @field
	 * @private  
	 * @memberOf UI_Manager
	 * @description 共用函式設定，格式為 [DOM2 Event]
	 */
	var documentEventList = ["resize"];
	var saveFunctions = {};
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf UI_Manager
	 * @description 將動作附加至window事件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	//將動作附加至window事件
	function setEventObserve(){
		if( JsUtils.isArray(documentEventList)){
			for(var i = 0 ; i < documentEventList.length ; i = i + 1 ){
				var eventName = documentEventList[i];
				//alert("set: " + eventName);
				saveFunctions[eventName] = function(){ callShareingObserve(eventName); }
				JsUtils.setEventObserve( window , eventName , saveFunctions[eventName] );
			}
		}
	}
	
	/** @ignore */
	this.stopEventObserving = stopEventObserving;
	/**    
	 * @function 
	 * @public  
	 * @memberOf UI_Manager
	 * @description 停止設定的Event
	 * @param {String} action 要停止之event Name
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function stopEventObserving( action ){
		if( JsUtils.isArray(documentEventList)){
			for(var i = 0 ; i < documentEventList.length ; i = i + 1 ){
				var eventName = documentEventList[i];
				if( action === eventName  ){
					JsUtils.stopEventObserving( window , eventName , saveFunctions[eventName] );
				}
			}
		}
	}
	
	/**    
	 * @field
	 * @private  
	 * @memberOf UI_Manager
	 */
	var loadStop = false;
	/**    
	 * @function 
	 * @private  
	 * @memberOf UI_Manager
	 * @description UI_Manager初始function
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function initLoad(){
		if(loadStop){ JsUtils.stopEventObserving( window , 'load' , initLoad ); return ;}
		loadStop = true;
		if(JsUtils.isFunction(window.init)){
			window.init();
		}
		setEventObserve();
	}
	JsUtils.setEventObserve( window , 'load' , initLoad );
}


/**
 * @class 產生頁面的UI控制公用套件
 * @author 黃亮勳
 * @version 20111101
 */
PageUI = new function(){
	
	var table;
	var contentDiv;
	var imgBase = "/";
	var isOverDivWorking = false;
	var subTitle;
	
	UI_Manager.addUIConfig( "PageUI" , this );

	//---------------------------------------------
	//	產生基本頁面元素函式
	//---------------------------------------------
	/** @ignore */
	this.createPage = createPage;
	/**    
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 產生頁面基本外框
	 * @param {String} pageNO 頁面編號
	 * @param {String} title 頁面主標題
	 * @param {String} subTitleText 頁面副標題
	 * @param {Boolean} [noPageFrame=false] 是否不要產生外框
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function createPage( pageNO , title , subTitleText , noPageFrame ){
		var forms = document.getElementsByTagName('form');
		for( var i =0 ; i < forms.length ; i++ ){
			forms[i].style.margin = '0px';
		}
		
		//處理頁面title
		document.title = title + " - " + subTitleText+" ("+pageNO+")";
		
		var frag  = document.createDocumentFragment();
		//處理頁面主區塊，包含邊框及主分類欄位
		table     = JsUtils.createDOMElement( "table" , { "className":"PageUI" , "cellPadding":0 , "cellSpacing":0 } , null , frag );
		
		var content;
		
		if(noPageFrame!== true){
			
			var thead = JsUtils.createDOMElement( "thead" , null, null  , table );
			var tbody = JsUtils.createDOMElement( "tbody" , null, null  , table );
			
			var tmpTitleTr       = JsUtils.createDOMElement( "TR" , null, null , thead );
			var tmpTitleTh      = JsUtils.createDOMElement( "th" , {colSpan:"3","vAlign":"top" , height:"5px"} , null , tmpTitleTr );
			var fixTable = JsUtils.createDOMElement( "table" , {"className":"titleBar" , width:"100%" , bgColor:"#F0FBC6", "cellPadding":0 , "cellSpacing":0}, null  , tmpTitleTh );
			var tmpthead = JsUtils.createDOMElement( "thead" , null, null  , fixTable );
		
			var titleTr1       = JsUtils.createDOMElement( "TR" , null, null , tmpthead );
			
			var borderTopLeft  = JsUtils.createDOMElement( "th" , {"className":"borderTopLeft", rowSpan:"2"} , null , titleTr1 );
			var borderTop      = JsUtils.createDOMElement( "th" , {"className":"borderTop", colSpan:"2"} , null , titleTr1 );
			var borderTopRight = JsUtils.createDOMElement( "th" , {"className":"borderTopRight", rowSpan:"2"} , null , titleTr1 );
			
			var titleTr2 = JsUtils.createDOMElement( "TR" , null, null , tmpthead );
			var titleTd  = JsUtils.createDOMElement( "th" , {"className":"borderText", align:"left"} , null , titleTr2 );
			var pageNoTd = JsUtils.createDOMElement( "th" , {"className":"borderText", align:"right" , 'id':'pageNo'} , null , titleTr2 );
			//畫面主分類文字
			titleTd.appendChild(document.createTextNode("\u25CF"+title));
			//畫面編號文字
			if(JsUtils.isString(pageNO) && pageNO != ""){
				pageNoTd.appendChild(document.createTextNode("畫面編號："+pageNO));
			}
			//將放置內容的區塊
			var contentTr    = JsUtils.createDOMElement( "TR" , null, null , tbody );
			var contentLeft  = JsUtils.createDOMElement( "td" , {"className":"borderTopLeft" , width:"4px"} , null , contentTr );
			content      = JsUtils.createDOMElement( "td" , {colSpan:"1" ,"className":"subTable", width:'99%' }, null , contentTr );
			var contentRight = JsUtils.createDOMElement( "td" , {"className":"borderTopRight" , width:"4px"} , null , contentTr );
		}else{
			var tbody = JsUtils.createDOMElement( "tbody" , null, null  , table );
			var contentTr    = JsUtils.createDOMElement( "TR" , null, null , tbody );
			content      = JsUtils.createDOMElement( "td" , {vAlign:"top"}, null , contentTr );
		}
		
		//內容區塊
		var cDiv         = JsUtils.createDOMElement( "div" , null , null , content );
		var cTable       = JsUtils.createDOMElement( "table" , { "className":"contents" , "cellPadding":0 , "cellSpacing":0 } , null , cDiv );
		var cTitleHeader = JsUtils.createDOMElement( "thead" , null , null , cTable );
		var cTitleTr     = JsUtils.createDOMElement( "tr" , null , null , cTitleHeader );
		var cTitleTh     = JsUtils.createDOMElement( "th" , { "className":"contentsTh" } , null , cTitleTr );
		//畫面子分類文字
		//var pointImg = JsUtils.createDOMElement( "img",{src:imgBase+"icon_dot11.gif",width:"18",height:"16"},null,cTitleTh );
		var pointFont = JsUtils.createDOMElement( "font",{color:"#5A99B9", size:"3px" },null,cTitleTh );
		pointFont.style.marginLeft = "3px";
		pointFont.style.marginRight = "3px";
		pointFont.style.cursor = "help";
		pointFont.appendChild(document.createTextNode("\u2756"));

		var browser_info = getBrowser();
		if (browser_info.isIE) {
		    pointFont.title = 'Microsoft Internet Explorer ' + browser_info.verIE + '(Mode:' + browser_info.docModeIE + ')';
		} else {
		    pointFont.title = browser_info.desp;
		}
		
		subTitle =  JsUtils.createDOMElement( "span" );
		subTitle.innerHTML = subTitleText;
		cTitleTh.appendChild(subTitle);
		
		var cTitleBody   = JsUtils.createDOMElement( "tbody" , null , null , cTable );
		cTitleTr         = JsUtils.createDOMElement( "tr" , null , null , cTitleBody );
		cTitleTh         = JsUtils.createDOMElement( "td" , { "className":"contentsTd" } , null , cTitleTr );
		contentDiv       = JsUtils.createDOMElement( "div" , null , null , cTitleTh );
		
		//強制將本頁面table強制放置在第一個元素位置
		if(document.body.childNodes.length > 0 ){
			document.body.insertBefore( frag , document.body.firstChild );
		}else{
			document.body.appendChild(frag);
		}
		
		var divBar1 = JsUtils.createDOMElement( "div" , {id:"bar1"} , null , cTable );
		
		//將畫面重新處理底色，若不夠長至覆蓋全頁面，將頁面變長。
		tableResize( true );
	}
	
	/** @ignore */
	this.createPageWithAllBodySubElement = createPageWithAllBodySubElement;
	/**    
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 產生頁面基本外框並將所有Body下的DOM物件納入顯示區塊
	 * @param {String} pageNO 頁面編號
	 * @param {String} title 頁面主標題
	 * @param {String} subTitleText 頁面副標題
	 * @param {Number} [fixedNum=0]  固定的欄位數目，0代表不將任何區塊放入sub frame
	 * @param {Boolean} [noPageFrame=false] 是否不要產生外框
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function createPageWithAllBodySubElement( pageNO , title , subTitleText , fixedNum , noPageFrame ){
		var loadinArray = [];
		var bodyChildren = document.body.childNodes;
		for(var i = 0 ; i < bodyChildren.length ; i = i + 1 ){
			var node = bodyChildren[i];
			if( 
				//若不是DOM物件，不做匯入
				JsUtils.isDOMObject(node) 
				//若是script物件，不做匯入
				&& node.tagName != 'SCRIPT' && node.localName != 'script' 
				//若是style css 物件，不做匯入
				&& node.tagName != 'STYLE' && node.localName != 'style' 
				&& node.tagName != 'LINK' && node.localName != 'link' 
				//若有隱藏屬性，不做匯入
				&& node.style.display != 'none' && node.style.visibility != 'hidden' 
				//若是特殊物件，強制匯入，否則沒有內容不匯入
				&& ( 
					//要有內容
					node.innerHTML 
					//tableui
					|| (node.className||'').indexOf('grid') >= 0 || (node.id||'').indexOf('grid') >= 0
					//tabs
					|| (node.className||'').indexOf('tabs') >= 0 || (node.id||'').indexOf('tabs') >= 0
				)
			){
				loadinArray[loadinArray.length] = node;
			}
		}
		var fragment = document.createDocumentFragment();
		for(var i = 0 ; i < loadinArray.length ; i = i + 1 ){
			fragment.appendChild(loadinArray[i]);
		}
		createPage( pageNO , title , subTitleText, noPageFrame );
		loadin(loadinArray,fixedNum);
		resize(true);
	}
	
	/** @ignore */
	this.loadin = loadin;
	/**    
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 將指定的DOM物件納入顯示區塊
	 * @param {Array} loadinConfigs 指定的DOM多個物件
	 * @param {String/DOMElement} loadinConfigs.arrayValue 指定的DOM物件之id值
	 * @param {Object} loadinConfigs.arrayObject 指定的DOM物件之設定值
	 * @param {String/DOMElement} loadinConfigs.arrayObject.elem 指定的DOM物件之id值
	 * @param {String/DOMElement} loadinConfigs.arrayObject.title 區塊標題文字或引入的DOM物件
	 * @param {Number} [fixedNum=0] 固定的欄位數目，0代表不將任何區塊放入sub frame
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function loadin( loadinConfigs , fixedNum ){
		//處理不同類型輸入，將其都轉換成array格式
		if(JsUtils.isObject(loadinConfigs) || JsUtils.isString(loadinConfigs) ||  JsUtils.isDOMObject(loadinConfigs) ){
			loadinConfigs = [ loadinConfigs ];
		}else if( !JsUtils.isArray(loadinConfigs) ){
			alert("Error Configs in Function loadin(PageUI)");
			return;
		}
		
		var	fragment = getContentDivFragment(false);
		
		var parentNodeList = [];
		
		//開始處理設定
		for( var i = 0 ; i < loadinConfigs.length ;  i = i + 1 ){
			//設定值
			config = loadinConfigs[i];
			
			//處理不同類型輸
			if(JsUtils.isString(config)){
				config = { elem:config };
			}else if(JsUtils.isDOMObject(config)){
				config = { elem:config };
			}else if(!JsUtils.isObject(config) || !config.elem  ){
				continue;
			}
			//取得要附加的元素
			var contentObject = JsUtils.getDOM(config.elem);
			
			if(!contentObject){ 
				continue; 
			}
			
			parentNodeList.push( contentObject.parentNode );
			
			var contentSubDiv = JsUtils.createDOMElement( "div" , {"className":"contentDiv",contentId:config.id} , null , fragment , config.position );
			
			var contentTable  = JsUtils.createDOMElement( "table" , {"className":"contentDivTable","cellPadding":0 , "cellSpacing":0} , null , contentSubDiv );
			
			var title = config.title || contentObject.getAttribute("blockTitle");
			
			if(JsUtils.isBasicType(title)){
				var thead   = JsUtils.createDOMElement( "thead" , null , null , contentTable );
				var titleTr = JsUtils.createDOMElement( "tr" , null , null , thead );
				var titleTh = JsUtils.createDOMElement( "th" , {"className":"contentDivTh" } , null , titleTr  );
				if(JsUtils.isDOMObject(title)){
					titleTh.appendChild(title );
				}else{
					titleTh.appendChild(document.createTextNode(title));
				}
			}
			var tbody     = JsUtils.createDOMElement( "tbody" , null , null , contentTable );
			var contentTr = JsUtils.createDOMElement( "tr" , null , null , tbody );
			var contentTd = JsUtils.createDOMElement( "td" , {"className":"contentDivTd" } , null , contentTr  );
			contentTd.appendChild(contentObject);
		}
		
		fragment = fixedContent( fixedNum , fragment , parentNodeList );

		if( fragment ){
			contentDiv.appendChild(fragment);		
			resize( true );
		}
	}
	
	/** @ignore */
	this.fixedContent = fixedContent;
	/**    
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 重新設定固定區塊數目
	 * @param {Number} [fixedNum=0] 固定的欄位數目，0代表不將任何區塊放入sub frame
  	 * @param {FragmentElement} [inputFragment] 
	 * @param {DOMElement} parentNodeList 每個區塊的parent DOM物件
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function fixedContent( fixedNum , inputFragment , parentNodeList ){
		
		if(!JsUtils.isNumeric(fixedNum)){ return inputFragment; }
		
		var hasInputFragment = JsUtils.isFragmentObject(inputFragment);
		
		var fragment = hasInputFragment ? inputFragment : getContentDivFragment(false);
		
		if(fixedNum === 0 || fixedNum >= contentDiv.length-1 ){ 
			if(hasInputFragment){
				return fragment;
			}else{
				contentDiv.appendChild(fragment); 
				resize( true );
				return; 
			}
		}
		
		isOverDivWorking = true;
		
		var mainFragment = document.createDocumentFragment();
		
		var div = JsUtils.createDOMElement( "div" , {"className":"overDiv" , id:"PageUiOverDiv"} );	
		var childLength = fragment.childNodes.length;	
		
		if( parentNodeList && ((parentNodeList.length -1) >= fixedNum ) ){
			var parent = parentNodeList[fixedNum];		//取得SubFrame的parent
			var subFragment = document.createDocumentFragment();
			for(var i = 0 ; i < childLength ; i = i + 1 ){
				if(i < fixedNum ){
					if( parent == parentNodeList[i] ){
						subFragment.appendChild(fragment.firstChild);		
					}else{
						mainFragment.appendChild( fragment.firstChild );	//獨立的區塊
					}
				}else{
					div.appendChild(fragment.firstChild);
				}
			}
			subFragment.appendChild(div);
			
			if( parent.tagName != "BODY" ){		//如果parent不是body的話 (如form,就直接塞在parent下面)
				parent.appendChild( subFragment );
				mainFragment.appendChild( parent );
			}else{
				mainFragment.appendChild( subFragment );
			}
		}else{
			for(var i = 0 ; i < childLength ; i = i + 1 ){
				if(i < fixedNum ){
					mainFragment.appendChild(fragment.firstChild);		
				}else{
					if( i === fixedNum ){
						mainFragment.appendChild(div);
					}
					div.appendChild(fragment.firstChild);
				}
			}
		}
		
		if(hasInputFragment){
			return mainFragment;
		}else{
			contentDiv.appendChild(mainFragment); 
			resize( true );
			return; 
		}
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf PageUI
	 * @description 取得所有區塊，並將其放至一這fragment
	 * @param {Boolean} [checkNotFixed=false] 
  	 * @returns {FragmentElement} [inputFragment] 
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getContentDivFragment( checkNotFixed ){
		
		isOverDivWorking = false;
		
		var divs = document.getElementsByTagName("DIV");
		if(checkNotFixed ){
			var notFixed = true;
			for( var i = 0 ; i < divs.length ; i = i + 1 ){
				if(divs[i].getAttribute("contentId") && div[i].parentNode != contentDiv ){
					notFixed = false;
					break;
				}
			}
			if(notFixed){ return false; }
		}
		var fragment = document.createDocumentFragment();
		for( var i = 0 ; i < divs.length ; i = i + 1 ){
			if(divs[i].getAttribute("contentId")){
				fragment.appendChild(divs[i]);
			}
		}
		while(contentDiv.lastChild){
			contentDiv.removeChild(contentDiv.lastChild);
		}
		return fragment;
	}
	
	/** @ignore */
	this.resize = resize;
	/**    
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 重新設定Page大小
	 * @param {Boolean} [uncheckDocumentResize=false] 是否忽略視窗改變大小檢查，強制進行resize
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function resize( uncheckDocumentResize ){
		overDivResize( uncheckDocumentResize );
		tableResize( uncheckDocumentResize );
		if( !uncheckDocumentResize ){
			var documentHeight = getDocumentHeight();
			document.body.setAttribute("documentHeight" , documentHeight );
		}	
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf PageUI
	 * @description 重新設定sub frame大小
	 * @param {Boolean} [uncheckDocumentResize=false] 是否忽略視窗改變大小檢查，強制進行resize
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function overDivResize( uncheckDocumentResize ){
		if( !isOverDivWorking ){ return; }
		var overDiv = JsUtils.getDOM("PageUiOverDiv");
		if( !overDiv || !JsUtils.isDOMObject(overDiv) ){ return; }
		var documentHeight = uncheckDocumentResize ? getDocumentHeight() : checkDocumentResize( 10 );
		if( !documentHeight ){ return; }
		var top = overDiv.scrollTop;
		
		//var bottomSpace = 70;//documentHeight*0.08;

		var overDivOffsetTop  = JsUtils.getOffsetTop(overDiv);
		//var overDivOffsetTop  = overDiv.offsetTop + (document.body.offsetTop || document.body.clientTop);
		
		if(overDivOffsetTop == 0){
			overDivOffsetTop = overDiv.getAttribute("offsetTopValue") || 0 ;
		}else{
			overDiv.setAttribute("offsetTopValue",overDivOffsetTop);
		}
		
		var overDivClientHeight = overDiv.scrollHeight || overDiv.clientHeight || overDiv.offsetHeight;		
		//alert(overDivClientHeight+"> ("+  documentHeight +"-"+ overDivOffsetTop +")"+( documentHeight - overDivOffsetTop ))
		
		overDiv.style.height = null;
		
		if(overDivClientHeight > ( documentHeight - overDivOffsetTop - 20) ){	// 20誤差值
			var overDivHeight = documentHeight - overDivOffsetTop-10;
			//var overDivHeight = (documentHeight - overDivOffsetTop)*0.98; //- bottomSpace;
			
			if( overDivHeight < (documentHeight / 2) ){
				overDivHeight = documentHeight*0.95 ;
			}
			if( !overDivHeight || overDivHeight > overDivClientHeight || overDivClientHeight < 300){
				return; 
			}
			
			overDiv.style.height = (overDivHeight)+'px';
		}
		if(top){overDiv.scrollTop = top; }
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf PageUI
	 * @description 重新設定主要Page大小
	 * @param {Boolean} [uncheckDocumentResize=false] 是否忽略視窗改變大小檢查，強制進行resize
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function tableResize( uncheckDocumentResize ){
		if(!table){return; }
		var documentHeight = uncheckDocumentResize ? getDocumentHeight() : checkDocumentResize();
		if( !documentHeight ){ return; }
		table.style.height = null;
		var tableHeight = table.offsetHeight;
		if( tableHeight < documentHeight ){
			table.style.height = documentHeight+'px';
		}
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf PageUI
	 * @description 取得現在的視窗可見高度
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function getDocumentHeight(){
		var documentHeight;
		try{
			if(window.parent){
				var iframes = window.parent.document.getElementsByTagName("iframe");
				for( var i = 0 ; i < iframes.length ; i = i + 1 ){
					if(iframes[i].getAttribute("name") == "mainFrame" ){
						documentHeight = iframes[i].offsetHeight;
					}
				}
			}
		}catch(err){
			documentHeight = null;
		}
		if(!documentHeight){
			documentHeight = window.innerHeight ? window.innerHeight-4 : window.innerHeight || document.documentElement.offsetHeight || document.body.clientHeight || 0;
		}
		return documentHeight;
	}
	
	/**    
	 * @function 
	 * @private  
	 * @memberOf PageUI
	 * @description 檢查視窗大小是否改變
	 * @param {Number} [ignoreRange=0] 誤差值在ignoreRange內的數值，皆會被認為未改變大小。
	 * @author 黃亮勳
	 * @version 20111101
	 */
	function checkDocumentResize( ignoreRange ){
		var documentHeight = getDocumentHeight();
		var preChangedDcoumentHeight = document.body.getAttribute("documentHeight");
		//alert("checkDocumentResize:" +documentHeight+"///"+preChangedDcoumentHeight+"="+(documentHeight-preChangedDcoumentHeight));
		return ( preChangedDcoumentHeight && Math.abs(documentHeight-preChangedDcoumentHeight) < Math.abs( ignoreRange || 0) ) ? false : documentHeight;
	}

    //--------------------------------------------
    //  測試瀏覽器
    //--------------------------------------------
	function getBrowser() {
	    var browser = {   // browser object
	        browser: '',
	        desp: null,
	        verIE: null,
	        docModeIE: null, //IE browser document mode
	        verIEtrue: null, //True IE browser version (independent of userAgent, document mode, or browser mode):
	        verIE_ua: null //IE browser version (derived from navigator.userAgent)
	    };

	    var userAgentStrings = navigator.userAgent;
	    var tmp = document.documentMode;
	    try { document.documentMode = ""; }
	    catch (e) { };

	    browser.isIE = typeof document.documentMode == "number" || eval("/*@cc_on!@*/!1");

	    try { document.documentMode = tmp; }
	    catch (e) { };

	    if (browser.isIE) {
	        // IE version from user agent
	        //
	        // For IE < 11, we look for "MSIE 10.0", etc...
	        // For IE 11+, we look for "rv:11.0", etc...
	        browser.verIE_ua = (/^(?:.*?[^a-zA-Z])??(?:MSIE|rv\s*\:)\s*(\d+\.?\d*)/i).test(userAgentStrings || "") ? parseFloat(RegExp.$1, 10) : null;

	        // Get true IE version using clientCaps.
	        var e, verTrueFloat, x, obj = document.createElement("div");
	        // Array of classids that can give us the IE version
	        var CLASSID = [
                 "{45EA75A0-A269-11D1-B5BF-0000F8051515}", // Internet Explorer Help
                 "{3AF36230-A269-11D1-B5BF-0000F8051515}", // Offline Browsing Pack
                 "{89820200-ECBD-11CF-8B85-00AA005B4383}"
	        ];
	        try { obj.style.behavior = "url(#default#clientcaps)" } catch (e) { };

	        for (x = 0; x < CLASSID.length; x++) {
	            try { browser.verIEtrue = obj.getComponentVersion(CLASSID[x], "componentid").replace(/,/g, "."); } catch (e) { };
	            if (browser.verIEtrue) break;
	        };
	        verTrueFloat = parseFloat(browser.verIEtrue || "0", 10);
	        browser.docModeIE = document.documentMode || ((/back/i).test(document.compatMode || "") ? 5 : verTrueFloat) || browser.verIE_ua;
	        browser.verIE = verTrueFloat || browser.docModeIE;
	    } else {
	        if (userAgentStrings.search('Firefox') >= 0) {
	            browser.browser = 'Firefox';
	            browser.desp = 'mozilla Firefox';
	        } else if (userAgentStrings.search('Opera') >= 0 || userAgentStrings.search('OPR') >= 0) {
	            browser.browser = 'Opera';
	            browser.desp = 'Opera';
	        } else if (userAgentStrings.search('Chrome') >= 0) {
	            browser.browser = 'Chrome';
	            browser.desp = 'Google Chrome';
	        } else if (userAgentStrings.search('Safari') >= 0) {
	            browser.browser = 'Safari';
	            browser.desp = 'Apple Safari';
	        } else if (userAgentStrings.search('Mozilla') >= 0) {
	            browser.browser = 'Mozilla';
	            browser.desp = 'Mozilla';
	        }
	    }
	    return browser;
	}
	
	//---------------------------------------------
	//	產生輸入/顯示table
	//---------------------------------------------
	
	var saveDomMap = {};
	var saveRecordMap = {};
	var contentCount = 0;
	//todo: contentCss 
	this.createContent = createContent
	function createContent(config , loadinValues , showType ){
		//檢核資料
		var functionName = "  (PageUI.createContent)";
		if(!JsUtils.isObject(config) || !JsUtils.isArray(config.contents)){ 
			alert("輸入資料錯誤，請確認輸入資料"+functionName);
			return;
		}
		var actionElem = JsUtils.getDOM(config.elem);
		
		if(!actionElem){
			alert("無法取得$(config.elem)"+functionName);
			return;
		}
		
		
		//若設定要清除所有子元素，進行清除
		if(config.clearChildElements){
			JsUtils.removeAllChildren(actionElem);
		}
		//處理是否要產生 header Content 欄位
		var noHeader = !!config.noHeader;
		var noContent = !!config.noContent;
		var headerInTop = !!config.headerInTop;
		
		if(  noHeader && noContent ){ return; }
		var doubleColSpan = !headerInTop && !noHeader && !noContent;
		var doubleRowSpan = headerInTop && ( !noHeader || !noContent );
		
		var colsInTable = config.dataColumns;
		if(!JsUtils.isNumeric(colsInTable)){
			colsInTable = 2;
		}
		
		var maxColumnsInLine = colsInTable * (doubleColSpan ? 2 : 1);
		
		//處理欄位寬度設定
		var columnProps = config.columnProps;
		if( !JsUtils.isArray(columnProps)){
			columnProps = [];
			var oneColumnProp = 100/colsInTable;
			for( var i = 0 ; i < colsInTable ; i = i + 1 ){
				if(doubleColSpan){
					columnProps[columnProps.length] = (oneColumnProp*0.3);
					columnProps[columnProps.length] = (oneColumnProp*0.7);
				}else{
					columnProps[columnProps.length] = oneColumnProp;
				}
			}
		}
		//設定作用位置 cTable tBody
		var contentAttrs = config.attrs || {};
		contentAttrs["cellPadding"]=0;
		contentAttrs["cellSpacing"]=0;
		var cTable;
		if(actionElem.tagName == "TABLE"){
			cTable = actionElem;
			for( var attr in contentAttrs){
				cTable.setAttribute(attr , contentAttrs[attr] );
			}
		}else{
			cTable = JsUtils.createDOMElement( "table" , contentAttrs );
		}
		JsUtils.setClass( cTable , "contentTable");
		if(JsUtils.isString(config.className)){
			JsUtils.setClass( cTable , config.className );
		}
		
		var saveDom = { count :0 };
		
		//準備開始加入欄位
		var tbodyId = config.id || ("contentArea"+contentCount);
		contentCount = contentCount + 1;
		var tbody = JsUtils.createDOMElement( "tbody" , { "id":tbodyId , "contentBody":true } );
		
		saveRecordMap[tbodyId] = {};
		
		var tr1 = JsUtils.createDOMElement( "tr" , null , null , tbody );
		var tr2;
		if(doubleRowSpan){
			tr2 = JsUtils.createDOMElement( "tr" , null , null , tbody );
		}else{
			tr2 = tr1;
		}
		
		var IdToKeyFunc = config.IdToKey;
		var KeyToIdFunc = config.KeyToId;
		IdToKeyFunc = JsUtils.isFunction(IdToKeyFunc) ? IdToKeyFunc :false;
		KeyToIdFunc = JsUtils.isFunction(KeyToIdFunc) ? KeyToIdFunc :false;
		
		var td;
		var colsMarks = [0];
		var colsMark = 0;
		var rowsCount = 0;
		var activeNodeCount = 0;
		
		for( var i = 0 ; i < config.contents.length ; i = i + 1  ){
			var contentSetting = config.contents[i];
			//取無設定，返回
			if( !JsUtils.isObject(contentSetting) ){
				continue;
			}
			//取得colSpan、rowSpan屬性
			var colSpan = JsUtils.isNumeric(contentSetting.colSpan) ? parseInt(contentSetting.colSpan,10) : 1 ;
			var rowSpan = JsUtils.isNumeric(contentSetting.rowSpan) ? parseInt(contentSetting.rowSpan,10) : 1 ;
			//計算可用colSpan
			if( ( colsMark + colSpan ) > colsInTable){
				colSpan = colsInTable - colsMark;
				colsMark = colsInTable;
			}else{
				colsMark = colsMark + colSpan; 
			}
			//計算後面的rowSpan
			for( var k = 1 ; k < rowSpan ; k = k + 1 ){
				colsMarks[rowsCount+k] = ( colsMarks[rowsCount+k]||0 ) + colSpan;
			}
			//畫面上真正的span
			if( doubleColSpan ){ colSpan = colSpan * 2 ; }
			if( doubleRowSpan ){ rowSpan = rowSpan * 2 ; }
			
			
			//文字顯示方塊
			if( !noHeader ){
				
				var hTdAttrs = {};
				hTdAttrs["className"] = "header";
				// 處理span
				if( doubleColSpan ){
					hTdAttrs["colSpan"] = 1;
					hTdAttrs["rowSpan"] = rowSpan;
				}else if( doubleRowSpan ){
					hTdAttrs["colSpan"] = colSpan;
					hTdAttrs["rowSpan"] = 1;
				}else{
					hTdAttrs["rowSpan"] = rowSpan;
					hTdAttrs["colSpan"] = colSpan;
				}
				//增加元件
				td = JsUtils.createDOMElement( "td" , hTdAttrs , null , tr1 );
				var headerText = contentSetting.header;
				if(JsUtils.isString(headerText)){
					td.appendChild( document.createTextNode( headerText ) );
				}else if(JsUtils.isDOMObject(headerText)){
					td.appendChild( headerText );
				}
				//處理比例 
				var headWidth = 0;
				var hColSpan = hTdAttrs["colSpan"];
				if( hColSpan > 1 ){
					for(var k = 0 ; k < hColSpan ; k = k + 1 ){
						var addProps = columnProps[ activeNodeCount + k ];
						if(!JsUtils.isNumeric(addProps) && addProps!= null ){ 
							headWidth = null;
							break;
						}
						headWidth = (headWidth||0) + addProps;
					}
				}else{ 
					headWidth = columnProps[ activeNodeCount ];
				}
				if( headWidth ){
					td.style.width = headWidth+(JsUtils.isNumeric(headWidth)?"%":"");
				}
				// 增加 Node count
				activeNodeCount = activeNodeCount+ hColSpan;
				
				//debugMode
				/*td.appendChild(document.createTextNode("-colsMark:"+colsMark));
				td.appendChild(document.createTextNode("-activeNodeCount:"+activeNodeCount+"-"));
				td.appendChild(document.createTextNode("-Colspan:"+hColSpan+"-"));
				*/
			}
			
			//操作區塊
			if( !noContent ){
				var cTdAttrs = {};
				cTdAttrs["className"] = "content";
				
				// 處理span
				if( doubleColSpan ){
					cTdAttrs["colSpan"] = colSpan - 1;
					cTdAttrs["rowSpan"] = rowSpan;
				}else if( doubleRowSpan ){
					cTdAttrs["colSpan"] = colSpan;
					cTdAttrs["rowSpan"] = rowSpan - 1;
				}else{
					cTdAttrs["rowSpan"] = rowSpan;
					cTdAttrs["colSpan"] = colSpan;
				}
				//解析物件
				td = JsUtils.createDOMElement( "td" , cTdAttrs , null , tr2 );
				var values = contentSetting.values;
				if(JsUtils.isArray(values)){
					for( var j = 0 ; j < values.length ; j = j + 1 ){
						var valueSetting = values[j];
						if(JsUtils.isBasicType(valueSetting)){
							td.appendChild( document.createTextNode(valueSetting));
						}else if(JsUtils.isDOMObject(valueSetting)){
							td.appendChild( valueSetting );
						}else if(JsUtils.isObject(valueSetting)){
							var nodeId = valueSetting.id;
							var nodeKey = valueSetting.key;
							
							if( !((nodeId && JsUtils.isBasicType(nodeId)) || ( nodeKey && JsUtils.isBasicType(nodeKey))) ){
								continue;
							}else if( !( nodeKey && JsUtils.isBasicType(nodeKey)) ){
								if(IdToKeyFunc){ 
									var temp = IdToKeyFunc(nodeId);
									valueSetting.key = JsUtils.isBasicType(temp) ? temp : nodeId;
								}else{
									valueSetting.key = nodeId;
								}
							}else if( !( nodeId && JsUtils.isBasicType(nodeId)) ){
								if(KeyToIdFunc){
									var temp = KeyToIdFunc(nodeKey);
									valueSetting.id = JsUtils.isBasicType(temp) ? temp : nodeKey;
								}else{
									valueSetting.id = nodeKey;
								}
								nodeId = valueSetting.id;
							}
							
							var nodeType = valueSetting.type;
							
							var getFunc = valueSetting.getFunc;
							var setFunc = valueSetting.setFunc;
							if(JsUtils.isFunction(getFunc) || JsUtils.isFunction(setFunc) ){
								saveDom[nodeId] = { get : getFunc , set : setFunc};
								saveDom["count"] = saveDom["count"] + 1;
								valueSetting.getFunc = null;
								valueSetting.setFunc = null;
							}
							var node = createInput( nodeType||"" , nodeId , valueSetting , JsUtils.isString(contentSetting.header)?contentSetting.header:""  );
							if(node){
								td.appendChild( node );
							}
						}
					}
				}
				//處理比例 
				var contentWidth;
				var cColSpan = cTdAttrs["colSpan"];
				if( cColSpan > 1 ){
					for(var k = 0 ; k < cColSpan ; k = k + 1 ){
						var addProps = columnProps[ activeNodeCount + k ];
						if(!JsUtils.isNumeric(addProps) && addProps!= null ){ 
							contentWidth = null;
							break;
						}
						contentWidth = (contentWidth||0) + addProps;
					}
				}else{ 
					contentWidth = columnProps[ activeNodeCount ];
				}
				if(contentWidth){
					td.style.width = contentWidth+(JsUtils.isNumeric(contentWidth)?"%":"");
				}
				// 增加 Node count
				activeNodeCount = activeNodeCount + cColSpan;
				
				//debugMode
				/*td.appendChild(document.createTextNode("-activeNodeCount:"+activeNodeCount+"-"));
				td.appendChild(document.createTextNode("-Colspan:"+cColSpan+"-"));
				*/
			}
			
			if( colsMark >= colsInTable){
				//判斷是否有行數全部都RowSpan
				var testNode = tr2.firstChild;
				var testRowSpan = testNode.getAttribute("rowSpan") || 1;
				while(testNode){
					var tempRowSpan = testNode.getAttribute("rowSpan") || 1;
					if( tempRowSpan != testRowSpan ){
						if(tempRowSpan < testRowSpan){
							testRowSpan = tempRowSpan;
						}
					}
					testNode = testNode.nextSibling;
				}
				//若最小Rowspan不為1，剪去多餘
				if( testRowSpan > 1 ){
					testNode = tr2.firstChild;
					var disRowSpan = testRowSpan - 1;
					while(testNode){
						var tempRowSpan = testNode.getAttribute("rowSpan") || testRowSpan;
						testNode.setAttribute("rowSpan" , tempRowSpan - disRowSpan );
						testNode = testNode.nextSibling;
					}
					for( var k = 1 ; k < testRowSpan ; k = k + 1 ){
						colsMark = (colsMarks[rowsCount] || 1) - 1;
					}
				}
				//處理換行參數
				rowsCount = rowsCount + 1;
				colsMark = colsMarks[rowsCount] || 0;
				activeNodeCount = colsMark*(doubleColSpan?2:1);
				//處理新TR
				tr1 = JsUtils.createDOMElement( "tr" , null , null , tbody );
				if(doubleRowSpan){
					tr2 = JsUtils.createDOMElement( "tr" , null , null , tbody );
				}else{
					tr2 = tr1;
				}
				
				//debugMode
				/*td.appendChild(document.createTextNode("***colsMark:"+colsMark+"-"));
				td.appendChild(document.createTextNode("-activeNodeCount:"+activeNodeCount+"-"));
				*/
			}
		}
		//若產生的作後一個tr沒有子元素，刪除
		if(!tr1.firstChild){
			var testNode = tr2.firstChild;
			while(testNode){
				testNode.setAttribute("rowSpan" , 1 );
				testNode = testNode.nextSibling;
			}
			
			tbody.removeChild(tr1);
			if(doubleRowSpan){
				tbody.removeChild(tr2);
			}
		}else{
			var lessNodeNum = colsInTable - colsMark;

			if(doubleRowSpan){
				tr1.lastChild.setAttribute("colSpan" , parseInt( tr1.lastChild.getAttribute("colSpan") || 1 , 10 ) + lessNodeNum );
				tr2.lastChild.setAttribute("colSpan" , parseInt( tr2.lastChild.getAttribute("colSpan") || 1 , 10 ) + lessNodeNum );
			}else{
				tr1.lastChild.setAttribute("colSpan" , parseInt( tr1.lastChild.getAttribute("colSpan") || 1 , 10 ) + (lessNodeNum*(doubleColSpan?2:1)) );
			}
		}
		
		//處理saveDomMap
		if(saveDom.count > 0){
			saveDomMap[tbodyId] = saveDom;
		}
		//將作用table附加到頁面上
		if(cTable != actionElem){
			cTable.appendChild(tbody);
			actionElem.appendChild(cTable);
		}else{
			var tds = cTable.getElementsByTagName("TD");
			var testTd = tds[tds.length-1];
			cTable.appendChild(tbody);
			if( JsUtils.isDOMObject(testTd) && JsUtils.compareClass( testTd , "buttons" )){
				tbody.appendChild(testTd.parentNode);	
			}
		}
		
		//處理CSS屬性
		 setTextClass( tbody )
		
		//讀入傳入預設值
		if(JsUtils.isObject(loadinValues)){
			setContentValues( tbody , loadinValues , true , true );
		}
		//處理顯示型態
		setContentsDisplay(tbody , JsUtils.isNumeric(showType) ? showType : 1 );
		
		if(window.autoCreateDate){
			autoCreateDate(tbody,false);
		}
		if(window.autoFormatToDate){
			autoFormatToDate();
			autoFormatToNumber(tbody);
		}
		//將作用資料回傳
		return tbody;
	}
	
	function setTextClass( tbody ){
		var inputs = tbody.getElementsByTagName("input");
		for( var i = 0 ; i < inputs.length ; i = i + 1 ){
			if(inputs[i].getAttribute("type") == 'text'){
				JsUtils.setClass(inputs[i] , "inputText" );
			}
		}
	}
	
	/**  
	 * @public  
	 * @memberOf PageUI
	 * @description 產生單一input物件
	 * @param {String} type input類型
	 * @param {String} id 物件id
	 * @param {Map} setting 設定資料
	 * @returns {DOMElement} 產生的物件;
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	var systemCount = 0;
	function createInput( type, id, setting , defaultFieldName ){
		if(!JsUtils.isBasicType(id) || !JsUtils.isBasicType(type) ){ return; }
		type = type.toLowerCase();
		var span = JsUtils.createDOMElement( "span" , {autoInput:id , autoInputType:type , autoInputValueKey:( setting.key || id )} );
		var attrs = {};
		var events = {};
		
		if(JsUtils.isObject(setting)){
			attrs =  setting.attrs || {};
			events = setting.events || {};
		}
		
		if(!JsUtils.isString(attrs.fieldName)){
			attrs.fieldName = defaultFieldName;
		}
		
		switch(type){
			case 'text':
				//input
				attrs.type = "text";
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				var elem = JsUtils.createDOMElement( "input" , attrs , events , span );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'number':
				attrs.type = "text";
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				attrs.datatype = "number";
				if(!attrs.pattern){
					attrs.pattern = "#";
				}
				var elem = JsUtils.createDOMElement( "input" , attrs , events , span );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
			
			case 'money':
				attrs.type = "text";
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				attrs.datatype = "number";
				if(!attrs.pattern){
					attrs.pattern = "#,##0";
				}
				var elem = JsUtils.createDOMElement( "input" , attrs , events , span );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'select':
				//input
				//get other Object
				var attrsPreOptions = setting.preOpts;
				var attrsOptions = setting.opts;
				var optKey = setting.optKey;
				var optValueKey = setting.optValueKey;
				
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				var elem = JsUtils.createDOMElement( "select" , attrs , events , span );
				
				if(attrsPreOptions){
					JsUtils.addOptions( elem , attrsPreOptions , optKey , optValueKey , true, false );
				}
				if(attrsOptions){
					JsUtils.addOptions( elem , attrsOptions , optKey , optValueKey , false );
				}
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'date':
				//input
				var dateSpan = JsUtils.createDOMElement( "span" , {inputTag:"input"} , null , span );
				attrs.type = "text";
				attrs.id = id;
				attrs.name = id;
				attrs.spanDistance = 2;
				if(!events.change){
					events.change = function(target){
						target.value = JsUtils.getDateInput( target , false );
					}
				}
				if(!attrs.datatype){ attrs.datatype = "date"; }
				var elem = JsUtils.createDOMElement( "input" , attrs , events , dateSpan );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'datebetween':
				var key = setting.key;
				//setting
				var attrs_s = {};
				var attrs_e = {};
				var events_s = {};
				var events_e = {};
				if(JsUtils.isObject(setting)){
					attrs_s = setting.attrs_s || attrs;
					attrs_e = setting.attrs_e || attrs;
					events_s = setting.events_s || events;
					events_e = setting.events_e || events;
				}
				if(!JsUtils.isString(attrs_s.fieldName)){
					attrs_s.fieldName = defaultFieldName+"起";
				}
				if(!JsUtils.isString(attrs_e.fieldName)){
					attrs_e.fieldName = defaultFieldName+"迄";
				}
				//input1
				var dateSpan_s = JsUtils.createDOMElement( "span" , {inputTag:"input"} , null , span );
				attrs_s.type = "text";
				attrs_s.id = id+"S";
				attrs_s.name = id+"S";
				attrs_s.key = key+"S";
				attrs_s.spanDistance = 2;
				if(!attrs_s.datatype){ attrs_s.datatype = "date"; }
				if(!events_s.change){
					events_s.change = function(target){
						target.value = JsUtils.getDateInput( target , false );
					}
				}
				var elem = JsUtils.createDOMElement( "input" , attrs_s , events_s , dateSpan_s );
				//display
				var textContentAttrs = { inputTag:"display" , valueKey:attrs_s.id };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				
				//text ==> ~
				span.appendChild(document.createTextNode("\u301C"));
				
				//input2
				var dateSpan_e = JsUtils.createDOMElement( "span" , {inputTag:"input"} , null , span );
				attrs_e.type = "text";
				attrs_e.id = id+"E";
				attrs_e.name = id+"E";
				attrs_e.key = key+"E";
				attrs_e.spanDistance = 2;
				if(!attrs_e.datatype){ attrs_e.datatype = "date"; }
				if(!events_e.change){
					events_e.change = function(target){
						target.value = JsUtils.getDateInput( target , false );
					}
				}
				var elem = JsUtils.createDOMElement( "input" , attrs_e , events_e , dateSpan_e );
				//display
				var textContentAttrs = { inputTag:"display" , valueKey:attrs_e.id };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'textarea':
				//input
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				var elem = JsUtils.createDOMElement( "textarea" , attrs , events , span );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'radio':
			case 'checkbox':
				//input
				span.setAttribute("id",id);
				var items = setting.items;
				var itemKey = setting.itemKey;
				var itemValueKey = setting.itemValueKey;

				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				attrs.name = attrs.name || id;
				JsUtils.addChecks( type, span , items , itemKey , itemValueKey , attrs ,events , true );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			case 'dom':
				//input
				var elem = setting.elem;
				if(JsUtils.isFunction(elem)){
					elem = elem();
				}
				elem = JsUtils.getDOM(elem);
				if(!elem){ break; }
				for( var attr in attrs){
					if(JsUtils.isBasicType(attrs[attr])){
						elem.setAttribute(attr , attrs[attr] );
					}
				}
				elem.setAttribute("inputTag","input");
				elem.setAttribute("id",id);
				elem.setAttribute("spanDistance",1);
				span.appendChild(elem);
				//display1
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
			
			case 'link':
				//input
				attrs.id = id;
				attrs.name = id;
				attrs.inputTag = "input";
				attrs.spanDistance = 1;
				if(!attrs.herf){ attrs.href="#"; }
				var elem = JsUtils.createDOMElement( "a" , attrs , events , span );
				//display
				var textContentAttrs = { inputTag:"display" };
				JsUtils.createDOMElement( "font" , textContentAttrs , null , span );
				break;
				
			default:
				//input
				var content = "";
				if( JsUtils.isString(setting) ){
					content = setting;
				}else if( JsUtils.isString(setting.text) ){
					content = setting.text;
				}
				span.appendChild(document.createTextNode(content));
				span.setAttribute("id",id);
				span.setAttribute("value",content);
				break;
		}
		
		return span;
	}
	
	/**  
	 * @public  
	 * @memberOf PageUI
	 * @description 單一物件顯示/輸入出切換
	 * @param {DOMElement} node content物件(span)或轄下的input物件,也可傳入element id
	 * @param {Number} displayType 顯示的Type 0=輸入模式 1=顯示模式
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	this.setContentDisplay = setContentDisplay
	function setContentDisplay( node , displayType ){
		node = isContent( node );
		if(!node){return;}
		
		var inputShow = ( displayType !== 1 && displayType !== -1 ) ? "" : "none";
		var displayShow = (displayType !== 0 && displayType !== -1) ? "" : "none";
		
		var child = node.firstChild;
		while(child){
			if(JsUtils.isDOMObject(child)){
				var inputTag = child.getAttribute("inputTag");
				if( inputTag === "display"){
					child.style.display = displayShow;
				}else if( inputTag === "input" ){
					child.style.display = inputShow;
				}
			}
			child = child.nextSibling;
		}
	}
	
	/**  
	 * @public  
	 * @memberOf PageUI
	 * @description 整個content物件顯示/輸入出切換
	 * @param {DOMElement} content contentBody物件(tbody),也可傳入element id
	 * @param {Number} displayType 顯示的Type 0=輸入模式 1=顯示模式
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	this.setContentsDisplay = setContentsDisplay;
	function setContentsDisplay( content , displayType ) {
		contentBodys = isContentBodys(content);
		if(!contentBodys){ return; }
		var returnValues = {};
		for( var i = 0 ; i<contentBodys.length ; i = i + 1 ){
			var contentBody = contentBodys[i];
			var contentSpans = getContentElems( contentBody );
			if(!contentSpans){ continue; }
			var values = {};
			for( var j = 0 ; j < contentSpans.length ; j = j + 1 ){
				setContentDisplay( contentSpans[j] , displayType );
			}
		}
		resize(true);
	}
	
	//-----------------------------------------
	//----- set get commit rollback 判斷函式
	//-----------------------------------------
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 判斷是否為ContentBodys
	 * @param {DOMElement} contentBody contentBody物件(tbody),或母Table,也可傳入element id
	 * @returns {Array} 若為contentBodys,回傳Array,否則回傳false
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isContentBodys( contentBody ){
		contentBody = JsUtils.getDOM( contentBody );
		if( !contentBody ){ return false;}
		var returnNodes = false;
		if( contentBody.tagName == "TABLE" && JsUtils.compareClass( contentBody , "contentTable") ){
			returnNodes = contentBody.getElementsByTagName("TBODY");
		}else if(contentBody.tagName == "TBODY" ){
			returnNodes = [ contentBody ];
		}
		if(returnNodes.length > 0 ){
			var rtnList = [];
			for(var i = 0 ; i < returnNodes.length ; i = i + 1 ){
				if(returnNodes[i].getAttribute("contentBody")){
					rtnList[rtnList.length] = returnNodes[i];
				}
			}
			if(rtnList.length > 0 ){ return rtnList; }
		}
		return false;
	}
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 判斷是否為ContentBody
	 * @param {DOMElement} contentBody contentBody物件(tbody,或母Table),也可傳入element id
	 * @returns {DOMElement} 若為contentBody,回傳單個Body,若有多個時，回傳第一個,否則回傳false
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isContentBody(contentBody){
		contentBody = isContentBodys( contentBody );
		if( contentBody ){ return contentBody[0];}
		return false;
	}
	
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 取得所有的ContentElements
	 * @param {DOMElement} contentBody contentBody物件(tbody),也可傳入element id
	 * @returns {Array} 回傳多個ContentElement,否則回傳false
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function getContentElems( contentBody ){
		contentBody = isContentBody(contentBody);
		if( contentBody ){
			var rtnList = [];
			var spans = contentBody.getElementsByTagName("SPAN");
			for( var i = 0 ; i < spans.length ; i = i + 1 ){
				var autoInput = spans[i].getAttribute("autoInput");
				if( JsUtils.isString(autoInput) ){
					rtnList[rtnList.length] = spans[i];
				}
			}
			return rtnList;
		}
		return false;
	}
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 判斷是否為Content
	 * @param {DOMElement} node content物件(span)或轄下的input物件,也可傳入element id
	 * @returns {DOMElement} 回傳content物件,否則回傳false
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function isContent( node ){
		node = JsUtils.getDOM( node );
		if(!JsUtils.isDOMObject(node)){ return false; } 
		var spanDistance = node.getAttribute("spanDistance");
		if(JsUtils.isNumeric(spanDistance)){
			for( var i = 0 ; i < spanDistance ; i = i + 1 ){
				if(node.parentNode){
					node = node.parentNode;
				}else{
					break;
				}
			}
		}
		if(node.tagName != "SPAN" || !node.getAttribute("autoInput") ){ return false; }
		return node;
	}
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 將指定值放入contentElement中的Display位置
	 * @param {DOMElement} inputElem content物件(span)轄下的display物件或同層物件
	 * @param {String} value 要放進display的資料
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function setToDisplay( inputElem , value , inputAttrs , setOnce ){
		if( JsUtils.isDOMObject(inputElem) && JsUtils.isBasicType(value)){
			var elem = inputElem;
			if(inputElem.tagName == "SPAN" && inputElem.getAttribute("autoInput") ){ 
				elem = inputElem.firstChild;
			}
			while(elem){
				if( JsUtils.isDOMObject(elem) && elem.getAttribute("inputTag")=== "display"){
					if(JsUtils.isObject(inputAttrs)){
						for(var key in inputAttrs){
							if(JsUtils.isBasicType(inputAttrs[key])){
								elem.setAttribute( key , inputAttrs[key] );
							}
						}
					}
					elem.appendChild(document.createTextNode(value));
					if(setOnce !== null ){
						break;
					}
				}
				elem = elem.nextSibling
			}
		}
	}
	
	/**  
	 * @private  
	 * @memberOf PageUI
	 * @description 清除單一ContentDisplay資料
	 * @param {DOMElement} inputElem content物件(span)轄下的input物件
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	function clearDisplays( node ){
		var displayNodes = node.getElementsByTagName("FONT");
		for(var i = 0 ; i < displayNodes.length ; i = i + 1 ){
			var displayNode = displayNodes[i];
			if( JsUtils.isDOMObject(displayNode) && displayNode.getAttribute("inputTag")=== "display"){
				JsUtils.removeAllChildren( displayNode );
				displayNode.removeAttribute("selectValue");
			}
		}
	}
	
	
	
	function getContentBodyIdByElement( node ){
		var contentBody = JsUtils.getParentByTagName( node , "TBODY" );
		contentBody = isContentBody(contentBody);
		if(!contentBody){ return false; }
		var contentBodyId = contentBody.getAttribute("id");
		return contentBodyId;
	}
	
	function getContentRecordById( id ){
		if(id){
			var record = saveRecordMap[id];
			if(!record || !JsUtils.isObject(record)){
				record = {};
				saveRecordMap[id] = record;
			}
			return record;
		}
		return false;
	}
	
	/**  
	 * @public  
	 * @memberOf PageUI
	 * @description 取得單一input物件值
	 * @param {DOMElement} inputElem content物件(span)轄下的input物件
	 * @param {Map} returnMap 附加結果的Map
	 * @returns {Map} 包含取得值得Map
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	this.getContentValue = getContentValue;
	function getContentValue( node , isForDisplay ){
		
		var returnMap = {};
		node = isContent( node );
		if(!node){return returnMap;}
		
		var contentBodyId = getContentBodyIdByElement( node );
		if(!contentBodyId){return returnMap;}
		
		if(isForDisplay !== true){
			returnMap = getContentRecordById(contentBodyId);
			isForDisplay = false;
		}
		
		//Attributes
		var id = node.getAttribute("autoInput");
		var key = node.getAttribute("autoInputValueKey");
		var type = node.getAttribute("autoInputType");
		
		//get Function
		var getFunc = false;
		var saveMap = saveDomMap[contentBodyId];
		if(JsUtils.isObject(saveMap) && JsUtils.isObject(saveMap[id])){
			getFunc = saveMap[id]["get"];
			if(!JsUtils.isFunction(getFunc)){
				getFunc = false;
			}
		}
		
		
		switch(type){
			case 'text':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var value = (elems[i].getValue && elems[i].getValue()) || elems[i].getAttribute("value");
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap , isForDisplay );
					}
					returnMap[key] = JsUtils.isBasicType(value) ? value : "";
				}
				break;
			
			case 'number':
			case 'money':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var value = (elems[i].getValue && elems[i].getValue()) || elems[i].getAttribute("value");
					if(!isForDisplay){
						value = value.replace(/,/g,"");
					}
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap, isForDisplay );
					}
					returnMap[key] = JsUtils.isBasicType(value) ? value : "";
				}
				break;
				
			case 'select':
				var elems = node.getElementsByTagName("select");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var value = elems[i].value;
					if(!value){
						elems[i].firstChild.selected = true;
						value = elems[i].value;
					}
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap , isForDisplay  );
					}
					value = JsUtils.isBasicType(value) ? value : "";
					if(isForDisplay){
						returnMap[key+"_CODE"] = value;
						returnMap[key] = JsUtils.getSelectName( elems[i] , value );
					}else{
						returnMap[key] = value;
						returnMap[key+"_NM"] = JsUtils.getSelectName( elems[i] , value );	
					}
				}
				break;
				
			case 'date':
			case 'datebetween':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var elemId = elems[i].getAttribute("key") || key;
					var value = JsUtils.getDateInput(elems[i], !isForDisplay );
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap , isForDisplay  );
					}
					returnMap[elemId] = JsUtils.isBasicType(value) ? value : "";
				}
				break;

			case 'textarea':
				var elems = node.getElementsByTagName("textarea");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var value = elems[i].textContent || elems[i].innerText;
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap , isForDisplay );
					}
					returnMap[key] = JsUtils.isBasicType(value) ? value : "";
				}
				break;
				
			case 'radio':	
			case 'checkbox':
				var rtnValues = JsUtils.getChecks ( type , id , node );
				if(getFunc){
					rtnValues = getFunc( node , rtnValues , returnMap , isForDisplay  );
				}
				rtnValues = JsUtils.isBasicType(rtnValues) || JsUtils.isArray(rtnValues) ? rtnValues : "";
				if(isForDisplay){
					returnMap[key] = JsUtils.getChecksNameByValues( type , id , node , rtnValues );
				}else{
					if(type == "radio"){
						returnMap[key] = (( JsUtils.isArray(rtnValues) ) ? rtnValues[0] : rtnValues) || "";
					}else{
						returnMap[key] = rtnValues;
					}
				}
				break;
				
			case 'dom':
				if(JsUtils.isFunction(getFunc)){
					rtnValue = getFunc( node.firstChild , returnMap , isForDisplay   );
					returnMap[key] = JsUtils.isBasicType(rtnValue) ? rtnValue : "";
				}
				break;
				
			case 'link':
				var elems = node.getElementsByTagName("a");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					var value = elems[i].textContent || elems[i].innerText;
					if(getFunc){
						value = getFunc( elems[i] , value , returnMap , isForDisplay );
					}
					returnMap[key] = JsUtils.isBasicType(value) ? value : "";
				}
				break;
				
			default:
				var value = node.textContent || node.innerText;
				if(JsUtils.isFunction(getFunc)){
					value = getFunc( node , value , returnMap , isForDisplay   );
				}
				returnMap[key] = JsUtils.isBasicType(value) ? value : "";
		}
		
		return returnMap;
	}
	
	/**  
	 * @public  
	 * @memberOf PageUI
	 * @description 寫入單一input物件值
	 * @param {DOMElement} inputElem content物件(span)轄下的input物件
	 * @param {Map} value 要更新的值
	 * @param {Boolean} [isAutoCommit=true] 更新後是否commit
	 * @param {Boolean} [clearValueWhenNotInValues=true] 當值為null時，是否以空白帶入
	 * @author 黃亮勳
	 * @version 20111101
	 */ 
	this.setContentValue = setContentValue
	function setContentValue( inputElem , value , isAutoCommit  , clearValueWhenNotInValues ){
		node = isContent( inputElem );
		if(!node){return;}
		
		var contentBodyId = getContentBodyIdByElement( node );
		if(!contentBodyId){return;}

		if(isAutoCommit !== false){ isAutoCommit = true; }

		//Attributes
		var id = node.getAttribute("autoInput");
		var key = node.getAttribute("autoInputValueKey");
		var type = node.getAttribute("autoInputType");
		
		//set Function
		var setFunc = false;
		var saveMap = saveDomMap[contentBodyId];
		if(JsUtils.isObject(saveMap) && JsUtils.isObject(saveMap[id])){
			setFunc = saveMap[id]["set"];
			if(!JsUtils.isFunction(setFunc)){
				setFunc = false;
			}
		}
		
		var newValue = "";
		if(JsUtils.isBasicType(value)){
			newValue = value;
		}else if(JsUtils.isObject(value)){
			newValue = value[key];
			if(!JsUtils.isBasicType(newValue)){
				newValue = "";
			}
		}
		/*if( !JsUtils.isBasicType(newValue) 
		 && !( type==='checkbox' && ( JsUtils.isArray(value) || JsUtils.isArray(newValue) ) )
		 && !( ( type==='datebetween' || type==='link' ) && ( JsUtils.isObject(value) || JsUtils.isObject(newValue) ) )
		){
			if(clearValueWhenNotInValues !== false){
				newValue = "";
				clearValueWhenNotInValues = true;
			}else{
				return;
			}
		}*/
		
		switch(type){
			case 'text':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value );
					}
					if(!JsUtils.isBasicType(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
					elems[i].setValue ? elems[i].setValue(newValue) : elems[i].setAttribute("value" , newValue);
				}
				break;
				
			case 'number':
			case 'money':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value);
					}
					var frontZeroCount = 0;
					if(type == 'number' && JsUtils.isBasicType(newValue)){
						for(frontZeroCount ; frontZeroCount < newValue.length ; frontZeroCount = frontZeroCount + 1 ){
							if(! ( newValue.charAt(frontZeroCount) === 0 || newValue.charAt(frontZeroCount) === "0") ){
								break; 
							}
						}
					}
					if(!JsUtils.isNumeric(newValue)){
						newValue = parseFloat(newValue);
						if(!newValue && newValue !== 0){
							if(clearValueWhenNotInValues){ newValue = ""; }else{ break; }
						}
					}
					if(frontZeroCount > 0){
						while(frontZeroCount > 0 ){
							newValue = "0"+newValue;
							frontZeroCount = frontZeroCount - 1;
						}
					} else if(CSRUtil){
						var pattern = elems[i].getAttribute("pattern") || "#";
						newValue = CSRUtil.$fmt( newValue , pattern );
					}
					
					elems[i].setValue ? elems[i].setValue(newValue) : elems[i].setAttribute("value" , newValue );
				}
				break;
				
			case 'select':
				var elems = node.getElementsByTagName("select");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value );
					}
					if(!JsUtils.isBasicType(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
					JsUtils.setOption(elems[i],newValue,false);
				}
				break;
					
			case 'datebetween':
				var values = newValue || value;
				if(JsUtils.isBasicType(values)){
					var newValues = {};
					newValues[nodekey] = values;
					values = newValues;
				}
				if( JsUtils.isObject(values) ){
					var elems = node.getElementsByTagName("input");
					for( var i = 0 ; i < elems.length ; i = i + 1 ){
						var inputValue = values[elems[i].getAttribute("key")] || values[key];
						if(setFunc){
							inputValue = setFunc( elems[i] , inputValue , value );
						}
						if(!JsUtils.isBasicType(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
						JsUtils.setDateInput(elems[i] , inputValue );
					}
				}
				break;
				
			case 'date':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value );
					}
					if(!JsUtils.isBasicType(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
					JsUtils.setDateInput(elems[i] , newValue );
				}
				break;
				
			case 'textarea':
				var elems = node.getElementsByTagName("textarea");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					JsUtils.removeAllChildren(elems[i]);
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value );
					}
					if(!JsUtils.isBasicType(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
					elems[i].appendChild(document.createTextNode(newValue));
				}
				break;
				
			case 'checkbox':
				newValue = newValue || value;
			case 'radio':
				JsUtils.setCheck( type , node.getAttribute("id") , node , newValue , true );
				break;
				
			case 'link':
				newValue = newValue || value;
				var elems = node.getElementsByTagName("a");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					JsUtils.removeAllChildren(elems[i]);
					if(setFunc){
						newValue = setFunc( elems[i] , newValue , value );
					}
					if(!JsUtils.isBasicType(newValue) && !JsUtils.isObject(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
					if(JsUtils.isBasicType(newValue)){
						elems[i].appendChild(document.createTextNode(newValue));
					}else{
						var href = newValue["href"];
						var text = newValue["text"];
						if(JsUtils.isString(href) && href.length > 0 ){elems[i].setAttribute("href",href); }
						if(JsUtils.isBasicType(text) ){ elems[i].setAttribute(elems[i].appendChild(document.createTextNode(text))); }
					}
				}
				break;
				
			case 'dom':
				if(JsUtils.isFunction(setFunc)){
					setFunc(node.firstChild , newValue , value);
				}
				break;
				
			default:
				JsUtils.removeAllChildren(node);
				if(setFunc){
					newValue = setFunc( node , newValue , value );
				}
				if(!JsUtils.isBasicType(newValue) && !JsUtils.isObject(newValue)){ if(clearValueWhenNotInValues){ newValue = ""; }else{ break; } }
				node.appendChild(document.createTextNode(newValue));
		}
		
		if(isAutoCommit !== false ){
			commitContentValue( node );
		}
	}
	
	//將單一input直複製到顯示區
	this.commitContentValue = commitContentValue
	function commitContentValue( node ){
		//更新顯示區
		var values = getContentValue( node ,true );
		if(!values){ return; }
		var id = node.getAttribute("autoInput");
		var key = node.getAttribute("autoInputValueKey");
		var type = node.getAttribute("autoInputType");
		var value = values[key] || "";
		
		clearDisplays(node);
		
		switch(type){
			case 'text':
			case 'number':
			case 'money':
			case 'date':
			case 'select':
			case 'textarea':
			case 'link':
			case 'dom':
			case 'radio':
			case 'checkbox':
				setToDisplay( node , value  );
				break;
			
			case 'datebetween':
				var elems = node.getElementsByTagName("input");
				for( var i = 0 ; i < elems.length ; i = i + 1 ){
					if(elems[i].getAttribute("type") === 'text' ){
						var elemantKey = elems[i].getAttribute("key");
						setToDisplay(elems[i].parentNode , values[elemantKey] , null , true );
					}
				}
				break;
			
			default:
				//doNothing
		}
		// 更新至後方儲存資料
		getContentValue( node ,false );
	}
	
	//將單一input區的直回復成顯示區的直
	this.rollbackContentValue=rollbackContentValue;
	function rollbackContentValue( node ){
		var node = isContent( node );
		if(!node){return;}
		
		var contentBodyId = getContentBodyIdByElement( node );
		if(!contentBodyId){return;}
			
		var recordMap = getContentRecordById(contentBodyId);
		
		setContentValue ( node , recordMap , false );
	}
	
	
	//取得content/contents inputs物件直
	this.getContentValues = getContentValues;
	function getContentValues( content , isAutoCommit, alwaysKeepTwoLayerMap ) {
		contentBodys = isContentBodys(content);
		if(!contentBodys){ return; }
		
		if( isAutoCommit !== false){
			commitContentValues( content );
		}
		var returnValues = {};
		for( var i = 0 ; i<contentBodys.length ; i = i + 1 ){
			
			var  contentBodyId = contentBodys[i].getAttribute("id");
			if(!contentBodyId){ continue; }
			
			var recordMap = getContentRecordById(contentBodyId);
			if(!recordMap || !JsUtils.isObject(recordMap)){ continue; }
			
			returnValues[contentBodyId] = recordMap;
		}
		
		if(!alwaysKeepTwoLayerMap && contentBodys.length == 1 ){
			for(var key in returnValues){
				return returnValues[key];
				break;
			}
		}else{
			return returnValues;
		}
	}
	
	//寫入content/contents inputs物件直
	this.setContentValues = setContentValues;
	function setContentValues( content , values , isAutoCommit , clearValueWhenNotInValues ) {
		var contentBodys = isContentBodys(content);
		if(!JsUtils.isObject(values) ){ values = {};}
		if(!contentBodys || !JsUtils.isObject(values) ){ return; }
		
		var isValueAllObject = true;
		for( var key in values ){
			if(!JsUtils.isObject(values[key])){
				isValueAllObject = false;
				break;
			}
		}
		
		if(!isValueAllObject && contentBodys.length == 1 ){
			var contentBody = contentBodys[0];
			var contentSpans = getContentElems( contentBody );
			if(!contentSpans){ return; }
			
			var contentBodyId = contentBody.getAttribute("id");
			saveRecordMap[contentBodyId] = values ;
			for( var j = 0 ; j < contentSpans.length ; j = j + 1 ){
				setContentValue( contentSpans[j] , values , isAutoCommit , clearValueWhenNotInValues );
			}
		}else if( isValueAllObject ){
			for( var i = 0 ; i<contentBodys.length ; i = i + 1 ){
				var contentBody = contentBodys[i];
				var contentSpans = getContentElems( contentBody );
				if(!contentSpans){ continue; }
				
				var contentBodyId = contentBody.getAttribute("id");
				var value = values[contentBodyId];
				saveRecordMap[contentBodyId] = value || {};
				for( var j = 0 ; j < contentSpans.length ; j = j + 1 ){
					setContentValue( contentSpans[j] , value , isAutoCommit , clearValueWhenNotInValues );
				}
			}
		}
	}
	
	//將content/contents inputs直複製到顯示區
	this.commitContentValues = commitContentValues;
	function commitContentValues( content ) {
		contentBodys = isContentBodys(content);
		if(!contentBodys){ return; }
		for( var i = 0 ; i<contentBodys.length ; i = i + 1 ){
			var contentBody = contentBodys[i];
			var contentSpans = getContentElems( contentBody );
			if(!contentSpans){ continue; }
			for( var j = 0 ; j < contentSpans.length ; j = j + 1 ){
				commitContentValue( contentSpans[j] );
			}
		}
	}
	
	//將content/contents inputs區的直回復成顯示區的直
	this.rollbackContentValues = rollbackContentValues;
	function rollbackContentValues( content ) {
		contentBodys = isContentBodys(content);
		if(!contentBodys ){ return; }
		for( var i = 0 ; i<contentBodys.length ; i = i + 1 ){
			var contentBody = contentBodys[i];
			var contentSpans = getContentElems( contentBody );
			if(!contentSpans){ continue; }
			for( var j = 0 ; j < contentSpans.length ; j = j + 1 ){
				rollbackContentValue( contentSpans[j] );
			}
		}
	}
	
	this.createButtonArea = createButtonArea
	function createButtonArea( content , buttonConfig ){
		var buttons = buttonConfig.buttons;
		if(!JsUtils.isObject(buttons)){
			return;
		}	
		content = JsUtils.getDOM(content);
		var contentElem = isContent(content);
		var contentBody = isContentBody(content);
		if( !contentBody && !contentElem && !content ){ return; }
		
		var div = JsUtils.createDOMElement("div" , {align:"center"});
		var changeForOneButton = ( buttonConfig.changeForOneButton === true) || (contentBody && buttonConfig.buttonOnRight === true );
		if( !window.authButtons || !JsUtils.isObject(window.authButtons)){
			window.authButtons = {};
		}
		var authMap = window.authButtons;
		
		for( key in buttons){
			var config = buttons[key];
			var ignoreAuth = config.ignoreAuth;
			var id = config.id || key;
			if(!ignoreAuth){
				authMap[key] = id;
			}
			var header = config.header || key;
			var events = config.events;
			var attrs = config.attrs ||{};
			attrs.type = "button";
			attrs.value = header;
			attrs.id = id;
			var button = JsUtils.createDOMElement( "input" , attrs , events , div );
			if(changeForOneButton){
				JsUtils.createDOMElement( "br" , null ,null , div );
			}
		}
		if(contentElem){
			JsUtils.setClass(div,"buttons");
			div.setAttribute("align","left");
			var td = getParentByTagName(contentElem , "TD" );
			td.appendChild(div);
		}else if(contentBody){
			if(buttonConfig.buttonOnRight === true ){
				var rowSpan = contentBody.childNodes.length;
				var buttonTd = JsUtils.createDOMElement("td", { rowSpan:rowSpan , "className":"buttons"} , null, contentBody.firstChild );
				buttonTd.appendChild(div);
			}else{
				var colSpan = 0;
				var firstRowTd = contentBody.firstChild.childNodes;
				for(var i = 0 ; i < firstRowTd.length ; i = i + 1 ){
					var tdColSapn = parseInt( firstRowTd[i].getAttribute("colSpan") || 1 , 10 );
					colSpan = colSpan + tdColSapn;
				}
				var buttonTr = JsUtils.createDOMElement("tr", null , null );
				var buttonTd = JsUtils.createDOMElement("td", { colSpan:colSpan , "className":"buttons"} , null, buttonTr );
				buttonTd.appendChild(div);
				contentBody.appendChild(buttonTr);
			}
		}else{
			if(buttonConfig.clearChildElements){
				while(content.firstChild){
					content.removeChild(content.firstChild);
				}
			}
			JsUtils.setClass(div,"buttons");
			content.appendChild(div);
		}
		return div;
	}
	
	this.setButtonsEnable = setButtonsEnable;
	//function setButtonsEnable( buttonContent , enableArray , skipCheck, buttonAuthFunc ){
	function setButtonsEnable( buttonContent , enableArray , skipCheck ){

		buttonContent = JsUtils.getDOM(buttonContent);
		if( !buttonContent || buttonContent.tagName != "DIV"){ return; }
		
		//處理輸入參數
		enableArray = JsUtils.stringToArray(enableArray ,",") ;
		skipCheck = JsUtils.stringToArray(skipCheck,",") ;
		
		
		//紀錄不處理的button狀態;
		var skipCheckMap = {};
		if(JsUtils.isArray(skipCheck)){
			for(var i = 0 ; i < skipCheck.length ; i = i + 1 ){
				skipCheckMap[skipCheck[i]] =  true;
			}
			var testButton = buttonContent.firstChild;
			while(testButton){
				if(JsUtils.isDOMObject(testButton) && testButton.tagName == "INPUT" && testButton.type == "button" ){
					var id = testButton.getAttribute("id");
					if(skipCheckMap[id]){
						skipCheckMap[id] = !!(testButton.disabled);
					}
				}
				testButton = testButton.nextSibling;
			}
		}
		
		//還原原始狀態；
		/*buttonAuth = buttonAuthFunc || window.buttonAuth;
		if(JsUtils.isFunction(buttonAuth)){
			buttonAuth(window.authButtons);
		}else{
			var testButton = buttonContent.firstChild;
			while(testButton){
				if(JsUtils.isDOMObject(testButton) && testButton.tagName == "INPUT" && testButton.type == "button" ){
					testButton.disabled = false;
				}
				testButton = testButton.nextSibling;
			}
		}*/
		
		//處理輸入的資料
		var enableMap = {};
		for( var i = 0 ; i < enableArray.length ; i = i + 1 ){
			enableMap[enableArray[i]] = true;
		}
		//alert(Object.toJSON(enableMap));
		//開始進行disable變更
		var testButton = buttonContent.firstChild;
		while(testButton){
			if(JsUtils.isDOMObject(testButton) && testButton.tagName == "INPUT" && testButton.type == "button" ){
				testButton.disabled = false;
				var id = testButton.getAttribute("id");
				//alert("id:"+id+"  skipCheckMap[id]:"+skipCheckMap[id]+"  enableMap[id]:"+enableMap[id])
				if(skipCheckMap[id] !== undefined){
					testButton.disabled = skipCheckMap[id];
				}else if(!enableMap[id]){
					testButton.disabled = true;
				}
			}
			testButton = testButton.nextSibling;
		}
	}
	
	/** @ignore */
	this.setSubTitle = setSubTitle;
	/**  
	 * @function 
	 * @public  
	 * @memberOf PageUI
	 * @description 設定頁面子標題的文字
	 * @param {String} subTitleText 子標題的文字
	 * @author 陳丁群
	 * @version 20120106
	 */ 
	function setSubTitle( subTitleText ){
		if( subTitle ){
			subTitle.innerHTML = subTitleText;
		}
	}
	
	/*this.setEvents = setEvents;
	function setEvents( eventAction , configs ){
		if( !JsUtils.isString(eventAction) && !JsUtils.isObject(configs) ){
			alert("輸入資料錯誤，請確認輸入資料 (PageUI.setEvents)");
			alert("eventAction :" + eventAction);
			alert("configs : " + configs);
			return;
		}
		for( var id in configs){
			var domObject = JsUtils.getDOM( id );
			if( !JsUtils.isDOMObject( domObject ) ){ continue; }
			var actionFunction = configs[id]
			if( !JsUtils.isFunction( actionFunction ) ){ continue; }
			JsUtils.setEventObserve( domObject , eventAction , actionFunction);
		}
	}*/
	
}
