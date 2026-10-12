/**
 * @public
 * @class display page field by locale
 * @param options (Map)
 * @param config.locale (String)!C
 * @param config.dateField (Array<String>)!C
 * @param config.numberField (Array<String>)!C
 **/
function LocaleDisplay(options){

	var _defaultScale = 25;
	var locale = options.locale;

	var dateFields = options.dateFields;
	var dateyFields = options.dateyFields;
	var dateymFields = options.dateymFields;
	var numberFields = options.numberFields;

	var dateFieldMaxLength;
	var dateyFieldMaxLength;
	var datemFieldMaxLength;

	var dataTypeByDate;
	var dataTypeByDatey;
	var dataTypeByDateym;
	var dateTypeByAmount;
	var validateClassByDate;
	var validateClassByDateym;

	var patternByDate;
	var patternByAmountPrefix;
	var patternByAmount;
	var sdf_ymAD = new SimpleDateFormat('yyyyMM', SimpleDateFormat.TW);
	var sdf;
	var sdf_input;
	var sdf_y;
	var sdf_ym;

	if(locale==='ROC'){
		dataTypeByDate = 'ROCDATE';
		dataTypeByDatey = 'ROCDATEY';
		dataTypeByDateym = 'ROCDATEYM';
		validateClassByDate = 'validate-ROCDate';
		validateClassByDateym = 'validate-ROCDateYM';
		sdf = new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW);
		sdf_input = new SimpleDateFormat('yyyMMdd', SimpleDateFormat.TW);
		sdf_y = new SimpleDateFormat('yyy', SimpleDateFormat.TW);
		sdf_ym = new SimpleDateFormat('yyyMM', SimpleDateFormat.TW);
		dateFieldMaxLength=7;
		dateyFieldMaxLength=3;
		dateymFieldMaxLength=5;
	}else if(locale==='VN'){
		dataTypeByDate = 'vndate';
		dataTypeByDatey = 'vndatey';
		dataTypeByDateym = 'vndateym';
		patternByDate = 'dd/MM/yyyy';
		sdf = new SimpleDateFormat('dd/MM/yyyy', SimpleDateFormat.TW);
		sdf_input = new SimpleDateFormat('dd/MM/yyyy', SimpleDateFormat.TW);
		sdf_y = new SimpleDateFormat('yyyy', SimpleDateFormat.TW);
		sdf_ym = new SimpleDateFormat('yyyyMM', SimpleDateFormat.TW);
		dateFieldMaxLength=10;
		dateyFieldMaxLength=4;
		dateymFieldMaxLength=6;
	}else{
		dataTypeByDate = 'date';
		dataTypeByDatey = 'datey';
		dataTypeByDateym = 'dateym';
		patternByDate = 'yyyy-MM-dd';
		validateClassByDate = 'validate-date-db';
		validateClassByDateym = 'validate-DateYM';
		dateFieldMaxLength=10;
		dateyFieldMaxLength=4;
		dateymFieldMaxLength=6;
	}

	var dateFieldsSize=dateFieldMaxLength+2;
	var dateyFieldsSize=dateyFieldMaxLength+2;
	var dateymFieldsSize=dateymFieldMaxLength+2;

	dateTypeByAmount = 'number';
	patternByAmountPrefix = '#,###';
	patternByAmount = patternByAmountPrefix+'.#######################';

	build();

	/**
	 * @constructor
	 * @private
	 * @memberOf LocaleDisplay
	 * @class wrap input event to judge data type and then control the output
	 **/
	function build(){

		var formElementSerializers = Form.Element.Serializers;

		if(!formElementSerializers.functionModified){

			formElementSerializers['input'] = formElementSerializers['input'].wrap(function(proceed, element, value){

				var elementDataType = element.readAttribute('datatype');
				if(elementDataType != undefined || elementDataType != null){
					elementDataType = elementDataType.toLowerCase();
				}

				if(!Object.isUndefined(value)){
					if(elementDataType === 'number'){
						element.writeAttribute('_isInput');
						var pattern = element.readAttribute('pattern') || CSRUtil.defaultPattern;
						value = new String(value);
						element.value = CSRUtil.$fmt(value, pattern, element.readAttribute('_isInput'));
						return;
					}
					if(elementDataType === 'rocdate' || elementDataType === 'vndate'){
						element.value = sdf_input.format(value);
						return;
					}
					if(elementDataType === 'rocdatey' || elementDataType === 'vndatey'){
						element.value = formatOutputDatey(value);
						return;
					}
					if(elementDataType === 'rocdateym' || elementDataType === 'vndateym'){
						formatOutputDateym(value, function(y,m){
							var tmpValue = y+'-'+m+'-01';
							element.value = sdf_ym.format(tmpValue);
						});
						return;
					}
					return proceed(element, value);
				}

				var elementValue = element.value;

				if(Object.isUndefined(elementValue)){
					return proceed(element, value);
				}

				if(elementDataType === 'rocdate'){
					return toY2K(elementValue);
				}

				if(elementDataType === 'rocdatey'){
					if(Object.isUndefined(elementValue) || elementValue==='' || isNaN(elementValue)){
						return '';
					}
					return (parseInt(elementValue,10)+1911).toString();
				}

				if(elementDataType === 'rocdateym'){
					if(Object.isUndefined(elementValue) || elementValue==='' || isNaN(elementValue)){
						return '';
					}
					return formatOutputDateym(elementValue, function(y,m){
						return (parseInt(y,10)+1911).toString()+m;
					});
				}

				if(elementDataType === 'number'){
					element.writeAttribute('_isInput');
					if(Object.isUndefined(value)){
						return element.value.replace(CSRUtil.replacePattern ,'');
					}
					var pattern = element.readAttribute('pattern') || CSRUtil.defaultPattern;
					value = new String(value);
					element.value = CSRUtil.$fmt(value, pattern, element.readAttribute('_isInput'));
					return;
				}

				return proceed(element, value);

			});

			formElementSerializers.functionModified = true;
		}
	}

	function registerEvent_numberOnly(ele){
		ele.observe('keypress', function(event){
			var code = event.keyCode;
			// number input only(code is 45 represens '-', code is 46 represen '.')
			if(!CSRUtil.pressNumber(code) || code==45 || code==46){ Event.stop(event); }
		});
	}

	function formatOutputDateym(v, func){
		var isAD = v.length==10 && isADdate(v,false);
		if(isAD){
			v = sdf_ymAD.format(v);
		}else if(!v || isNaN(v)){
			return '';
		}
		if(Object.isNumber(v)){
			v = v.toString();
		}
		var vl = v.length;
		var y = v.substring(0, vl-2);
		y = parseInt(y,10).toString();
		var m = v.substring(vl-2, vl);
		return func(y,m,isAD);
	}

	function formatOutputDatey(v){
		if(Object.isUndefined(v) || v===null || v===''){
			return '';
		}
		if(!Object.isNumber(v)){
			v = parseInt(v, 10);
		}
		return (locale==='ROC')?v-1911:v;
	}

	function editAttributeByDateField(id){
		var ele;
		if(typeof(id) === 'string'){ele = $(id);}else{ele = id;}
		if(!ele){return;} if(dataTypeByDate){ele.writeAttribute('datatype', dataTypeByDate);} if(patternByDate){ele.writeAttribute('pattern', patternByDate);} if(validateClassByDate){ele.addClassName(validateClassByDate);}
		ele.writeAttribute('size',dateFieldsSize).writeAttribute('maxLength',dateFieldMaxLength);
		if(autoCreateDate){
			autoCreateDate(ele);
		}
	}

	function editAttributeByDateyField(id){
		var ele;
		if(typeof(id) === 'string'){ele = $(id);}else{ele = id;}
		if(!ele){return;} if(dataTypeByDatey){ele.writeAttribute('datatype', dataTypeByDatey);}
		ele.writeAttribute('size',dateyFieldsSize).writeAttribute('maxLength',dateyFieldMaxLength);
		registerEvent_numberOnly(ele);
	}

	function editAttributeByDateymField(id){
		var ele;
		if(typeof(id) === 'string'){ele = $(id);}else{ele = id;}
		if(!ele){return;} if(dataTypeByDateym){ele.writeAttribute('datatype', dataTypeByDateym);} if(validateClassByDateym){ele.addClassName(validateClassByDateym);}
		ele.writeAttribute('size',dateymFieldsSize).writeAttribute('maxLength',dateymFieldMaxLength);
		registerEvent_numberOnly(ele);
	};

	function editAttributeByNumberField(id){

		var ele;

		if(typeof(id) === 'string'){ele = $(id);}else{ele = id;}

		if(!ele){return;} ele.writeAttribute('datatype', dateTypeByAmount); if(patternByAmount){ ele.writeAttribute('pattern', patternByAmount); }

		ele.setStyle({ 'textAlign': 'right', 'paddingRight':'3px' });

		ele.observe('keypress', function(event){
			var code = event.keyCode;
			if(!CSRUtil.pressNumber(code)){ Event.stop(event); }
		});

		ele.observe('keyup', function(event){

			var code = event.keyCode;

            if (CSRUtil.upNumber(code)) {

                var elem = event.element();
                var pVar = elem.value;

                var pos = 0 , oldCommaCnt = 0 , newCommaCnt = 0 ;
                /*  取出原 cursor 位置  */
                if(document.selection){
                    var oldRange = document.selection.createRange();
                    oldRange.moveStart('character', -pVar.length);
                    pos = oldRange.text.length;
                }else{
                    pos = elem.selectionStart;
                }
                /* 取得原,數量 */
                oldCommaCnt = pVar.match(/,/g);
                oldCommaCnt = oldCommaCnt ? oldCommaCnt.length : 0;
                /* 格式化資料 */
                elem.writeAttribute('_isInput', true);
                elem.setValue(pVar);
                /* 取得格式化後,數量 */
                newCommaCnt = elem.value.match(/,/g);
                newCommaCnt = newCommaCnt ? newCommaCnt.length : 0;

                /*  還原 cursor 位置  */
				//[20220121] 瀏覽器不支援 createTextRange 問題
				var cursorPos = pos + (newCommaCnt - oldCommaCnt);
				if (elem.createTextRange) { //IE
					var textRange = elem.createTextRange();
					textRange.move('character', cursorPos);
					textRange.select();
				} else {
					elem.setSelectionRange(cursorPos, cursorPos);
				}
            }
		});
	}

	if(dateFields){dateFields.each(function(id){editAttributeByDateField(id);});}

	if(dateymFields){dateyFields.each(function(id){editAttributeByDateyField(id);});}

	if(dateymFields){dateymFields.each(function(id){editAttributeByDateymField(id);});}

	if(numberFields){numberFields.each(function(id){editAttributeByNumberField(id);});}

	return {
		getLocale: function(){
			return locale;
		},
		getPatternByDate: function(){
			return patternByDate;
		},
		getPatternByAmount: function(scale){
			var useScale = Object.isNumber(scale)?scale:_defaultScale;
			if(useScale<=0){
				return patternByAmountPrefix;
			}
			var pattern = patternByAmountPrefix+'.';
			for(var i=0;i<useScale;i++){
				pattern+='#';;
			}
			return pattern;
		},
		formatNumber: function(v, scale, isInput){
			if(!v && v!==0){ return '';}
			return CSRUtil.$fmt(v, this.getPatternByAmount(scale), isInput);
		},
		formatDate: function(v){
			if(!v){ return '';};
			var index  = v.indexOf(' ');
			var datePart = index>=0?v.substring(0, index):v;
			if(!isADdate(datePart,false)){return '';}
			if(!sdf){return datePart;};
			return sdf.format(datePart);
		},
		formatDatey: formatOutputDatey,
		formatDateym: function(v){
			return formatOutputDateym(v, function(y,m){
				var tmpValue = y+'-'+m+'-01';
				return sdf_ym.format(tmpValue);
			});
		},
		formatTimestamp: function(v, showMillisecond){
			if(!v){ return '';};
			var index  = v.indexOf(' ');
			var datePart;
			var timePart;
			if(index>=0){
				datePart = v.substring(0, index);
				timePart = v.substring(index+1);
				if(!showMillisecond){
					timePart = timePart.substring(0, timePart.indexOf('.'));
				}
			}else{
				datePart = v;
			}

			var result = sdf?sdf.format(datePart):datePart;
			if(timePart){
				result += ' '+timePart;
			}
			return result;
		},
		/**
		 * @public
		 * @class register control output format of date field
		 * @param id (String||dom Object)!C
		 **/
		registerToDate: function(id){
			if(typeof(id) === 'string'){dateFields.push(id);}
			editAttributeByDateField(id);
		},
		/**
		 * @public
		 * @class register control output format of date layout year field
		 * @param id (String||dom Object)!C
		 **/
		registerToDatey: function(id){
			if(typeof(id) === 'string'){dateyFields.push(id);}
			editAttributeByDateyField(id);
		},
		/**
		 * @public
		 * @class register control output format of date layout year and month field
		 * @param id (String||dom Object)!C
		 **/
		registerToDateym: function(id){
			if(typeof(id) === 'string'){dateymFields.push(id);}
			editAttributeByDateymField(id);
		},
		/**
		 * @public
		 * @class register control output format of amount field
		 * @param id (String||dom Object)!C
		 **/
		registerToAmount: function(id){
			if(typeof(id) === 'string'){numberFields.push(id);}
			editAttributeByNumberField(id);
		}
	};

}