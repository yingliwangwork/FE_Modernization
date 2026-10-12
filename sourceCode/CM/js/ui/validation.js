/*
* Really easy field validation with Prototype
* http://tetlaw.id.au/view/javascript/really-easy-field-validation
* Andrew Tetlaw
* Version 1.5.4.1 (2007-01-05)
* 
* Copyright (c) 2007 Andrew Tetlaw
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

/**
 *  @public
 *	@class 針對頁面的表單資料進行資料驗證
 *	@author 
 *	@version 1.0
 **/ 
String.prototype.Blength = function () {
	var len = this.length;
	var arr = this.match(/[^u4e00-u9fa5]/ig);
	return arr == null ? len : len + arr.length;
}
 
//multiTest 判斷該檢核，是否為多重檢核 add by adin
var Validator = Class.create({
	initialize : function(className, error, test, options ) {
		if(typeof test == 'function'){
			this.options = $H(options);
			this._test = test;
		} else {
			this.options = $H(test);
			this._test = function(){return true};
		}
	
		this.error = error || '輸入檢核錯誤.';
		this.className = className;
	},
	test : function(v, elm , info) { // info : add by dave  
		if( info && info.multiTest == true){		 // multiTest 為 true 時，第一個參數傳入 inputs的陣列 add by Adin (為了動態)
			return this._test.apply( this , v );
		}
		return (this._test(v,elm,info) && this.options.all(function(p){
			return Validator.methods[p.key] ? Validator.methods[p.key](v,elm,Validation.getElementValue(p)) : true;
		}));
	}
});

Validator.methods = {
	pattern : function(v,elm,opt) {return Validation.get('IsEmpty').test(v) || opt.test(v)},
	minLength : function(v,elm,opt) {return v.Blength() >= opt},
	maxLength : function(v,elm,opt) {return v.Blength() <= opt},
	min : function(v,elm,opt) {return v >= parseFloat(opt)}, 
	max : function(v,elm,opt) {return v <= parseFloat(opt)},
	gt : function(v,elm,opt) {return v > parseFloat(opt)}, 
	lt : function(v,elm,opt) {return v < parseFloat(opt)},
	notOneOf : function(v,elm,opt) {return $A(opt).all(function(value) {
		return v != value;
	})},
	oneOf : function(v,elm,opt) {return $A(opt).any(function(value) {
		return v == value;
	})},
	is : function(v,elm,opt) {return v == opt},
	isNot : function(v,elm,opt) {return v != opt},
	equalToField : function(v,elm,opt) {return v == $F(opt)},
	notEqualToField : function(v,elm,opt) {return v != $F(opt)},
	include : function(v,elm,opt) {return $A(opt).all(function(value) {
		return Validation.get(value).test(v,elm);
	})}
} 
 
