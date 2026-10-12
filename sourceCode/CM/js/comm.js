function isFilled(text){
var returnflag = true;
if (text.value.length==0) 
 { 
returnflag = false;
 }
else
 {
    for ( i = 0; i < text.value.length; i++ )
      {
       var textTemp = text.value.charAt(i)
    
       if ( textTemp != " " )
          {
           var textResult = text.value.substring(i);
  	    break;
	  }
       else if (i == text.value.length-1)
          {
           returnflag = false;
           text.select();    
           break;
          }
      }
  }//esle的大括號  
return returnflag;
}

/**********************************************************************/
/*Function name 	  :isDate(s,f)				      */
/*Usage of this function  :To check s is a valid format 	      */ 
/*Input parameter required:s=input string			      */
/*			   f=input string format		      */ 
/*			    =1,in mm/dd/yyyy format		      */
/*			    else in dd/mm/yyyy			      */
/*Return value		  :if is a valid date return 1 		      */ 
/*			   else return 0			      */ 
/*Function required	  :isPositiveInteger()      	              */
/**********************************************************************/   
function isNormalDate(dateField)
{   
    var s = dateField.value ;	
    var a1=s.split("/");
 
    var a2=s.split("-");
    
    var e=true;
//判斷a1及a2切割後的長度是否等於3
    
    if ((a1.length!=3) && (a2.length!=3)) 
      { 
	e=false;
      }
    else
      {
       if (a1.length==3)
	 var na=a1;
       if (a2.length==3)
	 var na=a2;
       if (isPositiveInteger(na[0]) &&	isPositiveInteger(na[1]) && isPositiveInteger(na[2]))
	 {
	    var d=na[2],m=na[1];
	    var y=na[0];
	    if ((e) && (y<1000))
	      e=false
	    if (e) {
              v=new Date(m+"/"+d+"/"+y);
              if (v.getMonth()!=m-1){  
                e=false; 
              }
	    } 
	 }
       else
	{ 
	  e=false;
	}	
       }
    return e
}
/**********************************************************************/
/*Function name 	  :isYMD_Date(s,f)				      */
/*Usage of this function  :To check s is a valid format 	      */ 
/*Input parameter required:s=input string			      */
/*		ex:20080101 && 2008-01-01	&&	2008/01/01		      */
/*Return value		  :if is a valid date return 1 		      */ 
/*			   else return 0			      */ 
/*Function required	  :isPositiveInteger()      	              */
/**********************************************************************/   
function isYMD_Date(sDate){
		
		sDate = sDate.replace('/',  '');
		sDate = sDate.replace('-',  '');
		sDate = sDate.replace('/',  '');
		sDate = sDate.replace('-',  '');
		if(isNaN(sDate)) {
			return false;
		}
		var date = new String(sDate);
		if(date.length!=8) {
			return false;
		}
	
		var year = date.substring(0,4);
		var month = date.substring(4,6);
		var day = date.substring(6,8);

		var arrayMonth = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
					
		if(year.charAt(0) == '0'){
				year = year.charAt(1) + year.charAt(2);
		}

		if(month > 12) {
			return false;
		}
		var checkDay = 0;
		if(month == 2){
			if( ( (0 == year % 4) && (0 != (year % 100)) ) || (0 == year % 400) ){
				checkDay = 29;
			}else{
				checkDay = 28;
			}
		}else{
			checkDay = arrayMonth[month-1];
		}
		if(day<1){
			return false;
		}else if(day > checkDay){
			return false;
		} else {
			return true;
		}
				
		return false;
	}
/**********************************************************************/
/*Function name 	  :isleapyear(iyear)			      */
/*Usage of this function  :To check whether iyear is leap year	      */ 
/*Input parameter required:iyear				      */
/*Return value		  :if is a leap year return 1		      */ 
/*			   else return 0			      */ 
/**********************************************************************/
    function isleapyear(iyear)
    {	 var l=new Array(100,400,4),leap=0,c;
	 for (c=0;c<3;c++)
	  {if (iyear%l[c]==0)
	    leap++;
	  }
	if ((leap==1)||(leap==3))//if leap year
	 return(1);
	else
	 return(0);  
    }

/**********************************************************************/
/*Function name 	  :isDigit(theDigit)			      */
/*Usage of this function  :test for an digit			      */ 
/*Input parameter required:thedata=string for test whether is digit   */
/*Return value		  :if is digit,return true		      */ 
/*			   else return false			      */
/**********************************************************************/
function isDigit(theDigit)
{
  var digitArray = new Array('0','1','2','3','4','5','6','7','8','9'),j;
   
      for (j = 0; j < digitArray.length; j++)
	 {if (theDigit == digitArray[j])
	    return true
	 }   
   return false

}
/*************************************************************************/
/*Function name 	  :isPositiveInteger(theString) 		 */
/*Usage of this function  :test for an +ve integer			 */ 
/*Input parameter required:thedata=string for test whether is +ve integer*/
/*Return value		  :if is +ve integer,return true		 */ 
/*			   else return false				 */
/*function require        :isDigit                                       */
/*************************************************************************/
function isPositiveInteger(theString)
{
   var theData = new String(theString)
   if (!isDigit(theData.charAt(0)))
      if (!(theData.charAt(0)== '+'))
	 return false
   for (var i = 1; i < theData.length; i++)
      if (!isDigit(theData.charAt(i)))
	 return false
   return true
}


function chkNumber(value) {
      var valid = "0123456789-.,";
	  var ind = 1;
      var temp;
      for (var i=value.length; i>0; i--) {
        temp = "" + value.substring(i, i-1);
        if (valid.indexOf(temp) == "-1"){ 
           return false;
        }
        
		if(temp=="0" && i==1)
          return false ;
		
		if (temp==","){
	  		if(ind!=4||i==1) 
           		return false ;
        }
		
		if(ind == 4 ){
	  		ind = 1;
        }else{
	  		ind = ind +1
        }
      }
      return true;
    }
/*************************************************
/* 設定某一個元件是否為enable的
/* 參數 o 指定的元件
/* 參數 flag 為 boolean 值
/**************************************************/    
function setDisable(o,flag){
	o.disabled=flag;
}    


// 檢驗傳入的日期是否早於今天
// author: Sam Ho
// date: 2003/09/25
// param: baseDate - 要比較的日期，必須為"yyyy/MM/dd"的格式。
function isBeforeToday (baseDate) {
	today = new Date();		
	
	today.setHours(0);
	today.setMinutes(0);
	today.setSeconds(0);
	today.setMilliseconds(0);
	
	input = Date.parse(baseDate);
		
	if((today.getTime() - input) >= 0 ) {
		return true;
	}
	else {
		return false;
	}	
}

/**
 *	檢查傳入值是否為指定數值型態
 *	回傳true/false
 * 	ex.isDecimal("23.910",5,3) = true
 */
function isDecimal(number, decilen, postDeciLen) {
	if (number.length!=(decilen+1)) {
		return false;
	}

	return (number.indexOf('.')==(decilen -postDeciLen));
}