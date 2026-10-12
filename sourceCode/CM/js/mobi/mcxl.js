//cxl plugins for zepto
(function($){
	
	$.isSuccess = function(resp){
		
		var rtMsg = $.getReturnMessage(resp);
		
		return (rtMsg.returnCode == 0 && !resp['_stack']);
		
	};
	
	$.getReturnMessage = function(resp){
		
		if(!resp) return {};
		
		return resp.ErrMsg || {};
	};
	
	$.getMsgDesc = function(resp){
		
		return $.getReturnMessage(resp).msgDesc || '';
			
	}
	
	$.fparam = function(data){
		
		if(!data) return '';
		
		var pairs = [];
		
		for(var p in data){
		
			var val = data[p];
			if(val != undefined){
				pairs.push(encodeURIComponent(p) + '=' + encodeURIComponent(val));
			}
			
		}
		
		return pairs.join('&');		
		
	};
	
	function centerize(elem){
		
		var bodyDim = document.body.getBoundingClientRect();
		
		var bodyH = bodyDim.height;
		var bodyW = bodyDim.width;
		
		var dh = parseInt(bodyH * 0.3);
		var dw = parseInt(bodyW * 0.7);
		
		var cssObj = {
			'position':'absolute',
			'top': document.body.scrollTop + parseInt((bodyH - dh)/2),
			'left':document.body.scrollLeft + parseInt((bodyW - dw)/2),
			//'height': dh + 'px',
			'width': dw + 'px'
		};		
		
		elem.css(cssObj);
		
	}
	
	$.showProgress = function(elem){
		
		if(!elem){
			elem = document;
		}
		
		coverDiv.css({
			'display':'-webkit-box',
			'height':document.body.scrollHeight
		});
		
		centerize(imgDiv);
		
	};
	
	$.hideProgress = function(){
		coverDiv.hide();
	};
	
	$.submit = function(elem){
		
		var node = $(elem).dom[0];
		
		if(node.submit){
			$.showProgress();
			node.submit();			
		}

	};
	
	$.showMsg = function(msg){
		
		msgDiv.html(msg);
		msgCoverDiv.css({
			'display':'-webkit-box',
			'height':document.body.scrollHeight
		});
		centerize(msgDiv);
		
	};
	
	var coverDiv;
	var msgCoverDiv;
	var msgDiv;
	var imgDiv;
	
	$(document).ready(function(){
		
		var coverCss = {
			'position':'absolute',
			'left': '0',
			'top': '0',
			'background-color':'rgba(0, 0, 0, 0.3)',
			'display':'-webkit-box',
			'-webkit-box-orient': 'vertical',
			'-webkit-box-pack': 'center',
			'-webkit-box-align': 'center',		
			'width': '100%',
			'height': '100%'
		};
		
		coverDiv = $(document.createElement('div'));
		coverDiv.css(coverCss);
		
		msgCoverDiv = $(document.createElement('div'));
		msgCoverDiv.css(coverCss);
		
		imgDiv = $(document.createElement('div'));
		imgDiv.addClass('loader_cover');
		coverDiv.append(imgDiv);
		
		msgDiv = $(document.createElement('div'));
		msgDiv.css({
			'background-color': 'rgba(0, 0, 0, 0.7)',
			'color': '#ffffff',
			'border': '2px solid #ffffff',
			'border-radius': '8px',
			'display':'-webkit-box',
			'-webkit-box-orient': 'vertical',
			'-webkit-box-pack': 'center',
			'-webkit-box-align': 'center',
			'width': '70%',
			'height': '30%'
		});
		
		msgCoverDiv.append(msgDiv);
		msgDiv.bind('click', function(e){
			msgCoverDiv.hide();			
		});
		
		$(document.body).append(coverDiv);
		$(document.body).append(msgCoverDiv);
		coverDiv.hide();
		msgCoverDiv.hide();
		
	});
	
})(Zepto);


