var weekdays = ["\u65e5","\u4e00", "\u4e8c", "\u4e09", "\u56db", "\u4e94", "\u516d"];

function setWeekTitle(week_title) {
	weekdays = week_title;	
}

function oneCalendarInit(calendarName) {
	var currDate = new Date();
    
    $("#"+calendarName).append(createOneCalendar(currDate.getFullYear(), currDate.getMonth()));
    
    $("li>a:has(img[src*=icon33])").on("click", function(){refreshCalendar(calendarName, -1);});
    $("li>a:has(img[src*=icon34])").on("click", function(){refreshCalendar(calendarName, 1);});
}

function threeCalendarInit(calendarName) {
	var currDate = new Date();
    
    $("#"+calendarName).append(createThreeCalendar(currDate.getFullYear(), currDate.getMonth()));
    
    $("li>a:has(img[src*=icon33])").on("click", function(){refreshCalendar(calendarName, -3);});
    $("li>a:has(img[src*=icon34])").on("click", function(){refreshCalendar(calendarName, 3);});
}

/**
 * 產生一組一個日曆
 */
function createOneCalendar(yy, mm) {
	var fkUL = $("<ul></ul>").addClass("grid3");
    //[20250103]調整new Date取法 不使用三參數用法，使用parse轉換後再宣告
    var currDate = new Date(Date.parse(yy.toString() + '-' + leftPad( mm + 1, 2, '0') + '-01', "yyyy-MM-dd"));
    
    var fkLI_C = $("<li></li>").append(createCalendar(currDate.getFullYear(), currDate.getMonth()));
    
    fkUL.append(fkLI_C);
    
    return fkUL;
}

/**
 * 產生一組三個日曆
 */
function createThreeCalendar(yy, mm) {
	var fkUL = $("<ul></ul>").addClass("grid3");
    //[20250103]調整new Date取法 不使用三參數用法，使用parse轉換後再宣告
    var yyyymmdd = yy.toString() + '-' + leftPad( mm + 1, 2, '0') + '-01';
    var currDate = new Date(Date.parse(yyyymmdd, "yyyy-MM-dd"));
    var prevDate = new Date(Date.parse(yyyymmdd, "yyyy-MM-dd"));
    var nextDate = new Date(Date.parse(yyyymmdd, "yyyy-MM-dd"));
    
    prevDate.setMonth(currDate.getMonth() -1);
    nextDate.setMonth(currDate.getMonth() +1);
    
    var fkLI_L = $("<li></li>").append(createCalendar(prevDate.getFullYear(), prevDate.getMonth()));
    var fkLI_C = $("<li></li>").append(createCalendar(currDate.getFullYear(), currDate.getMonth()));
    var fkLI_R = $("<li></li>").append(createCalendar(nextDate.getFullYear(), nextDate.getMonth()));
    
    fkUL.append(fkLI_L);
    fkUL.append(fkLI_C);
    fkUL.append(fkLI_R);
    
    return fkUL;
}

/**
 * 產生指定年月之日曆
 */
