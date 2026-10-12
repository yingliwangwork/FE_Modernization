/**
 * 程式：date.js日期相關js。
 * 作者：新契約小組。
 * 功能：提供日期相關js。
 * 完成：2004/02/05。
 * 說明：
 * 更新：
 *
 *           Date         Author                                                    Description
 *      ==============  ==========  ==============================================================================================================
 * 　　　 2005/07/21                  增加 IBM isROCdate 及 94 年假日array
 * 　　　 2010/09/02      劉本傑      申請書編號「100823000284」
 *                　　　                1.於下列方法增加判斷「西元 1931 年以前（不含）及民國 20 年以前（不含）算是不正確之日期格式」。
 * 　 　　                                a.isROCdate、isROC13Mdate、isROC13MonthFirstDay、isADdate。
 * 　　 　                                b.若不限制，請傳入 false，預設為限制。
 * 　　　                                 c.若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。
 * 　　　                               2.修改 Javascript Docs 表示。
 * 　　　 2011/09/02      劉本傑      新增日期格式顯示處理之方法「SimpleDateFormat」
 * 　　　 2011/09/13      劉本傑      計算二日期相差天數之方法「diffDay」，提供第二個引數判斷是否為民國年月日格式。
 * 　　　                               1.未指定是否為民國年時，則依第一個參數傳入之格式判斷，不符合西元日期格式時，則以民國日期進行處理。
 * 　　　                             新增計算二民國日期相差天數之方法「diffDayROC」。
 * 　　　                             新增計算二西元日期相差天數之方法「diffDayY2K」。
 * 　　　 2012/04/19      劉本傑      增加取得現在的 timestamp。
 * 　　　 2014/03/12      劉本傑      public function「SimpleDateFormat」增加支援時間格式。
 * 
 * 
 *           public function                                                        Description
 *      =============================   =============================================================================================================
 *        isROCdate                       判斷民國年月日。
 *        diffDay                         計算二日期相差天數（日期2-日期1）。
 *        diffDayROC                      計算二民國日期相差天數之方法（日期2-日期1）。
 *        diffDayY2K                      計算二西元日期相差天數之方法（日期2-日期1）。
 *        toROC                           將西元年日期轉為民國年日期。
 *        toY2K                           將民國年日期轉為西元年日期。
 *        getDutyDay                      推放款應繳日。
 *        isLeap                          判斷傳入之西元日期是否為閏年。
 *        addDate                         日期加減。
 *        getY2KToday                     取得當天日期(西元年格式)。
 *        getToday                        取得當天日期(民國年格式)。
 *        getTime                         取得現在時刻。
 *        isHoliday                       判斷是否為休假日。
 *        isROC13Mdate                    檢核 民國 13 工作月。
 *        isROC13Month                    檢查年月是否為民國年，且 01<=月份<=13。
 *        isROC13MonthFirstDay            檢查年月是否為民國年，且 01<=月份<=13，且日必需等於'01'。
 *        isADdate                        判斷西元年。
 *        stringToDate_ROC                民國日期轉為日期物件。
 *        stringToDate_Y2K                西元日期轉為日期物件。
 *        SimpleDateFormat                使用方式詳見該方法之註解說明。
 *        dateJs.getCurrentTimeStamp      取得現在的 timestamp。
 *        dateJs.isDateYM			      檢核是否為日期年月格式。
 * 
 **/

/**
 *	@public
 *	@class check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyy-MM-DD, yyyMMDD, yyy/MM/DD, yyy-MM-DD」。 <br>
 *	       若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。 <br>
 *	       若為民國前之年月日時，會在日期前加上 - ，如 民國前 1 年 2 月 3 日為 -000203，民國前 2 年 2 月 3 日為 -010203。 <br>
 *	       Ex : isROCdate('191231')                 return  false。 <br>
 *	            isROCdate('191231', false)          return  true 。 <br>
 *	            isROCdate('-010203', false)         return  false。 <br>
 *	            isROCdate('-010203', false, true)   return  true 。 <br>
 *	            isROCdate('1000203')                return  true 。 <br>
 *	            isROCdate('200/01/01')              return  true 。 <br>
 *	            isROCdate('100-10-28')              return  true 。 <br>
 *	@param srcData (String) : 民國年月日。
 *	@param yearLimit (boolean) : 民國年是否限制在 20 年以前（不含），若不限制，請傳入 false，預設為限制。
 *	@param isROCBefore (boolean) : 是否為民國年前，若輸入參數為民國前，請傳入 true ，預設為 false。
 **/
function isROCdate(srcData, yearLimit, isROCBefore){

	var d = stringToDate_ROC(srcData, isROCBefore);

	if(!d || d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3 ){
		return false
	}

	if(yearLimit!==false){
/*
		西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
		西元 1911-01-01（民國 000101）視為合理日期
		Date getMonth() - Returns the month from the date object as a value from 0 through 11.
		Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
*/
		if( ( !( d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1 )) && d.getFullYear() < 1931){
			return false;
		}
	}

	return true;

}

