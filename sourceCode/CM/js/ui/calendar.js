if(!window.HTML_locate_base || window.HTML_locate_base !== false){
	HTML_locate_base = location.href.split("servlet");

	if(HTML_locate_base.length <= 1 ){
		HTML_locate_base = location.href.split("html");
	}
	if(HTML_locate_base.length > 1 ){
		HTML_locate_base = HTML_locate_base[0];
	}else{
		HTML_locate_base = false;
	}
}

//引入CSS使用
if(HTML_locate_base){
	var calendarCssBase = HTML_locate_base +"html/CM/css/ui/calendar.css";
	document.write('<link rel="stylesheet" type="text/css" href="'+calendarCssBase+'" />');
	
	/*var localeDisplayJsBase = HTML_locate_base +"html/CM/js/ui/LocaleDisplay.js";
	document.write('<script type="text/JavaScript" src="'+localeDisplayJsBase+'"></script>'); */
}



//---------------------- start -----------------------------
var calendarBase;

function autoCreateDate( elem  ){
	if(!calendarBase) { new create_Calendar(); }
	calendarBase.autoCreateDate(elem);
}

function getCalendarFor( elem ){
	if(!calendarBase) { new create_Calendar(); }
	calendarBase.showCalendar( elem );
}

function create_Calendar(){
	if(calendarBase){ return calendarBase; }

	calendarBase = this;
	
	var workingNode;
	var workingNodeValue;
	
	var workingNodeIsFocus = false;
	var calendarIsFocus = false;
	
	var working_pattern;
	
	//設定參數
	var TEXT_PRE = "\u25C4";//"\u2190";//"\u25C1";//
	var TEXT_NEXT = "\u25BA";//"\u2192";//
	
	//----------------------- calendar主體 ------------------
	var calendar = createDOM("DIV"
		,null
		,null
		,["calendar","shadow"]
		,{'click': function(){ setCalendarStatus(null,true); cancelEventBubble(); }
		  ,'mouseout': function(){ setCalendarStatus(null,false); cancelEventBubble(); }
		  ,'mouseover': function(){ setCalendarStatus(null,true); }
		}
	);
	
	//----------------------- control block ------------------
	var control = createDOM("DIV",null,null,["control"],null,calendar);
	
	var shiftLevelEvent = function(oEvent){
		var target = getEventTarget(oEvent);
		setCalendarStatus(false,true);
		switch(calender_type){
			case 'day':
				createDateSelectBox(target.getAttribute("year"),target.getAttribute("month"),0);
				break;
			case 'month':
				createMonthSelectBox(target.getAttribute("year"),0,true);
				break;
			case 'year':
				createYearSelectBox(target.getAttribute("year"),target.getAttribute("yearLevel"),true);
				break;
			default:
				return;
		}
	}
	
	var leftControl = createDOM( "DIV" , null , null ,["shift_left"] , {click:shiftLevelEvent} , control , TEXT_PRE );
	var rightControl = createDOM( "DIV" , null , null ,["shift_right"]  , {click:shiftLevelEvent} , control , TEXT_NEXT );
	
	var preLevelEvent = function(oEvent){
		var target = oEvent.target || oEvent.srcElement || this ;
		setCalendarStatus(false,true);
		switch(calender_type){
			case 'day':
				createMonthSelectBox(target.getAttribute("year"),target.getAttribute("month"),0);
				break;
			case 'month':
				createYearSelectBox(target.getAttribute("year"),1);
				break;
			case 'year':
				var yearLevel = parseInt(target.getAttribute("yearLevel"),10);
				if(yearLevel < working_pattern.getMaxYearLevel()){				
					createYearSelectBox(target.getAttribute("year"),yearLevel*10);
				}
				break;
		}
		workingNode.focus();
		setCalendarStatus(true,false);
	}
	
	var displayCell = createDOM( "DIV" ,null , null , ["calendar_title"] , {click:preLevelEvent} , control );
	
	//----------------------- content Table 顯示主體 ------------------
	var calender_type;
	
	var calender_main = createDOM("TABLE",{cellPadding:0,cellSpacing:0,border:0},null,["calendar_main"],null,calendar);
	
	var calender_body_day;
	var calender_body_month;
	var calender_body_year;
	
	//----------------------- 處理覆蓋區域 ------------------

	var cover = createDOM(
		"DIV"
		,null
		,null
		,["calendar_cover"]
		,{ 'mouseout': function(){ setCalendarStatus(null,false); } 
		 }
	);
	
	cover.appendChild(calendar);
	
	this.autoCreateDate = autoCreateDate;
	function autoCreateDate( elem ){
		
		/*if(window.localeDisplay){
			if(window.autoFormatToDate){ window.autoFormatToDate = null; }
		}*/

		if(isBasicType(elem)){
			var tempNode = document.getElementById(elem);
			if(!tempNode){
				tempNode = document.getElementsByName(elem);
				if(tempNode.length>0){
					tempNode = tempNode[0];
				}
			}
			elem = tempNode;
		}
		if(!isDOMObject(elem,"INPUT")){ elem = document.body; }
		
		var temp_inputs = isDOMObject(elem,"INPUT") ? [elem] : elem.getElementsByTagName("INPUT");
		
		for(var i = 0 ; i < temp_inputs.length ; i = i + 1 ){
			var node = temp_inputs[i];
			if(compareClass(node , "calendar_input")){ continue; }
			
			var datatype = node.getAttribute("datatype") || "";
			if( datatype.match(/^DATE|DATE$/i) ){
				/*if(window.$ && window.localeDisplay){
					locale = localeDisplay.registerToDate($(node));
				}*/
				var pattern = node.getAttribute("pattern") || "";	
				datatype = datatype.toUpperCase();
				var locale = datatype.substring(0,datatype.indexOf("DATE"));
				var pattern_length = getPatternSetting(locale,pattern).getPattern().length;
				createDOM(
					node
					,{"size":pattern_length+4,"maxLength":pattern_length}
					,null
					,["calendar_input"] 
					,{ focus:openCalendarFunc , click:openCalendarFunc , blur:function(oEvent){ setCalendarStatus(false,null); } } 
				);
				
				var img = node.nextSibling;
				while( !isDOMObject(img) ){
					if(img == null){
						break;
					}
					img = img.nextSibling;
				}
				if( isDOMObject(img,"IMG") ){
					var img_src = img.getAttribute("src") || "";
					if( img_src.match(/cal.gif$/i) 
					  || img_src.match(/calendar.gif$/i)
					  || img_src.match(/icon_calendar.gif$/i)
					)
					img.parentNode.removeChild(img);
				}
			}
		}

		// SCRUtil.js ---> autoFormatToDate 控制input輸入
		if(window.autoFormatToDate){ setTimeout(window.autoFormatToDate,500); }
	}
	
	function openCalendarFunc(oEvent){ 
		var target = getEventTarget(oEvent);
		if(target.getAttribute("readyToClose") == "true"){
			target.setAttribute("readyToClose" , false);
		}else{
			getCalendarFor(target); 
		}
	}
	
	//----------------------- function open and close ------------------
	this.showCalendar = showCalendar;
	function showCalendar( node ){
		if(isBasicType(node)){
			var tempNode = document.getElementById(node);
			if(!tempNode){
				tempNode = document.getElementsByName(node);
				if(tempNode.length>0){
					tempNode = tempNode[0];
				}
			}
			node = tempNode;
		}
		if(!isDOMObject(node , "INPUT" )){ return; }
		if( node == workingNode || node.disabled || node.readonly ){ return; }
		
		if(!compareClass(node , "calendar_input")){
			createDOM( node
				,null
				,null
				,["calendar_input","noImage"]
				,{ 'blur':function(oEvent){ setCalendarStatus(false,null); } } 
			);
		}
		
		if(workingNode != null){
			removeClass( workingNode.parentNode , 'calendar_parent' );
			removeClass( workingNode , "calendar_workingNode");
		}
		
		//註冊使用欄位
		workingNode = node;
		node.setAttribute("readyToClose" , false);
		setCalendarStatus(true,false);
		node.focus();
		
		var datatype = (workingNode.getAttribute("datatype") || "").toUpperCase();
		var pattern = node.getAttribute("pattern") || "";
		
		var locale = datatype.substring(0,datatype.indexOf("DATE"));
		
		working_pattern = getPatternSetting(locale,pattern);
		
		createDateSelectBoxByString(node.value);
		
		var node_parent = node.parentNode;
		
		if(! node_parent.style.position || node_parent.style.position == 'static' ){
			addClass( node_parent , "calendar_parent" );
		}
		
		node_parent.appendChild( cover );
		cover.style.display = '';
		
		addClass( workingNode , "calendar_workingNode" );
		
		var top = workingNode.offsetTop;
		var left = workingNode.offsetLeft;
		
		cover.style.paddingTop = ( top + workingNode.offsetHeight  - cover.offsetTop + 2) + 'px';
		cover.style.paddingLeft = ( left -cover.offsetLeft  ) + 'px';
		/*
		//可視範圍
		var maxLeft = document.body.scrollLeft;
		var maxTop= document.body.scrollTop;
		var maxRight = maxLeft + cover.offsetWidth;
		var maxBottom = maxTop + cover.offsetHeight;
		//節點位置
		
		
		var cell_top = node.offsetTop;
		var cell_left = node.offsetLeft;
		//cover.innerText = "[CALENDAR DEBUG] SCREEN_T_"+maxTop+"_B_"+maxBottom+"_L_"+maxLeft+"_R_"+maxRight+" X TOP_"+cell_top+" LEFT_"+cell_left+"    ";
		var isIE = navigator.userAgent.toLowerCase().indexOf("msie")!=-1 ;
		if( true){
			var findForm = node;
			do{
				cell_top -= findForm.scrollTop;
				cell_left -= findForm.scrollLeft;
				findForm = findForm.parentNode;
			}while(findForm && findForm.tagName != "BODY" );
		}
		var cell_bottom = cell_top + node.offsetHeight;
		var top = cell_bottom ;
		var left = cell_left;
		if( ( maxBottom - cell_bottom ) < 225 && top > 225 && top > ( maxBottom - cell_bottom ) ) { top = cell_top - (isIE?237:229) ; } else { top += 2; }
		if( maxRight - cell_left < 200 ) { left = maxRight - 200; if(left < 0 ){ left = 0; }}
		
		
		
		calendar.style.top = top+'px';
		calendar.style.left = left+'px';
		calendar.style.display = '';
		*/
		
	}
	
	function setCalendarStatus(worknode_status , calendar_status , waitTime ){
		(worknode_status!==null) && ( workingNodeIsFocus=(!!worknode_status));
		(calendar_status!==null) && ( calendarIsFocus=(!!calendar_status));
		
		waitTime = Math.abs(parseInt(waitTime,10)||500);
		
		if( !workingNodeIsFocus && !calendarIsFocus ){
			setTimeout(closeAfterWait,100);
		}
	}
	
	function closeAfterWait(){
		
		if( workingNode && !workingNodeIsFocus && !calendarIsFocus){
			//calendar.style.display = 'none';
			cover.style.display = 'none';
			removeClass( workingNode.parentNode , 'calendar_parent' );
			removeClass( workingNode , "calendar_workingNode");
			workingNode.setAttribute("readyToClose" , true);
			workingNode = null;
		}
	}
	
	//---------------------------- functions - create details ---------------------------------
	
	function createDateSelectBoxByString(testDate){
		var dateObj = working_pattern.parseDate(testDate);
		if(!dateObj){
			workingNode.value="";
			workingNodeValue = "";
			dateObj = new Date();
			createDateSelectBox( dateObj.getFullYear() , dateObj.getMonth() , dateObj.getDate() );
		}else{
			workingNodeValue = getPatternSetting().format( dateObj[0] , dateObj[1] , dateObj[2] );
			createDateSelectBox( dateObj[0] , dateObj[1] , dateObj[2] );
		}
	}
	
	function createDateSelectBox(year,month,date){
		
		//判斷傳入參數
		year = parseInt(year,10);
		month = parseInt(month,10);
		date = parseInt(date,10);
		if(month >= 12 ){ year = year + 1 ; month = 0;}
		else if (month <= -1){ year = year - 1 ; month = 11; }
		
		//設定參數
		var oneDateTime = (24*60*60*1000);
		
		//共用function
		var moveLevelFunction = function(oEvent){
			setCalendarStatus(false,true);
			var target = getEventTarget(oEvent) || this ;
			if(!compareClass(target,"grayBlock")){
				if(isDOMObject(workingNode,"INPUT")){
					var settingValue = createDateSelectBox(target.getAttribute("year"),target.getAttribute("month"),target.getAttribute("date"));
					workingNode.value = settingValue;
					if(settingValue !== workingNodeValue){
						if(Object.prototype.toString.apply(workingNode.onchange)  === '[object Function]' ){
							workingNode.onchange();
						}else if(workingNode.fireEvent){
							workingNode.fireEvent( "onchange" );
						}else{
							var changeEvent = document.createEvent("HTMLEvents");
							changeEvent.initEvent("change",true,false);
							workingNode.dispatchEvent(changeEvent);
						}
					}
					workingNode.focus();
					workingNode.select();
					setCalendarStatus(false,false);
					cancelEventBubble();
				}
			}else{
				createDateSelectBox(target.getAttribute("year"),target.getAttribute("month"),0);
			}
		}
		
		//設定參數上下月控制區
		createDOM( leftControl , {year:year,month:(month-1),date:0, title:"檢視上個月"} );
		createDOM( rightControl ,{year:year,month:(month+1),date:0, title:"檢視下個月"} );
		
		//若第一次呼叫，建立實體
		if( !calender_body_day ){
			calender_body_day = createDOM("TBODY",null,null,null,null,calender_main);
			var TR = createDOM("TR",null,null,["display_day_title"],null,calender_body_day);
			//星期顯示區
			for( var i = 0 ; i < 7 ; i = i + 1 ){
				var TH = createDOM("TH",null,null,null,null,TR);
				createDOM("DIV",null,null,["display_day","weekDay_"+i],null,TH);
			}	
			//日期顯示區 固定六列七欄
			for( var row_i = 0 ; row_i < 6 ; row_i = row_i + 1 ){
				var TR = createDOM("TR",null,null,null,null,calender_body_day);
				for( var col_i = 0 ; col_i < 7 ; col_i = col_i + 1 ){
					if( row_i == 5 && col_i == 6 ){
						//清除input 功能鍵
						var TD = createDOM("TD",null,null,null,null,TR);
						createDOM("DIV",null,{background:"#EEE",fontWeight:"bold"},["display_day","hover"],{
							click:function(){ 
								workingNode.value = ""; 
								if("" !== workingNodeValue){
									if(Object.prototype.toString.apply(workingNode.onchange)  === '[object Function]' ){
										workingNode.onchange();
									}else if(workingNode.fireEvent){
										workingNode.fireEvent( "onchange" );
									}else{
										var changeEvent = document.createEvent("HTMLEvents");
										changeEvent.initEvent("change",true,false);
										workingNode.dispatchEvent(changeEvent);
									}
								}
								workingNode.focus(); 
							}},TD,"清");
					}else if( row_i == 5 && col_i == 5 ){
						//今日日期 功能鍵
						
						var TD = createDOM("TD",null,null,null,null,TR);
						createDOM("DIV",null,{background:"#EEE",fontWeight:"bold",color:"black"},["display_day","hover"],{click:moveLevelFunction},TD,"今");
					}else{
						//普通功能
						var TD = createDOM("TD",null,null,null,null,TR);
						createDOM("DIV",{week_day:col_i},null,["display_day","weekDay_"+col_i,"hover"],{click:moveLevelFunction},TD,col_i);
					}
				}
			}
		}
		if(calender_type !== 'day' ){
			calender_body_day.style.display = '';
			(calender_body_month && (calender_body_month.style.display = 'none') );
			(calender_body_year && (calender_body_year.style.display = 'none') );
			calender_type = "day";
		}
		
		var header_display = working_pattern.format_YM(year,month);
		createDOM( displayCell ,{"year":year,"month":month,title:"切換至月份檢視"},null,null, null , null , header_display );
		
		//抓取主要月份資料
		var firstDateOfMonth = new Date();
		firstDateOfMonth.setFullYear(year,month,1);
		//本月第一天星期
		var day_startOfMonth = firstDateOfMonth.getDay();
		
		var weekday_display = working_pattern.getWeekDayDisplay();
		var THs = calender_body_day.getElementsByTagName("TH");
		for( var i = 0 ; i < (THs.length) ; i = i + 1 ){
			createDOM(THs[i].firstChild,null,null,null,null,null,weekday_display[i]);
		}
		
		//要開始作用的日期
		var work_date = new Date( firstDateOfMonth.valueOf() - ( ( day_startOfMonth || 7 ) * oneDateTime) );
		var TDs = calender_body_day.getElementsByTagName("TD");
		for( var i = 0 ; i < TDs.length; i = i + 1 ){ //扣掉兩個特殊功能
			var targetElem = TDs[i].firstChild;
			
			if(i==40){
				var today = new Date();
				
				createDOM(targetElem,{ year:today.getFullYear(),month:today.getMonth(),date:today.getDate() , title: working_pattern.format(today.getFullYear(),today.getMonth(),today.getDate())},null,null,null,null, working_pattern.getTodayTag());
				continue;
			}
			
			if(i==41){
				createDOM(targetElem,null,null,null,null,null, working_pattern.getClearTag());
				continue;
			}
			
			var s_month = work_date.getMonth();
			var s_date = work_date.getDate();
			
			var clazz = [];
			removeClass(targetElem , "grayBlock");
			removeClass(targetElem , "selected");
			
			if(s_month!==month){
				clazz.push("grayBlock");
			}else if(s_date===date){
				clazz.push("selected");
			}
			
			createDOM(
				targetElem
				,{ year:work_date.getFullYear(),month:s_month,date:s_date }
				,null
				,clazz
				,null
				,null
				,s_date);
				
			work_date = new Date( work_date.valueOf() + oneDateTime );
		}
		
		if(date){
			return working_pattern.format(year,month,date);
		}
	}
	
	function createMonthSelectBox( year , month , nohighlight ){
		
		//判斷傳入參數
		year = parseInt(year,10);
		month = parseInt(month,10);
		if(month >= 12 ){ year = year + 1 ; month = 0;}
		else if (month <= -1){ year = year - 1 ; month = 11; }
		
		//共用function
		var moveLevelFunction = function(oEvent){
			setCalendarStatus(false,true);
			var target = oEvent.target || oEvent.srcElement || this ;
			createDateSelectBox(target.getAttribute("year"),target.getAttribute("month"),0);
		}
		
		//設定參數上下年控制區
		createDOM( leftControl , {year:year-1,month:0,date:0 , title:"檢視上個年份"} );
		createDOM( rightControl ,{year:year+1,month:0,date:0 , title:"檢視下個年份"} );
		
		var month_display = working_pattern.getMonthDayDisplay();
		
		//若第一次呼叫，建立實體
		if( !calender_body_month ){
			calender_body_month = createDOM("TBODY",null,null,null,null,calender_main);
			for( var row_i = 0 ; row_i < 4 ; row_i = row_i + 1 ){
				var TR = createDOM("TR",null,null,null,null,calender_body_month);
				for( var col_i = 0 ; col_i < 3 ; col_i = col_i + 1 ){
					var s_month = row_i*3+col_i;
					var TD = createDOM("TD",null,null,null,null,TR);
					createDOM("DIV", {month:s_month},null,["display_month","hover"],{click:moveLevelFunction},TD);
					
				}
			}
		}
		
		var TDs = calender_body_month.getElementsByTagName("TD");
		for( var i = 0 ; i < TDs.length ; i = i + 1 ){
			var target = TDs[i].firstChild;
			createDOM(target,{ year:year} , null , null ,null,null , month_display[i] );
			if((!nohighlight)&&(i===month)){
				addClass(target,"selected");
			}else{
				removeClass(target,"selected");
			}
		}

		var header_display =  working_pattern.format_YM(year);
		createDOM( displayCell ,{year:year,title:"切換至區間年份檢視"},null,null,null,null , header_display );
		
		if(calender_type !== 'month' ){
			calender_body_month.style.display = '';
			(calender_body_day && (calender_body_day.style.display = 'none') );
			(calender_body_year && (calender_body_year.style.display = 'none') );
			calender_type = "month";
		}
		
	}
	
	function createYearSelectBox( year , yearLevel , nohighlight ){
		
		if(!yearLevel){yearLevel = 1; }
		yearLevel = parseInt(yearLevel,10);
		var yearLevel_10 = yearLevel*10;
		
		//判斷傳入參數
		year = parseInt(year,10);
		
		//共用function
		var moveLevelFunction = function(oEvent){
			setCalendarStatus(false,true);
			var target = getEventTarget(oEvent) || this ;
			var yearLevel = parseInt(target.getAttribute("yearLevel"),10);
			if(yearLevel===1){
				createMonthSelectBox(target.getAttribute("year"),0,true);
			}else{
				createYearSelectBox(target.getAttribute("year"),yearLevel/10,true);
			}
		}
		
		//設定參數上下年控制區
		createDOM( leftControl , {year:year-yearLevel_10,month:0,date:0,yearLevel:yearLevel,title:"檢視上個年份區間"} );
		createDOM( rightControl ,{year:year+yearLevel_10,month:0,date:0,yearLevel:yearLevel,title:"檢視下個年份區間"} );
		
		//若第一次呼叫，建立實體
		if( !calender_body_year ){
			calender_body_year = createDOM("TBODY",null,null,null,null,calender_main);
			for( var row_i = 0 ; row_i < 4 ; row_i = row_i + 1 ){
				var TR = createDOM("TR",null,null,null,null,calender_body_year);
				for( var col_i = 0 ; col_i < 3 ; col_i = col_i + 1 ){
					var TD = createDOM("TD",null,null,null,null,TR);
					var cell = createDOM("DIV",null,null,["display_year","hover"],{click:moveLevelFunction},TD,row_i+"/"+col_i);
					if(row_i+col_i === 0 || row_i*col_i === 6 ){
						addClass(cell , "grayArea");
					}
				}
			}
		}
		
		
		var header_display = working_pattern.format_YY(year , yearLevel_10 );
		createDOM( displayCell ,{year:year,yearLevel:yearLevel,title:"擴大區間年份檢視"},null,null, null , null , header_display );
		
		if(calender_type !== 'year' ){
			calender_body_year.style.display = '';
			(calender_body_day && (calender_body_day.style.display = 'none') );
			(calender_body_month && (calender_body_month.style.display = 'none') );
			calender_type = "year";
		}
		
		startYear = working_pattern.getStartYear(year,yearLevel);
		var TDs = calender_body_year.getElementsByTagName("TD");
		if(yearLevel === 1){
			for( var i = 0 ; i < TDs.length ; i = i + 1 ){
				var target = TDs[i].firstChild;
				removeClass(target,"multi");
				var title =  working_pattern.format_YY(startYear, yearLevel );
				createDOM(target,{ year:startYear , yearLevel:yearLevel },null,null,null,null,title);
				if((!nohighlight) && ( year === startYear )){
					addClass(target,"selected");
				}else{
					removeClass(target,"selected");
				}
				startYear = startYear + 1;	
			}
		}else{
			for( var i = 0 ; i < TDs.length ; i = i + 1 ){
				var target = TDs[i].firstChild;
				var title = working_pattern.format_YY(startYear, yearLevel );
				createDOM(target,{ year:startYear , yearLevel:yearLevel },null,["multi"],null,null,title);
				var endYear = (startYear+yearLevel-1);
				if( (!nohighlight) && ( year >= startYear ) && ( year <= endYear )){
					addClass(target,"selected");
				}else{
					removeClass(target,"selected");
				}
				startYear = startYear + yearLevel;
			}
		}
	}
	this.getValue = getValue;
	function getValue( node ){
		if(!isDOMObject(node , "INPUT" )){ return ""; }
		if(!compareClass(node , "calendar_input")){ return ""; }
		if(!node.value){ return "";}
		var datatype = (workingNode.getAttribute("datatype") || "").toUpperCase();
		var pattern = node.getAttribute("pattern") || "";
		var locale = datatype.substring(0,datatype.indexOf("DATE"));
		var datas = getPatternSetting(locale , pattern).parseDate(node.value);
		if(!datas){ node.value =""; return "";}
		return getPatternSetting().format(datas[0],datas[1],datas[2]);
	}
	
	this.setValue = setValue;
	function setValue( node , DBvalue){
		if(!isDOMObject(node , "INPUT" )){ return; }
		if(!compareClass(node , "calendar_input")){ return; }
		if(!DBvalue){ node.value =""; return;}
		var datas = getPatternSetting().parseDate(DBvalue);
		if(!datas){ node.value =""; return;}
		
		var datatype = (workingNode.getAttribute("datatype") || "").toUpperCase();
		var pattern = node.getAttribute("pattern") || "";
		var locale = datatype.substring(0,datatype.indexOf("DATE"));
		node.value = getPatternSetting(locale , pattern).format(datas[0],datas[1],datas[2]);
	}
	
	
	var calendar_patternSettings = {};
	function getPatternSetting(locale , pattern){
		if(!locale){
			locale = "default";
		}
		if(!pattern){
			switch(locale){
				case 'ROC':
					pattern = "yyyMMdd";
					break;
				case 'VN':
					pattern = "dd/MM/yyyy";
					break;
				default:
					pattern = "yyyy-MM-dd";
			}
		}
		
		var setting_key = pattern+"_"+locale;
		
		if( !calendar_patternSettings[setting_key]){ 
			calendar_patternSettings[setting_key] = new (function(){
				
				var inputPattern = pattern;
	
				var yReg = /y{2,4}/;
				var mReg = /M{2,3}/;
				var dReg = /d{2}/;
				
				var yPattern = pattern.match(yReg)[0];
				var mPattern = pattern.match(mReg)[0];
				var dPattern = pattern.match(dReg)[0];
				
				var calenderLevel = 1;
				if(!yPattern || !mPattern || !dPattern){
					alert("無法取得正確pattern");
					return null;
				}
				
				var yPosition = pattern.indexOf(yPattern);
				var mPosition = pattern.indexOf(mPattern);
				var dPosition = pattern.indexOf(dPattern);
				
				var maxP = Math.max(yPosition,mPosition,dPosition);
				var minP = Math.min(yPosition,mPosition,dPosition);
				
				if(yPosition == maxP){ yPosition = 3; }else if(yPosition == minP){ yPosition = 1; }else{ yPosition = 2; }
				if(mPosition == maxP){ mPosition = 3; }else if(mPosition == minP){ mPosition = 1; }else{ mPosition = 2; }
				if(dPosition == maxP){ dPosition = 3; }else if(dPosition == minP){ dPosition = 1; }else{ dPosition = 2; }
				
				var regString = ""
				if(pattern.match(/y[m,d]|m[y,d]|d[m,y]/i) != null ){
					regString = (pattern.replace(yPattern,"(\\d{2,"+yPattern.length+"})").replace(mPattern,(mPattern.length == 2 ?"(\\d{"+mPattern.length+"})" : "([\\w]*)")).replace(dPattern,"(\\d{"+dPattern.length+"})"));
				}else{
					regString = (pattern.replace(yPattern,"(\\d{2,"+yPattern.length+"})").replace(mPattern,(mPattern.length == 2 ?"(\\d{1,"+mPattern.length+"})" : "([\\w]*)")).replace(dPattern,"(\\d{1,"+dPattern.length+"})")); 
				}
				var parsePatternReg = new RegExp("^"+regString+"$");
				var month_display;
				var weekday_display;
				var displayTitleBeforeYear;
				var displayTitleAfterYear;
				var displayDateSplit;
				var spanBetweenYears;
				var maxYearLevel;
				
				var todayTag;
				var clearTag;
				
				//設定參數
				switch(locale){
					case 'VN':
						month_display = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];
						weekday_display=["S","M","T","W","T","F","S"];
						displayTitleBeforeYear = "";
						displayTitleAfterYear = "";
						spanBetweenYears = "~";
						maxYearLevel = 100;
						todayTag = "T";
						clearTag = "C";
						break;
					case 'ROC':
						month_display = ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"];
						weekday_display=["日","一","二","三","四","五","六"];
						displayTitleBeforeYear ="民國";
						displayTitleAfterYear = "年";
						spanBetweenYears = "至";
						maxYearLevel = 10;
						if(yPattern.length == 2){
							yPattern = "yyy";
							inputPattern.replace("yy","yyy");
						}
						todayTag = "今";
						clearTag = "清";
						break;
					default:
						month_display = ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"];
						weekday_display=["日","一","二","三","四","五","六"];
						displayYearChangeFunction = null;;
						displayTitleBeforeYear = "";
						displayTitleAfterYear = "";
						spanBetweenYears = "~";
						maxYearLevel = 100;
						todayTag = "今";
						clearTag = "清";
				}
				
				this.format = function( year , month , date ){
					if(locale == 'ROC'){
						year = year-1911;
					}else if(yPattern.length == 2){
						year =Math.floor( year % 100);
					}
					
					if(mPattern.length == 3){
						month = month_display[month];
					}else{
						month = month + 1;
					}
					return inputPattern.replace(yPattern,year).replace(mPattern,(month<10?"0"+""+month:month)).replace(dPattern,date<10?("0"+""+date):date);
				};
				
				this.format_YM = format_YM;
				function format_YM( year , month ){
					if(locale == 'ROC'){
						year = year-1911;
					}else if(yPattern.length == 2){
						year = Math.floor(year % 100);
					}
					if(month!=null){
						month = month_display[month];
						return displayTitleBeforeYear+year+displayTitleAfterYear+" "+month;
					}
					return displayTitleBeforeYear+year+displayTitleAfterYear;
				};
				
				this.format_YY = function( year , level ){
					if(locale == 'ROC'){
						year = year-1911;
					}
					year = year-Math.floor(year%level);
					if(level <= 1){
						return year+displayTitleAfterYear;
					}else{
						return year+" "+spanBetweenYears+"  "+(year+level-1)+displayTitleAfterYear;
					}
				};
				
				this.getStartYear = function( year , level ){
					if(locale == 'ROC'){
						year = year-1911;
					}
					year = year-Math.floor(year%(level*10))-Math.floor(level);
					if(locale == 'ROC'){
						year = year+1911;
					}
					return year;
				};
								
				this.parseDate = function(dateString){
					if(!dateString){ return null;}
					var rtn = dateString.match(parsePatternReg);
					if(!isArray(rtn) || rtn.length != 4 ){ return null; }
					
					var year =  parseInt(rtn[yPosition],10);
					var month = parseInt(rtn[mPosition],10);
					var date = parseInt(rtn[dPosition],10);
					
					if(locale == 'ROC'){
						year = year+1911;
					}if(yPattern.length == 2){
						year = year + 2000;
					}
					
					if(mPattern.length == 3){
						for(var i = 0 ; i < 12 ; i++){
							if(month_display[i] == month){
								month = i;
								break;
							}
						}
					}else{
						month = month-1;
					}
					
					return [ year , month , date ];
					
				};
				
				
				this.getWeekDayDisplay = function(){ return weekday_display; };
				this.getMonthDayDisplay = function(){ return month_display; };
				this.getMaxYearLevel = function(){ return maxYearLevel; };
				this.getPattern = function(){ return pattern; };
				this.getTodayTag = function(){ return todayTag; };
				this.getClearTag = function(){ return clearTag; };
			})();
		}
		return calendar_patternSettings[setting_key];
	}
	
	
	function createDOM( node , attrs , styles , classes , events , appendAt , content ){
		
		if(!isDOMObject( node )){
			node = document.createElement(node);	
		}
		
		if( isObject(attrs) ){
			for( var key in attrs ){
				if(isBasicType(attrs[key])){
					node.setAttribute( key , attrs[key] );
				}
			}
		}
		
		if( isObject(styles) ){
			for( var key in styles ){
				if(isBasicType(styles[key])){
					node.style[key] =  styles[key];
				}
			}
		}
				
		if( isArray(classes) ){
			for( var i = 0  ; i < classes.length ; i = i + 1  ){
				addClass( node , classes[i] );
			}
		}
		
		if( isObject(events) ){
			for( var key in events ){
				 setEventObserve( node , key , events[key] );
			}
		}
		
		if(isBasicType(content)){
			node.innerHTML = content;
		}
		
		if(isDOMObject( appendAt )){
			appendAt.appendChild(node);
		}
		
		return node;
	}
	
	function addClass( node , className){
		if( isBasicType(className) && !compareClass( node , className)){
			node.className = trim((node.className||"") +" "+ className);
		}
	}
	
	function getClass( node ){
		var classes = node.className;
		if(!isBasicType(classes)) { return []; }
		classes = classes.replace(/\s{2,}/g," ");
		return stringToArray(classes ," ");
	}
	
	function removeClass(node , compare ){
		if(!isBasicType(compare)){ return false; }
		var classes = node.className;
		if(!isBasicType(classes)) { return false; }
		classes = trim(classes);
		compare = trim(compare);		
		
		var reg=new RegExp("(^"+compare+"\\s)|(\\s"+compare+"\\s)|(\\s"+compare+"$)|(^"+compare+"$)","gi");
		node.className = trim(classes.replace(reg," ").replace(/\s{2,}/g," "));
	}
	
	function compareClass(node , compare ){
		if(!isDOMObject(node) || !isBasicType(compare)){ return false; }
		var classes = node.className;
		if(!isBasicType(classes)) { return false; }
		classes = trim(classes);
		compare = trim(compare);
		
		var reg=new RegExp("(^"+compare+"\\s)|(\\s"+compare+"\\s)|(\\s"+compare+"$)|(^"+compare+"$)","gi");
		
		return classes.match(reg) != null;
	}
	
	function getClass( node ){
		if(!isDOMObject(node)){return;}
		var classes = node.className||"";
		return classes.split(" ");
	}
	
	function trim(value)
	{
	    return (value||"").replace(/(^[\s]*)|([\s]*$)/g, "").replace(/^&nbsp;|&nbsp;$/g,"");
	}
	
	function getType(node){
		if(typeof(node) === 'undefined' ) {return "undefined"; }
		return Object.prototype.toString.apply(node);
	}
	
	function isBasicType( node ){
		var type = typeof(node);
		return !!( type === 'string' || type ==='number' || type === 'boolean' );
	} 
	
	function isNumeric(node){ 
		return isBasicType( node )&&(/^-?(0|[1-9]\d*|(?=\.))(\.\d+)?$/.test(node)); 
	} 
		
	function isString( node ){
		return !!(isBasicType( node ) && getType(node) === '[object String]');
	}
	
	function isObject(node){
		return !!(node && getType(node) == '[object Object]' && !isArray(node) && !isFunction(node) );
	}
	
	function isArray( node ){
		return !!(node && getType(node) === '[object Array]' && isNumeric( node.length ));
	}
	
	function isDOMObject( node , tagName ){
		return ( !!( node && node.tagName && node.nodeType === 1) ) && ( isString(tagName) ? (tagName.toUpperCase() == node.tagName):true ) ; 
	}
	
	function isFunction( node ){
		return !!(node && getType(node) === '[object Function]');
	}
	
	function clearAllChild(node){
		while(node.firstChild) {
			node.removeChild(node.firstChild); 
		} 		
	}
	
	function getEventTarget(e){
		if (!e) e = window.event;
		var target = e.target || e.srcElement;
		if(isDOMObject(target)){
			return target;
		}
		if(isDOMObject(e)){
			return e;
		}
		return false;
	}
	
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
	
	function stopEventObserving( elem , eventName , func  ){
		if( !(isDOMObject(elem) || elem==window || elem==document )  || !isString(eventName) ){ return; }
		if(Event.observe){
			Event.stopObserving(elem,eventName,func);
		}else if(elem.removeEventListener) {						//DOM2接口 with bubble
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
	
	function cancelEventBubble(e){ 
		if (!e) e = window.event; 
		//IE9 & Other Browsers 
		if (e.stopPropagation) { 
		  e.stopPropagation(); 
		} 
		//IE8 and Lower 
		else { 
		  e.cancelBubble = true; 
		} 
	}
	
	function setNodeText(node,text){
	if(node.textContent != undefined)
	  node.textContent=text;
	else
	  node.innerText=text;
	}

}