//format number plugin -----------------------------------------------------
(function($){
	
	//取得數字型態資料
	$.numVal = function(val){

        if(isNaN(val)){
        	return 0;
        }
		
        if(typeof val !== 'number'){
            val = Number(val);
        }    

        return val;		
		
	};
	
	//格式化數字欄位
	var defaultPattern = '#,###.####';
	var cleanFmt = /,/g;
	
	$.fmt = function(val, pattern){

		var str = ('' + val).toLowerCase().replace(cleanFmt, '').trim();
		
		if(str == '' || isNaN(str)){
			return str;
		}
		
		if(!pattern){
			pattern = defaultPattern;
		}
		
		var dec_index = pattern.indexOf('.');
		
		//是否為負數
		var minus = false;
		if(str.indexOf('-') == '0'){
			minus = true;
			str = str.substr(1);
		}
		
		//拆成數字跟小數部份
		var ary = str.split('.', 2);
		var intPart = ary[0];
		var floatPart = ary[1];
		
		//格式化數字部份
		var resultStr = formatInteger(intPart, pattern, dec_index);
		
		//有指定小數部份
		if(dec_index > 0){
			
			floatPart = formatFloat(floatPart, pattern, dec_index);
			
			if(floatPart){
				resultStr += '.' + 	floatPart;
			}			
			
		}
		
		if(minus){
			return '-' + resultStr;	
		}
		
		return resultStr;
		
		//---------------------------------------------------------
		//數字部份的處理(private method) 
		//---------------------------------------------------------
		function formatInteger(intPart, pattern, dotPos){
			
			//逗點分隔位置
			var sep = pattern.indexOf(',');
			
			if(sep == -1){
				return intPart;
			}
			
			//計算每幾位數給分隔號
			var sepLen = (dotPos!=-1?dotPos-sep-1:pattern.length-sep-1);
			var m = intPart.length;
			
			//長度超過才分隔
			if(m > sepLen){
				
				var firstP = m % sepLen;
				var sectionN = parseInt(m / sepLen);
				var sAry = [];
				
				if(firstP > 0){
					sAry.push(intPart.substr(0, firstP));	
				}
				
				while(sectionN > 0){
					
					sAry.push(intPart.substr(firstP, sepLen));
					firstP += sepLen;
					sectionN--;
					
				}
				
				intPart = sAry.join(',');
	
			}
			
			return intPart;			
		}
		//---------------------------------------------------------
		//end of 數字部份的處理
		//---------------------------------------------------------		
		
		//---------------------------------------------------------
		//小數部份的處理(private method)
		//---------------------------------------------------------
		function formatFloat(floatPart, pattern, dotPos){
			
			var floatPattern = pattern.substr(dotPos+1);
			
			var precision = floatPattern.length;
			
			if(!isNaN(floatPart)){
			
				//數值有小數，根據 pattern 的位數先用 0 補滿
				var fm = floatPart.length;
				
				//小數部份長度超過指定的長度
				if(fm > precision){
							
					floatPart = floatPart.substr(0, precision);
							
				}else if(fm < precision) {
		
					var padL = precision - floatPart.length;
							
					//先將小數部位用 0 補滿指定的精準位數
					while(padL > 0){
						floatPart += '0';
						padL--;
					}
					
				}
					
			}else{
				//數值沒有小數，用 0 補滿	

				var padL = precision;
				floatPart = '';
							
				//先將小數部位用 0 補滿指定的精準位數
				while(padL > 0){
					floatPart += '0';
					padL--;
				}

			}	
				
			//跟 pattern 比較，若 pattern 為 # 且數字為 0 則不保留
			var x = floatPart.length - 1;
						
			while(x >= 0){
							
				if(floatPattern.charAt(x) == '#'
				    && floatPart.charAt(x) != '0'){
					break;	
				}else if(floatPattern.charAt(x) == '0'){
					break;	
				}else{
					floatPart = floatPart.substr(0, x);	
				}
							
				x--;
								
			}
			
			return floatPart;
			
		}
		//---------------------------------------------------------
		//end of 小數部份的處理
		//---------------------------------------------------------			
		
	}	
	
	$.setFmtValue = function(elem, value){
		
		switch(elem.pluck('tagName')[0]){
			
			case 'INPUT': {
				elem.val($.fmt(value||elem.val(), elem.attr('pattern')));
				break;
			};
			
			case 'SPAN': 
			default: {
				elem.text($.fmt(value||elem.text(), elem.attr('pattern')));			
				break;
			};
				
		}
		
		return elem;
		
	}
	
	//格式化 class = number 的 INPUT, SPAN 欄位
	$.numberInput = function(context){
		
		var elems;
		
		if(context!==undefined){
			elems = $(context).find('.number');
		}
		
		elems = $('.number');
		
		elems.each(function(){
			
			var elem = $(this);
			elem.css({'text-align':'right','padding-right': '2px'});
			$.setFmtValue(elem);
			
		});
		
		elems.bind('change blur', function(e){
			$.setFmtValue($(this));
		});
		
		return elems;
		
	}
	
})(Zepto);


