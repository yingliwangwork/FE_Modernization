(function() {

	console.log("slry_page.js function 1 start");
	
	/*
	����撠雿
	*/
	var floatDecimal = 8;
	/*
	��憭扯撓�亙��訾���
	*/
	var inputFloatDecimal = 2;
	var floatMax = parseInt('1' + Array(floatDecimal + 1).join('0'));
	if (!String.prototype.format) {
		String.prototype.format = function() {
			var args = arguments;
			return this.replace(/{(\d+)}/g, function(match, number) { 
				return typeof args[number] != 'undefined' ? args[number] : match;
			});
		};
	}
	var padRight = function(/*String*/str) {
		return (str + Array(floatDecimal + 1).join('0')).substring(0, floatDecimal);
	};
	var isInteger = function(/*String*/ str) {
		return /^\d+$/.test(str);
	};
	
	var NumberChecker = function(/*String*/str) {
		str = str.trim();
		if ('-' === str.charAt(0)) {
			this.error = '<fmt:message key="FKA_UI_0014" /><%--���箸迤��-%>';
			return;
		}
		var tmp = str.split('\.');
		if (tmp.length >= 1) {
			if (isInteger(tmp[0])) {
				this.intPart = tmp[0];
				if (tmp.length == 2) {
					if (isInteger(tmp[1])) {
						if (tmp[1].length > inputFloatDecimal) {
							this.error = '<fmt:message key="FKA_UI_0015" /><%--�頛詨撠{0}雿�-%>'.format('' + inputFloatDecimal);
						} else {
							this.floatPart = tmp[1];
						}
					} else {
						this.error = '<fmt:message key="FKA_UI_0016" /><%--���箸摮�-%>';
					}
				} else if (tmp.length > 2) {
					this.error = '<fmt:message key="FKA_UI_0016" /><%--���箸摮�-%>';
				}
			} else {
				this.error = '<fmt:message key="FKA_UI_0016" /><%--���箸摮�-%>';
			}
		} else {
			this.error = '<fmt:message key="FKA_UI_0016" /><%--���箸摮�-%>'; 
		}
	};

	var BigDecimal = function(/*BigDecimal || String*/numberObj, /*boolean || undefine*/ allowMoneyFormat) {
		if (typeof numberObj === 'string') {
			if(allowMoneyFormat) {
				numberObj = numberObj.replace(/,/ig, '');
			}
			var checker = new NumberChecker(numberObj);
			if (checker.error) {
				this.errMsg = checker.error;
			} else {
				this.intPart = parseInt(checker.intPart, 10);
				this.floatPart = checker.floatPart ? parseInt(padRight(checker.floatPart), 10) : 0;
			}
		} else {
			if (numberObj.errMsg) {
				this.errMsg = numberObj.errMsg;
			} else {
				this.intPart = numberObj.intPart;
				this.floatPart = numberObj.floatPart;
			}
		}
	};
	
	BigDecimal.prototype.add = function(/*BigDecimal || String*/numberObj) {
		if (typeof numberObj === 'string') {
			numberObj = new BigDecimal(numberObj);
		}
		if (this.errMsg) {
			return this;
		} else if (numberObj.errMsg) {
			return numberObj;
		} else {
			var ret = new BigDecimal('0');
			ret.intPart = this.intPart + numberObj.intPart;
			ret.floatPart = this.floatPart + numberObj.floatPart;
			if (ret.floatPart >= floatMax) {
				ret.intPart += 1;
				ret.floatPart -= floatMax;
			} else if (ret.floatPart < 0) {
				ret.intPart -= 1;
				ret.floatPart += floatMax;
			}
			return ret;
		}
	};
	BigDecimal.prototype.toNumber = function() {
		if (this.errMsg) {
			return this.errMsg;
		}
		return this.intPart + (this.floatPart ? (this.floatPart / floatMax) : 0);
	};
	BigDecimal.prototype.hasError = function() {
		if (this.errMsg) {
			return true;
		}
		return false;
	};
	BigDecimal.prototype.toString = function() {
		return '' + this.toNumber();
	};
	BigDecimal.prototype.toMoneyFormat = function() {
		if (this.errMsg) {
			return this.errMsg;
		}
		return this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
	};
	BigDecimal.prototype.equals = function(/*String || Number || BigDecimal*/numberObj) {
		var clazz = typeof numberObj;
		if (clazz === 'string') {
			numberObj = new BigDecimal(numberObj);
		} else if (clazz === 'number') {
			numberObj = new BigDecimal(numberObj + '');
		}
		if (this.errMsg || numberObj.errMsg) {
			return false;
		}
		return numberObj.intPart === this.intPart && numberObj.floatPart === this.floatPart;
	};
	window.BigDecimal = function(/*String*/numberObj, /*boolean || undefine*/ allowMoneyFormat) {
		return new BigDecimal(numberObj, allowMoneyFormat);
	};
	window.setBigDecimalAllowFloatDecimal = function(/*int*/ num) {
		inputFloatDecimal = num;
	};
	
	console.log("slry_page.js function 1 end");
})();