//instance methods
var Validation = Class.create({
	initialize : function(form, options){
		//預設值
		this.options = Object.extend({
			onSubmit : false,
			stopOnFirst : false,
			immediate : false,
			focusOnError : true,
			useTitles : false,
			checkReadOnly : true,
			checkDisabled : false,
			onFormValidate : function(result, form) {},
			onElementValidate : function(result, elm) {},
			toNextError : true,
			notIgnoreHidden : false,
			mode : Validation.defaultManner
		}, options || {});
						
		Validation.mode = Validation.manner[this.options["mode"]];
		
		this.verifyList= {};  //存放多重檢核的物件
		
		this.form = $(form);
		if(this.options.onSubmit) Event.observe(this.form,'submit',this.onSubmit.bind(this),false);
		
		if(this.options.immediate) {
			var useTitles = this.options.useTitles;
			var callback = this.options.onElementValidate;
			var toNextError = this.options.toNextError;
			Form.getElements(this.form).each(function(input) { // Thanks Mike!
				Event.observe(input, 'change', function(event) {
					//showAlert add by adin 用來做validator的即時檢核用的
					var check = Validation.mode.validate( event.target ,{useTitle : useTitles, onElementValidate : callback } , {showAlert : true});
					if( check && toNextError){	//是否要跳到下一個錯誤
						Validation.focusNextErrorElement( input );
					}
				});
			});
		}	
	},onSubmit :  function(ev){
		if(!this.validate()) Event.stop(ev);
	},validate : function(info) {
		var result = false;
		var useTitles = this.options.useTitles;
		var callback = this.options.onElementValidate;
		var checkReadOnly = this.options.checkReadOnly;
		var checkDisabled = this.options.checkDisabled;
		var notIgnoreHidden = this.options.notIgnoreHidden;
		
		if( Validation.mode.beforeValidAction ){
			Validation.mode.beforeValidAction();
		}
			
		if(this.options.stopOnFirst) {	
			result = Form.getElements(this.form).all(function(elm) { 
				return Validation.mode.validate(elm,{ notIgnoreHidden : notIgnoreHidden, useTitle : useTitles, onElementValidate : callback, checkReadOnly: checkReadOnly, checkDisabled: checkDisabled }, info); }
			);
		} else {
			result = Form.getElements(this.form).collect(function(elm) { 
				return Validation.mode.validate(elm,{ notIgnoreHidden : notIgnoreHidden, useTitle : useTitles, onElementValidate : callback, checkReadOnly: checkReadOnly, checkDisabled: checkDisabled }, info); }	
			).all();
		}
		
		if(!result && this.options.focusOnError) {
			var elements = Form.getElements(this.form).findAll(function(elm){
				return $(elm).hasClassName( Validation.mode.fail_css )
			});
			
			for( var i=0 ; i < elements.length ; i++ ){
				if( Validation.isVisible(elements[i]) && ! elements[i].disabled ){
					elements[i].focus();
					break;
				}
			}
		}

		//多重檢核
		for( var method in this.verifyList ){
			for( var i=0 ; i < this.verifyList[method].length ; i++ ){    		//找出有幾組多重檢核method
				var params = this.verifyList[method][i];
				var inputs = params["input"];
				var options = params["option"];
				result = Validation.mode.multiValidate( method , inputs , options ) && result;
			}
		}

		if( Validation.mode.afterValidAction ){
			Validation.mode.afterValidAction( this.options );
		}

		this.options.onFormValidate(result, this.form);

		return result;
	},
	reset : function( isOnlyForm ){
		Form.getElements(this.form).each(
			function(elm){
				Validation.mode.reset(elm);
			}
		);
		
		if( ! isOnlyForm === true ){
			this.verifyReset();
		}
	},
	eraseMoney : function() {
			Form.getElements(this.form).findAll(function(elm){return $(elm).hasClassName('validate-number')}).each(function(e){
			var v = Validation.getElementValue(e);
			if (Validation.get('IsEmpty').test(v)){ 
				v = v.split(',').join('');
				e.setValue(v);
			}
			
		});
	},
	transformMoney : function() {
		Form.getElements(this.form).findAll(function(elm){return $(elm).hasClassName('validate-number')}).each(function(e){
			var v = Validation.getElementValue(e);
			if (Validation.get('IsEmpty').test(v)){
				v = v.replace(/^(\d+)((\.\d+)?)$/,function(s,s1,s2){return s1.replace(/\d{1,3}(?=(\d{3})+$)/g,"$&,")+s2;});
				e.setValue(v);
			}
			
		});
	},
	define : function( method_name, inputs , options ){   //自訂多個欄位的檢核
		options = options || this.options;
		var params = { input : inputs , option : options };
				
		if(! this.verifyList[method_name]){
			this.verifyList[method_name] = [];
		}
		this.verifyList[method_name].push( params );
	},
	clear : function(){		//清除多重檢核項目
		this.verifyList = {};
	},
	verifyReset: function(){
		for( var method in this.verifyList ){
			for( var i=0 ; i < this.verifyList[method].length ; i++ ){
				var params = this.verifyList[method][i];
				var inputs = params["input"];
				
				if( inputs instanceof Array ){
					for(var j=0 ; j < inputs.length ; j++ ){	//該method定義了幾組inputs的檢核
						Validation.mode.reset(inputs[j]["id"]);
					}
				}else{
					Validation.mode.reset(inputs["id"]);
				}
			}
		}
	}
});

