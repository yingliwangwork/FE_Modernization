// overrite 奔 mobile硂よ猭ノㄓ﹚ぃ跋遏糴
(function($){
	var msgWin;
	if( !$.cathay ){
		$.cathay = {};	// 讽 CSRUtil
	}	
	
	var BigNumber = function(n, p, r){
		var o = this, i;
		if(n instanceof BigNumber){
			for(i in {precision: 0, roundType: 0, _s: 0, _f: 0}) o[i] = n[i];
			o._d = n._d.slice();
			return;
		}
		o.precision = isNaN(p = Math.abs(p)) ? BigNumber.defaultPrecision : p;
		o.roundType = isNaN(r = Math.abs(r)) ? BigNumber.defaultRoundType : r;
		o._s = (n += "").charAt(0) == "-";
		o._f = ((n = n.replace(/[^\d.]/g, "").split(".", 2))[0] = n[0].replace(/^0+/, "") || "0").length;
		for(i = (n = o._d = (n.join("") || "0").split("")).length; i; n[--i] = +n[i]);
		o.round();
	};
	with({$: BigNumber, o: BigNumber.prototype}){
		$.ROUND_HALF_EVEN = ($.ROUND_HALF_DOWN = ($.ROUND_HALF_UP = ($.ROUND_FLOOR = ($.ROUND_CEIL = ($.ROUND_DOWN = ($.ROUND_UP = 0) + 1) + 1) + 1) + 1) + 1) + 1;
		$.defaultPrecision = 40;
		$.defaultRoundType = $.ROUND_HALF_UP;
		o.add = function(n){
			
			if(this._s != (n = new BigNumber(n))._s)
				return n._s ^= 1, this.subtract(n);
			var o = this._rounding ? this : new BigNumber(this);
			var a = o._d, b = n._d, la = o._f, lb = n._f, n = Math.max(la, lb), i, r;
			la != lb && ((lb = la - lb) > 0 ? o._zeroes(b, lb, 1) : o._zeroes(a, -lb, 1));
			i = (la = a.length) == (lb = b.length) ? a.length : ((lb = la - lb) > 0 ? o._zeroes(b, lb) : o._zeroes(a, -lb)).length;
			for(r = 0; i; r = (a[--i] = a[i] + b[i] + r) / 10 >>> 0, a[i] %= 10);
			return r && ++n && a.unshift(r), o._f = n, o.round();
		};
		o.subtract = function(n){
			if(this._s != (n = new BigNumber(n))._s)
				return n._s ^= 1, this.add(n);
			var o = new BigNumber(this), c = o.abs().compare(n.abs()) + 1, a = c ? o : n, b = c ? n : o, la = a._f, lb = b._f, d = la, i, j;
			a = a._d, b = b._d, la != lb && ((lb = la - lb) > 0 ? o._zeroes(b, lb, 1) : o._zeroes(a, -lb, 1));
			for(i = (la = a.length) == (lb = b.length) ? a.length : ((lb = la - lb) > 0 ? o._zeroes(b, lb) : o._zeroes(a, -lb)).length; i;){
				if(a[--i] < b[i]){
					for(j = i; j && !a[--j]; a[j] = 9);
					--a[j], a[i] += 10;
				}
				b[i] = a[i] - b[i];
			}
			return c || (o._s ^= 1), o._f = d, o._d = b, o.round();
		};
		o.multiply = function(n){
			var o = new BigNumber(this), r = o._d.length >= (n = new BigNumber(n))._d.length, a = (r ? o : n)._d,
			b = (r ? n : o)._d, la = a.length, lb = b.length, x = new BigNumber, i, j, s;
			for(i = lb; i; r && s.unshift(r), x.set(x.add(new BigNumber(s.join("")))))
				for(s = (new Array(lb - --i)).join("0").split(""), r = 0, j = la; j; r += a[--j] * b[i], s.unshift(r % 10), r = (r / 10) >>> 0);
			return o._s = o._s != n._s, o._f = ((r = la + lb - o._f - n._f) >= (j = (o._d = x._d).length) ? this._zeroes(o._d, r - j + 1, 1).length : j) - r, o.round();
		};
		o.divide = function(n){
			if((n = new BigNumber(n)) == "0")
				throw new Error("Division by 0");
			else if(this == "0")
				return new BigNumber;
			var o = new BigNumber(this), a = o._d, b = n._d, la = a.length - o._f,
			lb = b.length - n._f, r = new BigNumber, i = 0, j, s, l, f = 1, c = 0, e = 0;
			r._s = o._s != n._s, r.precision = Math.max(o.precision, n.precision),
			r._f = +r._d.pop(), la != lb && o._zeroes(la > lb ? b : a, Math.abs(la - lb));
			n._f = b.length, b = n, b._s = false, b = b.round();
			for(n = new BigNumber; a[0] == "0"; a.shift());
			out:
			do{
				for(l = c = 0, n == "0" && (n._d = [], n._f = 0); i < a.length && n.compare(b) == -1; ++i){
					(l = i + 1 == a.length, (!f && ++c > 1 || (e = l && n == "0" && a[i] == "0")))
					&& (r._f == r._d.length && ++r._f, r._d.push(0));
					(a[i] == "0" && n == "0") || (n._d.push(a[i]), ++n._f);
					if(e)
						break out;
					if((l && n.compare(b) == -1 && (r._f == r._d.length && ++r._f, 1)) || (l = 0))
						while(r._d.push(0), n._d.push(0), ++n._f, n.compare(b) == -1);
				}
				if(f = 0, n.compare(b) == -1 && !(l = 0))
					while(l ? r._d.push(0) : l = 1, n._d.push(0), ++n._f, n.compare(b) == -1);
				for(s = new BigNumber, j = 0; n.compare(y = s.add(b)) + 1 && ++j; s.set(y));
				n.set(n.subtract(s)), !l && r._f == r._d.length && ++r._f, r._d.push(j);
			}
			while((i < a.length || n != "0") && (r._d.length - r._f) <= r.precision);
			return r.round();
		};
		o.mod = function(n){
			return this.subtract(this.divide(n).intPart().multiply(n));
		};
		o.pow = function(n){
			var o = new BigNumber(this), i;
			if((n = (new BigNumber(n)).intPart()) == 0) return o.set(1);
			for(i = Math.abs(n); --i; o.set(o.multiply(this)));
			return n < 0 ? o.set((new BigNumber(1)).divide(o)) : o;
		};
		o.set = function(n){
			return this.constructor(n), this;
		};
		o.compare = function(n){
			var a = this, la = this._f, b = new BigNumber(n), lb = b._f, r = [-1, 1], i, l;
			if(a._s != b._s)
				return a._s ? -1 : 1;
			if(la != lb)
				return r[(la > lb) ^ a._s];
			for(la = (a = a._d).length, lb = (b = b._d).length, i = -1, l = Math.min(la, lb); ++i < l;)
				if(a[i] != b[i])
					return r[(a[i] > b[i]) ^ a._s];
			return la != lb ? r[(la > lb) ^ a._s] : 0;
		};
		o.negate = function(){
			var n = new BigNumber(this); return n._s ^= 1, n;
		};
		o.abs = function(){
			var n = new BigNumber(this); return n._s = 0, n;
		};
		o.intPart = function(){
			return new BigNumber((this._s ? "-" : "") + (this._d.slice(0, this._f).join("") || "0"));
		};
		o.valueOf = o.toString = function(){
			var o = this;
			return (o._s ? "-" : "") + (o._d.slice(0, o._f).join("") || "0") + (o._f != o._d.length ? "." + o._d.slice(o._f).join("") : "");
		};
		o._zeroes = function(n, l, t){
			var s = ["push", "unshift"][t || 0];
			for(++l; --l;  n[s](0));
			return n;
		};
		o.round = function(){
			if("_rounding" in this) return this;
			var $ = BigNumber, r = this.roundType, b = this._d, d, p, n, x;
			for(this._rounding = true; this._f > 1 && !b[0]; --this._f, b.shift());
			for(d = this._f, p = this.precision + d, n = b[p]; b.length > d && !b[b.length -1]; b.pop());
			x = (this._s ? "-" : "") + (p - d ? "0." + this._zeroes([], p - d - 1).join("") : "") + 1;
			if(b.length > p){
				n && (r == $.ROUND_DOWN ? false : r == $.ROUND_UP ? true : r == $.ROUND_CEIL ? !this._s
				: r == $.ROUND_FLOOR ? this._s : r == $.ROUND_HALF_UP ? n >= 5 : r == $.ROUND_HALF_DOWN ? n > 5
				: r == $.ROUND_HALF_EVEN ? n >= 5 && b[p - 1] & 1 : false) && this.add(x);
				b.splice(p, b.length - p);
			}
			return delete this._rounding, this;
		};
	}
	
	$.extend( $.cathay , {
		linkTo: function( params, form ){
			if( !params.action ){
				alert('叫﹚ action 把计');
				return;
			}

			var linkForm = $('<form>').attr( { method: "post", action: params.action }),
				parameters = params.parameters;
	
			if( $.isPlainObject( parameters ) ){
				for( var key in parameters ){
					var input = $('<input>').attr( { type: "hidden", name: key } ).val( parameters[key] );
					linkForm.append( input );
				}
			}
			
			if( form ){	// 玂痙瞷form把计
				var sessionStorage = window.sessionStorage;
				if( sessionStorage ){
					var cacheName = "com.cathay.linkQueue",
						cacheArray = sessionStorage[cacheName] ? $.parseJSON( sessionStorage[cacheName] ) : [];
					
					if( typeof form == "string" ){
						form = $('#' + form );
					}
					var obj = { RQ_SENDER: window.location.pathname };
					$.each( form.serializeArray(), function(index, elm){
						obj[elm.name] = elm.value;
					});
					cacheArray.push( obj );
					sessionStorage[cacheName] = JSON.stringify( cacheArray );
				}
			}
			
			linkForm.submit();
		},
		isBackLink: function( formID ){
			var cacheName = "com.cathay.linkQueue",
				sessionStorage = window.sessionStorage;
			if( sessionStorage && sessionStorage[cacheName] ){
				var json = sessionStorage[cacheName],
					queue = $.parseJSON( json ),
					inputs = queue[queue.length-1];
				if( inputs.RQ_SENDER == window.location.pathname ){ 
					for( var key in inputs ){
						$('#' + formID ).find( '[name="' + key + '"]' ).each(function(index, elm){
							elm = $(elm);
							elm.val( inputs[key] );
							if( elm.prop("tagName") == "SELECT" ){
								elm.selectmenu('refresh');
							}
						});	
					}
					
					if( queue.length > 1 ){
						queue.length = queue.length - 1; 	//奔程掸
						sessionStorage[cacheName] = JSON.stringify( queue );
					}else{
						delete sessionStorage[cacheName];
					}
					return true;
				}else{
					delete sessionStorage[cacheName];		// 铬匡虫
				}	
			}
			return false;			
		},
		createLinkBack: function( url, text, pageDiv ){
			var queryString;
			if( typeof pageDiv == "string" ){
				queryString = "#" + pageDiv;
			}
			$( queryString || 'div[data-role="page"]').live( 'pagebeforecreate', function(event){
				var elm = $(event.target),
					footer = elm.find('div[data-role="footer"]');
				if( footer.length == 0 ){
					footer = $('<div>').attr( { "data-role": "footer", "data-position": "fixed" } ).addClass( 'ui-bar' );
					elm.append( footer );
				}
				
				var link = $('<a>').attr( { href: url, "data-theme": "b", "data-ajax": false, "data-role": "button", "data-icon": "back", "data-mini": "true" } );
				link.text( text );
				footer.append( link );
			});
		},
		getMsgBoard: function(){
			return msgWin;
		},
		getReturnMessage: function (resp){
			return resp['ErrMsg'];
		},
		isSuccess: function( resp ){
			var msg = $.cathay.getReturnMessage(resp);			
			if( msg ){
				return (msg.returnCode == 0);
			}			
			
			return false;			
		},		
		ajaxPost: function ( url, parameter, successFunction, errorFunction ){
			$.ajax({
				  url: url,
				  dataType: 'json',
				  data: parameter,
				  success: function(resp, textStatus, xhr){
					try{
						if($.cathay.isSuccess(resp)){
							if( successFunction ){
								successFunction( resp );
							}
						}else{
							if( errorFunction ){
								errorFunction( resp );
							}
						}
					}catch( exception ){	
						var errMsg = '╰参Τ粇 :\n';
						errMsg += 'URL : ' + url + "\n";
						errMsg += 'ERROR : ' + exception.name + " - " + exception.message + '\n';
						alert( errMsg );
					}
				}
			});
		},
		createLink: function( url, text, options ){
			var link = $('<a>').attr( { "data-ajax": false, "href": url } ).html( text );
			if( options && options.useLinkTo ){
				link.bind( 'click', function(event){
					var params = {};
					params.action = url;
					params.parameters = options.parameters || {};
					event.preventDefault();
					$.cathay.linkTo( params, options.form || "" );					
				});
			}			
		
			return link;
		},
		//-------------------------MoneyFormat--------------------------------
		defaultPattern: "#,###.####",
		$fmt: function(v, pattern, isInput){
			if( !$.isNumeric(v) ) return '';
			
			var str = new String(v),
				dot = pattern.indexOf('.'); 	// pattern Τ﹚计
			
			//弘非耞璝 pattern Τ﹚计玥ㄌ﹚计计弘非
			// $fmt 磅︽礶Αて璝ゼ﹚计玥计计场穦钡玂痙
			//甧珿玂痙箇砞计 40 讽块璝ゼ﹚计计玥弘非砞 0
			var precision = BigNumber.defaultPrecision;
			
			if(dot != -1){
				precision = pattern.substr(dot+1).length;
			}else if(isInput){
				precision = 0;
			}else{
				//獶块ゼ﹚计杠ノ箇砞弘非ㄓΑて(40)
				dot = pattern.length;
				pattern += '.' +  strTimes( '#', precision);		
			}
			
			//琌Τ厩癘腹ボ
			var eePrest = str.indexOf('e');
			
			if( eePrest != -1){
				
				var powerN = str.substring(eePrest + 1);
				
				powerN = new Number(powerN);
				
				//弘非箇砞计翴 40 计
				powerN = new BigNumber(10).pow(powerN);
				
				str = new BigNumber(str.substring(0, eePrest), precision).multiply(powerN).toString();
				
			}else if(!isInput){
				//ぃ琌 input 暗弘非の秈矪瞶
				str = new BigNumber(str, precision).toString();			
			}
			
			//琌璽计
			var minus = false;
			if( str.lastIndexOf("-", 0) === 0 ){
				minus = true;
				str = str.substr(1);
			}
			
			//╊Θ计蛤计场
			var ary = str.split('.', 2);
			var intPart = ary[0];
			var floatPart = ary[1];
			
			var resultStr = formatInteger(intPart, pattern, dot);
			
			//pattern Τ﹚计
			if(precision > 0){
				if(isInput){
					//块计场度暗计篒耞
					if(str.indexOf('.') != -1){
						resultStr += '.' + floatPart.substr(0, precision);
					}
				}else{
					var floatPart = formatFloat(floatPart, pattern, dot, precision);
					
					if(floatPart){
						resultStr += '.' + 	floatPart;
					}
				}
			}
			
			if(minus){
				return '-' + resultStr;	
			}
			
			return resultStr;	
	
			function strTimes( str, count){
				return count < 1 ? '' : new Array(count + 1).join(str);
			}
	
			//计场矪瞶(private method) 
			function formatInteger(intPart, pattern, dotPos){
				//硆翴だ筳竚
				var sep = pattern.indexOf(',');
				
				if(sep == -1){
					return intPart;
				}
				
				//璸衡–碭计倒だ筳腹
				var sepLen = (dotPos!=-1?dotPos-sep-1:pattern.length-sep-1);
				var m = intPart.length;
				
				//禬筁だ筳
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
			//end of 计场矪瞶
	
			//计场矪瞶(private method)
			function formatFloat(floatPart, pattern, dotPos, precision){
				var floatPattern = pattern.substr(dotPos+1);
				
				if(!isNaN(floatPart)){
					//计Τ计沮 pattern 计ノ 0 干骸
							
					var fm = floatPart.length;
					//计场禬筁﹚
					if(fm > precision){
								
						floatPart = floatPart.substr(0, precision);
								
					}else if(fm < precision) {
			
						var padL = precision - floatPart.length;
								
						//盢计场ノ 0 干骸﹚弘非计
						if(padL > 0){
							floatPart += strTimes( '0' , padL );
						}
					}	
						
				}else{
					//计⊿Τ计ノ 0 干骸	
					floatPart = strTimes( '0' , precision );
				}	
					
				//蛤 pattern ゑ耕璝 pattern  # 计 0 玥ぃ玂痙
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
			//end of 计场矪瞶
		}
	});
	
	function MsgWin(){
		var msgBoard = $("<div class='ui-loader ui-overlay-shadow ui-body-a ui-corner-all'>")
				.css( {"display": "none", "opacity": 0.9, padding: "10px", "text-Align": "center" } );
	
		var title = $('<h1>');
		msgBoard.append(title).appendTo($.mobile.pageContainer)	
				.bind( 'tap', function(event){
					close();
				});

		this.show = show;
		function show( msg, isAutoClose ){
			var $window = $(window),
				top = $window.height() / 2 - 30,
				width = $window.width(),
				left;
			
			msg = msg.replace(/\\n|\n/g, '<br/>');						
			title.html(msg);
			// 璸衡竚いleft把计
			left = msgBoard.outerWidth(true);
			if( left <= width ){
				left = (width - left)/2;
			}
			
			msgBoard.css( { "display": "block", "top": top + "px", "left": left + "px" } );
			if( isAutoClose ){
				msgBoard.delay( 1500 );	// 1.5闽超
				this.close();
			}
		};
		
		this.close = close; 
		function close( fedeOutTime ){
			if( msgBoard.css("display") == "block"){
				if( fedeOutTime === 0 ){
					msgBoard.hide();
				}else{
					msgBoard.fadeOut( fedeOutTime || 600 , function() {
						msgBoard.hide();
					});
				}
			}
		};	
	}
	
	$.ajaxSetup({
		type: "POST"
	});	
	
	$.ajaxPrefilter( function( options, originalOptions, xhr ) {
		if( options.dataType == "html" ){
            xhr.setRequestHeader( "X-Requested-With", "XMLHttpRequest2" );	//2ㄓ磷秨AjaxFilter币笆
		}
	});
	
	$(document).ajaxStart( function(){
		msgWin.close(0);
		$.mobile.showPageLoadingMsg();
	})
	.ajaxStop( function(){
		$.mobile.hidePageLoadingMsg();
	})		
	.ajaxSuccess( function(event, xhr, options ){
		if( options.dataType == "json"){
			var resp = $.parseJSON( xhr.responseText ),
				errMsg = $.cathay.getReturnMessage( resp );
			if( errMsg ){
				var msgArray = errMsg.displayMsgDescs.split('\\n');
				var str = '';
				$.each(msgArray, function(index, s){
					str += s + '\n';
				});
				
				//ΤΘ穦 auto close()				
				if( $.trim(str).length != 0 ){
					msgWin.show( str, errMsg.returnCode === 0 );
				}
			}
		}		
	})	
	.ajaxError(function(event, xhr, settings, exception){
		msgWin.show( "╰参Τ粇: " + ( xhr.url || "" ) + "\n Error Code: " + ( xhr.status || "" ) + "\n" + ( xhr.responseText || "" ) );
	});
	
	// ノㄓэ jQuery mobile 箇砞把计
	$(document).bind('mobileinit', function () {
		$.mobile.page.prototype.options.theme  = "d";
		$.mobile.loadingMessageTextVisible = true;
	});
	
	// do some work before jQuery mobile going to enhance page!!
	$('div[data-role="page"]').live( 'pagecreate', function(event){
		var page = $(event.target);
				
		if( !msgWin ){
			msgWin = new MsgWin();
		}
		
		page.find('.ui-cathay-grid').each(function(index, div){
			div = $(div);
			var cols = div.attr( 'data-cathay-cols' ),
				child = div.children(),
				frag = document.createDocumentFragment();
			
			if( cols ){
				cols = cols.split(",");
				var getWidth = function(index){
					return cols[index] + "%";
				}
			}else{
				var average = 100 / child.length;
				var getWidth = function(index){
					return average + "%";
				}
			}
			child.each( function(index, elm ){
				var outDiv = document.createElement('div');
				frag.appendChild(outDiv);	// fragmentぃappendChild杆筁div
				var newDiv = $('<div>').css("margin", "4px 10px 4px 5px").append( elm );
				$(outDiv).addClass('ui-cathay-block').css("width", getWidth( index )).append(newDiv);
			});	
			div.append(frag);			
		});
		
		if( $.isFunction( window.getCalendarFor ) ){
			page.find('input[type="text"]').filter(function(index){
				var elm = $(this),
					datatype = elm.attr('datatype');
				if( (datatype == "date" || datatype == "ROCDate")){
					elm.attr( 'data-role', 'none' ).addClass('ui-input-text ui-body-c')
					   .parent().addClass('ui-input-search ui-shadow-inset ui-btn-corner-all ui-btn-shadow ui-cathay-icon-calendar ui-body-c');
					return true;
				}
				return false;
			}).bind('click', function(event){
				getCalendarFor(event.target);
			});			
		}
	});
})( jQuery );