/**
 *	@public
 *	@class 計算二日期相差天數（日期2-日期1）。 <br>
 *	       Ex : diffDay('990901', '990901')         return   0。 <br>
 *	            diffDay('990901', '990903')         return   2。 <br>
 *	            diffDay('990901', '990820')         return -12。 <br>
 *	            diffDay('-11231', '000113')         return  13。 <br>
 *	            diffDay('100/10/01', '100/10/28')   return   1。 <br>
 *	            diffDay('100-10-28', '100-10-29')   return   1。 <br>
 *	            diffDay('2011/09/13', '2011/09/16') return   3。 <br>
 *	            diffDay('2011-08-13', '2011-09-13') return -31。 <br>
 *	            diffDay('20110823', '20110913')     return  21。 <br>
 *	@param str1 (String) : 日期1
 *	@param str2 (String) : 日期2
 *	@param isROC (boolean) : 是否為民國年月日格式。
 **/
function diffDay(str1, str2, isROC){

	var dateInt1;
	var dateInt2;
/*
	未指定是否為民國年時，則依第一個參數傳入之格式判斷，不符合西元日期格式時，則以民國日期進行處理
*/
	if(typeof(isROC) == 'undefined'){
		dateInt1 = stringToDate_Y2K(str1);
		isROC = dateInt1?false:true;
	}else if(!isROC){
		dateInt1 = stringToDate_Y2K(str1);
	}

	if(isROC){
		dateInt1 = stringToDate_ROC(str1, true);
		dateInt2 = stringToDate_ROC(str2, true);
	}else{
		dateInt2=stringToDate_Y2K(str2);
	}

	return ((dateInt2-dateInt1)/86400000);

}

/**
 *	@public
 *	@class 計算二民國日期相差天數之方法（日期2-日期1）。 <br>
 *	       Ex : diffDayROC('990901', '990901') return   0。 <br>
 *	            diffDayROC('990901', '990903') return   2。 <br>
 *	            diffDayROC('990901', '990820') return -12。 <br>
 *	            diffDayROC('-11231', '000113') return  13。 <br>
 *	@param strRoc1 (String) : 民國日期1
 *	@param strRoc2 (String) : 民國日期2
 **/
function diffDayROC(strRoc1,strRoc2){
	return diffDay(strRoc1,strRoc2,true);
}

/**
 *	@public
 *	@class 計算二西元日期相差天數之方法（日期2-日期1）。 <br>
 *	       Ex : diffDayY2K('2011/09/13', '2011/09/16') return   3。 <br>
 *	            diffDayY2K('2011-08-13', '2011-09-13') return -31。 <br>
 *	            diffDayY2K('20110823', '20110913')     return  21。 <br>
 *	@param strRoc1 (String) : 西元日期1
 *	@param strRoc2 (String) : 西元日期2
 **/
function diffDayY2K(str1,str2){
	return diffDay(str1,str2,false);
}

/**
 *	@public
 *	@class 將西元年日期轉為民國年日期。 <br>
 *	@param Y2Kdate (String) : 西元日期
 **/
function toROC(Y2Kdate){
	if (Y2Kdate.length!=10) return "";
	if (Y2Kdate==""){
		ROCdate="";
	}else{
		ROCdate = ((parseInt(Y2Kdate.substring(0,4),10))-1911)+Y2Kdate.substring(5,7)+Y2Kdate.substring(8,10);
	}
	return ROCdate;
}

/**
 *	@public
 *	@class 將民國日期轉為西元日期。 <br>
 *	@param ROCdate (String) : 民國日期
 **/
function toY2K(ROCdate){

	var d = stringToDate_ROC(ROCdate, true);

	if(!d || d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3 ){
		return ROCdate
	}

	return d.getFullYear()+"-"+RegExp.$2+"-"+RegExp.$3;

}

//===========================

/**
 *	@public
 *	@class 將數字日期轉為資料庫日期。 <br>
 *	@param inputDate (String) : 西元年月日。
 **/
function toDBDate(inputDate)
{
	var outputDate;
	if (inputDate.length == 8){
		outputDate = inputDate.substring(0,4)+"-"+inputDate.substring(4,6)+"-"+inputDate.substring(6);
	} else if (inputDate.length == 10 && inputDate.indexOf("-") < 0) {
		outputDate = inputDate.substring(0,4)+"-"+inputDate.substring(5,7)+"-"+inputDate.substring(8);
	} else {
		outputDate = inputDate;
	}
	return outputDate;
}

/**
 *	@public
 *	@class 將數字日期轉為資料庫日期。 <br>
 *	@param inputObj (Object) : 輸入日期欄位之物件。
 **/
function dateFormatField(inputObj) {
	var dateValue = inputObj.value;
	var isValid = true;
	if (isADdate(dateValue, false)) {
		inputObj.value = toDBDate(dateValue);
	} else {
		isValid =false;
	}
	return isValid;
}