//將原先validate變動的部份抽出來成為一個class (具有validate() , test() , reset() ) 的介面
Validation.manner= {
	"validate" : { 	//對應國際投資的檢核效果
		pass_css : "validation-passed",
		fail_css : "validation-failed",
		m_fail_css: "m_validation-failed",
		advice_css: "validation-advice",
		validate : function(elm, options, info){
			options = Object.extend({
				useTitle : false,
				onElementValidate : function(result, elm) {}
			}, options || {});
			elm = $(elm);

			if(!options.checkReadOnly && elm.readOnly) { return true; }
			if(!options.checkDisabled && elm.disabled == true) { return true; }
			
			var cn = elm.classNames();
			
			var testMethod = this;
			return cn.all(function(value) {
				var test = testMethod.test(value,elm,options.useTitle,info ,options.notIgnoreHidden );
				options.onElementValidate(test, elm);
				return test;
			});
		},
		test : function(name, elm, useTitle, info, notIgnoreHidden ) {
			var v = Validation.get(name);
			try {
				var pass_css = this.pass_css;	
				var isVisible = notIgnoreHidden ? true : Validation.isVisible(elm);
				
				if( isVisible && ! v.test( $F(elm), elm, info)) {
					var errorMsg = useTitle ? ((elm && elm.title) ? elm.title : v.error) : v.error;
					var advice = this.getAdvice(name, elm);
				
					if( ! advice ) {
						advice = this.createAdvice(this.advice_css , name , elm , errorMsg);
						if( elm.type ){
							switch (elm.type.toLowerCase()) {
								case 'checkbox':
								case 'radio':
									var p = elm.parentNode;
									if(p) {
										Element.insert( p, { bottom : advice } );
									} else {
										Element.insert( elm, { after : advice } );									
									}
									break;
								default:
									Element.insert( elm , { after : advice } );	
							}
						}else{
							Element.insert( elm , { after : advice } );	
						}
					}else{
						advice.update(errorMsg);
					}

					advice.style.display = 'block';
					advice.removeClassName("validation-advice-disabled");
					
					elm.removeClassName( pass_css);
					elm.addClassName(this.fail_css);
					Validation.addError( elm , name , this.fail_css );
					return false;
				} else {
					var advice = this.getAdvice(name, elm);
					
					if( advice ){ 
						advice.style.display = "none";
						advice.addClassName("validation-advice-disabled");
					}	
					var result = Validation.removeError( elm , v.className , this.fail_css );
					if( result["result"] ){
						elm.addClassName( pass_css );				
					}
					
					if ( result["remove"] ){
						elm.removeClassName( this.fail_css );				
					}
					return true;
				}
			} catch(e) {
				throw(e)
			}
		},reset : function(elm) {
			elm = $(elm);
			
			var errors = Validation.getErrorArray( elm );	//取出element的ErrorPool,並隱藏advice
			for( var i=0 ; i < errors.length ; i++ ){
				var value = errors[i];
				var advice = this.getAdvice(value, elm);
				if( advice ){
					advice.style.display = "none";
					advice.addClassName("validation-advice-disabled");
				}	
			}
			
			elm.removeClassName(this.pass_css);
			elm.removeClassName(this.fail_css);
			elm.removeClassName(this.m_fail_css);
			Validation.clearCustomAttribute( elm );
		},multiValidate : function( validation_name , elms, options ){
			var notIgnoreHidden = ( options && options.notIgnoreHidden === true ) || false;

			var elements = Validation.getMultiTestElements( elms , options);
			if( elements === true ){
				return true;
			}
			return this.multiTest( validation_name , elements[0] , elements[1] , options.useTitle , notIgnoreHidden);
		},multiTest : function( validation_name , elms , inputs , useTitle , notIgnoreHidden) {
			var v = Validation.get( validation_name );
			try {
				var checklist = inputs[inputs.length -1 ];		//取得檢核的DOM列表
				if ( checklist.length == 1 ){					//只有一個元素的話,將DOM物件陣列改為傳一個DOM物件				
					inputs[inputs.length -1 ] = checklist[0];
				}
				var isVisible = true;

				if( !notIgnoreHidden ){
					for( var i=0 ; i < checklist.length ; i++ ){
						if(! Validation.isVisible(checklist[i]) ){
							isVisible = false;
							break;
						}
					}
				}

				var pass_css = this.pass_css;					
				if( isVisible && !v.test( inputs , elms , { multiTest: true })) {					
					for( var i=0 ; i < checklist.length ; i++ ){
						if( ! elms[i]["ignore"] === true ){
							var elm = checklist[i];						
							
							var errorMsg;
							if( elms[i]["errMsg"] ){    //使用者有自訂的話，用自訂的
								errorMsg = elms[i]["errMsg"];
							}else{						//有使用title的話用title,否則用檢核function的
								errorMsg = useTitle ? ((elm && elm.title) ? elm.title : v.error) : v.error;
							}
							
							var advice = this.getAdvice(validation_name , elm);

							if( !advice ) {		
								advice = this.createAdvice(this.advice_css , validation_name , elm , errorMsg);
								if( elm.type ){
									switch (elm.type.toLowerCase()) {
										case 'checkbox':
										case 'radio':
											var p = elm.parentNode;
											if(p) {
												Element.insert( p, { bottom : advice } );
											} else {
												Element.insert( elm, { after : advice } );									
											}
											break;
										default:
											Element.insert( elm , { after : advice } );	
									}
								}else{
									Element.insert( elm , { after : advice } );	
								}
							}else{
								advice.update(errorMsg);
							}

							advice.style.display = 'block';
							advice.removeClassName("validation-advice-disabled");
							
							elm.removeClassName( pass_css);
							elm.addClassName(this.m_fail_css);	
							Validation.addError( elm , validation_name , this.m_fail_css );
						}
					}
					return false;
				} else {
					for( var i=0 ; i < checklist.length ; i++ ){
						var elm = checklist[i];
						var advice = this.getAdvice(validation_name, elm);
						if(advice){ 
							advice.style.display = "none";
							advice.addClassName("validation-advice-disabled");
						}	
						var result = Validation.removeError( elm , v.className , this.m_fail_css );
						if( result["result"] ){
							elm.addClassName( pass_css );				
						}
						
						if ( result["remove"] ){
							elm.removeClassName( this.m_fail_css );				
						}				
					}
					return true;
				}
			} catch(e) {
				throw(e)
			}
		},createAdvice:function( advice_css , name , elm , errorMsg){
			var eleId = "advice-" + name + "-" + Validation.getElmID(elm);
			return new Element('div', {id:eleId})
				.addClassName(advice_css)
				.addClassName("validation-advice-disabled")
				.update(errorMsg)
				.hide();
		},getAdvice : function(name, elm) {
			return $('advice-' + name + '-' + Validation.getElmID(elm)) || $('advice-' + Validation.getElmID(elm));
		}
	},
	"validator" : //對應國內投資的檢核效果
	{
		pass_css : "validator-passed",
		fail_css : "validator-failed",
		m_fail_css : "m_validator-failed",	
		errMsg : "" ,
		validate : function(elm, options, info){
			options = Object.extend({
				useTitle : false,
				onElementValidate : function(result, elm) {}
			}, options || {});
			elm = $(elm);

			if(!options.checkReadOnly && elm.readOnly) { return true; }
			if(!options.checkDisabled && elm.disabled == true) { return true; }
			
			var cn = elm.classNames();
			
			var testMethod = this;
			return result = cn.all(function(value) {
				var test = testMethod.test(value,elm,options.useTitle,info, options.notIgnoreHidden );
				options.onElementValidate(test, elm);
				return test;
			});
		},
		test : function(name, elm, useTitle, info , notIgnoreHidden) {
			var v = Validation.get(name);
					
			try {
				var pass_css = this.pass_css;		
				var isVisible = notIgnoreHidden ? true : Validation.isVisible(elm);

				var verifyValue;
				if(elm.readAttribute('datatype') === 'ROCDATE'){
					verifyValue = $(elm).value;
				}else{
					verifyValue = $F(elm);
				}

				if( isVisible && !v.test(verifyValue, elm, info)) {

					
					var fieldName = elm.getAttribute("fieldName") || "" ; 
					var errorMsg = useTitle ? ((elm && elm.title) ? elm.title : v.error) : v.error;
					
					errorMsg = fieldName + " [" + errorMsg + "]";
					this.errMsg = this.errMsg + errorMsg + '\n';

					Validation.addError( elm , name , this.fail_css );				
					elm.removeClassName( pass_css );
					elm.addClassName( this.fail_css );
									
					//用來做即時檢核的alert
					if( info  && info.showAlert === true){	//因為info可傳可不傳,所以要先判斷undefined 
						alert( errorMsg );
					}
					
					return false;
				} else {
					var result = Validation.removeError( elm , v.className , this.fail_css );
					if( result["result"] ){
						elm.addClassName( pass_css );				
					}
					
					if ( result["remove"] ){
						elm.removeClassName( this.fail_css );				
					}
								
					return true;
				}
			} catch(e) {
				throw(e)
			}
		},reset : function(elm) {
			elm = $(elm);	
			this.errMsg = '';
			elm.removeClassName(this.fail_css);
			elm.removeClassName(this.pass_css);
			elm.removeClassName(this.m_fail_css);
			Validation.clearCustomAttribute( elm );
		}, beforeValidAction : function(){
			this.errMsg = '';
		}, afterValidAction : function( options ){
			if ( this.errMsg != '' ){
				this.errMsg =  ( options.alertTitle || "" ) + '檢核錯誤如下:\n' + this.errMsg;
				alert( this.errMsg);
			}
		},multiValidate : function( validation_name , elms, options ){
			var elements = Validation.getMultiTestElements( elms , options);
			if( elements === true ){
				return true;
			}
			var notIgnoreHidden = ( options && options.notIgnoreHidden === true ) || false;
			return this.multiTest( validation_name , elements[0] , elements[1] , options.useTitle, notIgnoreHidden );
		},multiTest : function( validation_name , elms , inputs , useTitle, notIgnoreHidden ) {
			var v = Validation.get( validation_name );
			
			try {
				var checklist = inputs[inputs.length -1 ];		//取得檢核的DOM列表
				if ( checklist.length == 1 ){					//只有一個元素的話,將DOM物件陣列改為傳一個DOM物件				
					inputs[inputs.length -1 ] = checklist[0];
				}
				
				var isVisible = true;
				
				if( !notIgnoreHidden ){
					for( var i=0 ; i < checklist.length ; i++ ){
						var elm = checklist[i];
						if(! Validation.isVisible(elm)){
							isVisible = false;
							break;
						}
					}
				}
				
				var pass_css = this.pass_css;			
				if( isVisible && !v.test( inputs , elms , { multiTest: true })) {
					for( var i=0 ; i < checklist.length ; i++ ){
						if( ! elms[i]["ignore"] === true ){
							var elm = checklist[i];					
							var name = elm.id || elm.name;
							var fieldName = elm.getAttribute("fieldName") || "" ;
				
							var errorMsg = '';
							if( elms[i]["errMsg"] ){    //使用者有自訂的話，用自訂的
								errorMsg = elms[i]["errMsg"];
							}else{						//有使用title的話用title,否則用檢核function的
								errorMsg = useTitle ? ((elm && elm.title) ? elm.title : v.error) : v.error;
							}
							
							errorMsg = fieldName + " [" + errorMsg + "]";
							this.errMsg = this.errMsg + errorMsg + '\n'; 
												
							//單一檢核的pass_css
							Validation.addError( elm , validation_name,this.m_fail_css);
							elm.removeClassName(pass_css);				//把pass css拿掉!!					
							elm.addClassName(this.m_fail_css);							
						}
					}
					return false;
				} else {
					for( var i=0 ; i < checklist.length ; i++ ){
						var elm = checklist[i];
						var result = Validation.removeError( elm , validation_name , this.m_fail_css );
						if( result["result"] ){
							elm.addClassName( pass_css );				
						}
						
						if ( result["remove"] ){
							elm.removeClassName( this.m_fail_css );				
						}						
					}
					return true;
				}
			} catch(e) {
				throw(e)
			}
		}	
	}
}