//�牡ata-name �誨name�臬���瑼Ｘ憟辣雿輻name.��銝��. 銝��BUG
(function() {
	console.log("slry_page.js function 2 start");
	
	/**
	 * 撱箇�Ｚ�鞈�
	 */
	var buildHtml = function(gearSlryListBuilder) {
		buildBaseSlry(gearSlryListBuilder);
		buildFixedSlry(gearSlryListBuilder);
		
		//靘璅∪�隤踵�恍
		removeUnnecessaryChildren($('#slry_SlrySum', gearSlryListBuilder.$coreTable), gearSlryListBuilder);
		
		setValue($('#slry_totalSlryCurrSum', gearSlryListBuilder.$coreTable), gearSlryListBuilder.slryData.currTotalSlryAmt);
		if(gearSlryListBuilder.slryData.editMode === 'N') {
			setValue($('#slry_totalSlryNewSum', gearSlryListBuilder.$coreTable), gearSlryListBuilder.slryData.newTotalSlryAmt);
		}
	};
	
	/**
	 * 蝬�隞�
	 */
	var binding = function(/*class obj*/ gearSlryListBuilder, /*jQuery || undefined*/ $trElm) {
		if(gearSlryListBuilder.slryData.editMode === 'N') {
			return $trElm;
		}
		
		//�箸��
		if(!$trElm) {
			$('.slry_baseSlryData', gearSlryListBuilder.$coreTable).each(function() {
				var $tr = $(this);
				$('input[data-name=AMT]', $tr).addClass('slry_baseSlryAmt').on('blur', function() {
					setValue($('#slry_baseSlryNewSum', gearSlryListBuilder.$coreTable), sumBaseAmt(gearSlryListBuilder.$coreTable).toString());
				});
			});
		}
		//�箏���
		if(!$trElm) {
			$trElm = $('.slry_fixedSlryData', gearSlryListBuilder.$coreTable);
		}
		
		$trElm.each(function() {
			var $tr = $(this);
			//蝞蜇��
			$('input[data-name=AMT]', $tr).addClass('slry_fixedSlryAmt').on('blur', function() {
				setValue($('#slry_fixedSlryNewSum', gearSlryListBuilder.$coreTable), sumFixedAmt(gearSlryListBuilder.$coreTable).toString());
			});
			//�⊿���
			$('input[data-name=UNLIMIT]', $tr).on('click', function(){
				var $this = $(this);
				var $input = $('input[data-name=GET_TIMES]', $this.closest('td'));
				if($this.prop('checked')) {
					$input.data('val', $input.val()).prop('readonly', true).val('-1');
				} else {
					$input.prop('readonly', false).val($input.data('val'));
				}
			});
			//����
			$('input[data-name=CANCLE]', $tr).on('click', function(){
				var $this = $(this);
				var $tr = $this.closest('tr');
				if($this.prop('checked')) {
					$tr.addClass('disabled');
					$('input,select', $tr).each(function(){
						var $input = $(this);
						if($input.attr('data-name') !== 'CANCLE') {
							$input.addClass('disabled').prop('disabled', true);
						}
					});
				} else {
					$tr.removeClass('disabled');
					$('input,select', $tr).each(function(){
						var $input = $(this);
						$input.removeClass('disabled').prop('disabled', false);
					});
				}
				setValue($('#slry_fixedSlryNewSum', gearSlryListBuilder.$coreTable), sumFixedAmt(gearSlryListBuilder.$coreTable).toString());
			});
		});
		return $trElm;
	};
	
	/**
	 * 蝬�霅�
	 */
	var initValidator = function(/*class obj*/ gearSlryListBuilder, /*jQuery || undefined*/ $trElm, debug) {
		if(gearSlryListBuilder.slryData.editMode === 'N') {
			return $trElm;
		}
		//閬�
		if(!$trElm) {
			$.validator.addMethod('checkRange', function(value, element) {
				//var $elm = $(element);
				return true;
			}, '');
			
			$.validator.addMethod('checkMoney', function(value, element) {
				var $elm = $(element);
				var amt = BigDecimal($elm.val());
				if(amt.hasError()) { 
					$elm.data('checkMsg', amt.toString());
					return false;
				}
				return true;
			}, function(params, element) {
				  return $(element).data('checkMsg');
			});
			$.validator.addMethod('checkSumEquals', function(value, element) {
				var baseSlryNewSum = $('#slry_baseSlryNewSum', gearSlryListBuilder.$coreTable).text() || '0';
				var fixedSlryNewSum = $('#slry_fixedSlryNewSum', gearSlryListBuilder.$coreTable).text() || '0';
				var sum = BigDecimal(baseSlryNewSum, true).add(BigDecimal(fixedSlryNewSum, true));
				var $elm = $(element);
				if(!sum.equals($elm.val())) {
					var msg = sum.hasError() ? '<fmt:message key="FKA_UI_0017" /><%--�嗡����炊--%>' : '<fmt:message key="FKA_UI_0018" /><%--�芾���銝蝑�蝟餌絞閮�銋�閮�潛 :{0}--%>'.format(sum.toString());
					$elm.data('checkMsg', msg);
					return false;
				}
				return true;
			}, function(params, element) {
				  return $(element).data('checkMsg');
			});
			
			$.validator.addMethod('checkGetTimes', function(value, element) {
				var $elm = $(element);
				var val = $elm.val();
				var intVal = parseInt(val, 10);
				if(val === '' + intVal) {
					if(intVal >= 0) {
						return true;
					}
					if(intVal === -1) {
						if($('input[data-name=UNLIMIT]', $elm.closest('td')).prop('checked')) {
							return true;
						}
					}
					$(element).data('checkMsg', '<fmt:message key="FKA_UI_0019" /><%--���箸迤�湔--%>');
				}
				$(element).data('checkMsg', '<fmt:message key="FKA_UI_0019" /><%--���箸迤�湔--%>');
				return false;
			}, function(params, element) {
				  return $(element).data('checkMsg');
			});
			
			gearSlryListBuilder.$coreTable.closest('form').validate({
				onfocusout: false
			});
			
			$('#slry_totalSlryNewSum', gearSlryListBuilder.$coreTable).rules('add', {
				required: true,
				checkMoney: true,
				checkSumEquals: true
			});
		}

		//�箸��
		if(!$trElm) {
			$('.slry_baseSlryData', gearSlryListBuilder.$coreTable).each(function() {
				var $tr = $(this);
				//��
				$('input[data-name=AMT]', $tr).rules('add', {
					required: true,
					checkMoney	: true
				});	
			});
		}
		
		//�箏���
		if(!$trElm) {
			$trElm = $('.slry_fixedSlryData', gearSlryListBuilder.$coreTable);
		}
		$trElm.each(function() {
			var $tr = $(this);
			//��
			$('input[data-name=AMT]', $tr).rules('add', {
				required: true,
				checkMoney	: true
			});
			//�芣揖隞��
			$('select[data-name=SLRY_CODE]', $tr).rules('add', {
				required: true
			});
			//蝮賣活��
			$('input[data-name=GET_TIMES]', $tr).rules('add', {
				required: true,
				checkGetTimes: true
			});
		});
		return $trElm;
	};
	
	/**
	 * 撱箇��箸�芸�憛�
	 */
	var buildBaseSlry = function(gearSlryListBuilder) {
		
		var $coreTable = gearSlryListBuilder.$coreTable;
		$('tr[class="slry_baseSlryData"]', $coreTable).remove();
		
		//�箸�芣見��
		var $template = $('#slry_baseSlryData', $coreTable);
		if ($template.length != 0) {
			gearSlryListBuilder.templates['slry_baseSlryData'] = $('<span>').append($template.removeAttr('id').addClass('slry_baseSlryData').show()).html();
			$template.remove();
		}
		
		//�箸�芣���
		var $beforeElm = removeUnnecessaryChildren($('#slry_baseSlryTitle', gearSlryListBuilder.$coreTable), gearSlryListBuilder);
		
		if (gearSlryListBuilder.templates && gearSlryListBuilder.templates['slry_baseSlryData']) {
			$.each(gearSlryListBuilder.slryData.baseSlryList, function(idx, data) {
				$beforeElm = removeUnnecessaryChildren(
					$(gearSlryListBuilder.templates['slry_baseSlryData'].replace(/$\{(.*?)\}/g, function(matchStr, key) {
						var keys = key.split(':');
						if (keys.length == 3) {
							return setValue(null, (data[keys[2]] || ''), keys[0], keys[1]);
						}
						return data[key] || '';
					})).data('vo', data)
				, gearSlryListBuilder, true).insertAfter($beforeElm);
			});
		}
		
		//�箸�芸�閮�
		setValue($('#slry_baseSlryCurrSum', $coreTable), gearSlryListBuilder.slryData.currBaseSlryAmt);
		setValue($('#slry_baseSlryNewSum', $coreTable), gearSlryListBuilder.slryData.newBaseSlryAmt);
	};
	
	/**
	 * 撱箇��箏��芸�憛�
	 */
	var buildFixedSlry = function(gearSlryListBuilder) {
		
		var $coreTable = gearSlryListBuilder.$coreTable;
		$('tr[class="slry_fixedSlryData"]', $coreTable).remove();
		
		//�箏��芣見��
		var $template = $('#slry_fixedSlryData', $coreTable);
		if($template.length != 0) {
			gearSlryListBuilder.templates['slry_fixedSlryData'] = $('<span>').append($template.removeAttr('id').addClass('slry_fixedSlryData').show()).html();
			$template.remove();
		}
		
		//�箏��芣���
		var $beforeElm = removeUnnecessaryChildren($('#slry_fixedSlryTitle', gearSlryListBuilder.$coreTable), gearSlryListBuilder);
		if (gearSlryListBuilder.templates && gearSlryListBuilder.templates['slry_fixedSlryData']) {
			$.each(gearSlryListBuilder.slryData.fixedSlryList, function(idx, data) {
				$beforeElm = removeUnnecessaryChildren(
					$(gearSlryListBuilder.templates['slry_fixedSlryData'].replace(/$\{(.*?)\}/g, function(matchStr, key) {
						var keys = key.split(':');
						if(keys.length == 3) {
							return setValue(null, (data[keys[2]] || ''), keys[0], keys[1]);
						}
						return data[key] || '';
					})).data('vo', data)
				, gearSlryListBuilder, true).insertAfter($beforeElm);
			});
		}
		//�箏��芸�閮�
		setValue($('#slry_fixedSlryCurrSum', $coreTable), gearSlryListBuilder.slryData.currFixedSlryAmt);
		setValue($('#slry_fixedSlryNewSum', $coreTable), gearSlryListBuilder.slryData.newFixedSlryAmt);
	};
	
	/**
	 * ����閮ata-type �lment, 靘�桀��舫＊蝷箸芋撘�蝺刻摩璅∪�,蝘駁銝�閬�摮lement
	 * @param $tr ��撠情
	 * @param needChangeName �臬��閬name, �html�迂���ame,撽�憟辣銝�湧�閬�name. �演rue����name撖怠 data-name,銝血��ame蝯虫�瘚偌��
	 */
	var removeUnnecessaryChildren = function(/*jQuery*/ $tr, /*class obj*/ gearSlryListBuilder, /*boolean*/ needChangeName) {
		var removeModeName = 'Y' === gearSlryListBuilder.slryData.editMode ? 'display' : 'edit';
		++gearSlryListBuilder.trCnt;
		$tr.children().each(function() {
			var $td = $(this);
			var type = $td.data('type') || '';
			if(type === removeModeName) {
				$td.remove();
			} else if(type !== '') {
				$td.removeAttr('data-type').show();
			}
			
			//name 蝯夷ndex
			if(needChangeName) {
				$('input,select', $td).each(function() {
					var $input = $(this);
					var name = $input.attr('name') || '';
					if(name !== '') {
						$input.attr('data-name', name);
						$input.attr('name', name + gearSlryListBuilder.trCnt);
					}
				});
			}
		});
		
		initWithDefine($tr, gearSlryListBuilder);
		return $tr;
	};
	
	/**
	 * ���桀�雿輻銝剔�SLRY_CODE, 銝��砍�亦�SLRY_CODE
	 * @param currSlryCode �桀��LRY_CODE
	 */
	var hasTheSameSlryCode = function(/*jqery*/$currSelect, $coreTable) {
		var ret = false;
		
		var currSlryCode = $currSelect.val();
		if(!currSlryCode ||currSlryCode == '') {
			return ret;
		}

		$('tr', $coreTable).each(function() {
			var $tr = $(this);
			var vo = $tr.data('vo');
			var srlyCode = '';
			if(vo) {
				srlyCode = vo['SLRY_CODE'];
			} else {
				var $slryCodeElm = $('select[data-name=SLRY_CODE]', $tr);
				if($slryCodeElm.length == 1 && $slryCodeElm[0] !== $currSelect[0]) {
					srlyCode = $slryCodeElm.val();
				}
			}
			if(srlyCode && srlyCode !='' && currSlryCode === srlyCode) {
				ret = true;
				return false;
			}
		});
		return ret;
	};
	
	/**
	 * 靘摰儔蝬�蝭����� 銋停�舐�Ｙ��脤憛�
	 * @param $tr 撠情
	 */
	var initWithDefine = function(/*jQuery*/ $tr, gearSlryListBuilder) {
		if(gearSlryListBuilder.slryData.chgSrc !== '3') {
			var vo = $tr.data('vo') || {};
			var slryDefine = null;
			if($tr.hasClass('slry_baseSlryData')) {
				slryDefine = gearSlryListBuilder.slryData.baseSlryDefineMap[vo['SLRY_CODE']];
			} else if($tr.hasClass('slry_fixedSlryData')) {
				var srlyCode = vo['SLRY_CODE'] || $('select[data-name=SLRY_CODE]', $tr).val();
				slryDefine = gearSlryListBuilder.slryData.fixedSlryDefineMap[srlyCode];
			}
			
			if(slryDefine) {
				var amt1 = slryDefine['AMT_1'];
				var amt2 = slryDefine['AMT_2'];
				if(amt1) {//�嗆�銝�����
					var $amtElm = $('input[data-name=AMT]', $tr);
					if('0' === slryDefine['IS_MOD']) {
						$amtElm.val(amt1).prop('readonly', true);
					} else if('Y' === slryDefine['IS_CHECK']) {
						$amtElm.after($('<span>', {'class':'txtRed2 ml10 limitMsg'}).text('<fmt:message key="FKA_UI_0020" /><%--撱箄降��{0}~${1}--%>'.format(BigDecimal(amt1).toString(), BigDecimal(amt2).toString())));
					}	
				}
			}	
		}
		return $tr;
	};
	
	/**
	 * �澆���頛詨
	 * @param $elm ��撠情, null�� �寞����喟��� �ull�� ���扳SPAN�撓�交��‵��
	 * @param val ���
	 * @param format val �臭�暻潮��� ��elm ��data-format. �臭蝙�肚money,times,gottimes,cancle} or undefined
	 * @param tagName val �臭�暻潭�蝐� ��elm ��data-tagName. �臭蝙�肚SPAN} or undefined
	 */
	var setValue = function(/*jQuery || null*/ $elm, /*String || BigDecimal*/ val, /*String || undefined*/ format, /*String || undefined*/tagName) {
		if(!format) {
			tagName = $elm.prop("tagName");
			format = $elm.data('format') || '';
		}
		if('SPAN' === tagName) {
			if(!val || val === '') {
				val = '-';
			} else {
				if('money' === format) {
					val = val.toMoneyFormat ? val.toMoneyFormat() : BigDecimal(val).toMoneyFormat();
				} else if('times' === format) {
					val = '-1' == val ? '<fmt:message key="FKA_UI_0011" /><%--銝�--%>' : val;
				} else if('gottimes' === format) {
					val = '-1' == val ? '-' : val;
				} else if('cancle' === format) {
					val = { 'I': '<fmt:message key="FKA_UI_0022" /><%--�啣�--%>', 
							'U': '<fmt:message key="FKA_UI_0023" /><%--靽格--%>',
							'C': '<fmt:message key="FKA_UI_0024" /><%--���啣�--%>',
							'D': '<fmt:message key="FKA_UI_0025" /><%--�芷--%>',
							'N': '<fmt:message key="FKA_UI_0026" /><%--�芾���-%>'
							}[val||''] || '-';
				}
			}
		}
		if($elm) {
			$elm = 'SPAN' === tagName ? $elm.html(val) : $elm.val(val);
		}
		return val;
	};
	
	/**
	 * ���hecked ��
	 */
	var initJsChecked = function($coreTable) {
		$('input[data-name=GET_TIMES][value=-1]', $coreTable).each(function(){
			$('input[data-name=UNLIMIT]', $(this).closest('td')).prop('checked', true).click().prop('checked', true);//銝��箔�銝�見撖急�銝���
		});
	};
	
	/**
	 * 閮��箸�芰蜇��
	 */
	var sumBaseAmt = function($coreTable) {
		var sum = BigDecimal('0');
		$('.slry_baseSlryAmt', $coreTable).each(function() {
			var $input = $(this);
			if(!$input.prop('disabled')) {
				var val = $input.val() === '' ? '0' : $input.val(); 
				sum = sum.add(val);
			}
		});
		return sum;
	};
	
	/**
	 * 閮��箏��芰蜇��
	 */
	var sumFixedAmt = function($coreTable) {
		var sum = BigDecimal('0');
		$('.slry_fixedSlryAmt', $coreTable).each(function() {
			var $input = $(this);
			if(!$input.prop('disabled')) {
				var val = $input.val() === '' ? '0' : $input.val(); 
				sum = sum.add(val);	
			}
		});
		return sum;
	};
	
	/**
	 * ���極雿�
	 * @param inputSlryData SlryInfo
	 */
	var init = function(/*Json*/ inputSlryData, /*class obj*/ gearSlryListBuilder) {
		if(!inputSlryData['editMode']) {
			if($.notify) {
				$.notify('no slry data', 'error');
			} else {
				alert('no slry data');
			}
			return;
		}

		gearSlryListBuilder.slryData = inputSlryData;
		setBigDecimalAllowFloatDecimal(gearSlryListBuilder.slryData.newDecimalPlaces);
		fixSlryData(gearSlryListBuilder);
		buildHtml(gearSlryListBuilder);
		binding(gearSlryListBuilder);
		initValidator(gearSlryListBuilder);
		initJsChecked(gearSlryListBuilder.$coreTable);
		triggerBinding(gearSlryListBuilder.$coreTable);
		gearSlryListBuilder.$coreTable.trigger('slryLoadSuccess');
	};
	
	/**
	 * 撌脩�蝯虫��箏��澆�,閫貊鈭辣
	 */
	var triggerBinding = function($coreTable) {
		$('input[data-name=CHG_TP][value=D]', $coreTable).each(function(){
			var $input = $(this);
			var $td = $input.closest('td');
			$('input[data-name=CANCLE]', $td).prop('checked', true).trigger('click').prop('checked', true);
		});
	};
	
	/**
	 * ��FKA1 銝行�撠�鞈�撣嗥策�啗��� 銝摮��芸��寡�, 撠�恍銝�靽格����瘝���
	 */
	var fixSlryData = function(gearSlryListBuilder) {
		if('3' === gearSlryListBuilder.slryData.chgSrc) {
			var newBaseSlryAmt = BigDecimal(gearSlryListBuilder.slryData.newBaseSlryAmt);
			$.each(gearSlryListBuilder.slryData.baseSlryList, function(idx, entry) {
				if(!entry.NEW_VO && 'D' !== entry.CHG_TP) {
					entry.AMT032 = entry.AMT004;
					entry.GET_TIMES032 = entry.GET_TIMES004;
					entry.GOT_TIMES032 = entry.GOT_TIMES004;
					newBaseSlryAmt = newBaseSlryAmt.add(entry.AMT032);
				}
			});
			gearSlryListBuilder.slryData.newBaseSlryAmt = newBaseSlryAmt.toString();
			
			var newFixedSlryAmt = BigDecimal(gearSlryListBuilder.slryData.newFixedSlryAmt);
			$.each(gearSlryListBuilder.slryData.fixedSlryList, function(idx, entry) {
				if(!entry.NEW_VO && 'D' !== entry.CHG_TP) {
					entry.AMT032 = entry.AMT004;
					entry.GET_TIMES032 = entry.GET_TIMES004;
					entry.GOT_TIMES032 = entry.GOT_TIMES004;
					newFixedSlryAmt = newFixedSlryAmt.add(entry.AMT032);
				}
			});
			gearSlryListBuilder.slryData.newFixedSlryAmt = newFixedSlryAmt.toString();
			
			gearSlryListBuilder.slryData.newTotalSlryAmt = newBaseSlryAmt.add(newFixedSlryAmt).toString();
		}
	};
	
	var GearSlryListBuilder = function (divId) { 
		this.$theDivId = $("#"+divId);	
		this.slryData = {};
		this.templates = {};
		this.trCnt = 0;
		this.$coreTable = $('#slryTable', $("#"+divId));
	};
	
	/**
	 * ����甇亙�憪�. 憒��澆�銝�, 隢銵succes���initByData
	 * @compId �砍��
	 * @employeeId �∪極
	 * @url ��SlryInfo�雯��, 撣嗅�COMP_ID, EMPLOYEE_ID
	 */
	GearSlryListBuilder.prototype.initByAjax = function(/*String*/ compId, /*String*/ employeeId, /*String*/ url) {
		$.ajax({
			'url': url,
			'data': {
				'COMP_ID': compId,
				'EMPLOYEE_ID': employeeId
			},
			'dataType': 'json',
			'cache': false,
			'error': function() {
				this.$coreTable.trigger('slryLoadError');
			},
			'success': function(resp, textStatus, jqXHR) {
				this.init(resp.SLRY_DATA);
			}
		});
	};
	
	/**
	 * ���郊����
	 * @param inputSlryData SlryInfo�拐辣
	 * @param editMode �臬�箇楊頛舀芋撘�Y/N
	 */
	GearSlryListBuilder.prototype.initByData = function(/*Json*/ inputSlryData, /*String*/ editMode, /*String*/ defaultChgTp) {
		

		if (editMode) {
			if (editMode == 'Y') {
				inputSlryData.editMode = 'Y';
			} else if (editMode == 'N') {
				inputSlryData.editMode = 'N';
			}
		}
		
		init(inputSlryData, this);
		
		if (defaultChgTp && defaultChgTp == 'I') {
			this.slryData.defaultChgTp = defaultChgTp;
		}
		
		return this;
	};
	
	/**
	 * �園��鞈���data, 銝血葆��callBackFnc �嗥洵銝�����
	 * chgSrc �����啣�鞈�. �嗅���芷隞亙�������
	 * @param employeeId
	 * @param callBackFnc(data)
	 */
	GearSlryListBuilder.prototype.submit = function(/*String*/ employeeId, /*function*/ callBackFunc, /*boolean*/ isNotOnlyChanged) {
		var $form = this.$coreTable.closest('form');
		if($form.validate().form()) {
			var datas = [];
			$('.slry_baseSlryData, .slry_fixedSlryData', $form).each(function() {
				var data = null;
				
				$tr = $(this);
				var vo = $tr.data('vo');
				if(vo) {
					data = vo['NEW_VO'] || vo['OLD_VO'];// ���瘝隡箸��刻���鋆
				}
				
				var isNewData = false;//�臬�臬�啁�鞈�
				//��閬���雿�_CHANGE)靘�瑟�行��啣�,slryData.chgSrc���������鞈�
				if(!data) {
					isNewData = true; //瘝EW_VO,銋�OLD_VO
					data = {
						'_CHANGE':true,
						'CHG_TP':'I'
					};
				}
				
				//閮剖�CHG_TP
				var pageChgTp = $('input[data-name=CANCLE]', $tr).prop('checked') ? 'D' : this.slryData.defaultChgTp;
				if(data['_CHANGE'] || ((data['CHG_TP'] == 'D' || pageChgTp == 'D') && data['CHG_TP'] != pageChgTp)) {//�啣����啣�敺D銝��敺���
					data['_CHANGE'] = true;
				}
				if (!data['CHG_TP']) {
					data['CHG_TP'] = pageChgTp;
				}
				
				//閮剖��嗅�甈�
				if('D' === data['CHG_TP'] && isNewData) {//�啗���瘝鞈�摨��芷���∟�
					return true;
				} else {
					vo = vo || {};
					data['EMPLOYEE_ID'] = data['EMPLOYEE_ID'] || employeeId;
					data['COMP_ID'] = data['COMP_ID'] || this.slryData.currCompId;
					data['SLRY_CODE'] = data['SLRY_CODE'] || vo.SLRY_CODE || $('select[data-name=SLRY_CODE]', $tr).val();
					
					//瑼Ｘ���臬���
					var pageAmt = $('input[data-name=AMT]', $tr).val();
					if(data['_CHANGE'] || data['AMT'] != pageAmt || data['CHG_TP'] == 'I') {
						data['_CHANGE'] = true;
					}
					
					//瑼Ｘ��甈⊥�臬���
					var pageGetTims = $('input[data-name=GET_TIMES]', $tr).val() || '-1';
					if(data['_CHANGE'] || data['GET_TIMS'] != pageGetTims) {
						data['_CHANGE'] = true;
					}
					
					if('D' !== data['CHG_TP']) {//�芣���斗�撣嗅靽格鞈�
						data['AMT'] = pageAmt;
						data['GET_TIMS'] = pageGetTims;
						data['GOT_TIMS'] = '-1' == data['GET_TIMS'] ? '-1' : (data['GOT_TIMS'] || '0');
					}
				}
				if(!isNotOnlyChanged && this.slryData.chgSrc === '3' && !data['_CHANGE']) {
					return true;//�軼hgSrc��銝�靽格��銝撓��
				}
				//A0�啣��脣�怠�, �活�脣���, 甇斗�銝��芷閰脩��怠�瑼� ���瘙�
				datas.push(data);
			});
			callBackFunc(datas);
		}
	};
	
	/**
	 * ��銝餉”jquery�拐辣
	 */
	GearSlryListBuilder.prototype.core = function() {
		if(this.slryData.editMode === 'N') {
			return $('#');//�蝛箇�
		} else {
			return this.$coreTable;
		}
	};
	
	/**
	 * �梯�CurrZone��憛�
	 */
	GearSlryListBuilder.prototype.hideCurrZone = function(/*boolean*/ needHide) {
		if(needHide) {
			$('.currZone', this.$coreTable).hide();
			$('th:first', $('tr:first', this.$coreTable)).addClass('w21');
		}
		return this;
	};
	
	/**
	 * ���摰
	 * @param url �賢�敺LRY_CODE�雯��, 撠�撣嗅�COMP_ID,AREA_CODE,SLRY_REF_BEL
	 */
	GearSlryListBuilder.prototype.addFixedSlryTr = function(/*String*/ url) {
		var gearSlryListBuilder = this;
		var $target = $('.slry_fixedSlryData', this.$coreTable).last();
		if($target.length == 0) {
			$target = $('#slry_fixedSlryTitle', this.$coreTable);
		}
		var $tr = removeUnnecessaryChildren($(this.templates['slry_fixedSlryData'].replace(/$\{(.*?)\}/g, function(matchStr, key) {
			return '';
		})), this, true);
		
		var $tds = $tr.children();
		var childCnt = $tds.length;
		var baseChildCnt = (childCnt - 1) / 2;
		var th = $tds.eq(0);
		th.attr('colspan', baseChildCnt + 1)
		.empty()
		.append(selectBuilder($('<select>', {'class':'select1 w40', 'name':'SLRY_CODE_REF' + this.trCnt, 'data-name':'SLRY_CODE_REF'}), 
					this.slryData.slryRefBelMap)
				.data('url', url)
				.on('change', function(){
			var $this = $(this);
			var $targetElm = $('select[data-name=SLRY_CODE]', $this.parent()).empty();
			var slryRefBel = $this.val();
			if(slryRefBel === '') {
				return;
			}
			
			$.ajax({
				url: $this.data('url'),
				data: {
					'COMP_ID': gearSlryListBuilder.slryData.currCompId,
					'AREA_CODE': gearSlryListBuilder.slryData.currAreaCode,
					'SLRY_REF_BEL': slryRefBel
				},
				dataType: "json",
				cache: false,
				error: function() {},
				success: function(req, textStatus, jqXHR) {
					selectBuilder($targetElm, req.slryItemMap);
				}
			});
		}))
		.append(selectBuilder($('<select>', {'class':'select1 w40 ml10', 'name':'SLRY_CODE' + this.trCnt, 'data-name':'SLRY_CODE'}), {}).on('change', function(){
			var $select = $(this);
			if(hasTheSameSlryCode($select, gearSlryListBuilder.$coreTable)) {
				var text = $('option:selected', $select).text();
				$select.val('');
				$.notify('<fmt:message key="FKA_UI_0029" /><%--�芣揖�[{0}]��--%>'.format(text));
			}
			initWithDefine($select.closest('tr'), gearSlryListBuilder);
		}));
		
		for(var i = 1 ; baseChildCnt > 0 ; baseChildCnt--, i++) {
			$tds.eq(i).remove();
		}
		initValidator(gearSlryListBuilder, binding(this, $tr).insertAfter($target), true);
	};
	
	/**
	 * 擃漁摨虫����典�
	 */
	GearSlryListBuilder.prototype.highLight = function() {
		$('.slry_baseSlryData, .slry_fixedSlryData', this.$coreTable).each(function(){
			var $tr = $(this);
			var $tds = $('td', $tr);//憒�憿�th, ��閬撖�
			var filedCnt = $tds.length / 2;
			for(var idx = 0 ; idx < filedCnt ; idx++) {
				var $currTd = $tds.eq(idx);
				var $newTd = $tds.eq(idx + filedCnt);
				var currSpan = $currTd.children().first();
				var newSpan = $newTd.children().first();
				if(currSpan.text() != newSpan.text()) {
					newSpan.addClass('txtOrange');
				}
			}
		});
		return this;
	};
	
	/**
	 * �勗�憪�蝯虫����葉�� DTFKA032 �批捆
	 */
	GearSlryListBuilder.prototype.getDTFKA032 = function() {
		var ret = [];
		$.each(this.slryData['baseSlryList'], function(idx, val){
			var vo = val['NEW_VO'];
			if(vo) {
				ret.push(vo);
			}
		});
		$.each(this.slryData['fixedSlryList'], function(idx, val){
			var vo = val['NEW_VO'];
			if(vo) {
				ret.push(vo);
			}
		});
		return ret;
	};
	
	GearSlryListBuilder.prototype.getBeEditedDTFKA032 = function() {
		var resultList = [];
		$('.slry_baseSlryData, .slry_fixedSlryData').each(function() {
			$tr = $(this); 
			var vo = $tr.data('vo');
			var newVo = vo['NEW_VO'];
			if (newVo) {
				resultList.push();
			}
		});
	};
	
	/**
	 * 撱箇�select�辣
	 * @$select 閬溶�ption��鞊�
	 * @dataMap option鞈�
	 * @currVal select ��閮貞elected��
	 */
	function selectBuilder(/*jQuery*/ $select, /*Map*/ dataMap, /*String*/ currVal) {
		$select.append($('<option>').text('<fmt:message key="FKA_UI_0028" /><%--隢��-%>').val(''));
		$.each(keyValueMapToSortedList(dataMap), function(key, optionData) {
			$select.append($('<option>').text(optionData.val).val(optionData.key).prop('selected', currVal === optionData.val));
		});
		return $select;
	};
	
	/**
	 * map 頧����array, �澆�憒� 
	 *{'key8':'val8', 'key1': 'val1'} -> [{key:'key1', val:'val1'}, {key:'key8', val:'val8'}]
	 */
	function keyValueMapToSortedList(/*Map*/ map) {
		var arr = [];
		$.each(map, function(key, value) {
			arr.push({
				'key':key,
				'val':value
			});
		});
		arr.sort(function(item1, item2) {
			if(item1.key.localeCompare) {
				return item1.key.localeCompare(item2.key);
			} else {
				if(item1.key === item2.key) {
					return 0;
				} else {
					return item1.key > item2.key ? 1 : -1;
				}	
			}
		});
		return arr;
	};
	
	console.log("slry_page.js function 2 end");
	window.GearSlryListBuilder = function(divId) {
		return new GearSlryListBuilder(divId);
	};
})();	