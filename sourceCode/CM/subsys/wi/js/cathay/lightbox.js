
var lightbox = function(){

	var lightboxWrap_initClass = 'lightbox-wrap';

	var _imageBase;

	var _oriScrollTop;

	var _displayMessage = false;

	var _allInputValues = {};

	var oDiv_lightboxWrap;

	var setupPatch = function(){
		//set up the images base by css path
		var includeCSSs = document.getElementsByTagName('link');
		if(includeCSSs.length > 0){
			for(var i=0;i<includeCSSs.length;i++){
				var cssHref = includeCSSs[i].href;
				if(cssHref.indexOf('WI/js')>0){
					var cssHrefIndex = cssHref.indexOf('html');
					_imageBase = cssHref.substring(0, cssHrefIndex) + 'images';
					break;
				}
			}
		}
	};

	setupPatch();

	var putInputValue = function(k,v) {
		_allInputValues[k]=v;
	};

	var getAllInputValue = function(){
		// 取得 lightbox 所產生的 radio 內容
		$('.lightbox_Radio').each(function(){
			if(this.checked){
				putInputValue(this.name, this.value);
			}
		});
		return _allInputValues;
	};

	var fullPadValue = function(v){
		return v<10?'0'+v:v;
	};

	var createBirthday = function(opt){

		var showSpace = opt['showSpece'];
		if(!showSpace){
			return;
		}
		var minAge = opt['minAge']||20;
		var maxAge = opt['maxAge']||0;
		var birthdayValue = opt['value'];
		var changeFunc = opt['change'];
		var initFunc = opt['init'];

		if(maxAge!==0 && minAge>maxAge){
			maxAge=minAge;
		}

		var birthdayValue_year;
		var birthdayValue_month;
		var birthdayValue_day;

		if(birthdayValue){
			birthdayValue.match(/^(\d{4})-(\d{2})-(\d{2})$/) || (birthdayValue.match(/^(\d{4})\/(\d{2})\/(\d{2})$/));
			birthdayValue_year = RegExp.$1;
			birthdayValue_month = RegExp.$2;
			birthdayValue_day = RegExp.$3;
		}

		var oSelect_year = $('<select/>');
		var oSelect_month = $('<select/>');
		var oSelect_day = $('<select/>');

		var currentDay = new Date();
		var baseYear = currentDay.getFullYear();
		var currentYear = baseYear-minAge;

		var beginYear = maxAge==0?1911:baseYear-maxAge;

		for(var yi=beginYear;yi<=currentYear;yi++){
			oSelect_year.append($('<option/>').attr('value',yi).html(yi));
		}

		for(var mi=1;mi<=12;mi++){
            var sv = fullPadValue(mi);
			oSelect_month.append($('<option/>').attr('value',sv).html(sv));
		}

		var dayMapping = {'01':31, '03':31, '04':30, '05':31, '06':30, '07':31, '08':31, '09':30, '10':31, '11':30, '12':31};

		var changeDay = function(){
			oSelect_day.empty();
			var month = oSelect_month.val();
			var days = dayMapping[month];
			if(days){
				for(var di=1;di<=days;di++){
					var sv = fullPadValue(di);
					oSelect_day.append($('<option/>').attr('value',sv).html(sv));
				}
			}else{
				for(var di=1;di<=29;di++){
					if(di==29){
						var chkDate = new Date(oSelect_year.val(), month-1, di);
						if(chkDate.getMonth()+1!=month){// 若非閏年時，則不顯示 29 號
							break;
						}
					}
					var sv = fullPadValue(di);
					oSelect_day.append($('<option/>').attr('value',sv).html(sv));
				}
			}
		};

		var putValue_Birthday = function(){
			if(changeFunc){
				changeFunc(oSelect_year.val()+'-'+oSelect_month.val()+'-'+oSelect_day.val());
			}
		};

		oSelect_year.change(changeDay);
		oSelect_month.change(changeDay);

		oSelect_year.change(putValue_Birthday);
		oSelect_month.change(putValue_Birthday);
		oSelect_day.change(putValue_Birthday);

		showSpace
			.append($('<span/>').addClass('iselect').css('width','100px').append(oSelect_year))
			.append($('<span/>').html('年'))
			.append($('<span/>').addClass('iselect').css('width','100px').append(oSelect_month))
			.append($('<span/>').html('月'))
			.append($('<span/>').addClass('iselect').css('width','100px').append(oSelect_day))
			.append($('<span/>').html('日'));

		oSelect_year.val(currentYear);

		changeDay();
		putValue_Birthday();

		if(birthdayValue_year){
			oSelect_year.val(birthdayValue_year);
			oSelect_month.val(birthdayValue_month);
			oSelect_day.val(birthdayValue_day);
		}
		if(initFunc){
			initFunc(oSelect_year.val()+'-'+oSelect_month.val()+'-'+oSelect_day.val());
		}
	};

	var generateForm = function(inputOpt){

		var dateRegister = function(obj,datepickerOptions){

			var defaultOptions = {
		        numberOfMonths: 1,
		        minDate: 0,
		        gotoCurrent: true,
		        dateFormat: 'yy-mm-dd',
		        dayNames: [ '星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六' ],
		        monthNames: [ '1月', '2月', '3月', '4月', '5月', '6月', '7月','8月','9月','10月','11月','12月' ],
		        dayNamesMin: [ '日', '一', '二', '三', '四', '五', '六' ],
		        prevText: '上一月',
		        nextText: '下一月',
		        dateFormat:'yy/mm/dd',
		        beforeShow: function() {
		            $(this).datepicker('widget').wrap('<div class="datepicker" />');
		        }
				, onSelect: function (date) {
					putInputValue(obj.attr('name'), dateFormatToDB(date));
				}
				, onClose: function( selectedDate ) {
		        	obj.val(selectedDate);
					obj.trigger('blur');
				}
	    	};
			if(datepickerOptions){
				for(var attr in datepickerOptions){
					defaultOptions[attr]=datepickerOptions[attr];
				}
			}
			obj.datepicker(defaultOptions);
	    	return obj;
		};

		var columnsSetting = inputOpt['columnsSetting']||{};
		var labelScale = columnsSetting['labelScale']||25;
		var valueScale = columnsSetting['valueScale']||75;

	    var oForm = $('<form/>');

	    var oDiv_header = $('<div/>').addClass('header')
	    	.append($('<div/>').addClass('title').html(inputOpt['title']))
	    	.append($('<div/>').addClass('close').append('<a href="javascript:;"></a>'));

		var oDiv_body_table_tbody = $('<tbody/>');
		var oDiv_body = $('<div/>').addClass('body').append($('<table/>').append(oDiv_body_table_tbody));

	    var columns = inputOpt.columns;
	    for(var i=0;i<columns.length;i++){

	        var columnInfo = columns[i];

	        switch(columnInfo.type){
	        	case 'text':
	        		var oTr_oTd_oDiv = $('<div/>').addClass('field-tf');
					var oTr = $('<tr/>');
						oTr.append(
							$('<td/>').width(labelScale+'%').addClass('first align-mr').append(
								$('<div/>').addClass('field-tf item').append(
									$('<span/>').addClass('dark-green').html(columnInfo.label)
								)
							)
						).append(
							$('<td/>').width(valueScale+'%').addClass('align-ml').append(oTr_oTd_oDiv)
						);

					oTr_oTd_oDiv.append($('<span/>').html(columnInfo.value));

	                oDiv_body_table_tbody.append(oTr);

	            	break;

	        	case 'inputText':
	        		var oTr_oTd_oDiv = $('<div/>').addClass('field-tf');
					var oTr = $('<tr/>');
						oTr.append(
							$('<td/>').width(labelScale+'%').addClass('first align-mr').append(
								$('<div/>').addClass('field-tf item').append(
									$('<span/>').addClass('dark-green').html(columnInfo.label)
								)
							)
						).append(
							$('<td/>').width(valueScale+'%').addClass('align-ml').append(oTr_oTd_oDiv)
						);

					oTr_oTd_oDiv.append($('<input/>').attr({'type':'text','name':columnInfo.name}).val(columnInfo.value).change(function(){
						putInputValue(this.name, this.value);
					}));

	                oDiv_body_table_tbody.append(oTr);

	            	break;

	        	case 'password':
	        		var oTr_oTd_oDiv = $('<div/>').addClass('field-tf');
					var oTr = $('<tr/>');
						oTr.append(
							$('<td/>').width(labelScale+'%').addClass('first align-mr').append(
								$('<div/>').addClass('field-tf item').append(
									$('<span/>').addClass('dark-green').html(columnInfo.label)
								)
							)
						).append(
							$('<td/>').width(valueScale+'%').addClass('align-ml').append(oTr_oTd_oDiv)
						);

					oTr_oTd_oDiv.append($('<input/>').attr({'type':'password','name':columnInfo.name}).val(columnInfo.value).change(function(){
						putInputValue(this.name, this.value);
					}));

	                oDiv_body_table_tbody.append(oTr);

	            	break;

	        	case 'span':
	        		var tdClass = columnInfo.isPosLeft===true?'align-ml':'align-mc';
	        		var oSpan = $('<span/>').html(columnInfo.value);
					if(columnInfo.css){
	        			oSpan.css(columnInfo.css)
	        		}
	        		var oTr = $('<tr/>').append($('<td/>').attr('colspan','2').addClass('first '+tdClass).append(oSpan));
	                oDiv_body_table_tbody.append(oTr);
	            	break;

	            case 'radio':

					var oTr_oTd_oDiv = $('<div/>').addClass('field-tf');
					var oTr = $('<tr/>');
						oTr.append(
							$('<td/>').width(labelScale+'%').addClass('first align-mr').append(
								$('<div/>').addClass('field-tf item').append(
									$('<span/>').addClass('dark-green').html(columnInfo.label)
								)
							)
						).append(
							$('<td/>').width(valueScale+'%').addClass('align-ml').append(oTr_oTd_oDiv)
						);

					var eles = columnInfo.elements;
					var fieldName = columnInfo.name;
					var fieldValue = columnInfo.value;
	                var eltotal = eles.length;
	                for(var j=0;j<eltotal;j++){
	                	var ele = eles[j];
	                	var eleVal = ele.value;
	                	var oRadio = $('<input/>').attr({'type':'radio','name':fieldName}).addClass('lightbox_Radio').val(eleVal);

	                	var oLabel = $('<label/>');
	                	if(j>0){
	                		oLabel.css('margin-left','20px');
	                	}
	                	oLabel.append(oRadio).append(ele.label);

	                	oTr_oTd_oDiv.append(oLabel);

						if(!fieldValue && j==0){
							oRadio.attr('checked',true);
							
						}
	                	if(eleVal==fieldValue){
	                		oRadio.attr('checked',true);
	                	}

	                }
	                

	                oDiv_body_table_tbody.append(oTr);

	            	break;

	            case 'duration':

					var calculateTotalInfo = columnInfo['calculateTotal'];
					var minDateApart = columnInfo['minDateApart'];
					var endTimeDisplay = columnInfo['endTimeDisplay'];

					var isCalculateTotal = typeof calculateTotalInfo != 'undefined';

		            var oTr_first = $('<tr/>').addClass('duration');
						oTr_first.append(
							$('<td/>').width(labelScale+'%').addClass('first align-mr').attr('rowspan', isCalculateTotal?3:2).append(
								$('<div/>').addClass('field-tf item').append(
									$('<span/>').addClass('dark-green').html(columnInfo.label)
								)
							)
						);

					var dateFormatToDB = function(str){
						str.match(/^(\d{4})\/(\d{2})\/(\d{2})$/);
						return RegExp.$1+"-"+RegExp.$2+"-"+RegExp.$3;
					};

					var endTimeDiv;
					if(isCalculateTotal){
						endTimeDiv = $('<span/>').addClass('align-ml').css({'margin-left':'20px'});
					}

					var createField = function(opt_date, oTr){
/*
						日期
*/
						var dateValue = opt_date.value;
						var maxDate = opt_date.maxDate;
						if(dateValue){
							dateValue = dateValue.replace(/-/g,'/');
						}
						var datepickerOptions = {};
						if(maxDate){
							datepickerOptions['maxDate']=maxDate;
						}
						var domObj_inputDate = dateRegister($('<input/>').attr({'type':'text','name':opt_date.name,'readonly':true}).css({width:'100px','margin-left':'10px'}).val(dateValue), datepickerOptions);

						var oTrTdDiv = $('<div/>').addClass('field-tf')
								.append(opt_date.label)
	            				.append(domObj_inputDate);
	
						oTr.append($('<td/>').width(valueScale+'%').addClass('align-ml').append(oTrTdDiv));
						oDiv_body_table_tbody.append(oTr);

/*
						時間
*/
						var opt_time = opt_date.time;

						if(opt_time){
							var timeName = opt_time.name;
							var timeValue = opt_time.value;
							var domObj_time = $('<select/>').attr({'name':timeName}).css({width:'100px','margin-left':'10px'}).change(function(){
								putInputValue(this.name, this.value);
								endTimeDiv.html(this.options[this.selectedIndex].innerHTML);
							});

	                    	for(var hi=0;hi<24;hi++){
	                    		var showTime = fullPadValue(hi)+':00';
	                    		var getValue = showTime+':00';
	                    		var selectOpt = $('<option/>').attr('value',getValue).html(showTime);

	                    		domObj_time.append(selectOpt);
								if(getValue==timeValue){
	                    			selectOpt.attr('selected', true);
	                    		}
	                    	}
	                    	oTrTdDiv.append(domObj_time);
	                    	domObj_time.change();

						}else if(endTimeDiv){
							oTrTdDiv.append(endTimeDiv);
						}
						return domObj_inputDate;
					};

					var oTr_second = $('<tr/>').addClass('duration');

					var opt_begin = columnInfo['begin'];
					var opt_end = columnInfo['end'];

					var domObj_beginInputDate = createField(opt_begin, oTr_first);

					var domObj_endInputDate = createField(opt_end, oTr_second);

					oDiv_body_table_tbody.append(oTr_first);
					oDiv_body_table_tbody.append(oTr_second);

					var getRtnDate = function(str){
						str.match(/^(\d{4})-(\d{2})-(\d{2})$/) || (str.match(/^(\d{4})\/(\d{2})\/(\d{2})$/));
						return RegExp.$1+"-"+RegExp.$2+"-"+RegExp.$3;
					};

					if(isCalculateTotal){
						var oSpan_calculateTotal = $('<span/>').css({'margin':'0px 10px'}).html('0');
						oDiv_body_table_tbody.append(
							$('<tr/>').addClass('duration').append(
								$('<td/>').width(valueScale+'%').addClass('align-ml').append(
		                			$('<div/>').addClass('field-tf')
		                				.append('共')
		                				.append(oSpan_calculateTotal)
		                				.append('天')
		                		)
	                		)
	                	);

	                	var calculateTotalFunc = function(isBegin){
	                		var bv = domObj_beginInputDate.val();
	                		var ev = domObj_endInputDate.val();

	                		if(!bv || !ev){
	                			return;
	                		}

	                		var getTypeForDate = function(str){
	                			str.match(/^(\d{4})-(\d{2})-(\d{2})$/) || (str.match(/^(\d{4})\/(\d{2})\/(\d{2})$/));
	                			return new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
	                		};

	                		var beginVal = getTypeForDate(bv);
	                		var endVal = getTypeForDate(ev);
	                		var diffDay = (endVal-beginVal)/86400000;

							if(diffDay<minDateApart){

								var inInputObj;
								var changeInputObj;
								var addDays=0;

								if(isBegin){
									inInputObj = domObj_beginInputDate;
									changeInputObj = domObj_endInputDate;
									addDays+=minDateApart;
								}else{
									inInputObj = domObj_endInputDate;
									changeInputObj = domObj_beginInputDate;
									addDays-=minDateApart;
								}

								var date_inputObj = getTypeForDate(inInputObj.val());

								var tempDate = new Date();
									tempDate.setFullYear(date_inputObj.getFullYear());
									tempDate.setMonth(date_inputObj.getMonth());
									tempDate.setDate(date_inputObj.getDate()+addDays);
									
								var tempMonth = tempDate.getMonth() + 1;
								var tempDay = tempDate.getDate();

								var showValue=tempDate.getFullYear()+'/';

								if(tempMonth<10){
									showValue+='0';
								}
								showValue+=tempMonth+'/';

								if(tempDay<10){
									showValue+='0';
								}
								showValue+=tempDay;

								changeInputObj.val(showValue);
								diffDay = minDateApart;
							}

							oSpan_calculateTotal.html(diffDay);
							putInputValue(calculateTotalInfo['name'], diffDay);

							putInputValue(domObj_beginInputDate.attr('name'), getRtnDate(domObj_beginInputDate.val()));
							putInputValue(domObj_endInputDate.attr('name'), getRtnDate(domObj_endInputDate.val()));
	                	};

	                	domObj_beginInputDate.blur(function(){calculateTotalFunc(true);});
	                	domObj_endInputDate.blur(function(){calculateTotalFunc(false);});
	                	calculateTotalFunc();

					}

					putInputValue(domObj_beginInputDate.attr('name'), getRtnDate(domObj_beginInputDate.val()));
					putInputValue(domObj_endInputDate.attr('name'), getRtnDate(domObj_endInputDate.val()));

	            	break;
	
	            case 'birthday':

					var oTr_Div_content = $('<div/>').addClass('field-tf');
					var oTr = $('<tr/>').addClass('duration').append(
						$('<td/>').width(labelScale+'%').addClass('first align-mr').append($('<span/>').addClass('dark-green').html(columnInfo.label))
                		
            		).append(
						$('<td/>').width(valueScale+'%').addClass('align-ml').append(
                			oTr_Div_content.append($('<span/>').html(columnInfo.prefixLabel))
                		)
            		);

					var columnInfoName = columnInfo.name;
					createBirthday({showSpece:oTr_Div_content,value:columnInfo.value,change:function(rtnVal){
						putInputValue(columnInfoName, rtnVal);
					}, init:function(v){
						putInputValue(columnInfoName, v);	
					}});

					oDiv_body_table_tbody.append(oTr);

	            	break;

	        	case 'question':
	        		var tdClass = columnInfo.isPosLeft===true?'align-ml':'align-mc';
	        		var oTd = $('<td/>').attr('colspan','2').addClass('first '+tdClass);

	        		if(columnInfo.topicTitle){
	        			oTd.append($('<div/>').html(columnInfo.topicTitle.value).css({'padding':'30px 0px 20px 35px','color':'#008852','font-size':'18px'}));
	        		}

					var contentDiv = $('<div/>');
	        		if(columnInfo.topicContent){
						var topicContent = columnInfo.topicContent;
						for(var i=0;i<topicContent.length;i++){
							var tc = topicContent[i];
							var stepNum = tc.step;
							var topicOpts = tc.options;
							var topicSelectOpts = tc.selectOption;
							var isSelectOption = typeof topicSelectOpts != 'undefined';
							var isShowOptions = typeof topicOpts != 'undefined';

							var topicContentSpan = $('<span/>').html(tc.value).css({'padding':'0px 30px 20px 20px','vertical-align':'text-top','display':'-moz-inline-box'});
							if(isShowOptions && !isSelectOption){
								topicContentSpan.css({'width':'300px','display':'inline-block'});
							}

							contentDiv.append($('<span/>').css({'padding-left':'50px','vertical-align':'text-top'}).html(((stepNum||(i+1))+'.'))).append(topicContentSpan);

			        		if(isShowOptions){
			        			if(isSelectOption){
			        				contentDiv.append(
			        					$('<div/>').css({'padding':'10px 0px 0px 83px'})
			        						.append($('<span/>').append(tc.optionTitle))
			        						.append($('<span/>').css({'padding-left':'15px'}).append(topicSelectOpts.css({'width':'430px'})))
			        				);

									var descriptionStyle_borderColor_org = '#C2C2C2';
									var oDiv_description = $('<div/>').css({'padding':'10px','margin':'10px 0px 10px 83px','width':'475px','height':'200px','font-size':'15px','border':'1px solid '+descriptionStyle_borderColor_org});

			        				contentDiv.append(
			        					$('<div/>').css({'padding':'10px 0px 0px 83px'}).append($('<span/>').append('您是否從事以下職業？'))
			        				).append(oDiv_description);

									var buttonCSS = {'border':'1px solid #C2C2C2','width':'40px','height':'27px','display':'inline-block','line-height':'27px','font-size':'13px','color':'#004A2F','text-align':'center','white-space':'nowrap','margin':'0 20px'};

									var topicOptsSpace = $('<div/>');

									var noButton;

					        		for(var j=0;j<topicOpts.length;j++){
					        			var topicOpt = topicOpts[j];
					        			var mouseOverTips = topicOpt['mouseOverTips'];
					        			var topicOptSpan = $('<span/>').css(buttonCSS).html('<b>'+topicOpt.text+'</b>');
					        			var tcf = topicOpt.clickFunction;
					        			if(tcf){
					        				topicOptSpan.css({'cursor':'pointer'}).click(tcf);
					        			}
					        			if(mouseOverTips){
					        				topicOptSpan.attr('mouseOverTips',mouseOverTips);
					        			}
					        			if(j==1){
					        				noButton = topicOptSpan;
					        			}
										topicOptsSpace.append(topicOptSpan);
					        		}

									contentDiv.append(topicOptsSpace.css({'padding':'20px 60px 0px 83px','text-align':'center'}));

			        				topicSelectOpts.change(function(){
										var oSelPts = topicSelectOpts.children();
										for(var i=0;i<oSelPts.length;i++){
											var oSelPt = $(oSelPts[i]);
											var org_jobClass = oSelPt.attr('org_jobClass');
											if(org_jobClass){
						        				oSelPt.attr('jobClass',oSelPt.attr('org_jobClass'));
						        				oSelPt.attr('group',oSelPt.attr('org_group'));
						        				oSelPt.attr('overprint',oSelPt.attr('org_overprint'));
						        				oSelPt.removeAttr('org_jobClass');
						        				oSelPt.removeAttr('org_group');
						        				oSelPt.removeAttr('org_overprint');
											}
										}
			        					var selectedOpt = $(this.options[this.selectedIndex]);
			        					if(selectedOpt.attr('jobClass')==''){
			        						oDiv_description.html('');
			        						return;
					        			}

			        					var selectedDesc = selectedOpt.attr('description')||'';
			        					oDiv_description.html(selectedDesc);

										var hasBackInit = selectedOpt.attr('backInit')==='true';
										if(hasBackInit){
											topicSelectOpts.addClass('questionBackInit');
										}else{
											topicSelectOpts.removeClass('questionBackInit');
										}

					        			if(noButton){

					        				var mouseOverEventRegister = function(isRegister){
												if(isRegister){
													var mouseOverTips = noButton.attr('mouseOverTips');
													if(mouseOverTips){
								        				var orgContent;
								        				noButton.hover(
															function(){
																orgContent = oDiv_description.html();
																oDiv_description.css({'border-color':'red','background-color':'#F2F5A9','color':'red'});
																oDiv_description.html(mouseOverTips);
															}
															, function(){
																oDiv_description.css({'border-color':descriptionStyle_borderColor_org,'background-color':'','color':''});
																oDiv_description.html(orgContent);
															}
														);
													}
												}else{
													noButton.unbind('mouseenter mouseleave click');
												}
					        				};

											mouseOverEventRegister(hasBackInit);

					        				noButton.click(function(event){

					        					var selectedOpt;
												var oSelPts = topicSelectOpts.children();
												for(var i=0;i<oSelPts.length;i++){
													var oSelPt = oSelPts[i];
													if(oSelPt.selected){
														selectedOpt = oSelPt;
														break;
													}
												}

												if(!selectedOpt){
													return;
												}

												selectedOpt = $(selectedOpt);
												if(selectedOpt.attr('jobClass')==''){
													topicSelectOpts.removeClass('questionBackInit');
													return;
												}

					        					var isBack = topicSelectOpts.hasClass('questionBackInit');

						        				if(isBack){
						        					mouseOverEventRegister(false);
													topicSelectOpts.removeClass('questionBackInit');
													topicSelectOpts.val('');
													oDiv_description.css({'border-color':descriptionStyle_borderColor_org,'background-color':'','color':''}).html('');
													noButton.unbind('click');
													return;
						        				}
						        				selectedOpt.attr('org_jobClass',selectedOpt.attr('jobClass'));
						        				selectedOpt.attr('org_group',selectedOpt.attr('group'));
						        				selectedOpt.attr('org_overprint',selectedOpt.attr('overprint'));
						        				selectedOpt.attr('jobClass',selectedOpt.attr('chooseNoOption_jobClass'));
						        				selectedOpt.attr('group',selectedOpt.attr('chooseNoOption_group'));
						        				selectedOpt.attr('overprint',selectedOpt.attr('chooseNoOption_overprint'));
						        				topicSelectOpts.addClass('questionBackInit');
						        				oDiv_description.html(selectedOpt.attr('chooseNoOption_description'));
						        				mouseOverEventRegister(true);
					        				});

					        			}
			        				});

			        			}else{
					        		for(var j=0;j<topicOpts.length;j++){
					        			var topicOpt = topicOpts[j];
					        			var topicOptSpan = $('<span/>').css({'padding':'0px 20px','vertical-align':'text-top','width':'20px','display':'inline-block','white-space':'nowrap','cursor':'pointer'}).html(topicOpt.text);
					        			if(topicOpt.clickFunction){
					        				topicOptSpan.click(topicOpt.clickFunction);
					        			}
										contentDiv.append(topicOptSpan);
					        		}
			        			}
			        		}
						}								
	        		}
	        		contentDiv.css({'padding-bottom':'20px'});
	        		var oTr = $('<tr/>').append(oTd.append(contentDiv));
	                oDiv_body_table_tbody.append(oTr);
	            	break;

	        }

	    }

		oForm.append(oDiv_header).append(oDiv_body);

/*
		按鈕
*/
		var buttons = inputOpt.buttons;
		if(buttons){
			var oDiv_footer_ul = $('<ul/>').addClass('clearfix');
		    var oDiv_footer = $('<div/>').addClass('action').append(oDiv_footer_ul);
		    for(var i=0;i<buttons.length;i++){
		    	var buttonInfo = buttons[i];
		        oDiv_footer_ul.append($('<li/>')
		        	.append(
		        		$('<a/>').attr('href','javascript:;').addClass('btn green caculator').css('text-decoration','none').click(function(){
							if(buttonInfo.clickAction(getAllInputValue())){
								_displayMessage = false;
								closeLightbox();
							}
			        	}).append('<i class=iconClass"></i>'+buttonInfo.label)
		        	)
		        );
		    }
		    oForm.append(oDiv_footer);
		}

		if(inputOpt.disaplyServiceLine===true){
			oForm.append(
				$('<div/>').addClass('infobox-footer')
					.append(
						$('<ul/>').addClass('serviceline')
							.append('<li><img alt="一般客服專線" src="'+_imageBase+'/WI/wbis/serviceline-general.png"></li>')
							.append('<li><img alt="VIP客服專線" src="'+_imageBase+'/WI/wbis/serviceline-vip.png"></li>')
							.append('<li><img alt="海外諮詢專線" src="'+_imageBase+'/WI/wbis/serviceline-international.png"></li>')
					)
			);
		}

	    return oForm;

	};

	var closeLightbox = function(forceClose){
		if(forceClose===true){
			_displayMessage=false;
		}
	    if(_displayMessage){
	    	return;
	    }
	    var lightbox = $('.lightbox');
	    if(lightbox.css('visibility')=='hidden'){
	    	return;
	    }
	    if(window.TweenMax){
	    	TweenMax.to(window, .5, { scrollTo: { y:_oriScrollTop, ease: Sine.easeOut } });
	    }
	    lightbox.css('visibility','hidden');
	    _oriScrollTop = 0;
	    $('.lightbox .'+lightboxWrap_initClass).removeAttr('class').addClass(lightboxWrap_initClass);
	    if(oDiv_lightboxWrap && !oDiv_lightboxWrap.hasClass(lightboxWrap_initClass)){
	    	oDiv_lightboxWrap.addClass(lightboxWrap_initClass);
		}
	};

	function displayLightbox(a_obj){
		window.focus();
		_allInputValues = {};
		var type = a_obj['type']||'';
		var canClose = a_obj['canClose'] !== false;
		var extOptions = a_obj['extOptions']||{};
	    var contentHTML;

	    switch(type){
	        case 'msg':
	        	_displayMessage = true;
	            contentHTML = a_obj.html;
	        break;
	        case 'html':
	            contentHTML = a_obj.html;
	        break;

	        case 'json':
	            contentHTML = generateForm(a_obj);
	        break;

	        case 'custom':
	            var _closeClass='';
	            if(a_obj.closeClass != undefined){
	                _closeClass = a_obj.closeClass;
	            }
	            contentHTML = a_obj.html +'<div class="close"><a href="javascript:;" class='+_closeClass+'></a></div>';
	        break;

	        case 'popSavingProgress':
	        	$.fancybox.open('#popSavingProgress');
			return;

			case 'popClaimOption':
	        	$.fancybox.open('#popClaimOption');
	        return;

	    }

	    var scope = $('.lightbox .'+lightboxWrap_initClass).html(contentHTML);
		var addLightboxWrapClass = extOptions['lightboxWrapClass'];
		if(addLightboxWrapClass!=undefined){
        	scope.addClass(addLightboxWrapClass);
		}

		if(scope.iCheck){
		    $(':checkbox', $(".lightbox ."+lightboxWrap_initClass)).iCheck({checkboxClass: 'icheckbox'});
		    $(':radio', $(".lightbox ."+lightboxWrap_initClass)).iCheck({checkboxClass: 'iradio'});
		    $('select', $(".lightbox ."+lightboxWrap_initClass)).each(function() {
		        var o = $(this),
				w = parseInt(o.css('width')) || 100,
				iselect, toggle;

		        o.wrap('<span class="iselect" />');
		        iselect = o.parent();

				iselect.css('width', w );
				o.css('width', w + 20);

				toggle = $('<i />').appendTo(iselect);

		        // avoid text overlaps <i>
		        iselect.on('mouseenter', function(){
		            toggle.css('z-index', 1);
		        }).on('mouseleave', function(){
		            toggle.css('z-index', '');
		        });
		    });
		}

		var handlerClickEventObjs = $(".lightbox .close,.lightbox .bg,.lightbox a.close");
		handlerClickEventObjs.unbind("click");
		if(canClose){
		    handlerClickEventObjs.bind("click",function(){
		    	_displayMessage = false;
		        closeLightbox();
		    });
		}else{
			_displayMessage = false;
		}

	    _oriScrollTop = $(window).scrollTop();
	    var contentH = $("."+lightboxWrap_initClass).height();
	    var screenH = $(window).height();
	    var screenW = $(window).width();
	    if(screenH>contentH){
	        $("."+lightboxWrap_initClass).css('position','fixed').css('top',(screenH-contentH)/2).css('left',(screenW-700)/2);
	    }else{
	        $("."+lightboxWrap_initClass).css('margin-top',30).css('position','relative').css('top','auto').css('left','auto');
	    }

	    if($("html").hasClass("lt-ie9")){
	        $(".lightbox").css('display','block');
	        $(".lightbox").css('visibility','visible');
	    }else{
	        $(".lightbox").css('display','none');
	        $(".lightbox").css('visibility','visible');
	        $(".lightbox").fadeIn('fast');
	    }
	}

    var sectionClass = "wbis-main";
    if($('.lightbox.'+sectionClass).length==0){
    	oDiv_lightboxWrap = $('<div class="'+lightboxWrap_initClass+'">');
        $('body').append(
        	$('<div class="lightbox '+sectionClass+'" style="margin:0;"/>')
        		.append($('<div class="bg"/>'))
        		.append(oDiv_lightboxWrap)
        );
    }

	return {
		windowFunctionRegister: function(){
			window['displayLightbox']=displayLightbox;
			window['closeLightbox']=closeLightbox;
			window['resetLightboxOriScrollTop']=function(){
				_oriScrollTop = 0;
			};
			window['lightboxForCreateBirthday']=createBirthday;
		}
	};
};