//初始化 validation 的模式 (由系統決定預設模式)
if( typeof CSRUtil == "object" && CSRUtil.UICore && CSRUtil.UICore.isOnTheSys( ['DS'] )){
	Validation.defaultManner = "validator";
	Validation.mode = Validation.manner["validator"];
}else{
	Validation.defaultManner = "validate";
	Validation.mode = Validation.manner["validate"];			//預設的檢核方式
}

Validation.PREFIX = "data-__validation";						//自訂屬性用的前置詞
Validation.ERROR_POOL = Validation.PREFIX + "ErrorPool";		//自訂屬性，用來記錄element有哪些檢核錯誤

//Class Methods	
Object.extend(Validation, {
	validate : function(elm, options, info){
		if( options && options.mode ){
			return Validation.manner[options.mode].validate(elm, options, info);
		}
		return Validation.mode.validate(elm, options, info);
	},
	test : function(name, elm, useTitle, info) {
		if( info && info.mode ){
			return Validation.manner[info.mode].test(name, elm, useTitle, info);
		}
		return Validation.mode.test(name, elm, useTitle, info);
	},
	isVisible : function(elm) {
		while(elm.tagName != 'BODY') {
			if(!$(elm).visible()) return false;
			elm = elm.parentNode;
		}
		return true;
	}
	,
	getElmID : function(elm) {
		return elm.id ? elm.id : elm.name;
	},
	reset : function(elm) {
		for( var mode in Validation.manner ){
			Validation.manner[mode].reset( elm );
		}
	},
	add : function(className, error, test, options) {
		Validation.methods[className] = new Validator( className ,error ,test ,options);	
	},
	addAllThese : function(validators) {
		$A(validators).each(function(value) {
			Validation.methods[value[0]] = new Validator(value[0], value[1], value[2], (value.length > 3 ? value[3] : {}));
		});
	},
	get : function(name) {
		return  Validation.methods[name] ? Validation.methods[name] : Validation.methods['_LikeNoIDIEverSaw_'];
	},
	methods : {
		'_LikeNoIDIEverSaw_' : new Validator('_LikeNoIDIEverSaw_','',{})
	},
	getAdvice : function(name, elm) {
		return $('advice-' + name + '-' + Validation.getElmID(elm)) || $('advice-' + Validation.getElmID(elm));
	},
	getMode: function(name){
		return Validation.manner[name];
	},
	setMode: function(name){
		Validation.mode = Validation.manner[name];
	},
	multiValidate : function( validation_name , elms, options){	 	
		options = options || {};
		if( options.mode ){
			return Validation.manner[options.mode].multiValidate( validation_name , elms , options );
		}		
		return Validation.mode.multiValidate( validation_name , elms , options );
	},
	multiTest : function( validation_name , elms , inputs , useTitle ){
		return Validation.mode.multiTest( validation_name , elms , inputs , useTitle);
	},
	addError:function( elm , method_name , fail_css ){	//在html DOM element上記錄檢核的錯誤資訊
		var errors = Validation.getErrorArray( elm );
		if(  errors.indexOf(method_name) == -1 ){	    //目前沒有這個錯誤
			var error = elm.getAttribute( Validation.ERROR_POOL ) || '';
			error =  error.length > 0 ? error + ' ' + method_name : method_name;
			elm.setAttribute( Validation.ERROR_POOL , error );
			var fail_css = Validation.PREFIX + fail_css;
			var error_count = elm.getAttribute( fail_css ) ? new Number(elm.getAttribute( fail_css )) + 1 : 1;
			elm.setAttribute( fail_css , error_count );
		}	
	},
	removeError:function( elm , method_name , fail_css ){	//在html DOM element上移除檢核的錯誤資訊,並回傳結果
		var errors = Validation.getErrorArray( elm );
		var result = false;
		var remove = false;
		
		var index =	errors.indexOf(method_name);
		if(  index >= 0 ){		   //已經有這個錯誤了
			errors = Validation.removeErrorArray( elm , errors , method_name );
			
			var fail_css = Validation.PREFIX + fail_css;
			var error_count = new Number(elm.getAttribute( fail_css ))-1;
			if( error_count == 0 ){
				elm.removeAttribute( fail_css );	
				remove= true;
			}else{
				elm.setAttribute( fail_css , error_count );
			}
		}		
		
		if( errors.length == 0 ){	//不論是String或是Array,length=0都代表沒錯誤了
			result = true;
		}
		
		return { "result" : result , "remove" : remove };				
	},
	focusNextErrorElement: function( input ){	//把焦點換到下一個錯誤
		var nextErrors = Element.select( document.body , '['+ Validation.ERROR_POOL + ']' );
		if( nextErrors && nextErrors.length > 0 ){
			var compare;
			if( input.compareDocumentPosition ){	//表示瀏覽器有支援DOM Level3
				compare = function( input , next ){
					if( input.compareDocumentPosition( next ) == 4 ){ //nextError在input之後
						return true;
					}
					return false;
				}
			}else{
				if( input.sourceIndex ){
					compare = function( input , next ){	//IE only
						if( next.sourceIndex > input.sourceIndex ){		//nextError在input之後
							return true;
						}
						return false;
					}
				}				
			}
			
			if( compare ){
				for( var i = 0 ; i < nextErrors.length ; i++ ){
					if( compare( input , nextErrors[i] ) ){
						if( Validation.isVisible(nextErrors[i]) && ! nextErrors[i].disabled ){
							nextErrors[i].focus();
							return;
						}
					}
				}
			}
			
			if( Validation.isVisible(nextErrors[0]) && !nextErrors[0].disabled ){
				nextErrors[0].focus();
			}
		}
	},
	clearCustomAttribute: function(elm){	//清除 element 的錯誤資訊
		var attrs = elm.attributes;
		for( var i = attrs.length-1 ; i >= 0  ; i-- ){
			if( attrs[i].name.indexOf(Validation.PREFIX) == 0 ){
				elm.removeAttribute( attrs[i].name );
			}
		}	
	},
	getElementValue: function(elm){
		var tagName = elm.tagName;
		switch(tagName){
			case 'DIV':
			case 'SPAN':
				return elm.innerHTML;
			case 'SELECT':
				return elm.value;
			default:
				return Object.isFunction(elm.getValue)?elm.getValue():elm.value;
		}
	},getErrorArray: function( elm ){
		var errors = elm.getAttribute( Validation.ERROR_POOL ) || "" ;
		return errors.split(" ");
	},removeErrorArray : function( elm , errors , method_name ){
		var error = '';
		for( var i = 0 ; i < errors.length ; i++ ){
			if( errors[i] == method_name ){
				continue;
			}
			error = error + errors[i] + " ";
		}
		
		if( error.length > 0 ){
			error = error.slice(0 , -1);	//去最後一個空白
		}
		elm.setAttribute( Validation.ERROR_POOL , error );
		return error;
	},getMultiTestElements: function( elms , options){
		var values = [];
		if( elms instanceof Array ){
			var inputs = [];
			for(var i=0 ; i < elms.length ; i++ ){
				var elm =  $( elms[i]["id"] );	
				if( !options.checkReadOnly && elm.readOnly) { return true; }
				if( !options.checkDisabled && elm.disabled == true) { return true; }
				values.push(Validation.getElementValue(elm));
				inputs.push(elm);		
			}
			values.push( inputs );
		}else if( typeof elms == "object" ){
			var id = elms["id"];
			elms = [ elms ];
			var elm =  $(id);
			if( !options.checkReadOnly && elm.readOnly) { return true; }
			if( !options.checkDisabled && elm.disabled == true) { return true; }	
			values.push(Validation.getElementValue(elm));
			values.push([ elm ]);
		}else if( typeof elms == "string" ){			
			var elm =  $( elms );
			if( !options.checkReadOnly && elm.readOnly) { return true; }
			if( !options.checkDisabled && elm.disabled == true) { return true; }
			elms = [{ id : elms }];
			values.push(Validation.getElementValue(elm));
			values.push([ elm ]);
		}
		 
		return [ elms , values ];
	}	
});