/**
 *	@public
 *	@class 將數字日期轉為資料庫日期。 <br>
 *	@param event (event)
 **/
function dateFieldChange( event ){
    var input = event.srcElement;
    if( input.value == "" ) { return; }
    if( !dateFormatField( input ) ) {
	    alert( "日期錯誤" );
		input.focus();
		input.select();
	}
}

/**
 *	@public
 *	@class 推放款應繳日。 <br>
 *	@param strDate (String)
 *	@param dudt (String)
 *	@param intMonth (Number)
 **/
function getDutyDay(strDate, dudt, intMonth){
/*
	推intMonth月，預防addDate("2002-03-31",0,-1,0)-->2002-03-03狀況，所以用該月 1 號來推
*/
	strDate = strDate.substr(0,8) + "01";
	strDate = addDate(strDate,0,intMonth,0);
	strYY = strDate.substr(0,4);
	strMM = strDate.substr(5,2);
	strDD = dudt;
	intMM = parseInt(strMM);
	intDD = parseInt(dudt);

	strYMD = strYY+"-"+strMM+"-";

	if (intDD <= 28) return strYMD + strDD;

	if (intMM == 2)
	{	if(isLeap(strDate)) return strYMD + (intDD > 29 ? "29":strDD);
		else return strYMD + (intDD > 28 ? "28":strDD);
	}
	else if ((intMM==4 || intMM==6 || intMM==9 || intMM==11 ) && intDD > 30) return strYMD + "30";
	else if ((intMM==1 || intMM==3 || intMM==5 || intMM==7 || intMM==8 || intMM==10 || intMM==12 ) && intDD > 31) return strYMD + "31";

	return strYMD + strDD;
}

/**
 *	@public
 *	@class 判斷傳入之西元日期是否為閏年。 <br>
 *	@param datInput (String)
 **/
function isLeap(datInput){

	var intYY;
	if (typeof datInput == 'string') {
		if(datInput.length>4){
			intYY = parseInt(datInput.substring(0,4), 10);
		}else{
			intYY = parseInt(datInput, 10);
		}
	} else {
	    intYY = datInput;
	}

	if (intYY%4 == 0){
		if (intYY%100 == 0){
			 if (intYY%400 == 0){
			 	return true;
			 }else{
			 	return false;
			 }
		}else{
			return true;
		}
	}else{
		return false;
	}
	return false;
}

/**
 *	@public
 *	@class 日期加減。 <br>
 *         Ex : addDate("2002-03-31",0,-1,0) return 2002-03-03 。<br>
 *	@param strDate (String) : 傳入日期之年月日（DB2之日期格式為yyyy-MM-dd）。
 *	@param intMM (Number) : 欲加減之年數。
 *	@param intMM (Number) : 欲加減之月數。
 *	@param intDD (Number) : 欲加減之天數。
 **/
function addDate(strDate, intYY, intMM, intDD){
	if ( !strDate && strDate.length != 10){return ""};
	datDate = new Date(parseInt(strDate.substr(0,4),10)+intYY,parseInt(strDate.substr(5,2),10) + intMM - 1,parseInt(strDate.substr(8,2),10)+ intDD);
	intM = datDate.getMonth()+1;
	strM = (intM<10 ? "-0":"-")+intM;
	intD = datDate.getDate();
	strD = (intD<10 ? "-0":"-")+intD;
	return datDate.getFullYear()+strM+strD;
}

/**
 *	@public
 *	@class 取得當天日期(西元年格式)。 <br>
 **/
function getY2KToday(){
	var dateObject = new Date();
	var yyyy = String(dateObject.getFullYear());
	var MM = String(dateObject.getMonth() + 1);
	if(MM.length <2 ){
		MM = "0"+MM;
	}
	var dd = String(dateObject.getDate());
	if(dd.length <2 ){
		dd = "0"+dd;
	}
	var returnDate = yyyy+"-"+MM+"-"+dd;
	return returnDate;
}

/**
 *	@public
 *	@class 取得當天日期(民國年格式)。 <br>
 **/
function getToday(){
	var dateObject = new Date();
	var yy = String(dateObject.getFullYear()-1911);
	var MM = String(dateObject.getMonth() + 1);
	if(MM.length <2 ){
		MM = "0"+MM;
	}
	var dd = String(dateObject.getDate());
	if(dd.length <2 ){
		dd = "0"+dd;
	}
	var returnDate = yy+MM+dd;
	return returnDate;
}

/**
 *	@public
 *	@class 取得現在時刻。 <br>
 **/
function getTime(){
    var dt = new Date();
    hh=String(dt.getHours());
    mm=String(dt.getMinutes());
    ss=String(dt.getSeconds());
    if(hh.length < 2){
       hh="0"+hh;
    }
    if(mm.length < 2){
       mm="0"+mm;
    }
    if(ss.length<2){
       ss = "0"+ss;
    }
    time=hh+mm+ss;
    return time;
}

/**
 *	@public
 *	@class 判斷是否為休假日。 <br>
 *	@param day (String)
 **/
