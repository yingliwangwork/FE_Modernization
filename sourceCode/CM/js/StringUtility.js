/*
程式：StringUtil.js 
功能：提供JavaScript String 處理函數
完成：2006/06/23
*/


//使用String物件之prototype屬性延伸String物件之方法
String.prototype.rTrim = rTrim;
String.prototype.lTrim = lTrim;
String.prototype.trim = trim;
String.prototype.rTrimFULL = rTrimFULL;
String.prototype.lTrimFULL= lTrimFULL;
String.prototype.trimFULL = trimFULL;
String.prototype.trimALL = trimALL;

//------------------------------------------------------------------------------ 
//去除右邊之空白(全形)字元
function rTrimFULL(){
    var orgStr= this.toString();
    var str=orgStr;
    while( str.length >0) {
        if (str.charAt(str.length-1) != '　'){
            break;
        }
        str=str.substring(0, str.length-1) ;
    }
    return str ;
} 
//------------------------------------------------------------------------------ 
//去除右邊之空白(半形)字元
function rTrim(){
    var orgStr= this.toString();
    var str=orgStr;
    while( str.length >0) {
        if (str.charAt(str.length-1) != ' '){
            break;
        }
        str=str.substring(0, str.length-1) ;
    }
    return str ;
}
//------------------------------------------------------------------------------
//去除左邊之(全形)空白字元
function trimFULL(){
    var orgStr= this.toString();
    var str=orgStr;
    while (str.length>0){
        if (str.charAt(0) != '　'){
            break;
        }
        str=str.substring(1, str.length) ;
    }
    return str;
}
//------------------------------------------------------------------------------ 
//去除左邊之(半形)空白字元
function lTrim(){
    var orgStr= this.toString();
    var str=orgStr;
    while (str.length>0){
        if (str.charAt(0) != ' '){
            break;
        }
        str=str.substring(1, str.length) ;
    }
    return str;
}
//------------------------------------------------------------------------------
//去除左右兩邊之(半形)空白字元
function trim(){
    var orgStr= this.toString();
    var str=orgStr;
    return str=(str.lTrim()).rTrim();
}
//------------------------------------------------------------------------------ 
//去除左右兩邊之(全形)空白字元
function trimFULL(){
    var orgStr= this.toString();
    var str=orgStr;
    return str=(str.lTrimFULL()).rTrimFULL();
}
//------------------------------------------------------------------------------ 