function createCalendar(yy, mm, sDate, eDate) {
	var showRangeOutText = true;  //是否顯示超過起迄範圍日期
	var arrSDate = null;  //起始日期
	var arrEDate = null;  //起迄日期
	var classColor = "gray"; //灰
	
	if(typeof sDate != 'undefined'){
		arrSDate = sDate.split('-');
		arrEDate = eDate.split('-');
		showRangeOutText = false;
	}

	var cTable = $("<table></table>").addClass("calendar");
	var cTitleText = $("<tr></tr>").append($("<th></th>").attr("colspan", 7).text(yy + "-" + (mm+1)));
	cTable.append(cTitleText);

	var cWeekTitle = $("<tr></tr>").addClass("weekday");
	
	for (var idx in weekdays) {
		var cTd = $("<td></td>").text(weekdays[idx]);
		cWeekTitle.append(cTd);
	}
	cTable.append(cWeekTitle);
	var cContentTR = $("<tr></tr>");
	var cContentTD = $("<td></td>").attr("colspan", 7);
	
	var cSubTable = $("<table></table>").addClass("date");
	//[20250103]調整new Date取法 不使用三參數用法，使用parse轉換後再宣告
	var theDate = new Date(Date.parse(yy.toString() + '-' + leftPad( mm + 1, 2, '0') + '-01', "yyyy-MM-dd"));
	
	var theFirstDayInWeek = theDate.getDay();
	var numOfWeek = 1;
	
	while(theDate.getMonth() == mm) {
		var cTr = $("<tr></tr>");
		for(var i = 0; i < 7 ; i ++){
			var cTd = $("<td></td>");
			if (theDate.getMonth() == mm && (numOfWeek > 1 || i >= theFirstDayInWeek)) {
				var addColorGray = false;  //是否加上超過範圍顏色
				
				if(!showRangeOutText){
					if(yy == arrSDate[0] && (mm+1) == arrSDate[1]){
						if(parseInt(theDate.getDate()) < parseInt(arrSDate[2])){
							addColorGray = true;
						}
					}
					if(yy == arrEDate[0] && (mm+1) == arrEDate[1]){
						if(parseInt(theDate.getDate()) > parseInt(arrEDate[2])){
							addColorGray = true;
						}
					}
				}
				
				if(addColorGray){
					cTd.addClass(classColor);
				}
				cTd.text(theDate.getDate());
				theDate.setDate(theDate.getDate() + 1);
			}
			cTr.append(cTd);
		}
		cSubTable.append(cTr);
		numOfWeek ++;
	}
	cContentTR.append(cContentTD.append(cSubTable));
	cTable.append(cContentTR);
	return cTable;
}

/**
 * 移除舊日曆並產生新日曆
 */
function refreshCalendar(calendarName, diffOfMonth) {
	var calendarNum = $("#FKWebCalendar table[class=date]").length;
	var centerDateString = "";
	if (calendarNum == 1) {
		centerDateString = $("table[class=calendar] tr th")[0].innerHTML;
	} else if (calendarNum == 3){
		centerDateString = $("table[class=calendar] tr th")[1].innerHTML;
	} else {
		return;
	}	
	
	//[20250103]調整new Date取法 不使用三參數用法，使用parse轉換後再宣告
	var centerDate = new Date(Date.parse(centerDateString + '-01', "yyyy-MM-dd"));
	centerDate.setMonth(centerDate.getMonth() + diffOfMonth);
	
	$("#"+calendarName+" > ul").remove();
	if (calendarNum == 1) {
		$("#"+calendarName).append(createOneCalendar(centerDate.getFullYear(), centerDate.getMonth()));
	} else if (calendarNum == 3){
		$("#"+calendarName).append(createThreeCalendar(centerDate.getFullYear(), centerDate.getMonth()));
	}
}

/** 
 * 設定指定日期顯示特定顏色
 */
function setDateColor(theDate, colorName) {
	var sTheDate = theDate.split("-");
	var yymm = parseInt(sTheDate[0])+"-"+parseInt(sTheDate[1]);
	var dd = parseInt(sTheDate[2])+"";
	var idx1 = -1;
	var idx2 = -1;
	
	$(".calendar th").each(
			function(idx, elem) {
				if (elem.innerHTML == yymm) {
					idx1 = idx;
				}
			});
	
	if (idx1 < 0) return;
	
	$(".calendar table[class=date]:eq(" + idx1 + ") td").each(
			function(idx, elem) {
				if (elem.innerHTML == dd) {
					idx2 = idx;
				}
			});
	
	if (colorName != "") {
		$(".calendar table[class=date]:eq(" + idx1 + ") td:eq(" + idx2 + ")").addClass(colorName);
	} else {
		$(".calendar table[class=date]:eq(" + idx1 + ") td:eq(" + idx2 + ")").removeClass();
	}
	
}

/**
 * leftPad('01', 2, '0') -> '01'
 * leftPad(1, 2, '0') -> '01'
 * leftPad('30', 2, '0') -> '30'
 * leftPad(30, 2, '0') -> '30'
 * 
 * leftPad('030', 2, '0') -> '030'
 * leftPad(30, 4, 'x') -> 'xx30'
 */
function leftPad(str, length, padChar) {
	str = str.toString();
    var padStr = "";

    while (padStr.length < length - str.length) {
        padStr += padChar;
    }

    return padStr + str;
}