function isHoliday(day){
  	var Holiday = new Array(
						"921129","921130","921206","921207","921213","921214","921220","921221","921227","921228",
						"930101","930103","930104","930110","930111","930117","930118","930121","930122","930123","930124","930125","930126","930131", 
						"930201","930207","930208","930214","930215","930221","930222","930228","930229",
						"930306","930307","930313","930314","930320","930321","930327","930328",
						"930403","930404","930410","930411","930417","930418","930424","930425",
						"930501","930502","930508","930509","930515","930516","930522","930523","930529","930530",
						"930605","930606","930612","930613","930619","930620","930622","930626","930627",
						"930703","930704","930710","930711","930717","930718","930724","930725","930731",
						"930801","930807","930808","930814","930815","930821","930822","930828","930829",
						"930904","930905","930911","930912","930918","930919","930925","930926","930928",
						"931002","931003","931009","931010","931016","931017","931023","931024","931030","931031",
						"931106","931107","931113","931114","931120","931121","931127","931128",
						"931204","931205","931211","931212","931218","931219","931225","931226",
						"940101","940102","940108","940109","940115","940116","940122","940123","940129","940130",
						"940206","940207","940208","940209","940210","940211","940212","940213","940219","940220","940226","940227","940228",
						"940305","940306","940312","940313","940319","940320","940326","940327",
						"940402","940403","940405","940409","940410","940416","940417","940423","940424","940430",
						"940501","940502","940507","940508","940514","940515","940521","940522","940528","940529",
						"940604","940605","940611","940612","940618","940619","940625","940626",
						"940702","940703","940709","940710","940716","940717","940723","940724","940730","940731",
						"940806","940807","940813","940814","940820","940821","940827","940828",
						"940903","940904","940910","940911","940917","940918","940924","940925",
						"941001","941002","941008","941009","941010","941015","941016","941022","941023","941029","941030",
						"941105","941106","941112","941113","941119","941120","941126","941127"										
					)
	for(h=0;h < Holiday.length;h++){
		if(day == Holiday[h]){
			return true;
		}
	}
	return false;
} 

/**
 *	@public
 *	@class check AD date format, 3 pattern can be accepted yyyyMMdd, yyyy/MM/dd, yyyy-MM-dd」。 <br>
 *	       西元 1931 年以前算是不正確之日期格式。<br>
 *	       西元 1911-01-01 視為合理日期。<br>
 *	@param srcDate (String) : 西元年月日。
 **/
function isDate(srcDate){
	return isADdate(srcDate);
}

/**
 *	@public
 *	@class check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyyMMDD, yyy/MM/DD」 and allow 13Month。 <br>
 *	       若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。 <br>
 *	@param srcData (String) : 民國年月日。
 *	@param yearLimit (boolean) : 民國年是否限制在 20 年以前（不含），若不限制，請傳入 false，預設為限制。
 **/
function isROC13Mdate(srcData, yearLimit) {

	var d;
	var month;
	if( ((srcData.match(/^(\d{2})(\d{2})(\d{2})$/))) || 
	    ((srcData.match(/^(\d{3})(\d{2})(\d{2})$/))) ||
	    ((srcData.match(/^(\d{4})(\d{2})(\d{2})$/))) ||
	    ((srcData.match(/^(\d{2})\/(\d{2})\/(\d{2})$/))) || 
	    ((srcData.match(/^(\d{3})\/(\d{2})\/(\d{2})$/))) ||
	    ((srcData.match(/^(\d{4})\/(\d{2})\/(\d{2})$/))) ) {
	    month = RegExp.$2
	    if(month==13) {
			month = 12;
	    }
   	    d = new Date((eval(RegExp.$1)+1911)+"/"+month+"/"+RegExp.$3);	    
    }

	if(!d || d.getMonth()!=(month-1)||d.getDate()!=RegExp.$3){
		return false
	}

	if(yearLimit!==false){
/*
		西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
		西元 1911-01-01（民國 000101）視為合理日期
		Date getMonth() - Returns the month from the date object as a value from 0 through 11.
		Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
*/
		if( ( !( d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1 )) && d.getFullYear() < 1931){
			return false;
		}
	}

	return true;	

}

/**
 *	@public
 *	@class 檢查年月是否為民國年，且 01<=月份<=13。 <br>
 *         check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyyMMDD, yyy/MM/DD」 and allow 13Month。 <br>
 *	@param srcData (String) : 民國年月日。
 **/
function isROC13Month(srcData) {

	var d;
	var month;
	if( ((srcData.match(/^(\d{2})(\d{2})$/))) || 
	    ((srcData.match(/^(\d{3})(\d{2})$/))) ) {
	    month = RegExp.$2
	    if(month==13) {
			month = 12;
	    }
   	    d = new Date((eval(RegExp.$1)+1911)+"/"+month+"/01");	    
    }

	if(!d || d.getMonth()!=(month-1)){
		return false
	}
	return true;	

}