Validation.add('IsEmpty', '', function(v) {
				return  ((v == null) || (v.length == 0)); // || /^\s+$/.test(v));
			});

Validation.addAllThese([
	['required', '不可空白.', function(v) {
				return !Validation.get('IsEmpty').test(v);
			}],
	['validate-number', '請輸入有效數字格式.', function(v) {
				return Validation.get('IsEmpty').test(v) || /^[+-]?[\d\,]*\.?\d*([eE][+-]?\d+)?$/.test(v);
			}],
	['validate-positive-number', '請輸入有效正數.', function(v) {
				return Validation.get('IsEmpty').test(v) || (!isNaN(v) && /^(\d)?\d*(\.\d*)?$/.test(v));
			}],
    ['validate-integer', '請輸入有效整數.', function(v) {
				return Validation.get('IsEmpty').test(v) || /^(-)?\d*$/.test(v);
			}],
	['validate-digits', '請輸入有效正整數.', function(v) {
				return Validation.get('IsEmpty').test(v) || /^\d+$/.test(v);
			}],
	['validate-positive', '請輸入大於零之有效正整數.', function(v) {
				return Validation.get('validate-digits').test(v);
			}, {gt:0}],
	['validate-greater-than-zero', '請輸入大於零之有效數字格式.', function(v) {
				return Validation.get('validate-number').test(v);
			}, {gt:0}],
	['validate-alpha', '請輸入英文字母.', function (v) {
				return Validation.get('IsEmpty').test(v) || /^[a-zA-Z]+$/.test(v)
			}],
	['validate-alphanum', '請輸入有效文數字.', function(v) {
				return Validation.get('IsEmpty').test(v) || !/\W/.test(v) || /[^u4e00-u9fa5]/.test(v)
			}],
	['validate-date', '請輸入有效日期格式.', function(v) {
				var test = new Date(v);
				return Validation.get('IsEmpty').test(v) || !isNaN(test);
			}],
	['validate-email', '請輸入有效電子郵件地址格式.', function (v) {
				return Validation.get('IsEmpty').test(v) || /\w{1,}[@][\w\-]{1,}([.]([\w\-]{1,})){1,}$/.test(v)
			}],
	['validate-url', '請輸入有效網址.', function (v) {
				return Validation.get('IsEmpty').test(v) || /^(http|https|ftp):\/\/(([A-Z0-9][A-Z0-9_-]*)(\.[A-Z0-9][A-Z0-9_-]*)+)(:(\d+))?\/?/i.test(v)
			}],
	['validate-date-db', '有效日期格式為: YYYY-MM-DD', function(v) {
				if(Validation.get('IsEmpty').test(v)) return true;
				var regex = /^(\d{4})\-(\d{2})\-(\d{2})$/;
				if(!regex.test(v)) return false;
				var d = new Date(v.replace(regex, '$1/$2/$3'));
				return ( parseInt(RegExp.$2, 10) == (1+d.getMonth()) ) && 
							(parseInt(RegExp.$3, 10) == d.getDate()) && 
							(parseInt(RegExp.$1, 10) == d.getFullYear() );
			}],
	['validate-currency-dollar', 'Please enter a valid $ amount. For example $100.00 .', function(v) {
				// [$]1[##][,###]+[.##]
				// [$]1###+[.##]
				// [$]0.##
				// [$].##
				return Validation.get('IsEmpty').test(v) ||  /^\$?\-?([1-9]{1}[0-9]{0,2}(\,[0-9]{3})*(\.[0-9]{0,2})?|[1-9]{1}\d*(\.[0-9]{0,2})?|0(\.[0-9]{0,2})?|(\.[0-9]{1,2})?)$/.test(v)
			}],
	['validate-selection', '請選擇', function(v,elm){
				// return elm.options ? elm.selectedIndex > 0 : !Validation.get('IsEmpty').test(v);
				return !Validation.get('IsEmpty').test(v) || elm.selectedIndex > 0;
			}],
	['validate-one-required', '請先選擇.', function (v,elm) {
				var p = elm.parentNode;
				var options = p.getElementsByTagName('INPUT');
				return $A(options).any(function(elm) {
					return $F(elm);
				});
			}],
	['validate-positive-integer', '請輸入大於零之有效整數.', function(v) {
				return Validation.get('validate-integer').test(v);
			}, {gt:0}]
]);