function ajaxPost(url, params, success){
	
	var callback = function(resp) {
		success(resp);
		$.hideProgress();
	};
	
	$.showProgress();
	
	$.ajax({
		url: url,
		type: 'post',
		contentType : 'application/x-www-form-urlencoded; charset=UTF-8',
		data: $.fparam(params),
		dataType: 'json',
		success: callback,
		error: function(body){
			alert("error : " + body);
		}
	});
	
}

//////////////////////////////////////////////////////////////////////////////////
//SlidePage class
//////////////////////////////////////////////////////////////////////////////////
function SlidePage (config) {
	
	var duration = config.duration || 0.3; //seconds
	var pages = config.pages || [];
	var currentIndex = config.index || 0;
	var lastIndex = 0;
	
	var defaultCSS = {
		width: '100%',
		top: '0',
		left: '0',
		position: 'absolute',
		'display':'-webkit-box',
		'-webkit-box-orient': 'vertical',
		'-webkit-box-pack': 'center',
		'-webkit-box-align': 'center',
		'border': '0',
		'-webkit-transition': 'all ' + duration + 's ease-in-out'
	};
	
	function build() {
		
		var pageElems = [];
		
		pages.forEach(function(id){
			pageElems.push( $(document.getElementById(id)).css(defaultCSS) );
		});
		
		pages = pageElems;
		
		if(pages.length > 1){
			for(var i=1; i<pages.length; i++){
				pages[i].css({'-webkit-transform':'translate(100%, 0)', 'display':'none'});
			}
		}
		
		lastIndex = pages.length - 1;		
		
	}
	
	function showPage(page){
		
		page.css('display', '-webkit-box');
		
		setTimeout(function(){
			page.css('-webkit-transform', 'translate(0, 0)');
		}, 1);
			
	}
	
	function moveRight(page){
		
		page.css('-webkit-transform', 'translate(100%, 0)');
		hidePage(page);
			
	}
	
	function moveLeft(page){
		
		page.css('-webkit-transform', 'translate(-100%, 0)');
		hidePage(page);		
			
	}
	
	function hidePage(page){
		
		setTimeout(function(){
			page.hide();
		}, duration * 1000);
			
	}
	
	build();
	
	return {
		
		goNext: function() {
			
			if(currentIndex >= lastIndex) return;
			
			var currentPage = pages[currentIndex];
			currentIndex++;
			var nextPage = pages[currentIndex];
			
			moveLeft(currentPage);
			showPage(nextPage);
			
		},
		
		goPrev: function() {
			
			if(currentIndex <= 0) return;
			
			var currentPage = pages[currentIndex];
			currentIndex--;
			
			var prevPage = pages[currentIndex];
			
			moveRight(currentPage);
			showPage(prevPage);
			
		},
		
		goFirst: function() {
			
			if(currentIndex <= 0) return;
			
			currentPage = pages[currentIndex];
			
			currentIndex = 0;
			var firstPage = pages[currentIndex];
			
			moveRight(currentPage);
			showPage(firstPage);
			
		},
		
		goLast: function() {

			if(currentIndex >= lastIndex) return;
			
			currentPage = pages[currentIndex];
			
			currentIndex = lastIndex;
			var lastPage = pages[currentIndex];
			
			moveRight(currentPage);
			showPage(lastPage);
			
		},
		
		goAbsolute: function(targetPage) {
			
			if(targetPage <= 0|| targetPage - 1 > lastIndex) return;
			if(currentIndex == targetPage - 1) return;
			currentPage = pages[currentIndex];
			if(targetPage - 1 > currentIndex){
				moveLeft(currentPage);
			}else{
				moveRight(currentPage);
			}
			currentIndex = targetPage - 1;
			var targetPage = pages[currentIndex];
			
			showPage(targetPage);
			
		}
		
	}

}