/**
 *	@public
 *	@class 檢查年月是否為民國年，且 01<=月份<=13，且日必需等於'01'。 <br>
 *         check ROC date format, 4 pattern can be accepted 「yyMMDD, yy/MM/DD, yyyMMDD, yyy/MM/DD」 and allow 13Month。 <br>
 *	       若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。 <br>
 *	@param srcData (String) : 民國年月日。
 *	@param yearLimit (boolean) : 民國年是否限制在 20 年以前（不含），若不限制，請傳入 false，預設為限制。
 **/
function isROC13MonthFirstDay(srcData, yearLimit){

	var d;
	var month;
	var day;
	if( ((srcData.match(/^(\d{2})(\d{2})(\d{2})$/))) || 
	    ((srcData.match(/^(\d{3})(\d{2})(\d{2})$/))) ){
	    month = RegExp.$2
	    day = RegExp.$3
	    if(day!='01') {
	    	return false;
	    }
	    
	    if(month==13) {
			month = 12;
	    }
   	    d = new Date((eval(RegExp.$1)+1911)+"/"+month+"/01");	    
    }

	if(!d || d.getMonth()!=(month-1)){
		return false
	}

	if(yearLimit!==false){
/*
		西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
		西元 1911-01-01（民國 000101）視為合理日期
		Date getMonth() - Returns the month from the date object as a value from 0 through 11.
		Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
*/
		if( ( !( d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1 )) && d.getFullYear() < 1931){
			return false;
		}
	}

	return true;

}

/**
 *	@public
 *	@class check AD date format, 3 pattern can be accepted yyyyMMdd, yyyy/MM/dd, yyyy-MM-dd」。 <br>
 *	       若限制在 20 年以前（不含）時，在西元 1911-01-01（民國 000101）會視為合理日期。 <br>
 *	@param srcData (String) : 西元年月日。
 *	@param yearLimit (boolean) : 西元年是否限制在 1931 以前（不含），若不限制，請傳入 false，預設為限制。
 **/
function isADdate(srcData, yearLimit){

	var d = stringToDate_Y2K(srcData);

	if(!d || d.getMonth()!=(RegExp.$2-1)||d.getDate()!=RegExp.$3){
		return false
	}

	if(yearLimit!==false){
/*
		西元 1931 年以前（不含）或民國 20 年以前（不含）算是不正確之日期格式
		西元 1911-01-01（民國 000101）視為合理日期
		Date getMonth() - Returns the month from the date object as a value from 0 through 11.
		Date getDate() - Get the day of the month. It is returned as a value between 1 and 31.
*/
		if( ( !( d.getFullYear() == 1911 && d.getMonth() == 0 && d.getDate() == 1 )) && d.getFullYear() < 1931){
			return false;
		}
	}

	return true;
}

/**
 *	@public
 *	@class 轉為日期物件
 *	@param srcData (String) : 民國日期
 *	@param isROCBefore (boolean) : 是否為民國年前，若輸入參數為民國前，請傳入 true ，預設為 false。
 *	@return Date
 *	@author 劉本傑
 *	@version 1.00
 **/