//必需使用 date.js 才能使用的檢核
Validation.addAllThese([
	['validate-Date-Interval', '日期起迄有誤', function( str_dt , end_dt , inputs ){
		if( !Validation.get('IsEmpty').test(str_dt) && !Validation.get('IsEmpty').test(end_dt) ){	//確認有輸入
			return diffDayY2K( str_dt , end_dt ) >= 0;
		}
		return true;
	}],
	['validate-ROCDate', '請輸入正確的民國日期格式', function(v,elem) {
		v = elem && elem.value || '';
		if( !Validation.get('IsEmpty').test(v) ){
			return isROCdate(v,false);
		}
		return true;
	}],
	['validate-ROCDate-Interval', '日期起迄有誤', function(str_dt , end_dt , inputs ) {
		str_dt = ( inputs && inputs[0] && inputs[0].value ) || '';
		end_dt = ( inputs && inputs[1] && inputs[1].value ) || '';
		if( !Validation.get('IsEmpty').test(str_dt) && !Validation.get('IsEmpty').test(end_dt) ){	//確認有輸入		
			return diffDayROC(str_dt, end_dt ) >= 0;
		}
		return true;
	}],
	['validate-DateYM', '請輸入正確之西元年月格式', function( v ) {
		return Validation.get('IsEmpty').test(v) || dateJs.isDateYM(v);
	}],
	['validate-ROCDateYM', '請輸入正確之民國年月格式', function( v ) {
		if(Validation.get('IsEmpty').test(v)){
			return true;
		}
		return dateJs.isDateYM(v, v.length<6);
	}]
]);

//必需使用 validation.js 才能使用的檢核 ( CM\js 下的)
Validation.addAllThese([
	['checkInputLength', '輸入值超出長度限制', function( v , element  ) {
		return validation.checkInputLength( v , element.maxLength );
	}],
	['checkUniSN', '統一編號格式有誤', function( v ) {
		return validation.checkUniSN( v );
	}],
	['hasFullType', '不可輸入半型文字', function( v ) {
		return !validation.hasHalfType( v );
	}],
	['hasHalfType', '不可輸入全型文字', function( v ) {
		return !validation.hasFullType( v );
	}],
	['checkROCID', '身份證字號格式錯誤', function( v ) {
		return validation.checkROCID( v );
	}],
	['checkROCPassport', '護照號碼格式錯誤', function( v ) {
		return validation.checkROCPassport( v );
	}],
	['checkROCARC', '居留證號碼格式錯誤', function( v ) {
		return validation.checkROCARC( v );
	}],
	['checkID', '證件格式錯誤', function( v ) {
		return validation.checkID( v );
	}]
])