function stringToDate_ROC(srcData, isROCBefore){

	var rocDateIsBefore = false;

	if(isROCBefore===true){
		if (srcData.substring(0,1)=="-"){ 
			srcData = srcData.substring(1,srcData.length);
			rocDateIsBefore = true;
		}
	}

	var addValue = rocDateIsBefore?-1911:1911;

	var d;
	if((srcData.match(/^(\d{1})(\d{2})(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{2})(\d{2})(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{3})(\d{2})(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{1})\/(\d{2})\/(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{2})\/(\d{2})\/(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{3})\/(\d{2})\/(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{1})\-(\d{2})\-(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{2})\-(\d{2})\-(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}else if((srcData.match(/^(\d{3})\-(\d{2})\-(\d{2})$/))){ d = new Date((eval(RegExp.$1)+addValue)+"/"+RegExp.$2+"/"+RegExp.$3);
	}

	return d;
}

/**
 *	@public
 *	@class 轉為日期物件
 *	@param srcData (String) : 西元日期
 *	@return Date
 *	@author 劉本傑
 *	@version 1.00
 **/
function stringToDate_Y2K(srcData){
	var d;
	if((
		srcData.match(/^(\d{4})(\d{2})(\d{2})$/))
		|| (srcData.match(/^(\d{4})\/(\d{2})\/(\d{2})$/))
		|| (srcData.match(/^(\d{4})-(\d{2})-(\d{2})$/))
	) {
		d = new Date(RegExp.$1+"/"+RegExp.$2+"/"+RegExp.$3);
	}
	return d;
}

/**
 *	@public
 *	@class 環境語言：中華民國
 *	@author 劉本傑
 *	@version 1.00
 **/
SimpleDateFormat.TW = 'tw';
/**
 *	@public
 *	@class 環境語言：美國
 *	@author 劉本傑
 *	@version 1.10
 **/
SimpleDateFormat.US = 'en';
/**
 *	@public
 *	@class 產生 SimpleDateFormat 後，再利用其進行日期格式顯示處理
 *	       Ex1.
 *	         var df = new SimpleDateFormat('yyyy-MMMM-dd EEEE', SimpleDateFormat.US);
 *	             df.format('2011-08-31')	return  '2011-August-31 Wednesday'
 *
 *	       Ex2.
 *	         var df = new SimpleDateFormat('yyy/MM/dd (EE)', SimpleDateFormat.TW);
 *	             df.format('2011/08/31')	return  '100/08/31 (三)'
 *
 *	       Ex3.
 *	         var df = new SimpleDateFormat('MMM/dd/yy (EE)', SimpleDateFormat.US);
 *	             df.format('2011/08/31')	return  'Aug/31/11 (Wed)'
 *
 *	       Ex4.
 *	         var df = new SimpleDateFormat('中華民國 yyy 年 MMM 月 dd 日 EEEE', SimpleDateFormat.TW);
 *	             df.format('20110831')	    return  '中華民國 100 年 八 月 31 日 星期三'
 *
 *	       Ex5.
 *           var df_timestamp = new SimpleDateFormat('中華民國 yyy 年 MMM 月 dd 日 EEEE HH:mm:ss', SimpleDateFormat.TW);
 *	             df_timestamp.format('2014-03-11 20:01:02.456000')	    return  '中華民國 103 年 三 月 11 日 星期二 20:01:02'
 *
 *	       Ex6.
 *           var df_timestamp = new SimpleDateFormat('yyyy-MM-dd hh:mm:ss', SimpleDateFormat.US);
 *	             df_timestamp.format('2014-03-12 18:05:02')	    return  '2014-03-12 06:05:02'
 *
 *	@param pattern (String) : 日期顯示格式
 *                            ------------------------------------------------------
 *                              西元年
 *	                              yyyy 
 *	                              yyy  僅顯示後 3 碼（會因環境語言進行處理）
 *	                              yy   僅顯示後 2 碼（會因環境語言進行處理）
 *	                              y    僅顯示後 2 碼（會因環境語言進行處理）
 *                            ------------------------------------------------------
 *                              月份
 *	                              MMMM 完整單字顯示（會因環境語言進行處理）
 *	                              MMM  簡化單字顯示（會因環境語言進行處理）
 *	                              MM   
 *	                              M    當為 10 以下時，僅顯示 1 碼
 *                            ------------------------------------------------------
 *                              日期
 *	                              dd
 *	                              d    當為 10 以下時，僅顯示 1 碼
 *                            ------------------------------------------------------
 *                              星期
 *	                              EEEE 完整單字顯示（會因環境語言進行處理）
 *	                              EEE  簡化單字顯示（會因環境語言進行處理）
 *	                              EE   簡化單字顯示（會因環境語言進行處理）
 *	                              E    簡化單字顯示（會因環境語言進行處理）
 *                            ------------------------------------------------------
 *                              時
 *	                              HH   24 小時制
 *	                              H    24 小時制，當為 10 以下時，僅顯示 1 碼
 *	                              hh   12 小時制
 *	                              h    12 小時制，當為 10 以下時，僅顯示 1 碼
 *                            ------------------------------------------------------
 *                              分
 *	                              mm
 *	                              m    當為 10 以下時，僅顯示 1 碼
 *                            ------------------------------------------------------
 *                              秒
 *	                              ss
 *	                              s    當為 10 以下時，僅顯示 1 碼
 *                            ------------------------------------------------------
 *	@param locale (String)  : 環境語言
 *	                            SimpleDateFormat.TW : 中華民國
 *	                            SimpleDateFormat.US : 美國
 *	@author 劉本傑
 *	@version 1.00
 **/
function SimpleDateFormat(pattern, locale){

	var patternKey_month_full = 'MMMM';
	var patternKey_month_short = 'MMM';
	var patternKey_month = 'MM';
	var patternKey_month_sub = 'M';
	var patternKey_week_full = 'EEEE';
	var patternKey_week_short = 'EEE';
	var patternKey_week = 'EE';
	var patternKey_week_sub = 'E';
	var patternKey_hours12 = 'hh';
	var patternKey_hours12_sub = 'h';

	var useMonthArray;
	var useWeekArray;
	var patternKeyInfos;

	initSimpleDateFormat();

	function initSimpleDateFormat(){

		var isROC;
		if(locale && locale == SimpleDateFormat.US){
			useMonthArray = ['January','February','March','April','May','June','July','August','September','October','November','December'];
			useWeekArray = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
			isROC = false;
		}else{
			useMonthArray = ['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];
			useWeekArray = ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'];
			isROC = true;
		}

		var patternManager = [
			{'patternKey':'yyyy', 'callDateMethod':'getFullYear'},
			{'patternKey':'yyy', 'callDateMethod':'getFullYear', 'subLength': 3, 'isROC':isROC},
			{'patternKey':'yy', 'callDateMethod':'getFullYear', 'subLength': 2, 'isROC':isROC},
			{'patternKey':'y', 'callDateMethod':'getFullYear', 'subLength': 2, 'isROC':isROC},
			{'patternKey':'MMMM', 'callDateMethod':'getMonth', 'isAppendZero': 1, 'isFull':true},
			{'patternKey':'MMM', 'callDateMethod':'getMonth', 'isAppendZero': 1},
			{'patternKey':'MM', 'callDateMethod':'getMonth', 'isAppendZero': 1},
			{'patternKey':'M', 'callDateMethod':'getMonth', 'isAppendZero': 0},
			{'patternKey':'dd', 'callDateMethod':'getDate', 'isAppendZero': 1},
			{'patternKey':'d', 'callDateMethod':'getDate', 'isAppendZero': 0},
			{'patternKey':'EEEE', 'callDateMethod':'getDay', 'isFull':true},
			{'patternKey':'EEE', 'callDateMethod':'getDay'},
			{'patternKey':'EE', 'callDateMethod':'getDay'},
			{'patternKey':'E', 'callDateMethod':'getDay'},
			{'patternKey':'HH', 'callDateMethod':'getHours', 'isAppendZero': 1},
			{'patternKey':'H', 'callDateMethod':'getHours', 'isAppendZero': 0},
			{'patternKey':'hh', 'callDateMethod':'getHours', 'isAppendZero': 1},
			{'patternKey':'h', 'callDateMethod':'getHours', 'isAppendZero': 0},
			{'patternKey':'mm', 'callDateMethod':'getMinutes', 'isAppendZero': 1},
			{'patternKey':'m', 'callDateMethod':'getMinutes', 'isAppendZero': 0},
			{'patternKey':'ss', 'callDateMethod':'getSeconds', 'isAppendZero': 1},
			{'patternKey':'s', 'callDateMethod':'getSeconds', 'isAppendZero': 0}
		];
/*
		定義 pattern 群組
*/
		var patternGroupManager = {
			'yyyy': 'year', 'yyy': 'year', 'yy': 'year', 'y': 'year',
			'MMMM': 'month', 'MMM': 'month', 'MM': 'month', 'M': 'month',
			'dd': 'day', 'd': 'day',
			'EEEE': 'week', 'EEE': 'week', 'EE': 'week', 'E': 'week',
			'HH': 'hour', 'H': 'hour',
			'hh': 'hour', 'h': 'hour',
			'mm': 'minute', 'm': 'minute',
			'ss': 'second', 's': 'second'
		}

		var setFormatPatterns = {};

		pattern = pattern || 'yyyy-MM-dd';

		patternKeyInfos = [];

/*
		將 patternManager 內 patternKey 設定相關位置
*/
		for(var i=0;i<patternManager.length;i++){
			var pat = patternManager[i];
			var patternKey = pat['patternKey'];
			var patg = patternGroupManager[patternKey];

			var index = pattern.indexOf(patternKey);
			if(index<0 || !patg || setFormatPatterns[patg]){
				continue;
			}
			patternKeyInfos.push({
				'index': index, 'patternKey':patternKey, 'callDateMethod':pat['callDateMethod'],
				'subLength': (pat['subLength']||'0'), 'isFull': (pat['isFull']||false), 'isAppendZero': (pat['isAppendZero']||0),
				'isROC': pat['isROC']||false
			});
			setFormatPatterns[patg]='Y'
		}
/*
		將準備顯示之年月日，依指定格式進行排序
*/
		patternKeyInfos.sort(function(obj1, obj2){
			return obj1['index']-obj2['index'];
		});

	}

	/**
	 *	@public
	 *	@class 轉為日期物件
	 *	@param srcData (String) : 西元日期
	 *	@return Date
	 *	@author 劉本傑
	 *	@version 1.00
	 **/
	function stringToDate(srcData){
		var d;
		if((
			srcData.match(/^(\d{4})(\d{2})(\d{2})$/))
			|| (srcData.match(/^(\d{4})\/(\d{2})\/(\d{2})$/))
			|| (srcData.match(/^(\d{4})-(\d{2})-(\d{2})$/))
		) {
			d = new Date(RegExp.$1,RegExp.$2-1,RegExp.$3);
		}else if(
			srcData.match(/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/)
			|| srcData.match(/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}).(\d{1,6})$/)
		) {
			d = new Date(RegExp.$1,RegExp.$2-1,RegExp.$3,RegExp.$4,RegExp.$5,RegExp.$6);
		}
		return d;
	}

	/**
	 *	@public
	 *	@class 日期格式顯示處理，若不為日期格式時，則回傳原值
	 *	       符合的日期格式：1.yyyyMMdd 2.yyyy/MM/dd 3.yyyy-MM-dd
	 *	       符合的日期格式：1.yyyy-MM-dd HH:mm:ss 2.yyyy-MM-dd HH:mm:ss.SSS 3.yyyy-MM-dd HH:mm:ss.SSSSSS
	 *	@param inDate (String) : 傳入日期
	 *	@param String
	 *	@author 劉本傑
	 *	@version 1.00
	 **/
	this.format = function(inDate){

		if(typeof(inDate) != 'string' || inDate===''){
			return '';
		}

		var d = stringToDate(inDate);
		if(!d){
			return inDate;
		}

		var outStr = '';
		var patternKeyInfosLength = patternKeyInfos.length;
		var patternLength = pattern.length;
		for(var i=0;i<patternKeyInfosLength;i++){
			var pki = patternKeyInfos[i];
			var index = pki['index'];
			var value = d[pki['callDateMethod']]();
			var patKey = pki['patternKey'];

			if(i==0){
				if(index!=0){
					outStr += pattern.substr(0, index);
				}
			}else{

				var previousPki = patternKeyInfos[i-1];
				var previousWordLastIndex = previousPki['index']+previousPki['patternKey'].length;

				if(previousWordLastIndex<index){
					outStr += pattern.substr(previousWordLastIndex, index-previousWordLastIndex);
				}

			}

			var isAppend = true;
			if(patKey==patternKey_month_sub || patKey==patternKey_month){
/*
由 Date 取得月份時，由 0 開始計算，故需 +1
*/
				value+=1;

			}else if(patKey==patternKey_month_full || patKey==patternKey_month_short){

				if(useMonthArray){
					var mvalue = useMonthArray[value];
					if(!pki['isFull']){
						if(locale == SimpleDateFormat.TW && mvalue.length>0){
							mvalue = mvalue.substr(0,mvalue.length-1);
						}else if(mvalue.length>3){
							mvalue = mvalue.substr(0,3);
						}
					}
					outStr += mvalue;
					isAppend= false;
				}else{
/*
					由 Date 取得月份時，由 0 開始計算，故需 +1
*/
					value+=1;
				}

			}else if(patKey==patternKey_week || patKey==patternKey_week_sub || patKey==patternKey_week_full ||patKey==patternKey_week_short){
				var wvalue = useWeekArray[value];
				if(!pki['isFull']){
					if(locale == SimpleDateFormat.US){
						wvalue = wvalue.substr(0, 3);
					}else{
						var wvalueLength = wvalue.length;
						wvalue = wvalue.substr(wvalueLength-1, wvalueLength);
					}
				}

				outStr += wvalue;
				isAppend= false;
			}else if(patKey==patternKey_hours12 || patKey==patternKey_hours12_sub){
				if(value>12){
					value -= 12;
				}
			}

			if(isAppend){
				var isAppendZero = pki['isAppendZero'];
/*
				不足 10 之參數則在前方補 0
*/
				if(isAppendZero>0 && value<10){
					outStr += '0';
				}
				if(pki['isROC']){
					value = value - 1911;
				}
				value = value.toString();
				var subLength = pki['subLength'];
				var valueLength = value.length;
				if(subLength>0 && valueLength>subLength){
					value = value.substr(valueLength-subLength);
				}
				outStr += value;
			}
/*
			將 pattern 最後一段進行顯示
*/
			if(i==patternKeyInfosLength-1){
				var lastIndex = index+patKey.length;
				if(lastIndex < patternLength){
					outStr += pattern.substr(lastIndex, patternLength);
				}
			}

		}

		return outStr;
	}
}

function createDateJs(){

	function formatValue(v){
		return v<10?'0'+v:v;
	}

	function formatValueMilliseconds(v){
		if(v<10){
			return '00'+v;
		}
		if(v<100){
			return '0'+v;
		}
		return v;
	};

	function sleep(ms){
		var sleepingTime = new Date();
			sleepingTime.setTime(sleepingTime.getTime() + ms);
		while (new Date().getTime() < sleepingTime.getTime());
	}

	function formatCurrentTimeStamp(){
		var currentDate = new Date();
		var str = "";
			str += currentDate.getFullYear();
			str += '-'+formatValue(currentDate.getMonth()+1);
			str += '-'+formatValue(currentDate.getDate());
			str += ' '+formatValue(currentDate.getHours());
			str += ':'+formatValue(currentDate.getMinutes());
			str += ':'+formatValue(currentDate.getSeconds());
			str += '.'+formatValueMilliseconds(currentDate.getMilliseconds());
		return str;		
	}

	this.getCurrentTimeStamp = function(){
		var currentTimeStamp = formatCurrentTimeStamp();
		if(currentTimeStamp.indexOf('00:00:00.000')>0){
			sleep(100);
			currentTimeStamp = formatCurrentTimeStamp();
		}
		return currentTimeStamp;
	};

	this.isDateYM = function(srcDate,isROC){
		var vp = isROC?new RegExp(/^(\d{2,3})(0[1-9]|1[0-2])$/):new RegExp(/^(\d{4})(0[1-9]|1[0-2])$/);
		return vp.test(srcDate);
	};
}

if(!window.dateJs){
	window.dateJs = new createDateJs();
}